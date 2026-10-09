-- Discovery follows the star map in tiers (with the connection graph, randomizations/planetary/connections.lua): a planet's tier is how many hops it is from the starting planet, and its discovery technologies take the science packs of every planet in the tier before it
-- Tiers (user, 2026-10-08) replaced each planet taking the packs of its own neighbors one hop closer (2026-09-30): every planet of a tier now needs the same planets, so the logic's home sets (top.home_sets in lib/graph/context-sort.lua) number the tiers rather than the planets, and each home set makes every sort that keeps them slower
-- Planets on the outermost planet orbit (in Space Age, Aquilo and its copies) give packs like any other (user, 2026-10-08): first kept for the end of the game, as in Space Age, where no planet's discovery takes cryogenic science (only the solar system edge's and the shattered planet's do, space-age/prototypes/technology.lua), but an Aquilo the map puts in an early tier may as well count for the planets after it
-- A tier after one with no planet that gives takes the packs of the nearest tier before it with one
-- What a planet gives the planets after it: its own science packs (the lab inputs whose recipes only it accepts) that some discovery technology takes already, a copy's pack counting as its original (like the starting planet's production and utility packs, which Aquilo's discovery takes, but not its military ones, which no discovery takes); a planet none of whose packs a discovery takes gives all of them
-- The starting planet gives nothing: every discovery takes what it needs from there already, so the first tier's discoveries keep their cost
-- A discovery technology keeps its other packs, loses those that are another planet's own, and takes those the planets before its planet give; it keeps the prerequisites that need no planet's discovery but those of earlier tiers, and gains the discoveries of the planets just before it and the technologies unlocking the packs it now takes, where there's one of each (both are needed anyway, so they add no requirement)
-- So that no discovery waits on itself, a tier's discoveries never need a discovery of their own tier or a later one: a planet only gives the packs it can make with the discoveries of its own tier and earlier ones (by induction over the tiers, what those need stays in earlier tiers too)
-- What a pack or technology needs comes from the game's logic graph (top.watched_needed), since technologies' own fields don't show all of it: a planet copy's pack comes from copies of its planet's technologies, which also need the copy of the starting planet with its number discovered (lib/dupe-planets.lua), and a research trigger can need a recipe from another planet's technologies
-- Space locations that aren't planets (the solar system edge, the shattered planet) keep their discovery, and so does a technology discovering several planets
-- Those past every planet are the end of the game, not stops on the way (user, 2026-09-30), so hops are never counted through them
-- A planet copy's packs need copies of its original's discovery chain for this (lib/dupe-planets.lua), or taking a planet's copy's packs would wait on the planet's own discovery

local constants = require("helper-tables/constants")
local localised_text = require("lib/localised-text")
local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
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
    return depth
end

-- What technologies and packs need, from the technologies' own fields, for a plan without the logic graph (like the plain-Lua tests): a technology needs the planets whose own packs its research or its prerequisites' research takes, and those it or its prerequisites discover (all the way down); a pack needs the planet that makes it
-- Returns needs as discovery.plan takes them
discovery.needs_from_fields = function(info)
    local owner = {}
    for planet, packs in pairs(info.own_packs) do
        for _, pack in pairs(packs) do
            owner[pack] = planet
        end
    end
    local technology = {}
    local function planets_needed(tech_name)
        if technology[tech_name] == nil then
            local planets = {}
            -- Stored first, so a prerequisite cycle ends here
            technology[tech_name] = planets
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
        return technology[tech_name]
    end
    for tech_name, _ in pairs(info.technologies) do
        planets_needed(tech_name)
    end
    local pack = {}
    for pack_name, planet in pairs(owner) do
        pack[pack_name] = {
            [planet] = true,
        }
    end
    return {
        technology = technology,
        pack = pack,
    }
end

