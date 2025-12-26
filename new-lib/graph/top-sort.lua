-- A topological sort with context
-- I realized midway through that contexts will rarely be all true so a lot of the optimizations don't do much; this is because we won't have all planets reachable right away
-- However, there are times when we'll be able to get context to any nodes that we can reach, like transportable items, so that could be a future optimization
-- This could be done by testing which nodes are "surface agnostic" at any point, i.e.- if we could reach all planets, then they would transmit all contexts
-- For this, we'd need to transmit contexts regardless of reachability and keep that a separate concept

local lib_name = "new-lib" -- Use this until integration with "old" lib
local gutils = require(lib_name .. "/graph/graph-utils")
-- Used for gathering contexts, etc. not for the actual graph
local logic = require(lib_name .. "/logic/logic")

local key = gutils.key

local top = {}

-- We'll just do basic top sort without blacklists or state saving for now
-- Okay, now we have state saving
-- new_conn should carry edge AND new contexts (contexts from old node)
top.sort = function(graph, state, new_conn, extra)
    state = state or {}
    -- node_to_contexts goes node_key --> { context_name --> true/false }
    -- There is also special case of node_key --> false (no contexts/unreachable) and node_key --> true (all contexts) for performance
    local node_to_contexts = state.node_to_contexts or {}
    -- Counters for efficiently determining how many prereqs of a node have a given context
    -- To determine number that need that context, we'll just call a helper function for number of edges into a node
    local node_context_to_satisfied = state.node_context_to_satisfied or {}
    local open = state.open or {}
    local in_open = state.in_open or {}
    local node_to_open_inds = state.node_to_open_inds or {}
    -- Keep track of reachable CONTEXTS (not nodes)
    --local reachable = state.reachable or {}

    local function add_contexts_to_node(node, contexts)
        --[[if contexts ~= true then
            for context, _ in pairs(contexts) do
                if not logic.contexts[context] then
                    log(serpent.block(contexts))
                    log(serpent.block(node))
                    error()
                end
            end
        end]]
        -- incoming is used for seeing what the transmitted in context was in path
        local incoming = contexts
        if type(incoming) == "table" then
            incoming = table.deepcopy(incoming)
        end

        -- Check if contexts is overriden
        if logic.type_info[node.type].context == true then
            contexts = true
        elseif type(logic.type_info[node.type].context) == "string" then
            -- Due to an oopsie where I made type info just nauvis for rooms, we need to just get the room key if it's a room
            contexts = {
                [node.name] = true
            }
        end

        --[[if node.type == "room" then
            log(serpent.block(node))
            log(serpent.block(contexts))
            log(serpent.block(logic.type_info["room"]))
        end]]

        if node.op == "AND" then
            -- We always go to open with AND nodes
            -- TODO: Add to current node in_open for AND nodes (will require keeping track of number times each context added)
            -- We also need to check for updates from this node again...
            table.insert(open, {
                node = key(node),
                contexts = contexts,
                incoming = incoming,
            })
            -- in_open doesn't really matter
            -- Other things should be updated
        elseif node.op == "OR" then
            -- If it's already true, no change needed
            local open_ind = in_open[key(node)]
            if open_ind ~= nil then
                -- If it's already true then no change needed
                if open[open_ind].contexts ~= true then
                    if contexts == true then
                        open[open_ind].contexts = true
                    else
                        for context, _ in pairs(contexts) do
                            open[open_ind].contexts[context] = true
                        end
                    end
                end
            else
                table.insert(open, {
                    node = key(node),
                    contexts = contexts,
                    incoming = incoming,
                })
                in_open[key(node)] = #open
            end
        end
    
        --[=[node_to_contexts[key(curr_node)] = true
        -- Transmit context(s) to deps
        for _, dep in pairs(curr_node.dep) do
            -- First test if edge already in open and if so add to its contexts for efficiency
            if in_open[dep] ~= nil and not edge_to_contexts[context] then
                open[in_open[dep]].new_contexts[context] = true
            elseif not edge_to_contexts[context] then
                -- Only add to sorted if it's not already in open
                table.insert(sorted, curr_node)
                in_open[dep] = true
                table.insert(open, {
                    edge = dep,
                    new_contexts = {
                        context = true,
                    }
                })
            end
        end]=]
    end

    local function process_edge(dep, open_info, old_contexts)
        local edge = graph.edges[dep]
        -- Check if the dependent already has all contexts for efficiency
        if node_to_contexts[edge.stop] ~= true then
            local end_node_key = edge.stop
            local end_node = graph.nodes[end_node_key]

            -- TODO: This table population would probably be more efficient in a general node loop
            node_to_contexts[end_node_key] = node_to_contexts[end_node_key] or {}

            -- TODO: If end_node has one prereq, we treat it specially for efficiency
            if end_node.op == "AND" then
                if node_to_contexts[open_info.node] == true then
                    -- If we now carry all contexts, remove single contexts and add to all
                    node_context_to_satisfied[end_node_key] = node_context_to_satisfied[end_node_key] or {}
                    node_context_to_satisfied[end_node_key]["all"] = (node_context_to_satisfied[end_node_key]["all"] or 0) + 1
                    for old_context, _ in pairs(old_contexts) do
                        node_context_to_satisfied[end_node_key][old_context] = node_context_to_satisfied[end_node_key][old_context] - 1
                    end
                else
                    -- Otherwise, just add to contexts
                    node_context_to_satisfied[end_node_key] = node_context_to_satisfied[end_node_key] or {}
                    for context, _ in pairs(open_info.contexts) do
                        node_context_to_satisfied[end_node_key][context] = (node_context_to_satisfied[end_node_key][context] or 0) + 1
                    end
                end

                -- Check if we've satisfied a new context
                local new_contexts = {}
                if open_info.contexts == true then
                    -- If "all", check all contexts
                    local add_all_contexts = true
                    for context, _ in pairs(logic.contexts) do
                        if not node_to_contexts[end_node_key][context] then
                            if (node_context_to_satisfied[end_node_key][context] or 0) + (node_context_to_satisfied[end_node_key]["all"] or 0) == end_node.num_pre then
                                new_contexts[context] = true
                            else
                                add_all_contexts = false
                            end
                        end
                    end
                else
                    for context, _ in pairs(open_info.contexts) do
                        -- The next check is probably redundant here
                        if not node_to_contexts[end_node_key][context] then
                            if (node_context_to_satisfied[end_node_key][context] or 0) + (node_context_to_satisfied[end_node_key]["all"] or 0) == end_node.num_pre then
                                new_contexts[context] = true
                            end
                        end
                    end
                end

                if next(new_contexts) ~= nil then
                    if add_all_contexts then
                        add_contexts_to_node(end_node, true)
                    else
                        add_contexts_to_node(end_node, new_contexts)
                    end
                end
            -- For OR nodes, add contexts right away?
            -- Nah, but we can treat one-indegree nodes as OR
            elseif end_node.op == "OR" then
                local new_contexts = {}
                if node_to_contexts[open_info.node] == true then
                    new_contexts = true
                else
                    for context, _ in pairs(open_info.contexts) do
                        if not node_to_contexts[end_node_key][context] then
                            new_contexts[context] = true
                        end
                    end
                end
                if new_contexts == true or next(new_contexts) ~= nil then
                    add_contexts_to_node(end_node, new_contexts)
                end
            else
                error("Node op not OR or AND")
            end
        end
    end

    -- sorted ignores nodes until they get a reachable context
    --[[local sorted = {}
    local deferred = {}
    for context, _ in pairs(logic.contexts) do
        deferred[context] = {}
    end]]
    if new_conn == nil then
        -- Add sources
        for source, _ in pairs(graph.sources) do
            -- These are added later!
            --node_to_contexts[source] = true
            --node_context_to_satisfied[source] = true
            table.insert(open, {
                node = source,
                contexts = true,
                incoming = true,
            })
            in_open[source] = #open
        end
    else
        --local stop = graph.edges[new_conn.edge].stop
        -- Don't process if node already has all contexts
        if node_to_contexts[stop] ~= true then
            process_edge(new_conn.edge, {
                node = graph.edges[new_conn.edge].start,
                contexts = new_conn.contexts,
            }, {}) -- Last table shows old contexts was nothing (no connection)
        end
    end
    -- Nodes that emit context regardless of reachability
    -- I realized this doesn't work; emitting regardless could still cause issues
    -- Let's see if it's actually slow first before more optimization
    --[[for emitter, context in pairs(graph.emitters) do
        local contexts
        if context == true then
            contexts = true
            -- Actually, we only want to emit from context sources
        else
            contexts = {context = true}
            table.insert(open, {
                node = emitter,
                contexts = contexts,
            })
            in_open[emitter] = #open
        end
    end]]
    --[[for node_key, _ in pairs(graph.nodes) do
        node_to_contexts[node_key] = false
        node_context_to_satisfied[node_key] = {}
        for context, _ in pairs(logic.contexts) do
            node_context_to_satisfied[node_key][context] = 0
        end
    end]]
    --[[for edge_key, _ in pairs(graph.edges) do
        edge_to_contexts[edge_key] = false
    end]]

    --[[local open = {}
    -- edge to its index in open, if any
    local in_open = {}]]

    -- graph.nodes will be iteration over nodes (since the graph has a lot in it now at top level, includes edges
    -- Get sources
    --[[for _, node in pairs(graph.nodes) do
        -- New: Store ops in nodes
        if node.op == "AND" and #node.pre == 0 then
            -- Since no prereqs, node is receiving all contexts (handled specially with "true", when normally contexts_to_push would get table)
            -- contexts_to_push reads node's context type and returns the types that it pushes (either identity function, constant function on a single context, or constant function on "true"/all contexts)
            -- (But need to check that passed in context isn't none/false in all cases)
            local contexts = contexts_to_push(node, true)
            -- Iterate over outgoing edges to add these contexts to those edges
            -- node.dep iterates over edge keys
            for dep, _ in pairs(node.dep) do
                -- A function that should merge contexts with current ones, taking special false/true cases into consideration for performance
                add_contexts(edge_to_contexts[dep], contexts)
                -- Sorted now carries edges with the new contexts to be updated on their end nodes
                table.insert(sorted, {
                    edge = dep,
                    new_contexts = contexts,
                })
            end
        end
    end]]

    -- Nodes in order that they got context added; includes duplicates so that we can see when they were reached again with new context
    --local sorted = {}

    local ind = state.ind or 1
    while ind <= #open do
        local open_info = open[ind]
        local node = graph.nodes[open_info.node]
        -- Remove node from open so it doesn't get added to
        -- Only used for OR nodes now
        in_open[open_info.node] = nil
        node_to_open_inds[open_info.node] = node_to_open_inds[open_info.node] or {}
        node_to_open_inds[open_info.node][ind] = true

        -- If old contexts is somehow already everything?? then we don't need to do anything (how is this happening?)
        if node_to_contexts[open_info.node] ~= true then
            -- Add new contexts
            local old_contexts = table.deepcopy(node_to_contexts[open_info.node] or {})
            if open_info.contexts == true then
                node_to_contexts[open_info.node] = true
            else
                node_to_contexts[open_info.node] = node_to_contexts[open_info.node] or {}
                for context, _ in pairs(open_info.contexts) do
                    node_to_contexts[open_info.node][context] = true
                end
                -- Check if we now carry all contexts
                local has_all = true
                for context, _ in pairs(logic.contexts) do
                    if not node_to_contexts[open_info.node][context] then
                        has_all = false
                    end
                end
                if has_all then
                    node_to_contexts[open_info.node] = true
                end
            end

            --[[local is_reachable = false
            if node_to_contexts[open_info.node] == true then
                is_reachable = true
            else
                for context, _ in pairs(reachable) do
                    if node_to_contexts[open_info.node][context] then
                        is_reachable = false
                    end
                end
            end
            if is_reachable then
                -- TODO: I don't need to do this since I'm not emitting from all sources yet
            end]]

            -- Evaluate reachability if this is a room node
            -- O(num_contexts^2) total cost, which is like, 36
            --[[if node.type == "room" then
                if not reachable[open_info.node] then
                    if node_to_contexts[open_info.node] == true then
                        reachable[open_info.node] = true
                    else
                        for context, _ in pairs(node_to_contexts[open_info.node]) do
                            -- Context should be same format as room node key
                            if reachable[context] then
                                -- Now this context is reachable
                                reachable[open_info.node] = true
                            end
                        end
                    end
                    if reachable[open_info.node] then
                        -- Check if any other room nodes have become reachable
                        -- This theoretically could unlock more contexts and so on, thus the outer loop
                        while true do
                            local add_context = false
                            for context, _ in pairs(logic.contexts) do
                                if not reachable[context] then
                                    if node_to_contexts[context] == true or (node_to_contexts[context] or {})[open_info.node] then
                                        reachable[context] = true
                                        add_context = true
                                    end
                                end
                            end
                            if not add_context then
                                break
                            end
                        end
                    end
                end
            end]]

            -- Check deps here and decide if any needs to be added to open
            for dep, _ in pairs(node.dep) do
                process_edge(dep, open_info, old_contexts)
            end
        end
        
        ind = ind + 1
    end

    return {
        node_to_contexts = node_to_contexts,
        node_context_to_satisfied = node_context_to_satisfied,
        open = open,
        in_open = in_open,
        node_to_open_inds = node_to_open_inds,
        ind = ind,
    }
        
        -- Check if all contexts already added for efficiency
        --[[if node_to_contexts[key(curr_node)] ~= true then
            -- get_contexts accounts for special cases like true/false meaning all/none
            -- TODO: Also add efficient testing for if new_contexts == true (like for OR nodes, just setting their contexts to true right away)
            -- TODO: For AND nodes, we could track edges with true
            local new_contexts = {}
            for _, context in pairs(get_contexts(open_info.new_contexts)) do
                -- Check if context already added to node
                if not node_to_contexts[context] then
                    -- Increase number of incoming edges to node with this context
                    local node_context_amounts = node_context_to_satisfied[key(curr_node)]
                    node_context_amounts[context] = node_context_amounts[context] + 1

                    if curr_node.op == "AND" then
                        -- Check if all incoming edges now have this context
                        if node_context_amounts[context] == #curr_node.pre then
                            add_context_to_node(curr_node, context)
                        end
                    elseif curr_node.op == "OR" then
                        -- Just add context to node; any new context is enough
                        add_context_to_node(curr_node, context)
                    end
                end
            end
        end

        ind = ind + 1
    end

    local reachable = {}
    -- Nodes with at least one context are counted as reachable
    for node_key, contexts in pairs(node_to_contexts) do
        for _, has_context in pairs(contexts) do
            if has_context then
                reachable[node_key] = true
                break
            end
        end
    end

    return {
        sorted = open,
        reachable = reachable,
    }]]
end

top.path = function(graph, goal, sort)
    local contexts_in_order = {
        key({type = "planet", name = "nauvis"}),
        key({type = "surface", name = "space-platform"}),
        key({type = "planet", name = "vulcanus"}),
        key({type = "planet", name = "fulgora"}),
        key({type = "planet", name = "gleba"}),
        key({type = "planet", name = "aquilo"}),
    }

    local open = sort.open
    local node_to_open_inds = sort.node_to_open_inds

    -- Path is a collection of inds from open, paired with contexts we are wanting from them
    -- goal itself is an ind with a context
    -- Note that path works backwards
    local path = {goal}
    -- ind + context to whether it's in the path yet (note that we need both)
    local in_path = {}
    for context, _ in pairs(logic.contexts) do
        in_path[context] = {}
    end

    local ind = 1
    while ind <= #path do
        local curr_goal = path[ind]

        local curr_open = open[curr_goal.ind]
        local goal_context = curr_goal.context
        local curr_node = graph.nodes[curr_open.node]
        -- Try to get this context as early as possible
        -- If this is a context emitter, then choose earliest possible context
        local earlier_emitter = false
        if logic.type_info[curr_node.type].context ~= nil then
            local earliest_ind
            for open_ind, _ in pairs(node_to_open_inds[curr_open.node]) do
                if earliest_ind == nil or open_ind < earliest_ind then
                    earliest_ind = open_ind
                end
            end
            -- Decide new goal context based off earliest available context in order
            for _, available_context in pairs(contexts_in_order) do
                if curr_open.incoming == true or curr_open.incoming[available_context] then
                    goal_context = available_context
                    break
                end
            end
            -- If we got an earlier node, push it and continue
            if earliest_ind < curr_goal.ind then
                earlier_emitter = true
                if not in_path[goal_context][earliest_ind] then
                    table.insert(path, {
                        ind = earliest_ind,
                        context = goal_context,
                    })
                    in_path[goal_context][earliest_ind] = true
                end
            end
        end
        if not earlier_emitter then
            if curr_node.op == "AND" then
                -- Add each of the prereq node's contexts
                for pre, _ in pairs(curr_node.pre) do
                    local prenode = graph.nodes[graph.edges[pre].start]
                    -- Get first occurrence with this context
                    local first_occurrence
                    for open_ind, _ in pairs(node_to_open_inds[key(prenode)]) do
                        local occurrence_contexts = open[open_ind].contexts
                        if occurrence_contexts == true or occurrence_contexts[goal_context] then
                            if first_occurrence == nil or open_ind < first_occurrence then
                                first_occurrence = open_ind
                            end
                        end
                    end
                    -- Add this occurrence
                    if not in_path[goal_context][first_occurrence] then
                        table.insert(path, {
                            ind = first_occurrence,
                            context = goal_context,
                        })
                        in_path[goal_context][first_occurrence] = true
                    end
                end
            elseif curr_node.op == "OR" then
                -- Find earliest prereq with this context
                local first_occurrence
                for pre, _ in pairs(curr_node.pre) do
                    local prenode = graph.nodes[graph.edges[pre].start]
                    for open_ind, _ in pairs(node_to_open_inds[key(prenode)] or {}) do
                        local occurrence_contexts = open[open_ind].contexts
                        if occurrence_contexts == true or occurrence_contexts[goal_context] then
                            if first_occurrence == nil or open_ind < first_occurrence then
                                first_occurrence = open_ind
                            end
                        end
                    end
                end
                if first_occurrence == nil then
                    log(serpent.block(curr_open))
                    log(goal_context)
                    log(serpent.block(curr_node))
                end
                if not in_path[goal_context][first_occurrence] then
                    table.insert(path, {
                        ind = first_occurrence,
                        context = goal_context,
                    })
                    in_path[goal_context][first_occurrence] = true
                end
            end
        end

        ind = ind + 1
    end

    return path
end

return top