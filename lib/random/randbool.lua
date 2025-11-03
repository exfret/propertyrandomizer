local constants = require("helper-tables/constants")
local rng = require("lib/random/rng")

local randbool = {}

local probability_multiplication = function(p, factor)
    local not_p = 1 - p
    local scaled_p = p * factor
    return scaled_p / (scaled_p + not_p)
end

local converge = function(id, p)
    return rng.value(rng.key({id = id})) < p
end

--- randomly returns true or false, high global_chaos increases likelyhood of true
randbool.rand_chaos = function(id, base_probability)
    local p = probability_multiplication(base_probability, global_chaos)
    return converge(id, p)
end

local bias_idx_to_factor = { 0.8, 0.9, 1, 1.1, 1.2 }

--- randomly returns true or false, affected by global_bias
randbool.rand_bias = function (id, base_probability, dir)
    if dir == 0 then
        return converge(id, base_probability)
    end
    local factor = bias_idx_to_factor[global_bias_idx + 1]
    if dir < 0 then
        factor = 1 / factor
    end
    local p = probability_multiplication(base_probability, factor)
    return converge(id, p)
end

return randbool