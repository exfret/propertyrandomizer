-- Plain-Lua tests for the combat check's weapons and kill times.
-- Run from the mod root: lua tests/unit/logic/builders/test-combat-counters.lua

local counters = require("src/logic/builders/combat-counters")
local gutils = require("src/lib/graph/graph-utils")

local key = gutils.key
local count = 0

local function test(name, check)
    local okay, reason = pcall(check)
    assert(okay, name .. ": " .. tostring(reason))
    count = count + 1
end

local function close(actual, expected)
    assert(type(actual) == "number" and math.abs(actual - expected) < 1e-9, tostring(actual) .. " ~= " .. expected)
end

local energy_units = {
    k = 1e3,
    M = 1e6,
}
local function parse_energy(value)
    local number, prefix, unit = string.match(value, "^([%d%.]+)([kM]?)([JW])$")
    return tonumber(number) * (energy_units[prefix] or 1) / (unit == "W" and 60 or 1)
end

local function instant(amount)
    return {
        action = {
            type = "direct",
            action_delivery = {
                type = "instant",
                target_effects = {
                    type = "damage",
                    damage = {
                        type = "test-damage",
                        amount = amount,
                    },
                },
            },
        },
    }
end

local function attack(kind, cooldown, extra)
    local result = {
        type = kind or "projectile",
        cooldown = cooldown or 60,
        range = 20,
    }
    for name, value in pairs(extra or {}) do
        result[name] = value
    end
    return result
end

local function weapons_by_name(lu, options)
    options = options or {}
    options.parse_energy = parse_energy
    local weapons, diagnostics = counters.weapons(lu, options)
    local result = {}
    for _, weapon in pairs(weapons) do
        result[weapon.name] = weapon
    end
    return result, diagnostics, weapons
end

local function has(list, value)
    for _, entry in pairs(list) do
        if entry == value then
            return true
        end
    end
    return false
end

test("guns, ammo turrets and vehicles get a weapon per ammo they fire", function()
    local lu = {
        items = {
            ["test-gun"] = {
                type = "gun",
                attack_parameters = attack("projectile", 60, { ammo_category = "test-ammo" }),
            },
            ["test-magazine"] = {
                type = "ammo",
                name = "test-magazine",
                ammo_category = "test-ammo",
                ammo_type = instant(10),
            },
            ["test-other"] = {
                type = "ammo",
                name = "test-other",
                ammo_category = "test-other",
                ammo_type = instant(10),
            },
        },
        entities = {
            ["test-turret"] = {
                type = "ammo-turret",
                attack_parameters = attack("projectile", 6, { ammo_category = "test-ammo" }),
            },
            ["test-car"] = {
                type = "car",
                guns = { "test-gun" },
            },
        },
    }
    local weapons = weapons_by_name(lu)
    local hand = weapons[gutils.concat({ key("item-gun", "test-gun"), "test-magazine" })]
    local turret = weapons[gutils.concat({ key("entity-operate", "test-turret"), "test-magazine" })]
    local car = weapons[gutils.concat({ key("entity-operate", "test-car"), "test-gun", "test-magazine" })]
    assert(hand and hand.mode == "manual" and has(hand.prerequisites, key("item-gun", "test-gun")) and has(hand.prerequisites, key("item", "test-magazine")))
    assert(turret and turret.mode == "turret" and has(turret.prerequisites, key("entity-operate", "test-turret")) and has(turret.prerequisites, key("item", "test-magazine")))
    assert(car and car.mode == "manual" and has(car.prerequisites, key("planet", "")))
    for name, _ in pairs(weapons) do
        assert(not string.find(name, "test-other", 1, true))
    end
end)

