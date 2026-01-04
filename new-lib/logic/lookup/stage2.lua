-- Stage 2: Filtered/processed collections (depends on stage 1)
-- These build on top of the raw collections from stage 1

local stage0 = require("new-lib/logic/lookup/stage0")
local pairs = stage0.pairs
local table_insert = stage0.table_insert
local table_sort = stage0.table_sort

local stage2 = {}

----------------------------------------------------------------------
-- MOVED from Stage 1: Uses lu.entities, so must be stage 2
----------------------------------------------------------------------

-- Precompute entity collision groups
stage2.entity_collision_groups = function(lu, req)
    local entity_collision_groups = {}
    local entity_collision_group_to_layers = {}
    local entity_to_collision_group = {}
    local gutils = req.gutils
    local collision_mask_util = req.collision_mask_util

    for _, entity in pairs(lu.entities) do
        local collision_layers = {}
        local collision_mask = entity.collision_mask or collision_mask_util.get_default_mask(entity.type)
        for layer, _ in pairs(collision_mask.layers) do
            table_insert(collision_layers, layer)
        end
        table_sort(collision_layers)
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

----------------------------------------------------------------------
-- Space-related lookups
----------------------------------------------------------------------

-- Maps space connections to asteroid entities that spawn on them
-- connection_name -> { asteroid_name -> true }
stage2.connection_asteroids = function(lu, req)
    local connection_asteroids = {}
    local prots = req.prots

    for _, conn in pairs(prots("space-connection")) do
        connection_asteroids[conn.name] = {}

        if conn.asteroid_spawn_definitions ~= nil then
            for _, spawn in pairs(conn.asteroid_spawn_definitions) do
                local asteroid_name
                if spawn.asteroid ~= nil then
                    asteroid_name = spawn.asteroid
                elseif spawn[1] ~= nil then
                    asteroid_name = spawn[1]
                end
                if asteroid_name ~= nil and lu.entities[asteroid_name] ~= nil then
                    connection_asteroids[conn.name][asteroid_name] = true
                end
            end
        end
    end

    lu.connection_asteroids = connection_asteroids
end

-- Where asteroids/asteroid chunks spawn
stage2.asteroid_to_place = function(lu, req)
    local asteroid_to_place = {}
    local gutils = req.gutils

    for place_key, place in pairs(lu.space_places) do
        local space_prot = data.raw[place.type][place.name]
        if space_prot.asteroid_spawn_definitions ~= nil then
            for _, spawn in pairs(space_prot.asteroid_spawn_definitions) do
                local spawned_thing
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

----------------------------------------------------------------------
-- Equipment-related lookups
----------------------------------------------------------------------

-- Maps equipment names to items that place them
-- equipment_name -> { item_name -> true }
stage2.equipment_to_items = function(lu, req)
    local equipment_to_items = {}

    for equip_name, _ in pairs(lu.equipment) do
        equipment_to_items[equip_name] = {}
    end

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

stage2.equipment_grid_sources = function(lu, req)
    local equipment_grid_sources = {}
    local prots = req.prots
    local categories = req.categories

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

    for _, armor in pairs(prots("armor")) do
        if armor.equipment_grid ~= nil then
            add_grid_source(armor.equipment_grid, armor.name, "armor")
        end
    end

    for _, vehicle_class in pairs(categories.vehicles_with_grids) do
        for _, vehicle in pairs(prots(vehicle_class)) do
            if lu.entities[vehicle.name] ~= nil and vehicle.equipment_grid ~= nil then
                add_grid_source(vehicle.equipment_grid, vehicle.name, "vehicle")
            end
        end
    end

    lu.equipment_grid_sources = equipment_grid_sources
end

-- Maps grid names to armors/vehicles that have them
-- grid_name -> { source_name -> source_type }
stage2.grid_to_sources = function(lu, req)
    local grid_to_sources = {}
    local prots = req.prots
    local categories = req.categories

    for _, grid in pairs(prots("equipment-grid")) do
        grid_to_sources[grid.name] = {}
    end

    for _, armor in pairs(prots("armor")) do
        if armor.equipment_grid ~= nil then
            if grid_to_sources[armor.equipment_grid] ~= nil then
                grid_to_sources[armor.equipment_grid][armor.name] = "armor"
            end
        end
    end

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
stage2.grid_power_sources = function(lu, req)
    local grid_power_sources = {}
    local prots = req.prots
    local categories = req.categories

    for _, grid in pairs(prots("equipment-grid")) do
        grid_power_sources[grid.name] = {}

        local grid_cats = {}
        for _, cat in pairs(grid.equipment_categories) do
            grid_cats[cat] = true
        end

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
-- Combat-related lookups
----------------------------------------------------------------------

