-- Furnace recipe selection: furnaces (the recycler too) pick their recipe from their input instead of having one set
-- Per the 2.1 auxiliary docs (doc-html/auxiliary/furnace-recipe-selection.html), a furnace picks the first recipe in inventory order that matches its fluid and item ingredients, then its item alone, then its fluid alone
-- So two recipes one furnace can craft that share an ingredient can't both be used there; the logic graph doesn't see this, so it's checked here

local furnace_selection = {}

-- A recipe's categories, with the engine's default (RecipePrototype.categories defaults to {"crafting"} in the 2.1 prototype docs)
furnace_selection.recipe_categories = function(recipe)
    return recipe.categories or { "crafting" }
end

-- Groups of crafting categories that one furnace crafts together, deduplicated, as a list of category --> true
-- raw (optional) is the prototype table to read furnaces from, data.raw by default
furnace_selection.pools = function(raw)
    raw = raw or data.raw
    local pools = {}
    local seen = {}
    for _, furnace in pairs(raw.furnace or {}) do
        local cats = {}
        for _, cat in pairs(furnace.crafting_categories or {}) do
            table.insert(cats, cat)
        end
        table.sort(cats)
        local pool_key = table.concat(cats, ",")
        if #cats > 0 and not seen[pool_key] then
            seen[pool_key] = true
            local pool = {}
            for _, cat in pairs(cats) do
                pool[cat] = true
            end
            table.insert(pools, pool)
        end
    end
    return pools
end

-- Indices into pools of the furnaces that can craft a recipe with these categories
furnace_selection.pools_for = function(pools, categories)
    local inds = {}
    for ind, pool in pairs(pools) do
        for _, cat in pairs(categories) do
            if pool[cat] then
                table.insert(inds, ind)
                break
            end
        end
    end
    return inds
end

