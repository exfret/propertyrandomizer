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
local rng_state = 1
local rng = {}
rng.int = function(_, maximum)
    rng_state = (rng_state * 48271) % 2147483647
    return rng_state % maximum + 1
end
rng.value = function(rng_key) return rng.int(rng_key, 1000000) / 1000000 end
rng.shuffle = function(rng_key, values)
    for i = #values, 2, -1 do
        local j = rng.int(rng_key, i)
        values[i], values[j] = values[j], values[i]
    end
end
rng.key = function(value) return value.id end
package.loaded["lib/random/rng"] = rng
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
local counters = require("lib/logic/combat-counters")
local builder = require("lib/logic/builder")
local setup = require("lib/logic/graph-setup")
local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local matching = require("randomizations/graph/unified/skeleton/monotone-matching")

local key = gutils.key
local passed = 0
local function test(name, run)
    run()
    passed = passed + 1
    print("ok - " .. name)
end

test("disabled combat randomization does not prepare the expensive scorer", function()
    local previous_config, prepare = config, counters.prepare
    config = {damage_type_randomization = false}
    counters.prepare = function() error("Disabled combat scorer ran") end
    local supplied, diagnostics = encounters.prepare({}, {
        connections = {},
        locations = {},
        definitions = {},
    })
    counters.prepare, config = prepare, previous_config
    assert(supplied.counter_provider == nil and diagnostics == nil)
    assert(supplied.reference_ship == nil and supplied.asteroid_counts == nil)
end)

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

local function collection_fixture()
    return {
        from = "test-start-location",
        to = "test-collection-location",
        length = 1000,
    }, {
        ["test-start-location"] = { fly_condition = false },
        ["test-collection-location"] = { fly_condition = true },
    }
end

test("collection windows follow the first distance toward the flying endpoint", function()
    local connection, locations = collection_fixture()
    local lower, upper, endpoint = encounters.collection_window(connection, locations, 250)
    assert(lower == 0 and upper == 0.25 and endpoint == connection.to)
end)

test("reversed collection connections use the corresponding normalized window", function()
    local connection, locations = collection_fixture()
    connection.from, connection.to = connection.to, connection.from
    local lower, upper, endpoint = encounters.collection_window(connection, locations, 250)
    assert(lower == 0.75 and upper == 1 and endpoint == connection.from)
end)

test("ordinary and ambiguous collection routes retain their full windows", function()
    local connection, locations = collection_fixture()
    locations[connection.to].fly_condition = false
    local lower, upper, endpoint = encounters.collection_window(connection, locations, 250)
    assert(lower == 0 and upper == 1 and endpoint == nil)
    locations[connection.from].fly_condition = true
    locations[connection.to].fly_condition = true
    lower, upper, endpoint = encounters.collection_window(connection, locations, 250)
    assert(lower == 0 and upper == 1 and endpoint == nil)
    lower, upper, endpoint = encounters.collection_window(connection, {}, 250)
    assert(lower == 0 and upper == 1 and endpoint == nil)
end)

test("an unspecified collection distance retains the full route", function()
    local connection, locations = collection_fixture()
    local lower, upper, endpoint = encounters.collection_window(connection, locations)
    assert(lower == 0 and upper == 1 and endpoint == nil)
end)

test("collection windows clamp to a short route and use the default length when absent", function()
    local connection, locations = collection_fixture()
    connection.length = 100
    local lower, upper, endpoint = encounters.collection_window(connection, locations, 250)
    assert(lower == 0 and upper == 1 and endpoint == connection.to)
    connection.from, connection.to = connection.to, connection.from
    lower, upper, endpoint = encounters.collection_window(connection, locations, 250)
    assert(lower == 0 and upper == 1 and endpoint == connection.from)
    connection.length = nil
    lower, upper, endpoint = encounters.collection_window(connection, locations, 150)
    assert(lower == 0.75 and upper == 1 and endpoint == connection.from)
end)

test("collection windows reject invalid distances and relevant route lengths", function()
    local connection, locations = collection_fixture()
    local invalid = {
        0,
        -1,
        math.huge,
        -math.huge,
        0 / 0,
        "250",
        false,
    }
    for _, value in pairs(invalid) do
        local lower, reason = encounters.collection_window(connection, locations, value)
        assert(lower == nil and reason == "invalid-collection-distance")
        connection.length = value
        lower, reason = encounters.collection_window(connection, locations, 250)
        assert(lower == nil and reason == "invalid-collection-route-length")
        connection.length = 1000
    end
end)

