-- Run from the mod root: lua lib/logic/test-operation-sources.lua
local gutils = require("lib/graph/graph-utils")
local sources = require("lib/logic/operation-sources")

local count = 0
local function test(name, run)
    run()
    count = count + 1
    print("ok - " .. name)
end

local function fixture()
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local function add(kind, name, op, pres)
        local node = gutils.add_node(graph, kind, "test-" .. name, { op = op })
        local node_key = gutils.key(node)
        for _, pre in pairs(pres or {}) do
            gutils.add_edge(graph, pre, node_key)
        end
        return node_key
    end
    local root = add("start", "start", "AND")
    return graph, add, root
end

local function can_gate(node)
    return node.type == "recipe"
end

local function allowed(node)
    return node.unsafe ~= true
end

local function size(set)
    local result = 0
    for _, _ in pairs(set) do
        result = result + 1
    end
    return result
end

test("all alternative recipe acquisitions keep their own gate", function()
    local graph, add, root = fixture()
    local first = add("recipe", "first-route", "AND", { root })
    local second = add("recipe", "second-route", "AND", { root })
    local target = add("item", "kit", "OR", {
        first,
        second,
    })
    local plan = sources.plan(graph, target, can_gate, allowed)
    assert(not plan.ungated)
    assert(plan.gates[first] and plan.gates[second] and size(plan.gates) == 2)
    assert(graph.nodes[target].num_pre == 2, "planning must preserve every acquisition edge")
end)

test("the nearest producer gate does not also gate its ingredients", function()
    local graph, add, root = fixture()
    local ingredient = add("recipe", "make-input", "AND", { root })
    local producer = add("recipe", "make-kit", "AND", { ingredient })
    local target = add("item", "kit", "OR", { producer })
    local plan = sources.plan(graph, target, can_gate, allowed)
    assert(not plan.ungated and plan.gates[producer] and size(plan.gates) == 1)
end)

test("mining back a placed item does not add an ungated first acquisition", function()
    local graph, add, root = fixture()
    local recipe = add("recipe", "make-kit", "AND", { root })
    local target = add("item", "kit", "OR", { recipe })
    local build = add("entity-build", "device", "AND", { target })
    local mine = add("entity-mine", "device", "AND", { build })
    gutils.add_edge(graph, mine, target)
    local plan = sources.plan(graph, target, can_gate, allowed)
    assert(not plan.ungated and plan.gates[recipe] and size(plan.gates) == 1)
end)

test("trigger salvage finds every source capsule recipe", function()
    local graph, add, root = fixture()
    local first = add("recipe", "make-capsule", "AND", { root })
    local second = add("recipe", "other-capsule", "AND", { root })
    local capsule = add("item", "capsule", "OR", {
        first,
        second,
    })
    local use = add("item-capsule", "capsule", "AND", { capsule })
    local own = add("entity-own", "device", "OR", { use })
    local entity = add("entity", "device", "OR", { own })
    local mine = add("entity-mine", "device", "AND", { entity })
    local target = add("item", "salvage", "OR", { mine })
    local build = add("entity-build", "device", "AND", { target })
    gutils.add_edge(graph, build, own)
    local plan = sources.plan(graph, target, can_gate, allowed)
    assert(not plan.ungated)
    assert(plan.gates[first] and plan.gates[second] and size(plan.gates) == 2)
end)

test("a wild alternative is still ungated when crafting is gated", function()
    local graph, add, root = fixture()
    local recipe = add("recipe", "make-kit", "AND", { root })
    local wild = add("entity", "wild-device", "OR", { root })
    local mine = add("entity-mine", "wild-device", "AND", { wild })
    local target = add("item", "kit", "OR", {
        recipe,
        mine,
    })
    local plan = sources.plan(graph, target, can_gate, allowed)
    assert(plan.ungated and plan.reason == "ungated acquisition")
    assert(plan.gates[recipe])
end)

