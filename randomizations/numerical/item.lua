local categories = require("helper-tables/categories")
local randnum = require("lib/random/randnum")
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
            variance = "small"
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
                    ammo.localised_description = locale_utils.create_localised_description(ammo, new_damage_amount / ammo_to_old_damage[ammo.name], id)
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
                variance = "small",
                rounding = "discrete"
            })

            ammo.localised_description = locale_utils.create_localised_description(ammo, ammo.magazine_size / old_magazine_size, id)
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
        property = "inventory_size_bonus"
    })

    for _, armor in pairs(data.raw.armor) do
        if armor.inventory_size_bonus ~= nil and armor.inventory_size_bonus > 0 then
            armor.localised_description = locale_utils.create_localised_description(armor, armor.inventory_size_bonus / armor_to_old_bonus[armor.name], id)
        end
    end
end

-- New
-- TODO: Make group randomized with armor
randomizations.armor_resistances_decrease = function(id)
    for _, armor in pairs(data.raw.armor) do
        if armor.resistances ~= nil then
            for _, resistance in pairs(armor.resistances) do
                randomize({
                    id = id,
                    prototype = armor,
                    tbl = resistance,
                    property = "decrease",
                    range = "very_small",
                    variance = "small"
                })
            end
        end
    end
end

-- New
randomizations.capsule_cooldown = function(id)
    for _, capsule in pairs(data.raw.capsule) do
        if capsule.capsule_action.attack_parameters then
            local attack_parameters = capsule.capsule_action.attack_parameters

            -- Rounding will be off but that's okay
            randomize({
                id = id,
                prototype = capsule,
                tbl = attack_parameters,
                property = "cooldown",
                rounding = "none",
                dir = -1
            })

            -- TODO: Inverse rounding?
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
                property = "range"
            })

            capsule.localised_description = locale_utils.create_localised_description(capsule, attack_parameters.range / old_range, id)
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
            range_min = "small"
        })

        gun.localised_description = locale_utils.create_localised_description(gun, attack_parameters.damage_modifier / old_modifier, id)
    end
end

-- TODO: Fix now that transformers aren't a thing
-- NEW
randomizations.gun_movement_slowdown_factor = function(id)
    for _, gun in pairs(data.raw.gun) do
        local attack_parameters = gun.attack_parameters

        -- This can cause guns to speed you up but that's funny
        if attack_parameters.movement_slow_down_factor ~= nil then
            randomize({
                id = id,
                prototype = gun,
                tbl = attack_parameters,
                property = "movement_slow_down_factor",
                range = "big",
                variance = "big"
            })
        end
    end
end

randomizations.gun_range = function(id)
    for _, gun in pairs(data.raw.gun) do
        local old_range = gun.attack_parameters.range

        randomize({
            id = id,
            prototype = gun,
            tbl = gun.attack_parameters,
            property = "range",
            range = "small",
            variance = "small"
        })

        gun.localised_description = locale_utils.create_localised_description(gun, gun.attack_parameters.range / old_range, id)
    end
end

randomizations.gun_shooting_speed = function(id)
    for _, gun in pairs(data.raw.gun) do
        local old_shooting_speed = 1 / gun.attack_parameters.cooldown

        randomize({
            id = id,
            prototype = gun,
            tbl = gun.attack_parameters,
            property = "cooldown",
            range = "small",
            variance = "small",
            dir = -1,
            rounding = "none"
        })

        local new_shooting_speed = 1 / gun.attack_parameters.cooldown
        gun.localised_description = locale_utils.create_localised_description(gun, new_shooting_speed / old_shooting_speed, id)
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
                        variance = "small"
                    })

                    item.localised_description = locale_utils.create_localised_description(item, util.parse_energy(item.fuel_value) / old_fuel_value, id)
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
                        variance = "big",
                        bias = 0.1,
                        rounding = "discrete"
                    })

                    item.localised_description = locale_utils.create_localised_description(item, item.stack_size / old_stack_size, id)
                end
            end
        end
    end
end

