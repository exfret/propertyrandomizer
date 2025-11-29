local graph_utils = require("lib/graph/graph-utils")
local set_utils = require("lib/graph/set-utils")
local top_sort = require("lib/graph/top-sort")
local path_utils = require("lib/graph/path")

local min_rec_req = {}

local graph = {}
local source_nodes = {}
local breadth_first_ordinals = {}

local operator_literal = "l"
local operator_reference = "r"
local operator_union = "u"

local get_ordinal = function (key, ordinals)
    if ordinals[key] == nil then
        return ordinals.MAX
    end
    return ordinals[key]
end

local sort_prereqs = function (prereqs, ordinals)
    table.sort(prereqs, function(a, b)
        return get_ordinal(graph_utils.get_node_key(a), ordinals)
            < get_ordinal(graph_utils.get_node_key(b), ordinals)
    end)
end

local potential_requirement = function (dependent_key, prereq_key)
    return get_ordinal(prereq_key, breadth_first_ordinals) < get_ordinal(dependent_key, breadth_first_ordinals)
end

local dereference_expr = function (key, reachablility_cache)
    return reachablility_cache[key].path_expr
end

local expr_literal = function (value)
    if value == nil then
        return { op = operator_literal, literal = { } }
    end
    return { op = operator_literal, literal = { [value] = true } }
end

local expr_reference = function (key)
    return { op = operator_reference, reference = key }
end

local expr_union = function (sets)
    return { op = operator_union, sets = sets }
end

local evaluate_expr = function (expr, reachablility_cache, path_cache) return {} end

evaluate_expr = function (expr, reachablility_cache, path_cache)
    if expr.op == operator_literal then
        return expr.literal
    elseif expr.op == operator_reference then
        local key = expr.reference
        if path_cache[key] ~= nil then
            return path_cache[key]
        end
        local set = evaluate_expr(dereference_expr(key, reachablility_cache), reachablility_cache, path_cache)
        path_cache[key] = set
        return set
    elseif expr.op == operator_union then
        local set = {}
        for i = 1, #expr.sets do
            local set2 = evaluate_expr(expr.sets[i], reachablility_cache, path_cache)
            if set2 ~= nil then
                set_utils.merge_union(set, set2)
            end
        end
        return set
    end
    error()
end

local cache_and_return = function (result, dependent_key, parents, reachablility_cache)
    reachablility_cache[dependent_key] = result
    return result
end

local critical_failure_result = function ()
    return { reachable = false, terminated = true, loop = false, undetermined = false }
end

local undetermined_result = function ()
    return { reachable = false, terminated = true, loop = false, undetermined = true }
end

local unreachable_result = function ()
    return { reachable = false, terminated = false, loop = false, undetermined = false }
end

local unreachable_loop_result = function ()
    return { reachable = false, terminated = false, loop = true, undetermined = false }
end

local failure_result = function (dependent_key, parents, critical_nodes, reachablility_cache, loop)
    parents[dependent_key] = nil
    if loop then
        return unreachable_loop_result()
    end
    if critical_nodes[dependent_key] then
        return critical_failure_result()
    end
    return cache_and_return(unreachable_result(), dependent_key, parents, reachablility_cache)
end

local reachable_result = function (path)
    return { reachable = true, terminated = false, loop = false, undetermined = false, path_expr = path }
end

local success_result = function (dependent_key, parents, reachablility_cache, path_expr)
    parents[dependent_key] = nil
    return cache_and_return(reachable_result(path_expr), dependent_key, parents, reachablility_cache)
end

-- Most of these are for algorithm debugging/analysis
local get_empty_stats = function ()
    return { chache_hits = 0, removed_node_hits = 0, max_depth = 0, loop_hits = 0, nodes_checked = 0, nodes_evaluated = 0,
    and_nodes_evaluated = 0, or_nodes_evaluated = 0, and_failures = 0, or_failures = 0, and_successes = 0, or_successes = 0 }
