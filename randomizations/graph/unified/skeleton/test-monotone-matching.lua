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
package.loaded["lib/logic/init"] = {
    type_info = {},
    contexts = {},
}
package.loaded["lib/logic/state"] = package.loaded["lib/logic/init"]
package.loaded["randomizations/graph/unified/skeleton/protection"] = {}

local gutils = require("lib/graph/graph-utils")
local matching = require("randomizations/graph/unified/skeleton/monotone-matching")
local top = require("lib/graph/context-sort")
local operation = require("lib/logic/operation-requirements")
local protection = require("randomizations/graph/unified/skeleton/protection")

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

test("shared supply used by a recipe position does not pin the old material", function()
    local graph = { nodes = {}, edges = {}, sources = {} }
    local source = gutils.add_node(graph, "item", "test-source", { op = "OR", slot = true })
    local identity = gutils.add_node(graph, "item", "test-identity", { op = "OR", trav = true })
    local alias = gutils.add_node(graph, "item", "test-alias", { op = "OR", trav = true })
    local position = gutils.add_node(graph, "item", "test-position", { op = "OR", slot = true })
    local recipe = gutils.add_node(graph, "recipe", "test-consumer", { op = "AND" })
    gutils.add_edge(graph, source, identity)
    gutils.add_edge(graph, identity, alias, { shared_identity = true })
    gutils.add_edge(graph, alias, position, { identity_supply = true })
    gutils.add_edge(graph, position, recipe)
    local assignment = { [key(source)] = key(identity), [key(position)] = key(alias) }
    local sorted = {}
    for i, node in pairs({ source, identity, alias, position, recipe }) do
        sorted[i] = { node_key = key(node), context = "test-room" }
    end
    local closure = { true, true, true, true, true }
    local support = { {}, { 1 }, { 2 }, { 3 }, { 4 } }
    local needs, _, positions = matching.needs_from_proof(graph, { sorted = sorted }, closure, support, assignment, {})
    assert(needs[key(identity)] == nil, "the recipe follows the position's replacement, not the old shared material")
    assert(positions[key(position)]["test-room"] == 5, "the replacement still needs supply before its consumer")
    local mechanic = gutils.add_node(graph, "test-mechanic", "test-use", { op = "OR" })
    gutils.add_edge(graph, alias, mechanic)
    sorted[6] = { node_key = key(mechanic), context = "test-room" }
    closure[6] = true
    support[6] = { 3 }
    needs = matching.needs_from_proof(graph, { sorted = sorted }, closure, support, assignment, {})
    assert(needs[key(identity)]["test-room"] == 6, "the identity is needed by the actual mechanic's deadline, not its first arrival")
end)

test("a resource slot doesn't count its own interesting identity as new", function()
    -- The fuel ore's identity is interesting (like coal, a fuel), so only the widget can make it mine something new
    local names = { "fuel-ore", "widget", "filler" }
    local graph, params = toy(names, { ["fuel-ore"] = true }, { ["fuel-ore"] = true, widget = true })
    assert(count_matches(graph, params, {}, no_ranks, assignment_of(names, {}), "fuel-ore", "widget") == NUM_KEYS)
end)

test("copies of the original ore do not count as new products", function()
    local names = {
        "ore-a",
        "ore-a-copy",
        "widget",
    }
    local graph, params = toy(names, { ["ore-a"] = true }, {
        ["ore-a"] = true,
        ["ore-a-copy"] = true,
        widget = true,
    })
    params.is_new_resource_pair = function(slot_key, trav_key)
        return graph.nodes[graph.nodes[trav_key].old_slot].name == "widget"
    end
    assert(count_matches(graph, params, {}, no_ranks, assignment_of(names, {}), "ore-a", "widget") == NUM_KEYS)
end)

test("a resource slot always gets a new trav when one fits", function()
    local names = { "plain-ore", "widget", "filler" }
    local graph, params = toy(names, { ["plain-ore"] = true }, { widget = true })
    assert(count_matches(graph, params, {}, no_ranks, assignment_of(names, {}), "plain-ore", "widget") == NUM_KEYS)
end)