-- What technologies and packs need, from the game's logic graph: the planets whose discovered nodes (space-location-discover) they can't be reached without (top.watched_needed), which sees research triggers and recipes too, and works however many technologies discover a planet
-- Returns needs as discovery.plan takes them, with false for what the graph doesn't reach
discovery.needs_from_graph = function(graph, info)
    local watched = {}
    local planet_of = {}
    for _, planet in pairs(sorted_keys(info.is_planet)) do
        local node_key = gutils.key("space-location-discover", planet)
        if graph.nodes[node_key] ~= nil then
            table.insert(watched, node_key)
            planet_of[node_key] = planet
        end
    end
    local needed = top.watched_needed(graph, watched)
    local function planets(node_key)
        local keys = needed(node_key)
        if keys == nil then
            return false
        end
        local set = {}
        for watched_key, _ in pairs(keys) do
            set[planet_of[watched_key]] = true
        end
        return set
    end
    local needs = {
        technology = {},
        pack = {},
    }
    local packs = {}
    for _, own in pairs(info.own_packs) do
        for _, pack in pairs(own) do
            packs[pack] = true
        end
    end
    for tech_name, tech in pairs(info.technologies) do
        needs.technology[tech_name] = planets(gutils.key("technology", tech_name))
        for _, pack in pairs(tech.ingredients or {}) do
            packs[pack] = true
        end
    end
    for pack, _ in pairs(packs) do
        needs.pack[pack] = planets(gutils.key("item", pack))
    end
    return needs
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
--   needs (optional): { technology = name --> set of the planets whose discovery it can't be had without, pack = name --> the same }, false for what can't be had at all and nil if unknown; from the logic graph in the game (discovery.needs_from_graph), and from the technologies' own fields if not given (discovery.needs_from_fields)
-- Returns the changes, and the packs planets don't give since they need a discovery of a later tier (planet --> pack --> sorted list of those planets); the changes are technology name --> { planet, tier, before = sorted list of planets, ingredients = list of pack names (kept ones first, in their order), added = list of the packs it now takes, prerequisites = list of names, dropped = list of the prerequisites it lost, dropped_packs = list of the packs it lost that aren't another planet's own }, for each discovery technology of a planet it changes
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
    local depth = hops(info.start, info.edges, ends)

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

    local needs = info.needs or discovery.needs_from_fields(info)
    -- Whether every planet whose discovery planets needs is the start or no more than tier hops from it (planets as in needs: a set, false for what can't be had at all, nil if unknown)
    local function needs_fit(planets, tier)
        if planets == false then
            return false
        end
        for planet, _ in pairs(planets or {}) do
            if planet ~= info.start and (depth[planet] == nil or depth[planet] > tier) then
                return false
            end
        end
        return true
    end

    -- What each planet gives the tiers after it: its own packs that some discovery takes, or all of them if no discovery takes any, of those it can make with discoveries of its own tier and earlier ones
    -- Planet --> pack --> the later planets it needs, for the packs a planet would give if not for those
    local withheld = {}
    local function gives(planet)
        if planet == info.start or depth[planet] == nil then
            return {}
        end
        local own = info.own_packs[planet] or {}
        local taken = {}
        for _, pack in pairs(own) do
            if taken_by_discovery[pack] ~= nil or (info.original_of[pack] ~= nil and taken_by_discovery[info.original_of[pack]] ~= nil) then
                table.insert(taken, pack)
            end
        end
        if #taken == 0 then
            taken = own
        end
        local given = {}
        for _, pack in pairs(taken) do
            if needs_fit(needs.pack[pack], depth[planet]) then
                table.insert(given, pack)
            else
                -- Logged, since it means a planet's pack needs a later planet (like a planet copy tied to another one by its dupe number, which lib/dupe-planets.lua shouldn't do)
                local later = {}
                for other, _ in pairs(needs.pack[pack] or {}) do
                    if other ~= info.start and (depth[other] == nil or depth[other] > depth[planet]) then
                        table.insert(later, other)
                    end
                end
                table.sort(later)
                withheld[planet] = withheld[planet] or {}
                withheld[planet][pack] = needs.pack[pack] == false and {"(it can't be made at all)"} or later
            end
        end
        return given
    end

    -- Tier --> its planets that give packs (sorted): every planet that many hops from the start with a pack to give
    local givers_of_tier = {}
    for _, planet in pairs(sorted_keys(info.is_planet)) do
        if depth[planet] ~= nil and #gives(planet) > 0 then
            givers_of_tier[depth[planet]] = givers_of_tier[depth[planet]] or {}
            table.insert(givers_of_tier[depth[planet]], planet)
        end
    end

    -- The planets before each planet: those of the nearest tier before its own with a planet that gives, the same for every planet of its tier
    local function before(planet)
        if depth[planet] == nil then
            return {}
        end
        for tier = depth[planet] - 1, 1, -1 do
            if givers_of_tier[tier] ~= nil then
                local list = {}
                for _, other in pairs(givers_of_tier[tier]) do
                    table.insert(list, other)
                end
                return list
            end
        end
        return {}
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
            local dropped_packs = {}
            for _, pack in pairs(tech.ingredients or {}) do
                -- Another planet's own packs go, and so does any other that needs a discovery of this tier or a later one (one that can't be had at all is kept as it is: it adds no new cycle)
                if owner[pack] == nil then
                    if needs.pack[pack] == false or needs_fit(needs.pack[pack], depth[planet] - 1) then
                        add_new(ingredients, seen, pack)
                    else
                        table.insert(dropped_packs, pack)
                    end
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
            local prerequisites = {}
            local dropped = {}
            local seen_prerequisites = {}
            for _, prerequisite in pairs(tech.prerequisites or {}) do
                -- One that can't be had at all is kept as it is: it adds no new cycle
                local prerequisite_needs = needs.technology[prerequisite]
                if prerequisite_needs == false or needs_fit(prerequisite_needs, depth[planet] - 1) then
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
                tier = depth[planet],
                before = planets_before,
                ingredients = ingredients,
                added = added,
                prerequisites = prerequisites,
                dropped = dropped,
                dropped_packs = dropped_packs,
            }
        end
    end
    return plan, withheld
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
        return localised_text.reason("no-connections", "there are no space connections")
    end
    if (data.raw.planet or {})[constants.starting_planet] == nil then
        return localised_text.reason("no-start", "there's no starting planet")
    end
    return nil
