-- Planet audio identity, with config.planet_names, after all planet copies exist.
-- Keep persistent ambience (including its crossfade and semi-persistent sounds) and the planet's music playlist together. Each copy draws independently.
-- Verified against installed Factorio 2.1.20 docs: PlanetPrototype, PersistentWorldAmbientSoundsDefinition, AmbientSound and AmbientSoundType.
-- Entity/tile ambience, effects, processions and space-only music are untouched.

local constants = require("src/config/constants")
local rng = require("src/lib/random/rng")

local planet_sounds = {}

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

local function equal(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then
        return a == b
    end
    for key, value in pairs(a) do
        if not equal(value, b[key]) then
            return false
        end
    end
    for key, _ in pairs(b) do
        if a[key] == nil then
            return false
        end
    end
    return true
end

local function contains(list, name)
    for _, value in pairs(list or {}) do
        if value == name then
            return true
        end
    end
    return false
end

-- AmbientSound surface selectors are literal substrings, not Lua patterns.
local function matches(list, name)
    for _, value in pairs(list or {}) do
        if string.find(name, value, 1, true) ~= nil then
            return true
        end
    end
    return false
end

local function plays_on(track, name)
    return (track.play_on_all_surfaces == true or contains(track.planets, name) or matches(track.surface_names, name))
        and not contains(track.exclude_planets, name) and not matches(track.exclude_surface_names, name)
end

-- Only automatically played world music: menu and script tracks retain their selectors and identity. AmbientSoundType documents these three world types.
local function world_track(track)
    return track.track_type == "main-track" or track.track_type == "interlude" or track.track_type == "hero-track"
end

-- A complete track without its routing or identifier, for comparing profiles by configuration rather than planet or track names.
local function payload(track)
    local copy = table.deepcopy(track)
    copy.name = nil
    copy.planets = nil
    copy.surface_names = nil
    copy.play_on_all_surfaces = nil
    copy.exclude_planets = nil
    copy.exclude_surface_names = nil
    return copy
end

local function same_profile(a, b)
    if not equal(a.ambience, b.ambience) or #a.music ~= #b.music then
        return false
    end
    -- Compare playlists as multisets: two differently named tracks may carry the same audio configuration, and that isn't an alternative identity.
    local used = {}
    for _, track in pairs(a.music) do
        local found = nil
        for i, other in pairs(b.music) do
            if used[i] == nil and equal(track.payload, other.payload) then
                found = i
                break
            end
        end
        if found == nil then
            return false
        end
        used[found] = true
    end
    return true
end

local function alternatives(original, pool)
    local candidates = {}
    local different_ambience = {}
    for _, donor in pairs(pool) do
        if not same_profile(donor, original) then
            table.insert(candidates, donor)
            if not equal(donor.ambience, original.ambience) then
                table.insert(different_ambience, donor)
            end
        end
    end
    -- A different playlist alone mustn't leave recognizable family ambience when another ambience exists.
    if #different_ambience > 0 then
        return different_ambience
    end
    return candidates
end

-- Originals shuffle among themselves without replacement wherever a family-safe permutation exists.
-- A repeated configuration can make a full permutation impossible; unmatched originals use the independent alternative picker below.
local function shuffle_originals(profiles, planets, donors)
    local order = {}
    local pool = {}
    for _, name in pairs(sorted_keys(profiles)) do
        local planet = planets[name]
        local profile = profiles[name]
        if planet.hidden ~= true and planet.orig_name == nil and name ~= constants.starting_planet
            and (profile.ambience ~= nil or #profile.music > 0) then
            table.insert(order, name)
            table.insert(pool, profile)
        end
    end
    local key = rng.key({id = "planet-sounds-originals"})
    rng.shuffle(key, order)
    rng.shuffle(key, pool)
    local choices = {}
    for _, name in pairs(order) do
        choices[name] = alternatives(profiles[name], pool)
        -- The exempt starting identity may be the only different ambience in the full pool; use the fallback rather than shuffling recognizable wind between originals.
        local available = alternatives(profiles[name], donors)
        if #available > 0 and not equal(available[1].ambience, profiles[name].ambience) then
            local distinct = {}
            for _, source in pairs(choices[name]) do
                if not equal(source.ambience, profiles[name].ambience) then
                    table.insert(distinct, source)
                end
            end
            choices[name] = distinct
        end
    end
    local owners = {}
    local selected = {}
    local function place(name, seen)
        for _, source in pairs(choices[name]) do
            if seen[source.name] == nil then
                seen[source.name] = true
                local owner = owners[source.name]
                if owner == nil or place(owner, seen) then
                    owners[source.name] = name
                    selected[name] = source
                    return true
                end
            end
        end
        return false
    end
    for _, name in pairs(order) do
        place(name, {})
    end
    return selected
end

-- The donor planet for each assignment, exposed for diagnostics and tests.
planet_sounds.sources = {}

planet_sounds.execute = function()
    planet_sounds.sources = {}
    local planets = data.raw.planet or {}
    local tracks = data.raw["ambient-sound"] or {}
    local profiles = {}
    local donors = {}
    -- Snapshot before changing any planet or routing; copies don't add weight to the donor pool. Hidden planets follow the name/tint exemption.
    for _, name in pairs(sorted_keys(planets)) do
        local planet = planets[name]
        local profile = {
            name = name,
            ambience = table.deepcopy(planet.persistent_ambient_sounds),
            music = {},
        }
        for _, track_name in pairs(sorted_keys(tracks)) do
            local track = tracks[track_name]
            if world_track(track) and plays_on(track, name) then
                table.insert(profile.music, {
                    name = track_name,
                    payload = payload(track),
                })
            end
        end
        profiles[name] = profile
        if planet.hidden ~= true and planet.orig_name == nil and (profile.ambience ~= nil or #profile.music > 0) then
            local distinct = true
            for _, other in pairs(donors) do
                if same_profile(profile, other) then
                    distinct = false
                    break
                end
            end
            if distinct then
                table.insert(donors, profile)
            end
        end
    end

    local shuffled = shuffle_originals(profiles, planets, donors)
    local assigned = {}
    for _, name in pairs(sorted_keys(planets)) do
        local planet = planets[name]
        if planet.hidden ~= true and name ~= constants.starting_planet and #donors > 0 then
            local original = profiles[planet.orig_name or name] or profiles[name]
            local candidates = alternatives(original, donors)
            -- No distinct alternative: retain the family's configuration, including giving copies its music, without drawing from an empty pool.
            local source = shuffled[name] or original
            if shuffled[name] == nil and #candidates > 0 then
                source = candidates[rng.int(rng.key({
                    id = "planet-sounds",
                    prototype = planet,
                }), #candidates)]
            end
            assigned[name] = source
            planet_sounds.sources[name] = source.name
            planet.persistent_ambient_sounds = table.deepcopy(source.ambience)
        end
    end

    local additions = {}
    for _, track_name in pairs(sorted_keys(tracks)) do
        local track = tracks[track_name]
        if world_track(track) then
            local destinations = {}
            for _, name in pairs(sorted_keys(assigned)) do
                for _, entry in pairs(assigned[name].music) do
                    if entry.name == track_name then
                        table.insert(destinations, name)
                        break
                    end
                end
            end
            local retained = {}
            local changed = false
            for _, name in pairs(track.planets or {}) do
                if assigned[name] == nil then
                    table.insert(retained, name)
                end
            end
            -- Broad surface routes must stop selecting the randomized planets, even when a planet's old playlist gets no destinations this time.
            for name, _ in pairs(assigned) do
                if plays_on(track, name) ~= contains(destinations, name) then
                    changed = true
                end
            end
            if changed then
                if track.surface_names ~= nil or track.play_on_all_surfaces == true then
                    -- Preserve the original routing on other surfaces. A separate planet-only route avoids substring leakage between copies and obeys AmbientSound's exclusion/selector compatibility rules.
                    for _, name in pairs(retained) do
                        if plays_on(track, name) and not contains(destinations, name) then
                            table.insert(destinations, name)
                        end
                    end
                    if #destinations > 0 then
                        local copy = payload(track)
                        local name = track_name .. "-propertyrandomizer-planets"
                        while tracks[name] ~= nil do
                            name = name .. "-copy"
                        end
                        copy.name = name
                        copy.planets = destinations
                        table.insert(additions, copy)
                    end
                    track.planets = nil
                    track.exclude_planets = track.exclude_planets or {}
                    for _, name in pairs(sorted_keys(assigned)) do
                        if not contains(track.exclude_planets, name) then
                            table.insert(track.exclude_planets, name)
                        end
                    end
                    -- Explicit non-randomized destinations now use the copy, without also gaining a second eligible track via the broad route.
                    for _, name in pairs(retained) do
                        if not contains(track.exclude_planets, name) then
                            table.insert(track.exclude_planets, name)
                        end
                    end
                else
                    for _, name in pairs(retained) do
                        table.insert(destinations, name)
                    end
                    track.planets = destinations
                end
            end
        end
    end
    if #additions > 0 then
        data:extend(additions)
    end
    for _, name in pairs(sorted_keys(planet_sounds.sources)) do
        log("Planet sounds: " .. name .. " <- " .. planet_sounds.sources[name])
    end
end

return planet_sounds
