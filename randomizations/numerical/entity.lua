local categories = require("helper-tables/categories")
local randnum = require("lib/random/randnum")
local randprob = require("lib/random/randprob")
local randbool = require("lib/random/randbool")
local rng = require("lib/random/rng")
local locale_utils = require("lib/locale")
local trigger_utils = require("lib/trigger")

local randomize = randnum.rand

local get_collision_radius = function(entity)
    return math.ceil(entity.collision_box[2][1] - entity.collision_box[1][1]) / 2
end

local round = function (n)
    return math.floor(n + 0.5)
end

local get_allowed_effects = function (entity)
    local class = entity.type
    local prototype_mining_drill = "mining-drill"
    local prototype_lab = "lab"
    local crafting_machine_prototypes = {
        ["assembling-machine"] = true,
        ["rocket-silo"] = true,
        ["furnace"] = true,
    }
    local no_quality_recipe_categories = {
        ["oil-processing"] = true,
        ["rocket-building"] = true,
    }
    if crafting_machine_prototypes[class] ~= nil then
        local allowed_effects = { "speed", "consumption", "pollution" }
        local productivity = true
        local quality = true
        for _, crafting_category in pairs(entity.crafting_categories) do
            if crafting_category == "recycling" then
                productivity = false
            end
            if no_quality_recipe_categories[crafting_category] ~= nil then
                quality = false
            end
        end
        if productivity then
            table.insert(allowed_effects, "productivity")
        end
        if quality then
            table.insert(allowed_effects, "quality")
        end
        return allowed_effects
    elseif class == prototype_lab then
        return { "speed", "productivity", "consumption", "pollution" }
    elseif class == prototype_mining_drill then
        local fluid = false
        for _, resource_category in pairs(entity.resource_categories) do
            if resource_category == "basic-fluid" then
                fluid = true
            end
        end
        if fluid then
            return { "speed", "productivity", "consumption", "pollution" }
        else
            return { "speed", "productivity", "consumption", "pollution", "quality" }
        end
    end
end

local to_unit_time = function (ticks)

    local ticks_unit = "ticks"
    local seconds = "seconds"
    local minutes = "minutes"
    local hours = "hours"

    local ticks_per_second = 60
    local seconds_per_minute = 60
    local minutes_per_hour = 60
    local unit = ticks_unit
    local time = ticks

    if time > ticks_per_second then
        unit = seconds
        time = time / ticks_per_second
        if time > seconds_per_minute then
            unit = minutes
            time = time / seconds_per_minute
            if time > minutes_per_hour then
                unit = hours
                time = time / minutes_per_hour
            end
        end
    end

    return { unit = unit, value = time }
end

local to_ticks = function (unit, value)

    local ticks_unit = "ticks"
    local seconds = "seconds"
    local minutes = "minutes"
    local hours = "hours"

    local ticks_per_second = 60
    local seconds_per_minute = 60
    local minutes_per_hour = 60

    if unit == seconds then
        value = value * ticks_per_second
    elseif unit == minutes then
        value = value * ticks_per_second * seconds_per_minute
    elseif unit == hours then
        value = value * ticks_per_second * seconds_per_minute * minutes_per_hour
    end

    return math.max(round(value), 1)
end

randomizations.accumulator_buffer = function(id)
    for _, accumulator in pairs(data.raw.accumulator) do
        if accumulator.energy_source.buffer_capacity ~= nil then
            local old_buffer_capacity = util.parse_energy(accumulator.energy_source.buffer_capacity)
            
            randomizations.energy({
                id = id,
                prototype = accumulator,
                tbl = accumulator.energy_source,
                property = "buffer_capacity",
                rounding = "discrete_float",
                variance = "big",
            })

            local factor = util.parse_energy(accumulator.energy_source.buffer_capacity) / old_buffer_capacity
            locale_utils.create_localised_description(accumulator, factor, id, { variance = "big" })
        end
    end
end

randomizations.accumulator_input_flow = function(id)
    for _, accumulator in pairs(data.raw.accumulator) do
        if accumulator.energy_source.input_flow_limit ~= nil then
            local old_value = util.parse_energy(accumulator.energy_source.input_flow_limit)
            randomizations.energy({
                is_power = true,
                id = id,
                prototype = accumulator,
                tbl = accumulator.energy_source,
                property = "input_flow_limit",
                rounding = "discrete_float",
                variance = "big",
            })
            local factor = util.parse_energy(accumulator.energy_source.input_flow_limit) / old_value
            locale_utils.create_localised_description(accumulator, factor, id, { variance = "big" })
        end
    end
end

randomizations.accumulator_output_flow = function(id)
    for _, accumulator in pairs(data.raw.accumulator) do
        if accumulator.energy_source.output_flow_limit ~= nil then
            local old_value = util.parse_energy(accumulator.energy_source.output_flow_limit)
            randomizations.energy({
                is_power = true,
                id = id,
                prototype = accumulator,
                tbl = accumulator.energy_source,
                property = "output_flow_limit",
                rounding = "discrete_float",
                variance = "big",
            })
            local factor = util.parse_energy(accumulator.energy_source.output_flow_limit) / old_value
            locale_utils.create_localised_description(accumulator, factor, id, { variance = "big" })
        end
    end
end

-- New
randomizations.agricultural_tower_radius = function(id)
    if data.raw["agricultural-tower"] ~= nil then
        for _, ag_tower in pairs(data.raw["agricultural-tower"]) do
            local old_value = ag_tower.radius
            randomize({
                id = id,
                prototype = ag_tower,
                property = "radius",
                abs_min = 1,
                range = "small",
                rounding = "discrete",
                variance = "small"
            })
            local factor = ag_tower.radius / old_value
            locale_utils.create_localised_description(ag_tower, factor, id, { variance = "small" })
        end
    end
end

-- New
randomizations.artillery_projectile_damage = function (id)
    local projectiles = trigger_utils.get_artillery_projectile_creator_table()

    local target_classes = {
        ["ammo"] = true,
    }

    for projectile_name, creators in pairs(projectiles) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local projectile = data.raw["artillery-projectile"][projectile_name]
            local structs = {}
            trigger_utils.gather_artillery_projectile_structs(structs, projectile, true)
            local changed = false
            local rng_key = rng.key({ id = id, prototype = projectile })
            local factor = randomize({
                key = rng_key,
                dummy = 1,
                rounding = "none",
                variance = "big",
            })
            local rounding_params = { key = rng_key, rounding = "discrete_float" }

            for _, damage_parameters in pairs(structs["damage-parameters"] or {}) do
                if damage_parameters.amount > 0 then
                    damage_parameters.amount = randnum.fixes(rounding_params, damage_parameters.amount * factor)
                    changed = true
                end
            end

            if changed then
                for _, prototype in pairs(affected_prototypes) do
                    locale_utils.create_localised_description(prototype, factor, id, { variance = "big" })
                end
            end
        end
    end
end

-- New
randomizations.artillery_projectile_effect_radius = function (id)
    local projectiles = trigger_utils.get_artillery_projectile_creator_table()

    local target_classes = {
        ["ammo"] = true,
    }

    for projectile_name, creators in pairs(projectiles) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local projectile = data.raw["artillery-projectile"][projectile_name]
            local structs = {}
            trigger_utils.gather_artillery_projectile_structs(structs, projectile, true)
            local randomized = false
            local rng_key = rng.key({ id = id, prototype = projectile })
            local factor = randomize({
                key = rng_key,
                dummy = 1,
                rounding = "none",
                variance = "medium",
            })
            local rounding_params = { key = rng_key, rounding = "discrete_float" }

            for _, trigger in pairs(structs["trigger"]) do
                if trigger.radius ~= nil and trigger.radius > 0 then
                    randomized = true
                    trigger.radius = randnum.fixes(rounding_params, trigger.radius * factor)
                end
            end

            if randomized then
                for _, prototype in pairs(affected_prototypes) do
                    locale_utils.create_localised_description(prototype, factor, id, { variance = "medium" })
                end
            end
        end
    end
end

-- New
randomizations.asteroid_collector_arm_inventory = function(id)
    if data.raw["asteroid-collector"] ~= nil then
        for _, collector in pairs(data.raw["asteroid-collector"]) do
            if collector.arm_inventory_size == nil then
                collector.arm_inventory_size = 5
            end

            local old_value = collector.arm_inventory_size

            randomize({
                id = id,
                prototype = collector,
                property = "arm_inventory_size",
                rounding = "discrete",
                variance = "medium",
            })

            local factor = collector.arm_inventory_size / old_value
            locale_utils.create_localised_description(collector, factor, id, { variance = "medium" })
        end
    end
end

-- New
randomizations.asteroid_collector_base_arm_count = function(id)
    if data.raw["asteroid-collector"] ~= nil then
        for _, collector in pairs(data.raw["asteroid-collector"]) do
            if collector.arm_count_base == nil then
                collector.arm_count_base = 3
            end

            local old_value = collector.arm_count_base

            randomize({
                id = id,
                prototype = collector,
                property = "arm_count_base",
                rounding = "discrete",
                variance = "medium",
            })

            local factor = collector.arm_count_base / old_value
            locale_utils.create_localised_description(collector, factor, id, { variance = "medium" })
        end
    end
end

-- New
randomizations.asteroid_collector_inventory = function(id)
    if data.raw["asteroid-collector"] ~= nil then
        for _, collector in pairs(data.raw["asteroid-collector"]) do
            if collector.inventory_size == nil then
                collector.inventory_size = 39
            end

            local old_value = collector.inventory_size

            randomize({
                id = id,
                prototype = collector,
                property = "inventory_size",
                rounding = "discrete",
                variance = "medium",
            })

            local factor = collector.inventory_size / old_value
            locale_utils.create_localised_description(collector, factor, id, { variance = "medium" })
        end
    end
end

-- Not added to spec yet
randomizations.asteroid_collector_offset = function(id)
    if data.raw["asteroid-collector"] ~= nil then
        for _, collector in pairs(data.raw["asteroid-collector"]) do
            randomize({
                id = id,
                prototype = collector,
                property = "collection_box_offset",
                range = "small",
                variance = "small"
            })
        end
    end
end

-- New
randomizations.asteroid_collector_radius = function(id)
    if data.raw["asteroid-collector"] ~= nil then
        for _, collector in pairs(data.raw["asteroid-collector"]) do
            local old_value = collector.collection_radius
            randomize({
                id = id,
                prototype = collector,
                property = "collection_radius",
                range = "small",
                variance = "small",
                rounding = "discrete"
            })
            local factor = collector.collection_radius / old_value
            locale_utils.create_localised_description(collector, factor, id, { variance = "small" })
        end
    end
end

-- New
randomizations.asteroid_collector_speed = function(id)
    if data.raw["asteroid-collector"] then
        for _, collector in pairs(data.raw["asteroid-collector"]) do
            if collector.arm_speed_base ~= nil then
                collector.arm_speed_base = 0.1
            end

            local old_arm_speed = collector.arm_speed_base

            -- To km/h
            collector.arm_speed_base = collector.arm_speed_base * 216
            randomize({
                id = id,
                prototype = collector,
                property = "arm_speed_base",
                range = "small",
                rounding = "discrete_float"
            })
            -- Back to tiles per tick
            collector.arm_speed_base = collector.arm_speed_base / 216

            local factor = collector.arm_speed_base / old_arm_speed
            -- Increase quality scaling by same amount
            if collector.arm_speed_quality_scaling ~= nil then
                collector.arm_speed_quality_scaling = collector.arm_speed_quality_scaling * factor
            end
            locale_utils.create_localised_description(collector, factor, id)
        end
    end
end

randomizations.asteroid_mass = function(id)
    if data.raw.asteroid ~= nil then
        for _, asteroid in pairs(data.raw.asteroid) do
            if asteroid.mass == nil then
                asteroid.mass = 1
            end
            local old_value = asteroid.mass

            randomize({
                id = id,
                prototype = asteroid,
                property = "mass",
                range = "small",
                rounding = "discrete_float",
                dir = -1
            })

            local factor = asteroid.mass / old_value
            locale_utils.create_localised_description(asteroid, factor, id, {flipped = true})
        end
    end
end

randomizations.asteroid_yields = function (id)
    if data.raw.asteroid ~= nil then
        for _, asteroid in pairs(data.raw.asteroid) do
            local structs = {}
            trigger_utils.gather_asteroid_structs(structs, asteroid, true)
            local rng_key = rng.key({ id = id, prototype = asteroid })
            for _, trigger_effect in pairs(structs["trigger-effect"] or {}) do
                if trigger_effect.offsets ~= nil then
                    local offsets = trigger_effect.offsets
                    local dir = -1
                    if trigger_effect.type == "create-asteroid-chunk" then
                        dir = 1
                    end
                    local new_count = randomize({
                        key = rng_key,
                        dummy = #offsets,
                        variance = "medium",
                        dir = dir,
                        rounding = "discrete",
                    })
                    while new_count < #offsets do
                        table.remove(offsets)
                    end
                    while new_count > #offsets do
                        -- Let's just put every asteroid in the exact same position and hope no one notices
                        local v = { 0, 0 }
                        table.insert(offsets, v)
                    end
                end
            end
        end
    end
end

