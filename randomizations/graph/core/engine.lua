local rng = require("lib/random/rng")
local graph_utils = require("lib/graph/graph-utils")
local top_sort = require("lib/graph/top-sort")
local queue = require("lib/graph/queue")
local set_utils = require("lib/graph/set-utils")
local reorder = require("randomizations/graph/core/graph-reorder")
local sm = require("randomizations/graph/core/scenario-manager")
local helpers = require("randomizations/graph/core/helpers")
local const = require("randomizations/graph/core/constants")

local export = {}

local get_preferred_edges = function (state)
    -- Let the randomizer decide which edges to use
    if state.randomizer.config.preferred_edges == const.config_unused then
        return state.unused_edges
    elseif state.randomizer.config.preferred_edges == const.config_reachable then
        return state.reachable_prereqs
    else
        error("Invalid preferred_edges config")
    end
end

local determine_available_edges = function (state)
    local edge_type = state.edge_type
    local override_scenario_key = state.override_scenario_key
    -- Gather the prereq edges
    local surface_edge_info = helpers.get_prereq_info(state, edge_type.prereq_type, state.node.surface)

    -- Picking from this set of edges ensures that the game is completable
    state.reachable_prereqs = surface_edge_info.reachable_prereqs
    -- Picking from this set of edges ensures an unchanged number of dependents per prereq
    state.unused_edges = surface_edge_info.unused_edges

    local preferred_edges = get_preferred_edges(state)

    -- Picking from this set of edges ensures that no softlocks occur (i wish)
    -- This set doesn't feature edges with the same prereq twice
    state.suitable_edges = helpers.unique_prereq_edge_filter(preferred_edges)

    if override_scenario_key ~= nil and state.scenarios[override_scenario_key] ~= nil then
        local scenario = state.scenarios[override_scenario_key]
        state.reachable_prereqs = {}
        local scenario_prereq_info = scenario.prereq_info[edge_type.prereq_type]
        if scenario_prereq_info ~= nil then
            local surface_info = scenario_prereq_info.no_surface
            if state.dependent_is_surface_specific and state.prereq_is_surface_specific then
                surface_info = scenario_prereq_info.surface_keys[state.node.surface]
            end
            if surface_info ~= nil then
                state.reachable_prereqs = surface_info.edges
            end
        end
        state.unused_edges = state.reachable_prereqs
        preferred_edges = get_preferred_edges(state)
        state.suitable_edges = helpers.unique_prereq_edge_filter(get_preferred_edges(state))
    end

    state.preferred_edges_suitable = true
    state.prereq_edges_suitable = true

    if #state.suitable_edges < state.first_edge_count then
        state.suitable_edges = helpers.unique_prereq_edge_filter(state.reachable_prereqs)
        state.preferred_edges_suitable = false
    end
    if #state.suitable_edges < state.first_edge_count then
        -- uh-oh
        state.prereq_edges_suitable = false
    end

    -- Find out if this dependent is a shared critical requirement
    state.critical_node = false
    local surface_ambiguous_key = graph_utils.get_surface_ambiguous_key(state.node)
    if state.critical_node_info[edge_type.key] ~= nil
    and state.critical_node_info[edge_type.key][surface_ambiguous_key] ~= nil then

        -- Aggregate a set of prereqs that are available in all the affected scenarios
        local filter = set_utils.create_universal_set()
        for scenario_key, surfaces in pairs(state.critical_node_info[edge_type.key][surface_ambiguous_key]) do
            local scenario = state.scenarios[scenario_key]

            -- Scenarios get deleted once they complete
            if scenario ~= nil then
                local prereq_info = scenario.prereq_info[edge_type.prereq_type]

                if prereq_info == nil then
                    -- There were no prereqs of this type discovered in this scenario.
                    -- Failure
                    filter = {}
                    break
                end
                if state.prereq_is_surface_specific and state.dependent_is_surface_specific then
                    for surface_key, _ in pairs(surfaces) do
                        local surface_prereq_info = prereq_info.surface_keys[surface_key]

                        if surface_prereq_info == nil then
                            -- There were no prereqs of this type for this surface in this scenario.
                            -- Failure
                            filter = {}
                            break
                        end
                        set_utils.merge_intersection(filter, prereq_info.surface_keys[surface_key].surface_ambiguous_keys)
                    end
                else
                    set_utils.merge_intersection(filter, prereq_info.no_surface.surface_ambiguous_keys)
                end
            end
        end

        -- Check if there actually were affected scenarios
        if not set_utils.is_universal_set(filter) then

            -- Shared critical node detected
            state.critical_node = true
            state.preferred_edges_suitable = true
            state.prereq_edges_suitable = true

            state.suitable_edges = {}
            -- Put intersection with unused edges as available edges
            for _, edge in pairs(preferred_edges) do
                local prereq = state.random_graph[edge.prereq_key]
                local prereq_surface_ambiguous_key = graph_utils.get_surface_ambiguous_key(prereq)
                if filter[prereq_surface_ambiguous_key] ~= nil then
                    table.insert(state.suitable_edges, edge)
                end
            end
            state.suitable_edges = helpers.unique_prereq_edge_filter(state.suitable_edges)

            -- Check if there's a good amount of edges
            if #state.suitable_edges < state.first_edge_count then

                -- This is bad
                state.preferred_edges_suitable = false
                state.suitable_edges = {}

                -- Try resorting to using any found prereq
                for _, edge in pairs(state.reachable_prereqs) do
                    local prereq = state.random_graph[edge.prereq_key]
                    local prereq_surface_ambiguous_key = graph_utils.get_surface_ambiguous_key(prereq)
                    if filter[prereq_surface_ambiguous_key] ~= nil then
                        table.insert(state.suitable_edges, edge)
                    end
                end
                state.suitable_edges = helpers.unique_prereq_edge_filter(state.suitable_edges)
            end

            if #state.suitable_edges < state.first_edge_count then

                -- uh-oh
                state.prereq_edges_suitable = false
                -- The randomizer will surely figure something out
            end
        end
    end
