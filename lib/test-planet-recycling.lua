-- Run from the mod root: lua lib/test-planet-recycling.lua
local recycling = require("lib/recycling")
local surface_sets = require("lib/surface-sets")
local furnace_selection = require("lib/furnace-selection")

function table.deepcopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for k, v in pairs(value) do copy[k] = table.deepcopy(v) end
    return copy
end
function log() end
defines = { prototypes = { item = { item = 0 }, entity = {}, equipment = {} } }
lookups = { rooms = {} }
data = { raw = { item = {}, recipe = {}, planet = {}, surface = {}, fluid = {}, technology = {}, ["surface-property"] = {} } }
function data:extend(prototypes)
    for _, prototype in pairs(prototypes) do
        self.raw[prototype.type] = self.raw[prototype.type] or {}
        self.raw[prototype.type][prototype.name] = prototype
    end
end
local function entry(name, amount)
    return { type = "item", name = name, amount = amount or 1 }
end
for _, name in pairs({ "gear", "circuit", "plate", "ore-a", "ore-b", "alternate-ore", "test-product" }) do
    data.raw.item[name] = { type = "item", name = name }
end
data.raw["surface-property"].test_world = { type = "surface-property", name = "test_world", default_value = 0 }
for i = 1, 3 do
    local name = "world-" .. i
    data.raw.planet[name] = { type = "planet", name = name, surface_properties = { test_world = i } }
    lookups.rooms["planet: " .. name] = data.raw.planet[name]
end
local function source(name, output, input, world, original)
    local recipe = { type = "recipe", name = name, ingredients = { entry(input, 4) }, results = { entry(output) }, orig_name = original }
    if world ~= nil then
        recipe.dupe_number = world
        recipe.surface_conditions = { { property = "test_world", min = world, max = world } }
    end
    data.raw.recipe[name] = recipe
    return recipe
end
source("gear", "gear", "plate")
source("circuit", "circuit", "plate")
source("local-a", "gear", "ore-a", 1, "gear")
source("local-b", "gear", "ore-b", 2, "gear")
source("alternative-a", "gear", "alternate-ore", 1)
data.raw.fluid["ore-b"] = { type = "fluid", name = "ore-b" }
source("test-product", "test-product", "plate")
local complex = source("a-complex", "test-product", "ore-a", 3, "test-product")
complex.ingredients = { entry("ore-a"), entry("ore-b"), { type = "fluid", name = "ore-b", amount = 10 } }
local simple = source("z-simple", "test-product", "alternate-ore", 3, "test-product")
simple.ingredients = { entry("alternate-ore", 2), entry("alternate-ore", 2) }
for name, generated in pairs(recycling.generate(data.raw, { ["gear-recycling"] = "gear", ["test-product-recycling"] = "test-product" })) do
    data.raw.recipe[name] = generated.recipe
end
recycling.prepare_planetary()
local old_raw = table.deepcopy(data.raw)
local function active(item, room)
    local found
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.recycling_origin ~= nil and recipe.ingredients[1].name == item and surface_sets.accepted(recipe)[room] ~= nil then
            assert(found == nil, "two recycling candidates accept the same physical item on " .. room)
            found = recipe
        end
    end
    return assert(found, "missing recycling for " .. item .. " on " .. room)
end
assert(active("gear", "planet: world-1").recycling_origin.source == "local-a")
assert(active("gear", "planet: world-2").recycling_origin.source == "local-b")
assert(active("gear", "planet: world-3").recycling_origin.source == "gear")
assert(active("gear", "planet: world-1").results[1].name == "ore-a")
assert(active("gear", "planet: world-2").results[1].name == "ore-b")
print("ok - local canonical sources override shared recycling only on their planets")
assert(data.raw.recipe["propertyrandomizer-local-recycling-a-complex"].recycling_origin.original_ingredient_count == 3)
assert(data.raw.recipe["propertyrandomizer-local-recycling-z-simple"].recycling_origin.original_ingredient_count == 1)
assert(active("test-product", "planet: world-3").recycling_origin.source == "z-simple")
-- Later ingredient randomization must not reverse the canonical choice.
complex.ingredients = { entry("ore-a", 4) }
simple.ingredients = { entry("ore-a", 4), entry("ore-b", 4), entry("alternate-ore", 4) }
print("ok - fewer original distinct materials wins before name order, including fluids and duplicate rows")

data.raw.recipe["local-a"].results[1].name = "circuit"
-- This alternate follows the same local production position through reflection.
data.raw.recipe["alternative-a"].results[1].name = "circuit"
recycling.regenerate(old_raw)
assert(active("test-product", "planet: world-3").recycling_origin.source == "z-simple")
assert(active("circuit", "planet: world-1").recycling_origin.source == "local-a")
assert(active("gear", "planet: world-1").recycling_origin.source == "gear")
assert(active("gear", "planet: world-2").recycling_origin.source == "local-b")
local before = {}
for name, recipe in pairs(data.raw.recipe) do
    if recipe.recycling_origin ~= nil then
        before[name] = recipe.ingredients[1].name .. ":" .. recipe.results[1].name
    end
end
recycling.regenerate(old_raw)
for name, expected in pairs(before) do
    local recipe = data.raw.recipe[name]
    assert(recipe.ingredients[1].name .. ":" .. recipe.results[1].name == expected)
end
print("ok - regeneration follows renamed local products, restores the fallback, and is repeatable")

data.raw.furnace = { recycler = { crafting_categories = { "recycling" } } }
assert(#furnace_selection.collisions(data.raw.recipe) == 0)
local a = active("gear", "planet: world-1")
local b = active("gear", "planet: world-2")
b.recycling_rooms["planet: world-1"] = true
assert(#furnace_selection.collisions(data.raw.recipe) > 0)
b.recycling_rooms["planet: world-1"] = nil
print("ok - disjoint recycling variants do not collide, but overlapping variants do")

local scopes, ambiguous = recycling.planetary_scopes(data.raw, function(_, _, product) return product end, surface_sets.accepted)
assert(#ambiguous == 0)
local candidate = data.raw.recipe["propertyrandomizer-local-recycling-alternative-a"]
candidate.recycling_origin.preferred = true
scopes, ambiguous = recycling.planetary_scopes(data.raw, function(_, _, product) return product end, surface_sets.accepted)
assert(#ambiguous > 0, "different equally canonical results need an ambiguity report")
assert(scopes[candidate.name]["planet: world-1"], "equal original counts fall back to stable name order")
print("ok - genuinely different equally ranked alternatives are reported")
