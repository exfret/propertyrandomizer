-- Extended-context (room + abilities) versions of the explorer's sorts, for the contexts panel
-- Built along with the simple sorts in load_dep_graph and updated incrementally alongside them, so opening the panel doesn't re-sort

local top = require("lib/graph/context-sort")

local explorer_sorts = {}

explorer_sorts.build = function()
    -- The full graph never changes in control, so only its result is kept
    storage.complex_sort_inds = top.sort(storage.graph, nil, nil, {complex_contexts = true}).node_to_context_inds
    storage.tech_complex_sort_info = top.sort(storage.tech_graph, nil, nil, {complex_contexts = true})
    storage.science_pack_complex_sort_info = top.sort(storage.science_pack_graph, nil, nil, {complex_contexts = true})
end

-- Call after new_edge is added to graph, with the storage key of that graph's complex sort
explorer_sorts.add_edge = function(sort_info_key, graph, new_edge)
    -- Saves from before these sorts existed get them when the panel first opens instead
    if storage[sort_info_key] == nil then
        return
    end
    storage[sort_info_key] = top.sort(graph, storage[sort_info_key], {graph.nodes[new_edge.start], graph.nodes[new_edge.stop]})
end

-- node_to_context_inds of each sort, keyed like the explorer's reach levels
explorer_sorts.inds = function()
    if storage.complex_sort_inds == nil or storage.tech_complex_sort_info == nil or storage.science_pack_complex_sort_info == nil then
        explorer_sorts.build()
    end
    return {
        tech = storage.tech_complex_sort_info.node_to_context_inds,
        science_pack = storage.science_pack_complex_sort_info.node_to_context_inds,
        full = storage.complex_sort_inds,
    }
end

return explorer_sorts
