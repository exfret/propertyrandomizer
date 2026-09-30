-- Plain-Lua regression tests for the military rebalance (lib/military.lua), not loaded by the mod
-- Run from the mod root: lua lib/test-military.lua

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
local military = require("lib/military")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function near(a, b, tolerance)
    return math.abs(a - b) <= (tolerance or 1e-6)
end

-- Spawn points as read_spawn_definition gives them
local function points_of(spawn_points)
    local _, points = acquisition.read_spawn_definition({
        "some-unit",
        spawn_points,
    })
    return points
end

-- A spawner's spawns, from {unit, spawn points} pairs written as in game data
local function entries_of(definitions)
    local entries = {}
    for _, definition in pairs(definitions) do
        table.insert(entries, {
            unit = definition[1],
            points = points_of(definition[2]),
        })
    end
    return entries
end

-- Vanilla spawners and health from the 2.1 data (base/prototypes/entity/enemies.lua, space-age/prototypes/entity/enemies.lua)
local biter_spawner = entries_of({
    {"test-small-biter", {{0.0, 0.3}, {0.6, 0.0}}},
    {"test-medium-biter", {{0.2, 0.0}, {0.6, 0.3}, {0.7, 0.1}}},
    {"test-big-biter", {{0.5, 0.0}, {1.0, 0.4}}},
    {"test-behemoth-biter", {{0.9, 0.0}, {1.0, 0.3}}},
})
local spitter_spawner = entries_of({
    {"test-small-biter", {{0.0, 0.3}, {0.35, 0}}},
    {"test-small-spitter", {{0.25, 0.0}, {0.5, 0.3}, {0.7, 0.0}}},
    {"test-medium-spitter", {{0.4, 0.0}, {0.7, 0.3}, {0.9, 0.1}}},
    {"test-big-spitter", {{0.5, 0.0}, {1.0, 0.4}}},
    {"test-behemoth-spitter", {{0.9, 0.0}, {1.0, 0.3}}},
})
local gleba_spawner = entries_of({
    {"test-small-wriggler-pentapod", {{0.0, 0.4}, {0.1, 0.4}, {0.6, 0}}},
    {"test-small-strafer-pentapod", {{0.0, 0.4}, {0.1, 0.4}, {0.6, 0}}},
    {"test-small-stomper-pentapod", {{0.0, 0.2}, {0.1, 0.2}, {0.6, 0}}},
    {"test-medium-wriggler-pentapod", {{0.1, 0}, {0.6, 0.4}, {0.95, 0}}},
    {"test-medium-strafer-pentapod", {{0.1, 0}, {0.6, 0.4}, {0.95, 0}}},
    {"test-medium-stomper-pentapod", {{0.1, 0}, {0.6, 0.2}, {0.95, 0}}},
    {"test-big-wriggler-pentapod", {{0.6, 0}, {0.95, 0.4}, {1, 0.4}}},
    {"test-big-strafer-pentapod", {{0.6, 0}, {0.95, 0.4}, {1, 0.4}}},
    {"test-big-stomper-pentapod", {{0.6, 0}, {0.95, 0.2}, {1, 0.2}}},
})
local small_gleba_spawner = entries_of({
    {"test-small-wriggler-pentapod", {{0.0, 0.9}, {0.1, 0.9}, {0.6, 0}}},
    {"test-medium-wriggler-pentapod", {{0.1, 0}, {0.6, 0.9}, {0.95, 0}}},
    {"test-big-wriggler-pentapod", {{0.6, 0}, {0.95, 0.9}, {1, 0.9}}},
})
local health = {
    ["test-small-biter"] = 15,
    ["test-medium-biter"] = 75,
    ["test-big-biter"] = 375,
    ["test-behemoth-biter"] = 3000,
    ["test-small-spitter"] = 10,
    ["test-medium-spitter"] = 50,
    ["test-big-spitter"] = 200,
    ["test-behemoth-spitter"] = 1500,
    ["test-small-wriggler-pentapod"] = 100,
    ["test-medium-wriggler-pentapod"] = 200,
    ["test-big-wriggler-pentapod"] = 400,
    ["test-small-strafer-pentapod"] = 800,
    ["test-medium-strafer-pentapod"] = 1400,
    ["test-big-strafer-pentapod"] = 2400,
    ["test-small-stomper-pentapod"] = 3500,
    ["test-medium-stomper-pentapod"] = 8000,
    ["test-big-stomper-pentapod"] = 15000,
}
local function health_of(unit)
    return health[unit]
