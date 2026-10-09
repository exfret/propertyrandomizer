-- Plain-Lua regression test for which planets give back their resource swap changes (randomizations/planetary/resources.lua), not loaded by the mod
-- Run from the mod root: lua randomizations/planetary/test-resource-undo.lua
--
-- When a resource swap still fails with every extra patch, only the planets the failures are on get their original recipes and technology triggers back (execute.lua's run_resources).
-- Taking every planet's changes back over one planet's failures left the user's seed 16 extra patches (2026-10-08): only Nauvis copy 2's grenade and plastic edits failed, since they now took an ore only a later drill mines.

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
config = {}
data = {
    raw = {
        technology = {},
    },
}
package.loaded["__core__/lualib/resource-autoplace"] = {}
package.loaded["helper-tables/constants"] = {
    starting_planet = "home",
}
package.loaded["lib/random/rng"] = {}
package.loaded["lib/data-utils"] = {}
package.loaded["lib/logic/state"] = {
    contexts = {},
    type_info = {},
}
-- The rock is only on the planets this names (check.node_specific_to_room)
local specific_to = {}
package.loaded["randomizations/planetary/check"] = {
    node_specific_to_room = function(before, node_key, planet_name)
        return specific_to[node_key] == planet_name
    end,
}
package.loaded["randomizations/planetary/locks"] = {}
package.loaded["randomizations/planetary/scaffolds"] = {}
package.loaded["lib/surface-sets"] = {}

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local resources = require("randomizations/planetary/resources")

local num_checks = 0
local function check(condition, message)
    num_checks = num_checks + 1
    if condition ~= true then
        error("test-resource-undo: " .. message)
    end
end
local function keys_of(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return table.concat(keys, ",")
end
local function names_of(list, field)
    local names = {}
    for _, entry in pairs(list) do
        table.insert(names, entry[field])
    end
    return table.concat(names, ",")
end

local function context(planet_name, abilities)
    return top.context_key(gutils.key("planet", planet_name), abilities)
end
local edits = {
    {
        planet_name = "alpha",
        recipe_name = "alpha-bomb",
    },
    {
        planet_name = "gamma",
        recipe_name = "gamma-brick",
    },
    {
        planet_name = "alpha",
        recipe_name = "alpha-plastic",
    },
}

-- 1. Failures point at the planet of their context, home contexts included, and an unreachable recipe at the planet whose edit changed it
local planets = resources.failing_planets({
    {
        text = "planet-locked alpha-bomb",
        keys = {
            gutils.key("recipe", "alpha-bomb"),
        },
        context = context("alpha", "10"),
    },
    {
        text = "mechanic on beta, at home",
        keys = {},
        context = top.home_context_key(context("beta", "00"), "home1"),
    },
    {
        text = "unreachable gamma-brick",
        keys = {
            gutils.key("recipe", "gamma-brick"),
        },
    },
}, edits)
check(keys_of(planets) == "alpha,beta,gamma", "expected alpha, beta and gamma, got " .. keys_of(planets))

-- 2. A failure on a room that isn't a planet, or an unreachable recipe no edit changed, points at no planet
planets = resources.failing_planets({
    {
        text = "on a platform",
        keys = {},
        context = top.context_key(gutils.key("surface", "platform"), "11"),
    },
    {
        text = "unreachable untouched",
        keys = {
            gutils.key("recipe", "untouched"),
        },
    },
}, edits)
check(next(planets) == nil, "expected no planet, got " .. keys_of(planets))

-- 3. Splitting by planet keeps each side's order
local on, rest = resources.split_by_planet(edits, {
    alpha = true,
})
check(names_of(on, "recipe_name") == "alpha-bomb,alpha-plastic", "wrong edits on alpha: " .. names_of(on, "recipe_name"))
check(names_of(rest, "recipe_name") == "gamma-brick", "wrong edits kept: " .. names_of(rest, "recipe_name"))

-- 4. A trigger edit serving several planets loses only the undone planet's replacement
data.raw.technology["rock-digging"] = {
    research_trigger = {
        type = "mine-entity",
        entities = {
            "rock",
        },
    },
}
local replacements = {
    alpha = {
        rock = "alpha-crystal",
    },
    beta = {
        rock = "beta-sand",
    },
}
local trigger_edits = resources.trigger_edits(replacements, {})
check(#trigger_edits == 1, "expected one trigger edit, got " .. #trigger_edits)
check(table.concat(trigger_edits[1].new_entities, ",") == "rock,alpha-crystal,beta-sand", "wrong trigger: " .. table.concat(trigger_edits[1].new_entities, ","))
check(table.concat(trigger_edits[1].planet_names, ",") == "alpha,beta", "wrong trigger planets: " .. table.concat(trigger_edits[1].planet_names, ","))
local variants = {
    {
        planet_name = "delta",
        recipe_name = "plate",
    },
}
check(keys_of(resources.changed_planets(edits, trigger_edits, variants)) == "alpha,beta,delta,gamma", "wrong changed planets: " .. keys_of(resources.changed_planets(edits, trigger_edits, variants)))
trigger_edits = resources.trigger_edits(resources.replacements_without(replacements, {
    alpha = true,
}), {})
check(#trigger_edits == 1 and table.concat(trigger_edits[1].new_entities, ",") == "rock,beta-sand", "beta's trigger edit should stay without alpha's replacement")
check(table.concat(trigger_edits[1].planet_names, ",") == "beta", "the trigger edit still lists alpha")

-- 5. A rock only alpha had is replaced in place, and goes back to the rock once alpha's changes are undone
specific_to[gutils.key("entity", "rock")] = "alpha"
trigger_edits = resources.trigger_edits({
    alpha = replacements.alpha,
}, {})
check(#trigger_edits == 1 and table.concat(trigger_edits[1].new_entities, ",") == "alpha-crystal", "alpha's own rock should be replaced in place")
trigger_edits = resources.trigger_edits(resources.replacements_without({
    alpha = replacements.alpha,
}, {
    alpha = true,
}), {})
check(#trigger_edits == 0, "no trigger edit should stay once alpha is undone")

print("test-resource-undo: " .. num_checks .. " checks passed")
