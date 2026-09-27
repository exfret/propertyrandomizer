-- Plain-Lua regression tests for staged sorts (lib/graph/staged-sort.lua), not loaded by the mod
-- Run from the mod root: lua lib/graph/test-staged-sort.lua
--
-- The toy graph is two planets, where a recipe on the rock planet needs lava pumped there and a goal on the rock planet needs the recipe's metal
-- Random graphs check that the reach after every stage equals relaxing and adding the edges directly

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
        -- The connector types staged sorts add
        head = {},
        base = {},
    },
}
package.loaded["lib/logic/init"] = logic

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
local staged = require("lib/graph/staged-sort")

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

-- Returns the graph and a node's key by short name
local function toy_graph()
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
    -- The shifted world: the rock planet's ocean is water now, so nothing pumps lava there
    node("pump-water", "stuff", "OR", { "rock" })
    node("pump-lava", "stuff", "OR", {})
    node("melt", "make", "AND", {
        "pump-lava",
        "rock",
    })
    node("metal", "stuff", "OR", { "melt" })
    node("goal", "make", "AND", {
        "metal",
        "rock",
    })
    return graph, nodes
end

local function goal_ind(result, node_key, room)
    return result.sort_info.node_to_context_inds[node_key][room]
end

local function run_seeds(fn)
    for seed = 1, 200 do
        rng_state = seed
        fn({
            choose_randomly = true,
        })
    end
end

test("without any gate, the goal on the rock planet isn't reached", function()
    run_seeds(function(extra)
        local graph, nodes = toy_graph()
        local result = staged.sort({
            graph = graph,
            stages = {},
            extra = extra,
        })
        assert(goal_ind(result, nodes["goal"], ROCK) == nil)
    end)
end)

test("a relaxed slot brings the goal back in its stage, and the witness uses only that slot", function()
    run_seeds(function(extra)
        local graph, nodes = toy_graph()
        local lava_slot = ekey(nodes["pump-lava"], nodes["melt"])
        local result = staged.sort({
            graph = graph,
            stages = {
                "root",
                "leaf",
            },
            relax = {
                {
                    edge_key = lava_slot,
                    stage = "root",
                },
                {
                    edge_key = ekey(nodes["metal"], nodes["goal"]),
                    stage = "leaf",
                },
            },
            extra = extra,
        })
        local ind = goal_ind(result, nodes["goal"], ROCK)
        assert(ind ~= nil)
        assert(result.stage_of(ind) == "root")
        local used = result.gates_on_witness({ ind })
        assert(used[lava_slot] ~= nil and used[lava_slot].kind == "relax" and used[lava_slot].stage == "root")
        assert(used[lava_slot].contexts[ROCK])
        local num_used = 0
        for _, _ in pairs(used) do
            num_used = num_used + 1
        end
        assert(num_used == 1, "only the root slot is needed")
    end)
end)

test("stage order decides which repair the witness uses", function()
    run_seeds(function(extra)
        local graph, nodes = toy_graph()
        local leaf_slot = ekey(nodes["metal"], nodes["goal"])
        local result = staged.sort({
            graph = graph,
            stages = {
                "leaf",
                "root",
            },
            relax = {
                {
                    edge_key = ekey(nodes["pump-lava"], nodes["melt"]),
                    stage = "root",
                },
                {
                    edge_key = leaf_slot,
                    stage = "leaf",
                },
            },
            extra = extra,
        })
        local ind = goal_ind(result, nodes["goal"], ROCK)
        assert(result.stage_of(ind) == "leaf")
        local used = result.gates_on_witness({ ind })
        assert(used[leaf_slot] ~= nil)
        assert(used[ekey(nodes["pump-lava"], nodes["melt"])] == nil)
    end)
end)

test("pebbles reached without gates rank before every stage and their witnesses use no gates", function()
    run_seeds(function(extra)
        local graph, nodes = toy_graph()
        local result = staged.sort({
            graph = graph,
            stages = {
                "root",
            },
            relax = {
                {
                    edge_key = ekey(nodes["pump-lava"], nodes["melt"]),
                    stage = "root",
                },
            },
            extra = extra,
        })
        local ind = goal_ind(result, nodes["pump-water"], ROCK)
        assert(ind ~= nil and result.stage_of(ind) == nil)
        assert(ind < result.stage_starts["root"])
        assert(next(result.gates_on_witness({ ind })) == nil)
    end)
end)

