-- No cost preservation for now, just enough to get it loading

local constants = require("helper-tables/constants")
local logic = require("lib/logic/init")
local gutils = require("lib/graph/graph-utils")
local lutils = require("lib/logic/logic-utils")
local dutils = require("lib/data-utils")
local lu = require("lib/lookup/init")
-- Used for getting trav name
local first_pass = require("randomizations/graph/unified/first-pass-new")
local cutils = require("lib/cost/cost-utils")
-- Later, I will want a refactored cost library
local flow_cost = require("lib/cost/flow-cost")
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

-- Fluid ingredients enter recipes through fluid-temperature-range nodes, so report those as the fluid itself
local function as_material(node)
    if node.type == "fluid-temperature-range" then
        return { type = "fluid", name = gutils.deconstruct(node.name).type }
    end
    return node
end

-- Like gutils.get_owner, but with fluid-temperature-range owners reported as their fluid
local function get_material_owner(graph, conn_node)
    return as_material(gutils.get_owner(graph, conn_node))
end

recipe_ingredients.claim = function(graph, prereq, dep, edge)
    if (prereq.type == "item" or prereq.type == "fluid" or prereq.type == "fluid-temperature-range") and dep.type == "recipe" then
        prereq = as_material(prereq)
        local recipe = data.raw.recipe[dep.name]
        if recipe.hidden then
            return false
        end
        if init_aggregate_costs.recipe_to_cost[dep.name] == nil then
            -- TODO: Support for recipes without a cost
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

-- Ingredients the current recipe must keep because promised recycling relies on them (see promotion.lua), as material key --> true
local current_pins = {}

