-- Differences with first-pass.lua:
--  * Doesn't use base/head terminology, but rather a .slot = true or .trav = true key property; nodes are still of the same type (though slot keeps name)

-- TODO: Tests for loop subroutines
--   * Bring loop subroutines out
-- TODO: Logging levels
--
-- (SOLVED) Current issue: Getting lost on recipe tech unlocks (with recipes completely detached)
--     My guess at what's happening is that it assumes these recipes are therefore immediately satisfiable, but they still need a technology beforehand
--     Thus, we need to check for prereq slots of the right type/enough prereqs first
-- Okay, I did that but now...
--     a) It's super duper slow
--     b) The ordering is super vanilla
--     c) The issue isn't fixed (light oil barrels need a particular crafting category and we only check prereq types)
-- Idea:
--     Ways to get unstuck in the beginning are often different from what you need mid-game. Gun turrets are eventually needed in spage, but not initially, so can be put off even if they're on the critical path
-- (SOLVED-ISH) NOW: Things coming before on nauvis but after on other places
--      I tried a solution but it seems logistic science packs now aren't being put after hand crafting
-- NEXT: Gleba things that arenaturally early aren't used early (like biochambers)

local MAX_ITERATIONS = 10000
local FAILURE_ACCEPTANCE = 1--0.9
-- TODO: This could be set with a startup settings
local DO_TESTS = false
-- Disabled because it was slow
local PUT_PATH_SLOTS_FIRST = false
local DO_PREREQ_POOL_CHECK = false
local DO_SLOTS_IN_ORDER = true
local CHECK_SAME_MECHANICS = true
local REPORT_PATH = false
local REPORT_SIZE_STATS = true
local REPORT_STARTING_TRAVS = false
local REPORT_SLOTS_FAILED = false

