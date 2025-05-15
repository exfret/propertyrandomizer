local rng = require("lib/random/rng")

-- TODO: Account for evenly spaced entities (on either axis)
-- TODO: Account for nil direction?
-- TODO: Test that normal fluid boxes are still an option (I'm not seeing them I think?)

randomizations.fluid_box_locations = function(id)
    local function get_pipe_conns(prototype, fluid_box_properties)
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
                        table.insert(fluid_box_directions, pipe_conn.direction)
                    end
                end
            end
        end
        -- Consider dummy fluid boxes
        if prototype.dummy_pipe_conns ~= nil then
            for _, dummy_pipe_conn in pairs(prototype.dummy_pipe_conns) do
                table.insert(pipe_conns, dummy_pipe_conn)
                table.insert(fluid_box_positions, dummy_pipe_conn.position)
                table.insert(fluid_box_directions, dummy_pipe_conn.direction)
            end
        end

        return {conns = pipe_conns, positions = fluid_box_positions, directions = fluid_box_directions}
    end

    local function add_dummy_pipe_conns(prototype, fluid_box_properties)
        local pipe_conn_info = get_pipe_conns(prototype, fluid_box_properties)

        -- Check if a new pipe connection would intersect an already made one
        -- Returns true if there is NO intersection (i.e.- position is valid for new fluid box)
        local function check_collision(proposed_position, old_positions)
            -- Simply test for each old position that the proposed position is at least 1 away in L1 norm
            for _, old_pos in pairs(old_positions) do
                if math.abs(old_pos[1] - proposed_position[1]) + math.abs(old_pos[2] - proposed_position[2]) < 1 then
                    return false
                end
            end
            return true
        end

        prototype.dummy_pipe_conns = {}

        -- We assume here that all fluid boxes are in reasonable positions (either between tiles or on tiles)
        -- Also assume collision boxes are reasonable/symmetric and exist
        -- Also assume pipe connection positions are given in numerical key form
        for y_side = 1, 2 do
            local direction
            local left_offset = 0
            local right_offset = 0
            local y_pos
            if y_side == 1 then
                direction = 0 -- North
                left_offset = 1
                y_pos = math.ceil(prototype.collision_box[y_side][2])
            else
                direction = 8 -- South
                right_offset = 1
                y_pos = math.floor(prototype.collision_box[y_side][2])
            end

            for x_pos = math.ceil(prototype.collision_box[1][1]) + left_offset, math.floor(prototype.collision_box[2][1]) - right_offset do
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
                up_offset = -1
                x_pos = math.ceil(prototype.collision_box[x_side][1])
            else
                direction = 4 -- East
                down_offset = -1
                x_pos = math.floor(prototype.collision_box[x_side][1])
            end

            for y_pos = math.ceil(prototype.collision_box[1][2]) + up_offset, math.floor(prototype.collision_box[2][2]) - down_offset do
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
    
    local function permute_fluid_boxes(key, prototype, fluid_box_properties)
        local pipe_conn_info = get_pipe_conns(prototype, fluid_box_properties)

        -- Shuffle the pipe connections, but nothing else
        rng.shuffle(pipe_conn_info.conns)

        for ind, pipe_conn in pairs(pipe_conn_info.conns) do
            pipe_conn.position = pipe_conn_info.positions[ind]
            pipe_conn.direction = pipe_conn_info.directions[ind]
        end
    end

    local function validate_fluid_box(fluid_box)
        -- Need to see if it ever defines positions, and that position is non-nil
        for _, pipe_conn in pairs(fluid_box.pipe_connections) do
            if pipe_conn.positions ~= nil then
                return false
            end
            if pipe_conn.position == nil then
                return false
            end
        end

        return true
    end

    -- Table of prototype to fluid box properties for every prototype with multiple fluid boxes
    -- If the property is the string "fluid_boxes", it's an array that gets filled in later
    local prot_fluid_box_props = {
        -- TODO: Storage tanks?
        ["boiler"] = {"fluid_box", "output_fluid_box"},
        ["assembling-machine"] = "fluid_boxes",
        ["furnace"] = "fluid_boxes",
        ["rocket-silo"] = "fluid_boxes",
        ["fusion-generator"] = {"input_fluid_box", "output_fluid_box"},
        ["fusion-reactor"] = {"input_fluid_box", "output_fluid_box"},
        -- Not mining drill, don't want to deal with the way it defines positions
        -- Not thruster, I'm afraid it will randomize to the back
    }

    -- Randomize input and output locations on boilers
    for class, fluid_box_properties in pairs(prot_fluid_box_props) do
        if data.raw[class] ~= nil then
            for _, prototype in pairs(data.raw[class]) do
                -- First, test if this is appropriate to randomize
                local to_randomize = true
                if fluid_box_properties == "fluid_boxes" then
                    if prototype["fluid_boxes"] == nil then
                        to_randomize = false
                    else
                        for _, fluid_box in pairs(prototype["fluid_boxes"]) do
                            if not validate_fluid_box(fluid_box) then
                                to_randomize = false
                            end
                        end
                    end
                else
                    for _, property in pairs(fluid_box_properties) do
                        if not validate_fluid_box(prototype[property]) then
                            to_randomize = false
                        end
                    end
                end

                if to_randomize then
                    -- Add dummy pipe connections to allow fluid boxes to go to new locations
                    add_dummy_pipe_conns(prototype, prot_fluid_box_props[prototype.type])

                    local key = rng.key({id = id, prototype = prototype})
                    permute_fluid_boxes(key, prototype, prot_fluid_box_props[prototype.type])

                    -- Delete dummy fluid boxes (not strictly necessary)
                    prototype.dummy_pipe_conns = nil
                end
            end
        end
    end
end