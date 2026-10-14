-- Plain-Lua regressions for sharing recipe unlock forwarding ORs.
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
local unlock = require("src/logic/analysis/unlock-contraction")
local handler = require("src/randomizations/unified/handlers/recipe-tech-unlocks")
local fx = require("tests/unit/logic/contexts/contexts-for-tests")
local superpose = require("src/lib/graph/superpose")
logic.type_info["recipe-tech-unlock"] = {}
logic.type_info["recipe-unlock"] = {}
logic.type_info.technology = { context = true, home_carrier = true }
logic.type_info["entity-operate"] = {}
local invariants = require("tests/graph-invariants")
local key = gutils.key

local function node(graph, kind, name, op, extra)
    extra = extra or {}
    extra.op = op
    local result = key(gutils.add_node(graph, kind, name, extra))
    if op == "AND" then graph.sources[result] = true end
    return result
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

local function fixture(empty)
    local g = { nodes = {}, edges = {}, sources = {} }
    local start = node(g, "start", "", "AND")
    logic.contexts = {}
    for _, name in pairs({ "A", "B" }) do
        local room = node(g, "room", name, "OR")
        gutils.add_edge(g, start, room)
        logic.contexts[name] = true
        local tech = node(g, "technology", name, "AND")
        gutils.add_edge(g, room, tech)
    end
    local source = node(g, "recipe-tech-unlock", "example", "OR", { class = "recipe", prot = "recipe: example" })
    local forward = node(g, "recipe-unlock", "example", "OR", { class = "recipe", prot = "recipe: example" })
    local recipe = node(g, "recipe", "example", "AND", { cost = 3, slot_additional_cost = 2 })
    if not empty then
        for _, name in pairs({ "A", "B" }) do gutils.add_edge(g, key("technology", name), source) end
    end
    gutils.add_edge(g, source, forward)
    gutils.add_edge(g, forward, recipe)
    -- A recipe only made in A has narrower contexts than its unlock OR; virtual queries must use the OR, not the recipe.
    gutils.add_edge(g, key("room", "A"), recipe)
    return g, source, forward, recipe
end

