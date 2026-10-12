-- Run from the mod root: lua tests/unit/randomizations/rebuild/test-rebuild-kept-paths.lua
-- A kept alternate unlock path (src/randomizations/rebuild/rebuild-unlocks.lua) gets its prerequisites from where it's kept for, in the actual rebuild (src/randomizations/rebuild/init.lua)
-- Like Electrolyte (Unlock 2) in the user's 2026-10-10 game, researched by crafting a crusher: each planet crafts crushers with its own recipe, the earliest of those could never be a prerequisite, and the tech sat at the start of the tree with none
function table.deepcopy(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for key, child in pairs(value) do
        copy[key] = table.deepcopy(child)
    end
    return copy
end
function log(message) end
serpent = { block = tostring }
mods = {}
config = {}
randomizations = {}

local ROOM_A = "planet: test-a"
local ROOM_B = "planet: test-b"
local logic = {
    contexts = {
        [ROOM_A] = true,
        [ROOM_B] = true,
    },
    type_info = {
        room = { context = "room" },
        technology = { context = true },
    },
}
package.loaded["src/logic/state"] = logic
package.loaded["src/logic/init"] = logic
package.loaded["src/lib/random/rng"] = { int = function() return 1 end }
package.loaded["src/prototypes/data-utils"] = { get_prot = function() return nil end }
package.loaded["src/localisation/locale"] = { find_localised_name = function(recipe) return recipe.name end }
package.loaded["src/prototypes/duplicates/dupe"] = {
    get_recipe_icons = function() return {} end,
    technology_icons = function(icons) return icons end,
}
package.loaded["src/prototypes/technology/technology-abilities"] = { bundle = function() return {} end }
package.loaded["src/prototypes/entities/fluid-ports"] = {}
package.loaded["src/prototypes/recipes/recycling"] = {}
package.loaded["src/logic/builders/recycling-sources"] = {}
package.loaded["src/prototypes/entities/crafter-slots"] = {}

local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
-- Edge abilities are codes (src/logic/contexts/contexts.lua); fixtures write them as the logic builders used to, like { [2] = true } (tests/unit/logic/contexts/contexts-for-tests.lua)
local fx = require("tests/unit/logic/contexts/contexts-for-tests")
require("src/randomizations/rebuild/init")
-- Games are built like logic.build builds them: concrete.lua's unlock nodes, contracted where one technology unlocks a recipe (src/logic/analysis/unlock-contraction.lua), and pass-through nodes left out (src/logic/analysis/pass-through.lua)
local pass_through = require("src/logic/analysis/pass-through")
local reductions = require("src/logic/analysis/reductions")
local unlock_contraction = require("src/logic/analysis/unlock-contraction")

data = { raw = {} }
function data:extend(prototypes)
    for _, prototype in pairs(prototypes) do
        self.raw[prototype.type][prototype.name] = prototype
    end
end

-- Room A crafts the trigger's material with its own recipe early, room B with another recipe much later, and the same for the target recipe's ingredient
-- The target recipe's own tech takes room A's pack, so only the kept path, researched by crafting the material, lets room B have the target recipe from its own resources
-- Room B's ingredient recipe is researched with a pack made from the material, so in room B its tech comes after the kept path, though before the target recipe
logic.build = function()
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local function node(kind, name, op, pres)
        logic.type_info[kind] = logic.type_info[kind] or {}
        local key = gutils.key(gutils.add_node(graph, kind, name, { op = op }))
        for _, pre in pairs(pres or {}) do
            gutils.add_edge(graph, pre, key)
        end
        return key
    end
    local start = node("start", "", "AND")
    local a = node("room", ROOM_A, "OR", { start })
    local b = node("room", ROOM_B, "OR", { start })
    local later = b
    for i = 1, 12 do
        later = node("test-later", tostring(i), "OR", { later })
    end
    local function made(recipe_name, pres)
        local unlock = node("recipe-unlock", recipe_name, "OR", { node("recipe-tech-unlock", recipe_name, "OR") })
        table.insert(pres, unlock)
        return node("recipe", recipe_name, "AND", pres)
    end
    local material = node("item", "test-trigger-material", "OR", {
        made("test-way-a", { a }),
        made("test-way-b", { later }),
    })
    local packs = {
        ["test-pack-a"] = node("item", "test-pack-a", "OR", { a }),
        ["test-pack-b"] = node("item", "test-pack-b", "OR", { later }),
        ["test-pack-late"] = node("item", "test-pack-late", "OR", { material }),
    }
    local ingredient = node("item", "test-ingredient", "OR", {
        made("test-ingredient-a", { a }),
        made("test-ingredient-b", { later }),
    })
    made("test-target-recipe", { ingredient })
    for name, prototype in pairs(data.raw.technology) do
        local research
        if prototype.research_trigger ~= nil then
            research = node("technology-trigger", name, "OR", { material })
        else
            research = packs[prototype.unit.ingredients[1][1]]
        end
        node("technology", name, "AND")
        gutils.add_edge(graph, research, gutils.key("technology", name), {
            abilities = fx.edge({ [2] = true }),
        })
    end
    for name, prototype in pairs(data.raw.technology) do
        local key = gutils.key("technology", name)
        for _, pre in pairs(prototype.prerequisites or {}) do
            gutils.add_edge(graph, gutils.key("technology", pre), key, {
                abilities = fx.edge({ [2] = true }),
            })
        end
        for _, effect in pairs(prototype.effects or {}) do
            if effect.type == "unlock-recipe" then
                gutils.add_edge(graph, key, gutils.key("recipe-tech-unlock", effect.recipe))
            end
        end
    end
    if reductions.enabled == true then
        unlock_contraction.contract(graph)
        pass_through.contract(graph)
    end
    logic.graph = graph
end

local function sort()
    logic.build()
    return top.sort(logic.graph, nil, nil, {
        complex_contexts = true,
        home_contexts = true,
    })
end

local function tech(name, recipe_name, pack)
    local prototype = {
        type = "technology",
        name = name,
        effects = {
            {
                type = "unlock-recipe",
                recipe = recipe_name,
            },
        },
    }
    if pack == nil then
        prototype.research_trigger = {
            type = "craft-item",
            item = "test-trigger-material",
        }
    else
        prototype.unit = {
            count = 1,
            ingredients = {
                {
                    pack,
                    1,
                },
            },
        }
    end
    data.raw.technology[name] = prototype
end

data.raw.lab = {}
data.raw.recipe = {}
data.raw.technology = {}
for _, recipe_name in pairs({
    "test-way-a",
    "test-way-b",
    "test-ingredient-a",
    "test-ingredient-b",
    "test-target-recipe",
}) do
    data.raw.recipe[recipe_name] = {
        type = "recipe",
        name = recipe_name,
        enabled = false,
        results = {},
    }
end
tech("test-way-a-tech", "test-way-a", "test-pack-a")
tech("test-way-b-tech", "test-way-b", "test-pack-b")
tech("test-ingredient-a-tech", "test-ingredient-a", "test-pack-a")
-- Its key sorts after the kept path's (see top.choose_open below)
tech("test-zz-ingredient-b-tech", "test-ingredient-b", "test-pack-late")
tech("test-target-tech", "test-target-recipe", "test-pack-a")
tech("test-kept-tech", "test-target-recipe")

-- The sort takes open nodes by key (top.choose_open), so which way comes first doesn't depend on pairs order: room A's ("recipe: ..." and "technology: ..." keys) before room B's chain ("test-later: ..."), and the target recipe's own tech before the kept one
top.choose_open = function(open)
    local first
    for node_key, _ in pairs(open) do
        if first == nil or node_key < first then
            first = node_key
        end
    end
    return first
end
local ok, err = pcall(function()
    local target_key = gutils.key("recipe", "test-target-recipe")
    local before = sort()
    local kept_name = "exfret-rebuilt-test-target-recipe-unlock-2-suffix"
    for round = 1, 2 do
        randomizations.rebuild_tech_tree()
        local after = sort()
        for context, _ in pairs(before.node_to_context_inds[target_key]) do
            assert(after.node_to_context_inds[target_key][context] ~= nil, "rebuild " .. round .. " lost the target recipe @ " .. top.context_name(context))
        end
        local kept = data.raw.technology[kept_name]
        assert(kept ~= nil and kept.hidden ~= true, "rebuild " .. round .. " didn't keep the crafting path as Unlock 2")
        -- Room A's ways couldn't be prerequisites: room B would wait for room A's pack, and the path is kept for room B
        -- Before 2026-10-10 that left it with none, and judged on room A as well, room B's ways couldn't be either
        local prerequisites = {}
        for _, prerequisite in pairs(kept.prerequisites or {}) do
            table.insert(prerequisites, prerequisite)
        end
        table.sort(prerequisites)
        assert(table.concat(prerequisites, ", ") == "exfret-rebuilt-test-ingredient-b-suffix, exfret-rebuilt-test-way-b-suffix", "rebuild " .. round .. " gave Unlock 2 the prerequisites {" .. table.concat(prerequisites, ", ") .. "}, not room B's ways of crafting what it's researched by and the recipe's ingredient")
        -- The recipe's own tech still takes room A's ingredient, which comes first
        local own = data.raw.technology["exfret-rebuilt-test-target-recipe-suffix"]
        assert(#(own.prerequisites or {}) == 1 and own.prerequisites[1] == "exfret-rebuilt-test-ingredient-a-suffix", "rebuild " .. round .. " gave Unlock 1 the prerequisites {" .. table.concat(own.prerequisites or {}, ", ") .. "}")
    end
end)
top.choose_open = nil
if ok ~= true then
    error(err, 0)
end
print("ok - a kept path is researched after what its recipe and research take where it's kept for, over repeated rebuilds")
