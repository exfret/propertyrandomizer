-- lua lib/cost/test-loot-amounts.lua
-- Loot uses ItemProductPrototype quantities and probabilities (Factorio 2.1 docs).
mods = {}
package.loaded["__core__/lualib/collision-mask-util"] = {}
package.loaded["lib/trigger"] = {}
local stage = require("lib/lookup/2-simple/entity-property")

local lu = {
    entities = {
        {
            name = "fixed-source",
            loot = {
                { type = "item", name = "drop", amount = 9 },
            },
        },
        {
            name = "ranged-source",
            loot = {
                { type = "item", name = "drop", amount_min = 1, amount_max = 3 },
            },
        },
        {
            name = "mixed-source",
            loot = {
                { type = "item", name = "drop", amount = 4, independent_probability = 0.5 },
                { type = "item", name = "drop", amount_min = 2, amount_max = 6, independent_probability = 0.5, shared_probability = { min = 0.25, max = 0.75 } },
                { type = "item", name = "fractional", amount = 1, extra_count_fraction = 0.5, independent_probability = 0.5 },
                { type = "item", name = "never", amount = 10, independent_probability = 0 },
                { type = "item", name = "empty", amount = 0 },
            },
        },
        { name = "no-loot" },
    },
}
stage.link(lu)
stage.loot_to_entities()
assert(lu.loot_to_entities.drop["fixed-source"] == 9)
assert(lu.loot_to_entities.drop["ranged-source"] == 2)
assert(lu.loot_to_entities.drop["mixed-source"] == 3)
assert(lu.loot_to_entities.fractional["mixed-source"] == 0.75)
assert(lu.loot_to_entities.never == nil)
assert(lu.loot_to_entities.empty == nil)
assert(lu.loot_to_entities.drop["no-loot"] == nil)
print("ok - fixed, ranged, probabilistic and duplicate loot quantities; zero yields excluded")
