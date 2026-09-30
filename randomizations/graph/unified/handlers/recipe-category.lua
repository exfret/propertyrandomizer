-- No overlapping ingredients for furnace categories
-- Account for limited fluidboxes
-- CRITICAL TODO: Later, also account for costs maybe
-- CRITICAL TODO: Figure out things that should stick to crafting category, if any (ask discord maybe)
-- Recipes a machine has as its fixed recipe (like rocket parts) are never claimed, so they keep their category

-- Furnaces don't get many recipes; I tried fixing but was unsuccessful
-- NOTE: Furnaces fixed! I did it! I'm so great!
-- TODO: Maybe weird context things are happening based on when something is available on another planet...

local gutils = require("lib/graph/graph-utils")
local lutils = require("lib/logic/logic-utils")
local lu = require("lib/lookup/init")
local furnace_selection = require("lib/furnace-selection")

local recipe_category = {}

recipe_category.id = "recipe_category"

recipe_category.with_replacement = true

-- Half the time a recipe tries its old category first, so categories are less chaotic; bases that pay a planetary debt still come before it (see the prereq shuffle in execute.lua)
-- The old category still has to pass validate, so a recipe it no longer fits picks at random like the rest
recipe_category.stay_chance = 0.5

-- Furnaces pick their recipe by ingredient, so recipes one furnace can craft mustn't share one (see lib/furnace-selection.lua)
-- taken[pool index][ingredient key] marks ingredients of recipes that pool's furnaces craft; recipe-ingredients then checks again with the final ingredients
local pools
local taken
-- Recipes whose category this handler randomizes; the rest stay where they are
local claimed_recipes
-- Keep track of whether we've claimed a category so we only give it a bonus the first time
local claimed_category
-- Category node name --> its crafting categories as one sorted string (see stays)
local cats_keys
recipe_category.initialize = function()
    pools = furnace_selection.pools()
    taken = nil
    claimed_recipes = {}
    claimed_category = {}
    cats_keys = {}
end

-- Recipes that keep their category keep their ingredients in its furnaces; only known once claiming is done, so this runs on first use
local function get_taken()
    if taken == nil then
        taken = {}
        for pool_ind, _ in pairs(pools) do
            taken[pool_ind] = {}
        end
        for recipe_name, recipe in pairs(lu.recipes) do
            if claimed_recipes[recipe_name] == nil then
                for _, pool_ind in pairs(furnace_selection.pools_for(pools, furnace_selection.recipe_categories(recipe))) do
                    for _, ing in pairs(recipe.ingredients or {}) do
                        taken[pool_ind][gutils.key(ing)] = true
                    end
                end
            end
        end
    end
    return taken
end

-- Recycling is a distinguished category: recycling recipes keep it, and no other recipe gets it
-- Its machine (the recycler) picks recipes by ingredient, so a recipe moved there would collide with the recycling recipe for that ingredient
local function has_recycling(rcat_name)
    for _, cat in pairs(lu.rcats[rcat_name].cats) do
        if cat == "recycling" then
            return true
        end
    end
    return false
end

recipe_category.claim = function(graph, prereq, dep, edge)
    -- Just don't claim fixed recipes, or hidden recipes

    if prereq.type == "recipe-category" and dep.type == "recipe" then
        -- A recycling recipe's only category edge is from a recycling category, so this keeps both directions out
        if has_recycling(prereq.name) then
            return false
        end
        if not (lu.fixed_recipes[dep.name] ~= nil and next(lu.fixed_recipes[dep.name]) ~= nil) then
            local recipe_prot = lu.recipes[dep.name]
            if not recipe_prot.hidden then
                claimed_recipes[dep.name] = true
                if claimed_category[prereq.name] then
                    return 0
                else
                    claimed_category[prereq.name] = true
                    return 1
                end
            end
        end
    end
end

