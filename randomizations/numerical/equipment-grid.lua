local randnum = require("lib/random/randnum")

local randomize = randnum.rand

-- NEW? Wasn't tested at least
randomizations.equipment_grid_sizes = function(id)
    for _, grid in pairs(data.raw["equipment-grid"]) do
        randomize({
            id = id,
            prototype = grid,
            property = "height",
            abs_min = 2,
            range = "small",
            variance = "small",
            rounding = "discrete"
        })
        randomize({
            id = id,
            prototype = grid,
            property = "width",
            abs_min = 2,
            range = "small",
            variance = "small",
            rounding = "discrete"
        })
    end
end