test("multi-technology and empty ORs preserve surviving contexts, virtual witnesses and exact expansion", function()
    for _, empty in pairs({ false, true }) do
        local full, source, forward, recipe = fixture(empty)
        local reduced = table.deepcopy(full)
        assert(unlock.share_forwarders(reduced) == 1)
        assert(unlock.share_forwarders(reduced) == 0)
        assert(reduced.nodes[forward] == nil and reduced.nodes[source] ~= nil)
        assert(unlock.forwarding_key(reduced, "example") == source)
        for _, extra in pairs({ {}, { complex_contexts = true, home_contexts = true } }) do
            local a = top.sort(full, nil, nil, table.deepcopy(extra))
            local b = top.sort(reduced, nil, nil, table.deepcopy(extra))
            for k, _ in pairs(reduced.nodes) do same(a.node_to_context_inds[k], b.node_to_context_inds[k]) end
            same(a.node_to_context_inds[forward], unlock.context_inds(reduced, b, forward))
            if empty then
                assert(next(b.node_to_context_inds[recipe]) == nil)
            else
                assert(#b.pebble_keys < #a.pebble_keys)
                for _, ind in pairs(unlock.context_inds(reduced, b, forward)) do
                    assert(b.pebble_keys[ind] == source)
                    top.path(reduced, { ind }, b)
                end
            end
        end
        invariants.test(reduced)
        assert(reductions.expand_all(reduced) == 1)
        assert(structure(full) == structure(reduced))
    end
end)

test("partial expansion restores the boundary before adding machine or technology alternatives", function()
    local full, source, forward = fixture()
    local reduced = table.deepcopy(full)
    unlock.share_forwarders(reduced)
    assert(unlock.expand(reduced, "example") == source)
    assert(structure(full) == structure(reduced))
    assert(unlock.expand(reduced, "example") == source)
    local machine = node(reduced, "entity-operate", "fixed", "AND")
    gutils.add_edge(reduced, key("room", "B"), machine)
    gutils.add_edge(reduced, machine, forward)
    assert(unlock.share_forwarders(reduced) == 0)
    invariants.test(reduced)
end)

test("ordinary and slot prices and graph combinations preserve the full shape", function()
    local full = fixture()
    local reduced = table.deepcopy(full)
    unlock.share_forwarders(reduced)
    for _, slot in pairs({ false, true }) do
        local a = costs.compute(full, { "anywhere" }, function(_, c) return { c } end, nil, slot)
        local b = costs.compute(reduced, { "anywhere" }, function(_, c) return { c } end, nil, slot)
        for k, _ in pairs(reduced.nodes) do assert(a[k].anywhere == b[k].anywhere, k) end
    end
    local expected = superpose.union(full, full).graph
    assert(structure(expected) == structure(superpose.union(reduced, full).graph))
    assert(structure(expected) == structure(superpose.union(full, reduced).graph))
end)

test("sharing does not activate claiming, including empty ORs and after OR subdivision", function()
    for _, empty in pairs({ false, true }) do
        local graph, source, forward, recipe = fixture(empty)
        handler.initialize()
        local old_edge = graph.edges[gutils.ekey({ start = forward, stop = recipe })]
        assert(handler.claim(graph, graph.nodes[forward], graph.nodes[recipe], old_edge) == nil)
        unlock.share_forwarders(graph)
        gutils.make_orands(graph)
        local edge = graph.edges[gutils.ekey({ start = source, stop = recipe })]
        assert(unlock.forwards_unlock(edge))
        assert(unlock.forwards_unlock(edge, "example") and not unlock.forwards_unlock(edge, "other"))
        assert(handler.claim(graph, graph.nodes[source], graph.nodes[recipe], edge) == nil)
        if not empty then
            -- A genuine direct edge retains its original handler behavior.
            assert(handler.claim(graph, graph.nodes[source], graph.nodes[recipe], { start = source, stop = recipe }) == 1)
        end
        invariants.test(graph)
    end
end)

test("technology input transformations and quantities survive while unlock capability prices stay free", function()
    local full, source, forward = fixture()
    full.nodes[key("technology", "A")].cost = 8
    full.nodes[key("technology", "B")].cost = 12
    local input = full.edges[gutils.ekey({ start = key("technology", "A"), stop = source })]
    input.amount = 2
    input.abilities = fx.edge({ [1] = false })
    input.inds = { 7 }
    full.nodes[source].cost = 5
    local reduced = table.deepcopy(full)
    assert(unlock.share_forwarders(reduced) == 1)
    for _, extra in pairs({ {}, { complex_contexts = true, home_contexts = true } }) do
        local a = top.sort(full, nil, nil, table.deepcopy(extra))
        local b = top.sort(reduced, nil, nil, table.deepcopy(extra))
        for k, _ in pairs(reduced.nodes) do same(a.node_to_context_inds[k], b.node_to_context_inds[k]) end
        same(a.node_to_context_inds[forward], unlock.context_inds(reduced, b, forward))
    end
    for _, slot in pairs({ false, true }) do
        local a = costs.compute(full, { "anywhere" }, function(_, c) return { c } end, nil, slot)
        local b = costs.compute(reduced, { "anywhere" }, function(_, c) return { c } end, nil, slot)
        assert(a[forward].anywhere == 0 and a[source].anywhere > 0)
        for k, _ in pairs(reduced.nodes) do assert(a[k].anywhere == b[k].anywhere, k) end
    end
    reductions.expand_all(reduced)
    assert(structure(full) == structure(reduced))
end)

test("debt touching the removed identity remains explicit; upstream technology debt still reaches the recipe", function()
    local full, source, forward, recipe = fixture()
    local old = table.deepcopy(full)
    local old_machine = node(old, "entity-operate", "old-fixed", "AND")
    gutils.add_edge(old, key("room", "A"), old_machine)
    gutils.add_edge(old, old_machine, forward)
    local debt = superpose.union(full, old)
    local g = table.deepcopy(full)
    assert(unlock.share_forwarders(g, debt) == 0)
    assert(#superpose.add_debt(g, debt) > 0)
    invariants.test(g)

    local newer = table.deepcopy(full)
    gutils.remove_edge(newer, gutils.ekey({ start = key("technology", "A"), stop = source }))
    gutils.remove_edge(newer, gutils.ekey({ start = key("technology", "B"), stop = source }))
    local upstream = superpose.union(newer, full)
    assert(unlock.share_forwarders(newer, upstream) == 1)
    gutils.make_orands(newer)
    local before = top.sort(newer)
    assert(next(before.node_to_context_inds[recipe]) == nil)
    local added, skipped = superpose.add_debt(newer, upstream)
    assert(#added == 2 and #skipped == 0)
    local after = superpose.continue_through_debt(newer, before, added)
    assert(next(after.node_to_context_inds[recipe]) ~= nil)
    same(top.sort(full).node_to_context_inds[recipe], after.node_to_context_inds[recipe])
    invariants.test(newer)

    for _, block in pairs({ "goal", "old-node", "joined-edge" }) do
        local g = table.deepcopy(full)
        local debt = { graph = g, debt_edges = {}, old_nodes = {}, goals = {} }
        if block == "goal" then debt.goals[forward] = { A = true }
        elseif block == "old-node" then debt.old_nodes[forward] = true
        else
            local edge = gutils.add_edge(g, source, recipe)
            debt.debt_edges[gutils.ekey(edge)] = true
        end
        assert(unlock.share_forwarders(g, debt) == 0)
    end
    local opaque = { graph = full, debt_edges = {}, old_nodes = {}, is_goal = function() return true end }
    assert(unlock.share_forwarders(table.deepcopy(full), opaque) == 0)
end)

test("transformed links, costs, extra outputs, collisions and research-home roles stay explicit", function()
    for _, change in pairs({
        function(g, source, forward, recipe) g.nodes[forward].cost = 1 end,
        function(g, source, forward, recipe) g.nodes[forward].mechanic = true end,
        function(g, source, forward, recipe) g.edges[gutils.ekey({ start = source, stop = forward })].amount = 1 end,
        function(g, source, forward, recipe) g.edges[gutils.ekey({ start = forward, stop = recipe })].amount = 1 end,
        function(g, source, forward, recipe) g.edges[gutils.ekey({ start = source, stop = forward })].abilities = fx.edge({ [1] = false }) end,
        function(g, source, forward, recipe) gutils.add_edge(g, source, recipe) end,
        function(g, source, forward, recipe) gutils.add_edge(g, forward, key("room", "B")) end,
        function(g, source, forward, recipe) gutils.add_edge(g, key("room", "B"), forward) end,
    }) do
        local g, source, forward, recipe = fixture()
        change(g, source, forward, recipe)
        assert(unlock.share_forwarders(g) == 0)
    end
    for _, field in pairs({ "context", "research_input", "home_carrier", "relay" }) do
        local g = fixture()
        logic.type_info["recipe-tech-unlock"][field] = true
        assert(unlock.share_forwarders(g) == 0)
        logic.type_info["recipe-tech-unlock"][field] = nil
    end
end)

print(passed .. " tests passed")
