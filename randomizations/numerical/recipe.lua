local categories = require("helper-tables/categories")
local randnum = require("lib/random/randnum")
local locale_utils = require("lib/locale")

local randomize = randnum.rand

-- New
randomizations.recipe_ingredients_numerical = function(id)
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.category ~= nil and recipe.category == "recycling" then
            -- We don't wanna mess with these, lest we trivialize the means of production too much
        elseif recipe.ingredients ~= nil then
            for _, ing in pairs(recipe.ingredients) do
                local old_amount = ing.amount
                local ignored_by_stats = 0
                if ing.ignored_by_stats ~= nil and ing.ignored_by_stats <= old_amount then
                    ignored_by_stats = ing.ignored_by_stats
                end
                local old_production = old_amount - ignored_by_stats
                if old_production > 0 then
                    local new_production = randomize({
                        id = id,
                        dummy = old_production,
                        abs_min = 1,
                        rounding = "discrete",
                        dir = -1
                    })
                    ing.amount = new_production + ignored_by_stats
                end
            end
        end
    end
end

local non_stackable_items = {}
for item_class, _ in pairs(defines.prototypes.item) do
    if data.raw[item_class] ~= nil then
        for _, item in pairs(data.raw[item_class]) do
            if item.stack_size <= 1 then
                non_stackable_items[item.name] = true
            end
        end
    end
end

-- New
randomizations.recipe_results_numerical = function(id)
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.category ~= nil and recipe.category == "recycling" then
            -- RECYCLING??
        elseif recipe.results ~= nil then
            for _, result in pairs(recipe.results) do
                if non_stackable_items[result.name] == nil then
                    local old_amount = result.amount
                    local ignored_by_stats = 0
                    if result.ignored_by_stats ~= nil and result.ignored_by_stats <= old_amount then
                        ignored_by_stats = result.ignored_by_stats
                    end
                    local old_production = old_amount - ignored_by_stats
                    if old_production > 0 then
                        local new_production = randomize({
                            id = id,
                            dummy = old_production,
                            abs_min = 1,
                            rounding = "discrete",
                            dir = 1
                        })
                        result.amount = new_production + ignored_by_stats
                    end
                end
            end
        end
    end
end