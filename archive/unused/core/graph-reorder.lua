local build_graph = require("lib/graph/build-graph")
local graph_utils = require("lib/graph/graph-utils")
local set_utils = require("lib/graph/set-utils")
local queue = require("lib/graph/queue")
local pq = require("lib/graph/priority-queue")
local displace = require("lib/random/displacement-shuffle")
local helpers = require("randomizations/graph/core/helpers")

local export = {}

local sort_shuffled_order = function (state)
    assert(not set_utils.set_empty(state.vanilla_graph))
    assert(not set_utils.set_empty(state.shuffled_order_graph))
    assert(#state.shuffled_order > 0)
    assert(not set_utils.set_empty(state.shuffled_order_ordinals))
    assert(not set_utils.set_empty(state.target_edges))

    local reachable = {}
    local reachable_condition = function (node)
        local node_reachable = true
        if graph_utils.is_and_node(node) then
            for _, prereq in pairs(node.prereqs) do
                if not reachable[graph_utils.get_node_key(prereq)] then
                    return false
                end
            end
        elseif graph_utils.is_or_node(node) then
            node_reachable = false
            for _, prereq in pairs(node.prereqs) do
                if reachable[graph_utils.get_node_key(prereq)] then
                    return true
                end
            end
        else
            error("how")
        end
        return node_reachable
    end

    local unreachable_prereqs = {}
    local get_prereq_type_surface_key = function (prereq_type, surface_key)
        local no_surface = "no_surface"
        if surface_key == nil then
            surface_key = no_surface
        end
        return build_graph.compound_key({prereq_type, surface_key})
    end

    local postponed = {}
    local new_shuffled_order = {}
    local node_queue = pq.new(function (node_key)
        return state.shuffled_order_ordinals[node_key]
    end)
    pq.push(node_queue, state.arbitrary_unlock_node_key)
    local ordinal = 1
    while ordinal <= #state.shuffled_order do
        if pq.is_empty(node_queue) then
            local node = state.shuffled_order[ordinal]
            local node_key = graph_utils.get_node_key(node)

            -- Treat undetermined edges as reachable
            local undetermined_edges = {}
            for _, prereq in pairs(node.prereqs) do
                local prereq_key = graph_utils.get_node_key(prereq)
                local edge = graph_utils.create_edge(prereq_key, node_key, state.shuffled_order_graph)
                if state.target_edges[edge.key] ~= nil then
                    undetermined_edges[#undetermined_edges+1] = edge
                end
            end
            if #undetermined_edges > 0 and graph_utils.is_and_node(node) then
                for _, edge in pairs(undetermined_edges) do
                    graph_utils.delete_edge(state.shuffled_order_graph, edge)
                end
            elseif #undetermined_edges > 0 and graph_utils.is_or_node(node) then
                state.force_reachable(node, state.shuffled_order_graph)
            end

            -- Keep track of prereqs for later
            if state.target_prereq_types[node.type] ~= nil then
                local vanilla_node = state.vanilla_graph[node_key]
                local key = get_prereq_type_surface_key(node.type, node.surface)
                for _, dependent in pairs(vanilla_node.dependents) do
                    local dependent_key = graph_utils.get_node_key(dependent)
                    local edge = graph_utils.create_edge(node_key, dependent_key, state.vanilla_graph)
                    if state.target_edges[edge.key] ~= nil then
                        if unreachable_prereqs[key] == nil then
                            unreachable_prereqs[key] = {}
                        end
                        unreachable_prereqs[key][node_key] = true
                    end
                end
            end

            pq.push(node_queue, node_key)
            ordinal = ordinal + 1
        end

        while not pq.is_empty(node_queue) do
            local node_key = pq.pop(node_queue)
            if reachable[node_key] == nil then
                local node = state.shuffled_order_graph[node_key]

                -- Check reachable
                local prereqs_reachable = reachable_condition(node)
                if prereqs_reachable then
                    reachable[node_key] = true
                    new_shuffled_order[#new_shuffled_order+1] = state.shuffled_order_graph[node_key]

                    -- Add postponed dependents
                    for _, dependent in pairs(node.dependents) do
                        local dependent_key = graph_utils.get_node_key(dependent)
                        local edge = graph_utils.create_edge(node_key, dependent_key, state.shuffled_order_graph)
                        if state.target_edges[edge.key] == nil and postponed[dependent_key] ~= nil then
                            postponed[dependent_key] = nil
                            pq.push(node_queue, dependent_key)
                        end
                    end
                else
                    postponed[node_key] = true
                end
            end
        end
    end
    assert(#state.shuffled_order == #new_shuffled_order)
    assert(set_utils.set_empty(postponed))

    state.shuffled_order = new_shuffled_order
    state.shuffled_order_ordinals = {}
    for i, node in pairs(new_shuffled_order) do
        local node_key = graph_utils.get_node_key(node)
        state.shuffled_order_ordinals[node_key] = i
    end
    state.shuffled_order_ordinals.MAX = #new_shuffled_order + 1

    -----------------------------------------------------------------------------------------------------------------------
    --- Consider the amount of prereqs we're accumulating to not run out at any point
    --- Don't even bother with keeping track of how many unique ones we have, probably not necessary...
    -----------------------------------------------------------------------------------------------------------------------

    local add_to_prereq_counter = function (prereq_counter, prereq_type, surface_key, amount)
        local key = get_prereq_type_surface_key(prereq_type, surface_key)
        if prereq_counter[key] == nil then
            prereq_counter[key] = 0
        end
        prereq_counter[key] = prereq_counter[key] + amount
    end

    local cost_per_node_key = {}
    local prereq_cost = function (node_key)
        if cost_per_node_key[node_key] ~= nil then
            return cost_per_node_key[node_key]
        end
        local node = state.vanilla_graph[node_key]
        local cost = {}
        if state.target_dependent_types[node.type] == nil then
            return cost
        end
        for _, prereq in pairs(node.prereqs) do
            local prereq_key = graph_utils.get_node_key(prereq)
            local edge = graph_utils.create_edge(prereq_key, node_key, state.vanilla_graph)
            if state.target_edges[edge.key] ~= nil then
                local surface = state.vanilla_graph[prereq_key].surface
                add_to_prereq_counter(cost, prereq.type, surface, 1)
            end
        end
        cost_per_node_key[node_key] = cost
        return cost
    end

    local yield_per_node_key = {}
    local prereq_yield = function (node_key)
        if yield_per_node_key[node_key] ~= nil then
            return yield_per_node_key[node_key]
        end
        local node = state.shuffled_order_graph[node_key]
        local yield = {}
        if state.target_prereq_types[node.type] == nil then
            return yield
        end
        local vanilla_node = state.vanilla_graph[node_key]
        local edge_count = 0
        for _, dependent in pairs(vanilla_node.dependents) do
            local dependent_key = graph_utils.get_node_key(dependent)
            local edge = graph_utils.create_edge(node_key, dependent_key, state.vanilla_graph)
            if state.target_edges[edge.key] ~= nil then
                edge_count = edge_count + 1
            end
        end
        add_to_prereq_counter(yield, node.type, node.surface, edge_count)
        yield_per_node_key[node_key] = yield
        return yield
    end

    local predicted_yield_per_node_key = {}
    local predicted_prereq_yield = function (node_key) return {} end
    predicted_prereq_yield = function (node_key)
        if predicted_yield_per_node_key[node_key] ~= nil then
            return predicted_yield_per_node_key[node_key]
        end
        local node = state.shuffled_order_graph[node_key]
        local yield = table.deepcopy(prereq_yield(node_key))
        for _, dependent in pairs(node.dependents) do
            local dependent_key = graph_utils.get_node_key(dependent)
            if state.shuffled_order_ordinals[node_key] < state.shuffled_order_ordinals[dependent_key] then
                local dependent_node = state.shuffled_order_graph[dependent_key]
                local prereq_count = 0
                for _, prereq in pairs(dependent_node.prereqs) do
                    local prereq_key = graph_utils.get_node_key(prereq)
                    if state.shuffled_order_ordinals[prereq_key] < state.shuffled_order_ordinals[dependent_key] then
                        prereq_count = prereq_count + 1
                    end
                end
                assert(prereq_count > 0)
                local dependent_yield = predicted_prereq_yield(dependent_key)
                for key, dependent_yield_amount in pairs(dependent_yield) do
                    local yield_amount = yield[key] or 0
                    yield[key] = yield_amount + dependent_yield_amount / prereq_count
                end
            end
        end
        predicted_yield_per_node_key[node_key] = yield
        return yield
    end

    local prereq_counter = {}
    local get_unaffordable_prereq_types = function (node)
        local node_key = graph_utils.get_node_key(node)
        local cost = prereq_cost(node_key)
        local unaffordable_prereq_types = {}
        local yield = table.deepcopy(prereq_yield(node_key))
        local status = "affordable"
        local affordable = true
        local margin = true
        for key, cost_amount in pairs(cost) do
            local current_amount = prereq_counter[key] or 0
            local yield_amount = yield[key] or 0

            -- Does this require more prereqs than we currently have?
            if current_amount - cost_amount < 0 then
                unaffordable_prereq_types[key] = true
                affordable = false
            end
            -- Will this leave us with less prereqs than this node costs?
            if current_amount + yield_amount - cost_amount < cost_amount then
                -- Okay if all prereqs are already reachable
                if not set_utils.set_empty(unreachable_prereqs[key]) then
                    unaffordable_prereq_types[key] = true
                    margin = false
                end
            end
        end
        if not affordable then
            status = "unaffordable"
        elseif not margin then
            status = "risky"
        end
        return { unaffordable = unaffordable_prereq_types, status = status }
    end

    local iter_dependent_prereqs_bfs = function (target_node_key)
        local nodes = queue.new()
        queue.push(nodes, target_node_key)
        local discovered = {}
        return function ()
            while not queue.is_empty(nodes) do
                local node_key = queue.pop(nodes)
                if discovered[node_key] == nil then
                    discovered[node_key] = true
                    local node = state.shuffled_order_graph[node_key]
                    for _, dependent in pairs(node.dependents) do
                        local dependent_key = graph_utils.get_node_key(dependent)
                        if state.shuffled_order_ordinals[node_key] < state.shuffled_order_ordinals[dependent_key] then
                            queue.push(nodes, dependent_key)
                        end
                    end
                    local yield = prereq_yield(node_key)
                    if not set_utils.set_empty(yield) then
                        return node_key
                    end
                end
            end
            return nil
        end
    end

    local iter_unreachable_path_bfs = function (target_node_key)
        local nodes = queue.new()
        queue.push(nodes, target_node_key)
        local discovered = {}
        return function ()
            while not queue.is_empty(nodes) do
                local node_key = queue.pop(nodes)
                if discovered[node_key] == nil and reachable[node_key] == nil then
                    discovered[node_key] = true
                    local node = state.shuffled_order_graph[node_key]
                    if graph_utils.is_and_node(node) then
                        for _, prereq in pairs(node.prereqs) do
                            local prereq_key = graph_utils.get_node_key(prereq)
                            if reachable[prereq_key] == nil then
                                queue.push(nodes, prereq_key)
                            end
                        end
                    elseif graph_utils.is_or_node(node) then
                        assert(#node.prereqs > 0)
                        local first_prereq_key = "MAX"
                        for _, prereq in pairs(node.prereqs) do
                            local prereq_key = graph_utils.get_node_key(prereq)
                            if state.shuffled_order_ordinals[prereq_key] < state.shuffled_order_ordinals[first_prereq_key] then
                                first_prereq_key = prereq_key
                            end
                        end
                        assert(first_prereq_key ~= "MAX")
                        if reachable[first_prereq_key] == nil then
                            queue.push(nodes, first_prereq_key)
                        end
                    end
                    if node_key ~= target_node_key then
                        return node_key
                    end
                end
            end
            return nil
        end
    end

    local eval_cost = function (yield, cost, target_prereq_keys)
        local repays = true
        local affordable = true
        for key, cost_amount in pairs(cost) do
            local current_amount = prereq_counter[key] or 0
            if cost_amount > current_amount then
                affordable = false
            end
            local yield_amount = yield[key] or 0
            if target_prereq_keys[key] ~= nil and cost_amount > yield_amount then
                repays = false
            end
        end
        return { repays = repays, affordable = affordable }
    end

    reachable = {}
    local any_prereq_will_repay = function (node_key, target_prereq_keys)
        local unaffordable_nodes = {}
        for prereq_key in iter_dependent_prereqs_bfs(node_key) do
            local cumulative_cost = table.deepcopy(prereq_cost(prereq_key))
            local yield = prereq_yield(prereq_key)
            local result = eval_cost(yield, cumulative_cost, target_prereq_keys)
            if result.affordable then
                for path_node_key, _ in iter_unreachable_path_bfs(prereq_key) do
                    if unaffordable_nodes[path_node_key] ~= nil then
                        result.affordable = false
                        break
                    end
                    local cost = prereq_cost(path_node_key)
                    for key, cost_amount in pairs(cost) do
                        local cumulative_cost_amount = cumulative_cost[key] or 0
                        cumulative_cost[key] = cumulative_cost_amount + cost_amount
                    end
                    if not set_utils.set_empty(cost) then
                        result = eval_cost(yield, cumulative_cost, target_prereq_keys)
                        if not result.affordable then
                            break
                        end
                    end
                end
                if result.affordable and result.repays then
                    return true
                end
            end
            if not result.affordable then
                unaffordable_nodes[prereq_key] = true
            end
        end
        return false
    end

    new_shuffled_order = {}
    local consider_node = function (local_ordinal, node_key) end
    consider_node = function (local_ordinal, node_key)
        if reachable[node_key] == nil then
            local node = state.shuffled_order_graph[node_key]

            -- Check reachable
            local prereqs_reachable = reachable_condition(node)

            if prereqs_reachable then
                -- Check if we have enough prereqs
                local unaffordable_result = get_unaffordable_prereq_types(node)
                local unaffordable = unaffordable_result.unaffordable
                local status = unaffordable_result.status
                if status == "risky" and any_prereq_will_repay(node_key, unaffordable) then
                    status = "affordable"
                end
                local out_of_nodes = false
                local other_ordinal = local_ordinal
                while not (status == "affordable") and not out_of_nodes do
                    out_of_nodes = true

                    -- Consider another node that is affordable first
                    while other_ordinal <= #state.shuffled_order do
                        local other_node = state.shuffled_order[other_ordinal]
                        local other_node_key = graph_utils.get_node_key(other_node)
                        local other_cost = prereq_cost(other_node_key)
                        local consider = true
                        if consider and reachable[other_node_key] ~= nil then
                            consider = false
                        end
                        if consider and not reachable_condition(other_node) then
                            consider = false
                        end
                        local union_unaffordable = unaffordable
                        if consider then
                            local other_unaffordable_result = get_unaffordable_prereq_types(other_node)
                            local other_status = other_unaffordable_result.status
                            if other_status == "unaffordable" then
                                consider = false
                            elseif other_status == "risky" then
                                union_unaffordable = table.deepcopy(unaffordable)
                                set_utils.merge_union(union_unaffordable, other_unaffordable_result.unaffordable)
                            end
                        end
                        if consider then
                            local investment = false
                            for key, _ in pairs(union_unaffordable) do
                                local cost_amount = other_cost[key] or 0
                                if cost_amount > 0 then
                                    investment = true
                                    break
                                end
                            end
                            if investment and not any_prereq_will_repay(other_node_key, union_unaffordable) then
                                consider = false
                            end
                        end
                        if consider then
                            consider_node(other_ordinal, other_node_key)
                            out_of_nodes = false
                            other_ordinal = other_ordinal + 1
                            break
                        end
                        other_ordinal = other_ordinal + 1
                    end

                    -- Check if we have enough prereqs now
                    unaffordable_result = get_unaffordable_prereq_types(node)
                    unaffordable = unaffordable_result.unaffordable
                    status = unaffordable_result.status
                end

                reachable[node_key] = true
                new_shuffled_order[#new_shuffled_order+1] = state.vanilla_graph[node_key]
                local yield = prereq_yield(node_key)
                for key, yield_amount in pairs(yield) do
                    local current_amount = prereq_counter[key] or 0
                    prereq_counter[key] = current_amount + yield_amount
                end
                local cost = prereq_cost(node_key)
                for key, cost_amount in pairs(cost) do
                    local current_amount = prereq_counter[key] or 0
                    prereq_counter[key] = current_amount - cost_amount
                    --assert(prereq_counter[key] >= 0)
                end
                if state.target_prereq_types[node.type] then
                    local prereq_type_surface_key = get_prereq_type_surface_key(node.type, node.surface)
                    unreachable_prereqs[prereq_type_surface_key][node_key] = nil
                end

                -- Add postponed dependents
                for _, dependent in pairs(node.dependents) do
                    local dependent_key = graph_utils.get_node_key(dependent)
                    local edge = graph_utils.create_edge(node_key, dependent_key, state.shuffled_order_graph)
                    if state.target_edges[edge.key] == nil and postponed[dependent_key] ~= nil then
                        postponed[dependent_key] = nil
                        pq.push(node_queue, dependent_key)
                    end
                end
            else
                postponed[node_key] = true
            end
        end
    end

    ordinal = 1
    while ordinal <= #state.shuffled_order do
        if pq.is_empty(node_queue) then
            local node = state.shuffled_order[ordinal]
            local node_key = graph_utils.get_node_key(node)
            pq.push(node_queue, node_key)
            ordinal = ordinal + 1
        end

        while not pq.is_empty(node_queue) do
            local node_key = pq.pop(node_queue)
            consider_node(ordinal, node_key)
        end
    end
    assert(#state.shuffled_order == #new_shuffled_order)
    assert(set_utils.set_empty(postponed))
    state.shuffled_order = new_shuffled_order
    state.shuffled_order_ordinals = {}
    for i, node in pairs(new_shuffled_order) do
        local node_key = graph_utils.get_node_key(node)
        state.shuffled_order_ordinals[node_key] = i
    end
end

export.generate_shuffled_order = function (state)
    -- Shuffled nodes
    state.shuffled_order = {}
    state.shuffled_order_graph = table.deepcopy(state.vanilla_graph)
    for i, node in pairs(state.vanilla_top_sort.sorted) do
        local node_key = graph_utils.get_node_key(node)
        state.shuffled_order[i] = state.shuffled_order_graph[node_key]
    end

    -- How much do we wanna displace the nodes? I have no idea...
    -- avg_displacement calculation below is completely arbitrary
    local avg_displacement = #state.shuffled_order / math.exp(3)
    displace.displacement_shuffle_chaos(state.rng_key, state.shuffled_order, avg_displacement)

    state.shuffled_order_ordinals = {}
    for i, node in pairs(state.shuffled_order) do
        state.shuffled_order_ordinals[graph_utils.get_node_key(node)] = i
    end

    -- Ensure topological ordering of nodes whose edges we're not changing
    sort_shuffled_order(state)
    -- shuffled_order now has nodes from vanilla_graph
    state.shuffled_order_graph = nil

    state.shuffled_order_ordinals.MAX = #state.shuffled_order + 1
    helpers.sort_all_prereqs(state.random_graph, state.shuffled_order_ordinals)
end

return export
