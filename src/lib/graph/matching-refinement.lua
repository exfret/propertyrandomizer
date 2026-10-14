-- Shared proposal/validation/refinement control. A validator must leave its
-- caller's state unchanged on rejection. Refinement adds constraints; zero new
-- constraints or exhaustion retains the last valid state, never a failed trial.
local refinement = {}

refinement.run = function(params)
    local stats = {refinements = 0, trials = 0, accepted = false}
    while true do
        local candidate = params.propose(stats.refinements)
        if candidate == nil then break end
        stats.trials = stats.trials + 1
        local ok, result = params.validate(candidate)
        if ok then
            stats.accepted = true
            return candidate, result, stats
        end
        stats.refinements = stats.refinements + 1
        local added = params.refine(candidate, result, stats.refinements)
        if added == 0 or stats.refinements >= params.max_refinements then break end
    end
    return params.current, params.current_result, stats
end

return refinement
