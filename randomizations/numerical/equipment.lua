local categories = require("helper-tables/categories")
local randnum = require("lib/random/randnum")

local randomize = randnum.rand

randomizations.equipment_active_defense_cooldown = function(id)
    for _, equipment in pairs(data.raw["active-defense-equipment"]) do
        -- Rounding will be off but that's okay
        randomize({
            id = id,
            prototoype = equipment,
            tbl = equipment.attack_parameters,
            property = "cooldown",
            rounding = "none"
        })
    end
end

randomizations.equipment_active_defense_damage = function(id)
    for _, equipment in pairs(data.raw["active-defense-equipment"]) do
        local attack_parameters = equipment.attack_parameters

        -- Easiest to just modify the attack damage modifier
        if attack_parameters.damage_modifier == nil then
            attack_parameters.damage_modifier = 1
        end

        randomize({
            id = id,
            prototype = equipment,
            tbl = attack_parameters,
            property = "damage_modifier"
        })
    end
end

randomizations.equipment_active_defense_range = function(id)
    for _, equipment in pairs(data.raw["active-defense-equipment"]) do
        randomize({
            id = id,
            prototype = equipment,
            tbl = equipment.attack_parameters,
            property = "range"
        })
    end
end

-- Linked randomization
randomizations.equipment_battery_buffer = function(id)
    -- Spoof a fake property for linked randomization
    local battery_equipments = {}
    for _, equipment in pairs(data.raw["battery-equipment"]) do
        if equipment.energy_source.buffer_capacity ~= nil then
            table.insert(battery_equipments, equipment)
            equipment.buffer_capacity_as_num = util.parse_energy(equipment.energy_source.buffer_capacity)
        end
    end

    randomizations.linked({
        id = id,
        prototypes = battery_equipments,
        property = "buffer_capacity_as_num",
        range = "small",
        variance = "small"
    })

    for _, equipment in pairs(battery_equipments) do
        equipment.energy_source.buffer_capacity = equipment.buffer_capacity_as_num .. "J"
        equipment.buffer_capacity_as_num = nil
    end
end

randomizations.equipment_battery_input_limit = function(id)
    for _, equipment in pairs(data.raw["battery-equipment"]) do
        if equipment.energy_source.input_flow_limit ~= nil then
            randomizations.energy({
                is_power = true,
                id = id,
                prototype = equipment,
                tbl = equipment.energy_source,
                property = "input_flow_limit",
                range = "small",
                variance = "small"
            })
        end
    end
end

randomizations.equipment_battery_output_limit = function(id)
    for _, equipment in pairs(data.raw["battery-equipment"]) do
        if equipment.energy_source.output_flow_limit ~= nil then
            randomizations.energy({
                is_power = true,
                id = id,
                prototype = equipment,
                tbl = equipment.energy_source,
                property = "output_flow_limit",
                range = "small",
                variance = "small"
            })
        end
    end
end

