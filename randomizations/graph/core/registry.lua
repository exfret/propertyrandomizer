local export = {}

export.create_empty_randomizer = function (key)
    return {
        -- Arbitrary unique name.
        -- Maybe "recipe", or maybe "technology"?
        key = key,
        -- Optional, called once before all other functions.
        -- Pre-computations, who knows?
        initialize = function (state) end,
        -- Called once. Used to calculate critical nodes.
        -- Return the set of edges that might be removed/changed by this randomizer. 
        get_target_edges = function (state) return {} end,
        -- Optional, called directly before each graph randomization attempt.
        -- More pre-computations?? You decide!
        pre_randomization = function (state) end,
        -- Called repeatedly during graph randomization to select new edges for a dependent.
        -- Puts edges in state.new_edges, ideally pulling from state.suitable_edges.
        execute_randomization = function (state) end,
        -- Optional, called directly after each graph randomization attempt.
        -- Graph fixes maybe?
        post_randomization = function (state) end,
        -- Optional, called last after a successful randomization attempt.
        -- Writing to data.raw? That can be done in any of these functions, but this is an option.
        finalize = function (state) end,
    }
end

export.add = function (randomizer)
    export.randomizers[randomizer.key] = randomizer
end

export.randomizers = {}

return export