end

-- For assigning edges during randomization
local assign_prereqs = function (state, node_key, override_scenario_key)

    state.node_key = node_key
    state.override_scenario_key = override_scenario_key
    state.node = state.random_graph[state.node_key]
    state.node_change_history = {}
    state.compromises_for_dependent = 0

    state.dependent_is_surface_specific = state.surface_specific(state.node.type)
    state.final_old_edges = {}
    state.final_new_edges = {}
    state.final_used_edges = {}

    local target_randomizers = {}

    -- Find an edge type for this type of dependent
    for edge_type_key, edge_type in pairs(state.edge_types) do
        if state.node.type == edge_type.dependent_type then
            state.edge_type = edge_type

            state.prereq_is_surface_specific = state.surface_specific(edge_type.prereq_type)

            -- Keep track of what the edges first were
            state.first_edges = {}
            for _, prereq in pairs(state.node.prereqs) do
                local edge = graph_utils.create_edge(graph_utils.get_node_key(prereq), state.node_key, state.random_graph)
                if prereq.type == edge_type.prereq_type and state.target_edges[edge.key] then
                    table.insert(state.first_edges, edge)
                end
            end
            state.first_edge_count = #state.first_edges

            -- Keep track of which edges end up used
            state.edges_to_use = {}

            -- Find which randomizers affect this node
            for _, randomizer in pairs(state.edge_type_to_randomizers[edge_type_key]) do
                if randomizer.edge_types[edge_type_key] ~= nil then
                    state.randomizer = randomizer
                    target_randomizers[randomizer.key] = randomizer

                    -- The old prereqs from the perspective of this randomizer
                    state.old_edges = {}
                    for _, prereq in pairs(state.node.prereqs) do
                        local edge = graph_utils.create_edge(graph_utils.get_node_key(prereq), state.node_key, state.random_graph)
                        if prereq.type == edge_type.prereq_type and state.target_edges[edge.key] then
                            table.insert(state.old_edges, edge)
                        end
                    end

                    determine_available_edges(state)

                    if not state.preferred_edges_suitable then
                        state.compromises_for_dependent = state.compromises_for_dependent + 1
                    end

                    -- Output list
                    state.new_edges = {}

                    -- Support for letting randomizers decide to postpone a dependent
                    state.postpone = false

                    -- Determine new edges
                    randomizer.execute_randomization(state)

                    -- Abort if postponed
                    if state.postpone then
                        -- Undo all changes so far
                        for i = #state.node_change_history, 1, -1 do
                            local changes = state.node_change_history[i]
                            graph_utils.update_edges(state.random_graph, changes.added_edges, changes.deleted_edges)
                        end
                        return false
                    end

                    -- Keep track of the used edges
                    state.edges_to_use = table.deepcopy(state.new_edges)

                    -- Set the dependent of each new edge
                    for i = 1, #state.new_edges do
                        state.new_edges[i] = graph_utils.create_edge(state.new_edges[i].prereq_key, state.node_key, state.random_graph)
                    end

                    -- If this dependent is a surface specific node, then make edges for each surface
                    if state.dependent_is_surface_specific then
                        helpers.clone_across_surfaces(state, state.new_edges)
                        helpers.clone_across_surfaces(state, state.old_edges)
                        helpers.clone_across_surfaces(state, state.edges_to_use)
                    end

                    -- Apply changes to graph
                    graph_utils.update_edges(state.random_graph, state.old_edges, state.new_edges)

                    -- Record temporary change history for this node
                    table.insert(state.node_change_history, { deleted_edges = state.old_edges, added_edges = state.new_edges})
                end
            end
            -- Randomizations of this edge type are complete

            -- Gather finalized changes for this edge type
            if state.dependent_is_surface_specific then
                helpers.clone_across_surfaces(state, state.first_edges)
            end
            -- Pre-first randomization edges
            for _, edge in pairs(state.first_edges) do
                state.final_old_edges[edge.key] = edge
            end
            -- Post-last randomization edges
            for _, edge in pairs(state.new_edges) do
                state.final_new_edges[edge.key] = edge
            end
            for _, edge in pairs(state.edges_to_use) do
                state.final_used_edges[edge.key] = edge
            end
        end
    end
    -- Randomizations of all edge types of this node are complete

    -- Unlock any potential other surface variants of the dependent, they got their prereqs early
    if state.dependent_is_surface_specific then
        local surface_ambiguous_key = graph_utils.get_surface_ambiguous_key(state.node)
        for _, dependent_key in pairs(state.surface_ambiguous_key_info[surface_ambiguous_key].node_keys) do
            state.locked_nodes[dependent_key] = nil
        end
    else
        state.locked_nodes[state.node_key] = nil
    end

    -- Update used edges
    for key, edge in pairs(state.final_used_edges) do
        local edge_type = edge.type
        state.used_edges[key] = true
        local prereq = state.random_graph[edge.prereq_key]
        local prereq_info = helpers.get_prereq_info(state, edge_type.prereq_type, prereq.surface)
        for i, edge2 in pairs(prereq_info.unused_edges) do
            if edge.key == edge2.key then
                table.remove(prereq_info.unused_edges, i)
                break
            end
        end
    end

    -- Update the scenarios in kind
    for _, scenario in pairs(state.scenarios) do
        sm.update_scenario_graph(state, scenario, state.final_old_edges, state.final_new_edges)
    end

    state.total_compromises = state.total_compromises + state.compromises_for_dependent

    for _, randomizer in pairs(target_randomizers) do
        state.randomizer = randomizer
        randomizer.on_assign_prereqs_success(state)
    end

    -- Success
    return true