test("resource matching can give up one changed deposit to change two others", function()
    local names = { "r1", "r2", "r3", "a", "b" }
    local graph, params = toy(names, { r1 = true, r2 = true, r3 = true }, { a = true, b = true })
    local allowed = {
        r1 = { a = true },
        r2 = { b = true },
        r3 = { a = true },
        a = { r1 = true, r2 = true },
        b = { r3 = true },
    }
    params.pair_ok = function(slot, trav)
        local name = graph.nodes[trav.old_slot].name
        return slot.name == name or (allowed[slot.name] or {})[name] == true
    end
    -- Keeping a at r1 allows only one changed deposit.
    -- The cycle r2 <- b <- r3 <- a <- r2 changes two, while r1 returns home.
    local assignment = assignment_of(names, { r1 = "a", a = "r1" })
    for seed = 1, 20 do
        local result = matching.random_matching(params, graph, no_ranks, {}, {}, assignment, "resource-optimum-" .. seed)
        assert(result[key("item", "r2")] == key("item", "b-trav"))
        assert(result[key("item", "r3")] == key("item", "a-trav"))
    end
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

test("a trav's needs are checked where its connection starts, like a carried entity's kill", function()
    -- The early slot comes before the carried identity in context C, but connecting them starts at a gate that only comes after it
    local names = { "early", "carried", "filler" }
    local graph, params = toy(names, {}, {})
    local sort_info = {
        node_to_context_inds = {
            [key("item", "early")] = { C = 1 },
            [key("item", "carried")] = { C = 2 },
            [key("item", "carried-trav")] = { C = 3 },
            [key("item", "filler")] = { C = 4 },
            [key("item", "gate")] = { C = 5 },
        },
    }
    local needs = {
        [key("item", "carried-trav")] = { C = true },
    }
    local assignment = assignment_of(names, {})
    assert(count_matches(graph, params, needs, sort_info, assignment, "early", "carried") > 0)
    params.connection = function(slot_key, trav_key)
        if slot_key == key("item", "early") and trav_key == key("item", "carried-trav") then
            return {
                base = key("item", "gate"),
            }
        end
        return nil
    end
    assert(count_matches(graph, params, needs, sort_info, assignment, "early", "carried") == 0)
end)

test("a slot connects to its trav where the connection starts, with the connection's abilities", function()
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local node_keys = {
        key("base", "slot-base"),
        key("head", "trav-head"),
        key("base", "gate"),
        key("orand", "slot"),
        key("orand", "slot-trav"),
    }
    for _, node_key in pairs(node_keys) do
        local parts = gutils.deconstruct(node_key)
        local node = gutils.add_node(graph, parts.type, parts.name)
        node.op = "AND"
    end
    local params = {
        slot_to_base = {
            [key("orand", "slot")] = graph.nodes[key("base", "slot-base")],
        },
        trav_to_head = {
            [key("orand", "slot-trav")] = graph.nodes[key("head", "trav-head")],
        },
    }
    local assignment = {
        [key("orand", "slot")] = key("orand", "slot-trav"),
    }
    matching.connect(graph, params, assignment)
    assert(graph.edges[gutils.ekey({
        start = key("base", "slot-base"),
        stop = key("head", "trav-head"),
    })] ~= nil)
    params.connection = function(slot_key, trav_key)
        return {
            base = key("base", "gate"),
            abilities = {
                [2] = false,
            },
        }
    end
    matching.connect(graph, params, assignment)
    local edge = graph.edges[gutils.ekey({
        start = key("base", "gate"),
        stop = key("head", "trav-head"),
    })]
    assert(edge ~= nil and edge.abilities[2] == false)
end)

test("an operation rejection refines the proposal before falling back to identity", function()
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local params = {
        unconnected_graph = graph,
        slot_keys = {},
        slot_to_base = {},
        trav_to_head = {},
        pair_ok = function() return true end,
        rounds = 1,
        operations = {},
    }
    for i = 1, 3 do
        local slot = gutils.add_node(graph, "item", "position-" .. i, { op = "AND" })
        local trav = gutils.add_node(graph, "item", "identity-" .. i, {
            op = "OR",
            trav = true,
        })
        slot.old_trav = key(trav)
        trav.old_slot = key(slot)
        table.insert(params.slot_keys, key(slot))
        params.slot_to_base[key(slot)] = slot
        params.trav_to_head[key(trav)] = trav
    end
    local original_sort = top.sort
    local original_matching = operation.matching
    local original_protection = protection.planet_locked_recipe_contexts
    local original_rng_key = rng.key
    local sorts = 0
    local rejected_slot
    local rejected_trav
    rng.key = function(value) return value.id end
    protection.planet_locked_recipe_contexts = function() return {} end
    top.sort = function(proposal)
        sorts = sorts + 1
        if sorts == 2 then
            for _, slot_key in pairs(params.slot_keys) do
                for edge_key, _ in pairs(proposal.nodes[slot_key].dep) do
                    local trav_key = proposal.edges[edge_key].stop
                    if trav_key ~= proposal.nodes[slot_key].old_trav then
                        rejected_slot = slot_key
                        rejected_trav = trav_key
                        break
                    end
                end
                if rejected_slot ~= nil then
                    break
                end
            end
            assert(rejected_slot ~= nil, "the first proposal should randomize an identity")
        end
        return {
            sorted = {},
            node_to_context_inds = {},
            proposal_number = sorts,
        }
    end
    operation.matching = function(_, sorted)
        return {
            allows = function(slot_key, trav_key)
                return sorted.proposal_number ~= 2 or slot_key ~= rejected_slot or trav_key ~= rejected_trav
            end,
        }
    end
    local result = matching.run(params)
    top.sort = original_sort
    operation.matching = original_matching
    protection.planet_locked_recipe_contexts = original_protection
    rng.key = original_rng_key
    assert(sorts >= 3, "a new rejected pair should cause another proposal")
    assert(result[rejected_slot] ~= rejected_trav)
    local moved = false
    for slot_key, trav_key in pairs(result) do
        moved = moved or trav_key ~= graph.nodes[slot_key].old_trav
    end
    assert(moved, "the repaired proposal should retain randomization")
end)

-- Run an actual form-trade gate, with controlled reachability and operation verdicts.
local function check_form_trade(reachable, ready, enabled)
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local params = {
        unconnected_graph = graph,
        slot_keys = {},
        slot_to_base = {},
        trav_to_head = {},
        rounds = 0,
        operations = enabled ~= false and {} or nil,
    }
    for i = 1, 2 do
        local slot = gutils.add_node(graph, "item", "position-" .. i, { op = "AND" })
        local trav = gutils.add_node(graph, "item", "identity-" .. i, {
            op = "OR",
            trav = true,
        })
        slot.old_trav = key(trav)
        trav.old_slot = key(slot)
        table.insert(params.slot_keys, key(slot))
        params.slot_to_base[key(slot)] = slot
        params.trav_to_head[key(trav)] = trav
    end
    local goal = gutils.add_node(graph, "make", "protected-goal", {
        op = "AND",
        mechanic = true,
    })
    params.form_swaps = {
        candidates = function()
            return {
                {
                    params.slot_keys[1],
                    params.slot_keys[2],
                },
            }
        end,
        form_of = function(node_key) return graph.nodes[node_key].old_slot or node_key end,
        max_trials = 1,
        max_swaps = 1,
    }
    local original_sort = top.sort
    local original_matching = operation.matching
    local original_protection = protection.planet_locked_recipe_contexts
    local original_hard = protection.is_hard_mechanic_pebble
    local original_rng_key = rng.key
    local sorts = 0
    local readiness_calls = 0
    rng.key = function(value) return value.id end
    protection.planet_locked_recipe_contexts = function() return {} end
    protection.is_hard_mechanic_pebble = function() return true end
    top.sort = function()
        sorts = sorts + 1
        local contexts = {}
        if sorts == 1 or reachable == true then
            contexts[key(goal)] = { home = 1 }
        end
        return {
            sorted = {},
            node_to_context_inds = contexts,
        }
    end
    operation.matching = function()
        readiness_calls = readiness_calls + 1
        return {
            allows = function()
                return ready
            end,
        }
    end
    local result = matching.run(params)
    top.sort = original_sort
    operation.matching = original_matching
    protection.planet_locked_recipe_contexts = original_protection
    protection.is_hard_mechanic_pebble = original_hard
    rng.key = original_rng_key
    assert(sorts == 2, "the trial should still receive its reachability check")
    local first = params.slot_keys[1]
    local expected = graph.nodes[params.slot_keys[reachable and (enabled == false or ready) and 2 or 1]].old_trav
    assert(result[first] == expected, "only a trade passing both gates may be kept")
    return readiness_calls
end

test("a trade losing reachability skips operation proofs", function()
    assert(check_form_trade(false, true) == 0)
    assert(check_form_trade(false, false) == 0)
end)

test("a reachable trade still fails when operation readiness fails", function()
    assert(check_form_trade(true, false) == 1)
end)

test("a trade passing reachability and operation readiness is kept", function()
    assert(check_form_trade(true, true) == 1)
end)

test("disabled operation checks skip proofs but retain reachability protection", function()
    assert(check_form_trade(true, false, false) == 0)
    assert(check_form_trade(false, false, false) == 0)
end)

print(num_passed .. " tests passed")
