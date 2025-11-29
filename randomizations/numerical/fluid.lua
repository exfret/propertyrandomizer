local randnum = require("lib/random/randnum")
local locale_utils = require("lib/locale")

local randomize = randnum.rand

randomizations.fluid_emissions_multiplier = function(id)
    for _, fluid in pairs(data.raw.fluid) do
        if fluid.emissions_multiplier == nil then
            fluid.emissions_multiplier = 1
        end

        local old_emissions_multiplier = fluid.emissions_multiplier

        randomize({
            id = id,
            prototype = fluid,
            property = "emissions_multiplier",
            range = "small",
            rounding = "discrete_float",
            dir = -1
        })

        fluid.localised_description = locale_utils.create_localised_description(fluid, fluid.emissions_multiplier / old_emissions_multiplier, id, { flipped = true })
    end
end

randomizations.fluid_fuel_value = function(id)
    for _, fluid in pairs(data.raw.fluid) do
        if fluid.fuel_value ~= nil then
            local old_fuel_value = util.parse_energy(fluid.fuel_value)

            randomizations.energy({
                id = id,
                prototype = fluid,
                property = "fuel_value",
                rounding = "discrete_float"
            })

            fluid.localised_description = locale_utils.create_localised_description(fluid, util.parse_energy(fluid.fuel_value) / old_fuel_value, id)
        end
    end
end

randomizations.fluid_heat_capacity = function(id)
    for _, fluid in pairs(data.raw.fluid) do
        if fluid.heat_capacity == nil then
            fluid.heat_capacity = "1kJ"
        end

        local old_heat_capacity = util.parse_energy(fluid.heat_capacity)

        randomizations.energy({
            id = id,
            prototype = fluid,
            property = "heat_capacity",
            range = "small",
            rounding = "discrete_float"
        })

        fluid.localised_description = locale_utils.create_localised_description(fluid, util.parse_energy(fluid.heat_capacity) / old_heat_capacity, id)
    end
end