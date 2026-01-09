-- Next steps:
--   * Finish tests on prereq pools
--   * Integration with main execute loop and tests
-- Note: If this doesn't work, I'll have to revert to a dynamic context re-evaluation loop
--   If that doesn't work either, I may have to live with a prereq shuffle, with side-integrations for item/entity rando
--   That would be really sad, but not the end of the world

-- The following musings are outdated
--   This file currently does an extremely basic proposed sort order through the graph with randomized edges removed
--   There is some "prereq management" via not adding a dependent if there are not enough prereqs for it according to some heuristic
--   Other than that, it will be quite minimal until it is tested with the second pass algorithm
--   It simply returns a map from nodes to arrays, with each position in the array corresponding to a context, and for each node that position being the first time the context was reached
--   Actually... that means I need to simulate a whole top sort here, not just order the dependents, right? Because I need at which points things got context, not just the order of first unlock

local rng = require("lib/random/rng")
local logic = require("new-lib/logic/init")
local gutils = require("new-lib/graph/graph-utils")
-- We use the extended contexts version here
--local top = require("new-lib/graph/extended-sort")
-- Actually let's do that later
local top = require("new-lib/graph/top-sort")

local first_pass = {}

local function head_to_vanilla_base(graph, head)
    -- Just remove the "-head" suffix
    return graph.nodes[gutils.key(head.type, string.sub(head.name, 1, -6))]
end

