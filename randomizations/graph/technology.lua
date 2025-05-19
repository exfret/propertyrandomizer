local build_graph = require("lib/graph/build-graph")
local top_sort = require("lib/graph/top-sort")
local rng = require("lib/random/rng")

randomizations.technology_tree_insnipping = function(id, dont_apply)
    local function hash_tech(tech)
        if tech.unit == nil then
            return "triggertech"
        end
        local ing_list = {}
        for _, ing in pairs(tech.unit.ingredients) do
            table.insert(ing_list, ing[1])
        end
        return build_graph.compound_key(ing_list)
    end

    local sort_info = top_sort.sort(dep_graph)
    local graph_sort = sort_info.sorted

    local tech_sort = {}
    local blacklist = {}
    for _, node in pairs(graph_sort) do
        if node.type == "technology" then
            table.insert(tech_sort, node)

            for _, prereq in pairs(node.prereqs) do
                blacklist[build_graph.conn_key({prereq, node})] = true
            end
        end
    end

    -- Last resort shuffle
    local tech_shuffle = table.deepcopy(tech_sort)
    rng.shuffle(rng.key({id = id}), tech_shuffle)

    local color_to_tech = {}
    for _, node in pairs(tech_sort) do
        ing_hash = hash_tech(data.raw.technology[node.name])

        if color_to_tech[ing_hash] == nil then
            color_to_tech[ing_hash] = {}
        end
        table.insert(color_to_tech[ing_hash], node)
    end

    -- "First" resort shuffle
    local color_to_tech_shuffled = table.deepcopy(color_to_tech)
    for _, tech_list in pairs(color_to_tech_shuffled) do
        rng.shuffle(rng.key({id = id}), tech_list)
    end

    local tech_to_new_prereqs = {}
    local stripped_techs = {}
    local sort_state = top_sort.sort(dep_graph, blacklist)
    for ind, node in pairs(tech_sort) do
        local reachable = sort_state.reachable

        local found_correct_color = false
        local correct_color_techs = color_to_tech_shuffled[hash_tech(data.raw.technology[node.name])]

        local function search_over_list(node_list)
            for _, new_node in pairs(node_list) do
                -- If we haven't stripped this node yet and it's reachable, strip it and add over the prereqs
                if not stripped_techs[new_node.name] and reachable[build_graph.key(new_node.type, new_node.name)] then
                    stripped_techs[new_node.name] = true

                    -- Add new prereqs
                    tech_to_new_prereqs[node.name] = {}
                    for _, prereq in pairs(new_node.prereqs) do
                        if prereq.type == "technology" then
                            table.insert(tech_to_new_prereqs[node.name], prereq.name)
                        end
                    end

                    return true
                end
            end

            return false
        end
        
        if not search_over_list(correct_color_techs) then
            if not search_over_list(tech_shuffle) then
                -- Couldn't find a prerequisite
                error()
            end
        end

        -- Update reachable
        for _, prereq in pairs(node.prereqs) do
            blacklist[build_graph.conn_key({prereq, node})] = false
            sort_state = top_sort.sort(dep_graph, blacklist, sort_state, {prereq, node})
        end
    end

    if not dont_apply then
        -- Fix data.raw
        for _, node in pairs(tech_sort) do
            data.raw.technology[node.name].prerequisites = tech_to_new_prereqs[node.name]
        end
    else
        return tech_to_new_prereqs
    end

    -- Stage where we make tech tree "make sense" science pack wise
    -- If something requires a science pack to reach, make it require that in its research
    -- Then, if something doesn't have a science pack as a prereq other than as a direct ingredient, remove that from it
    -- TODO: Consider whether to actually have this
end

-- Attempt at outsnipping code
--[[randomizations.technology_tree_outsnipping = function(id)
    -- Reverse prereqs/dependents
    for _, node in pairs(dep_graph) do
        local temp_prereqs = node.prereqs
        node.prereqs = node.dependents
        node.dependents = temp_prereqs
    end

    -- Apply insnipping
    local new_deps = randomizations.technology_tree_insnipping(id, true)

    -- Fix data.raw
    for tech_name, _ in pairs(new_deps) do
        data.raw.technology[tech_name].prerequisites = {}
    end
    for tech_name, deps in pairs(new_deps) do
        for _, dep in pairs(deps) do
            table.insert(data.raw.technology[dep].prerequisites, tech_name)
        end
    end

    -- Reverse again to fix dep_graph
    for _, node in pairs(dep_graph) do
        local temp_prereqs = prereqs
        node.prereqs = node.dependents
        node.dependents = temp_prereqs
    end
end]]

-- Old prereq shuffle code
--[[randomizations.technology_tree = function(id)
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
            
            -- Give each thing another chance to be a prereq
            table.insert(shuffled_prereqs, {
                type = node.type,
                name = node.name
            })
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
            local found_prereq = false
            for ind, prereq in pairs(shuffled_prereqs) do
                if not ind_to_used[ind] and reachable_hacky[prereq.name] and not already_included[prereq.name] then
                    
                    log(node.name)
                    log(prereq.name)
                    
                    table.insert(tech_to_new_prereqs[node.name], prereq.name)
                    ind_to_used[ind] = true
                    already_included[prereq.name] = true
                    found_prereq = true
                    break
                end
            end
            if not found_prereq then
                log(node.name)
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

    -- Stage where we make tech tree "make sense" science pack wise
    -- If something requires a science pack to reach, make it require that in its research
    -- Then, if something doesn't have a science pack as a prereq other than as a direct ingredient, remove that from it
end]]