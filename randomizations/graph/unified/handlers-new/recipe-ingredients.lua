-- No cost preservation for now, just enough to get it loading

local constants = require("helper-tables/constants")
local logic = require("new-lib/logic/init")
local gutils = require("new-lib/graph/graph-utils")
local lutils = require("new-lib/logic/logic-utils")
local dutils = require("new-lib/data-utils")
local lu = require("new-lib/lookup/init")
-- Used for getting trav name
local first_pass = require("randomizations/graph/unified/first-pass-new")
-- Later, I will want a refactored cost library
local flow_cost = require("lib/graph/flow-cost")
local cost_lib = require("randomizations/graph/recipe-cost")

local key = gutils.key

local recipe_ingredients = {}

recipe_ingredients.id = "recipe_ingredients"

recipe_ingredients.with_replacement = true

local recipe_to_new_ings
-- Include 10 copies first time, 3 copies each one after
local already_duped
-- Just used for determining things without a cost; more detailed cost analysis is done with separate vars in the custom prereq search
local init_aggregate_costs
local dependent_to_new_ings
local claimed_recipes
recipe_ingredients.initialize = function()
    recipe_to_new_ings = {}
    already_duped = {}
    claimed_recipes = {}

    init_aggregate_costs = flow_cost.determine_recipe_item_cost(randomization_info.options.cost.default_cost_table, constants.cost_params.time, constants.cost_params.complexity)
end

recipe_ingredients.claim = function(graph, prereq, dep, edge)
    if (prereq.type == "item" or prereq.type == "fluid") and dep.type == "recipe" then
        local recipe = data.raw.recipe[dep.name]
        if recipe.hidden then
            return false
        end
        if init_aggregate_costs.recipe_to_cost[dep.name] == nil then
            return false
        end
        -- Need to check this here due to doing custom prereq search
        if randomization_info.options.unified["recipe-ingredients"].blacklisted_pre[key(prereq)] then
            return false
        end
        if randomization_info.options.unified["recipe-ingredients"].blacklisted_dep[key(dep)] then
            return false
        end

        claimed_recipes[dep.name] = true
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
    if randomization_info.options.unified["recipe-ingredients"].blacklisted_pre[key(ing)] then
        return true
    end

    return false
end

-- TODO: Recipe rando should probably go based on all planets, not just first surface
-- This is motivated by preserving the isolated context in the future, which needs to be done on multiple planets
-- In particular, spoilage comes first on nauvis and otherwise might need to be manually assigned to Gleba

