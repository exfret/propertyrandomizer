-- Monotone matching for first pass: chooses which item identity (trav) goes in which item position (slot) all at once, instead of first pass's greedy forward fill
-- Based on the other session's report (scratchpad REPORT-multipass-complex-contexts.md) and its exp-iter.lua prototype
--
-- A round starts from a valid matching (the identity matching in round 1) and its graph:
--   1. Take a random complex sort of that graph, and prove every hard mechanic pebble in it (backings go to strictly earlier pebbles)
--   2. A trav's needs are the contexts in which those proofs use the identity (see needs_from_proof for which uses count)
--   3. A slot is admissible for a trav if its type and cost fit and, for each need, the slot has a pebble in that context ranked before the trav's; the trav's current slot is always admissible
--   4. Take a random perfect matching of the admissibility graph (it exists, since the current matching is one), and replace it by the one reflection realizes (params.realize)
--   5. Gate: sort the new graph, and if a hard pebble was lost, add the blocked trav pebbles of its witness to the needs and redo 3-5
-- Needs only grow and the current matching always passes, so every round ends with a valid matching
-- The proofs pick one provider per OR (the earliest that works), so an identity is only pinned where the proof actually uses it: another provider that comes first frees it in the next round
-- The gate is what guarantees the result; the proofs only make the proposals likely to pass
-- Sorts use home contexts, so the tech discovery rule is monotone too (see context-sort.lua); first pass's own gate afterward still checks with a fresh sort and retries if needed

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local rng = require("lib/random/rng")
local logic = require("lib/logic/init")
local protection = require("randomizations/graph/unified/skeleton/protection")

local key = gutils.key

local matching = {}

local function complex_sort(graph)
    return top.sort(graph, nil, nil, {
        choose_randomly = true,
        complex_contexts = true,
        home_contexts = true,
    })
end

-- Connect each slot to its assigned trav: slot base --> trav head, plus trav --> slot for items, since reflection makes them the same physical item (so the slot's consumers also get the trav's identity-based sources, like delivery and spoilage)
-- The slot_to_base and trav_to_head connectors come from params
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

-- Hard pebbles: protected mechanic pebbles (see protection.lua), plus each reachable recipe's earliest pebble asking for no abilities and not in a home context (which only the gate checks)
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
                if string.find(top.context_abilities(context) or "", "1", 1, true) == nil and top.context_home(context) == nil and (best_ind == nil or ind < best_ind) then
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

local function goal_inds_of(pebbles, sort_info)
    local goal_inds = {}
    for _, pebble in pairs(pebbles) do
        local ind = (sort_info.node_to_context_inds[pebble.node_key] or {})[pebble.context]
        if ind ~= nil then
            table.insert(goal_inds, ind)
        end
    end
    return goal_inds
end

----------------------------------------------------------------------------------------------------
-- Prover
----------------------------------------------------------------------------------------------------

