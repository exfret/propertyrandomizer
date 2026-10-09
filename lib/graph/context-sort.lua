-- A copy of consistent-sort.lua that can optionally also track the ability contexts (isolatability/automatability) from extended-sort.lua
-- Kept as close to consistent-sort.lua as possible so that callers can be ported over by just swapping the require
-- Differences from consistent-sort.lua:
--   1. Pass extra.complex_contexts = true to make each context a room with an ability mask rather than just a room
--      Contexts are numbers (see lib/graph/contexts.lua), a simple context standing for its room, so the rest of the sort treats them all alike
--   2. Contexts are now also transmitted through edges, since edges can add/remove abilities (edge.abilities)
--   3. Random selection from open is O(1) using a list of open keys, rather than rebuilding that list every step
--   4. Pass extra.home_contexts = true to also track home contexts (see Home contexts below), with or without complex contexts
--      Their home sets come from extra.home_sets if given (see top.home_sets), then logic.home_sets (the vanilla ones, stored by data-final-fixes.lua before randomization), and otherwise from the graph being sorted
-- Without complex contexts, this should behave exactly like consistent-sort.lua except for which random node is picked
-- I kept the pebble terminology: a *pebble* is a node_key/context pair

local ctx = require("lib/graph/contexts")
local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local rng = require("lib/random/rng")
-- Used for contexts and such; actual logic dependency graph is passed in
local logic = require("lib/logic/state")

-- Shortcuts
local key = gutils.key

-- Ability indices, matching edge.abilities (see lib/logic/builder.lua)
local ISOLATABILITY = ctx.ISOLATABILITY
local AUTOMATABILITY = ctx.AUTOMATABILITY
-- Edge abilities code --> mask + 1 --> the masks coming out of the edge, and those going in that make a mask come out (see contexts.forward_masks and contexts.inverse_masks)
local FORWARD_MASKS = ctx.FORWARD_MASKS
local INVERSE_MASKS = ctx.INVERSE_MASKS

local top = {}

top.ISOLATABILITY = ISOLATABILITY
-- Whether home contexts are kept to their home set's own rooms (see Home contexts above), rather than every room; false only to compare with how sorts used to be
top.home_contexts_in_set_rooms = true
-- Whether a smaller home set's home context stands for those of the home sets containing it in the same room (see Home contexts above), rather than each being passed on; false only to compare with how sorts used to be
top.implied_home_contexts = true
top.AUTOMATABILITY = AUTOMATABILITY

-- Every ability mask, in the order sorts go through them (see lib/graph/contexts.lua)
local masks = ctx.masks
top.ability_masks = masks
-- The weakest mask: no edge takes it away, so a node with any context in a room also has this one there
local NO_ABILITIES = ctx.NO_ABILITIES
top.NO_ABILITIES = NO_ABILITIES

local has_ability = ctx.has_ability
local with_ability = ctx.with_ability
top.has_ability = has_ability
top.with_ability = with_ability
top.without_ability = ctx.without_ability
-- Whether a mask has every ability another has
top.mask_covers = ctx.mask_covers
-- How a mask is written in logs, like "10"
top.mask_name = ctx.mask_name
-- Whether edge abilities (an edge's or a connection's, or nil for none) gain or lose an ability
top.edge_changes = ctx.edge_changes

-- Context helpers (see lib/graph/contexts.lua for how contexts are numbered)

-- Complex context of a room with an ability mask, or nil for a room that isn't a context
top.context_key = ctx.complex
-- Simple context of a room (a sort without complex contexts), or nil for a room that isn't a context
top.simple_context = ctx.simple

-- Home contexts
-- A home set is a set of rooms (see top.home_sets), and a pebble's home context for it means the pebble can be had using only those rooms
-- This is what removing every other room's node and sorting again would give, but for every home set in the same sort
-- Home contexts ride on each room's weakest context (the room's simple context for simple contexts, the room with no abilities for complex ones), and are named like "planet: vulcanus | 00 @ home1"
-- Only the home set's own rooms have its home contexts (with top.home_contexts_in_set_rooms): no other room's node sends them, so all another room could get is what forgetters send every room, and the set's rooms get that too
-- With complex contexts, they replace the order-dependent discovery rule: once a room is discovered, techs with a home context of its home set are isolatable there (see discover_home_rooms in top.sort)
-- What can be had using only a home set's rooms can be had using only the rooms of any home set containing it, so with top.implied_home_contexts a smaller home set's context stands for the bigger ones' in the same room: those aren't passed on, and looking for one counts the other
-- Discovery tiers make every home set hold the ones before it (randomizations/planetary/discovery.lua), so each pebble then needs only its earliest tier's home context instead of one per later tier (user, 2026-10-09)
-- Forgetters and rooms send the bigger ones' contexts to rooms the smaller one has none in, and the end of a sort writes out the ones that stood in, so what reads a sort finds every home context as before

-- The home context riding on a context (home sets are numbered, see top.home_sets)
top.home_context_key = ctx.home

-- The context a home context rides on, or the context itself if it isn't one
local without_home = ctx.without_home
top.context_without_home = without_home

top.context_room = ctx.room

-- Ability mask of a complex context, nil for simple ones
top.context_mask = ctx.mask

-- Home set number of a home context, or nil for other contexts
top.context_home = ctx.home_of

