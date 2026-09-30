-- Plain-Lua regression tests for lib/crafter-slots.lua (not loaded by the mod)
-- Run from the mod root: lua lib/test-crafter-slots.lua
-- Every crafting machine and lab gets trash slots for spoil results (user, 2026-09-30), and furnaces get an output slot for each item product of their recipes, so every crafter of a recipe's category can craft it as the logic has it

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

-- A crafting machine type other than the furnace (which has fixed output slots), from the mod's own table
local machine_types = {}
for machine_type, _ in pairs(categories.crafting_machines) do
    if machine_type ~= "furnace" then
        table.insert(machine_types, machine_type)
    end
end
table.sort(machine_types)
local machine_type = machine_types[1]

local CATEGORY = "test-category"
local OTHER_CATEGORY = "test-other-category"

local function new_raw()
    local raw = {
        item = {},
        recipe = {},
        furnace = {},
        lab = {},
    }
    raw[machine_type] = {}
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

-- Materials are item names, or { type, name } for another type
local function add_recipe(raw, name, cats, ingredients, results)
    local function materials(entries)
        local list = {}
        for _, entry in pairs(entries) do
            local material_type = "item"
            local material_name = entry
            if type(entry) == "table" then
                material_type = entry[1]
                material_name = entry[2]
            end
            table.insert(list, {
                type = material_type,
                name = material_name,
                amount = 1,
            })
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

local function add_machine(raw, name, cats, trash)
    raw[machine_type][name] = {
        type = machine_type,
        name = name,
        crafting_categories = cats,
        trash_inventory_size = trash,
    }
end

local function add_furnace(raw, name, cats, results)
    raw.furnace[name] = {
        type = "furnace",
        name = name,
        crafting_categories = cats,
        source_inventory_size = 1,
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

test("a furnace gets an output slot for each item product of a recipe in its categories", function()
    local raw = new_raw()
    add_item(raw, "shell")
    add_item(raw, "inserter")
    add_recipe(raw, "cook-up", { CATEGORY }, { "shell" }, {
        "inserter",
        "shell",
        {
            "fluid",
            "steam",
        },
    })
    add_furnace(raw, "oven", { CATEGORY }, 1)
    add_furnace(raw, "kiln", { OTHER_CATEGORY }, 1)
    local num_trash, num_results = crafter_slots.apply(raw)
    -- The fluid product doesn't take an output slot
    assert(raw.furnace.oven.result_inventory_size == 2)
    assert(raw.furnace.kiln.result_inventory_size == 1)
    assert(num_results == 1)
    assert(num_trash == 2)
end)

test("a furnace with more output slots than its recipes need keeps them, and other crafting machines get none", function()
    local raw = new_raw()
    add_item(raw, "scrap")
    add_item(raw, "plate")
    add_item(raw, "cog")
    add_recipe(raw, "recycle", { CATEGORY }, { "scrap" }, {
        "plate",
        "cog",
    })
    add_furnace(raw, "recycler", { CATEGORY }, 12)
    add_machine(raw, "machine", { CATEGORY })
    crafter_slots.apply(raw)
    assert(raw.furnace.recycler.result_inventory_size == 12)
    assert(raw[machine_type].machine.result_inventory_size == nil)
end)

print(num_passed .. " tests passed")
