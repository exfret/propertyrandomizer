local constants = require("helper-tables/constants")
local cutils = require("lib/cost/cost-utils")
local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")

local prots = dutils.prots

local simplex_cost = {}

-- Also computes recipe cost column and material amount row
simplex_cost.make_recipe_material_matrix = function(sort_info)
    local function reachable(node_type, node_name)
        if sort_info == nil then
            return true
        end
        return next(sort_info.node_to_context_inds[gutils.key(node_type, node_name)]) ~= nil
    end

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

    -- Find canonical building for a given recipe
    -- Assume crafting speeds are all 1 so I don't have to deal specially with py al buildings
    local recipe_to_building = {}
    for _, recipe in pairs(prots("recipe")) do
        for _, crafting_class in pairs({"furnace", "assembling-machine"}) do
            for _, machine in pairs(data.raw[crafting_class]) do
                -- Don't consider fluid boxes now, just category
                local matching = false
                for _, recipe_cat in pairs(recipe.categories or {"crafting"}) do
                    for _, machine_cat in pairs(machine.crafting_categories) do
                        if recipe_cat == machine_cat then
                            matching = true
                            break
                        end
                    end
                    if matching == true then
                        break
                    end
                end
                if matching then
                end
            end
        end
    end

    local matrix = {}
    local cost_column = {}
    local row_sources = {}
    local recipe_ingredient_amounts = {}
    local recipe_result_amounts = {}

    for _, recipe in pairs(recipe_list) do
        if reachable("recipe", recipe.name) then
            local row = {}
            local ing_row = {}
            local result_row = {}
            local relevant_materials = {}
            for _, ing in pairs(recipe.ingredients or {}) do
                relevant_materials[gutils.key(ing)] = ing
            end
            for _, result in pairs(recipe.results or {}) do
                relevant_materials[gutils.key(result)] = result
            end
            for _, material in pairs(relevant_materials) do
                -- TODO: Implement productivity amounts
                -- This might be fine since the bigger issue is something necessary that's cheap being regarded as expensive, and not being given in high enough amounts
                -- Not paying attention to productivity instead can regard late-game/expensive things as more expensive, but they were expensive anyways
                local amount = cutils.find_amount_in_recipe(recipe, material, nil, nil, {producivity = 0})
                if amount ~= 0 then
                    row[material_to_ind[gutils.key(material)]] = amount
                end
                local ing_amount = cutils.find_amount_in_ing_or_prod(recipe.ingredients or {}, material)
                if ing_amount ~= 0 then
                    ing_row[material_to_ind[gutils.key(material)]] = ing_amount
                end
                local result_amount = cutils.find_amount_in_ing_or_prod(recipe.results or {}, material)
                if result_amount ~= 0 then
                    result_row[material_to_ind[gutils.key(material)]] = result_amount
                end
            end

            table.insert(matrix, row)
            recipe_ingredient_amounts[#matrix] = ing_row
            recipe_result_amounts[#matrix] = result_row

            local additional_cost = constants.simplex_per_recipe_cost + (recipe.energy_required or 0.5) * constants.simplex_per_second_cost

            table.insert(cost_column, additional_cost)

            table.insert(row_sources, {
                type = "recipe",
                name = recipe.name,
            })
        end
    end
    -- Offshore pumps/tiles fluid
    for _, pump in pairs(prots("offshore-pump")) do
        if reachable("entity-operate", pump.name) then
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
                table.insert(row_sources, {
                    type = "offshore-pump",
                    name = pump.name,
                })
            end
        end
    end
    for _, tile in pairs(prots("tile")) do
        if tile.fluid ~= nil then
            if reachable("tile-fluid", tile.name) then
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
                table.insert(row_sources, {
                    type = "tile-fluid",
                    name = tile.name,
                })
            end
        end
    end
    -- Boiler
    for _, boiler in pairs(prots("boiler")) do
        if reachable("entity-operate", boiler.name) then
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
                table.insert(row_sources, {
                    type = "boiler",
                    name = boiler.name,
                })
            end
        end
    end
    -- Burnt results
    for item_class, _ in pairs(defines.prototypes.item) do
        for _, item in pairs(data.raw[item_class] or {}) do
            if item.fuel_category ~= nil and item.burnt_result ~= nil and item.burnt_result ~= "" then
                if reachable("item-burn", item.name) then
                    local row = {}
                    row[material_to_ind[gutils.key("item", item.name)]] = -1
                    for _, material in pairs(material_list) do
                        if material.type == "item" and material.name == item.burnt_result then
                            row[material_to_ind[gutils.key(material)]] = 1
                        end
                    end
                    table.insert(matrix, row)
                    table.insert(cost_column, constants.simplex_burnt_cost)
                    table.insert(row_sources, {
                        type = "burnt-result",
                        name = item.name,
                    })
                end
            end
        end
    end
    -- Rocket launch results
    for item_class, _ in pairs(defines.prototypes.item) do
        for _, item in pairs(data.raw[item_class] or {}) do
            if item.rocket_launch_products ~= nil then
                -- Assumes the item itself is not in its own results
                if reachable("item-launch", item.name) then
                    local row = {}
                    local relevant_mats = {}
                    for _, result in pairs(item.rocket_launch_products) do
                        relevant_mats[gutils.key(result)] = result
                    end
                    for _, material in pairs(relevant_mats) do
                        row[material_to_ind[gutils.key(material)]] = cutils.find_amount_in_ing_or_prod(item.rocket_launch_products, material)
                    end
                    row[material_to_ind[gutils.key("item", item.name)]] = -1
                    -- Only one silo in py, thankfully
                    row[material_to_ind[gutils.key("item", "rocket-part")]] = -data.raw["rocket-silo"]["rocket-silo"].rocket_parts_required
                    table.insert(matrix, row)
                    table.insert(cost_column, 0)
                    table.insert(row_sources, {
                        type = "rocket-launch-results",
                        name = item.name,
                    })
                end
            end
        end
    end
    -- Resource/asteroid chunk/plant mining
    for _, resource_type in pairs({"resource", "plant", "asteroid-chunk"}) do
        for _, resource in pairs(prots(resource_type)) do
            if (resource_type == "asteroid-chunk" and reachable("asteroid-chunk-mine", resource.name)) or (resource_type ~= "asteroid-chunk" and reachable("entity-mine", resource.name)) then
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
                                -- I don't know why the actual amount is divided by 10 but whatever
                                amount = amount - (minable.fluid_amount or 0) / 10
                            end
                            amount = amount + cutils.find_amount_in_ing_or_prod(results, material)
                            --table.insert(row, amount)
                            if amount ~= 0 then
                                row[material_to_ind[gutils.key(material)]] = amount
                            end
                        end
                        table.insert(matrix, row)
                        table.insert(cost_column, constants.simplex_per_resource_cost)
                        table.insert(row_sources, {
                            type = resource_type,
                            name = resource.name,
                        })
                    end
                end
            end
        end
    end

    local goal_row = {}
    for _, material in pairs(material_list) do
        table.insert(goal_row, 0)
    end

    local packs_in_order = {
        "automation-science-pack",
        "py-science-pack-1",
        "logistic-science-pack",
        "military-science-pack",
        "py-science-pack-2",
        "chemical-science-pack",
        "py-science-pack-3",
        "production-science-pack",
        "py-science-pack-4",
        "utility-science-pack",
        "space-science-pack",
    }
    local pack_level_to_packs = {}
    for ind, pack in pairs(packs_in_order) do
        -- Find a tech at this pack level
        local allowed_packs = {}
        for ind2, pack2 in pairs(packs_in_order) do
            if ind2 <= ind then
                allowed_packs[pack2] = true
            else
                break
            end
        end
        for _, tech in pairs(data.raw.technology) do
            if tech.unit ~= nil then
                local valid_tech = false
                for _, ing in pairs(tech.unit.ingredients) do
                    if ing[1] == pack then
                        valid_tech = true
                    end
                    if not allowed_packs[ing[1]] then
                        valid_tech = false
                        break
                    end
                end
                if valid_tech then
                    -- Give ingredients of this technology for research, in format like
                    -- {
                    --   {"automation-science-pack", 2},
                    --   {"py-science-pack-1", 1}
                    -- }
                    table.insert(pack_level_to_packs, tech.unit.ingredients)
                    break
                end
            end
        end
    end

    log("FINISHED SIMPLEX COST BUILDING")

    return {
        matrix = matrix,
        cost_column = cost_column,
        row_sources = row_sources,
        goal_row = goal_row,
        material_list = material_list,
        material_to_ind = material_to_ind,
        pack_level_to_packs = pack_level_to_packs,
        recipe_ingredient_amounts = recipe_ingredient_amounts,
        recipe_result_amounts = recipe_result_amounts,
        is_pyanodons = mods["pyalternativeenergy"],
        packs_in_order = packs_in_order,
    }
end

return simplex_cost