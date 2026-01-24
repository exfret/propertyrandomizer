-- Next steps:
--   * Figure out why this is putting things after unreachable things, like crude oil processing (it should just be failing in those cases)
--   * Needs to build context pools so that this doesn't happen

-- The following musings are outdated
--   This file currently does an extremely basic proposed sort order through the graph with randomized edges removed
--   There is some "prereq management" via not adding a dependent if there are not enough prereqs for it according to some heuristic
--   Other than that, it will be quite minimal until it is tested with the second pass algorithm
--   It simply returns a map from nodes to arrays, with each position in the array corresponding to a context, and for each node that position being the first time the context was reached
--   Actually... that means I need to simulate a whole top sort here, not just order the dependents, right? Because I need at which points things got context, not just the order of first unlock

local rng = require("lib/random/rng")
local logic = require("new-lib/logic/init")
local lutils = require("new-lib/logic/logic-utils")
local gutils = require("new-lib/graph/graph-utils")
local lu = require("new-lib/lookup/init")
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
first_pass.shuffle = function(graph, short_path, shuffled_prereqs, init_sort, base_deps, head_deps, dep_to_travs, head_to_trav, base_to_slot, base_to_vanilla_slots, trav_to_handler)
    -- Permutation to attempt on deps_sorted
    local perm = {}
    for i = 1, #base_deps do
        table.insert(perm, i)
    end
    rng.shuffle(rng.key({id = "unified"}), perm)

    local old_graph = table.deepcopy(graph)
    local pass_sort = top.sort(graph)

    local function base_reachable(base)
        -- Check if all vanilla connections have been assigned, thus getting contexts
        for _, slot in pairs(base_to_vanilla_slots[gutils.key(base)]) do
            local slot_contexts = pass_sort.node_to_contexts[gutils.key(slot)]
            if slot_contexts == nil then
                return false
            end
            if not (slot_contexts == true or next(slot_contexts) ~= nil) then
                return false
            end
        end
        return true

        -- Again, just check for any context
        --[[local base_contexts = pass_sort.node_to_contexts[gutils.key(base)]
        if base_contexts == nil then
            return false
        end
        if base_contexts == true or next(base_contexts) ~= nil then
            return true
        end
        return false]]
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

    local function connect_head(graph_to_connect, sort_to_use, base, head)
        -- First connect base to the vanilla base heads
        -- Get rid of old edges and just connect to the heads
        local to_remove = {}
        for pre, _ in pairs(base.pre) do
            table.insert(to_remove, pre)
        end
        for _, pre in pairs(to_remove) do
            gutils.remove_edge(graph_to_connect, pre)
        end
        -- Now add edges from vanilla slot heads
        for _, slot in pairs(base_to_vanilla_slots[gutils.key(base)]) do
            local slot_base = gutils.get_conn_owner(graph_to_connect, slot)
            local new_head = base_to_head[gutils.key(slot_base)]
            -- If new_head was nil, this maybe wasn't a dep, so wouldn't have a corresponding edge anyways
            -- If it was a base, then it should always have a head
            local new_slot_edge = gutils.add_edge(graph_to_connect, gutils.key(new_head or slot_base), gutils.key(base))
            sort_to_use = top.sort(graph_to_connect, sort_to_use, {
                edge = gutils.ekey(new_slot_edge),
                contexts = sort_to_use.node_to_contexts[gutils.key(new_head or slot_base)],
            })
        end

        local new_edge = gutils.add_edge(graph_to_connect, gutils.key(base_to_slot[gutils.key(base)]), gutils.key(head_to_trav[gutils.key(head)]), trav_to_handler)
        local all_contexts = {}
        for context, _ in pairs(logic.contexts) do
            all_contexts[context] = true
        end
        sort_to_use = top.sort(graph_to_connect, sort_to_use, {
            edge = gutils.ekey(new_edge),
            -- CRITICAL TODO: Make sure this accounts for edge context changes later (in general our subdivisions need to get fixed for that)
            -- Currently none of my randomizations occur at context change edges though so I can ignore this for now
            -- CRITICAL TODO: I turned off HAVING to have slot reachable but... is that the right way? Now I have to make this true
            contexts = sort_to_use.node_to_contexts[gutils.key(base)],
        })

        return sort_to_use
    end

    local function fulfill_reservation(base, head)
        local ind_to_remove
        for res_ind, res_base in pairs(reserved_bases) do
            if gutils.key(res_base) == gutils.key(base) then
                ind_to_remove = res_ind
            end
        end
        table.remove(reserved_bases, ind_to_remove)
        pass_sort = connect_head(graph, pass_sort, base, head)
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

    -- Check if there are enough prereqs for head to make a reservation
    -- We want each traveler to have at least some number of choices choices
    local function can_reserve(head)
        for _, head_trav in pairs(dep_to_travs[string.sub(gutils.key(head), 1, -6)]) do
            local num_prereqs = 0
            for _, prereq in pairs(shuffled_prereqs) do
                -- Just in case there are reference problems
                head_trav = old_graph.nodes[gutils.key(head_trav)]
                prereq = old_graph.nodes[gutils.key(prereq)]
                -- Just check for existence of any context so far
                local prereq_contexts = pass_sort.node_to_contexts[gutils.key(prereq)]
                if prereq_contexts ~= nil and (prereq_contexts == true or next(prereq_contexts) ~= nil) then
                    if trav_to_handler[gutils.key(head_trav)].validate(old_graph, prereq, head_trav, {init_sort = init_sort}) then
                        num_prereqs = num_prereqs + 1
                    end
                end

                if num_prereqs >= 0 then
                    break
                end
            end
            if num_prereqs < 0 then
                return false
            end
        end
        return true
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
                            if is_compatible(base, head) and (can_reserve(head) or head_vanilla_reachable(head)) then
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
                            if (priority_level == 1 and short_path[gutils.key(head)] and head_vanilla_reachable(head)) or (priority_level == 2 and head_vanilla_reachable(head)) or priority_level == 3 then
                                if #reserved_bases >= 1 then
                                    for j = #reserved_bases, 1, -1 do
                                        local res_base = reserved_bases[j]

                                        -- CRITICAL TODO: More proper check compatibility/validity between head and base
                                        if is_compatible(res_base, head) then
                                            table.remove(reserved_bases, j)
                                            is_reserved_base[gutils.key(res_base)] = nil
                                            
                                            local res_head = base_to_head[gutils.key(res_base)]
                                            base_to_head[gutils.key(res_base)] = head
                                            head_to_base[gutils.key(res_head)] = nil
                                            head_to_base[gutils.key(head)] = res_base

                                            log("\n\nCancelling\n" .. gutils.key(res_head) .. "\nin\n" .. gutils.key(res_base) .. "\nfor\n" .. gutils.key(head) .. "\n")

                                            -- Update reachability
                                            pass_sort = connect_head(graph, pass_sort, res_base, head)

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
            -- Log number reservations left
            log(#reserved_bases)
            -- Log first base that couldn't find a head
            for _, base in pairs(base_deps) do
                if base_to_head[gutils.key(base)] == nil and base_reachable(base) then
                    log(serpent.block(base))
                    break
                end
            end
            -- Log first head that couldn't find a base
            for perm_ind, head_ind in pairs(perm) do
                local head = head_deps[head_ind]
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
            pass_sort = connect_head(graph, pass_sort, old_base, new_head)
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

    --[[local so_many_sorts = top.sort(old_graph)
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
    end]]
    
    -- Need to use another sort because reservations cause being out of order
    local so_many_sorts = top.sort(old_graph)
    for _, dep in pairs(base_unlock_order) do
        so_many_sorts = connect_head(old_graph, so_many_sorts, old_graph.nodes[gutils.key(dep)], old_graph.nodes[gutils.key(base_to_head[gutils.key(dep)])])
    end
    -- Contexts are transferred from bases to heads later

    -- We just need to change it so the head contexts are what's considered
    --[[local new_context_assignments = {}
    for _, dep in pairs(base_unlock_order) do
        new_context_assignments[gutils.key(base_to_head[gutils.key(dep)])] = so_many_sorts.node_to_contexts[gutils.key(dep)]
    end
    for node_key, contexts in pairs(new_context_assignments) do
        so_many_sorts.node_to_contexts[node_key] = contexts
    end
    -- Oh, and we need to change open
    -- TODO: Maybe be more careful to switch base's sort information onto head?
    local new_open = {}
    for _, open_info in pairs(so_many_sorts.open) do
        if base_to_head[open_info.node] == nil then
            -- Transfer base contexts to heads
            if head_to_base[open_info.node] ~= nil then
                log(gutils.key(head_to_base[open_info.node]))
                open_info.node = gutils.key(head_to_base[open_info.node])
            end
            table.insert(new_open, open_info)
        -- Read the bases, but with the head's name just so ind_to_inds is happy
        else
            open_info.node = open_info.node .. "-head"
            table.insert(new_open, open_info)
        end
    end
    so_many_sorts.open = new_open
    log(serpent.block(so_many_sorts.open))]]

    return {
        new_dep_order = new_dep_order,
        pass_sort = so_many_sorts,
    }
end

return first_pass