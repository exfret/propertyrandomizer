-- Pass-through nodes: nodes that only pass on what comes in through their one way in to their one way out
-- A node type is pass-through when it's declared so where it's built (add_node's extra.pass_through, src/logic/builders/builder.lua); only declare types no code looks up by name (tests/unit/logic/analysis/test-pass-through-names.lua fails if some code does)
-- logic.build leaves out every pass-through node with exactly one plain edge in and one out, joining the two edges into one:
--   * Every node left gets the same contexts in every sort, since a pass-through node passes contexts on unchanged and plain edges carry no abilities (src/lib/sort/context-sort.lua)
--   * Research home contexts are the exception (top.research_home_contexts): only types the logic declares research_input, home_carrier or relay take them, so any other node stops them, and one standing between two that pass them on stays
--   * Prices stay the same too, since plain edges carry no amounts and the pass-through node no cost (src/cost/graph-cost-core.lua)
-- The joined edge keeps a record of every node it went through (edge.through), so expanding gives the graph back exactly, for code combining two games' graphs edge by edge (src/lib/graph/superpose.lua)
-- Recipe unlocks are contracted with the same splices, a whole chain at a time (src/logic/analysis/unlock-contraction.lua)

local gutils = require("src/lib/graph/graph-utils")
local logic = require("src/logic/state")

local pass_through = {}

-- The fields a node left out may have: anything else (a cost, a mechanic goal, a flag some code reads) keeps the node
local PLAIN_NODE_FIELDS = {
    object_type = true,
    type = true,
    name = true,
    op = true,
    pre = true,
    dep = true,
    num_pre = true,
    class = true,
    prot = true,
}

-- The fields a plain edge may have: its ends, and what it already went through
local PLAIN_EDGE_FIELDS = {
    object_type = true,
    start = true,
    stop = true,
    through = true,
}

local function has_only(object, fields)
    for k, _ in pairs(object) do
        if fields[k] == nil then
            return false
        end
    end
    return true
end

-- The only key of a node's pre or dep set, or nil if it has none or several
local function only(set)
    local first = next(set)
    if first == nil or next(set, first) ~= nil then
        return nil
    end
    return first
end

-- Edges and nodes also live under their keys in the graph table itself (gutils.add_edge, gutils.add_node), where graph_setup would find them again
local function remove_edge(graph, edge_key)
    gutils.remove_edge(graph, edge_key)
    graph[edge_key] = nil
end

local function remove_node(graph, node_key)
    graph.nodes[node_key] = nil
    graph[node_key] = nil
    if graph.sources ~= nil then
        graph.sources[node_key] = nil
    end
end

-- Whether a node's type passes research home contexts on (top.research_home_contexts in src/lib/sort/context-sort.lua): technologies (home_carrier), what their research needs (research_input), and unified's edge parts (relay)
local function passes_research_homes(graph, node_key)
    local info = logic.type_info[graph.nodes[node_key].type] or {}
    return info.home_carrier == true or info.research_input == true or info.relay == true
end

-- Whether an edge is plain: nothing on it but its ends and what it went through
pass_through.is_plain_edge = function(edge)
    return has_only(edge, PLAIN_EDGE_FIELDS)
end

-- Whether the node at node_key can be left out: it passes contexts on unchanged, has nothing on it some code reads, and has exactly one plain edge in and one out, between two other nodes not already joined
pass_through.can_splice = function(graph, node_key)
    local node = graph.nodes[node_key]
    if node == nil or (logic.type_info[node.type] or {}).context ~= nil or not has_only(node, PLAIN_NODE_FIELDS) or passes_research_homes(graph, node_key) then
        return false
    end
    local in_key = only(node.pre)
    local out_key = only(node.dep)
    if in_key == nil or out_key == nil then
        return false
    end
    local in_edge = graph.edges[in_key]
    local out_edge = graph.edges[out_key]
    if not pass_through.is_plain_edge(in_edge) or not pass_through.is_plain_edge(out_edge) or in_edge.start == out_edge.stop then
        return false
    end
    -- It stops research home contexts that would go from one to the other once it's left out
    if passes_research_homes(graph, in_edge.start) and passes_research_homes(graph, out_edge.stop) then
        return false
    end
    return graph.edges[gutils.ekey({
        start = in_edge.start,
        stop = out_edge.stop,
    })] == nil
end

-- Leaves out the node at node_key (pass_through.can_splice must hold), joining its edge in and its edge out into one edge, which it returns
-- The joined edge's through lists the left-out nodes in order, as records of their fields
pass_through.splice = function(graph, node_key)
    local node = graph.nodes[node_key]
    local in_key = next(node.pre)
    local out_key = next(node.dep)
    local in_edge = graph.edges[in_key]
    local out_edge = graph.edges[out_key]
    -- In order along the chain (numeric loops, as order matters here)
    local through = {}
    local in_through = in_edge.through or {}
    for i = 1, #in_through do
        table.insert(through, in_through[i])
    end
    local record = {}
    for k, v in pairs(node) do
        if k ~= "object_type" and k ~= "pre" and k ~= "dep" and k ~= "num_pre" then
            record[k] = v
        end
    end
    table.insert(through, record)
    local out_through = out_edge.through or {}
    for i = 1, #out_through do
        table.insert(through, out_through[i])
    end
    remove_edge(graph, in_key)
    remove_edge(graph, out_key)
    remove_node(graph, node_key)
    return gutils.add_edge(graph, in_edge.start, out_edge.stop, {
        through = through,
    })
end

-- Leaves out every node of a type declared pass-through that can be (pass_through.can_splice), in order of their keys
-- Returns how many it left out
pass_through.contract = function(graph)
    local node_keys = {}
    for node_key, node in pairs(graph.nodes) do
        if (logic.type_info[node.type] or {}).pass_through == true then
            table.insert(node_keys, node_key)
        end
    end
    table.sort(node_keys)
    local num_spliced = 0
    for _, node_key in pairs(node_keys) do
        if pass_through.can_splice(graph, node_key) then
            pass_through.splice(graph, node_key)
            num_spliced = num_spliced + 1
        end
    end
    return num_spliced
end

-- Gives back the nodes a joined edge went through, with their plain edges, and returns their keys in order
pass_through.expand = function(graph, edge_key)
    local edge = graph.edges[edge_key]
    if edge == nil or edge.through == nil then
        return {}
    end
    remove_edge(graph, edge_key)
    local node_keys = {}
    local previous = edge.start
    for i = 1, #edge.through do
        local record = edge.through[i]
        local extra = {}
        for k, v in pairs(record) do
            if k ~= "type" and k ~= "name" then
                extra[k] = v
            end
        end
        local node_key = gutils.key(gutils.add_node(graph, record.type, record.name, extra))
        gutils.add_edge(graph, previous, node_key)
        table.insert(node_keys, node_key)
        previous = node_key
    end
    gutils.add_edge(graph, previous, edge.stop)
    return node_keys
end

-- The keys of the joined edges, sorted
pass_through.joined_edges = function(graph)
    local edge_keys = {}
    for edge_key, edge in pairs(graph.edges) do
        if edge.through ~= nil then
            table.insert(edge_keys, edge_key)
        end
    end
    table.sort(edge_keys)
    return edge_keys
end

-- Gives back every node left out, giving the graph the full shape the builders make
-- For code combining two games' graphs edge by edge (src/lib/graph/superpose.lua): a node left out in one game but not the other (like a recipe unlocked by one technology there and by two here) must be in both for their edges to line up
-- Returns how many joined edges it expanded
pass_through.expand_all = function(graph)
    local edge_keys = pass_through.joined_edges(graph)
    for _, edge_key in pairs(edge_keys) do
        pass_through.expand(graph, edge_key)
    end
    return #edge_keys
end

return pass_through
