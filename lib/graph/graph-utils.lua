local build_graph = require("lib/graph/build-graph")

local util = {}

util.and_type = "AND"
util.or_type = "OR"
local node_member_name = "name"
local node_member_prereqs = "prereqs"
local node_member_dependents = "dependents"
local node_member_surface = "surface"

util.is_and_node = function (node)
    return build_graph.ops[node.type] == util.and_type
end

util.is_or_node = function (node)
    return build_graph.ops[node.type] == util.or_type
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

-- exfret: I use this so much that having a shorthand where it can use the dep_graph global is great
util.get = function (prereq)
    return dep_graph[build_graph.key(prereq.type, prereq.name)]
end

-- exfret: Same thing but get from type and name
util.getk = function (node_type, node_name)
    return dep_graph[build_graph.key(node_type, node_name)]
end

util.create_edge_type = function (prereq_type, dependent_type)
    return { key = build_graph.key(prereq_type, dependent_type), prereq_type = prereq_type, dependent_type = dependent_type }
end

util.get_edge_type = function (prereq, dependent)
    return util.create_edge_type(prereq.type, dependent.type)
end

util.create_edge = function (prereq_key, dependent_key, graph)
    return {
        key = build_graph.key(prereq_key, dependent_key),
        prereq_key = prereq_key,
        dependent_key = dependent_key,
        type = util.create_edge_type(graph[prereq_key].type, graph[dependent_key].type)
    }
end

util.add_prereq = function (prereq, dependent)
    -- Check if this edge has already been added
    for _, dependent2 in pairs(prereq.dependents) do
        if dependent2.type == dependent.type and dependent2.name == dependent.name then
            return
        end
    end

    if prereq.dependents ~= nil then
        prereq.dependents[#prereq.dependents+1] = {
            type = dependent.type,
            name = dependent.name,
        }
    end
    dependent.prereqs[#dependent.prereqs+1] = {
        type = prereq.type,
        name = prereq.name,
    }
end

util.add_edge = function (graph, edge)
    util.add_prereq(graph[edge.prereq_key], graph[edge.dependent_key])
end

util.remove_prereq = function (prereq, dependent)
    if prereq.dependents ~= nil then
        for i, d in pairs(prereq.dependents) do
            if d.type == dependent.type and d.name == dependent.name then
                table.remove(prereq.dependents, i)
                break
            end
        end
    end
    for i, p in pairs(dependent.prereqs) do
        if p.type == prereq.type and p.name == prereq.name then
            table.remove(dependent.prereqs, i)
            break
        end
    end
end

util.delete_edge = function (graph, edge)
    util.remove_prereq(graph[edge.prereq_key], graph[edge.dependent_key])
end

util.update_edges = function (graph, deleted_edges, added_edges)
    for _, edge in pairs(deleted_edges) do
        util.delete_edge(graph, edge)
    end
    for _, edge in pairs(added_edges) do
        util.add_edge(graph, edge)
    end
end

util.clear_prereqs = function (dependent, graph)
    while #dependent.prereqs > 0 do
        local prereq = graph[util.get_node_key(dependent.prereqs[#dependent.prereqs])]
        if prereq.dependents ~= nil then
            for i, d in pairs(prereq.dependents) do
                if d.type == dependent.type and d.name == dependent.name then
                    table.remove(prereq.dependents, i)
                    break
                end
            end
        end
        table.remove(dependent.prereqs, #dependent.prereqs)
    end
end

local node_member_filter = {
    [node_member_dependents] = true,
    [node_member_name] = true,
    [node_member_prereqs] = true,
    [node_member_surface] = true,
}
util.get_surface_ambiguous_key = function (node)
    if node[node_member_surface] ~= nil then
        local name_segments = {}
        for member, value in pairs(node) do
            if not node_member_filter[member] then
                assert(type(value) ~= "nil")
                assert(type(value) ~= "function")
                if type(value) == "table" then
                    value = build_graph.compound_key(value)
                end
                name_segments[#name_segments+1] = value
            end
        end
        return build_graph.compound_key(name_segments)
    end
    return util.get_node_key(node)
end

return util