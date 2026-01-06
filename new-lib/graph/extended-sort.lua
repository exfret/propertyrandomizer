-- A lot is copy-pasted from top-sort.lua
-- CRITICAL TODO: To make development easier, I did a full population of the contexts with room keys
-- However, this could severely slow things down; fix this in the future!
-- CRITICAL TODO: Remove hardcoded number of abilities
local NUM_ABILITIES = 2

local lib_name = "new-lib" -- Use this until integration with "old" lib
local gutils = require(lib_name .. "/graph/graph-utils")
-- Used for gathering contexts, etc. not for the actual graph
local logic = require(lib_name .. "/logic/logic")
local dutils = require(lib_name .. "/data-utils")

-- Commonly used function
local key = gutils.key

local top = {}

-- TODO: Move these utilities to logic-utils or elsewhere
local all_bin_strs = {}
local function find_all_bin_strs(length)
    if length == 0 then
        all_bin_strs = {[""] = true}
        return
    end

    find_all_bin_strs(length - 1)
    local previous_length_bin_strs = all_bin_strs
    all_bin_strs = {}
    for _, char in pairs({"0", "1"}) do
        for bin_str, _ in pairs(previous_length_bin_strs) do
            all_bin_strs[char .. bin_str] = true
        end
    end
end
-- Currently just isolatability and automatability
-- TODO: Make this not hardcoded
find_all_bin_strs(NUM_ABILITIES)
top.all_strs = all_bin_strs

local all_ones = ""
for i = 1, NUM_ABILITIES do
    all_ones = all_ones .. "1"
end

local function bin_str_lt(bin_str1, bin_str2)
    if bin_str1 == bin_str2 then
        return false
    end

    if #bin_str1 ~= #bin_str2 then
        error("Binary context strings not of same length.")
    end

    local function char_lt(char1, char2)
        if char1 == "0" and char2 == "1" then
            return true
        end

        return false
    end

    for i = 1, #bin_str1 do
        if char_lt(string.sub(bin_str2, i, i), string.sub(bin_str1, i, i)) then
            return false
        end
    end

    return true
end

local up_cone = {}
local down_cone = {}
for bin_str, _ in pairs(all_bin_strs) do
    up_cone[bin_str] = {[bin_str] = true}
    down_cone[bin_str] = {[bin_str] = true}
    for other_bin_str, _ in pairs(all_bin_strs) do
        if bin_str_lt(bin_str, other_bin_str) then
            up_cone[bin_str][other_bin_str] = true
        elseif bin_str_lt(other_bin_str, bin_str) then
            down_cone[bin_str][other_bin_str] = true
        end
    end
end

-- Returns union, difference, for just one room's context
-- No longer handles 'true' sentinel - always explicit dicts
local function room_merge(rbase, raddon)
    local union = table.deepcopy(rbase)
    local difference = {}
    for bin_str, _ in pairs(raddon) do
        if not rbase[bin_str] then
            union[bin_str] = true
            difference[bin_str] = true
        end
    end
    return {union = union, difference = difference}
end

-- Returns union, difference
-- No longer handles 'true' sentinel - always explicit dicts
local function merge(base, addon)
    local union = {}
    local difference = {}
    for room, _ in pairs(logic.contexts) do
        local rbase = base[room]
        local raddon = addon[room]
        local room_merge_info = room_merge(rbase, raddon)
        union[room] = room_merge_info.union
        difference[room] = room_merge_info.difference
    end
    return {union = union, difference = difference}
end

-- We shouldn't need context_reachable

