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

print(num_passed .. " tests passed")
