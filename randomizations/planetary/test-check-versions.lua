-- Plain-Lua regression test for the recipes that count as a recipe in the planetary checks (check.versions in randomizations/planetary/check.lua), not loaded by the mod
-- Run from the mod root: lua randomizations/planetary/test-check-versions.lua
--
-- A stage's variant of a recipe can get variants of its own from a later stage, and those count as the recipe too
-- Seed 0 with planet copies (2026-10-09): Vulcanus's acid neutralisation was the resource swap's planet variant, independent deposits then gave that variant versions taking Vulcanus's own deposits, and the check only looked at the variant, so most attempts lost acid neutralisation on Vulcanus

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
package.loaded["randomizations/graph/unified/skeleton/protection"] = {}
package.loaded["lib/random/rng"] = {}
data = {
    raw = {
        item = {},
        recipe = {},
    },
}

local check = require("randomizations/planetary/check")
local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
-- Contexts are numbers (lib/graph/contexts.lua); the fixtures write them as their names (lib/graph/contexts-for-tests.lua)
local fx = require("lib/graph/contexts-for-tests")
check.transported_mechanic_goals = function(before)
    return {}
end

local num_checks = 0
local function check_that(condition, message)
    num_checks = num_checks + 1
    if not condition then
        error(message, 2)
    end
end

-- The resource swap's planet variants of acid neutralisation, and independent deposits' versions of the Vulcanus one
local variants_of = {
    ["acid-neutralisation"] = {
        "acid-neutralisation-on-vulcanus",
        "acid-neutralisation-on-vulcanus-copy",
    },
    ["acid-neutralisation-on-vulcanus"] = {
        "acid-neutralisation-on-vulcanus-deposits-on-vulcanus",
        "acid-neutralisation-on-vulcanus-deposits-2-on-vulcanus",
    },
}

local versions = check.versions(variants_of, "acid-neutralisation")
check_that(#versions == 4, "the two variants and the two versions of one of them count, not " .. #versions)
check_that(versions[1] == "acid-neutralisation-on-vulcanus" and versions[2] == "acid-neutralisation-on-vulcanus-copy", "sorted by name: " .. table.concat(versions, ", "))
check_that(versions[3] == "acid-neutralisation-on-vulcanus-deposits-2-on-vulcanus" and versions[4] == "acid-neutralisation-on-vulcanus-deposits-on-vulcanus", "the versions of a variant count too: " .. table.concat(versions, ", "))
check_that(#check.versions(variants_of, "acid-neutralisation-on-vulcanus") == 2, "a variant's own versions don't include the recipe it's a variant of")
check_that(#check.versions(variants_of, "steam-condensation") == 0 and #check.versions(nil, "acid-neutralisation") == 0, "a recipe without variants has none")
local looped = check.versions({
    a = {
        "b",
    },
    b = {
        "a",
        "c",
    },
}, "a")
check_that(#looped == 2 and looped[1] == "b" and looped[2] == "c", "a loop ends, and the recipe itself never counts as its own version: " .. table.concat(looped, ", "))

-- Rule 2 of check.required: acid neutralisation was isolatable and automatable on Vulcanus before the planetary changes, and afterwards only the deposits' version of its Vulcanus variant is
local vulcanus_11 = fx.C(gutils.key("planet", "vulcanus") .. " | 11")
local vulcanus_01 = fx.C(gutils.key("planet", "vulcanus") .. " | 01")
local acid_key = gutils.key("recipe", "acid-neutralisation")
local function node(name)
    return {
        type = "recipe",
        name = name,
    }
end
local before = {
    graph = {
        nodes = {
            [acid_key] = node("acid-neutralisation"),
        },
    },
    sort_info = {
        node_to_context_inds = {
            [acid_key] = {
                [vulcanus_11] = 1,
            },
        },
    },
    planet_locked = {
        [acid_key] = {
            [vulcanus_11] = true,
        },
    },
}
local after = {
    graph = {
        nodes = {
            [acid_key] = node("acid-neutralisation"),
            [gutils.key("recipe", "acid-neutralisation-on-vulcanus")] = node("acid-neutralisation-on-vulcanus"),
            [gutils.key("recipe", "acid-neutralisation-on-vulcanus-deposits-on-vulcanus")] = node("acid-neutralisation-on-vulcanus-deposits-on-vulcanus"),
        },
    },
    sort_info = {
        node_to_context_inds = {
            -- The variant takes the materials the deposits' copies stand in for, so Vulcanus has it only with imports
            [gutils.key("recipe", "acid-neutralisation-on-vulcanus")] = {
                [vulcanus_01] = 3,
            },
            [gutils.key("recipe", "acid-neutralisation-on-vulcanus-deposits-on-vulcanus")] = {
                [vulcanus_11] = 2,
            },
        },
    },
}
local function lost_goals(variants)
    local texts = {}
    for _, failure in pairs(check.required_failures(before, after, variants)) do
        table.insert(texts, failure.text)
    end
    return texts
end
local lost = lost_goals(variants_of)
check_that(#lost == 0, "the deposits' version of the Vulcanus variant keeps the goal: " .. table.concat(lost, "; "))
local without_deposits = {
    ["acid-neutralisation"] = variants_of["acid-neutralisation"],
}
lost = lost_goals(without_deposits)
check_that(#lost == 1 and lost[1] == "planet-locked " .. acid_key .. " @ " .. top.context_name(vulcanus_11), "without that version the goal is lost: " .. table.concat(lost, "; "))

print("test-check-versions: " .. num_checks .. " checks passed")
