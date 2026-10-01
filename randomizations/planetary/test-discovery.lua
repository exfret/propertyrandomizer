-- Plain-Lua tests for discovery following the star map (randomizations/planetary/discovery.lua), not loaded by the mod
-- Run from the mod root: lua randomizations/planetary/test-discovery.lua
-- The map is the user's game of 2026-09-30 with made-up names: their example was that Glebis (here wet) should take the packs of Vullis (home-copy) and Naucanra (wet-copy)

-- discovery.plan reads only what it's given, so the modules discovery.lua loads for reading the game are stand-ins
package.loaded["helper-tables/constants"] = {}
package.loaded["lib/data-utils"] = {}
package.loaded["lib/graph/graph-utils"] = {}
package.loaded["lib/dupe"] = {}
package.loaded["lib/surface-sets"] = {}

local discovery = require("randomizations/planetary/discovery")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function words(text)
    local list = {}
    for word in string.gmatch(text, "%S+") do
        table.insert(list, word)
    end
    return list
end

local function set_of(list)
    local set = {}
    for _, value in pairs(list) do
        set[value] = true
    end
    return set
end

local function same_list(a, b)
    if #a ~= #b then
        return false
    end
    for i = 1, #a do
        if a[i] ~= b[i] then
            return false
        end
    end
    return true
end

local function tech(ingredients, prerequisites, discovers)
    return {
        ingredients = ingredients,
        prerequisites = prerequisites or {},
        discovers = discovers or {},
    }
end

