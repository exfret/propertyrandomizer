-- Plain-Lua regression tests for lib/crafter-slots.lua (not loaded by the mod)
-- Run from the mod root: lua lib/test-crafter-slots.lua
-- Every crafting machine and lab gets trash slots for spoil results (user, 2026-09-30), and machines with fixed output slots (furnaces) get one for each item product of their recipes, so every crafter of a recipe's category can craft it as the logic has it

-- Stand-ins for the Factorio environment
defines = {
    prototypes = {
        item = {
            item = 0,
        },
    },
}

local categories = require("helper-tables/categories")
local crafter_slots = require("lib/crafter-slots")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

-- A crafting machine type, from the mod's own table; any works, since crafter_slots finds machines with fixed output slots by their result_inventory_size
local machine_types = {}
for machine_type, _ in pairs(categories.crafting_machines) do
    table.insert(machine_types, machine_type)
end
table.sort(machine_types)
local machine_type = machine_types[1]

local CATEGORY = "test-category"
local OTHER_CATEGORY = "test-other-category"

-- The prototype tables crafter_slots reads: every item class and crafting machine class, recipes and labs
local function new_raw()
    local raw = {}
    for item_class, _ in pairs(defines.prototypes.item) do
        raw[item_class] = {}
    end
    for machine_class, _ in pairs(categories.crafting_machines) do
        raw[machine_class] = {}
    end
    raw.recipe = {}
    raw.lab = {}
    return raw
end

local function add_item(raw, name, spoil_result, spoil_ticks)
    raw.item[name] = {
        type = "item",
        name = name,
        spoil_result = spoil_result,
        spoil_ticks = spoil_ticks or (spoil_result ~= nil and 100 or nil),
    }
end

local function item(name)
    return {
        type = "item",
        name = name,
        amount = 1,
    }
end

local function fluid(name)
    return {
        type = "fluid",
        name = name,
        amount = 1,
    }
end

-- Ingredients and results are item names, or materials made by item() and fluid()
local function add_recipe(raw, name, cats, ingredients, results)
    local function materials(entries)
        local list = {}
        for _, entry in pairs(entries) do
            if type(entry) == "string" then
                entry = item(entry)
            end
            table.insert(list, entry)
        end
        return list
    end
    raw.recipe[name] = {
        type = "recipe",
        name = name,
        categories = cats,
        ingredients = materials(ingredients),
        results = materials(results),
    }
end

-- A crafting machine, with fixed output slots if results is given
local function add_machine(raw, name, cats, trash, results)
    raw[machine_type][name] = {
        type = machine_type,
        name = name,
        crafting_categories = cats,
        trash_inventory_size = trash,
        result_inventory_size = results,
    }
end

local function add_lab(raw, name, inputs)
    raw.lab[name] = {
        type = "lab",
        name = name,
        inputs = inputs,
    }
end

test("a machine whose recipes' items don't spoil still gets a trash slot", function()
    local raw = new_raw()
    add_item(raw, "ore")
    add_item(raw, "plate")
    add_recipe(raw, "plate", { CATEGORY }, { "ore" }, { "plate" })
    add_machine(raw, "machine", { CATEGORY })
    crafter_slots.apply(raw)
    assert(raw[machine_type].machine.trash_inventory_size == 1)
end)

test("a machine gets a trash slot for each spoil result of its recipes' ingredients and products, chains included", function()
    local raw = new_raw()
    add_item(raw, "rot")
    add_item(raw, "mush", "rot")
    add_item(raw, "fruit", "mush")
    add_item(raw, "ash")
    add_item(raw, "cake", "ash")
    add_recipe(raw, "cake", { CATEGORY }, { "fruit" }, { "cake" })
    add_machine(raw, "machine", { CATEGORY })
    crafter_slots.apply(raw)
    -- fruit spoils into mush then rot, and cake into ash
    assert(raw[machine_type].machine.trash_inventory_size == 3)
end)

