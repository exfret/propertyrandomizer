-- Plain-Lua regression tests for item reflection's placement rules in src/prototypes/data-utils.lua (not loaded by the mod)
-- Run from the mod root: lua tests/unit/randomizations/unified/test-item-reflection.lua
-- First pass models the game that item reflection builds, so both use these rules: which mining results keep their names, and where useless items go

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
defines = {
    prototypes = {
        item = {
            item = 0,
        },
    },
}
util = {
    parse_energy = function(energy)
        local number, prefix = string.match(energy, "^([%d%.]+)(%a?)[JW]$")
        local scale = { [""] = 1, k = 1e3, M = 1e6, G = 1e9, T = 1e12 }
        return (tonumber(number) or 0) * (scale[prefix] or 1)
    end,
}
data = {
    raw = {
        lab = {},
        item = {},
    },
}

local dutils = require("src/prototypes/data-utils")
local recycling_sources = require("src/logic/builders/recycling-sources")

-- The real number helpers, with stand-ins for the engine module and prefix roll
package.loaded["resource-autoplace"] = {}
package.loaded["src/lib/random/rng"] = {
    int = function(_, max)
        return 1
    end,
}
local dupe = require("src/prototypes/duplicates/dupe")
local constants = require("src/config/constants")
local locale_utils = require("src/localisation/locale")
local recipe_renames = require("src/prototypes/recipes/recipe-renames")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

-- A useless item has nothing tied to its identity; one that places something isn't useless
local function add_item(name, is_useless)
    data.raw.item[name] = {
        type = "item",
        name = name,
        place_result = (not is_useless) and name or nil,
    }
end

local function is_useless(name)
    return dutils.is_useless_item(dutils.get_prot("item", name))
end

test("mining a player creation or a tile keeps item names, mining anything else doesn't", function()
    -- Flags as on vanilla prototypes (see __space-age__/prototypes/decorative/decoratives-fulgora.lua for the ruin)
    assert(dutils.mining_keeps_item_names({ type = "tile", name = "some-tile" }))
    assert(dutils.mining_keeps_item_names({ type = "lightning-attractor", name = "ruin", flags = { "placeable-neutral", "player-creation", "not-upgradable" } }))
    assert(dutils.mining_keeps_item_names({ type = "assembling-machine", name = "machine", flags = { "placeable-neutral", "placeable-player", "player-creation" } }))
    assert(not dutils.mining_keeps_item_names({ type = "resource", name = "ore", flags = { "placeable-neutral" } }))
    assert(not dutils.mining_keeps_item_names({ type = "simple-entity", name = "rock" }))
end)

test("a cycle with two useless items keeps the non-useless one where it was assigned", function()
    add_item("a", true)
    add_item("b", true)
    add_item("c", false)
    -- Position a was assigned identity b, b was assigned c, and c was assigned a
    local identity_at = {
        a = "b",
        b = "c",
        c = "a",
    }
    assert(dutils.reflected_item_position(identity_at, "b", "c") == "b")
    -- b is useless, so it goes to the first position along the cycle holding a useless identity (c, which holds a)
    assert(dutils.reflected_item_position(identity_at, "a", "b") == "c")
    -- a and the identity at a's position (b) are both useless, so a is left alone
    assert(dutils.reflected_item_position(identity_at, "c", "a") == nil)
    local realized = dutils.realized_item_assignment(identity_at)
    assert(realized.a == "a")
    assert(realized.b == "c")
    assert(realized.c == "b")
end)

