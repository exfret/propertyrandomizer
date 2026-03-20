local logic = require("new-lib/logic/init")
logic.build()

local graph_op_test = require("tests/graph-operations")
graph_op_test.init(logic.graph)
graph_op_test.pre_depnode()
graph_op_test.pre_depnodes()

local consistent_sort = require("tests/consistent-sort")
consistent_sort.init(logic.graph)
for test_name, test in pairs(consistent_sort) do
    if type(test) == "function" and not consistent_sort.non_test_names[test_name] then
        test()
    end
end