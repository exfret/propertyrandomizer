-- Random planet tints (config.planet_tints: with the duplicates): every planet but the starting one looks like a hue rotation of its original, a random one per game
-- The rotations are made offline (dev/make-dupe-graphics.py, from a planet line's tints= in dev/dupe-planets.txt) and listed per original image in lib/planet-tint-manifest.lua
-- A planet takes one rotation for all its images: its icon and star map icon, the images of the technologies discovering it, and its icon wherever another prototype shows it (a space connection's icons show its two ends)
-- A planet copy (lib/dupe-planets.lua) is tinted from its original's images, in place of its own recolor; a planet and its copies each take a rotation at least MIN_GAP degrees from the others' where there is one, and a starting planet's copies keep that far from its untinted look
-- Runs at the end of data-final-fixes.lua, once the duplicates and planetary randomization have made every planet, technology and connection that shows a planet

local constants = require("helper-tables/constants")
local rng = require("lib/random/rng")
local tint_manifest = require("lib/planet-tint-manifest")

local planet_tints = {}

-- How far apart (degrees of hue rotation) a planet's and its copies' tints are kept when the tints allow it
local MIN_GAP = 90
-- A recolored copy's path (graphics/dupes/<folder>/<mod>/<path>, dev/make-dupe-graphics.py): its mod and the path within the mod
local RECOLORED_PATTERN = "^__propertyrandomizer__/graphics/dupes/[^/]+/([^/]+)/(.*)$"

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

-- The original image a path shows, for a recolored copy's path; other paths are their own original
local function original_path(path)
    local mod_name, rest = string.match(path, RECOLORED_PATTERN)
    if mod_name ~= nil then
        return "__" .. mod_name .. "__/" .. rest
    end
    return path
end

-- The path of the image tinted by the rotation, or nil when there's no such tint
local function tinted_path(path, degrees)
    local original = original_path(path)
    for _, available in pairs(tint_manifest.files[original] or {}) do
        if available == degrees then
            local mod_name, rest = string.match(original, "^__([^/]+)__/(.*)$")
            return "__propertyrandomizer__/graphics/dupes/tint-" .. degrees .. "/" .. mod_name .. "/" .. rest
        end
    end
    return nil
end

-- The layers of a prototype that show images (its icon, its icons, its star map icon and icons): tables whose image field holds the path
local function image_slots(prototype)
    local slots = {}
    if type(prototype.icon) == "string" then
        table.insert(slots, {
            tbl = prototype,
            field = "icon",
        })
    end
    if type(prototype.starmap_icon) == "string" then
        table.insert(slots, {
            tbl = prototype,
            field = "starmap_icon",
        })
    end
    for _, list_field in pairs({
        "icons",
        "starmap_icons",
    }) do
        if type(prototype[list_field]) == "table" then
            for _, layer in pairs(prototype[list_field]) do
                if type(layer) == "table" and type(layer.icon) == "string" then
                    table.insert(slots, {
                        tbl = layer,
                        field = "icon",
                    })
                end
            end
        end
    end
    return slots
end

-- The rotations every image of the planet has a tint for (sorted), none when one of its images has none
local function available_tints(planet)
    local counts = {}
    local slots = image_slots(planet)
    for _, slot in pairs(slots) do
        for _, degrees in pairs(tint_manifest.files[original_path(slot.tbl[slot.field])] or {}) do
            counts[degrees] = (counts[degrees] or 0) + 1
        end
    end
    local available = {}
    for _, degrees in pairs(sorted_keys(counts)) do
        if #slots > 0 and counts[degrees] == #slots then
            table.insert(available, degrees)
        end
    end
    return available
end

local function hue_gap(a, b)
    local gap = math.abs(a - b) % 360
    return math.min(gap, 360 - gap)
end

-- A random one of the rotations at least MIN_GAP from every taken one, or else one as far from them as any
local function pick(key, available, taken)
    local candidates = {}
    local best_gap = nil
    for _, degrees in pairs(available) do
        local gap = 360
        for _, other in pairs(taken) do
            gap = math.min(gap, hue_gap(degrees, other))
        end
        gap = math.min(gap, MIN_GAP)
        if best_gap == nil or gap > best_gap then
            candidates = {}
            best_gap = gap
        end
        if gap == best_gap then
            table.insert(candidates, degrees)
        end
    end
    return candidates[rng.int(key, #candidates)]
end

-- The one planet a technology discovers among the given ones (its only unlock-space-location effect for one of them), or nil
local function discovered_planet(tech, planets)
    local found = nil
    for _, effect in pairs(tech.effects or {}) do
        if effect.type == "unlock-space-location" and planets[effect.space_location] ~= nil then
            if found ~= nil and found ~= effect.space_location then
                return nil
            end
            found = effect.space_location
        end
    end
    return found
end

-- Swaps each image of the prototype that has a tint for the rotation to the tint; returns how many were swapped
local function tint_images(prototype, degrees)
    local num_swapped = 0
    for _, slot in pairs(image_slots(prototype)) do
        local new_path = tinted_path(slot.tbl[slot.field], degrees)
        if new_path ~= nil then
            slot.tbl[slot.field] = new_path
            num_swapped = num_swapped + 1
        end
    end
    return num_swapped
end

-- Planet name --> the rotation its images got (the last execute's)
planet_tints.tints = {}

-- Tints every planet but the starting one, and wherever its images show
planet_tints.execute = function()
    local key = rng.key({
        id = "planet-tints",
    })
    planet_tints.tints = {}
    -- Families: an original planet and its copies, which show the same images
    local families = {}
    for _, name in pairs(sorted_keys(data.raw.planet or {})) do
        local planet = data.raw.planet[name]
        if planet.hidden ~= true then
            local family = planet.orig_name or name
            families[family] = families[family] or {}
            table.insert(families[family], planet)
        end
    end
    local untinted = {}
    for _, family in pairs(sorted_keys(families)) do
        -- A member left as it is shows the untinted look, which the others keep away from
        local taken = {}
        local tintable = {}
        for _, planet in pairs(families[family]) do
            local available = available_tints(planet)
            if planet.name == constants.starting_planet or #available == 0 then
                table.insert(untinted, planet.name)
                taken = {
                    0,
                }
            else
                table.insert(tintable, {
                    planet = planet,
                    available = available,
                })
            end
        end
        for _, entry in pairs(tintable) do
            local degrees = pick(key, entry.available, taken)
            planet_tints.tints[entry.planet.name] = degrees
            table.insert(taken, degrees)
        end
    end

    -- What shows a tinted planet's images elsewhere shows them tinted too, except an image an untinted planet or another tint shows as well
    local swaps = {}
    local shared = {}
    for _, name in pairs(sorted_keys(planet_tints.tints)) do
        for _, slot in pairs(image_slots(data.raw.planet[name])) do
            local path = slot.tbl[slot.field]
            local new_path = tinted_path(path, planet_tints.tints[name])
            if swaps[path] ~= nil and swaps[path] ~= new_path then
                shared[path] = true
            end
            swaps[path] = new_path
        end
    end
    for _, name in pairs(untinted) do
        for _, slot in pairs(image_slots(data.raw.planet[name])) do
            shared[slot.tbl[slot.field]] = true
        end
    end
    for path, _ in pairs(shared) do
        swaps[path] = nil
    end

    local num_images = 0
    for name, degrees in pairs(planet_tints.tints) do
        num_images = num_images + tint_images(data.raw.planet[name], degrees)
    end
    local num_techs = 0
    for _, tech in pairs(data.raw.technology or {}) do
        local planet = discovered_planet(tech, planet_tints.tints)
        if planet ~= nil and tint_images(tech, planet_tints.tints[planet]) > 0 then
            num_techs = num_techs + 1
        end
    end
    local num_shown = 0
    for class_name, class in pairs(data.raw) do
        if class_name ~= "planet" then
            for _, prototype in pairs(class) do
                for _, slot in pairs(image_slots(prototype)) do
                    local new_path = swaps[slot.tbl[slot.field]]
                    if new_path ~= nil then
                        slot.tbl[slot.field] = new_path
                        num_shown = num_shown + 1
                    end
                end
            end
        end
    end

    local tints = {}
    for _, name in pairs(sorted_keys(planet_tints.tints)) do
        table.insert(tints, name .. " " .. planet_tints.tints[name])
    end
    log("Planet tints (hue rotation in degrees): " .. table.concat(tints, ", ") .. "; untinted: " .. table.concat(untinted, ", ") .. "; " .. num_images .. " planet images, " .. num_techs .. " discovery technologies, " .. num_shown .. " images shown by other prototypes")
end

return planet_tints
