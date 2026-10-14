-- Read-only eligibility and footprint audit; this is not a production reduction.
local gutils = require("src/lib/graph/graph-utils")
local logic = require("src/logic/state")

local audit = {}

local function plain_node(node)
    local info = logic.type_info[node.type] or {}
    if node.op ~= "OR" or info.context ~= nil or info.research_input == true or info.home_carrier == true or info.relay == true then
        return false
    end
    for field, _ in pairs(node) do
        if field ~= "object_type" and field ~= "type" and field ~= "name" and field ~= "op" and field ~= "pre" and field ~= "dep" and field ~= "num_pre" and field ~= "class" and field ~= "prot" then
            return false
        end
    end
    return true
end

-- Recover the original incoming edge after OR subdivision. Claimed links stay explicit.
audit.inspect = function(graph, node)
    local source_type, unit_amount
    if node.type == "entity-own-operable" then
        source_type, unit_amount = "entity-own", 1
    elseif node.type == "recipe-unlock" then
        source_type = "recipe-tech-unlock"
    else
        return nil
    end
    if node.num_pre ~= 1 then return { reason = "alternatives" } end
    if not plain_node(node) then return { reason = "node-metadata" } end
    local edge = graph.edges[next(node.pre)]
    local source = graph.nodes[edge.start]
    local connector_key
    if source.type == "orand" then
        connector_key = gutils.key(source)
        if source.num_pre ~= 1 then return { reason = "connector-inputs" } end
        edge = graph.edges[next(source.pre)]
        source = graph.nodes[edge.start]
    end
    if source.type ~= source_type or source.name ~= node.name then return { reason = "source-shape" } end
    if not plain_node(source) then return { reason = "source-metadata" } end
    for field, value in pairs(edge) do
        if field ~= "object_type" and field ~= "start" and field ~= "stop" and (field ~= "amount" or value ~= unit_amount) then
            return { reason = "input-transform" }
        end
    end
    -- Redirecting outgoing edges must not overwrite another edge from the survivor.
    for out_key, _ in pairs(node.dep) do
        local out_edge = graph.edges[out_key]
        local stop_key = out_edge.stop
        -- A zero-consumption OR input makes the forwarder's price zero; don't expose its source price to a consuming output.
        local amount = graph.nodes[stop_key].type == "base" and graph.nodes[stop_key].amount or out_edge.amount
        if unit_amount == nil and (amount or 0) ~= 0 then return { reason = "consuming-output" } end
        if graph.nodes[stop_key].type == "orand" then
            stop_key = graph.orand_to_parent[stop_key]
        end
        for source_out, _ in pairs(source.dep) do
            local other_stop = graph.edges[source_out].stop
            if graph.nodes[other_stop].type == "orand" then
                other_stop = graph.orand_to_parent[other_stop]
            end
            if other_stop == stop_key then return { reason = "output-collision" } end
        end
    end
    return {
        reason = "forwarding",
        source_key = gutils.key(source),
        connector_key = connector_key,
        source_inputs = source.num_pre,
    }
end

audit.report = function(graph, sort_info, stage)
    local stored = {}
    for _, key in pairs(sort_info.pebble_keys) do stored[key] = (stored[key] or 0) + 1 end
    local groups = {}
    local function count_contexts(key)
        local n = 0
        for _, _ in pairs(sort_info.node_to_context_inds[key] or {}) do n = n + 1 end
        return n
    end
    for key, node in pairs(graph.nodes) do
        local info = audit.inspect(graph, node)
        if info ~= nil then
            local reason = info.reason
            if reason == "forwarding" and node.type == "recipe-unlock" then
                reason = reason .. (info.source_inputs == 0 and "-empty" or info.source_inputs == 1 and "-single" or "-multiple")
            end
            local group_key = node.type .. " " .. reason
            local group = groups[group_key] or {
                nodes = 0,
                stored = 0,
                represented = 0,
                connector_stored = 0,
                connector_represented = 0,
                differing = 0,
            }
            groups[group_key] = group
            group.nodes = group.nodes + 1
            group.stored = group.stored + (stored[key] or 0)
            group.represented = group.represented + count_contexts(key)
            if info.connector_key ~= nil then
                group.connector_stored = group.connector_stored + (stored[info.connector_key] or 0)
                group.connector_represented = group.connector_represented + count_contexts(info.connector_key)
            end
            if info.source_key ~= nil then
                local a = sort_info.node_to_context_inds[key] or {}
                local b = sort_info.node_to_context_inds[info.source_key] or {}
                local differs = false
                for c, _ in pairs(a) do if b[c] == nil then differs = true end end
                for c, _ in pairs(b) do if a[c] == nil then differs = true end end
                if differs then group.differing = group.differing + 1 end
            end
        end
    end
    local keys = {}
    for key, _ in pairs(groups) do table.insert(keys, key) end
    table.sort(keys)
    for _, key in pairs(keys) do
        local group = groups[key]
        log("FORWARDINGAUDIT " .. stage .. " " .. key .. " nodes=" .. group.nodes
            .. " stored=" .. group.stored .. " represented=" .. group.represented
            .. " connector_stored=" .. group.connector_stored .. " connector_represented=" .. group.connector_represented
            .. " differing=" .. group.differing)
    end
end

return audit
