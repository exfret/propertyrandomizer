-- Plain-Lua regression tests for lib/result-summary.lua (not loaded by the mod)
-- Run from the mod root: lua lib/test-result-summary.lua
-- The log says what the randomization did (user, 2026-09-30), and a recipe no crafter can take shows as made in NOTHING

-- Stand-ins for the Factorio environment
defines = {
    prototypes = {
        item = {
            item = 0,
        },
        entity = {},
    },
}
local logged = {}
log = function(line)
    table.insert(logged, line)
end

local categories = require("helper-tables/categories")
local result_summary = require("lib/result-summary")

local num_passed = 0
local function test(name, fn)
    logged = {}
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

-- A crafting machine type, from the mod's own table; any works, since a fixed number of output slots is what makes a machine furnace-like here
local machine_types = {}
for machine_type, _ in pairs(categories.crafting_machines) do
    table.insert(machine_types, machine_type)
end
table.sort(machine_types)
local machine_type = machine_types[1]

local OVEN = "test-oven-category"
local BENCH = "test-bench-category"

local function item(name, amount, probability)
    return {
        type = "item",
        name = name,
        amount = amount or 1,
        independent_probability = probability,
    }
end

local function fluid(name, amount)
    return {
        type = "fluid",
        name = name,
        amount = amount or 1,
    }
end

local function add_item(raw, name)
    raw.item[name] = item(name)
    raw.item[name].amount = nil
end

local function add_machine(raw, name, cats, results)
    raw[machine_type][name] = {
        type = machine_type,
        name = name,
        crafting_categories = cats,
        result_inventory_size = results,
    }
end

-- A technology that unlocks these recipes, after these prerequisites
local function add_tech(raw, name, unlocks, prerequisites)
    local tech = {
        type = "technology",
        name = name,
        prerequisites = prerequisites,
    }
    tech.effects = {}
    for _, recipe_name in pairs(unlocks) do
        table.insert(tech.effects, {
            type = "unlock-recipe",
            recipe = recipe_name,
        })
    end
    raw.technology[name] = tech
end

-- A game with an oven (one output slot), a bench, and a contraption recipe the bench makes, unlocked by a technology
-- The prototype tables are the ones result_summary reads: every item class and crafting machine class, and recipes, technologies, fluids and characters
local function new_raw()
    local raw = {}
    for item_class, _ in pairs(defines.prototypes.item) do
        raw[item_class] = {}
    end
    for machine_class, _ in pairs(categories.crafting_machines) do
        raw[machine_class] = {}
    end
    raw.recipe = {}
    raw.technology = {}
    raw.fluid = {}
    raw.character = {}
    add_item(raw, "casing")
    add_item(raw, "grabber")
    add_item(raw, "gear")
    add_item(raw, "plate")
    add_machine(raw, "oven", { OVEN }, 1)
    add_machine(raw, "bench", { BENCH })
    raw.recipe.contraption = {
        type = "recipe",
        name = "contraption",
        categories = { BENCH },
        enabled = false,
        ingredients = {
            item("gear", 15),
            item("plate", 30),
        },
        results = {
            item("grabber"),
        },
    }
    add_tech(raw, "contraptions", { "contraption" })
    return raw
end