test("realized assignments are permutations that keep non-useless identities and are their own realization", function()
    math.randomseed(1)
    for trial = 1, 3000 do
        data.raw.item = {}
        local n = math.random(2, 12)
        local names = {}
        for i = 1, n do
            names[i] = "item-" .. i
            add_item(names[i], math.random() < 0.5)
        end
        local shuffled = {}
        for i = 1, n do
            shuffled[i] = names[i]
        end
        for i = n, 2, -1 do
            local j = math.random(1, i)
            shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
        end
        local identity_at = {}
        for i = 1, n do
            identity_at[names[i]] = shuffled[i]
        end

        local realized = dutils.realized_item_assignment(identity_at)
        local seen = {}
        for _, position in pairs(names) do
            local identity = realized[position]
            assert(identity ~= nil and not seen[identity], "not a permutation")
            seen[identity] = true
            if not is_useless(identity_at[position]) then
                assert(identity == identity_at[position], "a non-useless identity moved")
            end
        end
        local again = dutils.realized_item_assignment(realized)
        for _, position in pairs(names) do
            assert(again[position] == realized[position], "realizing a realized assignment changed it")
        end
    end
end)

test("the identity assignment realizes to itself", function()
    data.raw.item = {}
    local identity_at = {}
    for i = 1, 8 do
        add_item("item-" .. i, i % 2 == 0)
        identity_at["item-" .. i] = "item-" .. i
    end
    local realized = dutils.realized_item_assignment(identity_at)
    for position, identity in pairs(identity_at) do
        assert(realized[position] == identity)
    end
end)

test("item reflection and first pass both use the shared rules", function()
    local function source(path)
        local handle = assert(io.open(path))
        local text = handle:read("*a")
        handle:close()
        return text
    end
    local item_reflection = source("src/randomizations/unified/handlers/item.lua")
    local first_pass = source("src/randomizations/unified/first-pass.lua")
    -- First pass gates the assignment as item reflection realizes it (the useless rule for items and fluids, src/randomizations/unified/item-fluid.lua), and reflection applies that one as it is
    assert(string.find(item_reflection, "item_fluid.reflected_positions(", 1, true) ~= nil)
    assert(string.find(item_reflection, "dutils.mining_keeps_item_names(", 1, true) ~= nil)
    assert(string.find(first_pass, "item_fluid.realized_assignment(", 1, true) ~= nil)
    assert(string.find(first_pass, "dutils.mining_keeps_item_names(", 1, true) ~= nil)
    -- Coal's replacement becomes a fuel, which first pass models on coal's position
    assert(string.find(item_reflection, "dutils.replacement_gets_fuel(", 1, true) ~= nil)
    assert(string.find(item_reflection, "dutils.give_replacement_fuel(", 1, true) ~= nil)
    assert(string.find(first_pass, "dutils.replacement_gets_fuel(", 1, true) ~= nil)
end)

test("whatever replaces coal becomes a fuel of its category, and keeps its own fuel categories", function()
    local fcat = dutils.REPLACEMENT_FUEL_CATEGORY
    local plain = {
        type = "item",
        name = "widget",
    }
    assert(dutils.give_replacement_fuel(plain))
    assert(dutils.has_fuel_category(plain, fcat) and plain.fuel_value == "4MJ")
    -- Another kind of fuel (like fusion power cells) keeps its category, and its fuel value unless that's too small
    local other_fuel = {
        type = "item",
        name = "power-cell",
        fuel_categories = { "exotic" },
        fuel_value = "40GJ",
    }
    assert(dutils.give_replacement_fuel(other_fuel))
    assert(dutils.has_fuel_category(other_fuel, "exotic") and dutils.has_fuel_category(other_fuel, fcat) and other_fuel.fuel_value == "40GJ")
    local weak_other_fuel = {
        type = "item",
        name = "pellet",
        fuel_categories = { "exotic" },
        fuel_value = "500kJ",
    }
    assert(dutils.give_replacement_fuel(weak_other_fuel))
    assert(dutils.has_fuel_category(weak_other_fuel, fcat) and weak_other_fuel.fuel_value == "2MJ")
    -- A weak fuel of the category (like spoilage) gets more energy, and a strong one is left alone
    local weak = {
        type = "item",
        name = "twig",
        fuel_categories = { fcat },
        fuel_value = "1MJ",
    }
    assert(not dutils.give_replacement_fuel(weak) and weak.fuel_value == "2MJ")
    local strong = {
        type = "item",
        name = "log",
        fuel_categories = { fcat },
        fuel_value = "5MJ",
    }
    assert(not dutils.give_replacement_fuel(strong) and strong.fuel_value == "5MJ")
end)

