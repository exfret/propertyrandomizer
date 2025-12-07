local categories = require("helper-tables/categories")
local randnum = require("lib/random/randnum")
local randprob = require("lib/random/randprob")
local randbool = require("lib/random/randbool")
local rng = require("lib/random/rng")
local locale_utils = require("lib/locale")
local trigger_utils = require("lib/trigger")

local randomize = randnum.rand

local items = {}
for item_class, _ in pairs(categories.normal_item_classes) do
    if data.raw[item_class] ~= nil then
        for _, item in pairs(data.raw[item_class]) do
            if categories.special_item_subgroups[item.subgroup] == nil then
                items[item.name] = item
            end
        end
    end
end

local round = function (n)
    return math.floor(n + 0.5)
end

local to_array = function (single_or_array)
    if type(single_or_array) ~= "table" or single_or_array[1] == nil then
        return { single_or_array }
    end
    return single_or_array
end

-- New
randomizations.ammo_cooldown_modifier = function(id)
    for _, ammo in pairs(data.raw.ammo) do
        local ammo_types = to_array(ammo.ammo_type)
        for _, ammo_type in pairs(ammo_types) do
            if ammo_type.cooldown_modifier == nil then
                ammo_type.cooldown_modifier = 1
            end

            -- To shooting speed modifier
            ammo_type.cooldown_modifier = 1 / ammo_type.cooldown_modifier

            local old_value = ammo_type.cooldown_modifier

            randomize({
                id = id,
                prototype = ammo,
                tbl = ammo_type,
                property = "cooldown_modifier",
                rounding = "discrete_float",
                variance = "medium",
                dir = 1,
            })

            local factor = ammo_type.cooldown_modifier / old_value
            locale_utils.create_localised_description(ammo, factor, id, { variance = "medium" })

            -- Back to cooldown modifier
            ammo_type.cooldown_modifier = 1 / ammo_type.cooldown_modifier
        end
    end
end

randomizations.ammo_damage = function(id)
    for _, ammo in pairs(data.raw.ammo) do
        local structs = {}
        trigger_utils.gather_ammo_structs(structs, ammo, true)
        local rng_key = rng.key({ id = id, prototype = ammo })
        local factor = randomize({
            key = rng_key,
            dummy = 1,
            variance = "medium",
            rounding = "none",
            dir = 1,
        })
        local changed = false
        local rounding_params = { key = rng_key, rounding = "discrete_float" }

        for _, damage_parameters in pairs(structs["damage-parameters"] or {}) do
            if damage_parameters.amount > 0 then
                damage_parameters.amount = randnum.fixes(rounding_params, damage_parameters.amount * factor)
                changed = true
            end
        end

        if changed then
            locale_utils.create_localised_description(ammo, factor, id)
        end
    end
end

randomizations.ammo_magazine_size = function(id)
    for _, ammo in pairs(data.raw.ammo) do
        -- Don't randomize magazine sizes of 1, they probably don't want to be randomized
        if ammo.magazine_size ~= nil and ammo.magazine_size > 1 then
            local old_magazine_size = ammo.magazine_size

            randomize({
                id = id,
                prototype = ammo,
                property = "magazine_size",
                abs_min = 2,
                range = "small",
                rounding = "discrete"
            })

            locale_utils.create_localised_description(ammo, ammo.magazine_size / old_magazine_size, id)
        end
    end
end

-- New
randomizations.ammo_projectile_count = function(id)
    for _, ammo in pairs(data.raw.ammo) do
        local structs = {}
        trigger_utils.gather_ammo_structs(structs, ammo, true)
        local rng_key = rng.key({ id = id, prototype = ammo })
        local factor = randomize({
            key = rng_key,
            dummy = 1,
            variance = "big",
            rounding = "none",
            dir = 1,
        })
        local changed = false
        local rounding_params = { key = rng_key, rounding = "discrete", abs_min = 2 }

        for _, trigger in pairs(structs["trigger"] or {}) do
            if trigger.repeat_count ~= nil and trigger.repeat_count > 1 then
                trigger.repeat_count = randnum.fixes(rounding_params, trigger.repeat_count * factor)
                changed = true
            end
        end

        if changed then
            locale_utils.create_localised_description(ammo, factor, id, { variance = "big" })
        end
    end
end

