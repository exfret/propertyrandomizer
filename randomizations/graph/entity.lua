-- Note: We are currently assuming each entity is gotten one way, maybe generalize past that assumption
-- TODO: Will probably need proper claim and validate functions, then just do naive shuffle
-- TODO: Write this in a better way that separates "old data" from "new data" (maybe helper functions to go to old data)
-- TODO: I think we should just admit O(n^2) code complexity and split by cases of slot/trav handlers

local collision_mask_util = require("__core__/lualib/collision-mask-util")
local rng = require("lib/random/rng")
local locale = require("lib/locale")
local trigger = require("lib/trigger")

local entity_rando = {}

entity_rando.entity_to_trigger = {}

handlers = {}

----------------------------------------------------------------------
-- Placeable
----------------------------------------------------------------------

handlers.placeable = {}

local valid_item_types = {
    ["item"] = true,
    ["ammo"] = true,
    ["capsule"] = true,
    ["gun"] = true,
    ["module"] = true,
    ["space-platform-starter-pack"] = true,
    ["tool"] = true,
    ["armor"] = true,
    ["repair-tool"] = true,
}

local function is_valid_placeable(item)
    if item.place_result == nil then
        return false
    end

    if item.hidden then
        return false
    end

    if not valid_item_types[item.type] then
        return false
    end

    if item.plant_result ~= nil then
        return false
    end

    if item.place_as_tile ~= nil then
        return false
    end

    return true
end

handlers.placeable.claim = function(entity)
    local place_item
    if entity.placeable_by ~= nil and entity.placeable_by.item ~= nil then
        local item_name = entity.placeable_by.item
        for item_class, _ in pairs(defines.prototypes.item) do
            if data.raw[item_class][item_name] ~= nil then
                place_item = data.raw[item_class][item_name]
                break
            end
        end
    end
    if place_item == nil or place_item.place_result ~= entity.name or not is_valid_placeable(place_item) then
        return false
    end
    return true
end

