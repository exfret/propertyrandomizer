-- Differences with first-pass.lua:
--  * Doesn't use base/head terminology, but rather a .slot = true or .trav = true key property; nodes are still of the same type (though slot keeps name)

-- TODO: Tests for loop subroutines
--   * Bring loop subroutines out
-- TODO: Logging levels
-- TODO: electric pole is not booting anything

local MAX_ITERATIONS = 10000
-- TODO: This could be set with a startup settings
local DO_TESTS = true
local REPORT_PATH = false
local REPORT_SIZE_STATS = true
local REPORT_STARTING_TRAVS = false
local REPORT_SLOTS_FAILED = false
local REPORT_FAILED_CANCELLATIONS = true

local rng = require("lib/random/rng")
-- Used for contexts
local logic = require("new-lib/logic/init")
local gutils = require("new-lib/graph/graph-utils")
local top = require("new-lib/graph/consistent-sort")
local test_graph_invariants = require("tests/graph-invariants")

local key = gutils.key

local first_pass = {}

local trav_suffix = "-trav"
local function make_trav_name(old_name)
    return old_name .. trav_suffix
end
first_pass.make_trav_name = make_trav_name

first_pass.execute = function(params)
    ----------------------------------------------------------------------------------------------------
    -- CREATE PERMUTATION
    ----------------------------------------------------------------------------------------------------

    -- spoofed_graph is used to get prereqs before subdivision
    local spoofed_graph = table.deepcopy(params.spoofed_graph)
    local subdiv_graph = table.deepcopy(params.subdiv_graph)

    local init_sort = top.sort(spoofed_graph)

    local function valid_node_for_first_pass(node_key)
        -- Just check if at least one of its edges are randomized, or in other words that one of the pre's in subdiv graph are a head
        local subdiv_node = subdiv_graph.nodes[node_key]
        if subdiv_node.dummy then
            return false
        end
        for _, prenode in pairs(gutils.prenodes(subdiv_graph, subdiv_node)) do
            if prenode.type == "head" then
                return true
            end
        end
        return false
    end

    local node_in_sorted = {}
    local sorted_node_inds = {}
    for ind, pebble in pairs(init_sort.sorted) do
        if node_in_sorted[pebble.node_key] == nil and valid_node_for_first_pass(pebble.node_key) then
            node_in_sorted[pebble.node_key] = ind
            table.insert(sorted_node_inds, ind)
        end
    end

    -- Permutation to attempt on sorted_node_inds
    local perm = {}
    for i = 1, #sorted_node_inds do
        table.insert(perm, i)
    end
    rng.shuffle(rng.key({id = "unified"}), perm)

    ----------------------------------------------------------------------------------------------------
    -- FIND PATH
    ----------------------------------------------------------------------------------------------------

    -- First create goal nodes: tool items/sciences
    -- TODO: This just tests for ability to create sciences, not whether you can launch a ship to beat the game, actually research with the sciences, etc., so I could check those in the future
    -- TODO: This assumes nauvis context; we could be more flexible later
    local is_tool_node = {}
    for _, science_pack in pairs(data.raw.tool) do
        is_tool_node[key("item", science_pack.name)] = true
    end
    local nauvis_context = key("planet", "nauvis")
    local goal_inds = {}
    for ind, pebble in pairs(init_sort.sorted) do
        if is_tool_node[pebble.node_key] and pebble.context == nauvis_context then
            table.insert(goal_inds, ind)
        end
    end
    local path_info = top.path(spoofed_graph, goal_inds, init_sort)
    local is_important = {}
    for ind, pebble in pairs(init_sort.sorted) do
        if path_info.in_path[ind] then
            is_important[pebble.node_key] = true
        end
    end
    if REPORT_PATH then
        log(serpent.block(is_important))
    end

    ----------------------------------------------------------------------------------------------------
    -- SPLIT GRAPH NODES
    ----------------------------------------------------------------------------------------------------

    local split_graph = table.deepcopy(subdiv_graph)

    -- TEST: Presumably, at least one edge should not be randomized
    local not_all_randomized = false

    -- Sends a slot to the head that connects it to a trav, and vice versa for trav and head
    local slot_to_base = {}
    local trav_to_head = {}
    for node_key, _ in pairs(node_in_sorted) do
        local node = split_graph.nodes[node_key]
        node.slot = true
        local trav = gutils.add_node(split_graph, node.type, make_trav_name(node.name))
        trav.op = node.op
        trav.trav = true
        trav.old_slot = node_key
        node.old_trav = key(trav)
        -- Randomized edges to slot, fixed to trav
        -- CRITICAL TODO: I am allowing non-dep nodes, so things without any randomized connections... does this create any issues?..
        --    Well, on that note, we need to keep track of the fact that some "normal" nodes (without the -trav in their name) will have fixed edges if they don't get that corresponding slot)
        --    Or wait, the fact we do things this way might prevent this? Just need to add tests.
        -- By construction, an edge is randomized exactly when it's subdivided, so we can just check for the existence of a head/base
        -- EDIT: I'm going back on that and randomizing
        local fixed_pre = {}
        for pre, _ in pairs(node.pre) do
            if gutils.prenode(split_graph, pre).type ~= "head" then
                fixed_pre[pre] = true
                not_all_randomized = true
            end
        end
        for pre, _ in pairs(fixed_pre) do
            gutils.redirect_edge_stop(split_graph, pre, key(trav))
        end
        local fixed_dep = {}
        for dep, _ in pairs(node.dep) do
            if gutils.depnode(split_graph, dep).type ~= "base" then
                fixed_dep[dep] = true
                not_all_randomized = true
            end
        end
        for dep, _ in pairs(fixed_dep) do
            gutils.redirect_edge_start(split_graph, dep, key(trav))
        end

        local slot_trav_edge = gutils.add_edge(split_graph, node, trav)
        local base_head = gutils.subdivide_base_head(split_graph, gutils.ekey(slot_trav_edge))
        slot_to_base[node_key] = base_head.base
        trav_to_head[key(trav)] = base_head.head
        local head = base_head.head
        local edge_to_sever = gutils.unique_pre(split_graph, head)
        gutils.remove_edge(split_graph, gutils.ekey(edge_to_sever))
    end
    test_graph_invariants.test(split_graph)

    if not not_all_randomized and DO_TESTS then
        error("It seems all edges are randomized?")
    end
    if REPORT_SIZE_STATS then
        local in_sorted_size = 0
        for _, _ in pairs(node_in_sorted) do
            in_sorted_size = in_sorted_size + 1
        end
        log("\n\nNUMBER SLOT/TRAVS: " .. tostring(in_sorted_size) .. "\n\n")
    end

    local old_split_graph = table.deepcopy(split_graph)
    local split_sort = top.sort(split_graph)

    -- CRITICAL TODO: REMOVE
    log(serpent.block(old_split_graph.nodes[key("recipe", "copper-cable-trav")]))

    ----------------------------------------------------------------------------------------------------
    -- HELPER FUNCTIONS
    ----------------------------------------------------------------------------------------------------
    
    local slot_to_trav = {}
    local trav_to_slot = {}
    local new_slot_order = {}

    local function ind_to_slot(ind)
        return split_graph.nodes[init_sort.sorted[ind].node_key]
    end
    local function ind_to_trav(ind)
        local slot_node = ind_to_slot(ind)
        local trav_type = slot_node.type
        local trav_name = make_trav_name(slot_node.name)
        return split_graph.nodes[key(trav_type, trav_name)]
    end

    -- Checks that the slots that another slot would have depended on in vanilla (so fixed + randomized edges) are assigned
    -- This essentially checks whether this slot would have been reachable in a vanilla progression
    local function slot_vanilla_prereqs_assigned(slot)
        -- TEST: Make sure this is a slot
        if not slot.slot then
            log(serpent.block(slot))
            log(key(slot))
            error("Slot expected, but got different node type")
        end

        local spoofed_node = spoofed_graph.nodes[key(slot)]

        -- TEST: Make sure spoofed_node non-nil
        if spoofed_node == nil then
            log(serpent.block(slot))
            log(key(slot))
            error("slot doesn't exist in spoofed graph")
        end

        for _, prenode in pairs(gutils.prenodes(spoofed_graph, spoofed_node)) do
            local prenode_in_split_graph = split_graph.nodes[key(prenode)]

            if prenode_in_split_graph.slot and slot_to_trav[key(prenode)] == nil then
                return false
            end
        end
        return true
    end

    local function slot_acceptable(slot)
        -- TEST: Make sure this is a slot
        if not slot.slot then
            log(serpent.block(slot))
            log(key(slot))
            error("Slot expected, but got different node type")
        end

        -- TODO: There are many methods here, we should test them all out and choose the best
        --   * Call a slot acceptable if all its vanilla prereq *bases* have been satisfied by some context
        --      - Note that this checks other randomized contexts
        --      - I think this is what I was doing previously?
        --      - Actually, does that even make sense? Because then the slots would almost always go in order anyways
        --   * Call a slot acceptable if all the travelers for its old vanilla bases are assigned
        --      - This could make the sort too vanilla
        --   * Call a slot acceptable if there is some heuristic deciding there are enough prereqs for it
        --   * Just return true (we already follow a sorting of the slots, so this might be enough)
        -- Returning true wasn't sufficient, so I think I'm going to do the first option
        return slot_vanilla_prereqs_assigned(slot)
    end

    local function trav_absolute_reachable(trav)
        -- TEST: Make sure this is a trav
        if not trav.trav then
            log(serpent.block(trav))
            log(key(trav))
            error("Traveler expected, but got different node type")
        end

        -- This part is mandatory since it involves fixed edges
        -- Check that there is a common context among trav's fixed edge prereqs (excluding the dangling connection for a slot)
        for context, _ in pairs(logic.contexts) do
            local has_context = true
            for _, prenode in pairs(gutils.prenodes(split_graph, trav)) do
                if key(prenode) ~= key(trav_to_head[key(trav)]) then
                    if split_sort.node_to_context_inds[key(prenode)][context] == nil then
                        has_context = false
                        break
                    end
                end
            end
            if has_context then
                return true
            end
        end
        -- No valid context found
        return false
    end
    if DO_TESTS then
        -- Assert that some traveler is not reachable from the start
        local some_trav_not_reachable = false
        for perm_ind, sorted_node_ptr in pairs(perm) do
            local trav = ind_to_trav(sorted_node_inds[sorted_node_ptr])
            if not trav_absolute_reachable(trav) then
                some_trav_not_reachable = true
            elseif REPORT_STARTING_TRAVS then
                log(key(trav))
            end
        end
        if not some_trav_not_reachable then
            error("All travs reachable")
        end
    end

    -- Reserve things until all the corresponding slot is assigned
    -- This makes us stick to a fundamentally vanilla progression, while allowing crazy unlocks earlier
    local function trav_vanilla_reachable(trav)
        -- TEST: Make sure this is a trav
        if not trav.trav then
            log(serpent.block(trav))
            log(key(trav))
            error("Traveler expected, but got different node type")
        end

        return slot_to_trav[trav.old_slot] ~= nil
    end

    -- Not strictly necessary; this check makes sure the node replacing another is of the same type, increasing probability that valid previous prereqs can be found
    local function is_compatible(slot, trav)
        -- Just check that slot and trav are of the same type
        if slot.type == "orand" and trav.type == "orand" then
            -- subdiv_graph is technically semantically correct since that's where the orand connections are correct
            local orand_parent1 = subdiv_graph.nodes[subdiv_graph.orand_to_parent[key(slot)]]
            -- Need to go to trav's old slot to get orand parent type
            local orand_parent2 = subdiv_graph.nodes[subdiv_graph.orand_to_parent[trav.old_slot]]
            if orand_parent1.type == orand_parent2.type then
                return true
            end
        elseif slot.type == trav.type then
            return true
        end
        return false
    end

    ----------------------------------------------------------------------------------------------------
    -- RESERVATION SUBROUTINES
    ----------------------------------------------------------------------------------------------------

    local is_reserved = {}
    local reserved_slots = {}

    local function can_reserve(trav)
        -- Previously, we were checking for the existence of at least some number of prereqs, but it looks like even those checks were removed
        return true
    end

    local function to_be_reserved(trav)
        return not (trav_vanilla_reachable(trav) and is_important[trav.old_slot])
    end

    local function connect_slot_trav(graph, sort_info, slot, trav)
        -- TEST: Check slot is slot and trav is trav
        if not slot.slot then
            log(serpent.block(slot))
            log(key(slot))
            error("Got non-slot when expected slot.")
        end
        if not trav.trav then
            log(serpent.block(trav))
            log(key(trav))
            error("Got non-trav when expected trav.")
        end

        -- Check that these came from the correct graph
        if not test_graph_invariants.check_from_graph(split_graph, slot) then
            log(serpent.block(slot))
            log(key(slot))
            error("Slot from incorrect graph")
        end
        if not test_graph_invariants.check_from_graph(split_graph, trav) then
            log(serpent.block(trav))
            log(key(trav))
            error("Trav from incorrect graph")
        end

        -- Connect true to slot edges to satisfy it, then connect slot to trav
        local true_node = graph[key("true", "")]

        for _, prenode in pairs(gutils.prenodes(graph, slot)) do
            gutils.add_edge(graph, true_node, prenode)
            sort_info = top.sort(graph, sort_info, {true_node, prenode})
        end

        -- TEST: Check that slot corresponds to trav
        if slot_to_trav[key(slot)] ~= key(trav) then
            log(key(slot))
            log(key(trav))
            error("Connecting non-associated slot and trav")
        end

        -- Connect slot base to trav head
        local slot_base = slot_to_base[key(slot)]
        local trav_head = trav_to_head[key(trav)]

        -- TEST: See if base or head is nil
        if slot_base == nil then
            log(serpent.block(slot_to_base[key(slot)]))
            log(serpent.block(slot))
            log(key(slot))
            error("slot base nil")
        end
        if trav_head == nil then
            log(serpent.block(trav_to_head[key(trav)]))
            log(serpent.block(trav))
            log(trav)
            error("trav head nil")
        end

        gutils.add_edge(graph, slot_base, trav_head)
        sort_info = top.sort(graph, sort_info, {slot_base, trav_head})

        return sort_info
    end

    local function fulfill_reservation(res_ind)
        local slot = reserved_slots[res_ind]
        local trav = split_graph.nodes[slot_to_trav[key(slot)]]

        is_reserved[key(slot)] = nil
        table.remove(reserved_slots, res_ind)
        split_sort = connect_slot_trav(split_graph, split_sort, slot, trav)

        log("\n\nFULFILLED:\n" .. key(slot) .. " BY " .. key(trav) .. "\n")
    end

    local function update_reservations()
        local new_reservations = {}
        while true do
            local fulfilled = false

            for j = 1, #reserved_slots do
                local trav = split_graph.nodes[slot_to_trav[key(reserved_slots[j])]]
                if trav_vanilla_reachable(trav) then
                    fulfill_reservation(j)
                    fulfilled = true
                    break
                end
            end

            if not fulfilled then
                break
            end
        end
    end

    local function replace_reservation(res_ind, new_trav)
        local slot = reserved_slots[res_ind]
        local old_trav_key = slot_to_trav[key(slot)]

        log("\n\nReplacing\n" .. key(old_trav) .. "\nin\n" .. key(slot) .. "\nfor\n" .. gutils.key(new_trav) .. "\n")

        trav_to_slot[old_trav_key] = nil
        trav_to_slot[key(new_trav)] = key(slot)
        slot_to_trav[key(slot)] = key(new_trav)

        fulfill_reservation(res_ind)
        -- In case this fulfillment triggered more reservations to be available
        update_reservations()
    end

    ----------------------------------------------------------------------------------------------------
    -- CORE LOOP
    ----------------------------------------------------------------------------------------------------

    local function print_failure_message(i)
        error("First pass failed at " .. tostring(math.floor(100 * i / #sorted_node_inds)) .. "%")
    end

    for i = 1, #sorted_node_inds do
        local found_slot
        local found_trav

        for iteration = 1, MAX_ITERATIONS do
            if iteration % 100 == 0 then
                log("ITERATION #" .. tostring(iteration))
            end

            for _, slot_ind in pairs(sorted_node_inds) do
                local slot = ind_to_slot(slot_ind)
                local slot_key = key(slot)
                if slot_to_trav[slot_key] == nil and slot_acceptable(slot) then
                    for perm_ind, sorted_node_ptr in pairs(perm) do
                        local trav = ind_to_trav(sorted_node_inds[sorted_node_ptr])

                        if trav_to_slot[key(trav)] == nil and trav_absolute_reachable(trav) then
                            if is_compatible(slot, trav) and (can_reserve(trav) or not to_be_reserved(trav)) then
                                if to_be_reserved(trav) then
                                    is_reserved[key(slot)] = true
                                    table.insert(reserved_slots, slot)
                                end
                                found_slot = slot
                                found_trav = trav
                                break
                            end
                        end
                    end
                    if found_trav == nil and REPORT_SLOTS_FAILED then
                        log("SLOT FAILURE: " .. key(slot))
                    end
                end
                if found_trav ~= nil then
                    break
                end
            end
            if found_trav ~= nil then
                break
            else
                -- Reservation loop
                if #reserved_slots == 0 then
                    print_failure_message(i)
                end

                local found_reservation = false
                for perm_ind, sorted_node_ptr in pairs(perm) do
                    local trav = ind_to_trav(sorted_node_inds[sorted_node_ptr])

                    if trav_to_slot[key(trav)] == nil and trav_absolute_reachable(trav) then
                        for j = #reserved_slots, 1, -1 do
                            local slot = reserved_slots[j]

                            -- TODO: Should we check vanilla reachable for trav here?
                            if is_compatible(slot, trav) and is_important[trav.old_slot] then
                                replace_reservation(j, trav)
                                found_reservation = true
                                break
                            end
                        end
                    end
                    if found_reservation then
                        break
                    end
                end

                if not found_reservation then
                    if REPORT_FAILED_CANCELLATIONS then
                        for _, slot in pairs(reserved_slots) do
                            log(key(slot))
                            log(slot_to_trav[key(slot)])
                        end
                        log("FAILED CANCELLATION")
                    end

                    fulfill_reservation(1)
                    update_reservations()
                end
            end
        end

        if found_trav == nil then
            print_failure_message(i)
        end

        slot_to_trav[key(found_slot)] = key(found_trav)
        trav_to_slot[key(found_trav)] = key(found_slot)
        table.insert(new_slot_order, key(found_slot))
        local res_string_to_print = "\n\nSLOT: " .. key(found_slot) .. "\nTRAV: " .. key(found_trav)
        if is_reserved[key(found_slot)] then
            res_string_to_print = res_string_to_print .. "\n(RESERVED)"
        else
            connect_slot_trav(split_graph, split_sort, found_slot, found_trav)
        end
        res_string_to_print = res_string_to_print .. "\n"
        log(res_string_to_print)

        update_reservations()
    end

    if #reserved_slots >= 1 then
        -- The travs should have been satisfied by now
        for _, slot in pairs(reserved_slots) do
            log(key(slot))
            log(slot_to_trav[key(slot)])
        end
        error("There are " .. tostring(#reserved_slots) .. " reservations left!")
    end

    -- Need to do a new sort since the reservations can make it out of order
    local ordered_sort = top.sort(old_split_graph)
    for _, slot_key in pairs(new_slot_order) do
        local slot = old_split_graph.nodes[slot_key]
        local trav = old_split_graph.nodes[slot_to_trav[slot_key]]
        ordered_sort = connect_slot_trav(old_split_graph, ordered_sort, slot, trav)
    end

    return {
        slot_to_trav = slot_to_trav,
        trav_to_slot = trav_to_slot,
        -- CRITICAL TODO: Decide on sort after heuristics
        sort = split_sort,
        --sort = ordered_sort,
        graph = old_split_graph,
    }
end

return first_pass