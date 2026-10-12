-- Run from the mod root: lua tests/unit/logic/builders/test-resistance-groups.lua
package.preload["__core__/lualib/collision-mask-util"] = function() return {} end
package.preload["src/prototypes/entities/trigger"] = function() return {} end

local combat = require("src/prototypes/lookup/2-simple/combat")
local gutils = require("src/lib/graph/graph-utils")

local function entity(name, resistances)
    return {
        name = name,
        type = "unit",
        resistances = resistances,
    }
end

local lu = {
    entities = {
        first = entity("first", {
            {
                type = "test-second",
                percent = 100,
            },
            {
                type = "test-first",
                percent = 100,
            },
        }),
        same = entity("same", {
            {
                type = "test-first",
                percent = 100,
            },
            {
                type = "test-second",
                percent = 100,
            },
        }),
        partial = entity("partial", {
            {
                type = "test-first",
                percent = 99,
            },
        }),
        plain = entity("plain"),
    },
}
combat.link(lu)
combat.entity_resistance_groups()
local groups = lu.entity_resistance_groups
local immune = gutils.concat({
    "test-first",
    "test-second",
})
local ordinary = gutils.concat({})
assert(groups.to_resistance.first == immune)
assert(groups.to_resistance.same == immune)
assert(groups.to_entity[immune].first and groups.to_entity[immune].same)
assert(groups.groups[immune]["test-first"] and groups.groups[immune]["test-second"])
assert(groups.to_resistance.partial == ordinary and groups.to_resistance.plain == ordinary)
assert(next(groups.groups[ordinary]) == nil)
print("ok - percent immunities group deterministically; partial resistance remains nonimmune")
