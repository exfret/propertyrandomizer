-- Fixed combat workloads, independent of damage-source enumeration and graph evaluation.
-- Evolution is a scenario parameter, never a promise that an enemy can be acquired.

local acquisition = require("lib/logic/acquisition")
local gutils = require("lib/graph/graph-utils")

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

-- The reference workload/timing never changes with difficulty.
-- No Cap removes terrestrial benchmarks; asteroid checks retain the normal, finite allowance.
encounters.policy = function(options)
    options = options or {}
    local difficulty = options.difficulty or "normal"
    assert(difficulty == "normal" or difficulty == "no-cap", "Unknown combat difficulty")
    local multiplier = options.time_multiplier or 1
    assert(encounters.positive_finite(multiplier) and encounters.positive_finite(10 * multiplier), "Invalid combat time multiplier")
    return {
        difficulty = difficulty,
        check_enemies = difficulty ~= "no-cap",
        baseline_seconds = 10,
        clear_seconds = difficulty == "no-cap" and 10 or 10 * multiplier,
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
    definition.workload_calibrated = #definition.targets > 0
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
        definition.policy = copy(policy)
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
                    targets_by_name[name] = targets_by_name[name] or {
                        entity = name,
                        spawn_curves = {},
                    }
                    table.insert(targets_by_name[name].spawn_curves, copy(points))
                end
            end
        end
        local targets = {}
        local counts = options.asteroid_counts and options.asteroid_counts(connection)
        local actual_size = 0
        for _, name in pairs(sorted_keys(targets_by_name)) do
            local target = targets_by_name[name]
            if counts ~= nil and encounters.positive_finite(counts[name]) then
                target.amount = math.ceil(counts[name])
                actual_size = actual_size + target.amount
            end
            table.insert(targets, target)
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
                actual_size = counts ~= nil and actual_size or nil,
                targets = targets,
            })
        end
    end
    table.sort(definitions, function(a, b) return a.name < b.name end)
    return definitions
end

return encounters
