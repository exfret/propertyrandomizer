local constants = require("helper-tables/constants")

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

    -- A reachability graph for each of the three starter planets
    -- If something is in the reachability graph for one planet, it can't rely on things outside it
    -- CRITICAL TODO: Test for base game/don't hardcode planets here
    local planet_names = {}
    if mods["space-age"] then
        planet_names = {"fulgora", "gleba", "vulcanus"}
    end
    local planet_sort_info = {}
    for _, planet_name in pairs(planet_names) do
        local planet_specific_blacklist = {}
        for _, other_planet_name in pairs(planet_names) do
            if other_planet_name ~= planet_name then
                local other_planet_node = dep_graph[build_graph.key("space-location-discovery", other_planet_name)]
                for _, prereq in pairs(other_planet_node.prereqs) do
                    planet_specific_blacklist[build_graph.conn_key({prereq, other_planet_node})] = true
                end
            end
        end
        -- Also blacklist planet science packs so that things after them can require other planets
        for _, science_pack_name in pairs({"electromagnetic-science-pack", "agricultural-science-pack", "metallurgic-science-pack"}) do
            local science_pack_node = dep_graph[build_graph.key("item", science_pack_name)]
            for _, prereq in pairs(science_pack_node.prereqs) do
                planet_specific_blacklist[build_graph.conn_key({prereq, science_pack_node})] = true
            end
        end
        planet_sort_info[planet_name] = top_sort.sort(dep_graph, planet_specific_blacklist)
    end

    -- Last resort shuffle
    local tech_shuffle = table.deepcopy(tech_sort)
    rng.shuffle(rng.key({id = id}), tech_shuffle)

    -- "First" resort shuffle

    local color_to_tech = {}
    for _, node in pairs(tech_sort) do
        ing_hash = hash_tech(data.raw.technology[node.name])

        if color_to_tech[ing_hash] == nil then
            color_to_tech[ing_hash] = {}
        end
        table.insert(color_to_tech[ing_hash], node)
    end

    local color_to_tech_shuffled = table.deepcopy(color_to_tech)
    for _, tech_list in pairs(color_to_tech_shuffled) do
        rng.shuffle(rng.key({id = id}), tech_list)
    end

    local tech_to_new_prereqs = {}
    local stripped_techs = {}
    local sort_state = top_sort.sort(dep_graph, blacklist)
    for ind, node in pairs(tech_sort) do
        local reachable = table.deepcopy(sort_state.reachable)
        -- Refine reachable to exclude techs not reachable from a single planet if applicable
        local to_remove_from_reachable = {}
        local is_nauvis_tech = true
        for _, planet_name in pairs(planet_names) do
            if planet_sort_info[planet_name].reachable[build_graph.key(node.type, node.name)] then
                for reachable_node_name, _ in pairs(reachable) do
                    if not planet_sort_info[planet_name].reachable[reachable_node_name] then
                        to_remove_from_reachable[reachable_node_name] = true
                    end
                end
            else
                -- Don't allow science packs to take the spot of earlier packs, which leads to too few spots at that level
                for reachable_node_name, _ in pairs(reachable) do
                    if planet_sort_info[planet_name].reachable[reachable_node_name] then
                        to_remove_from_reachable[reachable_node_name] = true
                    end
                end

                is_nauvis_tech = false
            end
        end
        for reachable_node_name, _ in pairs(to_remove_from_reachable) do
            reachable[reachable_node_name] = nil
        end

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
        
        -- Only try color preservation for nauvis techs
        if (not is_nauvis_tech) or not search_over_list(correct_color_techs) then
            if not search_over_list(tech_shuffle) then
                -- Couldn't find a prerequisite
                error()
            end
        end

        -- Update blacklist
        for _, prereq in pairs(node.prereqs) do
            blacklist[build_graph.conn_key({prereq, node})] = false
            sort_state = top_sort.sort(dep_graph, blacklist, sort_state, {prereq, node})
        end
    end

    if not dont_apply then
        -- Fix data.raw
        for _, node in pairs(tech_sort) do
            data.raw.technology[node.name].prerequisites = tech_to_new_prereqs[node.name]
            data.raw.technology[node.name].upgrade = false
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