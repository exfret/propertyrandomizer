-- Run from the mod root: lua lib/test-rebuild-research.lua
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
config = { operation_readiness = false }
randomizations = {}

local logic = {
    contexts = { home = true },
    type_info = {},
    home_sets = {
        ids = {},
        sets = {},
    },
}
package.loaded["lib/logic/state"] = logic
package.loaded["lib/logic/init"] = logic
package.loaded["lib/random/rng"] = { int = function() return 1 end }
package.loaded["lib/data-utils"] = { get_prot = function() return nil end }
package.loaded["lib/locale"] = { find_localised_name = function(recipe) return recipe.name end }
package.loaded["lib/dupe"] = {
    get_recipe_icons = function() return {} end,
    technology_icons = function(icons) return icons end,
}
package.loaded["lib/technology-abilities"] = { bundle = function() return {} end }
package.loaded["lib/fluid-ports"] = {}
package.loaded["lib/recycling"] = {}
package.loaded["lib/logic/recycling-sources"] = {}
package.loaded["lib/crafter-slots"] = {}

local gutils = require("lib/graph/graph-utils")
require("randomizations/fixes")

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

recipe("test-material-recipe")
recipe("test-target-recipe")
tech("test-material-tech", "test-material-recipe")
tech("test-copied-tech", "test-target-recipe", true)
tech("test-alternate-tech", "test-target-recipe")

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
    local material = node("recipe", "test-material-recipe", "AND", { material_tech })
    local trigger = node("technology-trigger", "test-copied-tech", "OR", { material })
    local copied = node("technology", "test-copied-tech", "AND", { trigger })
    local alternate = node("technology", "test-alternate-tech", "AND", {
        start,
        copied,
    })
    local unlock = node("recipe-tech-unlock", "test-target-recipe", "OR", {
        copied,
        alternate,
    })
    node("recipe", "test-target-recipe", "AND", { unlock })
    logic.graph = graph
end

randomizations.rebuild_tech_tree()
local rebuilt = data.raw.technology["exfret-rebuilt-test-target-recipe-suffix"]
assert(rebuilt.research_trigger.item == "test-trigger-material")
assert(rebuilt.research_trigger.count == 630)
assert(#rebuilt.prerequisites == 1)
assert(rebuilt.prerequisites[1] == "exfret-rebuilt-test-material-recipe-suffix")
print("ok - rebuilt trigger technology requires its crafting recipe despite an earlier alternate unlock")