-- Item reflection renames a recipe after its new item only when the recipe was named after the old one
test("a recipe's main product is the one main_product names, or its only product", function()
    local function product(name)
        return {
            type = "item",
            name = name,
            amount = 1,
        }
    end
    local function main_name(recipe)
        local main_product = dutils.recipe_main_product(recipe)
        return main_product ~= nil and main_product.name or nil
    end
    assert(main_name({results = {product("gear")}}) == "gear")
    -- Several products and no main_product, like recycling, isn't named after any of them, even the first
    assert(main_name({results = {product("gear"), product("plate")}}) == nil)
    assert(main_name({main_product = "plate", results = {product("gear"), product("plate")}}) == "plate")
    assert(main_name({main_product = "", results = {product("gear")}}) == nil)
    assert(main_name({results = {}}) == nil)
    assert(main_name({}) == nil)
    -- Two entries for the same item are still several products
    assert(main_name({results = {product("gear"), product("gear")}}) == nil)
end)

test("a recycling recipe is named after its single ingredient, not a product", function()
    local function entry(name)
        return {
            type = "item",
            name = name,
            amount = 1,
        }
    end
    local vanilla_recipes = {
        ["gear-recycling"] = {categories = {"recycling"}, ingredients = {entry("gear")}, results = {entry("plate")}},
        ["plate-recycling"] = {categories = {"recycling"}, ingredients = {entry("plate")}, results = {entry("plate")}},
        ["gear"] = {ingredients = {entry("plate")}, results = {entry("gear")}},
    }
    assert(recycling_sources.named_after_ingredient(vanilla_recipes, "gear-recycling") == "gear")
    assert(recycling_sources.named_after_ingredient(vanilla_recipes, "plate-recycling") == "plate")
    assert(recycling_sources.named_after_ingredient(vanilla_recipes, "gear") == nil)
    -- Recipes made during randomization aren't vanilla recycling recipes
    assert(recycling_sources.named_after_ingredient(vanilla_recipes, "new-recipe") == nil)
end)

test("both item randomizations rename recipes by the shared main product rule", function()
    local function source(path)
        local handle = assert(io.open(path))
        local text = handle:read("*a")
        handle:close()
        return text
    end
    for _, path in pairs({"src/randomizations/unified/handlers/item.lua", "src/legacy/randomizations/item.lua"}) do
        local text = source(path)
        assert(string.find(text, "dutils.recipe_main_product(", 1, true) ~= nil, path)
        assert(string.find(text, "results[1].name ==", 1, true) == nil, path .. " matches recipes by their first result")
        assert(string.find(text, "recycling_sources.named_after_ingredient(", 1, true) ~= nil, path .. " renames recycling recipes after a product")
        -- Both name renamed recipes the same way, once every change is applied
        assert(string.find(text, "recipe_renames.apply(", 1, true) ~= nil, path .. " names renamed recipes itself")
    end
    assert(string.find(source("src/pipeline/data-final-fixes.lua"), "randomizations.fix_recycling_names()", 1, true) ~= nil)
    -- The unified item handler names recipes once it can count how many are named after each item
    assert(string.find(source("src/randomizations/unified/execute.lua"), "handler.after_changes()", 1, true) ~= nil)
end)

