-- Monotone matching for first pass: chooses which item identity (trav) goes in which item position (slot) all at once, instead of first pass's greedy forward fill
-- Based on the other session's report (scratchpad REPORT-multipass-complex-contexts.md) and its exp-iter.lua prototype
--
-- A round starts from a valid matching (the identity matching in round 1) and its graph:
--   1. Take a random complex sort of that graph, and prove every pebble that must keep its exact context in it (protected mechanics and planet-locked recipes; backings go to strictly earlier pebbles)
--   2. A trav's needs are the contexts in which those proofs use the identity (see needs_from_proof for which uses count)
--   3. A slot is admissible for a trav if its type and cost fit and, for each need, the slot has a pebble in that context ranked before the trav's, not counting what the trav it holds now brings it (see position_backing); the trav's current slot is always admissible
--   4. Take a random perfect matching of the admissibility graph (it exists, since the current matching is one), and replace it by the one reflection realizes (params.realize)
--   5. Gate: sort the new graph, and if a hard pebble was lost, add the blocked trav pebbles of its witness (and of what backs the new slots of blocked travs that moved) to the needs and redo 3-5
-- Needs only grow and the current matching always passes, so every round ends with a valid matching
-- A round whose refinements run out keeps the previous matching; rounds go on until params.rounds of them kept a new one, or as many kept the previous one (then a MATCHINGFLAG line says so)
-- The proofs pick one provider per OR (the earliest that works), so an identity is only pinned where the proof actually uses it: another provider that comes first frees it in the next round
-- The gate is what guarantees the result; the proofs only make the proposals likely to pass
-- Sorts use home contexts, so the tech discovery rule is monotone too (see context-sort.lua); first pass's own gate afterward still checks with a fresh sort and retries if needed

local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
local rng = require("src/lib/random/rng")
local logic = require("src/logic/init")
local protection = require("src/randomizations/unified/skeleton/protection")

local bipartite = require("src/lib/graph/bipartite-matching")
local refinement = require("src/lib/graph/matching-refinement")

local key = gutils.key

local matching = {}

local function complex_sort(graph)
    return top.sort(graph, nil, nil, {
        choose_randomly = true,
        complex_contexts = true,
        home_contexts = true,
    })
end

