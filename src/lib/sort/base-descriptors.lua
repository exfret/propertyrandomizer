-- Ordinary bases retain their connector metadata, but share source witnesses instead of owning context arrays or pebbles.
-- Graph ownership and edge identities stay available to the handlers; this is a sort representation, not a change to randomization units.
local logic = require("src/logic/state")
local gutils = require("src/lib/graph/graph-utils")

local descriptors = {}

local function source_of(graph, node_key, node)
    local info = logic.type_info[node.type] or {}
    if node.type ~= "base" or node.name == "" or node.op ~= "AND" or node.num_pre ~= 1 or node.mechanic ~= nil or info.context ~= nil or info.research_input == true or info.home_carrier == true then
        return nil
    end
    local input_key = next(node.pre)
    local edge = input_key ~= nil and graph.edges[input_key] or nil
    if edge == nil or next(node.pre, input_key) ~= nil or edge.start == node_key or graph.nodes[edge.start].type == "base" then
        return nil
    end
    for field, _ in pairs(edge) do
        if field ~= "object_type" and field ~= "start" and field ~= "stop" then
            return nil
        end
    end
    return edge.start, input_key
end

-- Reuse forwarding sets across incremental sorts, which only add connections.
descriptors.prepare = function(graph, previous, new_conn, carries_home)
    local aliases = previous.base_aliases
    local forwarded = previous.base_forwarded
    if new_conn == nil then
        aliases, forwarded = {}, {}
        for node_key, node in pairs(graph.nodes) do
            local source_key, input_key = source_of(graph, node_key, node)
            if source_key ~= nil then
                aliases[node_key] = {
                    source = source_key,
                    carries_home = carries_home(node_key),
                }
                local deps = forwarded[source_key]
                if deps == nil then
                    deps = {}
                    for dep, _ in pairs(graph.nodes[source_key].dep) do deps[dep] = true end
                    forwarded[source_key] = deps
                end
                deps[input_key] = nil
                for dep, _ in pairs(node.dep) do deps[dep] = true end
            end
        end
    elseif aliases ~= nil then
        local first = new_conn[1]
        local node_key = gutils.key(first)
        local alias = aliases[node_key]
        if alias ~= nil then
            -- The original base's cached contexts also keep the full sort's home filter.
            for dep, _ in pairs(graph.nodes[node_key].dep) do
                forwarded[alias.source][dep] = true
            end
        elseif forwarded[node_key] ~= nil then
            -- A real source can gain an ordinary edge as well as descriptor pairings.
            -- Its future contexts must reach that edge through the same cached forwarding view.
            for dep, _ in pairs(graph.nodes[node_key].dep) do
                if aliases[graph.edges[dep].stop] == nil then
                    forwarded[node_key][dep] = true
                end
            end
        end
    end
    return aliases or {}, forwarded or {}
end

-- No per-base context maps: most entries return the source's actual table.
-- A research source feeding a nonresearch base needs a filtered table, shared by all such entries of that source.
descriptors.attach = function(indices, aliases, context_info)
    local filtered = {}
    local function contexts(tables, node_key)
        local alias = aliases[node_key]
        if alias == nil then return nil end
        local source = rawget(tables, alias.source)
        if source == nil then return nil end
        if not context_info.research_homes or alias.carries_home then return source end
        local known = filtered[alias.source]
        if known ~= nil then return known end
        local needs_filter = false
        for context, _ in pairs(source) do
            local home_id = context_info.home[context]
            if home_id ~= nil and context_info.home_full[home_id] == nil then
                needs_filter = true
                break
            end
        end
        if not needs_filter then
            filtered[alias.source] = source
            return source
        end
        local result = {}
        for context, ind in pairs(source) do
            local home_id = context_info.home[context]
            if home_id == nil or context_info.home_full[home_id] ~= nil then result[context] = ind end
        end
        filtered[alias.source] = result
        return result
    end
    -- This closure retains only the alias records and context metadata, never the graph.
    setmetatable(indices, { __index = contexts })
    return function(source_key)
        if source_key == nil then filtered = {} else filtered[source_key] = nil end
    end
end

return descriptors
