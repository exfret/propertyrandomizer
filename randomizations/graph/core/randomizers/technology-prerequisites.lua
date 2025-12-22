local graph_utils = require("lib/graph/graph-utils")
local rng = require("lib/random/rng")
local registry = require("randomizations/graph/core/registry")

local technology_node_type = "technology"

local randomizer = registry.create_empty_randomizer("technology")
randomizer.get_target_edges = function (params)
    local edges = {}
    for _, node_key in pairs(params.node_type_to_node_keys[technology_node_type]) do
        local node = params.vanilla_graph[node_key]
        for _, prereq in pairs(node.prereqs) do
            if prereq.type == technology_node_type then
                local edge = graph_utils.create_edge(graph_utils.get_node_key(prereq), node_key, params.vanilla_graph)
                edges[edge.key] = edge
            end
        end
    end
    return edges
end

randomizer.execute_randomization = function (params)
    if #params.suitable_edges < params.first_edge_count then
        params.postpone = true
        return
    end
    rng.shuffle(params.rng_key, params.suitable_edges)
    for i = 1, params.first_edge_count do
        params.new_edges[i] = params.suitable_edges[i]
    end
end

randomizer.finalize = function (params)
    local graph = params.random_graph
    for _, node_key in pairs(params.node_type_to_node_keys[technology_node_type]) do
        local node = graph[node_key]
        local tech = data.raw.technology[node.name]
        if tech.prerequisites ~= nil then
            local target_prereqs = {}
            for _, prereq in pairs(node.prereqs) do
                if prereq.type == technology_node_type then
                    table.insert(target_prereqs, prereq.name)
                end
            end
            assert(#tech.prerequisites <= #target_prereqs)
            for i = 1, #target_prereqs do
                tech.prerequisites[i] = target_prereqs[i]
            end
        end
    end
end

registry.add(randomizer)
