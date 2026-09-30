-- Plain-Lua regression tests for random planet names (lib/planet-names.lua), not loaded by the mod
-- Run from the mod root: lua lib/test-planet-names.lua

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

local rng = require("lib/random/rng")
local planet_names = require("lib/planet-names")

-- Names every planet with the random stream from its start, as each load of the game does
local function name_planets()
    rng.prgs = {}
    planet_names.execute()
end

local function planet(name, hidden)
    return {
        type = "planet",
        name = name,
        hidden = hidden,
    }
end

local function discovery(name, locations)
    local effects = {}
    for _, location in pairs(locations) do
        table.insert(effects, {
            type = "unlock-space-location",
            space_location = location,
        })
    end
    return {
        type = "technology",
        name = name,
        effects = effects,
    }
end

-- Made-up planet names, since the module mustn't depend on which planets there are; edge is a space location that isn't a planet
local function new_game()
    data = {
        raw = {
            planet = {
                alpha = planet("alpha"),
                beta = planet("beta"),
                gamma = planet("gamma"),
                hidden = planet("hidden", true),
            },
            technology = {
                ["find-alpha"] = discovery("find-alpha", {
                    "alpha",
                }),
                ["find-beta-and-gamma"] = discovery("find-beta-and-gamma", {
                    "beta",
                    "gamma",
                }),
                ["find-hidden"] = discovery("find-hidden", {
                    "hidden",
                }),
                ["find-edge"] = discovery("find-edge", {
                    "edge",
                }),
                ["no-effects"] = {
                    type = "technology",
                    name = "no-effects",
                },
            },
        },
    }
end

-- Every name the parts can make, and the vanilla ones, from the parts as the module's header gives them
local vanilla_parts = {
    {
        "Nau",
        "v",
        "is",
    },
    {
        "Gle",
        "b",
        "a",
    },
    {
        "Ful",
        "go",
        "ra",
    },
    {
        "Vul",
        "can",
        "us",
    },
    {
        "Aqui",
        "l",
        "o",
    },
}
local mixes = {}
local vanilla_names = {}
for _, first in pairs(vanilla_parts) do
    for _, middle in pairs(vanilla_parts) do
        for _, last in pairs(vanilla_parts) do
            mixes[first[1] .. middle[2] .. last[3]] = true
        end
    end
    vanilla_names[first[1] .. first[2] .. first[3]] = true
end

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

test("every planet that isn't hidden gets its own name, mixed from the vanilla parts and not a vanilla name", function()
    new_game()
    name_planets()
    local seen = {}
    for _, name in pairs({
        "alpha",
        "beta",
        "gamma",
    }) do
        local new_name = data.raw.planet[name].localised_name
        assert(type(new_name) == "string", name .. " got no name")
        assert(mixes[new_name] ~= nil, new_name .. " isn't a mix of the parts")
        assert(vanilla_names[new_name] == nil, name .. " got the vanilla name " .. new_name)
        assert(seen[new_name] == nil, new_name .. " given twice")
        assert(planet_names.new_names[name] == new_name)
        seen[new_name] = true
    end
    assert(data.raw.planet.hidden.localised_name == nil)
    assert(planet_names.new_names.hidden == nil)
end)

test("a technology discovering just one renamed planet is named after its new name, and no other technology is renamed", function()
    new_game()
    name_planets()
    local name = data.raw.technology["find-alpha"].localised_name
    assert(name[1] == "propertyrandomizer.planet_discovery" and name[2] == data.raw.planet.alpha.localised_name and #name == 2)
    for _, tech_name in pairs({
        "find-beta-and-gamma",
        "find-hidden",
        "find-edge",
        "no-effects",
    }) do
        assert(data.raw.technology[tech_name].localised_name == nil, tech_name .. " was renamed")
    end
end)

test("a planet made later (a copy) gets a name no other planet has", function()
    new_game()
    name_planets()
    local copy = planet("alpha-copy")
    data.raw.planet[copy.name] = copy
    local new_name = planet_names.name(copy)
    assert(new_name ~= nil and copy.localised_name == new_name and mixes[new_name] ~= nil and vanilla_names[new_name] == nil)
    for _, name in pairs({
        "alpha",
        "beta",
        "gamma",
    }) do
        assert(data.raw.planet[name].localised_name ~= new_name, "the copy got " .. name .. "'s name")
    end
end)

test("a renamed planet's locale key in a localised string becomes its new name, wherever it's nested, and nothing else changes", function()
    new_game()
    name_planets()
    local copy = planet("alpha-copy")
    data.raw.planet[copy.name] = copy
    planet_names.name(copy)
    data.raw.recipe = {
        variant = {
            type = "recipe",
            name = "variant",
            localised_name = {
                "",
                {
                    "recipe-name.concrete",
                },
                " (",
                {
                    "space-location-name.beta",
                },
                ")",
            },
            localised_description = {
                "space-location-name.alpha-copy",
            },
        },
        fallback = {
            type = "recipe",
            name = "fallback",
            localised_name = {
                "?",
                {
                    "space-location-name.gamma",
                },
                "gamma",
            },
            factoriopedia_description = {
                "",
                {
                    "space-location-name.edge",
                },
                {
                    "space-location-name.hidden",
                },
                "space-location-name.alpha",
            },
        },
    }
    planet_names.fix_references()
    local variant = data.raw.recipe.variant
    assert(variant.localised_name[4] == data.raw.planet.beta.localised_name)
    assert(variant.localised_name[2][1] == "recipe-name.concrete" and variant.localised_name[1] == "" and variant.localised_name[5] == ")")
    assert(variant.localised_description == copy.localised_name)
    local fallback = data.raw.recipe.fallback
    assert(fallback.localised_name[2] == data.raw.planet.gamma.localised_name and fallback.localised_name[3] == "gamma")
    -- Keys of locations that weren't renamed stay, and a plain string is text rather than a key
    local other = fallback.factoriopedia_description
    assert(other[2][1] == "space-location-name.edge" and other[3][1] == "space-location-name.hidden" and other[4] == "space-location-name.alpha")
    -- The planets' own names are plain strings already
    assert(type(data.raw.planet.alpha.localised_name) == "string")
end)

test("once every mix is given, a planet keeps its name", function()
    new_game()
    data.raw.planet = {}
    data.raw.technology = {}
    for i = 1, 130 do
        local name = string.format("planet-%03d", i)
        data.raw.planet[name] = planet(name)
    end
    name_planets()
    local num_named = 0
    local seen = {}
    for _, prototype in pairs(data.raw.planet) do
        if prototype.localised_name ~= nil then
            assert(seen[prototype.localised_name] == nil, prototype.localised_name .. " given twice")
            seen[prototype.localised_name] = true
            num_named = num_named + 1
        end
    end
    -- 5 * 5 * 5 mixes, less the 5 vanilla names
    assert(num_named == 120, num_named .. " planets named")
    assert(planet_names.name(planet("late")) == nil)
end)

test("the same seed gives the same names", function()
    new_game()
    name_planets()
    local names = {}
    for name, prototype in pairs(data.raw.planet) do
        names[name] = prototype.localised_name
    end
    new_game()
    name_planets()
    for name, prototype in pairs(data.raw.planet) do
        assert(prototype.localised_name == names[name], name .. " got another name")
    end
end)

print(num_passed .. " tests passed")
