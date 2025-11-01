-- Fleishman method for generating non-normal random variables.
-- Implementation adapted from: https://github.com/amanchokshi/non-normal

local rng = require("lib/random/rng")

local Fleishman = {}
Fleishman.__index = Fleishman

--- Generate a standard normal random variable using Box-Muller transform.
-- @param key string The key used for random number generation
-- @return number Standard normal random variable
local function rand_normal(key)
    local u1 = rng.value(key)
    local u2 = rng.value(key)
    if u1 < 1e-12 then
        u1 = 1e-12
    end
    local z = math.sqrt(-2 * math.log(u1)) * math.cos(2 * math.pi * u2)
    return z
end

--- Create a new Fleishman random number generator.
-- @param mean number Target mean of the distribution
-- @param std number Target standard deviation
-- @param skew number Target skewness
-- @param ekurt number Target excess kurtosis
-- @return table New Fleishman instance
function Fleishman.new(mean, std, skew, ekurt)
    local self = setmetatable({}, Fleishman)
    self._b = 0
    self._c = 0
    self._d = 0
    self._mean = 0
    self._std = 0
    self._skew = 0
    self._ekurt = 0
    self:_solve_coefficients(mean, std, skew, ekurt)
    return self
end

function Fleishman:_fl_func(b0, c0, d0)
    local x = (b0 * b0) + 6 * (b0 * d0) + 2 * (c0 * c0) + 15 * (d0 * d0)
    local y = 2 * c0 * ((b0 * b0) + 24 * (b0 * d0) + 105 * (d0 * d0) + 2)
    local z = 24 * ((b0 * d0) + (c0 * c0) * (1 + (b0 * b0) + 28 * (b0 * d0)) + (d0 * d0) * (12 + 48 * (b0 * d0) + 141 * (c0 * c0) + 225 * (d0 * d0)))
    return {x - 1, y - self._skew, z - self._ekurt}
end

--- Solve for coefficients that will generate the desired distribution.
-- @param mean number Target mean
-- @param std number Target standard deviation
-- @param skew number Target skewness
-- @param ekurt number Target excess kurtosis
function Fleishman:_solve_coefficients(mean, std, skew, ekurt)
    self._mean = mean
    self._std = std
    self._skew = skew
    self._ekurt = ekurt
    
    local converge = 1e-30
    local max_iter = 128
    local ekurt_thresh = -1.13168 + 1.58837 * self._skew * self._skew

    if self._ekurt < ekurt_thresh then
        error(string.format(
            "For the Fleishman method to function with:\n\tmean: %.2f\n\tstd: %.2f\n\tskew: %.2f\nThe value of [ekurt] must be >= [%.4f]",
            self._mean, self._std, self._skew, ekurt_thresh
        ))
    end

    local b0 = (0.95357 - 0.05679 * self._ekurt + 0.03520 * self._skew * self._skew + 0.00133 * self._ekurt * self._ekurt)
    local c0 = 0.10007 * self._skew + 0.00844 * self._skew * self._skew * self._skew
    local d0 = 0.30978 - 0.31655 * b0

    local i = 0
    local f = self:_fl_func(b0, c0, d0)

    while math.max(math.abs(f[1]), math.abs(f[2]), math.abs(f[3])) > converge and i < max_iter do
        local b2 = b0 * b0
        local c2 = c0 * c0
        local d2 = d0 * d0
        local bd = b0 * d0

        local df1db = 2 * b0 + 6 * d0
        local df1dc = 4 * c0
        local df1dd = 6 * b0 + 30 * d0
        local df2db = 4 * c0 * (b0 + 12 * d0)
        local df2dc = 2 * (b2 + 24 * bd + 105 * d2 + 2)
        local df2dd = 4 * c0 * (12 * b0 + 105 * d0)
        local df3db = 24 * (d0 + c2 * (2 * b0 + 28 * d0) + 48 * d0 * d0 * d0)
        local df3dc = 48 * c0 * (1 + b2 + 28 * bd + 141 * d2)
        local df3dd = 24 * (b0 + 28 * b0 * c2 + 2 * d0 * (12 + 48 * bd + 141 * c2 + 225 * d2) + d2 * (48 * b0 + 450 * d0))

        local J = {
            {df1db, df1dc, df1dd},
            {df2db, df2dc, df2dd},
            {df3db, df3dc, df3dd}
        }

        local det = (J[1][1] * (J[2][2] * J[3][3] - J[2][3] * J[3][2]) -
                    J[1][2] * (J[2][1] * J[3][3] - J[2][3] * J[3][1]) +
                    J[1][3] * (J[2][1] * J[3][2] - J[2][2] * J[3][1]))

        if det == 0 then
            error("Matrix is singular and cannot be solved.")
        end

        local inv_det = 1.0 / det

        local inv = {
            {
                (J[2][2] * J[3][3] - J[2][3] * J[3][2]) * inv_det,
                (J[1][3] * J[3][2] - J[1][2] * J[3][3]) * inv_det,
                (J[1][2] * J[2][3] - J[1][3] * J[2][2]) * inv_det,
            },
            {
                (J[2][3] * J[3][1] - J[2][1] * J[3][3]) * inv_det,
                (J[1][1] * J[3][3] - J[1][3] * J[3][1]) * inv_det,
                (J[1][3] * J[2][1] - J[1][1] * J[2][3]) * inv_det,
            },
            {
                (J[2][1] * J[3][2] - J[2][2] * J[3][1]) * inv_det,
                (J[1][2] * J[3][1] - J[1][1] * J[3][2]) * inv_det,
                (J[1][1] * J[2][2] - J[1][2] * J[2][1]) * inv_det,
            },
        }

        local r = {
            inv[1][1] * f[1] + inv[1][2] * f[2] + inv[1][3] * f[3],
            inv[2][1] * f[1] + inv[2][2] * f[2] + inv[2][3] * f[3],
            inv[3][1] * f[1] + inv[3][2] * f[2] + inv[3][3] * f[3],
        }

        b0 = b0 - r[1]
        c0 = c0 - r[2]
        d0 = d0 - r[3]

        f = self:_fl_func(b0, c0, d0)
        i = i + 1
    end

    self._b, self._c, self._d = b0, c0, d0
