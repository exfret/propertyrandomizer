-- Prototype metadata shared by exclusions and the runtime selector catalogue.
local catalog = {}

local function key(kind, name)
    return kind .. ": " .. name
end

catalog.build = function(data_raw, prototype_classes)
    local classes = {}
    for class, members in pairs(prototype_classes or {}) do
        for kind, _ in pairs(members) do
            classes[kind] = class
        end
    end
    local result = {}
    for kind, members in pairs(data_raw) do
        for name, prototype in pairs(members) do
            local subgroup = prototype.subgroup
            local group = prototype.group
            if subgroup ~= nil and data_raw["item-subgroup"] ~= nil and data_raw["item-subgroup"][subgroup] ~= nil then
                group = data_raw["item-subgroup"][subgroup].group
            end
            table.insert(result, {
                key = key(kind, name),
                kind = kind,
                class = classes[kind] or kind,
                name = name,
                group = group,
                subgroup = subgroup,
                caption = prototype.localised_name,
            })
        end
    end
    table.sort(result, function(a, b) return a.key < b.key end)
    local by_class = {}
    for _, entry in pairs(result) do
        by_class[key(entry.class, entry.name)] = entry
        by_class[entry.key] = entry
    end
    -- Group entities with their placing items when the entity declares no subgroup.
    for _, entry in pairs(result) do
        local prototype = data_raw[entry.kind][entry.name]
        local entity = prototype.place_result ~= nil and by_class[key("entity", prototype.place_result)] or nil
        if entity ~= nil and entity.subgroup == nil and entry.subgroup ~= nil then
            entity.subgroup = entry.subgroup
            entity.group = entry.group
        end
    end
    -- RecipePrototype.main_product documents subgroup inheritance from a singular/main product (installed 2.1 prototype API).
    for _, entry in pairs(result) do
        if entry.class == "recipe" and entry.subgroup == nil then
            local prototype = data_raw[entry.kind][entry.name]
            local products = prototype.results or {}
            local main = prototype.main_product
            if main ~= "" then
                for _, product in pairs(products) do
                    if product.name == main or main == nil and #products == 1 then
                        local material = by_class[key(product.type or "item", product.name)]
                        if material ~= nil then
                            entry.subgroup = material.subgroup
                            entry.group = material.group
                        end
                        break
                    end
                end
            end
        end
    end
    return result
end

catalog.matches = function(entry, selector)
    local kind, name = string.match(selector, "^([^/]+)/(.+)$")
    if kind == "prototype" then
        local class, prototype_name = string.match(name, "^([^/]+)/(.+)$")
        return (entry.class == class or entry.kind == class) and entry.name == prototype_name
    elseif kind == "type" then
        return entry.kind == name
    elseif kind == "group" then
        return entry.group == name
    elseif kind == "subgroup" then
        return entry.subgroup == name
    end
    return false
end

return catalog
