-- Plain-Lua regression tests for encounter definitions and their graph foundation.
-- Run from the mod root: lua lib/logic/test-combat-encounters.lua

function table.deepcopy(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end
function log(message) end
serpent = { block = tostring }
package.loaded["lib/random/rng"] = { int = function(_, maximum) return maximum end }
package.loaded["lib/data-utils"] = { get_prot = function() return nil end }
local logic = {
    contexts = {},
    type_info = {},
    edge_info = {},
}
package.loaded["lib/logic/state"] = logic
package.loaded["lib/logic/init"] = logic

local model = require("lib/combat-encounters")
local encounters = require("lib/logic/combat-encounters")
local builder = require("lib/logic/builder")
local setup = require("lib/logic/graph-setup")
local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")

local key = gutils.key
local passed = 0
local function test(name, run)
    run()
    passed = passed + 1
    print("ok - " .. name)
end

local function equal(left, right)
    if type(left) ~= "table" or type(right) ~= "table" then
        return left == right
    end
    for k, value in pairs(left) do
        if not equal(value, right[k]) then
            return false
        end
    end
    for k, _ in pairs(right) do
        if left[k] == nil then
            return false
        end
    end
    return true
end

local HOME = "planet: test-home"
local AWAY = "planet: test-away"
local SPACE = "surface: test-platform"
local FIREPOWER = key("test-source", "test-firepower")
local AMMUNITION = key("test-source", "test-ammunition")

local function target_entry(entity, amount, share)
    return {
        entity = entity,
        amount = amount,
        share = share,
    }
end

local function spawn_entry(unit, initial_weight, final_weight)
    return {
        unit,
        {
            {
                0,
                initial_weight,
            },
            {
                1,
                final_weight,
            },
        },
    }
end

local function definition(kind)
    return {
        name = "test-encounter",
        kind = kind or "spawn-group",
        room = HOME,
        source = "test-spawner",
        evolution = 0,
        targets = { target_entry("test-target", 20) },
        nominal_size = 20,
        actual_size = 20,
        workload_calibrated = true,
        policy = model.policy(),
    }
end

local function counter(mode, seconds, count)
    return {
        name = "test-counter",
        prerequisites = { FIREPOWER },
        mode = mode or "turret",
        clear_seconds = seconds or 10,
        count = count,
    }
end

local function build(definitions, options, unavailable_ammunition)
    logic.graph = {}
    logic.contexts = {
        [HOME] = true,
        [AWAY] = true,
        [SPACE] = true,
    }
    logic.type_info = {}
    logic.edge_info = {}
    builder.init(logic.graph, logic.type_info, logic.edge_info)
    builder.set_class("test-encounter-fixture")
    builder.set_prot(nil)
    builder.add_node("test-start", "AND", nil, "test-start")
    builder.add_node("room", "OR", "room", HOME)
    builder.add_edge("test-start", "test-start")
    builder.add_node("room", "OR", "room", AWAY)
    builder.add_edge("test-start", "test-start")
    builder.add_node("room", "OR", "room", SPACE)
    builder.add_edge("test-start", "test-start")
    builder.add_node("space-surface", "OR", nil, "")
    builder.add_edge("room", SPACE)
    builder.add_node("test-source", "AND", nil, "test-firepower")
    -- An unavailable second prerequisite must prevent the entire counter.
    builder.add_node("test-ammo", "OR", nil, "test-ammo")
    if unavailable_ammunition ~= true then
        builder.add_edge("test-start", "test-start")
    end
    builder.add_node("test-source", "AND", nil, "test-ammunition")
    builder.add_edge("test-ammo", "test-ammo")
    encounters.build_definitions(logic.graph, definitions, options or {})
    setup.build(logic)
    local sorted = top.sort(logic.graph, nil, nil, { complex_contexts = true })
    return logic.graph, sorted
end

local function reachable(sorted, name, room, abilities)
    local contexts = sorted.node_to_context_inds[key("combat-encounter", name)] or {}
    return contexts[top.context_key(room or HOME, abilities or "00")] ~= nil
end

local function with_counter(candidate, encounter, options, unavailable_ammunition)
    options = options or {}
    options.counter_provider = function() return { candidate } end
    return build({ encounter or definition() }, options, unavailable_ammunition)
end

test("the normal policy fixes deployment and clearing time independently of roster size", function()
    local policy = model.policy()
    assert(policy.difficulty == "normal")
    assert(policy.check_enemies)
    assert(policy.baseline_seconds == 10 and policy.clear_seconds == 10)
    assert(policy.turret_count == 10 and policy.manual_count == 1)
    local harder = model.policy({ time_multiplier = 2 })
    assert(harder.baseline_seconds == 10 and harder.clear_seconds == 20)
    assert(harder.turret_count == 10 and harder.manual_count == 1)
end)

test("No Cap disables terrestrial requirements while preserving the asteroid time budget", function()
    local policy = model.policy({ difficulty = "no-cap" })
    assert(not policy.check_enemies)
    assert(policy.baseline_seconds == 10 and policy.clear_seconds == 10)
end)

test("duplicate spawn entries are summed before ceiling and zero weights stay absent", function()
    local spawner = {
        result_units = {
            spawn_entry("test-common", 8, 8),
            spawn_entry("test-rare", 1, 1),
            spawn_entry("test-common", 1, 1),
            spawn_entry("test-absent", 0, 0),
        },
    }
    local targets, total = model.spawn_targets(spawner, 0.4, 3)
    assert(equal(targets, {
        target_entry("test-common", 3, 0.9),
        target_entry("test-rare", 1, 0.1),
    }))
    assert(total == 4)
    local reversed = table.deepcopy(spawner)
    for i = 1, #spawner.result_units do
        reversed.result_units[i] = spawner.result_units[#spawner.result_units - i + 1]
    end
    assert(equal(targets, model.spawn_targets(reversed, 0.4, 3)))
end)

test("evolution samples interpolate spawn weights instead of retaining absent targets", function()
    local spawner = {
        result_units = {
            spawn_entry("test-early", 1, 0),
            spawn_entry("test-late", 0, 1),
        },
    }
    assert(equal(model.spawn_targets(spawner, 0, 10), { target_entry("test-early", 10, 1) }))
    assert(equal(model.spawn_targets(spawner, 0.4, 10), {
        target_entry("test-early", 6, 0.6),
        target_entry("test-late", 4, 0.4),
    }))
    assert(equal(model.spawn_targets(spawner, 1, 10), { target_entry("test-late", 10, 1) }))
end)

local function spawn_point(evolution, weight)
    return {
        evolution_factor = evolution,
        spawn_weight = weight,
    }
end

test("floating-point noise does not add a target to an exact integer mixture", function()
    local spawner = {
        result_units = {
            {
                unit = "test-early",
                spawn_points = {
                    spawn_point(0, 0.3),
                    spawn_point(0.6, 0),
                },
            },
            {
                unit = "test-middle",
                spawn_points = {
                    spawn_point(0.2, 0),
                    spawn_point(0.6, 0.3),
                    spawn_point(0.7, 0.1),
                },
            },
            {
                unit = "test-large",
                spawn_points = {
                    spawn_point(0.5, 0),
                    spawn_point(1, 0.4),
                },
            },
            {
                unit = "test-late",
                spawn_points = {
                    spawn_point(0.9, 0),
                    spawn_point(1, 0.3),
                },
            },
        },
    }
    local targets, total = model.spawn_targets(spawner, 0.4, 20)
    assert(#targets == 2 and total == 20)
    assert(targets[1].entity == "test-early" and targets[1].amount == 8)
    assert(targets[2].entity == "test-middle" and targets[2].amount == 12)
end)

test("rounding tolerance never drops a positive rare target", function()
    local targets, total = model.spawn_targets({
        result_units = {
            spawn_entry("test-common", 1, 1),
            spawn_entry("test-rare", 1e-30, 1e-30),
        },
    }, 0.4, 20)
    assert(#targets == 2 and total == 21)
    assert(targets[2].entity == "test-rare" and targets[2].amount == 1)
end)

local function collection_fixture()
    local spawner = {
        name = "test-spawner",
        max_friends_around_to_spawn = 5,
        result_units = { spawn_entry("test-target", 1, 1) },
    }
    local target = {
        name = "test-target",
        max_health = 100,
        resistances = {
            {
                type = "test-damage",
                percent = 25,
            },
        },
    }
    local lu = {
        rooms = {
            [HOME] = {
                type = "planet",
                name = "test-home",
            },
        },
        entities = {
            [spawner.name] = spawner,
            [target.name] = target,
        },
    }
    local options = {
        in_room = function() return true end,
        planet_of = function() return {} end,
    }
    return lu, options, spawner, target
end

test("collection builds six fixed evolution samples using the selected group-size heuristic", function()
    local lu, options = collection_fixture()
    local definitions = model.collect(lu, options)
    assert(#definitions == 6)
    for i, encounter in pairs(definitions) do
        assert(encounter.kind == "spawn-group")
        assert(encounter.evolution == (i - 1) / 5)
        assert(encounter.nominal_size == 20 and encounter.actual_size == 20)
        assert(encounter.targets[1].amount == 20)
        assert(encounter.workload_calibrated)
    end
    options.group_size = function() return 3 end
    assert(model.collect(lu, options)[1].targets[1].amount == 3)
end)

test("missing spawn limits leave workloads uncalibrated and target snapshots remain independent", function()
    local lu, options, spawner, target = collection_fixture()
    spawner.max_friends_around_to_spawn = nil
    local definitions = model.collect(lu, options)
    assert(#definitions == 6)
    assert(not definitions[1].workload_calibrated)
    assert(definitions[1].targets[1].amount == nil)
    assert(definitions[1].actual_size == nil)
    target.resistances[1].percent = 95
    assert(definitions[1].targets[1].reference.resistances[1].percent == 25)
    definitions[1].targets[1].reference.resistances[1].percent = 50
    assert(definitions[2].targets[1].reference.resistances[1].percent == 25)
end)

test("territory variants stay separate singleton encounters", function()
    local lu, options = collection_fixture()
    lu.entities["test-spawner"] = nil
    lu.entities["test-second-target"] = {
        name = "test-second-target",
        max_health = 200,
    }
    options.planet_of = function()
        return {
            map_gen_settings = {
                territory_settings = {
                    units = {
                        "test-target",
                        "test-second-target",
                        "test-target",
                    },
                },
            },
        }
    end
    local definitions = model.collect(lu, options)
    assert(#definitions == 2)
    for _, encounter in pairs(definitions) do
        assert(encounter.kind == "territory")
        assert(encounter.actual_size == 1 and #encounter.targets == 1)
        assert(encounter.targets[1].amount == 1)
    end
end)

test("asteroid rates remain inputs until a count adapter calibrates every target", function()
    local lu, options = collection_fixture()
    options.difficulty = "no-cap"
    options.connections = {
        ["test-route"] = {
            name = "test-route",
            asteroid_spawn_definitions = {
                {
                    asteroid = "test-target",
                    spawn_points = {
                        {
                            distance = 0,
                            probability = 0.1,
                            speed = 0.02,
                        },
                        {
                            distance = 1,
                            probability = 0.2,
                            speed = 0.03,
                        },
                    },
                },
            },
        },
    }
    local definitions = model.collect(lu, options)
    assert(#definitions == 1 and definitions[1].kind == "asteroid-route")
    assert(not definitions[1].workload_calibrated)
    assert(definitions[1].targets[1].amount == nil)
    assert(definitions[1].targets[1].spawn_curves[1][2].probability == 0.2)
    options.asteroid_counts = function() return { ["test-target"] = 7 } end
    definitions = model.collect(lu, options)
    assert(definitions[1].workload_calibrated)
    assert(definitions[1].actual_size == 7 and definitions[1].targets[1].amount == 7)
end)

test("an anchor alone cannot satisfy an unscored encounter", function()
    local graph, sorted = build({ definition() })
    local node = graph.nodes[key("combat-encounter", "test-encounter")]
    assert(node.mechanic)
    assert(node.evaluation.status == "unscored")
    assert(not reachable(sorted, "test-encounter"))
    assert(not reachable(sorted, "test-encounter", HOME, "01"))
end)

test("a counter at the time limit preserves automatic and manual contexts on its own room", function()
    local _, sorted = with_counter(counter("turret", 10))
    assert(reachable(sorted, "test-encounter"))
    assert(reachable(sorted, "test-encounter", HOME, "01"))
    assert(not reachable(sorted, "test-encounter", AWAY))
end)

test("manual counters never manufacture an automatic context from automated inputs", function()
    local _, sorted = with_counter(counter("manual", 10))
    assert(reachable(sorted, "test-encounter"))
    assert(not reachable(sorted, "test-encounter", HOME, "01"))
    assert(not reachable(sorted, "test-encounter", HOME, "11"))
end)

test("all prerequisites of a counter are needed", function()
    local candidate = counter()
    candidate.prerequisites = {
        FIREPOWER,
        AMMUNITION,
    }
    local _, sorted = with_counter(candidate, nil, nil, true)
    assert(not reachable(sorted, "test-encounter"))
end)

test("an uncalibrated workload cannot be certified by a supplied time estimate", function()
    local encounter = definition()
    encounter.workload_calibrated = false
    encounter.targets[1].amount = nil
    local _, sorted = with_counter(counter(), encounter)
    assert(not reachable(sorted, "test-encounter"))
end)

test("an unavailable encounter anchor never grants a context or calls the provider", function()
    local encounter = definition()
    encounter.anchor = key("room", "planet: test-unavailable")
    local calls = 0
    local graph, sorted = build({ encounter }, {
        counter_provider = function()
            calls = calls + 1
            return { counter() }
        end,
    })
    assert(calls == 0)
    assert(not reachable(sorted, encounter.name))
    assert(graph.nodes[key("combat-encounter", encounter.name)].evaluation.reason == "missing-anchor")
end)

test("invalid times and deployments fail closed", function()
    local invalid = {
        counter("turret", 10.001),
        counter("turret", 0),
        counter("turret", -1),
        counter("turret", math.huge),
        counter("turret", 0 / 0),
        counter("turret", 1, 11),
        counter("manual", 1, 2),
        counter("turret", 1, 0),
        counter("turret", 1, -1),
        counter("turret", 1, 1.5),
        counter("turret", 1, math.huge),
    }
    for _, candidate in pairs(invalid) do
        local graph, sorted = with_counter(candidate)
        assert(not reachable(sorted, "test-encounter"))
        local evaluation = graph.nodes[key("combat-encounter", "test-encounter")].evaluation
        assert(evaluation.accepted == 0 and #evaluation.rejected == 1)
    end
end)

test("missing or empty prerequisite lists cannot create a free counter", function()
    local invalid = {
        counter(),
        counter(),
        counter(),
    }
    invalid[1].prerequisites = {}
    invalid[2].prerequisites = nil
    invalid[3].prerequisites = { key("test-source", "test-missing") }
    for _, candidate in pairs(invalid) do
        local _, sorted = with_counter(candidate)
        assert(not reachable(sorted, "test-encounter"))
    end
end)

test("providers receive independent workload snapshots", function()
    local original = definition()
    local graph, sorted = build({ original }, {
        counter_provider = function(encounter)
            encounter.targets[1].amount = 1
            return { counter() }
        end,
    })
    assert(reachable(sorted, "test-encounter"))
    assert(original.targets[1].amount == 20)
    assert(graph.nodes[key("combat-encounter", original.name)].encounter.targets[1].amount == 20)
end)

test("missing target prototypes remain visible and prevent evaluation", function()
    local lu, options = collection_fixture()
    lu.entities["test-target"] = nil
    local definitions = model.collect(lu, options)
    assert(definitions[1].targets[1].entity == "test-target")
    assert(definitions[1].targets_complete == false)
    local calls = 0
    local _, sorted = build(definitions, {
        counter_provider = function()
            calls = calls + 1
            return { counter() }
        end,
    })
    assert(calls == 0)
    assert(not reachable(sorted, definitions[1].name))
end)

test("No Cap also filters precollected terrestrial definitions and retains asteroid alternatives", function()
    local terrestrial = definition()
    local asteroid = definition("asteroid-route")
    asteroid.name = "test-asteroids"
    asteroid.room = nil
    asteroid.anchor = key("space-surface", "")
    local graph, sorted = build({
        terrestrial,
        asteroid,
    }, {
        difficulty = "no-cap",
        counter_provider = function() return { counter() } end,
    })
    assert(graph.nodes[key("combat-encounter", terrestrial.name)] == nil)
    assert(reachable(sorted, asteroid.name, SPACE, "01"))
    assert(not reachable(sorted, asteroid.name))
    assert(not reachable(sorted, asteroid.name, AWAY, "01"))
end)

print(passed .. " tests passed")
