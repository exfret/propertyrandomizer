-- A copy of consistent-sort.lua that can optionally also track the ability contexts (isolatability/automatability) from extended-sort.lua
-- Kept as close to consistent-sort.lua as possible so that callers can be ported over by just swapping the require
-- Differences from consistent-sort.lua:
--   1. Pass extra.complex_contexts = true to make each context a room/ability string pair rather than just a room
--      These are encoded as a single string (see top.context_key) so the rest of the sort treats them just like rooms
--   2. Contexts are now also transmitted through edges, since edges can add/remove abilities (edge.abilities)
--   3. Random selection from open is O(1) using a list of open keys, rather than rebuilding that list every step
--   4. Pass extra.home_contexts = true to also track home contexts (see Home contexts below), with or without complex contexts
--      Their home sets come from extra.home_sets if given (see top.home_sets), then logic.home_sets (the vanilla ones, stored by data-final-fixes.lua before randomization), and otherwise from the graph being sorted
-- Without complex contexts, this should behave exactly like consistent-sort.lua except for which random node is picked
-- I kept the pebble terminology: a *pebble* is a node_key/context pair

local contutils = require("lib/graph/context-utils")
local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local rng = require("lib/random/rng")
-- Used for contexts and such; actual logic dependency graph is passed in
local logic = require("lib/logic/state")

-- Shortcuts
local key = gutils.key

-- Ability indices, matching edge.abilities (see lib/logic/builder.lua)
local ISOLATABILITY = 1
local AUTOMATABILITY = 2
local NUM_ABILITIES = 2
-- Can't appear in room keys
local CONTEXT_SEPARATOR = " | "
-- Separates a home context's home set id from the context it rides on; can't appear in room keys or ability strings
local HOME_SEPARATOR = " @ "

local top = {}

top.ISOLATABILITY = ISOLATABILITY
top.AUTOMATABILITY = AUTOMATABILITY

-- Every ability string, like "00", "01", "10", "11", where the i-th character is whether ability i is had
local ability_strs = { "" }
for _ = 1, NUM_ABILITIES do
    local longer_strs = {}
    for _, ability_str in pairs(ability_strs) do
        table.insert(longer_strs, ability_str .. "0")
        table.insert(longer_strs, ability_str .. "1")
    end
    ability_strs = longer_strs
end
top.ability_strs = ability_strs
-- The weakest ability string: no edge takes it away, so a node with any context in a room also has this one there
local NO_ABILITIES = string.rep("0", NUM_ABILITIES)

local function has_ability(ability_str, ability)
    return string.sub(ability_str, ability, ability) == "1"
end

local function with_ability(ability_str, ability)
    return string.sub(ability_str, 1, ability - 1) .. "1" .. string.sub(ability_str, ability + 1)
end

-- Complex context helpers

top.context_key = function(room, ability_str)
    return room .. CONTEXT_SEPARATOR .. ability_str
end

-- Home contexts
-- A home set is a set of rooms (see top.home_sets), and a pebble's home context for it means the pebble can be had using only those rooms
-- This is what removing every other room's node and sorting again would give, but for every home set in the same sort
-- Home contexts ride on each room's weakest context (the room itself for simple contexts, the room with no abilities for complex ones), and are written like "planet: vulcanus | 00 @ home1"
-- With complex contexts, they replace the order-dependent discovery rule: once a room is discovered, techs with a home context of its home set are isolatable there (see discover_home_rooms in top.sort)

-- The home context riding on a context
top.home_context_key = function(context, home_id)
    return context .. HOME_SEPARATOR .. home_id
end

-- The context a home context rides on, or the context itself if it isn't one
local function without_home(context)
    local i = string.find(context, HOME_SEPARATOR, 1, true)
    if i == nil then
        return context
    end
    return string.sub(context, 1, i - 1)
end
top.context_without_home = without_home

top.context_room = function(context)
    context = without_home(context)
    local i = string.find(context, CONTEXT_SEPARATOR, 1, true)
    if i == nil then
        return context
    end
    return string.sub(context, 1, i - 1)
end

-- Returns nil for simple contexts
top.context_abilities = function(context)
    context = without_home(context)
    local _, j = string.find(context, CONTEXT_SEPARATOR, 1, true)
    if j == nil then
        return nil
    end
    return string.sub(context, j + 1, -1)
end

-- Home set id of a home context, or nil for other contexts
top.context_home = function(context)
    local _, j = string.find(context, HOME_SEPARATOR, 1, true)
    if j == nil then
        return nil
    end
    return string.sub(context, j + 1, -1)
end

-- Gets the lookup tables for the contexts used in a sort
-- For simple contexts, the contexts are just the rooms, exactly as in consistent-sort.lua
-- home_sets (from top.home_sets) adds home contexts, or is nil for none
local function build_context_info(complex, home_sets)
    local context_info = {
        complex = complex,
        -- Every context
        list = {},
        -- context --> room (complex and home contexts only)
        room = {},
        -- context --> ability string (complex contexts only)
        abilities = {},
        -- room --> ability string --> context (complex contexts only)
        of = {},
        -- context --> home set id (home contexts only)
        home = {},
        -- room --> home set id --> context (home contexts only)
        home_of = {},
        -- home set id --> room --> true for the rooms in it (home contexts only)
        home_rooms = {},
    }
    for room, _ in pairs(logic.contexts) do
        if complex then
            context_info.of[room] = {}
            for _, ability_str in pairs(ability_strs) do
                local context = top.context_key(room, ability_str)
                table.insert(context_info.list, context)
                context_info.room[context] = room
                context_info.abilities[context] = ability_str
                context_info.of[room][ability_str] = context
            end
        else
            table.insert(context_info.list, room)
        end
        if home_sets ~= nil then
            -- Home contexts ride on the room's weakest context
            local base = room
            if complex then
                base = context_info.of[room][NO_ABILITIES]
            end
            context_info.home_of[room] = {}
            for _, home_id in pairs(home_sets.ids) do
                local context = top.home_context_key(base, home_id)
                table.insert(context_info.list, context)
                context_info.room[context] = room
                if complex then
                    context_info.abilities[context] = NO_ABILITIES
                end
                context_info.home[context] = home_id
                context_info.home_of[room][home_id] = context
            end
        end
    end
    if home_sets ~= nil then
        for _, home_id in pairs(home_sets.ids) do
            context_info.home_rooms[home_id] = home_sets.sets[home_id].rooms
        end
    end
    return context_info
