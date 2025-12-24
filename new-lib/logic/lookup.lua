-- Lookup tables for commonly used correspondences, like which recipes produce an item

local categories = require("helper-tables/categories")
local flow_cost = require("lib/graph/flow-cost")
local lib_name = "new-lib" -- Use this until integration with "old" lib
local tutils = require("lib/trigger")
local dutils = require(lib_name .. "/data-utils")
local gutils = require(lib_name .. "/graph/graph-utils")
local lutils = require(lib_name .. "/logic/logic-utils")
local collision_mask_util
if not offline then
    collision_mask_util = require("__core__/lualib/collision-mask-util")
else
    collision_mask_util = require("offline/lualib/collision-mask-util")
end

-- Commonly used
local prots = dutils.prots

local lu = {}

-- Use multi-stage approach so that some lookups can use earlier ones for reference
local stages = {}

----------------------------------------------------------------------
-- Stage 1
----------------------------------------------------------------------

stages[1] = {}

-- Rooms are places that you can be
stages[1].rooms = function()
    local rooms = {}

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
stages[1].space_places = function()
    local space_places = {}

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

stages[1].mcats = function()
    local mcats = {}

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
stages[1].science_sets = function()
    local science_sets = {}

    for _, tech in pairs(data.raw.technology) do
        if tech.unit ~= nil then
            local set = {}
            for _, ing in pairs(tech.unit.ingredients) do
                table.insert(set, ing[1])
            end
            table.sort(set)
            science_sets[gutils.concat(set)] = set
        end
    end

    lu.science_sets = science_sets
end

-- Note: Only gets "relevant" entities for logic; I might build an "all_entities" lookup later if needed
stages[1].entities = function()
    local entities = {}
    
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

stages[1].equipment = function()
    local equipment = {}

    for class, _ in pairs(defines.prototypes.equipment) do
        for _, prot in pairs(prots(class)) do
            equipment[prot.name] = prot
        end
    end

    lu.equipment = equipment
end

stages[1].items = function()
    local items = {}

    for class, _ in pairs(defines.prototypes.item) do
        for _, item in pairs(prots(class)) do
            items[item.name] = item
        end
    end
    
    lu.items = items
end

stages[1].fluids = function()
    local fluids = {}

    for _, fluid in pairs(prots("fluid")) do
        fluids[fluid.name] = fluid
    end
    
    lu.fluids = fluids
end

-- Just filters out hidden recipes
-- EDIT: Nevermind, that prevents recycling recipes from being found
-- TODO: Need to test whether recipe is hidden only for assembling machine types, but not for furnace types... ugh
-- TODO: Compatibility for py TURD hidden recipes
stages[1].recipes = function()
    local recipes = {}

    for _, recipe in pairs(prots("recipe")) do
        --if not recipe.hidden then
            recipes[recipe.name] = recipe
        --end
    end

    lu.recipes = recipes
end

-- Just filters out hidden technologies
-- TODO: Account for enabled too
stages[1].techs = function()
    local techs = {}

    for _, tech in pairs(prots("technology")) do
        if not tech.hidden then
            techs[tech.name] = tech
        end
    end

    lu.techs = techs
end

-- We just look at layers, nothing too fancy
stages[1].tile_collision_groups = function()
    local tile_collision_groups = {}
    local tile_collision_group_to_layers = {}

    for _, tile in pairs(prots("tile")) do
        local collision_layers = {}
        for layer, _ in pairs(tile.collision_mask.layers) do
            table.insert(collision_layers, layer)
        end
        table.sort(collision_layers)
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

stages[1].unit_spawner_captures = function()
    local unit_spawner_captures = {}

    for _, spawner in pairs(prots("unit-spawner")) do
        if spawner.captured_spawner_entity ~= nil then
            if unit_spawner_captures[spawner.captured_spawner_entity] == nil then
                unit_spawner_captures[spawner.captured_spawner_entity] = {}
            end
            table.insert(unit_spawner_captures[spawner.captured_spawner_entity], spawner)
        end
    end

    lu.unit_spawner_captures = unit_spawner_captures
end

-- Maps space-locations to the space-connections that touch them
-- space_location_name -> { connection_name -> "from" | "to" }
stages[1].space_location_to_connections = function()
    local space_location_to_connections = {}

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
stages[1].surface_to_starter_packs = function()
    local surface_to_starter_packs = {}

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
-- Stage 2
----------------------------------------------------------------------

stages[2] = {}

-- Precompute layers that appear for some entity
stages[1].entity_collision_groups = function()
    local entity_collision_groups = {}
    local entity_collision_group_to_layers = {}
    local entity_to_collision_group = {}

    for _, entity in pairs(lu.entities) do
        local collision_layers = {}
        local collision_mask = entity.collision_mask or collision_mask_util.get_default_mask(entity.type)
        for layer, _ in pairs(collision_mask.layers) do
            table.insert(collision_layers, layer)
        end
        table.sort(collision_layers)
        local layers_key = gutils.concat(collision_layers)
        if entity_collision_groups[layers_key] == nil then
            entity_collision_groups[layers_key] = {}
        end
        if entity_collision_group_to_layers[layers_key] == nil then
            entity_collision_group_to_layers[layers_key] = collision_mask.layers
        end
        entity_collision_groups[layers_key][entity.name] = true
        entity_to_collision_group[entity.name] = layers_key
    end

    lu.entity_collision_groups = entity_collision_groups
    lu.entity_collision_group_to_layers = entity_collision_group_to_layers
    lu.entity_to_collision_group = entity_to_collision_group
end

-- Maps space connections to asteroid entities that spawn on them
-- connection_name -> { asteroid_name -> true }
-- Used to determine which resistance groups must be defeated for each connection
stages[2].connection_asteroids = function()
    local connection_asteroids = {}

    for _, conn in pairs(prots("space-connection")) do
        connection_asteroids[conn.name] = {}

        if conn.asteroid_spawn_definitions ~= nil then
            for _, spawn in pairs(conn.asteroid_spawn_definitions) do
                local asteroid_name
                -- Space connections use a special format: {asteroid = name, ...} or {[1] = name}
                if spawn.asteroid ~= nil then
                    asteroid_name = spawn.asteroid
                elseif spawn[1] ~= nil then
                    asteroid_name = spawn[1]
                end
                -- Only include if asteroid is in lu.entities
                if asteroid_name ~= nil and lu.entities[asteroid_name] ~= nil then
                    connection_asteroids[conn.name][asteroid_name] = true
                end
            end
        end
    end

    lu.connection_asteroids = connection_asteroids
end

-- Maps equipment names to items that place them
-- equipment_name -> { item_name -> true }
-- Uses place_as_equipment_result field on items
stages[2].equipment_to_items = function()
    local equipment_to_items = {}

    -- Initialize for all equipment
    for equip_name, _ in pairs(lu.equipment) do
        equipment_to_items[equip_name] = {}
    end

    -- Iterate over items and check place_as_equipment_result
    for item_name, item in pairs(lu.items) do
        if item.place_as_equipment_result ~= nil then
            local equip_name = item.place_as_equipment_result
            if equipment_to_items[equip_name] ~= nil then
                equipment_to_items[equip_name][item_name] = true
            end
        end
    end

    lu.equipment_to_items = equipment_to_items
