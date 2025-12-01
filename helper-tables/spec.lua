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
    ammo_damage = {
        setting = {
            name = "propertyrandomizer-military",
            val = "less"
        }
    },
    ammo_magazine_size = {
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
    cliff_explosive_radius = {
        setting = {
            name = "propertyrandomizer-misc",
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
        }
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
    mining_fluid_amount_needed = {
        setting = {
            name = "propertyrandomizer-logistic",
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
    recipe_results_numerical = {
        setting = {
            name = "propertyrandomizer-production",
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
    tile_walking_speed_modifier = {
        setting = {
            name = "propertyrandomizer-misc",
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