end

-- Signature of an edge's abilities, like "-1" for { [2] = true } or "0-" for { [1] = false }
local function abilities_signature(abilities)
    local signature = ""
    for i = 1, NUM_ABILITIES do
        if abilities[i] == nil then
            signature = signature .. "-"
        elseif abilities[i] == true then
            signature = signature .. "1"
        else
            signature = signature .. "0"
        end
    end
    return signature
end

-- signature --> ability string --> list of ability strings that come out the other side of the edge
local forward_memo = {}
-- signature --> ability string --> list of ability strings that could have gone into the edge to produce it
local inverse_memo = {}

-- Same as extended-sort.lua's transmit_through_edge, but for a single ability string
-- Gaining an ability keeps the old ability string and adds the one with the ability; losing an ability drops strings that have it
local function compute_edge_abilities(abilities, ability_str)
    local results = { [ability_str] = true }
    for ability, gained in pairs(abilities) do
        local new_results = {}
        for result, _ in pairs(results) do
            if gained == true then
                new_results[result] = true
                new_results[with_ability(result, ability)] = true
            elseif not has_ability(result, ability) then
                new_results[result] = true
            end
        end
        results = new_results
    end
    local result_list = {}
    for _, result in pairs(ability_strs) do
        if results[result] ~= nil then
            table.insert(result_list, result)
        end
    end
    return result_list
end

local function edge_ability_tables(abilities)
    local signature = abilities_signature(abilities)
    if forward_memo[signature] == nil then
        local forward = {}
        local inverse = {}
        for _, ability_str in pairs(ability_strs) do
            inverse[ability_str] = {}
        end
        for _, ability_str in pairs(ability_strs) do
            forward[ability_str] = compute_edge_abilities(abilities, ability_str)
            for _, result in pairs(forward[ability_str]) do
                table.insert(inverse[result], ability_str)
            end
        end
        forward_memo[signature] = forward
        inverse_memo[signature] = inverse
    end
    return forward_memo[signature], inverse_memo[signature]
end

-- Contexts arriving at edge.stop when context leaves edge.start
-- Home contexts go through edges unchanged: they have no abilities to lose, and abilities an edge adds come from the context they ride on
local function edge_transmit(context_info, edge, context)
    if not context_info.complex or edge.abilities == nil or context_info.home[context] ~= nil then
        return { context }
    end
    local forward = edge_ability_tables(edge.abilities)
    local room = context_info.room[context]
    local arriving = {}
    for _, ability_str in pairs(forward[context_info.abilities[context]]) do
        table.insert(arriving, context_info.of[room][ability_str])
    end
    return arriving
end

-- Contexts leaving edge.start that would make context arrive at edge.stop
local function edge_sources(context_info, edge, context)
    if not context_info.complex or edge.abilities == nil or context_info.home[context] ~= nil then
        return { context }
    end
    local _, inverse = edge_ability_tables(edge.abilities)
    local room = context_info.room[context]
    local sources = {}
    for _, ability_str in pairs(inverse[context_info.abilities[context]]) do
        table.insert(sources, context_info.of[room][ability_str])
    end
    return sources
end

-- Earliest index in sorted of a pebble on edge.start that gets context to edge.stop, or nil if none
local function edge_ind(context_info, node_to_context_inds, edge, context)
    local start_inds = node_to_context_inds[edge.start]
    if not context_info.complex or edge.abilities == nil or context_info.home[context] ~= nil then
        return start_inds[context]
    end
    -- The same sources as edge_sources, without building the list
    local _, inverse = edge_ability_tables(edge.abilities)
    local room_contexts = context_info.of[context_info.room[context]]
    local earliest_ind
    for _, ability_str in pairs(inverse[context_info.abilities[context]]) do
        local ind = start_inds[room_contexts[ability_str]]
        if ind ~= nil and (earliest_ind == nil or ind < earliest_ind) then
            earliest_ind = ind
        end
    end
    return earliest_ind
end

-- Contexts leaving node when a home context arrives at it
-- Home contexts go through nodes like the contexts they ride on, except that a room only sends them for the home sets containing it
-- A pebble has a home context exactly when it can be had using only the rooms in that home set
local function home_transmit(context_info, node, incoming, home_id)
    local context_type = logic.type_info[node.type].context
    if context_type == nil then
        return { incoming }
    elseif context_type == true then
        -- Home sets aren't tied to a room, so forgetters send them to every room (like automatability)
        local outgoing = {}
        for room, _ in pairs(context_info.home_of) do
            table.insert(outgoing, context_info.home_of[room][home_id])
        end
        return outgoing
    elseif type(context_type) == "string" then
        -- Rooms use node.name for the room, see contutils.transmit
        local room_contexts = context_info.home_of[node.name]
        if room_contexts == nil then
            error("Room node " .. node.name .. " is not a context")
        end
        if context_info.home_rooms[home_id][node.name] ~= nil then
            return { room_contexts[home_id] }
        end
        return {}
    else
        -- Unhandled
        error()
    end
end

-- Contexts leaving node when incoming arrives at it
-- For simple contexts this is just contutils.transmit
-- For complex contexts this follows extended-sort.lua's transmit_through_node
local function node_transmit(context_info, node, incoming)
    local home_id = context_info.home[incoming]
    if home_id ~= nil then
        return home_transmit(context_info, node, incoming, home_id)
    end
    if not context_info.complex then
        return contutils.transmit(node, incoming)
    end

    local context_type = logic.type_info[node.type].context
    local ability_str = context_info.abilities[incoming]
    if context_type == nil then
        return { incoming }
    elseif context_type == true then
        -- Forgetters forget the room, but isolatability is tied to the room so it isn't shared with other rooms
        if has_ability(ability_str, ISOLATABILITY) then
            return { incoming }
        end
        local outgoing = {}
        for room, _ in pairs(context_info.of) do
            table.insert(outgoing, context_info.of[room][ability_str])
        end
        return outgoing
    elseif type(context_type) == "string" then
        -- Rooms use node.name for the room, see contutils.transmit
        -- Like extended-sort.lua, rooms emit every ability string no matter what came in
        local room_contexts = context_info.of[node.name]
        if room_contexts == nil then
            error("Room node " .. node.name .. " is not a context")
        end
        local outgoing = {}
        for _, room_ability_str in pairs(ability_strs) do
            table.insert(outgoing, room_contexts[room_ability_str])
        end
        return outgoing
    else
        -- Unhandled
        error()
    end
