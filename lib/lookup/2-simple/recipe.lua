-- Maintenance-wise, it's easiest to keep this exact header for all stage 2 lookups, even if not all these are used
-- START repeated header

local collision_mask_util = require("__core__/lualib/collision-mask-util")

local categories = require("helper-tables/categories")
local gutils = require("lib/graph/graph-utils")
local lutils = require("lib/logic/logic-utils")
local dutils = require("lib/data-utils")
local tutils = require("lib/trigger")
local fluid_ports = require("lib/fluid-ports")

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

    local function add_rcat(cats, fluids)
        local name = lutils.rcat_key(cats, fluids)
        if rcats[name] == nil then
            rcats[name] = {
                cats = cats,
                input = fluids.input,
                output = fluids.output,
            }
            for _, vanilla_name in pairs(cats) do
                vanilla_to_rcats[vanilla_name] = vanilla_to_rcats[vanilla_name] or {}
                vanilla_to_rcats[vanilla_name][name] = true
            end
        end
    end
    for _, recipe in pairs(lu.recipes) do
        add_rcat(recipe.categories or {"crafting"}, lutils.find_recipe_fluids(recipe))
    end
    local num_vanilla = 0
    for _, _ in pairs(rcats) do
        num_vanilla = num_vanilla + 1
    end

    -- With items and fluids trading positions, a recipe's fluid counts change (item_fluid.recipe_category_key), so every count a crafter of its categories can serve gets a category too, for its categories and for hand crafting's traded for the fluid one (fluid_ports.trade_hand_category)
    -- Each category is a mechanic node with a pebble per context that the matching's gate keeps exactly and every sort pays for, so the counts stop at the recipes' own ingredient and result counts, which a recipe's fluid counts can't exceed
    if config ~= nil and config.item_fluids then
        -- Category --> the most fluid inputs and outputs a machine crafting it has
        local most = {}
        for class, _ in pairs(categories.crafting_machines) do
            for _, machine in pairs(prots(class)) do
                local fluids = {
                    input = 0,
                    output = 0,
                }
                for _, box in pairs(machine.fluid_boxes or {}) do
                    if box.production_type == "input" then
                        fluids.input = fluids.input + 1
                    elseif box.production_type == "output" then
                        fluids.output = fluids.output + 1
                    end
                end
                for _, cat in pairs(machine.crafting_categories or {}) do
                    most[cat] = most[cat] or {
                        input = 0,
                        output = 0,
                    }
                    most[cat].input = math.max(most[cat].input, fluids.input)
                    most[cat].output = math.max(most[cat].output, fluids.output)
                end
            end
        end
        local function add_combinations(cats, num_ingredients, num_results)
            local max_input = 0
            local max_output = 0
            for _, cat in pairs(cats) do
                max_input = math.max(max_input, (most[cat] or {}).input or 0)
                max_output = math.max(max_output, (most[cat] or {}).output or 0)
            end
            for input = 0, math.min(max_input, num_ingredients) do
                for output = 0, math.min(max_output, num_results) do
                    add_rcat(cats, {
                        input = input,
                        output = output,
                    })
                end
            end
        end
        for _, recipe in pairs(lu.recipes) do
            local cats = recipe.categories or {"crafting"}
            local num_ingredients = #(recipe.ingredients or {})
            local num_results = #(recipe.results or {})
            add_combinations(cats, num_ingredients, num_results)
            local traded = fluid_ports.fluid_category_exists() and fluid_ports.trade_hand_category(cats) or nil
            if traded ~= nil then
                add_combinations(traded, num_ingredients, num_results)
            end
        end
    end
    local num_rcats = 0
    for _, _ in pairs(rcats) do
        num_rcats = num_rcats + 1
    end
    log("Recipe categories with fluid counts: " .. num_rcats .. " (" .. num_vanilla .. " from the recipes' own counts)")

    lu.rcats = rcats
    lu.vanilla_to_rcats = vanilla_to_rcats
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