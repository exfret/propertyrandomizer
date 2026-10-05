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
local operation_requirements = require("lib/logic/operation-requirements")
local weighted_matching = require("lib/graph/weighted-matching")

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
-- A fluid position (a fluid-temperature node, an AND of being made and being held, see lib/logic/concrete.lua) gets the same back edge into its making (fluid-create-temperature): its consumers can then use the identity's own sources too, pumping and barrels for a fluid identity (lib/item-fluid.lua moves those to the identity) or delivery for an item identity, which is how a recipe locked to a planet that doesn't make the fluid still gets it there
-- A fluid identity with independent mining sources needs this back edge too, even when its holding prerequisites make it an AND node.
-- Otherwise only OR identities get it: an AND identity fed by its head alone would gain nothing but a cycle through AND nodes, which needs derivation cannot follow.
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
            gutils.add_edge(graph, trav_key, slot_key, { identity_supply = true })
        elseif slot.type == "fluid-temperature" and (graph.nodes[trav_key].op == "OR" or graph.nodes[trav_key].shares_mining_identity == true) then
            for pre, _ in pairs(slot.pre) do
                local prenode = gutils.prenode(graph, pre)
                if prenode.type == "fluid-create-temperature" then
                    gutils.add_edge(graph, trav_key, key(prenode), { identity_supply = true })
                end
            end
        end
        if params.connect_extra ~= nil then
            params.connect_extra(graph, slot_key, trav_key, assignment)
        end
    end
    if params.connect_assignment ~= nil then
        params.connect_assignment(graph, assignment)
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
    local identity_deadlines = {}
    local function is_genuine(q, trav_key)
        if genuine[q] ~= nil then
            return genuine[q]
        end
        genuine[q] = false
        local result = users[q] == nil
        local deadline = result and q or nil
        for _, u in pairs(users[q] or {}) do
            local u_key = sorted[u].node_key
            local user = graph.nodes[u_key]
            local edge = graph.edges[gutils.ekey({ start = sorted[q].node_key, stop = u_key })]
            if user.slot == true then
                -- A position consumes its newly assigned material, not this old identity.
                -- position_needs proves its replacement's supply separately.
                if is_delivered(q, trav_key) then
                    requires_launchable[u_key] = true
                end
            elseif chain_of[u_key] == trav_key or u_key == trav_key or (edge ~= nil and edge.shared_identity == true) then
                if is_genuine(u, trav_key) then
                    result = true
                    deadline = math.min(deadline or math.huge, identity_deadlines[u])
                end
            else
                result = true
                deadline = math.min(deadline or math.huge, u)
            end
        end
        genuine[q] = result
        identity_deadlines[q] = deadline
        return result
    end

    local function consumer_deadline(q, seen, craft_only)
        if seen[q] then
            return nil
        end
        seen[q] = true
        local earliest
        for _, user in pairs(users[q] or {}) do
            local node = graph.nodes[sorted[user].node_key]
            local deadline
            if node.identity_connection ~= true and not (craft_only and (node.slot == true or node.craft_identity == true)) then
                if node.type == "base" or node.type == "head" or node.type == "orand" then
                    deadline = consumer_deadline(user, seen, craft_only)
                else
                    deadline = user
                end
            end
            if deadline ~= nil and (earliest == nil or deadline < earliest) then
                earliest = deadline
            end
        end
        return earliest
    end

    local needs = {}
    local position_needs = {}
    local craft_needs = {}
    local craft_position_needs = {}
    for q, _ in pairs(closure) do
        local pebble = sorted[q]
        local node = graph.nodes[pebble.node_key]
        if node.slot == true then
            position_needs[pebble.node_key] = position_needs[pebble.node_key] or {}
            -- The consumer's proof rank is the deadline, rather than the slot's first arrival.
            -- A shared material can arrive by import long before this position can produce it.
            local deadline = consumer_deadline(q, {})
            if deadline ~= nil then
                position_needs[pebble.node_key][pebble.context] = deadline
            end
        end
        if node.craft_position ~= nil and graph.nodes[node.craft_position].production_slot == nil then
            local deadline = consumer_deadline(q, {}, true)
            if deadline ~= nil then
                craft_position_needs[node.craft_position] = craft_position_needs[node.craft_position] or {}
                craft_position_needs[node.craft_position][pebble.context] = deadline
            end
        end
        if node.craft_identity == true then
            for _, j in pairs(support[q] or {}) do
                local edge = graph.edges[gutils.ekey({ start = sorted[j].node_key, stop = pebble.node_key })]
                if edge ~= nil and edge.craft_supplier ~= nil then
                    local supplier = edge.craft_supplier
                    craft_needs[supplier] = craft_needs[supplier] or {}
                    craft_needs[supplier][pebble.context] = math.min(craft_needs[supplier][pebble.context] or q, q)
                end
            end
        end
        if node.trav and slot_of[pebble.node_key] ~= nil then
            local borrowed_identity = false
            for _, j in pairs(support[q] or {}) do
                local edge = graph.edges[gutils.ekey({
                    start = sorted[j].node_key,
                    stop = pebble.node_key,
                })]
                if edge ~= nil and edge.shared_identity == true then
                    borrowed_identity = true
                end
            end
            -- An alias reading another copy's supply adds no acquisition requirement of its own.
            -- The producing copy on the same proof already records the material's requirement.
            if not borrowed_identity and is_genuine(q, pebble.node_key) and not is_delivered(q, pebble.node_key) then
                needs[pebble.node_key] = needs[pebble.node_key] or {}
                needs[pebble.node_key][pebble.context] = identity_deadlines[q]
            end
        end
    end
    return needs, requires_launchable, position_needs, craft_needs, craft_position_needs
