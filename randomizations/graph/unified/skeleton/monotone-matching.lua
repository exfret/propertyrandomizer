-- Monotone matching for first pass: chooses which item identity (trav) goes in which item position (slot) all at once, instead of first pass's greedy forward fill
-- Based on the other session's report (scratchpad REPORT-multipass-complex-contexts.md) and its exp-iter.lua prototype
--
-- A round starts from a valid matching (the identity matching in round 1) and its graph:
--   1. Take a random complex sort of that graph, and the earliest-provider skeleton (witnesses) of the hard mechanic pebbles
--   2. A trav's needs are the contexts in which the skeleton goes through the trav
--   3. A slot is admissible for a trav if its type and cost fit and, for each need, the slot has a pebble in that context ranked before the trav's; the trav's current slot is always admissible
--   4. Take a random perfect matching of the admissibility graph (it exists, since the current matching is one)
--   5. Gate: sort the new graph, and if a hard pebble was lost, add the blocked trav pebbles of its witness to the needs and redo 3-5
-- Needs only grow and the current matching always passes, so every round ends with a valid matching
-- Soundness: each hard pebble's witness still works with its trav steps now proven by earlier slot pebbles (by induction on rank), assuming monotone logic
-- The tech discovery rule isn't monotone, so first pass's own gate afterward still checks with a fresh sort and retries if needed

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local rng = require("lib/random/rng")
local protection = require("randomizations/graph/unified/skeleton/protection")

local key = gutils.key

local matching = {}

local function complex_sort(graph)
    return top.sort(graph, nil, nil, {
        choose_randomly = true,
        complex_contexts = true,
    })
end

-- Connect each slot to its assigned trav, the same way first pass's connect_slot_trav does
local function connect(graph, params, assignment)
    for slot_key, trav_key in pairs(assignment) do
        local slot = graph.nodes[slot_key]
        gutils.add_edge(graph, key(params.slot_to_base[slot_key]), key(params.trav_to_head[trav_key]))
        if slot.type == "item" and slot.op == "OR" then
            gutils.add_edge(graph, trav_key, slot_key)
        end
    end
    return graph
end

-- Hard pebbles: protected mechanic pebbles (see protection.lua), plus each reachable recipe's earliest pebble asking for no abilities (which only the gate checks)
local function hard_pebbles(graph, sort_info)
    local mechanics = {}
    local recipes = {}
    for node_key, context_inds in pairs(sort_info.node_to_context_inds) do
        local node = graph.nodes[node_key]
        if node ~= nil and node.mechanic and node.type ~= "orand" then
            for context, _ in pairs(context_inds) do
                if protection.is_hard_mechanic_pebble(node, context) then
                    table.insert(mechanics, {
                        node_key = node_key,
                        context = context,
                    })
                end
            end
        elseif node ~= nil and node.type == "recipe" then
            local best_context
            local best_ind
            for context, ind in pairs(context_inds) do
                if string.find(top.context_abilities(context) or "", "1", 1, true) == nil and (best_ind == nil or ind < best_ind) then
                    best_ind = ind
                    best_context = context
                end
            end
            if best_context ~= nil then
                table.insert(recipes, {
                    node_key = node_key,
                    context = best_context,
                })
            end
        end
    end
    return mechanics, recipes
end

-- Hard pebbles missing from the sort; a recipe only counts as lost if it has no pebble at all (recipes must stay reachable somewhere)
local function lost_pebbles(mechanics, recipes, sort_info)
    local lost = {}
    for _, pebble in pairs(mechanics) do
        if (sort_info.node_to_context_inds[pebble.node_key] or {})[pebble.context] == nil then
            table.insert(lost, pebble)
        end
    end
    for _, pebble in pairs(recipes) do
        if next(sort_info.node_to_context_inds[pebble.node_key] or {}) == nil then
            table.insert(lost, pebble)
        end
    end
    table.sort(lost, function(a, b) return a.node_key .. a.context < b.node_key .. b.context end)
    return lost
end

-- trav key --> set of contexts the skeleton of the given pebbles goes through the trav in
local function needs_from_skeleton(graph, sort_info, pebbles)
    local goal_inds = {}
    for _, pebble in pairs(pebbles) do
        local ind = (sort_info.node_to_context_inds[pebble.node_key] or {})[pebble.context]
        if ind ~= nil then
            table.insert(goal_inds, ind)
        end
    end
    local needs = {}
    for ind, _ in pairs(top.path(graph, goal_inds, sort_info).in_path) do
        local pebble = sort_info.sorted[ind]
        if graph.nodes[pebble.node_key].trav then
            needs[pebble.node_key] = needs[pebble.node_key] or {}
            needs[pebble.node_key][pebble.context] = true
        end
    end
    return needs
end

