-- Plain-Lua regression tests for the lock stage's repairs (not loaded by the mod)
-- Run from the mod root: lua randomizations/planetary/test-lock-repairs.lua
-- A moved machine takes its ocean recipes along (user, 2026-10-08: follow the machine): each new planet gets its own version taking its ocean now
--
-- The toy game: planet V's ocean was lava and is heavy oil now, planet F's was heavy oil and is lava now, and planet G's ocean is heavy oil throughout
-- The foundry, made only on planets its recipe's surface conditions allow, is the only machine for metallurgy, and its lock moved from V to V, F and G
-- Molten iron took lava before the stages, and the ocean stage edited it to take heavy oil on V

-- Stand-ins for the Factorio environment
function table.deepcopy(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end
function log(msg) end
serpent = {
    block = tostring,
    line = tostring,
}
config = {}
defines = {
    prototypes = {
        item = {
            item = true,
        },
        entity = {
            ["assembling-machine"] = true,
        },
    },
}

local function locked()
    return {
        {
            property = "pressure",
            min = 1,
            max = 1,
        },
    }
end

-- A planet whose map generation places these tiles
local function planet(name, tile_names)
    local settings = {}
    for _, tile_name in pairs(tile_names) do
        settings[tile_name] = {}
    end
    return {
        type = "planet",
        name = name,
        map_gen_settings = {
            autoplace_settings = {
                tile = {
                    settings = settings,
                },
            },
        },
    }
end

local function tile(name, fluid)
    return {
        type = "tile",
        name = name,
        fluid = fluid,
    }
end

local function amount_of(kind, name, amount)
    return {
        type = kind,
        name = name,
        amount = amount,
    }
end

local function recipe(name, category, ingredients, result, surface_conditions)
    return {
        type = "recipe",
        name = name,
        categories = {
            category,
        },
        surface_conditions = surface_conditions,
        ingredients = ingredients,
        results = {
            result,
        },
    }
end

local function fresh_data()
    data = {
        extend = function(self, prototypes)
            for _, prototype in pairs(prototypes) do
                self.raw[prototype.type] = self.raw[prototype.type] or {}
                self.raw[prototype.type][prototype.name] = prototype
            end
        end,
        raw = {
            planet = {
                V = planet("V", { "v-ocean" }),
                F = planet("F", {
                    "f-ocean",
                    "f-ground",
                }),
                G = planet("G", { "g-ocean" }),
            },
            -- The ocean swap gave the tiles their new fluid (oceans.lua)
            tile = {
                ["v-ocean"] = tile("v-ocean", "heavy-oil"),
                ["f-ocean"] = tile("f-ocean", "lava"),
                ["f-ground"] = tile("f-ground", nil),
                ["g-ocean"] = tile("g-ocean", "heavy-oil"),
            },
            item = {
                foundry = {
                    type = "item",
                    name = "foundry",
                    place_result = "foundry",
                },
                assembler = {
                    type = "item",
                    name = "assembler",
                    place_result = "assembler",
                },
            },
            ["assembling-machine"] = {
                foundry = {
                    type = "assembling-machine",
                    name = "foundry",
                    crafting_categories = {
                        "metallurgy",
                        "crafting",
                    },
                },
                assembler = {
                    type = "assembling-machine",
                    name = "assembler",
                    crafting_categories = {
                        "crafting",
                    },
                },
            },
            recipe = {
                foundry = recipe("foundry", "crafting", {}, amount_of("item", "foundry", 1), locked()),
                assembler = recipe("assembler", "crafting", {}, amount_of("item", "assembler", 1)),
                -- Edited by the ocean stage for V: it took lava before
                ["molten-iron"] = recipe("molten-iron", "metallurgy", {
                    amount_of("fluid", "heavy-oil", 500),
                    amount_of("item", "calcite", 1),
                }, amount_of("fluid", "molten-iron", 250)),
                gears = recipe("gears", "crafting", {
                    amount_of("fluid", "lava", 10),
                }, amount_of("item", "gear", 1)),
            },
            technology = {
                ["foundry-tech"] = {
                    type = "technology",
                    name = "foundry-tech",
                    effects = {
                        {
                            type = "unlock-recipe",
                            recipe = "molten-iron",
                        },
                    },
                },
            },
            furnace = {},
        },
    }
end
fresh_data()

local fixed = {}
package.loaded["randomizations/planetary/locks"] = {
    moved = {
        ["recipe/foundry"] = {
            kind = "recipe",
            name = "foundry",
            old = {
                ["planet: V"] = true,
            },
            new = {
                ["planet: F"] = true,
                ["planet: G"] = true,
            },
            rooms = {
                ["planet: V"] = true,
                ["planet: F"] = true,
                ["planet: G"] = true,
            },
        },
    },
    fix = function(kind, name, rooms)
        fixed[kind .. "/" .. name] = rooms
    end,
    unfix = function(kind, name)
        fixed[kind .. "/" .. name] = nil
    end,
    realize = function() end,
}
package.loaded["randomizations/planetary/rewards"] = {
    helpers = {},
    bundle_of_lock = function(id)
        return nil
    end,
}
package.loaded["randomizations/planetary/scaffolds"] = {
    planet_variant_name = function(base, planet_name)
        return "propertyrandomizer-" .. base .. "-on-" .. planet_name
    end,
    name_variant = function(variant, recipe, planet_name)
        variant.localised_name = {
            "",
            recipe.name,
            planet_name,
        }
    end,
    badged_icons = function(recipe, planet_name)
        return nil
    end,
}
package.loaded["lib/random/rng"] = {
    int = function(_, max)
        return 1
    end,
}
package.loaded["lib/logic/init"] = {
    contexts = {},
    type_info = {},
}
package.loaded["lib/logic/state"] = package.loaded["lib/logic/init"]
package.loaded["lib/recycling"] = {
    looks_generated = function(recipe)
        return false
    end,
}

local lock_repairs = require("randomizations/planetary/lock-repairs")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function state_before()
    local ingredients = lock_repairs.ingredients_now()
    ingredients["molten-iron"] = {
        {
            type = "fluid",
            name = "lava",
            amount = 500,
        },
        {
            type = "item",
            name = "calcite",
            amount = 1,
        },
    }
    return {
        variants_of = {},
        ocean_fluids_before = {
            V = {
                lava = true,
            },
            F = {
                ["heavy-oil"] = true,
            },
            G = {
                ["heavy-oil"] = true,
            },
        },
        ingredients_before = ingredients,
    }
end

test("a planet's ocean fluids come from the tiles its map generation places", function()
    local fluids = lock_repairs.ocean_fluids()
    assert(fluids.V["heavy-oil"] and fluids.F.lava and fluids.G["heavy-oil"], "each planet's ocean tile gives its fluid")
    assert(fluids.F["f-ground"] == nil and next(fluids.F, next(fluids.F)) == nil, "a tile without a fluid gives none")
end)

test("a moved machine's ocean recipe gets a version on a new planet, taking that planet's ocean now", function()
    local state = state_before()
    lock_repairs.made = {}
    local num_made = lock_repairs.follow_machines(state)
    local version = data.raw.recipe["propertyrandomizer-molten-iron-with-lava-on-F"]
    assert(version ~= nil, "F, whose ocean is lava now, gets molten iron taking lava")
    assert(version.ingredients[1].name == "lava" and version.ingredients[1].amount == 500, "the version takes the new ocean in place of the old one")
    assert(version.ingredients[2].name == "calcite", "its other ingredients are the recipe's own from before the stages")
    assert(fixed["recipe/propertyrandomizer-molten-iron-with-lava-on-F"]["planet: F"], "the version is locked to its planet")
    local unlocked = false
    for _, effect in pairs(data.raw.technology["foundry-tech"].effects) do
        if effect.recipe == version.name then
            unlocked = true
        end
    end
    assert(unlocked, "the version is unlocked like the recipe")
    assert(num_made == 1, "only F gets a version, not " .. tostring(num_made))
    assert(state.variants_of["molten-iron"][1] == version.name, "the version counts as the recipe's for the planetary check")
end)

test("a planet the recipe already works on with its ocean gets no version, and neither does the old planet", function()
    fresh_data()
    fixed = {}
    local state = state_before()
    lock_repairs.made = {}
    lock_repairs.follow_machines(state)
    assert(data.raw.recipe["propertyrandomizer-molten-iron-with-heavy-oil-on-G"] == nil, "G's ocean is heavy oil, which molten iron takes now")
    assert(data.raw.recipe["propertyrandomizer-molten-iron-with-heavy-oil-on-V"] == nil, "V isn't a new planet of the lock")
end)

test("a recipe in a category other machines craft too isn't the machine's", function()
    fresh_data()
    fixed = {}
    local state = state_before()
    lock_repairs.made = {}
    lock_repairs.follow_machines(state)
    for name, _ in pairs(data.raw.recipe) do
        assert(string.find(name, "propertyrandomizer-gears", 1, true) == nil, "gears are crafted by the assembler too, so they don't follow the foundry")
    end
end)

test("taking a lock's versions back removes them, their locks and their unlocks", function()
    fresh_data()
    fixed = {}
    local state = state_before()
    lock_repairs.made = {}
    lock_repairs.follow_machines(state)
    lock_repairs.undo("recipe/foundry", state)
    assert(data.raw.recipe["propertyrandomizer-molten-iron-with-lava-on-F"] == nil, "the version is gone")
    assert(fixed["recipe/propertyrandomizer-molten-iron-with-lava-on-F"] == nil, "its lock is gone")
    for _, effect in pairs(data.raw.technology["foundry-tech"].effects) do
        assert(effect.recipe == "molten-iron", "only the recipe's own unlock is left")
    end
    assert(state.variants_of["molten-iron"] == nil, "it no longer counts as the recipe's")
end)

print(num_passed .. " tests passed")
