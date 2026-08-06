-- Module: randomizations.graph.modules.state
-- Responsibility: construct and return the `state` table used by the graph randomization engine.

local top_sort = require("lib/graph/top-sort")
local build_graph = require("lib/graph/build-graph")
local graph_utils = require("lib/graph/graph-utils")
local rng = require("lib/random/rng")
local const = require("randomizations/graph/core/constants")
local helpers = require("randomizations/graph/core/helpers")

local export = {}

-- Callers may extend the returned state as needed.
function export.new_state(id)

    local state = {}
    state.rng_key = rng.key({id = id})

    state.scenario_planet_names = { const.vulcanus_name, const.gleba_name, const.fulgora_name }
    state.permanent_unlock_node_types = {
        [const.space_unlock_node_type] = true,
        [const.mining_with_fluid_unlock_node_type] = true,
        [const.recipe_unlock_node_type] = true,
        [const.space_location_discovery_node_type] = true,
        [const.technology_node_type] = true,

        -- compat
        ["mining-drill"] = true,
        ["assembling-machine"] = true,
        ["starter-gun"] = true,
        ["starter-gun-ammo"] = true,
        ["inserter"] = true,
        ["transport-belt"] = true,
        ["underground-belt"] = true,
        ["splitter"] = true,
        ["repair-pack"] = true,
        ["storage"] = true,
        ["rocket-turret"] = true,
        ["rocket-ammo"] = true,
        ["construction-robot"] = true,
        ["roboport"] = true,
        ["pump"] = true,
    }

    -- Let's prepare the vanilla graph
    state.vanilla_top_sort = top_sort.sort(build_graph.graph, nil, nil, nil, { randomized = true, key = state.rng_key })

    -- Make end node for checking if the game's completable
    local end_game_node = {
        type = const.end_game_node_type,
        name = const.canonical_name,
        prereqs = {},
        dependents = {},
    }
    build_graph.ops[const.end_game_node_type] = graph_utils.and_type
    state.end_game_node_key = graph_utils.get_node_key(end_game_node)
    build_graph.graph[state.end_game_node_key] = end_game_node

    -- Assuming that unlocking every technology is sufficient for considering the game completable
    for _, node in pairs(state.vanilla_top_sort.sorted) do
        if node.type == const.technology_node_type then
            graph_utils.add_prereq(node, end_game_node)
        end
    end

    -- Make arbitrary unlock node for forcing things to be reachable
    local arbitrary_unlock_node = {
        type = const.arbitrary_unlock_node_type,
        name = const.canonical_name,
        prereqs = {},
        dependents = {},
    }
    build_graph.ops[const.arbitrary_unlock_node_type] = graph_utils.and_type
    state.arbitrary_unlock_node_key = graph_utils.get_node_key(arbitrary_unlock_node)
    build_graph.graph[state.arbitrary_unlock_node_key] = arbitrary_unlock_node
    state.force_reachable = function (node, graph)
        local unlock_node = graph[state.arbitrary_unlock_node_key]
        graph_utils.clear_prereqs(node, graph)
        graph_utils.add_prereq(unlock_node, node)
    end

    -- Due to a quirk of vanilla space age, it's actually possible to softlock on vulcanus if you stuck there before
    -- unlocking the electric energy distribution 1 technology. This breaks the critical requirement calculation below.
    -- Thus we will adjust the vanilla graph a little bit.
    local electric_energy_distribution_1_node = build_graph.graph[build_graph.key(const.technology_node_type, const.electric_energy_distribution_1)]
    local planet_discovery_vulcanus_node = build_graph.graph[build_graph.key(const.technology_node_type, const.planet_discovery_vulcanus)]
    graph_utils.add_prereq(electric_energy_distribution_1_node, planet_discovery_vulcanus_node)

    -- Find a random possible topological ordering, as opposed to always breadth first
    state.vanilla_top_sort = top_sort.sort(build_graph.graph, nil, nil, nil, { randomized = true, key = state.rng_key })
    -- Surely, the vanilla game is completable, right??
    assert(state.vanilla_top_sort.reachable[state.end_game_node_key] ~= nil)

    state.vanilla_graph = build_graph.graph
    state.top_sort_ordinals = {}
    state.source_nodes_keys = {}
    state.node_type_to_node_keys = {}
    state.surface_specific_node_types = {}
    for ordinal, node in pairs(state.vanilla_top_sort.sorted) do

        local key = graph_utils.get_node_key(node)

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

    -- Put unreachable nodes in node_type_to_node_keys too
    for key, node in pairs(state.vanilla_graph) do
        if state.vanilla_top_sort.reachable[key] == nil then
            if state.node_type_to_node_keys[node.type] == nil then
                state.node_type_to_node_keys[node.type] = {}
            end
            table.insert(state.node_type_to_node_keys[node.type], graph_utils.get_node_key(node))
        end
    end

    -- Sort all prereqs in this randomized topological order
    -- Needed for path calculation
    state.top_sort_ordinals.MAX = #state.vanilla_top_sort.sorted + 1
    helpers.sort_all_prereqs(state.vanilla_top_sort.sorted, state.top_sort_ordinals)

    state.surface_specific = function (node_type)
        return state.surface_specific_node_types[node_type] ~= nil
    end

    return state
end

return export