local rng = require("lib/random/rng")
-- Used for contexts
local logic = require("new-lib/logic/init")
local lutils = require("new-lib/logic/logic-utils")
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
        if subdiv_node.spoof then
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
        -- Do the technology, so we don't make each tree's things important
        is_tool_node[key("technology", science_pack.name)] = true
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
    -- HOTFIX: Remove exfret copies
    local node_keys_to_remove = {}
    for node_key, _ in pairs(is_important) do
        if string.find(node_key, "exfret") ~= nil then
            table.insert(node_keys_to_remove, node_key)
        end
    end
    for _, node_key in pairs(node_keys_to_remove) do
        is_important[node_key] = nil
    end
    if REPORT_PATH then
        log(serpent.block(is_important))
    end
    
    local slot_inds = {}
    if PUT_PATH_SLOTS_FIRST then
        local in_path_in_order = {}
        local not_in_path_in_order = {}
        for _, ind in pairs(sorted_node_inds) do
            if path_info.in_path[ind] then
                table.insert(in_path_in_order, ind)
            else
                table.insert(not_in_path_in_order, ind)
            end
        end
        for _, ind in pairs(in_path_in_order) do
            table.insert(slot_inds, ind)
        end
        for _, ind in pairs(not_in_path_in_order) do
            table.insert(slot_inds, ind)
        end
    else
        slot_inds = sorted_node_inds
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

    -- Tests if the graph prenodes of node have a shared context in the *split sort* (regardless of the graph)
    local function node_prenodes_share_context(graph, node)
        for context, _ in pairs(logic.contexts) do
            local has_context = true
            for _, prenode in pairs(gutils.prenodes(graph, node)) do
                -- Don't involve the dangling connections for trav nodes
                if not node.trav or key(prenode) ~= key(trav_to_head[key(node)]) then
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

        -- CRITICAL TODO: Make decision of how to do this/profiling
        -- Right now I'm deciding between prereqs assigned and checking contexts

        -- Actually, this approach doesn't work, since slot
        --node_prenodes_share_context(spoofed_graph, spoofed_node)

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

    -- Just checks if there are enough prereq slots for trav of each type
    local function trav_acceptable(trav)
        if not DO_PREREQ_POOL_CHECK then
            return true
        end

        local type_to_nums = {}
        local slot_in_subdiv_graph = subdiv_graph.nodes[trav.old_slot]
        for _, prenode in pairs(gutils.prenodes(subdiv_graph, slot_in_subdiv_graph)) do
            if prenode.type == "head" then
                local prereq_type = gutils.get_owner(subdiv_graph, gutils.get_buddy(subdiv_graph, prenode)).type
                type_to_nums[prereq_type] = type_to_nums[prereq_type] or 0
                type_to_nums[prereq_type] = 1 + type_to_nums[prereq_type]
            end
        end
        local prereq_pool_sizes = {}
        for _, pebble in pairs(split_sort.sorted) do
            -- Check if this has at least one base depnode that could connect
            local node_in_subdiv = subdiv_graph.nodes[pebble.node_key]
            if node_in_subdiv ~= nil then
                for _, depnode in pairs(gutils.depnodes(subdiv_graph, node_in_subdiv)) do
                    if depnode.type == "base" then
                        if gutils.get_owner(subdiv_graph, gutils.get_buddy(subdiv_graph, depnode)).type == trav.type then
                            prereq_pool_sizes[node_in_subdiv.type] = prereq_pool_sizes[node_in_subdiv.type] or 0
                            prereq_pool_sizes[node_in_subdiv.type] = 1 + prereq_pool_sizes[node_in_subdiv.type]
                        end
                    end
                end
            end
        end
        for node_type, num_req in pairs(type_to_nums) do
            if prereq_pool_sizes[node_type] == nil or prereq_pool_sizes[node_type] < num_req then
                return false
            end
        end
        return true
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
        return node_prenodes_share_context(split_graph, trav)
    end
    if DO_TESTS then
        -- Assert that some traveler is not reachable from the start
        local some_trav_not_reachable = false
        for perm_ind, sorted_node_ptr in pairs(perm) do
            local trav = ind_to_trav(slot_inds[sorted_node_ptr])
            if not trav_absolute_reachable(trav) then
                some_trav_not_reachable = true
            elseif REPORT_STARTING_TRAVS then
                log(key(trav))
            end
        end
        if not some_trav_not_reachable then
            --error("All travs reachable")
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

    local trav_to_mechanics = {}
    for perm_ind, sorted_node_ptr in pairs(perm) do
        local trav = ind_to_trav(slot_inds[sorted_node_ptr])
        trav_to_mechanics[key(trav)] = {}
        local open = { trav }
        local in_open = {}
        local ind = 1
        while ind <= #open do
            local next_node = open[ind]
            if next_node.mechanic or (next_node.old_slot and split_graph.nodes[next_node.old_slot].mechanic) then
                trav_to_mechanics[key(trav)][key(next_node)] = true
            else
                -- Don't propagate through mechanics
                for _, depnode in pairs(gutils.depnodes(split_graph, next_node)) do
                    if not in_open[key(depnode)] then
                        in_open[key(depnode)] = true
                        table.insert(open, depnode)
                    end
                end
            end
            ind = ind + 1
        end
    end

    -- Not strictly necessary; this check makes sure the node replacing another is of the same type, increasing probability that valid previous prereqs can be found
    local function is_compatible(slot, trav)
        -- Check that slot and trav are of the same type
        local same_type = false
        if slot.type == "orand" and trav.type == "orand" then
            -- subdiv_graph is technically semantically correct since that's where the orand connections are correct
            local orand_parent1 = subdiv_graph.nodes[subdiv_graph.orand_to_parent[key(slot)]]
            -- Need to go to trav's old slot to get orand parent type
            local orand_parent2 = subdiv_graph.nodes[subdiv_graph.orand_to_parent[trav.old_slot]]
            if orand_parent1.type == orand_parent2.type then
                same_type = true
            end
        elseif slot.type == trav.type then
            same_type = true
        end
        if not same_type then
            return false
        end
        
        if CHECK_SAME_MECHANICS then
            for mechanic, _ in pairs(trav_to_mechanics[slot.old_trav]) do
                if not trav_to_mechanics[key(trav)][mechanic] then
                    return false
                end
            end
            for mechanic, _ in pairs(trav_to_mechanics[key(trav)]) do
                if not trav_to_mechanics[slot.old_trav][mechanic] then
                    return false
                end
            end
        end

        -- TODO: Check tech unlock; crafting with fluid
        if slot.type == "recipe" and trav.type == "recipe" then
            -- Check that two recipes are both enabled or both disabled
            local slot_recipe = data.raw.recipe[slot.name]
            local trav_recipe = data.raw.recipe[split_graph.nodes[trav.old_slot].name]
            if (slot_recipe.enabled or slot_recipe.enabled == nil) ~= (trav_recipe.enabled or trav_recipe.enabled == nil) then
                return false
            end

            -- Also check that both are crafting or not crafting
            if (slot_recipe.category == "crafting" or slot_recipe.category == nil) ~= (trav_recipe.category == "crafting" or trav_recipe.category == nil) then
                return false
            end

            -- Also check fluid match
            local fluids1 = lutils.find_recipe_fluids(slot_recipe)
            local fluids2 = lutils.find_recipe_fluids(trav_recipe)
            if fluids1.input ~= fluids2.input then
                return false
            elseif fluids1.output ~= fluids2.output then
                return false
            end
        end

        return true
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

        -- Connect reachable-room to slot edges to satisfy it, then connect slot to trav
        -- We need to connect to reachable-room so that it still gets contexts in a valid way
        local true_node = graph[key("reachable-room", "")]

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

        log("\n\nReplacing\n" .. old_trav_key .. "\nin\n" .. key(slot) .. "\nfor\n" .. key(new_trav) .. "\n")

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
        log("\nUnassigned slots...")
        for _, slot_ind in pairs(slot_inds) do
            local slot = ind_to_slot(slot_ind)
            local slot_key = key(slot)
            if slot_to_trav[slot_key] == nil then
                log(slot_key)
            end
        end
        log("\nUnassigned travs...")
        for perm_ind, sorted_node_ptr in pairs(perm) do
            local trav = ind_to_trav(slot_inds[sorted_node_ptr])
            local trav_key = key(trav)
            if trav_to_slot[trav_key] == nil then
                log(trav_key)
                log(trav_absolute_reachable(trav))
                log(trav_vanilla_reachable(trav))
            end
        end
        log("\nFirst pass failed at " .. tostring(math.floor(100 * i / #slot_inds)) .. "%\n")
    end

    for i = 1, #slot_inds do
        local found_slot
        local found_trav

        -- Outer desperation loop
        local disable_reachability_check = false
        while true do
            for iteration = 1, MAX_ITERATIONS do
                if iteration % 100 == 0 then
                    log("ITERATION #" .. tostring(iteration))
                end

                for _, slot_ind in pairs(slot_inds) do
                    local slot = ind_to_slot(slot_ind)
                    local slot_key = key(slot)
                    if slot_to_trav[slot_key] == nil and (slot_acceptable(slot) or disable_reachability_check) then
                        for perm_ind, sorted_node_ptr in pairs(perm) do
                            local trav = ind_to_trav(slot_inds[sorted_node_ptr])

                            if trav_acceptable(trav) and trav_to_slot[key(trav)] == nil and (trav_absolute_reachable(trav) or disable_reachability_check) then
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

                    -- Should we do a completely ordered traversal?
                    if DO_SLOTS_IN_ORDER and slot_to_trav[slot_key] == nil then
                        log("COULD NOT FIND TRAV FOR " .. slot_key)
                        break
                    end
                end
                if found_trav ~= nil then
                    break
                else
                    -- Reservation loop
                    if #reserved_slots == 0 then
                        break
                    end

                    local found_reservation = false
                    for p = 1, #perm do
                        -- Going in order is more likely to produce a newly reachable thing
                        local trav = ind_to_trav(slot_inds[p])

                        if trav_acceptable(trav) and trav_to_slot[key(trav)] == nil and trav_absolute_reachable(trav) then
                            for j = #reserved_slots, 1, -1 do
                                local slot = reserved_slots[j]

                                -- TODO: Should we check vanilla reachable for trav here?
                                if is_compatible(slot, trav) and is_important[trav.old_slot] and trav_vanilla_reachable(trav) then
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
                        log("FAILED CANCELLATION")
                        fulfill_reservation(1)
                        update_reservations()
                    end
                end
            end

            if found_trav ~= nil then
                break
            else
                print_failure_message(i)
                -- For debugging, ability to ignore last bit of unassigned slots/travs
                if i / #slot_inds < FAILURE_ACCEPTANCE then
                    return false
                else
                    if disable_reachability_check == true then
                        return false
                    else
                        disable_reachability_check = true
                    end
                end
            end
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
        log("There are " .. tostring(#reserved_slots) .. " reservations left!")
        return false
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
        -- CRITICAL TODO: Decide on sort after heuristics (ordered_sort or split_sort or init_sort)
        sort = ordered_sort,
        graph = old_split_graph,
    }
end

return first_pass