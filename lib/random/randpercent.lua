local randnum = require("lib/random/randnum")

local randpercent = {}

randpercent.probability_multiplication = function(p, factor)
    local not_p = 1 - p
    local scaled_p = p * factor
    return scaled_p / (scaled_p + not_p)
end

randpercent.rand = function(params)
    randnum.fill_in_defaults(params)
    local p = params.val
    local rounding = params.rounding
    params.val = nil
    params.rounding = "none"
    params.prototype = nil
    params.tbl = nil
    params.property = nil
    params.dummy = 1
    local factor = randnum.rand(params)
    local new_p = randpercent.probability_multiplication(p, factor)
    local is_high = new_p > 0.5
    local fixed_p = new_p
    -- Flip for higher rounding fidelity close to extremities
    if is_high then
        fixed_p = 1 - fixed_p
    end
    params.rounding = rounding
    fixed_p = randnum.fixes(params, fixed_p)
    if is_high then
        fixed_p = 1 - fixed_p
    end
    return fixed_p
end

return randpercent