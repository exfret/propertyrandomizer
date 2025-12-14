local build_graph = require("lib/graph/build-graph")
local graph_utils = require("lib/graph/graph-utils")
local helper = require("randomizations/graph/unified/helper")

-- TODO

local planet_water_tile = {}

-- Any edges with source in source_types and target in target_types is considered for randomization
-- We can add extra conditions, but any such edge *could* be randomized by this handler, and as problems might arise if multiple handlers try to touch the same edge, try not to allow any common source --> target types in different handlers
planet_water_tile.source_types = {
    ["offshore-pump-fluid-surface"] = true
}
planet_water_tile.target_types = {
    ["create-fluid-surface"] = true
}
planet_water_tile.group_surfaces = false

local planet_names = {
    "nauvis",
    "fulgora",
    "gleba",
    "vulcanus",
    "aquilo"
}
local is_planet = {}
for _, planet_name in pairs(planet_names) do
    is_planet[build_graph.compound_key({"planet", planet_name})] = true
end

planet_water_tile.presurgery = function()
    build_graph.ops["offshore-pump-fluid-surface"] = "OR"
    for surface_name, surface in pairs(build_graph.surfaces) do
        if is_planet[surface_name] then
            local water_tile_node = helper.create_dummy_node("offshore-pump-fluid-surface", surface_name)

        end
    end
end

planet_water_tile.add_dummies = function()
end

planet_water_tile.create_slot = function(edge)
    if not is_planet[edge[1].name] then
        return false
    end

    return {}
end

planet_water_tile.create_traveler = function(edge)


    return {}
end

default.to_canonical = function(slot_or_traveler)
    if slot_or_traveler.connector_type == "slot" then

    end
end

-- One part of unified randomization is that travelers not yet reachable can "reserve" slots for when they do become reachable
-- This actually helps the randomization process, because if we get stuck, we can undo a reservation and put a "more important" traveler there instead without having to do any special backtracking logic
-- No extra logic is necessary because we don't actually make the traveler reachable until it would normally be reachable still, so booting it out doesn't undo any reachability anyways
default.is_reservable = function(slot)
    -- Dummies are basically made to have extra reservable slots, so we definitely want to return true for those
    if slot.dummy then
        return true
    end

    -- By default, just check if the node this slot has been connected to is on the critical path, or if any of its surface variants are (if so, then we don't allow it to be reserved/have progression breaking travelers)
    -- It isn't necessarily more important to have slots on the critical path respect progression more, but we need some number of slots to respect progression to prevent softlocks, and those on the critical path seem like a good choice
    local slot_node = slot.edge[1]
    if default.state.is_critical[graph_utils.get_node_key(slot_node)] then
        return false
    end
    -- Check for surface variant criticality too
    if build_graph.ops[slot_node.type .. "-surface"] ~= nil then
        local surface_slot_nodes = helper.get_surface_variants(slot_node)
        for _, node in pairs(surface_slot_nodes) do
            if default.state.is_critical[graph_utils.get_node_key(node)] then
                return false
            end
        end
    end
    
    return true
end

-- Traveler priority measures how likely a traveler is to fix our problems if we get in a bind
-- Unlike is_reservable, this is more important to get right; we want the randomizer to have a good idea of how to progress!
-- When it gets stuck, it chooses a reachable traveler with the highest priority to boot out the most recent reservation; for this reason, even a little priority bump goes a long ways
-- Follow these general rules:
--    -1 means unlocks literally nothing (like a dummy)
--     0 means generally doesn't help progress things further
--     1 means may lead to an extra item but not usually a new science pack or anything
--     2 means has important qualities, like surface specificity, or is a major component to important progression
--     3 means this is basically required to come quickly, like a science pack or electricity components early on
-- I wonder also if I should have even fewer levels (in particular, combining levels 2 and 3) or do things a slightly different way, but I'm trying this out for now
default.traveler_priority = function(traveler)
    return helper.find_priority(traveler, default.state)
end

-- This checks if this slot accepts this traveler
-- Right now, I'm keeping this to mostly just checking that things are of the right types (so like a recipe-ingredients slot should accept only recipe-like travelers)
-- This is mandatory anyways, because the type of connections that should occur are not always obvious based on source and target types (for example, recipe-results accepts travelers that are items or fluids, not just craft-materials)
default.validate_connection = function(slot, traveler)
end

-- This is the "fun" part full of lots of special cases and ad hoc fixes, yay! We reflect our changes onto data.raw, creating new ingredients, modifying recipes, mucking with autoplace, and adding hotfixes
-- I'm wondering if reflection should be done all at once as a separate step rather than handled by each slot individually
-- In item randomization, for example, we need to first gather the changes, so like an item that spoils into one thing being changed might cause that new item to see it needs to be changed again wrongly
-- However, as long as we detect what needs to be changed from the graph rather than from data.raw, I think we're good
default.reflect = function(sorted_slots, slot_to_traveler)
end

return default