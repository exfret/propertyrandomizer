-- Discovery follows the star map (with the connection graph, randomizations/planetary/connections.lua): a planet's discovery technologies take the science packs of the planets before it on the map
-- The planets before a planet are its neighbors on the connection graph one hop closer to the starting planet that don't orbit farther from the sun (user, 2026-09-30: of Glebis's neighbors one hop closer, it takes Vullis's and Naucanra's packs but not those of an Aquilo on the outermost orbit)
-- What a planet gives the planets after it: its own science packs (the lab inputs whose recipes only it accepts) that some discovery technology takes already, a copy's pack counting as its original (like the starting planet's production and utility packs, which Aquilo's discovery takes, but not its military ones, which no discovery takes); a planet none of whose packs a discovery takes gives all of them
-- The starting planet gives nothing: every discovery takes what it needs from there already
-- A discovery technology keeps its other packs, loses those that are another planet's own, and takes those the planets before its planet give; it keeps the prerequisites that need no planet but the ones before it (all the way back to the start), and gains the discoveries of the planets just before it and the technologies unlocking the packs it now takes, where there's one of each (both are needed anyway, so they add no requirement)
-- Space locations that aren't planets (the solar system edge, the shattered planet) keep their discovery, and so does a technology discovering several planets
-- Those past every planet are the end of the game, not stops on the way (user, 2026-09-30), so hops are never counted through them
-- A planet copy's packs need copies of its original's discovery chain for this (lib/dupe-planets.lua), or taking a planet's copy's packs would wait on the planet's own discovery

local constants = require("helper-tables/constants")
local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local dupe = require("lib/dupe")
local surface_sets = require("lib/surface-sets")

local discovery = {}

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

-- Adds the value to the list unless it's there already
local function add_new(list, seen, value)
    if seen[value] == nil then
        seen[value] = true
        table.insert(list, value)
    end
end

-- Number of hops from the start to each location over the edges (a list of {from, to}), never through the locations in ends (a set); locations the start can't reach have none
local function hops(start, edges, ends)
    local neighbors = {}
    for _, edge in pairs(edges) do
        neighbors[edge.from] = neighbors[edge.from] or {}
        neighbors[edge.to] = neighbors[edge.to] or {}
        table.insert(neighbors[edge.from], edge.to)
        table.insert(neighbors[edge.to], edge.from)
    end
    local depth = {
        [start] = 0,
    }
    local queue = {
        start,
    }
    local index = 1
    while index <= #queue do
        local location = queue[index]
        index = index + 1
        for _, other in pairs(ends[location] == nil and neighbors[location] or {}) do
            if depth[other] == nil then
                depth[other] = depth[location] + 1
                table.insert(queue, other)
            end
        end
    end
    return depth, neighbors
end