end

----------------------------------------------------------------------------------------------------
-- Matching
----------------------------------------------------------------------------------------------------

-- Whether a resource slot mines something new: an interesting traveller whose physical material differs from the original (when is_new_resource_pair is supplied).
-- Reflection keeps interesting travs where the matching puts them, but doesn't swap two useless items (ores count as useless), so a useless trav usually leaves the resource as it was
local function is_new_resource_trav(params, slot_key, trav_key)
    return trav_key ~= params.unconnected_graph.nodes[slot_key].old_trav and params.is_interesting(trav_key, slot_key) and (params.is_new_resource_pair == nil or params.is_new_resource_pair(slot_key, trav_key))
end

local function native_production(graph, sort_info)
    local nci = sort_info.node_to_context_inds
    -- A position's current identity can supply its consumers, but that supply is replaced by a new pair.
    -- Admission therefore uses native production ranks, retaining AND prerequisites such as fluid holding.
    local production = {}
    local function production_inds(slot_key)
        if production[slot_key] ~= nil then
            return production[slot_key]
        end
        local memo = {}
        local function rank(node_key, context, force)
            local node = graph.nodes[node_key]
            if node.pre == nil then
                return (nci[node_key] or {})[context]
            end
            local borrowed = false
            for pre, _ in pairs(node.pre) do
                if graph.edges[pre].identity_supply == true then
                    borrowed = true
                end
            end
            local channel = node.type == "orand" or node.type == "item-craft" or node.type == "fluid-create-temperature" or node.type == "fluid-craft-temperature"
            if force ~= true and not borrowed and not channel then
                return (nci[node_key] or {})[context]
            end
            memo[node_key] = memo[node_key] or {}
            if memo[node_key][context] ~= nil then
                return memo[node_key][context] or nil
            end
            memo[node_key][context] = false
            local best
            local count = 0
            for pre, _ in pairs(node.pre) do
                local edge = graph.edges[pre]
                if edge.identity_supply ~= true then
                    count = count + 1
                    local found
                    local sources = edge.abilities ~= nil and top.edge_source_contexts(sort_info, edge, context) or { context }
                    for _, source in pairs(sources) do
                        local candidate = rank(edge.start, source, false)
                        if candidate ~= nil and (found == nil or candidate < found) then
                            found = candidate
                        end
                    end
                    if node.op == "AND" then
                        if found == nil then
                            return nil
                        end
                        best = math.max(best or 0, found)
                    elseif found ~= nil and (best == nil or found < best) then
                        best = found
                    end
                end
            end
            if count == 0 and node.op == "AND" then
                best = (nci[node_key] or {})[context]
            end
            if best ~= nil then
                memo[node_key][context] = best
            end
            return best
        end
        local ranks = {}
        for context, _ in pairs(nci[slot_key] or {}) do
            ranks[context] = rank(slot_key, context, true)
        end
        production[slot_key] = ranks
        return ranks
    end

    return production_inds
