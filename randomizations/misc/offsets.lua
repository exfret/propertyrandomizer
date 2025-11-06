local rng = require("lib/random/rng")
local randbool = require("lib/random/randbool")
local randnum = require("lib/random/randnum")
local locale_utils = require("lib/locale")

local round = function (x)
    return math.floor(x + 0.5)
end

-- Rotates a 2D vector (x, y) by angle theta (in radians)
local function rotate_vector(v, radians)
    local x = v[1]
    local y = v[2]
    local cos_theta = math.cos(radians)
    local sin_theta = math.sin(radians)
    local x_new = x * cos_theta - y * sin_theta
    local y_new = x * sin_theta + y * cos_theta
    return { x_new, y_new }
end

-- Extends a 2D vector (x, y) by 'amount', keeping its direction
local function scale_vector(v, amount)
    local x = v[1]
    local y = v[2]
    local length = math.sqrt(x * x + y * y)
    if length == 0 then
        return x, y
    end
    local new_length = length + amount
    local scale = new_length / length
    return { x * scale, y * scale }
end

-- Inserter offsets are NO LONGER randomized by just choosing from a list
randomizations.inserter_offsets = function(id)
    for _, inserter in pairs(data.raw.inserter) do
        if inserter.collision_box ~= nil and inserter.collision_box[1][1] == -0.15 and inserter.collision_box[1][2] == -0.15
        and inserter.collision_box[2][1] == 0.15 and inserter.collision_box[2][2] == 0.15 then
            local key = rng.key({id = id, prototype = inserter})
            local old_pickup_x, old_pickup_y = round(inserter.pickup_position[1]), round(inserter.pickup_position[2])
            local old_insert_x, old_insert_y = round(inserter.insert_position[1]), round(inserter.insert_position[2])
            local old_arm_length = math.sqrt(old_pickup_x^2 + old_pickup_y^2)

            -- Max arm length is 16. margin is to make sure rounding doesn't exceed limits.
            local margin = math.sqrt(0.5) + 0.01
            local new_arm_length = randnum.rand({
                key = key,
                dummy = old_arm_length,
                abs_min = margin,
                abs_max = 16 - margin,
                rounding = "none"
            })

            -- negative bias because this may slow down the inserter
            local randomize_stretch = randbool.rand_bias(key, 0.5, -1)
            local stretch_factor = 1
            if randomize_stretch then
                -- carefully make sure the stretch factor doesn't make the insert position go past limits
                stretch_factor = randnum.rand({
                    key = key,
                    dummy = 1,
                    abs_min = (margin) / new_arm_length,
                    abs_max = (16 - margin) / new_arm_length,
                    dir = 0,
                    rounding = "none"
                })
            end

            local arm_length_factor = new_arm_length / old_arm_length
            local new_pickup_x = round(old_pickup_x * arm_length_factor)
            local new_pickup_y = round(old_pickup_y * arm_length_factor)
            local new_insert_x = round(old_insert_x * arm_length_factor * stretch_factor)
            local new_insert_y = round(old_insert_y * arm_length_factor * stretch_factor)

            -- positive bias because this may speed up the inserter
            local randomize_rotation = randbool.rand_bias(key, 0.5, 1)
            if randomize_rotation then
                -- rotating the pickup position more than 45 degrees is pointless
                local pickup_position_rotation_rad = rng.float_range(key, -math.pi/4, math.pi/4)
                local rotated_pickup_vector = rotate_vector({ old_pickup_x * arm_length_factor, old_pickup_y * arm_length_factor }, pickup_position_rotation_rad)
                new_pickup_x, new_pickup_y = round(rotated_pickup_vector[1]), round(rotated_pickup_vector[2])
                new_insert_x, new_insert_y = new_pickup_x, new_pickup_y
                while new_insert_x == new_pickup_x and new_insert_y == new_pickup_y do
                    local inserter_rotation_rad = rng.float_range(key, 0, 2 * math.pi)
                    local rotated_insert_vector = rotate_vector({ old_insert_x * arm_length_factor * stretch_factor, old_insert_y * arm_length_factor * stretch_factor }, inserter_rotation_rad)
                    new_insert_x, new_insert_y = round(rotated_insert_vector[1]), round(rotated_insert_vector[2])
                end
                if new_pickup_x ~= 0 or new_insert_x ~= -new_pickup_x or new_insert_y ~= -new_pickup_y then
                    inserter.localised_description = {"", locale_utils.find_localised_description(inserter), "\n[color=red](Offset)[/color]"}
                end
            end

            local pickup_distance = math.sqrt(new_pickup_x^2 + new_pickup_y^2)
            local insert_distance = math.sqrt(new_insert_x^2 + new_insert_y^2)
            new_arm_length = math.max(pickup_distance, insert_distance)
            
            if randomize_stretch and math.abs(pickup_distance - insert_distance) > 0.5 then
                inserter.localised_description = {"", locale_utils.find_localised_description(inserter), "\n[color=red](Stretchy)[/color]"}
            end
            locale_utils.create_localised_description(inserter, new_arm_length / old_arm_length, id)
            
            local scaled_pickup_vector = scale_vector({ new_pickup_x, new_pickup_y }, -0.02)

            -- Let's randomize which side of the belt the inserter puts things on
            local insert_offset = 0.2
            if (randbool.converge(key, 0.5)) then
                insert_offset = -insert_offset
            end
            local scaled_insert_vector = scale_vector({ new_insert_x, new_insert_y }, insert_offset)

            inserter.pickup_position = scaled_pickup_vector
            inserter.insert_position = scaled_insert_vector
        end
    end