-- New
randomizations.ammo_projectile_range = function(id)
    for _, ammo in pairs(data.raw.ammo) do
        local structs = {}
        trigger_utils.gather_ammo_structs(structs, ammo, true)
        local rng_key = rng.key({ id = id, prototype = ammo })
        local factor = randomize({
            key = rng_key,
            dummy = 1,
            variance = "big",
            rounding = "none",
            dir = 1,
        })
        local changed = false
        local rounding_params = { key = rng_key, rounding = "discrete_float" }

        for _, trigger_delivery in pairs(structs["trigger-delivery"] or {}) do
            if trigger_delivery.max_range ~= nil and trigger_delivery.max_range > 0 then
                trigger_delivery.max_range = randnum.fixes(rounding_params, trigger_delivery.max_range * factor)
                changed = true
            end
        end

        if changed then
            locale_utils.create_localised_description(ammo, factor, id, { variance = "big" })
        end
    end
end

-- New
randomizations.ammo_range_modifier = function(id)
    for _, ammo in pairs(data.raw.ammo) do
        local ammo_types = to_array(ammo.ammo_type)
        for _, ammo_type in pairs(ammo_types) do
            if ammo_type.range_modifier == nil then
                ammo_type.range_modifier = 1
            end
            local old_value = ammo_type.range_modifier

            randomize({
                id = id,
                prototype = ammo,
                tbl = ammo_type,
                property = "range_modifier",
                rounding = "discrete_float",
                variance = "small",
                dir = 1,
            })

            local factor = ammo_type.range_modifier / old_value
            locale_utils.create_localised_description(ammo, factor, id, { variance = "small" })
        end
    end
end

randomizations.armor_inventory_bonus = function(id)
    local prototypes = {}
    local armor_to_old_bonus = {}
    for _, armor in pairs(data.raw.armor) do
        if armor.inventory_size_bonus ~= nil and armor.inventory_size_bonus > 0 then
            table.insert(prototypes, armor)
            armor_to_old_bonus[armor.name] = armor.inventory_size_bonus
        end
    end

    randomizations.linked({
        id = id,
        prototypes = prototypes,
        property = "inventory_size_bonus",
        rounding = "discrete",
        variance = "big",
    })

    for _, armor in pairs(data.raw.armor) do
        if armor.inventory_size_bonus ~= nil and armor.inventory_size_bonus > 0 then
            locale_utils.create_localised_description(armor, armor.inventory_size_bonus / armor_to_old_bonus[armor.name], id, { variance = "big" })
        end
    end
end

-- New
-- TODO: Make group randomized with armor
randomizations.armor_resistances = function(id)

    local damage_type_names = {}
    for name, _ in pairs(data.raw["damage-type"]) do
        table.insert(damage_type_names, name)
    end

    for _, armor in pairs(data.raw.armor) do
        if armor.resistances ~= nil then
            local shuffled_damage_type_names = table.deepcopy(damage_type_names)
            local key = rng.key({id = id, prototype = armor})
            rng.shuffle(key, shuffled_damage_type_names)
            local i = 1
            local old_flat_resistance_sum = 0
            local old_p_resistance_sum = 0
            for _, resistance in pairs(armor.resistances) do
                resistance.type = shuffled_damage_type_names[i]
                i = i + 1
                if resistance.decrease ~= nil and resistance.decrease > 0 then
                    old_flat_resistance_sum = old_flat_resistance_sum + resistance.decrease
                    randomize({
                        key = key,
                        prototype = armor,
                        tbl = resistance,
                        property = "decrease",
                        rounding = "discrete_float",
                        variance = "big",
                    })
                end
                if resistance.percent ~= nil and resistance.percent > 0 then
                    old_p_resistance_sum = old_p_resistance_sum + resistance.percent
                    resistance.percent = randprob.rand({
                        key = key,
                        prototype = armor,
                        tbl = resistance,
                        property = "percent",
                        rounding = "discrete_float",
                        variance = "big",
                        probability_scale = 100,
                    })
                end
            end
            if old_flat_resistance_sum + old_p_resistance_sum > 0 then
                armor.localised_description = {"", locale_utils.find_localised_description(armor), "\n[color=red](Botched resistance)[/color]"}
            end
        end
    end
end

