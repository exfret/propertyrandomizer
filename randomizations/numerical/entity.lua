local categories = require("helper-tables/categories")
local randnum = require("lib/random/randnum")
local rng = require("lib/random/rng")

local randomize = randnum.rand

randomizations.accumulator_buffer = function(id)
    for _, accumulator in pairs(data.raw.accumulator) do
        if accumulator.energy_source.buffer_capacity ~= nil then
            randomizations.energy({
                id = id,
                prototype = accumulator,
                tbl = accumulator.energy_source,
                property = "buffer_capacity"
            })
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
        randomize({
            id = id,
            prototype = beacon,
            property = "distribution_effectivity",
            range = "small",
            variance = "small"
        })
    end
end

randomizations.beacon_supply_area = function(id)
    for _, beacon in pairs(data.raw.beacon) do
        randomize({
            id = id,
            prototype = beacon,
            property = "supply_area_distance",
            abs_min = 2,
            range = "small",
            variance = "small",
            rounding = "discrete"
        })
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
            property = "damage_interval"
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
            property = "width"
        })
    end
end

-- Includes tiered randomization based off belt speeds
randomizations.belt_speed = function(id)
    local belts = {}
    for belt_class, _ in pairs(categories.belts) do
        for _, belt in pairs(data.raw[belt_class]) do
            table.insert(belts, belt)
            -- Multiply belt speed by 256 so that it rounds correctly
            belt.speed = belt.speed * 256
        end
    end

    randomizations.linked({
        id = id,
        prototypes = belts,
        property = "speed",
        rounding = "pure_discrete"
    })

    -- Undo earlier multiplication by 256
    for _, belt in pairs(belts) do
        belt.speed = belt.speed / 256
    end
end

randomizations.boiler_consumption = function(id)
    for _, boiler in pairs(data.raw.boiler) do
        randomizations.energy({
            is_power = true,
            id = id,
            prototype = boiler,
            property = "energy_consumption",
            range = "small",
            variance = "small"
        })
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
            end
        end
    end
end

randomizations.bot_speed = function(id)
    for bot_class, _ in pairs(categories.bot_classes) do
        if data.raw[bot_class] ~= nil then
            for _, bot in pairs(data.raw[bot_class]) do
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

                if bot.max_speed ~= nil and old_speed ~= 0 then
                    bot.max_speed = bot.max_speed * bot.speed / old_speed
                end
            end
        end
    end
end

randomizations.burner_generator_output = function(id)
    for _, burner_generator in pairs(data.raw["burner-generator"]) do
        randomizations.energy({
            is_power = true,
            id = id,
            prototype = burner_generator,
            property = "max_power_output",
            range = "small",
            variance = "small"
        })
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

randomizations.car_rotation_speed = function(id)
    for _, car in pairs(data.raw.car) do
        randomize({
            id = id,
            prototype = car,
            property = "rotation_speed"
        })
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
        end
    end
end

-- Includes linked randomization based on supply area
randomizations.electric_pole_supply_area = function(id)
    local electric_poles = {}
    for _, electric_pole in pairs(data.raw["electric-pole"]) do
        table.insert(electric_poles, electric_pole)
    end

    randomizations.linked({
        id = id,
        prototypes = electric_poles,
        property = "supply_area_distance",
        abs_min = 4,
        abs_max = 64
    })

    -- Fix even/odd placement on center of pole
    for _, electric_pole in pairs(data.raw["electric-pole"]) do
        local odd_placement
        if electric_pole.collision_box ~= nil then
            -- Just consider width parity
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
    end
end

-- TODO: Electric pole distribution range!

randomizations.gate_opening_speed = function(id)
    for _, gate in pairs(data.raw.gate) do
        local old_opening_speed = gate.opening_speed

        randomize({
            id = id,
            prototype = gate,
            property = "opening_speed"
        })

        -- Also modifies activation distance to compensate
        if gate.opening_speed > 0 then
            gate.activation_distance = gate.activation_distance * old_opening_speed / gate.opening_speed
        end
    end
end

