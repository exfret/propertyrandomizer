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

-- Combined items and fluids (by prototype key, not just name)
stage.materials = function()
    local materials = {}

    for _, item in pairs(lu.items) do
        materials[gutils.key("item", item.name)] = item
    end
    for _, fluid in pairs(lu.fluids) do
        materials[gutils.key("fluid", fluid.name)] = fluid
    end

    lu.materials = materials
end

-- Recipe subgroups (complex calculation)
stage.recipe_subgroup = function()
    local recipe_subgroup = {}

    local type_to_lookup = {
        item = lu.items,
        fluid = lu.fluids,
    }

    for _, recipe in pairs(lu.recipes) do
        if recipe.subgroup ~= nil then
            recipe_subgroup[recipe.name] = recipe.subgroup
        elseif recipe.results == nil then
            recipe_subgroup[recipe.name] = "other"
        elseif recipe.main_product == "" or recipe.main_product == nil then
            local found = false
            for _, result in pairs(recipe.results) do
                if result.name == recipe.main_product then
                    recipe_subgroup[recipe.name] = type_to_lookup[result.type][result.name].subgroup or "other"
                    found = true
                    break
                end
            end
            if not found then
                recipe_subgroup[recipe.name] = "other"
            end
        elseif #recipe.results == 1 then
            recipe_subgroup[recipe.name] = type_to_lookup[recipe.results[1].type][recipe.results[1].name].subgroup or "other"
        else
            recipe_subgroup[recipe.name] = "other"
        end
    end

    lu.recipe_subgroup = recipe_subgroup
end

-- Recipe categories (spoofed to include fluid counts)
stage.rcats = function()
    local rcats = {}
    -- Vanilla resource category to rcat names for it
    local vanilla_to_rcats = {}

    for _, recipe in pairs(lu.recipes) do
        local name = lutils.rcat_name(recipe)
        if rcats[name] == nil then
            local fluids = lutils.find_recipe_fluids(recipe)

            rcats[name] = {
                cat = recipe.category or "crafting",
                input = fluids.input,
                output = fluids.output,
            }
            local vanilla_name = recipe.category or "crafting"
            vanilla_to_rcats[vanilla_name] = vanilla_to_rcats[vanilla_name] or {}
            vanilla_to_rcats[vanilla_name][name] = true
        end
    end

    lu.rcats = rcats
    lu.vanilla_to_rcats = vanilla_to_rcats
end

-- Maps base recipe category names to their spoofed rcat names
stage.cat_to_rcats = function()
    local cat_to_rcats = {}

    for rcat_name, rcat in pairs(lu.rcats) do
        if cat_to_rcats[rcat.cat] == nil then
            cat_to_rcats[rcat.cat] = {}
        end
        cat_to_rcats[rcat.cat][rcat_name] = true
    end

    lu.cat_to_rcats = cat_to_rcats
end

stage.fixed_recipes = function()
    local fixed_recipes = {}

    -- Technically, furnaces can't have fixed recipes so we don't need to check those but it doesn't hurt
    for class, _ in pairs(categories.crafting_machines) do
        for _, machine in pairs(prots(class)) do
            if machine.fixed_recipe ~= nil and machine.fixed_recipe ~= "" then
                fixed_recipes[machine.fixed_recipe] = fixed_recipes[machine.fixed_recipe] or {}
                fixed_recipes[machine.fixed_recipe][machine.name] = true
            end
        end
    end

    lu.fixed_recipes = fixed_recipes
end

return stage