test("an electric turret fires its own beam, slowed down to how fast its buffer recharges", function()
    -- Shaped like the laser turret (base/prototypes/entity/turrets.lua, base/prototypes/entity/beams.lua)
    local beam = {
        type = "beam",
        damage_interval = 20,
        action = instant(10).action,
    }
    local turret = {
        type = "electric-turret",
        energy_source = {
            type = "electric",
            buffer_capacity = "801kJ",
            input_flow_limit = "9600kW",
            drain = "24kW",
        },
        attack_parameters = attack("beam", 40, {
            damage_modifier = 2,
            ammo_type = {
                energy_consumption = "800kJ",
                action = {
                    type = "direct",
                    action_delivery = {
                        type = "beam",
                        beam = "test-beam",
                        duration = 40,
                        max_length = 24,
                    },
                },
            },
        }),
    }
    local lu = {
        items = {},
        entities = { ["test-laser"] = turret },
    }
    local options = { entity_of = function(name) return name == "test-beam" and beam or nil end }
    local weapons = weapons_by_name(lu, options)
    local laser = weapons[gutils.concat({ key("entity-operate", "test-laser"), "builtin" })]
    assert(laser and #laser.prerequisites == 1)
    close(laser.profile.packets[1].amount, 20)
    close(laser.profile.interval_seconds, 40 / 60)
    -- A slower supply can't recharge 800 kJ in 40 ticks
    turret.energy_source.input_flow_limit = "600kW"
    weapons = weapons_by_name(lu, options)
    laser = weapons[gutils.concat({ key("entity-operate", "test-laser"), "builtin" })]
    close(laser.profile.interval_seconds, math.ceil(800 / (10 - 0.4)) / 60)
    turret.energy_source.buffer_capacity = "100kJ"
    local diagnostics
    weapons, diagnostics = weapons_by_name(lu, options)
    assert(diagnostics.rejected[gutils.concat({ key("entity-operate", "test-laser"), "builtin" })] == "shot-exceeds-buffer")
end)

test("a fluid turret gets a weapon per fluid, needing that fluid and scaled by its damage modifier", function()
    -- Shaped like the flamethrower turret (base/prototypes/entity/turrets.lua)
    local stream = {
        type = "stream",
        particle_spawn_interval = 2,
        particle_horizontal_speed = 0.25,
        particle_horizontal_speed_deviation = 0.025,
        action = {
            type = "area",
            radius = 2.5,
            action_delivery = instant(3).action.action_delivery,
        },
    }
    local lu = {
        items = {},
        entities = {
            ["test-flamer"] = {
                type = "fluid-turret",
                attack_parameters = attack("stream", 4, {
                    fluids = {
                        { type = "test-oil" },
                        {
                            type = "test-light-oil",
                            damage_modifier = 1.1,
                        },
                    },
                    ammo_type = {
                        action = {
                            type = "direct",
                            action_delivery = {
                                type = "stream",
                                stream = "test-stream",
                            },
                        },
                    },
                }),
            },
        },
    }
    local weapons = weapons_by_name(lu, { entity_of = function(name) return name == "test-stream" and stream or nil end })
    local crude = weapons[gutils.concat({ key("entity-operate", "test-flamer"), "test-oil" })]
    local light = weapons[gutils.concat({ key("entity-operate", "test-flamer"), "test-light-oil" })]
    assert(crude and light and has(light.prerequisites, key("fluid", "test-light-oil")))
    close(crude.profile.packets[1].amount, 3)
    close(light.profile.packets[1].amount, 3.3)
end)

test("turrets with target masks and attacks the scorer can't model are left out with a reason", function()
    local lu = {
        items = {
            ["test-magazine"] = {
                type = "ammo",
                name = "test-magazine",
                ammo_category = "test-ammo",
                ammo_type = instant(10),
            },
        },
        entities = {
            ["test-masked"] = {
                type = "ammo-turret",
                attack_target_mask = { "test-mask" },
                attack_parameters = attack("projectile", 6, { ammo_category = "test-ammo" }),
            },
            ["test-ignoring"] = {
                type = "ammo-turret",
                ignore_target_mask = { "test-mask" },
                attack_parameters = attack("projectile", 6, { ammo_category = "test-ammo" }),
            },
            ["test-artillery"] = {
                type = "ammo-turret",
                attack_parameters = attack("projectile", 6, {
                    ammo_category = "test-shell",
                }),
            },
        },
    }
    lu.items["test-shell"] = {
        type = "ammo",
        name = "test-shell",
        ammo_category = "test-shell",
        ammo_type = {
            action = {
                type = "direct",
                action_delivery = {
                    type = "artillery",
                    projectile = "test-artillery-projectile",
                },
            },
        },
    }
    local weapons, diagnostics = weapons_by_name(lu)
    assert(next(weapons) == nil)
    assert(diagnostics.rejected[key("entity-operate", "test-masked")] == "unsupported-source-filter")
    assert(diagnostics.rejected[key("entity-operate", "test-ignoring")] == "unsupported-source-filter")
    assert(diagnostics.rejected[gutils.concat({ key("entity-operate", "test-artillery"), "test-shell" })] == "unsupported-delivery")
end)

test("kill times deploy ten turrets or one weapon in hand, and keep why a target can't be scored", function()
    local lu = {
        items = {
            ["test-gun"] = {
                type = "gun",
                attack_parameters = attack("projectile", 60, { ammo_category = "test-ammo" }),
            },
            ["test-magazine"] = {
                type = "ammo",
                name = "test-magazine",
                ammo_category = "test-ammo",
                ammo_type = instant(10),
            },
        },
        entities = {
            ["test-turret"] = {
                type = "ammo-turret",
                attack_parameters = attack("projectile", 60, { ammo_category = "test-ammo" }),
            },
            ["test-target"] = { max_health = 100 },
            ["test-broken"] = {
                max_health = 100,
                segment_engine = {},
            },
        },
    }
    local weapons = select(3, weapons_by_name(lu))
    local times, reasons = counters.kill_times(weapons, { "test-target", "test-broken" }, lu.entities)
    local by_mode = {}
    for _, time in pairs(times["test-target"]) do
        by_mode[weapons[time.weapon].mode] = time.seconds
    end
    close(by_mode.turret, 1)
    close(by_mode.manual, 10)
    assert(times["test-broken"] == nil and reasons["test-broken"] == "invalid-segment-engine")
    times = counters.kill_times(weapons, { "test-target" }, lu.entities, {
        turret_count = 5,
        manual_count = 2,
    })
    by_mode = {}
    for _, time in pairs(times["test-target"]) do
        by_mode[weapons[time.weapon].mode] = time.seconds
    end
    close(by_mode.turret, 2)
    close(by_mode.manual, 5)
end)

print("combat counters: " .. count .. " tests passed")
