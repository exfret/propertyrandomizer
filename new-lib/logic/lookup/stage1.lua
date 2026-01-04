-- Stage 1: Raw prototype collections (no dependencies on other lookups)
-- These iterate over data.raw or defines.prototypes directly

local stage0 = require("new-lib/logic/lookup/stage0")
local pairs = stage0.pairs
local table_insert = stage0.table_insert
local table_sort = stage0.table_sort

local stage1 = {}

-- Rooms are places that you can be (planets and surfaces)
stage1.rooms = function(lu, req)
    local rooms = {}
    local prots = req.prots
    local gutils = req.gutils

    for _, class in pairs({"planet", "surface"}) do
        for prot_name, prot in pairs(prots(class)) do
            rooms[gutils.key(prot)] = {
                type = class,
                name = prot_name,
            }
        end
    end

    lu.rooms = rooms
end

-- Space places are places that a surface (the prototype) can be
stage1.space_places = function(lu, req)
    local space_places = {}
    local prots = req.prots
    local gutils = req.gutils

    for class, _ in pairs(defines.prototypes["space-location"]) do
        for _, location in pairs(prots(class)) do
            space_places[gutils.key(location)] = {
                type = location.type,
                name = location.name,
            }
        end
    end
    for _, conn in pairs(prots("space-connection")) do
        space_places[gutils.key(conn)] = {
            type = conn.type,
            name = conn.name,
        }
    end

    lu.space_places = space_places
end

-- Mining categories (spoofed with fluid counts)
stage1.mcats = function(lu, req)
    local mcats = {}
    local lutils = req.lutils

    for _, resource in pairs(data.raw.resource) do
        local name = lutils.mcat_name(resource)
        if mcats[name] == nil then
            local fluids = lutils.find_mining_fluids(resource)

            mcats[name] = {
                cat = resource.category or "basic-solid",
                input = fluids.input,
                output = fluids.output,
            }
        end
    end

    lu.mcats = mcats
end

-- Get science pack sets (collection of science packs that appear together in a tech)
stage1.science_sets = function(lu, req)
    local science_sets = {}
    local gutils = req.gutils

    for _, tech in pairs(data.raw.technology) do
        if tech.unit ~= nil then
            local set = {}
            for _, ing in pairs(tech.unit.ingredients) do
                table_insert(set, ing[1])
            end
            table_sort(set)
            science_sets[gutils.concat(set)] = set
        end
    end

    lu.science_sets = science_sets
end

-- Note: Only gets "relevant" entities for logic; filters corpses without minable
stage1.entities = function(lu, req)
    local entities = {}
    local prots = req.prots
    local categories = req.categories

    for class, _ in pairs(defines.prototypes.entity) do
        if class ~= "explosion" and class ~= "smoke-with-trigger" then
            for _, entity in pairs(prots(class)) do
                -- Check only minable corpses
                if not categories.corpse[entity.type] or entity.minable ~= nil then
                    entities[entity.name] = entity
                end
            end
        end
    end

    lu.entities = entities
end

stage1.equipment = function(lu, req)
    local equipment = {}
    local prots = req.prots

    for class, _ in pairs(defines.prototypes.equipment) do
        for _, prot in pairs(prots(class)) do
            equipment[prot.name] = prot
        end
    end

    lu.equipment = equipment
end

stage1.items = function(lu, req)
    local items = {}
    local prots = req.prots

    for class, _ in pairs(defines.prototypes.item) do
        for _, item in pairs(prots(class)) do
            items[item.name] = item
        end
    end

    lu.items = items
end

stage1.fluids = function(lu, req)
    local fluids = {}
    local prots = req.prots

    for _, fluid in pairs(prots("fluid")) do
        fluids[fluid.name] = fluid
    end

    lu.fluids = fluids
end

-- All recipes (including hidden for recycling compatibility)
stage1.recipes = function(lu, req)
    local recipes = {}
    local prots = req.prots

    for _, recipe in pairs(prots("recipe")) do
        recipes[recipe.name] = recipe
    end

    lu.recipes = recipes
end

-- Non-hidden technologies
stage1.techs = function(lu, req)
    local techs = {}
    local prots = req.prots

    for _, tech in pairs(prots("technology")) do
        if not tech.hidden then
            techs[tech.name] = tech
        end
    end

    lu.techs = techs
end

-- Tiles grouped by collision layers
stage1.tile_collision_groups = function(lu, req)
    local tile_collision_groups = {}
    local tile_collision_group_to_layers = {}
    local prots = req.prots
    local gutils = req.gutils

    for _, tile in pairs(prots("tile")) do
        local collision_layers = {}
        for layer, _ in pairs(tile.collision_mask.layers) do
            table_insert(collision_layers, layer)
        end
        table_sort(collision_layers)
        local layers_key = gutils.concat(collision_layers)
        if tile_collision_groups[layers_key] == nil then
            tile_collision_groups[layers_key] = {}
        end
        if tile_collision_group_to_layers[layers_key] == nil then
            tile_collision_group_to_layers[layers_key] = tile.collision_mask.layers
        end
        tile_collision_groups[layers_key][tile.name] = true
    end

    lu.tile_collision_groups = tile_collision_groups
    lu.tile_collision_group_to_layers = tile_collision_group_to_layers
end