test("a renamed recipe takes its new item's name, icon and place in the menus, and renamed ones sharing an item are numbered", function()
    local function entry(name)
        return {
            type = "item",
            name = name,
            amount = 1,
        }
    end
    data.raw.item.plate = {
        type = "item",
        name = "plate",
        icons = {
            {
                icon = "plate.png",
                icon_size = 32,
            },
        },
    }
    data.raw.item.egg = {
        type = "item",
        name = "egg",
        icon = "egg.png",
    }
    -- As the game is after item randomization: breed and cast make plates now, and hatch makes eggs
    data.raw.recipe = {
        smelt = {type = "recipe", name = "smelt", results = {entry("plate")}},
        breed = {type = "recipe", name = "breed", localised_name = {"recipe-name.breed"}, icon = "breed.png", subgroup = "farming", order = "b", results = {entry("plate")}},
        cast = {type = "recipe", name = "cast", results = {entry("plate")}},
        hatch = {type = "recipe", name = "hatch", icon = "hatch.png", results = {entry("egg")}},
        ["egg-recycling"] = {type = "recipe", name = "egg-recycling", categories = {"recycling"}, ingredients = {entry("egg")}, results = {entry("egg")}},
    }
    local old_recipes = {
        ["egg-recycling"] = data.raw.recipe["egg-recycling"],
    }
    recipe_renames.apply({
        breed = {type = "item", name = "plate"},
        cast = {type = "item", name = "plate"},
        hatch = {type = "item", name = "egg"},
    }, old_recipes, "key")

    local recipes = data.raw.recipe
    -- The only recipe named after eggs (recycling is named after what it recycles) takes the egg's plain name and icon, over its own
    assert(recipes.hatch.localised_name[1] == locale_utils.find_localised_name(data.raw.item.egg)[1])
    assert(recipes.hatch.icon == nil and #recipes.hatch.icons == 1 and recipes.hatch.icons[1].icon == "egg.png" and recipes.hatch.icons[1].icon_size == 64)
    -- Three recipes are named after plates, so the renamed two get a prefix and badges 1 and 2 in name order, and the one that wasn't renamed is left alone
    for number, name in pairs({"breed", "cast"}) do
        local recipe = recipes[name]
        assert(recipe.localised_name[1] == "propertyrandomizer-recipe-prefix." .. constants.funny_recipe_prefixes[1], name)
        assert(recipe.localised_name[2][1] == locale_utils.find_localised_name(data.raw.item.plate)[1], name)
        assert(recipe.icon == nil and #recipe.icons == 2 and recipe.icons[1].icon == "plate.png" and recipe.icons[2].icon == dupe.recipe_number_icon(number).icon, name)
    end
    -- A renamed recipe is listed with its new item, so its own subgroup and order go
    assert(recipes.breed.subgroup == nil and recipes.breed.order == nil)
    assert(recipes.smelt.localised_name == nil and recipes.smelt.icons == nil)
    -- The item's own icons aren't shared with the recipes
    assert(#data.raw.item.plate.icons == 1)
end)

test("many renamed recipes use complete number badges on the right through 99", function()
    data.raw.item.plate = {
        type = "item",
        name = "plate",
        icon = "plate.png",
    }
    data.raw.recipe = {}
    local renamed = {}
    for number = 1, 100 do
        local name = string.format("recipe-%03d", number)
        data.raw.recipe[name] = {
            type = "recipe",
            name = name,
            results = {
                {
                    type = "item",
                    name = "plate",
                    amount = 1,
                },
            },
        }
        renamed[name] = {
            type = "item",
            name = "plate",
        }
    end
    recipe_renames.apply(renamed, {}, "key")
    for number = 1, 99 do
        local icons = data.raw.recipe[string.format("recipe-%03d", number)].icons
        assert(#icons == 2, tostring(number))
        assert(icons[1].icon == "plate.png")
        local badge = icons[2]
        assert(badge.icon == dupe.recipe_number_icon(number).icon)
        assert(badge.shift[1] == 7 and badge.shift[2] == -7)
    end
    -- Larger numbers keep the product icon rather than reusing an earlier recipe's number
    assert(#data.raw.recipe["recipe-100"].icons == 1)
    assert(data.raw.item.plate.icons == nil)
end)

test("local intermediate recipe names keep their planet after product renaming", function()
    defines.prototypes.planet = {}
    defines.prototypes.planet.planet = 0
    data.raw.planet = {}
    data.raw.planet["test-copy-world"] = {
        name = "test-copy-world",
        localised_name = {
            "test-world-name",
        },
    }
    data.raw.planet["test-copy-world"].type = "planet"
    data.raw.item["test-shared-product"] = {
        type = "item",
        name = "test-shared-product",
        icon = "test-shared-product.png",
    }
    local recipe = {
        type = "recipe",
        name = "test-local-production",
        intermediate_planet = "test-copy-world",
        results = {
            {
                type = "item",
                name = "test-shared-product",
                amount = 1,
            },
        },
    }
    data.raw.recipe = {}
    data.raw.recipe[recipe.name] = recipe
    recipe_renames.apply({
        [recipe.name] = {
            type = "item",
            name = "test-shared-product",
        },
    }, {}, "key")
    assert(recipe.localised_name[1] == "propertyrandomizer.recipe_planet_variant")
    assert(recipe.localised_name[3][1] == "test-world-name")
    assert(recipe.icons[1].icon == "test-shared-product.png")
end)

test("planet variants and local copies use planet badges instead of numbers after product renaming", function()
    data.raw.planet = {
        ["test-badge-world"] = {
            type = "planet",
            name = "test-badge-world",
            icon = "test-badge-world.png",
        },
        ["test-no-icon-world"] = {
            type = "planet",
            name = "test-no-icon-world",
        },
    }
    data.raw.item["test-badge-product"] = {
        type = "item",
        name = "test-badge-product",
        icon = "test-badge-product.png",
    }
    -- Both creation paths mark the planet whose badge the recipe keeps.
    local function made_on_world(name, planet_badge)
        return {
            type = "recipe",
            name = name,
            intermediate_planet = "test-badge-world",
            planet_badge = planet_badge,
            results = {
                {
                    type = "item",
                    name = "test-badge-product",
                    amount = 1,
                },
            },
        }
    end
    data.raw.recipe = {
        ["test-variant"] = made_on_world("test-variant", "test-badge-world"),
        ["test-copy-local"] = made_on_world("test-copy-local", "test-badge-world"),
        ["test-no-icon"] = made_on_world("test-no-icon", "test-no-icon-world"),
        ["test-plain"] = made_on_world("test-plain", nil),
    }
    data.raw.recipe["test-no-icon"].intermediate_planet = "test-no-icon-world"
    data.raw.recipe["test-plain"].intermediate_planet = nil
    recipe_renames.apply({
        ["test-variant"] = {
            type = "item",
            name = "test-badge-product",
        },
        ["test-copy-local"] = {
            type = "item",
            name = "test-badge-product",
        },
        ["test-no-icon"] = {
            type = "item",
            name = "test-badge-product",
        },
        ["test-plain"] = {
            type = "item",
            name = "test-badge-product",
        },
    }, {}, "key")
    -- A planet badge is the only corner badge, even when several recipes share the product.
    local planet_recipes = {
        "test-variant",
        "test-copy-local",
    }
    for _, name in pairs(planet_recipes) do
        local recipe = data.raw.recipe[name]
        assert(#recipe.icons == 2 and recipe.icons[1].icon == "test-badge-product.png")
        local badge = recipe.icons[2]
        assert(badge.icon == "test-badge-world.png" and badge.shift[1] == 8 and badge.shift[2] == -8 and badge.scale == 16 / 64)
        assert(recipe.localised_name[1] == "propertyrandomizer.recipe_planet_variant")
        assert(recipe.localised_name[2][1] == "propertyrandomizer-recipe-prefix." .. constants.funny_recipe_prefixes[1])
    end
    -- Recipes without a usable planet icon keep their number, including the original numbering order.
    local no_icon = data.raw.recipe["test-no-icon"].icons
    local plain = data.raw.recipe["test-plain"].icons
    assert(#no_icon == 2 and no_icon[2].icon == dupe.recipe_number_icon(2).icon)
    assert(#plain == 2 and plain[2].icon == dupe.recipe_number_icon(3).icon)
end)

print(num_passed .. " tests passed")
