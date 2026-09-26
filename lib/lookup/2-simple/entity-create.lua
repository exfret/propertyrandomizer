-- Maintenance-wise, it's easiest to keep this exact header for all stage 2 lookups, even if not all these are used
-- START repeated header

local collision_mask_util = require("__core__/lualib/collision-mask-util")

local categories = require("helper-tables/categories")
local gutils = require("lib/graph/graph-utils")
local lutils = require("lib/logic/logic-utils")
local dutils = require("lib/data-utils")
local tutils = require("lib/trigger")

local prots = dutils.prots

local stage = {}

local lu
stage.link = function(lu_to_link)
    lu = lu_to_link
end

-- END repeated header

local acquisition = require("lib/logic/acquisition")

-- Creator tables (which prototypes create which)
local function get_default_creator_table(prototype)
    return {
        created_by = {},
        creates = {},
        prototype = prototype,
    }
end

stage.creator_tables = function()
    local creator_tables = {}

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

    -- TODO: I think these could be combined since they just replace trigger library's structure but I'm not sure

    -- Iterate items once using type_to_gather_struct_func dispatch
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

    -- Iterate entities once
    for entity_name, entity in pairs(lu.entities) do
        local gather_func = gather_struct_func[entity.type]
        if gather_func ~= nil then
            local structs = {}
            structs[entity.type] = {[entity_name] = entity}
            gather_func(structs, entity, nil)
            process_structs(structs, gutils.key("entity", entity_name), entity)
        end
    end

    -- Iterate equipment once
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
stage.buildables = function()
    local buildables = {}

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

-- Maps entities to what they spawn when dying
stage.dying_spawns = function()
    local dying_spawns = {}
    local dying_spawns_reverse = {}

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
stage.capsule_spawns = function()
    local capsule_spawns = {}
    local capsule_spawns_reverse = {}

    -- The reverse table also says whether the entity is ours (see entity-own in lib/logic/concrete.lua), which it is unless every effect creating it makes it an enemy (as_enemy)
    local function add_spawn(item_name, entity_name, as_enemy)
        if capsule_spawns[item_name] == nil then
            capsule_spawns[item_name] = {}
        end
        capsule_spawns[item_name][entity_name] = true

        if capsule_spawns_reverse[entity_name] == nil then
            capsule_spawns_reverse[entity_name] = {}
        end
        local spawn = capsule_spawns_reverse[entity_name][item_name] or {
            ours = false,
        }
        spawn.ours = spawn.ours or not as_enemy
        capsule_spawns_reverse[entity_name][item_name] = spawn
    end

    for item_name, item in pairs(lu.items) do
        if item.type == "capsule" then
            -- Only what using the capsule does; entities it spoils into are in spoil_spawns
            local structs = {}
            tutils.gather_capsule_use_structs(structs, item, nil)

            if structs["trigger-effect"] ~= nil then
                for _, te in pairs(structs["trigger-effect"]) do
                    if te.type == "create-entity" and te.entity_name ~= nil then
                        add_spawn(item_name, te.entity_name, te.as_enemy == true)
                    end
                end
            end
        end
    end

    lu.capsule_spawns = capsule_spawns
    lu.capsule_spawns_reverse = capsule_spawns_reverse
end

