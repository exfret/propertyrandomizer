-- Run from the mod root: lua tests/unit/prototypes/combat/test-combat-type-safety.lua

local safety = require("src/prototypes/combat/combat-type-safety")

local passed = 0
local function test(name, run)
    run()
    passed = passed + 1
    print("ok - " .. name)
end

local function resistance(kind, decrease, percent)
    return {
        type = kind,
        decrease = decrease,
        percent = percent,
    }
end

local function definition(name, target)
    return {
        name = name,
        targets = {
            {
                entity = target or "test-target",
                amount = 1,
            },
        },
    }
end

local function fixture()
    local definitions = {definition("test-encounter")}
    local entities = {
        ["test-target"] = {
            max_health = 100,
            resistances = {
                resistance("test-old", 10, 50),
                resistance("test-new", 5, 20),
            },
        },
    }
    return definitions, {}, entities
end

local function scored_counter(mode)
    return {
        policy = {
            clear_seconds = 10,
            turret_count = 10,
            manual_count = 1,
        },
        counters = {
            ["test-counter"] = {
                mode = mode or "turret",
                count = 1,
                clear_seconds = 9,
                prerequisites = {"test-source: test-item"},
            },
        },
    }
end

local function spawn(name)
    return {
        type = "create-entity",
        entity_name = name,
    }
end

test("unscored encounters permit only componentwise weaker resistance", function()
    local definitions, evaluated, entities = fixture()
    local guard = safety.new(definitions, evaluated, entities)
    assert(guard.unscored_count == 1 and guard.part_count == 1 and not guard.blocked)
    assert(guard.allows("test-old", "test-new"))
    local allowed, reason, details = guard.allows("test-new", "test-old")
    assert(not allowed and reason == "unscored-target-resistance-increase")
    assert(details.entity == "test-target" and details.encounter == "test-encounter")
    assert(details.old_decrease == 5 and details.new_decrease == 10)
end)

test("one improved resistance component cannot pay for another worsened component", function()
    local definitions, evaluated, entities = fixture()
    entities["test-target"].resistances[2].decrease = 11
    entities["test-target"].resistances[2].percent = 0
    assert(not safety.new(definitions, evaluated, entities).allows("test-old", "test-new"))
    entities["test-target"].resistances[2].decrease = 0
    entities["test-target"].resistances[2].percent = 51
    assert(not safety.new(definitions, evaluated, entities).allows("test-old", "test-new"))
end)

test("omitted resistance entries and omitted components use zero", function()
    local definitions, evaluated, entities = fixture()
    entities["test-target"].resistances = {
        resistance("test-old"),
    }
    local guard = safety.new(definitions, evaluated, entities)
    assert(guard.allows("test-old", "test-new"))
    assert(guard.allows("test-new", "test-old"))
    entities["test-target"].resistances = nil
    assert(safety.new(definitions, evaluated, entities).allows("test-old", "test-new"))
end)

test("a valid existing counter excludes its encounter from this fallback", function()
    local definitions, evaluated, entities = fixture()
    evaluated["test-encounter"] = scored_counter()
    local guard = safety.new(definitions, evaluated, entities)
    assert(guard.unscored_count == 0 and guard.part_count == 0)
    assert(guard.allows("test-new", "test-old"))
    evaluated["test-encounter"] = scored_counter("manual")
    assert(safety.new(definitions, evaluated, entities).unscored_count == 0)
end)

