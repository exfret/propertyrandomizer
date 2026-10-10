-- Plain-Lua regression test for the ocean scaffolds' planet variants (randomizations/planetary/scaffolds.lua), not loaded by the mod
-- Run from the mod root: lua randomizations/planetary/test-scaffolds.lua
--
-- Planets given the same ocean change (a planet and its copies all getting water for lava) each need their own variants and conversion.
-- Their names used to leave the planet out, so those planets shared one prototype, and since locks.fix replaces a lock, it was makeable on only one of them.
-- The others failed the check and kept a conversion each: the user's game (2026-10-01) kept 8 conversions, all on planets that shared their swap.

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
local logged = {}
function log(msg)
    table.insert(logged, msg)
end
serpent = {
    block = tostring,
    line = tostring,
}
settings = {
    startup = {},
}
mods = {}

-- The game: a lava-like planet with a copy, and a lake planet; a copy has a name of its own (lib/planet-names.lua)
-- Prototypes are made through prototype() with made-up names, so the fixtures hardcode no vanilla names (dev/hardcoded-names.py)
data = {
    raw = {},
    extend = function(self, prototypes)
        for _, prototype in pairs(prototypes) do
            self.raw[prototype.type] = self.raw[prototype.type] or {}
            self.raw[prototype.type][prototype.name] = prototype
        end
    end,
}
local function prototype(kind, name, fields)
    fields.type = kind
    fields.name = name
    data:extend({
        fields,
    })
    return fields
end
data.raw.item = {}
prototype("planet", "ember", {
    icon = "__test__/ember.png",
    icon_size = 64,
})
prototype("planet", "ember-exfret-2-copy", {
    icon = "__test__/ember-2.png",
    icon_size = 64,
    localised_name = "Embra",
})
prototype("planet", "lake", {
    icon = "__test__/lake.png",
    icon_size = 64,
})
prototype("fluid", "magma", {
    icon = "__test__/magma.png",
    icon_size = 64,
})
prototype("fluid", "lakewater", {
    icon = "__test__/lakewater.png",
    icon_size = 64,
})
prototype("recipe", "molten-ore", {
    icon = "__test__/molten-ore.png",
    icon_size = 64,
    ingredients = {
        {
            type = "fluid",
            name = "magma",
            amount = 500,
        },
        {
            type = "item",
            name = "grit",
            amount = 1,
        },
    },
    results = {
        {
            type = "fluid",
            name = "molten-metal",
            amount = 250,
        },
    },
})
for _, planet_name in pairs({
    "ember",
    "ember-exfret-2-copy",
    "lake",
}) do
    prototype("technology", "planet-discovery-" .. planet_name, {}).effects = {}
end
local ore_melting = prototype("technology", "ore-melting", {})
ore_melting.effects = {}
table.insert(ore_melting.effects, {
    type = "unlock-recipe",
    recipe = "molten-ore",
})

package.loaded["lib/data-utils"] = {
    get_prot = function(_, name)
        return data.raw.item[name]
    end,
}
-- Contexts are numbers (lib/graph/contexts.lua); fixtures write them as their names (lib/graph/contexts-for-tests.lua)
local ctx = require("lib/graph/contexts")
local C = require("lib/graph/contexts-for-tests").C
package.loaded["lib/graph/context-sort"] = {
    ISOLATABILITY = ctx.ISOLATABILITY,
    context_room = ctx.room,
    context_mask = ctx.mask,
    has_ability = ctx.has_ability,
}
package.loaded["randomizations/planetary/check"] = {}
-- Locks as the scaffolds use them: fix replaces a target's rooms, unfix forgets them
local fixed = {}
package.loaded["randomizations/planetary/locks"] = {
    fix = function(kind, name, rooms)
        fixed[kind .. "/" .. name] = rooms
    end,
    unfix = function(kind, name)
        fixed[kind .. "/" .. name] = nil
    end,
    realize = function() end,
}

local scaffolds = require("randomizations/planetary/scaffolds")

local num_checks = 0
local function check(condition, message)
    num_checks = num_checks + 1
    if condition ~= true then
        error("test-scaffolds: " .. message)
    end
