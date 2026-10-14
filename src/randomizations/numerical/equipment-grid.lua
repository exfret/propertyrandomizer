local randnum = require("src/lib/random/randnum")
local locale_utils = require("src/localisation/locale")
local rng = require("src/lib/random/rng")

local randomize = randnum.rand

randomizations.equipment_grid_sizes = function(id)
    local target_prototypes = {}
    -- Gather owners before adding prototypes, and identify them by their grid reference.
    for _, prototypes in pairs(data.raw) do
        for _, prototype in pairs(prototypes) do
            if type(prototype.equipment_grid) == "string" then
                table.insert(target_prototypes, prototype)
            end
        end
    end

    for _, grid_owner in pairs(target_prototypes) do
        if grid_owner.equipment_grid ~= nil then
            local grid = table.deepcopy(data.raw["equipment-grid"][grid_owner.equipment_grid])
            local name = "propertyrandomizer-grid-" .. grid_owner.type .. "-" .. grid_owner.name
            local suffix = 1
            while data.raw["equipment-grid"][name] ~= nil do
                name = "propertyrandomizer-grid-" .. grid_owner.type .. "-" .. grid_owner.name .. "-" .. suffix
                suffix = suffix + 1
            end
            grid.name = name
            data:extend({grid})
            grid_owner.equipment_grid = name
            local old_grid_size = grid.width * grid.height
            if old_grid_size > 0 then
                local old_aspect_ratio = grid.width / grid.height

                local key = rng.key({id = id, prototype = grid_owner})
                local new_grid_size = randomize({
                    id = id,
                    key = key,
                    dummy = old_grid_size,
                    rounding = "none",
                    abs_min = 1,
                    variance = "big",
                })

                local new_aspect_ratio = randomize({
                    id = id,
                    key = key,
                    dummy = old_aspect_ratio,
                    rounding = "none",
                    dir = 0,
                    variance = "medium",
                })

                -- Calculate new width and height based on new size and aspect ratio
                local new_height = math.sqrt(new_grid_size / new_aspect_ratio)
                local new_width = new_aspect_ratio * new_height
                new_height = randnum.fixes({ key = key, rounding = "pure_discrete", abs_min = 1, abs_max = 4294967295 }, new_height)
                new_width = randnum.fixes({ key = key, rounding = "pure_discrete", abs_min = 1, abs_max = 4294967295 }, new_width)
                grid.height = new_height
                grid.width = new_width

                new_grid_size = new_height * new_width
                local factor = new_grid_size / old_grid_size

                locale_utils.create_localised_description(grid_owner, factor, id, { variance = "big" })
            end
        end
    end
end
