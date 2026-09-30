-- Plain-Lua regression tests for the recipe-category handler's furnace guard (not loaded by the mod)
-- Run from the mod root: lua randomizations/graph/unified/handlers/test-recipe-category.lua
--
-- An oven crafts the baking category; recipe bar bakes ore in vanilla, and recipe cog is handwork from ore
-- A furnace picks its recipe by ingredient (doc-html/auxiliary/furnace-recipe-selection.html), so cog can't join bar in the oven while bar might still need ore there

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
defines = {
    prototypes = {
        item = {
            item = 0,
        },
    },
}
data = {
    raw = {
        furnace = {
            oven = {
                type = "furnace",
                name = "oven",
                crafting_categories = {
                    "baking",
                },
            },
        },
    },
}
mods = {}
local function recipe(name, category)
    return {
        type = "recipe",
        name = name,
        categories = {
            category,
        },
        ingredients = {
            {
                type = "item",
                name = "ore",
                amount = 1,
            },
        },
        results = {
            {
                type = "item",
                name = name,
                amount = 1,
            },
        },
    }
end
package.loaded["lib/lookup/init"] = {
    recipes = {
        bar = recipe("bar", "baking"),
        cog = recipe("cog", "handwork"),
    },
    rcats = {
        bake = {
            cats = {
                "baking",
            },
            input = 0,
            output = 0,
        },
        hand = {
            cats = {
                "handwork",
            },
            input = 0,
            output = 0,
        },
    },
    fixed_recipes = {},
}
package.loaded["lib/recipe-shape"] = {
    planned = function(recipe_name)
        return nil
    end,
}

local gutils = require("lib/graph/graph-utils")
local recipe_category = require("randomizations/graph/unified/handlers/recipe-category")

local key = gutils.key

-- Each recipe's category edge, claimed and cut into a base and head like the shuffle's
local function build()
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local function node(node_type, name, op)
        gutils.add_node(graph, node_type, name, {
            op = op,
        })
        return graph.nodes[key(node_type, name)]
    end
    recipe_category.initialize()
    local world = {
        graph = graph,
        bases = {},
        heads = {},
    }
    for recipe_name, rcat_name in pairs({
        bar = "bake",
        cog = "hand",
    }) do
        local rcat = graph.nodes[key("recipe-category", rcat_name)] or node("recipe-category", rcat_name, "OR")
        local recipe_node = node("recipe", recipe_name, "AND")
        assert(recipe_category.claim(graph, rcat, recipe_node, nil) ~= nil)
        local base = node("base", recipe_name, "AND")
        gutils.add_edge(graph, key(rcat), key(base))
        local head = node("head", recipe_name, "OR")
        gutils.add_edge(graph, key(head), key(recipe_node))
        world.bases[rcat_name] = base
        world.heads[recipe_name] = head
    end
    return world
end

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

test("a recipe can't move into a furnace while the recipe that bakes its ingredient there in vanilla may still fall back to it", function()
    local world = build()
    assert(not recipe_category.validate(world.graph, world.bases.bake, world.heads.cog))
    -- Bar itself can stay
    assert(recipe_category.validate(world.graph, world.bases.bake, world.heads.bar))
end)

test("once that recipe is placed somewhere else, its ingredient is free in the furnace", function()
    local world = build()
    recipe_category.process(world.graph, world.bases.hand, world.heads.bar)
    assert(recipe_category.validate(world.graph, world.bases.bake, world.heads.cog))
end)

test("once that recipe is placed in the furnace, its ingredient is taken there", function()
    local world = build()
    recipe_category.process(world.graph, world.bases.bake, world.heads.bar)
    assert(not recipe_category.validate(world.graph, world.bases.bake, world.heads.cog))
end)

print(num_passed .. " tests passed")
