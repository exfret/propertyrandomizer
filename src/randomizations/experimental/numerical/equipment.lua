-- Parked military/resistance experiment. Installed only by the explicit experimental flag.
local categories = require("src/prototypes/categories")
local randnum = require("src/lib/random/randnum")
local rng = require("src/lib/random/rng")
local locale_utils = require("src/localisation/locale")
local trigger_utils = require("src/prototypes/entities/trigger")
local combat_adapters = require("src/lib/random/combat-adapters")
local randomize = randnum.rand

local experimental = {}

experimental.equipment_active_defense_cooldown = function(id)
    for _, equipment in pairs(data.raw["active-defense-equipment"]) do
        local old_value = equipment.attack_parameters.cooldown
        local adapter = combat_adapters.reciprocal(equipment.attack_parameters, "cooldown", 60)
        randomize({
            id = id,
            prototype = equipment,
            dummy = adapter.read(),
            combat = adapter,
            rounding = "discrete_float",
            variance = "big",
        })
        local factor = equipment.attack_parameters.cooldown / old_value
        locale_utils.create_localised_description(equipment, factor, id, {flipped = true, variance = "big"})
    end
end

experimental.equipment_active_defense_effect_radius = function (id)
    for _, equipment in pairs(data.raw["active-defense-equipment"]) do
        local structs = {}
        trigger_utils.gather_active_defense_equipment_structs(structs, equipment, true)
        local rng_key = rng.key({ id = id, prototype = equipment })
        local fields = combat_adapters.fields(structs["trigger"], "radius")
        local rounded = combat_adapters.rounding({
            key = rng_key,
            rounding = "discrete_float",
        })
        local factor = randomize({
            id = id,
            key = rng_key,
            dummy = 1,
            combat = combat_adapters.factor(fields, rounded, false),
            rounding = "none",
            variance = "medium",
        })
        if #fields > 0 then
            locale_utils.create_localised_description(equipment, factor, id, { variance = "medium" })
        end
    end
end

experimental.equipment_energy_usage = function(id)
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

            -- Check to see if there was anything with energy worth scaling
            if equipment[energy_properties[1]] ~= nil then
                local old_first_energy_val = util.parse_energy(equipment[energy_properties[1]])
                local fields = {}
                for index, property in pairs(energy_properties) do
                    table.insert(fields, {
                        object = equipment,
                        key = property,
                        multiplier = ind_to_is_power[index] and 60 or 1,
                        suffix = ind_to_is_power[index] and "W" or "J",
                        rounded = false,
                    })
                end
                if equipment.energy_source ~= nil and equipment.energy_source.buffer_capacity ~= nil then
                    table.insert(fields, {
                        object = equipment.energy_source,
                        key = "buffer_capacity",
                        rounded = false,
                    })
                end
                local adapter = combat_adapters.energy(fields)
                randomize({
                    id = id,
                    prototype = equipment,
                    dummy = adapter.read(),
                    combat = adapter,
                    dir = -1,
                    rounding = "discrete_float",
                    variance = "big",
                })
                local factor = util.parse_energy(equipment[energy_properties[1]]) / old_first_energy_val
                locale_utils.create_localised_description(equipment, factor, id, {flipped = true, variance = "big"})
            end
        end
    end

    -- Special handling for active defense equipment
    for _, equipment in pairs(data.raw["active-defense-equipment"]) do
        local attack_parameters = equipment.attack_parameters
        if attack_parameters.ammo_type ~= nil then
            if attack_parameters.ammo_type.energy_consumption ~= nil then
                local old_energy_consumption = util.parse_energy(equipment.attack_parameters.ammo_type.energy_consumption)

                randomizations.energy({
                    id = id,
                    prototype = equipment,
                    tbl = attack_parameters.ammo_type,
                    property = "energy_consumption",
                    dir = -1,
                    rounding = "discrete_float",
                    variance = "big",
                })

                locale_utils.create_localised_description(equipment, util.parse_energy(equipment.attack_parameters.ammo_type.energy_consumption) / old_energy_consumption, id, {flipped = true, variance = "big"})
            end
        end
    end

    -- Special handling for energy shield equipment
    for _, equipment in pairs(data.raw["energy-shield-equipment"]) do
        if equipment.energy_source.input_flow_limit ~= nil then
            local old_value = util.parse_energy(equipment.energy_source.input_flow_limit)

            randomizations.energy({
                is_power = true,
                id = id,
                prototype = equipment,
                tbl = equipment.energy_source,
                property = "input_flow_limit",
                dir = 1,
                rounding = "discrete_float",
                variance = "big",
            })

            local factor = util.parse_energy(equipment.energy_source.input_flow_limit) / old_value

            locale_utils.create_localised_description(equipment, factor, id, { variance = "big" })
        end
    end
end

return experimental
