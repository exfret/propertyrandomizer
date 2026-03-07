local common = {}

-- Entities that really need to be on a grid or else they, like, freeze the game and stuff
common.grid_like_entity_classes = {
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
    ["transport-belt"] = true,
    ["underground-belt"] = true,
    ["splitter"] = true,
    ["lane-splitter"] = true,
    ["linked-belt"] = true,
    ["loader-1x1"] = true,
    ["loader"] = true,
}

-- TODO: Work in vehicles (item-with-entity-data)
common.valid_item_placeable_types = {
    ["item"] = true,
    ["ammo"] = true,
    ["gun"] = true,
    ["module"] = true,
    ["space-platform-starter-pack"] = true,
    ["tool"] = true,
    ["armor"] = true,
    ["repair-tool"] = true,
}

common.is_valid_placeable = function(item)
    if item.hidden then
        return false
    end

    if not common.valid_item_placeable_types[item.type] then
        return false
    end

    if item.plant_result ~= nil then
        return false
    end

    if item.place_as_tile ~= nil then
        return false
    end

    if item.flags ~= nil then
        for _, flag in pairs(item.flags) do
            if flag == "not-stackable" or flag == "spawnable" then
                return false
            end
        end
    end
    
    if item.equipment_grid ~= nil then
        return false
    end

    if item.parameter then
        return false
    end

    return true
end

-- Just find the first item that places an entity
common.entity_to_place_item = {}
common.populate_entity_to_place_item = function()
    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                if item.place_result ~= nil then
                    common.entity_to_place_item[item.place_result] = item
                end
            end
        end
    end
end

return common