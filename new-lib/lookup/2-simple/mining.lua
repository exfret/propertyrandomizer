-- Maintenance-wise, it's easiest to keep this exact header for all stage 2 lookups, even if not all these are used
-- START repeated header

local collision_mask_util
if not offline then
    collision_mask_util = require("__core__/lualib/collision-mask-util")
else
    collision_mask_util = require("offline/lualib/collision-mask-util")
end

local categories = require("helper-tables/categories")
local gutils = require("new-lib/graph/graph-utils")
local lutils = require("new-lib/logic/logic-utils")
local dutils = require("new-lib/data-utils")
local tutils = require("lib/trigger")

local prots = dutils.prots

local stage = {}

local lu
stage.link = function(lu_to_link)
    lu = lu_to_link
end

-- END repeated header

-- Mining categories (spoofed with fluid counts)
stage.mcats = function()
    local mcats = {}

    for _, resource in pairs(data.raw.resource) do
        local name = lutils.mcat_name(resource)
        if mcats[name] == nil then
            local fluids = lutils.find_mining_fluids(resource)

            mcats[name] = {
                cat = resource.category or "basic-solid",
                input = fluids.input,
                output = fluids.output,
            }
        end
    end

    lu.mcats = mcats
end

-- Maps spoofed resource category to mining drills
stage.mcat_to_drills = function()
    local mcat_to_drills = {}

    for _, drill_type in pairs({"mining-drill", "character"}) do
        for _, drill in pairs(prots(drill_type)) do
            if lu.entities[drill.name] ~= nil then
                local has_input_box = drill.input_fluid_box ~= nil
                local has_output_box = drill.output_fluid_box ~= nil
                local resource_cats = drill.resource_categories or drill.mining_categories or {"basic-solid"}

                for _, base_cat in pairs(resource_cats) do
                    local max_input = has_input_box and 1 or 0
                    local max_output = has_output_box and 1 or 0

                    for has_input = 0, max_input do
                        for has_output = 0, max_output do
                            local spoofed_key = gutils.concat({base_cat, has_input, has_output})
                            if mcat_to_drills[spoofed_key] == nil then
                                mcat_to_drills[spoofed_key] = {}
                            end
                            mcat_to_drills[spoofed_key][drill.name] = true
                        end
                    end
                end
            end
        end
    end

    lu.mcat_to_drills = mcat_to_drills
end

-- Maps base resource category to spoofed categories that exist (from actual resources)
-- base_mcat -> { spoofed_mcat -> true }
stage.mcat_to_mcats = function()
    local mcat_to_mcats = {}

    for _, resource in pairs(prots("resource")) do
        if resource.minable ~= nil then
            local base_cat = resource.category or "basic-solid"
            local spoofed_key = lutils.mcat_name(resource)

            if mcat_to_mcats[base_cat] == nil then
                mcat_to_mcats[base_cat] = {}
            end
            mcat_to_mcats[base_cat][spoofed_key] = true
        end
    end

    lu.mcat_to_mcats = mcat_to_mcats
end

return stage