-- slot is way to get, trav is entity to put there, both are given as literal entities (not nodes), unless trav is just "dummy" (no need for slot dummies)
handlers.placeable.reflect = function(slot, trav)
    local place_item
    if slot.placeable_by ~= nil and slot.placeable_by.item ~= nil then
        local item_name = slot.placeable_by.item
        for item_class, _ in pairs(defines.prototypes.item) do
            if data.raw[item_class][item_name] ~= nil then
                place_item = data.raw[item_class][item_name]
                break
            end
        end
    end
    if place_item == nil or place_item.place_result ~= slot.name or not is_valid_placeable(place_item) then
        return false
    end
    
    -- First check for trav entity
    if trav == "dummy" then
        place_item.place_result = nil
        -- Apply gray tint
        if place_item.icons ~= nil then
            for _, layer in pair(place_item.icons) do
                layer.tint = {r = 0.5, g = 0.5, b = 0.5, a = 1}
            end
        else
            place_item.icons = {
                {
                    icon = place_item.icon,
                    icon_size = place_item.icon_size or 64,
                    tint = {r = 0.5, g = 0.5, b = 0.5, a = 1},
                }
            }
            place_item.icon = nil
        end
        -- Update name to represent that item no longer places entity
        place_item.localised_name = {"", locale.find_localised_name(place_item), " (Vestige)"}
        return true
    end
    
    -- Next, check for trigger entities
    if trav.type == "capsule_trigger" then
        local entity = trav.entity
        local blank_triggerer = table.deepcopy(data.raw.explosion["blank-entity"])
        local blank_triggerer_name = blank_triggerer.name .. "-" .. trav.name
        blank_triggerer.name = blank_triggerer_name
        blank_triggerer.created_effect = trav.trigger
        data:extend({
            blank_triggerer
        })

        place_item.place_result = blank_triggerer_name
        -- Update icon
        if entity.icons ~= nil then
            place_item.icons = table.deepcopy(entity.icons)
            place_item.icon = nil
            place_item.icon_size = nil
        else
            place_item.icon = entity.icon
            place_item.icon_size = entity.icon_size or 64
            place_item.icons = nil
        end
        -- Update localization
        place_item.localised_name = locale_utils.find_localised_name(entity)
        -- Update subgroup, order and stack_size
        place_item.subgroup = entity.subgroup or "other"
        place_item.order = entity.order or "other"
        place_item.stack_size = 50

        -- Don't update minable (trigger entities shouldn't be minable)

        return true
    end

    place_item.place_result = trav.name
    trav.placeable_by = table.deepcopy(slot.placeable_by)
    -- Update icon
    if trav.icons ~= nil then
        place_item.icons = table.deepcopy(trav.icons)
        place_item.icon = nil
        place_item.icon_size = nil
    else
        place_item.icon = trav.icon
        place_item.icon_size = trav.icon_size or 64
        place_item.icons = nil
    end
    -- Update localization
    place_item.localised_name = locale_utils.find_localised_name(trav)
    -- Update subgroup, order, and stack_size
    local old_trav_item
    if trav.placeable_by ~= nil and trav.placeable_by.item ~= nil then
        local item_name = trav.placeable_by.item
        for item_class, _ in pairs(defines.prototypes.item) do
            if data.raw[item_class] ~= nil then
                if data.raw[item_class][item_name] ~= nil then
                    old_trav_item = data.raw[item_class][item_name]
                    break
                end
            end
        end
    end
    -- Default to item placing trav, otherwise to trav
    if old_trav_item ~= nil and old_trav_item.place_result == trav.name and is_valid_placeable(old_trav_item) then
        place_item.subgroup = old_trav_item.subgroup or "other"
        place_item.order = old_trav_item.order or "other"
        place_item.stack_size = old_trav_item.stack_size
    else
        place_item.subgroup = trav.subgroup or "other"
        place_item.order = trav.order or "other"
        -- Default stack size to 50
        place_item.stack_size = 50
    end

    -- Update minable result
    if trav.minable ~= nil then
        trav.minable.result = place_item.name
        trav.minable.count = 1
        trav.minable.results = nil
    end
end

handlers.placeable.fix = function(entity)
    -- Remove next_upgrade property (hotfix for now)
    entity.next_upgrade = nil
end

----------------------------------------------------------------------
-- Capsule
----------------------------------------------------------------------

handlers.capsule = {}

handlers.capsule.claim = function(entity)
    if entity.type == "capsule_trigger" then
        return true
    end
    return false
end

