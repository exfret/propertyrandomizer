local constants = require("helper-tables/constants")
local simplex = require("lib/cost/simplex")
local sparse_simplex = require("lib/cost/sparse-simplex-cutoff")
local cutils = require("lib/cost/cost-utils")
local dutils = require("new-lib/data-utils")
local gutils = require("new-lib/graph/graph-utils")

local prots = dutils.prots

local simplex_cost = {}

-- Also computes recipe cost column and material amount row
simplex_cost.make_recipe_material_matrix = function()
    local materials = {}
    for _, item in pairs(dutils.get_all_prots("item")) do
        materials[gutils.key("item", item.name)] = {
            type = "item",
            name = item.name
        }
    end
    for _, fluid in pairs(prots("fluid")) do
        materials[gutils.key("fluid", fluid.name)] = {
            type = "fluid",
            name = fluid.name
        }
    end

    local material_list = {}
    local material_to_ind = {}
    for _, material in pairs(materials) do
        table.insert(material_list, material)
        material_to_ind[gutils.key(material)] = #material_list
    end
    local recipe_list = {}
    local recipe_to_ind = {}
    for _, recipe in pairs(prots("recipe")) do
        table.insert(recipe_list, recipe)
        recipe_to_ind[recipe.name] = #recipe_list
    end

    local matrix = {}
    local cost_column = {}

    for _, recipe in pairs(recipe_list) do
        local row = {}
        for _, material in pairs(material_list) do
            --table.insert(row, cutils.find_amount_in_recipe(recipe, material))
            local amount = cutils.find_amount_in_recipe(recipe, material)
            if amount ~= 0 then
                row[material_to_ind[gutils.key(material)]] = amount
            end
        end
        -- Identity matrix part is automatically handled by simplex algorithm
        table.insert(matrix, row)

        -- Cost
        local additional_cost = constants.simplex_per_recipe_cost + (recipe.energy_required or 0.5) * constants.simplex_per_second_cost
        table.insert(cost_column, additional_cost)
    end
    -- Offshore pumps/tiles fluid
    for _, pump in pairs(prots("offshore-pump")) do
        if pump.fluid_box.filter ~= nil then
            local row = {}
            for _, material in pairs(material_list) do
                if material.type ~= "fluid" or material.name ~= pump.fluid_box.filter then
                    --table.insert(row, 0)
                else
                    -- Pumping speed doesn't really matter, so add 1 regardless
                    --table.insert(row, 1)
                    row[material_to_ind[gutils.key(material)]] = 1
                end
            end
            table.insert(matrix, row)
            table.insert(cost_column, constants.simplex_pump_cost)
        end
    end
    for _, tile in pairs(prots("tile")) do
        if tile.fluid ~= nil then
            local row = {}
            for _, material in pairs(material_list) do
                if material.type ~= "fluid" or material.name ~= tile.fluid then
                    --table.insert(row, 0)
                else
                    --table.insert(row, 1)
                    row[material_to_ind[gutils.key(material)]] = 1
                end
            end
            table.insert(matrix, row)
            table.insert(cost_column, constants.simplex_pump_cost)
        end
    end
    -- Boiler
    for _, boiler in pairs(prots("boiler")) do
        if boiler.fluid_box.filter ~= nil and boiler.output_fluid_box.filter ~= nil and boiler.mode == "output-to-separate-pipe" and boiler.fluid_box.filter ~= boiler.output_fluid_box.filter then
            local row = {}
            for _, material in pairs(material_list) do
                -- This doesn't account for actual conversion rates
                if material.type == "fluid" and material.name == boiler.fluid_box.filter then
                    --table.insert(row, -1)
                    row[material_to_ind[gutils.key(material)]] = -1
                elseif material.type == "fluid" and material.name == boiler.output_fluid_box.filter then
                    --table.insert(row, 1)
                    row[material_to_ind[gutils.key(material)]] = 1
                else
                    --table.insert(row, 0)
                end
            end
            table.insert(matrix, row)
            table.insert(cost_column, constants.simplex_boiling_cost)
        end
    end
    -- Resource mining
    for _, resource in pairs(prots("resource")) do
        local minable = resource.minable
        if minable ~= nil then
            if minable.results ~= nil or minable.result ~= nil then
                local results = minable.results or {
                    {type = "item", name = minable.result, amount = minable.count or 1}
                }

                local row = {}
                for _, material in pairs(material_list) do
                    local amount = 0
                    if material.type == "fluid" and material.name == minable.required_fluid then
                        amount = amount - (minable.fluid_amount or 0)
                    end
                    amount = amount + cutils.find_amount_in_ing_or_prod(results, material)
                    --table.insert(row, amount)
                    if amount ~= 0 then
                        row[material_to_ind[gutils.key(material)]] = amount
                    end
                end
                table.insert(matrix, row)
                table.insert(cost_column, constants.simplex_per_resource_cost)
            end
        end
    end

    local goal_row = {}
    for _, material in pairs(material_list) do
        table.insert(goal_row, 0)
    end

    return {
        matrix = matrix,
        cost_column = cost_column,
        goal_row = goal_row,
        material_list = material_list,
        material_to_ind = material_to_ind,
    }
