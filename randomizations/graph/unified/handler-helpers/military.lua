-- The military rebalance in the game (config.military_rebalance; lib/military.lua has the rules), run once entity randomization has filled spawners' spawn slots (see entity.reflect)
-- A spawner holding units from other spawners keeps their numbers down, and a unit spawned away from its home planet takes that planet's strength and a cost to join attacks in the pollutant its new spawner absorbs
-- A unit's home spawners are the ones spawning it when unified randomization started, and a spawner's planets are where logic finds it autoplaced (lutils.check_in_room)

local acquisition = require("lib/logic/acquisition")
local dutils = require("lib/data-utils")
local lutils = require("lib/logic/logic-utils")
local military = require("lib/military")

local rebalance = {}

-- A table's keys in order, so logs and floating point sums come out the same on every load
local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

-- An entity as it was when unified randomization started
local function starting_entity(name)
    for class, _ in pairs(defines.prototypes.entity) do
        local prototypes = unified_starting_data_raw[class]
        if prototypes ~= nil and prototypes[name] ~= nil then
            return prototypes[name]
        end
    end
    return nil
end

-- A spawner's spawns as lib/military.lua's entries
local function entries_of(spawner)
    local entries = {}
    for _, definition in pairs(spawner.result_units) do
        local unit, points = acquisition.read_spawn_definition(definition)
        table.insert(entries, {
            unit = unit,
            points = points,
        })
    end
    return entries
end

local function index_of(entries, unit_name)
    for index, entry in pairs(entries) do
        if entry.unit == unit_name then
            return index
        end
    end
    return nil
end

-- The planets a spawner is autoplaced on (a set of names)
local function planets_of(spawner)
    local planets = {}
    for _, room in pairs(lookups.rooms) do
        if room.type == "planet" and lutils.check_in_room(room, spawner) then
            planets[room.name] = true
        end
    end
    return planets
end

