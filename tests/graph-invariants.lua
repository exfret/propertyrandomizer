local gutils = require("new-lib/graph/graph-utils")

local test_graph_invariants = {}

test_graph_invariants.test = function(graph)
    -- Test that num_pre is actual number of prerequisites
    for _, node in pairs(graph.nodes) do
        local num_pre = 0
        for _, _ in pairs(node.pre) do
            num_pre = num_pre + 1
        end
        if node.num_pre ~= num_pre then
            log(serpent.block(node))
            error("Randomization assertion failed! Tell exfret he's a dumbo.")
        end
    end

    -- Test that each of a node's pre's has it as a stop and vice versa for dep
    for _, node in pairs(graph.nodes) do
        for pre, _ in pairs(node.pre) do
            if graph.edges[pre] == nil then
                log(serpent.block(node))
                error("Randomization assertion failed! Tell exfret he's a dumbo.")
            end
            if gutils.key(node) ~= graph.edges[pre].stop then
                log(serpent.block(node))
                log(serpent.block(graph.edges[pre]))
                error("Randomization assertion failed! Tell exfret he's a dumbo.")
            end
        end
        for dep, _ in pairs(node.dep) do
            if graph.edges[dep] == nil then
                log(serpent.block(node))
                error("Randomization assertion failed! Tell exfret he's a dumbo.")
            end
            if gutils.key(node) ~= graph.edges[dep].start then
                log(serpent.block(node))
                log(serpent.block(graph.edges[dep]))
                error("Randomization assertion failed! Tell exfret he's a dumbo.")
            end
        end
    end

    -- Test that the start and stop of an edge exists
    for _, edge in pairs(graph.edges) do
        if graph.nodes[edge.start] == nil or graph.nodes[edge.stop] == nil then
            log(serpent.block(edge))
            error("Randomization assertion failed! Tell exfret he's a dumbo.")
        end
    end
end

return test_graph_invariants