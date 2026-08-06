local analysis = {}

-- Should include:
--   Landfill/other buildability/movability
--   Circuits
--   Logi chests/robots
--   Automated trains
analysis.get_important_node_keys = function()
    -- Get things that should retain all their contexts
    -- Let's actually just assume for now that something having context somewhere is enough
    -- TODO
end

return analysis