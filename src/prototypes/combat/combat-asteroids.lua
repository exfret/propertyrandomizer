-- Expected asteroid workloads for an explicitly chosen reference platform.
-- Approximation, not a verified 2.1 engine formula or a bound on random bursts.
-- Wube's Rseding91 published the spawning routine on 2025-03-19 and confirmed km/tick for platform speed on 2025-08-04.
-- https://gist.github.com/Rseding91/aecc426adc32039844f6d43bf3f3c63f
-- The published code does not include its route-curve interpolator.
-- We interpolate between points and hold the nearest value outside them as a conservative envelope, not a claim about the engine's behavior outside the supplied points.
-- Its call site is also absent: the conversion to seconds assumes one spawn update per tick.
-- Projected hull threats use a separately declared geometric benchmark, not a claim about spawnAsteroid's unpublished placement/velocity law.
-- The all-spawn calculation remains available explicitly and is the fallback for an uncalibrated reference speed.

local asteroids = {}

local function finite(value)
    return type(value) == "number" and value > -math.huge and value < math.huge
end

local function positive(value)
    return finite(value) and value > 0
end

local function nonnegative(value)
    return finite(value) and value >= 0
end

local function singleton(raw, class)
    local prototype
    for _, candidate in pairs(raw and raw[class] or {}) do
        if prototype ~= nil then
            return nil
        end
        prototype = candidate
    end
    return prototype
end

local function coordinate(vector, name, index)
    return type(vector) == "table" and (vector[name] or vector[index]) or nil
end

local function bounds(box)
    if type(box) ~= "table" then
        return
    end
    local top_left = box.left_top or box[1]
    local bottom_right = box.right_bottom or box[2]
    return coordinate(top_left, "x", 1), coordinate(top_left, "y", 2), coordinate(bottom_right, "x", 1), coordinate(bottom_right, "y", 2)
end

local function calibration(options)
    local distance_min, distance_max = options.distance_min, options.distance_max
    if distance_min == nil then
        distance_min = 0
    end
    if distance_max == nil then
        distance_max = 1
    end
    if not nonnegative(distance_min) or not nonnegative(distance_max) or distance_min > distance_max or distance_max > 1 then
        return nil, "invalid-route-window"
    end
    if not positive(options.speed_km_per_second) then
        return nil, "missing-reference-speed"
    end
    -- The historical routine changes its rate calculation below 0.2 km/tick.
    -- Its moving/stopped distinctions are outside this travelling benchmark.
    if options.speed_km_per_second < 12 then
        return nil, "unsupported-low-reference-speed"
    end
    if not positive(options.width_tiles) or not positive(options.height_tiles) then
        return nil, "missing-reference-footprint"
    end
    if not positive(options.duration_seconds) then
        return nil, "missing-workload-duration"
    end
    local raw = options.raw or (data and data.raw)
    local utility = options.utility_constants or singleton(raw, "utility-constants")
    local settings = options.map_settings or singleton(raw, "map-settings")
    local offset = options.spawning_offset or (utility and utility.asteroid_spawning_offset)
    local rate = options.spawning_rate
    if rate == nil and settings ~= nil and settings.asteroids ~= nil then
        rate = settings.asteroids.spawning_rate
    end
    if not nonnegative(rate) then
        return nil, "missing-spawning-rate"
    end
    if type(offset) ~= "table" then
        return nil, "missing-spawning-offset"
    end
    local left, top, right, bottom = bounds(offset)
    if not finite(left) or not finite(top) or not finite(right) or not finite(bottom) then
        return nil, "invalid-spawning-offset"
    end
    local width = options.width_tiles + right - left
    local height = options.height_tiles + bottom - top
    if not positive(width) or not positive(height) then
        return nil, "invalid-spawning-area"
    end
    local factor = (width + height + width * options.speed_km_per_second / 6) * rate / 1024 * 60
    if not nonnegative(factor) or not nonnegative(factor * options.duration_seconds) then
        return nil, "invalid-rate-scale"
    end
    local calibrated = {
        approximation = true,
        source = "https://gist.github.com/Rseding91/aecc426adc32039844f6d43bf3f3c63f",
        source_date = "2025-03-19",
        engine_version_verified = false,
        spawn_updates_per_tick_assumed = 1,
        population = "all-spawns-in-expanded-platform-area",
        route_exterior = "nearest-value-envelope",
        route_distance_min = distance_min,
        route_distance_max = distance_max,
        workload = "ceiling-of-independent-expected-peaks",
        speed_km_per_second = options.speed_km_per_second,
        width_tiles = options.width_tiles,
        height_tiles = options.height_tiles,
        expanded_width_tiles = width,
        expanded_height_tiles = height,
        duration_seconds = options.duration_seconds,
        spawning_rate = rate,
        per_second_factor = factor,
    }
    local population = options.population or "projected-hull-threats"
    if population == "all-spawns-in-expanded-platform-area" then
        return calibrated
    end
    if population ~= "projected-hull-threats" then
        return nil, "invalid-workload-population"
    end
    local slope = options.max_lateral_slope
    local slope_source = "explicit-benchmark-parameter"
    if slope == nil then
        if options.speed_km_per_second ~= 100 then
            calibrated.projection_fallback_reason = "uncalibrated-reference-heading"
            return calibrated
        end
        -- Approved reference benchmark: twice the largest sampled |dx/dy| (1/16) in the 2.1.20 impact probe.
        -- This is an allowance for the model, not an engine bound or an inferred velocity formula.
        slope = 1 / 8
        slope_source = "reference-probe-allowance"
    end
    if not nonnegative(slope) then
        return nil, "invalid-reference-heading-envelope"
    end
    if left > 0 or top > 0 or right < 0 or bottom < 0 then
        return nil, "unsupported-inward-spawning-offset"
    end
    calibrated.population = population
    calibrated.projection = {
        placement = "uniform-expanded-front-edge",
        trajectory = "fixed-heading-envelope",
        max_lateral_slope = slope,
        slope_source = slope_source,
        radius = "collision-box-furthest-corner",
        probe_engine_version = "2.1.20",
        engine_placement_verified = false,
        engine_heading_bound_verified = false,
        -- Hull center is the origin; positive y points toward its rear in this benchmark.
        spawn_left_tiles = -options.width_tiles / 2 + left,
        spawn_right_tiles = options.width_tiles / 2 + right,
        spawn_front_tiles = -options.height_tiles / 2 + top,
    }
    return calibrated
