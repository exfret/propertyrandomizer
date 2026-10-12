-- Which enemies a combat check asks a weapon for: the units of each planet's attack groups and territories, and the asteroids of each space connection.
-- Only which ones, never how many: every target needs a weapon of its own (src/logic/builders/combat-encounters.lua).
-- Evolution is a scenario parameter, never a promise that an enemy can be acquired.

local acquisition = require("src/logic/builders/acquisition")
local gutils = require("src/lib/graph/graph-utils")

local encounters = {}

local function sorted_keys(values)
    local keys = {}
    for k, _ in pairs(values) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

local function positive_finite(value)
    return type(value) == "number" and value > 0 and value < math.huge
end

-- What a combat check allows: ten turrets of one weapon, or one weapon in hand, killing each target on its own within clear_seconds
-- The clear-time setting scales the 20 second default; No Cap leaves attack groups and territories unchecked
encounters.policy = function(options)
    options = options or {}
    local difficulty = options.difficulty or "normal"
    assert(difficulty == "normal" or difficulty == "no-cap", "Unknown combat difficulty")
    local multiplier = options.time_multiplier or 1
    assert(positive_finite(multiplier), "Invalid combat time multiplier")
    return {
        difficulty = difficulty,
        check_enemies = difficulty ~= "no-cap",
        clear_seconds = 20 * multiplier,
        turret_count = 10,
        manual_count = 1,
    }
end

-- The units a spawner sends at an evolution: every one with a positive spawn weight there
-- UnitSpawnDefinition accepts named/tuple entries and interpolates their weights.
-- https://lua-api.factorio.com/latest/types/UnitSpawnDefinition.html
encounters.spawn_mix = function(spawner, evolution)
    local units = {}
    for _, definition in pairs(spawner.result_units or {}) do
        local unit, points = acquisition.read_spawn_definition(definition)
        if unit ~= nil and acquisition.spawn_weight_at(points, evolution) > 0 then
            units[unit] = true
        end
    end
    return sorted_keys(units)
end

-- The attack groups (one per planet, spawner and evolution step 0, 0.2, ..., 1) and territories (one per segmented unit) a combat check protects
-- Each is {name, kind, room, anchor (a room node key), source, evolution, targets (entity names)}
-- options.in_room(room, entity) tells where a spawner is, options.planet_of(name) gives a planet's prototype
encounters.collect = function(lu, options)
    options = options or {}
    local definitions = {}
    local entities = lu.entities or {}
    for _, room_key in pairs(sorted_keys(lu.rooms or {})) do
        local room = lu.rooms[room_key]
        if room.type == "planet" then
            for _, entity_name in pairs(sorted_keys(entities)) do
                local spawner = entities[entity_name]
                if spawner.result_units ~= nil and options.in_room(room, spawner) then
                    for step = 0, 5 do
                        local evolution = step / 5
                        local units = encounters.spawn_mix(spawner, evolution)
                        if #units > 0 then
                            table.insert(definitions, {
                                name = gutils.concat({
                                    room_key,
                                    "spawn",
                                    entity_name,
                                    step,
                                }),
                                kind = "spawn-group",
                                room = room_key,
                                anchor = gutils.key("room", room_key),
                                source = entity_name,
                                evolution = evolution,
                                targets = units,
                            })
                        end
                    end
                end
            end
            local planet = options.planet_of(room.name)
            local map_gen = planet and planet.map_gen_settings
            local territory = map_gen and map_gen.territory_settings
            local units = {}
            -- TerritorySettings.units names individual segmented-unit variants.
            -- https://lua-api.factorio.com/latest/types/TerritorySettings.html
            for _, unit in pairs(territory and territory.units or {}) do
                units[unit] = true
            end
            for _, unit in pairs(sorted_keys(units)) do
                table.insert(definitions, {
                    name = gutils.concat({
                        room_key,
                        "territory",
                        unit,
                    }),
                    kind = "territory",
                    room = room_key,
                    anchor = gutils.key("room", room_key),
                    source = unit,
                    targets = { unit },
                })
            end
        end
    end
    table.sort(definitions, function(a, b) return a.name < b.name end)
    return definitions
end

-- The asteroids a space connection spawns: its own spawn definitions with a positive probability somewhere, and those of its endpoints, which spawn on the connections of their location
-- Returns a set of entity names; what these split into when they die is added by the caller
-- https://lua-api.factorio.com/latest/types/SpaceConnectionAsteroidSpawnDefinition.html
-- https://lua-api.factorio.com/latest/prototypes/SpaceLocationPrototype.html#asteroid_spawn_influence
encounters.route_asteroids = function(connection, locations)
    local names = {}
    for _, spawn in pairs(connection.asteroid_spawn_definitions or {}) do
        if (spawn.type or "entity") == "entity" then
            local name = spawn.asteroid or spawn[1]
            local positive = false
            for _, point in pairs(spawn.spawn_points or spawn[2] or {}) do
                positive = positive or (point.probability or 0) > 0
            end
            if name ~= nil and positive then
                names[name] = true
            end
        end
    end
    for _, location_name in pairs({
        connection.from,
        connection.to,
    }) do
        local location = (locations or {})[location_name]
        if location ~= nil and positive_finite(location.asteroid_spawn_influence or 0.1) then
            for _, spawn in pairs(location.asteroid_spawn_definitions or {}) do
                if (spawn.type or "entity") == "entity" and spawn.asteroid ~= nil and positive_finite(spawn.probability) then
                    names[spawn.asteroid] = true
                end
            end
        end
    end
    return names
end

return encounters
