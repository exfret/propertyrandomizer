local categories = require("helper-tables/categories")
local randnum = require("lib/random/randnum")
local rng = require("lib/random/rng")
local locale_utils = require("lib/locale")

local randomize = randnum.rand

randomizations.accumulator_buffer = function(id)
    for _, accumulator in pairs(data.raw.accumulator) do
        if accumulator.energy_source.buffer_capacity ~= nil then
            local old_buffer_capacity = util.parse_energy(accumulator.energy_source.buffer_capacity)
            
            randomizations.energy({
                id = id,
                prototype = accumulator,
                tbl = accumulator.energy_source,
                property = "buffer_capacity"
            })

            local factor = util.parse_energy(accumulator.energy_source.buffer_capacity) / old_buffer_capacity
            accumulator.localised_description = locale_utils.create_localised_description(accumulator, factor, id)
        end
    end
end

randomizations.accumulator_input_flow = function(id)
    for _, accumulator in pairs(data.raw.accumulator) do
        if accumulator.energy_source.input_flow_limit ~= nil then
            randomizations.energy({
                is_power = true,
                id = id,
                prototype = accumulator,
                tbl = accumulator.energy_source,
                property = "input_flow_limit"
            })
        end
    end
end

randomizations.accumulator_output_flow = function(id)
    for _, accumulator in pairs(data.raw.accumulator) do
        if accumulator.energy_source.output_flow_limit ~= nil then
            randomizations.energy({
                is_power = true,
                id = id,
                prototype = accumulator,
                tbl = accumulator.energy_source,
                property = "output_flow_limit"
            })
        end
    end
end

-- New
-- Check TODO's before adding
randomizations.agricultural_tower_radius = function(id)
    for _, ag_tower in pairs(data.raw["agricultural-tower"]) do
        randomize({
            id = id,
            prototype = ag_tower,
            property = "radius",
            abs_min = 2,
            range = "small",
            variance = "small",
            rounding = "discrete" -- TODO: Does it actually need to be discrete?
        })

        -- TODO: Do I need to change growth_grid_tile_size or growth_area_radius??
    end
end

-- New
randomizations.asteroid_collector_offset = function(id)
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

-- New
-- Check TODO's before adding
randomizations.asteroid_collector_radius = function(id)
    for _, collector in pairs(data.raw["asteroid-collector"]) do
        randomize({
            id = id,
            prototype = collector,
            property = "collection_radius",
            range = "small",
            variance = "small"
        })

        -- TODO: There are a few other radius keys, do those need to be changed too?
    end
end

-- New
randomizations.asteroid_collector_speed = function(id)
    for _, collector in pairs(data.raw["asteroid-collector"]) do
        if collector.arm_speed_base ~= nil then
            local old_arm_speed = collector.arm_speed_base

            randomize({
                id = id,
                prototype = collector,
                property = "arm_speed_base",
                range = "small",
                variance = "small"
            })

            -- Increase quality scaling by same amount
            if collector.arm_speed_quality_scaling ~= nil then
                collector.arm_speed_quality_scaling = collector.arm_speed_quality_scaling * collector.arm_speed_base / old_arm_speed
            end
        end
    end
end

-- New
randomizations.asteroid_mass = function(id)
    for _, asteroid in pairs(data.raw.asteroid) do
        if asteroid.mass == nil then
            asteroid.mass = 1
        end

        randomize({
            id = id,
            prototype = asteroid,
            property = "mass",
            range = "small",
            variance = "small"
        })
    end
end

randomizations.beacon_distribution_effectivity = function(id)
    for _, beacon in pairs(data.raw.beacon) do
        local old_distribution_effectivity = beacon.distribution_effectivity

        randomize({
            id = id,
            prototype = beacon,
            property = "distribution_effectivity",
            range = "small",
            variance = "small"
        })

        beacon.localised_description = locale_utils.create_localised_description(beacon, beacon.distribution_effectivity / old_distribution_effectivity, id)
    end
end

