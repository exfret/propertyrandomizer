local build_graph = require("lib/graph/build-graph")
local json = require("offline/utils/json")

nodes = io.open("offline/output/dep-graph.json", "wb")
nodes:write(json.stringify(build_graph.graph))