end

local function count(tbl)
    local n = 0
    for _, _ in pairs(tbl or {}) do
        n = n + 1
    end
    return n
end

local function ends_with(text, suffix)
    return string.sub(text, -#suffix) == suffix
end

-- Both embers get the lake's water, and the lake gets magma
local oceans = {
    families = {
        ember = {
            fluid = "magma",
        },
        ["ember-exfret-2-copy"] = {
            fluid = "magma",
        },
        lake = {
            fluid = "lakewater",
        },
    },
    planet_order = {
        "ember",
        "ember-exfret-2-copy",
        "lake",
    },
}
local assignment = {
    ember = "lake",
    ["ember-exfret-2-copy"] = "lake",
    lake = "ember",
}
-- Both embers made molten ore before the swap
local before = {
    sort_info = {
        node_to_context_inds = {
            ["recipe: molten-ore"] = {
                [C("planet: ember | 11")] = 1,
                [C("planet: ember-exfret-2-copy | 11")] = 2,
            },
        },
    },
}

-- 1. Each planet's candidates are its own: no two share a name, and every name ends with its planet's
local candidates = scaffolds.candidates(assignment, oceans, before)
local by_planet = {}
local names = {}
for _, candidate in pairs(candidates) do
    by_planet[candidate.planet .. "/" .. candidate.kind] = candidate
    check(names[candidate.recipe_name] == nil, "two candidates share the name " .. candidate.recipe_name)
    names[candidate.recipe_name] = true
    check(ends_with(candidate.recipe_name, "-on-" .. candidate.planet), candidate.recipe_name .. " doesn't end with its planet " .. candidate.planet)
end
local ember_variant = by_planet["ember/variant"]
local copy_variant = by_planet["ember-exfret-2-copy/variant"]
local ember_conversion = by_planet["ember/conversion"]
local copy_conversion = by_planet["ember-exfret-2-copy/conversion"]
check(ember_variant ~= nil and copy_variant ~= nil, "each ember gets its own variant of molten-ore")
check(ember_conversion ~= nil and copy_conversion ~= nil, "each ember gets its own conversion")
check(by_planet["lake/conversion"] ~= nil and by_planet["lake/variant"] == nil, "the lake, which made nothing from water, only gets a conversion")
local takes = {}
for _, ingredient in pairs(copy_variant.prototypes[1].ingredients) do
    takes[ingredient.name] = true
end
check(takes.lakewater == true and takes.magma == nil, "the variant takes lake water instead of magma")

-- 2. With every candidate in the game, each is makeable on its own planet only
for _, candidate in pairs(candidates) do
    scaffolds.add(candidate)
end
for _, candidate in pairs(candidates) do
    check(data.raw.recipe[candidate.recipe_name] ~= nil, candidate.recipe_name .. " isn't in the game")
    local rooms = fixed["recipe/" .. candidate.recipe_name]
    check(rooms ~= nil and rooms["planet: " .. candidate.planet] == true and count(rooms) == 1, candidate.recipe_name .. " isn't locked to exactly " .. candidate.planet)
end

-- 3. Taking one planet's variant out leaves the other planet's variant, its lock and its unlock
scaffolds.remove(ember_variant)
check(data.raw.recipe[ember_variant.recipe_name] == nil, "the removed variant is still in the game")
check(fixed["recipe/" .. ember_variant.recipe_name] == nil, "the removed variant is still locked")
check(data.raw.recipe[copy_variant.recipe_name] ~= nil, "removing ember's variant removed the copy's")
check(fixed["recipe/" .. copy_variant.recipe_name] ~= nil, "removing ember's variant removed the copy's lock")
local unlocked = {}
for _, effect in pairs(ore_melting.effects) do
    unlocked[effect.recipe] = true
end
check(unlocked[copy_variant.recipe_name] == true and unlocked[ember_variant.recipe_name] == nil, "the unlocks don't follow the variants")

-- 4. A conversion shows its planet like the variants do: "Magma from lake water (Embra)", with the planet's icon as a badge
-- The name is the planet-variant locale key (scaffolds.variant_name), whose second parameter is the planet's label
local conversion = data.raw.recipe[copy_conversion.recipe_name]
check(conversion.localised_name[1] == "propertyrandomizer-name.planet-variant" and conversion.localised_name[3] == "Embra", "the copy's conversion isn't named after its planet")
check(conversion.icons ~= nil and conversion.icons[#conversion.icons].icon == "__test__/ember-2.png", "the copy's conversion doesn't have its planet's badge")
check(conversion.icons[1].icon == "__test__/magma.png", "the conversion's icon isn't the fluid it makes")
-- The badge is in the top right corner, and the conversion says whose badge it wears, so item randomization's renames keep it (lib/recipe-renames.lua)
local conversion_badge = conversion.icons[#conversion.icons]
check(conversion_badge.shift[1] > 0 and conversion_badge.shift[2] < 0, "the planet's badge isn't in the top right corner")
check(conversion.planet_badge == "ember-exfret-2-copy", "the copy's conversion doesn't say it wears its planet's badge")

-- 5. Forgetting the kept candidates forgets their locks (execute puts data.raw back, and locks.fixed would keep them otherwise)
scaffolds.kept = {
    copy_conversion,
}
scaffolds.forget()
check(fixed["recipe/" .. copy_conversion.recipe_name] == nil and count(scaffolds.kept) == 0, "forget left the kept conversion's lock")

-- 6. The count at the end of planetary randomization counts the conversions the game still has
scaffolds.remove(ember_conversion)
logged = {}
scaffolds.log_conversions()
local line
for _, msg in pairs(logged) do
    if string.find(msg, "PLANETCHECK conversions: ", 1, true) == 1 then
        line = msg
    end
end
check(line ~= nil and string.find(line, "PLANETCHECK conversions: 2 in the game (at most 1): ", 1, true) == 1, "log_conversions counted wrong: " .. tostring(line))
-- A planet's name can start another's (ember, ember-exfret-2-copy), so the listed names are compared whole
local listed = {}
for name in string.gmatch(string.match(line, "%(at most 1%): (.*)$"), "[^, ]+") do
    listed[name] = true
end
check(listed[copy_conversion.recipe_name] == true and listed[by_planet["lake/conversion"].recipe_name] == true and listed[ember_conversion.recipe_name] == nil, "log_conversions listed the wrong conversions: " .. line)

-- 7. A variant of a recipe that's already the planet's own names the planet once (user, 2026-10-10: independent deposits' variants of Vulcanus's own tungsten carbide were "Tungsten carbide (Vulcanus) (Vulcanus)")
-- How many times a localised string has the text in it, at any depth
local function count_text(str, text)
    if str == text then
        return 1
    end
    local n = 0
    if type(str) == "table" then
        for _, part in pairs(str) do
            n = n + count_text(part, text)
        end
    end
    return n
end
local copy_recipe = data.raw.recipe[copy_variant.recipe_name]
check(copy_recipe.intermediate_planet == "ember-exfret-2-copy", "the copy's variant doesn't say which planet its name has")
local same_planet = table.deepcopy(copy_recipe)
scaffolds.name_variant(same_planet, copy_recipe, "ember-exfret-2-copy")
check(count_text(same_planet.localised_name, "Embra") == 1, "a variant of the copy's variant for the copy names it " .. count_text(same_planet.localised_name, "Embra") .. " times")
check(count_text(same_planet.localised_name, "recipe-name.molten-ore") == 1 and same_planet.intermediate_planet == "ember-exfret-2-copy", "a variant of the copy's variant for the copy isn't named like it")
-- Another planet's variant of it still names that planet
local other_planet = table.deepcopy(copy_recipe)
scaffolds.name_variant(other_planet, copy_recipe, "lake")
check(count_text(other_planet.localised_name, "space-location-name.lake") == 1 and other_planet.intermediate_planet == "lake", "a variant for another planet isn't named after that planet")

print("test-scaffolds: " .. num_checks .. " checks passed")
