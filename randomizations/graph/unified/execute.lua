-- CRITICAL TODO: Turn back on when things are working with this off (one step at a time)
local PRESERVE_ISOLATABILITY = false
-- First pass is broken now; I need to figure out what's wrong and fix it later
local CONDUCT_FIRST_PASS = false
-- Ad hoc attempt for grouping; put tech unlock with recipe
local COMBINE_TECH_UNLOCK_RECIPE = false
-- Second perhaps better try at tech unlock coupling; modify graph so that recipe --> unlock-recipe-technology (AND over recipe and a single tech) --> recipe-fina
-- This also doesn't work actually, but not for awful reasons; I'll just need to be more careful about how I do this
local COMBINE_TECH_UNLOCK_RECIPE_TWO = false
local SWITCH_TO_PLANET = false

local rng = require("lib/random/rng")
local gutils = require("new-lib/graph/graph-utils")
local top = require("new-lib/graph/top-sort")
local top2 = require("new-lib/graph/extended-sort")
local logic = require("new-lib/logic/init")
local first_pass = require("randomizations/graph/unified/first-pass")
local test_graph_invariants = require("tests/graph-invariants")

local unified = {}

local handler_ids = {
    --"recipe-category",
    --"recipe-ingredients",
    --"tech-prereqs",
    --"recipe-tech-unlocks",
    --"tech-unlocks",
    --"spoiling",
    --"tech-science-packs",
    "entity-operation-fluid",
}

