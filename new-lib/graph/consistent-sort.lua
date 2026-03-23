-- Tries to make consistent judgements about what should come before what with regards to context
-- For example, if piercing ammo comes before plastic on nauvis, it tries to do the same on the other planets
-- This is done by scanning through the open list at each step for the "already-added" thing that comes earliest, if such a thing exists, and adding *that* to sorted
-- This is inefficient (could probably be sped up), but luckily should only be needed to be done once
-- The code below is also an attempt at succinctness with the top sort code rather than potentially over-optimizing
-- I made new terminology here: a *pebble* is a node_key/context_name pair (as a parallel to pebbling games in theoretical computer science)

-- NOTE: I may want to actually give undiscovered things priority if it would result in things being in a "more consistent" order, or something along those lines, I'll have to see how this comes out
-- NOTE: I'm removing the "true/all optimization" since I don't think it actually does mucb

local contutils = require("new-lib/graph/context-utils")
local gutils = require("new-lib/graph/graph-utils")
-- Used for contexts and such; actual logic dependency graph is passed in
local logic = require("new-lib/logic/init")

-- Shortcuts
local key = gutils.key

local top = {}

top.sort = function(graph, state, new_conn, extra)
    -- state should be passed in if and only if we're doing a cached sort with a new_conn
    if (state ~= nil and new_conn == nil) or (state == nil and new_conn ~= nil) then
        error("Ambiguous signals for whether this is a cached sort!")
    end

    -- Initialize state vars
    state = state or {}
    -- node_to_context_inds goes node_key --> { context --> index | nil }, where index is when the node_key/context combo was added in sorted, nil if nonexistent
    -- Represents the OUTGOING contexts
    -- To check incoming, check node_to_context_inds on the prerequisite nodes
    -- This is updated when processed from open (not when added to it)
    local node_to_context_inds = state.node_to_context_inds or {}
    -- Before, open and sorted were conflated; here, we'll be needing to separate those concepts
    local sorted = state.sorted or {}
    -- This is now just a *table* of node_key --> nil or { context --> false/true }, rather than all pebbles
    local open = state.open or {}
    -- ind is no longer needed since we already separate open and sorted
    extra = extra or {}

    -- Initialize node_to_context_inds on *all* nodes, etc.
    -- Only do this on new sorts
    -- We'll actually populate initial "open" list later
    if new_conn == nil then
        for node_key, _ in pairs(graph.nodes) do
            node_to_context_inds[node_key] = {}
        end
    end

    local function add_to_open(node, context)
        local node_key = key(node)
        open[node_key] = open[node_key] or {}
        open[node_key][context] = true
    end

    -- Checks if this depnode *newly* has context
    local function process_depnode(depnode, incoming)
        local depnode_key = key(depnode)

        local check
        if depnode.op == "OR" then
            -- OR is false until proven true
            check = false
        elseif depnode.op == "AND" then
            -- AND is true until proven false
            check = true
        else
            error("Invalid node op: " .. tostring(depnode.op))
        end
        for _, prenode in pairs(gutils.prenodes(graph, depnode)) do
            local prenode_key = key(prenode)
            if (node_to_context_inds[prenode_key][incoming] ~= nil) == (not check) then
                check = not check
                break
            end
        end

        if check then
            local outgoing_contexts = contutils.transmit(depnode, incoming)
            for _, outgoing in pairs(outgoing_contexts) do
                -- If the depnode is already transmitting this context, return
                if node_to_context_inds[depnode_key][outgoing] ~= nil then
                    return
                end

                add_to_open(depnode, outgoing)
            end
        end
    end

    -- Now we can add starting nodes in open
    if new_conn == nil then
        for _, node in pairs(gutils.sources(graph)) do
            for context, _ in pairs(logic.contexts) do
                add_to_open(node, context)
            end
        end
    else
        -- Otherwise, add the dependent of the new_conn to open with the prereq's contexts
        for context, _ in pairs(node_to_context_inds[key(new_conn[1])]) do
            add_to_open(new_conn[2], context)
        end
    end

    -- Repeat until open is empty
    while next(open) ~= nil do
        -- Find the next candidate to remove from open
        -- This is the node, if any, with lowest value in the node_to_context_inds table
        local node_key
        if extra.choose_randomly then
            local open_keys = {}
            for open_key, _ in pairs(open) do
                table.insert(open_keys, open_key)
            end
            -- Since this is mainly just for testing and rng for graph randomization doesn't matter as much anyways, just use built in math.random
            node_key = open_keys[math.random(#open_keys)]
        else
            local curr_priority
            for candidate_node_key, contexts in pairs(open) do
                local node_priority
                for _, ind in pairs(node_to_context_inds[candidate_node_key]) do
                    if node_priority == nil or ind < node_priority then
                        node_priority = ind
                    end
                end
                if curr_priority == nil or (node_priority ~= nil and node_priority < curr_priority) then
                    node_key = candidate_node_key
                    curr_priority = node_priority
                end
            end
        end

        local contexts = open[node_key]
        open[node_key] = nil
        -- Transmit contexts to each dependent
        local node = graph.nodes[node_key]
        for context, _ in pairs(contexts) do
            -- Add this node-context pebble to sorted
            table.insert(sorted, {
                node_key = node_key,
                context = context
            })
            -- Add the context
            node_to_context_inds[node_key][context] = #sorted

            for _, depnode in pairs(gutils.depnodes(graph, node)) do
                process_depnode(depnode, context)
            end
        end
    end

    return {
        node_to_context_inds = node_to_context_inds,
        sorted = sorted,
        open = open,
    }
end

-- This is taken mainly from top-sort.lua
-- Creates a path of inds within sort_info.sorted starting from the goal and going backwards for how to get there
-- goal_inds is a list of inds in sort_info.sorted of the pebbles we are hoping to achieve
top.path = function(graph, goal_inds, sort_info)
    local sorted = sort_info.sorted
    local node_to_context_inds = sort_info.node_to_context_inds

    local path = goal_inds
    -- Whether an index is in the path yet
    local in_path = {}
    for _, ind in pairs(path) do
        in_path[ind] = true
    end

    local path_ind = 1
    while path_ind <= #path do
        local curr_ind = path[path_ind]
        local curr_pebble = sorted[curr_ind]
        local curr_context = curr_pebble.context
        local curr_node = graph.nodes[curr_pebble.node_key]

        local function find_preinds(node, context)
            local function log_error()
                log(serpent.block(curr_pebble))
                log(serpent.block(node))
                log(context)
                error()
            end
            
            local preinds = {}
            
            if node.op == "OR" then
                -- Just try earliest prereq (could be suboptimal, but this is a good heuristic)
                -- Start at curr_ind to more easily do error checking on indeed getting an earlier pebble
                local first_occurrence_ind = curr_ind
                for _, prenode in pairs(gutils.prenodes(graph, node)) do
                    -- Need to check that context is non-nil since OR nodes can depend on later things/with different contexts
                    if node_to_context_inds[key(prenode)][context] ~= nil and node_to_context_inds[key(prenode)][context] < first_occurrence_ind then
                        first_occurrence_ind = node_to_context_inds[key(prenode)][context]
                    end
                end
                -- Make sure we found something/didn't loop
                if first_occurrence_ind == curr_ind then
                    return false
                    --log_error()
                end
                table.insert(preinds, first_occurrence_ind)
            elseif node.op == "AND" then
                -- Add all previous pebbles to the path
                for _, prenode in pairs(gutils.prenodes(graph, node)) do
                    local prev_ind = node_to_context_inds[key(prenode)][context]
                    -- If this is nil, then not satisfiable, so abandon this context
                    if prev_ind == nil then
                        return false
                    end
                    if prev_ind >= curr_ind then
                        -- This can happen in a valid manner, it just means this is an invalid context
                        --log_error()
                    end
                    table.insert(preinds, prev_ind)
                end
            end

            return preinds
        end

        if logic.type_info[curr_node.type].context ~= nil then
            -- In this case, we assume just the forgetting contexts for now (true or string type)
            -- We then lost the context info, so we just choose the earliest context that appears earlier in the sort
            -- We'll choose that context and then do the rest with that
            local earliest_context_ind = curr_ind
            for context, _ in pairs(logic.contexts) do
                local preinds = find_preinds(curr_node, context)
                if preinds ~= false then
                    local latest_ind
                    for _, ind in pairs(preinds) do
                        if latest_ind == nil or ind > latest_ind then
                            latest_ind = ind
                        end
                    end
                    if latest_ind == nil then
                        if curr_node.op == "OR" then
                            -- This means no prereqs and it's an OR, so shouldn't have been found in the first place
                            --log(serpent.block(curr_pebble))
                            --error("Unreachable pebble.")
                            -- Oh that's fine we just ignore the context
                        else
                            -- In this case, we're satisfiable immediately anyways due to having no prereqs, and the exact context doesn't matter
                            -- Give earliest_context_ind a 0 so that later sanity checks don't complain
                            earliest_context_ind = 0
                            curr_context = context
                            break
                        end
                    else
                        if latest_ind < earliest_context_ind then
                            earliest_context_ind = latest_ind
                            curr_context = context
                        end
                    end
                end
            end
            -- If nothing was earlier, that's a contradiction
            if earliest_context_ind == curr_ind then
                log(serpent.block(curr_node))
                error("No earlier contexts possible.")
            end
        end

        -- Now, either way, we go from curr_context
        local preinds = find_preinds(curr_node, curr_context)
        -- preinds should always be valid by here
        if preinds == false then
            log(serpent.block(curr_pebble))
            error()
        end
        for _, ind in pairs(preinds) do
            if not in_path[ind] then
                in_path[ind] = true
                table.insert(path, ind)
            end
        end

        path_ind = path_ind + 1
    end

    return {
        path = path,
        in_path = in_path,
    }
end

-- Trims unnecessary contexts out of state's sorted list, starting from the back
-- Might not be necessary with top.path now
top.trim = function(graph, state)
    -- TODO
end

return top