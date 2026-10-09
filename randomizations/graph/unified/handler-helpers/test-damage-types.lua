-- Plain-Lua tests for transactional damage-type rewiring, including real promotion checks.
-- Run from the mod root: lua randomizations/graph/unified/handler-helpers/test-damage-types.lua

function table.deepcopy(value)
    if type(value) ~= "table" then
        return value
    end
    local result = {}
    for k, v in pairs(value) do
        result[k] = table.deepcopy(v)
    end
    return result
end

function log(message) end
serpent = {
    block = tostring,
    line = tostring,
}
local logic = {
    contexts = {
        ["test-room"] = true,
    },
    type_info = {
        orand = {},
    },
}
package.loaded["lib/logic/init"] = logic
package.loaded["lib/logic/state"] = logic
package.loaded["lib/random/rng"] = {
    int = function() return 1 end,
}

local gutils = require("lib/graph/graph-utils")
local helper = require("randomizations/graph/unified/handler-helpers/damage-types")
local promotion = require("randomizations/graph/unified/skeleton/promotion")
local top = require("lib/graph/context-sort")
-- Edge abilities are codes (lib/graph/contexts.lua); fixtures write them as the tables the logic builders used to (lib/graph/contexts-for-tests.lua)
local ctx = require("lib/graph/contexts")
local fx = require("lib/graph/contexts-for-tests")

-- Whether edge abilities lose an ability, as { [ability] = false } said
local function loses(abilities, ability)
    return ctx.edge_loses_ability(abilities, ability) and not ctx.edge_gains_ability(abilities, ability)
end

-- Whether a complex context has an ability
local function context_has(context, ability)
    return top.has_ability(top.context_mask(context), ability)
end

local passed = 0
local function test(name, run)
    run()
    passed = passed + 1
    print("ok - " .. name)
end

local function same_set(actual, expected)
    local members = {}
    for _, value in pairs(actual) do
        assert(members[value] == nil)
        members[value] = true
    end
    for _, value in pairs(expected) do
        assert(members[value], "Missing " .. value)
        members[value] = nil
    end
    assert(next(members) == nil)
end

local function edge_key(start, stop)
    return gutils.ekey({
        start = start,
        stop = stop,
    })
end

local function prekeys(graph, node_key)
    local result = {}
    for _, node in pairs(gutils.prenodes(graph, graph.nodes[node_key])) do
        table.insert(result, gutils.key(node))
    end
    return result
end

local function apply(graph, changes)
    for _, change in pairs(changes) do
        for _, start in pairs(change.remove or {}) do
            gutils.remove_edge(graph, edge_key(start, change.node_key))
        end
        if change.add ~= nil then
            gutils.add_edge(graph, change.add, change.node_key)
        end
    end
end

local function source_info(kind)
    return {source_type = kind}
end

local function fixture(important, mode)
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local function node(kind, name, op, extra)
        logic.type_info[kind] = logic.type_info[kind] or {}
        extra = extra or {}
        extra.op = op
        return gutils.key(gutils.add_node(graph, kind, name, extra))
    end
    local keys = {}
    keys.start = node("start", "", "AND")
    graph.sources[keys.start] = true
    keys.source = node("entity-operate", "test-turret", "AND")
    keys.ammo = node("item-ammo", "test-ammo", "AND")
    gutils.add_edge(graph, keys.start, keys.source)
    gutils.add_edge(graph, keys.start, keys.ammo)
    keys.counter = node("combat-encounter-counter", "test-counter", "AND", {
        counter_name = "test-mixed-battery",
        encounter_name = "test-encounter",
        deployment_mode = mode or "turret",
        counter_prerequisites = {
            keys.source,
            keys.ammo,
        },
    })
    gutils.add_edge(graph, keys.source, keys.counter)
    gutils.add_edge(graph, keys.ammo, keys.counter)
    keys.counters = node("combat-encounter-counters", "test-encounter", "OR")
    local counter_edge = {}
    if mode == "manual" then
        counter_edge.abilities = fx.edge({
            [top.AUTOMATABILITY] = false,
        })
    end
    gutils.add_edge(graph, keys.counter, keys.counters, counter_edge)
    keys.encounter = node("combat-encounter", "test-encounter", "AND", {mechanic = important})
    gutils.add_edge(graph, keys.counters, keys.encounter)
    keys.old_damage = node("damage-type", "test-old-damage", "OR")
    keys.new_damage = node("damage-type", "test-new-damage", "OR")
    gutils.add_edge(graph, keys.ammo, keys.old_damage, {
        abilities = fx.edge({
            [top.AUTOMATABILITY] = false,
        }),
    })
    gutils.make_orands(graph)
    keys.counter_carrier = gutils.key(gutils.prenodes(graph, graph.nodes[keys.counters])[1])
    keys.damage_carrier = gutils.key(gutils.prenodes(graph, graph.nodes[keys.old_damage])[1])
    return graph, keys
