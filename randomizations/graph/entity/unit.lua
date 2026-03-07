local locale = require("lib/locale")

local unit = {}

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

unit.claim = function(entity)
    if entity.type == "unit" then
        return true
    end
    return false
end

local blacklisted_unit_types = {
    ["dummy"] = true,
    ["curved-rail-a"] = true,
    ["elevated-curved-rail-a"] = true,
    ["curved-rail-b"] = true,
    ["elevated-curved-rail-b"] = true,
    ["half-diagonal-rail"] = true,
    ["elevated-half-diagonal-rail"] = true,
    ["legacy-curved-rail"] = true,
    ["legacy-straight-rail"] = true,
    ["rail-ramp"] = true,
    ["straight-rail"] = true,
    ["elevated-straight-rail"] = true,
}

unit.validate = function(slot, trav)
    -- Trav must have corpse to validate
    if trav.corpse == nil then
        return false
    end
    if blacklisted_unit_types[trav.type] then
        return false
    end
    return true
end

-- TODO: Don't allow rails/rail remnants (maybe not in general)
unit.reflect = function(slot, trav)
    -- Don't accept dummy travs for units
    if trav.type == "dummy" then
        error("Unit slots must have non-dummy travelers!")
    end

    local unit = table.deepcopy(slot)
    unit.name = unit.name .. "-exfret-unit"
    -- Change unit spawner results
    for _, spawner in pairs(old_data_raw["unit-spawner"]) do
        for ind, spawn_def in pairs(spawner.result_units) do
            if spawn_def[1] == slot.name then
                data.raw["unit-spawner"][spawner.name].result_units[ind][1] = unit.name
            elseif spawn_def.unit == slot.name then
                data.raw["unit-spawner"][spawner.name].result_units[ind].unit = unit.name
            end
        end
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
        unit.localised_name = {"", locale.find_localised_name(trav), " (Angry)"}

        -- TODO: Left off here - I think that I finished this section actually, but still need to review and refactor a lot of other things here
        -- CRITICAL TODO: Finish/merge this

        return true
    end

    -- Everything else: Do visual change
    local trav_anim = get_entity_visual(trav)
    -- Things without anim shouldn't be units
    if trav_anim == nil then
        error("Units must have trav_anim.")
    end
    -- TODO: Maybe check that the units don't get too big or small?
    unit.collision_box = trav.collision_box or {{-0.8, -0.8}, {0.8, 0.8}}
    unit.selection_box = trav.selection_box or {{-1, -1}, {1, 1}}

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
    unit.localised_name = {"", locale.find_localised_name(trav), " (Angry)"}
    -- TODO/idea: Add red tint to show anger?
    -- TODO/idea: If they die again while pacified, they turn back to enemies
    -- Create new corpse
    local unit_corpse = table.deepcopy(data.raw.corpse[trav.corpse])
    unit_corpse.localised_name = {"", locale.find_localised_name(trav), " (Pacified)"}
    unit_corpse.name = unit_corpse.name .. "-exfret-corpse"
    unit_corpse.minable = {
        mining_time = 0.1,
        result = trav.name .. "-exfret-unit" -- New item that places entity
    }
    unit_corpse.selection_box = trav.selection_box or {{-1, -1}, {1, 1}}
    unit_corpse.selection_priority = 51
    unit_corpse.selectable_in_game = true
    data:extend({unit_corpse})
    unit.corpse = unit_corpse.name
    unit.dying_explosion = old_data_raw[trav.type][trav.name].dying_explosion
    unit.damaged_trigger_effect = old_data_raw[trav.type][trav.name].damaged_trigger_effect
    unit.dying_trigger_effect = old_data_raw[trav.type][trav.name].dying_trigger_effect
    -- TODO: More item handling, right now we just create a basic item
    local new_place_item = {
        type = "item",
        name = trav.name .. "-exfret-unit",
        localised_name = locale.find_localised_name(trav),
        subgroup = trav.subgroup or "other",
        order = trav.order,
        stack_size = 50,
        place_result = trav.name,
    }
    if trav.icons ~= nil then
        new_place_item.icons = table.deepcopy(trav.icons)
    elseif trav.icon ~= nil then
        new_place_item.icon = trav.icon
        new_place_item.icon_size = trav.icon_size or 64
    end
    data.raw[trav.type][trav.name].placeable_by = {item = new_place_item.name, count = 1}
    data:extend({new_place_item})
    data:extend({unit})
end

return unit