-- Material costs from the logic graph's own cost model: node costs and edge amounts (see lib/logic/concrete.lua and abstract.lua)
-- Semantics are those of lib/cost/dependency_graph_lp.py, which solves the same graph as an LP:
--   AND node = action, costing node.cost per run; OR node = material/state, costing node.cost per unit on top of how it's made
--   OR -> AND: the action consumes amount of the OR per run; AND -> OR: the action produces amount of the OR per run
--   AND -> AND: the second action consumes amount runs of the first; OR -> OR: amount of the first becomes one of the second
--   A missing amount is 0: a capability, needed but not consumed; an OR made by an action with a missing amount (autoplace, unlocks) is free once that action is
-- Each material's price is the cheapest way to make one unit, like the LP maximizing each price on its own, so co-products get no credit
-- With slot costs, nodes and edges also charge their slot_additional_cost (like the LP's slot solve), which prices the player's own time dearly (mining rocks by hand, say)
-- Prices are per context, following the context sort: edges keep their context, and a node sends on what arrives unless its type moves it (rooms, and forgetters like technologies and launches)
-- So something only reachable in a context has a price there, and a price is found by lowering it from infinity until nothing changes (a loop that gains material only converges towards its limit)
-- Prices are passed on cheapest first, like Dijkstra's algorithm, so most nodes get their final price the first time they're reached; the result doesn't depend on that order
-- (An action is passed on when what it makes per unit is next cheapest, since a run can make many units)

local graph_cost = {}

-- Relative drop below which a price counts as unchanged; prices come out good to about a percent (far finer than recipe balancing needs), and passing on smaller drops was most of the work
local EPSILON = 1e-3
-- Updates per node and context before a loop that keeps gaining is left where it got to (a safety net, since loops that gain are solved directly where they can be)
local MAX_UPDATES = 1000
-- Steps followed back from an ingredient to the output of the action using it, to find a loop that gains (see loop_price)
local MAX_LOOP_STEPS = 8

-- Price of one unit of an OR (or one run of an AND) through the edge from pre_node, given pre_price
-- With slot costs, an OR --> OR edge charges its slot_additional_cost per unit made (the LP puts it on the action between the two)
local function through_edge(pre_node, edge, pre_price, slot)
    local amount = edge.amount or 0
    if pre_node.op == "AND" then
        -- Each run makes amount units; an action making an unmeasured amount makes it for free
        if amount > 0 then
            return pre_price / amount
        end
        return 0
    end
    -- amount units of the prerequisite make one unit
    return amount * pre_price + (slot and edge.slot_additional_cost or 0)
end

-- A node's own cost, with its slot_additional_cost when pricing with slot costs
local function node_cost(node, slot)
    return (node.cost or 0) + (slot and node.slot_additional_cost or 0)
end

-- graph: a logic graph (lib/logic/init.lua)
-- contexts: list of context keys; transmit(node, incoming): contexts leaving node when incoming arrives (like top.node_transmit)
-- excluded (optional): node key --> whether to treat the node as unavailable; slot (optional): whether to charge slot costs too
-- Returns node key --> context --> price (OR: per unit, AND: per run); missing where it can't be had in that context
graph_cost.compute = function(graph, contexts, transmit, excluded, slot)
    local nodes = graph.nodes
    local edges = graph.edges
    local price = {}
    local num_updates = {}
    -- The edge an OR's price comes through, per context (where it stays in that context), for finding loops
    local parent = {}
    for node_key, _ in pairs(nodes) do
        price[node_key] = {}
        num_updates[node_key] = {}
        parent[node_key] = {}
    end

    local function is_excluded(node_key)
        return excluded ~= nil and excluded(node_key)
    end

    -- A node's price when context arrives at it, from its prerequisites' prices in that context, and for an OR, the edge it comes through
    local function evaluate(node_key, context)
        local node = nodes[node_key]
        local own_cost = node_cost(node, slot)
        if node.op == "AND" then
            -- Every prerequisite must be there, as in the sort, but only consumed ones add to the price
            local total = own_cost
            for edge_key, _ in pairs(node.pre) do
                local edge = edges[edge_key]
                local pre_price = price[edge.start][context]
                if pre_price == nil then
                    return nil
                end
                local amount = edge.amount or 0
                if amount > 0 then
                    total = total + amount * pre_price
                end
            end
            return total
        end
        local best
        local best_edge
        for edge_key, _ in pairs(node.pre) do
            local edge = edges[edge_key]
            local pre_price = price[edge.start][context]
            if pre_price ~= nil then
                local candidate = through_edge(nodes[edge.start], edge, pre_price, slot)
                if best == nil or candidate < best then
                    best = candidate
                    best_edge = edge_key
                end
            end
        end
        if best == nil then
            return nil
        end
        return own_cost + best, best_edge
    end

    -- Whether a node keeps the context, so its price in a context comes from its prerequisites' prices there
    local function keeps_context(node, context)
        local transmitted = transmit(node, context)
        return #transmitted == 1 and transmitted[1] == context
    end

    -- A node's price as m * (target's price) + b, following the prerequisites its price comes through back to target_key (at most MAX_LOOP_STEPS)
    -- ORs follow the edge they got their price through; ANDs are followed if they keep the context and use up just one thing (like a fluid's temperature node)
    -- Returns m, b, or nil if the price doesn't come from the target that way
    local function price_in_terms_of(node_key, target_key, context)
        local m = 1
        local b = 0
        local current = node_key
        for _ = 1, MAX_LOOP_STEPS do
            if current == target_key then
                return m, b
            end
            local node = nodes[current]
            local via
            local factor
            local extra = 0
            if node.op == "OR" then
                via = parent[current][context]
                if via == nil then
                    return nil
                end
                local edge = edges[via]
                local amount = edge.amount or 0
                if nodes[edge.start].op == "AND" then
                    if amount <= 0 then
                        return nil
                    end
                    factor = 1 / amount
                else
                    factor = amount
                    extra = slot and edge.slot_additional_cost or 0
                end
            else
                if not keeps_context(node, context) then
                    return nil
                end
                for edge_key, _ in pairs(node.pre) do
                    local amount = edges[edge_key].amount or 0
                    if amount > 0 then
                        if via ~= nil then
                            return nil
                        end
                        via = edge_key
                        factor = amount
                    end
                end
                if via == nil then
                    return nil
                end
            end
            b = b + m * (node_cost(node, slot) + extra)
            m = m * factor
            if m <= 0 then
                return nil
            end
            current = edges[via].start
        end
        if current == target_key then
            return m, b
        end
        return nil
    end

    -- The limit of a loop that gains material, like Kovarex enrichment (40 uranium-235 in, 41 out): action_key makes output_key (through out_edge) and uses up an ingredient whose price comes back from output_key
    -- Going round the loop lowers the output's price by the same fraction each time, so it only approaches its limit; that limit is solved here instead (the price with the loop's net output, as in the LP)
    -- With p the output's price: the ingredient costs m * p + b (price_in_terms_of), the action costs k + a_in * (m * p + b) (k: everything else it uses), and p = own + action / a_out
    -- Returns nil where there's no such loop in context, or it doesn't gain
    local function loop_price(action_key, action_price, out_edge, output_key, context)
        local action = nodes[action_key]
        local a_out = out_edge.amount or 0
        local best
        for edge_key, _ in pairs(action.pre) do
            local in_edge = edges[edge_key]
            local a_in = in_edge.amount or 0
            local ingredient_key = in_edge.start
            local ingredient_price = price[ingredient_key][context]
            if a_in > 0 and ingredient_price ~= nil then
                local m, b = price_in_terms_of(ingredient_key, output_key, context)
                if m ~= nil and a_in * m / a_out < 1 and keeps_context(action, context) then
                    local gain = a_in * m / a_out
                    local k = action_price - a_in * ingredient_price
                    local limit = (node_cost(nodes[output_key], slot) + (k + a_in * b) / a_out) / (1 - gain)
                    if best == nil or limit < best then
                        best = limit
                    end
                end
            end
        end
        return best
    end

    -- Min-heap of prices to pass on (key, price, node, context), ties in the order pushed
    local heap_keys = {}
    local heap_prices = {}
    local heap_nodes = {}
    local heap_contexts = {}
    local heap_orders = {}
    local heap_size = 0
    local num_pushed = 0
    local function before(a, b)
        return heap_keys[a] < heap_keys[b] or (heap_keys[a] == heap_keys[b] and heap_orders[a] < heap_orders[b])
    end
    local function swap(a, b)
        heap_keys[a], heap_keys[b] = heap_keys[b], heap_keys[a]
        heap_prices[a], heap_prices[b] = heap_prices[b], heap_prices[a]
        heap_nodes[a], heap_nodes[b] = heap_nodes[b], heap_nodes[a]
        heap_contexts[a], heap_contexts[b] = heap_contexts[b], heap_contexts[a]
        heap_orders[a], heap_orders[b] = heap_orders[b], heap_orders[a]
    end
    -- An action's key is the cheapest a unit of what it makes gets from it, so its outputs are reached in order of their prices
    local function key_of(new, node_key)
        local node = nodes[node_key]
        local key = new
        if node.op == "AND" then
            for edge_key, _ in pairs(node.dep) do
                local edge = edges[edge_key]
                if nodes[edge.stop].op == "OR" then
                    local candidate = node_cost(nodes[edge.stop], slot) + through_edge(node, edge, new, slot)
                    if candidate < key then
                        key = candidate
                    end
                end
            end
        end
        return key
    end
    local function push(new, node_key, context)
        heap_size = heap_size + 1
        num_pushed = num_pushed + 1
        heap_keys[heap_size] = key_of(new, node_key)
        heap_prices[heap_size] = new
        heap_nodes[heap_size] = node_key
        heap_contexts[heap_size] = context
        heap_orders[heap_size] = num_pushed
        local child = heap_size
        while child > 1 do
            local parent = math.floor(child / 2)
            if not before(child, parent) then
                break
            end
            swap(child, parent)
            child = parent
        end
    end
    local function pop()
        local new, node_key, context = heap_prices[1], heap_nodes[1], heap_contexts[1]
        swap(1, heap_size)
        heap_keys[heap_size] = nil
        heap_prices[heap_size] = nil
        heap_nodes[heap_size] = nil
        heap_contexts[heap_size] = nil
        heap_orders[heap_size] = nil
        heap_size = heap_size - 1
        local parent = 1
        while true do
            local smallest = parent
            local left = 2 * parent
            local right = left + 1
            if left <= heap_size and before(left, smallest) then
                smallest = left
            end
            if right <= heap_size and before(right, smallest) then
                smallest = right
            end
            if smallest == parent then
                break
            end
            swap(parent, smallest)
            parent = smallest
        end
        return new, node_key, context
    end

    -- Lowers a node's price in the contexts it sends arriving on to, where new is cheaper, and queues it to be passed on
    -- via: for an OR, the edge the price comes through
    local function offer(node_key, arriving, new, via)
        for _, leaving in pairs(transmit(nodes[node_key], arriving)) do
            local old = price[node_key][leaving]
            if old == nil or old - new > EPSILON * old then
                num_updates[node_key][leaving] = (num_updates[node_key][leaving] or 0) + 1
                if num_updates[node_key][leaving] <= MAX_UPDATES then
                    price[node_key][leaving] = new
                    if leaving == arriving then
                        parent[node_key][leaving] = via
                    else
                        parent[node_key][leaving] = nil
                    end
                    push(new, node_key, leaving)
                end
            end
        end
    end

    -- Start from what needs nothing (actions without prerequisites)
    local sorted_node_keys = {}
    for node_key, _ in pairs(nodes) do
        if not is_excluded(node_key) then
            table.insert(sorted_node_keys, node_key)
        end
    end
    table.sort(sorted_node_keys)
    local sorted_contexts = {}
    for _, context in pairs(contexts) do
        table.insert(sorted_contexts, context)
    end
    table.sort(sorted_contexts)
    for _, node_key in pairs(sorted_node_keys) do
        for _, context in pairs(sorted_contexts) do
            local new, via = evaluate(node_key, context)
            if new ~= nil then
                offer(node_key, context, new, via)
            end
        end
    end

    while heap_size > 0 do
        local passed, node_key, context = pop()
        -- Skip a price that was lowered again since it was queued (the lower one is queued too)
        if price[node_key][context] == passed then
            local node = nodes[node_key]
            for edge_key, _ in pairs(node.dep) do
                local edge = edges[edge_key]
                local dep_key = edge.stop
                if not is_excluded(dep_key) then
                    local dep = nodes[dep_key]
                    local new
                    if dep.op == "AND" then
                        new = evaluate(dep_key, context)
                    else
                        -- An OR's other prerequisites were offered when they got their prices, so only this one can lower it now
                        new = node_cost(dep, slot) + through_edge(node, edge, passed, slot)
                        if node.op == "AND" and (edge.amount or 0) > 0 then
                            local limit = loop_price(node_key, passed, edge, dep_key, context)
                            if limit ~= nil and limit < new then
                                new = limit
                            end
                        end
                    end
                    if new ~= nil then
                        offer(dep_key, context, new, edge_key)
                    end
                end
            end
        end
    end

    return price
