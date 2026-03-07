local collision_mask_util
if not offline then
    collision_mask_util = require("__core__/lualib/collision-mask-util")
else
    collision_mask_util = require("offline/lualib/collision-mask-util")
end
local locale = require("lib/locale")
local common = require("randomizations/graph/entity/common")

local autoplace = {}

-- TODO: What to do about vulcanus chimneys being so awful to mine?
-- TODO: Add back ability to build etc. turrets; right now they're too strong against their biter brethren and are needed for defending the nests
local autoplace_blacklist_types = {
    ["resource"] = true,
    ["unit-spawner"] = true,
    ["plant"] = true, -- Includes yumako/jellynut
    ["turret"] = true,
}

autoplace.claim = function(entity)
    if entity.autoplace == nil then
        return false
    end
    if autoplace_blacklist_types[entity.type] then
        return false
    end

    return true
end

autoplace.validate = function(slot, trav)
    if trav.type == "dummy" then
        return false
    end
    if trav.type == "unit" or trav.type == "capsule_trigger" then
        return false
    end

    return true
end

-- Used to make sure we only zero out an autoplace once
local processed_autoplaces = {}
local processed_entity_autoplace = {}
autoplace.reflect = function(slot, trav)
    -- Reject dummy, explosion, and unit
    -- Dummy could be fine, but I'd want dummy autoplaces too, and those would take some work
    if trav.type == "dummy" then
        error("Dummy not allowed for autoplace")
    end
    if trav.type == "unit" or trav.type == "capsule_trigger" then
        error("Disallowed autoplace type")
    end

    local trav_entity = data.raw[trav.type][trav.name]
    trav_entity.autoplace = old_data_raw[slot.type][slot.name].autoplace
    -- Make player so it can be decon'd
    trav_entity.autoplace.force = "player"
    if not processed_entity_autoplace[slot.name] then
        slot.autoplace = nil
    end
    -- Make sure we don't set trav's autoplace to nil later
    processed_entity_autoplace[trav.name] = true
    -- Update planet map_gen_settings
    for _, planet in pairs(old_data_raw.planet) do
        local map_gen_settings = planet.map_gen_settings
        if map_gen_settings ~= nil then
            -- TODO: Account for autoplace controls as well
            local autoplace_settings = map_gen_settings.autoplace_settings
            if autoplace_settings ~= nil then
                local entity_settings = autoplace_settings.entity.settings
                if entity_settings[slot.name] ~= nil then
                    local data_raw_settings = data.raw.planet[planet.name].map_gen_settings.autoplace_settings.entity.settings
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
    trav_entity.localised_name = {"", locale.find_localised_name(trav_entity), " (Naturally Ocurring)"}
    -- Change collision masks
    -- Useful so things can still act like fish
    trav_entity.collision_mask = slot.collision_mask or collision_mask_util.get_default_mask(slot.type)

    -- Change minable result to a new item in case the old item is overriden with the placeable handler
    if common.entity_to_place_item[trav.name] ~= nil then
        local old_item_to_place = old_data_raw[common.entity_to_place_item[trav.name].type][common.entity_to_place_item[trav.name].name]
        local new_place_item = table.deepcopy(old_item_to_place)
        new_place_item.name = new_place_item.name .. "-exfret-autoplace"
        new_place_item.localised_name = locale.find_localised_name(old_item_to_place)
        new_place_item.localised_description = locale.find_localised_description(old_item_to_place)
        trav_entity.minable.results = nil
        trav_entity.minable.result = new_place_item.name
        trav_entity.minable.count = 1
        data:extend({new_place_item})
    end
end

return autoplace