randomizations.beacon_supply_area = function(id)
    for _, beacon in pairs(data.raw.beacon) do
        local old_supply_distance = beacon.supply_area_distance

        randomize({
            id = id,
            prototype = beacon,
            property = "supply_area_distance",
            abs_min = 2,
            abs_max = 64,
            range = "small",
            variance = "small",
            rounding = "discrete"
        })

        beacon.localised_description = locale_utils.create_localised_description(beacon, beacon.supply_area_distance / old_supply_distance, id)
    end
end

-- New
randomizations.beam_damage = function(id)
    for _, beam in pairs(data.raw.beam) do
        if beam.action ~= nil then
            randomizations.trigger({
                id = id,
                prototype = beam
            }, beam.action, "damage")
        end
    end
end

-- New
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
        rounding = "pure_discrete"
    })

    -- Undo earlier multiplication by 256
    for ind, belt in pairs(belts) do
        belt.speed = belt.speed / 256

        belt.localised_description = locale_utils.create_localised_description(belt, belt.speed / old_speeds[ind], id)
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
            variance = "small"
        })

        boiler.localised_description = locale_utils.create_localised_description(boiler, util.parse_energy(boiler.energy_consumption) / old_consumption, id)
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
                    variance = "small",
                    dir = -1
                })

                local new_energy_per_move = util.parse_energy(bot.energy_per_move)

                -- Scale energy_per_tick and max_energy accordingly
                if bot.energy_per_tick ~= nil then
                    local energy_per_tick_as_num = util.parse_energy(bot.energy_per_tick)
                    energy_per_tick_as_num = energy_per_tick_as_num * new_energy_per_move / old_energy_per_move
                    bot.energy_per_tick = energy_per_tick_as_num .. "J"
                end
                if bot.max_energy ~= nil then
                    local max_energy_as_num = util.parse_energy(bot.max_energy)
                    max_energy_as_num = max_energy_as_num * new_energy_per_move / old_energy_per_move
                    bot.max_energy = max_energy_as_num .. "J"
                end

                bot.localised_description = locale_utils.create_localised_description(bot, new_energy_per_move / old_energy_per_move, id, {flipped = true})
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

                    -- Bias toward faster bots
                    randomize({
                        id = id,
                        prototype = bot,
                        property = "speed",
                        range_min = "small",
                        range_max = "big",
                        bias = 0.03
                    })

                    if bot.max_speed ~= nil then
                        bot.max_speed = bot.max_speed * bot.speed / old_speed
                    end

                    bot.localised_description = locale_utils.create_localised_description(bot, bot.speed / old_speed, id)
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
            variance = "small"
        })

        burner_generator.localised_description = locale_utils.create_localised_description(burner_generator, util.parse_energy(burner_generator.max_power_output) / old_output, id)
    end
end

-- New
randomizations.capture_robot_capture_speed = function(id)
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

-- New
randomizations.capture_robot_search_radius = function(id)
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
                property = "rotation_speed"
            })

            car.localised_description = locale_utils.create_localised_description(car, car.rotation_speed / old_rotation_speed, id)
        end
    end
end

-- Includes linked randomization based on crafting speeds
randomizations.crafting_machine_speed = function(id)
    -- Separate by crafting category
    local function category_str(machine)
        local separator = "aaa"
        cat_str = ""
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
            property = "crafting_speed"
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

            machine.localised_description = locale_utils.create_localised_description(machine, machine.crafting_speed / machine_to_old_speed[machine.name], id)
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
        abs_min = 2,
        abs_max = 64
    })

    for _, electric_pole in pairs(electric_poles) do
        if electric_pole_to_old_wire_dist[electric_pole.name] > 0 then
            electric_pole.localised_description = locale_utils.create_localised_description(electric_pole, electric_pole.maximum_wire_distance / electric_pole_to_old_wire_dist[electric_pole.name], id)
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
    end

    randomizations.linked({
        id = id,
        prototypes = electric_poles,
        property = "supply_area_distance",
        abs_min = 2,
        abs_max = 64
    })

    -- Fix even/odd placement on center of pole
    for _, electric_pole in pairs(data.raw["electric-pole"]) do
        local odd_placement
        if electric_pole.collision_box ~= nil then
            -- Just consider width parity
            -- CRITICAL TODO: I don't think this actually works? See fluid-box randomization
            local collision_box_width_parity = math.floor(electric_pole.collision_box[2][1] - electric_pole.collision_box[1][1] + 0.5) % 2
            if collision_box_width_parity == 0 then
                odd_placement = true
            end
        end
        if odd_placement then
            electric_pole.supply_area_distance = math.min(63.5, math.floor(electric_pole.supply_area_distance + 1) - 0.5)
        else
            electric_pole.supply_area_distance = math.min(64, math.floor(electric_pole.supply_area_distance + 0.5))
        end

        electric_pole.localised_description = locale_utils.create_localised_description(electric_pole, electric_pole.supply_area_distance / electric_pole_to_old_supply_area[electric_pole.name], id)
    end
