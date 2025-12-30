local state_builder = require("randomizations/graph/core/state")
local registry = require("randomizations/graph/core/registry")
local engine = require("randomizations/graph/core/engine")

randomizations.graph = function(id)
    local state = state_builder.new_state(id)
    engine.run(state, registry)
end
