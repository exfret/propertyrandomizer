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
top.sort = function(graph)
    -- node_to_contexts goes node_key --> { context_name --> true/false }
    -- There is also special case of node_key --> false (no contexts/unreachable) and node_key --> true (all contexts) for performance
    local node_to_contexts = {}
    local edge_to_contexts = {}
    -- Counters for efficiently determining how many prereqs of a node have a given context
    -- To determine number that need that context, we'll just call a helper function for number of edges into a node
    local node_context_to_satisfied = {}
    for node_key, _ in pairs(graph.nodes) do
        node_to_contexts[node_key] = false
        node_context_to_satisfied[node_key] = {}
        for context, _ in pairs(logic.contexts) do
            node_context_to_satisfied[node_key][context] = 0
        end
    end
    for edge_key, _ in pairs(graph.edges) do
        edge_to_contexts[edge_key] = false
    end

    local open = {}
    -- edge to its index in open, if any
    local in_open = {}

    -- graph.nodes will be iteration over nodes (since the graph has a lot in it now at top level, includes edges
    -- Get sources
    for _, node in pairs(graph.nodes) do
        -- New: Store ops in nodes
        if node.op == "AND" and #node.pre == 0 then
            -- Since no prereqs, node is receiving all contexts (handled specially with "true", when normally contexts_to_push would get table)
            -- contexts_to_push reads node's context type and returns the types that it pushes (either identity function, constant function on a single context, or constant function on "true"/all contexts)
            -- (But need to check that passed in context isn't none/false in all cases)
            local contexts = contexts_to_push(node, true)
            -- Iterate over outgoing edges to add these contexts to those edges
            -- node.dep iterates over edge keys
            for dep, _ in pairs(node.dep) do
                -- A function that should merge contexts with current ones, taking special false/true cases into consideration for performance
                add_contexts(edge_to_contexts[dep], contexts)
                -- Sorted now carries edges with the new contexts to be updated on their end nodes
                table.insert(sorted, {
                    edge = dep,
                    new_contexts = contexts,
                })
            end
        end
    end

    -- Nodes in order that they got context added; includes duplicates so that we can see when they were reached again with new context
    local sorted = {}

    local function add_context_to_node(curr_node, context)
        node_to_contexts[key(curr_node)] = true
        -- Transmit context(s) to deps
        for _, dep in pairs(curr_node.dep) do
            -- First test if edge already in open and if so add to its contexts for efficiency
            if in_open[dep] ~= nil and not edge_to_contexts[context] then
                open[in_open[dep]].new_contexts[context] = true
            elseif not edge_to_contexts[context] then
                -- Only add to sorted if it's not already in open
                table.insert(sorted, curr_node)
                in_open[dep] = true
                table.insert(open, {
                    edge = dep,
                    new_contexts = {
                        context = true,
                    }
                })
            end
        end
    end

    local ind = 1
    while ind <= #open do
        local open_info = open_ind
        local curr_edge = graph.edges[open_info.edge]
        -- NOTE: I was originally planning to use .end as the property to get an edge's endnode key, but forgot end was a lua keyword
        local curr_node = graph.nodes[curr_edge.stop]
        -- Remove edge from open so it doesn't get added to
        in_open[open_info.edge] = nil
        
        -- Check if all contexts already added for efficiency
        if node_to_contexts[key(curr_node)] ~= true then
            -- get_contexts accounts for special cases like true/false meaning all/none
            -- TODO: Also add efficient testing for if new_contexts == true (like for OR nodes, just setting their contexts to true right away)
            -- TODO: For AND nodes, we could track edges with true
            local new_contexts = {}
            for _, context in pairs(get_contexts(open_info.new_contexts)) do
                -- Check if context already added to node
                if not node_to_contexts[context] then
                    -- Increase number of incoming edges to node with this context
                    local node_context_amounts = node_context_to_satisfied[key(curr_node)]
                    node_context_amounts[context] = node_context_amounts[context] + 1

                    if curr_node.op == "AND" then
                        -- Check if all incoming edges now have this context
                        if node_context_amounts[context] == #curr_node.pre then
                            add_context_to_node(curr_node, context)
                        end
                    elseif curr_node.op == "OR" then
                        -- Just add context to node; any new context is enough
                        add_context_to_node(curr_node, context)
                    end
                end
            end
        end

        ind = ind + 1
    end

    local reachable = {}
    -- Nodes with at least one context are counted as reachable
    for node_key, contexts in pairs(node_to_contexts) do
        for _, has_context in pairs(contexts) do
            if has_context then
                reachable[node_key] = true
                break
            end
        end
    end

    return {
        sorted = sorted,
        reachable = reachable,
    }
end

return top