end

randomizations.gate_opening_speed = function(id)
    for _, gate in pairs(data.raw.gate) do
        if gate.opening_speed > 0 then
            local old_opening_speed = gate.opening_speed

            randomize({
                id = id,
                prototype = gate,
                property = "opening_speed"
            })

            -- Also modifies activation distance to compensate
            gate.activation_distance = gate.activation_distance * old_opening_speed / gate.opening_speed

            gate.localised_description = locale_utils.create_localised_description(gate, gate.opening_speed / old_opening_speed, id)
        end
    end
end

randomizations.generator_fluid_usage = function(id)
    for _, generator in pairs(data.raw.generator) do
        local old_fluid_usage = generator.fluid_usage_per_tick

        randomize({
            id = id,
            prototype = generator,
            property = "fluid_usage_per_tick"
        })

        generator.localised_description = locale_utils.create_localised_description(generator, generator.fluid_usage_per_tick / old_fluid_usage, id)
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
    end

    for _, list in pairs(inserter_lists) do
        randomizations.linked({
            id = id,
            prototypes = list,
            property = "rotation_speed",
            range_min = "small",
            range_max = "very_big",
            variance = "big"
        })
    end

    -- Fix extension speed
    for _, inserter in pairs(data.raw.inserter) do
        inserter.extension_speed = inserter.extension_speed * inserter.rotation_speed / old_rotation_speeds[inserter.name]
        
        inserter.localised_description = locale_utils.create_localised_description(inserter, inserter.rotation_speed / old_rotation_speeds[inserter.name], id)
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
        abs_min = 2,
        rounding = "discrete"
    })
    for _, container in pairs(container_list) do
        container.localised_description = locale_utils.create_localised_description(container, container.inventory_size / container_to_old_size[container.name], id)
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
        abs_min = 2,
        rounding = "discrete"
    })
    for _, cargo_wagon in pairs(wagon_list) do
        cargo_wagon.localised_description = locale_utils.create_localised_description(cargo_wagon, cargo_wagon.inventory_size / wagon_to_old_size[cargo_wagon.name], id)
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
                    abs_min = 2,
                    rounding = "discrete"
                })

                entity.localised_description = locale_utils.create_localised_description(entity, entity.inventory_size / old_inventory_size, id)
            end
        end
    end
end

-- TODO: If I don't go with duplication, deifinitely make this a small range
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
            variance = "small"
        })

        lab.localised_description = locale_utils.create_localised_description(lab, lab.researching_speed / old_speed, id)
    end
end

randomizations.landmine_damage = function(id)
    for _, landmine in pairs(data.raw["land-mine"]) do
        if landmine.action ~= nil then
            randomizations.trigger({
                id = id,
                prototype = landmine
            }, landmine.action, "damage")
        end
    end
end

randomizations.landmine_effect_radius = function(id)
    for _, landmine in pairs(data.raw["land-mine"]) do
        if landmine.action ~= nil then
            randomizations.trigger({
                id = id,
                prototype = landmine
            }, landmine.action, "effect-radius")
        end
    end
end

randomizations.landmine_timeout = function(id)
    for _, landmine in pairs(data.raw["land-mine"]) do
        if landmine.timeout == nil then
            landmine.timeout = 120
        end

        randomize({
            id = id,
            prototype = landmine,
            property = "timeout",
            range = "big",
            variance = "big"
        })
    end
end

