-- Plain-Lua regression tests for top.intersect_home_sets and top.same_home_sets in context-sort.lua (not loaded by the mod)
-- Run from the mod root: lua lib/graph/test-intersect-home-sets.lua
--
-- Home sets are written out by hand here, as top.home_sets returns them (ids, sets by id with rooms and discovered, and of: room --> id)

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
package.loaded["lib/random/rng"] = {
    int = function(_, max)
        return 1
    end,
}
package.loaded["lib/logic/init"] = {
    contexts = {},
    type_info = {},
}
data = {
    raw = {},
}
package.loaded["lib/data-utils"] = {}

local top = require("lib/graph/context-sort")

local num_checks = 0
local function check(condition, message)
    num_checks = num_checks + 1
    if not condition then
        error(message, 2)
    end
end

local function set_of(...)
    local set = {}
    for _, value in pairs({ ... }) do
        set[value] = true
    end
    return set
end

-- Home sets from room --> list of rooms it needs
local function home_sets_of(needs)
    local home_sets = {
        ids = {},
        sets = {},
        of = {},
    }
    local rooms = {}
    for room, _ in pairs(needs) do
        table.insert(rooms, room)
    end
    table.sort(rooms)
    for i, room in pairs(rooms) do
        local home_id = "home" .. i
        table.insert(home_sets.ids, home_id)
        home_sets.sets[home_id] = {
            rooms = set_of(table.unpack(needs[room])),
            discovered = set_of(room),
        }
        home_sets.of[room] = home_id
    end
    return home_sets
end

local function rooms_of(home_sets, room)
    return home_sets.sets[home_sets.of[room]].rooms
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

-- Each room gets the rooms both sides need, and rooms with the same needs share one home set
do
    local a = home_sets_of({
        far = {
            "home",
            "left",
            "right",
        },
        left = {
            "home",
        },
        right = {
            "home",
        },
    })
    local b = home_sets_of({
        far = {
            "home",
            "left",
        },
        left = {
            "home",
            "station",
        },
        right = {
            "home",
        },
    })
    local both = top.intersect_home_sets(a, b)
    check(same_set(rooms_of(both, "far"), set_of("home", "left")), "far should need home and left")
    check(same_set(rooms_of(both, "left"), set_of("home")), "left should need only home")
    check(both.of["left"] == both.of["right"], "left and right need the same rooms but have different home sets")
    check(#both.ids == 2, "expected 2 home sets, got " .. #both.ids)
    check(top.same_home_sets(both, top.intersect_home_sets(b, a)), "intersection depends on the order")
    check(not top.same_home_sets(a, both), "a changed home set wasn't noticed")
    check(top.same_home_sets(a, top.intersect_home_sets(a, a)), "a home set's intersection with itself changed it")
end

-- A room only one side has keeps that side's needs
do
    local a = home_sets_of({
        far = {
            "home",
            "left",
        },
    })
    local b = home_sets_of({
        new = {
            "home",
        },
    })
    local both = top.intersect_home_sets(a, b)
    check(same_set(rooms_of(both, "far"), set_of("home", "left")), "a room only a has lost its needs")
    check(same_set(rooms_of(both, "new"), set_of("home")), "a room only b has lost its needs")
    check(not top.same_home_sets(a, both), "a new room wasn't noticed")
end

print("test-intersect-home-sets: " .. num_checks .. " checks passed")
