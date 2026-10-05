-- Run from the mod root: lua randomizations/graph/unified/skeleton/test-check.lua
-- The final verdict must include actual operation audit failures so the panel can warn.
config = { operation_readiness = true }
UNIFIED_MATERIAL_RENAMES = {}
old_data_raw = {}
local messages = {}
function log(message)
    table.insert(messages, message)
end
local logic = { type_info = {} }
package.loaded["lib/logic/state"] = logic
package.loaded["lib/logic/init"] = logic
package.loaded["lib/random/rng"] = {}
package.loaded["lib/furnace-selection"] = { new_collisions = function() return {} end }
package.loaded["lib/item-fluid"] = {}
package.loaded["randomizations/graph/unified/skeleton/protection"] = {
    planet_locked_recipe_contexts = function() return {} end,
}

local gutils = require("lib/graph/graph-utils")
local check = require("randomizations/graph/unified/skeleton/check")

local function fixture(ready)
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local sorted = {
        sorted = {},
        node_to_context_inds = {},
    }
    local function add(kind, name, op, prerequisites)
        logic.type_info[kind] = {}
        local node = gutils.add_node(graph, kind, name, { op = op })
        local node_key = gutils.key(node)
        for _, prerequisite in pairs(prerequisites or {}) do
            gutils.add_edge(graph, prerequisite, node_key)
        end
        local ind = #sorted.sorted + 1
        sorted.sorted[ind] = {
            node_key = node_key,
            context = "test-room",
        }
        sorted.node_to_context_inds[node_key] = { ["test-room"] = ind }
        return node_key
    end
    local start = add("start", "", "AND")
    local supply_tech = add("technology", "test-supply", "AND", { start })
    local kit_recipe = add("recipe", "test-kit", "AND", { ready and supply_tech or start })
    local kit = add("item", "test-kit", "OR", { kit_recipe })
    local supply_recipe = add("recipe", "test-supply", "AND", { supply_tech })
    local supply = add("item", "test-supply", "OR", { supply_recipe })
    local build = add("entity-build-item", "test-device", "OR", { kit })
    local own = add("entity-own", "test-device", "OR", { build })
    add("entity-operate", "test-device", "AND", {
        own,
        supply,
    })
    return graph, sorted
end

local num_passed = 0
local function test(name, fn)
    messages = {}
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

test("a final operation gap fails the verdict even when reachability is unchanged", function()
    local graph, sorted = fixture(false)
    local verdict = check.run(graph, sorted, sorted)
    assert(not verdict.ok)
    assert(verdict.operation_failures == 1)
    assert(verdict.unreachable == 0 and verdict.lost == 0 and verdict.missing == 0)
    assert(string.find(messages[#messages], "operation failures 1", 1, true) ~= nil)
end)

test("ready operation passes the final verdict", function()
    local graph, sorted = fixture(true)
    local verdict = check.run(graph, sorted, sorted)
    assert(verdict.ok and verdict.operation_failures == 0)
end)

test("disabling operation readiness retains the reachability verdict", function()
    config.operation_readiness = false
    local graph, sorted = fixture(false)
    local verdict = check.run(graph, sorted, sorted)
    config.operation_readiness = true
    assert(verdict.ok and verdict.operation_failures == 0)
end)

test("the pre-rebuild attempt check does not run the final operation audit", function()
    local graph, sorted = fixture(false)
    local verdict = check.run(graph, sorted, sorted, "UNIFIEDCHECK")
    assert(verdict.ok and verdict.operation_failures == 0)
end)

test("an attempt audited after unlock repair fails when a readiness gap remains", function()
    local graph, sorted = fixture(false)
    local verdict = check.run(graph, sorted, sorted, "UNIFIEDCHECK", true)
    assert(not verdict.ok and verdict.operation_failures == 1)
end)

print(num_passed .. " checker tests passed")