end

local function collision_radius(name, options)
    local prototype
    if options.entity_of ~= nil then
        prototype = options.entity_of(name)
    elseif options.entities ~= nil then
        prototype = options.entities[name]
    else
        local raw = options.raw or (data and data.raw)
        prototype = raw and raw.asteroid and raw.asteroid[name]
    end
    if prototype == nil then
        return nil, "missing-asteroid-collision-geometry"
    end
    -- EntityPrototype::collision_box defaults to an empty box in the 2.1 docs.
    -- LuaEntity::bounding_box respects orientation; the furthest corner's radius encloses every rotation.
    -- https://lua-api.factorio.com/latest/prototypes/EntityPrototype.html#collision_box
    -- https://lua-api.factorio.com/latest/classes/LuaEntity.html#bounding_box
    if prototype.collision_box == nil then
        return 0
    end
    local left, top, right, bottom = bounds(prototype.collision_box)
    if not finite(left) or not finite(top) or not finite(right) or not finite(bottom) or left > 0 or top > 0 or right < 0 or bottom < 0 then
        return nil, "invalid-asteroid-collision-geometry"
    end
    local x = math.max(-left, right)
    local y = math.max(-top, bottom)
    local radius = math.sqrt(x * x + y * y)
    if not nonnegative(radius) then
        return nil, "invalid-asteroid-collision-geometry"
    end
    return radius
end

local function threat_fraction(name, calibrated, options)
    if calibrated.projection == nil then
        return 1
    end
    local radius, reason = collision_radius(name, options)
    if radius == nil then
        return nil, reason
    end
    if radius == 0 then
        return 0, nil, radius, 0
    end
    local projection = calibrated.projection
    local rear = calibrated.height_tiles / 2 + radius
    local lateral_reach = (rear - projection.spawn_front_tiles) * projection.max_lateral_slope
    local half_width = calibrated.width_tiles / 2 + radius + lateral_reach
    -- Union over every heading in [-slope, slope], allowing drift all the way to the enlarged hull's rear.
    -- This includes every front-edge origin whose fixed trajectory can intersect the radius-expanded rectangle.
    -- Using a union, rather than averaging headings, also allows heading to depend on spawn position.
    local left = math.max(projection.spawn_left_tiles, -half_width)
    local right = math.min(projection.spawn_right_tiles, half_width)
    local width = math.max(0, right - left)
    if not nonnegative(lateral_reach) or not nonnegative(width) then
        return nil, "invalid-projected-corridor"
    end
    return math.min(1, width / calibrated.expanded_width_tiles), nil, radius, width
end

local function route_curve(definition)
    local points = {}
    for _, point in pairs(definition.spawn_points or definition[2] or {}) do
        if not finite(point.distance) or point.distance < 0 or point.distance > 1 or not nonnegative(point.probability) then
            return nil
        end
        table.insert(points, {
            distance = point.distance,
            probability = point.probability,
        })
    end
    if #points == 0 then
        return nil
    end
    table.sort(points, function(a, b) return a.distance < b.distance end)
    for i = 2, #points do
        if points[i].distance == points[i - 1].distance then
            return nil
        end
    end
    return points
end

