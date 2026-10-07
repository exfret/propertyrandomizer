local constants = require("helper-tables/constants")
local build_graph = require("lib/old-logic/build-graph")
local rng = require("lib/random/rng")

local major_raw_resources = randomization_info.options.cost.major_raw_resources

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
    --local complexity_points = math.max(old_recipe_costs.complexity_cost - new_recipe_costs.complexity_cost - 1, 0, 0.5 * (new_recipe_costs.complexity_cost - old_recipe_costs.complexity_cost - 3))
    -- In fact, let's just not hurt at all for higher complexity
    local complexity_points = math.max(old_recipe_costs.complexity_cost - new_recipe_costs.complexity_cost - 1, 0)

    -- resource costs
    local resource_cost_scaling = 0
    local resource_points = 0
    if not config.only_randomize_science_recipes then
        for resource_id, old_cost in pairs(old_recipe_costs.resource_costs) do
            local new_cost = new_recipe_costs.resource_costs[resource_id]
            -- Make it more acceptable for new_cost to be larger to fight imbalance I was having
            resource_points = resource_points + math.max((1 + old_cost) / (1 + new_cost), (1 + new_cost) / (1 + old_cost), 1) - 1
            resource_cost_scaling = resource_cost_scaling + 1
        end
        resource_points = resource_points / resource_cost_scaling
    end
    -- If we don't care about resource costs, don't consider those points
    local resource_points_modifier = 1
    if dont_preserve_resource_costs then
        resource_points_modifier = 0
    end

    -- Don't care about resource costs in the case of science pack only randomization; things aren't as sensitive
    if config.only_randomize_science_recipes then
        resource_points_modifier = 0
    end

    local points = constants.aggregate_points_weighting * aggregate_points + constants.complexity_points_weighting * complexity_points + resource_points_modifier * constants.resource_points_weighting * resource_points
    return points
end

