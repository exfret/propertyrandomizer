-- Called between recipe passes by the mod only when this test helper is enabled.
-- Dependencies are passed in so this uses the old randomizer's global pricing model.
local science_costs = {}

science_costs.capture = function(stage, flow_cost, cost_params)
    -- Reprice current recipes on both sides, including regenerated recycling afterward.
    -- Use the same global raw prices and time/complexity charges as the old randomizer.
    local costs = flow_cost.determine_recipe_item_cost(flow_cost.get_default_raw_resource_table(), cost_params.time, cost_params.complexity)
    local seen = {}
    local packs = {}
    for _, lab in pairs(data.raw.lab) do
        for _, pack in pairs(lab.inputs) do
            if not seen[pack] then
                seen[pack] = true
                table.insert(packs, pack)
            end
        end
    end
    table.sort(packs)
    for _, pack in pairs(packs) do
        local id = "item-" .. pack
        local price = costs.material_to_cost[id]
        log("SCIENCECOST\t" .. stage .. "\t" .. pack .. "\t" .. (price == nil and "unpriced" or string.format("%.17g", price)))
    end
end

return science_costs
