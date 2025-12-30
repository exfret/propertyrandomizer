local graph_utils = require("lib/graph/graph-utils")
local rng = require("lib/random/rng")
local registry = require("randomizations/graph/core/registry")

local technology_node_type = "technology"
local science_pack_set_node_type = "research-science-pack-set"

local randomizer = registry.create_empty_randomizer("science-pack-set")
randomizer.get_target_edges = function (params)
    local edges = {}
    for _, node_key in pairs(params.node_type_to_node_keys[technology_node_type]) do
        local node = params.vanilla_graph[node_key]
        for _, prereq in pairs(node.prereqs) do
            if prereq.type == science_pack_set_node_type then
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
        if tech.unit ~= nil then
            local target_prereqs = {}
            for _, prereq in pairs(node.prereqs) do
                local prereq_node = graph_utils.get_node(params.random_graph, prereq)
                if prereq_node.type == science_pack_set_node_type then
                    table.insert(target_prereqs, prereq_node.science_pack_set)
                end
            end
            assert(#target_prereqs == 1)
            local science_pack_set = target_prereqs[1]
            tech.unit.ingredients = {}
            for _, item_name in pairs(science_pack_set) do
                tech.unit.ingredients[#tech.unit.ingredients+1] = { item_name, 1 }
            end
        end
    end
end

registry.add(randomizer)