randomizations.landmine_trigger_radius = function(id)
    for _, landmine in pairs(data.raw["land-mine"]) do
        randomize({
            id = id,
            prototype = landmine,
            property = "trigger_radius",
            range = "big",
            variance = "big"
        })
    end
end

randomizations.machine_energy_usage = function(id)
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
                        dir = -1
                    })

                    local new_first_energy_val = util.parse_energy(entity[energy_properties[1]])

                    -- Scale all energy vals up the same way
                    for i = 2, #energy_properties do
                        local curr_energy_val = util.parse_energy(entity[energy_properties[i]])
                        local suffix = "J"
                        if ind_to_is_power[i] then
                            curr_energy_val = 60 * curr_energy_val
                            suffix = "W"
                        end
                        curr_energy_val = curr_energy_val * new_first_energy_val / old_first_energy_val
                        entity[energy_properties[i]] = curr_energy_val .. suffix
                    end

                    -- Update description
                    entity.localised_description = locale_utils.create_localised_description(entity, new_first_energy_val / old_first_energy_val, id, {flipped = true})
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
                property = "energy_consumption"
            })

            electric_turret.localised_description = locale_utils.create_localised_description(electric_turret, util.parse_energy(electric_turret.attack_parameters.ammo_type.energy_consumption) / old_energy_consumption, id, {flipped = true})
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
                            for pollutant_id, pollutant_amount in pairs(energy_source.emissions_per_minute) do
                                local old_pollution = pollutant_amount

                                randomize({
                                    id = id,
                                    prototype = entity,
                                    tbl = energy_source.emissions_per_minute,
                                    property = pollutant_id,
                                    range = "small",
                                    variance = "small"
                                })

                                entity.localised_description = locale_utils.create_localised_description(entity, energy_source.emissions_per_minute[pollutant_id] / old_pollution, id, {addons = " (" .. pollutant_id .. ")", flipped = true})
                            end
                        end
                    end
                end
            end
        end
    end
end

randomizations.max_health = function(id)
    -- Entities with health where it's sensitive enough not to randomize, or where randomization doesn't make sense
    -- Allow turrets and other military items to be randomized, we'll just dupe those
    -- These things are much harder to dupe on the other hand
    local health_blacklist = {
        ["character"] = true,
        ["spider-leg"] = true,
        ["turret"] = true,
        ["unit"] = true,
        ["unit-spawner"] = true
    }

    -- Just check whether the max_health key is non-nil
    -- Some entities can have health but have this be nil since it's optional, let's just not worry about those
    for entity_class, _ in pairs(defines.prototypes.entity) do
        if not health_blacklist[entity_class] then
            if data.raw[entity_class] ~= nil then
                for _, entity in pairs(data.raw[entity_class]) do
                    if entity.max_health ~= nil then
                        local old_max_health = entity.max_health

                        randomize({
                            id = id,
                            prototype = entity,
                            property = "max_health",
                            rounding = "discrete"
                        })

                        entity.localised_description = locale_utils.create_localised_description(entity, entity.max_health / old_max_health, id)
                    end
                end
            end
        end
    end
end

-- New
randomizations.mining_fluid_amount_needed = function(id)
    for entity_class, _ in pairs(data.raw.entity) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                if entity.minable ~= nil and entity.minable.required_fluid ~= nil then
                    randomize({
                        id = id,
                        prototype = entity,
                        tbl = entity.minable,
                        property = "fluid_amount"
                    })
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
            variance = "small"
        })

        mining_drill.localised_description = locale_utils.create_localised_description(mining_drill, mining_drill.mining_speed / old_mining_speed, id)
    end
end

-- New
randomizations.mining_times = function(id)
    for entity_class, _ in pairs(data.raw.entity) do
        if entity_class ~= "resource" and data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                if entity.minable ~= nil then
                    randomize({
                        id = id,
                        prototype = entity,
                        tbl = entity.minable,
                        property = "mining_time",
                        range = "small",
                        variance = "small"
                    })
                end
            end
        end
    end
end

-- New
randomizations.mining_times_resource = function(id)
    for _, resource in pairs(data.raw.resource) do
        if resource.minable ~= nil then
            randomize({
                id = id,
                prototype = resource,
                tbl = resource.minable,
                property = "mining_time",
                range = "small",
                variance = "small"
            })
        end
    end
