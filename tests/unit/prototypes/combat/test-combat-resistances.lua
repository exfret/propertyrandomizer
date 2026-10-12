package.loaded["src/config/experimental-flags"] = {military_resistances = true}
-- Run from the mod root: lua tests/unit/prototypes/combat/test-combat-resistances.lua

local resistances = require("src/prototypes/combat/combat-resistances")

local passed = 0
local function test(name, run)
    run()
    passed = passed + 1
    print("ok - " .. name)
end

local damage_types = {
    ["test-a"] = {},
    ["test-b"] = {},
    ["test-c"] = {},
}
local function entity(name, entries)
    return {
        type = "test-entity",
        name = name,
        resistances = entries,
    }
end
local function row(name, percent)
    return {
        type = name,
        percent = percent or 20,
        decrease = 5,
    }
end
local function reversed(group)
    local permutation = {}
    for index = #group.types, 1, -1 do table.insert(permutation, group.types[index]) end
    return permutation
end

test("shared arrays and overlapping shared rows form one atomic ownership group", function()
    local shared = row("test-a")
    local array = {shared}
    local first, second, third = entity("test-first", array), entity("test-second", array), entity("test-third", {
        shared,
        row("test-b"),
    })
    local groups = resistances.collect({
        first,
        second,
        third,
    }, damage_types)
    assert(#groups == 1 and #groups[1].prototypes == 3 and #groups[1].entries == 2)
    assert(resistances.attempt(groups[1], reversed(groups[1]), function() return true end, function(value) return value end))
    assert(first.resistances == array and second.resistances == array and third.resistances[1] == shared)
    assert(shared.type == "test-c" and third.resistances[2].type == "test-b")
    assert(shared.percent == 20 and shared.decrease == 5)
end)

test("an excluded owner blocks an entire connected alias component", function()
    local shared = row("test-a")
    local first = entity("test-first", {shared})
    local second = entity("test-second", {
        shared,
        row("test-b"),
    })
    local independent = entity("test-independent", {row("test-a")})
    local groups = resistances.collect({
        first,
        second,
        independent,
    }, damage_types, function(prototype)
        return prototype ~= second
    end)
    assert(#groups == 1 and groups[1].prototype == independent)
    assert(shared.type == "test-a")
end)

test("immune rows and their type labels stay fixed while other labels are permuted", function()
    local immune, ordinary = row("test-a", 100), row("test-b", 50)
    local prototype = entity("test-target", {
        immune,
        ordinary,
    })
    local group = resistances.collect({prototype}, damage_types)[1]
    assert(#group.types == 2)
    assert(resistances.attempt(group, reversed(group), function()
        assert(immune.type == "test-a" and immune.percent == 100 and immune.decrease == 5)
        assert(ordinary.type == "test-c" and ordinary.percent == 50)
        return true
    end, function(value) return value end))
    assert(#prototype.resistances == 2 and prototype.resistances[1] == immune)
end)

test("promotion refusal and errors restore every original shared row", function()
    local original = row("test-a")
    local prototype = entity("test-target", {original})
    local group = resistances.collect({prototype}, damage_types)[1]
    assert(not resistances.attempt(group, reversed(group), function()
        assert(original.type == "test-c")
        return "trial"
    end, function(value) assert(value == "trial"); return false end))
    assert(original.type == "test-a")
    local okay = pcall(resistances.attempt, group, reversed(group), function() error("test failure") end, function() return true end)
    assert(not okay and original.type == "test-a")
end)

test("unsupported resistance values and duplicate types are never candidates", function()
    local invalid = {
        row("test-missing"),
        row("test-a", 101),
        row("test-a", -1),
        row("test-a", 0 / 0),
        row("test-a", false),
    }
    invalid[5].percent = false
    for index, entry in pairs(invalid) do
        assert(#resistances.collect({entity("test-invalid-" .. index, {entry})}, damage_types) == 0)
    end
    local duplicate = entity("test-duplicate", {
        row("test-a"),
        row("test-a"),
    })
    assert(#resistances.collect({duplicate}, damage_types) == 0)
end)

test("identity and nonbijective assignments never invoke evaluation", function()
    local group = resistances.collect({entity("test-target", {row("test-a")})}, damage_types)[1]
    local function forbidden() error("should not evaluate") end
    assert(not resistances.attempt(group, group.types, forbidden, forbidden))
    local invalid = reversed(group)
    invalid[1] = invalid[2]
    assert(not resistances.attempt(group, invalid, forbidden, forbidden))
end)

test("out-of-scope registry owners protect shared rows across prototype classes", function()
    local shared = row("test-a")
    local target = entity("test-target", {shared})
    local outside = {
        type = "test-other-kind",
        name = "test-outside",
        resistances = {shared},
    }
    local raw = {[outside.type] = {[outside.name] = outside}}
    local groups = resistances.collect({target}, damage_types, function() return true end, raw)
    assert(#groups == 0 and shared.type == "test-a")
end)

test("combat fields barrier registries and target membership select independent ownership groups", function()
    local prototypes = {}
    for index = 1, 9 do prototypes[index] = entity("test-owner-" .. index, {row("test-a")}) end
    prototypes[1].attack_parameters = {}
    prototypes[2].guns = {"test-weapon"}
    prototypes[3].is_military_target = true
    prototypes[4].gun = "test-weapon"
    prototypes[8].result_units = {}
    local raw = {}
    raw.wall = {prototypes[5]}
    raw.gate = {prototypes[6]}
    local targets = {[prototypes[7].name] = true}
    local partition = resistances.partition(resistances.collect(prototypes, damage_types), {
        raw = raw,
        sensitive_entities = targets,
    })
    assert(#partition.sensitive == 8 and #partition.ordinary == 1)
    assert(partition.ordinary[1].prototype == prototypes[9])
end)

test("one sensitive alias keeps its entire shared ownership component independent", function()
    local shared = {row("test-a")}
    local first, second = entity("test-first", shared), entity("test-second", shared)
    second.attack_parameters = {}
    local groups = resistances.collect({
        first,
        second,
    }, damage_types)
    local partition = resistances.partition(groups)
    assert(#partition.sensitive == 1 and #partition.ordinary == 0)
    assert(partition.sensitive[1] == groups[1] and #groups[1].prototypes == 2)
end)

test("ordinary batches share permutations while preserving different magnitudes and original tables", function()
    local first = entity("test-first", {row("test-a", 10)})
    local second = entity("test-second", {
        row("test-a", 60),
        row("test-b", 30),
    })
    local first_array, second_array = first.resistances, second.resistances
    local partition = resistances.partition(resistances.collect({
        first,
        second,
    }, damage_types))
    local batch = partition.ordinary[1]
    assert(#partition.ordinary == 1 and #batch.groups == 2 and #batch.entries == 3)
    assert(resistances.attempt(batch, reversed(batch), function() return true end, function(value) return value end))
    assert(first.resistances[1].type == second.resistances[1].type and first.resistances[1].type == "test-c")
    assert(first.resistances[1].percent == 10 and second.resistances[1].percent == 60)
    assert(first.resistances == first_array and second.resistances == second_array)
end)

test("different immunity signatures keep separate mappings in one atomic ordinary transaction", function()
    local first = entity("test-first", {
        row("test-a", 100),
        row("test-b", 30),
    })
    local second = entity("test-second", {
        row("test-b", 100),
        row("test-a", 50),
    })
    local partition = resistances.partition(resistances.collect({
        first,
        second,
    }, damage_types))
    assert(#partition.ordinary == 2)
    local proposals = {}
    for _, batch in pairs(partition.ordinary) do
        table.insert(proposals, {
            group = batch,
            permutation = reversed(batch),
        })
    end
    local function evaluate()
        assert(first.resistances[1].type == "test-a" and second.resistances[1].type == "test-b")
        assert(first.resistances[2].type == "test-c" and second.resistances[2].type == "test-c")
        return true
    end
    assert(not resistances.attempt_batch(proposals, evaluate, function() return false end))
    assert(first.resistances[2].type == "test-b" and second.resistances[2].type == "test-a")
    local okay = pcall(resistances.attempt_batch, proposals, evaluate, function() error("test refusal") end)
    assert(not okay and first.resistances[2].type == "test-b" and second.resistances[2].type == "test-a")
    assert(resistances.attempt_batch(proposals, evaluate, function(value) return value end))
end)

test("target classification expands body parts and death children and fails conservatively", function()
    local head, body, child = entity("test-head", {}), entity("test-body", {}), entity("test-child", {})
    child.max_health = 50
    head.segment_engine = {segments = {{segment = body.name}}}
    head.dying_trigger_effect = {
        type = "create-entity",
        entity_name = child.name,
        trigger_created_entity = false,
    }
    local entities = {
        head,
        body,
        child,
    }
    local definitions = {
        {
            targets = {
                {
                    entity = head.name,
                    amount = 1,
                },
            },
        },
    }
    local targets = assert(resistances.target_set(definitions, entities, {}))
    assert(targets[head.name] and targets[body.name] and targets[child.name])
    head.dying_trigger_effect = {type = "test-unsupported-effect"}
    local unknown, reason = resistances.target_set(definitions, entities, {})
    assert(unknown == nil and reason ~= nil)
    local groups = resistances.collect({entity("test-ordinary", {row("test-a")})}, damage_types)
    local partition = resistances.partition(groups, {all_sensitive = unknown == nil})
    assert(#partition.sensitive == 1 and #partition.ordinary == 0)
end)

print(passed .. " tests passed")
