local build_graph = require("lib/graph/build-graph")
local graph_utils = require("lib/graph/graph-utils")
local helper = require("randomizations/graph/unified/helper")

local tile_pump_fluid = {}

tile_pump_fluid.source_types = {
    ["spawn-tile-surface"] = true
}
tile_pump_fluid.target_types = {
    ["create-fluid-offshore-surface"] = true
}
tile_pump_fluid.group_surfaces = false

tile_pump_fluid.add_dummies = function()
end

tile_pump_fluid.create_slot = function(edge)
    if edge[1].surface ~= edge[2].surface then
        return false
    end

    return {
        tile = edge[1].tile,
        fluid = edge[2].fluid,
        surface = edge[1].surface,
    }
end

tile_pump_fluid.create_traveler = function(edge)
    return {
        tile = edge[1].tile,
        fluid = edge[2].fluid,
        surface = edge[1].surface,
    }
end

tile_pump_fluid.to_canonical = function(slot_or_traveler)
    if slot_or_traveler.connector_type == "slot" then
        return graph_utils.getk("spawn-tile-surface", build_graph.compound_key({slot_or_traveler.tile, slot_or_traveler.surface}))
    elseif slot_or_traveler.connector_type == "traveler" then
        return graph_utils.getk("fluid-surface", build_graph.compound_key({slot_or_traveler.fluid, slot_or_traveler.surface}))
    end
end

tile_pump_fluid.is_reservable = function(slot)    
    if slot.fluid == "water" then
        return false
    end

    return true
end

tile_pump_fluid.traveler_priority = function(traveler)
    -- Just some educated guesses for what will get us out of softlocks for now
    if traveler.fluid == "water" --[[or traveler.fluid == "steam"]] then
        return 3
    elseif string.find(traveler.fluid, "oil") ~= nil or traveler.fluid == "lava" then
        return 2
    else
        return 1
    end
end

tile_pump_fluid.validate_connection = function(slot, traveler)
    if traveler.handler_id ~= "tile-pump-fluid" then
        return false
    end

    if traveler.fluid == nil then
        return false
    end
    if traveler.dummy then
        return false
    end

    -- Force lava not on vulcanus
    if slot.fluid == "lava" and traveler.fluid == "lava" then
        return false
    end

    return true
end

tile_pump_fluid.reflect = function(sorted_slots, slot_to_traveler)
    for _, slot in pairs(sorted_slots) do
        if slot.handler_id == "tile-pump-fluid" then
            -- Actually, just change the autoplace of the old tile (by changing every property of the other tile except autoplace and name), so that essentially we are changing where the fluid tiles spawn
            -- Doing a direct tile to create-fluid connection however is more convenient for the randomization process
            local traveler = slot_to_traveler[graph_utils.get_node_key(slot)]
            if traveler ~= nil then
                local old_tile = data.raw.tile[slot.tile]
                local new_tile = table.deepcopy(old_tile)
                new_tile.name = travler.tile
                new_tile.autoplace = data.raw.tile[traveler.tile].autoplace
                data.raw.tile[traveler.tile] = new_tile
            end
        end
    end
end

return tile_pump_fluid