end

-- Maps damage types to sources that can deal that damage type
-- damage_type -> { source_key -> { amount = number, source_type = string } }
-- source_key is gutils.key format (e.g., "item: railgun-ammo", "entity: laser-turret")
-- source_type is "ammo", "turret", "entity", or "equipment"
-- Note: Only tracks damage sources the player can control (not enemy attacks)
-- Note: Land mines excluded due to offensive drawbacks
stages[2].damage_type_sources = function()
    local damage_type_sources = {}

    -- Initialize for all damage types
    for _, damage in pairs(prots("damage-type")) do
        damage_type_sources[damage.name] = {}
    end

    -- Helper to add a damage source
    local function add_damage_source(damage_type, source_key, amount, source_type)
        if damage_type_sources[damage_type] == nil then
            damage_type_sources[damage_type] = {}
        end
        -- Keep highest damage if source already exists
        if damage_type_sources[damage_type][source_key] == nil or
           damage_type_sources[damage_type][source_key].amount < amount then
            damage_type_sources[damage_type][source_key] = {
                amount = amount,
                source_type = source_type,
            }
        end
    end

    -- Helper to extract damage from structs gathered by trigger library
    local function extract_damage_from_structs(structs, source_key, source_type)
        if structs["damage-parameters"] ~= nil then
            for _, dp in pairs(structs["damage-parameters"]) do
                if dp.type ~= nil and dp.amount ~= nil and dp.amount > 0 then
                    add_damage_source(dp.type, source_key, dp.amount, source_type)
                end
            end
        end
    end

    -- 1. AMMO ITEMS - Primary damage source via ammo_type.action triggers
    for item_name, item in pairs(lu.items) do
        if item.type == "ammo" then
            local structs = {}
            tutils.gather_ammo_structs(structs, item, nil)
            extract_damage_from_structs(structs, gutils.key("item", item_name), "ammo")
        end
    end

    -- 2. TURRETS WITH BUILT-IN DAMAGE (electric-turret, fluid-turret)
    -- Note: ammo-turrets don't deal damage themselves, the ammo does
    for _, turret_class in pairs({"electric-turret", "fluid-turret"}) do
        for _, turret in pairs(prots(turret_class)) do
            if lu.entities[turret.name] ~= nil then
                local structs = {}
                local gather_func = tutils.type_to_gather_struct_func[turret_class]
                if gather_func ~= nil then
                    gather_func(structs, turret, nil)
                    extract_damage_from_structs(structs, gutils.key("entity", turret.name), "turret")
                end
            end
        end
    end

    -- 3. COMBAT ROBOTS - spawned by capsules, can deal damage
    -- Note: Land mines excluded due to offensive drawbacks (damage to own structures)
    for entity_name, entity in pairs(lu.entities) do
        if entity.type == "combat-robot" then
            local structs = {}
            tutils.gather_combat_robot_structs(structs, entity, nil)
            extract_damage_from_structs(structs, gutils.key("entity", entity_name), "entity")
        end
    end

    -- 4. EQUIPMENT WITH ATTACK (active-defense-equipment like personal laser defense)
    -- COMMENT: What about discharge defense? Double check through equipments that might do damage.
    for equip_name, equip in pairs(lu.equipment) do
        if equip.type == "active-defense-equipment" then
            local structs = {}
            tutils.gather_active_defense_equipment_structs(structs, equip, nil)
            extract_damage_from_structs(structs, gutils.key("equipment", equip_name), "equipment")
        end
    end

    lu.damage_type_sources = damage_type_sources
end

-- Maps science pack set names to labs that can accept ALL packs in the set
-- science_set_name -> { lab_name -> true }
-- Labs must have all packs in their inputs array to be included
stages[2].science_set_to_labs = function()
    local science_set_to_labs = {}

    for set_name, set_packs in pairs(lu.science_sets) do
        science_set_to_labs[set_name] = {}

        for _, lab in pairs(prots("lab")) do
            local lab_inputs_set = {}
            for _, input in pairs(lab.inputs) do
                lab_inputs_set[input] = true
            end

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

-- Recipe subgroups actually have a complex calculation
stages[2].recipe_subgroup = function()
    local recipe_subgroup = {}

    local type_to_lookup = {
        item = lu.items,
        fluid = lu.fluids,
    }

    for _, recipe in pairs(lu.recipes) do
        if recipe.subgroup ~= nil then
            recipe_subgroup[recipe.name] = recipe.subgroup
        elseif recipe.results == nil then
            recipe_subgroup[recipe.name] = "other"
        elseif recipe.main_product == "" or recipe.main_product == nil then
            local main_product_type
            for _, result in pairs(recipe.results) do
                if result.name == recipe.main_product then
                    recipe_subgroup[recipe.name] = type_to_lookup[result.type][result.name].subgroup or "other"
                    break
                end
            end
        elseif #recipe.results == 1 then
            recipe_subgroup[recipe.name] = type_to_lookup[recipe.results[1].type][recipe.results[1].name].subgroup or "other"
        else
            recipe_subgroup[recipe.name] = "other"
        end
    end

    lu.recipe_subgroup = recipe_subgroup
end

-- Recipe categories (spoofed to include number fluids)
-- TODO: Need to also consider input/output amounts in general for things like furnaces
stages[2].rcats = function()
    local rcats = {}

    for _, recipe in pairs(lu.recipes) do
        local name = lutils.rcat_name(recipe)
        if rcats[name] == nil then
            local fluids = lutils.find_recipe_fluids(recipe)

            rcats[name] = {
                cat = recipe.category or "crafting",
                input = fluids.input,
                output = fluids.output,
            }
        end
    end

    lu.rcats = rcats
end

-- Where asteroids/asteroid chunks spawn
stages[2].asteroid_to_place = function()
    local asteroid_to_place = {}

    for place_key, place in pairs(lu.space_places) do
        local space_prot = data.raw[place.type][place.name]
        if space_prot.asteroid_spawn_definitions ~= nil then
            for _, spawn in pairs(space_prot.asteroid_spawn_definitions) do
                local spawned_thing
                -- Check if it's a space connection's special way of defining spawn definitions
                if spawn[1] == nil then
                    spawned_thing = gutils.key({type = spawn.type or "entity", name = spawn.asteroid})
                else
                    spawned_thing = gutils.key({type = "entity", name = spawn[1]})
                end
                if asteroid_to_place[spawned_thing] == nil then
                    asteroid_to_place[spawned_thing] = {}
                end
                asteroid_to_place[spawned_thing][place_key] = place
            end
        end
    end

    lu.asteroid_to_place = asteroid_to_place
end