recipe_category.validate = function(graph, base, head, extra)
    local base_owner = gutils.get_owner(graph, base)

    -- We already know via virtue of being in this handler that head is a recipe node
    if base_owner.type == "recipe-category" then
        local head_owner = gutils.get_owner(graph, head)
        -- If this is a spoof, always accept
        if head_owner.spoof then
            return true
        end

        local base_rcat = lu.rcats[base_owner.name]
        local vanilla_rcats = base_rcat.cats
        local recipe_prot = lu.recipes[head_owner.name]

        -- First, if a furnace crafts this rcat, make sure the recipe has exactly one ingredient and output
        -- This is technically incorrect, but I don't keep track of input/output bases of furnaces in logic now, so I'll leave that as a later problem
        -- TODO: Fix this problem later
        local base_pools = furnace_selection.pools_for(pools, vanilla_rcats)
        if #base_pools > 0 then
            if recipe_prot.ingredients == nil or #recipe_prot.ingredients ~= 1 or recipe_prot.results == nil or #recipe_prot.results ~= 1 then
                return false
            end

            -- Also check that this one ingredient isn't used by another recipe these furnaces craft
            local unique_ing = recipe_prot.ingredients[1]
            for _, pool_ind in pairs(base_pools) do
                if get_taken()[pool_ind][gutils.key(unique_ing)] then
                    return false
                end
            end
        end

        -- Check if there are the appropriate fluid connections
        -- We don't need to check equality exactly because we have a lot of duplicates
        -- With items and fluids trading positions, the recipe's counts include what first pass changed on its node (fluid_delta, see item_fluid.rewire_form_change)
        local recipe_fluids = lutils.find_recipe_fluids(recipe_prot)
        local delta = head_owner.fluid_delta or {}
        if recipe_fluids.input + (delta.input or 0) > base_rcat.input or recipe_fluids.output + (delta.output or 0) > base_rcat.output then
            return false
        end

        -- And I think that's all the check we'll do for now
        return true
    else
        return false
    end
end

recipe_category.process = function(graph, base, head)
    local head_owner = gutils.get_owner(graph, head)
    -- If this is a spoof, do nothing
    if head_owner.spoof then
        return
    end

    local base_owner = gutils.get_owner(graph, base)

    local base_pools = furnace_selection.pools_for(pools, lu.rcats[base_owner.name].cats)
    if #base_pools > 0 then
        local recipe_prot = lu.recipes[head_owner.name]
        local unique_ing = recipe_prot.ingredients[1]

        for _, pool_ind in pairs(base_pools) do
            get_taken()[pool_ind][gutils.key(unique_ing)] = true
        end
    end
end

-- Category nodes are split by fluid counts (lu.rcats), so a recipe stays in its category with any node of the same crafting categories
local function cats_key(rcat_name)
    if cats_keys[rcat_name] == nil and lu.rcats[rcat_name] ~= nil then
        local cats = table.deepcopy(lu.rcats[rcat_name].cats)
        table.sort(cats)
        cats_keys[rcat_name] = table.concat(cats, ",")
    end
    return cats_keys[rcat_name]
end

recipe_category.stays = function(graph, base, head)
    if head.old_base == nil then
        return false
    end
    local base_owner = gutils.get_owner(graph, base)
    local old_owner = gutils.get_owner(graph, graph.nodes[head.old_base])
    if base_owner.type ~= "recipe-category" or old_owner.type ~= "recipe-category" then
        return false
    end
    local old_cats = cats_key(old_owner.name)
    return old_cats ~= nil and cats_key(base_owner.name) == old_cats
end

recipe_category.reflect = function(graph, head_to_base, head_to_handler)
    for head_key, base_key in pairs(head_to_base) do
        if head_to_handler[head_key].id == "recipe_category" then
            local head = graph.nodes[head_key]
            local recipe_node = gutils.get_owner(graph, head)
            -- Check for spoof nodes
            if not recipe_node.spoof then
                local base = graph.nodes[base_key]
                local cat_node = gutils.get_owner(graph, base)
                local rcat = lu.rcats[cat_node.name]
                local recipe_prot = lu.recipes[recipe_node.name]
                recipe_prot.categories = rcat.cats
            end
        end
    end
end

return recipe_category