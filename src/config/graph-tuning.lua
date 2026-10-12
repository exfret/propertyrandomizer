-- Override schema shared by the data-stage policy and the in-game draft editor.
local constants = require("src/config/constants")

local tuning = {}
tuning.targets = {}
for id in string.gmatch("item recipe-ingredients recipe-category entity entity-energy-source mining-fluid-required mining-results spoiling tech-triggers", "%S+") do
    tuning.targets[id] = true
end
tuning.parameter_order = {
    "amount",
    "keep_category",
    "ingredient_count",
    "fluids",
    "resource_balance",
}
tuning.parameters = {
    amount = {
        values = {
            "0",
            "25",
            "50",
            "75",
            "100",
        },
    },
    keep_category = {
        values = {
            "0",
            "25",
            "50",
            "75",
            "100",
        },
    },
    ingredient_count = {
        values = {
            "preserve",
            "very_small",
            "small",
            "medium",
            "big",
            "very_big",
        },
    },
    fluids = {
        values = {
            "preserve",
            "less",
            "default",
            "more",
        },
    },
    resource_balance = {
        values = {
            "on",
            "off",
        },
    },
}
tuning.supports = function(id, field)
    return field == "amount" or id == "all"
        or (field == "keep_category" and id == "recipe-category")
        or ((field == "ingredient_count" or field == "fluids" or field == "resource_balance") and id == "recipe-ingredients")
end
tuning.valid_target = function(target)
    local id = string.match(target or "", "^graph/(.+)$")
    return id ~= nil and (id == "all" or tuning.targets[id] == true)
end
tuning.valid_value = function(field, value)
    local parameter = tuning.parameters[field]
    if parameter == nil then
        return false
    end
    if field == "amount" or field == "keep_category" then
        local number = tonumber(value)
        return number ~= nil and number >= 0 and number <= 100 and number % 1 == 0
    end
    for _, allowed in pairs(parameter.values) do
        if allowed == value then
            return true
        end
    end
    return false
end
tuning.valid_selector = function(selector)
    local kind, name = string.match(selector or "", "^([%w_-]+)/(.+)$")
    if kind == "prototype" then
        return string.match(name, "^[%w_-]+/.+$") ~= nil
    end
    return name ~= nil and (kind == "type" or kind == "group" or kind == "subgroup")
end
tuning.resolve = function(state, id)
    local result = {}
    for field, value in pairs((state.graph or {}).all or {}) do
        if tuning.supports(id, field) then
            result[field] = value
        end
    end
    for field, value in pairs((state.graph or {})[id] or {}) do
        result[field] = value
    end
    return result
end
tuning.default = function(field)
    if field == "amount" then
        return "100"
    elseif field == "keep_category" then
        return "50"
    elseif field == "ingredient_count" then
        return constants.recipe_shape.count_range
    elseif field == "fluids" then
        return "default"
    elseif field == "resource_balance" then
        return "on"
    end
end

return tuning