end

-- Rooms (as context keys) whose space locations this tech unlocks
-- Nodes that discover rooms for the isolatability discovery rule (see discover_space_locations and discover_home_rooms in top.sort)
-- Techs discover the space locations they unlock, and a spaceship discovers space platforms (the platform's techs count from when it can fly, not from when platforms are unlocked)
top.is_discoverer = function(node)
    return node.type == "technology" or node.type == "spaceship"
end

-- Rooms a discoverer node discovers, as { location, room }, where location identifies the discovery (so it only happens once)
top.discovered_rooms = function(tech_node)
    local rooms = {}
    if tech_node.type == "spaceship" then
        for room, _ in pairs(logic.contexts) do
            if gutils.deconstruct(room).type == "surface" then
                table.insert(rooms, {
                    location = room,
                    room = room,
                })
            end
        end
        return rooms
    end
    if tech_node.type ~= "technology" then
        return rooms
    end
    -- Control stage (the explorer's complex sorts) reads the runtime prototypes, which have the same effect fields
    local tech_prot
    if data ~= nil then
        tech_prot = data.raw.technology[tech_node.name]
    else
        tech_prot = prototypes.technology[tech_node.name]
    end
    if tech_prot == nil or tech_prot.effects == nil then
        return rooms
    end
    for _, effect in pairs(tech_prot.effects) do
        if effect.type == "unlock-space-location" then
            local loc_prot
            if data ~= nil then
                loc_prot = dutils.get_prot("space-location", effect.space_location)
            else
                loc_prot = prototypes.space_location[effect.space_location]
            end
            table.insert(rooms, {
                location = effect.space_location,
                room = key(loc_prot.type, loc_prot.name),
            })
        end
    end
    return rooms
end

-- Room --> node keys of the room's discoverers in the graph
top.room_discoverers = function(graph)
    local room_discoverers = {}
    for node_key, node in pairs(graph.nodes) do
        if top.is_discoverer(node) then
            for _, discovered in pairs(top.discovered_rooms(node)) do
                room_discoverers[discovered.room] = room_discoverers[discovered.room] or {}
                table.insert(room_discoverers[discovered.room], node_key)
            end
        end
    end
    return room_discoverers
end

-- The discovery rule for callers that reason about backings (like promotion), so that it lives only in this file
-- A tech pebble in an isolatable context can come from the rule, backed by an earlier pebble of the tech itself and an earlier pebble of a discoverer of the context's room
-- Returns the ranks of those candidates as { own = sorted list, discoverers = sorted list }, or nil if the rule can't give the pebble
-- With home contexts, the tech's own pebble has to be in a home context of the room's home set (see discover_home_rooms in top.sort); without them, any of its pebbles counts (see discover_space_locations)
-- room_discoverers comes from top.room_discoverers
top.discovery_candidates = function(sort_info, room_discoverers, tech_node, context)
    if sort_info.complex ~= true or tech_node.type ~= "technology" or top.context_home(context) ~= nil then
        return nil
    end
    local abilities = top.context_abilities(context)
    if abilities == nil or not has_ability(abilities, ISOLATABILITY) then
        return nil
    end
    local room = top.context_room(context)
    local home_id
    if sort_info.home_sets ~= nil then
        home_id = sort_info.home_sets.of[room]
        if home_id == nil then
            return nil
        end
    end
    local nci = sort_info.node_to_context_inds
    local own = {}
    for own_context, ind in pairs(nci[key(tech_node)] or {}) do
        if home_id == nil or top.context_home(own_context) == home_id then
            table.insert(own, ind)
        end
    end
    local discoverers = {}
    for _, discoverer_key in pairs(room_discoverers[room] or {}) do
        for _, ind in pairs(nci[discoverer_key] or {}) do
            table.insert(discoverers, ind)
        end
    end
    table.sort(own)
    table.sort(discoverers)
    return {
        own = own,
        discoverers = discoverers,
    }
end

-- Rooms needed: for every pebble of a sort without complex contexts, the rooms it can't be reached without, all found in one pass rather than a sort per room
-- They follow the sort's own rules, where a room's node is the only way to use that room:
--   * Sources need no rooms, and a room's node needs its own room on top of what satisfied it
--   * An incoming context satisfies an OR node needing what all its satisfying prerequisites need in common, and an AND node needing what any of its prerequisites needs
--   * Forgetters and rooms send the same contexts whichever incoming context satisfied them, so they need what all those incoming contexts need in common
-- Starting every pebble at all rooms and shrinking until nothing changes gives exactly the rooms each pebble can't be reached without
-- (The true answer follows these rules, and by induction along a sort without the room, any answer that follows them is contained in it; so it's the largest one, which is where shrinking ends up)
-- Sets of rooms are strings with a "0" or "1" per room, like ability strings, so that they're cheap to compare and memoize
local function compute_rooms_needed(graph)
    local sort_info = top.sort(graph)

    -- Rooms in a fixed order, so that sets of them can be strings
    local rooms = {}
    for room, _ in pairs(logic.contexts) do
        table.insert(rooms, room)
    end
    table.sort(rooms)
    local room_ind = {}
    for i = 1, #rooms do
        room_ind[rooms[i]] = i
    end
    local all_rooms = string.rep("1", #rooms)
    local no_rooms = string.rep("0", #rooms)

    -- Memoized, since there are only a few distinct sets
    local memos = {
        intersection = {},
        union = {},
    }
    local function combine(op, set1, set2)
        if set1 == set2 then
            return set1
        end
        local memo = memos[op]
        memo[set1] = memo[set1] or {}
        local result = memo[set1][set2]
        if result == nil then
            local chars = {}
            for i = 1, #rooms do
                local in_set1 = string.sub(set1, i, i) == "1"
                local in_set2 = string.sub(set2, i, i) == "1"
                if (op == "intersection" and in_set1 and in_set2) or (op == "union" and (in_set1 or in_set2)) then
                    chars[i] = "1"
                else
                    chars[i] = "0"
                end
            end
            result = table.concat(chars)
            memo[set1][set2] = result
        end
        return result
    end
    -- nil stands for no set yet, so that this can fold over alternatives
    local function intersect(set1, set2)
        if set1 == nil then
            return set2
        end
        return combine("intersection", set1, set2)
    end
    local function with_room(set, room)
        local i = room_ind[room]
        return combine("union", set, string.rep("0", i - 1) .. "1" .. string.rep("0", #rooms - i))
    end

    -- node_key --> context --> rooms needed, for every pebble the sort reached
    -- Pebbles start at all rooms (sources at their final sets), so a prerequisite pebble has a set exactly when the sort reached it
    local needed = {}
    for node_key, inds in pairs(sort_info.node_to_context_inds) do
        if next(inds) ~= nil then
            local node = graph.nodes[node_key]
            local start_set = all_rooms
            if gutils.is_source(graph, node) then
                start_set = no_rooms
                if type(logic.type_info[node.type].context) == "string" then
                    start_set = with_room(no_rooms, node.name)
                end
            end
            needed[node_key] = {}
            for context, _ in pairs(inds) do
                needed[node_key][context] = start_set
            end
        end
    end

    -- Recomputes a node's sets from its prerequisites' sets, and returns whether any shrank
    local function update(node_key)
        local node = graph.nodes[node_key]
        local node_needed = needed[node_key]
        if node_needed == nil or gutils.is_source(graph, node) then
            return false
        end

        -- Rooms needed by each incoming context that satisfies the node (edges don't change simple contexts)
        local incoming = {}
        for _, context in pairs(rooms) do
            local set
            local is_satisfied = node.op == "AND"
            for pre, _ in pairs(node.pre) do
                local pre_set = (needed[graph.edges[pre].start] or {})[context]
                if node.op == "OR" then
                    if pre_set ~= nil then
                        is_satisfied = true
                        set = intersect(set, pre_set)
                    end
                elseif pre_set == nil then
                    is_satisfied = false
                    break
                else
                    set = combine("union", set or no_rooms, pre_set)
                end
            end
            if is_satisfied then
                incoming[context] = set
            end
        end

        local new_needed = {}
        local context_type = logic.type_info[node.type].context
        if context_type == nil then
            new_needed = incoming
        else
            local common
            for _, set in pairs(incoming) do
                common = intersect(common, set)
            end
            if common ~= nil then
                if context_type == true then
                    for context, _ in pairs(node_needed) do
                        new_needed[context] = common
                    end
                else
                    -- Rooms use node.name for the room, see contutils.transmit
                    new_needed[node.name] = with_room(common, node.name)
                end
            end
        end
        local has_shrunk = false
        for context, set in pairs(new_needed) do
            if node_needed[context] ~= set then
                node_needed[context] = set
                has_shrunk = true
            end
        end
        return has_shrunk
    end

    -- Going in sort order first means most nodes see their prerequisites' final sets on the first visit
    local queue = {}
    local is_queued = {}
    local function push(node_key)
        if is_queued[node_key] == nil then
            is_queued[node_key] = true
            table.insert(queue, node_key)
        end
    end
    for _, pebble in pairs(sort_info.sorted) do
        push(pebble.node_key)
    end
    local queue_pos = 1
    while queue_pos <= #queue do
        local node_key = queue[queue_pos]
        queue_pos = queue_pos + 1
        is_queued[node_key] = nil
        if update(node_key) then
            for dep, _ in pairs(graph.nodes[node_key].dep) do
                push(graph.edges[dep].stop)
            end
        end
    end

    return {
        needed = needed,
        intersect = intersect,
        -- Set string --> room --> true
        decode = function(set)
            local decoded = {}
            for i = 1, #rooms do
                if string.sub(set, i, i) == "1" then
                    decoded[rooms[i]] = true
                end
            end
            return decoded
        end,
    }
end

-- For every pebble of a sort without complex contexts, the rooms it can't be reached without (see compute_rooms_needed)
-- Returns a function (node_key, context) --> { room --> true }, which gives nil for a pebble that can't be reached at all
top.rooms_needed = function(graph)
    local info = compute_rooms_needed(graph)
    return function(node_key, context)
        local set = (info.needed[node_key] or {})[context]
        if set == nil then
            return nil
        end
        return info.decode(set)
    end
end

-- Keys of a set, sorted, for logging
local function sorted_keys(set)
    local keys = {}
    for set_key, _ in pairs(set) do
        table.insert(keys, set_key)
    end
    table.sort(keys)
    return keys
end

-- Home sets: a room's home set is the rooms its discoverers (see top.is_discoverer) can't be reached without, like Nauvis and space platforms for Vulcanus
-- Those rooms have been used by the time the room is discovered, so with home contexts, a tech that can be had using only them is isolatable there once it's discovered (see discover_home_rooms in top.sort)
-- Returns { ids = list of home set ids, sets = id --> { rooms = room --> true, discovered = room --> true for the rooms it's the home set of }, of = room --> home set id }
-- Rooms with the same home set share it, and rooms with no reachable discoverer have none
-- Home sets are meant to come from the vanilla graph, so a sort of a randomized graph should pass the vanilla ones as extra.home_sets
-- Also returns the rooms the graph has discoverers of but reaches none of (sorted, and logged): nothing is isolatable in them by discovery, so they mean the graph isn't one to take home sets from (like a planetary change's world before unified pays its debt)
top.home_sets = function(graph)
    local info = compute_rooms_needed(graph)

    -- Room --> rooms that all its discoverers need
    local needs_of_room = {}
    for node_key, node in pairs(graph.nodes) do
        if top.is_discoverer(node) and info.needed[node_key] ~= nil then
            -- A discoverer counts once it's reached in any context
            local node_needs
            for _, set in pairs(info.needed[node_key]) do
                node_needs = info.intersect(node_needs, set)
            end
            for _, discovered in pairs(top.discovered_rooms(node)) do
                if logic.contexts[discovered.room] ~= nil then
                    -- Any one of a room's discoverers discovers it
                    needs_of_room[discovered.room] = info.intersect(needs_of_room[discovered.room], node_needs)
                end
            end
        end
    end

    -- Group rooms with the same home set, and number the sets in a fixed order
    local rooms_with_needs = {}
    local needs_list = {}
    for room, needs in pairs(needs_of_room) do
        if rooms_with_needs[needs] == nil then
            rooms_with_needs[needs] = {}
            table.insert(needs_list, needs)
        end
        rooms_with_needs[needs][room] = true
    end
    table.sort(needs_list)
    local home_sets = {
        ids = {},
        sets = {},
        of = {},
    }
    for i = 1, #needs_list do
        local needs = needs_list[i]
        local home_id = "home" .. tostring(i)
        table.insert(home_sets.ids, home_id)
        home_sets.sets[home_id] = {
            rooms = info.decode(needs),
            discovered = rooms_with_needs[needs],
        }
        for room, _ in pairs(rooms_with_needs[needs]) do
            home_sets.of[room] = home_id
        end
        log("Home set " .. home_id .. " of " .. table.concat(sorted_keys(rooms_with_needs[needs]), ", ") .. ": " .. table.concat(sorted_keys(home_sets.sets[home_id].rooms), ", "))
    end

    local undiscovered = {}
    for room, _ in pairs(top.room_discoverers(graph)) do
        if logic.contexts[room] ~= nil and needs_of_room[room] == nil then
            table.insert(undiscovered, room)
        end
    end
    table.sort(undiscovered)
    if #undiscovered > 0 then
        log("Home sets: no discoverer of " .. table.concat(undiscovered, ", ") .. " is reachable, so nothing is isolatable there by discovery; home sets should come from a game that can discover every room")
    end
    return home_sets, undiscovered
end

-- Home sets both given home sets agree on: each room's home set is the rooms in both (a room only one of them has keeps that one's)
-- A smaller home set grants less (see discover_home_rooms), so after a change to the game (like a planetary one) that may change which rooms discoveries need, this is the careful choice (notes/context-shift-report, the remark on home sets)
-- Returns home sets like top.home_sets does
top.intersect_home_sets = function(a, b)
    local needs_of_room = {}
    local rooms = {}
    for room, _ in pairs(a.of) do
        rooms[room] = true
    end
    for room, _ in pairs(b.of) do
        rooms[room] = true
    end
    for room, _ in pairs(rooms) do
        local a_rooms = a.of[room] ~= nil and a.sets[a.of[room]].rooms or nil
        local b_rooms = b.of[room] ~= nil and b.sets[b.of[room]].rooms or nil
        local needs = {}
        for needed, _ in pairs(a_rooms or b_rooms) do
            if a_rooms == nil or b_rooms == nil or (a_rooms[needed] ~= nil and b_rooms[needed] ~= nil) then
                needs[needed] = true
            end
        end
        needs_of_room[room] = needs
    end
    -- Group rooms with the same needs, numbered in a fixed order (by their needs, then their rooms)
    local rooms_with_needs = {}
    local needs_of_text = {}
    for room, needs in pairs(needs_of_room) do
        local text = table.concat(sorted_keys(needs), "\n")
        if rooms_with_needs[text] == nil then
            rooms_with_needs[text] = {}
            needs_of_text[text] = needs
        end
        rooms_with_needs[text][room] = true
    end
    local texts = sorted_keys(rooms_with_needs)
    local home_sets = {
        ids = {},
        sets = {},
        of = {},
    }
    for i, text in pairs(texts) do
        local home_id = "home" .. tostring(i)
        table.insert(home_sets.ids, home_id)
        home_sets.sets[home_id] = {
            rooms = needs_of_text[text],
            discovered = rooms_with_needs[text],
        }
        for room, _ in pairs(rooms_with_needs[text]) do
            home_sets.of[room] = home_id
        end
    end
    return home_sets
end

-- Whether two home sets give every room the same rooms (ids aside)
top.same_home_sets = function(a, b)
    for _, sets in pairs({
        {
            a,
            b,
        },
        {
            b,
            a,
        },
    }) do
        local x = sets[1]
        local y = sets[2]
        for room, home_id in pairs(x.of) do
            if y.of[room] == nil then
                return false
            end
            local x_rooms = x.sets[home_id].rooms
            local y_rooms = y.sets[y.of[room]].rooms
            for needed, _ in pairs(x_rooms) do
                if y_rooms[needed] == nil then
                    return false
                end
            end
        end
    end
    return true
end

-- Transmission rules for callers that reason about backings (like promotion), so the rules live only in this file
-- Cached as complex --> home sets (false for none) --> context info
local context_info_cache = {}
local function cached_context_info(sort_info)
    local complex = sort_info.complex == true
    local home_key = sort_info.home_sets or false
    context_info_cache[complex] = context_info_cache[complex] or {}
    if context_info_cache[complex][home_key] == nil then
        context_info_cache[complex][home_key] = build_context_info(complex, sort_info.home_sets)
    end
    return context_info_cache[complex][home_key]
end

-- Contexts leaving edge.start that would make context arrive at edge.stop, for a sort made by top.sort
top.edge_source_contexts = function(sort_info, edge, context)
    return edge_sources(cached_context_info(sort_info), edge, context)
end

-- Contexts leaving node when incoming arrives at it, for a sort made by top.sort
top.node_transmit = function(sort_info, node, incoming)
    return node_transmit(cached_context_info(sort_info), node, incoming)
end

top.sort = function(graph, state, new_conn, extra)
    -- state should be passed in if and only if we're doing a cached sort with a new_conn
    if (state ~= nil and new_conn == nil) or (state == nil and new_conn ~= nil) then
        error("Ambiguous signals for whether this is a cached sort!")
    end

    -- Initialize state vars
    state = state or {}
    extra = extra or {}
    -- A cached sort keeps whatever kind of contexts it was started with
    local complex = extra.complex_contexts == true
    if state.complex ~= nil then
        if extra.complex_contexts ~= nil and complex ~= state.complex then
            error("Cached sort was made with a different complex_contexts setting")
        end
        complex = state.complex
    end
    -- Home sets for home contexts, or nil for none, which a cached sort also keeps
    local home_sets
    if state.complex ~= nil then
        if extra.home_contexts ~= nil and extra.home_contexts ~= (state.home_sets ~= nil) then
            error("Cached sort was made with a different home_contexts setting")
        end
        home_sets = state.home_sets
    elseif extra.home_contexts == true then
        home_sets = extra.home_sets or logic.home_sets or top.home_sets(graph)
    end
    local context_info = build_context_info(complex, home_sets)
    -- node_to_context_inds goes node_key --> { context --> index | nil }, where index is when the node_key/context combo was added in sorted, nil if nonexistent
    -- Represents the OUTGOING contexts
    -- To check incoming, check node_to_context_inds on the prerequisite nodes (through the edge, which could change abilities)
    -- This is updated when processed from open (not when added to it)
    local node_to_context_inds = state.node_to_context_inds or {}
    local sorted = state.sorted or {}
    -- Table of node_key --> nil or { context --> true }
    local open = state.open or {}
    -- open's keys as a list, plus each key's position in that list, so random selection doesn't need to scan open
    local open_list = state.open_list or {}
    local open_pos = state.open_pos or {}
    -- Space locations whose discovery has already been handled (complex contexts only)
    local discovered_space_locations = state.discovered_space_locations or {}
    -- With home contexts instead: rooms discovered so far, and home set id --> techs with a pebble in one of its home contexts (see discover_home_rooms)
    local home_discovered = state.home_discovered or {}
    local home_techs = state.home_techs or {}
    -- Don't choose randomly for backwards compatibility with Frodo version
    if not DO_FRODO_FIXES and extra.choose_randomly == false then
        extra.choose_randomly = true
    end

    -- Without choose_randomly, the next node is the open node with the earliest pebble (lowest index in sorted), or the last one pairs(open) gives if no open node has a pebble yet
    -- A node's earliest pebble can't change while it's in open (only the node taken out of open gets new pebbles, and they come after its old ones), so the open nodes with one wait in a heap ordered by it
    -- Indices are unique, so the heap never has to break a tie
    local use_heap = not extra.choose_randomly
    local heap_inds = {}
    local heap_keys = {}
    local heap_size = 0

    local function heap_push(ind, node_key)
        heap_size = heap_size + 1
        local pos = heap_size
        while pos > 1 do
            local parent = math.floor(pos / 2)
            if heap_inds[parent] < ind then
                break
            end
            heap_inds[pos] = heap_inds[parent]
            heap_keys[pos] = heap_keys[parent]
            pos = parent
        end
        heap_inds[pos] = ind
        heap_keys[pos] = node_key
    end

    local function heap_pop()
        local earliest_key = heap_keys[1]
        local last_ind = heap_inds[heap_size]
        local last_key = heap_keys[heap_size]
        heap_inds[heap_size] = nil
        heap_keys[heap_size] = nil
        heap_size = heap_size - 1
        if heap_size > 0 then
            local pos = 1
            while true do
                local child = 2 * pos
                if child > heap_size then
                    break
                end
                if child < heap_size and heap_inds[child + 1] < heap_inds[child] then
                    child = child + 1
                end
                if last_ind < heap_inds[child] then
                    break
                end
                heap_inds[pos] = heap_inds[child]
                heap_keys[pos] = heap_keys[child]
                pos = child
            end
            heap_inds[pos] = last_ind
            heap_keys[pos] = last_key
        end
        return earliest_key
    end

    -- Puts a node that just entered open in the heap, if it has a pebble
    local function heap_add(node_key)
        local earliest
        for _, ind in pairs(node_to_context_inds[node_key]) do
            if earliest == nil or ind < earliest then
                earliest = ind
            end
        end
        if earliest ~= nil then
            heap_push(earliest, node_key)
        end
    end

    -- Initialize node_to_context_inds on *all* nodes, etc.
    -- Only do this on new sorts
    -- We'll actually populate initial "open" list later
    if new_conn == nil then
        for node_key, _ in pairs(graph.nodes) do
            node_to_context_inds[node_key] = {}
        end
    end
    -- A sort always empties open, but whatever a state still has open goes in the heap too
    if use_heap then
        for node_key, _ in pairs(open) do
            heap_add(node_key)
        end
    end

    -- node_key is key(node), when the caller has it
    local function add_to_open(node, context, node_key)
        node_key = node_key or key(node)
        if open[node_key] == nil then
            open[node_key] = {}
            table.insert(open_list, node_key)
            open_pos[node_key] = #open_list
            if use_heap then
                heap_add(node_key)
            end
        end
        open[node_key][context] = true
    end

    -- Swap-remove from open_list so this is O(1)
    local function remove_from_open(node_key)
        local pos = open_pos[node_key]
        local last_key = open_list[#open_list]
        open_list[pos] = last_key
        open_pos[last_key] = pos
        open_list[#open_list] = nil
        open_pos[node_key] = nil
        open[node_key] = nil
    end

    -- Checks if this depnode *newly* has context
    -- incoming is the context as it arrives at depnode (after going through the edge)
    -- depnode_key is key(depnode), and edge_key the edge incoming came through, when the caller has them
    local function process_depnode(depnode, incoming, depnode_key, edge_key)
        depnode_key = depnode_key or key(depnode)

        local check
        if depnode.op == "OR" then
            -- OR is false until proven true
            -- Any prereq with a pebble proves it, and the one incoming came through usually has one, so it's tried first
            if edge_key ~= nil and depnode.pre[edge_key] ~= nil and edge_ind(context_info, node_to_context_inds, graph.edges[edge_key], incoming) ~= nil then
                check = true
            else
                check = false
                for pre, _ in pairs(depnode.pre) do
                    if edge_ind(context_info, node_to_context_inds, graph.edges[pre], incoming) ~= nil then
                        check = true
                        break
                    end
                end
            end
        elseif depnode.op == "AND" then
            -- AND is true until proven false
            check = true
            for pre, _ in pairs(depnode.pre) do
                if edge_ind(context_info, node_to_context_inds, graph.edges[pre], incoming) == nil then
                    check = false
                    break
                end
            end
        else
            error("Invalid node op: " .. tostring(depnode.op))
        end

        if check then
            -- Nodes that aren't rooms or forgetters send complex and home contexts on unchanged (see node_transmit), which needs no list
            if logic.type_info[depnode.type].context == nil and (complex or context_info.home[incoming] ~= nil) then
                -- Skip contexts the depnode is already transmitting
                if node_to_context_inds[depnode_key][incoming] == nil then
                    add_to_open(depnode, incoming, depnode_key)
                end
            else
                local outgoing_contexts = node_transmit(context_info, depnode, incoming)
                for _, outgoing in pairs(outgoing_contexts) do
                    -- Skip contexts the depnode is already transmitting
                    if node_to_context_inds[depnode_key][outgoing] == nil then
                        add_to_open(depnode, outgoing, depnode_key)
                    end
                end
            end
        end
    end

    -- If a node discovers a room (a tech unlocking a space location, or a spaceship for space platforms), every tech so far is considered isolatable there (ported from extended-sort.lua)
    local function discover_space_locations(tech_node)
        for _, discovered in pairs(top.discovered_rooms(tech_node)) do
            local loc = discovered.location
            if discovered_space_locations[loc] == nil then
                discovered_space_locations[loc] = true
                local room_contexts = context_info.of[discovered.room]
                if room_contexts ~= nil then
                    for node_key, node in pairs(graph.nodes) do
                        if node.type == "technology" and (next(node_to_context_inds[node_key]) ~= nil or open[node_key] ~= nil) then
                            for ability_str, context in pairs(room_contexts) do
                                if has_ability(ability_str, ISOLATABILITY) and node_to_context_inds[node_key][context] == nil then
                                    add_to_open(node, context)
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Gives a tech the isolatable contexts of a room that it doesn't have yet
    local function add_isolatable_contexts(tech_node, room)
        local tech_key = key(tech_node)
        for ability_str, context in pairs(context_info.of[room]) do
            if has_ability(ability_str, ISOLATABILITY) and node_to_context_inds[tech_key][context] == nil then
                add_to_open(tech_node, context)
            end
        end
    end

    -- The discovery rule with home contexts, which doesn't depend on order: once a room is discovered, every tech that can be had using only its home set is isolatable there
    -- This half runs when a discoverer is reached, and add_home_tech when a tech gets a home context, so the rule applies whichever comes first
    local function discover_home_rooms(discoverer)
        for _, discovered in pairs(top.discovered_rooms(discoverer)) do
            local room = discovered.room
            local home_id = home_sets.of[room]
            if home_id ~= nil and home_discovered[room] == nil then
                home_discovered[room] = true
                for tech_key, _ in pairs(home_techs[home_id] or {}) do
                    add_isolatable_contexts(graph.nodes[tech_key], room)
                end
            end
        end
    end

    local function add_home_tech(tech_node, home_id)
        local tech_key = key(tech_node)
        home_techs[home_id] = home_techs[home_id] or {}
        if home_techs[home_id][tech_key] == nil then
            home_techs[home_id][tech_key] = true
            for room, _ in pairs(home_sets.sets[home_id].discovered) do
                if home_discovered[room] ~= nil then
                    add_isolatable_contexts(tech_node, room)
                end
            end
        end
    end

    -- Now we can add starting nodes in open
    if new_conn == nil then
        for _, node in pairs(gutils.sources(graph)) do
            for _, context in pairs(context_info.list) do
                add_to_open(node, context)
            end
        end
    else
        -- Otherwise, add the dependent of the new_conn to open with the prereq's contexts (sent through the edge)
        local new_edge
        if complex then
            new_edge = graph.edges[gutils.ekey({
                start = key(new_conn[1]),
                stop = key(new_conn[2]),
            })]
        end
        for context, _ in pairs(node_to_context_inds[key(new_conn[1])]) do
            local arriving_contexts = { context }
            if new_edge ~= nil then
                arriving_contexts = edge_transmit(context_info, new_edge, context)
            end
            for _, arriving in pairs(arriving_contexts) do
                if extra.do_new_edge_processing then
                    process_depnode(new_conn[2], arriving)
                else
                    add_to_open(new_conn[2], arriving)
                end
            end
        end
    end

    -- Repeat until open is empty
    while #open_list > 0 do
        -- Find the next candidate to remove from open
        -- This is the node, if any, with lowest value in the node_to_context_inds table
        local node_key
        if extra.choose_randomly then
            -- Use the mod's rng so the sort follows the seed setting
            node_key = open_list[rng.int("context-sort", #open_list)]
        elseif heap_size > 0 then
            node_key = heap_pop()
        else
            -- No open node has a pebble yet (see use_heap above)
            for candidate_node_key, _ in pairs(open) do
                node_key = candidate_node_key
            end
        end

        local contexts = open[node_key]
        remove_from_open(node_key)
        -- Transmit contexts to each dependent
        local node = graph.nodes[node_key]
        -- Home sets that this node got a home context of
        local new_home_ids
        for context, _ in pairs(contexts) do
            -- Add this node-context pebble to sorted
            table.insert(sorted, {
                node_key = node_key,
                context = context,
            })
            -- Add the context
            node_to_context_inds[node_key][context] = #sorted

            -- Edges without abilities (and every edge, for simple and home contexts) pass the context on unchanged, as edge_transmit would, without making a list for it
            local passes_unchanged = not complex or context_info.home[context] ~= nil
            for dep, _ in pairs(node.dep) do
                local edge = graph.edges[dep]
                local depnode = graph.nodes[edge.stop]
                if passes_unchanged or edge.abilities == nil then
                    process_depnode(depnode, context, edge.stop, dep)
                else
                    for _, arriving in pairs(edge_transmit(context_info, edge, context)) do
                        process_depnode(depnode, arriving, edge.stop, dep)
                    end
                end
            end

            local home_id = context_info.home[context]
            if home_id ~= nil then
                new_home_ids = new_home_ids or {}
                new_home_ids[home_id] = true
            end
        end

        -- The discovery rules run after the whole batch, so a context they add isn't one this node is still processing
        if complex then
            if home_sets ~= nil then
                if node.type == "technology" then
                    for home_id, _ in pairs(new_home_ids or {}) do
                        add_home_tech(node, home_id)
                    end
                end
                if top.is_discoverer(node) then
                    discover_home_rooms(node)
                end
            elseif top.is_discoverer(node) then
                discover_space_locations(node)
            end
        end
    end

    return {
        node_to_context_inds = node_to_context_inds,
        sorted = sorted,
        open = open,
        open_list = open_list,
        open_pos = open_pos,
        complex = complex,
        -- Every context this sort uses, for iterating over in place of logic.contexts
        contexts = context_info.list,
        discovered_space_locations = discovered_space_locations,
        home_sets = home_sets,
        home_discovered = home_discovered,
        home_techs = home_techs,
    }
end

-- For a tech pebble in an isolatable context that it could have gotten by discovery (see top.discovery_candidates): the earliest earlier pebble of the tech itself and of a discoverer of the room, or nil
local function find_discovery_preinds(sort_info, room_discoverers, tech_node, context, curr_ind)
    local candidates = top.discovery_candidates(sort_info, room_discoverers, tech_node, context)
    if candidates == nil then
        return nil
    end
    local own_ind = candidates.own[1]
    local discoverer_ind = candidates.discoverers[1]
    if own_ind == nil or own_ind >= curr_ind or discoverer_ind == nil or discoverer_ind >= curr_ind then
        return nil
    end
    return { own_ind, discoverer_ind }
end

-- This is taken mainly from top-sort.lua
-- Creates a path of inds within sort_info.sorted starting from the goal and going backwards for how to get there
-- goal_inds is a list of inds in sort_info.sorted of the pebbles we are hoping to achieve
top.path = function(graph, goal_inds, sort_info, extra_params)
    local sorted = sort_info.sorted
    local node_to_context_inds = sort_info.node_to_context_inds
    local context_info = build_context_info(sort_info.complex == true, sort_info.home_sets)
    extra_params = extra_params or {}
    local stop_if = extra_params.stop_if or function(pebble) return false end
    -- Only needed for the discovery rule, so found when first used
    local room_discoverers

    local path = goal_inds
    -- Whether an index is in the path yet
    local in_path = {}
    for _, ind in pairs(path) do
        in_path[ind] = true
    end

    local path_ind = 1
    while path_ind <= #path do
        local curr_ind = path[path_ind]
        local curr_pebble = sorted[curr_ind]
        local curr_context = curr_pebble.context
        local curr_node = graph.nodes[curr_pebble.node_key]

        -- context is the context arriving at node
        local function find_preinds(node, context)
            local preinds = {}

            if node.op == "OR" then
                -- Just try earliest prereq (could be suboptimal, but this is a good heuristic)
                -- Start at curr_ind to more easily do error checking on indeed getting an earlier pebble
                local first_occurrence_ind = curr_ind
                for pre, _ in pairs(node.pre) do
                    -- Need to check that context is non-nil since OR nodes can depend on later things/with different contexts
                    local pre_ind = edge_ind(context_info, node_to_context_inds, graph.edges[pre], context)
                    if pre_ind ~= nil and pre_ind < first_occurrence_ind then
                        first_occurrence_ind = pre_ind
                    end
                end
                -- Make sure we found something/didn't loop
                if first_occurrence_ind == curr_ind then
                    return false
                end
                table.insert(preinds, first_occurrence_ind)
            elseif node.op == "AND" then
                -- Add all previous pebbles to the path
                for pre, _ in pairs(node.pre) do
                    local prev_ind = edge_ind(context_info, node_to_context_inds, graph.edges[pre], context)
                    -- If this is nil, then not satisfiable, so abandon this context
                    if prev_ind == nil then
                        return false
                    end
                    -- prev_ind >= curr_ind can happen in a valid manner, it just means this is an invalid context
                    table.insert(preinds, prev_ind)
                end
            end

            return preinds
        end

        -- Whether incoming arriving at curr_node would send out curr_context
        local function transmits_curr_context(incoming)
            if not context_info.complex then
                return true
            end
            for _, outgoing in pairs(node_transmit(context_info, curr_node, incoming)) do
                if outgoing == curr_context then
                    return true
                end
            end
            return false
        end

        local discovery_preinds
        if logic.type_info[curr_node.type].context ~= nil then
            -- In this case, we assume just the forgetting contexts for now (true or string type)
            -- We then lost the context info, so we just choose the earliest context that appears earlier in the sort
            -- We'll choose that context and then do the rest with that
            local earliest_context_ind = curr_ind
            local outgoing_context = curr_context
            for _, context in pairs(context_info.list) do
                local preinds = false
                if transmits_curr_context(context) then
                    preinds = find_preinds(curr_node, context)
                end
                if preinds ~= false then
                    local latest_ind
                    for _, ind in pairs(preinds) do
                        if latest_ind == nil or ind > latest_ind then
                            latest_ind = ind
                        end
                    end
                    if latest_ind == nil then
                        if curr_node.op == "OR" then
                            -- This means no prereqs and it's an OR, so shouldn't have been found in the first place
                            -- Oh that's fine we just ignore the context
                        else
                            -- In this case, we're satisfiable immediately anyways due to having no prereqs, and the exact context doesn't matter
                            -- Give earliest_context_ind a 0 so that later sanity checks don't complain
                            earliest_context_ind = 0
                            curr_context = context
                            break
                        end
                    else
                        if latest_ind < earliest_context_ind then
                            earliest_context_ind = latest_ind
                            curr_context = context
                        end
                    end
                end
            end
            -- Isolatable contexts of techs can also come from discovering their space location (see discover_space_locations and discover_home_rooms in top.sort)
            -- Then the path goes through the tech itself in an earlier context (a home context of the location with home contexts) and an earlier pebble of a tech that unlocks the location
            if earliest_context_ind == curr_ind and context_info.complex and curr_node.type == "technology" then
                room_discoverers = room_discoverers or top.room_discoverers(graph)
                discovery_preinds = find_discovery_preinds(sort_info, room_discoverers, curr_node, outgoing_context, curr_ind)
            end
            -- If nothing was earlier, that's a contradiction
            if earliest_context_ind == curr_ind and discovery_preinds == nil then
                log(serpent.block(curr_node))
                log(outgoing_context)
                error("No earlier contexts possible.")
            end
        end

        -- Now, either way, we go from curr_context
        local preinds = discovery_preinds or find_preinds(curr_node, curr_context)
        -- preinds should always be valid by here
        if preinds == false then
            log(serpent.block(curr_pebble))
            error()
        end
        if path_ind == 1 or not stop_if(curr_pebble) then
            for _, ind in pairs(preinds) do
                if not in_path[ind] then
                    in_path[ind] = true
                    table.insert(path, ind)
                end
            end
        end

        path_ind = path_ind + 1
    end

    return {
        path = path,
        in_path = in_path,
    }
end

-- Trims unnecessary contexts out of state's sorted list, starting from the back
-- Might not be necessary with top.path now
top.trim = function(graph, state)
    -- TODO
end

return top
