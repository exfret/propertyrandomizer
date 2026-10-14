-- Run from the mod root: lua tests/unit/randomizations/rebuild/test-rebuild-derivations.lua
-- What the timeline planner (src/randomizations/rebuild/timeline.lua) reads off the timeline for a technology's prerequisites follows one route, as the sort does: a node that forgets the room takes all its inputs from one context (from a review of the planner, 2026-10-13)
-- Each game runs with recipes' unlocks both full and contracted (src/logic/analysis/unlock-contraction.lua)

local fixture = require("tests/unit/randomizations/rebuild/rebuild-world-for-tests")
local ROOM_A = fixture.ROOM_A
local ROOM_B = fixture.ROOM_B
local ROOM_C = fixture.ROOM_C

local num_passed = 0
-- Runs check(label) once with full unlocks and once contracted
local function test(name, check)
    for _, contract in pairs({
        false,
        true,
    }) do
        fixture.reductions.enabled = contract
        check(contract and "contracted" or "full")
    end
    fixture.reductions.enabled = true
    num_passed = num_passed + 1
    print("ok - " .. name)
end

-- Rooms A (the start), B and C, the latter two discovered by research technologies; returns their nodes
local function rooms(node)
    local start = node("start", "", "AND")
    local a = node("room", ROOM_A, "OR", { start })
    local b = node("room", ROOM_B, "OR", { node("test-reach", "b", "AND", { node("technology", "test-discover-b", "AND") }) })
    local c = node("room", ROOM_C, "OR", { node("test-reach", "c", "AND", { node("technology", "test-discover-c", "AND") }) })
    return a, b, c
end

-- A node forgetting the room, like launching an item (item-launch in src/logic/builders/concrete.lua), takes all its inputs in one context (process_depnode in src/lib/sort/context-sort.lua)
-- Room A makes the cargo first, but only room B can launch it, so what launches it is room B's cargo and room B's pad; taking each input's earliest wherever it was would put room A's cargo with room B's pad
test("a launched item's prerequisites come from the room launching it", function(label)
    fixture.logic.type_info["test-launch"] = {
        context = true,
    }
    fixture.world(function(node, recipe_node)
        local a, b = rooms(node)
        node("item", "test-pack", "OR", { a })
        local cargo = node("item", "test-cargo", "OR", {
            recipe_node("test-cargo-a", { a }),
            recipe_node("test-cargo-b", { b }),
        })
        local launched = node("test-launch", "test-cargo", "AND", {
            cargo,
            recipe_node("test-pad", { b }),
        })
        recipe_node("test-use", {
            a,
            launched,
        })
    end)
    for _, recipe_name in pairs({
        "test-cargo-a",
        "test-cargo-b",
        "test-pad",
        "test-use",
    }) do
        fixture.recipe_with_tech(recipe_name, "test-pack")
    end
    fixture.discovery("test-discover-b", "test-b", "test-pack")
    fixture.discovery("test-discover-c", "test-c", "test-pack")
    local before = fixture.sort()
    fixture.rebuild()
    local use = fixture.rebuilt("test-use")
    assert(use ~= nil, label .. ": the recipe using the launched cargo has a tech")
    assert(fixture.needs(use.name, fixture.rebuilt("test-cargo-b").name), label .. ": its tech comes after room B's way of making the cargo")
    assert(fixture.needs(use.name, fixture.rebuilt("test-pad").name), label .. ": and after the pad launching it")
    assert(not fixture.needs(use.name, fixture.rebuilt("test-cargo-a").name), label .. ": but not after room A's way, whose cargo is never launched")
    fixture.assert_kept(before, fixture.sort(), label)
end)

print(num_passed .. " passed")
