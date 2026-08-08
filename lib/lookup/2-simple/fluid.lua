-- Maintenance-wise, it's easiest to keep this exact header for all stage 2 lookups, even if not all these are used
-- START repeated header

local collision_mask_util = require("__core__/lualib/collision-mask-util")

local categories = require("helper-tables/categories")
local gutils = require("lib/graph/graph-utils")
local lutils = require("lib/logic/logic-utils")
local dutils = require("lib/data-utils")
local tutils = require("lib/trigger")

local prots = dutils.prots

local stage = {}

local lu
stage.link = function(lu_to_link)
    lu = lu_to_link
end

-- END repeated header

-- List of relevant temperatures for a fluid, in increasing order
-- Format:
--   fluid_name --> array of temperatures
-- To help with this, defines auxiliary map of which temperatures have been added of format
--   fluid_name --> temperature --> true | nil
-- Also defines fluid_temperature_index, with format:
--   fluid_name --> temperature --> index in fluid_temperatures_ordered
stage.fluid_temperatures_ordered = function()
    -- Note: We add to fluid_temps, then construct fluid_temperatures_ordered at the end
    lu.fluid_temps = {}
    lu.fluid_temperatures_ordered = {}
    lu.fluid_temperature_index = {}

    -- Excludes considering fluid box temperature cutoffs, since I judged the extra complexity not to be worth the few (if any) cases this is necessary as a consideration

    -- Default temperatures
    for _, fluid in pairs(prots("fluid")) do
        lu.fluid_temps[fluid.name] = {}
        lu.fluid_temps[fluid.name][fluid.default_temperature] = true
    end

    -- Boilers
    for _, boiler in pairs(prots("boiler")) do
        if boiler.mode == "output-to-separate-pipe" then
            -- Only consider this boiler in this case if it has an output filter
            -- The only alternative would be adding this as a relevant temperature point for everything, which is unrealistic
            local filter = boiler.output_fluid_box.filter 
            if filter ~= nil then
                lu.fluid_temps[filter][boiler.target_temperature] = true
            end
        elseif boiler.mode == "heat-fluid-inside" then
            -- Assume for simplicity as with above that input fluid box is filtered here too
            local filter = boiler.fluid_box.filter
            if filter ~= nil then
                local fluid = data.raw.fluid[filter]
                local max_temp = fluid.max_temperature or fluid.default_temperature
                lu.fluid_temps[filter][max_temp] = true
            end
        end
    end

    -- Fusion reactors
    for _, reactor in pairs(prots("fusion-reactor")) do
        if reactor.target_temperature ~= nil then
            lu.fluid_temps[reactor.output_fluid_box.filter][reactor.target_temperature] = true
        end
    end

    -- Generator temperature isn't really relevant, so we can ignore that

    -- Recipe ingredients/products
    for _, recipe in pairs(prots("recipe")) do
        for _, ing in pairs(dutils.tablize(recipe.ingredients)) do
            if ing.type == "fluid" then
                if ing.temperature ~= nil then
                    lu.fluid_temps[ing.name][ing.temperature] = true
                else
                    if ing.minimum_temperature ~= nil then
                        lu.fluid_temps[ing.name][ing.minimum_temperature] = true
                    end
                    if ing.maximum_temperature ~= nil then
                        lu.fluid_temps[ing.name][ing.maximum_temperature] = true
                    end
                end
            end
        end
        for _, result in pairs(dutils.tablize(recipe.results)) do
            if result.type == "fluid" and result.temperature ~= nil then
                lu.fluid_temps[result.name][result.temperature] = true
            end
        end
    end

    -- Minable results
    for _, minable_type in pairs({"entity", "tile"}) do
        for _, prot in pairs(dutils.get_all_prots(minable_type)) do
            if prot.minable ~= nil and prot.minable.results ~= nil then
                for _, result in pairs(prot.minable.results) do
                    if result.type == "fluid" and result.temperature ~= nil then
                        lu.fluid_temps[result.name][result.temperature] = true
                    end
                end
            end
        end
    end

    -- Build ordered maps
    for _, fluid in pairs(prots("fluid")) do
        lu.fluid_temperatures_ordered[fluid.name] = {}
        for temp, _ in pairs(lu.fluid_temps[fluid.name]) do
            table.insert(lu.fluid_temperatures_ordered[fluid.name], temp)
        end
        table.sort(lu.fluid_temperatures_ordered[fluid.name])

        lu.fluid_temperature_index[fluid.name] = {}
        for ind, temp in pairs(lu.fluid_temperatures_ordered[fluid.name]) do
            lu.fluid_temperature_index[fluid.name][temp] = ind
        end
    end
end

return stage