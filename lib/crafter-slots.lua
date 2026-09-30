-- Slots crafting machines and labs need for what the randomized game gives them, raised once randomization is done
-- The logic lets any crafter of a recipe's category craft it (lib/logic/concrete.lua), so the machines are made to fit that, as lib/fluid-ports.lua does for fluid boxes
-- Trash slots: spoil results that don't fit into a machine's recipe slots go to its trash inventory (defines.inventory.crafter_trash in the 2.1 runtime docs; labs have lab_trash), and a machine without trash_inventory_size has none (probed headless on 2.1.20, 2026-09-30)
-- Spoiling and recipe-category randomization give machines recipes with items that spoil, so every one gets trash slots (user, 2026-09-30: they only hold spoil results, and more of them does no harm)
-- Result slots: a furnace has a fixed number of output slots (FurnacePrototype::result_inventory_size) and doesn't take a recipe with more item products than that, whatever its trash slots
-- The same probe found this: a one-output copy of the stone furnace refused a recipe with two item products at 0 to 5 trash slots and took it with two outputs, and took recipes whose items spoil with no trash slots
-- Recipes randomized into a furnace's category can have more products, like an expensive ingredient partly given back (randomizations/graph/unified/execute.lua); assembling machines size their outputs to the recipe

local categories = require("helper-tables/categories")
local furnace_selection = require("lib/furnace-selection")

local crafter_slots = {}

-- Item names to their prototypes, across item classes
local function items_by_name(raw)
    local items = {}
    for item_class, _ in pairs(defines.prototypes.item) do
        for name, item in pairs(raw[item_class] or {}) do
            items[name] = item
        end
    end
    return items
end

-- How many different items these items can spoil into, following spoil results of spoil results (ItemPrototype::spoil_result is only loaded with a spoil time above 0)
-- Each one could sit in the trash at once, since a stack spoils a bit at a time
local function num_spoil_results(items, item_names)
    local seen = {}
    local num = 0
    local stack = {}
    for _, name in pairs(item_names) do
        table.insert(stack, name)
    end
    while #stack > 0 do
        local item = items[table.remove(stack)]
        if item ~= nil and item.spoil_result ~= nil and (item.spoil_ticks or 0) > 0 and not seen[item.spoil_result] then
            seen[item.spoil_result] = true
            num = num + 1
            table.insert(stack, item.spoil_result)
        end
    end
    return num
end

-- The item ingredients and products of a recipe
local function recipe_items(recipe)
    local names = {}
    for _, prop in pairs({
        "ingredients",
        "results",
    }) do
        for _, material in pairs(recipe[prop] or {}) do
            if material.type == "item" then
                table.insert(names, material.name)
            end
        end
    end
    return names
end

-- How many item products a recipe has, each entry counted (a recipe may list the same product twice, per RecipePrototype::results)
crafter_slots.num_item_products = function(recipe)
    local num = 0
    for _, result in pairs(recipe.results or {}) do
        if result.type == "item" then
            num = num + 1
        end
    end
    return num
end

-- How many item ingredients a recipe has
local function num_item_ingredients(recipe)
    local num = 0
    for _, ing in pairs(recipe.ingredients or {}) do
        if ing.type == "item" then
            num = num + 1
        end
    end
    return num
end

-- Whether a crafter's item slots take a recipe
-- A furnace has fixed input and output slots (FurnacePrototype::source_inventory_size, at most 1, and result_inventory_size), and an assembling machine caps item ingredients (AssemblingMachinePrototype::ingredient_count: a recipe with more is unavailable there, per the 2.1 docs) and item products (max_item_product_count), both 65535 by default
crafter_slots.fits_items = function(crafter, recipe)
    local num_ingredients = num_item_ingredients(recipe)
    local num_products = crafter_slots.num_item_products(recipe)
    if crafter.source_inventory_size ~= nil and num_ingredients > crafter.source_inventory_size then
        return false
    end
    if crafter.ingredient_count ~= nil and num_ingredients > crafter.ingredient_count then
        return false
    end
    if crafter.result_inventory_size ~= nil and num_products > crafter.result_inventory_size then
        return false
    end
    if crafter.max_item_product_count ~= nil and num_products > crafter.max_item_product_count then
        return false
    end
    return true
end

-- Slots each machine needs, as trash[prototype type][name] and results[prototype type][name]
-- Trash: one per spoil result the items of a recipe it crafts (a lab's inputs) can have, the most over its recipes, and at least one
-- Results: for a machine with a fixed number of output slots (a furnace), the most item products of a recipe in its categories
-- It reads raw (optional) as the prototype table, data.raw by default.
crafter_slots.needed = function(raw)
    raw = raw or data.raw
    local items = items_by_name(raw)
    -- The most spoil results and item products of a recipe in each crafting category
    local most_spoils = {}
    local most_products = {}
    for _, recipe in pairs(raw.recipe or {}) do
        local num_spoils = num_spoil_results(items, recipe_items(recipe))
        local num_products = crafter_slots.num_item_products(recipe)
        for _, cat in pairs(furnace_selection.recipe_categories(recipe)) do
            most_spoils[cat] = math.max(most_spoils[cat] or 0, num_spoils)
            most_products[cat] = math.max(most_products[cat] or 0, num_products)
        end
    end
    local needed = {
        trash = {},
        results = {},
    }
    for machine_class, _ in pairs(categories.crafting_machines) do
        for name, machine in pairs(raw[machine_class] or {}) do
            local num_trash = 1
            local num_results = 0
            for _, cat in pairs(machine.crafting_categories or {}) do
                num_trash = math.max(num_trash, most_spoils[cat] or 0)
                num_results = math.max(num_results, most_products[cat] or 0)
            end
            needed.trash[machine_class] = needed.trash[machine_class] or {}
            needed.trash[machine_class][name] = num_trash
            if machine.result_inventory_size ~= nil then
                needed.results[machine_class] = needed.results[machine_class] or {}
                needed.results[machine_class][name] = num_results
            end
        end
    end
    for name, lab in pairs(raw.lab or {}) do
        needed.trash.lab = needed.trash.lab or {}
        needed.trash.lab[name] = math.max(1, num_spoil_results(items, lab.inputs or {}))
    end
    return needed
end

-- Raises each machine's trash_inventory_size, and each furnace's result_inventory_size, to what it needs, keeping any larger size it has
-- Returns how many machines got more trash slots and how many furnaces more result slots
-- Runs after every randomization and after old versions are added (randomizations.post_fixes), since spoiling and category randomization change what needs it
crafter_slots.apply = function(raw)
    raw = raw or data.raw
    local needed = crafter_slots.needed(raw)
    local num_trash_raised = 0
    for machine_class, by_name in pairs(needed.trash) do
        for name, num in pairs(by_name) do
            local machine = raw[machine_class][name]
            if (machine.trash_inventory_size or 0) < num then
                machine.trash_inventory_size = num
                num_trash_raised = num_trash_raised + 1
            end
        end
    end
    local num_results_raised = 0
    for machine_class, by_name in pairs(needed.results) do
        for name, num in pairs(by_name) do
            local machine = raw[machine_class][name]
            if machine.result_inventory_size < num then
                machine.result_inventory_size = num
                num_results_raised = num_results_raised + 1
            end
        end
    end
    return num_trash_raised, num_results_raised
end

return crafter_slots
