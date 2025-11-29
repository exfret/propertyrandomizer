local constants = require("helper-tables/constants")
local rng = require("lib/random/rng")
local fleish = require("lib/random/fleishman")

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
        real_bias = true,
        -- For non-normal randomization implementation
        mul_std = true,
        -- For percentage randomization implementation
        probability_scale = true,
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
        very_small = {1.2, 1.5},
        small = {1.4, 2},
        medium = {1.75, 2.5},
        big = {2.25, 4},
        very_big = {3, 10},
        none = {0, constants.reasonably_large_number}
    }
    local min_key = "range_min"
    if params.range_min == "same" then
        min_key = "range"
    end
    params.soft_min = 1 / (str_to_cap[params[min_key]][1] * global_chaos_range) * params.val
    params.hard_min = 1 / (str_to_cap[params[min_key]][2] * global_chaos_range) * params.val
    local max_key = "range_max"
    if params.range_max == "same" then
        max_key = "range"
    end
    params.soft_max = (str_to_cap[params[max_key]][1] * global_chaos_range) * params.val
    params.hard_max = (str_to_cap[params[max_key]][2] * global_chaos_range) * params.val

    local str_to_step_size = {
        very_small = 1.5,
        small = 2.5,
        medium = 5,
        big = 10,
        very_big = 20
    }
    params.step_size = str_to_step_size[params.variance or "medium"]
    
    local str_to_mul_std = {
        very_small = 1.1,
        small = 1.2,
        medium = 1.5,
        big = 2.0,
        very_big = 3.5
    }
    params.mul_std = str_to_mul_std[params.variance or "medium"]

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

local function round(num, increment)
    return math.floor(num / increment + 0.5) * increment
end

