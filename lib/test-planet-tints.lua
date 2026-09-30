-- Plain-Lua regression tests for random planet tints (lib/planet-tints.lua), not loaded by the mod
-- Run from the mod root: lua lib/test-planet-tints.lua

-- Stand-ins for the Factorio environment, with the real rng: its hash needs Factorio's bit32, made here from Lua 5.4's operators
function log(msg) end
config = {
    seed = 23,
}
bit32 = {
    bxor = function(a, b)
        return (a ~ b) & 0xFFFFFFFF
    end,
    lshift = function(a, n)
        return (a << n) & 0xFFFFFFFF
    end,
    rshift = function(a, n)
        return (a & 0xFFFFFFFF) >> n
    end,
}
function table.deepcopy(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    local copy = {}
    for key, value in pairs(tbl) do
        copy[key] = table.deepcopy(value)
    end
    return copy
end

-- Made-up images and planets, since the module mustn't depend on which planets there are: rocky and home have tints, dusty has none
local ANGLES = {
    60,
    90,
    120,
    150,
    180,
    210,
    240,
    270,
    300,
}
local TINTED_IMAGES = {
    "__made-up__/icons/home.png",
    "__made-up__/icons/starmap-home.png",
    "__made-up__/icons/rocky.png",
    "__made-up__/icons/starmap-rocky.png",
    "__made-up__/technology/rocky.png",
}
local manifest_files = {}
for _, path in pairs(TINTED_IMAGES) do
    manifest_files[path] = ANGLES
end
package.loaded["lib/planet-tint-manifest"] = {
    files = manifest_files,
}

local constants = require("helper-tables/constants")
local rng = require("lib/random/rng")
local planet_tints = require("lib/planet-tints")

-- A recolored copy's path, as lib/dupe.lua swaps them in
local function recolored(path)
    local mod_name, rest = string.match(path, "^__([^/]+)__/(.*)$")
    return "__propertyrandomizer__/graphics/dupes/2/" .. mod_name .. "/" .. rest
end

local function tint_path(path, degrees)
    local mod_name, rest = string.match(path, "^__([^/]+)__/(.*)$")
    return "__propertyrandomizer__/graphics/dupes/tint-" .. degrees .. "/" .. mod_name .. "/" .. rest
end

local function planet(name, icon, starmap_icon, orig_name, hidden)
    return {
        type = "planet",
        name = name,
        icon = icon,
        starmap_icon = starmap_icon,
        orig_name = orig_name,
        hidden = hidden,
    }
end

local function discovery(name, location, images)
    local icons = {}
    for _, image in pairs(images) do
        table.insert(icons, {
            icon = image,
            icon_size = 256,
        })
    end
    return {
        type = "technology",
        name = name,
        icons = icons,
        effects = {
            {
                type = "unlock-space-location",
                space_location = location,
            },
        },
    }
end

local function connection(name, from, to, from_icon, to_icon)
    return {
        type = "space-connection",
        name = name,
        from = from,
        to = to,
        icons = {
            {
                icon = "__made-up__/icons/route.png",
            },
            {
                icon = from_icon,
                scale = 0.333,
            },
            {
                icon = to_icon,
                scale = 0.333,
            },
        },
    }
end

local OVERLAY = "__core__/constants/constant-planet.png"
local ROUTE = "__made-up__/icons/route.png"

-- home is the starting planet; rocky and home have copies with recolored images, as lib/dupe-planets.lua makes them
local function new_game()
    data = {
        raw = {
            planet = {
                home = planet("home", "__made-up__/icons/home.png", "__made-up__/icons/starmap-home.png"),
                ["home-copy"] = planet("home-copy", recolored("__made-up__/icons/home.png"), recolored("__made-up__/icons/starmap-home.png"), "home"),
                rocky = planet("rocky", "__made-up__/icons/rocky.png", "__made-up__/icons/starmap-rocky.png"),
                ["rocky-copy"] = planet("rocky-copy", recolored("__made-up__/icons/rocky.png"), recolored("__made-up__/icons/starmap-rocky.png"), "rocky"),
                dusty = planet("dusty", "__made-up__/icons/dusty.png", "__made-up__/icons/starmap-dusty.png"),
                unseen = planet("unseen", "__made-up__/icons/rocky.png", "__made-up__/icons/starmap-rocky.png", nil, true),
            },
            technology = {
                ["find-rocky"] = discovery("find-rocky", "rocky", {
                    "__made-up__/technology/rocky.png",
                    OVERLAY,
                }),
                ["find-rocky-copy"] = discovery("find-rocky-copy", "rocky-copy", {
                    recolored("__made-up__/technology/rocky.png"),
                    OVERLAY,
                }),
                -- Modeled on another discovery, a starting planet's copy shows its own icon
                ["find-home-copy"] = discovery("find-home-copy", "home-copy", {
                    recolored("__made-up__/icons/home.png"),
                }),
            },
            ["space-connection"] = {
                ["home-rocky"] = connection("home-rocky", "home", "rocky", "__made-up__/icons/home.png", "__made-up__/icons/rocky.png"),
                ["rocky-copy-home-copy"] = connection("rocky-copy-home-copy", "rocky-copy", "home-copy", recolored("__made-up__/icons/rocky.png"), recolored("__made-up__/icons/home.png")),
                ["rocky-dusty"] = connection("rocky-dusty", "rocky", "dusty", "__made-up__/icons/rocky.png", "__made-up__/icons/dusty.png"),
            },
        },
    }
end

-- Tints the planets with the random stream from its start, as each load of the game does
local function tint_planets()
    rng.prgs = {}
    local old_start = constants.starting_planet
    constants.starting_planet = "home"
    planet_tints.execute()
    constants.starting_planet = old_start
end

local function hue_gap(a, b)
    local gap = math.abs(a - b) % 360
    return math.min(gap, 360 - gap)
end

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

test("every planet but the starting one with tints for all its images gets one, from its original's images", function()
    new_game()
    tint_planets()
    local tints = planet_tints.tints
    assert(tints.home == nil and tints.dusty == nil and tints.unseen == nil)
    local planets = data.raw.planet
    assert(planets.home.icon == "__made-up__/icons/home.png" and planets.home.starmap_icon == "__made-up__/icons/starmap-home.png", "the starting planet was tinted")
    assert(planets.dusty.icon == "__made-up__/icons/dusty.png", "a planet without tints changed")
    assert(planets.unseen.icon == "__made-up__/icons/rocky.png", "a hidden planet was tinted")
    for name, original in pairs({
        rocky = "rocky",
        ["rocky-copy"] = "rocky",
        ["home-copy"] = "home",
    }) do
        local degrees = tints[name]
        assert(degrees ~= nil, name .. " got no tint")
        assert(planets[name].icon == tint_path("__made-up__/icons/" .. original .. ".png", degrees), name .. "'s icon is " .. planets[name].icon)
        assert(planets[name].starmap_icon == tint_path("__made-up__/icons/starmap-" .. original .. ".png", degrees), name .. "'s star map icon is " .. planets[name].starmap_icon)
    end
end)

test("a planet and its copy keep apart, and a starting planet's copy keeps away from its untinted look", function()
    for seed = 1, 40 do
        config.seed = seed
        new_game()
        tint_planets()
        local tints = planet_tints.tints
        assert(hue_gap(tints.rocky, tints["rocky-copy"]) >= 90, "seed " .. seed .. ": rocky " .. tints.rocky .. ", its copy " .. tints["rocky-copy"])
        assert(hue_gap(tints["home-copy"], 0) >= 90, "seed " .. seed .. ": the starting planet's copy got " .. tints["home-copy"])
    end
    config.seed = 23
end)

test("a discovery technology shows its planet's tint, and its other layers stay", function()
    new_game()
    tint_planets()
    local tints = planet_tints.tints
    local technologies = data.raw.technology
    assert(technologies["find-rocky"].icons[1].icon == tint_path("__made-up__/technology/rocky.png", tints.rocky))
    assert(technologies["find-rocky"].icons[2].icon == OVERLAY)
    assert(technologies["find-rocky-copy"].icons[1].icon == tint_path("__made-up__/technology/rocky.png", tints["rocky-copy"]))
    assert(technologies["find-rocky-copy"].icons[2].icon == OVERLAY)
    assert(technologies["find-home-copy"].icons[1].icon == tint_path("__made-up__/icons/home.png", tints["home-copy"]))
end)

test("a space connection's icons show each end as it looks now, and the starting planet's icon stays wherever it shows", function()
    new_game()
    tint_planets()
    local tints = planet_tints.tints
    local connections = data.raw["space-connection"]
    local home_rocky = connections["home-rocky"].icons
    assert(home_rocky[1].icon == ROUTE)
    assert(home_rocky[2].icon == "__made-up__/icons/home.png", "the starting planet's icon changed in a connection")
    assert(home_rocky[3].icon == tint_path("__made-up__/icons/rocky.png", tints.rocky))
    assert(home_rocky[3].scale == 0.333)
    local copies = connections["rocky-copy-home-copy"].icons
    assert(copies[2].icon == tint_path("__made-up__/icons/rocky.png", tints["rocky-copy"]))
    assert(copies[3].icon == tint_path("__made-up__/icons/home.png", tints["home-copy"]))
    local rocky_dusty = connections["rocky-dusty"].icons
    assert(rocky_dusty[2].icon == tint_path("__made-up__/icons/rocky.png", tints.rocky))
    assert(rocky_dusty[3].icon == "__made-up__/icons/dusty.png")
end)

test("an image that a tinted planet shares with an untinted one isn't tinted where others show it", function()
    new_game()
    -- A planet of its own (not a copy) showing the starting planet's icon, which stays the starting planet's
    data.raw.planet.lookalike = planet("lookalike", "__made-up__/icons/home.png", "__made-up__/icons/starmap-home.png")
    tint_planets()
    assert(planet_tints.tints.lookalike ~= nil)
    assert(data.raw.planet.lookalike.icon == tint_path("__made-up__/icons/home.png", planet_tints.tints.lookalike))
    assert(data.raw["space-connection"]["home-rocky"].icons[2].icon == "__made-up__/icons/home.png")
end)

test("the same seed gives the same tints", function()
    new_game()
    tint_planets()
    local first = {}
    for name, degrees in pairs(planet_tints.tints) do
        first[name] = degrees
    end
    new_game()
    tint_planets()
    for name, degrees in pairs(planet_tints.tints) do
        assert(first[name] == degrees, name .. " got another tint")
    end
end)

print(num_passed .. " tests passed")
