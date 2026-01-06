local default = {}

default.required = {
    ["claim"] = true,
    ["validate"] = true,
    ["reflect"] = true,
}

-- Just handles data.raw
default.preprocess = function()
end

default.spoof = function(graph)
end

-- Mandatory
-- Returns a num_copies, which is zero if it doesn't claim the edge
-- If nil is returned, it's automatically interpreted as zero
-- The num_copies adds more prereqs to the pool for flexibility
-- The trav is just to carry the edge's extra_info, if any
default.claim = function(graph, prereq, dep, trav)
end

-- Mandatory
default.validate = function(graph, slot, trav, extra)
end

-- Mandatory
default.reflect = function(graph, trav_to_new_slot, trav_to_old_slot)
end

return default