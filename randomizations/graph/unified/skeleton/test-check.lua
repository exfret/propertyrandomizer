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
local locked_contexts = {}
package.loaded["randomizations/graph/unified/skeleton/protection"] = {
    planet_locked_recipe_contexts = function() return locked_contexts end,
    protects_isolatability = function(node) return node.keep_isolatability == true end,
    is_isolatable_context = function(context)
        return string.find(context, " | 1", 1, true) ~= nil
    end,
    kept_part = function(node, context)
        if node.keep_isolatability == true then
            return context
        end
        return string.gsub(context, " | [01]", " | ?")
    end,
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

local function isolation_fixture(kind, protected)
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local node = gutils.add_node(graph, kind, "test-local-goal", {
        op = "OR",
        mechanic = kind ~= "recipe",
        keep_isolatability = protected,
    })
    local node_key = gutils.key(node)
    local before = { node_to_context_inds = { [node_key] = { ["test-room | 11"] = 1 } } }
    local after = { node_to_context_inds = { [node_key] = { ["test-room | 01"] = 1 } } }
    return graph, before, after, node_key
end

test("an attempt losing a planet-locked recipe's isolatability fails", function()
    local graph, before, after, node_key = isolation_fixture("recipe")
    locked_contexts = { [node_key] = { ["test-room | 11"] = true } }
    local verdict = check.run(graph, before, after, "UNIFIEDCHECK")
    locked_contexts = {}
    assert(not verdict.ok and verdict.lost == 1)
    assert(verdict.unreachable == 0)
end)

test("rocket launch isolatability fails even when imports preserve reachability", function()
    local graph, before, after = isolation_fixture("launch", true)
    local verdict = check.run(graph, before, after, "UNIFIEDCHECK")
    assert(not verdict.ok and verdict.lost == 1)
    assert(verdict.unreachable == 0)
end)

test("science pack imports may preserve reachability without local production", function()
    local graph, before, after = isolation_fixture("item", false)
    local verdict = check.run(graph, before, after, "UNIFIEDCHECK")
    assert(verdict.ok and verdict.lost == 0)
end)

test("a promised planet-locked context cannot be excused as only isolatability", function()
    local graph, before, after, node_key = isolation_fixture("recipe")
    locked_contexts = { [node_key] = { ["test-room | 11"] = true } }
    UNIFIED_PROMISED_PEBBLES = {
        {
            node_key = node_key,
            context = "test-room | 11",
            rank = 1,
        },
    }
    local verdict = check.run(graph, before, after, "UNIFIEDCHECK")
    locked_contexts = {}
    UNIFIED_PROMISED_PEBBLES = nil
    assert(not verdict.ok and verdict.missing == 1)
end)

test("a promised protected mechanic context cannot be excused as only isolatability", function()
    local graph, before, after, node_key = isolation_fixture("test-mechanic", true)
    UNIFIED_PROMISED_PEBBLES = {
        {
            node_key = node_key,
            context = "test-room | 11",
            rank = 1,
        },
    }
    local verdict = check.run(graph, before, after, "UNIFIEDCHECK")
    UNIFIED_PROMISED_PEBBLES = nil
    assert(not verdict.ok and verdict.missing == 1)
end)

test("missing home backings do not fail when protected room contexts are kept", function()
    local graph, before, _, node_key = isolation_fixture("test-mechanic", true)
    UNIFIED_PROMISED_PEBBLES = {
        {
            node_key = node_key,
            context = "test-room | 00 @ home1",
            rank = 1,
        },
    }
    local verdict = check.run(graph, before, before, "UNIFIEDCHECK")
    UNIFIED_PROMISED_PEBBLES = nil
    assert(verdict.ok and verdict.missing == 0)
end)

print(num_passed .. " checker tests passed")
