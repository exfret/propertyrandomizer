-- Plain-Lua regression tests for surface sets (lib/surface-sets.lua), not loaded by the mod
-- Run from the mod root: lua lib/test-surface-sets.lua
--
-- Every set a plan realizes must be accepted by exactly its rooms, under the conditions the plan gives it and the values it gives the new properties

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

local surface_sets = require("lib/surface-sets")

local num_checks = 0
local function check(condition, message)
    num_checks = num_checks + 1
    if not condition then
        error(message, 2)
    end
end

local function set_of(list)
    local set = {}
    for _, value in pairs(list) do
        set[value] = true
    end
    return set
end

local function describe(set)
    local keys = {}
    for key, _ in pairs(set) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return "{" .. table.concat(keys, ", ") .. "}"
end

local function same_set(a, b)
    for key, _ in pairs(a) do
        if b[key] == nil then
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

-- Checks that every realized request is accepted by exactly its rooms, and that every value is above the default of 0
local function check_plan(plan, requests, room_keys)
    local values = {}
    for _, property in pairs(plan.properties) do
        values[property.name] = property.values
        for _, room in pairs(room_keys) do
            check(property.values[room] ~= nil and property.values[room] > 0, "room " .. room .. " has no positive value of " .. property.name)
        end
    end
    local function value_of(room, property_name)
        return (values[property_name] or {})[room] or 0
    end
    local is_unrealized = set_of(plan.unrealized)
    for _, request in pairs(requests) do
        if is_unrealized[request.id] == nil then
            local conditions = plan.conditions[request.id]
            check(conditions ~= nil, "request " .. request.id .. " has no conditions")
            local accepted = surface_sets.accepting(conditions, room_keys, value_of)
            check(same_set(accepted, request.rooms), "request " .. request.id .. " wants " .. describe(request.rooms) .. " but gets " .. describe(accepted))
            -- A room the game doesn't know yet has every property at its default, so it must accept nothing that has a condition
            if #conditions > 0 then
                local unknown = surface_sets.accepting(conditions, {
                    "unknown",
                }, value_of)
                check(next(unknown) == nil, "request " .. request.id .. " is accepted by a room with default values")
            end
        end
    end
end

local rooms = {
    "planet: a",
    "planet: b",
    "planet: c",
    "planet: d",
    "planet: e",
    "surface: p",
}

-- A request for the given rooms
local function request(id, ...)
    return {
        id = id,
        rooms = set_of({ ... }),
    }
end

