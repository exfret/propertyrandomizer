local build_graph = require("lib/graph/build-graph")
local graph_utils = require("lib/graph/graph-utils")
local helper = require("randomizations/graph/unified/helper")

-- This file demonstrates the default layout of a handler
-- It's not just for show though! Fields not in the required_fields table are automatically populated with the functions here if not defined/overrided by a handler

local default = {}

-- Note that default's implementation of all the fields here aren't used since they're always mandatory; they're just here for demonstration purposes
default.required_fields = {
    ["source_types"] = true,
    ["target_types"] = true,
    ["group_surfaces"] = true,
    ["to_canonical"] = true,
    ["traveler_priority"] = true,
    ["validate_connection"] = true,
    ["reflect"] = true,
}

-- State is some pointers to extra info created by execute.lua, which calls the handlers
-- It's often big tables that we wouldn't want to create inside each handler, like top_sort's
default.state = {}
default.init = function(state)
    for k, v in pairs(state) do
        default.state[k] = v
    end
end

-- Any edges with source in source_types and target in target_types is considered for randomization
-- We can add extra conditions, but any such edge *could* be randomized by this handler, and as problems might arise if multiple handlers try to touch the same edge, try not to allow any common source --> target types in different handlers
default.source_types = {
}
default.target_types = {
}
-- Does this handler involve nodes with surface-specific variants that we need to account for?
-- A good example is anything 
default.group_surfaces = false

-- Pre-surgery allows handlers to separate out edges in the dependency graph or otherwise modify it as necessary before anything else happens
default.presurgery = function()
end

-- Dummies are extra slots (and travelers) to help smoothen the randomization process; they correspond to "virtual" recipes/etc. that we create later if needed
-- Dummies are manually put at the end of topological sorts so that they are only used if necessary
default.add_dummies = function()
    -- By default, we add no dummies
end

-- This function creates a slot
-- Most of the fields for a slot are filled out in execute.lua already, so a lot of the time we just return an empty table
-- This function also often tests to see if a given edge is valid to be randomized, and if not just returns false rather than an empty table
-- TODO: Split this test out to a separate function (I think that would be more intuitive)
default.create_slot = function(edge)
    return {}
end

-- This function creates a traveler
-- Also is usually an empty table
default.create_traveler = function(edge)
    return {}
end

-- This table takes a slot or traveler from this handler and returns the "concrete" type of node it is
-- For example, in recipe result randomization, when given a traveler, it wouldn't return the craft-material node, but rather the item node (crafting something isn't a literal "thing" in the game; items are)
default.to_canonical = function(slot_or_traveler)
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
    -- This is what it normally looks like, though traveler_priority is mandatory so this implementation doesn't matter
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