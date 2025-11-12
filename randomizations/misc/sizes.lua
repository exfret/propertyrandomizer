local randnum = require("lib/random/randnum")
local rng = require("lib/random/rng")
local locale_utils = require("lib/locale")
local reformat = require("lib/reformat")

local randomize = randnum.rand

randomizations.cliff_sizes = function(id)
    for _, cliff in pairs(data.raw.cliff) do
        for orientation_type, orientation in pairs(cliff.orientations) do
            -- The "none" orientations were causing troubles
            if not string.find(orientation_type, "none") then
                local factor = randomize({
                    id = id,
                    key = rng.key({id = id, prototype = cliff}),
                    dummy = 1,
                    dir = -1,
                    variance = "small"
                })

                for _, vector in pairs(orientation.collision_bounding_box) do
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
                dummy = 1,
                dir = -1,
                variance = "very_small",
                rounding = "none"
            }))
        end

        table.sort(factors)

        for ind, unit in pairs(group) do
            -- Set factor to factors[ind]
            local factor = factors[ind]
            local key = rng.key({prototype = unit, id = id, tier = group_name})
            local rounding_params = { key = key, rounding = "discrete_float" }

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
                local old_movement_speed = unit.movement_speed
                -- To km/h
                unit.movement_speed = unit.movement_speed * 216
                unit.movement_speed = randnum.fixes(rounding_params, unit.movement_speed * factor)
                -- Back to tiles per tick
                unit.movement_speed = unit.movement_speed / 216

                local speed_factor_post_rounding = unit.movement_speed / old_movement_speed
                -- This'll be an ugly unrounded number, but no one'll ever see it, so it's fine
                unit.distance_per_frame = unit.distance_per_frame * speed_factor_post_rounding
            elseif unit.type == "spider-unit" then
                -- Change actual size
                reformat.change_box_sizes(unit, factor)
                unit.height = randnum.fixes(rounding_params, unit.height * factor)

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
            unit.max_health = randnum.fixes(rounding_params, unit.max_health * factor^3)
            if unit.resistances ~= nil then
                for _, resistance in pairs(unit.resistances) do
                    if resistance.decrease ~= nil and resistance.decrease > 0 then
                        resistance.decrease = randnum.fixes(rounding_params, resistance.decrease * factor^3)
                    end
                end
            end
            if unit.healing_per_tick ~= nil and unit.healing_per_tick ~= 0 then
                unit.healing_per_tick = randnum.fixes(rounding_params, unit.healing_per_tick * factor^3)
            end

            -- And range
            local ap = unit.attack_parameters
            ap.range = randnum.fixes(rounding_params, ap.range * factor)
            if ap.min_range ~= nil then
                ap.min_range = randnum.fixes(rounding_params, ap.min_range * factor)
            end
            if ap.min_attack_distance ~= nil then
                ap.min_attack_distance = randnum.fixes(rounding_params, ap.min_attack_distance * factor)
            end
            unit.vision_distance = math.min(randnum.fixes(rounding_params, unit.vision_distance * factor), 100)
            if unit.max_pursue_distance == nil then
                unit.max_pursue_distance = 50
            end
            unit.max_pursue_distance = randnum.fixes(rounding_params, unit.max_pursue_distance * factor)

            -- And attack
            if ap.damage_modifier == nil then
                ap.damage_modifier = 1
            end
            ap.damage_modifier = randnum.fixes(rounding_params, ap.damage_modifier * factor^3)

            -- Realistically, if factor directly affects height, width and depth measurements of a unit, then its mass should scale with factor^3
            -- Speed and range scale with lengths of limbs and such, so scale with factor^1
            -- Max health and damage scale with mass, so scale with factor^3
            -- Flat resistances and healing make more sense to think of as ratios of max health, so those scale with factor^3 too

            -- Localised description
            unit.localised_description = locale_utils.create_localised_description(unit, factor, id, { variance = "very_small", flipped = true })
        end
    end
end