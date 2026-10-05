-- Run from the mod root: lua lib/random/test-tuning.lua
-- Lua 5.4 stand-ins for the arithmetic helpers used by this repository's RNG.
bit32 = {
    bxor = function(a, b) return (a ~ b) & 0xFFFFFFFF end,
    lshift = function(a, n) return (a << n) & 0xFFFFFFFF end,
    rshift = function(a, n) return (a & 0xFFFFFFFF) >> n end,
}
math.pow = math.pow or function(a, b) return a ^ b end
local constants = require("helper-tables/constants")
local customization = require("lib/customization")
local tuning = require("lib/random/tuning")
local rng = require("lib/random/rng")
local randnum = require("lib/random/randnum")
local randprob = require("lib/random/randprob")
local locale_utils = require("lib/locale")

local id = "belt_speed"
local function setup(text)
    config = {
        seed = 23,
        bias = 0,
        bias_idx = 2,
        chaos = 1,
        chaos_range = 1,
        numerical_algorithm = "exfret-random-walk",
        numerical_overrides = {},
        numerical_variances = {},
    }
    local state = customization.parse(text or "")
    assert(#state.warnings == 0)
    config.numerical_overrides[id] = customization.resolve(state, id)
    rng.prgs = {}
end
local function near(a, b)
    assert(math.abs(a - b) < 1e-12, tostring(a) .. " ~= " .. tostring(b))
end

-- Captured from randnum.lua before the customization refactor, including RNG states.
local baseline = {
    {
        rounding = tuning.default_rounding,
        value = 22.5,
        x1 = 495681,
        x2 = 466581,
    },
    {
        rounding = "discrete",
        value = 18,
        x1 = 264991,
        x2 = 889381,
    },
    {
        rounding = "pure_discrete",
        value = 12,
        x1 = 996302,
        x2 = 491885,
    },
    {
        rounding = "discrete_float",
        value = 10,
        x1 = 1033857,
        x2 = 434721,
    },
    {
        rounding = "none",
        value = 13.076265864332521,
        x1 = 693144,
        x2 = 869765,
    },
}
setup()
for index, fixture in pairs(baseline) do
    local key = "customizer-baseline-" .. index
    local value = randnum.rand({
        id = id,
        key = key,
        dummy = 17,
        variance = "small",
        rounding = fixture.rounding,
        dir = -1,
        abs_min = 1,
        abs_max = 60,
    })
    near(value, fixture.value)
    assert(rng.prgs[key].X1 == fixture.x1 and rng.prgs[key].X2 == fixture.x2, "empty overrides must consume the same RNG draws")
end

setup("PARAM:setting/propertyrandomizer-logistic.range=small;PARAM:setting/propertyrandomizer-logistic.variance=very_big;PARAM:" .. id .. ".variance=very_small;PARAM:" .. id .. ".range_min=big;PARAM:" .. id .. ".bias=best;PARAM:" .. id .. ".chaos=light")
local params = {
    id = id,
    key = "tuning-fields",
    dummy = 10,
    variance = "medium",
    rounding = "pure_discrete",
    dir = -1,
    bias = 0.05,
    abs_min = 2,
    abs_max = 15,
}
assert(randnum.fill_in_defaults(params))
assert(params.variance == "very_small" and params.range == "small" and params.range_min == "big")
near(params.hard_min, 10 / (4 * constants.chaos_string_to_range_num.light))
near(params.hard_max, 10 * 2 * constants.chaos_string_to_range_num.light)
assert(params.step_size == 1.5 and params.tuning_chaos == 0.3)
assert(params.abs_min == 2 and params.abs_max == 15 and params.rounding == "pure_discrete" and params.dir == -1 and params.bias == 0.05, "implementation constraints must be kept")
near(params.real_bias, 0.5 + 0.05 + constants.split_bias + constants.bias_string_to_num.best)
assert(config.bias == 0 and config.chaos == 1, "local settings must not change global configuration")

setup("PARAM:" .. id .. ".range=small;PARAM:" .. id .. ".variance=same")
local linked = {
    id = id,
    key = "linked-fields",
    dummy = 10,
    variance = "big",
}
randnum.fill_in_defaults(linked)
assert(linked.range == "small" and linked.variance == "small", "same links variance to effective range")
assert(config.numerical_variances[id] == "small")
setup("PARAM:" .. id .. ".variance=big;PARAM:" .. id .. ".range=same")
linked = {
    id = id,
    key = "linked-fields",
    dummy = 10,
    range = "small",
}
randnum.fill_in_defaults(linked)
assert(linked.range == "big" and linked.variance == "big")

-- Probability helpers must preserve the forced rounding of their temporary multiplier.
local instruction = "PARAM:" .. id .. ".range=big;PARAM:" .. id .. ".variance=very_small;PARAM:" .. id .. ".chaos=less;PARAM:" .. id .. ".bias=worse"
setup(instruction)
local probability = {value = 0.4}
local p = randprob.rand({
    id = id,
    key = "probability-tuning",
    tbl = probability,
    property = "value",
    abs_min = 0.2,
    abs_max = 0.8,
    rounding = "none",
})
local probability_state = rng.prgs["probability-tuning"]
setup()
config.bias = constants.bias_string_to_num.worse
config.chaos = constants.chaos_string_to_num.less
config.chaos_range = constants.chaos_string_to_range_num.less
local expected = randprob.rand({
    id = id,
    key = "probability-tuning",
    dummy = 0.4,
    range = "big",
    variance = "very_small",
    abs_min = 0.2,
    abs_max = 0.8,
    rounding = "none",
})
near(p, expected)
assert(probability.value == p and p >= 0.2 and p <= 0.8)
assert(rng.prgs["probability-tuning"].X1 == probability_state.X1 and rng.prgs["probability-tuning"].X2 == probability_state.X2)

-- Bias/chaos overrides should match the equivalent global settings on the real walk.
setup(instruction)
local overridden = randnum.rand({
    id = id,
    key = "walk-tuning",
    dummy = 20,
    dir = -1,
})
setup()
config.bias = constants.bias_string_to_num.worse
config.chaos = constants.chaos_string_to_num.less
config.chaos_range = constants.chaos_string_to_range_num.less
local equivalent = randnum.rand({
    id = id,
    key = "walk-tuning",
    dummy = 20,
    dir = -1,
    range = "big",
    variance = "very_small",
})
near(overridden, equivalent)

setup("PARAM:" .. id .. ".variance=very_small")
randnum.rand({
    id = id,
    key = "tooltip-tuning",
    dummy = 20,
})
locale_utils.find_localised_description = function() return {""} end
local tooltip_params
locale_utils.create_tooltip = function(_, options)
    tooltip_params = options
    return "fixture-tooltip"
end
locale_utils.create_localised_description({}, 1, id, {variance = "big"})
assert(tooltip_params.mul_std == constants.str_to_mul_std.very_small, "tooltips must use effective tuning")
setup("PARAM:" .. id .. ".range=small")
randnum.rand({
    id = id,
    key = "compound-size",
    dummy = 20,
    variance = "big",
})
randnum.rand({
    id = id,
    key = "compound-aspect-ratio",
    dummy = 1,
    variance = "medium",
})
locale_utils.create_localised_description({}, 1, id, {variance = "big"})
assert(tooltip_params.mul_std == constants.str_to_mul_std.big, "a range-only override must preserve a compound tooltip's explicit variance")
print("ok - numerical tuning, probability transforms, constraints, tooltips and unchanged seeded results")
