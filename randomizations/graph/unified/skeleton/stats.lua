-- Measurement only: builds the witness skeleton on the pool sort and compares how constrained recipe ingredient
-- randomization would be under the current every-context check versus skeleton-based checks
-- Does not change randomization; all output goes to the log with the prefix SKELSTATS

local gutils = require("lib/graph/graph-utils")
local logic = require("lib/logic/init")
local build = require("randomizations/graph/unified/skeleton/build")

local key = gutils.key

local stats = {}

local function log_stat(msg)
    log("SKELSTATS " .. msg)
end

local function pct(a, b)
    if b == 0 then
        return "n/a"
    end
    return string.format("%.1f%%", 100 * a / b)
end

local function summarize(counts)
    local sorted = table.deepcopy(counts)
    table.sort(sorted)
    local total = 0
    for _, c in pairs(sorted) do
        total = total + c
    end
    local n = #sorted
    if n == 0 then
        return "n=0"
    end
    return string.format("n=%d mean=%.1f median=%d min=%d max=%d", n, total / n, sorted[math.ceil(n / 2)], sorted[1], sorted[n])
end

-- params: graph (pool graph), sort_info (pool sort), sorted_deps, dep_to_heads, head_to_handler
stats.run = function(params)
    local graph = params.graph
    local sort_info = params.sort_info
    local sorted = sort_info.sorted
    local nci = sort_info.node_to_context_inds
    local num_pebbles = #sorted

    ----------------------------------------------------------------------------------------------------
    -- Skeletons
    ----------------------------------------------------------------------------------------------------

    local mech_goals = build.mechanic_goal_inds(graph, sort_info)
    local mech_skel = build.skeleton(graph, sort_info, mech_goals)
    local somewhere_goals = build.somewhere_goal_inds(graph, sort_info, mech_skel.in_skeleton)
    local full_goals = table.deepcopy(mech_goals)
    for _, ind in pairs(somewhere_goals) do
        table.insert(full_goals, ind)
    end
    local full_skel = build.skeleton(graph, sort_info, full_goals)

    local mech_nodes = {}
    local num_mech_nodes = 0
    for _, ind in pairs(mech_goals) do
        local node_key = sorted[ind].node_key
        if not mech_nodes[node_key] then
            mech_nodes[node_key] = true
            num_mech_nodes = num_mech_nodes + 1
        end
    end

    log_stat("pebbles total=" .. num_pebbles .. " mechanic_nodes=" .. num_mech_nodes .. " mechanic_goal_pebbles=" .. #mech_goals)
    for _, variant in pairs({ { "mech", mech_skel }, { "mech+somewhere", full_skel } }) do
        local name, skel = variant[1], variant[2]
        local nodes_in = {}
        local type_counts = {}
        local context_counts = {}
        for _, ind in pairs(skel.inds) do
            local pebble = sorted[ind]
            nodes_in[pebble.node_key] = true
            local node_type = graph.nodes[pebble.node_key].type
            type_counts[node_type] = (type_counts[node_type] or 0) + 1
            context_counts[pebble.context] = (context_counts[pebble.context] or 0) + 1
        end
        local num_nodes_in = 0
        for _, _ in pairs(nodes_in) do
            num_nodes_in = num_nodes_in + 1
        end
        log_stat("skeleton[" .. name .. "] pebbles=" .. #skel.inds .. " (" .. pct(#skel.inds, num_pebbles) .. " of all) nodes=" .. num_nodes_in)
        local total_context_counts = {}
        for _, pebble in pairs(sorted) do
            total_context_counts[pebble.context] = (total_context_counts[pebble.context] or 0) + 1
        end
        local context_strs = {}
        for context, total in pairs(total_context_counts) do
            table.insert(context_strs, context .. "=" .. (context_counts[context] or 0) .. "/" .. total)
        end
        table.sort(context_strs)
        log_stat("skeleton[" .. name .. "] by context: " .. table.concat(context_strs, ", "))
        local type_strs = {}
        for node_type, count in pairs(type_counts) do
            table.insert(type_strs, { node_type, count })
        end
        table.sort(type_strs, function(a, b) return a[2] > b[2] end)
        local type_out = {}
        for i = 1, math.min(12, #type_strs) do
            table.insert(type_out, type_strs[i][1] .. "=" .. type_strs[i][2])
        end
        log_stat("skeleton[" .. name .. "] top types: " .. table.concat(type_out, ", "))
    end

    ----------------------------------------------------------------------------------------------------
    -- Recipe ingredient constraints
    ----------------------------------------------------------------------------------------------------

    -- Recipes randomized by the recipe ingredients handler, and every (vanilla) ingredient base as the candidate pool
    local recipes = {}
    local bases = {}
    for _, dep in pairs(params.sorted_deps) do
        local node = graph.nodes[dep]
        if node.type == "recipe" then
            local is_claimed = false
            for _, head_key in pairs(params.dep_to_heads[dep] or {}) do
                if params.head_to_handler[head_key].id == "recipe_ingredients" then
                    is_claimed = true
                    table.insert(bases, graph.nodes[head_key].old_base)
                end
            end
            if is_claimed then
                table.insert(recipes, dep)
            end
        end
    end
    -- base --> ingredient node key
    local base_to_ing = {}
    local ing_list = {}
    local ing_seen = {}
    for _, base_key in pairs(bases) do
        local ing_node = gutils.prenodes(graph, graph.nodes[base_key])[1]
        base_to_ing[base_key] = key(ing_node)
        if not ing_seen[key(ing_node)] then
            ing_seen[key(ing_node)] = true
            table.insert(ing_list, key(ing_node))
        end
    end
    local ing_to_bases = {}
    for base_key, ing_key in pairs(base_to_ing) do
        ing_to_bases[ing_key] = ing_to_bases[ing_key] or {}
        table.insert(ing_to_bases[ing_key], base_key)
    end

    local function recipe_contexts(recipe_key, in_skeleton)
        local contexts = {}
        for context, ind in pairs(nci[recipe_key]) do
            if in_skeleton == nil or in_skeleton[ind] then
                table.insert(contexts, context)
            end
        end
        return contexts
    end

    -- Current rule in recipe-ingredients.lua: base earlier than recipe in every context, nil counting as "at the end"
    local function today_valid(recipe_key, base_key)
        for context, _ in pairs(logic.contexts) do
            local ind1 = nci[base_key][context] or (num_pebbles + 1)
            local ind2 = nci[recipe_key][context] or (num_pebbles + 2)
            if not (ind1 < ind2) then
                return false
            end
        end
        return true
    end
    -- Same rule but using the ingredient's own ranks rather than its base's
    local function today_item_rank_valid(recipe_key, ing_key)
        for context, _ in pairs(logic.contexts) do
            local ind1 = nci[ing_key][context] or (num_pebbles + 1)
            local ind2 = nci[recipe_key][context] or (num_pebbles + 2)
            if not (ind1 < ind2) then
                return false
            end
        end
        return true
    end
    -- Ingredient reachable earlier than the recipe in each given context (optionally only via skeleton pebbles)
    -- With a vanilla sort and nothing resolved yet, this is exactly "promotable"
    local function earlier_in_contexts(recipe_key, ing_key, contexts, in_skeleton)
        for _, context in pairs(contexts) do
            local ind = nci[ing_key][context]
            if ind == nil or ind >= nci[recipe_key][context] then
                return false
            end
            if in_skeleton ~= nil and not in_skeleton[ind] then
                return false
            end
        end
        return true
    end

    local rules = {
        { name = "today", fn = function(r, ing)
            for _, base_key in pairs(ing_to_bases[ing]) do
                if today_valid(r, base_key) then
                    return true
                end
            end
            return false
        end },
        { name = "today-item-ranks", fn = function(r, ing) return today_item_rank_valid(r, ing) end },
        { name = "promote[mech]", fn = function(r, ing) return earlier_in_contexts(r, ing, recipe_contexts(r, mech_skel.in_skeleton)) end },
        { name = "skel-only[mech]", fn = function(r, ing) return earlier_in_contexts(r, ing, recipe_contexts(r, mech_skel.in_skeleton), mech_skel.in_skeleton) end },
        { name = "promote[mech+somewhere]", fn = function(r, ing) return earlier_in_contexts(r, ing, recipe_contexts(r, full_skel.in_skeleton)) end },
        { name = "skel-only[mech+somewhere]", fn = function(r, ing) return earlier_in_contexts(r, ing, recipe_contexts(r, full_skel.in_skeleton), full_skel.in_skeleton) end },
    }

    -- Context requirements per recipe
    local num_pairs_all, num_pairs_mech, num_pairs_full = 0, 0, 0
    local num_no_mech_ctx, num_no_full_ctx = 0, 0
    for _, r in pairs(recipes) do
        local n_all = #recipe_contexts(r)
        local n_mech = #recipe_contexts(r, mech_skel.in_skeleton)
        local n_full = #recipe_contexts(r, full_skel.in_skeleton)
        num_pairs_all = num_pairs_all + n_all
        num_pairs_mech = num_pairs_mech + n_mech
        num_pairs_full = num_pairs_full + n_full
        if n_mech == 0 then
            num_no_mech_ctx = num_no_mech_ctx + 1
        end
        if n_full == 0 then
            num_no_full_ctx = num_no_full_ctx + 1
        end
    end
    log_stat("recipes=" .. #recipes .. " candidate_ingredients=" .. #ing_list .. " ingredient_slots=" .. #bases)
    local ing_type_counts = {}
    local ing_type_example = {}
    for _, ing in pairs(ing_list) do
        local node_type = graph.nodes[ing].type
        ing_type_counts[node_type] = (ing_type_counts[node_type] or 0) + 1
        ing_type_example[node_type] = ing_type_example[node_type] or ing
    end
    for node_type, count in pairs(ing_type_counts) do
        log_stat("candidate ingredient type " .. node_type .. "=" .. count .. " e.g. " .. ing_type_example[node_type])
    end
    -- Fluid ingredient slots in vanilla recipes that are randomized, and whether their edge was claimed
    local claimed_fluid_ings = {}
    for _, ing in pairs(ing_list) do
        local ing_node = graph.nodes[ing]
        if ing_node.type == "fluid-temperature-range" then
            claimed_fluid_ings[gutils.deconstruct(ing_node.name).type] = true
        else
            claimed_fluid_ings[ing_node.name] = true
        end
    end
    local unclaimed = {}
    for _, r in pairs(recipes) do
        for _, ing in pairs(unified_starting_data_raw.recipe[graph.nodes[r].name].ingredients or {}) do
            if ing.type == "fluid" and not claimed_fluid_ings[ing.name] then
                unclaimed[ing.name] = true
            end
        end
    end
    local unclaimed_list = {}
    for name, _ in pairs(unclaimed) do
        table.insert(unclaimed_list, name)
    end
    table.sort(unclaimed_list)
    log_stat("fluid ingredients of randomized recipes missing from candidates: " .. table.concat(unclaimed_list, ","))
    local concrete_key = key("recipe", "concrete")
    if graph.nodes[concrete_key] ~= nil then
        local pre_strs = {}
        for _, prenode in pairs(gutils.prenodes(graph, graph.nodes[concrete_key])) do
            local extra = ""
            if prenode.type == "head" then
                extra = " <- " .. key(gutils.prenodes(graph, graph.nodes[prenode.old_base])[1])
            end
            table.insert(pre_strs, key(prenode) .. extra)
        end
        log_stat("concrete prenodes: " .. table.concat(pre_strs, " ; "))
    end
    log_stat("constrained (recipe, context) pairs: today=" .. num_pairs_all .. " mech=" .. num_pairs_mech .. " mech+somewhere=" .. num_pairs_full)
    log_stat("recipes with no constrained context: mech=" .. num_no_mech_ctx .. " mech+somewhere=" .. num_no_full_ctx)

    local function vanilla_fluid_slots(recipe_name)
        local recipe = unified_starting_data_raw.recipe[recipe_name]
        local num_fluids, num_items = 0, 0
        for _, ing in pairs(recipe.ingredients or {}) do
            if ing.type == "fluid" then
                num_fluids = num_fluids + 1
            else
                num_items = num_items + 1
            end
        end
        return num_fluids, num_items
    end

    local watch = {
        [key("recipe", "concrete")] = true,
    }
    local water_key = key("fluid", "water")
    for r, _ in pairs(watch) do
        if nci[r] ~= nil then
            local strs = {}
            for context, _ in pairs(logic.contexts) do
                local r_ind = nci[r][context]
                local w_ind = nci[water_key] and nci[water_key][context]
                local mark = ""
                if r_ind ~= nil and mech_skel.in_skeleton[r_ind] then
                    mark = mark .. " [mech-skel]"
                end
                if r_ind ~= nil and full_skel.in_skeleton[r_ind] then
                    mark = mark .. " [full-skel]"
                end
                table.insert(strs, context .. ": recipe=" .. tostring(r_ind) .. " water=" .. tostring(w_ind) .. mark)
            end
            table.sort(strs)
            log_stat("watch " .. r .. " ranks: " .. table.concat(strs, " | "))
        end
    end
    for _, rule in pairs(rules) do
        local counts = {}
        local num_zero = 0
        local num_fluid_starved = 0
        local num_item_starved = 0
        for _, r in pairs(recipes) do
            local num_items, num_fluids = 0, 0
            local fluid_names = {}
            for _, ing in pairs(ing_list) do
                if rule.fn(r, ing) then
                    if graph.nodes[ing].type == "fluid" or graph.nodes[ing].type == "fluid-temperature-range" then
                        num_fluids = num_fluids + 1
                        table.insert(fluid_names, graph.nodes[ing].name)
                    else
                        num_items = num_items + 1
                    end
                end
            end
            table.insert(counts, num_items + num_fluids)
            if num_items + num_fluids == 0 then
                num_zero = num_zero + 1
            end
            local fluid_slots, item_slots = vanilla_fluid_slots(graph.nodes[r].name)
            if num_fluids < fluid_slots then
                num_fluid_starved = num_fluid_starved + 1
            end
            if num_items < item_slots then
                num_item_starved = num_item_starved + 1
            end
            if watch[r] then
                table.sort(fluid_names)
                log_stat("watch " .. r .. " [" .. rule.name .. "] contexts(today/mech/full)=" .. #recipe_contexts(r) .. "/" .. #recipe_contexts(r, mech_skel.in_skeleton) .. "/" .. #recipe_contexts(r, full_skel.in_skeleton) .. " items=" .. num_items .. " fluids=" .. num_fluids .. " {" .. table.concat(fluid_names, ",") .. "}")
            end
        end
        log_stat("rule[" .. rule.name .. "] candidates per recipe: " .. summarize(counts) .. " zero=" .. num_zero .. " fluid_starved=" .. num_fluid_starved .. " item_starved=" .. num_item_starved)
    end
end

return stats
