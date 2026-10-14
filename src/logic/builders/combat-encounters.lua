-- The combat check: whether some weapon kills each target on its own, and what attack groups, territories, asteroid routes and kills need of that (user, 2026-10-12).
-- A combat-target node (OR) per target has an edge from every weapon that kills it on its own within the time limit: ten turrets of the weapon, or the weapon in hand.
-- A combat-weapon node (AND) per weapon (src/logic/builders/combat-counters.lua) needs its turret, gun or vehicle and its ammo or fluid.
-- An entity-kill node (src/logic/builders/concrete.lua) needs its entity's combat-target, and a space-connection-asteroids node those of every asteroid on the route and what it splits into.
-- A combat-encounter node (AND, a mechanic) per planet, spawner and evolution step for attack groups, and per territory unit, needs the planet and the combat-target of every unit there.
-- With extra_params.time_limit = false (the final check, src/pipeline/data-final-fixes.lua) there's no time limit, since number randomization after unified's check can slow kills down: only a kill that became impossible is lost then, and slow ones are logged (user, 2026-10-12).

local encounters = require("src/prototypes/combat/combat-encounters")
local targets = require("src/prototypes/combat/combat-targets")
local counters = require("src/logic/builders/combat-counters")
local acquisition = require("src/logic/builders/acquisition")
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

local function sorted_keys(values)
    local keys = {}
    for name, _ in pairs(values) do
        table.insert(keys, name)
    end
    table.sort(keys)
    return keys
end

