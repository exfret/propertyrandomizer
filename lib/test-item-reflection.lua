-- Plain-Lua regression tests for item reflection's placement rules in lib/data-utils.lua (not loaded by the mod)
-- Run from the mod root: lua lib/test-item-reflection.lua
-- First pass models the game that item reflection builds, so both use these rules: which mining results keep their names, and where useless items go

-- Stand-ins for the Factorio environment
defines = {
    prototypes = {
        item = {
            item = 0,
        },
    },
}
util = {
    parse_energy = function(energy)
        return tonumber(string.match(energy, "^[%d%.]+")) or 0
    end,
}
data = {
    raw = {
        lab = {},
        item = {},
    },
}

local dutils = require("lib/data-utils")

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
    local item_reflection = source("randomizations/graph/unified/handlers-new/item.lua")
    local first_pass = source("randomizations/graph/unified/first-pass-new.lua")
    assert(string.find(item_reflection, "dutils.reflected_item_position(", 1, true) ~= nil)
    assert(string.find(item_reflection, "dutils.mining_keeps_item_names(", 1, true) ~= nil)
    assert(string.find(first_pass, "dutils.realized_item_assignment(", 1, true) ~= nil)
    assert(string.find(first_pass, "dutils.mining_keeps_item_names(", 1, true) ~= nil)
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
    local recycling_sources = require("lib/logic/recycling-sources")
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
    for _, path in pairs({"randomizations/graph/unified/handlers-new/item.lua", "randomizations/graph/item.lua"}) do
        local text = source(path)
        assert(string.find(text, "dutils.recipe_main_product(", 1, true) ~= nil, path)
        assert(string.find(text, "results[1].name ==", 1, true) == nil, path .. " matches recipes by their first result")
        assert(string.find(text, "recycling_sources.named_after_ingredient(", 1, true) ~= nil, path .. " renames recycling recipes after a product")
    end
    assert(string.find(source("data-final-fixes.lua"), "randomizations.fix_recycling_names()", 1, true) ~= nil)
    -- The unified item handler names recipes once it can count how many are named after each item
    assert(string.find(source("randomizations/graph/unified/execute-new.lua"), "handler.after_changes()", 1, true) ~= nil)
end)

print(num_passed .. " tests passed")