local function probability_at(points, distance)
    if distance <= points[1].distance then
        return points[1].probability
    end
    for i = 2, #points do
        local from = points[i - 1]
        local to = points[i]
        if distance <= to.distance then
            return from.probability + (to.probability - from.probability) * (distance - from.distance) / (to.distance - from.distance)
        end
    end
    return points[#points].probability
end

local function ceil_expected(value)
    if value == 0 then
        return 0
    end
    local nearest = math.floor(value + 0.5)
    if math.abs(value - nearest) <= 2e-15 * math.max(1, value) then
        value = nearest
    end
    return math.max(1, math.ceil(value))
end

-- Returns counts and calibration metadata, or nil and a reason.
-- No reference speed or footprint is guessed.
-- Engine configuration comes from the supplied prototypes/data.raw (base/prototypes/map-settings.lua and core/prototypes/utility-constants.lua), never a frozen vanilla settings table.
-- Counts combine each entity's separate peak; they need not occur simultaneously.
-- Optional normalized distance_min/distance_max restrict the peak search without rescaling route or endpoint coordinates.
asteroids.counts = function(connection, options)
    options = options or {}
    local calibrated, reason = calibration(options)
    if calibrated == nil then
        return nil, reason
    end
    local sources = {}
    local distance_min, distance_max = calibrated.route_distance_min, calibrated.route_distance_max
    local distances = {
        [distance_min] = true,
        [distance_max] = true,
    }
    local function sample(distance)
        if distance >= distance_min and distance <= distance_max then
            distances[distance] = true
        end
    end
    local function add(name, source)
        if type(name) ~= "string" or name == "" then
            return false
        end
        sources[name] = sources[name] or {}
        table.insert(sources[name], source)
        return true
    end
    for _, definition in pairs(connection.asteroid_spawn_definitions or {}) do
        if (definition.type or "entity") == "entity" then
            local points = route_curve(definition)
            if points == nil or not add(definition.asteroid or definition[1], {points = points}) then
                return nil, "invalid-route-spawn-curve"
            end
            for _, point in pairs(points) do
                sample(point.distance)
            end
        end
    end
    local function endpoint(name, destination)
        local location = (options.locations or {})[name]
        if location == nil then
            return "missing-endpoint-location"
        end
        -- Documented default, overridden by each actual location's value.
        -- https://lua-api.factorio.com/latest/prototypes/SpaceLocationPrototype.html#asteroid_spawn_influence
        local influence = location.asteroid_spawn_influence or 0.1
        if not nonnegative(influence) then
            return "invalid-endpoint-influence"
        end
        if influence == 0 then
            return
        end
        sample(destination and math.max(0, 1 - influence) or math.min(1, influence))
        for _, definition in pairs(location.asteroid_spawn_definitions or {}) do
            if (definition.type or "entity") == "entity" then
                if not nonnegative(definition.probability) or not add(definition.asteroid, {
                    probability = definition.probability,
                    influence = influence,
                    destination = destination,
                }) then
                    return "invalid-endpoint-spawn-definition"
                end
            end
        end
    end
    reason = endpoint(connection.from, false) or endpoint(connection.to, true)
    if reason ~= nil then
        return nil, reason
    end
    local counts = {}
    calibrated.expected_counts = {}
    calibrated.all_spawn_expected_counts = {}
    calibrated.threat_fractions = {}
    calibrated.collision_radii_tiles = {}
    calibrated.corridor_widths_tiles = {}
    calibrated.peak_distances = {}
    local sample_distances = {}
    for distance, _ in pairs(distances) do
        table.insert(sample_distances, distance)
    end
    table.sort(sample_distances)
    for name, definitions in pairs(sources) do
        local peak = 0
        local peak_distance
        for _, distance in pairs(sample_distances) do
            local probability = 0
            for _, source in pairs(definitions) do
                if source.points ~= nil then
                    probability = probability + probability_at(source.points, distance)
                else
                    local from_endpoint = source.destination and 1 - distance or distance
                    probability = probability + source.probability * math.max(0, 1 - from_endpoint / source.influence)
                end
            end
            if probability > peak then
                peak = probability
                peak_distance = distance
            end
        end
        local all_spawns = peak * calibrated.per_second_factor * calibrated.duration_seconds
        if not nonnegative(all_spawns) then
            return nil, "invalid-expected-count"
        end
        local fraction, fraction_reason, radius, corridor_width = threat_fraction(name, calibrated, options)
        if fraction == nil then
            return nil, fraction_reason
        end
        local expected = all_spawns * fraction
        -- Retain zero entries so a caller can distinguish zero configured spawn rate from an entity missing from its calibration.
        counts[name] = ceil_expected(expected)
        calibrated.expected_counts[name] = expected
        calibrated.all_spawn_expected_counts[name] = all_spawns
        calibrated.threat_fractions[name] = fraction
        calibrated.collision_radii_tiles[name] = radius
        calibrated.corridor_widths_tiles[name] = corridor_width
        calibrated.peak_distances[name] = peak_distance
    end
    return counts, calibrated
end

asteroids.new = function(options)
    return function(connection)
        return asteroids.counts(connection, options)
    end
end

return asteroids
