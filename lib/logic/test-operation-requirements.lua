-- Run from the mod root: lua lib/logic/test-operation-requirements.lua
function table.deepcopy(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end
function log(message) end
package.loaded["lib/random/rng"] = {
    shuffle = function() end,
    value = function() return 0.5 end,
}
local logic = {
    type_info = {},
    contexts = {
        home = true,
        away = true,
    },
}
package.loaded["lib/logic/state"] = logic
package.loaded["lib/logic/init"] = logic
package.loaded["randomizations/graph/unified/skeleton/protection"] = {}
local gutils = require("lib/graph/graph-utils")
local operation = require("lib/logic/operation-requirements")
local top = require("lib/graph/context-sort")
-- Contexts are numbers (lib/graph/contexts.lua); fixtures write them as their names, like "home" (lib/graph/contexts-for-tests.lua)
local C = require("lib/graph/contexts-for-tests").C
local key = gutils.key
local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function toy(research_supply)
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local sort = {
        sorted = {},
        node_to_context_inds = {},
    }
    -- context is a context's name (default "home")
    local function add(kind, name, op, pres, context)
        logic.type_info[kind] = logic.type_info[kind] or {}
        local node = gutils.add_node(graph, kind, name, { op = op })
        for _, pre in pairs(pres or {}) do
            gutils.add_edge(graph, pre, key(node))
        end
        context = C(context or "home")
        local ind = #sort.sorted + 1
        sort.sorted[ind] = {
            node_key = key(node),
            context = context,
        }
        sort.node_to_context_inds[key(node)] = { [context] = ind }
        return key(node)
    end
    local start = add("start", "", "AND")
    local early = add("item", "early-position", "OR", { start })
    local building_recipe = add("recipe", "make-device", "AND", { start })
    local item = add("item", "device-kit", "OR", { building_recipe })
    local intermediate = add(research_supply and "technology" or "recipe", "prepare-supply", "AND", { start })
    local supply_recipe = add("recipe", "make-supply", "AND", { intermediate })
    local supply = add("item", "supply", "OR", { supply_recipe })
    local late = add("item", "late-position", "OR", { supply })
    local build = add("entity-build-item", "device", "OR", { item })
    local own = add("entity-own", "device", "OR", { build })
    local operate = add("entity-operate", "device", "AND", {
        own,
        supply,
    })
    return graph, sort, {
        item = item,
        early = early,
        late = late,
        supply = supply,
        operate = operate,
        own = own,
        supply_recipe = supply_recipe,
    }, add
end

local function material_frontier(node)
    return node.type == "item" or node.type == "recipe"
end

test("association follows build edges with different item and entity names", function()
    local graph, _, nodes = toy()
    assert(operation.items(graph)[nodes.item][nodes.operate])
end)

test("a building may move after its supply, but not before it", function()
    local graph, sort, nodes = toy()
    local rules = operation.matching(graph, sort, operation.items(graph))
    assert(not rules.allows(nodes.early, nodes.item))
    assert(rules.allows(nodes.late, nodes.item))
    assert(not rules.allows(nodes.item, nodes.item), "the old position must not bypass readiness")
end)

test("provisional placement cuts the own-item dependency only", function()
    local graph, sort, nodes = toy()
    local proof = operation.prover(graph, sort, nodes.item, C("home"), material_frontier)(nodes.operate)
    assert(proof.rank == sort.node_to_context_inds[nodes.supply][C("home")])
    assert(proof.leaves[sort.node_to_context_inds[nodes.item][C("home")]] == nil)
    assert(proof.leaves[sort.node_to_context_inds[nodes.supply][C("home")]])
end)

test("an alternative early supply is enough", function()
    local graph, sort, nodes = toy()
    -- Replace the fuel edge by an OR with two providers, retaining a valid order.
    local supply = gutils.add_node(graph, "supply", "", { op = "OR" })
    gutils.add_edge(graph, nodes.supply, key(supply))
    gutils.add_edge(graph, nodes.early, key(supply))
    local old = sort.node_to_context_inds[nodes.operate][C("home")]
    sort.sorted[old] = {
        node_key = key(supply),
        context = C("home"),
    }
    sort.sorted[old + 1] = {
        node_key = nodes.operate,
        context = C("home"),
    }
    sort.node_to_context_inds[key(supply)] = { [C("home")] = old }
    sort.node_to_context_inds[nodes.operate][C("home")] = old + 1
    gutils.remove_edge(graph, gutils.ekey({
        start = nodes.supply,
        stop = nodes.operate,
    }))
    gutils.add_edge(graph, key(supply), nodes.operate)
    local proof = operation.prover(graph, sort, nodes.item, C("home"), material_frontier)(nodes.operate)
    assert(proof.rank == sort.node_to_context_inds[nodes.early][C("home")])
end)

test("operation in another context does not justify this placement", function()
    local graph, sort, nodes = toy()
    sort.node_to_context_inds[nodes.operate] = { [C("elsewhere")] = #sort.sorted }
    sort.sorted[#sort.sorted].context = C("elsewhere")
    assert(not operation.matching(graph, sort, operation.items(graph)).allows(nodes.late, nodes.item))
end)

test("a new sort invalidates a proof when its supply moves later", function()
    local graph, sort, nodes = toy()
    assert(operation.matching(graph, sort, operation.items(graph)).allows(nodes.late, nodes.item))
    gutils.remove_edge(graph, gutils.ekey({
        start = nodes.supply,
        stop = nodes.late,
    }))
    gutils.add_edge(graph, nodes.item, nodes.late)
    sort = {
        sorted = sort.sorted,
        node_to_context_inds = sort.node_to_context_inds,
    }
    assert(not operation.matching(graph, sort, operation.items(graph)).allows(nodes.late, nodes.item))
end)

test("a later supply recipe cannot be advanced by the provisional building", function()
    local graph, sort, nodes = toy()
    gutils.add_edge(graph, nodes.item, nodes.supply_recipe)
    local proof = operation.prover(graph, sort, nodes.item, C("home"), material_frontier)(nodes.operate)
    assert(proof.rank > sort.node_to_context_inds[nodes.item][C("home")])
end)

test("tech witnesses include the supply recipe and exclude the building recipe", function()
    local graph, sort, nodes = toy()
    local proof = operation.prover(graph, sort, nodes.item, C("home"), function(node) return node.type == "recipe" end)(nodes.operate)
    assert(proof.leaves[sort.node_to_context_inds[nodes.supply_recipe][C("home")]])
    assert(proof.leaves[sort.node_to_context_inds[key("recipe", "make-device")][C("home")]] == nil)
end)

test("operation tech prerequisites are added together", function()
    local deps = {
        device = {},
        supply = {},
        pipes = {},
    }
    assert(operation.extend_recipes(deps, "device", {
        supply = true,
        pipes = true,
    }, function() return true end))
    assert(deps.device.supply and deps.device.pipes)
end)

test("a transitive cycle rejects the entire operation witness", function()
    local deps = {
        device = {},
        supply = { middle = true },
        middle = { device = true },
        pipes = {},
    }
    assert(not operation.extend_recipes(deps, "device", {
        supply = true,
        pipes = true,
    }, function() return true end))
    assert(next(deps.device) == nil)
end)

test("a context-losing prerequisite rejects the entire witness", function()
    local deps = {
        device = {},
        supply = {},
        pipes = {},
    }
    assert(not operation.extend_recipes(deps, "device", {
        supply = true,
        pipes = true,
    }, function(pre) return pre ~= "supply" end))
    assert(next(deps.device) == nil)
end)

test("delivery must actually connect the acquisition room to the operation room", function()
    local graph, sort, nodes, add = toy()
    logic.type_info["item-deliver"] = { context = true }
    local delivery = add("item-deliver", "device-route", "AND", {
        nodes.item,
        nodes.late,
    }, "away")
    gutils.add_edge(graph, delivery, nodes.item)
    gutils.remove_edge(graph, gutils.ekey({
        start = nodes.supply,
        stop = nodes.operate,
    }))
    for _, node_key in pairs({
        nodes.item,
        key("entity-build-item", "device"),
        nodes.own,
        nodes.operate,
    }) do
        local ind = #sort.sorted + 1
        sort.sorted[ind] = {
            node_key = node_key,
            context = C("away"),
        }
        sort.node_to_context_inds[node_key][C("away")] = ind
    end
    sort.node_to_context_inds[nodes.operate][C("home")] = nil
    local rules = operation.matching(graph, sort, operation.items(graph))
    assert(not rules.allows(nodes.early, nodes.item))
    assert(rules.allows(nodes.late, nodes.item))
end)

test("the final audit distinguishes an enabled crafting step from a later research unlock", function()
    local graph, sort, nodes = toy()
    local operations = operation.items(graph)
    assert(not operation.matching(graph, sort, operations).allows(nodes.item, nodes.item))
    assert(operation.matching(graph, sort, operations, true).allows(nodes.item, nodes.item))
    local gated_graph, gated_sort, gated_nodes = toy(true)
    assert(not operation.matching(gated_graph, gated_sort, operation.items(gated_graph), true).allows(gated_nodes.item, gated_nodes.item))
end)

test("the physical audit accepts a later build instead of the earlier research capture", function()
    local graph, sort, nodes, add = toy()
    local capsule = add("technology", "capture-research", "AND", { key("start", "") })
    local capture = add("entity-capture", "device", "AND", { capsule })
    gutils.add_edge(graph, capture, nodes.own)
    -- The physical sort encountered capture before the independently enabled build route.
    local reordered = {}
    local build = key("entity-build-item", "device")
    for _, pebble in pairs(sort.sorted) do
        if pebble.node_key ~= build and pebble.node_key ~= nodes.own and pebble.node_key ~= nodes.operate then
            table.insert(reordered, pebble)
        end
    end
    for _, node_key in pairs({
        nodes.own,
        nodes.operate,
        build,
    }) do
        table.insert(reordered, {
            node_key = node_key,
            context = C("home"),
        })
    end
    sort.sorted = reordered
    for ind, pebble in pairs(reordered) do
        sort.node_to_context_inds[pebble.node_key][pebble.context] = ind
    end
    local levels = operation.levels(graph, sort, true)
    assert(levels[sort.node_to_context_inds[nodes.item][C("home")]] == 0)
    assert(levels[sort.node_to_context_inds[capture][C("home")]] == 1)
    assert(not operation.matching(graph, sort, operation.items(graph), true).allows(nodes.item, nodes.item))
    local messages = {}
    local original_log = log
    log = function(message) table.insert(messages, message) end
    local failed = operation.audit(graph, sort, "OPERATIONCHECK")
    log = original_log
    assert(#failed == 0)
    assert(messages[1] == "OPERATIONCHECK checked 1 building items; 0 precede operation readiness")
end)

test("the physical audit still reports a genuinely later research supply", function()
    local graph, sort, nodes = toy(true)
    local messages = {}
    local original_log = log
    log = function(message) table.insert(messages, message) end
    local failed = operation.audit(graph, sort, "OPERATIONCHECK")
    log = original_log
    assert(#failed == 1 and failed[1] == nodes.item)
    assert(messages[1] == "OPERATIONCHECK checked 1 building items; 1 precede operation readiness")
    assert(string.find(messages[2], "arrival research layer 0, ready research layer 1", 1, true))
    assert(string.find(messages[3], "item: supply (layer 1)", 1, true))
end)

test("shared outgoing contexts reuse one backing without depending on each other", function()
    local graph, sort, nodes, add = toy()
    logic.type_info["shared-location"] = { context = true }
    local shared = add("shared-location", "", "OR", { nodes.item })
    local first = #sort.sorted
    sort.sorted[first + 1] = {
        node_key = shared,
        context = C("away"),
    }
    sort.node_to_context_inds[shared][C("away")] = first + 1
    local original_path = top.path
    local calls = 0
    top.path = function(...)
        calls = calls + 1
        return original_path(...)
    end
    local levels = operation.levels(graph, sort)
    assert(levels[first] == levels[sort.node_to_context_inds[nodes.item][C("home")]])
    assert(levels[first + 1] == levels[first])
    top.path = original_path
    assert(calls == 1, "the same incoming witness should only be reconstructed once")
    assert(sort.operation_backings[first][first] == nil)
    assert(sort.operation_backings[first + 1][first] == nil)
end)

print(num_passed .. " tests passed")
