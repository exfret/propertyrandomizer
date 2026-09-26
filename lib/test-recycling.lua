-- Plain-Lua regression tests for lib/recycling.lua, which generates recycling recipes the way the recycler does (recycler/recycling.lua and recycler/data-updates.lua), but from the game after randomization
-- Run from the mod root: lua lib/test-recycling.lua

-- Stand-ins for the Factorio environment
defines = {
    prototypes = {
        item = {
            item = 0,
        },
        entity = {},
        equipment = {},
    },
}

local recycling = require("lib/recycling")
local recycling_sources = require("lib/logic/recycling-sources")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function entry(name, amount)
    return {
        type = "item",
        name = name,
        amount = amount,
    }
end

local function fluid_entry(name, amount)
    return {
        type = "fluid",
        name = name,
        amount = amount,
    }
end

local function items(names)
    local result = {}
    for _, name in pairs(names) do
        result[name] = {
            type = "item",
            name = name,
        }
    end
    return result
end

-- Recipes and their recycling as the recycler generates them from recipes
local function game(recipes, item_names)
    local raw = {
        recipe = recipes,
        item = items(item_names),
        fluid = {
            ["some-fluid"] = {
                name = "some-fluid",
            },
        },
        technology = {},
    }
    data = {
        raw = raw,
    }
    for name, entry in pairs(recycling.generate(raw)) do
        entry.recipe.enabled = true
        raw.recipe[name] = entry.recipe
    end
    return raw
end

