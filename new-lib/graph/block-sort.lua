-- Block-aware topological sort
-- Prioritizes completing blocks together: when a node becomes reachable,
-- other nodes in the same block get priority in the traversal order.
--
-- This helps ensure that related game mechanics (like steam power components)
-- unlock together during randomization.

local lib_name = "new-lib"
local gutils = require(lib_name .. "/graph/graph-utils")
local logic = require(lib_name .. "/logic/logic")

local key = gutils.key

local block_sort = {}

-- Simple topological sort that tries to complete blocks together
-- graph: the logic graph with nodes and edges
-- blocks: blockify results with group_node_set and node_to_group
-- Returns: { sorted = {...}, node_to_ind = {...} }
block_sort.sort = function(graph, blocks)
    local node_to_group = blocks.node_to_group
    local group_node_set = blocks.group_node_set

    -- Track prereq satisfaction for each node
    -- For AND: count of satisfied prereqs
    -- For OR: whether any prereq is satisfied
    local node_satisfied = {}
    local node_reachable = {}

    -- Initialize satisfaction tracking
    for node_key, node in pairs(graph.nodes) do
        if node.op == "AND" then
            node_satisfied[node_key] = 0
        else
            node_satisfied[node_key] = false
        end
        node_reachable[node_key] = false
    end

    -- Track which blocks have started (have at least one reachable node)
    local block_started = {}

    -- Two queues: priority (for nodes in started blocks) and regular
    local priority_queue = {}
    local regular_queue = {}
    local in_queue = {}  -- node_key -> true if in any queue

    -- Result
    local sorted = {}
    local node_to_ind = {}

    -- Helper: check if node is now reachable
    local function is_reachable(node_key)
        local node = graph.nodes[node_key]
        if node.op == "AND" then
            return node_satisfied[node_key] == node.num_pre
        else  -- OR
            return node_satisfied[node_key] == true
        end
    end

    -- Helper: add node to appropriate queue
    local function enqueue(node_key)
        if in_queue[node_key] then return end
        in_queue[node_key] = true

        local group = node_to_group[node_key]
        if group and block_started[group] then
            table.insert(priority_queue, node_key)
        else
            table.insert(regular_queue, node_key)
        end
    end

    -- Helper: mark a node as reachable and process its block
    local function mark_reachable(node_key)
        if node_reachable[node_key] then return end
        node_reachable[node_key] = true

        -- Mark block as started
        local group = node_to_group[node_key]
        if group and not block_started[group] then
            block_started[group] = true

            -- Move any queued nodes from this block to priority queue
            local new_regular = {}
            for _, queued_key in ipairs(regular_queue) do
                if node_to_group[queued_key] == group then
                    table.insert(priority_queue, queued_key)
                else
                    table.insert(new_regular, queued_key)
                end
            end
            regular_queue = new_regular
        end
    end

    -- Add source nodes (AND nodes with no prereqs)
    for source_key, _ in pairs(graph.sources or {}) do
        enqueue(source_key)
    end

    -- Also find any nodes with 0 prereqs that might not be in sources
    for node_key, node in pairs(graph.nodes) do
        if node.num_pre == 0 then
            enqueue(node_key)
        end
    end

    -- Main loop
    while #priority_queue > 0 or #regular_queue > 0 do
        -- Take from priority queue first
        local curr_key
        if #priority_queue > 0 then
            curr_key = table.remove(priority_queue, 1)
        else
            curr_key = table.remove(regular_queue, 1)
        end

        local curr_node = graph.nodes[curr_key]
        if curr_node == nil then
            -- Node was in queue but doesn't exist (shouldn't happen)
            goto continue
        end

        -- Check if actually reachable now
        if not is_reachable(curr_key) then
            -- Not yet reachable, skip (will be re-added when prereqs satisfied)
            in_queue[curr_key] = false
            goto continue
        end

        -- Mark as reachable and add to sorted
        mark_reachable(curr_key)
        table.insert(sorted, curr_key)
        node_to_ind[curr_key] = #sorted

        -- Update dependents
        for edge_key, _ in pairs(curr_node.dep) do
            local edge = graph.edges[edge_key]
            local dep_key = edge.stop
            local dep_node = graph.nodes[dep_key]

            if dep_node and not node_reachable[dep_key] then
                if dep_node.op == "AND" then
                    node_satisfied[dep_key] = node_satisfied[dep_key] + 1
                else  -- OR
                    node_satisfied[dep_key] = true
                end

                -- If now reachable, add to queue
                if is_reachable(dep_key) then
                    enqueue(dep_key)
                end
            end
        end

        ::continue::
    end

    return {
        sorted = sorted,
        node_to_ind = node_to_ind,
        reachable = node_reachable,
    }
