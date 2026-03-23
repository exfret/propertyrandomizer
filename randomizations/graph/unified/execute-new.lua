-- Fundamental differences:
--  * USE KEYS INTO THE GRAPH (no passing graph nodes, since we have so many different graphs by copy, not reference)
--  * Use the new graph library functions
--  * Use correct terminology

-- TODO: Some tests targeting areas where I might have forgotten about orands
-- TODO: Do a more thorough look through handlers for terminology changes etc.

local DO_FIRST_PASS = true

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
}

-- for _, id in pairs(all_handler_ids) do
for id, _ in pairs(config.unified) do
    if config.unified[id] then
        table.insert(handler_ids, id)
    end
    randomization_info.options.unified[id] = {
        blacklisted_pre = {},
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
    test_sort.init(subdiv_graph)
    for test_name, test in pairs(test_sort) do
        if type(test) == "function" and not test_sort.non_test_names[test_name] then
            test()
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

    local first_pass_info
    if DO_FIRST_PASS then
        first_pass_info = first_pass.execute({
            spoofed_graph = spoofed_graph,
            subdiv_graph = subdiv_graph,
        })
        sort_for_pool = first_pass_info.sort
    end

    -- Check if all of key1 node's context inds are before all of key2 node's
    local function all_contexts_reachable(key1, key2)
        if sort_for_pool.node_to_context_inds[key1] == nil then
            log(key1)
            error("Key invalid")
        elseif sort_for_pool.node_to_context_inds[key2] == nil then
            log(key2)
            error("Key invalid")
        end

        for context, _ in pairs(logic.contexts) do
            local index1 = sort_for_pool.node_to_context_inds[key1][context] or (#sort_for_pool.sorted + 1)
            local index2 = sort_for_pool.node_to_context_inds[key2][context] or (#sort_for_pool.sorted + 2)
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

    rng.shuffle(rng.key({id = "unified"}), shuffled_prereqs)
    rng.shuffle(rng.key({id = "unified"}), post_shuffled_prereqs)
    for _, prereq in pairs(post_shuffled_prereqs) do
        table.insert(shuffled_prereqs, prereq)
    end

    -- CRITICAL TODO: Tech delinearization (pull out to a helper)

    local head_to_base = {}
    local used_prereq_inds = {}
    for dep_ind, dep in pairs(sorted_deps) do
        if #dep_to_heads[dep] > 0 then
            log("Randomizing " .. dep)
        end
        for _, head_key in pairs(dep_to_heads[dep]) do
            local found_prereq = false
            for ind, base_key in pairs(shuffled_prereqs) do
                local is_context_reachable = false
                local base = random_graph.nodes[base_key]
                local head = random_graph.nodes[head_key]

                -- TEST: Check for nil base or head
                if base == nil or head == nil then
                    log(base_key)
                    log(head_key)
                    error("Randomization assertion failed! Tell exfret he's a dumbo.")
                end

                if not DO_FIRST_PASS then
                    is_context_reachable = all_contexts_reachable(base_key, head_key)
                else
                    -- In first pass, return to owner nodes and ask if one's slot is context reachable before the other's slot in the pass sort
                    local function node_to_first_pass_slot(node)
                        local trav_node_key = key(node.type, first_pass.make_trav_name(node.name))

                        if first_pass_info.trav_to_slot[trav_node_key] ~= nil then
                            -- In this case, we return the corresponding slot
                            return first_pass_info.trav_to_slot[trav_node_key]
                        else
                            -- Otherwise, there isn't a slot/trav distinction so just return the node
                            return key(node)
                        end
                    end

                    local base_owner = gutils.get_owner(random_graph, base)
                    local head_owner = gutils.get_owner(random_graph, head)
                    is_context_reachable = all_contexts_reachable(node_to_first_pass_slot(base_owner), node_to_first_pass_slot(head_owner))
                end

                if not used_prereq_inds[ind] and is_context_reachable then
                    -- Have head's handler validate this base

                    if head_to_handler[head_key].validate(random_graph, base, head, {
                        init_sort = sort_for_claiming, -- Needed for tech rando
                    }) then
                        log("Accepted prereq " .. key(gutils.get_owner(random_graph, base)))
                        head_to_handler[head_key].process(random_graph, base, head)
                        found_prereq = true
                        used_prereq_inds[ind] = true
                        head_to_base[head_key] = base_key

                        break
                    end
                end
            end
            if not found_prereq then
                local percentage = math.floor(100 * dep_ind / #sorted_deps)
                log("Prereq shuffle failed at " .. tostring(percentage) .. "%")
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

    return true
end

return unified