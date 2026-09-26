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

print(num_passed .. " tests passed")