end

local function candidate(keys, mode)
    return {
        mode = mode or "turret",
        count = 10,
        clear_seconds = 8,
        prerequisites = {
            keys.source,
            keys.ammo,
        },
    }
end

local function evaluation(keys, witness)
    local result = {
        ["test-encounter"] = {
            counters = {},
            policy = {
                turret_count = 10,
                manual_count = 1,
                clear_seconds = 10,
            },
        },
    }
    result["test-encounter"].counters["test-mixed-battery"] = witness
    return result
end

local function damage_sources(keys, damage_type)
    return {
        [damage_type] = {
            [gutils.key("test-source", "test-ammo")] = source_info("ammo"),
        },
    }
end

test("shared packets are changed once and success keeps every mutation", function()
    local first = {type = "test-old"}
    local second = {type = "test-other"}
    local calls = 0
    assert(helper.attempt({
        first,
        second,
        first,
    }, "test-new", function()
        calls = calls + 1
        assert(first.type == "test-new" and second.type == "test-new")
        return {token = 42}
    end, function(trial)
        assert(trial.token == 42)
        return true
    end))
    assert(first.type == "test-new" and second.type == "test-new" and calls == 1)
end)

test("refusal restores distinct original types even when one packet appears twice", function()
    local first = {type = "test-old"}
    local second = {type = "test-other"}
    assert(not helper.attempt({
        first,
        second,
        first,
    }, "test-new", function() return true end, function() return false end))
    assert(first.type == "test-old" and second.type == "test-other")
end)

test("evaluation errors restore every shared packet before propagating", function()
    local first = {type = "test-old"}
    local second = {type = "test-other"}
    local committed = false
    local ok, reason = pcall(helper.attempt, {
        first,
        second,
        first,
    }, "test-new", function()
        error("test-evaluation-failure")
    end, function()
        committed = true
        return true
    end)
    assert(not ok and string.find(reason, "test-evaluation-failure", 1, true))
    assert(not committed and first.type == "test-old" and second.type == "test-other")
end)

test("commit errors and nonboolean acceptance restore prototype mutations", function()
    local packet = {type = "test-old"}
    local ok, reason = pcall(helper.attempt, {packet}, "test-new", function() return true end, function()
        error("test-commit-failure")
    end)
    assert(not ok and string.find(reason, "test-commit-failure", 1, true))
    assert(packet.type == "test-old")
    assert(not helper.attempt({packet}, "test-new", function() return true end, function() return "accepted" end))
    assert(packet.type == "test-old")
end)

test("all packet original types are validated before any mutation", function()
    local valid = {type = "test-old"}
    local invalid = {}
    local evaluated = false
    local ok = pcall(helper.attempt, {
        valid,
        invalid,
    }, "test-new", function()
        evaluated = true
    end, function() return true end)
    assert(not ok and not evaluated and valid.type == "test-old" and invalid.type == nil)
end)

test("source classes map to their existing acquisition nodes without prototype name choices", function()
    local source = gutils.key("test-source", "test-name")
    assert(helper.source_key(source, source_info("ammo")) == gutils.key("item-ammo", "test-name"))
    assert(helper.source_key(source, source_info("turret")) == gutils.key("entity-operate", "test-name"))
    assert(helper.source_key(source, source_info("entity")) == gutils.key("entity", "test-name"))
    assert(helper.source_key(source, source_info("equipment")) == gutils.key("equipment-operate", "test-name"))
    assert(helper.source_key(source, source_info("test-unsupported")) == nil)
end)

