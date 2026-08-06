
local build_graph = require("lib/graph/build-graph")
local graph_utils = require("lib/graph/graph-utils")
local path_utils = require("lib/graph/path")
local critical_req = require("lib/graph/critical-req")
local queue = require("lib/graph/queue")
local const = require("randomizations/graph/core/constants")
local export = {}

-- Processes node queue of scenario
local process_scenario = function (state, scenario)
    local node_queue = scenario.node_queue
    local reachable = scenario.reachable
    local discovered = scenario.discovered
    local prereq_info = scenario.prereq_info
    local lock_bypass = scenario.lock_bypass

    local is_locked = function (node_key)
        return state.locked_nodes[node_key] ~= nil and lock_bypass[node_key] == nil
    end

    local reachable_condition = function (node)
        local node_reachable = true
        if graph_utils.is_and_node(node) then
            for _, prereq in pairs(node.prereqs) do
                if not reachable[graph_utils.get_node_key(prereq)] then
                    node_reachable = false
                    break
                end
            end
        elseif graph_utils.is_or_node(node) then
            node_reachable = false
            for _, prereq in pairs(node.prereqs) do
                if reachable[graph_utils.get_node_key(prereq)] then
                    node_reachable = true
                    break
                end
            end
        else
            error("how")
        end
        return node_reachable
    end

    -- To avoid adding nodes to node queue unnecessarily
    local nodes_in_node_queue = {}
    for _, node_key in pairs(node_queue.list) do
        nodes_in_node_queue[node_key] = true
    end

    while not queue.is_empty(node_queue) do
        local node_key = queue.pop(node_queue)
        nodes_in_node_queue[node_key] = nil
        local node = scenario.graph[node_key]

        -- Don't let locked nodes become discovered, reachable or an available prereq
        if not is_locked(node_key) then

            -- If it wasn't previously reachable, test to see if it is now
            if reachable[node_key] == nil and reachable_condition(node) then
                reachable[node_key] = true
            end

            -- Only reachable nodes can get discovered
            if reachable[node_key] ~= nil and discovered[node_key] == nil then
                discovered[node_key] = true
                -- Found a new reachable node

                if node_key == scenario.goal_node_key then
                    -- Goal reached
                    -- You've served your purpose. Bye bye.
                    state.scenarios[scenario.planet_name] = nil
                    -- May the garbage collector deliver swift release
                    return
                end

                -- Prereq detected
                if state.target_prereq_types[node.type] ~= nil then
                    if prereq_info[node.type] == nil then
                        prereq_info[node.type] = {
                            surface_keys = {},
                            no_surface = {
                                surface_ambiguous_keys = {},
                                edges = {},
                            },
                        }
                    end
                    local surface_info = prereq_info[node.type].no_surface
                    if state.surface_specific(node.type) then
                        if prereq_info[node.type].surface_keys[node.surface] == nil then
                            prereq_info[node.type].surface_keys[node.surface] = {
                                surface_ambiguous_keys = {},
                                edges = {},
                            }
                        end
                        surface_info = prereq_info[node.type].surface_keys[node.surface]
                    end
                    local surface_ambiguous_key = graph_utils.get_surface_ambiguous_key(node)
                    surface_info.surface_ambiguous_keys[surface_ambiguous_key] = true

                    local new_edges = 0
                    for _, edge_type in pairs(state.edge_types) do
                        if edge_type.prereq_type == node.type then
                            for _, dependent in pairs(node.dependents) do
                                if edge_type.dependent_type == dependent.type then
                                    local edge = graph_utils.create_edge(node_key, graph_utils.get_node_key(dependent), state.random_graph)
                                    table.insert(surface_info.edges, edge)
                                    new_edges = new_edges + 1
                                end
                            end
                        end
                    end

                    if new_edges < 1 then
                        local edge = graph_utils.create_edge(node_key, node_key, state.random_graph)
                        table.insert(surface_info.edges, edge)
                    end
                end

                -- Add dependents to the node_queue
                for _, dependent in pairs(node.dependents) do
                    local dependent_key = graph_utils.get_node_key(dependent)
                    if nodes_in_node_queue[dependent_key] == nil and not is_locked(node_key) then
                        -- Dependent is okay for traversal
                        queue.push(node_queue, dependent_key)
                        nodes_in_node_queue[dependent_key] = true
                    end
                end
            end
        end
    end
end

-- For when a permanent unlock node is reached
local unlock_scenario_node = function (state, scenario, node_key)
    local graph = scenario.graph
    scenario.lock_bypass[node_key] = true
    state.force_reachable(graph[node_key], graph)
    queue.push(scenario.node_queue, node_key)
    process_scenario(state, scenario)
end

