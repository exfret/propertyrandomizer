-- Plain-Lua regression tests for monotone matching's resource slots (not loaded by the mod)
-- Run from the mod root: lua randomizations/graph/unified/skeleton/test-monotone-matching.lua
-- A resource slot should mine something new whenever the matching allows it: an interesting trav other than its own identity

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
-- A small deterministic stand-in for lib/random/rng, whose hash needs Factorio's bit32
local rng_states = {}
local rng = {}
rng.value = function(rng_key)
    if rng_states[rng_key] == nil then
        local seed = 1
        for i = 1, #rng_key do
            seed = (seed * 31 + string.byte(rng_key, i)) % 2147483647
        end
        rng_states[rng_key] = seed
        -- Similar keys give similar seeds, so mix them first (as the real rng does)
        for _ = 1, 3 do
            rng.value(rng_key)
        end
    end
    local state = (rng_states[rng_key] * 48271) % 2147483647
    rng_states[rng_key] = state
    return state / 2147483647
end
rng.int = function(rng_key, max)
    return math.floor(rng.value(rng_key) * max) + 1
end
rng.shuffle = function(rng_key, tbl)
    for i = #tbl, 2, -1 do
        local j = rng.int(rng_key, i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
end
package.loaded["lib/random/rng"] = rng
package.loaded["lib/logic/init"] = { type_info = {} }
package.loaded["randomizations/graph/unified/skeleton/protection"] = {}

local gutils = require("lib/graph/graph-utils")
local matching = require("randomizations/graph/unified/skeleton/monotone-matching")

local key = gutils.key

-- Toy first pass: each name gets an item slot and its own trav ("<name>-trav"), with every item admissible everywhere unless needs say otherwise
-- resources: names whose slots are resource slots; interesting: names whose identities are interesting
local function toy(names, resources, interesting)
    local graph = {
        nodes = {},
        edges = {},
    }
    for _, name in pairs(names) do
        graph.nodes[key("item", name)] = {
            type = "item",
            name = name,
            old_trav = key("item", name .. "-trav"),
        }
        graph.nodes[key("item", name .. "-trav")] = {
            type = "item",
            name = name .. "-trav",
            old_slot = key("item", name),
        }
    end
    local params = {
        unconnected_graph = graph,
        pair_ok = function(slot, trav)
            return true
        end,
        is_launchable = function(trav_key)
            return true
        end,
        is_resource_slot = function(slot_key)
            return resources[graph.nodes[slot_key].name] == true
        end,
        is_interesting = function(trav_key)
            return interesting[graph.nodes[graph.nodes[trav_key].old_slot].name] == true
        end,
    }
    return graph, params
end

-- The identity matching, with some pairs changed: moves maps slot name --> trav name
local function assignment_of(names, moves)
    local assignment = {}
    for _, name in pairs(names) do
        assignment[key("item", name)] = key("item", (moves[name] or name) .. "-trav")
    end
    return assignment
end

-- Runs the matching with many rng keys, and returns how often slot name got trav name
local NUM_KEYS = 200
local function count_matches(graph, params, needs, sort_info, assignment, slot_name, trav_name)
    local count = 0
    for i = 1, NUM_KEYS do
        local slot_match = matching.random_matching(params, graph, sort_info, needs, {}, assignment, "test-monotone-matching-" .. i)
        if slot_match[key("item", slot_name)] == key("item", trav_name .. "-trav") then
            count = count + 1
        end
    end
    return count
end

local no_ranks = { node_to_context_inds = {} }

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

test("a resource slot doesn't count its own interesting identity as new", function()
    -- The fuel ore's identity is interesting (like coal, a fuel), so only the widget can make it mine something new
    local names = { "fuel-ore", "widget", "filler" }
    local graph, params = toy(names, { ["fuel-ore"] = true }, { ["fuel-ore"] = true, widget = true })
    assert(count_matches(graph, params, {}, no_ranks, assignment_of(names, {}), "fuel-ore", "widget") == NUM_KEYS)
end)

test("a resource slot always gets a new trav when one fits", function()
    local names = { "plain-ore", "widget", "filler" }
    local graph, params = toy(names, { ["plain-ore"] = true }, { widget = true })
    assert(count_matches(graph, params, {}, no_ranks, assignment_of(names, {}), "plain-ore", "widget") == NUM_KEYS)
end)

test("a resource slot keeps the new trav an earlier round gave it", function()
    -- The plain ore mines the snack from an earlier round, and the widget or gadget would fit just as well
    local names = { "plain-ore", "snack", "widget", "gadget", "filler" }
    local graph, params = toy(names, { ["plain-ore"] = true }, { snack = true, widget = true, gadget = true })
    local assignment = assignment_of(names, { ["plain-ore"] = "snack", snack = "plain-ore" })
    assert(count_matches(graph, params, {}, no_ranks, assignment, "plain-ore", "snack") == NUM_KEYS)
end)

test("a resource slot picks its new trav at random, not the early identity that has nowhere else to go", function()
    -- The kiln's identity is needed in context C, where only the ore's slot and its own come before it, so the ore's slot is its only other admissible one
    local names = { "plain-ore", "kiln", "widget", "gadget", "snack", "filler" }
    local graph, params = toy(names, { ["plain-ore"] = true }, { kiln = true, widget = true, gadget = true, snack = true })
    local needs = {
        [key("item", "kiln-trav")] = { C = true },
    }
    local sort_info = {
        node_to_context_inds = {
            [key("item", "plain-ore")] = { C = 1 },
            [key("item", "kiln")] = { C = 2 },
            [key("item", "kiln-trav")] = { C = 3 },
        },
    }
    local assignment = assignment_of(names, {})
    for _, name in pairs({ "widget", "gadget", "snack" }) do
        assert(count_matches(graph, params, needs, sort_info, assignment, "plain-ore", name) >= NUM_KEYS / 10)
    end
    assert(count_matches(graph, params, needs, sort_info, assignment, "plain-ore", "kiln") < NUM_KEYS / 2)
end)

test("a trav pinned to its resource slot moves to another resource slot to free its own", function()
    -- The fuel ore's identity is needed in context C, where only the two ore slots come before it, so it can only move between them
    -- The other ore already mines the snack from an earlier round, and can take the fuel ore's identity instead, so the fuel ore can take the widget or snack
    local names = { "fuel-ore", "other-ore", "widget", "snack" }
    local graph, params = toy(names, { ["fuel-ore"] = true, ["other-ore"] = true }, { ["fuel-ore"] = true, widget = true, snack = true })
    local assignment = assignment_of(names, { ["other-ore"] = "snack", snack = "other-ore" })
    local needs = {
        [key("item", "fuel-ore-trav")] = { C = true },
    }
    local sort_info = {
        node_to_context_inds = {
            [key("item", "fuel-ore")] = { C = 1 },
            [key("item", "other-ore")] = { C = 2 },
            [key("item", "fuel-ore-trav")] = { C = 3 },
        },
    }
    local both_new = 0
    for i = 1, NUM_KEYS do
        local slot_match = matching.random_matching(params, graph, sort_info, needs, {}, assignment, "test-monotone-matching-" .. i)
        local fuel_ore = slot_match[key("item", "fuel-ore")]
        if (fuel_ore == key("item", "widget-trav") or fuel_ore == key("item", "snack-trav")) and slot_match[key("item", "other-ore")] == key("item", "fuel-ore-trav") then
            both_new = both_new + 1
        end
    end
    assert(both_new == NUM_KEYS)
end)

test("a resource slot keeps its identity when every perfect matching needs that", function()
    -- The widget needs context C, where only its own slot comes before it, so it can't move and the ore can't take it
    local names = { "plain-ore", "widget" }
    local graph, params = toy(names, { ["plain-ore"] = true }, { widget = true })
    local needs = {
        [key("item", "widget-trav")] = { C = true },
    }
    local sort_info = {
        node_to_context_inds = {
            [key("item", "widget")] = { C = 1 },
            [key("item", "widget-trav")] = { C = 2 },
        },
    }
    assert(count_matches(graph, params, needs, sort_info, assignment_of(names, {}), "plain-ore", "plain-ore") == NUM_KEYS)
end)

test("a trav a debt goal wants somewhere the game doesn't have it moves to a slot the game has there", function()
    -- Only the local ore's slot is reachable in context C, where a debt goal uses the lost ore's identity
    local names = { "lost-ore", "local-ore", "filler" }
    local graph, params = toy(names, {}, {})
    local sort_info = {
        node_to_context_inds = {
            [key("item", "local-ore")] = { C = 1 },
        },
    }
    local wants = {
        [key("item", "lost-ore-trav")] = { C = true },
    }
    for i = 1, NUM_KEYS do
        local slot_match = matching.random_matching(params, graph, sort_info, {}, {}, assignment_of(names, {}), "test-monotone-matching-" .. i, wants)
        assert(slot_match[key("item", "local-ore")] == key("item", "lost-ore-trav"))
    end
end)

test("a wanted trav whose needs pin it stays where it is", function()
    -- The lost ore's identity is also needed in context D, where only its own slot comes before it
    local names = { "lost-ore", "local-ore", "filler" }
    local graph, params = toy(names, {}, {})
    local sort_info = {
        node_to_context_inds = {
            [key("item", "local-ore")] = { C = 1 },
            [key("item", "lost-ore")] = { D = 2 },
            [key("item", "lost-ore-trav")] = { D = 3 },
        },
    }
    local needs = {
        [key("item", "lost-ore-trav")] = { D = true },
    }
    local wants = {
        [key("item", "lost-ore-trav")] = { C = true },
    }
    for i = 1, NUM_KEYS do
        local slot_match = matching.random_matching(params, graph, sort_info, needs, {}, assignment_of(names, {}), "test-monotone-matching-" .. i, wants)
        assert(slot_match[key("item", "lost-ore")] == key("item", "lost-ore-trav"))
    end
end)

print(num_passed .. " tests passed")
