-- Plain-Lua regressions for sharing entity supply with its architecture OR.
function table.deepcopy(object)
    local seen = {}
    local function copy(value)
        if type(value) ~= "table" then return value end
        if seen[value] ~= nil then return seen[value] end
        local result = {}
        seen[value] = result
        for k, v in pairs(value) do result[copy(k)] = copy(v) end
        return result
    end
    return copy(object)
end
function log(_) end
serpent = {
    block = tostring,
    line = tostring,
}
local seed = 1
package.loaded["src/lib/random/rng"] = {
    int = function(_, max)
        seed = (seed * 1103515245 + 12345) % 2147483648
        return math.floor(seed / 65536) % max + 1
    end,
}
local logic = {
    contexts = {},
    type_info = {
        start = {},
        room = { context = "room" },
        recipe = {},
        item = {},
        mine = {},
        ["item-craft"] = {},
        ["technology-trigger"] = { research_input = true },
        base = { relay = true },
        head = { relay = true },
        orand = { relay = true },
        sink = {},
    },
}
package.loaded["src/logic/state"] = logic
package.loaded["src/logic/init"] = logic
package.loaded["src/prototypes/data-utils"] = { get_prot = function() return nil end }
data = {
    raw = {
        planet = {},
        technology = {},
    },
}
local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
local reductions = require("src/logic/analysis/reductions")
local costs = require("src/cost/graph-cost-core")
local supply = require("src/logic/analysis/entity-build-item")
local bootstrap = require("src/logic/builders/bootstrap")
local fx = require("tests/unit/logic/contexts/contexts-for-tests")
local superpose = require("src/lib/graph/superpose")
logic.type_info["entity-build-item"] = {}
logic.type_info["entity-build-architecture"] = {}
logic.type_info["entity-build"] = {}
logic.type_info["group-supply"] = {}
local invariants = require("tests/graph-invariants")
local key = gutils.key

local function node(graph, kind, name, op, extra)
    extra = extra or {}
    extra.op = op
    local result = key(gutils.add_node(graph, kind, name, extra))
    if op == "AND" then graph.sources[result] = true end
    return result
end
local function fixture()
    local g = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local start = node(g, "start", "", "AND")
    logic.contexts = {}
    for _, name in pairs({
        "A",
        "B",
    }) do
        local room = node(g, "room", name, "OR")
        gutils.add_edge(g, start, room)
        logic.contexts[name] = true
        local item = node(g, "item", name, "OR", { cost = name == "A" and 3 or 5 })
        gutils.add_edge(g, room, item)
    end
    local building = node(g, "entity-build-item", "machine", "OR", {
        class = "entity",
        prot = "machine: machine",
    })
    local architecture = node(g, "entity-build-architecture", "machine", "OR")
    local build = node(g, "entity-build", "machine", "AND")
    local group = node(g, "group-supply", "machines", "OR", { mechanic = true })
    gutils.add_edge(g, building, architecture, { amount = 1 })
    gutils.add_edge(g, building, group)
    gutils.add_edge(g, architecture, build, { amount = 1 })
    -- Supply is available in either room; actual building also needs B.
    gutils.add_edge(g, key("room", "B"), build)
    for _, name in pairs({
        "A",
        "B",
    }) do
        gutils.add_edge(g, key("item", name), building, {
            acq_kind = "build",
            build_key = "place_result",
            amount = 1,
            identity_base = true,
            inds = { 2 },
        })
    end
    return g
end
local function same(a, b)
    for c, _ in pairs(a or {}) do assert((b or {})[c] ~= nil, "lost " .. c) end
    for c, _ in pairs(b or {}) do assert((a or {})[c] ~= nil, "added " .. c) end
end
local function structure(g)
    local lines = {}
    local function fields(v)
        if type(v) ~= "table" then return tostring(v) end
        local parts = {}
        for k, value in pairs(v) do
            if k ~= "pre" and k ~= "dep" then table.insert(parts, tostring(k) .. "=" .. fields(value)) end
        end
        table.sort(parts)
        return "{" .. table.concat(parts, ",") .. "}"
    end
    for k, n in pairs(g.nodes) do table.insert(lines, k .. fields(n)) end
    for k, e in pairs(g.edges) do table.insert(lines, k .. fields(e)) end
    table.sort(lines)
    return table.concat(lines, "\n")
end
local passed = 0
local function test(name, fn)
    fn()
    passed = passed + 1
    print("ok - " .. name)
end

