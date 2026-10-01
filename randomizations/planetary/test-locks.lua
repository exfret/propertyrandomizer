-- Plain-Lua regression tests for planet locks with planet copies (randomizations/planetary/locks.lua), not loaded by the mod
-- Run from the mod root: lua randomizations/planetary/test-locks.lua
--
-- A duplicate's home lock (lib/dupe-planet-locks.lua) is on one copy number of its planets: dupe n on copy n, the original on the originals (user, 2026-09-30).
-- When the lock stage moves it, it must keep that copy number (foundry 2 from Vulcanus 2 to Gleba 2, never to Gleba or Gleba 3), and an original's lock can't go to the starting planet's family, whose original never moves.
-- A lock on whole families still gets whole families. While a home lock is moved, only the move is in the game, and reverting the move brings the home lock back.

-- Stand-ins for the Factorio environment
function table.deepcopy(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end
function log(msg) end
serpent = {
    block = tostring,
    line = tostring,
}
settings = {
    startup = {},
}
mods = {}
-- A seeded generator in place of the mod's (which needs Factorio's bit32), so every draw can be repeated with other seeds
local state = 1
package.loaded["lib/random/rng"] = {
    key = function(params)
        return params.id
    end,
    int = function(_, max)
        state = (state * 1103515245 + 12345) % 2147483648
        return state % max + 1
    end,
    shuffle = function(key, tbl)
        for i = #tbl, 2, -1 do
            local j = package.loaded["lib/random/rng"].int(key, i)
            tbl[i], tbl[j] = tbl[j], tbl[i]
        end
    end,
}
package.loaded["lib/data-utils"] = {
    get_prot = function(_, name)
        return data.raw.entity[name]
    end,
    get_all_prots = function()
        local list = {}
        for _, entity in pairs(data.raw.entity) do
            table.insert(list, entity)
        end
        return list
    end,
    lab_inputs = function()
        return {}
    end,
}

-- Five planets with two copies each; home is the starting planet
local constants = require("helper-tables/constants")
constants.starting_planet = "home"
local PLANETS = {
    "home",
    "ember",
    "moss",
    "storm",
    "frost",
}
local function copy_name(planet, number)
    if number == 1 then
        return planet
    end
    return planet .. "-exfret-" .. number .. "-copy"
end
data = {
    raw = {},
    extend = function(self, prototypes)
        for _, prototype in pairs(prototypes) do
            self.raw[prototype.type] = self.raw[prototype.type] or {}
            self.raw[prototype.type][prototype.name] = prototype
        end
    end,
}
data.raw.planet = {}
data.raw.recipe = {}
data.raw.entity = {}
data.raw["surface-property"] = {}
-- The planets and their copies up to this dupe number, as prototypes and as the logic's rooms
local function set_planets(max_number)
    data.raw.planet = {}
    lookups = {
        rooms = {},
    }
    for _, planet in pairs(PLANETS) do
        for number = 1, max_number do
            local name = copy_name(planet, number)
            data.raw.planet[name] = {
                type = "planet",
                name = name,
                surface_properties = {},
            }
            if number > 1 then
                data.raw.planet[name].orig_name = planet
                data.raw.planet[name].dupe_number = number
            end
            lookups.rooms["planet: " .. name] = {
                type = "planet",
                name = name,
            }
        end
    end
end
set_planets(3)

local surface_sets = require("lib/surface-sets")
local locks = require("randomizations/planetary/locks")

local num_checks = 0
local function check(condition, message)
    num_checks = num_checks + 1
    if not condition then
        error(message, 2)
    end
end

local function room(planet, number)
    return "planet: " .. copy_name(planet, number)
end

local function set_of(list)
    local set = {}
    for _, value in pairs(list) do
        set[value] = true
    end
    return set
end

local function names(set)
    local list = {}
    for key, _ in pairs(set) do
        table.insert(list, key)
    end
    table.sort(list)
    return table.concat(list, ", ")
