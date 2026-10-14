-- Small games for plain-Lua tests of the tech tree rebuild (src/randomizations/rebuild/), built the way logic.build builds them (not loaded by the mod)
-- Tests run from the mod root, like: lua tests/unit/randomizations/rebuild/test-rebuild-tree.lua
-- A test calls fixture.world(build) with a function adding the game's rooms, items and recipes, adds techs to data.raw.technology with fixture.recipe_with_tech and fixture.discovery, then runs randomizations.rebuild_tech_tree()

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

local fixture = {
    logged = {},
}
function log(message)
    table.insert(fixture.logged, message)
end
serpent = {
    block = tostring,
    line = tostring,
}
mods = {}
config = {}
randomizations = {}

-- Room A is the starting planet; the others need their discoveries
fixture.ROOM_A = "planet: test-a"
fixture.ROOM_B = "planet: test-b"
fixture.ROOM_C = "planet: test-c"

local logic = {
    contexts = {},
    type_info = {
        room = {
            context = "room",
        },
        technology = {
            context = true,
        },
    },
}
fixture.logic = logic
package.loaded["src/logic/state"] = logic
package.loaded["src/logic/init"] = logic
package.loaded["src/lib/random/rng"] = {
    int = function()
        return 1
    end,
}
package.loaded["src/prototypes/data-utils"] = {
    -- Only the space locations of the discovery rule (see top.discovered_rooms), which are planets here
    get_prot = function(class, name)
        if class == "space-location" then
            return {
                type = "planet",
                name = name,
            }
        end
        return nil
    end,
}
package.loaded["src/localisation/locale"] = {
    find_localised_name = function(prototype)
        return prototype.name
    end,
}
package.loaded["src/prototypes/duplicates/dupe"] = {
    get_recipe_icons = function()
        return {}
    end,
    technology_icons = function(icons)
        return icons
    end,
}
package.loaded["src/prototypes/technology/technology-abilities"] = {
    bundle = function()
        return {}
    end,
}
package.loaded["src/prototypes/entities/fluid-ports"] = {}
package.loaded["src/prototypes/recipes/recycling"] = {}
package.loaded["src/logic/builders/recycling-sources"] = {}
package.loaded["src/prototypes/entities/crafter-slots"] = {}

local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
fixture.gutils = gutils
fixture.top = top
-- These fixtures research techs straight from items, without the logic's science pack sets, so the discovery rule needs full home contexts rather than research ones (top.research_home_contexts)
top.research_home_contexts = false
-- Open nodes come out by key, so which of two techs that need the same things the sorts reach first is set by their names, whatever order pairs gives
top.choose_open = function(open)
    local first
    for node_key, _ in pairs(open) do
        if first == nil or node_key < first then
            first = node_key
        end
    end
    return first
end
-- Contexts are numbers (src/logic/contexts/contexts.lua); fixtures write ability masks as they used to be written, like "10" (tests/unit/logic/contexts/contexts-for-tests.lua)
local fx = require("tests/unit/logic/contexts/contexts-for-tests")
fixture.fx = fx
require("src/randomizations/rebuild/init")
-- Games are built like logic.build builds them: concrete.lua's unlock nodes, contracted where one technology unlocks a recipe (src/logic/analysis/unlock-contraction.lua), and pass-through nodes left out (src/logic/analysis/pass-through.lua)
local pass_through = require("src/logic/analysis/pass-through")
local reductions = require("src/logic/analysis/reductions")
local unlock_contraction = require("src/logic/analysis/unlock-contraction")
fixture.reductions = reductions

data = {
    raw = {},
}
function data:extend(prototypes)
    for _, prototype in pairs(prototypes) do
        self.raw[prototype.type][prototype.name] = prototype
    end
end

