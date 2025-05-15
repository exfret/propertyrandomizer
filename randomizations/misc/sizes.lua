local randnum = require("lib/random/randnum")
local rng = require("lib/random/rng")
local reformat = require("lib/reformat")

local randomize = randnum.rand

randomizations.cliff_sizes = function(id)
    for _, cliff in pairs(data.raw.cliff) do
        for _, orientation in pairs(cliff.orientations) do
            local factor = randomize({
                id = id,
                key = rng.key({id = id, prototype = cliff}),
                dummy = 1
            })

            for _, vector in pairs(orientation.collision_bounding_box) do
                -- Just ignore the orientation number, api docs say it's unused
                if type(vector) ~= "number" then
                    vector[1] = vector[1] * factor
                    vector[2] = vector[2] * factor
                end
            end
            
            reformat.change_image_variations_size(orientation.pictures, factor)
            reformat.change_image_variations_size(orientation.pictures_lower, factor)
        end
    end
end

randomizations.unit_sizes = function(id)
    local function get_unit_group(unit)
        local group_ind
        local group_name

        if string.sub(unit.name, 1, 6) == "small-" then
            group_ind = 1
            group_name = string.sub(unit.name, 7, -1)
        elseif string.sub(unit.name, 1, 7) == "medium-" then
            group_ind = 2
            group_name = string.sub(unit.name, 8, -1)
        elseif string.sub(unit.name, 1, 4) == "big-" then
            group_ind = 3
            group_name = string.sub(unit.name, 5, -1)
        elseif string.sub(unit.name, 1, 9) == "behemoth-" then
            group_ind = 4
            group_name = string.sub(unit.name, 10, -1)
        else
            group_ind = 1
            group_name = unit.name
        end

        return {ind = group_ind, name = group_name}
    end

    -- Sense unit groups by small-/medium-/big-/behemoth- prefix
    local unit_groups = {}
    for _, unit_class in pairs({"unit", "spider-unit"}) do
        if data.raw[unit_class] then
            for _, unit in pairs(data.raw[unit_class]) do
                local group_spec = get_unit_group(unit)
                local group_name = group_spec.name
                local group_ind = group_spec.ind

                if unit_groups[group_name] == nil then
                    unit_groups[group_name] = {}
                end
                unit_groups[group_name][group_ind] = unit
            end
        end
    end
    -- Randomize per unit group
    for group_name, group in pairs(unit_groups) do
        local factors = {}
        for i = 1, #group do
            table.insert(factors, randomize({
                key = rng.key({linked = true, id = id, tier = group_name}),
                dummy = 1
            }))
        end

        table.sort(factors)

        for ind, unit in pairs(group) do
            -- Set factor to factors[ind]
            local factor = factors[ind]

            if unit.type == "unit" then
                -- Change actual size
                reformat.change_box_sizes(unit, factor)

                -- Change all graphics to account for the size difference
                if unit.attack_parameters.animation ~= nil then
                    reformat.change_image_size(unit.attack_parameters.animation, factor)
                end
                reformat.change_image_size(unit.run_animation, factor)

                -- Change corpse sizes
                reformat.change_entity_corpse_size(unit, factor)

                -- For big units, make them a bit faster and also the animation a bit slower
                unit.movement_speed = unit.movement_speed * math.pow(factor, 1 / 3)
                unit.distance_per_frame = unit.distance_per_frame / math.pow(factor, 2 / 3)
            elseif unit.type == "spider-unit" then
                -- Change actual size
                reformat.change_box_sizes(unit, factor)
                unit.height = unit.height * factor

                -- Spider-engine (includes legs)
                reformat.change_spider_engine_size(unit.spider_engine, factor)

                -- Torso graphics
                if unit.graphics_set ~= nil then
                    reformat.change_spider_torso_graphics_size(unit.graphics_set, factor)
                end

                -- Attack animation
                if unit.attack_parameters.animation ~= nil then
                    reformat.change_image_size(unit.attack_parameters.animation, factor)
                end

                -- Change corpse sizes
                reformat.change_entity_corpse_size(unit, factor)
            end

            -- Also scale max health so it makes more sense
            if unit.max_health == nil then
                unit.max_health = 10
            end
            unit.max_health = unit.max_health * math.pow(factor, 1 / 3)
            -- And range
            unit.attack_parameters.range = unit.attack_parameters.range * math.pow(factor, 1 / 3)
        end
    end
end