unified.execute = function()
    -- CRITICAL TODO: Fix up to be base game compatible before release
    if not mods["space-age"] then
        error("exfret, you forgot to enable Space Age you doofus.")
    end

    -- Load handlers
    local default_handler = require("randomizations/graph/unified/handlers/default")
    local handlers = {}
    for _, handler_id in pairs(handler_ids) do
        local handler = require("randomizations/graph/unified/handlers/" .. handler_id)

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

    test_graph_invariants.test(logic.graph)

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
    local old_graph = table.deepcopy(logic.graph)
    local graph = logic.graph

    -- Change structure to couple tech unlocks with recipes
    if COMBINE_TECH_UNLOCK_RECIPE_TWO then
        local old_tech_unlock = {}
        logic.type_info["recipe-tech-unlock"].op = "AND"
        for _, node in pairs(graph.nodes) do
            if node.type == "recipe" and data.raw.recipe[node.name].enabled == false then
                local edges_to_remove = {}
                local recipe_final_node = gutils.add_node(graph, "logic-or", "recipe-final-" .. node.name)
                recipe_final_node.op = "OR"
                for pre, _ in pairs(node.pre) do
                    local prenode = graph.nodes[graph.edges[pre].start]
                    if prenode.type == "recipe-tech-unlock" then
                        old_tech_unlock[gutils.key(prenode)] = true
                        -- TODO: Some more basic graph navigation would be great
                        local prenode_tech = graph.nodes[graph.edges[next(prenode.pre)].start]
                        table.insert(edges_to_remove, pre)
                        -- TODO: I should probably use a compound key rather than normal key here
                        local unlock_recipe_tech_node = gutils.add_node(graph, "recipe-tech-unlock", gutils.key(node.name, prenode_tech.name))
                        unlock_recipe_tech_node.op = "AND"
                        gutils.add_edge(graph, gutils.key(node), gutils.key(unlock_recipe_tech_node))
                        gutils.add_edge(graph, gutils.key(prenode_tech), gutils.key(unlock_recipe_tech_node))
                        gutils.add_edge(graph, gutils.key(unlock_recipe_tech_node), gutils.key(recipe_final_node))
                    end
                end
                for dep, _ in pairs(node.dep) do
                    -- Filter out the node we just added to recipe-tech-unlock
                    local stop_node_key = graph.edges[dep].stop
                    if graph.nodes[stop_node_key].type ~= "recipe-tech-unlock" then
                        -- deps transferred to recipe-final
                        gutils.add_edge(graph, gutils.key(recipe_final_node), stop_node_key)
                        table.insert(edges_to_remove, dep)
                    end
                end
                for _, edge_key in pairs(edges_to_remove) do
                    gutils.remove_edge(graph, edge_key)
                end
            end
        end
    end

    -- Spoofing
    for _, handler in pairs(handlers) do
        handler.spoof(graph)
    end

    test_graph_invariants.test(graph)

    ----------------------------------------------------------------------------------------------------
    -- Subdivision and Path finding
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

    local path_graph = table.deepcopy(old_graph)
    local pre_to_subdivide_2 = {}
    for _, node in pairs(path_graph.nodes) do
        for pre,  _ in pairs(node.pre) do
            table.insert(pre_to_subdivide_2, pre)
        end
    end
    for _, pre in pairs(pre_to_subdivide_2) do
        gutils.subdivide(path_graph, pre)
    end

    local subdiv_sort = top.sort(path_graph)
    -- Path to promethium science item
    local prom_science = path_graph.nodes[gutils.key("item", "promethium-science-pack")]
    local path_goal
    for open_ind, open_info in pairs(subdiv_sort.open) do
        if open_info.node == gutils.key(prom_science) then
            path_goal = {
                ind = open_ind,
                context = gutils.key("surface", "space-platform"),
            }
            break
        end
    end
    local short_path_info = top.path(path_graph, path_goal, subdiv_sort)
    -- Get nodes that appear at all (with any context)
    local short_path = {}
    for _, open_info in pairs(short_path_info) do
        short_path[subdiv_sort.open[open_info.ind].node] = true
    end

    test_graph_invariants.test(subdiv_graph)

    ----------------------------------------------------------------------------------------------------
    -- Claiming
    ----------------------------------------------------------------------------------------------------

    -- We'll also be cutting the slot-traveler connections later
    local cut_graph = subdiv_graph
    subdiv_graph = table.deepcopy(subdiv_graph)
    -- Don't ever update this one for new planet
    old_subdiv_graph = table.deepcopy(subdiv_graph)

    -- Initial top sort
    local init_sort = top.sort(cut_graph)

    -- Find critical nodes; put those first
    -- Let promethium science be hardcoded as the win condition for the vanilla sort
    --[[local promethium_inds = init_sort.node_to_open_inds[gutils.key({type = "item", name = "promethium-science-pack"})]
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
    end]]
    -- CRITICAL TODO: Decide whether I actually want to keep the critical path stuff; the following line actually undoes it
    -- Note: This is different from the critical path stuff used for the first pass sort
    open_sorted = init_sort.open

    -- TODO: Dunno if I actually will use this I thought of another idea halfway through
    local graph_with_cuts = table.deepcopy(cut_graph)
    -- Initially empty
    local graph_with_cuts_edges_to_remove = {}
    for edge_key, _ in pairs(graph_with_cuts.edges) do
        table.insert(graph_with_cuts_edges_to_remove, edge_key)
    end
    for _, edge_key in pairs(graph_with_cuts_edges_to_remove) do
        gutils.remove_edge(graph_with_cuts, edge_key)
    end

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
        -- Tack on a condition that it's not an old tech unlock
        if node.type ~= "slot" and ((node.type ~= "traveler" and node.op == "AND") or (node.type == "traveler" and gutils.get_conn_owner(cut_graph, node).op == "OR" and not (COMBINE_TECH_UNLOCK_RECIPE_TWO and old_tech_unlock[gutils.key(gutils.get_conn_owner(cut_graph, node))]))) then
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
                    local edge = cut_graph.edges[edge_key]
                    gutils.add_edge(graph_with_cuts, edge.start, edge.stop)
                    gutils.remove_edge(cut_graph, edge_key)
                end
                -- Add everything to dependents (most of them just won't do anything but it's fine)
                added_to_deps[gutils.key(node)] = true
                table.insert(sorted_deps, node)
            end
        end
    end

    test_graph_invariants.test(cut_graph)

    ----------------------------------------------------------------------------------------------------
    -- Filling Pools
    ----------------------------------------------------------------------------------------------------

    log("Filling pools")

    -- Since we use cut_graph later, we can't do the usual deepcopy
    -- So note: Our references from sorted_deps and such at this point are DEAD, they point to cut_graph
    -- This shouldn't cause issues here hopefully
    local pool_graph = table.deepcopy(cut_graph)

    local sort_to_use = top.sort
    if PRESERVE_ISOLATABILITY then
        sort_to_use = top2.sort
    end
    local pool_info = sort_to_use(pool_graph)

    for _, dep in pairs(sorted_deps) do
        local function reconnect(traveler)
            local edge_start = trav_to_old_slot[gutils.key(traveler)]
            -- CRITICAL TODO: Need to figure out new abilities context for edge (might not be given by slot or traveler)
            local edge = gutils.add_edge(pool_graph, gutils.key(edge_start), gutils.key(traveler))
            if not PRESERVE_ISOLATABILITY then
                pool_info = sort_to_use(pool_graph, pool_info, {
                    edge = gutils.ekey(edge),
                    contexts = pool_info.node_to_contexts[edge.start],
                })
            else
                pool_info = sort_to_use(pool_graph, pool_info, gutils.ekey(edge))
            end
        end

        for _, trav in pairs(node_to_random_travs[gutils.key(dep)]) do
            reconnect(trav)
        end
    end
    -- Let's still test pools via index in each context list
    -- Later, we could try with context pools

    log("Calculating pools")

    -- Takes context and node to when the node first gets that context in open
    -- Might be able to add this to sort info
    -- This could still not catch things that only add an item to a surface where it's not needed but checking more rigorously could be a future task
    local context_node_to_ind = {}
    if not PRESERVE_ISOLATABILITY then
        local all_contexts = {}
        for context, _ in pairs(logic.contexts) do
            all_contexts[context] = true
            context_node_to_ind[context] = {}
        end
        for open_ind, node_info in pairs(pool_info.open) do
            local contexts_to_use = node_info.contexts
            if contexts_to_use == true then
                contexts_to_use = table.deepcopy(all_contexts)
            end
            for context, _ in pairs(contexts_to_use) do
                context_node_to_ind[context][node_info.node] = context_node_to_ind[context][node_info.node] or open_ind
            end
        end
    else
        for context, _ in pairs(logic.contexts) do
            for _, str_val in pairs({"0", "1"}) do
                context_node_to_ind[context .. str_val] = {}
            end
        end
        for open_ind, node_info in pairs(pool_info.open) do
            if node_info.contexts == true then
                for context, _ in pairs(logic.contexts) do
                    for _, str_val in pairs({"0", "1"}) do
                        context_node_to_ind[context .. str_val][node_info.node] = context_node_to_ind[context .. str_val][node_info.node] or open_ind
                    end
                end
            else
                for context, context_vals in pairs(node_info.contexts) do
                    if context_vals == true then
                        for _, str_val in pairs({"0", "1"}) do
                            context_node_to_ind[context .. str_val][node_info.node] = context_node_to_ind[context .. str_val][node_info.node] or open_ind
                        end
                    else
                        for bin_str, val in pairs(context_vals) do
                            context_node_to_ind[context .. string.sub(bin_str, 1, 1)][node_info.node] = context_node_to_ind[context .. string.sub(bin_str, 1, 1)][node_info.node] or open_ind
                        end
                    end
                end
            end
        end
    end

    local random_graph = cut_graph
    cut_graph = table.deepcopy(cut_graph)

    log("Calculating context reachability")

    -- Context reachability
    local function all_contexts_reachable(slot, trav)
        if not PRESERVE_ISOLATABILITY then
            for context, _ in pairs(logic.contexts) do
                -- Let's try with "last prereq comes after"
                -- Trying out a new idea where we ignore things after the last prereq that satisfied something (ind_to_ind)
                -- This actually didn't have an effect because of the way pool sort works
                if (pool_info.ind_to_ind[context_node_to_ind[context][gutils.key(trav)]] or (#pool_info.open + 2)) < (context_node_to_ind[context][gutils.key(slot)] or (#pool_info.open + 1)) then
                    return false
                end
            end
        else
            for context, _ in pairs(logic.contexts) do
                for _, str_val in pairs({"0", "1"}) do
                    if (context_node_to_ind[context .. str_val][gutils.key(trav)] or (#pool_info.open + 2)) < (context_node_to_ind[context .. str_val][gutils.key(slot)] or (#pool_info.open + 1)) then
                        return false
                    end
                end
            end
        end

        return true
    end

    test_graph_invariants.test(pool_graph)
    test_graph_invariants.test(random_graph)

    ----------------------------------------------------------------------------------------------------
    -- First Pass (if applicable)
    ----------------------------------------------------------------------------------------------------

    if SWITCH_TO_PLANET then
        -- Gleba here we come
        -- Since we're adding this as fixed and we have no randomized room connections yet, we don't need to worry about graph_with_cuts
        for _, graph_var in pairs({graph, pool_graph, pass_graph, cut_graph, random_graph, subdiv_graph}) do
            if graph_var ~= nil then
                -- It's much better algorithmically (and closer to reflection reality) to just switch dependents of gleba and nauvis
                local nauvis_node = graph_var.nodes[gutils.key("room", gutils.key("planet", "nauvis"))]
                local gleba_node = graph_var.nodes[gutils.key("room", gutils.key("planet", "gleba"))]
                local function leads_to_room_launch(node)
                    if node.type == "room-launch" then
                        return true
                    elseif node.type ~= "slot" and node.type ~= "traveler" then
                        return false
                    else
                        local next_edge
                        for dep, _ in pairs(node.dep) do
                            next_edge = graph.edges[dep]
                            break
                        end
                        if next_edge == nil then
                            return false
                        else
                            return leads_to_room_launch(graph.nodes[next_edge.stop])
                        end
                    end
                end
                local nauvis_deps = {}
                for dep, _ in pairs(nauvis_node.dep) do
                    local dep_node = graph_var.nodes[graph_var.edges[dep].stop]
                    -- room-launch's are intrinsic to the room
                    if not leads_to_room_launch(dep_node) then
                        if dep_node.type == "slot" then
                            local dep_node_dep
                            for dep2, _ in pairs(dep_node.dep) do
                                dep_node_dep = dep2
                                break
                            end
                            if dep_node_dep ~= nil then
                                table.insert(nauvis_deps, dep_node_dep)
                            end
                        else
                            table.insert(nauvis_deps, dep)
                        end
                    end
                end
                local gleba_deps = {}
                for dep, _ in pairs(gleba_node.dep) do
                    local dep_node = graph_var.nodes[graph_var.edges[dep].stop]
                    if not leads_to_room_launch(dep_node) then
                        if dep_node.type == "slot" then
                            local dep_node_dep
                            for dep2, _ in pairs(dep_node.dep) do
                                dep_node_dep = dep2
                                break
                            end
                            if dep_node_dep ~= nil then
                                table.insert(gleba_deps, dep_node_dep)
                            end
                        else
                            table.insert(gleba_deps, dep)
                        end
                    end
                end
                -- We add edges directly to the nodes, but skipping slots is fine; skipping travelers is what you have to watch out for
                for _, dep in pairs(nauvis_deps) do
                    local edge = graph_var.edges[dep]
                    gutils.add_edge(graph_var, gutils.key(gleba_node), edge.stop)
                    gutils.remove_edge(graph_var, dep)
                end
                for _, dep in pairs(gleba_deps) do
                    local edge = graph_var.edges[dep]
                    gutils.add_edge(graph_var, gutils.key(nauvis_node), edge.stop)
                    gutils.remove_edge(graph_var, dep)
                end
            end
        end
        log("Done injecting gleba")
    end

    if CONDUCT_FIRST_PASS then
        local pass_graph = table.deepcopy(subdiv_graph)

        if COMBINE_TECH_UNLOCK_RECIPE then
            -- Put recipe-tech-unlocks with their recipes if we're doing our experiment
            -- This technically incorrectly makes recipes depend on ALL techs that unlock them but is fine for now as a hotfix to test this approach
            for _, node in pairs(pass_graph.nodes) do
                -- TODO: Maybe some helper functions for dealing with subdivided edges
                -- TODO: Filter out annoying canonical slot
                if node.type == "slot" and node.name ~= "" then
                    local upstream_node = gutils.get_conn_owner(pass_graph, gutils.get_conn_buddy(pass_graph, node))
                    if upstream_node ~= nil and upstream_node.type == "recipe-tech-unlock" then
                        local corresponding_recipe_node = pass_graph.nodes[gutils.key("recipe", upstream_node.name)]
                        local edges_to_remove = {}

                        -- TODO: Do this better; the traveler will still have metadata about the old tech unlock node
                        local corresponding_trav = gutils.get_conn_buddy(pass_graph, node)
                        gutils.add_edge(pass_graph, gutils.key(corresponding_trav), gutils.key(corresponding_recipe_node))
                        local edges_to_remove = {}
                        for pre, _ in pairs(upstream_node.pre) do
                            table.insert(edges_to_remove, pre)
                        end
                        local function is_tech_unlock_pre(pre)
                            -- TODO: WHY IS THIS HAPPENEINGSING:?!?!
                            if pass_graph.edges[pre] == nil then
                                return false
                            end
                            local pre_node = pass_graph.nodes[pass_graph.edges[pre].start]
                            while true do
                                if pre_node.type ~= "slot" and pre_node.type ~= "traveler" then
                                    return pre_node.type == "recipe-tech-unlock"
                                else
                                    local return_val = false
                                    for further_pre, _ in pairs(pre_node.pre) do
                                        if is_tech_unlock_pre(further_pre) then
                                            return_val = true
                                        end
                                    end
                                    return return_val
                                end
                            end
                        end
                        for pre, _ in pairs(corresponding_recipe_node.pre) do
                            if is_tech_unlock_pre(pre) then
                                table.insert(edges_to_remove, pre)
                            end
                        end
                        --[[for dep, _ in pairs(upstream_node.dep) do
                            log(dep)
                            log(serpent.block(pass_graph.edges[dep]))
                            -- Idk why this wasn't added to graph.edges or whatever, hopefully that doesn't need a fix now
                            -- TODO: Fix
                            local i_hope_this_works = pass_graph.edges[dep]
                            if i_hope_this_works ~= nil then
                                local node_corresponding_trav = pass_graph.nodes[i_hope_this_works.stop]
                                for dep2, _ in pairs(node_corresponding_trav.dep) do
                                    log(dep2)
                                    if graph.edges[dep2] ~= nil then
                                        for dep3, _ in pairs(graph.nodes[graph.edges[dep2].stop].dep) do
                                            log(dep3)
                                            table.insert(edges_to_remove, dep2)
                                        end
                                    end
                                end
                            end
                        end]]
                        for _, edge_key in pairs(edges_to_remove) do
                            -- TODO: How are the edges not in the graph!?
                            if pass_graph.edges[edge_key] ~= nil then
                                gutils.remove_edge(pass_graph, edge_key)
                            end
                        end

                        --[[
                        for pre, _ in pairs(node.pre) do
                            local start = pass_graph.edges[pre].start
                            local rerouted_edge = gutils.add_edge(pass_graph, start, gutils.key(corresponding_recipe_node))
                            gutils.subdivide(pass_graph, gutils.ekey(rerouted_edge))
                            table.insert(edges_to_remove, pre)
                        end
                        for dep, _ in pairs(upstream_node.dep) do
                            table.insert(edges_to_remove, dep)
                        end
                        for _, pre in pairs(edges_to_remove) do
                            gutils.remove_edge(pass_graph, pre)
                        end]]
                    end
                end
            end
        end

        if SWITCH_TO_PLANET then
            -- TODO: Should I keep this?
            -- Extended sort to prioritize things reachable in isolations from larger VANILLA sort, then put other things after
            local planet_specific_sort = top2.sort(old_subdiv_graph)
            local reachable_isolation_deps = {}
            local not_reachable_isolation_deps = {}
            for _, dep in pairs(sorted_deps) do
                local gleba_context = gutils.key("planet", "gleba")
                -- 1 is isolatability
                if planet_specific_sort.node_to_contexts[gutils.key(dep)] == true or planet_specific_sort.node_to_contexts[gutils.key(dep)][gleba_context] == true then
                    table.insert(reachable_isolation_deps, dep)
                else
                    local has_isolatability_context = false
                    for bin_str, _ in pairs(planet_specific_sort.node_to_contexts[gutils.key(dep)][gleba_context]) do
                        if string.sub(bin_str, 1, 1) == "1" then
                            has_isolatability_context = true
                        end
                    end
                    if has_isolatability_context then
                        table.insert(reachable_isolation_deps, dep)
                    else
                        table.insert(not_reachable_isolation_deps, dep)
                    end
                end
            end
            sorted_deps = {}
            for _, dep in pairs(reachable_isolation_deps) do
                table.insert(sorted_deps, dep)
            end
            for _, dep in pairs(not_reachable_isolation_deps) do
                table.insert(sorted_deps, dep)
            end
        end
        -- CRITICAL TODO: Next level of desperation would be to start ignoring some of those blacklisted edges that we add

        local base_deps = {}
        local head_deps = {}
        local head_to_trav = {}
        local base_to_slot = {}
        local base_to_vanilla_slots = {}
        for _, dep_in_sorted in pairs(sorted_deps) do
            local dep = pass_graph.nodes[gutils.key(dep_in_sorted)]
            -- Only add deps if they had some travelers/were going to have something randomized
            -- A long stream of checks with COMBINE_TECH_UNLOCK_RECIPE, probably some are only needed because of bugs
            -- TODO: Fix!
            --if next(node_to_random_travs[gutils.key(dep)]) ~= nil and not (COMBINE_TECH_UNLOCK_RECIPE and dep.type == "traveler" and next(dep.dep) ~= nil and graph.edges[next(dep.dep)] ~= nil and gutils.get_conn_owner(pass_graph, dep) ~= nil and gutils.get_conn_owner(pass_graph, dep).type == "recipe-tech-unlock") then
                
            -- Only add deps if they had some travelers/were going to have something randomized
            -- Check if this is a tech_unlock traveler that should be excluded when COMBINE is enabled
            local is_tech_unlock_trav = false
            if COMBINE_TECH_UNLOCK_RECIPE and dep.type == "traveler" then
                local dep_in_subdiv = subdiv_graph.nodes[gutils.key(dep)]
                if dep_in_subdiv then
                    local owner = gutils.get_conn_owner(subdiv_graph, dep_in_subdiv)
                    is_tech_unlock_trav = (owner ~= nil) and (owner.type == "recipe-tech-unlock")
                end
            end
            if next(node_to_random_travs[gutils.key(dep)]) ~= nil and not is_tech_unlock_trav then
                table.insert(base_deps, dep)
                local head_node = gutils.add_node(pass_graph, dep.type, dep.name .. "-head")
                head_node.op = "AND"
                table.insert(head_deps, head_node)
                -- If dep was in short path, make sure this new head_node is too
                if short_path[gutils.key(dep)] then
                    short_path[gutils.key(head_node)] = true
                end
                local base_head_edge = gutils.add_edge(pass_graph, gutils.key(dep), gutils.key(head_node))
                -- All deps move to head
                local deps_to_remove = {}
                for base_dep, _ in pairs(dep.dep) do
                    -- TODO: Another nil edges?
                    if pass_graph.edges[base_dep] ~= nil and base_dep ~= gutils.ekey(base_head_edge) then
                        gutils.add_edge(pass_graph, gutils.key(head_node), pass_graph.edges[base_dep].stop)
                        table.insert(deps_to_remove, base_dep)
                    end
                end
                for _, base_dep in pairs(deps_to_remove) do
                    gutils.remove_edge(pass_graph, base_dep)
                end
                base_to_vanilla_slots[gutils.key(dep)] = {}
                -- Randomized pres stay with base
                -- For OR nodes/traveler deps everything (the only thing) is randomized
                if dep.type == "traveler" then
                    -- Base pre still needs to be broken
                    local slot_trav_edge
                    for pre, _ in pairs(dep.pre) do
                        slot_trav_edge = pre
                        break
                    end
                    table.insert(base_to_vanilla_slots[gutils.key(dep)], pass_graph.nodes[pass_graph.edges[slot_trav_edge].start])
                    gutils.remove_edge(pass_graph, slot_trav_edge)
                else
                    local stays_with_base = {}
                    for _, trav in pairs(node_to_random_travs[gutils.key(dep)]) do
                        stays_with_base[gutils.key(trav)] = true
                    end
                    local pres_to_remove = {}
                    for base_pre, _ in pairs(dep.pre) do
                        -- TODO: Another buggy nil edges check
                        if pass_graph.edges[base_pre] ~= nil then
                            if not stays_with_base[pass_graph.edges[base_pre].start] then
                                gutils.add_edge(pass_graph, pass_graph.edges[base_pre].start, gutils.key(head_node))
                                table.insert(pres_to_remove, base_pre)
                            else
                                -- Base pres must be broken so that they can be reassembled to the new head
                                local prenode = pass_graph.nodes[pass_graph.edges[base_pre].start]
                                -- Get unique edge from slot
                                local prenode_pre
                                for pre, _ in pairs(prenode.pre) do
                                    prenode_pre = pre
                                    break
                                end
                                table.insert(base_to_vanilla_slots[gutils.key(dep)], pass_graph.nodes[pass_graph.edges[prenode_pre].start])
                                table.insert(pres_to_remove, prenode_pre)
                            end
                        end
                    end
                    for _, base_pre in pairs(pres_to_remove) do
                        gutils.remove_edge(pass_graph, base_pre)
                    end
                end
                local subdivide_info = gutils.subdivide(pass_graph, gutils.ekey(base_head_edge))
                local sub_trav = subdivide_info.traveler
                head_to_trav[gutils.key(head_node)] = sub_trav
                base_to_slot[gutils.key(dep)] = subdivide_info.slot
                local edge_to_remove
                for pre, _ in pairs(sub_trav.pre) do
                    gutils.remove_edge(pass_graph, pre)
                    break
                end
            end
        end

        log("Calling first-pass")
        local first_pass_info = first_pass.shuffle(pass_graph, short_path, shuffled_prereqs, init_sort, base_deps, head_deps, node_to_random_travs, head_to_trav, base_to_slot, base_to_vanilla_slots, trav_to_handler)
        log("Call successful")

        if COMBINE_TECH_UNLOCK_RECIPE then
            -- Uncombine recipe and recipe-tech-unlock
            local pass_sort = first_pass_info.pass_sort

            local new_open = {}
            local old_ind_to_new_ind = {}
            local new_ind_to_ind = {}
            for open_ind, open_info in pairs(pass_sort.open) do
                local node = pass_graph.nodes[open_info.node]
                if node.type == "recipe" and string.sub(node.name, -5, -1) ~= "-head" then
                    table.insert(new_open, {
                        node = gutils.key("recipe-tech-unlock", node.name),
                        contexts = true--open_info.contexts,
                    })
                    old_ind_to_new_ind[open_ind] = #new_open
                    new_ind_to_ind[#new_open] = old_ind_to_new_ind[pass_sort.ind_to_ind[open_ind]]
                end
                table.insert(new_open, open_info)
                old_ind_to_new_ind[open_ind] = #new_open
                new_ind_to_ind[#new_open] = old_ind_to_new_ind[pass_sort.ind_to_ind[open_ind]]
            end
            pass_sort.open = new_open
            pass_sort.ind_to_ind = new_ind_to_ind
        end

        for _, dep in pairs(first_pass_info.new_dep_order) do
            log(gutils.key(dep))
        end

        pool_info = first_pass_info.pass_sort
        first_pass_sorted_deps = first_pass_info.new_dep_order
        -- first_pass_info gives back the dependents in its graph, to change sorted_deps let's get the dependents with matching keys
        sorted_deps = {}
        for _, dep in pairs(first_pass_sorted_deps) do
            if COMBINE_TECH_UNLOCK_RECIPE then
                if dep.type == "recipe" then
                    local recipe_prot = data.raw.recipe[string.sub(dep.name, 1, -6)]
                    if recipe_prot.enabled == false then
                        local tech_unlock_node = subdiv_graph.nodes[gutils.key("recipe-tech-unlock", string.sub(dep.name, 1, -6))]
                        table.insert(sorted_deps, tech_unlock_node)
                        -- TODO: So much hackiness...
                        node_to_random_travs[gutils.key(tech_unlock_node)] = {tech_unlock_node}
                        trav_to_handler[gutils.key(tech_unlock_node)] = handlers["tech-unlocks"]
                    end
                end
            end
            -- We do string.sub to remove the -head suffix, since the deps returned are the heads
            local dep_in_old_graph = subdiv_graph.nodes[gutils.key(dep.type, string.sub(dep.name, 1, -6))]
            table.insert(sorted_deps, dep_in_old_graph)
        end

        -- TODO: This is copy-pasted code; refactor into a function in the future
        context_node_to_ind = {}
        if not PRESERVE_ISOLATABILITY then
            local all_contexts = {}
            for context, _ in pairs(logic.contexts) do
                all_contexts[context] = true
                context_node_to_ind[context] = {}
            end
            for open_ind, node_info in pairs(pool_info.open) do
                local contexts_to_use = node_info.contexts
                if contexts_to_use == true then
                    contexts_to_use = table.deepcopy(all_contexts)
                end
                for context, _ in pairs(contexts_to_use) do
                    context_node_to_ind[context][node_info.node] = context_node_to_ind[context][node_info.node] or open_ind
                end
            end
        else
            for context, _ in pairs(logic.contexts) do
                for _, str_val in pairs({"0", "1"}) do
                    context_node_to_ind[context .. str_val] = {}
                end
            end
            for open_ind, node_info in pairs(pool_info.open) do
                if node_info.contexts == true then
                    for context, _ in pairs(logic.contexts) do
                        for _, str_val in pairs({"0", "1"}) do
                            context_node_to_ind[context .. str_val][node_info.node] = context_node_to_ind[context .. str_val][node_info.node] or open_ind
                        end
                    end
                else
                    for context, context_vals in pairs(node_info.contexts) do
                        if context_vals == true then
                            for _, str_val in pairs({"0", "1"}) do
                                context_node_to_ind[context .. str_val][node_info.node] = context_node_to_ind[context .. str_val][node_info.node] or open_ind
                            end
                        else
                            for bin_str, val in pairs(context_vals) do
                                context_node_to_ind[context .. string.sub(bin_str, 1, 1)][node_info.node] = context_node_to_ind[context .. string.sub(bin_str, 1, 1)][node_info.node] or open_ind
                            end
                        end
                    end
                end
            end
        end
        -- Give bases head contexts
        for context, _ in pairs(logic.contexts) do
            for _, dep in pairs(sorted_deps) do
                local corresponding_head = pass_graph.nodes[gutils.key(dep.type, dep.name .. "-head")]
                if corresponding_head ~= nil then
                    context_node_to_ind[context][gutils.key(dep)] = context_node_to_ind[context][gutils.key(corresponding_head)]
                end
            end
        end
    end

    -- Context reachability
    -- Testing if putting another here fixes a bug
    -- CRITICAL TODO: Remove when resolved
    local function all_contexts_reachable_new(slot, trav)
        -- Actually, this breaks things to do the direct connection way (which is kinda obvious in hindsight)
        -- CRITICAL TODO: Don't do that stupid direct connection thing (I think this was in "first pass" where I was doing this thing)
        -- I did some direct connections, which I probably shouldn't have, so we'll need to check the actual owners
        --local slot_owner = gutils.get_conn_owner(random_graph, slot)
        --local trav_owner = gutils.get_conn_owner(random_graph, trav)

        if not PRESERVE_ISOLATABILITY then
            for context, _ in pairs(logic.contexts) do
                -- Let's try with "last prereq comes after"
                -- Trying out a new idea where we ignore things after the last prereq that satisfied something (ind_to_ind)
                -- This actually didn't have an effect because of the way pool sort works
                if (pool_info.ind_to_ind[context_node_to_ind[context][gutils.key(trav)]] or (#pool_info.open + 2)) < (context_node_to_ind[context][gutils.key(slot)] or (#pool_info.open + 1)) then
                    return false
                end
            end
        else
            for context, _ in pairs(logic.contexts) do
                for _, str_val in pairs({"0", "1"}) do
                    if (context_node_to_ind[context .. str_val][gutils.key(trav)] or (#pool_info.open + 2)) < (context_node_to_ind[context .. str_val][gutils.key(slot)] or (#pool_info.open + 1)) then
                        return false
                    end
                end
            end
        end

        return true
    end

    -- TEST: Make sure each trav is after its corresponding slot
    for _, dep in pairs(sorted_deps) do
        for _, trav in pairs(node_to_random_travs[gutils.key(dep)]) do
            local subdiv_trav = subdiv_graph.nodes[gutils.key(trav)]
            local subdiv_slot = gutils.get_conn_buddy(subdiv_graph, subdiv_trav)
            local slot = random_graph.nodes[gutils.key(subdiv_slot)]
            if slot.name ~= trav.name then
                log(serpent.block(slot.name))
                log(serpent.block(trav.name))
                error("Randomization assertion failed! Tell exfret he's a dumbo.")
            end
            assert(all_contexts_reachable(slot, trav))
        end
    end

    test_graph_invariants.test(random_graph)

    ----------------------------------------------------------------------------------------------------
    -- Do The Shuffle
    ----------------------------------------------------------------------------------------------------

    log("Shuffle started")

    rng.shuffle(rng.key({id = "unified"}), shuffled_prereqs)
    rng.shuffle(rng.key({id = "unified"}), post_shuffled_prereqs)
    for _, prereq in pairs(post_shuffled_prereqs) do
        table.insert(shuffled_prereqs, prereq)
    end

    -- Take out techs and put them back in order to encourage recipe unlocks to be in order
    -- Order techs according to new sort
    -- This still seems not to be working
    --[[if COMBINE_TECH_UNLOCK_RECIPE_TWO then
        local techs_in_order = {}
        local tech_to_pos = {}
        for _, dep in pairs(sorted_deps) do
            if dep.type == "technology" then
                table.insert(techs_in_order, {})
                tech_to_pos[string.sub(dep.name, 1, -6)] = #techs_in_order
            end
        end
        for _, prereq in pairs(shuffled_prereqs) do
            local prereq_owner = gutils.get_conn_owner(pool_graph, prereq)
            if prereq_owner.type == "technology" and tech_to_pos[prereq_owner.name] ~= nil then
                table.insert(techs_in_order[tech_to_pos[prereq_owner.name] ], prereq)
            end
        end
        local outer_ind = 1
        local inner_ind = 1
        for ind, prereq in pairs(shuffled_prereqs) do
            local prereq_owner = gutils.get_conn_owner(pool_graph, prereq)
            if prereq_owner.type == "technology" and outer_ind <= #techs_in_order then
                if inner_ind > #techs_in_order[outer_ind] then
                    outer_ind = outer_ind + 1
                    inner_ind = 1
                end
                if outer_ind <= #techs_in_order then
                    local replacement_prereq = techs_in_order[outer_ind][inner_ind]
                    shuffled_prereqs[ind] = replacement_prereq
                    inner_ind = inner_ind + 1
                end
            end
        end
    end]]

    -- Note that we don't technically need to go in dependent order anymore
    local used_prereq_indices = {}
    -- We actually should keep dep-prereq map since some prereqs are there multiple times
    -- Thus, the graph alone would look weird as a way of representing things
    local trav_to_new_slot = {}
    for dep_ind, dep in pairs(sorted_deps) do
        if #node_to_random_travs[gutils.key(dep)] > 0 then
            log("Randomizing " .. gutils.key(dep))
            for _, trav in pairs(node_to_random_travs[gutils.key(dep)]) do
                local found_prereq = false
                for ind, slot in pairs(shuffled_prereqs) do
                    if trav_to_handler[gutils.key(trav)].id == "entity_operation_fluid" and gutils.get_conn_owner(random_graph, slot).type == "fluid" then
                        log(slot.name)
                        log(trav.name)
                        log(all_contexts_reachable_new(slot, trav))
                    end
                    if not used_prereq_indices[ind] and all_contexts_reachable_new(slot, trav) then
                        -- Have traveler's handler validate this ind
                        if trav_to_handler[gutils.key(trav)].validate(random_graph, slot, trav, {
                            init_sort = init_sort, -- Needed for tech rando
                        }) then
                            log("Accepted prereq " .. gutils.key(gutils.get_conn_owner(cut_graph, slot)))
                            trav_to_handler[gutils.key(trav)].process(random_graph, slot, trav)
                            found_prereq = true
                            used_prereq_indices[ind] = true
                            trav_to_new_slot[gutils.key(trav)] = slot

                            -- No need to update graph since we already know prereq pools
                            break
                        end
                    end
                end
                if not found_prereq then
                    -- Future idea: try going through a second time with another shuffled list
                    local percentage = math.floor(100 * dep_ind / #sorted_deps)
                    -- Prereq shuffle can "keep failing", making its failures only an isolated subset (that's cool!)
                    log("Prereq shuffle failed at " .. percentage .. "%")
                    -- CRITICAL TODO: Uncomment this out! No softlocks allowed!
                    --error()
                end
            end
        end
    end

    test_graph_invariants.test(random_graph)

    ----------------------------------------------------------------------------------------------------
    -- Reflection
    ----------------------------------------------------------------------------------------------------

    for _, handler in pairs(handlers) do
        handler.reflect(random_graph, trav_to_new_slot, trav_to_handler)
    end

    if SWITCH_TO_PLANET then
        local old_nauvis = table.deepcopy(data.raw.planet.nauvis)
        data.raw.planet.nauvis = table.deepcopy(data.raw.planet.gleba)
        data.raw.planet.nauvis.name = "nauvis"
        data.raw.planet.gleba = old_nauvis
        data.raw.planet.gleba.name = "gleba"
    end
end

return unified