-- A locked recipe with a tech of its own (named recipe_name .. "-tech"): research is a pack name, or { trigger = item name } for a tech researched by crafting that item
fixture.recipe_with_tech = function(recipe_name, research, tech_name)
    data.raw.recipe[recipe_name] = data.raw.recipe[recipe_name] or {
        type = "recipe",
        name = recipe_name,
        enabled = false,
        results = {},
    }
    local tech = {
        type = "technology",
        name = tech_name or (recipe_name .. "-tech"),
        effects = {
            {
                type = "unlock-recipe",
                recipe = recipe_name,
            },
        },
    }
    if type(research) == "table" then
        tech.research_trigger = {
            type = "craft-item",
            item = research.trigger,
        }
    else
        tech.unit = {
            count = 10,
            time = 1,
            ingredients = {
                {
                    research,
                    1,
                },
            },
        }
    end
    data.raw.technology[tech.name] = tech
    return tech
end

-- A tech discovering a planet, researched with packs (a name or a list of names), or { trigger = item name } for one researched by crafting that item
-- A tech's packs all come from one room in these games (nothing ships items between rooms), so a discovery needing something from another planet is a trigger
fixture.discovery = function(name, planet_name, packs)
    local tech = {
        type = "technology",
        name = name,
        effects = {
            {
                type = "unlock-space-location",
                space_location = planet_name,
            },
        },
    }
    if type(packs) == "table" and packs.trigger ~= nil then
        tech.research_trigger = {
            type = "craft-item",
            item = packs.trigger,
        }
    else
        if type(packs) ~= "table" then
            packs = { packs }
        end
        local ingredients = {}
        for _, pack in pairs(packs) do
            table.insert(ingredients, {
                pack,
                1,
            })
        end
        tech.unit = {
            count = 100,
            time = 1,
            ingredients = ingredients,
        }
    end
    data.raw.technology[name] = tech
    return tech
end

-- The game: build(node, recipe_node, enabled_recipe_node) adds the rooms, items and recipes
--   * node(kind, name, op, pres, extra) adds a node (with extra fields) and its prerequisites by key
--   * recipe_node(name, pres) adds a locked recipe needing its unlock and pres, and the item it makes (name .. "-product")
--   * enabled_recipe_node(name, pres) adds a recipe enabled from the start (data.raw.recipe too), and its item
-- Techs come from data.raw.technology, as src/logic/builders/concrete.lua builds them: research edges gain automatability, and a trigger tech goes through its technology-trigger node
fixture.world = function(build, rooms)
    data.raw = {
        lab = {},
        recipe = {},
        technology = {},
    }
    logic.contexts = {}
    for _, room in pairs(rooms or {
        fixture.ROOM_A,
        fixture.ROOM_B,
        fixture.ROOM_C,
    }) do
        logic.contexts[room] = true
    end
    logic.build = function()
        local graph = {
            nodes = {},
            edges = {},
            sources = {},
        }
        local function node(kind, name, op, pres, extra)
            logic.type_info[kind] = logic.type_info[kind] or {}
            local key = gutils.key(kind, name)
            if graph.nodes[key] == nil then
                local fields = {
                    op = op,
                }
                for field, value in pairs(extra or {}) do
                    fields[field] = value
                end
                gutils.add_node(graph, kind, name, fields)
            end
            for _, pre in pairs(pres or {}) do
                gutils.add_edge(graph, pre, key)
            end
            return key
        end
        local function recipe_node(name, pres)
            local all = {}
            if data.raw.recipe[name] == nil or data.raw.recipe[name].enabled == false then
                local unlock = node("recipe-tech-unlock", name, "OR")
                table.insert(all, node("recipe-unlock", name, "OR", { unlock }))
            end
            for _, pre in pairs(pres) do
                table.insert(all, pre)
            end
            local key = node("recipe", name, "AND", all)
            return node("item", name .. "-product", "OR", { key })
        end
        local function enabled_recipe_node(name, pres)
            data.raw.recipe[name] = data.raw.recipe[name] or {
                type = "recipe",
                name = name,
                results = {},
            }
            return recipe_node(name, pres)
        end
        build(node, recipe_node, enabled_recipe_node)
        local research = fx.edge({ [2] = true })
        for name, prototype in pairs(data.raw.technology) do
            local key = node("technology", name, "AND")
            if prototype.unit ~= nil then
                for _, ingredient in pairs(prototype.unit.ingredients) do
                    gutils.add_edge(graph, gutils.key("item", ingredient[1]), key, { abilities = research })
                end
            elseif prototype.research_trigger ~= nil then
                local trigger = node("technology-trigger", name, "OR", { gutils.key("item", prototype.research_trigger.item) })
                gutils.add_edge(graph, trigger, key, { abilities = research })
            end
        end
        for name, prototype in pairs(data.raw.technology) do
            local key = gutils.key("technology", name)
            for _, pre in pairs(prototype.prerequisites or {}) do
                gutils.add_edge(graph, gutils.key("technology", pre), key, { abilities = research })
            end
            for _, effect in pairs(prototype.effects or {}) do
                if effect.type == "unlock-recipe" and graph.nodes[gutils.key("recipe-tech-unlock", effect.recipe)] ~= nil then
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
end