-- Ingredients used per furnace pool, for recipe randomization: recipes one furnace crafts mustn't share an ingredient
-- Any shared ingredient counts, which is stricter than the selection rules but never lets a collision through
-- categories_of (optional): a recipe's categories where they'll end up (like after recipe-category randomization), else its own; raw (optional): as in pools
-- Returns a tracker with pools_of(recipe) (the pool indices whose furnaces craft it), take(recipe, material) (the recipe uses the material), reserve(recipe, material) and release(recipe) (holding a material for a recipe until it's placed), and is_taken(pool_inds, material, recipe) (used, or held for another recipe than recipe)
furnace_selection.tracker = function(categories_of, raw)
    local pools = furnace_selection.pools(raw)
    local taken = {}
    for pool_ind, _ in pairs(pools) do
        taken[pool_ind] = {}
    end
    local tracker = {}
    tracker.pools_of = function(recipe)
        local categories = categories_of ~= nil and categories_of(recipe) or nil
        return furnace_selection.pools_for(pools, categories or furnace_selection.recipe_categories(recipe))
    end
    -- Materials held for a recipe that isn't placed yet, per pool, as material key --> recipe name
    local reserved = {}
    for pool_ind, _ in pairs(pools) do
        reserved[pool_ind] = {}
    end
    tracker.take = function(recipe, material)
        for _, pool_ind in pairs(tracker.pools_of(recipe)) do
            taken[pool_ind][material.type .. "-" .. material.name] = true
        end
    end
    -- Holds a material for a recipe in its pools until release(recipe), so no other recipe its furnaces craft takes it first
    -- For what a recipe falls back to without asking the tracker, like its vanilla ingredients when nothing else fits; the first recipe to reserve a material keeps it
    tracker.reserve = function(recipe, material)
        for _, pool_ind in pairs(tracker.pools_of(recipe)) do
            local material_key = material.type .. "-" .. material.name
            if reserved[pool_ind][material_key] == nil then
                reserved[pool_ind][material_key] = recipe.name
            end
        end
    end
    tracker.release = function(recipe)
        for pool_ind, _ in pairs(pools) do
            for material_key, holder in pairs(reserved[pool_ind]) do
                if holder == recipe.name then
                    reserved[pool_ind][material_key] = nil
                end
            end
        end
    end
    -- Whether a material is used, or held for a recipe other than recipe (optional), in any of these pools
    tracker.is_taken = function(pool_inds, material, recipe)
        local material_key = material.type .. "-" .. material.name
        for _, pool_ind in pairs(pool_inds) do
            if taken[pool_ind][material_key] ~= nil then
                return true
            end
            local holder = reserved[pool_ind][material_key]
            if holder ~= nil and (recipe == nil or holder ~= recipe.name) then
                return true
            end
        end
        return false
    end
    return tracker
end

-- The ingredients a furnace selects a recipe by: its item, or its fluid when it has no item, as "type-name" keys
-- Recipes of other shapes can't run in a furnace at all, so they select nothing
furnace_selection.selecting_ingredients = function(ingredients)
    local items = {}
    local fluids = {}
    for _, ing in pairs(ingredients or {}) do
        if ing.type == "fluid" then
            table.insert(fluids, "fluid-" .. ing.name)
        else
            table.insert(items, "item-" .. ing.name)
        end
    end
    if #items > 1 or #fluids > 1 then
        return {}
    end
    if #items == 1 then
        return { items[1] }
    end
    return fluids
end

-- Recipes a furnace can't tell apart, as a list of {ingredient = "type-name", recipes = {names...}}, sorted for stable logs
-- categories_of (optional) gives a recipe's categories, for callers that know where categories will end up
-- raw (optional) is the prototype table to read furnaces from, data.raw by default
furnace_selection.collisions = function(recipes, categories_of, raw)
    categories_of = categories_of or furnace_selection.recipe_categories
    local pools = furnace_selection.pools(raw)
    local by_pool_ing = {}
    local names = {}
    for name, _ in pairs(recipes) do
        table.insert(names, name)
    end
    table.sort(names)
    for _, name in pairs(names) do
        local recipe = recipes[name]
        for _, pool_ind in pairs(furnace_selection.pools_for(pools, categories_of(recipe))) do
            for _, ing_key in pairs(furnace_selection.selecting_ingredients(recipe.ingredients)) do
                by_pool_ing[pool_ind] = by_pool_ing[pool_ind] or {}
                by_pool_ing[pool_ind][ing_key] = by_pool_ing[pool_ind][ing_key] or {}
                table.insert(by_pool_ing[pool_ind][ing_key], name)
            end
        end
    end
    local collisions = {}
    for pool_ind = 1, #pools do
        local ing_keys = {}
        for ing_key, _ in pairs(by_pool_ing[pool_ind] or {}) do
            table.insert(ing_keys, ing_key)
        end
        table.sort(ing_keys)
        for _, ing_key in pairs(ing_keys) do
            if #by_pool_ing[pool_ind][ing_key] > 1 then
                table.insert(collisions, {
                    ingredient = ing_key,
                    recipes = by_pool_ing[pool_ind][ing_key],
                })
            end
        end
    end
    return collisions
end

-- Collisions in data.raw that old_raw (the game before randomization) didn't have already, like one a mod's recycling makes
-- Recipes keep their names through randomization, so a collision is old if each pair of its recipes collided in old_raw too
furnace_selection.new_collisions = function(old_raw)
    local old_pairs = {}
    for _, collision in pairs(furnace_selection.collisions(old_raw.recipe, nil, old_raw)) do
        for _, a in pairs(collision.recipes) do
            for _, b in pairs(collision.recipes) do
                old_pairs[a .. "\n" .. b] = true
            end
        end
    end
    local new = {}
    for _, collision in pairs(furnace_selection.collisions(data.raw.recipe)) do
        local is_old = true
        for _, a in pairs(collision.recipes) do
            for _, b in pairs(collision.recipes) do
                if old_pairs[a .. "\n" .. b] == nil then
                    is_old = false
                end
            end
        end
        if not is_old then
            table.insert(new, collision)
        end
    end
    return new
end

return furnace_selection