randomizations.base_effect = function (id)

    -- Chance of considering to add/remove base effect from 
    local toggle_base_effect_p = 0.5
    -- Chance of negative base effect
    local negative_effect_p = 0.5

    local negative_effects = {
        ["consumption"] = true,
        ["pollution"] = true,
    }
    local base_effect_receivers = 0
    local possible_effect_receivers = {}

    for entity_class, _ in pairs(categories.effect_receivers) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                table.insert(possible_effect_receivers, entity)
                if entity.effect_receiver == nil then
                    entity.effect_receiver = {}
                end
                if entity.effect_receiver.base_effect == nil then
                    entity.effect_receiver.base_effect = {}
                end
                for _, value in pairs(entity.effect_receiver.base_effect) do
                    if value ~= 0 then
                        base_effect_receivers = base_effect_receivers + 1
                        break
                    end
                end
            end
        end
    end

    local ratio = base_effect_receivers / #possible_effect_receivers
    toggle_base_effect_p = toggle_base_effect_p * ratio

    -- Applying the probability on individual effects rather than entities in order to get 5 times the base effects
    -- However, not just positive effects and not just productivity
    for _, entity in pairs(possible_effect_receivers) do
        local rng_key = rng.key({ id = id, prototype = entity })
        local base_effect = entity.effect_receiver.base_effect

        -- Janky way of determining description but I can't be bothered
        local gained_positive_effect = false
        local gained_negative_effect = false
        local lost_positive_effect = false
        local lost_negative_effect = false
        local factor = -1
        local dir = 0

        for _, effect_name in pairs(get_allowed_effects(entity)) do
            local old_effect = base_effect[effect_name]
            local had_effect = old_effect ~= nil and old_effect ~= 0
            if had_effect and randbool.rand_bias_chaos(rng_key, toggle_base_effect_p, -1) then
                base_effect[effect_name] = nil
                if old_effect > 0 ~= (negative_effects[effect_name] ~= nil) then
                    lost_positive_effect = true
                else
                    lost_negative_effect = true
                end
            end
            if base_effect[effect_name] == nil and randbool.rand_bias_chaos(rng_key, toggle_base_effect_p, 1) then
                local value = 0.5
                if negative_effects[effect_name] ~= nil then
                    value = value * -1
                end
                if randbool.rand_bias(rng_key, negative_effect_p, -1) then
                    value = value * -1
                    if lost_negative_effect and had_effect then
                        lost_negative_effect = false
                    else
                        gained_negative_effect = true
                    end
                else
                    if lost_positive_effect and had_effect then
                        lost_positive_effect = false
                    else
                        gained_positive_effect = true
                    end
                end
                base_effect[effect_name] = value
            end
            if base_effect[effect_name] ~= nil and base_effect[effect_name] ~= 0 then
                local current_dir = -1
                if base_effect[effect_name] > 0 ~= (negative_effects[effect_name] ~= nil) then
                    current_dir = 1
                end
                randomize({
                    id = id,
                    prototype = entity,
                    tbl = base_effect,
                    property = effect_name,
                    rounding = "discrete_float",
                    variance = "medium",
                    dir = current_dir,
                    abs_min = -327,
                    abs_max = 327,
                })
                if had_effect then
                    dir = current_dir
                    factor = base_effect[effect_name] / old_effect
                end
            end
        end

        if gained_positive_effect then
            entity.localised_description = {"", locale_utils.find_localised_description(entity), "\n[color=green](Base effect)[/color]"}
        elseif gained_negative_effect then
            entity.localised_description = {"", locale_utils.find_localised_description(entity), "\n[color=red](Base effect)[/color]"}
        end
        if lost_positive_effect then
            entity.localised_description = {"", locale_utils.find_localised_description(entity), "\n[color=red](Missing base effect)[/color]"}
        elseif lost_negative_effect then
            entity.localised_description = {"", locale_utils.find_localised_description(entity), "\n[color=green](Missing base effect)[/color]"}
        end
        if factor ~= -1 then
            locale_utils.create_localised_description(entity, factor, id, { flipped = dir < 0 })
        end
    end
end

randomizations.beacon_distribution_effectivity = function(id)
    for _, beacon in pairs(data.raw.beacon) do
        local old_distribution_effectivity = beacon.distribution_effectivity

        randomize({
            id = id,
            prototype = beacon,
            property = "distribution_effectivity",
            rounding = "discrete_float",
            range = "small",
            variance = "big",
        })

        local factor = beacon.distribution_effectivity / old_distribution_effectivity
        beacon.distribution_effectivity_bonus_per_quality_level = beacon.distribution_effectivity_bonus_per_quality_level * factor
        locale_utils.create_localised_description(beacon, factor, id, { variance = "big" })
    end
end

randomizations.beacon_supply_area = function(id)
    for _, beacon in pairs(data.raw.beacon) do
        local old_supply_distance = beacon.supply_area_distance

        randomize({
            id = id,
            prototype = beacon,
            property = "supply_area_distance",
            abs_min = 1,
            abs_max = 64,
            range = "small",
            variance = "medium",
            rounding = "discrete"
        })

        locale_utils.create_localised_description(beacon, beacon.supply_area_distance / old_supply_distance, id, { variance = "medium" })
    end
end

-- New
randomizations.beam_damage = function (id)
    local beams = trigger_utils.get_beam_creator_table()

    local target_classes = {
        ["ammo"] = true,
    }

    for beam_name, creators in pairs(beams) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local beam = data.raw.beam[beam_name]
            local structs = {}
            trigger_utils.gather_beam_structs(structs, beam, true)
            local changed = false
            local rng_key = rng.key({ id = id, prototype = beam })
            local factor = randomize({
                key = rng_key,
                dummy = 1,
                rounding = "none",
                variance = "medium",
            })
            local rounding_params = { key = rng_key, rounding = "discrete_float" }

            for _, damage_parameters in pairs(structs["damage-parameters"] or {}) do
                if damage_parameters.amount > 0 then
                    damage_parameters.amount = randnum.fixes(rounding_params, damage_parameters.amount * factor)
                    changed = true
                end
            end

            if changed then
                for _, prototype in pairs(affected_prototypes) do
                    locale_utils.create_localised_description(prototype, factor, id, { variance = "medium" })
                end
            end
        end
    end
end

-- New
-- Not added to spec yet
randomizations.beam_damage_interval = function(id)
    for _, beam in pairs(data.raw.beam) do
        randomize({
            id = id,
            prototype = beam,
            property = "damage_interval",
            dir = -1
        })
        -- TODO: Inverse rounding
    end
end

-- New
-- Not added to spec yet
randomizations.beam_width = function(id)
    for _, beam in pairs(data.raw.beam) do
        randomize({
            id = id,
            prototype = beam,
            property = "width",
            range = "very_big"
        })
    end
end

-- Includes tiered randomization based off belt speeds
randomizations.belt_speed = function(id)
    local belts = {}
    local old_speeds = {}
    for belt_class, _ in pairs(categories.belts) do
        for _, belt in pairs(data.raw[belt_class]) do
            table.insert(old_speeds, belt.speed)
            table.insert(belts, belt)
            -- Multiply belt speed by 256 so that it rounds correctly
            belt.speed = belt.speed * 256
        end
    end

    randomizations.linked({
        id = id,
        prototypes = belts,
        property = "speed",
        range_min = "small",
        rounding = "discrete",
        abs_min = 1
    })

    -- Undo earlier multiplication by 256
    for ind, belt in pairs(belts) do
        belt.speed = belt.speed / 256

        locale_utils.create_localised_description(belt, belt.speed / old_speeds[ind], id)
    end
end

randomizations.boiler_consumption = function(id)
    for _, boiler in pairs(data.raw.boiler) do
        local old_consumption = util.parse_energy(boiler.energy_consumption)

        randomizations.energy({
            is_power = true,
            id = id,
            prototype = boiler,
            property = "energy_consumption",
            range = "small",
            rounding = "discrete_float"
        })

        locale_utils.create_localised_description(boiler, util.parse_energy(boiler.energy_consumption) / old_consumption, id)
    end
end

randomizations.bot_cargo_capacity = function(id)
    for _, bot_class in pairs({"construction-robot", "logistic-robot"}) do
        for _, bot in pairs(data.raw[bot_class]) do
            local old_value = bot.max_payload_size

            randomize({
                id = id,
                prototype = bot,
                property = "max_payload_size",
                rounding = "discrete",
                abs_min = 1,
            })

            local factor = bot.max_payload_size / old_value

            locale_utils.create_localised_description(bot, factor, id)
        end
    end
end

randomizations.bot_energy = function(id)
    -- Only include construction and logistic bots
    -- Other bots don't use energy keys anyways
    for _, bot_class in pairs({"construction-robot", "logistic-robot"}) do
        for _, bot in pairs(data.raw[bot_class]) do
            -- If energy_per_move is zero, randomization was probably not meant to be for this bot
            if bot.energy_per_move ~= nil and util.parse_energy(bot.energy_per_move) ~= 0 then
                local old_energy_per_move = util.parse_energy(bot.energy_per_move)

                randomizations.energy({
                    id = id,
                    prototype = bot,
                    property = "energy_per_move",
                    range = "small",
                    dir = -1,
                    rounding = "discrete_float"
                })

                local new_energy_per_move = util.parse_energy(bot.energy_per_move)

                -- Scale energy_per_tick accordingly
                local factor = new_energy_per_move / old_energy_per_move
                if bot.energy_per_tick ~= nil then
                    local energy_per_tick_as_num = util.parse_energy(bot.energy_per_tick)
                    local rounding_params = {key = rng.key({id=id, property = bot}), rounding = "discrete_float"}
                    energy_per_tick_as_num = randnum.fixes(rounding_params, energy_per_tick_as_num * factor)
                    bot.energy_per_tick = energy_per_tick_as_num .. "J"
                end

                locale_utils.create_localised_description(bot, factor, id, {flipped = true})
            end
        end
    end
end

randomizations.bot_energy_capacity = function(id)
    for _, bot_class in pairs({"construction-robot", "logistic-robot"}) do
        for _, bot in pairs(data.raw[bot_class]) do
            if bot.max_energy ~= nil and util.parse_energy(bot.max_energy) > 0 then
                local old_value = util.parse_energy(bot.max_energy)

                randomizations.energy({
                    id = id,
                    prototype = bot,
                    property = "max_energy",
                    range = "small",
                    rounding = "discrete_float"
                })

                local factor = util.parse_energy(bot.max_energy) / old_value

                locale_utils.create_localised_description(bot, factor, id)
            end
        end
    end
end

randomizations.bot_speed = function(id)
    for bot_class, _ in pairs(categories.bot_classes) do
        if data.raw[bot_class] ~= nil then
            for _, bot in pairs(data.raw[bot_class]) do
                if bot.speed > 0 then
                    local old_speed = bot.speed

                    -- To km/h
                    bot.speed = bot.speed * 216
                    -- No more bias toward faster bots with new algorithm
                    -- Fate alone determines your suffering now :D
                    randomize({
                        id = id,
                        prototype = bot,
                        property = "speed",
                        range_min = "small",
                        range_max = "big",
                        bias = 0.03,
                        rounding = "discrete_float"
                    })
                    -- Back to tiles per tick
                    bot.speed = bot.speed / 216

                    if bot.max_speed ~= nil then
                        bot.max_speed = bot.max_speed * bot.speed / old_speed
                    end

                    locale_utils.create_localised_description(bot, bot.speed / old_speed, id)
                end
            end
        end
    end
end

randomizations.burner_generator_output = function(id)
    for _, burner_generator in pairs(data.raw["burner-generator"]) do
        local old_output = util.parse_energy(burner_generator.max_power_output)

        randomizations.energy({
            is_power = true,
            id = id,
            prototype = burner_generator,
            property = "max_power_output",
            range = "small",
            rounding = "discrete_float",
            variance = "big",
        })

        locale_utils.create_localised_description(burner_generator, util.parse_energy(burner_generator.max_power_output) / old_output, id, { variance = "big" })
    end
end

-- New
-- Not added to spec yet
randomizations.capture_robot_capture_speed = function(id)
    if data.raw["capture-robot"] ~= nil then
        for _, bot in pairs(data.raw["capture-robot"]) do
            if bot.capture_speed == nil then
                bot.capture_speed = 1
            end

            randomize({
                id = id,
                prototype = bot,
                property = "capture_speed"
            })
        end
    end
end

-- New
-- Not added to spec yet
randomizations.capture_robot_search_radius = function(id)
    if data.raw["capture-robot"] ~= nil then
        for _, bot in pairs(data.raw["capture-robot"]) do
            if bot.search_radius == nil then
                bot.search_radius = 1
            end

            randomize({
                id = id,
                prototype = bot,
                property = "search_radius"
            })
        end
    end
end

-- NEW
randomizations.car_effectivity = function(id)
    for _, car in pairs(data.raw.car) do
        -- CRITICAL TODO
    end
end

randomizations.car_rotation_speed = function(id)
    for _, car in pairs(data.raw.car) do
        if car.rotation_speed > 0 then
            local old_rotation_speed = car.rotation_speed

            randomize({
                id = id,
                prototype = car,
                property = "rotation_speed",
                rounding = "discrete_float",
                variance = "big",
            })

            locale_utils.create_localised_description(car, car.rotation_speed / old_rotation_speed, id, { variance = "big" })
        end
    end
end

-- New
randomizations.cargo_bay_inventory_bonus = function (id)
    for _, cargo_bay in pairs(data.raw["cargo-bay"]) do
        local old_value = cargo_bay.inventory_size_bonus

        randomize({
            id = id,
            prototype = cargo_bay,
            property = "inventory_size_bonus",
            rounding = "discrete",
            variance = "medium",
        })

        local factor = cargo_bay.inventory_size_bonus / old_value

        locale_utils.create_localised_description(cargo_bay, factor, id, { variance = "medium" })
    end
end

-- New
randomizations.cargo_landing_pad_radar_range = function (id)
    for _, clp in pairs(data.raw["cargo-landing-pad"]) do
        if clp.radar_range ~= nil and clp.radar_range > 0 then
            local old_value = clp.radar_range

            randomize({
                id = id,
                prototype = clp,
                property = "radar_range",
                rounding = "discrete",
                variance = "small",
            })

            local factor = clp.radar_range / old_value

            locale_utils.create_localised_description(clp, factor, id, { variance = "small" })
        end
    end
