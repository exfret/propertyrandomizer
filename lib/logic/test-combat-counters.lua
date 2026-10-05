-- Plain-Lua integration tests for bounded combat-source discovery and direct-ammo scoring.
-- Run from the mod root: lua lib/logic/test-combat-counters.lua

-- Same J/W convention as core util.parse_energy, restricted to this fixture's units.
util = {
    parse_energy = function(value)
        local amount, prefix, unit = value:match("^([%d%.]+)(k?)([JW])$")
        return tonumber(amount) * (prefix == "k" and 1000 or 1) / (unit == "W" and 60 or 1)
    end,
}

local counters = require("lib/logic/combat-counters")
local encounters = require("lib/combat-encounters")
local gutils = require("lib/graph/graph-utils")

local key = gutils.key
local passed = 0
local function test(name, run)
    run()
    passed = passed + 1
    print("ok - " .. name)
end

local function direct_ammo(amount, source_type)
    return {
        source_type = source_type,
        action = {
            type = "direct",
            action_delivery = {
                type = "instant",
                target_effects = {
                    {
                        type = "damage",
                        damage = {
                            type = "test-damage",
                            amount = amount,
                        },
                    },
                },
            },
        },
    }
end

local function attack(category, modifier)
    return {
        type = "projectile",
        range = 20,
        ammo_category = category or "test-ammo-category",
        cooldown = 60,
        damage_modifier = modifier,
    }
end

local function ammo(name, amount, category)
    return {
        name = name,
        type = "ammo",
        ammo_category = category or "test-ammo-category",
        ammo_type = direct_ammo(amount or 10),
    }
end

local function gun(name, modifier, category)
    return {
        name = name,
        type = "gun",
        attack_parameters = attack(category, modifier),
    }
end

local function turret(name, modifier, category)
    return {
        name = name,
        type = "ammo-turret",
        attack_parameters = attack(category, modifier),
    }
end

local function fixture()
    local lu = {
        items = {},
        entities = {
            ["test-target"] = {
                name = "test-target",
                max_health = 100,
            },
        },
    }
    local definition = {
        policy = encounters.policy(),
        targets = {
            {
                entity = "test-target",
                amount = 2,
                reference = { max_health = 1 },
            },
        },
    }
    return lu, definition
end

local function named(results, source_name, ammo_name)
    local name = gutils.concat({
        source_name,
        ammo_name or "builtin",
    })
    for _, result in pairs(results) do
        if result.name == name then
            return result
        end
    end
    error("Expected counter " .. name)
end

