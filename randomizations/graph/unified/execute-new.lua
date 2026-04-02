-- Fundamental differences:
--  * USE KEYS INTO THE GRAPH (no passing graph nodes, since we have so many different graphs by copy, not reference)
--  * Use the new graph library functions
--  * Use correct terminology

-- TODO: Some tests targeting areas where I might have forgotten about orands
-- TODO: Do a more thorough look through handlers for terminology changes etc.

local DO_FIRST_PASS = true
-- Whether to only test relative ordering of first context, and just whether it can be gotten on each planet
-- Maybe could cause softlocks?
-- CRITICAL TODO: Think about this more!
local DO_TESTS = false
local ONLY_TEST_FIRST_CONTEXT_ORDER = true
-- CRITICAL TODO: Make this a config entry/setting so we can switch it better in recipe-tech-unlocks as well
local SPECIAL_RECIPE_TECH_UNLOCK_VALIDATION = true
local SWITCH_PLANETS = false
local REPORT_NUM_TECH_PREREQS = true

local rng = require("lib/random/rng")
local gutils = require("new-lib/graph/graph-utils")
local top = require("new-lib/graph/consistent-sort")
local logic = require("new-lib/logic/init")
local first_pass = require("randomizations/graph/unified/first-pass-new")
local test_graph_invariants = require("tests/graph-invariants")
local test_sort = require("tests/consistent-sort")

local key = gutils.key

local unified = {}

local all_handler_ids = require("helper-tables/handler-ids")
local handler_ids = {}

-- CRITICAL TODO: REMOVE!
config.unified = {
    ["recipe-category"] = true,
    ["recipe-ingredients"] = true,
    ["recipe-tech-unlocks"] = true,
    ["spoiling"] = true,
    ["tech-prereqs"] = true,
    ["tech-science-packs"] = true,
    ["entity-autoplace"] = true,
}

-- for _, id in pairs(all_handler_ids) do
for id, _ in pairs(config.unified) do
    if config.unified[id] then
        table.insert(handler_ids, id)
    end
    randomization_info.options.unified[id] = {
        blacklisted_pre = {},
        blacklisted_dep = {},
    }
end

