-- Monotone matching for first pass: chooses which item identity (trav) goes in which item position (slot) all at once, instead of first pass's greedy forward fill
-- Based on the other session's report (scratchpad REPORT-multipass-complex-contexts.md) and its exp-iter.lua prototype
--
-- A round starts from a valid matching (the identity matching in round 1) and its graph:
--   1. Take a random complex sort of that graph, and prove every pebble that must keep its exact context in it (protected mechanics and planet-locked recipes; backings go to strictly earlier pebbles)
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
local superpose = require("lib/graph/superpose")

local key = gutils.key

local matching = {}

local function complex_sort(graph)
    return top.sort(graph, nil, nil, {
        choose_randomly = true,
        complex_contexts = true,
        home_contexts = true,
    })
end

-- How a slot connects to a trav: params.connection(slot_key, trav_key) (optional) gives { base = the node the connection starts at (the slot's base if nil), abilities = what getting through it gains or loses (see lib/graph/context-sort.lua) }, or nil for the plain connection
-- Entity positions use it: a built entity found in the wild or looted can't be automated, and one carried by a unit also takes killing the carrier (see handlers/entity.lua)
local function connection_of(params, slot_key, trav_key)
    local connection
    if params.connection ~= nil then
        connection = params.connection(slot_key, trav_key)
    end
    return connection or {}
end

-- Connect each slot to its assigned trav: slot base --> trav head, plus trav --> slot for items, since reflection makes them the same physical item (so the slot's consumers also get the trav's identity-based sources, like delivery and spoilage)
-- The slot_to_base and trav_to_head connectors come from params, and params.connect_extra(graph, slot_key, trav_key) (optional) connects anything else that follows the pair
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
        end
        if params.connect_extra ~= nil then
            params.connect_extra(graph, slot_key, trav_key)
        end
    end
    return graph
end

-- Hard pebbles, in two lists:
--   * exact: protected mechanic pebbles, and every pebble of a recipe locked to one planet (see protection.lua), which must keep their exact contexts
--   * recipes: each reachable recipe's earliest pebble asking for no abilities and not in a home context, which only has to stay reachable somewhere (and only the gate checks)
-- params.recipe_may_vanish(node_key) (optional) names recipes that may become unreachable, like the recycling recipes of a position a fluid takes (see lib/item-fluid.lua rewire_form_change): the game regenerates them for the item identity under the same name
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
-- With wants (optional, trav key --> set of contexts), each trav a debt goal uses where the game doesn't have it then takes a slot the game has in all those contexts, wherever the matching allows it, which pays for that part of the debt (see matching.run)
-- Returns the matching
local function random_matching(params, graph, sort_info, needs, requires_launchable, assignment, rng_key, wants)
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
                -- Slots take travs of their own type, or of another type where params.cross_type_ok allows it (items and fluids trading positions, see lib/item-fluid.lua)
                local is_admissible = (slot.type == trav.type or (params.cross_type_ok ~= nil and params.cross_type_ok(slot, trav))) and params.pair_ok(slot, trav)
                if is_admissible and requires_launchable[slot_key] and not params.is_launchable(trav_key) then
                    is_admissible = false
                end
                if is_admissible then
                    -- Ranks are the connection's: its start (the slot unless the connection says otherwise) in any context that arrives in the need's through it
                    local connection = connection_of(params, slot_key, trav_key)
                    local start_inds = nci[connection.base or slot_key] or {}
                    for context, _ in pairs(needs[trav_key] or {}) do
                        local slot_ind
                        local sources = { context }
                        if connection.abilities ~= nil then
                            sources = top.edge_source_contexts(sort_info, connection, context)
                        end
                        for _, source in pairs(sources) do
                            if start_inds[source] ~= nil and (slot_ind == nil or start_inds[source] < slot_ind) then
                                slot_ind = start_inds[source]
                            end
                        end
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
        -- Lists of keys, so a plain copy is a deep one
        local function copy_list(list)
            local copy = {}
            for i, value in pairs(list) do
                copy[i] = value
            end
            return copy
        end
        local function try(trav_key, visited)
            local candidates = copy_list(admissible[trav_key])
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
        local order = copy_list(travs)
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
    -- Each trav a debt goal wants takes a random admissible slot the game has in every wanted context, if a perfect matching still exists with it
    -- Travs placed that way stay put below
    local is_paid = {}
    local want_travs = {}
    for trav_key, _ in pairs(wants or {}) do
        if not is_taken[trav_key] then
            table.insert(want_travs, trav_key)
        end
    end
    table.sort(want_travs)
    rng.shuffle(rng_key, want_travs)
    for _, trav_key in pairs(want_travs) do
        local candidates = {}
        for _, slot_key in pairs(admissible[trav_key]) do
            if prefilled[slot_key] == nil then
                local pays = true
                for context, _ in pairs(wants[trav_key]) do
                    if (nci[slot_key] or {})[context] == nil then
                        pays = false
                        break
                    end
                end
                if pays then
                    table.insert(candidates, slot_key)
                end
            end
        end
        rng.shuffle(rng_key, candidates)
        for i = 1, math.min(#candidates, 5) do
            prefilled[candidates[i]] = trav_key
            if complete(prefilled) ~= nil then
                is_taken[trav_key] = true
                is_paid[trav_key] = true
                break
            end
            prefilled[candidates[i]] = nil
        end
    end
    local num_paid = 0
    for _, _ in pairs(is_paid) do
        num_paid = num_paid + 1
    end
    if #want_travs > 0 then
        log("Monotone matching: " .. num_paid .. " of " .. #want_travs .. " identities debt goals want now come from the game where they're wanted")
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
                -- A trav that pays for debt doesn't move
                local options = is_paid[trav_key] and {} or table.deepcopy(admissible[trav_key])
                if not is_paid[trav_key] then
                    table.insert(options, current_slot[trav_key])
                end
                rng.shuffle(rng_key, options)
                for _, slot_key in pairs(options) do
                    if prev[slot_key] == nil and keeps_resources_new(trav_key, slot_key) then
                        prev[slot_key] = queue[i]
                        local closing = slot_match[slot_key]
                        if is_admissible[closing][resource_slot] and is_new_resource_trav(params, resource_slot, closing) and not is_paid[closing] then
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

-- How many lost pebbles blocked_travs looks at: the earliest ones (in the previous sort) are the roots of the loss, and the rest follow from them, while each witness costs a path search (a proposal once lost thousands and took minutes)
local BLOCKED_PEBBLES_LIMIT = 300

-- Trav pebbles on the witnesses (in the previous graph) of the lost pebbles that are missing from the new sort
local function blocked_travs(graph, sort_info, lost, new_sort)
    local blocked = {}
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
    for n, ind in pairs(earliest) do
        if n <= BLOCKED_PEBBLES_LIMIT then
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

----------------------------------------------------------------------------------------------------
-- Debt goals
----------------------------------------------------------------------------------------------------

-- With planetary changes superposed (debt, like planetary.superposed; see lib/graph/superpose.lua), goals only the older world reaches must stay reachable with its debt, since promotion keeps them owed until something pays for them
-- Everything the game itself has is kept as before, since the other sorts here leave the debt out

-- A copy of graph with the debt added, and a sort of it
local function superposed_sort(graph, debt)
    local sup_graph = table.deepcopy(graph)
    superpose.add_debt(sup_graph, debt)
    return sup_graph, complex_sort(sup_graph)
end

-- Goals only the debt reaches, given the game's graph and a sort of it
-- Returns { exact = pebbles of hard transported goals (debt.goals, hard as in protection.lua) the superposed graph reaches but the game doesn't, recipes = the recipes it reaches but the game doesn't (each with the earliest context it has, for its witness) }, and the superposed graph and sort
local function debt_goals_of(graph, sort_info, debt)
    local sup_graph, sup_sort = superposed_sort(graph, debt)
    local nci = sort_info.node_to_context_inds
    local sup_nci = sup_sort.node_to_context_inds
    local goals = {
        exact = {},
        recipes = {},
    }
    for node_key, contexts in pairs(debt.goals or {}) do
        local node = sup_graph.nodes[node_key]
        for context, _ in pairs(contexts) do
            local is_hard = node ~= nil and (node.type == "recipe" or (node.mechanic and node.type ~= "orand" and protection.is_hard_mechanic_pebble(node, context)))
            if is_hard and (nci[node_key] or {})[context] == nil and (sup_nci[node_key] or {})[context] ~= nil then
                table.insert(goals.exact, {
                    node_key = node_key,
                    context = context,
                })
            end
        end
    end
    for node_key, contexts in pairs(sup_nci) do
        local node = sup_graph.nodes[node_key]
        if node.type == "recipe" and node.old_world == nil and next(contexts) ~= nil and next(nci[node_key] or {}) == nil then
            local earliest_context
            local earliest
            for context, ind in pairs(contexts) do
                if earliest == nil or ind < earliest then
                    earliest = ind
                    earliest_context = context
                end
            end
            table.insert(goals.recipes, {
                node_key = node_key,
                context = earliest_context,
            })
        end
    end
    for _, list in pairs(goals) do
        table.sort(list, function(a, b) return a.node_key .. a.context < b.node_key .. b.context end)
    end
    return goals, sup_graph, sup_sort
end

-- Debt goals (from debt_goals_of) that a sort of a superposed graph misses: exact goals need their context, recipes any context
matching.lost_debt_goals = function(goals, sup_sort)
    local sup_nci = sup_sort.node_to_context_inds
    local lost = {}
    for _, pebble in pairs(goals.exact) do
        if (sup_nci[pebble.node_key] or {})[pebble.context] == nil then
            table.insert(lost, pebble)
        end
    end
    for _, pebble in pairs(goals.recipes) do
        if next(sup_nci[pebble.node_key] or {}) == nil then
            table.insert(lost, pebble)
        end
    end
    return lost
end

-- A copy of graph with the debt added, and a sort of it (for first pass's own gate)
matching.superposed_sort = superposed_sort

-- params:
--   slot_keys: every slot
--   unconnected_graph: first pass's split graph with no slot/trav connections
--   slot_to_base, trav_to_head: first pass's connector nodes
--   pair_ok(slot, trav): whether the trav can go in the slot (their costs fit, and item reflection's special rules allow it)
--   cross_type_ok(slot, trav) (optional): whether a trav can go in a slot of another node type at all (pair_ok still has to allow it too); without it, slots only take travs of their own type
--   rounds: how many rounds to iterate (each starts from the last round's matching)
--   is_resource_slot(slot_key), is_interesting(trav_key) (optional): see random_matching
--   recipe_may_vanish(node_key) (optional): recipes the gate doesn't hold on to (see hard_pebbles)
--   realize(assignment) (optional): the matching the game will actually have, which is what gets gated and returned
--   connection(slot_key, trav_key) (optional): where the connection of a slot/trav pair starts and what abilities it gains or loses (see connection_of)
--   connect_extra(graph, slot_key, trav_key) (optional): connects anything else that follows a slot/trav pair (see connect)
--   debt (optional): planetary changes superposed (see the debt goals above), whose goals only the debt reaches must stay reachable with it
-- Returns slot key --> trav key, and the debt goals it kept (nil without debt), for first pass's own gate
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

    -- The superposed graph and sort of the current matching, whose witnesses tell which travs a lost debt goal needs
    local debt_goals
    local sup_graph
    local sup_sort
    if params.debt ~= nil then
        debt_goals, sup_graph, sup_sort = debt_goals_of(graph, sort_info, params.debt)
        log("Monotone matching: " .. #debt_goals.exact .. " goals and " .. #debt_goals.recipes .. " recipes only reachable with the debt")
    end

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

    for round = 1, params.rounds do
        -- Recipe anchors are left to the gate (their needs would be too strict), but planet-locked recipes keep exact contexts, so they're proved like mechanics
        local closure, support, failed = make_prover(graph, sort_info).prove(goal_inds_of(exact, sort_info))
        if #failed > 0 then
            -- Those pebbles get no needs, so the gate is all that protects them this round
            log("Monotone matching: round " .. round .. " couldn't prove " .. #failed .. " hard pebbles in its own sort")
        end
        local needs, requires_launchable = needs_from_proof(graph, sort_info, closure, support, assignment, chain_of)
        -- Wants: travs whose identity a debt goal's proof (in the superposed graph) uses in a context the game doesn't have it in
        -- Putting such a trav in a slot the game has in that context pays for that part of the debt
        local wants
        if debt_goals ~= nil then
            local debt_goal_pebbles = {}
            for _, list in pairs(debt_goals) do
                for _, pebble in pairs(list) do
                    table.insert(debt_goal_pebbles, pebble)
                end
            end
            local sup_closure, sup_support = make_prover(sup_graph, sup_sort).prove(goal_inds_of(debt_goal_pebbles, sup_sort))
            wants = {}
            for trav_key, contexts in pairs(needs_from_proof(sup_graph, sup_sort, sup_closure, sup_support, assignment, chain_of)) do
                for context, _ in pairs(contexts) do
                    if (sort_info.node_to_context_inds[trav_key] or {})[context] == nil then
                        wants[trav_key] = wants[trav_key] or {}
                        wants[trav_key][context] = true
                    end
                end
            end
        end
        local num_refinements = 0
        local new_assignment
        local new_graph
        local new_sort
        -- The superposed graph and sort of the matching this round keeps, if it keeps a new one
        local kept_sup_graph
        local kept_sup_sort
        while true do
            new_assignment = random_matching(params, graph, sort_info, needs, requires_launchable, assignment, rng.key({ id = "monotone-matching-" .. round .. "-" .. num_refinements }), wants)
            new_assignment = realize(params, new_assignment)
            new_graph = connect(table.deepcopy(params.unconnected_graph), params, new_assignment)
            new_sort = complex_sort(new_graph)
            local lost = lost_pebbles(exact, recipes, new_sort)
            -- Debt goals are only checked once the game itself keeps everything, since that's the cheaper sort
            local lost_debt = {}
            local new_sup_graph
            local new_sup_sort
            if #lost == 0 and debt_goals ~= nil then
                new_sup_graph, new_sup_sort = superposed_sort(new_graph, params.debt)
                lost_debt = matching.lost_debt_goals(debt_goals, new_sup_sort)
            end
            if #lost == 0 and #lost_debt == 0 then
                kept_sup_graph = new_sup_graph
                kept_sup_sort = new_sup_sort
                break
            end
            local blocked = blocked_travs(graph, sort_info, lost, new_sort)
            if #lost_debt > 0 then
                for id, q in pairs(blocked_travs(sup_graph, sup_sort, lost_debt, new_sup_sort)) do
                    blocked[id] = q
                end
            end
            local num_added = 0
            for _, q in pairs(blocked) do
                needs[q.node_key] = needs[q.node_key] or {}
                if needs[q.node_key][q.context] == nil then
                    needs[q.node_key][q.context] = true
                    num_added = num_added + 1
                end
            end
            num_refinements = num_refinements + 1
            local example = lost[1] or lost_debt[1]
            log("Monotone matching: round " .. round .. " lost " .. #lost .. " hard pebbles and " .. #lost_debt .. " debt goals (e.g. " .. example.node_key .. " @ " .. example.context .. "); added " .. num_added .. " needs")
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
        if kept_sup_sort ~= nil then
            sup_graph = kept_sup_graph
            sup_sort = kept_sup_sort
        end
    end

    -- Positions of different forms trade identities afterwards (params.form_swaps, items and fluids trading positions, see lib/item-fluid.lua): such a trade moves recipes to other crafters, which the needs above can't repair, so trades are gated like a round and kept only when nothing is lost
    -- Each trial gates a batch of trades with one sort (most trades pass, and a sort is what a trial costs); a failing batch's trades are gated one by one
    -- params.form_swaps: { candidates = function(assignment) --> list of { slot key, slot key, preferred = whether to try it before the others }, form_of = function(node key) --> the form of a slot or trav, max_trials (gates), max_swaps (trades kept), batch (trades per gate, 1 when nil) }
    if params.form_swaps ~= nil then
        local swaps = params.form_swaps
        local candidates = swaps.candidates(assignment)
        rng.shuffle(rng.key({ id = "monotone-matching-form-swaps" }), candidates)
        -- Preferred candidates come first in their shuffled order, so the others are only tried once those run out
        local ordered = {}
        for i = 1, #candidates do
            if candidates[i].preferred == true then
                table.insert(ordered, candidates[i])
            end
        end
        local num_preferred = #ordered
        for i = 1, #candidates do
            if candidates[i].preferred ~= true then
                table.insert(ordered, candidates[i])
            end
        end
        candidates = ordered
        log("Monotone matching: " .. #candidates .. " form trade candidates, " .. num_preferred .. " preferred")
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
        -- What a trial assignment loses: hard pebbles, or debt goals once it keeps every hard pebble (empty when it passes)
        local function gate(trial)
            num_trials = num_trials + 1
            local trial_graph = connect(table.deepcopy(params.unconnected_graph), params, trial)
            local trial_sort = complex_sort(trial_graph)
            local lost = lost_pebbles(exact, recipes, trial_sort)
            if #lost == 0 and debt_goals ~= nil then
                local _, trial_sup_sort = superposed_sort(trial_graph, params.debt)
                lost = matching.lost_debt_goals(debt_goals, trial_sup_sort)
            end
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
            return num_trials < swaps.max_trials and num_kept < swaps.max_swaps
        end
        local next_candidate = 1
        while next_candidate <= #candidates and budget_left() do
            -- The next batch: candidates whose positions are still open and that share no position within the batch
            local batch = {}
            local taken = {}
            while next_candidate <= #candidates and #batch < math.min(swaps.batch or 1, swaps.max_swaps - num_kept) do
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
                log("Monotone matching: form trade dropped, " .. assignment[batch[1][2]] .. " at " .. batch[1][1] .. " and " .. assignment[batch[1][1]] .. " at " .. batch[1][2] .. " lost " .. #lost .. " pebbles (e.g. " .. lost[1].node_key .. " @ " .. lost[1].context .. ")")
            else
                log("Monotone matching: a batch of " .. #batch .. " form trades lost " .. #lost .. " pebbles (e.g. " .. lost[1].node_key .. " @ " .. lost[1].context .. "), so each is gated alone")
                for _, pair in pairs(batch) do
                    if not budget_left() then
                        break
                    end
                    local trial_one = traded({ pair })
                    local lost_one = gate(trial_one)
                    if #lost_one == 0 then
                        keep(trial_one, { pair })
                    else
                        log("Monotone matching: form trade dropped, " .. assignment[pair[2]] .. " at " .. pair[1] .. " and " .. assignment[pair[1]] .. " at " .. pair[2] .. " lost " .. #lost_one .. " pebbles (e.g. " .. lost_one[1].node_key .. " @ " .. lost_one[1].context .. ")")
                    end
                end
            end
        end
        log("Monotone matching: " .. num_kept .. " form trades kept in " .. num_trials .. " trials (" .. #candidates .. " candidates)")
    end
    return assignment, debt_goals
end

return matching
