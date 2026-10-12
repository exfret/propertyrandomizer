-- Plain-Lua regression tests for reusing bootstrap.prune's last sort in context-sort.lua (top.offer_reusable_sort), and for resuming a sort kept from before its pebble lists (not loaded by the mod)
-- Run from the mod root: lua tests/unit/lib/sort/test-sort-reuse.lua
--
-- A reused sort has to be the very sort the caller would have made, so it's only handed out while nothing a sort reads has changed (top.graph_fingerprint, top.home_sets_signature)

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

-- Only sorts choosing randomly draw from it
package.loaded["src/lib/random/rng"] = {
    int = function(_, max)
        return max
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
    },
}
package.loaded["src/logic/init"] = logic
package.loaded["src/logic/state"] = package.loaded["src/logic/init"]

-- Space locations the toy techs discover (read by top.discovered_rooms)
data = {
    raw = {},
}
package.loaded["src/prototypes/data-utils"] = {
    get_prot = function(_, name)
        return data.raw["planet"][name]
    end,
}

local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")

local key = gutils.key

local HOME = "planet: home"
local ROCK = "planet: rock"
local MOSS = "planet: moss"

-- A home planet and a rock planet that a tech discovers
-- Returns the graph and its node keys by short name
local function toy_graph()
    logic.contexts = {
        [HOME] = true,
        [ROCK] = true,
    }
    data.raw["planet"] = {
        rock = {
            type = "planet",
            name = "rock",
        },
        moss = {
            type = "planet",
            name = "moss",
        },
    }
    data.raw["technology"] = {
        ["find-rock"] = {
            effects = {
                {
                    type = "unlock-space-location",
                    space_location = "rock",
                },
            },
        },
    }
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
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
    node("t-basic", "technology", "AND", { "ore" })
    node("find-rock", "technology", "AND", { "t-basic" })
    node("reach-rock", "reach", "AND", { "find-rock" })
    node("rock", "room", "OR", { "reach-rock" }, ROCK)
    node("mine-rock", "make", "AND", { "rock" })
    node("rock-ore", "stuff", "OR", { "mine-rock" })
    node("t-rock", "technology", "AND", { "find-rock", "rock-ore" })
    node("t-late", "technology", "AND", { "t-basic", "ore" })
    return graph, nodes
end

local function options(home_sets)
    return {
        complex_contexts = true,
        home_contexts = true,
        home_sets = home_sets,
    }
end

-- Every pebble in the order the sort found it, with the contexts' names (contexts are numbers, see src/logic/contexts/contexts.lua)
local function pebbles(sort_info)
    local list = {}
    for pebble_ind, pebble_key in pairs(sort_info.pebble_keys) do
        local pebble_context = sort_info.pebble_contexts[pebble_ind]
        table.insert(list, pebble_key .. " @@ " .. top.context_name(pebble_context))
    end
    return table.concat(list, "\n")
end

-- A toy graph with its home sets and an offered sort of it, as bootstrap.prune leaves them
local function offered_world()
    local graph, nodes = toy_graph()
    local home_sets = top.home_sets(graph)
    local offered = top.sort(graph, nil, nil, options(home_sets))
    top.offer_reusable_sort(graph, offered, home_sets)
    return graph, nodes, home_sets, offered
end

----------------------------------------------------------------------
-- Tests
----------------------------------------------------------------------

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

test("the next sort of the same graph with the same home sets takes the offered sort, once", function()
    local graph, _, home_sets, offered = offered_world()
    -- Home sets worked out again are another table with the same contents, and the sort then holds the caller's table
    local same_sets = top.home_sets(graph)
    assert(same_sets ~= home_sets)
    local taken = top.sort(graph, nil, nil, options(same_sets))
    assert(taken == offered)
    assert(taken.home_sets == same_sets)
    -- Taken once, so the next caller gets tables of its own, with the same pebbles
    local again = top.sort(graph, nil, nil, options(home_sets))
    assert(again ~= offered)
    assert(pebbles(again) == pebbles(offered))
end)

test("logic.home_sets stands in for missing extra.home_sets, as in a sort of its own", function()
    local graph, _, home_sets, offered = offered_world()
    logic.home_sets = home_sets
    local taken = top.sort(graph, nil, nil, {
        complex_contexts = true,
        home_contexts = true,
    })
    logic.home_sets = nil
    assert(taken == offered)
end)

