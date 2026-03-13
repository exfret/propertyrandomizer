-- Note: We are currently assuming each entity is gotten one way, maybe generalize past that assumption
-- TODO: Will probably need proper claim and validate functions, then just do naive shuffle
-- TODO: I think we should just admit O(n^2) code complexity and split by cases of slot/trav handlers

-- TODO: Dummies (so that, like, ammo can place things)
-- TODO: Decide what to do about splitters getting tree collision mask
-- TODO: Check for awful entities to throw/autoplace/etc. and blacklist
-- TODO: Consider what to do about evolution softlocks (not having access to a building due to evolving past that, etc.)
-- TODO: More trigger-based handlers
-- TODO: Some biter icons not set correctly (for barrels)
-- TODO: Check about what happens if a capsule enters a unit slot

local collision_mask_util
if not offline then
    collision_mask_util = require("__core__/lualib/collision-mask-util")
else
    collision_mask_util = require("offline/lualib/collision-mask-util")
end
local build_graph = require("lib/graph/build-graph")
local top_sort = require("lib/graph/top-sort")
local rng = require("lib/random/rng")
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
    local entities = {}
    local key_to_entity_ind = {}
    for entity_class, _ in pairs(defines.prototypes.entity) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                table.insert(entities, entity)
                key_to_entity_ind[build_graph.key(entity.type, entity.name)] = #entities
            end
        end
    end
    -- Add custom capsule entities
    for _, capsule_trigger_entity in pairs(entity_rando.capsule_to_trigger_entity) do
        table.insert(entities, capsule_trigger_entity)
        key_to_entity_ind[build_graph.key(capsule_trigger_entity.entity.type, capsule_trigger_entity.entity.name)] = #entities
    end
    -- Shuffle for fairness
    local entities_sorted = table.deepcopy(entities)
    rng.shuffle(rng.key({id = "i don't care"}), entities)

    local handlers_in_order = {
        handlers.unit,
        handlers.capsule,
        handlers.placeable,
        handlers.autoplace,
    }
    entity_to_handler = {}
    slot_name_to_slot = {}
    local entities_claimed = {}
    -- Process entities in claim order
    -- TODO: Figure out a good claim order
    for _, entity in pairs(entities) do
        for _, handler in pairs(handlers_in_order) do
            if handler.claim(entity) then
                log(entity.name)
                -- TODO: Should probaby be called slot_to_handler
                entity_to_handler[entity.name] = handler
                slot_name_to_slot[entity.name] = table.deepcopy(entity)
                table.insert(entities_claimed, entity)
                break
            end
        end
    end

    -- Dummies
    local dummies_claimed = {}
    for item_class, _ in pairs(common.valid_item_placeable_types) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                if item.place_result == nil and common.is_valid_placeable(item) then
                    local dummy_name = item.name .. "-dummy-exfret-placeable"
                    local dummy_entity = {
                        type = "dummy",
                        name = dummy_name,
                        item = item,
                    }
                    entity_to_handler[dummy_name] = handlers.placeable
                    slot_name_to_slot[dummy_name] = dummy_entity
                    table.insert(dummies_claimed, dummy_entity)
                end
            end
        end
    end
    rng.shuffle(rng.key({id = "i don't care"}), dummies_claimed)
    for _, dummy in pairs(dummies_claimed) do
        table.insert(entities_claimed, dummy)
    end

    -- For now, we just have slots as entities, but for those there will be extra places
    -- The travs could have dummies at end, travs processed first in order (most important, puts dummies at end), then slots in random order
    local slots = table.deepcopy(entities_claimed)
    local travs = table.deepcopy(entities_claimed)
    rng.shuffle(rng.key({id = "i don't care"}), travs)
    local new_travs = {}
    for _, trav in pairs(travs) do
        if not string.find(trav.name, "dummy") then
            table.insert(new_travs, trav)
        end
    end
    for _, trav in pairs(travs) do
        if string.find(trav.name, "dummy") then
            table.insert(new_travs, trav)
        end
    end
    travs = new_travs

    -- CRITICAL TODO: Move dependents to entity/item rather than the surface nodes (more convenient for later)
    -- TODO: This could lead to softlocks?..

    -- Use key_to_entity_ind to help sort slots
    -- Special cases: item place (dummy entity), and capsules
    local prereq_sort_info = top_sort.sort(dep_graph)
    for _, node in pairs(prereq_sort_info.sorted) do
        local entity_name
        if node.type == "item" then
            local item
            for item_class, _ in pairs(defines.prototypes.item) do
                if data.raw[item_class] ~= nil then
                    if data.raw[item_class][node.item] then
                        item = data.raw[item_class][node.item]
                        break
                    end
                end
            end
            if item.place_result ~= nil and entity_to_handler[item.place_result] ~= nil then

            end
        end
    end

    -- TODO: Shuffle travs, topologically sort slots (maybe do capsule actions by the capsule to minimize graph changes)
    -- We could straight up remove dummy travs, but this still causes issues since some slots (biters/autoplace) require travs too
    -- We could also just put dummy travs at end as permanent reservations? That should probably work; then they're also independently shuffled
    -- Yeah, I think I've done that before as well

    local curr_sort_state = top_sort.sort(dep_graph)

    local function get_corresponding_entity(node)
        return entities_sorted[key_to_entity_ind[build_graph.key(node.type, node.name)]]
    end

    local function is_slot_reachable(slot)
        log(serpent.block(slot))

        -- Check if this is a prereq itself rather than a proper node yet
        local slot_node = slot
        if slot.type == "dummy" and slot.item ~= nil then
            slot_node = dep_graph[build_graph.key(slot.item.type, slot.item.name)]
        elseif slot.prereqs == nil then
            slot_node = dep_graph[build_graph.key(slot.type, slot.name)]
        end
        for _, prereq in pairs(slot_node.prereqs) do
            if curr_sort_state.reachable[build_graph.key(prereq.type, prereq.name)] then
                return true
            end
        end
        return false
    end

    local function is_boring(node)
        local entity_prototype = get_corresponding_entity(node)

        if entity_prototype.type == "simple-entity" then
            return true
        end

        -- TODO: I'm not too sure what makes an entity boring right now
        return false
    end

    local function is_trav_reachable(node)
        return curr_sort_state.reachable[build_graph.key(node.type, node.name)] or is_slot_reachable(dep_graph[build_graph.key("entity-slot", node.name)])
    end

    -- Actual randomization; goal to populate slot_to_trav
    local used_trav_ind = {}
    local used_slot_ind = {}
    slot_to_trav = {}
    trav_to_slot = {}
    -- Just need real travs to get assigned, not all travs
    while true do
        local old_slot
        local new_trav

        -- Max number of bootings
        for i = 1, 5 do
            for _, slot in pairs(slots) do
                if slot_to_trav[build_graph.key(slot.type, slot.name)] == nil and is_slot_reachable(slot) then
                    for _, trav in pairs(travs) do
                        if trav_to_slot[build_graph.key(trav.type, trav.name)] == nil and (is_boring(slot) or is_trav_reachable(trav)) then
                            if entity_to_handler[slot.name].validate == nil or entity_to_handler[slot.name].validate(slot, trav) then
                                old_slot = slot
                                new_trav = trav
                                break
                            end
                        end
                    end
                end
                if old_slot ~= nil then
                    break
                end
            end
            if old_slot ~= nil then
                break
            end
            -- Otherwise, try to boot
            local booting_successful = false
            for _, trav in pairs(travs) do
                -- Check on short path
                local on_short_path = false
                for surface_name, surface in pairs(build_graph.surfaces) do
                    -- CRITICAL TODO: Capture special capsule nodes
                    if short_path[build_graph.key("entity-surface", build_graph.compound_key({trav.name, surface_name}))] then
                        on_short_path = true
                    end
                end
                if trav_to_slot[build_graph.key(trav.type, trav.name)] == nil and is_trav_reachable(trav) and not is_boring(trav) and on_short_path then
                    if #reserved_slots >= 1 then
                        local canceled_slot = reserved_slots[#reserved_slots]
                        
                        -- CRITICAL TODO
                    else
                        break
                    end
                end
            end
            if not booting_successful then
                error()
            end
        end
    end
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