end

local add_prereq_edges = function (state, node_key)

    state.node_key = node_key
    state.node = state.random_graph[state.node_key]

    if state.prereqs_added[node_key] ~= nil then
        return
    end
    state.prereqs_added[node_key] = true

    local surface_info = helpers.get_prereq_info(state, state.node.type, state.node.surface)
    local self_edge = graph_utils.create_edge(state.node_key, state.node_key, state.random_graph)
    table.insert(surface_info.reachable_prereqs, self_edge)

    -- Figure out if this node has edges we're randomizing
    for edge_type_key, edge_type in pairs(state.edge_types) do
        if edge_type.prereq_type == state.node.type then
            state.check_postponed_locked_types[edge_type.dependent_type] = true
            for _, dependent in pairs(state.node.dependents) do
                local dependent_key = graph_utils.get_node_key(dependent)
                local edge = graph_utils.create_edge(state.node_key, dependent_key, state.random_graph)
                local prereq_edge_type = edge.type
                if prereq_edge_type.key == edge_type_key
                and state.target_edges[edge.key] ~= nil
                and state.used_edges[edge.key] == nil then
                    -- This dependent could be reassigned

                    -- Keep track of this as an edge
                    table.insert(surface_info.unused_edges, edge)
                    table.insert(surface_info.all_reachable_edges, edge)
                end
            end
        end
    end