-- Maps damage types to sources that can deal that damage type
stage2.damage_type_sources = function(lu, req)
    local damage_type_sources = {}
    local prots = req.prots
    local gutils = req.gutils
    local tutils = req.tutils

    for _, damage in pairs(prots("damage-type")) do
        damage_type_sources[damage.name] = {}
    end

    local function add_damage_source(damage_type, source_key, amount, source_type)
        if damage_type_sources[damage_type] == nil then
            damage_type_sources[damage_type] = {}
        end
        if damage_type_sources[damage_type][source_key] == nil or
           damage_type_sources[damage_type][source_key].amount < amount then
            damage_type_sources[damage_type][source_key] = {
                amount = amount,
                source_type = source_type,
            }
        end
    end

    local function extract_damage_from_structs(structs, source_key, source_type)
        if structs["damage-parameters"] ~= nil then
            for _, dp in pairs(structs["damage-parameters"]) do
                if dp.type ~= nil and dp.amount ~= nil and dp.amount > 0 then
                    add_damage_source(dp.type, source_key, dp.amount, source_type)
                end
            end
        end
    end

    -- 1. AMMO ITEMS
    for item_name, item in pairs(lu.items) do
        if item.type == "ammo" then
            local structs = {}
            tutils.gather_ammo_structs(structs, item, nil)
            extract_damage_from_structs(structs, gutils.key("item", item_name), "ammo")
        end
    end

    -- 2. TURRETS WITH BUILT-IN DAMAGE
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

    -- 3. COMBAT ROBOTS
    for entity_name, entity in pairs(lu.entities) do
        if entity.type == "combat-robot" then
            local structs = {}
            tutils.gather_combat_robot_structs(structs, entity, nil)
            extract_damage_from_structs(structs, gutils.key("entity", entity_name), "entity")
        end
    end

    -- 4. EQUIPMENT WITH ATTACK
    for equip_name, equip in pairs(lu.equipment) do
        if equip.type == "active-defense-equipment" then
            local structs = {}
            tutils.gather_active_defense_equipment_structs(structs, equip, nil)
            extract_damage_from_structs(structs, gutils.key("equipment", equip_name), "equipment")
        end
    end

    lu.damage_type_sources = damage_type_sources
end

-- A table for entities to resistance groups
stage2.entity_resistance_groups = function(lu, req)
    local entity_resistance_groups = {
        to_resistance = {},
        to_entity = {},
        groups = {},
    }
    local categories = req.categories
    local gutils = req.gutils

    -- Reusable table for immunities (optimization)
    local immunities = {}

    for _, entity in pairs(lu.entities) do
        if not categories.without_health[entity.type] then
            -- Clear and reuse immunities table
            for k in pairs(immunities) do immunities[k] = nil end
            local is_immune = {}
            local count = 0

            if entity.resistances ~= nil then
                for _, resistance in pairs(entity.resistances) do
                    if resistance.percentage ~= nil and resistance.percentage >= 100 then
                        count = count + 1
                        immunities[count] = resistance.type
                        is_immune[resistance.type] = true
                    end
                end
            end

            -- Sort only the used portion
            if count > 1 then
                table_sort(immunities, function(a, b)
                    if a == nil then return false end
                    if b == nil then return true end
                    return a < b
                end)
            end

            -- Build key from sorted immunities
            local key_parts = {}
            for i = 1, count do
                key_parts[i] = immunities[i]
            end
            local immunities_key = gutils.concat(key_parts)

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

-- Maps ammo categories to things that can shoot that category
stage2.ammo_category_sources = function(lu, req)
    local ammo_category_sources = {}
    local prots = req.prots
    local dutils = req.dutils
    local gutils = req.gutils

    for _, cat in pairs(prots("ammo-category")) do
        ammo_category_sources[cat.name] = {}
    end

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

    for _, turret in pairs(prots("ammo-turret")) do
        if lu.entities[turret.name] ~= nil then
            add_sources(turret.attack_parameters, gutils.key("entity", turret.name), "turret")
        end
    end

    for _, gun in pairs(prots("gun")) do
        add_sources(gun.attack_parameters, gutils.key("item", gun.name), "gun")
    end

    lu.ammo_category_sources = ammo_category_sources
