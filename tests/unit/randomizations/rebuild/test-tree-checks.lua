-- Run from the mod root: lua tests/unit/randomizations/rebuild/test-tree-checks.lua
-- The checks of a rebuilt tech tree against the user's rules (src/randomizations/rebuild/tree-checks.lua): each catches the problem it's for, on a tree like the one the user found it in (2026-10-12), and passes a tree without it

local tree_checks = require("src/randomizations/rebuild/tree-checks")

local START = "planet: start"
local HOT = "planet: hot"
local HOT_2 = "planet: hot-2"
local COLD = "planet: cold"
local COLD_3 = "planet: cold-3"

local function tech(name, fields)
    local prototype = fields or {}
    prototype.type = "technology"
    prototype.name = name
    return prototype
end
local function unit(packs, count)
    local ingredients = {}
    for _, pack in pairs(packs) do
        table.insert(ingredients, {
            pack,
            1,
        })
    end
    return {
        count = count or 10,
        time = 1,
        ingredients = ingredients,
    }
end
local function unlock(recipe_name)
    return {
        type = "unlock-recipe",
        recipe = recipe_name,
    }
end
local function discover(location)
    return {
        type = "unlock-space-location",
        space_location = location,
    }
end

-- A clean tree: the hot planet's discovery after the start's packs, a recipe only the hot planet makes after it, researched with the discovery's packs too, and its copy after the hot planet copy's discovery
local function clean()
    return {
        technologies = {
            ["find-hot"] = tech("find-hot", {
                effects = { discover("hot") },
                unit = unit({
                    "red",
                    "blue",
                }, 100),
            }),
            ["find-hot-2"] = tech("find-hot-2", {
                effects = { discover("hot-2") },
                unit = unit({
                    "red",
                    "blue",
                }, 100),
            }),
            ["find-cold"] = tech("find-cold", {
                effects = { discover("cold") },
                unit = unit({
                    "red",
                    "blue",
                }, 100),
            }),
            ["hot-pack"] = tech("hot-pack", {
                effects = { unlock("hot-pack") },
                prerequisites = { "find-hot" },
                research_trigger = {
                    type = "craft-item",
                    item = "tungsten",
                },
            }),
            ["drill"] = tech("drill", {
                effects = { unlock("drill") },
                unit = unit({ "red" }),
            }),
            ["drill-2"] = tech("drill-2", {
                effects = { unlock("drill-2") },
                prerequisites = { "find-hot-2" },
                unit = unit({
                    "red",
                    "blue",
                }),
            }),
            ["merged-hot"] = tech("merged-hot", {
                effects = { unlock("merged") },
                prerequisites = { "find-hot" },
                unit = unit({
                    "red",
                    "blue",
                }),
            }),
            ["merged-cold"] = tech("merged-cold", {
                effects = { unlock("merged") },
                prerequisites = { "find-cold" },
                unit = unit({
                    "red",
                    "blue",
                }),
            }),
        },
        recipes = {
            ["hot-pack"] = {
                name = "hot-pack",
                enabled = false,
            },
            ["drill"] = {
                name = "drill",
                enabled = false,
            },
            ["drill-2"] = {
                name = "drill-2",
                enabled = false,
                dupe_number = 2,
            },
            ["merged"] = {
                name = "merged",
                enabled = false,
            },
            ["hot-brick"] = {
                name = "hot-brick",
                enabled = false,
            },
            ["plate"] = {
                name = "plate",
            },
        },
        rooms = {
            ["hot-pack"] = { [HOT] = true },
            ["drill"] = {
                [START] = true,
                [HOT] = true,
            },
            ["drill-2"] = {
                [START] = true,
                [HOT] = true,
            },
            ["merged"] = {
                [HOT] = true,
                [COLD] = true,
            },
            ["hot-brick"] = { [HOT] = true },
            ["plate"] = {
                [START] = true,
                [HOT] = true,
            },
        },
    }
end

