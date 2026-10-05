-- Conditional operation proofs: supply the placing item, but no other material or recipe.
-- The proof's rank is the latest external frontier pebble it needs.
-- AND takes all inputs; OR chooses the proof with the earliest frontier. Edges retain their abilities.
local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local logic = require("lib/logic/state")
local bundles = require("lib/logic/operation-bundles")

local operation = {}
local key = gutils.key

-- Several outgoing contexts of a room or forgetter share one incoming witness.
local function backing(graph, sort_info, ind)
    sort_info.operation_backings = sort_info.operation_backings or {}
    if sort_info.operation_backings[ind] == nil then
        local pebble = sort_info.sorted[ind]
        local context_type = (logic.type_info[graph.nodes[pebble.node_key].type] or {}).context
        local home = top.context_home(pebble.context)
        local abilities = top.context_abilities(pebble.context)
        local group
        if type(context_type) == "string" and home == nil then
            group = "room"
        elseif context_type == true then
            if home ~= nil then
                group = "home:" .. home
            elseif abilities == nil or string.sub(abilities, top.ISOLATABILITY, top.ISOLATABILITY) == "0" then
                group = "shared:" .. (abilities or "")
            end
        end
        local shared
        if group ~= nil then
            sort_info.operation_shared_backings = sort_info.operation_shared_backings or {}
            sort_info.operation_shared_backings[pebble.node_key] = sort_info.operation_shared_backings[pebble.node_key] or {}
            shared = sort_info.operation_shared_backings[pebble.node_key]
        end
        local result = shared ~= nil and shared[group] or nil
        if result == nil then
            result = top.path(graph, { ind }, sort_info, { immediate = true }).in_path
            -- The caller's own index is not a prerequisite of another context.
            result[ind] = nil
            if shared ~= nil then
                shared[group] = result
            end
        end
        sort_info.operation_backings[ind] = result
    end
    return sort_info.operation_backings[ind]
end

-- Read the actual build edges, including subdivision wrappers, without assuming that an item and the entity it places have the same name.
operation.items = function(graph)
    local result = {}
    for _, node in pairs(graph.nodes) do
        if node.type == "entity-build-item" and graph.nodes[key("entity-operate", node.name)] ~= nil then
            local seen = {}
            local function visit(node_key)
                if seen[node_key] ~= nil then
                    return
                end
                seen[node_key] = true
                local pre = graph.nodes[node_key]
                if pre.type == "item" then
                    result[node_key] = result[node_key] or {}
                    result[node_key][key("entity-operate", node.name)] = true
                elseif pre.type == "entity-build-item" or pre.type == "orand" or pre.type == "base" or pre.type == "head" then
                    for edge_key, _ in pairs(pre.pre) do
                        visit(graph.edges[edge_key].start)
                    end
                end
            end
            visit(key(node))
        end
    end
    return result
end

local function affected_nodes(graph, item_key, frontier)
    local affected = { [item_key] = true }
    local queue = { item_key }
    local i = 1
    while i <= #queue do
        for edge_key, _ in pairs(graph.nodes[queue[i]].dep) do
            local dep = graph.edges[edge_key].stop
            if affected[dep] == nil and not frontier(graph.nodes[dep]) then
                affected[dep] = true
                table.insert(queue, dep)
            end
        end
        i = i + 1
    end
    return affected
end

