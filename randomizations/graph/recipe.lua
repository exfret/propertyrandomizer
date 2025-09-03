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
local build_graph = require("lib/graph/build-graph")
local flow_cost = require("lib/graph/flow-cost")
local top_sort = require("lib/graph/top-sort")
local rng = require("lib/random/rng")

local major_raw_resources = {
    "item-iron-ore",
    "item-copper-ore",
    "item-coal",
    "item-stone",
    "fluid-crude-oil"
    -- Don't include space age resources; those aren't super important to balance
}

-- Don't randomize water
local dont_randomize_ings = {
    ["fluid-water"] = true
}
-- Also put jellynut and yumako here so that their processing recipes don't get randomized
-- Also make lava still useful by preserving it in spots
local dont_randomize_ings_space_age = {
    ["item-yumako"] = true,
    ["item-jellynut"] = true,
    ["fluid-fluoroketone-cold"] = true,
    ["fluid-lava"] = true,
    ["item-metallic-asteroid-chunk"] = true,
    ["item-carbonic-asteroid-chunk"] = true,
    ["item-oxide-asteroid-chunk"] = true,
}
for ing, bool in pairs(dont_randomize_ings_space_age) do
    dont_randomize_ings[ing] = bool
end

local function is_unrandomized_ing(ing, is_result_of_this_recipe)
    -- If this is special in any way, don't randomize
    if is_result_of_this_recipe[ing.type .. "-" .. ing.name] then
        return true
    end
    if dont_randomize_ings[ing.type .. "-" .. ing.name] then
        return true
    end

    return false
end

-- Don't randomize these sensitive recipes
-- It was just too hard when they weren't enforced...
local sensitive_recipes = {
    ["iron-plate"] = true,
    ["copper-plate"] = true,
    ["stone-brick"] = true,
    ["basic-oil-processing"] = true,
    -- Preserve fuel sinks for fluids
    ["solid-fuel-from-heavy-oil"] = true,
    ["solid-fuel-from-light-oil"] = true,
    ["solid-fuel-from-petroleum-gas"] = true,
    ["plastic-bar"] = true,
    ["uranium-processing"] = true,
    -- Technically redundant due to other checks
    ["kovarex-enrichment-process"] = true
}
-- Also add recycling recipes
-- CRITICAL TODO: WAIT DO WE NOT UPDATE RECYCLING RESULTS???
for _, recipe in pairs(data.raw.recipe) do
    if recipe.category == "recycling" or recipe.category == "recycling-or-hand-crafting" then
        sensitive_recipes[recipe.name] = true
    end
end
-- Add barreling recipes
for _, recipe in pairs(data.raw.recipe) do
    if string.sub(recipe.name, -6, -1) == "barrel" then
        sensitive_recipes[recipe.name] = true
    end
end
-- Add crushing recipes (space stuff is too sensitive I think?)
for _, recipe in pairs(data.raw.recipe) do
    if recipe.category == "crushing" then
        sensitive_recipes[recipe.name] = true
    end
end
local space_age_sensitive_recipes = {
    -- Scrap recycling is captured by recycling recipe checks
    -- I would do jellynut/yumako, but it was throwing weird errors, so I just made them unrandomized as ingredients instead
    --["jellynut-processing"] = true,
    --["yumako-processing"] = true,
    ["tungsten-plate"] = true,
    ["iron-bacteria-cultivation"] = true,
    ["copper-bacteria-cultivation"] = true,
    ["fluoroketone-cooling"] = true,
    ["ammoniacal-solution-separation"] = true,
    ["thruster-fuel"] = true,
    ["thruster-oxidizer"] = true,
    ["ice-melting"] = true,
    ["holmium-solution"] = true,
    ["holmium-plate"] = true,
    ["lithium-plate"] = true
}
if mods["space-age"] then
    for recipe_name, bool in pairs(space_age_sensitive_recipes) do
        sensitive_recipes[recipe_name] = bool
    end
end

-- Manually assign some materials to only be for some surfaces
local manually_assigned_material_surfaces = {
    ["item-spoilage"] = build_graph.compound_key({"planet", "gleba"})
}

local used_mats = {}
for _, recipe in pairs(data.raw.recipe) do
    if recipe.ingredients ~= nil and recipe.category ~= "recycling" then
        for _, ing in pairs(recipe.ingredients) do
            used_mats[flow_cost.get_prot_id(ing)] = true
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

