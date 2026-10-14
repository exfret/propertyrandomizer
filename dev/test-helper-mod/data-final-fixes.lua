local tile_buildability = require("test-tile-buildability-data")
local biome_placement = require("test-biome-placement-data")

tile_buildability.run()
biome_placement.run()

-- Noise properties used only by the runtime coordinate probe, never by playable planets.
local biome_setting = settings.startup["propertyrandomizer-planetary-biomes"]
if biome_setting ~= nil and biome_setting.value == true then
    for axis, _ in pairs({
        x = true,
        y = true,
    }) do
        data:extend({
            {
                type = "noise-expression",
                name = "propertyrandomizer-biome-probe-" .. axis,
                expression = axis,
            },
        })
    end
end
