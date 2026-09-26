-- Which recipe each vanilla recycling recipe inverts, shared by promotion (derived recycling edges) and fixes.lua (regenerating recycling results), so the model and the final game agree
-- Vanilla (recycler/recycling.lua) names a recycling recipe after the recycled item X, and fills it from the ingredients of a recipe whose single item result is X
-- That recipe can redirect with recycle_to_ingredients_of (e.g. hazard concrete returns concrete's ingredients)
-- Self-recycling (X returns only X) inverts nothing, so it isn't listed
-- The mapping must come from vanilla recipes, never from randomized properties like categories or names

local sources = {}

local function is_recycling(recipe)
    for _, cat in pairs(recipe.categories or { recipe.category or "crafting" }) do
        if cat == "recycling" then
            return true
        end
    end
    return false
end

local function single_item_result(recipe)
    local name
    for _, res in pairs(recipe.results or {}) do
        if res.type == "item" then
            if name ~= nil then
                return nil
            end
            name = res.name
        end
    end
    return name
end

local cache

-- Returns recycling recipe name --> name of the recipe whose current item ingredients it should return
sources.get = function(vanilla_recipes)
    if cache ~= nil then
        return cache
    end
    cache = {}
    -- Recipes by their single item result, sorted by name so ties are deterministic
    local by_result = {}
    local names = {}
    for name, _ in pairs(vanilla_recipes) do
        table.insert(names, name)
    end
    table.sort(names)
    for _, name in pairs(names) do
        local recipe = vanilla_recipes[name]
        if not is_recycling(recipe) then
            local result = single_item_result(recipe)
            if result ~= nil then
                by_result[result] = by_result[result] or {}
                table.insert(by_result[result], name)
            end
        end
    end
    for _, name in pairs(names) do
        local recycling = vanilla_recipes[name]
        if is_recycling(recycling) and recycling.ingredients ~= nil and #recycling.ingredients == 1 then
            local x = recycling.ingredients[1].name
            local returned = {}
            local num_returned = 0
            for _, res in pairs(recycling.results or {}) do
                if res.name ~= x and returned[res.name] == nil then
                    returned[res.name] = true
                    num_returned = num_returned + 1
                end
            end
            if num_returned > 0 then
                for _, candidate_name in pairs(by_result[x] or {}) do
                    local candidate = vanilla_recipes[candidate_name]
                    local target_name = candidate.recycle_to_ingredients_of or candidate_name
                    local target = vanilla_recipes[target_name]
                    if target ~= nil then
                        local item_ings = {}
                        for _, ing in pairs(target.ingredients or {}) do
                            if ing.type == "item" then
                                item_ings[ing.name] = true
                            end
                        end
                        local matches = true
                        for returned_name, _ in pairs(returned) do
                            if item_ings[returned_name] == nil then
                                matches = false
                            end
                        end
                        if matches then
                            cache[name] = target_name
                            break
                        end
                    end
                end
            end
        end
    end
    return cache
end

return sources
