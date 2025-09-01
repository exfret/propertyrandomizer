local hash = require("lib/random/hash")

local rng = {}

rng.prgs = {}

local A1 = 727595
local A2 = 798405
local D20 = 1048576
local D40 = 1099511627776

rng.seed = function(key)
    local state_tbl = {}

    local state_seed = global_seed + (hash.hash(key) % D20)

    state_tbl["X1"] = (state_seed * 2 + 11111) % D20
    state_tbl["X2"] = (state_seed * 4 + 1) % D20

    rng.prgs[key] = state_tbl

    rng.value(key)
    rng.value(key)
    rng.value(key)
end

rng.value = function(key)
    if rng.prgs[key] == nil then
        rng.seed(key)
    end

    local state_tbl = rng.prgs[key]

    local U = state_tbl["X2"] * A2
    local V = (state_tbl["X1"] * A2 + state_tbl["X2"] * A1) % D20
    V = (V * D20 + U) % D40
    state_tbl["X1"] = math.floor(V / D20)
    state_tbl["X2"] = V - state_tbl["X1"] * D20

    return V / D40
end

-- Get an integer value between [1, max]
rng.int = function(key, max)
    return math.floor(rng.value(key) * max) + 1
end

-- Get an integer value between [min, max]
rng.range = function(key, min, max)
    return min + rng.int(key, max - min + 1) - 1
end

-- Get a float value between [min, max]
rng.float_range = function(key, min, max)
    return min + rng.value(key) * (max - min)
end

-- Applies a uniformly random permutation to an ordered list
rng.shuffle = function(key, tbl)
    for i = #tbl, 2, -1 do
        local j = rng.int(key, i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
end

-- Generates a string key from an object
rng.key = function(params)
    params = table.deepcopy(params)

    local separators = {
        "aaa",
        "bbb",
        "ccc",
        "ddd"
    }

    -- All randomizations should have id, but some other purposes need to just get a unique identifier per prototype
    if params.id == nil and params.prototype ~= nil then
        return params.prototype.type .. separators[1] .. params.prototype.name
    end

    -- See if this is a prototype-based key
    if params.prototype ~= nil then
        return "prototype" .. separators[1] .. params.id .. separators[2] .. params.prototype.type .. separators[3] .. params.prototype.name
    elseif params.linked then
        return "linked" .. separators[1] .. params.id .. separators[2] .. params.tier
    elseif params.id ~= nil then
        return "grouped" .. separators[1] .. params.id
    end

    error("Invalid params for key.")
end

return rng