-- Plain-Lua regression tests for the recipe-ingredients blacklist concepts in lib/data-utils.lua (not loaded by the mod)
-- Run from the mod root: lua lib/test-raw-materials.lua
-- compat/vanilla.lua keeps resource materials (dutils.resource_materials) and round trips (dutils.round_trips) out of ingredient randomization

-- Stand-ins for the Factorio environment
defines = {
    prototypes = {
        entity = {
            ["resource"] = 0,
            ["asteroid-chunk"] = 0,
            -- Any other entity classes; the code goes over all of them
            ["flora"] = 0,
            ["machine"] = 0,
        },
    },
}

local dutils = require("lib/data-utils")

local num_passed = 0
local function test(name, fn)
    data = {
        raw = {
            ["resource"] = {},
            ["asteroid-chunk"] = {},
            ["flora"] = {},
            ["machine"] = {},
            tile = {},
            recipe = {},
        },
    }
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function item(name, amount)
    return { type = "item", name = name, amount = amount or 1 }
end

local function fluid(name, amount)
    return { type = "fluid", name = name, amount = amount or 10 }
end

local function add_recipe(name, ingredients, results, categories)
    data.raw.recipe[name] = {
        type = "recipe",
        name = name,
        categories = categories,
        ingredients = ingredients,
        results = results,
    }
end

-- An entity turning one filtered fluid into another, with fluid boxes set up as on vanilla's fusion reactor (__space-age__/prototypes/entity/entities.lua)
local function add_converter(class, name, from, to)
    data.raw[class][name] = {
        type = class,
        name = name,
        input_fluid_box = { production_type = "input", filter = from },
        output_fluid_box = { production_type = "output", filter = to },
    }
end

local function count(tbl)
    local n = 0
    for _, _ in pairs(tbl) do
        n = n + 1
    end
    return n
end

test("resource materials are what resources and asteroid chunks give when mined, plus tile fluids", function()
    data.raw["resource"]["ore-patch"] = { type = "resource", name = "ore-patch", minable = { result = "ore" } }
    data.raw["resource"]["oil-field"] = { type = "resource", name = "oil-field", minable = { results = { fluid("oil") } } }
    data.raw["resource"]["mixed-patch"] = { type = "resource", name = "mixed-patch", minable = { results = { item("gem"), fluid("brine") } } }
    data.raw["resource"]["unminable"] = { type = "resource", name = "unminable" }
    data.raw["asteroid-chunk"]["rock-chunk"] = { type = "asteroid-chunk", name = "rock-chunk", minable = { result = "rock-chunk" } }
    data.raw.tile["lake"] = { type = "tile", name = "lake", fluid = "lake-water" }
    data.raw.tile["meadow"] = { type = "tile", name = "meadow" }
    -- Other minable things (trees, buildings) aren't resources
    data.raw["flora"]["shrub"] = { type = "flora", name = "shrub", minable = { result = "timber" } }

    local materials = dutils.resource_materials()
    assert(materials["item-ore"] ~= nil and materials["item-ore"].type == "item" and materials["item-ore"].name == "ore")
    assert(materials["fluid-oil"] ~= nil and materials["fluid-oil"].type == "fluid")
    assert(materials["item-gem"] ~= nil)
    assert(materials["fluid-brine"] ~= nil)
    assert(materials["item-rock-chunk"] ~= nil)
    assert(materials["fluid-lake-water"] ~= nil and materials["fluid-lake-water"].name == "lake-water")
    assert(materials["item-timber"] == nil)
    assert(count(materials) == 6)
end)

test("exact inverse recipes are round trips, and changing an amount breaks the pair", function()
    add_recipe("fill", { fluid("water", 50), item("barrel") }, { item("water-barrel") })
    add_recipe("empty", { item("water-barrel") }, { fluid("water", 50), item("barrel") })
    add_recipe("fill-oil", { fluid("oil", 50), item("barrel") }, { item("oil-barrel") })
    add_recipe("empty-oil-lossy", { item("oil-barrel") }, { fluid("oil", 40), item("barrel") })

    local round_trips = dutils.round_trips()
    assert(round_trips.recipes["fill"] and round_trips.recipes["empty"])
    assert(not round_trips.recipes["fill-oil"] and not round_trips.recipes["empty-oil-lossy"])
    -- Pairs freeze their recipes, but not the materials, which are used all over (water, oil)
    assert(count(round_trips.materials) == 0)
end)

