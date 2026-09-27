-- Plain-Lua regression tests for how logic models spoiling (not loaded by the mod)
-- Run from the mod root: lua lib/logic/test-spoiling.lua
-- Logic only delivers items that last a trip to another room (dutils.survives_trip in lib/data-utils.lua), and randomizations never make an item stop lasting one, so all of them use that one helper
-- Spoiling itself is just waiting, so it keeps the spoiling item's abilities

-- Stand-ins for the Factorio environment
defines = {
    prototypes = {
        item = {
            item = 0,
        },
    },
}
data = {
    raw = {
        item = {},
    },
}

local constants = require("helper-tables/constants")
local dutils = require("lib/data-utils")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local minute = 60 * 60

-- An item that spoils after spoil_ticks (nil for one that doesn't spoil)
local function item_with(spoil_ticks)
    return {
        type = "item",
        name = "test-item",
        spoil_ticks = spoil_ticks,
    }
end

test("an item that doesn't spoil survives a trip", function()
    assert(dutils.survives_trip(item_with(nil)))
    -- The game's default spoil time is 0, which means not spoiling
    assert(dutils.survives_trip(item_with(0)))
end)

test("an item survives a trip exactly when it lasts at least constants.spoil_trip_ticks", function()
    assert(dutils.survives_trip(item_with(constants.spoil_trip_ticks)))
    assert(dutils.survives_trip(item_with(constants.spoil_trip_ticks + 1)))
    assert(not dutils.survives_trip(item_with(constants.spoil_trip_ticks - 1)))
    assert(not dutils.survives_trip(item_with(1)))
end)

test("the trip line splits vanilla spoil times where the constant's comment says", function()
    -- Space Age's spoil times in minutes (data/space-age/prototypes/item.lua, raw fish in data/space-age/base-data-updates.lua)
    local short_spoil_minutes = {
        1, -- Bacteria
        3, -- Yumako mash
        4, -- Jelly
        5, -- Nutrients
        15, -- Pentapod egg
    }
    local long_spoil_minutes = {
        30, -- Biter egg, captive biter spawner
        60, -- Yumako, jellynut, agricultural science pack
        120, -- Bioflux
        453000 / minute, -- Raw fish
    }
    for _, spoil_minutes in pairs(short_spoil_minutes) do
        assert(not dutils.survives_trip(item_with(spoil_minutes * minute)), spoil_minutes)
    end
    for _, spoil_minutes in pairs(long_spoil_minutes) do
        assert(dutils.survives_trip(item_with(spoil_minutes * minute)), spoil_minutes)
    end
end)

test("logic and numerical spoil time randomization both use the helper", function()
    local function source(path)
        local handle = assert(io.open(path, "r"))
        local text = handle:read("*a")
        handle:close()
        return text
    end
    -- Delivery (the item-deliver node and the context cycling edge from it)
    local _, num_logic_uses = string.gsub(source("lib/logic/concrete.lua"), "dutils%.survives_trip%(item%)", "")
    assert(num_logic_uses == 2, "concrete.lua should gate both delivery pieces on dutils.survives_trip")
    assert(string.find(source("randomizations/numerical/item.lua"), "dutils.survives_trip(item)", 1, true) ~= nil)
end)

test("spoil edges keep the spoiling item's abilities, since waiting takes no player input", function()
    local handle = assert(io.open("lib/logic/concrete.lua", "r"))
    local text = handle:read("*a")
    handle:close()
    local start = string.find(text, "-- Edge from items that spoil into this item", 1, true)
    local stop = string.find(text, "-- Edge from fuels that burn into this item", 1, true)
    assert(start ~= nil and stop ~= nil and start < stop, "couldn't find the spoil edge in concrete.lua")
    local spoil_edge = string.sub(text, start, stop - 1)
    assert(string.find(spoil_edge, "spoils_into = true", 1, true) ~= nil)
    assert(string.find(spoil_edge, "abilities =", 1, true) == nil, "a spoil edge that sets abilities would stop spoiling from carrying automatability")
end)

print(num_passed .. " tests passed")