handlers.capsule.reflect = function(slot, trav)
    local capsule = data.raw.capsule[slot.name]

    -- Check for dummy trav
    if trav == "dummy" then
        -- Lose capsule powers
        capsule.type = "item"
        capsule.capsule_action = nil
        capsule.radius_color = nil
        -- Apply gray tint
        if capsule.icons ~= nil then
            for _, layer in pair(capsule.icons) do
                layer.tint = {r = 0.5, g = 0.5, b = 0.5, a = 1}
            end
        else
            capsule.icons = {
                {
                    icon = capsule.icon,
                    icon_size = capsule.icon_size or 64,
                    tint = {r = 0.5, g = 0.5, b = 0.5, a = 1},
                }
            }
            capsule.icon = nil
        end
        -- Adjust name
        capsule.localised_name = {"", locale.find_localised_name(capsule), " (Vestige)"}

        return true
    end
    
    -- Check for other trigger entities
    -- TODO: No wait, we should be just changing the projectile's action, that way capsules can still have distinct mix n' match flavors; I'll do this later
    if trav.type == "capsule_trigger" then
        local trav_capsule = old_data_raw.capsule[trav.name]

        capsule.capsule_action = table.deepcopy(trav_capsule.capsule_action)

        if trav_capsule.icons ~= nil then
            capsule.icons = trav_capsule.icons
            capsule.icon = nil
            capsule.icon_size = nil
        elseif trav_capsule.icon ~= nil then
            capsule.icon = trav_capsule.icon
            capsule.icon_size = trav_capsule.icon_size or 64
            capsule.icons = nil
        else
            -- Icons are mandatory for items, so trav better have had icons
            error("capsule trav had no icons!")
        end
        capsule.localised_name = locale.find_localised_name(trav_capsule)

        return true
    end

    -- Everything else: just make the capsule action's projectiles create the entity
    -- Slots are old_data_raw, so we need to get the new data.raw version
    data.raw.projectile[slot.projectile.name].action = {
        type = "direct",
        action_delivery = {
            type = "instant",
            target_effects = {
                type = "create-entity",
                name = trav.name,
            }
        }
    }
    -- Change icon to be a smaller version of the capsule in top left over the entity icon
    -- TODO: Really, they should be old_data_raw icons
    local new_icons = table.deepcopy(trav.icons) or {
        {
            icon = trav.icon,
            icon_size = trav.icon_size or 64,
        }
    }
    if capsule.icons ~= nil then
        for _, icon_data in pairs(capsule.icons) do
            local new_icon_data = table.deepcopy(icon_data)
            new_icon_data.scale = (new_icon_data.scale or 1) / 2
            table.insert(new_icons, table.deepcopy(new_icon_data))
        end
    elseif capsule.icon ~= nil then
        table.insert(new_icons, {
            icon = capsule.icon,
            icon_size = capsule.icon_size or 64,
            scale = 1 / 2,
        })
    end
    capsule.localised_name = {"", locale.find_localised_name(trav), " (Throwable)"}
end

----------------------------------------------------------------------
-- Unit
----------------------------------------------------------------------

handlers.unit = {}

local function extract_sprite_layer(source)
    if source == nil then
        return nil
    end

    if source.filename ~= nil then
        return {
            filename = source.filename,
            width = source.width,
            height = source.height,
            frame_count = 1,
            direction_count = 1,
            scale = source.scale or 0.5,
            shift = source.shift or {0, 0},
        }
    end

    if source.layers ~= nil and source.layers[1] ~= nil then
        return extract_sprite_layer(source.layers[1])
    end
    if source.sheet ~= nil then
        return extract_sprite_layer(source.sheet)
    end
    if source.sheets ~= nil and source.sheets[1] ~= nil then
        return extract_sprite_layer(source.sheets[1])
    end

    return nil
end

-- Entity types that have good full-entity graphics
local good_graphics_types = {
    ["assembling-machine"] = true,  -- graphics_set.animation
    ["furnace"] = true,             -- graphics_set.animation
    ["container"] = true,           -- picture
    ["logistic-container"] = true,  -- picture
    ["lab"] = true,                 -- on_animation
    ["solar-panel"] = true,         -- picture
    ["beacon"] = true,              -- graphics_set
    ["reactor"] = true,             -- picture (nuclear)
    ["fusion-reactor"] = true,      -- graphics_set
    ["accumulator"] = true,         -- chargable_graphics
    ["boiler"] = true,              -- pictures (structure)
    ["generator"] = true,           -- horizontal/vertical_animation
    ["fusion-generator"] = true,    -- graphics_set
    ["mining-drill"] = true,        -- graphics_set
    ["offshore-pump"] = true,       -- graphics_set
    ["pump"] = true,                -- animations
    ["arithmetic-combinator"] = true, -- sprites
    ["decider-combinator"] = true,  -- sprites
    ["constant-combinator"] = true, -- sprites
    ["selector-combinator"] = true, -- sprites
    ["lamp"] = true,                -- picture_on
    ["agricultural-tower"] = true,  -- graphics_set
    ["biolab"] = true,              -- on_animation
    ["rocket-silo"] = true,         -- graphics_set
    ["cargo-landing-pad"] = true,   -- graphics_set
    ["space-platform-hub"] = true,  -- graphics_set
    ["radar"] = true,               -- pictures
    ["roboport"] = true,            -- base
    ["storage-tank"] = true,        -- pictures
}

