-- Surface sets: which rooms (planets and surfaces) accept a recipe or entity, and surface conditions that give exactly a chosen set
-- Randomizations choose the set of rooms that should accept something; this file turns sets into conditions, never the other way around
-- Conditions are an AND of one [min, max] range per property, so a set is exact on a property when its rooms sit next to each other in that property's order of rooms
-- New properties (with silly names, see POOL) give each room a value, ordered so that every chosen set is a range on one of them
-- The planning part (surface_sets.plan) is plain Lua, so lib/test-surface-sets.lua can test it outside the game

local gutils = require("lib/graph/graph-utils")

local surface_sets = {}

-- New surface properties, in the order they're used
-- Each has locale in locale/en/locale.cfg ([surface-property-name] and [surface-property-unit]); step spaces a property's values out, so they look like measurements
-- Rooms get values step, 2 * step, ..., and the default (for surfaces the game makes that no room here knows about) is 0, outside every range
surface_sets.POOL = {
    {
        name = "propertyrandomizer-vibes",
        step = 7,
    },
    {
        name = "propertyrandomizer-snootiness",
        step = 12,
    },
    {
        name = "propertyrandomizer-ambient-jazz",
        step = 33,
    },
    {
        name = "propertyrandomizer-wobble",
        step = 3,
    },
    {
        name = "propertyrandomizer-crunchiness",
        step = 25,
    },
    {
        name = "propertyrandomizer-spookiness",
        step = 13,
    },
    {
        name = "propertyrandomizer-squeakiness",
        step = 42,
    },
    {
        name = "propertyrandomizer-cheese-content",
        step = 5,
    },
}

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

local function size(set)
    local num = 0
    for _, _ in pairs(set) do
        num = num + 1
    end
    return num
end

-- An order of rooms still being decided, as a list of blocks (sets of rooms): rooms in different blocks are in the blocks' order, rooms in one block in any order
-- Adding a set that must be a range only ever splits blocks, so sets added before stay unions of consecutive blocks (so ranges)
-- Returns the refined blocks, or nil if the set can't be a range without undoing an earlier choice
local function refine(blocks, set)
    local first
    local last
    for i, block in pairs(blocks) do
        for room, _ in pairs(block) do
            if set[room] ~= nil then
                first = first or i
                last = i
                break
            end
        end
    end
    if first == nil then
        return nil
    end
    local function split(block)
        local inside = {}
        local outside = {}
        for room, _ in pairs(block) do
            if set[room] ~= nil then
                inside[room] = true
            else
                outside[room] = true
            end
        end
        return inside, outside
    end
    -- Blocks strictly between the first and last touched ones must be wholly in the set
    for i = first + 1, last - 1 do
        local _, outside = split(blocks[i])
        if next(outside) ~= nil then
            return nil
        end
    end
    local refined = {}
    for i = 1, first - 1 do
        table.insert(refined, blocks[i])
    end
    local inside, outside = split(blocks[first])
    if first == last then
        -- The set lies in one block: its rooms go to that block's end
        if next(outside) ~= nil then
            table.insert(refined, outside)
        end
        table.insert(refined, inside)
    else
        -- The set's part of the first block faces the blocks after it, and its part of the last block faces the ones before
        if next(outside) ~= nil then
            table.insert(refined, outside)
        end
        table.insert(refined, inside)
        for i = first + 1, last - 1 do
            table.insert(refined, blocks[i])
        end
        local last_inside, last_outside = split(blocks[last])
        table.insert(refined, last_inside)
        if next(last_outside) ~= nil then
            table.insert(refined, last_outside)
        end
    end
    for i = last + 1, #blocks do
        table.insert(refined, blocks[i])
    end
    return refined
end