end

----------------------------------------------------------------------
-- Science/Technology lookups
----------------------------------------------------------------------

-- Maps science pack set names to labs that can accept ALL packs in the set
-- OPTIMIZED: Pre-compute lab input sets once
stage2.science_set_to_labs = function(lu, req)
    local science_set_to_labs = {}
    local prots = req.prots

    -- Pre-compute lab input sets once (optimization)
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

-- Technologies that unlock the ability to send starter packs to space
stage2.space_platform_unlock_techs = function(lu, req)
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

-- Maps recipe names to technologies that unlock them
stage2.recipe_to_techs = function(lu, req)
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

stage2.space_location_to_discovery_techs = function(lu, req)
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

----------------------------------------------------------------------
-- Recipe-related lookups
----------------------------------------------------------------------

-- Recipe subgroups (complex calculation)
stage2.recipe_subgroup = function(lu, req)
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
            local found = false
            for _, result in pairs(recipe.results) do
                if result.name == recipe.main_product then
                    recipe_subgroup[recipe.name] = type_to_lookup[result.type][result.name].subgroup or "other"
                    found = true
                    break
                end
            end
            if not found then
                recipe_subgroup[recipe.name] = "other"
            end
        elseif #recipe.results == 1 then
            recipe_subgroup[recipe.name] = type_to_lookup[recipe.results[1].type][recipe.results[1].name].subgroup or "other"
        else
            recipe_subgroup[recipe.name] = "other"
        end
    end

    lu.recipe_subgroup = recipe_subgroup
end

-- Recipe categories (spoofed to include fluid counts)
stage2.rcats = function(lu, req)
    local rcats = {}
    local lutils = req.lutils

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

-- Maps base recipe category names to their spoofed rcat names
stage2.cat_to_rcats = function(lu, req)
    local cat_to_rcats = {}

    for rcat_name, rcat in pairs(lu.rcats) do
        if cat_to_rcats[rcat.cat] == nil then
            cat_to_rcats[rcat.cat] = {}
        end
        cat_to_rcats[rcat.cat][rcat_name] = true
    end

    lu.cat_to_rcats = cat_to_rcats
end

----------------------------------------------------------------------
-- Fuel-related lookups
----------------------------------------------------------------------

stage2.fcat_to_items = function(lu, req)
    local fcat_to_items = {}
    local gutils = req.gutils

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

-- Combinations of fuel categories and burnt inventory size
stage2.fcat_combos = function(lu, req)
    local fcat_combos = {}
    local dutils = req.dutils
    local lutils = req.lutils
    local categories = req.categories

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
stage2.fcat_to_burners = function(lu, req)
    local fcat_to_burners = {}
    local dutils = req.dutils
    local categories = req.categories

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

----------------------------------------------------------------------
-- Mining-related lookups
----------------------------------------------------------------------

-- Maps spoofed resource category to mining drills
stage2.mcat_to_drills = function(lu, req)
    local mcat_to_drills = {}
    local prots = req.prots
    local gutils = req.gutils

    for _, drill_type in pairs({"mining-drill", "character"}) do
        for _, drill in pairs(prots(drill_type)) do
            if lu.entities[drill.name] ~= nil then
                local has_input_box = drill.input_fluid_box ~= nil
                local has_output_box = drill.output_fluid_box ~= nil
                local resource_cats = drill.resource_categories or drill.mining_categories or {"basic-solid"}

                for _, base_cat in pairs(resource_cats) do
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

----------------------------------------------------------------------
-- Item transformation lookups (spoil, burn, etc.)
----------------------------------------------------------------------

-- Reverse map: item -> items that spoil into it
stage2.spoil_result_to_items = function(lu, req)
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
stage2.burnt_result_to_items = function(lu, req)
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

----------------------------------------------------------------------
-- Tile/Building lookups
----------------------------------------------------------------------

-- Maps tiles to items that can place them
stage2.place_as_tile_items = function(lu, req)
    local place_as_tile_items = {}

    for _, item in pairs(lu.items) do
        if item.place_as_tile ~= nil then
            local tile_name = item.place_as_tile.result
            if place_as_tile_items[tile_name] == nil then
                place_as_tile_items[tile_name] = {}
            end

            local condition_info = {}

            if item.place_as_tile.condition ~= nil and item.place_as_tile.condition.layers ~= nil then
                condition_info.blocking_layers = item.place_as_tile.condition.layers
            end

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