-- The plan, from what it needs to know about the game (discovery.execute reads it from data.raw):
--   start: the starting planet's name
--   orbit: location name --> its distance from the sun
--   edges: the space connections, as a list of { from, to }
--   is_planet: set of planet names (the other locations can be on the way, but have no packs and keep their discovery)
--   own_packs: planet name --> sorted list of its own packs (every planet but the start)
--   original_of: pack name --> the pack it's a copy of, for copies
--   technologies: technology name --> { ingredients = list of pack names, prerequisites = list of names, discovers = list of location names }
--   unlocking: pack name --> sorted list of the technologies unlocking a recipe that makes it
-- Returns technology name --> { planet, before = sorted list of planets, ingredients = list of pack names (kept ones first, in their order), added = list of the packs it now takes, prerequisites = list of names, dropped = list of the prerequisites it lost }, for each discovery technology of a planet it changes
discovery.plan = function(info)
    -- The end of the game: locations that aren't planets, farther from the sun than every planet
    local farthest_planet = nil
    for planet, _ in pairs(info.is_planet) do
        if farthest_planet == nil or (info.orbit[planet] or 0) > farthest_planet then
            farthest_planet = info.orbit[planet] or 0
        end
    end
    local ends = {}
    for location, orbit in pairs(info.orbit) do
        if info.is_planet[location] == nil and farthest_planet ~= nil and orbit > farthest_planet then
            ends[location] = true
        end
    end
    local depth, neighbors = hops(info.start, info.edges, ends)

    -- Planet --> the technologies discovering it (sorted), and the packs any discovery technology takes (as their originals too)
    local discoverers = {}
    local taken_by_discovery = {}
    for _, tech_name in pairs(sorted_keys(info.technologies)) do
        local tech = info.technologies[tech_name]
        for _, location in pairs(tech.discovers or {}) do
            discoverers[location] = discoverers[location] or {}
            table.insert(discoverers[location], tech_name)
        end
        if #(tech.discovers or {}) > 0 then
            for _, pack in pairs(tech.ingredients or {}) do
                taken_by_discovery[pack] = true
            end
        end
    end

    -- Pack --> the planet whose own pack it is
    local owner = {}
    for planet, packs in pairs(info.own_packs) do
        for _, pack in pairs(packs) do
            owner[pack] = planet
        end
    end

    -- The planets before each planet, and what each planet gives the planets after it
    local function before(planet)
        local list = {}
        if depth[planet] == nil then
            return list
        end
        for _, other in pairs(neighbors[planet] or {}) do
            if info.is_planet[other] ~= nil and depth[other] < depth[planet] and (info.orbit[other] or 0) <= (info.orbit[planet] or 0) then
                table.insert(list, other)
            end
        end
        table.sort(list)
        return list
    end
    local function gives(planet)
        if planet == info.start then
            return {}
        end
        local own = info.own_packs[planet] or {}
        local given = {}
        for _, pack in pairs(own) do
            if taken_by_discovery[pack] ~= nil or (info.original_of[pack] ~= nil and taken_by_discovery[info.original_of[pack]] ~= nil) then
                table.insert(given, pack)
            end
        end
        if #given == 0 then
            return own
        end
        return given
    end

    -- Planet --> the planets its discovery may need: the start and the planets before it, all the way back
    local allowed_memo = {}
    local function allowed(planet)
        if allowed_memo[planet] == nil then
            local rooms = {
                [info.start] = true,
            }
            for _, other in pairs(before(planet)) do
                rooms[other] = true
                for further, _ in pairs(allowed(other)) do
                    rooms[further] = true
                end
            end
            allowed_memo[planet] = rooms
        end
        return allowed_memo[planet]
    end

    -- Technology --> the planets it needs: those whose own packs its research or its prerequisites' research takes, and those it or its prerequisites discover (all the way down)
    local needs_memo = {}
    local function planets_needed(tech_name)
        if needs_memo[tech_name] == nil then
            local planets = {}
            -- Stored first, so a prerequisite cycle ends here
            needs_memo[tech_name] = planets
            local tech = info.technologies[tech_name]
            if tech ~= nil then
                for _, pack in pairs(tech.ingredients or {}) do
                    if owner[pack] ~= nil then
                        planets[owner[pack]] = true
                    end
                end
                for _, location in pairs(tech.discovers or {}) do
                    if info.is_planet[location] ~= nil then
                        planets[location] = true
                    end
                end
                for _, prerequisite in pairs(tech.prerequisites or {}) do
                    for planet, _ in pairs(planets_needed(prerequisite)) do
                        planets[planet] = true
                    end
                end
            end
        end
        return needs_memo[tech_name]
    end

    local plan = {}
    for _, tech_name in pairs(sorted_keys(info.technologies)) do
        local tech = info.technologies[tech_name]
        local discovered = {}
        for _, location in pairs(tech.discovers or {}) do
            if info.is_planet[location] ~= nil and location ~= info.start then
                table.insert(discovered, location)
            end
        end
        if #discovered == 1 and depth[discovered[1]] ~= nil then
            local planet = discovered[1]
            local planets_before = before(planet)
            local ingredients = {}
            local seen = {}
            for _, pack in pairs(tech.ingredients or {}) do
                if owner[pack] == nil then
                    add_new(ingredients, seen, pack)
                end
            end
            local added = {}
            for _, other in pairs(planets_before) do
                for _, pack in pairs(gives(other)) do
                    if seen[pack] == nil then
                        table.insert(added, pack)
                    end
                    add_new(ingredients, seen, pack)
                end
            end
            local may_need = allowed(planet)
            local prerequisites = {}
            local dropped = {}
            local seen_prerequisites = {}
            for _, prerequisite in pairs(tech.prerequisites or {}) do
                local fits = true
                for needed, _ in pairs(planets_needed(prerequisite)) do
                    if may_need[needed] == nil then
                        fits = false
                    end
                end
                if fits then
                    add_new(prerequisites, seen_prerequisites, prerequisite)
                else
                    table.insert(dropped, prerequisite)
                end
            end
            for _, other in pairs(planets_before) do
                if discoverers[other] ~= nil and #discoverers[other] == 1 then
                    add_new(prerequisites, seen_prerequisites, discoverers[other][1])
                end
            end
            for _, pack in pairs(added) do
                if info.unlocking[pack] ~= nil and #info.unlocking[pack] == 1 and info.unlocking[pack][1] ~= tech_name then
                    add_new(prerequisites, seen_prerequisites, info.unlocking[pack][1])
                end
            end
            plan[tech_name] = {
                planet = planet,
                before = planets_before,
                ingredients = ingredients,
                added = added,
                prerequisites = prerequisites,
                dropped = dropped,
            }
        end
    end
    return plan
end

