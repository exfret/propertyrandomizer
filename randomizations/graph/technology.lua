local build_graph = require("lib/graph/build-graph")
local top_sort = require("lib/graph/top-sort")
local rng = require("lib/random/rng")

randomizations.technology_tree = function(id)
    local sort_info = top_sort.sort(dep_graph)
    local graph_sort = sort_info.sorted

    local sorted_deps = {}
    local shuffled_prereqs = {}
    local dep_to_num_tech_prereqs = {}
    local blacklist = {}
    for _, node in pairs(graph_sort) do
        if node.type == "technology" then
            table.insert(sorted_deps, node)
            dep_to_num_tech_prereqs[build_graph.key(node.type, node.name)] = 0

            for i = #node.prereqs, 1, -1 do
                local prereq = node.prereqs[i]
                blacklist[build_graph.conn_key({prereq, node})] = true

                if prereq.type == "technology" then
                    table.insert(shuffled_prereqs, prereq)
                    dep_to_num_tech_prereqs[build_graph.key(node.type, node.name)] = dep_to_num_tech_prereqs[build_graph.key(node.type, node.name)] + 1
                    -- Literally remove this prereq
                    --table.remove(node.prereqs, i)
                end
            end
        end
    end

    rng.shuffle(rng.key({id = id}), shuffled_prereqs)

    local tech_to_new_prereqs = {}
    local ind_to_used = {}
    local sort_state = top_sort.sort(dep_graph, blacklist)
    -- CRITICAL TODO: Check that this is actually the way to do this
    local reachable_hacky = {}
    for _, node in pairs(sorted_deps) do
        local reachable = sort_state.reachable
        tech_to_new_prereqs[node.name] = {}

        local already_included = {}
        for i = 1, dep_to_num_tech_prereqs[build_graph.key(node.type, node.name)] do
            for ind, prereq in pairs(shuffled_prereqs) do
                if not ind_to_used[ind] and reachable_hacky[prereq.name] and not already_included[prereq.name] then
                    table.insert(tech_to_new_prereqs[node.name], prereq.name)
                    ind_to_used[ind] = true
                    already_included[prereq.name] = true
                    break
                end
            end
        end

        reachable_hacky[node.name] = true

        for _, prereq in pairs(node.prereqs) do
            blacklist[build_graph.conn_key({prereq, node})] = false
            sort_state = top_sort.sort(dep_graph, blacklist, sort_state, {prereq, node})
        end
    end

    -- Fix data.raw
    for _, node in pairs(sorted_deps) do
        data.raw.technology[node.name].prerequisites = tech_to_new_prereqs[node.name]
    end
end