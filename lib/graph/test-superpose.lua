-- Plain-Lua regression tests for superpositions (lib/graph/superpose.lua), not loaded by the mod
-- Run from the mod root: lua lib/graph/test-superpose.lua
--
-- The toy worlds are two planets whose oceans swapped: the old world pumps lava on the rock planet, the new one pumps water there and lava at home
-- Random world pairs move edges into OR nodes around and check that the superposition reaches everything either world does

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

-- A seeded stand-in for the mod's rng, so sorts choosing randomly can run in different orders
local rng_state = 1
package.loaded["lib/random/rng"] = {
    int = function(_, max)
        rng_state = (rng_state * 1103515245 + 12345) % 2147483648
        -- The low bits of this generator repeat quickly, so use the high ones
        return math.floor(rng_state / 65536) % max + 1
    end,
}

local logic = {
    contexts = {},
    type_info = {
        start = {},
        -- Emitter: sends the context named by the node
        room = { context = "room" },
        stuff = {},
        make = {},
        -- Forgetters
        technology = { context = true },
        reach = { context = true },
        -- The connector type superpositions add
        base = {},
    },
}
package.loaded["lib/logic/init"] = logic
package.loaded["lib/logic/state"] = package.loaded["lib/logic/init"]

data = {
    raw = {
        technology = {},
    },
}
package.loaded["lib/data-utils"] = {
    get_prot = function(_, name)
        return nil
    end,
}

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local superpose = require("lib/graph/superpose")

local key = gutils.key
local ekey = function(start, stop)
    return gutils.ekey({
        start = start,
        stop = stop,
    })
end

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local HOME = "planet: home"
local ROCK = "planet: rock"

local function new_graph()
    return {
        nodes = {},
        edges = {},
        sources = {},
    }
end

-- One world of the toy pair; lava_room is the room whose ocean is lava, the other room's ocean is water
local function toy_world(lava_room)
    logic.contexts = {
        [HOME] = true,
        [ROCK] = true,
    }
    local graph = new_graph()
    local nodes = {}
    local function node(name, node_type, op, pres, node_name)
        gutils.add_node(graph, node_type, node_name or name, {
            op = op,
        })
        nodes[name] = key(node_type, node_name or name)
        for _, pre in pairs(pres) do
            gutils.add_edge(graph, nodes[pre], nodes[name])
        end
    end
    node("start", "start", "AND", {})
    node("home", "room", "OR", { "start" }, HOME)
    node("mine-ore", "make", "AND", { "home" })
    node("ore", "stuff", "OR", { "mine-ore" })
    node("find-rock", "technology", "AND", { "ore" })
    node("reach-rock", "reach", "AND", { "find-rock" })
    node("rock", "room", "OR", { "reach-rock" }, ROCK)
    -- The feature edges: each room's ocean gives the fluid of its current family
    node("pump-lava", "stuff", "OR", { lava_room == ROCK and "rock" or "home" })
    node("pump-water", "stuff", "OR", { lava_room == ROCK and "home" or "rock" })
    node("melt", "make", "AND", { "pump-lava" })
    node("metal", "stuff", "OR", { "melt" })
    return graph, nodes
end

local function pebbles(sort_info)
    local set = {}
    for node_key, inds in pairs(sort_info.node_to_context_inds) do
        for context, _ in pairs(inds) do
            set[node_key .. " @@ " .. context] = true
        end
    end
    return set
end

local function contains(big, small)
    for pebble, _ in pairs(small) do
        if big[pebble] == nil then
            return false, pebble
        end
    end
    return true
end

local function count(tbl)
    local n = 0
    for _, _ in pairs(tbl) do
        n = n + 1
    end
    return n
end

local function sort_of(graph, seed, complex)
    rng_state = seed
    return top.sort(graph, nil, nil, {
        choose_randomly = true,
        complex_contexts = complex,
    })
end

