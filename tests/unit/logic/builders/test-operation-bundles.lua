-- Run from the mod root: lua tests/unit/logic/builders/test-operation-bundles.lua
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
serpent = { block = tostring }
package.loaded["src/lib/random/rng"] = { shuffle = function() end }
local logic = {
    type_info = {},
    contexts = {
        home = true,
        away = true,
    },
}
package.loaded["src/logic/state"] = logic
local gutils = require("src/lib/graph/graph-utils")
local bundles = require("src/logic/builders/operation-bundles")
-- Contexts are numbers (src/logic/contexts/contexts.lua); fixtures write them as their names, like "home" or "home | 01", and edge abilities as the logic builders used to (tests/unit/logic/contexts/contexts-for-tests.lua)
local fx = require("tests/unit/logic/contexts/contexts-for-tests")
local C = fx.C
local key = gutils.key
local passed = 0
local function test(name, fn)
    fn()
    passed = passed + 1
    print("ok - " .. name)
end

local function toy()
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local sort = {
        pebble_keys = {},
        pebble_contexts = {},
        node_to_context_inds = {},
    }
    -- context is a context's name (default "home"), here and in add and prove
    local function pebble(node_key, context)
        local ind = #sort.pebble_keys + 1
        context = C(context or "home")
        sort.pebble_keys[ind] = node_key
        sort.pebble_contexts[ind] = context
        sort.node_to_context_inds[node_key] = sort.node_to_context_inds[node_key] or {}
        sort.node_to_context_inds[node_key][context] = ind
        return ind
    end
    local function add(kind, name, op, pres, context)
        logic.type_info[kind] = logic.type_info[kind] or {}
        local node = gutils.add_node(graph, kind, name, { op = op })
        for _, pre in pairs(pres or {}) do
            gutils.add_edge(graph, pre, key(node))
        end
        if context ~= false then
            pebble(key(node), context)
        end
        return key(node)
    end
    return graph, sort, add, pebble
end

local function prove(graph, sort, item, operate, context, levels)
    return bundles.prove(bundles.compile(graph, item, { [operate] = true }), sort, C(context or "home"), levels)
end

test("compilation preserves every independent acquisition alternative", function()
    local graph, sort, add = toy()
    local recipe = add("recipe", "make-device", "AND")
    local salvage = add("entity-mine", "independent-device", "AND")
    local item = add("item", "device", "OR", {
        recipe,
        salvage,
    })
    local build = add("entity-build-item", "device", "OR", { item })
    local operate = add("entity-operate", "device", "AND", { build })
    local before = table.deepcopy(graph)
    assert(prove(graph, sort, item, operate).rank == 0)
    for node_key, node in pairs(before.nodes) do
        assert(graph.nodes[node_key].op == node.op)
        assert(graph.nodes[node_key].num_pre == node.num_pre)
    end
    for edge_key, edge in pairs(before.edges) do
        assert(graph.edges[edge_key].start == edge.start and graph.edges[edge_key].stop == edge.stop)
    end
    assert(graph.nodes[item].num_pre == 2)
end)

test("supplied build replaces an earlier trigger ownership witness", function()
    local graph, sort, add = toy()
    local capsule = add("recipe", "make-capsule", "AND")
    local capture = add("entity-capture", "device", "AND", { capsule })
    local own = add("entity-own", "device", "OR", { capture })
    local salvage = add("entity-mine", "device", "AND", { own })
    local item = add("item", "device", "OR", { salvage })
    local operate = add("entity-operate", "device", "AND", { own })
    -- The real sort first owned the entity through capture, so its build route is later.
    local build = add("entity-build-item", "device", "OR", { item })
    gutils.add_edge(graph, build, own)
    local proof = prove(graph, sort, item, operate)
    assert(proof ~= nil and next(proof.leaves) == nil)
end)

test("OR keeps the earliest provider and honors optional research levels", function()
    local graph, sort, add = toy()
    local early = add("item", "early-provider", "OR")
    local late = add("item", "late-provider", "OR")
    local item = add("item", "device", "OR")
    local first = add("provider", "first", "AND", {
        item,
        early,
    })
    local second = add("provider", "second", "AND", {
        item,
        late,
    })
    local power = add("power", "", "OR", {
        first,
        second,
    })
    local operate = add("entity-operate", "device", "AND", { power })
    local early_ind = sort.node_to_context_inds[early][C("home")]
    local late_ind = sort.node_to_context_inds[late][C("home")]
    local proof = prove(graph, sort, item, operate)
    assert(proof.leaves[early_ind] and not proof.leaves[late_ind])
    proof = prove(graph, sort, item, operate, "home", {
        [early_ind] = 4,
        [late_ind] = 1,
    })
    assert(proof.rank == 1 and proof.leaves[late_ind] and not proof.leaves[early_ind])
end)

