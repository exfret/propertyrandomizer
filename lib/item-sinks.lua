-- Sinks: whether machines can use up an item on the way to research, judged on a prototype table (data.raw in the mod)
-- Spoil results need a sink, or else they pile up (see handlers/spoiling.lua); that's not the same as being useful elsewhere, like item reflection's useless items (user, 2026-09-29)
-- A path of steps has to end at a science pack, which labs use up, or at chemical fuel, which burners do; nothing else ends one
-- Placing an item can't be automated and launching it for products is hard to, and so is using up other fuel categories or items used directly (ammo, capsules, modules, ...)
-- Steps are recipes some machine can craft, hand-written recycling like scrap recycling included, and spoiling
-- The recycler's generated recycling isn't a step, so a spoil result only it takes still gets a fuel value
-- The whole game counts, wherever and whenever a step can be done

local categories = require("helper-tables/categories")
local dutils = require("lib/data-utils")
local lutils = require("lib/logic/logic-utils")
local recycling = require("lib/recycling")

local item_sinks = {}

-- The only fuel that ends a path, which is what a burner takes unless it names other categories (BurnerEnergySource::fuel_categories defaults to {"chemical"})
item_sinks.CHEMICAL_FUEL_CATEGORY = "chemical"
-- A recipe that names no categories is a crafting recipe (RecipePrototype::categories defaults to {"crafting"})
local DEFAULT_RECIPE_CATEGORY = "crafting"

local function item_key(name)
    return "item/" .. name
end

-- Recipe ingredients and products name their type, item or fluid
local function material_key(material)
    return material.type .. "/" .. material.name
end

-- What ending a path depends on besides the item, gathered once from raw: which items labs take, and whether some burner burns chemical fuel, with a burnt result inventory or at all
item_sinks.context = function(raw)
    local lab_inputs = {}
    for _, lab in pairs(raw.lab or {}) do
        for _, input in pairs(lab.inputs or {}) do
            lab_inputs[input] = true
        end
    end
    local chemical_burners = {
        any = false,
        with_burnt_inventory = false,
    }
    for entity_type, energy_props in pairs(categories.energy_sources_input) do
        for _, entity in pairs(raw[entity_type] or {}) do
            for _, energy_prop in pairs(dutils.tablize(energy_props)) do
                local energy_source = entity[energy_prop]
                if energy_source ~= nil and energy_source.type == "burner" then
                    local is_chemical = energy_source.fuel_categories == nil
                    for _, fuel_category in pairs(energy_source.fuel_categories or {}) do
                        if fuel_category == item_sinks.CHEMICAL_FUEL_CATEGORY then
                            is_chemical = true
                        end
                    end
                    if is_chemical then
                        chemical_burners.any = true
                        if (energy_source.burnt_inventory_size or 0) > 0 then
                            chemical_burners.with_burnt_inventory = true
                        end
                    end
                end
            end
        end
    end
    return {
        lab_inputs = lab_inputs,
        chemical_burners = chemical_burners,
    }
end

-- Whether some burner can burn the item as chemical fuel
-- A fuel with a burnt result needs a burner with a burnt result inventory, as logic models it (lib/lookup/2-simple/fuel.lua)
item_sinks.burns_chemical = function(context, item)
    if item.fuel_value == nil or util.parse_energy(item.fuel_value) <= 0 or not dutils.has_fuel_category(item, item_sinks.CHEMICAL_FUEL_CATEGORY) then
        return false
    end
    if item.burnt_result ~= nil and item.burnt_result ~= "" then
        return context.chemical_burners.with_burnt_inventory
    end
    return context.chemical_burners.any
end

-- Whether a path can end at the item: labs use it up as a science pack, or burners as chemical fuel
item_sinks.is_end_point = function(context, item)
    return context.lab_inputs[item.name] ~= nil or item_sinks.burns_chemical(context, item)
end

-- Whether a recipe product can come out: some amount, at a chance above 0 (ProductPrototypeBase::independent_probability and shared_probability)
local function can_come_out(product)
    local amount = product.amount or product.amount_max or 0
    if amount <= 0 and (product.extra_count_fraction or 0) <= 0 then
        return false
    end
    if product.independent_probability ~= nil and product.independent_probability <= 0 then
        return false
    end
    local shared = product.shared_probability
    return shared == nil or (shared.max or 0) > (shared.min or 0)
