package.loaded["helper-tables/experimental-flags"] = {military_resistances = true}
-- Run from the mod root: lua lib/random/test-combat-adapters.lua
bit32 = {
    bxor = function(a, b) return (a ~ b) & 0xFFFFFFFF end,
    lshift = function(a, n) return (a << n) & 0xFFFFFFFF end,
    rshift = function(a, n) return (a & 0xFFFFFFFF) >> n end,
}
math.pow = math.pow or function(a, b) return a ^ b end
local sampled
package.loaded["lib/random/fleishman"] = {
    randomize_multiplicatively = function() return sampled end,
}
package.loaded["helper-tables/categories"] = {
    normal_item_classes = {},
    turrets = {},
    machine_energy_usage_keys = {},
    equipment_energy_usage_keys = {},
}
package.loaded["lib/data-utils"] = {}
package.loaded["lib/locale"] = { create_localised_description = function() end }
package.loaded["lib/trigger"] = {
    gather_ammo_structs = function(structs, ammo) structs["damage-parameters"] = ammo.packets end,
}
package.loaded["randomizations/helper/indirect"] = {}
package.loaded["lib/combat-resistances"] = {}
package.loaded["lib/prototype-exclusions"] = {}
config = {
    seed = 39,
    bias = 0,
    bias_idx = 2,
    chaos = 1,
    chaos_range = 1,
    numerical_algorithm = "fleishman",
}
data = { raw = {} }
defines = { prototypes = { entity = {} } }
randomizations = {}
util = {
    parse_energy = function(value)
        assert(type(value) == "string")
        local number, suffix = value:match("^(.-)([JW])$")
        assert(tonumber(number) ~= nil)
        return tonumber(number) / (suffix == "W" and 60 or 1)
    end,
}

package.loaded["lib/logic/combat-encounters"] = {definitions = function() return {} end}
local randnum = require("lib/random/randnum")
local randprob = require("lib/random/randprob")
local adapters = require("lib/random/combat-adapters")
local energy_randomizations = require("randomizations/helper/energy")
local item_randomizations = require("randomizations/numerical/item")
local entity_randomizations = require("randomizations/numerical/entity")

local passed = 0
local function test(name, check)
    local okay, reason = pcall(check)
    assert(okay, name .. ": " .. tostring(reason))
    passed = passed + 1
end

test("scalar reductions apply without a combat floor or rollback", function()
    local packet = { amount = 20 }
    sampled = 0.1
    randnum.rand({
        key = "test-direct",
        tbl = packet,
        property = "amount",
        rounding = "none",
    })
    assert(packet.amount == 0.1)
end)

test("probability sampling writes the final percentage directly", function()
    local row = { percent = 40 }
    sampled = 2
    local value = randprob.rand({
        key = "test-percent",
        tbl = row,
        property = "percent",
        probability_scale = 100,
        rounding = "none",
    })
    assert(math.abs(value - 400 / 7) < 1e-8 and row.percent == value)
end)

test("real gun cadence accepts the sampled speed without bounds probes", function()
    local gun = {
        name = "test-gun",
        type = "gun",
        attack_parameters = { cooldown = 30 },
    }
    data.raw.gun = { [gun.name] = gun }
    sampled = 0.1
    randomizations.gun_shooting_speed("test-gun-speed")
    assert(gun.attack_parameters.cooldown == 600)
end)

test("real ammo damage applies a shared factor once to aliased packets", function()
    local packet = { amount = 20 }
    local ammo = {
        name = "test-ammo",
        type = "ammo",
        packets = {
            packet,
            packet,
        },
    }
    data.raw.ammo = { [ammo.name] = ammo }
    sampled = 0.1
    randomizations.ammo_damage("test-ammo-damage")
    assert(packet.amount == 2)
end)

test("shared odds preserve each original percentage", function()
    local first, second = { value = 20 }, { value = 40 }
    local fields = adapters.fields({
        first,
        second,
        first,
    }, "value")
    local adapter = adapters.odds(fields, 100)
    adapter.apply(2)
    assert(#adapter.fields == 2)
    assert(math.abs(first.value - 100 / 3) < 1e-8)
    assert(math.abs(second.value - 400 / 7) < 1e-8)
end)

test("signed values retain their transform without combat rejection", function()
    local target = { healing_per_tick = -0.01 }
    local adapter = adapters.scaled(target, "healing_per_tick", -1 / 60)
    sampled = 0.1
    randnum.rand({
        key = "test-signed",
        dummy = adapter.read(),
        combat = adapter,
        rounding = "none",
    })
    assert(math.abs(target.healing_per_tick + 0.1 / 60) < 1e-10)
end)

test("energy helper retains the sampled cost instead of its original string", function()
    local source = {
        name = "test-energy-source",
        type = "test-source",
        cost = "60W",
    }
    sampled = 120
    randomizations.energy({
        id = "test-energy-helper",
        prototype = source,
        property = "cost",
        is_power = true,
        rounding = "none",
    })
    assert(source.cost == "120W")
end)

print("numerical combat transform tests passed: " .. passed)
