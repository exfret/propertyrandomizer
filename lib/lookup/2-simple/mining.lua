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

-- With items and fluids trading positions, a resource's results can change form (item_fluid.resource_category_key), so every fluid count some drill of the category can serve gets a spoofed category too
-- Returns resource category --> { input = whether a drill of it has an input fluid box, output = whether one has an output fluid box }, or nil when it doesn't apply
local function drill_fluid_boxes()
    if config == nil or not config.item_fluids then
        return nil
    end
    local boxes = {}
    for _, drill in pairs(prots("mining-drill")) do
        for _, cat in pairs(drill.resource_categories or {}) do
            boxes[cat] = boxes[cat] or {
                input = false,
                output = false,
            }
            boxes[cat].input = boxes[cat].input or drill.input_fluid_box ~= nil
            boxes[cat].output = boxes[cat].output or drill.output_fluid_box ~= nil
        end
    end
    return boxes
end

-- Every fluid count combination the drills of a resource's category can serve, as a list of { input, output }
local function fluid_combinations(boxes, category)
    local combinations = {}
    local can = boxes[category] or {
        input = false,
        output = false,
    }
    for input = 0, (can.input and 1 or 0) do
        for output = 0, (can.output and 1 or 0) do
            table.insert(combinations, {
                input = input,
                output = output,
            })
        end
    end
    return combinations
end

-- Mining categories (spoofed with fluid counts)
stage.mcats = function()
    local mcats = {}
    local function add_mcat(cat, fluids)
        local name = lutils.mcat_key(cat, fluids)
        if mcats[name] == nil then
            mcats[name] = {
                cat = cat,
                input = fluids.input,
                output = fluids.output,
            }
        end
    end

    local boxes = drill_fluid_boxes()
    for _, resource in pairs(data.raw.resource) do
        if resource.minable ~= nil then
            add_mcat(resource.category or "basic-solid", lutils.find_mining_fluids(resource))
            -- Every count the category's drills can serve
            if boxes ~= nil then
                for _, fluids in pairs(fluid_combinations(boxes, resource.category or "basic-solid")) do
                    add_mcat(resource.category or "basic-solid", fluids)
                end
            end
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

    local boxes = drill_fluid_boxes()
    for _, resource in pairs(prots("resource")) do
        if resource.minable ~= nil then
            local base_cat = resource.category or "basic-solid"
            local spoofed_key = lutils.mcat_name(resource)

            if mcat_to_mcats[base_cat] == nil then
                mcat_to_mcats[base_cat] = {}
            end
            mcat_to_mcats[base_cat][spoofed_key] = true
            -- Every count the category's drills can serve (see drill_fluid_boxes)
            if boxes ~= nil then
                for _, fluids in pairs(fluid_combinations(boxes, base_cat)) do
                    mcat_to_mcats[base_cat][lutils.mcat_key(base_cat, fluids)] = true
                end
            end
        end
    end

    lu.mcat_to_mcats = mcat_to_mcats
end

return stage