-- Plain-Lua regression tests for items with several fuel categories (ItemPrototype::fuel_categories, 2.1.20) (not loaded by the mod)
-- Run from the mod root: lua lib/logic/test-fuel-categories.lua

-- The shared stage-2 header loads these, but the fuel lookups don't use them
package.preload["__core__/lualib/collision-mask-util"] = function()
    return {}
end
package.preload["lib/trigger"] = function()
    return {}
end
-- Factorio's util.parse_energy, enough for plain joule strings
util = {
    parse_energy = function(energy)
        local units = {
            [""] = 1,
            k = 1e3,
            M = 1e6,
            G = 1e9,
        }
        local number, prefix = string.match(energy, "^([%d%.]+)([kMG]?)J$")
        return tonumber(number) * units[prefix]
    end,
}

local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local lutils = require("lib/logic/logic-utils")
local fuel_lookups = require("lib/lookup/2-simple/fuel")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function lookups_for(items)
    local lu = {
        items = {},
        entities = {},
    }
    for _, item in pairs(items) do
        lu.items[item.name] = item
    end
    fuel_lookups.link(lu)
    fuel_lookups.fcat_to_items()
    fuel_lookups.burn_fcats()
    return lu
end

local plain = {
    name = "plain",
}
local fuel_plain = {
    name = "fuel-plain",
    fuel_value = "4MJ",
    fuel_categories = {"fcat-a"},
}
local fuel_burnt = {
    name = "fuel-burnt",
    fuel_value = "8GJ",
    fuel_categories = {"fcat-b"},
    burnt_result = "fuel-burnt-spent",
}
local multi = {
    name = "multi",
    fuel_value = "2MJ",
    fuel_categories = {
        "zeta",
        "alpha",
    },
    burnt_result = "fuel-multi-spent",
}

test("an item without fuel_categories has none", function()
    assert(#dutils.fuel_categories(plain) == 0)
    assert(not dutils.has_fuel_category(plain, "fcat-a"))
end)

test("an item is in each of its fuel categories", function()
    assert(dutils.has_fuel_category(multi, "zeta"))
    assert(dutils.has_fuel_category(multi, "alpha"))
    assert(not dutils.has_fuel_category(multi, "fcat-a"))
end)

test("a single-category item burns under that category's own name", function()
    assert(lutils.item_fcats_name(fuel_burnt) == "fcat-b")
end)

test("the burn name of several categories doesn't depend on their order", function()
    local reordered = {
        name = "reordered",
        fuel_categories = {
            "alpha",
            "zeta",
        },
    }
    assert(lutils.item_fcats_name(multi) == lutils.item_fcats_name(reordered))
    assert(lutils.item_fcats_name(multi) ~= "alpha" and lutils.item_fcats_name(multi) ~= "zeta")
    -- Naming doesn't reorder the prototype's own list
    assert(multi.fuel_categories[1] == "zeta")
end)

test("a fuel with several categories fuels burners of each", function()
    local lu = lookups_for({plain, fuel_plain, fuel_burnt, multi})
    local function fuels(fcat, burnt)
        return lu.fcat_to_items[gutils.concat({fcat, burnt})] or {}
    end
    assert(fuels("fcat-a", 0)["fuel-plain"])
    assert(fuels("fcat-b", 1)["fuel-burnt"])
    assert(fuels("zeta", 1).multi)
    assert(fuels("alpha", 1).multi)
    assert(not fuels("fcat-a", 0).plain)
end)

test("only burnable items with burnt results get burn categories, one per category set", function()
    local lu = lookups_for({plain, fuel_plain, fuel_burnt, multi})
    local multi_name = lutils.item_fcats_name(multi)
    assert(lu.burn_fcats["fcat-b"] ~= nil)
    assert(lu.burn_fcats[multi_name] ~= nil and #lu.burn_fcats[multi_name] == 2)
    assert(lu.burn_fcats["fcat-a"] == nil)
    assert(lu.vanilla_to_burn_fcats["alpha"][multi_name])
    assert(lu.vanilla_to_burn_fcats["zeta"][multi_name])
    assert(lu.vanilla_to_burn_fcats["fcat-b"]["fcat-b"])
end)

print(num_passed .. " tests passed")
