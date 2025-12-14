local build_graph = require("lib/graph/build-graph")
local graph_utils = require("lib/graph/graph-utils")
local helper = require("randomizations/graph/unified/helper")

-- I assumed for this randomization that tiles were unique to surfaces, but it might be good to remove that assumption

local surface_tile = {}

surface_tile.source_types = {
    ["surface"] = true
}
surface_tile.target_types = {
    ["spawn-tile-surface"] = true
}
surface_tile.group_surfaces = false

surface_tile.create_slot = function(edge)
    return {
        old_tile = edge[2].tile,
        surface = edge[1].name,
    }
end

-- CRITICAL TODO: Need to figure out some way of easily "switching surfaces"
surface_tile.create_traveler = function(edge)
    return {
        tile = edge[2].tile,
        surface = edge[1].name,
    }
end

surface_tile.to_canonical = function(slot_or_traveler)
    if slot_or_traveler.connector_type == "slot" then
        return graph_utils.getk("surface", slot_or_traveler.surface)
    else
        return graph_utils.getk("spawn-tile-surface", build_graph.compound_key({slot_or_traveler.tile, slot_or_traveler.surface}))
    end
end

surface_tile.is_reservable = function(slot)
    return true
end

surface_tile.traveler_priority = function(traveler)
    if traveler.fluid == "water" then
        return 3
    elseif traveler.fluid ~= nil then
        return 2
    end
    return 1
end

surface_tile.validate_connection = function(slot, traveler)
    if traveler.tile == nil then
        return false
    end

    return true
end

surface_tile.reflect = function(sorted_slots, slot_to_traveler)
    local new_tiles = {}
    for _, slot in pairs(sorted_slots) do
        if slot.handler_id == "surface-tile" then
            local traveler = slot_to_traveler[graph_utils.get_node_key(slot)]
            if traveler ~= nil then
                -- We want the tile in slot to have traveler's autoplace
                -- Instead, we'll just make a new tile that has traveler's name and autoplace, but everything else is from slot
                -- TODO: I did this because I didn't want to change the keys in planets for autoplace control and such, but this could mess other references up, so fix it later
                local slot_tile = data.raw.tile[slot.old_tile]
                local traveler_tile = data.raw.tile[traveler.tile]
                local new_tile = table.deepcopy(slot_tile)
                new_tile.name = traveler_tile.name
                new_tile.autoplace = traveler_tile.autoplace
                new_tiles[new_tile.name] = new_tile
            end
        end
    end
    -- Update data.raw.tile
    for tile_name, tile in pairs(new_tiles) do
        data.raw.tile[tile_name] = tile
    end
end

return surface_tile