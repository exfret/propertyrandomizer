local constants = require("helper-tables/constants")
local cutils = require("lib/cost/cost-utils")

local flow_cost = {}

-- Precomputation of materials
flow_cost.material_list = {}
flow_cost.material_id_to_material = {}
flow_cost.update_material_list = function()
    flow_cost.material_list = {}
    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                -- Hotfix: Don't worry about filled barrels
                -- CRITICAL TODO: Autosense barrels or add this elsewhere?
                if item.name == "barrel" or string.sub(item.name, -6, -1) ~= "barrel" then
                    table.insert(flow_cost.material_list, item)
                end
            end
        end
    end
    for _, fluid in pairs(data.raw.fluid) do
        table.insert(flow_cost.material_list, fluid)
    end

    for _, material in pairs(flow_cost.material_list) do
        flow_cost.material_id_to_material[flow_cost.get_prot_id(material)] = material
    end
end

flow_cost.calculate_individual_recipe_map = function(recipe, maps, ing_overrides, use_data)
    local material_lists = {
        recipe.ingredients or {},
        recipe.results or {},
    }
    -- Overridden ingredients may include materials that aren't in data.raw's ingredients, so they need visiting too
    if not use_data and ing_overrides ~= nil and ing_overrides[recipe.name] ~= nil and ing_overrides[recipe.name][1] ~= "blacklisted" then
        table.insert(material_lists, ing_overrides[recipe.name])
    end
    for _, material_list in pairs(material_lists) do
        if material_list ~= nil then
            for _, ing_or_prod in pairs(material_list) do
                local material_id = flow_cost.get_prot_id(ing_or_prod)

                -- This is needed in case this is an excluded material, like barrels
                if flow_cost.material_id_to_material[material_id] ~= nil then
                    local amount_in_recipe = cutils.find_amount_in_recipe(recipe, flow_cost.material_id_to_material[material_id], ing_overrides, use_data)
                    if amount_in_recipe ~= 0 then
                        maps.recipe_to_material[recipe.name][material_id] = amount_in_recipe
                        maps.material_to_recipe[material_id][recipe.name] = amount_in_recipe
                    end
                end
            end
        end
    end
end

flow_cost.construct_item_recipe_maps = function(ing_overrides, use_data, recipe_prototypes)
    --log("Considering material list")
    flow_cost.update_material_list()
    recipe_prototypes = recipe_prototypes or data.raw.recipe

    local recipe_to_material = {}
    local material_to_recipe = {}
    for _, recipe in pairs(recipe_prototypes) do
        recipe_to_material[recipe.name] = {}
    end
    for _, material in pairs(flow_cost.material_list) do
        material_to_recipe[flow_cost.get_prot_id(material)] = {}
    end

    for _, recipe in pairs(recipe_prototypes) do
        flow_cost.calculate_individual_recipe_map(recipe, {recipe_to_material = recipe_to_material, material_to_recipe = material_to_recipe}, ing_overrides, use_data)
    end
    
    return {recipe_to_material = recipe_to_material, material_to_recipe = material_to_recipe}
end

flow_cost.update_item_recipe_maps = function(old_maps, updated_recipes, ing_overrides, use_data)
    for _, recipe in pairs(updated_recipes) do
        -- Recalculate the mappings for this recipe

        for material_id, amount in pairs(old_maps.recipe_to_material[recipe.name]) do
            old_maps.recipe_to_material[recipe.name][material_id] = nil
            old_maps.material_to_recipe[material_id][recipe.name] = nil
        end

        flow_cost.calculate_individual_recipe_map(recipe, old_maps, ing_overrides, use_data)
    end
end

-- A copy of the raw material costs (randomization_info.options.cost.default_cost_table)
flow_cost.get_default_raw_resource_table = function()
    local raw_costs = {}
    for material_id, cost in pairs(randomization_info.options.cost.default_cost_table) do
        raw_costs[material_id] = cost
    end
    return raw_costs