-- Helper: calculate scale for icon based on entity's size
local function get_icon_scale_for_entity(entity)
    local box = entity.selection_box or entity.collision_box
    if box ~= nil then
        local width = math.abs(box[2][1] - box[1][1])
        local height = math.abs(box[2][2] - box[1][2])
        local size = math.max(width, height)
        -- Icon is 64px, entity tiles are 32px each at scale 1
        -- scale = size * 32 / 64 = size / 2
        return size / 2
    end
    return 1 -- fallback for entities without boxes (like explosions)
end

-- Helper: try to get full-entity graphics, fall back to icon
local function get_entity_visual(entity)
    -- Only try extraction for known good types
    if good_graphics_types[entity.type] then
        local layer = nil

        -- Try various good graphics sources
        if entity.graphics_set ~= nil and entity.graphics_set.animation ~= nil then
            layer = extract_sprite_layer(entity.graphics_set.animation)
        elseif entity.on_animation ~= nil then
            layer = extract_sprite_layer(entity.on_animation)
        elseif entity.picture ~= nil then
            layer = extract_sprite_layer(entity.picture)
        elseif entity.pictures ~= nil and entity.pictures.picture ~= nil then
            layer = extract_sprite_layer(entity.pictures.picture)
        elseif entity.chargable_graphics ~= nil and entity.chargable_graphics.picture ~= nil then
            layer = extract_sprite_layer(entity.chargable_graphics.picture)
        elseif entity.sprites ~= nil then
            layer = extract_sprite_layer(entity.sprites)
        elseif entity.picture_on ~= nil then
            layer = extract_sprite_layer(entity.picture_on)
        elseif entity.horizontal_animation ~= nil then
            layer = extract_sprite_layer(entity.horizontal_animation)
        elseif entity.animations ~= nil then
            layer = extract_sprite_layer(entity.animations)
        elseif entity.base ~= nil then
            layer = extract_sprite_layer(entity.base)
        elseif entity.base_animation ~= nil then
            layer = extract_sprite_layer(entity.base_animation)
        elseif entity.pictures ~= nil and type(entity.pictures) == "table" then
            -- radar/storage-tank style
            if entity.pictures.layers ~= nil then
                layer = extract_sprite_layer(entity.pictures)
            elseif entity.pictures[1] ~= nil then
                layer = extract_sprite_layer(entity.pictures[1])
            end
        end

        if layer ~= nil then
            return { layers = { layer } }
        end
    end

    -- Fall back to icon for everything else
    local icon_file = nil
    local icon_size = 64

    if entity.icons ~= nil and entity.icons[1] ~= nil then
        icon_file = entity.icons[1].icon
        icon_size = entity.icons[1].icon_size or 64
    elseif entity.icon ~= nil then
        icon_file = entity.icon
        icon_size = entity.icon_size or 64
    end

    if icon_file == nil then
        return nil
    end

    -- Scale icon based on entity's actual size
    local scale = get_icon_scale_for_entity(entity)

    return {
        layers = {
            {
                filename = icon_file,
                width = icon_size,
                height = icon_size,
                frame_count = 1,
                direction_count = 1,
                scale = scale,
                shift = {0, 0},
            }
        }
    }
end

