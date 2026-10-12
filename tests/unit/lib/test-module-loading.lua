-- Regression for eager loading: graph algorithms load before logic metadata without a require cycle.
-- Run from the mod root: lua tests/unit/lib/test-module-loading.lua
package.loaded["src/lib/random/rng"] = {
    int = function(_, maximum)
        return maximum
    end,
}

local state = require("src/logic/state")
local top = require("src/lib/sort/context-sort")
local contutils = require("src/logic/contexts/context-utils")
local bootstrap = require("src/logic/builders/bootstrap")
local context_costs = require("src/cost/context-costs")
local graph_cost = require("src/cost/graph-cost")
local core = require("src/cost/graph-cost-core")

assert(package.loaded["src/logic/init"] == nil)
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
    -- The data stage's room numbering (src/logic/contexts/contexts.lua export_rooms), which the control stage imports
    mod_data = {
        ["propertyrandomizer-contexts"] = {
            data = {
                numbers = {
                    ["planet: test-planet"] = 0,
                },
                originals = 1,
            },
        },
    },
}
serpent = {
    load = function()
        return true, {room = {context = "room"}}
    end,
}
local logic = require("src/logic/init")
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
