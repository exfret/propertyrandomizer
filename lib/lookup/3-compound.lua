local gutils = require("lib/graph/graph-utils")
local dutils = require("lib/data-utils")

local prots = dutils.prots

local stage = {}

local lu
stage.link = function(lu_to_link)
    lu = lu_to_link
end

-- Maps asteroid entity names to their resistance group key
stage.asteroid_resistance_groups = function()
    local asteroid_resistance_groups = {}

    for _, asteroid in pairs(prots("asteroid")) do
        -- Only include if asteroid is in lu.entities
        if lu.entities[asteroid.name] ~= nil then
            local group_key = lu.entity_resistance_groups.to_resistance[asteroid.name]
            if group_key ~= nil then
                asteroid_resistance_groups[asteroid.name] = group_key
            end
        end
    end

    lu.asteroid_resistance_groups = asteroid_resistance_groups
end

-- Maps spoofed recipe categories (rcat names) to entities that can craft them
stage.rcat_to_crafters = function()
    local rcat_to_crafters = {}

    for rcat_name, _ in pairs(lu.rcats) do
        rcat_to_crafters[rcat_name] = {}
    end

    -- Pre-compute rcat lookup by base category
    local rcats_by_cat = {}
    for rcat_name, rcat in pairs(lu.rcats) do
        for _, cat in pairs(rcat.cats) do
            if rcats_by_cat[cat] == nil then
                rcats_by_cat[cat] = {}
            end
            rcats_by_cat[cat][rcat_name] = rcat
        end
    end

    for _, class in pairs({"assembling-machine", "furnace", "rocket-silo", "character"}) do
        for _, machine in pairs(prots(class)) do
            if machine.crafting_categories ~= nil then
                -- Count machine fluid boxes once per machine (not per rcat!)
                local machine_fluids = {input = 0, output = 0}
                if machine.fluid_boxes ~= nil then
                    for _, fluid_box in pairs(machine.fluid_boxes) do
                        if fluid_box.production_type == "input" then
                            machine_fluids.input = machine_fluids.input + 1
                        elseif fluid_box.production_type == "output" then
                            machine_fluids.output = machine_fluids.output + 1
                        end
                    end
                end

                for _, category in pairs(machine.crafting_categories) do
                    if rcats_by_cat[category] ~= nil then
                        for rcat_name, rcat in pairs(rcats_by_cat[category]) do
                            if machine_fluids.input >= rcat.input and machine_fluids.output >= rcat.output then
                                rcat_to_crafters[rcat_name][machine.name] = true
                            end
                        end
                    end
                end
            end
        end
    end

    lu.rcat_to_crafters = rcat_to_crafters
end

-- Bidirectional material-recipe mapping
stage.mat_recipe_map = function()
    local mat_recipe_map = {
        material = {},
        recipe = {},
    }
    local temp_ranges = {}
    for _, fluid in pairs(lu.fluids) do
        temp_ranges[fluid.name] = {}
    end

    for mat_key, mat in pairs(lu.materials) do
        if mat.type == "fluid" then
            for _, temp in pairs(lu.fluid_temperatures_ordered[mat.name]) do
                -- This secretly relies on the associativity of the gutils.key function
                local real_key = gutils.key(mat_key, tostring(temp))
                mat_recipe_map.material[real_key] = {
                    ingredients = {},
                    results = {},
                }
            end
        else
            mat_recipe_map.material[mat_key] = {
                ingredients = {},
                results = {},
            }
        end
    end

    for _, recipe in pairs(lu.recipes) do
        mat_recipe_map.recipe[recipe.name] = {
            ingredients = {},
            results = {},
        }

        for _, prop in pairs({"ingredients", "results"}) do
            if recipe[prop] ~= nil then
                for ind, prod in pairs(recipe[prop]) do
                    local recipe_map = mat_recipe_map.recipe[recipe.name][prop]
                    local name_key = prod.name
                    local min_temperature
                    local max_temperature
                    if prod.type == "fluid" then
                        if prop == "results" then
                            local fluid_prot = data.raw.fluid[prod.name]
                            name_key = gutils.key(prod.name, prod.temperature or fluid_prot.default_temperature)
                        elseif prop == "ingredients" then
                            min_temperature = prod.temperature or prod.minimum_temperature or "nil"
                            max_temperature = prod.temperature or prod.maximum_temperature or "nil"
                            temp_ranges[prod.name][gutils.key(min_temperature, max_temperature)] = true
                            name_key = gutils.key(prod.name, gutils.key(min_temperature, max_temperature))
                        end
                    end
                    local prod_key = gutils.key(prod.type, name_key)
                    local mat_map = mat_recipe_map.material[prod_key]

                    if mat_map ~= nil then
                        if recipe_map[prod_key] == nil then
                            recipe_map[prod_key] = {}
                        end
                        if mat_map[prop][recipe.name] == nil then
                            mat_map[prop][recipe.name] = {}
                        end
                        recipe_map[prod_key][ind] = true
                        mat_map[prop][recipe.name][ind] = true
                    elseif min_temperature ~= nil then
                        -- Recipe map just gets prod key/range raw
                        if recipe_map[prod_key] == nil then
                            recipe_map[prod_key] = {}
                        end
                        recipe_map[prod_key][ind] = true
                        -- But testing for a specific material involves the fluid
                        for _, temp in pairs(lu.fluid_temperatures_ordered[prod.name]) do
                            if min_temperature == "nil" or tonumber(min_temperature) <= temp then
                                if max_temperature == "nil" or tonumber(max_temperature) >= temp then
                                    mat_map = mat_recipe_map.material[gutils.key("fluid", gutils.key(prod.name, temp))]
                                    if mat_map[prop][recipe.name] == nil then
                                        mat_map[prop][recipe.name] = {}
                                    end
                                    mat_map[prop][recipe.name][ind] = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    lu.temp_ranges = temp_ranges
    lu.mat_recipe_map = mat_recipe_map
