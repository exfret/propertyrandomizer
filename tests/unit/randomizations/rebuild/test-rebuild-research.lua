-- Run from the mod root: lua tests/unit/randomizations/rebuild/test-rebuild-research.lua
-- Exercise the actual rebuild when removing old tech prerequisites changes the earliest recipe unlock.
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
require("src/randomizations/rebuild/init")
-- Games are built like logic.build builds them: concrete.lua's unlock nodes, contracted where one technology unlocks a recipe (src/logic/analysis/unlock-contraction.lua), and pass-through nodes left out (src/logic/analysis/pass-through.lua)
local pass_through = require("src/logic/analysis/pass-through")
local reductions = require("src/logic/analysis/reductions")
local unlock_contraction = require("src/logic/analysis/unlock-contraction")

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

-- The game before the rebuild: the target is unlocked by a technology researched by crafting the material and by an alternate one researched with packs, which came after it
local function fresh_game()
    data = { raw = {} }
    data.raw.lab = {}
    data.raw.recipe = {}
    data.raw.technology = {}
    function data:extend(prototypes)
        for _, prototype in pairs(prototypes) do
            self.raw[prototype.type][prototype.name] = prototype
        end
    end
    recipe("test-material-recipe")
    recipe("test-target-recipe")
    tech("test-material-tech", "test-material-recipe")
    tech("test-copied-tech", "test-target-recipe", true)
    tech("test-zalternate-tech", "test-target-recipe")
    UNIFIED_TRIGGER_TAKERS = { ["test-original-trigger"] = { "test-copied-tech" } }
end

logic.build = function()
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local function node(kind, name, op, pres)
        logic.type_info[kind] = logic.type_info[kind] or {}
        local created = gutils.add_node(graph, kind, name, { op = op })
        local key = gutils.key(created)
        for _, pre in pairs(pres or {}) do
            gutils.add_edge(graph, pre, key)
        end
        return key
    end
    local start = node("start", "", "AND")
    local material_tech = node("technology", "test-material-tech", "AND", { start })
    local material = node("recipe", "test-material-recipe", "AND", { node("recipe-unlock", "test-material-recipe", "OR", { node("recipe-tech-unlock", "test-material-recipe", "OR", { material_tech }) }) })
    local trigger = node("technology-trigger", "test-copied-tech", "OR", { material })
    local copied = node("technology", "test-copied-tech", "AND", { trigger })
    local alternate = node("technology", "test-zalternate-tech", "AND", {
        start,
        copied,
    })
    local unlock = node("recipe-tech-unlock", "test-target-recipe", "OR", {
        copied,
        alternate,
    })
    node("recipe", "test-target-recipe", "AND", { node("recipe-unlock", "test-target-recipe", "OR", { unlock }) })
    if reductions.enabled then
        unlock_contraction.contract(graph)
        pass_through.contract(graph)
    end
    logic.graph = graph
end

-- The sort takes open nodes by key (top.choose_open), so which unlock the timeline reaches the target with doesn't depend on pairs order
local top = require("src/lib/sort/context-sort")
local function rebuild_taking(first_of)
    fresh_game()
    top.choose_open = function(open)
        local first
        for node_key, _ in pairs(open) do
            if first == nil or first_of(node_key, first) then
                first = node_key
            end
        end
        return first
    end
    randomizations.rebuild_tech_tree()
    top.choose_open = nil
    return data.raw.technology["exfret-rebuilt-test-target-recipe-suffix"]
end

-- Lowest key first: the material's tech and recipe ("recipe: ..." keys) come before the alternate's tech, so the copied trigger is had in time and the rebuild copies it, as the game before had it first
local rebuilt = rebuild_taking(function(a, b)
    return a < b
end)
assert(rebuilt.research_trigger.item == "test-trigger-material")
assert(rebuilt.research_trigger.count == 630)
assert(#rebuilt.prerequisites == 1)
assert(rebuilt.prerequisites[1] == "exfret-rebuilt-test-material-recipe-suffix")
assert(data.raw.technology["test-copied-tech"].hidden == true)
assert(#UNIFIED_TRIGGER_TAKERS["test-original-trigger"] == 1)
assert(UNIFIED_TRIGGER_TAKERS["test-original-trigger"][1] == rebuilt.name)
print("ok - rebuilt trigger technology requires its crafting recipe despite an earlier alternate unlock")

-- The alternate's route first: the timeline makes the target through the alternate before the material, so the trigger isn't had in time and the rebuild copies the alternate's research rather than make the target wait for the trigger (user, 2026-10-15: the old tree's first unlocker needn't be kept, "we don't care about the old tree anymore")
local function on_alternate_route(node_key)
    return string.find(node_key, "test-zalternate-tech", 1, true) ~= nil or string.find(node_key, "test-target-recipe", 1, true) ~= nil
end
rebuilt = rebuild_taking(function(a, b)
    if on_alternate_route(a) ~= on_alternate_route(b) then
        return on_alternate_route(a)
    end
    return a < b
end)
assert(rebuilt.research_trigger == nil)
assert(rebuilt.unit.count == 1 and #rebuilt.unit.ingredients == 0)
assert(#(rebuilt.prerequisites or {}) == 0)
assert(data.raw.technology["test-copied-tech"].hidden == true)
-- No technology takes the trigger unified randomization promised, so its promise goes (src/prototypes/technology/technology-trigger-promises.lua)
assert(#UNIFIED_TRIGGER_TAKERS["test-original-trigger"] == 0)
print("ok - rebuilt technology copies the alternate's research when the timeline reaches the recipe through it first")
