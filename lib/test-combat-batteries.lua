-- Run from the mod root: lua lib/test-combat-batteries.lua

local batteries = require("lib/combat-batteries")

local passed = 0
local function test(name, run)
    run()
    passed = passed + 1
    print("ok - " .. name)
end

local function profile(kind, amount, interval, mode)
    return {
        mode = mode or "turret",
        profile = {
            packets = {
                {
                    type = kind,
                    amount = amount or 10,
                    count = 1,
                },
            },
            interval_seconds = interval or 1,
        },
    }
end

local function target(immune)
    return {
        max_health = 10,
        resistances = {
            {
                type = immune,
                percent = 100,
            },
        },
    }
end

local function fixture()
    local profiles = {
        profile("test-first"),
        profile("test-second"),
    }
    local entities = {
        ["test-first-target"] = target("test-second"),
        ["test-second-target"] = target("test-first"),
    }
    local roster = {
        {
            entity = "test-first-target",
            amount = 10,
        },
        {
            entity = "test-second-target",
            amount = 10,
        },
    }
    return profiles, roster, entities
end

test("complementary profiles share one fixed ten-turret budget", function()
    local profiles, roster, entities = fixture()
    local candidates, diagnostics = batteries.evaluate(profiles, roster, entities)
    assert(#candidates == 1)
    local candidate = candidates[1]
    assert(candidate.left == 1 and candidate.right == 2)
    assert(candidate.left_count == 5 and candidate.right_count == 5)
    assert(candidate.clear_seconds == 2)
    assert(diagnostics.allocations_attempted == 9 and not diagnostics.truncated)
end)

test("manual sources are excluded without changing profile indexes", function()
    local profiles, roster, entities = fixture()
    table.insert(profiles, 1, profile("test-universal", 1000, 0.01, "manual"))
    local candidates = batteries.evaluate(profiles, roster, entities)
    assert(#candidates == 1)
    assert(candidates[1].left == 2 and candidates[1].right == 3)
end)

test("a flexible target batch can split between cohorts", function()
    local profiles, _, entities = fixture()
    entities["test-flexible"] = {max_health = 10}
    local roster = {
        {
            entity = "test-flexible",
            amount = 10,
        },
    }
    local candidates = batteries.evaluate(profiles, roster, entities)
    assert(#candidates == 1 and candidates[1].clear_seconds == 1)
    assert(candidates[1].left_count + candidates[1].right_count == 10)
end)

test("spawn generations cannot overlap their parents", function()
    local profiles, _, entities = fixture()
    entities["test-first-target"].dying_trigger_effect = {
        type = "create-entity",
        entity_name = "test-second-target",
    }
    local roster = {
        {
            entity = "test-first-target",
            amount = 5,
        },
    }
    local candidates = batteries.evaluate(profiles, roster, entities)
    assert(#candidates == 1)
    assert(candidates[1].left_count == 5 and candidates[1].right_count == 5)
    assert(candidates[1].clear_seconds == 2)
end)

test("the deployment limit applies to both cohorts together", function()
    local profiles, roster, entities = fixture()
    local candidates = batteries.evaluate(profiles, roster, entities, {deployment_count = 3})
    assert(#candidates == 1)
    assert(candidates[1].left_count == 1 and candidates[1].right_count == 2)
    assert(candidates[1].clear_seconds == 10)
end)

test("duration cutoffs cannot turn a slow schedule into a counter", function()
    local profiles, roster, entities = fixture()
    local candidates, diagnostics = batteries.evaluate(profiles, roster, entities, {max_seconds = 1})
    assert(#candidates == 0 and diagnostics.rejected["mixed-too-slow"] == 9)
end)

test("an uncovered target makes every allocation fail closed", function()
    local profiles, roster, entities = fixture()
    entities["test-first-target"].resistances[2] = {
        type = "test-first",
        percent = 100,
    }
    local candidates, diagnostics = batteries.evaluate(profiles, roster, entities)
    assert(#candidates == 0)
    assert(diagnostics.rejected["mixed-uncovered-target"] == 9)
end)

test("pair limits are deterministic and report incomplete coverage", function()
    local profiles, roster, entities = fixture()
    table.insert(profiles, profile("test-third"))
    table.insert(profiles, profile("test-fourth"))
    local candidates, diagnostics = batteries.evaluate(profiles, roster, entities, {max_pairs = 2})
    assert(#candidates == 2)
    assert(candidates[1].left == 1 and candidates[1].right == 2)
    assert(candidates[2].left == 1 and candidates[2].right == 3)
    assert(diagnostics.pairs_attempted == 2 and diagnostics.pair_limit_reached and diagnostics.truncated)
end)

test("a later faster alternative does not replace an earlier profile pair", function()
    local profiles, roster, entities = fixture()
    table.insert(profiles, profile("test-later", 100, 0.1))
    local candidates = batteries.evaluate(profiles, roster, entities)
    assert(#candidates == 3)
    assert(candidates[1].left == 1 and candidates[1].right == 2)
    assert(candidates[1].clear_seconds == 2)
    assert(candidates[2].clear_seconds < candidates[1].clear_seconds)
end)

test("work exhaustion emits no incomplete schedule", function()
    local profiles, roster, entities = fixture()
    local candidates, diagnostics = batteries.evaluate(profiles, roster, entities, {max_work = 1})
    assert(#candidates == 0)
    assert(diagnostics.work <= 1 and diagnostics.work_limit_reached and diagnostics.truncated)
end)

test("large repeated target counts do not require individual job objects", function()
    local profiles, roster, entities = fixture()
    roster[1].amount = 100000000
    roster[2].amount = 100000000
    local candidates, diagnostics = batteries.evaluate(profiles, roster, entities)
    assert(#candidates == 1 and candidates[1].clear_seconds == 20000000)
    assert(not diagnostics.truncated and diagnostics.work < 100000)
end)

test("too few turret profiles or slots produces no mixture", function()
    local profiles, roster, entities = fixture()
    assert(#batteries.evaluate(profiles, roster, entities, {deployment_count = 1}) == 0)
    profiles[2].mode = "manual"
    assert(#batteries.evaluate(profiles, roster, entities) == 0)
end)

test("caller options cannot exceed the ten-turret limit", function()
    local profiles, roster, entities = fixture()
    local okay = pcall(batteries.evaluate, profiles, roster, entities, {deployment_count = 11})
    assert(not okay)
end)

test("filtered pairs retain their schedule without spending budgets on earlier alternatives", function()
    local profiles, roster, entities = fixture()
    local baseline, baseline_diagnostics = batteries.evaluate(profiles, roster, entities)
    local first, second = profiles[1], profiles[2]
    local unused = profile("test-unused")
    unused.profile = {}
    table.insert(profiles, 1, unused)
    local calls = 0
    local candidates, diagnostics = batteries.evaluate(profiles, roster, entities, {
        max_pairs = 1,
        max_work = baseline_diagnostics.work,
        pair_allowed = function(left, right)
            calls = calls + 1
            return left == first and right == second
        end,
    })
    assert(calls == 3 and #candidates == 1)
    local candidate, expected = candidates[1], baseline[1]
    assert(candidate.left == 2 and candidate.right == 3)
    assert(candidate.clear_seconds == expected.clear_seconds)
    assert(candidate.left_count == expected.left_count and candidate.right_count == expected.right_count)
    assert(diagnostics.pairs_attempted == 1 and not diagnostics.truncated)
    assert(diagnostics.work == baseline_diagnostics.work)
end)

test("rejecting every pair performs no profile preparation or allocation work", function()
    local profiles, roster, entities = fixture()
    profiles[1].profile = {}
    profiles[2].profile = {}
    local candidates, diagnostics = batteries.evaluate(profiles, roster, entities, {
        max_pairs = 1,
        max_work = 1,
        pair_allowed = function() return false end,
    })
    assert(#candidates == 0 and diagnostics.pairs_attempted == 0)
    assert(diagnostics.work == 0 and diagnostics.allocations_attempted == 0)
    assert(not diagnostics.truncated and next(diagnostics.rejected) == nil)
end)

test("allowing a pair does not certify an uncovered target", function()
    local profiles, roster, entities = fixture()
    entities["test-first-target"].resistances[2] = {
        type = "test-first",
        percent = 100,
    }
    local candidates, diagnostics = batteries.evaluate(profiles, roster, entities, {
        pair_allowed = function() return true end,
    })
    assert(#candidates == 0 and diagnostics.pairs_attempted == 1)
    assert(diagnostics.rejected["mixed-uncovered-target"] == 9)
end)

local function materials(amount)
    local profiles, _, _ = fixture()
    local entities, roster = {}, {}
    for index = 1, 3 do
        local left, right = "test-left-" .. index, "test-right-" .. index
        entities[left] = target("test-second")
        entities[right] = target("test-first")
        table.insert(roster, {
            entity = left,
            amount = amount,
        })
        table.insert(roster, {
            entity = right,
            amount = amount,
        })
    end
    return profiles, roster, entities
end

test("different materials share each cohort's available turrets concurrently", function()
    local profiles, roster, entities = materials(1)
    local candidates = batteries.evaluate(profiles, roster, entities, {deployment_count = 6})
    assert(#candidates == 1)
    assert(candidates[1].left_count == 3 and candidates[1].right_count == 3)
    assert(candidates[1].clear_seconds == 1)
end)

test("concurrent material schedules still charge the complete assigned workload", function()
    local profiles, roster, entities = materials(4)
    local candidates = batteries.evaluate(profiles, roster, entities, {deployment_count = 6})
    assert(#candidates == 1)
    -- Each cohort clears twelve entities with three independent turrets, not four per material simultaneously.
    assert(candidates[1].left_count == 3 and candidates[1].right_count == 3)
    assert(candidates[1].clear_seconds == 4)
end)

test("concurrent material schedules do not overlap descendant generations", function()
    local profiles, _, entities = materials(1)
    local roster = {}
    for index = 1, 3 do
        local name = "test-left-" .. index
        entities[name].dying_trigger_effect = {
            type = "create-entity",
            entity_name = "test-right-" .. index,
        }
        table.insert(roster, {
            entity = name,
            amount = 1,
        })
    end
    local candidates = batteries.evaluate(profiles, roster, entities, {deployment_count = 6})
    assert(#candidates == 1 and candidates[1].clear_seconds == 2)
end)

test("the default work budget completes a bounded multi-profile multi-material search", function()
    local profiles, entities, roster = {}, {}, {}
    for index = 1, 7 do
        profiles[index] = profile("test-damage", 10 + index, index / 10)
    end
    for index = 1, 4 do
        local name = "test-material-" .. index
        entities[name] = {max_health = 100}
        table.insert(roster, {
            entity = name,
            amount = 10 + index,
        })
    end
    local candidates, diagnostics = batteries.evaluate(profiles, roster, entities)
    assert(#candidates == 21 and diagnostics.pairs_attempted == 21)
    assert(not diagnostics.truncated and diagnostics.work > 100000 and diagnostics.work <= 500000)
end)

test("feasibility search stops at a complete within-limit schedule for each pair", function()
    local profiles, roster, entities = fixture()
    local ordinary, full = batteries.evaluate(profiles, roster, entities)
    local candidates, early = batteries.evaluate(profiles, roster, entities, {
        feasibility_only = true,
        max_seconds = 10,
    })
    assert(#candidates == 1 and #ordinary == 1)
    local candidate = candidates[1]
    assert(candidate.clear_seconds == 10 and ordinary[1].clear_seconds == 2)
    assert(candidate.clear_seconds == math.max(math.ceil(10 / candidate.left_count), math.ceil(10 / candidate.right_count)))
    assert(candidate.left_count + candidate.right_count == 10)
    assert(early.allocations_attempted == 1 and full.allocations_attempted == 9 and early.work < full.work)
    table.insert(profiles, profile("test-universal"))
    candidates, early = batteries.evaluate(profiles, roster, entities, {
        feasibility_only = true,
        max_seconds = 10,
    })
    assert(#candidates == 3 and early.pairs_attempted == 3 and early.allocations_attempted == 3)
    assert(candidates[3].left == 2 and candidates[3].right == 3)
end)

test("feasibility still charges descendant generations and fails closed at limits", function()
    local profiles, _, entities = fixture()
    entities["test-first-target"].dying_trigger_effect = {
        type = "create-entity",
        entity_name = "test-second-target",
    }
    local roster = {
        {
            entity = "test-first-target",
            amount = 5,
        },
    }
    local candidates = batteries.evaluate(profiles, roster, entities, {
        feasibility_only = true,
        max_seconds = 5.5,
    })
    assert(#candidates == 1)
    local candidate = candidates[1]
    assert(candidate.clear_seconds == math.ceil(5 / candidate.left_count) + math.ceil(5 / candidate.right_count))
    assert(candidate.clear_seconds <= 5.5)
    assert(#batteries.evaluate(profiles, roster, entities, {
        feasibility_only = true,
        max_seconds = 1.5,
    }) == 0)
    local diagnostics
    candidates, diagnostics = batteries.evaluate(profiles, roster, entities, {
        feasibility_only = true,
        max_seconds = 5.5,
        max_work = 100,
    })
    assert(#candidates == 0 and diagnostics.work_limit_reached and diagnostics.work <= 100)
end)

print(passed .. " tests passed")
