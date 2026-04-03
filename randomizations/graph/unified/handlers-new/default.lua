local default = {}

default.id = "default"

default.required = {
    ["with_replacement"] = true,
    ["claim"] = true,
    ["validate"] = true,
    ["reflect"] = true,
}

-- Whether to add a prereq back to the end of the list when it's used
default.with_replacement = true

-- How much later prereqs should be repeated to combat bias toward earlier ones
-- Makes prereqs in first quartile added once, in second quartile added twice, etc.
-- CRITICAL TODO: Unimplemented, seeing if needed
-- Seems like not needed, maybe don't do
--default.ending_bias = false

-- Whether to only check non-nil contexts when deciding context reachability
-- Mostly a hotfix for autoplace randomization due to connection logic in new first pass being broken
-- NOTE: I forget how it was "broken" but I think it was something to do with direct connections to rooms
default.ignore_nil_contexts = false

default.preprocess = function()
end

default.spoof = function(graph)
end

-- Mandatory
-- Returns a num_copies of each prereq/base to add (usually 1); falsey returns mean "not claimed"
-- Having num_copies more than one adds more prereqs to the pool for flexibility or to bias the pool one way
-- These extra copies are currently just added to the end rather than mixed in uniformly
-- The number 0 can be returned, in which case a new prereq won't be added, but the dep_node will still be counted as claimed/randomizable
-- The edge parameter is just to carry the edge's extra_info, if any
default.claim = function(graph, prereq, dep_node, edge)
end

-- Mandatory
default.validate = function(graph, base, head, extra)
end

-- Called when a prereq is claimed
default.process = function(graph, base, head)
end

-- Mandatory
default.reflect = function(graph, head_to_base, head_to_handler)
end

return default