local function copy(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    local result = {}
    for k, v in pairs(tbl) do
        result[k] = copy(v)
    end
    return result
end

-- Randomization runs on a copy of the game, like data.raw after old_data_raw was taken
local function randomize(old_raw)
    data = {
        raw = copy(old_raw),
    }
    return data.raw
end

local function results_of(recipe)
    local result = {}
    for _, product in pairs(recipe.results) do
        result[product.name] = product
    end
    return result
end

local function base_recipes()
    return {
        gear = {
            name = "gear",
            ingredients = {entry("plate", 2)},
            results = {entry("gear", 1)},
        },
        circuit = {
            name = "circuit",
            ingredients = {entry("plate", 1), entry("cable", 3)},
            results = {entry("circuit", 1)},
        },
        cable = {
            name = "cable",
            ingredients = {entry("plate", 1)},
            results = {entry("cable", 2)},
        },
        junk = {
            name = "junk",
            categories = {"recycling", "by-hand"},
            ingredients = {entry("junk", 1)},
            results = {entry("gear", 1)},
        },
    }
end

local item_names = {"plate", "gear", "circuit", "cable", "junk", "new-item"}

test("recycling returns a quarter of each item ingredient per result, as the recycler does", function()
    local raw = game(base_recipes(), item_names)
    local gear = results_of(raw.recipe["gear-recycling"])
    assert(gear.plate.amount == 0 and gear.plate.extra_count_fraction == 0.5)
    local cable = results_of(raw.recipe["cable-recycling"])
    assert(cable.plate.amount == 0 and cable.plate.extra_count_fraction == 0.125)
    local circuit = results_of(raw.recipe["circuit-recycling"])
    assert(circuit.cable.amount == 0 and circuit.cable.extra_count_fraction == 0.75)
    -- Self-recycling for items no recipe makes
    local plate = raw.recipe["plate-recycling"]
    assert(plate.results[1].name == "plate" and plate.results[1].independent_probability == 0.25)
    -- Hand-written recycling (like scrap recycling) is left alone, and its name keeps the self-recycling recipe from being made
    assert(raw.recipe["junk"].results[1].name == "gear")
    assert(raw.recipe["junk-recycling"] ~= nil and raw.recipe["junk-recycling"].results[1].name == "junk")
end)

test("regenerated recycling follows changed ingredients", function()
    local old_raw = game(base_recipes(), item_names)
    local raw = randomize(old_raw)
    raw.recipe.gear.ingredients = {entry("cable", 8), entry("circuit", 4)}
    recycling.regenerate(old_raw)
    local gear = results_of(raw.recipe["gear-recycling"])
    assert(gear.plate == nil)
    assert(gear.cable.amount == 2 and gear.cable.extra_count_fraction == 0)
    assert(gear.circuit.amount == 1)
end)

test("a recipe with no item ingredients left isn't reversed, so its item recycles into itself", function()
    local old_raw = game(base_recipes(), item_names)
    local raw = randomize(old_raw)
    raw.recipe.gear.ingredients = {fluid_entry("some-fluid", 10)}
    recycling.regenerate(old_raw)
    local gear = raw.recipe["gear-recycling"]
    assert(#gear.results == 1 and gear.results[1].name == "gear" and gear.results[1].independent_probability == 0.25)
end)

test("a recipe with several item results isn't reversed", function()
    local old_raw = game(base_recipes(), item_names)
    local raw = randomize(old_raw)
    table.insert(raw.recipe.circuit.results, entry("gear", 1))
    recycling.regenerate(old_raw)
    assert(raw.recipe["circuit-recycling"].results[1].name == "circuit")
end)

test("recycling follows what a recipe makes now, under the name of its new item", function()
    local old_raw = game(base_recipes(), item_names)
    local raw = randomize(old_raw)
    raw.recipe.gear.results = {entry("new-item", 1)}
    recycling.regenerate(old_raw)
    local new_item = results_of(raw.recipe["new-item-recycling"])
    assert(new_item.plate.extra_count_fraction == 0.5)
    -- No recipe makes gears anymore
    assert(raw.recipe["gear-recycling"].results[1].name == "gear")
    -- Hand-written recycling (like scrap recycling) is still left alone
    assert(raw.recipe["junk-recycling"].results[1].name == "junk")
    assert(raw.recipe["junk"].results[1].name == "gear")
end)

test("after item randomization swaps items, each item's recycling keeps the name of the recipe recycling it, which the logic model follows", function()
    local old_raw = game(base_recipes(), item_names)
    local raw = randomize(old_raw)
    local swap = {
        gear = "cable",
        cable = "gear",
    }
    for _, recipe in pairs(raw.recipe) do
        for _, list in pairs({recipe.ingredients or {}, recipe.results or {}}) do
            for _, material in pairs(list) do
                material.name = swap[material.name] or material.name
            end
        end
    end
    recycling.regenerate(old_raw)
    -- The recipe named gear-recycling recycles cables now, which the recipe named gear makes
    local gear_recycling = raw.recipe["gear-recycling"]
    assert(gear_recycling.ingredients[1].name == "cable")
    assert(results_of(gear_recycling).plate.extra_count_fraction == 0.5)
    local cable_recycling = raw.recipe["cable-recycling"]
    assert(cable_recycling.ingredients[1].name == "gear")
    assert(results_of(cable_recycling).plate.extra_count_fraction == 0.125)
    assert(recycling_sources.get(old_raw)["gear-recycling"] == "gear")
    -- Circuits need 3 of what's now a gear
    assert(results_of(raw.recipe["circuit-recycling"]).gear.extra_count_fraction == 0.75)
end)

test("the recycler's recycle_to_ingredients_of redirect is kept", function()
    local recipes = base_recipes()
    recipes["fancy-gear"] = {
        name = "fancy-gear",
        recycle_to_ingredients_of = "gear",
        ingredients = {entry("gear", 1), entry("cable", 5)},
        results = {entry("fancy-gear", 1)},
    }
    local old_raw = game(recipes, {"plate", "gear", "circuit", "cable", "junk", "fancy-gear"})
    assert(recycling_sources.get(old_raw)["fancy-gear-recycling"] == "gear")
    local raw = randomize(old_raw)
    raw.recipe.gear.ingredients = {entry("circuit", 4)}
    recycling.regenerate(old_raw)
    local fancy = results_of(raw.recipe["fancy-gear-recycling"])
    assert(fancy.circuit.amount == 1 and fancy.cable == nil)
end)

test("among recipes making the same item, the one recycled before randomization stays the source", function()
    local recipes = base_recipes()
    -- Sorts before "gear", so it's first by name
    recipes["a-gear"] = {
        name = "a-gear",
        ingredients = {entry("cable", 4)},
        results = {entry("gear", 1)},
    }
    local old_raw = game(recipes, item_names)
    -- As if the recycler had visited "gear" last
    old_raw.recipe["gear-recycling"].results = {entry("plate", 0)}
    old_raw.recipe["gear-recycling"].results[1].extra_count_fraction = 0.5
    assert(recycling_sources.get(old_raw)["gear-recycling"] == "gear")
    local raw = randomize(old_raw)
    raw.recipe.gear.ingredients = {entry("circuit", 4)}
    recycling.regenerate(old_raw)
    assert(results_of(raw.recipe["gear-recycling"]).circuit ~= nil)
    -- Once it stops making gears, the other one is used
    raw.recipe.gear.results = {entry("new-item", 1)}
    recycling.regenerate(old_raw)
    assert(results_of(raw.recipe["gear-recycling"]).cable ~= nil)
end)

test("recycling recipes are unlocked from the start, and no technology unlocks them", function()
    local old_raw = game(base_recipes(), item_names)
    old_raw.technology["unlock-tech"] = {
        name = "unlock-tech",
        effects = {},
    }
    for name, recipe in pairs(old_raw.recipe) do
        if recycling.looks_generated(recipe) then
            recipe.enabled = false
            table.insert(old_raw.technology["unlock-tech"].effects, {
                type = "unlock-recipe",
                recipe = name,
            })
        end
    end
    table.insert(old_raw.technology["unlock-tech"].effects, {
        type = "unlock-recipe",
        recipe = "gear",
    })
    local raw = randomize(old_raw)
    raw.recipe.gear.results = {entry("new-item", 1)}
    recycling.regenerate(old_raw)
    for name, recipe in pairs(raw.recipe) do
        if recycling.looks_generated(recipe) then
            assert(recipe.enabled == true, name)
        end
    end
    -- Only other recipes' unlocks are left
    local effects = raw.technology["unlock-tech"].effects
    assert(#effects == 1 and effects[1].recipe == "gear")
end)

test("regenerating twice changes nothing", function()
    local old_raw = game(base_recipes(), item_names)
    local raw = randomize(old_raw)
    raw.recipe.gear.results = {entry("new-item", 1)}
    recycling.regenerate(old_raw)
    local first = copy(raw.recipe)
    recycling.regenerate(old_raw)
    for name, recipe in pairs(first) do
        assert(raw.recipe[name] ~= nil, name)
        assert(#raw.recipe[name].results == #recipe.results, name)
    end
    for name, _ in pairs(raw.recipe) do
        assert(first[name] ~= nil, name)
    end
end)

print(num_passed .. " tests passed")
