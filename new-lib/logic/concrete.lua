-- Concrete node definitions for the dependency graph
-- These represent "concrete" types of things - usually with a related prototype

local collision_mask_util
if not offline then
    collision_mask_util = require("__core__/lualib/collision-mask-util")
else
    collision_mask_util = require("offline/lualib/collision-mask-util")
end

local lib_name = "new-lib"
local categories = require("helper-tables/categories")
local dutils = require(lib_name .. "/data-utils")
local gutils = require(lib_name .. "/graph/graph-utils")
local lutils = require(lib_name .. "/logic/logic-utils")
local builder = require(lib_name .. "/logic/builder")

local prots = dutils.prots
local key = gutils.key
local concat = gutils.concat
local add_node = builder.add_node
local add_edge = builder.add_edge
local set_class = builder.set_class
local set_prot = builder.set_prot

local concrete = {}

function concrete.build(lu)
    ----------------------------------------------------------------------
    -- Ammo Category
    ----------------------------------------------------------------------

    set_class("ammo-category")

    for _, cat in pairs(prots("ammo-category")) do
        set_prot(cat)

        ----------------------------------------
        add_node("ammo-category", "OR")
        ----------------------------------------
        -- Can we use ammo of this ammo_category in some ammo turret or gun?

        local sources = lu.ammo_category_sources[cat.name]
        if sources ~= nil then
            for source_key, source_type in pairs(sources) do
                local source_info = gutils.deconstruct(source_key)
                if source_type == "turret" then
                    -- Ammo turrets: need the turret operational
                    add_edge("entity-operate", source_info.name)
                elseif source_type == "gun" then
                    -- Guns: need the gun item + planet (player uses guns on planets only)
                    -- Guns can't be "automated"
                    add_edge("item-gun", source_info.name, nil, cat.name, {
                        abilities = { [2] = false },
                    })
                end
            end
        end
    end

    ----------------------------------------------------------------------
    -- Asteroid Chunk
    ----------------------------------------------------------------------

    set_class("asteroid-chunk")

    for _, chunk in pairs(prots("asteroid-chunk")) do
        set_prot(chunk)

        ----------------------------------------
        add_node("asteroid-chunk", "OR")
        ----------------------------------------
        -- Can we encounter this asteroid chunk?

        -- Edges from locations that spawn this chunk naturally
        if lu.asteroid_to_place[key("asteroid-chunk", chunk.name)] ~= nil then
            for place_name, place in pairs(lu.asteroid_to_place[key("asteroid-chunk", chunk.name)]) do
                local node_type
                if place.type == "space-connection" then
                    node_type = "space-connection"
                else
                    node_type = "space-location"
                end
                add_edge(node_type, place.name)
            end
        end
        -- Edges from entities that spawn this chunk when dying
        if lu.dying_spawns_reverse[key("asteroid-chunk", chunk.name)] ~= nil then
            for entity_key, _ in pairs(lu.dying_spawns_reverse[key("asteroid-chunk", chunk.name)]) do
                local entity_info = gutils.deconstruct(entity_key)
                if entity_info.type == "entity" then
                    add_edge("entity-kill", entity_info.name)
                end
            end
        end

        ----------------------------------------
        add_node("asteroid-chunk-mine", "AND")
        ----------------------------------------
        -- Can we mine this asteroid chunk?
        -- Requires: chunk + asteroid collector

        -- Asteroid chunks can be mined automatically
        add_edge("asteroid-chunk", chunk.name, {
            abilities = { [2] = true },
        })
        add_edge("asteroid-collector", "")
    end

    ----------------------------------------------------------------------
    -- Damage Type
    ----------------------------------------------------------------------

    set_class("damage-type")

    for _, damage in pairs(prots("damage-type")) do
        set_prot(damage)

        ----------------------------------------
        add_node("damage-type", "OR")
        ----------------------------------------
        -- Can we deal damage of this type?
        -- OR over: ammo items, turrets with built-in damage, combat robots, equipment
        -- Note: Land mines excluded due to offensive drawbacks

        local sources = lu.damage_type_sources[damage.name]
        if sources ~= nil then
            for source_key, source_info in pairs(sources) do
                local source = gutils.deconstruct(source_key)
                if source_info.source_type == "ammo" then
                    -- Ammo items: need item-ammo (which checks ammo-category)
                    add_edge("item-ammo", source.name, {
                        damage_amount = source_info.amount,
                    })
                elseif source_info.source_type == "turret" then
                    -- Turrets with built-in damage (electric/fluid)
                    add_edge("entity-operate", source.name, {
                        damage_amount = source_info.amount,
                    })
                elseif source_info.source_type == "entity" then
                    -- Combat robots: come from capsules, entity must be creatable
                    add_edge("entity", source.name, {
                        damage_amount = source_info.amount,
                        abilities = { [2] = false },
                    })
                elseif source_info.source_type == "equipment" then
                    -- Equipment: need equipment-operate
                    add_edge("equipment-operate", source.name, {
                        damage_amount = source_info.amount,
                        abilities = { [2] = false },
                    })
                end
            end
        end
    end

    ----------------------------------------------------------------------
    -- Entity
    ----------------------------------------------------------------------

    set_class("entity")

    for _, entity in pairs(lu.entities) do
        set_prot(entity)

        ----------------------------------------
        add_node("entity", "OR")
        ----------------------------------------
        -- Can we encounter this entity? (Previously called spawn-entity)

        -- TODO: Should any of these turn off automatability?
        local buildable = lu.buildables[key(entity)]
        if buildable ~= nil then
            add_edge("entity-build")
        end
        -- Check if the entity is put automatically in a room (planet/space surface)
        for room_key, room in pairs(lu.rooms) do
            if lutils.check_in_room(room, entity) then
                -- Technically, we should check that there are non-colliding tiles too, but it would be very silly to have an entity in autoplace that can't be placed somewhere
                add_edge("room", room_key, {
                    abilities = { [1] = true },
                }) -- Being from a room leads to isolatability
            end
        end
        -- Check if entity could be the corpse of another entity
        if categories.corpse[entity.type] and lu.minable_corpses[entity.name] ~= nil then
            for other_entity, _ in pairs(lu.minable_corpses[entity.name]) do
                add_edge("entity-kill", other_entity)
            end
        end
        -- Check if for spawners that capture into this entity
        if lu.unit_spawner_captures[entity.name] ~= nil then
            for _, spawner in pairs(lu.unit_spawner_captures[entity.name]) do
                add_edge("entity-capture-spawner", spawner.name)
            end
        end
        -- Check if entity spawns from a capsule (only on planets)
        if lu.capsule_spawns_reverse[entity.name] ~= nil then
            for item_name, _ in pairs(lu.capsule_spawns_reverse[entity.name]) do
                add_edge("item-capsule", item_name)
            end
        end
        if lu.ammo_spawns_reverse[entity.name] ~= nil then
            for item_name, _ in pairs(lu.ammo_spawns_reverse[entity.name]) do
                add_edge("item-ammo", item_name)
            end
        end
        -- Asteroid spawning in space
        if lu.asteroid_to_place[key("entity", entity.name)] ~= nil then
            for place_name, place in pairs(lu.asteroid_to_place[key("entity", entity.name)]) do
                local node_type
                if place.type == "space-connection" then
                    node_type = "space-connection"
                else
                    node_type = "space-location"
                end
                add_edge(node_type, place.name)
            end
        end
        -- Check if entity spawns from dying trigger effects
        if lu.dying_spawns_reverse[key("entity", entity.name)] ~= nil then
            for dying_entity_key, _ in pairs(lu.dying_spawns_reverse[key("entity", entity.name)]) do
                local dying_info = gutils.deconstruct(dying_entity_key)
                if dying_info.type == "entity" then
                    add_edge("entity-kill", dying_info.name)
                end
            end
        end
        -- Check if we can get access this through it being our character
        if entity.type == "character" then
            add_edge("entity-character", entity.name, {
                abilities = { [1] = true } -- Characters are always "local"
            })
        end

        if buildable ~= nil then
            ----------------------------------------
            add_node("entity-build", "AND")
            ----------------------------------------
            -- Can we build this entity using an item?
            -- Entities that can be planted are counted as being built, though later during
            -- randomization we might have to condition on it being a planted or built entity

            add_edge("entity-build-item")
            add_edge("entity-build-tile")
            if entity.surface_conditions ~= nil and #entity.surface_conditions > 0 then
                add_edge("entity-build-surface-condition")
            end
            -- If it's a rolling stock (locomotive/cargo wagon/etc.), check that we can build some rail that it does not collide with
            -- Technically, we should test that the rail also shares a tile with the locomotive that both can be placed on, but also I could have a life and I think I'd take the latter
            if categories.rolling_stock[entity.type] then
                add_edge("entity-build-rail")

                ----------------------------------------
                add_node("entity-build-rail", "OR")
                ----------------------------------------
                -- Can we build a rail to put this rolling stock on?

                -- TODO: I was testing on every rail for every rolling stock, but this is inefficient; I should be testing on groups of rails. Otherwise, we'd get too many edges.
                add_edge("satisfied", "")

                --[[for rail_class, _ in pairs(categories.rail) do
                    for _, rail in pairs(prots(rail_class)) do
                        add_edge("entity", rail.name)
                    end
                end]]
            end

            ----------------------------------------
            add_node("entity-build-item", "OR")
            ----------------------------------------
            -- Can we get an item needed to build this entity?

            for item, prop in pairs(buildable) do
                add_edge("item", item, {
                    build_key = prop,
                })
            end

            if entity.surface_conditions ~= nil and #entity.surface_conditions > 0 then
                ----------------------------------------
                add_node("entity-build-surface-condition", "OR")
                ----------------------------------------
                -- Can we access a room with the right surface conditions for this entity?

                for room_key, room in pairs(lu.rooms) do
                    if lutils.check_surface_conditions(room, entity.surface_conditions or {}) then
                        add_edge("room", room_key)
                    end
                end
            end

            ----------------------------------------
            add_node("entity-build-tile", "OR")
            ----------------------------------------
            -- Can we access a tile on which the entity can be built? (i.e., no collision)

            -- For optimization, we precompute possible tile collision masks and make a tile-collision node for each group, then simply have this depend on the right groups
            -- If there's a restriction, this gets more complicated, so just depend on the individual tiles (note that this overrides collision masks)
            if not (entity.autoplace ~= nil and entity.autoplace.tile_restriction ~= nil) then
                add_edge("entity-collision-group", lu.entity_to_collision_group[entity.name])
            else
                -- This is luckily an OR over tiles and transitions
                for _, restriction in pairs(entity.autoplace.tile_restriction) do
                    -- Ignore transition restrictions (those could play a role but only in mods that force buildings to be on specific transitions)
                    -- Still check collision in case a mod does something dumb since that's easy
                    if type(restriction) == "string" and not collision_mask_util.masks_collide(data.raw.tile[restriction].collision_mask, entity.collision_mask or collision_mask_util.get_default_mask(entity.type)) then
                        add_edge("tile", restriction)
                    end
                end
            end
        end

        if lu.operable_entities[entity.name] then
            ----------------------------------------
            add_node("entity-operate", "AND")
            ----------------------------------------
            -- Can we operate this entity (ensure it's heated, powered, etc.)?

            add_edge("entity", entity.name, {
                abilities = { [2] = true } -- Automatic operation doesn't require automatic production
            })
            if categories.energy_sources_input[entity.type] then
                add_edge("entity-operate-energy")
            end
            if categories.fluid_required[entity.type] then
                add_edge("entity-operate-fluid")
            end
            -- Thrusters need two specific fluids (AND), not a generic fluid requirement
            if entity.type == "thruster" then
                add_edge("fluid", entity.fuel_fluid_box.filter)
                add_edge("fluid", entity.oxidizer_fluid_box.filter)
            end
            if lutils.check_freezable(entity) then
                add_edge("warmth", "")
            end
            -- Note: Turrets are "operable" without ammo; since the damage is on the ammo, we actually need to check if there is a turret to shoot an ammo rather than check if there is ammo for a turret to shoot
            -- TODO: Module requirements (for mods like PyAL)

            if categories.fluid_required[entity.type] then
                ----------------------------------------
                add_node("entity-operate-fluid", "OR")
                ----------------------------------------
                -- Can we provide a fluid this entity needs to operate?

                -- Different entity types have different fluid input properties
                -- See categories.fluid_required: boiler, fusion-generator, fusion-reactor, generator, fluid-turret

                if entity.type == "boiler" then
                    -- Boilers use fluid_box for input
                    if entity.fluid_box.filter ~= nil then
                        add_edge("fluid", entity.fluid_box.filter)
                    else
                        -- No filter - boiler heats any fluid (powered by energy source, not the fluid)
                        -- TODO: Implement proper fluid availability check
                        add_edge("satisfied", "")
                    end
                elseif entity.type == "fusion-generator" then
                    -- Fusion generators use input_fluid_box (required field per API)
                    if entity.input_fluid_box.filter ~= nil then
                        add_edge("fluid", entity.input_fluid_box.filter)
                    end
                elseif entity.type == "fusion-reactor" then
                    -- Fusion reactors use input_fluid_box (required field per API)
                    if entity.input_fluid_box.filter ~= nil then
                        add_edge("fluid", entity.input_fluid_box.filter)
                    end
                elseif entity.type == "generator" then
                    -- Generators can have filtered fluid_box or burn any fuel fluid
                    if entity.fluid_box.filter ~= nil then
                        add_edge("fluid", entity.fluid_box.filter)
                    elseif entity.burns_fluid then
                        -- Any fluid with fuel_value works
                        add_edge("energy-source-fluid", "")
                    else
                        -- Non-burning generator without filter (steam engine style)
                        -- In vanilla, all steam engines have filters (steam), so this branch is unlikely
                        -- TODO: Implement temperature requirements for proper fluid matching
                        add_edge("satisfied", "")
                    end
                -- TODO: Store damage_modifier on edges so reflection can reconstruct appropriate modifiers for new fluids
                elseif entity.type == "fluid-turret" then
                    -- Fluid turrets specify fluids in attack_parameters.fluids
                    if entity.attack_parameters ~= nil and entity.attack_parameters.fluids ~= nil then
                        for ind, stream_fluid in pairs(entity.attack_parameters.fluids) do
                            add_edge("fluid", stream_fluid.type, {
                                ind = ind,
                            })
                        end
                    end
                end
            end

            if categories.energy_sources_input[entity.type] ~= nil then
                ----------------------------------------
                add_node("entity-operate-energy", "OR")
                ----------------------------------------
                -- Can we power this entity?

                -- Note: Entities still depend on "void" energy source even if their energy_source is nil so that randomization is still possible
                -- The energy source nodes are generic/entity independent, but burner energy sources that have different fuel_categories are counted as distinct
                -- TODO: Later, also distinguish fluid energy sources based off fluid box filters/whether they burn fluid, and heat energy sources based on min/max heat etc., but for now just having one of each is fine
                for _, energy_prop in pairs(dutils.tablize(categories.energy_sources_input[entity.type])) do
                    local energy_source = entity[energy_prop]
                    if energy_source == nil or energy_source.type == "void" then
                        add_edge("energy-source-void", "")
                    elseif energy_source.type == "burner" then
                        add_edge("energy-source-burner", lutils.fcat_combo_name(energy_source))
                    elseif energy_source.type == "electric" then
                        add_edge("energy-source-electric", "")
                    elseif energy_source.type == "fluid" then
                        add_edge("energy-source-fluid", "")
                    elseif energy_source.type == "heat" then
                        add_edge("energy-source-heat", "")
                    end
                end
            end
        end

        -- Just check for asteroids and other critical entities now for performance
        if not categories.without_health[entity.type] and (entity.type == "asteroid" or lu.dying_spawns[key("entity", entity.name)] or (entity.loot ~= nil and #entity.loot > 0) or (entity.corpse ~= nil and lu.minable_corpses[entity.corpse])) then
            ----------------------------------------
            add_node("entity-kill", "AND")
            ----------------------------------------
            -- Can we kill this entity?
            -- Created for anything that could have health.

            -- We just check for immunities here, i.e.- 100% or more resistance
            -- Later, in logic-balancing.lua we can worry about "virtually immune" entities/health amounts etc.
            -- We also might want edges to damage types for representing resistances to randomize later, but when I do that I can decide what specific entities to touch
            -- Building every entity-damage type combination seems like a lot to me now, which is why I'm doing it this way
            add_edge("resistance-group", lu.entity_resistance_groups.to_resistance[entity.name])
            add_edge("entity")
        end

        if entity.minable ~= nil then
            ----------------------------------------
            add_node("entity-mine", "AND")
            ----------------------------------------
            -- Can we mine this entity?

            if entity.type == "resource" then
                add_edge("entity", entity.name, {
                    abilities = { [2] = true },
                })
                -- For resources requiring fluid: need the specific fluid + tech unlock
                -- These are separate edges because different resources may need different fluids
                -- Note that if we wanted to be especially careful, we'd check mining drill filters too, but we'll leave that for another time
                if entity.minable.required_fluid ~= nil then
                    add_edge("fluid", entity.minable.required_fluid)
                    add_edge("mining-with-fluid-unlock", "", {
                        abilities = { [2] = true }, -- I don't know if I'll count unlocks as "automatable", but resources should be automatable as long as fluid is (if any), and the drill is automatically operable
                    })
                end

                -- Resource category checks drill capability (right category + fluid boxes)
                -- The mcat_name includes has_input/has_output flags
                add_edge("resource-category", lutils.mcat_name(entity)) -- Need to be able to automatically operate the entity to automate the resources
            else
                add_edge("entity", entity.name, {
                    abilities = { [2] = false },
                })
            end
        end

        if entity.type == "unit-spawner" then
            ----------------------------------------
            add_node("entity-capture-spawner", "AND")
            ----------------------------------------
            -- Can we capture this unit spawner?

            add_edge("entity")
            add_edge("capture-robot", "")
        end

        if entity.type == "character" then
            ----------------------------------------
            add_node("entity-character", "OR")
            ----------------------------------------
            -- Can we inhabit this character entity?

            -- I was originally planning to use this node to test for ability to throw capsules and such, but then just tested for whether you're on a planet
            -- TODO: Decide if I want to keep this

            if entity.name == lutils.starting_character_name then
                add_edge("starting-character", "")
            end
        end

        if entity.type == "rocket-silo" then
            ----------------------------------------
            add_node("entity-rocket-silo", "AND")
            ----------------------------------------
            -- Can we use this rocket silo for launching?
            -- Combines entity-operate with the silo's fixed recipe requirement.

            add_edge("entity-operate")
            if entity.fixed_recipe ~= nil and lu.recipes[entity.fixed_recipe] ~= nil then
                add_edge("recipe", entity.fixed_recipe)
            end
            -- If no fixed recipe, silo can be used without crafting (edge case)
        end
    end

    ----------------------------------------------------------------------
    -- Equipment
    ----------------------------------------------------------------------

    -- Equipment power is SEPARATE from world entity power.
    -- Grids have their own internal power pool.
    -- Note: Size constraints not checked (equipment might be too large for grid).

    set_class("equipment")

    for equip_name, equip in pairs(lu.equipment) do
        set_prot(equip)

        ----------------------------------------
        add_node("equipment", "AND")
        ----------------------------------------
        -- Can we use this equipment?
        -- Requires: way to place it + planet (equipment works where player is)

        add_edge("equipment-place")
        add_edge("planet", "")  -- Equipment only works on planets, not in space

        ----------------------------------------
        add_node("equipment-place", "OR")
        ----------------------------------------
        -- Can we place this equipment in some grid?
        -- OR over items that place this equipment.

        local placing_items = lu.equipment_to_items[equip_name]
        if placing_items ~= nil then
            for item_name, _ in pairs(placing_items) do
                add_edge("item", item_name)
            end
        end

        -- Determine power type using categories tables
        local power_type = "void"
        if categories.equipment_power_producers[equip.type] then
            power_type = "producer"  -- Producers don't need external power
        elseif categories.equipment_power_consumers[equip.type] then
            -- Check if this specific equipment has burner instead of electric
            if equip.burner ~= nil or (equip.energy_source ~= nil and equip.energy_source.type == "burner") then
                power_type = "burner"
            elseif equip.energy_source == nil then
                power_type = "void"  -- No energy source defined = void/optional
            else
                power_type = "electric"
            end
        else
            -- Unknown equipment type - check energy_source/burner fields
            if equip.burner ~= nil or (equip.energy_source ~= nil and equip.energy_source.type == "burner") then
                power_type = "burner"
            elseif equip.energy_source ~= nil and equip.energy_source.type == "electric" then
                power_type = "electric"
            end
        end

        if power_type == "electric" then
            ----------------------------------------
            add_node("equipment-operate", "AND")
            ----------------------------------------
            -- Can we operate this electric-powered equipment?
            -- Requires: equipment + power from a compatible grid

            add_edge("equipment")
            add_edge("equipment-operate-power")

            ----------------------------------------
            add_node("equipment-operate-power", "OR")
            ----------------------------------------
            -- Can we power this equipment?
            -- OR over equipment categories that can be powered.
            -- Note: Not checking size constraints.

            local equip_cats = equip.categories or {}
            for _, cat in pairs(equip_cats) do
                add_edge("equipment-category-powered", cat)
            end

        elseif power_type == "burner" then
            ----------------------------------------
            add_node("equipment-operate", "AND")
            ----------------------------------------
            -- Can we operate this burner-powered equipment?
            -- Requires: equipment + fuel

            add_edge("equipment")
            local burner = equip.burner or equip.energy_source
            if burner ~= nil then
                add_edge("energy-source-burner", lutils.fcat_combo_name(burner))
            end

        elseif power_type == "void" then
            ----------------------------------------
            add_node("equipment-operate", "AND")
            ----------------------------------------
            -- Can we operate this void-powered equipment?
            -- Consumers with optional power need void energy source.

            add_edge("equipment")
            add_edge("energy-source-void", "")

        else
            ----------------------------------------
            add_node("equipment-operate", "AND")
            ----------------------------------------
            -- Can we operate this producer equipment?
            -- Producers just need to be placed (they generate power, not consume).

            add_edge("equipment")
        end
    end

    ----------------------------------------------------------------------
    -- Equipment Category
    ----------------------------------------------------------------------

    -- Equipment categories determine which grids equipment can go in.
    -- A category is "available" if any grid accepts it.
    -- A category is "powered" if any accepting grid can be powered.

    set_class("equipment-category")

    local seen_categories = {}
    for _, grid in pairs(prots("equipment-grid")) do
        for _, cat in pairs(grid.equipment_categories) do
            seen_categories[cat] = true
        end
    end

    for cat, _ in pairs(seen_categories) do
        set_prot(data.raw["equipment-category"][cat])

        ----------------------------------------
        add_node("equipment-category", "OR")
        ----------------------------------------
        -- Can we access a grid that accepts this equipment category?
        -- OR over grids that accept this category.

        local grids = lu.category_to_grids[cat]
        if grids ~= nil then
            for grid_name, _ in pairs(grids) do
                add_edge("equipment-grid", grid_name)
            end
        end

        ----------------------------------------
        add_node("equipment-category-powered", "OR")
        ----------------------------------------
        -- Can we access a POWERED grid that accepts this equipment category?
        -- OR over grids that accept this category AND can be powered.

        local grids = lu.category_to_grids[cat]
        if grids ~= nil then
            for grid_name, _ in pairs(grids) do
                add_edge("equipment-grid-powered", grid_name)
            end
        end
    end

    ----------------------------------------------------------------------
    -- Equipment Grid
    ----------------------------------------------------------------------

    -- Equipment grids are accessed via armors or vehicles.
    -- Nodes are by grid NAME, not category.

    set_class("equipment-grid")

    for _, grid in pairs(prots("equipment-grid")) do
        set_prot(grid)

        ----------------------------------------
        add_node("equipment-grid", "OR")
        ----------------------------------------
        -- Can we access this specific equipment grid?
        -- OR over armors/vehicles that have this grid.

        local sources = lu.grid_to_sources[grid.name]
        if sources ~= nil then
            for source_name, source_type in pairs(sources) do
                if source_type == "armor" then
                    add_edge("item", source_name)
                elseif source_type == "vehicle" then
                    add_edge("entity-operate", source_name)
                end
            end
        end

        ----------------------------------------
        add_node("equipment-grid-powered", "AND")
        ----------------------------------------
        -- Can we access this grid AND power it?
        -- Requires: grid + power source that fits in this grid.

        add_edge("equipment-grid", grid.name)
        add_edge("equipment-grid-power-source", grid.name)

        ----------------------------------------
        add_node("equipment-grid-power-source", "OR")
        ----------------------------------------
        -- Can we power this specific grid?
        -- OR over power-producing equipment that can go in this grid.
        -- Depends on equipment-operate (generators can have burner energy sources).

        local power_sources = lu.grid_power_sources[grid.name]
        if power_sources ~= nil then
            for equip_name, _ in pairs(power_sources) do
                add_edge("equipment-operate", equip_name)
            end
        end
    end

    ----------------------------------------------------------------------
    -- Fluid
    ----------------------------------------------------------------------

    set_class("fluid")

    for _, fluid in pairs(lu.fluids) do
        set_prot(fluid)

        ----------------------------------------
        add_node("fluid", "AND")
        ----------------------------------------
        -- Can we obtain this fluid?
        -- Requires: some way to create it + way to hold/transport it

        add_edge("fluid-create")
        add_edge("fluid-hold")

        ----------------------------------------
        add_node("fluid-create", "OR")
        ----------------------------------------
        -- Can we create/produce this fluid?
        -- OR over: crafting, offshore pumping, mining, entity output

        local corresponding_recipes = lu.mat_recipe_map.material[key("fluid", fluid.name)].results
        if corresponding_recipes ~= nil then
            add_edge("fluid-craft")
        end
        -- Check offshore pumping possibilities
        local has_filter_pumps = lu.pumps_with_filter[fluid.name] ~= nil
        local has_tiles = lu.fluid_to_tiles[fluid.name] ~= nil
        if has_filter_pumps or has_tiles then
            add_edge("fluid-create-offshore")
        end
        -- Check if fluid comes from mining
        local corresponding_minables = lu.mat_mining_map.to_minable[key("fluid", fluid.name)]
        if corresponding_minables ~= nil then
            for minable_key, inds in pairs(corresponding_minables) do
                local minable = gutils.deconstruct(minable_key)
                add_edge(minable.type, minable.name, {
                    inds = inds,
                })
            end
        end
        -- Check if fluid comes from boiler/reactor/generator output
        if lu.entity_output_fluids ~= nil then
            for entity_name, output_fluid in pairs(lu.entity_output_fluids) do
                if output_fluid == fluid.name then
                    add_edge("entity-operate", entity_name)
                end
            end
        end

        if corresponding_recipes ~= nil then
            ----------------------------------------
            add_node("fluid-craft", "OR")
            ----------------------------------------
            -- Can we produce this fluid via recipe?

            for recipe_name, inds in pairs(corresponding_recipes) do
                add_edge("recipe", recipe_name, {
                    inds = inds,
                })
            end
        end

        if has_filter_pumps or has_tiles then
            ----------------------------------------
            add_node("fluid-create-offshore", "OR")
            ----------------------------------------
            -- Can we pump this fluid using an offshore pump?
            -- OR over: pumps with filter for this fluid, tiles that have this fluid

            -- Pumps with filter always produce this fluid
            if has_filter_pumps then
                for pump_name, _ in pairs(lu.pumps_with_filter[fluid.name]) do
                    add_edge("entity-operate", pump_name)
                end
            end

            -- Tiles with this fluid can be pumped by compatible pumps
            if has_tiles then
                for tile_name, _ in pairs(lu.fluid_to_tiles[fluid.name]) do
                    add_edge("tile-fluid", tile_name)
                end
            end
        end

        ----------------------------------------
        add_node("fluid-hold", "OR")
        ----------------------------------------
        -- Can we transport/hold this fluid? (pipes, tanks, etc.)
        -- Needed for recipes with fluid inputs/outputs when crafter isn't at source.

        -- Note: Potential optimization - could use a lookup class for filtered pipes only, with a bottleneck node depending on all pipes for the unfiltered case (not necessary for now)
        for _, pipe_class in pairs({"pipe", "pipe-to-ground", "storage-tank", "pump"}) do
            for _, pipe in pairs(prots(pipe_class)) do
                -- fluid_box is mandatory for these types per API
                if pipe.fluid_box.filter == nil or pipe.fluid_box.filter == fluid.name then
                    add_edge("entity-operate", pipe.name)
                end
            end
        end
    end

    ----------------------------------------------------------------------
    -- Fuel Category
    ----------------------------------------------------------------------

    -- Uses spoofed categories similar to recipe-category: base name + burnt flag
    -- Node name is concat({fcat_name, burnt}) to match fcat_to_items keys

    set_class("fuel-category")

    for _, fcat in pairs(prots("fuel-category")) do
        set_prot(fcat)

        -- Create nodes for both burnt=0 and burnt=1 variants if they have items
        for burnt = 0, 1 do
            local spoofed_key = concat({fcat.name, burnt})
            local items_for_fcat = lu.fcat_to_items[spoofed_key]
            if items_for_fcat ~= nil then
                ----------------------------------------
                add_node("fuel-category", "OR", nil, spoofed_key)
                ----------------------------------------
                -- Can we provide items of this (spoofed) fuel category?
                -- OR over all items with this fuel_category and burnt flag.

                for item_name, _ in pairs(items_for_fcat) do
                    add_edge("item", item_name)
                end
            end
        end

        ----------------------------------------
        add_node("fuel-category-burn", "OR")
        ----------------------------------------
        -- Can we burn fuel of this category?
        -- OR over burner entities with burnt_inventory_size > 0 for this category.
        if lu.fcat_to_burners[fcat.name] ~= nil then
            for burner_name, _ in pairs(lu.fcat_to_burners[fcat.name]) do
                add_edge("entity-operate", burner_name)
            end
        end
    end

    ----------------------------------------------------------------------
    -- Item
    ----------------------------------------------------------------------

    set_class("item")

    for _, item in pairs(lu.items) do
        set_prot(item)

        ----------------------------------------
        add_node("item", "OR")
        ----------------------------------------
        -- Can we obtain this item?

        local corresponding_recipes = lu.mat_recipe_map.material[key("item", item.name)].results
        if corresponding_recipes ~= nil then
            add_edge("item-craft")
        end
        local corresponding_minables = lu.mat_mining_map.to_minable[key("item", item.name)]
        if corresponding_minables ~= nil then
            for minable_key, inds in pairs(corresponding_minables) do
                local minable = gutils.deconstruct(minable_key)
                add_edge(minable.type, minable.name, {
                    inds = inds,
                })
            end
        end
        -- Edge from item-launch for context cycling
        -- This edge allows items to gain more contexts: an item reachable in one context
        -- can be launched to space, then delivered to a space surface, gaining that context
        local rocket_lift_weight = data.raw["utility-constants"].default.rocket_lift_weight
        if lu.weight[item.name] <= rocket_lift_weight then
            add_edge("item-deliver", item.name, {
                abilities = { [1] = false },
            })
        end
        -- Edge from items that spoil into this item
        if lu.spoil_result_to_items[item.name] ~= nil then
            for spoiling_item, _ in pairs(lu.spoil_result_to_items[item.name]) do
                local item_prot = dutils.get_prot("item", spoiling_item)
                add_edge("item", spoiling_item, {
                    spoil_ticks = item_prot.spoil_ticks,
                })
            end
        end
        -- Edge from fuels that burn into this item
        if lu.burnt_result_to_items[item.name] ~= nil then
            for fuel_item, _ in pairs(lu.burnt_result_to_items[item.name]) do
                add_edge("item-burn", fuel_item)
            end
        end
        -- Edge from entity kills that drop this as loot
        if lu.loot_to_entities[item.name] ~= nil then
            for entity_name, _ in pairs(lu.loot_to_entities[item.name]) do
                add_edge("entity-kill", entity_name, {
                    abilities = { [2] = false }, -- Even if we can automatically kill something, we can't automatically pick up its loot (at least in vanilla)
                })
            end
        end

        if item.fuel_category ~= nil and item.burnt_result ~= nil and item.burnt_result ~= "" then
            ----------------------------------------
            add_node("item-burn", "AND")
            ----------------------------------------
            -- Can we burn this item? (Possibly unlocks burnt_result items)
            -- Requires: item + burner with burnt_inventory_size > 0

            add_edge("item")
            add_edge("fuel-category-burn", item.fuel_category)
        end

        if corresponding_recipes ~= nil then
            ----------------------------------------
            add_node("item-craft", "OR")
            ----------------------------------------
            -- Can we craft this item? (Separate node needed for tech triggers)

            for recipe_name, inds in pairs(corresponding_recipes) do
                add_edge("recipe", recipe_name, {
                    -- The indices of where in the results this item is (it could be in multiple spots)
                    inds = inds,
                })
            end
        end

        local rocket_lift_weight = data.raw["utility-constants"].default.rocket_lift_weight
        if lu.weight[item.name] <= rocket_lift_weight then
            -- CRITICAL TODO: This if condition prevents deliveries of high-weight items *from* space platforms; fix this!

            ----------------------------------------
            add_node("item-launch", "AND", true)
            ----------------------------------------
            -- Can we launch this item into space?
            -- This node FORGETS context: launching makes item available to all reachable rooms
            -- Right now, this just filters through deliver to test reachability of that context/room
            -- Space surfaces can deliver anywhere, and planets can deliver if they can launch
            -- This causes planets to launch to other planets, which may not be accurate if there ever comes some extra step besides launching into space to deliver an item
            -- TODO: Address this in more generality

            add_edge("item")
            add_edge("deliver", "")

            ----------------------------------------
            add_node("item-deliver", "AND")
            ----------------------------------------
            -- Can we receive this item in a room?
            -- Filters context to reachable rooms

            add_edge("item-launch")
            add_edge("reachable-room", "")
        end

        if item.type == "ammo" then
            ----------------------------------------
            add_node("item-ammo", "AND")
            ----------------------------------------
            -- Can we use this ammo item in some gun or turret?

            add_edge("item")
            add_edge("ammo-category", item.ammo_category)
        end

        if item.type == "capsule" and lu.capsule_spawns[item.name] ~= nil then
            ----------------------------------------
            add_node("item-capsule", "AND")
            ----------------------------------------
            -- Can we use this capsule item to spawn entities?
            -- Capsules only work where there's a character (on planets, not in space).

            add_edge("item")
            add_edge("planet", "")  -- Capsules require a planet (character can only be on planets)
        end

        if item.type == "gun" then
            ----------------------------------------
            add_node("item-gun", "AND")
            ----------------------------------------
            -- Can we use this gun item?
            -- Guns only work where there's a character (on planets, not in space).

            add_edge("item")
            add_edge("planet", "")  -- Guns require a planet (character can only be on planets)
        end
    end

    ----------------------------------------------------------------------
    -- Recipe
    ----------------------------------------------------------------------

    set_class("recipe")

    for _, recipe in pairs(lu.recipes) do
        set_prot(recipe)

        local rcat_name = lutils.rcat_name(recipe)
        local unlocking_techs = lu.recipe_to_techs[recipe.name]
        local ingredient_map = lu.mat_recipe_map.recipe[recipe.name].ingredients

        ----------------------------------------
        add_node("recipe", "AND")
        ----------------------------------------
        -- Can we perform this recipe?

        add_edge("recipe-category", rcat_name)
        if unlocking_techs ~= nil then
            add_edge("recipe-tech-unlock")
        end
        -- Ingredients with inds for trigger technology support
        for mat_key, inds in pairs(ingredient_map) do
            local mat = gutils.deconstruct(mat_key)
            add_edge(mat.type, mat.name, {
                inds = inds,
            })
        end
        if recipe.surface_conditions ~= nil then
            add_edge("recipe-surface-condition")
        end

        if unlocking_techs ~= nil then
            ----------------------------------------
            add_node("recipe-tech-unlock", "OR")
            ----------------------------------------
            -- Can we unlock this recipe via technology?
            -- This could have itself as canonical because it is technically sensible to randomize the unlock --> recipe edge
            -- However, this is not too much different from randomizing the tech --> unlock edge in most cases

            for tech_name, _ in pairs(unlocking_techs) do
                add_edge("technology", tech_name)
            end
        end

        if recipe.surface_conditions ~= nil then
            ----------------------------------------
            add_node("recipe-surface-condition", "OR")
            ----------------------------------------
            -- Can we craft on a surface meeting this recipe's conditions?

            for room_key, room in pairs(lu.rooms) do
                if lutils.check_surface_conditions(room, recipe.surface_conditions) then
                    add_edge("room", room_key)
                end
            end
        end
    end

    ----------------------------------------------------------------------
    -- Recipe Category
    ----------------------------------------------------------------------

    -- Spoofed categories keyed by base category prototype, with nodes for each fluid count variant.

    set_class("recipe-category")

    for _, cat in pairs(data.raw["recipe-category"]) do
        set_prot(cat)

        local spoofed_cats = lu.vanilla_to_rcats[cat.name]
        if spoofed_cats ~= nil then
            for rcat_name, _ in pairs(spoofed_cats) do
                ----------------------------------------
                add_node("recipe-category", "OR", nil, rcat_name)
                ----------------------------------------
                -- Can we craft recipes in this spoofed category?
                -- OR over all entities that support this category with sufficient fluid boxes.

                local crafters = lu.rcat_to_crafters[rcat_name]
                if crafters ~= nil then
                    for crafter_name, _ in pairs(crafters) do
                        add_edge("entity-operate", crafter_name)
                    end
                end
            end
        end
    end

    ----------------------------------------------------------------------
    -- Resource Category
    ----------------------------------------------------------------------
    -- Spoofed resource categories: category|has_input|has_output
    -- has_input/has_output are 0 or 1, indicating fluid box requirements
    -- The specific input fluid is handled by entity-mine, not here

    set_class("resource-category")

    for _, cat in pairs(data.raw["resource-category"]) do
        set_prot(cat)

        local spoofed_cats = lu.mcat_to_mcats[cat.name]
        if spoofed_cats ~= nil then
            for mcat_key, _ in pairs(spoofed_cats) do
                ----------------------------------------
                add_node("resource-category", "OR", nil, mcat_key)
                ----------------------------------------
                -- Can we mine resources in this category with these fluid requirements?
                -- OR over mining drills that support this category AND have matching fluid boxes

                local drills = lu.mcat_to_drills[mcat_key]
                if drills ~= nil then
                    for drill_name, _ in pairs(drills) do
                        add_edge("entity-operate", drill_name)
                    end
                end
            end
        end
    end

    ----------------------------------------------------------------------
    -- Space Connection
    ----------------------------------------------------------------------

    set_class("space-connection")

    for _, conn in pairs(prots("space-connection")) do
        set_prot(conn)

        ----------------------------------------
        add_node("space-connection", "AND")
        ----------------------------------------
        -- Can we travel along this space connection?
        -- This node FORGETS context: connections are global once available.
        -- Requires: access to endpoints, discovery, and ability to destroy asteroids (just tests against 100% resistances)

        add_edge("space-connection-enter")
        add_edge("space-connection-discover")
        add_edge("space-connection-asteroids")

        ----------------------------------------
        add_node("space-connection-enter", "OR")
        ----------------------------------------
        -- Can we access either end of this space connection with a spaceship?

        for _, endpoint in pairs({"from", "to"}) do
            add_edge("space-location-spaceship", conn[endpoint])
        end

        ----------------------------------------
        add_node("space-connection-discover", "AND")
        ----------------------------------------
        -- Have we discovered this space connection?
        -- Requires both endpoints to be discovered.

        for _, endpoint in pairs({"from", "to"}) do
            add_edge("space-location-discover", conn[endpoint])
        end

        ----------------------------------------
        add_node("space-connection-asteroids", "AND")
        ----------------------------------------
        -- Can we destroy the asteroids on this space connection?
        -- Requires being able to overcome each asteroid type's resistance group.

        local asteroids = lu.connection_asteroids[conn.name]
        if asteroids ~= nil then
            for asteroid_name, _ in pairs(asteroids) do
                local group_key = lu.asteroid_resistance_groups[asteroid_name]
                if group_key ~= nil then
                    add_edge("resistance-group", group_key)
                end
            end
        end
    end

    ----------------------------------------------------------------------
    -- Space Location
    ----------------------------------------------------------------------

    set_class("space-location")

    for _, loc in pairs(dutils.get_all_prots("space-location")) do
        set_prot(loc)

        ----------------------------------------
        add_node("space-location", "AND")
        ----------------------------------------
        -- Can we inhabit this space location with some surface?
        -- This is an AND over space-location-reachable and space nodes to enforce that we're on a surface

        add_edge("space-surface", "")
        add_edge("space-location-reachable", loc.name)

        ----------------------------------------
        add_node("space-location-reachable", "OR", true)
        ----------------------------------------
        -- This node FORGETS context: locations are global once reachable.
        -- OR over: space connections that lead here, launching from planet (bootstrap)

        local connections = lu.space_location_to_connections[loc.name]
        if connections ~= nil then
            for conn_name, _ in pairs(connections) do
                add_edge("space-connection", conn_name)
            end
        end
        if loc.type == "planet" then
            add_edge("room-launch", loc.name, {
                abilities = { [1] = false },
            })
        end

        ----------------------------------------
        add_node("space-location-discover", "OR")
        ----------------------------------------
        -- Have we discovered this space location?
        -- If we can reach it, we've discovered it; otherwise need technology unlock.

        add_edge("space-location")
        local discovery_techs = lu.space_location_to_discovery_techs[loc.name]
        if discovery_techs ~= nil then
            for tech_name, _ in pairs(discovery_techs) do
                add_edge("technology", tech_name)
            end
        end

        ----------------------------------------
        add_node("space-location-spaceship", "AND")
        ----------------------------------------
        -- Can we inhabit this space location with a surface capable of space flight?
        -- Requires: space-location + spaceship capability

        add_edge("space-location")
        add_edge("spaceship", "")
    end

    ----------------------------------------------------------------------
    -- Technology
    ----------------------------------------------------------------------

    set_class("technology")

    for _, tech in pairs(lu.techs) do
        set_prot(tech)

        ----------------------------------------
        add_node("technology", "AND", true)
        ----------------------------------------
        -- Can we research this technology?
        -- This node FORGETS context: research makes tech available everywhere.
        -- Still needs at least one incoming context to match along all inputs.

        -- Techs carry automatability contexts since one they're unlocked, they don't need continued effort
        -- Thus, all prerequisites for a tech add automatability contexts

        -- Techs via triggers can get planet-locked, but assuming this for unit techs might be too harsh
        -- For now, we'll stick to all techs, but could change this in the future
        local tech_abilities = {
            [2] = true,
        }

        -- Prerequisite technologies
        if tech.prerequisites ~= nil then
            for _, prereq in pairs(tech.prerequisites) do
                add_edge("technology", prereq, {
                    abilities = table.deepcopy(tech_abilities),
                })
            end
        end

        -- Research method: either science packs (unit) or trigger condition
        if tech.unit ~= nil then
            -- Standard research with science packs
            local set = {}
            for _, ing in pairs(tech.unit.ingredients) do
                table.insert(set, ing[1])
            end
            table.sort(set)
            -- Need the science pack items
            add_edge("science-pack-set-science", gutils.concat(set), {
                abilities = table.deepcopy(tech_abilities),
            })
            -- Need a lab that can accept all packs
            add_edge("science-pack-set-lab", gutils.concat(set), {
                abilities = table.deepcopy(tech_abilities),
            })
        elseif tech.research_trigger ~= nil then
            -- Trigger-based research
            local trigger = tech.research_trigger

            if trigger.type == "mine-entity" then
                add_edge("entity-mine", trigger.entity, {
                    abilities = table.deepcopy(tech_abilities),
                })
            elseif trigger.type == "craft-item" then
                add_edge("item-craft", trigger.item, {
                    abilities = table.deepcopy(tech_abilities),
                })
            elseif trigger.type == "craft-fluid" then
                add_edge("fluid-craft", trigger.fluid, {
                    abilities = table.deepcopy(tech_abilities),
                })
            elseif trigger.type == "send-item-to-orbit" then
                -- Need to deliver the specified item (must have space surface to receive it)
                add_edge("item-launch", trigger.item, {
                    abilities = table.deepcopy(tech_abilities),
                })
            elseif trigger.type == "capture-spawner" then
                -- Need to capture the specified spawner type
                if trigger.entity ~= nil then
                    add_edge("entity-capture-spawner", trigger.entity, {
                        abilities = table.deepcopy(tech_abilities),
                    })
                else
                    -- Any spawner will do
                    add_edge("capture-spawner", "", {
                        abilities = table.deepcopy(tech_abilities),
                    })
                end
            elseif trigger.type == "build-entity" then
                add_edge("entity-build", trigger.entity, {
                    abilities = table.deepcopy(tech_abilities),
                })
            elseif trigger.type == "create-space-platform" then
                add_edge("create-platform", "", {
                    abilities = table.deepcopy(tech_abilities),
                })
            end
        end
    end

    ----------------------------------------------------------------------
    -- Tile
    ----------------------------------------------------------------------

    set_class("tile")

    for _, tile in pairs(prots("tile")) do
        set_prot(tile)

        ----------------------------------------
        add_node("tile", "OR")
        ----------------------------------------
        -- Can we encounter this tile?

        -- Tiles can be encountered by being generated on a planet
        local tile_rooms = lu.tiles_to_rooms[tile.name]
        if tile_rooms ~= nil then
            for room_key, _ in pairs(tile_rooms) do
                add_edge("room", room_key, {
                    abilities = { [1] = true },
                })
            end
        end

        local buildable = lu.buildables[key(tile)]
        -- Tiles can also be built (if buildable)
        if buildable ~= nil then
            add_edge("tile-build")

            ----------------------------------------
            add_node("tile-build", "OR")
            ----------------------------------------
            -- Can we build this tile?
            -- OR over tile-build-item-place-as-tile (one per item that can build it)

            local tile_items = lu.place_as_tile_items[tile.name]
            if tile_items ~= nil then
                for item_name, _ in pairs(tile_items) do
                    add_edge("tile-build-item-place-as-tile", concat({tile.name, item_name}))
                end
            end

            ----------------------------------------
            add_node("tile-build-item", "OR")
            ----------------------------------------
            -- Can we access an item that can build this tile?
            -- Useful for direct queries about tile-building items.

            if tile_items ~= nil then
                for item_name, _ in pairs(tile_items) do
                    add_edge("item", item_name)
                end
            end

            -- Compound nodes: one per (tile, item) pair
            if tile_items ~= nil then
                for item_name, condition_info in pairs(tile_items) do
                    local compound_key = concat({tile.name, item_name})

                    ----------------------------------------
                    add_node("tile-build-item-place-as-tile", "AND", nil, compound_key, {
                        item = item_name,
                    })
                    ----------------------------------------
                    -- Can we build this tile with this specific item?
                    -- Requires: item + valid placement tiles for this item's condition

                    add_edge("item", item_name)
                    add_edge("tile-build-item-place-as-tile-condition", compound_key)

                    ----------------------------------------
                    add_node("tile-build-item-place-as-tile-condition", "OR", nil, compound_key, {
                        item = item_name,
                    })
                    ----------------------------------------
                    -- Can we access a tile that satisfies this item's placement condition?
                    -- Placement rules:
                    --   - If whitelist is set: only tiles in whitelist are valid
                    --   - If blocking_layers is set: tiles with those layers are excluded
                    --   - Both can apply simultaneously

                    local has_any_condition = condition_info.whitelist ~= nil or condition_info.blocking_layers ~= nil

                    if has_any_condition then
                        -- Use tile_collision_groups to efficiently check tiles
                        for layers_key, tiles_in_group in pairs(lu.tile_collision_groups) do
                            local group_layers = lu.tile_collision_group_to_layers[layers_key]

                            -- Check if this collision group is blocked by blocking_layers
                            local group_blocked = false
                            if condition_info.blocking_layers ~= nil then
                                for layer, _ in pairs(group_layers) do
                                    if condition_info.blocking_layers[layer] then
                                        group_blocked = true
                                        break
                                    end
                                end
                            end

                            if not group_blocked then
                                -- Add tiles from this group (filtered by whitelist if present)
                                -- For more efficiency, we could depend on groups of tiles again instead of specific tiles,
                                -- but that is less likely to help in this case and more involved, so let's not go that far for now
                                for tile_name_in_group, _ in pairs(tiles_in_group) do
                                    local allowed = true
                                    if condition_info.whitelist ~= nil then
                                        allowed = condition_info.whitelist[tile_name_in_group] == true
                                    end
                                    if allowed then
                                        add_edge("tile", tile_name_in_group)
                                    end
                                end
                            end
                        end
                    end
                    -- No condition = no edges (falsey, conservative default)
                    -- In vanilla all items have conditions, so this shouldn't trigger
                end
            end
        end

        if tile.fluid ~= nil then
            ----------------------------------------
            add_node("tile-fluid", "AND")
            ----------------------------------------
            -- Can we pump fluid from this tile?
            -- Requires: tile + compatible pump

            add_edge("tile")
            add_edge("tile-fluid-pump")

            ----------------------------------------
            add_node("tile-fluid-pump", "OR")
            ----------------------------------------
            -- Can we operate an offshore pump that can pump from this tile?

            local valid_pumps = lu.tile_valid_pumps[tile.name]
            if valid_pumps ~= nil then
                for pump_name, _ in pairs(valid_pumps) do
                    add_edge("entity-operate", pump_name)
                end
            end
            -- If no valid pumps, this node has no prereqs and will be unsatisfiable
        end

        if tile.minable ~= nil then
            ----------------------------------------
            add_node("tile-mine", "AND")
            ----------------------------------------
            -- Can we mine this tile?

            -- We could also add the condition of needing either robots or the ability to hold a tile in your hand, but that seems not worth it
            add_edge("tile")
        end
    end

end

return concrete
