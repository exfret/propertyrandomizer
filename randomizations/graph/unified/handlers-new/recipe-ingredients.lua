-- No cost preservation for now, just enough to get it loading

local constants = require("helper-tables/constants")
local gutils = require("new-lib/graph/graph-utils")
local dutils = require("new-lib/data-utils")
-- Used for getting trav name
local first_pass = require("randomizations/graph/unified/first-pass-new")
-- Later, I will want a refactored cost library
local flow_cost = require("lib/graph/flow-cost")

local key = gutils.key

local recipe_ingredients = {}

recipe_ingredients.id = "recipe_ingredients"

recipe_ingredients.with_replacement = true

-- Don't randomize if the ing is in the results, or if it's already specified not to be randomized
-- TODO: Need to figure out how to signal not randomizing a specific ing, and how to do multiple ings at once in general
--[[local function is_unrandomized_ing(ing, is_result_of_this_recipe)
    -- If this is special in any way, don't randomize
    if is_result_of_this_recipe[ing.type .. "-" .. ing.name] then
        return true
    end
    if dont_randomize_ings[ing.type .. "-" .. ing.name] then
        return true
    end

    return false
end]]

local recipe_to_new_ings
-- Include 10 copies first time, 3 copies each one after
local already_duped
-- Just used for determining things without a cost; more detailed cost analysis is done with separate vars in the custom prereq search
local init_aggregate_costs
recipe_ingredients.initialize = function()
    recipe_to_new_ings = {}
    already_duped = {}

    init_aggregate_costs = flow_cost.determine_recipe_item_cost(randomization_info.options.cost.default_cost_table, constants.cost_params.time, constants.cost_params.complexity)
end

recipe_ingredients.claim = function(graph, prereq, dep, edge)
    if (prereq.type == "item" or prereq.type == "fluid") and dep.type == "recipe" then
        local recipe = data.raw.recipe[dep.name]
        if recipe.hidden then
            return false
        end
        if init_aggregate_costs.material_to_cost[flow_cost.get_prot_id(prereq)] == nil then
            return false
        end
        -- TODO: Other checks
        -- TODO: Better claim logic (not sure what that would entail yet)
        -- TODO: Things are delicate right now... I should really decrease this from 6 or at least add ways to encourage lesser-used intermediates
        if already_duped[key(prereq)] then
            return 2
        else
            already_duped[key(prereq)] = true
            return 50
        end
    end
end

local function is_unrandomized_ing(ing, is_result_of_this_recipe)
    -- If this is special in any way, don't randomize
    -- Right now, this just involves checking for ingredients also in the results
    if is_result_of_this_recipe[ing.type .. "-" .. ing.name] then
        return true
    end
    if dont_randomize_ings[ing.type .. "-" .. ing.name] then
        return true
    end

    return false
end

-- TODO: Recipe rando should probably go based on all planets, not just first surface
-- This is motivated by preserving the isolated context in the future, which needs to be done on multiple planets
-- In particular, spoilage comes first on nauvis and otherwise might need to be manually assigned to Gleba

-- Attempt with usual cost analysis
--recipe_ingredients.custom_prereq_search = function(params)
    -- Helper function to determine if a recipe is used in any other recipes
    -- I think we might not need this so commenting out for now
    --[[local used_mats = {}
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.ingredients ~= nil and recipe.category ~= "recycling" then
            for _, ing in pairs(recipe.ingredients) do
                used_mats[key(ing)] = true
            end
        end
    end

    local function produces_final_products(recipe)
        if recipe.results ~= nil then
            for _, result in pairs(recipe.results) do
                if used_mats[flow_cost.get_prot_id(result)] ~= nil then
                    return false
                end
            end

            return true
        end
    end]]


--end