end

-- Includes linked randomization based on crafting speeds
randomizations.crafting_machine_speed = function(id)
    -- Separate by crafting category
    local function category_str(machine)
        local separator = "aaa"
        local cat_str = ""
        for _, cat in pairs(machine.crafting_categories) do
            cat_str = cat_str .. cat .. separator
        end
        return string.sub(cat_str, 1, -4)
    end

    local category_to_machines = {}
    local machine_to_old_speed = {}
    for crafting_machine_class, _ in pairs(categories.crafting_machines) do
        for _, machine in pairs(data.raw[crafting_machine_class]) do
            local cat_str = category_str(machine)

            if category_to_machines[cat_str] == nil then
                category_to_machines[cat_str] = {}
            end
            table.insert(category_to_machines[cat_str], machine)
            machine_to_old_speed[machine.name] = machine.crafting_speed
        end
    end
    for _, machine_list in pairs(category_to_machines) do
        randomizations.linked({
            separated = true,
            id = id,
            prototypes = machine_list,
            property = "crafting_speed",
            rounding = "discrete_float"
        })
    end

    -- Scale pollution and energy usage accordingly
    for crafting_machine_class, _ in pairs(categories.crafting_machines) do
        for _, machine in pairs(data.raw[crafting_machine_class]) do
            local energy_usage_as_number = 60 * util.parse_energy(machine.energy_usage)
            machine.energy_usage = energy_usage_as_number * machine.crafting_speed / machine_to_old_speed[machine.name] .. "W"

            if machine.energy_source.emissions_per_minute ~= nil then
                for pollutant_id, pollutant_amount in pairs(machine.energy_source.emissions_per_minute) do
                    machine.energy_source.emissions_per_minute[pollutant_id] = pollutant_amount * machine.crafting_speed / machine_to_old_speed[machine.name]
                end
            end

            locale_utils.create_localised_description(machine, machine.crafting_speed / machine_to_old_speed[machine.name], id)
        end
    end
end

-- Includes linked randomization based on distribution distance
randomizations.electric_pole_wire_distance = function(id)
    local electric_poles = {}
    local electric_pole_to_old_wire_dist = {}
    for _, electric_pole in pairs(data.raw["electric-pole"]) do
        table.insert(electric_poles, electric_pole)
        electric_pole_to_old_wire_dist[electric_pole.name] = electric_pole.maximum_wire_distance
    end

    randomizations.linked({
        id = id,
        prototypes = electric_poles,
        property = "maximum_wire_distance",
        abs_min = 1,
        abs_max = 64,
        rounding = "discrete"
    })

    for _, electric_pole in pairs(electric_poles) do
        if electric_pole_to_old_wire_dist[electric_pole.name] > 0 then
            locale_utils.create_localised_description(electric_pole, electric_pole.maximum_wire_distance / electric_pole_to_old_wire_dist[electric_pole.name], id)
        end
    end
end

-- Includes linked randomization based on supply area
randomizations.electric_pole_supply_area = function(id)
    local electric_poles = {}
    local electric_pole_to_old_supply_area = {}

    for _, electric_pole in pairs(data.raw["electric-pole"]) do
        table.insert(electric_poles, electric_pole)
        electric_pole_to_old_supply_area[electric_pole.name] = electric_pole.supply_area_distance
        -- Let's just randomize the part of the radius that extends past its own tiles
        if electric_pole.collision_box == nil then
            electric_pole.collision_box = { { 0, 0 }, { 0, 0 } }
            -- Two owls staring at you    ^^^^^^^^^^^^^^^^^^^^^^
        end
        electric_pole.supply_area_distance = electric_pole.supply_area_distance - get_collision_radius(electric_pole)
    end

    randomizations.linked({
        id = id,
        prototypes = electric_poles,
        property = "supply_area_distance",
        abs_min = 1,
        abs_max = 64,
        variance = "small",
        rounding = "discrete"
    })

    for _, electric_pole in pairs(data.raw["electric-pole"]) do
        local collision_radius = get_collision_radius(electric_pole)
        local odd_size = (collision_radius * 2) % 2 == 1
        local max_value = 64
        if odd_size then
            max_value = 63.5
        end
        -- Revert the previous adjustment
        electric_pole.supply_area_distance = math.min(max_value, electric_pole.supply_area_distance + collision_radius)

        locale_utils.create_localised_description(electric_pole, electric_pole.supply_area_distance / electric_pole_to_old_supply_area[electric_pole.name], id, { variance = "small" })
    end
end

-- New
randomizations.fire_damage = function (id)
    local fires = trigger_utils.get_fire_creator_table()

    local target_classes = {
        ["ammo"] = true,
    }

    for fire_name, creators in pairs(fires) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local fire = data.raw.fire[fire_name]
            local structs = {}
            trigger_utils.gather_fire_structs(structs, fire, true)
            local changed = false
            local rng_key = rng.key({ id = id, prototype = fire })
            local factor = randomize({
                key = rng_key,
                dummy = 1,
                rounding = "none",
                variance = "big",
            })
            local rounding_params = { key = rng_key, rounding = "discrete_float" }

            for _, damage_parameters in pairs(structs["damage-parameters"] or {}) do
                if damage_parameters.amount > 0 then
                    damage_parameters.amount = randnum.fixes(rounding_params, damage_parameters.amount * factor)
                    changed = true
                end
            end

            if changed then
                for _, prototype in pairs(affected_prototypes) do
                    locale_utils.create_localised_description(prototype, factor, id, { variance = "big" })
                end
            end
        end
    end
end

-- New
randomizations.fire_lifetime = function (id)
    local fires = trigger_utils.get_fire_creator_table()

    local target_classes = {
        ["ammo"] = true,
    }

    for fire_name, creators in pairs(fires) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local fire = data.raw.fire[fire_name]
            if fire.initial_lifetime == nil then
                fire.initial_lifetime = 300
            end

            local old_value = fire.initial_lifetime
            local unit_time = to_unit_time(fire.initial_lifetime)
            fire.initial_lifetime = unit_time.value

            randomize({
                id = id,
                prototype = fire,
                property = "initial_lifetime",
                rounding = "discrete_float",
                variance = "big",
            })

            fire.initial_lifetime = to_ticks(unit_time.unit, fire.initial_lifetime)

            local factor = fire.initial_lifetime / old_value
            for _, prototype in pairs(affected_prototypes) do
                locale_utils.create_localised_description(prototype, factor, id, { variance = "big" })
            end
        end
    end
end

-- New
randomizations.fluid_stream_damage = function (id)
    local streams = trigger_utils.get_stream_creator_table()

    local target_classes = {
        ["ammo"] = true,
    }

    for stream_name, creators in pairs(streams) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local stream = data.raw.stream[stream_name]
            local structs = {}
            trigger_utils.gather_stream_structs(structs, stream, true)
            local changed = false
            local rng_key = rng.key({ id = id, prototype = stream })
            local factor = randomize({
                key = rng_key,
                dummy = 1,
                rounding = "none",
                variance = "big",
            })
            local rounding_params = { key = rng_key, rounding = "discrete_float" }

            for _, damage_parameters in pairs(structs["damage-parameters"] or {}) do
                if damage_parameters.amount > 0 then
                    damage_parameters.amount = randnum.fixes(rounding_params, damage_parameters.amount * factor)
                    changed = true
                end
            end

            if changed then
                for _, prototype in pairs(affected_prototypes) do
                    locale_utils.create_localised_description(prototype, factor, id, { variance = "big" })
                end
            end
        end
    end
end

-- New
randomizations.fluid_stream_effect_radius = function (id)
    local streams = trigger_utils.get_stream_creator_table()

    local target_classes = {
        ["ammo"] = true,
    }

    for stream_name, creators in pairs(streams) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local stream = data.raw.stream[stream_name]
            local structs = {}
            trigger_utils.gather_stream_structs(structs, stream, true)
            local randomized = false
            local rng_key = rng.key({ id = id, prototype = stream })
            local factor = randomize({
                key = rng_key,
                dummy = 1,
                rounding = "none",
                variance = "medium",
            })
            local rounding_params = { key = rng_key, rounding = "discrete_float" }

            for _, trigger in pairs(structs["trigger"]) do
                if trigger.radius ~= nil and trigger.radius > 0 then
                    randomized = true
                    trigger.radius = randnum.fixes(rounding_params, trigger.radius * factor)
                end
            end

            if randomized then
                for _, prototype in pairs(affected_prototypes) do
                    locale_utils.create_localised_description(prototype, factor, id, { variance = "medium" })
                end
            end
        end
    end
end

-- New
randomizations.fusion_generator_max_power = function(id)
    for _, generator in pairs(data.raw["fusion-generator"]) do
        local old_value = util.parse_energy(generator.energy_source.output_flow_limit)

        randomizations.energy({
            is_power = true,
            id = id,
            prototype = generator,
            tbl = generator.energy_source,
            property = "output_flow_limit",
            rounding = "discrete_float",
            variance = "big"
        })

        local factor = util.parse_energy(generator.energy_source.output_flow_limit) / old_value

        locale_utils.create_localised_description(generator, factor, id, { variance = "big" })
    end
end

-- New
randomizations.fusion_generator_speed = function(id)
    for _, generator in pairs(data.raw["fusion-generator"]) do
        local old_value = generator.max_fluid_usage

        randomize({
            id = id,
            prototype = generator,
            property = "max_fluid_usage",
            rounding = "discrete_float",
            variance = "big",
        })

        local factor = generator.max_fluid_usage / old_value

        locale_utils.create_localised_description(generator, factor, id, { variance = "big" })
    end
end

-- New
randomizations.fusion_reactor_neighbor_bonus = function(id)
    for _, reactor in pairs(data.raw["fusion-reactor"]) do
        if reactor.neighbour_bonus == nil then
            reactor.neighbour_bonus = 1
        end

        local old_value = reactor.neighbour_bonus

        randomize({
            id = id,
            prototype = reactor,
            property = "neighbour_bonus",
            rounding = "discrete_float",
            variance = "big"
        })

        local factor = reactor.neighbour_bonus / old_value

        locale_utils.create_localised_description(reactor, factor, id, { variance = "big" })
    end
end

-- New
randomizations.fusion_reactor_power_input = function(id)
    for _, reactor in pairs(data.raw["fusion-reactor"]) do
        local old_value = util.parse_energy(reactor.power_input)

        randomizations.energy({
            is_power = true,
            id = id,
            prototype = reactor,
            property = "power_input",
            dir = -1,
            rounding = "discrete_float",
            variance = "big"
        })

        local factor = util.parse_energy(reactor.power_input) / old_value

        locale_utils.create_localised_description(reactor, factor, id, { flipped = true, variance = "big" })
    end
end

-- New
randomizations.fusion_reactor_speed = function(id)
    for _, reactor in pairs(data.raw["fusion-reactor"]) do
        local old_value = reactor.max_fluid_usage

        randomize({
            id = id,
            prototype = reactor,
            property = "max_fluid_usage",
            rounding = "discrete_float",
            variance = "big"
        })

        local factor = reactor.max_fluid_usage / old_value

        locale_utils.create_localised_description(reactor, factor, id, { variance = "big" })
    end
end

randomizations.gate_opening_speed = function(id)
    for _, gate in pairs(data.raw.gate) do
        if gate.opening_speed > 0 then
            local old_opening_speed = gate.opening_speed

            randomize({
                id = id,
                prototype = gate,
                property = "opening_speed",
                variance = "big"
            })

            -- Also modifies activation distance to compensate
            gate.activation_distance = gate.activation_distance * old_opening_speed / gate.opening_speed

            locale_utils.create_localised_description(gate, gate.opening_speed / old_opening_speed, id, { variance = "big" })
        end
    end
end

randomizations.generator_fluid_usage = function(id)
    for _, generator in pairs(data.raw.generator) do
        local old_fluid_usage = generator.fluid_usage_per_tick

        randomize({
            id = id,
            prototype = generator,
            property = "fluid_usage_per_tick",
            rounding = "discrete_float"
        })

        locale_utils.create_localised_description(generator, generator.fluid_usage_per_tick / old_fluid_usage, id)
    end
end

randomizations.health_regeneration = function (id)
    local enemy_classes = {
        ["asteroid"] = true,
        ["segment"] = true,
        ["segmented-unit"] = true,
        ["simple-entity"] = true,
        ["spider-unit"] = true,
        ["tree"] = true, -- They're standing in the way of my factory!
        ["turret"] = true,
        ["unit"] = true,
        ["unit-spawner"] = true
    }

    local tree_classes = {
        ["tree"] = true,
        ["plant"] = true,
    }

    for entity_class, _ in pairs(defines.prototypes.entity) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                if entity.healing_per_tick == nil and tree_classes[entity_class] ~= nil then
                    entity.healing_per_tick = 0.1 / 60
                end

                if entity.healing_per_tick ~= nil and entity.healing_per_tick ~= 0 then
                    local dir = -1
                    local old_value = entity.healing_per_tick
                    if enemy_classes[entity_class] == nil then
                        dir = 1
                    end
                    if old_value < 0 then
                        dir = dir * -1
                        entity.healing_per_tick = entity.healing_per_tick * -1
                    end

                    -- To health per second
                    entity.healing_per_tick = entity.healing_per_tick * 60

                    randomize({
                        id = id,
                        prototype = entity,
                        property = "healing_per_tick",
                        rounding = "discrete_float",
                        dir = dir,
                    })

                    -- Back to health per tick
                    entity.healing_per_tick = entity.healing_per_tick / 60

                    if old_value < 0 then
                        entity.healing_per_tick = entity.healing_per_tick * -1
                    end

                    local factor = entity.healing_per_tick / old_value
                    locale_utils.create_localised_description(entity, factor, id, { flipped = dir < 0 })
                end
            end
        end
    end