-- New
randomizations.capsule_cooldown = function(id)
    for _, capsule in pairs(data.raw.capsule) do
        if capsule.capsule_action.attack_parameters then
            local attack_parameters = capsule.capsule_action.attack_parameters
            local old_value = attack_parameters.cooldown

            -- To attacks per second
            attack_parameters.cooldown = 60 / attack_parameters.cooldown
            randomize({
                id = id,
                prototype = capsule,
                tbl = attack_parameters,
                property = "cooldown",
                rounding = "discrete_float",
                variance = "big",
            })
            -- Back to ticks per attack
            attack_parameters.cooldown = 60 / attack_parameters.cooldown

            local factor = attack_parameters.cooldown / old_value
            locale_utils.create_localised_description(capsule, factor, id, { flipped = true, variance = "big" })
        end
    end
end

randomizations.capsule_healing = function(id)
    for _, capsule in pairs(data.raw.capsule) do
        local structs = {}
        trigger_utils.gather_capsule_structs(structs, capsule, true)
        local rng_key = rng.key({ id = id, prototype = capsule })
        local factor = randomize({
            key = rng_key,
            dummy = 1,
            variance = "big",
            rounding = "none",
            dir = 1,
        })
        local rounding_params = { key = rng_key, rounding = "discrete_float" }
        local changed = false

        for _, damage_parameters in pairs(structs["damage-parameters"] or {}) do
            if damage_parameters.amount < 0 then
                damage_parameters.amount = randnum.fixes(rounding_params, damage_parameters.amount * factor)
                changed = true
            end
        end

        if changed then
            locale_utils.create_localised_description(capsule, factor, id, { variance = "big" })
        end
    end
end

randomizations.capsule_throw_range = function(id)
    for _, capsule in pairs(data.raw.capsule) do
        local capsule_action = capsule.capsule_action
        if capsule_action.type == "throw" or capsule_action.type == "destroy-cliffs" then
            local attack_parameters = capsule_action.attack_parameters

            local old_range = attack_parameters.range

            -- Note that radius visualization circle should be fixed
            -- If not, then yell at CodeGreen
            randomize({
                id = id,
                prototype = capsule,
                tbl = attack_parameters,
                property = "range",
                variance = "medium",
                rounding = "discrete_float"
            })

            locale_utils.create_localised_description(capsule, attack_parameters.range / old_range, id, { variance = "medium" })
        end
    end
end

-- New
randomizations.capsule_throwable_damage = function(id)
    for _, capsule in pairs(data.raw.capsule) do
        local capsule_action = capsule.capsule_action
        -- Cliff explosives don't actually do damage, but technically they still could and are basically just a throwable filtered at cliffs
        if capsule_action.type == "throw" or capsule_action.type == "destroy-cliffs" then
            local attack_parameters = capsule_action.attack_parameters

            -- TODO: Consider whether to have a global table to keep track of whether a projectile's damage was randomized
        end
    end
end

randomizations.gun_damage_modifier = function(id)
    for _, gun in pairs(data.raw.gun) do
        local attack_parameters = gun.attack_parameters

        if attack_parameters.damage_modifier == nil then
            attack_parameters.damage_modifier = 1
        end

        local old_modifier = attack_parameters.damage_modifier

        randomize({
            id = id,
            prototype = gun,
            tbl = attack_parameters,
            property = "damage_modifier",
            range_min = "small",
            rounding = "discrete_float",
            variance = "big",
        })

        locale_utils.create_localised_description(gun, attack_parameters.damage_modifier / old_modifier, id, { variance = "big" })
    end
end

randomizations.gun_minimum_range = function(id)
    for _, gun in pairs(data.raw.gun) do
        if gun.attack_parameters.min_range ~= nil then
            local old_min_range = gun.attack_parameters.min_range

            randomize({
                id = id,
                prototype = gun,
                tbl = gun.attack_parameters,
                property = "min_range",
                variance = "medium",
                rounding = "discrete_float"
            })

            gun.attack_parameters.range = gun.attack_parameters.range - old_min_range + gun.attack_parameters.min_range

            local factor = gun.attack_parameters.min_range / old_min_range
            locale_utils.create_localised_description(gun, factor, id, { variance = "medium" })
        end
    end
end

