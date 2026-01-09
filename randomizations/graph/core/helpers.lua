local graph_utils = require("lib/graph/graph-utils")

local export = {}

local get_ordinal = function (key, ordinals)
    if ordinals[key] == nil then
        return ordinals.MAX
    end
    return ordinals[key]
end
local sort_prereqs = function (prereqs, ordinals)
    table.sort(prereqs, function(a, b)
        return get_ordinal(graph_utils.get_node_key(a), ordinals)
            < get_ordinal(graph_utils.get_node_key(b), ordinals)
    end)
end
export.sort_all_prereqs = function (graph, ordinals)
    for _, node in pairs(graph) do
        sort_prereqs(node.prereqs, ordinals)
        sort_prereqs(node.dependents, ordinals)
    end
end

export.get_prereq_info = function (state, prereq_type, surface_key)
    if state.surface_specific(prereq_type) then
        assert(surface_key ~= nil)
        if state.prereq_edges[prereq_type].surface_keys[surface_key] == nil then
            state.prereq_edges[prereq_type].surface_keys[surface_key] = {
                reachable_prereqs = {},
                all_reachable_edges = {},
                unused_edges = {},
            }
        end
        return state.prereq_edges[prereq_type].surface_keys[surface_key]
    end
    return state.prereq_edges[prereq_type].no_surface
end

-- To mirror edges across surfaces
export.clone_across_surfaces = function (state, edges)
    local single_surface_edges = table.deepcopy(edges)
    for i = 1, #edges do edges[i] = nil end

    -- Grab the surface variants of this dependent
    for _, edge in pairs(single_surface_edges) do
        local surface_ambiguous_key = graph_utils.get_surface_ambiguous_key(state.random_graph[edge.dependent_key])
        for surface_key, dependent_key in pairs(state.surface_ambiguous_key_info[surface_ambiguous_key].node_keys) do
            local prereq_key = edge.prereq_key
            local prereq = state.random_graph[prereq_key]

            -- Correct the prereq surface if it's surface specific too
            if state.surface_specific(prereq.type) then
                local prereq_surface_ambiguous_key = graph_utils.get_surface_ambiguous_key(prereq)
                prereq_key = state.surface_ambiguous_key_info[prereq_surface_ambiguous_key].node_keys[surface_key]
                table.insert(edges, graph_utils.create_edge(prereq_key, dependent_key, state.random_graph))
            end
        end
    end
end

export.unique_prereq_edge_filter = function (edge_list)
    local set = {}
    local unique = {}
    for _, edge in pairs(edge_list) do
        if set[edge.prereq_key] == nil then
            set[edge.prereq_key] = true
            unique[#unique+1] = edge
        end
    end
    return unique
end

-- Item lookup
export.items = {}
for item_class, _ in pairs(defines.prototypes.item) do
    if data.raw[item_class] ~= nil then
        for _, item in pairs(data.raw[item_class]) do
            export.items[item.name] = item
        end
    end
end

return export
