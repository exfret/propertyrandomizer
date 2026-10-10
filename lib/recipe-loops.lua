-- Positive loops of size one (user, 2026-10-10): a recipe making more of an item than it takes of it keeps itself going once started, like pentapod eggs (one egg in, two out)
-- So the item it gains needn't be automatable for the recipe to run automatically: lib/logic/concrete.lua gives that ingredient's edge automatability (and marks it self_loop, see promotion.lua's owner_pre)
-- Telling positive loops through several recipes from negative ones would take a linear program (simplex), so only loops through one recipe count
-- Expected amounts decide (probabilities and extra counts included, cutils.find_amount_in_entry); only items, since a fluid result and ingredient can differ in temperature
-- Plain Lua, so lib/test-recipe-loops.lua can test it outside the game

local cutils = require("lib/cost/cost-utils")

local recipe_loops = {}

-- The items recipe makes more of than it takes, as item name --> true
recipe_loops.gained_items = function(recipe)
    local taken = {}
    for _, ing in pairs(recipe.ingredients or {}) do
        if ing.type == "item" then
            taken[ing.name] = (taken[ing.name] or 0) + cutils.find_amount_in_entry(ing)
        end
    end
    local made = {}
    for _, result in pairs(recipe.results or {}) do
        if result.type == "item" and taken[result.name] ~= nil then
            made[result.name] = (made[result.name] or 0) + cutils.find_amount_in_entry(result)
        end
    end
    local gained = {}
    for item_name, amount in pairs(made) do
        if amount > taken[item_name] then
            gained[item_name] = true
        end
    end
    return gained
end

-- Catalysts: the items some visible recipe both takes and makes, like pentapod eggs in their own recipe, as item name --> true
-- Hidden recipes (the recycler's, which give some items back) don't count
recipe_loops.catalyst_items = function(recipes)
    local catalysts = {}
    for _, recipe in pairs(recipes) do
        if recipe.hidden ~= true then
            local taken = {}
            for _, ing in pairs(recipe.ingredients or {}) do
                if ing.type == "item" then
                    taken[ing.name] = true
                end
            end
            for _, result in pairs(recipe.results or {}) do
                if result.type == "item" and taken[result.name] ~= nil then
                    catalysts[result.name] = true
                end
            end
        end
    end
    return catalysts
end

-- Whether item randomization may put an identity (an item prototype, or nil for anything else) at a position named position_name
-- A catalyst's position needs a stackable identity (user, 2026-10-10): lib/recipe-item-amounts.lua caps a non-stackable item's amounts at one, which would turn a positive loop like one egg in, two out into one in, one out, losing the automatability the loop gives
-- is_stackable(item prototype) is dutils.is_stackable in the game
recipe_loops.identity_fits = function(position_name, identity, catalysts, is_stackable)
    if catalysts[position_name] == nil or identity == nil then
        return true
    end
    return is_stackable(identity)
end

return recipe_loops