end

randomizations.inserter_base_hand_size = function(id)
    for _, inserter in pairs(data.raw.inserter) do
        if inserter.stack_size_bonus == nil then
            inserter.stack_size_bonus = 0
        end
        local old_value = inserter.stack_size_bonus + 1

        local new_value = randomize({
            key = rng.key({id = id, prototype = inserter}),
            dummy = old_value,
            rounding = "discrete",
            abs_min = 1,
            variance = "big"
        })

        inserter.stack_size_bonus = new_value - 1
        local factor = new_value / old_value
        locale_utils.create_localised_description(inserter, factor, id, { variance = "big" })
    end
end

randomizations.inserter_filter = function(id)

    -- Base probability of toggling whether an inserter has a filter
    local flip_p = 0.5

    for _, inserter in pairs(data.raw.inserter) do

        if inserter.filter_count == nil then
            inserter.filter_count = 0
        end
        local has_filter = inserter.filter_count > 0

        local dir = 1
        if has_filter then
            dir = -1
        end

        local flip = randbool.rand_bias_chaos(rng.key({id = id, prototype = inserter, property = "filter_count"}), flip_p, dir)
        if flip then
            has_filter = has_filter ~= flip
            local description = "[color=red](Broken filter)[/color]"
            if has_filter then
                description = "[color=green](Filter installed)[/color]"
            end
            inserter.localised_description = {"", locale_utils.find_localised_description(inserter), "\n" .. description}
        end

        if has_filter then
            inserter.filter_count = 5
        else
            inserter.filter_count = 0
        end
    end
end

-- Tier preservation
-- Separate out fast/bulk/stack inserters into separate tier lists
randomizations.inserter_speed = function(id)
    local old_rotation_speeds = {}
    local inserter_lists = {
        stack = {},
        bulk = {},
        normal = {}
    }
    for _, inserter in pairs(data.raw.inserter) do
        -- Stack inserter
        if inserter.max_belt_stack_size ~= nil and inserter.max_belt_stack_size > 1 then
            table.insert(inserter_lists.stack, inserter)
        elseif inserter.bulk then
            table.insert(inserter_lists.bulk, inserter)
        else
            table.insert(inserter_lists.normal, inserter)
        end
        old_rotation_speeds[inserter.name] = inserter.rotation_speed
        -- To degrees per second
        inserter.rotation_speed = inserter.rotation_speed * 21600
    end

    for _, list in pairs(inserter_lists) do
        randomizations.linked({
            id = id,
            prototypes = list,
            property = "rotation_speed",
            range_min = "small",
            range_max = "very_big",
            rounding = "discrete_float",
        })
    end

    -- Fix extension speed
    for _, inserter in pairs(data.raw.inserter) do
        -- Back to cycles per tick
        inserter.rotation_speed = inserter.rotation_speed / 21600
        inserter.extension_speed = inserter.extension_speed * inserter.rotation_speed / old_rotation_speeds[inserter.name]
        
        locale_utils.create_localised_description(inserter, inserter.rotation_speed / old_rotation_speeds[inserter.name], id)
    end
end

randomizations.inventory_sizes = function(id)
    -- Tier preservation for containers
    local container_list = {}
    local container_to_old_size = {}
    for _, class_name in pairs({"container", "logistic-container"}) do
        for _, container in pairs(data.raw[class_name]) do
            -- If the inventory has size 0 or 1, it probably should not be randomized
            if container.inventory_size > 1 then
                container_to_old_size[container.name] = container.inventory_size
                table.insert(container_list, container)
            end
        end
    end
    randomizations.linked({
        id = id,
        prototypes = container_list,
        property = "inventory_size",
        abs_min = 1,
        rounding = "discrete"
    })
    for _, container in pairs(container_list) do
        locale_utils.create_localised_description(container, container.inventory_size / container_to_old_size[container.name], id)
    end
    
    -- Tier preservation for cargo wagons
    local wagon_list = {}
    local wagon_to_old_size = {}
    for _, cargo_wagon in pairs(data.raw["cargo-wagon"]) do
        if cargo_wagon.inventory_size > 1 then
            wagon_to_old_size[cargo_wagon.name] = cargo_wagon.inventory_size
            table.insert(wagon_list, cargo_wagon)
        end
    end
    randomizations.linked({
        id = id,
        prototypes = wagon_list,
        property = "inventory_size",
        abs_min = 1,
        rounding = "discrete"
    })
    for _, cargo_wagon in pairs(wagon_list) do
        locale_utils.create_localised_description(cargo_wagon, cargo_wagon.inventory_size / wagon_to_old_size[cargo_wagon.name], id)
    end

    -- Now everything else is randomized separately
    for entity_class, _ in pairs(categories.entities_with_inventory) do
        for _, entity in pairs(data.raw[entity_class]) do
            if entity.inventory_size > 1 then
                local old_inventory_size = entity.inventory_size

                randomize({
                    id = id,
                    prototype = entity,
                    property = "inventory_size",
                    abs_min = 1,
                    rounding = "discrete"
                })

                locale_utils.create_localised_description(entity, entity.inventory_size / old_inventory_size, id)
            end
        end
    end
end

-- TODO: If I don't go with duplication, definitely make this a small range
randomizations.lab_research_speed = function(id)
    for _, lab in pairs(data.raw.lab) do
        if lab.researching_speed == nil then
            lab.researching_speed = 1
        end

        local old_speed = lab.researching_speed

        randomize({
            id = id,
            prototype = lab,
            property = "researching_speed",
            range = "small",
            rounding = "discrete_float"
        })

        locale_utils.create_localised_description(lab, lab.researching_speed / old_speed, id)
    end
end

-- New
randomizations.lab_science_pack_drain = function(id)
    for _, lab in pairs(data.raw.lab) do
        if lab.science_pack_drain_rate_percent == nil then
            lab.science_pack_drain_rate_percent = 100
        end

        local old_value = lab.science_pack_drain_rate_percent

        randomize({
            id = id,
            prototype = lab,
            property = "science_pack_drain_rate_percent",
            dir = -1,
            rounding = "discrete",
            abs_min = 1,
            abs_max = 100,
        })

        local factor = lab.science_pack_drain_rate_percent / old_value

        locale_utils.create_localised_description(lab, factor, id, { flipped = true })
    end
end

randomizations.landmine_damage = function(id)
    for _, landmine in pairs(data.raw["land-mine"]) do
        if landmine.action ~= nil then
            randomizations.trigger({
                id = id,
                prototype = landmine,
                variance = "big"
            }, landmine.action, "damage")
        end
    end
end

randomizations.landmine_effect_radius = function(id)
    for _, landmine in pairs(data.raw["land-mine"]) do
        if landmine.action ~= nil then
            randomizations.trigger({
                id = id,
                prototype = landmine,
                variance = "medium"
            }, landmine.action, "effect-radius")
        end
    end
end

randomizations.landmine_timeout = function(id)
    for _, landmine in pairs(data.raw["land-mine"]) do
        if landmine.timeout == nil then
            landmine.timeout = 120
        end

        local old_value = landmine.timeout

        randomize({
            id = id,
            prototype = landmine,
            property = "timeout",
            range = "big",
            dir = -1,
            rounding = "discrete_float",
            variance = "big",
        })

        local factor = landmine.timeout / old_value
        locale_utils.create_localised_description(landmine, factor, id, {flipped = true, variance = "big"})
    end
end

randomizations.landmine_trigger_radius = function(id)
    for _, landmine in pairs(data.raw["land-mine"]) do
        local old_value = landmine.trigger_radius

        randomize({
            id = id,
            prototype = landmine,
            property = "trigger_radius",
            range = "big",
            variance = "medium",
            rounding = "discrete_float"
        })

        local factor = landmine.trigger_radius / old_value
        locale_utils.create_localised_description(landmine, factor, id, { variance = "medium" })
    end
end

-- New
randomizations.lightning_attractor_drain = function (id)
    for _, la in pairs(data.raw["lightning-attractor"]) do
        if la.energy_source ~= nil and la.energy_source.drain ~= nil then
            local old_value = util.parse_energy(la.energy_source.drain)

            randomizations.energy({
                is_power = true,
                id = id,
                prototype = la,
                tbl = la.energy_source,
                property = "drain",
                dir = -1,
                variance = "medium",
                rounding = "discrete_float"
            })

            local factor = util.parse_energy(la.energy_source.drain) / old_value

            locale_utils.create_localised_description(la, factor, id, { variance = "medium", flipped = true })
        end
    end
end

-- New
randomizations.lightning_attractor_efficiency = function (id)
    for _, la in pairs(data.raw["lightning-attractor"]) do
        if la.efficiency ~= nil and la.efficiency > 0 then
            local old_value = la.efficiency

            randomize({
                id = id,
                prototype = la,
                property = "efficiency",
                variance = "medium",
                rounding = "discrete_float"
            })

            local factor = la.efficiency / old_value

            locale_utils.create_localised_description(la, factor, id, { variance = "medium" })
        end
    end
end

-- New
randomizations.lightning_attractor_range = function (id)
    for _, la in pairs(data.raw["lightning-attractor"]) do
        if la.range_elongation ~= nil and la.range_elongation > 0 then
            local old_value = la.range_elongation

            randomize({
                id = id,
                prototype = la,
                property = "range_elongation",
                variance = "small",
                rounding = "discrete_float"
            })

            local factor = la.range_elongation / old_value

            locale_utils.create_localised_description(la, factor, id, { variance = "small" })
        end
    end
end

-- New
randomizations.locomotive_max_speed = function(id)

    local max_value = 0
    for _, locomotive in pairs(data.raw["locomotive"]) do

        local old_value = locomotive.max_speed

        -- To km/h
        locomotive.max_speed = locomotive.max_speed * 216
        randomize({
            id = id,
            prototype = locomotive,
            property = "max_speed",
            range = "big",
            rounding = "discrete_float",
            variance = "big",
        })
        -- Back to tiles per tick
        locomotive.max_speed = locomotive.max_speed / 216
        max_value = math.max(max_value, locomotive.max_speed)

        local factor = locomotive.max_speed / old_value
        locale_utils.create_localised_description(locomotive, factor, id, { variance = "big" })
    end

    -- The other rolling stock also have max speeds
    -- Actual max speed of a train is capped to lowest of its rolling stock
    -- Thus we need to modify these so they don't interfere with the max speed
    local other_rolling_stock_classes = {
        "artillery-wagon",
        "cargo-wagon",
        "infinity-cargo-wagon",
        "fluid-wagon",
    }
    for _, class in pairs(other_rolling_stock_classes) do
        for _, rolling_stock in pairs(data.raw[class]) do
            rolling_stock.max_speed = max_value
        end
    end
end

randomizations.machine_energy_usage = function(id)

    local crafting_machine_classes = {
        ["assembling-machine"] = true,
        ["rocket-silo"] = true,
        ["furnace"] = true,
    }

    for entity_class, energy_keys in pairs(categories.machine_energy_usage_keys) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                local energy_properties = {}
                local ind_to_is_power = {}
                for energy_key, energy_or_power in pairs(energy_keys) do
                    if entity[energy_key] ~= nil and util.parse_energy(entity[energy_key]) > 0 then
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

                if #energy_properties >= 1 then
                    -- is_power scaling doesn't matter since we're going to just see proportion scaling
                    local old_first_energy_val = util.parse_energy(entity[energy_properties[1]])

                    randomizations.energy({
                        is_power = ind_to_is_power[1],
                        id = id,
                        prototype = entity,
                        property = energy_properties[1],
                        dir = -1,
                        rounding = "discrete_float"
                    })

                    local new_first_energy_val = util.parse_energy(entity[energy_properties[1]])
                    local factor = new_first_energy_val / old_first_energy_val

                    local key = rng.key({ id = id, prototype = entity })
                    local rounding_params = { key = key, rounding = "discrete_float" }

                    -- Scale all energy vals up the same way
                    for i = 2, #energy_properties do
                        local curr_energy_val = util.parse_energy(entity[energy_properties[i]])
                        local suffix = "J"
                        if ind_to_is_power[i] then
                            curr_energy_val = 60 * curr_energy_val
                            suffix = "W"
                        end
                        curr_energy_val = randnum.fixes(rounding_params, curr_energy_val * factor)
                        entity[energy_properties[i]] = curr_energy_val .. suffix
                    end

                    -- Things like turrets may break if their energy capacity isn't scaled too
                    if entity.energy_source ~= nil and entity.energy_source.buffer_capacity ~= nil then
                        entity.energy_source.buffer_capacity = util.parse_energy(entity.energy_source.buffer_capacity) * factor .. "J"
                    end

                    -- Randomize power drain too
                    -- For some reason, crafting-machine prototypes has energy_usage / 30 as default drain
                    if crafting_machine_classes[entity_class] and entity.energy_source.type == "electric" and entity.energy_source.drain == nil then
                        local drain = 60 * util.parse_energy(entity.energy_usage) / 30
                        entity.energy_source.drain = randnum.fixes(rounding_params, drain) .. "W"
                    elseif entity.energy_source ~= nil and entity.energy_source.type == "electric" and entity.energy_source.drain ~= nil then
                        local curr_energy_val = 60 * util.parse_energy(entity.energy_source.drain)
                        curr_energy_val = randnum.fixes(rounding_params, curr_energy_val * factor)
                        entity.energy_source.drain = curr_energy_val .. "W"
                    end

                    -- Update description
                    locale_utils.create_localised_description(entity, factor, id, {flipped = true})
                end
            end
        end
    end

    for _, electric_turret in pairs(data.raw["electric-turret"]) do
        local shot_energy_consumption = electric_turret.attack_parameters.ammo_type.energy_consumption
        if shot_energy_consumption ~= nil then
            local old_energy_consumption = util.parse_energy(electric_turret.attack_parameters.ammo_type.energy_consumption)

            randomizations.energy({
                id = id,
                prototype = electric_turret,
                tbl = electric_turret.attack_parameters.ammo_type,
                property = "energy_consumption",
                dir = -1,
                rounding = "discrete_float"
            })

            local factor = util.parse_energy(electric_turret.attack_parameters.ammo_type.energy_consumption) / old_energy_consumption
            if electric_turret.energy_source ~= nil and electric_turret.energy_source.buffer_capacity ~= nil then
                electric_turret.energy_source.buffer_capacity = util.parse_energy(electric_turret.energy_source.buffer_capacity) * factor .. "J"
            end

            locale_utils.create_localised_description(electric_turret, factor, id, {flipped = true})
        end
    end
