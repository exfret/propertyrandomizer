-- Ideas to speed up:
--  * Pause early on trinary search if our points are good enough (not just multi-ing search)
--  * Optimize trinary search to binary as suggested by Hexicube
--  * Filter out prereqs that are too expensive (should be a good number)
--  * Use an appearance counting method rather than a list for prereqs
--  * Make dependency graph skinnier
-- TODO:
--  * When a recipe can't be reached, still randomize what ingredients can be reached
--  * Figure out why iron chest gets randomized to 1 ore

local constants = require("helper-tables/constants")
-- build_graph is used for its utility functions, not the graph building (graph is assumed global)
local build_graph = require("lib/old-logic/build-graph")
local flow_cost = require("lib/cost/flow-cost")
local top_sort = require("lib/old-logic/top-sort")
local rng = require("lib/random/rng")
local context_costs = require("lib/cost/context-costs")
local dutils = require("lib/data-utils")
local furnace_selection = require("lib/furnace-selection")

local DO_SURFACE_PRESERVATION = true
local gutils = require("lib/graph/graph-utils")
local logic = require("lib/logic/init")
local context_sort = require("lib/graph/context-sort")

local major_raw_resources = randomization_info.options.cost.major_raw_resources

-- Which ingredients stay and which recipes are left alone come from compat/vanilla.lua's recipe-ingredients blacklists, shared with unified randomization's handler
-- blacklisted_pre holds materials (whatever mining a resource gives, spoilage, round-trip materials, ...); blacklisted_dep holds recipes (recycling, barrels, round trips, ...)
local function recipe_blacklists()
    return randomization_info.options.unified["recipe-ingredients"]
end

local function is_blacklisted_ing(material)
    return recipe_blacklists().blacklisted_pre[gutils.key(material.type, material.name)] ~= nil
end

local function is_unrandomized_ing(ing, is_result_of_this_recipe)
    -- If this is special in any way, don't randomize
    if is_result_of_this_recipe[ing.type .. "-" .. ing.name] then
        return true
    end
    if is_blacklisted_ing(ing) then
        return true
    end

    return false
end

-- Find science packs
local is_science_pack = {}
for _, lab in pairs(data.raw.lab) do
    for _, input in pairs(lab.inputs) do
        is_science_pack[input] = true
    end
end

-- Recipes left as they are: the blacklisted ones, and when only science pack recipes are randomized (recipes with one result that is a science pack), every other one
local function find_sensitive_recipes()
    local sensitive_recipes = {}
    for recipe_name, _ in pairs(data.raw.recipe) do
        if recipe_blacklists().blacklisted_dep[gutils.key("recipe", recipe_name)] ~= nil then
            sensitive_recipes[recipe_name] = true
        end
    end
    if config.only_randomize_science_recipes then
        for _, recipe in pairs(data.raw.recipe) do
            local is_science_recipe = false
            if recipe.results ~= nil then
                if #recipe.results == 1 then
                    if recipe.results[1].type == "item" and is_science_pack[recipe.results[1].name] ~= nil then
                        is_science_recipe = true
                    end
                end
            end
            if not is_science_recipe then
                sensitive_recipes[recipe.name] = true
            end
        end
    end
    return sensitive_recipes
end

