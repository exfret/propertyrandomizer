local rng = require("lib/random/rng")

-- Recipe groups and subgroups shuffle (separate functions)

-- New
randomizations.recipe_order = function(id)
    local recipe_list = {}
    local order_list = {}

    for _, recipe in pairs(data.raw.recipe) do
        local order = ""
        if recipe.order ~= nil then
            order = recipe.order
        end

        table.insert(recipe_list, recipe)
        table.insert(order_list, order)
    end

    local key = rng.key({id = id})
    rng.shuffle(key, order_list)

    for ind, recipe in pairs(recipe_list) do
        recipe.order = order_list[ind]
    end
end

-- New
randomizations.recipe_subgroup = function(id)
    local function find_recipe_main_item(recipe)
        -- Find the item
        local item_name
        if #recipe.results == 1 then
            item_name = recipe.results[1].name
        else
            item_name = recipe.main_product
        end
        for item_class, _ in pairs(defines.prototypes.item) do
            if data.raw[item_class] ~= nil and data.raw[item_class][item_name] ~= nil then
                return data.raw[item_class][item_name]
            end
        end
    end

    local recipe_list = {}
    local subgroup_list = {}

    for _, recipe in pairs(data.raw.recipe) do
        -- Get the subgroup
        local subgroup = recipe.subgroup
        if subgroup == nil then
            local main_item = find_recipe_main_item(recipe)
            if main_item ~= nil then
                subgroup = main_item.subgroup
            end
        end
        if subgroup == nil then
            -- If we still haven't found a subgroup, just assign it to other
            subgroup = "other"
        end

        table.insert(recipe_list, recipe)
        table.insert(subgroup_list, subgroup)
    end

    local key = rng.key({id = id})
    rng.shuffle(key, subgroup_list)

    for ind, recipe in pairs(recipe_list) do
        recipe.subgroup = subgroup_list[ind]
    end
end

-- NEW
randomizations.subgroup_group = function(id)
    local subgroups = {}
    local groups = {}

    for _, item_subgroup in pairs(data.raw["item-subgroup"]) do
        table.insert(subgroups, item_subgroup)
        table.insert(groups, item_subgroup.group)
    end

    rng.shuffle(rng.shuffle({id = id}), groups)

    for ind, subgroup in pairs(subgroups) do
        subgroup.group = groups[ind]
    end
end