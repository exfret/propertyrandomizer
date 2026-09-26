-- Which recipe each vanilla recycling recipe inverts, shared by promotion (derived recycling edges) and lib/recycling.lua (regenerating recycling recipes), so the model and the final game agree
-- Vanilla (recycler/recycling.lua) names a recycling recipe after the recycled item X, and fills it from the ingredients of a recipe whose single item result is X
-- That recipe can redirect with recycle_to_ingredients_of (e.g. hazard concrete returns concrete's ingredients)
-- Self-recycling (X returns only X) inverts nothing, so it isn't listed
-- The mapping must come from vanilla recipes, never from randomized properties like categories or names

local recycling = require("lib/recycling")

local sources = {}

local function is_recycling(recipe)
    for _, cat in pairs(recipe.categories or { recipe.category or "crafting" }) do
        if cat == "recycling" then
            return true
        end
    end
    return false
end

-- Vanilla names and draws a recycling recipe after its single ingredient, the item being recycled, not after a product
-- Returns the name of that ingredient in vanilla, or nil if recipe_name isn't a vanilla recycling recipe
sources.named_after_ingredient = function(vanilla_recipes, recipe_name)
    local recipe = vanilla_recipes[recipe_name]
    if recipe == nil or not is_recycling(recipe) or recipe.ingredients == nil or #recipe.ingredients ~= 1 then
        return nil
    end
    return recipe.ingredients[1].name
end

-- Returns recycling recipe name --> name of the recipe whose current item ingredients it returns (after recycle_to_ingredients_of), for every recycling recipe the recycler generated in vanilla_raw
-- regenerate (lib/recycling.lua) keeps these sources while they still make the item, which is what the logic model assumes
local cache = {}

sources.get = function(vanilla_raw)
    if cache.raw ~= vanilla_raw then
        cache = {
            raw = vanilla_raw,
            result = {},
        }
        for recycling_name, entry in pairs(recycling.vanilla(vanilla_raw)) do
            cache.result[recycling_name] = entry.reversed
        end
    end
    return cache.result
end

return sources
