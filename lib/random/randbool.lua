local constants = require("helper-tables/constants")
local rng = require("lib/random/rng")
local randprob = require("lib/random/randprob")

local randbool = {}

randbool.converge = function(key, p)
    return rng.value(key) < p
end

--- randomly returns true or false, high global_chaos increases likelyhood of true
randbool.rand_chaos = function(key, base_probability)
    local p = randprob.scale_odds(base_probability, global_chaos)
    return randbool.converge(key, p)
end

local bias_idx_to_factor = { 0.8, 0.9, 1, 1.1, 1.2 }

--- randomly returns true or false, affected by global_bias
randbool.rand_bias = function (key, base_probability, dir)
    if dir == 0 then
        return randbool.converge(key, base_probability)
    end
    local factor = bias_idx_to_factor[global_bias_idx + 1]
    if dir < 0 then
        factor = 1 / factor
    end
    local p = randprob.scale_odds(base_probability, factor)
    return randbool.converge(key, p)
end

--- randomly returns true or false, affected by both global_chaos and global_bias
randbool.rand_bias_chaos = function (key, base_probability, dir)
    local half = math.sqrt(base_probability)
    return randbool.rand_bias(key, half, dir) and randbool.rand_chaos(key, half)
end

return randbool