test("a nonempty counter map without a timely valid witness remains unscored", function()
    local definitions, evaluated, entities = fixture()
    local result = scored_counter()
    evaluated["test-encounter"] = result
    local counter = result.counters["test-counter"]
    counter.clear_seconds = 10.001
    assert(safety.new(definitions, evaluated, entities).unscored_count == 1)
    counter.clear_seconds = 0 / 0
    assert(safety.new(definitions, evaluated, entities).unscored_count == 1)
    counter.clear_seconds = 9
    counter.count = 11
    assert(safety.new(definitions, evaluated, entities).unscored_count == 1)
    counter.count = false
    assert(safety.new(definitions, evaluated, entities).unscored_count == 1)
    counter.count = 1
    counter.mode = "test-invalid-mode"
    assert(safety.new(definitions, evaluated, entities).unscored_count == 1)
    counter.mode = "manual"
    counter.count = 2
    assert(safety.new(definitions, evaluated, entities).unscored_count == 1)
    counter.count = 1
    counter.prerequisites = {}
    assert(safety.new(definitions, evaluated, entities).unscored_count == 1)
end)

test("all unscored targets matter while successfully scored targets do not constrain the fallback", function()
    local definitions, evaluated, entities = fixture()
    table.insert(definitions, definition("test-other-encounter", "test-other-target"))
    entities["test-other-target"] = {
        max_health = 10,
        resistances = {resistance("test-new", 20, 90)},
    }
    assert(not safety.new(definitions, evaluated, entities).allows("test-old", "test-new"))
    evaluated["test-other-encounter"] = scored_counter()
    local guard = safety.new(definitions, evaluated, entities)
    assert(guard.unscored_count == 1 and guard.allows("test-old", "test-new"))
end)

test("death children constrain type changes even when the parent improves", function()
    local definitions, evaluated, entities = fixture()
    entities["test-target"].dying_trigger_effect = spawn("test-child")
    entities["test-child"] = {
        max_health = 5,
        resistances = {resistance("test-new", 1, 0)},
    }
    local guard = safety.new(definitions, evaluated, entities)
    assert(guard.part_count == 2)
    local allowed, _, details = guard.allows("test-old", "test-new")
    assert(not allowed and details.entity == "test-child")
end)

test("all shared-health segments and their death children are checked", function()
    local definitions, evaluated, entities = fixture()
    entities["test-target"].segment_engine = {
        segments = {
            {segment = "test-segment"},
        },
    }
    entities["test-segment"] = {
        name = "test-segment",
        max_health = 10,
        dying_trigger_effect = spawn("test-child"),
    }
    entities["test-child"] = {
        max_health = 5,
        resistances = {resistance("test-new", 0, 1)},
    }
    local guard = safety.new(definitions, evaluated, entities)
    assert(guard.part_count == 3 and not guard.allows("test-old", "test-new"))
    entities["test-child"].resistances = nil
    entities["test-segment"].resistances = {resistance("test-new", 0, 1)}
    local allowed, _, details = safety.new(definitions, evaluated, entities).allows("test-old", "test-new")
    assert(not allowed and details.entity == "test-segment")
end)

test("unknown lifecycle effects and attack reactions block categorical changes", function()
    local definitions, evaluated, entities = fixture()
    entities["test-target"].dying_trigger_effect = {type = "test-unknown-effect"}
    local guard = safety.new(definitions, evaluated, entities)
    assert(guard.blocked and not guard.allows("test-old", "test-new"))
    assert(guard.allows("test-old", "test-old"))
    entities["test-target"].dying_trigger_effect = nil
    entities["test-target"].attack_reaction = {{damage_type = "test-old"}}
    guard = safety.new(definitions, evaluated, entities)
    assert(guard.blocked and guard.reason == "unsupported-target-reaction")
end)

test("missing targets or a known incomplete roster cannot yield a partial proof", function()
    local definitions, evaluated, entities = fixture()
    entities["test-target"] = nil
    local guard = safety.new(definitions, evaluated, entities)
    assert(guard.blocked and guard.reason == "missing-target")
    definitions[1].targets_complete = false
    evaluated["test-encounter"] = scored_counter()
    guard = safety.new(definitions, evaluated, entities)
    assert(guard.unscored_count == 1 and guard.blocked and guard.reason == "incomplete-target-roster")
end)

