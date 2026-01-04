-- Stage 4: Derived calculations (depends on stage 3)
-- Currently just the weight calculation, which is complex enough to warrant its own file

local stage0 = require("new-lib/logic/lookup/stage0")
local pairs = stage0.pairs
local table_insert = stage0.table_insert
local table_sort = stage0.table_sort
local math_floor = stage0.math_floor

local stage4 = {}

-- Calculates item weights using Factorio's algorithm
-- Reference: https://lua-api.factorio.com/2.0.72/auxiliary/item-weight.html
stage4.weight = function(lu, req)
    local weight = {}
    local gutils = req.gutils
    local flow_cost = req.flow_cost

    local default_weight = data.raw["utility-constants"].default.default_item_weight
    local rocket_lift_weight = data.raw["utility-constants"].default.rocket_lift_weight

    local item_to_first_recipe = {}

    -- Phase 1: Determine weights for items with explicit weights or special flags
    for _, item in pairs(lu.items) do
        if item.weight ~= nil then
            -- Manually set weight
            weight[item.name] = item.weight
        else
            -- Check for "only-in-cursor" and "spawnable" flags -> weight = 0
            if item.flags ~= nil then
                local give_zero_weight = false
                for _, flag in pairs(item.flags) do
                    if flag == "only-in-cursor" or flag == "spawnable" then
                        give_zero_weight = true
                        break
                    end
                end
                if give_zero_weight then
                    weight[item.name] = 0
                end
            end

            -- Find canonical recipe for items without explicit weight
            if weight[item.name] == nil then
                local related_recipes = lu.mat_recipe_map.material[gutils.key("item", item.name)]
                local valid_recipes = {}

                for recipe_name, _ in pairs(related_recipes.results) do
                    local recipe = data.raw.recipe[recipe_name]
                    -- Recipes that don't allow decomposition are not considered
                    if recipe.allow_decomposition or recipe.allow_decomposition == nil then
                        table_insert(valid_recipes, recipe)
                    end
                end

                if next(valid_recipes) == nil then
                    -- No valid recipe -> default weight
                    weight[item.name] = default_weight
                else
                    -- Sort recipes to find the canonical one
                    -- Define checker functions once (not per comparison)
                    local function check_name(recipe)
                        return recipe.name == item.name and 0 or 1
                    end

                    local function using_as_catalyst(recipe)
                        if (recipe.ignored_by_productivity ~= nil and recipe.ignored_by_productivity > 0) or
                           (recipe.ignored_by_productivity == nil and recipe.ignored_by_stats ~= nil and recipe.ignored_by_stats > 0) then
                            return 1
                        else
                            return 0
                        end
                    end

                    local function usable_in_handcrafting(recipe)
                        if recipe.allow_as_intermediate or recipe.allow_as_intermediate == nil then
                            return 0
                        else
                            return 1
                        end
                    end

                    local function category_order(recipe)
                        local category = data.raw["recipe-category"][recipe.category or "crafting"]
                        return category.order or category.name
                    end

                    local function subgroup_order(recipe)
                        local subgroup = data.raw["item-subgroup"][lu.recipe_subgroup[recipe.name]]
                        return subgroup.order or subgroup.name
                    end

                    local function recipe_order(recipe)
                        return recipe.order or recipe.name
                    end

                    local checkers = {check_name, using_as_catalyst, usable_in_handcrafting,
                                      category_order, subgroup_order, recipe_order}

                    table_sort(valid_recipes, function(r1, r2)
                        for _, checker in pairs(checkers) do
                            local order1 = checker(r1)
                            local order2 = checker(r2)
                            if order1 < order2 then
                                return true
                            elseif order2 < order1 then
                                return false
                            end
                        end
                        return false
                    end)

                    item_to_first_recipe[item.name] = valid_recipes[1]
                end
            end
        end
    end

    -- Phase 2: Topological sort to compute weights in dependency order
    -- Items depend on their recipe ingredients

    local item_graph = {}
    local open = {}
    local in_open = {}
    local reqs_total = {}
    local reqs_satisfied = {}

    -- Initialize graph nodes for all items
    for item_name, _ in pairs(lu.items) do
        item_graph[item_name] = {
            pre = {},
            dep = {},
        }
        reqs_total[item_name] = 0
        reqs_satisfied[item_name] = 0
    end

    -- Add edges from recipe ingredients to recipe outputs
    for item_name, recipe in pairs(item_to_first_recipe) do
        -- Don't add prereqs if item already has weight (prevents double-adding to open)
        if weight[item_name] == nil then
            if recipe.ingredients ~= nil then
                for _, ing in pairs(recipe.ingredients) do
                    if ing.type == "item" then
                        item_graph[item_name].pre[ing.name] = true
                        reqs_total[item_name] = reqs_total[item_name] + 1
                    end
                end
            end
        end

        -- Add items with no prereqs to open list
        if reqs_total[item_name] == 0 then
            table_insert(open, item_name)
            in_open[item_name] = true
        end
    end

    -- Add items with pre-assigned weights (they're sources in the graph)
    for _, item in pairs(lu.items) do
        if item_to_first_recipe[item.name] == nil and weight[item.name] ~= nil then
            table_insert(open, item.name)
            in_open[item.name] = true
        end
    end

    -- Build dependent edges (reverse of prereq edges)
    for item_name, node in pairs(item_graph) do
        for pre, _ in pairs(node.pre) do
            item_graph[pre].dep[item_name] = true
        end
    end

    -- Process items in topological order
    local ind = 1
    while ind <= #open do
        local curr_item = open[ind]
        local curr_item_prot = lu.items[curr_item]
        local curr_weight = weight[curr_item]

        -- Calculate weight if not already assigned
        if curr_weight == nil then
            local curr_recipe = item_to_first_recipe[curr_item]

            -- Calculate recipe weight from ingredients
            local recipe_weight = 0
            if curr_recipe.ingredients ~= nil then
                for _, ing in pairs(curr_recipe.ingredients) do
                    if ing.type == "item" then
                        -- Item ingredient: weight * count
                        recipe_weight = recipe_weight + weight[ing.name] * ing.amount
                    else
                        -- Fluid ingredient: amount * 100
                        recipe_weight = recipe_weight + ing.amount * 100
                    end
                end
            end

            if recipe_weight == 0 then
                -- Zero recipe weight -> default
                weight[curr_item] = default_weight
            else
                -- Calculate product count (expected output for item products)
                local product_count = 0
                if curr_recipe.results ~= nil then
                    for _, result in pairs(curr_recipe.results) do
                        if result.type == "item" then
                            product_count = product_count + flow_cost.find_amount_in_entry(result)
                        end
                    end
                end

                if product_count == 0 then
                    -- Zero products -> default
                    weight[curr_item] = default_weight
                else
                    -- Calculate intermediate result
                    local coefficient = curr_item_prot.ingredient_to_weight_coefficient or 0.5
                    local intermediate_result = (recipe_weight / product_count) * coefficient

                    if not curr_recipe.allow_productivity then
                        -- Non-productivity recipes: check simple result
                        local simple_result = rocket_lift_weight / curr_item_prot.stack_size
                        if simple_result >= intermediate_result then
                            weight[curr_item] = simple_result
                        end
                    end

                    if weight[curr_item] == nil then
                        -- Calculate stack amount and final weight
                        local stack_amount = rocket_lift_weight / intermediate_result / curr_item_prot.stack_size

                        if stack_amount <= 1 then
                            weight[curr_item] = intermediate_result
                        else
                            weight[curr_item] = rocket_lift_weight / math_floor(stack_amount) / curr_item_prot.stack_size
                        end
                    end
                end
            end
        end

        -- Add dependents to open list when all their prereqs are satisfied
        for dep, _ in pairs(item_graph[curr_item].dep) do
            reqs_satisfied[dep] = reqs_satisfied[dep] + 1
            if reqs_satisfied[dep] == reqs_total[dep] then
                if not in_open[dep] then
                    table_insert(open, dep)
                    in_open[dep] = true
                end
            end
        end

        ind = ind + 1
    end

    -- Phase 3: Assign default weight to any remaining items (caught in cycles)
    for item_name, _ in pairs(lu.items) do
        if weight[item_name] == nil then
            weight[item_name] = default_weight
        end
    end

    lu.weight = weight
end

return stage4