-- NEW
randomizations.gun_movement_slowdown_factor = function(id)
    for _, gun in pairs(data.raw.gun) do
        local attack_parameters = gun.attack_parameters

        -- This can cause guns to speed you up but that's funny
        if attack_parameters.movement_slow_down_factor ~= nil then
            local old_value = attack_parameters.movement_slow_down_factor
            randomize({
                id = id,
                prototype = gun,
                tbl = attack_parameters,
                property = "movement_slow_down_factor",
                range = "big",
                rounding = "discrete_float"
            })
            local factor = attack_parameters.movement_slow_down_factor / old_value
            locale_utils.create_localised_description(gun, factor, id)
        end
    end
end

randomizations.gun_range = function(id)
    for _, gun in pairs(data.raw.gun) do
        local min_range = 0
        if gun.attack_parameters.min_range ~= nil then
            min_range = gun.attack_parameters.min_range
        end

        local old_range = gun.attack_parameters.range - min_range

        local new_range = randomize({
            key = rng.key({id = id, prototype = gun}),
            dummy = old_range,
            range = "small",
            variance = "medium",
            rounding = "discrete_float"
        })
        gun.attack_parameters.range = new_range + min_range
        local factor = gun.attack_parameters.range / (old_range + min_range)
        locale_utils.create_localised_description(gun, factor, id, { variance = "medium" })
    end
end

randomizations.gun_shooting_speed = function(id)
    for _, gun in pairs(data.raw.gun) do
        local old_shooting_speed = 1 / gun.attack_parameters.cooldown

        -- To attacks per second
        gun.attack_parameters.cooldown = 60 / gun.attack_parameters.cooldown
        randomize({
            id = id,
            prototype = gun,
            tbl = gun.attack_parameters,
            property = "cooldown",
            range = "small",
            rounding = "discrete_float",
            variance = "big",
        })
        -- Back to ticks per attack
        gun.attack_parameters.cooldown = 60 / gun.attack_parameters.cooldown

        local new_shooting_speed = 1 / gun.attack_parameters.cooldown
        locale_utils.create_localised_description(gun, new_shooting_speed / old_shooting_speed, id, { variance = "big" })
    end
end

-- New
randomizations.item_fuel_acceleration = function(id)
    for _, item in pairs(items) do
        -- Change this if vehicles ever use other types of fuel
        if item.fuel_value ~= nil and item.fuel_category == "chemical" then
            if item.fuel_acceleration_multiplier == nil then
                item.fuel_acceleration_multiplier = 1.0
            end

            local old_value = item.fuel_acceleration_multiplier

            randomize({
                id = id,
                prototype = item,
                property = "fuel_acceleration_multiplier",
                rounding = "discrete_float",
                variance = "medium",
                dir = 1,
            })

            local factor = item.fuel_acceleration_multiplier / old_value

            locale_utils.create_localised_description(item, factor, id)
        end
    end
end

-- New
randomizations.item_fuel_top_speed = function(id)
    for _, item in pairs(items) do
        -- Change this if vehicles ever use other types of fuel
        if item.fuel_value ~= nil and item.fuel_category == "chemical" then
            if item.fuel_top_speed_multiplier == nil then
                item.fuel_top_speed_multiplier = 1.0
            end

            local old_value = item.fuel_top_speed_multiplier

            randomize({
                id = id,
                prototype = item,
                property = "fuel_top_speed_multiplier",
                rounding = "discrete_float",
                variance = "big",
                dir = 1,
            })

            local factor = item.fuel_top_speed_multiplier / old_value

            locale_utils.create_localised_description(item, factor, id, { variance = "big" })
        end
    end
end

randomizations.item_fuel_value = function(id)
    for _, item in pairs(items) do
        if item.fuel_value ~= nil then
            local old_fuel_value = util.parse_energy(item.fuel_value)

            randomizations.energy({
                id = id,
                prototype = item,
                property = "fuel_value",
                range = "small",
                rounding = "discrete_float"
            })

            locale_utils.create_localised_description(item, util.parse_energy(item.fuel_value) / old_fuel_value, id)
        end
    end
end

randomizations.item_stack_sizes = function(id)
    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                if item.stack_size ~= nil and item.stack_size >= 2 then
                    local old_stack_size = item.stack_size

                    randomize({
                        id = id,
                        prototype = item,
                        property = "stack_size",
                        range_min = "small",
                        range_max = "big",
                        bias = 0.1,
                        rounding = "discrete",
                        abs_min = 2,
                    })

                    locale_utils.create_localised_description(item, item.stack_size / old_stack_size, id)
                end
            end
        end
    end