-- Sets that are ranges of one order all fit on one property
do
    local requests = {
        request("one", "planet: a"),
        request("two", "planet: a", "planet: b"),
        request("three", "planet: a", "planet: b", "planet: c"),
        request("other", "planet: d"),
    }
    local plan = surface_sets.plan(requests, rooms, surface_sets.POOL)
    check_plan(plan, requests, rooms)
    check(#plan.unrealized == 0, "nested sets were left unrealized")
    check(#plan.properties == 1, "nested sets used " .. #plan.properties .. " properties instead of 1")
end

-- A full set needs no condition, and an empty one can't be realized
do
    local requests = {
        request("everywhere", table.unpack(rooms)),
        request("nowhere"),
    }
    local plan = surface_sets.plan(requests, rooms, surface_sets.POOL)
    check(#plan.conditions["everywhere"] == 0, "a set of every room got conditions")
    check(#plan.unrealized == 1 and plan.unrealized[1] == "nowhere", "an empty set wasn't reported unrealized")
    check_plan(plan, requests, rooms)
end

-- Sets that can't all be ranges of one order (a cycle of overlapping pairs) take more properties
do
    local requests = {
        request("ab", "planet: a", "planet: b"),
        request("bc", "planet: b", "planet: c"),
        request("ca", "planet: c", "planet: a"),
    }
    local plan = surface_sets.plan(requests, rooms, surface_sets.POOL)
    check_plan(plan, requests, rooms)
    check(#plan.unrealized == 0, "a cycle of pairs was left unrealized")
    check(#plan.properties == 2, "a cycle of pairs used " .. #plan.properties .. " properties instead of 2")
end

-- With a pool of one property, what doesn't fit is reported, and what does is still exact
do
    local requests = {
        request("ab", "planet: a", "planet: b"),
        request("bc", "planet: b", "planet: c"),
        request("ca", "planet: c", "planet: a"),
    }
    local plan = surface_sets.plan(requests, rooms, {
        surface_sets.POOL[1],
    })
    check(#plan.unrealized == 1, "a one-property pool realized " .. (3 - #plan.unrealized) .. " of a cycle of 3 pairs")
    check_plan(plan, requests, rooms)
end

-- Plans depend only on their inputs
do
    local requests = {
        request("x", "planet: a", "planet: c"),
        request("y", "planet: b", "planet: c", "planet: d"),
        request("z", "planet: e"),
    }
    local plan1 = surface_sets.plan(requests, rooms, surface_sets.POOL)
    local plan2 = surface_sets.plan({
        requests[3],
        requests[1],
        requests[2],
    }, rooms, surface_sets.POOL)
    check(#plan1.properties == #plan2.properties, "request order changed the number of properties")
    for i, property in pairs(plan1.properties) do
        for _, room in pairs(rooms) do
            check(property.values[room] == plan2.properties[i].values[room], "request order changed " .. property.name .. " on " .. room)
        end
    end
end

-- Random families of sets: whatever is realized is exact, and the default pool realizes everything for a handful of rooms
do
    local state = 12345
    local function random_int(max)
        state = (state * 1103515245 + 12345) % 2147483648
        return math.floor(state / 65536) % max + 1
    end
    local num_unrealized = 0
    for trial = 1, 300 do
        local requests = {}
        for i = 1, random_int(12) do
            local set = {}
            for _, room in pairs(rooms) do
                if random_int(3) == 1 then
                    set[room] = true
                end
            end
            if next(set) == nil then
                set[rooms[random_int(#rooms)]] = true
            end
            table.insert(requests, {
                id = "t" .. trial .. "r" .. i,
                rooms = set,
            })
        end
        local plan = surface_sets.plan(requests, rooms, surface_sets.POOL)
        check_plan(plan, requests, rooms)
        num_unrealized = num_unrealized + #plan.unrealized
    end
    check(num_unrealized == 0, num_unrealized .. " random sets were left unrealized with the default pool")
end

-- Families: a planet copy (orig_name, lib/dupe-planets.lua) is in its original's family, and every other room is its own
data = {
    raw = {
        planet = {
            rocky = {},
            ["rocky-exfret-2-copy"] = {
                orig_name = "rocky",
            },
            mossy = {},
        },
    },
}
lookups = {
    rooms = {
        ["planet: rocky"] = { type = "planet", name = "rocky" },
        ["planet: rocky-exfret-2-copy"] = { type = "planet", name = "rocky-exfret-2-copy" },
        ["planet: mossy"] = { type = "planet", name = "mossy" },
        ["surface: orbit"] = { type = "surface", name = "orbit" },
    },
}
check(surface_sets.family_of("planet: rocky-exfret-2-copy") == "planet: rocky", "a copy is in its original's family")
check(surface_sets.family_of("planet: rocky") == "planet: rocky", "an original is its own family")
check(surface_sets.family_of("planet: mossy") == "planet: mossy", "a planet without copies is its own family")
check(surface_sets.family_of("surface: orbit") == "surface: orbit", "a surface is its own family")
local rocky_rooms = surface_sets.family_rooms("planet: rocky-exfret-2-copy")
check(rocky_rooms["planet: rocky"] and rocky_rooms["planet: rocky-exfret-2-copy"] and rocky_rooms["planet: mossy"] == nil and rocky_rooms["surface: orbit"] == nil, "a family's rooms are the original and its copies")

print("test-surface-sets: " .. num_checks .. " checks passed")
