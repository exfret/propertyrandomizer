-- Parked numerical sampling changes for the military/resistance experiment.
local randnum = require("lib/random/randnum")

local randprob = {}

randprob.scale_odds = function(p, factor)
    local not_p = 1 - p
    local scaled_p = p * factor
    return scaled_p / (scaled_p + not_p)
end

randprob.calc_odds_factor = function(p_old, p_new)
    local odds_old = p_old / (1 - p_old)
    local odds_new = p_new / (1 - p_new)
    return odds_new / odds_old
end

randprob.rand = function(params)
    randnum.fill_in_defaults(params)
    if params.abs_min == "none" then params.abs_min = nil end
    if params.abs_max == "none" then params.abs_max = nil end

    -- Normalize input
    local probability_scale = params.probability_scale or 1
    local p = params.val / probability_scale
    local abs_min = params.abs_min or 0
    local abs_max = params.abs_max or probability_scale

    -- Input validation
    if p > 1 or p < 0 then
        error("Cannot randomize probability " .. params.val .. " out of bounds: [0, " .. probability_scale .. "]")
    end
    if abs_min ~= nil and abs_min > probability_scale then
        error("Cannot randomize probability with abs_min " .. params.abs_min .. " above maximum: " .. probability_scale .. "")
    end
    if abs_max ~= nil and abs_max < 0 then
        error("Cannot randomize probability with abs_max " .. params.abs_max .. " below minimum: 0")
    end

    -- Generate factor
    local final_params = {
        tbl = params.tbl,
        property = params.property,
        dummy = params.dummy,
        combat = params.combat,
    }
    -- The temporary odds multiplier is not the field being randomized.
    params.combat = false
    params.val = nil
    params.abs_min = nil
    params.abs_max = nil
    params.prototype = nil
    params.dummy = 1
    params.tbl = nil
    params.property = nil
    local rounding = params.rounding
    params.rounding = "none"
    -- Tuning was resolved on the original value.
    -- Preserve it while randomizing the temporary odds multiplier, including its forced rounding mode.
    local factor = randnum.rand(params, true)

    -- Scale odds with factor
    local new_p = randprob.scale_odds(p, factor)

    -- Scale back to outside domain
    new_p = new_p * probability_scale

    -- Round result
    -- Flip probability for symmetric and higher rounding fidelity close to extremities
    params.rounding = rounding
    params.abs_min = nil
    params.abs_max = nil
    local function normalize(value)
        local is_high = value > probability_scale / 2
        if is_high then
            value = probability_scale - value
        end
        params.rounding = rounding
        params.abs_min = nil
        params.abs_max = nil
        value = randnum.fixes(params, value)
        if is_high then
            value = probability_scale - value
        end

        -- Bound the original coordinate after complement rounding.
        params.rounding = "none"
        params.abs_min = abs_min
        params.abs_max = abs_max
        return randnum.fixes(params, value)
    end
    new_p = normalize(new_p)
    return randnum.write(final_params, new_p)
end

return randprob