-- TODO: Don't allow rails/rail remnants (maybe not in general)
handlers.unit.reflect = function(slot, trav)
    -- data.raw version of slot
    local unit = data.raw.unit[slot.name]

    -- Don't accept dummy travs for units
    if trav == "dummy" then
        error("Unit slots must have non-dummy travelers!")
    end

    if trav.type == "capsule_trigger" then
        local trav_anim = get_entity_visual(trav)
        if trav_anim == nil then
            error("Units must have trav_anim.")
        end

        unit.run_animation = trav_anim
        unit.attack_parameters.animation = trav_anim
        unit.alternative_attacking_frame_sequence = nil

        -- Update icon and name
        -- TODO: This should actually be a deepcopied/old_data_raw version, rather than trav
        if trav.icons ~= nil then
            unit.icons = table.deepcopy(trav.icons)
            unit.icon = nil
            unit.icon_size = nil
        elseif trav.icon ~= nil then
            unit.icon = trav.icon
            unit.icon_size = trav.icon_size or 64
            unit.icons = nil
        else
            unit.icon = nil
            unit.icon_size = nil
            unit.icons = nil
        end
        unit.localised_name = {"", locale_utils.find_localised_name(trav), " (Angry)"}

        -- TODO: Left off here - I think that I finished this section actually, but still need to review and refactor a lot of other things here

        return true
    end

    -- Everything else: Do visual change
    local trav_anim = get_entity_visual(trav)
    -- Things without anim shouldn't be units
    if trav_anim == nil then
        error("Units must have trav_anim.")
    end
    unit.run_animation = trav_anim
    unit.attack_parameters.animation = table.deepcopy(trav_anim)
    -- Clear frame sequence references
    unit.alternative_attacking_frame_sequence = nil

    -- Update icon and name
    if trav.icons ~= nil then
        unit.icons = table.deepcopy(trav.icons)
        unit.icon = nil
        unit.icon_size = nil
    elseif trav.icon ~= nil then
        unit.icon = trav.icon
        unit.icon_size = trav.icon_size or 64
        unit.icons = nil
    else
        unit.icon = nil
        unit.icon_size = nil
        unit.icons = nil
    end
    unit.localised_name = {"", locale_utils.find_localised_name(trav), " (Angry)"}
    -- TODO/idea: Add red tint to show anger?
    -- TODO/idea: If they die again while pacified, they turn back to enemies
    -- Create new corpse
    local unit_corpse = table.deepcopy(data.raw.corpse[trav.corpse])
    unit_corpse.localised_name = {"", locale_utils.find_localised_name(unit_corpse), " (Pacified)"}
    unit_corpse.name = unit_corpse.name .. "-unit"
    unit_corpse.minable = {
        mining_time = 0.1,
        result = trav.name .. "-unit" -- New item that places entity
    }
    -- TODO: More item handling, right now we just create a basic item
    local new_place_item = {
        type = "item",
        name = trav.name .. "-unit",
        localised_name = locale_utils.find_localised_name(trav),
        subgroup = trav.subgroup or "other",
        order = building.order,
        stack_size = 50,
        place_result = trav.name,
    }
    if trav.icons ~= nil then
        new_place_item.icons = table.deepcopy(trav.icons)
    elseif trav.icon ~= nil then
        new_place_item.icon = trav.icon
        new_place_item.icon_size = trav.icon_size or 64
    end
    data:extend({new_place_item})
end

----------------------------------------------------------------------
-- Autoplace
----------------------------------------------------------------------

handlers.autoplace = {}

-- TODO: What to do about vulcanus chimneys being so awful to mine?
local autoplace_blacklist_types = {
    ["resource"] = true,
    ["unit-spawner"] = true,
    ["plant"] = true, -- Includes yumako/jellynut
}

