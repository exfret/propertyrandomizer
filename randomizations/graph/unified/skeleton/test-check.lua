-- Run from the mod root: lua randomizations/graph/unified/skeleton/test-check.lua
-- The final verdict must include actual operation audit failures so the panel can warn.
config = { operation_readiness = true }
UNIFIED_MATERIAL_RENAMES = {}
old_data_raw = {}
-- The game the check reads merged recipes from (lib/recipe-merges.lua)
data = { raw = { recipe = {} } }
local messages = {}
function log(message)
    table.insert(messages, message)
end
local logic = { type_info = {} }
package.loaded["lib/logic/state"] = logic
package.loaded["lib/logic/init"] = logic
package.loaded["lib/random/rng"] = {}
package.loaded["lib/furnace-selection"] = { new_collisions = function() return {} end }
package.loaded["lib/item-fluid"] = {}
-- Contexts are numbers (lib/graph/contexts.lua); fixtures write them as their names (lib/graph/contexts-for-tests.lua)
local ctx = require("lib/graph/contexts")
local C = require("lib/graph/contexts-for-tests").C
local locked_contexts = {}
-- A science pack keeps every context in the rooms it belongs to (node.science_rooms) and nothing elsewhere, as in protection.lua
local function keeps_room(node, context)
    return node.science_rooms == nil or node.science_rooms[ctx.room(context)] ~= nil
end
local function protects_isolatability(node)
    return node.keep_isolatability == true or node.science_rooms ~= nil
end
local function is_isolatable_context(context)
    local mask = ctx.mask(context)
    return mask ~= nil and ctx.has_ability(mask, ctx.ISOLATABILITY)
end
package.loaded["randomizations/graph/unified/skeleton/protection"] = {
    planet_locked_recipe_contexts = function() return locked_contexts end,
    protects_isolatability = protects_isolatability,
    keeps_room = keeps_room,
    is_isolatable_context = is_isolatable_context,
    is_hard_mechanic_pebble = function(node, context)
        if ctx.home_of(context) ~= nil or not keeps_room(node, context) then
            return false
        end
        return not is_isolatable_context(context) or protects_isolatability(node)
    end,
    -- "room | ia" is kept as "room | ?a", which kept parts write as minus one minus "room | 0a" (see protection.kept_part); nil where nothing is kept
    kept_part = function(node, context)
        if not keeps_room(node, context) then
            return nil
        end
        local mask = ctx.mask(context)
        if protects_isolatability(node) or mask == nil then
            return context
        end
        return -1 - ctx.with_mask(context, ctx.without_ability(mask, ctx.ISOLATABILITY))
    end,
    kept_name = function(kept)
        if kept >= 0 then
            return ctx.name(kept)
        end
        return (string.gsub(ctx.name(-1 - kept), " | [01]", " | ?"))
    end,
}

local gutils = require("lib/graph/graph-utils")
local check = require("randomizations/graph/unified/skeleton/check")

local function fixture(ready)
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local sorted = {
        pebble_keys = {},
        pebble_contexts = {},
        node_to_context_inds = {},
    }
    local function add(kind, name, op, prerequisites)
        logic.type_info[kind] = {}
        local node = gutils.add_node(graph, kind, name, { op = op })
        local node_key = gutils.key(node)
        for _, prerequisite in pairs(prerequisites or {}) do
            gutils.add_edge(graph, prerequisite, node_key)
        end
        local ind = #sorted.pebble_keys + 1
        sorted.pebble_keys[ind] = node_key
        sorted.pebble_contexts[ind] = C("test-room")
        sorted.node_to_context_inds[node_key] = { [C("test-room")] = ind }
        return node_key
    end
    local start = add("start", "", "AND")
    local supply_tech = add("technology", "test-supply", "AND", { start })
    local kit_recipe = add("recipe", "test-kit", "AND", { ready and supply_tech or start })
    local kit = add("item", "test-kit", "OR", { kit_recipe })
    local supply_recipe = add("recipe", "test-supply", "AND", { supply_tech })
    local supply = add("item", "test-supply", "OR", { supply_recipe })
    local build = add("entity-build-item", "test-device", "OR", { kit })
    local own = add("entity-own", "test-device", "OR", { build })
    add("entity-operate", "test-device", "AND", {
        own,
        supply,
    })
    return graph, sorted
end

local num_passed = 0
local function test(name, fn)
    messages = {}
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

