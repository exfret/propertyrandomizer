-- What the recipe-ingredients lists (randomization_info.options.unified["recipe-ingredients"], set in src/compat/vanilla.lua) mean, for both recipe randomizations: unified's (src/randomizations/unified/handlers/recipe-ingredients.lua) and the one outside it (src/legacy/randomizations/recipe.lua)
-- Materials, keyed like "item: iron-ore":
--   blacklisted_pre: never a new ingredient anywhere, since it inherently can't be one (like fusion plasma, which no crafting machine can take in); it keeps the spots it has
--   kept_pre: keeps every spot it has, but recipes may still take it as a new ingredient, offered as often as any ingredient taken by as many recipes (user, 2026-10-07: ores and whatever else mining or pumping gives, spoilage, Gleba's fruits, round-trip fluids)
-- Recipes, keyed like "recipe: iron-plate":
--   blacklisted_dep: keep their ingredients, and those don't count as uses (recycling and barrel recipes)
--   kept_dep: keep their ingredients, which still count as uses, so a material only they take (like ice or holmium ore) can still be a new ingredient elsewhere (user, 2026-10-07)

local gutils = require("src/lib/graph/graph-utils")

local key = gutils.key

local ingredient_blacklists = {}

-- The rules of one set of lists
ingredient_blacklists.of = function(lists)
    local blacklisted_pre = lists.blacklisted_pre or {}
    local kept_pre = lists.kept_pre or {}
    local blacklisted_dep = lists.blacklisted_dep or {}
    local kept_dep = lists.kept_dep or {}

    local rules = {}

    -- Whether the material stays in every recipe that takes it
    rules.keeps_spots = function(material)
        local material_key = key(material.type, material.name)
        return blacklisted_pre[material_key] == true or kept_pre[material_key] == true
    end

    -- Whether recipes may take the material as a new ingredient
    rules.may_add = function(material)
        return blacklisted_pre[key(material.type, material.name)] ~= true
    end

    -- Whether the recipe keeps its ingredients
    rules.keeps_ingredients = function(recipe_name)
        local recipe_key = key("recipe", recipe_name)
        return blacklisted_dep[recipe_key] == true or kept_dep[recipe_key] == true
    end

    -- Whether the recipe's ingredients count as uses of them, which decide how often each material is offered as a new ingredient
    rules.counts_uses = function(recipe_name)
        return blacklisted_dep[key("recipe", recipe_name)] ~= true
    end

    -- Whether the recipe taking the material is a use that stays as it is but still counts: the material keeps its spots or the recipe its ingredients, and the use counts
    -- A recipe randomization offers the material for each such use as if the use were randomized
    rules.kept_use = function(material, recipe_name)
        if not rules.may_add(material) or not rules.counts_uses(recipe_name) then
            return false
        end
        return kept_pre[key(material.type, material.name)] == true or kept_dep[key("recipe", recipe_name)] == true
    end

    -- The keys of the recipes that keep their ingredients, sorted
    rules.kept_recipe_keys = function()
        local recipe_keys = {}
        for recipe_key, value in pairs(blacklisted_dep) do
            if value == true then
                table.insert(recipe_keys, recipe_key)
            end
        end
        for recipe_key, value in pairs(kept_dep) do
            if value == true and blacklisted_dep[recipe_key] ~= true then
                table.insert(recipe_keys, recipe_key)
            end
        end
        table.sort(recipe_keys)
        return recipe_keys
    end

    return rules
end

return ingredient_blacklists
