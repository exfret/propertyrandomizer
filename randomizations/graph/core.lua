-- This is a draft of a master graph randomization algorithm by Nifyr

local top_sort = require("lib/graph/top-sort")
local rng = require("lib/random/rng")
local displace = require("lib/random/displacement-shuffle")
local graph_utils = require("lib/graph/graph-utils")
local build_graph = require("lib/graph/build-graph")
local path_utils = require("lib/graph/path")
local critical_req = require("lib/graph/critical-req")
local set_utils = require("lib/graph/set-utils")
local queue = require("lib/graph/queue")

local graph_randomizations = {}


graph_randomizations.create_empty_randomizer = function (key)
    return {
        -- Arbitrary unique name.
        -- Maybe "recipe", or maybe "technology"?
        key = key,
        -- Optional, called once before all other functions.
        -- Pre-computations, who knows?
        initialize = function (state) end,
        -- Called once. Used to calculate critical nodes.
        -- Return the set of edges that might be removed/changed by this randomizer. 
        get_target_edges = function (state) return {} end,
        -- Optional, called directly before each graph randomization attempt.
        -- More pre-computations?? You decide!
        pre_randomization = function (state) end,
        -- Called repeatedly during graph randomization to select new edges for a dependent.
        -- Puts edges in state.new_edges, ideally pulling from state.suitable_edges.
        execute_randomization = function (state) end,
        -- Optional, called directly after each graph randomization attempt.
        -- Graph fixes maybe?
        post_randomization = function (state) end,
        -- Optional, called last after a successful randomization attempt.
        -- Writing to data.raw? That can be done in any of these functions, but this is an option.
        finalize = function (state) end,
    }
end

graph_randomizations.add = function (randomizer)
    graph_randomizations.randomizers[randomizer.key] = randomizer
end

graph_randomizations.randomizers = {}

