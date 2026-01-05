-- A topological sort with context
-- I realized midway through that contexts will rarely be all true so a lot of the optimizations don't do much; this is because we won't have all planets reachable right away
-- However, there are times when we'll be able to get context to any nodes that we can reach, like transportable items, so that could be a future optimization
-- This could be done by testing which nodes are "surface agnostic" at any point, i.e.- if we could reach all planets, then they would transmit all contexts
-- For this, we'd need to transmit contexts regardless of reachability and keep that a separate concept

local lib_name = "new-lib" -- Use this until integration with "old" lib
local gutils = require(lib_name .. "/graph/graph-utils")
-- Used for gathering contexts, etc. not for the actual graph
local logic = require(lib_name .. "/logic/logic")

local key = gutils.key

local top = {}

-- We'll just do basic top sort without blacklists or state saving for now
-- Okay, now we have state saving
-- new_conn should carry edge AND new contexts (contexts from old node)
top.sort = function(graph, state, new_conn, extra)
    state = state or {}
    -- node_to_contexts goes node_key --> { context_name --> true/false }
    -- SIMPLIFIED: No longer using true as special "all contexts" value
    local node_to_contexts = state.node_to_contexts or {}
    -- Counters for efficiently determining how many prereqs of a node have a given context
    -- To determine number that need that context, we'll just call a helper function for number of edges into a node
    local node_context_to_satisfied = state.node_context_to_satisfied or {}
    local open = state.open or {}
    local in_open = state.in_open or {}
    local node_to_open_inds = state.node_to_open_inds or {}
    -- A map of an ind to the previous ind of the node that added it
    local ind_to_ind = state.ind_to_ind or {}
    local ind = state.ind or 1

    -- Build all_contexts dict once for reuse
    local all_contexts = {}
    for context, _ in pairs(logic.contexts) do
        all_contexts[context] = true
    end

    local function add_contexts_to_node(node, contexts)
        -- incoming is used for seeing what the transmitted in context was in path
        local incoming = contexts
        if type(incoming) == "table" then
            incoming = table.deepcopy(incoming)
        end

        -- Check if contexts is overriden (forgetters output all contexts, adders output specific room)
        if logic.type_info[node.type].context == true then
            -- Forgetter: output all contexts (use explicit dict instead of true)
            contexts = table.deepcopy(all_contexts)
        elseif type(logic.type_info[node.type].context) == "string" then
            -- Adder: output specific room context
            contexts = {
                [node.name] = true
            }
        end

        if node.op == "AND" then
            -- We always go to open with AND nodes
            table.insert(open, {
                node = key(node),
                contexts = contexts,
                incoming = incoming,
            })
            ind_to_ind[#open] = ind
        elseif node.op == "OR" then
            local open_ind = in_open[key(node)]
            if open_ind ~= nil then
                -- Merge into existing open entry
                for context, _ in pairs(contexts) do
                    open[open_ind].contexts[context] = true
                end
            else
                table.insert(open, {
                    node = key(node),
                    contexts = contexts,
                    incoming = incoming,
                })
                in_open[key(node)] = #open
                ind_to_ind[#open] = ind
            end
        end
    end

    local function process_edge(dep, open_info, old_contexts)
        local edge = graph.edges[dep]
        local end_node_key = edge.stop
        local end_node = graph.nodes[end_node_key]

        -- node_to_contexts[end_node_key] already pre-allocated

        if end_node.op == "AND" then
            -- node_context_to_satisfied[end_node_key] already pre-allocated
            -- Increment satisfaction and check for newly satisfied in single pass
            local new_contexts = {}
            local satisfied = node_context_to_satisfied[end_node_key]
            local existing = node_to_contexts[end_node_key]
            local num_pre = end_node.num_pre

            for context, _ in pairs(open_info.contexts) do
                -- Increment satisfaction for NEW contexts only
                if not old_contexts[context] then
                    satisfied[context] = (satisfied[context] or 0) + 1
                end
                -- Check if now fully satisfied and not already in node
                if not existing[context] and satisfied[context] == num_pre then
                    new_contexts[context] = true
                end
            end

            if next(new_contexts) ~= nil then
                add_contexts_to_node(end_node, new_contexts)
            end
        elseif end_node.op == "OR" then
            local new_contexts = {}
            for context, _ in pairs(open_info.contexts) do
                if not node_to_contexts[end_node_key][context] then
                    new_contexts[context] = true
                end
            end
            if next(new_contexts) ~= nil then
                add_contexts_to_node(end_node, new_contexts)
            end
        else
            error("Node op not OR or AND")
        end
    end

    if new_conn == nil then
        -- Pre-allocate tables for all nodes (avoids repeated or {} checks in hot path)
        for node_key, node in pairs(graph.nodes) do
            node_to_contexts[node_key] = node_to_contexts[node_key] or {}
            if node.op == "AND" then
                node_context_to_satisfied[node_key] = node_context_to_satisfied[node_key] or {}
            end
        end

        -- Add sources with all contexts (share same table since sources don't modify it)
        local source_contexts = table.deepcopy(all_contexts)
        for source, _ in pairs(graph.sources) do
            table.insert(open, {
                node = source,
                contexts = source_contexts,
                incoming = source_contexts,
            })
            in_open[source] = #open
            ind_to_ind[#open] = 0
        end
    else
        -- Process new connection
        process_edge(new_conn.edge, {
            node = graph.edges[new_conn.edge].start,
            contexts = new_conn.contexts,
        }, {}) -- Last table shows old contexts was nothing (no connection)
    end

    while ind <= #open do
        local open_info = open[ind]
        local node = graph.nodes[open_info.node]
        -- Remove node from open so it doesn't get added to
        -- Only used for OR nodes now
        in_open[open_info.node] = nil
        node_to_open_inds[open_info.node] = node_to_open_inds[open_info.node] or {}
        node_to_open_inds[open_info.node][ind] = true

        -- Process edges BEFORE updating node_to_contexts (avoids deepcopy)
        -- process_edge checks against current node_to_contexts to find new contexts
        -- node_to_contexts[open_info.node] already pre-allocated
        for dep, _ in pairs(node.dep) do
            process_edge(dep, open_info, node_to_contexts[open_info.node])
        end

        -- Now add the new contexts
        for context, _ in pairs(open_info.contexts) do
            node_to_contexts[open_info.node][context] = true
        end

        ind = ind + 1
    end

    return {
        node_to_contexts = node_to_contexts,
        node_context_to_satisfied = node_context_to_satisfied,
        open = open,
        in_open = in_open,
        node_to_open_inds = node_to_open_inds,
        ind_to_ind = ind_to_ind,
        ind = ind,
    }
end

-- Also accounts for abilities defined in logic (these technically should be factored into contexts, but are kept separate for now while we're working on integration)
-- (EDITED) A contexts-type thing is now a map from binary strings to maps from rooms to true/false (combinations of abilities to where we have those combinations)
-- (EDITED) A room having combination 01 and 10 doesn't imply it has 11, but if it has 11 it automatically has 01 and 10, so we need special logic for whether one context is a subset of another now
-- (EDITED) Also, for efficiency, we might not always want to update contexts to fill out the lower elements, but it would probably be good to keep some sort of frontier for each
-- I take back what I said in the edited comments, I think contexts should be room --> frontier string --> true. We only ever add to the frontier, so this can be efficient.
-- union takes the union of two conexts, or returns nil if addon is a subset of base
-- No wait, let's just create cones when needed and use the whole set of strings; this is conceptually simpler and with ability set so small, optimization won't make much of a difference and may even hurt

-- Takes a set of binary strings and a set to add onto it and adds the resulting "cone" (all subsets) to the set (mutating for efficiency)
-- conify is a silly word for this but that's fun
-- Wait we might not need this
local function conify(old, new)
end

-- Calculate union of two contexts
-- Mutates base, so if needed deepcopy it beforehand
-- Returns false if no new contexts were added, otherwise returns new contexts
-- If we now have all contexts across all rooms, returns true (assigning base to now be true should be handled by caller; in this case it doesn't mutate)
local function union(base, addon)
    -- Calculate union for a specific room
    local function room_union(room_base, room_addon)
        -- For each string in addon, try adding it to base; it's that simple
        -- This works because unions of downward closed sets are downward closed

        -- If base is true (all contexts), then return false
        if room_base == true then
            return false
        end
        
        -- If addon already contains everything (coded by = true) then return true for efficiency (to be specially handled since we don't get new contexts exactly)
        if room_addon == true then
            return true
        end

        local room_added = {}
        for context, _ in pairs(room_addon) do
            if not room_base[context] then
                room_base[context] = true
                room_added[context] = true
            end
        end

        -- Check for no context added
        if next(room_added) == nil then
            return false
        else
            return room_added
        end
    end

    -- Calculate room_union for each room
    local added = {}
    local all_true = true
    -- TODO: Make logic.contexts more general; it's now just the rooms
    for room_context, _ in pairs(logic.contexts) do
        local room_added = room_union(base[room_context], room_addon[room_contex])

        if room_added == true then
            base[room_contex] = true
            added[room_contex] = true
        elseif room_added ~= false then
            -- base was already mutated
            added[room_context] = room_added
            all_true = false
        else
            all_true = false
        end
    end

    if next(added) == nil then
        return false
    end

    -- With all contexts across all rooms, return true for efficiency
    if all_true == true then
        return true
    end

    -- Otherwise, return the added boundary
    return added
end

top.sort_extended = function(graph, state, new_conn, extra)
    -- TODO

    state = state or {}
    local node_to_contexts = state.node_to_contexts or {}
    local node_context_to_satisfied = state.node_context_to_satisfied or {}
    local open = state.open or {}
    local in_open = state.in_open or {}
    local node_to_open_inds = state.node_to_open_inds or {}
    local ind_to_ind = state.ind_to_ind or {}
    local ind = state.ind or 1

    -- Build all_contexts dict once for reuse
    local all_contexts = {}
    for context, _ in pairs(logic.contexts) do
        all_contexts[context] = true
    end

    -- Push onto open to add the added contexts to node
    -- We can assume added ~= false
    local function add_contexts_to_node(node, added)
        -- incoming is used for seeing what the transmitted in context was in path
        local incoming = added
        if type(incoming) == "table" then
            incoming = table.deepcopy(added)
        end

        -- Check if contexts is overriden (forgetters output all contexts, adders output specific room)
        local contexts = added
        if logic.type_info[node.type].context == true then
            -- Forgetter: output all contexts (use explicit dict instead of true)
            contexts = table.deepcopy(all_contexts)
        elseif type(logic.type_info[node.type].context) == "string" then
            -- Adder: output specific room context
            contexts = {
                [node.name] = true
            }
        end

        if node.op == "AND" then
            -- We always go to open with AND nodes
            table.insert(open, {
                node = key(node),
                contexts = contexts,
                incoming = incoming,
            })
            ind_to_ind[#open] = ind
        elseif node.op == "OR" then
            local open_ind = in_open[key(node)]
            if open_ind ~= nil then
                -- Merge into existing open entry
                for context, _ in pairs(contexts) do
                    open[open_ind].contexts[context] = true
                end
            else
                table.insert(open, {
                    node = key(node),
                    contexts = contexts,
                    incoming = incoming,
                })
                in_open[key(node)] = #open
                ind_to_ind[#open] = ind
            end
        end
    end

    local function process_edge(dep, open_info, old_contexts)
        local edge = graph.edges[dep]
        local end_node_key = edge.stop
        local end_node = graph.nodes[end_node_key]

        -- node_to_contexts[end_node_key] already pre-allocated

        if end_node.op == "AND" then
            -- node_context_to_satisfied[end_node_key] already pre-allocated
            -- Increment satisfaction and check for newly satisfied in single pass
            local new_contexts = {}
            local satisfied = node_context_to_satisfied[end_node_key]
            local existing = node_to_contexts[end_node_key]
            local num_pre = end_node.num_pre

            for context, _ in pairs(open_info.contexts) do
                -- Increment satisfaction for NEW contexts only
                if not old_contexts[context] then
                    satisfied[context] = (satisfied[context] or 0) + 1
                end
                -- Check if now fully satisfied and not already in node
                if not existing[context] and satisfied[context] == num_pre then
                    new_contexts[context] = true
                end
            end

            if next(new_contexts) ~= nil then
                add_contexts_to_node(end_node, new_contexts)
            end
        elseif end_node.op == "OR" then
            local new_contexts = {}
            for context, _ in pairs(open_info.contexts) do
                if not node_to_contexts[end_node_key][context] then
                    new_contexts[context] = true
                end
            end
            if next(new_contexts) ~= nil then
                add_contexts_to_node(end_node, new_contexts)
            end
        else
            error("Node op not OR or AND")
        end
    end

    if new_conn == nil then
        -- Pre-allocate tables for all nodes (avoids repeated or {} checks in hot path)
        for node_key, node in pairs(graph.nodes) do
            node_to_contexts[node_key] = node_to_contexts[node_key] or {}
            if node.op == "AND" then
                node_context_to_satisfied[node_key] = node_context_to_satisfied[node_key] or {}
            end
        end

        -- Add sources with all contexts (share same table since sources don't modify it)
        local source_contexts = table.deepcopy(all_contexts)
        for source, _ in pairs(graph.sources) do
            table.insert(open, {
                node = source,
                contexts = source_contexts,
                incoming = source_contexts,
            })
            in_open[source] = #open
            ind_to_ind[#open] = 0
        end
    else
        -- Process new connection
        process_edge(new_conn.edge, {
            node = graph.edges[new_conn.edge].start,
            contexts = new_conn.contexts,
        }, {}) -- Last table shows old contexts was nothing (no connection)
    end

    while ind <= #open do
        local open_info = open[ind]
        local node = graph.nodes[open_info.node]
        -- Remove node from open so it doesn't get added to
        -- Only used for OR nodes now
        in_open[open_info.node] = nil
        node_to_open_inds[open_info.node] = node_to_open_inds[open_info.node] or {}
        node_to_open_inds[open_info.node][ind] = true

        -- Process edges BEFORE updating node_to_contexts (avoids deepcopy)
        -- process_edge checks against current node_to_contexts to find new contexts
        -- node_to_contexts[open_info.node] already pre-allocated
        for dep, _ in pairs(node.dep) do
            process_edge(dep, open_info, node_to_contexts[open_info.node])
        end

        -- Now add the new contexts
        for context, _ in pairs(open_info.contexts) do
            node_to_contexts[open_info.node][context] = true
        end

        ind = ind + 1
    end

    return {
        node_to_contexts = node_to_contexts,
        node_context_to_satisfied = node_context_to_satisfied,
        open = open,
        in_open = in_open,
        node_to_open_inds = node_to_open_inds,
        ind_to_ind = ind_to_ind,
        ind = ind,
    }
end

-- Helper to find earliest open index with matching context
local find_first_occurrence_with_context = function(node_key, context, node_to_open_inds, open)
    local first
    for open_ind, _ in pairs(node_to_open_inds[node_key] or {}) do
        local ctxs = open[open_ind].contexts
        if ctxs == true or ctxs[context] then
            if first == nil or open_ind < first then
                first = open_ind
            end
        end
    end
    return first
end

top.path = function(graph, goal, sort)
    local contexts_in_order = {
        key({type = "planet", name = "nauvis"}),
        key({type = "surface", name = "space-platform"}),
        key({type = "planet", name = "vulcanus"}),
        key({type = "planet", name = "fulgora"}),
        key({type = "planet", name = "gleba"}),
        key({type = "planet", name = "aquilo"}),
    }

    local open = sort.open
    local node_to_open_inds = sort.node_to_open_inds

    -- Path is a collection of inds from open, paired with contexts we are wanting from them
    -- goal itself is an ind with a context
    -- Note that path works backwards
    local path = {goal}
    -- ind + context to whether it's in the path yet (note that we need both)
    local in_path = {}
    for context, _ in pairs(logic.contexts) do
        in_path[context] = {}
    end

    local ind = 1
    while ind <= #path do
        local curr_goal = path[ind]

        local curr_open = open[curr_goal.ind]
        local goal_context = curr_goal.context
        local curr_node = graph.nodes[curr_open.node]
        -- Try to get this context as early as possible
        -- If this is a context emitter, then choose earliest possible context
        local earlier_emitter = false
        if logic.type_info[curr_node.type].context ~= nil then
            local earliest_ind
            for open_ind, _ in pairs(node_to_open_inds[curr_open.node]) do
                if earliest_ind == nil or open_ind < earliest_ind then
                    earliest_ind = open_ind
                end
            end
            -- Decide new goal context based off earliest available context in order
            for _, available_context in pairs(contexts_in_order) do
                if curr_open.incoming == true or curr_open.incoming[available_context] then
                    goal_context = available_context
                    break
                end
            end
            -- If we got an earlier node, push it and continue
            if earliest_ind < curr_goal.ind then
                earlier_emitter = true
                if not in_path[goal_context][earliest_ind] then
                    table.insert(path, {
                        ind = earliest_ind,
                        context = goal_context,
                    })
                    in_path[goal_context][earliest_ind] = true
                end
            end
        end
        if not earlier_emitter then
            if curr_node.op == "AND" then
                -- Add each of the prereq node's contexts
                for pre, _ in pairs(curr_node.pre) do
                    local prenode = graph.nodes[graph.edges[pre].start]
                    local first_occurrence = find_first_occurrence_with_context(
                        key(prenode), goal_context, node_to_open_inds, open)
                    if first_occurrence and not in_path[goal_context][first_occurrence] then
                        table.insert(path, {
                            ind = first_occurrence,
                            context = goal_context,
                        })
                        in_path[goal_context][first_occurrence] = true
                    end
                end
            elseif curr_node.op == "OR" then
                -- Find earliest prereq with this context
                local first_occurrence
                for pre, _ in pairs(curr_node.pre) do
                    local prenode = graph.nodes[graph.edges[pre].start]
                    local occ = find_first_occurrence_with_context(
                        key(prenode), goal_context, node_to_open_inds, open)
                    if occ and (first_occurrence == nil or occ < first_occurrence) then
                        first_occurrence = occ
                    end
                end
                if first_occurrence == nil then
                    log("Warning: no prereq with context " .. tostring(goal_context) .. " for OR node")
                    log(serpent.block(curr_node))
                elseif not in_path[goal_context][first_occurrence] then
                    table.insert(path, {
                        ind = first_occurrence,
                        context = goal_context,
                    })
                    in_path[goal_context][first_occurrence] = true
                end
            end
        end

        ind = ind + 1
    end

    return path
end

return top