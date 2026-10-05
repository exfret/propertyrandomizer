-- Parked military/resistance experiment. Installed only by the explicit experimental flag.
local randnum = require("lib/random/randnum")
local rng = require("lib/random/rng")
local locale_utils = require("lib/locale")
local trigger_utils = require("lib/trigger")
local combat_adapters = require("lib/random/combat-adapters")
local randomize = randnum.rand
local to_array = function (single_or_array)
    if type(single_or_array) ~= "table" or single_or_array[1] == nil then
        return { single_or_array }
    end
    return single_or_array
end

local experimental = {}

experimental.ammo_cooldown_modifier = function(id)
    for _, ammo in pairs(data.raw.ammo) do
        local ammo_types = to_array(ammo.ammo_type)
        for _, ammo_type in pairs(ammo_types) do
            local adapter = combat_adapters.reciprocal(ammo_type, "cooldown_modifier", 1, 1)
            local old_value = adapter.read()
            local new_value = randomize({
                id = id,
                prototype = ammo,
                dummy = old_value,
                combat = adapter,
                rounding = "discrete_float",
                variance = "medium",
                dir = 1,
            })

            local factor = new_value / old_value
            locale_utils.create_localised_description(ammo, factor, id, { variance = "medium" })
        end
    end
end

experimental.ammo_damage = function(id)
    for _, ammo in pairs(data.raw.ammo) do
        local structs = {}
        trigger_utils.gather_ammo_structs(structs, ammo, true)
        local rng_key = rng.key({ id = id, prototype = ammo })
        local fields = {}
        for _, packet in pairs(structs["damage-parameters"] or {}) do
            if packet.amount > 0 then
                table.insert(fields, {
                    object = packet,
                    key = "amount",
                })
            end
        end
        local rounding_params = {
            key = rng_key,
            rounding = "discrete_float",
        }
        local factor = randomize({
            id = id,
            key = rng_key,
            dummy = 1,
            combat = combat_adapters.factor(fields, combat_adapters.rounding(rounding_params), "increasing"),
            variance = "medium",
            rounding = "none",
            dir = 1,
        })
        if #fields > 0 then
            locale_utils.create_localised_description(ammo, factor, id)
        end
    end
end

experimental.ammo_projectile_count = function(id)
    for _, ammo in pairs(data.raw.ammo) do
        local structs = {}
        trigger_utils.gather_ammo_structs(structs, ammo, true)
        local rng_key = rng.key({ id = id, prototype = ammo })
        local fields = combat_adapters.fields(structs["trigger"], "repeat_count", function(value) return value > 1 end)
        local rounding_params = {
            key = rng_key,
            rounding = "discrete",
            abs_min = 2,
        }
        local factor = randomize({
            id = id,
            key = rng_key,
            dummy = 1,
            combat = combat_adapters.factor(fields, combat_adapters.rounding(rounding_params), "increasing"),
            variance = "big",
            rounding = "none",
            dir = 1,
        })
        if #fields > 0 then
            locale_utils.create_localised_description(ammo, factor, id, { variance = "big" })
        end
    end
end

experimental.ammo_projectile_range = function(id)
    for _, ammo in pairs(data.raw.ammo) do
        local structs = {}
        trigger_utils.gather_ammo_structs(structs, ammo, true)
        local rng_key = rng.key({ id = id, prototype = ammo })
        local fields = combat_adapters.fields(structs["trigger-delivery"], "max_range")
        local rounding_params = {
            key = rng_key,
            rounding = "discrete_float",
        }
        local factor = randomize({
            id = id,
            key = rng_key,
            dummy = 1,
            combat = combat_adapters.factor(fields, combat_adapters.rounding(rounding_params), false),
            variance = "big",
            rounding = "none",
            dir = 1,
        })
        if #fields > 0 then
            locale_utils.create_localised_description(ammo, factor, id, { variance = "big" })
        end
    end
end

experimental.gun_minimum_range = function(id)
    for _, gun in pairs(data.raw.gun) do
        if gun.attack_parameters.min_range ~= nil then
            local old_min_range = gun.attack_parameters.min_range
            local old_range = gun.attack_parameters.range

            randomize({
                id = id,
                prototype = gun,
                dummy = old_min_range,
                combat = {
                    read = function() return old_min_range end,
                    apply = function(value)
                        gun.attack_parameters.min_range = value
                        gun.attack_parameters.range = old_range - old_min_range + value
                    end,
                    direction = false,
                    fields = {
                        {
                            object = gun.attack_parameters,
                            key = "min_range",
                        },
                        {
                            object = gun.attack_parameters,
                            key = "range",
                        },
                    },
                },
                variance = "medium",
                rounding = "discrete_float",
            })

            local factor = gun.attack_parameters.min_range / old_min_range
            locale_utils.create_localised_description(gun, factor, id, { variance = "medium" })
        end
    end
end

experimental.gun_range = function(id)
    for _, gun in pairs(data.raw.gun) do
        local min_range = 0
        if gun.attack_parameters.min_range ~= nil then
            min_range = gun.attack_parameters.min_range
        end

        local old_range = gun.attack_parameters.range - min_range

        randomize({
            id = id,
            key = rng.key({id = id, prototype = gun}),
            dummy = old_range,
            combat = {
                read = function() return old_range end,
                apply = function(value) gun.attack_parameters.range = value + min_range end,
                direction = false,
                fields = {
                    {
                        object = gun.attack_parameters,
                        key = "range",
                    },
                },
            },
            range = "small",
            variance = "medium",
            rounding = "discrete_float",
        })
        local factor = gun.attack_parameters.range / (old_range + min_range)
        locale_utils.create_localised_description(gun, factor, id, { variance = "medium" })
    end
end

experimental.gun_shooting_speed = function(id)
    for _, gun in pairs(data.raw.gun) do
        local old_shooting_speed = 1 / gun.attack_parameters.cooldown

        local adapter = combat_adapters.reciprocal(gun.attack_parameters, "cooldown", 60)
        randomize({
            id = id,
            prototype = gun,
            dummy = adapter.read(),
            combat = adapter,
            range = "small",
            rounding = "discrete_float",
            variance = "big",
        })
        local new_shooting_speed = 1 / gun.attack_parameters.cooldown
        locale_utils.create_localised_description(gun, new_shooting_speed / old_shooting_speed, id, { variance = "big" })
    end
end

return experimental