-- Attempt with usual cost analysis
recipe_ingredients.custom_prereq_search = function(params)
    local random_graph = params.random_graph
    local sorted_deps = params.sorted_deps
    local shuffled_prereqs = params.shuffled_prereqs
    local sort_for_pool = params.sort_for_pool
    local trav_to_slot = params.trav_to_slot

    -- Helper function to determine if a recipe is used in any other recipes
    -- I think we might not need this so commenting out for now
    local used_mats = {}
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
    end

    -- COPY-PASTED from randomizations/graph/recipe.lua
    -- Table sending recipe to its new ingredients
    -- This needs to be populated with empty arrays first so that costs can be constructed accurately
    -- dependent_to_new_ings now is declared at module level
    dependent_to_new_ings = {}
    -- This is needed for the staged old cost calculations
    local dependent_to_old_ings = {}
    for _, dep in pairs(sorted_deps) do
        local node = random_graph.nodes[dep]
        if node.type == "recipe" and claimed_recipes[node.name] then
            -- For old ings, we are considering the slot recipes
            local slot_node = random_graph.nodes[trav_to_slot[key(node.type, first_pass.make_trav_name(node.name))] ]
            local slot_recipe = data.raw.recipe[slot_node.name]
            assert(slot_recipe ~= nil)

            local recipe_name = node.name
            dependent_to_new_ings[recipe_name] = {"blacklisted"}
            dependent_to_old_ings[slot_recipe.name] = {"blacklisted"}
        end
    end
    -- Add sensitive recipes back to dependent_to_new_ings
    for node_key, _ in pairs(randomization_info.options.unified["recipe-ingredients"].blacklisted_dep) do
        if random_graph.nodes[node_key] ~= nil then
            local recipe_name = random_graph.nodes[node_key].name
            assert(recipe_name ~= "")
            local recipe = data.raw.recipe[recipe_name]
            dependent_to_new_ings[recipe_name] = {}

            -- For old ings, we are considering the slot recipes
            local slot_node = random_graph.nodes[trav_to_slot[key("recipe", first_pass.make_trav_name(recipe_name))] or node_key]
            local slot_recipe = data.raw.recipe[slot_node.name]
            assert(slot_recipe ~= nil)
            dependent_to_old_ings[slot_recipe.name] = {}

            if recipe.ingredients ~= nil then
                for _, ing in pairs(recipe.ingredients) do
                    table.insert(dependent_to_new_ings[recipe_name], ing)
                    table.insert(dependent_to_old_ings[slot_recipe.name], ing)
                end
            end
        end
    end
    local major_raw_resources = randomization_info.options.cost.major_raw_resources
    local vanilla_aggregate_costs = flow_cost.determine_recipe_item_cost(randomization_info.options.cost.default_cost_table, constants.cost_params.time, constants.cost_params.complexity, {ing_overrides = dependent_to_old_ings})
    local vanilla_complexity_costs = flow_cost.determine_recipe_item_cost(flow_cost.get_empty_raw_resource_table(), 0, 1, {mode = "max", ing_overrides = dependent_to_old_ings})
    local vanilla_resource_costs = {}
    for _, resource_id in pairs(major_raw_resources) do
        vanilla_resource_costs[resource_id] = flow_cost.determine_recipe_item_cost(flow_cost.get_single_resource_table(resource_id), 0, 0, {ing_overrides = dependent_to_old_ings})
    end
    local randomized_aggregate_costs = flow_cost.determine_recipe_item_cost(randomization_info.options.cost.default_cost_table, constants.cost_params.time, constants.cost_params.complexity, {ing_overrides = dependent_to_new_ings})
    local randomized_complexity_costs = flow_cost.determine_recipe_item_cost(flow_cost.get_empty_raw_resource_table(), 0, 1, {mode = "max", ing_overrides = dependent_to_new_ings})
    local randomized_resource_costs = {}
    for _, resource_id in pairs(major_raw_resources) do
        randomized_resource_costs[resource_id] = flow_cost.determine_recipe_item_cost(flow_cost.get_single_resource_table(resource_id), 0, 0, {ing_overrides = dependent_to_new_ings})
    end
    local vanilla_item_recipe_maps = flow_cost.construct_item_recipe_maps()
    local randomized_item_recipe_maps = flow_cost.construct_item_recipe_maps()

    -- Used for making sure there aren't repeat ingredients for furnaces
    -- This logic is technically too strict now, since it doesn't allow ingredient repeats across all smelting categories
    -- However, countering this is difficult, since recipe categories can overlap in what machines have them
    -- TODO: Deal with this complexity
    local smelting_ingredients = {}
    for recipe_node_key, _ in pairs(randomization_info.options.unified["recipe-ingredients"].blacklisted_dep) do
        local recipe_node = random_graph.nodes[recipe_node_key]
        if recipe_node ~= nil then
            local recipe = data.raw.recipe[recipe_node.name]
            if lu.smelting_rcats[lutils.rcat_name(recipe)] and recipe.ingredients ~= nil then
                for _, ing in pairs(recipe.ingredients) do
                    smelting_ingredients[key(ing)] = true
                end
            end
        end
    end

    local ind_to_used = {}
    for _, dep in pairs(sorted_deps) do
        local node = random_graph.nodes[dep]
        if node.type == "recipe" and claimed_recipes[node.name] then
            log("Processing " .. node.name)
            local dependent_recipe = data.raw.recipe[node.name]
            assert(dependent_recipe ~= nil)
            -- Ignore the heads etc., just find good ings via search

            -- Old cost update
            -- Update costs for old recipe (transitioning to slot from trav)
            local slot_node = random_graph.nodes[trav_to_slot[key(node.type, first_pass.make_trav_name(node.name))] ]
            local slot_recipe = data.raw.recipe[slot_node.name]
            assert(slot_recipe ~= nil)
            log("Old context: " .. slot_node.name)

            dependent_to_old_ings[slot_recipe.name] = {}
            for _, ing in pairs(slot_recipe.ingredients) do
                table.insert(dependent_to_old_ings[slot_recipe.name], ing)
            end
            flow_cost.update_recipe_item_costs(vanilla_aggregate_costs, {slot_recipe.name}, 100, flow_cost.get_default_raw_resource_table(), constants.cost_params.time, constants.cost_params.complexity, {ing_overrides = dependent_to_old_ings, use_data = true, item_recipe_maps = vanilla_item_recipe_maps})
            vanilla_complexity_costs = flow_cost.determine_recipe_item_cost(flow_cost.get_empty_raw_resource_table(), 0, 1, {mode = "max", ing_overrides = dependent_to_old_ings, use_data = true, item_recipe_maps = vanilla_item_recipe_maps})
            for _, resource_id in pairs(major_raw_resources) do
                flow_cost.update_recipe_item_costs(vanilla_resource_costs[resource_id], {slot_recipe.name}, 100, flow_cost.get_single_resource_table(resource_id), 0, 0, {ing_overrides = dependent_to_old_ings, use_data = true, item_recipe_maps = vanilla_item_recipe_maps})
            end

            -- Gather information about this recipe
            -- TODO: Being "a smelting recipe" is up in the air; depends on recipe category randomization as well!
            -- Need to act based on how recipe category previously randomized
            local is_smelting_recipe = lu.smelting_rcats[lutils.rcat_name(dependent_recipe)]
            local is_result_of_this_recipe = {}
            if dependent_recipe.results ~= nil then
                for _, result in pairs(dependent_recipe.results) do
                    is_result_of_this_recipe[result.type .. "-" .. result.name] = true
                end
            end

            local function find_valid_prereq_list(shuffled_prereqs)
                -- Only include each prereq once
                local already_included = {}

                local valid_prereq_list = {}
                local valid_prereq_inds = {}
                for prereq_index, prereq in pairs(shuffled_prereqs) do
                    -- Make sure this prereq has currently calculable costs
                    local prereq_node = random_graph.nodes[prereq]
                    local prereq_owner = gutils.get_owner(random_graph, prereq_node)
                    local prereq_prot = dutils.get_prot(prereq_owner.type, prereq_owner.name)
                    local prereq_prot_id = flow_cost.get_prot_id(prereq_owner)
                    local has_costs = true
                    if randomized_aggregate_costs.material_to_cost[prereq_prot_id] == nil then
                        has_costs = false
                    end
                    for _, resource_id in pairs(major_raw_resources) do
                        if randomized_resource_costs[resource_id].material_to_cost[prereq_prot_id] == nil then
                            has_costs = false
                        end
                    end

                    local function do_recipe_checks()
                        -- Test for reachability at all contexts
                        local key1 = prereq
                        local key2 = dep
                        for context, _ in pairs(logic.contexts) do
                            local index1 = sort_for_pool.node_to_context_inds[key1][context]
                            local index2 = sort_for_pool.node_to_context_inds[key2][context]
                            -- TODO: Should I ignore nil contexts?
                            --[[if ignore_nil_contexts and (index1 == nil or index2 == nil) then
                                return true
                            end]]
                            index1 = index1 or (#sort_for_pool.sorted + 1)
                            index2 = index2 or (#sort_for_pool.sorted + 2)
                            if not (index1 < index2) then
                                return false
                            end
                        end

                        -- Test for prereqs already used for other dependents
                        if ind_to_used[prereq_index] then
                            return false
                        end

                        -- Make sure this ingredient isn't in the results of the recipe
                        if is_result_of_this_recipe[prereq_prot_id] then
                            return false
                        end

                        -- Make sure we don't have fuels as ingredients of smelting recipes
                        if is_smelting_recipe and prereq_prot.fuel_value ~= nil and util.parse_energy(prereq_prot.fuel_value) > 0 then
                            return false
                        end

                        -- Don't repeat ingredients in smelting recipes
                        if is_smelting_recipe and smelting_ingredients[prereq_owner.type .. "-" .. prereq_owner.name] then
                            return false
                        end

                        -- Make sure we can find a cost for it
                        if not has_costs then
                            return false
                        end

                        -- If the cost is too high, return false
                        if randomized_aggregate_costs.material_to_cost[prereq_prot_id] > vanilla_aggregate_costs.recipe_to_cost[slot_recipe.name] then
                            return false
                        end

                        -- Check if we already included this as a prereq for this recipe
                        if already_included[key(prereq_owner)] then
                            return false
                        end

                        -- Make sure the ingredient isn't too cheap
                        local largeness_okay_multiplier = 1
                        if prereq_owner.type == "fluid" then
                            largeness_okay_multiplier = 0.1
                        end
                        if randomized_aggregate_costs.material_to_cost[prereq_owner.type .. "-" .. prereq_owner.name] < largeness_okay_multiplier * 0.001 * vanilla_aggregate_costs.recipe_to_cost[slot_recipe.name] then
                            return false
                        end

                        return true
                    end

                    if do_recipe_checks() then
                        table.insert(valid_prereq_list, prereq)
                        table.insert(valid_prereq_inds, prereq_index)
                        already_included[key(prereq_owner)] = true
                    end
                end

                return {prereq_list = valid_prereq_list, prereq_inds = valid_prereq_inds}
            end

            -- Extract material_to_costs
            local vanilla_material_to_costs = {}
            vanilla_material_to_costs.aggregate_cost = vanilla_aggregate_costs.material_to_cost
            vanilla_material_to_costs.complexity_cost = vanilla_complexity_costs.material_to_cost
            vanilla_material_to_costs.resource_costs = {}
            for _, resource_id in pairs(major_raw_resources) do
                vanilla_material_to_costs.resource_costs[resource_id] = vanilla_resource_costs[resource_id].material_to_cost
            end
            local vanilla_recipe_costs = cost_lib.get_costs_from_ings(vanilla_material_to_costs, slot_recipe.ingredients)
            local randomized_material_costs = {}
            randomized_material_costs.aggregate_cost = randomized_aggregate_costs.material_to_cost
            randomized_material_costs.complexity_cost = randomized_complexity_costs.material_to_cost
            randomized_material_costs.resource_costs = {}
            for _, resource_id in pairs(major_raw_resources) do
                randomized_material_costs.resource_costs[resource_id] = randomized_resource_costs[resource_id].material_to_cost
            end

            local potential_ings = {}
            local valid_prereq_list_info = find_valid_prereq_list(shuffled_prereqs)
            for _, prereq in pairs(valid_prereq_list_info.prereq_list) do
                local prereq_node = random_graph.nodes[prereq]
                -- TODO: In the future, maybe some less painful way of getting the actual ings?
                -- Since ingredients can't be repeated, prereq.inds should only have one element
                local ind_of_ing
                for ind, _ in pairs(prereq_node.inds) do
                    if ind_of_ing == nil then
                        ind_of_ing = ind
                    else
                        error()
                    end
                end
                assert(ind_of_ing ~= nil)
                -- Now go to the vanilla recipe to fetch the ingredient
                local ing_recipe_node = gutils.get_owner(random_graph, random_graph.nodes[prereq_node.old_head])
                local ing_recipe = data.raw.recipe[ing_recipe_node.name]
                table.insert(potential_ings, ing_recipe.ingredients[ind_of_ing])
            end

            -- Find ingredients to not switch out, and put them last
            local unrandomized_ings = {}
            local reordered_ings_randomized = {}
            local reordered_ings_unrandomized = {}
            for _, ing in pairs(dependent_recipe.ingredients or {}) do
                if is_unrandomized_ing(ing, is_result_of_this_recipe) then
                    table.insert(unrandomized_ings, ing)
                    table.insert(reordered_ings_unrandomized, ing)
                else
                    table.insert(reordered_ings_randomized, ing)
                end
            end
            -- Find new fluid indices
            local is_fluid_index = {}
            for ing_ind, ing in pairs(reordered_ings_randomized) do
                if ing.type == "fluid" then
                    is_fluid_index[ing_ind] = true
                end
            end
            for ing_ind, ing in pairs(reordered_ings_unrandomized) do
                if ing.type == "fluid" then
                    is_fluid_index[#reordered_ings_randomized + ing_ind] = true
                end
            end

            -- TODO: Should I put in part about not preserving resource costs post-nauvis or for final products?
            -- I decided to leave that part out here

            -- Finally, search for the best ingredients
            local best_search_info = cost_lib.search_for_ings(table.deepcopy(potential_ings), #reordered_ings_randomized, vanilla_recipe_costs, randomized_material_costs, {unrandomized_ings = table.deepcopy(unrandomized_ings), is_fluid_index = is_fluid_index, dont_preserve_resource_costs = dont_preserve_resource_costs, nauvis_reachable = nauvis_reachable})
            
            -- Update dependencies
            for index_in_best_search_info, ing in pairs(best_search_info.ings) do
                -- In this case, this is an unrandomized ing
                if index_in_best_search_info > #reordered_ings_randomized then
                    table.insert(dependent_to_new_ings[dependent_recipe.name], ing)
                else
                    local prereq_ind_of_ing = valid_prereq_list_info.prereq_inds[best_search_info.inds[index_in_best_search_info]]
                    local prereq_of_ing = shuffled_prereqs[prereq_ind_of_ing]
                    local prereq_owner = gutils.get_owner(random_graph, random_graph.nodes[prereq_of_ing])

                    table.insert(dependent_to_new_ings[dependent_recipe.name], ing)
                    ind_to_used[prereq_ind_of_ing] = true
                    -- Add prereq to end of shuffled_prereqs (doing with replacement)
                    table.insert(shuffled_prereqs, prereq_of_ing)
                    if is_smelting_recipe then
                        smelting_ingredients[prereq_owner.type .. "-" .. prereq_owner.name] = true
                    end
                end
            end

            -- No need to update reachability
            -- Get rid of blacklisted property
            table.remove(dependent_to_new_ings[dependent_recipe.name], 1)
            -- TODO: Do better than this hotfix once I get a better cost library!
            local deepcopied_recipe = table.deepcopy(dependent_recipe)
            deepcopied_recipe.ingredients = dependent_to_new_ings[deepcopied_recipe.name]
            -- Update item recipe maps
            flow_cost.update_item_recipe_maps(randomized_item_recipe_maps, {deepcopied_recipe}, dependent_to_new_ings, true)

            -- Update costs
            -- I changed use_data to false, not sure why it was true
            flow_cost.update_recipe_item_costs(randomized_aggregate_costs, {dependent_recipe.name}, 100, flow_cost.get_default_raw_resource_table(), constants.cost_params.time, constants.cost_params.complexity, {ing_overrides = dependent_to_new_ings, use_data = false, item_recipe_maps = randomized_item_recipe_maps})
            -- Just re-determine the complexity costs, this isn't the slowest part anymore anyways
            -- I was having bugs with update_recipe_item_costs which is why I do it this way
            randomized_complexity_costs = flow_cost.determine_recipe_item_cost(flow_cost.get_empty_raw_resource_table(), 0, 1, {mode = "max", ing_overrides = dependent_to_new_ings, use_data = false, item_recipe_maps = randomized_item_recipe_maps})
            for _, resource_id in pairs(major_raw_resources) do
                flow_cost.update_recipe_item_costs(randomized_resource_costs[resource_id], {dependent_recipe.name}, 100, flow_cost.get_single_resource_table(resource_id), 0, 0, {ing_overrides = dependent_to_new_ings, use_data = false, item_recipe_maps = randomized_item_recipe_maps})
            end
        end
    end
end

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
    --[[local added_ings = {}

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
    end]]

    -- Add back unrandomized ings
    -- CRITICAL TODO: Do we actually need to do this? We might be able to accomplish ingredient restrictions by being careful in first pass
    --[[for recipe_name, inds in pairs(recipe_inds_to_remove) do
        local recipe = data.raw.recipe[recipe_name]
        local new_ings = {}
        for ind, ing in pairs(recipe.ingredients) do
            if not inds[ind] then
                table.insert(new_ings, ing)
            end
        end
        recipe.ingredients = new_ings
    end]]

    for recipe_name, ings in pairs(dependent_to_new_ings) do
        local recipe = data.raw.recipe[recipe_name]
        -- TODO: Maybe investigate whether the deepcopy is necessary
        recipe.ingredients = table.deepcopy(ings)
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