randomizations.generator_fluid_usage = function(id)
    for _, generator in pairs(data.raw.generator) do
        randomize({
            id = id,
            prototype = generator,
            property = "fluid_usage_per_tick"
        })
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
    end
end

randomizations.inventory_sizes = function(id)
    -- Tier preservation for containers
    local container_list = {}
    for _, class_name in pairs({"container", "logistic-container"}) do
        for _, container in pairs(data.raw[class_name]) do
            -- If the inventory has size 0 or 1, it probably should not be randomized
            if container.inventory_size > 1 then
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
    
    -- Tier preservation for cargo wagons
    local wagon_list = {}
    for _, cargo_wagon in pairs(data.raw["cargo-wagon"]) do
        if cargo_wagon.inventory_size > 1 then
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

    -- Now everything else is randomized separately
    for entity_class, _ in pairs(categories.entities_with_inventory) do
        for _, entity in pairs(data.raw[entity_class]) do
            if entity.inventory_size > 1 then
                randomize({
                    id = id,
                    prototype = entity,
                    property = "inventory_size",
                    abs_min = 2,
                    rounding = "discrete"
                })
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

        randomize({
            id = id,
            prototype = lab,
            property = "researching_speed"
        })
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
                end
            end
        end
    end

    for _, electric_turret in pairs(data.raw["electric-turret"]) do
        local shot_energy_consumption = electric_turret.attack_parameters.ammo_type.energy_consumption
        if shot_energy_consumption ~= nil then
            randomizations.energy({
                id = id,
                prototype = electric_turret,
                tbl = electric_turret.attack_parameters.ammo_type,
                property = "energy_consumption"
            })
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
                            for pollutant, _ in pairs(energy_source.emissions_per_minute) do
                                randomize({
                                    id = id,
                                    prototype = entity,
                                    tbl = energy_source.emissions_per_minute,
                                    property = pollutant,
                                    range = "small",
                                    variance = "small"
                                })
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
                        randomize({
                            id = id,
                            prototype = entity,
                            property = "max_health",
                            rounding = "discrete"
                        })
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
        randomize({
            id = id,
            prototype = mining_drill,
            property = "mining_speed"
        })
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
                    randomize({
                        id = id,
                        prototype = entity,
                        property = "module_slots",
                        rounding = "discrete",
                        abs_min = 1
                    })
                end
            end
        end
    end
end

randomizations.offshore_pump_speed = function(id)
    for _, offshore_pump in pairs(data.raw["offshore-pump"]) do
        randomize({
            id = id,
            prototype = offshore_pump,
            property = "pumping_speed",
            range = "very_big",
            variance = "very_big",
            bias = -0.05
        })
    end
end

randomizations.pipe_to_ground_distance = function(id)
    local underground_pipe_conns = {}
    for _, pipe in pairs(data.raw["pipe-to-ground"]) do
        for _, pipe_connection in pairs(pipe.fluid_box.pipe_connections) do
            if pipe_connection.max_underground_distance ~= nil and pipe_connection.max_underground_distance > 0 then
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
end

randomizations.pump_pumping_speed = function(id)
    for _, pump in pairs(data.raw.pump) do
        randomize({
            id = id,
            prototype = pump,
            property = "pumping_speed"
        })
    end
end

randomizations.radar_reveal_area = function(id)
    for _, radar in pairs(data.raw.radar) do
        randomize({
            id = id,
            prototype = radar,
            property = "max_distance_of_nearby_sector_revealed",
            abs_min = 2,
            range = "small",
            variance = "small",
            rounding = "discrete"
        })
    end
end

randomizations.radar_search_area = function(id)
    for _, radar in pairs(data.raw.radar) do
        randomize({
            id = id,
            prototype = radar,
            property = "max_distance_of_sector_revealed",
            rounding = "discrete"
        })
    end
end

randomizations.reactor_consumption = function(id)
    for _, reactor in pairs(data.raw.reactor) do
        randomizations.energy({
            is_power = true,
            id = id,
            prototype = reactor,
            property = "consumption"
        })
    end