local function prepared_collection_fixture(distance, ordinary)
    local connection, locations = collection_fixture()
    connection.length = 400000
    connection.asteroid_spawn_definitions = {
        {
            asteroid = "test-window-target",
            spawn_points = {
                {
                    distance = 0,
                    probability = 0,
                    speed = 0.01,
                },
                {
                    distance = 1,
                    probability = 10,
                    speed = 0.01,
                },
            },
        },
    }
    locations[connection.to].fly_condition = not ordinary
    local previous_config = config
    config = {damage_type_randomization = true}
    encounters.reset()
    local supplied = encounters.prepare({}, {
        definitions = {},
        connections = {connection},
        locations = locations,
        collection_distance_km = distance,
        counter_provider = function() return {} end,
        reference_ship = {
            population = "all-spawns-in-expanded-platform-area",
            speed_km_per_second = 60,
            width_tiles = 1,
            height_tiles = 1,
            spawning_rate = 1024 / 720,
            spawning_offset = {
                {
                    0,
                    0,
                },
                {
                    0,
                    0,
                },
            },
        },
    })
    config = previous_config
    encounters.reset()
    return supplied, connection
end

test("enabled encounter preparation applies its default collection trip to actual counts", function()
    local supplied, connection = prepared_collection_fixture()
    assert(supplied.score_counters == true and supplied.collection_distance_km == 100000)
    local counts, metadata = supplied.asteroid_counts(connection)
    assert(counts["test-window-target"] == 25)
    assert(metadata.duration_seconds == 10)
    assert(metadata.route_distance_min == 0 and metadata.route_distance_max == 0.25)
    assert(metadata.collection_endpoint == connection.to and metadata.collection_distance_km == 100000)
    assert(metadata.peak_distances["test-window-target"] == 0.25)
end)

test("explicit collection distances override the enabled preparation default", function()
    local supplied, connection = prepared_collection_fixture(50000)
    assert(supplied.collection_distance_km == 50000)
    local counts, metadata = supplied.asteroid_counts(connection)
    assert(counts["test-window-target"] == 13)
    assert(metadata.route_distance_min == 0 and metadata.route_distance_max == 0.125)
    assert(metadata.expected_counts["test-window-target"] == 12.5)
    assert(metadata.collection_endpoint == connection.to and metadata.collection_distance_km == 50000)
end)

test("enabled preparation keeps ordinary connections at their full-route workload", function()
    local supplied, connection = prepared_collection_fixture(nil, true)
    assert(supplied.collection_distance_km == 100000)
    local counts, metadata = supplied.asteroid_counts(connection)
    assert(counts["test-window-target"] == 100)
    assert(metadata.route_distance_min == 0 and metadata.route_distance_max == 1)
    assert(metadata.collection_endpoint == nil and metadata.collection_distance_km == nil)
end)

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
    assert(policy.baseline_seconds == 10 and policy.clear_seconds == 20)
    assert(policy.turret_count == 10 and policy.manual_count == 1)
    local relaxed = model.policy({ time_multiplier = 2 })
    assert(relaxed.baseline_seconds == 10 and relaxed.clear_seconds == 40)
    assert(relaxed.turret_count == 10 and relaxed.manual_count == 1)
end)

