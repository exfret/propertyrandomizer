local default = {}

default.id = "default"

default.required = {
    ["claim"] = true,
    ["validate"] = true,
    ["reflect"] = true,
}

default.preprocess = function()
end

default.spoof = function(graph)
end

-- Mandatory
-- Returns a num_copies of each prereq to add (usually 1); 0 or nil means "not claimed"
-- Having num_copies more than one adds more prereqs to the pool for flexibility
-- The trav is just to carry the edge's extra_info, if any
default.claim = function(graph, prereq, dep, trav)
end

-- Mandatory
default.validate = function(graph, slot, trav, extra)
end

-- Called when a prereq is claimed
default.process = function(graph, slot, trav)
end

-- Mandatory
default.reflect = function(graph, trav_to_new_slot, trav_to_handler)
end

return default