-- Run from the mod root: lua lib/test-recipe-merges.lua
local merges = require("lib/recipe-merges")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function set(values)
    local result = {}
    for _, value in pairs(values) do
        result[value] = true
    end
    return result
end

-- A list of its arguments
local function list(...)
    return {
        ...,
    }
end

local function item(name, amount)
    return {
        type = "item",
        name = name,
        amount = amount,
    }
end

local function fluid(name, amount, temperature)
    return {
        type = "fluid",
        name = name,
        amount = amount,
        temperature = temperature,
    }
end

-- A recipe making one copper cable item out of its ingredients, a version of version_of when given, made in rooms (test_rooms, read by rooms_of below)
local function recipe(name, ingredients, fields)
    local prototype = {
        type = "recipe",
        name = name,
        ingredients = ingredients,
        results = {
            item("copper-cable", 2),
        },
        categories = {
            "crafting",
        },
        enabled = false,
        test_rooms = set({
            "planet: nauvis",
        }),
    }
    for field, value in pairs(fields or {}) do
        prototype[field] = value
    end
    return prototype
end

local function rooms_of(prototype)
    return prototype.test_rooms
end

local function recipes_of(list)
    local recipes = {}
    for _, prototype in pairs(list) do
        recipes[prototype.name] = prototype
    end
    return recipes
end

local function count(tbl)
    local num = 0
    for _, _ in pairs(tbl) do
        num = num + 1
    end
    return num
end

test("a recipe is in its own family unless it's a version of another", function()
    assert(merges.family_of({
        name = "copper-cable",
    }) == "copper-cable")
    assert(merges.family_of({
        name = "propertyrandomizer-copper-cable-on-gleba",
        version_of = "copper-cable",
    }) == "copper-cable")
end)

test("signatures leave out amounts but not what the ingredients are or what comes out", function()
    local base = recipe("a", {
        item("pipe", 1),
        fluid("steam", 10, 165),
    })
    assert(merges.signature(base) == merges.signature(recipe("b", {
        fluid("steam", 50, 165),
        item("pipe", 15),
    })))
    assert(merges.signature(base) ~= merges.signature(recipe("c", {
        item("pipe", 1),
        fluid("steam", 10, 500),
    })))
    assert(merges.signature(base) ~= merges.signature(recipe("d", {
        item("pipe", 1),
    })))
    assert(merges.signature(base) ~= merges.signature(recipe("e", {
        item("pipe", 1),
        fluid("steam", 10, 165),
    }, {
        results = {
            item("copper-cable", 3),
        },
    })))
    -- Where a fluid goes in the machine isn't what it is
    local placed = fluid("steam", 10, 165)
    placed.fluidbox_index = 2
    assert(merges.signature(base) == merges.signature(recipe("f", {
        item("pipe", 1),
        placed,
    })))
end)

test("the amount ratio is the largest gap over ingredients", function()
    local one = recipe("a", {
        item("pipe", 1),
        item("gear", 4),
    })
    local same = recipe("b", {
        item("gear", 4),
        item("pipe", 1),
    })
    local far = recipe("c", {
        item("pipe", 15),
        item("gear", 2),
    })
    assert(merges.amount_ratio(list(one, same)) == 1)
    assert(merges.amount_ratio(list(one, same, far)) == 15)
    local none = recipe("d", {
        item("pipe", 0),
        item("gear", 4),
    })
    assert(merges.amount_ratio(list(one, none)) == math.huge)
end)