local function deepcopy(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = deepcopy(v)
    end
    return copy
end

-- A renamed recipe's name: a prefix, then its product's locale key
local function cook_up(product_name)
    return {
        "",
        "Cook up ",
        { "item-name." .. product_name },
    }
end

-- The logged line starting with this text
local function line_starting(text)
    for _, line in pairs(logged) do
        if string.find(line, text, 1, true) == 1 then
            return line
        end
    end
    return nil
end

test("a localised name shows its literal text and the prototype names its locale keys point at", function()
    assert(result_summary.text_of(cook_up("long-handed-grabber")) == "Cook up long-handed-grabber")
    local alternatives = {
        "?",
        { "entity-name.big-oven" },
        "fallback",
    }
    assert(result_summary.text_of(alternatives) == "big-oven")
    assert(result_summary.text_of("plain") == "plain")
end)

test("a recipe with more item products than a machine's fixed output slots isn't made in it", function()
    local raw = new_raw()
    local recipe = raw.recipe.contraption
    recipe.categories = { OVEN }
    recipe.ingredients = {
        item("casing"),
    }
    recipe.results = {
        item("grabber", 20),
        item("casing", 1, 0.5977),
    }
    assert(#result_summary.made_in(raw, recipe) == 0)
    raw[machine_type].oven.result_inventory_size = 2
    local made_in = result_summary.made_in(raw, recipe)
    assert(#made_in == 1 and made_in[1] == "oven")
end)

test("a machine's item ingredient cap and fluid boxes decide whether it makes a recipe", function()
    local raw = new_raw()
    local recipe = raw.recipe.contraption
    assert(#result_summary.made_in(raw, recipe) == 1)
    raw[machine_type].bench.ingredient_count = 1
    assert(#result_summary.made_in(raw, recipe) == 0)
    raw[machine_type].bench.ingredient_count = nil
    table.insert(recipe.ingredients, fluid("oil", 10))
    assert(#result_summary.made_in(raw, recipe) == 0)
    raw[machine_type].bench.fluid_boxes = {
        {
            production_type = "input",
        },
    }
    assert(#result_summary.made_in(raw, recipe) == 1)
end)

test("a changed recipe is logged with its shown name, old and new values, what unlocks it and what makes it", function()
    local before = new_raw()
    local raw = deepcopy(before)
    local recipe = raw.recipe.contraption
    recipe.localised_name = cook_up("grabber")
    recipe.categories = { OVEN }
    recipe.ingredients = {
        item("casing"),
    }
    recipe.results = {
        item("grabber", 20),
        item("casing", 1, 0.5977),
    }
    -- The product now shows another name, as an item placing another entity does
    raw.item.grabber.localised_name = { "entity-name.big-oven" }
    result_summary.log(before, raw)
    local line = line_starting("RESULT recipe contraption")
    assert(line ~= nil)
    for _, part in pairs({
        -- Before, the recipe showed its product's name
        "shown as: grabber -> Cook up grabber",
        "categories: " .. BENCH .. " -> " .. OVEN,
        "ingredients: 15 gear, 30 plate -> 1 casing",
        "products: 1 grabber -> 20 grabber \"big-oven\", 1 casing at 59.77%",
        "made in: NOTHING",
    }) do
        assert(string.find(line, part, 1, true) ~= nil, part .. " not in: " .. line)
    end
    assert(string.find(logged[#logged], "(1 made in nothing)", 1, true) ~= nil)
end)

test("an unchanged game logs no recipe, technology or other prototype", function()
    local before = new_raw()
    result_summary.log(before, deepcopy(before))
    for _, line in pairs(logged) do
        assert(string.find(line, "RESULT recipe ", 1, true) == nil, line)
        assert(string.find(line, "RESULT technology ", 1, true) == nil, line)
    end
    assert(string.find(logged[#logged], "Listed 0 recipes (0 made in nothing), 0 technologies and 0 other prototypes", 1, true) ~= nil, logged[#logged])
end)

test("a technology's changed unlocks and prerequisites are logged, and so is the recipe it unlocks now, with its shown name", function()
    local before = new_raw()
    local raw = deepcopy(before)
    add_tech(raw, "later-tech", { "contraption" }, { "contraptions" })
    raw.technology["later-tech"].localised_name = cook_up("grabber")
    raw.technology.contraptions.effects = {}
    result_summary.log(before, raw)
    assert(line_starting("RESULT technology contraptions: unlocks: contraption -> none") ~= nil, table.concat(logged, "\n"))
    -- Without a research cost, nothing is shown for it
    local tech_line = line_starting("RESULT technology later-tech (new): ")
    assert(tech_line == "RESULT technology later-tech (new): shown as: Cook up grabber; prerequisites: contraptions; unlocks: contraption", tostring(tech_line))
    assert(line_starting("RESULT recipe contraption: unlocked by: contraptions -> later-tech \"Cook up grabber\"") ~= nil, table.concat(logged, "\n"))
end)

test("prototypes a step added are only counted when given as unlisted", function()
    local before = new_raw()
    local raw = deepcopy(before)
    local names = result_summary.prototype_names(raw)
    add_item(raw, "old-grabber")
    raw.recipe["make-old-grabber"] = {
        type = "recipe",
        name = "make-old-grabber",
        ingredients = {
            item("grabber"),
        },
        results = {
            item("old-grabber"),
        },
    }
    local added = result_summary.added_since(names, raw)
    assert(added.item["old-grabber"] ~= nil and added.recipe["make-old-grabber"] ~= nil and added.item.grabber == nil)
    result_summary.log(before, raw, {
        prototypes = added,
        what = "copies",
    })
    assert(line_starting("RESULT recipe make-old-grabber") == nil)
    assert(line_starting("RESULT 1 changed or new prototypes aren't listed: copies") ~= nil, table.concat(logged, "\n"))
end)

print(num_passed .. " tests passed")
