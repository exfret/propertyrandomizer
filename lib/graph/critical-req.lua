local top_sort = require("lib/graph/top-sort")
local rng = require("lib/random/rng")
local graph_utils = require("lib/graph/graph-utils")

local critical_req = {}

-- O(edges). If the target_node is reachable, this returns a critical_requirement set of nodes from a set of target_node_types such that:
-- if all nodes in the critical_requirement set are reachable, and prereqs of node types outside of target_node_types stay the same,
-- then the target_node must be reachable.
critical_req.critical_requirement = function (target_node, target_node_types, graph)
    local sort_state = top_sort.sort(graph, nil, nil, nil, { randomized = true, key = rng.key{ id = "critical_requirement" } })
    local target_node_key = graph_utils.get_node_key(target_node)
    assert(sort_state.reachable[target_node_key])

    local ordinals = {}
    for i, node in pairs(sort_state.sorted) do
        ordinals[graph_utils.get_node_key(node)] = i
    end
    ordinals.MAX = sort_state.curr_ind
    local get_ordinal = function (key)
        return ordinals[key] or ordinals.MAX
    end
    for _, node in pairs(sort_state.sorted) do
        table.sort(node.prereqs, function(a, b)
            return get_ordinal(graph_utils.get_node_key(a))
                < get_ordinal(graph_utils.get_node_key(b))
        end)
    end

    local node_queue = { target_node_key }
    local node_queue_front = 1
    local discovered = { [target_node_key] = true }

    local discover_prereq = function (prereq)
        local prereq_key = graph_utils.get_node_key(prereq)
        if not discovered[prereq_key] then
            discovered[prereq_key] = true
            node_queue[#node_queue+1] = prereq_key
        end
    end

    local critical_requirement = {}

    while #node_queue >= node_queue_front do
        local node_key = node_queue[node_queue_front]
        assert(node_key ~= nil)
        node_queue_front = node_queue_front + 1
        local node = graph[node_key]
        if target_node_types[node.type] then
            critical_requirement[node_key] = true
        else
            if graph_utils.is_and_node(node) then
                for _, prereq in pairs(node.prereqs) do
                    discover_prereq(prereq)
                end
            elseif graph_utils.is_or_node(node) then
                assert(#node.prereqs > 0)
                discover_prereq(node.prereqs[1])
            else
                error("what")
            end
        end
    end

    return critical_requirement
end

return critical_req