-- How a slot connects to a trav: params.connection(slot_key, trav_key) (optional) gives { base = the node the connection starts at (the slot's base if nil), abilities = what getting through it gains or loses (see src/lib/sort/context-sort.lua) }, or nil for the plain connection
-- Entity positions use it: a built entity found in the wild or looted can't be automated, and one carried by a unit also takes killing the carrier (see handlers/entity.lua)
local function connection_of(params, slot_key, trav_key)
    local connection
    if params.connection ~= nil then
        connection = params.connection(slot_key, trav_key)
    end
    return connection or {}
end

-- Connect each slot to its assigned trav: slot base --> trav head, plus trav --> slot for items, since reflection makes them the same physical item (so the slot's consumers also get the trav's identity-based sources, like delivery and spoilage)
-- A fluid position (a fluid-temperature node, an AND of being made and being held, see src/logic/builders/concrete.lua) gets the same back edge into its making (fluid-create-temperature): its consumers can then use the identity's own sources too, pumping and barrels for a fluid identity (src/randomizations/unified/item-fluid.lua moves those to the identity) or delivery for an item identity, which is how a recipe locked to a planet that doesn't make the fluid still gets it there
-- Only when the trav is an OR node (an item, or a fluid with sources of its own): a fluid trav without them is an AND node fed by its head alone, so the edge would add nothing but a cycle through AND nodes, which needs derivation can't follow
-- The slot_to_base and trav_to_head connectors come from params, and params.connect_extra(graph, slot_key, trav_key) (optional) connects anything else that follows the pair
-- params.connect_after(graph, assignment) (optional) then changes what follows the whole matching, not one pair alone
local function connect(graph, params, assignment)
    for slot_key, trav_key in pairs(assignment) do
        local slot = graph.nodes[slot_key]
        local connection = connection_of(params, slot_key, trav_key)
        local extra
        if connection.abilities ~= nil then
            extra = {
                abilities = table.deepcopy(connection.abilities),
            }
        end
        gutils.add_edge(graph, connection.base or key(params.slot_to_base[slot_key]), key(params.trav_to_head[trav_key]), extra)
        if slot.type == "item" and slot.op == "OR" then
            gutils.add_edge(graph, trav_key, slot_key)
        elseif slot.type == "fluid-temperature" and graph.nodes[trav_key].op == "OR" then
            for pre, _ in pairs(slot.pre) do
                local prenode = gutils.prenode(graph, pre)
                if prenode.type == "fluid-create-temperature" then
                    gutils.add_edge(graph, trav_key, key(prenode))
                end
            end
        end
        if params.connect_extra ~= nil then
            params.connect_extra(graph, slot_key, trav_key)
        end
    end
    if params.connect_after ~= nil then
        params.connect_after(graph, assignment)
    end
    return graph
end

-- Hard pebbles, in two lists:
--   * exact: protected mechanic pebbles, and every pebble of a recipe locked to one planet (see protection.lua), which must keep their exact contexts
--   * recipes: each reachable recipe's earliest pebble asking for no abilities and not in a home context, which only has to stay reachable somewhere (and only the gate checks)
-- params.recipe_may_vanish(node_key) (optional) names recipes that may become unreachable, like the recycling recipes of a position a fluid takes (see src/randomizations/unified/item-fluid.lua rewire_form_change): the game regenerates them for the item identity under the same name
local function hard_pebbles(graph, sort_info, params)
    local exact = {}
    local recipes = {}
    local locked = protection.planet_locked_recipe_contexts(graph, sort_info)
    for node_key, contexts in pairs(locked) do
        for context, _ in pairs(contexts) do
            table.insert(exact, {
                node_key = node_key,
                context = context,
            })
        end
    end
    for node_key, context_inds in pairs(sort_info.node_to_context_inds) do
        local node = graph.nodes[node_key]
        if node ~= nil and node.mechanic and node.type ~= "orand" then
            for context, _ in pairs(context_inds) do
                if protection.is_hard_mechanic_pebble(node, context) then
                    table.insert(exact, {
                        node_key = node_key,
                        context = context,
                    })
                end
            end
        elseif node ~= nil and node.type == "recipe" and not (params ~= nil and params.recipe_may_vanish ~= nil and params.recipe_may_vanish(node_key)) then
            local best_context
            local best_ind
            for context, ind in pairs(context_inds) do
                local mask = top.context_mask(context)
                if (mask == nil or mask == top.NO_ABILITIES) and top.context_home(context) == nil and (best_ind == nil or ind < best_ind) then
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
    return exact, recipes
end

-- Hard pebbles missing from the sort; a recipe only counts as lost if it has no pebble at all (recipes must stay reachable somewhere)
local function lost_pebbles(exact, recipes, sort_info)
    local lost = {}
    for _, pebble in pairs(exact) do
        if (sort_info.node_to_context_inds[pebble.node_key] or {})[pebble.context] == nil then
            table.insert(lost, pebble)
        end
    end
    for _, pebble in pairs(recipes) do
        if next(sort_info.node_to_context_inds[pebble.node_key] or {}) == nil then
            table.insert(lost, pebble)
        end
    end
    table.sort(lost, top.pebble_order)
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
    local pebble_keys = sort_info.pebble_keys
    local pebble_contexts = sort_info.pebble_contexts
    local nci = sort_info.node_to_context_inds
    local memo = {}

    -- Nodes that discover each room (for the discovery rule), found when first needed
    local room_discoverers

    -- Ranks of the pebbles of an edge's start that get context through the edge, earliest first
    local function pre_inds(edge_key, context)
        local edge = graph.edges[edge_key]
        local context_inds = nci[edge.start] or {}
        if edge.abilities == nil and top.edge_keeps_context(sort_info, edge, context) then
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
        local pebble_context = pebble_contexts[ind]
        local node = graph.nodes[pebble_keys[ind]]
        if next(node.pre) == nil then
            -- Sources: AND with no prereqs is vacuously satisfied, OR with none never is
            if node.op == "AND" then
                return {}
            end
            return nil
        end
        if logic.type_info[node.type].context == nil then
            return back_with(ind, node, pebble_context)
        end

        -- Forgetters and emitters can send out this pebble's context from other incoming contexts (see top.node_transmit)
        local contexts = {}
        for _, context in pairs(sort_info.contexts) do
            local transmits = false
            for _, outgoing in pairs(top.node_transmit(sort_info, node, context)) do
                if outgoing == pebble_context then
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
        local candidates = top.discovery_candidates(sort_info, room_discoverers, node, pebble_context)
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
    local pebble_keys = sort_info.pebble_keys
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
            if chain_of[pebble_keys[j]] == trav_key then
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
            local u_key = pebble_keys[u]
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
        local node_key = pebble_keys[q]
        local node = graph.nodes[node_key]
        if node.trav == true and slot_of[node_key] ~= nil then
            if is_genuine(q, node_key) and not is_delivered(q, node_key) then
                needs[node_key] = needs[node_key] or {}
                needs[node_key][sort_info.pebble_contexts[q]] = true
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
-- params.is_new_resource_pair(slot_key, trav_key) (optional) can ask for more, like a trav new to the planets mining the slot (independent deposits)
local function is_new_resource_trav(params, slot_key, trav_key)
    return trav_key ~= params.unconnected_graph.nodes[slot_key].old_trav and params.is_interesting(trav_key) and (params.is_new_resource_pair == nil or params.is_new_resource_pair(slot_key, trav_key))
end

-- Where a slot gets a context for a trav moving in: the earliest pebble of the connection's start (see connection_of) in a context that arrives in the given one through it
-- The edges from the trav the slot holds now (connect's back edge, into a fluid position's making for a fluid) don't count, since they're that identity's own sources and leave with it
-- Seen on seed 1 (2026-10-12): the artificial jellynut soil position had Fulgora's isolatable context only from the stone brick identity it held, so an identity needing that context moved there and lost it, and refinement had nothing to pin.
-- The memo (optional) is a table for one graph and matching, which keeps what each slot's own sources give it
-- Returns the start's rank in the sort and the pebbles that back it without the held trav (just that pebble when the held trav adds nothing to it), or nil if there are none
local function position_backing(params, graph, sort_info, assignment, slot_key, trav_key, context, memo)
    local nci = sort_info.node_to_context_inds
    local connection = connection_of(params, slot_key, trav_key)
    local start_key = connection.base or slot_key
    local sources = { context }
    if connection.abilities ~= nil then
        sources = top.edge_source_contexts(sort_info, connection, context)
    end
    local start_inds = nci[start_key] or {}
    local start_ind
    local start_context
    for _, source in pairs(sources) do
        if start_inds[source] ~= nil and (start_ind == nil or start_inds[source] < start_ind) then
            start_ind = start_inds[source]
            start_context = source
        end
    end
    if start_ind == nil then
        return nil
    end
    -- A carrier's base (an entity position's connection) isn't the slot, so the held trav has no edge into it
    if connection.base ~= nil then
        return start_ind, { start_ind }
    end
    if memo ~= nil then
        memo[slot_key] = memo[slot_key] or {}
        local cached = memo[slot_key][start_context]
        if cached ~= nil then
            if cached == false then
                return nil
            end
            return start_ind, cached
        end
    end

    local held = assignment[slot_key]
    local function has_held_edge(node)
        for pre, _ in pairs(node.pre or {}) do
            if graph.edges[pre].start == held then
                return true
            end
        end
        return false
    end
    -- The earliest pebble of an edge's start that brings the context through it
    local function edge_ind(edge_key)
        local edge = graph.edges[edge_key]
        local context_inds = nci[edge.start] or {}
        if edge.abilities == nil and top.edge_keeps_context(sort_info, edge, start_context) then
            return context_inds[start_context]
        end
        local best
        for _, source in pairs(top.edge_source_contexts(sort_info, edge, start_context)) do
            if context_inds[source] ~= nil and (best == nil or context_inds[source] < best) then
                best = context_inds[source]
            end
        end
        return best
    end
    -- An OR node's earliest prerequisite other than the held trav (slot nodes and a fluid's making keep their contexts)
    local function or_backing(node)
        local best
        for pre, _ in pairs(node.pre) do
            if graph.edges[pre].start ~= held then
                local i = edge_ind(pre)
                if i ~= nil and (best == nil or i < best) then
                    best = i
                end
            end
        end
        return best
    end
    local start = graph.nodes[start_key]
    local backing = { start_ind }
    if start.op == "OR" and has_held_edge(start) then
        backing = { or_backing(start) }
        if backing[1] == nil then
            backing = false
        end
    elseif start.op == "AND" then
        -- A fluid position: each prerequisite, its making without the held trav
        local makings = {}
        for pre, _ in pairs(start.pre or {}) do
            local prenode = gutils.prenode(graph, pre)
            if prenode.op == "OR" and has_held_edge(prenode) then
                makings[pre] = prenode
            end
        end
        if next(makings) ~= nil then
            backing = {}
            for pre, _ in pairs(start.pre) do
                local i
                if makings[pre] ~= nil then
                    i = or_backing(makings[pre])
                else
                    i = edge_ind(pre)
                end
                if i == nil then
                    backing = false
                    break
                end
                table.insert(backing, i)
            end
        end
    end
    if memo ~= nil then
        memo[slot_key][start_context] = backing
    end
    if backing == false then
        return nil
    end
    return start_ind, backing
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
    local backing_memo = {}

    local admissible = {}
    for _, trav_key in pairs(travs) do
        local trav = graph.nodes[trav_key]
        admissible[trav_key] = {}
        for _, slot_key in pairs(slots) do
            if slot_key ~= current_slot[trav_key] then
                local slot = graph.nodes[slot_key]
                -- Slots take travs of their own type, or of another type where params.cross_type_ok allows it (items and fluids trading positions, see src/randomizations/unified/item-fluid.lua)
                local is_admissible = (slot.type == trav.type or (params.cross_type_ok ~= nil and params.cross_type_ok(slot, trav))) and params.pair_ok(slot, trav)
                if is_admissible and requires_launchable[slot_key] and not params.is_launchable(trav_key) then
                    is_admissible = false
                end
                if is_admissible then
                    -- Ranks are the connection's: its start (the slot unless the connection says otherwise) in any context that arrives in the need's through it, and what backs that without the trav the slot holds now (see position_backing)
                    for context, _ in pairs(needs[trav_key] or {}) do
                        local trav_ind = (nci[trav_key] or {})[context]
                        local slot_ind, backing = position_backing(params, graph, sort_info, assignment, slot_key, trav_key, context, backing_memo)
                        if slot_ind == nil or trav_ind == nil or slot_ind >= trav_ind then
                            is_admissible = false
                            break
                        end
                        for _, i in pairs(backing) do
                            if i >= trav_ind then
                                is_admissible = false
                                break
                            end
                        end
                        if not is_admissible then
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

    -- Keep ordering and random draws here; the shared matcher only follows candidates.
    local function copy_list(list)
        local copy = {}
        for i, value in pairs(list) do copy[i] = value end
        return copy
    end
    local function complete(prefilled)
        local order = copy_list(travs)
        rng.shuffle(rng_key, order)
        return bipartite.complete({
            order = order,
            fixed = prefilled,
            candidates = function(trav_key)
                local candidates = copy_list(admissible[trav_key])
                rng.shuffle(rng_key, candidates)
                table.insert(candidates, current_slot[trav_key])
                return candidates
            end,
        })
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
                        if is_admissible[closing][resource_slot] == true and is_new_resource_trav(params, resource_slot, closing) then
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

