local locale_utils = {}

function locale_utils.find_localised_name(prototype)
    -- Check if this inherits from PrototypeBase
    -- Changing non-Base things seems spooky
    local is_base_prototype = false
    for _, lookup in pairs(defines.prototypes) do
        if lookup[prototype.type] ~= nil then 
            is_base_prototype = true
        end
    end
    if not is_base_prototype or prototype.name == "default" then
        return
    end

    if defines.prototypes.item[prototype.type] then
        return locale_utils.find_localised_name_item(prototype)
    elseif prototype.type == "recipe" then
        return locale_utils.find_localised_name_recipe(prototype)
    elseif prototype.type == "technology" then
        return locale_utils.find_localised_name_technology(prototype)
    else
        if prototype.localised_name ~= nil then
            return prototype.localised_name
        else
            local base_class
            -- Find base class
            for possible_base_class, lookup in pairs(defines.prototypes) do
                if lookup[prototype.type] then
                    base_class = possible_base_class
                end
            end
            return {base_class .. "-name." .. prototype.name}
        end
    end
end

function locale_utils.find_localised_name_item(item)
    if item.localised_name ~= nil then
        return item.localised_name
    end

    local type_name = "item"
    local prototype
    if item.place_result ~= nil then
        type_name = "entity"
        
        for entity_class, _ in pairs(defines.prototypes.entity) do
            if data.raw[entity_class] ~= nil then
                if data.raw[entity_class][item.place_result] ~= nil then
                    prototype = data.raw[entity_class][item.place_result]
                end
            end
        end
    elseif item.place_as_equipment_result ~= nil then
        type_name = "equipment"

        for equipment_class, _ in pairs(defines.prototypes.equipment) do
            if data.raw[equipment_class] ~= nil then
                if data.raw[equipment_class][item.place_as_equipment_result] ~= nil then
                    prototype = data.raw[equipment_class][item.place_as_equipment_result]
                end
            end
        end
    elseif item.place_as_tile ~= nil then
        -- Need to not change type_name if this is a tiles with variations
        local tile_prototype = data.raw.tile[item.place_as_tile.result]
        if tile_prototype ~= nil and tile_prototype.localised_name ~= nil then
            type_name = "tile"
            prototype = tile_prototype
        end
    end

    if prototype ~= nil and prototype.localised_name ~= nil then
        return prototype.localised_name
    else
        return {type_name .. "-name." .. item.name}
    end
end

function locale_utils.find_localised_name_recipe(recipe)
    if recipe.localised_name ~= nil then
        return recipe.localised_name
    end

    if recipe.main_product == "" then
        return {"recipe-name." .. recipe.name}
    elseif recipe.main_product ~= nil and recipe.main_product == recipe.name then
        local prototype

        for item_class, _ in pairs(defines.prototypes.item) do
            if data.raw[item_class] ~= nil then
                if data.raw[item_class][recipe.main_product] ~= nil then
                    prototype = data.raw[item_class][recipe.main_product]
                end
            end
        end

        return locale_utils.find_localised_name_item(prototype)
    elseif recipe.results ~= nil and #recipe.results == 1 and recipe.results[1].name == recipe.name then
        local prototype
        
        if recipe.results[1].type == "item" then
            for item_class, _ in pairs(defines.prototypes.item) do
                if data.raw[item_class] ~= nil then
                    if data.raw[item_class][recipe.results[1].name] ~= nil then
                        prototype = data.raw[item_class][recipe.results[1].name]
                    end
                end
            end
        elseif recipe.results[1].type == "fluid" then
            prototype = data.raw.fluid[recipe.results[1].name]
        end
        
        return locale_utils.find_localised_name(prototype)
    else
        return {"recipe-name." .. recipe.name}
    end
end

function locale_utils.find_localised_name_technology(technology)
    if technology.localised_name ~= nil then
        return technology.localised_name
    end

    -- I'm sorry, this code is awful, I know there are better ways to do it, but this is what I'm familiar with
    local is_digit = {
        ["0"] = true,
        ["1"] = true,
        ["2"] = true,
        ["3"] = true,
        ["4"] = true,
        ["5"] = true,
        ["6"] = true,
        ["7"] = true,
        ["8"] = true,
        ["9"] = true,
    }
    local ending_num = ""
    for i = string.len(technology.name), 1, -1 do
        if not is_digit[string.sub(technology.name, i, i)] then
            if string.sub(technology.name, i, i) ~= "-" then
                ending_num = nil
            end
            break
        else
            ending_num = string.sub(technology.name, i, i) .. ending_num
        end
    end
    if ending_num ~= nil and string.len(ending_num) > 0 then
        return {"technology-name." .. string.sub(technology.name, 1, -(string.len(ending_num) + 1))}
    end

    return {"technology-name." .. technology.name}
end

function locale_utils.capitalize(str)
    -- This code is awful I'm sorry
    capitals = {
        a = "A",
        b = "B",
        c = "C",
        d = "D",
        e = "E",
        f = "F",
        g = "G",
        h = "H",
        i = "I",
        j = "J",
        k = "K",
        l = "L",
        m = "M",
        n = "N",
        o = "O",
        p = "P",
        q = "Q",
        r = "R",
        s = "S",
        t = "T",
        u = "U",
        v = "V",
        w = "W",
        x = "X",
        y = "Y",
        z = "Z",
    }

    local first_char = string.sub(str, 1, 1)

    if capitals[first_char] then
        return capitals[first_char] .. string.sub(str, 2, -1)
    end
end

return locale_utils