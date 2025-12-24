-- Common utilities for handling data.raw

local dutils = {}

dutils.prots = function(class)
    if data.raw[class] == nil then
        return {}
    else
        return data.raw[class]
    end
end

-- Takes a top-level prototype class name and the value of its name property in data.raw and returns its data.raw entry
dutils.get_prot = function(top_level_class, name)
    for class, _ in pairs(defines.prototypes[top_level_class]) do
        if data.raw[class] ~= nil then
            if data.raw[class][name] ~= nil then
                return data.raw[class][name] 
            end
        end
    end

    -- We couldn't find the prototype
    return nil
end

dutils.get_all_prots = function(top_level_class)
    local result = {}
    for class, _ in pairs(defines.prototypes[top_level_class]) do
        for name, prot in pairs(dutils.prots(class)) do
            result[name] = prot
        end
    end
    return result
end

dutils.tablize = function(val)
    if type(val) == "table" then
        return val
    else
        return {val}
    end
end

-- Extract ammo categories from attack_parameters
-- Returns nil if no categories, otherwise returns array of category names
dutils.get_ammo_categories = function(attack_parameters)
    if attack_parameters == nil then
        return nil
    end
    local cats = attack_parameters.ammo_categories
    if cats == nil and attack_parameters.ammo_category ~= nil then
        cats = {attack_parameters.ammo_category}
    end
    return cats
end

return dutils