test("unsupported and duplicate resistances fail closed even for a different damage type", function()
    local definitions, evaluated, entities = fixture()
    table.insert(entities["test-target"].resistances, resistance("test-other", -1, 0))
    local guard = safety.new(definitions, evaluated, entities)
    assert(guard.blocked and guard.reason == "unsupported-resistance")
    entities["test-target"].resistances[3] = resistance("test-new", 0, 0)
    guard = safety.new(definitions, evaluated, entities)
    assert(guard.blocked and guard.reason == "duplicate-resistance")
    entities["test-target"].resistances[3] = resistance("test-other", 0, 101)
    assert(safety.new(definitions, evaluated, entities).blocked)
    entities["test-target"].resistances[3] = resistance("test-other", 0 / 0, 0)
    assert(safety.new(definitions, evaluated, entities).blocked)
    entities["test-target"].resistances[3] = resistance("test-other", false, 0)
    assert(safety.new(definitions, evaluated, entities).blocked)
end)

test("resolver callbacks are reused and callback errors fail closed", function()
    local definitions, evaluated, entities = fixture()
    entities["test-target"].damaged_trigger_effect = {type = "test-visual-effect"}
    local options = {
        entity_of = function(name) return entities[name] end,
        visual_effect = function(effect) return effect.type == "test-visual-effect" end,
    }
    local guard = safety.new(definitions, evaluated, {}, options)
    assert(not guard.blocked and guard.allows("test-old", "test-new"))
    options.visual_effect = function() error("test-callback-error") end
    guard = safety.new(definitions, evaluated, {}, options)
    assert(guard.blocked and guard.reason == "target-resolution-error")
end)

test("unique target parts are shared across evolution benchmarks", function()
    local definitions, evaluated, entities = fixture()
    table.insert(definitions, definition("test-other-evolution"))
    local guard = safety.new(definitions, evaluated, entities)
    assert(guard.unscored_count == 2 and guard.part_count == 1 and #guard.details == 2)
end)

test("resolver and guard budgets never permit a truncated proof", function()
    local definitions, evaluated, entities = fixture()
    entities["test-target"].dying_trigger_effect = spawn("test-child")
    entities["test-child"] = {max_health = 10}
    local guard = safety.new(definitions, evaluated, entities, {max_nodes = 1})
    assert(guard.blocked and guard.reason == "target-node-budget")
    guard = safety.new(definitions, evaluated, entities, {max_parts = 1})
    assert(guard.blocked and guard.reason == "target-part-budget")
    guard = safety.new(definitions, evaluated, entities, {max_resistance_entries = 1})
    assert(guard.blocked and guard.reason == "resistance-entry-budget")
    table.insert(definitions, definition("test-other-evolution"))
    guard = safety.new(definitions, evaluated, entities, {max_roster_entries = 1})
    assert(guard.blocked and guard.reason == "target-roster-budget")
    guard = safety.new(definitions, evaluated, entities, {max_definitions = 1})
    assert(guard.blocked and guard.reason == "definition-budget")
    assert(not guard.allows("test-old", "test-new"))
end)

test("cycle detection and malformed target data fail closed", function()
    local definitions, evaluated, entities = fixture()
    entities["test-target"].dying_trigger_effect = spawn("test-target")
    local guard = safety.new(definitions, evaluated, entities)
    assert(guard.blocked and guard.reason == "target-spawn-cycle")
    definitions[1].targets[1] = false
    guard = safety.new(definitions, evaluated, entities)
    assert(guard.blocked and guard.reason == "target-resolution-error")
end)

test("snapshots do not change beneath a sequence of categorical packet mutations", function()
    local definitions, evaluated, entities = fixture()
    local guard = safety.new(definitions, evaluated, entities)
    entities["test-target"].resistances[2].decrease = 100
    assert(guard.allows("test-old", "test-new"))
    assert(not safety.new(definitions, evaluated, entities).allows("test-old", "test-new"))
    assert(not guard.allows(nil, "test-new"))
end)

print(passed .. " tests passed")
