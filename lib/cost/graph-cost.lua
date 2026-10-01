-- Connect the pure graph pricing model to context sorts and recipe costs.
local core = require("lib/cost/graph-cost-core")
local context_costs = require("lib/cost/context-costs")
local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local logic = require("lib/logic/state")

local graph_cost = {
    compute = core.compute,
    price_without_recipes = core.price_without_recipes,
    RAW_COST_SCALE = core.RAW_COST_SCALE,
}

-- Prices for the contexts and context rules of a sort made by top.sort (lib/graph/context-sort.lua)
graph_cost.compute_for_sort = function(graph, sort_info, excluded, slot)
    local contexts = {}
    for context, _ in pairs(logic.contexts) do
        table.insert(contexts, context)
    end
    return graph_cost.compute(graph, contexts, function(node, incoming)
        return top.node_transmit(sort_info, node, incoming)
    end, excluded, slot)
end

-- Materials resource entities give that the starting room has without any research, like ores mined by hand or with a burner drill, as "type-name" ids (sorted)
-- These are the resources whose balance recipe randomization tracks separately (randomization_info.options.cost.major_raw_resources)
graph_cost.starting_resources = function(graph, sort_info, starting_context)
    local no_research = graph_cost.compute_for_sort(graph, sort_info, function(node_key)
        return graph.nodes[node_key].type == "technology"
    end)
    local found = {}
    for _, resource in pairs(dutils.prots("resource")) do
        for _, result in pairs(dutils.minable_results(resource)) do
            local material_key = gutils.key(result.type, result.name)
            if graph.nodes[material_key] ~= nil and graph_cost.price_without_recipes(graph, no_research, material_key, starting_context) ~= nil then
                found[result.type .. "-" .. result.name] = true
            end
        end
    end
    local ids = {}
    for id, _ in pairs(found) do
        table.insert(ids, id)
    end
    table.sort(ids)
    return ids
end

-- Whether a complex context (a room with ability string, see lib/graph/context-sort.lua) has automatability
local function context_automatable(context)
    local abilities = top.context_abilities(context)
    return abilities ~= nil and string.sub(abilities, top.AUTOMATABILITY, top.AUTOMATABILITY) == "1"
end

-- What a sort with complex contexts reaches automatably in each room: room --> material id ("type-name") --> true, for the item and fluid nodes of graph
graph_cost.automatable_by_room = function(graph, complex_sort_info)
    local automatable = {}
    for node_key, node in pairs(graph.nodes) do
        if node.type == "item" or node.type == "fluid" then
            local id = node.type .. "-" .. node.name
            for context, _ in pairs(complex_sort_info.node_to_context_inds[node_key] or {}) do
                if context_automatable(context) then
                    local room = top.context_room(context)
                    automatable[room] = automatable[room] or {}
                    automatable[room][id] = true
                end
            end
        end
    end
    return automatable
end

-- What each room has and makes (lib/cost/context-costs.lua) and the starting resources of a sorted graph, without setting anything
-- Its raw_costs are what derive_cost_options puts in the default cost table
graph_cost.build_costs = function(graph, sort_info, starting_context, complex_sort_info, contexts)
    local starting = graph_cost.starting_resources(graph, sort_info, starting_context)
    -- Slot costs price the player's own time (hand mining, say) dearly, so materials only gotten by hand aren't cheap
    local prices = graph_cost.compute_for_sort(graph, sort_info, nil, true)
    -- With the game's costs tracking the major resources
    return context_costs.build(graph, sort_info, prices, starting_context, contexts, true, starting, graph_cost.automatable_by_room(graph, complex_sort_info)), starting
end

-- Fills randomization_info.options.cost from all reachable raw material prices
-- (default_cost_table) and major resources (major_raw_resources). A price says
-- nothing about automation; callers use the separate per-room eligibility table.
-- complex_sort_info: a sort of the same graph with complex contexts, for automatability
-- contexts: the logic's contexts (lib/logic/init.lua's logic.contexts), passed in since that module only loads in the game
-- Tables are filled in place, since modules like randomizations/graph/recipe-cost.lua keep references to them
-- Costs a compat file set already are kept
graph_cost.derive_cost_options = function(graph, sort_info, starting_context, complex_sort_info, contexts)
    local cost_options = randomization_info.options.cost
    cost_options.default_cost_table = cost_options.default_cost_table or {}
    cost_options.major_raw_resources = cost_options.major_raw_resources or {}

    local major = cost_options.major_raw_resources
    for i = #major, 1, -1 do
        major[i] = nil
    end
    local built, starting = graph_cost.build_costs(graph, sort_info, starting_context, complex_sort_info, contexts)
    for _, id in pairs(starting) do
        table.insert(major, id)
    end
    context_costs.current = built
    for id, cost in pairs(context_costs.current.raw_costs) do
        if cost_options.default_cost_table[id] == nil then
            cost_options.default_cost_table[id] = cost
        end
    end

    local ids = {}
    for id, _ in pairs(cost_options.default_cost_table) do
        table.insert(ids, id)
    end
    table.sort(ids)
    for _, id in pairs(ids) do
        log("Raw cost " .. id .. " = " .. cost_options.default_cost_table[id])
    end
    log("Major raw resources: " .. table.concat(major, ", "))
end

return graph_cost