-- Random perfect matching of travs to admissible slots (Kuhn's algorithm with shuffled candidates, current slot tried last)
local function random_matching(params, graph, sort_info, needs, assignment, rng_key)
    local current_slot = {}
    local slots = {}
    local travs = {}
    for slot_key, trav_key in pairs(assignment) do
        current_slot[trav_key] = slot_key
        table.insert(slots, slot_key)
        table.insert(travs, trav_key)
    end
    table.sort(slots)
    table.sort(travs)
    local nci = sort_info.node_to_context_inds

    local admissible = {}
    for _, trav_key in pairs(travs) do
        local trav = graph.nodes[trav_key]
        admissible[trav_key] = {}
        for _, slot_key in pairs(slots) do
            if slot_key ~= current_slot[trav_key] then
                local slot = graph.nodes[slot_key]
                local is_admissible = slot.type == trav.type and params.cost_ok(slot, trav)
                if is_admissible then
                    for context, _ in pairs(needs[trav_key] or {}) do
                        local slot_ind = (nci[slot_key] or {})[context]
                        local trav_ind = (nci[trav_key] or {})[context]
                        if slot_ind == nil or trav_ind == nil or slot_ind >= trav_ind then
                            is_admissible = false
                            break
                        end
                    end
                end
                if is_admissible then
                    table.insert(admissible[trav_key], slot_key)
                end
            end
        end
    end

    local slot_match = {}
    local function try(trav_key, visited)
        local candidates = table.deepcopy(admissible[trav_key])
        rng.shuffle(rng_key, candidates)
        table.insert(candidates, current_slot[trav_key])
        for _, slot_key in pairs(candidates) do
            if not visited[slot_key] then
                visited[slot_key] = true
                if slot_match[slot_key] == nil or try(slot_match[slot_key], visited) then
                    slot_match[slot_key] = trav_key
                    return true
                end
            end
        end
        return false
    end
    local order = table.deepcopy(travs)
    rng.shuffle(rng_key, order)
    for _, trav_key in pairs(order) do
        if not try(trav_key, {}) then
            error("Monotone matching failed although the current matching is admissible")
        end
    end
    return slot_match
end

-- Trav pebbles on the witnesses (in the previous graph) of the lost pebbles that are missing from the new sort
local function blocked_travs(graph, sort_info, lost, new_sort)
    local blocked = {}
    for _, pebble in pairs(lost) do
        local ind = (sort_info.node_to_context_inds[pebble.node_key] or {})[pebble.context]
        if ind ~= nil then
            for i, _ in pairs(top.path(graph, { ind }, sort_info).in_path) do
                local q = sort_info.sorted[i]
                if graph.nodes[q.node_key].trav and (new_sort.node_to_context_inds[q.node_key] or {})[q.context] == nil then
                    blocked[q.node_key .. " @ " .. q.context] = q
                end
            end
        end
    end
    return blocked
end

-- params:
--   slot_keys: every slot
--   unconnected_graph: first pass's split graph with no slot/trav connections
--   slot_to_base, trav_to_head: first pass's connector nodes
--   cost_ok(slot, trav): whether the pair's costs fit
--   rounds: how many rounds to iterate (each starts from the last round's matching)
-- Returns slot key --> trav key
matching.run = function(params)
    local assignment = {}
    for _, slot_key in pairs(params.slot_keys) do
        assignment[slot_key] = params.unconnected_graph.nodes[slot_key].old_trav
    end
    local graph = connect(table.deepcopy(params.unconnected_graph), params, assignment)
    local sort_info = complex_sort(graph)
    local mechanics, recipes = hard_pebbles(graph, sort_info)
    log("Monotone matching: " .. #mechanics .. " hard mechanic pebbles, " .. #recipes .. " recipes")

    for round = 1, params.rounds do
        -- Recipes are left to the gate (needs from recipe anchors are too strict)
        local needs = needs_from_skeleton(graph, sort_info, mechanics)
        local num_refinements = 0
        local new_assignment
        local new_graph
        local new_sort
        while true do
            new_assignment = random_matching(params, graph, sort_info, needs, assignment, rng.key({ id = "monotone-matching-" .. round .. "-" .. num_refinements }))
            new_graph = connect(table.deepcopy(params.unconnected_graph), params, new_assignment)
            new_sort = complex_sort(new_graph)
            local lost = lost_pebbles(mechanics, recipes, new_sort)
            if #lost == 0 then
                break
            end
            local num_added = 0
            for _, q in pairs(blocked_travs(graph, sort_info, lost, new_sort)) do
                needs[q.node_key] = needs[q.node_key] or {}
                if needs[q.node_key][q.context] == nil then
                    needs[q.node_key][q.context] = true
                    num_added = num_added + 1
                end
            end
            num_refinements = num_refinements + 1
            log("Monotone matching: round " .. round .. " lost " .. #lost .. " hard pebbles (e.g. " .. lost[1].node_key .. " @ " .. lost[1].context .. "); added " .. num_added .. " needs")
            if num_added == 0 or num_refinements >= 10 then
                -- Nothing left to refine, so keep the previous matching (always valid)
                new_assignment = assignment
                new_graph = graph
                new_sort = sort_info
                break
            end
        end
        local num_moved = 0
        for slot_key, trav_key in pairs(new_assignment) do
            if params.unconnected_graph.nodes[trav_key].old_slot ~= slot_key then
                num_moved = num_moved + 1
            end
        end
        log("Monotone matching: round " .. round .. " done with " .. num_refinements .. " refinements; " .. num_moved .. " identities moved")
        assignment = new_assignment
        graph = new_graph
        sort_info = new_sort
    end
    return assignment
end

return matching
