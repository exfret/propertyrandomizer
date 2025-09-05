local randnum = require("lib/random/randnum")
local rng = require("lib/random/rng")
local locale_utils = require("lib/locale")

local randomize = randnum.rand

-- TODO: Research trigger amounts
-- TODO: Research bonus amounts (like extra bullet damage)

-- Biased toward lower amounts to make expected average closer to normal
randomizations.tech_costs = function(id)
    for _, tech in pairs(data.raw.technology) do
        if tech.unit ~= nil then
            if tech.unit.count ~= nil then
                local old_count = tech.unit.count

                randomize({
                    id = id,
                    prototype = tech,
                    tbl = tech.unit,
                    property = "count",
                    abs_min = 1,
                    bias = 0.05,
                    dir = -1
                })

                tech.localised_description = locale_utils.create_localised_description(tech, tech.unit.count / old_count, id, {flipped = true})
            else
                -- In this case, we have a count formula
                local key = rng.key({id = id, prototype = prototype})
                local formula_multiplier = randomize({
                    key = key,
                    dummy = 1,
                    abs_min = 1,
                    bias = 0.05,
                    dir = -1
                })
                tech.unit.count_formula = formula_multiplier .. "*(" .. tech.unit.count_formula .. ")"

                tech.localised_description = locale_utils.create_localised_description(tech, formula_multiplier, id, {flipped = true})
            end
        end
    end
end

randomizations.tech_times = function(id)
    for _, tech in pairs(data.raw.technology) do
        if tech.unit ~= nil then
            local old_time = tech.unit.time

            randomize({
                id = id,
                prototype = tech,
                tbl = tech.unit,
                property = "time",
                abs_min = 1,
                bias = 0.05,
                dir = -1,
                rounding = "discrete"
            })

            tech.localised_description = locale_utils.create_localised_description(tech, tech.unit.time / old_time, id, {flipped = true})
        end
    end
end