end

-- Weighted perfect matching of travs to admissible slots, with seeded tie breaking
-- With params.is_resource_slot, resource slots then get travs that make them mine something new (see is_new_resource_trav) wherever the matching allows it
-- With wants (optional, trav key --> set of contexts), each trav a debt goal uses where the game doesn't have it then takes a slot the game has in all those contexts, wherever the matching allows it, which pays for that part of the debt (see matching.run)
-- Returns the matching
local function random_matching(params, graph, sort_info, needs, requires_launchable, assignment, rng_key, wants, position_needs, shared_sources, craft_needs, craft_position_needs)
    local operation_rules
    if params.operations ~= nil then
        operation_rules = operation_requirements.matching(graph, sort_info, params.operations)
    end
    local function operation_ok(slot_key, trav_key)
        if operation_rules == nil then
            return true
        end
        return (params.operation_rejected == nil or (params.operation_rejected[trav_key] or {})[slot_key] == nil) and operation_rules.allows(slot_key, trav_key)
    end
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

    local production_inds = native_production(graph, sort_info)

    local admissible = {}
    local resource_options = {}
    for _, trav_key in pairs(travs) do
        local trav = graph.nodes[trav_key]
        admissible[trav_key] = {}
        for _, slot_key in pairs(slots) do
            if slot_key ~= current_slot[trav_key] then
                local slot = graph.nodes[slot_key]
                -- Slots take travs of their own type, or of another type where params.cross_type_ok allows it (items and fluids trading positions, see lib/item-fluid.lua)
                local is_admissible = (slot.type == trav.type or (params.cross_type_ok ~= nil and params.cross_type_ok(slot, trav))) and params.pair_ok(slot, trav) and operation_ok(slot_key, trav_key)
                local rejection = "compatibility"
                if is_admissible and requires_launchable[slot_key] and not params.is_launchable(trav_key) then
                    is_admissible = false
                end
                if is_admissible then
                    -- Ranks are the connection's: its start (the slot unless the connection says otherwise) in any context that arrives in the need's through it
                    local connection = connection_of(params, slot_key, trav_key)
                    local start_inds = connection.base ~= nil and (nci[connection.base] or {}) or production_inds(slot_key)
                    local function arrives_before(context, deadline)
                        local sources = { context }
                        if connection.abilities ~= nil then
                            sources = top.edge_source_contexts(sort_info, connection, context)
                        end
                        for _, source in pairs(sources) do
                            if start_inds[source] ~= nil and deadline ~= nil and start_inds[source] < deadline then
                                return true
                            end
                        end
                        return false
                    end
                    for context, required in pairs(needs[trav_key] or {}) do
                        local deadline = type(required) == "number" and required or (nci[trav_key] or {})[context]
                        if operation_rules ~= nil then
                            deadline = operation_rules.deadline(trav_key, context, deadline)
                        end
                        if not arrives_before(context, deadline) then
                            rejection = "identity supply"
                            is_admissible = false
                            break
                        end
                    end
                    if is_admissible then
                        local craft_key = (graph.craft_positions or {})[slot_key]
                        local craft_inds = craft_key ~= nil and production_inds(craft_key) or {}
                        for context, deadline in pairs((craft_needs or {})[trav_key] or {}) do
                            if craft_inds[context] == nil or craft_inds[context] >= deadline then
                                rejection = "craft supply"
                                is_admissible = false
                                break
                            end
                        end
                        if is_admissible then
                            for context, deadline in pairs((craft_position_needs or {})[slot_key] or {}) do
                                local shared_rank = ((shared_sources or {})[trav.craft_identity_key] or {})[context]
                                local native_rank = craft_inds[context]
                                if not (native_rank ~= nil and native_rank < deadline) and not (shared_rank ~= nil and shared_rank < deadline) then
                                    rejection = "craft consumer"
                                    is_admissible = false
                                    break
                                end
                            end
                        end
                    end
                    if is_admissible then
                        for context, required in pairs((position_needs or {})[slot_key] or {}) do
                            local deadline = type(required) == "number" and required or (nci[slot_key] or {})[context]
                            local identity = trav.shared_identity_key
                            local shared_rank = identity ~= nil and ((shared_sources or {})[identity] or {})[context] or nil
                            -- A local recipe may use an imported copy of its new ingredient.
                            -- Its source proof is included up front, so the matching must preserve that supply too.
                            if not arrives_before(context, deadline) and not (shared_rank ~= nil and shared_rank < deadline) then
                                rejection = "position consumer"
                                is_admissible = false
                                break
                            end
                        end
                    end
                end
                if is_admissible then
                    table.insert(admissible[trav_key], slot_key)
                end
                if params.is_resource_slot ~= nil and params.is_resource_slot(slot_key) and is_new_resource_trav(params, slot_key, trav_key) then
                    local reason = is_admissible and "admitted" or rejection
                    resource_options[slot_key] = resource_options[slot_key] or {}
                    resource_options[slot_key][reason] = (resource_options[slot_key][reason] or 0) + 1
                end
            end
        end
    end

    -- Optimize the complete assignment, rather than freezing greedy resource choices.
    -- One more changed deposit outweighs all secondary preferences together.
    -- Equally good resource counts retain existing changes and pay debt, then choose by seeded random edge weights.
    -- Maximizing all moved identities would bias deposits toward identities whose only alternative is their current position.
    rng.shuffle(rng_key, slots)
    rng.shuffle(rng_key, travs)
    local column_of = {}
    for column, slot_key in pairs(slots) do
        column_of[slot_key] = column
    end
    local priority = 2 * #slots + 1
    local costs = {}
    local pays_debt = {}
    local function score(slot_key, trav_key)
        local value = rng.value(rng_key)
        if params.is_resource_slot ~= nil and params.is_resource_slot(slot_key) and is_new_resource_trav(params, slot_key, trav_key) then
            value = value * priority + priority * priority * priority
            if assignment[slot_key] == trav_key then
                value = value + priority * priority
            end
        end
        if wants ~= nil and wants[trav_key] ~= nil then
            local pays = true
            for context, _ in pairs(wants[trav_key]) do
                if (nci[slot_key] or {})[context] == nil then
                    pays = false
                    break
                end
            end
            if pays then
                value = value + priority * priority
                pays_debt[trav_key] = pays_debt[trav_key] or {}
                pays_debt[trav_key][slot_key] = true
            end
        end
        return value
    end
    for row, trav_key in pairs(travs) do
        local row_costs = {}
        costs[row] = row_costs
        for _, slot_key in pairs(admissible[trav_key]) do
            row_costs[column_of[slot_key]] = -score(slot_key, trav_key)
        end
        local slot_key = current_slot[trav_key]
        if operation_ok(slot_key, trav_key) then
            row_costs[column_of[slot_key]] = -score(slot_key, trav_key)
        end
    end
    local matched = weighted_matching.solve(costs, #slots)
    if matched == nil then
        for _, trav_key in pairs(travs) do
            if #admissible[trav_key] == 0 and not operation_ok(current_slot[trav_key], trav_key) then
                log("Operation matching: no candidate for " .. trav_key .. "; " .. operation_rules.describe(current_slot[trav_key], trav_key))
            end
        end
        return nil
    end
    local slot_match = {}
    local num_paid = 0
    local num_wanted = 0
    for column, row in pairs(matched) do
        local slot_key = slots[column]
        local trav_key = travs[row]
        slot_match[slot_key] = trav_key
        if params.is_resource_slot ~= nil and params.is_resource_slot(slot_key) and not is_new_resource_trav(params, slot_key, trav_key) then
            local reasons = {}
            for reason, count in pairs(resource_options[slot_key] or {}) do
                table.insert(reasons, reason .. "=" .. count)
            end
            table.sort(reasons)
            log("Resource matching: unchanged " .. slot_key .. "; replacement candidates " .. table.concat(reasons, ", "))
        end
        if wants ~= nil and wants[trav_key] ~= nil then
            num_wanted = num_wanted + 1
            if (pays_debt[trav_key] or {})[slot_key] == true then
                num_paid = num_paid + 1
            end
        end
    end
    if num_wanted > 0 then
        log("Monotone matching: " .. num_paid .. " of " .. num_wanted .. " identities debt goals want now come from the game where they're wanted")
    end
    return slot_match
end

-- How many lost pebbles blocked_travs looks at: the earliest ones (in the previous sort) are the roots of the loss, and the rest follow from them
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
    for n = #earliest, BLOCKED_PEBBLES_LIMIT + 1, -1 do
        earliest[n] = nil
    end
    -- Only the union of the witnesses matters. Trace them together so shared prerequisites are visited once (top.path picks the same backing regardless of the other goals).
    for i, _ in pairs(top.path(graph, earliest, sort_info).in_path) do
        local q = sort_info.sorted[i]
        if graph.nodes[q.node_key].trav == true and (new_sort.node_to_context_inds[q.node_key] or {})[q.context] == nil then
            blocked[q.node_key .. " @ " .. q.context] = q
        end
    end
    return blocked
end

-- The matching the game will actually have: params.realize (optional) maps a matching to the one reflection realizes, which is what gets gated and returned
-- The result is still a perfect matching; operation readiness is checked after realizing it.
local function realize(params, assignment)
    if params.realize == nil then
        return assignment
    end
    return params.realize(assignment)
end

local function operation_failures(params, graph, sort_info, assignment)
    if params.operations == nil then
        return {}
    end
    local rules = operation_requirements.matching(graph, sort_info, params.operations)
    local failed = {}
    for slot_key, trav_key in pairs(assignment) do
        if not rules.allows(slot_key, trav_key) then
            table.insert(failed, {
                slot = slot_key,
                trav = trav_key,
            })
        end
    end
    table.sort(failed, function(a, b) return a.trav < b.trav end)
    return failed
end

matching.connect = connect
-- For tests (test-monotone-matching.lua)
matching.random_matching = random_matching
matching.needs_from_proof = needs_from_proof

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

-- Debt goals (from debt_goals_of) that a sort of a superposed graph misses: exact goals need their context (or its isolatable counterpart, see top.provides_context), recipes any context
matching.lost_debt_goals = function(goals, sup_sort)
    local sup_nci = sup_sort.node_to_context_inds
    local lost = {}
    for _, pebble in pairs(goals.exact) do
        if not top.provides_context(sup_nci[pebble.node_key] or {}, pebble.context) then
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
-- Optional operations maps each trav key to operation node keys that must be ready where the trav arrives.
--   is_resource_slot(slot_key), is_interesting(trav_key) (optional): see random_matching
--   is_new_resource_pair(slot_key, trav_key) (optional): distinguishes actual product changes from exchanging copies of the same material
--   recipe_may_vanish(node_key) (optional): recipes the gate doesn't hold on to (see hard_pebbles)
--   realize(assignment) (optional): the matching the game will actually have, which is what gets gated and returned
--   connection(slot_key, trav_key) (optional): where the connection of a slot/trav pair starts and what abilities it gains or loses (see connection_of)
--   connect_extra(graph, slot_key, trav_key) (optional): connects anything else that follows a slot/trav pair (see connect)
--   debt (optional): planetary changes superposed (see the debt goals above), whose goals only the debt reaches must stay reachable with it
-- Returns slot key --> trav key, and the debt goals it kept (nil without debt), for first pass's own gate; returns false when no operation-ready matching is found.
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
    for _, trav_key in pairs(travs) do
        local shared = graph.nodes[trav_key].shared_identity_key
        if shared ~= nil and is_launchable[shared] == true then
            is_launchable[trav_key] = true
        end
    end
    params.is_launchable = function(trav_key)
        return is_launchable[trav_key] == true
    end

    for round = 1, params.rounds do
        params.operation_rejected = {}
        -- Prove recipe anchors too, so a changed ingredient position keeps a backing before its consumers.
        local goals = table.deepcopy(exact)
        for _, pebble in pairs(recipes) do
            table.insert(goals, pebble)
        end
        local closure, support, failed = make_prover(graph, sort_info).prove(goal_inds_of(goals, sort_info))
        if #failed > 0 then
            -- Those pebbles get no needs, so the gate is all that protects them this round
            log("Monotone matching: round " .. round .. " couldn't prove " .. #failed .. " hard pebbles in its own sort")
        end
        local needs, requires_launchable, position_needs, craft_needs, craft_position_needs = needs_from_proof(graph, sort_info, closure, support, assignment, chain_of)
        -- Before choosing pairs, prove the shared supplies that local consumers could use.
        -- These are source obligations of this round, rather than refinements learned from a failed shuffle.
        local source_goals = {}
        local source_inds = {}
        local nci = sort_info.node_to_context_inds
        local production_inds = native_production(graph, sort_info)
        for slot_key, contexts in pairs(position_needs) do
            local slot = graph.nodes[slot_key]
            if slot.production_slot ~= nil then
                for _, trav_key in pairs(travs) do
                    local trav = graph.nodes[trav_key]
                    if trav.shared_identity_key ~= nil and params.pair_ok(slot, trav) then
                        for context, deadline in pairs(contexts) do
                            local ind = (nci[trav.shared_identity_key] or {})[context]
                            local native_rank = production_inds(slot_key)[context]
                            if not (native_rank ~= nil and native_rank < deadline) and ind ~= nil and ind < deadline and source_inds[ind] == nil then
                                source_inds[ind] = true
                                table.insert(source_goals, { node_key = trav.shared_identity_key, context = context })
                            end
                        end
                    end
                end
            end
        end
        for slot_key, contexts in pairs(craft_position_needs) do
            local slot = graph.nodes[slot_key]
            for _, trav_key in pairs(travs) do
                local trav = graph.nodes[trav_key]
                if trav.craft_identity_key ~= nil and params.pair_ok(slot, trav) then
                    for context, deadline in pairs(contexts) do
                        local ind = (nci[trav.craft_identity_key] or {})[context]
                        local craft_key = (graph.craft_positions or {})[slot_key]
                        local native_rank = craft_key ~= nil and production_inds(craft_key)[context] or nil
                        if not (native_rank ~= nil and native_rank < deadline) and ind ~= nil and ind < deadline and source_inds[ind] == nil then
                            source_inds[ind] = true
                            table.insert(source_goals, { node_key = trav.craft_identity_key, context = context })
                        end
                    end
                end
            end
        end
        local shared_sources = {}
        if #source_goals > 0 then
            local all_goals = table.deepcopy(goals)
            for _, goal in pairs(source_goals) do
                table.insert(all_goals, goal)
            end
            closure, support = make_prover(graph, sort_info).prove(goal_inds_of(all_goals, sort_info))
            needs, requires_launchable, position_needs, craft_needs, craft_position_needs = needs_from_proof(graph, sort_info, closure, support, assignment, chain_of)
            for _, goal in pairs(source_goals) do
                local ind = nci[goal.node_key][goal.context]
                if closure[ind] then
                    shared_sources[goal.node_key] = shared_sources[goal.node_key] or {}
                    shared_sources[goal.node_key][goal.context] = ind
                end
            end
        end
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
            new_assignment = random_matching(params, graph, sort_info, needs, requires_launchable, assignment, rng.key({ id = "monotone-matching-" .. round .. "-" .. num_refinements }), wants, position_needs, shared_sources, craft_needs, craft_position_needs)
            if new_assignment == nil then
                if #operation_failures(params, graph, sort_info, assignment) == 0 then
                    new_assignment = assignment
                    new_graph = graph
                    new_sort = sort_info
                    break
                end
                log("Operation matching: no complete assignment satisfies operation readiness in round " .. round)
                return false
            end
            new_assignment = realize(params, new_assignment)
            new_graph = connect(table.deepcopy(params.unconnected_graph), params, new_assignment)
            new_sort = complex_sort(new_graph)
            -- Candidate supplies are proved up front, but only supplies this assignment actually borrows are obligations of its final gate.
            local used_sources = {}
            local function borrow(identity, context)
                if identity ~= nil and ((shared_sources or {})[identity] or {})[context] ~= nil then
                    used_sources[identity] = used_sources[identity] or {}
                    used_sources[identity][context] = true
                end
            end
            for slot_key, trav_key in pairs(new_assignment) do
                local trav = graph.nodes[trav_key]
                for context, deadline in pairs(position_needs[slot_key] or {}) do
                    local native = production_inds(slot_key)[context]
                    if native == nil or native >= deadline then
                        borrow(trav.shared_identity_key, context)
                    end
                end
                local craft_key = (graph.craft_positions or {})[slot_key]
                for context, deadline in pairs(craft_position_needs[slot_key] or {}) do
                    local native = craft_key ~= nil and production_inds(craft_key)[context] or nil
                    if native == nil or native >= deadline then
                        borrow(trav.craft_identity_key, context)
                    end
                end
            end
            local source_exact = table.deepcopy(exact)
            for _, goal in pairs(source_goals) do
                if (used_sources[goal.node_key] or {})[goal.context] ~= nil then
                    table.insert(source_exact, goal)
                end
            end
            local lost = lost_pebbles(source_exact, recipes, new_sort)
            local idle = operation_failures(params, new_graph, new_sort, new_assignment)
            local num_rejected = 0
            for _, pair in pairs(idle) do
                params.operation_rejected[pair.trav] = params.operation_rejected[pair.trav] or {}
                if params.operation_rejected[pair.trav][pair.slot] == nil then
                    num_rejected = num_rejected + 1
                end
                params.operation_rejected[pair.trav][pair.slot] = true
            end
            if #idle > 0 then
                log("Operation matching: " .. #idle .. " buildings precede their operation inputs; first " .. idle[1].trav .. " at " .. idle[1].slot)
            end
            -- Debt goals are only checked once the game itself keeps everything, since that's the cheaper sort
            local lost_debt = {}
            local new_sup_graph
            local new_sup_sort
            if #lost == 0 and debt_goals ~= nil then
                new_sup_graph, new_sup_sort = superposed_sort(new_graph, params.debt)
                lost_debt = matching.lost_debt_goals(debt_goals, new_sup_sort)
            end
            if #lost == 0 and #lost_debt == 0 and #idle == 0 then
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
            if example ~= nil then
                log("Monotone matching: round " .. round .. " lost " .. #lost .. " hard pebbles and " .. #lost_debt .. " debt goals (e.g. " .. example.node_key .. " @ " .. example.context .. "); added " .. num_added .. " needs")
            end
            if (num_added == 0 and num_rejected == 0) or num_refinements >= 10 then
                if #operation_failures(params, graph, sort_info, assignment) == 0 then
                    -- Retain a validated placement only after refinements stop adding information or hit the limit.
                    new_assignment = assignment
                    new_graph = graph
                    new_sort = sort_info
                    break
                elseif #idle == 0 or num_refinements >= 10 then
                    log("Operation matching: the previous assignment isn't operation-ready either; retrying unified randomization")
                    return false
                end
                -- An unready original placement cannot be retained; rejected pairs still give the next refinement new information.
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
            -- A failed reachability gate already rejects this trial, so its operation proofs cannot change the decision.
            if #lost > 0 then
                return lost
            end
            for _, pair in pairs(operation_failures(params, trial_graph, trial_sort, trial)) do
                table.insert(lost, {
                    node_key = pair.trav,
                    context = "operation readiness",
                })
            end
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
    if params.is_resource_slot ~= nil then
        local changed, total = 0, 0
        for slot_key, trav_key in pairs(assignment) do
            if params.is_resource_slot(slot_key) then
                total = total + 1
                if is_new_resource_trav(params, slot_key, trav_key) then changed = changed + 1 end
            end
        end
        log("Resource matching: final assignment changes " .. changed .. " of " .. total .. " deposits, after form trades")
    end
    return assignment, debt_goals
end

return matching