end
local nauvis = {
    biter_spawner,
    spitter_spawner,
}
local gleba = {
    gleba_spawner,
    small_gleba_spawner,
}

local function index_of(entries, unit)
    for index, entry in pairs(entries) do
        if entry.unit == unit then
            return index
        end
    end
end

-- Spawner limits from the same data
local nauvis_limits = military.spawner_limits({
    max_count_of_owned_units = 7,
    max_friends_around_to_spawn = 5,
})
local gleba_limits = military.spawner_limits({
    max_count_of_owned_units = 2,
    max_count_of_owned_defensive_units = 1,
    max_friends_around_to_spawn = 3,
    max_defensive_friends_around_to_spawn = 2,
})
local small_gleba_limits = military.spawner_limits({
    max_count_of_owned_units = 1,
    max_friends_around_to_spawn = 2,
})

-- What a spawner spawns, for limits_with_foreign_units
local function limit_entry(spawn_points, defensive, home)
    return {
        points = points_of(spawn_points),
        defensive = defensive,
        home = home,
    }
end

local function limits_equal(limits, owned, owned_defensive, friends, friends_defensive)
    return limits.owned == owned and limits.owned_defensive == owned_defensive and limits.friends == friends and limits.friends_defensive == friends_defensive
end

test("defensive limits default to the others, and only units that never join attacks are defensive", function()
    assert(limits_equal(nauvis_limits, 7, 7, 5, 5))
    assert(limits_equal(gleba_limits, 2, 1, 3, 2))
    -- Wrigglers never join attacks; stompers, strafers and biters do by default
    assert(military.is_defensive({
        ai_settings = {
            join_attacks = false,
        },
    }))
    assert(not military.is_defensive({
        ai_settings = {
            allow_try_return_to_spawner = true,
        },
    }))
    assert(not military.is_defensive({}))
end)

test("a unit several spawners spawn comes in the numbers of whichever keeps the most", function()
    -- Small wrigglers spawn from both Gleba spawners
    assert(limits_equal(military.loosest_limits({
        gleba_limits,
        small_gleba_limits,
    }), 2, 1, 3, 2))
end)

test("a spawner whose early spawns are all foreign keeps their home's numbers all game", function()
    -- A small stomper in a spitter spawner's small biter slot (floored, as a transient slot's new unit is), with its spitters
    local limits = military.limits_with_foreign_units(nauvis_limits, {
        limit_entry({{0.0, 0.3}, {0.35, 0.03}}, false, gleba_limits),
        limit_entry({{0.25, 0.0}, {0.5, 0.3}, {0.7, 0.0}}, false),
        limit_entry({{0.4, 0.0}, {0.7, 0.3}, {0.9, 0.1}}, false),
        limit_entry({{0.5, 0.0}, {1.0, 0.4}}, false),
        limit_entry({{0.9, 0.0}, {1.0, 0.3}}, false),
    })
    assert(limits_equal(limits, 2, 2, 3, 3))
end)

test("a foreign defensive unit only lowers the defensive limits", function()
    -- A small wriggler in a biter spawner's small biter slot, with its biters
    local wriggler_home = military.loosest_limits({
        gleba_limits,
        small_gleba_limits,
    })
    local limits = military.limits_with_foreign_units(nauvis_limits, {
        limit_entry({{0.0, 0.3}, {0.6, 0.03}}, true, wriggler_home),
        limit_entry({{0.2, 0.0}, {0.6, 0.3}, {0.7, 0.1}}, false),
        limit_entry({{0.5, 0.0}, {1.0, 0.4}}, false),
        limit_entry({{0.9, 0.0}, {1.0, 0.3}}, false),
    })
    assert(limits_equal(limits, 7, 1, 5, 2))
end)

