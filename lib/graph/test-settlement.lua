-- Plain-Lua regression tests for settlement (lib/graph/settlement.lua), not loaded by the mod
-- Run from the mod root: lua lib/graph/test-settlement.lua
--
-- The toy worlds are two planets whose oceans swapped: the old world pumps lava on the rock planet, the new one pumps water there and lava at home
-- Melting needs lava, so the new world can't make metal on the rock planet, which is the goal the shift broke

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
package.loaded["lib/random/rng"] = {
    int = function(_, max)
        return 1
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
        -- The connector types staged sorts add
        head = {},
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
local settlement = require("lib/graph/settlement")

local key = gutils.key

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local HOME = "planet: home"
local ROCK = "planet: rock"

-- One world of the toy pair; lava_room is the room whose ocean is lava
local function toy_world(lava_room)
    logic.contexts = {
        [HOME] = true,
        [ROCK] = true,
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
    node("rock", "room", "OR", { "start" }, ROCK)
    node("pump-lava", "stuff", "OR", { lava_room == ROCK and "rock" or "home" })
    node("pump-water", "stuff", "OR", { lava_room == ROCK and "home" or "rock" })
    node("melt", "make", "AND", { "pump-lava" })
    node("metal", "stuff", "OR", { "melt" })
    return graph, nodes
end

-- The new world as the game, the old world's edges as debt, and a check of whether the rock planet makes metal
local function setup()
    local old, nodes = toy_world(ROCK)
    local game = toy_world(HOME)
    local debt = superpose.union(game, old)
    local function check()
        local sort_info = top.sort(game)
        local failures = {}
        if (sort_info.node_to_context_inds[nodes["metal"]] or {})[ROCK] == nil then
            table.insert(failures, {
                text = "metal @ rock",
                keys = {
                    nodes["metal"],
                },
                context = ROCK,
            })
        end
        return {
            failures = failures,
            graph = game,
            sort_extra = {},
        }
    end
    return game, nodes, debt, check
end

-- A settler for the lava debt: its fixes add the old edge back to the game (an addition), after an optional fix that doesn't help
local function lava_settler(game, nodes, useless_first)
    return {
        name = "lava",
        owns = function(edge)
            return edge.stop == nodes["pump-lava"]
        end,
        fixes = function(edge)
            local fixes = {}
            if useless_first then
                table.insert(fixes, {
                    rung = "repair",
                    text = "a repair that doesn't help",
                    apply = function() end,
                    undo = function() end,
                })
            end
            table.insert(fixes, {
                rung = "addition",
                text = "lava back on the rock planet",
                apply = function()
                    gutils.add_edge(game, edge.start, edge.stop)
                end,
                undo = function()
                    gutils.remove_edge(game, gutils.ekey(edge))
                end,
            })
            return fixes
        end,
    }
end

test("the debt edge on the owed goal's witness is the old world's lava pump", function()
    local game, nodes, debt, check = setup()
    local result = check()
    assert(#result.failures == 1)
    local owed = settlement.owed_edges(result.graph, result.sort_extra, result.failures, debt)
    local edge_key = gutils.ekey({
        start = nodes["rock"],
        stop = nodes["pump-lava"],
    })
    assert(owed[edge_key] ~= nil and owed[edge_key][ROCK])
    local num_owed = 0
    for _, _ in pairs(owed) do
        num_owed = num_owed + 1
    end
    assert(num_owed == 1, "the water pump's old edge isn't needed")
end)

test("a settler's fix for an owed debt edge settles the goal", function()
    local game, nodes, debt, check = setup()
    local result = settlement.settle({
        check = check,
        debt = debt,
        settlers = {
            lava_settler(game, nodes, false),
        },
    })
    assert(#result.failures == 0)
    assert(#result.applied == 1 and result.applied[1].rung == "addition")
end)

test("when a fix doesn't settle the goal, the next round takes the settler's next fix", function()
    local game, nodes, debt, check = setup()
    local result = settlement.settle({
        check = check,
        debt = debt,
        settlers = {
            lava_settler(game, nodes, true),
        },
    })
    assert(#result.failures == 0)
    assert(#result.applied == 2 and result.applied[1].rung == "repair" and result.applied[2].rung == "addition")
end)

test("a debt edge no settler owns is reported as unsettled", function()
    local _, nodes, debt, check = setup()
    local result = settlement.settle({
        check = check,
        debt = debt,
        settlers = {},
    })
    assert(#result.failures == 1 and #result.applied == 0)
    assert(result.unsettled[gutils.ekey({
        start = nodes["rock"],
        stop = nodes["pump-lava"],
    })] ~= nil)
end)

print(num_passed .. " tests passed")