-- Maps tiles (with fluid) to offshore pumps that can pump from them
-- OPTIMIZED: Only iterates tiles with fluid (via lu.fluid_to_tiles)
stage2.tile_valid_pumps = function(lu, req)
    local tile_valid_pumps = {}
    local prots = req.prots
    local collision_mask_util = req.collision_mask_util

    -- Only check tiles that have fluids
    for _, tile in pairs(prots("tile")) do
        if tile.fluid ~= nil then
            tile_valid_pumps[tile.name] = {}

            for _, pump in pairs(prots("offshore-pump")) do
                if pump.fluid_box.filter == nil then
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
-- OPTIMIZED: Uses lu.autoplace_control_to_prots instead of iterating all prots
stage2.room_tile_maps = function(lu, req)
    local room_tiles = {}
    local tiles_to_rooms = {}
    local prots = req.prots
    local dutils = req.dutils

    -- Initialize tiles_to_rooms for all tiles
    for _, tile in pairs(prots("tile")) do
        tiles_to_rooms[tile.name] = {}
    end

    -- Optimized check_in_room that uses pre-computed autoplace_control_to_prots
    local function get_room_tiles(room)
        local results = {}

        if room.type == "planet" then
            local planet = data.raw.planet[room.name]

            if planet.map_gen_settings ~= nil then
                local map_gen_settings = planet.map_gen_settings

                -- Check autoplace_settings
                if map_gen_settings.autoplace_settings ~= nil then
                    local autoplace_settings = map_gen_settings.autoplace_settings["tile"]

                    if autoplace_settings ~= nil and autoplace_settings.settings ~= nil then
                        for prot_name, _ in pairs(autoplace_settings.settings) do
                            local prot_data = dutils.get_prot("tile", prot_name)
                            if prot_data ~= nil then
                                if autoplace_settings.treat_missing_as_default or prot_data.autoplace ~= nil then
                                    results[prot_name] = true
                                end
                            end
                        end
                    end
                end

                -- Check autoplace_controls - OPTIMIZED using pre-computed mapping
                if map_gen_settings.autoplace_controls ~= nil then
                    local control_map = lu.autoplace_control_to_prots["tile"]
                    for control, _ in pairs(map_gen_settings.autoplace_controls) do
                        if control_map[control] ~= nil then
                            for prot_name, _ in pairs(control_map[control]) do
                                results[prot_name] = true
                            end
                        end
                    end
                end
            end
        end

        return results
    end

    -- Build room_tiles, then invert for tiles_to_rooms
    for room_key, room in pairs(lu.rooms) do
        room_tiles[room_key] = get_room_tiles(room)

        for tile_name, _ in pairs(room_tiles[room_key]) do
            tiles_to_rooms[tile_name][room_key] = true
        end
    end

    lu.room_tiles = room_tiles
    lu.tiles_to_rooms = tiles_to_rooms
end

----------------------------------------------------------------------
-- Entity spawn/loot lookups
----------------------------------------------------------------------

-- Maps items to entities that drop them as loot
stage2.loot_to_entities = function(lu, req)
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

-- Maps entities to what they spawn when dying
stage2.dying_spawns = function(lu, req)
    local dying_spawns = {}
    local dying_spawns_reverse = {}
    local gutils = req.gutils
    local tutils = req.tutils

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

            local gather_func = tutils.type_to_gather_struct_func[entity.type]
            if gather_func ~= nil then
                local structs = {}
                gather_func(structs, entity, nil)

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
stage2.capsule_spawns = function(lu, req)
    local capsule_spawns = {}
    local capsule_spawns_reverse = {}
    local tutils = req.tutils

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
            local structs = {}
            tutils.gather_capsule_structs(structs, item, nil)

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
stage2.ammo_spawns = function(lu, req)
    local ammo_spawns = {}
    local ammo_spawns_reverse = {}
    local tutils = req.tutils

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
            local structs = {}
            tutils.gather_ammo_structs(structs, item, nil)

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

----------------------------------------------------------------------
-- Entity property lookups
----------------------------------------------------------------------

