local rng = require("lib/random/rng")

-- Inserter offsets are randomized by just choosing from a list
randomizations.inserter_offsets = function(id)
    local insert_positions = {
        {0, 1.2}, -- Standard
        {0, 0.8}, -- Near
        {0, 2.2}, -- Far
        {0, 4.2}, -- Very far
        {-0.98, 0}, -- To the side
        {0.98, 0.98}, -- Diagonal
    }
    local pickup_positions = {
        {0, -0.98}, -- Standard
        {0, -1.98}, -- Long-handed
        {0, -3.98}, -- Very long-handed
        {0.98, 0}, -- To the side
        {-0.98, -0.98}, -- Diagonal
        {-1.2, -0.2}, -- Diagonal, sorta?
        {-2.2, 7.2} -- Huh?
    }

    for _, inserter in pairs(data.raw.inserter) do
        -- Only do "normal-size" inserters, bigger collision boxes can break things
        if inserter.collision_box ~= nil and inserter.collision_box[1][1] == -0.15 and inserter.collision_box[1][2] == -0.15 and inserter.collision_box[2][1] == 0.15 and inserter.collision_box[2][2] == 0.15 then
            local key = rng.key({id = id, prototype = inserter})
            
            -- This is a random variable used to determine both the change in insert and in pickup position
            local pos_var = rng.range(key, 1, 9)

            -- 5/9 chance each to change to a different type of insert/pickup position
            -- Notice that these events are not independent

            if 1 <= pos_var and pos_var <= 5 then
                inserter.insert_position = insert_positions[rng.int(key, #insert_positions)]
            end

            if 2 <= pos_var and pos_var <= 6 then
                inserter.pickup_position = pickup_positions[rng.int(key, #pickup_positions)]
            end
        end
    end
end

randomizations.mining_drill_offsets = function(id)
    for _, mining_drill in pairs(data.raw["mining-drill"]) do
        -- Don't randomize fluid output positions
        if mining_drill.output_fluid_box == nil then
            local key = rng.key({id = id, prototype = mining_drill})

            -- Just make it a random amount farther away up to the collision box size
            if mining_drill.collision_box ~= nil then
                collision_box_size = math.ceil(mining_drill.collision_box[2][1] - mining_drill.collision_box[1][1])
                mining_drill.vector_to_place_result[2] = mining_drill.vector_to_place_result[2] - rng.float_range(key, 0, collision_box_size)
            end
        end
    end
end