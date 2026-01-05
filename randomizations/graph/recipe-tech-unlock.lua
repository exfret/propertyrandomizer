local build_graph = require("lib/graph/build-graph")
local top_sort = require("lib/graph/top-sort")
local rng = require("lib/random/rng")

randomizations.recipe_tech_unlock = function(id)
    local sort_info = top_sort.sort(dep_graph)
    local graph_sort = sort_info.sorted

    -- Let's just treat recipe unlocks like they're AND nodes even though they're actually OR's, this will simplify some things

    local unlock_sort = {}
    local shuffled_tech_prereqs = {}
    local blacklist = {}
    local prev_num_prereqs = {}
    -- Add technologies an extra time to the pool
    local added_to_pool_extra = {}
    for _, node in pairs(graph_sort) do
        if node.type == "recipe-tech-unlock" then
            table.insert(unlock_sort, node)
            local prev_num_prereqs_for_this_node = 0
            for _, prereq in pairs(node.prereqs) do
                if prereq.type == "technology" then
                    prev_num_prereqs_for_this_node = prev_num_prereqs_for_this_node + 1
                    table.insert(shuffled_tech_prereqs, prereq)
                    if not added_to_pool_extra[prereq.name] then
                        added_to_pool_extra[prereq.name] = true
                        -- Add an extra time
                        table.insert(shuffled_tech_prereqs, prereq)
                    end
                    blacklist[build_graph.conn_key({prereq, node})] = true

                    -- Hacky way: Just remove connections like with item rando
                    -- TODO: Do this in a better way, similar to fluid rando
                    --[[local prereq_node = dep_graph[build_graph.key(prereq.type, prereq.name)]
                    local ind_to_remove
                    for ind, dependent in pairs(prereq_node.dependents) do
                        if dependent.type == node.type and dependent.name == node.name then
                            ind_to_remove = ind
                            break
                        end
                    end
                    table.remove(prereq_node.dependents, ind_to_remove)]]
                end
            end
            -- This is so hacky
            --[[node.prereqs = {
                {
                    type = "starting-planet",
                    name = "canonical"
                }
            }
            blacklist[build_graph.conn_key({dep_graph[build_graph.key("starting-planet", "canonical")], node})] = true]]
            
            prev_num_prereqs[node.name] = prev_num_prereqs_for_this_node
        end
    end

    rng.shuffle(rng.key({id = id}), shuffled_tech_prereqs)

    local prereq_inds_used = {}
    local unlock_node_to_new_prereqs = {}
    local sort_state = top_sort.sort(dep_graph, blacklist)

    for _, unlock_node in pairs(unlock_sort) do
        log("Randomizing tech unlock: " .. unlock_node.name)

        unlock_node_to_new_prereqs[unlock_node.name] = {}
        for i = 1, prev_num_prereqs[unlock_node.name] do
            local found_prereq = false
            for ind, prereq in pairs(shuffled_tech_prereqs) do
                if not prereq_inds_used[ind] and sort_state.reachable[build_graph.key(prereq.type, prereq.name)] then
                    log("Randomized to: " .. prereq.name)

                    prereq_inds_used[ind] = true
                    table.insert(unlock_node_to_new_prereqs[unlock_node.name], prereq)
                    found_prereq = true
                    break
                end
            end
            if not found_prereq then
                error()
            end
        end

        -- Update blacklist
        for _, prereq in pairs(unlock_node.prereqs) do
            if prereq.type == "technology" then
                blacklist[build_graph.conn_key({prereq, unlock_node})] = false
                sort_state = top_sort.sort(dep_graph, blacklist, sort_state, {prereq, unlock_node})
            end
        end
        --for _, prereq in pairs(unlock_node_to_new_prereqs[unlock_node.name]) do
            --[[table.insert(unlock_node.prereqs, prereq)
            local prereq_node = dep_graph[build_graph.key(prereq.type, prereq.name)]
            table.insert(prereq_node.dependents, {
                type = unlock_node.type,
                name = unlock_node.name
            })]]
            --[[blacklist[build_graph.conn_key({dep_graph[build_graph.key("starting-planet", "canonical")], unlock_node})] = false
            sort_state = top_sort.sort(dep_graph, blacklist, sort_state, {dep_graph[build_graph.key("starting-planet", "canonical")], unlock_node})]]
        --end
    end

    -- Fix data.raw

    -- First remove old recipe tech unlocks
    for _, technology in pairs(data.raw.technology) do
        if technology.effects ~= nil then
            local new_effects = {}
            for _, effect in pairs(technology.effects) do
                if effect.type ~= "unlock-recipe" then
                    table.insert(new_effects, effect)
                end
            end
            technology.effects = new_effects
        end
    end

    -- Now add new tech unlocks
    local added_tech_unlock_already = {}
    for unlock_node_name, prereq_list in pairs(unlock_node_to_new_prereqs) do
        for _, prereq in pairs(prereq_list) do
            if added_tech_unlock_already[prereq.name] == nil then
                added_tech_unlock_already[prereq.name] = {}
            end
            if not added_tech_unlock_already[prereq.name][unlock_node_name] then
                table.insert(data.raw.technology[prereq.name].effects, {
                    type = "unlock-recipe",
                    recipe = unlock_node_name
                })
                added_tech_unlock_already[prereq.name][unlock_node_name] = true
            end
        end
    end
end

