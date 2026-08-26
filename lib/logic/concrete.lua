-- These nodes represent "concrete" types of things - usually with a related prototype

local collision_mask_util collision_mask_util = require("__core__/lualib/collision-mask-util")

local lib_name = "lib"
local constants = require("helper-tables/constants")
local categories = require("helper-tables/categories")
local cutils = require("lib/cost/cost-utils")
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

function concrete.build(lu, extra_params)
    extra_params = extra_params or {}
    local payback_time = extra_params.payback_time or constants.cost.default_payback_time

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
                    add_edge("item-gun", source_info.name, {
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

        -- Asteroid chunks can be mined automatically
        add_edge("asteroid-chunk", chunk.name, {
            abilities = { [2] = true },
        })
        add_edge("asteroid-collector", "", { amount = 1 })
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

        local entity_cost = constants.cost.per_entity_cost
        ----------------------------------------
        add_node("entity", "OR", nil, nil, { cost = entity_cost })
        ----------------------------------------
        -- Can we encounter this entity in the wild?

        -- TODO: Should any of these turn off automatability?
        local buildable = lu.buildables[key(entity)]
        if buildable ~= nil then
            add_edge("entity-build", nil, { amount = 1 })
        end
        -- Check if the entity is put automatically in a room (planet/space surface)
        for room_key, room in pairs(lu.rooms) do
            if room.type ~= "control" then
                if lutils.check_in_room(room, entity) then
                    -- Technically, we should check that there are non-colliding tiles too, but it would be very silly to have an entity in autoplace that can't be placed there
                    add_edge("room-autoplace", room_key, {
                        entity = entity.name,
                        abilities = { [1] = true },
                        amount = 0, -- Zero amount to trigger the creation of this entity as an OR node
                    }) -- Being from a room leads to isolatability
                end
            end
        end
        -- Check if entity could be the corpse of another entity
        if categories.corpse[entity.type] and lu.minable_corpses[entity.name] ~= nil then
            for other_entity, _ in pairs(lu.minable_corpses[entity.name]) do
                -- Technically we could spawn multiple corpses (thus costing a fraction of an entity), but this doesn't account for that yet
                add_edge("entity-kill", other_entity, { amount = 1 })
            end
        end
        -- Check if for spawners that capture into this entity
        if lu.unit_spawner_captures[entity.name] ~= nil then
            for _, spawner in pairs(lu.unit_spawner_captures[entity.name]) do
                add_edge("entity-capture-spawner", spawner.name, { amount = 1 })
            end
        end
        -- Check if entity spawns from a capsule (only on planets)
        if lu.capsule_spawns_reverse[entity.name] ~= nil then
            for item_name, _ in pairs(lu.capsule_spawns_reverse[entity.name]) do
                -- Note: The amount of spawns might not be 1, but I'm not going to go into depth with that now
                add_edge("item-capsule", item_name, { amount = 1 })
            end
        end
        if lu.ammo_spawns_reverse[entity.name] ~= nil then
            for item_name, _ in pairs(lu.ammo_spawns_reverse[entity.name]) do
                -- Note: The amount of spawns might not be 1, but I'm not going to go into depth with that now
                add_edge("item-ammo", item_name, { amount = 1 })
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
                    -- Note: The amount of spawns might not be 1, but I'm not going to go into depth with that now
                    add_edge("entity-kill", dying_info.name, { amount = 1 })
                end
            end
        end
        -- Check if we can get access this through it being our character
        if entity.type == "character" then
            add_edge("entity-character", entity.name, {
                abilities = { [1] = true }, -- Characters are always "local"
                amount = 0,
            })
        end

        if buildable ~= nil then
            ----------------------------------------
            add_node("entity-build", "AND")
            ----------------------------------------
            -- Can we build this entity using an item?
            -- Entities that can be planted are counted as being built, though later during randomization we might have to condition on it being a planted or built entity

            add_edge("entity-build-item", nil, { amount = 1 })
            -- We could include a cost for special tiles needed here, but we already factor in space costs in the entity-operate
            add_edge("entity-build-tile")
            if entity.surface_conditions ~= nil and #entity.surface_conditions > 0 then
                add_edge("entity-build-surface-condition")
            end
            -- If it's a rolling stock (locomotive/cargo wagon/etc.), check that we can build some rail that it does not collide with
            -- Technically, we should test that the rail also shares a tile with the locomotive that both can be placed on, but also I could have a life and I think I'd take the latter
            if categories.rolling_stock[entity.type] then
                -- If we wanted to get technical, we could include the price of the rail, but let's not
                add_edge("entity-build-rail")
            end

            if categories.rolling_stock[entity.type] then
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
                    -- TODO: Support for item build place amount as defined by placeable_by
                    amount = 1,
                })
            end

            if entity.surface_conditions ~= nil and #entity.surface_conditions > 0 then
                ----------------------------------------
                add_node("entity-build-surface-condition", "OR")
                ----------------------------------------
                -- Can we access a room with the right surface conditions for this entity?

                for room_key, room in pairs(lu.rooms) do
                    if room.type ~= "control" then
                        if lutils.check_surface_conditions(room, entity.surface_conditions or {}) then
                            add_edge("room", room_key)
                        end
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

        -- Too many things were operable in mods that I didn't expect, so just add this for everything
        -- TODO: Better operability check!
        --if lu.operable_entities[entity.name] then
            local operation_cost = 0
            local slot_additional_operation_cost = 0
            if entity.collision_box ~= nil then
                local width = math.ceil(entity.collision_box[2][1] - entity.collision_box[1][1])
                local height = math.ceil(entity.collision_box[2][2] - entity.collision_box[1][2])
                operation_cost = operation_cost + constants.cost.per_tile_operation_cost * width * height
            end
            operation_cost = operation_cost + constants.cost.per_building_operation_cost
            if entity.type == "character" then
                operation_cost = operation_cost + constants.cost.character_operation_cost
                slot_additional_operation_cost = slot_additional_operation_cost + constants.cost.slot_additional_character_operation_cost
            end

            -- Check for burner energy source
            if categories.energy_sources_input[entity.type] then
                for _, energy_prop in pairs(dutils.tablize(categories.energy_sources_input[entity.type])) do
                    local energy_source = entity[energy_prop]
                    if energy_source ~= nil and energy_source.type == "burner" then
                        operation_cost = operation_cost + constants.cost.burner_energy_source_penalty
                    end
                end
            end

            -- TODO: extra operation cost for entities that require a character? (Like cars)

            ----------------------------------------
            add_node("entity-operate", "AND", nil, nil, { cost = operation_cost, slot_additional_cost = slot_additional_operation_cost })
            ----------------------------------------
            -- Can we operate this entity (ensure it's heated, powered, etc.)?

            -- Automatic operation doesn't require automatic production (unless this is a character)
            local is_automatic = true
            if entity.type == "character" then
                is_automatic = false
            end

            add_edge("entity", entity.name, {
                abilities = { [2] = is_automatic },
                -- Account for one-time cost of entity
                amount = 1 / payback_time,
            })
            if categories.energy_sources_input[entity.type] then
                -- Note: Entities still depend on "void" energy source even if their energy_source is nil so that randomization is still possible
                -- The energy source nodes are generic/entity independent, but burner energy sources that have different fuel_categories are counted as distinct
                -- TODO: Later, also distinguish fluid energy sources based off fluid box filters/whether they burn fluid, and heat energy sources based on min/max heat etc., but for now just having one of each is fine
                for _, energy_prop in pairs(dutils.tablize(categories.energy_sources_input[entity.type])) do
                    local energy_source = entity[energy_prop]
                    -- TODO: Check for keys more than just energy_usage (like consumption)
                    local energy_amount = 60 * util.parse_energy(entity.energy_usage or entity.energy_consumption or "0J")
                    if energy_amount == 0 then
                        energy_amount = nil
                    end
                    if energy_source == nil or energy_source.type == "void" then
                        add_edge("energy-source-void", "")
                    elseif energy_source.type == "burner" then
                        add_edge("energy-source-burner", lutils.fcat_combo_name(energy_source), { amount = energy_amount })
                    elseif energy_source.type == "electric" then
                        add_edge("energy-source-electric", "", { amount = energy_amount })
                    elseif energy_source.type == "fluid" then
                        if energy_source.fluid_box.filter ~= nil then
                            local fluid_name = energy_source.fluid_box.filter
                            local fluid = data.raw.fluid[fluid_name]
                            local fuel_value = fluid.fuel_value
                            local amount_of_fluid
                            -- TODO: Figure out temperature heating/when fuel value is nil
                            if fuel_value ~= nil then
                                amount_of_fluid = energy_amount / util.parse_energy(fuel_value)
                            end
                            add_edge("fluid", fluid_name, { amount = amount_of_fluid })
                        else
                            add_edge("energy-source-fluid", "", { amount = energy_amount })
                        end
                    elseif energy_source.type == "heat" then
                        add_edge("energy-source-heat", "", { amount = energy_amount })
                    end
                end
            end
            if categories.fluid_required[entity.type] then
                -- Fluid amounts are defined in the entity-operate-fluid node
                local amount_to_use
                -- Costs only implemented for boilers and generators now
                if entity.type == "boiler" or entity.type == "generator" then
                    amount_to_use = 1
                end
                add_edge("entity-operate-fluid", nil, { amount = amount_to_use })
            end
            -- Thrusters need two specific fluids (AND), not a generic fluid requirement
            if entity.type == "thruster" then
                -- TODO: fluid amounts cost
                add_edge("fluid", entity.fuel_fluid_box.filter)
                add_edge("fluid", entity.oxidizer_fluid_box.filter)
            end
            if lutils.check_freezable(entity) then
                -- TODO: Heating energy const
                add_edge("warmth", "")
            end
            local base_name
            if string.len(entity.name) >= 6 then
                if string.sub(entity.name, -5, -3) == "-mk" then
                    base_name = string.sub(entity.name, 1, -6)
                end
            end
            local operability_modules
            if base_name ~= nil and lu.py_operability_module_cats[base_name] ~= nil then
                operability_modules = lu.py_operability_module_cats[base_name]
                add_edge("entity-operate-py-module", nil, { amount = entity.module_slots })
            end
            -- Note: Turrets are "operable" without ammo; since the damage is on the ammo, we actually need to check if there is a turret to shoot an ammo rather than check if there is ammo for a turret to shoot
            -- TODO: Module requirements (for mods like PyAL)

            if operability_modules ~= nil then
                ----------------------------------------
                add_node("entity-operate-py-module", "OR", nil, nil, { mechanic = true })
                ----------------------------------------
                -- Can we get the module required to operate this py building

                for category, _ in pairs(operability_modules) do
                    for _, mod in pairs(data.raw.module) do
                        if mod.category == category then
                            -- The number of modules needed is factored in by the entity-operate edge from here
                            add_edge("item", mod.name, { amount = 1 / payback_time })
                        end
                    end
                end
            end

            if categories.fluid_required[entity.type] then
                ----------------------------------------
                add_node("entity-operate-fluid", "OR")
                ----------------------------------------
                -- Can we provide a fluid that this entity needs to operate?

                if entity.type == "boiler" then
                    -- TODO: boiler fluid amounts calculation
                    if entity.fluid_box.filter ~= nil then
                        local fluid_amount = 0
                        if entity.target_temperature ~= nil and entity.fluid_box.filter ~= nil then
                            fluid_amount = dutils.boiler_input_amount(entity)
                        end
                        add_edge("fluid", entity.fluid_box.filter, { amount = fluid_amount })
                    else
                        -- No filter, i.e.- any fluid can be heated
                        -- TODO: Implement proper fluid availability check
                        add_edge("satisfied", "")
                    end
                elseif entity.type == "fusion-generator" then
                    -- TODO: Implement fluid amounts
                    if entity.input_fluid_box.filter ~= nil then
                        add_edge("fluid", entity.input_fluid_box.filter)
                    end
                elseif entity.type == "fusion-reactor" then
                    -- TODO: Implement fluid amounts
                    if entity.input_fluid_box.filter ~= nil then
                        add_edge("fluid", entity.input_fluid_box.filter)
                    end
                elseif entity.type == "generator" then
                    -- TODO: Implement fluid amounts
                    -- Generators can have filtered fluid_box or burn any fuel fluid
                    if entity.fluid_box.filter ~= nil then
                        add_edge("fluid", entity.fluid_box.filter, { amount = 60 * entity.fluid_usage_per_tick })
                    elseif entity.burns_fluid then
                        -- Any fluid with fuel_value works
                        add_edge("energy-source-fluid", "")
                    else
                        -- Non-burning generator without filter
                        -- In vanilla, all generators have filters (steam), so I'm ignoring this for now
                        -- TODO: Implement temperature requirements for proper fluid matching
                        add_edge("satisfied", "")
                    end
                -- TODO: Store damage_modifier on edges so reflection can reconstruct appropriate modifiers for new fluids
                elseif entity.type == "fluid-turret" then
                    -- Fluid turrets specify fluids in attack_parameters.fluids
                    -- TODO: Implement fluid amounts
                    if entity.attack_parameters ~= nil and entity.attack_parameters.fluids ~= nil then
                        for ind, stream_fluid in pairs(entity.attack_parameters.fluids) do
                            add_edge("fluid", stream_fluid.type, {
                                ind = ind,
                            })
                        end
                    end
                end
            end
        --end

        -- Just check for asteroids and other critical entities now for performance
        if not categories.without_health[entity.type] and (entity.type == "asteroid" or lu.dying_spawns[key("entity", entity.name)] or (entity.loot ~= nil and #entity.loot > 0) or (entity.corpse ~= nil and lu.minable_corpses[entity.corpse])) then
            ----------------------------------------
            add_node("entity-kill", "AND")
            ----------------------------------------
            -- Can we kill this entity?
            -- Only created for things that could have health.

            -- We just check for immunities here, i.e.- 100% or more resistance
            -- Later, in logic-balancing.lua we can worry about "virtually immune" entities/health amounts etc.
            -- We also might want edges to damage types for representing resistances to randomize later, but when I do that I can decide what specific entities to touch
            -- Building every entity-damage type combination seems like a lot to me now, which is why I'm doing it this way
            add_edge("resistance-group", lu.entity_resistance_groups.to_resistance[entity.name])
            add_edge("entity", nil, { amount = 1 })
        end

        if entity.minable ~= nil then
            ----------------------------------------
            add_node("entity-mine", "AND")
            ----------------------------------------
            -- Can we mine this entity?

            if entity.type == "resource" then
                add_edge("entity", entity.name, {
                    abilities = { [2] = true },
                    amount = 1,
                })
                -- For resources requiring fluid: need the specific fluid + tech unlock
                -- These are separate edges because different resources may need different fluids
                -- Note that if we wanted to be especially careful, we'd check mining drill filters too, but we'll leave that for another time
                if entity.minable.required_fluid ~= nil then
                    -- I don't know why the actual amount is divided by 10 (at least in pyanodons) but whatever
                    local fluid_amount = (entity.minable.fluid_amount or 0) / 10
                    add_edge("fluid", entity.minable.required_fluid, { amount = fluid_amount })
                    -- Mining with fluid unlock triggered automatically at start of game now
                    --[[add_edge("mining-with-fluid-unlock", "", {
                        abilities = { [2] = true }, -- I don't know if I'll count unlocks as "automatable", but resources should be automatable as long as fluid is (if any), and the drill is automatically operable
                    })]]
                end

                add_edge("resource-category", lutils.mcat_name(entity), { amount = entity.minable.mining_time })
            else
                add_edge("entity", entity.name, {
                    abilities = { [2] = false },
                    amount = 1,
                })
                -- TODO: Don't hardcode characters?
                add_edge("entity-operate", "character", { amount = entity.minable.mining_time / data.raw.character.character.mining_speed })
            end
        end

        if entity.type == "unit-spawner" then
            ----------------------------------------
            add_node("entity-capture-spawner", "AND")
            ----------------------------------------
            -- Can we capture this unit spawner?

            add_edge("entity", nil, { amount = 1 })
            add_edge("capture-robot", "", { amount = 1 })
        end

        if entity.type == "character" then
            ----------------------------------------
            add_node("entity-character", "OR")
            ----------------------------------------
            -- Can we inhabit this character entity?

            -- I was originally planning to use this node to test for ability to throw capsules and such, but then just tested for whether you're on a planet
            -- TODO: Decide if I want to keep this

            if entity.name == lutils.starting_character_name then
                -- Starting character can visit the planet, so is isolatable
                add_edge("starting-character", "", {
                    abilities = { [1] = true },
                })
            end
        end

        local blacklisted_silos = {
            ["mega-farm"] = true, -- Py smart farms work via scripting and don't actually launch a rocket
        }
        if entity.type == "rocket-silo" then
            ----------------------------------------
            add_node("entity-rocket-silo", "AND")
            ----------------------------------------
            -- Can we use this rocket silo for launching?
            
            -- Cost corresponds to cost for one rocket

            if entity.fixed_recipe ~= nil and lu.recipes[entity.fixed_recipe] ~= nil then
                local recipe = data.raw.recipe[entity.fixed_recipe]
                add_edge("entity-operate", nil, { amount = (recipe.energy_required or 0.5) * entity.rocket_parts_required / entity.crafting_speed })
                add_edge("recipe", entity.fixed_recipe, { amount = entity.rocket_parts_required })
            else
                -- Just add the entity-operate without a cost if no fixed recipe
                add_edge("entity-operate")
            end
        end
    end

    ----------------------------------------------------------------------
    -- Equipment
    ----------------------------------------------------------------------

    -- Note: Size constraints not checked (equipment might be too large for grid).

    set_class("equipment")

    for equip_name, equip in pairs(lu.equipment) do
        set_prot(equip)

        ----------------------------------------
        add_node("equipment", "AND")
        ----------------------------------------
        -- Can we use this equipment?

        add_edge("equipment-place")
        add_edge("planet", "") -- Equipment only works on planets, not in space

        ----------------------------------------
        add_node("equipment-place", "OR")
        ----------------------------------------
        -- Can we place this equipment in some grid?

        local placing_items = lu.equipment_to_items[equip_name]
        if placing_items ~= nil then
            for item_name, _ in pairs(placing_items) do
                add_edge("item", item_name)
            end
        end

        -- TODO: Clean up this section
        -- Determine power type using categories tables
        local power_type = "void"
        if categories.equipment_power_producers[equip.type] then
            power_type = "producer"
        elseif categories.equipment_power_consumers[equip.type] then
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

            add_edge("equipment")
            add_edge("equipment-operate-power")

            ----------------------------------------
            add_node("equipment-operate-power", "OR")
            ----------------------------------------
            -- Can we power this equipment?

            local equip_cats = equip.categories or {}
            for _, cat in pairs(equip_cats) do
                add_edge("equipment-category-powered", cat)
            end

        elseif power_type == "burner" then
            ----------------------------------------
            add_node("equipment-operate", "AND")
            ----------------------------------------
            -- Can we operate this burner-powered equipment?

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

            add_edge("equipment")
            add_edge("energy-source-void", "")

        elseif power_type == "producer" then
            ----------------------------------------
            add_node("equipment-operate", "AND")
            ----------------------------------------
            -- Can we operate this producer equipment?
            -- In this branch, the equipment doesn't require power, it produces it without requirements, so we only need the equipment for operation

            add_edge("equipment")
        end
    end

    ----------------------------------------------------------------------
    -- Equipment Category
    ----------------------------------------------------------------------

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

        local grids = lu.category_to_grids[cat]
        if grids ~= nil then
            for grid_name, _ in pairs(grids) do
                add_edge("equipment-grid", grid_name)
            end
        end

        ----------------------------------------
        add_node("equipment-category-powered", "OR")
        ----------------------------------------
        -- Can we access a powered grid that accepts this equipment category?

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

    set_class("equipment-grid")

    for _, grid in pairs(prots("equipment-grid")) do
        set_prot(grid)

        ----------------------------------------
        add_node("equipment-grid", "OR")
        ----------------------------------------
        -- Can we access this specific equipment grid?

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

        add_edge("equipment-grid", grid.name)
        add_edge("equipment-grid-power-source", grid.name)

        ----------------------------------------
        add_node("equipment-grid-power-source", "OR")
        ----------------------------------------
        -- Can we power this specific grid?

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
        add_node("fluid", "OR")
        ----------------------------------------
        -- Can we obtain this fluid?
        -- OR over all possible fluid temperatures

        -- NOTE: We don't count mixing for middle temperatures, so like mixing 50 degree and 150 degree fluid for 100 degree fluid
        -- If a modpack requires this in the future, manual compatibility would have to be added
        -- Though honestly, this sounds like an awful mechanic to have to deal with as a player (especially with any fluid temperatures that have to be exact), which is why it's not coded into logic

        for _, temp in pairs(lu.fluid_temperatures_ordered[fluid.name]) do
            add_edge("fluid-temperature", key(fluid.name, tostring(temp)), { amount = 1 })
        end

        for temp_range, _ in pairs(lu.temp_ranges[fluid.name]) do
            local fluid_temp_range_name = key(fluid.name, temp_range)

            ----------------------------------------
            add_node("fluid-temperature-range", "OR", nil, fluid_temp_range_name, {
                fluid = fluid.name,
            })
            ----------------------------------------
            -- Can we create fluid at this specific temperature range?

            local temps = gutils.deconstruct(temp_range)
            local temp_min = temps.type
            local temp_max = temps.name

            for _, temp in pairs(lu.fluid_temperatures_ordered[fluid.name]) do
                if temp_min == "nil" or tonumber(temp_min) <= temp then
                    if temp_max == "nil" or tonumber(temp_max) >= temp then
                        add_edge("fluid-temperature", key(fluid.name, temp), { amount = 1 })
                    end
                end
            end
        end
        for _, temp in pairs(lu.fluid_temperatures_ordered[fluid.name]) do
            local fluid_temp_range_name = key(fluid.name, key(tostring(temp), tostring(temp)))

            ----------------------------------------
            add_node("fluid-temperature-range", "OR", nil, fluid_temp_range_name)
            ----------------------------------------
            -- Can we create fluid at this specific temperature range (that consists of a single temperature)?

            add_edge("fluid-temperature", key(fluid.name, tostring(temp)), { amount = 1 })
        end

        for _, temp in pairs(lu.fluid_temperatures_ordered[fluid.name]) do
            local fluid_temp_name = key(fluid.name, tostring(temp))

            ----------------------------------------
            add_node("fluid-temperature", "AND", nil, fluid_temp_name, { cost = constants.cost.per_fluid_cost })
            ----------------------------------------
            -- Can we obtain this fluid at this given temperature point?
            -- Checks ability to create it and to hold it

            add_edge("fluid-create-temperature", fluid_temp_name, { amount = 1 })
            add_edge("fluid-hold", fluid.name)
        end

        ----------------------------------------
        add_node("fluid-create", "OR")
        ----------------------------------------
        -- Can we create/produce this fluid?

        for _, temp in pairs(lu.fluid_temperatures_ordered[fluid.name]) do
            add_edge("fluid-create-temperature", key(fluid.name, tostring(temp)), { amount = 1 })
        end

        ----------------------------------------
        add_node("fluid-craft-temperature", "OR", nil, fluid_temp_name)
        ----------------------------------------
        -- Can we produce this fluid via recipe?
        -- Needed for tech triggers

        for _, temp in pairs(lu.fluid_temperatures_ordered[fluid.name]) do
            add_edge("fluid-craft-temperature", key(fluid.name, tostring(temp)), { amount = 1 })
        end

        for _, temp in pairs(lu.fluid_temperatures_ordered[fluid.name]) do
            local fluid_temp_name = key(fluid.name, tostring(temp))
            ----------------------------------------
            add_node("fluid-create-temperature", "OR", nil, fluid_temp_name)
            ----------------------------------------
            -- Can we create/produce this fluid at this given temperature point?

            local corresponding_recipes = (lu.mat_recipe_map.material[key("fluid", fluid_temp_name)] or {}).results or {}
            add_edge("fluid-craft-temperature", fluid_temp_name, { amount = 1 })
            -- Check offshore pumping possibilities
            -- Offshore pumps only produce default temperature
            local has_filter_pumps = lu.pumps_with_filter[fluid.name] ~= nil
            local has_tiles = lu.fluid_to_tiles[fluid.name] ~= nil
            if temp == fluid.default_temperature then
                if has_filter_pumps or has_tiles then
                    add_edge("fluid-create-offshore-temperature", fluid_temp_name, { amount = 1 })
                end
            end

            -- Check if fluid comes from mining
            local corresponding_minables = lu.mat_mining_map.to_minable[key("fluid", fluid_temp_name)]
            if corresponding_minables ~= nil then
                for minable_key, inds in pairs(corresponding_minables) do
                    local minable_thing = gutils.deconstruct(minable_key)
                    local minable_prot = dutils.get_prot(string.sub(minable_thing.type, 1, -(1 + string.len("-mine"))), minable_thing.name)
                    local minable = minable_prot.minable
                    local minable_amount
                    if minable.results ~= nil then
                        minable_amount = cutils.find_amount_in_ing_or_prod(minable.results, {type = "fluid", name = fluid.name, temperature = temp})
                    else
                        minable_amount = minable.count or 1
                    end
                    add_edge(minable_thing.type, minable_thing.name, {
                        inds = inds,
                        amount = minable_amount,
                    })
                end
            end
            -- Check if fluid comes from boiler/reactor/fusion generator output
            if lu.entity_output_fluids ~= nil then
                for entity_name, output_fluid in pairs(lu.entity_output_fluids) do
                    if output_fluid == fluid_temp_name then
                        -- TODO: Amounts for things other than boiler
                        local fluid_amount
                        local entity = dutils.get_prot("entity", entity_name)
                        if entity.type == "boiler" then
                            if entity.target_temperature ~= nil and entity.fluid_box.filter ~= nil then
                                fluid_amount = dutils.boiler_output_amount(entity)
                            end
                        end
                        add_edge("entity-operate", entity_name, { amount = fluid_amount })
                    end
                end
            end
            -- Check for recipes that should skip over fluid-craft
            for recipe_name, inds in pairs(corresponding_recipes) do
                local recipe = data.raw.recipe[recipe_name]
                if recipe.hide_from_stats then
                    local result_amount = cutils.find_amount_in_ing_or_prod(recipe.results, {type = "fluid", name = fluid.name, temperature = temp})
                    add_edge("recipe", recipe_name, {
                        inds = inds,
                        amount = result_amount,
                    })
                end
            end
 
            ----------------------------------------
            add_node("fluid-craft-temperature", "OR", nil, fluid_temp_name)
            ----------------------------------------
            -- Can we produce this fluid via recipe at this temperature?

            for recipe_name, inds in pairs(corresponding_recipes) do
                local recipe = data.raw.recipe[recipe_name]
                -- Recipes hidden from stats don't satisfy crafting triggers; these will go directly to the fluid
                if not recipe.hide_from_stats then
                    local result_amount = cutils.find_amount_in_ing_or_prod(recipe.results, {type = "fluid", name = fluid.name, temperature = temp})
                    add_edge("recipe", recipe_name, {
                        inds = inds,
                        amount = result_amount,
                    })
                end
            end

            -- TODO: If the offshore pump filter has a temperature condition, can this force it to produce fluids with that temperature?
            -- If so, that might be something we want to account for (though we have no logic for temperature specific pipes now)
            if temp == fluid.default_temperature and (has_filter_pumps or has_tiles) then
                ----------------------------------------
                add_node("fluid-create-offshore-temperature", "OR", nil, fluid_temp_name, { mechanic = true })
                ----------------------------------------
                -- Can we pump this fluid using an offshore pump?
                -- Still counted as a "temperature" node even though this only exists at one temperature point in logic technically

                -- Pumps with filter always produce this fluid
                if has_filter_pumps then
                    for pump_name, _ in pairs(lu.pumps_with_filter[fluid.name]) do
                        local pump = data.raw["offshore-pump"][pump_name]
                        add_edge("entity-operate", pump_name, { amount = pump.pumping_speed })
                    end
                end

                -- Tiles with this fluid can be pumped by compatible pumps
                if has_tiles then
                    for tile_name, _ in pairs(lu.fluid_to_tiles[fluid.name]) do
                        add_edge("tile-fluid", tile_name, { amount = 1 })
                    end
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
                    local item = dutils.get_prot("item", item_name)
                    local fuel_value = util.parse_energy(item.fuel_value)
                    add_edge("item", item_name, { amount = 1 / fuel_value })
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
                local burner_entity = dutils.get_prot("entity", burner_name)
                local energy_usage
                -- TODO: Double check that we got all energy usage keys for burner things
                if burner_entity.max_power_output ~= nil then
                    energy_usage = burner_entity.max_power_output
                elseif burner_entity.energy_consumption ~= nil then
                    energy_usage = burner_entity.energy_consumption
                elseif burner_entity.consumption ~= nil then
                    energy_usage = burner_entity.consumption
                elseif burner_entity.energy_usage ~= nil then
                    energy_usage = burner_entity.energy_usage
                end
                local watts_burned = 0
                if energy_usage ~= nil then
                    watts_burned = 60 * util.parse_energy(energy_usage)
                end
                add_edge("entity-operate", burner_name, { amount = watts_burned })
            end
        end
    end

    ----------------------------------------------------------------------
    -- Item
    ----------------------------------------------------------------------

    set_class("item")

    for _, item in pairs(lu.items) do
        set_prot(item)

        local is_science_pack = false
        for _, lab in pairs(data.raw.lab) do
            for _, input in pairs(lab.inputs) do
                if input == item.name then
                    is_science_pack = true
                end
            end
        end
        local should_be_mechanic = is_science_pack or (lu.burnt_result_to_items[item.name] ~= nil) or (lu.rocket_results_to_items[item.name] ~= nil)

        ----------------------------------------
        add_node("item", "OR", nil, item.name, {
            item = item.name,
            mechanic = should_be_mechanic,
            cost = constants.cost.per_item_cost,
        })
        ----------------------------------------
        -- Can we obtain this item?

        local corresponding_recipes = lu.mat_recipe_map.material[key("item", item.name)].results
        add_edge("item-craft", nil, { amount = 1 })
        local corresponding_minables = lu.mat_mining_map.to_minable[key("item", item.name)]
        if corresponding_minables ~= nil then
            for minable_key, inds in pairs(corresponding_minables) do
                local minable_thing = gutils.deconstruct(minable_key)
                local minable_prot = dutils.get_prot(string.sub(minable_thing.type, 1, -(1 + string.len("-mine"))), minable_thing.name)
                local minable = minable_prot.minable
                local minable_amount
                if minable.results ~= nil then
                    minable_amount = cutils.find_amount_in_ing_or_prod(minable.results, {type = "item", name = item.name})
                else
                    minable_amount = minable.count or 1
                end
                -- Ignore tiles for now
                if minable_thing.type == "tile-mine" then
                    minable_amount = nil
                end
                add_edge(minable_thing.type, minable_prot.name, {
                    inds = inds,
                    amount = minable_amount,
                })
            end
        end
        -- Edge from item-launch for context cycling
        -- This edge allows items to gain more contexts: an item reachable in one context can be launched to space, then delivered to a space surface, gaining that context
        local rocket_lift_weight = data.raw["utility-constants"].default.default_rocket_lift_weight
        if lu.weight[item.name] <= rocket_lift_weight then
            add_edge("item-deliver", item.name, {
                abilities = { [1] = false },
                amount = 1,
                -- TODO: Deliver cost
            })
        end
        -- Edge from items that spoil into this item
        if lu.spoil_result_to_items[item.name] ~= nil then
            for spoiling_item, _ in pairs(lu.spoil_result_to_items[item.name]) do
                local item_prot = dutils.get_prot("item", spoiling_item)
                add_edge("item", spoiling_item, {
                    spoil_ticks = item_prot.spoil_ticks,
                    amount = 1,
                    -- Note: When doing OR-OR subdivision for cost analysis, make sure this cost goes on that AND node; costs don't technically go on edges
                    slot_additional_cost = constants.cost.slot_spoil_additional_cost_fixed + constants.cost.slot_spoil_additional_cost_per_second * item_prot.spoil_ticks / 60,
                })
            end
        end
        -- Edge from fuels that burn into this item
        if lu.burnt_result_to_items[item.name] ~= nil then
            for fuel_item, _ in pairs(lu.burnt_result_to_items[item.name]) do
                -- item-burn already takes into account extra costs from operating a machine to burn it
                add_edge("item-burn", fuel_item, {
                    amount = 1,
                })
            end
        end
        -- Edge from entity kills that drop this as loot
        if lu.loot_to_entities[item.name] ~= nil then
            for entity_name, _ in pairs(lu.loot_to_entities[item.name]) do
                -- TODO: cost amounts
                add_edge("entity-kill", entity_name, {
                    abilities = { [2] = false }, -- Even if we can automatically kill something, we can't automatically pick up its loot (at least in vanilla)
                })
            end
        end
        -- Check if there is a recipe that should link directly to this item (doesn't set off crafting triggers)
        for recipe_name, inds in pairs(corresponding_recipes) do
            local recipe = data.raw.recipe[recipe_name]
            if recipe.hide_from_stats then
                local result_amount = cutils.find_amount_in_ing_or_prod(recipe.results, {type = "item", name = item.name})
                add_edge("recipe", recipe_name, {
                    inds = inds,
                    amount = result_amount,
                })
            end
        end
        -- Check if there are items that give this item as a rocket launch result
        if lu.rocket_results_to_items[item.name] ~= nil then
            for launch_item, _ in pairs(lu.rocket_results_to_items[item.name]) do
                local launch_item_prot = dutils.get_prot("item", launch_item)
                local result_amount = cutils.find_amount_in_ing_or_prod(launch_item_prot.rocket_launch_products, {type = "item", name = item.name})
                add_edge("item-launch", launch_item, { amount = result_amount })
            end
        end

        if item.fuel_category ~= nil and item.burnt_result ~= nil and item.burnt_result ~= "" then
            ----------------------------------------
            add_node("item-burn", "AND", nil, nil, { cost = constants.cost.burnt_result_additional_cost })
            ----------------------------------------
            -- Can we burn this item?

            add_edge("item", nil, { amount = 1 })
            -- In this case, the amount is longer/more annoying for items with larger fuel values, since we're measuring machine usage, not the item usage
            -- Technically, this double counts the fuel consumption, since the item being burned is already providing fuel, but I think that's fine (burning is annoying anyways so the extra cost is probably welcome)
            add_edge("fuel-category-burn", item.fuel_category, { amount = util.parse_energy(item.fuel_value) })
        end

        ----------------------------------------
        add_node("item-craft", "OR")
        ----------------------------------------
        -- Can we craft this item? (Separate node needed for tech triggers)

        for recipe_name, inds in pairs(corresponding_recipes) do
            local recipe = data.raw.recipe[recipe_name]
            if not recipe.hide_from_stats then
                local result_amount = cutils.find_amount_in_ing_or_prod(recipe.results, {type = "item", name = item.name})
                add_edge("recipe", recipe_name, {
                    inds = inds,
                    amount = result_amount,
                })
            end
        end

        local rocket_lift_weight = data.raw["utility-constants"].default.default_rocket_lift_weight
        if lu.weight[item.name] <= rocket_lift_weight then
            -- TODO: This if condition prevents deliveries of high-weight items *from* space platforms; fix this!

            ----------------------------------------
            add_node("item-launch", "AND", true)
            ----------------------------------------
            -- Can we launch this item into space?
            -- This node FORGETS context: launching makes item available to all reachable rooms
            -- Right now, this just filters through deliver to test reachability of that context/room
            -- Space surfaces can deliver anywhere, and planets can deliver if they can launch
            -- This causes planets to launch to other planets, which may not be accurate if there ever comes some extra step besides launching into space to deliver an item
            -- TODO: Address this in more generality

            -- TODO: In games with both a rocket silo that launches items for delivery and for launch results, this allows the delivery launch to satisfy a result launch
            -- Fix this! (I'll need a separate item-launch-results node or something)

            add_edge("item", nil, { amount = 1 })
            add_edge("deliver", "", { amount = 1 })

            ----------------------------------------
            add_node("item-deliver", "AND")
            ----------------------------------------
            -- Can we receive this item in a room?
            -- Filters context to reachable rooms

            add_edge("item-launch", nil, { amount = 1 })
            add_edge("reachable-room", "")
        end

        if item.type == "ammo" then
            ----------------------------------------
            add_node("item-ammo", "AND")
            ----------------------------------------
            -- Can we use this ammo item in some gun or turret?

            add_edge("item", nil, { amount = 1 })
            add_edge("ammo-category", item.ammo_category)
        end

        if item.type == "capsule" and lu.capsule_spawns[item.name] ~= nil then
            ----------------------------------------
            add_node("item-capsule", "AND")
            ----------------------------------------
            -- Can we use this capsule item to spawn entities?
            -- Capsules only work where there's a character (on planets, not in space).

            add_edge("item", nil, { amount = 1 })
            add_edge("planet", "")  -- Capsules require a planet (character can only be on planets)
        end

        if item.type == "gun" then
            ----------------------------------------
            add_node("item-gun", "AND")
            ----------------------------------------
            -- Can we use this gun item?
            -- Guns only work where there's a character (on planets, not in space).

            add_edge("item", nil, { amount = 1 })
            add_edge("planet", "")  -- Guns require a planet (character can only be on planets)
        end
    end

    ----------------------------------------------------------------------
    -- Recipe
    ----------------------------------------------------------------------

    set_class("recipe")

    -- Recipes with special control behavior for their ingredients
    -- Easier to add here than to mess with it later in compat
    local ingredients_not_needed = {
        ["bioport-hidden-recipe"] = true,
    }

    for _, recipe in pairs(lu.recipes) do
        set_prot(recipe)

        local rcat_name = lutils.rcat_name(recipe)
        local unlocking_techs = lu.recipe_to_techs[recipe.name]
        local ingredient_map = lu.mat_recipe_map.recipe[recipe.name].ingredients

        -- dont_randomize is mainly for outside programs not to know to randomize this recipe
        local dont_randomize = false
        if recipe.hidden then
            dont_randomize = true
        end
        local dont_randomize_categories = {
            ["compost"] = true,
            ["py-barreling"] = true,
            ["py-unbarreling"] = true,
            ["py-incineration"] = true,
            ["py-runoff"] = true,
            ["py-venting"] = true,
            ["slaughterhouse"] = true,
        }
        for _, cat in pairs(recipe.categories or {"crafting"}) do
            if dont_randomize_categories[cat] then
                dont_randomize = true
            end
        end
        -- py caging/uncaging recipes
        if string.find(recipe.name, "caged") ~= nil or string.find(recipe.name, "uncaged") ~= nil then
            -- Some "caged" recipes aren't actually about caging, so check that we actually get a thing caged
            if recipe.results ~= nil and #recipe.results == 1 and string.find(recipe.results[1].name, "caged") ~= nil then
                dont_randomize = true
            end
        end
        -- Let's not mess with tholins
        if string.find(recipe.name, "tholins") ~= nil then
            dont_randomize = true
        end
        -- For some reason, methanol canisters are their own special thing
        if string.find(recipe.name, "methanol") ~= nil and string.find(recipe.name, "canister") ~= nil then
            dont_randomize = true
        end

        ----------------------------------------
        add_node("recipe", "AND", nil, nil, { dont_randomize = dont_randomize })
        ----------------------------------------
        -- Can we perform this recipe?

        add_edge("recipe-category", rcat_name, { amount = recipe.energy_required or 0.5 })
        if recipe.enabled == false then
            add_edge("recipe-unlock")
        end
        -- Ingredients with inds for trigger technology support
        if not ingredients_not_needed[recipe.name] then
            for mat_key, inds in pairs(ingredient_map) do
                local mat = gutils.deconstruct(mat_key)
                local mat_type = mat.type
                local mat_name = mat.name
                local fluid_name
                if mat.type == "fluid" then
                    mat_type = "fluid-temperature-range"
                    fluid_name = gutils.deconstruct(mat_name).type
                end
                -- Doesn't account for if a recipe has ingredients for the same fluid with different temperature ranges
                local ing_amount = cutils.find_amount_in_ing_or_prod(recipe.ingredients, {type = mat.type, name = fluid_name or mat.name})
                add_edge(mat_type, mat_name, {
                    inds = inds,
                    amount = ing_amount,
                })
            end
        end
        if recipe.surface_conditions ~= nil then
            add_edge("recipe-surface-condition")
        end
        local create_py_module_node = false
        if recipe.allowed_module_categories ~= nil and #recipe.allowed_module_categories == 1 and lu.is_operability_module_cat[recipe.allowed_module_categories[1]] then
            create_py_module_node = true
            -- Usually, py modules required for a recipe indicate it's in the reproductive complex, which has two module slots
            add_edge("recipe-py-module", nil, { amount = 2 })
        end

        if create_py_module_node then
            ----------------------------------------
            add_node("recipe-py-module", "OR", nil, nil, { mechanic = true })
            ----------------------------------------
            -- Can we get the module required to craft this recipe
            -- TODO: This should be combined in a new node along with entity-operate-py-module (there's only one category we're accounting for anyways)

            for _, mod in pairs(data.raw.module) do
                if mod.category == recipe.allowed_module_categories[1] then
                    -- We can't know the actual amount of time the recipe takes (and thus we can't actually calculate the per-module costs), because we don't know the machine
                    -- Therefore, just assume crafting speed 1
                    add_edge("item", mod.name, { amount = (recipe.energy_required or 0.5) / payback_time })
                end
            end
        end

        if recipe.enabled == false then
            ----------------------------------------
            add_node("recipe-unlock", "OR")
            ----------------------------------------
            -- Can we unlock this recipe in some way?
            -- Recipes are mainly unlocked via technologies, but could also be enabled with control scripting and access to an assembling machine with the recipe as a fixed_recipe (which doesn't require it being enabled to work)

            add_edge("recipe-tech-unlock")
            for machine_name, _ in pairs(lu.fixed_recipes[recipe.name] or {}) do
                -- This isn't where we factor in operation cost; see recipe-category for that
                add_edge("entity-operate", machine_name)
            end

            ----------------------------------------
            add_node("recipe-tech-unlock", "OR")
            ----------------------------------------
            -- Can we unlock this recipe via technology?
            -- This could have itself as canonical because it is technically sensible to randomize the unlock --> recipe edge
            -- However, this is not too much different from randomizing the tech --> unlock edge in most cases

            if unlocking_techs ~= nil then
                for tech_name, _ in pairs(unlocking_techs) do
                    add_edge("technology", tech_name)
                end
            end
        end

        if recipe.surface_conditions ~= nil then
            ----------------------------------------
            add_node("recipe-surface-condition", "OR")
            ----------------------------------------
            -- Can we craft on a surface meeting this recipe's conditions?

            for room_key, room in pairs(lu.rooms) do
                if room.type ~= "control" then
                    if lutils.check_surface_conditions(room, recipe.surface_conditions) then
                        add_edge("room", room_key)
                    end
                end
            end
        end
    end

    ----------------------------------------------------------------------
    -- Recipe Category
    ----------------------------------------------------------------------

    -- Spoofed categories keyed by base category prototype, with nodes for each fluid count variant

    set_class("recipe-category")

    for _, cat in pairs(data.raw["recipe-category"]) do
        set_prot(cat)

        local spoofed_cats = lu.vanilla_to_rcats[cat.name]
        if spoofed_cats ~= nil then
            for rcat_name, _ in pairs(spoofed_cats) do
                ----------------------------------------
                add_node("recipe-category", "OR", nil, rcat_name, { mechanic = true })
                ----------------------------------------
                -- Can we craft recipes in this spoofed category?

                local crafters = lu.rcat_to_crafters[rcat_name]
                if crafters ~= nil then
                    for crafter_name, _ in pairs(crafters) do
                        local crafter_entity = dutils.get_prot("entity", crafter_name)
                        local crafting_speed
                        local base_name
                        if string.len(crafter_entity.name) >= 6 then
                            if string.sub(crafter_entity.name, -5, -3) == "-mk" then
                                base_name = string.sub(crafter_entity.name, 1, -6)
                            end
                        end
                        -- Assume pyAL buildings have crafting speed of 1
                        -- TODO: Factor in higher mk speed bonus
                        if base_name ~= nil and lu.py_operability_module_cats[base_name] ~= nil then
                            crafting_speed = 1
                        else
                            crafting_speed = crafter_entity.crafting_speed
                        end
                        add_edge("entity-operate", crafter_name, { amount = crafting_speed or 1 })
                    end
                end
            end
        end
    end

    ----------------------------------------------------------------------
    -- Resource Category
    ----------------------------------------------------------------------

    -- Spoofed categories keyed by base category prototype, with nodes for each fluid count variant

    set_class("resource-category")

    for _, cat in pairs(data.raw["resource-category"]) do
        set_prot(cat)

        local spoofed_cats = lu.mcat_to_mcats[cat.name]
        if spoofed_cats ~= nil then
            for mcat_key, _ in pairs(spoofed_cats) do
                ----------------------------------------
                add_node("resource-category", "OR", nil, mcat_key, { mechanic = true })
                ----------------------------------------
                -- Can we mine resources in this category with these fluid requirements?

                -- drills includes character as well (since they can also mine things)
                local drills = lu.mcat_to_drills[mcat_key]
                if drills ~= nil then
                    for drill_name, _ in pairs(drills) do
                        local drill = dutils.get_prot("entity", drill_name)
                        add_edge("entity-operate", drill_name, { amount = drill.mining_speed })
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
        add_node("space-connection-asteroids", "AND", nil, nil, { mechanic = true })
        ----------------------------------------
        -- Can we destroy the asteroids on this space connection?
        -- Requires being able to overcome each asteroid type's resistance group.
        -- Made a mechanic so that the big scary asteroids aren't switched in for the small ones

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
                -- TODO: Support for multiple mined entities on a trigger
                -- Right now, this just supports one
                add_edge("entity-mine", trigger.entities[1], {
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
                -- If trigger.entity is set, we need that specific spawner; otherwise any will do
                if trigger.entity ~= nil then
                    add_edge("entity-capture-spawner", trigger.entity, {
                        abilities = table.deepcopy(tech_abilities),
                    })
                else
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

        local tile_rooms = lu.tiles_to_rooms[tile.name]
        if tile_rooms ~= nil then
            for room_key, _ in pairs(tile_rooms) do
                add_edge("room-autoplace", room_key, {
                    abilities = { [1] = true },
                })
            end
        end

        local buildable = lu.buildables[key(tile)]
        if buildable ~= nil then
            add_edge("tile-build")

            ----------------------------------------
            add_node("tile-build", "OR")
            ----------------------------------------
            -- Can we build this tile?

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

            if tile_items ~= nil then
                for item_name, _ in pairs(tile_items) do
                    add_edge("item", item_name)
                end
            end

            -- Compound node: one per (tile, item) pair
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
                    --   * If whitelist is set: only tiles in whitelist are valid
                    --   * If blocking_layers is set: tiles with those layers are excluded

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

                            if (not condition_info.invert and not group_blocked) or (condition_info.invert and group_blocked) then
                                -- For more efficiency, we could depend on groups of tiles again instead of specific tiles, but that is less likely to help in this case and more involved, so let's not go that far for now
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
                end
            end
        end

        if tile.fluid ~= nil then
            ----------------------------------------
            add_node("tile-fluid", "AND")
            ----------------------------------------
            -- Can we pump fluid from this tile?
            -- Requires: tile and compatible pump

            add_edge("tile")
            add_edge("tile-fluid-pump", nil, { amount = 1 })

            ----------------------------------------
            add_node("tile-fluid-pump", "OR")
            ----------------------------------------
            -- Can we operate an offshore pump that can pump from this tile?

            local valid_pumps = lu.tile_valid_pumps[tile.name]
            if valid_pumps ~= nil then
                for pump_name, _ in pairs(valid_pumps) do
                    local pump = data.raw["offshore-pump"][pump_name]
                    add_edge("entity-operate", pump_name, { amount = pump.pumping_speed })
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
