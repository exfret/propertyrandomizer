local constants = require("helper-tables/constants")

local flow_cost = {}



-- log
local num_amount_in_entry_calls = 0






flow_cost.find_amount_in_entry = function(ing_or_prod)




    num_amount_in_entry_calls = num_amount_in_entry_calls + 1
    --log(num_amount_in_entry_calls)




    local probability = 1
    if ing_or_prod.probability ~= nil then
        probability = ing_or_prod.probability
    end

    if ing_or_prod.amount ~= nil then
        return probability * ing_or_prod.amount
    else
        return probability * (ing_or_prod.amount_max + ing_or_prod.amount_min) / 2
    end
end

flow_cost.find_amount_in_ing_or_prod = function(ing_or_prod_list, material)
    local material_type = "item"
    if material.type == "fluid" then
        material_type = "fluid"
    end

    local amount = 0

    if ing_or_prod_list ~= nil then
        for _, ing_or_prod in pairs(ing_or_prod_list) do
            if ing_or_prod.type == material_type and ing_or_prod.name == material.name then
                amount = amount + flow_cost.find_amount_in_entry(ing_or_prod)
            end
        end
    end

    return amount
end

flow_cost.find_amount_in_recipe = function(recipe, material, ing_overrides, use_data)
    -- Don't count recipes which are not gotten yet; these will have just the string "blacklisted"
    if ing_overrides ~= nil and ing_overrides[recipe.name] ~= nil and ing_overrides[recipe.name][1] == "blacklisted" then
        return nil
    end
    -- If ing_overrides is non-nil but doesn't contain this recipe, it's not reachable, so also return nil here
    if ing_overrides ~= nil and ing_overrides[recipe.name] == nil then
        return nil
    end

    local ing_amount = flow_cost.find_amount_in_ing_or_prod(recipe.ingredients, material)

    -- Check use_data to see if we should not be paying attention to the overrides
    if ing_overrides ~= nil and ing_overrides[recipe.name] ~= nil and not use_data then
        ing_amount = 0
        for _, prereq in pairs(ing_overrides[recipe.name]) do
            if prereq.type == material.type and prereq.name == material.name then
                ing_amount = flow_cost.find_amount_in_entry(prereq)
            end
        end
    end

    return flow_cost.find_amount_in_ing_or_prod(recipe.results, material) - ing_amount
end

flow_cost.construct_item_recipe_maps = function(ing_overrides, use_data)
    log("Considering material list")

    local material_list = {}
    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                -- Hotfix: Don't worry about filled barrels
                -- CRITICAL TODO: Autosense barrels or add this elsewhere?
                if item.name == "barrel" or string.sub(item.name, -6, -1) ~= "barrel" then
                    table.insert(material_list, item)
                end
            end
        end
    end
    for _, fluid in pairs(data.raw.fluid) do
        table.insert(material_list, fluid)
    end

    local recipe_to_material = {}
    local material_to_recipe = {}




    -- log
    local loop_its = 0




    local material_id_to_material = {}
    for _, recipe in pairs(data.raw.recipe) do
        recipe_to_material[recipe.name] = {}
    end
    for _, material in pairs(material_list) do
        material_to_recipe[flow_cost.get_prot_id(material)] = {}
        material_id_to_material[flow_cost.get_prot_id(material)] = material
    end

    for _, recipe in pairs(data.raw.recipe) do
        for _, material_property in pairs({"ingredients", "results"}) do
            if recipe[material_property] ~= nil then
                for _, ing_or_prod in pairs(recipe[material_property]) do
                    local material_id = flow_cost.get_prot_id(ing_or_prod)

                    -- This is needed in case this is an excluded material, like barrels
                    if material_id_to_material[material_id] ~= nil then
                        local amount_in_recipe = flow_cost.find_amount_in_recipe(recipe, material_id_to_material[material_id], ing_overrides, use_data)
                        if amount_in_recipe ~= 0 then
                            recipe_to_material[recipe.name][material_id] = amount_in_recipe
                            material_to_recipe[material_id][recipe.name] = amount_in_recipe
                        end
                    end
                end
            end
        end
    end
    
    return {recipe_to_material = recipe_to_material, material_to_recipe = material_to_recipe}
end