local function calculate_points(old_recipe_costs, new_recipe_costs, extra_params)
    local dont_preserve_resource_costs = false
    if extra_params.dont_preserve_resource_costs ~= nil then
        dont_preserve_resource_costs = extra_params.dont_preserve_resource_costs
    end

    -- Calculate points given already-calculated costs

    -- aggregate cost
    -- Make it more okay for aggregate cost to be larger to fight imabalance I was having
    local aggregate_points = math.max((0.1 + new_recipe_costs.aggregate_cost) / (0.1 + old_recipe_costs.aggregate_cost), (0.1 + old_recipe_costs.aggregate_cost) / (0.1 + new_recipe_costs.aggregate_cost), 1) - 1

    -- complexity cost
    -- Don't hurt it as much for having higher complexity
    local complexity_points = math.max(old_recipe_costs.complexity_cost - new_recipe_costs.complexity_cost - 1, 0, 0.5 * (new_recipe_costs.complexity_cost - old_recipe_costs.complexity_cost - 3))

    -- resource costs
    local resource_cost_scaling = 0
    local resource_points = 0
    for resource_id, old_cost in pairs(old_recipe_costs.resource_costs) do
        local new_cost = new_recipe_costs.resource_costs[resource_id]
        -- Make it more acceptable for new_cost to be larger to fight imbalance I was having
        resource_points = resource_points + math.max((1 + old_cost) / (1 + new_cost), (1 + new_cost) / (1 + old_cost), 1) - 1
        resource_cost_scaling = resource_cost_scaling + 1
    end
    resource_points = resource_points / resource_cost_scaling
    -- If we don't care about resource costs, don't consider those points
    local resource_points_modifier = 1
    if dont_preserve_resource_costs then
        resource_points_modifier = 0
    end

    local points = constants.aggregate_points_weighting * aggregate_points + constants.complexity_points_weighting * complexity_points + resource_points_modifier * constants.resource_points_weighting * resource_points
    return points
end

local function get_costs_from_ings(material_to_costs, ings)
    local costs = {}

    -- aggregate cost
    costs.aggregate_cost = 0
    for _, ing in pairs(ings) do
        costs.aggregate_cost = costs.aggregate_cost + ing.amount * material_to_costs.aggregate_cost[ing.type .. "-" .. ing.name]
    end

    -- complexity cost
    costs.complexity_cost = 0
    for _, ing in pairs(ings) do
        costs.complexity_cost = costs.complexity_cost + material_to_costs.complexity_cost[ing.type .. "-" .. ing.name]
    end
    costs.complexity_cost = costs.complexity_cost / #ings

    -- resource costs
    costs.resource_costs = {}
    for _, resource_id in pairs(major_raw_resources) do
        costs.resource_costs[resource_id] = 0
        for _, ing in pairs(ings) do
            costs.resource_costs[resource_id] = costs.resource_costs[resource_id] + ing.amount * material_to_costs.resource_costs[resource_id][ing.type .. "-" .. ing.name]
        end
    end

    return costs
end