test("a final operation gap fails the verdict even when reachability is unchanged", function()
    local graph, sorted = fixture(false)
    local verdict = check.run(graph, sorted, sorted)
    assert(not verdict.ok)
    assert(verdict.operation_failures == 1)
    assert(verdict.unreachable == 0 and verdict.lost == 0 and verdict.missing == 0)
    assert(string.find(messages[#messages], "operation failures 1", 1, true) ~= nil)
end)

test("ready operation passes the final verdict", function()
    local graph, sorted = fixture(true)
    local verdict = check.run(graph, sorted, sorted)
    assert(verdict.ok and verdict.operation_failures == 0)
end)

test("disabling operation readiness retains the reachability verdict", function()
    config.operation_readiness = false
    local graph, sorted = fixture(false)
    local verdict = check.run(graph, sorted, sorted)
    config.operation_readiness = true
    assert(verdict.ok and verdict.operation_failures == 0)
end)

test("the pre-rebuild attempt check does not run the final operation audit", function()
    local graph, sorted = fixture(false)
    local verdict = check.run(graph, sorted, sorted, "UNIFIEDCHECK")
    assert(verdict.ok and verdict.operation_failures == 0)
end)

test("an attempt audited after unlock repair fails when a readiness gap remains", function()
    local graph, sorted = fixture(false)
    local verdict = check.run(graph, sorted, sorted, "UNIFIEDCHECK", true)
    assert(not verdict.ok and verdict.operation_failures == 1)
end)

local function isolation_fixture(kind, protected, science_rooms)
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local node = gutils.add_node(graph, kind, "test-local-goal", {
        op = "OR",
        mechanic = kind ~= "recipe",
        keep_isolatability = protected,
        science_rooms = science_rooms,
    })
    local node_key = gutils.key(node)
    local before = { node_to_context_inds = { [node_key] = { [C("test-room | 11")] = 1 } } }
    local after = { node_to_context_inds = { [node_key] = { [C("test-room | 01")] = 1 } } }
    return graph, before, after, node_key
end

test("an attempt losing a planet-locked recipe's isolatability fails", function()
    local graph, before, after, node_key = isolation_fixture("recipe")
    locked_contexts = { [node_key] = { [C("test-room | 11")] = true } }
    local verdict = check.run(graph, before, after, "UNIFIEDCHECK")
    locked_contexts = {}
    assert(not verdict.ok and verdict.lost == 1)
    assert(verdict.unreachable == 0)
end)

test("rocket launch isolatability fails even when imports preserve reachability", function()
    local graph, before, after = isolation_fixture("launch", true)
    local verdict = check.run(graph, before, after, "UNIFIEDCHECK")
    assert(not verdict.ok and verdict.lost == 1)
    assert(verdict.unreachable == 0)
end)

test("science pack imports may preserve reachability without local production", function()
    local graph, before, after = isolation_fixture("item", false)
    local verdict = check.run(graph, before, after, "UNIFIEDCHECK")
    assert(verdict.ok and verdict.lost == 0)
end)

test("a science pack losing its isolatability in the room it belongs to fails", function()
    local graph, before, after = isolation_fixture("item", nil, { ["test-room"] = true })
    local verdict = check.run(graph, before, after, "UNIFIEDCHECK")
    assert(not verdict.ok and verdict.lost == 1)
end)

test("a science pack lost from a room it doesn't belong to doesn't fail", function()
    local graph, before, _, node_key = isolation_fixture("item", nil, { ["other-room"] = true })
    local verdict = check.run(graph, before, { node_to_context_inds = { [node_key] = {} } }, "UNIFIEDCHECK")
    assert(verdict.ok and verdict.lost == 0)
end)

test("a promised planet-locked context cannot be excused as only isolatability", function()
    local graph, before, after, node_key = isolation_fixture("recipe")
    locked_contexts = { [node_key] = { [C("test-room | 11")] = true } }
    UNIFIED_PROMISED_PEBBLES = {
        {
            node_key = node_key,
            context = C("test-room | 11"),
            rank = 1,
        },
    }
    local verdict = check.run(graph, before, after, "UNIFIEDCHECK")
    locked_contexts = {}
    UNIFIED_PROMISED_PEBBLES = nil
    assert(not verdict.ok and verdict.missing == 1)
end)

test("a promised protected mechanic context cannot be excused as only isolatability", function()
    local graph, before, after, node_key = isolation_fixture("test-mechanic", true)
    UNIFIED_PROMISED_PEBBLES = {
        {
            node_key = node_key,
            context = C("test-room | 11"),
            rank = 1,
        },
    }
    local verdict = check.run(graph, before, after, "UNIFIEDCHECK")
    UNIFIED_PROMISED_PEBBLES = nil
    assert(not verdict.ok and verdict.missing == 1)
end)

test("missing home backings do not fail when protected room contexts are kept", function()
    local graph, before, _, node_key = isolation_fixture("test-mechanic", true)
    UNIFIED_PROMISED_PEBBLES = {
        {
            node_key = node_key,
            context = C("test-room | 00 @ home1"),
            rank = 1,
        },
    }
    local verdict = check.run(graph, before, before, "UNIFIEDCHECK")
    UNIFIED_PROMISED_PEBBLES = nil
    assert(verdict.ok and verdict.missing == 0)
end)

test("trigger promises survive removal of the model's original technology", function()
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local original = gutils.key("technology-trigger", "test-original-trigger")
    local copied = gutils.key(gutils.add_node(graph, "technology-trigger", "test-copied-trigger", { op = "OR" }))
    UNIFIED_TRIGGER_TAKERS = { ["test-original-trigger"] = { "test-copied-trigger" } }
    UNIFIED_PROMISED_PEBBLES = {
        {
            node_key = original,
            context = C("test-room | 00"),
            rank = 1,
        },
    }
    local before = { node_to_context_inds = {} }
    local after = { node_to_context_inds = { [copied] = { [C("test-room | 00")] = 1 } } }
    local verdict = check.run(graph, before, after, "UNIFIEDCHECK")
    assert(verdict.ok and verdict.missing == 0)
    after.node_to_context_inds[copied] = nil
    verdict = check.run(graph, before, after, "UNIFIEDCHECK")
    assert(not verdict.ok and verdict.missing == 1)
    UNIFIED_TRIGGER_TAKERS = nil
    UNIFIED_PROMISED_PEBBLES = nil
end)

test("every copied trigger owes the promised context", function()
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local original = gutils.key(gutils.add_node(graph, "technology-trigger", "test-original-trigger", { op = "OR" }))
    local ready = gutils.key(gutils.add_node(graph, "technology-trigger", "test-ready-trigger", { op = "OR" }))
    gutils.add_node(graph, "technology-trigger", "test-blocked-trigger", { op = "OR" })
    UNIFIED_TRIGGER_TAKERS = {
        ["test-original-trigger"] = {
            "test-ready-trigger",
            "test-blocked-trigger",
        },
    }
    UNIFIED_PROMISED_PEBBLES = {
        {
            node_key = original,
            context = C("test-room | 00"),
            rank = 1,
        },
    }
    local before = { node_to_context_inds = {} }
    local after = { node_to_context_inds = {} }
    after.node_to_context_inds[ready] = { [C("test-room | 00")] = 1 }
    local verdict = check.run(graph, before, after, "UNIFIEDCHECK")
    assert(not verdict.ok and verdict.missing == 1)
    UNIFIED_TRIGGER_TAKERS = nil
    UNIFIED_PROMISED_PEBBLES = nil
end)

test("an unused trigger has no final carrier to check", function()
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    UNIFIED_TRIGGER_TAKERS = { ["test-unused-trigger"] = {} }
    UNIFIED_PROMISED_PEBBLES = {
        {
            node_key = gutils.key("technology-trigger", "test-unused-trigger"),
            context = C("test-room | 00"),
            rank = 1,
        },
    }
    local sorted = { node_to_context_inds = {} }
    local verdict = check.run(graph, sorted, sorted, "UNIFIEDCHECK")
    assert(verdict.ok and verdict.missing == 0)
    UNIFIED_TRIGGER_TAKERS = nil
    UNIFIED_PROMISED_PEBBLES = nil
end)

test("a recipe merged into another owes its promises through the recipe it became", function()
    local graph = {
        nodes = {},
        edges = {},
        sources = {},
    }
    local kept = gutils.key(gutils.add_node(graph, "recipe", "test-cable", { op = "AND" }))
    -- A game of its own, since what was merged is read once per game (merges.into_of)
    local game_before = data
    data = {
        raw = {
            recipe = {
                ["test-cable"] = {
                    name = "test-cable",
                    merged_versions = {
                        {
                            name = "test-cable-on-gleba",
                            is_planet_locked = true,
                        },
                    },
                },
            },
        },
    }
    UNIFIED_PROMISED_PEBBLES = {
        {
            node_key = gutils.key("recipe", "test-cable-on-gleba"),
            context = C("test-room | 11"),
            rank = 1,
        },
    }
    local before = { node_to_context_inds = {} }
    local after = { node_to_context_inds = { [kept] = { [C("test-room | 11")] = 1 } } }
    local verdict = check.run(graph, before, after, "UNIFIEDCHECK")
    assert(verdict.ok and verdict.missing == 0)
    local compared = false
    for _, message in pairs(messages) do
        if string.find(message, "promised pebbles compared 1;", 1, true) ~= nil then
            compared = true
        end
    end
    assert(compared)
    -- Kept as planet-locked by protection, so the recipe it became can't lose even just isolatability there
    locked_contexts = { [kept] = { [C("test-room | 11")] = true } }
    after.node_to_context_inds[kept] = { [C("test-room | 01")] = 1 }
    verdict = check.run(graph, before, after, "UNIFIEDCHECK")
    assert(not verdict.ok and verdict.missing == 1)
    locked_contexts = {}
    data = game_before
    UNIFIED_PROMISED_PEBBLES = nil
end)

print(num_passed .. " checker tests passed")
