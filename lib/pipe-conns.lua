local pipe_conns = {}

pipe_conns.get_pipe_conns = function(prototype, fluid_box_properties)
    local fluid_box_obj
    local fluid_box_keys
    if fluid_box_properties == "fluid_boxes" then
        fluid_box_obj = prototype["fluid_boxes"]
        fluid_box_keys = {}
        for ind, _ in pairs(prototype.fluid_boxes) do
            table.insert(fluid_box_keys, ind)
        end
    else
        fluid_box_obj = prototype
        fluid_box_keys = fluid_box_properties
    end

    local pipe_conns = {}
    local fluid_box_positions = {}
    local fluid_box_directions = {}

    for _, key in pairs(fluid_box_keys) do
        if fluid_box_obj[key] ~= nil then
            for ind, pipe_conn in pairs(fluid_box_obj[key].pipe_connections) do
                if pipe_conn.position ~= nil then
                    table.insert(pipe_conns, pipe_conn)
                    table.insert(fluid_box_positions, pipe_conn.position)
                    table.insert(fluid_box_directions, pipe_conn.direction or "input-output")
                end
            end
        end
    end
    -- Consider dummy fluid boxes
    if prototype.dummy_pipe_conns ~= nil then
        for _, dummy_pipe_conn in pairs(prototype.dummy_pipe_conns) do
            table.insert(pipe_conns, dummy_pipe_conn)
            table.insert(fluid_box_positions, dummy_pipe_conn.position)
            table.insert(fluid_box_directions, dummy_pipe_conn.direction or "input-output")
        end
    end

    return {conns = pipe_conns, positions = fluid_box_positions, directions = fluid_box_directions}
end

pipe_conns.add_dummy_pipe_conns = function(prototype, fluid_box_properties)
    local pipe_conn_info = pipe_conns.get_pipe_conns(prototype, fluid_box_properties)

    -- Check if a new pipe connection would intersect an already made one
    -- Returns true if there is NO intersection (i.e.- position is valid for new fluid box)
    local function check_collision(proposed_position, old_positions)
        -- Simply test for each old position that the proposed position is at least 1 away in L1 norm
        for _, old_pos in pairs(old_positions) do
            if math.abs(old_pos[1] - proposed_position[1]) + math.abs(old_pos[2] - proposed_position[2]) < 1 then
                return false
            end
        end
        -- Check heat connection positions
        if prototype.energy_source ~= nil and prototype.energy_source.type == "heat" then
            for _, old_pos in pairs(prototype.energy_source.connections) do
                if math.abs(old_pos.position[1] - proposed_position[1]) + math.abs(old_pos.position[2] - proposed_position[2]) < 1 then
                    return false
                end
            end
        end
        return true
    end

    prototype.dummy_pipe_conns = {}

    -- We assume here that all fluid boxes are in reasonable positions (either between tiles or on tiles)
    -- Also assume collision boxes are reasonable/symmetric and exist
    -- Also assume pipe connection positions are given in numerical key form
    local horiz_shift = 0.5 - 0.5 * (math.ceil(prototype.collision_box[2][1] - prototype.collision_box[1][1]) % 2)
    local vert_shift = 0.5 - 0.5 * (math.ceil(prototype.collision_box[2][2] - prototype.collision_box[1][2]) % 2)
    for y_side = 1, 2 do
        local direction
        local left_offset = 0
        local right_offset = 0
        local y_pos
        if y_side == 1 then
            direction = 0 -- North
            left_offset = 1
            y_pos = prototype.collision_box[y_side][2] + 0.1
        else
            direction = 8 -- South
            right_offset = 1
            y_pos = prototype.collision_box[y_side][2] - 0.1
        end

        for x_pos = math.ceil(prototype.collision_box[1][1] - horiz_shift) + horiz_shift + left_offset, math.floor(prototype.collision_box[2][1] - horiz_shift) + horiz_shift - right_offset do
            local proposed_position = {x_pos, y_pos}

            if check_collision(proposed_position, pipe_conn_info.positions) then
                table.insert(prototype.dummy_pipe_conns, {
                    position = proposed_position,
                    direction = direction
                })
            end
        end
    end
    for x_side = 1, 2 do
        local direction
        local up_offset = 0
        local down_offset = 0
        local x_pos
        if x_side == 1 then
            direction = 12 -- West
            up_offset = 1
            x_pos = prototype.collision_box[x_side][1] + 0.1
        else
            direction = 4 -- East
            down_offset = 1
            x_pos = prototype.collision_box[x_side][1] - 0.1
        end

        for y_pos = math.ceil(prototype.collision_box[1][2] - vert_shift) + vert_shift + up_offset, math.floor(prototype.collision_box[2][2] - vert_shift) + vert_shift - down_offset do
            local proposed_position = {x_pos, y_pos}

            if check_collision(proposed_position, pipe_conn_info.positions) then
                table.insert(prototype.dummy_pipe_conns, {
                    position = proposed_position,
                    direction = direction
                })
            end
        end
    end

    -- The values are given in the modified prototype, so we don't need to return anything
end

return pipe_conns