-- Plans conditions giving each request exactly its set of rooms
-- requests: list of { id, rooms = room key --> true }; room_keys: every room there is; pool: new properties to use, like surface_sets.POOL
-- Returns:
--   * properties: list of { name, values = room key --> value } for the new properties used, in pool order
--   * conditions: request id --> list of { property, min, max } (empty when every room accepts it)
--   * unrealized: ids of requests no property could take (the pool ran out) or with no rooms, sorted
-- Larger sets go first, since they constrain the order the most; the result depends only on the inputs
surface_sets.plan = function(requests, room_keys, pool)
    local all_rooms = {}
    for _, room in pairs(room_keys) do
        all_rooms[room] = true
    end
    local num_rooms = size(all_rooms)
    local order = {}
    for _, request in pairs(requests) do
        table.insert(order, request)
    end
    table.sort(order, function(a, b)
        local size_a = size(a.rooms)
        local size_b = size(b.rooms)
        if size_a ~= size_b then
            return size_a > size_b
        end
        return a.id < b.id
    end)

    -- Property index --> blocks, and property index --> ids of the requests it realizes
    local property_blocks = {}
    local property_ids = {}
    local conditions = {}
    local unrealized = {}
    for _, request in pairs(order) do
        local rooms = {}
        for room, _ in pairs(request.rooms) do
            if all_rooms[room] ~= nil then
                rooms[room] = true
            end
        end
        local num = size(rooms)
        if num == 0 then
            table.insert(unrealized, request.id)
        elseif num == num_rooms then
            conditions[request.id] = {}
        else
            local placed = false
            for i = 1, #pool do
                if property_blocks[i] == nil then
                    property_blocks[i] = { all_rooms }
                    property_ids[i] = {}
                end
                local refined = refine(property_blocks[i], rooms)
                if refined ~= nil then
                    property_blocks[i] = refined
                    table.insert(property_ids[i], request.id)
                    placed = true
                    break
                end
            end
            if not placed then
                table.insert(unrealized, request.id)
            end
        end
    end

    local properties = {}
    local rooms_of = {}
    for _, request in pairs(order) do
        rooms_of[request.id] = request.rooms
    end
    for i = 1, #pool do
        if property_blocks[i] ~= nil and #property_ids[i] > 0 then
            local values = {}
            local position = 0
            for _, block in pairs(property_blocks[i]) do
                for _, room in pairs(sorted_keys(block)) do
                    position = position + 1
                    values[room] = position * pool[i].step
                end
            end
            table.insert(properties, {
                name = pool[i].name,
                values = values,
            })
            for _, id in pairs(property_ids[i]) do
                local min
                local max
                for room, _ in pairs(rooms_of[id]) do
                    if values[room] ~= nil then
                        min = math.min(min or values[room], values[room])
                        max = math.max(max or values[room], values[room])
                    end
                end
                conditions[id] = {
                    {
                        property = pool[i].name,
                        min = min,
                        max = max,
                    },
                }
            end
        end
    end
    table.sort(unrealized)
    return {
        properties = properties,
        conditions = conditions,
        unrealized = unrealized,
    }
end

-- The rooms whose property values meet every condition, as room key --> true
-- value_of(room key, property name) gives a room's value of a property
surface_sets.accepting = function(conditions, room_keys, value_of)
    local rooms = {}
    for _, room in pairs(room_keys) do
        local accepts = true
        for _, condition in pairs(conditions) do
            local value = value_of(room, condition.property)
            if (condition.min ~= nil and value < condition.min) or (condition.max ~= nil and value > condition.max) then
                accepts = false
            end
        end
        if accepts then
            rooms[room] = true
        end
    end
    return rooms
end

----------------------------------------------------------------------
-- Data stage: reading and writing prototypes
----------------------------------------------------------------------

-- A room's prototype, from its logic key (like planet: gleba)
surface_sets.room_prototype = function(room_key)
    local room = gutils.deconstruct(room_key)
    return (data.raw[room.type] or {})[room.name]
end

-- Keys of the rooms the logic knows (lookups.rooms, built by the logic build), except control rooms, which have no prototype, sorted
surface_sets.room_keys = function()
    local keys = {}
    for room_key, room in pairs(lookups.rooms) do
        if room.type ~= "control" then
            table.insert(keys, room_key)
        end
    end
    table.sort(keys)
    return keys
end

-- A room's value of a surface property: its own, or else the property's default
surface_sets.value = function(room_key, property_name)
    local prototype = surface_sets.room_prototype(room_key)
    local value = ((prototype or {}).surface_properties or {})[property_name]
    if value == nil then
        value = data.raw["surface-property"][property_name].default_value
    end
    return value
end

-- The rooms (logic keys) that accept a prototype's surface conditions now
surface_sets.accepted = function(prototype)
    return surface_sets.accepting(prototype.surface_conditions or {}, surface_sets.room_keys(), surface_sets.value)
end

-- Removes every pool property from the game: its prototype, and each room's value
surface_sets.clear = function(pool)
    for _, entry in pairs(pool) do
        data.raw["surface-property"][entry.name] = nil
        for _, room_key in pairs(surface_sets.room_keys()) do
            local prototype = surface_sets.room_prototype(room_key)
            if prototype ~= nil and prototype.surface_properties ~= nil then
                prototype.surface_properties[entry.name] = nil
            end
        end
    end
end

-- Puts a plan (from surface_sets.plan) in the game: after clearing the pool's properties, adds the ones the plan uses and their room values
-- Conditions are the caller's to set, since the caller knows which prototype each request is
surface_sets.apply_properties = function(plan, pool)
    surface_sets.clear(pool)
    for i, property in pairs(plan.properties) do
        data:extend({
            {
                type = "surface-property",
                name = property.name,
                default_value = 0,
                order = "z[propertyrandomizer]-" .. string.format("%02d", i),
            },
        })
        for room_key, value in pairs(property.values) do
            local prototype = surface_sets.room_prototype(room_key)
            prototype.surface_properties = prototype.surface_properties or {}
            prototype.surface_properties[property.name] = value
        end
    end
end

return surface_sets