test("a foreign unit that's rare even at its peak only takes its share of the limits", function()
    -- A big stomper in a biter spawner's behemoth slot is 3/8 of its spawns at evolution 1, so 5 units keep 15/8 of them on average, under Gleba's 2
    local limits = military.limits_with_foreign_units(nauvis_limits, {
        limit_entry({{0.0, 0.3}, {0.6, 0.0}}, false),
        limit_entry({{0.2, 0.0}, {0.6, 0.3}, {0.7, 0.1}}, false),
        limit_entry({{0.5, 0.0}, {1.0, 0.4}}, false),
        limit_entry({{0.9, 0.0}, {1.0, 0.3}}, false, gleba_limits),
    })
    assert(limits_equal(limits, 5, 5, 5, 5))
end)

test("the foreign share just before another unit jumps in counts", function()
    -- At 0.5 the foreign unit is half of the spawns until a unit starting with weight 0.9 jumps in and makes it a fifth
    local limits = military.limits_with_foreign_units(nauvis_limits, {
        limit_entry({{0.0, 0.3}}, false),
        limit_entry({{0.0, 0.0}, {0.5, 0.3}}, false, gleba_limits),
        limit_entry({{0.5, 0.9}}, false),
    })
    assert(limits.owned == 4)
end)

test("units from spawners keeping more never raise a spawner's limits, and own units leave them alone", function()
    -- A small biter in a Gleba spawner's small strafer slot
    local limits = military.limits_with_foreign_units(gleba_limits, {
        limit_entry({{0.0, 0.4}, {0.1, 0.4}, {0.6, 0}}, true),
        limit_entry({{0.0, 0.4}, {0.1, 0.4}, {0.6, 0.04}}, false, nauvis_limits),
        limit_entry({{0.0, 0.2}, {0.1, 0.2}, {0.6, 0}}, false),
    })
    assert(limits_equal(limits, 2, 1, 3, 2))
    assert(limits_equal(military.limits_with_foreign_units(nauvis_limits, {
        limit_entry({{0.0, 0.3}, {0.6, 0.0}}, false),
    }), 7, 7, 5, 5))
end)

test("limits written back read the same", function()
    local spawner = {
        max_count_of_owned_units = 7,
        max_friends_around_to_spawn = 5,
    }
    military.set_spawner_limits(spawner, military.limits_with_foreign_units(nauvis_limits, {
        limit_entry({{0.0, 0.3}}, false, gleba_limits),
    }))
    assert(spawner.max_count_of_owned_units == 2 and spawner.max_count_of_owned_defensive_units == 2)
    assert(limits_equal(military.spawner_limits(spawner), 2, 2, 3, 3))
end)

test("a unit peaks at the earliest evolution where it makes up most of its spawner", function()
    -- A small stomper is a fifth of a Gleba spawner's spawns until medium pentapods start at 0.1
    local evolution, share = military.peak_of(gleba_spawner, index_of(gleba_spawner, "test-small-stomper-pentapod"))
    assert(evolution == 0 and near(share, 0.2))
    -- Big stompers are a fifth from 0.95 on, once medium pentapods have stopped
    evolution, share = military.peak_of(gleba_spawner, index_of(gleba_spawner, "test-big-stomper-pentapod"))
    assert(near(evolution, 0.95) and near(share, 0.2))
    -- Behemoth biters peak at evolution 1, at 3/8 of a biter spawner's spawns
    evolution, share = military.peak_of(biter_spawner, index_of(biter_spawner, "test-behemoth-biter"))
    assert(evolution == 1 and near(share, 0.375))
end)

test("a unit that never spawns has no peak", function()
    local entries = entries_of({
        {"some-unit", {{0.0, 0.0}}},
        {"other-unit", {{0.0, 0.5}}},
    })
    local evolution, share = military.peak_of(entries, 1)
    assert(evolution == nil and share == 0)
end)