local function get_costs_from_ings(material_to_costs, ings)
    local costs = {}

    -- Each ingredient's material id, made once rather than once per resource
    local ids = {}
    for ind, ing in pairs(ings) do
        ids[ind] = ing.type .. "-" .. ing.name
    end

    -- aggregate cost
    costs.aggregate_cost = 0
    for ind, ing in pairs(ings) do
        costs.aggregate_cost = costs.aggregate_cost + ing.amount * material_to_costs.aggregate_cost[ids[ind]]
    end

    -- complexity cost
    costs.complexity_cost = 0
    --[[for _, ing in pairs(ings) do
        costs.complexity_cost = costs.complexity_cost + material_to_costs.complexity_cost[ing.type .. "-" .. ing.name]
    end
    costs.complexity_cost = costs.complexity_cost / #ings]]

    -- resource costs
    costs.resource_costs = {}
    if not config.only_randomize_science_recipes then
        for _, resource_id in pairs(major_raw_resources) do
            costs.resource_costs[resource_id] = 0
            local resource_costs = material_to_costs.resource_costs[resource_id]
            for ind, ing in pairs(ings) do
                costs.resource_costs[resource_id] = costs.resource_costs[resource_id] + ing.amount * resource_costs[ids[ind]]
            end
        end
    end

    return costs
end

-- The form an ingredient has in the game: its form field when the caller says it (with items and fluids trading positions, a candidate's position and its identity can differ in form, see lib/item-fluid.lua), else its type
local function form_of(ing)
    return ing.form or ing.type
end

-- Gives a function from an amount of all_ings[ing_ind] to the costs of all_ings, as get_costs_from_ings gives them, with the other amounts staying as they are.
-- The other ingredients are added up once, so each amount tried only adds its own share; the sums can differ from get_costs_from_ings in the last bits, since they're added in another order.
local function varied_amount_costs(material_to_costs, all_ings, ing_ind)
    local ing = all_ings[ing_ind]
    local id = ing.type .. "-" .. ing.name
    local rest_aggregate = 0
    for ind, other in pairs(all_ings) do
        if ind ~= ing_ind then
            rest_aggregate = rest_aggregate + other.amount * material_to_costs.aggregate_cost[other.type .. "-" .. other.name]
        end
    end
    local unit_aggregate = material_to_costs.aggregate_cost[id]
    local rest_resources = {}
    local unit_resources = {}
    -- Like get_costs_from_ings, no resource costs with science-pack-only recipe randomization (config.only_randomize_science_recipes is true or nil)
    if config.only_randomize_science_recipes ~= true then
        for _, resource_id in pairs(major_raw_resources) do
            local resource_costs = material_to_costs.resource_costs[resource_id]
            local rest = 0
            for ind, other in pairs(all_ings) do
                if ind ~= ing_ind then
                    rest = rest + other.amount * resource_costs[other.type .. "-" .. other.name]
                end
            end
            rest_resources[resource_id] = rest
            unit_resources[resource_id] = resource_costs[id]
        end
    end
    return function(amount)
        local costs = {
            aggregate_cost = rest_aggregate + amount * unit_aggregate,
            complexity_cost = 0,
            resource_costs = {},
        }
        for resource_id, rest in pairs(rest_resources) do
            costs.resource_costs[resource_id] = rest + amount * unit_resources[resource_id]
        end
        return costs
    end
end

-- Assumes a convex points function
-- Also returns the costs at the best amount (costs)
local function optimize_single_ing(old_recipe_costs, material_to_costs, all_ings, ing_ind, extra_params)
    local dont_preserve_resource_costs = false
    if extra_params.dont_preserve_resource_costs ~= nil then
        dont_preserve_resource_costs = extra_params.dont_preserve_resource_costs
    end

    -- The ingredient's own amount is left alone; the amounts tried only go through costs_at
    local costs_at = varied_amount_costs(material_to_costs, all_ings, ing_ind)

    -- Amounts are at most 2^16, and a fluid's at most extra_params.fluid_amount_cap when given (recipe shapes cap them at the largest fluid amount any recipe takes, see lib/recipe-shape.lua)
    local max_amount = 65535
    if extra_params.fluid_amount_cap ~= nil and form_of(all_ings[ing_ind]) == "fluid" then
        max_amount = math.max(1, math.floor(extra_params.fluid_amount_cap))
    end
    local best_points
    local lower_bound = 0.25
    local upper_bound = 1
    for i = 1, 16 do
        local costs = costs_at(upper_bound)
        local curr_points = calculate_points(old_recipe_costs, costs, {dont_preserve_resource_costs = dont_preserve_resource_costs})

        if not (best_points == nil or curr_points < best_points) then
            -- We've found the max number of ingredients it could be
            break
        else
            best_points = curr_points
        end

        if upper_bound >= max_amount then
            break
        end
        lower_bound = lower_bound * 2
        upper_bound = math.min(upper_bound * 2, max_amount)
    end

    -- If upper bound is too high, decrease it to the most an amount can be
    if upper_bound > max_amount then
        upper_bound = max_amount
    end

    local best_amount
    -- If lower_bound = 0.5, that means upper_bound as 1 was best (it can't be 0.25 because the loop runs fully at least once)
    if lower_bound == 0.5 then
        -- best_points should still be set correctly since we breaked before resetting it
        -- So just need to set best_amount
        best_amount = 1
    else
        -- Find lower bound and upper bound costs
        local lower_costs = costs_at(lower_bound)
        local lower_points = calculate_points(old_recipe_costs, lower_costs, {dont_preserve_resource_costs = dont_preserve_resource_costs})
        local upper_costs = costs_at(upper_bound)
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
                local middle_amount_cost = costs_at(middle_amount)
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

            local amount_costs_1 = costs_at(curr_amount_1)
            local amount_points_1 = calculate_points(old_recipe_costs, amount_costs_1, {dont_preserve_resource_costs = dont_preserve_resource_costs})
            local amount_costs_2 = costs_at(curr_amount_2)
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

    return {
        best_points = best_points,
        best_amount = best_amount,
        costs = costs_at(best_amount),
    }
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
        local optimization_info = optimize_single_ing(old_recipe_costs, material_to_costs, proposed_ings, 1, {
            dont_preserve_resource_costs = true,
            fluid_amount_cap = extra_params.fluid_amount_cap,
        })

        proposed_ings[1].amount = optimization_info.best_amount
        return optimization_info.best_points
    end

    -- First binary search as if this was the only ingredient for each ingredient
    -- Make sure to only allocate 1 / (3 * #proposed_ings) of the recipe cost to this ingredient
    local allocated_amounts = 1 / (3 * #proposed_ings)

    local recipe_costs_to_use = table.deepcopy(old_recipe_costs)
    recipe_costs_to_use.aggregate_cost = recipe_costs_to_use.aggregate_cost * allocated_amounts
    -- Don't do complexity costs
    if not config.only_randomize_science_recipes then
        for _, resource_id in pairs(major_raw_resources) do
            recipe_costs_to_use.resource_costs[resource_id] = recipe_costs_to_use.resource_costs[resource_id] * allocated_amounts
        end
    end

    for ing_ind, ing in pairs(proposed_ings) do
        -- Only set amounts for ingredients we're randomizing
        if ing_ind <= num_ings_to_find then
            ing.amount = optimize_single_ing(recipe_costs_to_use, material_to_costs, {ing}, 1, {
                dont_preserve_resource_costs = dont_preserve_resource_costs,
                fluid_amount_cap = extra_params.fluid_amount_cap,
            }).best_amount
        end
    end

    -- Optimize each ing individually until we can't improve
    local curr_costs = get_costs_from_ings(material_to_costs, proposed_ings)
    local curr_points = calculate_points(old_recipe_costs, curr_costs, {dont_preserve_resource_costs = dont_preserve_resource_costs})
    local num_failed_attempts = 0
    while true do
        local new_proposals = {}

        allocated_amounts = math.min(1, allocated_amounts + 1 / (3 * #proposed_ings))

        recipe_costs_to_use = table.deepcopy(old_recipe_costs)
        recipe_costs_to_use.aggregate_cost = recipe_costs_to_use.aggregate_cost * allocated_amounts
        -- Don't do complexity costs in this part
        if not config.only_randomize_science_recipes then
            for _, resource_id in pairs(major_raw_resources) do
                recipe_costs_to_use.resource_costs[resource_id] = recipe_costs_to_use.resource_costs[resource_id] * allocated_amounts
            end
        end

        for i = 1, 2 * (#proposed_ings) do
            local ing_ind = rng.int("recipe-ingredients-calculate-optimal-amounts", num_ings_to_find)
            local optimization_info = optimize_single_ing(recipe_costs_to_use, material_to_costs, proposed_ings, ing_ind, {
                dont_preserve_resource_costs = dont_preserve_resource_costs,
                fluid_amount_cap = extra_params.fluid_amount_cap,
            })
            -- Get actual points
            local this_proposal_curr_points = calculate_points(old_recipe_costs, optimization_info.costs, {dont_preserve_resource_costs = dont_preserve_resource_costs})
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
        if math.abs(new_points - curr_points) <= 0.0001 and allocated_amounts == 1 or num_failed_attempts >= constants.max_num_failed_attempts_ing_search then
            break
        end

        curr_points = new_points
        num_failed_attempts = num_failed_attempts + 1
    end

    return curr_points
end

-- Note: I removed fluid_slots and old_num_fluids from extra_params in favor of is_fluid_index
local function search_for_ings(potential_ings, num_ings_to_find, old_recipe_costs, material_to_costs, extra_params)
    if extra_params == nil then
        extra_params = {}
    end
    -- The forms of the slots to fill, as a list of "item"/"fluid" (recipe shapes, see lib/recipe-shape.lua), in place of num_ings_to_find and is_fluid_index
    local is_fluid_index = {}
    if extra_params.slot_forms ~= nil then
        num_ings_to_find = #extra_params.slot_forms
        for ind, form in pairs(extra_params.slot_forms) do
            if form == "fluid" then
                is_fluid_index[ind] = true
            end
        end
    elseif extra_params.is_fluid_index ~= nil then
        is_fluid_index = extra_params.is_fluid_index
    end

    -- If there's nothing to randomize, return
    if num_ings_to_find == 0 then
        -- There must be unrandomized_ings in this case
        return {ings = extra_params.unrandomized_ings, points = 0, inds = {}}
    end
    local unrandomized_ings = {}
    if extra_params.unrandomized_ings ~= nil then
        unrandomized_ings = extra_params.unrandomized_ings
    end
    local dont_preserve_resource_costs = false
    if extra_params.dont_preserve_resource_costs ~= nil then
        dont_preserve_resource_costs = extra_params.dont_preserve_resource_costs
    end
    local starting_planet_reachable
    if extra_params.starting_planet_reachable ~= nil then
        starting_planet_reachable = extra_params.starting_planet_reachable
    end
    -- Optional material id --> share of its cost from newer raw resources (0 to 1), which earn a bonus, since those tend to get left out
    local novelty = extra_params.novelty
    -- Points taken off for the newer resources in the ingredients being chosen (the kept ones come after them)
    local function novelty_bonus(ings)
        if novelty == nil then
            return 0
        end
        local bonus = 0
        for i = 1, num_ings_to_find do
            if ings[i] ~= nil then
                bonus = bonus + (novelty[ings[i].type .. "-" .. ings[i].name] or 0)
            end
        end
        return constants.new_resource_bonus * bonus
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
        if #potential_ings == 0 then
            return "No possible ingredients for recipe."
        end

        local num_failed_attempts = 0

        while true do
            local ind = rng.int("recipe-ingredients-search-for-ings", #potential_ings)

            if check_unused(ind) then
                -- Also check fluid indices, by the form the candidate has in the game
                if (is_fluid_index[index_in_ings] and form_of(potential_ings[ind]) == "fluid") or (not is_fluid_index[index_in_ings] and form_of(potential_ings[ind]) == "item") then
                    return ind
                end
            end

            num_failed_attempts = num_failed_attempts + 1
            if num_failed_attempts >= constants.max_num_failed_attempts_ing_search then
                log(serpent.block(potential_ings))
                return "Max number of failed attempts reached during recipe ingredient randomization."
            end
        end
    end

    for i = 1, num_ings_to_find do
        local new_ing_ind = choose_unused_ind(i)
        -- Check for warning
        if type(new_ing_ind) == "string" then
            return new_ing_ind
        end
        table.insert(curr_ing_inds, new_ing_ind)
    end

    local curr_ings = {}
    for ind_in_curr_ing, ind in pairs(curr_ing_inds) do
        curr_ings[ind_in_curr_ing] = {
            type = potential_ings[ind].type,
            name = potential_ings[ind].name,
            form = potential_ings[ind].form,
        }
    end
    -- Add unrandomized ings back in
    for _, unrandomized_ing in pairs(unrandomized_ings) do
        table.insert(curr_ings, unrandomized_ing)
    end
    local amount_params = {
        dont_preserve_resource_costs = dont_preserve_resource_costs,
        fluid_amount_cap = extra_params.fluid_amount_cap,
    }
    local curr_ings_points = calculate_optimal_amounts(old_recipe_costs, material_to_costs, curr_ings, num_ings_to_find, amount_params) - novelty_bonus(curr_ings)

    -- Candidates tried so far, and how many had been when the points last made real progress (see constants.ing_search_stall_candidates)
    local num_tried = 0
    local last_progress = 0
    local progress_points = curr_ings_points
    for i = 1, #potential_ings do
        -- Stop once the points have stopped making real progress: when no ingredient fits the recipe's cost, tiny improvements go on for every candidate
        if num_tried - last_progress >= constants.ing_search_stall_candidates then
            break
        end
        -- Check if the material for this ind is unused
        if check_unused(i) then
            num_tried = num_tried + 1
            -- Check which swap is best
            for j = 1, num_ings_to_find do
                local ind_to_swap = j
                local new_ind_to_use = i

                -- Just straight up preserve fluid indices for now, by the form the candidate has in the game
                if (is_fluid_index[ind_to_swap] and form_of(potential_ings[new_ind_to_use]) == "fluid") or (not is_fluid_index[ind_to_swap] and form_of(potential_ings[new_ind_to_use]) == "item") then
                    local new_ings = table.deepcopy(curr_ings)
                    new_ings[ind_to_swap] = {
                        type = potential_ings[new_ind_to_use].type,
                        name = potential_ings[new_ind_to_use].name,
                        form = potential_ings[new_ind_to_use].form,
                    }
                    local new_ings_points = calculate_optimal_amounts(old_recipe_costs, material_to_costs, new_ings, num_ings_to_find, amount_params) - novelty_bonus(new_ings)

                    -- Bonus negative points if new ingredient is not from starting planet
                    if starting_planet_reachable ~= nil and not starting_planet_reachable[build_graph.key(potential_ings[new_ind_to_use].type, potential_ings[new_ind_to_use].name)] then
                        --log(potential_ings[new_ind_to_use].name)
                        new_ings_points = new_ings_points - constants.non_starting_planet_bonus
                    end

                    -- Decide whether to perform swap
                    if new_ings_points < curr_ings_points then
                        -- Do the swap
                        curr_ing_inds[ind_to_swap] = new_ind_to_use
                        curr_ings = new_ings
                        curr_ings_points = new_ings_points
                        if curr_ings_points <= progress_points - constants.ing_search_progress_points then
                            progress_points = curr_ings_points
                            last_progress = num_tried
                        end

                        break
                    end
                end
            end

            -- Break if points are already pretty good
            -- Only after trying a candidate: the random start is often under the threshold already, but keeping it made recipes (and so science packs) noticeably dearer
            if curr_ings_points <= constants.target_cost_threshold then
                break
            end
        end
    end

    return {ings = curr_ings, points = curr_ings_points, inds = curr_ing_inds}
end

return {
    calculate_points = calculate_points,
    get_costs_from_ings = get_costs_from_ings,
    optimize_single_ing = optimize_single_ing,
    calculate_optimal_amounts = calculate_optimal_amounts,
    search_for_ings = search_for_ings,
}