-- The user's map: orbits 10 (hot), 15 (home, the start), 20 (wet), 25 (stormy), 35 (cold), each with a copy on its orbit, and two locations that aren't planets beyond
local function user_game()
    local base = {
        "red",
        "green",
        "blue",
        "cosmic",
    }
    local function with(extra)
        local list = {}
        for _, pack in pairs(base) do
            table.insert(list, pack)
        end
        for _, pack in pairs(extra) do
            table.insert(list, pack)
        end
        return list
    end
    local edges = {}
    for _, pair in pairs({
        {
            "hot-copy",
            "home",
        },
        {
            "hot",
            "home",
        },
        {
            "hot",
            "home-copy",
        },
        {
            "home-copy",
            "wet",
        },
        {
            "hot-copy",
            "wet-copy",
        },
        {
            "home",
            "stormy-copy",
        },
        {
            "home-copy",
            "stormy",
        },
        {
            "stormy-copy",
            "cold",
        },
        {
            "wet-copy",
            "cold-copy",
        },
        {
            "cold-copy",
            "edge",
        },
        {
            "edge",
            "far",
        },
        {
            "stormy",
            "cold-copy",
        },
        {
            "stormy",
            "cold",
        },
        {
            "wet-copy",
            "stormy-copy",
        },
        {
            "wet",
            "cold",
        },
        {
            "wet",
            "wet-copy",
        },
    }) do
        table.insert(edges, {
            from = pair[1],
            to = pair[2],
        })
    end
    return {
        start = "home",
        orbit = {
            home = 15,
            ["home-copy"] = 15,
            hot = 10,
            ["hot-copy"] = 10,
            wet = 20,
            ["wet-copy"] = 20,
            stormy = 25,
            ["stormy-copy"] = 25,
            cold = 35,
            ["cold-copy"] = 35,
            edge = 50,
            far = 80,
        },
        edges = edges,
        is_planet = set_of({
            "home",
            "home-copy",
            "hot",
            "hot-copy",
            "wet",
            "wet-copy",
            "stormy",
            "stormy-copy",
            "cold",
            "cold-copy",
        }),
        own_packs = {
            ["home-copy"] = {
                "mil-copy",
                "prod-copy",
                "util-copy",
            },
            hot = {
                "hot-pack",
            },
            ["hot-copy"] = {
                "hot-pack-copy",
            },
            wet = {
                "wet-pack",
            },
            ["wet-copy"] = {
                "wet-pack-copy",
            },
            stormy = {
                "stormy-pack",
            },
            ["stormy-copy"] = {
                "stormy-pack-copy",
            },
            cold = {
                "cold-pack",
            },
            ["cold-copy"] = {
                "cold-pack-copy",
            },
        },
        original_of = {
            ["mil-copy"] = "mil",
            ["prod-copy"] = "prod",
            ["util-copy"] = "util",
            ["hot-pack-copy"] = "hot-pack",
            ["wet-pack-copy"] = "wet-pack",
            ["stormy-pack-copy"] = "stormy-pack",
            ["cold-pack-copy"] = "cold-pack",
        },
        technologies = {
            thrusters = tech(base),
            pontoons = tech({
                "red",
                "green",
            }),
            ["find-hot"] = tech(base, {"thrusters"}, {"hot"}),
            ["find-hot-copy"] = tech(base, {"thrusters"}, {"hot-copy"}),
            ["find-home-copy"] = tech(base, {"thrusters"}, {"home-copy"}),
            ["find-wet"] = tech(base, words("thrusters pontoons"), {"wet"}),
            ["find-wet-copy"] = tech(base, words("thrusters pontoons"), {"wet-copy"}),
            ["find-stormy"] = tech(base, {"thrusters"}, {"stormy"}),
            ["find-stormy-copy"] = tech(base, {"thrusters"}, {"stormy-copy"}),
            -- Like Aquilo's: three inner planets' packs and the start's production and utility packs, with prerequisites from those planets
            ["find-cold"] = tech(with(words("prod util hot-pack wet-pack stormy-pack")), words("heating hot-pack-tech thrusters"), {"cold"}),
            ["find-cold-copy"] = tech(with(words("prod util hot-pack wet-pack stormy-pack")), words("heating hot-pack-tech thrusters"), {"cold-copy"}),
            ["find-edge"] = tech(with(words("prod util hot-pack wet-pack stormy-pack cold-pack")), {}, {"edge"}),
            heating = tech({}, {"find-wet"}),
            ["hot-pack-tech"] = tech({}, {"find-hot"}),
            ["prod-tech"] = tech({
                "red",
                "green",
                "blue",
            }),
            ["util-tech"] = tech({
                "red",
                "green",
                "blue",
            }),
            ["wet-pack-copy-tech"] = tech({}, {"find-wet-copy"}),
            ["stormy-pack-copy-tech"] = tech({}, {"find-stormy-copy"}),
        },
        unlocking = {
            ["prod-copy"] = {
                "prod-tech",
            },
            ["util-copy"] = {
                "util-tech",
            },
            ["wet-pack-copy"] = {
                "wet-pack-copy-tech",
            },
            ["stormy-pack-copy"] = {
                "stormy-pack-copy-tech",
            },
            -- Two technologies unlock it, so neither is added as a prerequisite
            ["hot-pack"] = {
                "hot-pack-tech",
                "hot-pack-tech-2",
            },
        },
    }
end

