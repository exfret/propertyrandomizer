-- Plain-Lua regression tests for context numbers (src/logic/contexts/contexts.lua), not loaded by the mod
-- Run from the mod root: lua tests/unit/logic/contexts/test-contexts.lua
--
-- The numbering is the module's own state, kept for a whole load, so each test numbers rooms in a fresh copy of the module

local dupe_graphics = require("src/prototypes/duplicates/dupe-graphics-manifest")

local messages = {}
function log(msg)
    table.insert(messages, msg)
end

local num_passed = 0
local function test(name, fn)
    messages = {}
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

-- Planet copies, as room key --> its original's room key and its dupe number
local COPIES = {
    ["planet: rock-2"] = {
        original = "planet: rock",
        number = 2,
    },
    ["planet: home-2"] = {
        original = "planet: home",
        number = 2,
    },
    ["planet: moss-2"] = {
        original = "planet: moss",
        number = 2,
    },
    ["planet: moss-3"] = {
        original = "planet: moss",
        number = 3,
    },
    -- Claims rock-2's number
    ["planet: rock-2b"] = {
        original = "planet: rock",
        number = 2,
    },
}
-- The starting planet, which isn't first by name
local START = "planet: rock"

-- A fresh copy of the module numbering from start, with copies telling which rooms are planet copies (nil for none)
local function fresh(start, copies)
    local ctx = assert(loadfile("src/logic/contexts/contexts.lua"))()
    ctx.start_room = start
    ctx.copy_of = function(room_key)
        local copy = (copies or {})[room_key]
        if copy == nil then
            return nil
        end
        return copy.original, copy.number
    end
    return ctx
end

local function set(list)
    local result = {}
    for _, key in pairs(list) do
        result[key] = true
    end
    return result
end

local ROOMS = {
    "planet: home",
    "planet: moss",
    "planet: rock",
    "planet: rock-2",
    "planet: home-2",
    "planet: moss-3",
}

-- The number of a room, from its simple context
local function number_of(ctx, room_key)
    return (ctx.simple(room_key) - ctx.SIMPLE_SLOT) / ctx.SLOTS
end