end

-- Version with context tracking (combines block priority with context propagation)
-- This is more complex but handles multi-surface games properly
block_sort.sort_with_contexts = function(graph, blocks)
    local node_to_group = blocks.node_to_group
    local group_node_set = blocks.group_node_set

    -- Track contexts per node (like the original top-sort)
    -- node_key -> true (all contexts) or {context -> true} or nil (no contexts)
    local node_to_contexts = {}

    -- For AND nodes: track how many prereqs have each context
    -- node_key -> { context -> count, "all" -> count_with_all_contexts }
    local node_context_counts = {}

    -- Track which blocks have started
    local block_started = {}

    -- Two queues with context info
    local priority_queue = {}  -- {node_key, contexts}
    local regular_queue = {}
    local in_queue = {}  -- node_key -> true

    -- Result
    local sorted = {}
    local node_to_ind = {}

    -- Initialize
    for node_key, node in pairs(graph.nodes) do
        node_context_counts[node_key] = {}
    end

    -- Helper: get effective contexts after applying node type's context behavior
    local function apply_context_behavior(node, incoming_contexts)
        local type_info = logic.type_info[node.type]
        if type_info == nil then
            return incoming_contexts
        end

        local context_behavior = type_info.context
        if context_behavior == true then
            -- FORGET: emit all contexts
            return true
        elseif type(context_behavior) == "string" then
            -- ADD: emit specific context (room nodes)
            return { [node.name] = true }
        else
            -- TRANSMIT: pass through contexts
            return incoming_contexts
        end
    end

    -- Helper: merge contexts
    local function merge_contexts(existing, new)
        if existing == true or new == true then
            return true
        end
        if existing == nil then
            if type(new) == "table" then
                return table.deepcopy(new)
            end
            return new
        end
        if new == nil then
            return existing
        end
        for ctx, _ in pairs(new) do
            existing[ctx] = true
        end
        return existing
    end

    -- Helper: check if node has any contexts
    local function has_contexts(node_key)
        local ctx = node_to_contexts[node_key]
        if ctx == true then return true end
        if ctx == nil then return false end
        return next(ctx) ~= nil
    end

    -- Helper: add to queue with block priority
    local function enqueue(node_key, contexts)
        -- Skip if node already has all contexts (fully processed)
        if node_to_contexts[node_key] == true then
            return
        end

        -- Don't add duplicates, but do merge contexts
        if in_queue[node_key] then
            -- Find and update contexts in whichever queue it's in
            for _, entry in ipairs(priority_queue) do
                if entry.node == node_key then
                    entry.contexts = merge_contexts(entry.contexts, contexts)
                    return
                end
            end
            for _, entry in ipairs(regular_queue) do
                if entry.node == node_key then
                    entry.contexts = merge_contexts(entry.contexts, contexts)
                    return
                end
            end
            return
        end

        in_queue[node_key] = true
        local entry = { node = node_key, contexts = contexts }

        local group = node_to_group[node_key]
        if group and block_started[group] then
            table.insert(priority_queue, entry)
        else
            table.insert(regular_queue, entry)
        end
    end

    -- Helper: mark block as started and reprioritize
    local function start_block(group)
        if block_started[group] then return end
        block_started[group] = true

        -- Move nodes from this block to priority queue
        local new_regular = {}
        for _, entry in ipairs(regular_queue) do
            if node_to_group[entry.node] == group then
                table.insert(priority_queue, entry)
            else
                table.insert(new_regular, entry)
            end
        end
        regular_queue = new_regular
    end

    -- Add source nodes
    for source_key, _ in pairs(graph.sources or {}) do
        enqueue(source_key, true)
    end

    -- Main loop
    while #priority_queue > 0 or #regular_queue > 0 do
        local entry
        if #priority_queue > 0 then
            entry = table.remove(priority_queue, 1)
        else
            entry = table.remove(regular_queue, 1)
        end

        local curr_key = entry.node
        local incoming_contexts = entry.contexts
        in_queue[curr_key] = false

        local curr_node = graph.nodes[curr_key]
        if curr_node == nil then
            goto continue
        end

        -- Apply context behavior
        local outgoing_contexts = apply_context_behavior(curr_node, incoming_contexts)

        -- Update node's contexts
        local old_contexts = node_to_contexts[curr_key]
        node_to_contexts[curr_key] = merge_contexts(node_to_contexts[curr_key], outgoing_contexts)

        -- Optimization: if we now have all contexts, set to true for faster future checks
        if node_to_contexts[curr_key] ~= true and type(node_to_contexts[curr_key]) == "table" then
            local has_all = true
            for ctx, _ in pairs(logic.contexts) do
                if not node_to_contexts[curr_key][ctx] then
                    has_all = false
                    break
                end
            end
            if has_all then
                node_to_contexts[curr_key] = true
            end
        end

        -- If this is the first time we have contexts, mark block started
        if old_contexts == nil and has_contexts(curr_key) then
            local group = node_to_group[curr_key]
            if group then
                start_block(group)
            end

            -- Add to sorted order
            table.insert(sorted, curr_key)
            node_to_ind[curr_key] = #sorted
        end

        -- Skip if no new contexts to propagate
        if old_contexts == true then
            goto continue
        end

        -- Also skip if outgoing contexts are subset of what we already had
        -- (Use outgoing_contexts, not incoming, to account for ADD/FORGET transformations)
        if old_contexts ~= nil and outgoing_contexts ~= true and type(outgoing_contexts) == "table" then
            local has_new = false
            for ctx, _ in pairs(outgoing_contexts) do
                if not old_contexts[ctx] then
                    has_new = true
                    break
                end
            end
            if not has_new then
                goto continue
            end
        end

        -- Propagate to dependents
        for edge_key, _ in pairs(curr_node.dep) do
            local edge = graph.edges[edge_key]
            local dep_key = edge.stop
            local dep_node = graph.nodes[dep_key]

            if dep_node == nil then goto next_dep end

            if dep_node.op == "OR" then
                -- OR: any incoming context is passed through
                if outgoing_contexts == true or (type(outgoing_contexts) == "table" and next(outgoing_contexts)) then
                    enqueue(dep_key, outgoing_contexts)
                end
            else  -- AND
                -- AND: need all prereqs to have a context before we can emit it
                local counts = node_context_counts[dep_key]

                -- Only count NEW contexts from this prereq to avoid double-counting
                -- If prereq now has all contexts, transition from individual to "all"
                if node_to_contexts[curr_key] == true then
                    -- Current node now has all contexts
                    if old_contexts == nil then
                        -- First time: just increment "all"
                        counts["all"] = (counts["all"] or 0) + 1
                    elseif old_contexts ~= true then
                        -- Transitioning from individual contexts to all:
                        -- increment "all" and decrement old individual counts
                        counts["all"] = (counts["all"] or 0) + 1
                        for old_ctx, _ in pairs(old_contexts) do
                            counts[old_ctx] = (counts[old_ctx] or 0) - 1
                        end
                    end
                    -- If old_contexts == true, we already counted this prereq as "all"
                elseif type(outgoing_contexts) == "table" then
                    -- Only add contexts that are new (not in old_contexts)
                    for ctx, _ in pairs(outgoing_contexts) do
                        if old_contexts == nil or not old_contexts[ctx] then
                            counts[ctx] = (counts[ctx] or 0) + 1
                        end
                    end
                end

                -- Check if any context is now satisfied (has all prereqs)
                local satisfied_contexts = {}
                local all_satisfied = false

                if (counts["all"] or 0) >= dep_node.num_pre then
                    all_satisfied = true
                else
                    for ctx, _ in pairs(logic.contexts) do
                        local total = (counts[ctx] or 0) + (counts["all"] or 0)
                        if total >= dep_node.num_pre then
                            satisfied_contexts[ctx] = true
                        end
                    end
                end

                if all_satisfied then
                    enqueue(dep_key, true)
                elseif next(satisfied_contexts) then
                    enqueue(dep_key, satisfied_contexts)
                end
            end

            ::next_dep::
        end

        ::continue::
    end

    return {
        sorted = sorted,
        node_to_ind = node_to_ind,
        node_to_contexts = node_to_contexts,
    }
end

return block_sort