end

flow_cost.get_empty_raw_resource_table = function()
    local empty_table = flow_cost.get_default_raw_resource_table()
    for key, _ in pairs(empty_table) do
        empty_table[key] = 0
    end
    return empty_table
end

flow_cost.get_single_resource_table = function(specified_resource_id)
    local resource_table = {}

    for ind, _ in pairs(flow_cost.get_default_raw_resource_table()) do
        if ind == specified_resource_id then
            resource_table[ind] = 1
        else
            resource_table[ind] = 0
        end
    end

    return resource_table
end

-- Read-only stand-in for a missing ingredient list
local NO_INGREDIENTS = {}

-- The ingredients a recipe is priced with (only read), and false if the overrides make it unavailable
local function priced_ingredients(recipe, recipe_name, ing_overrides, use_data)
    -- A recipe can leave out its ingredients (like the captive spawner's biter eggs)
    local ings_to_use = recipe.ingredients or NO_INGREDIENTS
    local reachable = true
    -- If this has an override, use that instead
    if ing_overrides ~= nil then
        local override = ing_overrides[recipe_name]
        if override ~= nil then
            if override[1] == "blacklisted" then
                ings_to_use = NO_INGREDIENTS
                reachable = false
            -- Check that use_data isn't set for whether we use the overrides
            elseif not use_data then
                ings_to_use = override
            end
        else
            ings_to_use = NO_INGREDIENTS
            reachable = false
        end
    end
    return ings_to_use, reachable
end

-- A recipe's cost from its ingredients' costs, and whether all of them have one
local function ingredients_cost(recipe, ings_to_use, reachable, material_to_cost, recipe_time_modifier, recipe_complexity_modifier, mode)
    local new_cost = 0
    for _, ing in pairs(ings_to_use) do
        local ing_material_id = ing.type .. "-" .. ing.name
        local ing_amount = cutils.find_amount_in_entry(ing)
        
        if material_to_cost[ing_material_id] ~= nil then
            if mode == nil or mode == "add" then
                new_cost = new_cost + ing_amount * material_to_cost[ing_material_id]
            elseif mode == "max" then
                new_cost = math.max(new_cost, material_to_cost[ing_material_id])
            else
                -- I misspelled something
                error()
            end
        else
            reachable = false
            break
        end
    end

    -- Add base costs for time required and also for added cost of "complexity" for an extra recipe
    local energy_required = 0.5
    if recipe.energy_required ~= nil then
        energy_required = recipe.energy_required
    end
    new_cost = new_cost + recipe_time_modifier * energy_required
    new_cost = new_cost + recipe_complexity_modifier

    return reachable, new_cost
end

-- A recipe's resource bill, summed over its ingredients the same way as its cost
local function ingredients_bill(ings_to_use, material_to_cost, mode, material_to_resources)
    local resources = {}
    for _, ing in pairs(ings_to_use) do
        local ing_material_id = ing.type .. "-" .. ing.name
        local ing_amount = cutils.find_amount_in_entry(ing)

        if material_to_cost[ing_material_id] ~= nil then
            if mode == nil or mode == "add" then
                for resource_id, amount in pairs(material_to_resources[ing_material_id]) do
                    resources[resource_id] = (resources[resource_id] or 0) + ing_amount * amount
                end
            end
        else
            break
        end
    end
    return resources
end

flow_cost.eval_recipe_cost = function(params)
    local recipe = (params.recipe_prototypes or data.raw.recipe)[params.recipe_name]
    local ings_to_use, reachable = priced_ingredients(recipe, params.recipe_name, params.ing_overrides, params.use_data)
    local cost
    reachable, cost = ingredients_cost(recipe, ings_to_use, reachable, params.material_to_cost, params.recipe_time_modifier, params.recipe_complexity_modifier, params.mode)
    -- Material -> raw resource vector, when resources are tracked (see determine_recipe_item_cost)
    local resources
    if params.material_to_resources ~= nil then
        resources = ingredients_bill(ings_to_use, params.material_to_cost, params.mode, params.material_to_resources)
    end
    return {
        reachable = reachable,
        cost = cost,
        resources = resources,
    }
end

-- Queue entries for the pricing loops, one per recipe and per material, never changed once made
local recipe_nodes = {}
local material_nodes = {}
local function recipe_node(recipe_name)
    local node = recipe_nodes[recipe_name]
    if node == nil then
        node = {
            type = "recipe",
            name = recipe_name,
        }
        recipe_nodes[recipe_name] = node
    end
    return node
end
local function material_node(material_id)
    local node = material_nodes[material_id]
    if node == nil then
        node = {
            type = "material",
            name = material_id,
        }
        material_nodes[material_id] = node
    end
    return node
end

-- Material id (like "item-iron-plate") --> {type, name}, made once per id and never changed
local material_of_id = {}
local function material_from_id(material_id)
    local material = material_of_id[material_id]
    if material == nil then
        if string.sub(material_id, 1, 4) == "item" then
            material = {
                type = "item",
                name = string.sub(material_id, 6, -1),
            }
        else
            material = {
                type = "fluid",
                name = string.sub(material_id, 7, -1),
            }
        end
        material_of_id[material_id] = material
    end
    return material
end

flow_cost.local_cost_update = function(params)
    local open_nodes = params.open_nodes
    local curr_node = params.curr_node
    local material_to_recipe = params.material_to_recipe
    local recipe_to_material = params.recipe_to_material
    local material_to_cost = params.material_to_cost
    local recipe_to_cost = params.recipe_to_cost
    local recipe_time_modifier = params.recipe_time_modifier
    local recipe_complexity_modifier = params.recipe_complexity_modifier
    -- Mode is how to combine costs from multiple ingredients
    -- Default way is to add (this is chosen when it is nil), but for complexity calculations it makes more sense to take max
    local mode = params.mode
    local ing_overrides = params.ing_overrides
    local use_data = params.use_data
    local material_to_resources = params.material_to_resources
    local recipe_to_resources = params.recipe_to_resources

    if curr_node.type == "material" then
        local curr_node_material = material_from_id(curr_node.name)
        local recipe_prototypes = params.recipe_prototypes or data.raw.recipe

        for recipe_name, _ in pairs(material_to_recipe[curr_node.name]) do
            -- ing_overrides can be a view that works out each entry (see lib/cost/context-costs.lua), so it's read once
            local override
            if ing_overrides ~= nil then
                override = ing_overrides[recipe_name]
            end
            -- Don't use blacklisted recipes for item costs
            -- Note: This doesn't seem to do anything, probably safe to delete
            if ing_overrides == nil or (override ~= nil and override[1] ~= "blacklisted") then
                -- Only check recipes for which this is an ingredient
                -- We can't use amount here because it takes results into account, which we don't want
                local recipe_ingredients = recipe_prototypes[recipe_name].ingredients
                -- Make sure we aren't forced to use data.raw (the override is only read)
                if override ~= nil and not use_data then
                    recipe_ingredients = override
                end

                if recipe_ingredients ~= nil and cutils.find_amount_in_ing_or_prod(recipe_ingredients, curr_node_material) > 0 then
                    -- Evaluate if the recipe is cheaper now
                    local recipe = recipe_prototypes[recipe_name]
                    local ings_to_use, reachable = priced_ingredients(recipe, recipe_name, ing_overrides, use_data)
                    local cost
                    reachable, cost = ingredients_cost(recipe, ings_to_use, reachable, material_to_cost, recipe_time_modifier, recipe_complexity_modifier, mode)

                    if reachable and (recipe_to_cost[recipe_name] == nil or cost < recipe_to_cost[recipe_name]) then
                        recipe_to_cost[recipe_name] = cost
                        -- The bill only matters for the recipe that sets the cost, so it's made only then
                        if recipe_to_resources ~= nil then
                            local resources
                            if material_to_resources ~= nil then
                                resources = ingredients_bill(ings_to_use, material_to_cost, mode, material_to_resources)
                            end
                            recipe_to_resources[recipe_name] = resources
                        end
                        table.insert(open_nodes, recipe_node(recipe_name))
                    end
                end
            end
        end
    elseif curr_node.type == "recipe" then
        -- Read once, like above
        local override
        if ing_overrides ~= nil then
            override = ing_overrides[curr_node.name]
        end
        if ing_overrides == nil or (override ~= nil and override[1] ~= "blacklisted") then
            -- Distribute cost evenly over results
            local num_results = 0
            for _, amount in pairs(recipe_to_material[curr_node.name]) do
                if amount > 0 then
                    num_results = num_results + 1
                end
            end

            for material_id, amount in pairs(recipe_to_material[curr_node.name]) do
                -- Only check materials that are a product of this recipe
                if amount > 0 then
                    local new_cost
                    if mode == nil or mode == "add" then
                        new_cost = recipe_to_cost[curr_node.name] / (num_results * amount)
                    elseif mode == "max" then
                        new_cost = recipe_to_cost[curr_node.name]
                    else
                        -- I misspelled something
                        error()
                    end
                    if material_to_cost[material_id] == nil or new_cost < material_to_cost[material_id] then
                        material_to_cost[material_id] = new_cost
                        if material_to_resources ~= nil then
                            -- Same even split as the cost
                            local resources = {}
                            for resource_id, resource_amount in pairs(recipe_to_resources[curr_node.name]) do
                                resources[resource_id] = resource_amount / (num_results * amount)
                            end
                            material_to_resources[material_id] = resources
                        end
                        table.insert(open_nodes, material_node(material_id))
                    end
                end
            end
        end
    end
end

-- extra_params.track_resources: list of raw resource IDs; if given, also finds each material's bill of those resources
-- (material_to_resources, material ID -> {resource ID -> amount}) along the recipes that give it its cost
-- Unlike costing each resource on its own, this can't be fooled by loops that are free with respect to one resource
flow_cost.determine_recipe_item_cost = function(raw_resource_costs, recipe_time_modifier, recipe_complexity_modifier, extra_params)
    if extra_params == nil then
        extra_params = {}
    end
    local mode = extra_params.mode
    local ing_overrides = extra_params.ing_overrides
    local use_data = extra_params.use_data

    local item_recipe_maps
    local recipe_to_material
    local material_to_recipe
    if extra_params.item_recipe_maps ~= nil then
        item_recipe_maps = extra_params.item_recipe_maps
        recipe_to_material = extra_params.item_recipe_maps.recipe_to_material
        material_to_recipe = extra_params.item_recipe_maps.material_to_recipe
    else
        item_recipe_maps = flow_cost.construct_item_recipe_maps(ing_overrides, use_data, extra_params.recipe_prototypes)
        recipe_to_material = item_recipe_maps.recipe_to_material
        material_to_recipe = item_recipe_maps.material_to_recipe
    end

    local material_to_cost = {}
    local recipe_to_cost = {}
    local material_to_resources
    local recipe_to_resources
    if extra_params.track_resources ~= nil then
        material_to_resources = {}
        recipe_to_resources = {}
    end

    local open_nodes = {}
    
    -- First open nodes are raw resources
    for resource_id, cost in pairs(raw_resource_costs) do
        table.insert(open_nodes, material_node(resource_id))
        material_to_cost[resource_id] = cost
    end
    if material_to_resources ~= nil then
        flow_cost.set_raw_resource_vectors(material_to_resources, raw_resource_costs, extra_params.track_resources, extra_params.raw_bills)
    end
    -- Recipes that take nothing (like the captive spawner's biter eggs) are sources too, since no material would open them
    local recipe_names = {}
    for recipe_name, _ in pairs(recipe_to_material) do
        table.insert(recipe_names, recipe_name)
    end
    table.sort(recipe_names)
    for _, recipe_name in pairs(recipe_names) do
        local takes_something = false
        for _, amount in pairs(recipe_to_material[recipe_name]) do
            if amount < 0 then
                takes_something = true
            end
        end
        if not takes_something then
            local cost_info = flow_cost.eval_recipe_cost({
                recipe_name = recipe_name,
                recipe_prototypes = extra_params.recipe_prototypes,
                material_to_cost = material_to_cost,
                recipe_time_modifier = recipe_time_modifier,
                recipe_complexity_modifier = recipe_complexity_modifier,
                mode = mode,
                ing_overrides = ing_overrides,
                use_data = use_data,
                material_to_resources = material_to_resources,
            })
            if cost_info.reachable then
                recipe_to_cost[recipe_name] = cost_info.cost
                if recipe_to_resources ~= nil then
                    recipe_to_resources[recipe_name] = cost_info.resources
                end
                table.insert(open_nodes, recipe_node(recipe_name))
            end
        end
    end

    -- local_cost_update only reads its params, so one table serves every step
    local update_params = {
        open_nodes = open_nodes,
        recipe_prototypes = extra_params.recipe_prototypes,
        material_to_recipe = material_to_recipe,
        recipe_to_material = recipe_to_material,
        material_to_cost = material_to_cost,
        recipe_to_cost = recipe_to_cost,
        recipe_time_modifier = recipe_time_modifier,
        recipe_complexity_modifier = recipe_complexity_modifier,
        mode = mode,
        ing_overrides = ing_overrides,
        use_data = use_data,
        material_to_resources = material_to_resources,
        recipe_to_resources = recipe_to_resources,
    }
    local open_index = 1
    while true do
        local curr_node
        if #open_nodes >= open_index then
            curr_node = open_nodes[open_index]
        else
            break
        end

        update_params.curr_node = curr_node
        flow_cost.local_cost_update(update_params)

        if open_index >= constants.max_flow_iterations then
            break
        end
        open_index = open_index + 1
    end

    return {
        material_to_cost = material_to_cost,
        recipe_to_cost = recipe_to_cost,
        material_to_resources = material_to_resources,
        recipe_to_resources = recipe_to_resources,
        track_resources = extra_params.track_resources,
    }
end

-- One resource's cost of each material, read from costs determined with track_resources
-- Same shape as the material_to_cost of a single resource table run: nil where the material has no cost yet
flow_cost.resource_cost_view = function(costs, resource_id)
    return setmetatable({}, {
        __index = function(_, material_id)
            local resources = costs.material_to_resources[material_id]
            if resources == nil then
                return nil
            end
            return resources[resource_id] or 0
        end,
    })
end

-- Raw resources are their own bill: a tracked resource is one of itself, anything else raw is free
-- raw_bills (optional): material id --> bill, for raw materials that carry one from elsewhere (like imports, see lib/cost/context-costs.lua)
flow_cost.set_raw_resource_vectors = function(material_to_resources, raw_resource_costs, track_resources, raw_bills)
    for resource_id, _ in pairs(raw_resource_costs) do
        material_to_resources[resource_id] = {}
    end
    for _, resource_id in pairs(track_resources) do
        material_to_resources[resource_id] = {[resource_id] = 1}
    end
    for material_id, bill in pairs(raw_bills or {}) do
        if raw_resource_costs[material_id] ~= nil then
            local copy = {}
            for resource_id, amount in pairs(bill) do
                copy[resource_id] = amount
            end
            material_to_resources[material_id] = copy
        end
    end
end

-- Update the costs just a bit knowing that the addition of new_recipe_names is all that's changed
flow_cost.update_recipe_item_costs = function(curr_costs, new_recipe_names, num_its, raw_resource_costs, recipe_time_modifier, recipe_complexity_modifier, extra_params)
    if extra_params == nil then
        extra_params = {}
    end
    local mode = extra_params.mode
    local ing_overrides = extra_params.ing_overrides
    local use_data = extra_params.use_data

    --log("Constructing item recipe maps")

    local item_recipe_maps
    local recipe_to_material
    local material_to_recipe
    if extra_params.item_recipe_maps ~= nil then
        item_recipe_maps = extra_params.item_recipe_maps
        recipe_to_material = extra_params.item_recipe_maps.recipe_to_material
        material_to_recipe = extra_params.item_recipe_maps.material_to_recipe
    else
        item_recipe_maps = flow_cost.construct_item_recipe_maps(ing_overrides, use_data, extra_params.recipe_prototypes)
        recipe_to_material = item_recipe_maps.recipe_to_material
        material_to_recipe = item_recipe_maps.material_to_recipe
    end
    
    local material_to_cost = curr_costs.material_to_cost
    local recipe_to_cost = curr_costs.recipe_to_cost
    -- Resources are tracked if they were when curr_costs was determined
    local material_to_resources = curr_costs.material_to_resources
    local recipe_to_resources = curr_costs.recipe_to_resources

    -- Still need to add in resource costs
    for resource_id, cost in pairs(raw_resource_costs) do
        material_to_cost[resource_id] = cost
    end
    if material_to_resources ~= nil then
        flow_cost.set_raw_resource_vectors(material_to_resources, raw_resource_costs, curr_costs.track_resources, extra_params.raw_bills)
    end

    --log("Finding new open nodes")

    local open_nodes = {}
    for _, recipe_name in pairs(new_recipe_names) do
        table.insert(open_nodes, recipe_node(recipe_name))

        -- Add the costs of the recipes to recipe_to_cost
        local cost_info = flow_cost.eval_recipe_cost({
            recipe_name = recipe_name,
            recipe_prototypes = extra_params.recipe_prototypes,
            material_to_cost = material_to_cost,
            recipe_time_modifier = recipe_time_modifier,
            recipe_complexity_modifier = recipe_complexity_modifier,
            mode = mode,
            ing_overrides = ing_overrides,
            use_data = use_data,
            material_to_resources = material_to_resources,
        })
        if not cost_info.reachable then
            -- Updating the costs comes with the assumption we just unlocked these recipes, so if we still can't reach them then something is up
            -- Also log the offending recipe/other info for debugging purposes
            log(serpent.block(material_to_cost))
            log(recipe_name)
            error()
        end
        -- If we've already been able to reach this recipe, then something is fishy
        if recipe_to_cost[recipe_name] ~= nil then
            log(recipe_name)
            error()
        end
        recipe_to_cost[recipe_name] = cost_info.cost
        if recipe_to_resources ~= nil then
            recipe_to_resources[recipe_name] = cost_info.resources
        end
    end

    -- local_cost_update only reads its params, so one table serves every step
    local update_params = {
        open_nodes = open_nodes,
        recipe_prototypes = extra_params.recipe_prototypes,
        material_to_recipe = material_to_recipe,
        recipe_to_material = recipe_to_material,
        material_to_cost = material_to_cost,
        recipe_to_cost = recipe_to_cost,
        recipe_time_modifier = recipe_time_modifier,
        recipe_complexity_modifier = recipe_complexity_modifier,
        mode = mode,
        ing_overrides = ing_overrides,
        use_data = use_data,
        material_to_resources = material_to_resources,
        recipe_to_resources = recipe_to_resources,
    }
    local open_index = 1
    while true do
        local curr_node
        if #open_nodes >= open_index then
            curr_node = open_nodes[open_index]
        else
            break
        end

        update_params.curr_node = curr_node
        flow_cost.local_cost_update(update_params)

        if open_index >= num_its then
            break
        end
        open_index = open_index + 1
    end
end

flow_cost.get_prot_id = function(prototype)
    local prot_type = "item"
    if prototype.type == "fluid" then
        prot_type = "fluid"
    end
    return prot_type .. "-" .. prototype.name
end

return flow_cost