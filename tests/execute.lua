local logic = require("new-lib/logic/init")
logic.build()

local graph_op_test = require("tests/graph-operations")
graph_op_test.init(logic.graph)
graph_op_test.pre_depnode()
graph_op_test.pre_depnodes()