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
local function extend_vector(v, amount)
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
    -- Probability of randomizing the pickup and insert distances separately
    local randomize_stretch_p = 0.75
    -- Probability of randomizing the rotation of the pickup and insert vectors
    local randomize_rotation_p = 1
    -- Probability of putting the insert position on the close side of a belt
    local close_side_p = 0.5

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
                id = id,
                key = key,
                dummy = old_arm_length,
                abs_min = margin,
                abs_max = 16 - margin,
                rounding = "none"
            })

            -- negative bias because this may slow down the inserter
            local randomize_stretch = randbool.rand_bias_chaos(key, randomize_stretch_p, -1)
            local stretch_factor = 1
            if randomize_stretch then
                -- carefully make sure the stretch factor doesn't make the insert position go past limits
                stretch_factor = randnum.rand({
                    id = id,
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
            local randomize_rotation = randbool.rand_bias_chaos(key, randomize_rotation_p, 1)
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
                    inserter.localised_description = {"", locale_utils.find_localised_description(inserter), {"propertyrandomizer-status.offset-red"}}
                end
            end

            local pickup_distance = math.sqrt(new_pickup_x^2 + new_pickup_y^2)
            local insert_distance = math.sqrt(new_insert_x^2 + new_insert_y^2)
            new_arm_length = math.max(pickup_distance, insert_distance)
            
            if randomize_stretch and math.abs(pickup_distance - insert_distance) > 0.5 then
                inserter.localised_description = {"", locale_utils.find_localised_description(inserter), {"propertyrandomizer-status.stretchy-red"}}
            end
            locale_utils.create_localised_description(inserter, new_arm_length / old_arm_length, id)
            
            local scaled_pickup_vector = extend_vector({ new_pickup_x, new_pickup_y }, -0.02)

            -- Let's randomize which side of the belt the inserter puts things on
            local insert_offset = 0.2
            if (randbool.converge(key, close_side_p)) then
                insert_offset = -insert_offset
            end
            local scaled_insert_vector = extend_vector({ new_insert_x, new_insert_y }, insert_offset)

            inserter.pickup_position = scaled_pickup_vector
            inserter.insert_position = scaled_insert_vector
        end
    end
end

-- Vector and BoundingBox accept both array and named coordinates in the 2.1 API.
local function coords(vector)
    return {
        vector.x or vector[1],
        vector.y or vector[2],
    }
end

-- Distance from the origin to the rectangle boundary along a unit vector.
local function edge_distance(direction, left_top, right_bottom, padding)
    local distance = math.huge
    for axis = 1, 2 do
        if direction[axis] > 0 then
            distance = math.min(distance, (right_bottom[axis] + padding) / direction[axis])
        elseif direction[axis] < 0 then
            distance = math.min(distance, (left_top[axis] - padding) / direction[axis])
        end
    end
    return distance
end

randomizations.mining_drill_offsets = function(id)
    local randomize_place_rotation_p = 0.5

    for _, mining_drill in pairs(data.raw["mining-drill"]) do
        local box = mining_drill.collision_box
        local off_grid = false
        for _, flag in pairs(mining_drill.flags or {}) do
            if flag == "off-grid" then
                off_grid = true
            end
        end
        -- Item offsets are independent of fluid output boxes, including ports added by preview preparation.
        if box ~= nil and not off_grid
        and (box.orientation or box[3] or 0) == 0 then
            local left_top = coords(box.left_top or box[1])
            local right_bottom = coords(box.right_bottom or box[2])
            local old_place_vector = coords(mining_drill.vector_to_place_result)
            local old_place_distance = math.sqrt(old_place_vector[1]^2 + old_place_vector[2]^2)

            -- A zero vector has no output direction to rotate or stretch.
            if old_place_distance > 0 then
                local key = rng.key({
                    id = id,
                    prototype = mining_drill,
                })
                local old_direction = {
                    old_place_vector[1] / old_place_distance,
                    old_place_vector[2] / old_place_distance,
                }
                local place_rotation_rad = 0
                if randbool.rand_chaos(key, randomize_place_rotation_p) then
                    place_rotation_rad = rng.float_range(key, -math.pi/4, math.pi/4)
                end
                local direction = rotate_vector(old_direction, place_rotation_rad)
                local old_edge_distance = edge_distance(old_direction, left_top, right_bottom, 0)
                local new_extension = randnum.rand({
                    id = id,
                    key = key,
                    dummy = math.max(0.5, old_place_distance - old_edge_distance + 0.5),
                    rounding = "none",
                    dir = 0
                }) - 0.5

                -- Padding covers half a receiving tile (0.5), the maximum snapping movement (0.5), and a small margin (0.01).
                local min_place_distance = edge_distance(direction, left_top, right_bottom, 1.01)
                local new_place_distance = math.max(min_place_distance,
                    edge_distance(direction, left_top, right_bottom, 0) + new_extension)
                -- EntityPrototype tile_width/tile_height default to each collision dimension rounded up; even dimensions place the origin on a tile edge.
                local width = mining_drill.tile_width or math.ceil(right_bottom[1] - left_top[1])
                local height = mining_drill.tile_height or math.ceil(right_bottom[2] - left_top[2])
                local grid_phase = {
                    (1 - width % 2) / 2,
                    (1 - height % 2) / 2,
                }
                local new_place_vector = {}
                for axis = 1, 2 do
                    local position = direction[axis] * new_place_distance
                    new_place_vector[axis] = round(position - grid_phase[axis]) + grid_phase[axis]
                end

                -- Aim toward the near side of the receiving tile along the actual output direction.
                for axis = 1, 2 do
                    new_place_vector[axis] = new_place_vector[axis] - 0.2 * direction[axis]
                end
                if new_place_vector[1] ~= old_place_vector[1] or new_place_vector[2] ~= old_place_vector[2] then
                    mining_drill.localised_description = {"", locale_utils.find_localised_description(mining_drill), {"propertyrandomizer-status.misaligned-red"}}
                end
                mining_drill.vector_to_place_result = new_place_vector
            end
        end
    end
end