test("one safe mandatory branch covers an AND with another unsafe gate", function()
    local graph, add, root = fixture()
    local safe = add("recipe", "safe-input", "AND", { root })
    local unsafe = add("recipe", "unsafe-input", "AND", { root })
    graph.nodes[unsafe].unsafe = true
    local acquire = add("entity-mine", "device", "AND", {
        safe,
        unsafe,
    })
    local target = add("item", "kit", "OR", { acquire })
    local plan = sources.plan(graph, target, can_gate, allowed)
    assert(not plan.ungated and plan.gates[safe] and size(plan.gates) == 1)
end)

test("two safe mandatory branches need only one gate in deterministic order", function()
    local graph, add, root = fixture()
    local first = add("recipe", "a-input", "AND", { root })
    local second = add("recipe", "b-input", "AND", { root })
    local acquire = add("entity-mine", "device", "AND", {
        first,
        second,
    })
    local target = add("item", "kit", "OR", { acquire })
    local plan = sources.plan(graph, target, can_gate, allowed)
    assert(not plan.ungated and size(plan.gates) == 1)
    assert(plan.gates[first] == nil and plan.gates[second], "alphabetically earlier redundant gates are removed first")
end)

test("an unsafe recipe can still be covered by a safe upstream gate", function()
    local graph, add, root = fixture()
    local safe = add("recipe", "safe-input", "AND", { root })
    local unsafe = add("recipe", "unsafe-producer", "AND", { safe })
    graph.nodes[unsafe].unsafe = true
    local target = add("item", "kit", "OR", { unsafe })
    local plan = sources.plan(graph, target, can_gate, allowed)
    assert(not plan.ungated and plan.gates[safe] and size(plan.gates) == 1)
end)

test("an unsafe OR alternative cannot be covered by gating only its sibling", function()
    local graph, add, root = fixture()
    local safe = add("recipe", "safe-route", "AND", { root })
    local unsafe = add("recipe", "unsafe-route", "AND", { root })
    graph.nodes[unsafe].unsafe = true
    local target = add("item", "kit", "OR", {
        safe,
        unsafe,
    })
    local plan = sources.plan(graph, target, can_gate, allowed)
    assert(plan.ungated and plan.gates[safe] and size(plan.gates) == 1)
end)

test("a candidate recipe in a pure cycle cannot certify initial acquisition", function()
    local graph, add = fixture()
    local target = add("item", "kit", "OR")
    local recipe = add("recipe", "return-kit", "AND", { target })
    gutils.add_edge(graph, recipe, target)
    local plan = sources.plan(graph, target, can_gate, allowed)
    assert(plan.ungated and plan.reason == "unreachable" and next(plan.gates) == nil)
end)

test("dead OR alternatives do not introduce unreachable gates", function()
    local graph, add, root = fixture()
    local live = add("recipe", "live-route", "AND", { root })
    local dead = add("item", "unobtainable", "OR")
    local recipe = add("recipe", "dead-route", "AND", { dead })
    local target = add("item", "kit", "OR", {
        live,
        recipe,
    })
    local plan = sources.plan(graph, target, can_gate, allowed)
    assert(not plan.ungated and plan.gates[live] and size(plan.gates) == 1)
end)

test("a gate downstream of an ungated acquisition cannot hide that acquisition", function()
    local graph, add, root = fixture()
    local target = add("item", "kit", "OR", { root })
    local recipe = add("recipe", "return-kit", "AND", { target })
    gutils.add_edge(graph, recipe, target)
    local plan = sources.plan(graph, target, can_gate, allowed)
    assert(plan.ungated, "the return cycle must not count as a gate for the original item")
end)

test("a missing target is reported without a coverage certificate", function()
    local graph = fixture()
    local plan = sources.plan(graph, "test-missing", can_gate, allowed)
    assert(plan.ungated and plan.reason == "missing target" and next(plan.gates) == nil)
end)

print("passed " .. count .. " operation-source tests")