randomizations.graph = function(id)

    local technology_node_type = "technology"
    local recipe_node_type = "recipe-surface"
    local item_node_type = "item-surface"
    local fluid_node_type = "fluid-surface"
    local recipe_unlock_node_type = "recipe-tech-unlock"
    local craft_material_node_type = "craft-material-surface"
    local mining_node_type = "mine-entity-surface"
    local craft_material_anywhere_node_type = "craft-material"
    local planet_access_node_type = "planet"
    local space_unlock_node_type = "create-space-platform-tech-unlock"
    local mining_with_fluid_unlock_node_type = "mining-with-fluid-unlock"
    local space_location_discovery_node_type = "space-location-discovery"
    local starting_planet_node_type = "starting-planet"
    local arbitrary_unlock_node_type = "arbitrary-unlock"
    local spaceship_node_type = "spaceship"
    local rocket_launch_planet_node_type = "rocket-launch-planet"
    local vulcanus_name = "vulcanus"
    local gleba_name = "gleba"
    local fulgora_name = "fulgora"
    local surface_type_planet = "planet"
    local canonical_name = "canonical"
    local electric_energy_distribution_1 = "electric-energy-distribution-1"
    local planet_discovery_vulcanus = "planet-discovery-vulcanus"
    local promethium_science_pack = "promethium-science-pack"

    -- Let's just put everything in a table and pass the whole thing to randomizers when the time comes
    local state = {}

    state.rng_key = rng.key({id = id})
    state.scenario_planet_names = { vulcanus_name, gleba_name, fulgora_name }
    state.permanent_unlock_node_types = {
        [space_unlock_node_type] = true,
        [mining_with_fluid_unlock_node_type] = true,
        [recipe_unlock_node_type] = true,
        [space_location_discovery_node_type] = true,
        [technology_node_type] = true,
    }

    -- Let's prepare the vanilla graph
    build_graph.load()
    build_graph.add_dependents(build_graph.graph)

    -- Find a random possible topological ordering, as opposed to always breadth first
    state.vanilla_top_sort = top_sort.sort(build_graph.graph, nil, nil, nil, { randomized = true, key = state.rng_key })

    -- Assuming the promethium science pack technology serves as a nice end point
    local end_game_key = build_graph.key(technology_node_type, promethium_science_pack)
    assert(state.vanilla_top_sort.reachable[end_game_key])

    state.vanilla_graph = {}
    state.top_sort_ordinals = {}
    state.source_nodes_keys = {}
    state.node_type_to_node_keys = {}
    state.surface_specific_node_types = {}
    for ordinal, node in pairs(state.vanilla_top_sort.sorted) do

        -- Let's strip the graph of unreachable nodes
        local key = graph_utils.get_node_key(node)
        state.vanilla_graph[key] = build_graph.graph[key]

        -- Get rid of prereqs and dependents that point to unreachable nodes
        local old_prereq_count = #node.prereqs
        local new_prereq_count = 0
        for i = 1, old_prereq_count do
            local prereq = node.prereqs[i]
            node.prereqs[i] = nil
            if state.vanilla_top_sort.reachable[graph_utils.get_node_key(prereq)] then
                new_prereq_count = new_prereq_count + 1
                node.prereqs[new_prereq_count] = prereq
            end
        end
        local old_dependent_count = #node.dependents
        local new_dependent_count = 0
        for i = 1, old_dependent_count do
            local dependent = node.dependents[i]
            node.dependents[i] = nil
            if state.vanilla_top_sort.reachable[graph_utils.get_node_key(dependent)] then
                new_dependent_count = new_dependent_count + 1
                node.dependents[new_dependent_count] = dependent
            end
        end

        -- Let's grab the node ordinals from this randomized topological sort
        state.top_sort_ordinals[key] = ordinal

        -- Let's keep track of the source nodes
        if graph_utils.is_this_one_of_those_uh_one_of_those_nodes_that_you_when_theres_like_uh_source_node_thats_what_its_called_is_that_what_this_is(node) then
            table.insert(state.source_nodes_keys, graph_utils.get_node_key(node))
        end

        -- Lookup for nodes of a certain type
        if state.node_type_to_node_keys[node.type] == nil then
            state.node_type_to_node_keys[node.type] = {}
        end
        table.insert(state.node_type_to_node_keys[node.type], graph_utils.get_node_key(node))

        -- Find out which nodes has different surface versions
        if state.surface_specific_node_types[node.type] == nil and node.surface ~= nil then
            state.surface_specific_node_types[node.type] = true
        end
    end

    -- Sort all prereqs in this randomized topological order
    -- Needed for path calculation
    state.top_sort_ordinals.MAX = #state.vanilla_top_sort.sorted + 1
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
    for _, node in pairs(state.vanilla_top_sort.sorted) do
        sort_prereqs(node.prereqs, state.top_sort_ordinals)
    end

    state.surface_specific = function (node_type)
        return state.surface_specific_node_types[node_type] ~= nil
    end

    -- Make arbitrary unlock node for forcing things to be reachable
    local arbitrary_unlock_node = {
        type = arbitrary_unlock_node_type,
        name = canonical_name,
        prereqs = {},
        dependents = {},
    }
    build_graph.ops[arbitrary_unlock_node_type] = graph_utils.and_type
    state.arbitrary_unlock_node_key = graph_utils.get_node_key(arbitrary_unlock_node)
    state.vanilla_graph[state.arbitrary_unlock_node_key] = arbitrary_unlock_node
    table.insert(state.source_nodes_keys, state.arbitrary_unlock_node_key)
    state.force_reachable = function (node, graph)
        local unlock_node = graph[state.arbitrary_unlock_node_key]
        graph_utils.clear_prereqs(node, graph)
        graph_utils.add_prereq(unlock_node, node)
    end

    -- Due to a quirk of vanilla space age, it's actually possible to softlock on vulcanus if you stuck there before
    -- unlocking the electric energy distribution 1 technology. This breaks the critical requirement calculation below.
    -- Thus we will adjust the vanilla graph a little bit.
    local electric_energy_distribution_1_node = state.vanilla_graph[build_graph.key(technology_node_type, electric_energy_distribution_1)]
    local planet_discovery_vulcanus_node = state.vanilla_graph[build_graph.key(technology_node_type, planet_discovery_vulcanus)]
    graph_utils.add_prereq(electric_energy_distribution_1_node, planet_discovery_vulcanus_node)

    ---------------------------------------------------------------------------------------------------------------------------
    -- This region is purely for testing, remember to remove!
    ---------------------------------------------------------------------------------------------------------------------------

    local tech_tree_randomizer = graph_randomizations.create_empty_randomizer("technology")
    tech_tree_randomizer.get_target_edges = function (params)
        local edges = {}
        for _, node_key in pairs(params.node_type_to_node_keys[technology_node_type]) do
            local node = params.vanilla_graph[node_key]
            for _, prereq in pairs(node.prereqs) do
                if prereq.type == technology_node_type then
                    local edge = graph_utils.create_edge(graph_utils.get_node_key(prereq), node_key, params.vanilla_graph)
                    edges[edge.key] = edge
                end
            end
        end
        return edges
    end
    tech_tree_randomizer.execute_randomization = function (params)
        if #params.suitable_edges < params.first_edge_count then
            params.postpone = true
            return
        end
        rng.shuffle(state.rng_key, params.suitable_edges)
        for i = 1, params.first_edge_count do
            params.new_edges[i] = params.suitable_edges[i]
        end
    end
    graph_randomizations.add(tech_tree_randomizer)
    local recipe_randomizer = graph_randomizations.create_empty_randomizer("recipe")
    recipe_randomizer.get_target_edges = function (params)
        local edges = {}
        for _, node_key in pairs(params.node_type_to_node_keys[recipe_node_type]) do
            local node = params.vanilla_graph[node_key]
            for _, prereq in pairs(node.prereqs) do
                if prereq.type == item_node_type or prereq.type == fluid_node_type then
                    local edge = graph_utils.create_edge(graph_utils.get_node_key(prereq), node_key, params.vanilla_graph)
                    edges[edge.key] = edge
                end
            end
        end
        return edges
    end
    recipe_randomizer.execute_randomization = function (params)
        if #params.suitable_edges < params.first_edge_count then
            params.postpone = true
            return
        end
        rng.shuffle(state.rng_key, params.suitable_edges)
        for i = 1, params.first_edge_count do
            params.new_edges[i] = params.suitable_edges[i]
        end
    end
    graph_randomizations.add(recipe_randomizer)

    ---------------------------------------------------------------------------------------------------------------------------
    -- End of test region
    ---------------------------------------------------------------------------------------------------------------------------

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
    state.add_surface_ambiguous_key_info = function (node_type)
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
        state.add_surface_ambiguous_key_info(node_type)
    end
    for node_type, _ in pairs(state.target_dependent_types) do
        state.add_surface_ambiguous_key_info(node_type)
    end

    -- Constitutes an attempt at graph randomization
    state.try_randomize_graph = function ()

        -- Base the randomized graph off of the vanilla graph
        state.random_graph = table.deepcopy(state.vanilla_graph)

        -- Shuffled nodes
        state.shuffled_order = {}
        for i, node in pairs(state.vanilla_top_sort.sorted) do
            state.shuffled_order[i] = node
        end
        -- How much do we wanna displace the nodes?
        local avg_displacement = #state.shuffled_order / math.exp(3)
        displace.displacement_shuffle_chaos(state.rng_key, state.shuffled_order, avg_displacement)

        state.shuffled_order_ordinals = {}
        for i, node in pairs(state.shuffled_order) do
            state.shuffled_order_ordinals[graph_utils.get_node_key(node)] = i
        end

        -- Ensure topological ordering of nodes whose edges we're not changing
        for i = 1, #state.shuffled_order do
            local node = state.shuffled_order[i]
            local node_key = graph_utils.get_node_key(node)
            if graph_utils.is_and_node(node) then
                local highest_ordinal = 0
                for _, prereq in pairs(node.prereqs) do
                    local prereq_key = graph_utils.get_node_key(prereq)
                    local edge = graph_utils.create_edge(prereq_key, node_key, state.random_graph)
                    local prereq_ordinal = state.shuffled_order_ordinals[prereq_key]
                    if state.target_edges[edge.key] ~= nil then
                        prereq_ordinal = 0
                    end
                    if prereq_ordinal > highest_ordinal then
                        highest_ordinal = prereq_ordinal
                    end
                end
                if highest_ordinal > i then
                    local prereq_node = state.shuffled_order[highest_ordinal]
                    local prereq_key = graph_utils.get_node_key(prereq_node)
                    state.shuffled_order[highest_ordinal] = node
                    state.shuffled_order[i] = prereq_node
                    state.shuffled_order_ordinals[node_key] = highest_ordinal
                    state.shuffled_order_ordinals[prereq_key] = i
                    i = i - 1
                end
            elseif graph_utils.is_or_node(node) then
                local lowest_ordinal = #state.shuffled_order + 1
                for _, prereq in pairs(node.prereqs) do
                    local prereq_key = graph_utils.get_node_key(prereq)
                    local edge = graph_utils.create_edge(prereq_key, node_key, state.random_graph)
                    local prereq_ordinal = state.shuffled_order_ordinals[prereq_key]
                    if state.target_edges[edge.key] ~= nil then
                        prereq_ordinal = 0
                    end
                    if prereq_ordinal < lowest_ordinal then
                        lowest_ordinal = prereq_ordinal
                    end
                end
                if lowest_ordinal > i then
                    local prereq_node = state.shuffled_order[lowest_ordinal]
                    local prereq_key = graph_utils.get_node_key(prereq_node)
                    state.shuffled_order[lowest_ordinal] = node
                    state.shuffled_order[i] = prereq_node
                    state.shuffled_order_ordinals[node_key] = lowest_ordinal
                    state.shuffled_order_ordinals[prereq_key] = i
                    i = i - 1
                end
            end
        end

        -- Set up scenarios to figure out critical edges for getting un-stuck
        state.scenario_to_critical_edges = {}
        state.scenario_goal_node_key = build_graph.key(spaceship_node_type, canonical_name)
        for _, planet_name in pairs(state.scenario_planet_names) do

            -- Construct scenario
            local scenario_graph = table.deepcopy(state.vanilla_graph)

            -- Scenario starts with the unlocks needed to get to the planet
            local planet_access_node_key = build_graph.key(planet_access_node_type, planet_name)
            local vanilla_planet_access_node = state.vanilla_graph[planet_access_node_key]
            local path = path_utils.find_path(state.vanilla_graph, vanilla_planet_access_node, state.permanent_unlock_node_types)
            for node_key, _ in pairs(path) do
                state.force_reachable(scenario_graph[node_key], scenario_graph)
            end

            -- Remove access to starting planet, probably nauvis
            local starting_planet_node = scenario_graph[build_graph.key(starting_planet_node_type, canonical_name)]
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

        -- Keep track of which nodes we haven't decided prereqs for yet
        state.locked_nodes = {}
        for node_type, _ in pairs(state.target_dependent_types) do
            for _, node_key in pairs(state.node_type_to_node_keys[node_type]) do
                state.locked_nodes[node_key] = true
            end
        end

        -- Create scenarios to keep track of while randomizing the new graph
        state.scenarios = {}
        for _, planet_name in pairs(state.scenario_planet_names) do
            local scenario = {
                surface_key = build_graph.compound_key({surface_type_planet, planet_name}),
                planet_name = planet_name,
                graph = table.deepcopy(state.vanilla_graph),

                -- End goal for scenario
                goal_node_key = state.scenario_goal_node_key,

                -- For doing graph traversal
                node_queue = queue.new_queue(),
                discovered = {},
                reachable = {},
                lock_bypass = {},

                -- Keep track of reachable prereq nodes
                prereq_info = {},

                -- For parallel progression
                start_node_key = build_graph.key(planet_access_node_type, planet_name),
            }
            state.scenarios[scenario.planet_name] = scenario

            -- Remove access to starting planet, probably nauvis
            local starting_planet_node = scenario.graph[build_graph.key(starting_planet_node_type, canonical_name)]
            local original_starting_planet_access_node = scenario.graph[graph_utils.get_node_key(starting_planet_node.dependents[1])]
            graph_utils.remove_prereq(starting_planet_node, original_starting_planet_access_node)

            -- Add access to scenario planet
            local planet_access_node = scenario.graph[scenario.start_node_key]
            graph_utils.add_prereq(starting_planet_node, planet_access_node)

            -- Start search for goal
            for _, key in pairs(state.source_nodes_keys) do
                queue.push(scenario.node_queue, key)
            end
            state.process_scenario(scenario)

            -- Set the ordinals for parallel progression
            scenario.start_ordinal = state.shuffled_order_ordinals[scenario.start_node_key]
            scenario.end_ordinal = state.shuffled_order_ordinals[build_graph.key(rocket_launch_planet_node_type, planet_name)]
            scenario.prev_ordinal = scenario.start_ordinal

            for i = 1, scenario.start_ordinal do
                local node_key = graph_utils.get_node_key(state.shuffled_order[i])
                local node = scenario.graph[node_key]
                if state.permanent_unlock_node_types[node.type] ~= nil then
                    state.unlock_scenario_node(scenario, node_key)
                end
            end
        end

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

        -- Call each randomizer's pre_randomization function
        for _, randomizer in pairs(graph_randomizations.randomizers) do
            state.randomizer = randomizer
            randomizer.pre_randomization(state)
        end
        state.randomizer = nil

        -- Mechanism for postponing prereq assignment to nodes
        state.postponed_locked_nodes = queue.new_queue()
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
        state.check_postponed_locked_nodes = false
        for ordinal, vanilla_node in pairs(state.shuffled_order) do

            -- First, go through the postponed nodes and see if any them can now be made reachable
            if not queue.is_empty(state.postponed_locked_nodes) then
                while state.check_postponed_locked_nodes do
                    state.check_postponed_locked_nodes = false
                    local old_queue = state.postponed_locked_nodes
                    state.postponed_locked_nodes = queue.new_queue()
                    while not queue.is_empty(old_queue) do
                        local call_info = queue.pop(old_queue)
                        state.postponed_nodes_set[call_info.node_key] = nil
                        state.try_make_reachable(call_info.node_key, call_info.override_scenario)
                    end
                end
            end

            -- Then go through the current node
            state.try_make_reachable(graph_utils.get_node_key(vanilla_node))

            -- Then do parallel progression
            state.parallel_progression(ordinal)
        end

        -- Cleanup time
        state.check_postponed_locked_nodes = nil
        state.node = nil
        state.node_key = nil
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
        state.unused_critical_edges_suitable = nil
        state.reachable_critical_edges_suitable = nil
        state.prereq_critical_edges_suitable = nil
        state.new_edges = nil
        state.edges_to_use = nil

        -- Lastly, call each randomizer's post-randomization function
        for _, randomizer in pairs(graph_randomizations.randomizers) do
            state.randomizer = randomizer
            randomizer.post_randomization(state)
        end
        state.randomizer = nil

        -- Did we complete all our scenarios?
        local scenarios_complete = set_utils.set_empty(state.scenarios)

        -- Is the game completable?
        local game_complete = state.random_graph_reachable[end_game_key] ~= nil

        if scenarios_complete and game_complete then
            return true
        else
            for _, scenario_key in pairs(state.scenario_planet_names) do
                state.showstoppers_per_scenario[scenario_key] = {}
            end
            while not queue.is_empty(state.postponed_locked_nodes) do
                local call_info = queue.pop(state.postponed_locked_nodes)
                local node_key = call_info.node_key
                if state.locked_nodes[node_key] ~= nil then
                    local ordinal = state.shuffled_order_ordinals[node_key]
                    local dependent = state.vanilla_graph[node_key]
                    local surface_ambiguous_key = graph_utils.get_surface_ambiguous_key(dependent)
                    for _, prereq in ipairs(dependent.prereqs) do
                        local edge_type = graph_utils.create_edge_type(prereq.type, dependent.type)
                        if state.edge_types[edge_type.key] ~= nil
                        and state.critical_node_info[edge_type.key][surface_ambiguous_key] ~= nil then
                            for scenario_key, _ in pairs(state.critical_node_info[edge_type.key][surface_ambiguous_key]) do
                                local scenario = state.scenarios[scenario_key]
                                if scenario ~= nil and ordinal < scenario.start_ordinal then
                                    state.showstoppers_per_scenario[scenario_key][node_key] = true
                                end
                            end
                        end
                    end
                end
            end
            return false
        end
    end

    -- Processes node queue of scenario
    state.process_scenario = function (scenario)
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

    -- For after having picked a new dependent for edges/new prereqs for a dependent
    state.update_scenario_graph = function (scenario, deleted_edges, added_edges)
        graph_utils.update_edges(scenario.graph, deleted_edges, added_edges)
        for _, edge in pairs(added_edges) do
            queue.push(scenario.node_queue, edge.dependent_key)
        end
        state.process_scenario(scenario)
    end

    -- For when a permanent unlock node is reached
    state.unlock_scenario_node = function (scenario, node_key)
        local graph = scenario.graph
        scenario.lock_bypass[node_key] = true
        state.force_reachable(graph[node_key], graph)
        queue.push(scenario.node_queue, node_key)
        state.process_scenario(scenario)
    end

    state.get_prereq_info = function (prereq_type, surface_key)
        if state.surface_specific(prereq_type) then
            if state.prereq_edges[prereq_type].surface_keys[surface_key] == nil then
                state.prereq_edges[prereq_type].surface_keys[surface_key] = {
                    reachable_prereqs = {},
                    all_reachable_edges = {},
                    unused_edges = {},
                }
            end
            return state.prereq_edges[prereq_type].surface_keys[surface_key]
        end
        return state.prereq_edges[prereq_type].no_surface
    end

    -- To mirror edges across surfaces
    state.clone_across_surfaces = function (edges)
        if #edges == 0 then
            return
        end
        local node_key = edges[1].dependent_key
        local single_surface_edges = table.deepcopy(edges)
        for i = 1, #edges do edges[i] = nil end

        -- Grab the surface variants of this dependent
        local surface_ambiguous_key = graph_utils.get_surface_ambiguous_key(state.random_graph[node_key])
        for surface_key, dependent_key in pairs(state.surface_ambiguous_key_info[surface_ambiguous_key].node_keys) do
            for _, edge in pairs(single_surface_edges) do
                local prereq_key = edge.prereq_key
                local prereq = state.random_graph[prereq_key]

                -- Correct the prereq surface if it's surface specific too
                if state.surface_specific(prereq.type) then
                    local prereq_surface_ambiguous_key = graph_utils.get_surface_ambiguous_key(prereq)
                    prereq_key = state.surface_ambiguous_key_info[prereq_surface_ambiguous_key].node_keys[surface_key]
                end

                -- There may not be available prereqs on all surfaces
                if prereq_key ~= nil then
                    table.insert(edges, graph_utils.create_edge(prereq_key, dependent_key, state.random_graph))
                end
            end
        end
    end

    -- For assigning edges during randomization
    state.assign_prereqs = function (node_key, override_scenario)

        state.node_key = node_key
        state.node = state.random_graph[state.node_key]

        state.dependent_is_surface_specific = state.surface_specific(state.node.type)
        state.final_old_edges = {}
        state.final_new_edges = {}
        state.final_used_edges = {}

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

                        -- The old prereqs from the perspective of this randomizer
                        state.old_edges = {}
                        for _, prereq in pairs(state.node.prereqs) do
                            local edge = graph_utils.create_edge(graph_utils.get_node_key(prereq), state.node_key, state.random_graph)
                            if prereq.type == edge_type.prereq_type and state.target_edges[edge.key] then
                                table.insert(state.old_edges, edge)
                            end
                        end

                        -- Gather the prereq edges
                        local surface_edge_info = state.get_prereq_info(edge_type.prereq_type, state.node.surface)

                        -- Picking from this set of edges ensures that the game is completable
                        state.reachable_prereqs = surface_edge_info.reachable_prereqs
                        -- Picking from this set of edges ensures that no new edges are created
                        state.all_reachable_edges = surface_edge_info.all_reachable_edges
                        -- Picking from this set of edges ensures an unchanged number of dependents per prereq
                        state.unused_edges = surface_edge_info.unused_edges
                        -- Picking from this set of edges ensures that no softlocks occur (i wish)
                        state.suitable_edges = state.unused_edges

                        if #state.suitable_edges < state.first_edge_count then
                            state.suitable_edges = state.all_reachable_edges
                        end
                        if #state.suitable_edges < state.first_edge_count then
                            state.suitable_edges = state.reachable_prereqs
                        end

                        for _, edge in pairs(state.unused_edges) do
                            assert(state.used_edges[edge.key] == nil)
                        end

                        if override_scenario ~= nil then
                            state.reachable_prereqs = {}
                            local scenario_prereq_info = override_scenario.prereq_info[edge_type.prereq_type]
                            if scenario_prereq_info ~= nil then
                                local surface_info = scenario_prereq_info.no_surface
                                if state.dependent_is_surface_specific and state.prereq_is_surface_specific then
                                    surface_info = scenario_prereq_info.surface_keys[state.node.surface]
                                end
                                if surface_info ~= nil then
                                    state.reachable_prereqs = surface_info.edges
                                end
                            end
                            state.all_reachable_edges = state.reachable_prereqs
                            state.unused_edges = state.all_reachable_edges
                            state.suitable_edges = state.unused_edges
                        end

                        -- Find out if this dependent is a shared critical requirement
                        state.critical_node = false
                        state.unused_critical_edges_suitable = false
                        state.reachable_critical_edges_suitable = false
                        state.prereq_critical_edges_suitable = false
                        local surface_ambiguous_key = graph_utils.get_surface_ambiguous_key(state.node)
                        if state.critical_node_info[edge_type_key][surface_ambiguous_key] ~= nil then

                            -- Aggregate a set of prereqs that are available in all the affected scenarios
                            local filter = set_utils.create_universal_set()
                            for scenario_key, surfaces in pairs(state.critical_node_info[edge_type_key][surface_ambiguous_key]) do
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
                                state.unused_critical_edges_suitable = true

                                state.suitable_edges = {}
                                -- Put intersection with unused edges as available edges
                                for _, edge in pairs(state.unused_edges) do
                                    local prereq = state.random_graph[edge.prereq_key]
                                    local prereq_surface_ambiguous_key = graph_utils.get_surface_ambiguous_key(prereq)
                                    if filter[prereq_surface_ambiguous_key] ~= nil then
                                        table.insert(state.suitable_edges, edge)
                                    end
                                end

                                -- Check if there's a good amount of edges
                                if #state.suitable_edges < state.first_edge_count then

                                    -- This is bad
                                    state.unused_critical_edges_suitable = false
                                    state.reachable_critical_edges_suitable = true
                                    state.suitable_edges = {}

                                    -- Try resorting to using used edges too
                                    for _, edge in pairs(state.all_reachable_edges) do
                                        local prereq = state.random_graph[edge.prereq_key]
                                        local prereq_surface_ambiguous_key = graph_utils.get_surface_ambiguous_key(prereq)
                                        if filter[prereq_surface_ambiguous_key] ~= nil then
                                            table.insert(state.suitable_edges, edge)
                                        end
                                    end
                                end

                                if #state.suitable_edges < state.first_edge_count then

                                    -- This is bad
                                    state.reachable_critical_edges_suitable = false
                                    state.prereq_critical_edges_suitable = true
                                    state.suitable_edges = {}

                                    -- Try resorting to using any found prereq
                                    for _, edge in pairs(state.reachable_prereqs) do
                                        local prereq = state.random_graph[edge.prereq_key]
                                        local prereq_surface_ambiguous_key = graph_utils.get_surface_ambiguous_key(prereq)
                                        if filter[prereq_surface_ambiguous_key] ~= nil then
                                            table.insert(state.suitable_edges, edge)
                                        end
                                    end
                                end

                                if #state.suitable_edges < state.first_edge_count then

                                    -- uh-oh
                                    state.prereq_critical_edges_suitable = false
                                    -- The randomizer will surely figure somthing out
                                end
                            end
                        end
                        -- Available edges determined

                        -- Output list
                        state.new_edges = {}

                        -- Support for letting randomizers decide to postpone a dependent
                        state.postpone = false

                        -- Determine new edges
                        randomizer.execute_randomization(state)

                        -- Abort if postponed
                        if state.postpone then
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
                            state.clone_across_surfaces(state.new_edges)
                            state.clone_across_surfaces(state.old_edges)
                            state.clone_across_surfaces(state.edges_to_use)
                        end

                        -- Apply changes to graph
                        graph_utils.update_edges(state.random_graph, state.old_edges, state.new_edges)
                    end
                end
                -- Randomizations of this edge type are complete

                -- Gather finalized changes for this edge type
                if state.dependent_is_surface_specific then
                    state.clone_across_surfaces(state.first_edges)
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
            state.used_edges[key] = true
            local edge_type = edge.type
            local prereq = state.random_graph[edge.prereq_key]
            local prereq_info = state.get_prereq_info(edge_type.prereq_type, prereq.surface)
            for i, edge2 in pairs(prereq_info.unused_edges) do
                if edge.key == edge2.key then
                    table.remove(prereq_info.unused_edges, i)
                    break
                end
            end
        end

        -- Update the scenarios in kind
        for _, scenario in pairs(state.scenarios) do
            state.update_scenario_graph(scenario, state.final_old_edges, state.final_new_edges)
        end

        -- Success
        return true
    end

    state.add_prereq_edges = function (node_key)

        state.node_key = node_key
        state.node = state.random_graph[state.node_key]

        if state.prereqs_added[node_key] ~= nil then
            return
        end
        state.prereqs_added[node_key] = true
        state.check_postponed_locked_nodes = true

        local surface_info = state.get_prereq_info(state.node.type, state.node.surface)
        local self_edge = graph_utils.create_edge(state.node_key, state.node_key, state.random_graph)
        table.insert(surface_info.reachable_prereqs, self_edge)

        -- Figure out if this node has edges we're randomizing
        for edge_type_key, edge_type in pairs(state.edge_types) do
            if edge_type.prereq_type == state.node.type then
                for _, dependent in pairs(state.node.dependents) do
                    local dependent_key = graph_utils.get_node_key(dependent)
                    local edge = graph_utils.create_edge(state.node_key, dependent_key, state.random_graph)
                    local prereq_edge_type = edge.type
                    if prereq_edge_type.key == edge_type_key
                    and state.target_edges[edge.key]
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

    state.prereqs_in_random_graph = function (node_key)
        if state.locked_nodes[node_key] ~= nil then
            return false
        end
        local node = state.random_graph[node_key]
        local node_reachable = true
        if graph_utils.is_and_node(node) then
            for _, prereq in pairs(node.prereqs) do
                if not state.random_graph_reachable[graph_utils.get_node_key(prereq)] then
                    node_reachable = false
                    break
                end
            end
        elseif graph_utils.is_or_node(node) then
            node_reachable = false
            for _, prereq in pairs(node.prereqs) do
                if state.random_graph_reachable[graph_utils.get_node_key(prereq)] then
                    node_reachable = true
                    break
                end
            end
        else
            error("how")
        end
        return node_reachable
    end

    state.try_make_reachable = function (node_key, override_scenario)
        local node = state.random_graph[node_key]

        if state.locked_nodes[node_key] ~= nil then
            -- Dependent in need of new prereqs detected
            local success = state.assign_prereqs(node_key, override_scenario)
            if success then
                state.locked_nodes[node_key] = nil
            end
        end

        if state.prereqs_in_random_graph(node_key) then
            -- Reachable node detected
            state.random_graph_reachable[node_key] = true
            for _, dependent in pairs(node.dependents) do
                local dependent_key = graph_utils.get_node_key(dependent)
                local call_info = state.postponed_nodes_set[dependent_key]
                if call_info ~= nil then
                    if state.locked_nodes[call_info.node_key] == nil then
                        state.postponed_nodes_set[dependent_key] = nil
                        state.try_make_reachable(call_info.node_key, call_info.override_scenario)
                    end
                end
            end
        elseif override_scenario == nil or state.locked_nodes[node_key] ~= nil then
            local call_info = { node_key = node_key, override_scenario = override_scenario }
            state.postponed_nodes_set[node_key] = call_info
            if state.locked_nodes[node_key] ~= nil then
                queue.push(state.postponed_locked_nodes, call_info)
            end
        end

        if state.random_graph_reachable[node_key] ~= nil
        and state.target_prereq_types[node.type] ~= nil then

            -- Reachable prereq detected
            state.add_prereq_edges(node_key)
        end
    end

    -- Make other scenarios progress in parallel with random graph to expand their pool of prereqs
    state.parallel_progression = function (ordinal)

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
            state.try_make_reachable(scenario_node_key, scenario)
        end
    end

    local success = false
    state.attempts = 0
    state.previous_showstoppers = {}
    for _, scenario_key in pairs(state.scenario_planet_names) do
        state.previous_showstoppers[scenario_key] = {}
    end
    while not success do
        state.showstoppers_per_scenario = {}
        state.attempts = state.attempts + 1
        success = state.try_randomize_graph()
        for scenario_key, node_keys in pairs(state.showstoppers_per_scenario) do
            for node_key, _ in pairs(node_keys) do
                state.previous_showstoppers[scenario_key][node_key] = true
            end
        end
    end

    -- Lastly, call each randomizer's finalize function
    for _, randomizer in pairs(graph_randomizations.randomizers) do
        state.randomizer = randomizer
        randomizer.finalize(state)
    end
    state.randomizer = nil

    -- Is the game completable?
    local random_graph_top_sort = top_sort.sort(state.random_graph)
    assert(random_graph_top_sort.reachable[end_game_key] ~= nil)
    return state
end

return graph_randomizations