test("a surviving mixed witness retains its complete original prerequisite conjunction", function()
    local graph, keys = fixture()
    local captured = helper.capture(graph)
    local changes = helper.changes(graph, captured, evaluation(keys, candidate(keys)), damage_sources(keys, "test-old-damage"))
    assert(#changes == 0)
    same_set(graph.nodes[keys.counter].counter_prerequisites, {
        keys.source,
        keys.ammo,
    })
    same_set(prekeys(graph, keys.counter), {
        keys.source,
        keys.ammo,
    })
    local easier = candidate(keys)
    easier.prerequisites = {keys.ammo}
    assert(helper.same_witness(graph.nodes[keys.counter], easier, evaluation(keys)["test-encounter"].policy))
    assert(#helper.changes(graph, captured, evaluation(keys, easier), damage_sources(keys, "test-old-damage")) == 0)
    same_set(prekeys(graph, keys.counter), {
        keys.source,
        keys.ammo,
    })
end)

test("counter loss removes only its OR alternative and never invents a new witness", function()
    local graph, keys = fixture()
    local captured = helper.capture(graph)
    local evaluated = evaluation(keys)
    evaluated["test-encounter"].counters["test-new-counter"] = candidate(keys)
    local changes = helper.changes(graph, captured, evaluated, damage_sources(keys, "test-old-damage"))
    assert(#changes == 1 and changes[1].node_key == keys.counters)
    same_set(changes[1].remove, {keys.counter_carrier})
    apply(graph, changes)
    assert(next(graph.nodes[keys.counters].pre) == nil)
    same_set(prekeys(graph, keys.counter), {
        keys.source,
        keys.ammo,
    })
end)

test("changed mode or stronger prerequisites cannot reuse an old counter", function()
    local graph, keys = fixture()
    local node = graph.nodes[keys.counter]
    local policy = evaluation(keys)["test-encounter"].policy
    local witness = candidate(keys, "manual")
    witness.count = 1
    assert(not helper.same_witness(node, witness, policy))
    node.deployment_mode = "manual"
    assert(helper.same_witness(node, witness, policy))
    witness.count = 2
    assert(not helper.same_witness(node, witness, policy))
    witness.count = 1
    witness.prerequisites = {gutils.key("test-requirement", "test-later-tech")}
    assert(not helper.same_witness(node, witness, policy))
    witness.prerequisites = {}
    assert(not helper.same_witness(node, witness, policy))
end)

test("counter budgets reject excess deployment and nonfinite or late completion", function()
    local graph, keys = fixture()
    local node = graph.nodes[keys.counter]
    local policy = evaluation(keys)["test-encounter"].policy
    local witness = candidate(keys)
    witness.count = 11
    assert(not helper.same_witness(node, witness, policy))
    witness.count = 1.5
    assert(not helper.same_witness(node, witness, policy))
    witness.count = 0 / 0
    assert(not helper.same_witness(node, witness, policy))
    witness.count = 10
    witness.clear_seconds = 10.01
    assert(not helper.same_witness(node, witness, policy))
    witness.clear_seconds = 0 / 0
    assert(not helper.same_witness(node, witness, policy))
    witness.clear_seconds = math.huge
    assert(not helper.same_witness(node, witness, policy))
    witness.clear_seconds = 0
    assert(not helper.same_witness(node, witness, policy))
    witness.clear_seconds = 10
    assert(helper.same_witness(node, witness, policy))
end)

test("moving a source to another damage type reuses the connector carrying its manual-only ability", function()
    local graph, keys = fixture()
    local captured = helper.capture(graph)
    local changes = helper.changes(graph, captured, evaluation(keys, candidate(keys)), damage_sources(keys, "test-new-damage"))
    apply(graph, changes)
    assert(graph.edges[edge_key(keys.damage_carrier, keys.old_damage)] == nil)
    assert(graph.edges[edge_key(keys.damage_carrier, keys.new_damage)] ~= nil)
    assert(loses(graph.edges[edge_key(keys.ammo, keys.damage_carrier)].abilities, top.AUTOMATABILITY))
    local sorted = top.sort(graph, nil, nil, {complex_contexts = true})
    local contexts = sorted.node_to_context_inds[keys.new_damage]
    assert(contexts ~= nil and next(contexts) ~= nil)
    for context, _ in pairs(contexts) do
        assert(not context_has(context, top.AUTOMATABILITY))
    end
end)

test("a retained manual counter never gains an automatic encounter context", function()
    local graph, keys = fixture(true, "manual")
    local witness = candidate(keys, "manual")
    witness.count = 1
    local changes = helper.changes(graph, helper.capture(graph), evaluation(keys, witness), damage_sources(keys, "test-old-damage"))
    assert(#changes == 0)
    assert(loses(graph.edges[edge_key(keys.counter, keys.counter_carrier)].abilities, top.AUTOMATABILITY))
    local sorted = top.sort(graph, nil, nil, {complex_contexts = true})
    local contexts = sorted.node_to_context_inds[keys.encounter]
    assert(contexts ~= nil and next(contexts) ~= nil)
    for context, _ in pairs(contexts) do
        assert(not context_has(context, top.AUTOMATABILITY))
    end
    witness.mode = "turret"
    assert(#helper.changes(graph, helper.capture(graph), evaluation(keys, witness), damage_sources(keys, "test-old-damage")) == 1)
end)

test("an unchanged source with several damage types keeps each existing connector", function()
    local graph, keys = fixture()
    local duplicate = gutils.add_edge(graph, keys.ammo, keys.new_damage, {
        abilities = fx.edge({
            [top.AUTOMATABILITY] = false,
        }),
    })
    gutils.make_orand(graph, gutils.ekey(duplicate))
    local sources = damage_sources(keys, "test-old-damage")
    sources["test-new-damage"] = damage_sources(keys, "test-new-damage")["test-new-damage"]
    local changes = helper.changes(graph, helper.capture(graph), evaluation(keys, candidate(keys)), sources)
    assert(#changes == 0)
end)

test("real promotion rejects losing a promised encounter and restores shared packets", function()
    local graph, keys = fixture(true)
    local prom = promotion.new({
        graph = graph,
        complex = true,
    })
    assert(#prom.promise_mechanics() == 0)
    local promised = prom.num_promised
    assert(promised > 0)
    local captured = helper.capture(graph)
    local packet = {type = "test-old-damage"}
    assert(not helper.attempt({
        packet,
        packet,
    }, "test-new-damage", function()
        return helper.changes(graph, captured, evaluation(keys), damage_sources(keys, packet.type))
    end, function(changes)
        return prom.try_rewires(changes, true)
    end))
    assert(packet.type == "test-old-damage")
    assert(prom.num_promised == promised)
    same_set(prom.pre_keys_of(keys.counters), {keys.counter_carrier})
    same_set(prom.pre_keys_of(keys.old_damage), {keys.damage_carrier})
    assert(#prom.pre_keys_of(keys.new_damage) == 0)
end)

test("real promotion accepts a type change retaining the promised mixed witness and manual ability filter", function()
    local graph, keys = fixture(true)
    local prom = promotion.new({
        graph = graph,
        complex = true,
    })
    assert(#prom.promise_mechanics() == 0)
    local captured = helper.capture(graph)
    local packet = {type = "test-old-damage"}
    local checked = false
    assert(helper.attempt({
        packet,
        packet,
    }, "test-new-damage", function()
        return helper.changes(graph, captured, evaluation(keys, candidate(keys)), damage_sources(keys, packet.type))
    end, function(changes)
        return prom.try_rewires(changes, true, function(trial)
            checked = true
            assert(loses(trial.edges[edge_key(keys.ammo, keys.damage_carrier)].abilities, top.AUTOMATABILITY))
            same_set(prekeys(trial, keys.counter), {
                keys.source,
                keys.ammo,
            })
            return true
        end)
    end))
    assert(checked and packet.type == "test-new-damage")
    same_set(prom.pre_keys_of(keys.counters), {keys.counter_carrier})
    assert(#prom.pre_keys_of(keys.old_damage) == 0)
    same_set(prom.pre_keys_of(keys.new_damage), {keys.damage_carrier})
end)

print(passed .. " tests passed")
