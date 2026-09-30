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
        -- Like the logic's own (lib/logic/abstract.lua), for graphs with orands and false
        orand = {},
        ["false"] = {},
    },
}
package.loaded["lib/logic/state"] = package.loaded["lib/logic/init"]

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

test("a planet-locked recipe keeps every context it had, so it can't take an ingredient that can't be automated", function()
    -- x can be gotten in both rooms, but never automated
    local graph = build_graph(false, true)
    gutils.add_edge(graph, key("room", "B"), key("mine", "x"))
    -- Every context r had before randomization (with its vanilla ingredient connected), as promotion gets them from first pass's sort
    local before = table.deepcopy(graph)
    gutils.connect_base_head(before, key("base", "z-r"), key("head", "z-r"))
    local planet_locked = {
        [r] = {},
    }
    for context, _ in pairs(top.sort(before, nil, nil, {
        complex_contexts = true,
        home_contexts = true,
    }).node_to_context_inds[r]) do
        if top.context_home(context) == nil then
            planet_locked[r][context] = true
        end
    end
    local prom = promotion.new({
        graph = graph,
        complex = true,
        planet_locked = planet_locked,
    })
    assert(#prom.promise_mechanics() == 0)
    local contexts = prom.required_contexts(r)
    assert(has_automatable(contexts))
    assert(not prom.candidate_ok(r, x, contexts))
    assert(prom.candidate_ok(r, z, contexts))
    -- Without the lock, r only keeps one anchor context, which asks for no abilities
    local plain = promotion.new({
        graph = build_graph(false, true),
        complex = true,
    })
    plain.promise_mechanics()
    assert(not has_automatable(plain.required_contexts(r)))
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

    -- Unified's graphs have orands: make_orands puts an AND node between the claimed edge and the OR node it went into, and detaching mustn't leave that orand with nothing to need (a source, which made spoofed spoil results and entity positions free everywhere in first pass's sort of the game)
    local with_orands = friendly_graph()
    gutils.make_orands(with_orands)
    assert(reachable(with_orands))
    gutils.detach_starting_heads(with_orands)
    assert(not reachable(with_orands))
    for node_key, node in pairs(with_orands.nodes) do
        if node.type == "orand" then
            assert(next(top.sort(with_orands).node_to_context_inds[node_key]) == nil, "a detached orand is reached")
        end
    end

    local subdivided, edge = friendly_graph()
    local conns = gutils.subdivide_base_head(subdivided, gutils.ekey(edge))
    assert(conns.head.starts_detached and reachable(subdivided))
    gutils.detach_starting_heads(subdivided)
    assert(not reachable(subdivided))
    -- The head and its vanilla base are still there, so its slot can be claimed and later given a base
    assert(subdivided.nodes[key(conns.head)] ~= nil and subdivided.nodes[key(conns.base)] ~= nil)
end)

test("a head's new base only has to come before the head's dependent, like a resource gaining a mining fluid", function()
    -- Mechanic m (mining a resource) needs its head (the fluid slot) and item w
    -- The head's vanilla base is free (fed by start, like needing no fluid), so the head sorts near the start
    -- Base late (a fluid) is at the end of a chain from start and feeds w's mine, so it sorts after the head but before m
    -- Base after is fed by m's own product, so it sorts after m
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
    local base_free = node("base", "free-m", "AND")
    gutils.add_edge(graph, start, base_free)
    local head = node("head", "free-m", "OR", {
        old_base = base_free,
    })
    graph.nodes[base_free].old_head = head
    local m = node("mine", "m", "AND", {
        mechanic = true,
    })
    gutils.add_edge(graph, head, m)
    local prev = start
    for _, name in pairs({
        "c1",
        "c2",
    }) do
        local mine = node("mine", name, "AND")
        gutils.add_edge(graph, prev, mine)
        prev = node("item", name, "OR")
        gutils.add_edge(graph, mine, prev)
    end
    local base_late = node("base", "late-m", "AND")
    gutils.add_edge(graph, prev, base_late)
    local mine_w = node("mine", "w", "AND")
    gutils.add_edge(graph, base_late, mine_w)
    local item_w = node("item", "w", "OR")
    gutils.add_edge(graph, mine_w, item_w)
    gutils.add_edge(graph, item_w, m)
    local item_m = node("item", "m", "OR")
    gutils.add_edge(graph, m, item_m)
    local base_after = node("base", "after-m", "AND")
    gutils.add_edge(graph, item_m, base_after)

    local prom = promotion.new({
        graph = graph,
    })
    assert(#prom.promise_mechanics() == 0)
    local contexts = prom.required_contexts(m)
    assert(#contexts > 0)
    -- The ranks this is about, checked so a change in the sort's tie-breaking can't make the test pass vacuously: the head is one step from start and base late ends a chain, so the sort's first-open-node pick under the rng stub takes the head first in either order of start's dependents
    for _, context in pairs(contexts) do
        assert(prom.rank(head, context) < prom.rank(base_late, context))
        assert(prom.rank(base_late, context) < prom.rank(m, context))
        assert(prom.rank(m, context) < prom.rank(base_after, context))
    end
    -- Bounded by the head's own rank, base late would be refused and the head could only ever keep its free base
    assert(prom.head_candidate_ok(head, base_late, contexts))
    -- A base that needs the dependent itself would be a cycle
    assert(not prom.head_candidate_ok(head, base_after, contexts))
    -- Resolving keeps the head and m established (resolve_head errors otherwise)
    prom.resolve_head(head, base_late, contexts)
    assert(prom.head_candidate_ok(head, base_late, contexts))
end)

-- Whether node_key is among the nodes currently feeding the recipe in promotion's graph
local function recipe_needs(prom, node_key)
    for _, pre_key in pairs(prom.pre_keys_of(r)) do
        if pre_key == node_key then
            return true
        end
    end
    return false
end

test("a recipe can require a further category node that comes before it, like the fluid category of its planned shape", function()
    local graph = build_graph(true)
    -- A crafter z's mine also needs, so it sorts before r in every context
    local crafter = key("mine", "crafter")
    gutils.add_node(graph, "mine", "crafter", {
        op = "AND",
    })
    gutils.add_edge(graph, key("start", ""), crafter)
    gutils.add_edge(graph, crafter, key("mine", "z"))
    -- A fresh promotion state has it (a misplaced block once defined it inside try_rewires, so every game with recipe shapes crashed before any rewire ran)
    local prom = promotion.new({
        graph = graph,
    })
    assert(#prom.promise_mechanics() == 0)
    assert(prom.require_recipe_category(r, crafter))
    assert(recipe_needs(prom, crafter))
    -- Asking again changes nothing
    assert(prom.require_recipe_category(r, crafter))
end)

test("a recipe can't require a category node only its own product leads to, and is left as it was", function()
    local graph = build_graph(true)
    local crafter = key("mine", "crafter")
    gutils.add_node(graph, "mine", "crafter", {
        op = "AND",
    })
    gutils.add_edge(graph, key("item", "p"), crafter)
    local prom = promotion.new({
        graph = graph,
    })
    assert(#prom.promise_mechanics() == 0)
    assert(not prom.require_recipe_category(r, crafter))
    assert(not recipe_needs(prom, crafter))
end)

----------------------------------------------------------------------
-- Debt mode: promotion over a superposition of two worlds (see lib/graph/superpose.lua)
----------------------------------------------------------------------

local superpose = require("lib/graph/superpose")

local lava, p, q, s = key("item", "lava"), key("item", "p"), key("item", "q"), key("recipe", "s")
local use_p = key("mine", "use-p")

-- Two worlds where lava moved from room A to room B, like a planetary ocean swap: the old world's pump in A is the debt edge
-- Pumps are built from z, so z ranks before lava wherever there's lava
-- Recipe r takes lava through a cut edge and makes p; recipe s takes z through a cut edge, needs room A, and makes mechanic q
-- Item p is a mechanic, unless p_used_only_in_a puts a mechanic that uses p in room A in its place
-- The optional is_goal (default: the mechanics' pebbles, as for transported goals, where a recipe only counts if a planet had it locked) says which pebbles only the old world has must still be kept
-- Returns the new world with its cut heads (as promotion gets it) and promotion's debt for the old world
local function build_debt_worlds(opts)
    opts = opts or {}
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
    for _, room in pairs({
        "A",
        "B",
    }) do
        gutils.add_edge(graph, start, node("room", room, "OR"))
    end
    local mine_z = node("mine", "z", "AND")
    gutils.add_edge(graph, start, mine_z)
    gutils.add_edge(graph, mine_z, node("item", "z", "OR"))
    -- Both rooms can build a pump, but only B's pumps lava in the new world
    for _, room in pairs({
        "A",
        "B",
    }) do
        local pump = node("mine", "pump-" .. room, "AND")
        gutils.add_edge(graph, key("room", room), pump)
        gutils.add_edge(graph, z, pump)
    end
    node("item", "lava", "OR")
    gutils.add_edge(graph, key("mine", "pump-B"), lava)
    -- Cut ingredient edges, as in the random graph
    local function cut_ingredient(material_key, recipe_key)
        local name = material_key .. " -> " .. recipe_key
        local base = node("base", name, "AND")
        local head = node("head", name, "OR", {
            old_base = base,
        })
        graph.nodes[base].old_head = head
        gutils.add_edge(graph, material_key, base)
        gutils.add_edge(graph, head, recipe_key)
    end
    node("recipe", "r", "AND")
    cut_ingredient(lava, r)
    gutils.add_edge(graph, r, node("item", "p", "OR", {
        mechanic = not opts.p_used_only_in_a or nil,
    }))
    if opts.p_used_only_in_a then
        node("mine", "use-p", "AND", {
            mechanic = true,
        })
        gutils.add_edge(graph, p, use_p)
        gutils.add_edge(graph, key("room", "A"), use_p)
    end
    node("recipe", "s", "AND")
    cut_ingredient(z, s)
    gutils.add_edge(graph, key("room", "A"), s)
    gutils.add_edge(graph, s, node("item", "q", "OR", {
        mechanic = true,
    }))
    -- The old world pumped lava in A instead
    local old = table.deepcopy(graph)
    gutils.remove_edge(old, gutils.ekey({
        start = key("mine", "pump-B"),
        stop = lava,
    }))
    gutils.add_edge(old, key("mine", "pump-A"), lava)
    local union = superpose.union(graph, old)
    return graph, {
        graph = union.graph,
        debt_edges = union.debt_edges,
        old_nodes = union.old_nodes,
        is_goal = opts.is_goal or function(node_key, context)
            return node_key == p or node_key == q or node_key == use_p
        end,
    }
end

-- Promised pebbles as a set of "node_key @ context"
local function pebble_set(pebbles)
    local set = {}
    for _, pebble in pairs(pebbles) do
        set[pebble.node_key .. " @ " .. pebble.context] = true
    end
    return set
end

-- Runs fn with the sort's random choices drawn from a seeded generator instead of always the first open node
local rng_stub = package.loaded["lib/random/rng"]
local function with_seed(seed, fn)
    local rng_state = seed
    local old_int = rng_stub.int
    rng_stub.int = function(_, max)
        rng_state = (rng_state * 1103515245 + 12345) % 2147483648
        -- The low bits of this generator repeat quickly, so use the high ones
        return math.floor(rng_state / 65536) % max + 1
    end
    local is_ok, err = pcall(fn)
    rng_stub.int = old_int
    if not is_ok then
        error(err, 0)
    end
end

test("in debt mode, a goal only the old world backs is promised but owed, and only solvent promises count for the game", function()
    local graph, debt = build_debt_worlds()
    local prom = promotion.new({
        graph = graph,
        debt = debt,
    })
    assert(#prom.promise_mechanics() == 0)
    local owed = prom.owed_pebbles()
    assert(#owed == 1 and owed[1].node_key == p and owed[1].context == "A")
    assert(prom.is_solvent(p, "B") and not prom.is_solvent(p, "A"))
    local solvent = pebble_set(prom.promised_pebbles())
    assert(solvent[p .. " @ B"] and solvent[q .. " @ A"])
    assert(solvent[p .. " @ A"] == nil)
end)

test("a choice that backs an owed goal without debt pays for it", function()
    local graph, debt = build_debt_worlds()
    local prom = promotion.new({
        graph = graph,
        debt = debt,
    })
    prom.promise_mechanics()
    local contexts = prom.required_contexts(r)
    assert(#contexts == 2)
    assert(prom.candidate_ok(r, z, contexts))
    prom.resolve(r, {
        z,
    }, contexts)
    assert(#prom.owed_pebbles() == 0 and prom.num_paid == 1)
    assert(pebble_set(prom.promised_pebbles())[p .. " @ A"])
end)

test("the vanilla fallback is still valid, and leaves the goal owed", function()
    local graph, debt = build_debt_worlds()
    local prom = promotion.new({
        graph = graph,
        debt = debt,
    })
    prom.promise_mechanics()
    local contexts = prom.required_contexts(r)
    assert(prom.candidate_ok(r, lava, contexts))
    prom.resolve(r, {
        lava,
    }, contexts)
    assert(#prom.owed_pebbles() == 1 and prom.num_paid == 0)
end)

test("a recipe pebble that's a goal (like one the old world had locked to a planet) is promised, and owed while only the debt backs it", function()
    local graph, debt = build_debt_worlds({
        is_goal = function(node_key, context)
            return node_key == p or node_key == r
        end,
    })
    local prom = promotion.new({
        graph = graph,
        debt = debt,
    })
    assert(#prom.promise_mechanics() == 0)
    local owed = pebble_set(prom.owed_pebbles())
    assert(owed[r .. " @ A"] and owed[p .. " @ A"])
    -- Backing the recipe without the debt pays for both
    prom.resolve(r, {
        z,
    }, prom.required_contexts(r))
    assert(#prom.owed_pebbles() == 0)
end)

test("a mechanic pebble only the old world has isn't promised unless it's a goal", function()
    local graph, debt = build_debt_worlds({
        is_goal = function(node_key, context)
            return false
        end,
    })
    local prom = promotion.new({
        graph = graph,
        debt = debt,
    })
    assert(#prom.promise_mechanics() == 0)
    assert(#prom.owed_pebbles() == 0)
    local contexts = prom.promised_contexts(p)
    assert(#contexts == 1 and contexts[1] == "B")
end)

test("a recipe whose promises are all owed also keeps a context it's solvent in", function()
    local graph, debt = build_debt_worlds({
        p_used_only_in_a = true,
    })
    local prom = promotion.new({
        graph = graph,
        debt = debt,
    })
    assert(#prom.promise_mechanics() == 0)
    local promised = prom.promised_contexts(r)
    assert(#promised == 1 and promised[1] == "A")
    local contexts = prom.required_contexts(r)
    table.sort(contexts)
    assert(#contexts == 2 and contexts[1] == "A" and contexts[2] == "B")
end)

test("a recipe that owes something only through its ingredients is a chunk boundary, and an ingredient that doesn't need the debt pays for it", function()
    local graph, debt = build_debt_worlds()
    -- Melting also takes lava directly, through an edge no handler randomizes, so it owes through that edge
    gutils.add_node(graph, "recipe", "melt", {
        op = "AND",
    })
    local melt = key("recipe", "melt")
    gutils.add_edge(graph, lava, melt)
    local prom = promotion.new({
        graph = graph,
        debt = debt,
    })
    prom.promise_mechanics()
    local boundary = prom.recipe_boundary_contexts(r, {
        "A",
        "B",
    })
    assert(#boundary == 1 and boundary[1] == "A", "r owes only in A, and only through its lava slot")
    assert(prom.pays(r, z, boundary))
    assert(not prom.pays(r, lava, boundary))
    assert(#prom.recipe_boundary_contexts(melt, {
        "A",
    }) == 0, "no ingredient choice pays for melting in A")
end)

test("a head whose dependent owes something only through it is a chunk boundary, and a base that doesn't need the debt pays for it", function()
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
    gutils.add_edge(graph, start, node("mine", "z", "AND"))
    gutils.add_edge(graph, key("mine", "z"), node("item", "z", "OR"))
    node("item", "lava", "OR")
    gutils.add_edge(graph, key("room", "B"), lava)
    -- The mechanic in room A needs whatever feeds its head, whose vanilla base comes from lava; z's base is another candidate
    local lava_base = node("base", "lava-h", "AND")
    local z_base = node("base", "z-h", "AND")
    local head = node("head", "h", "OR", {
        old_base = lava_base,
    })
    graph.nodes[lava_base].old_head = head
    gutils.add_edge(graph, lava, lava_base)
    gutils.add_edge(graph, z, z_base)
    local use = node("mine", "use", "AND", {
        mechanic = true,
    })
    gutils.add_edge(graph, head, use)
    gutils.add_edge(graph, key("room", "A"), use)
    -- The old world had lava in room A
    local old = table.deepcopy(graph)
    gutils.remove_edge(old, gutils.ekey({
        start = key("room", "B"),
        stop = lava,
    }))
    gutils.add_edge(old, key("room", "A"), lava)
    local union = superpose.union(graph, old)
    local prom = promotion.new({
        graph = graph,
        debt = {
            graph = union.graph,
            debt_edges = union.debt_edges,
            old_nodes = union.old_nodes,
            is_goal = function(node_key, context)
                return node_key == use
            end,
        },
    })
    prom.promise_mechanics()
    local boundary = prom.head_boundary_contexts(head, prom.required_contexts(use))
    assert(#boundary == 1 and boundary[1] == "A")
    assert(prom.head_pays(head, z_base, boundary))
    assert(not prom.head_pays(head, lava_base, boundary))
end)

test("ranks are solvency-first: everything the game has ranks before anything that needs a debt edge", function()
    local keys = {
        z,
        lava,
        r,
        p,
        s,
        q,
        key("mine", "pump-A"),
        key("mine", "pump-B"),
    }
    for seed = 1, 30 do
        with_seed(seed, function()
            local graph, debt = build_debt_worlds()
            local prom = promotion.new({
                graph = graph,
                debt = debt,
            })
            local last_solvent = 0
            local first_insolvent = math.huge
            for _, node_key in pairs(keys) do
                for _, context in pairs({
                    "A",
                    "B",
                }) do
                    local rank = prom.rank(node_key, context)
                    if rank ~= nil and prom.is_solvent(node_key, context) then
                        last_solvent = math.max(last_solvent, rank)
                    elseif rank ~= nil then
                        first_insolvent = math.min(first_insolvent, rank)
                    end
                end
            end
            assert(first_insolvent < math.huge, "lava in A needs the debt edge")
            assert(last_solvent < first_insolvent)
        end)
    end
end)

-- Two worlds where w was also mined in the old world, and recipe t makes it in the new one; t needs the old mine (as a machine), so the old mine always ranks before w
-- Recipe s takes z through a cut edge, needs room A, and makes mechanic q
local w, t = key("item", "w"), key("recipe", "t")
local function build_mined_worlds()
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
    for _, room in pairs({
        "A",
        "B",
    }) do
        gutils.add_edge(graph, start, node("room", room, "OR"))
    end
    for _, name in pairs({
        "z",
        "w-old",
    }) do
        gutils.add_edge(graph, start, node("mine", name, "AND"))
    end
    gutils.add_edge(graph, key("mine", "z"), node("item", "z", "OR"))
    local function cut_ingredient(material_key, recipe_key)
        local name = material_key .. " -> " .. recipe_key
        local base = node("base", name, "AND")
        local head = node("head", name, "OR", {
            old_base = base,
        })
        graph.nodes[base].old_head = head
        gutils.add_edge(graph, material_key, base)
        gutils.add_edge(graph, head, recipe_key)
    end
    node("recipe", "t", "AND")
    cut_ingredient(z, t)
    gutils.add_edge(graph, key("mine", "w-old"), t)
    gutils.add_edge(graph, t, node("item", "w", "OR"))
    node("recipe", "s", "AND")
    cut_ingredient(z, s)
    gutils.add_edge(graph, key("room", "A"), s)
    gutils.add_edge(graph, s, node("item", "q", "OR", {
        mechanic = true,
    }))
    local old = table.deepcopy(graph)
    gutils.add_edge(old, key("mine", "w-old"), w)
    local union = superpose.union(graph, old)
    return graph, {
        graph = union.graph,
        debt_edges = union.debt_edges,
        old_nodes = union.old_nodes,
        is_goal = function(node_key, context)
            return node_key == q or node_key == key("mine", "use-w")
        end,
    }
end

-- Unpromised w stops being made by t, so only the old world's mine backs it
local stop_making_w = {
    {
        node_key = w,
        remove = {
            t,
        },
    },
}

test("where a recipe is solvent, it can't take an ingredient only a debt edge backs (the no-new-insolvency rule)", function()
    -- Nothing makes w rank before s (s doesn't need it), so check every seed where it does, and that some do
    local num_debt_checked = 0
    local num_plain_checked = 0
    for seed = 1, 60 do
        with_seed(seed, function()
            local graph, debt = build_mined_worlds()
            local prom = promotion.new({
                graph = graph,
                debt = debt,
            })
            prom.promise_mechanics()
            assert(prom.try_rewires(stop_making_w, true))
            local contexts = prom.required_contexts(s)
            assert(#contexts == 1 and contexts[1] == "A")
            if prom.rank(w, "A") < prom.rank(s, "A") then
                num_debt_checked = num_debt_checked + 1
                assert(prom.is_solvent(s, "A") and not prom.is_solvent(w, "A"))
                assert(not prom.candidate_ok(s, w, contexts))
                local is_ok, err = pcall(prom.resolve, s, {
                    w,
                }, contexts)
                assert(not is_ok and string.find(err, "isn't solvent", 1, true) ~= nil)
            end
        end)
        with_seed(seed, function()
            -- The same superposed graph without debt mode takes it
            local _, debt = build_mined_worlds()
            local plain = promotion.new({
                graph = debt.graph,
            })
            plain.promise_mechanics()
            assert(plain.try_rewires(stop_making_w, true))
            local contexts = plain.required_contexts(s)
            if plain.rank(w, "A") < plain.rank(s, "A") then
                num_plain_checked = num_plain_checked + 1
                assert(plain.candidate_ok(s, w, contexts))
            end
        end)
    end
    assert(num_debt_checked > 0 and num_plain_checked > 0, "no seed ranked w before s")
end)

test("a rewire can't make a solvent promise insolvent", function()
    local graph, debt = build_mined_worlds()
    -- A mechanic that needs w in A, so w is promised solvently there
    gutils.add_node(graph, "mine", "use-w", {
        op = "AND",
        mechanic = true,
    })
    gutils.add_edge(graph, w, key("mine", "use-w"))
    gutils.add_edge(graph, key("room", "A"), key("mine", "use-w"))
    local prom = promotion.new({
        graph = graph,
        debt = debt,
    })
    assert(#prom.promise_mechanics() == 0)
    assert(prom.is_solvent(w, "A"))
    -- The debt edge alone would still establish w in A, but not solvently
    assert(not prom.try_rewires(stop_making_w, true))
    assert(prom.is_solvent(w, "A"))
end)

print(num_passed .. " tests passed")