export.setup_critical_node_info = function (state)

    -- Set up scenarios to figure out critical edges for getting un-stuck
    state.scenario_to_critical_edges = {}
    state.scenario_goal_node_key = build_graph.key(const.spaceship_node_type, const.canonical_name)
    for _, planet_name in pairs(state.scenario_planet_names) do

        -- Construct scenario
        local scenario_graph = table.deepcopy(state.vanilla_graph)

        -- Scenario starts with the unlocks needed to get to the planet
        local planet_access_node_key = build_graph.key(const.planet_access_node_type, planet_name)
        local vanilla_planet_access_node = state.vanilla_graph[planet_access_node_key]
        local path = path_utils.find_path(state.vanilla_graph, vanilla_planet_access_node, state.permanent_unlock_node_types)
        for node_key, _ in pairs(path) do
            state.force_reachable(scenario_graph[node_key], scenario_graph)
        end

        -- Remove access to starting planet, probably nauvis
        local starting_planet_node = scenario_graph[build_graph.key(const.starting_planet_node_type, const.canonical_name)]
        local original_starting_planet_access_node = scenario_graph[graph_utils.get_node_key(starting_planet_node.dependents[1])]
        graph_utils.remove_prereq(starting_planet_node, original_starting_planet_access_node)

        -- Add access to scenario planet
        local planet_access_node = scenario_graph[planet_access_node_key]
        graph_utils.add_prereq(starting_planet_node, planet_access_node)

        -- Scenario goal node
        local spaceship_node = scenario_graph[state.scenario_goal_node_key]

        -- Generate critical edges
        local critical_edges = critical_req.critical_edges(spaceship_node, state.target_edges, scenario_graph)

        -- Showstoppers from previous randomization attempts
        for node_key, _ in pairs(state.previous_showstoppers[planet_name]) do
            local node = scenario_graph[node_key]
            for _, prereq in pairs(node.prereqs) do
                local prereq_key = graph_utils.get_node_key(prereq)
                local edge = graph_utils.create_edge(prereq_key, node_key, scenario_graph)
                if state.target_edges[edge.key] ~= nil then
                    local prereq_node = scenario_graph[prereq_key]
                    local additional_critical_edges = critical_req.critical_edges(prereq_node, state.target_edges, scenario_graph)
                    for key, value in pairs(additional_critical_edges) do
                        if critical_edges[key] == nil then
                            critical_edges[key] = value
                        end
                    end
                end
            end
        end

        state.scenario_to_critical_edges[planet_name] = critical_edges
    end

    -- Determine the set of scenarios where a node is a critical requirement
    state.critical_node_info = {}
    for planet_name, critical_edges in pairs(state.scenario_to_critical_edges) do
        for _, edge in pairs(critical_edges) do
            local edge_type_key = edge.type.key
            if state.critical_node_info[edge_type_key] == nil then
                state.critical_node_info[edge_type_key] = {}
            end
            local node = state.vanilla_graph[edge.dependent_key]
            local surface_ambiguous_key = graph_utils.get_surface_ambiguous_key(node)
            local info = state.critical_node_info[edge_type_key][surface_ambiguous_key]
            if info == nil then
                info = {}
                state.critical_node_info[edge_type_key][surface_ambiguous_key] = info
            end
            if state.surface_specific(node.type) then
                if info[planet_name] == nil then
                    info[planet_name] = {}
                end
                info[planet_name][node.surface] = true
            else
                info[planet_name] = true
            end
        end
    end
end

export.init_scenarios = function (state)

    -- Create scenarios to keep track of while randomizing the new graph
    state.scenarios = {}
    for _, planet_name in pairs(state.scenario_planet_names) do
        local scenario = {
            surface_key = build_graph.compound_key({const.surface_type_planet, planet_name}),
            planet_name = planet_name,
            graph = table.deepcopy(state.vanilla_graph),

            -- End goal for scenario
            goal_node_key = state.scenario_goal_node_key,

            -- For doing graph traversal
            node_queue = queue.new(),
            discovered = {},
            reachable = {},
            lock_bypass = {},

            -- Keep track of reachable prereq nodes
            prereq_info = {},

            -- For parallel progression
            start_node_key = build_graph.key(const.planet_access_node_type, planet_name),
        }
        state.scenarios[scenario.planet_name] = scenario

        -- Remove access to starting planet, probably nauvis
        local starting_planet_node = scenario.graph[build_graph.key(const.starting_planet_node_type, const.canonical_name)]
        local original_starting_planet_access_node = scenario.graph[graph_utils.get_node_key(starting_planet_node.dependents[1])]
        graph_utils.remove_prereq(starting_planet_node, original_starting_planet_access_node)

        -- Add access to scenario planet
        local planet_access_node = scenario.graph[scenario.start_node_key]
        graph_utils.add_prereq(starting_planet_node, planet_access_node)

        -- Start search for goal
        for _, key in pairs(state.source_nodes_keys) do
            queue.push(scenario.node_queue, key)
        end
        process_scenario(state, scenario)

        -- Set the ordinals for parallel progression
        scenario.start_ordinal = state.shuffled_order_ordinals[scenario.start_node_key]
        scenario.end_ordinal = state.shuffled_order_ordinals[build_graph.key(const.rocket_launch_planet_node_type, planet_name)]
        scenario.prev_ordinal = scenario.start_ordinal
        assert(scenario.start_ordinal < scenario.end_ordinal)

        for i = 1, scenario.start_ordinal do
            local node_key = graph_utils.get_node_key(state.shuffled_order[i])
            local node = scenario.graph[node_key]
            if state.permanent_unlock_node_types[node.type] ~= nil then
                unlock_scenario_node(state, scenario, node_key)
            end
        end
    end
end

    -- For after having picked a new dependent for edges/new prereqs for a dependent
export.update_scenario_graph = function (state, scenario, deleted_edges, added_edges)
    graph_utils.update_edges(scenario.graph, deleted_edges, added_edges)
    for _, edge in pairs(added_edges) do
        queue.push(scenario.node_queue, edge.dependent_key)
    end
    process_scenario(state, scenario)
end

return export