end

local prereqs_in_random_graph = function (state, node_key)
    local locked = state.locked_nodes[node_key] ~= nil
    local node = state.random_graph[node_key]
    local node_reachable = true
    if graph_utils.is_and_node(node) then
        for _, prereq in pairs(node.prereqs) do
            local prereq_key = graph_utils.get_node_key(prereq)
            local edge = graph_utils.create_edge(prereq_key, node_key, state.random_graph)
            if not locked or state.target_edges[edge.key] == nil then
                if not state.random_graph_reachable[prereq_key] then
                    return false
                end
            end
        end
    elseif graph_utils.is_or_node(node) then
        node_reachable = false
        for _, prereq in pairs(node.prereqs) do
            local prereq_key = graph_utils.get_node_key(prereq)
            local edge = graph_utils.create_edge(prereq_key, node_key, state.random_graph)
            if locked and state.target_edges[edge.key] ~= nil then
                return true
            end
            if state.random_graph_reachable[prereq_key] then
                return true
            end
        end
    else
        error("how")
    end
    return node_reachable
end

local try_make_reachable = function (state, node_key, override_scenario) end
try_make_reachable = function (state, node_key, override_scenario)
    local node = state.random_graph[node_key]

    if state.locked_nodes[node_key] ~= nil
    and (override_scenario ~= nil or prereqs_in_random_graph(state, node_key)) then
        -- Dependent in need of new prereqs detected
        assign_prereqs(state, node_key, override_scenario)
    end

    if state.locked_nodes[node_key] == nil and prereqs_in_random_graph(state, node_key) then
        -- Reachable node detected
        state.random_graph_reachable[node_key] = true
        local dependents = table.deepcopy(node.dependents)
        for _, dependent in pairs(dependents) do
            local dependent_key = graph_utils.get_node_key(dependent)
            local call_info = state.postponed_nodes_set[dependent_key]
            local edge = graph_utils.create_edge(node_key, dependent_key, state.random_graph)
            if call_info ~= nil and state.target_edges[edge.key] == nil then
                state.postponed_nodes_set[dependent_key] = nil
                if state.locked_nodes[dependent_key] ~= nil then
                    queue.remove(state.postponed_locked_nodes[dependent.type], function (other)
                        return other.node_key == call_info.node_key
                    end)
                end
                try_make_reachable(state, call_info.node_key, call_info.override_scenario)
            end
        end
    elseif override_scenario == nil or state.locked_nodes[node_key] ~= nil then
        local call_info = { node_key = node_key, override_scenario = override_scenario }
        if state.locked_nodes[node_key] ~= nil then
            if state.postponed_nodes_set[node_key] == nil then
                queue.push(state.postponed_locked_nodes[node.type], call_info)
            end
        end
        state.postponed_nodes_set[node_key] = call_info
    end

    if state.random_graph_reachable[node_key] ~= nil
    and state.target_prereq_types[node.type] ~= nil then

        -- Reachable prereq detected
        add_prereq_edges(state, node_key)
    end
end

local try_unlock_postponed = function (state, dependent_type)
    local old_queue = state.postponed_locked_nodes[dependent_type]
    state.postponed_locked_nodes[dependent_type] = queue.new()
    while not queue.is_empty(old_queue) do
        local call_info = queue.pop(old_queue)
        state.postponed_nodes_set[call_info.node_key] = nil
        try_make_reachable(state, call_info.node_key, call_info.override_scenario)
        if state.check_postponed_locked_types[dependent_type] ~= nil then
            while not queue.is_empty(old_queue) do
                queue.push(state.postponed_locked_nodes[dependent_type], queue.pop(old_queue))
            end
        end
    end
end