end

randomizations.module_slots = function(id)
    for entity_class, _ in pairs(categories.entities_with_module_slots) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                if entity.module_slots ~= nil and entity.module_slots > 0 then
                    local old_module_slots = entity.module_slots

                    randomize({
                        id = id,
                        prototype = entity,
                        property = "module_slots",
                        rounding = "discrete",
                        abs_min = 1
                    })

                    entity.localised_description = locale_utils.create_localised_description(entity, entity.module_slots / old_module_slots, id)
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
            variance = "very_big",
            bias = -0.05
        })

        offshore_pump.localised_description = locale_utils.create_localised_description(offshore_pump, offshore_pump.pumping_speed / old_pumping_speed, id)
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
        abs_max = 255
    })

    for _, pipe in pairs(data.raw["pipe-to-ground"]) do
        for ind, pipe_connection in pairs(pipe.fluid_box.pipe_connections) do
            if pipe_connection.max_underground_distance ~= nil and pipe_connection.max_underground_distance > 0 then
                pipe.localised_description = locale_utils.create_localised_description(pipe, pipe_connection.max_underground_distance / pipe_to_old_underground_distances[pipe.name][ind], id, {addons = " (Pipe connection " .. ind .. ")"})
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
            property = "pumping_speed"
        })

        pump.localised_description = locale_utils.create_localised_description(pump, pump.pumping_speed / old_pumping_speed, id)
    end
end

randomizations.radar_reveal_area = function(id)
    for _, radar in pairs(data.raw.radar) do
        local old_reveal_area = radar.max_distance_of_nearby_sector_revealed

        randomize({
            id = id,
            prototype = radar,
            property = "max_distance_of_nearby_sector_revealed",
            abs_min = 2,
            range = "small",
            variance = "small",
            rounding = "discrete"
        })

        radar.localised_description = locale_utils.create_localised_description(radar, radar.max_distance_of_nearby_sector_revealed / old_reveal_area, id)
    end
end

randomizations.radar_search_area = function(id)
    for _, radar in pairs(data.raw.radar) do
        local old_search_area = radar.max_distance_of_sector_revealed

        randomize({
            id = id,
            prototype = radar,
            property = "max_distance_of_sector_revealed",
            rounding = "discrete"
        })

        radar.localised_description = locale_utils.create_localised_description(radar, radar.max_distance_of_sector_revealed / old_search_area, id)
    end
end

randomizations.reactor_consumption = function(id)
    for _, reactor in pairs(data.raw.reactor) do
        local old_consumption = util.parse_energy(reactor.consumption)

        randomizations.energy({
            is_power = true,
            id = id,
            prototype = reactor,
            property = "consumption"
        })

        reactor.localised_description = locale_utils.create_localised_description(reactor, util.parse_energy(reactor.consumption) / old_consumption, id)
    end
end

randomizations.reactor_neighbour_bonus = function(id)
    for _, reactor in pairs(data.raw.reactor) do
        if reactor.neighbour_bonus == nil then
            reactor.neighbour_bonus = 1
        end

        local old_neighbour_bonus = reactor.neighbour_bonus

        randomize({
            id = id,
            prototype = reactor,
            property = "neighbour_bonus"
        })

        reactor.localised_description = locale_utils.create_localised_description(reactor, reactor.neighbour_bonus / old_neighbour_bonus, id)
    end
end