local function run(tree)
    return tree_checks.run({
        technologies = tree.technologies,
        recipes = tree.recipes,
        rooms_of = function(recipe_name)
            return tree.rooms[recipe_name]
        end,
        discoverers = {
            [HOT] = { ["find-hot"] = true },
            [HOT_2] = { ["find-hot-2"] = true },
            [COLD] = { ["find-cold"] = true },
            [COLD_3] = { ["find-cold-3"] = true },
        },
        copy_number = function(room)
            if room == HOT_2 then
                return 2
            end
            return room == COLD_3 and 3 or 1
        end,
        labs = {
            {
                red = true,
                blue = true,
            },
        },
        reasons = tree.reasons,
    })
end
-- The violations of the named rule
local function violations(results, name)
    for _, result in pairs(results) do
        if result.name == name then
            return result.violations
        end
    end
    error("no rule " .. name)
end
-- Every rule that isn't only information passes, except the named one, which has exactly count violations
local function expect(results, name, count, label)
    for _, result in pairs(results) do
        if result.info ~= true then
            local expected = result.name == name and count or 0
            assert(#result.violations == expected, label .. ": " .. result.name .. " has " .. #result.violations .. " violations, not " .. expected .. " (" .. table.concat(result.violations, "; ") .. ")")
        end
    end
end

local num_passed = 0
local function test(name, check)
    check()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

test("a tree following the rules passes", function()
    local lines = {}
    local ok = tree_checks.report(run(clean()), function(line)
        table.insert(lines, line)
    end)
    assert(ok, "the clean tree passes: " .. table.concat(lines, "\n"))
    assert(lines[#lines] == "REBUILDCHECK verdict: ok")
end)

test("gates: a tech unlocking a recipe made only on a planet needing discovery without its discovery", function()
    -- Like Fulcanus's metallurgic pack, researched by crafting tungsten plate after the previous planet's pack only (user's issue 1)
    local tree = clean()
    tree.technologies["hot-pack"].prerequisites = {}
    expect(run(tree), "gates", 1, "gates")
end)

test("served: a recipe two planets make, unlocked only after one of their discoveries", function()
    -- Like heavy oil cracking for Aquilra, Vullus and Aquicana, after only one discovery (user's issue 3)
    local tree = clean()
    tree.technologies["merged-cold"] = nil
    local results = run(tree)
    expect(results, "served", 1, "served")
    assert(string.find(violations(results, "served")[1], "merged on planet: cold waits for find-hot", 1, true) ~= nil)
end)

test("superfluous: two unlocks of a recipe with the same research and prerequisites, or one needing the other", function()
    -- Like Unlock 2 and Unlock 3 of the same recipe in the user's tree (user's issue 2)
    local tree = clean()
    tree.technologies["merged-hot-2"] = tech("merged-hot-2", {
        effects = { unlock("merged") },
        prerequisites = { "find-hot" },
        unit = unit({
            "red",
            "blue",
        }),
    })
    expect(run(tree), "superfluous", 1, "same research")
    tree = clean()
    tree.technologies["merged-late"] = tech("merged-late", {
        effects = { unlock("merged") },
        prerequisites = { "merged-hot" },
        research_trigger = {
            type = "craft-item",
            item = "tungsten",
        },
    })
    expect(run(tree), "superfluous", 1, "one needing the other")
end)

test("start-enabled: a recipe only a planet needing discovery makes, enabled from the start", function()
    -- Like the stone brick versions of planets enabled at the start (user's second list, issue 4)
    local tree = clean()
    tree.recipes["hot-brick"].enabled = nil
    expect(run(tree), "start-enabled", 1, "start-enabled")
end)

test("justified: a prerequisite the rebuild has no reason for", function()
    -- Like the electric mining drill (Dupe 3) needing pipe-to-ground (Dupe 3)'s tech (user's second list, issue 5)
    local tree = clean()
    tree.technologies["drill-2"].prerequisites = {
        "find-hot-2",
        "hot-pack",
    }
    tree.reasons = {
        ["drill-2"] = {
            ["find-hot-2"] = "its research comes after find-hot-2",
        },
    }
    expect(run(tree), "justified", 1, "justified")
end)

test("science: a tech after a discovery that doesn't take the discovery's packs", function()
    -- Like the copied drill after its planet copy's discovery, still researched with red science only (user's second list, issue 7)
    local tree = clean()
    tree.technologies["drill-2"].unit = unit({ "red" })
    expect(run(tree), "science", 1, "science")
    -- A lab taking all of them is needed for that: without one, it's only information
    tree.technologies["find-hot-2"].unit = unit({
        "red",
        "space",
    }, 100)
    local results = run(tree)
    assert(#violations(results, "science") == 0 and #violations(results, "science-no-lab") == 1, "no lab takes red and space together")
end)

test("copies: a copied item's recipe unlocked before any planet copy with its number", function()
    -- User, 2026-10-12: "the duplicated items belong to the duplicated planets, not to nauvis"
    local tree = clean()
    tree.technologies["drill-2"].prerequisites = {}
    tree.technologies["drill-2"].unit = unit({ "red" })
    expect(run(tree), "copies", 1, "copies")
end)

test("copies: a recipe merged from planet copies' versions belongs to every planet it's made on", function()
    -- Like casting iron gear wheel's versions for Aquicana (Fulgora copy 3), Glelis (Nauvis copy 3) and Vulgora (Vulcanus copy 2), merged into Aquicana's and unlocked after Vulgora's discovery (user, 2026-10-15)
    local tree = clean()
    tree.technologies["find-cold-3"] = tech("find-cold-3", {
        effects = { discover("cold-3") },
        prerequisites = { "find-hot-2" },
        unit = unit({
            "red",
            "blue",
        }, 100),
    })
    tree.technologies["belt-3"] = tech("belt-3", {
        effects = { unlock("belt-3") },
        prerequisites = { "find-hot-2" },
        unit = unit({
            "red",
            "blue",
        }),
    })
    tree.recipes["belt-3"] = {
        name = "belt-3",
        enabled = false,
        dupe_number = 3,
        merged_versions = {
            {
                name = "belt-2",
                is_planet_locked = true,
            },
        },
    }
    tree.rooms["belt-3"] = {
        [HOT_2] = true,
        [COLD_3] = true,
    }
    -- After the discovery of the copy 2 planet it's made on
    expect(run(tree), "copies", 0, "after a copy 2 planet")
    -- Unmerged, the same recipe is a copy 3 one, as before
    tree.recipes["belt-3"].merged_versions = nil
    expect(run(tree), "copies", 1, "unmerged")
    -- Researchable from the start: made on a planet that isn't a copy too, it needs no planet copy's discovery
    tree = clean()
    tree.technologies["belt-3"] = tech("belt-3", {
        effects = { unlock("belt-3") },
        unit = unit({ "red" }),
    })
    tree.recipes["belt-3"] = {
        name = "belt-3",
        enabled = false,
        dupe_number = 3,
        merged_versions = {
            {
                name = "belt-2",
                is_planet_locked = true,
            },
        },
    }
    tree.rooms["belt-3"] = {
        [START] = true,
        [HOT_2] = true,
    }
    expect(run(tree), "copies", 0, "made on a planet that isn't a copy")
    -- Made only on planet copies, a merged one is still caught before any of their discoveries
    tree.rooms["belt-3"] = {
        [HOT_2] = true,
        [COLD_3] = true,
    }
    local found = violations(run(tree), "copies")
    assert(#found == 1 and string.find(found[1], "belt-3 unlocks belt-3 (copy 2 or 3) before any copy 2 or 3 planet", 1, true) ~= nil, "merged, before any of its planets: " .. table.concat(found, "; "))
end)

test("cycles: a prerequisite leading back, or one that doesn't exist", function()
    local tree = clean()
    tree.technologies["find-hot"].prerequisites = { "hot-pack" }
    local results = run(tree)
    assert(#violations(results, "cycles") >= 1, "the cycle is found")
    tree = clean()
    tree.technologies["drill"].prerequisites = { "gone" }
    assert(#violations(run(tree), "cycles") == 1, "the missing prerequisite is found")
end)

print(num_passed .. " tests passed")
