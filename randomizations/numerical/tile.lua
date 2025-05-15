local randnum = require("lib/random/randnum")
local locale_utils = require("lib/locale")

local randomize = randnum.rand

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
        property = "walking_speed_modifier"
    })

    for _, tile in pairs(data.raw.tile) do
        if tile.walking_speed_modifier ~= nil then
            tile.localised_description = locale_utils.create_localised_description(tile, 1 + tile.walking_speed_modifier - tile_to_old_modifier[tile.name], id)
        end
    end
end