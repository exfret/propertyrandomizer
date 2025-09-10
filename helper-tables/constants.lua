local constants = {
    left_digits_to_keep = 3,
    num_rolls = 25,
    reasonably_large_number = 1000000000,
    split_bias = 0.06,
    step_size_modifier = 0.4, -- Things were getting a little too random, thus this
    steps_per_roll = 20,
    -- Technology randomization (no special constants yet)
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
    -- Item randomization
    item_randomization_probability_high = 1,
    item_randomization_probability_low = settings.startup["propertyrandomizer-item-percent"].value / 100,
    -- Randomizations to build dependency graph for
    dep_graph_randomizations = {
        ["propertyrandomizer-technology"] = true,
        ["propertyrandomizer-recipe"] = true,
        ["propertyrandomizer-item"] = true,
        ["propertyrandomizer-watch-the-world-burn"] = true
    }
}

return constants