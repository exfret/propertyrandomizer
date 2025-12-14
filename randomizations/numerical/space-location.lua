local randnum = require("lib/random/randnum")
local locale_utils = require("lib/locale")
local rng = require("lib/random/rng")

local space_location_classes = {
    "planet",
    "space-location",
}

local round = function (n)
    return math.floor(n + 0.5)
end

local to_unit_time = function (ticks)

    local ticks_unit = "ticks"
    local seconds = "seconds"
    local minutes = "minutes"
    local hours = "hours"

    local ticks_per_second = 60
    local seconds_per_minute = 60
    local minutes_per_hour = 60
    local unit = ticks_unit
    local time = ticks

    if time > ticks_per_second then
        unit = seconds
        time = time / ticks_per_second
        if time > seconds_per_minute then
            unit = minutes
            time = time / seconds_per_minute
            if time > minutes_per_hour then
                unit = hours
                time = time / minutes_per_hour
            end
        end
    end

    return { unit = unit, value = time }
end

local to_ticks = function (unit, value)

    local seconds = "seconds"
    local minutes = "minutes"
    local hours = "hours"

    local ticks_per_second = 60
    local seconds_per_minute = 60
    local minutes_per_hour = 60

    if unit == seconds then
        value = value * ticks_per_second
    elseif unit == minutes then
        value = value * ticks_per_second * seconds_per_minute
    elseif unit == hours then
        value = value * ticks_per_second * seconds_per_minute * minutes_per_hour
    end

    return math.min(math.max(round(value), 1), 4000000000)
end

randomizations.asteroid_spawns = function (id)
    if not mods["space-age"] then
        return
    end

    for _, class in pairs(space_location_classes) do
        for _, space_location in pairs(data.raw[class]) do
            if space_location.asteroid_spawn_definitions ~= nil then
                local entity_to_factor = {}
                local rng_key = rng.key({ id = id, prototype = space_location })
                for _, asd in pairs(space_location.asteroid_spawn_definitions) do
                    local factor = entity_to_factor[asd.asteroid]
                    if factor == nil then
                        local dir = -1
                        if asd.type == "asteroid-chunk" then
                            dir = 1
                        end
                        factor = randnum.rand({
                            key = rng_key,
                            dummy = 1,
                            variance = "medium",
                            rounding = "none",
                            dir = dir,
                        })
                        entity_to_factor[asd.asteroid] = factor
                    end
                    asd.probability = asd.probability * factor
                end
            end
        end
    end

    for _, space_connection in pairs(data.raw["space-connection"] or {}) do
        for i = 1, #space_connection.asteroid_spawn_definitions or 0 do
            local asd = space_connection.asteroid_spawn_definitions[i]
            space_connection.asteroid_spawn_definitions[i] = {
                type = asd.type or "entity",
                asteroid = asd.asteroid or asd[1],
                spawn_points = asd.spawn_points or asd[2],
            }
            asd = space_connection.asteroid_spawn_definitions[i]

            local dir = -1
            if asd.type == "asteroid-chunk" then
                dir = 1
            end
            local factor = randnum.rand({
                id = id,
                prototype = space_connection,
                dummy = 1,
                variance = "medium",
                rounding = "none",
                dir = dir,
            })

            for _, spawn_point in pairs(asd.spawn_points) do
                spawn_point.probability = spawn_point.probability * factor
            end
        end
    end
end

-- This is applicable to base game
randomizations.planet_day_night_cycles = function (id)
    for _, planet in pairs(data.raw["planet"]) do
        if planet.surface_properties ~= nil then
            if planet.surface_properties["day-night-cycle"] == nil then
                planet.surface_properties["day-night-cycle"] = 300
            end

            local old_value = planet.surface_properties["day-night-cycle"]
            local unit_time = to_unit_time(old_value)
            planet.surface_properties["day-night-cycle"] = unit_time.value

            randnum.rand({
                id = id,
                prototype = planet,
                tbl = planet.surface_properties,
                property = "day-night-cycle",
                variance = "big",
                rounding = "discrete_float",
                dir = -1,
            })

            planet.surface_properties["day-night-cycle"] = to_ticks(unit_time.unit, planet.surface_properties["day-night-cycle"])

            local factor = planet.surface_properties["day-night-cycle"] / old_value
            locale_utils.create_localised_description(planet, factor, id, { variance = "big", flipped = true })
        end
    end
end