-- A proof against one sort, with item_key assumed only in the supplied context.
-- frontier(node) stops at external acquisitions; provisionally supplying the building item cannot make them earlier.
-- Context-changing nodes use the sort's actual witnesses, including its discovery rules.
operation.prover = function(graph, sort_info, item_key, context, frontier, levels, affected)
    local memo = {}
    local nci = sort_info.node_to_context_inds
    -- The affected nodes do not depend on the supplied context, so matching can reuse them.
    if levels ~= nil and affected == nil then
        affected = affected_nodes(graph, item_key, frontier)
    end
    local function prove(ind)
        if memo[ind] ~= nil then
            return memo[ind] or nil
        end
        memo[ind] = false
        local pebble = sort_info.sorted[ind]
        local node = graph.nodes[pebble.node_key]
        local answer
        local supplied = pebble.context == context
        local incoming_abilities = top.context_abilities(context)
        local needed_abilities = top.context_abilities(pebble.context)
        if incoming_abilities ~= nil and needed_abilities ~= nil and top.context_room(context) == top.context_room(pebble.context) and top.context_home(context) == top.context_home(pebble.context) then
            supplied = true
            for i = 1, #needed_abilities do
                if string.sub(needed_abilities, i, i) == "1" and string.sub(incoming_abilities, i, i) ~= "1" then
                    supplied = false
                end
            end
        end
        if pebble.node_key == item_key and supplied then
            answer = {
                rank = 0,
                leaves = {},
            }
        elseif (levels ~= nil and affected[pebble.node_key] == nil) or (pebble.node_key ~= item_key and frontier(node)) then
            answer = {
                rank = levels ~= nil and levels[ind] or ind,
                leaves = { [ind] = true },
            }
        elseif (logic.type_info[node.type] or {}).context ~= nil then
            -- A delivered copy follows the real transport witness back to the supplied item and still needs all delivery infrastructure.
            answer = {
                rank = 0,
                leaves = {},
            }
            for pre, _ in pairs(backing(graph, sort_info, ind)) do
                if pre < ind then
                    local proof = prove(pre)
                    if proof == nil then
                        answer = nil
                        break
                    end
                    answer.rank = math.max(answer.rank, proof.rank)
                    if levels == nil then
                        for leaf, _ in pairs(proof.leaves) do
                            answer.leaves[leaf] = true
                        end
                    end
                end
            end
        else
            if node.op == "AND" then
                answer = {
                    rank = 0,
                    leaves = {},
                }
            end
            local edges = {}
            for edge_key, _ in pairs(node.pre) do
                table.insert(edges, edge_key)
            end
            table.sort(edges)
            for _, edge_key in pairs(edges) do
                local edge = graph.edges[edge_key]
                local sources = { pebble.context }
                if edge.abilities ~= nil then
                    sources = top.edge_source_contexts(sort_info, edge, pebble.context)
                end
                local best
                for _, source in pairs(sources) do
                    local pre_ind = (nci[edge.start] or {})[source]
                    -- Restrict proofs to the sort's acyclic backing order.
                    if pre_ind ~= nil and pre_ind < ind then
                        local candidate = prove(pre_ind)
                        if candidate ~= nil and (best == nil or candidate.rank < best.rank) then
                            best = candidate
                        end
                    end
                end
                if node.op == "AND" then
                    if best == nil then
                        answer = nil
                        break
                    end
                    answer.rank = math.max(answer.rank, best.rank)
                    if levels == nil then
                        for leaf, _ in pairs(best.leaves) do
                            answer.leaves[leaf] = true
                        end
                    end
                elseif best ~= nil and (answer == nil or best.rank < answer.rank) then
                    answer = best
                end
            end
        end
        memo[ind] = answer or false
        return answer
    end
    return function(operation_key)
        local best
        for c, ind in pairs(nci[operation_key] or {}) do
            -- Another room is valid only through the graph's actual delivery path; supplying an item in one room doesn't supply it in the other room.
            if top.context_home(c) == nil then
                local proof = prove(ind)
                if proof ~= nil and (best == nil or proof.rank < best.rank) then
                    best = proof
                end
            end
        end
        return best
    end
end

-- Acquisition layers ignore scheduling between independently available nodes.
-- Recipes and technologies add a step; placement and operation only propagate it.
-- This uses the sort's acyclic witnesses, including its context/discovery rules.
-- The final unlock audit counts only research steps; placement also counts crafting steps to prefer positions where the other materials already arrive.
operation.levels = function(graph, sort_info, research_only)
    local cache_key = research_only == true and "operation_research_levels" or "operation_levels"
    if sort_info[cache_key] ~= nil then
        return sort_info[cache_key]
    end
    local levels = {}
    local nci = sort_info.node_to_context_inds
    for ind, pebble in pairs(sort_info.sorted) do
        local node = graph.nodes[pebble.node_key]
        local level = node.op == "AND" and 0 or math.huge
        if (logic.type_info[node.type] or {}).context ~= nil then
            level = 0
            for pre, _ in pairs(backing(graph, sort_info, ind)) do
                if pre < ind then
                    level = math.max(level, levels[pre])
                end
            end
        else
            for edge_key, _ in pairs(node.pre) do
                local edge = graph.edges[edge_key]
                local sources = { pebble.context }
                if edge.abilities ~= nil then
                    sources = top.edge_source_contexts(sort_info, edge, pebble.context)
                end
                local best = math.huge
                for _, context in pairs(sources) do
                    local pre = (nci[edge.start] or {})[context]
                    if pre ~= nil and pre < ind then
                        best = math.min(best, levels[pre])
                    end
                end
                if node.op == "AND" then
                    level = math.max(level, best)
                else
                    level = math.min(level, best)
                end
            end
        end
        if node.type == "technology" or (research_only ~= true and node.type == "recipe") then
            level = level + 1
        end
        levels[ind] = level
    end
    sort_info[cache_key] = levels
    return levels
end

-- First acquisition in a real room, excluding home contexts.
operation.first = function(sort_info, node_key)
    local first
    local context
    for c, ind in pairs(sort_info.node_to_context_inds[node_key] or {}) do
        if top.context_home(c) == nil and (first == nil or ind < first) then
            first = ind
            context = c
        end
    end
    return first, context
end

