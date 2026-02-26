-- A file for common graph utils

local gutils = {}

-- Select separator strings with characters that cannot appear in names
-- Assuming all names are [a-z-]+

local node_key_separator = ": "
local concat_separators = {"__", "_2_"}
local edge_separator = " --> "

-- Get key from type + name
gutils.key = function(node_type, node_name)
    -- If just one argument was passed, view node_type as the node
    if node_name == nil then
        return gutils.key(node_type.type, node_type.name)
    end
    return node_type .. node_key_separator .. node_name
end

-- Deconstruct a key into a corresponding type and name
gutils.deconstruct = function(node_key)
    local i, j = string.find(node_key, node_key_separator)
    return {
        type = string.sub(node_key, 1, i - 1),
        name = string.sub(node_key, j + 1, -1),
    }
end

-- Turn a table/list of strings into a string
gutils.concat = function(key_tbl, sep_level)
    -- Sometimes, we need a second unique separator for "concatenations over concatenations"
    sep_to_use = concat_separators[sep_level or 1]

    local compound_key = ""
    for _, key in pairs(key_tbl) do
        compound_key = compound_key .. sep_to_use .. tostring(key)
    end
    return string.sub(compound_key, 1 + #sep_to_use, -1)
end

gutils.ekey = function(edge)
    return edge.start .. edge_separator .. edge.stop
end

-- TODO: Key deconstruct function for concat and ekey (basically a .split())
-- Could call this deconcat

gutils.prenode = function(graph, pre)
    return graph.nodes[graph.edges[pre].start]
end

gutils.depnode = function(graph, dep)
    return graph.nodes[graph.edges[dep].stop]
end

-- Untested
gutils.pres = function(graph, node)
    local edges = {}
    for pre, _ in pairs(node.pre) do
        if graph.edges[pre] == nil then
            log(serpent.block(node))
            log(pre)
            error("Randomization assertion failed! Tell exfret he's a dumbo.")
        end
        table.insert(edges, graph.edges[pre])
    end
    return edges
end

-- Untested
gutils.deps = function(graph, node)
    local edges = {}
    for dep, _ in pairs(node.dep) do
        if graph.edges[dep] == nil then
            log(serpent.block(node))
            log(dep)
            error("Randomization assertion failed! Tell exfret he's a dumbo.")
        end
        table.insert(edges, graph.edges[dep])
    end
    return edges
end

gutils.prenodes = function(graph, node)
    local nodes = {}
    for pre, _ in pairs(node.pre) do
        table.insert(nodes, gutils.prenode(graph, pre))
    end
    return nodes
end

gutils.depnodes = function(graph, node)
    local nodes = {}
    for dep, _ in pairs(node.dep) do
        table.insert(nodes, gutils.depnode(graph, dep))
    end
    return nodes
end

-- Untested
-- Gets unique pre (edge) (only works if it is unique)
gutils.unique_pre = function(graph, node)
    -- Check both num_pre and actual number prereqs for safety
    if node.num_pre ~= 1 then
        error("Graph invariant failed. Tell exfret he's a dumbo!")
    end
    local pres = gutils.pres(graph, node)
    if #pres ~= 1 then
        error("Graph invariant failed. Tell exfret he's a dumbo!")
    end
    return pres[1]
end

-- Untested
-- Gets unique dep (edge) (only works if it is unique)
gutils.unique_dep = function(graph, node)
    local deps = gutils.deps(graph, node)
    if #deps ~= 1 then
        error("Graph invariant failed. Tell exfret he's a dumbo!")
    end
    return deps[1]
end

-- Untested
-- Gets unique prenode (only works if it is unique)
gutils.unique_prenode = function(graph, node)
    return gutils.prenode(graph, gutils.ekey(gutils.unique_pre(graph, node)))
end

-- Untested
-- Gets unique depnode (only works if it is unique)
gutils.unique_depnode = function(graph, node)
    return gutils.depnode(graph, gutils.ekey(gutils.unique_dep(graph, node)))
end

local connector_types = {
    ["slot"] = true,
    ["traveler"] = true,
}

-- Same as above, but goes through slots/travs until reaching a "proper" node
gutils.unique_preconn = function(graph, node)
    repeat
        node = gutils.unique_prenode(graph, node)
    until not connector_types[node.type]
    return node
end

gutils.unique_depconn = function(graph, node)
    repeat
        node = gutils.unique_depnode(graph, node)
    until not connector_types[node.type]
    return node
end

-- Does not add to sources or add op property
gutils.add_node = function(graph, node_type, node_name, extra)
    local node = {
        object_type = "node",
        type = node_type,
        name = node_name,
        pre = {},
        dep = {},
        num_pre = 0,
    }

    if extra ~= nil then
        for k, v in pairs(extra) do
            node[k] = v
        end
    end

    local node_key = gutils.key(node_type, node_name)

    graph[node_key] = node

    if graph.nodes ~= nil then
        graph.nodes[node_key] = node
    end

    return node
end

gutils.add_edge = function(graph, start, stop, extra)
    if type(start) == "table" then
        start = gutils.key(start)
    end
    if type(stop) == "table" then
        stop = gutils.key(stop)
    end

    local edge = {
        object_type = "edge",
        start = start,
        stop = stop,
    }

    if extra ~= nil then
        for k, v in pairs(extra) do
            edge[k] = v
        end
    end

    local edge_key = gutils.ekey(edge)
    graph[edge_key] = edge

    -- If we have constructed the nodes yet, then populate their pre/dep/etc.
    if graph.nodes ~= nil then
        if graph.nodes[edge.start] ~= nil then
            graph.nodes[edge.start].dep[edge_key] = true
        end
        if graph.nodes[edge.stop] ~= nil then
            graph.nodes[edge.stop].pre[edge_key] = true
            graph.nodes[edge.stop].num_pre = graph.nodes[edge.stop].num_pre + 1
            if graph.sources[edge.stop] then
                graph.sources[edge.stop] = nil
            end
        end
    end
    -- Only add to edges if we've constructed it
    if graph.edges ~= nil then
        graph.edges[edge_key] = edge
    end

    return edge
end

gutils.remove_edge = function(graph, edge_key)
    local edge = graph.edges[edge_key]
    
    graph.edges[edge_key] = nil
    graph.nodes[edge.start].dep[edge_key] = nil
    graph.nodes[edge.stop].pre[edge_key] = nil
    graph.nodes[edge.stop].num_pre = graph.nodes[edge.stop].num_pre - 1
    -- Recompute sources
    if graph.nodes[edge.stop].op == "AND" and graph.nodes[edge.stop].num_pre == 0 then
        graph.sources[edge.stop] = true
    end
end

gutils.subdivide = function(graph, edge_key)
    local edge = graph.edges[edge_key]
    local node1 = graph.nodes[edge.start]
    local node2 = graph.nodes[edge.stop]
    local slot = gutils.add_node(graph, "slot", edge_key)
    local traveler = gutils.add_node(graph, "traveler", edge_key)
    slot.op = "AND"
    traveler.op = "OR"
    slot.old_trav = gutils.key(traveler)
    traveler.old_slot = gutils.key(slot)
    gutils.add_edge(graph, gutils.key(node1), gutils.key(slot))
    gutils.add_edge(graph, gutils.key(traveler), gutils.key(node2))
    -- Slot and traveler start connected
    gutils.add_edge(graph, gutils.key(slot), gutils.key(traveler))
    gutils.remove_edge(graph, edge_key)

    -- Add any extra info that was on the edge to the slot and traveler nodes
    local normal_keys = {
        ["start"] = true,
        ["stop"] = true,
        ["object_type"] = true,
    }
    for k, v in pairs(edge) do
        if not normal_keys[k] then
            slot[k] = v
            traveler[k] = v
        end
    end

    return {
        slot = slot,
        traveler = traveler,
    }
end

-- TODO: The following could be rewritten in terms of the new traversal functions once I feel confident about them
-- Get a slot or traveler's base node
gutils.get_conn_owner = function(graph, conn)
    if conn.type == "slot" then
        -- There should only be one prereq
        for pre, _ in pairs(conn.pre) do
            return graph.nodes[graph.edges[pre].start]
        end
    end
    if conn.type == "traveler" then
        -- There should only be one dependent
        for dep, _ in pairs(conn.dep) do
            return graph.nodes[graph.edges[dep].stop]
        end
    end
end

-- Get a slot or traveler's connected traveler/slot, if any
gutils.get_conn_buddy = function(graph, conn)
    if conn.type == "slot" then
        -- There should only be one prereq
        for dep, _ in pairs(conn.dep) do
            return graph.nodes[graph.edges[dep].stop]
        end
    end
    if conn.type == "traveler" then
        -- There should only be one dependent
        for pre, _ in pairs(conn.pre) do
            return graph.nodes[graph.edges[pre].start]
        end
    end
end

return gutils