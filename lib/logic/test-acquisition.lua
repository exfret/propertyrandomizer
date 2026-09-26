-- Plain-Lua regression tests for lib/logic/acquisition.lua (not loaded by the mod)
-- Run from the mod root: lua lib/logic/test-acquisition.lua

-- Factorio adds table.deepcopy (core's util.lua); prototype data has no metatables or cycles, so a plain copy does
table.deepcopy = function(object)
    if type(object) ~= "table" then
        return object
    end
    local copy = {}
    for k, v in pairs(object) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end

local acquisition = require("lib/logic/acquisition")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

-- Spawn classes of spawn points written as in base game data
local function class_of(spawn_points)
    local _, points = acquisition.read_spawn_definition({
        "some-unit",
        spawn_points,
    })
    return acquisition.spawn_class(points)
end

-- Curves below are from the 2.1.17 base and space-age data

test("small biters stop spawning, so they're transient", function()
    assert(class_of({{0.0, 0.3}, {0.6, 0.0}}) == "transient")
    -- On spitter spawners
    assert(class_of({{0.0, 0.3}, {0.35, 0}}) == "transient")
end)

test("units that only start spawning above evolution 0 are late", function()
    -- Medium biters, even though they never stop once started
    assert(class_of({{0.2, 0.0}, {0.6, 0.3}, {0.7, 0.1}}) == "late")
    -- Big and behemoth biters
    assert(class_of({{0.5, 0.0}, {1.0, 0.4}}) == "late")
    assert(class_of({{0.9, 0.0}, {1.0, 0.3}}) == "late")
    -- Small spitters
    assert(class_of({{0.25, 0.0}, {0.5, 0.3}, {0.7, 0.0}}) == "late")
end)

test("gleba pentapods follow the same rules", function()
    assert(class_of({{0.0, 0.4}, {0.1, 0.4}, {0.6, 0}}) == "transient")
    assert(class_of({{0.1, 0}, {0.6, 0.4}, {0.95, 0}}) == "late")
    assert(class_of({{0.6, 0}, {0.95, 0.9}, {1, 0.9}}) == "late")
end)

test("positive weight everywhere is persistent, since the last weight holds past the last point", function()
    assert(class_of({{0.0, 0.5}}) == "persistent")
    assert(class_of({{0.0, 0.2}, {0.5, 0.1}}) == "persistent")
end)

test("dropping to zero in the middle counts as transient even if it comes back", function()
    assert(class_of({{0.0, 0.3}, {0.3, 0}, {0.6, 0.3}}) == "transient")
end)

test("a first point above evolution 0 counts as late, since what happens before it is undocumented", function()
    assert(class_of({{0.3, 0.5}}) == "late")
end)

test("no spawn points is late (never spawns)", function()
    assert(class_of({}) == "late")
end)

test("named spawn definitions are read like positional ones", function()
    local unit, points = acquisition.read_spawn_definition({
        unit = "small-biter",
        spawn_points = {
            {
                evolution_factor = 0.0,
                spawn_weight = 0.3,
            },
            {
                evolution_factor = 0.6,
                spawn_weight = 0.0,
            },
        },
    })
    assert(unit == "small-biter")
    assert(#points == 2)
    assert(points[1].evolution == 0.0 and points[1].weight == 0.3)
    assert(points[2].evolution == 0.6 and points[2].weight == 0.0)
    assert(acquisition.spawn_class(points) == "transient")
end)

test("tag adds acq_kind and keeps other edge info", function()
    local extra = acquisition.tag("autoplace", {
        amount = 0,
    })
    assert(extra.acq_kind == "autoplace")
    assert(extra.amount == 0)
    assert(acquisition.tag("spawn").acq_kind == "spawn")
end)

test("tag errors on an unknown kind", function()
    assert(not pcall(acquisition.tag, "autoplaec", {}))
end)

-- Spawn points as read_spawn_definition gives them
local function points_of(spawn_points)
    local _, points = acquisition.read_spawn_definition({
        "some-unit",
        spawn_points,
    })
    return points
end

test("spawn weights are linear between points, hold after the last, and are zero before the first", function()
    local points = points_of({{0.2, 0.0}, {0.6, 0.4}})
    assert(acquisition.spawn_weight_at(points, 0.1) == 0)
    assert(math.abs(acquisition.spawn_weight_at(points, 0.4) - 0.2) < 1e-9)
    assert(acquisition.spawn_weight_at(points, 0.9) == 0.4)
end)

test("flooring spawn points keeps a transient unit spawning", function()
    -- Small biters stop at 0.6 in vanilla
    local floored = acquisition.floor_spawn_points(points_of({{0.0, 0.3}, {0.6, 0.0}}), 0.1)
    assert(acquisition.spawn_class(floored) == "persistent")
    assert(floored[1].weight == 0.3 and math.abs(floored[2].weight - 0.03) < 1e-9)
end)

test("merged spawn points spawn at least as much as either at every evolution", function()
    local early = points_of({{0.0, 0.3}, {0.6, 0.0}})
    local late = points_of({{0.5, 0.0}, {1.0, 0.4}})
    local merged = acquisition.merge_spawn_points(early, late)
    for evolution = 0, 1, 0.05 do
        local weight = acquisition.spawn_weight_at(merged, evolution)
        assert(weight >= acquisition.spawn_weight_at(early, evolution) - 1e-9 and weight >= acquisition.spawn_weight_at(late, evolution) - 1e-9)
    end
    local definition = acquisition.spawn_definition("some-unit", merged)
    assert(definition.unit == "some-unit" and definition.spawn_points[1].evolution_factor == 0 and definition.spawn_points[1].spawn_weight == 0.3)
end)

test("demand tiers come from the entity's class and its item's stack size", function()
    assert(acquisition.demand_tier("inserter", 50) == "bulk")
    assert(acquisition.demand_tier("assembling-machine", 100) == "bulk")
    assert(acquisition.demand_tier("assembling-machine", 50) == "some")
    assert(acquisition.demand_tier("rocket-silo", 1) == "few")
    assert(acquisition.demand_tier("unit", nil) == "some")
    assert(not acquisition.can_supply("bulk", "autoplace") and acquisition.can_supply("bulk", "spawn"))
    assert(acquisition.can_supply("few", "autoplace"))
end)

test("loot is cost-aware and weak carriers don't carry expensive things", function()
    -- A small biter (15 health) carrying steam engines (cost about 5.5) drops one
    assert(acquisition.loot_amount(15, 5.5, "some", 10) == 1)
    -- Cheap bulk items come in larger numbers, up to a stack
    assert(acquisition.loot_amount(15, 0.29, "bulk", 100) == 38)
    assert(acquisition.loot_amount(3000, 0.29, "bulk", 100) == 100)
    assert(acquisition.worth_carrying(15, 5.5))
    assert(not acquisition.worth_carrying(3000, 6220))
    assert(acquisition.worth_salvaging(4, 0.2) and not acquisition.worth_salvaging(6, 0.2))
end)

test("unknown costs fail the balance checks, since loot and salvage can't be balanced without them", function()
    assert(not acquisition.worth_carrying(15, nil))
    assert(not pcall(acquisition.loot_amount, 15, nil, "some", 10))
    assert(not acquisition.worth_salvaging(nil, 1))
    assert(not acquisition.worth_salvaging(1, nil))
    assert(not acquisition.worth_salvaging(nil, nil))
end)

-- A base or head as gutils.subdivide_base_head leaves it: carrying its edge's acq_kind and abilities
local function slot_node(kind, abilities)
    return {
        acq_kind = kind,
        abilities = abilities,
    }
end

test("an item slot for a built entity connects with the slot's own abilities", function()
    local pairing = acquisition.pairing(slot_node("build"), slot_node("build"))
    assert(pairing ~= nil and pairing.abilities == nil)
end)

test("an entity slot for an entity that isn't built keeps the slot's abilities", function()
    local pairing = acquisition.pairing(slot_node("autoplace", {
        [1] = true,
    }), slot_node("spawn"))
    assert(pairing.abilities[1] == true and pairing.abilities[2] == nil)
end)

test("an entity slot for a built entity can't be automated, since its item is salvaged or looted", function()
    local autoplace = slot_node("autoplace", {
        [1] = true,
    })
    local pairing = acquisition.pairing(autoplace, slot_node("build"))
    assert(pairing.abilities[1] == true and pairing.abilities[2] == false)
    -- The slot's own abilities aren't changed
    assert(autoplace.abilities[2] == nil)
    assert(acquisition.pairing(slot_node("spawn"), slot_node("build")).abilities[2] == false)
end)

test("an item slot for an entity that isn't built isn't supported yet", function()
    assert(acquisition.pairing(slot_node("build"), slot_node("autoplace")) == nil)
end)

print(num_passed .. " tests passed")