operation.matching = function(graph, sort_info, operations, research_only)
    -- Refinements try several matchings against the same graph and operation map.
    -- Keep their conditional proofs until a new sort replaces this one.
    local cache_key = research_only == true and "operation_research_matching" or "operation_matching"
    sort_info[cache_key] = sort_info[cache_key] or {}
    if sort_info[cache_key][operations] ~= nil then
        return sort_info[cache_key][operations]
    end
    local cache = {}
    local affected = {}
    local levels = next(operations) ~= nil and operation.levels(graph, sort_info, research_only) or {}
    local function frontier(node)
        return node.type == "item" or (node.type == "fluid-temperature" and (node.slot == true or node.trav == true)) or node.type == "recipe" or node.type == "technology"
    end
    local function requirement(item_key, context)
        cache[item_key] = cache[item_key] or {}
        if cache[item_key][context] == nil then
            affected[item_key] = affected[item_key] or affected_nodes(graph, item_key, frontier)
            local prove = operation.prover(graph, sort_info, item_key, context, frontier, levels, affected[item_key])
            local rank = 0
            for operation_key, _ in pairs(operations[item_key]) do
                local proof = prove(operation_key)
                if proof == nil then
                    rank = math.huge
                    break
                end
                rank = math.max(rank, proof.rank)
            end
            cache[item_key][context] = rank
        end
        return cache[item_key][context]
    end
    local rules = {
        describe = function(slot_key, item_key)
            local rank, context = operation.first(sort_info, slot_key)
            if context == nil or operations[item_key] == nil then
                return "no acquisition context"
            end
            local ready = requirement(item_key, context)
            local layer = research_only == true and " research layer " or " acquisition layer "
            return "arrival" .. layer .. levels[rank] .. ", ready" .. layer .. ready .. " @ " .. context
        end,
        allows = function(slot_key, item_key)
            if operations[item_key] == nil then
                return true
            end
            local rank, context = operation.first(sort_info, slot_key)
            return rank ~= nil and requirement(item_key, context) <= levels[rank]
        end,
        -- Operation supplies the upper bound; the ordinary reachability gate still checks every protected use.
        deadline = function(item_key, context, fallback)
            local deadline = fallback
            for operation_key, _ in pairs(operations[item_key] or {}) do
                local ind = (sort_info.node_to_context_inds[operation_key] or {})[context]
                if ind ~= nil then
                    deadline = math.max(deadline or 0, ind)
                end
            end
            return deadline
        end,
    }
    sort_info[cache_key][operations] = rules
    return rules
end

-- Add a whole operation witness to a recipe's technology prerequisites only if every prerequisite preserves its contexts and the combined graph stays acyclic.
-- An operation that needs this recipe's products cannot gate that recipe's unlock.
operation.extend_recipes = function(recipe_to_prev, recipe_name, requirements, covers)
    local function reaches(start, target, seen)
        if start == target then
            return true
        end
        if seen[start] ~= nil then
            return false
        end
        seen[start] = true
        for pre, _ in pairs(recipe_to_prev[start] or {}) do
            if reaches(pre, target, seen) then
                return true
            end
        end
        return false
    end
    for pre, _ in pairs(requirements) do
        if not covers(pre, recipe_name) or reaches(pre, recipe_name, {}) then
            return false
        end
    end
    for pre, _ in pairs(requirements) do
        recipe_to_prev[recipe_name][pre] = true
    end
    return true
end

-- Inspect the reflected game as well: later handlers can change both what an item builds and what its operation needs.
-- This reports readiness separately from reachability, comparing research layers so an extra enabled crafting step does not count as a later unlock.
-- Re-evaluate the supplied-item corridor independently of witness order: an earlier capture witness must not hide a later build with no research requirement.
operation.audit = function(graph, sort_info, label)
    local items = operation.items(graph)
    local levels = next(items) ~= nil and operation.levels(graph, sort_info, true) or {}
    local failed = {}
    local failures = {}
    local checked = 0
    for item_key, operation_keys in pairs(items) do
        local arrival, context = operation.first(sort_info, item_key)
        if arrival ~= nil then
            checked = checked + 1
            local compiled = bundles.compile(graph, item_key, operation_keys)
            local proof = bundles.prove(compiled, sort_info, context, levels)
            if proof == nil or proof.rank > levels[arrival] then
                table.insert(failed, item_key)
                failures[item_key] = {
                    arrival = arrival,
                    context = context,
                    ready = proof ~= nil and proof.rank or math.huge,
                }
            end
        end
    end
    table.sort(failed)
    log(label .. " checked " .. checked .. " building items; " .. #failed .. " precede operation readiness")
    for i = 1, math.min(10, #failed) do
        local failure = failures[failed[i]]
        log(label .. " " .. failed[i] .. "; arrival research layer " .. levels[failure.arrival] .. ", ready research layer " .. failure.ready .. " @ " .. failure.context)
        for operation_key, _ in pairs(items[failed[i]]) do
            local compiled = bundles.compile(graph, failed[i], { [operation_key] = true })
            local proof = bundles.prove(compiled, sort_info, failure.context, levels)
            local later = {}
            for leaf, _ in pairs(proof ~= nil and proof.leaves or {}) do
                if levels[leaf] > levels[failure.arrival] then
                    table.insert(later, sort_info.sorted[leaf].node_key .. " (layer " .. levels[leaf] .. ")")
                end
            end
            table.sort(later)
            log(label .. " " .. operation_key .. " later inputs: " .. table.concat(later, ", "))
        end
    end
    return failed
end

return operation
