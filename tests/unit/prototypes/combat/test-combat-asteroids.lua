-- Pure mathematical tests for the explicitly approximate route workload adapter.
-- Run from the mod root: lua tests/unit/prototypes/combat/test-combat-asteroids.lua

local asteroids = require("src/prototypes/combat/combat-asteroids")

local passed = 0
local function test(name, run)
    run()
    passed = passed + 1
    print("ok - " .. name)
end

local function close(actual, expected)
    assert(math.abs(actual - expected) < 1e-9, tostring(actual) .. " ~= " .. tostring(expected))
end

local function point(distance, probability)
    return {
        distance = distance,
        probability = probability,
        speed = 0.01,
    }
end

local function coordinate(x, y)
    return {
        x,
        y,
    }
end

local function offset(left, top, right, bottom)
    return {
        coordinate(left, top),
        coordinate(right, bottom),
    }
end

local function curve(name, ...)
    return {
        name,
        {...},
    }
end

local function orbital(name, probability)
    return {
        asteroid = name,
        probability = probability,
        speed = 0.01,
    }
end

local function fixture()
    local connection = {
        from = "test-origin",
        to = "test-destination",
        asteroid_spawn_definitions = {
            {
                asteroid = "test-target",
                spawn_points = {
                    point(0, 0),
                    point(0.5, 2),
                    point(1, 0),
                },
            },
        },
    }
    -- This calibration gives one expected asteroid/second per probability unit.
    local options = {
        population = "all-spawns-in-expanded-platform-area",
        speed_km_per_second = 60,
        width_tiles = 1,
        height_tiles = 1,
        duration_seconds = 1,
        spawning_rate = 1024 / 720,
        spawning_offset = offset(0, 0, 0, 0),
        locations = {
            [connection.from] = {},
            [connection.to] = {},
        },
    }
    return connection, options
end

test("route peaks use the chosen speed and expanded footprint", function()
    local connection, options = fixture()
    options.speed_km_per_second = 100
    options.width_tiles = 20
    options.height_tiles = 40
    options.duration_seconds = 10
    options.spawning_rate = 1
    options.spawning_offset = offset(-48, -72, 48, 48)
    connection.asteroid_spawn_definitions[1].spawn_points[2].probability = 0.01
    local counts, metadata = asteroids.counts(connection, options)
    assert(counts["test-target"] == 13)
    close(metadata.expected_counts["test-target"], 12.9453125)
    assert(metadata.expanded_width_tiles == 116 and metadata.expanded_height_tiles == 160)
    assert(metadata.approximation and metadata.engine_version_verified == false)
    assert(metadata.spawn_updates_per_tick_assumed == 1)
    assert(metadata.population == "all-spawns-in-expanded-platform-area")
    assert(metadata.route_distance_min == 0 and metadata.route_distance_max == 1)
    options.speed_km_per_second = 200
    counts, metadata = asteroids.counts(connection, options)
    assert(counts["test-target"] == 25)
    close(metadata.expected_counts["test-target"], 24.2734375)
end)

test("duplicate curves sum at the same position before finding their combined peak", function()
    local connection, options = fixture()
    connection.asteroid_spawn_definitions = {
        curve("test-target", point(0, 1), point(1, 0)),
        curve("test-target", point(0, 0), point(1, 1)),
    }
    local counts, metadata = asteroids.counts(connection, options)
    assert(counts["test-target"] == 1)
    close(metadata.expected_counts["test-target"], 1)
end)

test("different target peaks may occur at different positions", function()
    local connection, options = fixture()
    connection.asteroid_spawn_definitions = {
        curve("test-early", point(0, 2), point(1, 0)),
        curve("test-late", point(0, 0), point(1, 3)),
    }
    local counts, metadata = asteroids.counts(connection, options)
    assert(counts["test-early"] == 2 and counts["test-late"] == 3)
    assert(metadata.peak_distances["test-early"] == 0 and metadata.peak_distances["test-late"] == 1)
end)

test("endpoint-only targets and faded endpoint contributions are included", function()
    local connection, options = fixture()
    options.locations[connection.from] = {
        asteroid_spawn_influence = 1,
        asteroid_spawn_definitions = {
            orbital("test-target", 2),
            orbital("test-endpoint-only", 4),
        },
    }
    local counts, metadata = asteroids.counts(connection, options)
    assert(counts["test-target"] == 3 and counts["test-endpoint-only"] == 4)
    close(metadata.peak_distances["test-target"], 0.5)
end)

