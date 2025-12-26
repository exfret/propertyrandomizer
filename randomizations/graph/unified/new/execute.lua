local rng = require("lib/random/rng")
local gutils = require("new-lib/graph/graph-utils")
local top = require("new-lib/graph/top-sort")
local logic = require("new-lib/logic/logic")

local unified = {}

local handler_ids = {
    "tech-prereqs"
}

unified.execute = function()
    -- Load handlers
    local default_handler = require("randomizations/graph/unified/new/handlers/default")
    local handlers = {}
    for _, handler_id in pairs(handler_ids) do
        local handler = require("randomizations/graph/unified/new/handlers/" .. handler_id)

        for prop, val in pairs(default_handler) do
            if handler[prop] == nil then
                if default_handler.required[prop] then
                    error("Required property " .. prop .. " missing from handler " .. handler_id)
                else
                    handler[prop] = val
                end
            end
        end

        handlers[handler_id] = handler
    end

    ----------------------------------------------------------------------------------------------------
    -- GRAPH PREP
    ----------------------------------------------------------------------------------------------------

    -- data.raw preprocessing if necessary
    for _, handler in pairs(handlers) do
        handler.preprocess()
    end

    -- Lookup loading is done by logic building, so not necessary here

    -- Logic building
    logic.build()
    local graph = logic.graph

    -- Spoofing
    for _, handler in pairs(handlers) do
        handler.spoof(graph)
    end

    ----------------------------------------------------------------------------------------------------
    -- EDGE GATHERING
    ----------------------------------------------------------------------------------------------------

    -- Subdivide edges into slots and travelers (but don't disrupt connections yet
    local subdiv_graph = graph
    -- Deepcopy the old version so that references don't become dead
    graph = table.deepcopy(graph)
    local trav_to_old_slot = {}
    local pre_to_subdivide = {}
    for _, node in pairs(subdiv_graph.nodes) do
        for pre,  _ in pairs(node.pre) do
            table.insert(pre_to_subdivide, pre)
        end
    end
    for _, pre in pairs(pre_to_subdivide) do
        local conn = gutils.subdivide(subdiv_graph, pre)
        trav_to_old_slot[gutils.key(conn.traveler)] = conn.slot
    end

    -- We'll also be cutting the slot-traveler connections later
    local cut_graph = subdiv_graph
    subdiv_graph = table.deepcopy(subdiv_graph)

    -- Initial top sort
    local init_sort = top.sort(cut_graph)

    -- Find critical nodes; put those first
    -- Let promethium science be hardcoded as the win condition for the vanilla sort
    local promethium_inds = init_sort.node_to_open_inds[gutils.key({type = "item", name = "promethium-science-pack"})]
    local earliest_ind
    for ind, _ in pairs(promethium_inds) do
        if earliest_ind == nil or ind < earliest_ind then
            earliest_ind = ind
        end
    end
    local path = top.path(cut_graph, { ind = earliest_ind, context = gutils.key({type = "surface", name = "space-platform"}) }, init_sort)
    local in_path = {}
    for _, path_info in pairs(path) do
        in_path[path_info.ind] = true
    end
    local priority_open = {}
    local unimportant_open = {}
    for open_ind, open_info in pairs(init_sort.open) do
        if in_path[open_ind] then
            table.insert(priority_open, open_info)
        else
            table.insert(unimportant_open, open_info)
        end
    end
    local open_sorted = {}
    for _, open_info in pairs(priority_open) do
        table.insert(open_sorted, open_info)
    end
    for _, open_info in pairs(unimportant_open) do
        table.insert(open_sorted, open_info)
    end
    -- CRITICAL TODO: Decide whether I actually want to keep the critical path stuff; the following line actually undoes it
    open_sorted = init_sort.open

    -- Now for the actual gathering
    local added_to_deps = {}
    local sorted_deps = {}
    local shuffled_prereqs = {}
    local post_shuffled_prereqs = {}
    -- For AND's, gather all their travelers and do in order
    -- This will need to be more simultaneous for recipe rando, but helps skirt issues with multi-type AND prereqs for now
    local trav_to_handler = {}
    local node_to_random_travs = {}
    for open_ind, open_info in pairs(open_sorted) do
        local node_key = open_info.node
        local node = cut_graph.nodes[node_key]

        -- Do OR node's corresponding travelers, and the AND nodes themselves
        if node.type ~= "slot" and ((node.type ~= "traveler" and node.op == "AND") or (node.type == "traveler" and gutils.get_conn_owner(cut_graph, node).op == "OR")) then
            if not added_to_deps[gutils.key(node)] then
                node_to_random_travs[gutils.key(node)] = {}

                local edges_to_remove = {}
                for pre, _ in pairs(node.pre) do
                    local corresponding_trav
                    if node.type == "traveler" then
                        corresponding_trav = node
                    else
                        corresponding_trav = cut_graph.nodes[cut_graph.edges[pre].start]
                    end
                    -- Go traveler --> slot, then slot --> prereq node
                    local start_node = gutils.get_conn_owner(cut_graph, gutils.get_conn_buddy(cut_graph, corresponding_trav))
                    -- If this is a traveler, need to get ending node to judge connection
                    local end_node = node
                    if node.type == "traveler" then
                        end_node = gutils.get_conn_owner(cut_graph, node)
                    end

                    local claimed = false
                    for _, handler in pairs(handlers) do
                        -- Pass corresponding_trav in since it holds the edge's extra_info
                        -- num_copies says how many extra times the prereq should be added to the pool for flexibility
                        local num_copies = handler.claim(cut_graph, start_node, end_node, corresponding_trav) or 0
                        if num_copies > 0 then
                            if claimed then
                                error("Multiple handlers claiming the same edge")
                            end
                            claimed = true
                            table.insert(node_to_random_travs[gutils.key(node)], corresponding_trav)
                            trav_to_handler[gutils.key(corresponding_trav)] = handler
                            -- Add the slot to prereqs
                            table.insert(shuffled_prereqs, gutils.get_conn_buddy(cut_graph, corresponding_trav))
                            for i = 2, num_copies do
                                table.insert(post_shuffled_prereqs, gutils.get_conn_buddy(cut_graph, corresponding_trav))
                            end
                        end
                    end

                    if claimed then
                        -- Mark the slot-traveler edges for deletion
                        local slot_traveler_edge
                        for pre, _ in pairs(corresponding_trav.pre) do
                            slot_traveler_edge = pre
                            break
                        end
                        table.insert(edges_to_remove, slot_traveler_edge)
                    end
                end

                for _, edge_key in pairs(edges_to_remove) do
                    gutils.remove_edge(cut_graph, edge_key)
                end
                -- Add everything to dependents (most of them just won't do anything but it's fine)
                added_to_deps[gutils.key(node)] = true
                table.insert(sorted_deps, node)
            end
        end
    end

    ----------------------------------------------------------------------------------------------------
    -- Filling Pools
    ----------------------------------------------------------------------------------------------------

    -- Since we use cut_graph later, we can't do the usual deepcopy
    -- So note: Our references from sorted_deps and such at this point are DEAD, they point to cut_graph
    -- This shouldn't cause issues here hopefully
    local pool_graph = table.deepcopy(cut_graph)
    local pool_info = top.sort(pool_graph)

    local trav_to_pool = {}
    for _, dep in pairs(sorted_deps) do
        local function reconnect(traveler)
            local edge_start = trav_to_old_slot[gutils.key(traveler)]
            local edge = gutils.add_edge(pool_graph, gutils.key(edge_start), gutils.key(traveler))
            pool_info = top.sort(pool_graph, pool_info, {
                edge = gutils.ekey(edge),
                contexts = pool_info.node_to_contexts[edge.start],
            })
        end

        for _, trav in pairs(node_to_random_travs[gutils.key(dep)]) do
            reconnect(trav)
        end
    end
    -- Let's still test pools via index in each context list
    -- Later, we could try with context pools

    -- Takes context and node to when the node first gets that context in open
    -- Might be able to add this to sort info
    -- This could still not catch things that only add an item to a surface where it's not needed but checking more rigorously could be a future task
    local context_node_to_ind = {}
    for context, _ in pairs(logic.contexts) do
        context_node_to_ind[context] = {}
    end
    for open_ind, node_info in pairs(pool_info.open) do
        if node_info.contexts == true then
            for context, _ in pairs(logic.contexts) do
                context_node_to_ind[context][node_info.node] = context_node_to_ind[context][node_info.node] or open_ind
            end
        else
            for context, _ in pairs(node_info.contexts) do
                context_node_to_ind[context][node_info.node] = context_node_to_ind[context][node_info.node] or open_ind
            end
        end
    end

    local random_graph = cut_graph
    cut_graph = table.deepcopy(cut_graph)

    log(serpent.block(pool_info.ind_to_ind))

    -- Context reachability
    local function all_contexts_reachable(slot, trav)
        for context, _ in pairs(logic.contexts) do
            -- Let's try with "last prereq comes after"
            -- Trying out a new idea where we ignore things after the last prereq that satisfied something (ind_to_ind)
            -- This actually didn't have an effect because of the way pool sort works
            if (pool_info.ind_to_ind[context_node_to_ind[context][gutils.key(trav)]] or (#pool_info.open + 2)) < (context_node_to_ind[context][gutils.key(slot)] or (#pool_info.open + 1)) then
                return false
            end
        end

        return true
    end

    ----------------------------------------------------------------------------------------------------
    -- Do The Shuffle
    ----------------------------------------------------------------------------------------------------

    rng.shuffle(rng.key({id = "unified"}), shuffled_prereqs)
    rng.shuffle(rng.key({id = "unified"}), post_shuffled_prereqs)
    for _, prereq in pairs(post_shuffled_prereqs) do
        table.insert(shuffled_prereqs, prereq)
    end

    -- Note that we don't technically need to go in dependent order anymore
    local used_prereq_indices = {}
    -- We actually should keep dep-prereq map since some prereqs are there multiple times
    -- Thus, the graph alone would look weird as a way of representing things
    local trav_to_new_slot = {}
    for _, dep in pairs(sorted_deps) do
        if #node_to_random_travs[gutils.key(dep)] > 0 then
            log("Randomizing " .. gutils.key(dep))
            for _, trav in pairs(node_to_random_travs[gutils.key(dep)]) do
                local found_prereq = false
                for ind, slot in pairs(shuffled_prereqs) do
                    if not used_prereq_indices[ind] and all_contexts_reachable(slot, trav) then
                        -- Have traveler's handler validate this ind
                        if trav_to_handler[gutils.key(trav)].validate(random_graph, slot, trav, {
                            init_sort = init_sort, -- Needed for tech rando
                        }) then
                            log("Accepted prereq " .. gutils.key(gutils.get_conn_owner(cut_graph, slot)))
                            found_prereq = true
                            used_prereq_indices[ind] = true
                            trav_to_new_slot[gutils.key(trav)] = slot

                            -- No need to update graph since we already know prereq pools
                            break
                        end
                    end
                end
                if not found_prereq then
                    error()
                end
            end
        end
    end

    ----------------------------------------------------------------------------------------------------
    -- Reflection
    ----------------------------------------------------------------------------------------------------

    for _, handler in pairs(handlers) do
        handler.reflect(random_graph, trav_to_new_slot)
    end
end

return unified