flow_cost.get_default_raw_resource_table = function()
    -- TODO: Resource auto-sensing for mods
    return table.deepcopy({
        ["item-iron-ore"] = 1,
        ["item-copper-ore"] = 1,
        ["item-coal"] = 1,
        ["item-stone"] = 1,
        ["fluid-crude-oil"] = 0.2,
        ["item-uranium-ore"] = 2,
        -- Include this so that uranium-235 isn't too expensive
        -- TODO: Maybe just require kovarex earlier?
        ["item-uranium-235"] = 100,
        ["fluid-water"] = 0.001,
        ["fluid-steam"] = 0.05,
        -- Space age resources
        ["item-metallic-asteroid-chunk"] = 1,
        ["item-carbonic-asteroid-chunk"] = 1,
        ["item-oxide-asteroid-chunk"] = 1,
        ["fluid-ammoniacal-solution"] = 0.6,
        ["fluid-fluorine"] = 0.6,
        ["item-lithium"] = 2,
        ["item-scrap"] = 1,
        ["item-pentapod-egg"] = 2,
        ["item-jellynut"] = 1,
        ["item-yumako"] = 1,
        ["item-spoilage"] = 0.5,
        ["fluid-lava"] = 0.05,
        ["item-tungsten-ore"] = 3,
        ["item-calcite"] = 1,
        ["item-iron-bacteria"] = 5,
        ["item-copper-bacteria"] = 5
    })
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



-- log
local eval_recipe_cost_calls = 0





flow_cost.eval_recipe_cost = function(params)
    local recipe_name = params.recipe_name
    local material_to_cost = params.material_to_cost
    local recipe_time_modifier = params.recipe_time_modifier
    local recipe_complexity_modifier = params.recipe_complexity_modifier
    local mode = params.mode
    local ing_overrides = params.ing_overrides
    local use_data = params.use_data

    local new_cost = 0
    local reachable = true

    local recipe = data.raw.recipe[recipe_name]
    -- recipe.ingredients must exist since amount < 0
    local ings_to_use = recipe.ingredients
    -- if this has an override, use that instead
    if ing_overrides ~= nil and ing_overrides[recipe_name] ~= nil then
        if ing_overrides[recipe_name][1] == "blacklisted" then
            ings_to_use = {}
    
            reachable = false
        -- Check that use_data isn't set for whether we use the overrides
        elseif not use_data then
            ings_to_use = {}
    
            for _, ing in pairs(ing_overrides[recipe_name]) do
                table.insert(ings_to_use, ing)
            end
        end
    end
    for _, ing in pairs(ings_to_use) do






        eval_recipe_cost_calls = eval_recipe_cost_calls + 1
        --log(eval_recipe_cost_calls)






        local ing_material_id = ing.type .. "-" .. ing.name
        local ing_amount = flow_cost.find_amount_in_entry(ing)
        
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

    return {reachable = reachable, cost = new_cost}
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

    if curr_node.type == "material" then
        local material_type
        local material_name
        if string.sub(curr_node.name, 1, 4) == "item" then
            material_type = "item"
            material_name = string.sub(curr_node.name, 6, -1)
        else
            material_type = "fluid"
            material_name = string.sub(curr_node.name, 7, -1)
        end
        local curr_node_material = {type = material_type, name = material_name}

        for recipe_name, _ in pairs(material_to_recipe[curr_node.name]) do
            -- Only check recipes for which this is an ingredient
            -- We can't use amount here because it takes results into account, which we don't want
            local recipe_ingredients = data.raw.recipe[recipe_name].ingredients
            if ing_overrides ~= nil and ing_overrides[recipe_name] ~= nil and ing_overrides[recipe_name][1] ~= "blacklisted" then
                -- Make sure we aren't forced to use data.raw
                if not use_data then
                    recipe_ingredients = {}
                    for _, ing_override in pairs(ing_overrides[recipe_name]) do
                        table.insert(recipe_ingredients, ing_override)
                    end
                end
            end

            if recipe_ingredients ~= nil and flow_cost.find_amount_in_ing_or_prod(recipe_ingredients, curr_node_material) > 0 then
                -- Evaluate if the recipe is cheaper now
                local cost_info = flow_cost.eval_recipe_cost({
                    recipe_name = recipe_name,
                    material_to_cost = material_to_cost,
                    recipe_time_modifier = recipe_time_modifier,
                    recipe_complexity_modifier = recipe_complexity_modifier,
                    mode = mode,
                    ing_overrides = ing_overrides,
                    use_data = use_data
                })

                if cost_info.reachable and (recipe_to_cost[recipe_name] == nil or cost_info.cost < recipe_to_cost[recipe_name]) then
                    recipe_to_cost[recipe_name] = cost_info.cost
                    table.insert(open_nodes, {
                        type = "recipe",
                        name = recipe_name
                    })
                end
            end
        end
    elseif curr_node.type == "recipe" then
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
                    table.insert(open_nodes, {
                        type = "material",
                        name = material_id
                    })
                end
            end
        end
    end
