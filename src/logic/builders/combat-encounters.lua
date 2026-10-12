-- Encounter node foundation, separate from weapon/effect enumeration.
-- The counter provider must estimate one entire fixed group using at most ten turrets or one manual source, including all its prerequisites.
-- It must read current candidate prototype properties; target.reference only records the original properties.
-- Unsupported effects remain unscored, never a successful immunity-only approximation.

local encounters = require("src/prototypes/combat/combat-encounters")
local asteroids = require("src/prototypes/combat/combat-asteroids")
local counters = require("src/logic/builders/combat-counters")
local gutils = require("src/lib/graph/graph-utils")
local ctx = require("src/logic/contexts/contexts")
local builder = require("src/logic/builders/builder")
local dutils = require("src/prototypes/data-utils")
local lutils = require("src/logic/logic-utils")

local add_node = builder.add_node
local add_edge = builder.add_edge
local set_class = builder.set_class
local set_prot = builder.set_prot
local key = gutils.key

local combat = {}
local baseline_definitions

combat.reset = function()
    baseline_definitions = nil
end

combat.definitions = function()
    return encounters.copy(baseline_definitions or {})
end

-- Nodes are stored directly on the graph before graph-setup builds its indexes.
local function node_at(graph, node_key)
    local node = graph.nodes ~= nil and graph.nodes[node_key] or graph[node_key]
    if type(node) == "table" and node.object_type == "node" then
        return node
    end
end

local function rejection(graph, counter, policy)
    if type(counter) ~= "table" or type(counter.name) ~= "string" or counter.name == "" then
        return "invalid-counter"
    end
    if counter.mode ~= "turret" and counter.mode ~= "manual" then
        return "unknown-deployment"
    end
    local limit = counter.mode == "turret" and policy.turret_count or policy.manual_count
    local count = counter.count or limit
    if not encounters.positive_finite(count) or count % 1 ~= 0 or count > limit then
        return "deployment-limit"
    end
    if not encounters.positive_finite(counter.clear_seconds) then
        return "unknown-clear-time"
    end
    if counter.clear_seconds > policy.clear_seconds then
        return "too-slow"
    end
    if type(counter.prerequisites) ~= "table" or #counter.prerequisites == 0 then
        return "missing-prerequisites"
    end
    for _, prerequisite in pairs(counter.prerequisites) do
        if type(prerequisite) ~= "string" or node_at(graph, prerequisite) == nil then
            return "unknown-prerequisite"
        end
    end
end

-- Definitions can be captured once and reused when validating candidates, keeping rosters/reference timing fixed.
-- Like the other important balance goals, scored encounters use first pass's existing mechanic witnesses and rank constraints.
-- No separate research checkpoints are needed; unscored encounters have no reachable contexts to preserve yet.
combat.build_definitions = function(graph, definitions, options)
    options = options or {}
    local built = {}
    set_class("combat-encounter")
    set_prot(nil)

    for _, original in pairs(definitions) do
        local definition = encounters.copy(original)
        local policy = definition.policy
        if policy == nil or options.difficulty ~= nil or options.time_multiplier ~= nil then
            policy = encounters.policy(options, definition)
        end
        if policy.check_enemies == true or definition.kind == "asteroid-route" then
            definition.policy = encounters.copy(policy)
            local anchor = definition.anchor or (definition.room and key("room", definition.room))
            local encounter_key = key("combat-encounter", definition.name)
            local counters_key = key("combat-encounter-counters", definition.name)
            local evaluation = {
                status = "unscored",
                accepted = 0,
                rejected = {},
            }
            ----------------------------------------
            add_node("combat-encounter", "AND", nil, definition.name, {
                mechanic = true,
                important = true,
                encounter = definition,
                evaluation = evaluation,
            })
            ----------------------------------------
            add_edge("combat-encounter-counters", definition.name)
            if anchor ~= nil and node_at(graph, anchor) ~= nil then
                local node = node_at(graph, anchor)
                add_edge(node.type, node.name)
            end
            ----------------------------------------
            add_node("combat-encounter-counters", "OR", nil, definition.name)
            ----------------------------------------
            -- Leave this OR empty until a numerical whole-group check succeeds.
            local candidates
            if anchor ~= nil and node_at(graph, anchor) == nil then
                evaluation.reason = "missing-anchor"
            elseif definition.targets_complete == false then
                evaluation.reason = "missing-target"
            elseif definition.workload_calibrated ~= true then
                evaluation.reason = "uncalibrated-workload"
            elseif options.counter_provider ~= nil then
                candidates = options.counter_provider(encounters.copy(definition))
            else
                evaluation.reason = "missing-counter-provider"
            end
            if candidates ~= nil then
                assert(type(candidates) == "table", "Combat counter provider must return a list or nil")
                evaluation.status = "scored"
                local names = {}
                for _, counter in pairs(candidates) do
                    local reason = rejection(graph, counter, policy)
                    if reason == nil and names[counter.name] ~= nil then
                        reason = "duplicate-counter"
                    end
                    if reason ~= nil then
                        table.insert(evaluation.rejected, reason)
                    else
                        names[counter.name] = true
                        local name = gutils.concat({
                            definition.name,
                            counter.name,
                        })
                        local count = counter.count or (counter.mode == "turret" and policy.turret_count or policy.manual_count)
                        ----------------------------------------
                        add_node("combat-encounter-counter", "AND", nil, name, {
                            counter_name = counter.name,
                            encounter_name = definition.name,
                            counter_prerequisites = encounters.copy(counter.prerequisites),
                            clear_seconds = counter.clear_seconds,
                            deployment_count = count,
                            deployment_mode = counter.mode,
                            deployment_sources = counter.sources,
                        })
                        ----------------------------------------
                        for _, prerequisite in pairs(counter.prerequisites) do
                            local node = node_at(graph, prerequisite)
                            add_edge(node.type, node.name)
                        end
                        local edge_extra = {}
                        if counter.mode == "manual" then
                            edge_extra.abilities = ctx.LOSES_AUTOMATABILITY
                        end
                        -- Automatic counters only preserve their inputs' abilities; nothing here grants automatic production or operation.
                        gutils.add_edge(graph, key("combat-encounter-counter", name), counters_key, edge_extra)
                        evaluation.accepted = evaluation.accepted + 1
                    end
                end
            end
            table.insert(built, encounter_key)
        end
    end
    return built