test("the user's example: a planet takes the packs of its neighbors one hop closer to the start that don't orbit farther out", function()
    local plan = discovery.plan(user_game())
    local wet = plan["find-wet"]
    assert(same_list(wet.before, words("home-copy wet-copy")))
    -- The start copy gives the copies of the start packs some discovery takes (production and utility), not its military one
    assert(same_list(wet.ingredients, words("red green blue cosmic prod-copy util-copy wet-pack-copy")))
    assert(same_list(wet.added, words("prod-copy util-copy wet-pack-copy")))
    -- It gains the discoveries of the planets before it and the one technology unlocking each pack it now takes
    assert(same_list(wet.prerequisites, words("thrusters pontoons find-home-copy find-wet-copy prod-tech util-tech wet-pack-copy-tech")))
    assert(#wet.dropped == 0)
end)

test("a neighbor on a farther orbit doesn't count, however close to the start", function()
    local plan = discovery.plan(user_game())
    -- wet-copy's neighbors one hop closer: hot-copy (orbit 10) and stormy-copy (orbit 25)
    assert(same_list(plan["find-wet-copy"].before, {"hot-copy"}))
    assert(same_list(plan["find-wet-copy"].added, {"hot-pack-copy"}))
    assert(same_list(plan["find-stormy"].before, {"home-copy"}))
end)

test("a far planet's discovery loses the other planets' packs and the prerequisites that need planets not before it", function()
    local plan = discovery.plan(user_game())
    local cold = plan["find-cold"]
    assert(same_list(cold.before, {"stormy-copy"}))
    -- The start's own production and utility packs stay; the three inner planets' packs go
    assert(same_list(cold.ingredients, words("red green blue cosmic prod util stormy-pack-copy")))
    -- heating needs wet's discovery and hot-pack-tech hot's, neither before cold
    assert(same_list(cold.dropped, words("heating hot-pack-tech")))
    assert(same_list(cold.prerequisites, words("thrusters find-stormy-copy stormy-pack-copy-tech")))
end)

test("first-hop planets keep their discovery as it was, and the start gives nothing", function()
    local plan = discovery.plan(user_game())
    for _, name in pairs(words("find-hot find-hot-copy find-stormy-copy")) do
        assert(#plan[name].added == 0)
        assert(same_list(plan[name].ingredients, words("red green blue cosmic")))
        assert(same_list(plan[name].prerequisites, {"thrusters"}))
    end
    -- home-copy's closer neighbor is hot; home itself is one hop from nothing closer
    assert(same_list(plan["find-home-copy"].before, {"hot"}))
end)

test("space locations that aren't planets keep their discovery", function()
    local plan = discovery.plan(user_game())
    assert(plan["find-edge"] == nil)
end)

test("a planet none of whose packs a discovery takes gives all of them", function()
    local game = user_game()
    -- Nothing takes production or utility packs, so home-copy gives all three of its packs
    game.technologies["find-cold"] = tech({"red"}, {}, {"cold"})
    game.technologies["find-cold-copy"] = tech({"red"}, {}, {"cold-copy"})
    game.technologies["find-edge"] = tech({"red"}, {}, {"edge"})
    local plan = discovery.plan(game)
    assert(same_list(plan["find-wet"].added, words("mil-copy prod-copy util-copy wet-pack-copy")))
end)

test("a planet the start can't reach, and a technology discovering two planets, are left alone", function()
    local game = user_game()
    game.is_planet["lost"] = true
    game.orbit["lost"] = 20
    game.technologies["find-lost"] = tech({"red"}, {}, {"lost"})
    game.technologies["find-both"] = tech({"red"}, {}, words("wet stormy"))
    local plan = discovery.plan(game)
    assert(plan["find-lost"] == nil)
    assert(plan["find-both"] == nil)
    assert(plan["find-wet"] ~= nil)
end)

test("hops never go through the end of the game (locations past every planet that aren't planets)", function()
    local game = user_game()
    -- A planet joined only to edge, and both copies of the outermost planet joined to edge too
    game.is_planet["lone"] = true
    game.orbit["lone"] = 35
    for _, pair in pairs({
        {
            "cold",
            "edge",
        },
        {
            "lone",
            "edge",
        },
    }) do
        table.insert(game.edges, {
            from = pair[1],
            to = pair[2],
        })
    end
    game.technologies["find-lone"] = tech(words("red green"), {}, {"lone"})
    local plan = discovery.plan(game)
    -- lone is reachable only through edge, so it gets no place on the map and keeps its discovery
    assert(plan["find-lone"] == nil)
    -- cold-copy still comes after wet-copy, not after cold through edge
    assert(same_list(plan["find-cold-copy"].before, words("wet-copy")))
end)

print(num_passed .. " tests passed")
