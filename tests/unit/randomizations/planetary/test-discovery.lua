-- Plain-Lua tests for discovery following the star map (src/randomizations/planetary/discovery.lua), not loaded by the mod
-- Run from the mod root: lua tests/unit/randomizations/planetary/test-discovery.lua
-- The map is the user's game of 2026-09-30 with made-up names: hot, hot-copy and stormy-copy are one hop from the start, home-copy, wet-copy and cold two, and cold-copy, stormy and wet three
-- A planet takes the packs of its own neighbors one hop closer: home-copy hot's, wet-copy hot-copy's and stormy-copy's, cold stormy-copy's, wet cold's, home-copy's and wet-copy's, stormy cold's and home-copy's, cold-copy wet-copy's

-- discovery.plan reads only what it's given, so the modules discovery.lua loads for reading the game are stand-ins
package.loaded["src/config/constants"] = {}
package.loaded["src/prototypes/data-utils"] = {}
package.loaded["src/lib/graph/graph-utils"] = {}
package.loaded["src/lib/sort/context-sort"] = {}
package.loaded["src/prototypes/duplicates/dupe"] = {}
package.loaded["src/prototypes/surfaces/surface-sets"] = {}

local discovery = require("src/randomizations/planetary/discovery")

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

test("a planet's discovery takes the packs of the planets one hop closer", function()
    local plan = discovery.plan(user_game())
    local wet = plan["find-wet"]
    assert(wet.hops == 3)
    assert(same_list(wet.before, words("cold home-copy wet-copy")))
    -- The start copy gives the copies of the start packs some discovery takes (production and utility), not its military one
    assert(same_list(wet.ingredients, words("red green blue cosmic cold-pack prod-copy util-copy wet-pack-copy")))
    assert(same_list(wet.added, words("cold-pack prod-copy util-copy wet-pack-copy")))
    -- It gains the discoveries of the planets before it and the one technology unlocking each pack it now takes (cold's pack has none)
    assert(same_list(wet.prerequisites, words("thrusters pontoons find-cold find-home-copy find-wet-copy prod-tech util-tech wet-pack-copy-tech")))
    assert(#wet.dropped == 0)
end)

test("each planet takes the packs of its own planets before it, not its whole tier's", function()
    local plan = discovery.plan(user_game())
    local before = {
        ["find-home-copy"] = words("hot"),
        ["find-wet-copy"] = words("hot-copy stormy-copy"),
        ["find-cold"] = words("stormy-copy"),
        ["find-wet"] = words("cold home-copy wet-copy"),
        -- stormy is one hop from home-copy and cold, not from wet-copy
        ["find-stormy"] = words("cold home-copy"),
        -- cold-copy's only neighbor one hop closer is wet-copy (stormy is as far out as it is)
        ["find-cold-copy"] = words("wet-copy"),
    }
    for name, planets in pairs(before) do
        assert(same_list(plan[name].before, planets), name .. ": " .. table.concat(plan[name].before, " "))
    end
    -- The hops are only for the log
    assert(plan["find-stormy"].hops == 3 and plan["find-cold"].hops == 2 and plan["find-hot"].hops == 1)
end)

test("planets on the outermost planet orbit give packs like any other", function()
    local plan = discovery.plan(user_game())
    -- cold is two hops out and gives its pack to the planets after it, though in Space Age no planet's discovery takes Aquilo's
    for _, name in pairs(words("find-stormy find-wet")) do
        assert(set_of(plan[name].added)["cold-pack"] ~= nil)
    end
    -- But not to one it isn't before
    assert(set_of(plan["find-cold-copy"].added)["cold-pack"] == nil)
    -- They take the packs of the planets before them too
    assert(same_list(plan["find-cold"].before, words("stormy-copy")))
end)

test("a far planet's discovery loses the other planets' packs and the prerequisites that need planets not before it", function()
    local plan = discovery.plan(user_game())
    local cold = plan["find-cold"]
    -- The start's own production and utility packs stay; the three inner planets' packs go, and stormy-copy's comes in
    assert(same_list(cold.ingredients, words("red green blue cosmic prod util stormy-pack-copy")))
    -- heating needs wet's discovery and hot-pack-tech hot's, and neither is before cold
    assert(same_list(cold.dropped, words("heating hot-pack-tech")))
    assert(same_list(cold.prerequisites, words("thrusters find-stormy-copy stormy-pack-copy-tech")))
    -- hot is one hop from the start, but not before cold-copy either
    assert(same_list(plan["find-cold-copy"].dropped, words("heating hot-pack-tech")))
end)

test("planets one hop out keep their discovery as it was, and the start gives nothing", function()
    local plan = discovery.plan(user_game())
    for _, name in pairs(words("find-hot find-hot-copy find-stormy-copy")) do
        assert(#plan[name].before == 0)
        assert(#plan[name].added == 0)
        assert(same_list(plan[name].ingredients, words("red green blue cosmic")))
        assert(same_list(plan[name].prerequisites, {"thrusters"}))
    end
end)

test("a planet none of whose planets before it gives takes the packs of the nearest ones before them that do", function()
    local function edge(from, to)
        return {
            from = from,
            to = to,
        }
    end
    local game = {
        start = "home",
        orbit = {
            home = 15,
            hot = 10,
            moss = 12,
            cold = 35,
            wet = 20,
        },
        edges = {
            edge("home", "hot"),
            edge("home", "moss"),
            edge("hot", "cold"),
            edge("cold", "wet"),
        },
        is_planet = set_of(words("home hot moss cold wet")),
        -- cold has no pack of its own, so it gives nothing
        own_packs = {
            hot = {"hot-pack"},
            moss = {"moss-pack"},
            wet = {"wet-pack"},
        },
        original_of = {},
        technologies = {
            ["find-hot"] = tech({"red"}, {}, {"hot"}),
            ["find-moss"] = tech({"red"}, {}, {"moss"}),
            ["find-cold"] = tech({"red"}, {}, {"cold"}),
            ["find-wet"] = tech({"red"}, {}, {"wet"}),
        },
        unlocking = {},
    }
    local plan = discovery.plan(game)
    -- wet is only reached through cold, which has nothing to give, so it takes from hot, the planet before cold
    assert(plan["find-wet"].hops == 3)
    assert(same_list(plan["find-wet"].before, {"hot"}))
    -- No discovery takes hot's pack, so hot gives all of its packs; moss is one hop out too, but not before wet
    assert(same_list(plan["find-wet"].added, {"hot-pack"}))
    assert(same_list(plan["find-cold"].before, {"hot"}))
end)

-- The user's game with what packs and technologies need read from their own fields, as the game's logic graph would give it, then changed by overrides (kind --> name --> set of planets, or false)
local function with_needs(overrides)
    local game = user_game()
    game.needs = discovery.needs_from_fields(game)
    for kind, entries in pairs(overrides) do
        for name, planets in pairs(entries) do
            game.needs[kind][name] = planets
        end
    end
    return game
end

test("a planet doesn't take a pack that needs a planet not before it", function()
    -- Like a planet copy's pack, which needs the copy of the starting planet with its number discovered too (home-copy isn't before wet-copy)
    local plan, withheld = discovery.plan(with_needs({
        pack = {
            ["hot-pack-copy"] = set_of(words("hot-copy home-copy")),
        },
    }))
    -- hot-copy has nothing else to give, so wet-copy takes only stormy-copy's pack
    assert(same_list(plan["find-wet-copy"].before, words("stormy-copy")))
    assert(same_list(plan["find-wet-copy"].added, words("stormy-pack-copy")))
    -- And the pack it doesn't take is reported with the planet it needs
    assert(same_list(withheld["wet-copy"]["hot-pack-copy"], {"home-copy"}))
    assert(withheld["hot"] == nil)
    -- A pack needing the discovery of any planet before the taker is fine, even one that isn't before the giver
    plan = discovery.plan(with_needs({
        pack = {
            ["hot-pack-copy"] = set_of(words("hot-copy stormy-copy")),
        },
    }))
    assert(same_list(plan["find-wet-copy"].before, words("hot-copy stormy-copy")))
end)

test("a discovery keeps the prerequisites that need only the discoveries of planets before it", function()
    local game = with_needs({
        technology = {
            -- cold is before wet; stormy isn't
            ["cold-tech"] = set_of({"cold"}),
            ["stormy-tech"] = set_of({"stormy"}),
            ["lost-tech"] = false,
        },
    })
    for _, name in pairs(words("cold-tech stormy-tech lost-tech")) do
        game.technologies[name] = tech({})
        table.insert(game.technologies["find-wet"].prerequisites, name)
    end
    local plan = discovery.plan(game)
    local prerequisites = set_of(plan["find-wet"].prerequisites)
    assert(prerequisites["cold-tech"] ~= nil)
    -- What can't be had at all is kept as it is: it adds no new cycle
    assert(prerequisites["lost-tech"] ~= nil)
    assert(same_list(plan["find-wet"].dropped, {"stormy-tech"}))
end)

test("a discovery leaves out a pack it kept that needs a planet not before it", function()
    local plan = discovery.plan(with_needs({
        pack = {
            -- wet is three hops out
            blue = set_of({"wet"}),
        },
    }))
    assert(same_list(plan["find-hot"].dropped_packs, {"blue"}))
    assert(same_list(plan["find-hot"].ingredients, words("red green cosmic")))
    -- Nor can stormy's, which wet isn't before
    assert(same_list(plan["find-stormy"].dropped_packs, {"blue"}))
    -- A pack that can't be had at all isn't given, and stays where it was
    plan = discovery.plan(with_needs({
        pack = {
            ["wet-pack-copy"] = false,
            blue = false,
        },
    }))
    assert(same_list(plan["find-wet"].added, words("cold-pack prod-copy util-copy")))
    assert(#plan["find-hot"].dropped_packs == 0)
end)

test("space locations that aren't planets keep their discovery", function()
    local plan = discovery.plan(user_game())
    assert(plan["find-edge"] == nil)
end)

test("a planet none of whose packs a discovery takes gives all of them", function()
    local game = user_game()
    -- Nothing takes production or utility packs, so home-copy gives all three of its packs, and nothing takes cold's either
    game.technologies["find-cold"] = tech({"red"}, {}, {"cold"})
    game.technologies["find-cold-copy"] = tech({"red"}, {}, {"cold-copy"})
    game.technologies["find-edge"] = tech({"red"}, {}, {"edge"})
    local plan = discovery.plan(game)
    assert(same_list(plan["find-wet"].added, words("cold-pack mil-copy prod-copy util-copy wet-pack-copy")))
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
    -- A planet joined only to edge, and edge joined to the start and the outermost planet too
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
        {
            "home",
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
    -- lone is reachable only through edge, so it gets no hops and keeps its discovery
    assert(plan["find-lone"] == nil)
    -- cold-copy is still three hops out, not two through edge
    assert(plan["find-cold-copy"].hops == 3)
end)

print(num_passed .. " tests passed")
