-- Coal's fuel belongs to its position (user, 2026-09-26): whatever item replaces coal becomes a fuel like coal (dutils.replacement_gets_fuel, dutils.give_replacement_fuel)
-- So first pass keeps coal's fuel edge on coal's slot, which also reaches every room the slot's item is delivered to; when a proof needs that fuel elsewhere, monotone matching only asks the slot for a launchable identity (needs_from_proof)
-- Coal's identity is still a fuel wherever it goes, but it gets its own fuel edge only while it's matched away from coal's slot
-- With that edge on coal's slot as well, proofs credited fuel shipped to other planets to coal's identity (on another planet its edge comes a step before the slot's), so coal was pinned to Nauvis's earliest slots: one of its starting patches mined coal in 7 of 12 games (user, 2026-10-07)
-- Plain Lua over the graph utilities, so test-replacement-fuel.lua can check it

local gutils = require("lib/graph/graph-utils")

local replacement_fuel = {}

-- Connects what follows a slot/trav pair (first pass's connect_extra): coal's identity matched to any slot but coal's gets its own fuel edge
-- identity_fuel: trav key --> the fuel node its identity provides on its own (coal's identity only)
replacement_fuel.connect = function(graph, slot_key, trav_key, identity_fuel)
    local fuel_key = identity_fuel[trav_key]
    if fuel_key ~= nil and graph.nodes[trav_key].old_slot ~= slot_key then
        gutils.add_edge(graph, trav_key, fuel_key)
    end
end

return replacement_fuel
