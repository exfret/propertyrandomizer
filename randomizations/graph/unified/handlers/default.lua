local default = {}

default.id = "default"

default.required = {
    ["with_replacement"] = true,
    ["initialize"] = true,
    ["claim"] = true,
    ["validate"] = true,
    ["reflect"] = true,
}

-- Whether to add a prereq back to the end of the list when it's used
default.with_replacement = true
-- Whether to put extra copies with the same priority or at the end (default at the end)
default.uniform_copies = false
-- Chance that a head first tries the bases that keep its old connection, as stays says (see the prereq shuffle in execute.lua); 0 never does
default.stay_chance = 0
-- Whether connecting base to head keeps head's old connection, for stay_chance
default.stays = function(graph, base, head)
    return false
end

-- How much later prereqs should be repeated to combat bias toward earlier ones
-- Makes prereqs in first quartile added once, in second quartile added twice, etc.
-- TODO: Unimplemented, seeing if needed
-- Seems like not needed, maybe don't do
--default.ending_bias = false

-- Whether to only check non-nil contexts when deciding context reachability
-- Mostly a hotfix for autoplace randomization due to connection logic in new first pass being broken
-- NOTE: I forget how it was "broken" but I think it was something to do with direct connections to rooms
default.ignore_nil_contexts = false

-- For setting local module vars back to defaults
default.initialize = function()
end

default.preprocess = function()
end

default.spoof = function(graph)
end

-- Mandatory
-- Returns a num_copies of each prereq/base to add (usually 1); falsey returns mean "not claimed"
-- Having num_copies more than one adds more prereqs to the pool for flexibility or to bias the pool one way
-- These extra copies are currently just added to the end rather than mixed in uniformly
-- The number 0 can be returned, in which case a new prereq won't be added, but dep will still be counted as claimed/randomizable
-- The edge parameter is just to carry the edge's extra_info, if any
default.claim = function(graph, prereq, dep, edge)
end

-- Called once promotion has promised the mechanics and before any head is randomized, for decisions a handler makes for every dependent up front, like the shapes recipes take (lib/recipe-shape.lua), with promotion's state (params.promotion, nil without promotion) to keep the model honest; params also carry random_graph, sorted_deps, split_graph and trav_to_slot (first pass's, or nil), and do_first_pass
default.before_heads = function(params)
end

-- Called with first pass and promotion, before promotion ranks anything, for heads whose new base is chosen up front and checked on the whole game instead of by promotion's fixed ranks
-- That suits a head whose vanilla base is free (like a resource needing no mining fluid): its dependent can take a later base only if that base happens to sort before the dependent, which one random order rarely shows
-- params: heads (this handler's heads of randomized dependents), pool (its shuffled bases), random_graph, baseline_sort (first pass's sort of the game), and sort_without(node keys), a sort of the game (first pass's graph, with earlier handlers' up-front choices) where those AND nodes can't be reached
-- Returns head key --> base key for the heads it decided (promotion starts from them, and the shuffle leaves them alone)
default.choose_up_front = function(params)
    return {}
end

-- Allows for defining a function for the handler to do the prereq search on a dependent themselves
-- Required for more advanced handlers like the one for recipe ingredients
default.custom_prereq_search = false

-- Mandatory (though can be empty for handlers with custom prereq searches)
default.validate = function(graph, base, head, extra)
end

-- Called when a prereq is claimed
default.process = function(graph, base, head)
end

-- Abilities of the edge connecting a base to one of this handler's heads (see gutils.connect_base_head), which promotion uses when reasoning
-- By default a base keeps its original edge's abilities, which fits edges whose abilities come from how their prereq is gotten
default.connection_abilities = function(base, head)
    return base.abilities
end

-- Mandatory
default.reflect = function(graph, head_to_base, head_to_handler)
end

-- Called once every handler's reflect changes have been applied to data.raw, for fixes that need the final game
default.after_changes = function()
end

return default