local categories = require("src/prototypes/categories")
local dutils = require("src/prototypes/data-utils")
local randnum = require("src/lib/random/randnum")
local randprob = require("src/lib/random/randprob")
local randbool = require("src/lib/random/randbool")
local rng = require("src/lib/random/rng")
local locale_utils = require("src/localisation/locale")
local trigger_utils = require("src/prototypes/entities/trigger")

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
            id = id,
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
                rounding = "discrete",
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
            id = id,
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
            id = id,
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

    for _, prototype in pairs(prototypes) do
        randomize({
            id = id,
            prototype = prototype,
            property = "inventory_size_bonus",
            rounding = "discrete",
            variance = "big",
            data_type = "uint16",
        })
    end

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
                        id = id,
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
                        id = id,
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
                armor.localised_description = {"", locale_utils.find_localised_description(armor), {"propertyrandomizer-status.changed-resistance-red"}}
            end
        end
    end
end

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
            id = id,
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
                rounding = "discrete_float",
            })

            locale_utils.create_localised_description(capsule, attack_parameters.range / old_range, id, { variance = "medium" })
        end
    end
end

-- New
-- Not added to spec yet
-- TODO
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
                rounding = "discrete_float",
            })

            gun.attack_parameters.range = gun.attack_parameters.range - old_min_range + gun.attack_parameters.min_range

            local factor = gun.attack_parameters.min_range / old_min_range
            locale_utils.create_localised_description(gun, factor, id, { variance = "medium" })
        end
    end
end

-- Not added to spec yet
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
                rounding = "discrete_float",
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
            rounding = "discrete_float",
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
        if item.fuel_value ~= nil and dutils.has_fuel_category(item, "chemical") then
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
        if item.fuel_value ~= nil and dutils.has_fuel_category(item, "chemical") then
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
                rounding = "discrete_float",
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
                        data_type = "uint32",
                    })

                    locale_utils.create_localised_description(item, item.stack_size / old_stack_size, id)
                end
            end
        end
    end
end

-- TODO: Don't hardcode this?
local rocket_lift_weight = 1000000

-- New
randomizations.item_weights = function(id)
    for item_class, _ in pairs(categories.normal_item_classes) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                if item.subgroup == nil or categories.special_item_subgroups[item.subgroup] == nil and item.weight ~= nil then
                    local key = rng.key({ id = id, property = item })

                    local weight_factor = randomize{
                        key = key,
                        dummy = 1,
                        rounding = "discrete_float",
                    }
                    item.weight = math.min(item.weight / weight_factor, rocket_lift_weight)

                    locale_utils.create_localised_description(item, 1 / weight_factor, id, { flipped = false })
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
            item.localised_description = {"", locale_utils.find_localised_description(item), {"propertyrandomizer-status.neutralized-green"}}
        elseif not had_spawn and now_spawns then
            item.localised_description = {"", locale_utils.find_localised_description(item), {"propertyrandomizer-status.infested-red"}}
        elseif changed then
            item.localised_description = {"", locale_utils.find_localised_description(item), {"propertyrandomizer-status.mutated-spoil-result-red"}}
        end
    end
end

-- New
-- Logic lets an item be delivered to other rooms only if it lasts the trip (dutils.survives_trip), and unified randomization counted on that, so an item that lasted it still has to
-- A roll that drops it below is rolled again (the item's rng key moves on), and after this many the item keeps its spoil time
-- An item that didn't last a trip may start to, which only adds routes
local MAX_SPOIL_TIME_ROLLS = 20

randomizations.spoil_time = function (id)

    local ticks = "ticks"
    local seconds = "seconds"
    local minutes = "minutes"
    local hours = "hours"

    local ticks_per_second = 60
    local seconds_per_minute = 60
    local minutes_per_hour = 60

    local function roll_spoil_ticks(item)
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

        item.spoil_ticks = math.min(math.max(round(item.spoil_ticks), 1), 4000000000)
    end

    for _, item in pairs(items) do
        if item.spoil_ticks ~= nil and item.spoil_ticks > 0 then
            local old_value = item.spoil_ticks
            local survives_trip = dutils.survives_trip(item)

            for _ = 1, MAX_SPOIL_TIME_ROLLS do
                item.spoil_ticks = old_value
                roll_spoil_ticks(item)
                if dutils.survives_trip(item) or not survives_trip then
                    break
                end
            end
            if survives_trip and not dutils.survives_trip(item) then
                item.spoil_ticks = old_value
            end

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
        "repair-tool",
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
