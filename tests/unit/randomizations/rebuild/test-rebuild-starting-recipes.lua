-- Run from the mod root: lua tests/unit/randomizations/rebuild/test-rebuild-starting-recipes.lua
-- A planet's starting recipes come with its discovery in the tech tree rebuild (src/randomizations/rebuild/starting-recipes.lua, randomizations.rebuild_tech_tree in src/randomizations/rebuild/init.lua)
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
local logged = {}
function log(message)
    table.insert(logged, message)
end
serpent = { block = tostring }
mods = {}
config = { operation_readiness = false }
randomizations = {}

local ROOM_A = "planet: test-a"
local ROOM_B = "planet: test-b"
local ROOM_C = "planet: test-c"
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
-- Contexts are numbers (src/logic/contexts/contexts.lua) and edge abilities codes; fixtures write ability masks and edge abilities as they used to be written, like "10" and { [2] = true } (tests/unit/logic/contexts/contexts-for-tests.lua)
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

-- A recipe with a tech of its own: research is a pack name, or a table { trigger = item name } for a tech researched by crafting that item
local function recipe_with_tech(recipe_name, research)
    data.raw.recipe[recipe_name] = {
        type = "recipe",
        name = recipe_name,
        enabled = false,
        results = {},
    }
    local tech = {
        type = "technology",
        name = recipe_name .. "-tech",
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
            count = 1,
            ingredients = {
                {
                    research,
                    1,
                },
            },
        }
    end
    data.raw.technology[tech.name] = tech
end

-- A tech discovering a planet, researched with a pack
local function discovery(name, planet_name, pack)
    data.raw.technology[name] = {
        type = "technology",
        name = name,
        effects = {
            {
                type = "unlock-space-location",
                space_location = planet_name,
            },
        },
        unit = {
            count = 1,
            ingredients = {
                {
                    pack,
                    1,
                },
            },
        },
    }
end

-- The game: build_world(node, recipe_node) adds the rooms, items and recipes, where node(kind, name, op, pres, extra) adds a node (with extra fields), its prerequisites by key, and recipe_node(name, pres) a recipe needing its unlock and pres, with the item it makes
-- Techs come from data.raw.technology, as src/logic/builders/concrete.lua builds them: research edges gain automatability, and a trigger tech goes through its technology-trigger node
local function world(build_world)
    data.raw = {
        lab = {},
        recipe = {},
        technology = {},
    }
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
                local fields = { op = op }
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
            local unlock = node("recipe-tech-unlock", name, "OR")
            local all = { node("recipe-unlock", name, "OR", { unlock }) }
            for _, pre in pairs(pres) do
                table.insert(all, pre)
            end
            local key = node("recipe", name, "AND", all)
            return node("item", name .. "-product", "OR", { key })
        end
        build_world(node, recipe_node)
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
end

local function sort()
    logic.build()
    return top.sort(logic.graph, nil, nil, {
        complex_contexts = true,
        home_contexts = true,
    })
end

-- Every recipe keeps every context it had before the rebuild
local function assert_kept(before, after, label)
    for node_key, contexts in pairs(before.node_to_context_inds) do
        if gutils.deconstruct(node_key).type == "recipe" then
            for context, _ in pairs(contexts) do
                assert((after.node_to_context_inds[node_key] or {})[context] ~= nil, label .. ": lost " .. node_key .. " @ " .. top.context_name(context))
            end
        end
    end
end

local function rebuilt(recipe_name)
    return data.raw.technology["exfret-rebuilt-" .. recipe_name .. "-suffix"]
end
local function unlocks(tech, recipe_name)
    for _, effect in pairs((tech or {}).effects or {}) do
        if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
            return true
        end
    end
    return false
end
-- Whether tech_name needs target_name through prerequisites
local function needs(tech_name, target_name)
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
local function logged_line(pattern)
    for _, message in pairs(logged) do
        if string.find(message, pattern, 1, true) ~= nil then
            return message
        end
    end
    return nil
end

