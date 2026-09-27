-- Correctness check, independent of how randomization works: compares each mechanic's contexts in a sort of the final randomized game against a sort of the original game, and logs any mechanic contexts that were lost
-- It also checks that every originally reachable recipe is still reachable somewhere
-- Output goes to the log with the prefix MECHCHECK (or the given label)
-- The verdict says whether the game is safe to hand out: unified randomization retries attempts that fail it, and a game that still fails it loads with a warning in the randomizer panel (a softlock must never be silent, and a startup error would make them reset their settings)

local top = require("lib/graph/context-sort")
local protection = require("randomizations/graph/unified/skeleton/protection")
local furnace_selection = require("lib/furnace-selection")
local item_fluid = require("lib/item-fluid")
local logic = require("lib/logic/init")

local check = {}

-- Whether a node missing context in the final game only lost isolatability there: it still has the context's room and automatability (final_has(context) says whether the final game has a context)
-- Losing only isolatability means importing something, not a softlock, so it's logged but doesn't fail the check
-- Home contexts only back isolatability, so losing one never fails the check either
local function only_isolatability_lost(context, final_has)
    if top.context_home(context) ~= nil then
        return true
    end
    local abilities = top.context_abilities(context)
    if abilities == nil or not protection.is_isolatable_context(context) then
        return false
    end
    local without_isolatability = string.sub(abilities, 1, top.ISOLATABILITY - 1) .. "0" .. string.sub(abilities, top.ISOLATABILITY + 1)
    return final_has(top.context_key(top.context_room(context), without_isolatability))
end