end

-- Prices for the contexts and context rules of a sort made by top.sort (lib/graph/context-sort.lua)
graph_cost.compute_for_sort = function(graph, sort_info, excluded, slot)
    local top = require("lib/graph/context-sort")
    local logic = require("lib/logic/init")
    local contexts = {}
    for context, _ in pairs(logic.contexts) do
        table.insert(contexts, context)
    end
    return graph_cost.compute(graph, contexts, function(node, incoming)
        return top.node_transmit(sort_info, node, incoming)
    end, excluded, slot)
end

-- Types of the nodes through which a material is made by recipes
local CRAFT_TYPES = {
    ["item-craft"] = true,
    ["fluid-craft"] = true,
    ["fluid-craft-temperature"] = true,
}

-- Types of the nodes through which an entity or tile is ours because we placed it; mining or killing what we placed gives back what we put in, so it's no source
local PLACED_TYPES = {
    ["entity-own"] = true,
    ["tile-build"] = true,
    ["tile-build-space"] = true,
}

-- A material's price in a context without its recipes: follows its own acquisition nodes (those built for its prototype), skipping the craft ones, and uses full prices for everything else (machines, fuel, fluids a drill needs)
-- The entities and tiles an action there uses up only count as the world gives them (autoplace, spawning, hatching), not as we placed them
-- material_key: its item or fluid node key; prices: from graph_cost.compute (slot: whether they charged slot costs, so this does too)
-- Returns nil if only recipes make it there
graph_cost.price_without_recipes = function(graph, prices, material_key, context, slot)
    local nodes = graph.nodes
    local edges = graph.edges
    local prot = nodes[material_key].prot
    local memo = {}
    local visiting = {}

    -- Whether a node can be something we placed (an entity or tile), which a source action then uses up
    local function can_be_placed(node_key)
        for edge_key, _ in pairs(nodes[node_key].pre) do
            if PLACED_TYPES[nodes[edges[edge_key].start].type] ~= nil then
                return true
            end
        end
        return false
    end

    -- An entity or tile's price as the world gives it
    local function world_price(node_key)
        local node = nodes[node_key]
        local best
        for edge_key, _ in pairs(node.pre) do
            local edge = edges[edge_key]
            if PLACED_TYPES[nodes[edge.start].type] == nil then
                local pre_price = prices[edge.start][context]
                if pre_price ~= nil then
                    local candidate = through_edge(nodes[edge.start], edge, pre_price, slot)
                    if best == nil or candidate < best then
                        best = candidate
                    end
                end
            end
        end
        if best == nil then
            return nil
        end
        return node_cost(node, slot) + best
    end

    -- An action outside the material's own nodes that makes it (like mining or killing something), with what it uses up priced as the world gives it
    local function source_price(node_key)
        local node = nodes[node_key]
        if node.op ~= "AND" then
            return prices[node_key][context]
        end
        local total = node_cost(node, slot)
        for edge_key, _ in pairs(node.pre) do
            local edge = edges[edge_key]
            local pre_price
            if can_be_placed(edge.start) then
                pre_price = world_price(edge.start)
            else
                pre_price = prices[edge.start][context]
            end
            if pre_price == nil then
                return nil
            end
            if (edge.amount or 0) > 0 then
                total = total + edge.amount * pre_price
            end
        end
        return total
    end

    local function own_price(node_key)
        local node = nodes[node_key]
        if node.prot ~= prot then
            return source_price(node_key)
        end
        if CRAFT_TYPES[node.type] ~= nil then
            return nil
        end
        if memo[node_key] ~= nil then
            return memo[node_key] or nil
        end
        if visiting[node_key] ~= nil then
            -- A loop within the material's own nodes (like delivering it by rocket); it can't be cheaper than what enters the loop
            return nil
        end
        visiting[node_key] = true
        local own_cost = node_cost(node, slot)
        local result
        if node.op == "AND" then
            result = own_cost
            for edge_key, _ in pairs(node.pre) do
                local edge = edges[edge_key]
                local pre_price = own_price(edge.start)
                if pre_price == nil then
                    result = nil
                    break
                end
                if (edge.amount or 0) > 0 then
                    result = result + edge.amount * pre_price
                end
            end
        else
            for edge_key, _ in pairs(node.pre) do
                local edge = edges[edge_key]
                local pre_price = own_price(edge.start)
                if pre_price ~= nil then
                    local candidate = through_edge(nodes[edge.start], edge, pre_price, slot)
                    if result == nil or candidate < result then
                        result = candidate
                    end
                end
            end
            if result ~= nil then
                result = own_cost + result
            end
        end
        visiting[node_key] = nil
        memo[node_key] = result or false
        return result
    end

    return own_price(material_key)
