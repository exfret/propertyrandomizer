-- Run from the mod root: lua tests/unit/prototypes/duplicates/test-dupe-tech-trees.lua
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

local stubs = {
    "src/prototypes/categories",
    "src/config/constants",
    "src/lib/random/rng",
    "src/localisation/locale",
    "src/prototypes/data-utils",
    "resource-autoplace",
    "src/prototypes/duplicates/dupe-graphics-manifest",
    "src/lib/graph/graph-utils",
    "src/prototypes/lookup/init",
    "src/prototypes/surfaces/surface-sets",
    "src/prototypes/entities/wild-entities",
    "src/lib/sort/context-sort",
    "src/logic/init",
    "src/logic/logic-utils",
    "src/randomizations/planetary/locks",
    "src/randomizations/planetary/oceans",
    "src/randomizations/planetary/planet-names",
}
for _, name in pairs(stubs) do
    package.loaded[name] = {}
end
package.loaded["src/prototypes/duplicates/dupe-graphics-manifest"].files = {}
package.loaded["src/lib/random/rng"].key = function(info)
    if info.prototype ~= nil then
        return info.prototype.type .. "/" .. info.prototype.name
    end
    return info.id
end
package.loaded["src/lib/random/rng"].value = function() return 0.5 end
package.loaded["src/lib/random/rng"].int = function(_, count) return count end
package.loaded["src/localisation/locale"].find_localised_name = function(prototype) return prototype.name end
package.loaded["src/localisation/locale"].find_localised_description = function() return nil end
package.loaded["src/lib/graph/graph-utils"].key = function(kind, name) return kind .. ": " .. name end

local dupe = require("src/prototypes/duplicates/dupe")
local planets = require("src/prototypes/duplicates/dupe-planets")
local intermediates = require("src/prototypes/duplicates/dupe-intermediates")

local function reset()
    data = {
        raw = {},
    }
    data.raw.technology = {}
    data.raw.recipe = {}
    data.raw.item = {}
    data.raw.fluid = {}
    data.raw.planet = {}
    local locks = package.loaded["src/randomizations/planetary/locks"]
    locks.fixed = {}
    locks.fix = function(kind, name, rooms)
        locks.fixed[kind .. "/" .. name] = rooms
    end
    locks.realize = function() end
    package.loaded["src/prototypes/surfaces/surface-sets"].accepted = function(recipe)
        if recipe.accepted ~= nil then
            return recipe.accepted
        end
        local rooms = {}
        for name, _ in pairs(data.raw.planet) do
            rooms["planet: " .. name] = true
        end
        return rooms
    end
    function data:extend(prototypes)
        for _, prototype in pairs(prototypes) do
            self.raw[prototype.type] = self.raw[prototype.type] or {}
            assert(self.raw[prototype.type][prototype.name] == nil)
            self.raw[prototype.type][prototype.name] = prototype
        end
    end
    dupe.technology_copies = {}
    dupe.home_discoveries = {}
    dupe.has_been_duplicated = {}
    defines = {
        prototypes = {},
    }
    defines.prototypes.item = {}
    defines.prototypes.item.item = 0
    package.loaded["src/prototypes/data-utils"].get_all_prots = function(kind)
        if kind == "item" then
            return data.raw.item
        end
        return {}
    end
    package.loaded["src/prototypes/data-utils"].lab_inputs = function() return {} end
end

local function tech(name, extra)
    local prototype = extra or {}
    prototype.type = "technology"
    prototype.name = name
    prototype.icon = name .. ".png"
    data:extend({
        prototype,
    })
    return prototype
end

local count = 0
local function test(name, run)
    reset()
    run()
    count = count + 1
    print("ok - " .. name)
end

