-- Plain-Lua regression test for spare versions of duplicated buildings (check.spare_building_recipes in randomizations/planetary/check.lua), not loaded by the mod
-- Run from the mod root: lua randomizations/planetary/test-spare-buildings.lua
--
-- An item placing a building and its copies (lib/dupe.lua) are versions of one building.
-- A recipe making one version needs no planet-locked goals of its own while another version is automatable somewhere and no recipe but its own recycling takes it (user, 2026-09-30); otherwise its goals stay.

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
-- Prototype classes by base type (the buildings' entities aren't defined, so recycling names them by their items)
defines = {
    prototypes = {
        item = {
            item = 0,
        },
        entity = {},
    },
}
-- The check only calls protection inside functions this test doesn't reach, and nothing here is random (the generator needs Factorio's bit32)
package.loaded["randomizations/graph/unified/skeleton/protection"] = {}
package.loaded["lib/random/rng"] = {}

local check = require("randomizations/planetary/check")
local recycling = require("lib/recycling")

local num_checks = 0
local function check_that(condition, message)
    num_checks = num_checks + 1
    if not condition then
        error(message, 2)
    end
end

-- A building with two copies, one with none, and an ordinary item
local function item(name, extra)
    local prototype = {
        type = "item",
        name = name,
    }
    for key, value in pairs(extra or {}) do
        prototype[key] = value
    end
    return prototype
end
local function makes(recipe_name, item_name, ingredients)
    return {
        type = "recipe",
        name = recipe_name,
        ingredients = ingredients or {},
        results = {
            {
                type = "item",
                name = item_name,
                amount = 1,
            },
        },
    }
end
local COPY_2 = "digger-exfret-2-copy"
local COPY_3 = "digger-exfret-3-copy"
data = {
    raw = {},
}
data.raw.item = {
    digger = item("digger", {
        place_result = "digger",
    }),
    [COPY_2] = item(COPY_2, {
        place_result = COPY_2,
        orig_name = "digger",
        dupe_number = 2,
    }),
    [COPY_3] = item(COPY_3, {
        place_result = COPY_3,
        orig_name = "digger",
        dupe_number = 3,
    }),
    loner = item("loner", {
        place_result = "loner",
    }),
    cog = item("cog"),
}
data.raw.recipe = {
    digger = makes("digger", "digger"),
    [COPY_2] = makes(COPY_2, COPY_2),
    [COPY_3] = makes(COPY_3, COPY_3),
    loner = makes("loner", "loner"),
    cog = makes("cog", "cog"),
}

-- The game checked: the original is automatable on one planet, copy 2 only made by hand there, copy 3 not at all
local function sorted_with(contexts_of_items)
    local node_to_context_inds = {}
    for item_name, contexts in pairs(contexts_of_items) do
        node_to_context_inds["item: " .. item_name] = {}
        for _, context in pairs(contexts) do
            node_to_context_inds["item: " .. item_name][context] = 1
        end
    end
    return {
        sort_info = {
            node_to_context_inds = node_to_context_inds,
        },
    }
end
local after = sorted_with({
    digger = {
        "planet: alpha | 00",
        "planet: alpha | 01",
    },
    [COPY_2] = {
        "planet: alpha | 00",
    },
    loner = {
        "planet: alpha | 01",
    },
})

local spare = check.spare_building_recipes(after)
check_that(spare["recipe: " .. COPY_2] ~= nil, "copy 2 is spare while the original is automatable")
check_that(spare["recipe: " .. COPY_3] ~= nil, "copy 3 is spare while the original is automatable")
check_that(spare["recipe: digger"] == nil, "the original isn't spare while no other version is automatable")
check_that(spare["recipe: loner"] == nil, "a building without copies is never spare")
check_that(spare["recipe: cog"] == nil, "an item placing nothing is never spare")

-- A version another recipe takes isn't spare, but its own recycling doesn't count
data.raw.recipe.drill_kit = makes("drill-kit", "cog", {
    {
        type = "item",
        name = COPY_3,
        amount = 1,
    },
})
-- The recycling recipe the recycler would make for copy 2 (lib/recycling.lua's own generator)
local generated = recycling.generate(data.raw)[COPY_2 .. "-recycling"]
check_that(generated ~= nil and recycling.looks_generated(generated.recipe), "the generator makes copy 2's recycling")
data.raw.recipe[generated.recipe.name] = generated.recipe
spare = check.spare_building_recipes(after)
check_that(spare["recipe: " .. COPY_3] == nil, "a version another recipe takes isn't spare")
check_that(spare["recipe: " .. COPY_2] ~= nil, "a version only its own recycling takes is still spare")

-- Once copy 2 is automatable too, the original is spare as well
after = sorted_with({
    digger = {
        "planet: alpha | 00",
    },
    [COPY_2] = {
        "planet: beta | 11",
    },
})
spare = check.spare_building_recipes(after)
check_that(spare["recipe: digger"] ~= nil, "the original is spare while a copy is automatable")
check_that(spare["recipe: " .. COPY_2] == nil, "copy 2 isn't spare while no other version is automatable")

print("test-spare-buildings: " .. num_checks .. " checks passed")
