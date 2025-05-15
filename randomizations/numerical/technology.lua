local randnum = require("lib/random/randnum")
local rng = require("lib/random/rng")

local randomize = randnum.rand

-- TODO: Research trigger amounts
-- TODO: Research bonus amounts (like extra bullet damage)

randomizations.tech_costs = function(id)
    for _, tech in pairs(data.raw.technology) do
        if tech.unit ~= nil then
            if tech.unit.count ~= nil then
                randomize({
                    id = id,
                    prototype = tech,
                    tbl = tech.unit,
                    property = "count",
                    abs_min = 1,
                    dir = -1
                })
            else
                -- In this case, we have a count formula
                local key = rng.key({id = id, prototype = prototype})
                local formula_multiplier = randomize({
                    key = key,
                    dummy = 1,
                    dir = -1
                })
                tech.unit.count_formula = formula_multiplier .. "*(" .. tech.unit.count_formula .. ")"
            end
        end
    end
end

randomizations.tech_times = function(id)
    for _, tech in pairs(data.raw.technology) do
        if tech.unit ~= nil then
            randomize({
                id = id,
                prototype = tech,
                tbl = tech.unit,
                property = "time",
                abs_min = 1,
                dir = -1,
                rounding = "discrete"
            })
        end
    end
end