local function is_unrandomized_ing(ind, is_result_of_this_recipe, recipe)
    -- If this is special in any way, don't randomize

    local ing = recipe.ingredients[ind]

    if current_pins[key(ing)] ~= nil then
        return true
    end

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
    local do_first_pass = params.do_first_pass

    local used_mats = {}
    for _, recipe in pairs(data.raw.recipe) do
        local has_recycling = false
        for _, category in pairs(recipe.categories or {"crafting"}) do
            if category == "recycling" then
                has_recycling = true
            end
        end
        if recipe.ingredients ~= nil and not has_recycling then
            for _, ing in pairs(recipe.ingredients) do
                used_mats[key(ing)] = true
            end
        end
    end

    -- Helper function to determine if a recipe is used in any other recipes
    -- I think we might not need this?
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
            local slot_node = (do_first_pass and random_graph.nodes[trav_to_slot[key(node.type, first_pass.make_trav_name(node.name))] ]) or node
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
            local slot_node = (do_first_pass and random_graph.nodes[trav_to_slot[key("recipe", first_pass.make_trav_name(recipe_name))] or node_key]) or random_graph.nodes[node_key]
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
    -- Also add back recipes that went unclaimed only because all their ingredients are blacklisted_pre (e.g. yumako-processing)
    -- Recipes missing from ing_overrides are treated as nonexistent by flow_cost, which would leave their products without costs
    for recipe_name, recipe in pairs(data.raw.recipe) do
        if dependent_to_new_ings[recipe_name] == nil and not recipe.hidden and init_aggregate_costs.recipe_to_cost[recipe_name] ~= nil then
            dependent_to_new_ings[recipe_name] = {}
            dependent_to_old_ings[recipe_name] = {}
            for _, ing in pairs(recipe.ingredients or {}) do
                table.insert(dependent_to_new_ings[recipe_name], ing)
                table.insert(dependent_to_old_ings[recipe_name], ing)
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
    -- Unstaged vanilla costs, for slot recipes whose ingredients the staged vanilla world hasn't reached yet (see below)
    local full_vanilla_costs
    local function get_full_vanilla_costs()
        if full_vanilla_costs == nil then
            full_vanilla_costs = {
                aggregate = flow_cost.determine_recipe_item_cost(randomization_info.options.cost.default_cost_table, constants.cost_params.time, constants.cost_params.complexity),
                complexity = flow_cost.determine_recipe_item_cost(flow_cost.get_empty_raw_resource_table(), 0, 1, {mode = "max"}),
                resources = {},
            }
            for _, resource_id in pairs(major_raw_resources) do
                full_vanilla_costs.resources[resource_id] = flow_cost.determine_recipe_item_cost(flow_cost.get_single_resource_table(resource_id), 0, 0)
            end
        end
        return full_vanilla_costs
    end
    -- Whether a staged world (vanilla or randomized) already has aggregate and resource costs for a material
    -- Both worlds are built up in this run's processing order, which needn't be the order their recipes' ingredients get made in
    local function is_costed(aggregate_costs, resource_costs, material)
        local material_id = flow_cost.get_prot_id(material)
        if aggregate_costs.material_to_cost[material_id] == nil then
            return false
        end
        for _, resource_id in pairs(major_raw_resources) do
            if resource_costs[resource_id].material_to_cost[material_id] == nil then
                return false
            end
        end
        return true
    end
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

    -- Shared promotion state from execute-new.lua (nil means use the old every-context ordering check)
    local prom = params.promotion
    local num_fallbacks = 0

    local num_processed = 0
    local total_valid_prereqs = 0
    local num_changed_ings = 0
    local num_ings = 0
    local ind_to_used = {}
    for _, dep in pairs(sorted_deps) do
        local node = random_graph.nodes[dep]
        if node.type == "recipe" and claimed_recipes[node.name] then
            log("Processing " .. node.name)
            current_pins = prom ~= nil and prom.pins_for(dep) or {}
            local required_contexts
            if prom ~= nil then
                required_contexts = prom.required_contexts(dep)
                if #required_contexts == 0 then
                    if prom.initially_reachable(dep) then
                        -- Every recipe must stay reachable, so this is a failure
                        log("Promotion: " .. dep .. " can no longer be reached in any context")
                        return false
                    end
                    log("Promotion: " .. dep .. " was already unreachable before recipe randomization")
                end
            end
            local dependent_recipe = data.raw.recipe[node.name]
            assert(dependent_recipe ~= nil)
            -- Ignore the heads etc., just find good ings via search

            -- Old cost update
            -- Update costs for old recipe (transitioning to slot from trav)
            local slot_node = (do_first_pass and random_graph.nodes[trav_to_slot[key(node.type, first_pass.make_trav_name(node.name))] ]) or node
            local slot_recipe = data.raw.recipe[slot_node.name]
            assert(slot_recipe ~= nil)
            log("Old context: " .. slot_node.name)

            -- If it's something without a cost, do whatever
            if init_aggregate_costs.recipe_to_cost[slot_recipe.name] == nil then
                
                -- TODO

            else
                -- The staged vanilla world only has costs for what the slot recipes processed so far make
                -- Processing follows this run's sort, not vanilla's, so a slot recipe can come before the recipes making its ingredients (e.g. on other planet starts)
                local slot_is_staged = true
                for _, ing in pairs(slot_recipe.ingredients) do
                    if not is_costed(vanilla_aggregate_costs, vanilla_resource_costs, ing) then
                        slot_is_staged = false
                    end
                end
                -- Either way, the slot recipe now counts in the staged vanilla world; if it's not reachable yet, cost updates pick it up once its ingredients are
                dependent_to_old_ings[slot_recipe.name] = {}
                for _, ing in pairs(slot_recipe.ingredients) do
                    table.insert(dependent_to_old_ings[slot_recipe.name], ing)
                end
                local slot_vanilla
                if slot_is_staged then
                    flow_cost.update_recipe_item_costs(vanilla_aggregate_costs, {slot_recipe.name}, 100, flow_cost.get_default_raw_resource_table(), constants.cost_params.time, constants.cost_params.complexity, {ing_overrides = dependent_to_old_ings, use_data = true, item_recipe_maps = vanilla_item_recipe_maps})
                    vanilla_complexity_costs = flow_cost.determine_recipe_item_cost(flow_cost.get_empty_raw_resource_table(), 0, 1, {mode = "max", ing_overrides = dependent_to_old_ings, use_data = true, item_recipe_maps = vanilla_item_recipe_maps})
                    for _, resource_id in pairs(major_raw_resources) do
                        flow_cost.update_recipe_item_costs(vanilla_resource_costs[resource_id], {slot_recipe.name}, 100, flow_cost.get_single_resource_table(resource_id), 0, 0, {ing_overrides = dependent_to_old_ings, use_data = true, item_recipe_maps = vanilla_item_recipe_maps})
                    end
                    slot_vanilla = {
                        aggregate = vanilla_aggregate_costs,
                        complexity = vanilla_complexity_costs,
                        resources = vanilla_resource_costs,
                    }
                else
                    log("Staged vanilla costs don't reach " .. slot_recipe.name .. " yet; comparing against full vanilla costs")
                    slot_vanilla = get_full_vanilla_costs()
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
                        local prereq_owner = get_material_owner(random_graph, prereq_node)
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
                            if prom ~= nil and #required_contexts > 0 then
                                -- Must be promotable in each context the recipe is required in
                                if not prom.candidate_ok(dep, key(gutils.get_owner(random_graph, prereq_node)), required_contexts) then
                                    return false
                                end
                            end
                            -- Test for reachability at all contexts
                            local key1 = prereq
                            local key2 = dep
                            for context, _ in pairs(prom ~= nil and {} or logic.contexts) do
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
                            if randomized_aggregate_costs.material_to_cost[prereq_prot_id] > slot_vanilla.aggregate.recipe_to_cost[slot_recipe.name] then
                                return false
                            end

                            -- Check if we already included this as a prereq for this recipe
                            if already_included[key(prereq_owner)] then
                                return false
                            end

                            -- Make sure the ingredient isn't too cheap, but don't worry about it for very expensive recipes
                            local should_check_costs = true
                            if constants.unified_recipe_ingredients_cost_threshold < slot_vanilla.aggregate.recipe_to_cost[slot_recipe.name] then
                                should_check_costs = false
                            end
                            if should_check_costs then
                                local largeness_okay_multiplier = 1
                                if prereq_owner.type == "fluid" then
                                    largeness_okay_multiplier = 0.1
                                end
                                if randomized_aggregate_costs.material_to_cost[prereq_owner.type .. "-" .. prereq_owner.name] < largeness_okay_multiplier * 0.001 * slot_vanilla.aggregate.recipe_to_cost[slot_recipe.name] then
                                    return false
                                end
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
                vanilla_material_to_costs.aggregate_cost = slot_vanilla.aggregate.material_to_cost
                vanilla_material_to_costs.complexity_cost = slot_vanilla.complexity.material_to_cost
                vanilla_material_to_costs.resource_costs = {}
                for _, resource_id in pairs(major_raw_resources) do
                    vanilla_material_to_costs.resource_costs[resource_id] = slot_vanilla.resources[resource_id].material_to_cost
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
                num_processed = num_processed + 1
                total_valid_prereqs = total_valid_prereqs + #valid_prereq_list_info.prereq_list
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
                for ind, ing in pairs(dependent_recipe.ingredients or {}) do
                    if is_unrandomized_ing(ind, is_result_of_this_recipe, dependent_recipe) then
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

                -- Ingredients kept as they are may not have randomized costs yet (their recipes come later in this run), so price those with full vanilla costs
                local uncosted_kept = {}
                for _, ing in pairs(unrandomized_ings) do
                    if not is_costed(randomized_aggregate_costs, randomized_resource_costs, ing) then
                        table.insert(uncosted_kept, flow_cost.get_prot_id(ing))
                    end
                end
                if #uncosted_kept > 0 then
                    log("Randomized costs don't reach kept ingredients " .. table.concat(uncosted_kept, ", ") .. " yet; using full vanilla costs for them")
                    local full = get_full_vanilla_costs()
                    local function with_full(staged, full_material_to_cost)
                        local overlay = {}
                        for _, material_id in pairs(uncosted_kept) do
                            if staged[material_id] == nil then
                                overlay[material_id] = full_material_to_cost[material_id]
                            end
                        end
                        return setmetatable(overlay, {__index = staged})
                    end
                    randomized_material_costs.aggregate_cost = with_full(randomized_material_costs.aggregate_cost, full.aggregate.material_to_cost)
                    randomized_material_costs.complexity_cost = with_full(randomized_material_costs.complexity_cost, full.complexity.material_to_cost)
                    for _, resource_id in pairs(major_raw_resources) do
                        randomized_material_costs.resource_costs[resource_id] = with_full(randomized_material_costs.resource_costs[resource_id], full.resources[resource_id].material_to_cost)
                    end
                end

                -- Finally, search for the best ingredients
                local best_search_info = cost_lib.search_for_ings(table.deepcopy(potential_ings), #reordered_ings_randomized, vanilla_recipe_costs, randomized_material_costs, {unrandomized_ings = table.deepcopy(unrandomized_ings), is_fluid_index = is_fluid_index, dont_preserve_resource_costs = dont_preserve_resource_costs, starting_planet_reachable = starting_planet_reachable})
                -- Test for failure
                local is_fallback = false
                if type(best_search_info) == "string" then
                    if prom == nil then
                        log("Recipe randomization failed")
                        return false
                    end
                    -- Fall back to vanilla ingredients, which promotion guarantees are valid in every promised context
                    log("Recipe randomization failed; falling back to vanilla ingredients")
                    num_fallbacks = num_fallbacks + 1
                    is_fallback = true
                    best_search_info = {
                        ings = table.deepcopy(slot_recipe.ingredients or {}),
                        inds = {},
                    }
                end

                -- Update dependencies
                local new_owner_keys = {}
                for index_in_best_search_info, ing in pairs(best_search_info.ings) do
                    -- In this case, this is an unrandomized ing
                    if is_fallback or index_in_best_search_info > #reordered_ings_randomized then
                        table.insert(dependent_to_new_ings[dependent_recipe.name], ing)
                        -- Unrandomized ings that aren't randomized edges (e.g. blacklisted) stay as fixed prereqs, so have no owner here
                        if prom ~= nil then
                            local owner_key = prom.vanilla_owner(dep, ing)
                            if owner_key ~= nil then
                                table.insert(new_owner_keys, owner_key)
                            end
                        end
                    else
                        local prereq_ind_of_ing = valid_prereq_list_info.prereq_inds[best_search_info.inds[index_in_best_search_info]]
                        local prereq_of_ing = shuffled_prereqs[prereq_ind_of_ing]
                        local prereq_owner = get_material_owner(random_graph, random_graph.nodes[prereq_of_ing])

                        table.insert(dependent_to_new_ings[dependent_recipe.name], ing)
                        table.insert(new_owner_keys, key(gutils.get_owner(random_graph, random_graph.nodes[prereq_of_ing])))
                        ind_to_used[prereq_ind_of_ing] = true
                        -- Add prereq to end of shuffled_prereqs (doing with replacement)
                        table.insert(shuffled_prereqs, prereq_of_ing)
                        if is_smelting_recipe then
                            smelting_ingredients[prereq_owner.type .. "-" .. prereq_owner.name] = true
                        end
                    end
                end

                if prom ~= nil and #required_contexts > 0 then
                    prom.resolve(dep, new_owner_keys, required_contexts)
                elseif prom ~= nil then
                    prom.record_ingredients(dep, new_owner_keys)
                end
                -- Pins on fixed prereqs (not randomized edges) are kept anyway
                for material_key, _ in pairs(current_pins) do
                    local kept = prom.vanilla_owner(dep, gutils.deconstruct(material_key)) == nil
                    for _, owner_key in pairs(new_owner_keys) do
                        if owner_key == material_key then
                            kept = true
                        end
                    end
                    if not kept then
                        error("Recipe " .. dep .. " dropped pinned ingredient " .. material_key)
                    end
                end
                current_pins = {}

                do
                    local is_old_ing = {}
                    for _, ing in pairs(slot_recipe.ingredients or {}) do
                        is_old_ing[key(ing)] = true
                    end
                    for _, ing in pairs(best_search_info.ings) do
                        num_ings = num_ings + 1
                        if is_old_ing[key(ing)] == nil then
                            num_changed_ings = num_changed_ings + 1
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
                -- If some new ingredient has no randomized cost yet, the recipe isn't reachable in the randomized world so far; it's no longer blacklisted, so cost updates pick it up once it is
                local new_ings_costed = true
                for _, ing in pairs(dependent_to_new_ings[dependent_recipe.name]) do
                    if not is_costed(randomized_aggregate_costs, randomized_resource_costs, ing) then
                        new_ings_costed = false
                    end
                end
                if new_ings_costed then
                    -- I changed use_data to false, not sure why it was true
                    flow_cost.update_recipe_item_costs(randomized_aggregate_costs, {dependent_recipe.name}, 100, flow_cost.get_default_raw_resource_table(), constants.cost_params.time, constants.cost_params.complexity, {ing_overrides = dependent_to_new_ings, use_data = false, item_recipe_maps = randomized_item_recipe_maps})
                    for _, resource_id in pairs(major_raw_resources) do
                        flow_cost.update_recipe_item_costs(randomized_resource_costs[resource_id], {dependent_recipe.name}, 100, flow_cost.get_single_resource_table(resource_id), 0, 0, {ing_overrides = dependent_to_new_ings, use_data = false, item_recipe_maps = randomized_item_recipe_maps})
                    end
                else
                    log("Randomized costs don't reach " .. dependent_recipe.name .. "'s new ingredients yet; its costs come once they do")
                end
                -- Just re-determine the complexity costs, this isn't the slowest part anymore anyways
                -- I was having bugs with update_recipe_item_costs which is why I do it this way
                randomized_complexity_costs = flow_cost.determine_recipe_item_cost(flow_cost.get_empty_raw_resource_table(), 0, 1, {mode = "max", ing_overrides = dependent_to_new_ings, use_data = false, item_recipe_maps = randomized_item_recipe_maps})
            end
        end
    end

    log(string.format("RECIPESTATS recipes=%d mean_valid_prereqs=%.1f changed_ings=%d/%d", num_processed, total_valid_prereqs / math.max(num_processed, 1), num_changed_ings, num_ings))
    if prom ~= nil then
        prom.log_pins()
        local unreachable = prom.anchor_remaining_recipes()
        -- For skeleton/check.lua: what promotion claims will be reachable
        UNIFIED_PROMISED_PEBBLES = prom.promised_pebbles()
        log("Promotion: done; promised " .. prom.num_promised .. " pebbles total; " .. num_fallbacks .. " recipes fell back to vanilla ingredients; " .. #unreachable .. " other recipes can no longer be reached")
        for _, recipe_key in pairs(unreachable) do
            log("Promotion: unreachable recipe " .. recipe_key)
        end
        if #unreachable > 0 then
            return false
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
                    local amount = cutils.find_amount_in_ing_or_prod(data.raw.recipe[init_slot.name].ingredients, pre_slot)
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
    local base_owner = get_material_owner(graph, base)
    if base_owner.type ~= "fluid" and base_owner.type ~= "item" then
        return false
    end

    -- Only allow fluids in fluid bases and items in item bases for now
    local old_prereq = get_material_owner(graph, graph.nodes[head.old_base])
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
    -- TODO: Do we actually need to do this? We might be able to accomplish ingredient restrictions by being careful in first pass
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

        -- Remove blacklisted for recipes without cost
        if ings[1] == "blacklisted" then
            table.remove(ings, 1)
        end

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