-- The game as discovery.plan needs it, from data.raw and the current space connections
local function read_game()
    local info = {
        start = constants.starting_planet,
        orbit = {},
        edges = {},
        is_planet = {},
        own_packs = {},
        original_of = {},
        technologies = {},
        unlocking = {},
    }
    for name, location in pairs(dutils.get_all_prots("space-location")) do
        info.orbit[name] = location.distance or 0
    end
    for name, planet in pairs(data.raw.planet or {}) do
        if planet.hidden ~= true then
            info.is_planet[name] = true
        end
    end
    for _, name in pairs(sorted_keys(data.raw["space-connection"] or {})) do
        local connection = data.raw["space-connection"][name]
        table.insert(info.edges, {
            from = connection.from,
            to = connection.to,
        })
    end

    -- A planet's own packs: the lab inputs whose recipes only it accepts, among every planet and surface
    local room_keys = {}
    for _, name in pairs(sorted_keys(data.raw.planet or {})) do
        table.insert(room_keys, gutils.key("planet", name))
    end
    for _, name in pairs(sorted_keys(data.raw.surface or {})) do
        table.insert(room_keys, gutils.key("surface", name))
    end
    local recipes_of = {}
    for _, pack_name in pairs(sorted_keys(dutils.lab_inputs())) do
        local pack = dupe.find_prototype("item", pack_name)
        if pack ~= nil then
            if pack.orig_name ~= nil then
                info.original_of[pack_name] = pack.orig_name
            end
            local recipes = dupe.item_recipes(pack)
            recipes_of[pack_name] = recipes
            local only = nil
            for _, recipe in pairs(recipes) do
                local accepted = sorted_keys(surface_sets.accepting(recipe.surface_conditions or {}, room_keys, surface_sets.value))
                local room = #accepted == 1 and gutils.deconstruct(accepted[1]) or nil
                if room == nil or room.type ~= "planet" or (only ~= nil and only ~= room.name) then
                    only = false
                elseif only == nil then
                    only = room.name
                end
            end
            if type(only) == "string" and only ~= info.start then
                info.own_packs[only] = info.own_packs[only] or {}
                table.insert(info.own_packs[only], pack_name)
            end
        end
    end

    local unlocked_by = {}
    for _, tech_name in pairs(sorted_keys(data.raw.technology or {})) do
        local tech = data.raw.technology[tech_name]
        local entry = {
            ingredients = {},
            prerequisites = tech.prerequisites or {},
            discovers = {},
        }
        for _, ingredient in pairs((tech.unit or {}).ingredients or {}) do
            table.insert(entry.ingredients, ingredient[1])
        end
        for _, effect in pairs(tech.effects or {}) do
            if effect.type == "unlock-space-location" then
                table.insert(entry.discovers, effect.space_location)
            elseif effect.type == "unlock-recipe" then
                unlocked_by[effect.recipe] = unlocked_by[effect.recipe] or {}
                unlocked_by[effect.recipe][tech_name] = true
            end
        end
        info.technologies[tech_name] = entry
    end
    for pack_name, recipes in pairs(recipes_of) do
        local techs = {}
        for _, recipe in pairs(recipes) do
            for tech_name, _ in pairs(unlocked_by[recipe.name] or {}) do
                techs[tech_name] = true
            end
        end
        info.unlocking[pack_name] = sorted_keys(techs)
    end
    return info
end

-- Why discovery can't follow the star map now, or nil if it can
discovery.problem = function()
    if next(data.raw["space-connection"] or {}) == nil then
        return "there are no space connections"
    end
    if (data.raw.planet or {})[constants.starting_planet] == nil then
        return "there's no starting planet"
    end
    return nil
end

-- Changes the discovery technologies; returns a line for the log
discovery.execute = function()
    local info = read_game()
    local plan = discovery.plan(info)
    local lines = {}
    for _, tech_name in pairs(sorted_keys(plan)) do
        local change = plan[tech_name]
        local tech = data.raw.technology[tech_name]
        local amounts = {}
        for _, ingredient in pairs((tech.unit or {}).ingredients or {}) do
            amounts[ingredient[1]] = ingredient[2]
        end
        if tech.unit ~= nil then
            local ingredients = {}
            for _, pack in pairs(change.ingredients) do
                table.insert(ingredients, {
                    pack,
                    amounts[pack] or 1,
                })
            end
            tech.unit.ingredients = ingredients
        end
        tech.prerequisites = change.prerequisites
        table.insert(lines, change.planet .. " <-- " .. (#change.before > 0 and table.concat(change.before, ", ") or "nothing") .. " (" .. tech_name .. (#change.added > 0 and (" takes " .. table.concat(change.added, ", ")) or "") .. (#change.dropped > 0 and ("; left out " .. table.concat(change.dropped, ", ")) or "") .. ")")
    end
    return #sorted_keys(plan) .. " discovery technologies follow the map: " .. table.concat(lines, "; ")
end

return discovery