-- How about rounding to some nice composite numbers?
-- How about randomizing the rounding itself?
local nice_rounding_coefficients = {
    {
        { 1.0, 2.0, 5.0, 10.0 }, -- 1 digits, divisors of 2
        { 1.0, 2.0, 3.0, 5.0, 6.0, 10.0 }, -- 1 digits, divisors of 6
        { 1.0, 2.0, 4.0, 5.0, 10.0 }, -- 1 digits, divisors of 4
        { 1.0, 2.0, 4.0, 5.0, 8.0, 10.0 }, -- 1 digits, divisors of 8
        { 1.0, 3.0, 10.0 }, -- 1 digits, divisors of 3
        { 1.0, 3.0, 9.0, 10.0 }, -- 1 digits, divisors of 9
        { 1.0, 2.0, 5.0, 10.0 }, -- 1 digits, divisors 5
        { 1.0, 7.0, 10.0 }, -- 1 digits, divisors of 7
    },
    {
        { 1.0, 1.2, 1.5, 2.0, 2.4, 2.5, 3.0, 4.0, 5.0, 6.0, 7.5, 8.0, 10.0 }, -- 2 digits, divisors of 60
        { 1.0, 2.0, 5.0, 10.0 }, -- 2 digits, divisors of 2
        { 1.0, 1.2, 1.5, 1.8, 2.0, 2.4, 2.5, 3.0, 3.6, 4.0, 4.5, 5.0, 6.0, 7.2, 7.5, 8.0, 9.0, 10.0 }, -- 2 digits, divisors of 72
        { 1.0, 1.2, 1.4, 1.5, 2.0, 2.1, 2.5, 2.8, 3.0, 3.5, 4.0, 4.2, 5.0, 6.0, 7.0, 7.5, 8.4, 10.0 }, -- 2 digits, divisors of 84
        { 1.0, 1.2, 1.5, 1.8, 2.0, 2.5, 3.0, 3.6, 4.0, 4.5, 5.0, 6.0, 7.5, 9.0, 10.0 }, -- 2 digits, divisors of 90
        { 1.0, 1.2, 1.5, 1.6, 2.0, 2.4, 2.5, 3.0, 3.2, 4.0, 4.8, 5.0, 6.0, 7.5, 8.0, 9.6, 10.0 }, -- 2 digits, divisors of 96
        { 1.0, 1.2, 1.5, 1.6, 2.0, 2.4, 2.5, 3.0, 4.0, 4.8, 5.0, 6.0, 7.5, 8.0, 10.0 }, -- 2 digits, divisors of 48
        { 1.0, 1.2, 1.5, 2.0, 2.4, 2.5, 3.0, 4.0, 5.0, 6.0, 7.5, 8.0, 10.0 }, -- 2 digits, divisors of 24
    },
    {
        { 1.0, 1.05, 1.12, 1.2, 1.25, 1.4, 1.5, 1.6, 1.68, 1.75, 2.0, 2.1, 2.4, 2.5, 2.8, 3.0, 3.36, 3.5, 3.75, 4.0, 4.2, 4.8,
            5.0, 5.25, 5.6, 6.0, 6.25, 7.0, 7.5, 8.0, 8.4, 8.75, 10.0 }, -- 3 digits, divisors of 840
        { 1.0, 1.2, 1.25, 1.44, 1.5, 1.6, 1.8, 2.0, 2.25, 2.4, 2.5, 2.88, 3.0, 3.2, 3.6, 3.75, 4.0, 4.5, 4.8, 5.0, 6.0, 6.25,
            7.2, 7.5, 8.0, 9.0, 9.6, 10.0 }, -- 3 digits, divisors of 720
        { 1.0, 1.2, 1.25, 1.28, 1.5, 1.6, 1.92, 2.0, 2.4, 2.5, 3.0, 3.2, 3.75, 3.84, 4.0, 4.8, 5.0, 6.0, 6.25, 6.4, 7.5, 8.0,
            9.6, 10.0 }, -- 3 digits, divisors of 960
        { 1.0, 1.2, 1.25, 1.44, 1.5, 1.6, 1.8, 2.0, 2.25, 2.4, 2.5, 3.0, 3.6, 3.75, 4.0, 4.5, 4.8, 5.0, 6.0, 6.25, 7.2, 7.5,
            8.0, 9.0, 10.0 }, -- 3 digits, divisors of 360
        { 1.0, 1.05, 1.2, 1.25, 1.4, 1.5, 1.68, 1.75, 2.0, 2.1, 2.4, 2.5, 2.8, 3.0, 3.5, 3.75, 4.0, 4.2, 5.0, 5.25, 5.6, 6.0,
            7.0, 7.5, 8.0, 8.4, 8.75, 10.0 }, -- 3 digits, divisors of 420
        { 1.0, 1.2, 1.25, 1.44, 1.5, 1.6, 1.8, 2.0, 2.25, 2.4, 2.5, 3.0, 3.6, 3.75, 4.0, 4.5, 4.8, 5.0, 6.0, 6.25, 7.2, 7.5,
            8.0, 9.0, 10.0 }, -- 3 digits, divisors of 900
        { 1.0, 1.2, 1.25, 1.5, 1.6, 1.92, 2.0, 2.4, 2.5, 3.0, 3.2, 3.75, 4.0, 4.8, 5.0, 6.0, 6.25, 6.4, 7.5, 8.0, 9.6, 10.0 },
            -- 3 digits, divisors of 480
        { 1.0, 1.05, 1.2, 1.25, 1.26, 1.4, 1.5, 1.68, 1.75, 1.8, 2.0, 2.1, 2.25, 2.4, 2.5, 2.52, 2.8, 3.0, 3.15, 3.5, 3.6,
            3.75, 4.0, 4.2, 4.5, 5.0, 5.04, 5.25, 5.6, 6.0, 6.3, 7.0, 7.2, 7.5, 8.0, 8.4, 8.75, 9.0, 10.0 }, -- 3 digits, divisors of 504
    }
}
local nice_low_integers = {
    { 1, 2, 5, 10, 12, 15, 20, 24, 25, 30, 40, 50, 60, 75, 80, 100 },
    { 1, 2, 3, 5, 6, 10, 20, 50, 100 },
    { 1, 2, 4, 5, 10, 12, 15, 18, 20, 24, 25, 30, 36, 40, 45, 50, 60, 72, 75, 80, 90, 100 },
    { 1, 2, 4, 5, 8, 10, 12, 14, 15, 20, 21, 25, 28, 30, 35, 40, 42, 50, 60, 70, 75, 84, 100 },
    { 1, 3, 10, 12, 15, 18, 20, 25, 30, 36, 40, 45, 50, 60, 75, 90, 100 },
    { 1, 3, 9, 10, 12, 15, 16, 20, 24, 25, 30, 32, 40, 48, 50, 60, 75, 80, 96, 100 },
    { 1, 2, 5, 10, 12, 15, 16, 20, 24, 25, 30, 40, 48, 50, 60, 75, 80, 100 },
    { 1, 7, 10, 12, 15, 20, 24, 25, 30, 40, 50, 60, 75, 80, 100 },
}