test("the cheapest takes no more of anything, else costs least at the prices, else multiplies to the least", function()
    local few = recipe("a", {
        item("pipe", 1),
        item("gear", 2),
    })
    local many = recipe("b", {
        item("pipe", 15),
        item("gear", 2),
    })
    local cheapest, how = merges.cheapest(list(few, many))
    assert(cheapest == few and how == "fewest")
    cheapest, how = merges.cheapest(list(many, few))
    assert(cheapest == few and how == "fewest")

    -- Neither takes less of everything: 1 pipe and 16 gears against 3 pipes and 4 gears
    local gears = recipe("c", {
        item("pipe", 1),
        item("gear", 16),
    })
    local pipes = recipe("d", {
        item("pipe", 3),
        item("gear", 4),
    })
    local prices = {
        pipe = 10,
        gear = 1,
    }
    cheapest, how = merges.cheapest(list(gears, pipes), function(ingredient)
        return prices[ingredient.name]
    end)
    assert(cheapest == gears and how == "prices")
    prices.gear = 5
    cheapest, how = merges.cheapest(list(gears, pipes), function(ingredient)
        return prices[ingredient.name]
    end)
    assert(cheapest == pipes and how == "prices")
    -- An ingredient without a price leaves prices out: 1 * 16 against 3 * 4
    cheapest, how = merges.cheapest(list(gears, pipes), function(ingredient)
        return ingredient.name == "pipe" and 1 or nil
    end)
    assert(cheapest == pipes and how == "evenly")
    cheapest, how = merges.cheapest(list(gears, pipes))
    assert(cheapest == pipes and how == "evenly")
    -- Ties go to the first
    local tied = recipe("e", {
        item("pipe", 4),
        item("gear", 3),
    })
    cheapest = merges.cheapest(list(pipes, tied))
    assert(cheapest == pipes)
end)