local function transmit_through_node(node, incoming_context)
    local context_info = logic.type_info[node.type].context

    if context_info == nil then
        -- Context simply transmitted; majority of cases
        return table.deepcopy(incoming_context)
    elseif context_info == true then
        -- Case of forgetter
        -- There are two current cases: item-launch and technology
        -- technology should be a source for automatability, but not necessarily item-launch
        -- However, we already add automatability to technology incoming-prerequisite edges, so it's enough to make this only forget over room contexts
        -- No longer handles 'true' sentinel - always explicit dicts
        local rcombined_context = {}
        for room, _ in pairs(logic.contexts) do
            -- Filter out isolatability (that's not shared)
            local incoming_context_to_combine = {}
            for bin_str, _ in pairs(incoming_context[room]) do
                if string.sub(bin_str, 1, 1) == "0" then
                    incoming_context_to_combine[bin_str] = true
                end
            end
            rcombined_context = room_merge(rcombined_context, incoming_context_to_combine).union
        end
        local outgoing_context = {}
        for room, _ in pairs(logic.contexts) do
            -- Need to merge in case incoming_context had isolatability for that one room
            outgoing_context[room] = room_merge(table.deepcopy(rcombined_context), incoming_context[room]).union
        end
        return outgoing_context
    elseif type(context_info) == "string" then
        -- Case of emitter of single context
        -- Since context_info is per-type, and room context transmission is per node name, we need to use the node.name for the specific context transmitted
        -- Rooms only guarantee isolatability, not automatability
        local outgoing_context = {}
        for room, _ in pairs(logic.contexts) do
            if room == node.name then
                outgoing_context[room] = { ["00"] = true, ["10"] = true, ["01"] = true, ["11"] = true }
            else
                outgoing_context[room] = {}
            end
        end
        return outgoing_context
    end
end

local function transmit_through_edge(edge, incoming_context)
    if edge.abilities == nil then
        return table.deepcopy(incoming_context)
    end

    -- No longer handles 'true' sentinel - always explicit dicts
    local outgoing_context = table.deepcopy(incoming_context)
    for ability, new_val in pairs(edge.abilities) do
        if new_val == true then
            -- Granting ability: for each bin_str, also add version with ability bit = 1
            for room, _ in pairs(logic.contexts) do
                local bin_str_to_add = {}
                for bin_str, _ in pairs(outgoing_context[room]) do
                    local new_bin_str = ""
                    for i = 1, NUM_ABILITIES do
                        if i == ability then
                            new_bin_str = new_bin_str .. "1"
                        else
                            new_bin_str = new_bin_str .. string.sub(bin_str, i, i)
                        end
                    end
                    table.insert(bin_str_to_add, new_bin_str)
                end
                for _, bin_str in pairs(bin_str_to_add) do
                    outgoing_context[room][bin_str] = true
                end
            end
        elseif new_val == false then
            -- Removing ability: remove bin_strs with ability bit = 1
            for room, _ in pairs(logic.contexts) do
                local bin_str_to_remove = {}
                for bin_str, _ in pairs(outgoing_context[room]) do
                    if string.sub(bin_str, ability, ability) == "1" then
                        table.insert(bin_str_to_remove, bin_str)
                    end
                end
                for _, bin_str in pairs(bin_str_to_remove) do
                    outgoing_context[room][bin_str] = nil
                end
            end
        end
    end

    return outgoing_context
end

local function transmit_dep(graph, dep, start_context)
    local edge = graph.edges[dep]
    local end_node = graph.nodes[edge.stop]

    local midway_context = transmit_through_edge(edge, start_context)
    return transmit_through_node(end_node, midway_context)
end

top.sort = function(graph, state, new_conn, extra)
    state = state or {}
    -- node_to_contexts is now the OUTGOING contexts
    -- Beware, it was the INCOMING in previous versions!
    local node_to_contexts = state.node_to_contexts or {}
    -- node_context_to_amount currently doesn't have "all" keys, which were previously for optimization, but too complex for me to implement yet
    -- CRITICAL TODO: Add back these "all" keys when I get the time!
    local node_context_to_amount = state.node_context_to_amount or {}
    local open = state.open or {}
    local in_open = state.in_open or {}
    local ind = state.ind or 1

    -- Initialize maps
    -- Only do this step on an initial sort
    if new_conn == nil then
        local blank_context = {}
        for room, _ in pairs(logic.contexts) do
            blank_context[room] = {}
        end
        for node_key, node in pairs(graph.nodes) do
            node_to_contexts[node_key] = {}
            node_context_to_amount[node_key] = {}
            for room, _ in pairs(logic.contexts) do
                node_to_contexts[node_key][room] = {}
                node_context_to_amount[node_key][room] = {}
                for bin_str, _ in pairs(all_bin_strs) do
                    node_context_to_amount[node_key][room][bin_str] = 0
                end
            end
        end
    end

    -- For special space location unlock handling
    local discovered_space_locations = {}
    -- Add an open_info entry with node as the source and contexts as the NEW contexts
    local function add_to_open(node, contexts)
        local node_key = key(node)
        if node.op == "OR" then
            local in_open_ind = in_open[node_key]
            if in_open_ind ~= nil then
                -- In this case, just add to the already existing entry in open
                local open_info = open[in_open_ind]
                local merge_info = merge(open_info.contexts, contexts)
                open_info.contexts = merge_info.union
            else
                table.insert(open, {
                    node = node_key,
                    contexts = contexts,
                })
                in_open[node_key] = #open
            end
        elseif node.op == "AND" then
            -- AND nodes need to have separate entries, on the other hand
            table.insert(open, {
                node = node_key,
                contexts = contexts,
            })
        else
            error("Unexpected op " .. node.op)
        end

        -- Special handling: If this is a planet discovery tech, consider every previous technology from the sort isolatable for that planet
        -- We do this after adding this current node to handling so that the discover tech is also considered
        -- CRITICAL TODO: Also consider space surfaces gotten through create-space-surface or whatever it is nodes
        if node.type == "technology" then
            local tech_prot = data.raw.technology[node.name]
            if tech_prot.effects ~= nil then
                for _, effect in pairs(tech_prot.effects) do
                    local loc = effect.space_location
                    if effect.type == "unlock-space-location" and not discovered_space_locations[loc] then
                        discovered_space_locations[loc] = true
                        local old_open_size = #open
                        for open_ind, prev_info in pairs(open) do
                            -- Break if we go past where we were before
                            if open_ind > old_open_size then
                                break
                            end
                            local prev_node = graph.nodes[prev_info.node]
                            if prev_node.type == "technology" then
                                local loc_prot = dutils.get_prot("space-location", loc)
                                local loc_key = key(loc_prot.type, loc_prot.name)
                                -- Techs should transmit everything except isolatability right now, so we can just do every bin_str with isolatability true
                                -- CRITICAL TODO: Document this somewhere central in case that changes
                                local planetary_context = {}
                                for room, _ in pairs(logic.contexts) do
                                    if room == loc_key then
                                        planetary_context[room] = {}
                                        for bin_str, _ in pairs(all_bin_strs) do
                                            if string.sub(bin_str, 1, 1) == "1" then
                                                planetary_context[room][bin_str] = true
                                            end
                                        end
                                    else
                                        planetary_context[room] = {}
                                    end
                                end
                                add_to_open(prev_node, planetary_context)
                            end
                        end
                    end
                end
            end
        end
    end

    local function has_new_context(difference_context)
        -- No longer handles 'true' sentinel - always explicit dicts
        for room, _ in pairs(logic.contexts) do
            if next(difference_context[room]) ~= nil then
                return true
            end
        end
        return false
    end

    local function process_dep(dep, new_contexts, old_contexts)
        local end_node_key = graph.edges[dep].stop
        local end_node = graph.nodes[end_node_key]
        local outgoing = transmit_dep(graph, dep, new_contexts)
        local merge_info = merge(node_to_contexts[end_node_key], outgoing)
        -- Only proceed if we could potentially add at least one new context
        if has_new_context(merge_info.difference) then
            -- For OR nodes, that's all we need to check, the context is always transmitted with just this one sender
            if end_node.op == "OR" then
                add_to_open(end_node, merge_info.difference)
            elseif end_node.op == "AND" then
                -- For AND nodes, we need to go through and check if any context actually passes through the node
                -- outgoing is NEW outgoing, so we add up all the contexts added to node_context_to_amount
                local old_incoming = transmit_through_edge(graph.edges[dep], old_contexts)
                local new_incoming = transmit_through_edge(graph.edges[dep], new_contexts)
                -- Because of stuff with edge context changes, old_incoming and new_incoming could overlap despite old_contexts and new_contexts not overlapping, so check
                -- It's enough to shave the base old_incoming stuff from new_incoming
                -- No longer handles 'true' sentinel - difference is always explicit dict
                local difference = merge(old_incoming, new_incoming).difference

                -- Add new contexts and check satisfaction
                local newly_satisfied = {}
                for room, _ in pairs(logic.contexts) do
                    newly_satisfied[room] = {}
                    for bin_str, _ in pairs(difference[room]) do
                        node_context_to_amount[end_node_key][room][bin_str] = node_context_to_amount[end_node_key][room][bin_str] + 1
                        if node_context_to_amount[end_node_key][room][bin_str] == end_node.num_pre then
                            newly_satisfied[room][bin_str] = true
                        end
                    end
                end

                -- Double check that we actually end up transmitting a new thing afterward
                local accurate_outgoing = transmit_through_node(end_node, newly_satisfied)
                local accurate_merge_info = merge(node_to_contexts[end_node_key], accurate_outgoing)
                if has_new_context(accurate_merge_info.difference) then
                    add_to_open(end_node, accurate_merge_info.difference)
                end
            else
                error("Unexpected op " .. end_node.op)
            end
        end
    end

    if new_conn == nil then
        local all_contexts_context = {}
        for room, _ in pairs(logic.contexts) do
            all_contexts_context[room] = {}
            for bin_str, _ in pairs(all_bin_strs) do
                all_contexts_context[room][bin_str] = true
            end
        end
        for node_key, node in pairs(graph.nodes) do
            if node.op == "AND" and node.num_pre == 0 then
                add_to_open(node, table.deepcopy(all_contexts_context))
            end
        end
    else
        -- new_conn is just the edge key now, everything else can be gathered here
        -- The third parameter should always just be empty contexts when it's passed here
        process_dep(new_conn, node_to_contexts[graph.edges[new_conn].start], node_to_contexts[graph.edges[new_conn].stop])
    end

    while ind <= #open do
        local open_info = open[ind]
        local node_key = open_info.node
        --log("Processing " .. node_key)
        --log("With contexts " .. serpent.block(open_info.contexts))
        local node = graph.nodes[node_key]
        local old_contexts = table.deepcopy(node_to_contexts[node_key])
        local new_contexts = open_info.contexts
        in_open[node_key] = nil
        node_to_contexts[node_key] = merge(old_contexts, new_contexts).union
        
        for dep, _ in pairs(node.dep) do
            process_dep(dep, new_contexts, old_contexts)
        end

        ind = ind + 1
    end

    return {
        node_to_contexts = node_to_contexts,
        node_context_to_amount = node_context_to_amount,
        open = open,
        in_open = in_open,
        ind = ind,
    }
end

return top