end

-- Materials resource entities give that the starting room has without any research, like ores mined by hand or with a burner drill, as "type-name" ids (sorted)
-- These are the resources whose balance recipe randomization tracks separately (randomization_info.options.cost.major_raw_resources)
graph_cost.starting_resources = function(graph, sort_info, starting_context)
    local dutils = require("lib/data-utils")
    local gutils = require("lib/graph/graph-utils")
    local no_research = graph_cost.compute_for_sort(graph, sort_info, function(node_key)
        return graph.nodes[node_key].type == "technology"
    end)
    local found = {}
    for _, resource in pairs(dutils.prots("resource")) do
        for _, result in pairs(dutils.minable_results(resource)) do
            local material_key = gutils.key(result.type, result.name)
            if graph.nodes[material_key] ~= nil and graph_cost.price_without_recipes(graph, no_research, material_key, starting_context) ~= nil then
                found[result.type .. "-" .. result.name] = true
            end
        end
    end
    local ids = {}
    for id, _ in pairs(found) do
        table.insert(ids, id)
    end
    table.sort(ids)
    return ids
end

-- How much graph prices are scaled for recipe costs, whose time and complexity terms (lib/cost/flow-cost.lua) were tuned with ores costing about 1, as they do in the graph
graph_cost.RAW_COST_SCALE = 1

