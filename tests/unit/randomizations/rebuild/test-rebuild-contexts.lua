-- Run from the mod root: lua tests/unit/randomizations/rebuild/test-rebuild-contexts.lua
-- Exercise the actual rebuild with different research paths for the same recipe.
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

local logic = {
    contexts = { home = true },
    type_info = {},
    home_sets = {
        ids = {},
        sets = {},
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
data.raw.lab = {}
data.raw.recipe = {}
data.raw.technology = {}
function data:extend(prototypes)
    for _, prototype in pairs(prototypes) do
        self.raw[prototype.type][prototype.name] = prototype
    end
end

local function recipe(name)
    data.raw.recipe[name] = {
        type = "recipe",
        name = name,
        enabled = false,
        results = {},
    }
end
local function tech(name, unlocked, trigger)
    local prototype = {
        type = "technology",
        name = name,
    }
    prototype.effects = {
        {
            type = "unlock-recipe",
            recipe = unlocked,
        },
    }
    if trigger == true then
        prototype.research_trigger = {
            type = "craft-item",
            item = "test-trigger-material",
            count = 630,
        }
    else
        prototype.unit = {
            count = 1,
            ingredients = {},
        }
    end
    data.raw.technology[name] = prototype
end


local ROOM_A = "planet: test-a"
local ROOM_B = "planet: test-b"
logic.contexts = {
    [ROOM_A] = true,
    [ROOM_B] = true,
}
logic.type_info.room = { context = "room" }
logic.type_info.technology = { context = true }
logic.home_sets = nil
local research_uses_target = false

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
    local pack_a = node("item", "test-pack-a", "OR", { a })
    local later = b
    for i = 1, 12 do
        later = node("test-later", tostring(i), "OR", { later })
    end
    local pack_b = node("item", "test-pack-b", "OR", { later })
    local unlock = node("recipe-tech-unlock", "test-target-recipe", "OR")
    local target = node("recipe", "test-target-recipe", "AND", { node("recipe-unlock", "test-target-recipe", "OR", { unlock }) })
    if research_uses_target == true then
        gutils.add_edge(graph, target, pack_b)
    end
    for name, prototype in pairs(data.raw.technology) do
        local science = prototype.unit.ingredients[1][1] == "test-pack-a" and pack_a or pack_b
        local key = node("technology", name, "AND")
        gutils.add_edge(graph, science, key, {
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
                gutils.add_edge(graph, key, unlock)
            end
        end
    end
    if reductions.enabled then
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

local function providers()
    local count = 0
    for name, technology in pairs(data.raw.technology) do
        local num_unlocks = 0
        local unlocks_target = false
        for _, effect in pairs(technology.effects or {}) do
            if effect.type == "unlock-recipe" then
                num_unlocks = num_unlocks + 1
            end
            if effect.type == "unlock-recipe" and effect.recipe == "test-target-recipe" then
                count = count + 1
                unlocks_target = true
                assert(technology.hidden ~= true, "a retained research path must stay visible")
            end
        end
        if unlocks_target then
            -- A kept path is a tech of its own (src/randomizations/rebuild/rebuild-unlocks.lua), never the original
            assert(string.sub(name, 1, string.len("exfret-rebuilt-")) == "exfret-rebuilt-" and num_unlocks == 1, name .. " unlocks the recipe, but isn't one of its rebuilt techs")
        end
    end
    return count
end

local function check(distinct, self_research)
    research_uses_target = self_research == true
    data.raw.recipe = {}
    data.raw.technology = {}
    recipe("test-target-recipe")
    tech("test-source-a", "test-target-recipe")
    local alternate_name = self_research == true and "exfret-rebuilt-test-target-recipe-suffix" or "test-source-b"
    tech(alternate_name, "test-target-recipe")
    data.raw.technology["test-source-a"].unit.ingredients = {
        {
            "test-pack-a",
            1,
        },
    }
    data.raw.technology[alternate_name].unit.ingredients = {
        {
            distinct and "test-pack-b" or "test-pack-a",
            1,
        },
    }
    local before = sort()
    local key = gutils.key("recipe", "test-target-recipe")
    for iteration = 1, 3 do
        if distinct == true and iteration == 2 then
            -- Make the alternate unlock arrive first on the second rebuild.
            -- Reusing its descriptor under the primary's name would overwrite the retained primary path.
            local primary_name = "exfret-rebuilt-test-target-recipe-suffix"
            for name, technology in pairs(data.raw.technology) do
                for _, effect in pairs(technology.effects or {}) do
                    if name ~= primary_name and effect.type == "unlock-recipe" then
                        data.raw.technology[primary_name].prerequisites = { name }
                    end
                end
            end
        end
        randomizations.rebuild_tech_tree()
        local after = sort()
        for context, _ in pairs(before.node_to_context_inds[key]) do
            assert(after.node_to_context_inds[key][context] ~= nil, "rebuild " .. iteration .. " lost alternate unlock context " .. top.context_name(context))
        end
        assert(providers() == (distinct and 2 or 1), "only alternatives contributing a missing context stay")
    end
end

check(true)
print("ok - rebuild keeps alternate room, ability and home contexts over repeated rebuilds")
check(false)
print("ok - rebuild removes redundant unlocks without changing recipe contexts")
check(true, true)
print("ok - a primary research path dependent on the recipe keeps its independent alternate")

-- The dependent's witness uses the independent alternate production unlock.
-- Its primary production technology is reached only after the dependent in the second room.
data.raw.recipe = {}
data.raw.technology = {}
recipe("test-production-recipe")
recipe("test-dependent-recipe")
tech("exfret-rebuilt-test-production-recipe-suffix", "test-production-recipe")
tech("test-independent-production-tech", "test-production-recipe")
tech("test-dependent-tech", "test-dependent-recipe")
data.raw.technology["exfret-rebuilt-test-production-recipe-suffix"].unit.ingredients = {
    {
        "test-pack-a",
        1,
    },
}
data.raw.technology["test-independent-production-tech"].unit.ingredients = {
    {
        "test-pack-b",
        1,
    },
}
data.raw.technology["test-dependent-tech"].unit.ingredients = {
    {
        "test-production-pack",
        1,
    },
}
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
    local pack_a = node("item", "test-pack-a", "OR", { a })
    local pack_b = node("item", "test-pack-b", "OR", { b })
    local production_unlock = node("recipe-tech-unlock", "test-production-recipe", "OR")
    local production = node("recipe", "test-production-recipe", "AND", { node("recipe-unlock", "test-production-recipe", "OR", { production_unlock }) })
    local dependent_unlock = node("recipe-tech-unlock", "test-dependent-recipe", "OR")
    local dependent = node("recipe", "test-dependent-recipe", "AND", { node("recipe-unlock", "test-dependent-recipe", "OR", { dependent_unlock }) })
    local production_pack = node("item", "test-production-pack", "OR", { production })
    gutils.add_edge(graph, dependent, pack_a)
    local science = {
        ["test-pack-a"] = pack_a,
        ["test-pack-b"] = pack_b,
        ["test-production-pack"] = production_pack,
    }
    for name, prototype in pairs(data.raw.technology) do
        local key = node("technology", name, "AND")
        gutils.add_edge(graph, science[prototype.unit.ingredients[1][1]], key, {
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
    if reductions.enabled then
        unlock_contraction.contract(graph)
        pass_through.contract(graph)
    end
    logic.graph = graph
end
local before_frontier = sort()
randomizations.rebuild_tech_tree()
local after_frontier = sort()
local frontier_recipes = {
    "test-production-recipe",
    "test-dependent-recipe",
}
for _, name in pairs(frontier_recipes) do
    local key = gutils.key("recipe", name)
    for context, _ in pairs(before_frontier.node_to_context_inds[key]) do
        assert(after_frontier.node_to_context_inds[key][context] ~= nil, "substituting a later primary unlock lost " .. name .. " @ " .. top.context_name(context))
    end
end
print("ok - a prerequisite witness cannot be replaced with a later primary unlock")
