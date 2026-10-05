-- Encounter node foundation, separate from weapon/effect enumeration.
-- The counter provider must estimate one entire fixed group using at most ten turrets or one manual source, including all its prerequisites.
-- It must read current candidate prototype properties; target.reference only records the original properties.
-- No provider means unscored, never a successful immunity-only approximation.

local encounters = require("lib/combat-encounters")
local gutils = require("lib/graph/graph-utils")
local builder = require("lib/logic/builder")
local dutils = require("lib/data-utils")
local lutils = require("lib/logic/logic-utils")

local add_node = builder.add_node
local add_edge = builder.add_edge
local set_class = builder.set_class
local set_prot = builder.set_prot
local key = gutils.key

local combat = {}

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
-- This does not yet enforce acquisition deadlines: mechanic protection alone only preserves eventual room/ability reachability.
combat.build_definitions = function(graph, definitions, options)
    options = options or {}
    local option_policy = encounters.policy(options)
    local built = {}
    set_class("combat-encounter")
    set_prot(nil)

    for _, original in pairs(definitions) do
        local definition = encounters.copy(original)
        local policy = definition.policy or option_policy
        if options.difficulty ~= nil or options.time_multiplier ~= nil then
            policy = option_policy
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
                            clear_seconds = counter.clear_seconds,
                            deployment_count = count,
                            deployment_mode = counter.mode,
                        })
                        ----------------------------------------
                        for _, prerequisite in pairs(counter.prerequisites) do
                            local node = node_at(graph, prerequisite)
                            add_edge(node.type, node.name)
                        end
                        local edge_extra = {}
                        if counter.mode == "manual" then
                            edge_extra.abilities = { [2] = false }
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

combat.build = function(graph, lu, options)
    local supplied = {}
    for k, value in pairs(options or {}) do
        supplied[k] = value
    end
    supplied.planet_of = supplied.planet_of or planet_of
    supplied.in_room = supplied.in_room or lutils.check_in_room
    supplied.connections = supplied.connections or dutils.prots("space-connection")
    local definitions = supplied.definitions or encounters.collect(lu, supplied)
    return combat.build_definitions(graph, definitions, supplied)
end

return combat
