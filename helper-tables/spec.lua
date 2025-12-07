-- Randomizations not in the spec:
--  * Technology randomization
--  * Recipe randomization
--  * Recipe tech unlock randomization
--  * Item randomization
--
-- The above need to be done in a certain order, which is why they are separated from the other randomizations
-- They are all toggleable directly from the settings rather than using overrides

local spec = {
    -- How much power accumulators store
    accumulator_buffer = {
        setting = {
            name = "propertyrandomizer-production",
            val = "default"
        }
    },
    -- How fast accumulators recharge
    accumulator_input_flow = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    -- How much power accumulators can output
    accumulator_output_flow = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    agricultural_tower_radius = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    --[[ Currently makes things a little too hard
    ammo_categories = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },]]
    ammo_cooldown_modifier = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    ammo_damage = {
        setting = {
            name = "propertyrandomizer-military",
            val = "less"
        }
    },
    ammo_damage_types = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    ammo_magazine_size = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    ammo_projectile_count = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    ammo_projectile_range = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    ammo_range_modifier = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    armor_inventory_bonus = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    armor_resistances = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    artillery_projectile_damage = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    artillery_projectile_damage_types = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    artillery_projectile_effect_radius = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    asteroid_collector_arm_inventory = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    asteroid_collector_base_arm_count = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    asteroid_collector_inventory = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    asteroid_collector_radius = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    asteroid_collector_speed = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    asteroid_mass = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    asteroid_spawns = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    asteroid_yields = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    base_effect = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    beacon_distribution_effectivity = {
        setting = {
            name = "propertyrandomizer-production",
            val = "default"
        }
    },
    beacon_profiles = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    beacon_supply_area = {
        setting = {
            name = "propertyrandomizer-production",
            val = "default"
        }
    },
    beam_damage = {
        setting = {
            -- It's in "more" since the damage bonuses on the weapons themselves are already randomized, so this is essentially a double randomization
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    beam_damage_interval = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    beam_damage_types = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    beam_width = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    belt_speed = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "less"
        }
    },
    -- The power output of boilers
    boiler_consumption = {
        setting = {
            name = "propertyrandomizer-production",
            val = "default"
        }
    },
    bot_cargo_capacity = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    -- This is energy USAGE, not how much they can hold
    bot_energy = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "default"
        }
    },
    -- THIS is how much energy they can hold
    bot_energy_capacity = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    bot_speed = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "default"
        }
    },
    burner_generator_output = {
        setting = {
            name = "propertyrandomizer-production",
            val = "less"
        }
    },
    capsule_actions = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    capsule_cooldown = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    capsule_damage_types = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- Applies to fish and the fruits in space age
    capsule_healing = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- Biggest thing this applies to is grenades
    capsule_throw_range = {
        setting = {
            name = "propertyrandomizer-military",
            val = "default"
        }
    },

    capture_robot_capture_speed = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    capture_robot_search_radius = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    car_rotation_speed = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "default"
        }
    },
    cargo_bay_inventory_bonus = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    cargo_landing_pad_radar_range = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    chain_fork_chance = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    chain_max_jumps = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- A classic
    cliff_sizes = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    crafting_machine_speed = {
        setting = {
            name = "propertyrandomizer-production",
            val = "less"
        }
    },
    electric_pole_wire_distance = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "less"
        }
    },
    electric_pole_supply_area = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "less"
        }
    },
    equipment_active_defense_cooldown = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    equipment_active_defense_damage = {
        setting = {
            name = "propertyrandomizer-military",
            val = "default"
        }
    },
    equipment_active_defense_range = {
        setting = {
            name = "propertyrandomizer-military",
            val = "default"
        }
    },
    -- How much battery equipment can hold
    equipment_battery_buffer = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "default"
        }
    },
    -- Doesn't do anything in vanilla since personal batteries have infinite flow
    equipment_battery_input_limit = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    -- Doesn't do anything in vanilla since personal batteries have infinite flow
    equipment_battery_output_limit = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    equipment_energy_usage = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "default"
        }
    },
    equipment_generator_power = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "default"
        }
    },
    equipment_grid_sizes = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "default"
        }
    },
    equipment_movement_bonus = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "default"
        }
    },
    -- How fast the personal roboport can charge bots
    equipment_personal_roboport_charging_speed = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    equipment_personal_roboport_charging_station_count = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    equipment_personal_roboport_construction_radius = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    equipment_personal_roboport_max_robots = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    equipment_shapes = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    equipment_solar_panel_production = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "default"
        }
    },
    fire_damage = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    fire_damage_types = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    fire_lifetime = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    fluid_box_locations = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    -- Doesn't change anything in vanilla
    fluid_emissions_multiplier = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- Doesn't change anything in vanilla
    fluid_fuel_value = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    -- In vanilla, this would change how much water is needed to convert to steam for the same amount of energy
    fluid_heat_capacity = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    fluid_stream_damage = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    fluid_stream_effect_radius = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- How much max power output
    fusion_generator_max_power = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    -- How much input fluid to power and output fluid per tick
    fusion_generator_speed = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    fusion_reactor_neighbor_bonus = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    -- How much electric power is required
    fusion_reactor_power_input = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    -- How much input fluid and fuel to output fluid per tick
    fusion_reactor_speed = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    gate_opening_speed = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "default"
        }
    },
    -- How much steam do steam engines use
    generator_fluid_usage = {
        setting = {
            name = "propertyrandomizer-production",
            val = "default"
        }
    },
    -- TODO for gun randomizations: Make different vehicle guns not get randomized differently
    gun_damage_modifier = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    gun_minimum_range = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- Broken without transformer now
    --[[gun_movement_slowdown_factor = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },]]
    gun_range = {
        setting = {
            name = "propertyrandomizer-military",
            val = "default"
        }
    },
    gun_shooting_speed = {
        setting = {
            name = "propertyrandomizer-military",
            val = "default"
        }
    },
    health_regeneration = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- Where inserters can take from and where the put items
    inserter_offsets = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    inserter_base_hand_size = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    inserter_filter = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    inserter_speed = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "less"
        }
    },
    -- Just does "big" inventories like containers, not all inventories
    inventory_sizes = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "default"
        }
    },
    item_fuel_acceleration = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    item_fuel_top_speed = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    item_fuel_value = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    item_fuels = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        },
        -- Needs to be done before fuel stats randomizations
        order = 1,
    },
    item_stack_sizes = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    -- Affects rocket capacity
    item_weights = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    lab_research_speed = {
        setting = {
            name = "propertyrandomizer-production",
            val = "default"
        }
    },
    lab_science_pack_drain = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    landmine_damage = {
        setting = {
            name = "propertyrandomizer-military",
            val = "default"
        }
    },
    landmine_effect_radius = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    landmine_timeout = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    landmine_trigger_radius = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    lightning_attractor_drain = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    lightning_attractor_efficiency = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    lightning_attractor_range = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    locomotive_max_speed = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    module_effects = {
        setting = {
            name = "propertyrandomizer-production",
            val = "default"
        }
    },
    machine_energy_usage = {
        setting = {
            name = "propertyrandomizer-production",
            val = "less"
        }
    },
    machine_pollution = {
        setting = {
            name = "propertyrandomizer-military",
            val = "default"
        }
    },
    map_colors = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    -- Affects everything, including enemy HP
    max_health = {
        setting = {
            name = "propertyrandomizer-military",
            val = "default"
        }
    },
    -- Where mining drills put their items
    mining_drill_offsets = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    mining_drill_radius = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    mining_drill_resource_drain = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    mining_fluid_amount_needed = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    -- Includes anything with a defined results field
    -- That's rocks, plants and fluid resouces in vanilla
    mining_results = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    -- Mining drill speeds
    mining_speeds = {
        setting = {
            name = "propertyrandomizer-production",
            val = "less"
        }
    },
    mining_times = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    mining_times_resource = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    module_slots = {
        setting = {
            name = "propertyrandomizer-production",
            val = "default"
        }
    },
    offshore_pump_speed = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    pipe_to_ground_distance = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "less"
        }
    },
    planet_day_night_cycles = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    planet_gravity = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    planet_lightning_density = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    planet_solar_power = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    plant_growth_time = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    plant_harvest_pollution = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    projectile_damage = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    projectile_damage_types = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    projectile_effect_radius = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    projectile_piercing_power = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- How many projectiles get spawned by projectiles
    projectile_projectile_count = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    pump_pumping_speed = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "default"
        }
    },
    radar_reveal_area = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    radar_search_area = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    reactor_consumption = {
        setting = {
            name = "propertyrandomizer-production",
            val = "less"
        }
    },
    reactor_effectivity = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    reactor_neighbour_bonus = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    recipe_crafting_times = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    -- exfret Note: I specifically didn't touch the next few recipe randomizations due to exponential cascading issues, but let's see how they go
    -- If someone enables "More" on a randomization, they deserve pain anyways
    recipe_ingredients_numerical = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    -- Also inversely affects recycling yields
    recipe_maximum_productivity = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    recipe_result_percent_spoiled = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    recipe_result_probabilities = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    recipe_results_numerical = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    repair_speed = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    resistances = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- How fast a roboport uses energy to charge bots
    roboport_charging_energy = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    -- How many bots can charge at once
    roboport_charging_station_count = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    roboport_construction_radius = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    -- The slots in roboports for bots and repair packs
    roboport_inventory = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    roboport_logistic_radius = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    roboport_radar_range = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    rocket_parts_required = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    -- How long it takes to launch a rocket
    --[[rocket_silo_launch_time = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },]]
    solar_panel_production = {
        setting = {
            name = "propertyrandomizer-production",
            val = "less"
        }
    },
    space_connection_length = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    space_location_solar_power_space = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    space_platform_initial_items = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    spoil_spawn = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        },
        -- Needs to be done before spoil time randomization
        order = 1,
    },
    spoil_time = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    sticker_damage = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    sticker_damage_types = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    sticker_duration = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    sticker_healing = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    sticker_movement_speed = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    storage_tank_capacity = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    tech_costs = {
        setting = {
            name = "propertyrandomizer-production",
            val = "default"
        }
    },
    tech_times = {
        setting = {
            name = "propertyrandomizer-production",
            val = "default"
        }
    },
    tech_upgrades = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    thruster_consumption = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    thruster_effectivity = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    tile_walking_speed_modifier = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    -- Affects science capacity
    tool_durability = {
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    turret_damage_modifier = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    turret_min_range = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    turret_range = {
        setting = {
            name = "propertyrandomizer-military",
            val = "default"
        }
    },
    turret_rotation_speed = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    turret_shooting_speed = {
        setting = {
            name = "propertyrandomizer-military",
            val = "default"
        }
    },
    underground_belt_distance = {
        setting = {
            name = "propertyrandomizer-logistic",
            val = "less"
        }
    },
    unit_attack_speed = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    unit_melee_damage = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- Doesn't include gleba spider-units (those move in different ways)
    -- Also doesn't include demolishers
    unit_movement_speed = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- How much pollution it takes for an enemy to join an attack party
    -- Look up factorio enemy/pollution mechanics if you're confused by this
    unit_pollution_to_join_attack = {
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- Doesn't include demolishers
    unit_sizes = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    -- How much damage crashing into things with a given vehicle does
    vehicle_crash_damage = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    vehicle_effectivity = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    -- How fast vehicles accelerate
    vehicle_power = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "less"
        }
    },
    vehicle_weight = {
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
}

return spec