-- Make other scenarios progress in parallel with random graph to expand their pool of prereqs
local parallel_progression = function (state, ordinal)

    --[[ Turns out that simply relying on nodes available through unlocks from before the scenarios start produces
    a severely limited pool of nodes to choose from once the time comes to pick nodes for a critical requirement.
    Let's try unlocking some of the nodes that would be discovered during the scenarios, as if they were progressing in
    parallel with the main graph that's being randomized. ]]
    local node_key_to_scenarios = {}
    for _, scenario in pairs(state.scenarios) do
        if ordinal < scenario.start_ordinal then
            -- Linear interpolation
            local ratio_to_start = ordinal / scenario.start_ordinal

            local ordinal_in_scenario = math.floor(ratio_to_start * scenario.end_ordinal + (1 - ratio_to_start) * scenario.start_ordinal)

            -- Find out if any locked nodes have been encountered by any scenarios
            for i = scenario.prev_ordinal + 1, ordinal_in_scenario do
                local scenario_node_key = graph_utils.get_node_key(state.shuffled_order[i])
                if state.locked_nodes[scenario_node_key] ~= nil and node_key_to_scenarios[scenario_node_key] == nil then

                    local scenario_node = state.random_graph[scenario_node_key]
                    if state.surface_specific_node_types[scenario_node.type] ~= nil then

                        -- Make sure to grab the earliest variation of the node
                        local surface_ambiguous_key = graph_utils.get_surface_ambiguous_key(scenario_node)
                        local surface_ambiguous_key_info = state.surface_ambiguous_key_info[surface_ambiguous_key]
                        scenario_node_key = surface_ambiguous_key_info.node_keys[surface_ambiguous_key_info.first_surface]
                        scenario_node = state.random_graph[scenario_node_key]
                        local scenario_node_ordinal = state.shuffled_order_ordinals[scenario_node_key]

                        -- Find out which scenarios this node could be relevant for
                        for _, scenario2 in pairs(state.scenarios) do
                            local has_surface_prereqs = true
                            for _, prereq in pairs(scenario_node.prereqs) do
                                local edge_type = graph_utils.get_edge_type(prereq, scenario_node)
                                if state.edge_types[edge_type.key] ~= nil and state.surface_specific(edge_type.prereq_type) then
                                    local surface = state.random_graph[graph_utils.get_node_key(prereq)].surface
                                    if scenario2.prereq_info[edge_type.prereq_type] == nil
                                    or scenario2.prereq_info[edge_type.prereq_type].surface_keys[surface] == nil then
                                        has_surface_prereqs = false
                                        break
                                    end
                                end
                            end

                            if has_surface_prereqs and scenario_node_ordinal <= scenario2.end_ordinal then
                                if node_key_to_scenarios[scenario_node_key] == nil then
                                    node_key_to_scenarios[scenario_node_key] = {}
                                end
                                table.insert(node_key_to_scenarios[scenario_node_key], scenario2)
                            end
                        end
                    else
                        for _, scenario2 in pairs(state.scenarios) do
                            if node_key_to_scenarios[scenario_node_key] == nil then
                                node_key_to_scenarios[scenario_node_key] = {}
                            end
                            table.insert(node_key_to_scenarios[scenario_node_key], scenario2)
                        end
                    end
                end
            end

            scenario.prev_ordinal = ordinal_in_scenario
        end
    end
    for scenario_node_key, target_scenarios in pairs(node_key_to_scenarios) do

        -- Select one of the scenarios at random as source of edges if multiple were found
        local scenario = target_scenarios[rng.int(state.rng_key, #target_scenarios)]
        try_make_reachable(state, scenario_node_key, scenario.planet_name)
    end
end

-- Constitutes an attempt at graph randomization
local try_randomize_graph = function (state, graph_randomizations)

    -- Base the randomized graph off of the vanilla graph
    state.random_graph = table.deepcopy(state.vanilla_graph)

    reorder.generate_shuffled_order(state)

    sm.setup_critical_node_info(state)

    -- Keep track of which nodes we haven't decided prereqs for yet
    state.locked_nodes = {}
    for node_key, _ in pairs(state.target_dependents) do
        state.locked_nodes[node_key] = true
    end

    sm.init_scenarios(state)

    -- Call each randomizer's pre_randomization function
    for _, randomizer in pairs(graph_randomizations.randomizers) do
        state.randomizer = randomizer
        randomizer.pre_randomization(state)
    end
    state.randomizer = nil

    -- For keep track of prereq edges per edge type and surface
    state.prereq_edges = {}
    for prereq_type, _ in pairs(state.target_prereq_types) do
        state.prereq_edges[prereq_type] = {
            surface_keys = {},
            no_surface = {
                -- Reachable unused edges 
                unused_edges = {},
                -- Both used and unused edges
                all_reachable_edges = {},
                -- Non-existent edges representing all reachable prereqs
                reachable_prereqs = {},
            }
        }
    end

    -- For keeping track of used edges
    state.used_edges = {}

    -- Mechanism for postponing prereq assignment to nodes
    state.postponed_locked_nodes = {}
    for dependent_type, _ in pairs(state.target_dependent_types) do
        state.postponed_locked_nodes[dependent_type] = queue.new()
    end
    state.postponed_nodes_set = {}

    -- Keep track of which nodes have been made reachable
    state.random_graph_reachable = {}

    state.prereqs_added = {}

    -- Let the randomization commence
    -- Traverse the nodes in a randomized topological order
    -- Delegate prereqs to each locked dependent to make it reachable
    -- Other nodes are reachable if enough of their prereqs are
    -- If the node is reachable, potentially add to prereq pool
    -- If not, add it to postponed_nodes and make it reachable at first opportunity
    state.check_postponed_locked_types = {}
    state.total_compromises = 0
    for ordinal, vanilla_node in pairs(state.shuffled_order) do

        -- First, go through the postponed nodes and see if any them can now be made reachable
        while not set_utils.set_empty(state.check_postponed_locked_types) do
            local types_to_check = table.deepcopy(state.check_postponed_locked_types)
            for dependent_type, _ in pairs(types_to_check) do
                state.check_postponed_locked_types[dependent_type] = nil
                if not queue.is_empty(state.postponed_locked_nodes[dependent_type]) then
                    try_unlock_postponed(state, dependent_type)
                end
            end
        end

        -- Then go through the current node
        try_make_reachable(state, graph_utils.get_node_key(vanilla_node))

        -- Then do parallel progression
        parallel_progression(state, ordinal)
    end

    -- Cleanup time
    state.check_postponed_locked_types = nil
    state.node = nil
    state.node_key = nil
    state.override_scenario_key = nil
    state.override_edge_type_to_edges = nil
    state.dependent_is_surface_specific = nil
    state.final_old_edges = nil
    state.final_new_edges = nil
    state.final_used_edges = nil
    state.edge_type = nil
    state.prereq_is_surface_specific = nil
    state.first_edges = nil
    state.first_edge_count = nil
    state.randomizer = nil
    state.old_edges = nil
    state.reachable_prereqs = nil
    state.all_reachable_edges = nil
    state.unused_edges = nil
    state.suitable_edges = nil
    state.critical_node = nil
    state.preferred_edges_suitable = nil
    state.prereq_edges_suitable = nil
    state.new_edges = nil
    state.edges_to_use = nil
    state.node_change_history = nil

    -- Lastly, call each randomizer's post-randomization function
    for _, randomizer in pairs(graph_randomizations.randomizers) do
        state.randomizer = randomizer
        randomizer.post_randomization(state)
    end
    state.randomizer = nil

    -- Did we complete all our scenarios?
    local scenarios_complete = set_utils.set_empty(state.scenarios)

    -- Is the game completable?
    local game_complete = state.random_graph_reachable[state.end_game_node_key] ~= nil

    if scenarios_complete and game_complete then
        return true
    else
        for _, scenario_key in pairs(state.scenario_planet_names) do
            state.showstoppers_per_scenario[scenario_key] = {}
        end
        local showstopper = false
        for dependent_type, _ in pairs(state.target_dependent_types) do
            while not queue.is_empty(state.postponed_locked_nodes[dependent_type]) do
                local call_info = queue.pop(state.postponed_locked_nodes[dependent_type])
                local node_key = call_info.node_key
                if state.locked_nodes[node_key] ~= nil and prereqs_in_random_graph(state, node_key) then
                    local dependent = state.vanilla_graph[node_key]
                    local surface_ambiguous_key = graph_utils.get_surface_ambiguous_key(dependent)
                    for _, prereq in ipairs(dependent.prereqs) do
                        local edge_type = graph_utils.create_edge_type(prereq.type, dependent.type)
                        if state.edge_types[edge_type.key] ~= nil
                        and state.critical_node_info[edge_type.key] ~= nil
                        and state.critical_node_info[edge_type.key][surface_ambiguous_key] ~= nil then
                            for scenario_key, surfaces in pairs(state.critical_node_info[edge_type.key][surface_ambiguous_key]) do
                                local scenario = state.scenarios[scenario_key]
                                if scenario ~= nil then
                                    local sak_info = state.surface_ambiguous_key_info[surface_ambiguous_key]
                                    for surface_key, _ in pairs(surfaces) do
                                        local showstopper_node_key = sak_info.node_keys[surface_key]
                                        local ordinal = state.shuffled_order_ordinals[showstopper_node_key]
                                        if ordinal < scenario.end_ordinal then
                                            state.showstoppers_per_scenario[scenario_key][showstopper_node_key] = true
                                            showstopper = true
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        -- Surely, the reason this attempt failed was because a critical node couldn't be resolved, right??
        assert(showstopper)
        return false
    end
end

export.run = function (state, graph_randomizations)

    -- Call each randomizer's initialize function
    for _, randomizer in pairs(graph_randomizations.randomizers) do
        state.randomizer = randomizer
        randomizer.initialize(state)
    end
    state.randomizer = nil

    -- Gather the edge types that are gonna be randomized
    state.edge_types = {}
    -- Gather randomizers per edge type
    state.edge_type_to_randomizers = {}
    -- Gather the edges themselves
    state.target_edges = {}
    -- Gather dependents that'll have their prereqs randomized
    state.target_dependents = {}
    for randomizer_key, randomizer in pairs(graph_randomizations.randomizers) do
        state.randomizer = randomizer
        randomizer.edges = randomizer.get_target_edges(state)
        randomizer.edge_types = {}
        for _, edge in pairs(randomizer.edges) do
            state.target_edges[edge.key] = edge
            local edge_type = edge.type
            local edge_type_key = edge_type.key
            state.edge_types[edge_type_key] = edge_type
            randomizer.edge_types[edge_type_key] = edge_type
            if state.edge_type_to_randomizers[edge_type_key] == nil then
                state.edge_type_to_randomizers[edge_type_key] = {}
            end
            state.edge_type_to_randomizers[edge_type_key][randomizer_key] = randomizer
            state.target_dependents[edge.dependent_key] = true
        end
    end
    state.randomizer = nil

    -- Gather the node types that'll have their prereqs changed
    state.target_dependent_types = {}
    -- Gather the node types that'll get used as prereqs
    state.target_prereq_types = {}
    for _, edge_type in pairs(state.edge_types) do
        state.target_dependent_types[edge_type.dependent_type] = true
        state.target_prereq_types[edge_type.prereq_type] = true
    end

    -- Create lookup for finding the first surface a node is associated with and surface variations
    state.surface_ambiguous_key_info = {}
    local add_surface_ambiguous_key_info = function (node_type)
        for _, node_key in pairs(state.node_type_to_node_keys[node_type]) do
            local node = state.vanilla_graph[node_key]
            if state.surface_specific(node_type) then
                local surface_ambiguous_key = graph_utils.get_surface_ambiguous_key(node)
                if state.surface_ambiguous_key_info[surface_ambiguous_key] == nil then
                    state.surface_ambiguous_key_info[surface_ambiguous_key] = {}
                end
                local info = state.surface_ambiguous_key_info[surface_ambiguous_key]
                if info.first_surface == nil then
                    info.first_surface = node.surface
                end
                if info.node_keys == nil then
                    info.node_keys = {}
                end
                info.node_keys[node.surface] = node_key
            end
        end
    end
    for node_type, _ in pairs(state.target_prereq_types) do
        add_surface_ambiguous_key_info(node_type)
    end
    for node_type, _ in pairs(state.target_dependent_types) do
        add_surface_ambiguous_key_info(node_type)
    end

    local success = false
    state.attempts = 0
    state.previous_showstoppers = {}
    for _, scenario_key in pairs(state.scenario_planet_names) do
        state.previous_showstoppers[scenario_key] = {}
    end
    while not success and state.attempts <= 8 do
        state.showstoppers_per_scenario = {}
        state.attempts = state.attempts + 1
        success = try_randomize_graph(state, graph_randomizations)
        for scenario_key, node_keys in pairs(state.showstoppers_per_scenario) do
            for node_key, _ in pairs(node_keys) do
                state.previous_showstoppers[scenario_key][node_key] = true
            end
        end
    end
    assert(success)

    -- Lastly, call each randomizer's finalize function
    for _, randomizer in pairs(graph_randomizations.randomizers) do
        state.randomizer = randomizer
        randomizer.finalize(state)
    end
    state.randomizer = nil

    -- Is the game completable?
    local random_graph_top_sort = top_sort.sort(state.random_graph)
    assert(random_graph_top_sort.reachable[state.end_game_node_key] ~= nil)
    return true
end

return export
