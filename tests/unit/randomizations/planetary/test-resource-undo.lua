-- Plain-Lua regression test for which planets give back their resource swap changes (src/randomizations/planetary/resources.lua), not loaded by the mod
-- Run from the mod root: lua tests/unit/randomizations/planetary/test-resource-undo.lua
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
package.loaded["src/config/constants"] = {
    starting_planet = "home",
}
package.loaded["src/lib/random/rng"] = {}
package.loaded["src/prototypes/data-utils"] = {}
package.loaded["src/logic/state"] = {
    contexts = {},
    type_info = {},
}
-- The rock is only on the planets this names (check.node_specific_to_room)
local specific_to = {}
package.loaded["src/randomizations/planetary/check"] = {
    node_specific_to_room = function(before, node_key, planet_name)
        return specific_to[node_key] == planet_name
    end,
}
package.loaded["src/randomizations/planetary/locks"] = {}
package.loaded["src/randomizations/planetary/scaffolds"] = {}
package.loaded["src/prototypes/surfaces/surface-sets"] = {}

local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
local resources = require("src/randomizations/planetary/resources")
-- Contexts are numbers (src/logic/contexts/contexts.lua); the failures below write them as their names (tests/unit/logic/contexts/contexts-for-tests.lua)
local fx = require("tests/unit/logic/contexts/contexts-for-tests")

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

-- A planet's complex context, its abilities written as in context names, like "10"
local function context(planet_name, abilities)
    return fx.C(gutils.key("planet", planet_name) .. " | " .. abilities)
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
        -- Home set 1, named "home1" in logs
        context = top.home_context_key(context("beta", "00"), 1),
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
        context = fx.C(gutils.key("surface", "platform") .. " | 11"),
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

-- The originals step (resources.exclude_originals): a planet-locked original gives way on its planets with a variant too (user, 2026-10-14), and is left on no planet once all of them have one
local surface_sets = package.loaded["src/prototypes/surfaces/surface-sets"]
local locks = package.loaded["src/randomizations/planetary/locks"]
surface_sets.room_keys = function()
    return {
        "planet: home",
        "planet: vul",
        "planet: vul-2",
        "surface: platform",
    }
end
-- Test recipes list the rooms their own conditions accept
surface_sets.accepted = function(recipe)
    return recipe.accepts
end
local function fresh_locks()
    locks.fixed = {}
    locks.moved = {}
    locks.fix = function(kind, name, rooms)
        locks.fixed[kind .. "/" .. name] = {
            rooms = rooms,
        }
        return kind .. "/" .. name
    end
end
local function variant(recipe_name, planet_name)
    return {
        recipe_name = recipe_name,
        planet_name = planet_name,
        variant = {
            name = recipe_name .. "-on-" .. planet_name,
        },
    }
end
data.raw.recipe = {
    -- Works on Vulcanus and its copy alike, like acid neutralisation
    acid = {
        surface_conditions = {
            {
                property = "pressure",
                min = 4000,
                max = 4000,
            },
        },
        accepts = {
            ["planet: vul"] = true,
            ["planet: vul-2"] = true,
        },
    },
    plate = {},
    -- A duplicate's home lock is fixed already
    foundry = {
        surface_conditions = {
            {
                property = "pressure",
                min = 4000,
                max = 4000,
            },
        },
        accepts = {
            ["planet: vul"] = true,
        },
    },
}

-- Its technology unlocks it and its variants (resources.add_variant puts them beside it)
local function fresh_technologies()
    data.raw.technology = {
        calcite = {
            effects = {
                {
                    type = "unlock-recipe",
                    recipe = "acid",
                },
                {
                    type = "unlock-recipe",
                    recipe = "acid-on-vul",
                },
                {
                    type = "unlock-recipe",
                    recipe = "acid-on-vul-2",
                },
            },
        },
    }
end
local function unlocks_of(technology_name)
    local names = {}
    for _, effect in pairs(data.raw.technology[technology_name].effects) do
        table.insert(names, effect.recipe)
    end
    return table.concat(names, ",")
end

fresh_locks()
fresh_technologies()
local excluded = resources.exclude_originals({
    variant("acid", "vul"),
    variant("acid", "vul-2"),
})
check(#excluded == 1 and keys_of(excluded[1].planet_rooms) == "planet: vul,planet: vul-2", "acid gives way on both Vulcanus planets")
check(next(locks.fixed["recipe/acid"].rooms) == nil, "with every one of its planets having a variant, it's left on none (retired by locks.realize)")
local retired = resources.retire_originals(excluded)
check(table.concat(retired, ",") == "acid", "acid is retired: " .. table.concat(retired, ","))
check(unlocks_of("calcite") == "acid-on-vul,acid-on-vul-2", "a retired original is unlocked by nothing, and its variants still are: " .. unlocks_of("calcite"))

fresh_locks()
fresh_technologies()
excluded = resources.exclude_originals({
    variant("acid", "vul"),
})
check(keys_of(locks.fixed["recipe/acid"].rooms) == "planet: vul-2", "it stays on its own planet without a variant, and nowhere new: " .. keys_of(locks.fixed["recipe/acid"].rooms))
check(#resources.retire_originals(excluded) == 0 and unlocks_of("calcite") == "acid,acid-on-vul,acid-on-vul-2", "an original still on a planet isn't retired, and keeps its unlock: " .. unlocks_of("calcite"))

fresh_locks()
excluded = resources.exclude_originals({
    variant("plate", "vul"),
})
check(keys_of(locks.fixed["recipe/plate"].rooms) == "planet: home,planet: vul-2,surface: platform", "an original with no lock of its own stays everywhere else: " .. keys_of(locks.fixed["recipe/plate"].rooms))

fresh_locks()
locks.fixed["recipe/foundry"] = {
    rooms = {
        ["planet: vul"] = true,
    },
    movable = true,
}
excluded = resources.exclude_originals({
    variant("foundry", "vul"),
})
check(#excluded == 0 and locks.fixed["recipe/foundry"].rooms["planet: vul"], "an original with a fixed lock already keeps it")

print("test-resource-undo: " .. num_checks .. " checks passed")
