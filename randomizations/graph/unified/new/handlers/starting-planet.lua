local gutils = require("new-lib/graph/graph-utils")
local lu = require("new-lib/logic/lookup/init")

local starting_planets = {}

starting_planets.id = "starting_planet"

starting_planets.required = {
    ["claim"] = true,
    ["validate"] = true,
    ["reflect"] = true,
}

starting_planets.claim = function(graph, prereq, dep, trav)
    if dep.type == "room" then
        return 1
    end
end

starting_planets.validate = function(graph, slot, trav, extra)
    local slot_owner = gutils.get_conn_owner(graph, slot)
    local trav_owner = gutils.get_conn_owner(graph, trav)
    local room_struct = lu.rooms[trav_owner.name]
    if ((slot_owner.type == "starting-planet" or slot_owner.type == "space-location") and room_struct.type == "planet") or (slot_owner.type == "room-create-platform" and room_struct.type == "surface") then
        -- Help the randomizer decide to start on a different planet
        if slot_owner.type == "starting-planet" and room_struct.name == "nauvis" then
            return false
        end
        return true
    end

    return false
end

starting_planets.reflect = function(graph, trav_to_new_slot, trav_to_old_slot)
    -- Let's just do starting planet for now to see if this even works
    -- CRITICAL TODO: Expand/do space locations too
    -- TODO: Iterating over this whole thing each time is probably not efficient, should speed up and not pass all of trav_to_new_slot or smth
    for trav_key, slot in pairs(trav_to_new_slot) do
        local slot_owner = gutils.get_conn_owner(graph, slot)
        if slot_owner.type == "starting_planet" then
            local starting_planet_name = lu.rooms[gutils.get_conn_owner(graph, graph.nodes[trav_key]).name].name
            data.raw.planet.nauvis = table.deepcopy(data.raw.planet[starting_planet_name])
            data.raw.planet.nauvis.name = "nauvis"
        end
    end
end

return starting_planets