-- How a context is written in logs and on the panel, like "planet: nauvis | 11" (from lookup tables, see lib/graph/contexts.lua)
top.context_name = ctx.name
top.home_name = ctx.home_name
-- Names of a list of contexts, for logs
top.context_names = ctx.names

-- Sorts a list of contexts by name, for logs (decisions order contexts by number)
local function by_name(a, b)
    return ctx.name(a) < ctx.name(b)
end
top.sort_by_name = function(list)
    table.sort(list, by_name)
end

-- Orders pebbles (tables with node_key and context) by node key, then context, for table.sort
top.pebble_order = function(a, b)
    if a.node_key ~= b.node_key then
        return a.node_key < b.node_key
    end
    return a.context < b.context
end

-- The context in the same room asking for automatability on top of what this one asks for, or nil for one that already does, a simple context or a home context
top.automatable_counterpart = function(context)
    local mask = ctx.mask(context)
    if mask == nil or ctx.home_of(context) ~= nil or has_ability(mask, AUTOMATABILITY) then
        return nil
    end
    return ctx.with_mask(context, with_ability(mask, AUTOMATABILITY))
end

-- Whether a node's contexts in a sort (context --> anything) provide a goal context: the context itself, or its isolatable counterpart when the goal isn't isolatable, since whatever can be had isolatably can be had without isolatability too (a sort records the contexts of its routes, so the weaker one needn't be there on its own)
-- Nothing else is implied: automatability must match, and home contexts and simple contexts are looked up unchanged
-- The checks of what randomization must keep compare goal contexts through this (randomizations/planetary/check.lua, settlement's witnesses, first pass's debt goals), like the mechanic context check's kept parts (skeleton/protection.lua)
top.provides_context = function(contexts, context)
    if contexts[context] ~= nil then
        return true
    end
    local mask = ctx.mask(context)
    if mask == nil or ctx.home_of(context) ~= nil or has_ability(mask, ISOLATABILITY) then
        return false
    end
    return contexts[ctx.with_mask(context, with_ability(mask, ISOLATABILITY))] ~= nil
end

-- Whether a node's contexts in a sort with complex contexts (context --> anything) include an isolatable one in a room: it can be had there from the room's own resources, without bringing anything in (lib/logic/builder.lua)
-- Home contexts and simple contexts never count
top.isolatable_in = function(contexts, room)
    if contexts == nil then
        return false
    end
    for _, mask in pairs(masks) do
        if has_ability(mask, ISOLATABILITY) then
            local context = ctx.complex(room, mask)
            if context ~= nil and contexts[context] ~= nil then
                return true
            end
        end
    end
    return false
end

-- Gets the lookup tables for the contexts used in a sort
-- For simple contexts, the contexts are just the rooms' simple contexts, like the rooms in consistent-sort.lua
-- home_sets (from top.home_sets) adds home contexts, or is nil for none
local function build_context_info(complex, home_sets)
    ctx.number_rooms(logic.contexts)
    local context_info = {
        complex = complex,
        -- Every context
        list = {},
        -- The rooms' simple contexts, in room order (simple contexts only)
        simple_list = {},
        -- context --> room (complex and home contexts only)
        room = {},
        -- context --> ability mask (complex contexts only)
        mask = {},
        -- room --> ability mask + 1 --> context (complex contexts only)
        of = {},
        -- context --> home set id (home contexts only)
        home = {},
        -- room --> home set id --> context (home contexts only)
        home_of = {},
        -- home set id --> room --> true for the rooms in it (home contexts only)
        home_rooms = {},
        -- home set id --> the other home sets containing it, and those inside it (home contexts only, see top.implied_home_contexts)
        home_supersets = {},
        home_subsets = {},
        -- home set id --> how many rooms it has (home contexts only)
        home_size = {},
    }
    for room, _ in pairs(logic.contexts) do
        if complex then
            context_info.of[room] = {}
            for _, mask in pairs(masks) do
                local context = ctx.complex(room, mask)
                table.insert(context_info.list, context)
                context_info.room[context] = room
                context_info.mask[context] = mask
                context_info.of[room][mask + 1] = context
            end
        else
            table.insert(context_info.list, ctx.simple(room))
            table.insert(context_info.simple_list, ctx.simple(room))
        end
        if home_sets ~= nil then
            -- Home contexts ride on the room's weakest context
            local base = ctx.simple(room)
            if complex then
                base = context_info.of[room][NO_ABILITIES + 1]
            end
            context_info.home_of[room] = {}
            for _, home_id in pairs(home_sets.ids) do
                -- A home set with no rooms at all keeps its home contexts everywhere, so what needs no room still gets one
                local set_rooms = home_sets.sets[home_id].rooms
                if not top.home_contexts_in_set_rooms or set_rooms[room] ~= nil or next(set_rooms) == nil then
                    local context = ctx.home(base, home_id)
                    table.insert(context_info.list, context)
                    context_info.room[context] = room
                    if complex then
                        context_info.mask[context] = NO_ABILITIES
                    end
                    context_info.home[context] = home_id
                    context_info.home_of[room][home_id] = context
                end
            end
        end
    end
    if home_sets ~= nil then
        for _, home_id in pairs(home_sets.ids) do
            context_info.home_rooms[home_id] = home_sets.sets[home_id].rooms
        end
        for _, home_id in pairs(home_sets.ids) do
            local count = 0
            for _, _ in pairs(context_info.home_rooms[home_id]) do
                count = count + 1
            end
            context_info.home_size[home_id] = count
        end
        -- A home set stands for the contexts of those containing it, and those inside it stand for its own (top.implied_home_contexts)
        for _, home_id in pairs(home_sets.ids) do
            context_info.home_supersets[home_id] = {}
            context_info.home_subsets[home_id] = {}
        end
        if top.implied_home_contexts then
            for _, inner_id in pairs(home_sets.ids) do
                for _, outer_id in pairs(home_sets.ids) do
                    if inner_id ~= outer_id then
                        local inside = true
                        for room, _ in pairs(context_info.home_rooms[inner_id]) do
                            if context_info.home_rooms[outer_id][room] == nil then
                                inside = false
                                break
                            end
                        end
                        if inside then
                            table.insert(context_info.home_supersets[inner_id], outer_id)
                            table.insert(context_info.home_subsets[outer_id], inner_id)
                        end
                    end
                end
            end
            -- From the smallest containing home set up, which is the order process_depnode in top.sort tries them in
            for _, home_id in pairs(home_sets.ids) do
                table.sort(context_info.home_supersets[home_id], function(a, b)
                    if context_info.home_size[a] ~= context_info.home_size[b] then
                        return context_info.home_size[a] < context_info.home_size[b]
                    end
                    return a < b
                end)
            end
        end
    end
    return context_info
end

-- The earliest index of a home context among a node's pebbles, counting those of the home sets inside it in the same room, which stand for it (top.implied_home_contexts), or nil if none
local function implied_ind(context_info, inds, context)
    local earliest = inds[context]
    local subsets = context_info.home_subsets[context_info.home[context]]
    if subsets ~= nil and subsets[1] ~= nil then
        local room_homes = context_info.home_of[context_info.room[context]]
        for _, subset_id in pairs(subsets) do
            local subset_context = room_homes[subset_id]
            local ind = subset_context ~= nil and inds[subset_context] or nil
            if ind ~= nil and (earliest == nil or ind < earliest) then
                earliest = ind
            end
        end
    end
    return earliest
end

-- The contexts of the smallest home sets containing home_id that a room's home contexts (room --> home set id --> context) have, for a room without home_id's, or nil for none
-- member_room, when given, has to be in those home sets too (a room's own node only sends the home sets holding it)
local function smallest_containing(context_info, room_homes, home_id, member_room)
    local candidates = {}
    for _, superset_id in pairs(context_info.home_supersets[home_id] or {}) do
        if room_homes[superset_id] ~= nil and (member_room == nil or context_info.home_rooms[superset_id][member_room] ~= nil) then
            candidates[superset_id] = true
        end
    end
    local contexts
    for superset_id, _ in pairs(candidates) do
        -- Not one containing another candidate; of home sets with the same rooms, the first by id
        local smallest = true
        for _, inner_id in pairs(context_info.home_subsets[superset_id]) do
            if candidates[inner_id] ~= nil and (context_info.home_size[inner_id] < context_info.home_size[superset_id] or inner_id < superset_id) then
                smallest = false
                break
            end
        end
        if smallest then
            contexts = contexts or {}
            table.insert(contexts, room_homes[superset_id])
        end
    end
    return contexts
end

-- Contexts arriving at edge.stop when context leaves edge.start
-- Home contexts go through edges unchanged: they have no abilities to lose, and abilities an edge adds come from the context they ride on
local function edge_transmit(context_info, edge, context)
    if not context_info.complex or edge.abilities == nil or context_info.home[context] ~= nil then
        return { context }
    end
    local room_contexts = context_info.of[context_info.room[context]]
    local arriving = {}
    for _, mask in pairs(FORWARD_MASKS[edge.abilities][context_info.mask[context] + 1]) do
        table.insert(arriving, room_contexts[mask + 1])
    end
    return arriving
end

-- Contexts leaving edge.start that would make context arrive at edge.stop
local function edge_sources(context_info, edge, context)
    if not context_info.complex or edge.abilities == nil or context_info.home[context] ~= nil then
        return { context }
    end
    local room_contexts = context_info.of[context_info.room[context]]
    local sources = {}
    for _, mask in pairs(INVERSE_MASKS[edge.abilities][context_info.mask[context] + 1]) do
        table.insert(sources, room_contexts[mask + 1])
    end
    return sources
end

-- Earliest index in sorted of a pebble on edge.start that gets context to edge.stop, or nil if none
local function edge_ind(context_info, node_to_context_inds, edge, context)
    local start_inds = node_to_context_inds[edge.start]
    if context_info.home[context] ~= nil then
        return implied_ind(context_info, start_inds, context)
    end
    if not context_info.complex or edge.abilities == nil then
        return start_inds[context]
    end
    -- The same sources as edge_sources, without building the list
    local room_contexts = context_info.of[context_info.room[context]]
    local earliest_ind
    for _, mask in pairs(INVERSE_MASKS[edge.abilities][context_info.mask[context] + 1]) do
        local ind = start_inds[room_contexts[mask + 1]]
        if ind ~= nil and (earliest_ind == nil or ind < earliest_ind) then
            earliest_ind = ind
        end
    end
    return earliest_ind
end

-- Whether a pebble on edge.start gets context to edge.stop (edge_ind ~= nil), for callers that don't need the index: it stops at the first source found
local function edge_sends(context_info, node_to_context_inds, edge, context)
    local start_inds = node_to_context_inds[edge.start]
    if context_info.home[context] ~= nil then
        return implied_ind(context_info, start_inds, context) ~= nil
    end
    if not context_info.complex or edge.abilities == nil then
        return start_inds[context] ~= nil
    end
    local room_contexts = context_info.of[context_info.room[context]]
    for _, mask in pairs(INVERSE_MASKS[edge.abilities][context_info.mask[context] + 1]) do
        if start_inds[room_contexts[mask + 1]] ~= nil then
            return true
        end
    end
    return false
end

-- Contexts leaving node when a home context arrives at it
-- Home contexts go through nodes like the contexts they ride on, except that a room only sends them for the home sets containing it
-- A pebble has a home context exactly when it can be had using only the rooms in that home set
local function home_transmit(context_info, node, incoming, home_id)
    local context_type = logic.type_info[node.type].context
    if context_type == nil then
        return { incoming }
    elseif context_type == true then
        -- Home sets aren't tied to a room, so forgetters send them to every room that has them (like automatability)
        -- A room without them gets those of the smallest home sets containing it that it has, which this one stands for elsewhere (top.implied_home_contexts)
        local outgoing = {}
        for _, room_homes in pairs(context_info.home_of) do
            if room_homes[home_id] ~= nil then
                table.insert(outgoing, room_homes[home_id])
            else
                for _, context in pairs(smallest_containing(context_info, room_homes, home_id) or {}) do
                    table.insert(outgoing, context)
                end
            end
        end
        return outgoing
    elseif type(context_type) == "string" then
        -- Rooms use node.name for the room (type_info names one room for every room node)
        local room_contexts = context_info.home_of[node.name]
        if room_contexts == nil then
            error("Room node " .. node.name .. " is not a context")
        end
        if context_info.home_rooms[home_id][node.name] ~= nil then
            return { room_contexts[home_id] }
        end
        -- The room can still be in home sets containing this one, which it stands for (top.implied_home_contexts)
        return smallest_containing(context_info, room_contexts, home_id, node.name) or {}
    else
        -- Unhandled
        error()
    end
end

-- Contexts leaving node when incoming arrives at it
-- For simple contexts, as consistent-sort.lua's contutils.transmit does with rooms: forgetters send every room's simple context, and a room sends its own
-- For complex contexts this follows extended-sort.lua's transmit_through_node
local function node_transmit(context_info, node, incoming)
    local home_id = context_info.home[incoming]
    if home_id ~= nil then
        return home_transmit(context_info, node, incoming, home_id)
    end
    local context_type = logic.type_info[node.type].context
    if not context_info.complex then
        if context_type == nil then
            return { incoming }
        elseif context_type == true then
            local outgoing = {}
            for _, context in pairs(context_info.simple_list) do
                table.insert(outgoing, context)
            end
            return outgoing
        elseif type(context_type) == "string" then
            -- Rooms use node.name for the room (type_info names one room for every room node)
            -- A room the logic doesn't list still gets a context, as the room's own name did when contexts were names
            if ctx.simple(node.name) == nil then
                ctx.number_rooms({ [node.name] = true })
            end
            return { ctx.simple(node.name) }
        else
            -- Unhandled
            error()
        end
    end

    local mask = context_info.mask[incoming]
    if context_type == nil then
        return { incoming }
    elseif context_type == true then
        -- Forgetters forget the room, but isolatability is tied to the room so it isn't shared with other rooms
        if has_ability(mask, ISOLATABILITY) then
            return { incoming }
        end
        local outgoing = {}
        for _, room_contexts in pairs(context_info.of) do
            table.insert(outgoing, room_contexts[mask + 1])
        end
        return outgoing
    elseif type(context_type) == "string" then
        -- Rooms use node.name for the room (type_info names one room for every room node)
        -- Like extended-sort.lua, rooms emit every ability mask no matter what came in
        local room_contexts = context_info.of[node.name]
        if room_contexts == nil then
            error("Room node " .. node.name .. " is not a context")
        end
        local outgoing = {}
        for _, room_mask in pairs(masks) do
            table.insert(outgoing, room_contexts[room_mask + 1])
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
    local mask = ctx.mask(context)
    if mask == nil or not has_ability(mask, ISOLATABILITY) then
        return nil
    end
    local room = ctx.room(context)
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
-- Given watched (a list of node keys), those nodes go in the sets as if they were rooms: each needs itself on top of what satisfied it, so the sets also say which of them a pebble can't be reached without
local function compute_rooms_needed(graph, watched)
    local sort_info = top.sort(graph)

    -- Rooms in a fixed order, then the watched nodes, so that sets of them can be strings
    local rooms = {}
    for room, _ in pairs(logic.contexts) do
        table.insert(rooms, room)
    end
    table.sort(rooms)
    -- The contexts a pebble can have are the rooms' simple contexts
    local contexts = {}
    for _, room in pairs(rooms) do
        table.insert(contexts, ctx.simple(room))
    end
    local watched_keys = {}
    for _, node_key in pairs(watched or {}) do
        table.insert(watched_keys, node_key)
    end
    table.sort(watched_keys)
    for _, node_key in pairs(watched_keys) do
        table.insert(rooms, node_key)
    end
    local room_ind = {}
    for i = 1, #rooms do
        room_ind[rooms[i]] = i
    end
    local is_watched = {}
    for _, node_key in pairs(watched_keys) do
        is_watched[node_key] = true
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
                if is_watched[node_key] then
                    start_set = with_room(start_set, node_key)
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
        for _, context in pairs(contexts) do
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
                    -- Rooms use node.name for the room, see node_transmit
                    new_needed[ctx.simple(node.name)] = with_room(common, node.name)
                end
            end
        end
        if is_watched[node_key] then
            for context, set in pairs(new_needed) do
                new_needed[context] = with_room(set, node_key)
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
        -- The rooms in either set
        union = function(set1, set2)
            return combine("union", set1, set2)
        end,
        -- The set without one room
        without = function(set, room)
            local i = room_ind[room]
            if i == nil or string.sub(set, i, i) ~= "1" then
                return set
            end
            return string.sub(set, 1, i - 1) .. "0" .. string.sub(set, i + 1)
        end,
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
-- Returns a function (node_key, context) --> { room --> true }, which gives nil for a pebble that can't be reached at all (context is a simple context, see top.simple_context)
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

-- For every node a sort without complex contexts reaches, which of the watched nodes (a list of node keys) it can't be reached without in any context (see compute_rooms_needed)
-- Returns a function node_key --> { watched node key --> true }, which gives nil for a node that can't be reached at all
top.watched_needed = function(graph, watched)
    local info = compute_rooms_needed(graph, watched)
    local is_watched = {}
    for _, node_key in pairs(watched) do
        is_watched[node_key] = true
    end
    return function(node_key)
        local common
        for _, set in pairs(info.needed[node_key] or {}) do
            common = info.intersect(common, set)
        end
        if common == nil then
            return nil
        end
        local needed = {}
        for name, _ in pairs(info.decode(common)) do
            if is_watched[name] then
                needed[name] = true
            end
        end
        return needed
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

-- Home sets: a room's home set is the rooms its discoverers (see top.is_discoverer) can't be reached without, like Nauvis and space platforms for Vulcanus, and the rooms the room itself can't be reached without (the route there: the locations on the way, which have to be discovered, and the asteroid defense along it)
-- Those rooms have been used by the time the room is discovered and reached, so with home contexts, a tech that can be had using only them is isolatable there once it's discovered (see discover_home_rooms in top.sort); isolatable contexts there only matter once it's reached
-- The route mostly needs no more than the discovery, but where discoveries follow the star map (randomizations/planetary/discovery.lua), a far planet's route passes planets that need other planets' packs, and isolatability may use the techs gotten by the time the room is reached (lib/logic/builder.lua)
-- Returns { ids = list of home set ids, sets = id --> { rooms = room --> true, discovered = room --> true for the rooms it's the home set of }, of = room --> home set id }
-- Home set ids are the numbers 1, 2, ..., named home1, home2, ... in logs (top.home_name)
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
    -- And what reaching the room needs (its room node's rooms, the room itself aside)
    for room, needs in pairs(needs_of_room) do
        local reach = (info.needed[gutils.key("room", room)] or {})[ctx.simple(room)]
        if reach ~= nil then
            needs_of_room[room] = info.union(needs, info.without(reach, room))
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
        local home_id = i
        table.insert(home_sets.ids, home_id)
        home_sets.sets[home_id] = {
            rooms = info.decode(needs),
            discovered = rooms_with_needs[needs],
        }
        for room, _ in pairs(rooms_with_needs[needs]) do
            home_sets.of[room] = home_id
        end
        log("Home set " .. ctx.home_name(home_id) .. " of " .. table.concat(sorted_keys(rooms_with_needs[needs]), ", ") .. ": " .. table.concat(sorted_keys(home_sets.sets[home_id].rooms), ", "))
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
-- A smaller home set grants less (see discover_home_rooms), so after a change to the game (like a planetary one) that may change which rooms discoveries need, this is the careful choice (notes/old/context-shift-report, the remark on home sets)
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
        local home_id = i
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

-- What a sort reads of home sets, in the order it reads them, so home sets with the same signature give the same sorts (top.same_home_sets also counts other ids and orders as the same)
top.home_sets_signature = function(home_sets)
    local parts = {}
    for _, home_id in pairs(home_sets.ids) do
        table.insert(parts, "id " .. home_id)
        for room, _ in pairs(home_sets.sets[home_id].rooms) do
            table.insert(parts, "room " .. room)
        end
        for room, _ in pairs(home_sets.sets[home_id].discovered or {}) do
            table.insert(parts, "discovered " .. room)
        end
    end
    for room, home_id in pairs(home_sets.of) do
        table.insert(parts, "of " .. room .. " " .. home_id)
    end
    return table.concat(parts, "\n")
end

-- What a sort reads besides its options and home sets, in the order it reads it: the graph's nodes with their op and edges, how it treats their types (logic.type_info), the rooms its discoverers discover (top.discovered_rooms reads data.raw), its edges with their abilities, the rooms (logic.contexts) and this file's switches
-- Graphs with the same fingerprint give the same sorts, so whatever else top.sort comes to read has to go in here too
top.graph_fingerprint = function(graph)
    local parts = {}
    local n = 0
    local types = {}
    for node_key, node in pairs(graph.nodes) do
        n = n + 1
        parts[n] = "n " .. node_key .. " " .. tostring(node.op)
        if types[node.type] == nil then
            types[node.type] = true
            n = n + 1
            parts[n] = "t " .. node.type .. " " .. tostring((logic.type_info[node.type] or {}).context)
        end
        for pre, _ in pairs(node.pre) do
            n = n + 1
            parts[n] = "p " .. pre
        end
        for dep, _ in pairs(node.dep) do
            n = n + 1
            parts[n] = "d " .. dep
        end
        if top.is_discoverer(node) then
            for _, discovered in pairs(top.discovered_rooms(node)) do
                n = n + 1
                parts[n] = "r " .. discovered.location .. " " .. discovered.room
            end
        end
    end
    for edge_key, edge in pairs(graph.edges) do
        n = n + 1
        parts[n] = "e " .. edge_key .. " " .. (edge.abilities ~= nil and tostring(edge.abilities) or "")
    end
    for room, _ in pairs(logic.contexts) do
        n = n + 1
        parts[n] = "c " .. room
    end
    n = n + 1
    parts[n] = "s " .. tostring(top.home_contexts_in_set_rooms) .. " " .. tostring(top.implied_home_contexts)
    return table.concat(parts, "\n")
end

-- A sort bootstrap.prune made of a graph it then left alone (top.offer_reusable_sort): the next from-scratch sort of that graph, still unchanged, with the same options and home sets takes it instead of sorting again
-- It's taken once, so no two callers share one sort's tables
local reusable = nil

top.offer_reusable_sort = function(graph, sort_info, home_sets)
    reusable = {
        graph = graph,
        sort_info = sort_info,
        home_sets = home_sets,
        home_signature = top.home_sets_signature(home_sets),
        fingerprint = top.graph_fingerprint(graph),
    }
end

-- The offered sort, if a from-scratch sort of graph with extra would make the same one, or nil
local function take_reusable_sort(graph, extra)
    local offer = reusable
    if offer.graph ~= graph or extra == nil or extra.complex_contexts ~= true or extra.home_contexts ~= true then
        return nil
    end
    for option, _ in pairs(extra) do
        if option ~= "complex_contexts" and option ~= "home_contexts" and option ~= "home_sets" then
            return nil
        end
    end
    -- Home sets the sort would have to work out itself are left to it
    local home_sets = extra.home_sets or logic.home_sets
    if home_sets == nil or (home_sets ~= offer.home_sets and top.home_sets_signature(home_sets) ~= offer.home_signature) then
        return nil
    end
    reusable = nil
    if top.graph_fingerprint(graph) ~= offer.fingerprint then
        return nil
    end
    -- The same contents, so the caller's own table, as a sort of its own would have
    offer.sort_info.home_sets = home_sets
    return offer.sort_info
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
    if state == nil and reusable ~= nil then
        local taken = take_reusable_sort(graph, extra)
        if taken ~= nil then
            return taken
        end
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
    -- Nodes that got a home context in this sort, whose home contexts standing for others are written out at the end (top.implied_home_contexts)
    local home_touched = {}
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
    -- node_key --> index of the node's earliest pebble, once it has one
    -- New pebbles come after the old ones (and pebbles written out at the end of a sort repeat existing indices), so it doesn't change during a sort once found
    local earliest_inds = {}
    local function heap_add(node_key)
        local earliest = earliest_inds[node_key]
        if earliest == nil then
            for _, ind in pairs(node_to_context_inds[node_key]) do
                if earliest == nil or ind < earliest then
                    earliest = ind
                end
            end
            earliest_inds[node_key] = earliest
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

    -- Whether a node has a context already or about to (in open), counting for a home context those of the home sets inside it in the same room, which stand for it (top.implied_home_contexts)
    local function already_has(node_key, context)
        local inds = node_to_context_inds[node_key]
        if inds[context] ~= nil then
            return true
        end
        local subsets = context_info.home_subsets[context_info.home[context]]
        if subsets == nil or subsets[1] == nil then
            return false
        end
        local room_homes = context_info.home_of[context_info.room[context]]
        local waiting = open[node_key]
        for _, subset_id in pairs(subsets) do
            local subset_context = room_homes[subset_id]
            if subset_context ~= nil and (inds[subset_context] ~= nil or (waiting ~= nil and waiting[subset_context] ~= nil)) then
                return true
            end
        end
        return false
    end

    -- Whether every prerequisite of an AND node sends it context
    -- A context that isn't a home context, through an edge that doesn't change abilities (or any edge, for simple contexts), is read straight from the prerequisite's pebbles, as edge_sends would
    local function all_pres_send(depnode, context)
        local plain = context_info.home[context] == nil
        for pre, _ in pairs(depnode.pre) do
            local edge = graph.edges[pre]
            if plain and (not complex or edge.abilities == nil) then
                if node_to_context_inds[edge.start][context] == nil then
                    return false
                end
            elseif not edge_sends(context_info, node_to_context_inds, edge, context) then
                return false
            end
        end
        return true
    end

    -- Puts what the depnode sends when context arrives at it in open, skipping contexts it already has
    local function add_arrived(depnode, context, depnode_key)
        -- Nodes that aren't rooms or forgetters send complex and home contexts on unchanged (see node_transmit), which needs no list
        if logic.type_info[depnode.type].context == nil and (complex or context_info.home[context] ~= nil) then
            if not already_has(depnode_key, context) then
                add_to_open(depnode, context, depnode_key)
            end
        else
            for _, outgoing in pairs(node_transmit(context_info, depnode, context)) do
                if not already_has(depnode_key, outgoing) then
                    add_to_open(depnode, outgoing, depnode_key)
                end
            end
        end
    end

    -- Checks if this depnode *newly* has context
    -- incoming is the context as it arrives at depnode (after going through the edge)
    -- depnode_key is key(depnode), and edge_key the edge incoming came through, when the caller has them
    -- incoming_sends says edge_key's prerequisite has just got the pebble incoming came from, as in the main loop, so that edge sends incoming
    local function process_depnode(depnode, incoming, depnode_key, edge_key, incoming_sends)
        depnode_key = depnode_key or key(depnode)

        local check
        if depnode.op == "OR" then
            -- OR is false until proven true
            -- Any prereq with a pebble proves it, and the one incoming came through usually has one, so it's tried first
            if edge_key ~= nil and depnode.pre[edge_key] ~= nil and (incoming_sends or edge_sends(context_info, node_to_context_inds, graph.edges[edge_key], incoming)) then
                check = true
            else
                check = false
                for pre, _ in pairs(depnode.pre) do
                    if edge_sends(context_info, node_to_context_inds, graph.edges[pre], incoming) then
                        check = true
                        break
                    end
                end
            end
        elseif depnode.op == "AND" then
            check = all_pres_send(depnode, incoming)
        else
            error("Invalid node op: " .. tostring(depnode.op))
        end

        if check then
            add_arrived(depnode, incoming, depnode_key)
        elseif depnode.op == "AND" then
            -- The prerequisite incoming came from also stands for the home sets containing incoming's, which the others may all send already, though not incoming itself (top.implied_home_contexts)
            -- Those home contexts weren't passed on, so their check is here: the smallest containing home sets the depnode can have, each standing for the ones containing it
            -- They go in open after all of them are checked, since open is part of what already_has reads
            local arrived
            local home_id = context_info.home[incoming]
            if home_id ~= nil then
                local room_homes = context_info.home_of[context_info.room[incoming]]
                local found = {}
                for _, superset_id in pairs(context_info.home_supersets[home_id]) do
                    local superset_context = room_homes[superset_id]
                    local covered = false
                    for _, inner_id in pairs(context_info.home_subsets[superset_id]) do
                        if found[inner_id] ~= nil then
                            covered = true
                            break
                        end
                    end
                    if superset_context ~= nil and not covered then
                        if already_has(depnode_key, superset_context) then
                            found[superset_id] = true
                        elseif all_pres_send(depnode, superset_context) then
                            found[superset_id] = true
                            arrived = arrived or {}
                            table.insert(arrived, superset_context)
                        end
                    end
                end
            end
            if arrived ~= nil then
                for _, context in pairs(arrived) do
                    add_arrived(depnode, context, depnode_key)
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
                            for i, context in pairs(room_contexts) do
                                if has_ability(i - 1, ISOLATABILITY) and node_to_context_inds[node_key][context] == nil then
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
        for i, context in pairs(context_info.of[room]) do
            if has_ability(i - 1, ISOLATABILITY) and node_to_context_inds[tech_key][context] == nil then
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
        -- Home sets that this node got a home context of, with the home sets containing them (top.implied_home_contexts)
        local new_home_ids
        for context, _ in pairs(contexts) do
            local home_id = context_info.home[context]
            -- A home context that one of a home set inside it already stands for isn't passed on (it came in before that one did)
            if home_id == nil or implied_ind(context_info, node_to_context_inds[node_key], context) == nil then
                -- Add this node-context pebble to sorted
                table.insert(sorted, {
                    node_key = node_key,
                    context = context,
                })
                -- Add the context
                node_to_context_inds[node_key][context] = #sorted

                -- Edges without abilities (and every edge, for simple and home contexts) pass the context on unchanged, as edge_transmit would, without making a list for it
                -- An edge that changes abilities sends the masks its table gives, in edge_transmit's order, also without a list
                -- Either way the pebble just recorded is where incoming comes from, so the edge sends it (process_depnode's incoming_sends)
                local passes_unchanged = not complex or home_id ~= nil
                local room_contexts = complex and context_info.of[context_info.room[context]] or nil
                for dep, _ in pairs(node.dep) do
                    local edge = graph.edges[dep]
                    local depnode = graph.nodes[edge.stop]
                    if passes_unchanged or edge.abilities == nil then
                        process_depnode(depnode, context, edge.stop, dep, true)
                    else
                        for _, mask in pairs(FORWARD_MASKS[edge.abilities][context_info.mask[context] + 1]) do
                            process_depnode(depnode, room_contexts[mask + 1], edge.stop, dep, true)
                        end
                    end
                end

                if home_id ~= nil then
                    new_home_ids = new_home_ids or {}
                    new_home_ids[home_id] = true
                    for _, superset_id in pairs(context_info.home_supersets[home_id]) do
                        new_home_ids[superset_id] = true
                    end
                    home_touched[node_key] = true
                end
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

    -- The home contexts that a smaller home set's context stood for, written out with its index, so what reads the sort finds every home context as before (top.implied_home_contexts)
    for node_key, _ in pairs(home_touched) do
        local inds = node_to_context_inds[node_key]
        local implied = {}
        for context, ind in pairs(inds) do
            local home_id = context_info.home[context]
            if home_id ~= nil then
                local room_homes = context_info.home_of[context_info.room[context]]
                for _, superset_id in pairs(context_info.home_supersets[home_id]) do
                    local superset_context = room_homes[superset_id]
                    if superset_context ~= nil and inds[superset_context] == nil and (implied[superset_context] == nil or ind < implied[superset_context]) then
                        implied[superset_context] = ind
                    end
                end
            end
        end
        for context, ind in pairs(implied) do
            inds[context] = ind
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
-- The immediate option returns only the backing of the first goal, without inspecting its parents.
-- extra_params.prefer(pre_ind, curr_ind) picks which prereq an OR node that keeps its context takes: a preferred one goes before the earliest, and may even come after the OR node's own pebble as long as it's before extra_params.prefer_before (default: the OR node's pebble)
-- A later prereq can lead back to the OR node, so with prefer the result also has chosen (ind --> the inds it went on to), for checking that the path is still a derivation (see lib/logic/witness-recipes.lua), and preferred (OR pebble --> the preferred prereq it took over an earlier one)
top.path = function(graph, goal_inds, sort_info, extra_params)
    local sorted = sort_info.sorted
    local node_to_context_inds = sort_info.node_to_context_inds
    extra_params = extra_params or {}
    local context_info
    if extra_params.immediate == true then
        -- Operation layers request many direct backings of the same immutable sort.
        sort_info.immediate_context_info = sort_info.immediate_context_info or build_context_info(sort_info.complex == true, sort_info.home_sets)
        context_info = sort_info.immediate_context_info
    else
        context_info = build_context_info(sort_info.complex == true, sort_info.home_sets)
    end
    local stop_if = extra_params.stop_if or function(pebble) return false end
    local prefer = extra_params.prefer
    local chosen
    local preferred
    if prefer ~= nil then
        chosen = {}
        preferred = {}
    end
    -- Only needed for the discovery rule, so found when first used
    local room_discoverers = extra_params.immediate == true and sort_info.immediate_room_discoverers or nil

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
                -- Only nodes that keep their context: a forgetting node's prereqs are compared across contexts below
                local can_prefer = prefer ~= nil and logic.type_info[node.type].context == nil
                local prefer_before = extra_params.prefer_before or curr_ind
                local preferred_ind
                for pre, _ in pairs(node.pre) do
                    -- Need to check that context is non-nil since OR nodes can depend on later things/with different contexts
                    local pre_ind = edge_ind(context_info, node_to_context_inds, graph.edges[pre], context)
                    if pre_ind ~= nil and pre_ind < first_occurrence_ind then
                        first_occurrence_ind = pre_ind
                    end
                    if can_prefer and pre_ind ~= nil and pre_ind < prefer_before and (preferred_ind == nil or pre_ind < preferred_ind) and prefer(pre_ind, curr_ind) then
                        preferred_ind = pre_ind
                    end
                end
                -- Make sure we found something/didn't loop
                if first_occurrence_ind == curr_ind then
                    return false
                end
                if preferred_ind ~= nil and preferred_ind ~= first_occurrence_ind then
                    preferred[curr_ind] = preferred_ind
                    table.insert(preinds, preferred_ind)
                else
                    table.insert(preinds, first_occurrence_ind)
                end
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
            -- Test membership directly: constructing every outgoing context here repeats the room expansion for every candidate of every witness.
            local context_type = logic.type_info[curr_node.type].context
            local home = context_info.home[incoming]
            if home ~= context_info.home[curr_context] then
                return false
            end
            if context_type == true then
                if home ~= nil then
                    return true
                end
                local mask = context_info.mask[incoming]
                if has_ability(mask, ISOLATABILITY) then
                    return incoming == curr_context
                end
                return mask == context_info.mask[curr_context]
            elseif type(context_type) == "string" then
                return context_info.room[curr_context] == curr_node.name
                    and (home == nil or context_info.home_rooms[home][curr_node.name] ~= nil)
            end
            return incoming == curr_context
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
                if extra_params.immediate == true then
                    -- Direct backings share the same immutable graph, so discovery queries share its graph-wide lookup too.
                    sort_info.immediate_room_discoverers = room_discoverers
                end
                discovery_preinds = find_discovery_preinds(sort_info, room_discoverers, curr_node, outgoing_context, curr_ind)
            end
            -- If nothing was earlier, that's a contradiction
            if earliest_context_ind == curr_ind and discovery_preinds == nil then
                log(serpent.block(curr_node))
                log(ctx.name(outgoing_context))
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
            if chosen ~= nil then
                chosen[curr_ind] = preinds
            end
            for _, ind in pairs(preinds) do
                if not in_path[ind] then
                    in_path[ind] = true
                    table.insert(path, ind)
                end
            end
        end

        if extra_params.immediate == true then
            break
        end
        path_ind = path_ind + 1
    end

    return {
        path = path,
        in_path = in_path,
        chosen = chosen,
        preferred = preferred,
    }
end

-- Trims unnecessary contexts out of state's sorted list, starting from the back
-- Might not be necessary with top.path now
top.trim = function(graph, state)
    -- TODO
end

return top