test("No Cap disables terrestrial requirements while preserving the asteroid time budget", function()
    local policy = model.policy({ difficulty = "no-cap" })
    assert(not policy.check_enemies)
    assert(policy.baseline_seconds == 10 and policy.clear_seconds == 20)
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

local function asteroid_fixture()
    local lu, options = collection_fixture()
    local connection = {
        name = "test-route",
        from = "test-origin",
        to = "test-destination",
        asteroid_spawn_definitions = {},
    }
    options.difficulty = "no-cap"
    options.connections = { [connection.name] = connection }
    options.locations = {
        [connection.from] = {
            asteroid_spawn_definitions = {
                {
                    asteroid = "test-target",
                    probability = 0.1,
                    speed = 0.02,
                },
            },
        },
        [connection.to] = {},
    }
    return lu, options, connection
end

-- Temporary route exceptions explicitly authorized by the user; ordinary route fixtures remain at 20 seconds.
local route_cutoffs = {
    ["gleba-aquilo"] = 60,
    ["fulgora-aquilo"] = 60,
    ["aquilo-solar-system-edge"] = 60,
    ["solar-system-edge-shattered-planet"] = 120,
    ["test-route"] = 20,
}

local function route_definition(source)
    local encounter = definition("asteroid-route")
    encounter.source = source
    encounter.room = nil
    encounter.anchor = key("space-surface", "")
    encounter.policy = nil
    return encounter
end

test("temporary route cutoffs scale normally without changing other encounter kinds", function()
    for source, seconds in pairs(route_cutoffs) do
        local encounter = route_definition(source)
        local policy = model.policy(nil, encounter)
        assert(policy.clear_seconds == seconds and policy.baseline_seconds == 10)
        policy = model.policy({time_multiplier = 2}, encounter)
        assert(policy.clear_seconds == 2 * seconds and policy.baseline_seconds == 10)
        encounter.kind = "spawn-group"
        assert(model.policy(nil, encounter).clear_seconds == 20)
        encounter.kind = "territory"
        assert(model.policy({time_multiplier = 2}, encounter).clear_seconds == 40)
    end
end)

test("collection attaches the appropriate route policy while preserving calibrated counts", function()
    for source, seconds in pairs(route_cutoffs) do
        local lu, options, connection = asteroid_fixture()
        lu.entities["test-spawner"] = nil
        connection.name = source
        options.connections = {[source] = connection}
        options.difficulty = "normal"
        options.asteroid_counts = function() return {["test-target"] = 7} end
        local definitions = model.collect(lu, options)
        assert(#definitions == 1)
        local encounter = definitions[1]
        assert(encounter.source == source and encounter.policy.clear_seconds == seconds)
        assert(encounter.policy.baseline_seconds == 10 and encounter.actual_size == 7)
        options.time_multiplier = 2
        definitions = model.collect(lu, options)
        assert(definitions[1].policy.clear_seconds == 2 * seconds)
        assert(equal(definitions[1].targets, encounter.targets))
    end
end)

test("route graph counters pass at their cutoff and fail immediately above it", function()
    for source, seconds in pairs(route_cutoffs) do
        local encounter = route_definition(source)
        local graph, sorted = with_counter(counter("turret", seconds), encounter)
        assert(reachable(sorted, encounter.name, SPACE, "01"))
        local node = graph.nodes[key("combat-encounter", encounter.name)]
        assert(node.encounter.policy.clear_seconds == seconds and node.evaluation.accepted == 1)
        graph, sorted = with_counter(counter("turret", seconds + 0.001), encounter)
        assert(not reachable(sorted, encounter.name, SPACE, "01"))
        node = graph.nodes[key("combat-encounter", encounter.name)]
        assert(node.evaluation.accepted == 0 and #node.evaluation.rejected == 1)
    end
end)

test("graph difficulty overrides rebuild route policies without changing reference rosters", function()
    for source, seconds in pairs(route_cutoffs) do
        local encounter = route_definition(source)
        encounter.policy = model.policy({time_multiplier = 0.5}, encounter)
        encounter.calibration = {
            duration_seconds = 10,
            route_distance_min = 0,
            route_distance_max = 0.25,
        }
        local original = table.deepcopy(encounter)
        local graph, sorted = with_counter(counter("turret", 2 * seconds), encounter, {time_multiplier = 2})
        assert(reachable(sorted, encounter.name, SPACE, "01"))
        local rebuilt = graph.nodes[key("combat-encounter", encounter.name)].encounter
        assert(rebuilt.policy.clear_seconds == 2 * seconds and rebuilt.policy.baseline_seconds == 10)
        assert(equal(rebuilt.targets, original.targets) and equal(rebuilt.calibration, original.calibration))
        assert(rebuilt.actual_size == original.actual_size and equal(encounter, original))
    end
end)

test("No Cap retains finite route exceptions regardless of multiplier and keeps their rosters", function()
    for source, seconds in pairs(route_cutoffs) do
        local encounter = route_definition(source)
        encounter.policy = model.policy({time_multiplier = 2}, encounter)
        local original = table.deepcopy(encounter)
        local options = {
            difficulty = "no-cap",
            time_multiplier = 10,
        }
        local graph, sorted = with_counter(counter("turret", seconds), encounter, options)
        assert(reachable(sorted, encounter.name, SPACE, "01"))
        local rebuilt = graph.nodes[key("combat-encounter", encounter.name)].encounter
        assert(rebuilt.policy.clear_seconds == seconds and rebuilt.policy.baseline_seconds == 10)
        assert(rebuilt.policy.check_enemies == false and equal(rebuilt.targets, original.targets))
        assert(equal(encounter, original))
        graph, sorted = with_counter(counter("turret", seconds + 0.001), encounter, options)
        assert(not reachable(sorted, encounter.name, SPACE, "01"))
    end
end)

test("an existing definition policy remains authoritative without a difficulty override", function()
    local encounter = route_definition("aquilo-solar-system-edge")
    encounter.policy = model.policy({time_multiplier = 0.5}, encounter)
    local graph, sorted = with_counter(counter("turret", 30), encounter)
    assert(reachable(sorted, encounter.name, SPACE, "01"))
    assert(graph.nodes[key("combat-encounter", encounter.name)].encounter.policy.clear_seconds == 30)
    graph, sorted = with_counter(counter("turret", 30.001), encounter)
    assert(not reachable(sorted, encounter.name, SPACE, "01"))
end)

test("endpoint-only positive targets remain unscored when no calibration exists", function()
    local lu, options, connection = asteroid_fixture()
    local definitions = model.collect(lu, options)
    assert(#definitions == 1 and #definitions[1].targets == 1)
    local target = definitions[1].targets[1]
    assert(target.entity == "test-target" and target.amount == nil)
    assert(target.endpoint_spawns[1].location == connection.from)
    assert(target.endpoint_spawns[1].influence == 0.1)
    assert(definitions[1].calibration_reason == "missing-asteroid-calibration")
    assert(not definitions[1].workload_calibrated)
    options.locations[connection.from].asteroid_spawn_influence = 0
    assert(#model.collect(lu, options) == 0)
end)

test("calibration can introduce additional targets and retains independent metadata", function()
    local lu, options = asteroid_fixture()
    lu.entities["test-extra"] = {
        name = "test-extra",
        max_health = 200,
    }
    local metadata = {
        approximation = true,
        speed_km_per_second = 100,
        expected_counts = { ["test-extra"] = 2.5 },
    }
    options.asteroid_counts = function()
        return {
            ["test-target"] = 2,
            ["test-extra"] = 3,
        }, metadata
    end
    local encounter = model.collect(lu, options)[1]
    assert(encounter.workload_calibrated and encounter.targets_complete)
    assert(encounter.actual_size == 5 and #encounter.targets == 2)
    assert(encounter.targets[1].entity == "test-extra" and encounter.targets[1].amount == 3)
    assert(encounter.calibration.approximation)
    assert(encounter.calibration.speed_km_per_second == 100)
    metadata.expected_counts["test-extra"] = 20
    assert(encounter.calibration.expected_counts["test-extra"] == 2.5)
    lu.entities["test-extra"] = nil
    encounter = model.collect(lu, options)[1]
    assert(not encounter.targets_complete and #encounter.targets == 2)
end)

test("an explicit zero removes a target but absent counts never do", function()
    local lu, options = asteroid_fixture()
    lu.entities["test-extra"] = {
        name = "test-extra",
        max_health = 200,
    }
    options.asteroid_counts = function()
        return {
            ["test-target"] = 0,
            ["test-extra"] = 2,
        }
    end
    local encounter = model.collect(lu, options)[1]
    assert(encounter.workload_calibrated and encounter.actual_size == 2)
    assert(#encounter.targets == 1 and encounter.targets[1].entity == "test-extra")
    options.asteroid_counts = function() return { ["test-extra"] = 2 } end
    encounter = model.collect(lu, options)[1]
    assert(not encounter.workload_calibrated and encounter.actual_size == nil)
    assert(#encounter.targets == 2 and encounter.targets[2].amount == nil)
    assert(encounter.calibration_reason == "missing-target-count")
    options.asteroid_counts = function() return { ["test-target"] = 0 } end
    assert(#model.collect(lu, options) == 0)
end)

test("failed and invalid calibration cannot certify a smaller asteroid workload", function()
    local lu, options = asteroid_fixture()
    options.asteroid_counts = function() return nil, "missing-reference-speed" end
    local encounter = model.collect(lu, options)[1]
    assert(encounter.calibration_reason == "missing-reference-speed")
    assert(not encounter.workload_calibrated and #encounter.targets == 1)
    for _, invalid in pairs({
        -1,
        math.huge,
        0 / 0,
        "unknown",
    }) do
        options.asteroid_counts = function() return { ["test-target"] = invalid } end
        encounter = model.collect(lu, options)[1]
        assert(not encounter.workload_calibrated and encounter.actual_size == nil)
        assert(encounter.targets[1].amount == nil)
        assert(encounter.calibration_reason == "invalid-asteroid-counts")
    end
    options.asteroid_counts = function() return false end
    encounter = model.collect(lu, options)[1]
    assert(not encounter.workload_calibrated and encounter.calibration_reason == "invalid-asteroid-counts")
end)

test("direct and endpoint membership merge into one calibrated target", function()
    local lu, options, connection = asteroid_fixture()
    connection.asteroid_spawn_definitions = {
        {
            asteroid = "test-target",
            spawn_points = {
                {
                    distance = 0.5,
                    probability = 0.2,
                    speed = 0.02,
                },
            },
        },
    }
    options.asteroid_counts = function() return { ["test-target"] = 4 } end
    local encounter = model.collect(lu, options)[1]
    assert(#encounter.targets == 1 and encounter.actual_size == 4)
    assert(#encounter.targets[1].spawn_curves == 1)
    assert(#encounter.targets[1].endpoint_spawns == 1)
end)

test("an anchor alone cannot satisfy an unscored encounter", function()
    local graph, sorted = build({ definition() })
    local node = graph.nodes[key("combat-encounter", "test-encounter")]
    assert(node.mechanic)
    assert(node.important)
    assert(node.evaluation.status == "unscored")
    assert(not reachable(sorted, "test-encounter"))
    assert(not reachable(sorted, "test-encounter", HOME, "01"))
end)

test("a counter at the time limit preserves automatic and manual contexts on its own room", function()
    local _, sorted = with_counter(counter("turret", 20))
    assert(reachable(sorted, "test-encounter"))
    assert(reachable(sorted, "test-encounter", HOME, "01"))
    assert(not reachable(sorted, "test-encounter", AWAY))
end)

test("manual counters never manufacture an automatic context from automated inputs", function()
    local _, sorted = with_counter(counter("manual", 20))
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
        counter("turret", 20.001),
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

-- A small split graph, using the same matching entry point that first pass calls.
local function matching_fixture(protect_encounter)
    local graph = with_counter(counter())
    data = { raw = {} }
    data.raw.recipe = {}
    local encounter = graph.nodes[key("combat-encounter", "test-encounter")]
    encounter.mechanic = protect_encounter
    encounter.important = protect_encounter
    local function source(name, prerequisite)
        local node = gutils.add_node(graph, "test-source", name, { op = "AND" })
        if prerequisite ~= nil then
            gutils.add_edge(graph, prerequisite, key(node))
        end
        return node
    end
    local early = source("test-early-slot", key("test-start", "test-start"))
    local previous = key("test-start", "test-start")
    for i = 1, 30 do
        previous = key(source("test-later-step-" .. i, previous))
    end
    local late = source("test-late-slot", previous)
    local filler = source("test-filler-trav")
    local firepower = graph.nodes[FIREPOWER]
    firepower.trav = true
    firepower.old_slot = key(early)
    early.old_trav = FIREPOWER
    filler.trav = true
    filler.old_slot = key(late)
    late.old_trav = key(filler)
    setup.build(logic)
    return {
        unconnected_graph = graph,
        slot_keys = {
            key(early),
            key(late),
        },
        slot_to_base = {
            [key(early)] = early,
            [key(late)] = late,
        },
        trav_to_head = {
            [FIREPOWER] = firepower,
            [key(filler)] = filler,
        },
        pair_ok = function() return true end,
        rounds = 1,
    }
end

test("first pass's matching keeps an important encounter counter before a later available position", function()
    local protected_cases = 0
    for seed = 1, 10 do
        local params = matching_fixture(true)
        local initial_sort
        local real_sort = top.sort
        top.sort = function(graph, state, connection, options)
            local sorted = real_sort(graph, state, connection, options)
            if options ~= nil and options.complex_contexts == true then
                initial_sort = initial_sort or sorted
            end
            return sorted
        end
        rng_state = seed
        local ok, assignment = pcall(matching.run, params)
        top.sort = real_sort
        assert(ok, assignment)
        assert(assignment ~= false)
        local context = top.context_key(HOME, "01")
        local early_rank = initial_sort.node_to_context_inds[FIREPOWER][context]
        local later_rank = initial_sort.node_to_context_inds[params.slot_keys[2]][context]
        if early_rank < later_rank then
            protected_cases = protected_cases + 1
            assert(assignment[params.slot_keys[1]] == FIREPOWER)
            assert(assignment[params.slot_keys[2]] ~= FIREPOWER)
        end
    end
    assert(protected_cases > 0, "the fixture must exercise a counter with an earlier original rank")

    -- Without the encounter obligation both positions remain reachable, so the same matcher may exchange their identities.
    local moved = false
    for seed = 1, 10 do
        local params = matching_fixture(false)
        rng_state = seed
        local assignment = matching.run(params)
        assert(assignment ~= false)
        moved = moved or assignment[params.slot_keys[2]] == FIREPOWER
    end
    assert(moved, "without the encounter obligation a later position must remain available")
end)

print(passed .. " tests passed")