end

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
        recipe_to_material = extra_params.item_recipe_maps.recipe_to_material
        material_to_recipe = extra_params.item_recipe_maps.material_to_recipe
    else
        item_recipe_maps = flow_cost.construct_item_recipe_maps(ing_overrides, use_data)
        recipe_to_material = item_recipe_maps.recipe_to_material
        material_to_recipe = item_recipe_maps.material_to_recipe
    end

    local material_to_cost = {}
    local recipe_to_cost = {}

    local open_nodes = {}
    
    -- First open nodes are raw resources
    for resource_id, cost in pairs(raw_resource_costs) do
        table.insert(open_nodes, {
            type = "material",
            name = resource_id
        })
        material_to_cost[resource_id] = cost
    end

    local open_index = 1
    while true do
        local curr_node
        if #open_nodes >= open_index then
            curr_node = open_nodes[open_index]
        else
            break
        end

        flow_cost.local_cost_update({
            open_nodes = open_nodes,
            curr_node = curr_node,
            material_to_recipe = material_to_recipe,
            recipe_to_material = recipe_to_material,
            material_to_cost = material_to_cost,
            recipe_to_cost = recipe_to_cost,
            recipe_time_modifier = recipe_time_modifier,
            recipe_complexity_modifier = recipe_complexity_modifier,
            mode = mode,
            ing_overrides = ing_overrides,
            use_data = use_data
        })

        if open_index >= constants.max_flow_iterations then
            break
        end
        open_index = open_index + 1
    end

    return {material_to_cost = material_to_cost, recipe_to_cost = recipe_to_cost}
end

-- Update the costs just a bit knowing that the addition of new_recipe_names is all that's changed
flow_cost.update_recipe_item_costs = function(curr_costs, new_recipe_names, num_its, raw_resource_costs, recipe_time_modifier, recipe_complexity_modifier, extra_params)
    if extra_params == nil then
        extra_params = {}
    end
    local mode = extra_params.mode
    local ing_overrides = extra_params.ing_overrides
    local use_data = extra_params.use_data

    log("Constructing item recipe maps")

    local item_recipe_maps
    local recipe_to_material
    local material_to_recipe
    if extra_params.item_recipe_maps ~= nil then
        recipe_to_material = extra_params.item_recipe_maps.recipe_to_material
        material_to_recipe = extra_params.item_recipe_maps.material_to_recipe
    else
        item_recipe_maps = flow_cost.construct_item_recipe_maps(ing_overrides, use_data)
        recipe_to_material = item_recipe_maps.recipe_to_material
        material_to_recipe = item_recipe_maps.material_to_recipe
    end
    
    local material_to_cost = curr_costs.material_to_cost
    local recipe_to_cost = curr_costs.recipe_to_cost

    -- Still need to add in resource costs
    for resource_id, cost in pairs(raw_resource_costs) do
        material_to_cost[resource_id] = cost
    end

    log("Finding new open nodes")

    local open_nodes = {}
    for _, recipe_name in pairs(new_recipe_names) do
        table.insert(open_nodes, {
            type = "recipe",
            name = recipe_name
        })

        -- Add the costs of the recipes to recipe_to_cost
        local cost_info = flow_cost.eval_recipe_cost({
            recipe_name = recipe_name,
            material_to_cost = material_to_cost,
            recipe_time_modifier = recipe_time_modifier,
            recipe_complexity_modifier = recipe_complexity_modifier,
            mode = mode,
            ing_overrides = ing_overrides,
            use_data = use_data
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
    end

    log("Beginning flow cost algorithm")

    local open_index = 1
    while true do
        local curr_node
        if #open_nodes >= open_index then
            curr_node = open_nodes[open_index]
        else
            break
        end

        flow_cost.local_cost_update({
            open_nodes = open_nodes,
            curr_node = curr_node,
            material_to_recipe = material_to_recipe,
            recipe_to_material = recipe_to_material,
            material_to_cost = material_to_cost,
            recipe_to_cost = recipe_to_cost,
            recipe_time_modifier = recipe_time_modifier,
            recipe_complexity_modifier = recipe_complexity_modifier,
            mode = mode,
            ing_overrides = ing_overrides,
            use_data
        })

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