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
    simplex_per_resource_cost = 1,
    simplex_per_recipe_cost = 0.1,
    simplex_per_second_cost = 0.05,
    simplex_pump_cost = 0.01,
    simplex_boiling_cost = 0.05,

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

    unified_recipe_ingredients_cost_threshold = 1000,
    unified_mining_fluid_required_default_fluid_amount = 10,
    unified_recipe_results_dummy_fraction = 1,

    -- Randomizations to build dependency graph for
    dep_graph_randomizations = {
        ["propertyrandomizer-technology"] = true,
        ["propertyrandomizer-recipe"] = true,
        ["propertyrandomizer-item"] = true,
        ["propertyrandomizer-watch-the-world-burn"] = true
    }
}

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