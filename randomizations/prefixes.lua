-- Add input fluid boxes to all mining drills that don't already have them

local pipe_conns = require("lib/pipe-conns")

for _, drill in pairs(data.raw["mining-drill"]) do
    if drill.input_fluid_box == nil then
        pipe_conns.add_dummy_pipe_conns(drill, {"input_fluid_box", "output_fluid_box"})
        local pipe_conn_to_use = drill.dummy_pipe_conns[1]
        pipe_conn_to_use.flow_direction = "input"

        drill.input_fluid_box = {
            volume = 200,
            pipe_connections = {pipe_conn_to_use},
            production_type = "input",
        }

        -- Delete dummy fluid boxes
        drill.dummy_pipe_conns = nil
    else
        -- Make sure drills don't have input fluid box filters
        drill.input_fluid_box.filter = nil
    end
end

-- Add fluid box connections to assembling machine 1, if it doesn't already have some added by another mod
local assm1 = data.raw["assembling-machine"]["assembling-machine-1"]
local assm2 = data.raw["assembling-machine"]["assembling-machine-2"]
if assm1 ~= nil and assm2 ~= nil then
    if assm1.fluid_boxes == nil or #assm1.fluid_boxes == 0 then
        if assm2.fluid_boxes ~= nil and #assm2.fluid_boxes > 0 then
            assm1.fluid_boxes_off_when_no_fluid_recipe = true
            assm1.fluid_boxes = table.deepcopy(assm2.fluid_boxes)
            table.insert(assm1.crafting_categories, "crafting-with-fluid")
        end
    end
end