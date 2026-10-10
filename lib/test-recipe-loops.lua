-- Plain-Lua tests for positive loops of size one (lib/recipe-loops.lua; not loaded by the mod)
-- Run from the mod root: lua lib/test-recipe-loops.lua
-- Fixtures follow vanilla Space Age recipes (verified 2026-10-10 in the installed game's space-age/prototypes/recipe.lua: pentapod-egg takes one egg and makes two)

local recipe_loops = require("lib/recipe-loops")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function names(set)
    local list = {}
    for name, _ in pairs(set) do
        table.insert(list, name)
    end
    table.sort(list)
    return table.concat(list, ", ")
end

test("a recipe making more of an item than it takes gains that item", function()
    local pentapod_egg = {
        ingredients = {
            {
                type = "item",
                name = "pentapod-egg",
                amount = 1,
            },
            {
                type = "item",
                name = "nutrients",
                amount = 30,
            },
            {
                type = "fluid",
                name = "water",
                amount = 60,
            },
        },
        results = {
            {
                type = "item",
                name = "pentapod-egg",
                amount = 2,
            },
        },
    }
    assert(names(recipe_loops.gained_items(pentapod_egg)) == "pentapod-egg")
end)

test("only the item the recipe makes more of counts, not one it makes less of", function()
    -- Like uranium enrichment: 40 of one isotope in and 41 out, 5 of the other in and 2 out
    local enrichment = {
        ingredients = {
            {
                type = "item",
                name = "rich",
                amount = 40,
            },
            {
                type = "item",
                name = "poor",
                amount = 5,
            },
        },
        results = {
            {
                type = "item",
                name = "rich",
                amount = 41,
            },
            {
                type = "item",
                name = "poor",
                amount = 2,
            },
        },
    }
    assert(names(recipe_loops.gained_items(enrichment)) == "rich")
end)

test("giving back as much as it takes, or less on average, isn't a positive loop", function()
    local catalyst = {
        ingredients = {
            {
                type = "item",
                name = "catalyst",
                amount = 1,
            },
        },
        results = {
            {
                type = "item",
                name = "catalyst",
                amount = 1,
            },
        },
    }
    assert(next(recipe_loops.gained_items(catalyst)) == nil)
    -- Like the recycler's self-recycling recipes: one in, a quarter of one back
    local recycling = {
        ingredients = {
            {
                type = "item",
                name = "pack",
                amount = 1,
            },
        },
        results = {
            {
                type = "item",
                name = "pack",
                amount = 1,
                independent_probability = 0.25,
            },
        },
    }
    assert(next(recipe_loops.gained_items(recycling)) == nil)
    -- Two out with a 40% chance is 0.8 on average, less than the one taken
    local unlucky = {
        ingredients = {
            {
                type = "item",
                name = "seed",
                amount = 1,
            },
        },
        results = {
            {
                type = "item",
                name = "seed",
                amount = 2,
                independent_probability = 0.4,
            },
        },
    }
    assert(next(recipe_loops.gained_items(unlucky)) == nil)
end)

test("expected amounts count ranges, chances, extra counts and several entries of one item", function()
    local ranged = {
        ingredients = {
            {
                type = "item",
                name = "spore",
                amount = 2,
            },
        },
        results = {
            {
                type = "item",
                name = "spore",
                amount_min = 1,
                amount_max = 3,
            },
            {
                type = "item",
                name = "spore",
                amount = 1,
                extra_count_fraction = 0.5,
            },
        },
    }
    -- 2 on average from the range, plus 1.5 from the second entry
    assert(names(recipe_loops.gained_items(ranged)) == "spore")
end)

test("fluids and items the recipe doesn't take back don't count", function()
    local liquefaction = {
        ingredients = {
            {
                type = "fluid",
                name = "heavy-oil",
                amount = 25,
            },
            {
                type = "item",
                name = "coal",
                amount = 10,
            },
        },
        results = {
            {
                type = "fluid",
                name = "heavy-oil",
                amount = 90,
            },
        },
    }
    assert(next(recipe_loops.gained_items(liquefaction)) == nil)
    assert(next(recipe_loops.gained_items({})) == nil)
end)

test("catalysts are the items a visible recipe both takes and makes, whatever the amounts", function()
    local recipes = {
        ["pentapod-egg"] = {
            ingredients = {
                {
                    type = "item",
                    name = "pentapod-egg",
                    amount = 1,
                },
                {
                    type = "item",
                    name = "nutrients",
                    amount = 30,
                },
            },
            results = {
                {
                    type = "item",
                    name = "pentapod-egg",
                    amount = 2,
                },
            },
        },
        -- Gives back less than it takes, but still a catalyst
        ["crushing"] = {
            ingredients = {
                {
                    type = "item",
                    name = "chunk",
                    amount = 1,
                },
            },
            results = {
                {
                    type = "item",
                    name = "ore",
                    amount = 20,
                },
                {
                    type = "item",
                    name = "chunk",
                    amount = 1,
                    independent_probability = 0.2,
                },
            },
        },
        -- The recycler's self-recycling is hidden, so it doesn't count
        ["ore-recycling"] = {
            hidden = true,
            ingredients = {
                {
                    type = "item",
                    name = "ore",
                    amount = 1,
                },
            },
            results = {
                {
                    type = "item",
                    name = "ore",
                    amount = 1,
                    independent_probability = 0.25,
                },
            },
        },
        ["gears"] = {
            ingredients = {
                {
                    type = "item",
                    name = "plate",
                    amount = 2,
                },
            },
            results = {
                {
                    type = "item",
                    name = "gear",
                    amount = 1,
                },
            },
        },
    }
    assert(names(recipe_loops.catalyst_items(recipes)) == "chunk, pentapod-egg")
end)

test("a catalyst's position only takes stackable identities, every other position takes anything", function()
    local catalysts = {
        ["pentapod-egg"] = true,
    }
    local function is_stackable(item)
        return item.stackable
    end
    local armor = {
        name = "power-armor",
        stackable = false,
    }
    local plate = {
        name = "iron-plate",
        stackable = true,
    }
    assert(not recipe_loops.identity_fits("pentapod-egg", armor, catalysts, is_stackable))
    assert(recipe_loops.identity_fits("pentapod-egg", plate, catalysts, is_stackable))
    assert(recipe_loops.identity_fits("iron-gear-wheel", armor, catalysts, is_stackable))
    -- Not an item (like a fluid identity): nothing to cap
    assert(recipe_loops.identity_fits("pentapod-egg", nil, catalysts, is_stackable))
end)

print(num_passed .. " tests passed")
