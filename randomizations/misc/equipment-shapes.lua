local randnum = require("lib/random/randnum")
local rng = require("lib/random/rng")

local randomize = randnum.rand

local basic_shapes = {
    -- Basic rectangle
    {
        cost = 0,
        shape = {
            {0, 0}
        }
    },
    -- Basic L shape
    {
        cost = 1,
        shape = {
            {0, 0}, {1, 0},
            {0, 1}
        }
    },
    -- Taller L shape
    {
        cost = 3,
        shape = {
            {0, 0}, {1, 0},
            {0, 1},
            {0, 2}
        }
    },
    -- S shape
    {
        cost = 5,
        shape = {
                    {1, 0},
            {0, 1}, {1, 1},
            {0, 2}
        }
    },
    -- T shape
    {
        cost = 4,
        shape = {
            {0, 0},
            {0, 1}, {1, 1},
            {0, 2}
        }
    },
    -- F shape (F's to anyone who gets this)
    {
        cost = 7,
        shape = {
                    {1, 0}, {2, 0},
            {0, 1}, {1, 1},
                    {1, 2}
        }
    },
    -- Square with piece sticking out
    {
        cost = 3,
        shape = {
            {0, 0}, {1, 0}, {2, 0},
            {0, 1}, {1, 1}
        }
    },
    -- Diagonal
    {
        cost = 5,
        shape = {
                    {1, 0}, {2, 0},
            {0, 1}, {1, 1},
            {0, 2}
        }
    },
    -- Square (needed for larger square-ish shapes
    {
        cost = 0,
        shape = {
            {0, 0}, {1, 0},
            {0, 1}, {1, 1},
        }
    }
}

-- New
randomizations.equipment_shapes = function(id)
    -- Use some basic shapes and stretch/rotate/reflect them as needed

    local cost_to_shapes = {}

    -- This is coded really lazily but it's okay to be inefficient
    -- It also adds the same shape many times, but that's whatever as well
    -- ~10 shapes, ~25 pt's max per shape, ~10*10*4*2 transformations each is 200k ops (at most), so probably not too many
    for shape_ind, shape_spec in pairs(basic_shapes) do
        local shape = shape_spec.shape
        local old_width = 0
        local old_height = 0
        for _, pt in pairs(shape) do
            old_width = math.max(old_width, pt[1] + 1)
            old_height = math.max(old_height, pt[2] + 1)
        end

        -- Horizontal stretch
        for hor = 1, 5 do
            -- Vertical stretch
            for vert = 1, 5 do
                -- Rotation
                for rot = 1, 4 do
                    -- Reflection (horizontal)
                    for ref = 1, 2 do
                        local new_shape = table.deepcopy(shape)
                        local width = old_width
                        local height = old_height

                        -- First, apply reflection
                        local reflected_shape = {}
                        for _, pt in pairs(new_shape) do
                            table.insert(reflected_shape, {width - pt[1] - 1, pt[2]})
                        end
                        new_shape = reflected_shape

                        local rotated_shape = {}
                        for _, pt in pairs(new_shape) do
                            -- Counterclockwise 90 degrees (I think)
                            if rot == 1 then
                                table.insert(rotated_shape, {height - pt[2] - 1, pt[1]})
                            elseif rot == 2 then
                                table.insert(rotated_shape, {width - pt[1] - 1, height - pt[2] - 1})
                            elseif rot == 3 then
                                table.insert(rotated_shape, {pt[2], width - pt[1] - 1})
                            elseif rot == 4 then
                                table.insert(rotated_shape, pt)
                            end
                        end
                        if rot == 1 or rot == 3 then
                            local temp = width
                            width = height
                            height = temp
                        end
                        new_shape = rotated_shape

                        local scaled_shape = {}
                        for _, pt in pairs(new_shape) do
                            for x = 1, hor do
                                for y = 1, vert do
                                    table.insert(scaled_shape, {hor * pt[1] + x - 1, vert * pt[2] + y - 1})
                                end
                            end
                        end
                        width = width * hor
                        height = height * vert
                        new_shape = scaled_shape

                        for _, pt in pairs(new_shape) do
                            if pt[1] >= width or pt[2] >= height then
                                error("Equipment shape overflow")
                            end
                        end

                        -- Reorder points
                        local hashed_pt_to_included = {}
                        for _, pt in pairs(new_shape) do
                            hashed_pt_to_included[width * pt[2] + pt[1]] = true
                        end
                        local reordered_shape = {}
                        for pt, _ in pairs(hashed_pt_to_included) do
                            table.insert(reordered_shape, {pt % width, math.floor(pt / width)})
                        end
                        new_shape = reordered_shape

                        -- Calculate a "cost" for the new shape, which factors number of points and awkwardness of shape
                        -- Points are 2 cost each, and awkwardness can add an integer amount of cost
                        -- Also factor in width and height
                        local cost = (2 * #shape + shape_spec.cost) * hor * vert + math.floor((width * width + height * height) / (3 * 3))

                        -- Add this shape as valid for all costs within a factor of 30%
                        for cost_ind = math.ceil(cost * 0.7), math.floor(cost * 1.3) do
                            if cost_to_shapes[cost_ind] == nil then
                                cost_to_shapes[cost_ind] = {}
                            end

                            table.insert(cost_to_shapes[cost_ind], {
                                type = "manual",
                                width = width,
                                height = height,
                                points = new_shape
                            })
                        end
                    end
                end
            end
        end
    end

    for equipment_class, _ in pairs(defines.prototypes.equipment) do
        if data.raw[equipment_class] ~= nil then
            for _, equipment in pairs(data.raw[equipment_class]) do
                if equipment.shape ~= nil then
                    -- Don't randomize equipment which does not have "full" type (maybe this is a bit hypocritical)
                    if equipment.shape.type == "full" then
                        local old_cost = 2 * equipment.shape.width * equipment.shape.height + math.floor((equipment.shape.width * equipment.shape.width + equipment.shape.height * equipment.shape.height) / (3 * 3))

                        local new_cost = randomize({
                            id = id,
                            prototype = equipment,
                            dummy = old_cost,
                            range = "small",
                            -- Keep same variance so it has higher chance of attaining min/max
                            dir = -1,
                            rounding = "discrete",
                            abs_min = 1
                        })

                        -- Choose from shapes with similar enough costs
                        if cost_to_shapes[new_cost] ~= nil then
                            local new_shape = cost_to_shapes[new_cost][rng.int(rng.key({id = id, prototype = equipment}), #cost_to_shapes[new_cost])]
                            equipment.shape = new_shape
                        end
                    end
                end
            end
        end
    end
end