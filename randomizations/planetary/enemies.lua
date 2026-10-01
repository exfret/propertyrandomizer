-- Planetary enemy moves (setting propertyrandomizer-planetary-enemies, work in progress, see notes/wip.txt): demolisher territories and the starting planet's kind of enemies go to random other planets
-- The starting planet keeps its own enemies and gets no others (user, 2026-10-01): capturing its spawners is how biter eggs are made, which the logic counts on there
-- Demolishers: each planet's territory settings (map_gen_settings.territory_settings, how Vulcanus makes them) go to a planet other than the starting one, one territory per planet
-- The starting planet's kinds of enemies come with their map gen slider: Nauvis lists no enemies among its entities, and a planet places autoplaced enemies only with their slider (base/prototypes/entity/enemy-autoplace-utils.lua gives them all "enemy-base")
-- So each other planet with such a slider (the starting planet's copies) gives it to a random planet, all kinds of one slider together (user, 2026-10-01: together is fine)
-- Spawners only absorb their own pollutant, so a planet getting them gets the starting planet's pollutant if it has none, and a planet with another one (Gleba's spores, which its own spawners need) gets none
-- Nothing else follows: enemies aren't modeled as hazards (user, 2026-09-26), and the starting planet keeps the spawners the logic captures

local constants = require("helper-tables/constants")
local dutils = require("lib/data-utils")
local rng = require("lib/random/rng")

local enemies = {}

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

-- The map gen sliders of the starting planet's kinds of enemies: its autoplace controls that some autoplaced entity of the enemy force uses
local function start_enemy_controls()
    local used = {}
    for _, entity in pairs(dutils.get_all_prots("entity")) do
        if entity.autoplace ~= nil and entity.autoplace.force == "enemy" and entity.autoplace.control ~= nil then
            used[entity.autoplace.control] = true
        end
    end
    local controls = {}
    local start = data.raw.planet[constants.starting_planet]
    for _, control in pairs(sorted_keys(((start or {}).map_gen_settings or {}).autoplace_controls or {})) do
        if used[control] ~= nil then
            table.insert(controls, control)
        end
    end
    return controls
end

-- Moves the demolisher territories; returns the moves as text
local function move_territories(key)
    local sources = {}
    local destinations = {}
    for _, planet_name in pairs(sorted_keys(data.raw.planet)) do
        local map_gen_settings = data.raw.planet[planet_name].map_gen_settings
        if planet_name ~= constants.starting_planet and map_gen_settings ~= nil then
            table.insert(destinations, planet_name)
            if map_gen_settings.territory_settings ~= nil then
                table.insert(sources, planet_name)
            end
        end
    end
    local territories = {}
    for _, planet_name in pairs(sources) do
        local map_gen_settings = data.raw.planet[planet_name].map_gen_settings
        table.insert(territories, map_gen_settings.territory_settings)
        map_gen_settings.territory_settings = nil
    end
    rng.shuffle(key, destinations)
    local moves = {}
    for i, territory in pairs(territories) do
        data.raw.planet[destinations[i]].map_gen_settings.territory_settings = territory
        table.insert(moves, "territory of " .. sources[i] .. " --> " .. destinations[i])
    end
    return moves
end

-- Moves the starting planet's enemy sliders off the other planets that have them; returns the moves as text
local function move_start_enemies(key)
    local controls = start_enemy_controls()
    local pollutant = data.raw.planet[constants.starting_planet].pollutant_type
    local destinations = {}
    for _, planet_name in pairs(sorted_keys(data.raw.planet)) do
        local planet = data.raw.planet[planet_name]
        if planet_name ~= constants.starting_planet and planet.map_gen_settings ~= nil and (planet.pollutant_type == nil or planet.pollutant_type == pollutant) then
            table.insert(destinations, planet_name)
        end
    end
    local moves = {}
    if #destinations == 0 then
        return moves
    end
    -- Every slider leaves its planet before any lands, so one landing on a planet later in the order isn't moved again from there
    local placements = {}
    for _, planet_name in pairs(sorted_keys(data.raw.planet)) do
        local map_gen_settings = data.raw.planet[planet_name].map_gen_settings
        if planet_name ~= constants.starting_planet and map_gen_settings ~= nil and map_gen_settings.autoplace_controls ~= nil then
            for _, control in pairs(controls) do
                if map_gen_settings.autoplace_controls[control] ~= nil then
                    table.insert(placements, {
                        planet_name = planet_name,
                        control = control,
                        settings = map_gen_settings.autoplace_controls[control],
                    })
                    map_gen_settings.autoplace_controls[control] = nil
                end
            end
        end
    end
    for _, placement in pairs(placements) do
        local destination = data.raw.planet[destinations[rng.int(key, #destinations)]]
        local map_gen_settings = destination.map_gen_settings
        map_gen_settings.autoplace_controls = map_gen_settings.autoplace_controls or {}
        map_gen_settings.autoplace_controls[placement.control] = map_gen_settings.autoplace_controls[placement.control] or placement.settings
        local added = ""
        if destination.pollutant_type == nil and pollutant ~= nil then
            destination.pollutant_type = pollutant
            added = " (now with " .. pollutant .. ")"
        end
        table.insert(moves, placement.control .. " of " .. placement.planet_name .. " --> " .. destination.name .. added)
    end
    return moves
end

local function log_moves(what, moves)
    log("Planetary " .. what .. ": " .. #moves .. " moves" .. (#moves > 0 and (": " .. table.concat(moves, "; ")) or ""))
end

-- Moves the demolisher territories; id names the random stream
enemies.move_demolishers = function(id)
    log_moves("demolishers", move_territories(rng.key({
        id = id,
    })))
end

-- Moves the starting planet's enemy sliders off its copies; id names the random stream
-- Capturing a spawner is then only kept on the starting planet (the capture-spawner node's planetary_feature "biters", lib/logic/abstract.lua)
enemies.move_biters = function(id)
    log_moves("biters", move_start_enemies(rng.key({
        id = id,
    })))
end

return enemies
