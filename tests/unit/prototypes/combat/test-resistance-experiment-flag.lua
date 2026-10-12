-- Run from the mod root: lua tests/unit/prototypes/combat/test-resistance-experiment-flag.lua
local flags = require("src/config/experimental-flags")
assert(flags.military_resistances == false, "The parked experiment must default to off")
settings = {startup = {}}
for _, name in pairs({
    "propertyrandomizer-unified-preview",
    "propertyrandomizer-dev-unified",
    "propertyrandomizer-unified-damage-types",
}) do
    settings.startup[name] = {value = true}
end
local features = require("src/config/feature-flags")
assert(features.damage_types == false, "Preview and startup settings cannot enable the parked graph handler")
flags.military_resistances = true
package.loaded["src/config/feature-flags"] = nil
features = require("src/config/feature-flags")
assert(features.damage_types == true, "Enabling both flags should enable the graph handler")
settings.startup["propertyrandomizer-unified-damage-types"].value = false
package.loaded["src/config/feature-flags"] = nil
features = require("src/config/feature-flags")
assert(features.damage_types == false, "The startup switch must also be enabled")
flags.military_resistances = false
local spec = require("src/config/spec")
assert(spec.resistances == nil, "Military More must not schedule the parked magnitude pass")

local resistances = require("src/prototypes/combat/combat-resistances")
local function forbidden() error("Disabled experiment executed") end
local inaccessible = setmetatable({}, { __pairs = forbidden, __index = forbidden })
assert(next(resistances.collect(inaccessible, inaccessible, forbidden, inaccessible)) == nil)
assert(next(resistances.target_set(inaccessible, inaccessible, inaccessible)) == nil)
local partition = resistances.partition(inaccessible, inaccessible)
assert(#partition.sensitive == 0 and #partition.ordinary == 0)
assert(resistances.attempt_batch(inaccessible, forbidden, forbidden) == false)
assert(resistances.attempt(inaccessible, inaccessible, forbidden, forbidden) == false)

-- Deliberately unusable experimental implementations must never be installed while disabled.
package.loaded["src/lib/random/experimental/randnum"] = { rand = forbidden }
package.loaded["src/lib/random/experimental/randprob"] = { rand = forbidden }
package.loaded["src/randomizations/experimental/numerical/entity"] = inaccessible
package.loaded["src/randomizations/experimental/numerical/item"] = inaccessible
package.loaded["src/randomizations/experimental/numerical/equipment"] = inaccessible
package.loaded["src/randomizations/experimental/helper/energy"] = inaccessible
package.loaded["src/randomizations/experimental/helper/trigger"] = inaccessible
bit32 = {
    bxor = function(a, b) return (a ~ b) & 0xFFFFFFFF end,
    lshift = function(a, n) return (a << n) & 0xFFFFFFFF end,
    rshift = function(a, n) return (a & 0xFFFFFFFF) >> n end,
}
math.pow = math.pow or function(a, b) return a ^ b end
package.loaded["src/lib/random/fleishman"] = { randomize_multiplicatively = function() return 2 end }
package.loaded["src/prototypes/categories"] = { normal_item_classes = {} }
package.loaded["src/prototypes/data-utils"] = {}
package.loaded["src/localisation/locale"] = { create_localised_description = function() end }
package.loaded["src/prototypes/entities/trigger"] = {
    gather_ammo_structs = function(structs, ammo) structs["damage-parameters"] = ammo.packets end,
}
package.loaded["src/randomizations/helpers/indirect"] = {}
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
local randnum = require("src/lib/random/randnum")
local randprob = require("src/lib/random/randprob")
local entity = require("src/randomizations/numerical/entity")
local item = require("src/randomizations/numerical/item")
local equipment = require("src/randomizations/numerical/equipment")
local energy = require("src/randomizations/helpers/energy")
local trigger = require("src/randomizations/helpers/trigger")
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
package.loaded["src/config/spec"] = nil
local enabled_spec = require("src/config/spec")
assert(enabled_spec.resistances ~= nil)
local installed = false
package.loaded["src/randomizations/experimental/numerical/item"] = {
    ammo_damage = function() installed = true end,
}
package.loaded["src/randomizations/numerical/item"] = nil
local enabled_item = require("src/randomizations/numerical/item")
randomizations.ammo_damage("test-enabled")
assert(installed)
print("ok - experiment defaults off; samplers and numerical routines retain original behavior; resistance helper is inert")