-- Later will probably need prereqs passed for pool management
first_pass.shuffle = function(graph, short_path, base_deps, head_deps, dep_to_travs, head_to_trav, base_to_slot, trav_to_handler)
    -- Permutation to attempt on deps_sorted
    local perm = {}
    for i = 1, #base_deps do
        table.insert(perm, i)
    end
    rng.shuffle(rng.key({id = "unified"}), perm)



    -- CRITICAL TODO: Remove this when done with it
    -- Put nauvis at end of order so we get new planets maybe
    --[=[local nauvis_indices = {}
    for ind, dep in pairs(head_deps) do
        if dep.type == "traveler" and (string.find(gutils.get_conn_owner(graph, dep).name, "nauvis") ~= nil or string.find(gutils.get_conn_owner(graph, dep).name, "space") ~= nil) then
            nauvis_indices[ind] = true
        end
    end
    local new_perm = {}
    for i, j in pairs(perm) do
        if not nauvis_indices[j] then
            table.insert(new_perm, j)
        end
    end
    -- Or just remove nuvis altogether
    --[[for ind, _ in pairs(nauvis_indices) do
        table.insert(new_perm, ind)
    end]]
    perm = new_perm]=]



    local old_graph = table.deepcopy(graph)
    local pass_sort = top.sort(graph)
    --log(serpent.block(pass_sort.open))

    local function base_reachable(base)
        -- Again, just check for any context
        local base_contexts = pass_sort.node_to_contexts[gutils.key(base)]
        if base_contexts == nil then
            return false
        end
        if base_contexts == true or next(base_contexts) ~= nil then
            return true
        end
        return false
    end

    local function head_vanilla_reachable(head)
        -- Note: the incoming edges to a base are different from those incoming to a head
        -- Wait, base already is an AND over the previous travelers, so we can just check if it has a context
        local vanilla_base = head_to_vanilla_base(graph, head)
        if base_reachable(vanilla_base) then
            return true
        end
        return false
    end

    local function head_absolute_reachable(head)
        for context, _ in pairs(logic.contexts) do
            local has_context = true
            for pre, _ in pairs(head.pre) do
                local prenode = graph.nodes[graph.edges[pre].start]
                -- Check that this isn't the connection we're trying to assign
                if gutils.key(prenode) ~= gutils.key(head_to_trav[gutils.key(head)]) then
                    local prenode_contexts = pass_sort.node_to_contexts[gutils.key(prenode)]
                    if prenode_contexts == nil or (prenode_contexts ~= true and prenode_contexts[context] ~= true) then
                        has_context = false
                        break
                    end
                end
            end
            if has_context then
                return true
            end
        end
        return false
    end

    local is_reserved_base = {}
    local reserved_bases = {}
    local base_to_head = {}
    local head_to_base = {}
    -- Bases never get cancelled, so we only need to keep track of this one thing
    local base_unlock_order = {}

    local function connect_head(base, head)
        local new_edge = gutils.add_edge(graph, gutils.key(base_to_slot[gutils.key(base)]), gutils.key(head_to_trav[gutils.key(head)]), trav_to_handler)
        local all_contexts = {}
        for context, _ in pairs(logic.contexts) do
            all_contexts[context] = true
        end
        pass_sort = top.sort(graph, pass_sort, {
            edge = gutils.ekey(new_edge),
            -- CRITICAL TODO: Make sure this accounts for edge context changes later (in general our subdivisions need to get fixed for that)
            -- Currently none of my randomizations occur at context change edges though so I can ignore this for now
            -- CRITICAL TODO: I turned off HAVING to have slot reachable but... is that the right way? Now I have to make this true
            contexts = pass_sort.node_to_contexts[gutils.key(base)],
        })
    end

    local function fulfill_reservation(base, head)
        local ind_to_remove
        for res_ind, res_base in pairs(reserved_bases) do
            if gutils.key(res_base) == gutils.key(base) then
                ind_to_remove = res_ind
            end
        end
        table.remove(reserved_bases, ind_to_remove)
        connect_head(base, head)
        log("\n\nFULFILLED:\n" .. gutils.key(base) .. " INTO " .. gutils.key(head) .. "\n")
    end

    local function update_reservations()
        -- Fulfill reservations until no more are getting fulfilled
        while true do
            local fulfilled_reservation = false
            local bases_to_remove = {}
            for res_base_key, _ in pairs(is_reserved_base) do
                local res_base = graph.nodes[res_base_key]
                local res_head = base_to_head[res_base_key]
                if head_vanilla_reachable(res_head) then
                    fulfilled_reservation = true
                    fulfill_reservation(res_base, res_head)
                    bases_to_remove[res_base_key] = true
                end
            end
            for res_base_key, _ in pairs(bases_to_remove) do
                is_reserved_base[res_base_key] = nil
            end
            if not fulfilled_reservation then
                break
            end
        end
    end

    local function is_compatible(base, head)
        if head.type == base.type then
            if head.type == "traveler" then
                if trav_to_handler[gutils.key(head.type, string.sub(head.name, 1, -6))].id == trav_to_handler[gutils.key(base)].id then
                    return true
                end
            else
                return true
            end
        end
        return false
    end

    for i = 1, #base_deps do
        local old_base
        local new_head

        -- Reservation cancellation loop
        -- TODO: Just for safety, add a max iteration in constants.lua for this
        local iterations = 1
        while true do
            if iterations % 100 == 0 then
                log(tostring(iterations))
            end
            if iterations >= 10000 then
                break
            end
            iterations = iterations + 1
            for _, base in pairs(base_deps) do
                base = graph.nodes[gutils.key(base)]
                if base_to_head[gutils.key(base)] == nil and base_reachable(base) then
                    for perm_ind, head_ind in pairs(perm) do
                        local head = head_deps[head_ind]
                        head = graph.nodes[gutils.key(head)]

                        if head_to_base[gutils.key(head)] == nil and head_absolute_reachable(head) then
                            -- Test if prereq pools are agreeable according to vanilla pools; filter valid prereqs
                            local valid_matching

                            -- Just treat each traveler of dep like it needs the same prereqs
                            local example_traveler = dep_to_travs[gutils.key(head_to_vanilla_base(graph, head))][1]
                            local trav_owner = gutils.get_conn_owner(graph, graph.nodes[gutils.key(example_traveler)])
                            -- The number of prereqs needed is actually on base, since that has the randomized edges
                            -- trav is needed to check for validity conditions, which we skip over right now
                            -- CRITICAL TODO: Better validation check
                            
                            --[[local num_prereqs_needed = #dep_to_travs[gutils.key(base)]
                            local num_prereqs_found = 0
                            for _, prereq_slot in pairs(base_to_pool[gutils.key(base)]) do
                                local prereq = gutils.get_conn_owner(graph, graph.nodes[gutils.key(prereq_slot)])

                                -- CRITICAL TODO: Write proper validate function as well

                                -- For now check if types are the same
                                if prereq.type == trav_owner.type then
                                    num_prereqs_found = num_prereqs_found + 1
                                end
                            end
                            if num_prereqs_found >= num_prereqs_needed then
                                valid_matching = true
                            end]]

                            -- No ability to make atm
                            -- CRITICAL TODO: Rework
                            if is_compatible(base, head) then
                                -- TODO: Permanent reservations (right now results aren't randomized, so recipes basically all do something, making them pointless to implement now)
                                -- Test if this is a reservation
                                if not head_vanilla_reachable(head) then
                                    is_reserved_base[gutils.key(base)] = true
                                    table.insert(reserved_bases, base)
                                end
                                old_base = base
                                new_head = head
                            end
                        end
                        if new_head ~= nil then
                            break
                        end
                    end
                end
                if new_head ~= nil then
                    break
                end
            end
            if new_head ~= nil then
                break
            else
                -- Try nodes on critical path AND vanilla reachable, then just vanilla reachable
                -- TODO: Consider third pass with arbitrary travelers
                -- TODO: Should I iterate over reservations then heads?
                local found_cancellation = false
                for priority_level = 1, 3 do
                    for perm_ind, head_ind in pairs(perm) do
                        local head = head_deps[head_ind]
                        if head_to_base[gutils.key(head)] == nil and head_absolute_reachable(head) then
                            if (priority_level == 1 and short_path[gutils.key(head)]) or (priority_level == 2 and head_vanilla_reachable(head)) or priority_level == 3 then
                                if #reserved_bases >= 1 then
                                    for i = #reserved_bases, 1, -1 do
                                        local res_base = reserved_bases[i]

                                        -- CRITICAL TODO: More proper check compatibility/validity between head and base
                                        if is_compatible(res_base, head) then
                                            table.remove(reserved_bases, i)
                                            is_reserved_base[gutils.key(res_base)] = nil
                                            
                                            local res_head = base_to_head[gutils.key(res_base)]
                                            base_to_head[gutils.key(res_base)] = head
                                            head_to_base[gutils.key(res_head)] = nil
                                            head_to_base[gutils.key(head)] = res_base

                                            log("\n\nCancelling\n" .. gutils.key(res_head) .. "\nin\n" .. gutils.key(res_base) .. "\nfor\n" .. gutils.key(head) .. "\n")

                                            -- Update reachability
                                            connect_head(res_base, head)

                                            update_reservations()

                                            found_cancellation = true
                                            break
                                        end
                                    end
                                else
                                    break
                                end
                            end
                        end
                        if found_cancellation then
                            break
                        end
                    end
                    if found_cancellation then
                        break
                    end
                end
                if not found_cancellation then
                    if #reserved_bases == 0 then
                        break
                    else
                        local first_res_base = reserved_bases[1]
                        fulfill_reservation(first_res_base, base_to_head[gutils.key(first_res_base)])
                        is_reserved_base[gutils.key(first_res_base)] = nil
                    end
                end
            end
        end
        if new_head == nil then
            -- Log first base that couldn't find a head
            for _, base in pairs(base_deps) do
                if base_to_head[gutils.key(base)] == nil and base_reachable(base) then
                    log(serpent.block(base))
                    break
                end
            end
            -- Log first head that couldn't find a base
            for perm_ind, head_ind in pairs(perm) do
                head = head_deps[head_ind]
                if head_to_base[gutils.key(head)] == nil and head_absolute_reachable(head) then
                    log(serpent.block(head))
                    break
                end
            end
            local percentage = math.floor(100 * i / #base_deps)
            log("Success percentage: " .. percentage .. "%")
            --error("Randomization errored at " .. percentage .. "% of the way through.")
            break
        end

        log("\n\nBASE: " .. gutils.key(old_base) .. "\nHEAD: " .. gutils.key(new_head) .. "\n")
        if is_reserved_base[gutils.key(old_base)] then
            log("RESERVED\n")
        end

        table.insert(base_unlock_order, old_base)
        base_to_head[gutils.key(old_base)] = new_head
        head_to_base[gutils.key(new_head)] = old_base
        -- If not a reservation, update reachability
        if not is_reserved_base[gutils.key(old_base)] then
            connect_head(old_base, new_head)
        end

        update_reservations()
    end

    -- If there are reservations left, those bases are unreachable, an error
    if #reserved_bases >= 1 then
        log(tostring(#reserved_bases) .. " reservations left")
        -- CRITICAL TODO: fulfill!
    end

    local new_dep_order = {}
    for _, dep in pairs(base_unlock_order) do
        table.insert(new_dep_order, base_to_head[gutils.key(dep)])
    end

    local so_many_sorts = top.sort(old_graph)
    -- Also make travelers unreachable
    local trav_to_old_slot_in_old_graph = {}
    for _, dep in pairs(new_dep_order) do
        -- A little bit of awkwardness here since dep is a head and so has a different key
        -- We just translate to base and get that one's key
        for _, trav in pairs(dep_to_travs[gutils.key(head_to_base[gutils.key(dep)])]) do
            local old_edge_key = next(trav.pre)
            if old_edge_key ~= nil then
                local old_slot_key = old_graph.edges[old_edge_key].stop
                trav_to_old_slot_in_old_graph[gutils.key(trav)] = old_slot_key
                gutils.remove_edge(old_graph, old_edge_key)
            end
        end
    end
    for _, dep in pairs(new_dep_order) do
        -- First add all prereqs back to travs
        for _, trav in pairs(dep_to_travs[gutils.key(head_to_base[gutils.key(dep)])]) do
            local edge_start = trav_to_old_slot_in_old_graph[gutils.key(trav)]
            if edge_start ~= nil then
                local trav_edge = gutils.add_edge(old_graph, edge_start, gutils.key(trav))
                so_many_sorts = top.sort(old_graph, so_many_sorts, {
                    edge = gutils.ekey(trav_edge),
                    contexts = so_many_sorts.node_to_contexts[edge_start],
                })
            end
        end

        local dep_key = gutils.key(dep)
        local edge_start_slot = gutils.key(head_to_base[dep_key])
        local edge_start = gutils.key(base_to_slot[edge_start_slot])
        local edge_end = gutils.key(head_to_trav[dep_key])
        local new_edge = gutils.add_edge(old_graph, edge_start, edge_end)
        local all_contexts = {}
        for context, _ in pairs(logic.contexts) do
            all_contexts[context] = true
        end
        so_many_sorts = top.sort(old_graph, so_many_sorts, {
            edge = gutils.ekey(new_edge),
            -- CRITICAL TODO: Make sure this accounts for edge context changes later (in general our subdivisions need to get fixed for that)
            -- Currently none of my randomizations occur at context change edges though so I can ignore this for now
            contexts = so_many_sorts.node_to_contexts[edge_start],
        })
    end

    return {
        new_dep_order = new_dep_order,
        pass_sort = so_many_sorts,
    }
end

do return first_pass end
-- Below this is old code

-- Extra number of estimated prereqs required in each pool past 1
local PREREQ_REQUIREMENT_BONUS = 0

-- Shuffle the open list of the sort info given in sort from the graph while attempting to keep prereq pool healthy
-- Need to check "reachability" of an element of open... what does that mean?
-- I guess we activate the contexts we've been given along the edges
-- Wait, we just need to shuffle the deps, the others will follow naturally
-- Wait no, we shuffle open, then pick out the deps
-- dep_map should not be a list, but a map from dep node key to dependent
-- I think sort needs to be with the extended contexts version

-- graph should be cut_graph
-- node_to_random_travs is mostly for convenience; takes our dep node and produces the travs to check
-- prereqs is just a list of node_key for slots; it can have duplicates if a slot is allowed to be used multiple times
first_pass.shuffle = function(graph, sort, dep_map, prereqs, node_to_random_travs)
    local dep_to_context_sequence = {}
    for _, open_info in pairs(sort.open) do
        local node_key = open_info.node
        if dep_map[node_key] ~= nil then
            dep_to_context_sequence[node_key] = dep_to_context_sequence[node_key] or {}
            table.insert(dep_to_context_sequence[node_key], table.deepcopy(open_info.contexts))
        end
    end

    local shuffled_open = rng.shuffle(rng.key({id = "unified"}), table.deepcopy(sort.open))
    local deps_shuffled = {}
    local dep_to_inds_in_shuffled = {}
    for open_ind, open_info in pairs(shuffled_open) do
        local node_key = open_info.node
        if dep_map[node_key] ~= nil then
            -- Contexts need to be decided by deck method, so just insert node_key
            table.insert(deps_shuffled, node_key)
            dep_to_inds_in_shuffled[node_key] = dep_to_inds_in_shuffled[node_key] or {}
            dep_to_inds_in_shuffled[node_key][open_ind] = true
        end
    end

    -- dep --> number representing how many times it's been put in new_order
    -- This is used to determine which context from dep_to_context_sequence to use
    local num_times_dep_used = {}
    for dep_key, _ in pairs(dep_map) do
        num_times_dep_used[dep_key] = 0
    end
    -- node_type --> number of times that node type was used
    local node_type_to_consumed = {}
    for node_type, type_info in pairs(logic.type_info) do
        node_type_to_consumed[node_type] = 0
    end

    -- This is for finding what slots/prereqs are currently reachable
    local slot_sort = top.sort(graph)

    local ind_to_used = {}
    local new_order = {}

    for i = 1, #deps_shuffled do
        local found_next_dep = false
        for dep_ind, dep_key in pairs(deps_shuffled) do
            -- An immediate check for ind used is efficient and gets that out of the way
            -- TODO: Need to check dep reachable too
            if not ind_to_used[dep_ind] then
                -- Check prereq pools with respect to context (then propagate with new reachable - will need to deal with "edge still not being there")
                -- I think the edge not being there problem can be solved by just using the traveler --> owner connection
                local context_to_use = dep_to_context_sequence[dep_key][num_times_dep_used[dep_key] + 1]

                local all_travs_satisfied = false
                for _, trav in pairs(node_to_random_travs[dep_key]) do
                    -- Strategy: Find number of slots that transmit at least context_to_use on a transmit_dep (need to do this in case the edge modifies context)
                    --   And also check validity for each one
                    --   Then, multiply by the the fraction of the total number of slots reachable by some context that are not consumed
                    --   Finally, check if the final result is at least 1 + PREREQ_REQUIREMENT_BONUS

                    local total_num_reachable_slots = 0
                    local total_num_valid_slots = 0
                    -- It's really slow to keep iterating over every slot each time, but this is good enough for now
                    for _, slot_key in pairs(prereqs) do
                        -- Check dep context transmission
                    end
                end
            end
        end
    end
end

return first_pass