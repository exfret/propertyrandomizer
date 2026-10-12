-- Run from the mod root: lua tests/unit/prototypes/combat/test-combat-asteroid-batteries.lua

local batteries = require("src/prototypes/combat/combat-asteroid-batteries")

local passed = 0
local function test(name, run)
    run()
    passed = passed + 1
    print("ok - " .. name)
end

local function profile(kind, interval, mode)
    return {
        name = kind,
        mode = mode or "turret",
        profile = {
            packets = {
                {
                    type = kind,
                    amount = 10,
                    count = 1,
                },
            },
            interval_seconds = interval or 1,
        },
    }
end

local function roster(name, amount)
    return {
        entity = name,
        amount = amount or 1,
    }
end

local function fixture()
    local profiles = {
        profile("test-first"),
        profile("test-second"),
        profile("test-third"),
    }
    local entities, group = {}, {}
    for index, source in pairs(profiles) do
        local name = "test-target-" .. index
        local target = {
            max_health = 10,
            resistances = {},
        }
        for other, entry in pairs(profiles) do
            if other ~= index then
                table.insert(target.resistances, {
                    type = entry.name,
                    percent = 100,
                })
            end
        end
        entities[name] = target
        table.insert(group, roster(name, index == 3 and 40 or 30))
    end
    return profiles, group, entities
end

