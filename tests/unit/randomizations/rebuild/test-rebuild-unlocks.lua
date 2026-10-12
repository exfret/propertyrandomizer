-- Run from the mod root: lua tests/unit/randomizations/rebuild/test-rebuild-unlocks.lua
-- A kept alternate unlock path becomes a tech of its own for its recipe (src/randomizations/rebuild/rebuild-unlocks.lua), so every tech still unlocks a single recipe
function table.deepcopy(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for key, child in pairs(value) do
        copy[key] = table.deepcopy(child)
    end
    return copy
end
package.loaded["src/lib/random/rng"] = { int = function() return 1 end }
package.loaded["src/logic/init"] = {
    contexts = {},
    type_info = {},
}
package.loaded["src/prototypes/data-utils"] = { get_prot = function() return nil end }

local rebuild_unlocks = require("src/randomizations/rebuild/rebuild-unlocks")

local function unlock(recipe_name)
    return {
        type = "unlock-recipe",
        recipe = recipe_name,
    }
end
local function describe(recipe_name)
    return {
        localised_name = "name of " .. recipe_name,
        icons = {
            {
                icon = recipe_name .. ".png",
            },
        },
    }
end
local function unlocked(technology)
    local recipes = {}
    for _, effect in pairs(technology.effects or {}) do
        if effect.type == "unlock-recipe" then
            table.insert(recipes, effect.recipe)
        end
    end
    return recipes
end
local function has(list, value)
    for _, entry in pairs(list or {}) do
        if entry == value then
            return true
        end
    end
    return false
end

-- An original kept for two recipes, with nothing else left to give, that another tech needs
local technologies = {
    ["test-original"] = {
        type = "technology",
        name = "test-original",
        prerequisites = { "test-before" },
        unit = {
            count = 100,
            ingredients = {
                {
                    "test-pack",
                    1,
                },
            },
            time = 30,
        },
        effects = {
            unlock("test-recipe-a"),
            unlock("test-recipe-b"),
        },
    },
    ["test-before"] = {
        type = "technology",
        name = "test-before",
        effects = {},
    },
    ["test-after"] = {
        type = "technology",
        name = "test-after",
        prerequisites = { "test-original" },
        effects = {},
    },
    [rebuild_unlocks.rebuilt_name("test-recipe-a")] = {
        type = "technology",
        name = rebuild_unlocks.rebuilt_name("test-recipe-a"),
        localised_name = "name of test-recipe-a",
        effects = { unlock("test-recipe-a") },
    },
}
local retained = {
    ["test-original"] = {
        ["test-recipe-a"] = true,
        ["test-recipe-b"] = true,
    },
}
local copies, originals = rebuild_unlocks.split(technologies, retained, { ["test-original"] = 4 }, describe)
local copy_a = rebuild_unlocks.numbered_name("test-recipe-a", 2)
local copy_b = rebuild_unlocks.numbered_name("test-recipe-b", 2)
assert(#originals == 1 and originals[1] == "test-original")
assert(copies[copy_a].recipe == "test-recipe-a" and copies[copy_a].original == "test-original")
assert(copies[copy_b].recipe == "test-recipe-b")
local both = {
    copy_a,
    copy_b,
}
for _, copy_name in pairs(both) do
    local copy = technologies[copy_name]
    assert(#unlocked(copy) == 1, "each copy unlocks one recipe")
    assert(has(copy.prerequisites, "test-before"), "a copy has the original's prerequisites")
    -- The original's research, split over the recipes it unlocked before the rebuild
    assert(copy.unit.count == 25 and copy.unit.ingredients[1][1] == "test-pack")
    assert(copy.localised_name[1] == "propertyrandomizer-name.unlock-number" and copy.localised_name[3] == "2")
end
assert(technologies[copy_a].icons[1].icon == "test-recipe-a.png")
local rebuilt_a = technologies[rebuild_unlocks.rebuilt_name("test-recipe-a")]
assert(rebuilt_a.localised_name[1] == "propertyrandomizer-name.unlock-number" and rebuilt_a.localised_name[2] == "name of test-recipe-a" and rebuilt_a.localised_name[3] == "1")
assert(#unlocked(technologies["test-original"]) == 0 and technologies["test-original"].hidden == true, "the emptied original is hidden")
local after = technologies["test-after"].prerequisites
assert(not has(after, "test-original") and has(after, copy_a) and has(after, copy_b), "what needed the original needs its copies instead")
print("ok - a kept path becomes a numbered tech of its own for each recipe, replacing the original")

-- A copy from an earlier rebuild kept again stays as it is
local copies_again = rebuild_unlocks.split(technologies, {
    [copy_a] = {
        ["test-recipe-a"] = true,
    },
}, {}, describe)
assert(next(copies_again) == nil and technologies[copy_a].hidden ~= true)
print("ok - a numbered unlock kept again stays as it is")

-- An original with other effects stays, next to its copy
technologies = {
    ["test-discoverer"] = {
        type = "technology",
        name = "test-discoverer",
        research_trigger = {
            type = "craft-item",
            item = "test-item",
        },
        effects = {
            unlock("test-recipe-c"),
            {
                type = "unlock-space-location",
                space_location = "test-planet",
            },
        },
    },
    ["test-after"] = {
        type = "technology",
        name = "test-after",
        prerequisites = { "test-discoverer" },
        effects = {},
    },
}
rebuild_unlocks.split(technologies, {
    ["test-discoverer"] = {
        ["test-recipe-c"] = true,
    },
}, { ["test-discoverer"] = 1 }, describe)
local copy_c = rebuild_unlocks.numbered_name("test-recipe-c", 2)
assert(technologies[copy_c].research_trigger.item == "test-item")
assert(technologies["test-discoverer"].hidden ~= true and #unlocked(technologies["test-discoverer"]) == 0)
assert(has(technologies["test-after"].prerequisites, "test-discoverer") and has(technologies["test-after"].prerequisites, copy_c))
print("ok - an original with other effects stays, without the recipe, and what needed it needs the copy too")