randomizations.roboport_inventory = function(id)
    for _, roboport in pairs(data.raw.roboport) do
        randomize({
            id = id,
            prototype = roboport,
            property = "material_slots_count",
            range = "small",
            variance = "small",
            rounding = "discrete"
        })

        randomize({
            id = id,
            prototype = roboport,
            property = "robot_slots_count",
            range = "small",
            variance = "small",
            rounding = "discrete"
        })
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
            variance = "small"
        })

        roboport.localised_description = locale_utils.create_localised_description(roboport, util.parse_energy(roboport.charging_energy) / old_charging_rate, id)
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

            roboport.localised_description = locale_utils.create_localised_description(roboport, roboport.charging_station_count / old_station_count, id)
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
                rounding = "discrete"
            })

            -- Make sure construction radius is at least as large as logistics radius
            if roboport.construction_radius < roboport.logistics_radius then
                roboport.construction_radius = roboport.logistics_radius
            end

            roboport.localised_description = locale_utils.create_localised_description(roboport, roboport.construction_radius / old_construction_radius, id)
        end
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
            rounding = "discrete"
        })

        -- Scale up logistics connection distance with logistic radius
        if roboport.logistics_connection_distance ~= nil then
            if old_logistics_radius ~= 0 then
                roboport.logistics_connection_distance = roboport.logistics_connection_distance * roboport.logistics_radius / old_logistics_radius
            end
        end

        roboport.localised_description = locale_utils.create_localised_description(roboport, roboport.logistics_radius / old_logistics_radius, id)
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
            variance = "small",
            dir = -1
        })

        rocket_silo.localised_description = locale_utils.create_localised_description(rocket_silo, rocket_silo.rocket_parts_required / old_rocket_parts_required, id)
    end
end

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

        rocket_silo.localised_description = locale_utils.create_localised_description(rocket_silo, time_factor, id, {flipped = true})
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
            range_min = "small"
        })

        solar_panel.localised_description = locale_utils.create_localised_description(solar_panel, util.parse_energy(solar_panel.production) / old_production, id)
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
            variance = "big"
        })

        storage_tank.localised_description = locale_utils.create_localised_description(storage_tank, storage_tank.fluid_box.volume / old_capacity, id)
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
                property = "damage_modifier"
            })

            turret.localised_description = locale_utils.create_localised_description(turret, attack_parameters.damage_modifier / old_damage_modifier, id)
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
                randomize({
                    id = id,
                    prototype = turret,
                    tbl = attack_parameters,
                    property = "min_range",
                    abs_max = 2 / 3 * attack_parameters.range,
                    range = "small",
                    variance = "small",
                    dir = -1
                })

                turret.localised_description = locale_utils.create_localised_description(turret, attack_parameters.min_range / old_min_range, id, {flipped = true})
            end
        end
    end
end

randomizations.turret_range = function(id)
    for turret_class, _ in pairs(categories.turrets) do
        for _, turret in pairs(data.raw[turret_class]) do
            local attack_parameters = turret.attack_parameters

            local old_range = attack_parameters.range

            randomize({
                id = id,
                prototype = turret,
                tbl = attack_parameters,
                property = "range",
                range = "small"
            })

            -- Randomize minimum range by a proportional amount if it exists
            if attack_parameters.min_range ~= nil then
                attack_parameters.min_range = attack_parameters.min_range * attack_parameters.range / old_range
            end
            if attack_parameters.min_attack_distance ~= nil then
                attack_parameters.min_attack_distance = attack_parameters.min_attack_distance * attack_parameters.range / old_range
            end
            if turret.prepare_range ~= nil then
                turret.prepare_range = turret.prepare_range * attack_parameters.range / old_range
            end

            turret.localised_description = locale_utils.create_localised_description(turret, attack_parameters.range / old_range, id)
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
                property = "rotation_speed"
            })

            turret.localised_description = locale_utils.create_localised_description(turret, turret.rotation_speed / old_rotation_speed, id)
        end
    end

    -- Artillery wagons and artillery turrets not included as turrets, so we need to do them separately
    for _, turret_class in pairs({"artillery-turret", "artillery-wagon"}) do
        for _, turret in pairs(data.raw[turret_class]) do
            local old_rotation_speed = turret.turret_rotation_speed

            randomize({
                id = id,
                prototype = turret,
                property = "turret_rotation_speed"
            })

            turret.localised_description = locale_utils.create_localised_description(turret, turret.turret_rotation_speed / old_rotation_speed, id)
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
            property = "turret_rotation_speed"
        })

        car.localised_description = locale_utils.create_localised_description(car, car.turret_rotation_speed / old_rotation_speed, id)
    end
end

