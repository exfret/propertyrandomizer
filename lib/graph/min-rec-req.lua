local graph_utils = require("lib/graph/graph-utils")
local set_utils = require("lib/graph/set-utils")
local top_sort = require("lib/graph/top-sort")
local path_utils = require("lib/graph/path")

local min_rec_req = {}

local graph = {}
local source_nodes = {}
local breadth_first_ordinals = {}

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

local reachable_result = function (path)
    return { reachable = true, terminated = false, loop = false, undetermined = false, path_expr = path }
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

    -- exfret: This needs to be removed when "online"
    --local start_time = os.clock()

    local required_nodes = { [master_key] = true }
    local not_required_nodes = {}
    local added_to_potential_stack = {}
    local potential_stack = {}

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
                local stats = path_utils.get_empty_stats()
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
    --local elapsed_time = os.clock() - start_time

    return required_nodes
end

return min_rec_req