local randnum = require("lib/random/randnum")
local rng = require("lib/random/rng")

local randomize = randnum.rand

randomizations.energy = function(params)
    local old_property = params.property
    params.property = nil

    local multiplier = 1
    local suffix = "J"
    if params.is_power then
        multiplier = 60
        suffix = "W"
    end

    tbl_to_use = params.prototype
    if params.tbl ~= nil then
        tbl_to_use = params.tbl
    end

    local energy_as_number = multiplier * util.parse_energy(tbl_to_use[old_property])
    params.dummy = energy_as_number
    params.key = rng.key({id = params.id, prototype = params.prototype})
    local new_energy_as_number = randomize(params)

    tbl_to_use[old_property] = new_energy_as_number .. suffix
end