-- Resource products are graph-only positions in first pass, sharing physical identities but choosing them independently.

local gutils = require("lib/graph/graph-utils")
local item_fluid = require("lib/item-fluid")
local locale = require("lib/locale")
local mining_slots = require("randomizations/graph/unified/handler-helpers/mining-slots")
local dutils = require("lib/data-utils")
local base_costs = require("lib/cost/material-costs/sa")
local py_costs = require("lib/cost/material-costs/py-full")

local material_costs = base_costs
if mods["pypostprocessing"] then
    material_costs = py_costs
end

local mining = {}
mining.id = "mining_results"
mining.with_replacement = false
local outputs = {}

mining.initialize = function()
    outputs = {}
end

mining.spoof = mining_slots.spoof
-- First pass owns these positions, so no mining-source edges are claimed by the later prerequisite shuffle.
mining.claim = function() end
mining.validate = false

mining.custom_prereq_search = function(params)
    local graph = params.split_graph
    if graph == nil then
        return
    end
    local count = 0
    for slot_key, trav_key in pairs(params.slot_to_trav or {}) do
        local source = graph.nodes[slot_key].mining_slot
        if source ~= nil then
            local material = item_fluid.material_of_node(graph, graph.nodes[trav_key])
            material.multiplier = item_fluid.form_multiplier(params, slot_key, trav_key, material_costs.costs)
            if material.type == "fluid" and material.temperature == nil then
                local original_slot = graph.nodes[graph.nodes[trav_key].old_slot]
                material.temperature = tonumber(gutils.deconstruct(original_slot.name).name)
            end
            outputs[source.resource_name] = outputs[source.resource_name] or {}
            for index, _ in pairs(source.inds or { [1] = true }) do
                outputs[source.resource_name][index] = table.deepcopy(material)
            end
            count = count + 1
        end
    end
    log("Mining results: " .. count .. " independent deposit slots assigned by item randomization")
end

mining.manages_result = function(resource_name, index)
    return (outputs[resource_name] or {})[index] ~= nil
end

-- Write the identities directly; item reflection leaves these individual results alone.
mining.reflect = function()
    for resource_name, results in pairs(outputs) do
        local resource = data.raw.resource[resource_name]
        local original = table.deepcopy(resource.minable)
        for index, material in pairs(results) do
            if original.results ~= nil then
                local result = item_fluid.retarget_entry(original.results[index], material, material.multiplier)
                if material.type == "fluid" then
                    result.temperature = material.temperature
                end
                if original.results[index].type == "fluid" and material.type == "item" and not dutils.is_stackable(item_fluid.prot(material)) then
                    if result.amount ~= nil then result.amount = 1 end
                    if result.amount_min ~= nil then result.amount_min = 1 end
                    if result.amount_max ~= nil then result.amount_max = 1 end
                end
                resource.minable.results[index] = result
            elseif material.type == "item" then
                resource.minable.result = material.name
            else
                resource.minable.result = nil
                resource.minable.count = nil
                resource.minable.results = { item_fluid.retarget_entry({ type = "item", name = original.result, amount = original.count or 1 }, material, material.multiplier) }
            end
            log("Mining result: " .. resource_name .. " -> " .. material.type .. ": " .. material.name)
        end
    end
end

mining.after_changes = function()
    for resource_name, _ in pairs(outputs) do
        local resource = data.raw.resource[resource_name]
        local result
        if resource.minable.results ~= nil and #resource.minable.results == 1 then
            result = resource.minable.results[1]
        elseif resource.minable.results == nil then
            result = { name = resource.minable.result }
        end
        if result ~= nil then
            local prototype = item_fluid.prot(result)
            if prototype ~= nil then
                resource.localised_name = locale.find_localised_name(prototype)
                resource.icon = prototype.icon
                resource.icon_size = prototype.icon_size
                resource.icons = table.deepcopy(prototype.icons)
                local icon = prototype.icon or (prototype.icons or {})[1]
                local icon_size = prototype.icon_size or 64
                if type(icon) == "table" then
                    icon_size = icon.icon_size or icon_size
                    icon = icon.icon
                end
                if icon ~= nil then
                    -- The same icon sprites ordinary item reflection uses for a single-product resource.
                    local sheets = {}
                    for _, sprite in pairs({
                        {
                            scale = 0.35,
                            shift = {
                                0.2,
                                0.6,
                            },
                        },
                        {
                            scale = 0.25,
                            shift = {
                                -0.5,
                                0.2,
                            },
                        },
                        {
                            scale = 0.45,
                            shift = {
                                0,
                                0,
                            },
                        },
                        {
                            scale = 0.4,
                            shift = {
                                -0.2,
                                -0.6,
                            },
                        },
                    }) do
                        sprite.variation_count = 1
                        sprite.filename = icon
                        sprite.size = icon_size
                        table.insert(sheets, sprite)
                    end
                    resource.stages = { sheets = sheets }
                    if resource.stage_counts ~= nil then
                        resource.stage_counts = { resource.stage_counts[1] }
                    end
                    resource.stages_effect = nil
                end
            end
        end
    end
end

return mining