fixture.sort = function()
    logic.build()
    return top.sort(logic.graph, nil, nil, {
        complex_contexts = true,
        home_contexts = true,
    })
end

-- Runs the rebuild with a fresh log
fixture.rebuild = function()
    fixture.logged = {}
    randomizations.rebuild_tech_tree()
end

-- The techs unlocking a recipe after the rebuild, sorted by name
fixture.unlockers = function(recipe_name)
    local names = {}
    for tech_name, tech in pairs(data.raw.technology) do
        if tech.hidden ~= true then
            for _, effect in pairs(tech.effects or {}) do
                if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
                    table.insert(names, tech_name)
                end
            end
        end
    end
    table.sort(names)
    return names
end

fixture.rebuilt = function(recipe_name)
    return data.raw.technology["exfret-rebuilt-" .. recipe_name .. "-suffix"]
end

fixture.unlocks = function(tech, recipe_name)
    for _, effect in pairs((tech or {}).effects or {}) do
        if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
            return true
        end
    end
    return false
end

-- Whether tech_name needs target_name through prerequisites
fixture.needs = function(tech_name, target_name)
    local seen = {}
    local pending = { tech_name }
    while #pending > 0 do
        local current = table.remove(pending)
        if current == target_name then
            return true
        end
        if not seen[current] then
            seen[current] = true
            for _, prereq in pairs((data.raw.technology[current] or {}).prerequisites or {}) do
                table.insert(pending, prereq)
            end
        end
    end
    return false
end

fixture.logged_line = function(pattern)
    for _, message in pairs(fixture.logged) do
        if string.find(message, pattern, 1, true) ~= nil then
            return message
        end
    end
    return nil
end

-- Every recipe keeps every context it had before the rebuild
fixture.assert_kept = function(before, after, label)
    for node_key, contexts in pairs(before.node_to_context_inds) do
        if gutils.deconstruct(node_key).type == "recipe" then
            for context, _ in pairs(contexts) do
                assert((after.node_to_context_inds[node_key] or {})[context] ~= nil, label .. ": lost " .. node_key .. " @ " .. top.context_name(context))
            end
        end
    end
end

-- The rebuild's own checks passed (REBUILDCHECK lines, src/randomizations/rebuild/tree-checks.lua)
fixture.assert_checks_pass = function(label)
    local verdict = fixture.logged_line("REBUILDCHECK verdict: ")
    if verdict ~= "REBUILDCHECK verdict: ok" then
        local lines = {}
        for _, message in pairs(fixture.logged) do
            if string.find(message, "REBUILDCHECK", 1, true) ~= nil or string.find(message, "REBUILDCONTEXTS", 1, true) ~= nil then
                table.insert(lines, message)
            end
        end
        error(label .. ": the rebuild's checks failed:\n" .. table.concat(lines, "\n"))
    end
end

return fixture