test("an added edge (a debt edge from the old world) brings the goal back, and the witness names it", function()
    run_seeds(function(extra)
        local graph, nodes = toy_graph()
        local result = staged.sort({
            graph = graph,
            stages = {
                "debt",
            },
            add = {
                {
                    start = nodes["rock"],
                    stop = nodes["pump-lava"],
                    stage = "debt",
                },
            },
            extra = extra,
        })
        local ind = goal_ind(result, nodes["goal"], ROCK)
        assert(ind ~= nil and result.stage_of(ind) == "debt")
        local used = result.gates_on_witness({ ind })
        local id = ekey(nodes["rock"], nodes["pump-lava"])
        assert(used[id] ~= nil and used[id].kind == "add" and used[id].stage == "debt")
        -- The goal on the home planet never needed the debt: there's no lava there even in the old world
        assert(goal_ind(result, nodes["goal"], HOME) == nil)
    end)
end)

----------------------------------------------------------------------
-- Random graphs: the staged sort's final reach equals relaxing and adding the edges directly
----------------------------------------------------------------------

local ROOMS = {
    "planet: a",
    "planet: b",
    "planet: c",
}

local function random_abilities(complex)
    if not complex then
        return nil
    end
    local choices = {
        false,
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
    local choice = choices[math.random(#choices)]
    if choice == false then
        return nil
    end
    return choice
end

-- A random layered graph: rooms reached from the start, then AND/OR nodes over earlier ones (some forgetters)
-- Returns the graph and the list of its non-room node keys, in layer order
local function random_graph(complex)
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
        gutils.add_edge(graph, earlier[math.random(#earlier)], key("room", room), {
            abilities = random_abilities(complex),
        })
        table.insert(earlier, key("room", room))
    end
    local inner = {}
    for i = 1, 30 do
        local node_type = "stuff"
        local op = "OR"
        if math.random() < 0.5 then
            node_type = "make"
            op = "AND"
        end
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
        table.insert(earlier, node_key)
        table.insert(inner, node_key)
    end
    return graph, inner
end

-- Every pebble, as one sorted string, to compare reach regardless of order (the gated graph's own connectors left out)
local function reach_of(sort_info)
    local pebbles = {}
    for node_key, inds in pairs(sort_info.node_to_context_inds) do
        if string.find(node_key, "staged-", 1, true) == nil then
            for context, _ in pairs(inds) do
                table.insert(pebbles, node_key .. " @@ " .. context)
            end
        end
    end
    table.sort(pebbles)
    return table.concat(pebbles, "\n")
end

test("on random graphs, the reach after every stage equals relaxing and adding the edges directly", function()
    for trial = 1, 150 do
        math.randomseed(trial)
        local complex = trial % 2 == 0
        local graph, inner = random_graph(complex)
        local relax = {}
        local add = {}
        local direct = table.deepcopy(graph)
        -- Relax a few AND in-edges and add a few edges into OR nodes, in two stages
        for _, node_key in pairs(inner) do
            local node = graph.nodes[node_key]
            if node.op == "AND" and math.random() < 0.3 then
                for pre, _ in pairs(node.pre) do
                    if math.random() < 0.5 then
                        table.insert(relax, {
                            edge_key = pre,
                            stage = math.random() < 0.5 and "one" or "two",
                        })
                        gutils.remove_edge(direct, pre)
                        break
                    end
                end
            elseif node.op == "OR" and math.random() < 0.3 then
                local start = inner[math.random(#inner)]
                if start ~= node_key and graph.edges[ekey(start, node_key)] == nil and direct.edges[ekey(start, node_key)] == nil then
                    local abilities = random_abilities(complex)
                    table.insert(add, {
                        start = start,
                        stop = node_key,
                        extra = abilities ~= nil and {
                            abilities = abilities,
                        } or nil,
                        stage = math.random() < 0.5 and "one" or "two",
                    })
                    gutils.add_edge(direct, start, node_key, {
                        abilities = abilities,
                    })
                end
            end
        end
        rng_state = trial
        local extra = {
            choose_randomly = true,
            complex_contexts = complex,
        }
        local result = staged.sort({
            graph = graph,
            stages = {
                "one",
                "two",
            },
            relax = relax,
            add = add,
            extra = extra,
        })
        local direct_sort = top.sort(direct, nil, nil, extra)
        assert(reach_of(result.sort_info) == reach_of(direct_sort), "trial " .. trial .. " reach differs")
    end
end)

print(num_passed .. " tests passed")
