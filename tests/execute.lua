local logic = require("lib/logic/init")
local entity_acquisition = require("tests/entity-acquisition")
local graph_op_test = require("tests/graph-operations")
local consistent_sort = require("tests/consistent-sort")

local test = {}

test.execute = function()
    logic.build()

    entity_acquisition.run(logic.graph)

    graph_op_test.init(logic.graph)
    graph_op_test.pre_depnode()
    graph_op_test.pre_depnodes()

    consistent_sort.init(logic.graph)
    for test_name, test in pairs(consistent_sort) do
        if type(test) == "function" and not consistent_sort.non_test_names[test_name] then
            test()
        end
    end
end

return test