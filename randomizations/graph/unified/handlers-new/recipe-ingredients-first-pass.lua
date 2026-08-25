-- TODO: Still having troubles with costs :(

local gutils = require("lib/graph/graph-utils")
local cutils = require("lib/cost/cost-utils")
local first_pass = require("randomizations/graph/unified/first-pass-new")
local sa_costs = require("lib/cost/material-costs/sa")

local recipe_ingredients_first_pass = {}

recipe_ingredients_first_pass.id = "recipe_ingredients_first_pass"

recipe_ingredients_first_pass.with_replacement = true

local slot_to_trav
local trav_to_slot
local split_graph
local material_to_cost
local recipe_to_cost
local orig_graph
recipe_ingredients_first_pass.initialize = function()
    slot_to_trav = nil
    trav_to_slot = nil
    split_graph = nil
    material_to_cost = sa_costs.costs
    orig_graph = nil

    recipe_to_cost = {}
    for _, recipe in pairs(data.raw.recipe) do
        -- Wait, we just need the recipe result cost for canonical
        if first_pass.is_canonical_result(recipe.name) then
            recipe_to_cost[recipe.name] = material_to_cost[gutils.key(recipe.results[1])]
        end
        --[[local cost = 0
        local in_ings = {}
        for _, ing in pairs(recipe.ingredients or {}) do
            in_ings[gutils.key(ing)] = ing
        end
        for ing_key, ing in pairs(in_ings) do
            local multiplier_per_ing = material_to_cost[gutils.key(ing)]
            if type(multiplier_per_ing) ~= "number" then
                multiplier_per_ing = math.huge
            end
            cost = cost + multiplier_per_ing * cutils.find_amount_in_ing_or_prod(recipe.ingredients or {}, ing)
        end
        recipe_to_cost[recipe.name] = cost]]
    end
end

recipe_ingredients_first_pass.claim = function(graph, prereq, dep, edge)
    -- The randomization is done by first pass
    return false
    --[[if (prereq.type == "item" or prereq.type == "fluid-temperature-range") and dep.type == "recipe" then
        local recipe = data.raw.recipe[dep.name]
        if recipe ~= nil then
            if recipe.results ~= nil and #recipe.results == 1 and recipe.results[1].name == recipe.name then
                return 1
            end
        end
    end]]
end

recipe_ingredients_first_pass.custom_prereq_search = function(params)
    slot_to_trav = params.slot_to_trav
    trav_to_slot = params.trav_to_slot
    split_graph = params.split_graph
end

recipe_ingredients_first_pass.validate = false

recipe_ingredients_first_pass.reflect = function(graph, head_to_base, head_to_handler)

    for trav_key, slot_key in pairs(trav_to_slot) do
        local slot = split_graph.nodes[slot_key]
        local trav = split_graph.nodes[trav_key]
        -- Remember to do string.sub for trav to get its "actual" name
        local actual_trav_name = string.sub(trav.name, 1, -6)
        if slot ~= nil and slot.type == "recipe" and first_pass.is_canonical_result(slot.name) and trav ~= nil and trav.type == "recipe" and first_pass.is_canonical_result(actual_trav_name) then
            local slot_recipe = data.raw.recipe[slot.name]
            local trav_recipe = data.raw.recipe[actual_trav_name]
            --[[if RECIPE_INGS_DIR == "BACKWARD" then
                slot_recipe, trav_recipe = trav_recipe, slot_recipe
            end]]
            if RECIPE_INGS_DIR == "BACKWARD" then
                local new_ings = slot_recipe.ingredients
                for _, ing in pairs(new_ings) do
                    if first_pass.is_canonical_result(ing.name) then
                        local ing_trav_key = slot_to_trav[gutils.key("recipe", ing.name)]
                        ing.name = graph.nodes[string.sub(ing_trav_key, 1, -6)].name
                    end
                end
                table.insert(changes, {
                    tbl = trav_recipe,
                    prop = "ingredients",
                    new_val = new_ings,
                })
            else
                local new_ingredients = trav_recipe.ingredients
                if recipe_to_cost[slot_recipe.name] > recipe_to_cost[trav_recipe.name] then
                    -- In this case, the ingredients are cheaper than normal; multiply then by some amount to preserve order
                    local multiplier = recipe_to_cost[slot_recipe.name] / recipe_to_cost[trav_recipe.name]
                    for _, ing in pairs(new_ingredients or {}) do
                        for amount_key in pairs({"amount", "amount_min", "amount_max"}) do
                            table.insert(changes, {
                                tbl = ing,
                                prop = amount_key,
                                multiplier = multiplier,
                                is_ing_or_result = true,
                                ingredients = true,
                                recipe = trav_recipe,
                            })
                        end
                    end
                else
                    -- In this case, the ingredients are more expensive; multiply results then
                    local multiplier = recipe_to_cost[trav_recipe.name] / recipe_to_cost[slot_recipe.name]
                    -- Recall there is only one result anyways
                    for _, amount_key in pairs({"amount", "amount_min", "amount_max"}) do
                        table.insert(changes, {
                            tbl = slot_recipe.results[1],
                            prop = amount_key,
                            multiplier = multiplier,
                            is_ing_or_result = true,
                            recipe = trav_recipe,
                        })
                    end
                end
                table.insert(changes, {
                    tbl = slot_recipe,
                    prop = "ingredients",
                    new_val = new_ingredients,
                })
                -- Take geometric mean of crafting times so that things don't get too out of hand
                slot_recipe.energy_required = math.sqrt((slot_recipe.energy_required or 0.5) * (trav_recipe.energy_required or 0.5))
                --[[for _, tech in pairs(data.raw.technology) do
                    for _, effect in pairs(tech.effects or {}) do
                        if effect.type == "unlock-recipe" then
                            if effect.recipe == trav_recipe.name then
                                table.insert(changes, {
                                    tbl = effect,
                                    prop = "recipe",
                                    new_val = slot_recipe.name,
                                })
                            end
                        end
                    end
                end]]
            end
        end
    end

    --[[for head_key, base_key in pairs(head_to_base) do
        if head_to_handler[head_key].id == "recipe_ingredients_first_pass" then
            local head = graph.nodes[head_key]
            local recipe_node = gutils.get_owner(graph, head)
            if not recipe_node.spoof then
                if first_pass.is_canonical_result(recipe_node.name) then
                    local base = graph.nodes[base_key]
                    local base_owner = gutils.get_owner(graph, base)
                    if first_pass.is_canonical_result(base_owner.name) then
                        local recipe =
                    end
                end
            end
        end
    end]]
end

return recipe_ingredients_first_pass