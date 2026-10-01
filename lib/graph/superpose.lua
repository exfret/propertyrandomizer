-- Superposition of two worlds' logic graphs, like the game before and after a planetary change (see notes/old/context-shift-report)
-- It has every node and edge of either world, and the edges only the old world has are debt edges (edge.debt = true): they won't be in the game unless something pays for them
-- Adding in-edges to OR nodes only grows what the sort reaches, so when every debt edge that changes a node of the new world goes into an OR node, the superposition reaches everything either world reaches
-- That makes it a reference for both worlds' goals, where promotion can start before anything is repaired (planetary features all enter the logic through edges into OR nodes)

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")

local superpose = {}

local function copy_extras(edge)
    local extra = {}
    for k, v in pairs(edge) do
        if k ~= "object_type" and k ~= "start" and k ~= "stop" then
            extra[k] = table.deepcopy(v)
        end
    end
    return extra
end

-- Whether two edges change contexts the same way (abilities are all that matter to the sort)
local function same_abilities(edge1, edge2)
    local abilities1 = edge1.abilities or {}
    local abilities2 = edge2.abilities or {}
    for i, value in pairs(abilities1) do
        if abilities2[i] ~= value then
            return false
        end
    end
    for i, value in pairs(abilities2) do
        if abilities1[i] ~= value then
            return false
        end
    end
    return true
end

-- new_graph, old_graph: logic graphs whose shared nodes have the same keys (neither is changed)
-- An old edge whose endpoints the new world also connects, but with other abilities, is a different edge: the graph keys edges by their endpoints, so the old one goes through a connector node (an AND "base" node named after it) instead
-- Returns:
--   * graph: the superposition, a copy of new_graph plus old_graph's other nodes and edges
--   * debt_edges: edge key --> true for the edges only old_graph has (in the superposition's graph, so a connector's two edges for an old edge with other abilities)
--   * old_nodes: node key --> true for the nodes new_graph doesn't have (old_graph's own nodes and the connectors)
--   * not_into_or: keys of debt edges into nodes of new_graph that aren't OR nodes, since then the superposition may reach less than new_graph does and isn't a reference
superpose.union = function(new_graph, old_graph)
    local graph = table.deepcopy(new_graph)
    local old_nodes = {}
    for node_key, node in pairs(old_graph.nodes) do
        if graph.nodes[node_key] == nil then
            local copy = table.deepcopy(node)
            copy.pre = {}
            copy.dep = {}
            copy.num_pre = 0
            graph.nodes[node_key] = copy
            graph[node_key] = copy
            if copy.op == "AND" and graph.sources ~= nil then
                graph.sources[node_key] = true
            end
            old_nodes[node_key] = true
        end
    end
    local debt_edges = {}
    local not_into_or = {}
    local function add_debt(start, stop, extra)
        extra.debt = true
        local edge = gutils.add_edge(graph, start, stop, extra)
        debt_edges[gutils.ekey(edge)] = true
        local stop_node = new_graph.nodes[stop]
        if stop_node ~= nil and stop_node.op ~= "OR" then
            table.insert(not_into_or, gutils.ekey(edge))
        end
    end
    for edge_key, edge in pairs(old_graph.edges) do
        local new_edge = graph.edges[edge_key]
        if new_edge == nil then
            add_debt(edge.start, edge.stop, copy_extras(edge))
        elseif not same_abilities(new_edge, edge) then
            local connector = gutils.add_node(graph, "base", "superposed: " .. edge_key)
            connector.op = "AND"
            local connector_key = gutils.key(connector)
            old_nodes[connector_key] = true
            add_debt(edge.start, connector_key, copy_extras(edge))
            add_debt(connector_key, edge.stop, {})
        end
    end
    table.sort(not_into_or)
    return {
        graph = graph,
        debt_edges = debt_edges,
        old_nodes = old_nodes,
        not_into_or = not_into_or,
    }
end

-- Adds a superposition's debt (graph, debt_edges and old_nodes, as superpose.union returns them) to another graph with the same keys for shared nodes, like unified's graphs of the new world
-- Added nodes get old_world = true and added edges get debt = true
-- An edge into a node of graph that isn't an OR node is left out, since it would make that node harder to reach instead of easier
-- Returns the added edges (in a fixed order) and texts saying why the others were left out
superpose.add_debt = function(graph, debt)
    for node_key, _ in pairs(debt.old_nodes) do
        if graph.nodes[node_key] == nil then
            local copy = table.deepcopy(debt.graph.nodes[node_key])
            copy.pre = {}
            copy.dep = {}
            copy.num_pre = 0
            copy.old_world = true
            graph.nodes[node_key] = copy
            graph[node_key] = copy
        end
    end
    local added = {}
    local skipped = {}
    for edge_key, _ in pairs(debt.debt_edges) do
        local edge = debt.graph.edges[edge_key]
        local stop = graph.nodes[edge.stop]
        if graph.nodes[edge.start] == nil or stop == nil then
            table.insert(skipped, edge_key .. " (an end isn't in this graph)")
        elseif stop.op ~= "OR" and debt.old_nodes[edge.stop] == nil then
            table.insert(skipped, edge_key .. " (into an AND node)")
        elseif graph.edges[edge_key] ~= nil then
            table.insert(skipped, edge_key .. " (already an edge)")
        else
            local extra = copy_extras(edge)
            extra.debt = true
            table.insert(added, gutils.add_edge(graph, edge.start, edge.stop, extra))
        end
    end
    table.sort(added, function(a, b) return gutils.ekey(a) < gutils.ekey(b) end)
    table.sort(skipped)
    return added, skipped
end

-- Continues sort_info, a sort of graph made before superpose.add_debt added the debt edges, through those edges
-- Everything that needs debt then ranks after everything that doesn't (solvency first), since the sort reached everything else before
-- Every debt edge is in graph before the sort goes on, so continuing it from one also goes through the others it reaches
-- Returns the continued sort (the same tables, changed)
superpose.continue_through_debt = function(graph, sort_info, added)
    -- A sort only has entries for the nodes its graph had when it started, so the older world's own nodes (added by superpose.add_debt) get theirs before the sort can reach them
    for node_key, _ in pairs(graph.nodes) do
        if sort_info.node_to_context_inds[node_key] == nil then
            sort_info.node_to_context_inds[node_key] = {}
        end
    end
    for _, edge in pairs(added) do
        sort_info = top.sort(graph, sort_info, {
            graph.nodes[edge.start],
            graph.nodes[edge.stop],
        }, {
            choose_randomly = true,
            do_new_edge_processing = true,
        })
    end
    return sort_info
end

return superpose