local function exact_prerequisites(counter, expected)
    assert(#counter.prerequisites == #expected)
    local remaining = {}
    for _, prerequisite in pairs(expected) do
        remaining[prerequisite] = true
    end
    for _, prerequisite in pairs(counter.prerequisites) do
        assert(remaining[prerequisite], "Unexpected prerequisite " .. prerequisite)
        remaining[prerequisite] = nil
    end
    assert(next(remaining) == nil)
end

local function triple_fixture()
    local lu, definition = fixture()
    lu.entities = {}
    definition.name = "test-triple-asteroids"
    definition.kind = "asteroid-route"
    definition.targets = {}
    local source_names, prerequisites = {}, {}
    for index = 1, 3 do
        local suffix = tostring(index)
        local category = "test-triple-category-" .. suffix
        local ammo_name = "test-triple-round-" .. suffix
        local turret_name = "test-triple-turret-" .. suffix
        local target_name = "test-triple-target-" .. suffix
        local ammunition = ammo(ammo_name, 10, category)
        ammunition.ammo_type.action.action_delivery.target_effects[1].damage.type = "test-triple-damage-" .. suffix
        lu.items[ammo_name] = ammunition
        lu.entities[turret_name] = turret(turret_name, 1, category)
        local target = {
            name = target_name,
            max_health = 100,
            resistances = {},
        }
        for other = 1, 3 do
            if other ~= index then
                table.insert(target.resistances, {
                    type = "test-triple-damage-" .. tostring(other),
                    percent = 100,
                })
            end
        end
        lu.entities[target_name] = target
        table.insert(definition.targets, {
            entity = target_name,
            amount = 1,
        })
        table.insert(source_names, gutils.concat({
            key("entity-operate", turret_name),
            ammo_name,
        }))
        table.insert(prerequisites, key("entity-operate", turret_name))
        table.insert(prerequisites, key("item", ammo_name))
    end
    local name = gutils.concat({
        "asteroid-battery",
        source_names[1],
        source_names[2],
        source_names[3],
    })
    return lu, definition, name, prerequisites
end

test("direct ammo retains its particular gun and ammunition requirements and damage modifier", function()
    local lu, definition = fixture()
    lu.items["test-round"] = ammo("test-round")
    lu.items["test-gun"] = gun("test-gun", 2)
    lu.items["test-incompatible-gun"] = gun("test-incompatible-gun", 100, "test-other-category")
    local provide, diagnostics = counters.prepare(lu)
    local results = provide(definition)
    assert(#results == 1 and diagnostics.compiled == 1)
    local result = results[1]
    exact_prerequisites(result, {
        key("item-gun", "test-gun"),
        key("item", "test-round"),
    })
    assert(result.mode == "manual" and result.count == 1)
    assert(result.clear_seconds == 10)
end)

test("the same ammo supports separate ten-turret and one-manual-source counters", function()
    local lu, definition = fixture()
    lu.items["test-round"] = ammo("test-round")
    lu.items["test-gun"] = gun("test-gun")
    lu.entities["test-turret"] = turret("test-turret")
    local provide = counters.prepare(lu)
    local results = provide(definition)
    assert(#results == 2)
    local manual = named(results, key("item-gun", "test-gun"), "test-round")
    local automatic = named(results, key("entity-operate", "test-turret"), "test-round")
    assert(manual.count == 1 and manual.clear_seconds == 20)
    assert(automatic.count == 10 and automatic.clear_seconds == 2)
    exact_prerequisites(automatic, {
        key("entity-operate", "test-turret"),
        key("item", "test-round"),
    })
end)

test("source variants select player and turret damage while vehicles use the first-entry fallback", function()
    local lu, definition = fixture()
    lu.entities["test-target"].max_health = 400
    definition.targets[1].amount = 1
    lu.items["test-round"] = ammo("test-round")
    lu.items["test-round"].ammo_type = {
        direct_ammo(10),
        direct_ammo(20, "player"),
        direct_ammo(40, "turret"),
    }
    lu.items["test-gun"] = gun("test-gun")
    lu.entities["test-turret"] = turret("test-turret")
    lu.entities["test-vehicle"] = {
        name = "test-vehicle",
        guns = { "test-gun" },
    }
    local provide = counters.prepare(lu)
    local results = provide(definition)
    assert(#results == 3)
    assert(named(results, key("item-gun", "test-gun"), "test-round").clear_seconds == 20)
    assert(named(results, key("entity-operate", "test-turret"), "test-round").clear_seconds == 1)
    local vehicle_source = gutils.concat({
        key("entity-operate", "test-vehicle"),
        "test-gun",
    })
    local vehicle = named(results, vehicle_source, "test-round")
    assert(vehicle.clear_seconds == 40 and vehicle.count == 1)
    exact_prerequisites(vehicle, {
        key("entity-operate", "test-vehicle"),
        key("planet", ""),
        key("item", "test-round"),
    })
end)

test("vehicle-specific ammo variants apply without requiring the built-in gun item", function()
    local lu, definition = fixture()
    lu.items["test-hidden-gun"] = gun("test-hidden-gun", 2)
    lu.items["test-round"] = ammo("test-round")
    lu.items["test-round"].ammo_type = {
        direct_ammo(1),
        direct_ammo(25, "vehicle"),
    }
    lu.entities["test-vehicle"] = {
        name = "test-vehicle",
        guns = { "test-hidden-gun" },
    }
    local provide = counters.prepare(lu)
    local source_name = gutils.concat({
        key("entity-operate", "test-vehicle"),
        "test-hidden-gun",
    })
    local result = named(provide(definition), source_name, "test-round")
    assert(result.clear_seconds == 4)
    exact_prerequisites(result, {
        key("entity-operate", "test-vehicle"),
        key("planet", ""),
        key("item", "test-round"),
    })
end)

test("duplicate compatible ammo categories do not spend the profile budget twice", function()
    local lu, definition = fixture()
    lu.items["test-round"] = ammo("test-round")
    lu.items["test-gun"] = gun("test-gun")
    lu.items["test-gun"].attack_parameters.ammo_categories = {
        "test-ammo-category",
        "test-ammo-category",
    }
    local provide, diagnostics = counters.prepare(lu, { max_profiles = 1 })
    assert(#provide(definition) == 1)
    assert(diagnostics.attempted == 1 and diagnostics.compiled == 1)
    assert(not diagnostics.truncated)
end)

test("the profile cap is deterministic and bounds attempts even when profiles are rejected", function()
    local lu, definition = fixture()
    for i = 3, 1, -1 do
        local name = "test-gun-" .. i
        lu.items[name] = gun(name)
    end
    lu.items["test-round"] = ammo("test-round")
    local provide, diagnostics = counters.prepare(lu, { max_profiles = 2 })
    local results = provide(definition)
    assert(#results == 2 and diagnostics.attempted == 2 and diagnostics.truncated)
    assert(results[1].name == gutils.concat({
        key("item-gun", "test-gun-1"),
        "test-round",
    }))
    assert(results[2].name == gutils.concat({
        key("item-gun", "test-gun-2"),
        "test-round",
    }))
    lu.items["test-round"].ammo_type = {}
    provide, diagnostics = counters.prepare(lu, { max_profiles = 2 })
    assert(#provide(definition) == 0)
    assert(diagnostics.attempted == 2 and diagnostics.compiled == 0 and diagnostics.truncated)
end)

test("built-in attacks require the turret operation without inventing ammunition", function()
    local lu, definition = fixture()
    local built_in = {
        name = "test-builtin-turret",
        type = "electric-turret",
        attack_parameters = attack(),
    }
    built_in.attack_parameters.ammo_type = direct_ammo(10)
    lu.entities[built_in.name] = built_in
    local provide = counters.prepare(lu)
    local result = named(provide(definition), key("entity-operate", built_in.name))
    exact_prerequisites(result, { key("entity-operate", built_in.name) })
    assert(result.count == 10 and result.clear_seconds == 2)
end)

test("unmodeled source filters and fluid modifiers cannot produce counters", function()
    local lu, definition = fixture()
    lu.items["test-round"] = ammo("test-round")
    lu.entities["test-filtered"] = turret("test-filtered")
    lu.entities["test-filtered"].attack_target_mask = { "test-mask" }
    lu.entities["test-fluid"] = turret("test-fluid")
    lu.entities["test-fluid"].attack_parameters.fluids = {}
    local provide, diagnostics = counters.prepare(lu)
    assert(#provide(definition) == 0 and diagnostics.compiled == 0)
    assert(diagnostics.rejected[key("entity-operate", "test-filtered")] == "unsupported-source-filter")
    assert(diagnostics.rejected[key("entity-operate", "test-fluid")] == "unsupported-source-filter")
end)

test("turret exclusion masks cannot certify a counter while an unrestricted turret still works", function()
    local lu, definition = fixture()
    lu.items["test-round"] = ammo("test-round")
    lu.entities["test-unrestricted"] = turret("test-unrestricted")
    lu.entities["test-excluding"] = turret("test-excluding")
    lu.entities["test-excluding"].ignore_target_mask = { "test-target-mask" }
    local provide, diagnostics = counters.prepare(lu)
    local results = provide(definition)
    assert(#results == 1)
    named(results, key("entity-operate", "test-unrestricted"), "test-round")
    assert(diagnostics.rejected[key("entity-operate", "test-excluding")] ~= nil)
end)

test("per-shot electricity must fit the buffer and have a recharge path", function()
    local lu, definition = fixture()
    lu.items["test-round"] = ammo("test-round")
    local powered = turret("test-powered-ammo")
    powered.energy_per_shot = "2kJ"
    powered.energy_source = {
        type = "electric",
        buffer_capacity = "1kJ",
        input_flow_limit = "0W",
    }
    lu.entities[powered.name] = powered
    local builtin = {
        name = "test-powered-builtin",
        type = "electric-turret",
        attack_parameters = attack(),
        energy_source = powered.energy_source,
    }
    builtin.attack_parameters.ammo_type = direct_ammo(10)
    builtin.attack_parameters.ammo_type.energy_consumption = "2kJ"
    lu.entities[builtin.name] = builtin
    local provide, diagnostics = counters.prepare(lu)
    assert(#provide(definition) == 0)
    local powered_key = gutils.concat({
        key("entity-operate", powered.name),
        "test-round",
    })
    assert(diagnostics.rejected[powered_key] == "shot-exceeds-buffer")
    local builtin_key = gutils.concat({
        key("entity-operate", builtin.name),
        "builtin",
    })
    assert(diagnostics.rejected[builtin_key] == "shot-exceeds-buffer")
    powered.energy_source.buffer_capacity = "3kJ"
    provide, diagnostics = counters.prepare(lu)
    assert(#provide(definition) == 0)
    assert(diagnostics.rejected[powered_key] == "shot-cannot-recharge")
    assert(diagnostics.rejected[builtin_key] == "shot-cannot-recharge")
    powered.energy_source.input_flow_limit = "1500W"
    powered.energy_source.drain = "500W"
    provide = counters.prepare(lu)
    local results = provide(definition)
    assert(#results == 2)
    local powered_seconds = named(results, key("entity-operate", powered.name), "test-round").clear_seconds
    local builtin_seconds = named(results, key("entity-operate", builtin.name)).clear_seconds
    assert(powered_seconds >= 4 and powered_seconds <= 4 + 1 / 30)
    assert(builtin_seconds == powered_seconds)
end)

test("complementary batteries preserve both weapons and ammunition with ten turrets total", function()
    local lu, definition = fixture()
    definition.name = "test-complementary"
    lu.items["test-first-round"] = ammo("test-first-round", 10, "test-first-category")
    lu.items["test-second-round"] = ammo("test-second-round", 10, "test-second-category")
    lu.items["test-second-round"].ammo_type.action.action_delivery.target_effects[1].damage.type = "test-other-damage"
    lu.entities["test-first-turret"] = turret("test-first-turret", 1, "test-first-category")
    lu.entities["test-second-turret"] = turret("test-second-turret", 1, "test-second-category")
    lu.entities["test-target"].resistances = {
        {
            type = "test-other-damage",
            percent = 100,
        },
    }
    lu.entities["test-other-target"] = {
        max_health = 100,
        resistances = {
            {
                type = "test-damage",
                percent = 100,
            },
        },
    }
    table.insert(definition.targets, {
        entity = "test-other-target",
        amount = 2,
    })
    local provide = counters.prepare(lu)
    local results = provide(definition)
    assert(#results == 1)
    local result = results[1]
    assert(result.mode == "turret" and result.count == 10 and result.clear_seconds == 4)
    assert(#result.sources == 2 and result.sources[1].count + result.sources[2].count == 10)
    exact_prerequisites(result, {
        key("entity-operate", "test-first-turret"),
        key("entity-operate", "test-second-turret"),
        key("item", "test-first-round"),
        key("item", "test-second-round"),
    })
    -- The requested pair retains its proof even when earlier unneeded pairs would exhaust the limit.
    lu.entities["test-a-unneeded-turret"] = turret("test-a-unneeded-turret", 1, "test-first-category")
    local filtered, diagnostics = counters.prepare(lu, {
        counter_names = {
            [definition.name] = { [result.name] = true },
        },
        max_mixed_pairs = 1,
    })
    local selected = filtered(definition)
    assert(#selected == 1 and selected[1].name == result.name)
    assert(selected[1].clear_seconds == result.clear_seconds and selected[1].count == result.count)
    exact_prerequisites(selected[1], result.prerequisites)
    assert(diagnostics.mixed[definition.name].pairs_attempted == 1)
    local feasible, early = counters.prepare(lu, {
        counter_names = {
            [definition.name] = { [result.name] = true },
        },
        retain_dominated = true,
        feasibility_only = true,
    })
    local preserved = feasible(definition)
    assert(#preserved == 1 and preserved[1].name == result.name and preserved[1].count == result.count)
    assert(preserved[1].clear_seconds > result.clear_seconds and preserved[1].clear_seconds <= definition.policy.clear_seconds)
    exact_prerequisites(preserved[1], result.prerequisites)
    assert(early.mixed[definition.name].allocations_attempted == 1)
    lu.entities["test-target"].resistances[2] = {
        type = "test-damage",
        percent = 100,
    }
    assert(#filtered(definition) == 0)
    assert(#feasible(definition) == 0)
end)

test("three complementary asteroid profiles retain all prerequisites within ten turrets", function()
    local lu, definition, expected_name, prerequisites = triple_fixture()
    local provide, diagnostics = counters.prepare(lu)
    local results = provide(definition)
    assert(#results == 1, "Only the three-profile battery can damage every target")
    local result = results[1]
    assert(result.name == expected_name and result.mode == "turret" and result.count == 10)
    assert(result.clear_seconds > 0 and result.clear_seconds <= definition.policy.clear_seconds)
    exact_prerequisites(result, prerequisites)
    assert(#result.sources == 3)
    local total = 0
    for _, source in pairs(result.sources) do
        assert(type(source.name) == "string" and source.count > 0 and source.count % 1 == 0)
        total = total + source.count
    end
    assert(total == result.count)
    assert(diagnostics.asteroid_mixed[definition.name].triples_attempted == 1)
end)

test("terrestrial encounters do not gain three-profile batteries", function()
    local lu, definition = triple_fixture()
    definition.kind = "spawn-group"
    definition.name = "test-triple-terrestrial"
    local provide = counters.prepare(lu)
    assert(#provide(definition) == 0)
end)

test("feasibility-only asteroid counters retain exact names and prerequisite unions", function()
    local lu, definition, expected_name, prerequisites = triple_fixture()
    definition.policy.clear_seconds = 40
    for index, target in pairs(definition.targets) do
        target.amount = index == 3 and 4 or 3
    end
    local complete = counters.prepare(lu)
    local ordinary = complete(definition)
    local provide, diagnostics = counters.prepare(lu, {
        counter_names = {
            [definition.name] = { [expected_name] = true },
        },
        retain_dominated = true,
        feasibility_only = true,
    })
    local results = provide(definition)
    assert(#results == 1 and results[1].name == expected_name and results[1].count == 10)
    assert(results[1].clear_seconds > ordinary[1].clear_seconds and results[1].clear_seconds <= definition.policy.clear_seconds)
    exact_prerequisites(results[1], prerequisites)
    assert(diagnostics.asteroid_mixed[definition.name].allocations_attempted == 1)
    lu.items["test-triple-round-3"] = nil
    provide = counters.prepare(lu, {
        feasibility_only = true,
        retain_dominated = true,
    })
    assert(#provide(definition) == 0)
end)

test("an exact asteroid triple filter retains the third ammunition prerequisite", function()
    local lu, definition, expected_name, prerequisites = triple_fixture()
    for index = 1, 6 do
        local name = "test-a-unneeded-turret-" .. tostring(index)
        lu.entities[name] = turret(name, 1, "test-triple-category-1")
    end
    local options = {
        counter_names = {
            [definition.name] = { [expected_name] = true },
        },
        max_asteroid_triples = 1,
        max_asteroid_scanned_triples = 128,
    }
    local provide, diagnostics = counters.prepare(lu, options)
    local results = provide(definition)
    assert(#results == 1 and results[1].name == expected_name)
    assert(#results[1].sources == 3 and results[1].count == 10)
    exact_prerequisites(results[1], prerequisites)
    assert(diagnostics.asteroid_mixed[definition.name].triples_attempted == 1)
    assert(diagnostics.mixed[definition.name].pairs_attempted == 0)
    lu.items["test-triple-round-3"] = nil
    provide = counters.prepare(lu, options)
    assert(#provide(definition) == 0, "The third ammunition cannot be omitted from a preserved counter")
end)

test("filtering one single counter preserves its measured time and prerequisites", function()
    local lu, definition = fixture()
    definition.name = "test-single"
    lu.items["test-round"] = ammo("test-round")
    lu.items["test-gun"] = gun("test-gun")
    lu.entities["test-turret"] = turret("test-turret")
    local baseline = counters.prepare(lu)
    local expected = named(baseline(definition), key("item-gun", "test-gun"), "test-round")
    local provide = counters.prepare(lu, {
        counter_names = {
            [definition.name] = { [expected.name] = true },
        },
    })
    local result = provide(definition)
    assert(#result == 1 and result[1].name == expected.name)
    assert(result[1].clear_seconds == expected.clear_seconds and result[1].mode == expected.mode)
    exact_prerequisites(result[1], expected.prerequisites)
    lu.entities["test-target"].resistances = {
        {
            type = "test-damage",
            percent = 100,
        },
    }
    assert(#provide(definition) == 0)
end)

test("missing encounter or counter names produce no filtered counter", function()
    local lu, definition = fixture()
    definition.name = "test-missing"
    lu.items["test-round"] = ammo("test-round")
    lu.items["test-gun"] = gun("test-gun")
    lu.entities["test-first-turret"] = turret("test-first-turret")
    lu.entities["test-second-turret"] = turret("test-second-turret")
    local names = {}
    local provide, diagnostics = counters.prepare(lu, { counter_names = names })
    assert(#provide(definition) == 0)
    assert(diagnostics.mixed[definition.name].pairs_attempted == 0)
    assert(diagnostics.mixed[definition.name].work == 0)
    assert(next(diagnostics.evaluation_rejected) == nil)
    names[definition.name] = { ["test-nonexistent-counter"] = true }
    assert(#provide(definition) == 0)
end)

test("deployment aiming options do not mutate another profile's cached summary", function()
    local lu, definition = fixture()
    definition.targets[1].amount = 1
    lu.entities["test-target"].max_health = 50
    lu.entities["test-target"].segment_engine = { segments = { { segment = "test-body" } } }
    lu.entities["test-body"] = {
        resistances = {
            {
                type = "test-damage",
                percent = 100,
            },
        },
    }
    lu.items["test-round"] = ammo("test-round")
    lu.items["test-gun"] = gun("test-gun")
    lu.entities["test-turret"] = turret("test-turret")
    local provide = counters.prepare(lu, { manual_segment_aim = "head" })
    local results = provide(definition)
    assert(#results == 1 and results[1].mode == "manual" and results[1].clear_seconds == 5)
    provide = counters.prepare(lu)
    assert(#provide(definition) == 0)
end)

test("evaluation reads current target properties instead of captured reference statistics", function()
    local lu, definition = fixture()
    lu.items["test-round"] = ammo("test-round")
    lu.items["test-gun"] = gun("test-gun")
    local provide = counters.prepare(lu)
    assert(provide(definition)[1].clear_seconds == 20)
    lu.entities["test-target"].max_health = 200
    assert(provide(definition)[1].clear_seconds == 40)
    lu.entities["test-target"].resistances = {
        {
            type = "test-damage",
            percent = 100,
        },
    }
    assert(#provide(definition) == 0)
    assert(definition.targets[1].reference.max_health == 1)
end)

print(passed .. " tests passed")
