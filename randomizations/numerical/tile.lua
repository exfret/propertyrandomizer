local randnum = require("lib/random/randnum")

local randomize = randnum.rand

randomizations.tile_walking_speed_modifier = function(id)
    -- Just do linked randomization to make things easier, so that I don't have to worry about next_direction
    local prototypes = {}
    for _, tile in pairs(data.raw.tile) do
        if tile.walking_speed_modifier ~= nil then
            table.insert(prototypes, tile)
        end
    end

    randomizations.linked({
        id = id,
        prototypes = prototypes,
        property = "walking_speed_modifier"
    })
end