-- I think this is also applicable to base game in the sense that it at least doesn't break it, but I don't think it does anything either
randomizations.planet_gravity = function (id)
    for _, planet in pairs(data.raw["planet"]) do
        if planet.surface_properties ~= nil then
            if planet.surface_properties["gravity"] == nil then
                planet.surface_properties["gravity"] = 10
            end

            if planet.surface_properties["gravity"] >= 1 then
                local old_value = planet.surface_properties["gravity"]

                randnum.rand({
                    id = id,
                    prototype = planet,
                    tbl = planet.surface_properties,
                    property = "gravity",
                    variance = "medium",
                    rounding = "discrete_float",
                    dir = -1,
                    abs_min = 1,
                })

                local factor = planet.surface_properties["gravity"] / old_value
                locale_utils.create_localised_description(planet, factor, id, { variance = "medium", flipped = true })
            end
        end
    end
end

-- According to the API this is also fine in base game... maybe should test this because like, wait you can have lightning attractors in base game?..
randomizations.planet_lightning_density = function (id)
    for _, planet in pairs(data.raw["planet"]) do
        if planet.lightning_properties ~= nil then
            local old_value = planet.lightning_properties.lightnings_per_chunk_per_tick

            local chunk_size = 32
            local night_ratio = 0.3
            -- To avg lightning per tile per tick
            planet.lightning_properties.lightnings_per_chunk_per_tick
                = planet.lightning_properties.lightnings_per_chunk_per_tick
                / chunk_size / chunk_size * night_ratio

            randnum.rand({
                id = id,
                prototype = planet,
                tbl = planet.lightning_properties,
                property = "lightnings_per_chunk_per_tick",
                variance = "medium",
                rounding = "discrete_float",
                dir = 1,
            })

            -- Back to lightning per chunk per tick
            planet.lightning_properties.lightnings_per_chunk_per_tick
                = planet.lightning_properties.lightnings_per_chunk_per_tick
                * chunk_size * chunk_size / night_ratio

            local factor = planet.lightning_properties.lightnings_per_chunk_per_tick / old_value
            locale_utils.create_localised_description(planet, factor, id, { variance = "medium" })
        end
    end
end

-- Pretty standard base game randomization
randomizations.planet_solar_power = function (id)
    for _, planet in pairs(data.raw["planet"]) do
        if planet.surface_properties ~= nil then
            if planet.surface_properties["solar-power"] == nil then
                planet.surface_properties["solar-power"] = 100
            end

            local old_value = planet.surface_properties["solar-power"]

            randnum.rand({
                id = id,
                prototype = planet,
                tbl = planet.surface_properties,
                property = "solar-power",
                variance = "big",
                rounding = "discrete_float",
                dir = 1,
            })

            local factor = planet.surface_properties["solar-power"] / old_value
            locale_utils.create_localised_description(planet, factor, id, { variance = "big" })
        end
    end
end

-- Definitely a space age only randomization; added guard clause
randomizations.space_connection_length = function (id)
    if not mods["space-age"] then
        return
    end

    for _, space_connection in pairs(data.raw["space-connection"] or {}) do
        if space_connection.length == nil then
            space_connection.length = 600
        end
        local old_value = space_connection.length

        randnum.rand({
            id = id,
            prototype = space_connection,
            property = "length",
            variance = "medium",
            rounding = "discrete",
            dir = -1,
            data_type = "uint32",
        })

        local factor = space_connection.length / old_value
        locale_utils.create_localised_description(space_connection, factor, id, { variance = "medium", flipped = true })
    end
end

-- Added a guard clause because even though no space age only prototypes/properties are used, data.raw["space-location"] will be empty without space age, causing a crash
-- I'm wondering if we should just populate all the space age class tables to just be empty tables at least to avoid all these errors
randomizations.space_location_solar_power_space = function (id)
    if not mods["space-age"] then
        return
    end
    
    for _, class in pairs(space_location_classes) do
        for _, planet in pairs(data.raw[class]) do
            if planet.solar_power_in_space == nil then
                planet.solar_power_in_space = 1.0
            end

            local old_value = planet.solar_power_in_space

            randnum.rand({
                id = id,
                prototype = planet,
                property = "solar_power_in_space",
                variance = "medium",
                rounding = "discrete_float",
                dir = 1,
            })

            local factor = planet.solar_power_in_space / old_value
            locale_utils.create_localised_description(planet, factor, id, { variance = "medium" })
        end
    end
end