test("overlapping endpoint influences sum before rounding", function()
    local connection, options = fixture()
    connection.asteroid_spawn_definitions = {}
    options.locations[connection.from] = {
        asteroid_spawn_influence = 2,
        asteroid_spawn_definitions = {orbital("test-overlap", 2)},
    }
    options.locations[connection.to] = {
        asteroid_spawn_influence = 2,
        asteroid_spawn_definitions = {orbital("test-overlap", 2)},
    }
    local counts, metadata = asteroids.counts(connection, options)
    assert(counts["test-overlap"] == 3)
    close(metadata.expected_counts["test-overlap"], 3)
end)

test("chunk spawn definitions never add combat workload", function()
    local connection, options = fixture()
    local chunk = curve("test-chunk", point(0, 100), point(1, 100))
    chunk.type = "asteroid-chunk"
    table.insert(connection.asteroid_spawn_definitions, chunk)
    local endpoint_chunk = orbital("test-endpoint-chunk", 100)
    endpoint_chunk.type = "asteroid-chunk"
    options.locations[connection.from].asteroid_spawn_definitions = {endpoint_chunk}
    local counts = asteroids.counts(connection, options)
    assert(counts["test-target"] == 2)
    assert(counts["test-chunk"] == nil and counts["test-endpoint-chunk"] == nil)
end)

test("destination influences reverse distance and use the documented default", function()
    local connection, options = fixture()
    connection.asteroid_spawn_definitions = {}
    options.locations[connection.to].asteroid_spawn_definitions = {
        orbital("test-endpoint-only", 1.2),
    }
    local counts, metadata = asteroids.counts(connection, options)
    assert(counts["test-endpoint-only"] == 2)
    assert(metadata.peak_distances["test-endpoint-only"] == 1)
    options.locations[connection.to].asteroid_spawn_influence = 0
    counts = asteroids.counts(connection, options)
    assert(next(counts) == nil)
end)

test("a single route point is treated as a constant conservative envelope", function()
    local connection, options = fixture()
    connection.asteroid_spawn_definitions[1].spawn_points = {point(0.5, 2)}
    local counts, metadata = asteroids.counts(connection, options)
    assert(counts["test-target"] == 2)
    assert(metadata.route_exterior == "nearest-value-envelope")
end)

test("tiny positive rates survive rounding and exact counts do not gain a target", function()
    local connection, options = fixture()
    connection.asteroid_spawn_definitions[1].spawn_points[2].probability = 1e-12
    assert(asteroids.counts(connection, options)["test-target"] == 1)
    connection.asteroid_spawn_definitions[1].spawn_points[2].probability = 12.000000000000002
    assert(asteroids.counts(connection, options)["test-target"] == 12)
    connection.asteroid_spawn_definitions[1].spawn_points[2].probability = 12.0000000001
    assert(asteroids.counts(connection, options)["test-target"] == 13)
end)

test("zero configured rates return explicit zero counts", function()
    local connection, options = fixture()
    options.spawning_rate = 0
    local counts, metadata = asteroids.counts(connection, options)
    assert(counts["test-target"] == 0 and metadata.expected_counts["test-target"] == 0)
end)

test("engine settings may come from actual prototype objects", function()
    local connection, options = fixture()
    options.utility_constants = {asteroid_spawning_offset = options.spawning_offset}
    options.map_settings = {asteroids = {spawning_rate = options.spawning_rate}}
    options.spawning_offset = nil
    options.spawning_rate = nil
    assert(asteroids.counts(connection, options)["test-target"] == 2)
end)

test("reference speed and dimensions are never silently supplied", function()
    local connection, options = fixture()
    options.speed_km_per_second = nil
    local counts, reason = asteroids.counts(connection, options)
    assert(counts == nil and reason == "missing-reference-speed")
    options.speed_km_per_second = 1
    counts, reason = asteroids.counts(connection, options)
    assert(counts == nil and reason == "unsupported-low-reference-speed")
    options.speed_km_per_second = 60
    options.width_tiles = nil
    counts, reason = asteroids.counts(connection, options)
    assert(counts == nil and reason == "missing-reference-footprint")
end)

test("unavailable endpoint information cannot silently remove its traffic", function()
    local connection, options = fixture()
    options.locations[connection.to] = nil
    local counts, reason = asteroids.counts(connection, options)
    assert(counts == nil and reason == "missing-endpoint-location")
end)

