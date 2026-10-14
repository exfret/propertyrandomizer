-- Shared numerical/cost helpers may import legacy utilities without enabling legacy randomization.
package.loaded["__core__/lualib/collision-mask-util"] = {}
package.loaded["src/config/constants"] = {}
package.loaded["src/legacy/logic/dying-spawns"] = {}
package.loaded["src/prototypes/entities/wild-entities"] = {}
package.loaded["src/lib/random/rng"] = {}

data = {
    raw = {
        planet = {},
        recipe = {},
        resource = {},
        technology = {},
        fluid = {},
    },
}
defines = {
    prototypes = {
        entity = {},
        item = {},
    },
}
log = function(message)
    error("Import unexpectedly executed graph work: " .. message)
end

local build = require("src/legacy/logic/build-graph")
local compat = require("src/legacy/logic/build-graph-compat")
local sort = require("src/legacy/logic/top-sort")

assert(build.graph == nil, "Import built a dependency graph without a caller")
assert(dep_graph == nil, "Import installed a global dependency graph")
assert(build.key("item", "fixture") == "item:fixture")
local parts = {
    "one",
    "two",
}
assert(build.compound_key(parts) == "one_two")
assert(type(build.load) == "function")
assert(type(compat.load) == "function")
assert(type(sort.sort) == "function")
print("Legacy utility imports leave graph construction to their caller")
