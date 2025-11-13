local randnum = require("lib/random/randnum")

local randprob = {}

randprob.scale_odds = function(p, factor)
    local not_p = 1 - p
    local scaled_p = p * factor
    return scaled_p / (scaled_p + not_p)
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
    params.val = nil
    params.abs_min = nil
    params.abs_max = nil
    params.prototype = nil
    params.tbl = nil
    params.property = nil
    params.dummy = 1
    local rounding = params.rounding
    params.rounding = "none"
    local factor = randnum.rand(params)

    -- Scale odds with factor
    local new_p = randprob.scale_odds(p, factor)

    -- Scale back to outside domain
    new_p = new_p * probability_scale

    -- Round result
    -- Flip probability for symmetric and higher rounding fidelity close to extremities
    local is_high = new_p > 0.5
    if is_high then
        new_p = probability_scale - new_p
    end
    params.rounding = rounding
    new_p = randnum.fixes(params, new_p)
    if is_high then
        new_p = probability_scale - new_p
    end

    -- Enforce absolute boundaries outside in separate step due to flipping probabilities in previous step
    params.rounding = "none"
    params.abs_min = abs_min
    params.abs_max = abs_max
    new_p = randnum.fixes(params, new_p)

    return new_p
end

return randprob