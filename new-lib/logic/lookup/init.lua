-- Lookup tables for commonly used correspondences
-- Reorganized into 5 stages for clarity and maintainability
--
-- Stage 0: Constants and localized globals (setup, no lookups)
-- Stage 1: Raw prototype collections (no dependencies)
-- Stage 2: Filtered/processed collections (depends on stage 1)
-- Stage 3: Complex lookups (depends on stage 2)
-- Stage 4: Derived calculations (depends on stage 3)

local lib_name = "new-lib" -- Use this until integration with "old" lib

-- Load stage modules
local stage0 = require(lib_name .. "/logic/lookup/stage0")
local stage1 = require(lib_name .. "/logic/lookup/stage1")
local stage2 = require(lib_name .. "/logic/lookup/stage2")
local stage3 = require(lib_name .. "/logic/lookup/stage3")
local stage4 = require(lib_name .. "/logic/lookup/stage4")

-- Initialize shared requires once
local req = stage0.init_requires(lib_name)

-- The lookup table that will be populated
local lu = {}

-- Stage definitions with names for profiling
-- TODO: Undo this ugly table
-- TODO: No wait the whole code is horrifyingly ugly, need to clean this up too... ugh
local stages = {
    [1] = {
        {"rooms", stage1.rooms},
        {"space_places", stage1.space_places},
        {"mcats", stage1.mcats},
        {"science_sets", stage1.science_sets},
        {"entities", stage1.entities},
        {"equipment", stage1.equipment},
        {"items", stage1.items},
        {"fluids", stage1.fluids},
        {"recipes", stage1.recipes},
        {"techs", stage1.techs},
        {"tile_collision_groups", stage1.tile_collision_groups},
        {"unit_spawner_captures", stage1.unit_spawner_captures},
        {"space_location_to_connections", stage1.space_location_to_connections},
        {"surface_to_starter_packs", stage1.surface_to_starter_packs},
        {"autoplace_control_to_prots", stage1.autoplace_control_to_prots},
        {"mcat_to_mcats", stage1.mcat_to_mcats},
        {"fluid_to_tiles", stage1.fluid_to_tiles},
        {"pumps_with_filter", stage1.pumps_with_filter},
        {"category_to_grids", stage1.category_to_grids},
    },
    [2] = {
        {"entity_collision_groups", stage2.entity_collision_groups},
        {"connection_asteroids", stage2.connection_asteroids},
        {"asteroid_to_place", stage2.asteroid_to_place},
        {"equipment_to_items", stage2.equipment_to_items},
        {"equipment_grid_sources", stage2.equipment_grid_sources},
        {"grid_to_sources", stage2.grid_to_sources},
        {"grid_power_sources", stage2.grid_power_sources},
        {"damage_type_sources", stage2.damage_type_sources},
        {"entity_resistance_groups", stage2.entity_resistance_groups},
        {"ammo_category_sources", stage2.ammo_category_sources},
        {"science_set_to_labs", stage2.science_set_to_labs},
        {"space_platform_unlock_techs", stage2.space_platform_unlock_techs},
        {"recipe_to_techs", stage2.recipe_to_techs},
        {"space_location_to_discovery_techs", stage2.space_location_to_discovery_techs},
        {"recipe_subgroup", stage2.recipe_subgroup},
        {"rcats", stage2.rcats},
        {"cat_to_rcats", stage2.cat_to_rcats},
        {"fcat_to_items", stage2.fcat_to_items},
        {"fcat_combos", stage2.fcat_combos},
        {"fcat_to_burners", stage2.fcat_to_burners},
        {"mcat_to_drills", stage2.mcat_to_drills},
        {"spoil_result_to_items", stage2.spoil_result_to_items},
        {"burnt_result_to_items", stage2.burnt_result_to_items},
        {"place_as_tile_items", stage2.place_as_tile_items},
        {"tile_valid_pumps", stage2.tile_valid_pumps},
        {"room_tile_maps", stage2.room_tile_maps},
        {"loot_to_entities", stage2.loot_to_entities},
        {"dying_spawns", stage2.dying_spawns},
        {"capsule_spawns", stage2.capsule_spawns},
        {"ammo_spawns", stage2.ammo_spawns},
        {"entity_output_fluids", stage2.entity_output_fluids},
        {"creator_tables", stage2.creator_tables},
        {"buildables", stage2.buildables},
        {"materials", stage2.materials},
        {"minable_corpse", stage2.minable_corpse},
        {"operable_entities", stage2.operable_entities},
    },
    [3] = {
        {"asteroid_resistance_groups", stage3.asteroid_resistance_groups},
        {"rcat_to_crafters", stage3.rcat_to_crafters},
        {"mat_recipe_map", stage3.mat_recipe_map},
        {"mat_mining_map", stage3.mat_mining_map},
    },
    [4] = {
        {"weight", stage4.weight},
    },
}

-- Load all lookups in stage order
lu.load_lookups = function()
    for stage_num = 1, #stages do
        for _, entry in ipairs(stages[stage_num]) do
            entry[2](lu, req)
        end
    end
end

-- Load lookups with per-stage timing (uses Factorio log timestamps)
lu.load_lookups_timed = function()
    log("=== Lookup Loading Started ===")

    for stage_num = 1, #stages do
        log("STAGE " .. stage_num .. " START (" .. #stages[stage_num] .. " lookups)")
        for _, entry in ipairs(stages[stage_num]) do
            local name, loader = entry[1], entry[2]
            if stage_num == 2 then
                log("  [2] " .. name .. " ...")
            end
            loader(lu, req)
            if stage_num == 2 then
                log("  [2] " .. name .. " done")
            end
        end
        log("STAGE " .. stage_num .. " END")
    end

    log("=== Lookup Loading Complete ===")
end

return lu