test("invalid probability curves are rejected", function()
    local connection, options = fixture()
    connection.asteroid_spawn_definitions[1].spawn_points[2].probability = -1
    local counts, reason = asteroids.counts(connection, options)
    assert(counts == nil and reason == "invalid-route-spawn-curve")
    connection.asteroid_spawn_definitions[1].spawn_points[2].probability = 2
    connection.asteroid_spawn_definitions[1].spawn_points[2].distance = 0
    counts, reason = asteroids.counts(connection, options)
    assert(counts == nil and reason == "invalid-route-spawn-curve")
end)

test("invalid endpoint data cannot remove or overflow its workload", function()
    local connection, options = fixture()
    local definition = orbital("test-endpoint-only", math.huge)
    options.locations[connection.to].asteroid_spawn_definitions = {definition}
    local counts, reason = asteroids.counts(connection, options)
    assert(counts == nil and reason == "invalid-endpoint-spawn-definition")
    definition.probability = 1
    options.locations[connection.to].asteroid_spawn_influence = -1
    counts, reason = asteroids.counts(connection, options)
    assert(counts == nil and reason == "invalid-endpoint-influence")
    options.locations[connection.to].asteroid_spawn_influence = 0.1
    definition.probability = 1e308
    options.duration_seconds = 1e308
    counts, reason = asteroids.counts(connection, options)
    assert(counts == nil and reason == "invalid-expected-count")
end)

test("the adapter closure preserves the counts and metadata interface", function()
    local connection, options = fixture()
    local adapter = asteroids.new(options)
    local counts, metadata = adapter(connection)
    assert(counts["test-target"] == 2 and metadata.approximation)
end)

test("route windows interpolate their boundaries and exclude distant peaks", function()
    local connection, options = fixture()
    options.distance_max = 0.25
    local counts, metadata = asteroids.counts(connection, options)
    assert(counts["test-target"] == 1)
    close(metadata.expected_counts["test-target"], 1)
    close(metadata.peak_distances["test-target"], 0.25)
    assert(metadata.route_distance_min == 0 and metadata.route_distance_max == 0.25)
    options.distance_min, options.distance_max = 0.75, 0.9
    counts, metadata = asteroids.counts(connection, options)
    assert(counts["test-target"] == 1)
    close(metadata.expected_counts["test-target"], 1)
    close(metadata.peak_distances["test-target"], 0.75)
end)

test("route windows retain interior knots and permit a single sampled position", function()
    local connection, options = fixture()
    options.distance_min, options.distance_max = 0.2, 0.8
    local counts, metadata = asteroids.counts(connection, options)
    assert(counts["test-target"] == 2 and metadata.peak_distances["test-target"] == 0.5)
    options.distance_min, options.distance_max = 0.25, 0.25
    counts, metadata = asteroids.counts(connection, options)
    assert(counts["test-target"] == 1 and metadata.peak_distances["test-target"] == 0.25)
    options.distance_max = nil
    counts, metadata = asteroids.counts(connection, options)
    assert(counts["test-target"] == 2)
    assert(metadata.route_distance_min == 0.25 and metadata.route_distance_max == 1)
end)

test("endpoint weighting keeps full-route coordinates within either end's window", function()
    local connection, options = fixture()
    connection.asteroid_spawn_definitions = {}
    options.locations[connection.from] = {
        asteroid_spawn_influence = 0.2,
        asteroid_spawn_definitions = {orbital("test-origin-only", 4)},
    }
    options.locations[connection.to] = {
        asteroid_spawn_influence = 0.2,
        asteroid_spawn_definitions = {orbital("test-destination-only", 8)},
    }
    options.distance_min, options.distance_max = 0.1, 0.15
    local counts, metadata = asteroids.counts(connection, options)
    assert(counts["test-origin-only"] == 2 and counts["test-destination-only"] == 0)
    close(metadata.expected_counts["test-origin-only"], 2)
    assert(metadata.expected_counts["test-destination-only"] == 0)
    options.distance_min, options.distance_max = 0.85, 0.9
    counts, metadata = asteroids.counts(connection, options)
    assert(counts["test-origin-only"] == 0 and counts["test-destination-only"] == 4)
    close(metadata.expected_counts["test-destination-only"], 4)
    close(metadata.peak_distances["test-destination-only"], 0.9)
end)