-- Finds backings of pebbles in a sort: each pebble is proven by pebbles of strictly lower rank, as in promotion.lua's compute_support (without its recipe and head handling)
-- Unlike top.path, it backtracks, so when a provider's pebble can't be proven it falls back to other providers
local function make_prover(graph, sort_info)
    local sorted = sort_info.sorted
    local nci = sort_info.node_to_context_inds
    local memo = {}

    -- Nodes that discover each room (for the discovery rule), found when first needed
    local room_discoverers

    -- Ranks of the pebbles of an edge's start that get context through the edge, earliest first
    local function pre_inds(edge_key, context)
        local edge = graph.edges[edge_key]
        local context_inds = nci[edge.start] or {}
        if edge.abilities == nil then
            return { context_inds[context] }
        end
        local inds = {}
        for _, source in pairs(top.edge_source_contexts(sort_info, edge, context)) do
            if context_inds[source] ~= nil then
                table.insert(inds, context_inds[source])
            end
        end
        table.sort(inds)
        return inds
    end

    local establish

    local function back_with(ind, node, context)
        if node.op == "AND" then
            local support = {}
            for pre, _ in pairs(node.pre) do
                local found
                for _, i in pairs(pre_inds(pre, context)) do
                    if i < ind and establish(i) then
                        found = i
                        break
                    end
                end
                if found == nil then
                    return nil
                end
                table.insert(support, found)
            end
            return support
        end
        -- Earliest provider first, falling back to later ones
        local candidates = {}
        for pre, _ in pairs(node.pre) do
            for _, i in pairs(pre_inds(pre, context)) do
                if i < ind then
                    table.insert(candidates, i)
                end
            end
        end
        table.sort(candidates)
        for _, i in pairs(candidates) do
            if establish(i) then
                return { i }
            end
        end
        return nil
    end

    local function compute_support(ind)
        local pebble = sorted[ind]
        local node = graph.nodes[pebble.node_key]
        if next(node.pre) == nil then
            -- Sources: AND with no prereqs is vacuously satisfied, OR with none never is
            if node.op == "AND" then
                return {}
            end
            return nil
        end
        if logic.type_info[node.type].context == nil then
            return back_with(ind, node, pebble.context)
        end

        -- Forgetters and emitters can send out this pebble's context from other incoming contexts (see top.node_transmit)
        local contexts = {}
        for _, context in pairs(sort_info.contexts) do
            local transmits = false
            for _, outgoing in pairs(top.node_transmit(sort_info, node, context)) do
                if outgoing == pebble.context then
                    transmits = true
                    break
                end
            end
            if transmits then
                local score
                for pre, _ in pairs(node.pre) do
                    local i = pre_inds(pre, context)[1]
                    if node.op == "AND" then
                        if i == nil then
                            score = nil
                            break
                        end
                        score = math.max(score or 0, i)
                    elseif i ~= nil and (score == nil or i < score) then
                        score = i
                    end
                end
                if score ~= nil and score < ind then
                    table.insert(contexts, {
                        context = context,
                        score = score,
                    })
                end
            end
        end
        table.sort(contexts, function(a, b) return a.score < b.score end)
        for _, entry in pairs(contexts) do
            local support = back_with(ind, node, entry.context)
            if support ~= nil then
                return support
            end
        end

        -- Isolatable tech contexts can also come from the discovery rule (see top.discovery_candidates): an earlier pebble of the tech itself (in a home context of the room's home set) plus an earlier pebble of a discoverer of the room
        room_discoverers = room_discoverers or top.room_discoverers(graph)
        local candidates = top.discovery_candidates(sort_info, room_discoverers, node, pebble.context)
        if candidates ~= nil then
            local own_ind
            for _, i in pairs(candidates.own) do
                if i < ind and establish(i) then
                    own_ind = i
                    break
                end
            end
            if own_ind ~= nil then
                for _, i in pairs(candidates.discoverers) do
                    if i < ind and establish(i) then
                        return { own_ind, i }
                    end
                end
            end
        end
        return nil
    end

    establish = function(ind)
        local cached = memo[ind]
        if cached ~= nil then
            return cached ~= false
        end
        memo[ind] = false
        local support = compute_support(ind)
        if support ~= nil then
            memo[ind] = support
        end
        return support ~= nil
    end

    return {
        -- Proves the goals
        -- Returns the closure of their backings (ind --> true), each pebble's backing (ind --> list of inds), and the goals that couldn't be proven
        prove = function(goal_inds)
            memo = {}
            local closure = {}
            local failed = {}
            local stack = {}
            for _, goal in pairs(goal_inds) do
                if establish(goal) then
                    table.insert(stack, goal)
                else
                    table.insert(failed, goal)
                end
            end
            while #stack > 0 do
                local i = table.remove(stack)
                if not closure[i] then
                    closure[i] = true
                    for _, j in pairs(memo[i]) do
                        if not closure[j] then
                            table.insert(stack, j)
                        end
                    end
                end
            end
            return closure, memo, failed
        end,
    }
end

----------------------------------------------------------------------------------------------------
-- Needs
----------------------------------------------------------------------------------------------------

-- The nodes of each trav's launch chain: trav --> item-launch --> item-deliver --> orand --> trav (delivery to other rooms)
-- Returns node key --> the trav whose chain it's on
local function launch_chains(graph, travs)
    local chain_of = {}
    for _, trav_key in pairs(travs) do
        for dep, _ in pairs(graph.nodes[trav_key].dep) do
            local launch = graph.nodes[graph.edges[dep].stop]
            if launch.type == "item-launch" then
                chain_of[key(launch)] = trav_key
                for dep2, _ in pairs(launch.dep) do
                    local deliver = graph.nodes[graph.edges[dep2].stop]
                    if deliver.type == "item-deliver" then
                        chain_of[key(deliver)] = trav_key
                        for dep3, _ in pairs(deliver.dep) do
                            local mid = graph.nodes[graph.edges[dep3].stop]
                            if mid.type == "orand" then
                                chain_of[key(mid)] = trav_key
                            end
                        end
                    end
                end
            end
        end
    end
    return chain_of
end

-- Needs from a proof: trav key --> set of contexts, plus slot key --> true for slots whose delivered contents need a launchable trav
-- A trav pebble is a need only if its users lead to a real use of the identity
-- If its only use is delivering its own slot's contents to other rooms, the slot needs whatever trav it holds to be launchable instead, since reflection makes the slot's item that trav
-- Delivered contexts of a trav aren't needs themselves: they follow from its origin context through the same launch chain
local function needs_from_proof(graph, sort_info, closure, support, assignment, chain_of)
    local sorted = sort_info.sorted
    local users = {}
    for i, _ in pairs(closure) do
        for _, j in pairs(support[i]) do
            users[j] = users[j] or {}
            table.insert(users[j], i)
        end
    end
    local slot_of = {}
    for slot_key, trav_key in pairs(assignment) do
        slot_of[trav_key] = slot_key
    end

    local function is_delivered(q, trav_key)
        for _, j in pairs(support[q] or {}) do
            if chain_of[sorted[j].node_key] == trav_key then
                return true
            end
        end
        return false
    end

    local requires_launchable = {}
    local genuine = {}
    local function is_genuine(q, trav_key)
        if genuine[q] ~= nil then
            return genuine[q]
        end
        genuine[q] = false
        local result = false
        for _, u in pairs(users[q] or {}) do
            local u_key = sorted[u].node_key
            if u_key == slot_of[trav_key] then
                if is_delivered(q, trav_key) then
                    requires_launchable[u_key] = true
                else
                    result = true
                end
            elseif chain_of[u_key] == trav_key or u_key == trav_key then
                if is_genuine(u, trav_key) then
                    result = true
                end
            else
                result = true
            end
        end
        genuine[q] = result
        return result
    end

    local needs = {}
    for q, _ in pairs(closure) do
        local pebble = sorted[q]
        local node = graph.nodes[pebble.node_key]
        if node.trav and slot_of[pebble.node_key] ~= nil then
            if is_genuine(q, pebble.node_key) and not is_delivered(q, pebble.node_key) then
                needs[pebble.node_key] = needs[pebble.node_key] or {}
                needs[pebble.node_key][pebble.context] = true
            end
        end
    end
    return needs, requires_launchable
end

----------------------------------------------------------------------------------------------------
-- Matching
----------------------------------------------------------------------------------------------------

-- Whether a resource slot's trav makes the resource mine something new: an interesting trav (params.is_interesting) other than the slot's own identity
-- Reflection keeps interesting travs where the matching puts them, but doesn't swap two useless items (ores count as useless), so a useless trav usually leaves the resource as it was
local function is_new_resource_trav(params, slot_key, trav_key)
    return trav_key ~= params.unconnected_graph.nodes[slot_key].old_trav and params.is_interesting(trav_key)
end

-- Random perfect matching of travs to admissible slots (Kuhn's algorithm with shuffled candidates, current slot tried last)
-- With params.is_resource_slot, resource slots then get travs that make them mine something new (see is_new_resource_trav) wherever the matching allows it
-- Returns the matching
local function random_matching(params, graph, sort_info, needs, requires_launchable, assignment, rng_key)
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
                local is_admissible = slot.type == trav.type and params.pair_ok(slot, trav)
                if is_admissible and requires_launchable[slot_key] and not params.is_launchable(trav_key) then
                    is_admissible = false
                end
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

    -- Kuhn's algorithm around the prefilled pairs, which stay fixed; nil if some trav can't be matched
    local function complete(prefilled)
        local slot_match = {}
        local is_fixed = {}
        local is_matched = {}
        for slot_key, trav_key in pairs(prefilled) do
            slot_match[slot_key] = trav_key
            is_fixed[slot_key] = true
            is_matched[trav_key] = true
        end
        local function try(trav_key, visited)
            local candidates = table.deepcopy(admissible[trav_key])
            rng.shuffle(rng_key, candidates)
            table.insert(candidates, current_slot[trav_key])
            for _, slot_key in pairs(candidates) do
                if not visited[slot_key] and not is_fixed[slot_key] then
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
            if not is_matched[trav_key] and not try(trav_key, {}) then
                return nil
            end
        end
        return slot_match
    end

    local resource_slots = {}
    if params.is_resource_slot ~= nil then
        for _, slot_key in pairs(slots) do
            if params.is_resource_slot(slot_key) then
                table.insert(resource_slots, slot_key)
            end
        end
    end

    -- Resource slots that already mine something new keep their travs, so later rounds never lose that (the current matching has all these pairs at once, so this can't fail)
    local prefilled = {}
    local is_taken = {}
    for _, slot_key in pairs(resource_slots) do
        if is_new_resource_trav(params, slot_key, assignment[slot_key]) then
            prefilled[slot_key] = assignment[slot_key]
            is_taken[assignment[slot_key]] = true
        end
    end
    -- Each other resource slot takes a random admissible new trav (see is_new_resource_trav) if a perfect matching still exists with it
    -- Left to Kuhn's algorithm instead, resource slots would mostly get the early identities whose only other admissible slots they are
    local admitted_travs = {}
    for _, trav_key in pairs(travs) do
        for _, slot_key in pairs(admissible[trav_key]) do
            admitted_travs[slot_key] = admitted_travs[slot_key] or {}
            table.insert(admitted_travs[slot_key], trav_key)
        end
    end
    rng.shuffle(rng_key, resource_slots)
    for _, slot_key in pairs(resource_slots) do
        if prefilled[slot_key] == nil then
            local candidates = {}
            for _, trav_key in pairs(admitted_travs[slot_key] or {}) do
                if not is_taken[trav_key] and is_new_resource_trav(params, slot_key, trav_key) then
                    table.insert(candidates, trav_key)
                end
            end
            rng.shuffle(rng_key, candidates)
            -- A few tries are enough: when the first fails, the rest usually do too (the slot's own trav can't move), and the repair below handles that
            for i = 1, math.min(#candidates, 5) do
                prefilled[slot_key] = candidates[i]
                if complete(prefilled) ~= nil then
                    is_taken[candidates[i]] = true
                    break
                end
                prefilled[slot_key] = nil
            end
        end
    end
    local slot_match = complete(prefilled)
    if slot_match == nil then
        error("Monotone matching failed although every prefilled pair was checked")
    end

    -- Then each resource slot still without a new trav gets one if some perfect matching allows it while every resource slot that mines something new keeps doing so
    -- It searches breadth-first for a cycle of moves through the slot: the trav at a slot moves to a slot it's admissible for, and that slot's trav moves on, until one can move into the resource slot as a new trav
    -- A resource slot that mines something new only takes travs that keep it so, which still lets a trav whose needs pin it to early slots move to another resource slot and free its own
    local is_admissible = {}
    for _, trav_key in pairs(travs) do
        is_admissible[trav_key] = {
            [current_slot[trav_key]] = true,
        }
        for _, slot_key in pairs(admissible[trav_key]) do
            is_admissible[trav_key][slot_key] = true
        end
    end
    local function keeps_resources_new(trav_key, slot_key)
        return not params.is_resource_slot(slot_key) or not is_new_resource_trav(params, slot_key, slot_match[slot_key]) or is_new_resource_trav(params, slot_key, trav_key)
    end
    for _, resource_slot in pairs(resource_slots) do
        if not is_new_resource_trav(params, resource_slot, slot_match[resource_slot]) then
            -- Slot --> the slot whose trav moves into it
            local prev = {
                [resource_slot] = resource_slot,
            }
            local queue = { resource_slot }
            local last
            local i = 1
            while i <= #queue and last == nil do
                local trav_key = slot_match[queue[i]]
                local options = table.deepcopy(admissible[trav_key])
                table.insert(options, current_slot[trav_key])
                rng.shuffle(rng_key, options)
                for _, slot_key in pairs(options) do
                    if prev[slot_key] == nil and keeps_resources_new(trav_key, slot_key) then
                        prev[slot_key] = queue[i]
                        local closing = slot_match[slot_key]
                        if is_admissible[closing][resource_slot] and is_new_resource_trav(params, resource_slot, closing) then
                            last = slot_key
                            break
                        end
                        table.insert(queue, slot_key)
                    end
                end
                i = i + 1
            end
            if last ~= nil then
                -- Each slot on the cycle takes the trav of the slot before it, and the resource slot takes the last slot's
                local closing = slot_match[last]
                local slot_key = last
                while slot_key ~= resource_slot do
                    slot_match[slot_key] = slot_match[prev[slot_key]]
                    slot_key = prev[slot_key]
                end
                slot_match[resource_slot] = closing
            end
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

-- The matching the game will actually have: params.realize (optional) maps a matching to the one reflection realizes, which is what gets gated and returned
-- The result is still a perfect matching, and realizing the identity matching gives it back, so the "current matching always passes" argument still holds
local function realize(params, assignment)
    if params.realize == nil then
        return assignment
    end
    return params.realize(assignment)
end

matching.connect = connect
-- For tests (test-monotone-matching.lua)
matching.random_matching = random_matching

-- params:
--   slot_keys: every slot
--   unconnected_graph: first pass's split graph with no slot/trav connections
--   slot_to_base, trav_to_head: first pass's connector nodes
--   pair_ok(slot, trav): whether the trav can go in the slot (their costs fit, and item reflection's special rules allow it)
--   rounds: how many rounds to iterate (each starts from the last round's matching)
--   is_resource_slot(slot_key), is_interesting(trav_key) (optional): see random_matching
--   realize(assignment) (optional): the matching the game will actually have, which is what gets gated and returned
-- Returns slot key --> trav key
matching.run = function(params)
    local assignment = {}
    local travs = {}
    for _, slot_key in pairs(params.slot_keys) do
        assignment[slot_key] = params.unconnected_graph.nodes[slot_key].old_trav
        table.insert(travs, assignment[slot_key])
    end
    table.sort(travs)
    local graph = connect(table.deepcopy(params.unconnected_graph), params, assignment)
    local sort_info = complex_sort(graph)
    local mechanics, recipes = hard_pebbles(graph, sort_info)
    log("Monotone matching: " .. #mechanics .. " hard mechanic pebbles, " .. #recipes .. " recipes")

    -- Launch chains and launchability are properties of the travs themselves, so they're the same in every round
    local chain_of = launch_chains(graph, travs)
    local is_launchable = {}
    for node_key, trav_key in pairs(chain_of) do
        if graph.nodes[node_key].type == "item-launch" then
            is_launchable[trav_key] = true
        end
    end
    params.is_launchable = function(trav_key)
        return is_launchable[trav_key] == true
    end

    for round = 1, params.rounds do
        -- Recipes are left to the gate (needs from recipe anchors are too strict)
        local closure, support, failed = make_prover(graph, sort_info).prove(goal_inds_of(mechanics, sort_info))
        if #failed > 0 then
            -- Those pebbles get no needs, so the gate is all that protects them this round
            log("Monotone matching: round " .. round .. " couldn't prove " .. #failed .. " hard pebbles in its own sort")
        end
        local needs, requires_launchable = needs_from_proof(graph, sort_info, closure, support, assignment, chain_of)
        local num_refinements = 0
        local new_assignment
        local new_graph
        local new_sort
        while true do
            new_assignment = random_matching(params, graph, sort_info, needs, requires_launchable, assignment, rng.key({ id = "monotone-matching-" .. round .. "-" .. num_refinements }))
            new_assignment = realize(params, new_assignment)
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
        local num_resources = 0
        local num_new_resources = 0
        for slot_key, trav_key in pairs(new_assignment) do
            if params.unconnected_graph.nodes[trav_key].old_slot ~= slot_key then
                num_moved = num_moved + 1
            end
            if params.is_resource_slot ~= nil and params.is_resource_slot(slot_key) then
                num_resources = num_resources + 1
                if is_new_resource_trav(params, slot_key, trav_key) then
                    num_new_resources = num_new_resources + 1
                end
            end
        end
        log("Monotone matching: round " .. round .. " done with " .. num_refinements .. " refinements; " .. num_moved .. " identities moved; " .. num_new_resources .. " of " .. num_resources .. " resource slots mine something new")
        assignment = new_assignment
        graph = new_graph
        sort_info = new_sort
    end
    return assignment
end

return matching
