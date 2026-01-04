-- Conclusion: Got this working, but it turns out the idea of going by blocks is fundamentally flawed
-- Even with "obvious" chunks, the dependency graph is much too concave in weird unexpected ways to assume any consistent structure
-- For example, item-craft should clearly go with item, right? Well, stone's "item-craft" is off with recycler, far far away
-- Even if you fix that, more things come up, and more, and more; this was where I concluded impossibility


-- This is mostly a copy-paste of top-sort.lua now and should probably be integrated into that function after testing

local lib_name = "new-lib" -- Use this until integration with "old" lib
local gutils = require(lib_name .. "/graph/graph-utils")
-- Used for gathering contexts, etc. not for the actual graph
local logic = require(lib_name .. "/logic/init")

local key = gutils.key

local block = {}

-- blocks has .group_node_set and .node_to_group (you're meant to just pass in the blockify object after calling blockify.get)
block.sort = function(graph, state, new_conn, initial_sort, blocks, extra)
    state = state or {}
    -- node_to_contexts goes node_key --> true | { context_name --> true/false }
    -- There is also special case of node_key --> nil | {} (no contexts/unreachable) and node_key --> true (all contexts) for performance
    -- TODO: standardize so it's node_key --> {} everywhere
    local node_to_contexts = state.node_to_contexts or {}
    -- Counters for efficiently determining how many prereqs of a node have a given context
    -- To determine number that need that context, we'll just call a helper function for number of edges into a node
    local node_context_to_satisfied = state.node_context_to_satisfied or {}
    local open = state.open or {}
    local in_open = state.in_open or {}
    -- I think we haven't fully implemented this yet
    -- TODO: Implement!
    local node_to_open_inds = state.node_to_open_inds or {}
    -- A map of an ind to the previous ind of the node that added it
    -- This is more complex with block sort, so let's hold off on it right now
    --local ind_to_ind = state.ind_to_ind or {}
    local ind = state.ind or 1

    -- A map from node keys to their first index in initial_sort
    local node_to_first_ind = {}
    for node_key, inds in pairs(initial_sort.node_to_open_inds) do
        local smallest_ind
        for ind, _ in pairs(inds) do
            if smallest_ind == nil or smallest_ind > ind then
                smallest_ind = ind
            end
        end
        node_to_first_ind[node_key] = smallest_ind
    end

    -- Block preprocessing
    -- Just keep track of frontier nodes reached by some context right now
    -- Frontier nodes in a block are those with a forward connection to them from outside the block
    -- We care about forwardness just in case an OR node only has backward connections from outside and should be satisfied within the block
    -- In that case we don't want it to be a frontier
    -- Forwardness is determined by first index in initial_sort
    -- We try to process a whole block if all nodes on the frontier would get context, excluding intra-block nodes

    -- Get frontier nodes/edges
    -- How to represent group pools?
    -- Maybe we do group_to_completed_frontier
    -- If all of those have turned true, we allow group to be processed in open_groups
    local group_to_frontier_size = {}
    -- group_to_remaining_frontier goes from group and node_key to true if not completed yet, or nil (not false) if completed
    -- To check if a group is completed, we check if next(group_to_remaining_frontier) == nil
    local group_to_remaining_frontier = {}
    local open_groups = {}
    -- Gives nil if not in open_groups
    local group_to_open_ind = {}
    -- Only set to true when group is processed
    local is_processed_group = {}
    local open_group_ind = 1
    for group_name, node_set in pairs(blocks.group_node_set) do
        group_to_frontier_size[group_name] = {}
        -- Used mainly for AND nodes since they just need the connections from the outside to give context to be satisfied for the purpose of the group being satisfied
        group_to_remaining_frontier[group_name] = {}
        for node_key, _ in pairs(node_set) do
            local node = graph.nodes[node_key]
            local frontier_edges = {}
            group_to_frontier_size[group_name][node_key] = 0
            for pre, _ in pairs(node.pre) do
                -- Need to check A. If prenode is outside group, and B. If edge is forward
                local prenode = graph.nodes[graph.edges[pre].start]
                -- Note that we also need to check if node_to_first_ind even exists, since we're iterating over the *whole* graph, and node_to_first_ind is only for reachable nodes
                if not node_set[key(prenode)] and node_to_first_ind[key(prenode)] ~= nil and node_to_first_ind[node_key] ~= nil and node_to_first_ind[key(prenode)] < node_to_first_ind[node_key] then
                    frontier_edges[pre] = true
                    group_to_frontier_size[group_name][node_key] = group_to_frontier_size[group_name][node_key] + 1
                end
            end
            
            if next(frontier_edges) ~= nil then
                group_to_remaining_frontier[group_name][node_key] = true
            end
        end
    end

    -- Note that when we propagate, don't go past the frontier of un-added blocks, but we might propagate into old blocks again to add new contexts
    -- Let's not support new_conn yet (silently ignore)

    -- Note: this should probably become a general utility function
    local function is_context_reachable(node_key)
        local contexts = node_to_contexts[node_key]
        return contexts == true or (type(contexts) == "table" and next(contexts) ~= nil)
    end

    -- Merges added contexts onto base contexts
    -- Returns {union = base, new = false} if added is a subset of base
    -- Otherwise, returns {union = true, new = true} if base now has all contexts
    -- Otherwise, returns all the contexts after merge with union and the new contexts from added alone
    local function merge_contexts(base, added)
        -- base already has all contexts, so is a superset of added
        if base == true then
            return {union = base, added = false}
        end

        -- Since we already check if base is true (keep invariant that all contexts is always true, never full set of contexts), this must add at least one context
        if added == true then
            return {union = true, added = true}
        end

        -- TODO: Check if we have context lists being false ever
        -- We don't want that, since it's an extra case to check and just as efficient as testing empty tables
        -- Technically we should be therefore checking if added is empty table here, but eh

        -- Now check contexts
        -- Iterate through logic.contexts so that we can simultaneously check if all contexts fulfilled
        local all_contexts_fulfilled = true
        local new_contexts = {}
        local new_base = {}
        for context, _ in pairs(logic.contexts) do
            -- First check if this is a new context
            if not base[context] and added[context] then
                new_contexts[context] = true
            end
            -- Now check if this context isn't in either
            if not base[context] and not added[context] then
                all_contexts_fulfilled = false
            else
                new_base[context] = true
            end
        end
        if all_contexts_fulfilled then
            return {union = true, added = true}
        else
            return {union = new_base, added = new_contexts}
        end
    end

    -- Take input contexts and produce outgoing contexts given a node based off its context type info
    local function transmit_contexts(node, incoming)
        local context_info = logic.type_info[node.type].context

        if context_info == nil then
            -- Context simply transmitted; majority of cases
            return table.deepcopy(incoming)
        elseif context_info == true then
            -- Case of forgetter
            return true
        elseif type(context_info) == "string" then
            -- Case of emitter of single context
            -- Since context_info is per-type, and room context transmission is per node name, we need to use the node.name for the specific context transmitted
            return {
                [node.name] = true
            }
        end
    end

    local function add_group_to_open(group_name)
        table.insert(open_groups, group_name)
        group_to_open_ind[group_name] = #open_groups
    end

    -- Add a single node to open; assume incoming contexts has already been updated to be "true" or just the new contexts
    -- left_in_group can be true, signalling that it is being constructed and group is definitely not completed yet
    local function add_to_open(node, incoming, group_name, to_add_to_open, node_to_ind_in_to_add_to_open, left_in_group)
        local node_key = key(node)

        -- We now do the deepcopy onto outgoing for efficiency, since there is a chance it becomes not a table anyways, reducing the need to deepcopy
        -- TODO: Check if any deepcopy is even necessary; I think we're looking at table elements one by one anyways, maybe it will change with more complex contexts?
        -- I think table.deepcopy's aren't needed here, but I'll add just in case
        -- If this is being added due to being on a group frontier, we have to be careful to treat it as if it wasn't added at all yet
        local old_incoming = node_to_contexts[node_key] or {}
        if left_in_group == true then
            old_incoming = {}
        end
        local old_outgoing = table.deepcopy(transmit_contexts(node, old_incoming))
        local outgoing = table.deepcopy(transmit_contexts(node, incoming))
        local merge_info_incoming = merge_contexts(node_to_contexts[node_key] or {}, incoming)
        -- We have to update node_to_contexts here, since that's how we tell what nodes to reprocess when group is done, and what groups become ready
        node_to_contexts[node_key] = merge_info_incoming.union
        local merge_info_outgoing = merge_contexts(old_outgoing, outgoing)

        -- If nothing new outgoing was added, return
        if merge_info_outgoing.added == false then
            return
        end

        -- Update group info; this could already have been set to nil but no harm in doing it again
        local node_group = blocks.node_to_group[node_key]
        local remaining_frontier = group_to_remaining_frontier[node_group]
        remaining_frontier[node_key] = nil
        if next(remaining_frontier) == nil and group_to_open_ind[node_group] == nil then
            table.insert(open_groups, node_group)
            group_to_open_ind[node_group] = #open_groups
        end

        if node.op == "OR" then
            local open_ind = in_open[node_key]
            local to_add_open_ind = node_to_ind_in_to_add_to_open[node_key]

            -- TODO: Find way to combine this with AND logic (very similar/code duplication)
            if open_ind ~= nil then
                open[open_ind].contexts = merge_contexts(open[open_ind].contexts, outgoing).union
            elseif to_add_open_ind ~= nil then
                to_add_to_open[to_add_open_ind].contexts = merge_contexts(to_add_to_open[to_add_open_ind].contexts, outgoing).union
            elseif blocks.node_to_group[node_key] == group_name or (left_in_group ~= true and next(left_in_group) == nil and is_processed_group[blocks.node_to_group[node_key]]) then
                table.insert(open, {
                    node = node_key,
                    contexts = merge_info_outgoing.added,
                    -- Don't worry about incoming for now
                })
                in_open[node_key] = #open
                -- Don't worry about ind_to_ind for now
            elseif is_processed_group[blocks.node_to_group[node_key]] then
                table.insert(to_add_to_open, {
                    node = node_key,
                    contexts = merge_info_outgoing.added
                })
                node_to_ind_in_to_add_to_open[node_key] = #to_add_to_open
            -- If it's in an unprocessed group, it will be naturally found when searching for source groups
            end
        else
            -- For AND nodes, in_open doesn't really matter (at least for now)
            if blocks.node_to_group[node_key] == group_name or (left_in_group ~= true and next(left_in_group) == nil and is_processed_group[blocks.node_to_group[node_key]]) then
                table.insert(open, {
                    node = node_key,
                    contexts = merge_info_outgoing.added,
                })
                in_open[node_key] = #open
                -- node_to_open_inds is updated on processing a node in open for simplicity, so don't need to check that now either
                -- Also, since we're not doing ind_to_ind yet, this makes the AND implementation here complete
            elseif is_processed_group[blocks.node_to_group[node_key]] then
                table.insert(to_add_to_open, {
                    node = node_key,
                    contexts = merge_info_outgoing.added
                })
                node_to_ind_in_to_add_to_open[node_key] = #to_add_to_open
            end
        end
    end

    local function process_dep(dep, open_info, old_contexts, merge_info, group_name, to_add_to_open, node_to_ind_in_to_add_to_open, left_in_group)
        local edge = graph.edges[dep]
        -- Check if the dependent already has all incoming contexts for efficiency, or if we got no new outgoing contexts
        if node_to_contexts[edge.stop] ~= true and merge_info.added ~= false then
            local end_node_key = edge.stop
            local end_node = graph.nodes[end_node_key]

            -- TODO: This table population would probably be more efficient in a general node loop
            node_to_contexts[end_node_key] = node_to_contexts[end_node_key] or {}

            -- TODO: If end_node has one prereq, treat it specially for efficiency
            if end_node.op == "AND" then
                if node_to_contexts[open_info.node] == true then
                    -- If we now carry all contexts, remove single contexts and add to all
                    node_context_to_satisfied[end_node_key] = node_context_to_satisfied[end_node_key] or {}
                    node_context_to_satisfied[end_node_key]["all"] = (node_context_to_satisfied[end_node_key]["all"] or 0) + 1
                    for old_context, _ in pairs(old_contexts) do
                        node_context_to_satisfied[end_node_key][old_context] = node_context_to_satisfied[end_node_key][old_context] - 1
                    end
                else
                    -- Otherwise, just add the new contexts
                    node_context_to_satisfied[end_node_key] = node_context_to_satisfied[end_node_key] or {}
                    for context, _ in pairs(merge_info.added) do
                        node_context_to_satisfied[end_node_key][context] = (node_context_to_satisfied[end_node_key][context] or 0) + 1
                    end
                end

                -- Pretend like the intra-block edges don't exist if this node isn't in a processed block
                local num_edges_to_check = end_node.num_pre
                local end_node_group = blocks.node_to_group[end_node_key]
                if not is_processed_group[end_node_group] then
                    num_edges_to_check = group_to_frontier_size[end_node_group][end_node_key]
                end

                -- Check if we've satisfied a new context
                local new_contexts = {}
                local add_all_contexts
                if merge_info.added == true then
                    -- If "all", check all contexts
                    add_all_contexts = true
                    for context, _ in pairs(logic.contexts) do
                        if not node_to_contexts[end_node_key][context] then
                            if (node_context_to_satisfied[end_node_key][context] or 0) + (node_context_to_satisfied[end_node_key]["all"] or 0) == num_edges_to_check then
                                new_contexts[context] = true
                            else
                                add_all_contexts = false
                            end
                        end
                    end
                else
                    -- If not "all"/true, then we know not all contexts will be satisfied, so we don't need to update it
                    for context, _ in pairs(merge_info.added) do
                        -- The next check is probably redundant here
                        if not node_to_contexts[end_node_key][context] then
                            if (node_context_to_satisfied[end_node_key][context] or 0) + (node_context_to_satisfied[end_node_key]["all"] or 0) == num_edges_to_check then
                                new_contexts[context] = true
                            end
                        end
                    end
                end

                if next(new_contexts) ~= nil then
                    if add_all_contexts then
                        -- add_to_open is where the checks for whether this group is completed, whether end_node is in an active block, etc. happen, so we need to pass through all this group info
                        add_to_open(end_node, true, group_name, to_add_to_open, node_to_ind_in_to_add_to_open, left_in_group)
                    else
                        add_to_open(end_node, new_contexts, group_name, to_add_to_open, node_to_ind_in_to_add_to_open, left_in_group)
                    end
                end
            elseif end_node.op == "OR" then
                local new_contexts = {}
                if node_to_contexts[open_info.node] == true then
                    new_contexts = true
                else
                    for context, _ in pairs(open_info.contexts) do
                        if not node_to_contexts[end_node_key][context] then
                            new_contexts[context] = true
                        end
                    end
                end
                if new_contexts == true or next(new_contexts) ~= nil then
                    add_to_open(end_node, new_contexts, group_name, to_add_to_open, node_to_ind_in_to_add_to_open, left_in_group)
                end
            else
                error("Node op not OR or AND")
            end
        end
    end

    -- Add "source" groups (no incoming edges, and no falsey nodes)
    -- By monotonicity, such blocks must be fillable
    for group_name, node_set in pairs(blocks.group_node_set) do
        local is_source_block = true
        -- We don't break early here, because this is also where we set the AND source contexts
        for node_key, _ in pairs(node_set) do
            local node = graph.nodes[node_key]
            -- First check for falsiness
            if node.op == "OR" and node.num_pre == 0 then
                is_source_block = false
            elseif node.op == "AND" and node.num_pre == 0 then
                -- We need to add contexts here for this source to show it's reachable
                node_to_contexts[node_key] = true
            end
            -- Next, node must have only intra-block edges
            local is_intra_block = true
            for pre, _ in pairs(node.pre) do
                local pre_key = graph.edges[pre].start
                if blocks.node_to_group[pre_key] ~= group_name then
                    is_intra_block = false
                end
            end
            if not is_intra_block then
                is_source_block = false
            end
        end
        if is_source_block then
            add_group_to_open(group_name)
        end
    end

    while open_group_ind <= #open_groups do
        -- Because node_to_contexts stores the relevant info for group frontier context for us already, we can just have open_groups store group names
        local group_name = open_groups[open_group_ind]
        is_processed_group[group_name] = true
        log("Processing group " .. group_name)

        -- Don't update in_open; groups aren't revisited, just their individual nodes, so we don't forget their existence from open_groups
        -- They act like AND nodes anyways

        -- We were pretending before that AND nodes on the frontier of a group already had their intra-group edges satsified
        -- However, this gives them context when they shouldn't have it yet, so we just need to remove it for those nodes
        -- I think nothing else needs to be changed
        for node_key, _ in pairs(blocks.group_node_set[group_name]) do
            local node = graph.nodes[node_key]
            if node.op == "AND" and group_to_frontier_size[group_name][node_key] ~= nil and node.num_pre ~= group_to_frontier_size[group_name][node_key] then
                node_to_contexts[node_key] = {}
            end
        end

        -- For each node in group, test if it's reachable (has contexts), and if so add to 
        -- We'll assume we update node_to_contexts when a node propagates, so we can just test for nodes with context here
        -- These nodes just get added to open

        -- We'll also keep track of which group nodes have been added to open so far
        -- At the beginning of the inner node loop, we add all nodes to open from to_add_to_open if list of group nodes left to find is empty
        -- We also allow adding nodes outside group directly to open (as long as they are from active groups)
        local left_in_group = {}
        -- Process nodes again
        -- Need process just block nodes; keep track of nodes added to add to open once block is finished
        local to_add_to_open = {}
        -- Needed for OR nodes
        -- This is getting a bit ugly
        local node_to_ind_in_to_add_to_open = {}
        for node_key, _ in pairs(blocks.group_node_set[group_name]) do
            if is_context_reachable(node_key) then
                add_to_open(graph.nodes[node_key], node_to_contexts[node_key], group_name, to_add_to_open, node_to_ind_in_to_add_to_open, true)
            end
            left_in_group[node_key] = true
        end

        while ind <= #open do
            local open_info = open[ind]
            local node_key = open_info.node
            log("Processing node " .. node_key)
            local node = graph.nodes[open_info.node]
            -- There must be some new context or else this would have never been added to open in the first place
            local new_contexts = open_info.contexts
            -- Remove from in_open (used for just OR nodes now)
            in_open[node_key] = nil
            -- Update that this is no longer an unreachable in the group if applicable too
            if left_in_group[node_key] ~= nil then
                left_in_group[node_key] = nil
            end
            -- Update node_to_open_inds map of node to inds in open it appears at
            node_to_open_inds[node_key] = node_to_open_inds[node_key] or {}
            node_to_open_inds[node_key][ind] = true

            -- Now process dependents
            for dep, _ in pairs(node.dep) do
                local old_contexts = node_to_contexts[graph.edges[dep].stop] or {}
                local merge_info = merge_contexts(old_contexts, new_contexts)
                process_dep(dep, open_info, old_contexts, merge_info, group_name, to_add_to_open, node_to_ind_in_to_add_to_open, left_in_group)
            end

            if next(left_in_group) == nil and next(to_add_to_open) ~= nil then
                -- Add nodes from to_add_to_open
                -- These nodes were already fully processed; they just need to be moved to the right list
                for _, to_add_open_info in pairs(to_add_to_open) do
                    table.insert(open, to_add_open_info)
                end
                to_add_to_open = {}
            end

            ind = ind + 1
        end

        -- I think partial reaching is just bound to happen; hard to predict
        -- We do need to re-plan the algorithm around it though
        --[[if next(left_in_group) ~= nil then
            -- It's perfectly fine to be partial on unreachable groups
            local all_reachable = true
            for node_key, _ in pairs(left_in_group) do
                local final_contexts = initial_sort.node_to_contexts[node_key]
                if not (final_contexts == true or (type(final_contexts) == "table" and next(final_contexts) ~= nil)) then
                    all_reachable = false
                end
            end
            if all_reachable then
                log(serpent.block(left_in_group))
                log(serpent.block(group_to_frontier_size[group_name]))
                for node_name, _ in pairs(left_in_group) do
                    log(serpent.block(graph.nodes[node_name]))
                end
                error("Group " .. group_name .. " not reachable in one go.")
            end
        end]]

        open_group_ind = open_group_ind + 1
    end

    return {
        node_to_contexts = node_to_contexts,
        node_context_to_satisfied = node_context_to_satisfied,
        open = open,
        in_open = in_open,
        node_to_open_inds = node_to_open_inds,
        -- We'll get to ind_to_ind later
        --ind_to_ind = ind_to_ind,
        ind = ind,
        group_to_frontier_size = group_to_frontier_size,
        group_to_remaining_frontier = group_to_remaining_frontier,
        open_groups = open_groups,
        group_to_open_ind = group_to_open_ind,
        is_processed_group = is_processed_group,
        open_group_ind = open_group_ind,
    }
end

return block