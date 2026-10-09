-- Run from the mod root: lua lib/test-rebuild-prerequisites.lua
-- Which witness prerequisites the actual rebuild keeps, and the check of the rebuilt game (lib/rebuild-check.lua) leaving out what takes a context away through another tech
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
package.loaded["lib/logic/state"] = logic
package.loaded["lib/logic/init"] = logic
package.loaded["lib/random/rng"] = { int = function() return 1 end }
package.loaded["lib/data-utils"] = {
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
local top = require("lib/graph/context-sort")
local rebuild_check = require("lib/rebuild-check")
-- Contexts are numbers (lib/graph/contexts.lua) and edge abilities codes; fixtures write ability masks and edge abilities as they used to be written, like "10" and { [2] = true } (lib/graph/contexts-for-tests.lua)
local fx = require("lib/graph/contexts-for-tests")
require("randomizations/fixes")

data = { raw = {} }
function data:extend(prototypes)
    for _, prototype in pairs(prototypes) do
        self.raw[prototype.type][prototype.name] = prototype
    end
end

-- A fixture: recipes each unlocked by their own tech, researched with one science pack
-- build_world(node) adds the rest of the game, where node(kind, name, op, pres, abilities) adds a node, its prerequisites by key and their edges' abilities (codes) by key
local function fixture(techs, build_world)
    data.raw = {
        lab = {},
        recipe = {},
        technology = {},
    }
    for recipe_name, pack in pairs(techs) do
        data.raw.recipe[recipe_name] = {
            type = "recipe",
            name = recipe_name,
            enabled = false,
            results = {},
        }
        data.raw.technology[recipe_name .. "-tech"] = {
            type = "technology",
            name = recipe_name .. "-tech",
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = recipe_name,
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
    logic.build = function()
        local graph = {
            nodes = {},
            edges = {},
            sources = {},
        }
        local function node(kind, name, op, pres, abilities)
            logic.type_info[kind] = logic.type_info[kind] or {}
            local key = gutils.key(kind, name)
            if graph.nodes[key] == nil then
                gutils.add_node(graph, kind, name, { op = op })
            end
            for _, pre in pairs(pres or {}) do
                gutils.add_edge(graph, pre, key, { abilities = (abilities or {})[pre] })
            end
            return key
        end
        build_world(node)
        for name, prototype in pairs(data.raw.technology) do
            local key = node("technology", name, "AND")
            for _, ingredient in pairs(prototype.unit.ingredients) do
                gutils.add_edge(graph, gutils.key("item", ingredient[1]), key, {
                    abilities = fx.edge({ [2] = true }),
                })
            end
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

-- A recipe node needing its unlock and other nodes, with the item it makes
local function recipe_node(node, name, pres, abilities)
    local unlock = node("recipe-tech-unlock", name, "OR")
    table.insert(pres, unlock)
    local key = node("recipe", name, "AND", pres, abilities)
    node("item", name .. "-product", "OR", { key })
    return key
end

local function prerequisites(recipe_name)
    local set = {}
    for _, prereq in pairs(data.raw.technology["exfret-rebuilt-" .. recipe_name .. "-suffix"].prerequisites or {}) do
        set[prereq] = true
    end
    return set
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

-- A machine whose recipe is automatable only with the target recipe's product, though anything using the machine is automatable once it's built (like sulfur in a hand-crafted chemical plant)
-- The machine's tech still comes first, so it's a prerequisite even though the target recipe is automatable before the machine's recipe is
fixture({
    ["test-machine"] = "test-pack",
    ["test-target"] = "test-pack",
}, function(node)
    local start = node("start", "", "AND")
    local a = node("room", ROOM_A, "OR", { start })
    node("item", "test-pack", "OR", { a })
    local target_product = node("item", "test-target-product", "OR")
    local hand_input = node("item", "test-hand-input", "OR", {
        a,
        target_product,
    }, {
        [a] = fx.edge({ [2] = false }),
    })
    recipe_node(node, "test-machine", { hand_input })
    local machine = gutils.key("item", "test-machine-product")
    recipe_node(node, "test-target", { machine }, {
        [machine] = fx.edge({ [2] = true }),
    })
end)
logic.contexts = {
    [ROOM_A] = true,
}
local before = sort()
local automatable = top.context_key(ROOM_A, fx.mask("01"))
assert(before.node_to_context_inds[gutils.key("recipe", "test-machine")][automatable] > before.node_to_context_inds[gutils.key("recipe", "test-target")][automatable], "the fixture's machine recipe is automatable after the target recipe")
randomizations.rebuild_tech_tree()
assert(prerequisites("test-target")["exfret-rebuilt-test-machine-suffix"], "the machine's tech must be a prerequisite though its recipe is automatable later")
assert_kept(before, sort(), "machine")
print("ok - a prerequisite is kept when only its recipe reaches a context after the target recipe")

-- A recipe made only in room B, whose original tech is isolatable in room A, needing an input whose tech isn't
-- In room A the recipe's tech unlocks nothing, so it can lose isolatability there to the input's tech
fixture({
    ["test-input"] = "test-pack-b",
    ["test-target"] = "test-pack-a",
}, function(node)
    local start = node("start", "", "AND")
    local a = node("room", ROOM_A, "OR", { start })
    local b = node("room", ROOM_B, "OR", { start })
    node("item", "test-pack-a", "OR", { a })
    node("item", "test-pack-b", "OR", { b })
    local b_input = node("item", "test-b-input", "OR", { b })
    recipe_node(node, "test-input", {})
    recipe_node(node, "test-target", {
        gutils.key("item", "test-input-product"),
        b_input,
    })
end)
logic.contexts = {
    [ROOM_A] = true,
    [ROOM_B] = true,
}
before = sort()
assert(before.node_to_context_inds[gutils.key("technology", "test-target-tech")][top.context_key(ROOM_A, fx.mask("10"))] ~= nil and before.node_to_context_inds[gutils.key("technology", "test-input-tech")][top.context_key(ROOM_A, fx.mask("10"))] == nil, "the fixture's target tech is isolatable in room A and its input's tech isn't")
randomizations.rebuild_tech_tree()
assert(prerequisites("test-target")["exfret-rebuilt-test-input-suffix"], "the input's tech must be a prerequisite of a recipe made only where that tech is just as good")
assert_kept(before, sort(), "other room")
print("ok - contexts where the target recipe can't be made don't keep out a prerequisite")

-- A part made in room A from an input whose tech isn't isolatable in room B, and in room B by another recipe; room B is reached with the product made from the parts
-- The part's tech keeps the input's tech, since the part's recipe is only made in room A, so it isn't isolatable in room B any more
-- The product's witness uses the part made in room A, so the product's tech would wait on the part's tech, and the product made in room B from the other part recipe would lose isolatability there
-- The check of the rebuilt game leaves out the prerequisites that take room B's isolatability away, and keeps the part's own
fixture({
    ["test-input"] = "test-pack-a",
    ["test-part"] = "test-pack-ab",
    ["test-part-b"] = "test-pack-ab",
    ["test-product"] = "test-pack-ab",
}, function(node)
    local start = node("start", "", "AND")
    local a = node("room", ROOM_A, "OR", { start })
    local product = node("item", "test-product-product", "OR")
    local b = node("room", ROOM_B, "OR", { product })
    node("item", "test-pack-a", "OR", { a })
    node("item", "test-pack-ab", "OR", {
        a,
        b,
    })
    local a_input = node("item", "test-a-input", "OR", { a })
    local b_input = node("item", "test-b-input", "OR", { b })
    recipe_node(node, "test-input", {})
    local part = recipe_node(node, "test-part", {
        gutils.key("item", "test-input-product"),
        a_input,
    })
    local part_b = recipe_node(node, "test-part-b", { b_input })
    local parts = node("item", "test-parts", "OR", {
        part,
        part_b,
    })
    recipe_node(node, "test-product", { parts })
end)
before = sort()
local isolatable = top.context_key(ROOM_B, fx.mask("10"))
assert(before.node_to_context_inds[gutils.key("recipe", "test-product")][isolatable] ~= nil, "the fixture's product is isolatable in room B")
logged = {}
randomizations.rebuild_tech_tree()
assert(prerequisites("test-part")["exfret-rebuilt-test-input-suffix"], "the part's tech keeps its input's tech")
assert(not prerequisites("test-product")["exfret-rebuilt-test-part-suffix"], "the check must leave out the prerequisite that takes room B's isolatability away")
assert_kept(before, sort(), "chain")
local reported = false
for _, message in pairs(logged) do
    if string.find(message, "Tech tree rebuild check: [1-9]%d* more prerequisites left out") ~= nil then
        reported = true
    end
end
assert(reported, "the check says what it left out")
print("ok - the rebuild check leaves out a prerequisite that takes a context away from another tech's recipe")

-- What the check counts as lost: only nodes the rebuild doesn't replace, and not home contexts on their own
do
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    for _, kind in pairs({
        "technology",
        "recipe-tech-unlock",
        "recipe-unlock",
        "recipe",
    }) do
        gutils.add_node(graph, kind, "test", { op = "OR" })
    end
    local context = top.context_key(ROOM_A, fx.mask("00"))
    local home = top.home_context_key(context, 1)
    local before_sort = { node_to_context_inds = {} }
    for node_key, _ in pairs(graph.nodes) do
        before_sort.node_to_context_inds[node_key] = {
            [context] = 1,
            [home] = 2,
        }
    end
    local lost = rebuild_check.lost(before_sort, graph, { node_to_context_inds = {} })
    assert(#lost == 1 and lost[1].node_key == gutils.key("recipe", "test") and lost[1].context == context, "only the recipe's own context is lost")
end
print("ok - the rebuild check skips techs, unlocks and home contexts")

-- A recipe isolatable before the rebuild only through an alternate unlock, whose rebuilt tech's research isn't isolatable: leaving out that tech's prerequisites can't bring it back, so they stay
-- With research that is isolatable, the prerequisite that isn't is what's left out
do
    local function graph_with(has_alternate, has_prereq)
        local graph = {
            nodes = {},
            edges = {},
            sources = {},
        }
        local function node(kind, name, pres, abilities)
            logic.type_info[kind] = logic.type_info[kind] or {}
            local op = "OR"
            if kind == "start" or kind == "technology" or kind == "recipe" then
                op = "AND"
            end
            local key = gutils.key(gutils.add_node(graph, kind, name, { op = op }))
            for _, pre in pairs(pres) do
                gutils.add_edge(graph, pre, key, { abilities = abilities })
            end
            return key
        end
        local a = node("room", ROOM_A, { node("start", "", {}) })
        local pack = node("item", "test-pack", { a })
        local techs = { node("technology", "test-flat-tech", { pack }, fx.edge({ [1] = false })) }
        if has_alternate then
            table.insert(techs, node("technology", "test-alternate-tech", { pack }))
        end
        if has_prereq then
            local prereq_key = node("technology", "test-prereq-tech", { pack }, fx.edge({ [1] = false }))
            gutils.add_edge(graph, prereq_key, techs[1], { abilities = fx.edge({ [2] = true }) })
        end
        node("recipe", "test-recipe", { node("recipe-tech-unlock", "test-recipe", techs) })
        return graph
    end
    local function sorted(graph)
        return top.sort(graph, nil, nil, {
            complex_contexts = true,
            home_contexts = true,
        })
    end
    logic.contexts = {
        [ROOM_A] = true,
    }
    local flat_graph = graph_with(true, false)
    local flat_sort = sorted(flat_graph)
    local after_graph = graph_with(false, true)
    local after_sort = sorted(after_graph)
    local lost = rebuild_check.lost(flat_sort, after_graph, after_sort)
    local isolatable = top.context_key(ROOM_A, fx.mask("10"))
    local found = false
    for _, pebble in pairs(lost) do
        if pebble.node_key == gutils.key("recipe", "test-recipe") and pebble.context == isolatable then
            found = true
        end
    end
    assert(found, "the fixture's recipe loses isolatability with only the rebuilt tech")
    local full_prerequisites = {
        ["test-flat-tech"] = { "test-prereq-tech" },
    }
    local cuts = rebuild_check.cuts(lost, flat_graph, flat_sort, after_graph, after_sort, function(tech_name)
        return tech_name == "test-flat-tech" and "test-flat-tech" or nil
    end, full_prerequisites)
    assert(next(cuts) == nil, "research that can't reach the context keeps its prerequisites")
    cuts = rebuild_check.cuts(lost, flat_graph, flat_sort, after_graph, after_sort, function(tech_name)
        return tech_name == "test-flat-tech" and "test-alternate-tech" or nil
    end, full_prerequisites)
    assert((cuts["test-flat-tech"] or {})["test-prereq-tech"], "research that reaches the context loses the prerequisite that doesn't")
end
print("ok - the rebuild check only leaves out prerequisites when the tech's own research reaches the context")

-- A tech's prerequisite that reduce left out, because the prerequisite it kept already needs it, is left out with that one when it can't send the context either, so the tech gets the context in one round
-- One that can send the context stays
do
    -- Every edge into a tech asks for automatability (lib/logic/concrete.lua), and test-needed's research isn't isolatable
    local tech_abilities = fx.edge({ [2] = true })
    local function new_graph()
        return {
            nodes = {},
            edges = {},
            sources = {},
        }
    end
    local function add(graph, kind, name, pres, abilities)
        logic.type_info[kind] = logic.type_info[kind] or {}
        local op = "OR"
        if kind == "start" or kind == "technology" or kind == "recipe" then
            op = "AND"
        end
        local key = gutils.key(gutils.add_node(graph, kind, name, { op = op }))
        for _, pre in pairs(pres) do
            gutils.add_edge(graph, pre, key, { abilities = abilities })
        end
        return key
    end
    local function pack_of(graph)
        local a = add(graph, "room", ROOM_A, { add(graph, "start", "", {}) })
        return add(graph, "item", "test-pack", { a })
    end
    local function recipe_of(graph, tech)
        add(graph, "recipe", "test-recipe", { add(graph, "recipe-tech-unlock", "test-recipe", { tech }) })
    end
    logic.contexts = {
        [ROOM_A] = true,
    }
    local flat_graph = new_graph()
    recipe_of(flat_graph, add(flat_graph, "technology", "test-tech", { pack_of(flat_graph) }, tech_abilities))
    -- The rebuilt tech's full prerequisites are test-direct, test-needed and test-fine, and reduce kept test-direct, which needs the other two
    local after_graph = new_graph()
    local pack = pack_of(after_graph)
    local needed = add(after_graph, "technology", "test-needed", { pack }, fx.edge({
        [1] = false,
        [2] = true,
    }))
    local fine = add(after_graph, "technology", "test-fine", { pack }, tech_abilities)
    local direct = add(after_graph, "technology", "test-direct", {
        pack,
        needed,
        fine,
    }, tech_abilities)
    recipe_of(after_graph, add(after_graph, "technology", "test-tech", {
        pack,
        direct,
    }, tech_abilities))
    local function sorted(graph)
        return top.sort(graph, nil, nil, {
            complex_contexts = true,
            home_contexts = true,
        })
    end
    local flat_sort = sorted(flat_graph)
    local after_sort = sorted(after_graph)
    local lost = rebuild_check.lost(flat_sort, after_graph, after_sort)
    assert(#lost > 0, "the fixture's recipe loses isolatability through test-needed")
    local cuts = rebuild_check.cuts(lost, flat_graph, flat_sort, after_graph, after_sort, function(tech_name)
        return tech_name == "test-tech" and "test-tech" or nil
    end, {
        ["test-tech"] = {
            "test-direct",
            "test-needed",
            "test-fine",
        },
    })
    local tech_cuts = cuts["test-tech"] or {}
    assert(tech_cuts["test-direct"] and tech_cuts["test-needed"], "the kept prerequisite and the one reduce left out that can't send isolatability are both left out")
    assert(not tech_cuts["test-fine"], "a prerequisite reduce left out that can send isolatability stays")
end
print("ok - the rebuild check leaves out prerequisites reduce left out when they can't send the context either")

-- A recipe made in room B, whose tech is isolatable there only by the discovery rule: room B is discovered, and the tech can be had using only room A (B's home set)
-- The rebuilt tech's prerequisite is researched only in room B, so it sends every context of room B but not the home context, which costs the rebuilt tech room B's isolatability
-- The check leaves out that prerequisite, since the flat tech's home context backs the recipe
do
    local function new_graph()
        return {
            nodes = {},
            edges = {},
            sources = {},
        }
    end
    local function add(graph, kind, name, pres)
        logic.type_info[kind] = logic.type_info[kind] or {}
        local op = "OR"
        if kind == "start" or kind == "technology" or kind == "recipe" then
            op = "AND"
        end
        local key = gutils.key(gutils.add_node(graph, kind, name, { op = op }))
        for _, pre in pairs(pres) do
            gutils.add_edge(graph, pre, key, {})
        end
        return key
    end
    -- Rooms A and B, with B discovered by test-discover-tech, and B's inputs
    local function world(graph)
        local a = add(graph, "room", ROOM_A, { add(graph, "start", "", {}) })
        local pack_a = add(graph, "item", "test-pack-a", { a })
        local b = add(graph, "room", ROOM_B, { add(graph, "technology", "test-discover-tech", { pack_a }) })
        return pack_a, add(graph, "item", "test-pack-b", { b }), add(graph, "item", "test-b-input", { b })
    end
    local function recipe_of(graph, tech, b_input)
        add(graph, "recipe", "test-recipe", {
            add(graph, "recipe-tech-unlock", "test-recipe", { tech }),
            b_input,
        })
    end
    data.raw = {
        technology = {
            ["test-discover-tech"] = {
                type = "technology",
                name = "test-discover-tech",
                effects = {
                    {
                        type = "unlock-space-location",
                        space_location = "test-b",
                    },
                },
            },
        },
    }
    logic.contexts = {
        [ROOM_A] = true,
        [ROOM_B] = true,
    }
    -- Home set ids are numbers, named home1, home2, ... (top.home_name)
    logic.home_sets = {
        ids = { 1 },
        sets = {
            [1] = {
                rooms = {
                    [ROOM_A] = true,
                },
                discovered = {
                    [ROOM_B] = true,
                },
            },
        },
        of = {
            [ROOM_B] = 1,
        },
    }
    local function sorted(graph)
        return top.sort(graph, nil, nil, {
            complex_contexts = true,
            home_contexts = true,
        })
    end
    local flat_graph = new_graph()
    local pack_a, _, b_input = world(flat_graph)
    recipe_of(flat_graph, add(flat_graph, "technology", "test-flat-tech", { pack_a }), b_input)
    local after_graph = new_graph()
    local pack_b
    pack_a, pack_b, b_input = world(after_graph)
    recipe_of(after_graph, add(after_graph, "technology", "test-rebuilt-tech", {
        pack_a,
        add(after_graph, "technology", "test-prereq-tech", { pack_b }),
    }), b_input)
    local flat_sort = sorted(flat_graph)
    local after_sort = sorted(after_graph)
    local isolatable = top.context_key(ROOM_B, fx.mask("10"))
    local recipe_key = gutils.key("recipe", "test-recipe")
    assert(flat_sort.node_to_context_inds[recipe_key][isolatable] ~= nil, "the fixture's recipe is isolatable in room B by the discovery rule")
    assert(after_sort.node_to_context_inds[gutils.key("technology", "test-prereq-tech")][isolatable] ~= nil, "the fixture's prerequisite sends room B's isolatability")
    local lost = rebuild_check.lost(flat_sort, after_graph, after_sort)
    local found = false
    for _, pebble in pairs(lost) do
        if pebble.node_key == recipe_key and pebble.context == isolatable then
            found = true
        end
    end
    assert(found, "the fixture's recipe loses isolatability in room B")
    local cuts = rebuild_check.cuts(lost, flat_graph, flat_sort, after_graph, after_sort, function(tech_name)
        return tech_name == "test-rebuilt-tech" and "test-flat-tech" or nil
    end, {
        ["test-rebuilt-tech"] = { "test-prereq-tech" },
    })
    assert((cuts["test-rebuilt-tech"] or {})["test-prereq-tech"], "the prerequisite that keeps the rebuilt tech from the home context is left out")
    print("ok - the rebuild check leaves out a prerequisite that takes away isolatability from the discovery rule")

    -- The same, but the earliest way to the recipe's isolatability without prerequisites is another tech that unlocked it, which the rebuild didn't keep
    -- The check's backing then goes through that tech, so it follows the backing of the rebuilt tech's own research too (lib/rebuild-check.lua)
    -- Like the original Fulgora's water scaffold for electrolyte on sa/dupes-preview seed 1, isolatable on Fulgora first through Fulgora 2's electromagnetic plant research
    flat_graph = new_graph()
    pack_a, _, b_input = world(flat_graph)
    -- The other tech comes after room B's discovery and the rebuilt tech's flat tech after the other tech, so the other tech is isolatable in room B first whatever order the sort takes nodes in
    local other_tech = add(flat_graph, "technology", "test-other-tech", {
        pack_a,
        gutils.key("technology", "test-discover-tech"),
    })
    local own_tech = add(flat_graph, "technology", "test-flat-tech", {
        pack_a,
        other_tech,
    })
    add(flat_graph, "recipe", "test-recipe", {
        add(flat_graph, "recipe-tech-unlock", "test-recipe", {
            other_tech,
            own_tech,
        }),
        b_input,
    })
    flat_sort = sorted(flat_graph)
    assert(flat_sort.node_to_context_inds[recipe_key][isolatable] ~= nil)
    local backing = top.path(flat_graph, { flat_sort.node_to_context_inds[recipe_key][isolatable] }, flat_sort)
    local through_other = false
    for ind, _ in pairs(backing.in_path) do
        if flat_sort.pebble_keys[ind] == other_tech then
            through_other = true
        end
    end
    assert(through_other, "the fixture's backing goes through the tech the rebuild didn't keep")
    lost = rebuild_check.lost(flat_sort, after_graph, after_sort)
    cuts = rebuild_check.cuts(lost, flat_graph, flat_sort, after_graph, after_sort, function(tech_name)
        return tech_name == "test-rebuilt-tech" and "test-flat-tech" or nil
    end, {
        ["test-rebuilt-tech"] = { "test-prereq-tech" },
    })
    assert((cuts["test-rebuilt-tech"] or {})["test-prereq-tech"], "the prerequisite that keeps the rebuilt tech from the home context is left out, though the backing went through another tech")
    logic.home_sets = nil
end
print("ok - the rebuild check follows the backing of the tech now unlocking a lost recipe, when the backing went through one the rebuild didn't keep")

-- A recipe made only in room B, which a tech discovers, and a recipe made in either room
-- The first one's rebuilt tech needs the discovery, not only the science pack the discovery takes: before, its witness went on through the discovery to the pack, and the tech could be researched before room B could be reached
-- The second one's earliest way is in room A, so its tech doesn't need the discovery
fixture({
    ["test-b-recipe"] = "test-pack",
    ["test-either-recipe"] = "test-pack",
}, function(node)
    local start = node("start", "", "AND")
    local a = node("room", ROOM_A, "OR", { start })
    node("item", "test-pack", "OR", { a })
    local b = node("room", ROOM_B, "OR", { node("technology", "test-discover", "AND") })
    recipe_node(node, "test-b-recipe", { node("item", "test-b-input", "OR", { b }) })
    recipe_node(node, "test-either-recipe", {
        node("item", "test-either-input", "OR", {
            a,
            b,
        }),
    })
end)
data.raw.technology["test-discover"] = {
    type = "technology",
    name = "test-discover",
    effects = {
        {
            type = "unlock-space-location",
            space_location = "test-b",
        },
    },
    unit = {
        count = 1,
        ingredients = {
            {
                "test-pack",
                1,
            },
        },
    },
}
logic.contexts = {
    [ROOM_A] = true,
    [ROOM_B] = true,
}
before = sort()
logged = {}
randomizations.rebuild_tech_tree()
assert(prerequisites("test-b-recipe")["test-discover"], "a recipe made only in a discovered room needs the room's discovery")
assert(not prerequisites("test-either-recipe")["test-discover"], "a recipe whose earliest way is in the start room doesn't")
assert(not data.raw.technology["test-discover"].hidden, "the discovery stays in the tree")
assert_kept(before, sort(), "discovery")
local reported = false
for _, message in pairs(logged) do
    if string.find(message, "Tech tree rebuild: 1 prerequisites on techs the logic needs", 1, true) ~= nil then
        reported = true
    end
    assert(string.find(message, "techs unlock a recipe made only on planets they don't need the discovery of", 1, true) == nil or string.find(message, "Tech tree rebuild: 0 techs", 1, true) ~= nil, "no tech is left without its recipe's discovery: " .. message)
end
assert(reported, "the rebuild says how many needed techs it added")
-- What the check of that counts: without the discovery, the tech could be researched before room B is reached
logic.build()
local tech_recipes = {
    ["exfret-rebuilt-test-b-recipe-suffix"] = "test-b-recipe",
    ["exfret-rebuilt-test-either-recipe-suffix"] = "test-either-recipe",
}
local recipe_rooms = {
    ["test-b-recipe"] = {
        [ROOM_B] = true,
    },
    ["test-either-recipe"] = {
        [ROOM_A] = true,
        [ROOM_B] = true,
    },
}
local function rooms_of(recipe_name)
    return recipe_rooms[recipe_name]
end
assert(#rebuild_check.undiscovered(logic.graph, data.raw.technology, tech_recipes, rooms_of) == 0, "the rebuilt tree leaves no tech without its recipe's discovery")
data.raw.technology["exfret-rebuilt-test-b-recipe-suffix"].prerequisites = {}
local undiscovered = rebuild_check.undiscovered(logic.graph, data.raw.technology, tech_recipes, rooms_of)
assert(#undiscovered == 1 and undiscovered[1].recipe == "test-b-recipe", "a tech whose recipe is made only in a discovered room, without the discovery, is found")
print("ok - a recipe made only in a discovered room needs the discovery")

-- A recipe made only in room B, which a tech researched in room A discovers, whose tech is isolatable there only by the discovery rule, and whose ingredient's tech is researched in room B
-- The ingredient's tech is isolatable in room B from room B's own resources, but not in room B's home set, so as a prerequisite it would take the target tech's isolatability there away
-- The prerequisite filter leaves it out up front, so the check has nothing left to cut (like the original Fulgora's water scaffold for electrolyte on sa/dupes-preview seed 1, under scrap recycling's tech)
fixture({
    ["test-ingredient"] = "test-pack-b",
    ["test-target"] = "test-pack-a",
}, function(node)
    local start = node("start", "", "AND")
    local a = node("room", ROOM_A, "OR", { start })
    node("item", "test-pack-a", "OR", { a })
    local b = node("room", ROOM_B, "OR", { node("technology", "test-discover", "AND") })
    node("item", "test-pack-b", "OR", { b })
    local b_input = node("item", "test-b-input", "OR", { b })
    recipe_node(node, "test-ingredient", { b_input })
    recipe_node(node, "test-target", {
        gutils.key("item", "test-ingredient-product"),
        b_input,
    })
end)
data.raw.technology["test-discover"] = {
    type = "technology",
    name = "test-discover",
    effects = {
        {
            type = "unlock-space-location",
            space_location = "test-b",
        },
    },
    unit = {
        count = 1,
        ingredients = {
            {
                "test-pack-a",
                1,
            },
        },
    },
}
before = sort()
local isolatable_b = top.context_key(ROOM_B, fx.mask("10"))
assert(before.node_to_context_inds[gutils.key("recipe", "test-target")][isolatable_b] ~= nil, "the fixture's target recipe is isolatable in room B")
assert(before.node_to_context_inds[gutils.key("technology", "test-ingredient-tech")][isolatable_b] ~= nil, "the fixture's ingredient tech is isolatable in room B")
logged = {}
randomizations.rebuild_tech_tree()
assert(not prerequisites("test-target")["exfret-rebuilt-test-ingredient-suffix"], "the ingredient's tech would take away the target tech's isolatability from the discovery rule")
assert_kept(before, sort(), "rule")
local nothing_cut = false
for _, message in pairs(logged) do
    if string.find(message, "Tech tree rebuild check: the rebuilt game keeps everything the game had", 1, true) ~= nil then
        nothing_cut = true
    end
end
assert(nothing_cut, "the prerequisite filter leaves it out before the check")
print("ok - a prerequisite without the home context the discovery rule needs is left out up front")
