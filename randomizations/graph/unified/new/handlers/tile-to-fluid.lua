-- Doesn't make any changes in prereq shuffle now until more interesting paths are suggested

local gutils = require("new-lib/graph/graph-utils")

local tile_to_fluid = {}

-- Claim edges from tile-fluid to fluid-create-offshore
tile_to_fluid.claim = function(graph, prereq, dep, trav)
    if prereq.type == "tile-fluid" and dep.type == "fluid-create-offshore" then
        return 1
    end
end

tile_to_fluid.validate = function(graph, slot, trav, extra)
    local slot_owner = gutils.get_conn_owner(graph, slot)
    if slot_owner.type == "tile-fluid" then
        return true
    end
end

-- Apply tile fluid changes to data.raw
tile_to_fluid.reflect = function(graph, trav_to_new_slot, trav_to_old_slot)
    for trav_key, slot in pairs(trav_to_new_slot) do
        local trav = graph.nodes[trav_key]
        local trav_owner = gutils.get_conn_owner(graph, trav)
        local slot_owner = gutils.get_conn_owner(graph, slot)

        -- Only process our edge type
        if trav_owner.type == "fluid-create-offshore" and slot_owner.type == "tile-fluid" then
            local fluid_name = trav_owner.name
            local tile_name = slot_owner.name
            local tile = data.raw.tile[tile_name]
            if tile then
                tile.fluid = fluid_name
            end
        end
    end
end

return tile_to_fluid