test("route types absent within the selected window retain explicit zeros", function()
    local connection, options = fixture()
    connection.asteroid_spawn_definitions = {
        curve("test-early", point(0, 2), point(0.4, 0), point(1, 0)),
        curve("test-late", point(0, 0), point(0.6, 0), point(1, 2)),
    }
    options.distance_min, options.distance_max = 0.45, 0.55
    local counts, metadata = asteroids.counts(connection, options)
    assert(counts["test-early"] == 0 and counts["test-late"] == 0)
    assert(metadata.expected_counts["test-early"] == 0 and metadata.expected_counts["test-late"] == 0)
end)

test("restricting a window does not change the nearest-point exterior envelope", function()
    local connection, options = fixture()
    connection.asteroid_spawn_definitions = {
        curve("test-target", point(0.3, 2), point(0.7, 4)),
    }
    options.distance_min, options.distance_max = 0, 0.1
    local counts = asteroids.counts(connection, options)
    assert(counts["test-target"] == 2)
    options.distance_min, options.distance_max = 0.9, 1
    counts = asteroids.counts(connection, options)
    assert(counts["test-target"] == 4)
end)

test("reversed nonfinite and out-of-route windows fail closed", function()
    local connection, options = fixture()
    local invalid = {
        coordinate(0.8, 0.2),
        coordinate(-0.1, 1),
        coordinate(0, 1.1),
        coordinate(2, 2),
        coordinate(0 / 0, 1),
        coordinate(0, math.huge),
        coordinate(false, 1),
        coordinate(0, "1"),
    }
    for _, window in pairs(invalid) do
        options.distance_min, options.distance_max = window[1], window[2]
        local counts, reason = asteroids.counts(connection, options)
        assert(counts == nil and reason == "invalid-route-window")
    end
end)

local function projected_fixture()
    local connection, options = fixture()
    options.population = nil
    options.speed_km_per_second = 100
    options.width_tiles = 20
    options.height_tiles = 40
    options.duration_seconds = 10
    options.spawning_rate = 1
    options.spawning_offset = offset(-48, -72, 48, 48)
    options.entities = {
        ["test-target"] = {collision_box = offset(-1, -1, 1, 1)},
    }
    connection.asteroid_spawn_definitions[1].spawn_points[2].probability = 0.01
    return connection, options
end

test("the approved reference uses a documented heading allowance and prototype geometry", function()
    local connection, options = projected_fixture()
    local counts, metadata = asteroids.counts(connection, options)
    local radius = math.sqrt(2)
    local width = 20 + 2 * radius + 2 * (40 + 72 + radius) / 8
    close(metadata.collision_radii_tiles["test-target"], radius)
    close(metadata.corridor_widths_tiles["test-target"], width)
    close(metadata.threat_fractions["test-target"], width / 116)
    close(metadata.all_spawn_expected_counts["test-target"], 12.9453125)
    close(metadata.expected_counts["test-target"], 12.9453125 * width / 116)
    assert(counts["test-target"] == 6)
    assert(metadata.population == "projected-hull-threats")
    assert(metadata.projection.slope_source == "reference-probe-allowance")
    assert(metadata.projection.max_lateral_slope == 1 / 8)
    assert(metadata.projection.engine_placement_verified == false and metadata.projection.engine_heading_bound_verified == false)
end)

test("asteroid size and both hull dimensions change the projected workload", function()
    local connection, options = projected_fixture()
    local _, first = asteroids.counts(connection, options)
    options.entities["test-target"].collision_box = offset(-4.5, -4.5, 4.5, 4.5)
    local _, larger = asteroids.counts(connection, options)
    assert(larger.threat_fractions["test-target"] > first.threat_fractions["test-target"])
    options.height_tiles = 80
    local _, longer = asteroids.counts(connection, options)
    assert(longer.corridor_widths_tiles["test-target"] > larger.corridor_widths_tiles["test-target"])
    options.width_tiles = 40
    local _, wider = asteroids.counts(connection, options)
    assert(wider.corridor_widths_tiles["test-target"] > longer.corridor_widths_tiles["test-target"])
end)

test("explicit heading envelopes apply at other reference speeds while absent ones fall back safely", function()
    local connection, options = projected_fixture()
    options.speed_km_per_second = 200
    local counts, metadata = asteroids.counts(connection, options)
    assert(counts["test-target"] == 25)
    assert(metadata.population == "all-spawns-in-expanded-platform-area")
    assert(metadata.projection_fallback_reason == "uncalibrated-reference-heading")
    assert(metadata.threat_fractions["test-target"] == 1)
    options.max_lateral_slope = 0
    counts, metadata = asteroids.counts(connection, options)
    close(metadata.threat_fractions["test-target"], (20 + 2 * math.sqrt(2)) / 116)
    assert(metadata.projection.slope_source == "explicit-benchmark-parameter")
    assert(counts["test-target"] == 5)
end)