end

randomizations.reactor_neighbour_bonus = function(id)
    for _, reactor in pairs(data.raw.reactor) do
        if reactor.neighbour_bonus == nil then
            reactor.neighbour_bonus = 1
        end

        randomize({
            id = id,
            prototype = reactor,
            property = "neighbour_bonus"
        })
    end
end

randomizations.rocket_parts_required = function(id)
    for _, rocket_silo in pairs(data.raw["rocket-silo"]) do
        randomize({
            id = id,
            prototype = rocket_silo,
            property = "rocket_parts_required",
            range = "small",
            variance = "small",
            dir = -1
        })
    end
end

randomizations.rocket_silo_launch_time = function(id)
    for _, rocket_silo in pairs(data.raw["rocket-silo"]) do
        randomize({
            id = id,
            prototype = rocket_silo,
            property = "times_to_blink",
            range = "big",
            variance = "big",
            dir = -1
        })

        randomize({
            id = id,
            prototype = rocket_silo,
            property = "light_blinking_speed",
            range = "big",
            variance = "big",
            dir = -1
        })

        randomize({
            id = id,
            prototype = rocket_silo,
            property = "door_opening_speed",
            range = "big",
            variance = "big",
            dir = -1
        })

        if rocket_silo.rocket_rising_delay == nil then
            rocket_silo.rocket_rising_delay = 30
        end
        randomize({
            id = id,
            prototype = rocket_silo,
            property = "rocket_rising_delay",
            range = "big",
            variance = "big",
            dir = -1
        })

        if rocket_silo.launch_wait_time == nil then
            rocket_silo.launch_wait_time = 120
        end
        randomize({
            id = id,
            prototype = rocket_silo,
            property = "launch_wait_time",
            range = "big",
            variance = "big",
            dir = -1
        })
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
        randomizations.energy({
            is_power = true,
            id = id,
            prototype = roboport,
            property = "charging_energy",
            range = "small",
            variance = "small"
        })
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
            randomize({
                id = id,
                prototype = roboport,
                property = "charging_station_count",
                -- Don't randomize if there's only one station, and don't randomize down to one station if there are more
                abs_min = 2,
                rounding = "discrete"
            })
        end
    end
end

randomizations.roboport_construction_radius = function(id)
    for _, roboport in pairs(data.raw.roboport) do
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
    end
end

randomizations.solar_panel_production = function(id)
    for _, solar_panel in pairs(data.raw["solar-panel"]) do
        randomizations.energy({
            is_power = true,
            id = id,
            prototype = solar_panel,
            property = "production"
        })
    end
end

randomizations.storage_tank_capacity = function(id)
    for _, storage_tank in pairs(data.raw["storage-tank"]) do
        randomize({
            id = id,
            prototype = storage_tank,
            tbl = storage_tank.fluid_box,
            property = "volume",
            range = "big",
            variance = "big"
        })
    end
end

randomizations.turret_damage_modifier = function(id)
    for turret_class, _ in pairs(categories.turrets) do
        for _, turret in pairs(data.raw[turret_class]) do
            local attack_parameters = turret.attack_parameters

            if attack_parameters.damage_modifier == nil then
                attack_parameters.damage_modifier = 1
            end

            randomize({
                id = id,
                prototype = turret,
                tbl = attack_parameters,
                property = "damage_modifier"
            })
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
            if attack_parameters.min_range ~= nil and old_range ~= 0 then
                attack_parameters.min_range = attack_parameters.min_range * attack_parameters.range / old_range
            end
            if attack_parameters.min_attack_distance ~= nil and old_range ~= 0 then
                attack_parameters.min_attack_distance = attack_parameters.min_attack_distance * attack_parameters.range / old_range
            end
            if turret.prepare_range ~= nil then
                turret.prepare_range = turret.prepare_range * attack_parameters.range / old_range
            end
        end
    end
end

