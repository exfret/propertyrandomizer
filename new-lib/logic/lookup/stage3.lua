-- Stage 3: Complex lookups (depends on stage 2)
-- These are computationally expensive or have complex dependencies

local stage0 = require("new-lib/logic/lookup/stage0")
local pairs = stage0.pairs

local stage3 = {}

-- Maps asteroid entity names to their resistance group key
-- NOTE: Fixed duplicate definition bug - this now appears only once
stage3.asteroid_resistance_groups = function(lu, req)
    local asteroid_resistance_groups = {}
    local prots = req.prots

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
-- OPTIMIZED: Inverted loop structure for ~25x speedup
-- Instead of O(rcats × machines), we do O(machines) with hash lookups
stage3.rcat_to_crafters = function(lu, req)
    local rcat_to_crafters = {}
    local prots = req.prots

    -- Initialize for all rcats
    for rcat_name, _ in pairs(lu.rcats) do
        rcat_to_crafters[rcat_name] = {}
    end

    -- Pre-compute rcat lookup by base category
    -- This allows O(1) lookup instead of iterating all rcats
    local rcats_by_cat = {}
    for rcat_name, rcat in pairs(lu.rcats) do
        if rcats_by_cat[rcat.cat] == nil then
            rcats_by_cat[rcat.cat] = {}
        end
        rcats_by_cat[rcat.cat][rcat_name] = rcat
    end

    -- Iterate machines ONCE, find all compatible rcats per machine
    for _, class in pairs({"assembling-machine", "furnace", "rocket-silo", "character"}) do
        for _, machine in pairs(prots(class)) do
            if machine.crafting_categories ~= nil then
                -- Count machine fluid boxes ONCE per machine (not per rcat!)
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

                -- Only check rcats matching machine's crafting_categories
                for _, category in pairs(machine.crafting_categories) do
                    if rcats_by_cat[category] ~= nil then
                        for rcat_name, rcat in pairs(rcats_by_cat[category]) do
                            -- Simple comparison - no function call overhead
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
stage3.mat_recipe_map = function(lu, req)
    local mat_recipe_map = {
        material = {},
        recipe = {},
    }
    local gutils = req.gutils

    for mat_key, mat in pairs(lu.materials) do
        mat_recipe_map.material[mat_key] = {
            ingredients = {},
            results = {},
        }
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
                    local prod_key = gutils.key(prod)
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
                    end
                end
            end
        end
    end

    lu.mat_recipe_map = mat_recipe_map
end

-- Material to minable thing mapping
stage3.mat_mining_map = function(lu, req)
    local mat_mining_map = {
        to_minable = {},
        to_material = {},
    }
    local prots = req.prots
    local gutils = req.gutils

    for mat_key, mat in pairs(lu.materials) do
        mat_mining_map.to_minable[mat_key] = {}
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

return stage3
