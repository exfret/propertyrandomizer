local randnum = require("lib/random/randnum")
local categories = require("helper-tables/categories")
local locale_utils = require("lib/locale")
local rng = require("lib/random/rng")

local randomize = randnum.rand

local round = function (num)
    return math.floor(num + 0.5)
end

-- New
randomizations.equipment_grid_sizes = function(id)
    local target_prototypes = {}
    for class_name, _ in pairs(categories.vehicles) do
        for _, vehicle in pairs(data.raw[class_name]) do
            table.insert(target_prototypes, vehicle)
        end
    end
    for _, armor in pairs(data.raw.armor) do
        table.insert(target_prototypes, armor)
    end

    for _, grid_owner in pairs(target_prototypes) do
        if grid_owner.equipment_grid ~= nil then
            local grid = data.raw["equipment-grid"][grid_owner.equipment_grid]
            local old_grid_size = grid.width * grid.height
            if old_grid_size > 0 then
                local old_aspect_ratio = grid.width / grid.height

                local key = rng.key({id = id, prototype = grid_owner})
                local new_grid_size = randomize({
                    key = key,
                    dummy = old_grid_size,
                    rounding = "none",
                    abs_min = 1
                })

                local new_aspect_ratio = randomize({
                    key = key,
                    dummy = old_aspect_ratio,
                    rounding = "none",
                    dir = 0
                })

                -- Calculate new width and height based on new size and aspect ratio
                local new_height = math.max(round(math.sqrt(new_grid_size / new_aspect_ratio)), 1)
                local new_width = math.max(round(new_aspect_ratio * math.sqrt(new_grid_size / new_aspect_ratio)), 1)
                grid.height = new_height
                grid.width = new_width

                new_grid_size = new_height * new_width
                local factor = new_grid_size / old_grid_size

                locale_utils.create_localised_description(grid_owner, factor, id)
            end
        end
    end
end