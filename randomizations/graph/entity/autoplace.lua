local collision_mask_util = require("__core__/lualib/collision-mask-util")
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

-- Entities (and per planet, entity settings) that have received an autoplace from some slot, so they aren't cleared when their own old autoplace moves elsewhere
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

    -- Clear the slot's own autoplace before giving it to trav, so an entity assigned to its own slot keeps it
    -- The slot passed in is a copy of the old prototype, so the clearing has to happen on data.raw
    if not processed_entity_autoplace[slot.name] then
        data.raw[slot.type][slot.name].autoplace = nil
    end
    local trav_entity = data.raw[trav.type][trav.name]
    -- Copy so the force change below doesn't also change old_data_raw
    trav_entity.autoplace = table.deepcopy(old_data_raw[slot.type][slot.name].autoplace)
    -- Make player so it can be decon'd
    trav_entity.autoplace.force = "player"
    processed_entity_autoplace[trav.name] = true
    -- Update planet map_gen_settings the same way
    for _, planet in pairs(old_data_raw.planet) do
        -- TODO: Account for autoplace controls as well
        local map_gen_settings = planet.map_gen_settings
        if map_gen_settings ~= nil and map_gen_settings.autoplace_settings ~= nil and map_gen_settings.autoplace_settings.entity ~= nil then
            local entity_settings = map_gen_settings.autoplace_settings.entity.settings
            if entity_settings[slot.name] ~= nil then
                local data_raw_settings = data.raw.planet[planet.name].map_gen_settings.autoplace_settings.entity.settings
                processed_autoplaces[planet.name] = processed_autoplaces[planet.name] or {}
                if not processed_autoplaces[planet.name][slot.name] then
                    data_raw_settings[slot.name] = nil
                end
                data_raw_settings[trav.name] = table.deepcopy(entity_settings[slot.name])
                processed_autoplaces[planet.name][trav.name] = true
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
        common.set_mining_result(trav_entity, new_place_item.name)
        data:extend({new_place_item})
    end
end

return autoplace