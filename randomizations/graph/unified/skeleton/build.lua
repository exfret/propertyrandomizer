-- Builds the witness skeleton: the union of witnesses (backward paths) for the pebbles we require to stay reachable
-- See docs/glossary.md for terminology (skeleton, witness, mechanic context, earliest-provider rule)
-- Witnesses are traced with top.path, which already implements the earliest-provider rule for ORs

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/consistent-sort")

local key = gutils.key

local build = {}

-- Nodes that exist only as graph plumbing, not as things the player needs to reach
local plumbing_types = {
    ["base"] = true,
    ["head"] = true,
    ["orand"] = true,
}

-- Every pebble of every mechanic node, i.e. all mechanic contexts
build.mechanic_goal_inds = function(graph, sort_info)
    local goal_inds = {}
    for ind, pebble in pairs(sort_info.sorted) do
        local node = graph.nodes[pebble.node_key]
        if node.mechanic and node.type ~= "orand" then
            table.insert(goal_inds, ind)
        end
    end
    return goal_inds
end

-- Earliest pebble of each non-plumbing node that has no pebble in in_skeleton yet
-- Used to add "reachable somewhere" requirements on top of the mechanic contexts
build.somewhere_goal_inds = function(graph, sort_info, in_skeleton)
    local goal_inds = {}
    for node_key, context_inds in pairs(sort_info.node_to_context_inds) do
        local node = graph.nodes[node_key]
        if node ~= nil and not plumbing_types[node.type] and not node.spoof then
            local covered = false
            local earliest
            for _, ind in pairs(context_inds) do
                if in_skeleton[ind] then
                    covered = true
                    break
                end
                if earliest == nil or ind < earliest then
                    earliest = ind
                end
            end
            if not covered and earliest ~= nil then
                table.insert(goal_inds, earliest)
            end
        end
    end
    return goal_inds
end

-- Returns { inds = list of sort inds in the skeleton, in_skeleton = ind --> true }
build.skeleton = function(graph, sort_info, goal_inds)
    -- top.path extends its goal list in place, so pass a copy
    local path_info = top.path(graph, table.deepcopy(goal_inds), sort_info)
    return {
        inds = path_info.path,
        in_skeleton = path_info.in_path,
    }
end

return build
