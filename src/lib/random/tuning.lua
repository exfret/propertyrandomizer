-- Shared by startup configuration, numerical randomization and the customizer.
local constants = require("src/config/constants")

local tuning = {}
tuning.default_rounding = "normal"
tuning.parameter_order = {
    "range",
    "range_min",
    "range_max",
    "variance",
    "bias",
    "chaos",
}

tuning.defaults = {
    abs_min = "none",
    abs_max = "none",
    range = "same",
    range_min = "same",
    range_max = "same",
    variance = "same",
    bias = 0,
    dir = 1,
}

tuning.range_caps = {
    very_small = {
        1.2,
        1.5,
    },
    small = {
        1.4,
        2,
    },
    medium = {
        1.75,
        2.5,
    },
    big = {
        2.25,
        4,
    },
    very_big = {
        3,
        10,
    },
    none = {
        0,
        constants.reasonably_large_number,
    },
}

tuning.step_sizes = {
    very_small = 1.5,
    small = 2.5,
    medium = 5,
    big = 10,
    very_big = 20,
}

local levels = {
    "very_small",
    "small",
    "medium",
    "big",
    "very_big",
    "same",
}
-- Bias and chaos replace the corresponding global setting for this randomization.
-- Implementation-specific bias offsets, limits, directions and rounding are kept.
tuning.parameters = {
    range = {values = levels},
    range_min = {values = levels},
    range_max = {values = levels},
    variance = {values = levels},
    bias = {
        values = {
            "worst",
            "worse",
            "default",
            "better",
            "best",
        },
    },
    chaos = {
        values = {
            "light",
            "less",
            "default",
            "more",
            "ultimate",
        },
    },
}

tuning.valid_value = function(parameter, value)
    local info = tuning.parameters[parameter]
    if info == nil then
        return false
    end
    for _, allowed in pairs(info.values) do
        if value == allowed then
            return true
        end
    end
    return false
end

return tuning