randomizations.equipment_energy_usage = function(id)
    -- Note: Copied from entity's energy usage function
    -- This is a bit overkill but I already had the code
    for equipment_class, energy_keys in pairs(categories.equipment_energy_usage_keys) do
        for _, equipment in pairs(data.raw[equipment_class]) do
            local energy_properties = {}
            local ind_to_is_power = {}
            for energy_key, energy_or_power in pairs(energy_keys) do
                if equipment[energy_key] ~= nil and util.parse_energy(equipment[energy_key]) > 0 then
                    table.insert(energy_properties, energy_key)
                    if energy_or_power == "power" then
                        table.insert(ind_to_is_power, true)
                    elseif energy_or_power == "energy" then
                        table.insert(ind_to_is_power, false)
                    else
                        -- In this case, I made a typo
                        error()
                    end
                end
            end

            -- is_power scaling doesn't matter since we're going to just see proportion scaling
            local old_first_energy_val = util.parse_energy(equipment[energy_properties[1]])

            randomizations.energy({
                is_power = ind_to_is_power[1],
                id = id,
                prototype = equipment,
                property = energy_properties[1]
            })

            local new_first_energy_val = util.parse_energy(equipment[energy_properties[1]])

            -- Scale all energy vals up the same way
            for i = 2, #energy_properties do
                local curr_energy_val = util.parse_energy(equipment[energy_properties[i]])
                local suffix = "J"
                if ind_to_is_power[i] then
                    curr_energy_val = 60 * curr_energy_val
                    suffix = "W"
                end
                curr_energy_val = curr_energy_val * new_first_energy_val / old_first_energy_val
                equipment[energy_properties[i]] = curr_energy_val .. suffix
            end
        end
    end

    -- Special handling for active defense equipment
    for _, equipment in pairs(data.raw["active-defense-equipment"]) do
        local attack_parameters = equipment.attack_parameters
        if attack_parameters.ammo_type ~= nil then
            if attack_parameters.ammo_type.energy_consumption ~= nil then
                randomizations.energy({
                    id = id,
                    prototype = equipment,
                    tbl = attack_parameters.ammo_type,
                    property = "energy_consumption"
                })
            end
        end
    end
end

randomizations.equipment_generator_power = function(id)
    for _, equipment in pairs(data.raw["generator-equipment"]) do
        randomizations.energy({
            is_power = true,
            id = id,
            prototype = equipment,
            property = "power",
            range = "small",
            variance = "small"
        })
    end
end

randomizations.equipment_movement_bonus = function(id)
    for _, equipment in pairs(data.raw["movement-bonus-equipment"]) do
        randomize({
            id = id,
            prototype = equipment,
            property = "movement_bonus",
            range_min = "small",
            range_max = "big"
        })
    end
end

randomizations.equipment_personal_roboport_charging_speed = function(id)
    for _, equipment in pairs(data.raw["roboport-equipment"]) do
        randomizations.energy({
            is_power = true,
            id = id,
            prototype = equipment,
            property = "charging_energy",
            range = "small",
            variance = "small"
        })
    end
end

randomizations.equipment_personal_roboport_charging_station_count = function(id)
    for _, equipment in pairs(data.raw["roboport-equipment"]) do
        if equipment.charging_station_count == nil or equipment.charging_station_count == 0 then
            if equipment.charging_offsets ~= nil then
                equipment.charging_station_count = #equipment.charging_offsets
            else
                equipment.charging_station_count = 0
            end
        end

        if equipment.charging_station_count ~= 0 then
            randomize({
                id = id,
                prototype = equipment,
                property = "charging_station_count",
                -- Don't randomize if there's only one station, and don't randomize down to one station if there are more
                abs_min = 2,
                range = "small",
                variance = "small",
                rounding = "discrete"
            })
        end
    end
end

randomizations.equipment_personal_roboport_construction_radius = function(id)
    local roboports = {}
    for _, equipment in pairs(data.raw["roboport-equipment"]) do
        table.insert(roboports, equipment)
    end

    randomizations.linked({
        id = id,
        prototypes = roboports,
        property = "construction_radius",
        range = "small",
        variance = "small",
        rounding = "discrete"
    })
end

randomizations.equipment_personal_roboport_max_robots = function(id)
    local roboports = {}
    for _, equipment in pairs(data.raw["roboport-equipment"]) do
        if equipment.robot_limit ~= nil then
            table.insert(roboports, equipment)
        end
    end

    randomizations.linked({
        id = id,
        prototypes = roboports,
        property = "robot_limit",
        range = "small",
        variance = "small",
        rounding = "discrete"
    })
end

randomizations.equipment_solar_panel_production = function(id)
    for _, equipment in pairs(data.raw["solar-panel-equipment"]) do
        if equipment.power ~= nil then
            randomizations.energy({
                is_power = true,
                id = id,
                prototype = equipment,
                property = "power",
                range = "small",
                variance = "small"
            })
        end
    end
end