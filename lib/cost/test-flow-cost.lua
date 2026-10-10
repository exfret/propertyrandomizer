-- Plain-Lua regression tests for lib/cost/flow-cost.lua (not loaded by the mod)
-- Run from the mod root: lua lib/cost/test-flow-cost.lua

-- Stand-ins for the Factorio environment
defines = {
    prototypes = {
        item = {
            item = 0,
        },
    },
}

local constants = require("helper-tables/constants")
local flow_cost = require("lib/cost/flow-cost")

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

-- Ore smelts into plates; the raw costs also price a deposit copy of the ore that's gone from the game, as the load's table does once copies are their materials again
data = {
    raw = {
        item = {
            ore = {
                type = "item",
                name = "ore",
            },
            plate = {
                type = "item",
                name = "plate",
            },
        },
        fluid = {},
        recipe = {
            smelt = {
                name = "smelt",
                ingredients = {
                    entry("ore", 1),
                },
                results = {
                    entry("plate", 1),
                },
            },
        },
    },
}
local raw_costs = {
    ["item-ore"] = 1,
    ["item-propertyrandomizer-ore-from-elsewhere"] = 1,
}

test("costing from a raw cost of a material the game no longer has fails", function()
    assert(not pcall(flow_cost.determine_recipe_item_cost, raw_costs, constants.cost_params.time, constants.cost_params.complexity))
end)

test("present raw costs leave out materials the game no longer has, and cost the rest", function()
    local maps = flow_cost.construct_item_recipe_maps()
    local present = flow_cost.present_raw_costs(raw_costs, maps)
    assert(present["item-ore"] == 1 and present["item-propertyrandomizer-ore-from-elsewhere"] == nil)
    local costs = flow_cost.determine_recipe_item_cost(present, constants.cost_params.time, constants.cost_params.complexity, {
        item_recipe_maps = maps,
    }).material_to_cost
    assert(costs["item-plate"] ~= nil and costs["item-plate"] > costs["item-ore"])
end)

print(num_passed .. " flow cost tests passed")