-- graph: final logic graph; init_sort_info / final_sort_info: sorts of the original and final graphs (with complex contexts, so abilities like isolatability are checked too)
-- Only the protected part of each mechanic context counts (see protection.lua)
-- label (optional) replaces MECHCHECK in the log lines
-- Returns the verdict: { ok = whether nothing a player needs was lost, unreachable = number of recipes, lost = number of mechanic contexts lost beyond isolatability, missing = number of promised pebbles missing beyond isolatability, furnace_collisions = number of ingredients some furnace can't pick a recipe by }
check.run = function(graph, init_sort_info, final_sort_info, label)
    label = label or "MECHCHECK"
    local function log_check(message)
        log(label .. " " .. message)
    end
    local num_checked = 0
    local lost = {}
    local num_hard_lost = 0
    -- Nodes named after an item or fluid are named after the identity at its position in the final game, since item reflection renames them (see item_fluid.final_node_key)
    local function final_key(node_key)
        if not config.item_fluids then
            return node_key
        end
        return item_fluid.final_node_key(node_key, UNIFIED_MATERIAL_RENAMES, logic.type_info)
    end
    for node_key, init_context_inds in pairs(init_sort_info.node_to_context_inds) do
        local node = graph.nodes[final_key(node_key)]
        if node ~= nil and node.mechanic and node.type ~= "orand" then
            local final_kept = {}
            for context, _ in pairs(final_sort_info.node_to_context_inds[final_key(node_key)] or {}) do
                final_kept[protection.kept_part(node, context)] = true
            end
            local is_checked = {}
            for context, _ in pairs(init_context_inds) do
                local kept = protection.kept_part(node, context)
                if is_checked[kept] == nil then
                    is_checked[kept] = true
                    num_checked = num_checked + 1
                    if final_kept[kept] == nil then
                        if only_isolatability_lost(kept, function(other)
                            return final_kept[other] ~= nil
                        end) then
                            table.insert(lost, node_key .. " @ " .. kept .. " (only isolatability)")
                        else
                            table.insert(lost, node_key .. " @ " .. kept)
                            num_hard_lost = num_hard_lost + 1
                        end
                    end
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
    log_check("checked " .. num_recipes .. " recipes; unreachable " .. #lost_recipes)
    for _, recipe_key in pairs(lost_recipes) do
        log_check("unreachable recipe " .. recipe_key)
    end

    -- Promised pebbles missing from the final game show where promotion's model and the reflected game disagree
    -- Item-derived nodes (item, item-craft, item-launch, entity-build-item, ...) are skipped since first pass renames items: the model keys them by position, the final game by the item now at that position
    -- Nodes named after fluids (fluid, fluid-temperature, fluid-create, ..., and mining-fluid bases) are skipped for the same reason, since first pass renames fluids too (see lib/item-fluid.lua)
    local num_hard_missing = 0
    if UNIFIED_PROMISED_PEBBLES ~= nil then
        local num_compared = 0
        local mismatches = {}
        for _, pebble in pairs(UNIFIED_PROMISED_PEBBLES) do
            local node = graph.nodes[pebble.node_key]
            local named_after_fluid = config.item_fluids and (string.sub(node ~= nil and node.type or "", 1, 5) == "fluid" or (node ~= nil and node.type == "mining-fluid"))
            if node ~= nil and string.find(node.type, "item", 1, true) == nil and not named_after_fluid then
                num_compared = num_compared + 1
                local final_contexts = final_sort_info.node_to_context_inds[pebble.node_key] or {}
                if final_contexts[pebble.context] == nil then
                    table.insert(mismatches, pebble)
                    if not only_isolatability_lost(pebble.context, function(other)
                        return final_contexts[other] ~= nil
                    end) then
                        num_hard_missing = num_hard_missing + 1
                    end
                end
            end
        end
        log_check("promised pebbles compared " .. num_compared .. "; missing in final game " .. #mismatches .. " (" .. num_hard_missing .. " beyond isolatability)")
        for i = 1, math.min(20, #mismatches) do
            log_check("promised but missing: " .. mismatches[i].node_key .. " @ " .. mismatches[i].context .. " (model rank " .. mismatches[i].rank .. ")")
        end
    end

    -- Also report how much unprotected isolatability was kept (informational, not a failure)
    do
        local num_isolatable = 0
        local num_isolatable_lost = 0
        for node_key, init_context_inds in pairs(init_sort_info.node_to_context_inds) do
            local node = graph.nodes[node_key]
            if node ~= nil and node.mechanic and node.type ~= "orand" then
                local final_context_inds = final_sort_info.node_to_context_inds[node_key] or {}
                for context, _ in pairs(init_context_inds) do
                    if protection.is_isolatable_context(context) and not protection.protects_isolatability(node) then
                        num_isolatable = num_isolatable + 1
                        if final_context_inds[context] == nil then
                            num_isolatable_lost = num_isolatable_lost + 1
                        end
                    end
                end
            end
        end
        log_check("unprotected isolatable mechanic contexts (not required): " .. num_isolatable .. "; lost " .. num_isolatable_lost)
    end

    table.sort(lost)
    log_check("checked " .. num_checked .. " mechanic contexts; lost " .. #lost .. " (" .. num_hard_lost .. " beyond isolatability)")
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
            if earliest ~= nil and next(final_sort_info.node_to_context_inds[final_key(node_key)] or {}) == nil and graph.nodes[final_key(node_key)] ~= nil then
                local node_type = graph.nodes[final_key(node_key)].type
                if node_type == "item" or node_type == "fluid" or node_type == "recipe" or node_type == "entity" or node_type == "technology" then
                    table.insert(newly_unreachable, {
                        key = final_key(node_key),
                        ind = earliest,
                    })
                end
            end
        end
        table.sort(newly_unreachable, function(a, b) return a.ind < b.ind end)
        for i = 1, math.min(15, #newly_unreachable) do
            log_check("root? " .. newly_unreachable[i].key .. " (orig rank " .. newly_unreachable[i].ind .. ")")
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
                log_check("walk " .. indent .. node_key .. " op=" .. tostring(node.op) .. " num_pre=" .. num_pre)
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
        log_check("lost " .. str)
    end

    -- Furnaces (the recycler too) pick their recipe by ingredient, which the logic graph doesn't model, so check the game itself
    -- Two recipes one furnace can craft that share an ingredient can't both be used there; only collisions the original game (old_data_raw) didn't have count
    local furnace_collisions = furnace_selection.new_collisions(old_data_raw)
    log_check("checked furnace recipe selection; collisions " .. #furnace_collisions)
    for _, collision in pairs(furnace_collisions) do
        log_check("furnace collision on " .. collision.ingredient .. ": " .. table.concat(collision.recipes, ", "))
    end

    local verdict = {
        ok = #lost_recipes == 0 and num_hard_lost == 0 and num_hard_missing == 0 and #furnace_collisions == 0,
        unreachable = #lost_recipes,
        lost = num_hard_lost,
        missing = num_hard_missing,
        furnace_collisions = #furnace_collisions,
    }
    log_check("verdict: " .. (verdict.ok and "ok" or "FAILED") .. " (unreachable recipes " .. verdict.unreachable .. ", lost contexts " .. verdict.lost .. ", missing promised pebbles " .. verdict.missing .. ", furnace collisions " .. verdict.furnace_collisions .. ", not counting isolatability)")
    return verdict
end

return check