end

-- Whether some crafting machine (not the character, who crafts by hand) can craft the recipe: one of its categories, with fluid boxes for its fluids (lutils.is_compatible_rcat)
local function machine_craftable(machines, recipe)
    local fluids = lutils.find_recipe_fluids(recipe)
    local rcat = {
        cats = recipe.categories or { DEFAULT_RECIPE_CATEGORY },
        input = fluids.input,
        output = fluids.output,
    }
    for _, machine in pairs(machines) do
        if lutils.is_compatible_rcat(machine, rcat) then
            return true
        end
    end
    return false
end

-- Every material some path takes to an end point, as material key ("item/<name>" or "fluid/<name>") --> true
-- old_raw is the game before randomization, which tells the recycler's generated recipes apart (recycling.generated_names)
-- item_at (optional) gives the item prototype the game will have at an item position, for judging a game item randomization hasn't built yet (first pass has put identities at positions, but reflect hasn't renamed anything)
-- Recipes stay with positions, while ending a path and what an item spoils into move with its identity; by default each item is its own
item_sinks.sinkable = function(raw, old_raw, item_at)
    local function own_item(name)
        for item_class, _ in pairs(defines.prototypes.item) do
            local item = (raw[item_class] or {})[name]
            if item ~= nil then
                return item
            end
        end
        return nil
    end
    item_at = item_at or own_item
    local context = item_sinks.context(raw)

    -- Steps backwards: material key --> keys of the materials that can become it
    local made_from = {}
    local function add_step(from_key, to_key)
        made_from[to_key] = made_from[to_key] or {}
        made_from[to_key][from_key] = true
    end

    -- Recipes a player can get (enabled from the start or unlocked by a technology, and not blueprint parameters) that some machine can craft, except the recycler's generated recycling
    local is_generated = recycling.generated_names(raw, old_raw)
    local unlocked = {}
    for _, technology in pairs(raw.technology or {}) do
        for _, effect in pairs(technology.effects or {}) do
            if effect.type == "unlock-recipe" then
                unlocked[effect.recipe] = true
            end
        end
    end
    local machines = {}
    for machine_type, _ in pairs(categories.crafting_machines) do
        for _, machine in pairs(raw[machine_type] or {}) do
            if machine.crafting_categories ~= nil then
                table.insert(machines, machine)
            end
        end
    end
    for recipe_name, recipe in pairs(raw.recipe or {}) do
        local can_get = recipe.enabled ~= false or unlocked[recipe_name] ~= nil
        if is_generated[recipe_name] == nil and recipe.parameter ~= true and can_get and machine_craftable(machines, recipe) then
            for _, ingredient in pairs(recipe.ingredients or {}) do
                for _, product in pairs(recipe.results or {}) do
                    if (product.type == "item" or product.type == "fluid") and can_come_out(product) then
                        add_step(material_key(ingredient), material_key(product))
                    end
                end
            end
        end
    end

    -- Spoiling (ItemPrototype::spoil_result is only loaded with a spoil time above 0), and the end points
    local sinkable = {}
    local queue = {}
    for item_class, _ in pairs(defines.prototypes.item) do
        for position_name, _ in pairs(raw[item_class] or {}) do
            local item = item_at(position_name)
            if item ~= nil then
                if item.spoil_result ~= nil and (item.spoil_ticks or 0) > 0 then
                    add_step(item_key(position_name), item_key(item.spoil_result))
                end
                if item_sinks.is_end_point(context, item) then
                    sinkable[item_key(position_name)] = true
                    table.insert(queue, item_key(position_name))
                end
            end
        end
    end

    -- Everything with a path to an end point, found backwards from the end points
    local next_ind = 1
    while next_ind <= #queue do
        local to_key = queue[next_ind]
        next_ind = next_ind + 1
        for from_key, _ in pairs(made_from[to_key] or {}) do
            if sinkable[from_key] == nil then
                sinkable[from_key] = true
                table.insert(queue, from_key)
            end
        end
    end
    return sinkable
end

-- Whether the item at a position has a sink, given what sinkable returned
item_sinks.has_sink = function(sinkable, item_name)
    return sinkable[item_key(item_name)] ~= nil
end

return item_sinks