stages[2].fcat_to_items = function()
    local fcat_to_items = {}

    for _, item in pairs(lu.items) do
        if item.fuel_category ~= nil and item.fuel_value ~= nil and util.parse_energy(item.fuel_value) > 0 then
            local burnt = 0
            if item.burnt_result ~= nil and item.burnt_result ~= "" then
                burnt = 1
            end
            local fcat_key = gutils.concat({item.fuel_category, burnt})
            if fcat_to_items[fcat_key] == nil then
                fcat_to_items[fcat_key] = {}
            end
            fcat_to_items[fcat_key][item.name] = true
        end
    end

    lu.fcat_to_items = fcat_to_items
end

-- Combinations of fuel categories and whether it includes a burnt inventory size that are used in some entity
stages[2].fcat_combos = function()
    local fcat_combos = {}

    for _, entity in pairs(lu.entities) do
        if categories.energy_sources_input[entity.type] ~= nil then
            for _, energy_prop in pairs(dutils.tablize(categories.energy_sources_input[entity.type])) do
                local energy_source = entity[energy_prop]
                if energy_source ~= nil and energy_source.type == "burner" then
                    local burnt = 0
                    if energy_source.burnt_inventory_size ~= nil and energy_source.burnt_inventory_size > 0 then
                        burnt = 1
                    end
                    fcat_combos[lutils.fcat_combo_name(energy_source)] = {
                        fuel = energy_source.fuel_categories or {"chemical"},
                        burnt = burnt,
                    }
                end
            end
        end
    end

    lu.fcat_combos = fcat_combos
end

-- Maps fuel_category to burner entities that have burnt_inventory_size > 0
-- fuel_category -> { entity_name -> true }
-- Used for fuel-category-burn node to find where burnt_results can be produced
-- Note: Uses base fuel_category names, not spoofed combos. The node is "can we burn
-- this fuel category", which depends on any burner that accepts it and has burnt slot.
stages[2].fcat_to_burners = function()
    local fcat_to_burners = {}

    for _, entity in pairs(lu.entities) do
        if categories.energy_sources_input[entity.type] ~= nil then
            for _, energy_prop in pairs(dutils.tablize(categories.energy_sources_input[entity.type])) do
                local energy_source = entity[energy_prop]
                if energy_source ~= nil and energy_source.type == "burner" then
                    if energy_source.burnt_inventory_size ~= nil and energy_source.burnt_inventory_size > 0 then
                        local fuel_cats = energy_source.fuel_categories or {"chemical"}
                        for _, fcat in pairs(fuel_cats) do
                            if fcat_to_burners[fcat] == nil then
                                fcat_to_burners[fcat] = {}
                            end
                            fcat_to_burners[fcat][entity.name] = true
                        end
                    end
                end
            end
        end
    end

    lu.fcat_to_burners = fcat_to_burners
end

-- Maps spoofed resource category (category|has_input|has_output) to mining drills
-- spoofed_mcat -> { drill_name -> true }
-- A drill matches if it:
--   1. Has the base category in its resource_categories
--   2. Has input_fluid_box if has_input == 1
--   3. Has output_fluid_box if has_output == 1
stages[2].mcat_to_drills = function()
    local mcat_to_drills = {}

    -- Factorio character is counted as a mining drill; she works just as hard!
    for _, drill_type in pairs({"mining-drill", "character"}) do
        for _, drill in pairs(prots(drill_type)) do
            if lu.entities[drill.name] ~= nil then
                local has_input_box = drill.input_fluid_box ~= nil
                local has_output_box = drill.output_fluid_box ~= nil
                local resource_cats = drill.resource_categories or drill.mining_categories or {"basic-solid"}

                for _, base_cat in pairs(resource_cats) do
                    -- Generate all valid spoofed keys this drill can handle
                    -- A drill without input box can only handle has_input=0
                    -- A drill without output box can only handle has_output=0
                    local max_input = has_input_box and 1 or 0
                    local max_output = has_output_box and 1 or 0

                    for has_input = 0, max_input do
                        for has_output = 0, max_output do
                            local spoofed_key = gutils.concat({base_cat, has_input, has_output})
                            if mcat_to_drills[spoofed_key] == nil then
                                mcat_to_drills[spoofed_key] = {}
                            end
                            mcat_to_drills[spoofed_key][drill.name] = true
                        end
                    end
                end
            end
        end
    end

    lu.mcat_to_drills = mcat_to_drills
end

-- Maps base resource category to spoofed categories that exist (from actual resources)
-- base_mcat -> { spoofed_mcat -> true }
stages[2].mcat_to_mcats = function()
    local mcat_to_mcats = {}

    for _, resource in pairs(prots("resource")) do
        if resource.minable ~= nil then
            local base_cat = resource.category or "basic-solid"
            local spoofed_key = lutils.mcat_name(resource)  -- Uses existing function: category|has_input|has_output

            if mcat_to_mcats[base_cat] == nil then
                mcat_to_mcats[base_cat] = {}
            end
            mcat_to_mcats[base_cat][spoofed_key] = true
        end
    end

    lu.mcat_to_mcats = mcat_to_mcats
end

-- Technologies that unlock the ability to send starter packs to space
-- tech_name -> true
stages[2].space_platform_unlock_techs = function()
    local space_platform_unlock_techs = {}

    for _, tech in pairs(lu.techs) do
        if tech.effects ~= nil then
            for _, effect in pairs(tech.effects) do
                if effect.type == "unlock-space-platforms" and effect.modifier then
                    space_platform_unlock_techs[tech.name] = true
                end
            end
        end
    end

    lu.space_platform_unlock_techs = space_platform_unlock_techs
end

-- Reverse map: item -> items that spoil into it
-- item_name -> { spoiling_item_name -> true }
stages[2].spoil_result_to_items = function()
    local spoil_result_to_items = {}

    for _, item in pairs(lu.items) do
        if item.spoil_result ~= nil and item.spoil_result ~= "" then
            if spoil_result_to_items[item.spoil_result] == nil then
                spoil_result_to_items[item.spoil_result] = {}
            end
            spoil_result_to_items[item.spoil_result][item.name] = true
        end
    end

    lu.spoil_result_to_items = spoil_result_to_items
end

-- Reverse map: item -> fuels that burn into it
-- item_name -> { fuel_item_name -> true }
stages[2].burnt_result_to_items = function()
    local burnt_result_to_items = {}

    for _, item in pairs(lu.items) do
        if item.burnt_result ~= nil and item.burnt_result ~= "" then
            if burnt_result_to_items[item.burnt_result] == nil then
                burnt_result_to_items[item.burnt_result] = {}
            end
            burnt_result_to_items[item.burnt_result][item.name] = true
        end
    end

    lu.burnt_result_to_items = burnt_result_to_items
end

