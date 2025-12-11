local randnum = require("lib/random/randnum")
local locale_utils = require("lib/locale")
local rng = require("lib/random/rng")

local randomize = randnum.rand

randomizations.tile_pollution_absorption = function (id)
    local chunk_size = 32
    local seconds_per_minute = 60

    local randomized_tables = {}

    for _, tile in pairs(data.raw.tile or {}) do
        if randomized_tables[tile.absorptions_per_second] ~= nil then
            local factor = randomized_tables[tile.absorptions_per_second]
            locale_utils.create_localised_description(tile, factor, id, { variance = "medium" })
        else
            local rng_key = rng.key({ id = id, prototype = tile })
            local factor = randomize({
                key = rng_key,
                dummy = 1,
                rounding = "none",
                dir = 1,
                variance = "medium",
            })
            local rounding_params = { key = rng_key, rounding = "discrete_float" }
            local changed = false

            for pollutant, value in pairs(tile.absorptions_per_second or {}) do
                local per_chunk_per_minute = value * chunk_size * chunk_size * seconds_per_minute
                per_chunk_per_minute = randnum.fixes(rounding_params, per_chunk_per_minute * factor)
                local per_tile_per_second = per_chunk_per_minute / chunk_size / chunk_size / seconds_per_minute
                tile.absorptions_per_second[pollutant] = per_tile_per_second
                changed = true
            end

            if changed then
                randomized_tables[tile.absorptions_per_second] = factor
                locale_utils.create_localised_description(tile, factor, id, { variance = "medium" })
            end
        end
    end
end

randomizations.tile_walking_speed_modifier = function(id)
    -- Just do linked randomization to make things easier, so that I don't have to worry about next_direction
    local prototypes = {}
    local tile_to_old_modifier = {}
    for _, tile in pairs(data.raw.tile) do
        if tile.walking_speed_modifier ~= nil and tile.walking_speed_modifier > 0 then
            table.insert(prototypes, tile)
            tile_to_old_modifier[tile.name] = tile.walking_speed_modifier
        end
    end

    randomizations.linked({
        id = id,
        prototypes = prototypes,
        property = "walking_speed_modifier",
        rounding = "discrete_float",
        variance = "big",
    })

    for _, tile in pairs(data.raw.tile) do
        if tile.walking_speed_modifier ~= nil then
            local factor = tile.walking_speed_modifier / tile_to_old_modifier[tile.name]
            locale_utils.create_localised_description(tile, factor, id, { variance = "big" })
        end
    end
end