-- Room B, which test-zdiscover discovers, makes electricity from its own resources with four things, each with its own recipe and tech:
--   * a generator only room B makes, researched with a pack: the discovery unlocks it, and its own tech goes
--   * a pole both rooms make, researched with the pack before the discovery: its tech becomes a prerequisite of the discovery
--   * a drill only room B makes, researched by crafting a tool room B makes: its tech stays, and the tool's recipe (only room B, researched with a pack) is on the route to that trigger, so the discovery unlocks it
--   * fuel only room B makes, researched by crafting something only room A makes: room B can't meet that trigger, so the discovery unlocks it
-- A recipe nothing on that route needs keeps its tech, and isn't a prerequisite of the discovery
local function main_world()
    world(function(node, recipe_node)
        local start = node("start", "", "AND")
        local a = node("room", ROOM_A, "OR", { start })
        node("item", "test-pack", "OR", { a })
        local a_thing = node("item", "test-a-thing", "OR", { a })
        local b = node("room", ROOM_B, "OR", { node("technology", "test-zdiscover", "AND") })
        local b_input = node("item", "test-b-input", "OR", { b })
        local ab_input = node("item", "test-ab-input", "OR", {
            a,
            b,
        })
        local generator = recipe_node("test-generator", { b_input })
        local pole = recipe_node("test-pole", { ab_input })
        local drill = recipe_node("test-drill", { b_input })
        recipe_node("test-b-tool", { b_input })
        local fuel = recipe_node("test-fuel", { b_input })
        recipe_node("test-unrelated", { b_input })
        node("energy-source-electric", "", "AND", {
            generator,
            pole,
            drill,
            fuel,
        }, { keep_planetary_isolatability = true })
        assert(a_thing ~= nil)
    end)
    recipe_with_tech("test-generator", "test-pack")
    recipe_with_tech("test-pole", "test-pack")
    recipe_with_tech("test-drill", { trigger = "test-b-tool-product" })
    recipe_with_tech("test-b-tool", "test-pack")
    recipe_with_tech("test-fuel", { trigger = "test-a-thing" })
    recipe_with_tech("test-unrelated", "test-pack")
    discovery("test-zdiscover", "test-b", "test-pack")
end

for _, contract in pairs({
    false,
    true,
}) do
    reductions.enabled = contract
    local label = contract and "contracted" or "full"
    main_world()
    logic.contexts = {
        [ROOM_A] = true,
        [ROOM_B] = true,
    }
    local before = sort()
    local isolatable = top.context_key(ROOM_B, fx.mask("10"))
    assert(top.isolatable_in(before.node_to_context_inds[gutils.key("energy-source-electric", "")], ROOM_B), label .. ": the fixture makes electricity in room B from its own resources")
    assert(before.node_to_context_inds[gutils.key("technology-trigger", "test-drill-tech")][isolatable] ~= nil, label .. ": room B meets the drill's trigger itself")
    assert(top.isolatable_in(before.node_to_context_inds[gutils.key("technology-trigger", "test-fuel-tech")], ROOM_B) == false, label .. ": room B can't meet the fuel's trigger itself")
    logged = {}
    randomizations.rebuild_tech_tree()
    local discover = data.raw.technology["test-zdiscover"]
    for _, recipe_name in pairs({
        "test-generator",
        "test-b-tool",
        "test-fuel",
    }) do
        assert(unlocks(discover, recipe_name), label .. ": the discovery unlocks " .. recipe_name)
        assert(rebuilt(recipe_name) == nil, label .. ": " .. recipe_name .. " has no tech of its own")
    end
    for _, recipe_name in pairs({
        "test-pole",
        "test-drill",
        "test-unrelated",
    }) do
        assert(not unlocks(discover, recipe_name), label .. ": the discovery doesn't unlock " .. recipe_name)
        assert(rebuilt(recipe_name) ~= nil, label .. ": " .. recipe_name .. " keeps its own tech")
    end
    assert(needs("test-zdiscover", "exfret-rebuilt-test-pole-suffix"), label .. ": the pole's tech is a prerequisite of the discovery")
    assert(not needs("test-zdiscover", "exfret-rebuilt-test-unrelated-suffix"), label .. ": a recipe off the route isn't")
    assert(rebuilt("test-drill").research_trigger ~= nil and needs("exfret-rebuilt-test-drill-suffix", "test-zdiscover"), label .. ": the drill stays a trigger tech after the discovery")
    for tech_name, tech in pairs(data.raw.technology) do
        for _, prereq in pairs(tech.prerequisites or {}) do
            assert(data.raw.technology[prereq] ~= nil, label .. ": " .. tech_name .. " needs a tech that's gone: " .. prereq)
        end
    end
    assert_kept(before, sort(), label)
    local summary = logged_line("Tech tree rebuild: planets' starting recipes: ")
    assert(summary ~= nil and string.find(summary, "1 techs made prerequisites of the discovery, 1 left as triggers the planet meets, 3 recipes unlocked by the discovery instead of a tech of their own, 0 unlocked by the discovery and still by their own tech", 1, true) ~= nil, label .. ": the rebuild says what it did: " .. tostring(summary))
    local kept = logged_line("starting recipes' techs made prerequisites of their discovery were left out by the check")
    assert(kept ~= nil and string.find(kept, "Tech tree rebuild: 0 of 1 ", 1, true) ~= nil, label .. ": the check keeps the pole's tech before the discovery: " .. tostring(kept))

    -- A second rebuild, like the one after the rest of randomization, finds the same: the discovery's research doesn't come back as the packaged recipes' own techs
    logged = {}
    before = sort()
    randomizations.rebuild_tech_tree()
    discover = data.raw.technology["test-zdiscover"]
    for _, recipe_name in pairs({
        "test-generator",
        "test-b-tool",
        "test-fuel",
    }) do
        assert(unlocks(discover, recipe_name), label .. ", again: the discovery unlocks " .. recipe_name)
        assert(rebuilt(recipe_name) == nil, label .. ", again: " .. recipe_name .. " has no tech of its own")
    end
    assert(needs("test-zdiscover", "exfret-rebuilt-test-pole-suffix"), label .. ", again: the pole's tech is a prerequisite of the discovery")
    assert(rebuilt("test-drill") ~= nil and rebuilt("test-drill").research_trigger ~= nil, label .. ", again: the drill stays a trigger tech")
    assert_kept(before, sort(), label .. ", again")