local used_mats = {}
for _, recipe in pairs(data.raw.recipe) do
    -- Disregard only recipes that aren't *only* recycling
    if recipe.ingredients ~= nil and not (recipe.categories ~= nil and #recipe.categories == 1 and recipe.categories[1] == "recycling") then
        for _, ing in pairs(recipe.ingredients) do
            used_mats[flow_cost.get_prot_id(ing)] = true
        end
    end
end

local function produces_final_products(recipe)
    if recipe.results ~= nil then
        for _, result in pairs(recipe.results) do
            -- Science packs aren't ingredients of anything, but their resource costs are what matter most
            if used_mats[flow_cost.get_prot_id(result)] ~= nil or (result.type == "item" and is_science_pack[result.name]) then
                return false
            end
        end

        return true
    end
end

local cost_lib = require("randomizations/graph/recipe-cost")
local get_costs_from_ings = cost_lib.get_costs_from_ings
local search_for_ings = cost_lib.search_for_ings

-- TODO:
--   * Handle resource generation loops like coal liquefaction by studying resource costs with respect to "optimal" recipe choices
--   * Investigate certain loops like kovarex with regards to flow cost (I don't think it would handle them well)
-- FEATURES:
--   * Balanced cost randomization, with costs per room (lib/cost/context-costs.lua) like unified randomization's recipe-ingredients handler
--   * Keeps barreling recipes the same
--   * Makes sure recipes one furnace crafts don't share ingredients (lib/furnace-selection.lua)
--   * Furnace recipes don't involve fuels
--   * Doesn't include the results as ingredients (preventing length one loops)
--   * When there is a length one loop, preserves them (like in kovarex)
--   * Uses each thng a similar number of times
--   * Keeps the same number of fluids in the recipe
--   * Accounts for spoilage/other things that should restrict a recipe to a specific surface
--   * Encourages newer resources (constants.new_resource_bonus)
randomizations.recipe_ingredients = function(id)
    ----------------------------------------------------------------------
    -- Setup
    ----------------------------------------------------------------------

    log("Recipe randomization setup")

    local sensitive_recipes = find_sensitive_recipes()

    -- The whole game's costs, from the raw costs of what it gives automatably (lib/cost/graph-cost.lua), for which recipes and materials take part at all
    -- Having a cost is how this randomization tells what's automatable, since it has no automatability check of its own
    local old_aggregate_cost = flow_cost.determine_recipe_item_cost(flow_cost.get_default_raw_resource_table(), constants.cost_params.time, constants.cost_params.complexity)

    log("Finding starting planet reachable")

    -- Find stuff not reachable from starting planet by taking away spaceship and seeing what can be reached
    log("Deepcopying dep_graph")
    local dep_graph_copy = table.deepcopy(dep_graph)
    log("Removing spacheship node")
    local spaceship_node = dep_graph_copy[build_graph.key("spaceship", "canonical")]
    for _, prereq in pairs(spaceship_node.prereqs) do
        local prereq_node = dep_graph_copy[build_graph.key(prereq.type, prereq.name)]
        local dependent_ind_to_remove
        for ind, dependent in pairs(prereq_node.dependents) do
            if dependent.type == "spaceship" and dependent.name == "canonical" then
                dependent_ind_to_remove = ind
            end
        end
        table.remove(prereq_node.dependents, dependent_ind_to_remove)
    end
    spaceship_node.prereqs = {}
    log("Doing non-starting-planet top sort")
    local starting_planet_reachable = top_sort.sort(dep_graph_copy).reachable

    log("Finding all reachable")

    -- Topological sort
    local sort_info = top_sort.sort(dep_graph)
    local graph_sort = sort_info.sorted

    -- Find previously reachable
    -- Ignore balance nodes here
    logic.build(true)
    local isolation_sort_info = context_sort.sort(logic.graph, nil, nil, { complex_contexts = true })

    ----------------------------------------------------------------------
    -- Prereq shuffle
    ----------------------------------------------------------------------

    log("Gathering dependents/prereqs")

    local sorted_dependents = {}
    local shuffled_prereqs = {}
    local blacklist = {}
    -- Assign a recipe to the first surface it appears on
    local recipe_to_surface = {}
    local material_added = {}
    for _, dependent_node in pairs(graph_sort) do
        -- Add each item/fluid node once
        if dependent_node.type == "item-surface" or dependent_node.type == "fluid-surface" then
            local material_type
            if dependent_node.type == "item-surface" then
                material_type = "item"
            elseif dependent_node.type == "fluid-surface" then
                material_type = "fluid"
            end

            -- Check that we didn't already (attempt to) add this
            local material = {
                type = material_type,
                name = dependent_node.item or dependent_node.fluid,
            }
            local prot_id = flow_cost.get_prot_id(material)
            if not material_added[prot_id] then
                material_added[prot_id] = true
                -- Check that this material has a cost
                if old_aggregate_cost.material_to_cost[prot_id] ~= nil then
                    -- Check that not blacklisted in randomizing as an ingredient
                    if not is_blacklisted_ing(material) then
                        -- Insert a manually constructed prereq so things go smoothly
                        table.insert(shuffled_prereqs, {
                            type = material_type,
                            name = material.name,
                            ing = {
                                type = material_type,
                                name = material.name,
                            }
                        })
                    end
                end
            end
        end
        if dependent_node.type == "recipe-surface" then
            if recipe_to_surface[dependent_node.recipe] == nil then
                -- This is the first surface encountered, so assign it to this recipe
                recipe_to_surface[dependent_node.recipe] = build_graph.surfaces[dependent_node.surface]

                -- Don't randomize if we couldn't calculate a cost for an ingredient of this
                local cost_calculable = true
                -- Also check that it has ingredients
                local has_ings = false
                for _, prereq in pairs(dependent_node.prereqs) do
                    if prereq.is_ingredient then
                        has_ings = true
                        if old_aggregate_cost.material_to_cost[flow_cost.get_prot_id(prereq.ing)] == nil then
                            cost_calculable = false
                        end
                    end
                end

                if cost_calculable and has_ings and not sensitive_recipes[dependent_node.recipe] then
                    table.insert(sorted_dependents, dependent_node)

                    for _, prereq in pairs(dependent_node.prereqs) do
                        if prereq.is_ingredient then
                            if not is_blacklisted_ing(prereq.ing) then
                                table.insert(shuffled_prereqs, prereq)
                                -- Add in twice for flexibility in the algorithm
                                -- There's a 50% chance for this to happen, so that there's not too much clutter
                                if rng.value(rng.key({id = id})) < 0.5 then
                                    table.insert(shuffled_prereqs, prereq)
                                end
                                -- With watch the world burn mode, we add more; this helps the algorithm out and makes things more chaotic
                                if config.watch_the_world_burn then
                                    table.insert(shuffled_prereqs, prereq)
                                end
                                -- Also, if it's expensive, add more for the algorithm since those things are hard to come by
                                if old_aggregate_cost.material_to_cost[prereq.ing.type .. "-" .. prereq.ing.name] >= 50 then
                                    table.insert(shuffled_prereqs, prereq)
                                    table.insert(shuffled_prereqs, prereq)
                                end
                                -- Add to blacklist
                                blacklist[build_graph.conn_key({prereq, dependent_node})] = true
                                -- Add recipe being made on other surfaces to blacklist
                                for surface_name, surface in pairs(build_graph.surfaces) do
                                    if surface_name ~= dependent_node.surface then
                                        local other_surface_node = dep_graph[build_graph.key("recipe-surface", build_graph.compound_key({dependent_node.recipe, surface_name}))]
                                        for _, surface_node_prereq in pairs(other_surface_node.prereqs) do
                                            blacklist[build_graph.conn_key({surface_node_prereq, other_surface_node})] = true
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    log("Shuffling")

    rng.shuffle(rng.key({id = id}), shuffled_prereqs)

    log("Constructing dependent_to_new_ings and dependent_to_old_ings")

    -- Table sending recipe to its new ingredients
    -- This needs to be populated with empty arrays first so that costs can be constructed accurately
    local dependent_to_new_ings = {}
    -- This is needed for the staged old cost calculations
    local dependent_to_old_ings = {}
    for _, dependent in pairs(sorted_dependents) do
        dependent_to_new_ings[dependent.recipe] = {"blacklisted"}
        dependent_to_old_ings[dependent.recipe] = {"blacklisted"}
    end
    -- Recipes this leaves alone keep their ingredients: the sensitive ones, and the rest that aren't randomized (without a cost or ingredients)
    -- Recipes missing from ing_overrides are treated as nonexistent by flow_cost, which would leave their products without costs
    local is_randomized = {}
    for _, dependent in pairs(sorted_dependents) do
        is_randomized[dependent.recipe] = true
    end
    for recipe_name, recipe in pairs(data.raw.recipe) do
        if dependent_to_new_ings[recipe_name] == nil then
            dependent_to_new_ings[recipe_name] = {}
            dependent_to_old_ings[recipe_name] = {}
            for _, ing in pairs(recipe.ingredients or {}) do
                table.insert(dependent_to_new_ings[recipe_name], ing)
                table.insert(dependent_to_old_ings[recipe_name], ing)
            end
        end
    end

    log("Initial cost calculations")

    -- Aggregate costs and bills of the major resources are per room (lib/cost/context-costs.lua), judged in the same room as unified randomization's handler judges them
    -- Each is kept three ways: the game's, staged in processing order (vanilla_sets); the randomized recipes' so far (randomized_sets); and the game's in full (full_sets)
    -- Prices come only from what each room has automatably, so having a cost there still means being automatable there
    local rooms = context_costs.current
    local judged_contexts = {}
    for _, dependent in pairs(sorted_dependents) do
        judged_contexts[context_costs.judging_context(rooms, dependent.recipe) or rooms.starting_context] = true
    end
    local vanilla_item_recipe_maps = flow_cost.construct_item_recipe_maps()
    local randomized_item_recipe_maps = flow_cost.construct_item_recipe_maps()
    local full_sets = context_costs.set_views(context_costs.game_set(rooms, major_raw_resources, true), major_raw_resources)
    local function staged_sets(set_params)
        set_params.track_resources = major_raw_resources
        set_params.updated_contexts = judged_contexts
        set_params.imports_from = full_sets.set
        set_params.automatable_only = true
        return context_costs.set_views(context_costs.new_set(rooms, set_params), major_raw_resources)
    end
    local vanilla_sets = staged_sets({
        ing_overrides = dependent_to_old_ings,
        use_data = true,
        item_recipe_maps = vanilla_item_recipe_maps,
    })
    local randomized_sets = staged_sets({
        ing_overrides = dependent_to_new_ings,
        use_data = false,
        item_recipe_maps = randomized_item_recipe_maps,
    })

    -- How much of each material's cost in a room comes from newer resources, for the search's bonus that gets them used (context_costs.novelty)
    local newer_resources = context_costs.newer_resources(major_raw_resources)
    local function novelty_in(context)
        return context_costs.novelty(rooms, context, full_sets.set, newer_resources, vanilla_item_recipe_maps)
    end

    -- Furnaces (the recycler too) pick their recipe by ingredient, so recipes one furnace can craft mustn't share one (lib/furnace-selection.lua's tracker)
    -- Ingredients that won't change are taken first: all of those in recipes this leaves alone, and those kept in recipes it randomizes
    local furnaces = furnace_selection.tracker()
    for recipe_name, recipe in pairs(data.raw.recipe) do
        for _, ing in pairs(recipe.ingredients or {}) do
            if is_randomized[recipe_name] == nil or is_blacklisted_ing(ing) then
                furnaces.take(recipe, ing)
            else
                for _, result in pairs(recipe.results or {}) do
                    if result.type == ing.type and result.name == ing.name then
                        furnaces.take(recipe, ing)
                    end
                end
            end
        end
    end

    log("Starting recipe randomization main loop")

    -- Table of indices to prereqs that have been used in a recipe
    local ind_to_used = {}
    -- Newer resources in the ingredients chosen (see novelty_in), before and after, summed over ingredients; and how far chosen ingredients' aggregate cost is from the recipe's (mean absolute log ratio)
    local num_processed = 0
    local num_changed_ings = 0
    local num_ings = 0
    local old_newer_share = 0
    local new_newer_share = 0
    local cost_drift = 0
    local num_drift = 0
    -- Initial reachability
    local sort_state = top_sort.sort(dep_graph, blacklist)
    for _, dependent in pairs(sorted_dependents) do
        local dependent_recipe = data.raw.recipe[dependent.recipe]
        log("Starting on dependent: " .. dependent_recipe.name)

        local reachable = table.deepcopy(sort_state.reachable)

        if DO_SURFACE_PRESERVATION then
            local new_logic_node_key = gutils.key("recipe", dependent.recipe)
            local node_in_new_logic = logic.graph.nodes[new_logic_node_key]
            local dep_surface = build_graph.surfaces[dependent.surface]
            local this_context = gutils.key(dep_surface.prototype.type, dep_surface.prototype.name)
            local function new_logic_node_isolatable(node, context)
                local context_inds = isolation_sort_info.node_to_context_inds[gutils.key(node)]
                if context_inds == nil then
                    return false
                end
                for _, ability_str in pairs(context_sort.ability_strs) do
                    if string.sub(ability_str, context_sort.ISOLATABILITY, context_sort.ISOLATABILITY) == "1" and context_inds[context_sort.context_key(context, ability_str)] ~= nil then
                        return true
                    end
                end
                return false
            end
            if new_logic_node_isolatable(node_in_new_logic, this_context) then
                log("Preserving isolatability of " .. dependent.recipe .. " on " .. this_context)
                local to_remove_from_reachable = {}
                for reachable_node_key, _ in pairs(reachable) do
                    local node_in_old = dep_graph[reachable_node_key]
                    local new_type
                    local new_name
                    if node_in_old.type == "item-surface" then
                        new_type = "item"
                        new_name = node_in_old.item
                    elseif node_in_old.type == "fluid-surface" then
                        new_type = "fluid"
                        new_name = node_in_old.fluid
                    end
                    if new_type ~= nil then
                        local node_in_new = logic.graph.nodes[gutils.key(new_type, new_name)]
                        if node_in_new ~= nil then
                            if not new_logic_node_isolatable(node_in_new, this_context) then
                                to_remove_from_reachable[reachable_node_key] = true
                            end
                        end
                    end
                end
                for reachable_node_key, _ in pairs(to_remove_from_reachable) do
                    reachable[reachable_node_key] = nil
                end
            end
        end

        -- Ingredients are judged in one room: the starting planet if the recipe is available there, else the room the sort first reaches it in
        local context = context_costs.judging_context(rooms, dependent_recipe.name) or rooms.starting_context

        log("Old cost update")

        -- The staged vanilla world only has costs for what the recipes processed so far make
        -- Processing follows the sort, not the order recipes' ingredients get made in, so a recipe can come before the recipes making its ingredients
        local is_staged = true
        for _, ing in pairs(dependent_recipe.ingredients or {}) do
            if not vanilla_sets.is_costed(context, ing) then
                is_staged = false
            end
        end
        -- Either way, the recipe now counts in the staged vanilla world; if it's not reachable yet, cost updates pick it up once its ingredients are
        dependent_to_old_ings[dependent_recipe.name] = {}
        for _, ing in pairs(dependent_recipe.ingredients or {}) do
            table.insert(dependent_to_old_ings[dependent_recipe.name], ing)
        end
        vanilla_sets.update(dependent_recipe.name)
        local old_costs
        if is_staged then
            old_costs = vanilla_sets.in_room(context)
        else
            log("Staged vanilla costs don't reach " .. dependent_recipe.name .. " yet; comparing against full vanilla costs")
            old_costs = full_sets.in_room(context)
        end
        local recipe_cost = context_costs.recipe_cost_in(old_costs.aggregate, dependent_recipe)

        log("Gathering recipe info")

        -- Gather information about this dependent/recipe
        local dependent_pools = furnaces.pools_of(dependent_recipe)
        local is_smelting_recipe = #dependent_pools > 0

        local is_result_of_this_recipe = {}
        if dependent_recipe.results ~= nil then
            for _, result in pairs(dependent_recipe.results) do
                is_result_of_this_recipe[result.type .. "-" .. result.name] = true
            end
        end

        -- Candidates must have costs from the randomized recipes so far in this room (the game's recipes that aren't randomized count from the start)
        local curr_costs = randomized_sets.in_room(context)
        local full_costs = full_sets.in_room(context)

        local function find_valid_prereq_list(shuffled_prereqs)
            -- Only include each prereq once
            local already_included = {}

            local valid_prereq_list = {}
            local valid_prereq_inds = {}
            for prereq_index, prereq in pairs(shuffled_prereqs) do
                -- Make sure this prereq has currently calculable costs
                local prereq_prot_id = flow_cost.get_prot_id(prereq.ing)
                local prereq_cost = curr_costs.aggregate.material_to_cost[prereq_prot_id]
                local has_costs = prereq_cost ~= nil
                for _, resource_id in pairs(major_raw_resources) do
                    if curr_costs.resources[resource_id].material_to_cost[prereq_prot_id] == nil then
                        has_costs = false
                    end
                end

                -- Find the fluid/item prototype that this prereq corresponds to
                local prereq_prot
                if prereq.ing.type == "fluid" then
                    prereq_prot = data.raw.fluid[prereq.ing.name]
                else
                    for item_class, _ in pairs(defines.prototypes.item) do
                        if data.raw[item_class] ~= nil then
                            if data.raw[item_class][prereq.ing.name] then
                                prereq_prot = data.raw[item_class][prereq.ing.name]
                            end
                        end
                    end
                end

                local function do_recipe_checks()
                    -- Test for reachability
                    if not reachable[build_graph.key(prereq.type, prereq.name)] then
                        return false
                    end

                    -- Test for prereqs already used for other dependents
                    if ind_to_used[prereq_index] ~= nil then
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
                    if furnaces.is_taken(dependent_pools, prereq.ing) then
                        return false
                    end

                    -- Make sure we can find a cost for it
                    if not has_costs then
                        return false
                    end

                    -- If the cost is too high, return false
                    if prereq_cost > recipe_cost then
                        return false
                    end

                    -- Check if we already included this as a prereq for this recipe
                    if already_included[build_graph.key(prereq.type, prereq.name)] then
                        return false
                    end

                    -- As a hotfix, assume being on starting planet means it's everywhere
                    -- CRITICAL TODO: FIX!
                    if build_graph.surfaces[dependent.surface].name ~= constants.starting_planet then
                        -- If this is a fluid, make sure it's available on the relevant surface
                        if prereq.ing.type == "fluid" and not reachable[build_graph.key("fluid-surface", build_graph.compound_key({prereq.ing.name, build_graph.compound_key({build_graph.surfaces[dependent.surface].type, build_graph.surfaces[dependent.surface].name})}))] then
                            return false
                        end

                        -- If this is an item, make sure it's available on the relevant surface (this in particular rules out certain spoilables)
                        if prereq.ing.type == "item" and not reachable[build_graph.key("item-surface", build_graph.compound_key({prereq.ing.name, build_graph.compound_key({build_graph.surfaces[dependent.surface].type, build_graph.surfaces[dependent.surface].name})}))] then
                            return false
                        end
                    end

                    -- Make sure the ingredient isn't too cheap
                    local largeness_okay_multiplier = 1
                    if prereq.ing.type == "fluid" then
                        largeness_okay_multiplier = 0.1
                    end
                    if prereq_cost < largeness_okay_multiplier * 0.001 * recipe_cost then
                        return false
                    end

                    return true
                end

                if do_recipe_checks() then
                    table.insert(valid_prereq_list, prereq)
                    table.insert(valid_prereq_inds, prereq_index)
                    already_included[build_graph.key(prereq.type, prereq.name)] = true
                end
            end

            return {prereq_list = valid_prereq_list, prereq_inds = valid_prereq_inds}
        end

        log("Getting recipe costs")

        local old_material_to_costs = {}
        old_material_to_costs.aggregate_cost = old_costs.aggregate.material_to_cost
        old_material_to_costs.complexity_cost = old_costs.complexity.material_to_cost
        old_material_to_costs.resource_costs = {}
        for _, resource_id in pairs(major_raw_resources) do
            old_material_to_costs.resource_costs[resource_id] = old_costs.resources[resource_id].material_to_cost
        end
        -- Ingredients a recipe keeps can be made only by recipes processed later, which have no randomized cost yet, so the search prices them like the game makes them, else at the logic graph's price
        local curr_material_costs = {}
        curr_material_costs.aggregate_cost = context_costs.fallback_view(curr_costs.aggregate.material_to_cost, full_costs.aggregate.material_to_cost, function(material_id)
            return rooms.graph_costs[context][material_id] or 0
        end)
        curr_material_costs.complexity_cost = curr_costs.complexity.material_to_cost
        curr_material_costs.resource_costs = {}
        for _, resource_id in pairs(major_raw_resources) do
            curr_material_costs.resource_costs[resource_id] = context_costs.fallback_view(curr_costs.resources[resource_id].material_to_cost, full_costs.resources[resource_id].material_to_cost, function()
                return 0
            end)
        end

        log("Finding valid prereqs")

        local my_potential_ings = {}
        local valid_prereq_list_info = {
            prereq_list = {},
            prereq_inds = {},
        }
        -- Without a cost for the recipe here there's nothing to compare ingredients against, so it keeps its ingredients
        if recipe_cost ~= nil then
            valid_prereq_list_info = find_valid_prereq_list(shuffled_prereqs)
        end

        for _, prereq in pairs(valid_prereq_list_info.prereq_list) do
            table.insert(my_potential_ings, prereq.ing)
        end

        log("Finding randomized/unrandomized ings")

        -- Find ingredients to not switch out, and put them last
        local unrandomized_ings = {}
        local reordered_ings_randomized = {}
        local reordered_ings_unrandomized = {}
        for _, prereq in pairs(dependent.prereqs) do
            if prereq.is_ingredient then
                if is_unrandomized_ing(prereq.ing, is_result_of_this_recipe) then
                    table.insert(unrandomized_ings, prereq.ing)
                    table.insert(reordered_ings_unrandomized, prereq.ing)
                else
                    table.insert(reordered_ings_randomized, prereq.ing)
                end
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

        -- Don't care about preserving resource costs if this is a final product to speed things up
        -- Also don't care if it's post-starting-planet
        local dont_preserve_resource_costs = produces_final_products(dependent_recipe)
        if dont_preserve_resource_costs or not starting_planet_reachable[build_graph.key(dependent.type, dependent.name)] then
            log("Will not preserve resource costs")
        else
            log("Will preserve resource costs")
        end

        log("Performing ings search")

        -- Finally, search for the best ingredients
        local best_search_info
        if recipe_cost == nil then
            log("No vanilla cost for " .. dependent_recipe.name .. " in " .. context .. "; keeping its ingredients")
            best_search_info = {
                ings = table.deepcopy(dependent_recipe.ingredients or {}),
                inds = {},
                points = 0,
            }
        else
            local old_recipe_costs = get_costs_from_ings(old_material_to_costs, dependent_recipe.ingredients)
            best_search_info = search_for_ings(table.deepcopy(my_potential_ings), #reordered_ings_randomized, old_recipe_costs, curr_material_costs, {unrandomized_ings = table.deepcopy(unrandomized_ings), is_fluid_index = is_fluid_index, dont_preserve_resource_costs = dont_preserve_resource_costs, starting_planet_reachable = starting_planet_reachable, novelty = novelty_in(context)})
            -- Test for error
            if type(best_search_info) == "string" then
                error(best_search_info)
            end

            log("Found ings with total points " .. best_search_info.points)
            local new_recipe_costs = get_costs_from_ings(curr_material_costs, best_search_info.ings)
            -- Local resource bills of the old and new ingredients, for dev/check-resources.py
            if not config.only_randomize_science_recipes then
                local bill_parts = {}
                for _, resource_id in pairs(major_raw_resources) do
                    table.insert(bill_parts, resource_id .. "=" .. old_recipe_costs.resource_costs[resource_id] .. "/" .. new_recipe_costs.resource_costs[resource_id])
                end
                local preserved = "preserved"
                if dont_preserve_resource_costs then
                    preserved = "unpreserved"
                end
                log("RECIPEBILL " .. dependent_recipe.name .. " " .. preserved .. " " .. table.concat(bill_parts, " "))
            end
            if new_recipe_costs.aggregate_cost > 0 and old_recipe_costs.aggregate_cost > 0 then
                cost_drift = cost_drift + math.abs(math.log(new_recipe_costs.aggregate_cost / old_recipe_costs.aggregate_cost))
                num_drift = num_drift + 1
            end
        end

        log("Updating dependencies")

        -- Update dependencies
        local is_old_ing = {}
        for _, ing in pairs(dependent_recipe.ingredients or {}) do
            is_old_ing[flow_cost.get_prot_id(ing)] = true
            old_newer_share = old_newer_share + (novelty_in(context)[flow_cost.get_prot_id(ing)] or 0)
        end
        for index_in_best_search_info, ing in pairs(best_search_info.ings) do
            table.insert(dependent_to_new_ings[dependent_recipe.name], ing)
            furnaces.take(dependent_recipe, ing)
            -- Randomized ingredients use up their spot in the pool; kept ones (after the randomized ones, or all of them when it kept its ingredients) have none
            if recipe_cost ~= nil and index_in_best_search_info <= #reordered_ings_randomized then
                ind_to_used[valid_prereq_list_info.prereq_inds[best_search_info.inds[index_in_best_search_info]]] = true
            end
            num_ings = num_ings + 1
            if is_old_ing[flow_cost.get_prot_id(ing)] == nil then
                num_changed_ings = num_changed_ings + 1
            end
            new_newer_share = new_newer_share + (novelty_in(context)[flow_cost.get_prot_id(ing)] or 0)
        end
        num_processed = num_processed + 1

        log("Updating reachability")

        -- Update reachability
        for _, prereq in pairs(dependent.prereqs) do
            blacklist[build_graph.conn_key({prereq, dependent})] = false
            if reachable[build_graph.key(prereq.type, prereq.name)] then
                sort_state = top_sort.sort(dep_graph, blacklist, sort_state, {prereq, dependent})
            end
        end
        for surface_name, surface in pairs(build_graph.surfaces) do
            if surface_name ~= dependent.surface then
                local other_surface_node = dep_graph[build_graph.key("recipe-surface", build_graph.compound_key({dependent.recipe, surface_name}))]
                for _, surface_node_prereq in pairs(other_surface_node.prereqs) do
                    blacklist[build_graph.conn_key({surface_node_prereq, other_surface_node})] = false
                    if reachable[build_graph.key(surface_node_prereq.type, surface_node_prereq.name)] then
                        sort_state = top_sort.sort(dep_graph, blacklist, sort_state, {surface_node_prereq, other_surface_node})
                    end
                end
            end
        end
        -- Get rid of the blacklisted property
        table.remove(dependent_to_new_ings[dependent_recipe.name], 1)

        log("Updating item recipe maps")

        -- Update the randomized item recipe maps with the recipe's new ingredients (data.raw still has its old ones)
        local recipe_with_new_ings = table.deepcopy(dependent_recipe)
        recipe_with_new_ings.ingredients = dependent_to_new_ings[dependent_recipe.name]
        flow_cost.update_item_recipe_maps(randomized_item_recipe_maps, {recipe_with_new_ings}, dependent_to_new_ings, true)

        log("Updating new costs")

        -- Update costs, in every room the recipe is available in
        randomized_sets.update(dependent_recipe.name)

        log("Next loop")
    end

    log(string.format("RECIPESTATS recipes=%d changed_ings=%d/%d", num_processed, num_changed_ings, num_ings))
    log(string.format("RECIPESTATS newer resources in ingredients: %.1f before, %.1f after (summed shares); ingredient cost drift %.3f (mean abs log ratio over %d recipes)", old_newer_share, new_newer_share, cost_drift / math.max(num_drift, 1), num_drift))

    ----------------------------------------------------------------------
    -- END prereq_shuffle code
    ----------------------------------------------------------------------

    -- Fix data.raw for the randomized recipes
    for recipe_name, _ in pairs(is_randomized) do
        local ings = {}
        for _, ing in pairs(dependent_to_new_ings[recipe_name]) do
            -- Check if this is a duped ingredient
            local already_present = false
            -- Note: This process destroys other keys, but let's hope that's fine
            -- We're destroying ingredient information anyways with a complete replacement of the ingredients
            -- A more careful approach would require integrating min/max temperature mechanics into the dependency graph, which would not be fun
            for _, other_ing in pairs(ings) do
                if other_ing.type == ing.type and other_ing.name == ing.name then
                    other_ing.amount = other_ing.amount + ing.amount
                    already_present = true
                    break
                end
            end
            if not already_present then
                table.insert(ings, ing)
            end
        end
        -- An item that doesn't stack is used one at a time, as in unified randomization's handler (recycling a recipe would otherwise give some back in a stack, which the game rejects)
        for _, ing in pairs(ings) do
            if ing.type == "item" and not dutils.is_stackable(dutils.get_prot("item", ing.name)) then
                ing.amount = 1
            end
        end

        data.raw.recipe[recipe_name].ingredients = ings
    end
end

log("Finished loading recipe.lua")