end

randomizations.machine_pollution = function(id)
    for entity_class, _ in pairs(defines.prototypes.entity) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                -- These are the only keys for energy sources, and they're only used for them
                for _, energy_source_key in pairs({"burner", "energy_source"}) do
                    if entity[energy_source_key] ~= nil then
                        local energy_source = entity[energy_source_key]
                        if energy_source.emissions_per_minute ~= nil then
                            local randomized = false
                            local rng_key = rng.key({id = id, prototype = entity})
                            local positive_factor = randomize({
                                key = rng_key,
                                dummy = 1,
                                range = "small",
                                dir = -1,
                                rounding = "none",
                            })
                            local negative_factor = randomize({
                                key = rng_key,
                                dummy = 1,
                                range = "small",
                                dir = 1,
                                rounding = "none",
                            })
                            local rounding_params = { key = rng_key, rounding = "discrete_float" }
                            local positive = true
                            local factor = positive_factor

                            for pollutant_id, pollutant_amount in pairs(energy_source.emissions_per_minute) do
                                if pollutant_amount ~= 0 then
                                    if pollutant_amount > 0 then
                                        factor = positive_factor
                                        positive = true
                                    else
                                        factor = negative_factor
                                        positive = false
                                    end
                                    local new_amount = randnum.fixes(rounding_params, pollutant_amount * factor)
                                    energy_source.emissions_per_minute[pollutant_id] = new_amount
                                    randomized = true
                                end
                            end

                            if randomized then
                                -- Factor doesn't take into consideration the effects of rounding, which may be huge, but it's fine
                                -- Also, if there are both negative and positive pollution values, this will only show one of them
                                locale_utils.create_localised_description(entity, factor, id, { flipped = positive })
                            end
                        end
                    end
                end
            end
        end
    end
end

local enemy_health_classes = {
    ["asteroid"] = true,
    ["segment"] = true,
    ["segmented-unit"] = true,
    ["simple-entity"] = true,
    ["spider-unit"] = true,
    ["tree"] = true, -- They're standing in the way of my factory!
    ["turret"] = true,
    ["unit"] = true,
    ["unit-spawner"] = true
}

randomizations.max_health = function(id)
    -- Entities with health where it's sensitive enough not to randomize, or where randomization doesn't make sense
    -- Allow turrets and other military items to be randomized, we'll just dupe those
    -- These things are much harder to dupe on the other hand

    -- Just check whether the max_health key is non-nil
    -- Some entities can have health but have this be nil since it's optional, let's just not worry about those
    for entity_class, _ in pairs(defines.prototypes.entity) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                if entity.max_health ~= nil then
                    local old_max_health = entity.max_health

                    local dir = 1
                    if enemy_health_classes[entity_class] then
                        dir = -1
                    end

                    randomize({
                        id = id,
                        prototype = entity,
                        property = "max_health",
                        rounding = "discrete",
                        dir = dir
                    })
                    
                    locale_utils.create_localised_description(entity, entity.max_health / old_max_health, id, {flipped = dir == -1})
                end
            end
        end
    end
end

-- New
randomizations.mining_drill_radius = function (id)
    for _, mining_drill in pairs(data.raw["mining-drill"]) do
        local collision_radius = get_collision_radius(mining_drill)
        local odd_size = (collision_radius * 2) % 2 == 1
        local radius = mining_drill.resource_searching_radius
        if odd_size then
            radius = radius + 0.5
        end
        radius = round(radius)

        radius = randomize({
            key = rng.key({ id = id, prototype = mining_drill }),
            dummy = radius,
            rounding = "discrete",
            variance = "small",
        })

        -- Vanilla radius always has a 0.01 margin
        radius = radius - 0.01
        if odd_size then
            radius = radius - 0.5
        end
        local factor = radius / mining_drill.resource_searching_radius
        mining_drill.resource_searching_radius = radius
        locale_utils.create_localised_description(mining_drill, factor, id, { variance = "small" })

        -- Vanilla burner mining drill has no visualization
        if mining_drill.radius_visualisation_picture == nil then
            mining_drill.radius_visualisation_picture =  {
                filename = "__base__/graphics/entity/electric-mining-drill/electric-mining-drill-radius-visualization.png",
                width = 10,
                height = 10,
            }
        end
    end
end

-- New
randomizations.mining_drill_resource_drain = function (id)
    for _, mining_drill in pairs(data.raw["mining-drill"]) do
        if mining_drill.resource_drain_rate_percent == nil then
            mining_drill.resource_drain_rate_percent = 100
        end

        local old_value = mining_drill.resource_drain_rate_percent

        randomize({
            id = id,
            prototype = mining_drill,
            property = "resource_drain_rate_percent",
            dir = -1,
            rounding = "discrete",
            abs_min = 1,
            abs_max = 100,
        })

        local factor = mining_drill.resource_drain_rate_percent / old_value
        locale_utils.create_localised_description(mining_drill, factor, id, { flipped = true })
    end
end

-- New
randomizations.mining_fluid_amount_needed = function(id)
    for entity_class, _ in pairs(defines.prototypes.entity) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                if entity.minable ~= nil and entity.minable.required_fluid ~= nil then
                    local old_value = entity.minable.fluid_amount
                    randomize({
                        id = id,
                        prototype = entity,
                        tbl = entity.minable,
                        property = "fluid_amount",
                        dir = -1,
                        rounding = "discrete"
                    })

                    local factor = entity.minable.fluid_amount / old_value
                    locale_utils.create_localised_description(entity, factor, id, {flipped = true})
                end
            end
        end
    end
end

-- New
randomizations.mining_results = function(id)
    for entity_class, _ in pairs(defines.prototypes.entity) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                -- The results property seems to only contain stuff that doesn't build the entity
                -- Safe to randomize? Surely
                if entity.minable ~= nil and entity.minable.results ~= nil then
                    local rng_key = rng.key({ id = id, prototype = entity })
                    for _, product in pairs(entity.minable.results) do
                        if product.amount ~= nil then
                            if product.amount > 0 then
                                randomize({
                                    id = id,
                                    prototype = entity,
                                    tbl = product,
                                    property = "amount",
                                    dir = 1,
                                    rounding = "discrete",
                                    variance = "medium",
                                })
                            end
                        else
                            local diff = product.amount_max - product.amount_min
                            if diff > 0 then
                                diff = randomize({
                                    key = rng_key,
                                    dummy = diff,
                                    rounding = "discrete",
                                    dir = 1,
                                    variance = "medium",
                                })
                            end
                            if product.amount_min > 0 then
                                randomize({
                                    id = id,
                                    prototype = entity,
                                    tbl = product,
                                    property = "amount_min",
                                    dir = 1,
                                    rounding = "discrete",
                                    variance = "medium",
                                })
                            end
                            product.amount_max = product.amount_min + diff
                        end
                        if product.probability ~= nil then
                            randprob.rand({
                                id = id,
                                prototype = entity,
                                tbl = product,
                                property = "probability",
                                dir = 1,
                                rounding = "discrete_float",
                                variance = "medium",
                            })
                        end
                    end
                end
            end
        end
    end
end

-- Don't do tier preservation, mining drills seem different enough, at least in vanilla
randomizations.mining_speeds = function(id)
    for _, mining_drill in pairs(data.raw["mining-drill"]) do
        local old_mining_speed = mining_drill.mining_speed

        randomize({
            id = id,
            prototype = mining_drill,
            property = "mining_speed",
            range = "small",
            rounding = "discrete_float"
        })

        locale_utils.create_localised_description(mining_drill, mining_drill.mining_speed / old_mining_speed, id)
    end
end

-- New
randomizations.mining_times = function(id)
    for entity_class, _ in pairs(defines.prototypes.entity) do
        if entity_class ~= "resource" and data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                if entity.minable ~= nil and entity.minable.mining_time > 0 then
                    local old_value = entity.minable.mining_time

                    randomize({
                        id = id,
                        prototype = entity,
                        tbl = entity.minable,
                        property = "mining_time",
                        range = "small",
                        rounding = "discrete_float",
                        dir = -1
                    })
                    
                    local factor = entity.minable.mining_time / old_value
                    locale_utils.create_localised_description(entity, factor, id, {flipped = true})
                end
            end
        end
    end
end

-- New
randomizations.mining_times_resource = function(id)
    for _, resource in pairs(data.raw.resource) do
        if resource.minable ~= nil then
            local old_value = resource.minable.mining_time

            randomize({
                id = id,
                prototype = resource,
                tbl = resource.minable,
                property = "mining_time",
                range = "small",
                rounding = "discrete_float",
                dir = -1
            })

            local factor = resource.minable.mining_time / old_value
            locale_utils.create_localised_description(resource, factor, id, {flipped = true})
        end
    end
end

