-- Context numbers: what top.sort (lib/graph/context-sort.lua) and everything reading its sorts use for a context, where and how a pebble can be had
--
-- Rooms (planets and surfaces) are numbered: the starting planet is 0, the other original rooms follow in room key order, and a planet's copy with dupe number n (lib/dupe-planets.lua) is its original's number plus (n - 1) times the number of original rooms, so a copy's contexts are its original's shifted by a constant
-- A context is its room's number times SLOTS plus a slot:
--   * slots 0 to 3 are complex contexts, the slot being the ability mask, with ISOLATABILITY the bit 2 and AUTOMATABILITY the bit 1 (so 3 has both, and the starting planet's complex contexts are 0 to 3)
--   * SIMPLE_SLOT is the room's simple context (a sort without complex contexts)
-- A home context (see Home contexts in context-sort.lua) is its home set's number times HOME_STRIDE plus the context it rides on
--
-- Edge abilities (edge.abilities, see lib/logic/builder.lua) are a code of two masks: the abilities the edge gains and those it loses (contexts.edge_abilities)
--
-- Names (contexts.name) are what contexts used to be, like "planet: nauvis | 11", "planet: nauvis | 00 @ home1" or "planet: nauvis" for a simple context
-- They're only for logs and display, and come from lookup tables filled once per room and home set, never from building strings on every call

local dupe_graphics = require("lib/dupe-graphics-manifest")

local contexts = {}

-- Ability indices, as the old ability strings ordered them (the first character was isolatability)
contexts.ISOLATABILITY = 1
contexts.AUTOMATABILITY = 2
contexts.NUM_ABILITIES = 2
-- Ability index --> its bit in a mask
local ABILITY_BIT = {
    [contexts.ISOLATABILITY] = 2,
    [contexts.AUTOMATABILITY] = 1,
}
contexts.ABILITY_BIT = ABILITY_BIT
contexts.NUM_MASKS = 4
contexts.NO_ABILITIES = 0
contexts.ISOLATED = ABILITY_BIT[contexts.ISOLATABILITY]
contexts.AUTOMATED = ABILITY_BIT[contexts.AUTOMATABILITY]
contexts.ALL_ABILITIES = contexts.ISOLATED + contexts.AUTOMATED
-- Every mask, in the order sorts go through them (the order the ability strings "00", "01", "10", "11" had)
contexts.masks = {}
for mask = 0, contexts.NUM_MASKS - 1 do
    table.insert(contexts.masks, mask)
end

-- mask + 1 --> ability --> whether the mask has it, and the mask with it added or taken away
local HAS = {}
local WITH = {}
local WITHOUT = {}
-- mask + 1 --> how the old ability strings wrote it
local MASK_NAME = {}
for mask = 0, contexts.NUM_MASKS - 1 do
    HAS[mask + 1] = {}
    WITH[mask + 1] = {}
    WITHOUT[mask + 1] = {}
    local name = ""
    for ability = 1, contexts.NUM_ABILITIES do
        local bit = ABILITY_BIT[ability]
        local has = math.floor(mask / bit) % 2 == 1
        HAS[mask + 1][ability] = has
        WITH[mask + 1][ability] = has and mask or mask + bit
        WITHOUT[mask + 1][ability] = has and mask - bit or mask
        name = name .. (has and "1" or "0")
    end
    MASK_NAME[mask + 1] = name
end

contexts.has_ability = function(mask, ability)
    return HAS[mask + 1][ability]
end

contexts.with_ability = function(mask, ability)
    return WITH[mask + 1][ability]
end

contexts.without_ability = function(mask, ability)
    return WITHOUT[mask + 1][ability]
end

-- How a mask used to be written, like "10"
contexts.mask_name = function(mask)
    return MASK_NAME[mask + 1]
end

-- Whether a mask has every ability another has
contexts.mask_covers = function(mask, other)
    for ability = 1, contexts.NUM_ABILITIES do
        if HAS[other + 1][ability] and not HAS[mask + 1][ability] then
            return false
        end
    end
    return true
end

----------------------------------------------------------------------
-- Edge abilities
----------------------------------------------------------------------

-- An edge's abilities: gains and loses are masks of the abilities a context gains and loses going through the edge, or nil when it changes none
local EDGE_CODES = contexts.NUM_MASKS
contexts.edge_abilities = function(gains, loses)
    if gains == 0 and loses == 0 then
        return nil
    end
    return gains * EDGE_CODES + loses
end

contexts.edge_gains = function(code)
    return math.floor(code / EDGE_CODES)
end

contexts.edge_loses = function(code)
    return code % EDGE_CODES
end

-- The edge abilities the logic builders use
contexts.GAINS_ISOLATABILITY = contexts.edge_abilities(contexts.ISOLATED, 0)
contexts.GAINS_AUTOMATABILITY = contexts.edge_abilities(contexts.AUTOMATED, 0)
contexts.GAINS_ALL = contexts.edge_abilities(contexts.ALL_ABILITIES, 0)
contexts.LOSES_ISOLATABILITY = contexts.edge_abilities(0, contexts.ISOLATED)
contexts.LOSES_AUTOMATABILITY = contexts.edge_abilities(0, contexts.AUTOMATED)

-- Edge abilities (or nil for none) with one ability gained (gained true) or lost (gained false) instead of whatever they did with it
contexts.edge_with = function(code, ability, gained)
    local bit = ABILITY_BIT[ability]
    local gains = code ~= nil and contexts.edge_gains(code) or 0
    local loses = code ~= nil and contexts.edge_loses(code) or 0
    gains = WITHOUT[gains + 1][ability]
    loses = WITHOUT[loses + 1][ability]
    if gained then
        gains = gains + bit
    else
        loses = loses + bit
    end
    return contexts.edge_abilities(gains, loses)
end

-- Whether edge abilities (or nil for none) gain or lose an ability
contexts.edge_changes = function(code, ability)
    if code == nil then
        return false
    end
    return HAS[contexts.edge_gains(code) + 1][ability] or HAS[contexts.edge_loses(code) + 1][ability]
end

-- code --> mask + 1 --> the masks coming out the other side, in the order of contexts.masks
-- Gaining an ability keeps the old mask and adds the one with the ability, and losing one drops masks that have it (as extended-sort.lua's transmit_through_edge did with ability strings)
local FORWARD = {}
-- code --> mask + 1 --> the masks going in that make it come out
local INVERSE = {}
for code = 0, EDGE_CODES * EDGE_CODES - 1 do
    local gains = math.floor(code / EDGE_CODES)
    local loses = code % EDGE_CODES
    FORWARD[code] = {}
    INVERSE[code] = {}
    for mask = 0, contexts.NUM_MASKS - 1 do
        INVERSE[code][mask + 1] = {}
    end
    for mask = 0, contexts.NUM_MASKS - 1 do
        local results = { [mask] = true }
        for ability = 1, contexts.NUM_ABILITIES do
            local bit = ABILITY_BIT[ability]
            local new_results = {}
            for result, _ in pairs(results) do
                if math.floor(gains / bit) % 2 == 1 then
                    new_results[result] = true
                    new_results[WITH[result + 1][ability]] = true
                elseif math.floor(loses / bit) % 2 == 1 then
                    if not HAS[result + 1][ability] then
                        new_results[result] = true
                    end
                else
                    new_results[result] = true
                end
            end
            results = new_results
        end
        FORWARD[code][mask + 1] = {}
        for result = 0, contexts.NUM_MASKS - 1 do
            if results[result] ~= nil then
                table.insert(FORWARD[code][mask + 1], result)
                table.insert(INVERSE[code][result + 1], mask)
            end
        end
    end
end

-- The masks a mask becomes through an edge with these abilities (a list not to be changed)
contexts.forward_masks = function(code, mask)
    return FORWARD[code][mask + 1]
end

-- The masks that become a mask through an edge with these abilities (a list not to be changed)
contexts.inverse_masks = function(code, mask)
    return INVERSE[code][mask + 1]
end

-- The same tables (code --> mask + 1 --> masks), for the sort's inner loop to read without a call; not to be changed
contexts.FORWARD_MASKS = FORWARD
contexts.INVERSE_MASKS = INVERSE

-- Whether going through an edge with these abilities can take a context's ability away
contexts.edge_loses_ability = function(code, ability)
    return code ~= nil and HAS[code % EDGE_CODES + 1][ability]
end

-- Whether going through an edge with these abilities can give a context an ability
contexts.edge_gains_ability = function(code, ability)
    return code ~= nil and HAS[math.floor(code / EDGE_CODES) + 1][ability]
end

----------------------------------------------------------------------
-- Rooms and context numbers
----------------------------------------------------------------------

local SLOTS = 8
local SIMPLE_SLOT = 4
local HOME_STRIDE = 65536
contexts.SLOTS = SLOTS
contexts.SIMPLE_SLOT = SIMPLE_SLOT
contexts.HOME_STRIDE = HOME_STRIDE

-- The highest dupe number planet copies can have: the highest with recolored graphics (see lib/dupe-planets.lua)
local MAX_DUPE_NUMBER = dupe_graphics.max_dupe
-- Room key --> number, and number --> room key
local ROOM_NUMBER = {}
local ROOM_KEY = {}
-- How many original rooms the copies are shifted by, once rooms are numbered
local num_originals
-- Context (without a home) --> room key, and --> mask (complex contexts only)
local ROOM_OF = {}
local MASK_OF = {}
-- Context --> name, home set number --> name
local NAME = {}
local HOME_NAME = {}

-- The starting planet's room key, which gets number 0 (set by lib/logic/init.lua before rooms are numbered)
contexts.start_room = nil
-- Room key --> its original's room key and its dupe number, for planet copies (set by lib/logic/init.lua in the data stage, see surface_sets.family_of); nil for rooms that aren't copies
contexts.copy_of = function(room_key)
    return nil
end

local function add_room(room_key, number)
    if (number + 1) * SLOTS > HOME_STRIDE then
        error("Contexts: room " .. room_key .. " got number " .. tostring(number) .. ", whose contexts would reach the home contexts' range (HOME_STRIDE)")
    end
    ROOM_NUMBER[room_key] = number
    ROOM_KEY[number] = room_key
    for mask = 0, contexts.NUM_MASKS - 1 do
        local context = number * SLOTS + mask
        ROOM_OF[context] = room_key
        MASK_OF[context] = mask
        NAME[context] = room_key .. " | " .. MASK_NAME[mask + 1]
    end
    local simple = number * SLOTS + SIMPLE_SLOT
    ROOM_OF[simple] = room_key
    NAME[simple] = room_key
end

-- Numbers the rooms of a set (room key --> true) not numbered yet
-- The first call numbers the original rooms as described at the top; copies get their shifted numbers then or whenever they appear, while those are free, and other rooms appearing later (none should) get numbers past every copy's, and are logged
contexts.number_rooms = function(rooms)
    local new_rooms = {}
    for room_key, _ in pairs(rooms) do
        if ROOM_NUMBER[room_key] == nil then
            table.insert(new_rooms, room_key)
        end
    end
    table.sort(new_rooms)
    if num_originals == nil then
        local originals = {}
        for _, room_key in pairs(new_rooms) do
            local original = contexts.copy_of(room_key)
            if room_key ~= contexts.start_room and (original == nil or rooms[original] == nil) then
                table.insert(originals, room_key)
            end
        end
        if contexts.start_room ~= nil and rooms[contexts.start_room] ~= nil then
            table.insert(originals, 1, contexts.start_room)
        end
        num_originals = #originals
        for i, room_key in pairs(originals) do
            add_room(room_key, i - 1)
        end
    end
    local unshifted = {}
    for _, room_key in pairs(new_rooms) do
        if ROOM_NUMBER[room_key] == nil then
            local original, number = contexts.copy_of(room_key)
            local shifted = original ~= nil and ROOM_NUMBER[original] ~= nil and ROOM_NUMBER[original] + (number - 1) * num_originals or nil
            if shifted ~= nil and ROOM_KEY[shifted] == nil then
                add_room(room_key, shifted)
            else
                table.insert(unshifted, room_key)
            end
        end
    end
    if #unshifted > 0 then
        -- Past the slots of every dupe number there are graphics for
        local next_number = MAX_DUPE_NUMBER * math.max(num_originals, 1)
        for number, _ in pairs(ROOM_KEY) do
            next_number = math.max(next_number, number + 1)
        end
        for _, room_key in pairs(unshifted) do
            add_room(room_key, next_number)
            next_number = next_number + 1
        end
        -- Plain-Lua tests number rooms as their fixtures name them, without the game's log
        if log ~= nil then
            log("Contexts: rooms numbered after the others, so not shifted copies of an original: " .. table.concat(unshifted, ", "))
        end
    end
end

-- The numbering as { numbers = room key --> number, originals = how many original rooms }, for passing to the control stage (contexts.import_rooms)
contexts.export_rooms = function()
    local numbers = {}
    for room_key, number in pairs(ROOM_NUMBER) do
        numbers[room_key] = number
    end
    return {
        numbers = numbers,
        originals = num_originals,
    }
end

-- Takes the data stage's numbering (from contexts.export_rooms), so control stage contexts are the same numbers
contexts.import_rooms = function(exported)
    for room_key, number in pairs(exported.numbers) do
        if ROOM_NUMBER[room_key] == nil then
            add_room(room_key, number)
        end
    end
    num_originals = exported.originals
end

-- Complex context of a room with these abilities, or nil for a room that isn't numbered
contexts.complex = function(room_key, mask)
    local number = ROOM_NUMBER[room_key]
    if number == nil then
        return nil
    end
    return number * SLOTS + mask
end

-- Simple context of a room, or nil for a room that isn't numbered
contexts.simple = function(room_key)
    local number = ROOM_NUMBER[room_key]
    if number == nil then
        return nil
    end
    return number * SLOTS + SIMPLE_SLOT
end

-- The home context of a home set riding on a context
contexts.home = function(context, home_number)
    return home_number * HOME_STRIDE + context
end

-- The context a home context rides on, or the context itself if it isn't one
contexts.without_home = function(context)
    return context % HOME_STRIDE
end

-- Home set number of a home context, or nil for other contexts
contexts.home_of = function(context)
    if context < HOME_STRIDE then
        return nil
    end
    return math.floor(context / HOME_STRIDE)
end

contexts.room = function(context)
    return ROOM_OF[context % HOME_STRIDE]
end

-- Ability mask of a complex context (or of the complex context a home context rides on), nil for simple ones
contexts.mask = function(context)
    return MASK_OF[context % HOME_STRIDE]
end

-- The same context (home set kept) with another ability mask; only for complex contexts
contexts.with_mask = function(context, mask)
    return context - MASK_OF[context % HOME_STRIDE] + mask
end

contexts.home_name = function(home_number)
    local name = HOME_NAME[home_number]
    if name == nil then
        name = "home" .. tostring(home_number)
        HOME_NAME[home_number] = name
    end
    return name
end

-- How the context used to be written, for logs and display
contexts.name = function(context)
    local name = NAME[context]
    if name == nil then
        local base = NAME[context % HOME_STRIDE]
        if base == nil or context < HOME_STRIDE then
            return "<context " .. tostring(context) .. ">"
        end
        name = base .. " @ " .. contexts.home_name(math.floor(context / HOME_STRIDE))
        NAME[context] = name
    end
    return name
end

-- Names of a list of contexts, for logs
contexts.names = function(context_list)
    local names = {}
    for _, context in pairs(context_list) do
        table.insert(names, contexts.name(context))
    end
    return names
end

return contexts
