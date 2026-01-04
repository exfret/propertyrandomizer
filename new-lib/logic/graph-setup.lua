-- Graph lookup construction
-- Adds node/edge lookups, sources, emitters, prereqs/deps after graph is built

local graph_setup = {}

function graph_setup.build(logic)
    local graph = logic.graph
    local type_info = logic.type_info

    -- Add node and edge lookups
    -- This stuff could probably go in graph-utils
    graph.nodes = {}
    graph.edges = {}
    graph.sources = {}
    graph.emitters = {}
    graph.context_sources = {}

    for key, object in pairs(graph) do
        if object.object_type == "node" then
            object.op = type_info[object.type].op
            if object.op == "AND" then
                graph.sources[key] = true
            end
            local node_context = type_info[object.type].context
            -- Check if not context transmitter
            if node_context ~= nil then
                graph.emitters[key] = node_context
            end
            -- Check if this represents a context
            if type(node_context) == "string" then
                graph.context_sources[key] = node_context
            end
            graph.nodes[key] = object
            object.pre = {}
            object.dep = {}
            object.num_pre = 0
        elseif object.object_type == "edge" then
            graph.edges[key] = object
        end
    end

    -- Add prereqs and depends to nodes
    for edge_key, edge in pairs(graph.edges) do
        if graph.nodes[edge.start] == nil then
            log(serpent.block(edge))
        end
        if graph.nodes[edge.stop] == nil then
            log(serpent.block(edge))
        end

        graph.sources[edge.stop] = nil
        graph.nodes[edge.start].dep[edge_key] = true
        graph.nodes[edge.stop].pre[edge_key] = true
        graph.nodes[edge.stop].num_pre = graph.nodes[edge.stop].num_pre + 1
    end
end

return graph_setup
