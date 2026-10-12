-- Damage types are categorical mutations whose consequences enter the ordinary promotion graph.
-- Run after reflection so scorer inputs are the actual prototypes the other handlers produced.

local helper = require("src/randomizations/unified/handler-helpers/damage-types")
local combat = require("src/logic/builders/combat-encounters")
local encounters = require("src/prototypes/combat/combat-encounters")
local type_safety = require("src/prototypes/combat/combat-type-safety")
local damage = require("src/prototypes/combat/combat-damage")
local resistances = require("src/prototypes/combat/combat-resistances")
local combat_lookup = require("src/prototypes/lookup/2-simple/combat")
local lu = require("src/prototypes/lookup/init")
local trigger = require("src/prototypes/entities/trigger")
local dutils = require("src/prototypes/data-utils")
local gutils = require("src/lib/graph/graph-utils")
local customization = require("src/config/graph-customization")
local rng = require("src/lib/random/rng")

local handler = {}
handler.id = "damage-types"
handler.with_replacement = true

local function keys(values)
    local result = {}
    for name, _ in pairs(values or {}) do
        table.insert(result, name)
    end
    table.sort(result)
    return result
end

handler.initialize = function()
end

handler.claim = function()
    -- Mutations can affect several sources/encounters at once; there is no independent base/head assignment.
end

handler.validate = function()
    return false
end

handler.reflect = function()
end

handler.spoof = function(graph)
    for edge_key, edge in pairs(graph.edges) do
        local stop = graph.nodes[edge.stop]
        if stop.type == "damage-type" or stop.type == "combat-encounter-counters" then
            randomization_info.options.first_pass.blacklist[gutils.key("orand", edge_key)] = true
        end
    end
end

local function evaluate(counter_names)
    local supplied = combat.prepare(lu, {
        scorer = {
            retain_dominated = true,
            -- Retained alternatives only need a complete passing schedule during a proposal.
            feasibility_only = counter_names ~= nil,
            counter_names = counter_names,
        },
    })
    local evaluated = {}
    for _, definition in pairs(supplied.definitions) do
        local result = {
            policy = definition.policy,
            counters = {},
        }
        if definition.targets_complete ~= false and definition.workload_calibrated == true then
            for _, counter in pairs(supplied.counter_provider(definition) or {}) do
                result.counters[counter.name] = counter
            end
        end
        evaluated[definition.name] = result
    end
    combat_lookup.damage_type_sources()
    return {
        definitions = supplied.definitions,
        encounters = evaluated,
        sources = lu.damage_type_sources,
    }
end

-- Discover physical packets through the existing trigger schema walker, not a list of weapon names.
-- Shared effects stay shared; every source that refers to them is rescored in the same transaction.
local function groups()
    local player_packets = {}
    local blocked_packets = {}
    local seen_sources = {}
    for _, sources in pairs(lu.damage_type_sources) do
        for source_key, _ in pairs(sources) do
            if not seen_sources[source_key] then
                seen_sources[source_key] = true
                local source = gutils.deconstruct(source_key)
                local prototype = dutils.get_prot(source.type, source.name)
                local gather = prototype and trigger.type_to_gather_struct_func[prototype.type]
                if gather ~= nil then
                    local structs = {}
                    gather(structs, prototype)
                    for _, packet in pairs(structs["damage-parameters"] or {}) do
                        player_packets[packet] = true
                        if not customization.selected(handler.id, prototype) or customization.excluded(handler.id, prototype) then
                            blocked_packets[packet] = true
                        end
                    end
                end
            end
        end
    end
    local owners = {}
    for _, class in pairs(keys(data.raw)) do
        local gather = trigger.type_to_gather_struct_func[class]
        if gather ~= nil then
            for _, name in pairs(keys(data.raw[class])) do
                local prototype = data.raw[class][name]
                local structs = {}
                gather(structs, prototype, true)
                local packets = structs["damage-parameters"] or {}
                if customization.selected(handler.id, prototype) and not customization.excluded(handler.id, prototype) then
                    table.insert(owners, {
                        prototype = prototype,
                        packets = packets,
                    })
                else
                    for _, packet in pairs(packets) do
                        blocked_packets[packet] = true
                    end
                end
            end
        end
    end
    local result, seen = {}, {}
    for _, owner in pairs(owners) do
        local packets = {}
        for _, packet in pairs(owner.packets) do
            if player_packets[packet] == true and blocked_packets[packet] == nil and seen[packet] == nil and type(packet.type) == "string" and encounters.positive_finite(packet.amount) then
                seen[packet] = true
                table.insert(packets, packet)
            end
        end
        if #packets > 0 then
            table.insert(result, {
                prototype = owner.prototype,
                packets = packets,
            })
        end
    end
    return result
end

handler.collect_groups = groups