end

local rocket_lift_weight = 1000000

-- New
randomizations.item_weights = function(id)
    for item_class, _ in pairs(categories.normal_item_classes) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                if item.subgroup == nil or categories.special_item_subgroups[item.subgroup] == nil then
                    local key = rng.key({ id = id, property = item })

                    local weight_factor = randomize{
                        key = key,
                        dummy = 1,
                        rounding = "discrete_float",
                        dir = -1,
                    }
                    if item.ingredient_to_weight_coefficient == nil then
                        item.ingredient_to_weight_coefficient = 0.5
                    end
                    item.ingredient_to_weight_coefficient = item.ingredient_to_weight_coefficient * weight_factor

                    -- Let's try not to make stuff too heavy for rockets
                    if item.weight ~= nil and item.weight <= rocket_lift_weight then
                        item.weight = math.min(item.weight * weight_factor, rocket_lift_weight)
                    end

                    locale_utils.create_localised_description(item, weight_factor, id, { flipped = true })
                end
            end
        end
    end
end

randomizations.module_effects = function(id)
    local effect_names = {
        "consumption",
        "speed",
        "productivity",
        "pollution",
        "quality"
    }
    -- You have no idea the lengths i went to in order to develop this point system and calculate these stats
    local tier_points = {
        {
            negative_per_cat = -16,
            target_sum = 25
        },
        {
            negative_per_cat = -24,
            target_sum = 40
        },
        {
            negative_per_cat = -32,
            target_sum = 70
        }
    }
    local negative_effect_stats = {
        consumption = {
            name = "consumption",
            value = 0.1,
            points = -10,
            frequency = 6
        },
        speed = {
            name = "speed",
            value = -0.05,
            points = -5,
            frequency = 2
        },
        productivity = {
            name = "productivity",
            value = -0.02,
            points = -22,
            frequency = 4
        },
        pollution = {
            name = "pollution",
            value = 0.01,
            points = -1,
            frequency = 7
        },
        quality = {
            name = "quality",
            value = -0.05,
            points = -8,
            frequency = 3
        }
    }
    local positive_effect_stats = {
        consumption = {
            name = "consumption",
            value = -0.1,
            points = 10,
            frequency = 4
        },
        speed = {
            name = "speed",
            value = 0.1,
            points = 40,
            frequency = 3
        },
        productivity = {
            name = "productivity",
            value = 0.02,
            points = 36,
            frequency = 3
        },
        pollution = {
            name = "pollution",
            value = -0.01,
            points = 2,
            frequency = 5
        },
        quality = {
            name = "quality",
            value = 0.05,
            points = 14,
            frequency = 4
        }
    }

    local random_effect = function (key, effects)
        local total_weight = 0
        for _, effect in pairs(effects) do
            total_weight = total_weight + effect.frequency
        end
        local r = rng.range(key, 0, total_weight - 1)
        for _, effect in pairs(effects) do
            if (effect.frequency > r) then
                return effect
            end
            r = r - effect.frequency
        end
        error("Implementation error")
    end

    local module_categories = {}
    for _, module in pairs(data.raw.module) do
        -- Completely disregard which effects the module previously had
        for _, effect_name in pairs(effect_names) do
            module.effect[effect_name] = 0
        end
        if module_categories[module.category] == nil then
            module_categories[module.category] = {}
        end

        -- Assuming at most 1 module per tier in each category
        module_categories[module.category][module.tier] = module

        -- 
        module.localised_description = {"", locale_utils.find_localised_description(module), "\n[color=red](Reconfigured)[/color]"}
    end
    
    for _, module_category in pairs(module_categories) do
        for tier, module in pairs(module_category) do
            local key = rng.key({id = id, prototype = module})
            local shuffled_effect_names = table.deepcopy(effect_names)
            rng.shuffle(key, shuffled_effect_names)

            -- It's always 1 normally, but not anymore!!
            local positive_effect_count = 1
            positive_effect_count = randomize({
                id = id,
                dummy = positive_effect_count,
                rounding = "discrete",
                dir = -1,
                abs_min = 1,
                abs_max = 5,
                variance = "big",
            })
            local max_negative_effect_count = #effect_names - positive_effect_count

            -- Uniform 0 to 3 negative effect count because that just so happens to be the distribution from space age
            local negative_effect_count = math.min(rng.range(key, 0, 3), max_negative_effect_count)

            -- No coordination between different categories when picking which effects they have
            -- That is to say, modules may have overlapping effects
            -- Also, there may be effects no modules grant
            local target_positive_effects = {}
            local target_negative_effects = {}
            for i = 1, positive_effect_count do
                target_positive_effects[i] = positive_effect_stats[shuffled_effect_names[i]]
            end
            for i = positive_effect_count + 1, positive_effect_count + negative_effect_count do
                target_negative_effects[i - positive_effect_count] = negative_effect_stats[shuffled_effect_names[i]]
            end

            -- Move all of the code above to outside of the module loop to have different tiers of the same module categories to have the same effects

            local negative_target_sum = tier_points[tier].negative_per_cat * negative_effect_count
            local positive_target_sum = tier_points[tier].target_sum - negative_target_sum
            local positive_sum = 0
            while positive_sum < positive_target_sum do
                local effect = random_effect(key, target_positive_effects)
                positive_sum = positive_sum + effect.points
                module.effect[effect.name] = module.effect[effect.name] + effect.value
            end
            local negative_sum = 0
            while negative_sum > negative_target_sum do
                local effect = random_effect(key, target_negative_effects)
                negative_sum = negative_sum + effect.points
                module.effect[effect.name] = module.effect[effect.name] + effect.value
            end

            -- Some somewhat balanced effects should now be set for the module. Let's ruin it :)

            for _, effect in pairs(target_positive_effects) do
                local effect_strength = math.abs(module.effect[effect.name])
                if effect_strength > 0 then
                    effect_strength = randomize({
                        id = id,
                        dummy = effect_strength,
                        rounding = "discrete_float",
                        abs_min = 0.01,
                        abs_max = 327.67,
                        variance = "big",
                    })
                    if module.effect[effect.name] < 0 then
                        effect_strength = 0 - effect_strength
                    end
                    module.effect[effect.name] = effect_strength
                end
            end

            for _, effect in pairs(target_negative_effects) do
                local effect_strength = math.abs(module.effect[effect.name])
                if effect_strength > 0 then
                    effect_strength = randomize({
                        id = id,
                        dummy = effect_strength,
                        rounding = "discrete_float",
                        dir = -1,
                        abs_min = 0.01,
                        abs_max = 327.67,
                        variance = "big",
                    })
                    if module.effect[effect.name] < 0 then
                        effect_strength = 0 - effect_strength
                    end
                    module.effect[effect.name] = effect_strength
                end
            end
        end
    end