-- TODO: Make work with negatives!
randomizations.module_effects = function(id)
    local cat_to_modules = {}
    local module_to_old_effects = {}
    for _, module in pairs(data.raw.module) do
        -- Populate effects
        local effects = {
            consumption = true,
            speed = true,
            productivity = true,
            pollution = true,
            quality = true
        }

        for effect, _ in pairs(effects) do
            if module.effect[effect] == nil then
                module.effect[effect] = 0
            end
        end

        module_to_old_effects[module.name] = table.deepcopy(module.effect)

        local sign

        sign = 1
        if module.effect.consumption < 0 then
            sign = -1
            module.effect.consumption = -1 * module.effect.consumption
        end
        randomize({
            id = id,
            prototype = module,
            tbl = module.effect,
            property = "consumption",
            range = "small",
            variance = "small",
            dir = -1 * sign
        })
        module.effect.consumption = sign * module.effect.consumption

        sign = 1
        if module.effect.speed < 0 then
            sign = -1
            module.effect.speed = -1 * module.effect.speed
        end
        randomize({
            id = id,
            prototype = module,
            tbl = module.effect,
            property = "speed",
            range = "small",
            variance = "small",
            dir = sign
        })
        module.effect.speed = sign * module.effect.speed

        sign = 1
        if module.effect.productivity < 0 then
            sign = -1
            module.effect.productivity = -1 * module.effect.productivity
        end
        randomize({
            id = id,
            prototype = module,
            tbl = module.effect,
            property = "productivity",
            range = "very_small",
            variance = "very_small",
            dir = sign
        })
        module.effect.productivity = sign * module.effect.productivity

        sign = 1
        if module.effect.pollution < 0 then
            sign = -1
            module.effect.pollution = -1 * module.effect.pollution
        end
        randomize({
            id = id,
            prototype = module,
            tbl = module.effect,
            property = "pollution",
            range = "small",
            variance = "small",
            dir = -1 * sign
        })
        module.effect.pollution = sign * module.effect.pollution

        sign = 1
        if module.effect.quality < 0 then
            sign = -1
            module.effect.quality = -1 * module.effect.quality
        end
        randomize({
            id = id,
            prototype = module,
            tbl = module.effect,
            property = "quality",
            range = "very_small",
            variance = "very_small",
            dir = sign
        })
        module.effect.quality = sign * module.effect.quality

        -- Add to cat_to_modules
        if cat_to_modules[module.category] == nil then
            cat_to_modules[module.category] = {}
        end
        table.insert(cat_to_modules[module.category], module)
    end

    local function sort_modules_tier(module1, module2)
        return module1.tier < module2.tier
    end

    for module_cat, module_tbl in pairs(cat_to_modules) do
        local prop_to_use
        local sign = 1
        if module_cat == "efficiency" then
            sign = -1
            prop_to_use = "consumption"
        elseif module_cat == "speed" then
            prop_to_use = "speed"
        elseif module_cat == "productivity" then
            prop_to_use = "productivity"
        elseif module_cat == "quality" then
            prop_to_use = "quality"
        end

        -- Don't sort modded module categories for now
        if prop_to_use ~= nil then
            local sort_modules_property = function(module1, module2) return sign * module1.effect[prop_to_use] < sign * module2.effect[prop_to_use] end

            local sorted_tiers = table.deepcopy(cat_to_modules[module_cat])
            table.sort(sorted_tiers, sort_modules_tier)
            local sorted_effects = table.deepcopy(module_tbl)
            table.sort(sorted_effects, sort_modules_property)

            for ind, module in pairs(sorted_tiers) do
                -- Need to go into data.raw here because sorted_tiers is a deep clone
                data.raw.module[module.name].effect[prop_to_use] = sorted_effects[ind].effect[prop_to_use]
            end
        end
    end

    -- Update localised_description
    for _, module in pairs(data.raw.module) do
        for effect_name, effect_val in pairs(module.effect) do
            local flipped = false
            if effect_name == "consumption" or effect_name == "pollution" then
                flipped = true
            end
            local normalizing_factor = 1
            -- The game treats quality effects as actually being divided by 10
            if effect_name == "quality" then
                normalizing_factor = 0.1
            end
            module.localised_description = locale_utils.create_localised_description(module, (1 + normalizing_factor * (effect_val - module_to_old_effects[module.name][effect_name])), id, {addons = " " .. effect_name .. " (additive)", flipped = flipped, round_more = true})
        end
    end
end