end

local function planet_of(name)
    return data.raw.planet and data.raw.planet[name]
end

local function entity_of(name)
    return dutils.get_prot("entity", name)
end

local function particle_of(name)
    return dutils.prots("optimized-particle")[name]
end

-- A fly-condition endpoint represents a continuing collection trip for this benchmark.
-- Travel toward ordinary destinations still covers the full connection.
-- https://lua-api.factorio.com/latest/prototypes/SpaceLocationPrototype.html#fly_condition
combat.collection_window = function(connection, locations, distance_km)
    if distance_km == nil then
        return 0, 1
    end
    if not encounters.positive_finite(distance_km) then
        return nil, "invalid-collection-distance"
    end
    local from = locations[connection.from]
    local to = locations[connection.to]
    local from_collection = from ~= nil and from.fly_condition == true
    local to_collection = to ~= nil and to.fly_condition == true
    if from_collection == to_collection then
        return 0, 1
    end
    -- SpaceConnectionPrototype.length defaults to 600 km.
    -- https://lua-api.factorio.com/latest/prototypes/SpaceConnectionPrototype.html#length
    local length = connection.length
    if length == nil then
        length = 600
    end
    if not encounters.positive_finite(length) then
        return nil, "invalid-collection-route-length"
    end
    local fraction = math.min(1, distance_km / length)
    if to_collection then
        return 0, fraction, connection.to
    end
    return 1 - fraction, 1, connection.from
end

combat.prepare = function(lu, options)
    local supplied = {}
    local diagnostics
    for k, value in pairs(options or {}) do
        supplied[k] = value
    end
    supplied.planet_of = supplied.planet_of or planet_of
    supplied.in_room = supplied.in_room or lutils.check_in_room
    supplied.connections = supplied.connections or dutils.prots("space-connection")
    supplied.locations = supplied.locations or dutils.get_all_prots("space-location")
    local enabled = config ~= nil and config.damage_type_randomization == true
    if enabled then
        if supplied.score_counters == nil then
            supplied.score_counters = true
        end
        supplied.difficulty = supplied.difficulty or config.military_difficulty or "normal"
        supplied.time_multiplier = supplied.time_multiplier or config.military_time_multiplier or 1
        -- Provisional collection-trip calibration; callers can supply another turnaround distance.
        if supplied.collection_distance_km == nil then
            supplied.collection_distance_km = 100000
        end
        supplied.reference_ship = supplied.reference_ship or {
            speed_km_per_second = 100,
            width_tiles = 20,
            height_tiles = 40,
        }
    end
    if supplied.asteroid_counts == nil and supplied.reference_ship ~= nil then
        local calibration = encounters.copy(supplied.reference_ship)
        calibration.locations = supplied.locations
        calibration.entity_of = entity_of
        -- The workload stays fixed when difficulty changes the allowed clearing time.
        calibration.duration_seconds = encounters.policy(supplied).baseline_seconds
        supplied.asteroid_counts = function(connection)
            local lower, upper, endpoint = combat.collection_window(connection, supplied.locations, supplied.collection_distance_km)
            if lower == nil then
                return nil, upper
            end
            local route_calibration = encounters.copy(calibration)
            route_calibration.distance_min = lower
            route_calibration.distance_max = upper
            local counts, details = asteroids.counts(connection, route_calibration)
            if counts ~= nil and endpoint ~= nil then
                details.collection_endpoint = endpoint
                details.collection_distance_km = supplied.collection_distance_km
            end
            return counts, details
        end
    end
    if supplied.counter_provider == nil and supplied.score_counters == true then
        local scorer_options = {}
        for name, value in pairs(supplied.scorer or {}) do
            scorer_options[name] = value
        end
        scorer_options.entity_of = scorer_options.entity_of or entity_of
        scorer_options.particle_of = scorer_options.particle_of or particle_of
        scorer_options.impact_effects = scorer_options.impact_effects or dutils.prots("deliver-impact-combination")
        scorer_options.tile_effects = scorer_options.tile_effects or dutils.prots("tile")
        scorer_options.decorative_effects = scorer_options.decorative_effects or dutils.prots("optimized-decorative")
        if enabled then
            scorer_options.segment_line_geometry = scorer_options.segment_line_geometry or "head-on"
        end
        supplied.counter_provider, diagnostics = counters.prepare(lu, scorer_options)
    end
    local definitions = supplied.definitions or (enabled and baseline_definitions) or encounters.collect(lu, supplied)
    if enabled and baseline_definitions == nil then
        baseline_definitions = encounters.copy(definitions)
    end
    supplied.definitions = definitions
    return supplied, diagnostics
end

combat.build = function(graph, lu, options)
    local supplied, diagnostics = combat.prepare(lu, options)
    return combat.build_definitions(graph, supplied.definitions, supplied), diagnostics
end

return combat
