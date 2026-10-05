-- Categorical damage changes must not worsen targets whose benchmark has no proven counter.
-- This guard establishes componentwise resistance dominance, never encounter feasibility.
-- Construct it from the current prototypes; resistance and lifecycle mutations invalidate its snapshots.

local targets = require("lib/combat-targets")

local safety = {}

local function finite(value)
    return type(value) == "number" and value > -math.huge and value < math.huge
end

local function integer(value)
    return finite(value) and value >= 1 and value % 1 == 0
end

local function valid_counter(counter, policy)
    if type(counter) ~= "table" or type(policy) ~= "table" then
        return false
    end
    local limit
    if counter.mode == "turret" then
        limit = policy.turret_count
    elseif counter.mode == "manual" then
        limit = policy.manual_count
    else
        return false
    end
    local count = counter.count
    if count == nil then
        count = limit
    end
    if not integer(limit) or not integer(count) or count > limit then
        return false
    end
    if not finite(policy.clear_seconds) or policy.clear_seconds <= 0 or not finite(counter.clear_seconds)
        or counter.clear_seconds <= 0 or counter.clear_seconds > policy.clear_seconds then
        return false
    end
    if type(counter.prerequisites) ~= "table" or #counter.prerequisites == 0 then
        return false
    end
    for _, prerequisite in pairs(counter.prerequisites) do
        if type(prerequisite) ~= "string" or prerequisite == "" then
            return false
        end
    end
    return true
end

local function scored(definition, evaluated)
    if definition.targets_complete == false or definition.workload_calibrated == false then
        return false
    end
    local result = evaluated[definition.name]
    if type(result) ~= "table" or type(result.counters) ~= "table" then
        return false
    end
    for _, counter in pairs(result.counters) do
        if valid_counter(counter, result.policy) then
            return true
        end
    end
    return false
end

-- Evaluated counters come from the existing scorer/build validation, including prerequisite-node validity.
-- Resolver options accept the same entity_of / visual_effect / visual_entity callbacks as combat-targets.
safety.new = function(definitions, evaluated, entities, resolver_options)
    resolver_options = resolver_options or {}
    evaluated = evaluated or {}
    local guard = {
        unscored_count = 0,
        part_count = 0,
        blocked = false,
        details = {},
    }
    local maps, seen = {}, {}
    local limits = {
        definitions = resolver_options.max_definitions or 4096,
        roster_entries = resolver_options.max_roster_entries or 4096,
        parts = resolver_options.max_parts or 4096,
        resistances = resolver_options.max_resistance_entries or 65536,
    }
    local definitions_seen, roster_entries, resistance_entries = 0, 0, 0
    local resolver = targets.new(entities, resolver_options)
    local function block(reason, detail)
        guard.blocked = true
        guard.reason = guard.reason or reason
        detail.reason = reason
    end
    local function resistances(part)
        if type(part) ~= "table" or (part.resistances ~= nil and type(part.resistances) ~= "table") then
            return nil, "unsupported-resistance"
        end
        local result = {}
        -- Factorio 2.1 Resistance documents both components as "Higher is better", each defaulting to zero.
        -- https://lua-api.factorio.com/latest/types/Resistance.html
        -- Restrict this proof to the supported nonnegative flat / 0..100 percent domain.
        for _, resistance in pairs(part.resistances or {}) do
            resistance_entries = resistance_entries + 1
            if resistance_entries > limits.resistances then
                return nil, "resistance-entry-budget"
            end
            if type(resistance) ~= "table" or type(resistance.type) ~= "string" or resistance.type == "" then
                return nil, "unsupported-resistance"
            end
            local decrease = resistance.decrease
            local percent = resistance.percent
            if decrease == nil then
                decrease = 0
            end
            if percent == nil then
                percent = 0
            end
            if not finite(decrease) or decrease < 0 or not finite(percent) or percent < 0 or percent > 100 then
                return nil, "unsupported-resistance"
            end
            if result[resistance.type] ~= nil then
                return nil, "duplicate-resistance"
            end
            result[resistance.type] = {
                decrease = decrease,
                percent = percent,
            }
        end
        return result
    end
    if not integer(limits.definitions) or not integer(limits.roster_entries) or not integer(limits.parts) or not integer(limits.resistances)
        or type(definitions) ~= "table" or type(evaluated) ~= "table" then
        local detail = {}
        table.insert(guard.details, detail)
        block("invalid-safety-input", detail)
    else
        for _, definition in pairs(definitions) do
            definitions_seen = definitions_seen + 1
            if definitions_seen > limits.definitions then
                local detail = {}
                table.insert(guard.details, detail)
                block("definition-budget", detail)
                break
            end
            if type(definition) ~= "table" or type(definition.name) ~= "string" then
                local detail = {}
                table.insert(guard.details, detail)
                block("invalid-encounter-definition", detail)
            elseif not scored(definition, evaluated) then
                guard.unscored_count = guard.unscored_count + 1
                local detail = {
                    name = definition.name,
                    reason = "no-valid-counter",
                    parts = 0,
                }
                table.insert(guard.details, detail)
                if definition.targets_complete == false then
                    block("incomplete-target-roster", detail)
                elseif guard.blocked then
                    detail.reason = guard.reason
                else
                    if type(definition.targets) == "table" then
                        for _, _ in pairs(definition.targets) do
                            roster_entries = roster_entries + 1
                            if roster_entries > limits.roster_entries then
                                block("target-roster-budget", detail)
                                break
                            end
                        end
                    end
                    local okay, workload, reason
                    if guard.blocked ~= true then
                        okay, workload, reason = pcall(resolver.workload, definition.targets)
                    end
                    if guard.blocked then
                        detail.reason = guard.reason
                    elseif okay ~= true then
                        block("target-resolution-error", detail)
                    elseif workload == nil then
                        block(reason or "unknown-target-lifecycle", detail)
                    else
                        for _, target in pairs(workload) do
                            for _, part in pairs(target.parts) do
                                detail.parts = detail.parts + 1
                                if seen[part] == nil then
                                    seen[part] = true
                                    guard.part_count = guard.part_count + 1
                                    if guard.part_count > limits.parts then
                                        block("target-part-budget", detail)
                                        break
                                    end
                                    local map, map_reason = resistances(part)
                                    if map == nil then
                                        block(map_reason, detail)
                                        break
                                    end
                                    table.insert(maps, {
                                        name = part.name or target.entity,
                                        encounter = definition.name,
                                        resistances = map,
                                    })
                                end
                            end
                            if guard.blocked then
                                break
                            end
                        end
                    end
                end
            end
        end
    end
    guard.allows = function(old_type, new_type)
        if type(old_type) ~= "string" or old_type == "" or type(new_type) ~= "string" or new_type == "" then
            return false, "invalid-damage-type"
        end
        if old_type == new_type then
            return true
        end
        if guard.blocked then
            return false, guard.reason
        end
        for _, part in pairs(maps) do
            local old = part.resistances[old_type]
            local new = part.resistances[new_type]
            local old_decrease, old_percent = 0, 0
            local new_decrease, new_percent = 0, 0
            if old ~= nil then
                old_decrease, old_percent = old.decrease, old.percent
            end
            if new ~= nil then
                new_decrease, new_percent = new.decrease, new.percent
            end
            if new_decrease > old_decrease or new_percent > old_percent then
                return false, "unscored-target-resistance-increase", {
                    encounter = part.encounter,
                    entity = part.name,
                    old_decrease = old_decrease,
                    new_decrease = new_decrease,
                    old_percent = old_percent,
                    new_percent = new_percent,
                }
            end
        end
        return true
    end
    return guard
end

return safety
