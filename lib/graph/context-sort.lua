-- A copy of consistent-sort.lua that can optionally also track the ability contexts (isolatability/automatability) from extended-sort.lua
-- Kept as close to consistent-sort.lua as possible so that callers can be ported over by just swapping the require
-- Differences from consistent-sort.lua:
--   1. Pass extra.complex_contexts = true to make each context a room/ability string pair rather than just a room
--      These are encoded as a single string (see top.context_key) so the rest of the sort treats them just like rooms
--   2. Contexts are now also transmitted through edges, since edges can add/remove abilities (edge.abilities)
--   3. Random selection from open is O(1) using a list of open keys, rather than rebuilding that list every step
-- Without complex contexts, this should behave exactly like consistent-sort.lua except for which random node is picked
-- I kept the pebble terminology: a *pebble* is a node_key/context pair

local contutils = require("lib/graph/context-utils")
local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local rng = require("lib/random/rng")
-- Used for contexts and such; actual logic dependency graph is passed in
local logic = require("lib/logic/init")

-- Shortcuts
local key = gutils.key

-- Ability indices, matching edge.abilities (see lib/logic/builder.lua)
local ISOLATABILITY = 1
local AUTOMATABILITY = 2
local NUM_ABILITIES = 2
-- Can't appear in room keys
local CONTEXT_SEPARATOR = " | "

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

top.context_room = function(context)
    local i = string.find(context, CONTEXT_SEPARATOR, 1, true)
    if i == nil then
        return context
    end
    return string.sub(context, 1, i - 1)
end

-- Returns nil for simple contexts
top.context_abilities = function(context)
    local _, j = string.find(context, CONTEXT_SEPARATOR, 1, true)
    if j == nil then
        return nil
    end
    return string.sub(context, j + 1, -1)
end

-- Gets the lookup tables for the contexts used in a sort
-- For simple contexts, the contexts are just the rooms, exactly as in consistent-sort.lua
local function build_context_info(complex)
    local context_info = {
        complex = complex,
        -- Every context
        list = {},
        -- The following are only for complex contexts
        -- context --> room
        room = {},
        -- context --> ability string
        abilities = {},
        -- room --> ability string --> context
        of = {},
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
local function edge_transmit(context_info, edge, context)
    if not context_info.complex or edge.abilities == nil then
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
    if not context_info.complex or edge.abilities == nil then
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
    if not context_info.complex or edge.abilities == nil then
        return start_inds[context]
    end
    local earliest_ind
    for _, source in pairs(edge_sources(context_info, edge, context)) do
        local ind = start_inds[source]
        if ind ~= nil and (earliest_ind == nil or ind < earliest_ind) then
            earliest_ind = ind
        end
    end
    return earliest_ind
end

-- Contexts leaving node when incoming arrives at it
-- For simple contexts this is just contutils.transmit
-- For complex contexts this follows extended-sort.lua's transmit_through_node
local function node_transmit(context_info, node, incoming)
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
-- Nodes that discover rooms for the isolatability discovery rule (see discover_space_locations in top.sort)
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
    local tech_prot = data.raw.technology[tech_node.name]
    if tech_prot == nil or tech_prot.effects == nil then
        return rooms
    end
    for _, effect in pairs(tech_prot.effects) do
        if effect.type == "unlock-space-location" then
            local loc_prot = dutils.get_prot("space-location", effect.space_location)
            table.insert(rooms, {
                location = effect.space_location,
                room = key(loc_prot.type, loc_prot.name),
            })
        end
    end
    return rooms
end

-- Transmission rules for callers that reason about backings (like promotion), so the rules live only in this file
local context_info_cache = {}
local function cached_context_info(complex)
    if context_info_cache[complex] == nil then
        context_info_cache[complex] = build_context_info(complex)
    end
    return context_info_cache[complex]
end

-- Contexts leaving edge.start that would make context arrive at edge.stop, for a sort made by top.sort
top.edge_source_contexts = function(sort_info, edge, context)
    return edge_sources(cached_context_info(sort_info.complex == true), edge, context)
end

-- Contexts leaving node when incoming arrives at it, for a sort made by top.sort
top.node_transmit = function(sort_info, node, incoming)
    return node_transmit(cached_context_info(sort_info.complex == true), node, incoming)
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
    local context_info = build_context_info(complex)
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
    -- Don't choose randomly for backwards compatibility with Frodo version
    if not DO_FRODO_FIXES and extra.choose_randomly == false then
        extra.choose_randomly = true
    end

    -- Initialize node_to_context_inds on *all* nodes, etc.
    -- Only do this on new sorts
    -- We'll actually populate initial "open" list later
    if new_conn == nil then
        for node_key, _ in pairs(graph.nodes) do
            node_to_context_inds[node_key] = {}
        end
    end

    local function add_to_open(node, context)
        local node_key = key(node)
        if open[node_key] == nil then
            open[node_key] = {}
            table.insert(open_list, node_key)
            open_pos[node_key] = #open_list
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
    local function process_depnode(depnode, incoming)
        local depnode_key = key(depnode)

        local check
        if depnode.op == "OR" then
            -- OR is false until proven true
            check = false
        elseif depnode.op == "AND" then
            -- AND is true until proven false
            check = true
        else
            error("Invalid node op: " .. tostring(depnode.op))
        end
        for pre, _ in pairs(depnode.pre) do
            local edge = graph.edges[pre]
            if (edge_ind(context_info, node_to_context_inds, edge, incoming) ~= nil) == (not check) then
                check = not check
                break
            end
        end

        if check then
            local outgoing_contexts = node_transmit(context_info, depnode, incoming)
            for _, outgoing in pairs(outgoing_contexts) do
                -- Skip contexts the depnode is already transmitting
                if node_to_context_inds[depnode_key][outgoing] == nil then
                    add_to_open(depnode, outgoing)
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
        else
            local curr_priority
            for candidate_node_key, contexts in pairs(open) do
                local node_priority
                for _, ind in pairs(node_to_context_inds[candidate_node_key]) do
                    if node_priority == nil or ind < node_priority then
                        node_priority = ind
                    end
                end
                if curr_priority == nil or (node_priority ~= nil and node_priority < curr_priority) then
                    node_key = candidate_node_key
                    curr_priority = node_priority
                end
            end
        end

        local contexts = open[node_key]
        remove_from_open(node_key)
        -- Transmit contexts to each dependent
        local node = graph.nodes[node_key]
        for context, _ in pairs(contexts) do
            -- Add this node-context pebble to sorted
            table.insert(sorted, {
                node_key = node_key,
                context = context,
            })
            -- Add the context
            node_to_context_inds[node_key][context] = #sorted

            for dep, _ in pairs(node.dep) do
                local edge = graph.edges[dep]
                local depnode = graph.nodes[edge.stop]
                for _, arriving in pairs(edge_transmit(context_info, edge, context)) do
                    process_depnode(depnode, arriving)
                end
            end
        end

        if complex and top.is_discoverer(node) then
            discover_space_locations(node)
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
    }
