-- TODO: When we get into caring about automatability, especially when adding recipe ingredients, we might want to give a closer eye to this
-- Since spoiling has item ins/outs along with recipe ingredients/results, they can share prereqs, so when we get there we'd want to keep an eye on making sure the automatable things stay with the recipes
-- TODO: Need to make sure you can also get rid of spoilage (maybe also a future problem)
-- Prevent rocket parts/blueprints and some special items (what counts as special other than rocket parts?)
-- TODO: Do a quick look through item subgroups/spawnables just to see anything that might need to be blacklisted

local gutils = require("new-lib/graph/graph-utils")

local spoiling = {}

spoiling.id = "spoiling"

-- We'll probably need spoofing? I'll leave it here because it might become relevant sooner rather than later.
spoiling.spoof = function(graph)
end

spoiling.claim = function(graph, prereq, dep, trav)
    -- Spoiling is the only item --> item connection right now
    if prereq.type == "item" and dep.type == "item" then
        return true
    end
end

spoiling.validate = function(graph, slot, trav, extra)
    -- Just allow anything for now
    local slot_owner = gutils.get_conn_owner(graph, slot)
    if slot_owner.type == "item" then
        return true
    else
        return false
    end
end

spoiling.reflect = function(graph, trav_to_new_slot, trav_to_handler)
    for trav_key, slot in pairs(trav_to_new_slot) do
        if trav_to_handler[trav_key].id == "spoiling" then
        end
    end
end

return spoiling