test("planets' enemy strength is spawn-weighted health, then spawners alike", function()
    assert(near(military.mean_at(nauvis, health_of, 0), 15))
    assert(near(military.mean_at(gleba, health_of, 0), 580))
    assert(near(military.mean_at(nauvis, health_of, 1), 995.3125))
    assert(near(military.mean_at(gleba, health_of, 1), 2260))
    -- Units without a value are left out, and nothing to average is nil
    assert(near(military.mean_at(nauvis, function(unit)
        return unit == "test-small-biter" and 4 or nil
    end, 0), 4))
    assert(military.mean_at(nauvis, function()
        return nil
    end, 0) == nil)
end)

test("pentapods on the starting planet shrink to its strength where they spawn now", function()
    -- A small stomper in a spitter spawner's small biter slot: Nauvis enemies have 15 health at evolution 0, Gleba's 580
    local factor = military.strength_factor(580, {
        {
            strength = 15,
            on_start = true,
        },
    }, false, true)
    assert(near(factor, 15 / 580) and near(3500 * factor, 90.5, 0.1))
    -- On both planets it still shrinks, as the slot on the starting planet asks
    assert(near(military.strength_factor(580, {
        {
            strength = 15,
            on_start = true,
        },
        {
            strength = 2000,
            on_start = false,
        },
    }, false, true), 15 / 580))
end)

test("scaling down never makes a unit stronger", function()
    -- A small wriggler in a behemoth biter slot meets stronger enemies on Nauvis than at home, and stays as it was
    assert(military.strength_factor(580, {
        {
            strength = 995,
            on_start = true,
        },
    }, false, true) == 1)
end)

test("the starting planet's enemies grow only once they're only elsewhere", function()
    -- A small biter only in Gleba spawners' early slots
    assert(near(military.strength_factor(15, {
        {
            strength = 580,
            on_start = false,
        },
    }, true, false), 580 / 15))
    -- Two slots: the one asking for less wins
    assert(near(military.strength_factor(15, {
        {
            strength = 580,
            on_start = false,
        },
        {
            strength = 150,
            on_start = false,
        },
    }, true, false), 10))
    -- Still spawned on the starting planet too: no change
    assert(military.strength_factor(15, {
        {
            strength = 580,
            on_start = false,
        },
    }, true, true) == 1)
    -- A behemoth biter in a Gleba spawner's early slot meets weaker enemies than at home, and stays as it was
    assert(military.strength_factor(995, {
        {
            strength = 580,
            on_start = false,
        },
    }, true, false) == 1)
end)

test("enemies moving between other planets, or with no known home strength, stay as they are", function()
    assert(military.strength_factor(580, {
        {
            strength = 2000,
            on_start = false,
        },
    }, false, false) == 1)
    assert(military.strength_factor(nil, {
        {
            strength = 15,
            on_start = true,
        },
    }, false, true) == 1)
end)

-- Attacks as the 2.1 data builds them (base/prototypes/entity/enemies.lua and enemy-projectiles.lua, space-age/prototypes/entity/enemies.lua and gleba-enemy-animations.lua), cut down to what does damage
local function damage_effect(amount)
    return {
        type = "damage",
        damage = {
            amount = amount,
        },
    }
end
local function instant(effects)
    return {
        type = "instant",
        target_effects = effects,
    }
end
local function area(radius, effects)
    return {
        type = "area",
        radius = radius,
        action_delivery = instant(effects),
    }
end
local delivered = {
    ["test-stream-delivery"] = {
        ["test-stream"] = {
            special_neutral_target_damage = {
                amount = 1,
            },
            initial_action = {
                {
                    type = "direct",
                    action_delivery = instant({
                        {
                            type = "create-fire",
                            entity_name = "test-fire",
                        },
                    }),
                },
                area(0.5, {
                    {
                        type = "create-sticker",
                        sticker = "test-sticker",
                    },
                    damage_effect(1),
                }),
            },
        },
    },
    ["test-projectile-delivery"] = {
        ["test-projectile"] = {
            action = {
                type = "direct",
                action_delivery = instant({
                    {
                        type = "nested-result",
                        action = area(1, {
                            damage_effect(67.5),
                        }),
                    },
                }),
            },
        },
    },
}
local function delivered_prototype(prototype_type, name)
    return (delivered[prototype_type] or {})[name]