-- Scales every damage effect in a table of trigger effects (like a spider leg's stomp), each table once
-- A unit's attack_parameters.damage_modifier doesn't reach its legs' stomps (a probe on vanilla data: a stomper's acid stream scaled with it and its stomp didn't), so they're scaled here
local function scale_damage_effects(tbl, factor, seen)
    if type(tbl) ~= "table" or seen[tbl] ~= nil then
        return
    end
    seen[tbl] = true
    if tbl.type == "damage" and type(tbl.damage) == "table" and tbl.damage.amount ~= nil then
        tbl.damage.amount = tbl.damage.amount * factor
    end
    for _, value in pairs(tbl) do
        scale_damage_effects(value, factor, seen)
    end
end

-- Puts a line above a prototype's description
local function add_description_line(prototype, line)
    if prototype.localised_description ~= nil then
        prototype.localised_description = {"", line, "\n", prototype.localised_description}
    else
        prototype.localised_description = {"", line, {"?", {"", "\n", {"entity-description." .. prototype.name}}, ""}}
    end
end

-- Health and regeneration times factor
local function scale_health(unit, factor)
    unit.max_health = military.round_health((unit.max_health or 10) * factor)
    if unit.healing_per_tick ~= nil then
        unit.healing_per_tick = unit.healing_per_tick * factor
    end
end

-- Damage times factor
-- The attack's damage_modifier scales everything its attack does, projectiles and streams included (the same probe: biter and wriggler bites, strafer projectiles and stomper acid all hit 10 times as hard at 10 times the modifier)
local function scale_damage(unit, factor)
    unit.attack_parameters.damage_modifier = (unit.attack_parameters.damage_modifier or 1) * factor
    if unit.spider_engine ~= nil then
        local legs = unit.spider_engine.legs
        if legs[1] == nil then
            legs = {
                legs,
            }
        end
        local seen = {}
        for _, leg in pairs(legs) do
            scale_damage_effects(leg.leg_hit_the_ground_trigger, factor, seen)
            scale_damage_effects(leg.leg_hit_the_ground_when_attacking_trigger, factor, seen)
        end
    end
end

rebalance.apply = function()
    local start = lutils.starting_planet_name
    local starting_spawners = unified_starting_data_raw["unit-spawner"] or {}
    local spawners = data.raw["unit-spawner"] or {}

    -- Spawner --> its spawns when unified randomization started (home_entries) and now, the planets it's on, and the pollutants it absorbs, in order
    local home_entries = {}
    local now_entries = {}
    local planets = {}
    local pollutants = {}
    for _, name in pairs(sorted_keys(starting_spawners)) do
        home_entries[name] = entries_of(starting_spawners[name])
        planets[name] = planets_of(starting_spawners[name])
        pollutants[name] = sorted_keys(starting_spawners[name].absorptions_per_second or {})
    end
    for _, name in pairs(sorted_keys(spawners)) do
        now_entries[name] = entries_of(spawners[name])
        planets[name] = planets[name] or planets_of(spawners[name])
        pollutants[name] = pollutants[name] or sorted_keys(spawners[name].absorptions_per_second or {})
    end

    -- Unit --> set of its home spawners, and the limits of each
    local homes = {}
    local home_limits = {}
    for _, name in pairs(sorted_keys(home_entries)) do
        local limits = military.spawner_limits(starting_spawners[name])
        for _, entry in pairs(home_entries[name]) do
            homes[entry.unit] = homes[entry.unit] or {}
            homes[entry.unit][name] = true
            home_limits[entry.unit] = home_limits[entry.unit] or {}
            table.insert(home_limits[entry.unit], limits)
        end
    end

    -- A spawner holding units from other spawners keeps, on average, no more of them than their home spawners would (military.limits_with_foreign_units)
    -- Limits don't change with evolution, so the spawner's own units are held to that too
    for _, name in pairs(sorted_keys(now_entries)) do
        local entries = {}
        local foreign_names = {}
        for _, entry in pairs(now_entries[name]) do
            local unit = dutils.get_prot("entity", entry.unit)
            local limit_entry = {
                points = entry.points,
                defensive = unit ~= nil and military.is_defensive(unit),
            }
            if homes[entry.unit] ~= nil and homes[entry.unit][name] == nil then
                limit_entry.home = military.loosest_limits(home_limits[entry.unit])
                table.insert(foreign_names, entry.unit)
            end
            table.insert(entries, limit_entry)
        end
        if #foreign_names > 0 then
            local old_limits = military.spawner_limits(spawners[name])
            local new_limits = military.limits_with_foreign_units(old_limits, entries)
            local changes = {}
            for _, limit in pairs({
                "owned",
                "owned_defensive",
                "friends",
                "friends_defensive",
            }) do
                if new_limits[limit] ~= old_limits[limit] then
                    table.insert(changes, limit .. " " .. old_limits[limit] .. " -> " .. new_limits[limit])
                end
            end
            if #changes > 0 then
                military.set_spawner_limits(spawners[name], new_limits)
                table.sort(foreign_names)
                log("Military rebalance: " .. name .. " holds fewer units (" .. table.concat(changes, ", ") .. "), since it spawns " .. table.concat(foreign_names, ", ") .. " from other spawners")
            end
        end
    end

    -- Planet --> its spawners' spawns when unified randomization started, and those of its spawners absorbing each pollutant, for the planet's usual health and costs
    local spawners_on = {}
    local absorbing_on = {}
    for _, name in pairs(sorted_keys(home_entries)) do
        for _, planet in pairs(sorted_keys(planets[name])) do
            spawners_on[planet] = spawners_on[planet] or {}
            table.insert(spawners_on[planet], home_entries[name])
            absorbing_on[planet] = absorbing_on[planet] or {}
            for _, pollutant in pairs(pollutants[name]) do
                absorbing_on[planet][pollutant] = absorbing_on[planet][pollutant] or {}
                table.insert(absorbing_on[planet][pollutant], home_entries[name])
            end
        end
    end
    -- What units' attacks deliver to (projectiles, streams and beams), when unified randomization started
    local function delivered_prototype(prototype_type, name)
        return (unified_starting_data_raw[prototype_type] or {})[name]
    end
    local function health_of(unit_name)
        local unit = starting_entity(unit_name)
        return unit ~= nil and (unit.max_health or 10) or nil
    end
    local function damage_of(unit_name)
        local unit = starting_entity(unit_name)
        return unit ~= nil and military.damage_per_second(unit, delivered_prototype) or nil
    end
    local function cost_of(pollutant)
        return function(unit_name)
            local unit = starting_entity(unit_name)
            if unit == nil or military.is_defensive(unit) or unit.absorptions_to_join_attack == nil then
                return nil
            end
            return unit.absorptions_to_join_attack[pollutant]
        end
    end
    -- Mean over a set of planets of a measure (value_of) of their enemies, at an evolution: health and damage over all their spawners, and a cost to join attacks in a pollutant over the spawners absorbing it
    local function usual_over(planet_set, evolution, value_of, pollutant)
        local sum = 0
        local count = 0
        for _, planet in pairs(sorted_keys(planet_set)) do
            local spawners_here = spawners_on[planet] or {}
            if pollutant ~= nil then
                spawners_here = (absorbing_on[planet] or {})[pollutant] or {}
            end
            local mean = military.mean_at(spawners_here, value_of, evolution)
            if mean ~= nil then
                sum = sum + mean
                count = count + 1
            end
        end
        if count == 0 then
            return nil
        end
        return sum / count
    end

    -- Unit --> the spawners spawning it now, in order
    local spawned_by = {}
    for _, name in pairs(sorted_keys(now_entries)) do
        for _, entry in pairs(now_entries[name]) do
            spawned_by[entry.unit] = spawned_by[entry.unit] or {}
            table.insert(spawned_by[entry.unit], name)
        end
    end

    -- Units spawned away from their home planet take the strength of the enemies where they spawn most now, measured against home (military.strength_factor)
    for _, unit_name in pairs(sorted_keys(spawned_by)) do
        local home_set = homes[unit_name]
        local unit = dutils.get_prot("entity", unit_name)
        local start_unit = starting_entity(unit_name)
        if home_set ~= nil and unit ~= nil and start_unit ~= nil and unit.attack_parameters ~= nil then
            -- Where it spawned most at home
            local home_spawner
            local home_evolution
            local home_share = 0
            local home_on_start = false
            for _, name in pairs(sorted_keys(home_set)) do
                local evolution, share = military.peak_of(home_entries[name], index_of(home_entries[name], unit_name))
                if evolution ~= nil and share > home_share then
                    home_spawner = name
                    home_evolution = evolution
                    home_share = share
                end
                if planets[name][start] ~= nil then
                    home_on_start = true
                end
            end
            -- Where it spawns most in each foreign spawner now
            local now_on_start = false
            local slots = {}
            for _, name in pairs(spawned_by[unit_name]) do
                if planets[name][start] ~= nil then
                    now_on_start = true
                end
                if home_set[name] == nil then
                    local evolution = military.peak_of(now_entries[name], index_of(now_entries[name], unit_name))
                    if evolution ~= nil then
                        table.insert(slots, {
                            spawner = name,
                            evolution = evolution,
                            health_level = usual_over(planets[name], evolution, health_of),
                            damage_level = usual_over(planets[name], evolution, damage_of),
                            on_start = planets[name][start] == true,
                        })
                    end
                end
            end
            if home_spawner ~= nil and #slots > 0 then
                -- Health and damage scale apart, each against the same measure of the enemies at home and where it spawns now
                local function factor_of(measure, value_of)
                    local measured = {}
                    for _, slot in pairs(slots) do
                        table.insert(measured, {
                            strength = slot[measure],
                            on_start = slot.on_start,
                        })
                    end
                    return military.strength_factor(usual_over(planets[home_spawner], home_evolution, value_of), measured, home_on_start, now_on_start)
                end
                local health_factor = factor_of("health_level", health_of)
                local damage_factor = factor_of("damage_level", damage_of)

                -- A cost to join attacks in each pollutant a foreign spawner absorbs that the unit has no cost in, matched to that planet's usual costs (military.matched_cost), the dearest where several ask
                -- Units that never join attacks need none
                local home_costs = start_unit.absorptions_to_join_attack or {}
                local home_pollutant
                for _, pollutant in pairs(pollutants[home_spawner]) do
                    if home_pollutant == nil and home_costs[pollutant] ~= nil then
                        home_pollutant = pollutant
                    end
                end
                local new_costs = {}
                if not military.is_defensive(unit) then
                    for _, slot in pairs(slots) do
                        for _, pollutant in pairs(pollutants[slot.spawner]) do
                            if home_costs[pollutant] == nil then
                                local new_usual = usual_over(planets[slot.spawner], slot.evolution, cost_of(pollutant), pollutant)
                                local cost
                                if home_pollutant ~= nil then
                                    cost = military.matched_cost(home_costs[home_pollutant], usual_over(planets[home_spawner], home_evolution, cost_of(home_pollutant), home_pollutant), new_usual)
                                    -- Usual costs unknown: its home cost, scaled like its health (vanilla costs follow health more than damage)
                                    cost = cost or home_costs[home_pollutant] * health_factor
                                else
                                    -- No home cost to go by: the usual cost there
                                    cost = new_usual
                                end
                                if cost ~= nil then
                                    new_costs[pollutant] = math.max(new_costs[pollutant] or 0, cost)
                                end
                            end
                        end
                    end
                end

                local slot_names = {}
                for _, slot in pairs(slots) do
                    table.insert(slot_names, slot.spawner .. " (evolution " .. string.format("%.2f", slot.evolution) .. ")")
                end
                if health_factor ~= 1 or damage_factor ~= 1 then
                    local old_health = unit.max_health or 10
                    scale_health(unit, health_factor)
                    scale_damage(unit, damage_factor)
                    local change = "health x" .. string.format("%.3g", health_factor) .. ", damage x" .. string.format("%.3g", damage_factor)
                    add_description_line(unit, "Military rebalance: " .. change .. ", since it spawns away from its home planet.")
                    log("Military rebalance: " .. unit_name .. " " .. change .. " (health " .. old_health .. " -> " .. unit.max_health .. "), spawning in " .. table.concat(slot_names, ", ") .. " away from " .. home_spawner .. " (evolution " .. string.format("%.2f", home_evolution) .. ")")
                end
                if health_factor ~= 1 or next(new_costs) ~= nil then
                    local costs = unit.absorptions_to_join_attack or {}
                    -- Its own costs follow its health, like the new ones follow the new planet's usual costs
                    if health_factor ~= 1 then
                        for _, pollutant in pairs(sorted_keys(costs)) do
                            if costs[pollutant] > 0 then
                                costs[pollutant] = military.round_cost(costs[pollutant] * health_factor)
                            end
                        end
                    end
                    for _, pollutant in pairs(sorted_keys(new_costs)) do
                        costs[pollutant] = military.round_cost(new_costs[pollutant])
                    end
                    unit.absorptions_to_join_attack = costs
                    local cost_names = {}
                    for _, pollutant in pairs(sorted_keys(costs)) do
                        table.insert(cost_names, costs[pollutant] .. " " .. pollutant)
                    end
                    log("Military rebalance: " .. unit_name .. " joins attacks for " .. table.concat(cost_names, ", "))
                end
            end
        end
    end
end

return rebalance