test("finite trees include early and triggered technologies without copied packs", function()
    tech("early", {
        unit = {
            ingredients = {
                {
                    "shared-pack",
                    1,
                },
            },
        },
    })
    tech("triggered", {
        research_trigger = {
            type = "craft-item",
            item = "test-component",
        },
    })
    tech("hidden-test", {
        hidden = true,
        unit = {
            ingredients = {},
        },
    })
    tech("disabled-test", {
        enabled = false,
        unit = {
            ingredients = {},
        },
    })
    tech("infinite-test", {
        unit = {
            ingredients = {},
            count_formula = "L",
        },
    })
    local discovery = tech("discovery-test", {})
    discovery.effects = {
        {
            type = "unlock-space-location",
            space_location = "test-world",
        },
    }
    local candidates = planets.tree_candidates()
    assert(#candidates == 2 and candidates[1].name == "early" and candidates[2].name == "triggered")
end)

test("parallel roots wait on discovery and pack unlocks move to their own tree", function()
    local root = tech("root", {
        unit = {
            ingredients = {
                {
                    "shared-pack",
                    1,
                },
            },
        },
    })
    local pack = tech("pack-tech", {
        prerequisites = {
            root.name,
        },
        unit = {
            ingredients = {
                {
                    "shared-pack",
                    1,
                },
            },
        },
    })
    pack.effects = {
        {
            type = "unlock-recipe",
            recipe = "original-pack",
        },
        {
            type = "unlock-recipe",
            recipe = "copied-pack-2",
        },
        {
            type = "unlock-recipe",
            recipe = "copied-pack-3",
        },
    }
    local packs = {
        copies = {
            [2] = {},
            [3] = {},
        },
        recipe_copies = {
            [2] = {
                ["original-pack"] = "copied-pack-2",
            },
            [3] = {
                ["original-pack"] = "copied-pack-3",
            },
        },
    }
    local function needs() return {} end
    local copied, moved = planets.parallel_tree({
        root,
        pack,
    }, {}, packs, {}, 2, "home-discovery-2", needs)
    assert(copied.root.prerequisites[1] == "home-discovery-2")
    assert(copied[pack.name].prerequisites[1] == copied.root.name)
    assert(#moved == 1 and #copied[pack.name].effects == 1)
    assert(copied[pack.name].effects[1].recipe == "copied-pack-2")
    assert(#pack.effects == 2 and pack.effects[2].recipe == "copied-pack-3")
    assert(root.prerequisites == nil and copied.root.unit.ingredients[1][1] == "shared-pack")
end)

test("a planet copy's technologies keep only their own branch's prerequisites, as copies", function()
    local function discovery(name, location)
        return tech(name, {
            effects = {
                {
                    type = "unlock-space-location",
                    space_location = location,
                },
            },
        })
    end
    -- Like the electric mining drill: the starting planet's own research
    local drill = tech("drill", {
        unit = {
            ingredients = {
                {
                    "shared-pack",
                    1,
                },
            },
        },
    })
    discovery("find-hot", "hot")
    discovery("find-wet", "wet")
    discovery("find-cold", "cold")
    -- Like Vulcanus's research: a trigger after its discovery, then one that also needs the drill
    local mine = tech("hot-mine", {
        prerequisites = {
            "find-hot",
        },
    })
    local big = tech("hot-big-drill", {
        prerequisites = {
            "hot-mine",
            "drill",
        },
    })
    -- Like Aquilo's: after its own discovery, needing another planet's research too
    local heat = tech("wet-heat", {
        prerequisites = {
            "find-wet",
        },
    })
    data.raw.technology["find-cold"].prerequisites = {
        "wet-heat",
    }
    local ice = tech("cold-ice", {
        prerequisites = {
            "find-cold",
            "wet-heat",
        },
    })
    local closure = {}
    local function needs(name)
        if closure[name] == nil then
            local needed = {}
            closure[name] = needed
            for _, prerequisite in pairs(data.raw.technology[name].prerequisites or {}) do
                needed[prerequisite] = true
                for further, _ in pairs(needs(prerequisite)) do
                    needed[further] = true
                end
            end
        end
        return closure[name]
    end
    local packs = {
        copies = {},
        recipe_copies = {},
    }
    local discovery_copies = {
        ["find-hot"] = "find-hot-2",
        ["find-wet"] = "find-wet-2",
        ["find-cold"] = "find-cold-2",
    }
    local copied = planets.parallel_tree({
        drill,
        mine,
        big,
        heat,
        ice,
    }, {}, packs, discovery_copies, 2, "home-discovery-2", needs)
    -- Its own branch's copies only: not the drill research's copy, which waits on the starting planet copy's discovery, nor the original
    assert(copied["hot-mine"].prerequisites[1] == "find-hot-2")
    assert(#copied["hot-big-drill"].prerequisites == 1)
    assert(copied["hot-big-drill"].prerequisites[1] == copied["hot-mine"].name)
    -- Nor another planet's research
    assert(#copied["cold-ice"].prerequisites == 1)
    assert(copied["cold-ice"].prerequisites[1] == "find-cold-2")
    -- The starting planet's copied research itself still waits on the starting planet copy's discovery
    assert(copied["drill"].prerequisites[1] == "home-discovery-2")
end)

test("unified randomization keeps each planet copy's technology behind the discoveries its tree follows", function()
    local function discovery(name, location, extra)
        local prototype = extra or {}
        prototype.effects = {
            {
                type = "unlock-space-location",
                space_location = location,
            },
        }
        return tech(name, prototype)
    end
    discovery("find-home-2", "home-2", {
        dupe_number = 2,
    })
    discovery("find-hot-2", "hot-2", {
        dupe_number = 2,
        prerequisites = {
            "find-home-2",
        },
    })
    -- Like copy 2's electric mining drill, rooted at the starting planet copy's discovery, and Vulcanus 2's research after its own discovery
    tech("drill-exfret-2-copy", {
        dupe_number = 2,
        prerequisites = {
            "find-home-2",
        },
    })
    tech("mine-exfret-2-copy", {
        dupe_number = 2,
        prerequisites = {
            "find-hot-2",
        },
    })
    -- Needing both, it follows the later discovery only
    tech("big-exfret-2-copy", {
        dupe_number = 2,
        prerequisites = {
            "mine-exfret-2-copy",
            "drill-exfret-2-copy",
        },
    })
    tech("original", {
        prerequisites = {
            "drill-exfret-2-copy",
        },
    })
    local gates = dupe.copy_gates(data.raw.technology)
    assert(#gates["drill-exfret-2-copy"] == 1 and gates["drill-exfret-2-copy"][1] == "find-home-2")
    assert(#gates["mine-exfret-2-copy"] == 1 and gates["mine-exfret-2-copy"][1] == "find-hot-2")
    assert(#gates["big-exfret-2-copy"] == 1 and gates["big-exfret-2-copy"][1] == "find-hot-2")
    -- A discovery's copy follows its own tiers, and an original isn't a copy
    assert(gates["find-hot-2"] == nil and gates["find-home-2"] == nil)
    assert(gates["original"] == nil)
end)

test("initially enabled duplicate recipes require their copy discovery", function()
    local discovery = tech("home-discovery", {})
    dupe.home_discoveries[2] = discovery
    local recipe = {
        type = "recipe",
        name = "test-enabled",
        icon = "test.png",
        results = {},
    }
    data:extend({
        recipe,
    })
    local copy = dupe.recipe(recipe, 2)
    assert(copy.enabled == false and recipe.enabled == nil)
    assert(discovery.effects[1].recipe == copy.name)
end)

test("intermediate planning follows dependencies and stops at mined and behavioral items", function()
    local items = {}
    for _, name in pairs({
        "test-gear",
        "test-plate",
        "test-ore",
        "test-fruit",
        "test-building",
    }) do
        items[name] = {
            name = name,
        }
    end
    items["test-fruit"].spoil_ticks = 60
    items["test-gear"].place_as_equipment_result = ""
    items["test-building"].place_result = "test-machine"
    local recipes = {}
    local function recipe(name, ingredients)
        recipes[name] = {
            name = name,
            ingredients = {},
            results = {
                {
                    type = "item",
                    name = name,
                },
            },
        }
        for _, ingredient in pairs(ingredients) do
            table.insert(recipes[name].ingredients, {
                type = "item",
                name = ingredient,
            })
        end
    end
    recipe("test-gear", {
        "test-plate",
    })
    recipe("test-plate", {
        "test-ore",
    })
    recipe("test-ore", {})
    recipe("test-fruit", {})
    recipe("test-building", {})
    recipes["test-final-copy"] = {
        dupe_number = 2,
        ingredients = {
            {
                type = "item",
                name = "test-gear",
            },
            {
                type = "item",
                name = "test-fruit",
            },
            {
                type = "item",
                name = "test-building",
            },
        },
    }
    local entity = {
        minable = {
            result = "test-ore",
        },
    }
    local planned = intermediates.plan(items, recipes, {
        entity,
    }, {
        [2] = {},
    }, {})[2]
    assert(planned["test-gear"] and planned["test-plate"])
    assert(planned["test-ore"] == nil and planned["test-fruit"] == nil and planned["test-building"] == nil)
end)

test("furnace products stay shared to avoid ambiguous recipe selection", function()
    local items = {
        ["test-metal"] = {
            name = "test-metal",
        },
        ["test-component"] = {
            name = "test-component",
        },
    }
    local recipes = {
        ["test-metal"] = {
            name = "test-metal",
            categories = {
                "test-smelting",
            },
            ingredients = {
                {
                    type = "item",
                    name = "test-ore",
                },
            },
            results = {
                {
                    type = "item",
                    name = "test-metal",
                },
            },
        },
        ["test-component"] = {
            name = "test-component",
            categories = {
                "test-crafting",
            },
            ingredients = {
                {
                    type = "item",
                    name = "test-metal",
                },
            },
            results = {
                {
                    type = "item",
                    name = "test-component",
                },
            },
        },
        ["test-copy"] = {
            dupe_number = 2,
            ingredients = {
                {
                    type = "item",
                    name = "test-component",
                },
            },
        },
    }
    local planned = intermediates.plan(items, recipes, {}, {
        [2] = {},
    }, {}, {
        {
            ["test-smelting"] = true,
        },
    })[2]
    assert(planned["test-component"] and planned["test-metal"] == nil)
end)

test("science splitting excludes the bootstrap route and gives copies an equal share", function()
    local bootstrap = tech("bootstrap-test", {
        unit = {
            ingredients = {
                {
                    "pack-test",
                    1,
                },
            },
        },
    })
    local branch = tech("branch-test", {
        prerequisites = {
            bootstrap.name,
        },
        unit = {
            ingredients = {
                {
                    "pack-test",
                    1,
                },
            },
        },
    })
    local packs = {
        versions = {
            ["pack-test"] = {
                "pack-test",
                "pack-copy-2",
                "pack-copy-3",
            },
        },
        copies_of = {
            ["pack-test"] = {
                "pack-copy-2",
                "pack-copy-3",
            },
        },
    }
    local flips = planets.split({
        bootstrap,
        branch,
    }, packs, {
        [bootstrap.name] = true,
    })
    assert(#flips == 1 and bootstrap.unit.ingredients[1][1] == "pack-test")
    assert(branch.unit.ingredients[1][1] == "pack-copy-3")
end)

test("local variants share products and inputs while keeping planet locks and copied unlocks", function()
    function log() end
    local home = tech("test-home", {})
    dupe.home_discoveries[2] = home
    local other_home = tech("test-other-home", {})
    home.effects = {
        {
            type = "unlock-space-location",
            space_location = "test-home-copy",
        },
    }
    other_home.effects = {
        {
            type = "unlock-space-location",
            space_location = "test-other-copy",
        },
    }
    data.raw.planet["test-home-copy"] = {
        name = "test-home-copy",
        dupe_number = 2,
        icon = "test-home-copy.png",
    }
    data.raw.planet["test-other-copy"] = {
        name = "test-other-copy",
        dupe_number = 2,
        icon = "test-other-copy.png",
    }
    data.raw.planet["test-original"] = {
        name = "test-original",
    }
    data.raw.planet["test-next-copy"] = {
        name = "test-next-copy",
        dupe_number = 3,
    }
    local maker = tech("test-maker", {
        unit = {
            ingredients = {
                {
                    "test-science",
                    1,
                },
            },
        },
    })
    maker.effects = {
        {
            type = "unlock-recipe",
            recipe = "test-component",
        },
    }
    local finisher = tech("test-finisher", {
        research_trigger = {
            type = "craft-item",
            item = {
                name = "test-component",
                quality = "test-quality",
            },
        },
    })
    finisher.effects = {
        {
            type = "unlock-recipe",
            recipe = "test-final",
        },
    }
    local maker_copy = dupe.prototype(maker, 2)
    -- Discovery chains initially retain the original unlock before variants replace it.
    maker_copy.effects = table.deepcopy(maker.effects)
    local finisher_copy = dupe.prototype(finisher, 2)
    finisher_copy.effects = nil
    dupe.technology_copies[2] = {
        [maker.name] = maker_copy,
        [finisher.name] = finisher_copy,
    }
    for _, name in pairs({
        "test-basic",
        "test-component",
        "test-final",
    }) do
        data:extend({
            {
                type = "item",
                name = name,
                icon = name .. ".png",
            },
        })
    end
    data:extend({
        {
            type = "recipe",
            name = "test-basic",
            ingredients = {},
            results = {
                {
                    type = "item",
                    name = "test-basic",
                    amount = 1,
                },
            },
        },
        {
            type = "recipe",
            name = "test-component",
            enabled = false,
            ingredients = {
                {
                    type = "item",
                    name = "test-basic",
                    amount = 1,
                },
            },
            results = {
                {
                    type = "item",
                    name = "test-component",
                    amount = 1,
                },
            },
        },
        {
            type = "recipe",
            name = "test-final",
            enabled = false,
            ingredients = {
                {
                    type = "item",
                    name = "test-component",
                    amount = 1,
                },
            },
            results = {
                {
                    type = "item",
                    name = "test-final",
                    amount = 1,
                },
            },
        },
    })
    data.raw.item["test-component"].icons = {
        {
            icon = "test-layer.png",
            icon_size = 64,
        },
    }
    local local_recipe = table.deepcopy(data.raw.recipe["test-component"])
    local_recipe.name = "test-local-component"
    local_recipe.accepted = {
        ["planet: test-other-copy"] = true,
    }
    data:extend({
        local_recipe,
    })
    table.insert(maker.effects, {
        type = "unlock-recipe",
        recipe = local_recipe.name,
    })
    local final_copy = dupe.item(data.raw.item["test-final"], 2)
    -- The other planet copy's own copied recipe takes the component too (its technology's copy follows that planet's discovery), so both planet copies need local variants of it
    local other_finisher = tech("test-other-finisher", {
        unit = {
            ingredients = {
                {
                    "test-science",
                    1,
                },
            },
        },
    })
    other_finisher.effects = {
        {
            type = "unlock-recipe",
            recipe = "test-other-final",
        },
    }
    local other_finisher_copy = dupe.prototype(other_finisher, 2)
    other_finisher_copy.effects = nil
    other_finisher_copy.prerequisites = {
        other_home.name,
    }
    dupe.technology_copies[2][other_finisher.name] = other_finisher_copy
    data:extend({
        {
            type = "item",
            name = "test-other-final",
            icon = "test-other-final.png",
        },
        {
            type = "recipe",
            name = "test-other-final",
            enabled = false,
            ingredients = {
                {
                    type = "item",
                    name = "test-component",
                    amount = 1,
                },
            },
            results = {
                {
                    type = "item",
                    name = "test-other-final",
                    amount = 1,
                },
            },
        },
    })
    dupe.item(data.raw.item["test-other-final"], 2)
    intermediates.execute()
    assert(data.raw.item["test-component-exfret-2-copy"] == nil)
    assert(data.raw.item["test-basic-exfret-2-copy"] == nil)
    assert(data.raw.recipe[final_copy.name].ingredients[1].name == "test-component")
    assert(data.raw.recipe["test-final"].ingredients[1].name == "test-component")
    assert(finisher_copy.research_trigger.item.name == "test-component")
    assert(finisher_copy.research_trigger.item.quality == "test-quality")
    assert(finisher.research_trigger.item.name == "test-component")
    local variants = {}
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.intermediate_planet ~= nil then
            assert(recipe.dupe_number == 2)
            assert(recipe.planet_badge == recipe.intermediate_planet)
            assert(#recipe.icons == 2)
            assert(recipe.icons[2].icon == recipe.intermediate_planet .. ".png")
            assert(recipe.intermediate_planet ~= "test-original" and recipe.intermediate_planet ~= "test-next-copy")
            local rooms = package.loaded["src/randomizations/planetary/locks"].fixed["recipe/" .. recipe.name]
            assert(rooms["planet: " .. recipe.intermediate_planet] and next(rooms, next(rooms)) == nil)
            assert(recipe.results[1].name == data.raw.recipe[recipe.orig_name].results[1].name)
            assert(recipe.enabled == false)
            variants[recipe.orig_name] = variants[recipe.orig_name] or {}
            variants[recipe.orig_name][recipe.intermediate_planet] = recipe
        end
    end
    assert(#data.raw.item["test-component"].icons == 1)
    assert(data.raw.recipe["test-component"].icons == nil)
    assert(#variants["test-component"]["test-home-copy"].icons == 2)
    assert(#variants["test-component"]["test-other-copy"].icons == 2)
    assert(variants["test-component"]["test-home-copy"].ingredients[1].name == "test-basic")
    assert(variants["test-component"]["test-other-copy"].ingredients[1].name == "test-basic")
    assert(variants[local_recipe.name]["test-home-copy"] == nil)
    assert(variants[local_recipe.name]["test-other-copy"] ~= nil)
    assert(#maker_copy.effects == 3 and maker.effects[1].recipe == "test-component")
    for _, effect in pairs(maker_copy.effects) do
        local recipe = data.raw.recipe[effect.recipe]
        assert(recipe.orig_name == "test-component" or recipe.orig_name == local_recipe.name)
    end
    assert(home.effects[2].recipe == variants["test-basic"]["test-home-copy"].name)
    assert(other_home.effects[2].recipe == variants["test-basic"]["test-other-copy"].name)
    -- Ingredient randomization can change one planet's recipe without changing the others.
    variants["test-component"]["test-home-copy"].ingredients[1].amount = 3
    assert(variants["test-component"]["test-other-copy"].ingredients[1].amount == 1)
    assert(data.raw.recipe["test-component"].ingredients[1].amount == 1)

end)

-- User, 2026-10-14: "nauvis copies have military science, why would fulgora (which doesn't have military science) need to get a copy for it?"
test("a planet copy gets local variants only of what its own copied recipes need", function()
    function log() end
    local home = tech("test-home", {
        effects = {
            {
                type = "unlock-space-location",
                space_location = "test-home-copy",
            },
        },
    })
    dupe.home_discoveries[2] = home
    local other_home = tech("test-other-home", {
        effects = {
            {
                type = "unlock-space-location",
                space_location = "test-other-copy",
            },
        },
    })
    for _, name in pairs({
        "test-home-copy",
        "test-other-copy",
    }) do
        data.raw.planet[name] = {
            name = name,
            dupe_number = 2,
            icon = name .. ".png",
        }
    end
    local function item_with_recipe(name, ingredients)
        local recipe = {
            type = "recipe",
            name = name,
            enabled = false,
            ingredients = {},
            results = {
                {
                    type = "item",
                    name = name,
                    amount = 1,
                },
            },
        }
        for _, ingredient in pairs(ingredients) do
            table.insert(recipe.ingredients, {
                type = "item",
                name = ingredient,
                amount = 1,
            })
        end
        data:extend({
            {
                type = "item",
                name = name,
                icon = name .. ".png",
            },
            recipe,
        })
    end
    -- Intermediates every planet could make: rounds (for the starting planet copy's pack), coils (for the other planet copy's), and a shared part both packs take
    item_with_recipe("test-rounds", {})
    item_with_recipe("test-coil", {})
    item_with_recipe("test-part", {})
    item_with_recipe("test-orphan-input", {})
    item_with_recipe("test-home-pack", {
        "test-rounds",
        "test-part",
    })
    item_with_recipe("test-other-pack", {
        "test-coil",
        "test-part",
    })
    -- Each pack's technology copy is on its planet copy's branch: the starting planet copy's has no prerequisites (its tree is rooted at the home discovery), the other planet copy's follows that planet's discovery
    for _, entry in pairs({
        {
            pack = "test-home-pack",
            prerequisites = {},
        },
        {
            pack = "test-other-pack",
            prerequisites = {
                other_home.name,
            },
        },
    }) do
        local original = tech(entry.pack .. "-tech", {
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = entry.pack,
                },
            },
        })
        local copy = dupe.prototype(original, 2)
        copy.effects = nil
        copy.prerequisites = entry.prerequisites
        dupe.technology_copies[2] = dupe.technology_copies[2] or {}
        dupe.technology_copies[2][original.name] = copy
        dupe.item(data.raw.item[entry.pack], 2)
    end
    -- A copied recipe no technology unlocks, whose planet copy can't be told: it counts for both
    data:extend({
        {
            type = "recipe",
            name = "test-orphan-exfret-2-copy",
            dupe_number = 2,
            orig_name = "test-orphan",
            ingredients = {
                {
                    type = "item",
                    name = "test-orphan-input",
                    amount = 1,
                },
            },
            results = {},
        },
    })
    intermediates.execute()
    local planets_of = {}
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.intermediate_planet ~= nil then
            planets_of[recipe.orig_name] = planets_of[recipe.orig_name] or {}
            planets_of[recipe.orig_name][recipe.intermediate_planet] = true
        end
    end
    local function on(name)
        local list = {}
        for planet, _ in pairs(planets_of[name] or {}) do
            table.insert(list, planet)
        end
        table.sort(list)
        return table.concat(list, ",")
    end
    assert(on("test-rounds") == "test-home-copy", "rounds: " .. on("test-rounds"))
    assert(on("test-coil") == "test-other-copy", "coils: " .. on("test-coil"))
    assert(on("test-part") == "test-home-copy,test-other-copy", "parts: " .. on("test-part"))
    assert(on("test-orphan-input") == "test-home-copy,test-other-copy", "orphan input: " .. on("test-orphan-input"))
end)

test("on a planet's branch, copies keep the starting planet's items rather than this number's copies of them", function()
    function log() end
    local function item(name)
        data:extend({
            {
                type = "item",
                name = name,
                icon = name .. ".png",
                place_result = name,
            },
        })
    end
    local function recipe(name, ingredient)
        data:extend({
            {
                type = "recipe",
                name = name,
                enabled = false,
                ingredients = {
                    {
                        type = "item",
                        name = ingredient,
                        amount = 1,
                    },
                },
                results = {
                    {
                        type = "item",
                        name = name,
                        amount = 1,
                    },
                },
            },
        })
    end
    -- Like the electric mining drill: the starting planet's, with copies of its own
    item("drill")
    recipe("drill", "plate")
    local drill_tech = tech("drill-tech", {
        effects = {
            {
                type = "unlock-recipe",
                recipe = "drill",
            },
            {
                type = "unlock-recipe",
                recipe = "drill-line",
            },
        },
        research_trigger = {
            type = "craft-item",
            item = "drill",
        },
    })
    -- Another of the starting planet's, made from the drill
    item("drill-line")
    recipe("drill-line", "drill")
    -- Like the big mining drill: a planet's own, made from the drill and triggered by crafting one
    tech("find-hot", {
        effects = {
            {
                type = "unlock-space-location",
                space_location = "hot",
            },
        },
    })
    local big_tech = tech("big-tech", {
        prerequisites = {
            "find-hot",
        },
        effects = {
            {
                type = "unlock-recipe",
                recipe = "big",
            },
        },
        research_trigger = {
            type = "craft-item",
            item = "drill",
        },
    })
    item("big")
    recipe("big", "drill")
    local drill_copy = dupe.item(data.raw.item["drill"], 2)
    dupe.item(data.raw.item["drill-line"], 2)
    dupe.item(data.raw.item["big"], 2)
    local drill_tech_copy = dupe.prototype(drill_tech, 2)
    local big_tech_copy = dupe.prototype(big_tech, 2)
    dupe.technology_copies[2] = {
        [drill_tech.name] = drill_tech_copy,
        [big_tech.name] = big_tech_copy,
    }
    intermediates.execute()
    local function copy_of(name)
        for _, candidate in pairs(data.raw.recipe) do
            if candidate.orig_name == name and candidate.dupe_number == 2 then
                return candidate
            end
        end
    end
    -- The starting planet's own copies take this number's drill
    assert(copy_of("drill-line").ingredients[1].name == drill_copy.name)
    assert(drill_tech_copy.research_trigger.item == drill_copy.name)
    -- The planet's copies keep the ordinary drill
    assert(copy_of("big").ingredients[1].name == "drill")
    assert(big_tech_copy.research_trigger.item == "drill")
    -- The originals are untouched
    assert(data.raw.recipe["big"].ingredients[1].name == "drill")
end)

test("empty copied leaves are removed while prerequisites of real unlocks remain", function()
    local root = tech("copy-root", {})
    local leaf = tech("copy-leaf", {
        prerequisites = {
            root.name,
        },
    })
    local unlock = tech("copy-unlock", {
        prerequisites = {
            root.name,
        },
    })
    unlock.effects = {
        {
            type = "unlock-recipe",
            recipe = "test-reward",
        },
    }
    local tree = {
        [2] = {
            root = root,
            leaf = leaf,
            unlock = unlock,
        },
    }
    assert(intermediates.prune(data.raw.technology, tree) == 1)
    assert(data.raw.technology[root.name] == root and tree[2].root == root)
    assert(data.raw.technology[leaf.name] == nil and tree[2].leaf == nil)
end)

print(count .. " tests passed")
