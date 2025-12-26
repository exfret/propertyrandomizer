local path = require("lib/graph/path")
local rng = require("lib/random/rng")
local gutils = require("new-lib/graph/graph-utils")
local top = require("new-lib/graph/top-sort")
local logic = require("new-lib/logic/logic")
local dutils = require("new-lib/data-utils")

-- Just for some ad hoc translation so path can work
local build_graph = require("lib/graph/build-graph")
local top_orig = require("lib/graph/top-sort")

local recipe_results = {}

recipe_results.execute = function(graph)
    -- Ignore tech triggers for now
    local blacklist = {}
    for _, tech in pairs(data.raw.technology) do
        if tech.research_trigger ~= nil and (tech.research_trigger.type == "craft-item" or tech.research_trigger.type == "craft-fluid") then
            blacklist[tech.research_trigger.item or tech.research_trigger.fluid] = true
        end
    end
    -- Ad hoc list
    --[[for _, item in pairs({"atomic-bomb"}) do
        blacklist[item] = true
    end
    for _, item in pairs(data.raw.tool) do
        blacklist[item.name] = true
        data.raw.recipe[item.name].surface_conditions = nil
    end]]

    local old_graph = table.deepcopy(graph)
    local initial_sort = top.sort(graph)

    local added_to_dependents = {}
    local sorted_dependents = {}
    local shuffled_prereqs = {}
    -- We can be more lenient with launchable items
    local launchable_items = {}
    local dep_to_old_prereq = {}
    local node_to_ind = {}
    for open_ind, node_info in pairs(initial_sort.open) do
        local node_key = node_info.node
        local node = graph.nodes[node_key]
        -- This is used for calling path later, so needs the build-graph key
        node_to_ind[build_graph.key(node.type, node.name)] = open_ind

        local item_launchable = false
        for pre, _ in pairs(node.pre) do
            local prereq = graph.nodes[graph.edges[pre].start]
            if prereq.type == "item-launch" then
                launchable_items[node_key] = true
                item_launchable = true
            end
        end
        -- Update context_node_to_ind, but only if this item is not deliverable or it hasn't been assigned any yet
        --[[if not item_launchable or not added_to_dependents[node_key] then
            if node_info.contexts == true then
                for context, _ in pairs(logic.contexts) do
                    context_node_to_ind[context][node_key] = context_node_to_ind[context][node_key] or open_ind
                end
            else
                for context, _ in pairs(node_info.contexts) do
                    context_node_to_ind[context][node_key] = context_node_to_ind[context][node_key] or open_ind
                end
            end
        end]]

        if not added_to_dependents[node_key] and (node.type == "item-craft" or node.type == "fluid-craft") and not blacklist[node.name] then
            local prereqs = {}
            for pre, _ in pairs(node.pre) do
                local prereq = graph.nodes[graph.edges[pre].start]
                if prereq.type == "recipe" and not data.raw.recipe[prereq.name].hidden then
                    table.insert(prereqs, pre)
                end
            end

            -- Only add for results with only one recipe for simplicity
            -- Otherwise, we'd have to cut edges up
            if #prereqs == 1 then
                added_to_dependents[node_key] = true
                table.insert(sorted_dependents, node)
                dep_to_old_prereq[node_key] = {}

                for _, pre in pairs(prereqs) do
                    local prereq = graph.nodes[graph.edges[pre].start]
                    table.insert(shuffled_prereqs, prereq)
                    dep_to_old_prereq[node_key][pre] = graph.edges[pre]
                    gutils.remove_edge(graph, pre)
                end
            end
        end
    end

    local ad_hoc_graph = {}
    for _, node in pairs(old_graph.nodes) do
        ad_hoc_node = {
            type = node.type,
            name = node.name,
            prereqs = {},
            dependents = {},
        }
        for pre, _ in pairs(node.pre) do
            local prereq = old_graph.nodes[old_graph.edges[pre].start]
            table.insert(ad_hoc_node.prereqs, {
                type = prereq.type,
                name = prereq.name,
            })
        end
        for dep, _ in pairs(node.dep) do
            local dependent = old_graph.nodes[old_graph.edges[dep].stop]
            table.insert(ad_hoc_node.dependents, {
                type = dependent.type,
                name = dependent.name,
            })
        end
        --[[table.sort(ad_hoc_node.prereqs, function(a, b)
            if node_to_ind[build_graph.key(a.type, a.name)] == nil then
                -- Put at end
                return false
            end
            if node_to_ind[build_graph.key(b.type, b.name)] == nil then
                -- Put at end
                return true
            end
            return node_to_ind[build_graph.key(a.type, a.name)] < node_to_ind[build_graph.key(b.type, b.name)]
        end)]]
        ad_hoc_graph[build_graph.key(node.type, node.name)] = ad_hoc_node
    end
    for type_name, type_info in pairs(logic.type_info) do
        build_graph.ops[type_name] = type_info.op
    end

    -- Maybe try with real top sort
    local orig_sort = top_orig.sort(ad_hoc_graph)
    local real_node_to_ind = {}
    for ind, node in pairs(orig_sort.sorted) do
        real_node_to_ind[build_graph.key(node.type, node.name)] = ind
    end
    for ind, node in pairs(orig_sort.sorted) do
        table.sort(node.prereqs, function(a, b)
            if real_node_to_ind[build_graph.key(a.type, a.name)] == nil then
                return false
            end
            if real_node_to_ind[build_graph.key(b.type, b.name)] == nil then
                return true
            end
            return real_node_to_ind[build_graph.key(a.type, a.name)] < real_node_to_ind[build_graph.key(b.type, b.name)]
        end)
    end
    -- Just in case
    build_graph.add_dependents(ad_hoc_graph)
    -- This is just used as a heuristic to put some things first
    local critical_path = path.find_path(ad_hoc_graph, ad_hoc_graph[build_graph.key("item", "promethium-science-pack")])

    --log(serpent.block(critical_path))

    local new_sorted_dependents_first = {}
    local new_sorted_dependents_last = {}
    for _, dependent in pairs(sorted_dependents) do
        if critical_path[build_graph.key(dependent.type, dependent.name)] then
            table.insert(new_sorted_dependents_first, dependent)
        else
            table.insert(new_sorted_dependents_last, dependent)
        end
    end
    -- Reverse new_sorted_dependents_last
    local new_sorted_dependents_last_reverse = {}
    for i = #new_sorted_dependents_last, 1, -1 do
        table.insert(new_sorted_dependents_last_reverse, new_sorted_dependents_last[i])
    end
    sorted_dependents = {}
    for _, dep in pairs(new_sorted_dependents_first) do
        table.insert(sorted_dependents, dep)
    end
    for _, dep in pairs(new_sorted_dependents_last_reverse) do
        table.insert(sorted_dependents, dep)
    end
    for _, dep in pairs(sorted_dependents) do
        --log(dep.name)
    end

    local function is_context_reachable(sort_to_use, node)
        return sort_to_use.node_to_contexts[gutils.key(node)] ~= nil and (sort_to_use.node_to_contexts[gutils.key(node)] == true or next(sort_to_use.node_to_contexts[gutils.key(node)]) ~= nil)
    end

    -- Now do a sort, but fill out prereqs first before adding new dep to figure out full pools
    local pool_graph = table.deepcopy(graph)

    -- Need to separate into slots and travelers
    local pre_to_slot = {}
    local dep_to_traveler = {}
    for dep, pres in pairs(dep_to_old_prereq) do
        for pre, prereq in pairs(pres) do
            local prenode = pool_graph.nodes[prereq.start]
            local slot = gutils.add_node(pool_graph, "slot", gutils.ekey(prereq))
            local traveler = gutils.add_node(pool_graph, "traveler", gutils.ekey(prereq))
            slot.op = "AND"
            traveler.op = "OR"
            gutils.add_edge(pool_graph, gutils.key(prenode), gutils.key(slot))
            gutils.add_edge(pool_graph, gutils.key(traveler), dep)
            pre_to_slot[gutils.key(prenode)] = slot
            dep_to_traveler[dep] = traveler
        end
    end

    local pool_sort = top.sort(pool_graph)
    -- Things maybe be out of order now...
    local dep_inds_added = {}

    local function is_prereq_context_reachable(sort_to_use, dep)
        -- Technically should check slot, not prereq, but good enough
        for pre, prereq in pairs(dep_to_old_prereq[gutils.key(dep)]) do
            if is_context_reachable(sort_to_use, pool_graph.nodes[prereq.start]) then
                return true
            end
        end
        return false
    end

    local okay_final_sorted_dependents_order = {}
    for i = 1, #sorted_dependents do
        for ind, dep in pairs(sorted_dependents) do
            if not dep_inds_added[ind] and is_prereq_context_reachable(pool_sort, dep) then
                table.insert(okay_final_sorted_dependents_order, dep)
                dep_inds_added[ind] = true
                -- This should only be one prereq in reality
                for pre, prereq in pairs(dep_to_old_prereq[gutils.key(dep)]) do
                    local edge = gutils.add_edge(pool_graph, gutils.key(pre_to_slot[prereq.start]), gutils.key(dep_to_traveler[gutils.key(dep)]))
                    pool_sort = top.sort(pool_graph, pool_sort, {
                        edge = gutils.ekey(edge),
                        contexts = pool_sort.node_to_contexts[edge.start],
                    })
                end
                break
            end
        end
    end
    sorted_dependents = okay_final_sorted_dependents_order
    for _, dep in pairs(sorted_dependents) do
        --log(dep.name)
    end
    -- Takes context and node to when the node first gets that context in open
    -- Might be able to add this to sort info
    -- This could still not catch things that only add an item to a surface where it's not needed but checking more rigorously could be a future task
    local context_node_to_ind = {}
    for context, _ in pairs(logic.contexts) do
        context_node_to_ind[context] = {}
    end
    for open_ind, node_info in pairs(pool_sort.open) do
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

    rng.shuffle(rng.key({id = "graph"}), shuffled_prereqs)

    local prereq_inds_used = {}
    local new_edges = {}
    local sort = top.sort(graph)
    local dep_to_prereq = {}
    for _, dep in pairs(sorted_dependents) do
        log("Randomizing result: " .. dep.name)

        local found_prereq = false

        local is_launchable = false
        for dep, _ in pairs(dep.dep) do
            if graph.nodes[graph.edges[dep].stop].type == "item" then
                if launchable_items[graph.edges[dep].stop] then
                    is_launchable = true
                end
            end
        end

        --[[local pre_to_compare
        -- Get unique prereq (need to compare prereq contexts and prereq contexts)
        -- TODO: Not sure how to do this with multiple prereqs
        for _, prereq in pairs(dep_to_old_prereq[gutils.key(dep)]) do
            pre_to_compare = graph.nodes[prereq.start]
        end]]

        -- Check if prereq is earlier in all contexts
        -- Note: This is an oversimplification, because a recipe doesn't need to be made in all contexts, so prereqs don't need to come beforehand in all contexts
        -- TODO: Fix this so we only check contexts that are relevant
        local function all_contexts_reachable(prereq)
            -- If dep is launchable, just need to check first reachability
            --[[if is_launchable then
                return sort.node_to_contexts[gutils.key(prereq)] ~= nil and (sort.node_to_contexts[gutils.key(prereq)] == true or next(sort.node_to_contexts[gutils.key(prereq)]) ~= nil)
            end]]

            for context, _ in pairs(logic.contexts) do
                -- If item/traveler unreachable (on the left) in this context - no need to worry, so large number (so that it won't return false)
                -- If recipe/slot unreachable (on the right) - yes worry (but not as much), so less large number
                if (context_node_to_ind[context][gutils.key(dep_to_traveler[gutils.key(dep)])] or (#initial_sort.open + 2)) <= (context_node_to_ind[context][gutils.key(pre_to_slot[gutils.key(prereq)])] or (#initial_sort.open + 1)) then
                    --log(serpent.block(context_node_to_ind[context][gutils.key(pre_to_compare)]))
                    --log(serpent.block(context_node_to_ind[context][gutils.key(prereq)]))
                    return false
                end
            end
            return true
        end

        for ind, prereq in pairs(shuffled_prereqs) do
            if not prereq_inds_used[ind] and all_contexts_reachable(prereq) then
                -- Check fluidity
                local recipe_prot = data.raw.recipe[prereq.name]
                if not ((recipe_prot.category == nil or recipe_prot.category == "crafting") and dep.type == "fluid-craft") then
                    log("Randomized to: " .. prereq.name)
                    found_prereq = true
                    prereq_inds_used[ind] = true
                    dep_to_prereq[gutils.key(dep)] = prereq

                    -- Update graph
                    local edge = gutils.add_edge(graph, gutils.key(prereq), gutils.key(dep))
                    sort = top.sort(graph, sort, {
                        edge = gutils.ekey(edge),
                        contexts = sort.node_to_contexts[gutils.key(prereq)],
                    })

                    break
                end
            end
        end
        
        if not found_prereq then
            for ind, prereq in pairs(shuffled_prereqs) do
                if not prereq_inds_used[ind] and sort.node_to_contexts[gutils.key(prereq)] ~= nil and (sort.node_to_contexts[gutils.key(prereq)] == true or next(sort.node_to_contexts[gutils.key(prereq)]) ~= nil) then
                    log(prereq.name)
                end
            end
            error()
        end
    end

    -- Some of our prereqs actually go to multiple deps!
    for _, dep in pairs(sorted_dependents) do
        local recipe_prot = data.raw.recipe[dep_to_prereq[gutils.key(dep)].name]
        recipe_prot.results = {}
    end

    for _, dep in pairs(sorted_dependents) do
        local mat_type = "item"
        if dep.type == "fluid-craft" then
            mat_type = "fluid"
        end
        local material_prot = dutils.get_prot(mat_type, dep.name)
        local recipe_prot = data.raw.recipe[dep_to_prereq[gutils.key(dep)].name]
        
        recipe_prot.main_product = nil
        table.insert(recipe_prot.results, {type = mat_type, name = dep.name, amount = 1})

        -- Fix icon
        if recipe_prot.icons == nil and recipe_prot.icon == nil then
            local recipe_icons
            if material_prot.icons ~= nil then
                recipe_prot.icons = material_prot.icons
            else
                recipe_prot.icons = {
                    {
                        icon = material_prot.icon,
                        icon_size = material_prot.icon_size or 64
                    }
                }
            end
        end
    end

    -- Fix main products
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.main_product ~= nil then
            if recipe.results ~= nil then
                local has_valid_result = false
                for _, ing in pairs(recipe.results) do
                    if ing.name == recipe.main_product then
                        has_valid_result = true
                        break
                    end
                end
                if not has_valid_result then
                    recipe.main_product = nil
                end
            else
                recipe.main_product = nil
            end
        end
    end
end

return recipe_results