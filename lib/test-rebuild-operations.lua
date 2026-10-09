-- Run from the mod root: lua lib/test-rebuild-operations.lua
-- Exercise the actual technology rebuild with operation and placement prerequisites.
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
config = { operation_readiness = true }
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
local fixes = require("randomizations/fixes")
local top = require("lib/graph/context-sort")
local operation = require("lib/logic/operation-requirements")
-- Games are built like logic.build builds them: concrete.lua's unlock nodes, contracted where one technology unlocks a recipe (lib/logic/unlock-contraction.lua), and pass-through nodes left out (lib/logic/pass-through.lua)
local pass_through = require("lib/logic/pass-through")
local reductions = require("lib/logic/reductions")
local unlock_contraction = require("lib/logic/unlock-contraction")

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


local function check(operation_enabled, starts_enabled, placement)
    config.operation_readiness = operation_enabled
    data.raw.recipe = {}
    data.raw.technology = {}
    recipe("test-distribution")
    recipe("test-production")
    recipe("test-device")
    recipe("test-research")
    tech("test-distribution-tech", "test-distribution")
    tech("test-production-tech", "test-production")
    tech("test-device-tech", "test-device")
    tech("test-research-tech", "test-research")
    data.raw.recipe["test-research"].results = {
        {
            type = "item",
            name = "test-research-pack",
            amount = 1,
        },
    }
    -- These research inputs survive the ordinary rebuild, keeping both supplies later than the device.
    data.raw.technology["test-distribution-tech"].unit.ingredients = {
        {
            "test-research-pack",
            1,
        },
    }
    data.raw.technology["test-production-tech"].unit.ingredients = table.deepcopy(data.raw.technology["test-distribution-tech"].unit.ingredients)
    data.raw.recipe["test-device"].results = {
        {
            type = "item",
            name = "test-kit",
            amount = 1,
        },
    }
    data.raw.recipe["test-device"].enabled = starts_enabled
    if starts_enabled == true then
        data.raw.technology["test-device-tech"] = nil
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
        -- Rebuild from current prototypes every time, including technologies made by the operation pass.
        for name, _ in pairs(data.raw.technology) do
            node("technology", name, "AND", { start })
        end
        for name, prototype in pairs(data.raw.recipe) do
            local unlock = node("recipe-tech-unlock", name, "OR", prototype.enabled ~= false and { start } or {})
            local recipe_key = node("recipe", name, "AND", { node("recipe-unlock", name, "OR", { unlock }) })
            for _, product in pairs(prototype.results or {}) do
                local item_key = gutils.key("item", product.name)
                if graph.nodes[item_key] == nil then
                    node("item", product.name, "OR")
                end
                gutils.add_edge(graph, recipe_key, item_key)
            end
        end
        for name, prototype in pairs(data.raw.technology) do
            local tech_key = gutils.key("technology", name)
            for _, prerequisite in pairs(prototype.prerequisites or {}) do
                gutils.add_edge(graph, gutils.key("technology", prerequisite), tech_key)
            end
            for _, ingredient in pairs(prototype.unit ~= nil and prototype.unit.ingredients or {}) do
                gutils.add_edge(graph, gutils.key("item", ingredient[1]), tech_key)
            end
            for _, effect in pairs(prototype.effects or {}) do
                if effect.type == "unlock-recipe" then
                    gutils.add_edge(graph, tech_key, gutils.key("recipe-tech-unlock", effect.recipe))
                end
            end
        end
        local item = gutils.key("item", "test-kit")
        local distribution = gutils.key("recipe", "test-distribution")
        local production = gutils.key("recipe", "test-production")
        local build_item = node("entity-build-item", "test-machine", "OR", { item })
        local build = node("entity-build", "test-machine", "AND", { build_item })
        local own = node("entity-own", "test-machine", "OR", { build })
        local operate = node("entity-operate", "test-machine", "AND", { own })
        if placement == true then
            local rails = node("entity-build-rail", "test-machine", "OR", { distribution })
            gutils.add_edge(graph, rails, build)
        else
            local heat = node("energy-source-heat", "", "AND", {
                distribution,
                production,
            })
            gutils.add_edge(graph, heat, operate)
        end
        if reductions.enabled then
            unlock_contraction.contract(graph)
            pass_through.contract(graph)
        end
        logic.graph = graph
    end
    randomizations.rebuild_tech_tree()
    local function unlocking(recipe_name)
        local result
        for _, technology in pairs(data.raw.technology) do
            for _, effect in pairs(technology.effects or {}) do
                if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
                    assert(result == nil, "fixture recipe must have one unlocking technology")
                    result = technology
                end
            end
        end
        return result
    end
    local rebuilt = unlocking("test-device")
    local requirements = {}
    for _, name in pairs(rebuilt ~= nil and rebuilt.prerequisites or {}) do
        requirements[name] = true
    end
    if operation_enabled == true then
        assert(rebuilt ~= nil)
        assert(requirements[unlocking("test-distribution").name], "the device must wait for distribution or rails")
        if placement ~= true then
            assert(requirements[unlocking("test-production").name], "the device must also wait for heat production")
        end
        assert(data.raw.recipe["test-device"].enabled == false)
    else
        assert(next(requirements) == nil)
    end
    logic.build()
    local gaps = operation.audit(logic.graph, top.sort(logic.graph), "TESTCHECK")
    assert((#gaps == 0) == operation_enabled, "audit must inspect the reflected prerequisites, and disabling must leave the original gap")
end

check(true, false, false)
print("ok - rebuilt device technology requires both heat distribution and production")
check(true, false, true)
print("ok - rebuilt rolling-stock technology includes rails from the placement path")
check(true, true, false)
print("ok - an initially enabled device gets a technology requiring its operation supplies")
check(false, false, false)
print("ok - disabling operation requirements retains the independent unlock")