test("the old world's feature edges become debt edges, and the superposition reaches both worlds", function()
    local old, nodes = toy_world(ROCK)
    local new = toy_world(HOME)
    local result = superpose.union(new, old)
    assert(count(result.debt_edges) == 2)
    assert(result.debt_edges[ekey(nodes["rock"], nodes["pump-lava"])])
    assert(result.debt_edges[ekey(nodes["home"], nodes["pump-water"])])
    assert(result.graph.edges[ekey(nodes["rock"], nodes["pump-lava"])].debt == true)
    assert(result.graph.edges[ekey(nodes["home"], nodes["pump-lava"])].debt == nil)
    assert(#result.not_into_or == 0)
    for seed = 1, 50 do
        local reach = pebbles(sort_of(result.graph, seed))
        assert(contains(reach, pebbles(sort_of(old, seed))))
        assert(contains(reach, pebbles(sort_of(new, seed))))
    end
    -- Metal on the rock planet exists only through the debt
    assert(pebbles(sort_of(result.graph, 1))[nodes["metal"] .. " @@ " .. ROCK])
    assert(pebbles(sort_of(new, 1))[nodes["metal"] .. " @@ " .. ROCK] == nil)
end)

test("the inputs aren't changed", function()
    local old = toy_world(ROCK)
    local new = toy_world(HOME)
    local num_old = count(old.edges)
    local num_new = count(new.edges)
    superpose.union(new, old)
    assert(count(old.edges) == num_old and count(new.edges) == num_new)
end)

test("a debt edge into an AND node of the new world is reported, since the superposition may reach less there", function()
    local old, nodes = toy_world(ROCK)
    local new = toy_world(ROCK)
    -- The old world's melting also needed the rock planet's presence
    gutils.add_edge(old, nodes["rock"], nodes["melt"])
    local result = superpose.union(new, old)
    assert(#result.not_into_or == 1 and result.not_into_or[1] == ekey(nodes["rock"], nodes["melt"]))
end)

test("nodes only the old world has come along with their edges, and one without prerequisites is a source", function()
    local old, nodes = toy_world(ROCK)
    local new = toy_world(ROCK)
    gutils.add_node(old, "make", "old-only", {
        op = "AND",
    })
    gutils.add_node(old, "stuff", "old-product", {
        op = "OR",
    })
    gutils.add_edge(old, key("make", "old-only"), key("stuff", "old-product"))
    local result = superpose.union(new, old)
    assert(result.graph.nodes[key("make", "old-only")] ~= nil)
    assert(result.old_nodes[key("make", "old-only")] and result.old_nodes[key("stuff", "old-product")])
    assert(count(result.old_nodes) == 2, "nodes both worlds have aren't old nodes")
    assert(result.graph.sources[key("make", "old-only")])
    assert(result.debt_edges[ekey(key("make", "old-only"), key("stuff", "old-product"))])
    -- Edges into nodes the new world doesn't have can't make it reach less, so they aren't reported
    assert(#result.not_into_or == 0)
    assert(pebbles(sort_of(result.graph, 3))[key("stuff", "old-product") .. " @@ " .. HOME])
end)

test("continuing a sort through the debt reaches nodes only the old world has", function()
    -- Promotion sorts the game, then adds the debt and continues the same sort (solvency-first ranks); a node the sort didn't start with once crashed it
    local old, nodes = toy_world(ROCK)
    local new = toy_world(ROCK)
    gutils.add_node(old, "make", "old-craft", {
        op = "AND",
    })
    gutils.add_node(old, "stuff", "old-product", {
        op = "OR",
    })
    gutils.add_edge(old, nodes["ore"], key("make", "old-craft"))
    gutils.add_edge(old, key("make", "old-craft"), key("stuff", "old-product"))
    local debt = superpose.union(new, old)
    local graph = table.deepcopy(new)
    local sort_info = sort_of(graph, 5)
    local added = superpose.add_debt(graph, debt)
    assert(#added == 2)
    sort_info = superpose.continue_through_debt(graph, sort_info, added)
    assert(pebbles(sort_info)[key("stuff", "old-product") .. " @@ " .. HOME])
end)

test("an old edge the new world has with other abilities stays, through a connector, so the superposition still gets what it gave", function()
    local old, nodes = toy_world(ROCK)
    local new = toy_world(ROCK)
    -- In the old world, pumping lava on the rock planet was isolatable; in the new world the same connection loses isolatability
    local edge_key = ekey(nodes["rock"], nodes["pump-lava"])
    old.edges[edge_key].abilities = {
        [1] = true,
    }
    new.edges[edge_key].abilities = {
        [1] = false,
    }
    local result = superpose.union(new, old)
    local connector = key("base", "superposed: " .. edge_key)
    assert(result.graph.nodes[connector] ~= nil)
    assert(result.old_nodes[connector])
    assert(result.debt_edges[ekey(nodes["rock"], connector)] and result.debt_edges[ekey(connector, nodes["pump-lava"])])
    assert(result.graph.edges[edge_key].abilities[1] == false, "the new world's edge stays as it was")
    for seed = 1, 20 do
        local reach = pebbles(sort_of(result.graph, seed, true))
        assert(contains(reach, pebbles(sort_of(old, seed, true))))
        assert(contains(reach, pebbles(sort_of(new, seed, true))))
    end
end)

----------------------------------------------------------------------
-- Random world pairs
----------------------------------------------------------------------

local ROOMS = {
    "planet: a",
    "planet: b",
    "planet: c",
}

local function random_abilities(complex)
    if not complex or math.random() < 0.5 then
        return nil
    end
    local choices = {
        {
            [1] = false,
        },
        {
            [1] = true,
        },
        {
            [2] = true,
        },
        {
            [2] = false,
        },
    }
    return choices[math.random(#choices)]
end

-- A random layered graph, and the keys of its OR nodes that could take new in-edges (feature-like)
local function random_world(complex)
    logic.contexts = {}
    for _, room in pairs(ROOMS) do
        logic.contexts[room] = true
    end
    local graph = new_graph()
    gutils.add_node(graph, "start", "", {
        op = "AND",
    })
    local earlier = {
        key("start", ""),
    }
    for _, room in pairs(ROOMS) do
        gutils.add_node(graph, "room", room, {
            op = "OR",
        })
        gutils.add_edge(graph, earlier[math.random(#earlier)], key("room", room))
        table.insert(earlier, key("room", room))
    end
    local ors = {}
    for i = 1, 30 do
        local op = math.random() < 0.5 and "AND" or "OR"
        local node_type = op == "AND" and "make" or "stuff"
        if math.random() < 0.1 then
            node_type = "technology"
            op = "AND"
        end
        local node_key = key(node_type, "n" .. tostring(i))
        gutils.add_node(graph, node_type, "n" .. tostring(i), {
            op = op,
        })
        for _ = 1, math.random(1, 3) do
            local start = earlier[math.random(#earlier)]
            if graph.edges[ekey(start, node_key)] == nil then
                gutils.add_edge(graph, start, node_key, {
                    abilities = random_abilities(complex),
                })
            end
        end
        if op == "OR" then
            table.insert(ors, node_key)
        end
        table.insert(earlier, node_key)
    end
    return graph, ors, earlier
end

test("on random world pairs that move edges into OR nodes, the superposition reaches everything either world does", function()
    for trial = 1, 150 do
        math.randomseed(trial)
        local complex = trial % 2 == 0
        local old, ors, earlier = random_world(complex)
        local new = table.deepcopy(old)
        -- Move a few edges into OR nodes, like features changing rooms
        for _, node_key in pairs(ors) do
            if math.random() < 0.4 then
                for pre, _ in pairs(table.deepcopy(new.nodes[node_key].pre)) do
                    if math.random() < 0.5 then
                        gutils.remove_edge(new, pre)
                    end
                end
                local start = earlier[math.random(#earlier)]
                if start ~= node_key and new.edges[ekey(start, node_key)] == nil then
                    gutils.add_edge(new, start, node_key, {
                        abilities = random_abilities(complex),
                    })
                end
            end
        end
        local result = superpose.union(new, old)
        assert(#result.not_into_or == 0)
        local reach = pebbles(sort_of(result.graph, trial, complex))
        local is_old, missing_old = contains(reach, pebbles(sort_of(old, trial, complex)))
        local is_new, missing_new = contains(reach, pebbles(sort_of(new, trial, complex)))
        assert(is_old, "trial " .. trial .. ": misses the old world's " .. tostring(missing_old))
        assert(is_new, "trial " .. trial .. ": misses the new world's " .. tostring(missing_new))
    end
end)

print(num_passed .. " tests passed")
