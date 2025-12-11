local graph_utils = require("lib/graph/graph-utils")
local set_utils = require("lib/graph/set-utils")

local path = {}

local operator_literal = "l"
local operator_reference = "r"
local operator_union = "u"

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
path.get_empty_stats = function ()
    return { chache_hits = 0, removed_node_hits = 0, max_depth = 0, loop_hits = 0, nodes_checked = 0, nodes_evaluated = 0,
    and_nodes_evaluated = 0, or_nodes_evaluated = 0, and_failures = 0, or_failures = 0, and_successes = 0, or_successes = 0 }
end

-- Fast median runtime, but horrible time complexity O(n!) showcased when the algorithm hits a local minimum.
-- Configured to terminate undetermined after a while.
path.check_reachable_top_down = function (graph, dependent_node, removed_key, parents, critical_nodes, depth, reachablility_cache, stats)

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
            local result = path.check_reachable_top_down(graph, graph[prereq_key], removed_key, parents, critical_nodes, depth + 1, reachablility_cache, stats)
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
            local result = path.check_reachable_top_down(graph, graph[prereq_key], removed_key, parents, critical_nodes, depth + 1, reachablility_cache, stats)
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

-- Very important: sort the prereqs of each node in topological order before calling this.
path.find_path = function (graph, target_node, node_types)
    local target_key = graph_utils.get_node_key(target_node)
    local required_nodes = { [target_key] = true }

    local stats = path.get_empty_stats()
    local path_reachability_cache = {}
    local path_expr = path.check_reachable_top_down(graph, target_node, nil, {}, required_nodes, 0, path_reachability_cache, stats).path_expr
    local path_set = evaluate_expr(path_expr, path_reachability_cache, {})

    if node_types ~= nil then
        for key, _ in pairs(path_set) do
            if node_types[graph[key].type] == nil then
                path_set[key] = nil
            end
        end
    end

    return path_set
end

return path