local constants = require("helper-tables/constants")
local rng = require("lib/random/rng")

local randnum = {}

-- TODO: blacklists
-- TODO: check for incorrect params

randnum.fill_in_defaults = function(params)
    -- Check for incorrect params
    local is_allowed_param = {
        id = true,
        prototype = true,
        key = true,
        tbl = true,
        property = true,
        dummy = true,
        abs_min = true,
        abs_max = true,
        range = true,
        range_min = true,
        range_max = true,
        variance = true,
        bias = true,
        dir = true,
        rounding = true,
        -- Special keys that this file doesn't care about but we still allow
        prototypes = true,
        tbls = true,
        separated = true,
        is_power = true,
        -- Allow val etc. for now, but keep in mind it will allow the same params to be used to randomize multiple times
        val = true,
        hard_min = true,
        soft_min = true,
        soft_max = true,
        hard_max = true,
        step_size = true,
        real_bias = true
    }
    for k, _ in pairs(params) do
        if not is_allowed_param[k] then
            -- This param was misspelled!
            log("Incorrect randomization key: " .. k)
            error()
        end
    end

    -- Fill in key first
    if params.key == nil then
        params.key = rng.key({id = params.id, prototype = params.prototype})
    end

    if params.dummy ~= nil then
        params.tbl = {
            dummy = params.dummy
        }
        params.property = "dummy"
    else
        if params.tbl == nil then
            params.tbl = params.prototype
        end
    end

    params.val = params.tbl[params.property]

    -- Set defaults for tuning
    local defaults = {
        abs_min = "none",
        abs_max = "none",
        range = "medium",
        range_min = "same",
        range_max = "same",
        variance = "medium",
        bias = 0,
        dir = 1,
        rounding = "normal"
    }
    for key, default_val in pairs(defaults) do
        if params[key] == nil then
            params[key] = default_val
        end
    end

    -- Fill in for min/max factors
    local str_to_cap = {
        very_small = {1.3, 1.75},
        small = {1.5, 2.5},
        medium = {2, 4},
        big = {5, 10},
        very_big = {15, 25},
        none = {0, constants.reasonably_large_number}
    }
    local min_key = "range_min"
    if params.range_min == "same" then
        min_key = "range"
    end
    params.soft_min = 1 / str_to_cap[params[min_key]][1] * params.val
    params.hard_min = 1 / str_to_cap[params[min_key]][2] * params.val
    local max_key = "range_max"
    if params.range_max == "same" then
        max_key = "range"
    end
    params.soft_max = str_to_cap[params[max_key]][1] * params.val
    params.hard_max = str_to_cap[params[max_key]][2] * params.val

    local str_to_step_size = {
        very_small = 1.5,
        small = 2.5,
        medium = 5,
        big = 10,
        very_big = 20
    }
    params.step_size = str_to_step_size[params.variance or "medium"]

    -- Returns either negative or positive the split bias
    local real_split_bias = constants.split_bias * (2 * rng.range(params.key, 0, 1) - 1)
    params.real_bias = 0.5 + params.bias + real_split_bias + global_bias

    -- If the value is already below or above the absolute min or max, skip randomization
    if (params.abs_min ~= "none" and params.val < params.abs_min) or (params.abs_max ~= "none" and params.val > params.abs_max) then
        return false
    end

    -- Skip randomization for values that aren't positive
    if params.val <= 0 then
        return false
    end

    return true
end

local function round_normal(num)
    local digits_modulus = math.pow(10, math.floor(math.log(math.abs(num), 10) - constants.left_digits_to_keep + 1))
    local rounded_num = math.floor((num + digits_modulus / 2) / digits_modulus) * digits_modulus
    -- If we accidentally rounded down to zero, round the other direction instead
    if rounded_num == 0 then
        rounded_num = math.ceil(num / digits_modulus) * digits_modulus
    end

    return rounded_num
end

local function round_discrete(num)
    local modulus = 1
    if 20 < num then
        modulus = 5
    elseif 100 < num then
        modulus = 10
    end

    local rounded_num = math.floor((num + modulus / 2) / modulus) * modulus
    if rounded_num == 0 then
        rounded_num = math.ceil(num / modulus) * modulus
    end

    return rounded_num
end

local function round_pure_discrete(num)
    return math.floor(num + 1 / 2)
end

randnum.fixes = function(params, val)
    -- Rounding first
    if params.rounding == "normal" then -- Default rounding value
        val = round_normal(val)
    elseif params.rounding == "discrete" then
        val = round_discrete(val)
    elseif params.rounding == "pure_discrete" then
        val = round_pure_discrete(val)
    elseif params.rounding == "none" then
        -- Don't do anything
    -- Otherwise, there was a misspelling
    else
        error()
    end

    -- Assume abs_min and abs_max are rounded
    if params.abs_min ~= "none" and val < params.abs_min then
        val = params.abs_min
    end
    if params.abs_max ~= "none" and val > params.abs_max then
        val = params.abs_max
    end

    return val
end

-- (?) id - id of the randomization
-- (?) prototype - prototype that the randomization is applied to
-- (?) key - the rng key that should be used, mandatory if prototype is nil
-- (?) tbl - the table whose property should be randomized
-- (?) property - the property of the table to be randomized
-- (?) dummy - the dummy value to be randomized, mandatory if prototype and tbl are nil
-- (?) abs_min
-- (?) abs_max
-- (?) range
-- (?) range_min
-- (?) range_max
-- (?) variance
-- (?) bias
-- (?) dir - whether higher values make things "better" (+1) or "worse" (-1)
-- (?) rounding
randnum.rand = function(params)
    -- Fill in and compute values for params that are needed for randomization
    local valid = randnum.fill_in_defaults(params)

    -- If the value is not valid to be randomized, just return back the same value
    if not valid then
        return params.val
    end
    
    local tbl, property, key, real_bias, dir, val, soft_min, hard_min, soft_max, hard_max, step_size = params.tbl, params.property, params.key, params.real_bias, params.dir, params.val, params.soft_min, params.hard_min, params.soft_max, params.hard_max, params.step_size

    -- Perform randomization
    for i = 1, constants.num_rolls do
        local sign = dir
        if rng.value(key) >= real_bias then
            sign = -1 * sign
        end

        for j = 1, constants.steps_per_roll do
            local forces = 0

            if val < soft_min then
                forces = 1 - (val - hard_min) / (soft_min - hard_min)
            end
            if val > soft_max then
                forces = -1 + (hard_max - val) / (hard_max - soft_max)
            end

            val = val + constants.step_size_modifier * val * global_chaos * (step_size / (constants.num_rolls * constants.steps_per_roll)) * (sign + forces)

            -- Reset t_val if it passed hard_max or hard_min due to too high forces
            if val > hard_max then
                val = hard_max * 0.95 + hard_min * 0.05
            end
            if val < hard_min then
                val = hard_min * 0.95 + hard_max * 0.05
            end
        end
    end

    val = randnum.fixes(params, val)

    -- Update with randomized value, and return this value
    tbl[property] = val
    return tbl[property]
end

return randnum