-- Maps entities to their output fluid (boilers, fusion-reactors, fusion-generators)
stage2.entity_output_fluids = function(lu, req)
    local entity_output_fluids = {}

    for _, entity in pairs(lu.entities) do
        local output_fluid = nil

        if entity.type == "boiler" then
            if entity.output_fluid_box ~= nil and entity.output_fluid_box.filter ~= nil then
                local input_filter = entity.fluid_box and entity.fluid_box.filter
                if entity.output_fluid_box.filter ~= input_filter then
                    output_fluid = entity.output_fluid_box.filter
                end
            end
        elseif entity.type == "fusion-reactor" then
            if entity.output_fluid_box ~= nil and entity.output_fluid_box.filter ~= nil then
                output_fluid = entity.output_fluid_box.filter
            end
        elseif entity.type == "fusion-generator" then
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

-- Creator tables (which prototypes create which)
local function get_default_creator_table(prototype)
    return {
        created_by = {},
        creates = {},
        prototype = prototype,
    }
end

stage2.creator_tables = function(lu, req)
    local creator_tables = {}
    local gutils = req.gutils
    local tutils = req.tutils

    -- Helper to add creator relationship
    local function add_relationship(created_key, created_prot, creator_key, creator_prot)
        if creator_tables[created_key] == nil then
            creator_tables[created_key] = get_default_creator_table(created_prot)
        end
        if creator_tables[creator_key] == nil then
            creator_tables[creator_key] = get_default_creator_table(creator_prot)
        end
        creator_tables[created_key].created_by[creator_key] = creator_prot
        creator_tables[creator_key].creates[created_key] = created_prot
    end

    -- Helper to process structs and add relationships
    local function process_structs(structs, creator_key, creator_prot)
        for struct_type, prototypes in pairs(structs) do
            if type(prototypes) == "table" then
                for prot_name, created_prot in pairs(prototypes) do
                    -- Only process actual prototypes with name
                    if type(created_prot) == "table" and created_prot.name ~= nil then
                        -- Use struct_type as the type (more reliable than created_prot.type)
                        local created_key = gutils.key(struct_type, created_prot.name)
                        add_relationship(created_key, created_prot, creator_key, creator_prot)
                    end
                end
            end
        end
    end

    -- Iterate items ONCE using type_to_gather_struct_func dispatch
    local gather_struct_func = tutils.type_to_gather_struct_func
    for item_name, item in pairs(lu.items) do
        local gather_func = gather_struct_func[item.type]
        if gather_func ~= nil then
            local structs = {}
            structs[item.type] = {[item_name] = item}
            gather_func(structs, item, nil)
            process_structs(structs, gutils.key("item", item_name), item)
        end
    end

    -- Iterate entities ONCE
    for entity_name, entity in pairs(lu.entities) do
        local gather_func = gather_struct_func[entity.type]
        if gather_func ~= nil then
            local structs = {}
            structs[entity.type] = {[entity_name] = entity}
            gather_func(structs, entity, nil)
            process_structs(structs, gutils.key("entity", entity_name), entity)
        end
    end

    -- Iterate equipment ONCE
    for equip_name, equip in pairs(lu.equipment) do
        local gather_func = gather_struct_func[equip.type]
        if gather_func ~= nil then
            local structs = {}
            structs[equip.type] = {[equip_name] = equip}
            gather_func(structs, equip, nil)
            process_structs(structs, gutils.key("equipment", equip_name), equip)
        end
    end

    lu.creator_tables = creator_tables
end

-- Buildable entities/tiles from items
stage2.buildables = function(lu, req)
    local buildables = {}
    local dutils = req.dutils
    local gutils = req.gutils

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

-- Combined items and fluids
stage2.materials = function(lu, req)
    local materials = {}
    local gutils = req.gutils

    for _, item in pairs(lu.items) do
        materials[gutils.key("item", item.name)] = item
    end
    for _, fluid in pairs(lu.fluids) do
        materials[gutils.key("fluid", fluid.name)] = fluid
    end

    lu.materials = materials
end

-- Minable corpses to entities that create them
stage2.minable_corpse = function(lu, req)
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
stage2.operable_entities = function(lu, req)
    local operable_entities = {}

    for _, entity in pairs(lu.entities) do
        if entity.flags ~= nil then
            for _, flag in pairs(entity.flags) do
                if flag == "player-creation" or flag == "placeable-player" then
                    operable_entities[entity.name] = true
                end
            end
        end
        if entity.type == "character" then
            operable_entities[entity.name] = true
        end
    end

    lu.operable_entities = operable_entities
end

return stage2
