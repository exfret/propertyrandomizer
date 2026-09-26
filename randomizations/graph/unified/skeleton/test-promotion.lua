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
local top = require("lib/graph/context-sort")

local key = gutils.key

local function build_graph(p_is_mechanic, x_not_automatable)
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
        -- Optionally, x can only be gotten in a way that can't be automated (like picking up loot)
        local extra
        if name == "x" and x_not_automatable then
            extra = {
                abilities = { [2] = false },
            }
        end
        gutils.add_edge(graph, mine, node("item", name, "OR"), extra)
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

-- Whether some complex context in the list is automatable (read through context-sort's accessors, since contexts can carry a home context too)
local function has_automatable(contexts)
    for _, context in pairs(contexts) do
        local abilities = top.context_abilities(context)
        if abilities ~= nil and string.sub(abilities, top.AUTOMATABILITY, top.AUTOMATABILITY) == "1" then
            return true
        end
    end
    return false
end

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

test("with complex contexts, an ingredient that can't be automated can't feed a mechanic that must stay automatable", function()
    -- Make x reachable in both rooms so only automatability tells x and z apart
    local graph = build_graph(true, true)
    gutils.add_edge(graph, key("room", "B"), key("mine", "x"))
    local prom = promotion.new({
        graph = graph,
        complex = true,
    })
    local failed = prom.promise_mechanics()
    assert(#failed == 0)
    local contexts = prom.required_contexts(r)
    assert(has_automatable(contexts))
    assert(not prom.candidate_ok(r, x, contexts))
    assert(prom.candidate_ok(r, z, contexts))
end)

-- A generic handler head: mechanic m needs whatever feeds its cut head, whose vanilla base comes from item z
-- Items x and z can both be gotten in both rooms, so only what their bases' connections gain or lose tells them apart
-- x_abilities and z_abilities are what each base keeps from its original edge, like a slot whose item can't be automated
local function build_head_graph(x_abilities, z_abilities)
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
    gutils.add_edge(graph, start, node("room", "A", "OR"))
    gutils.add_edge(graph, start, node("room", "B", "OR"))
    for _, name in pairs({
        "x",
        "z",
    }) do
        local mine = node("mine", name, "AND")
        gutils.add_edge(graph, start, mine)
        gutils.add_edge(graph, mine, node("item", name, "OR"))
    end
    local base_x = node("base", "x-m", "AND", {
        abilities = x_abilities,
    })
    local base_z = node("base", "z-m", "AND", {
        abilities = z_abilities,
    })
    local head = node("head", "z-m", "OR", {
        old_base = base_z,
    })
    graph.nodes[base_z].old_head = head
    gutils.add_edge(graph, key("item", "x"), base_x)
    gutils.add_edge(graph, key("item", "z"), base_z)
    -- x's base also feeds z's mine, so it sorts before m's head in every context like z's base does
    -- Otherwise where it sorts relative to the head would be up to the sort's tie-breaking, which changes between plain Lua runs
    gutils.add_edge(graph, base_x, key("mine", "z"))
    gutils.add_edge(graph, head, node("mine", "m", "AND", {
        mechanic = true,
    }))
    return graph
end

local head_m = key("head", "z-m")
local base_x, base_z = key("base", "x-m"), key("base", "z-m")
local mechanic_m = key("mine", "m")

-- Promotion over the head graph with m's mechanic contexts promised, and the contexts m's head must keep
local function promoted_head_graph(x_abilities, connection_abilities, z_abilities)
    local prom = promotion.new({
        graph = build_head_graph(x_abilities, z_abilities),
        complex = true,
        connection_abilities = connection_abilities,
    })
    assert(#prom.promise_mechanics() == 0)
    local contexts = prom.required_contexts(mechanic_m)
    assert(has_automatable(contexts))
    return prom, contexts
end

test("subdividing an edge keeps its abilities on the connection between base and head", function()
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    gutils.add_node(graph, "item", "a", {
        op = "OR",
    })
    gutils.add_node(graph, "mine", "b", {
        op = "AND",
    })
    local edge = gutils.add_edge(graph, key("item", "a"), key("mine", "b"), {
        abilities = {
            [2] = false,
        },
    })
    local conns = gutils.subdivide_base_head(graph, gutils.ekey(edge))
    local connection = graph.edges[gutils.ekey({
        start = key(conns.base),
        stop = key(conns.head),
    })]
    assert(connection.abilities[2] == false)
    -- The connection has its own copy
    connection.abilities[2] = true
    assert(conns.base.abilities[2] == false)
end)

test("a base whose connection loses automatability can't feed a head whose dependent must stay automatable", function()
    local prom, contexts = promoted_head_graph({
        [2] = false,
    })
    assert(not prom.head_candidate_ok(head_m, base_x, contexts))
    assert(prom.head_candidate_ok(head_m, base_z, contexts))
    -- Without the lost ability, x is as good as z
    local plain_prom, plain_contexts = promoted_head_graph(nil)
    assert(plain_prom.head_candidate_ok(head_m, base_x, plain_contexts))
end)

test("a handler's connection abilities count instead of the base's own", function()
    -- z's own edge can't be automated, so m can't be either
    local own_prom = promotion.new({
        graph = build_head_graph(nil, {
            [2] = false,
        }),
        complex = true,
    })
    assert(#own_prom.promise_mechanics() == 0)
    assert(not has_automatable(own_prom.required_contexts(mechanic_m)))
    -- Unless the handler says the connection can be
    local prom, contexts = promoted_head_graph(nil, function(base, head)
        return nil
    end, {
        [2] = false,
    })
    assert(prom.head_candidate_ok(head_m, base_z, contexts))
end)

test("rewiring a promised head to a base whose connection loses automatability is refused", function()
    local prom, contexts = promoted_head_graph({
        [2] = false,
    })
    prom.resolve_head(head_m, base_z, contexts)
    assert(not prom.try_rewires({
        {
            node_key = head_m,
            remove = {
                base_z,
            },
            add = base_x,
        },
    }, false))
    local plain_prom, plain_contexts = promoted_head_graph(nil)
    plain_prom.resolve_head(head_m, base_z, plain_contexts)
    assert(plain_prom.try_rewires({
        {
            node_key = head_m,
            remove = {
                base_z,
            },
            add = base_x,
        },
    }, false))
end)

test("a head can be detached only if nothing promised needs it, and a refused detach changes nothing", function()
    local prom, contexts = promoted_head_graph(nil)
    prom.resolve_head(head_m, base_z, contexts)
    local detach = {
        {
            node_key = head_m,
            remove = {
                base_z,
            },
            detach = true,
        },
    }
    -- m is a mechanic, so its head is promised
    assert(not prom.try_rewires(detach, true))
    assert(#prom.pre_keys_of(head_m) == 1)
    assert(prom.head_candidate_ok(head_m, base_z, contexts))

    -- Without the mechanic, nothing needs the head
    local graph = build_head_graph(nil)
    graph.nodes[mechanic_m].mechanic = nil
    local free_prom = promotion.new({
        graph = graph,
        complex = true,
    })
    free_prom.promise_mechanics()
    assert(#free_prom.promised_contexts(head_m) == 0)
    assert(free_prom.try_rewires(detach, true))
    assert(#free_prom.pre_keys_of(head_m) == 0)
    -- Detached, the head isn't fed by its vanilla base anymore, so it can't back anything
    assert(#free_prom.required_contexts(mechanic_m) == 0)
end)

test("a head that starts detached isn't fed by its vanilla base, and a rewire can still give it one", function()
    local graph = build_head_graph(nil)
    graph.nodes[mechanic_m].mechanic = nil
    graph.nodes[head_m].starts_detached = true
    local prom = promotion.new({
        graph = graph,
        complex = true,
    })
    prom.promise_mechanics()
    assert(#prom.pre_keys_of(head_m) == 0)
    -- Nothing reaches m through the head, so it has no context at all
    assert(#prom.required_contexts(mechanic_m) == 0)
    assert(prom.try_rewires({
        {
            node_key = head_m,
            remove = {},
            add = base_x,
        },
    }, true))
    assert(#prom.pre_keys_of(head_m) == 1)
end)

test("models built for first pass don't count on a head that starts detached, before or after subdividing", function()
    -- A source feeds a unit's placing through an edge that's only there to be claimed (a friendly biter)
    local function friendly_graph()
        local graph = {
            nodes = {},
            edges = {},
            sources = {},
        }
        gutils.add_node(graph, "start", "", {
            op = "AND",
        })
        graph.sources[key("start", "")] = true
        gutils.add_node(graph, "item", "u", {
            op = "OR",
        })
        local edge = gutils.add_edge(graph, key("start", ""), key("item", "u"), {
            starts_detached = true,
        })
        return graph, edge
    end
    local function reachable(graph)
        return next(top.sort(graph).node_to_context_inds[key("item", "u")] or {}) ~= nil
    end

    local graph = friendly_graph()
    assert(reachable(graph))
    gutils.detach_starting_heads(graph)
    assert(not reachable(graph))

    local subdivided, edge = friendly_graph()
    local conns = gutils.subdivide_base_head(subdivided, gutils.ekey(edge))
    assert(conns.head.starts_detached and reachable(subdivided))
    gutils.detach_starting_heads(subdivided)
    assert(not reachable(subdivided))
    -- The head and its vanilla base are still there, so its slot can be claimed and later given a base
    assert(subdivided.nodes[key(conns.head)] ~= nil and subdivided.nodes[key(conns.base)] ~= nil)
end)

print(num_passed .. " tests passed")
