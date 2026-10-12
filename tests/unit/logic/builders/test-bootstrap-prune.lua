-- Plain-Lua regression tests for bootstrap.prune's control flow (src/logic/builders/bootstrap.lua), not loaded by the mod
-- Run from the mod root: lua tests/unit/logic/builders/test-bootstrap-prune.lua
--
-- The sort is a stand-in that says which delivered buildings' items are isolatable in their room from the grants the graph has, so each test can script what justifies what

function log(msg) end

local ISOLATABILITY = 2
-- What the stand-in sort justifies: building name --> function(present) --> whether its item is isolatable, where present is building name --> whether its grant is in the graph
local rules = {}
local num_sorts = 0
local fake_top = {
    ISOLATABILITY = ISOLATABILITY,
    AUTOMATABILITY = 1,
}
-- Contexts are { room, isolatable } pairs here
fake_top.context_room = function(context)
    return context.room
end
fake_top.context_mask = function(context)
    return context.isolatable and ISOLATABILITY or 0
end
fake_top.context_home = function(context)
    return nil
end
fake_top.has_ability = function(mask, ability)
    return mask == ISOLATABILITY and ability == ISOLATABILITY
end
fake_top.home_sets_signature = function(home_sets)
    return "home sets"
end
fake_top.offer_reusable_sort = function() end
fake_top.graph_fingerprint = function(graph)
    local keys = {}
    for edge_key, _ in pairs(graph.edges) do
        table.insert(keys, edge_key)
    end
    table.sort(keys)
    return table.concat(keys, "\n")
end
fake_top.sort = function(graph)
    num_sorts = num_sorts + 1
    local present = {}
    for _, node in pairs(graph.nodes) do
        if node.type == "entity-own-bootstrap-rooms" and next(node.pre) ~= nil then
            present[node.name] = true
        end
    end
    local inds = {}
    for name, rule in pairs(rules) do
        if rule(present) then
            inds["entity-build-item: " .. name] = {
                [{
                    room = "planet: rock",
                    isolatable = true,
                }] = 1,
            }
        end
    end
    return {
        node_to_context_inds = inds,
    }
end
package.loaded["src/lib/sort/context-sort"] = fake_top

local gutils = require("src/lib/graph/graph-utils")
local bootstrap = require("src/logic/builders/bootstrap")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

-- A graph with a grant on the planet for each building
local function graph_with(buildings)
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    gutils.add_node(graph, "room", "planet: rock", {
        op = "OR",
    })
    for _, name in pairs(buildings) do
        gutils.add_node(graph, "entity-own-bootstrap-rooms", name, {
            op = "OR",
        })
        gutils.add_edge(graph, gutils.key("room", "planet: rock"), gutils.key("entity-own-bootstrap-rooms", name))
    end
    return {
        graph = graph,
        home_sets = {},
    }
end
local function kept(logic)
    local names = {}
    for _, candidate in pairs(bootstrap.justifications(logic.graph)) do
        table.insert(names, candidate.name)
    end
    table.sort(names)
    return table.concat(names, ",")
end
local function prune(logic, from_last)
    num_sorts = 0
    local returned = bootstrap.prune(logic, logic.home_sets, from_last)
    assert(returned == num_sorts, "the prune says it took " .. returned .. " sorts, but took " .. num_sorts)
    return num_sorts
end

local buildings = {
    "assembler",
    "furnace",
    "turret",
}

-- First, while the module has no last prune
test("without a full prune before, a prune from the last one is a full prune", function()
    rules = {
        assembler = function()
            return true
        end,
        furnace = function()
            return false
        end,
        turret = function()
            return false
        end,
    }
    local logic = graph_with(buildings)
    assert(prune(logic, true) == 2)
    assert(kept(logic) == "assembler")
    -- That one counts as a full prune, so the next prune from it leaves out what it dropped
    rules.furnace = function()
        return true
    end
    local again = graph_with(buildings)
    assert(prune(again, true) == 1)
    assert(kept(again) == "assembler")
end)

test("a full prune keeps the most grants that justify each other", function()
    -- The assembler's item is made locally; the furnace's only with a turret operating locally, whose item never is
    rules = {
        assembler = function()
            return true
        end,
        furnace = function(present)
            return present.turret == true
        end,
        turret = function()
            return false
        end,
    }
    local logic = graph_with(buildings)
    assert(prune(logic) == 3)
    assert(kept(logic) == "assembler")
end)

test("the same graph again takes no sorts", function()
    local logic = graph_with(buildings)
    assert(prune(logic) == 0)
    assert(kept(logic) == "assembler")
end)

test("from the last prune, what it dropped stays out and one sort confirms the rest", function()
    -- The turret's item is now made locally too, which a full prune would keep, along with the furnace
    rules.turret = function()
        return true
    end
    local logic = graph_with(buildings)
    assert(prune(logic, true) == 1)
    assert(kept(logic) == "assembler")
end)

test("a prune from the last one isn't reused as a full prune of the same graph", function()
    local logic = graph_with(buildings)
    assert(prune(logic) == 1)
    assert(kept(logic) == "assembler,furnace,turret")
end)

test("from the last prune, a grant that no longer justifies itself still drops", function()
    rules.assembler = function(present)
        return present.furnace == true and present.turret == true
    end
    rules.furnace = function()
        return false
    end
    local logic = graph_with(buildings)
    -- The last full prune kept every grant; now the furnace drops, and without it the assembler
    assert(prune(logic, true) == 3)
    assert(kept(logic) == "turret")
end)

print(num_passed .. " bootstrap prune tests passed")