-- Whether a node can be had automatably somewhere, by a sort with complex contexts (top.sort with complex_contexts), as a function of the node key
graph_cost.automatable_in_sort = function(complex_sort_info)
    local top = require("lib/graph/context-sort")
    return function(node_key)
        for context, _ in pairs(complex_sort_info.node_to_context_inds[node_key] or {}) do
            local abilities = top.context_abilities(context)
            if abilities ~= nil and string.sub(abilities, top.AUTOMATABILITY, top.AUTOMATABILITY) == "1" then
                return true
            end
        end
        return false
    end
end

-- The whole-game raw costs (lib/cost/context-costs.lua's raw_costs, by material id) of just the materials the game gives automatably (is_automatable: node key --> whether)
-- Callers pricing the whole game at once (like recipe randomization outside unified, randomizations/graph/recipe.lua) take having a cost as being usable in automated recipes
-- So what only the player can gather (wood from trees and fish in base) stays unpriced there, as in the hand-made table this replaced
graph_cost.automatable_raw_costs = function(graph, raw_costs, is_automatable)
    local costs = {}
    for node_key, node in pairs(graph.nodes) do
        if node.type == "item" or node.type == "fluid" then
            local id = node.type .. "-" .. node.name
            if raw_costs[id] ~= nil and is_automatable(node_key) then
                costs[id] = raw_costs[id]
            end
        end
    end
    return costs
end

-- Fills randomization_info.options.cost from the logic graph: whole-game raw material costs of what the game gives automatably (default_cost_table) and the major resources (major_raw_resources)
-- complex_sort_info: a sort of the same graph with complex contexts, for automatability
-- Tables are filled in place, since modules like randomizations/graph/recipe-cost.lua keep references to them
-- Costs a compat file set already are kept
graph_cost.derive_cost_options = function(graph, sort_info, starting_context, complex_sort_info)
    local cost_options = randomization_info.options.cost
    cost_options.default_cost_table = cost_options.default_cost_table or {}
    cost_options.major_raw_resources = cost_options.major_raw_resources or {}

    local major = cost_options.major_raw_resources
    for i = #major, 1, -1 do
        major[i] = nil
    end
    for _, id in pairs(graph_cost.starting_resources(graph, sort_info, starting_context)) do
        table.insert(major, id)
    end

    -- Slot costs price the player's own time (hand mining, say) dearly, so materials only gotten by hand aren't cheap
    local prices = graph_cost.compute_for_sort(graph, sort_info, nil, true)
    -- What each room has and makes, which recipe randomization prices with (lib/cost/context-costs.lua), with the game's costs tracking the major resources
    local context_costs = require("lib/cost/context-costs")
    context_costs.current = context_costs.build(graph, sort_info, prices, starting_context, require("lib/logic/init").contexts, true, major)
    for id, cost in pairs(graph_cost.automatable_raw_costs(graph, context_costs.current.raw_costs, graph_cost.automatable_in_sort(complex_sort_info))) do
        if cost_options.default_cost_table[id] == nil then
            cost_options.default_cost_table[id] = cost
        end
    end

    local ids = {}
    for id, _ in pairs(cost_options.default_cost_table) do
        table.insert(ids, id)
    end
    table.sort(ids)
    for _, id in pairs(ids) do
        log("Raw cost " .. id .. " = " .. cost_options.default_cost_table[id])
    end
    log("Major raw resources: " .. table.concat(major, ", "))
end

return graph_cost