unified.execute = function()
    ----------------------------------------------------------------------------------------------------
    -- HANDLER LOADING
    ----------------------------------------------------------------------------------------------------

    -- Load handlers
    local default_handler = require("randomizations/graph/unified/handlers-new/default")
    local handlers = {}
    for _, handler_id in pairs(handler_ids) do
        local handler = require("randomizations/graph/unified/handlers-new/" .. handler_id)

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

    -- First, save old data
    -- We can't call this old_data_raw because that's for the *very* initial data
    -- Make it a global so we don't have to pass it everywhere
    unified_starting_data_raw = table.deepcopy(data.raw)

    -- data.raw preprocessing if necessary
    for _, handler in pairs(handlers) do
        handler.preprocess()
    end

    -- Logic building
    logic.build()
    test_graph_invariants.test(logic.graph)
    local init_graph = logic.graph
    test_graph_invariants.test(init_graph)

    local spoofed_graph = table.deepcopy(init_graph)
    -- Spoofing
    for _, handler in pairs(handlers) do
        handler.spoof(spoofed_graph)
    end
    test_graph_invariants.test(spoofed_graph)
    gutils.make_orands(spoofed_graph)
    test_graph_invariants.test(spoofed_graph)

    ----------------------------------------------------------------------------------------------------
    -- CLAIMING
    ----------------------------------------------------------------------------------------------------

    local sort_for_claiming = top.sort(spoofed_graph, nil, nil, { choose_randomly = true })
    local subdiv_graph = table.deepcopy(spoofed_graph)

    local added_to_deps = {}
    local sorted_deps = {}
    local shuffled_prereqs = {}
    local post_shuffled_prereqs = {}
    local dep_to_heads = {}
    local head_to_handler = {}
    for ind, pebble in pairs(sort_for_claiming.sorted) do
        -- Get node from subdiv_graph
        local node_key = pebble.node_key
        local node = subdiv_graph.nodes[node_key]

        if node.op == "AND" and node.type ~= "base" then
            if not added_to_deps[node_key] then
                added_to_deps[node_key] = true
                -- Just make sure this isn't spoofed
                if not node.spoof then
                    table.insert(sorted_deps, node_key)
                end

                dep_to_heads[node_key] = {}

                local subdivide_info = {}
                for pre, _ in pairs(node.pre) do
                    local prereq_node = gutils.prenode(subdiv_graph, pre)
                    -- Get the "true" node in case node is an orand
                    local orand_parent = subdiv_graph.nodes[subdiv_graph.orand_to_parent[node_key]]
                    local claimed = false

                    for handler_id, handler in pairs(handlers) do
                        local num_copies = handler.claim(subdiv_graph, prereq_node, orand_parent, subdiv_graph.edges[pre]) or 0
                        -- Make sure this connection isn't blacklisted for this handler
                        if randomization_info.options.unified[handler_id].blacklisted_pre[key(prereq_node)] then
                            num_copies = 0
                        end
                        if randomization_info.options.unified[handler_id].blacklisted_dep[key(orand_parent)] then
                            num_copies = 0
                        end

                        if num_copies > 0 then
                            if claimed then
                                error("Multiple handlers claiming the same edge")
                            end
                            claimed = true
                            table.insert(subdivide_info, {
                                edge_key = pre,
                                handler = handler,
                                num_copies = num_copies,
                            })
                        end
                    end
                end

                for _, info in pairs(subdivide_info) do
                    local conns = gutils.subdivide_base_head(subdiv_graph, info.edge_key)
                    table.insert(dep_to_heads[node_key], key(conns.head))
                    head_to_handler[key(conns.head)] = info.handler
                    -- Add the base as the "prereqs"
                    table.insert(shuffled_prereqs, key(conns.base))
                    for i = 2, info.num_copies do
                        table.insert(post_shuffled_prereqs, key(conns.base))
                    end
                end
            end
        end
    end
    test_graph_invariants.test(subdiv_graph)

    -- TEST: Do consistent_sort tests on subdiv_graph
    if DO_TESTS then
        test_sort.init(subdiv_graph)
        for test_name, test in pairs(test_sort) do
            if type(test) == "function" and not test_sort.non_test_names[test_name] then
                test()
            end
        end
    end

    -- Cut base-head connections
    local cut_graph = table.deepcopy(subdiv_graph)
    for _, node in pairs(cut_graph.nodes) do
        -- Make sure to ignore the canonical head node created to instantiate the type during graph building
        if node.type == "head" and node.name ~= "" then
            gutils.remove_edge(cut_graph, gutils.ekey(gutils.unique_pre(cut_graph, node)))
        end
    end
    test_graph_invariants.test(cut_graph)

    ----------------------------------------------------------------------------------------------------
    -- CALCULATE POOLS
    ----------------------------------------------------------------------------------------------------

    local pool_graph = table.deepcopy(cut_graph)
    local sort_for_pool = top.sort(pool_graph, nil, nil, { choose_randomly = true })

    for _, dep in pairs(sorted_deps) do
        for _, head_key in pairs(dep_to_heads[dep]) do
            local head = pool_graph.nodes[head_key]
            local old_base = pool_graph.nodes[head.old_base]
            sort_for_pool = top.sort(pool_graph, sort_for_pool, {old_base, head}, { choose_randomly = true })
        end
    end

    ----------------------------------------------------------------------------------------------------
    -- FIRST PASS
    ----------------------------------------------------------------------------------------------------

    local first_pass_info
    local old_sorted_deps
    if DO_FIRST_PASS then
        local function switch_vulcanus_nauvis(graph)
            local nauvis_node = graph.nodes[key("room", key("planet", "nauvis"))]
            local vulcanus_node = graph.nodes[key("room", key("planet", "vulcanus"))]

            -- room-launch's are intrinsic to the room
            local function leads_to_room_launch(node)
                if node.type == "room-launch" then
                    return true
                elseif node.type ~= "base" and node.type ~= "head" then
                    return false
                else
                    return leads_to_room_launch(gutils.unique_depnode(graph, node))
                end
            end

            local function gather_deps(node)
                local deps_tbl = {}
                for dep, _ in pairs(node.dep) do
                    local depnode = graph.nodes[graph.edges[dep].stop]
                    if not leads_to_room_launch(depnode) then
                        if depnode.type == "base" then
                            table.insert(deps_tbl, gutils.unique_dep(graph, depnode))
                        else
                            table.insert(deps_tbl, graph.edges[dep])
                        end
                    end
                end
                return deps_tbl
            end

            local nauvis_deps = gather_deps(nauvis_node)
            local vulcanus_deps = gather_deps(vulcanus_node)
            for _, edge in pairs(nauvis_deps) do
                gutils.redirect_edge_start(graph, gutils.ekey(edge), key(vulcanus_node))
            end
            for _, edge in pairs(vulcanus_deps) do
                gutils.redirect_edge_start(graph, gutils.ekey(edge), key(nauvis_node))
            end
        end

        local spoofed_graph_to_pass = table.deepcopy(spoofed_graph)
        local subdiv_graph_to_pass = table.deepcopy(subdiv_graph)
        if SWITCH_PLANETS then
            -- Don't randomize the spoofed graph, since that's used for the initial vanilla sort
            --switch_vulcanus_nauvis(spoofed_graph_to_pass)
            switch_vulcanus_nauvis(subdiv_graph_to_pass)
        end

        first_pass_info = first_pass.execute({
            spoofed_graph = spoofed_graph_to_pass,
            subdiv_graph = subdiv_graph_to_pass,
        })
        if first_pass_info == false then
            return false
        end
        sort_for_pool = first_pass_info.sort

        -- Replace deps in sorted_deps by travs
        old_sorted_deps = table.deepcopy(sorted_deps)
        for dep_ind, dep in pairs(sorted_deps) do
            local trav_key = first_pass_info.slot_to_trav[dep]
            -- Dep might not have been a slot, in which case it stays the same
            if trav_key ~= nil then
                local trav = first_pass_info.graph.nodes[trav_key]
                sorted_deps[dep_ind] = trav.old_slot
            end
        end
    end

    ----------------------------------------------------------------------------------------------------
    -- CONTEXT REACHABILITY
    ----------------------------------------------------------------------------------------------------

    -- Check if all of key1 node's context inds are before all of key2 node's
    local function all_contexts_reachable(key1, key2, ignore_nil_contexts)
        if sort_for_pool.node_to_context_inds[key1] == nil then
            log(key1)
            error("Key invalid")
        elseif sort_for_pool.node_to_context_inds[key2] == nil then
            log(key2)
            error("Key invalid")
        end

        if ONLY_TEST_FIRST_CONTEXT_ORDER then
            local smallest_ind1
            local smallest_ind2

            for context, _ in pairs(logic.contexts) do
                local index1 = sort_for_pool.node_to_context_inds[key1][context]
                local index2 = sort_for_pool.node_to_context_inds[key2][context]
                if ignore_nil_contexts and (index1 == nil or index2 == nil) then
                    return true
                end
                if index1 == nil and index2 ~= nil then
                    return false
                end
                if smallest_ind1 == nil or (index1 ~= nil and index1 < smallest_ind1) then
                    smallest_ind1 = index1
                end
                if smallest_ind2 == nil or (index2 ~= nil and index2 < smallest_ind2) then
                    smallest_ind2 = index2
                end
            end

            if smallest_ind1 < smallest_ind2 then
                return true
            else
                return false
            end
        end

        for context, _ in pairs(logic.contexts) do
            local index1 = sort_for_pool.node_to_context_inds[key1][context]
            local index2 = sort_for_pool.node_to_context_inds[key2][context]
            if ignore_nil_contexts and (index1 == nil or index2 == nil) then
                return true
            end
            index1 = index1 or (#sort_for_pool.sorted + 1)
            index2 = index2 or (#sort_for_pool.sorted + 2)
            if not (index1 < index2) then
                return false
            end
        end

        return true
    end

    test_graph_invariants.test(pool_graph)

    -- TEST: Make sure each head is after its corresponding base
    -- TODO: Make this check compatible with first pass
    if not DO_FIRST_PASS then
        for _, dep in pairs(sorted_deps) do
            for _, head_key in pairs(dep_to_heads[dep]) do
                local head = subdiv_graph.nodes[head_key]
                local base_key = head.old_base
                local base = pool_graph.nodes[base_key]

                if base.name ~= head.name then
                    log(serpent.block(base))
                    log(serpent.block(head))
                    error("Randomization assertion failed! Tell exfret he's a dumbo.")
                end
                if not all_contexts_reachable(base_key, head_key) then
                    log(serpent.block(base))
                    log(serpent.block(head))
                    error("Randomization assertion failed! Tell exfret he's a dumbo.")
                end
            end
        end
    end

    ----------------------------------------------------------------------------------------------------
    -- SHUFFLE
    ----------------------------------------------------------------------------------------------------

    local random_graph = table.deepcopy(cut_graph)

    -- With special tech unlock validation, put them in reverse order
    local not_shuffled_post_shuffled_prereqs = {}
    local techs_with_tech_unlock_added = {}
    if SPECIAL_RECIPE_TECH_UNLOCK_VALIDATION then
        for i = #shuffled_prereqs, 1, -1 do
            local prereq_node = subdiv_graph.nodes[shuffled_prereqs[i]]
            local prereq_owner = gutils.get_owner(subdiv_graph, prereq_node)
            if prereq_owner.type == "recipe-tech-unlock" then
                -- Make each tech equally likely-ish to unlock a recipe now
                local add_to_tech_unlock_list = true
                if prereq_owner.num_pre == 1 then
                    -- Need to do twice to get past orand
                    local tech_node = gutils.unique_prenode(subdiv_graph, gutils.unique_prenode(subdiv_graph, prereq_owner))
                    if techs_with_tech_unlock_added[tech_node.name] then
                        add_to_tech_unlock_list = false
                    else
                        techs_with_tech_unlock_added[tech_node.name] = true
                    end
                end
                if add_to_tech_unlock_list then
                    -- Bias toward later unlocks by adding more of them
                    local bias_num = 4
                    for j = 1, bias_num * math.ceil(i / #shuffled_prereqs) do
                        table.insert(not_shuffled_post_shuffled_prereqs, key(prereq_node))
                    end
                end
                table.remove(shuffled_prereqs, i)
            end
        end
    end
    rng.shuffle(rng.key({id = "unified"}), shuffled_prereqs)
    rng.shuffle(rng.key({id = "unified"}), post_shuffled_prereqs)
    for _, prereq in pairs(post_shuffled_prereqs) do
        table.insert(shuffled_prereqs, prereq)
    end
    local not_shuffled_post_shuffled_prereqs_start = #shuffled_prereqs + 1
    if SPECIAL_RECIPE_TECH_UNLOCK_VALIDATION then
        rng.shuffle(rng.key({id = "unified"}), not_shuffled_post_shuffled_prereqs)
        for _, prereq in pairs(not_shuffled_post_shuffled_prereqs) do
            table.insert(shuffled_prereqs, prereq)
        end
    end

    -- CRITICAL TODO: Tech delinearization (pull out to a helper)

    -- In first pass, return to owner nodes and ask if one's slot is context reachable before the other's slot in the pass sort
    local function node_to_first_pass_slot(node)
        -- Trav should get the right context from its slot
        local trav_node_key = key(node.type, first_pass.make_trav_name(node.name))
        
        if first_pass_info.graph.nodes[trav_node_key] ~= nil then
            return trav_node_key
        else
            return key(node)
        end
    end

    local function get_context_reachable(base, head)
        local ignore_nil_contexts = head_to_handler[key(head)].ignore_nil_contexts

        if not DO_FIRST_PASS then
            return all_contexts_reachable(key(base), key(head), ignore_nil_contexts)
        else
            local base_owner = gutils.get_owner(random_graph, base)
            local head_owner = gutils.get_owner(random_graph, head)
            return all_contexts_reachable(node_to_first_pass_slot(base_owner), node_to_first_pass_slot(head_owner), ignore_nil_contexts)
        end
    end

    local head_to_base = {}
    local used_prereq_inds = {}
    for dep_ind, dep in pairs(sorted_deps) do
        if #dep_to_heads[dep] > 0 then
            local context_str = ""
            if DO_FIRST_PASS then
                context_str = old_sorted_deps[dep_ind]
            end
            log("\nRandomizing " .. dep .. " (" .. context_str .. ")")
        end
        for _, head_key in pairs(dep_to_heads[dep]) do
            local found_prereq = false
            local starting_ind = 1
            if SPECIAL_RECIPE_TECH_UNLOCK_VALIDATION and head_to_handler[head_key].id == "recipe_tech_unlocks" then
                starting_ind = not_shuffled_post_shuffled_prereqs_start
            end
            for ind = starting_ind, #shuffled_prereqs do
                local base_key = shuffled_prereqs[ind]

                local is_context_reachable = false
                local base = random_graph.nodes[base_key]
                local head = random_graph.nodes[head_key]

                -- TEST: Check for nil base or head
                if base == nil or head == nil then
                    log(base_key)
                    log(head_key)
                    error("Randomization assertion failed! Tell exfret he's a dumbo.")
                end

                is_context_reachable = get_context_reachable(base, head)

                if not used_prereq_inds[ind] and is_context_reachable then
                    -- Have head's handler validate this base

                    if head_to_handler[head_key].validate(random_graph, base, head, {
                        init_sort = sort_for_claiming, -- Needed for tech rando
                    }) then
                        log("Accepted prereq " .. key(gutils.get_owner(random_graph, base)) .. " (" .. key(gutils.get_owner(random_graph, random_graph.nodes[base.old_head])) .. ")")
                        head_to_handler[head_key].process(random_graph, base, head)
                        found_prereq = true
                        used_prereq_inds[ind] = true
                        head_to_base[head_key] = base_key

                        if SPECIAL_RECIPE_TECH_UNLOCK_VALIDATION then
                            table.insert(shuffled_prereqs, base_key)
                        end

                        break
                    end
                end
            end
            if not found_prereq then
                log(head_key)
                local percentage = math.floor(100 * dep_ind / #sorted_deps)
                log("Prereq shuffle failed at " .. tostring(percentage) .. "%")

                if REPORT_NUM_TECH_PREREQS then
                    local num_reachable = 0
                    local num_reachable_context = 0
                    for dep_ind2, dep2 in pairs(sorted_deps) do
                        for ind2, base_key2 in pairs(shuffled_prereqs) do
                            local subdiv_base = subdiv_graph.nodes[base_key2]
                            local subdiv_opposite = gutils.get_owner(subdiv_graph, gutils.get_buddy(subdiv_graph, subdiv_base))
                            if dep2 == key(subdiv_opposite) then
                                local subdiv_base_owner = gutils.get_owner(subdiv_graph, subdiv_base)
                                if subdiv_base_owner.type == "recipe-tech-unlock" then
                                    -- Check unusued
                                    if not used_prereq_inds[ind2] then
                                        local base = random_graph.nodes[base_key2]
                                        local head = random_graph.nodes[head_key]
                                        if get_context_reachable(base, head) then
                                            num_reachable_context = 1 + num_reachable_context
                                        end
                                        if dep_ind2 < dep_ind then
                                            num_reachable = 1 + num_reachable
                                        end
                                    end
                                end
                            end
                        end
                    end
                    log("Num context recipe tech prereqs: " .. tostring(num_reachable_context))
                    log("Num previous recipe tech prereqs: " .. tostring(num_reachable))
                end

                return false
            end
        end
    end

    ----------------------------------------------------------------------------------------------------
    -- REFLECT
    ----------------------------------------------------------------------------------------------------

    for _, handler in pairs(handlers) do
        handler.reflect(random_graph, head_to_base, head_to_handler)
    end

    if SWITCH_PLANETS then
        local old_nauvis = table.deepcopy(data.raw.planet.nauvis)
        data.raw.planet.nauvis = table.deepcopy(data.raw.planet.vulcanus)
        data.raw.planet.nauvis.name = "nauvis"
        data.raw.planet.vulcanus = old_nauvis
        data.raw.planet.vulcanus.name = "vulcanus"
    end

    return true
end

return unified