local function check_certificate(candidate, profiles, expected_phases)
    local counts = {
        [candidate.left] = candidate.left_count,
        [candidate.middle] = candidate.middle_count,
        [candidate.right] = candidate.right_count,
    }
    local deployment = candidate.left_count + candidate.middle_count + candidate.right_count
    assert(deployment <= 10 and candidate.left_count >= 1 and candidate.middle_count >= 1 and candidate.right_count >= 1)
    local total = 0
    for _, phase in pairs(candidate.schedule) do
        local actual, deployed, longest = {}, {}, 0
        assert(#phase.guns == deployment)
        for _, gun in pairs(phase.guns) do
            deployed[gun.profile] = (deployed[gun.profile] or 0) + 1
            local duration = 0
            for name, amount in pairs(gun.counts) do
                assert(amount >= 0 and amount % 1 == 0)
                actual[name] = (actual[name] or 0) + amount
                duration = duration + amount * profiles[gun.profile].profile.interval_seconds
            end
            -- These fixtures use one-shot kills, so the full gun load can be checked independently.
            assert(math.abs(duration - gun.seconds) < 1e-9)
            longest = math.max(longest, gun.seconds)
        end
        for index, amount in pairs(counts) do
            assert(deployed[index] == amount)
        end
        for name, amount in pairs(expected_phases[phase.generation]) do
            assert(actual[name] == amount)
            actual[name] = nil
        end
        assert(next(actual) == nil and longest == phase.seconds)
        total = total + phase.seconds
    end
    assert(total == candidate.clear_seconds)
end

test("three complementary profiles keep a single fixed ten-turret budget", function()
    local profiles, group, entities = fixture()
    local candidates, diagnostics = batteries.evaluate(profiles, group, entities)
    assert(#candidates == 1)
    local candidate = candidates[1]
    assert(candidate.left == 1 and candidate.middle == 2 and candidate.right == 3)
    assert(candidate.left_count == 3 and candidate.middle_count == 3 and candidate.right_count == 4)
    assert(candidate.clear_seconds == 10)
    assert(diagnostics.triples_attempted == 1 and diagnostics.allocations_attempted == 36 and not diagnostics.truncated)
    check_certificate(candidate, profiles, {
        [0] = {
            ["test-target-1"] = 30,
            ["test-target-2"] = 30,
            ["test-target-3"] = 40,
        },
    })
end)

test("different materials run concurrently inside one cohort", function()
    local profiles, group, entities = fixture()
    for _, target in pairs(group) do
        target.amount = 1
    end
    entities["test-target-extra"] = entities["test-target-1"]
    table.insert(group, roster("test-target-extra"))
    local candidates = batteries.evaluate(profiles, group, entities, {deployment_count = 4})
    assert(#candidates == 1 and candidates[1].clear_seconds == 1)
    assert(candidates[1].left_count == 2 and candidates[1].middle_count == 1 and candidates[1].right_count == 1)
    check_certificate(candidates[1], profiles, {
        [0] = {
            ["test-target-1"] = 1,
            ["test-target-2"] = 1,
            ["test-target-3"] = 1,
            ["test-target-extra"] = 1,
        },
    })
end)

test("dependency generations wait for parents and preserve all created targets", function()
    local profiles, _, entities = fixture()
    entities["test-target-1"].dying_trigger_effect = {
        type = "create-entity",
        entity_name = "test-target-2",
        repeat_count = 3,
    }
    entities["test-target-2"].dying_trigger_effect = {
        type = "create-entity",
        entity_name = "test-target-3",
        repeat_count = 3,
    }
    local candidates = batteries.evaluate(profiles, {roster("test-target-1")}, entities)
    assert(#candidates == 1 and #candidates[1].schedule == 3 and candidates[1].clear_seconds == 4)
    check_certificate(candidates[1], profiles, {
        [0] = {["test-target-1"] = 1},
        [1] = {["test-target-2"] = 3},
        [2] = {["test-target-3"] = 9},
    })
end)

test("manual profiles never enter a turret triple and original indexes survive", function()
    local profiles, group, entities = fixture()
    table.insert(profiles, 1, profile("test-manual", 0.01, "manual"))
    local candidates = batteries.evaluate(profiles, group, entities)
    assert(#candidates == 1 and candidates[1].left == 2 and candidates[1].middle == 3 and candidates[1].right == 4)
end)

test("a single unreachable target prevents an incomplete mixture", function()
    local profiles, group, entities = fixture()
    table.insert(entities["test-target-1"].resistances, {
        type = "test-first",
        percent = 100,
    })
    local candidates, diagnostics = batteries.evaluate(profiles, group, entities)
    assert(#candidates == 0 and diagnostics.rejected["asteroid-mixed-uncovered-target"] == 1)
    assert(diagnostics.allocations_attempted == 0)
end)

test("time cutoffs omit slow schedules without rounding them into a success", function()
    local profiles, group, entities = fixture()
    local candidates, diagnostics = batteries.evaluate(profiles, group, entities, {max_seconds = 9.99})
    assert(#candidates == 0 and diagnostics.rejected["asteroid-mixed-too-slow"] == 1)
    assert(diagnostics.triples_pruned == 1 and diagnostics.allocations_attempted == 0)
    assert(#batteries.evaluate(profiles, group, entities, {max_seconds = 10}) == 1)
end)

test("an exact deadline remains feasible after optimistic allocation pruning", function()
    local profiles, group, entities = fixture()
    for _, source in pairs(profiles) do
        source.profile.interval_seconds = 2
    end
    local candidates, diagnostics = batteries.evaluate(profiles, group, entities, {max_seconds = 20})
    assert(#candidates == 1 and candidates[1].clear_seconds == 20)
    assert(diagnostics.allocations_pruned > 0 and diagnostics.work < 10000 and not diagnostics.truncated)
end)

test("distinct source keys exclude extra ammo profiles before scored budgets", function()
    local profiles, group, entities = fixture()
    local extra = profile("test-alternate-ammo")
    extra.source_key = "test-shared-weapon"
    profiles[1].source_key = extra.source_key
    table.insert(profiles, 2, extra)
    local candidates, diagnostics = batteries.evaluate(profiles, group, entities, {
        max_triples = 1,
        triple_allowed = function(a, b, c)
            return a.name == "test-first" and b.name == "test-second" and c.name == "test-third"
        end,
    })
    assert(#candidates == 1 and candidates[1].left == 1 and candidates[1].middle == 3 and candidates[1].right == 4)
    assert(diagnostics.duplicate_sources_skipped == 2 and diagnostics.triples_scanned == 4)
    assert(diagnostics.triples_attempted == 1 and not diagnostics.truncated)
    candidates, diagnostics = batteries.evaluate(profiles, group, entities, {
        max_work = 1,
        max_scanned_triples = 2,
    })
    assert(#candidates == 0 and diagnostics.work == 0 and diagnostics.triples_attempted == 0)
    assert(diagnostics.duplicate_sources_skipped == 2 and diagnostics.scan_limit_reached)
end)

test("source identity falls back to profile names and then array indexes", function()
    local profiles, group, entities = fixture()
    profiles[2].name = profiles[1].name
    local candidates, diagnostics = batteries.evaluate(profiles, group, entities)
    assert(#candidates == 0 and diagnostics.duplicate_sources_skipped == 1 and diagnostics.work == 0)
    for _, source in pairs(profiles) do
        source.name = nil
    end
    assert(#batteries.evaluate(profiles, group, entities) == 1)
end)

test("triple filters run before attempted-triple and work budgets", function()
    local profiles = {
        profile("test-a"),
        profile("test-b"),
        profile("test-c"),
        profile("test-d"),
        profile("test-e"),
    }
    local group = {roster("test-target")}
    local entities = {["test-target"] = {max_health = 10}}
    local candidates, diagnostics = batteries.evaluate(profiles, group, entities, {
        max_triples = 1,
        triple_allowed = function(a, b, c)
            return a.name == "test-c" and b.name == "test-d" and c.name == "test-e"
        end,
    })
    assert(#candidates == 1 and diagnostics.triples_attempted == 1 and diagnostics.triples_scanned == 10)
    assert(candidates[1].left == 3 and candidates[1].middle == 4 and candidates[1].right == 5)
    assert(not diagnostics.truncated)
    candidates, diagnostics = batteries.evaluate(profiles, group, entities, {
        max_work = 1,
        triple_allowed = function() return false end,
    })
    assert(#candidates == 0 and diagnostics.work == 0 and diagnostics.triples_attempted == 0)
end)

test("raw scan limits bound even a filter that rejects every triple", function()
    local profiles, group, entities = fixture()
    table.insert(profiles, profile("test-fourth"))
    local candidates, diagnostics = batteries.evaluate(profiles, group, entities, {
        max_scanned_triples = 2,
        triple_allowed = function() return false end,
    })
    assert(#candidates == 0 and diagnostics.triples_scanned == 2 and diagnostics.triples_attempted == 0)
    assert(diagnostics.scan_limit_reached and diagnostics.truncated and diagnostics.work == 0)
    assert(diagnostics.reason == "asteroid-mixed-scan-budget")
end)

test("accepted-triple limits preserve deterministic earlier witnesses", function()
    local profiles, group, entities = fixture()
    table.insert(profiles, profile("test-fourth"))
    local candidates, diagnostics = batteries.evaluate(profiles, group, entities, {max_triples = 1})
    assert(#candidates == 1 and candidates[1].left == 1 and candidates[1].middle == 2 and candidates[1].right == 3)
    assert(diagnostics.triple_limit_reached and diagnostics.truncated)
    assert(diagnostics.reason == "asteroid-mixed-triple-budget")
end)

test("work exhaustion cannot emit a partially assigned workload", function()
    local profiles, group, entities = fixture()
    local candidates, diagnostics = batteries.evaluate(profiles, group, entities, {max_work = 100})
    assert(#candidates == 0 and diagnostics.work <= 100)
    assert(diagnostics.work_limit_reached and diagnostics.truncated)
    assert(diagnostics.reason == "asteroid-mixed-work-budget")
end)

test("repeated jobs stay compact even for enormous target counts", function()
    local profiles, group, entities = fixture()
    group[1].amount = 30000000
    group[2].amount = 30000000
    group[3].amount = 40000000
    local candidates, diagnostics = batteries.evaluate(profiles, group, entities)
    assert(#candidates == 1 and candidates[1].clear_seconds == 10000000)
    assert(not diagnostics.truncated and diagnostics.work < 100000)
    check_certificate(candidates[1], profiles, {
        [0] = {
            ["test-target-1"] = 30000000,
            ["test-target-2"] = 30000000,
            ["test-target-3"] = 40000000,
        },
    })
end)

test("incomplete lifecycles and insufficient turret slots return no witness", function()
    local profiles, group, entities = fixture()
    assert(#batteries.evaluate(profiles, group, entities, {deployment_count = 2}) == 0)
    entities["test-target-1"].dying_trigger_effect = {
        type = "create-entity",
        entity_name = "test-missing-child",
    }
    local candidates, diagnostics = batteries.evaluate(profiles, group, entities)
    assert(#candidates == 0 and diagnostics.reason == "missing-created-target")
end)

test("feasibility returns a complete certificate without minimizing each triple", function()
    local profiles, group, entities = fixture()
    local ordinary, full = batteries.evaluate(profiles, group, entities)
    local candidates, early = batteries.evaluate(profiles, group, entities, {
        feasibility_only = true,
        max_seconds = 30,
    })
    assert(#candidates == 1 and #ordinary == 1)
    assert(candidates[1].clear_seconds == 30 and ordinary[1].clear_seconds == 10)
    assert(early.allocations_attempted == 1 and full.allocations_attempted == 36 and early.work < full.work)
    check_certificate(candidates[1], profiles, {
        [0] = {
            ["test-target-1"] = 30,
            ["test-target-2"] = 30,
            ["test-target-3"] = 40,
        },
    })
    table.insert(profiles, profile("test-universal"))
    candidates, early = batteries.evaluate(profiles, group, entities, {
        feasibility_only = true,
        max_seconds = 30,
    })
    assert(#candidates == 4 and early.triples_attempted == 4 and early.allocations_attempted == 4)
    assert(candidates[4].left == 2 and candidates[4].middle == 3 and candidates[4].right == 4)
end)

test("feasibility includes every death generation and cannot emit partial work", function()
    local profiles, _, entities = fixture()
    entities["test-target-1"].dying_trigger_effect = {
        type = "create-entity",
        entity_name = "test-target-2",
        repeat_count = 3,
    }
    entities["test-target-2"].dying_trigger_effect = {
        type = "create-entity",
        entity_name = "test-target-3",
        repeat_count = 3,
    }
    local group = {roster("test-target-1")}
    local candidates = batteries.evaluate(profiles, group, entities, {
        feasibility_only = true,
        max_seconds = 6,
    })
    assert(#candidates == 1 and candidates[1].clear_seconds == 6)
    check_certificate(candidates[1], profiles, {
        [0] = {["test-target-1"] = 1},
        [1] = {["test-target-2"] = 3},
        [2] = {["test-target-3"] = 9},
    })
    assert(#batteries.evaluate(profiles, group, entities, {
        feasibility_only = true,
        max_seconds = 2.5,
    }) == 0)
    local diagnostics
    candidates, diagnostics = batteries.evaluate(profiles, group, entities, {
        feasibility_only = true,
        max_seconds = 6,
        max_work = 100,
    })
    assert(#candidates == 0 and diagnostics.work_limit_reached and diagnostics.work <= 100)
end)

print(passed .. " tests passed")
