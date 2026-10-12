-- Run from the mod root: lua tests/unit/randomizations/rebuild/test-rebuild-research-planet.lua
-- A recipe only one planet makes takes its rebuilt research from that planet's own technologies, even when another planet's technology unlocking it comes first (like a planet copy's, which unlocks its family's recipes too)
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
config = { operation_readiness = false }
randomizations = {}

local logic = {
    contexts = { home = true },
    type_info = {},
    home_sets = {
        ids = {},
        sets = {},
        of = {},
    },
}
package.loaded["src/logic/state"] = logic
package.loaded["src/logic/init"] = logic
package.loaded["src/lib/random/rng"] = { int = function() return 1 end }
-- The discovered planet, which the sort's discovery rule looks up
package.loaded["src/prototypes/data-utils"] = {
    get_prot = function(_, name)
        if name == "hot" then
            return {
                type = "planet",
                name = "hot",
            }
        end
        return nil
    end,
}
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
-- The rooms accepting a recipe, as the test recipes say
package.loaded["src/prototypes/surfaces/surface-sets"] = { accepted = function(recipe) return recipe.test_accepted end }

local gutils = require("src/lib/graph/graph-utils")
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

local function recipe(name, accepted)
    data.raw.recipe[name] = {
        type = "recipe",
        name = name,
        enabled = false,
        results = {},
    }
    if accepted ~= nil then
        data.raw.recipe[name].surface_conditions = {
            {
                property = "test-property",
                min = 1,
                max = 1,
            },
        }
        data.raw.recipe[name].test_accepted = accepted
    end
end
local function tech(name, unlocked, trigger_item, prerequisites)
    data.raw.technology[name] = {
        type = "technology",
        name = name,
        prerequisites = prerequisites,
        effects = {},
        research_trigger = {
            type = "craft-item",
            item = trigger_item,
        },
    }
    for _, recipe_name in pairs(unlocked) do
        table.insert(data.raw.technology[name].effects, {
            type = "unlock-recipe",
            recipe = recipe_name,
        })
    end
end

-- Another planet's technology unlocks both recipes only the hot planet makes; the planet's own unlocks one of them, after its discovery
recipe("planet-recipe", {
    ["planet: hot"] = true,
})
recipe("unowned-recipe", {
    ["planet: hot"] = true,
})
tech("other-planet-tech", {
    "planet-recipe",
    "unowned-recipe",
}, "other-planet-thing")
data.raw.technology["find-hot"] = {
    type = "technology",
    name = "find-hot",
    unit = {
        count = 1,
        ingredients = {},
    },
    effects = {
        {
            type = "unlock-space-location",
            space_location = "hot",
        },
    },
}
tech("hot-tech", {
    "planet-recipe",
}, "hot-thing", {
    "find-hot",
})

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
    local other = node("technology", "other-planet-tech", "AND", { start })
    local find = node("technology", "find-hot", "AND", { start })
    local hot = node("technology", "hot-tech", "AND", { find })
    local planet_unlock = node("recipe-tech-unlock", "planet-recipe", "OR", {
        other,
        hot,
    })
    node("recipe", "planet-recipe", "AND", { node("recipe-unlock", "planet-recipe", "OR", { planet_unlock }) })
    local unowned_unlock = node("recipe-tech-unlock", "unowned-recipe", "OR", { other })
    node("recipe", "unowned-recipe", "AND", { node("recipe-unlock", "unowned-recipe", "OR", { unowned_unlock }) })
    if reductions.enabled then
        unlock_contraction.contract(graph)
        pass_through.contract(graph)
    end
    logic.graph = graph
end

randomizations.rebuild_tech_tree()
-- The recipe only the hot planet makes has the hot planet's research
assert(data.raw.technology["exfret-rebuilt-planet-recipe-suffix"].research_trigger.item == "hot-thing")
-- One the planet's own technologies don't unlock still takes the technology that does
assert(data.raw.technology["exfret-rebuilt-unowned-recipe-suffix"].research_trigger.item == "other-planet-thing")
print("ok - a recipe only one planet makes takes its research from that planet's technologies")