end

--- Generate a random number with the specified distribution parameters.
-- @param key string The key used for random number generation
-- @return number Random number from the configured distribution
function Fleishman:generate(key)
    local X = rand_normal(key)
    return (-1 * self._c + X * (self._b + X * (self._c + X * self._d))) * self._std + self._mean
end

-- Constants for randomization
local BIAS_OPTION_COUNT = 5 -- Assuming 5 bias options: 0 (strong negative) to 4 (strong positive) with 2 as no bias
local MEAN_COEFF = 1.5 -- Selected such that mode ~ mean for various biases
local CHAOS_COEFF = 0.6 -- Selected to calibrate std behavior to the global chaos settings

-- Cache for storing pre-calculated Fleishman instances
local instance_cache = {}

--- Get or create a Fleishman instance for the given parameters
-- @param bias_idx number Index representing bias level
-- @param chaos_val number Chaos factor affecting standard deviation
-- @return table Fleishman instance configured for these parameters
local function get_fleishman_instance(bias_idx, chaos_val)
    -- Create a cache key from the parameters
    local cache_key = string.format("%.0f_%.6f", bias_idx, chaos_val)
    
    -- Return cached instance if it exists
    if instance_cache[cache_key] then
        return instance_cache[cache_key]
    end
    
    -- Calculate parameters for new instance
    local no_bias_idx = (BIAS_OPTION_COUNT - 1) / 2 -- Index representing no bias. Curiously also works for even counts.
    local bias_val = bias_idx - no_bias_idx -- Convert bias index to signed bias value -2 to 2
    local bias_sign = bias_val > 0 and 1 or bias_val < 0 and -1 or 0 -- Determine bias sign
    local bias_strength = math.abs(bias_val) -- Determine bias strength as distance from no bias index
    local exp_std = chaos_val^CHAOS_COEFF -- Decided to cram in chaos effect as the std here, CHAOS_COEFF for calibration
    local exp_skew = bias_sign * (math.sqrt((bias_strength + 1.13168) / 1.58837) - 2^(-1 * bias_strength)) -- Skew increases with bias strength in direction of bias
    local exp_mean = MEAN_COEFF * bias_sign * bias_strength * exp_std / BIAS_OPTION_COUNT -- Mean is shifted in an attempt to center the mode around 0 after skew
    local exp_ekurt = bias_strength -- Excess kurtosis has to increase with skew due to Fleishman method constraints
    
    -- Create and cache new instance
    instance_cache[cache_key] = Fleishman.new(exp_mean, exp_std, exp_skew, exp_ekurt)
    return instance_cache[cache_key]
end

--- Clear the instance cache to free memory if needed
function Fleishman.clear_cache()
    instance_cache = {}
end

--- Generalized random number generator using Fleishman method.
-- @param key string The key used for random number generation
-- @param old_val number The original value to be randomized
-- @param mul_std number Multiplicative standard deviation factor
-- @param bias_idx number Index representing bias level (0 to BIAS_OPTION_COUNT-1)
-- @param chaos_val number Chaos factor affecting standard deviation
-- @return number A non-normally distributed random number based on the inputs
function Fleishman.randomize_multiplicatively(key, old_val, mul_std, bias_idx, chaos_val)
    local rng_inst = get_fleishman_instance(bias_idx, chaos_val)
    return old_val * mul_std^rng_inst:generate(key) -- Use generated number as exponent to cause multiplicative effect
end

return Fleishman