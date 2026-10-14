-- Plain-Lua regression test for the failures a planetary change caused (check.caused_failures in src/randomizations/planetary/check.lua), not loaded by the mod
-- Run from the mod root: lua tests/unit/randomizations/planetary/test-caused-failures.lua
--
-- User's load, 2026-10-13: the resource stage tried to have planet variants replace their originals while a Nauvis copy's own coal recipes were failing for another reason, which every original back couldn't fix
-- That failure made it give every original back on every planet, so none of the 42 variants replaced its original; a fallback answers only for what its own change broke
-- Stand-ins for the Factorio environment
function table.deepcopy(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end
function log(msg) end
serpent = {
    block = tostring,
    line = tostring,
}
settings = {
    startup = {},
}
mods = {}
defines = {
    prototypes = {
        item = {
            item = 0,
        },
        entity = {},
    },
}
-- Nothing here is random (the generator needs Factorio's bit32), and the mechanic goals (rule 3) aren't what this tests
package.loaded["src/randomizations/unified/skeleton/protection"] = {}
package.loaded["src/lib/random/rng"] = {}
data = {
    raw = {
        item = {},
        recipe = {},
    },
}

local check = require("src/randomizations/planetary/check")

local num_checks = 0
local function check_that(condition, message)
    num_checks = num_checks + 1
    if condition ~= true then
        error(message, 2)
    end
end

local function failure(text)
    return {
        text = text,
        keys = {},
    }
end

-- The Nauvis copy's carbon fails with or without the originals; leaving iron plate's original out on Gleba breaks Gleba's steel
local with_exclusions = {
    failure("planet-locked recipe: carbon-on-nauvis-2 @ planet: nauvis-2 | 11"),
    failure("planet-locked recipe: steel-on-gleba @ planet: gleba | 11"),
}
local with_every_original = {
    failure("planet-locked recipe: carbon-on-nauvis-2 @ planet: nauvis-2 | 11"),
}
local caused = check.caused_failures(with_exclusions, with_every_original)
check_that(#caused == 1 and caused[1].text == "planet-locked recipe: steel-on-gleba @ planet: gleba | 11", "only Gleba's steel is the exclusions' doing")
check_that(#check.caused_failures(with_every_original, with_every_original) == 0, "a failure that was there without the change isn't the change's")
check_that(#check.caused_failures(with_exclusions, {}) == 2, "with nothing failing before, every failure is the change's")
check_that(#check.caused_failures({}, with_every_original) == 0, "nothing failing now means nothing caused")

print(num_checks .. " checks passed")