end

-- New
randomizations.repair_speed = function(id)
    for _, repair_tool in pairs(data.raw["repair-tool"]) do
        local old_value = repair_tool.speed

        randomize({
            id = id,
            prototype = repair_tool,
            property = "speed",
            rounding = "discrete_float",
        })

        local factor = repair_tool.speed / old_value

        locale_utils.create_localised_description(repair_tool, factor, id)
    end
end

-- New
randomizations.spoil_spawn = function (id)

    -- Chance of considering adding/removing a spoil trigger for an item
    local toggle_spoil_to_trigger_result_p = 0.5

    local spoil_to_trigger_result_pool = {}
    local spoil_ticks_pool = {}
    local item_count = 0

    for _, item in pairs(items) do
        item_count = item_count + 1
        if item.spoil_ticks ~= nil and item.spoil_ticks > 0 then
            table.insert(spoil_ticks_pool, item.spoil_ticks)
            if item.spoil_to_trigger_result ~= nil then
                table.insert(spoil_to_trigger_result_pool, table.deepcopy(item.spoil_to_trigger_result))
            end
        end
    end

    local ratio = #spoil_to_trigger_result_pool / item_count
    local add_p = toggle_spoil_to_trigger_result_p * ratio
    local remove_p = toggle_spoil_to_trigger_result_p * (1 - ratio)

    -- Let's just stick to regular units for now...
    local spawnable_units = {}
    for unit_name, unit in pairs(data.raw["unit"]) do
        if unit.hidden ~= true then
            table.insert(spawnable_units, unit_name)
        end
    end

    for _, item in pairs(items) do
        local had_spawn = item.spoil_to_trigger_result ~= nil
        local rng_key = rng.key({id = id, prototype = item})
        local changed = false
        if had_spawn and randbool.rand_bias_chaos(rng_key, remove_p, 1) then
            item.spoil_to_trigger_result = nil
            if item.spoil_result == nil then
                item.spoil_ticks = nil
            end
        end
        if not had_spawn and randbool.rand_bias_chaos(rng_key, add_p, -1) then
            local spoil_spawn = spoil_to_trigger_result_pool[rng.int(rng_key, #spoil_to_trigger_result_pool)]
            item.spoil_to_trigger_result = table.deepcopy(spoil_spawn)
            if item.spoil_ticks == nil or item.spoil_ticks <= 0 then
                item.spoil_ticks = spoil_ticks_pool[rng.int(rng_key, #spoil_ticks_pool)]
            end
        end
        if item.spoil_to_trigger_result ~= nil then
            local structs = {}
            trigger_utils.gather_item_structs(structs, item, true)
            local entity_mapping = {}
            for _, trigger_effect in pairs(structs["trigger-effect"]) do
                if trigger_effect.entity_name ~= nil then
                    local new_entity_name = entity_mapping[trigger_effect.entity_name]
                    if new_entity_name == nil then
                        new_entity_name = spawnable_units[rng.int(rng_key, #spawnable_units)]
                        entity_mapping[trigger_effect.entity_name] = new_entity_name
                    end
                    trigger_effect.entity_name = new_entity_name
                end
            end
            for from, to in pairs(entity_mapping) do
                if from ~= to then
                    changed = true
                    break
                end
            end
        end
        local now_spawns = item.spoil_to_trigger_result ~= nil
        if had_spawn and not now_spawns then
            item.localised_description = {"", locale_utils.find_localised_description(item), "\n[color=green](Neutralized)[/color]"}
        elseif not had_spawn and now_spawns then
            item.localised_description = {"", locale_utils.find_localised_description(item), "\n[color=red](Infested)[/color]"}
        elseif changed then
            item.localised_description = {"", locale_utils.find_localised_description(item), "\n[color=red](Mutated spoil result)[/color]"}
        end
    end
end

-- New
randomizations.spoil_time = function (id)

    local ticks = "ticks"
    local seconds = "seconds"
    local minutes = "minutes"
    local hours = "hours"

    local ticks_per_second = 60
    local seconds_per_minute = 60
    local minutes_per_hour = 60

    for _, item in pairs(items) do
        if item.spoil_ticks ~= nil and item.spoil_ticks > 0 then
            local old_value = item.spoil_ticks

            local magnitude = ticks
            if item.spoil_ticks > ticks_per_second then
                magnitude = seconds
                item.spoil_ticks = item.spoil_ticks / ticks_per_second
                if item.spoil_ticks > seconds_per_minute then
                    magnitude = minutes
                    item.spoil_ticks = item.spoil_ticks / seconds_per_minute
                    if item.spoil_ticks > minutes_per_hour then
                        magnitude = hours
                        item.spoil_ticks = item.spoil_ticks / minutes_per_hour
                    end
                end
            end

            randomize({
                id = id,
                prototype = item,
                property = "spoil_ticks",
                variance = "medium",
                rounding = "discrete_float",
            })

            if magnitude == seconds then
                item.spoil_ticks = item.spoil_ticks * ticks_per_second
            elseif magnitude == minutes then
                item.spoil_ticks = item.spoil_ticks * ticks_per_second * seconds_per_minute
            elseif magnitude == hours then
                item.spoil_ticks = item.spoil_ticks * ticks_per_second * seconds_per_minute * minutes_per_hour
            end

            item.spoil_ticks = math.max(round(item.spoil_ticks), 1)

            local factor = item.spoil_ticks / old_value

            locale_utils.create_localised_description(item, factor, id)
        end
    end
end

-- New
randomizations.tool_durability = function(id)

    -- Opting to just randomize repair tool durability for now
    local tool_classes = {
        --"tool", "armor",
        "repair-tool"
    }

    for _, class in pairs(tool_classes) do
        for _, tool in pairs(data.raw[class]) do
            if tool.infinite == nil or not tool.infinite then
                local old_value = tool.durability

                -- This could technically give non-integer durabilities to repair tools, but might be fine
                randomize({
                    id = id,
                    prototype = tool,
                    property = "durability",
                    rounding = "discrete_float",
                })

                local factor = tool.durability / old_value

                locale_utils.create_localised_description(tool, factor, id)
            end
        end
    end
end