-- Regression for eager loading: graph algorithms load before logic metadata without a require cycle.
-- Run from the mod root: lua lib/test-module-loading.lua
package.loaded["lib/random/rng"] = {
    int = function(_, maximum)
        return maximum
    end,
}

local state = require("lib/logic/state")
local top = require("lib/graph/context-sort")
local contutils = require("lib/graph/context-utils")
local bootstrap = require("lib/logic/bootstrap")
local context_costs = require("lib/cost/context-costs")
local graph_cost = require("lib/cost/graph-cost")
local core = require("lib/cost/graph-cost-core")

assert(package.loaded["lib/logic/init"] == nil)
assert(graph_cost.compute == core.compute)
assert(graph_cost.price_without_recipes == core.price_without_recipes)
assert(type(context_costs.build) == "function")
assert(bootstrap.prune({
    graph = {
        nodes = {},
        edges = {},
    },
}) == 0)

-- Populate runtime metadata after consumers have loaded, using the same shared state object.
data = nil
defines = {selection_mode = {select = 1}}
prototypes = {
    space_location = {
        test_planet = {
            type = "planet",
            name = "test-planet",
        },
    },
    surface = {},
    item = {
        ["propertyrandomizer-logic"] = {
            get_entity_type_filters = function()
                return {serialized = true}
            end,
        },
    },
}
serpent = {
    load = function()
        return true, {room = {context = "room"}}
    end,
}
local logic = require("lib/logic/init")
assert(logic == state)
assert(contutils.full_context()["planet: test-planet"] == true)
assert(contutils.transmit({
    type = "room",
    name = "another-room",
}, "incoming")[1] == "another-room")
local empty = {
    nodes = {},
    edges = {},
    sources = {},
}
assert(next(top.sort(empty).node_to_context_inds) == nil)
assert(next(graph_cost.compute_for_sort(empty, {})) == nil)
print("ok - eager module imports share initialized metadata and avoid logic/cost cycles")
