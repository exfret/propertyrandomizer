local build_graph = require("lib/graph/build-graph")

local util = {}

local and_type = "AND"
local or_type = "OR"

util.is_and_node = function (node)
    return build_graph.ops[node.type] == and_type
end

util.is_or_node = function (node)
    return build_graph.ops[node.type] == or_type
end

util.is_this_one_of_those_uh_one_of_those_nodes_that_you_when_theres_like_uh_source_node_thats_what_its_called_is_that_what_this_is = function(node)
    return util.is_and_node(node) and #node.prereqs == 0
end

util.is_false_node = function (node)
    return util.is_or_node(node) and #node.prereqs == 0
end

util.get_node_key = function (node)
    return build_graph.key(node.type, node.name)
end

util.get_node = function (graph, prereq)
    return graph[build_graph.key(prereq.type, prereq.name)]
end

return util