-- Attempt with context switching
--[[recipe_ingredients.custom_prereq_search = function(params)
    local split_graph = params.split_graph
    local slot_to_trav = params.slot_to_trav
    local trav_to_slot = params.trav_to_slot
    local dep = params.dep

    local dep_as_slot = split_graph.nodes[dep]
    recipe_to_new_ings[dep_as_slot.name] = {}
    local dep_as_trav = split_graph.nodes[dep_as_slot.old_trav]
    local init_slot = split_graph.nodes[trav_to_slot[key(dep_as_trav)] ]
    for _, prenode in pairs(gutils.prenodes(split_graph, init_slot)) do
        local base = split_graph.nodes[prenode.old_base]
        local pre_slot = gutils.get_owner(split_graph, base)
        if pre_slot.type == "fluid" or pre_slot.type == "item" then
            local create_node = pre_slot
            if pre_slot.type == "fluid" then
                for _, prenode2 in pairs(gutils.prenodes(split_graph, pre_slot)) do
                    if prenode2.type == "fluid-create" then
                        create_node = prenode2
                        break
                    end
                end
                if create_node.type ~= "fluid-create" then
                    error("Could not find create node for fluid")
                end
            end
            local pre_orand
            for _, prenode2 in pairs(gutils.prenodes(split_graph, create_node)) do
                if prenode2.type == "orand" then
                    if prenode2.trav then
                        prenode2 = split_graph.nodes[prenode2.old_slot]
                    end
                    if split_graph.orand_to_child[key(prenode2)] == nil then
                        log(key(prenode2))
                        error("orand node without child.")
                    end
                    local craft_node = split_graph.nodes[split_graph.orand_to_child[key(prenode2)] ]
                    if craft_node.type == "item-craft" or craft_node.type == "fluid-craft" then
                        pre_orand = prenode2
                        break
                    end
                end
            end
            if pre_orand == nil then
                log(key(pre_slot))
            else
                if slot_to_trav[key(pre_orand)] ~= nil then
                    local final_node = split_graph.nodes[split_graph.nodes[slot_to_trav[key(pre_orand)] ].old_slot]
                    final_node = split_graph.nodes[split_graph.orand_to_parent[key(final_node)] ]
                    local amount = flow_cost.find_amount_in_ing_or_prod(data.raw.recipe[init_slot.name].ingredients, pre_slot)
                    table.insert(recipe_to_new_ings[dep_as_slot.name], {
                        type = pre_slot.type,
                        name = final_node.name,
                        amount = amount,
                    })
                    log(key(final_node))
                else
                    log(key(pre_orand))
                    log(key(pre_slot))
                end
            end
        end
    end
end]]

recipe_ingredients.validate = function(graph, base, head, extra)
    local base_owner = gutils.get_owner(graph, base)
    if base_owner.type ~= "fluid" and base_owner.type ~= "item" then
        return false
    end

    -- Only allow fluids in fluid bases and items in item bases for now
    local old_prereq = gutils.get_owner(graph, graph.nodes[head.old_base])
    if old_prereq.type ~= base_owner.type then
        return false
    end

    -- Otherwise, we're probably okay for now
    return true
end

recipe_ingredients.reflect = function(graph, head_to_base, head_to_handler)
    -- Now with the context switching recipe rando, we just set the ingredients
    --[[for _, recipe in pairs(data.raw.recipe) do
        if recipe_to_new_ings[recipe.name] ~= nil then
            recipe.ingredients = recipe_to_new_ings[recipe.name]
        end
    end]]

    -- Hotfix for now: don't add an ing if it's already been added
    local added_ings = {}

    local recipe_inds_to_remove = {}
    for head_key, base_key in pairs(head_to_base) do
        if head_to_handler[head_key].id == "recipe_ingredients" then
            local head = graph.nodes[head_key]
            local recipe_node = gutils.get_owner(graph, head)
            local recipe = data.raw.recipe[recipe_node.name]
            added_ings[recipe.name] = added_ings[recipe.name] or {}
            local base = graph.nodes[base_key]
            local ing = gutils.get_owner(graph, base)
            -- trav.inds holds recipe inds of old ingredient
            for ind, _ in pairs(head.inds) do
                if not added_ings[recipe.name][key(ing)] then
                    added_ings[recipe.name][key(ing)] = true
                    recipe.ingredients[ind].type = ing.type
                    recipe.ingredients[ind].name = ing.name
                else
                    recipe_inds_to_remove[recipe.name] = recipe_inds_to_remove[recipe.name] or {}
                    recipe_inds_to_remove[recipe.name][ind] = true
                end
            end
        end
    end

    -- Add back unrandomized ings
    -- CRITICAL TODO: Do we actually need to do this? We might be able to accomplish ingredient restrictions by being careful in first pass
    for recipe_name, inds in pairs(recipe_inds_to_remove) do
        local recipe = data.raw.recipe[recipe_name]
        local new_ings = {}
        for ind, ing in pairs(recipe.ingredients) do
            if not inds[ind] then
                table.insert(new_ings, ing)
            end
        end
        recipe.ingredients = new_ings
    end

    -- Final check to remove duplicate ingredients
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.ingredients ~= nil then
            local already_seen = {}
            for i = #recipe.ingredients, 1, -1 do
                local ing = recipe.ingredients[i]
                if already_seen[ing.type .. "-" .. ing.name] then
                    table.remove(recipe.ingredients, i)
                else
                    already_seen[ing.type .. "-" .. ing.name] = true
                end
            end
        end
    end
    -- Now go through and make ingredient amounts 1 if thing isn't stackable
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.ingredients ~= nil then
            for _, ing in pairs(recipe.ingredients) do
                if ing.type == "item" then
                    local item = dutils.get_prot("item", ing.name)
                    if not dutils.is_stackable(item) then
                        ing.amount = 1
                    end
                end
            end
        end
    end
end

return recipe_ingredients