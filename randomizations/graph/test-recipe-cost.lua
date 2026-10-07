-- Plain-Lua regression tests for randomizations/graph/recipe-cost.lua's ingredient search (not loaded by the mod)
-- Run from the mod root: lua randomizations/graph/test-recipe-cost.lua

-- Stand-ins for the Factorio environment
function table.deepcopy(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end
function log(msg) end
config = {
    seed = 0,
}
randomization_info = {
    options = {
        cost = {
            major_raw_resources = { "item-ore", "item-coal" },
        },
    },
}
-- A small deterministic stand-in for lib/random/rng, whose hash needs Factorio's bit32 (as in skeleton/test-monotone-matching.lua)
local rng_states = {}
local rng = {}
rng.value = function(rng_key)
    if rng_states[rng_key] == nil then
        local seed = 1
        for i = 1, #rng_key do
            seed = (seed * 31 + string.byte(rng_key, i)) % 2147483647
        end
        rng_states[rng_key] = seed
    end
    local state = (rng_states[rng_key] * 48271) % 2147483647
    rng_states[rng_key] = state
    return state / 2147483647
end
rng.int = function(rng_key, max)
    return math.floor(rng.value(rng_key) * max) + 1
end
package.loaded["lib/random/rng"] = rng
-- The search only uses the old logic's key function
package.loaded["lib/old-logic/build-graph"] = {
    key = function(node_type, node_name)
        return node_type .. ": " .. node_name
    end,
}

local constants = require("helper-tables/constants")
local cost_lib = require("randomizations/graph/recipe-cost")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function near(a, b)
    return math.abs(a - b) <= 1e-9 * math.max(1, math.abs(a), math.abs(b))
end

-- Material costs where item "c<k>" costs aggregate[k], with ore and coal shares of it; lookups of aggregate costs are recorded in looked_up
local function costs_for(aggregate, looked_up)
    local aggregate_cost = {}
    local ore = {}
    local coal = {}
    for k, cost in pairs(aggregate) do
        aggregate_cost["item-c" .. k] = cost
        ore["item-c" .. k] = cost * 0.25
        coal["item-c" .. k] = cost * 0.75
    end
    local recorded = aggregate_cost
    if looked_up ~= nil then
        recorded = setmetatable({}, {
            __index = function(_, id)
                looked_up[id] = true
                return aggregate_cost[id]
            end,
        })
    end
    return {
        aggregate_cost = recorded,
        resource_costs = {
            ["item-ore"] = ore,
            ["item-coal"] = coal,
        },
    }
end

local function candidates(count)
    local list = {}
    for k = 1, count do
        table.insert(list, {
            type = "item",
            name = "c" .. k,
        })
    end
    return list
end

local function count(set)
    local num = 0
    for _, _ in pairs(set) do
        num = num + 1
    end
    return num
end

test("an ingredient amount's costs match adding up every ingredient, and the ingredient itself is left alone", function()
    local material_to_costs = costs_for({ 3, 0.7, 12.5, 1.1 })
    local target = {
        aggregate_cost = 40,
        complexity_cost = 0,
        resource_costs = {
            ["item-ore"] = 10,
            ["item-coal"] = 30,
        },
    }
    for ing_ind = 1, 4 do
        local ings = {}
        for k = 1, 4 do
            table.insert(ings, {
                type = "item",
                name = "c" .. k,
                amount = k + 1,
            })
        end
        local before = ings[ing_ind].amount
        local info = cost_lib.optimize_single_ing(target, material_to_costs, ings, ing_ind, {})
        assert(ings[ing_ind].amount == before)
        ings[ing_ind].amount = info.best_amount
        local added_up = cost_lib.get_costs_from_ings(material_to_costs, ings)
        assert(near(info.costs.aggregate_cost, added_up.aggregate_cost))
        for _, resource_id in pairs({ "item-ore", "item-coal" }) do
            assert(near(info.costs.resource_costs[resource_id], added_up.resource_costs[resource_id]))
        end
    end
end)

test("a search stops at the first candidate it tries once its points are good enough", function()
    -- Any candidate at 2 of them makes the target exactly
    local aggregate = {}
    for k = 1, 40 do
        aggregate[k] = 1
    end
    local looked_up = {}
    local target = {
        aggregate_cost = 2,
        complexity_cost = 0,
        resource_costs = {
            ["item-ore"] = 0.5,
            ["item-coal"] = 1.5,
        },
    }
    local result = cost_lib.search_for_ings(candidates(40), 1, target, costs_for(aggregate, looked_up), {})
    assert(result.points <= constants.target_cost_threshold)
    -- The random start and the one candidate tried
    assert(count(looked_up) == 2, "looked at " .. count(looked_up) .. " candidates")
end)

test("a search no candidate can satisfy stops once it stops making real progress", function()
    -- Every candidate is far too dear even once, each a little cheaper than the one before, so each later one is a tiny improvement
    local aggregate = {}
    for k = 1, 100 do
        aggregate[k] = 100 - 0.001 * k
    end
    local looked_up = {}
    local target = {
        aggregate_cost = 1,
        complexity_cost = 0,
        resource_costs = {
            ["item-ore"] = 0.25,
            ["item-coal"] = 0.75,
        },
    }
    local result = cost_lib.search_for_ings(candidates(100), 1, target, costs_for(aggregate, looked_up), {})
    assert(result.points > constants.target_cost_threshold)
    -- The random start, then the candidates tried before the stall limit
    local num = count(looked_up)
    assert(num >= constants.ing_search_stall_candidates and num <= constants.ing_search_stall_candidates + 1, "looked at " .. num .. " candidates")
end)

-- The forms of slots, as recipe shapes name them
local FLUID = "fluid"
local ITEM = "item"

-- Material costs with fluids "f<k>" at fluid_costs[k] next to the items of costs_for
local function costs_with_fluids(aggregate, fluid_costs)
    local costs = costs_for(aggregate)
    for k, cost in pairs(fluid_costs) do
        costs.aggregate_cost["fluid-f" .. k] = cost
        costs.resource_costs["item-ore"]["fluid-f" .. k] = cost * 0.25
        costs.resource_costs["item-coal"]["fluid-f" .. k] = cost * 0.75
    end
    return costs
end

test("slot forms decide how many slots there are and which take a fluid, kept ingredients after them", function()
    local aggregate = {}
    for k = 1, 6 do
        aggregate[k] = 1
    end
    local material_to_costs = costs_with_fluids(aggregate, { 1, 1, 1 })
    local pool = candidates(6)
    for k = 1, 3 do
        table.insert(pool, {
            type = "fluid",
            name = "f" .. k,
        })
    end
    local target = {
        aggregate_cost = 3,
        complexity_cost = 0,
        resource_costs = {
            ["item-ore"] = 0.75,
            ["item-coal"] = 2.25,
        },
    }
    -- The count passed is ignored in favor of the forms
    local result = cost_lib.search_for_ings(pool, 99, target, material_to_costs, {
        slot_forms = { FLUID, ITEM, ITEM },
        unrandomized_ings = {},
    })
    assert(type(result) ~= "string", result)
    assert(#result.ings == 3)
    assert(result.ings[1].type == "fluid" and result.ings[2].type == "item" and result.ings[3].type == "item")
    assert(#result.inds == 3)
    local kept = {
        type = "item",
        name = "c6",
        amount = 2,
    }
    result = cost_lib.search_for_ings(pool, 99, target, material_to_costs, {
        slot_forms = { FLUID },
        unrandomized_ings = { kept },
    })
    assert(#result.ings == 2 and result.ings[1].type == "fluid" and result.ings[2].name == "c6")
    result = cost_lib.search_for_ings(pool, 99, target, material_to_costs, {
        slot_forms = {},
        unrandomized_ings = { kept },
    })
    assert(#result.ings == 1 and result.ings[1].name == "c6", "no slots means only the kept ingredients")
    -- Without forms, the count and the fluid index are what they were
    result = cost_lib.search_for_ings(pool, 2, target, material_to_costs, {
        is_fluid_index = { [2] = true },
        unrandomized_ings = {},
    })
    assert(#result.ings == 2 and result.ings[1].type == "item" and result.ings[2].type == "fluid")
end)

test("a candidate fills a slot by the form it says it has in the game, not its type", function()
    -- Items and fluids trading positions: the pool has an item position holding a fluid identity (form fluid) and a fluid position holding an item identity (form item)
    local aggregate = {}
    for k = 1, 4 do
        aggregate[k] = 1
    end
    local material_to_costs = costs_with_fluids(aggregate, { 1, 1 })
    local pool = candidates(4)
    pool[1].form = FLUID
    table.insert(pool, {
        type = "fluid",
        name = "f1",
        form = ITEM,
    })
    table.insert(pool, {
        type = "fluid",
        name = "f2",
    })
    local target = {
        aggregate_cost = 2,
        complexity_cost = 0,
        resource_costs = {
            ["item-ore"] = 0.5,
            ["item-coal"] = 1.5,
        },
    }
    for _ = 1, 8 do
        local result = cost_lib.search_for_ings(pool, 99, target, material_to_costs, {
            slot_forms = { FLUID, FLUID },
            unrandomized_ings = {},
        })
        assert(type(result) ~= "string", result)
        -- Only c1 (form fluid) and f2 (a fluid) fit fluid slots; f1 says it's an item in the game
        for _, ing in pairs(result.ings) do
            assert(ing.name == "c1" or ing.name == "f2", ing.name)
            assert((ing.form or ing.type) == FLUID)
        end
    end
    -- The amount cap follows the form too
    local material_to_costs_cheap = costs_with_fluids({ 0.001 }, { 0.001 })
    local dear = {
        aggregate_cost = 100,
        complexity_cost = 0,
        resource_costs = {
            ["item-ore"] = 25,
            ["item-coal"] = 75,
        },
    }
    local as_fluid = {
        {
            type = "item",
            name = "c1",
            amount = 1,
            form = FLUID,
        },
    }
    assert(cost_lib.optimize_single_ing(dear, material_to_costs_cheap, as_fluid, 1, { fluid_amount_cap = 1000 }).best_amount == 1000)
end)

test("a fluid's amount stops at the cap, an item's doesn't", function()
    local material_to_costs = costs_with_fluids({ 0.001 }, { 0.001 })
    local target = {
        aggregate_cost = 100,
        complexity_cost = 0,
        resource_costs = {
            ["item-ore"] = 25,
            ["item-coal"] = 75,
        },
    }
    local fluid = {
        {
            type = "fluid",
            name = "f1",
            amount = 1,
        },
    }
    local uncapped = cost_lib.optimize_single_ing(target, material_to_costs, fluid, 1, {})
    assert(uncapped.best_amount > 1000, "uncapped picks " .. uncapped.best_amount)
    local capped = cost_lib.optimize_single_ing(target, material_to_costs, fluid, 1, { fluid_amount_cap = 1000 })
    assert(capped.best_amount == 1000, "capped picks " .. capped.best_amount)
    local item = {
        {
            type = "item",
            name = "c1",
            amount = 1,
        },
    }
    local item_info = cost_lib.optimize_single_ing(target, material_to_costs, item, 1, { fluid_amount_cap = 1000 })
    assert(item_info.best_amount > 1000, "items aren't capped")
    -- Through the search too
    local fluid_pool = {
        {
            type = "fluid",
            name = "f1",
        },
    }
    local result = cost_lib.search_for_ings(fluid_pool, 1, target, material_to_costs, {
        is_fluid_index = { true },
        unrandomized_ings = {},
        fluid_amount_cap = 1000,
    })
    assert(result.ings[1].amount <= 1000, "the search picked " .. result.ings[1].amount)
end)

print(num_passed .. " tests passed")
