local locale_utils = require("lib/locale")
local rng = require("lib/random/rng")

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

    -- Just go over chemical non-resource fuels and randomly toggle them on with 2% chance or off with 30% chance
    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                if not is_resource_item[item.name] then
                    if item.fuel_category == "chemical" then
                        if rng.value(rng.key({id = id})) < 0.3 then
                            item.fuel_value = nil
                            item.fuel_acceleration_multiplier = nil
                            item.fuel_top_speed_multiplier = nil
                            item.fuel_glow_color = nil
                            item.localised_name = {"", locale_utils.find_localised_name(item), "\n[color=red](Nonreactive)[/color]"}
                        end
                    else
                        if rng.value(rng.key({id = id})) < 0.02 then
                            local possible_fuel_values = {
                                "2kJ",
                                "123kJ",
                                "666kJ",
                                "2.3MJ",
                                "5.5MJ",
                                "6.1MJ",
                                "10.1MJ",
                                "31.4MJ",
                                "50MJ",
                                "250MJ",
                                "2.71GJ"
                            }
                            item.fuel_value = possible_fuel_values[rng.int(rng.key({id = id}), #possible_fuel_values)]

                            local possible_acceleration_multipliers = {
                                0,
                                0.1,
                                0.75,
                                1,
                                1,
                                1,
                                1,
                                1.01,
                                1.05,
                                1.2,
                                2.5
                            }
                            item.fuel_acceleration_multiplier = possible_acceleration_multipliers[rng.int(rng.key({id = id}), #possible_acceleration_multipliers)]

                            local possible_top_speed_multipliers = {
                                0.4,
                                0.97,
                                1,
                                1,
                                1,
                                1,
                                1,
                                1.05,
                                1.1,
                                1.25,
                                2
                            }
                            item.fuel_top_speed_multiplier = possible_top_speed_multipliers[rng.int(rng.key({id = id}), #possible_top_speed_multipliers)]

                            item.fuel_category = "chemical"
                            item.localised_name = {"", locale_utils.find_localised_name(item), "\n[color=red](Burnable)[/color]"}
                        end
                    end
                end
            end
        end
    end
end