test("a machine's trash is sized by its recipe with the most spoil results, in any of its categories", function()
    local raw = new_raw()
    add_item(raw, "rot")
    add_item(raw, "fruit", "rot")
    add_item(raw, "ash")
    add_item(raw, "cake", "ash")
    add_item(raw, "plate")
    add_recipe(raw, "one", { CATEGORY }, { "fruit" }, { "plate" })
    add_recipe(raw, "two", { OTHER_CATEGORY }, { "fruit" }, { "cake" })
    add_machine(raw, "both", {
        CATEGORY,
        OTHER_CATEGORY,
    })
    add_machine(raw, "first", { CATEGORY })
    crafter_slots.apply(raw)
    assert(raw[machine_type].both.trash_inventory_size == 2)
    assert(raw[machine_type].first.trash_inventory_size == 1)
end)

test("a spoil result without a spoil time doesn't count", function()
    local raw = new_raw()
    add_item(raw, "rot")
    add_item(raw, "fruit", "rot", 0)
    add_recipe(raw, "fruit", { CATEGORY }, { "fruit" }, { "fruit" })
    add_machine(raw, "machine", { CATEGORY })
    crafter_slots.apply(raw)
    assert(raw[machine_type].machine.trash_inventory_size == 1)
end)

test("a machine with more trash slots than it needs keeps them", function()
    local raw = new_raw()
    add_machine(raw, "machine", { CATEGORY }, 7)
    crafter_slots.apply(raw)
    assert(raw[machine_type].machine.trash_inventory_size == 7)
end)

test("a lab gets a trash slot for each spoil result of its inputs, and at least one", function()
    local raw = new_raw()
    add_item(raw, "rot")
    add_item(raw, "red-pack")
    add_item(raw, "green-pack", "rot")
    add_lab(raw, "plain", { "red-pack" })
    add_lab(raw, "spoiling", {
        "red-pack",
        "green-pack",
    })
    crafter_slots.apply(raw)
    assert(raw.lab.plain.trash_inventory_size == 1)
    assert(raw.lab.spoiling.trash_inventory_size == 1)
    add_item(raw, "blue-pack", "red-pack")
    raw.lab.spoiling.inputs = {
        "green-pack",
        "blue-pack",
    }
    crafter_slots.apply(raw)
    assert(raw.lab.spoiling.trash_inventory_size == 2)
end)

test("a machine with fixed output slots gets one for each item product of a recipe in its categories", function()
    local raw = new_raw()
    add_item(raw, "casing")
    add_item(raw, "grabber")
    add_recipe(raw, "cook-up", { CATEGORY }, { "casing" }, {
        "grabber",
        "casing",
        fluid("vapor"),
    })
    add_machine(raw, "oven", { CATEGORY }, nil, 1)
    add_machine(raw, "kiln", { OTHER_CATEGORY }, nil, 1)
    local num_trash, num_results = crafter_slots.apply(raw)
    -- The fluid product doesn't take an output slot
    assert(raw[machine_type].oven.result_inventory_size == 2)
    assert(raw[machine_type].kiln.result_inventory_size == 1)
    assert(num_results == 1)
    assert(num_trash == 2)
end)

test("a machine with more fixed output slots than its recipes need keeps them, and machines without fixed outputs get none", function()
    local raw = new_raw()
    add_item(raw, "junk")
    add_item(raw, "plate")
    add_item(raw, "cog")
    add_recipe(raw, "sort-junk", { CATEGORY }, { "junk" }, {
        "plate",
        "cog",
    })
    add_machine(raw, "sorter", { CATEGORY }, nil, 12)
    add_machine(raw, "machine", { CATEGORY })
    crafter_slots.apply(raw)
    assert(raw[machine_type].sorter.result_inventory_size == 12)
    assert(raw[machine_type].machine.result_inventory_size == nil)
end)

print(num_passed .. " tests passed")