test("an external OR acquisition remains a valid ownership alternative", function()
    local graph, sort, add = toy()
    local capture = add("entity-capture", "device", "AND")
    local item = add("item", "device", "OR")
    local missing = add("item", "missing-tile", "OR", {}, false)
    local build = add("entity-build", "device", "AND", {
        item,
        missing,
    }, false)
    local own = add("entity-own", "device", "OR", {
        build,
        capture,
    })
    local operate = add("entity-operate", "device", "AND", { own })
    local proof = prove(graph, sort, item, operate)
    assert(proof.leaves[sort.node_to_context_inds[capture][C("home")]])
end)

test("missing external supplies are never granted by the item", function()
    local graph, sort, add = toy()
    local item = add("item", "device", "OR")
    local supply = add("fluid", "missing-supply", "OR", {}, false)
    local operate = add("entity-operate", "device", "AND", {
        item,
        supply,
    }, false)
    assert(prove(graph, sort, item, operate) == nil)
end)

test("a material produced downstream is an external boundary", function()
    local graph, sort, add = toy()
    local item = add("item", "device", "OR")
    local conversion = add("conversion", "", "AND", { item })
    local supply = add("item", "supply", "OR", { conversion })
    local operate = add("entity-operate", "device", "AND", {
        item,
        supply,
    })
    local proof = prove(graph, sort, item, operate)
    assert(proof.leaves[sort.node_to_context_inds[supply][C("home")]])
end)

test("a corridor with an unseeded AND cycle stays unproved", function()
    local graph, sort, add = toy()
    local item = add("item", "device", "OR")
    local loop = add("loop", "", "AND", { item }, false)
    local operate = add("entity-operate", "device", "AND", { loop }, false)
    gutils.add_edge(graph, operate, loop)
    assert(prove(graph, sort, item, operate) == nil)
end)

test("an OR exit seeds a cyclic corridor without inventing a source", function()
    local graph, sort, add = toy()
    local item = add("item", "device", "OR")
    local loop = add("loop", "", "OR", { item })
    local operate = add("entity-operate", "device", "AND", { loop })
    gutils.add_edge(graph, operate, loop)
    assert(prove(graph, sort, item, operate).rank == 0)
end)

test("operation elsewhere still needs an actual delivery witness", function()
    local graph, sort, add, pebble = toy()
    local item = add("item", "device", "OR")
    local supply = add("item", "away-supply", "OR", {}, "away")
    local operate = add("entity-operate", "device", "AND", {
        item,
        supply,
    }, "away")
    assert(prove(graph, sort, item, operate) == nil)
    local infrastructure = add("item", "delivery-infrastructure", "OR")
    logic.type_info["item-deliver"] = { context = true }
    local delivery = add("item-deliver", "device", "AND", {
        item,
        infrastructure,
    }, "away")
    gutils.add_edge(graph, delivery, item)
    pebble(item, "away")
    local proof = prove(graph, sort, item, operate)
    assert(proof ~= nil)
    assert(proof.leaves[sort.node_to_context_inds[infrastructure][C("home")]])
    assert(proof.leaves[sort.node_to_context_inds[supply][C("away")]])
end)

test("the corridor preserves ability-changing edges", function()
    local graph, sort, add = toy()
    sort.complex = true
    local item = add("item", "device", "OR", {}, "home | 00")
    local operate = add("entity-operate", "device", "AND", {}, "home | 01")
    gutils.add_edge(graph, item, operate, { abilities = fx.edge({ [2] = true }) })
    assert(prove(graph, sort, item, operate, "home | 00").rank == 0)
end)

test("a recipe downstream of the item remains an external acquisition", function()
    local graph, sort, add = toy()
    local item = add("item", "device", "OR")
    local recipe = add("recipe", "supply", "AND", { item })
    local operate = add("entity-operate", "device", "AND", {
        item,
        recipe,
    })
    local proof = prove(graph, sort, item, operate)
    assert(proof.leaves[sort.node_to_context_inds[recipe][C("home")]])
end)

test("all requested operations contribute their external requirements", function()
    local graph, sort, add = toy()
    local item = add("item", "device", "OR")
    local supply = add("item", "supply", "OR")
    local first = add("entity-operate", "first", "AND", { item })
    local second = add("entity-operate", "second", "AND", {
        item,
        supply,
    })
    local compiled = bundles.compile(graph, item, {
        [first] = true,
        [second] = true,
    })
    local proof = bundles.prove(compiled, sort, C("home"))
    assert(proof.leaves[sort.node_to_context_inds[supply][C("home")]])
end)

test("no requested operation means no compilation work or proof", function()
    local graph, sort, add = toy()
    local item = add("item", "device", "OR")
    local compiled = bundles.compile(graph, item, {})
    assert(not compiled.supported and next(compiled.nodes) == nil)
    assert(bundles.prove(compiled, sort, C("home")) == nil)
end)

print(passed .. " tests passed")
