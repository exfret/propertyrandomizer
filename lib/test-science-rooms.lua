-- Plain-Lua tests for the rooms each science pack belongs to (lib/science-rooms.lua; not loaded by the mod)
-- Run from the mod root: lua lib/test-science-rooms.lua
-- Fixture packs and rooms are named after vanilla Space Age's (verified 2026-10-10 in the installed game's space-age/prototypes/recipe.lua, planet/planet.lua and surface.lua: metallurgic science needs pressure 4000, which only Vulcanus has; space science gravity 0, which only space platforms have; the base packs have no surface conditions)

local science_rooms = require("lib/science-rooms")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local START = "planet: nauvis"
-- Each fixture recipe lists the rooms accepting it as its surface_conditions here
local ALL_ROOMS = {
    ["planet: nauvis"] = true,
    ["planet: vulcanus"] = true,
    ["planet: vulcanus-exfret-2-copy"] = true,
    ["planet: fulgora"] = true,
    ["surface: space-platform"] = true,
}
local function accepting(recipe)
    return recipe.surface_conditions or ALL_ROOMS
end

local function keys(set)
    local list = {}
    for key, _ in pairs(set or {}) do
        table.insert(list, key)
    end
    table.sort(list)
    return table.concat(list, ", ")
end

local function pack_recipe(name, product, rooms, extra)
    local recipe = {
        name = name,
        results = {
            {
                type = "item",
                name = product,
                amount = 1,
            },
        },
        surface_conditions = rooms,
    }
    for k, v in pairs(extra or {}) do
        recipe[k] = v
    end
    return recipe
end

test("a pack the starting planet can make belongs to it alone, a locked pack to the rooms its recipe is locked to", function()
    local packs = {
        ["automation-science-pack"] = true,
        ["utility-science-pack"] = true,
        ["metallurgic-science-pack"] = true,
        ["space-science-pack"] = true,
    }
    local recipes = {
        pack_recipe("automation-science-pack", "automation-science-pack"),
        pack_recipe("utility-science-pack", "utility-science-pack"),
        pack_recipe("metallurgic-science-pack", "metallurgic-science-pack", { ["planet: vulcanus"] = true }),
        pack_recipe("space-science-pack", "space-science-pack", { ["surface: space-platform"] = true }),
    }
    local rooms = science_rooms.of_packs(packs, recipes, START, accepting)
    assert(keys(rooms["automation-science-pack"]) == START)
    -- Utility science belongs to the starting planet, not to Fulgora, which could make it too
    assert(keys(rooms["utility-science-pack"]) == START)
    assert(keys(rooms["metallurgic-science-pack"]) == "planet: vulcanus")
    assert(keys(rooms["space-science-pack"]) == "surface: space-platform")
end)

test("a planet copy's pack belongs to its copy, and a pack several rooms accept belongs to all of them", function()
    local packs = {
        ["metallurgic-science-pack-exfret-2-copy"] = true,
        ["shared-science-pack"] = true,
    }
    local recipes = {
        pack_recipe("metallurgic-science-pack-exfret-2-copy", "metallurgic-science-pack-exfret-2-copy", { ["planet: vulcanus-exfret-2-copy"] = true }),
        pack_recipe("shared-science-pack", "shared-science-pack", {
            ["planet: vulcanus"] = true,
            ["planet: fulgora"] = true,
        }),
    }
    local rooms = science_rooms.of_packs(packs, recipes, START, accepting)
    assert(keys(rooms["metallurgic-science-pack-exfret-2-copy"]) == "planet: vulcanus-exfret-2-copy")
    assert(keys(rooms["shared-science-pack"]) == "planet: fulgora, planet: vulcanus")
end)

test("any recipe of a pack the starting planet accepts makes it the starting planet's, whatever order the recipes come in", function()
    local packs = {
        ["two-recipe-pack"] = true,
    }
    local locked = pack_recipe("two-recipe-pack-locked", "two-recipe-pack", { ["planet: vulcanus"] = true })
    local free = pack_recipe("two-recipe-pack-free", "two-recipe-pack")
    local orders = {
        {
            locked,
            free,
        },
        {
            free,
            locked,
        },
    }
    for _, recipes in pairs(orders) do
        local rooms = science_rooms.of_packs(packs, recipes, START, accepting)
        assert(keys(rooms["two-recipe-pack"]) == START)
    end
    -- Two locked recipes give every room either accepts
    local other = pack_recipe("two-recipe-pack-other", "two-recipe-pack", { ["planet: fulgora"] = true })
    local both_locked = {
        locked,
        other,
    }
    local rooms = science_rooms.of_packs(packs, both_locked, START, accepting)
    assert(keys(rooms["two-recipe-pack"]) == "planet: fulgora, planet: vulcanus")
end)

test("hidden recipes (like recycling giving a pack back) and recipes making a pack only on the side don't count", function()
    local packs = {
        ["metallurgic-science-pack"] = true,
    }
    local recipes = {
        pack_recipe("metallurgic-science-pack", "metallurgic-science-pack", { ["planet: vulcanus"] = true }),
        -- The recycler's self-recycling recipe: hidden, and every room accepts it
        pack_recipe("metallurgic-science-pack-recycling", "metallurgic-science-pack", nil, {
            hidden = true,
        }),
        -- A pack among several results, with something else as the main product
        {
            name = "side-product",
            main_product = "iron-plate",
            results = {
                {
                    type = "item",
                    name = "iron-plate",
                    amount = 1,
                },
                {
                    type = "item",
                    name = "metallurgic-science-pack",
                    amount = 1,
                },
            },
        },
    }
    local rooms = science_rooms.of_packs(packs, recipes, START, accepting)
    assert(keys(rooms["metallurgic-science-pack"]) == "planet: vulcanus")
end)

test("a pack with a main product among several results counts, and a pack no recipe makes belongs to the starting planet", function()
    local packs = {
        ["cryogenic-science-pack"] = true,
        ["rocket-launch-pack"] = true,
    }
    local recipes = {
        {
            name = "cryogenic-science-pack",
            main_product = "cryogenic-science-pack",
            surface_conditions = {
                ["planet: aquilo"] = true,
            },
            results = {
                {
                    type = "item",
                    name = "cryogenic-science-pack",
                    amount = 1,
                },
                {
                    type = "fluid",
                    name = "fluoroketone-hot",
                    amount = 3,
                },
            },
        },
    }
    local rooms = science_rooms.of_packs(packs, recipes, START, accepting)
    assert(keys(rooms["cryogenic-science-pack"]) == "planet: aquilo")
    -- Like space science in the base game, a rocket launch's result
    assert(keys(rooms["rocket-launch-pack"]) == START)
end)

print(num_passed .. " tests passed")
