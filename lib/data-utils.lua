-- Common utilities for handling data.raw

local constants = require("helper-tables/constants")

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

-- Whether an item lasts long enough to be sent to another room (constants.spoil_trip_ticks), which logic needs before it lets the item be delivered
-- Only spoil times above 0 make an item spoil (the game's default is 0)
-- Randomizations never make an item that lasted a trip stop lasting it (like numerical spoil time randomization), so the delivery edges logic built before them stay true
-- Making an item last a trip only adds routes, so a randomization can lengthen a spoil time to let something be delivered
dutils.survives_trip = function(item)
    local spoil_ticks = item.spoil_ticks or 0
    return spoil_ticks <= 0 or spoil_ticks >= constants.spoil_trip_ticks
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
-- is_useless (optional) says which identities are useless, for keys other than item names (item_fluid.is_useless_material takes item and fluid material keys, see lib/item-fluid.lua)
-- Returns the position where reflection puts identity (assigned to position), or nil if reflection leaves it alone
dutils.reflected_item_position = function(identity_at, position, identity, is_useless)
    is_useless = is_useless or function(name)
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

-- The assignment reflection realizes, as item position name --> identity name (is_useless as for reflected_item_position)
-- It's a permutation that agrees with identity_at on every non-useless identity, and realizing it again changes nothing, so first pass can gate and model this one instead
dutils.realized_item_assignment = function(identity_at, is_useless)
    local realized = {}
    for position, identity in pairs(identity_at) do
        local reflected = dutils.reflected_item_position(identity_at, position, identity, is_useless)
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

-- What mining a prototype gives, as a list of {type, name} (MinableProperties: result is only read without results)
dutils.minable_results = function(prot)
    local results = {}
    if prot.minable ~= nil then
        if prot.minable.results ~= nil then
            for _, result in pairs(prot.minable.results) do
                if result.type == "item" or result.type == "fluid" then
                    table.insert(results, {
                        type = result.type,
                        name = result.name,
                    })
                end
            end
        elseif prot.minable.result ~= nil then
            table.insert(results, {
                type = "item",
                name = prot.minable.result,
            })
        end
    end
    return results
end

-- Materials straight from the map: mined from a resource entity or an asteroid chunk (ores, crude oil, chunks, ...) or pumped from a tile (water, lava, ...)
-- As {type, name} keyed by "type-name"
dutils.resource_materials = function()
    local materials = {}
    for _, class in pairs({"resource", "asteroid-chunk"}) do
        for _, prot in pairs(dutils.prots(class)) do
            for _, result in pairs(dutils.minable_results(prot)) do
                materials[result.type .. "-" .. result.name] = result
            end
        end
    end
    for _, tile in pairs(dutils.prots("tile")) do
        if tile.fluid ~= nil then
            materials["fluid-" .. tile.fluid] = { type = "fluid", name = tile.fluid }
        end
    end
    return materials
end

local function is_recycling_recipe(recipe)
    for _, cat in pairs(recipe.categories or { recipe.category or "crafting" }) do
        if cat == "recycling" then
            return true
        end
    end
    return false
end

-- Round trips: conversions that another conversion undoes, like filling and emptying a barrel, or cooling fluoroketone that a fusion reactor and generator heat back up
-- Changing one side's ingredients breaks the loop (the returned material has no sink, or comes from nowhere)
-- Returns { recipes = recipe name --> true, materials = "type-name" --> {type, name} }, where materials are those carried around single-material loops
-- Recycling is left out, since it inverts nearly everything by design
dutils.round_trips = function()
    local recipes = {}
    local materials = {}

    -- Recipes that are exact inverses of each other, amounts included
    local function signature(list)
        local parts = {}
        for _, entry in pairs(list or {}) do
            table.insert(parts, entry.type .. "-" .. entry.name .. "=" .. tostring(entry.amount))
        end
        table.sort(parts)
        return table.concat(parts, ",")
    end
    local by_ingredients = {}
    for _, recipe in pairs(data.raw.recipe) do
        if not is_recycling_recipe(recipe) and recipe.ingredients ~= nil and #recipe.ingredients > 0 then
            local sig = signature(recipe.ingredients)
            by_ingredients[sig] = by_ingredients[sig] or {}
            table.insert(by_ingredients[sig], recipe.name)
        end
    end
    for _, recipe in pairs(data.raw.recipe) do
        if not is_recycling_recipe(recipe) and recipe.results ~= nil and #recipe.results > 0 and recipe.ingredients ~= nil then
            for _, other_name in pairs(by_ingredients[signature(recipe.results)] or {}) do
                if other_name ~= recipe.name and signature(data.raw.recipe[other_name].results) == signature(recipe.ingredients) then
                    recipes[recipe.name] = true
                    recipes[other_name] = true
                end
            end
        end
    end

    -- Single-material conversions: X --> Y where X is the only thing consumed and Y the only thing made (catalysts, on both sides, don't count)
    -- edges[X][Y] = list of recipe names (entity conversions have none)
    local edges = {}
    local function add_edge(from, to, recipe_name)
        edges[from] = edges[from] or {}
        edges[from][to] = edges[from][to] or {}
        if recipe_name ~= nil then
            table.insert(edges[from][to], recipe_name)
        end
    end
    for _, recipe in pairs(data.raw.recipe) do
        if not is_recycling_recipe(recipe) then
            local ins = {}
            local outs = {}
            for _, ing in pairs(recipe.ingredients or {}) do
                ins[ing.type .. "-" .. ing.name] = true
            end
            for _, result in pairs(recipe.results or {}) do
                if result.type == "item" or result.type == "fluid" then
                    outs[result.type .. "-" .. result.name] = true
                end
            end
            local only_in, only_out
            local num_in, num_out = 0, 0
            for mat, _ in pairs(ins) do
                if not outs[mat] then
                    only_in = mat
                    num_in = num_in + 1
                end
            end
            for mat, _ in pairs(outs) do
                if not ins[mat] then
                    only_out = mat
                    num_out = num_out + 1
                end
            end
            if num_in == 1 and num_out == 1 then
                add_edge(only_in, only_out, recipe.name)
            end
        end
    end
    -- Entities that take in one filtered fluid and put out another (fluid boxes are found by their production_type, directly or in a list)
    for class, _ in pairs(defines.prototypes.entity) do
        for _, entity in pairs(dutils.prots(class)) do
            local ins = {}
            local outs = {}
            local function visit_box(box)
                if type(box) == "table" and box.production_type ~= nil and box.filter ~= nil then
                    if box.production_type == "input" or box.production_type == "input-output" then
                        ins["fluid-" .. box.filter] = true
                    end
                    if box.production_type == "output" or box.production_type == "input-output" then
                        outs["fluid-" .. box.filter] = true
                    end
                end
            end
            for _, value in pairs(entity) do
                if type(value) == "table" then
                    visit_box(value)
                    if value.production_type == nil then
                        for _, sub in pairs(value) do
                            visit_box(sub)
                        end
                    end
                end
            end
            local num_in, num_out = 0, 0
            local only_in, only_out
            for mat, _ in pairs(ins) do
                if not outs[mat] then
                    num_in = num_in + 1
                    only_in = mat
                end
            end
            for mat, _ in pairs(outs) do
                if not ins[mat] then
                    num_out = num_out + 1
                    only_out = mat
                end
            end
            if num_in == 1 and num_out == 1 then
                add_edge(only_in, only_out, nil)
            end
        end
    end

    local function as_material(mat_key)
        if mat_key:sub(1, 5) == "item-" then
            return { type = "item", name = mat_key:sub(6) }
        end
        return { type = "fluid", name = mat_key:sub(7) }
    end

    -- A conversion is on a loop when its output can be converted back to its input
    local function reaches(from, target)
        local seen = { [from] = true }
        local stack = { from }
        while #stack > 0 do
            local mat = table.remove(stack)
            if mat == target then
                return true
            end
            for next_mat, _ in pairs(edges[mat] or {}) do
                if not seen[next_mat] then
                    seen[next_mat] = true
                    table.insert(stack, next_mat)
                end
            end
        end
        return false
    end
    for from, tos in pairs(edges) do
        for to, recipe_names in pairs(tos) do
            if reaches(to, from) then
                materials[from] = as_material(from)
                materials[to] = as_material(to)
                for _, recipe_name in pairs(recipe_names) do
                    recipes[recipe_name] = true
                end
            end
        end
    end

    return { recipes = recipes, materials = materials }
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

-- Item reflection makes whatever replaces coal (raw coal with py) a fuel of this category (see handlers/item.lua), so first pass treats that fuel as part of coal's position
-- TODO: Do this for fuel ores in general, not by name
dutils.REPLACEMENT_FUEL_CATEGORY = "chemical"
dutils.replacement_gets_fuel = function(item_name)
    if mods["pypostprocessing"] then
        return item_name == "raw-coal"
    end
    return item_name == "coal"
end

-- Makes an item a fuel of that category, as item reflection does to whatever replaces coal; returns whether it wasn't one before
dutils.give_replacement_fuel = function(item)
    local fcat = dutils.REPLACEMENT_FUEL_CATEGORY
    local was_fuel = dutils.has_fuel_category(item, fcat)
    if #dutils.fuel_categories(item) == 0 then
        item.fuel_categories = { fcat }
        item.fuel_value = "4MJ"
    elseif not was_fuel then
        -- An item can have several fuel categories, so it keeps its own (e.g. fusion power cells'), which logic relies on
        table.insert(item.fuel_categories, fcat)
    end
    -- Large fuel values are fine, but a weak fuel (like spoilage) gets enough energy to be worth burning
    if item.fuel_value == nil or util.parse_energy(item.fuel_value) < 2000000 then
        item.fuel_value = "2MJ"
    end
    return not was_fuel
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