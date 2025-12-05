local categories = require("helper-tables/categories")
local randnum = require("lib/random/randnum")
local randprob = require("lib/random/randprob")
local locale_utils = require("lib/locale")
local rng = require("lib/random/rng")

local randomize = randnum.rand

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
randomizations.recipe_crafting_times = function(id)
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.energy_required == nil then
            recipe.energy_required = 0.5
        end
        randomize({
            id = id,
            prototype = recipe,
            property = "energy_required",
            rounding = "discrete_float",
            abs_min = 0.01,
            dir = -1
        })
    end
end

-- New
randomizations.recipe_ingredients_numerical = function(id)
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.category ~= nil and recipe.category == "recycling" then
            -- We don't wanna mess with these, lest we trivialize the means of production too much
        elseif recipe.ingredients ~= nil then
            local key = rng.key({ id = id, property = recipe })
            for _, ing in pairs(recipe.ingredients) do
                local old_amount = ing.amount
                local ignored_by_stats = 0
                if ing.ignored_by_stats ~= nil and ing.ignored_by_stats <= old_amount then
                    ignored_by_stats = ing.ignored_by_stats
                end
                local old_production = old_amount - ignored_by_stats
                if old_production > 0 then
                    local new_production = randomize({
                        key = key,
                        dummy = old_production,
                        abs_min = 1,
                        range = "small",
                        variance = "small",
                        dir = -1,
                        rounding = "discrete"
                    })
                    ing.amount = new_production + ignored_by_stats
                end
            end
        end
    end
end

randomizations.recipe_maximum_productivity = function(id)
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.maximum_productivity == nil then
            recipe.maximum_productivity = 3
        end
        if recipe.maximum_productivity > 0 then
            randomize({
                id = id,
                prototype = recipe,
                property = "maximum_productivity",
                rounding = "discrete_float",
                variance = "big",
            })
        end
    end
end

-- New
randomizations.recipe_result_percent_spoiled = function(id)
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.category ~= "recycling" and recipe.results ~= nil then
            for _, product in pairs(recipe.results) do
                if product.percent_spoiled ~= nil then
                    randprob.rand({
                        id = id,
                        prototype = recipe,
                        tbl = product,
                        property = "percent_spoiled",
                        rounding = "discrete_float",
                        variance = "big",
                        dir = -1,
                    })
                end
            end
        end
    end
end

-- New
randomizations.recipe_result_probabilities = function(id)
    for _, recipe in pairs(data.raw.recipe) do
        for _, product in pairs(recipe.results or {}) do
            if product.probability ~= nil then
                randprob.rand({
                    id = id,
                    prototype = recipe,
                    tbl = product,
                    property = "probability",
                    rounding = "discrete_float",
                    dir = 1
                })
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
            local key = rng.key({ id = id, property = recipe })
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
                            key = key,
                            dummy = old_production,
                            abs_min = 1,
                            range = "small",
                            variance = "small",
                            dir = 1,
                            rounding = "discrete"
                        })
                        result.amount = new_production + ignored_by_stats
                    end
                end
            end
        end
    end
end