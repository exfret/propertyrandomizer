-- Share the supply OR with entity-build-architecture, which otherwise only forwards it.
-- Placement inputs remain alternatives, with their acquisition and quantity fields intact.
-- Bootstrap and bulk supply still query supply alone, before entity-build's extra requirements.
local gutils = require("src/lib/graph/graph-utils")
local logic = require("src/logic/state")

local supply = {}

local function extras(object)
    local result = {}
    for field, value in pairs(object) do
        if field ~= "object_type" and field ~= "type" and field ~= "name" and field ~= "start" and field ~= "stop" and field ~= "pre" and field ~= "dep" and field ~= "num_pre" then
            result[field] = table.deepcopy(value)
        end
    end
    return result
end

local function plain_node(node)
    local info = logic.type_info[node.type] or {}
    if node.op ~= "OR" or info.context ~= nil or info.research_input == true or info.home_carrier == true or info.relay == true then
        return false
    end
    for field, _ in pairs(extras(node)) do
        if field ~= "op" and field ~= "class" and field ~= "prot" then
            return false
        end
    end
    return true
end

local function unit_edge(edge)
    for field, value in pairs(extras(edge)) do
        if field ~= "amount" or value ~= 1 then
            return false
        end
    end
    return true
end

local function remove_edge(graph, key)
    gutils.remove_edge(graph, key)
    graph[key] = nil
end

-- The physical supply node. Legacy/full graphs and detached spoof positions keep their OR.
supply.key = function(graph, name)
    local key = gutils.key("entity-build-architecture", name)
    if (graph.nodes[key] or {}).build_supply == true then
        return key
    end
    return gutils.key("entity-build-item", name)
end

supply.is_node = function(node)
    return node ~= nil and (node.type == "entity-build-item" or node.build_supply == true)
end

-- Virtual queries point to a real supply pebble, so witness callers can use its rank.
supply.context_inds = function(graph, sort_info, key)
    local node = gutils.deconstruct(key)
    if node.type == "entity-build-item" then
        key = supply.key(graph, node.name)
    end
    return sort_info.node_to_context_inds[key] or {}
end

supply.contract = function(graph)
    local keys = {}
    for key, node in pairs(graph.nodes) do
        if node.type == "entity-build-item" then
            table.insert(keys, key)
        end
    end
    table.sort(keys)
    local count = 0
    for _, key in pairs(keys) do
        local node = graph.nodes[key]
        local target_key = gutils.key("entity-build-architecture", node.name)
        local target = graph.nodes[target_key]
        local link_key = gutils.ekey({
            start = key,
            stop = target_key,
        })
        local link = graph.edges[link_key]
        local safe = target ~= nil and plain_node(node) and plain_node(target) and link ~= nil and target.num_pre == 1
        local outputs = {}
        for edge_key, _ in pairs(node.dep) do
            local edge = graph.edges[edge_key]
            if not unit_edge(edge) or (edge.stop ~= target_key and graph.edges[gutils.ekey({
                start = target_key,
                stop = edge.stop,
            })] ~= nil) then
                safe = false
            end
            outputs[edge.stop] = extras(edge)
        end
        for edge_key, _ in pairs(node.pre) do
            local edge = graph.edges[edge_key]
            local source = graph.nodes[edge.start]
            local info = logic.type_info[source.type] or {}
            -- The merge must not open a research-home route that the supply OR stopped.
            if source.type ~= "item" or edge.acq_kind ~= "build" or info.research_input == true or info.home_carrier == true or info.relay == true or info.context ~= nil then
                safe = false
            end
        end
        if safe then
            graph.entity_build_item_nodes = graph.entity_build_item_nodes or {}
            graph.entity_build_item_nodes[key] = {
                fields = extras(node),
                outputs = outputs,
            }
            for edge_key, _ in pairs(table.deepcopy(node.dep)) do
                local edge = graph.edges[edge_key]
                remove_edge(graph, edge_key)
                if edge.stop ~= target_key then
                    gutils.add_edge(graph, target_key, edge.stop, extras(edge))
                end
            end
            for edge_key, _ in pairs(table.deepcopy(node.pre)) do
                local edge = graph.edges[edge_key]
                remove_edge(graph, edge_key)
                gutils.add_edge(graph, edge.start, target_key, extras(edge))
            end
            target.build_supply = true
            graph.nodes[key], graph[key], graph.sources[key] = nil, nil, nil
            count = count + 1
        end
    end
    return count
end

-- Physical graphs are expanded before superposition, preserving edge-by-edge identity.
supply.expand_all = function(graph)
    local keys = {}
    for key, _ in pairs(graph.entity_build_item_nodes or {}) do
        table.insert(keys, key)
    end
    table.sort(keys)
    for _, key in pairs(keys) do
        local name = gutils.deconstruct(key).name
        local target_key = supply.key(graph, name)
        local target = graph.nodes[target_key]
        local record = graph.entity_build_item_nodes[key]
        gutils.add_node(graph, "entity-build-item", name, table.deepcopy(record.fields))
        for edge_key, _ in pairs(table.deepcopy(target.pre)) do
            local edge = graph.edges[edge_key]
            assert(graph.nodes[edge.start].type ~= "orand", "expand building supply before subdivision")
            remove_edge(graph, edge_key)
            gutils.add_edge(graph, edge.start, key, extras(edge))
        end
        for stop, extra in pairs(record.outputs) do
            if stop ~= target_key then
                remove_edge(graph, gutils.ekey({
                    start = target_key,
                    stop = stop,
                }))
            end
            gutils.add_edge(graph, key, stop, table.deepcopy(extra))
        end
        target.build_supply = nil
        graph.entity_build_item_nodes[key] = nil
    end
    return #keys
end

return supply
