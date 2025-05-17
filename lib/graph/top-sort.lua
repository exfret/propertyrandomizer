-- We won't be using build_graph's graph, just its ops
local build_graph = require("build-graph")

local top_sort = {}

-- blacklist is a table sending pairs of node names representing connections to true/false
top_sort.sort = function(graph, blacklist, state, new_conn)
    if blacklist == nil then
        blacklist = {}
    end
    if state == nil then
        state = {}
    end

    local in_open = state.in_open or {}
    local open = state.open or {}
    local reachable = state.reachable or {}
    local sorted = state.sorted or {}

    local num_satisfiers = state.num_satisfiers or {}
    local num_needed_satisfiers = state.num_needed_satisfiers or {}

    local num_blacklisted_prereqs = state.num_blacklisted_prereqs or {}
    local curr_ind = state.curr_ind or 1

    -- Add sources if not already there
    if new_conn == nil then
        for node_name, node in pairs(graph) do
            num_satisfiers[node_name] = 0
            num_needed_satisfiers[node_name] = #node.prereqs
            num_blacklisted_prereqs[node_name] = 0
            if build_graph.ops[node.type] == "AND" and num_needed_satisfiers[node_name] == 0 then
                reachable[node_name] = true
                table.insert(sorted, node)
                in_open[node_name] = true
                table.insert(open, node)
            end
        end
    -- Check if there was a new connection
    -- This shouldn't change reachability, but could change blacklistedness
    -- TODO: It actually does change reachability with the new item algorithm!
    else
        -- New node at end of new_conn
        local dependent = new_conn[2]
        local dependent_key = build_graph.key(dependent.type, dependent.name)
        local dependent_node = graph[dependent_key]

        -- Check if the new node is now reachable without blacklist, and if so add it to open nodes
        num_blacklisted_prereqs[dependent_key] = num_blacklisted_prereqs[dependent_key] - 1
        if reachable[dependent_key] then
            if build_graph.ops[dependent_node.type] == "AND" then
                if num_blacklisted_prereqs[dependent_key] == 0 then
                    table.insert(open, dependent_node)
                    in_open[dependent_key] = true
                end
            -- For OR's we need to have just un-blacklisted a prereq for the *first* time
            elseif build_graph.ops[dependent_node.type] == "OR" then
                if not in_open[dependent_key] then
                    table.insert(open, dependent_node)
                    in_open[dependent_key] = true
                end
            else
                -- I misspelled something
                error()
            end
        end
    end

    while curr_ind <= #open do
        local curr_node = open[curr_ind]
        local curr_key = build_graph.key(curr_node.type, curr_node.name)

        for _, dependent in pairs(curr_node.dependents) do
            local dependent_key = build_graph.key(dependent.type, dependent.name)
            local dependent_node = graph[dependent_key]

            -- Allow blacklisted to be reachable and in top sort, but not in open nodes
            local is_blacklisted = blacklist[build_graph.compound_key({curr_key, dependent_key})]

            num_satisfiers[dependent_key] = num_satisfiers[dependent_key] + 1
            if is_blacklisted then
                num_blacklisted_prereqs[dependent_key] = num_blacklisted_prereqs[dependent_key] + 1
            end

            if build_graph.ops[dependent_node.type] == "AND" then
                if num_satisfiers[dependent_key] == num_needed_satisfiers[dependent_key] then
                    if not reachable[dependent_key] then
                        reachable[dependent_key] = true
                        table.insert(sorted, dependent_node)
                    end
                    -- Check that no connections were blacklisted ones
                    if num_blacklisted_prereqs[dependent_key] == 0 then
                        in_open[dependent_key] = true
                        table.insert(open, dependent_node)
                    end
                end
            elseif build_graph.ops[dependent_node.type] == "OR" then
                -- Check if it's already been added
                if not reachable[dependent_key] then
                    reachable[dependent_key] = true
                    table.insert(sorted, dependent_node)
                    -- Just need to check that this connection was not a blacklisted one in this case
                    if not is_blacklisted then
                        in_open[dependent_key] = true
                        table.insert(open, dependent_node)
                    end
                end
            else
                -- I misspelled something
                error()
            end
        end

        curr_ind = curr_ind + 1
    end

    return {in_open = in_open, open = open, reachable = reachable, sorted = sorted, num_satisfiers = num_satisfiers, num_needed_satisfiers = num_needed_satisfiers, num_blacklisted_prereqs = num_blacklisted_prereqs, curr_ind = curr_ind}
end

return top_sort