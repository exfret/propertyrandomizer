-- Run from the mod root: lua lib/test-deposit-copies.lua
local copies = require("lib/deposit-copies")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function set(list)
    local result = {}
    for _, value in pairs(list) do
        result[value] = true
    end
    return result
end

local iron_nauvis = copies.copy_name("iron-ore", "nauvis")
local iron_copy = copies.copy_name("iron-ore", "nauvis-copy")
local oil_aquilo = copies.copy_name("crude-oil", "aquilo")

test("copies, clones and their materials have different names", function()
    assert(iron_nauvis ~= iron_copy)
    assert(copies.clone_name("iron-ore", "nauvis") ~= iron_nauvis)
    assert(iron_nauvis ~= "iron-ore")
end)

test("a prototype is a copy only when the stage marked it", function()
    assert(copies.is_copy({
        name = iron_nauvis,
        deposit_copy_of = "iron-ore",
    }))
    assert(not copies.is_copy({
        name = "iron-ore",
    }))
    assert(not copies.is_copy(nil))
end)

test("a recipe gets a variant for each mix of its materials with copies, all of them first, or only the big ones past the limit", function()
    local function count(mixes)
        local num = 0
        for _, _ in pairs(mixes) do
            num = num + 1
        end
        return num
    end
    assert(count(copies.mixes({}, 3)) == 0)
    local one = copies.mixes({
        "item: iron-ore",
    }, 3)
    assert(count(one) == 1 and one[1]["item: iron-ore"] == true)
    local three = copies.mixes({
        "fluid: sulfuric-acid",
        "item: calcite",
        "item: coal",
    }, 3)
    assert(count(three) == 7)
    assert(three[1]["item: coal"] and three[1]["item: calcite"] and three[1]["fluid: sulfuric-acid"])
    local seen = {}
    for _, mixed in pairs(three) do
        local names = {}
        for material_key, _ in pairs(mixed) do
            table.insert(names, material_key)
        end
        table.sort(names)
        local text = table.concat(names, ",")
        assert(text ~= "" and seen[text] == nil)
        seen[text] = true
    end
    local four = copies.mixes({
        "item: a",
        "item: b",
        "item: c",
        "item: d",
    }, 3)
    assert(count(four) == 5)
end)

