local locale = require("lib/locale")
local common = require("randomizations/graph/entity/common")

local placeable = {}

placeable.claim = function(entity)
    local place_item = common.entity_to_place_item[entity.name]

    -- Note that for us, there are items that place something that aren't "valid placeable"
    if place_item == nil or not common.is_valid_placeable(place_item) then
        return false
    end

    return true
end

placeable.reflect = function(slot, trav)
    local place_item
    if slot.type == "dummy" then
        place_item = data.raw[slot.item.type][slot.item.name]
    else
        place_item = common.entity_to_place_item[slot.name]
    end
    local old_place_item = old_data_raw[place_item.type][place_item.name]
    
    -- First check for trav entity
    if trav.type == "dummy" then
        if slot.type == "dummy" then
            return true
        end

        place_item.place_result = nil
        -- Apply gray tint
        if place_item.icons ~= nil then
            for _, layer in pairs(place_item.icons) do
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
        place_item.localised_name = {"", locale.find_localised_name(old_place_item), " (Vestige)"}
        return true
    end
    
    -- Next, check for trigger entities
    -- TODO: There is a lot of duplicate code here, maybe combine?
    if trav.type == "capsule_trigger" then
        local entity = old_data_raw[trav.entity.type][trav.entity.name]
        local blank_triggerer = table.deepcopy(data.raw.explosion["blank-entity"])
        local blank_triggerer_name = blank_triggerer.name .. "-" .. trav.name
        blank_triggerer.localised_name = locale.find_localised_name(entity)
        blank_triggerer.localised_description = locale.find_localised_description(entity)
        blank_triggerer.name = blank_triggerer_name
        blank_triggerer.created_effect = trav.trigger
        blank_triggerer.collision_box = entity.collision_box
        if blank_triggerer.collision_box == nil or blank_triggerer.collision_box[1][1] == 0 then
            blank_triggerer.collision_box = {{-0.4, -0.4}, {0.4, 0.4}}
        end
        data:extend({
            blank_triggerer
        })
        -- Also update combat robots to follow nearest player
        if entity.type == "combat-robot" then
            local trav_entity = data.raw[entity.type][entity.name]
            trav_entity.created_effect = {
                type = "direct",
                action_delivery = {
                    type = "instant",
                    target_effects = {
                        type = "script",
                        effect_id = "randomizer-follower-robot-created"
                    }
                }
            }
        end

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
        -- If that didn't work, try animation
        if place_item.icons == nil and place_item.icon == nil then
            if entity.animation ~= nil and entity.animation.filename ~= nil then
                place_item.icon = entity.animation.filename
                if entity.size ~= nil then
                    place_item.icon_size = entity.animation.size
                else
                    place_item.icon_size = math.min(entity.animation.width, entity.animation.height)
                end
            -- If that still didn't work, just use question mark icon
            else
                place_item.icon = "__core__/graphics/questionmark.png"
            end
        end
        -- Update localization
        place_item.localised_name = locale.find_localised_name(entity)
        -- Update subgroup, order and stack_size
        place_item.subgroup = entity.subgroup or "other"
        place_item.order = entity.order or "other"
        place_item.stack_size = 50

        -- Don't update minable (trigger entities shouldn't be minable)

        return true
    end

    place_item.place_result = trav.name
    local prot_with_icons
    if common.entity_to_place_item[trav.name] ~= nil then
        prot_with_icons = old_data_raw[common.entity_to_place_item[trav.name].type][common.entity_to_place_item[trav.name].name]
    else
        prot_with_icons = trav
    end
    -- Update icon
    if prot_with_icons.icons ~= nil then
        place_item.icons = table.deepcopy(prot_with_icons.icons)
        place_item.icon = nil
        place_item.icon_size = nil
    else
        place_item.icon = prot_with_icons.icon
        place_item.icon_size = prot_with_icons.icon_size or 64
    end
    -- Update localization
    place_item.localised_name = locale.find_localised_name(trav)
    place_item.localised_description = locale.find_localised_description(trav)
    -- Update subgroup, order, and stack_size
    -- Default to item placing trav, otherwise to trav
    if common.entity_to_place_item[trav.name] ~= nil then
        local old_trav_item = old_data_raw[common.entity_to_place_item[trav.name].type][common.entity_to_place_item[trav.name].name]
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
    local trav_entity = data.raw[trav.type][trav.name]
    if trav_entity.minable ~= nil then
        trav_entity.minable.result = place_item.name
        trav_entity.minable.count = 1
        trav_entity.minable.results = nil
    end

    return true
end

placeable.fix = function(entity)
    -- Remove next_upgrade property (hotfix for now)
    -- CRITICAL TODO: Fix properly!
    entity.next_upgrade = nil
end

return placeable