end
local function attack(cooldown, damage_modifier, delivery)
    return {
        cooldown = cooldown,
        damage_modifier = damage_modifier,
        ammo_type = {
            action = {
                type = "direct",
                action_delivery = delivery,
            },
        },
    }
end

test("a biter's damage per second is its bite every cooldown", function()
    local small_biter = {
        attack_parameters = attack(35, nil, instant({
            damage_effect(7),
        })),
    }
    assert(near(military.damage_per_second(small_biter, delivered_prototype), 12))
end)

test("streams and projectiles do their damage times the attack's damage_modifier, and fire and stickers aren't counted", function()
    local small_spitter = {
        attack_parameters = attack(100, 12, {
            type = "test-stream-delivery",
            ["test-stream-delivery"] = "test-stream",
        }),
    }
    assert(near(military.damage_per_second(small_spitter, delivered_prototype), 7.2))
    local small_strafer = {
        attack_parameters = attack(120, nil, {
            type = "test-projectile-delivery",
            ["test-projectile-delivery"] = "test-projectile",
        }),
    }
    assert(near(military.damage_per_second(small_strafer, delivered_prototype), 33.75))
end)

test("a stomper adds one leg's stomp per attack, which its damage_modifier doesn't reach", function()
    local legs = {}
    for _ = 1, 5 do
        table.insert(legs, {
            leg_hit_the_ground_when_attacking_trigger = {
                {
                    type = "nested-result",
                    action = area(4.05, {
                        damage_effect(43.75),
                    }),
                },
            },
        })
    end
    local small_stomper = {
        spider_engine = {
            legs = legs,
        },
        attack_parameters = attack(60, 0.5, {
            type = "test-stream-delivery",
            ["test-stream-delivery"] = "test-stream",
        }),
    }
    assert(near(military.damage_per_second(small_stomper, delivered_prototype), 0.5 + 43.75))
end)

test("heals aren't damage, and a unit without an attack cooldown has no damage per second", function()
    -- A premature wriggler's bite heals itself (source effects) and hurts its target twice
    local bite = instant({
        damage_effect(3.75),
        damage_effect(3.75),
    })
    bite.source_effects = {
        damage_effect(-1.2),
    }
    assert(near(military.damage_per_second({
        attack_parameters = attack(26, nil, bite),
    }, delivered_prototype), 7.5 * 60 / 26))
    assert(military.damage_per_second({
        attack_parameters = attack(nil, nil, bite),
    }, delivered_prototype) == nil)
    assert(military.damage_per_second({}, delivered_prototype) == nil)
end)

test("health and damage scale apart", function()
    -- Early on, Gleba's enemies have 39 times Nauvis's health but under twice its damage per second (spawn-weighted, 580 vs 15 health and 23.3 vs 12)
    local slots = function(strength)
        return {
            {
                strength = strength,
                on_start = true,
            },
        }
    end
    assert(near(military.strength_factor(580, slots(15), false, true), 15 / 580))
    assert(near(military.strength_factor(23.3, slots(12), false, true), 12 / 23.3))
end)

test("a unit's cost to join attacks follows the new planet's usual costs", function()
    -- A small stomper costs 25 spores where a Gleba spawner's attackers usually cost 65/3 at evolution 0 (strafers 20, stompers 25), and small biters cost 4 pollution
    local cost = military.matched_cost(25, 65 / 3, 4)
    assert(near(cost, 25 * 4 * 3 / 65) and military.round_cost(cost) == 4.6)
    assert(military.matched_cost(25, nil, 4) == nil and military.matched_cost(nil, 20, 4) == nil)
end)

test("rounding keeps health and costs above zero", function()
    assert(military.round_health(2.4) == 2 and military.round_health(0.2) == 1)
    assert(military.round_cost(0.01) == 0.1 and military.round_cost(4.64) == 4.6)
end)

print(num_passed .. " tests passed")
