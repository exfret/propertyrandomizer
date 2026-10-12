-- Weapons and kill times for the combat check (src/logic/builders/combat-encounters.lua).
-- A weapon is a gun, turret or vehicle gun with one ammo it fires (one fluid for a fluid turret), compiled once per logic build.
-- A kill time is how long ten turrets of one weapon, or one weapon in hand, take to kill one target on its own.
-- This is a conservative scorer, not a simulation of positioning or ammunition throughput.

local damage = require("src/prototypes/combat/combat-damage")
local targets = require("src/prototypes/combat/combat-targets")
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

-- Every weapon the data has, as {name, mode ("turret" or "manual"), prerequisites (node keys), profile, target_options}, and diagnostics of the ones left out
-- A turret needs its entity-operate and its ammo item (or the fluid it fires); a gun in hand its item-gun; a vehicle's gun the vehicle's entity-operate on a planet
counters.weapons = function(lu, options)
    options = options or {}
    local entities = lu.entities or {}
    local items = lu.items or {}
    local resolver = damage.new({
        entity_of = options.entity_of or function(name) return entities[name] end,
        chain_of = options.chain_of,
        impact_effects = options.impact_effects,
        tile_effects = options.tile_effects,
        decorative_effects = options.decorative_effects,
        particle_of = options.particle_of,
        projectile_time = options.projectile_time,
        max_nodes = options.max_nodes,
        max_depth = options.max_depth,
        max_packets = options.max_packets,
    })
    local weapons = {}
    local diagnostics = {
        compiled = 0,
        rejected = {},
    }
    local ammunition = {}
    for _, name in pairs(sorted_keys(items)) do
        local item = items[name]
        if item.type == "ammo" and item.ammo_category ~= nil then
            ammunition[item.ammo_category] = ammunition[item.ammo_category] or {}
            table.insert(ammunition[item.ammo_category], item)
        end
    end

    local function compile(source, attack, ammo, ammo_item, fluid)
        local name = gutils.concat({
            source.name,
            ammo_item and ammo_item.name or fluid and fluid.type or "builtin",
        })
        local summary, reason = resolver.ammo(ammo)
        local profile
        if summary ~= nil then
            profile, reason = damage.attack(summary, attack, ammo, fluid and fluid.damage_modifier)
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
        target_options.segment_aim = source.mode == "manual" and (options.manual_segment_aim or "worst-segment") or (options.turret_segment_aim or "worst-segment")
        target_options.segment_line_geometry = options.segment_line_geometry
        local prerequisites = {}
        for _, prerequisite in pairs(source.prerequisites) do
            table.insert(prerequisites, prerequisite)
        end
        if ammo_item ~= nil then
            table.insert(prerequisites, gutils.key("item", ammo_item.name))
        elseif fluid ~= nil then
            table.insert(prerequisites, gutils.key("fluid", fluid.type))
        end
        table.insert(weapons, {
            name = name,
            mode = source.mode,
            prerequisites = prerequisites,
            profile = profile,
            target_options = target_options,
        })
        diagnostics.compiled = diagnostics.compiled + 1
    end

    local function add_source(source, attack, needs_ammo)
        if attack == nil then
            return
        end
        -- Filtered targets need their own evaluator.
        if source.target_mask ~= nil then
            diagnostics.rejected[source.name] = "unsupported-source-filter"
            return
        end
        -- A fluid turret fires its own stream with each fluid it takes, which scales the damage by the fluid's damage_modifier
        -- https://lua-api.factorio.com/latest/types/StreamAttackParameters.html#fluids
        if attack.fluids ~= nil then
            if attack.ammo_type ~= nil then
                for _, fluid in pairs(attack.fluids) do
                    compile(source, attack, attack.ammo_type, nil, fluid)
                end
            end
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
    return weapons, diagnostics, resolver.target_options
end

-- For each target name, what kills it on its own: a list of {weapon (index into weapons), seconds} for the weapons that kill it at all
-- Turrets deploy turret_count of one weapon, a weapon in hand is one; reasons says why a target couldn't be scored at all
-- With options.outnumber, a turret weapon that does damage per hit but can't outpace regeneration at turret_count is listed too, with seconds = math.huge, outnumbered = true and its damage per shot, since more turrets of it would win (the final check, user 2026-10-12)
counters.kill_times = function(weapons, names, entities, options)
    options = options or {}
    local resolver = targets.new(entities, options.target_options)
    local list, reasons = {}, {}
    for _, name in pairs(names) do
        local target, reason = resolver.target(name)
        if target ~= nil then
            table.insert(list, target)
        else
            reasons[name] = reason
        end
    end
    local times = {}
    for index, weapon in pairs(weapons) do
        local evaluator = targets.prepare(weapon.profile, list, weapon.target_options)
        if evaluator ~= nil then
            local team = weapon.mode == "turret" and (options.turret_count or 10) or (options.manual_count or 1)
            for _, target in pairs(list) do
                local seconds, reason = evaluator.seconds(target.entity, team)
                local entry
                if seconds ~= nil then
                    entry = {
                        weapon = index,
                        seconds = seconds,
                    }
                elseif options.outnumber == true and weapon.mode == "turret" and reason == "insufficient-damage" and (evaluator.shot_damage(target.entity) or 0) > 0 then
                    entry = {
                        weapon = index,
                        seconds = math.huge,
                        outnumbered = true,
                        shot_damage = evaluator.shot_damage(target.entity),
                    }
                end
                if entry ~= nil then
                    times[target.entity] = times[target.entity] or {}
                    table.insert(times[target.entity], entry)
                end
            end
        end
    end
    return times, reasons, resolver
end

return counters
