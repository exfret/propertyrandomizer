local randnum = require("lib/random/randnum")

local randomize = randnum.rand

randomizations.fluid_emissions_multiplier = function(id)
    for _, fluid in pairs(data.raw.fluid) do
        if fluid.emissions_multiplier == nil then
            fluid.emissions_multiplier = 1
        end

        randomize({
            id = id,
            prototype = fluid,
            property = "emissions_multiplier",
            range = "small",
            variance = "small"
        })
    end
end

randomizations.fluid_fuel_value = function(id)
    for _, fluid in pairs(data.raw.fluid) do
        if fluid.fuel_value ~= nil then
            randomizations.energy({
                id = id,
                prototype = fluid,
                property = "fuel_value"
            })
        end
    end
end

randomizations.fluid_heat_capacity = function(id)
    for _, fluid in pairs(data.raw.fluid) do
        if fluid.heat_capacity == nil then
            fluid.heat_capacity = "1kJ"
        end

        randomizations.energy({
            id = id,
            prototype = fluid,
            property = "heat_capacity",
            range = "small",
            variance = "small"
        })
    end
end