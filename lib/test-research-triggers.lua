-- Plain-Lua regression tests for lib/research-triggers.lua (not loaded by the mod)
-- Run from the mod root: lua lib/test-research-triggers.lua
-- New research triggers ask for about what the old one cost (user, 2026-10-07), and only for things a player can hold, find or place

-- Stand-in for Factorio's table.deepcopy
function table.deepcopy(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end

local research_triggers = require("lib/research-triggers")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

-- Raw material prices, as material ids
local prices = {
    ["item-plate"] = 1,
    ["item-gear"] = 2,
    ["item-circuit"] = 4.5,
    ["item-machine"] = 150,
    ["item-cheap-machine"] = 30,
    ["fluid-oil"] = 0.1,
}

test("a craft trigger asks for about as much as the old craft trigger cost", function()
    local old = {
        type = "craft-item",
        item = "plate",
        count = 50,
    }
    local new = research_triggers.make({
        kind = "craft-item",
        target = "gear",
    }, old, prices, {})
    assert(new.type == "craft-item" and new.item == "gear" and new.count == 25, research_triggers.describe(new))
    -- 50 plates cost 50; at 4.5 each that's 11.1 circuits, so 11
    new = research_triggers.make({
        kind = "craft-item",
        target = "circuit",
    }, old, prices, {})
    assert(new.count == 11, research_triggers.describe(new))
end)

test("counts keep two significant digits and are at least one", function()
    assert(research_triggers.round_amount(0.2) == 1)
    assert(research_triggers.round_amount(1.4) == 1)
    assert(research_triggers.round_amount(1.6) == 2)
    assert(research_triggers.round_amount(37.4) == 37)
    assert(research_triggers.round_amount(99.6) == 100)
    assert(research_triggers.round_amount(113) == 110)
    assert(research_triggers.round_amount(1234) == 1200)
    assert(research_triggers.round_amount(0 / 0) == 1)
    -- An expensive item for a cheap trigger is one of it
    local new = research_triggers.make({
        kind = "craft-item",
        target = "machine",
    }, {
        type = "craft-item",
        item = "plate",
        count = 10,
    }, prices, {})
    assert(new.count == 1, research_triggers.describe(new))
end)

test("a build trigger costs its cheapest placing item, a fluid trigger its amount", function()
    local placers = {
        ["machine-entity"] = {
            "cheap-machine",
            "machine",
        },
    }
    assert(research_triggers.cost({
        type = "build-entity",
        entity = "machine-entity",
    }, prices, placers) == 30)
    -- 300 oil would cost what the cheapest machine does, but a build trigger counts one, so at most 10
    local new = research_triggers.make({
        kind = "craft-fluid",
        target = "oil",
    }, {
        type = "build-entity",
        entity = "machine-entity",
    }, prices, placers)
    assert(new.type == "craft-fluid" and new.fluid == "oil" and new.amount == 10, research_triggers.describe(new))
    -- And the other way: 300 oil cost 30, a gear 2
    new = research_triggers.make({
        kind = "craft-item",
        target = "gear",
    }, {
        type = "craft-fluid",
        fluid = "oil",
        amount = 300,
    }, prices, placers)
    assert(new.count == 15, research_triggers.describe(new))
end)

test("a craft trigger asks for at most ten times the old count, however cheap its material", function()
    local cheap_prices = {
        ["item-plate"] = 1,
        ["fluid-water"] = 0.0005,
    }
    -- 50 plates cost what 100,000 water does
    local new = research_triggers.make({
        kind = "craft-fluid",
        target = "water",
    }, {
        type = "craft-item",
        item = "plate",
        count = 50,
    }, cheap_prices, {})
    assert(new.amount == 500, research_triggers.describe(new))
    -- Below the cap, the cost decides
    assert(research_triggers.matched_amount(50, 0.25, 50) == 200)
    assert(research_triggers.matched_amount(50, 0.01, 50) == 500)
    -- A trigger that counts nothing but costs something (building a machine, say) caps at 10, however expensive
    assert(research_triggers.matched_amount(1000, 1, nil) == 10)
end)

test("a trigger without a material cost makes a craft trigger ask for one, and unknown prices keep the old count", function()
    local new = research_triggers.make({
        kind = "craft-item",
        target = "gear",
    }, {
        type = "mine-entity",
        entities = {
            "rock",
        },
    }, prices, {})
    assert(new.count == 1, research_triggers.describe(new))
    new = research_triggers.make({
        kind = "craft-item",
        target = "gear",
    }, {
        type = "craft-item",
        item = "unpriced",
        count = 40,
    }, prices, {})
    assert(new.count == 40, research_triggers.describe(new))
    -- Item filters can be tables (ItemIDFilter)
    assert(research_triggers.cost({
        type = "craft-item",
        item = {
            name = "gear",
        },
        count = 3,
    }, prices, {}) == 6)
end)

test("other kinds make their own trigger, naming what they ask for", function()
    local mine = research_triggers.make({
        kind = "mine-entity",
        target = "rock",
    }, nil, prices, {})
    assert(mine.type == "mine-entity" and #mine.entities == 1 and mine.entities[1] == "rock")
    local build = research_triggers.make({
        kind = "build-entity",
        target = "machine-entity",
    }, nil, prices, {})
    assert(build.type == "build-entity" and build.entity == "machine-entity")
    local any_spawner = research_triggers.make({
        kind = "capture-spawner",
    }, nil, prices, {})
    assert(any_spawner.type == "capture-spawner" and any_spawner.entity == nil)
    local platform = research_triggers.make({
        kind = "create-space-platform",
    }, nil, prices, {})
    assert(platform.type == "create-space-platform")
end)

test("an option matching the old trigger counts as keeping it", function()
    local mine = {
        type = "mine-entity",
        entities = {
            "rock",
            "tree",
        },
    }
    assert(research_triggers.matches({
        kind = "mine-entity",
        target = "tree",
    }, mine))
    assert(not research_triggers.matches({
        kind = "mine-entity",
        target = "ore",
    }, mine))
    assert(not research_triggers.matches({
        kind = "craft-item",
        target = "tree",
    }, mine))
    assert(research_triggers.matches({
        kind = "craft-item",
        target = "gear",
    }, {
        type = "craft-item",
        item = {
            name = "gear",
        },
    }))
    assert(research_triggers.matches({
        kind = "capture-spawner",
    }, {
        type = "capture-spawner",
    }))
    assert(not research_triggers.matches({
        kind = "capture-spawner",
        target = "nest",
    }, {
        type = "capture-spawner",
    }))
    assert(not research_triggers.matches({
        kind = "craft-item",
        target = "gear",
    }, nil))
end)

test("kinds come up about as often as the game's own triggers use them, and unused kinds still can", function()
    local old_triggers = {
        a = {
            type = "craft-item",
        },
        b = {
            type = "craft-item",
        },
        c = {
            type = "mine-entity",
        },
        d = {
            type = "send-item-to-orbit",
        },
    }
    local weights = research_triggers.kind_weights(old_triggers, {
        ["craft-item"] = true,
        ["mine-entity"] = true,
        ["craft-fluid"] = true,
    })
    assert(weights["craft-item"] == 3 and weights["mine-entity"] == 2 and weights["craft-fluid"] == 1)
    -- Kinds without options left are skipped, and the pick is deterministic in the value
    local function all(kind)
        return true
    end
    local function no_craft(kind)
        return kind ~= "craft-item"
    end
    -- Sorted: craft-fluid (1), craft-item (3), mine-entity (2) out of 6
    assert(research_triggers.pick_kind(weights, all, 0) == "craft-fluid")
    assert(research_triggers.pick_kind(weights, all, 0.2) == "craft-item")
    assert(research_triggers.pick_kind(weights, all, 0.7) == "mine-entity")
    assert(research_triggers.pick_kind(weights, no_craft, 0.5) == "mine-entity")
    assert(research_triggers.pick_kind(weights, function()
        return false
    end, 0.5) == nil)
end)

test("only things a player holds, finds or places qualify", function()
    assert(research_triggers.item_ok({
        name = "gear",
    }))
    assert(not research_triggers.item_ok({
        name = "plan",
        flags = {
            "only-in-cursor",
        },
    }))
    assert(not research_triggers.item_ok({
        name = "secret",
        hidden = true,
    }))
    -- Map generation places it, and it can be mined
    assert(research_triggers.mine_ok({
        name = "rock",
        minable = {},
        autoplace = {},
    }))
    assert(not research_triggers.mine_ok({
        name = "machine-entity",
        minable = {},
    }))
    local items = {
        machine = {
            name = "machine",
            place_result = "machine-entity",
        },
        rail = {
            name = "rail",
        },
        seed = {
            name = "seed",
            plant_result = "plant",
        },
    }
    local entities = {
        ["machine-entity"] = {
            name = "machine-entity",
        },
        ["rail-piece"] = {
            name = "rail-piece",
            placeable_by = {
                item = "rail",
                count = 1,
            },
        },
        plant = {
            name = "plant",
        },
    }
    local placers = research_triggers.placers(items, entities)
    assert(placers["machine-entity"][1] == "machine")
    assert(placers["rail-piece"][1] == "rail")
    -- Planting isn't building with place_result, so a plant is only ever mined
    assert(placers.plant == nil)
    assert(research_triggers.build_ok(entities["machine-entity"], placers["machine-entity"]))
    assert(not research_triggers.build_ok(entities.plant, placers.plant))
end)

test("things doable just before the old trigger count most, later ones less, and far ones hardly", function()
    local indices = {
        old = 10,
        recent = 90,
        newest = 99,
        same_time = 100,
        soon_after = 101,
        later = 150,
    }
    local weights = research_triggers.nearness_weights(indices, 100)
    assert(weights.newest == 1)
    assert(math.abs(weights.recent - 0.85) < 1e-9)
    assert(math.abs(weights.old - 0.85 ^ 2) < 1e-9)
    -- At or after the anchor: half as much, falling off the same way (ties go by name)
    assert(math.abs(weights.same_time - 0.5) < 1e-9)
    assert(math.abs(weights.soon_after - 0.5 * 0.85) < 1e-9)
    assert(math.abs(weights.later - 0.5 * 0.85 ^ 2) < 1e-9)
    -- Picking is deterministic in the value, in sorted order, skipping weightless candidates
    local picks = {
        a = 1,
        b = 0,
        c = 3,
    }
    assert(research_triggers.pick_weighted(picks, 0) == "a")
    assert(research_triggers.pick_weighted(picks, 0.3) == "c")
    assert(research_triggers.pick_weighted({
        a = 0,
    }, 0.5) == nil)
end)

test("a trigger technology unlocking several recipes splits into one technology per recipe", function()
    local technologies = {
        smelting = {
            type = "technology",
            name = "smelting",
            research_trigger = {
                type = "mine-entity",
                entities = {
                    "rock",
                },
            },
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = "plate",
                },
                {
                    type = "character-mining-speed",
                    modifier = 1,
                },
                {
                    type = "unlock-recipe",
                    recipe = "gear",
                },
                {
                    type = "unlock-recipe",
                    recipe = "rod",
                },
            },
        },
        -- One recipe, nothing to split
        single = {
            type = "technology",
            name = "single",
            research_trigger = {
                type = "craft-item",
                item = "plate",
            },
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = "pipe",
                },
            },
        },
        -- Science-pack technologies are left alone
        science = {
            type = "technology",
            name = "science",
            unit = {
                count = 10,
            },
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = "belt",
                },
                {
                    type = "unlock-recipe",
                    recipe = "splitter",
                },
            },
        },
    }
    -- A recipe whose per-recipe technology exists already stays with its technology
    technologies[research_triggers.split_name("rod")] = {
        type = "technology",
        name = research_triggers.split_name("rod"),
        unit = {
            count = 1,
        },
    }
    local created = research_triggers.split_technologies(technologies)
    assert(#created == 1 and created[1] == research_triggers.split_name("gear"), table.concat(created, ", "))
    local gear_tech = technologies[research_triggers.split_name("gear")]
    assert(gear_tech.research_trigger.entities[1] == "rock" and gear_tech.research_trigger ~= technologies.smelting.research_trigger)
    assert(#gear_tech.effects == 1 and gear_tech.effects[1].recipe == "gear")
    assert(gear_tech.localised_name[1] == "technology-name.smelting")
    -- The original keeps its first recipe, its other effects and the recipe that already had a technology, in order
    local kept = {}
    for _, effect in pairs(technologies.smelting.effects) do
        table.insert(kept, effect.recipe or effect.type)
    end
    assert(table.concat(kept, ",") == "plate,character-mining-speed,rod", table.concat(kept, ","))
    assert(#technologies.single.effects == 1 and #technologies.science.effects == 2)
end)

print(num_passed .. " tests passed")
