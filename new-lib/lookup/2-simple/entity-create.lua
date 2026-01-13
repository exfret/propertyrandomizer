-- Maintenance-wise, it's easiest to keep this exact header for all stage 2 lookups, even if not all these are used
-- START repeated header

local collision_mask_util
if not offline then
    collision_mask_util = require("__core__/lualib/collision-mask-util")
else
    collision_mask_util = require("offline/lualib/collision-mask-util")
end

local categories = require("helper-tables/categories")
local gutils = require("new-lib/graph/graph-utils")
local lutils = require("new-lib/logic/logic-utils")
local dutils = require("new-lib/data-utils")
local tutils = require("lib/trigger")

local prots = dutils.prots

local stage = {}

local lu
stage.link = function(lu_to_link)
    lu = lu_to_link
end

-- END repeated header

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
stage.ammo_spawns = function()
    local ammo_spawns = {}
    local ammo_spawns_reverse = {}

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