-- Maps ammo items to entities they spawn
stage.ammo_spawns = function()
    local ammo_spawns = {}
    local ammo_spawns_reverse = {}

    -- The reverse table also says whether the entity is ours (see entity-own in lib/logic/concrete.lua), which it is unless every effect creating it makes it an enemy (as_enemy)
    local function add_spawn(item_name, entity_name, as_enemy)
        if ammo_spawns[item_name] == nil then
            ammo_spawns[item_name] = {}
        end
        ammo_spawns[item_name][entity_name] = true

        if ammo_spawns_reverse[entity_name] == nil then
            ammo_spawns_reverse[entity_name] = {}
        end
        local spawn = ammo_spawns_reverse[entity_name][item_name] or {
            ours = false,
        }
        spawn.ours = spawn.ours or not as_enemy
        ammo_spawns_reverse[entity_name][item_name] = spawn
    end

    for item_name, item in pairs(lu.items) do
        if item.type == "ammo" then
            -- Only what firing the ammo does; entities it spoils into are in spoil_spawns
            local structs = {}
            tutils.gather_ammo_use_structs(structs, item, nil)

            if structs["trigger-effect"] ~= nil then
                for _, te in pairs(structs["trigger-effect"]) do
                    if te.type == "create-entity" and te.entity_name ~= nil then
                        add_spawn(item_name, te.entity_name, te.as_enemy == true)
                    end
                end
            end
        end
    end

    lu.ammo_spawns = ammo_spawns
    lu.ammo_spawns_reverse = ammo_spawns_reverse
end

-- Maps items to entities they create when they spoil (spoil_to_trigger_result), like biter eggs hatching
stage.spoil_spawns = function()
    local spoil_spawns = {}
    local spoil_spawns_reverse = {}

    local function add_spawn(item_name, entity_name)
        if spoil_spawns[item_name] == nil then
            spoil_spawns[item_name] = {}
        end
        spoil_spawns[item_name][entity_name] = true

        if spoil_spawns_reverse[entity_name] == nil then
            spoil_spawns_reverse[entity_name] = {}
        end
        spoil_spawns_reverse[entity_name][item_name] = true
    end

    for item_name, item in pairs(lu.items) do
        -- spoil_to_trigger_result is only used if the item spoils at all
        if item.spoil_to_trigger_result ~= nil and item.spoil_ticks ~= nil and item.spoil_ticks > 0 then
            local structs = {}
            tutils.gather_trigger_structs(structs, item.spoil_to_trigger_result.trigger, nil)

            if structs["trigger-effect"] ~= nil then
                for _, te in pairs(structs["trigger-effect"]) do
                    if te.type == "create-entity" and te.entity_name ~= nil then
                        add_spawn(item_name, te.entity_name)
                    end
                end
            end
        end
    end

    lu.spoil_spawns = spoil_spawns
    lu.spoil_spawns_reverse = spoil_spawns_reverse
end

-- Maps unit spawners to what they spawn (result_units), keyed by the spawned entity's name
-- Each spawn has its class from lib/logic/acquisition.lua (persistent, transient or late); result_units can name any entity, not just units
stage.unit_spawns = function()
    local unit_spawns = {}
    local unit_spawns_reverse = {}

    -- If a spawner lists the same entity twice, keep the class that spawns it most
    local class_rank = {
        late = 1,
        transient = 2,
        persistent = 3,
    }

    for _, spawner in pairs(prots("unit-spawner")) do
        for _, definition in pairs(spawner.result_units) do
            local unit_name, points = acquisition.read_spawn_definition(definition)
            if lu.entities[unit_name] ~= nil then
                local class = acquisition.spawn_class(points)
                unit_spawns[spawner.name] = unit_spawns[spawner.name] or {}
                local old_spawn = unit_spawns[spawner.name][unit_name]
                if old_spawn == nil or class_rank[class] > class_rank[old_spawn.class] then
                    local spawn = {
                        spawner = spawner.name,
                        unit = unit_name,
                        class = class,
                    }
                    unit_spawns[spawner.name][unit_name] = spawn
                    unit_spawns_reverse[unit_name] = unit_spawns_reverse[unit_name] or {}
                    unit_spawns_reverse[unit_name][spawner.name] = spawn
                end
            end
        end
    end

    lu.unit_spawns = unit_spawns
    lu.unit_spawns_reverse = unit_spawns_reverse
end

-- Minable corpses to entities that create them
stage.minable_corpse = function()
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

stage.unit_spawner_captures = function()
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

return stage