end

-- Material to minable thing mapping
stage.mat_mining_map = function()
    local mat_mining_map = {
        to_minable = {},
        to_material = {},
    }

    for mat_key, mat in pairs(lu.materials) do
        if mat.type == "fluid" then
            for _, temp in pairs(lu.fluid_temperatures_ordered[mat.name]) do
                -- This secretly relies on the associativity of the gutils.key function
                local real_key = gutils.key(mat_key, tostring(temp))
                mat_mining_map.to_minable[real_key] = {}
            end
        else
            mat_mining_map.to_minable[mat_key] = {}
        end
    end

    local function add_minable(minable_thing, minable_key)
        mat_mining_map.to_material[minable_key] = {}

        local minable = minable_thing.minable
        if minable ~= nil then
            local minable_results = minable.results
            if minable_results == nil and minable.result ~= nil then
                minable_results = {{type = "item", name = minable.result, amount = minable.count or 1}}
            end
            for ind, result in pairs(minable_results or {}) do
                local result_key = gutils.key(result)
                if result.type == "fluid" then
                    local fluid = data.raw.fluid[result.name]
                    result_key = gutils.key(result_key, tostring(result.temperature or fluid.default_temperature))
                end
                local to_material_map = mat_mining_map.to_material[minable_key]
                local to_minable_map = mat_mining_map.to_minable[result_key]

                if to_minable_map ~= nil then
                    if to_material_map[result_key] == nil then
                        to_material_map[result_key] = {}
                    end
                    if to_minable_map[minable_key] == nil then
                        to_minable_map[minable_key] = {}
                    end
                    to_material_map[result_key][ind] = true
                    to_minable_map[minable_key][ind] = true
                end
            end
        end
    end

    for _, entity in pairs(lu.entities) do
        add_minable(entity, gutils.key("entity-mine", entity.name))
    end
    for _, tile in pairs(prots("tile")) do
        add_minable(tile, gutils.key("tile-mine", tile.name))
    end
    for _, chunk in pairs(prots("asteroid-chunk")) do
        add_minable(chunk, gutils.key("asteroid-chunk-mine", chunk.name))
    end

    lu.mat_mining_map = mat_mining_map
end

-- Recipe cats made in some furnace prototype
stage.smelting_rcats = function()
    local smelting_rcats = {}

    for _, furnace in pairs(prots("furnace")) do
        for _, category in pairs(furnace.crafting_categories) do
            for rcat, _ in pairs(lu.vanilla_to_rcats[category] or {}) do
                smelting_rcats[rcat] = true
            end
        end
    end

    lu.smelting_rcats = smelting_rcats
end

-- Maps science pack set names to labs that can accept ALL packs in the set
stage.science_set_to_labs = function()
    local science_set_to_labs = {}

    local lab_inputs_sets = {}
    for _, lab in pairs(prots("lab")) do
        lab_inputs_sets[lab.name] = {}
        for _, input in pairs(lab.inputs) do
            lab_inputs_sets[lab.name][input] = true
        end
    end

    for set_name, set_packs in pairs(lu.science_sets) do
        science_set_to_labs[set_name] = {}

        for _, lab in pairs(prots("lab")) do
            local lab_inputs_set = lab_inputs_sets[lab.name]

            local lab_can_hold_all = true
            for _, pack in pairs(set_packs) do
                if not lab_inputs_set[pack] then
                    lab_can_hold_all = false
                    break
                end
            end

            if lab_can_hold_all then
                science_set_to_labs[set_name][lab.name] = true
            end
        end
    end

    lu.science_set_to_labs = science_set_to_labs
end

return stage