handler.after_reflection = function(params)
    if params.promotion == nil then
        return true
    end
    lu.load_lookups()
    combat_lookup.link(lu)
    local graph = params.split_graph or params.random_graph
    local captured = helper.capture(graph)
    local function commit(trial)
        return params.promotion.try_rewires(helper.changes(graph, captured, trial.encounters, trial.sources, params.promotion.pre_keys_of), true)
    end
    -- Reflection itself may invalidate a proof. Retry the whole unified attempt instead of certifying stale inputs.
    local baseline = evaluate()
    if not commit(baseline) then
        log("DAMAGECHECK reflected combat inputs lost a promised witness")
        return false
    end
    local counter_names, safety_encounters = {}, {}
    for name, result in pairs(baseline.encounters) do
        safety_encounters[name] = {
            policy = result.policy,
            counters = {},
        }
    end
    for node_key, links in pairs(captured.counters) do
        local names = {}
        counter_names[graph.nodes[node_key].name] = names
        for _, node in pairs(links) do
            names[node.counter_name] = true
            local result = baseline.encounters[node.encounter_name]
            local candidate = result and result.counters[node.counter_name]
            if result ~= nil and helper.same_witness(node, candidate, result.policy) then
                safety_encounters[node.encounter_name].counters[node.counter_name] = candidate
            end
        end
    end
    local entity_of = function(name) return dutils.get_prot("entity", name) end
    local resolver = damage.new({
        entity_of = entity_of,
        particle_of = function(name) return dutils.prots("optimized-particle")[name] end,
        impact_effects = dutils.prots("deliver-impact-combination"),
        tile_effects = dutils.prots("tile"),
        decorative_effects = dutils.prots("optimized-decorative"),
    })
    -- A reflection-only success has no retained graph alternative for promotion to protect.
    -- Such encounters still need the unscored fallback, even though unrestricted baseline scoring found a counter.
    local safety = type_safety.new(baseline.definitions, safety_encounters, lu.entities, {
        entity_of = entity_of,
        visual_effect = resolver.visual_effect,
        visual_entity = resolver.visual_entity,
    })
    log("DAMAGECHECK unscored benchmarks " .. safety.unscored_count .. "; conservative type restrictions active=" .. tostring(safety.unscored_count > 0))
    local function evaluate_trial()
        return evaluate(counter_names)
    end
    local candidates = groups()
    local damage_types = keys(dutils.prots("damage-type"))
    local rng_key = rng.key({ id = handler.id })
    rng.shuffle(rng_key, candidates)
    local tried, changed = 0, 0
    -- A fixed search budget prevents modded effect graphs from turning this into an unbounded product search.
    local budget = 64
    local resistance_groups = resistances.collect(lu.entities, dutils.prots("damage-type"), function(prototype)
        return customization.selected(handler.id, prototype) and not customization.excluded(handler.id, prototype)
    end, data.raw)
    local sensitive_entities = resistances.target_set(baseline.definitions, lu.entities, data.raw)
    local partition = resistances.partition(resistance_groups, {
        raw = data.raw,
        sensitive_entities = sensitive_entities,
        all_sensitive = sensitive_entities == nil,
    })
    rng.shuffle(rng_key, partition.sensitive)
    local ordinary_proposals, ordinary_previous = {}, {}
    for _, batch in pairs(partition.ordinary) do
        if batch.can_permute then
            local permutation = encounters.copy(batch.types)
            rng.shuffle(rng_key, permutation)
            table.insert(ordinary_proposals, {
                group = batch,
                permutation = permutation,
            })
            for _, row in pairs(batch.entries) do ordinary_previous[row] = row.type end
        end
    end
    local resistance_changed, ordinary_changed = 0, 0
    -- An empty benchmark cannot certify a harder resistance assignment; retain its original mapping.
    -- Keep half of the shared proposal budget available for damage packets.
    if safety.unscored_count == 0 and safety.blocked ~= true then
        local sensitive_budget = budget / 2 - (#ordinary_proposals > 0 and 1 or 0)
        for _, group in pairs(partition.sensitive) do
            if tried >= sensitive_budget then break end
            if group.can_permute then
                local permutation = encounters.copy(group.types)
                rng.shuffle(rng_key, permutation)
                tried = tried + 1
                if resistances.attempt(group, permutation, evaluate_trial, commit) then
                    resistance_changed = resistance_changed + 1
                    log("RESISTANCECHANGE " .. gutils.key(group.prototype))
                end
            end
        end
        if #ordinary_proposals > 0 then
            tried = tried + 1
            if resistances.attempt_batch(ordinary_proposals, evaluate_trial, commit) then
                for _, proposal in pairs(ordinary_proposals) do
                    for _, group in pairs(proposal.group.groups) do
                        for _, row in pairs(group.entries) do
                            if row.type ~= ordinary_previous[row] then
                                ordinary_changed = ordinary_changed + 1
                                break
                            end
                        end
                    end
                end
                resistance_changed = resistance_changed + ordinary_changed
                log("RESISTANCECHANGE ordinary batches: " .. #ordinary_proposals .. "; shared groups: " .. ordinary_changed)
            end
        end
    end
    for _, group in pairs(candidates) do
        if tried >= budget then
            break
        end
        local types = encounters.copy(damage_types)
        rng.shuffle(rng_key, types)
        for _, damage_type in pairs(types) do
            local differs = false
            local safe = true
            for _, packet in pairs(group.packets) do
                differs = differs or packet.type ~= damage_type
                safe = safe and safety.allows(packet.type, damage_type) == true
            end
            if differs and safe and tried < budget then
                tried = tried + 1
                if helper.attempt(group.packets, damage_type, evaluate_trial, commit) then
                    changed = changed + 1
                    log("DAMAGECHANGE " .. gutils.key(group.prototype) .. " -> " .. damage_type)
                    break
                end
            end
        end
    end
    -- The last rejected trial's lookup tables must not leak into subsequent consumers.
    combat_lookup.damage_type_sources()
    log("RESISTANCECHECK accepted " .. resistance_changed .. " shared groups (" .. ordinary_changed .. " ordinary); "
        .. #partition.sensitive .. " sensitive groups; " .. #partition.ordinary .. " ordinary batches; frozen="
        .. tostring(safety.unscored_count > 0 or safety.blocked == true))
    log("DAMAGECHECK accepted " .. changed .. " prototype groups from " .. tried .. " proposals; " .. #candidates .. " eligible groups")
    return true
end

return handler
