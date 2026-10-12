-- Compile each ammo effect once, then reuse it for a bounded set of compatible sources.
-- A counter always keeps the particular source and ammo as separate graph prerequisites.
-- This is an initial conservative scorer, not a simulation of positioning or ammunition throughput.

local damage = require("src/prototypes/combat/combat-damage")
local batteries = require("src/prototypes/combat/combat-batteries")
local asteroid_batteries = require("src/prototypes/combat/combat-asteroid-batteries")
local categories = require("src/prototypes/categories")
local gutils = require("src/lib/graph/graph-utils")

local counters = {}

local function sorted_keys(values)
    local keys = {}
    for name, _ in pairs(values or {}) do
        table.insert(keys, name)
    end
    table.sort(keys)
    return keys
end

local function mixed_name(left, right)
    return gutils.concat({
        "mixed-battery",
        left.name,
        right.name,
    })
end

local function asteroid_mixed_name(left, middle, right)
    local names = {
        left.name,
        middle.name,
        right.name,
    }
    table.sort(names)
    table.insert(names, 1, "asteroid-battery")
    return gutils.concat(names)
end

-- Array variants select by source_type, falling back to the first entry.
-- https://lua-api.factorio.com/latest/types/AmmoSourceType.html
local function ammo_for(item, source_type)
    local ammo = item.ammo_type
    if ammo == nil then
        return nil
    elseif ammo[1] == nil then
        return ammo
    end
    for _, variant in pairs(ammo) do
        if variant.source_type == source_type then
            return variant
        end
    end
    return ammo[1]
end

local function attack_categories(attack)
    if attack.ammo_categories ~= nil then
        return attack.ammo_categories
    elseif attack.ammo_category ~= nil then
        return { attack.ammo_category }
    end
    return {}
end

-- util.parse_energy returns joules for J and joules/tick for W (core/lualib/util.lua).
-- Assume a supplied electric network, as required by entity-operate, but enforce local buffer capacity and recharge rate.
-- Charging a shot is paid even for the first volley.
local function shot_energy(profile, source, ammo, parse_energy)
    if source.energy_per_shot == nil and ammo.energy_consumption == nil then
        return true
    end
    if parse_energy == nil then
        return nil, "missing-energy-parser"
    end
    local energy = source.energy_source
    if energy == nil then
        return nil, "missing-shot-energy-source"
    elseif energy.type == "void" then
        return true
    elseif energy.type ~= "electric" then
        return nil, "unsupported-shot-energy-source"
    end
    local function amount(value, default)
        if value == nil then
            return default
        end
        local ok, parsed = pcall(parse_energy, value)
        if ok == true and type(parsed) == "number" and parsed >= 0 and parsed < math.huge then
            return parsed
        end
    end
    local entity_shot = amount(source.energy_per_shot, 0)
    local ammo_shot = amount(ammo.energy_consumption, 0)
    local capacity = amount(energy.buffer_capacity)
    local input = amount(energy.input_flow_limit, math.huge)
    local drain = amount(energy.drain, 0)
    if entity_shot == nil or ammo_shot == nil or capacity == nil or input == nil or drain == nil then
        return nil, "invalid-shot-energy"
    end
    local cost = entity_shot + ammo_shot
    if capacity < cost then
        return nil, "shot-exceeds-buffer"
    elseif input <= drain and cost > 0 then
        return nil, "shot-cannot-recharge"
    end
    if cost > 0 then
        local recharge_ticks = math.ceil(cost / (input - drain))
        profile.interval_seconds = math.max(profile.interval_seconds, recharge_ticks / 60)
    end
    return true
end

