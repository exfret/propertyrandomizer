local gutils = require("new-lib/graph/graph-utils")

local test = {}

local test_graph
local test_node1
local test_node2
local test_edge1

test.init = function(graph)
    test_graph = table.deepcopy(graph)

    test_node1 = gutils.add_node(test_graph, "recipe", "exfret-test-node-1")
    test_node2 = gutils.add_node(test_graph, "recipe", "exfret-test-node-2")
    test_edge1 = gutils.add_edge(test_graph, test_node1, test_node2)
end

test.pre_depnode = function()
    for pre, _ in pairs(test_node2.pre) do
        local prenode = gutils.prenode(test_graph, pre)
        assert(gutils.key(prenode) == gutils.key(test_node1))
        for dep, _ in pairs(prenode.dep) do
            local depnode = gutils.depnode(test_graph, dep)
            assert(gutils.key(depnode) == gutils.key(test_node2))
        end
    end
end

test.pre_depnodes = function()
    for _, node in pairs(gutils.prenodes(test_graph, test_node2)) do
        assert(gutils.key(node) == gutils.key(test_node1))
        for _, node2 in pairs(gutils.prenodes(test_graph, node)) do
            -- test_node1 has no predecessors
            assert(false)
        end
        for _, node2 in pairs(gutils.depnodes(test_graph, node)) do
            assert(gutils.key(node2) == gutils.key(test_node2))
        end
    end
end

return test