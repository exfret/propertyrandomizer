-- File for any last-minute fixes in the randomization process that may be needed

local locale_utils = require("lib/locale")

randomizations.fixes = function()
    -- Fix electric pole supply area to be at least as large as distribution range
    for _, electric_pole in pairs(data.raw["electric-pole"]) do
        if electric_pole.maximum_wire_distance == nil then
            electric_pole.maximum_wire_distance = 0
        end

        electric_pole.maximum_wire_distance = math.min(64, math.max(electric_pole.maximum_wire_distance, 2 * electric_pole.supply_area_distance))
    end

    -- Add the placeable entity/etc.'s localised description to every item so stats show up all at once
    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                if item.localised_description ~= nil then
                    if item.place_result ~= nil then
                        -- Get the entity
                        local entity
                        for entity_class, _ in pairs(defines.prototypes.entity) do
                            if data.raw[entity_class] ~= nil then
                                if data.raw[entity_class][item.place_result] ~= nil then
                                    entity = data.raw[entity_class][item.place_result]
                                end
                            end
                        end
                        local desc = locale_utils.find_localised_description(entity, {with_newline = true})
                        item.localised_description = {"", desc, item.localised_description}
                    end
                    if item.place_as_equipment_result ~= nil then
                        -- Get the equipment
                        local equipment
                        for equipment_class, _ in pairs(defines.prototypes.equipment) do
                            if data.raw[equipment_class] ~= nil then
                                if data.raw[equipment_class][item.place_as_equipment_result] ~= nil then
                                    equipment = data.raw[equipment_class][item.place_as_equipment_result]
                                end
                            end
                        end
                        local desc = locale_utils.find_localised_description(equipment, {with_newline = true})
                        item.localised_description = {"", desc, item.localised_description}
                    end
                    if item.place_as_tile ~= nil then
                        local tile = data.raw.tile[item.place_as_tile.result]
                        local desc = locale_utils.find_localised_description(tile, {with_newline = true})
                        item.localised_description = {"", desc, item.localised_description}
                    end
                end
            end
        end
    end

    -- Remove duplicate ingredients (needed for watch the world burn mode)

    for _, recipe in pairs(data.raw.recipe) do
        if recipe.ingredients ~= nil then
            local item_ing_seen = {}
            local new_ings = {}
            for _, ing in pairs(recipe.ingredients) do
                if ing.type ~= "item" or not item_ing_seen[ing.name] then
                    item_ing_seen[ing.name] = true
                    table.insert(new_ings, ing)
                else
                    for _, new_ing in pairs(new_ings) do
                        if new_ing.type == "item" and new_ing.name == ing.name then
                            new_ing.amount = new_ing.amount + ing.amount
                        end
                    end
                end
            end
            recipe.ingredients = new_ings
        end
    end
end