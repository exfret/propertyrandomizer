-- Run from the mod root: lua lib/cost/test-staged-recipes.lua
defines = {
    prototypes = {
        item = {item = 0},
        entity = {},
        equipment = {},
    },
}

local recycling = require("lib/recycling")
local staged_recipes = require("lib/cost/staged-recipes")
local flow_cost = require("lib/cost/flow-cost")

local function entry(name, amount)
    return {type = "item", name = name, amount = amount}
end

local raw = {
    item = {},
    fluid = {},
    recipe = {
        make = {
            type = "recipe",
            name = "make",
            ingredients = {entry("ore", 4)},
            results = {entry("plate", 1)},
            energy_required = 2,
        },
    },
}
for _, name in pairs({"ore", "replacement", "plate"}) do
    raw.item[name] = {type = "item", name = name, stack_size = 100}
end
for name, generated in pairs(recycling.generate(raw)) do
    raw.recipe[name] = generated.recipe
end
data = {raw = raw}
local overrides = {}
for name, recipe in pairs(raw.recipe) do
    overrides[name] = recipe.ingredients
end
overrides.make = {"blacklisted"}
local world = staged_recipes.new(raw, overrides)
local function price()
    return flow_cost.determine_recipe_item_cost({["item-plate"] = 1, ["item-replacement"] = 1}, 0.07, 0.01, {
        ing_overrides = overrides,
        recipe_prototypes = world.recipes,
        track_resources = {},
    })
end
assert(overrides["plate-recycling"][1] == "blacklisted")
assert(price().material_to_cost["item-ore"] == nil)
local incremental = price()
local maps = flow_cost.construct_item_recipe_maps(overrides, false, world.recipes)
print("ok - a pending source cannot supply its old ingredients through recycling")

overrides.make = {entry("replacement", 8)}
local updated = world.update("make")
assert(#updated == 2)
local result = world.recipes["plate-recycling"].results[1]
assert(result.name == "replacement" and result.amount == 2)
local costs = price()
assert(costs.material_to_cost["item-ore"] == nil)
assert(math.abs(costs.material_to_cost["item-replacement"] - 0.509375) < 1e-6)
print("ok - flow costing uses current reverse outputs rather than the original prototypes")

flow_cost.update_item_recipe_maps(maps, updated, overrides, true)
flow_cost.update_recipe_item_costs(incremental, {"make", "plate-recycling"}, 1000,
    {["item-plate"] = 1, ["item-replacement"] = 1}, 0.07, 0.01, {
        ing_overrides = overrides,
        recipe_prototypes = world.recipes,
        item_recipe_maps = maps,
        track_resources = {},
    })
assert(incremental.material_to_cost["item-ore"] == nil)
assert(math.abs(incremental.material_to_cost["item-replacement"] - costs.material_to_cost["item-replacement"]) < 1e-6)
assert(maps.recipe_to_material["plate-recycling"]["item-ore"] == nil)
print("ok - incremental pricing and dependency maps follow the regenerated outputs")

assert(data.raw.recipe.make.ingredients[1].name == "ore")
assert(data.raw.recipe["plate-recycling"].results[1].name == "ore")
print("ok - staged pricing does not modify the game prototypes")