-- Assumes a convex points function
local function optimize_single_ing(old_recipe_costs, material_to_costs, all_ings, ing_ind, extra_params)
    local dont_preserve_resource_costs = false
    if extra_params.dont_preserve_resource_costs ~= nil then
        dont_preserve_resource_costs = extra_params.dont_preserve_resource_costs
    end

    local ing = all_ings[ing_ind]
    local old_amount = ing.amount

    local best_points
    local lower_bound = 0.25
    local upper_bound = 1
    -- Amounts are at most 2^16
    for i = 1, 16 do
        ing.amount = upper_bound
        local costs = get_costs_from_ings(material_to_costs, all_ings)
        local curr_points = calculate_points(old_recipe_costs, costs, {dont_preserve_resource_costs = dont_preserve_resource_costs})

        if not (best_points == nil or curr_points < best_points) then
            -- We've found the max number of ingredients it could be
            break
        else
            best_points = curr_points
        end

        lower_bound = lower_bound * 2
        upper_bound = upper_bound * 2
    end

    -- If upper bound is too high, decrease it by one
    if upper_bound == 65536 then
        upper_bound = 65535
    end

    local best_amount
    -- If lower_bound = 0.5, that means upper_bound as 1 was best (it can't be 0.25 because the loop runs fully at least once)
    if lower_bound == 0.5 then
        -- best_points should still be set correctly since we breaked before resetting it
        -- So just need to set best_amount
        best_amount = 1
    else
        -- Find lower bound and upper bound costs
        ing.amount = lower_bound
        local lower_costs = get_costs_from_ings(material_to_costs, all_ings)
        local lower_points = calculate_points(old_recipe_costs, lower_costs, {dont_preserve_resource_costs = dont_preserve_resource_costs})
        ing.amount = upper_bound
        local upper_costs = get_costs_from_ings(material_to_costs, all_ings)
        local upper_points = calculate_points(old_recipe_costs, upper_costs, {dont_preserve_resource_costs = dont_preserve_resource_costs})

        -- Now trinary search between lower_bound and upper_bound
        while true do
            -- Base cases
            if upper_bound == lower_bound + 1 then
                if lower_points <= upper_points then
                    best_points = lower_points
                    best_amount = lower_bound
                else
                    best_points = upper_points
                    best_amount = upper_bound
                end

                break
            elseif upper_bound == lower_bound + 2 then
                middle_amount = lower_bound + 1
                ing.amount = middle_amount
                local middle_amount_cost = get_costs_from_ings(material_to_costs, all_ings)
                local middle_amount_points = calculate_points(old_recipe_costs, middle_amount_cost, {dont_preserve_resource_costs = dont_preserve_resource_costs})

                if lower_points <= middle_amount_points and lower_points <= upper_points then
                    best_points = lower_points
                    best_amount = lower_bound
                elseif middle_amount_points < lower_points and middle_amount_points <= upper_points then
                    best_points = middle_amount_points
                    best_amount = middle_amount
                else
                    best_points = upper_points
                    best_amount = upper_bound
                end

                break
            end

            local curr_amount_1 = math.floor(lower_bound * 2 / 3 + upper_bound * 1 / 3)
            local curr_amount_2 = math.floor(lower_bound * 1 / 3 + upper_bound * 2 / 3)

            ing.amount = curr_amount_1
            local amount_costs_1 = get_costs_from_ings(material_to_costs, all_ings)
            local amount_points_1 = calculate_points(old_recipe_costs, amount_costs_1, {dont_preserve_resource_costs = dont_preserve_resource_costs})
            ing.amount = curr_amount_2
            local amount_costs_2 = get_costs_from_ings(material_to_costs, all_ings)
            local amount_points_2 = calculate_points(old_recipe_costs, amount_costs_2, {dont_preserve_resource_costs = dont_preserve_resource_costs})

            -- Could probably be optimized for cases where optimum is between, for example, curr_amount_2 and upper_bound
            if amount_points_1 < amount_points_2 then
                -- Move upper bound down
                upper_bound = curr_amount_2
                upper_costs = amount_costs_2
                upper_points = amount_points_2
            else
                -- Move lower bound up
                lower_bound = curr_amount_1
                lower_costs = amount_costs_1
                lower_points = amount_points_1
            end
        end
    end

    -- undo our modification to the ing
    ing.amount = old_amount
    return {best_points = best_points, best_amount = best_amount}
end

-- Modifies proposed_ings
-- Needs num_ings_to_find to know which ings it needs to calculate for, and which ones are fixed
local function calculate_optimal_amounts(old_recipe_costs, material_to_costs, proposed_ings, num_ings_to_find, extra_params)
    dont_preserve_resource_costs = false
    if extra_params.dont_preserve_resource_costs then
        dont_preserve_resource_costs = extra_params.dont_preserve_resource_costs
    end

    -- Special check for if there's only one item in a recipe
    if #proposed_ings == 1 then
        -- Always don't preserve resource costs in this case
        -- TODO: Think about moving this single-ingredient check outside this function?
        local optimization_info = optimize_single_ing(old_recipe_costs, material_to_costs, proposed_ings, 1, {dont_preserve_resource_costs = true})
        
        proposed_ings[1].amount = optimization_info.best_amount
        return optimization_info.best_points
    end

    -- First binary search as if this was the only ingredient for each ingredient
    -- Make sure to only allocate 1 / (3 * #proposed_ings) of the recipe cost to this ingredient
    local allocated_amounts = 1 / (3 * #proposed_ings)

    local recipe_costs_to_use = table.deepcopy(old_recipe_costs)
    recipe_costs_to_use.aggregate_cost = recipe_costs_to_use.aggregate_cost * allocated_amounts
    -- Don't do complexity costs
    for _, resource_id in pairs(major_raw_resources) do
        recipe_costs_to_use.resource_costs[resource_id] = recipe_costs_to_use.resource_costs[resource_id] * allocated_amounts
    end

    for ing_ind, ing in pairs(proposed_ings) do
        -- Only set amounts for ingredients we're randomizing
        if ing_ind <= num_ings_to_find then
            ing.amount = optimize_single_ing(recipe_costs_to_use, material_to_costs, {ing}, 1, {dont_preserve_resource_costs = dont_preserve_resource_costs}).best_amount
        end
    end

    -- Optimize each ing individually until we can't improve
    local curr_costs = get_costs_from_ings(material_to_costs, proposed_ings)
    local curr_points = calculate_points(old_recipe_costs, curr_costs, {dont_preserve_resource_costs = dont_preserve_resource_costs})
    while true do
        local new_proposals = {}

        allocated_amounts = math.min(1, allocated_amounts + 1 / (3 * #proposed_ings))

        recipe_costs_to_use = table.deepcopy(old_recipe_costs)
        recipe_costs_to_use.aggregate_cost = recipe_costs_to_use.aggregate_cost * allocated_amounts
        -- Don't do complexity costs in this part
        for _, resource_id in pairs(major_raw_resources) do
            recipe_costs_to_use.resource_costs[resource_id] = recipe_costs_to_use.resource_costs[resource_id] * allocated_amounts
        end

        for i = 1, 2 * (#proposed_ings) do
            local ing_ind = rng.int("recipe-ingredients-calculate-optimal-amounts", num_ings_to_find)
            local optimization_info = optimize_single_ing(recipe_costs_to_use, material_to_costs, proposed_ings, ing_ind, {dont_preserve_resource_costs = dont_preserve_resource_costs})
            local this_proposal_ings = table.deepcopy(proposed_ings)
            this_proposal_ings[ing_ind].amount = optimization_info.best_amount
            local this_proposal_curr_costs = get_costs_from_ings(material_to_costs, this_proposal_ings)
            -- Get actual points
            local this_proposal_curr_points = calculate_points(old_recipe_costs, this_proposal_curr_costs, {dont_preserve_resource_costs = dont_preserve_resource_costs})
            optimization_info.best_points = this_proposal_curr_points
            table.insert(new_proposals, {ind = ing_ind, optimization_info = optimization_info})
        end

        -- Choose best proposal
        local new_points = curr_points
        local ing_ind_to_change
        local new_ing_amount
        for _, proposal in pairs(new_proposals) do
            if proposal.optimization_info.best_points < new_points then
                ing_ind_to_change = proposal.ind
                new_ing_amount = proposal.optimization_info.best_amount
                new_points = proposal.optimization_info.best_points
            end
        end
        if ing_ind_to_change ~= nil then
            proposed_ings[ing_ind_to_change].amount = new_ing_amount
        end

        -- If we've optimized to within a very small point difference I think that's good enough
        if math.abs(new_points - curr_points) <= 0.0001 and allocated_amounts == 1 then
            break
        end

        curr_points = new_points
    end

    return curr_points
end

-- Note: I removed fluid_slots and old_num_fluids from extra_params in favor of is_fluid_index
local function search_for_ings(potential_ings, num_ings_to_find, old_recipe_costs, material_to_costs, extra_params)
    -- If there's nothing to randomize, return
    if num_ings_to_find == 0 then
        -- There must be unrandomized_ings in this case
        return {ings = extra_params.unrandomized_ings, points = 0, inds = {}}
    end

    if extra_params == nil then
        extra_params = {}
    end
    local is_fluid_index = {}
    if extra_params.is_fluid_index ~= nil then
        is_fluid_index = extra_params.is_fluid_index
    end
    local unrandomized_ings = {}
    if extra_params.unrandomized_ings ~= nil then
        unrandomized_ings = extra_params.unrandomized_ings
    end
    local dont_preserve_resource_costs = false
    if extra_params.dont_preserve_resource_costs ~= nil then
        dont_preserve_resource_costs = extra_params.dont_preserve_resource_costs
    end
    local nauvis_reachable
    if extra_params.nauvis_reachable ~= nil then
        nauvis_reachable = extra_params.nauvis_reachable
    end

    local curr_ing_inds = {}

    local function check_unused(ind)
        -- Check that the material is unused, not just the ind
        for _, old_ind in pairs(curr_ing_inds) do
            if potential_ings[ind].type .. "-" .. potential_ings[ind].name == potential_ings[old_ind].type .. "-" .. potential_ings[old_ind].name then
                return false
            end
        end
        for _, unrandomized_ing in pairs(unrandomized_ings) do
            if potential_ings[ind].type .. "-" .. potential_ings[ind].name == unrandomized_ing.type .. "-" .. unrandomized_ing.name then
                return false
            end
        end

        return true
    end

    local function choose_unused_ind(index_in_ings)
        while true do
            local ind = rng.int("recipe-ingredients-search-for-ings", #potential_ings)

            if check_unused(ind) then
                -- Also check fluid indices
                if (is_fluid_index[index_in_ings] and potential_ings[ind].type == "fluid") or (not is_fluid_index[index_in_ings] and potential_ings[ind].type == "item") then
                    return ind
                end
            end
        end
    end

    for i = 1, num_ings_to_find do
        local new_ing_ind = choose_unused_ind(i)
        table.insert(curr_ing_inds, new_ing_ind)
    end

    local curr_ings = {}
    for ind_in_curr_ing, ind in pairs(curr_ing_inds) do
        curr_ings[ind_in_curr_ing] = {type = potential_ings[ind].type, name = potential_ings[ind].name}
    end
    -- Add unrandomized ings back in
    for _, unrandomized_ing in pairs(unrandomized_ings) do
        table.insert(curr_ings, unrandomized_ing)
    end
    local curr_ings_points = calculate_optimal_amounts(old_recipe_costs, material_to_costs, curr_ings, num_ings_to_find, {dont_preserve_resource_costs = dont_preserve_resource_costs})

    for i = 1, #potential_ings do
        -- Check if the material for this ind is unused
        if check_unused(i) then
            -- Check which swap is best
            for j = 1, num_ings_to_find do
                local ind_to_swap = j
                local new_ind_to_use = i

                -- Just straight up preserve fluid indices for now
                if (is_fluid_index[ind_to_swap] and potential_ings[new_ind_to_use].type == "fluid") or (not is_fluid_index[ind_to_swap] and potential_ings[new_ind_to_use].type == "item") then
                    local new_ings = table.deepcopy(curr_ings)
                    new_ings[ind_to_swap] = {type = potential_ings[new_ind_to_use].type, name = potential_ings[new_ind_to_use].name}
                    local new_ings_points = calculate_optimal_amounts(old_recipe_costs, material_to_costs, new_ings, num_ings_to_find, {dont_preserve_resource_costs = dont_preserve_resource_costs})

                    -- Bonus negative points if new ingredient is not from nauvis
                    if nauvis_reachable ~= nil and not nauvis_reachable[build_graph.key(potential_ings[new_ind_to_use].type, potential_ings[new_ind_to_use].name)] then
                        --log(potential_ings[new_ind_to_use].name)
                        new_ings_points = new_ings_points - constants.non_starting_planet_bonus
                    end

                    -- Decide whether to perform swap
                    if new_ings_points < curr_ings_points then
                        -- Do the swap
                        curr_ing_inds[ind_to_swap] = new_ind_to_use
                        curr_ings = new_ings
                        curr_ings_points = new_ings_points

                        break
                    end
                end
            end

            -- Break if points are already pretty good
            if curr_ings_points <= constants.target_cost_threshold then
                break
            end
        end
    end

    return {ings = curr_ings, points = curr_ings_points, inds = curr_ing_inds}
end

-- TODO:
--   * Handle resource generation loops like coal liquefaction by studying resource costs with respect to "optimal" recipe choices
--   * Investigate certain loops like kovarex with regards to flow cost (I don't think it would handle them well)
-- FEATURES:
--   * Balanced cost randomization
--   * Keeps barreling recipes the same
--   * Makes sure furnace recipe ingredients don't overlap
--   * Furnace recipes don't involve fuels
--   * Doesn't include the results as ingredients (preventing length one loops)
--   * When there is a length one loop, preserves them (like in kovarex)
--   * Uses each thng a similar number of times
--   * Keeps the same number of fluids in the recipe
--   * Accounts for spoilage/other things that should restrict a recipe to a specific surface
randomizations.recipe_ingredients = function(id)
    ----------------------------------------------------------------------
    -- Setup
    ----------------------------------------------------------------------

    log("Recipe randomization setup")

    local old_aggregate_cost = flow_cost.determine_recipe_item_cost(flow_cost.get_default_raw_resource_table(), constants.cost_params.time, constants.cost_params.complexity)
    local old_complexity_cost = flow_cost.determine_recipe_item_cost(flow_cost.get_empty_raw_resource_table(), 0, 1, {mode = "max"})
    local old_resource_costs = {}
    for _, resource_id in pairs(major_raw_resources) do
        old_resource_costs[resource_id] = flow_cost.determine_recipe_item_cost(flow_cost.get_single_resource_table(resource_id), 0, 0)
    end

    -- Used for making sure there aren't repeat ingredients for furnaces
    local smelting_ingredients = {}
    for recipe_name, _ in pairs(sensitive_recipes) do
        if data.raw.recipe[recipe_name].category == "smelting" then
            for _, ing in pairs(data.raw.recipe[recipe_name].ingredients) do
                smelting_ingredients[ing.type .. "-" .. ing.name] = true
            end
        end
    end

    log("Finding nauvis reachable")

    -- Find stuff not reachable from nauvis by taking away spaceship and seeing what can be reached
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
    log("Doing non-Nauvis top sort")
    local nauvis_reachable = top_sort.sort(dep_graph_copy).reachable

    log("Finding all reachable")

    -- Topological sort
    local sort_info = top_sort.sort(dep_graph)
    local graph_sort = sort_info.sorted

    log("Finding item/fluid indices")

    -- Find index for items/fluids in topological sort, so that we can prioritize later items/fluids in recipes
    local node_to_index_in_sort = {}
    for ind, node in pairs(graph_sort) do
        node_to_index_in_sort[build_graph.key(node.type, node.name)] = ind
    end
    local function compare_index_in_sort_reverse(node1, node2)
        if node_to_index_in_sort[build_graph.key(node1.type, node1.name)] == nil or node_to_index_in_sort[build_graph.key(node2.type, node2.name)] == nil then
            log(serpent.block(node1))
            log(serpent.block(node2))
            error()
        end

        return node_to_index_in_sort[build_graph.key(node2.type, node2.name)] < node_to_index_in_sort[build_graph.key(node1.type, node1.name)]
    end

    ----------------------------------------------------------------------
    -- Prereq shuffle
    ----------------------------------------------------------------------

    log("Gathering dependents/prereqs")

    local sorted_dependents = {}
    local shuffled_prereqs = {}
    local blacklist = {}
    -- Assign a recipe to the first surface it appears on
    -- I think this is redundant now?
    -- TODO: Possibly remove
    local recipe_to_surface = {}
    for _, dependent_node in pairs(graph_sort) do
        if dependent_node.type == "recipe-surface" then
            if recipe_to_surface[dependent_node.recipe.name] == nil then
                -- This is the first surface encountered, so assign it to this recipe
                recipe_to_surface[dependent_node.recipe.name] = build_graph.surfaces[dependent_node.surface]

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

                if cost_calculable and has_ings and not sensitive_recipes[dependent_node.recipe.name] then
                    table.insert(sorted_dependents, dependent_node)

                    for _, prereq in pairs(dependent_node.prereqs) do
                        if prereq.is_ingredient then
                            if not dont_randomize_ings[flow_cost.get_prot_id(prereq.ing)] then
                                table.insert(shuffled_prereqs, prereq)
                                -- Add in twice for flexibility in the algorithm
                                -- There's a 50% chance for this to happen, so that there's not too much clutter
                                if rng.value(rng.key({id = id})) < 0.5 then
                                    table.insert(shuffled_prereqs, prereq)
                                end
                                -- Add to blacklist
                                blacklist[build_graph.conn_key({prereq, dependent_node})] = true
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
        dependent_to_new_ings[dependent.recipe.name] = {"blacklisted"}
        dependent_to_old_ings[dependent.recipe.name] = {"blacklisted"}
    end
    -- Add sensitive recipes back to dependent_to_new_ings
    for recipe_name, _ in pairs(sensitive_recipes) do
        dependent_to_new_ings[recipe_name] = {}
        dependent_to_old_ings[recipe_name] = {}

        if data.raw.recipe[recipe_name].ingredients ~= nil then
            for _, ing in pairs(data.raw.recipe[recipe_name].ingredients) do
                table.insert(dependent_to_new_ings[recipe_name], ing)
                table.insert(dependent_to_old_ings[recipe_name], ing)
            end
        end
    end

    log("Initial cost calculations")

    -- Updated to reflect costs at each stage
    local curr_aggregate_cost = flow_cost.determine_recipe_item_cost(flow_cost.get_default_raw_resource_table(), constants.cost_params.time, constants.cost_params.complexity, {ing_overrides = dependent_to_new_ings})
    local curr_complexity_cost = flow_cost.determine_recipe_item_cost(flow_cost.get_empty_raw_resource_table(), 0, 1, {mode = "max", ing_overrides = dependent_to_new_ings})
    local curr_resource_costs = {}
    for _, resource_id in pairs(major_raw_resources) do
        curr_resource_costs[resource_id] = flow_cost.determine_recipe_item_cost(flow_cost.get_single_resource_table(resource_id), 0, 0, {ing_overrides = dependent_to_new_ings})
    end

    -- Also updated to reflect costs at each stage, but with respect to old recipes
    local old_aggregate_cost_staged = flow_cost.determine_recipe_item_cost(flow_cost.get_default_raw_resource_table(), constants.cost_params.time, constants.cost_params.complexity, {ing_overrides = dependent_to_old_ings})
    local old_complexity_cost_staged = flow_cost.determine_recipe_item_cost(flow_cost.get_empty_raw_resource_table(), 0, 1, {mode = "max", ing_overrides = dependent_to_old_ings})
    local old_resource_costs_staged = {}
    for _, resource_id in pairs(major_raw_resources) do
        old_resource_costs_staged[resource_id] = flow_cost.determine_recipe_item_cost(flow_cost.get_single_resource_table(resource_id), 0, 0, {ing_overrides = dependent_to_old_ings})
    end

    log("Initial item recipe maps construction")

    -- Keep track of item recipe maps ourselves for optimization purposes
    local item_recipe_maps = flow_cost.construct_item_recipe_maps()

    log("Starting recipe randomization main loop")

    -- Table of indices to prereqs that have been used in a recipe
    local ind_to_used = {}
    -- Initial reachability
    local sort_state = top_sort.sort(dep_graph, blacklist)
    for _, dependent in pairs(sorted_dependents) do
        log("Starting on dependent: " .. dependent.recipe.name)

        local reachable = sort_state.reachable

        log("Old cost update")

        -- Update costs for old recipe
        dependent_to_old_ings[dependent.recipe.name] = {}
        for _, ing in pairs(dependent.recipe.ingredients) do
            table.insert(dependent_to_old_ings[dependent.recipe.name], ing)
        end

        log("Flow cost update")

        flow_cost.update_recipe_item_costs(old_aggregate_cost_staged, {dependent.recipe.name}, 100, flow_cost.get_default_raw_resource_table(), constants.cost_params.time, constants.cost_params.complexity, {ing_overrides = dependent_to_old_ings, use_data = true, item_recipe_maps = item_recipe_maps})
        old_complexity_cost_staged = flow_cost.determine_recipe_item_cost(flow_cost.get_empty_raw_resource_table(), 0, 1, {mode = "max", ing_overrides = dependent_to_old_ings, use_data = true, item_recipe_maps = item_recipe_maps})
        for _, resource_id in pairs(major_raw_resources) do
            flow_cost.update_recipe_item_costs(old_resource_costs_staged[resource_id], {dependent.recipe.name}, 100, flow_cost.get_single_resource_table(resource_id), 0, 0, {ing_overrides = dependent_to_old_ings, use_data = true, item_recipe_maps = item_recipe_maps})
        end

        log("Gathering recipe info")

        -- Gather information about this dependent/recipe
        local is_smelting_recipe = false
        if dependent.recipe.category ~= nil and dependent.recipe.category == "smelting" then
            is_smelting_recipe = true
        end

        local is_result_of_this_recipe = {}
        if dependent.recipe.results ~= nil then
            for _, result in pairs(dependent.recipe.results) do
                is_result_of_this_recipe[result.type .. "-" .. result.name] = true
            end
        end

        local function find_valid_prereq_list(shuffled_prereqs)
            local shuffled_indices_of_prereqs = {}
            for prereq_index, _ in pairs(shuffled_prereqs) do
                table.insert(shuffled_indices_of_prereqs, prereq_index)
            end

            --rng.shuffle(rng.key({id = id}), shuffled_indices_of_prereqs)
            -- Actually prioritize later on items/fluids
            local function sort_comparator(ind1, ind2)
                return compare_index_in_sort_reverse(shuffled_prereqs[ind1], shuffled_prereqs[ind2])
            end
            -- TODO: Later look into other methods, right now just preserve order
            --table.sort(shuffled_indices_of_prereqs, sort_comparator)

            -- List of the actual prereqs, rather than just the indices
            local shuffled_prereqs_to_use = {}
            for _, prereq_index in pairs(shuffled_indices_of_prereqs) do
                table.insert(shuffled_prereqs_to_use, shuffled_prereqs[prereq_index])
            end

            -- Only include each prereq once
            local already_included = {}

            local valid_prereq_list = {}
            local valid_prereq_inds = {}
            for prereq_index_in_shuffled_prereqs_to_use, prereq in pairs(shuffled_prereqs_to_use) do
                -- Make sure this prereq has currently calculable costs
                local prereq_prot_id = flow_cost.get_prot_id(prereq.ing)
                local has_costs = true
                if curr_aggregate_cost.material_to_cost[prereq_prot_id] == nil then
                    has_costs = false
                end
                for _, resource_id in pairs(major_raw_resources) do
                    if curr_resource_costs[resource_id].material_to_cost[prereq_prot_id] == nil then
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
                    if ind_to_used[shuffled_indices_of_prereqs[prereq_index_in_shuffled_prereqs_to_use]] then
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
                    if is_smelting_recipe and smelting_ingredients[prereq.ing.type .. "-" .. prereq.ing.name] then
                        return false
                    end

                    -- Make sure we can find a cost for it
                    if not has_costs then
                        return false
                    end

                    -- If the cost is too high, return false
                    if curr_aggregate_cost.material_to_cost[prereq_prot_id] > old_aggregate_cost_staged.recipe_to_cost[dependent.recipe.name] then
                        return false
                    end

                    -- Check if we already included this as a prereq for this recipe
                    if already_included[build_graph.key(prereq.type, prereq.name)] then
                        return false
                    end

                    -- If this is a fluid, make sure it's available on the relevant surface
                    if prereq.ing.type == "fluid" and not reachable[build_graph.key("fluid-surface", build_graph.compound_key({prereq.ing.name, build_graph.compound_key({build_graph.surfaces[dependent.surface].type, build_graph.surfaces[dependent.surface].name})}))] then
                        return false
                    end

                    -- If this is an item, make sure it's available on the relevant surface (this in particular rules out certain spoilables)
                    if prereq.ing.type == "item" and not reachable[build_graph.key("item-surface", build_graph.compound_key({prereq.ing.name, build_graph.compound_key({build_graph.surfaces[dependent.surface].type, build_graph.surfaces[dependent.surface].name})}))] then
                        return false
                    end

                    -- If this material has a manually assigned surface, make sure this is that surface
                    --log(serpent.block(prereq.ing))
                    if manually_assigned_material_surfaces[flow_cost.get_prot_id(prereq.ing)] ~= nil and manually_assigned_material_surfaces[flow_cost.get_prot_id(prereq.ing)] ~= build_graph.compound_key({build_graph.surfaces[dependent.surface].type, build_graph.surfaces[dependent.surface].name}) then
                        return false
                    end

                    return true
                end

                if do_recipe_checks() then
                    table.insert(valid_prereq_list, prereq)
                    -- Convert from shuffled_prereqs_to_use index to shuffled_prereqs index
                    table.insert(valid_prereq_inds, shuffled_indices_of_prereqs[prereq_index_in_shuffled_prereqs_to_use])
                    already_included[build_graph.key(prereq.type, prereq.name)] = true
                end
            end

            return {prereq_list = valid_prereq_list, prereq_inds = valid_prereq_inds}
        end

        log("Getting recipe costs")

        local old_material_to_costs = {}
        old_material_to_costs.aggregate_cost = old_aggregate_cost_staged.material_to_cost
        old_material_to_costs.complexity_cost = old_complexity_cost_staged.material_to_cost
        old_material_to_costs.resource_costs = {}
        for _, resource_id in pairs(major_raw_resources) do
            old_material_to_costs.resource_costs[resource_id] = old_resource_costs_staged[resource_id].material_to_cost
        end
        local old_recipe_costs = get_costs_from_ings(old_material_to_costs, dependent.recipe.ingredients)
        local curr_material_costs = {}
        curr_material_costs.aggregate_cost = curr_aggregate_cost.material_to_cost
        curr_material_costs.complexity_cost = curr_complexity_cost.material_to_cost
        curr_material_costs.resource_costs = {}
        for _, resource_id in pairs(major_raw_resources) do
            curr_material_costs.resource_costs[resource_id] = curr_resource_costs[resource_id].material_to_cost
        end

        log("Finding valid prereqs")

        local my_potential_ings = {}
        local valid_prereq_list_info = find_valid_prereq_list(shuffled_prereqs)
        for _, prereq in pairs(valid_prereq_list_info.prereq_list) do
            table.insert(my_potential_ings, prereq.ing)
        end

        log("Finding randomized/unrandomized ings")

        -- Find ingredients to not switch out, and put them last
        local unrandomized_ings = {}
        local reordered_ings_randomized = {}
        local reordered_ings_unrandomized = {}
        local num_ings_to_find = 0
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
        -- Also don't care if it's post-nauvis
        dont_preserve_resource_costs = produces_final_products(dependent.recipe)
        if dont_preserve_resource_costs or not nauvis_reachable[build_graph.key(dependent.type, dependent.name)] then
            log("Will not preserve resource costs")
        else
            log("Will preserve resource costs")
        end

        log("Performing ings search")

        -- Finally, search for the best ingredients
        -- Do a while loop so we can restart if there are recipe loops
        local best_search_info = search_for_ings(table.deepcopy(my_potential_ings), #reordered_ings_randomized, old_recipe_costs, curr_material_costs, {unrandomized_ings = table.deepcopy(unrandomized_ings), is_fluid_index = is_fluid_index, dont_preserve_resource_costs = dont_preserve_resource_costs, nauvis_reachable = nauvis_reachable})
        
        log("Found ings with total points " .. best_search_info.points)

        log("Updating dependencies")

        -- Update dependencies
        for index_in_best_search_info, ing in pairs(best_search_info.ings) do
            -- In this case, this is an unrandomized ing
            if index_in_best_search_info > #reordered_ings_randomized then
                table.insert(dependent_to_new_ings[dependent.recipe.name], ing)
            else
                local prereq_ind_of_ing = valid_prereq_list_info.prereq_inds[best_search_info.inds[index_in_best_search_info]]
                local prereq_of_ing = shuffled_prereqs[prereq_ind_of_ing]

                table.insert(dependent_to_new_ings[dependent.recipe.name], ing)
                ind_to_used[prereq_ind_of_ing] = true
                if is_smelting_recipe then
                    smelting_ingredients[prereq_of_ing.ing.type .. "-" .. prereq_of_ing.ing.name] = true
                end
            end
        end

        log("Updating reachability")

        -- Update reachability
        for _, prereq in pairs(dependent.prereqs) do
            blacklist[build_graph.conn_key({prereq, dependent})] = false
            sort_state = top_sort.sort(dep_graph, blacklist, sort_state, {prereq, dependent})
        end
        -- Get rid of the blacklisted property
        table.remove(dependent_to_new_ings[dependent.recipe.name], 1)

        log("Updating item recipe maps")

        -- Update item recipe maps
        flow_cost.update_item_recipe_maps(item_recipe_maps, {dependent.recipe}, dependent_to_new_ings, true)

        log("Updating new costs")

        -- Update costs
        flow_cost.update_recipe_item_costs(curr_aggregate_cost, {dependent.recipe.name}, 100, flow_cost.get_default_raw_resource_table(), constants.cost_params.time, constants.cost_params.complexity, {ing_overrides = dependent_to_new_ings, use_data = true, item_recipe_maps = item_recipe_maps})
        -- Just re-determine the complexity costs, this isn't the slowest part anymore anyways
        -- I was having bugs with update_recipe_item_costs which is why I do it this way
        log("Updating complexity cost")
        curr_complexity_cost = flow_cost.determine_recipe_item_cost(flow_cost.get_empty_raw_resource_table(), 0, 1, {mode = "max", ing_overrides = dependent_to_new_ings, use_data = true, item_recipe_maps = item_recipe_maps})
        log("Finished updating complexity cost")
        for _, resource_id in pairs(major_raw_resources) do
            flow_cost.update_recipe_item_costs(curr_resource_costs[resource_id], {dependent.recipe.name}, 100, flow_cost.get_single_resource_table(resource_id), 0, 0, {ing_overrides = dependent_to_new_ings, use_data = true, item_recipe_maps = item_recipe_maps})
        end

        log("Next loop")
    end

    ----------------------------------------------------------------------
    -- END prereq_shuffle code
    ----------------------------------------------------------------------

    -- Fix data.raw
    for recipe_name, new_ings in pairs(dependent_to_new_ings) do
        local ings = {}
        for _, ing in pairs(new_ings) do
            -- Check if this is a duped ingredient
            local already_present = false
            -- Note: This process destroys other keys, but let's hope that's fine
            -- TODO: Fix this!
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

        data.raw.recipe[recipe_name].ingredients = ings
    end
end

log("Finished loading recipe.lua")