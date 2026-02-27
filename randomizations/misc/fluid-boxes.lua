local rng = require("lib/random/rng")
local pipe_conns = require("lib/pipe-conns")

randomizations.fluid_box_locations = function(id)
    local function permute_fluid_boxes(key, prototype, fluid_box_properties)
        local pipe_conn_info = pipe_conns.get_pipe_conns(prototype, fluid_box_properties)

        -- Shuffle the pipe connections, but nothing else
        rng.shuffle(rng.key({id = id}), pipe_conn_info.conns)

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
        ["boiler"] = {"fluid_box", "output_fluid_box"},
        ["assembling-machine"] = "fluid_boxes",
        ["furnace"] = "fluid_boxes",
        ["rocket-silo"] = "fluid_boxes",
        -- I'm not sure about these yet
        --["fusion-generator"] = {"input_fluid_box", "output_fluid_box"},
        --["fusion-reactor"] = {"input_fluid_box", "output_fluid_box"},
        -- These don't rotate/display nicely
        --["storage-tank"] = {"fluid_box"},
        --["generator"] = {"fluid_box"}
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
                    pipe_conns.add_dummy_pipe_conns(prototype, prot_fluid_box_props[prototype.type])

                    local key = rng.key({id = id, prototype = prototype})
                    permute_fluid_boxes(key, prototype, prot_fluid_box_props[prototype.type])

                    -- Delete dummy fluid boxes
                    prototype.dummy_pipe_conns = nil
                end
            end
        end
    end
end