stage1.unit_spawner_captures = function(lu, req)
    local unit_spawner_captures = {}
    local prots = req.prots

    for _, spawner in pairs(prots("unit-spawner")) do
        if spawner.captured_spawner_entity ~= nil then
            if unit_spawner_captures[spawner.captured_spawner_entity] == nil then
                unit_spawner_captures[spawner.captured_spawner_entity] = {}
            end
            table_insert(unit_spawner_captures[spawner.captured_spawner_entity], spawner)
        end
    end

    lu.unit_spawner_captures = unit_spawner_captures
end

-- Maps space-locations to the space-connections that touch them
-- space_location_name -> { connection_name -> "from" | "to" }
stage1.space_location_to_connections = function(lu, req)
    local space_location_to_connections = {}
    local prots = req.prots

    for _, conn in pairs(prots("space-connection")) do
        for _, endpoint in pairs({"from", "to"}) do
            local loc_name = conn[endpoint]
            if space_location_to_connections[loc_name] == nil then
                space_location_to_connections[loc_name] = {}
            end
            space_location_to_connections[loc_name][conn.name] = endpoint
        end
    end

    lu.space_location_to_connections = space_location_to_connections
end

-- Maps surface prototypes to starter packs that create them
-- surface_name -> { item_name -> true }
stage1.surface_to_starter_packs = function(lu, req)
    local surface_to_starter_packs = {}
    local prots = req.prots

    for _, item in pairs(prots("space-platform-starter-pack")) do
        if item.surface ~= nil then
            if surface_to_starter_packs[item.surface] == nil then
                surface_to_starter_packs[item.surface] = {}
            end
            surface_to_starter_packs[item.surface][item.name] = true
        end
    end

    lu.surface_to_starter_packs = surface_to_starter_packs
end

----------------------------------------------------------------------
-- NEW: Pre-computed autoplace control to prototype mapping
-- This is the key optimization for check_in_room
----------------------------------------------------------------------
stage1.autoplace_control_to_prots = function(lu, req)
    local control_to_prots = {
        tile = {},
        entity = {},
    }
    local prots = req.prots

    -- Tiles: O(tiles)
    for _, tile in pairs(prots("tile")) do
        if tile.autoplace ~= nil and tile.autoplace.control ~= nil then
            local ctrl = tile.autoplace.control
            if control_to_prots.tile[ctrl] == nil then
                control_to_prots.tile[ctrl] = {}
            end
            control_to_prots.tile[ctrl][tile.name] = true
        end
    end

    -- Entities: O(entities) - iterate all entity classes
    for class, _ in pairs(defines.prototypes.entity) do
        for _, entity in pairs(prots(class)) do
            if entity.autoplace ~= nil and entity.autoplace.control ~= nil then
                local ctrl = entity.autoplace.control
                if control_to_prots.entity[ctrl] == nil then
                    control_to_prots.entity[ctrl] = {}
                end
                control_to_prots.entity[ctrl][entity.name] = true
            end
        end
    end

    lu.autoplace_control_to_prots = control_to_prots
end

----------------------------------------------------------------------
-- MOVED from Stage 2: These don't depend on any stage 1 lookups
----------------------------------------------------------------------

-- Maps base resource category to spoofed categories that exist (from actual resources)
-- base_mcat -> { spoofed_mcat -> true }
stage1.mcat_to_mcats = function(lu, req)
    local mcat_to_mcats = {}
    local prots = req.prots
    local lutils = req.lutils

    for _, resource in pairs(prots("resource")) do
        if resource.minable ~= nil then
            local base_cat = resource.category or "basic-solid"
            local spoofed_key = lutils.mcat_name(resource)

            if mcat_to_mcats[base_cat] == nil then
                mcat_to_mcats[base_cat] = {}
            end
            mcat_to_mcats[base_cat][spoofed_key] = true
        end
    end

    lu.mcat_to_mcats = mcat_to_mcats
end

-- Maps fluids to tiles that have them
stage1.fluid_to_tiles = function(lu, req)
    local fluid_to_tiles = {}
    local prots = req.prots

    for _, tile in pairs(prots("tile")) do
        if tile.fluid ~= nil then
            if fluid_to_tiles[tile.fluid] == nil then
                fluid_to_tiles[tile.fluid] = {}
            end
            fluid_to_tiles[tile.fluid][tile.name] = true
        end
    end

    lu.fluid_to_tiles = fluid_to_tiles
end

-- Maps fluids to offshore pumps that have a filter for that fluid
-- These pumps always produce this fluid regardless of tile
stage1.pumps_with_filter = function(lu, req)
    local pumps_with_filter = {}
    local prots = req.prots

    for _, pump in pairs(prots("offshore-pump")) do
        if pump.fluid_box.filter ~= nil then
            local fluid_name = pump.fluid_box.filter
            if pumps_with_filter[fluid_name] == nil then
                pumps_with_filter[fluid_name] = {}
            end
            pumps_with_filter[fluid_name][pump.name] = true
        end
    end

    lu.pumps_with_filter = pumps_with_filter
end

-- Maps equipment categories to grids that support them
stage1.category_to_grids = function(lu, req)
    local category_to_grids = {}
    local prots = req.prots

    for _, grid in pairs(prots("equipment-grid")) do
        for _, cat in pairs(grid.equipment_categories) do
            if category_to_grids[cat] == nil then
                category_to_grids[cat] = {}
            end
            category_to_grids[cat][grid.name] = true
        end
    end

    lu.category_to_grids = category_to_grids
end

return stage1