-- Used to make sure we only zero out an autoplace once
local processed_autoplaces = {}
handlers.autoplace.reflect = function(slot, trav)
    -- Reject dummy, explosion, and unit
    -- Dummy could be fine, but I'd want dummy autoplaces too, and those would take some work
    if trav == "dummy" then
        error("Dummy not allowed for autoplace")
    end
    if trav.type == "unit" or trav.type == "capsule_trigger" then
        error("Unallowed autoplace type")
    end

    trav.autoplace = slot.autoplace
    -- Get slot entity in new data.raw
    local slot_new
    for entity_class, _ in pairs(defines.prototypes.entity) do
        if data.raw[entity_class] ~= nil then
            if data.raw[entity_class][slot.name] ~= nil then
                slow_new = data.raw[entity_class][slot.name]
                break
            end
        end
    end
    slot_new.autoplace = nil
    -- Update planet map_gen_settings
    for _, planet in pairs(old_data_raw.planet) do
        local map_gen_settings = planet.map_gen_settings
        if map_gen_settings ~= nil then
            -- TODO: Account for autoplace controls as well
            local autoplace_settings = map_gen_settings.autoplace_settings
            if autoplace_settings ~= nil then
                local entity_settings = autoplace_settings.entity
                if entity_settings[slot.name] ~= nil then
                    local data_raw_settings = data.raw.planet[planet.name].map_gen_settings.autoplace_settings.entity
                    data_raw_settings[trav.name] = entity_settings[slot.name]
                    processed_autoplaces[planet.name] = processed_autoplaces[planet.name] or {}
                    if not processed_autoplaces[planet.name][slot.name] then
                        processed_autoplaces[planet.name][slot.name] = true
                        data_raw_settings[slot.name] = nil
                    end
                end
            end
        end
    end
    -- Change collision masks
    -- Useful so things can still act like fish
    trav.collision_mask = slot.collision_mask or collision_mask_util.get_default_mask(slot.type)
end

----------------------------------------------------------------------
-- Asteroids
----------------------------------------------------------------------

-- TODO

----------------------------------------------------------------------
-- Captured Spawners
----------------------------------------------------------------------

-- TODO

-- TODO: More triggers?

----------------------------------------------------------------------
-- Main reflection
----------------------------------------------------------------------

-- Reflection functions are based on slot entity
entity_rando.reflect = function(item)
    -- Make sure to pass old_data_raw version of slots
    old_data_raw = table.deepcopy(data.raw)

    data:extend({
        {
            type = "explosion",
            name = "blank-entity",
            animations = util.empty_sprite(),
            -- Give a collision mask to make things like explosions less spammable
            collision_mask = collision_mask_util.get_default_mask("assembling-machine"),
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
                if projectile_creating_entity ~= nil or projectile.action == nil then
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

    local entities = {}
    for entity_class, _ in pairs(defines.prototypes.entity) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                table.insert(entities, entity)
            end
        end
    end
    -- Add custom capsule entities
    for _, capsule_trigger_entity in pairs(capsule_to_trigger_entity) do
        table.insert(entities, capsule_trigger_entity)
    end

    local entity_to_handler = {}
    local slot_name_to_slot = {}
    -- Process entities in claim order
    -- TODO: Figure out a good claim order
    for _, entity in pairs(entities) do
        for _, handler in pairs(handler) do
            if handler.claim(entity) then
                -- TODO: Should probaby be called slot_to_handler
                entity_to_handler[entity.name] = handler
                slot_name_to_slot[entity.name] = table.deepcopy(entity)
                break
            end
        end
    end

    -- TODO: Add dummies
    -- For now, we just have slots as entities, but for those there will be extra places
    -- The travs could have dummies at end, travs processed first in order (most important, puts dummies at end), then slots in random order
    local travs = table.deepcopy(entities)
    local slots = table.deepcopy(entities)
    rng.shuffle(rng.key({id = "i don't care"}), slots)

    local slot_to_trav = {}
    local used_slot_inds = {}
    for _, trav in pairs(travs) do
        local found_slot = false
        for slot_ind, slot in pairs(shuffled) do
            if not used_slot_inds[slot_ind] and entity_to_handler[slot.name].validate(slot, trav) then
                used_slot_inds[slot_ind] = true
                slot_to_trav[slot.name] = trav
                found_trav = true
                break
            end
        end
        if not found_slot and trav ~= "dummy" then
            error("Traveler not found")
        end
    end

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