local function round_discrete_float(num, key)
    if num == 0 then
        return num;
    end
    local abs = math.abs(num)
    local magnitude = 10^math.floor(math.log(abs, 10))
    local coefficient = abs / magnitude
    local digits = rng.int(key, #nice_rounding_coefficients)
    local set_idx = rng.int(key, #nice_rounding_coefficients[digits])
    local target_coefficients = nice_rounding_coefficients[digits][set_idx]
    local rounded_coefficient = 0
    for i = 2, #target_coefficients do
        if target_coefficients[i] > coefficient then
            local low = target_coefficients[i - 1]
            rounded_coefficient = round(coefficient - low, target_coefficients[i] - low) + low
            break
        end
    end
    local rounded_abs = rounded_coefficient * magnitude
    if num < 0 then
        return 0 - rounded_abs
    end
    return rounded_abs
end

local function round_discrete(num, key)
    if num == 0 then
        return num;
    end
    local set_idx = rng.int(key, #nice_low_integers)
    local target_coefficients = nice_low_integers[set_idx]
    local abs = math.abs(num)
    if abs >= target_coefficients[#target_coefficients] then
        return round_discrete_float(num, key)
    end
    local rounded_abs = 1
    if abs > 1 then
        for i = 2, #target_coefficients do
            if target_coefficients[i] > abs then
                local low = target_coefficients[i - 1]
                rounded_abs = round(abs - low, target_coefficients[i] - low) + low
                break
            end
        end
    end
    if num < 0 then
        return 0 - rounded_abs
    end
    return rounded_abs
end

local function round_pure_discrete(num)
    return round(num, 1)
end

randnum.fixes = function(params, val)
    -- Rounding first
    if params.rounding == "normal" then -- Default rounding value
        val = round_normal(val)
    elseif params.rounding == "discrete" then
        val = round_discrete(val, params.key)
    elseif params.rounding == "pure_discrete" then
        val = round_pure_discrete(val)
    elseif params.rounding == "discrete_float" then
        val = round_discrete_float(val, params.key)
    elseif params.rounding == "none" then
        -- Don't do anything
    -- Otherwise, there was a misspelling
    else
        error()
    end

    -- Assume abs_min and abs_max are rounded
    if params.abs_min ~= nil and params.abs_min ~= "none" and val < params.abs_min then
        val = params.abs_min
    end
    if params.abs_max ~= nil and params.abs_max ~= "none" and val > params.abs_max then
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
    local tbl, property, key = params.tbl, params.property, params.key
    local real_bias, dir, step_size = params.real_bias, params.dir, params.step_size
    local val, soft_min, hard_min, soft_max, hard_max = params.val, params.soft_min, params.hard_min, params.soft_max, params.hard_max
    local mul_std, bias_idx, chaos_val = params.mul_std, global_bias_idx, global_chaos

    --[[ What is this, a homebrewed random walk algorithm?
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
    ]]

    if dir < 0 then
        -- assuming 5 bias options: 0 (strong negative) to 4 (strong positive) with 2 as no bias
        bias_idx = (5 - 1) - bias_idx
    elseif dir == 0 then
        bias_idx = 2
    end

    val = fleish.randomize_multiplicatively(key, val, mul_std, bias_idx, chaos_val)

    --[[ Nah, no mercy
    if val > hard_max then
        val = hard_max
    end
    if val < hard_min then
        val = hard_min
    end
    ]]

    val = randnum.fixes(params, val)

    -- Update with randomized value, and return this value
    tbl[property] = val
    return tbl[property]
end

return randnum