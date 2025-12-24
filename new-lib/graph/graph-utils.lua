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

gutils.add_node = function(graph, node_type, node_name, extra)
    local node = {
        object_type = "node",
        type = node_type,
        name = node_name,
    }

    if extra ~= nil then
        for k, v in pairs(extra) do
            node[k] = v
        end
    end

    graph[gutils.key(node_type, node_name)] = node

    return node
end

gutils.add_edge = function(graph, start, stop, extra)
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

    graph[gutils.ekey(edge)] = edge

    return edge
end

return gutils