test("the starting planet is 0, the other originals follow by key, and copies are their originals shifted by the number of originals", function()
    local ctx = fresh(START, COPIES)
    ctx.number_rooms(set(ROOMS))
    assert(number_of(ctx, "planet: rock") == 0)
    assert(number_of(ctx, "planet: home") == 1)
    assert(number_of(ctx, "planet: moss") == 2)
    -- The starting planet's complex contexts are 0 to 3
    for _, mask in pairs(ctx.masks) do
        assert(ctx.complex("planet: rock", mask) == mask)
    end
    for _, copy in pairs({
        "planet: rock-2",
        "planet: home-2",
        "planet: moss-3",
    }) do
        local original, dupe_number = ctx.copy_of(copy)
        local shift = (dupe_number - 1) * 3 * ctx.SLOTS
        assert(ctx.simple(copy) == ctx.simple(original) + shift, copy .. " isn't its original shifted")
        for _, mask in pairs(ctx.masks) do
            assert(ctx.complex(copy, mask) == ctx.complex(original, mask) + shift)
            assert(ctx.room(ctx.complex(copy, mask)) == copy and ctx.mask(ctx.complex(copy, mask)) == mask)
        end
        assert(ctx.room(ctx.simple(copy)) == copy and ctx.mask(ctx.simple(copy)) == nil)
    end
    assert(#messages == 0)
end)

test("a copy numbered later still gets its shifted number, and other rooms numbered later go past every copy's and are logged", function()
    local ctx = fresh(START, COPIES)
    ctx.number_rooms(set(ROOMS))
    ctx.number_rooms(set({ "planet: moss-2" }))
    assert(number_of(ctx, "planet: moss-2") == number_of(ctx, "planet: moss") + 3)
    assert(#messages == 0)
    ctx.number_rooms(set({ "planet: late" }))
    -- Copies stay below the highest dupe number times the 3 originals
    assert(number_of(ctx, "planet: late") == dupe_graphics.max_dupe * 3)
    assert(#messages == 1 and string.find(messages[1], "planet: late", 1, true) ~= nil)
end)

test("a copy whose shifted number is taken goes past the others too", function()
    local ctx = fresh(START, COPIES)
    local rooms = set(ROOMS)
    rooms["planet: rock-2b"] = true
    ctx.number_rooms(rooms)
    assert(number_of(ctx, "planet: rock-2") == 3)
    assert(number_of(ctx, "planet: rock-2b") == dupe_graphics.max_dupe * 3)
    assert(#messages == 1 and string.find(messages[1], "planet: rock-2b", 1, true) ~= nil)
end)

test("names are how contexts were written when they were strings", function()
    local ctx = fresh(START, COPIES)
    ctx.number_rooms(set(ROOMS))
    assert(ctx.name(ctx.complex("planet: moss", ctx.ALL_ABILITIES)) == "planet: moss | 11")
    assert(ctx.name(ctx.complex("planet: moss", ctx.ISOLATED)) == "planet: moss | 10")
    assert(ctx.name(ctx.complex("planet: moss", ctx.AUTOMATED)) == "planet: moss | 01")
    assert(ctx.name(ctx.complex("planet: moss", ctx.NO_ABILITIES)) == "planet: moss | 00")
    assert(ctx.name(ctx.simple("planet: moss")) == "planet: moss")
    assert(ctx.name(ctx.home(ctx.complex("planet: rock", ctx.NO_ABILITIES), 2)) == "planet: rock | 00 @ home2")
    assert(ctx.name(ctx.home(ctx.simple("planet: moss-3"), 12)) == "planet: moss-3 @ home12")
end)

test("a home context keeps its home set through the accessors", function()
    local ctx = fresh(START, COPIES)
    ctx.number_rooms(set(ROOMS))
    local context = ctx.complex("planet: home-2", ctx.ALL_ABILITIES)
    local home = ctx.home(context, 3)
    assert(ctx.home_of(home) == 3 and ctx.home_of(context) == nil)
    assert(ctx.without_home(home) == context)
    assert(ctx.room(home) == "planet: home-2" and ctx.mask(home) == ctx.ALL_ABILITIES)
    assert(ctx.with_mask(home, ctx.NO_ABILITIES) == ctx.home(ctx.complex("planet: home-2", ctx.NO_ABILITIES), 3))
end)

test("the control stage takes the data stage's numbers, though it can't tell copies from their originals", function()
    local data_stage = fresh(START, COPIES)
    data_stage.number_rooms(set(ROOMS))
    local control_stage = fresh(nil, nil)
    control_stage.import_rooms(data_stage.export_rooms())
    for _, room_key in pairs(ROOMS) do
        assert(control_stage.simple(room_key) == data_stage.simple(room_key))
        for _, mask in pairs(data_stage.masks) do
            assert(control_stage.complex(room_key, mask) == data_stage.complex(room_key, mask))
        end
    end
    control_stage.number_rooms(set(ROOMS))
    assert(#messages == 0)
end)

test("rooms whose contexts would reach the home contexts' range are refused", function()
    local ctx = fresh(nil, nil)
    local last = ctx.HOME_STRIDE / ctx.SLOTS - 1
    ctx.import_rooms({
        numbers = {
            ["planet: last"] = last,
        },
        originals = 1,
    })
    assert(ctx.simple("planet: last") < ctx.HOME_STRIDE)
    assert(not pcall(ctx.import_rooms, {
        numbers = {
            ["planet: past"] = last + 1,
        },
        originals = 1,
    }))
end)

test("edge abilities are codes of what they gain and lose, and pass masks as ability strings did", function()
    local ctx = fresh(nil, nil)
    assert(ctx.edge_abilities(0, 0) == nil)
    assert(ctx.edge_with(nil, ctx.ISOLATABILITY, false) == ctx.LOSES_ISOLATABILITY)
    assert(ctx.edge_with(ctx.GAINS_AUTOMATABILITY, ctx.ISOLATABILITY, true) == ctx.GAINS_ALL)
    -- An ability gained or lost replaces whatever the edge did with it
    assert(ctx.edge_with(ctx.GAINS_ISOLATABILITY, ctx.ISOLATABILITY, false) == ctx.LOSES_ISOLATABILITY)
    assert(ctx.edge_changes(ctx.LOSES_AUTOMATABILITY, ctx.AUTOMATABILITY) and not ctx.edge_changes(ctx.LOSES_AUTOMATABILITY, ctx.ISOLATABILITY))
    assert(not ctx.edge_changes(nil, ctx.AUTOMATABILITY))
    -- Losing an ability drops masks that have it, and gaining one keeps the mask and adds the one with it
    assert(#ctx.forward_masks(ctx.LOSES_AUTOMATABILITY, ctx.ALL_ABILITIES) == 0)
    local through = ctx.forward_masks(ctx.LOSES_AUTOMATABILITY, ctx.ISOLATED)
    assert(#through == 1 and through[1] == ctx.ISOLATED)
    through = ctx.forward_masks(ctx.GAINS_ISOLATABILITY, ctx.NO_ABILITIES)
    assert(#through == 2 and through[1] == ctx.NO_ABILITIES and through[2] == ctx.ISOLATED)
    -- inverse_masks undoes forward_masks for every edge code
    for code = 0, ctx.NUM_MASKS * ctx.NUM_MASKS - 1 do
        for _, mask in pairs(ctx.masks) do
            for _, result in pairs(ctx.masks) do
                local forward = set(ctx.forward_masks(code, mask))[result] ~= nil
                local inverse = set(ctx.inverse_masks(code, result))[mask] ~= nil
                assert(forward == inverse, "code " .. code .. ": " .. ctx.mask_name(mask) .. " and " .. ctx.mask_name(result) .. " disagree")
            end
        end
    end
end)

print(num_passed .. " tests passed")