-- Returns a whole-group provider and diagnostics. No gun/ammo/effect-path products are expanded.
-- The cap bounds compatible source/ammo profiles; omitted or unsupported profiles cannot prove an encounter.
-- counter_names, when supplied, is an encounter-name map of allowed counter-name sets; absent entries score nothing.
counters.prepare = function(lu, options)
    options = options or {}
    local limit = options.max_profiles or 4096
    assert(type(limit) == "number" and limit >= 1 and limit < math.huge and limit % 1 == 0, "Invalid combat profile limit")
    local entities = lu.entities or {}
    local items = lu.items or {}
    local resolver = damage.new({
        entity_of = options.entity_of or function(name) return entities[name] end,
        impact_effects = options.impact_effects,
        tile_effects = options.tile_effects,
        decorative_effects = options.decorative_effects,
        particle_of = options.particle_of,
        projectile_time = options.projectile_time,
        max_nodes = options.max_nodes,
        max_depth = options.max_depth,
        max_packets = options.max_packets,
    })
    local profiles = {}
    local diagnostics = {
        attempted = 0,
        compiled = 0,
        truncated = false,
        rejected = {},
        evaluation_rejected = {},
        mixed = {},
        asteroid_mixed = {},
    }
    local ammunition = {}
    for _, name in pairs(sorted_keys(items)) do
        local item = items[name]
        if item.type == "ammo" and item.ammo_category ~= nil then
            ammunition[item.ammo_category] = ammunition[item.ammo_category] or {}
            table.insert(ammunition[item.ammo_category], item)
        end
    end

    local function compile(source, attack, ammo, ammo_item)
        if diagnostics.attempted >= limit then
            diagnostics.truncated = true
            return
        end
        diagnostics.attempted = diagnostics.attempted + 1
        local name = gutils.concat({
            source.name,
            ammo_item and ammo_item.name or "builtin",
        })
        local summary, reason = resolver.ammo(ammo)
        local profile
        if summary ~= nil then
            profile, reason = damage.attack(summary, attack, ammo)
        end
        if profile == nil then
            diagnostics.rejected[name] = reason or "unsupported-attack"
            return
        end
        local powered
        powered, reason = shot_energy(profile, source, ammo, options.parse_energy or (util and util.parse_energy))
        if powered ~= true then
            diagnostics.rejected[name] = reason
            return
        end
        -- Effect summaries share their resolver callbacks; aiming is specific to a deployment.
        local target_options = {}
        for option, value in pairs(profile.target_options or {}) do
            target_options[option] = value
        end
        if source.mode == "manual" then
            target_options.segment_aim = options.manual_segment_aim or "worst-segment"
        else
            target_options.segment_aim = options.turret_segment_aim or "worst-segment"
        end
        profile.target_options = target_options
        target_options.segment_line_geometry = options.segment_line_geometry
        local prerequisites = {}
        for _, prerequisite in pairs(source.prerequisites) do
            table.insert(prerequisites, prerequisite)
        end
        if ammo_item ~= nil then
            table.insert(prerequisites, gutils.key("item", ammo_item.name))
        end
        table.insert(profiles, {
            name = name,
            source_key = source.name,
            mode = source.mode,
            prerequisites = prerequisites,
            profile = profile,
        })
        diagnostics.compiled = diagnostics.compiled + 1
    end

    local function add_source(source, attack, needs_ammo)
        if attack == nil or diagnostics.truncated then
            return
        end
        -- Filtered targets and fluid-specific modifiers need their own evaluator.
        if source.target_mask ~= nil or attack.fluids ~= nil then
            diagnostics.rejected[source.name] = "unsupported-source-filter"
            return
        end
        if not needs_ammo then
            if attack.ammo_type ~= nil then
                compile(source, attack, attack.ammo_type)
            end
            return
        end
        local seen = {}
        for _, category in pairs(attack_categories(attack)) do
            for _, item in pairs(ammunition[category] or {}) do
                if not seen[item.name] then
                    seen[item.name] = true
                    local ammo = ammo_for(item, source.source_type)
                    if ammo ~= nil then
                        compile(source, attack, ammo, item)
                    end
                    if diagnostics.truncated then
                        return
                    end
                end
            end
        end
    end

    for _, name in pairs(sorted_keys(items)) do
        local item = items[name]
        if item.type == "gun" then
            add_source({
                name = gutils.key("item-gun", name),
                mode = "manual",
                source_type = "player",
                prerequisites = { gutils.key("item-gun", name) },
            }, item.attack_parameters, true)
        end
    end
    for _, name in pairs(sorted_keys(entities)) do
        local entity = entities[name]
        if categories.turrets[entity.type] == true then
            -- Exclusion masks need checks beyond generic entity operation.
            -- https://lua-api.factorio.com/latest/prototypes/TurretPrototype.html#ignore_target_mask
            -- https://lua-api.factorio.com/latest/prototypes/AmmoTurretPrototype.html#energy_per_shot
            if entity.ignore_target_mask ~= nil then
                diagnostics.rejected[gutils.key("entity-operate", name)] = "unsupported-source-filter"
            else
                add_source({
                    name = gutils.key("entity-operate", name),
                    mode = "turret",
                    source_type = "turret",
                    target_mask = entity.attack_target_mask,
                    energy_source = entity.energy_source,
                    energy_per_shot = entity.energy_per_shot,
                    prerequisites = { gutils.key("entity-operate", name) },
                }, entity.attack_parameters, categories.ammo_required[entity.type])
            end
        end
        -- CarPrototype.guns names built-in guns; acquiring those hidden gun items is unnecessary.
        -- https://lua-api.factorio.com/latest/prototypes/CarPrototype.html#guns
        for _, gun_name in pairs(entity.guns or {}) do
            local gun = items[gun_name]
            if gun ~= nil then
                add_source({
                    name = gutils.concat({
                        gutils.key("entity-operate", name),
                        gun_name,
                    }),
                    mode = "manual",
                    source_type = "vehicle",
                    prerequisites = {
                        gutils.key("entity-operate", name),
                        gutils.key("planet", ""),
                    },
                }, gun.attack_parameters, true)
            end
        end
    end

    local function provide(definition)
        local result = {}
        local single_times = {}
        local allowed_names = options.counter_names and options.counter_names[definition.name] or {}
        local function allowed(name)
            return options.counter_names == nil or allowed_names[name] == true
        end
        local pair_allowed
        if options.counter_names ~= nil then
            pair_allowed = function(left, right) return allowed(mixed_name(left, right)) end
        end
        for index, source in pairs(profiles) do
            if allowed(source.name) then
                local count = source.mode == "turret" and definition.policy.turret_count or definition.policy.manual_count
                local seconds, reason = damage.clear_seconds(source.profile, definition.targets, entities, count)
                if seconds ~= nil then
                    single_times[index] = seconds
                    table.insert(result, {
                        name = source.name,
                        mode = source.mode,
                        count = count,
                        prerequisites = source.prerequisites,
                        clear_seconds = seconds,
                    })
                else
                    reason = reason or "unsupported-workload"
                    diagnostics.evaluation_rejected[reason] = (diagnostics.evaluation_rejected[reason] or 0) + 1
                end
            end
        end
        local mixtures, mixed_diagnostics = batteries.evaluate(profiles, definition.targets, entities, {
            deployment_count = definition.policy.turret_count,
            max_pairs = options.max_mixed_pairs,
            max_work = options.max_mixed_work,
            max_seconds = definition.policy.clear_seconds,
            feasibility_only = options.feasibility_only,
            pair_allowed = pair_allowed,
        })
        diagnostics.mixed[definition.name or "workload"] = mixed_diagnostics
        local pair_times = {}
        for _, mixture in pairs(mixtures) do
            pair_times[mixture.left] = pair_times[mixture.left] or {}
            pair_times[mixture.left][mixture.right] = mixture.clear_seconds
            -- A faster homogeneous battery needs a subset of this pair's prerequisites.
            local dominated = (single_times[mixture.left] ~= nil and single_times[mixture.left] <= mixture.clear_seconds)
                or (single_times[mixture.right] ~= nil and single_times[mixture.right] <= mixture.clear_seconds)
            if not dominated or options.retain_dominated == true then
                local left, right = profiles[mixture.left], profiles[mixture.right]
                local prerequisites, seen = {}, {}
                for _, source in pairs({
                    left,
                    right,
                }) do
                    for _, prerequisite in pairs(source.prerequisites) do
                        if seen[prerequisite] == nil then
                            table.insert(prerequisites, prerequisite)
                            seen[prerequisite] = true
                        end
                    end
                end
                table.sort(prerequisites)
                table.insert(result, {
                    name = mixed_name(left, right),
                    mode = left.mode,
                    count = mixture.left_count + mixture.right_count,
                    prerequisites = prerequisites,
                    clear_seconds = mixture.clear_seconds,
                    sources = {
                        {
                            name = left.name,
                            count = mixture.left_count,
                        },
                        {
                            name = right.name,
                            count = mixture.right_count,
                        },
                    },
                })
            end
        end
        -- Asteroid defense can dedicate different weapons to successive size classes.
        -- This bounded three-profile search is reserved for those encounters.
        if definition.kind == "asteroid-route" then
            local triple_allowed
            if options.counter_names ~= nil then
                triple_allowed = function(left, middle, right) return allowed(asteroid_mixed_name(left, middle, right)) end
            end
            local triples, triple_diagnostics = asteroid_batteries.evaluate(profiles, definition.targets, entities, {
                deployment_count = definition.policy.turret_count,
                max_triples = options.max_asteroid_triples,
                max_scanned_triples = options.max_asteroid_scanned_triples,
                max_work = options.max_asteroid_work,
                max_seconds = definition.policy.clear_seconds,
                feasibility_only = options.feasibility_only,
                triple_allowed = triple_allowed,
            })
            diagnostics.asteroid_mixed[definition.name or "workload"] = triple_diagnostics
            for _, mixture in pairs(triples) do
                local function faster_pair(left, right)
                    local seconds = pair_times[left] and pair_times[left][right]
                    return seconds ~= nil and seconds <= mixture.clear_seconds
                end
                local dominated = (single_times[mixture.left] ~= nil and single_times[mixture.left] <= mixture.clear_seconds)
                    or (single_times[mixture.middle] ~= nil and single_times[mixture.middle] <= mixture.clear_seconds)
                    or (single_times[mixture.right] ~= nil and single_times[mixture.right] <= mixture.clear_seconds)
                    or faster_pair(mixture.left, mixture.middle)
                    or faster_pair(mixture.left, mixture.right)
                    or faster_pair(mixture.middle, mixture.right)
                if not dominated or options.retain_dominated == true then
                    local left, middle, right = profiles[mixture.left], profiles[mixture.middle], profiles[mixture.right]
                    local prerequisites, seen = {}, {}
                    for _, source in pairs({
                        left,
                        middle,
                        right,
                    }) do
                        for _, prerequisite in pairs(source.prerequisites) do
                            if seen[prerequisite] == nil then
                                table.insert(prerequisites, prerequisite)
                                seen[prerequisite] = true
                            end
                        end
                    end
                    table.sort(prerequisites)
                    table.insert(result, {
                        name = asteroid_mixed_name(left, middle, right),
                        mode = left.mode,
                        count = mixture.left_count + mixture.middle_count + mixture.right_count,
                        prerequisites = prerequisites,
                        clear_seconds = mixture.clear_seconds,
                        sources = {
                            {
                                name = left.name,
                                count = mixture.left_count,
                            },
                            {
                                name = middle.name,
                                count = mixture.middle_count,
                            },
                            {
                                name = right.name,
                                count = mixture.right_count,
                            },
                        },
                    })
                end
            end
        end
        return result
    end
    return provide, diagnostics
end

return counters