randomizations.recipe_tech_unlock_new = function(graph)
    local top = require("new-lib/graph/top-sort")
    local gutils = require("new-lib/graph/graph-utils")

    local sort_info = top.sort(graph)
    local open = sort_info.open

    local unlock_sort = {}
    local added_to_sort = {}
    local shuffled_tech_prereqs = {}
    local prev_num_prereqs = {}
    -- Add technologies an extra time to the pool
    local added_to_pool_extra = {}
    for _, open_info in pairs(open) do
        local node = graph.nodes[open_info.node]
        if node.type == "recipe-tech-unlock" and not added_to_sort[open_info.node] then
            table.insert(unlock_sort, node)
            local prev_num_prereqs_for_this_node = 0
            local edges_to_remove = {}
            for pre, _ in pairs(node.pre) do
                local prereq = graph.nodes[graph.edges[pre].start]
                if prereq.type == "technology" then
                    table.insert(edges_to_remove, pre)
                    prev_num_prereqs_for_this_node = prev_num_prereqs_for_this_node + 1
                    table.insert(shuffled_tech_prereqs, prereq)
                    if not added_to_pool_extra[prereq.name] then
                        added_to_pool_extra[prereq.name] = true
                        -- Add an extra time
                        table.insert(shuffled_tech_prereqs, prereq)
                    end

                    -- Hacky way: Just remove connections like with item rando
                    -- TODO: Do this in a better way, similar to fluid rando
                    --[[local prereq_node = dep_graph[build_graph.key(prereq.type, prereq.name)]
                    local ind_to_remove
                    for ind, dependent in pairs(prereq_node.dependents) do
                        if dependent.type == node.type and dependent.name == node.name then
                            ind_to_remove = ind
                            break
                        end
                    end
                    table.remove(prereq_node.dependents, ind_to_remove)]]
                end
            end
            -- This is so hacky
            --[[node.prereqs = {
                {
                    type = "starting-planet",
                    name = "canonical"
                }
            }
            blacklist[build_graph.conn_key({dep_graph[build_graph.key("starting-planet", "canonical")], node})] = true]]
            
            -- Remove old prereqs
            for _, edge_key in pairs(edges_to_remove) do
                gutils.remove_edge(graph, edge_key)
            end
            
            prev_num_prereqs[node.name] = prev_num_prereqs_for_this_node
        end
    end

    rng.shuffle(rng.key({id = "how"}), shuffled_tech_prereqs)

    local prereq_inds_used = {}
    local unlock_node_to_new_prereqs = {}
    local sort_state = top.sort(graph)

    for _, unlock_node in pairs(unlock_sort) do
        log("Randomizing tech unlock: " .. unlock_node.name)

        unlock_node_to_new_prereqs[unlock_node.name] = {}
        for i = 1, prev_num_prereqs[unlock_node.name] do
            local found_prereq = false
            for ind, prereq in pairs(shuffled_tech_prereqs) do
                -- Reachable means by at least one context (not false or nil)
                -- Contexts is always a table now (never true)
                local contexts = sort_state.node_to_contexts[gutils.key(prereq)]
                if not prereq_inds_used[ind] and contexts ~= nil and next(contexts) ~= nil then
                    log("Randomized to: " .. prereq.name)

                    prereq_inds_used[ind] = true
                    table.insert(unlock_node_to_new_prereqs[unlock_node.name], prereq)
                    found_prereq = true

                    -- Update graph
                    local edge = gutils.add_edge(graph, gutils.key(prereq), gutils.key(unlock_node))
                    --log(serpent.block(graph.edges[gutils.ekey(edge)]))
                    sort_state = top.sort(graph, sort_state, {
                        edge = gutils.ekey(edge),
                        contexts = sort_state.node_to_contexts[gutils.key(prereq)],
                    })

                    break
                end
            end
            if not found_prereq then
                error()
            end
        end

        --[[for _, prereq in pairs(unlock_node.prereqs) do
            if prereq.type == "technology" then
                blacklist[build_graph.conn_key({prereq, unlock_node})] = false
                sort_state = top_sort.sort(dep_graph, blacklist, sort_state, {prereq, unlock_node})
            end
        end]]
        --for _, prereq in pairs(unlock_node_to_new_prereqs[unlock_node.name]) do
            --[[table.insert(unlock_node.prereqs, prereq)
            local prereq_node = dep_graph[build_graph.key(prereq.type, prereq.name)]
            table.insert(prereq_node.dependents, {
                type = unlock_node.type,
                name = unlock_node.name
            })]]
            --[[blacklist[build_graph.conn_key({dep_graph[build_graph.key("starting-planet", "canonical")], unlock_node})] = false
            sort_state = top_sort.sort(dep_graph, blacklist, sort_state, {dep_graph[build_graph.key("starting-planet", "canonical")], unlock_node})]]
        --end
    end

    -- Fix data.raw

    -- First remove old recipe tech unlocks
    for _, technology in pairs(data.raw.technology) do
        if technology.effects ~= nil then
            local new_effects = {}
            for _, effect in pairs(technology.effects) do
                if effect.type ~= "unlock-recipe" then
                    table.insert(new_effects, effect)
                end
            end
            technology.effects = new_effects
        end
    end

    -- Now add new tech unlocks
    local added_tech_unlock_already = {}
    for unlock_node_name, prereq_list in pairs(unlock_node_to_new_prereqs) do
        for _, prereq in pairs(prereq_list) do
            if added_tech_unlock_already[prereq.name] == nil then
                added_tech_unlock_already[prereq.name] = {}
            end
            if not added_tech_unlock_already[prereq.name][unlock_node_name] then
                table.insert(data.raw.technology[prereq.name].effects, {
                    type = "unlock-recipe",
                    recipe = unlock_node_name
                })
                added_tech_unlock_already[prereq.name][unlock_node_name] = true
            end
        end
    end
end