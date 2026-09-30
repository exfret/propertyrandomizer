-- Random planet names (config.planet_names: planetary randomization, the unified randomizations and the duplicates all on)
-- Every planet gets a name of a prefix, a root and a suffix, each from any of the vanilla planets' names (Nau-v-is, Gle-b-a, Ful-go-ra, Vul-can-us, Aqui-l-o), like Glecanus or Aquigora
-- No two planets share a name, and none gets a vanilla name (all three parts from one planet), so no planet passes for another
-- Names are given before the duplicates and planetary changes (planet_names.execute, from data-final-fixes.lua), so what those name after a planet (copies, discovery technologies, space connections) takes its new name from the prototype; a planet made later, like a copy, takes a name of its own (planet_names.name)
-- Localised strings made along the way that name a planet by its locale key get its new name at the end (planet_names.fix_references)

local rng = require("lib/random/rng")

local planet_names = {}

-- The vanilla planets' names as prefix-root-suffix
local VANILLA_PARTS = {
    "Nau-v-is",
    "Gle-b-a",
    "Ful-go-ra",
    "Vul-can-us",
    "Aqui-l-o",
}
-- The fields of a prototype holding localised strings that can name a planet
local STRING_FIELDS = {
    "localised_name",
    "localised_description",
    "factoriopedia_description",
}
-- A planet's locale key, which a string names it by when it doesn't take the planet's localised name
local LOCALE_KEY_PATTERN = "^space%-location%-name%.(.+)$"

-- Planet name --> the name it goes by now
planet_names.new_names = {}
-- The names left to give, taken from the end
local unused = {}

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

-- Every mix of the vanilla parts except the vanilla names themselves, in a random order
local function shuffled_names()
    local splits = {}
    for _, parts in pairs(VANILLA_PARTS) do
        local prefix, root, suffix = string.match(parts, "^(.-)%-(.-)%-(.-)$")
        table.insert(splits, {
            prefix = prefix,
            root = root,
            suffix = suffix,
        })
    end
    local names = {}
    for i, first in pairs(splits) do
        for j, middle in pairs(splits) do
            for k, last in pairs(splits) do
                if i ~= j or j ~= k then
                    table.insert(names, first.prefix .. middle.root .. last.suffix)
                end
            end
        end
    end
    rng.shuffle(rng.key({
        id = "planet-names",
    }), names)
    return names
end

-- The one space location a technology discovers (its only unlock-space-location effect), or nil
local function discovered_location(tech)
    local found = nil
    for _, effect in pairs(tech.effects or {}) do
        if effect.type == "unlock-space-location" then
            if found ~= nil then
                return nil
            end
            found = effect.space_location
        end
    end
    return found
end

-- The localised string with each string of just a renamed planet's locale key in it (like {"space-location-name.gleba"}) swapped for the planet's new name, and how many were swapped
local function fixed(str)
    if type(str) ~= "table" then
        return str, 0
    end
    if type(str[1]) == "string" then
        local planet_name = string.match(str[1], LOCALE_KEY_PATTERN)
        if planet_name ~= nil and planet_names.new_names[planet_name] ~= nil then
            return planet_names.new_names[planet_name], 1
        end
    end
    local num_fixed = 0
    for ind, param in pairs(str) do
        local new_param, num = fixed(param)
        str[ind] = new_param
        num_fixed = num_fixed + num
    end
    return str, num_fixed
end

-- Gives the planet the next name left and returns it; once they're all given, returns nil and the planet keeps its name
planet_names.name = function(planet)
    local name = table.remove(unused)
    if name == nil then
        log("Planet names: none left for " .. planet.name .. ", so it keeps its name")
        return nil
    end
    planet.localised_name = name
    planet_names.new_names[planet.name] = name
    log("Planet names: " .. planet.name .. " is " .. name)
    return name
end

-- Names every planet that isn't hidden, and each technology discovering just one of them after its new name
planet_names.execute = function()
    planet_names.new_names = {}
    unused = shuffled_names()
    for _, name in pairs(sorted_keys(data.raw.planet or {})) do
        local planet = data.raw.planet[name]
        if planet.hidden ~= true then
            planet_names.name(planet)
        end
    end
    local num_techs = 0
    for _, tech in pairs(data.raw.technology or {}) do
        local location = discovered_location(tech)
        if location ~= nil and planet_names.new_names[location] ~= nil then
            tech.localised_name = {
                "propertyrandomizer.planet_discovery",
                planet_names.new_names[location],
            }
            num_techs = num_techs + 1
        end
    end
    log("Planet names: " .. num_techs .. " discovery technologies named after their planet's new name")
end

-- Swaps each renamed planet's locale key in the prototypes' localised strings for its new name, for strings that named a planet by its key (like a planet variant's "Concrete (Gleba)" in randomizations/planetary/scaffolds.lua)
planet_names.fix_references = function()
    local num_fixed = 0
    for _, class in pairs(data.raw) do
        for _, prototype in pairs(class) do
            for _, field in pairs(STRING_FIELDS) do
                local new_value, num = fixed(prototype[field])
                prototype[field] = new_value
                num_fixed = num_fixed + num
            end
        end
    end
    log("Planet names: " .. num_fixed .. " planet locale keys in localised strings now name the planet's new name")
end

return planet_names
