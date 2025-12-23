local graph_utils = require("lib/graph/graph-utils")
local es = require("lib/energy_source")
local rng = require("lib/random/rng")
local registry = require("randomizations/graph/core/registry")
local helpers = require("randomizations/graph/core/helpers")
local const = require("randomizations/graph/core/constants")

local item_node_type = "item-surface"
local burn_node_type = "burn-item-surface"
local burner_energy_source = "burner"

local items_with_burnt_result

local randomizer = registry.create_empty_randomizer("burnt-result-fuel")
randomizer.config.preferred_edges = const.config_reachable
randomizer.get_target_edges = function (state)
    local edges = {}
    for _, node_key in pairs(state.node_type_to_node_keys[item_node_type]) do
        local node = state.vanilla_graph[node_key]
        for _, prereq in pairs(node.prereqs) do
            if prereq.type == burn_node_type then
                local edge = graph_utils.create_edge(graph_utils.get_node_key(prereq), node_key, state.vanilla_graph)
                edges[edge.key] = edge
            end
        end
    end
    return edges
end

randomizer.pre_randomization = function (state)
    items_with_burnt_result = {}
end

randomizer.execute_randomization = function (state)
    if state.first_edge_count == 0 then
        return
    end
    for i = #state.suitable_edges, 1, -1 do
        local prereq_key = state.suitable_edges[i].prereq_key
        local item_name = state.random_graph[prereq_key].item
        if items_with_burnt_result[item_name] ~= nil then
            table.remove(state.suitable_edges, i)
        end
    end
    if #state.suitable_edges < state.first_edge_count then
        state.postpone = true
        return
    end
    rng.shuffle(state.rng_key, state.suitable_edges)
    for i = 1, state.first_edge_count do
        state.new_edges[i] = state.suitable_edges[i]
    end
end

randomizer.on_assign_prereqs_success = function (state)
    for _, prereq in pairs(state.node.prereqs) do
        if prereq.type == burn_node_type then
            local node = graph_utils.get_node(state.random_graph, prereq)
            items_with_burnt_result[node.item] = true
        end
    end
end

randomizer.finalize = function (state)
    local fuel_categories_with_burnt_results = {}
    for _, item in pairs(helpers.items) do
        item.burnt_result = nil
    end
    for _, node_key in pairs(state.node_type_to_node_keys[item_node_type]) do
        local node = state.random_graph[node_key]
        local target_prereqs = {}
        for _, prereq in pairs(node.prereqs) do
            if prereq.type == burn_node_type then
                local prereq_node = graph_utils.get_node(state.random_graph, prereq)
                table.insert(target_prereqs, prereq_node.item)
            end
        end
        assert(#target_prereqs <= 1)
        if #target_prereqs > 0 then
            local item = helpers.items[target_prereqs[1]]
            item.burnt_result = node.item
            assert(item.fuel_category)
            fuel_categories_with_burnt_results[item.fuel_category] = true
        end
    end
    for prototype_type, property in es.iter_burner_properties() do
        for _, prototype in pairs(data.raw[prototype_type] or {}) do
            local energy_source = prototype[property]
            if energy_source and energy_source.type == burner_energy_source then
                if not energy_source.fuel_categories then
                    energy_source.fuel_categories = { "chemical" }
                end
                local has_burnt_results = false
                for _, fuel_category in pairs(energy_source.fuel_categories) do
                    if fuel_categories_with_burnt_results[fuel_category] then
                        has_burnt_results = true
                    end
                end
                if has_burnt_results then
                    energy_source.burnt_inventory_size = 1
                else
                    energy_source.burnt_inventory_size = nil
                end
            end
        end
    end
end

registry.add(randomizer)