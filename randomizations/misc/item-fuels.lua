local locale_utils = require("lib/locale")
local rng = require("lib/random/rng")
local randbool = require("lib/random/randbool")
local randnum = require("lib/random/randnum")

randomizations.item_fuels = function(id)
    local is_resource_item = {}
    for _, resource in pairs(data.raw.resource) do
        if resource.minable then
            if resource.minable.results ~= nil then
                for _, result in pairs(resource.minable.results) do
                    if result.type == "item" then
                        is_resource_item[result.name] = true
                    end
                end
            else
                is_resource_item[resource.minable.result] = true
            end
        end
    end
    -- Wood is a special burner item and used as a starter fuel, so don't take its fuel value away
    is_resource_item["wood"] = true


    local chemical_fuel_count = 0
    local non_fuel_count = 0
    
    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                if not is_resource_item[item.name] then
                    if item.fuel_category == "chemical" then
                        chemical_fuel_count = chemical_fuel_count + 1
                        if randbool.rand_chaos(id, 0.5) then
                            item.fuel_value = nil
                            item.fuel_acceleration_multiplier = nil
                            item.fuel_top_speed_multiplier = nil
                            item.fuel_glow_color = nil
                            item.fuel_category = nil
                            item._nonreactive = true
                        end
                    elseif item.fuel_category == nil then
                        non_fuel_count = non_fuel_count + 1
                    end
                end
            end
        end
    end

    local fuel_p = chemical_fuel_count / (chemical_fuel_count + non_fuel_count)

    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                if not is_resource_item[item.name] then
                    if item.fuel_category == nil and randbool.rand_bias(id, fuel_p, 1) and randbool.rand_chaos(id, 0.5) then
                        -- actual space age fuel statistics
                        local possible_fuel_values = {
                            "100kJ",
                            "250kJ",
                            "1MJ",
                            "1MJ",
                            "2MJ",
                            "2MJ",
                            "2MJ",
                            "4MJ",
                            "4MJ",
                            "4MJ",
                            "5MJ",
                            "6MJ",
                            "10MJ",
                            "12MJ",
                            "100MJ",
                            "1.21GJ"
                        }
                        item.fuel_value = possible_fuel_values[rng.int(rng.key({id = id}), #possible_fuel_values)]
                        randomizations.energy({
                            id = id,
                            prototype = item,
                            property = "fuel_value",
                            rounding = "discrete_float"
                        })

                        local possible_acceleration_multipliers = {
                            0.5,
                            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                            1.2,
                            1.8,
                            2.5,
                        }
                        item.fuel_acceleration_multiplier = possible_acceleration_multipliers[rng.int(rng.key({id = id}), #possible_acceleration_multipliers)]
                        randnum.rand({
                            id = id,
                            prototype = item,
                            property = "fuel_acceleration_multiplier",
                            rounding = "discrete_float",
                            variance = "small"
                        })

                        local possible_top_speed_multipliers = {
                            0.5,
                            1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                            1.05,
                            1.15,
                            1.15,
                        }
                        item.fuel_top_speed_multiplier = possible_top_speed_multipliers[rng.int(rng.key({id = id}), #possible_top_speed_multipliers)]
                        randnum.rand({
                            id = id,
                            prototype = item,
                            property = "fuel_top_speed_multiplier",
                            rounding = "discrete_float"
                        })

                        item.fuel_category = "chemical"
                        item._nonreactive = nil
                        -- item.localised_name = {"", locale_utils.find_localised_name(item), "\n[color=red](Burnable)[/color]"}
                    end
                    if item.fuel_category == nil and item._nonreactive then
                        item.localised_description = {"", locale_utils.find_localised_description(item), "\n[color=red](Fireproof)[/color]"}
                        item._nonreactive = nil
                    end
                end
                if item.fuel_category == "chemical" then
                    item.localised_description = {"", locale_utils.find_localised_description(item), "\n[color=green](Combustible)[/color]"}
                end
            end
        end
    end
end