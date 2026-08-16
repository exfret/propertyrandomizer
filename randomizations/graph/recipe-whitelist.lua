local costs
local sa_costs = require("lib/cost/material-costs/sa")
local py_costs_automation = require("lib/cost/material-costs/py-full-automation-science")
local py_costs_py_1 = require("lib/cost/material-costs/py-full-py-science-1")
local py_costs_logistic = require("lib/cost/material-costs/py-full-logistic-science")
local py_costs_py_2 = require("lib/cost/material-costs/py-full-py-science-2")
local py_costs_chemical = require("lib/cost/material-costs/py-full-chemical-science")
local py_costs_py_3 = require("lib/cost/material-costs/py-full-py-science-3")
local py_costs_production = require("lib/cost/material-costs/py-full-production-science")
--local py_costs_py_4 = require("lib/cost/material-costs/py-full-py-science-4")
--local py_costs_utility = require("lib/cost/material-costs/py-full-utility-science")
--local py_costs_space = require("lib/cost/material-costs/py-full-space-science")
--local py_costs_pyrrhic = require("lib/cost/material-costs/py-full-pyrrhic")

local whitelist = {}

whitelist.build = function()
    local in_whitelist = {}

    -- Whitelists are built specifically for pyanodons right now
    if mods["pyalternativeenergy"] then
        for _, recipe in pairs(data.raw.recipe) do
            in_whitelist[recipe.name] = {}

            for ind, ing in pairs(recipe.ingredients or {}) do
                -- First, test
            end
        end
    end

    return in_whitelist
end

return whitelist