test("a sufficiently wide corridor counts every spawn without exceeding the original workload", function()
    local connection, options = projected_fixture()
    options.max_lateral_slope = 10
    local counts, metadata = asteroids.counts(connection, options)
    assert(metadata.threat_fractions["test-target"] == 1)
    assert(metadata.corridor_widths_tiles["test-target"] == 116)
    assert(counts["test-target"] == 13)
end)

test("asymmetric spawn offsets clip the actual corridor intersection", function()
    local connection, options = projected_fixture()
    options.max_lateral_slope = 0
    options.spawning_offset = offset(0, -72, 96, 48)
    local _, metadata = asteroids.counts(connection, options)
    close(metadata.corridor_widths_tiles["test-target"], 20 + math.sqrt(2))
    close(metadata.threat_fractions["test-target"], (20 + math.sqrt(2)) / 116)
end)

test("the geometry lookup supports callbacks and encloses off-center rotated boxes", function()
    local connection, options = projected_fixture()
    options.entities = nil
    options.entity_of = function(name)
        assert(name == "test-target")
        return {
            collision_box = {
                left_top = {
                    x = -1,
                    y = -2,
                },
                right_bottom = {
                    x = 3,
                    y = 4,
                },
                orientation = 0.125,
            },
        }
    end
    local _, metadata = asteroids.counts(connection, options)
    close(metadata.collision_radii_tiles["test-target"], 5)
end)

test("empty collision geometry means zero hull threats but missing geometry fails closed", function()
    local connection, options = projected_fixture()
    options.entities["test-target"].collision_box = nil
    local counts, metadata = asteroids.counts(connection, options)
    assert(counts["test-target"] == 0 and metadata.threat_fractions["test-target"] == 0)
    options.entities["test-target"].collision_box = offset(0, 0, 0, 0)
    assert(asteroids.counts(connection, options)["test-target"] == 0)
    options.entities["test-target"] = nil
    local reason
    counts, reason = asteroids.counts(connection, options)
    assert(counts == nil and reason == "missing-asteroid-collision-geometry")
end)

test("invalid geometry and projection parameters cannot produce a smaller workload", function()
    local connection, options = projected_fixture()
    options.entities["test-target"].collision_box = offset(1, -1, 2, 1)
    local counts, reason = asteroids.counts(connection, options)
    assert(counts == nil and reason == "invalid-asteroid-collision-geometry")
    options.entities["test-target"].collision_box = offset(-1e308, -1, 1e308, 1)
    counts, reason = asteroids.counts(connection, options)
    assert(counts == nil and reason == "invalid-asteroid-collision-geometry")
    options.max_lateral_slope = -1
    counts, reason = asteroids.counts(connection, options)
    assert(counts == nil and reason == "invalid-reference-heading-envelope")
    options.max_lateral_slope = nil
    options.spawning_offset = offset(1, -1, 3, 1)
    counts, reason = asteroids.counts(connection, options)
    assert(counts == nil and reason == "unsupported-inward-spawning-offset")
    options.population = "test-unknown-population"
    counts, reason = asteroids.counts(connection, options)
    assert(counts == nil and reason == "invalid-workload-population")
end)

test("the projection envelope contains sampled fixed trajectories from the full spawn edge", function()
    local connection, options = projected_fixture()
    local _, metadata = asteroids.counts(connection, options)
    local projection = metadata.projection
    local radius = metadata.collision_radii_tiles["test-target"]
    local half = metadata.corridor_widths_tiles["test-target"] / 2
    -- Check trajectories throughout the allowed heading cone and the enlarged hull depth.
    for step = 0, 40 do
        local slope = projection.max_lateral_slope * (step / 20 - 1)
        for depth = 0, 20 do
            local y = -options.height_tiles / 2 - radius + depth / 20 * (options.height_tiles + 2 * radius)
            local travel = y - projection.spawn_front_tiles
            for side = -1, 1, 2 do
                local origin = side * (options.width_tiles / 2 + radius) - slope * travel
                assert(math.abs(origin) <= half + 1e-12)
            end
        end
    end
end)

print(passed .. " tests passed")
