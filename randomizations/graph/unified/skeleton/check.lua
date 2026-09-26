-- Correctness check, independent of how randomization works: compares each mechanic's contexts in a sort of the final randomized game against a sort of the original game, and logs any mechanic contexts that were lost
-- It also checks that every originally reachable recipe is still reachable somewhere
-- All output goes to the log with the prefix MECHCHECK

local check = {}

-- graph: final logic graph; init_sort_info / final_sort_info: sorts of the original and final graphs
check.run = function(graph, init_sort_info, final_sort_info)
    local num_checked = 0
    local lost = {}
    for node_key, init_context_inds in pairs(init_sort_info.node_to_context_inds) do
        local node = graph.nodes[node_key]
        if node ~= nil and node.mechanic and node.type ~= "orand" then
            local final_context_inds = final_sort_info.node_to_context_inds[node_key] or {}
            for context, _ in pairs(init_context_inds) do
                num_checked = num_checked + 1
                if final_context_inds[context] == nil then
                    table.insert(lost, node_key .. " @ " .. context)
                end
            end
        end
    end
    -- Every recipe reachable originally must still be reachable somewhere
    local num_recipes = 0
    local lost_recipes = {}
    for node_key, init_context_inds in pairs(init_sort_info.node_to_context_inds) do
        local node = graph.nodes[node_key]
        if node ~= nil and node.type == "recipe" and next(init_context_inds) ~= nil then
            num_recipes = num_recipes + 1
            if next(final_sort_info.node_to_context_inds[node_key] or {}) == nil then
                table.insert(lost_recipes, node_key)
            end
        end
    end
    table.sort(lost_recipes)
    log("MECHCHECK checked " .. num_recipes .. " recipes; unreachable " .. #lost_recipes)
    for _, recipe_key in pairs(lost_recipes) do
        log("MECHCHECK unreachable recipe " .. recipe_key)
    end

    -- Promised pebbles missing from the final game show where promotion's model and the reflected game disagree
    -- Item-derived nodes (item, item-craft, item-launch, entity-build-item, ...) are skipped since first pass renames items: the model keys them by position, the final game by the item now at that position
    if UNIFIED_PROMISED_PEBBLES ~= nil then
        local num_compared = 0
        local mismatches = {}
        for _, pebble in pairs(UNIFIED_PROMISED_PEBBLES) do
            local node = graph.nodes[pebble.node_key]
            if node ~= nil and string.find(node.type, "item", 1, true) == nil then
                num_compared = num_compared + 1
                if (final_sort_info.node_to_context_inds[pebble.node_key] or {})[pebble.context] == nil then
                    table.insert(mismatches, pebble)
                end
            end
        end
        log("MECHCHECK promised pebbles compared " .. num_compared .. "; missing in final game " .. #mismatches)
        for i = 1, math.min(20, #mismatches) do
            log("MECHCHECK promised but missing: " .. mismatches[i].node_key .. " @ " .. mismatches[i].context .. " (model rank " .. mismatches[i].rank .. ")")
        end
    end

    table.sort(lost)
    log("MECHCHECK checked " .. num_checked .. " mechanic contexts; lost " .. #lost)
    if #lost > 0 or #lost_recipes > 0 then
        -- Earliest nodes (by original sort) that became unreachable everywhere; the first few are likely the root cause
        local newly_unreachable = {}
        for node_key, init_context_inds in pairs(init_sort_info.node_to_context_inds) do
            local earliest
            for _, ind in pairs(init_context_inds) do
                if earliest == nil or ind < earliest then
                    earliest = ind
                end
            end
            if earliest ~= nil and next(final_sort_info.node_to_context_inds[node_key] or {}) == nil and graph.nodes[node_key] ~= nil then
                local node_type = graph.nodes[node_key].type
                if node_type == "item" or node_type == "fluid" or node_type == "recipe" or node_type == "entity" or node_type == "technology" then
                    table.insert(newly_unreachable, {
                        key = node_key,
                        ind = earliest,
                    })
                end
            end
        end
        table.sort(newly_unreachable, function(a, b) return a.ind < b.ind end)
        for i = 1, math.min(15, #newly_unreachable) do
            log("MECHCHECK root? " .. newly_unreachable[i].key .. " (orig rank " .. newly_unreachable[i].ind .. ")")
        end

        -- Walk back from the earliest root through prereqs that are unreachable in the final game, to show where it bottoms out
        if #newly_unreachable > 0 then
            local seen = {}
            local function walk(node_key, depth, indent)
                if seen[node_key] or depth > 25 then
                    return
                end
                seen[node_key] = true
                local node = graph.nodes[node_key]
                local num_pre = 0
                for _, _ in pairs(node.pre) do
                    num_pre = num_pre + 1
                end
                log("MECHCHECK walk " .. indent .. node_key .. " op=" .. tostring(node.op) .. " num_pre=" .. num_pre)
                for pre, _ in pairs(node.pre) do
                    local pre_key = graph.edges[pre].start
                    if next(final_sort_info.node_to_context_inds[pre_key] or {}) == nil then
                        walk(pre_key, depth + 1, indent .. "  ")
                    end
                end
            end
            walk(newly_unreachable[1].key, 0, "")
        end
    end
    for _, str in pairs(lost) do
        log("MECHCHECK lost " .. str)
    end
    return lost
end

return check