end
reductions.enabled = true
print("ok - a planet's starting recipes become prerequisites of its discovery, stay triggers it meets, or come with it")
print("ok - a second rebuild keeps them with the discovery")

-- The discovery unlocks two recipes before the rebuild, like vanilla Fulgora's lightning rod: a rod both rooms make, which room B's electricity needs, and an extra nothing there needs
-- The rod stays with the discovery, without a tech of its own copying the discovery's research; the extra gets its own tech as before
-- Room C, which test-cdiscover discovers, and room B both make a cable from an input only they have, which room B's electricity needs; the cable's tech needs room C's discovery, so as a prerequisite it would make room B's discovery wait for room C's
-- (Its name puts its tech after room C's discovery in these sorts, so its first pebble is in room C)
-- So room B's discovery unlocks the cable, and the cable keeps its own tech too, since that one doesn't come after room B's discovery
for _, contract in pairs({
    false,
    true,
}) do
    reductions.enabled = contract
    local label = contract and "contracted" or "full"
    world(function(node, recipe_node)
        local start = node("start", "", "AND")
        local a = node("room", ROOM_A, "OR", { start })
        node("item", "test-pack", "OR", { a })
        local b = node("room", ROOM_B, "OR", { node("technology", "test-zdiscover", "AND") })
        local c = node("room", ROOM_C, "OR", { node("technology", "test-cdiscover", "AND") })
        local ab_input = node("item", "test-ab-input", "OR", {
            a,
            b,
        })
        local bc_input = node("item", "test-bc-input", "OR", {
            b,
            c,
        })
        local rod = recipe_node("test-rod", { ab_input })
        recipe_node("test-extra", { ab_input })
        local cable = recipe_node("test-xcable", { bc_input })
        node("energy-source-electric", "", "AND", {
            rod,
            cable,
        }, { keep_planetary_isolatability = true })
    end)
    recipe_with_tech("test-xcable", "test-pack")
    discovery("test-zdiscover", "test-b", "test-pack")
    discovery("test-cdiscover", "test-c", "test-pack")
    for _, recipe_name in pairs({
        "test-rod",
        "test-extra",
    }) do
        data.raw.recipe[recipe_name] = {
            type = "recipe",
            name = recipe_name,
            enabled = false,
            results = {},
        }
        table.insert(data.raw.technology["test-zdiscover"].effects, {
            type = "unlock-recipe",
            recipe = recipe_name,
        })
    end
    logic.contexts = {
        [ROOM_A] = true,
        [ROOM_B] = true,
        [ROOM_C] = true,
    }
    local before = sort()
    logged = {}
    randomizations.rebuild_tech_tree()
    local discover = data.raw.technology["test-zdiscover"]
    assert(unlocks(discover, "test-rod") and rebuilt("test-rod") == nil, label .. ": the rod stays with the discovery, without a tech of its own")
    assert(not unlocks(discover, "test-extra") and rebuilt("test-extra") ~= nil, label .. ": the extra gets a tech of its own")
    assert(rebuilt("test-xcable") ~= nil and needs("exfret-rebuilt-test-xcable-suffix", "test-cdiscover"), label .. ": the cable's tech needs room C's discovery")
    assert(unlocks(discover, "test-xcable"), label .. ": room B's discovery unlocks the cable")
    assert(not needs("test-zdiscover", "test-cdiscover"), label .. ": room B's discovery doesn't wait for room C's")
    assert_kept(before, sort(), label .. ", old unlocks")
    local summary = logged_line("Tech tree rebuild: planets' starting recipes: ")
    assert(summary ~= nil and string.find(summary, "1 recipes unlocked by the discovery instead of a tech of their own, 1 unlocked by the discovery and still by their own tech", 1, true) ~= nil, label .. ": the rebuild says what it did: " .. tostring(summary))
end
reductions.enabled = true
print("ok - a starting recipe the discovery already unlocked stays with it")
print("ok - a starting recipe whose tech would make the discovery wait for another planet's comes with the discovery and keeps its own tech")