test("a variant that came out the same as its original is dropped with its unlocks, and one that didn't stays", function()
    local function plate(name, ore, extra)
        local recipe = {
            type = "recipe",
            name = name,
            category = "smelting",
            energy_required = 3.2,
            ingredients = {
                {
                    type = "item",
                    name = ore,
                    amount = 1,
                },
            },
            results = {
                {
                    type = "item",
                    name = "iron-plate",
                    amount = 1,
                },
            },
        }
        for field, value in pairs(extra or {}) do
            recipe[field] = value
        end
        return recipe
    end
    local raw = {
        recipe = {
            ["iron-plate"] = plate("iron-plate", "iron-ore"),
            ["plate-on-copy"] = plate("plate-on-copy", "iron-ore", {
                deposit_local = {
                    original = "iron-plate",
                    planet = "nauvis-copy",
                },
                localised_name = "Iron plate (copy)",
            }),
            ["plate-on-other"] = plate("plate-on-other", "stone-furnace", {
                deposit_local = {
                    original = "iron-plate",
                    planet = "other",
                },
            }),
        },
        technology = {
            ["smelting"] = {
                type = "technology",
                name = "smelting",
                effects = {
                    {
                        type = "unlock-recipe",
                        recipe = "plate-on-copy",
                    },
                    {
                        type = "unlock-recipe",
                        recipe = "plate-on-other",
                    },
                },
            },
        },
    }
    assert(copies.same_recipe(raw.recipe["plate-on-copy"], raw.recipe["iron-plate"]))
    assert(not copies.same_recipe(raw.recipe["plate-on-other"], raw.recipe["iron-plate"]))
    raw.recipe["plate-on-other-2"] = plate("plate-on-other-2", "stone-furnace", {
        deposit_local = {
            original = "iron-plate",
            planet = "other",
        },
    })
    assert(copies.drop_twins(raw) == 2)
    assert(raw.recipe["plate-on-copy"] == nil and raw.recipe["plate-on-other"] ~= nil and raw.recipe["iron-plate"] ~= nil)
    -- Two variants on one planet that came out the same: one stays
    assert(raw.recipe["plate-on-other-2"] == nil)
    assert(#raw.technology.smelting.effects == 1 and raw.technology.smelting.effects[1].recipe == "plate-on-other")
end)

test("a variant that came out the same as its original stays if it's had earlier on its planet", function()
    local function plate(name, extra)
        local recipe = {
            type = "recipe",
            name = name,
            category = "smelting",
            enabled = false,
            ingredients = {
                {
                    type = "item",
                    name = "iron-ore",
                    amount = 1,
                },
            },
            results = {
                {
                    type = "item",
                    name = "iron-plate",
                    amount = 1,
                },
            },
            deposit_local = {
                original = "iron-plate",
                planet = "nauvis-copy",
            },
        }
        for field, value in pairs(extra or {}) do
            recipe[field] = value
        end
        return recipe
    end
    local function unlocking(recipe_names)
        local effects = {}
        for _, recipe_name in pairs(recipe_names) do
            table.insert(effects, {
                type = "unlock-recipe",
                recipe = recipe_name,
            })
        end
        return {
            type = "technology",
            effects = effects,
        }
    end
    local original = plate("iron-plate")
    original.deposit_local = nil
    local raw = {
        recipe = {
            ["iron-plate"] = original,
            -- Unlocked by a technology that doesn't unlock the original, like after randomizing unlocks
            ["plate-early"] = plate("plate-early"),
            -- Had from the start, while the original isn't
            ["plate-enabled"] = plate("plate-enabled", {
                enabled = true,
            }),
            -- Unlocked only by the original's technology
            ["plate-same"] = plate("plate-same"),
        },
        technology = {
            ["early"] = unlocking({ "plate-early" }),
            ["smelting"] = unlocking({
                "iron-plate",
                "plate-same",
            }),
        },
    }
    assert(copies.drop_twins(raw) == 1)
    assert(raw.recipe["plate-early"] ~= nil and raw.recipe["plate-enabled"] ~= nil and raw.recipe["plate-same"] == nil)
    assert(#raw.technology.smelting.effects == 1 and raw.technology.smelting.effects[1].recipe == "iron-plate")
end)

test("dropped recipes take their unlocks with them, and nothing else", function()
    local function recipe(name)
        return {
            type = "recipe",
            name = name,
        }
    end
    local function unlock(name)
        return {
            type = "unlock-recipe",
            recipe = name,
        }
    end
    local raw = {
        recipe = {
            ["electrolyte"] = recipe("electrolyte"),
            ["electrolyte-on-gleba"] = recipe("electrolyte-on-gleba"),
            ["electrolyte-on-vulcanus"] = recipe("electrolyte-on-vulcanus"),
        },
        technology = {
            ["electromagnetics"] = {
                type = "technology",
                name = "electromagnetics",
                effects = {
                    unlock("electrolyte-on-gleba"),
                    unlock("electrolyte"),
                    {
                        type = "give-item",
                        item = "electrolyte-on-gleba",
                    },
                    unlock("electrolyte-on-vulcanus"),
                },
            },
            ["no-effects"] = {
                type = "technology",
                name = "no-effects",
            },
        },
    }
    copies.drop_recipes(raw, set({
        "electrolyte-on-gleba",
        "electrolyte-on-vulcanus",
    }))
    assert(raw.recipe["electrolyte"] ~= nil and raw.recipe["electrolyte-on-gleba"] == nil and raw.recipe["electrolyte-on-vulcanus"] == nil)
    local effects = raw.technology.electromagnetics.effects
    assert(#effects == 2 and effects[1].recipe == "electrolyte" and effects[2].type == "give-item")
end)

local function fixture()
    return {
        item = {
            ["iron-ore"] = {
                type = "item",
                name = "iron-ore",
            },
            [iron_nauvis] = {
                type = "item",
                name = iron_nauvis,
                deposit_copy_of = "iron-ore",
            },
            [iron_copy] = {
                type = "item",
                name = iron_copy,
                deposit_copy_of = "iron-ore",
            },
            ["egg"] = {
                type = "item",
                name = "egg",
                spoil_result = iron_copy,
            },
        },
        fluid = {
            ["crude-oil"] = {
                type = "fluid",
                name = "crude-oil",
            },
            [oil_aquilo] = {
                type = "fluid",
                name = oil_aquilo,
                deposit_copy_of = "crude-oil",
            },
        },
        resource = {
            ["iron-ore"] = {
                type = "resource",
                name = "iron-ore",
                minable = {
                    results = {
                        {
                            type = "item",
                            name = "stone-furnace",
                            amount = 1,
                        },
                    },
                },
            },
            [copies.clone_name("iron-ore", "nauvis-copy")] = {
                type = "resource",
                name = copies.clone_name("iron-ore", "nauvis-copy"),
                minable = {
                    result = iron_copy,
                },
            },
            ["crude-oil"] = {
                type = "resource",
                name = "crude-oil",
                minable = {
                    results = {
                        {
                            type = "fluid",
                            name = oil_aquilo,
                            amount_min = 10,
                        },
                    },
                },
            },
        },
        recipe = {
            ["iron-plate"] = {
                type = "recipe",
                name = "iron-plate",
                ingredients = {
                    {
                        type = "item",
                        name = iron_nauvis,
                        amount = 1,
                    },
                },
                results = {
                    {
                        type = "item",
                        name = "iron-plate",
                        amount = 1,
                    },
                },
            },
            ["mixer"] = {
                type = "recipe",
                name = "mixer",
                ingredients = {
                    {
                        type = "item",
                        name = iron_nauvis,
                        amount = 2,
                    },
                    {
                        type = "item",
                        name = "iron-ore",
                        amount = 3,
                        ignored_by_stats = 1,
                    },
                    {
                        type = "fluid",
                        name = oil_aquilo,
                        amount = 5,
                    },
                },
                results = {
                    {
                        type = "item",
                        name = iron_copy,
                        amount = 1,
                    },
                    {
                        type = "item",
                        name = "iron-ore",
                        amount = 1,
                    },
                },
                main_product = iron_copy,
            },
        },
        technology = {
            ["mining"] = {
                type = "technology",
                name = "mining",
                research_trigger = {
                    type = "craft-item",
                    item = iron_nauvis,
                },
            },
        },
        ["assembling-machine"] = {
            ["mixer"] = {
                type = "assembling-machine",
                name = "mixer",
                fluid_boxes = {
                    {
                        filter = oil_aquilo,
                    },
                },
                keyed = {
                    [iron_copy] = 4,
                },
            },
        },
    }
end

local original_of = {
    [iron_nauvis] = "iron-ore",
    [iron_copy] = "iron-ore",
    [oil_aquilo] = "crude-oil",
}

test("collapse renames every reference to a copy, drops the copies and merges ingredients a recipe then lists twice", function()
    local raw = fixture()
    assert(copies.has_copies(raw, original_of))
    local num_renamed, num_merged = copies.collapse(raw, original_of)
    assert(not copies.has_copies(raw, original_of))
    assert(raw.item[iron_nauvis] == nil and raw.item[iron_copy] == nil and raw.fluid[oil_aquilo] == nil)
    assert(raw.item["iron-ore"] ~= nil and raw.fluid["crude-oil"] ~= nil)
    assert(raw.item.egg.spoil_result == "iron-ore")
    assert(raw.resource["iron-ore"].minable.results[1].name == "stone-furnace")
    assert(raw.resource[copies.clone_name("iron-ore", "nauvis-copy")].minable.result == "iron-ore")
    assert(raw.resource["crude-oil"].minable.results[1].name == "crude-oil")
    assert(raw.recipe["iron-plate"].ingredients[1].name == "iron-ore")
    local mixer = raw.recipe.mixer
    assert(#mixer.ingredients == 2)
    assert(mixer.ingredients[1].name == "iron-ore" and mixer.ingredients[1].amount == 5 and mixer.ingredients[1].ignored_by_stats == 1)
    assert(mixer.ingredients[2].type == "fluid" and mixer.ingredients[2].name == "crude-oil")
    -- Results may list an item twice (RecipePrototype::results), so they stay as they are, renamed
    assert(#mixer.results == 2 and mixer.results[1].name == "iron-ore" and mixer.results[2].name == "iron-ore")
    assert(mixer.main_product == "iron-ore")
    assert(raw.technology.mining.research_trigger.item == "iron-ore")
    local machine = raw["assembling-machine"].mixer
    assert(machine.fluid_boxes[1].filter == "crude-oil")
    assert(machine.keyed["iron-ore"] == 4 and machine.keyed[iron_copy] == nil)
    assert(num_merged == 1)
    assert(num_renamed >= 10)
end)

test("collapse leaves a game without copies as it was", function()
    local raw = fixture()
    copies.collapse(raw, original_of)
    local num_renamed, num_merged = copies.collapse(raw, original_of)
    assert(num_renamed == 0 and num_merged == 0)
end)

test("a deposit's new identity has to be new to its planet", function()
    copies.current = {
        original_of = original_of,
        original_key = {
            ["item: " .. iron_nauvis] = "item: iron-ore",
            ["item: " .. iron_copy] = "item: iron-ore",
            ["item: " .. copies.copy_name("coal", "vulcanus")] = "item: coal",
        },
        position_planets = {
            ["item: " .. iron_nauvis] = { nauvis = true },
            ["item: uranium-ore"] = { nauvis = true },
        },
        mined_on = {
            nauvis = set({
                "item: iron-ore",
                "item: coal",
                "item: uranium-ore",
            }),
            vulcanus = set({
                "item: coal",
                "item: calcite",
            }),
        },
    }
    -- Another planet's copy of an ore the planet mines relabels its deposits
    assert(not copies.is_new_for("item: " .. iron_nauvis, "item: " .. iron_copy))
    assert(not copies.is_new_for("item: " .. iron_nauvis, "item: " .. copies.copy_name("coal", "vulcanus")))
    -- So does one of the planet's own materials, when its deposits mine only one copy of it
    assert(not copies.is_new_for("item: uranium-ore", "item: coal"))
    -- Something the planet didn't mine is new
    assert(copies.is_new_for("item: " .. iron_nauvis, "item: stone-furnace"))
    assert(copies.is_new_for("item: " .. iron_nauvis, "item: calcite"))
    -- Positions no deposit mines aren't judged
    assert(copies.is_new_for("item: iron-gear-wheel", "item: " .. iron_copy))
    copies.current = nil
    assert(copies.is_new_for("item: " .. iron_nauvis, "item: " .. iron_copy))
end)

print(num_passed .. " tests passed")
