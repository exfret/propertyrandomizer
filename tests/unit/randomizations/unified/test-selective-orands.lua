-- Selective expansion must prove a branch unclaimable without running claim side effects.
function table.deepcopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, child in pairs(value) do copy[key] = table.deepcopy(child) end
    return copy
end
function log(_) end
serpent = { block = tostring }
data = { raw = { technology = {} } }
local logic = {
    contexts = { A = true, B = true },
    type_info = {
        start = {}, room = { context = "room" }, item = {}, recipe = {},
        base = { relay = true }, head = { relay = true }, orand = { relay = true },
        technology = { context = true, home_carrier = true }, research = { research_input = true },
        ["item-craft"] = {},
    },
}
package.loaded["src/logic/state"] = logic
package.loaded["src/logic/init"] = logic
package.loaded["src/lib/random/rng"] = { int = function(_, max) return max end }
package.loaded["src/prototypes/data-utils"] = { get_prot = function() return nil end }
local gutils = require("src/lib/graph/graph-utils")
local policy = require("src/randomizations/unified/orand-policy")
local top = require("src/lib/sort/context-sort")
local invariants = require("tests/graph-invariants")
local fx = require("tests/unit/logic/contexts/contexts-for-tests")
local count = 0
local function test(name, fn)
    fn()
    count = count + 1
    print("ok - " .. name)
end
local function node(g, kind, name, op, extra)
    extra = extra or {}
    extra.op = op
    return gutils.key(gutils.add_node(g, kind, name, extra))
end
local function fixture(target_type, extra)
    local g = { nodes = {}, edges = {}, sources = {} }
    local start = node(g, "start", "", "AND")
    g.sources[start] = true
    local a = node(g, "room", "A", "OR")
    local b = node(g, "room", "B", "OR")
    gutils.add_edge(g, start, a)
    gutils.add_edge(g, start, b)
    local source = node(g, "item", "source", "OR")
    gutils.add_edge(g, b, source)
    local target = node(g, target_type or "item", "target", "OR")
    local edge = gutils.add_edge(g, source, target, extra or { amount = 3, abilities = fx.edge({ [1] = false }), inds = { [2] = true } })
    return g, source, target, gutils.ekey(edge)
end
local function branches(g)
    local n = 0
    for _, v in pairs(g.nodes) do if v.type == "orand" then n = n + 1 end end
    return n
end
local function unclaimable()
    return policy.precheck({ fixed = { may_claim = function() return false end, claim = function() error("claim was called during preflight") end } })
end
local function same(a, b, homes)
    local opts = { complex_contexts = true, home_contexts = homes ~= nil, home_sets = homes, choose_randomly = false }
    local sa, sb = top.sort(a, nil, nil, opts), top.sort(b, nil, nil, opts)
    for key, _ in pairs(b.nodes) do
        local ca, cb = sa.node_to_context_inds[key] or {}, sb.node_to_context_inds[key] or {}
        for ctx, _ in pairs(ca) do assert(cb[ctx], "lost " .. key .. " " .. ctx) end
        for ctx, _ in pairs(cb) do assert(ca[ctx], "gained " .. key .. " " .. ctx) end
    end
end
local homes = { ids = { 1, 2 }, sets = {
    [1] = { rooms = { A = true }, discovered = {} },
    [2] = { rooms = { A = true, B = true }, discovered = {} },
}, of = {}, }
test("unclaimable edges retain original metadata and no connector", function()
    local g, _, target, edge_key = fixture()
    local original = g.edges[edge_key]
    gutils.make_orands(g, unclaimable())
    assert(g.edges[edge_key] == original and original.amount == 3 and original.inds[2])
    assert(next(g.node_to_orands[target]) == nil)
    assert(branches(g) == 2, "room contexts still need relays")
    invariants.test(g)
end)
test("unknown handler conservatively retains every branch", function()
    local g = fixture()
    gutils.make_orands(g, policy.precheck({ unknown = {} }))
    assert(branches(g) == 4)
end)
test("zero-copy claims retain a connector without running claim", function()
    local g = fixture()
    local calls = 0
    gutils.make_orands(g, policy.precheck({ zero = { may_claim = function() return 0 end, claim = function() calls = calls + 1 return 0 end } }))
    assert(branches(g) == 4 and calls == 0)
end)
test("selection can prove an unknown handler inactive on an edge", function()
    local g = fixture()
    gutils.make_orands(g, policy.precheck({ unknown = {} }, function() return false end))
    assert(branches(g) == 2)
end)
test("potential claims stay explicit even if later blacklisted", function()
    local g = fixture()
    gutils.make_orands(g, policy.precheck({ h = { may_claim = function() return true end } }, function() return true end))
    assert(branches(g) == 4)
end)
test("production promises retain their branch identities", function()
    local g, _, target, e = fixture("item-craft")
    gutils.make_orands(g, unclaimable())
    assert(next(g.node_to_orands[target]) ~= nil and g.edges[e] == nil)
    g, _, target, e = fixture("item", { item_craft = true, amount = 2 })
    gutils.make_orands(g, unclaimable())
    assert(next(g.node_to_orands[target]) ~= nil and g.edges[e] == nil)
end)
test("research transform relay stays explicit and preserves homes", function()
    local g, _, target = fixture("research")
    local tech = node(g, "technology", "t", "AND")
    gutils.add_edge(g, target, tech)
    local before = table.deepcopy(g)
    gutils.make_orands(before)
    gutils.make_orands(g, unclaimable())
    assert(next(g.node_to_orands[target]) ~= nil)
    same(before, g, homes)
end)
test("fixed-input builders keep their existing direct-edge policy", function()
    local g, _, target, edge = fixture()
    g.nodes[target].fixed_inputs = true
    gutils.make_orands(g, policy.precheck({ unknown = {} }))
    assert(g.edges[edge] ~= nil and next(g.node_to_orands[target]) == nil)
end)
test("first-pass style input moves preserve direct edge metadata", function()
    local g, source, target, edge = fixture()
    gutils.make_orands(g, unclaimable())
    local trav = node(g, "item", "target-trav", "OR", { trav = true })
    gutils.redirect_edge_stop(g, edge, trav)
    local moved = g.edges[gutils.ekey({ start = source, stop = trav })]
    assert(moved.amount == 3 and moved.abilities ~= nil and moved.inds[2])
    assert(g.nodes[target].num_pre == 0 and g.nodes[trav].num_pre == 1)
    invariants.test(g)
end)
test("generated DAGs and cycles preserve surviving contexts", function()
    for seed = 1, 40 do
        local g, source, target = fixture()
        for i = 1, 14 do
            local v = node(g, "item", "v" .. i, "OR")
            local pre = i == 1 and source or gutils.key("item", "v" .. (i - 1))
            gutils.add_edge(g, pre, v, { abilities = fx.edge({ [(seed + i) % 2 + 1] = (seed + i) % 3 == 0 }) })
            if i % 3 == 0 then gutils.add_edge(g, source, v) end
            if i == 14 then
                gutils.add_edge(g, v, target)
                if seed % 2 == 0 then gutils.add_edge(g, v, source) end
            end
        end
        local before = table.deepcopy(g)
        gutils.make_orands(before)
        gutils.make_orands(g, unclaimable())
        same(before, g, homes)
        same(before, g, nil)
        invariants.test(g)
    end
end)
print(count .. " selective orand tests passed")