test("only recipes of one family with one signature merge, and the family's own recipe stays", function()
    local plan = merges.plan(recipes_of({
        recipe("copper-cable", {
            item("pipe", 1),
        }),
        recipe("copper-cable-on-gleba", {
            item("pipe", 2),
        }, {
            version_of = "copper-cable",
            test_rooms = set({
                "planet: gleba",
            }),
        }),
        recipe("copper-cable-on-vulcanus", {
            item("stone", 2),
        }, {
            version_of = "copper-cable",
            test_rooms = set({
                "planet: vulcanus",
            }),
        }),
        -- Another family taking and making the same things
        recipe("cable-from-pipes", {
            item("pipe", 1),
        }),
    }), {
        rooms_of = rooms_of,
    })
    assert(#plan == 1)
    local merge = plan[1]
    assert(merge.keeper == "copper-cable")
    assert(#merge.absorbed == 1 and merge.absorbed[1] == "copper-cable-on-gleba")
    assert(#merge.members == 2)
    assert(merge.rooms["planet: nauvis"] and merge.rooms["planet: gleba"] and count(merge.rooms) == 2)
    assert(merge.ratio == 2 and not merge.is_flagged and merge.amounts_from == "copper-cable")
end)

test("without the family's own recipe the version made in the most rooms stays, the first by name on a tie", function()
    local function version(name, rooms)
        return recipe(name, {
            item("pipe", 1),
        }, {
            version_of = "copper-cable",
            test_rooms = set(rooms),
        })
    end
    local plan = merges.plan(recipes_of({
        version("b-version", list("planet: gleba", "planet: gleba-2")),
        version("a-version", list("planet: fulgora")),
        version("c-version", list("planet: aquilo", "planet: aquilo-2")),
    }), {
        rooms_of = rooms_of,
    })
    assert(#plan == 1 and plan[1].keeper == "b-version")
    assert(count(plan[1].rooms) == 5)
end)

test("hidden recipes and recipes no room accepts stay as they are", function()
    local plan = merges.plan(recipes_of({
        recipe("copper-cable", {
            item("pipe", 1),
        }, {
            test_rooms = {},
        }),
        recipe("hidden-version", {
            item("pipe", 1),
        }, {
            version_of = "copper-cable",
            hidden = true,
        }),
        recipe("lone-version", {
            item("pipe", 1),
        }, {
            version_of = "copper-cable",
        }),
    }), {
        rooms_of = rooms_of,
    })
    assert(#plan == 0)
end)

test("merged recipes are made in every member's machines, the kept one's first, and enabled if one was", function()
    local plan = merges.plan(recipes_of({
        recipe("copper-cable", {
            item("pipe", 1),
        }, {
            categories = {
                "electromagnetics",
                "crafting",
            },
        }),
        recipe("version-1", {
            item("pipe", 1),
        }, {
            version_of = "copper-cable",
            categories = {
                "metallurgy",
                "crafting",
            },
            enabled = true,
        }),
    }), {
        rooms_of = rooms_of,
    })
    local categories = plan[1].categories
    assert(#categories == 3 and categories[1] == "electromagnetics" and categories[2] == "crafting" and categories[3] == "metallurgy")
    assert(plan[1].is_enabled)
end)

test("radically different amounts are flagged and take the cheapest; others keep the kept recipe's", function()
    local function plan_for(original_amount, version_amount)
        return merges.plan(recipes_of({
            recipe("copper-cable", {
                item("pipe", original_amount),
            }),
            recipe("version-1", {
                item("pipe", version_amount),
            }, {
                version_of = "copper-cable",
            }),
        }), {
            rooms_of = rooms_of,
        })[1]
    end
    local close = plan_for(4, 6)
    assert(not close.is_flagged and close.amounts_from == "copper-cable" and close.told_apart_by == nil)
    local close_cheaper = plan_for(6, 4)
    assert(not close_cheaper.is_flagged and close_cheaper.amounts_from == "copper-cable")
    local far = plan_for(15, 1)
    assert(far.is_flagged and far.amounts_from == "version-1" and far.told_apart_by == "fewest")
    local at_limit = plan_for(merges.RADICAL_RATIO, 1)
    assert(at_limit.is_flagged)
end)

test("applying a plan merges the recipes, their technologies and what the checks need", function()
    local raw = {
        recipe = recipes_of({
            recipe("copper-cable", {
                item("pipe", 15),
            }, {
                categories = {
                    "crafting",
                },
                surface_conditions = {
                    {
                        property = "pressure",
                        min = 1000,
                        max = 1000,
                    },
                },
            }),
            recipe("version-locked", {
                item("pipe", 1),
            }, {
                version_of = "copper-cable",
                categories = {
                    "metallurgy",
                },
                surface_conditions = {
                    {
                        property = "vibes",
                        min = 7,
                        max = 7,
                    },
                },
                test_rooms = set({
                    "planet: vulcanus",
                }),
                energy_required = 3,
            }),
            recipe("version-deposits", {
                item("pipe", 2),
            }, {
                version_of = "copper-cable",
                surface_conditions = {
                    {
                        property = "vibes",
                        min = 14,
                        max = 14,
                    },
                },
                deposit_local_unlocked = true,
                test_rooms = set({
                    "planet: gleba",
                }),
                enabled = true,
                intermediate_planet = "gleba",
            }),
        }),
        technology = {
            ["electronics"] = {
                name = "electronics",
                effects = {
                    {
                        type = "unlock-recipe",
                        recipe = "copper-cable",
                    },
                    {
                        type = "unlock-recipe",
                        recipe = "version-locked",
                    },
                },
            },
            ["vulcanus-cables"] = {
                name = "vulcanus-cables",
                effects = {
                    {
                        type = "unlock-recipe",
                        recipe = "version-locked",
                    },
                    {
                        type = "change-recipe-productivity",
                        recipe = "version-locked",
                        change = 0.1,
                    },
                },
            },
            ["unrelated"] = {
                name = "unrelated",
                effects = {
                    {
                        type = "unlock-recipe",
                        recipe = "gear",
                    },
                    {
                        type = "unlock-recipe",
                        recipe = "gear",
                    },
                },
            },
        },
    }
    local unrelated_effects = raw.technology["unrelated"].effects
    assert(next(merges.into_of(raw)) == nil)
    local plan = merges.plan(raw.recipe, {
        rooms_of = rooms_of,
    })
    assert(#plan == 1 and plan[1].keeper == "copper-cable" and plan[1].is_flagged and plan[1].amounts_from == "version-locked")
    local new_conditions = {
        {
            property = "togetherness",
            min = 9,
            max = 27,
        },
    }
    local into = merges.apply(raw, plan, {
        ["copper-cable"] = new_conditions,
    })
    assert(into["version-locked"] == "copper-cable" and into["version-deposits"] == "copper-cable")
    local into_of = merges.into_of(raw)
    assert(into_of["version-locked"] == "copper-cable" and into_of["version-deposits"] == "copper-cable" and count(into_of) == 2)

    local kept = raw.recipe["copper-cable"]
    assert(raw.recipe["version-locked"] == nil and raw.recipe["version-deposits"] == nil)
    assert(kept.ingredients[1].amount == 1 and kept.energy_required == 3)
    assert(#kept.categories == 2 and kept.categories[1] == "crafting" and kept.categories[2] == "metallurgy" and kept.category == nil)
    assert(kept.enabled == true)
    assert(kept.surface_conditions[1].property == "togetherness" and kept.surface_conditions ~= new_conditions)
    local records = {}
    for _, record in pairs(kept.merged_versions) do
        records[record.name] = record
    end
    assert(records["version-locked"].is_planet_locked == true)
    assert(records["version-deposits"].is_planet_locked == false)

    -- Every technology that unlocked a member unlocks the kept recipe, once each
    local electronics = raw.technology["electronics"].effects
    assert(#electronics == 1 and electronics[1].recipe == "copper-cable")
    local vulcanus = raw.technology["vulcanus-cables"].effects
    assert(#vulcanus == 2 and vulcanus[1].type == "unlock-recipe" and vulcanus[1].recipe == "copper-cable")
    assert(vulcanus[2].type == "change-recipe-productivity" and vulcanus[2].recipe == "copper-cable")
    -- A technology naming none of them is left alone, repeats and all
    assert(raw.technology["unrelated"].effects == unrelated_effects and #unrelated_effects == 2)
end)

test("an empty list of conditions means every room, and a new label replaces a planet's name", function()
    local raw = {
        recipe = recipes_of({
            recipe("version-1", {
                item("pipe", 1),
            }, {
                version_of = "copper-cable",
                surface_conditions = {
                    {
                        property = "vibes",
                        min = 7,
                        max = 7,
                    },
                },
                intermediate_planet = "nauvis",
                localised_name = {
                    "propertyrandomizer-name.planet-variant",
                    "Copper cable",
                    "Nauvis",
                },
            }),
            recipe("version-2", {
                item("pipe", 1),
            }, {
                version_of = "copper-cable",
                test_rooms = set({
                    "planet: gleba",
                }),
            }),
        }),
        technology = {},
    }
    local plan = merges.plan(raw.recipe, {
        rooms_of = rooms_of,
    })
    assert(#plan == 1 and plan[1].keeper == "version-1")
    local label = {
        "propertyrandomizer-name.planet-variant",
        "Copper cable",
        {
            "",
            "Nauvis",
            ", ",
            "Gleba",
        },
    }
    merges.apply(raw, plan, {
        ["version-1"] = {},
    }, {
        ["version-1"] = label,
    })
    local kept = raw.recipe["version-1"]
    assert(kept.surface_conditions == nil)
    assert(kept.localised_name[3][4] == "Gleba" and kept.localised_name ~= label)
    assert(kept.intermediate_planet == nil)
end)

test("a merged recipe gets at least what each recipe it took in had", function()
    local prototypes = {
        recipe("copper-cable", {
            item("pipe", 1),
        }, {
            categories = {
                "crafting",
            },
            test_rooms = set({
                "planet: nauvis",
                "planet: fulgora",
            }),
        }),
    }
    local planets = list("gleba", "vulcanus", "aquilo", "gleba-2", "vulcanus-3")
    local categories = list("metallurgy", "organic", "crafting", "electromagnetics", "metallurgy")
    for i, planet in pairs(planets) do
        table.insert(prototypes, recipe("version-" .. i, {
            item("pipe", i * 2),
        }, {
            version_of = "copper-cable",
            categories = {
                categories[i],
            },
            test_rooms = set({
                "planet: " .. planet,
            }),
        }))
    end
    local raw = {
        recipe = recipes_of(prototypes),
        technology = {},
    }
    for i, _ in pairs(planets) do
        raw.technology["tech-" .. i] = {
            name = "tech-" .. i,
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = "version-" .. i,
                },
            },
        }
    end
    local before = {}
    for name, prototype in pairs(raw.recipe) do
        before[name] = {
            rooms = prototype.test_rooms,
            categories = prototype.categories,
        }
    end
    local plan = merges.plan(raw.recipe, {
        rooms_of = rooms_of,
    })
    local into = merges.apply(raw, plan, {})
    assert(count(into) == #planets)
    for name, kept_name in pairs(into) do
        local merge
        for _, candidate in pairs(plan) do
            if candidate.keeper == kept_name then
                merge = candidate
            end
        end
        for room_key, _ in pairs(before[name].rooms) do
            assert(merge.rooms[room_key], name .. " lost " .. room_key)
        end
        local kept_categories = set(raw.recipe[kept_name].categories)
        for _, category in pairs(before[name].categories) do
            assert(kept_categories[category], name .. " lost " .. category)
        end
    end
    for i, _ in pairs(planets) do
        local effects = raw.technology["tech-" .. i].effects
        assert(#effects == 1 and effects[1].recipe == "copper-cable")
    end
end)

print(num_passed .. " tests passed")
