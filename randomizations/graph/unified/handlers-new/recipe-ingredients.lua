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
local furnace_selection = require("lib/furnace-selection")
local context_costs = require("lib/cost/context-costs")


local key = gutils.key

local recipe_ingredients = {}

recipe_ingredients.id = "recipe_ingredients"

recipe_ingredients.with_replacement = true

local recipe_to_new_ings
-- Include 10 copies first time, 3 copies each one after
local already_duped
local dependent_to_new_ings
local claimed_recipes
recipe_ingredients.initialize = function()
    recipe_to_new_ings = {}
    already_duped = {}
    claimed_recipes = {}
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
        -- Having a cost doesn't decide what's randomized (automatability does, through promotion's contexts); a recipe without a vanilla cost keeps its ingredients when processed
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
    -- Also add back recipes that went unclaimed (e.g. all their ingredients are blacklisted_pre, like yumako-processing)
    -- Recipes missing from ing_overrides are treated as nonexistent by flow_cost, which would leave their products without costs
    for recipe_name, recipe in pairs(data.raw.recipe) do
        if dependent_to_new_ings[recipe_name] == nil and not recipe.hidden then
            dependent_to_new_ings[recipe_name] = {}
            dependent_to_old_ings[recipe_name] = {}
            for _, ing in pairs(recipe.ingredients or {}) do
                table.insert(dependent_to_new_ings[recipe_name], ing)
                table.insert(dependent_to_old_ings[recipe_name], ing)
            end
        end
    end
    local major_raw_resources = randomization_info.options.cost.major_raw_resources
    local vanilla_item_recipe_maps = flow_cost.construct_item_recipe_maps()
    local randomized_item_recipe_maps = flow_cost.construct_item_recipe_maps()
    -- The ingredient search doesn't score complexity (recipe-cost.lua's get_costs_from_ings leaves it at 0), so it isn't priced, which saved two full pricings per recipe
    local no_complexity_costs = {
        material_to_cost = setmetatable({}, {
            __index = function()
                return 0
            end,
        }),
    }
    -- Aggregate costs and bills of the major resources are per room (lib/cost/context-costs.lua), each kept three ways:
    -- the game's, staged in this run's processing order (vanilla_sets); the randomized recipes' so far (randomized_sets); and the game's in full (full_sets)
    local rooms = context_costs.current
    -- The rooms recipes are judged in (context_costs.judging_context of each slot's recipe), the only ones the staged worlds need to keep up to date
    local judged_contexts = {}
    for _, dep in pairs(sorted_deps) do
        local node = random_graph.nodes[dep]
        if node.type == "recipe" and claimed_recipes[node.name] then
            local slot_node = (do_first_pass and random_graph.nodes[trav_to_slot[key(node.type, first_pass.make_trav_name(node.name))] ]) or node
            judged_contexts[context_costs.judging_context(rooms, slot_node.name) or rooms.starting_context] = true
        end
    end
    -- With nil set_params, the game's own costs (context_costs.game_set)
    local function cost_sets(set_params)
        local set
        if set_params == nil then
            set = context_costs.game_set(rooms, major_raw_resources)
        else
            set_params.track_resources = major_raw_resources
            set = context_costs.new_set(rooms, set_params)
        end
        local sets = {
            set = set,
        }
        -- Prices a recipe whose ingredients (in the overrides) are now set, in every room it's available in; where its ingredients have no costs yet, cost updates price it once they do
        sets.update = function(recipe_name)
            set:update(recipe_name)
        end
        -- Whether a room has a cost (and so a resource bill) for a material
        -- The staged worlds are built up in this run's processing order, which needn't be the order their recipes' ingredients get made in
        sets.is_costed = function(context, material)
            return set:view(context).material_to_cost[flow_cost.get_prot_id(material)] ~= nil
        end
        sets.aggregate = function(context)
            return set:view(context)
        end
        sets.resource = function(context, resource_id)
            return set:resource_view(context, resource_id)
        end
        -- A room's costs in the shape slot_vanilla takes
        sets.in_room = function(context, complexity_costs)
            local costs = {
                aggregate = set:view(context),
                complexity = complexity_costs,
                resources = {},
            }
            for _, resource_id in pairs(major_raw_resources) do
                costs.resources[resource_id] = set:resource_view(context, resource_id)
            end
            return costs
        end
        return sets
    end
    -- The game's costs are priced once per load (unified randomization's retries start from the same game); the staged worlds take their imports from them
    local full_sets = cost_sets(nil)
    local vanilla_sets = cost_sets({
        ing_overrides = dependent_to_old_ings,
        use_data = true,
        item_recipe_maps = vanilla_item_recipe_maps,
        updated_contexts = judged_contexts,
        imports_from = full_sets.set,
    })
    local randomized_sets = cost_sets({
        ing_overrides = dependent_to_new_ings,
        use_data = false,
        item_recipe_maps = randomized_item_recipe_maps,
        updated_contexts = judged_contexts,
        imports_from = full_sets.set,
    })
    -- A material's cost for choosing ingredients: what the randomized recipes so far make it for, else what the game made it for, else default (the logic graph's price, or none)
    -- What can be an ingredient is decided by automatability through promotion's contexts, not by having a cost in the randomized world yet, so every material there needs some cost
    local function fallback_view(randomized_table, full_table, default)
        return setmetatable({}, {
            __index = function(_, id)
                local cost = randomized_table[id]
                if cost == nil then
                    cost = full_table[id]
                end
                if cost == nil and default ~= nil then
                    cost = default(id)
                end
                return cost
            end,
        })
    end
    -- A recipe's cost from a room's material costs, like flow_cost prices it (ingredients, then time and complexity), or nil if some ingredient has none
    local function recipe_cost_in(material_costs, recipe)
        local total = 0
        for _, ing in pairs(recipe.ingredients or {}) do
            local cost = material_costs.material_to_cost[flow_cost.get_prot_id(ing)]
            if cost == nil then
                return nil
            end
            total = total + cutils.find_amount_in_entry(ing) * cost
        end
        return total + constants.cost_params.time * (recipe.energy_required or 0.5) + constants.cost_params.complexity
    end
    local function graph_cost_in(context)
        return function(id)
            return rooms.graph_costs[context][id]
        end
    end
    local function no_cost()
        return 0
    end

    -- How much of each material's cost in a room comes from newer resources, for the search's bonus that gets them used:
    -- raw resources outside the starting ones (major_raw_resources), and what the room imports (made in other rooms)
    local newer_resources = {}
    do
        local is_major = {}
        for _, id in pairs(major_raw_resources) do
            is_major[id] = true
        end
        for _, resource in pairs(dutils.prots("resource")) do
            for _, result in pairs(dutils.minable_results(resource)) do
                local id = result.type .. "-" .. result.name
                if is_major[id] == nil then
                    newer_resources[id] = true
                end
            end
        end
    end
    -- Each room's shares, priced once per load: newer resources and imports carry their cost as one combined "newer" amount through flow_cost's resource bills
    rooms.novelty = rooms.novelty or {}
    local function novelty_in(context)
        if rooms.novelty[context] == nil then
            local seeds = full_sets.set.tiers[context].full_seeds
            local bills = {}
            for id, cost in pairs(seeds) do
                if newer_resources[id] ~= nil or rooms.import_from[context][id] ~= nil then
                    bills[id] = {
                        newer = cost,
                    }
                end
            end
            local costs = flow_cost.determine_recipe_item_cost(seeds, constants.cost_params.time, constants.cost_params.complexity, {
                track_resources = {},
                raw_bills = bills,
                ing_overrides = context_costs.overrides_view(rooms, context, context_costs.data_overrides()),
                use_data = true,
                item_recipe_maps = vanilla_item_recipe_maps,
            })
            local novelty = {}
            for id, cost in pairs(costs.material_to_cost) do
                local bill = costs.material_to_resources[id]
                if bill ~= nil and bill.newer ~= nil and cost > 0 then
                    novelty[id] = math.min(1, bill.newer / cost)
                end
            end
            rooms.novelty[context] = novelty
        end
        return rooms.novelty[context]
    end

    -- Furnaces (the recycler too) pick their recipe by ingredient, so recipes one furnace can craft mustn't share one (see lib/furnace-selection.lua)
    -- taken[pool index][material key] marks ingredients used by a recipe that pool's furnaces craft
    -- Any shared ingredient counts, which is stricter than the selection rules but never lets a collision through
    local pools = furnace_selection.pools()
    local taken = {}
    for pool_ind, _ in pairs(pools) do
        taken[pool_ind] = {}
    end
    -- Categories are where recipe-category randomization put them, which it decided before this search
    local final_categories = {}
    for head_key, base_key in pairs(params.head_to_base or {}) do
        local head_owner = gutils.get_owner(random_graph, random_graph.nodes[head_key])
        local base_owner = gutils.get_owner(random_graph, random_graph.nodes[base_key])
        if head_owner.type == "recipe" and not head_owner.spoof and base_owner.type == "recipe-category" and lu.rcats[base_owner.name] ~= nil then
            final_categories[head_owner.name] = lu.rcats[base_owner.name].cats
        end
    end
    local function furnace_pools_of(recipe)
        return furnace_selection.pools_for(pools, final_categories[recipe.name] or furnace_selection.recipe_categories(recipe))
    end
    local function take(recipe, ing)
        for _, pool_ind in pairs(furnace_pools_of(recipe)) do
            taken[pool_ind][key(ing)] = true
        end
    end
    local function is_taken(pool_inds, material)
        for _, pool_ind in pairs(pool_inds) do
            if taken[pool_ind][key(material)] then
                return true
            end
        end
        return false
    end
    -- Ingredients that won't change: all of those in recipes this search leaves alone, and those kept in recipes it randomizes
    local to_process = {}
    for _, dep in pairs(sorted_deps) do
        local node = random_graph.nodes[dep]
        if node.type == "recipe" and claimed_recipes[node.name] then
            to_process[node.name] = true
        end
    end
    for recipe_name, recipe in pairs(data.raw.recipe) do
        for _, ing in pairs(recipe.ingredients or {}) do
            if to_process[recipe_name] == nil or randomization_info.options.unified["recipe-ingredients"].blacklisted_pre[key(ing)] then
                take(recipe, ing)
            else
                for _, result in pairs(recipe.results or {}) do
                    if result.type == ing.type and result.name == ing.name then
                        take(recipe, ing)
                    end
                end
            end
        end
    end

    -- Shared promotion state from execute-new.lua (nil means use the old every-context ordering check)
    local prom = params.promotion
    local num_fallbacks = 0
    -- Recipes at chunk boundaries (debt mode) whose new ingredients pay for them
    local num_paying = 0

    local num_processed = 0
    local total_valid_prereqs = 0
    local num_changed_ings = 0
    -- Newer resources in the ingredients chosen (see novelty_in), before and after, summed over ingredients
    local old_newer_share = 0
    local new_newer_share = 0
    -- How far chosen ingredients' aggregate cost is from the slot recipe's (mean absolute log ratio, over searched recipes)
    local cost_drift = 0
    local num_drift = 0
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

            -- Ingredients are judged in one room: the starting planet if the slot's recipe is available there, else the room the sort first reaches it in
            local context = context_costs.judging_context(rooms, slot_recipe.name) or rooms.starting_context
            -- Without a vanilla cost for the slot's recipe there's nothing to compare ingredients against, so it keeps the slot's ingredients like after a failed search
            local slot_cost_known = recipe_cost_in(full_sets.aggregate(context), slot_recipe) ~= nil
            do
                -- The staged vanilla world only has costs for what the slot recipes processed so far make
                -- Processing follows this run's sort, not vanilla's, so a slot recipe can come before the recipes making its ingredients (e.g. on other planet starts)
                local slot_is_staged = true
                for _, ing in pairs(slot_recipe.ingredients or {}) do
                    if not vanilla_sets.is_costed(context, ing) then
                        slot_is_staged = false
                    end
                end
                -- Either way, the slot recipe now counts in the staged vanilla world; if it's not reachable yet, cost updates pick it up once its ingredients are
                dependent_to_old_ings[slot_recipe.name] = {}
                for _, ing in pairs(slot_recipe.ingredients or {}) do
                    table.insert(dependent_to_old_ings[slot_recipe.name], ing)
                end
                vanilla_sets.update(slot_recipe.name)
                local slot_vanilla
                if slot_is_staged then
                    slot_vanilla = vanilla_sets.in_room(context, no_complexity_costs)
                else
                    log("Staged vanilla costs don't reach " .. slot_recipe.name .. " yet; comparing against full vanilla costs")
                    slot_vanilla = full_sets.in_room(context, no_complexity_costs)
                end
                local slot_cost = recipe_cost_in(slot_vanilla.aggregate, slot_recipe)

                -- Gather information about this recipe
                local dependent_pools = furnace_pools_of(dependent_recipe)
                local is_smelting_recipe = #dependent_pools > 0
                -- Pinned ingredients stay, so this search can't help if another recipe here took them already; the built-game check reports it
                for material_key, _ in pairs(current_pins) do
                    local material = gutils.deconstruct(material_key)
                    local pin_is_own = false
                    for _, ing in pairs(dependent_recipe.ingredients or {}) do
                        if key(ing) == material_key then
                            pin_is_own = true
                        end
                    end
                    if not pin_is_own and is_taken(dependent_pools, material) then
                        log("Furnace selection: pinned ingredient " .. material_key .. " of " .. dependent_recipe.name .. " is already used by another recipe its furnaces craft")
                    end
                end
                local is_result_of_this_recipe = {}
                if dependent_recipe.results ~= nil then
                    for _, result in pairs(dependent_recipe.results) do
                        is_result_of_this_recipe[result.type .. "-" .. result.name] = true
                    end
                end

                local candidate_costs = fallback_view(randomized_sets.aggregate(context).material_to_cost, full_sets.aggregate(context).material_to_cost, graph_cost_in(context))

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
                        local has_costs = candidate_costs[prereq_prot_id] ~= nil

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

                            -- Don't share an ingredient with another recipe the same furnace crafts
                            if is_taken(dependent_pools, prereq_owner) then
                                return false
                            end

                            -- Make sure we can find a cost for it
                            if not has_costs then
                                return false
                            end

                            -- If the cost is too high, return false
                            if candidate_costs[prereq_prot_id] > slot_cost then
                                return false
                            end

                            -- Check if we already included this as a prereq for this recipe
                            if already_included[key(prereq_owner)] then
                                return false
                            end

                            -- Make sure the ingredient isn't too cheap, but don't worry about it for very expensive recipes
                            local should_check_costs = true
                            if constants.unified_recipe_ingredients_cost_threshold < slot_cost then
                                should_check_costs = false
                            end
                            if should_check_costs then
                                local largeness_okay_multiplier = 1
                                if prereq_owner.type == "fluid" then
                                    largeness_okay_multiplier = 0.1
                                end
                                if candidate_costs[prereq_owner.type .. "-" .. prereq_owner.name] < largeness_okay_multiplier * 0.001 * slot_cost then
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
                local vanilla_recipe_costs = slot_cost_known and cost_lib.get_costs_from_ings(vanilla_material_to_costs, slot_recipe.ingredients) or nil
                -- Ingredients (candidates, and kept ones whose recipes come later in this run) are priced with fallbacks, like candidate_costs
                local randomized_material_costs = {}
                randomized_material_costs.aggregate_cost = candidate_costs
                randomized_material_costs.complexity_cost = no_complexity_costs.material_to_cost
                randomized_material_costs.resource_costs = {}
                for _, resource_id in pairs(major_raw_resources) do
                    randomized_material_costs.resource_costs[resource_id] = fallback_view(randomized_sets.resource(context, resource_id).material_to_cost, full_sets.resource(context, resource_id).material_to_cost, no_cost)
                end

                local potential_ings = {}
                local valid_prereq_list_info = {
                    prereq_list = {},
                    prereq_inds = {},
                }
                if slot_cost_known then
                    valid_prereq_list_info = find_valid_prereq_list(shuffled_prereqs)
                end
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

                -- Finally, search for the best ingredients
                local function search(ings)
                    return cost_lib.search_for_ings(table.deepcopy(ings), #reordered_ings_randomized, vanilla_recipe_costs, randomized_material_costs, {unrandomized_ings = table.deepcopy(unrandomized_ings), is_fluid_index = is_fluid_index, dont_preserve_resource_costs = dont_preserve_resource_costs, starting_planet_reachable = starting_planet_reachable, novelty = novelty_in(context)})
                end
                -- At a chunk boundary (debt mode: the recipe owes something only through its ingredients, see skeleton/promotion.lua), first search among ingredients that pay for it
                local best_search_info
                if not slot_cost_known then
                    best_search_info = "No vanilla cost to compare ingredients against."
                end
                local paying_contexts = (prom ~= nil and #required_contexts > 0) and prom.recipe_boundary_contexts(dep, required_contexts) or {}
                if #paying_contexts > 0 then
                    local paying_info = {
                        prereq_list = {},
                        prereq_inds = {},
                    }
                    local paying_ings = {}
                    for i, prereq in pairs(valid_prereq_list_info.prereq_list) do
                        if prom.pays(dep, key(gutils.get_owner(random_graph, random_graph.nodes[prereq])), paying_contexts) then
                            table.insert(paying_info.prereq_list, prereq)
                            table.insert(paying_info.prereq_inds, valid_prereq_list_info.prereq_inds[i])
                            table.insert(paying_ings, potential_ings[i])
                        end
                    end
                    if #paying_ings > 0 then
                        local paying_search_info = search(paying_ings)
                        if type(paying_search_info) ~= "string" then
                            best_search_info = paying_search_info
                            valid_prereq_list_info = paying_info
                            num_paying = num_paying + 1
                        end
                    end
                end
                if best_search_info == nil then
                    best_search_info = search(potential_ings)
                end
                -- Test for failure
                local is_fallback = false
                if type(best_search_info) == "string" then
                    if prom == nil then
                        log("Recipe randomization failed")
                        return false
                    end
                    -- Fall back to vanilla ingredients, which promotion guarantees are valid in every promised context
                    log("Recipe randomization failed (" .. best_search_info .. "); falling back to vanilla ingredients")
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
                        take(dependent_recipe, ing)
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
                        take(dependent_recipe, prereq_owner)
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
                        new_newer_share = new_newer_share + (novelty_in(context)[flow_cost.get_prot_id(ing)] or 0)
                    end
                    for _, ing in pairs(slot_recipe.ingredients or {}) do
                        old_newer_share = old_newer_share + (novelty_in(context)[flow_cost.get_prot_id(ing)] or 0)
                    end
                    if not is_fallback and vanilla_recipe_costs ~= nil then
                        local new_costs = cost_lib.get_costs_from_ings(randomized_material_costs, best_search_info.ings)
                        if new_costs.aggregate_cost > 0 and vanilla_recipe_costs.aggregate_cost > 0 then
                            cost_drift = cost_drift + math.abs(math.log(new_costs.aggregate_cost / vanilla_recipe_costs.aggregate_cost))
                            num_drift = num_drift + 1
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

                -- Update costs, in every room the recipe is available in (lib/cost/context-costs.lua)
                randomized_sets.update(dependent_recipe.name)
            end
        end
    end

    log(string.format("RECIPESTATS recipes=%d mean_valid_prereqs=%.1f changed_ings=%d/%d", num_processed, total_valid_prereqs / math.max(num_processed, 1), num_changed_ings, num_ings))
    do
        local judged = {}
        for context, _ in pairs(judged_contexts) do
            table.insert(judged, context)
        end
        table.sort(judged)
        log("RECIPESTATS judged in rooms: " .. table.concat(judged, ", "))
        log(string.format("RECIPESTATS newer resources in ingredients: %.1f before, %.1f after (summed shares); ingredient cost drift %.3f (mean abs log ratio over %d recipes)", old_newer_share, new_newer_share, cost_drift / math.max(num_drift, 1), num_drift))
    end
    if prom ~= nil then
        prom.log_pins()
        local unreachable = prom.anchor_remaining_recipes()
        -- For skeleton/check.lua: what promotion claims will be reachable
        UNIFIED_PROMISED_PEBBLES = prom.promised_pebbles()
        log("Promotion: done; promised " .. prom.num_promised .. " pebbles total; " .. num_fallbacks .. " recipes fell back to vanilla ingredients; " .. #unreachable .. " other recipes can no longer be reached; " .. num_paying .. " recipes at chunk boundaries took ingredients that pay for them")
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