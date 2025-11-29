local categories = require("helper-tables/categories")
local randnum = require("lib/random/randnum")
local randprob = require("lib/random/randprob")
local rng = require("lib/random/rng")
local locale_utils = require("lib/locale")

local randomize = randnum.rand

randomizations.ammo_damage = function(id)
    local function get_targets(tbls, action)
        local targets = randomizations.trigger({}, action, "gather-damage")
        for _, target in pairs(targets) do
            table.insert(tbls, target)
        end

        -- Consider any projectiles that cause further damage
        local projectiles = {}
        for _, projectile in pairs(randomizations.trigger({}, action, "gather-projectiles")) do
            table.insert(projectiles, projectile)
        end
        for _, projectile in pairs(randomizations.trigger({}, action, "gather-artillery-projectiles")) do
            table.insert(projectiles, projectile)
        end
        for _, projectile in pairs(projectiles) do
            local proj_prot = data.raw.projectile[projectile]
            if proj_prot == nil then
                proj_prot = data.raw["artillery-projectile"][projectile]
            end
            -- See if this projectile's been touched for the purposes of this randomization
            if not randomization_info.touched[rng.key({id = id, prototype = proj_prot})] then
                randomization_info.touched[rng.key({id = id, prototype = proj_prot})] = true

                if proj_prot.action ~= nil then
                    get_targets(tbls, proj_prot.action)
                end
                if proj_prot.final_action ~= nil then
                    get_targets(tbls, proj_prot.final_action)
                end
            end
        end
    end

    -- Randomize within ammo categories
    for _, ammo_category in pairs(data.raw["ammo-category"]) do
        local tbls = {}
        local ammo_to_old_damage = {}

        for _, ammo in pairs(data.raw.ammo) do
            if ammo.ammo_type.action ~= nil and ammo.ammo_category == ammo_category.name then
                ammo_to_old_damage[ammo.name] = 0
                local new_targets = {}
                get_targets(new_targets, ammo.ammo_type.action)
                for _, new_target in pairs(new_targets) do
                    -- Just add up damage amounts
                    ammo_to_old_damage[ammo.name] = ammo_to_old_damage[ammo.name] + new_target.amount
                    table.insert(tbls, new_target)
                end
            end
        end

        randomizations.linked({
            id = id,
            tbls = tbls,
            property = "amount",
            range = "small",
            rounding = "discrete_float"
        })

        for _, ammo in pairs(data.raw.ammo) do
            if ammo.ammo_type.action ~= nil and ammo.ammo_category == ammo_category.name then
                -- Just get the targets/damage amounts again
                local new_damage_amount = 0
                local targets = {}
                get_targets(targets, ammo.ammo_type.action)
                for _, target in pairs(targets) do
                    new_damage_amount = new_damage_amount + target.amount
                end

                -- Check that this ammo's damage wasn't 0 just in case it's some special action bullet
                if ammo_to_old_damage[ammo.name] ~= 0 then
                    locale_utils.create_localised_description(ammo, new_damage_amount / ammo_to_old_damage[ammo.name], id)
                end
            end
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
                armor.localised_description = {"", locale_utils.find_localised_description(armor), "\n[color=red](Specialized resistance)[/color]"}
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

-- TODO: Healing amount displayed? Agh
randomizations.capsule_healing = function(id)
    for _, capsule in pairs(data.raw.capsule) do
        local capsule_action = capsule.capsule_action
        if capsule_action.type == "use-on-self" then
            local ammo_type = capsule_action.attack_parameters.ammo_type
            if ammo_type ~= nil then
                if ammo_type.action then
                    randomizations.trigger({
                        id = id,
                        prototype = capsule
                    }, ammo_type.action, "healing")

                    -- Check for stickers
                    for _, sticker in pairs(randomizations.trigger({}, ammo_type.action, "gather-stickers")) do
                        local sticker_prot = data.raw.sticker[sticker]
                        -- Check if we've already randomized this sticker's healing
                        if not randomization_info.touched[rng.key({id = id, prototype = sticker_prot})] then
                            randomization_info.touched[rng.key({id = id, prototype = sticker_prot})] = true

                            if sticker_prot.damage_per_tick ~= nil then
                                if sticker_prot.damage_interval == nil then
                                    sticker_prot.damage_interval = 1
                                end

                                -- Multiply by negative one to make it positive for randomization
                                sticker_prot.damage_per_tick.amount = -sticker_prot.damage_per_tick.amount
                                randomize({
                                    id = id,
                                    prototype = sticker_prot,
                                    tbl = sticker_prot.damage_per_tick,
                                    property = "amount",
                                    rounding = "none"
                                })
                                -- Undo earlier multiplication by -1
                                sticker_prot.damage_per_tick.amount = -sticker_prot.damage_per_tick.amount
                            end
                        end
                    end
                end
            end
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

-- TODO: Fix now that transformers aren't a thing
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

randomizations.item_fuel_value = function(id)
    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
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
    end
end

randomizations.item_stack_sizes = function(id)
    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                if item.stack_size ~= nil and item.stack_size > 1 then
                    local old_stack_size = item.stack_size

                    randomize({
                        id = id,
                        prototype = item,
                        property = "stack_size",
                        range_min = "small",
                        range_max = "big",
                        bias = 0.1,
                        rounding = "discrete"
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