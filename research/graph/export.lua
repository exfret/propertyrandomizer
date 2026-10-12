-- Export the minimum graph/logic data needed by the Python consistent sort.
--
-- Usage after logic.build():
--   local exporter = require("path/to/export-consistent-sort-graph")
--   exporter.export_to_log(logic)  -- works in Factorio's data stage
--
-- In the repository's offline Lua runner, this is also available:
--   exporter.export_to_file(logic, "offline/output/consistent-sort-graph.json")

local exporter = {}

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
    local max_index = 0
    local count = 0
    for key, _ in pairs(value) do
        if type(key) ~= "number" or key < 1 or key % 1 ~= 0 then
            return false
        end
        max_index = math.max(max_index, key)
        count = count + 1
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
            error("Cannot encode non-finite number as JSON")
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
    error("Cannot encode value of type " .. value_type .. " as JSON")
end

local function context_mode(context_type)
    if context_type == nil then
        return "preserve"
    elseif context_type == true then
        return "broadcast"
    elseif type(context_type) == "string" then
        return "emit-node-name"
    end
    error("Unsupported node context type: " .. type(context_type))
end

local function unpack_inputs(logic_or_graph, contexts, type_info)
    if logic_or_graph ~= nil and logic_or_graph.graph ~= nil then
        return logic_or_graph.graph, logic_or_graph.contexts, logic_or_graph.type_info
    end
    if logic_or_graph == nil or contexts == nil or type_info == nil then
        error("Expected logic, or graph plus contexts and type_info")
    end
    return logic_or_graph, contexts, type_info
end

function exporter.build_export_object(logic_or_graph, contexts, type_info)
    local graph
    graph, contexts, type_info = unpack_inputs(
        logic_or_graph,
        contexts,
        type_info
    )
    if graph.nodes == nil or graph.edges == nil then
        error("logic.build() must run before exporting the graph")
    end

    local context_list = {}
    for context, _ in pairs(contexts) do
        context_list[#context_list + 1] = context
    end
    table.sort(context_list)

    local nodes = {}
    local node_keys = {}
    for node_key, node in pairs(graph.nodes) do
        local node_type_info = type_info[node.type]
        if node_type_info == nil then
            error("Missing type_info for node type " .. tostring(node.type))
        end
        nodes[#nodes + 1] = {
            key = node_key,
            type = node.type,
            name = node.name,
            op = node.op or node_type_info.op,
            context_mode = context_mode(node_type_info.context),
        }
        node_keys[node_key] = true
    end
    table.sort(nodes, function(left, right)
        return left.key < right.key
    end)

    -- Export the final graph exactly as built by Property Randomizer.  The
    -- frozen-profile adapter adds AP gate subdivisions and a supplied stable
    -- goal later; this exporter never guesses a particular launch or planet.
    local edges = {}
    for _, edge in pairs(graph.edges) do
        edges[#edges + 1] = { start = edge.start, stop = edge.stop }
    end
    table.sort(edges, function(left, right)
        if left.start == right.start then
            return left.stop < right.stop
        end
        return left.start < right.start
    end)
    return {
        format = FORMAT,
        contexts = context_list,
        nodes = nodes,
        edges = edges,
    }
end

function exporter.to_json(logic_or_graph, contexts, type_info)
    return json_encode(
        exporter.build_export_object(logic_or_graph, contexts, type_info)
    )
end

function exporter.export_to_log(logic_or_graph, contexts, type_info)
    local json_string = exporter.to_json(logic_or_graph, contexts, type_info)
    log(BEGIN_MARKER)
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

function exporter.export_to_file(logic_or_graph, path, contexts, type_info)
    if io == nil or io.open == nil then
        error("export_to_file is only available in the offline Lua runner")
    end
    local handle, open_error = io.open(path, "wb")
    if handle == nil then
        error("Could not open export path: " .. tostring(open_error))
    end
    handle:write(exporter.to_json(logic_or_graph, contexts, type_info))
    handle:write("\n")
    handle:close()
end

return exporter