randomizations.turret_rotation_speed = function(id)
    for turret_class, _ in pairs(categories.turrets) do
        for _, turret in pairs(data.raw[turret_class]) do
            if turret.rotation_speed == nil then
                turret.rotation_speed = 1
            end

            randomize({
                id = id,
                prototype = turret,
                property = "rotation_speed"
            })
        end
    end

    -- Artillery wagons and artillery turrets not included as turrets, so we need to do them separately
    for _, turret_class in pairs({"artillery-turret", "artillery-wagon"}) do
        for _, turret in pairs(data.raw[turret_class]) do
            randomize({
                id = id,
                prototype = turret,
                property = "turret_rotation_speed"
            })
        end
    end

    -- Car turret rotation speed
    for _, car in pairs(data.raw.car) do
        -- For some reason the default here is 0.01 and the default on "normal" turrets is 1
        if car.turret_rotation_speed == nil then
            car.turret_rotation_speed = 0.01
        end

        randomize({
            id = id,
            prototype = car,
            property = "turret_rotation_speed"
        })
    end
end

randomizations.turret_shooting_speed = function(id)
    for turret_class, _ in pairs(categories.turrets) do
        for _, turret in pairs(data.raw[turret_class]) do
            -- Rounding is technically off but that's fine
            randomize({
                id = id,
                prototype = turret,
                tbl = turret.attack_parameters,
                property = "cooldown",
                prerounding = "normal",
                rounding = "none",
                range = "small",
                variance = "small",
                dir = -1,
            })
        end
    end
end

randomizations.underground_belt_distance = function(id)
    for _, belt in pairs(data.raw["underground-belt"]) do
        randomize({
            id = id,
            prototype = belt,
            property = "max_distance",
            abs_min = 2,
            abs_max = 255,
            range_max = "very_big",
            variance = "big"
        })
    end
end

randomizations.unit_attack_speed = function(id)
    for _, unit_class in pairs({"unit", "spider-unit"}) do
        if data.raw[unit_class] ~= nil then
            for _, unit in pairs(data.raw[unit_class]) do
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

                randomize({
                    id = id,
                    prototype = unit,
                    tbl = attack_parameters,
                    property = "damage_modifier",
                    range = "small",
                    variance = "small",
                    dir = -1
                })
            end
        end
    end
end

-- Doesn't include gleba spider-units or vulcanus segmented-units (those move in different ways)
randomizations.unit_movement_speed = function(id)
    for _, unit in pairs(data.raw.unit) do
        local old_movement_speed = unit.movement_speed

        randomize({
            id = id,
            prototype = unit,
            property = "movement_speed",
            range = "small",
            variance = "small",
            dir = -1
        })

        if unit.old_movement_speed ~= 0 then
            unit.distance_per_frame = unit.distance_per_frame * unit.movement_speed / old_movement_speed
        end
    end
end

randomizations.unit_pollution_to_join_attack = function(id)
    for _, unit_class in pairs({"unit", "spider-unit"}) do
        if data.raw[unit_class] ~= nil then
            for _, unit in pairs(data.raw[unit_class]) do
                if unit.absorptions_to_join_attack ~= nil then
                    for pollutant_id, _ in pairs(unit.absorptions_to_join_attack) do
                        randomize({
                            id = id,
                            prototype = unit,
                            tbl = unit.absorptions_to_join_attack,
                            property = pollutant_id,
                            range = "very_small",
                            variance = "very_small"
                        })
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

            randomizations.energy({
                is_power = true,
                id = id,
                prototype = vehicle,
                property = power_key,
                range = "big",
                variance = "big"
            })
            local new_power = 60 * util.parse_energy(vehicle[power_key]) 
            

            if old_power ~= 0 then
                -- Scale braking force with the new consumption for improved user experience
                if vehicle.braking_power ~= nil then
                    braking_power_as_number = 60 * util.parse_energy(vehicle.braking_power)
                    braking_power_as_number = braking_power_as_number * new_power / old_power
                    vehicle.braking_power = braking_power_as_number .. "W"
                else
                    -- In this case, vehicle.braking_force must be set
                    vehicle.braking_force = vehicle.braking_force * new_power / old_power
                end
            end
        end
    end
end