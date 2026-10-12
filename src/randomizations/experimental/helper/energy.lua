-- Parked military/resistance experiment. Installed only by the explicit experimental flag.
local randnum = require("src/lib/random/randnum")
local rng = require("src/lib/random/rng")
local randomize = randnum.rand

local experimental = {}

experimental.energy = function(params)
    local old_property = params.property
    params.property = nil

    local multiplier = 1
    local suffix = "J"
    if params.is_power then
        multiplier = 60
        suffix = "W"
    end

    local tbl_to_use = params.prototype
    if params.tbl ~= nil then
        tbl_to_use = params.tbl
    end

    local energy_as_number = multiplier * util.parse_energy(tbl_to_use[old_property])
    local original = tbl_to_use[old_property]
    params.dummy = energy_as_number
    params.key = rng.key({id = params.id, prototype = params.prototype})
    if params.combat == nil then
        params.combat = {
            read = function() return energy_as_number end,
            apply = function(value)
                if value == energy_as_number then
                    tbl_to_use[old_property] = original
                else
                    tbl_to_use[old_property] = value .. suffix
                end
            end,
            direction = false,
            fields = {
                {
                    object = tbl_to_use,
                    key = old_property,
                },
            },
        }
    end
    local value = randomize(params)
    if params.combat == false then
        tbl_to_use[old_property] = value .. suffix
    end
    return value
end

return experimental