-- How many lost pebbles blocked_travs looks at: the earliest ones (in the previous sort) are the roots of the loss, and the rest follow from them
local BLOCKED_PEBBLES_LIMIT = 300

-- Trav pebbles on the witnesses (in the previous graph) of the lost pebbles that are missing from the new sort
-- A missing trav pebble that moved now gets its context through its new slot, so the witnesses of what backs that slot (see position_backing) count too
-- Without them, a pinned trav whose new slot lost the context only blocks itself, which is pinned already, and the round gives up with nothing added.
local function blocked_travs(params, graph, sort_info, assignment, lost, new_assignment, new_sort)
    local blocked = {}
    local new_slot_of = {}
    for slot_key, trav_key in pairs(new_assignment) do
        new_slot_of[trav_key] = slot_key
    end
    local earliest = {}
    for _, pebble in pairs(lost) do
        local ind = (sort_info.node_to_context_inds[pebble.node_key] or {})[pebble.context]
        if ind ~= nil then
            table.insert(earliest, ind)
        end
    end
    table.sort(earliest)
    if #earliest > BLOCKED_PEBBLES_LIMIT then
        log("Monotone matching: witnesses of the " .. BLOCKED_PEBBLES_LIMIT .. " earliest of " .. #earliest .. " lost pebbles")
    end
    for n = #earliest, BLOCKED_PEBBLES_LIMIT + 1, -1 do
        earliest[n] = nil
    end
    -- Only the union of the witnesses matters. Trace them together so shared prerequisites are visited once (top.path picks the same backing regardless of the other goals).
    local traced = {}
    local goals = earliest
    while #goals > 0 do
        local next_goals = {}
        for i, _ in pairs(top.path(graph, goals, sort_info).in_path) do
            if traced[i] == nil then
                traced[i] = true
                local node_key = sort_info.pebble_keys[i]
                local context = sort_info.pebble_contexts[i]
                if graph.nodes[node_key].trav == true and (new_sort.node_to_context_inds[node_key] or {})[context] == nil then
                    blocked[node_key .. " @ " .. context] = {
                        node_key = node_key,
                        context = context,
                    }
                    local slot_key = new_slot_of[node_key]
                    if slot_key ~= nil and assignment[slot_key] ~= node_key then
                        local _, backing = position_backing(params, graph, sort_info, assignment, slot_key, node_key, context)
                        for _, j in pairs(backing or {}) do
                            if traced[j] == nil then
                                table.insert(next_goals, j)
                            end
                        end
                    end
                end
            end
        end
        goals = next_goals
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
-- For tests (test-monotone-matching.lua, test-replacement-fuel.lua)
matching.random_matching = random_matching
matching.make_prover = make_prover
matching.launch_chains = launch_chains
matching.needs_from_proof = needs_from_proof
-- For first pass's trades between items and fluids, which judge resource slots by the same rule
matching.is_new_resource_trav = is_new_resource_trav

-- Orders form trade candidates (see params.form_swaps in matching.run), in the order given: those that make a resource slot mine something new first (at most first_tries for each such slot, 1 when nil), then preferred ones, then the rest
-- Returns the ordered candidates, how many come first, for how many resource slots, and how many preferred ones follow them
local function order_form_swaps(candidates, first_tries)
    local ordered = {}
    local is_ordered = {}
    local tries = {}
    local num_first_slots = 0
    for i = 1, #candidates do
        local slot_key = candidates[i].first_for
        if slot_key ~= nil then
            if tries[slot_key] == nil then
                tries[slot_key] = 0
                num_first_slots = num_first_slots + 1
            end
            if tries[slot_key] < (first_tries or 1) then
                tries[slot_key] = tries[slot_key] + 1
                table.insert(ordered, candidates[i])
                is_ordered[i] = true
            end
        end
    end
    local num_first = #ordered
    for i = 1, #candidates do
        if not is_ordered[i] and candidates[i].preferred == true then
            table.insert(ordered, candidates[i])
            is_ordered[i] = true
        end
    end
    local num_preferred = #ordered - num_first
    for i = 1, #candidates do
        if not is_ordered[i] then
            table.insert(ordered, candidates[i])
        end
    end
    return ordered, num_first, num_first_slots, num_preferred
end
matching.order_form_swaps = order_form_swaps

-- How many resource slots (params.is_resource_slot) an assignment has, and how many of them mine something new (is_new_resource_trav)
local function count_new_resources(params, assignment)
    local num_resources = 0
    local num_new = 0
    if params.is_resource_slot == nil then
        return num_resources, num_new
    end
    for slot_key, trav_key in pairs(assignment) do
        if params.is_resource_slot(slot_key) then
            num_resources = num_resources + 1
            if is_new_resource_trav(params, slot_key, trav_key) then
                num_new = num_new + 1
            end
        end
    end
    return num_resources, num_new
end

-- params:
--   slot_keys: every slot
--   unconnected_graph: first pass's split graph with no slot/trav connections
--   slot_to_base, trav_to_head: first pass's connector nodes
--   pair_ok(slot, trav): whether the trav can go in the slot (their costs fit, and item reflection's special rules allow it)
--   cross_type_ok(slot, trav) (optional): whether a trav can go in a slot of another node type at all (pair_ok still has to allow it too); without it, slots only take travs of their own type
--   rounds: how many rounds should keep a new matching (each starts from the last round's matching)
--   max_failed_rounds (optional, rounds when nil): how many rounds may keep the previous matching instead before the rounds stop anyway
--   is_resource_slot(slot_key), is_interesting(trav_key) (optional): see random_matching
--   recipe_may_vanish(node_key) (optional): recipes the gate doesn't hold on to (see hard_pebbles)
--   realize(assignment) (optional): the matching the game will actually have, which is what gets gated and returned
--   connection(slot_key, trav_key) (optional): where the connection of a slot/trav pair starts and what abilities it gains or loses (see connection_of)
--   connect_extra(graph, slot_key, trav_key) (optional): connects anything else that follows a slot/trav pair (see connect)
--   connect_after(graph, assignment) (optional): changes what follows the whole matching (see connect)
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
    local exact, recipes = hard_pebbles(graph, sort_info, params)
    log("Monotone matching: " .. #exact .. " hard pebbles kept exactly (mechanics and planet-locked recipes), " .. #recipes .. " recipes")

    -- Launch chains and launchability are properties of the travs themselves, so they're the same in every round
    -- Launchable means deliverable: an item that spoils before a trip is over can be launched (for launch results) but has no item-deliver node
    local chain_of = launch_chains(graph, travs)
    local is_launchable = {}
    for node_key, trav_key in pairs(chain_of) do
        if graph.nodes[node_key].type == "item-deliver" then
            is_launchable[trav_key] = true
        end
    end
    params.is_launchable = function(trav_key)
        return is_launchable[trav_key] == true
    end

    -- Rounds go on until params.rounds of them kept a new matching, or params.max_failed_rounds kept the previous one because their proposals kept losing hard pebbles (user, 2026-10-12: a round that does nothing is as bad as a failure)
    local max_failed_rounds = params.max_failed_rounds or params.rounds
    local num_kept_rounds = 0
    local num_failed_rounds = 0
    local round = 0
    while num_kept_rounds < params.rounds and num_failed_rounds < max_failed_rounds do
        round = round + 1
        -- Recipe anchors are left to the gate (their needs would be too strict), but planet-locked recipes keep exact contexts, so they're proved like mechanics
        local closure, support, failed = make_prover(graph, sort_info).prove(goal_inds_of(exact, sort_info))
        if #failed > 0 then
            -- Those pebbles get no needs, so the gate is all that protects them this round
            log("Monotone matching: round " .. round .. " couldn't prove " .. #failed .. " hard pebbles in its own sort")
        end
        local needs, requires_launchable = needs_from_proof(graph, sort_info, closure, support, assignment, chain_of)
        local new_assignment, result, stats = refinement.run({
            current = assignment,
            current_result = {graph = graph, sort = sort_info},
            max_refinements = 10,
            propose = function(num_refinements)
                return realize(params, random_matching(params, graph, sort_info, needs, requires_launchable, assignment, rng.key({ id = "monotone-matching-" .. round .. "-" .. num_refinements })))
            end,
            validate = function(candidate)
                local candidate_graph = connect(table.deepcopy(params.unconnected_graph), params, candidate)
                local candidate_sort = complex_sort(candidate_graph)
                local lost = lost_pebbles(exact, recipes, candidate_sort)
                return #lost == 0, {graph = candidate_graph, sort = candidate_sort, lost = lost}
            end,
            refine = function(candidate, trial)
                local blocked = blocked_travs(params, graph, sort_info, assignment, trial.lost, candidate, trial.sort)
                local num_added = 0
                for _, q in pairs(blocked) do
                    needs[q.node_key] = needs[q.node_key] or {}
                    if needs[q.node_key][q.context] == nil then
                        needs[q.node_key][q.context] = true
                        num_added = num_added + 1
                    end
                end
                local example = trial.lost[1]
                log("Monotone matching: round " .. round .. " lost " .. #trial.lost .. " hard pebbles (e.g. " .. example.node_key .. " @ " .. top.context_name(example.context) .. "); added " .. num_added .. " needs")
                return num_added
            end,
        })
        local new_graph, new_sort = result.graph, result.sort
        local num_refinements, round_failed = stats.refinements, not stats.accepted
        local num_moved = 0
        for slot_key, trav_key in pairs(new_assignment) do
            if params.unconnected_graph.nodes[trav_key].old_slot ~= slot_key then
                num_moved = num_moved + 1
            end
        end
        local num_resources, num_new_resources = count_new_resources(params, new_assignment)
        if round_failed then
            num_failed_rounds = num_failed_rounds + 1
        else
            num_kept_rounds = num_kept_rounds + 1
        end
        log("Monotone matching: round " .. round .. " done with " .. num_refinements .. " refinements, " .. (round_failed and "kept the previous matching" or "kept a new matching") .. "; " .. num_moved .. " identities moved; " .. num_new_resources .. " of " .. num_resources .. " resource slots mine something new")
        assignment = new_assignment
        graph = new_graph
        sort_info = new_sort
    end
    if num_failed_rounds >= max_failed_rounds then
        log("MATCHINGFLAG Monotone matching: " .. num_failed_rounds .. " rounds kept the previous matching and only " .. num_kept_rounds .. " kept a new one, so first pass moved less than it should have")
    end

    -- Positions of different forms trade identities afterwards (params.form_swaps, items and fluids trading positions, see src/randomizations/unified/item-fluid.lua): such a trade moves recipes to other crafters, which the needs above can't repair, so trades are gated like a round and kept only when nothing is lost
    -- Each trial gates a batch of trades with one sort (most trades pass, and a sort is what a trial costs); a failing batch's trades are gated one by one
    -- params.form_swaps: { candidates = function(assignment) --> list of { slot key, slot key, preferred = whether to try it before the others, first_for = the resource slot it makes mine something new (optional) }, form_of = function(node key) --> the form of a slot or trav, max_trials (gates), max_swaps (trades kept), batch (trades per gate, 1 when nil), first_tries (candidates tried first for each first_for slot, 1 when nil) }
    if params.form_swaps ~= nil then
        local swaps = params.form_swaps
        local candidates = swaps.candidates(assignment)
        rng.shuffle(rng.key({ id = "monotone-matching-form-swaps" }), candidates)
        -- Trades that make a resource slot mine something new come first, then preferred candidates, each in their shuffled order, so the others are only tried once those run out (order_form_swaps)
        -- Each such slot may keep one trade beyond max_swaps, so these don't use up the other trades' share
        local num_first, num_first_slots, num_preferred
        candidates, num_first, num_first_slots, num_preferred = order_form_swaps(candidates, swaps.first_tries)
        local max_swaps = swaps.max_swaps + num_first_slots
        log("Monotone matching: " .. #candidates .. " form trade candidates, " .. num_first .. " first for " .. num_first_slots .. " resource slots, " .. num_preferred .. " preferred")
        local num_trials = 0
        local num_kept = 0
        -- Whether both positions of a candidate still hold identities of their own form (an earlier trade may have taken either)
        local function open(pair)
            return swaps.form_of(assignment[pair[1]]) == swaps.form_of(pair[1]) and swaps.form_of(assignment[pair[2]]) == swaps.form_of(pair[2])
        end
        -- The assignment with the given trades (of positions no two share) made, as reflection realizes it
        local function traded(pairs_to_trade)
            local trial = table.deepcopy(assignment)
            for _, pair in pairs(pairs_to_trade) do
                trial[pair[1]] = assignment[pair[2]]
                trial[pair[2]] = assignment[pair[1]]
            end
            return realize(params, trial)
        end
        -- What a trial assignment loses: hard pebbles (empty when it passes)
        local function gate(trial)
            num_trials = num_trials + 1
            local trial_graph = connect(table.deepcopy(params.unconnected_graph), params, trial)
            local trial_sort = complex_sort(trial_graph)
            local lost = lost_pebbles(exact, recipes, trial_sort)
            return lost
        end
        local function keep(trial, pairs_kept)
            assignment = trial
            num_kept = num_kept + #pairs_kept
            for _, pair in pairs(pairs_kept) do
                log("Monotone matching: form trade kept, " .. assignment[pair[1]] .. " at " .. pair[1] .. " and " .. assignment[pair[2]] .. " at " .. pair[2])
            end
        end
        local function budget_left()
            return num_trials < swaps.max_trials and num_kept < max_swaps
        end
        local next_candidate = 1
        while next_candidate <= #candidates and budget_left() do
            -- The next batch: candidates whose positions are still open and that share no position within the batch
            local batch = {}
            local taken = {}
            while next_candidate <= #candidates and #batch < math.min(swaps.batch or 1, max_swaps - num_kept) do
                local pair = candidates[next_candidate]
                next_candidate = next_candidate + 1
                if open(pair) and taken[pair[1]] == nil and taken[pair[2]] == nil then
                    table.insert(batch, pair)
                    taken[pair[1]] = true
                    taken[pair[2]] = true
                end
            end
            if #batch == 0 then
                break
            end
            local trial = traded(batch)
            local lost = gate(trial)
            if #lost == 0 then
                keep(trial, batch)
            elseif #batch == 1 then
                log("Monotone matching: form trade dropped, " .. assignment[batch[1][2]] .. " at " .. batch[1][1] .. " and " .. assignment[batch[1][1]] .. " at " .. batch[1][2] .. " lost " .. #lost .. " pebbles (e.g. " .. lost[1].node_key .. " @ " .. top.context_name(lost[1].context) .. ")")
            else
                log("Monotone matching: a batch of " .. #batch .. " form trades lost " .. #lost .. " pebbles (e.g. " .. lost[1].node_key .. " @ " .. top.context_name(lost[1].context) .. "), so each is gated alone")
                for _, pair in pairs(batch) do
                    if not budget_left() then
                        break
                    end
                    local trial_one = traded({ pair })
                    local lost_one = gate(trial_one)
                    if #lost_one == 0 then
                        keep(trial_one, { pair })
                    else
                        log("Monotone matching: form trade dropped, " .. assignment[pair[2]] .. " at " .. pair[1] .. " and " .. assignment[pair[1]] .. " at " .. pair[2] .. " lost " .. #lost_one .. " pebbles (e.g. " .. lost_one[1].node_key .. " @ " .. top.context_name(lost_one[1].context) .. ")")
                    end
                end
            end
        end
        log("Monotone matching: " .. num_kept .. " form trades kept in " .. num_trials .. " trials (" .. #candidates .. " candidates)")
        if num_first_slots > 0 then
            local num_resources, num_new_resources = count_new_resources(params, assignment)
            log("Monotone matching: after form trades, " .. num_new_resources .. " of " .. num_resources .. " resource slots mine something new")
        end
    end
    return assignment
end

return matching
