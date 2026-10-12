-- Run from the mod root: lua tests/unit/runtime/test-landing-lightning.lua
local landing_lightning = require("src/runtime/landing-lightning")
local natural_lightning = require("src/prototypes/entities/natural-lightning-attractors")

local raw = {
    planet = {
        storm = {lightning_properties = {}},
        dry = {},
    },
    item = {
        rod = {place_result = "basic-attractor"},
        collector = {place_result = "advanced-attractor"},
        hidden = {
            place_result = "hidden-attractor",
            hidden = true,
        },
    },
    ["lightning-attractor"] = {
        ["basic-attractor"] = {
            range_elongation = 15,
            efficiency = 0.2,
        },
        ["advanced-attractor"] = {
            range_elongation = 25,
            efficiency = 0.4,
        },
        ["natural-attractor"] = {
            range_elongation = 20,
            autoplace = {},
            flags = {
                "placeable-neutral",
                "player-creation",
                "not-upgradable",
            },
        },
        ["hidden-attractor"] = {range_elongation = 10},
        ["no-range"] = {},
    },
}
local catalog = landing_lightning.catalog(raw, {item = true})
assert(catalog.lightning_planets.storm and not catalog.lightning_planets.dry)
assert(#catalog.candidates == 2 and catalog.candidates[1].name == "basic-attractor")
assert(catalog.ranges["natural-attractor"] == 20 and catalog.ranges["no-range"] == nil)
assert(next(landing_lightning.catalog({}, {}).lightning_planets) == nil)

local created, nearby, blocked, fail_creation, searches
local surface = {
    index = 7,
    planet = {name = "storm"},
    find_entities_filtered = function(filter)
        assert(filter.position.x == 100 and filter.position.y == 200)
        return nearby
    end,
    find_non_colliding_position = function(name, center, radius, precision, tile_center)
        searches = searches + 1
        assert(radius > 0 and radius <= 8 and tile_center)
        if not blocked then
            return {
                x = center.x + 3.5,
                y = center.y + 0.5,
            }
        end
    end,
    create_entity = function(options)
        assert(options.force == game.players[1].force)
        if not fail_creation then
            table.insert(created, options)
            return {valid = true}
        end
    end,
}
local event = {
    player_index = 1,
    cargo_pod = {
        valid = true,
        surface = surface,
        position = {
            x = 100,
            y = 200,
        },
    },
}
prototypes = {mod_data = {["propertyrandomizer-landing-lightning"] = {data = catalog}}}
game = {players = {{force = {index = 1}}}}

local passed = 0
local function test(name, fn)
    storage = {}
    created, nearby, blocked, fail_creation, searches = {}, {}, false, false, 0
    surface.planet = {name = "storm"}
    event.player_index = 1
    event.cargo_pod.valid = true
    fn()
    passed = passed + 1
    print("ok - " .. name)
end

test("first landing gets a basic attractor at the pod's actual position, once", function()
    landing_lightning.on_landing(event)
    assert(#created == 1 and created[1].name == "basic-attractor")
    assert(created[1].position.x == 103.5 and storage.landing_lightning[7])
    landing_lightning.on_landing(event)
    assert(#created == 1 and searches == 1)
end)

test("natural attractors already near the landing prevent a duplicate", function()
    nearby = {
        {
            name = "natural-attractor",
            position = {
                x = 101,
                y = 200,
            },
        },
    }
    landing_lightning.on_landing(event)
    assert(#created == 0 and searches == 0 and storage.landing_lightning[7])
end)

test("an attractor out of range doesn't suppress the fallback", function()
    nearby = {
        {
            name = "basic-attractor",
            position = {
                x = 120,
                y = 200,
            },
        },
    }
    landing_lightning.on_landing(event)
    assert(#created == 1)
end)

test("blocked terrain and failed creation can retry on the next landing", function()
    blocked = true
    landing_lightning.on_landing(event)
    assert(not storage.landing_lightning[7] and #created == 0)
    blocked, fail_creation = false, true
    landing_lightning.on_landing(event)
    assert(not storage.landing_lightning[7] and #created == 0)
    fail_creation = false
    landing_lightning.on_landing(event)
    assert(storage.landing_lightning[7] and #created == 1)
end)

test("cargo deliveries and invalid pods don't trigger placement", function()
    event.player_index = nil
    landing_lightning.on_landing(event)
    event.player_index, event.cargo_pod.valid = 1, false
    landing_lightning.on_landing(event)
    assert(#created == 0 and searches == 0 and storage.landing_lightning == nil)
end)

test("dry planets and space surfaces don't trigger placement", function()
    surface.planet = {name = "dry"}
    landing_lightning.on_landing(event)
    surface.planet = nil
    landing_lightning.on_landing(event)
    assert(#created == 0 and searches == 0 and storage.landing_lightning == nil)
end)

print(passed .. " landing tests passed")

-- Use the same fixture to verify that preparation preserves placement and range.
raw["lightning-attractor"]["basic-attractor"].autoplace = {}
raw["lightning-attractor"]["basic-attractor"].flags = {"player-creation"}
raw["lightning-attractor"]["hidden-attractor"].autoplace = {}
raw["lightning-attractor"]["hidden-attractor"].flags = {"player-creation"}
natural_lightning.prepare(raw, {item = true})
local natural = raw["lightning-attractor"]["natural-attractor"]
assert(#natural.flags == 3 and natural.flags[2] == "player-creation")
assert(natural.autoplace.force == "neutral")
assert(natural.alert_when_damaged == false and natural.range_elongation == 20 and natural.autoplace ~= nil)
assert(raw["lightning-attractor"]["basic-attractor"].flags[1] == "player-creation")
assert(raw["lightning-attractor"]["hidden-attractor"].flags[1] == "player-creation")
assert(raw["lightning-attractor"]["basic-attractor"].alert_when_damaged == nil)
assert(raw["lightning-attractor"]["hidden-attractor"].alert_when_damaged == nil)
assert(raw["lightning-attractor"]["no-range"].alert_when_damaged == nil)
natural_lightning.prepare(raw, {item = true})
assert(#natural.flags == 3)
natural_lightning.prepare({}, {})
print("ok - natural attractors get neutral ownership and no damage alerts; buildable attractors keep their behavior")

local old_ruin = {force = game.players[1].force}
local neutral_force = {}
game.forces = {neutral = neutral_force}
local scans = 0
game.surfaces = {
    {
        find_entities_filtered = function(filter)
            assert(#filter.name == 1 and filter.name[1] == "natural-attractor")
            scans = scans + 1
            return {old_ruin}
        end,
    },
}
prototypes.mod_data["propertyrandomizer-natural-lightning-attractors"] = {data = {names = natural_lightning.names(raw, {item = true})}}
natural_lightning.migrate()
assert(old_ruin.force == neutral_force and storage.natural_lightning_migrated and scans == 1)
natural_lightning.migrate()
assert(old_ruin.force == neutral_force and scans == 1)
old_ruin.force = game.players[1].force
natural_lightning.migrate()
assert(old_ruin.force == game.players[1].force and scans == 1)
prototypes.mod_data["propertyrandomizer-natural-lightning-attractors"].data.names = {}
storage.natural_lightning_migrated = nil
natural_lightning.migrate()
assert(scans == 1)
print("ok - migration converts old ruins once, preserves claims, and skips empty scans")
