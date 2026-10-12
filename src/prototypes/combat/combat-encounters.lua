-- Fixed combat workloads, independent of damage-source enumeration and graph evaluation.
-- Evolution is a scenario parameter, never a promise that an enemy can be acquired.

local acquisition = require("src/logic/builders/acquisition")
local gutils = require("src/lib/graph/graph-utils")

local encounters = {}

local function copy(value)
    if type(value) ~= "table" then
        return value
    end
    local result = {}
    for k, v in pairs(value) do
        result[k] = copy(v)
    end
    return result
end

encounters.copy = copy

local function sorted_keys(values)
    local keys = {}
    for k, _ in pairs(values) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

encounters.positive_finite = function(value)
    return type(value) == "number" and value > 0 and value < math.huge
end

-- Temporary route calibration explicitly requested by the user on 2026-10-05.
-- These longer clearing allowances compensate for the current conservative combat model.
-- The reference ship, collection distance and ten seconds of arrivals remain fixed.
local route_clear_seconds = {
    ["gleba-aquilo"] = 60,
    ["fulgora-aquilo"] = 60,
    ["aquilo-solar-system-edge"] = 60,
    ["solar-system-edge-shattered-planet"] = 120,
}

-- No Cap removes terrestrial benchmarks; asteroid checks retain their finite default allowances.
encounters.policy = function(options, definition)
    options = options or {}
    local difficulty = options.difficulty or "normal"
    assert(difficulty == "normal" or difficulty == "no-cap", "Unknown combat difficulty")
    local multiplier = options.time_multiplier or 1
    local clear_seconds = 20
    if definition ~= nil and definition.kind == "asteroid-route" then
        clear_seconds = route_clear_seconds[definition.source] or clear_seconds
    end
    assert(encounters.positive_finite(multiplier) and encounters.positive_finite(clear_seconds * multiplier), "Invalid combat time multiplier")
    return {
        difficulty = difficulty,
        check_enemies = difficulty ~= "no-cap",
        baseline_seconds = 10,
        clear_seconds = difficulty == "no-cap" and clear_seconds or clear_seconds * multiplier,
        turret_count = 10,
        manual_count = 1,
    }
end

-- UnitSpawnDefinition accepts named/tuple entries and interpolates their weights.
-- https://lua-api.factorio.com/latest/types/UnitSpawnDefinition.html
-- Duplicate unit entries merge before rounding, and every positive share survives.
encounters.spawn_targets = function(spawner, evolution, nominal_size)
    local weights = {}
    for _, definition in pairs(spawner.result_units or {}) do
        local unit, points = acquisition.read_spawn_definition(definition)
        local weight = acquisition.spawn_weight_at(points, evolution)
        if unit ~= nil and weight > 0 then
            weights[unit] = (weights[unit] or 0) + weight
        end
    end
    local total_weight = 0
    local names = sorted_keys(weights)
    for _, name in pairs(names) do
        total_weight = total_weight + weights[name]
    end
    local targets = {}
    local actual_size = 0
    for _, name in pairs(names) do
        local amount
        if encounters.positive_finite(nominal_size) then
            local expected = nominal_size * weights[name] / total_weight
            -- Ignore floating-point noise at whole counts without losing any positive rare target.
            amount = math.max(1, math.ceil(expected - 2e-15 * math.max(1, expected)))
            actual_size = actual_size + amount
        end
        table.insert(targets, {
            entity = name,
            share = weights[name] / total_weight,
            amount = amount,
        })
    end
    return targets, encounters.positive_finite(nominal_size) and actual_size or nil
end

-- Snapshot reference target properties separately from the fixed roster/counts.
-- A candidate scorer must use current prototype properties, not these reference stats.
-- Unknown targets remain in the roster and invalidate it; dropping them would understate difficulty.
local function describe_targets(definition, entities)
    definition.targets_complete = true
    definition.workload_calibrated = #definition.targets > 0 and definition.calibration_valid ~= false
    for _, target in pairs(definition.targets) do
        local entity = entities[target.entity]
        if entity == nil then
            definition.targets_complete = false
        else
            target.reference = {
                max_health = entity.max_health,
                healing_per_tick = entity.healing_per_tick,
                resistances = copy(entity.resistances or {}),
                segment_engine = copy(entity.segment_engine),
            }
        end
        if not encounters.positive_finite(target.amount) then
            definition.workload_calibrated = false
        end
    end
end