end

-- Changes the discovery technologies; graph is the logic graph of the game as it is, for what packs and technologies need (discovery.needs_from_graph), or nil to read that from the technologies' own fields; returns a line for the log
discovery.execute = function(graph)
    local info = read_game()
    if graph ~= nil then
        info.needs = discovery.needs_from_graph(graph, info)
    end
    local plan, withheld = discovery.plan(info)
    for _, planet in pairs(sorted_keys(withheld)) do
        for _, pack in pairs(sorted_keys(withheld[planet])) do
            log("Planetary discovery: " .. planet .. " doesn't give " .. pack .. ", which needs the discovery of " .. table.concat(withheld[planet][pack], ", ") .. ", in a later tier")
        end
    end
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
        table.insert(lines, "tier " .. change.tier .. ": " .. change.planet .. " <-- " .. (#change.before > 0 and table.concat(change.before, ", ") or "nothing") .. " (" .. tech_name .. (#change.added > 0 and (" takes " .. table.concat(change.added, ", ")) or "") .. (#change.dropped > 0 and ("; left out " .. table.concat(change.dropped, ", ")) or "") .. (#change.dropped_packs > 0 and ("; left out packs " .. table.concat(change.dropped_packs, ", ")) or "") .. ")")
    end
    local tiers = {}
    for _, change in pairs(plan) do
        tiers[change.tier] = true
    end
    return #sorted_keys(plan) .. " discovery technologies follow the map in " .. #sorted_keys(tiers) .. " tiers: " .. table.concat(lines, "; ")
end

return discovery