end

-- The lock kind of a recipe (locks.lua)
local RECIPE = "recipe"

local function candidate(name, rooms)
    return {
        id = "recipe/" .. name,
        kind = RECIPE,
        name = name,
        node_key = "recipe-surface-condition: " .. name,
        accepted = set_of(rooms),
    }
end

-- Copy numbers come from the planet prototypes
check(surface_sets.copy_number(room("ember", 1)) == 1, "an original is copy 1")
check(surface_sets.copy_number(room("ember", 3)) == 3, "a copy has its dupe number")

for seed = 1, 200 do
    state = seed
    data.raw.recipe = {
        ["smelter-2"] = {
            name = "smelter-2",
        },
        smelter = {
            name = "smelter",
        },
        tower = {
            name = "tower",
        },
        conveyor = {
            name = "conveyor",
        },
        lumber = {
            name = "lumber",
        },
    }
    local drawn = locks.draw({
        candidate("smelter-2", {
            room("ember", 2),
        }),
        candidate("smelter", {
            room("ember", 1),
        }),
        candidate("tower", {
            room("home", 2),
            room("moss", 2),
        }),
        candidate("conveyor", {
            room("ember", 1),
            room("ember", 2),
            room("ember", 3),
        }),
        candidate("lumber", {
            room("home", 1),
            room("home", 2),
            room("home", 3),
        }),
    }, "test-locks")

    -- A copy's lock moves to another planet's copy with the same number
    local lock = drawn["recipe/smelter-2"]
    check(lock ~= nil, "seed " .. seed .. ": smelter 2 moved")
    local rooms = names(lock.rooms)
    check(#rooms > 0 and select(2, string.gsub(rooms, "planet: ", "")) == 1, "seed " .. seed .. ": smelter 2 on one planet, not " .. rooms)
    local only = next(lock.rooms)
    check(surface_sets.copy_number(only) == 2 and surface_sets.family_of(only) ~= room("ember", 1), "seed " .. seed .. ": smelter 2 on another planet's copy 2, not " .. rooms)
    check(lock.map[room("ember", 2)] == only, "seed " .. seed .. ": smelter 2's goals follow it")

    -- An original's lock moves to another original, never into the starting planet's family
    lock = drawn["recipe/smelter"]
    check(lock ~= nil, "seed " .. seed .. ": the original smelter moved")
    only = next(lock.rooms)
    check(next(lock.rooms, only) == nil and surface_sets.copy_number(only) == 1 and surface_sets.family_of(only) ~= room("ember", 1) and surface_sets.family_of(only) ~= room("home", 1), "seed " .. seed .. ": the original smelter on another original planet but the start, not " .. names(lock.rooms))

    -- A lock on copy 2 of two planets stays on copy 2 of two planets
    lock = drawn["recipe/tower"]
    if lock ~= nil then
        local families = {}
        for room_key, _ in pairs(lock.rooms) do
            check(surface_sets.copy_number(room_key) == 2, "seed " .. seed .. ": the tower's copies keep number 2, not " .. names(lock.rooms))
            families[surface_sets.family_of(room_key)] = true
        end
        check(select(2, string.gsub(names(lock.rooms), "planet: ", "")) == 2 and select(2, string.gsub(names(families), "planet: ", "")) == 2, "seed " .. seed .. ": the tower on two planets' copy 2, not " .. names(lock.rooms))
    end

    -- A lock on a whole family gets a whole family
    lock = drawn["recipe/conveyor"]
    check(lock ~= nil, "seed " .. seed .. ": the conveyor moved")
    local family = surface_sets.family_of(next(lock.rooms))
    check(family ~= room("ember", 1), "seed " .. seed .. ": the conveyor left its planet")
    if family == room("home", 1) then
        local movable_copies = set_of({
            room("home", 2),
            room("home", 3),
        })
        check(names(lock.rooms) == names(movable_copies), "seed " .. seed .. ": the conveyor on the starting planet's movable copies, not " .. names(lock.rooms))
    else
        local planet = string.match(family, "^planet: (.*)$")
        local whole_family = set_of({
            room(planet, 1),
            room(planet, 2),
            room(planet, 3),
        })
        check(names(lock.rooms) == names(whole_family), "seed " .. seed .. ": the conveyor on a whole family, not " .. names(lock.rooms))
        check(lock.map[room("ember", 2)] == room(planet, 2), "seed " .. seed .. ": the conveyor's copy 2 goals go to copy 2")
    end

    -- The starting planet keeps its place in a lock on its whole family
    lock = drawn["recipe/lumber"]
    check(lock ~= nil and lock.rooms[room("home", 1)] ~= nil, "seed " .. seed .. ": lumber keeps the starting planet")
    check(select(2, string.gsub(names(lock.rooms), "planet: ", "")) == 4, "seed " .. seed .. ": lumber on the starting planet and another whole family, not " .. names(lock.rooms))
end

-- With one copy per planet, the starting planet's copy is its family's only movable room, but a lock on it alone still isn't on the whole family (a sa/dupes-preview load moved biolab 2 from Nauvis 2 to all of Gleba that way)
set_planets(2)
for seed = 1, 100 do
    state = seed
    data.raw.recipe = {
        ["greenhouse-2"] = {
            name = "greenhouse-2",
        },
    }
    local lock = locks.draw({
        candidate("greenhouse-2", {
            room("home", 2),
        }),
    }, "test-locks")["recipe/greenhouse-2"]
    check(lock ~= nil, "seed " .. seed .. ": greenhouse 2 moved")
    local only = next(lock.rooms)
    check(next(lock.rooms, only) == nil and surface_sets.copy_number(only) == 2 and surface_sets.family_of(only) ~= room("home", 1), "seed " .. seed .. ": greenhouse 2 on one other planet's copy 2, not " .. names(lock.rooms))
end
set_planets(3)

-- Realizing: a moved home lock is the one in the game, and reverting the move brings the home lock back; descriptions stay the recipe's own (the game shows where it works from its conditions)
data.raw.recipe = {
    ["smelter-2"] = {
        type = "recipe",
        name = "smelter-2",
        surface_conditions = {
            {
                property = "squishiness",
                min = 4000,
                max = 4000,
            },
        },
        localised_description = {"own"},
    },
}
locks.moved = {}
locks.fixed = {}
locks.fix_home("recipe", "smelter-2", set_of({room("ember", 2)}))
check(locks.fixed["recipe/smelter-2"].movable == true, "fix_home makes a movable fixed lock")
locks.realize()
local function accepted_now()
    return names(surface_sets.accepting(data.raw.recipe["smelter-2"].surface_conditions or {}, surface_sets.room_keys(), surface_sets.value))
end
check(accepted_now() == room("ember", 2), "the home lock is in the game, not " .. accepted_now())
local candidates = locks.candidates()
check(#candidates == 1 and candidates[1].id == "recipe/smelter-2", "a home lock is a lock stage candidate")
state = 7
local drawn = locks.draw(candidates, "test-locks")
locks.moved["recipe/smelter-2"] = drawn["recipe/smelter-2"]
locks.realize()
local moved_to = names(drawn["recipe/smelter-2"].rooms)
check(accepted_now() == moved_to, "the move is in the game (" .. moved_to .. "), not " .. accepted_now())
check(data.raw.recipe["smelter-2"].localised_description[1] == "own", "a move leaves the recipe's description alone")
locks.revert({
    "recipe/smelter-2",
})
check(accepted_now() == room("ember", 2), "reverting the move brings the home lock back, not " .. accepted_now())
check(data.raw.recipe["smelter-2"].localised_description[1] == "own", "a home lock leaves the recipe's description alone")

print("test-locks: " .. num_checks .. " checks passed")
