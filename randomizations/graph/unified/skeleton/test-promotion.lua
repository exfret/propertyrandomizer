-- Plain-Lua regression tests for promotion (not loaded by the mod)
-- Run from the mod root: lua randomizations/graph/unified/skeleton/test-promotion.lua
--
-- The toy graph has two contexts, A and B
-- Item x is only reachable in A, item y only in B, and item z in both
-- Recipe r has vanilla ingredient z through a cut (subdivided) edge, and produces item p

-- Stand-ins for the Factorio environment
function table.deepcopy(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end
function log(msg) end
serpent = {
    block = tostring,
    line = tostring,
}
package.loaded["lib/random/rng"] = { int = function(_, max) return 1 end }
package.loaded["lib/logic/init"] = {
    contexts = {
        A = true,
        B = true,
    },
    type_info = {
        start = {},
        -- Emitter: sends the context named by the node
        room = { context = "room" },
        mine = {},
        item = {},
        recipe = {},
        base = {},
        head = {},
    },
}

local gutils = require("lib/graph/graph-utils")
local promotion = require("randomizations/graph/unified/skeleton/promotion")

local key = gutils.key

local function build_graph(p_is_mechanic)
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local function node(node_type, name, op, extra)
        extra = extra or {}
        extra.op = op
        gutils.add_node(graph, node_type, name, extra)
        return key(node_type, name)
    end
    local start = node("start", "", "AND")
    graph.sources[start] = true
    local room_a = node("room", "A", "OR")
    local room_b = node("room", "B", "OR")
    gutils.add_edge(graph, start, room_a)
    gutils.add_edge(graph, start, room_b)
    local rooms_for = {
        x = { room_a },
        y = { room_b },
        z = { start },
    }
    for name, pres in pairs(rooms_for) do
        local mine = node("mine", name, "AND")
        for _, pre in pairs(pres) do
            gutils.add_edge(graph, pre, mine)
        end
        gutils.add_edge(graph, mine, node("item", name, "OR"))
    end
    -- r's ingredient edge from z is subdivided and cut, as in the random graph
    local recipe = node("recipe", "r", "AND")
    local base = node("base", "z-r", "AND")
    local head = node("head", "z-r", "OR", { old_base = base })
    graph.nodes[base].old_head = head
    gutils.add_edge(graph, key("item", "z"), base)
    gutils.add_edge(graph, head, recipe)
    gutils.add_edge(graph, recipe, node("item", "p", "OR", { mechanic = p_is_mechanic }))
    return graph
end

local r = key("recipe", "r")
local x, y, z = key("item", "x"), key("item", "y"), key("item", "z")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

test("unpromised recipe gets exactly one anchor context", function()
    local prom = promotion.new({ graph = build_graph(false) })
    prom.promise_mechanics()
    assert(#prom.required_contexts(r) == 1)
end)

test("unpromised recipe can't combine ingredients that share no context", function()
    local prom = promotion.new({ graph = build_graph(false) })
    prom.promise_mechanics()
    local contexts = prom.required_contexts(r)
    assert(not (prom.candidate_ok(r, x, contexts) and prom.candidate_ok(r, y, contexts)))
end)

test("vanilla ingredient is always a valid fallback in the anchor context", function()
    local prom = promotion.new({ graph = build_graph(false) })
    prom.promise_mechanics()
    local contexts = prom.required_contexts(r)
    assert(prom.candidate_ok(r, z, contexts))
    prom.resolve(r, { z }, contexts)
end)

test("candidate_ok refuses an empty context list", function()
    local prom = promotion.new({ graph = build_graph(false) })
    assert(not pcall(prom.candidate_ok, r, x, {}))
end)

test("resolving anchors the recipe in its context", function()
    local prom = promotion.new({ graph = build_graph(false) })
    prom.promise_mechanics()
    local contexts = prom.required_contexts(r)
    local owner = prom.candidate_ok(r, x, contexts) and x or (prom.candidate_ok(r, y, contexts) and y or z)
    prom.resolve(r, { owner }, contexts)
    -- The recipe is now promised, so it keeps exactly that context
    local after = prom.required_contexts(r)
    assert(#after == 1 and after[1] == contexts[1])
end)

test("recipe needed for a mechanic in both contexts only accepts ingredients available in both", function()
    local prom = promotion.new({ graph = build_graph(true) })
    local failed = prom.promise_mechanics()
    assert(#failed == 0)
    local contexts = prom.required_contexts(r)
    assert(#contexts == 2)
    assert(not prom.candidate_ok(r, x, contexts))
    assert(not prom.candidate_ok(r, y, contexts))
    assert(prom.candidate_ok(r, z, contexts))
end)

print(num_passed .. " tests passed")