test("multiple placing items remain OR alternatives, independent of build requirements", function()
    local full = fixture()
    local reduced = table.deepcopy(full)
    assert(supply.contract(reduced) == 1)
    assert(reduced.nodes[key("entity-build-item", "machine")] == nil)
    local target = supply.key(reduced, "machine")
    assert(reduced.nodes[target].num_pre == 2)
    for _, extra in pairs({
        {},
        {
        complex_contexts = true,
        home_contexts = true,
    },
    }) do
        local a, b = top.sort(full, nil, nil, extra), top.sort(reduced, nil, nil, extra)
        for k, _ in pairs(reduced.nodes) do same(a.node_to_context_inds[k], b.node_to_context_inds[k]) end
        same(a.node_to_context_inds[key("entity-build-item", "machine")], supply.context_inds(reduced, b, key("entity-build-item", "machine")))
        local found = false
        for c, ind in pairs(supply.context_inds(reduced, b, key("entity-build-item", "machine"))) do
            if top.context_room(c) == "A" then
                found = true
                assert(b.pebble_keys[ind] == target)
                local witness = top.path(reduced, { ind }, b)
                for _, rank in pairs(witness.inds or witness) do
                    if type(rank) == "number" then assert(b.pebble_keys[rank] ~= key("entity-build-item", "machine")) end
                end
                assert((b.node_to_context_inds[key("entity-build", "machine")] or {})[c] == nil)
            end
        end
        assert(found)
        assert(#b.pebble_keys < #a.pebble_keys)
    end
    for edge_key, _ in pairs(reduced.nodes[target].pre) do
        local edge = reduced.edges[edge_key]
        assert(edge.acq_kind == "build" and edge.build_key == "place_result" and edge.identity_base and edge.inds[1] == 2)
    end
    invariants.test(reduced)
    assert(reductions.expand_all(reduced) == 1)
    assert(structure(full) == structure(reduced))
end)

test("ordinary and slot prices and physical graph superposition remain equivalent", function()
    local full = fixture()
    local reduced = table.deepcopy(full)
    supply.contract(reduced)
    for _, slot in pairs({
        false,
        true,
    }) do
        local a = costs.compute(full, { "anywhere" }, function(_, c) return { c } end, nil, slot)
        local b = costs.compute(reduced, { "anywhere" }, function(_, c) return { c } end, nil, slot)
        for k, _ in pairs(reduced.nodes) do assert(math.abs(a[k].anywhere - b[k].anywhere) < 1e-6, k) end
    end
    local expected = superpose.union(full, full).graph
    local actual = superpose.union(reduced, full).graph
    assert(structure(expected) == structure(actual))
    assert(structure(expected) == structure(superpose.union(full, reduced).graph))
    assert(structure(expected) == structure(superpose.union(reduced, reduced).graph))
    invariants.test(actual)
end)

test("subdivided placement slots still own the entity supply OR", function()
    local g = fixture()
    supply.contract(g)
    local target = supply.key(g, "machine")
    gutils.make_orands(g)
    for edge_key, _ in pairs(g.nodes[target].pre) do
        local connector = g.nodes[g.edges[edge_key].start]
        local input = gutils.unique_pre(g, connector)
        local conns = gutils.subdivide_base_head(g, gutils.ekey(input))
        assert(conns.base.acq_kind == "build" and conns.head.acq_kind == "build")
        assert(conns.base.identity_base and conns.head.build_key == "place_result")
        local owner = gutils.get_owner(g, conns.head)
        assert(g.orand_to_parent[key(owner)] == target)
        assert(supply.is_node(g.nodes[target]))
    end
    invariants.test(g)
end)

test("empty supply stays unreachable; nontrivial nodes, output transforms and collisions stay explicit", function()
    local g = fixture()
    for edge_key, _ in pairs(table.deepcopy(g.nodes[key("entity-build-item", "machine")].pre)) do gutils.remove_edge(g, edge_key) end
    assert(supply.contract(g) == 1)
    assert(next(supply.context_inds(g, top.sort(g), key("entity-build-item", "machine"))) == nil)
    local changes = {
        function(g) g.nodes[key("entity-build-item", "machine")].cost = 1 end,
        function(g) g.nodes[key("entity-build-architecture", "machine")].mechanic = true end,
        function(g) gutils.add_edge(g, key("item", "A"), key("entity-build-architecture", "machine")) end,
        function(g) g.edges[gutils.ekey({
            start = key("entity-build-item", "machine"),
            stop = key("group-supply", "machines"),
        })].amount = 2 end,
        function(g) gutils.add_edge(g, key("entity-build-architecture", "machine"), key("group-supply", "machines")) end,
    }
    for _, change in pairs(changes) do
        g = fixture()
        change(g)
        assert(supply.contract(g) == 0)
    end
    logic.type_info.item.research_input = true
    assert(supply.contract(fixture()) == 0)
    logic.type_info.item.research_input = nil
end)
test("placement edge amounts and ability changes survive with alternative providers", function()
    local full = fixture()
    local input = full.edges[gutils.ekey({
        start = key("item", "A"),
        stop = key("entity-build-item", "machine"),
    })]
    input.amount = 2
    input.abilities = fx.edge({ [1] = false })
    local reduced = table.deepcopy(full)
    assert(supply.contract(reduced) == 1)
    for _, extra in pairs({
        {},
        {
            complex_contexts = true,
            home_contexts = true,
        },
    }) do
        local a = top.sort(full, nil, nil, extra)
        local b = top.sort(reduced, nil, nil, extra)
        for k, _ in pairs(reduced.nodes) do same(a.node_to_context_inds[k], b.node_to_context_inds[k]) end
    end
    local a = costs.compute(full, { "anywhere" }, function(_, c) return { c } end)
    local b = costs.compute(reduced, { "anywhere" }, function(_, c) return { c } end)
    for k, _ in pairs(reduced.nodes) do assert(math.abs(a[k].anywhere - b[k].anywhere) < 1e-6, k) end
    reductions.expand_all(reduced)
    assert(structure(full) == structure(reduced))
end)

test("bootstrap justification uses the surviving supply node, including after subdivision", function()
    local g = fixture()
    local grant = node(g, "entity-own-bootstrap-rooms", "machine", "OR")
    gutils.add_edge(g, key("room", "A"), grant)
    supply.contract(g)
    local target = supply.key(g, "machine")
    assert(bootstrap.justifications(g)[1].node_key == target)
    gutils.make_orands(g)
    assert(bootstrap.justifications(g)[1].node_key == target)
end)

print(passed .. " tests passed")
