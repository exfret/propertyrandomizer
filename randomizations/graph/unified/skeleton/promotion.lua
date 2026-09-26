-- Promotion keeps mechanic contexts and recipe reachability during randomization
-- See docs/glossary.md for terminology (promised pebble, backing, rank, promotion, fallback bundle)
--
-- A pebble is identified by its index (rank) in the sort, and it's *established* if it has a backing of established pebbles with strictly lower rank in the current random graph
-- In that graph, resolved recipes use their new ingredients and unresolved recipes use their vanilla ingredients (their fallback bundle)
-- Promised pebbles are established by construction, so the search stops at them
-- Promising an unresolved recipe pebble (r, c) promises its vanilla ingredient pebbles in c too (they're in its backing), which keeps r's vanilla ingredients a valid fallback when r is finally resolved
-- Since ranks strictly decrease along backings, induction on rank shows every promised pebble is reachable at the end

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/consistent-sort")
local logic = require("lib/logic/init")

local key = gutils.key

local promotion = {}

local function is_ingredient_owner_type(node_type)
    return node_type == "item" or node_type == "fluid-temperature-range"
end

-- params: graph (the random graph, or first pass's split graph when first pass ran), head_to_base (generic handlers' choices), pool_sort_info (optional, for reporting)
-- With first pass, the split graph must be used: it's the model reflection builds (e.g. item identities swapped), so reasoning over the unsplit graph would be about a different game
promotion.new = function(params)
    local head_to_base = params.head_to_base or {}

    -- Ranks come from a random sort of the current hybrid graph: generic handlers' choices applied, recipe ingredients still vanilla
    -- The pool sort is of the vanilla graph, which generic handlers have already rewired, so its ranks don't fit
    -- Heads chosen by a generic handler get that base, other cut heads get their vanilla base, and connected heads that no handler reassigned (like first pass's own slot/trav heads) stay as they are
    local graph = table.deepcopy(params.graph)
    for node_key, node in pairs(graph.nodes) do
        if node.type == "head" and node.name ~= "" then
            local new_base = head_to_base[node_key]
            if new_base ~= nil then
                for pre, _ in pairs(table.deepcopy(node.pre)) do
                    gutils.remove_edge(graph, pre)
                end
                gutils.add_edge(graph, new_base, node_key)
            elseif next(node.pre) == nil then
                gutils.add_edge(graph, node.old_base, node_key)
            end
        end
    end
    local sort_info = top.sort(graph, nil, nil, { choose_randomly = true })
    local sorted = sort_info.sorted
    local nci = sort_info.node_to_context_inds

    local state = {
        -- ind --> true
        is_promised = {},
        num_promised = 0,
        -- recipe node key --> list of ingredient owner node keys
        resolved = {},
    }

    -- recipe node key --> { fixed = list of non-ingredient prenode keys, vanilla_owners = list of ingredient owner keys }
    -- Ingredient heads are the subdivided item/fluid --> recipe edges; they are cut in the random graph
    local recipe_info = {}
    local function get_recipe_info(recipe_key)
        if recipe_info[recipe_key] == nil then
            local info = {
                fixed = {},
                vanilla_owners = {},
                vanilla_owner_by_material = {},
            }
            for _, prenode in pairs(gutils.prenodes(graph, graph.nodes[recipe_key])) do
                local owner
                if prenode.type == "head" and prenode.old_base ~= nil then
                    local base = graph.nodes[prenode.old_base]
                    local base_pre = gutils.prenodes(graph, base)[1]
                    if base_pre ~= nil and is_ingredient_owner_type(base_pre.type) then
                        owner = base_pre
                    end
                end
                if owner ~= nil then
                    table.insert(info.vanilla_owners, key(owner))
                    local material_key
                    if owner.type == "fluid-temperature-range" then
                        material_key = key("fluid", gutils.deconstruct(owner.name).type)
                    else
                        material_key = key(owner)
                    end
                    info.vanilla_owner_by_material[material_key] = key(owner)
                else
                    table.insert(info.fixed, key(prenode))
                end
            end
            recipe_info[recipe_key] = info
        end
        return recipe_info[recipe_key]
    end

    -- Establishability cache; only valid until the next resolve/commit
    local memo = {}
    local support = {}
    local function clear_cache()
        memo = {}
        support = {}
    end

    local function pre_ind(pre_key, context)
        local context_inds = nci[pre_key]
        if context_inds == nil then
            return nil
        end
        return context_inds[context]
    end

    -- Prereq keys of a node in the current random graph
    -- Recipe ingredient heads are replaced by ingredient owners (new if resolved, vanilla otherwise)
    -- Other cut heads get the base chosen by their generic handler, or their vanilla base if none was chosen
    local function get_pre_keys(node)
        local pre_keys = {}
        if node.type == "recipe" then
            local info = get_recipe_info(key(node))
            for _, pre_key in pairs(info.fixed) do
                table.insert(pre_keys, pre_key)
            end
            for _, owner_key in pairs(state.resolved[key(node)] or info.vanilla_owners) do
                table.insert(pre_keys, owner_key)
            end
        elseif node.type == "head" and next(node.pre) == nil then
            table.insert(pre_keys, head_to_base[key(node)] or node.old_base)
        else
            for _, prenode in pairs(gutils.prenodes(graph, node)) do
                table.insert(pre_keys, key(prenode))
            end
        end
        return pre_keys
    end

    local establish

    -- Tries to find a backing for pebble ind among the given prereq keys in the given context
    -- Returns the list of support inds, or nil if there's none (op is "AND" or "OR")
    local function back_with(ind, pre_keys, op, context)
        if op == "AND" then
            local inds = {}
            for _, pre_key in pairs(pre_keys) do
                local i = pre_ind(pre_key, context)
                if i == nil or i >= ind or not establish(i) then
                    return nil
                end
                table.insert(inds, i)
            end
            return inds
        else
            -- Earliest provider first, falling back to later providers
            local candidates = {}
            for _, pre_key in pairs(pre_keys) do
                local i = pre_ind(pre_key, context)
                if i ~= nil and i < ind then
                    table.insert(candidates, i)
                end
            end
            table.sort(candidates)
            for _, i in pairs(candidates) do
                if establish(i) then
                    return { i }
                end
            end
            return nil
        end
    end

    local function compute_support(ind)
        local pebble = sorted[ind]
        local node = graph.nodes[pebble.node_key]

        local pre_keys = get_pre_keys(node)

        if #pre_keys == 0 then
            -- Sources: AND with no prereqs is vacuously satisfied, OR with none never is
            if node.op == "AND" then
                return {}
            end
            return nil
        end

        if logic.type_info[node.type].context == nil then
            return back_with(ind, pre_keys, node.op, pebble.context)
        end

        -- Forgetters and emitters send their context regardless of incoming context, so any incoming context works
        -- Try contexts in order of how early their prereqs are (mirrors top.path)
        local contexts = {}
        for context, _ in pairs(logic.contexts) do
            local score
            for _, pre_key in pairs(pre_keys) do
                local i = pre_ind(pre_key, context)
                if node.op == "AND" then
                    if i == nil then
                        score = nil
                        break
                    end
                    score = math.max(score or 0, i)
                elseif i ~= nil and (score == nil or i < score) then
                    score = i
                end
            end
            if score ~= nil and score < ind then
                table.insert(contexts, {
                    context = context,
                    score = score,
                })
            end
        end
        table.sort(contexts, function(a, b) return a.score < b.score end)
        for _, entry in pairs(contexts) do
            local inds = back_with(ind, pre_keys, node.op, entry.context)
            if inds ~= nil then
                return inds
            end
        end
        return nil
    end

    establish = function(ind)
        if state.is_promised[ind] then
            return true
        end
        if memo[ind] ~= nil then
            return memo[ind]
        end
        -- Ranks strictly decrease along backings, so there are no cycles; this is just a guard
        memo[ind] = false
        local inds = compute_support(ind)
        if inds ~= nil then
            memo[ind] = true
            support[ind] = inds
        end
        return memo[ind]
    end

    -- Promise ind and its whole (cached) backing
    local function commit(ind)
        local stack = { ind }
        while #stack > 0 do
            local curr = table.remove(stack)
            if not state.is_promised[curr] then
                if support[curr] == nil then
                    error("Committing pebble without a backing")
                end
                state.is_promised[curr] = true
                state.num_promised = state.num_promised + 1
                for _, i in pairs(support[curr]) do
                    table.insert(stack, i)
                end
            end
        end
    end

    ----------------------------------------------------------------------------------------------------
    -- Public interface
    ----------------------------------------------------------------------------------------------------

    -- Promise every mechanic pebble that can currently be established; returns list of pebble inds that couldn't be
    state.promise_mechanics = function()
        -- Report mechanic contexts the generic handlers already lost (reachable in the pool sort but not the hybrid graph)
        if params.pool_sort_info ~= nil then
            local num_lost = 0
            for node_key, context_inds in pairs(params.pool_sort_info.node_to_context_inds) do
                local node = graph.nodes[node_key]
                if node ~= nil and node.mechanic and node.type ~= "orand" then
                    for context, _ in pairs(context_inds) do
                        if nci[node_key] == nil or nci[node_key][context] == nil then
                            num_lost = num_lost + 1
                            log("Promotion: mechanic context lost before recipe randomization: " .. node_key .. " @ " .. context)
                        end
                    end
                end
            end
            state.num_lost_before = num_lost
            -- Same for recipes, which must all stay reachable
            local num_recipes_lost = 0
            for node_key, context_inds in pairs(params.pool_sort_info.node_to_context_inds) do
                local node = graph.nodes[node_key]
                if node ~= nil and node.type == "recipe" and next(context_inds) ~= nil and next(nci[node_key] or {}) == nil then
                    num_recipes_lost = num_recipes_lost + 1
                    log("Promotion: recipe lost before recipe randomization: " .. node_key)
                end
            end
            state.num_recipes_lost_before = num_recipes_lost
        end
        local failed = {}
        for ind, pebble in pairs(sorted) do
            local node = graph.nodes[pebble.node_key]
            if node ~= nil and node.mechanic and node.type ~= "orand" then
                if establish(ind) then
                    commit(ind)
                else
                    table.insert(failed, ind)
                end
            end
        end
        if #failed > 0 then
            state.explain(failed[1])
        end
        clear_cache()
        return failed
    end

    -- Debugging: follow a failed pebble down to where its backing search actually fails, logging each step
    state.explain = function(ind, max_depth)
        max_depth = max_depth or 40
        local curr = ind
        for depth = 1, max_depth do
            local pebble = sorted[curr]
            local node = graph.nodes[pebble.node_key]
            local pre_keys = get_pre_keys(node)
            local strs = {}
            local next_ind
            for _, pre_key in pairs(pre_keys) do
                local i = pre_ind(pre_key, pebble.context)
                local status
                if i == nil then
                    status = "no-pebble"
                elseif i >= curr then
                    status = "later(" .. i .. ")"
                elseif establish(i) then
                    status = "ok(" .. i .. ")"
                else
                    status = "FAIL(" .. i .. ")"
                    if next_ind == nil then
                        next_ind = i
                    end
                end
                table.insert(strs, pre_key .. "=" .. status)
            end
            log("EXPLAIN " .. depth .. ": [" .. curr .. "] " .. pebble.node_key .. " @ " .. pebble.context .. " op=" .. tostring(node.op) .. " ctxtype=" .. tostring(logic.type_info[node.type].context) .. " pres={" .. table.concat(strs, "; ") .. "}")
            if next_ind == nil then
                return
            end
            curr = next_ind
        end
    end

    -- Logs, per context, which of the recipe's prereqs can't be established before it
    local function log_recipe_prereqs(recipe_key)
        for context, recipe_ind in pairs(nci[recipe_key] or {}) do
            local strs = {}
            for _, pre_key in pairs(get_pre_keys(graph.nodes[recipe_key])) do
                local i = pre_ind(pre_key, context)
                local status
                if i == nil then
                    status = "none"
                elseif i >= recipe_ind then
                    status = "later"
                elseif establish(i) then
                    status = "ok"
                else
                    status = "FAIL"
                end
                table.insert(strs, pre_key .. "=" .. status)
            end
            log("Promotion: " .. recipe_key .. " @ " .. context .. " (rank " .. recipe_ind .. "): " .. table.concat(strs, "; "))
        end
    end

    -- Earliest context in which the recipe can currently be established with its current ingredients, or nil
    local function earliest_establishable_context(recipe_key)
        local entries = {}
        for context, ind in pairs(nci[recipe_key] or {}) do
            table.insert(entries, {
                context = context,
                ind = ind,
            })
        end
        table.sort(entries, function(a, b) return a.ind < b.ind end)
        for _, entry in pairs(entries) do
            if establish(entry.ind) then
                return entry.context
            end
        end
        return nil
    end

    -- Whether the recipe was reachable when promotion started (i.e. not already lost by earlier randomization steps)
    state.initially_reachable = function(recipe_key)
        return next(nci[recipe_key] or {}) ~= nil
    end

    -- Promise every recipe that is reachable in exactly one context, returning how many were promised
    -- Anchoring recipes lazily keeps flexibility in which context they end up in, but with only one option there's nothing to choose
    -- Waiting would only let earlier choices (e.g. another handler changing something only that context has) cut the recipe off before its turn
    state.promise_single_context_recipes = function()
        local num_promised_recipes = 0
        for node_key, node in pairs(graph.nodes) do
            if node.type == "recipe" then
                local only_ind
                local num_contexts = 0
                for _, ind in pairs(nci[node_key] or {}) do
                    num_contexts = num_contexts + 1
                    only_ind = ind
                end
                if num_contexts == 1 and not state.is_promised[only_ind] and establish(only_ind) then
                    commit(only_ind)
                    num_promised_recipes = num_promised_recipes + 1
                end
            end
        end
        clear_cache()
        return num_promised_recipes
    end

    -- Contexts in which all of the recipe's new ingredients must be established
    -- These are its promised contexts; a recipe with none gets one anchor context chosen now, the earliest it can currently be established in with its vanilla ingredients, so they remain a valid fallback there
    -- Ingredients are always checked against these explicit contexts, since ingredients checked separately against "some context" could share none, and every recipe must stay reachable
    -- Returns an empty list only if the recipe can't be reached anywhere anymore
    state.required_contexts = function(recipe_key)
        local contexts = {}
        for context, ind in pairs(nci[recipe_key] or {}) do
            if state.is_promised[ind] then
                table.insert(contexts, context)
            end
        end
        if #contexts == 0 then
            local anchor = earliest_establishable_context(recipe_key)
            if anchor ~= nil then
                table.insert(contexts, anchor)
            else
                log_recipe_prereqs(recipe_key)
            end
        end
        return contexts
    end

    -- Whether ingredient owner could be promoted in each required context before the recipe
    state.candidate_ok = function(recipe_key, owner_key, required_contexts)
        assert(#required_contexts > 0, "candidate_ok needs required contexts (from required_contexts) for " .. recipe_key)
        for _, context in pairs(required_contexts) do
            local i = pre_ind(owner_key, context)
            if i == nil or i >= nci[recipe_key][context] or not establish(i) then
                return false
            end
        end
        return true
    end

    state.vanilla_owners = function(recipe_key)
        return get_recipe_info(recipe_key).vanilla_owners
    end

    -- Owner key of the vanilla ingredient edge for this material, or nil if the ingredient isn't a randomized edge
    state.vanilla_owner = function(recipe_key, material)
        return get_recipe_info(recipe_key).vanilla_owner_by_material[key(material.type, material.name)]
    end

    -- Record the recipe's new ingredient owners, then promise them and the recipe itself in each required context
    -- Candidates must have passed candidate_ok (or be the vanilla fallback) since the last resolve
    state.resolve = function(recipe_key, owner_keys, required_contexts)
        assert(#required_contexts > 0, "resolve needs required contexts (from required_contexts) for " .. recipe_key)
        for _, context in pairs(required_contexts) do
            for _, owner_key in pairs(owner_keys) do
                local i = pre_ind(owner_key, context)
                if i == nil or i >= nci[recipe_key][context] or not establish(i) then
                    error("Resolving recipe " .. recipe_key .. " with unestablished ingredient " .. owner_key .. " in " .. context)
                end
                commit(i)
            end
        end
        state.resolved[recipe_key] = owner_keys
        clear_cache()

        -- Already promised for mechanic contexts; this is what anchors the rest
        for _, context in pairs(required_contexts) do
            local ind = nci[recipe_key][context]
            if not establish(ind) then
                log_recipe_prereqs(recipe_key)
                error("Recipe " .. recipe_key .. " can't be established in required context " .. context .. " after resolving")
            end
            commit(ind)
        end
        clear_cache()
    end

    -- Checks a candidate base for a generic handler head (e.g. energy source --> entity-operate)
    -- The base must be establishable before the head in each required context of the head's dependent (from required_contexts(dep))
    state.head_candidate_ok = function(head_key, base_key, required_contexts)
        assert(#required_contexts > 0, "head_candidate_ok needs required contexts (from required_contexts) for " .. head_key)
        for _, context in pairs(required_contexts) do
            local i = pre_ind(base_key, context)
            local head_ind = pre_ind(head_key, context)
            if i == nil or head_ind == nil or i >= head_ind or not establish(i) then
                return false
            end
        end
        return true
    end

    -- Point head at its chosen base, then promise the base, the head and the head's dependent in each required context
    -- The base must have passed head_candidate_ok (or be the head's vanilla base) since the last resolve
    -- With no required contexts (dependent not reachable anyway), this only repoints the head
    state.resolve_head = function(head_key, base_key, required_contexts)
        for _, context in pairs(required_contexts) do
            local i = pre_ind(base_key, context)
            local head_ind = pre_ind(head_key, context)
            if i == nil or head_ind == nil or i >= head_ind or not establish(i) then
                error("Resolving head " .. head_key .. " with unestablished base " .. base_key .. " in " .. context)
            end
            commit(i)
        end
        local head = graph.nodes[head_key]
        for pre, _ in pairs(table.deepcopy(head.pre)) do
            gutils.remove_edge(graph, pre)
        end
        gutils.add_edge(graph, base_key, head_key)
        clear_cache()

        local dep_key = key(gutils.unique_depnode(graph, head))
        for _, context in pairs(required_contexts) do
            for _, node_key in pairs({ head_key, dep_key }) do
                local ind = nci[node_key][context]
                if not establish(ind) then
                    error("Can't establish " .. node_key .. " in " .. context .. " after resolving head " .. head_key)
                end
                commit(ind)
            end
        end
        clear_cache()
    end

    -- Every promised pebble with its rank, in rank order (for checking the model against the final game)
    state.promised_pebbles = function()
        local pebbles = {}
        for ind, _ in pairs(state.is_promised) do
            table.insert(pebbles, {
                node_key = sorted[ind].node_key,
                context = sorted[ind].context,
                rank = ind,
            })
        end
        table.sort(pebbles, function(a, b) return a.rank < b.rank end)
        return pebbles
    end

    -- Anchor every initially reachable recipe that has no promised pebble yet (e.g. recipes the handler never randomizes)
    -- Returns keys of recipes that can't be reached anywhere anymore
    state.anchor_remaining_recipes = function()
        local unreachable = {}
        for node_key, node in pairs(graph.nodes) do
            if node.type == "recipe" and state.initially_reachable(node_key) then
                local has_promise = false
                for _, ind in pairs(nci[node_key]) do
                    if state.is_promised[ind] then
                        has_promise = true
                        break
                    end
                end
                if not has_promise then
                    local context = earliest_establishable_context(node_key)
                    if context ~= nil then
                        commit(nci[node_key][context])
                    else
                        log_recipe_prereqs(node_key)
                        table.insert(unreachable, node_key)
                    end
                end
            end
        end
        clear_cache()
        table.sort(unreachable)
        return unreachable
    end

    return state
end

return promotion