end

simplex_cost.get_material_costs = function()
    local matrix_info = simplex_cost.make_recipe_material_matrix()

    log("Constructing matrix")
    local lp = sparse_simplex.new(matrix_info.matrix, matrix_info.cost_column, #matrix_info.material_list)
    log("#Materials: " .. tostring(#matrix_info.material_list))
    local material_to_cost = {}



    -- DEBUGGING: Try iron plate first since we know that should be easier
    do
        local i = matrix_info.material_to_ind[gutils.key("item", "iron-plate")]
        local material = { type = "item", name = "iron-plate" }
        log("Calculating material #" .. tostring(i) .. " cost of " .. material.name)

        local target_col = matrix_info.material_to_ind[gutils.key(material)]
        local solve_info = sparse_simplex.solve_unit_objective(lp, target_col)

        log(
            "Calculated status=" .. tostring(solve_info.status)
            .. " objective=" .. tostring(solve_info.objective)
            .. " current_objective=" .. tostring(solve_info.current_objective)
            .. " pivots=" .. tostring(solve_info.pivots)
            .. " entering_col=" .. tostring(solve_info.entering_col)
        )

        if solve_info.status == "optimal" then
            material_to_cost[gutils.key(material)] = solve_info.objective
        else
            material_to_cost[gutils.key(material)] = nil
        end
    end




    for i, material in pairs(matrix_info.material_list) do
        log("Calculating material #" .. tostring(i) .. " cost of " .. material.name)

        local target_col = matrix_info.material_to_ind[gutils.key(material)]
        local solve_info = sparse_simplex.solve_unit_objective(lp, target_col)

        log(
            "Calculated status=" .. tostring(solve_info.status)
            .. " objective=" .. tostring(solve_info.objective)
            .. " current_objective=" .. tostring(solve_info.current_objective)
            .. " pivots=" .. tostring(solve_info.pivots)
            .. " entering_col=" .. tostring(solve_info.entering_col)
        )

        if solve_info.status == "optimal" then
            material_to_cost[gutils.key(material)] = solve_info.objective
        else
            material_to_cost[gutils.key(material)] = nil
        end
    end
    return material_to_cost

    --[=[local matrix_info = simplex_cost.make_recipe_material_matrix()

    local material_to_cost = {}
    log("#Materials: " .. tostring(#matrix_info.material_list))
    for i, material in pairs(matrix_info.material_list) do
        log("Calculating material #" .. tostring(i) .. " cost of " .. material.name)

        local curr_matrix = table.deepcopy(matrix_info.matrix)
        local curr_goal_row = table.deepcopy(matrix_info.goal_row)
        local curr_cost_column = table.deepcopy(matrix_info.cost_column)
        curr_goal_row[matrix_info.material_to_ind[gutils.key(material)]] = 1

        local solve_info = simplex.solve_in_place(curr_matrix, curr_cost_column, curr_goal_row)
        material_to_cost[gutils.key(material)] = solve_info.objective
    end

    return material_to_cost]=]
end

return simplex_cost