end

-- Fast median runtime, but horrible time complexity O(n!) showcased when the algorithm hits a local minimum.
-- Configured to terminate undetermined after a while.
local check_reachable_top_down = function (dependent_node, removed_key, parents, critical_nodes, depth, reachablility_cache, stats) return {} end

check_reachable_top_down = function (dependent_node, removed_key, parents, critical_nodes, depth, reachablility_cache, stats)

    local dependent_key = graph_utils.get_node_key(dependent_node)
    stats.max_depth = math.max(stats.max_depth, depth)
    stats.nodes_checked = stats.nodes_checked + 1
    if reachablility_cache[dependent_key] ~= nil then
        stats.chache_hits = stats.chache_hits + 1
        return reachablility_cache[dependent_key]
    end
    if dependent_key == removed_key then
        stats.removed_node_hits = stats.removed_node_hits + 1
        return unreachable_result()
    end
    if parents[dependent_key] then
        stats.loop_hits = stats.loop_hits + 1
        return unreachable_loop_result()
    end

    -- These numbers were selected because they worked well with the graph at the time this was developed
    if stats.removed_node_hits >= 16 then
        return undetermined_result()
    end
    if depth >= 128 then
        return undetermined_result()
    end
    if stats.nodes_checked >= 8192 then
        return undetermined_result()
    end

    parents[dependent_key] = true
    stats.nodes_evaluated = stats.nodes_evaluated + 1
    if graph_utils.is_and_node(dependent_node) then
        stats.and_nodes_evaluated = stats.and_nodes_evaluated + 1
        local path_exprs = {}
        for _, prereq in pairs(dependent_node.prereqs) do
            local prereq_key = graph_utils.get_node_key(prereq)
            local result = check_reachable_top_down(graph[prereq_key], removed_key, parents, critical_nodes, depth + 1, reachablility_cache, stats)
            if result.terminated then
                return result
            end
            if not result.reachable then
                stats.and_failures = stats.and_failures + 1
                return failure_result(dependent_key, parents, critical_nodes, reachablility_cache, result.loop)
            end
            path_exprs[#path_exprs+1] = expr_union({expr_literal(prereq_key), expr_reference(prereq_key)})
        end
        stats.and_successes = stats.and_successes + 1
        return success_result(dependent_key, parents, reachablility_cache, expr_union(path_exprs))
    elseif graph_utils.is_or_node(dependent_node) then
        stats.or_nodes_evaluated = stats.or_nodes_evaluated + 1
        local loop = false
        for _, prereq in pairs(dependent_node.prereqs) do
            local prereq_key = graph_utils.get_node_key(prereq)
            local result = check_reachable_top_down(graph[prereq_key], removed_key, parents, critical_nodes, depth + 1, reachablility_cache, stats)
            if result.terminated then
                return result
            end
            if result.reachable then
                stats.or_successes = stats.or_successes + 1
                local path_expr = expr_union({expr_literal(prereq_key), expr_reference(prereq_key)})
                return success_result(dependent_key, parents, reachablility_cache, path_expr)
            end
            if result.loop then
                loop = true
            end
        end
        stats.or_failures = stats.or_failures + 1
        return failure_result(dependent_key, parents, critical_nodes, reachablility_cache, loop)
    end
    error()
end

-- Slow median runtime, but good time complexity O(n)
local check_reachable_bottom_up = function (target_key, remove_key)
    if target_key == remove_key then
        return false
    end
    local node_queue = {}
    local discovered = {}
    local prereqs_discovered = {}
    for _, key in pairs(source_nodes) do
        if key ~= remove_key then
            if key == target_key then
                return true
            end
            node_queue[#node_queue+1] = key
            discovered[key] = true
        end
    end
    local node_queue_front = 1
    while #node_queue >= node_queue_front do
        local node_key = node_queue[node_queue_front]
        local node = graph[node_key]
        for _, dependent in pairs(node.dependents) do
            local dependent_key = graph_utils.get_node_key(dependent)
            if prereqs_discovered[dependent_key] == nil then
                prereqs_discovered[dependent_key] = 1
            else
                prereqs_discovered[dependent_key] = prereqs_discovered[dependent_key] + 1
            end
            local dependent_node = graph[dependent_key]
            local satisfied = false
            if graph_utils.is_and_node(dependent_node) then
                satisfied = prereqs_discovered[dependent_key] >= #dependent_node.prereqs
            elseif graph_utils.is_or_node(dependent_node) then
                satisfied = prereqs_discovered[dependent_key] > 0
            else
                error()
            end
            if satisfied then
                if dependent_key ~= remove_key then
                    if dependent_key == target_key then
                        return true
                    end
                    if discovered[dependent_key] == nil then
                        node_queue[#node_queue+1] = dependent_key
                        discovered[dependent_key] = true
                    end
                end
            end
        end
        node_queue_front = node_queue_front + 1
    end
    return false
end

min_rec_req.init = function (input_graph)
    min_rec_req.restart(input_graph)
end

min_rec_req.restart = function (input_graph)
    graph = {}
    source_nodes = {}
    local breadth_first_top_sort = top_sort.sort(input_graph)
    breadth_first_ordinals = {}
    for ordinal, node2 in pairs(breadth_first_top_sort.sorted) do
        local key2 = graph_utils.get_node_key(node2)
        breadth_first_ordinals[key2] = ordinal
        graph[key2] = input_graph[key2]
    end
    breadth_first_ordinals.MAX = breadth_first_top_sort.curr_ind
    for _, node2 in pairs(breadth_first_top_sort.sorted) do
        local key2 = graph_utils.get_node_key(node2)
        local old_prereq_count = #node2.prereqs
        local new_prereq_count = 0
        for i = 1, old_prereq_count do
            local prereq = node2.prereqs[i]
            node2.prereqs[i] = nil
            if graph[graph_utils.get_node_key(prereq)] ~= nil then
                new_prereq_count = new_prereq_count + 1
                node2.prereqs[new_prereq_count] = prereq
            end
        end
        sort_prereqs(node2.prereqs, breadth_first_ordinals)
        local old_dependent_count = #node2.dependents
        local new_dependent_count = 0
        for i = 1, old_dependent_count do
            local dependent = node2.dependents[i]
            node2.dependents[i] = nil
            if graph[graph_utils.get_node_key(dependent)] ~= nil then
                new_dependent_count = new_dependent_count + 1
                node2.dependents[new_dependent_count] = dependent
            end
        end
        if graph_utils.is_this_one_of_those_uh_one_of_those_nodes_that_you_when_theres_like_uh_source_node_thats_what_its_called_is_that_what_this_is(node2) then
            source_nodes[#source_nodes+1] = key2
        end
    end
end

-- O(nodes*edges). If the node is reachable, this returns the set of unavoidable nodes this node needs in order to be reachable.
-- Runtime scales linearly with the amount of nodes with type in node_types. Set node_types to nil for all node types (slow).
-- Runtime is slower the farther into the endgame target_node is located.
min_rec_req.minimum_recursive_requirements = function (target_node, node_types)
    if set_utils.set_empty(graph) then
        error("gotta call init first to initialize, lad.")
    end
    local master_key = graph_utils.get_node_key(target_node)
    assert(graph[master_key])

    local start_time = os.clock()

    local required_nodes = { [master_key] = true }
    local not_required_nodes = {}
    local added_to_potential_stack = {}
    local potential_stack = {}

    local master_stats = get_empty_stats()
    local master_path_reachability_cache = {}
    local master_path_expr = path_utils.check_reachable_top_down(graph, target_node, nil, {}, required_nodes, 0, master_path_reachability_cache, master_stats).path_expr
    local master_path = path_utils.find_path(graph, target_node)

    local add_potential_prereqs_to_stack = function (dependent_node)
        local dependent_key = graph_utils.get_node_key(dependent_node)

        for _, prereq in pairs(dependent_node.prereqs) do
            local prereq_key = graph_utils.get_node_key(prereq)
            if (graph_utils.is_and_node(dependent_node) or potential_requirement(dependent_key, prereq_key))
                and not added_to_potential_stack[prereq_key] then
                added_to_potential_stack[prereq_key] = true
                potential_stack[#potential_stack+1] = graph[prereq_key]
            end
        end
    end

    local add_required_node = function (current_key) end

    add_required_node = function (current_key)
        if required_nodes[current_key] == nil then
            required_nodes[current_key] = true
            local current_node = graph[current_key]
            if graph_utils.is_and_node(current_node) then
                for _, prereq in pairs(current_node.prereqs) do
                    add_required_node(graph_utils.get_node_key(prereq))
                end
            elseif graph_utils.is_or_node(current_node) and #current_node.prereqs == 1 then
                add_required_node(graph_utils.get_node_key(current_node.prereqs[1]))
            end
            if #current_node.dependents == 1 then
                add_required_node(graph_utils.get_node_key(current_node.dependents[1]))
            end
        end
    end

    local add_not_required_node = function (current_key) end

    add_not_required_node = function (current_key)
        if not_required_nodes[current_key] == nil then
            not_required_nodes[current_key] = true
            local current_node = graph[current_key]
            for _, dependent in pairs(current_node.dependents) do
                local dependent_key = graph_utils.get_node_key(dependent)
                local dependent_node = graph[dependent_key]
                if graph_utils.is_and_node(dependent_node) then
                    add_not_required_node(dependent_key)
                elseif graph_utils.is_or_node(dependent_node) and #dependent_node.prereqs == 1 then
                    add_not_required_node(dependent_key)
                end
            end
            if graph_utils.is_and_node(current_node) then
                for _, prereq in pairs(current_node.prereqs) do
                    local prereq_key = graph_utils.get_node_key(prereq)
                    if #graph[prereq_key].dependents == 1 then
                        add_not_required_node(prereq_key)
                    end
                end
            elseif graph_utils.is_or_node(current_node) and #current_node.prereqs == 1 then
                local prereq_key = graph_utils.get_node_key(current_node.prereqs[1])
                if #graph[prereq_key].dependents == 1 then
                    add_not_required_node(prereq_key)
                end
            end
        end
    end

    add_potential_prereqs_to_stack(target_node)

    local top_down_checks = 0
    local bottom_up_checks = 0

    while #potential_stack > 0 do
        local remove_node = potential_stack[#potential_stack]
        potential_stack[#potential_stack] = nil
        local remove_key = graph_utils.get_node_key(remove_node)
        add_potential_prereqs_to_stack(remove_node)
        local node_type_match = node_types == nil or node_types[remove_node.type]
        if required_nodes[remove_key] == nil and not_required_nodes[remove_key] == nil and node_type_match then
            local result = reachable_result(nil)
            local reachablility_cache = {}
            if master_path[remove_key] then
                top_down_checks = top_down_checks + 1
                local stats = get_empty_stats()
                result = path_utils.check_reachable_top_down(graph, target_node, remove_key, {}, required_nodes, 0, reachablility_cache, stats)
                if result.undetermined then
                    bottom_up_checks = bottom_up_checks + 1
                    result.reachable = check_reachable_bottom_up(master_key, remove_key)
                end
            end
            if result.reachable then
                add_not_required_node(remove_key)
            else
                add_required_node(remove_key)
            end
        end
    end

    required_nodes[master_key] = nil
    if node_types ~= nil then
        for key, _ in pairs(required_nodes) do
            if node_types[graph[key].type] == nil then
                required_nodes[key] = nil
            end
        end
    end

    local node_count = set_utils.count(required_nodes)
    local elapsed_time = os.clock() - start_time

    return required_nodes
end

return min_rec_req