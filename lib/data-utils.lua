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
    -- If no filter is set, but input fluid box filter is set, then we're getting the input fluid out anyways
    local output_fluid = data.raw.fluid[boiler.output_fluid_box.filter or boiler.fluid_box.filter]
    return dutils.boiler_input_amount(boiler) * util.parse_energy(input_fluid.heat_capacity or "1kJ") / util.parse_energy(output_fluid.heat_capacity or "1kJ")
end

local is_spoil_or_burnt_result = {}
dutils.recalculate_spoil_burnt_results = function()
    for class, _ in pairs(defines.prototypes.item) do
        for _, item in pairs(data.raw[class] or {}) do
            if item.spoil_result ~= nil then
                is_spoil_or_burnt_result[item.spoil_result] = true
            end
            if item.burnt_result ~= nil then
                is_spoil_or_burnt_result[item.burnt_result] = true
            end
        end
    end
end

-- Whether mining this entity or tile gives items under their own names, whatever item first pass put in their positions
-- Item reflection leaves the mining results of player creations alone (so you get back the buildings you place down) and never changes tiles', so first pass models those results as part of the items' identities
dutils.mining_keeps_item_names = function(prot)
    if prot.type == "tile" then
        return true
    end
    for _, flag in pairs(prot.flags or {}) do
        if flag == "placeable-player" or flag == "player-creation" then
            return true
        end
    end
    return false
end

-- Item reflection's placement rule, shared with first pass so that first pass models the game reflection builds
-- identity_at: item position name --> name of the item identity assigned there (a permutation of the same names)
-- Reflection doesn't swap two useless items (see is_useless_item), since that would only change names
-- A useless identity instead goes to the first position along its cycle whose assigned identity is useless, so non-useless identities always land where they were assigned
-- Returns the position where reflection puts identity (assigned to position), or nil if reflection leaves it alone
dutils.reflected_item_position = function(identity_at, position, identity)
    local function is_useless(name)
        return dutils.is_useless_item(dutils.get_prot("item", name))
    end
    if is_useless(identity_at[identity]) and is_useless(identity) then
        return nil
    end
    if not is_useless(identity) then
        return position
    end
    local curr = identity_at[identity]
    while not is_useless(identity_at[curr]) do
        curr = identity_at[curr]
    end
    return curr
end

-- The assignment reflection realizes, as item position name --> identity name
-- It's a permutation that agrees with identity_at on every non-useless identity, and realizing it again changes nothing, so first pass can gate and model this one instead
dutils.realized_item_assignment = function(identity_at)
    local realized = {}
    for position, identity in pairs(identity_at) do
        local reflected = dutils.reflected_item_position(identity_at, position, identity)
        if reflected ~= nil then
            realized[reflected] = identity
        end
    end
    -- Positions reflection doesn't rename keep their own items
    for position, _ in pairs(identity_at) do
        if realized[position] == nil then
            realized[position] = position
        end
    end
    return realized
end

-- The results entry a recipe takes its name, icon and subgroup from, or nil if it uses its own (see RecipePrototype::main_product)
-- That's the product main_product names, or the only product when main_product is nil; with several products and no main_product, or main_product set to "", there's none
dutils.recipe_main_product = function(recipe)
    local results = recipe.results or {}
    if recipe.main_product == nil then
        if #results == 1 then
            return results[1]
        end
        return nil
    end
    for _, result in pairs(results) do
        if result.name == recipe.main_product then
            return result
        end
    end
    return nil
end

-- Science packs: every item some lab accepts, as item name --> true (not anything with "science-pack" in its name)
dutils.lab_inputs = function()
    local lab_inputs = {}
    for _, lab in pairs(data.raw.lab or {}) do
        for _, input in pairs(lab.inputs or {}) do
            lab_inputs[input] = true
        end
    end
    return lab_inputs
end

-- An item's fuel categories as a list (empty if it isn't a fuel); since 2.1.20 an item can have several, and a burner takes it if they share any
dutils.fuel_categories = function(item)
    return item.fuel_categories or {}
end

dutils.has_fuel_category = function(item, fcat)
    for _, item_fcat in pairs(dutils.fuel_categories(item)) do
        if item_fcat == fcat then
            return true
        end
    end
    return false
end

dutils.is_useless_item = function(item)
    if item.type ~= "item" then
        return false
    end
    if item.fuel_value ~= nil and util.parse_energy(item.fuel_value) ~= 0 then
        return false
    end
    if item.place_result ~= nil or item.plant_result ~= nil or item.place_as_tile ~= nil or item.place_as_equipment_result ~= nil then
        return false
    end
    if item.spoil_result ~= nil then
        return false
    end
    if is_spoil_or_burnt_result[item.name] then
        return false
    end
    local is_science_pack
    for _, lab in pairs(data.raw.lab) do
        for _, input in pairs(lab.inputs) do
            if input == item.name then
                return false
            end
        end
    end
    if item.rocket_launch_products ~= nil then
        return false
    end
    return true
end

return dutils