test("a sort with other options or other home sets sorts itself and leaves the offer", function()
    local graph, _, home_sets, offered = offered_world()
    local random = options(home_sets)
    random.choose_randomly = true
    assert(top.sort(graph, nil, nil, random) ~= offered)
    local smaller = top.home_sets(graph)
    for _, home_id in pairs(smaller.ids) do
        smaller.sets[home_id].rooms = {}
    end
    assert(top.sort(graph, nil, nil, options(smaller)) ~= offered)
    assert(top.sort(graph, nil, nil, {
        complex_contexts = true,
    }) ~= offered)
    -- Nor does another graph sorted with other options
    local other = toy_graph()
    assert(top.sort(other) ~= offered)
    assert(top.sort(other, nil, nil, {
        complex_contexts = true,
    }) ~= offered)
    assert(top.sort(graph, nil, nil, options(home_sets)) == offered)
end)

test("a sort like it of another graph doesn't take the offer, and drops it", function()
    local graph, _, home_sets, offered = offered_world()
    local other = toy_graph()
    assert(top.sort(other, nil, nil, options(home_sets)) ~= offered)
    -- The offered graph is then sorted again, the same way
    local again = top.sort(graph, nil, nil, options(home_sets))
    assert(again ~= offered)
    assert(pebbles(again) == pebbles(offered))
end)

test("a graph changed after the offer is sorted again", function()
    local graph, nodes, home_sets, offered = offered_world()
    gutils.add_edge(graph, nodes["rock-ore"], nodes["t-late"])
    local sorted = top.sort(graph, nil, nil, options(home_sets))
    assert(sorted ~= offered)
    assert(pebbles(sorted) ~= pebbles(offered))
    assert(pebbles(sorted) == pebbles(top.sort(graph, nil, nil, options(home_sets))))
end)

test("a new room, a changed discovery or a flipped switch after the offer means sorting again", function()
    local graph, _, home_sets, offered = offered_world()
    logic.contexts[MOSS] = true
    assert(top.sort(graph, nil, nil, options(home_sets)) ~= offered)

    graph, _, home_sets, offered = offered_world()
    data.raw["technology"]["t-basic"] = {
        effects = {
            {
                type = "unlock-space-location",
                space_location = "moss",
            },
        },
    }
    assert(top.sort(graph, nil, nil, options(home_sets)) ~= offered)

    graph, _, home_sets, offered = offered_world()
    top.implied_home_contexts = false
    local sorted = top.sort(graph, nil, nil, options(home_sets))
    top.implied_home_contexts = true
    assert(sorted ~= offered)

    graph, _, home_sets, offered = offered_world()
    logic.type_info["stuff"] = {
        context = true,
    }
    sorted = top.sort(graph, nil, nil, options(home_sets))
    logic.type_info["stuff"] = {}
    assert(sorted ~= offered)

    -- Research home contexts' switch, and what they read of a node type (top.research_home_contexts)
    graph, _, home_sets, offered = offered_world()
    local research = top.research_home_contexts
    top.research_home_contexts = not research
    sorted = top.sort(graph, nil, nil, options(home_sets))
    top.research_home_contexts = research
    assert(sorted ~= offered)

    graph, _, home_sets, offered = offered_world()
    logic.type_info["stuff"] = {
        research_input = true,
    }
    sorted = top.sort(graph, nil, nil, options(home_sets))
    logic.type_info["stuff"] = {}
    assert(sorted ~= offered)
end)

test("a sort kept with a table per pebble, from before the pebble lists, carries on as lists", function()
    -- Ore isn't reachable until its recipe's edge is added back to a kept sort, the way the control stage adds edges to sorts in storage
    local function resumed(old_format)
        local graph, nodes = toy_graph()
        gutils.remove_edge(graph, gutils.ekey({
            start = nodes["mine-ore"],
            stop = nodes["ore"],
        }))
        local state = top.sort(graph)
        if old_format == true then
            state.sorted = {}
            for ind, node_key in pairs(state.pebble_keys) do
                state.sorted[ind] = {
                    node_key = node_key,
                    context = state.pebble_contexts[ind],
                }
            end
            state.pebble_keys = nil
            state.pebble_contexts = nil
        end
        gutils.add_edge(graph, nodes["mine-ore"], nodes["ore"])
        local sort_info = top.sort(graph, state, {
            graph.nodes[nodes["mine-ore"]],
            graph.nodes[nodes["ore"]],
        })
        assert(sort_info.sorted == nil and state.sorted == nil)
        assert(sort_info.node_to_context_inds[nodes["t-late"]][next(sort_info.node_to_context_inds[nodes["t-late"]])] ~= nil)
        return pebbles(sort_info)
    end
    assert(resumed(true) == resumed(false))
end)

print(tostring(num_passed) .. " tests passed")