test("recycling isn't a round trip, even though it inverts its recipe", function()
    add_recipe("gear", { item("plate", 2) }, { item("gear") })
    add_recipe("gear-recycling", { item("gear") }, { item("plate", 2) }, { "recycling" })

    local round_trips = dutils.round_trips()
    assert(count(round_trips.recipes) == 0)
    assert(count(round_trips.materials) == 0)
end)

test("a coolant loop through entities freezes its recipe and pins the fluids it carries", function()
    -- As in Space Age: the reactor turns cold into plasma, the generator plasma into hot, and a recipe cools hot back down
    add_converter("machine", "reactor", "cold", "plasma")
    add_converter("machine", "generator", "plasma", "hot")
    add_recipe("cooling", { fluid("hot") }, { fluid("cold") })
    -- A recipe that uses the coolant and returns it hot makes more than one thing, so it isn't a single-material conversion
    add_recipe("cryo-pack", { fluid("cold"), item("ice") }, { item("pack"), fluid("hot") })

    local round_trips = dutils.round_trips()
    assert(round_trips.recipes["cooling"])
    assert(not round_trips.recipes["cryo-pack"])
    assert(round_trips.materials["fluid-cold"] ~= nil and round_trips.materials["fluid-cold"].type == "fluid")
    assert(round_trips.materials["fluid-hot"] ~= nil)
    assert(round_trips.materials["fluid-plasma"] ~= nil)
    assert(round_trips.materials["item-ice"] == nil)
end)

test("a one-way conversion isn't a round trip until something converts back", function()
    -- Fluid boxes as on vanilla's boiler (__base__/prototypes/entity/entities.lua)
    data.raw["machine"]["evaporator"] = {
        type = "machine",
        name = "evaporator",
        fluid_box = { production_type = "input", filter = "liquid" },
        output_fluid_box = { production_type = "output", filter = "vapor" },
    }
    -- A boiler in fluid heating mode heats a fluid in place ("input-output"), so it converts nothing
    data.raw["machine"]["heater"] = {
        type = "machine",
        name = "heater",
        fluid_box = { production_type = "input-output", filter = "oil" },
    }
    add_recipe("oil-cracking", { fluid("oil") }, { fluid("gas") })
    add_recipe("gas-condensing", { fluid("gas") }, { fluid("heavy") })
    add_recipe("melting", { item("ice") }, { fluid("liquid") })
    local round_trips = dutils.round_trips()
    assert(count(round_trips.recipes) == 0)
    assert(count(round_trips.materials) == 0)

    add_recipe("condensation", { fluid("vapor", 1000) }, { fluid("liquid", 90) })
    round_trips = dutils.round_trips()
    assert(round_trips.recipes["condensation"])
    assert(not round_trips.recipes["melting"])
    assert(round_trips.materials["fluid-liquid"] ~= nil and round_trips.materials["fluid-vapor"] ~= nil)
    assert(round_trips.materials["item-ice"] == nil)
    assert(round_trips.materials["fluid-oil"] == nil)
end)

test("catalysts don't count, so a recipe that only enriches its catalyst isn't a conversion", function()
    -- Like kovarex: both materials are on both sides
    add_recipe("enrichment", { item("u235", 40), item("u238", 5) }, { item("u235", 41), item("u238", 2) })
    -- A catalyst on both sides of a real conversion doesn't stop it counting
    add_recipe("forward", { item("a"), item("tool") }, { item("b"), item("tool") })
    add_recipe("backward", { item("b") }, { item("a") })

    local round_trips = dutils.round_trips()
    assert(not round_trips.recipes["enrichment"])
    assert(round_trips.recipes["forward"] and round_trips.recipes["backward"])
    assert(round_trips.materials["item-tool"] == nil)
end)

print(num_passed .. " tests passed")
