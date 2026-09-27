-- Plain-Lua regression tests for the recipes a rebuilt tech's prerequisites come from (lib/logic/witness-recipes.lua), not loaded by the mod
-- Run from the mod root: lua lib/logic/test-witness-recipes.lua
--
-- The toy graph is the captive spawner: smelting (locked) makes plates, plates make fuel (locked), the spawner burns the fuel, and its fixed recipe (enabled, so no tech) makes eggs that breeding needs

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

local HOME = "room: home"

local logic = {
    contexts = {
        [HOME] = true,
    },
    type_info = {
        start = {},
        -- Emitter: sends the context named by the node
        room = { context = "room" },
        stuff = {},
        -- The node type witness_recipes looks for
        recipe = {},
        operate = {},
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
local witness_recipes = require("lib/logic/witness-recipes")

local key = gutils.key

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

-- Recipes that get a tech; the fixed egg recipe is enabled, so it doesn't
local locked = {
    smelt = true,
    ["make-fuel"] = true,
    breed = true,
    gear = true,
}
local function gets_tech(recipe_name)
    return locked[recipe_name] == true
end

local function toy_graph()
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local function node(node_type, name, op, pres)
        gutils.add_node(graph, node_type, name, {
            op = op,
        })
        for _, pre in pairs(pres) do
            gutils.add_edge(graph, pre, key(node_type, name))
        end
    end
    node("start", "start", "AND", {})
    node("room", "home", "OR", { key("start", "start") })
    node("stuff", "ore", "OR", { key("room", "home") })
    node("recipe", "smelt", "AND", { key("stuff", "ore") })
    node("stuff", "plate", "OR", { key("recipe", "smelt") })
    node("recipe", "make-fuel", "AND", { key("stuff", "plate") })
    node("stuff", "fuel", "OR", { key("recipe", "make-fuel") })
    node("operate", "spawner", "AND", { key("stuff", "fuel") })
    node("recipe", "eggs", "AND", { key("operate", "spawner") })
    node("stuff", "egg", "OR", { key("recipe", "eggs") })
    node("recipe", "breed", "AND", { key("stuff", "egg") })
    node("recipe", "gear", "AND", { key("stuff", "plate") })
    return graph
end

-- The recipes the first pebble of a recipe directly needs
local function recipes_needed_by(recipe_name, tech_rule)
    local graph = toy_graph()
    local sort_info = top.sort(graph)
    local ind
    for _, context_ind in pairs(sort_info.node_to_context_inds[key("recipe", recipe_name)]) do
        if ind == nil or context_ind < ind then
            ind = context_ind
        end
    end
    return witness_recipes.of(graph, sort_info, ind, tech_rule or gets_tech)
end

local function names(set)
    local list = {}
    for name, _ in pairs(set) do
        table.insert(list, name)
    end
    table.sort(list)
    return table.concat(list, ",")
end

test("a recipe needs the recipes with techs on its witness, and not what those need", function()
    assert(names(recipes_needed_by("gear")) == "smelt")
    assert(names(recipes_needed_by("make-fuel")) == "smelt")
end)

test("the witness goes on through a recipe without a tech, like a fixed recipe, to the fuel its machine burns", function()
    -- Stopping at the egg recipe gave breeding nothing, so its tech had no prerequisites
    assert(names(recipes_needed_by("breed")) == "make-fuel")
end)

test("only recipes that get a tech are returned", function()
    for name, _ in pairs(recipes_needed_by("breed")) do
        assert(gets_tech(name))
    end
    -- If every recipe got a tech, the egg recipe's tech would carry the fuel, so the witness stops there
    local all_get_tech = function()
        return true
    end
    assert(names(recipes_needed_by("breed", all_get_tech)) == "eggs")
end)

print(num_passed .. " tests passed")