-- Pure-table entry point; the graph wrapper supplies prototype/room accessors.
-- group_size may override the user-approved calibration heuristic of four times a spawner's nearby-unit limit.
-- This is a chosen workload, not a predicted raid.
encounters.collect = function(lu, options)
    options = options or {}
    local policy = encounters.policy(options)
    local definitions = {}
    local entities = lu.entities or {}
    local function append(definition)
        definition.policy = encounters.policy(options, definition)
        describe_targets(definition, entities)
        table.insert(definitions, definition)
    end

    if policy.check_enemies == true then
        for _, room_key in pairs(sorted_keys(lu.rooms or {})) do
            local room = lu.rooms[room_key]
            if room.type == "planet" then
                for _, entity_name in pairs(sorted_keys(entities)) do
                    local spawner = entities[entity_name]
                    if spawner.result_units ~= nil and options.in_room(room, spawner) then
                        local nominal_size
                        if options.group_size ~= nil then
                            nominal_size = options.group_size(room, spawner)
                        elseif encounters.positive_finite(spawner.max_friends_around_to_spawn) then
                            nominal_size = 4 * spawner.max_friends_around_to_spawn
                        end
                        for step = 0, 5 do
                            local evolution = step / 5
                            local targets, actual_size = encounters.spawn_targets(spawner, evolution, nominal_size)
                            if #targets > 0 then
                                append({
                                    name = gutils.concat({
                                        room_key,
                                        "spawn",
                                        entity_name,
                                        step,
                                    }),
                                    kind = "spawn-group",
                                    room = room_key,
                                    anchor = gutils.key("room", room_key),
                                    source = entity_name,
                                    evolution = evolution,
                                    nominal_size = nominal_size,
                                    actual_size = actual_size,
                                    targets = targets,
                                })
                            end
                        end
                    end
                end
                local planet = options.planet_of(room.name)
                local map_gen = planet and planet.map_gen_settings
                local territory = map_gen and map_gen.territory_settings
                local units = {}
                -- TerritorySettings.units names individual segmented-unit variants.
                -- https://lua-api.factorio.com/latest/types/TerritorySettings.html
                for _, unit in pairs(territory and territory.units or {}) do
                    units[unit] = true
                end
                for _, unit in pairs(sorted_keys(units)) do
                    append({
                        name = gutils.concat({
                            room_key,
                            "territory",
                            unit,
                        }),
                        kind = "territory",
                        room = room_key,
                        anchor = gutils.key("room", room_key),
                        source = unit,
                        nominal_size = 1,
                        actual_size = 1,
                        targets = {
                            {
                                entity = unit,
                                amount = 1,
                            },
                        },
                    })
                end
            end
        end
    end

    for _, connection_name in pairs(sorted_keys(options.connections or {})) do
        local connection = options.connections[connection_name]
        local targets_by_name = {}
        local function target_of(name)
            targets_by_name[name] = targets_by_name[name] or {
                entity = name,
                spawn_curves = {},
                endpoint_spawns = {},
            }
            return targets_by_name[name]
        end
        -- Probability and asteroid speed are retained as inputs, not interpreted as asteroids/second.
        -- A later rate adapter must supply calibrated counts.
        -- https://lua-api.factorio.com/latest/types/SpaceConnectionAsteroidSpawnDefinition.html
        for _, spawn in pairs(connection.asteroid_spawn_definitions or {}) do
            if (spawn.type or "entity") == "entity" then
                local name = spawn.asteroid or spawn[1]
                local points = spawn.spawn_points or spawn[2] or {}
                local positive = false
                for _, point in pairs(points) do
                    positive = positive or (point.probability or 0) > 0
                end
                if name ~= nil and positive then
                    table.insert(target_of(name).spawn_curves, copy(points))
                end
            end
        end
        -- Endpoint definitions also contribute to routes within their location's influence.
        -- https://lua-api.factorio.com/latest/prototypes/SpaceLocationPrototype.html#asteroid_spawn_influence
        local function add_endpoint(location_name)
            local location = (options.locations or {})[location_name]
            if location == nil then
                return
            end
            local influence = location.asteroid_spawn_influence or 0.1
            if not encounters.positive_finite(influence) then
                return
            end
            for _, spawn in pairs(location.asteroid_spawn_definitions or {}) do
                if (spawn.type or "entity") == "entity" and spawn.asteroid ~= nil and encounters.positive_finite(spawn.probability) then
                    table.insert(target_of(spawn.asteroid).endpoint_spawns, {
                        location = location_name,
                        influence = influence,
                        definition = copy(spawn),
                    })
                end
            end
        end
        add_endpoint(connection.from)
        add_endpoint(connection.to)

        local counts
        local calibration
        local calibration_reason
        if options.asteroid_counts ~= nil then
            local detail
            counts, detail = options.asteroid_counts(connection)
            if type(detail) == "table" then
                calibration = copy(detail)
            elseif type(detail) == "string" then
                calibration_reason = detail
            end
            if counts ~= nil then
                if type(counts) ~= "table" then
                    calibration_reason = "invalid-asteroid-counts"
                    counts = nil
                else
                    for name, amount in pairs(counts) do
                        if type(name) ~= "string" or name == "" or (amount ~= 0 and not encounters.positive_finite(amount)) then
                            calibration_reason = "invalid-asteroid-counts"
                            counts = nil
                            break
                        end
                    end
                end
            end
            if counts == nil then
                calibration_reason = calibration_reason or "missing-asteroid-counts"
            end
        else
            calibration_reason = "missing-asteroid-calibration"
        end
        -- An adapter may know additional targets; retain them even when it cannot find their prototypes.
        for name, amount in pairs(counts or {}) do
            if amount > 0 then
                target_of(name)
            end
        end
        local targets = {}
        local actual_size = 0
        local complete = counts ~= nil
        for _, name in pairs(sorted_keys(targets_by_name)) do
            local target = targets_by_name[name]
            local amount = counts and counts[name]
            -- Only an explicit, validated zero removes a known target from the workload.
            if amount ~= 0 then
                if amount ~= nil then
                    target.amount = math.max(1, math.ceil(amount - 2e-15 * math.max(1, amount)))
                    actual_size = actual_size + target.amount
                else
                    complete = false
                    calibration_reason = calibration_reason or "missing-target-count"
                end
                table.insert(targets, target)
            end
        end
        if not encounters.positive_finite(actual_size) then
            complete = false
            calibration_reason = calibration_reason or "invalid-total-count"
        end
        if #targets > 0 then
            append({
                name = gutils.concat({
                    "route",
                    connection_name,
                }),
                kind = "asteroid-route",
                source = connection_name,
                anchor = gutils.key("space-surface", ""),
                actual_size = complete and actual_size or nil,
                targets = targets,
                calibration = calibration,
                calibration_reason = calibration_reason,
                calibration_valid = complete,
            })
        end
    end
    table.sort(definitions, function(a, b) return a.name < b.name end)
    return definitions
end

return encounters
