-- Planetary freezing moves (setting propertyrandomizer-planetary-freezing)
-- Freezing (a planet's entities_require_heating) trades places among the planets other than the starting planet, so a planet whose buildings freeze gives that to one where they don't
-- It moves as a group with what heats buildings there: a technology unlocking a heat source (a reactor, like the heating tower) that belongs to another planet (a prerequisite that discovers it, or a trigger mining something there) is researched on the new frozen planet instead
-- That way the new frozen planet can heat its buildings from its own discovery on (warmth, see lib/logic/abstract.lua).
-- Warmth isn't a planetary feature: every room must stay warm, so the new frozen planet must be able to heat its buildings, and the old one is warm without heating
-- A planet that stops freezing only gains warmth, so what a move can break is on the new frozen planet; if it breaks something, the move is undone

local constants = require("helper-tables/constants")
local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local rng = require("lib/random/rng")

local freezing = {}

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

-- Names of the planets other than the starting planet, sorted
local function movable_planets()
    local names = {}
    for name, _ in pairs(data.raw.planet or {}) do
        if name ~= constants.starting_planet then
            table.insert(names, name)
        end
    end
    table.sort(names)
    return names
end

-- Why freezing can't move, or nil if it can
freezing.problem = function()
    local num_frozen = 0
    local num_warm = 0
    for _, name in pairs(movable_planets()) do
        if data.raw.planet[name].entities_require_heating then
            num_frozen = num_frozen + 1
        else
            num_warm = num_warm + 1
        end
    end
    if num_frozen == 0 then
        return "no planet but the starting planet freezes"
    end
    if num_warm == 0 then
        return "every planet but the starting planet freezes"
    end
    return nil
end

-- Names of technologies that discover a planet (an unlock-space-location effect for it), sorted
local function discoverers(planet_name)
    local names = {}
    for _, tech in pairs(data.raw.technology) do
        for _, effect in pairs(tech.effects or {}) do
            if effect.type == "unlock-space-location" and effect.space_location == planet_name then
                names[tech.name] = true
            end
        end
    end
    return sorted_keys(names)
end

-- Names of technologies unlocking a recipe that makes an item placing a heat source (a reactor, which heats through its heat buffer), sorted
local function heating_technologies()
    local heat_items = {}
    for _, item in pairs(dutils.get_all_prots("item")) do
        if item.place_result ~= nil and (data.raw.reactor or {})[item.place_result] ~= nil then
            heat_items[item.name] = true
        end
    end
    local heat_recipes = {}
    for _, recipe in pairs(data.raw.recipe) do
        for _, result in pairs(recipe.results or {}) do
            if result.type == "item" and heat_items[result.name] ~= nil then
                heat_recipes[recipe.name] = true
            end
        end
    end
    local names = {}
    for _, tech in pairs(data.raw.technology) do
        for _, effect in pairs(tech.effects or {}) do
            if effect.type == "unlock-recipe" and heat_recipes[effect.recipe] ~= nil then
                names[tech.name] = true
            end
        end
    end
    return sorted_keys(names)
end

-- The planets whose map generation places an entity (in their autoplace settings), as planet name --> true
local function planets_placing(entity_name)
    local planets = {}
    for name, planet in pairs(data.raw.planet or {}) do
        local settings = (((planet.map_gen_settings or {}).autoplace_settings or {}).entity or {}).settings or {}
        if settings[entity_name] ~= nil then
            planets[name] = true
        end
    end
    return planets
end

-- A minable entity only this planet's map generation places (the first by name), or nil
local function entity_only_on(planet_name)
    local settings = ((((data.raw.planet[planet_name] or {}).map_gen_settings or {}).autoplace_settings or {}).entity or {}).settings or {}
    for _, entity_name in pairs(sorted_keys(settings)) do
        local entity = dutils.get_prot("entity", entity_name)
        if entity ~= nil and entity.minable ~= nil then
            local planets = planets_placing(entity_name)
            if next(planets) == planet_name and next(planets, planet_name) == nil then
                return entity_name
            end
        end
    end
    return nil
end

-- The last move, for freezing.revert:
--   * map: old planet name --> new planet name
--   * old_frozen: planet name --> whether it froze before
--   * tech_edits: list of { tech, prerequisites (before), research_trigger (before) }
freezing.last = nil

-- Moves freezing among the planets other than the starting planet, with its group (see the top of this file)
-- Returns the map of where it went (old planet name --> new planet name), empty if it didn't move
freezing.execute = function(id)
    local key = rng.key({ id = id })
    local planets = movable_planets()
    local frozen = {}
    local old_frozen = {}
    for i, name in pairs(planets) do
        frozen[i] = data.raw.planet[name].entities_require_heating == true
        old_frozen[name] = frozen[i]
    end
    -- Planet i gets planet order[i]'s freezing; a few tries for an order where every frozen planet gives it away
    local order = {}
    for i = 1, #planets do
        order[i] = i
    end
    for _ = 1, 20 do
        rng.shuffle(key, order)
        local moves_all = true
        for i, j in pairs(order) do
            if frozen[j] and i == j then
                moves_all = false
            end
        end
        if moves_all then
            break
        end
    end
    local map = {}
    for i, j in pairs(order) do
        if frozen[j] and not frozen[i] then
            map[planets[j]] = planets[i]
        end
    end
    for i, name in pairs(planets) do
        data.raw.planet[name].entities_require_heating = frozen[order[i]] or nil
    end

    -- Heating follows: a heat source technology discovered with (or researched by mining on) a planet other than the new frozen one gets the new planet's discovery as prerequisite and one of its own entities as trigger
    local tech_edits = {}
    for _, new_planet in pairs(sorted_keys(freezing.inverse(map))) do
        local discovery = discoverers(new_planet)[1]
        local trigger_entity = entity_only_on(new_planet)
        for _, tech_name in pairs(heating_technologies()) do
            local tech = data.raw.technology[tech_name]
            local edit = {
                tech = tech_name,
                prerequisites = table.deepcopy(tech.prerequisites),
                research_trigger = table.deepcopy(tech.research_trigger),
            }
            local changed = false
            if discovery ~= nil then
                for i, prereq in pairs(tech.prerequisites or {}) do
                    for _, space_location in pairs(freezing.discovered_by(prereq)) do
                        if space_location ~= new_planet and data.raw.planet[space_location] ~= nil and space_location ~= constants.starting_planet then
                            tech.prerequisites[i] = discovery
                            changed = true
                        end
                    end
                end
            end
            if trigger_entity ~= nil and tech.research_trigger ~= nil and tech.research_trigger.type == "mine-entity" then
                local mined_elsewhere = false
                for _, entity_name in pairs(tech.research_trigger.entities or { tech.research_trigger.entity }) do
                    if planets_placing(entity_name)[new_planet] == nil then
                        mined_elsewhere = true
                    end
                end
                if mined_elsewhere then
                    tech.research_trigger = {
                        type = "mine-entity",
                        entities = {
                            trigger_entity,
                        },
                    }
                    changed = true
                end
            end
            if changed then
                table.insert(tech_edits, edit)
            end
        end
    end
    freezing.last = {
        map = map,
        old_frozen = old_frozen,
        tech_edits = tech_edits,
    }
    return map
end

-- The room keys of the planets the last move made freeze, as room key --> true
freezing.new_frozen_rooms = function()
    local rooms = {}
    for _, new_planet in pairs(freezing.last.map) do
        rooms[gutils.key("planet", new_planet)] = true
    end
    return rooms
end

-- new planet name --> old planet name, for a map from freezing.execute
freezing.inverse = function(map)
    local inverse = {}
    for old_planet, new_planet in pairs(map) do
        inverse[new_planet] = old_planet
    end
    return inverse
end

-- The space locations a technology discovers
freezing.discovered_by = function(tech_name)
    local locations = {}
    for _, effect in pairs((data.raw.technology[tech_name] or {}).effects or {}) do
        if effect.type == "unlock-space-location" then
            table.insert(locations, effect.space_location)
        end
    end
    return locations
end

-- Puts everything the last move changed back: freezing and the heating technologies
freezing.revert = function()
    local last = freezing.last
    for name, was_frozen in pairs(last.old_frozen) do
        data.raw.planet[name].entities_require_heating = was_frozen or nil
    end
    for _, edit in pairs(last.tech_edits) do
        local tech = data.raw.technology[edit.tech]
        tech.prerequisites = table.deepcopy(edit.prerequisites)
        tech.research_trigger = table.deepcopy(edit.research_trigger)
    end
end

-- One line for the log
freezing.describe = function()
    local parts = {}
    for _, old_planet in pairs(sorted_keys(freezing.last.map)) do
        table.insert(parts, old_planet .. " --> " .. freezing.last.map[old_planet])
    end
    local edits = {}
    for _, edit in pairs(freezing.last.tech_edits) do
        local tech = data.raw.technology[edit.tech]
        local trigger = tech.research_trigger ~= nil and (tech.research_trigger.entities or {})[1] or "none"
        table.insert(edits, edit.tech .. " (prerequisites " .. table.concat(tech.prerequisites or {}, ", ") .. "; mined trigger " .. tostring(trigger) .. ")")
    end
    return table.concat(parts, ", ") .. "; heating technologies edited: " .. (#edits > 0 and table.concat(edits, ", ") or "none")
end

return freezing