randomizations.turret_shooting_speed = function(id)
    for turret_class, _ in pairs(categories.turrets) do
        for _, turret in pairs(data.raw[turret_class]) do
            local old_shooting_speed = 1 / turret.attack_parameters.cooldown

            -- Rounding is technically off but that's fine
            randomize({
                id = id,
                prototype = turret,
                tbl = turret.attack_parameters,
                property = "cooldown",
                range = "small",
                variance = "small",
                dir = -1,
                rounding = "none"
            })

            local new_shooting_speed = 1 / turret.attack_parameters.cooldown
            turret.localised_description = locale_utils.create_localised_description(turret, new_shooting_speed / old_shooting_speed, id)
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
            variance = "big"
        })

        belt.localised_description = locale_utils.create_localised_description(belt, belt.max_distance / old_distance, id)
    end
end

randomizations.unit_attack_speed = function(id)
    for _, unit_class in pairs({"unit", "spider-unit"}) do
        if data.raw[unit_class] ~= nil then
            for _, unit in pairs(data.raw[unit_class]) do
                local old_attack_speed = unit.attack_parameters.cooldown

                -- Rounding is technically off but that's fine
                randomize({
                    id = id,
                    prototype = unit,
                    tbl = unit.attack_parameters,
                    property = "cooldown",
                    rounding = "none",
                    range = "small",
                    variance = "small"
                })

                local new_attack_speed = unit.attack_parameters.cooldown
                unit.localised_description = locale_utils.create_localised_description(unit, new_attack_speed / old_attack_speed, id, {flipped = true})
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
                    variance = "small",
                    dir = -1
                })

                unit.localised_description = locale_utils.create_localised_description(unit, attack_parameters.damage_modifier / old_damage, id, {flipped = true})
            end
        end
    end
end

-- Doesn't include gleba spider-units or vulcanus segmented-units (those move in different ways)
randomizations.unit_movement_speed = function(id)
    for _, unit in pairs(data.raw.unit) do
        if unit.movement_speed > 0 then
            local old_movement_speed = unit.movement_speed

            randomize({
                id = id,
                prototype = unit,
                property = "movement_speed",
                range = "small",
                variance = "small",
                dir = -1
            })

            unit.distance_per_frame = unit.distance_per_frame * unit.movement_speed / old_movement_speed

            unit.localised_description = locale_utils.create_localised_description(unit, unit.movement_speed / old_movement_speed, id, {flipped = true})
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
                            variance = "very_small"
                        })

                        unit.localised_description = locale_utils.create_localised_description(unit, unit.absorptions_to_join_attack[pollutant_id] / pollutant_amount, id, {addons = " (" .. pollutant_id .. ")"})
                    end
                end
            end
        end
    end
end

-- New
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
                property = "energy_per_hit_point"
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

            vehicle.localised_description = locale_utils.create_localised_description(vehicle, vehicle.energy_per_hit_point / old_energy_per_hit_point, id)
        end
    end
end

-- New
randomizations.vehicle_effectivity = function(id)
    -- Effectivity for cars and locomotives are in separate spots
    for _, car in pairs(data.raw.car) do
        randomize({
            id = id,
            prototype = car,
            property = "effectivity",
            range = "big",
            variance = "big"
        })
    end

    for _, vehicle_class in pairs({"locomotive", "spider-vehicle"}) do
        for _, vehicle in pairs(data.raw[vehicle_class]) do
            local energy_source = vehicle.energy_source

            if energy_source.type == "burner" then
                if energy_source.effectivity == nil then
                    energy_source.effectivity = 1
                end

                randomize({
                    id = id,
                    prototype = vehicle,
                    property = "effectivity",
                    range = "big",
                    variance = "big"
                })
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
                    variance = "big"
                })
                local new_power = 60 * util.parse_energy(vehicle[power_key]) 
                
                -- Scale braking force with the new consumption for improved user experience
                if vehicle.braking_power ~= nil then
                    braking_power_as_number = 60 * util.parse_energy(vehicle.braking_power)
                    braking_power_as_number = braking_power_as_number * new_power / old_power
                    vehicle.braking_power = braking_power_as_number .. "W"
                else
                    -- In this case, vehicle.braking_force must be set
                    vehicle.braking_force = vehicle.braking_force * new_power / old_power
                end

                vehicle.localised_description = locale_utils.create_localised_description(vehicle, new_power / old_power, id)
            end
        end
    end
end