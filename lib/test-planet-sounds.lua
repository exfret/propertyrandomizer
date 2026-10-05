-- Plain Lua tests with the real deterministic RNG.
-- Run from the mod root: lua lib/test-planet-sounds.lua

function log(message) end
config = {seed = 23}
bit32 = {
    bxor = function(a, b) return (a ~ b) & 0xFFFFFFFF end,
    lshift = function(a, n) return (a << n) & 0xFFFFFFFF end,
    rshift = function(a, n) return (a & 0xFFFFFFFF) >> n end,
}
function table.deepcopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for k, v in pairs(value) do copy[k] = table.deepcopy(v) end
    return copy
end

local constants = require("helper-tables/constants")
local rng = require("lib/random/rng")
local sounds = require("lib/planet-sounds")

local function equal(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then return a == b end
    for k, v in pairs(a) do if not equal(v, b[k]) then return false end end
    for k, _ in pairs(b) do if a[k] == nil then return false end end
    return true
end

local function contains(list, name, substring)
    for _, value in pairs(list or {}) do
        if value == name or (substring == true and string.find(name, value, 1, true)) then return true end
    end
    return false
end

local function eligible(track, name)
    return (track.play_on_all_surfaces == true or contains(track.planets, name) or contains(track.surface_names, name, true))
        and not contains(track.exclude_planets, name) and not contains(track.exclude_surface_names, name, true)
end

local function playlist(raw, name)
    local list = {}
    for _, track in pairs(raw["ambient-sound"] or {}) do
        if track.track_type ~= "menu-track" and track.track_type ~= "script-track" and eligible(track, name) then
            -- Audio + weight, independent of the routing clone's name.
            local id = track.sound and track.sound.filename or track.variable_sound.layers[1].name
            list[id] = (list[id] or 0) + (track.weight or 1)
        end
    end
    return list
end

local function environment()
    data = {raw = {}}
    data.raw.planet = {}
    data.raw["ambient-sound"] = {}
    function data:extend(prototypes)
        for _, prototype in pairs(prototypes) do
            assert(self.raw[prototype.type][prototype.name] == nil)
            self.raw[prototype.type][prototype.name] = prototype
        end
    end
    rng.prgs = {}
end

local function planet(name, family, ambience, hidden)
    local prototype = {
        type = "planet",
        name = name,
        orig_name = family,
        persistent_ambient_sounds = table.deepcopy(ambience),
        hidden = hidden,
    }
    data.raw.planet[name] = prototype
    return prototype
end

local function track(name, kind, planets, surfaces, all)
    local prototype = {
        type = "ambient-sound",
        name = name,
        track_type = kind,
        surface_names = surfaces,
        play_on_all_surfaces = all,
        sound = {
            filename = name .. ".ogg",
            volume = 0.7,
        },
    }
    prototype.planets = planets
    data.raw[prototype.type][name] = prototype
    return prototype
end

local function fixture()
    environment()
    local base = {
        base_ambience = {filename = "base.ogg"},
        wind = {filename = "wind.ogg"},
        crossfade = {
            order = {
                "wind",
                "base_ambience",
            },
        },
        semi_persistent = {
            {
                sound = {filename = "gust.ogg"},
                delay_mean_seconds = 9,
            },
        },
    }
    planet(constants.starting_planet, nil, base)
    local other = table.deepcopy(base)
    other.base_ambience = {
        {
            sound = {
                filename = "night.ogg",
                advanced_volume_control = {darkness_threshold = 0.8},
            },
        },
        {sound = {filename = "day.ogg"}},
    }
    planet("moss.+", nil, other)
    planet("cold", nil, {wind = {filename = "cold.ogg"}})
    planet("music-only", nil, nil)
    planet("silent", nil, nil)
    planet("hidden", nil, base, true)
    for _, family in pairs({
        constants.starting_planet,
        "moss.+",
        "cold",
    }) do
        for i = 1, 32 do
            planet(family .. "-copy-" .. i, family, data.raw.planet[family].persistent_ambient_sounds)
        end
    end
    track("start", "hero-track", {constants.starting_planet})
    track("moss-theme", "main-track", {
        "moss.+",
        "outside-location",
    }).weight = 7
    local variable = track("moss-variable", "main-track", {"moss.+"})
    variable.sound = nil
    variable.variable_sound = {
        layers = {
            {
                name = "variable",
                variants = {{filename = "a.ogg"}},
            },
        },
        states = {{name = "begin"}},
        length_seconds = 50,
    }
    track("cold-hero", "hero-track", {"cold"})
    track("only-theme", "main-track", {"music-only"})
    track("moss-surface", "interlude", nil, {"moss.+"}).exclude_surface_names = {"laboratory"}
    local mixed = track("mixed", "main-track", {
        constants.starting_planet,
        "outside-location",
    }, {"cold"})
    mixed.exclude_surface_names = {"laboratory"}
    local broad = track("broad", "main-track", nil, nil, true)
    broad.exclude_planets = {"cold"}
    broad.exclude_surface_names = {"laboratory"}
    track("universal", "interlude", nil, nil, true)
    track("orbital-music", "main-track")
    track("menu", "menu-track")
    track("script", "script-track")
    -- Exercise routing-name collision handling.
    track("moss-surface-propertyrandomizer-planets", "script-track")
    data.raw.fixture_effects = {
        sound = {filename = "machine.ogg"},
        ambient_sounds = {sound = {filename = "trees.ogg"}},
    }
end

fixture()
local before = table.deepcopy(data.raw)
sounds.execute()
local after = table.deepcopy(data.raw)
local assignment = table.deepcopy(sounds.sources)
assert(equal(data.raw.planet[constants.starting_planet], before.planet[constants.starting_planet]), "Starting planet changed")
assert(equal(playlist(data.raw, constants.starting_planet), playlist(before, constants.starting_planet)), "Starting music changed")
assert(sounds.sources.hidden == nil, "Hidden planet randomized")
for name, source in pairs(sounds.sources) do
    local family = before.planet[name].orig_name or name
    assert(source ~= family, "Kept original family: " .. name)
    assert(equal(data.raw.planet[name].persistent_ambient_sounds, before.planet[source].persistent_ambient_sounds), "Split ambient bundle")
    assert(equal(playlist(data.raw, name), playlist(before, source)), "Music does not match donor on " .. name)
    if data.raw.planet[name].persistent_ambient_sounds ~= nil then
        assert(data.raw.planet[name].persistent_ambient_sounds ~= data.raw.planet[source].persistent_ambient_sounds, "Shared mutable ambience")
    end
end
local choices = {}
for i = 1, 32 do choices[assignment["cold-copy-" .. i]] = true end
local count = 0
for _, _ in pairs(choices) do count = count + 1 end
assert(count > 1, "Copies inherited one assignment")
assert(equal(before.fixture_effects, data.raw.fixture_effects), "Entity effects changed")
for _, name in pairs({
    "universal",
    "orbital-music",
    "menu",
    "script",
}) do
    assert(equal(before["ambient-sound"][name], data.raw["ambient-sound"][name]), "Unrelated track changed")
end
for _, name in pairs({
    "outside-location",
    "cold-laboratory",
    "moss.+-laboratory",
    "moss.+-custom-surface",
    "unrelated-surface",
    "hidden",
}) do
    assert(equal(playlist(before, name), playlist(data.raw, name)), "Unrelated surface music changed on " .. name)
end
fixture()
sounds.execute()
assert(equal(data.raw, after) and equal(sounds.sources, assignment), "Same seed/data gave a different result")
fixture()
config.seed = 24
sounds.execute()
assert(not equal(sounds.sources, assignment), "Seed had no effect")

-- One configuration, copies with no direct music routing, and no ambience.
environment()
planet("alone", nil, nil)
planet("copy", "alone", nil)
track("only", "main-track", {"alone"})
sounds.execute()
assert(sounds.sources.copy == "alone" and contains(data.raw["ambient-sound"].only.planets, "copy"), "Single profile fallback lost music")

-- Identical configurations under different names aren't alternatives.
environment()
planet("a", nil, {wind = {filename = "same.ogg"}})
planet("b", nil, {wind = {filename = "same.ogg"}})
planet("c", nil, {wind = {filename = "other.ogg"}})
sounds.execute()
assert(sounds.sources.a == "c" and sounds.sources.b == "c", "Identical ambience counted as an alternative")

-- Different music mustn't make the same ambient configuration an alternative when another ambient configuration exists.
environment()
planet("a", nil, {wind = {filename = "same.ogg"}})
planet("b", nil, {wind = {filename = "same.ogg"}})
planet("c", nil, {wind = {filename = "other.ogg"}})
track("a-theme", "main-track", {"a"})
track("b-theme", "main-track", {"b"})
sounds.execute()
assert(sounds.sources.a == "c" and sounds.sources.b == "c", "Different playlists allowed original ambient audio")

-- The starting planet remains an available audio donor when it is the only way to replace recognizable ambience.
environment()
planet(constants.starting_planet, nil, {wind = {filename = "different.ogg"}})
planet("a", nil, {wind = {filename = "same.ogg"}})
planet("b", nil, {wind = {filename = "same.ogg"}})
track("a-theme", "main-track", {"a"})
track("b-theme", "main-track", {"b"})
sounds.execute()
assert(sounds.sources.a == constants.starting_planet and sounds.sources.b == constants.starting_planet)

-- Original identities form a permutation when distinct profiles permit it; copies draw separately.
environment()
planet(constants.starting_planet, nil, {wind = {filename = "home.ogg"}})
local original_names = {
    "red-rock",
    "blue-rock",
    "green-rock",
    "gold-rock",
}
for _, name in pairs(original_names) do
    planet(name, nil, {wind = {filename = name .. ".ogg"}})
    planet(name .. "-copy", name, data.raw.planet[name].persistent_ambient_sounds)
end
sounds.execute()
local taken = {}
for _, name in pairs(original_names) do
    local source = sounds.sources[name]
    assert(source ~= name and source ~= constants.starting_planet, "Original shuffle kept or introduced an exempt identity")
    assert(taken[source] == nil, "Originals reused a profile despite a valid permutation")
    taken[source] = true
    assert(sounds.sources[name .. "-copy"] ~= name, "Copy kept its family in the original shuffle")
end

environment()
planet("silent", nil, nil)
sounds.execute()
assert(next(sounds.sources) == nil and data.raw.planet.silent.persistent_ambient_sounds == nil)
environment()
sounds.execute()
assert(next(sounds.sources) == nil)
print("Planet sound tests passed: bundles, selectors, copies, deterministic RNG, exemptions and missing profiles")
