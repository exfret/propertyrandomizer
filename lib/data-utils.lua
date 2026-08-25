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

-- Check if an item prototype is stackable (not flagged as not-stackable)
dutils.is_stackable = function(item_prototype)
    -- Special case: armors with equipment grids are never stackable, even without not-stackable flag set
    if item_prototype.type == "armor" and item_prototype.equipment_grid ~= nil then
        return false
    end
    if item_prototype.type == "item-with-inventory" then
        return false
    end
    if item_prototype.flags ~= nil then
        for _, flag in pairs(item_prototype.flags) do
            if flag == "not-stackable" then
                return false
            end
        end
    end
    return true
end

dutils.boiler_input_amount = function(boiler)
    local input_fluid = data.raw.fluid[boiler.fluid_box.filter]
    local energy_to_heat = (boiler.target_temperature - input_fluid.default_temperature) * util.parse_energy(input_fluid.heat_capacity or "1kJ")
    return (60 * util.parse_energy(boiler.energy_consumption)) / energy_to_heat
end

dutils.boiler_output_amount = function(boiler)
    local input_fluid = data.raw.fluid[boiler.fluid_box.filter]
    local output_fluid = data.raw.fluid[boiler.output_fluid_box.filter]
    return dutils.boiler_input_amount(boiler) * util.parse_energy(input_fluid.heat_capacity or "1kJ") / util.parse_energy(output_fluid.heat_capacity or "1kJ")
end

return dutils