end

-- For a tech pebble in an isolatable context on a space location that it could have gotten by discovery: the earliest earlier pebble of the tech itself and of a tech unlocking that location, or nil
local function find_discovery_preinds(graph, node_to_context_inds, tech_node, context, curr_ind)
    local abilities = top.context_abilities(context)
    if abilities == nil or not has_ability(abilities, ISOLATABILITY) then
        return nil
    end
    local room = top.context_room(context)
    local own_ind
    for _, ind in pairs(node_to_context_inds[key(tech_node)]) do
        if ind < curr_ind and (own_ind == nil or ind < own_ind) then
            own_ind = ind
        end
    end
    if own_ind == nil then
        return nil
    end
    local discoverer_ind
    for node_key, node in pairs(graph.nodes) do
        if top.is_discoverer(node) then
            for _, discovered in pairs(top.discovered_rooms(node)) do
                if discovered.room == room then
                    for _, ind in pairs(node_to_context_inds[node_key]) do
                        if ind < curr_ind and (discoverer_ind == nil or ind < discoverer_ind) then
                            discoverer_ind = ind
                        end
                    end
                end
            end
        end
    end
    if discoverer_ind == nil then
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
    local context_info = build_context_info(sort_info.complex == true)
    extra_params = extra_params or {}
    local stop_if = extra_params.stop_if or function(pebble) return false end

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
            -- Isolatable contexts of techs can also come from discovering their space location (see discover_space_locations in top.sort)
            -- Then the path goes through the tech itself in an earlier context and an earlier pebble of a tech that unlocks the location
            if earliest_context_ind == curr_ind and context_info.complex and curr_node.type == "technology" then
                discovery_preinds = find_discovery_preinds(graph, node_to_context_inds, curr_node, outgoing_context, curr_ind)
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
