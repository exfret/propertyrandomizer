-- Differences with first-pass.lua:
--  * Doesn't use base/head terminology, but rather a .slot = true or .trav = true key property; nodes are still of the same type (though slot keeps name)

local MAX_ITERATIONS = 10000

-- Used for contexts
local logic = require("new-lib/logic/init")
local gutils = require("new-lib/graph/graph-utils")
local top = require("new-lib/graph/consistent-sort")
local test_graph_invariants = require("tests/graph-invariants")

local key = gutils.key

local first_pass = {}

local function make_trav_name(old_name)
    return old_name .. "-trav"
end

first_pass.execute = function(params)
    ----------------------------------------------------------------------------------------------------
    -- CREATE PERMUTATION
    ----------------------------------------------------------------------------------------------------

    local graph = table.deepcopy(params.graph)
    local added_to_deps = params.added_to_deps

    local init_sort = top.sort(graph)

    local node_in_sorted = {}
    local sorted_node_inds = {}
    for ind, pebble in pairs(init_sort.sorted) do
        if node_in_sorted[pebble.node_key] == nil then
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
    -- SPLIT GRAPH NODES
    ----------------------------------------------------------------------------------------------------

    for node_key, _ in pairs(node_in_sorted) do
        local node = graph.nodes[node_key]
        node.slot = true
        local trav = gutils.add_node(graph, node.type, make_trav_name(node.name))
        trav.trav = true
        trav.old_slot = node_key
        slot.old_trav = key(trav)
        -- Randomized edges to slot, fixed to trav
        -- CRITICAL TODO: I am allowing non-dep nodes, so things without any randomized connections... does this create any issues?..
        --    Well, on that note, we need to keep track of the fact that some "normal" nodes (without the -trav in their name) will have fixed edges if they don't get that corresponding slot)
        --    Or wait, the fact we do things this way might prevent this? Just need to add tests.
        -- By construction, an edge is randomized exactly when it's subdivided, so we can just check for the existence of a head/base
        local fixed_pre = {}
        for pre, _ in pairs(slot.pre) do
            if gutils.prenode(graph, pre).type ~= "head" then
                fixed_pre[pre] = true
            end
        end
        for pre, _ in pairs(fixed_pre) do
            gutils.redirect_edge_stop(graph, pre, trav)
        end
        local fixed_dep = {}
        for dep, _ in pairs(slot.pre) do
            if gutils.depnode(graph, dep).type ~= "base" then
                fixed_dep[pre] = true
            end
        end
        for dep, _ in pairs(fixed_dep) do
            gutils.redirect_edge_start(graph, dep, trav)
        end

        local slot_trav_edge = gutils.add_edge(graph, slot, trav)
        local base_head = gutils.subdivide_base_head(graph, gutils.ekey(slot_trav_edge))
        local head = base_head.head
        local edge_to_sever = gutils.unique_pre(head)
        gutils.remove_edge(graph, gutils.ekey(edge_to_sever))
    end
    test_graph_invariants.test(graph)

    local pass_sort = top.sort(graph)

    ----------------------------------------------------------------------------------------------------
    -- HELPERS
    ----------------------------------------------------------------------------------------------------

    local function ind_to_slot(ind)
        return graph.nodes[init_sort.sorted[ind].node_key]
    end
    local function ind_to_trav(ind)
        local slot_node = ind_to_base(ind)
        local trav_type = slot_node.type
        local trav_name = make_trav_name(slot_node.name)
        return graph.nodes[key(trav_type, trav_name)]
    end

    local function slot_acceptable(slot)
        -- TODO: There are many methods here, we should test them all out and choose the best
        --   * Call a slot acceptable if all its vanilla prereq *bases* have been satisfied by some context
        --      - Note that this checks other randomized contexts
        --      - I think this is what I was doing previously?
        --      - Actually, does that even make sense? Because then the slots would almost always go in order anyways
        --   * Call a slot acceptable if all the travelers for its old vanilla bases are assigned
        --      - This could make the sort too vanilla
        --   * Call a slot acceptable if there is some heuristic deciding there are enough prereqs for it
        --   * Just return true
        return true
    end

    local function trav_absolute_reachable(trav)
        -- This part is mandatory since it involves fixed edges
        -- Check that there is a common context among trav's fixed edge prereqs (excluding the dangling connection for a slot)
        for context, _ in pairs(logic.contexts) do
            local has_context = true
            for _, prenode in pairs(gutils.prenodes(trav)) do
                -- The only time a prenode will be a head is if it's the dangling connection for a slot
                if prenode.type == "head" then
                    if pass_sort.node_to_context_inds[key(prenode)][context] == nil then
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

    ----------------------------------------------------------------------------------------------------
    -- CORE LOOP
    ----------------------------------------------------------------------------------------------------

    local slot_to_trav = {}
    local trav_to_slot = {}

    for i = 1, #sorted_node_inds do
        local found_slot
        local found_trav

        for iteration = 1, MAX_ITERATIONS do
            for _, slot_ind in pairs(sorted_node_inds) do
                local slot = ind_to_slot(slot_ind)
                local slot_key = key(slot)
                if slot_to_trav[slot_key] == nil and slot_acceptable(slot) then
                    for perm_ind, sorted_node_ptr in pairs(perm) do
                        local sorted_node_ind = sorted_node_inds[sorted_node_ptr]
                        local trav_slot_pebble = init_sort.sorted[sorted_node_ind]
                        local trav_slot = graph.nodes[trav_slot_pebble.node_key]
                        local trav_key = key(trav_slot.type, make_trav_name(trav_slot.name))
                        local trav = graph.nodes[trav_key]

                        if trav_to_slot[trav_key] == nil and trav_absolute_reachable(trav) then
                            
                        end
                    end
                end
            end
        end
    end

    -- TODO: Keep orands in mind!
end

return first_pass