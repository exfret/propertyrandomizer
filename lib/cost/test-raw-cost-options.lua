-- lua lib/cost/test-raw-cost-options.lua
-- Verify the global options boundary preserves every raw price, independently of abilities.
local raw = { ["item-manual"] = 8, ["item-automated"] = 1, ["item-compat"] = 3 }
local contexts = { here = true }
local context_costs = {
    build = function()
        return { raw_costs = raw, automatable = { here = { ["item-automated"] = true } } }
    end,
}
package.loaded["lib/cost/context-costs"] = context_costs
-- Context sorting is outside this option-export test.
package.loaded["lib/graph/context-sort"] = {}
local graph_cost = require("lib/cost/graph-cost")

-- Isolate option export from graph solving (covered by test-graph-cost.lua).
graph_cost.compute_for_sort = function() return {} end
graph_cost.starting_resources = function() return { "item-automated" } end
graph_cost.automatable_by_room = function() return context_costs.build().automatable end
log = function() end
randomization_info = { options = { cost = { default_cost_table = { ["item-compat"] = 7 } } } }
local graph = { nodes = {} }
for _, name in pairs({ "manual", "automated", "compat" }) do
    graph.nodes["item: " .. name] = { type = "item", name = name }
end
graph_cost.derive_cost_options(graph, {}, "here", { node_to_context_inds = {} }, contexts)
local costs = randomization_info.options.cost.default_cost_table
assert(costs["item-manual"] == 8)
assert(costs["item-automated"] == 1)
assert(costs["item-compat"] == 7)
assert(costs["item-unknown"] == nil)
assert(context_costs.current.automatable.here["item-manual"] == nil)
print("ok - global raw prices retain manual sources and compatibility overrides without granting automation")
