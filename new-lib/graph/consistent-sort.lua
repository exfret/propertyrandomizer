-- Tries to make consistent judgements about what should come before what with regards to context
-- For example, if piercing ammo comes before plastic on nauvis, it tries to do the same on the other planets
-- This is done by scanning through the open list at each step for the "already-added" thing that comes earliest, if such a thing exists, and adding *that* to sorted
-- This is inefficient (could probably be sped up), but luckily should only be needed to be done once
-- The code below is also an attempt at succinctness with the top sort code rather than potentially over-optimizing

-- CRITICAL TODO: Write tests!

-- NOTE: I may want to actually give undiscovered things priority if it would result in things being in a "more consistent" order, or something along those lines, I'll have to see how this comes out
-- NOTE: I'm removing the "true/all optimization" since I don't think it actually does mucb

local gutils = require("new-lib/graph/graph-utils")
-- Used for logic and such; actual logic dependency graph is passed in
local logic = require("new-lib/logic/init")

-- Shortcuts
local key = gutils.key

local top = {}

top.sort = function(graph, state, new_conn)
    -- state should be passed in if and only if we're doing a cached sort with a new_conn
    if (state ~= nil and new_conn == nil) or (state == nil and new_conn ~= nil) then
        error("Ambiguous signals for whether this is a cached sort!")
    end

    -- Initialize state vars
    state = state or {}
    -- node_to_contexts goes node_key --> { context_name --> true/false }
    -- Represents the OUTGOING contexts
    -- To check incoming, check node_to_contexts on the prerequisite nodes
    local node_to_contexts = state.node_to_contexts or {}
    -- Before, open and sorted were conflated; here, we'll be needing to separate those concepts
    local sorted = state.sorted or {}
    -- This is now just a *table* of node_key --> contexts, rather than all pebbles (my new name for node-context pairs)
    local open = state.open or {}
    -- This is needed for the short-path algorithm; sends a node to all indices in the sorted list where it appears
    -- It's also needed for trying to keep to earlier sort patterns' the sorted inds tables must be in ascending order
    local node_to_sorted_inds = state.node_to_sorted_inds or {}
    -- ind is no longer needed since we already separate open and sorted

    -- Initialize node_to_contexts on *all* nodes, etc.
    -- Only do this on new sorts
    -- We'll actually populate initial "open" list later
    if new_conn == nil then
        local blank_context = {}
        for room, _ in pairs(logic.contexts) do
            blank_context[room] = false
        end
        for node_key, _ in pairs(graph.nodes) do
            node_to_contexts[node_key] = table.deepcopy(blank_context)
            node_to_sorted_inds[node_key] = {}
        end
    end

    local function add_to_open(node, context)
        if node.op ~= "OR" and node.op ~= "AND" then
            error("Invalid node op: " .. tostring(node.op))
        end

        local node_key = key(node)
        open[node_key] = open[node_key] or {}
        open[node_key][context] = true
    end

    -- Now we can add starting nodes in open
    if new_conn == nil then
        local all_context = {}
        for room, _ in pairs(logic.contexts) do
            all_context[room] = true
        end
        for _, node in pairs(gutils.sources(graph)) do
            node_to_contexts[key(node)] = table.deepcopy(all_context)
            for room, _ in pairs(logic.contexts) do
                add_to_open(node, room)
            end
        end
    end

    -- Checks if this depnode *newly* has context
    local function process_depnode(depnode, context)
        local depnode_key = key(depnode)

        -- If it's already transmitting this context, return
        if node_to_contexts[depnode_key][context] then
            return
        end

        local check
        if depnode.op ~= "OR" and depnode.op ~= "AND" then
            error("Invalid node op: " .. tostring(node.op))
        end
        if depnode.op == "OR" then
            -- OR is false until proven true
            check = false
        elseif depnode.op == "AND" then
            -- AND is true until proven false
            check = true
        end
        for _, prenode in pairs(gutils.prenodes(graph, depnode)) do
            local prenode_key = key(prenode)
            if node_to_contexts[prenode_key][context] == (not check) then
                check = not check
                break
            end
        end
        if check then
            add_to_open(depnode, context)
        end
    end

    -- Repeat until open is empty
    while next(open) ~= nil do
        -- Find the next candidate to remove from open
        -- This is the one that is in node_to_sorted_inds and also has the earliest index
        local node_key
        local curr_priority
        for candidate_node_key, contexts in pairs(open) do
            local node_priority = node_to_sorted_inds[candidate_node_key][1]
            if curr_priority == nil or (node_priority ~= nil and node_priority < curr_priority) then
                node_key = candidate_node_key
                curr_priority = node_priority
            end
        end

        local contexts = open[node_key]
        -- Add contexts to node_to_contexts
        for context, _ in pairs(contexts) do
            node_to_contexts[node_key][context] = true
        end
        open[node_key] = nil
        -- Transmit contexts to each dependent
        local node = graph.nodes[node_key]
        for context, _ in pairs(contexts) do
            -- Add this node-context pebble to sorted
            table.insert(sorted, {
                node = node_key,
                context = context
            })
            -- Keep track of this new ind in sorted that this node is at
            table.insert(node_to_sorted_inds[node_key], #sorted)

            for _, depnode in pairs(gutils.depnodes(graph, node)) do
                process_depnode(depnode, context)
            end
        end
    end

    return {
        node_to_contexts = node_to_contexts,
        sorted = sorted,
        open = open,
        node_to_sorted_inds = node_to_sorted_inds,
    }
end

return top