-- Maps tiles to items that can place them, with their placement conditions
-- tile_name -> { item_name -> { blocking_layers = {...} or nil, whitelist = {...} or nil } }
-- blocking_layers: collision mask layers that BLOCK placement (tiles with these can't be replaced)
-- whitelist: explicit list of tile names that CAN be replaced (if set, only these tiles work)
-- Used for tile-build compound nodes to check per-item placement rules
stages[2].place_as_tile_items = function()
    local place_as_tile_items = {}

    for _, item in pairs(lu.items) do
        if item.place_as_tile ~= nil then
            local tile_name = item.place_as_tile.result
            if place_as_tile_items[tile_name] == nil then
                place_as_tile_items[tile_name] = {}
            end

            local condition_info = {}

            -- Collision mask layers that block placement
            if item.place_as_tile.condition ~= nil and item.place_as_tile.condition.layers ~= nil then
                condition_info.blocking_layers = item.place_as_tile.condition.layers
            end

            -- Explicit whitelist of tiles that can be replaced
            if item.place_as_tile.tile_condition ~= nil then
                condition_info.whitelist = {}
                for _, allowed_tile in pairs(item.place_as_tile.tile_condition) do
                    condition_info.whitelist[allowed_tile] = true
                end
            end

            place_as_tile_items[tile_name][item.name] = condition_info
        end
    end

    lu.place_as_tile_items = place_as_tile_items
end

-- Maps items to entities that drop them as loot
-- item_name -> { entity_name -> true }
stages[2].loot_to_entities = function()
    local loot_to_entities = {}

    for _, entity in pairs(lu.entities) do
        if entity.loot ~= nil then
            for _, loot_entry in pairs(entity.loot) do
                local item_name = loot_entry.item
                if item_name ~= nil then
                    if loot_to_entities[item_name] == nil then
                        loot_to_entities[item_name] = {}
                    end
                    loot_to_entities[item_name][entity.name] = true
                end
            end
        end
    end

    lu.loot_to_entities = loot_to_entities
end

-- Maps entities to what they spawn when dying (via dying_trigger_effect)
-- Uses trigger library to gather all trigger effects from entity
-- dying_spawns: entity_key -> { spawned_key -> true }
-- dying_spawns_reverse: spawned_key -> { entity_key -> true }
-- spawned_key can be "entity:name" or "asteroid-chunk:name"
stages[2].dying_spawns = function()
    local dying_spawns = {}
    local dying_spawns_reverse = {}

    -- Helper to add a spawn relationship
    local function add_spawn(entity_key, spawned_key)
        if dying_spawns[entity_key] == nil then
            dying_spawns[entity_key] = {}
        end
        dying_spawns[entity_key][spawned_key] = true

        if dying_spawns_reverse[spawned_key] == nil then
            dying_spawns_reverse[spawned_key] = {}
        end
        dying_spawns_reverse[spawned_key][entity_key] = true
    end

    for _, entity in pairs(lu.entities) do
        if entity.dying_trigger_effect ~= nil then
            local entity_key = gutils.key("entity", entity.name)

            -- Use trigger library to gather all trigger effects
            local gather_func = tutils.type_to_gather_struct_func[entity.type]
            if gather_func ~= nil then
                local structs = {}
                gather_func(structs, entity, nil)

                -- Extract spawned entities/chunks from trigger effects
                if structs["trigger-effect"] ~= nil then
                    for _, te in pairs(structs["trigger-effect"]) do
                        if te.type == "create-entity" and te.entity_name ~= nil then
                            add_spawn(entity_key, gutils.key("entity", te.entity_name))
                        end
                        if te.type == "create-asteroid-chunk" and te.asteroid_name ~= nil then
                            add_spawn(entity_key, gutils.key("asteroid-chunk", te.asteroid_name))
                        end
                    end
                end
            end
        end
    end

    lu.dying_spawns = dying_spawns
    lu.dying_spawns_reverse = dying_spawns_reverse
end

-- Maps capsule items to entities they spawn
-- Uses trigger library to gather capsule action trigger effects
-- capsule_spawns: item_name -> { entity_name -> true }
-- capsule_spawns_reverse: entity_name -> { item_name -> true }
stages[2].capsule_spawns = function()
    local capsule_spawns = {}
    local capsule_spawns_reverse = {}

    -- Helper to add a spawn relationship
    local function add_spawn(item_name, entity_name)
        if capsule_spawns[item_name] == nil then
            capsule_spawns[item_name] = {}
        end
        capsule_spawns[item_name][entity_name] = true

        if capsule_spawns_reverse[entity_name] == nil then
            capsule_spawns_reverse[entity_name] = {}
        end
        capsule_spawns_reverse[entity_name][item_name] = true
    end

    for item_name, item in pairs(lu.items) do
        if item.type == "capsule" then
            -- Use trigger library to gather all trigger effects from capsule
            local structs = {}
            tutils.gather_capsule_structs(structs, item, nil)

            -- Extract spawned entities from trigger effects
            if structs["trigger-effect"] ~= nil then
                for _, te in pairs(structs["trigger-effect"]) do
                    if te.type == "create-entity" and te.entity_name ~= nil then
                        add_spawn(item_name, te.entity_name)
                    end
                end
            end
        end
    end

    lu.capsule_spawns = capsule_spawns
    lu.capsule_spawns_reverse = capsule_spawns_reverse
end

-- Maps ammo items to entities they spawn
-- Uses trigger library to gather ammo action trigger effects
-- ammo_spawns: item_name -> { entity_name -> true }
-- ammo_spawns_reverse: entity_name -> { item_name -> true }
stages[2].ammo_spawns = function()
    local ammo_spawns = {}
    local ammo_spawns_reverse = {}

    -- Helper to add a spawn relationship
    local function add_spawn(item_name, entity_name)
        if ammo_spawns[item_name] == nil then
            ammo_spawns[item_name] = {}
        end
        ammo_spawns[item_name][entity_name] = true

        if ammo_spawns_reverse[entity_name] == nil then
            ammo_spawns_reverse[entity_name] = {}
        end
        ammo_spawns_reverse[entity_name][item_name] = true
    end

    for item_name, item in pairs(lu.items) do
        if item.type == "ammo" then
            -- Use trigger library to gather all trigger effects from ammo
            local structs = {}
            tutils.gather_ammo_structs(structs, item, nil)

            -- Extract spawned entities from trigger effects
            if structs["trigger-effect"] ~= nil then
                for _, te in pairs(structs["trigger-effect"]) do
                    if te.type == "create-entity" and te.entity_name ~= nil then
                        add_spawn(item_name, te.entity_name)
                    end
                end
            end
        end
    end

    lu.ammo_spawns = ammo_spawns
    lu.ammo_spawns_reverse = ammo_spawns_reverse
end

-- Maps entities to their output fluid (boilers, fusion-reactors, fusion-generators)
-- entity_name -> fluid_name
-- Only includes entities with filtered output_fluid_box where output differs from input
stages[2].entity_output_fluids = function()
    local entity_output_fluids = {}

    for _, entity in pairs(lu.entities) do
        local output_fluid = nil

        if entity.type == "boiler" then
            -- Boilers have output_fluid_box (required field per API)
            if entity.output_fluid_box ~= nil and entity.output_fluid_box.filter ~= nil then
                -- Only count if output differs from input (e.g., water -> steam)
                local input_filter = entity.fluid_box and entity.fluid_box.filter
                if entity.output_fluid_box.filter ~= input_filter then
                    output_fluid = entity.output_fluid_box.filter
                end
            end
        elseif entity.type == "fusion-reactor" then
            -- Fusion reactors have output_fluid_box (required field per API)
            if entity.output_fluid_box ~= nil and entity.output_fluid_box.filter ~= nil then
                output_fluid = entity.output_fluid_box.filter
            end
        elseif entity.type == "fusion-generator" then
            -- Fusion generators also have output_fluid_box (not just input!)
            if entity.output_fluid_box ~= nil and entity.output_fluid_box.filter ~= nil then
                output_fluid = entity.output_fluid_box.filter
            end
        end

        if output_fluid ~= nil then
            entity_output_fluids[entity.name] = output_fluid
        end
    end

    lu.entity_output_fluids = entity_output_fluids
end

local function get_default_creator_table(prototype)
    return {
        created_by = {},
        creates = {},
        prototype = prototype,
    }
end
stages[2].creator_tables = function()
    local creator_tables = {}

    local class_list = {"item", "entity", "equipment"}
    for _, top_level in pairs(class_list) do
        for class, _ in pairs(defines.prototypes[top_level]) do
            local name_to_creators = tutils.get_creator_table(class, lu.items, lu.entities, lu.equipment)
            for _, prototype in pairs(prots(class)) do
                if creator_tables[gutils.key(prototype)] == nil then
                    creator_tables[gutils.key(prototype)] = get_default_creator_table(prototype)
                end
                for _, creator in pairs(name_to_creators[prototype.name] or {}) do
                    if creator_tables[gutils.key(creator)] == nil then
                        creator_tables[gutils.key(creator)] = get_default_creator_table(creator)
                    end
                    creator_tables[gutils.key(prototype)].created_by[gutils.key(creator)] = creator
                    creator_tables[gutils.key(creator)].creates[gutils.key(prototype)] = prototype
                end
            end
        end
    end

    lu.creator_tables = creator_tables
end

stages[2].buildables = function()
    local buildables = {}

    -- Assume any entity is only built or planted (anything else doesn't make sense)
    -- "Planted" will be checked the same as "built", except some connections later may depend on it being a planted entity
    local buildable_keys = {
        ["place_result"] = "entity",
        ["plant_result"] = "entity",
        ["place_as_tile"] = "tile",
    }
    for _, item in pairs(lu.items) do
        for prop, class in pairs(buildable_keys) do
            if item[prop] ~= nil then
                local prot
                if class == "entity" then
                    prot = dutils.get_prot("entity", item[prop])
                elseif class == "tile" then
                    -- Case of "place_as_tile"
                    prot = dutils.get_prot("tile", item[prop].result)
                end

                if buildables[gutils.key(prot)] == nil then
                    buildables[gutils.key(prot)] = {}
                end
                buildables[gutils.key(prot)][item.name] = prop
            end
        end
    end

    lu.buildables = buildables
end

stages[2].materials = function()
    local materials = {}

    for _, item in pairs(lu.items) do
        materials[gutils.key("item", item.name)] = item
    end
    for _, fluid in pairs(lu.fluids) do
        materials[gutils.key("fluid", fluid.name)] = fluid
    end
    
    lu.materials = materials
end

-- Minable corpses to entities that create them
stages[2].minable_corpse = function()
    local minable_corpses = {}

    for _, entity in pairs(lu.entities) do
        for _, corpse_prop in pairs({"corpse", "character-corpse"}) do
            local corpse = data.raw[corpse_prop][entity[corpse_prop]]
            if corpse ~= nil and corpse.minable ~= nil then
                if minable_corpses[corpse.name] == nil then
                    minable_corpses[corpse.name] = {}
                end
                minable_corpses[corpse.name][entity.name] = true
            end
        end
    end

    lu.minable_corpses = minable_corpses
end

-- Get a list of entities that are probably operable
stages[2].operable_entities = function()
    local operable_entities = {}

    for _, entity in pairs(lu.entities) do
        if entity.flags ~= nil then
            for _, flag in pairs(entity.flags) do
                if flag == "player-creation" or flag == "placeable-player" then
                    operable_entities[entity.name] = true
                end
            end
        end
        -- Also have to add character prototypes themselves
        if entity.type == "character" then
            operable_entities[entity.name] = true
        end
    end

    lu.operable_entities = operable_entities
end

-- A table for entities to restistance groups, and from resistance groups to entities
-- A resistance group is the full collection of damage types that can deal damage to an entity; almost all entities have all damages as possible
stages[2].entity_resistance_groups = function()
    local entity_resistance_groups = {
        to_resistance = {},
        to_entity = {},
        groups = {},
    }

    for _, entity in pairs(lu.entities) do
        if not categories.without_health[entity.type] then
            local immunities = {}
            local is_immune = {}

            if entity.resistances ~= nil then
                for _, resistance in pairs(entity.resistances) do
                    -- Flat resistances can never prevent damage from being done at all (see the wiki for more info about this)
                    -- Thus, we only need to check if the percentage is too high
                    if resistance.percentage ~= nil and resistance.percentage >= 100 then
                        table.insert(immunities, resistance.type)
                        is_immune[resistance.type] = true
                    end
                end
            end

            table.sort(immunities)
            local immunities_key = gutils.concat(immunities)
            entity_resistance_groups.to_resistance[entity.name] = immunities_key
            if entity_resistance_groups.to_entity[immunities_key] == nil then
                entity_resistance_groups.to_entity[immunities_key] = {}
            end
            entity_resistance_groups.to_entity[immunities_key][entity.name] = true
            if entity_resistance_groups.groups[immunities_key] == nil then
                entity_resistance_groups.groups[immunities_key] = is_immune
            end
        end
    end

    lu.entity_resistance_groups = entity_resistance_groups
end

-- Maps fluids to tiles that have them
stages[2].fluid_to_tiles = function()
    local fluid_to_tiles = {}

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
stages[2].pumps_with_filter = function()
    local pumps_with_filter = {}

    for _, pump in pairs(prots("offshore-pump")) do
        -- offshore pumps always have fluid_box (mandatory per API)
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

-- Maps tiles (with fluid) to offshore pumps that can pump from them
-- Only includes pumps WITHOUT a filter (pumps with filter always produce their filter fluid)
-- Checks collision between pump and tile
--
-- Basic check: collision_mask_util.masks_collide(tile.collision_mask, pump.collision_mask)
-- More complex: tile_buildability_rules exist but are complex and only used by 4 entities (rail ramps, offshore pumps, thrusters, asteroid collectors)
-- For now, we do basic collision check; tile_buildability_rules could be added later
stages[2].tile_valid_pumps = function()
    local tile_valid_pumps = {}

    for _, tile in pairs(prots("tile")) do
        if tile.fluid ~= nil then
            tile_valid_pumps[tile.name] = {}

            for _, pump in pairs(prots("offshore-pump")) do
                -- Only include pumps without a filter (pump.fluid_box is mandatory per API)
                -- Pumps WITH a filter always produce their filter fluid regardless of what tile they're on,
                -- so they're handled separately via pumps_with_filter lookup (the fluid comes from the pump, not the tile)
                if pump.fluid_box.filter == nil then
                    -- Check collision
                    local pump_mask = pump.collision_mask or collision_mask_util.get_default_mask("offshore-pump")
                    if not collision_mask_util.masks_collide(tile.collision_mask, pump_mask) then
                        tile_valid_pumps[tile.name][pump.name] = true
                    end
                end
            end
        end
    end

    lu.tile_valid_pumps = tile_valid_pumps
end

-- Maps rooms to tiles and tiles to rooms (bidirectional)
-- Uses lutils.check_in_room which now supports returning all tiles for a room
stages[2].room_tile_maps = function()
    local room_tiles = {}
    local tiles_to_rooms = {}

    -- Initialize tiles_to_rooms for all tiles
    for _, tile in pairs(prots("tile")) do
        tiles_to_rooms[tile.name] = {}
    end

    -- Build room_tiles using check_in_room, then invert for tiles_to_rooms
    for room_key, room in pairs(lu.rooms) do
        -- check_in_room(room, "tile") returns all tiles in that room
        room_tiles[room_key] = lutils.check_in_room(room, "tile")

        -- Build reverse mapping
        for tile_name, _ in pairs(room_tiles[room_key]) do
            tiles_to_rooms[tile_name][room_key] = true
        end
    end

    lu.room_tiles = room_tiles
    lu.tiles_to_rooms = tiles_to_rooms
end


-- Maps recipe names to technologies that unlock them
-- recipe_name -> { tech_name -> true }
stages[2].recipe_to_techs = function()
    local recipe_to_techs = {}

    for _, tech in pairs(lu.techs) do
        if tech.effects ~= nil then
            for _, effect in pairs(tech.effects) do
                if effect.type == "unlock-recipe" then
                    if recipe_to_techs[effect.recipe] == nil then
                        recipe_to_techs[effect.recipe] = {}
                    end
                    recipe_to_techs[effect.recipe][tech.name] = true
                end
            end
        end
    end

    lu.recipe_to_techs = recipe_to_techs
end

stages[2].space_location_to_discovery_techs = function()
    local space_location_to_discovery_techs = {}

    for _, tech in pairs(lu.techs) do
        if tech.effects ~= nil then
            for _, effect in pairs(tech.effects) do
                if effect.type == "unlock-space-location" then
                    local loc_name = effect.space_location
                    if space_location_to_discovery_techs[loc_name] == nil then
                        space_location_to_discovery_techs[loc_name] = {}
                    end
                    space_location_to_discovery_techs[loc_name][tech.name] = true
                end
            end
        end
    end

    lu.space_location_to_discovery_techs = space_location_to_discovery_techs
end

-- Maps base recipe category names to their spoofed rcat names
-- cat_name -> { rcat_name -> true }
stages[2].cat_to_rcats = function()
    local cat_to_rcats = {}

    for rcat_name, rcat in pairs(lu.rcats) do
        if cat_to_rcats[rcat.cat] == nil then
            cat_to_rcats[rcat.cat] = {}
        end
        cat_to_rcats[rcat.cat][rcat_name] = true
    end

    lu.cat_to_rcats = cat_to_rcats
end

stages[2].equipment_grid_sources = function()
    local equipment_grid_sources = {}

    -- Helper to add a grid source
    local function add_grid_source(grid_name, source_name, source_type)
        local grid = data.raw["equipment-grid"][grid_name]
        if grid ~= nil and grid.equipment_categories ~= nil then
            for _, cat in pairs(grid.equipment_categories) do
                if equipment_grid_sources[cat] == nil then
                    equipment_grid_sources[cat] = {}
                end
                equipment_grid_sources[cat][source_name] = source_type
            end
        end
    end

    -- Check armor items
    for _, armor in pairs(prots("armor")) do
        if armor.equipment_grid ~= nil then
            add_grid_source(armor.equipment_grid, armor.name, "armor")
        end
    end

    -- Check all vehicle types that can have equipment grids
    for _, vehicle_class in pairs(categories.vehicles_with_grids) do
        for _, vehicle in pairs(prots(vehicle_class)) do
            if lu.entities[vehicle.name] ~= nil and vehicle.equipment_grid ~= nil then
                add_grid_source(vehicle.equipment_grid, vehicle.name, "vehicle")
            end
        end
    end

    lu.equipment_grid_sources = equipment_grid_sources
end

-- Maps ammo categories to things that can shoot that category
-- ammo_category -> { source_key -> source_type }
-- source_type is "turret" (ammo-turret entity) or "gun" (gun item)
stages[2].ammo_category_sources = function()
    local ammo_category_sources = {}

    -- Initialize for all ammo categories
    for _, cat in pairs(prots("ammo-category")) do
        ammo_category_sources[cat.name] = {}
    end

    -- Helper to add sources for ammo categories
    local function add_sources(attack_parameters, source_key, source_type)
        local cats = dutils.get_ammo_categories(attack_parameters)
        if cats ~= nil then
            for _, cat in pairs(cats) do
                if ammo_category_sources[cat] == nil then
                    ammo_category_sources[cat] = {}
                end
                ammo_category_sources[cat][source_key] = source_type
            end
        end
    end

    -- 1. AMMO TURRETS
    for _, turret in pairs(prots("ammo-turret")) do
        if lu.entities[turret.name] ~= nil then
            add_sources(turret.attack_parameters, gutils.key("entity", turret.name), "turret")
        end
    end

    -- 2. GUNS
    for _, gun in pairs(prots("gun")) do
        add_sources(gun.attack_parameters, gutils.key("item", gun.name), "gun")
    end

    lu.ammo_category_sources = ammo_category_sources
end

stages[2].category_to_grids = function()
    local category_to_grids = {}

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

-- Maps grid names to armors/vehicles that have them
-- grid_name -> { source_name -> source_type }
-- source_type is "armor" or "vehicle"
stages[2].grid_to_sources = function()
    local grid_to_sources = {}

    -- Initialize for all grids
    for _, grid in pairs(prots("equipment-grid")) do
        grid_to_sources[grid.name] = {}
    end

    -- Check armor items
    for _, armor in pairs(prots("armor")) do
        if armor.equipment_grid ~= nil then
            if grid_to_sources[armor.equipment_grid] ~= nil then
                grid_to_sources[armor.equipment_grid][armor.name] = "armor"
            end
        end
    end

    -- Check vehicles
    for _, vehicle_class in pairs(categories.vehicles_with_grids) do
        for _, vehicle in pairs(prots(vehicle_class)) do
            if lu.entities[vehicle.name] ~= nil and vehicle.equipment_grid ~= nil then
                if grid_to_sources[vehicle.equipment_grid] ~= nil then
                    grid_to_sources[vehicle.equipment_grid][vehicle.name] = "vehicle"
                end
            end
        end
    end

    lu.grid_to_sources = grid_to_sources
end

-- Maps grids to power-producing equipment that can go in them
-- grid_name -> { equip_name -> true }
-- Note: Only checks category match, not size (equipment might be too large for grid)
stages[2].grid_power_sources = function()
    local grid_power_sources = {}

    for _, grid in pairs(prots("equipment-grid")) do
        grid_power_sources[grid.name] = {}

        local grid_cats = {}
        for _, cat in pairs(grid.equipment_categories) do
            grid_cats[cat] = true
        end

        -- Find power-producing equipment with matching categories
        for equip_name, equip in pairs(lu.equipment) do
            if categories.equipment_power_producers[equip.type] then
                local equip_cats = equip.categories or {}
                for _, cat in pairs(equip_cats) do
                    if grid_cats[cat] then
                        grid_power_sources[grid.name][equip_name] = true
                        break
                    end
                end
            end
        end
    end

    lu.grid_power_sources = grid_power_sources
end

----------------------------------------------------------------------
-- Stage 3
----------------------------------------------------------------------

stages[3] = {}

-- Maps asteroid entity names to their resistance group key
-- asteroid_name -> resistance_group_key
-- Uses entity_resistance_groups lookup for the group key
stages[3].asteroid_resistance_groups = function()
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

-- Maps asteroid entity names to their resistance group key
-- asteroid_name -> resistance_group_key
-- Uses entity_resistance_groups lookup for the group key
stages[3].asteroid_resistance_groups = function()
    local asteroid_resistance_groups = {}

    for _, asteroid in pairs(prots("asteroid")) do
        local group_key = lu.entity_resistance_groups.to_resistance[asteroid.name]
        if group_key ~= nil then
            asteroid_resistance_groups[asteroid.name] = group_key
        end
    end

    lu.asteroid_resistance_groups = asteroid_resistance_groups
end

-- Maps spoofed recipe categories (rcat names) to entities that can craft them
-- rcat_name -> { entity_name -> true }
-- Uses lutils.is_compatible_rcat to check category + fluid box compatibility
stages[3].rcat_to_crafters = function()
    local rcat_to_crafters = {}

    -- Initialize for all rcats
    for rcat_name, _ in pairs(lu.rcats) do
        rcat_to_crafters[rcat_name] = {}
    end

    -- Check each crafting machine against each rcat
    for _, class in pairs({"assembling-machine", "furnace", "rocket-silo", "character"}) do
        for _, machine in pairs(prots(class)) do
            if machine.crafting_categories ~= nil then
                for rcat_name, rcat in pairs(lu.rcats) do
                    if lutils.is_compatible_rcat(machine, rcat) then
                        rcat_to_crafters[rcat_name][machine.name] = true
                    end
                end
            end
        end
    end

    lu.rcat_to_crafters = rcat_to_crafters
end

stages[3].mat_recipe_map = function()
    local mat_recipe_map = {
        material = {},
        recipe = {},
    }

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
                    local mat_map = mat_recipe_map.material[gutils.key(prod)][prop]
                    -- I could check if the amount was set to zero, but that just seems silly
                    if recipe_map[gutils.key(prod)] == nil then
                        recipe_map[gutils.key(prod)] = {}
                    end
                    if mat_map[recipe.name] == nil then
                        mat_map[recipe.name] = {}
                    end
                    recipe_map[gutils.key(prod)][ind] = true
                    mat_map[recipe.name][ind] = true
                end
            end
        end
    end

    lu.mat_recipe_map = mat_recipe_map
end

stages[3].mat_mining_map = function()
    local mat_mining_map = {
        to_minable = {},
        to_material = {},
    }

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
                local to_material_map = mat_mining_map.to_material[minable_key]
                local to_minable_map = mat_mining_map.to_minable[gutils.key(result)]
                if to_material_map[gutils.key(result)] == nil then
                    to_material_map[gutils.key(result)] = {}
                end
                if to_minable_map[minable_key] == nil then
                    to_minable_map[minable_key] = {}
                end
                to_material_map[gutils.key(result)][ind] = true
                to_minable_map[minable_key][ind] = true
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

----------------------------------------------------------------------
-- Stage 4
----------------------------------------------------------------------

stages[4] = {}

stages[4].weight = function()
    local weight = {}

    -- Details for weight calculation found from URL below (version 2.0.72); quotes from page included for clarity
    -- https://lua-api.factorio.com/2.0.72/auxiliary/item-weight.html

    local default_weight = data.raw["utility-constants"].default.default_item_weight
    local rocket_lift_weight = data.raw["utility-constants"].default.rocket_lift_weight

    local item_to_first_recipe = {}
    for _, item in pairs(lu.items) do
        -- Check for manually set weight; if it doesn't
        if item.weight ~= nil then
            weight[item.name] = item.weight
        else
            -- Quote: If an item has the "only-in-cursor" and "spawnable" flags, its weight will be 0.
            if item.flags ~= nil then
                local give_zero_weight = false
                for _, flag in pairs(item.flags) do
                    if flag == "only-in-cursor" or flag == "spawnable" then
                        give_zero_weight = true
                        break
                    end
                end
                if give_zero_weight then
                    weight[item.name] = 0
                end
            end

            -- Only continue if we didn't set weight to zero just now
            if weight[item.name] == nil then
                local related_recipes = lu.mat_recipe_map.material[gutils.key("item", item.name)]
                local valid_recipes = {}
                for recipe_name, _ in pairs(related_recipes.results) do
                    local recipe = data.raw.recipe[recipe_name]
                    -- Quote: Recipes that don't allow decomposition are not considered
                    if recipe.allow_decomposition or recipe.allow_decomposition == nil then
                        table.insert(valid_recipes, recipe)
                    end
                end
                -- Quote: If an item has no recipe to produce it, it'll fall back to the default item weight.
                if next(valid_recipes) == nil then
                    weight[item.name] = default_weight
                else
                    -- Quote: If an item has multiple recipes, it picks the first recipe, according to the sorting described at the bottom of this page.
                    -- (Note that this sorting process applies for one recipe as well, since any ordering will put it first trivially)
                    -- Quote: The sorting works by considering the following attributes in order, preferring recipes that fulfill them:
                    table.sort(valid_recipes, function(r1, r2)
                        -- Quote: The name of the recipe is identical to the item name.
                        local function check_name(recipe)
                            if recipe.name == item.name then
                                return 0
                            else
                                return 1
                            end
                        end
                        -- Quote: The recipe is not using the item as a catalyst.
                        local function using_as_catalyst(recipe)
                            if (recipe.ignored_by_productivity ~= nil and recipe.ignored_by_productivity > 0) or (recipe.ignored_by_productivity == nil and recipe.ignored_by_stats ~= nil and recipe.ignored_by_stats > 0) then
                                -- Being a catalyst puts it later
                                return 1
                            else
                                return 0
                            end
                        end
                        -- Quote: The recipe can be used as an intermediate while hand-crafting.
                        local function usable_in_handcrafting(recipe)
                            if recipe.allow_as_intermediate or recipe.allow_as_intermediate == nil then
                                return 0
                            else
                                return 1
                            end
                        end
                        -- The recipe's category, subgroup, then order.
                        local function category_order(recipe)
                            local category = data.raw["recipe-category"][recipe.category or "crafting"]
                            return category.order or category.name
                        end
                        local function subgroup_order(recipe)
                            local subgroup = data.raw["item-subgroup"][lu.recipe_subgroup[recipe.name]]
                            return subgroup.order or subgroup.name
                        end
                        local function recipe_order(recipe)
                            return recipe.order or recipe.name
                        end
                        
                        for _, checker in pairs({check_name, using_as_catalyst, usable_in_handcrafting, category_order, subgroup_order, recipe_order}) do
                            local order1 = checker(r1)
                            local order2 = checker(r2)
                            if order1 < order2 then
                                return true
                            elseif order2 < order1 then
                                return false
                            end
                        end

                        -- Note: Technically, everything including recipe orders can be the same, but behavior then is undefined; let's just return false
                        return false
                    end)

                    item_to_first_recipe[item.name] = valid_recipes[1]
                end
            end
        end
    end

    -- Now, let's do a mini topological sort on the item --> item graph

    -- First, construct the graph
    local item_graph = {}
    local open = {}
    local in_open = {}
    local reqs_total = {}
    local reqs_satisfied = {}
    -- We need to add all nodes separately since not every item was added to item_to_first_recipe
    for item_name, _ in pairs(lu.items) do
        item_graph[item_name] = {
            pre = {},
            dep = {},
        }
        reqs_total[item_name] = 0
        reqs_satisfied[item_name] = 0
    end
    for item_name, recipe in pairs(item_to_first_recipe) do
        -- Don't add prereqs if the item already has a weight, since then it might get added to open twice
        if weight[item_name] == nil then
            if recipe.ingredients ~= nil then
                for _, ing in pairs(recipe.ingredients) do
                    if ing.type == "item" then
                        item_graph[item_name].pre[ing.name] = true
                        reqs_total[item_name] = reqs_total[item_name] + 1
                    end
                end
            end
        end
        -- Add sources
        if reqs_total[item_name] == 0 then
            table.insert(open, item_name)
            in_open[item_name] = true
        end
    end
    -- Add sources not in item_to_first_recipe; these are items already assigned a weight
    for _, item in pairs(lu.items) do
        if item_to_first_recipe[item.name] == nil and weight[item.name] ~= nil then
            table.insert(open, item.name)
            in_open[item.name] = true
        end
    end
    -- Add dependents
    for item_name, node in pairs(item_graph) do
        for pre, _ in pairs(node.pre) do
            item_graph[pre].dep[item_name] = true
        end
    end

    local ind = 1
    while true do
        if ind > #open then
            break
        end

        local curr_item = open[ind]
        local curr_item_prot = lu.items[curr_item]

        local curr_weight = weight[curr_item]

        -- Calculate weight if we haven't done so yet
        if curr_weight == nil then
            local curr_recipe = item_to_first_recipe[curr_item]
            -- We might end up recalculating the recipe cost for a recipe that somehow is canonical for more than one item, but that should be rare and not worth the effort to optimize for

            -- Quote: The recipe weight is then calculated by iterating over all ingredients:
            local recipe_weight = 0
            if curr_recipe.ingredients ~= nil then
                for _, ing in pairs(curr_recipe.ingredients) do
                    if ing.type == "item" then
                        -- Quote: For each item ingredient, the weight is increased by item_weight * item_ingredient_count.
                        recipe_weight = recipe_weight + weight[ing.name] * ing.amount
                    else
                        -- Quote: For each fluid ingredient, the weight is increased by fluid_ingredient_amount * 100.
                        recipe_weight = recipe_weight + ing.amount * 100
                    end
                end
            end
            -- Quote: If the resulting recipe weight is 0, the item's weight will fall back to the default item weight.
            if recipe_weight == 0 then
                weight[curr_item] = default_weight
            else
                -- Quote: The game then determines the product count of the recipe by iterating all products and adding up the expected (ie. after probabilities) count for all item products. Fluid products are skipped.
                local product_count = 0
                if curr_recipe.results ~= nil then
                    for _, result in pairs(curr_recipe.results) do
                        if result.type == "item" then
                            product_count = product_count + flow_cost.find_amount_in_entry(result)
                        end
                    end
                end
                -- Quote: If the recipe's product count is 0, the item's weight will fall back to the default item weight.
                if product_count == 0 then
                    weight[curr_item] = default_weight
                else
                    -- Quote: Next, an intermediate result will be determined as (recipe_weight / product_count) * ingredient_to_weight_coefficient (see ingredient_to_weight_coefficient, which defaults to 0.5).
                    local intermediate_result = (recipe_weight / product_count) * (curr_item_prot.ingredient_to_weight_coefficient or 0.5)

                    if not curr_recipe.allow_productivity then
                        -- Quote: Following this, if a recipe doesn't support productivity, its simple result is determined as rocket_lift_weight / stack_size (see rocket_lift_weight and stack_size).
                        local simple_result = rocket_lift_weight / curr_item_prot.stack_size
                        -- Quote: If this simple result is larger than or equal to the intermediate result, it becomes the item's weight.
                        if simple_result >= intermediate_result then
                            weight[curr_item] = simple_result
                        end
                    end

                    -- Quote: Check if we still haven't assigned weight (either the recipe supports productivity or didn't satisfy simple_result constraints)
                    if weight[curr_item] == nil then
                        -- Quote: Otherwise, the game determines the amount of stacks that would result from the intermediate result as rocket_lift_weight / intermediate_result / stack_size.
                        local stack_amount = rocket_lift_weight / intermediate_result / curr_item_prot.stack_size
                        -- Quote: If this amount is less than or equal to 1, the intermediate result becomes the item's weight.
                        if stack_amount <= 1 then
                            weight[curr_item] = intermediate_result
                        -- Quote: Else, the item's weight is set to rocket_lift_weight / floor(stack_amount) / stack_size.
                        else
                            weight[curr_item] = rocket_lift_weight / math.floor(stack_amount) / curr_item_prot.stack_size
                        end
                    end
                end
            end
        end

        -- Add dependents to open
        for dep, _ in pairs(item_graph[curr_item].dep) do
            reqs_satisfied[dep] = reqs_satisfied[dep] + 1
            if reqs_satisfied[dep] == reqs_total[dep] then
                if not in_open[dep] then
                    table.insert(open, dep)
                    in_open[dep] = true
                end
            end
        end

        ind = ind + 1
    end

    -- Put default item weights on the rest (which must have been in a loop)
    for item_name, _ in pairs(lu.items) do
        if weight[item_name] == nil then
            weight[item_name] = default_weight
        end
    end

    lu.weight = weight
end

-- Load the lookups

lu.load_lookups = function()
    for _, stage in pairs(stages) do
        for _, loader in pairs(stage) do
            loader()
        end
    end
end

return lu