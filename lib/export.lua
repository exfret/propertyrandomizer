-- NOTE: This file was written by ChatGPT
-- It was originally made for Archipelago compatibility, which I didn't deem worth the 20-30 hours of work it would have otherwise taken, so it was either this or nothing


-- Exports the final PropertyRandomizer logic graph for the external Python
-- consistent-sort implementation.
--
-- Factorio's data stage cannot write arbitrary files, so this module emits
-- chunked JSON through log(). tools/extract-consistent-sort-graph.py rebuilds
-- the JSON file from factorio-current.log.

local export = {}

local FORMAT = "propertyrandomizer-consistent-sort-graph-v1"
local CHUNK_SIZE = 8000
local BEGIN_MARKER = "PROPERTYRANDOMIZER_CONSISTENT_SORT_GRAPH_JSON_BEGIN"
local CHUNK_MARKER = "PROPERTYRANDOMIZER_CONSISTENT_SORT_GRAPH_JSON_CHUNK "
local END_MARKER = "PROPERTYRANDOMIZER_CONSISTENT_SORT_GRAPH_JSON_END"

local function json_escape_string(value)
    local string_value = tostring(value)
    string_value = string.gsub(string_value, "\\", "\\\\")
    string_value = string.gsub(string_value, "\"", "\\\"")
    string_value = string.gsub(string_value, "\b", "\\b")
    string_value = string.gsub(string_value, "\f", "\\f")
    string_value = string.gsub(string_value, "\n", "\\n")
    string_value = string.gsub(string_value, "\r", "\\r")
    string_value = string.gsub(string_value, "\t", "\\t")
    return "\"" .. string_value .. "\""
end

local function is_array(value)
    local count = 0
    local max_index = 0

    for key, _ in pairs(value) do
        if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
            return false
        end
        count = count + 1
        max_index = math.max(max_index, key)
    end

    return count == max_index
end

local function sorted_keys(value)
    local keys = {}
    for key, _ in pairs(value) do
        keys[#keys + 1] = key
    end
    table.sort(keys, function(left, right)
        return tostring(left) < tostring(right)
    end)
    return keys
end

local function json_encode(value)
    local value_type = type(value)

    if value_type == "nil" then
        return "null"
    elseif value_type == "boolean" then
        return value and "true" or "false"
    elseif value_type == "number" then
        if value ~= value or value == math.huge or value == -math.huge then
            error("Cannot encode a non-finite number as JSON")
        end
        return string.format("%.17g", value)
    elseif value_type == "string" then
        return json_escape_string(value)
    elseif value_type == "table" then
        local parts = {}
        if is_array(value) then
            for index = 1, #value do
                parts[#parts + 1] = json_encode(value[index])
            end
            return "[" .. table.concat(parts, ",") .. "]"
        end

        for _, key in pairs(sorted_keys(value)) do
            parts[#parts + 1] =
                json_escape_string(key) .. ":" .. json_encode(value[key])
        end
        return "{" .. table.concat(parts, ",") .. "}"
    end

    error("Cannot encode a value of type " .. value_type .. " as JSON")
end

local function get_context_mode(context_value)
    if context_value == nil then
        return "preserve"
    elseif context_value == true then
        return "broadcast"
    elseif type(context_value) == "string" then
        -- context-utils.lua ignores the shared type-info string and emits the
        -- particular room node's name.
        return "emit-node-name"
    end

    error(
        "Unsupported context metadata type: " .. type(context_value)
    )
end

function export.build_export_object(logic)
    if logic == nil then
        error("Expected new-lib/logic/init")
    end
    if logic.graph == nil or logic.graph.nodes == nil
        or logic.graph.edges == nil then
        error("logic.build() must run before exporting")
    end
    if logic.contexts == nil or logic.type_info == nil then
        error("Logic contexts/type_info have not been built")
    end

    local contexts = {}
    for context, _ in pairs(logic.contexts) do
        contexts[#contexts + 1] = context
    end
    table.sort(contexts)

    local nodes = {}
    for node_key, node in pairs(logic.graph.nodes) do
        local type_info = logic.type_info[node.type]
        if type_info == nil then
            error("Missing type_info for node type " .. tostring(node.type))
        end

        local op = node.op or type_info.op
        if op ~= "AND" and op ~= "OR" then
            error("Invalid op on node " .. node_key .. ": " .. tostring(op))
        end

        nodes[#nodes + 1] = {
            key = node_key,
            type = node.type,
            name = node.name,
            op = op,
            context_mode = get_context_mode(type_info.context),
        }
    end
    table.sort(nodes, function(left, right)
        return left.key < right.key
    end)

    local edges = {}
    for _, edge in pairs(logic.graph.edges) do
        edges[#edges + 1] = {
            start = edge.start,
            stop = edge.stop,
        }
    end
    table.sort(edges, function(left, right)
        if left.start == right.start then
            return left.stop < right.stop
        end
        return left.start < right.start
    end)

    return {
        format = FORMAT,
        contexts = contexts,
        nodes = nodes,
        edges = edges,
    }
end

function export.export_to_log(logic)
    local export_object = export.build_export_object(logic)
    local json_string = json_encode(export_object)

    log(
        BEGIN_MARKER
        .. " nodes=" .. tostring(#export_object.nodes)
        .. " edges=" .. tostring(#export_object.edges)
        .. " contexts=" .. tostring(#export_object.contexts)
        .. " chars=" .. tostring(#json_string)
    )

    local position = 1
    while position <= #json_string do
        log(
            CHUNK_MARKER
            .. string.sub(json_string, position, position + CHUNK_SIZE - 1)
        )
        position = position + CHUNK_SIZE
    end

    log(END_MARKER)
end

return export