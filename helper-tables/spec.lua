-- Randomizations not in the spec:
--  * Technology randomization
--  * Recipe randomization
--  * Recipe tech unlock randomization
--  * Item randomization
--
-- The above need to be done in a certain order, which is why they are separated from the other randomizations
-- They are all toggleable directly from the settings rather than using overrides

local spec = {
----------------------------------------------------------------------
-- Graph randomizations
----------------------------------------------------------------------
    items = {
        category = "graph",
    },
    recipe_ingredients = {
        category = "graph",
    },
    recipe_unlocks = {
        category = "graph",
    },
    technology_prerequisites = {
        category = "graph",
    },
----------------------------------------------------------------------
-- Unified randomizations
----------------------------------------------------------------------
    unified_entity_operation_fluid = {
        category = "unified",
        handler = "entity-operation-fluid",
    },
    unified_mining_fluid_required = {
        category = "unified",
        handler = "mining-fluid-required",
    },
    unified_recipe_unlocks = {
        category = "unified",
        handler = "recipe-tech-unlocks",
    },
    unified_spoiling = {
        category = "unified",
        handler = "spoiling",
    },
    unified_technology_prerequisites = {
        category = "unified",
        handler = "tech-prereqs",
    },
    unified_technology_science_packs = {
        category = "unified",
        handler = "tech-science-packs",
    },
----------------------------------------------------------------------
-- Numerical randomizations
----------------------------------------------------------------------
    -- How much power accumulators store
    accumulator_buffer = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "default"
        }
    },
    -- How fast accumulators recharge
    accumulator_input_flow = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    -- How much power accumulators can output
    accumulator_output_flow = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    agricultural_tower_radius = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    --[[ Currently makes things a little too hard
    ammo_categories = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },]]
    ammo_cooldown_modifier = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    ammo_damage = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "less"
        }
    },
    --[[ammo_damage_types = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },]]
    ammo_magazine_size = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    ammo_projectile_count = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    ammo_projectile_range = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    ammo_range_modifier = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    armor_inventory_bonus = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    armor_resistances = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    artillery_projectile_damage = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    artillery_projectile_damage_types = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    artillery_projectile_effect_radius = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    asteroid_collector_arm_inventory = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    asteroid_collector_base_arm_count = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    asteroid_collector_inventory = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    asteroid_collector_radius = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    asteroid_collector_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    -- Disabled until there is a workable version
    --[[asteroid_mass = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },]]
    -- Disabled until there is a workable version
    --[[asteroid_spawns = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },]]
    -- Disabled until there is a workable version
    --[[asteroid_yields = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },]]
    --[[base_effect = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },]]
    beacon_distribution_effectivity = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "default"
        }
    },
    beacon_profiles = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    beacon_supply_area = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "default"
        }
    },
    beam_damage = {
        category = "numerical",
        setting = {
            -- It's in "more" since the damage bonuses on the weapons themselves are already randomized, so this is essentially a double randomization
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    beam_damage_interval = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    beam_damage_types = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    beam_width = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    belt_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "less"
        }
    },
    -- The power output of boilers
    boiler_consumption = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "default"
        }
    },
    bot_cargo_capacity = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    -- This is energy USAGE, not how much they can hold
    bot_energy = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "default"
        }
    },
    -- THIS is how much energy they can hold
    bot_energy_capacity = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    bot_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "default"
        }
    },
    burner_generator_output = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "less"
        }
    },
    capsule_actions = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    capsule_cooldown = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    capsule_damage_types = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- Applies to fish and the fruits in space age
    capsule_healing = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- Biggest thing this applies to is grenades
    capsule_throw_range = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "default"
        }
    },
    capture_robot_capture_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    capture_robot_search_radius = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    --[[car_rotation_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "default"
        }
    },]]
    cargo_bay_inventory_bonus = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    cargo_landing_pad_radar_range = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    chain_fork_chance = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    chain_max_jumps = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    --[[character_crafting_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },]]
    -- A classic
    cliff_sizes = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    combat_robot_damage = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    combat_robot_damage_types = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    combat_robot_lifetime = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    combat_robot_range = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    combat_robot_shooting_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    crafting_machine_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "less"
        }
    },
    electric_pole_wire_distance = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "less"
        }
    },
    electric_pole_supply_area = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "less"
        }
    },
    equipment_active_defense_cooldown = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    equipment_active_defense_effect_radius = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    equipment_active_defense_range = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "default"
        }
    },
    -- How much battery equipment can hold
    equipment_battery_buffer = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "default"
        }
    },
    -- Doesn't do anything in vanilla since personal batteries have infinite flow
    equipment_battery_input_limit = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    -- Doesn't do anything in vanilla since personal batteries have infinite flow
    equipment_battery_output_limit = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    equipment_energy_per_shield = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    equipment_energy_usage = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "default"
        }
    },
    equipment_generator_power = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "default"
        }
    },
    --[[equipment_grid_sizes = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "default"
        }
    },]]
    equipment_inventory_bonus = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    equipment_movement_bonus = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "default"
        }
    },
    -- How fast the personal roboport can charge bots
    equipment_personal_roboport_charging_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    equipment_personal_roboport_charging_station_count = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    equipment_personal_roboport_construction_radius = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    equipment_personal_roboport_max_robots = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    equipment_shapes = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    equipment_shield_hitpoints = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    equipment_solar_panel_production = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "default"
        }
    },
    fire_damage = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    --[[fire_damage_types = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },]]
    fire_lifetime = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- Was causing too many issues
    --[[
    fluid_box_locations = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },]]
    -- Doesn't change anything in vanilla
    fluid_emissions_multiplier = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- Doesn't change anything in vanilla
    fluid_fuel_value = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    -- In vanilla, this would change how much water is needed to convert to steam for the same amount of energy
    --[[fluid_heat_capacity = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },]]
    fluid_stream_damage = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    --[[fluid_stream_damage_types = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },]]
    fluid_stream_effect_radius = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    fluid_turret_consumption = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- How much max power output
    fusion_generator_max_power = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    -- How much input fluid to power and output fluid per tick
    fusion_generator_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    fusion_reactor_neighbor_bonus = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    -- How much electric power is required
    fusion_reactor_power_input = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    -- How much input fluid and fuel to output fluid per tick
    fusion_reactor_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    --[[gate_opening_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "default"
        }
    },]]
    -- How much steam do steam engines use
    generator_fluid_usage = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "default"
        }
    },
    -- TODO for gun randomizations: Make different vehicle guns not get randomized differently
    gun_damage_modifier = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    gun_minimum_range = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- Broken without transformer now
    --[[gun_movement_slowdown_factor = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },]]
    gun_range = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "default"
        }
    },
    gun_shooting_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "default"
        }
    },
    health_regeneration = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- Where inserters can take from and where the put items
    inserter_offsets = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    --[[inserter_base_hand_size = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },]]
    --[[inserter_filter = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },]]
    inserter_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "less"
        }
    },
    -- Just does "big" inventories like containers, not all inventories
    inventory_sizes = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "default"
        }
    },
    item_fuel_acceleration = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    item_fuel_top_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    item_fuel_value = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    --[[item_fuels = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        },
        -- Needs to be done before fuel stats randomizations
        order = 1,
    },]]
    item_stack_sizes = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    -- Affects rocket capacity
    --[[item_weights = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },]]
    lab_research_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "default"
        }
    },
    --[[lab_science_pack_drain = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },]]
    landmine_damage = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "default"
        }
    },
    --[[landmine_damage_types = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },]]
    landmine_effect_radius = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    landmine_timeout = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    landmine_trigger_radius = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    lightning_attractor_drain = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    lightning_attractor_efficiency = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    lightning_attractor_range = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    lightning_damage = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    lightning_energy = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    --[[locomotive_max_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },]]
    -- Disabled until there is a workable version
    --[[ module_effects = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "default"
        }
    },]]
    machine_energy_usage = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "less"
        }
    },
    machine_pollution = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "default"
        }
    },
    map_colors = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    --[[map_gen_preset = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },]]
    -- Affects everything, including enemy HP
    max_health = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "default"
        }
    },
    -- Where mining drills put their items
    -- TODO: Figure out why offsets are appearing inside the machine then re-enable
    --[[mining_drill_offsets = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },]]
    --[[mining_drill_radius = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },]]
    --[[mining_drill_resource_drain = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },]]
    mining_fluid_amount_needed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    -- Includes anything with a defined results field
    -- That's rocks, plants and fluid resouces in vanilla
    --[[mining_results = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },]]
    -- Mining drill speeds
    mining_speeds = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "less"
        }
    },
    --[[mining_times = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },]]
    --[[mining_times_resource = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },]]
    module_slots = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "default"
        }
    },
    offshore_pump_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    pipe_to_ground_distance = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "less"
        }
    },
    planet_day_night_cycles = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    planet_gravity = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    planet_lightning_density = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    planet_solar_power = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    plant_growth_time = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    plant_harvest_pollution = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- How many projectiles get spawned by projectiles as part of a cluster
    projectile_cluster_size = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    projectile_damage = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    --[[projectile_damage_types = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },]]
    projectile_effect_radius = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    projectile_piercing_power = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- How many projectiles get spawned by projectiles
    projectile_projectile_count = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    pump_pumping_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "default"
        }
    },
    --[[radar_reveal_area = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },]]
    radar_search_area = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    reactor_consumption = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "less"
        }
    },
    reactor_effectivity = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    reactor_neighbour_bonus = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    recipe_crafting_times = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    -- exfret Note: I specifically didn't touch the next few recipe randomizations due to exponential cascading issues, but let's see how they go
    -- If someone enables "More" on a randomization, they deserve pain anyways
    --[[recipe_ingredients_numerical = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },]]
    -- Also inversely affects recycling yields
    --[[recipe_maximum_productivity = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },]]
    --[[recipe_result_percent_spoiled = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },]]
    --[[recipe_result_probabilities = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },]]
    --[[recipe_results_numerical = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },]]
    --[[repair_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },]]
    -- Disabled until there is a workable version
    --[[resistances = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },]]
    -- How fast a roboport uses energy to charge bots
    roboport_charging_energy = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    -- How many bots can charge at once
    roboport_charging_station_count = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    roboport_construction_radius = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    -- The slots in roboports for bots and repair packs
    roboport_inventory = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    roboport_logistic_radius = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    --[[roboport_radar_range = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },]]
    --[[rocket_parts_required = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },]]
    -- How long it takes to launch a rocket
    --[[rocket_silo_launch_time = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },]]
    segmented_unit_attacking_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    segmented_unit_enraged_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    segmented_unit_investigating_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    segmented_unit_patrolling_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    smoke_damage = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    --[[smoke_damage_types = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },]]
    smoke_effect_radius = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    smoke_trigger_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    solar_panel_production = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "less"
        }
    },
    space_connection_length = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    space_location_solar_power_space = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    --[[space_platform_initial_items = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },]]
    spider_unit_projectile_range = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    spider_unit_yields = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    spoil_spawn = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        },
        -- Needs to be done before spoil time randomization
        order = 1,
    },
    spoil_time = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    sticker_damage = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    sticker_damage_types = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    sticker_duration = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    sticker_healing = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    sticker_movement_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    storage_tank_capacity = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "more"
        }
    },
    tech_costs = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "default"
        }
    },
    tech_craft_requirement = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    tech_times = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "default"
        }
    },
    tech_upgrades = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    thruster_consumption = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    thruster_effectivity = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    tile_pollution_absorption = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    --[[tile_walking_speed_modifier = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },]]
    -- Affects science capacity
    tool_durability = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-production",
            val = "more"
        }
    },
    turret_damage_modifier = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    turret_min_range = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    turret_range = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "default"
        }
    },
    turret_rotation_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    turret_shooting_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "default"
        }
    },
    underground_belt_distance = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-logistic",
            val = "less"
        }
    },
    unit_attack_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    unit_damage = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    --[[unit_damage_types = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },]]
    -- Doesn't include gleba spider-units (those move in different ways)
    -- Also doesn't include demolishers
    unit_movement_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- How much pollution it takes for an enemy to join an attack party
    -- Look up factorio enemy/pollution mechanics if you're confused by this
    unit_pollution_to_join_attack = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    unit_range = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    -- Doesn't include demolishers
    unit_sizes = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    --[[unit_spawner_loot = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },]]
    --[[unit_spawner_yields = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },]]
    -- How much damage crashing into things with a given vehicle does
    vehicle_crash_damage = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },
    --[[vehicle_effectivity = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },]]
    -- How fast vehicles accelerate
    vehicle_power = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "less"
        }
    },
    --[[vehicle_weight = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-misc",
            val = "more"
        }
    },]]
    worm_range = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
    worm_shooting_speed = {
        category = "numerical",
        setting = {
            name = "propertyrandomizer-military",
            val = "more"
        }
    },
----------------------------------------------------------------------
-- Misc randomizations
----------------------------------------------------------------------
    colors = {
        category = "misc",
    },    
    group_order = {
        category = "misc",
    },
    icons = {
        category = "misc",
    },
    localised_names = {
        category = "misc",
    },
    recipe_order = {
        category = "misc",
    },
    recipe_subgroup = {
        category = "misc",
    },
    sounds = {
        category = "misc",
    },
    subgroup_group = {
        category = "misc",
    },
}

return spec