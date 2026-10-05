-- Run from the mod root: lua lib/test-resistance-experiment-flag.lua
local flags = require("helper-tables/experimental-flags")
assert(flags.military_resistances == false, "The parked experiment must default to off")
local spec = require("helper-tables/spec")
assert(spec.resistances == nil, "Military More must not schedule the parked magnitude pass")

local resistances = require("lib/combat-resistances")
local function forbidden() error("Disabled experiment executed") end
local inaccessible = setmetatable({}, { __pairs = forbidden, __index = forbidden })
assert(next(resistances.collect(inaccessible, inaccessible, forbidden, inaccessible)) == nil)
assert(next(resistances.target_set(inaccessible, inaccessible, inaccessible)) == nil)
local partition = resistances.partition(inaccessible, inaccessible)
assert(#partition.sensitive == 0 and #partition.ordinary == 0)
assert(resistances.attempt_batch(inaccessible, forbidden, forbidden) == false)
assert(resistances.attempt(inaccessible, inaccessible, forbidden, forbidden) == false)

-- Deliberately unusable experimental implementations must never be installed while disabled.
package.loaded["lib/random/experimental/randnum"] = { rand = forbidden }
package.loaded["lib/random/experimental/randprob"] = { rand = forbidden }
package.loaded["randomizations/experimental/numerical/entity"] = inaccessible
package.loaded["randomizations/experimental/numerical/item"] = inaccessible
package.loaded["randomizations/experimental/numerical/equipment"] = inaccessible
package.loaded["randomizations/experimental/helper/energy"] = inaccessible
package.loaded["randomizations/experimental/helper/trigger"] = inaccessible
bit32 = {
    bxor = function(a, b) return (a ~ b) & 0xFFFFFFFF end,
    lshift = function(a, n) return (a << n) & 0xFFFFFFFF end,
    rshift = function(a, n) return (a & 0xFFFFFFFF) >> n end,
}
math.pow = math.pow or function(a, b) return a ^ b end
package.loaded["lib/random/fleishman"] = { randomize_multiplicatively = function() return 2 end }
package.loaded["helper-tables/categories"] = { normal_item_classes = {} }
package.loaded["lib/data-utils"] = {}
package.loaded["lib/locale"] = { create_localised_description = function() end }
package.loaded["lib/trigger"] = {
    gather_ammo_structs = function(structs, ammo) structs["damage-parameters"] = ammo.packets end,
}
package.loaded["randomizations/helper/indirect"] = {}
config = {
    seed = 39,
    bias = 0,
    bias_idx = 2,
    chaos = 1,
    chaos_range = 1,
    numerical_algorithm = "fleishman",
}
defines = { prototypes = { entity = {} } }
data = { raw = {} }
randomizations = {}
local randnum = require("lib/random/randnum")
local randprob = require("lib/random/randprob")
local entity = require("randomizations/numerical/entity")
local item = require("randomizations/numerical/item")
local equipment = require("randomizations/numerical/equipment")
local energy = require("randomizations/helper/energy")
local trigger = require("randomizations/helper/trigger")
assert(randnum.write == nil, "Experimental adapter dispatch leaked into the default sampler")
local target = { value = 10 }
randnum.rand({
    key = "test-flag-off",
    tbl = target,
    property = "value",
    rounding = "none",
})
assert(target.value == 2)

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
randomizations.ammo_damage("test-original-ammo")
assert(packet.amount > 60, "The original per-reference writes must not use experimental deduplication")

flags.military_resistances = true
package.loaded["helper-tables/spec"] = nil
local enabled_spec = require("helper-tables/spec")
assert(enabled_spec.resistances ~= nil)
local installed = false
package.loaded["randomizations/experimental/numerical/item"] = {
    ammo_damage = function() installed = true end,
}
package.loaded["randomizations/numerical/item"] = nil
local enabled_item = require("randomizations/numerical/item")
randomizations.ammo_damage("test-enabled")
assert(installed)
print("ok - experiment defaults off; samplers and numerical routines retain original behavior; resistance helper is inert")