end

local round_half = function (x)
    return math.floor(x) + 0.5
end

local modify_coords = function(v, func)
    return { func(v[1]), func(v[2]) }
end

randomizations.mining_drill_offsets = function(id)
    for _, mining_drill in pairs(data.raw["mining-drill"]) do
        -- Don't randomize fluid output positions
        if mining_drill.output_fluid_box == nil then
            local key = rng.key({id = id, prototype = mining_drill})

            -- Just make it a random amount farther away up to the collision box size
            if mining_drill.collision_box ~= nil then
                -- Assuming square collision box
                local collision_box_size = math.ceil(mining_drill.collision_box[2][1] - mining_drill.collision_box[1][1])
                local collision_box_radius = collision_box_size / 2
                local even_sized = (collision_box_size % 2) == 0
                local round_function = round
                if even_sized then
                    round_function = round_half
                end
                local old_place_vector = modify_coords(mining_drill.vector_to_place_result, round_function)
                local old_place_distance = math.sqrt(old_place_vector[1]^2 + old_place_vector[2]^2)
                local place_rotation_rad = 0

                local randomize_rotation = randbool.rand_chaos(key, 0.5)
                if randomize_rotation then
                    place_rotation_rad = rng.float_range(key, -math.pi/4, math.pi/4)
                end
                local rotated_place_vector = rotate_vector(old_place_vector, place_rotation_rad)

                -- Find out the minimum place_distance to not overlap with collision box
                local min_place_distance = collision_box_radius / math.cos(place_rotation_rad)

                -- Randomize only the extension beyond the collision box so that randomization gets the right variance
                local min_extension = min_place_distance - collision_box_radius + 0.01
                local old_extension = old_place_distance - collision_box_radius

                local new_extension = randnum.rand({
                    key = key,
                    dummy = old_extension,
                    rounding = "none",
                    dir = 0
                })
                if new_extension < min_extension then
                    new_extension = min_extension
                end

                local new_place_distance = collision_box_radius + new_extension
                local scale_factor = new_place_distance / old_place_distance

                local scaled_place_vector = modify_coords(rotated_place_vector, function(x) return x * scale_factor end)
                local new_place_vector = modify_coords(scaled_place_vector, round_function)

                if new_place_vector[1] ~= old_place_vector[1] or new_place_vector[2] ~= old_place_vector[2] then
                    mining_drill.localised_description = {"", locale_utils.find_localised_description(mining_drill), "\n[color=red](Misaligned)[/color]"}
                end

                -- place stuff on the adjacent side of a belt
                new_place_vector[2] = new_place_vector[2] + 0.2
                mining_drill.vector_to_place_result = new_place_vector
            end
        end
    end
end