randomizations.module_slots = function(id)

    -- Chance of considering toggling between modules/no modules
    local toggle_module_slots_p = 0.5

    local module_slot_counts = {}
    local no_module_slots_count = 0

    local prototype_beacon = "beacon"
    local prototype_mining_drill = "mining-drill"
    local crafting_machine_prototypes = {
        ["assembling-machine"] = true,
        ["rocket-silo"] = true,
        ["furnace"] = true,
    }
    local no_quality_recipe_categories = {
        ["oil-processing"] = true,
        ["rocket-building"] = true,
    }

    for entity_class, _ in pairs(categories.entities_with_module_slots) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                if entity.module_slots ~= nil and entity.module_slots > 0 then
                    table.insert(module_slot_counts, entity.module_slots)
                else
                    no_module_slots_count = no_module_slots_count + 1
                end
                if entity_class ~= prototype_beacon then
                    if entity.effect_receiver == nil then
                        entity.effect_receiver = {}
                    end
                end
            end
        end
    end

    local ratio = #module_slot_counts / (no_module_slots_count + #module_slot_counts)
    -- Chance of giving module slots to an entity that previously didn't have any
    local add_p = toggle_module_slots_p * ratio
    -- Chance of removing all module slots from an entity
    local remove_p = toggle_module_slots_p * (1 - ratio)

    for entity_class, _ in pairs(categories.entities_with_module_slots) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                local rng_key = rng.key({ id = id, prototype = entity })
                if entity.module_slots ~= nil and entity.module_slots > 0 then
                    if entity_class ~= prototype_beacon and randbool.rand_bias_chaos(rng_key, remove_p, -1) then
                        entity.effect_receiver.uses_module_effects = false
                        entity.effect_receiver.uses_beacon_effects = false
                        entity.module_slots = 0
                        entity.localised_description = {"", locale_utils.find_localised_description(entity), "\n[color=red](Module incompatible)[/color]"}
                    else
                        local old_module_slots = entity.module_slots

                        randomize({
                            id = id,
                            prototype = entity,
                            property = "module_slots",
                            rounding = "discrete",
                            abs_min = 1,
                            variance = "big"
                        })

                        locale_utils.create_localised_description(entity, entity.module_slots / old_module_slots, id, { variance = "big" })
                    end
                elseif randbool.rand_bias_chaos(rng_key, add_p, 1) then
                    entity.effect_receiver.uses_module_effects = true
                    entity.effect_receiver.uses_beacon_effects = true
                    entity.module_slots = module_slot_counts[rng.int(rng_key, #module_slot_counts)]
                    randomize({
                        id = id,
                        prototype = entity,
                        property = "module_slots",
                        rounding = "discrete",
                        abs_min = 1,
                        variance = "big"
                    })
                    entity.allowed_effects = get_allowed_effects(entity)
                    entity.localised_description = {"", locale_utils.find_localised_description(entity), "\n[color=green](Module slots)[/color]"}
                end
            end
        end
    end
end

randomizations.offshore_pump_speed = function(id)
    for _, offshore_pump in pairs(data.raw["offshore-pump"]) do
        local old_pumping_speed = offshore_pump.pumping_speed

        randomize({
            id = id,
            prototype = offshore_pump,
            property = "pumping_speed",
            range = "very_big",
            rounding = "discrete_float",
            bias = -0.05
        })

        locale_utils.create_localised_description(offshore_pump, offshore_pump.pumping_speed / old_pumping_speed, id)
    end
end

randomizations.pipe_to_ground_distance = function(id)
    local underground_pipe_conns = {}
    local pipe_to_old_underground_distances = {}
    for _, pipe in pairs(data.raw["pipe-to-ground"]) do
        pipe_to_old_underground_distances[pipe.name] = {}

        for ind, pipe_connection in pairs(pipe.fluid_box.pipe_connections) do
            if pipe_connection.max_underground_distance ~= nil and pipe_connection.max_underground_distance > 0 then
                pipe_to_old_underground_distances[pipe.name][ind] = pipe_connection.max_underground_distance
                table.insert(underground_pipe_conns, pipe_connection)
            end
        end
    end

    randomizations.linked({
        id = id,
        tbls = underground_pipe_conns,
        property = "max_underground_distance",
        abs_min = 2,
        abs_max = 255,
        rounding = "discrete"
    })

    for _, pipe in pairs(data.raw["pipe-to-ground"]) do
        for ind, pipe_connection in pairs(pipe.fluid_box.pipe_connections) do
            if pipe_connection.max_underground_distance ~= nil and pipe_connection.max_underground_distance > 0 then
                locale_utils.create_localised_description(pipe, pipe_connection.max_underground_distance / pipe_to_old_underground_distances[pipe.name][ind], id)
            end
        end
    end
end

-- New
randomizations.plant_growth_time = function (id)
    for _, plant in pairs(data.raw["plant"]) do
        local old_value = plant.growth_ticks

        local unit_time = to_unit_time(plant.growth_ticks)
        plant.growth_ticks = unit_time.value

        randomize({
            id = id,
            prototype = plant,
            property = "growth_ticks",
            variance = "medium",
            rounding = "discrete_float",
            dir = -1,
        })

        plant.growth_ticks = to_ticks(unit_time.unit, plant.growth_ticks)

        local factor = plant.growth_ticks / old_value

        locale_utils.create_localised_description(plant, factor, id, { flipped = true })
    end
end

-- New
randomizations.plant_harvest_pollution = function (id)
    for _, plant in pairs(data.raw["plant"]) do
        if plant.harvest_emissions ~= nil then
            local randomized = false
            local rng_key = rng.key({id = id, prototype = plant})
            local factor = randomize({
                key = rng_key,
                dummy = 1,
                dir = -1,
                rounding = "none",
            })
            local rounding_params = { key = rng_key, rounding = "discrete_float" }

            for pollutant_id, pollutant_amount in pairs(plant.harvest_emissions) do
                if pollutant_amount > 0 then
                    local new_amount = randnum.fixes(rounding_params, pollutant_amount * factor)
                    plant.harvest_emissions[pollutant_id] = new_amount
                    randomized = true
                end
            end

            if randomized then
                -- Factor doesn't take into consideration the effects of rounding, so description may be inaccurate
                locale_utils.create_localised_description(plant, factor, id, { flipped = true })
            end
        end
    end
end

-- New
randomizations.projectile_damage = function (id)
    local projectiles = trigger_utils.get_projectile_creator_table()

    local target_classes = {
        ["ammo"] = true,
        ["capsule"] = true,
    }

    for projectile_name, creators in pairs(projectiles) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local projectile = data.raw.projectile[projectile_name]
            local structs = {}
            trigger_utils.gather_projectile_structs(structs, projectile, true)
            local changed = false
            local rng_key = rng.key({ id = id, prototype = projectile })
            local factor = randomize({
                key = rng_key,
                dummy = 1,
                rounding = "none",
                variance = "medium",
            })
            local rounding_params = { key = rng_key, rounding = "discrete_float" }

            for _, damage_parameters in pairs(structs["damage-parameters"] or {}) do
                if damage_parameters.amount > 0 then
                    damage_parameters.amount = randnum.fixes(rounding_params, damage_parameters.amount * factor)
                    changed = true
                end
            end

            if changed then
                for _, prototype in pairs(affected_prototypes) do
                    locale_utils.create_localised_description(prototype, factor, id, { variance = "medium" })
                end
            end
        end
    end
end

-- New
randomizations.projectile_effect_radius = function (id)
    local projectiles = trigger_utils.get_projectile_creator_table()

    local target_classes = {
        ["capsule"] = true,
        ["ammo"] = true,
    }

    for projectile_name, creators in pairs(projectiles) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local projectile = data.raw.projectile[projectile_name]
            local structs = {}
            trigger_utils.gather_projectile_structs(structs, projectile, true)
            local randomized = false
            local rng_key = rng.key({ id = id, prototype = projectile })
            local factor = randomize({
                key = rng_key,
                dummy = 1,
                rounding = "none",
                variance = "small",
            })
            local rounding_params = { key = rng_key, rounding = "discrete_float" }

            for _, trigger_effect in pairs(structs["trigger-effect"]) do
                if trigger_effect.radius ~= nil and trigger_effect.radius > 0 then
                    randomized = true
                    trigger_effect.radius = randnum.fixes(rounding_params, trigger_effect.radius * factor)
                end
            end

            for _, trigger in pairs(structs["trigger"]) do
                if trigger.radius ~= nil and trigger.radius > 0 then
                    randomized = true
                    trigger.radius = randnum.fixes(rounding_params, trigger.radius * factor)
                end
            end

            if randomized then
                for _, prototype in pairs(affected_prototypes) do
                    locale_utils.create_localised_description(prototype, factor, id, { variance = "small" })
                end
            end
        end
    end
end

-- New
randomizations.projectile_piercing_power = function (id)
    local projectiles = trigger_utils.get_projectile_creator_table()

    local target_classes = {
        ["ammo"] = true,
    }

    for projectile_name, creators in pairs(projectiles) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local projectile = data.raw.projectile[projectile_name]
            if projectile.piercing_damage ~= nil and projectile.piercing_damage > 0 then
                local old_value = projectile.piercing_damage

                randomize({
                    id = id,
                    prototype = projectile,
                    property = "piercing_damage",
                    rounding = "discrete_float",
                    variance = "big",
                })

                local factor = projectile.piercing_damage / old_value
                for _, prototype in pairs(affected_prototypes) do
                    locale_utils.create_localised_description(prototype, factor, id, { variance = "big" })
                end
            end
        end
    end
end

-- New
randomizations.projectile_projectile_count = function (id)
    local projectiles = trigger_utils.get_projectile_creator_table()

    local target_classes = {
        ["ammo"] = true,
    }

    for projectile_name, creators in pairs(projectiles) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local projectile = data.raw.projectile[projectile_name]
            local structs = {}
            trigger_utils.gather_projectile_structs(structs, projectile, true)
            local rng_key = rng.key({ id = id, prototype = projectile })
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
                for _, prototype in pairs(affected_prototypes) do
                    locale_utils.create_localised_description(prototype, factor, id, { variance = "big" })
                end
            end
        end
    end
end

randomizations.pump_pumping_speed = function(id)
    for _, pump in pairs(data.raw.pump) do
        local old_pumping_speed = pump.pumping_speed

        randomize({
            id = id,
            prototype = pump,
            property = "pumping_speed",
            rounding = "discrete_float",
            variance = "big",
        })

        locale_utils.create_localised_description(pump, pump.pumping_speed / old_pumping_speed, id, { variance = "big" })
    end
end

randomizations.radar_reveal_area = function(id)
    for _, radar in pairs(data.raw.radar) do
        local old_reveal_area = radar.max_distance_of_nearby_sector_revealed

        randomize({
            id = id,
            prototype = radar,
            property = "max_distance_of_nearby_sector_revealed",
            abs_min = 1,
            range = "small",
            variance = "medium",
            rounding = "discrete"
        })

        locale_utils.create_localised_description(radar, radar.max_distance_of_nearby_sector_revealed / old_reveal_area, id, { variance = "medium" })
    end
end

randomizations.radar_search_area = function(id)
    for _, radar in pairs(data.raw.radar) do
        local old_search_area = radar.max_distance_of_sector_revealed

        randomize({
            id = id,
            prototype = radar,
            property = "max_distance_of_sector_revealed",
            rounding = "discrete",
            variance = "medium",
        })

        locale_utils.create_localised_description(radar, radar.max_distance_of_sector_revealed / old_search_area, id, { variance = "medium" })
    end
end

randomizations.reactor_consumption = function(id)
    for _, reactor in pairs(data.raw.reactor) do
        local old_consumption = util.parse_energy(reactor.consumption)

        randomizations.energy({
            is_power = true,
            id = id,
            prototype = reactor,
            property = "consumption",
            rounding = "discrete_float",
        })

        locale_utils.create_localised_description(reactor, util.parse_energy(reactor.consumption) / old_consumption, id)
    end
end

-- New
randomizations.reactor_effectivity = function(id)
    for _, reactor in pairs(data.raw.reactor) do
        if reactor.energy_source.type == "burner" then
            if reactor.energy_source.effectivity == nil then
                reactor.energy_source.effectivity = 1
            end

            local old_value = reactor.energy_source.effectivity

            randomize({
                id = id,
                prototype = reactor,
                tbl = reactor.energy_source,
                property = "effectivity",
                rounding = "discrete_float",
                variance = "medium",
            })

            local factor = reactor.energy_source.effectivity / old_value

            locale_utils.create_localised_description(reactor, factor, id)
        end
    end
end

randomizations.reactor_neighbour_bonus = function(id)
    for _, reactor in pairs(data.raw.reactor) do
        if reactor.neighbour_bonus == nil then
            reactor.neighbour_bonus = 1
        end

        if reactor.neighbour_bonus > 0 then
            local old_neighbour_bonus = reactor.neighbour_bonus
    
            randomize({
                id = id,
                prototype = reactor,
                property = "neighbour_bonus",
                rounding = "discrete_float",
                variance = "big"
            })
    
            locale_utils.create_localised_description(reactor, reactor.neighbour_bonus / old_neighbour_bonus, id, { variance = "big" })
        end
    end
end

-- New
randomizations.resistances = function(id)
    local damage_type_names = {}
    for name, _ in pairs(data.raw["damage-type"]) do
        table.insert(damage_type_names, name)
    end
    for entity_class, _ in pairs(defines.prototypes.entity) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                if entity.resistances ~= nil then
                    local shuffled_damage_type_names = table.deepcopy(damage_type_names)
                    local key = rng.key({id = id, prototype = entity})
                    rng.shuffle(key, shuffled_damage_type_names)
                    local dir = 1
                    if enemy_health_classes[entity_class] then
                        dir = -1
                    end
                    local i = 1
                    local old_flat_resistance_sum = 0
                    local old_p_resistance_sum = 0
                    for _, resistance in pairs(entity.resistances) do
                        resistance.type = shuffled_damage_type_names[i]
                        i = i + 1
                        if resistance.decrease ~= nil and resistance.decrease > 0 then
                            old_flat_resistance_sum = old_flat_resistance_sum + resistance.decrease
                            randomize({
                                key = key,
                                prototype = entity,
                                tbl = resistance,
                                property = "decrease",
                                rounding = "discrete_float",
                                variance = "medium",
                                dir = dir,
                            })
                        end
                        if resistance.percent ~= nil and resistance.percent > 0 then
                            old_p_resistance_sum = old_p_resistance_sum + resistance.percent
                            resistance.percent = randprob.rand({
                                key = key,
                                prototype = entity,
                                tbl = resistance,
                                property = "percent",
                                rounding = "discrete_float",
                                variance = "medium",
                                dir = dir,
                                probability_scale = 100,
                            })
                        end
                    end
                    if old_flat_resistance_sum + old_p_resistance_sum > 0 then
                        entity.localised_description = {"", locale_utils.find_localised_description(entity), "\n[color=red](Botched resistance)[/color]"}
                    end
                end
            end
        end
    end

    -- Perhaps asteroids of equal size should have the same resistances.
    if data.raw.asteroid ~= nil then
        for name, asteroid in pairs(data.raw["asteroid"]) do
            local source = nil
            if name:match("^small") then
                source = data.raw["asteroid"]["small-metallic-asteroid"]
            elseif name:match("^medium") then
                source = data.raw["asteroid"]["medium-metallic-asteroid"]
            elseif name:match("^big") then
                source = data.raw["asteroid"]["big-metallic-asteroid"]
            elseif name:match("^huge") then
                source = data.raw["asteroid"]["huge-metallic-asteroid"]
            end

            if source ~= nil then
                asteroid.resistances = table.deepcopy(source.resistances)
            end
        end
    end
end

randomizations.roboport_charging_energy = function(id)
    for _, roboport in pairs(data.raw.roboport) do
        local old_charging_rate = util.parse_energy(roboport.charging_energy)

        randomizations.energy({
            is_power = true,
            id = id,
            prototype = roboport,
            property = "charging_energy",
            range = "small",
            rounding = "discrete_float"
        })

        locale_utils.create_localised_description(roboport, util.parse_energy(roboport.charging_energy) / old_charging_rate, id)
    end
end

randomizations.roboport_charging_station_count = function(id)
    for _, roboport in pairs(data.raw.roboport) do
        if roboport.charging_station_count == nil or roboport.charging_station_count == 0 then
            if roboport.charging_offsets ~= nil then
                roboport.charging_station_count = #roboport.charging_offsets
            else
                roboport.charging_station_count = 0
            end
        end

        if roboport.charging_station_count ~= 0 then
            local old_station_count = roboport.charging_station_count

            randomize({
                id = id,
                prototype = roboport,
                property = "charging_station_count",
                -- Don't randomize if there's only one station, and don't randomize down to one station if there are more
                abs_min = 2,
                rounding = "discrete"
            })

            locale_utils.create_localised_description(roboport, roboport.charging_station_count / old_station_count, id)
        end
    end
end

randomizations.roboport_construction_radius = function(id)
    for _, roboport in pairs(data.raw.roboport) do
        if roboport.construction_radius > 0 then
            local old_construction_radius = roboport.construction_radius

            randomize({
                id = id,
                prototype = roboport,
                property = "construction_radius",
                range_min = "small",
                range_max = "big",
                variance = "small",
                rounding = "discrete"
            })

            -- Make sure construction radius is at least as large as logistics radius
            if roboport.construction_radius < roboport.logistics_radius then
                roboport.construction_radius = roboport.logistics_radius
            end

            locale_utils.create_localised_description(roboport, roboport.construction_radius / old_construction_radius, id, { variance = "small" })
        end
    end
end

randomizations.roboport_inventory = function(id)
    for _, roboport in pairs(data.raw.roboport) do
        local old_value = roboport.material_slots_count + roboport.robot_slots_count

        randomize({
            id = id,
            prototype = roboport,
            property = "material_slots_count",
            range = "small",
            rounding = "discrete"
        })

        randomize({
            id = id,
            prototype = roboport,
            property = "robot_slots_count",
            range = "small",
            rounding = "discrete"
        })

        local factor = (roboport.material_slots_count + roboport.robot_slots_count) / old_value
        locale_utils.create_localised_description(roboport, factor, id)
    end
end

randomizations.roboport_logistic_radius = function(id)
    for _, roboport in pairs(data.raw.roboport) do
        local old_logistics_radius = roboport.logistics_radius

        randomize({
            id = id,
            prototype = roboport,
            property = "logistics_radius",
            range_min = "small",
            range_max = "big",
            variance = "small",
            rounding = "discrete"
        })

        -- Make sure construction radius is at least as large as logistics radius
        if roboport.construction_radius < roboport.logistics_radius then
            roboport.construction_radius = roboport.logistics_radius
        end

        -- Scale up logistics connection distance with logistic radius
        if roboport.logistics_connection_distance ~= nil then
            if old_logistics_radius ~= 0 then
                roboport.logistics_connection_distance = roboport.logistics_connection_distance * roboport.logistics_radius / old_logistics_radius
            end
        end

        locale_utils.create_localised_description(roboport, roboport.logistics_radius / old_logistics_radius, id, { variance = "small" })
    end
end

randomizations.roboport_radar_range = function(id)
    for _, roboport in pairs(data.raw.roboport) do
        if roboport.radar_range == nil then
            roboport.radar_range = math.ceil(roboport.construction_radius / 32)
        end

        if roboport.radar_range > 0 then
            local old_value = roboport.radar_range

            randomize({
                id = id,
                prototype = roboport,
                property = "radar_range",
                variance = "small",
                rounding = "discrete"
            })

            local factor = roboport.radar_range / old_value

            locale_utils.create_localised_description(roboport, factor, id, { variance = "small" })
        end
    end
end

randomizations.rocket_parts_required = function(id)
    for _, rocket_silo in pairs(data.raw["rocket-silo"]) do
        local old_rocket_parts_required = rocket_silo.rocket_parts_required

        randomize({
            id = id,
            prototype = rocket_silo,
            property = "rocket_parts_required",
            range = "small",
            dir = -1,
            rounding = "discrete"
        })

        locale_utils.create_localised_description(rocket_silo, rocket_silo.rocket_parts_required / old_rocket_parts_required, id, {flipped = true})
    end
end

-- Removed from spec
randomizations.rocket_silo_launch_time = function(id)
    for _, rocket_silo in pairs(data.raw["rocket-silo"]) do
        local time_factor = randomize({
            id = id,
            prototype = rocket_silo,
            dummy = 1,
            range = "big",
            variance = "big",
            dir = -1
        })

        rocket_silo.times_to_blink = math.min(255, time_factor * rocket_silo.times_to_blink)
        rocket_silo.light_blinking = rocket_silo.times_to_blink / time_factor
        rocket_silo.door_opening_speed = rocket_silo.door_opening_speed / time_factor

        if rocket_silo.rocket_rising_delay == nil then
            rocket_silo.rocket_rising_delay = 30
        end
        rocket_silo.rocket_rising_delay = math.min(255, time_factor * rocket_silo.rocket_rising_delay)

        if rocket_silo.launch_wait_time == nil then
            rocket_silo.launch_wait_time = 120
        end
        rocket_silo.launch_wait_time = math.min(255, time_factor * rocket_silo.launch_wait_time)

        locale_utils.create_localised_description(rocket_silo, time_factor, id, {flipped = true})
    end
end

randomizations.solar_panel_production = function(id)
    for _, solar_panel in pairs(data.raw["solar-panel"]) do
        local old_production = util.parse_energy(solar_panel.production)

        randomizations.energy({
            is_power = true,
            id = id,
            prototype = solar_panel,
            property = "production",
            -- Small min range because solar is needed for space platforms
            range_min = "small",
            rounding = "discrete_float"
        })

        locale_utils.create_localised_description(solar_panel, util.parse_energy(solar_panel.production) / old_production, id)
    end
end

randomizations.space_platform_initial_items = function (id)
    for _, spsp in pairs(data.raw["space-platform-starter-pack"]) do
        for _, product in pairs(spsp.initial_items or {}) do
            if product.amount ~= nil then
                randomize({
                    id = id,
                    prototype = spsp,
                    tbl = product,
                    property = "amount",
                    rounding = "discrete",
                    variance = "big",
                })
            end
        end
    end
end

-- New
randomizations.sticker_damage = function (id)
    local stickers = trigger_utils.get_sticker_creator_table()

    local target_classes = {
        ["ammo"] = true
    }

    for sticker_name, creators in pairs(stickers) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local sticker = data.raw.sticker[sticker_name]
            local structs = {}
            trigger_utils.gather_sticker_structs(structs, sticker, true)
            local changed = false
            local rng_key = rng.key({ id = id, prototype = sticker })
            local factor = randomize({
                key = rng_key,
                dummy = 1,
                rounding = "none",
                variance = "big",
            })
            local rounding_params = { key = rng_key, rounding = "discrete_float" }

            for _, damage_parameters in pairs(structs["damage-parameters"] or {}) do
                if damage_parameters.amount > 0 then
                    local damage_interval = 1
                    if sticker.damage_interval ~= nil then
                        damage_interval = sticker.damage_interval
                    end
                    local intervals_per_sec = 60 / damage_interval

                    -- To damage per second
                    damage_parameters.amount = damage_parameters.amount * intervals_per_sec

                    damage_parameters.amount = randnum.fixes(rounding_params, damage_parameters.amount * factor)

                    -- Back to damage per interval
                    damage_parameters.amount = damage_parameters.amount / intervals_per_sec

                    changed = true
                end
            end
            if changed then
                for _, prototype in pairs(affected_prototypes) do
                    locale_utils.create_localised_description(prototype, factor, id, { variance = "big" })
                end
            end
        end
    end
end

-- New
randomizations.sticker_duration = function (id)
    local stickers = trigger_utils.get_sticker_creator_table()

    local target_classes = {
        ["capsule"] = true,
        ["ammo"] = true,
    }

    -- As fate would have it, some capsules have multiple stickers handling different aspects of the same "effect".
    -- For instance, yumako healing and animation are handled by two separate stickers.
    -- This randomizes each separately, meaning yumako will get two descriptions of changed sticker duration.
    -- Oh well :)
    for sticker_name, creators in pairs(stickers) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local sticker = data.raw.sticker[sticker_name]

            local old_value = sticker.duration_in_ticks

            local unit_time = to_unit_time(sticker.duration_in_ticks)
            sticker.duration_in_ticks = unit_time.value

            randomize({
                id = id,
                prototype = sticker,
                property = "duration_in_ticks",
                rounding = "discrete_float",
                variance = "big",
            })

            sticker.duration_in_ticks = to_ticks(unit_time.unit, sticker.duration_in_ticks)

            local factor = sticker.duration_in_ticks / old_value

            for _, prototype in pairs(affected_prototypes) do
                locale_utils.create_localised_description(prototype, factor, id, { variance = "big" })
            end
        end
    end
end

-- New
randomizations.sticker_healing = function (id)
    local stickers = trigger_utils.get_sticker_creator_table()

    local target_classes = {
        ["capsule"] = true
    }

    for sticker_name, creators in pairs(stickers) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local sticker = data.raw.sticker[sticker_name]
            local structs = {}
            trigger_utils.gather_sticker_structs(structs, sticker, true)
            local changed = false
            local rng_key = rng.key({ id = id, prototype = sticker })
            local factor = randomize({
                key = rng_key,
                dummy = 1,
                rounding = "none",
                variance = "big",
            })
            local rounding_params = { key = rng_key, rounding = "discrete_float" }

            for _, damage_parameters in pairs(structs["damage-parameters"] or {}) do
                if damage_parameters.amount < 0 then
                    local damage_interval = 1
                    if sticker.damage_interval ~= nil then
                        damage_interval = sticker.damage_interval
                    end
                    local intervals_per_sec = 60 / damage_interval

                    -- To healing per second
                    damage_parameters.amount = damage_parameters.amount * intervals_per_sec

                    damage_parameters.amount = randnum.fixes(rounding_params, damage_parameters.amount * factor)

                    -- Back to healing per interval
                    damage_parameters.amount = damage_parameters.amount / intervals_per_sec

                    changed = true
                end
            end
            if changed then
                for _, prototype in pairs(affected_prototypes) do
                    locale_utils.create_localised_description(prototype, factor, id, { variance = "big" })
                end
            end
        end
    end
end

-- New
randomizations.sticker_movement_speed = function (id)
    local stickers = trigger_utils.get_sticker_creator_table()

    local target_classes = {
        ["capsule"] = true,
        ["ammo"] = true,
    }

    for sticker_name, creators in pairs(stickers) do
        local affected_prototypes = {}

        for _, prototype in pairs(creators) do
            if target_classes[prototype.type] ~= nil then
                affected_prototypes[#affected_prototypes+1] = prototype
            end
        end

        if #affected_prototypes > 0 then
            local sticker = data.raw.sticker[sticker_name]
            if sticker.target_movement_modifier ~= nil and sticker.target_movement_modifier ~= 1 then
                local dir = 1
                if sticker.target_movement_modifier < 1 then
                    dir = -1
                end

                local old_value = sticker.target_movement_modifier

                randomize({
                    id = id,
                    prototype = sticker,
                    property = "target_movement_modifier",
                    rounding = "discrete_float",
                    variance = "big",
                    dir = dir,
                })

                local factor = sticker.target_movement_modifier / old_value

                for _, prototype in pairs(affected_prototypes) do
                    locale_utils.create_localised_description(prototype, factor, id, { variance = "big", flipped = dir < 0 })
                end
            end
        end
    end
end

randomizations.storage_tank_capacity = function(id)
    for _, storage_tank in pairs(data.raw["storage-tank"]) do
        local old_capacity = storage_tank.fluid_box.volume

        randomize({
            id = id,
            prototype = storage_tank,
            tbl = storage_tank.fluid_box,
            property = "volume",
            range = "big",
            rounding = "discrete_float",
            variance = "big"
        })

        locale_utils.create_localised_description(storage_tank, storage_tank.fluid_box.volume / old_capacity, id, { variance = "big" })
    end
end

-- New
randomizations.thruster_consumption = function (id)
    for _, thruster in pairs(data.raw["thruster"]) do
        thruster.min_performance = {
            fluid_volume = thruster.min_performance.fluid_volume or thruster.min_performance[1],
            fluid_usage = thruster.min_performance.fluid_usage or thruster.min_performance[2],
            effectivity = thruster.min_performance.effectivity or thruster.min_performance[3],
        }
        thruster.max_performance = {
            fluid_volume = thruster.max_performance.fluid_volume or thruster.max_performance[1],
            fluid_usage = thruster.max_performance.fluid_usage or thruster.max_performance[2],
            effectivity = thruster.max_performance.effectivity or thruster.max_performance[3],
        }

        -- Randomizing min and max separately seems interesting so let's do that
        local old_max = thruster.max_performance.fluid_usage
        thruster.max_performance.fluid_usage = thruster.max_performance.fluid_usage - thruster.min_performance.fluid_usage

        -- To fluid per second
        thruster.max_performance.fluid_usage = thruster.max_performance.fluid_usage * 60
        thruster.min_performance.fluid_usage = thruster.min_performance.fluid_usage * 60

        randomize({
            id = id,
            prototype = thruster,
            tbl = thruster.min_performance,
            property = "fluid_usage",
            rounding = "discrete_float",
            variance = "medium"
        })
        randomize({
            id = id,
            prototype = thruster,
            tbl = thruster.max_performance,
            property = "fluid_usage",
            rounding = "discrete_float",
            variance = "medium"
        })

        -- Back to fluid per tick
        thruster.max_performance.fluid_usage = thruster.max_performance.fluid_usage / 60
        thruster.min_performance.fluid_usage = thruster.min_performance.fluid_usage / 60

        thruster.max_performance.fluid_usage = thruster.max_performance.fluid_usage + thruster.min_performance.fluid_usage

        local factor = thruster.max_performance.fluid_usage / old_max
        locale_utils.create_localised_description(thruster, factor, id)
    end
end

-- New
randomizations.thruster_effectivity = function (id)
    for _, thruster in pairs(data.raw["thruster"]) do
        thruster.min_performance = {
            fluid_volume = thruster.min_performance.fluid_volume or thruster.min_performance[1],
            fluid_usage = thruster.min_performance.fluid_usage or thruster.min_performance[2],
            effectivity = thruster.min_performance.effectivity or thruster.min_performance[3],
        }
        thruster.max_performance = {
            fluid_volume = thruster.max_performance.fluid_volume or thruster.max_performance[1],
            fluid_usage = thruster.max_performance.fluid_usage or thruster.max_performance[2],
            effectivity = thruster.max_performance.effectivity or thruster.max_performance[3],
        }

        -- Randomizing min and max separately seems interesting so let's do that
        local old_max = thruster.max_performance.effectivity

        randomize({
            id = id,
            prototype = thruster,
            tbl = thruster.min_performance,
            property = "effectivity",
            rounding = "discrete_float",
            variance = "medium"
        })
        randomize({
            id = id,
            prototype = thruster,
            tbl = thruster.max_performance,
            property = "effectivity",
            rounding = "discrete_float",
            variance = "medium"
        })

        local factor = thruster.max_performance.effectivity / old_max
        locale_utils.create_localised_description(thruster, factor, id)
    end
end

randomizations.turret_damage_modifier = function(id)
    for turret_class, _ in pairs(categories.turrets) do
        for _, turret in pairs(data.raw[turret_class]) do
            local attack_parameters = turret.attack_parameters

            if attack_parameters.damage_modifier == nil then
                attack_parameters.damage_modifier = 1
            end

            local old_damage_modifier = attack_parameters.damage_modifier

            randomize({
                id = id,
                prototype = turret,
                tbl = attack_parameters,
                property = "damage_modifier",
                rounding = "discrete_float"
            })

            locale_utils.create_localised_description(turret, attack_parameters.damage_modifier / old_damage_modifier, id)
        end
    end
end

randomizations.turret_min_range = function(id)
    for turret_class, _ in pairs(categories.turrets) do
        for _, turret in pairs(data.raw[turret_class]) do
            local attack_parameters = turret.attack_parameters

            if attack_parameters.min_range ~= nil and attack_parameters.min_range ~= 0 then
                local old_min_range = attack_parameters.min_range

                -- Don't randomize to more than, say, 2/3 of the range value
                -- Or we could scale max range whenever min range is changed, then randomize the diff between them instead of the max range directly?
                randomize({
                    id = id,
                    prototype = turret,
                    tbl = attack_parameters,
                    property = "min_range",
                    variance = "small",
                    rounding = "discrete_float",
                })

                local delta = attack_parameters.min_range - old_min_range
                local old_range = attack_parameters.range
                if attack_parameters.range ~= nil then
                    attack_parameters.range = attack_parameters.range + delta
                end
                local range_factor = attack_parameters.range / old_range
                if turret.prepare_range ~= nil then
                    turret.prepare_range = turret.prepare_range * range_factor
                end
                if attack_parameters.min_attack_distance ~= nil then
                    attack_parameters.min_attack_distance = attack_parameters.min_attack_distance + delta
                end

                locale_utils.create_localised_description(turret, attack_parameters.min_range / old_min_range, id, { variance = "small" })
            end
        end
    end
end

randomizations.turret_range = function(id)
    for turret_class, _ in pairs(categories.turrets) do
        for _, turret in pairs(data.raw[turret_class]) do
            local attack_parameters = turret.attack_parameters
            local min_range = 0
            if attack_parameters.min_range ~= nil then
                min_range = attack_parameters.min_range
            end

            local old_range = attack_parameters.range
            local old_delta_range = attack_parameters.range - min_range

            local new_delta_range = randomize({
                id = id,
                dummy = old_delta_range,
                variance = "small",
                range = "small",
                rounding = "discrete_float"
            })

            attack_parameters.range = new_delta_range + min_range

            local factor = attack_parameters.range / old_range

            if turret.prepare_range ~= nil then
                turret.prepare_range = turret.prepare_range * factor
            end

            locale_utils.create_localised_description(turret, factor, id, { variance = "small" })
        end
    end
end

randomizations.turret_rotation_speed = function(id)
    for turret_class, _ in pairs(categories.turrets) do
        for _, turret in pairs(data.raw[turret_class]) do
            if turret.rotation_speed == nil then
                turret.rotation_speed = 1
            end

            local old_rotation_speed = turret.rotation_speed

            randomize({
                id = id,
                prototype = turret,
                property = "rotation_speed",
                rounding = "discrete_float"
            })

            locale_utils.create_localised_description(turret, turret.rotation_speed / old_rotation_speed, id)
        end
    end

    -- Artillery wagons and artillery turrets not included as turrets, so we need to do them separately
    for _, turret_class in pairs({"artillery-turret", "artillery-wagon"}) do
        for _, turret in pairs(data.raw[turret_class]) do
            local old_rotation_speed = turret.turret_rotation_speed

            randomize({
                id = id,
                prototype = turret,
                property = "turret_rotation_speed",
                rounding = "discrete_float",
                variance = "big",
            })

            locale_utils.create_localised_description(turret, turret.turret_rotation_speed / old_rotation_speed, id, { variance = "big" })
        end
    end

    -- Car turret rotation speed
    for _, car in pairs(data.raw.car) do
        -- For some reason the default here is 0.01 and the default on "normal" turrets is 1
        if car.turret_rotation_speed == nil then
            car.turret_rotation_speed = 0.01
        end

        local old_rotation_speed = car.turret_rotation_speed

        randomize({
            id = id,
            prototype = car,
            property = "turret_rotation_speed",
            rounding = "discrete_float",
            variance = "big"
        })

        locale_utils.create_localised_description(car, car.turret_rotation_speed / old_rotation_speed, id, { variance = "big" })
    end
end

randomizations.turret_shooting_speed = function(id)
    for turret_class, _ in pairs(categories.turrets) do
        for _, turret in pairs(data.raw[turret_class]) do
            local old_shooting_speed = 1 / turret.attack_parameters.cooldown
            
            -- To attacks per second
            turret.attack_parameters.cooldown = 60 / turret.attack_parameters.cooldown
            randomize({
                id = id,
                prototype = turret,
                tbl = turret.attack_parameters,
                property = "cooldown",
                range = "small",
                rounding = "discrete_float"
            })
            -- Back to ticks per attack
            turret.attack_parameters.cooldown = 60 / turret.attack_parameters.cooldown

            local new_shooting_speed = 1 / turret.attack_parameters.cooldown
            locale_utils.create_localised_description(turret, new_shooting_speed / old_shooting_speed, id)
        end
    end
end

randomizations.underground_belt_distance = function(id)
    for _, belt in pairs(data.raw["underground-belt"]) do
        local old_distance = belt.max_distance

        randomize({
            id = id,
            prototype = belt,
            property = "max_distance",
            abs_min = 2,
            abs_max = 255,
            range_max = "very_big",
            rounding = "discrete"
        })

        locale_utils.create_localised_description(belt, belt.max_distance / old_distance, id)
    end
end

randomizations.unit_attack_speed = function(id)
    for _, unit_class in pairs({"unit", "spider-unit"}) do
        if data.raw[unit_class] ~= nil then
            for _, unit in pairs(data.raw[unit_class]) do
                local old_attack_speed = 1 / unit.attack_parameters.cooldown

                -- To attacks per second
                unit.attack_parameters.cooldown = 60 / unit.attack_parameters.cooldown
                randomize({
                    id = id,
                    prototype = unit,
                    tbl = unit.attack_parameters,
                    property = "cooldown",
                    rounding = "discrete_float",
                    range = "small",
                    dir = -1
                })
                -- Back to ticks per attack
                unit.attack_parameters.cooldown = 60 / unit.attack_parameters.cooldown

                local new_attack_speed = 1 / unit.attack_parameters.cooldown
                locale_utils.create_localised_description(unit, new_attack_speed / old_attack_speed, id, {flipped = true})
            end
        end
    end
end

randomizations.unit_melee_damage = function(id)
    for _, unit_class in pairs({"unit", "spider-unit"}) do
        if data.raw[unit_class] ~= nil then
            for _, unit in pairs(data.raw[unit_class]) do
                local attack_parameters = unit.attack_parameters

                if attack_parameters.damage_modifier == nil then
                    attack_parameters.damage_modifier = 1
                end

                local old_damage = attack_parameters.damage_modifier

                randomize({
                    id = id,
                    prototype = unit,
                    tbl = attack_parameters,
                    property = "damage_modifier",
                    range = "small",
                    dir = -1,
                    rounding = "discrete_float"
                })

                locale_utils.create_localised_description(unit, attack_parameters.damage_modifier / old_damage, id, {flipped = true})
            end
        end
    end
end

-- Doesn't include gleba spider-units or vulcanus segmented-units (those move in different ways)
randomizations.unit_movement_speed = function(id)
    for _, unit in pairs(data.raw.unit) do
        if unit.movement_speed > 0 then
            local old_movement_speed = unit.movement_speed

            -- To km/h
            unit.movement_speed = unit.movement_speed * 216
            randomize({
                id = id,
                prototype = unit,
                property = "movement_speed",
                range = "small",
                dir = -1,
                rounding = "discrete_float"
            })
            -- Back to tiles per tick
            unit.movement_speed = unit.movement_speed / 216

            locale_utils.create_localised_description(unit, unit.movement_speed / old_movement_speed, id, {flipped = true})
        end
    end
end

randomizations.unit_pollution_to_join_attack = function(id)
    for _, unit_class in pairs({"unit", "spider-unit"}) do
        if data.raw[unit_class] ~= nil then
            for _, unit in pairs(data.raw[unit_class]) do
                if unit.absorptions_to_join_attack ~= nil then
                    for pollutant_id, pollutant_amount in pairs(unit.absorptions_to_join_attack) do
                        randomize({
                            id = id,
                            prototype = unit,
                            tbl = unit.absorptions_to_join_attack,
                            property = pollutant_id,
                            range = "very_small",
                            rounding = "discrete_float"
                        })

                        locale_utils.create_localised_description(unit, unit.absorptions_to_join_attack[pollutant_id] / pollutant_amount, id, {addons = " (" .. pollutant_id .. ")"})
                    end
                end
            end
        end
    end
end

-- New
-- Not added to spec yet
randomizations.unit_spawner_time_to_capture = function(id)
    for _, spawner in pairs(data.raw["unit-spawner"]) do
        randomize({
            id = id,
            prototype = spawner,
            property = "time_to_capture"
        })
    end
end

randomizations.vehicle_crash_damage = function(id)
    for vehicle_class, _ in pairs(categories.vehicles) do
        for _, vehicle in pairs(data.raw[vehicle_class]) do
            local old_energy_per_hit_point = vehicle.energy_per_hit_point

            randomize({
                id = id,
                prototype = vehicle,
                property = "energy_per_hit_point",
                rounding = "discrete_float",
                variance = "big",
            })

            -- Increase flat impact resistance for higher crash damages so that this isn't just a glass cannon
            -- Doesn't apply if vehicle didn't have any impact resistance to start with
            if vehicle.resistances ~= nil then
                for _, resistance in pairs(vehicle.resistances) do
                    if resistance.type == "impact" and resistance.decrease ~= nil then
                        -- energy_per_hit_point can't be zero, so we don't need to check for that
                        resistance.decrease = resistance.decrease * vehicle.energy_per_hit_point / old_energy_per_hit_point
                    end
                end
            end

            locale_utils.create_localised_description(vehicle, vehicle.energy_per_hit_point / old_energy_per_hit_point, id, { variance = "big" })
        end
    end
end

-- New
randomizations.vehicle_effectivity = function(id)
    -- Effectivity for cars and locomotives are in separate spots
    for _, car in pairs(data.raw.car) do
        local old_value = car.effectivity
        randomize({
            id = id,
            prototype = car,
            property = "effectivity",
            range = "big",
            rounding = "discrete_float",
            variance = "big",
        })
        local factor = car.effectivity / old_value
        locale_utils.create_localised_description(car, factor, id, { variance = "big" })
    end

    for _, vehicle_class in pairs({"locomotive", "spider-vehicle"}) do
        for _, vehicle in pairs(data.raw[vehicle_class]) do
            local energy_source = vehicle.energy_source

            if energy_source.type == "burner" then
                if energy_source.effectivity == nil then
                    energy_source.effectivity = 1
                end
                
                local old_value = energy_source.effectivity

                randomize({
                    id = id,
                    prototype = vehicle,
                    tbl = energy_source,
                    property = "effectivity",
                    range = "big",
                    rounding = "discrete_float",
                    variance = "big",
                })
                
                local factor = energy_source.effectivity / old_value
                locale_utils.create_localised_description(vehicle, factor, id, { variance = "big" })
            end
        end
    end
end

randomizations.vehicle_power = function(id)
    for vehicle_class, power_key in pairs({car = "consumption", ["spider-vehicle"] = "movement_energy_consumption", locomotive = "max_power"}) do
        for _, vehicle in pairs(data.raw[vehicle_class]) do
            local old_power = 60 * util.parse_energy(vehicle[power_key])

            if old_power > 0 then
                randomizations.energy({
                    is_power = true,
                    id = id,
                    prototype = vehicle,
                    property = power_key,
                    range = "big",
                    rounding = "discrete_float",
                    variance = "big",
                })
                local new_power = 60 * util.parse_energy(vehicle[power_key])

                -- Scale braking force with the new consumption for improved user experience
                if vehicle.braking_power ~= nil then
                    local braking_power_as_number = 60 * util.parse_energy(vehicle.braking_power)
                    braking_power_as_number = braking_power_as_number * new_power / old_power
                    vehicle.braking_power = braking_power_as_number .. "W"
                else
                    -- In this case, vehicle.braking_force must be set
                    vehicle.braking_force = vehicle.braking_force * new_power / old_power
                end

                locale_utils.create_localised_description(vehicle, new_power / old_power, id, { variance = "big" })
            end
        end
    end
end

randomizations.vehicle_weight = function(id)
    for vehicle_class, _ in pairs(categories.vehicles) do
        for _, vehicle in pairs(data.raw[vehicle_class]) do
            local old_value = vehicle.weight

            randomize({
                id = id,
                prototype = vehicle,
                property = "weight",
                rounding = "discrete_float",
                variance = "big",
                dir = -1,
            })

            local factor = vehicle.weight / old_value

            locale_utils.create_localised_description(vehicle, factor, id, { variance = "big", flipped = true })
        end
    end
end