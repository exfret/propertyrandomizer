local constants = {
    -- Config stuffs
    bias_string_to_num = {
        ["worst"] = -0.05,
        ["worse"] = -0.025,
        ["default"] = 0,
        ["better"] = 0.025,
        ["best"] = 0.05
    },
    bias_string_to_idx = {
        ["worst"] = 0,
        ["worse"] = 1,
        ["default"] = 2,
        ["better"] = 3,
        ["best"] = 4,
    },
    chaos_string_to_num = {
        ["light"] = 0.3,
        ["less"] = 0.7,
        ["default"] = 1,
        ["more"] = 1.75,
        ["ultimate"] = 3.5
    },
    chaos_string_to_idx = {
        ["light"] = 0,
        ["less"] = 1,
        ["default"] = 2,
        ["more"] = 3,
        ["ultimate"] = 4
    },
    chaos_string_to_range_num = {
        ["light"] = 0.75,
        ["less"] = 0.875,
        ["default"] = 1,
        ["more"] = 1.3,
        ["ultimate"] = 1.7
    },
    str_to_mul_std = {
        very_small = 1.1,
        small = 1.2,
        medium = 1.5,
        big = 2.0,
        very_big = 3.5
    },
    setting_values = {
        none = 0,
        less = 1,
        default = 2,
        more = 3,
        most = 4
    },

    starting_planet = "nauvis",

    left_digits_to_keep = 3,
    num_rolls = 25,
    reasonably_large_number = 1000000000,
    split_bias = 0.06,
    step_size_modifier = 0.4, -- Things were getting a little too random, thus this
    steps_per_roll = 20,

    -- Simplex cost
    simplex_per_resource_cost = 0.3,
    simplex_per_recipe_cost = 0.3,
    simplex_per_second_cost = 0.1,
    simplex_pump_cost = 0.005,
    simplex_boiling_cost = 0.05,
    simplex_burnt_cost = 1,

    path_max_removed_node_hits = 30 * 16,
    path_max_depth = 30 * 128,
    path_max_nodes_checked = 30 * 8192,
    -- Recipe randomization
    max_flow_iterations = 10000,
    cost_params = {
        time = 0.07,
        complexity = 0.01
    },
    target_cost_threshold = 1.5,
    aggregate_points_weighting = 1,
    complexity_points_weighting = 2,
    resource_points_weighting = 0.1,
    non_starting_planet_bonus = 3,
    max_num_failed_attempts_ing_search = 10000,
    -- Item randomization
    item_randomization_cost_factor_threshold = 100,
    item_randomization_max_fallbacks = 100,

    -- First pass constants
    first_pass_max_cost_log_difference = 1000, -- Basically disable for now
    -- Now I use upper and lower; we're more strict about an expensive thing going in a cheap slot
    -- These are base e, so something 150x more expensive is rejected, and something 3000x cheaper is rejected
    first_pass_max_cost_log_difference_expensive = 5,
    first_pass_max_cost_log_difference_cheap = 8,

    unified_recipe_ingredients_cost_threshold = 1000,
    unified_recipe_results_dummy_fraction = 1,

    py_electricity_scaling = { -- Roughly in GW expected for an "average" base, but the ratios are what matter anyways
        0.1, -- pre-auto
        0.2, -- auto
        0.5, -- py1
        1, -- logi
        3, -- military
        3, -- py2
        6, -- chem
        10, -- py3
        20, -- prod
        40, -- py4
        65, -- utility
        100, -- space
    },

    -- For the built in graph costs
    cost = {
        default_payback_time = 10 * 3600,
        -- One-time cost per entity
        -- In particular, this is what gives ores their value of about 1
        per_entity_cost = 1,
        -- Covers the space cost of the building (per second)
        per_tile_operation_cost = 0.001,
        -- To cover fixed costs of logistics to a building, like belts/inserters (per second)
        per_building_operation_cost = 0.025,
        -- How much your time is worth (per second)
        character_operation_cost = 1,
        slot_additional_character_operation_cost = 30,
        -- Floor on fluid cost to represent logistical complexity of a lot of fluid, even if it's otherwise free
        per_fluid_cost = 0.001,
        -- Floor on item cost to represent logistical complexity of many items, even if they're otherwise free
        per_item_cost = 0.1,
        -- Complexity cost for dealing with having to burn something
        burnt_result_additional_cost = 1,
        slot_additional_burnt_result_cost = 5,
        -- TODO: Spoilage costs not tested yet
        -- Spoilage costs are only for calculating slot cost
        -- Additional fixed cost from nuisance of getting something through spoiling
        slot_spoil_additional_cost_fixed = 0.2,
        -- Variable cost per second of having to wait for something to spoil
        slot_spoil_additional_cost_per_second = 0.0167,
        -- Penalty to operation for something having a burner energy source
        burner_energy_source_penalty = 0.1,
        -- Let's say heat is like, 5x more annoying than electricity or so
        heat_multiplier = 5,
    },
    
    blacklisted_silos = {
        ["mega-farm"] = true, -- Py smart farms work via scripting and don't actually launch a rocket
    },

    funny_recipe_prefixes_keys = {
        ["Discombobulate"] = true,
        ["Throw together"] = true,
        ["Invent"] = true,
        ["Materialize"] = true,
        ["Order online"] = true,
        ["Discover"] = true,
        ["Scavenge"] = true,
        ["'Borrow'"] = true,
        ["Receive"] = true,
        ["Steal"] = true,
        ["Create"] = true,
        ["Manifest"] = true,
        ["Conjure"] = true,
        ["exfretiate"] = true,
        ["Factorioize"] = true,
        ["Spawn"] = true,
        ["Evoke"] = true,
        ["Make"] = true,
        ["Concatenate"] = true,
        ["Realize"] = true,
        ["Find"] = true,
        ["Demand"] = true,
        ["Beg for"] = true,
        ["Devaporize"] = true,
        ["Spit out"] = true,
        ["Assemble"] = true,
        ["Give birth to"] = true,
        ["Lure"] = true,
        ["Inherit"] = true,
        ["Ask for"] = true,
        ["Undestroy"] = true,
        ["Forge"] = true,
        ["Barter for"] = true,
        ["Buy"] = true,
        ["Stumble upon"] = true,
        ["Predict"] = true,
        ["Refine stuff into"] = true,
        ["exfret enrichment of"] = true,
        ["Doshingtonize"] = true,
        ["Polish"] = true,
        ["Differentiate"] = true,
        ["Achieve"] = true,
        ["Breed"] = true,
        ["Conjure"] = true,
        ["Wish for"] = true,
        ["Dream of"] = true,
        ["Expertly craft"] = true,
        ["Begrudgingly craft"] = true,
        ["Rescue"] = true,
        ["Craft"] = true,
        ["Workshop"] = true,
        ["Ferment"] = true,
        ["Cook up"] = true,
        ["Bake"] = true,
        ["Sautee"] = true,
        ["Notice you have"] = true,
        ["Dig up"] = true,
        ["Search for"] = true,
        ["Forage for"] = true,
    },
}
constants.funny_recipe_prefixes = {}
for k, _ in pairs(constants.funny_recipe_prefixes_keys) do
    table.insert(constants.funny_recipe_prefixes, k)
end

local function set_aps_starting_planet()
    if settings.startup["aps-planet"].value ~= "none" then
        constants.starting_planet = settings.startup["aps-planet"].value
    end
end
-- Assume mods ~= nil means we're in data stage, and script.active_mods ~= nil means control
if mods ~= nil and mods["any-planet-start"] then
    set_aps_starting_planet()
end
if script ~= nil and script.active_mods ~= nil and script.active_mods["any-planet-start"] ~= nil then
    set_aps_starting_planet()
end

return constants