-- Returns the attack groups and territories it checked, and the weapons' and targets' diagnostics
combat.build = function(graph, lu, extra_params)
    extra_params = extra_params or {}
    local policy = encounters.policy({
        difficulty = extra_params.difficulty or (config and config.military_difficulty),
        time_multiplier = extra_params.time_multiplier or (config and config.military_time_multiplier),
    })
    local time_limit = extra_params.time_limit ~= false
    local entities = lu.entities or {}

    local weapons, weapon_diagnostics, target_options = counters.weapons(lu, {
        entity_of = function(name) return dutils.get_prot("entity", name) end,
        chain_of = function(name) return dutils.prots("chain-active-trigger")[name] end,
        particle_of = function(name) return dutils.prots("optimized-particle")[name] end,
        impact_effects = dutils.prots("deliver-impact-combination"),
        tile_effects = dutils.prots("tile"),
        decorative_effects = dutils.prots("optimized-decorative"),
        segment_line_geometry = "head-on",
    })
    -- A weapon whose turret, gun or ammo isn't in the graph can't be had
    local usable = {}
    for _, weapon in pairs(weapons) do
        local present = true
        for _, prerequisite in pairs(weapon.prerequisites) do
            present = present and graph[prerequisite] ~= nil
        end
        if present then
            table.insert(usable, weapon)
        end
    end

    -- The targets: what entity-kill nodes kill, what spawn and spoil slots put in the world (entity randomization carries buildings on them), attack groups' and territories' units, and route asteroids with what they split into
    local wanted = {}
    local routes = {}
    for _, object in pairs(graph) do
        if type(object) == "table" and object.object_type == "node" then
            if object.type == "entity-kill" and object.spoof ~= true then
                wanted[object.name] = true
            elseif object.type == "space-connection-asteroids" then
                routes[object.name] = true
            end
        elseif type(object) == "table" and object.object_type == "edge" and (object.acq_kind == "spawn" or object.acq_kind == "spoil") then
            local stop = graph[object.stop]
            if stop ~= nil and stop.type == "entity" then
                wanted[stop.name] = true
            end
        end
    end
    local definitions = {}
    if policy.check_enemies == true then
        definitions = encounters.collect(lu, {
            in_room = lutils.check_in_room,
            planet_of = function(name) return dutils.prots("planet")[name] end,
        })
        for _, definition in pairs(definitions) do
            for _, unit in pairs(definition.targets) do
                wanted[unit] = true
            end
        end
    end
    for _, entity in pairs(entities) do
        for _, definition in pairs(entity.result_units or {}) do
            local unit = acquisition.read_spawn_definition(definition)
            if unit ~= nil then
                wanted[unit] = true
            end
        end
    end
    local resolver = targets.new(entities, target_options)
    local locations = dutils.get_all_prots("space-location")
    local connections = dutils.prots("space-connection")
    for _, route in pairs(sorted_keys(routes)) do
        local asteroids = encounters.route_asteroids(connections[route] or {}, locations)
        for _, name in pairs(sorted_keys(asteroids)) do
            if entities[name] ~= nil then
                local spawned, reason = resolver.spawned(name)
                if spawned == nil then
                    log("Combat check: what " .. name .. " leaves when it dies is unknown (" .. tostring(reason) .. "), so " .. route .. " only needs it killed")
                end
                for child, _ in pairs(spawned or {}) do
                    asteroids[child] = true
                end
            end
        end
        routes[route] = asteroids
        for name, _ in pairs(asteroids) do
            wanted[name] = true
        end
    end

    -- A segment shares its unit's health, so killing one is killing a unit it's part of (whichever is easiest), not something weapons are scored on
    -- https://lua-api.factorio.com/latest/types/SegmentEngineSpecification.html
    local owners = {}
    for unit_name, entity in pairs(entities) do
        if entity.segment_engine ~= nil then
            for _, specification in pairs(entity.segment_engine.segments or {}) do
                if specification.segment ~= nil and specification.segment ~= unit_name then
                    owners[specification.segment] = owners[specification.segment] or {}
                    owners[specification.segment][unit_name] = true
                end
            end
        end
    end
    for _, name in pairs(sorted_keys(wanted)) do
        for owner, _ in pairs(owners[name] or {}) do
            wanted[owner] = true
        end
    end
    local names = {}
    local scored = {}
    for _, name in pairs(sorted_keys(wanted)) do
        if entities[name] ~= nil then
            table.insert(names, name)
            if owners[name] == nil then
                table.insert(scored, name)
            end
        end
    end
    local times, target_reasons = counters.kill_times(usable, scored, entities, {
        target_options = target_options,
        turret_count = policy.turret_count,
        manual_count = policy.manual_count,
        outnumber = not time_limit,
    })

    set_class("combat")
    set_prot(nil)
    local used = {}
    for _, name in pairs(names) do
        -- Pointing at the entity lets the panel show its name
        set_prot(entities[name])
        ----------------------------------------
        -- These alternatives are checked, never shuffled; keep their OR edges without matching connectors.
        add_node("combat-target", "OR", nil, name, { fixed_inputs = true })
        ----------------------------------------
        -- Can some weapon kill this on its own, ten turrets of it or one in hand, within the time limit?
        -- In the final check, more turrets of a weapon count too, so only a target nothing damages is lost
        -- A segment is killed with a unit it's part of
        for owner, _ in pairs(owners[name] or {}) do
            add_edge("combat-target", owner)
        end
        local best
        for _, time in pairs(times[name] or {}) do
            local weapon = usable[time.weapon]
            -- The fastest, or among weapons that need more than ten turrets, the hardest hitting
            if best == nil or time.seconds < best.seconds or (time.outnumbered == true and best.outnumbered == true and time.shot_damage > best.shot_damage) then
                best = time
            end
            if not time_limit or time.seconds <= policy.clear_seconds then
                used[time.weapon] = true
                -- A weapon in hand only kills while someone holds it
                add_edge("combat-weapon", weapon.name, weapon.mode == "manual" and {
                    abilities = ctx.LOSES_AUTOMATABILITY,
                } or nil)
            end
        end
        if target_reasons[name] ~= nil then
            log("Combat check: " .. name .. " can't be scored (" .. target_reasons[name] .. "), so nothing kills it")
        elseif not time_limit and best ~= nil and best.outnumbered == true then
            log("Combat check: ten turrets of no weapon outpace " .. name .. "'s regeneration anymore; more of them would (" .. usable[best.weapon].name .. ")")
        elseif not time_limit and best ~= nil and best.seconds > policy.clear_seconds then
            log("Combat check: the fastest weapon kills " .. name .. " in " .. string.format("%.1f", best.seconds) .. " s (" .. usable[best.weapon].name .. "), over the " .. policy.clear_seconds .. " s limit")
        end
    end
    set_prot(nil)
    for index, weapon in pairs(usable) do
        if used[index] == true then
            ----------------------------------------
            add_node("combat-weapon", "AND", nil, weapon.name)
            ----------------------------------------
            -- The turret, gun or vehicle, and what it fires
            for _, prerequisite in pairs(weapon.prerequisites) do
                local node = graph[prerequisite]
                add_edge(node.type, node.name)
            end
        end
    end

    -- Every asteroid on a route and what it splits into has to be killed from the platform
    for route, asteroids in pairs(routes) do
        for _, name in pairs(sorted_keys(asteroids)) do
            if graph[key("combat-target", name)] ~= nil then
                add_edge("combat-target", name, nil, "space-connection-asteroids", route)
            end
        end
    end

    set_class("combat-encounter")
    for _, definition in pairs(definitions) do
        local anchor = graph[definition.anchor]
        if anchor ~= nil then
            ----------------------------------------
            add_node("combat-encounter", "AND", nil, definition.name, {
                mechanic = true,
                important = true,
                encounter = definition,
            })
            ----------------------------------------
            -- Can every unit this planet's attack group (or territory) has be killed by some weapon on its own there?
            -- A unit the logic has no entity for can't be checked, which is logged rather than left as an edge from nothing
            add_edge(anchor.type, anchor.name)
            for _, unit in pairs(definition.targets) do
                if graph[key("combat-target", unit)] ~= nil then
                    add_edge("combat-target", unit)
                else
                    log("Combat check: " .. definition.name .. " has " .. unit .. ", which the logic has no entity for")
                end
            end
        end
    end
    return definitions, {
        weapons = weapon_diagnostics,
        targets = target_reasons,
    }
end

return combat
