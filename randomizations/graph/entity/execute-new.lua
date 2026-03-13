-- I just made this file and copy-pasted still applicable old parts over, no new code has been written yet

-- Uses new logic
-- TODO: Make sure to use testing!

local collision_mask_util
if not offline then
    collision_mask_util = require("__core__/lualib/collision-mask-util")
else
    collision_mask_util = require("offline/lualib/collision-mask-util")
end
local rng = require("lib/random/rng")
local logic = require("new-lib/logic/init")
local top = require("new-lib/graph/top-sort")
local locale = require("lib/locale")
local common = require("randomizations/graph/entity/common")

local entity_rando = {}

local handlers = {}

handlers.autoplace = require("randomizations/graph/entity/autoplace")
handlers.capsule = require("randomizations/graph/entity/capsule")
handlers.placeable = require("randomizations/graph/entity/placeable")
handlers.unit = require("randomizations/graph/entity/unit")

local slot_to_trav
local trav_to_slot
local slot_name_to_slot
local entity_to_handler

entity_rando.preprocess = function()
    common.populate_entity_to_place_item()

    data:extend({
        {
            type = "explosion",
            name = "blank-entity",
            animations = util.empty_sprite(),
            -- Give a collision mask to make things like explosions less spammable
            collision_mask = collision_mask_util.get_default_mask("assembling-machine"),
            delay = 40,
        }
    })

    -- Preprocessing for capsules; add each capsule effect that creates an entity as if it was that entity
    entity_rando.capsule_to_trigger_entity = {}
    local function to_entities_created(entities, tbl)
        for k, v in pairs(tbl) do
            if type(v) == "table" then
                if v.entity_name ~= nil then
                    entities[v.entity_name] = true
                else
                    to_entities_created(entities, v)
                end
            end
        end
    end
    local function to_projectiles_created(projectiles, tbl)
        for k, v in pairs(tbl) do
            if type(v) == "table" then
                if v.projectile ~= nil then
                    table.insert(projectiles, v.projectile)
                else
                    to_projectiles_created(projectiles, v)
                end
            end
        end
    end
    for _, capsule in pairs(data.raw.capsule) do
        local entities_created = {}
        local projectiles_created = {}
        local capsule_action = capsule.capsule_action
        if capsule_action.type == "throw" then
            local attack_parameters = capsule_action.attack_parameters
            if attack_parameters.type == "projectile" then
                local ammo_type = attack_parameters.ammo_type
                if ammo_type ~= nil then
                    if ammo_type.action ~= nil then
                        local trigger = ammo_type.action
                        to_projectiles_created(projectiles_created, trigger)
                    end
                end
            end
        end
        -- TODO: Account for more than one projectile creating an entity?
        local projectile_creating_entity
        for _, projectile in pairs(projectiles_created) do
            local projectile_entities_created = {}
            to_entities_created(projectile_entities_created, data.raw.projectile[projectile])
            if next(projectile_entities_created) ~= nil then
                -- Assume action is what created the entity; if nil, there is weirdness so skip
                if projectile_creating_entity ~= nil then
                    entities_created = {}
                    break
                else
                    projectile_creating_entity = data.raw.projectile[projectile]
                    for entity_name, _ in pairs(projectile_entities_created) do
                        entities_created[entity_name] = true
                    end
                end
            end
        end
        local unique_entity_created
        for entity_name, _ in pairs(entities_created) do
            -- Skip projectile creation special case
            if data.raw.projectile[entity_name] ~= nil then
                unique_entity_created = nil
                break
            end
            if unique_entity_created ~= nil then
                unique_entity_created = nil
                break
            end
            unique_entity_created = entity_name
        end
        if unique_entity_created ~= nil then
            local unique_entity
            for entity_class, _ in pairs(defines.prototypes.entity) do
                if data.raw[entity_class] ~= nil then
                    if data.raw[entity_class][unique_entity_created] ~= nil then
                        unique_entity = data.raw[entity_class][unique_entity_created]
                        break
                    end
                end
            end
            entity_rando.capsule_to_trigger_entity[capsule.name] = {
                type = "capsule_trigger",
                name = capsule.name,
                entity = unique_entity,
                projectile = projectile_creating_entity,
                trigger = projectile_creating_entity.action,
            }
        end
    end
end

entity_rando.shuffle = function()
    -- CRITICAL TODO
end

-- Reflection functions are based on slot entity
entity_rando.reflect = function()
    -- Reflect
    for slot_name, trav in pairs(slot_to_trav) do
        -- CRITICAL TODO: Make sure I account for spoofed dummy slots! (Just thought of this)
        -- Note: slot_name_to_slot gives a deepcopied version and is thus basically the same as giving an old_data_raw version
        local slot = slot_name_to_slot[slot_name]
        entity_to_handler[slot_name].reflect(slot, trav)
    end

    -- Fixes
    -- Iterates over all handlers with fix functions, then over all entities
    for _, handler in pairs(handlers) do
        if handler.fix ~= nil then
            for entity_class, _ in pairs(defines.prototypes.entity) do
                if data.raw[entity_class] ~= nil then
                    for _, entity in pairs(data.raw[entity_class]) do
                        handler.fix(entity)
                    end
                end
            end
        end
    end
end

return entity_rando