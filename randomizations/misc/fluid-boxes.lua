local rng = require("lib/random/rng")
local pipe_conns = require("lib/pipe-conns")

randomizations.fluid_box_locations = function(id)
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

    -- Table of prototypes with possible fluid boxes
    local prot_fluid_box_props = {
        "boiler", -- fluid_box, output_fluid_box, energy_source
        "assembling-machine", -- fluid_boxes, energy_source
        "furnace", -- fluid_boxes, energy_source
        "rocket-silo", -- fluid_boxes, energy_source (note, rocket silos cannot be rotated)
        "pump", -- fluid_box, energy_source
        "fluid-turret", -- fluid_box
        "generator", -- fluid_box, energy_source
        "fusion-generator", -- input_fluid_box, output_fluid_box
        "fusion-reactor", -- input_fluid_box, output_fluid_box

        -- additional possible fluidbox randomization
        -- "storage-tank", -- fluid_box
        -- "offshore-pump", -- fluid_box, energy_source (needs support to not put connections on water)
        -- "mining-drill", -- input_fluid_box, output_fluid_box, energy_source (would need support to not overlap with vector_to_place_result)
        -- "thruster", -- fuel_fluid_box, oxidizer_fluid_box (would need support to not put pipe connections on back)
        -- "valve", -- fluid_box
        -- "pipe", -- fluid_box (not recommended, but technically possible, but also doesnt do anything most of the time. will break certain mods)
        -- "infinity-pipe", -- fluid_box (not recommended, but technically possible, but also doesnt do anything most of the time. will break certain mods)
        -- "pipe-to-ground", -- fluid_box (may break other mods)
        -- "heat-pipe", -- heat_buffer (not recommended, but technically possible, but also doesnt do anything most of the time)
        -- "heat-interface", -- heat_buffer (not recommended, but technically possible, but also doesnt do anything most of the time)

        -- only energy_source.fluid_box if a FluidEnergySource 
        "inserter",
        "agricultural-tower",
        "lab",
        "radar",
        "reactor",
        "loader",
    }

    -- Randomize input and output locations on boilers
    for _, class in pairs(prot_fluid_box_props) do
        for _, prototype in pairs(data.raw[class] or {}) do
            local fluid_boxes = {}
            local heat_connections = {}
            -- multiple fluid_boxes
            for _, fluid_box in pairs(prototype.fluid_boxes or {}) do fluid_boxes[#fluid_boxes + 1] = fluid_box end
            -- single fluid_box
            if prototype.fluid_box then fluid_boxes[#fluid_boxes + 1] = prototype.fluid_box end
            -- input fluid_box
            if prototype.input_fluid_box then fluid_boxes[#fluid_boxes + 1] = prototype.input_fluid_box end
            -- output fluid_box
            if prototype.output_fluid_box then fluid_boxes[#fluid_boxes + 1] = prototype.output_fluid_box end
            -- fuel fluid_box
            if prototype.fuel_fluid_box then fluid_boxes[#fluid_boxes + 1] = prototype.fuel_fluid_box end
            -- oxidizer fluid_box
            if prototype.oxidizer_fluid_box then fluid_boxes[#fluid_boxes + 1] = prototype.oxidizer_fluid_box end
            -- energy source fluid_box
            if prototype.energy_source and prototype.energy_source.type == "fluid" then fluid_boxes[#fluid_boxes + 1] = prototype.energy_source.fluid_box end
            -- energy source heat connections
            if prototype.energy_source and prototype.energy_source.type == "heat" then heat_connections[#heat_connections + 1] = prototype.energy_source.connections end
            -- energy source heat connections
            if prototype.heat_buffer then heat_connections[#heat_connections + 1] = prototype.heat_buffer.connections end

            -- First, test if this is appropriate to randomize
            local to_randomize = true
            for _, fluid_box in pairs(fluid_boxes) do to_randomize = to_randomize and validate_fluid_box(fluid_box) end

            if to_randomize then
                -- generate all possible connections (position and direction)
                local possible_connections = pipe_conns.get_possible_pipe_connections(prototype)
                -- duplicate, because they are the same
                local possible_underground_connections = table.deepcopy(possible_connections)

                -- shuffle normal connections
                rng.shuffle(rng.key({id = id}), possible_connections)
                -- shuffle underground connections separately, since they can overlap
                rng.shuffle(rng.key({id = id}), possible_underground_connections)

                -- update pipe connections for each fluidbox and type, just indexing shuffled generated pipe connections
                local i, j = 1, 1
                for _, fluid_box in pairs(fluid_boxes) do
                    for _, pipe_connection in pairs(fluid_box.pipe_connections) do
                        if pipe_connection.connection_type == "normal" or not pipe_connection.connection_type then
                            pipe_connection.position =  possible_connections[i].position
                            pipe_connection.direction = possible_connections[i].direction
                            i = i + 1
                        elseif pipe_connection.connection_type == "underground" then
                            pipe_connection.position =  possible_underground_connections[j].position
                            pipe_connection.direction = possible_underground_connections[j].direction
                            j = j + 1
                        end
                    end
                end
                for _, connections in pairs(heat_connections) do
                    for _, connection in pairs(connections) do
                        connection.position =  possible_connections[i].position
                        connection.direction = possible_connections[i].direction
                        i = i + 1
                    end
                end
            end
        end
    end
end