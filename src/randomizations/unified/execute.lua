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
-- TODO: Speed up tests! Currently they take a long time
local DO_TESTS = false
local ONLY_TEST_FIRST_CONTEXT_ORDER = true
local SWITCH_PLANETS = false
local REMOVE_TECH_PREREQS = true
-- Keep mechanic contexts and recipe reachability with promotion (src/randomizations/unified/skeleton/promotion.lua) for both generic handlers and recipe ingredients, instead of comparing orders in a sort
local USE_PROMOTION = true
-- Have promotion keep room/ability contexts (isolatability, automatability), not just rooms
local PROMOTION_COMPLEX_CONTEXTS = true
-- Log witness skeleton stats (src/randomizations/unified/skeleton/stats.lua); measurement only
local SKELETON_STATS = false

-- 0 means nothing except on errors (in case I decide to stop polluting log in the future), 1 means default/important things, 2 means lots
local LOGGING_LEVEL = 2
local function log_info(level, info)
    if LOGGING_LEVEL >= level then
        log(info)
    end
end

local constants = require("src/config/constants")
local graph_customization = require("src/config/graph-customization")
local localised_text = require("src/localisation/localised-text")
local rng = require("src/lib/random/rng")
local dutils = require("src/prototypes/data-utils")
-- The planet copies' technologies keep the discoveries they follow when tech prerequisites are cleared
local dupe_branches = require("src/prototypes/duplicates/dupe-branches")
local gutils = require("src/lib/graph/graph-utils")
local orand_policy = require("src/randomizations/unified/orand-policy")
local item_fluid = require("src/randomizations/unified/item-fluid")
local recycling = require("src/prototypes/recipes/recycling")
local recipe_item_amounts = require("src/prototypes/recipes/recipe-item-amounts")
local top = require("src/lib/sort/context-sort")
local superpose = require("src/lib/graph/superpose")
local reductions = require("src/logic/analysis/reductions")
local unlock_contraction = require("src/logic/analysis/unlock-contraction")
local logic = require("src/logic/init")
local item_craft = require("src/logic/builders/item-craft")
local first_pass = require("src/randomizations/unified/first-pass")
local promotion = require("src/randomizations/unified/skeleton/promotion")
local balance = require("src/randomizations/unified/first-pass-balance")
local test_graph_invariants = require("tests/graph-invariants")
local test_sort = require("tests/consistent-sort")
local planetary = require("src/randomizations/planetary/execute")
local skeleton_stats = require("src/randomizations/unified/skeleton/stats")

local key = gutils.key

local unified = {}

local all_handler_ids = require("src/config/handler-ids")
local handler_ids = {}

-- Handlers still in development, forced on in every game while the hidden setting propertyrandomizer-dev-unified is (config.dev_unified; off in releases)
RECIPE_INGS_DIR = "FORWARD"
local enabled = {}
-- Spoiling also needs its own setting (propertyrandomizer-unified-spoiling, visible and off by default; tests/configs.txt pins it on for unified-all), since the checkout is the user's playable mod and spoiling is still being worked on (user, 2026-09-29)
local is_spoiling_on = config.unified["spoiling"] == true
if config.dev_unified then
    -- CRITICAL TODO: REMOVE!
    config.unified = {
        ["recipe-ingredients"] = true,
        ["recipe-tech-unlocks"] = true,
        ["spoiling"] = true,
        ["tech-prereqs"] = true,
        ["tech-science-packs"] = true,
        ["item-ingredients"] = true,
        ["recipe-ingredients-first-pass"] = true,
        ["entity-autoplace"] = true,

        ["recipe-category"] = true,
        ["item"] = true,
        ["entity-energy-source"] = true,
        ["mining-fluid-required"] = true,
        ["tech-triggers"] = true,
    }

    ITEM_ENABLED = true
    enabled = {
        --["recipe-ingredients"] = true,
        --["tech-science-packs"] = true,
        --["tech-prereqs"] = true,
        --["recipe-tech-unlocks"] = true,
        --["recipe-ingredients-first-pass"] = true,
        --["entity-autoplace"] = true,

        ["recipe-category"] = true,
        ["item"] = ITEM_ENABLED,
        ["entity-energy-source"] = true,
        ["mining-fluid-required"] = true,
        ["recipe-ingredients"] = true,
        ["spoiling"] = is_spoiling_on,
        -- Research triggers (handlers/tech-triggers.lua): technologies trade triggers
        ["tech-triggers"] = true,
    }
end
-- Entity randomization (handlers/entity.lua) is behind its own startup setting
if config.entity_randomization then
    config.unified["entity"] = true
    enabled["entity"] = true
end

-- for _, id in pairs(all_handler_ids) do
for id, _ in pairs(config.unified) do
    if enabled[id] then--config.unified[id] then
        table.insert(handler_ids, id)
    end
    if randomization_info.options.unified[id] == nil then
        randomization_info.options.unified[id] = {
            blacklisted_pre = {},
            blacklisted_dep = {},
        }
    end
end

-- Load handlers
local default_handler = require("src/randomizations/unified/handlers/default")
local available_handlers = {
    ["entity"] = require("src/randomizations/unified/handlers/entity"),
    ["entity-autoplace"] = require("src/randomizations/unified/handlers/entity-autoplace"),
    ["entity-energy-source"] = require("src/randomizations/unified/handlers/entity-energy-source"),
    ["entity-operation-fluid"] = require("src/randomizations/unified/handlers/entity-operation-fluid"),
    ["item"] = require("src/randomizations/unified/handlers/item"),
    ["item-ingredients"] = require("src/randomizations/unified/handlers/item-ingredients"),
    ["mining-fluid-required"] = require("src/randomizations/unified/handlers/mining-fluid-required"),
    ["recipe-category"] = require("src/randomizations/unified/handlers/recipe-category"),
    ["recipe-ingredients"] = require("src/randomizations/unified/handlers/recipe-ingredients"),
    ["recipe-ingredients-first-pass"] = require("src/randomizations/unified/handlers/recipe-ingredients-first-pass"),
    ["recipe-tech-unlocks"] = require("src/randomizations/unified/handlers/recipe-tech-unlocks"),
    ["spoiling"] = require("src/randomizations/unified/handlers/spoiling"),
    ["tech-prereqs"] = require("src/randomizations/unified/handlers/tech-prereqs"),
    ["tech-science-packs"] = require("src/randomizations/unified/handlers/tech-science-packs"),
    ["tech-triggers"] = require("src/randomizations/unified/handlers/tech-triggers"),
}
local handlers = {}
for _, handler_id in pairs(handler_ids) do
    local handler = available_handlers[handler_id]

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

-- Whether any handler is on, so there's anything for unified randomization to do
unified.has_handlers = #handler_ids > 0
-- Whether research triggers are randomized (handlers/tech-triggers.lua), for data-final-fixes.lua's split of trigger technologies before the tech tree rebuild (research_triggers.split_technologies)
unified.randomizes_triggers = handlers["tech-triggers"] ~= nil

-- One attempt (see unified.execute below)
-- Repair mode uses the same prerequisite chooser before first pass, only at unpaid requirements.
local function attempt(options)
    options = options or {}
    local repair_only = options.repair_only == true
    local do_first_pass = DO_FIRST_PASS and not repair_only
    local handlers = handlers
    local handler_ids = handler_ids
    local debt = options.debt
    if repair_only then
        assert(USE_PROMOTION and debt ~= nil, "Prerequisite repairs need promotion and the previous game's requirements")
        handlers = {}
        handler_ids = options.handler_keys
        for _, handler_id in pairs(handler_ids) do
            local handler = assert(available_handlers[handler_id])
            for prop, val in pairs(default_handler) do
                if handler[prop] == nil and default_handler.required[prop] == nil then
                    handler[prop] = val
                end
            end
            handlers[handler_id] = handler
        end
    end
    if not repair_only then
        graph_customization.initialize(config.customization, data.raw, defines.prototypes, config.seed)
        config.graph_exclusion_warnings = config.graph_exclusion_warnings or {}
        for _, selector in pairs(graph_customization.unmatched()) do
            if config.graph_exclusion_warnings[selector] == nil then
                config.graph_exclusion_warnings[selector] = true
                table.insert(randomization_info.warnings, localised_text.get("propertyrandomizer-warning.graph-exclusion-empty", selector))
                log("Graph exclusion matches no loaded prototypes: " .. selector)
            end
        end
    end
    for _, handler in pairs(handlers) do
        handler.initialize({ repair_only = repair_only })
    end

    ----------------------------------------------------------------------------------------------------
    log_info(2, "GRAPH PREP")
    ----------------------------------------------------------------------------------------------------

    -- First, save old data
    -- We can't call this old_data_raw because that's for the *very* initial data
    -- Make it a global so we don't have to pass it everywhere
    unified_starting_data_raw = table.deepcopy(data.raw)

    -- data.raw preprocessing if necessary
    if not repair_only then
        for _, handler in pairs(handlers) do
            handler.preprocess()
        end
    end

    if REMOVE_TECH_PREREQS and not repair_only then
        -- A planet copy's technologies keep the discoveries their parallel tree follows (dupe_branches.copy_gates), so that randomization never makes something early need a copied item: the copies belong to their planet copies (user, 2026-10-12), which the tech tree rebuild keeps them behind
        local copy_gates = dupe_branches.copy_gates(data.raw.technology)
        for _, tech in pairs(data.raw.technology) do
            if not graph_customization.excluded("tech-prereqs", {
                type = "technology",
                name = tech.name,
            }) then
                tech.prerequisites = table.deepcopy(copy_gates[tech.name] or {})
            end
        end
    end

    -- Logic building
    logic.build()
    -- The debt has every node logic.build left out (see superpose.union), so this game needs them too for the debt to fit onto its graphs
    if debt ~= nil then
        reductions.expand_all(logic.graph)
    end
    test_graph_invariants.test(logic.graph)
    local init_graph = logic.graph
    if not repair_only then
        graph_customization.protect_references(init_graph)
    end
    test_graph_invariants.test(init_graph)

    local spoofed_graph = table.deepcopy(init_graph)
    -- Spoofing
    for _, handler in pairs(handlers) do
        handler.spoof(spoofed_graph)
    end
    -- Share unchanged unlock forwarding links after debt expansion/spoofing, keeping every endpoint the debt needs.
    local shared_unlocks = reductions.enabled and unlock_contraction.share_forwarders(spoofed_graph, debt) or 0
    if shared_unlocks > 0 then
        log("Recipe unlocks: " .. shared_unlocks .. " forwarding ORs share their technology alternatives")
    end
    test_graph_invariants.test(spoofed_graph)
    gutils.make_orands(spoofed_graph, orand_policy.precheck(handlers, function(handler_id, prereq, dep)
        return repair_only or (graph_customization.selected(handler_id, dep) and not graph_customization.excluded(handler_id, prereq))
    end))
    test_graph_invariants.test(spoofed_graph)

    ----------------------------------------------------------------------------------------------------
    log_info(2, "CLAIMING")
    ----------------------------------------------------------------------------------------------------

    local sort_for_claiming = top.sort(spoofed_graph, nil, nil, { choose_randomly = true })
    log_info(2, "NUM PEBBLES: " .. tostring(#sort_for_claiming.pebble_keys))
    -- Repair mode includes missing requirements in the dependents' sort, so the chooser can repair a recipe that has no context in the actual game yet.
    -- The debt edges live only in this copy: the claimed heads and bases come from subdiv_graph, the game's graph
    local sort_for_deps = sort_for_claiming
    if debt ~= nil then
        local deps_graph = table.deepcopy(spoofed_graph)
        local added = superpose.add_debt(deps_graph, debt)
        if #added > 0 then
            sort_for_deps = top.sort(deps_graph, nil, nil, { choose_randomly = true })
            log("Claiming: " .. #added .. " debt edges added for the dependents to randomize; " .. #sort_for_deps.pebble_keys .. " pebbles with them, " .. #sort_for_claiming.pebble_keys .. " without")
        end
    end
    local subdiv_graph = table.deepcopy(spoofed_graph)

    local added_to_deps = {}
    local sorted_deps = {}
    local handler_to_shuffled_prereqs = {}
    local handler_to_post_shuffled_prereqs = {}
    for _, handler in pairs(handlers) do
        -- Be careful that handler.id is different from handler's key in handlers (one uses underscores the other dashes)
        -- handler.id can actually be gotten from the handler alone though, which is why we use it
        handler_to_shuffled_prereqs[handler.id] = {}
        handler_to_post_shuffled_prereqs[handler.id] = {}
    end
    -- To help the aforementioned discrepancy, create a way to get the handler from handler.id
    local handler_id_to_handler = {}
    for _, handler in pairs(handlers) do
        handler_id_to_handler[handler.id] = handler
    end
    -- Ordinary edges and metadata-only uses share the same policy; ordinary claim side effects retain their order.
    local function selected(handler_id, prereq, dep)
        return repair_only or (graph_customization.selected(handler_id, dep) and not graph_customization.excluded(handler_id, prereq))
    end
    local function blacklisted(handler_id, prereq, dep)
        if repair_only then
            return false
        end
        local options = randomization_info.options.unified[handler_id]
        return options.blacklisted_pre[key(prereq)] == true or options.blacklisted_dep[key(dep)] == true
    end
    local function add_pool_entry(handler, base_key, num_copies)
        if num_copies > 0 then
            table.insert(handler_to_shuffled_prereqs[handler.id], base_key)
            for i = 2, num_copies do
                if handler.uniform_copies == true then
                    table.insert(handler_to_shuffled_prereqs[handler.id], base_key)
                else
                    table.insert(handler_to_post_shuffled_prereqs[handler.id], base_key)
                end
            end
        end
    end
    local dep_to_heads = {}
    local head_to_handler = {}
    for ind, node_key in pairs(sort_for_deps.pebble_keys) do
        -- Get node from subdiv_graph
        local node = subdiv_graph.nodes[node_key]

        -- A node only the game before planetary changes has (superpose.add_debt adds those to the debt copy, like a route a planetary change replaced, or a connector for an old edge) has nothing to claim or randomize in the game's graph
        if node ~= nil and node.op == "AND" and node.type ~= "base" then
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
                    local claimed_by

                    for handler_id, handler in pairs(handlers) do
                        local num_copies
                        if selected(handler_id, prereq_node, orand_parent) then
                            num_copies = handler.claim(subdiv_graph, prereq_node, orand_parent, subdiv_graph.edges[pre])
                        end
                        if blacklisted(handler_id, prereq_node, orand_parent) then
                            num_copies = false
                        end

                        if num_copies then
                            if claimed_by ~= nil then
                                error("Multiple handlers claiming the same edge: " .. claimed_by .. " AND " .. handler_id)
                            end
                            claimed_by = handler_id
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
                    add_pool_entry(info.handler, key(conns.base), info.num_copies)
                end
            end
        end
    end
    for handler_id, handler in pairs(handlers) do
        local entries = handler.pool_entries(subdiv_graph, sort_for_deps, function(prereq, dep)
            return selected(handler_id, prereq, dep) and not blacklisted(handler_id, prereq, dep)
        end)
        for _, entry in pairs(entries) do
            add_pool_entry(handler, entry.base_key, entry.num_copies)
        end
    end
    local num_craft_options = item_craft.fuse_options(subdiv_graph)
    if num_craft_options > 0 then
        local kept_deps = {}
        for _, dep_key in pairs(sorted_deps) do
            if subdiv_graph.nodes[dep_key] ~= nil then
                table.insert(kept_deps, dep_key)
            end
        end
        sorted_deps = kept_deps
        log("Craft production: " .. num_craft_options .. " trigger candidates share their item's production branches")
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
    log_info(2, "CALCULATE POOLS")
    ----------------------------------------------------------------------------------------------------

    local pool_graph = table.deepcopy(cut_graph)
    local sort_for_pool = top.sort(pool_graph, nil, nil, { choose_randomly = true })

    for _, dep in pairs(sorted_deps) do
        for _, head_key in pairs(dep_to_heads[dep]) do
            local head = pool_graph.nodes[head_key]
            local old_base = pool_graph.nodes[head.old_base]
            -- Heads that start detached have a vanilla base only so their edge could be claimed (see promotion.new)
            if head.starts_detached == nil then
                gutils.connect_base_head(pool_graph, head.old_base, head_key, old_base.abilities)
                sort_for_pool = top.sort(pool_graph, sort_for_pool, {old_base, head}, { choose_randomly = true })
            end
        end
    end

    -- SKELETON EXPERIMENT (measurement only; see src/randomizations/unified/skeleton/)
    if SKELETON_STATS then
        skeleton_stats.run({
            graph = pool_graph,
            sort_info = sort_for_pool,
            sorted_deps = sorted_deps,
            dep_to_heads = dep_to_heads,
            head_to_handler = head_to_handler,
        })
    end
    -- Nothing changes pool_graph after this, so it's checked now, before first pass can let go of it
    test_graph_invariants.test(pool_graph)

    ----------------------------------------------------------------------------------------------------
    log_info(2, "FIRST PASS")
    ----------------------------------------------------------------------------------------------------

    local first_pass_info
    local old_sorted_deps
    if do_first_pass then
        -- NOTE: This switch code is out of date
        local function switch_vulcanus_start(graph)
            local start_node = graph.nodes[key("room", key("planet", constants.starting_planet))]
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

            local start_deps = gather_deps(start_node)
            local vulcanus_deps = gather_deps(vulcanus_node)
            for _, edge in pairs(start_deps) do
                gutils.redirect_edge_start(graph, gutils.ekey(edge), key(vulcanus_node))
            end
            for _, edge in pairs(vulcanus_deps) do
                gutils.redirect_edge_start(graph, gutils.ekey(edge), key(start_node))
            end
        end

        local spoofed_graph_to_pass = table.deepcopy(spoofed_graph)
        local subdiv_graph_to_pass = table.deepcopy(subdiv_graph)
        -- Heads that start detached (like friendly biters') are only there to be claimed, so first pass can't count on them, as the pool graph and promotion don't
        gutils.detach_starting_heads(spoofed_graph_to_pass)
        item_craft.discard_options(spoofed_graph_to_pass)
        gutils.detach_starting_heads(subdiv_graph_to_pass)
        if SWITCH_PLANETS then
            -- Don't randomize the spoofed graph, since that's used for the initial vanilla sort
            --switch_vulcanus_start(spoofed_graph_to_pass)
            switch_vulcanus_start(subdiv_graph_to_pass)
        end
        -- With first pass, nothing reads these again (first pass's sort takes the pool sort's place), so they don't stay in memory through first pass and the shuffle
        spoofed_graph = nil
        subdiv_graph = nil
        pool_graph = nil
        sort_for_pool = nil

        first_pass_info = first_pass.execute({
            spoofed_graph = spoofed_graph_to_pass,
            subdiv_graph = subdiv_graph_to_pass,
            -- With constants.entity_first_pass, entity randomization's slots are first pass positions (see first_pass_rules in handlers/entity.lua)
            entity_rules = constants.entity_first_pass and handlers["entity"] ~= nil and handlers["entity"].first_pass_rules or nil,
        })
        spoofed_graph_to_pass = nil
        subdiv_graph_to_pass = nil
        if first_pass_info == false then
            return false
        end
        sort_for_pool = first_pass_info.sort

        -- Replace deps in sorted_deps by travs
        old_sorted_deps = table.deepcopy(sorted_deps)
        for dep_ind, dep in pairs(sorted_deps) do
            local trav_key = first_pass_info.slot_to_trav[dep]
            -- Dep might not have been a slot, in which case it stays the same
            -- An identity from a slot that isn't a dep here (an item at a fluid position, see src/randomizations/unified/item-fluid.lua) leaves it too
            if trav_key ~= nil and dep_to_heads[first_pass_info.graph.nodes[trav_key].old_slot] ~= nil then
                local trav = first_pass_info.graph.nodes[trav_key]
                sorted_deps[dep_ind] = trav.old_slot
            end
        end
    end

    ----------------------------------------------------------------------------------------------------
    log_info(2, "CONTEXT REACHABILITY")
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

            for room, _ in pairs(logic.contexts) do
                local context = top.simple_context(room)
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

            if smallest_ind1 == nil or smallest_ind2 == nil then
                log(key1)
                log(smallest_ind1)
                log(key2)
                log(smallest_ind2)

                error("Node that should be reachable is not reachable!")
            end

            if smallest_ind1 < smallest_ind2 then
                return true
            else
                return false
            end
        end

        for room, _ in pairs(logic.contexts) do
            local context = top.simple_context(room)
            local index1 = sort_for_pool.node_to_context_inds[key1][context]
            local index2 = sort_for_pool.node_to_context_inds[key2][context]
            if ignore_nil_contexts and (index1 == nil or index2 == nil) then
                return true
            end
            index1 = index1 or (#sort_for_pool.pebble_keys + 1)
            index2 = index2 or (#sort_for_pool.pebble_keys + 2)
            if not (index1 < index2) then
                return false
            end
        end

        return true
    end

    -- TEST: Make sure each head is after its corresponding base
    -- TODO: Make this check compatible with first pass
    if not do_first_pass and not repair_only then
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
    log_info(2, "SHUFFLE")
    ----------------------------------------------------------------------------------------------------

    local random_graph = table.deepcopy(cut_graph)
    -- The graphs before this one aren't read again, so they don't stay in memory through the shuffle
    spoofed_graph = nil
    subdiv_graph = nil
    cut_graph = nil
    pool_graph = nil
    -- First pass's fluid counts on recipes and resources (fluid_delta, see item_fluid.rewire_form_change) are on its graph, while handlers' validate gets this one, so they're carried over
    -- Without this, the recipe-category handler saw no fluid on a recipe whose kept ingredient's position took a fluid identity, and moved it to hand crafting (base seed 1, 2026-09-30: copper plates' recipe, which the game then couldn't craft anywhere)
    if do_first_pass then
        for node_key, node in pairs(first_pass_info.graph.nodes) do
            if node.fluid_delta ~= nil and random_graph.nodes[node_key] ~= nil then
                random_graph.nodes[node_key].fluid_delta = table.deepcopy(node.fluid_delta)
            end
        end
    end

    for _, handler in pairs(handlers) do
        rng.shuffle(rng.key({id = "unified"}), handler_to_shuffled_prereqs[handler.id])
        rng.shuffle(rng.key({id = "unified"}), handler_to_post_shuffled_prereqs[handler.id])
        for _, prereq in pairs(handler_to_post_shuffled_prereqs[handler.id]) do
            -- TODO: Might need to add back; currently disables adding a prereq multiple times
            if handler.with_replacement == false then
                table.insert(handler_to_shuffled_prereqs[handler.id], prereq)
            end
        end
    end

    -- Choices some handlers make up front, before promotion ranks anything, like which resources need a mining fluid (see choose_up_front in handlers/default.lua)
    -- Promotion then starts from these choices, and the shuffle below leaves their heads alone
    local up_front = {}
    if do_first_pass and USE_PROMOTION then
        local split_graph = first_pass_info.graph
        local false_key = key("false", "")
        assert(split_graph.nodes[false_key] ~= nil, "first pass's graph has no false node")
        -- A sort of the game (first pass's graph, with earlier handlers' up-front choices, and any heads in connections (head key --> base key) fed by those bases instead) where these AND nodes can't be reached, leaving the graph as it was
        local function sort_without(node_keys, connections)
            local removed = {}
            local added = {}
            local function connect(head_key, base_key)
                for pre, _ in pairs(table.deepcopy(split_graph.nodes[head_key].pre)) do
                    table.insert(removed, table.deepcopy(split_graph.edges[pre]))
                    gutils.remove_edge(split_graph, pre)
                end
                local abilities = head_to_handler[head_key].connection_abilities(split_graph.nodes[base_key], split_graph.nodes[head_key])
                table.insert(added, gutils.ekey(gutils.connect_base_head(split_graph, base_key, head_key, abilities)))
            end
            for head_key, base_key in pairs(up_front) do
                connect(head_key, base_key)
            end
            for head_key, base_key in pairs(connections or {}) do
                connect(head_key, base_key)
            end
            for _, node_key in pairs(node_keys) do
                assert(split_graph.nodes[node_key].op == "AND", "sort_without can only cut off AND nodes, not " .. node_key)
                if split_graph.edges[gutils.ekey({
                    start = false_key,
                    stop = node_key,
                })] == nil then
                    table.insert(added, gutils.ekey(gutils.add_edge(split_graph, false_key, node_key)))
                end
            end
            local sort_info = top.sort(split_graph, nil, nil, {
                choose_randomly = true,
                complex_contexts = true,
                home_contexts = true,
            })
            for _, edge_key in pairs(added) do
                gutils.remove_edge(split_graph, edge_key)
            end
            for _, edge in pairs(removed) do
                gutils.add_edge(split_graph, edge.start, edge.stop, edge)
            end
            return sort_info
        end
        -- A sort of the game (first pass's graph, with earlier handlers' up-front choices) where these heads start cut off and are connected again one at a time, each once nothing else is left to reach, the one whose base was reached earliest first, leaving the graph as it was
        -- Returns the sort and head key --> how many pebbles it had sorted when that head was connected (none for a head whose base it never reached): whatever came before doesn't need the head, nor any head connected after it
        -- So a handler choosing, for each of these heads, a base sorted before the head's entry chooses no cycle (research triggers, handlers/tech-triggers.lua)
        -- It sorts in the order things become reachable (without choose_randomly, see top.sort), with plain room contexts, which say whether something can be had at all without the heads, several times faster than ability contexts
        -- With no heads it's a plain sort of the game in that order, whose ranks say how early something can be had, which a random order doesn't (there, late things on one planet can come right next to the first ones on another)
        local function sort_deferring(head_keys)
            local removed = {}
            local added = {}
            for head_key, base_key in pairs(up_front) do
                for pre, _ in pairs(table.deepcopy(split_graph.nodes[head_key].pre)) do
                    table.insert(removed, table.deepcopy(split_graph.edges[pre]))
                    gutils.remove_edge(split_graph, pre)
                end
                local abilities = head_to_handler[head_key].connection_abilities(split_graph.nodes[base_key], split_graph.nodes[head_key])
                table.insert(added, gutils.ekey(gutils.connect_base_head(split_graph, base_key, head_key, abilities)))
            end
            -- Head key --> the edges into it, cut until it's connected
            local cut = {}
            for _, head_key in pairs(head_keys) do
                local edges = {}
                for pre, _ in pairs(table.deepcopy(split_graph.nodes[head_key].pre)) do
                    table.insert(edges, table.deepcopy(split_graph.edges[pre]))
                    gutils.remove_edge(split_graph, pre)
                end
                cut[head_key] = edges
            end
            local extra = {}
            local sort_info = top.sort(split_graph, nil, nil, extra)
            local entry = {}
            while true do
                local next_head
                local next_ind
                for head_key, edges in pairs(cut) do
                    for _, edge in pairs(edges) do
                        for _, ind in pairs(sort_info.node_to_context_inds[edge.start] or {}) do
                            if next_ind == nil or ind < next_ind or (ind == next_ind and head_key < next_head) then
                                next_head = head_key
                                next_ind = ind
                            end
                        end
                    end
                end
                if next_head == nil then
                    break
                end
                entry[next_head] = #sort_info.pebble_keys
                for _, edge in pairs(cut[next_head]) do
                    gutils.add_edge(split_graph, edge.start, edge.stop, edge)
                    sort_info = top.sort(split_graph, sort_info, {
                        split_graph.nodes[edge.start],
                        split_graph.nodes[edge.stop],
                    }, extra)
                end
                cut[next_head] = nil
            end
            for _, edges in pairs(cut) do
                for _, edge in pairs(edges) do
                    gutils.add_edge(split_graph, edge.start, edge.stop, edge)
                end
            end
            for _, edge_key in pairs(added) do
                gutils.remove_edge(split_graph, edge_key)
            end
            for _, edge in pairs(removed) do
                gutils.add_edge(split_graph, edge.start, edge.stop, edge)
            end
            return sort_info, entry
        end
        -- Each handler's heads of randomized dependents
        local handler_heads = {}
        for _, dep in pairs(sorted_deps) do
            for _, head_key in pairs(dep_to_heads[dep]) do
                local handler_id = head_to_handler[head_key].id
                handler_heads[handler_id] = handler_heads[handler_id] or {}
                table.insert(handler_heads[handler_id], head_key)
            end
        end
        for _, handler_id in pairs(handler_ids) do
            local handler = handlers[handler_id]
            local choices = handler.choose_up_front({
                heads = handler_heads[handler.id] or {},
                pool = handler_to_shuffled_prereqs[handler.id],
                random_graph = random_graph,
                baseline_sort = first_pass_info.sort,
                baseline_graph = first_pass_info.graph,
                planet_locked = first_pass_info.planet_locked,
                sort_without = sort_without,
                sort_deferring = sort_deferring,
            })
            for head_key, base_key in pairs(choices) do
                up_front[head_key] = base_key
            end
        end
    end

    -- One promotion state shared by the generic handlers below and custom searches (like recipe ingredients) after
    -- With first pass, it must reason over first pass's split graph, which is the model reflection builds
    local prom
    if USE_PROMOTION then
        prom = promotion.new({
            graph = (do_first_pass and first_pass_info.graph) or random_graph,
            -- Starting from the choices made up front
            head_to_base = up_front,
            pool_sort_info = sort_for_pool,
            complex = PROMOTION_COMPLEX_CONTEXTS,
            debt = debt,
            -- Contexts recipes locked to one planet keep, from first pass's sort of the game before randomization
            planet_locked = (first_pass_info or {}).planet_locked,
            -- A head's handler says what connecting a base to it gains or loses (e.g. entity randomization's pairing table)
            connection_abilities = function(base, head)
                local handler = head_to_handler[key(head)]
                if handler == nil then
                    return base.abilities
                end
                return handler.connection_abilities(base, head)
            end,
        })
        local failed = prom.promise_mechanics()
        local num_single_context_recipes = prom.promise_single_context_recipes()
        log("Promotion: promised " .. num_single_context_recipes .. " recipes that are reachable in only one context")
        log("Promotion: promised " .. prom.num_promised .. " pebbles for mechanics; " .. #failed .. " mechanic pebbles could not be established; " .. tostring(prom.num_lost_before) .. " mechanic contexts and " .. tostring(prom.num_recipes_lost_before) .. " recipes already lost before randomization")
        prom.log_debt("start")
    end

    -- Decisions handlers make for every dependent before any head is randomized, like the shapes recipes take (see handlers/default.lua, before_heads)
    for _, handler_id in pairs(repair_only and {} or handler_ids) do
        handlers[handler_id].before_heads({
            random_graph = random_graph,
            promotion = prom,
            sorted_deps = sorted_deps,
            split_graph = (first_pass_info or {}).graph,
            trav_to_slot = (first_pass_info or {}).trav_to_slot,
            do_first_pass = do_first_pass,
        })
    end

    -- TODO: Tech delinearization (pull out to a helper)
    -- Might be defunct now that I'm doing tech tree reconstruction

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

        if not do_first_pass then
            return all_contexts_reachable(key(base), key(head), ignore_nil_contexts)
        else
            local base_owner = gutils.get_owner(random_graph, base)
            local head_owner = gutils.get_owner(random_graph, head)
            return all_contexts_reachable(node_to_first_pass_slot(base_owner), node_to_first_pass_slot(head_owner), ignore_nil_contexts)
        end
    end

    local head_to_base = table.deepcopy(up_front)
    local handler_to_used_prereq_inds = {}
    -- Heads at chunk boundaries (debt mode) whose new base pays for their dependent
    local num_paying_heads = 0
    -- For handlers with a stay_chance: their heads, how many tried to keep their old connection, and how many kept it (in all, and of those that tried)
    local handler_to_stay_stats = {}
    for _, handler in pairs(handlers) do
        handler_to_used_prereq_inds[handler.id] = {}
    end
    for dep_ind, dep in pairs(sorted_deps) do
        if #dep_to_heads[dep] > 0 then
            local context_str = ""
            if do_first_pass then
                context_str = old_sorted_deps[dep_ind]
            end
            log("\nRandomizing " .. dep .. " (" .. context_str .. ")")
        end

        local handler_to_heads = {}

        -- Contexts this dep must keep; computed only if a generic handler randomizes one of its heads
        local required_contexts
        if prom ~= nil then
            for _, head_key in pairs(dep_to_heads[dep]) do
                if head_to_handler[head_key].custom_prereq_search == false and up_front[head_key] == nil and required_contexts == nil then
                    required_contexts = prom.required_contexts(dep)
                    if #required_contexts == 0 and random_graph.nodes[dep].type == "recipe" and prom.initially_reachable(dep) then
                        -- Every recipe must stay reachable
                        log("Promotion: " .. dep .. " can no longer be reached in any context")
                        return false
                    end
                end
            end
        end

        for _, head_key in pairs(dep_to_heads[dep]) do
            local head = random_graph.nodes[head_key]
            local found_prereq = false
            local handler_id = head_to_handler[head_key].id
            local shuffled_prereqs = handler_to_shuffled_prereqs[handler_id]

            local repair_contexts = {}
            if repair_only and head_to_handler[head_key].custom_prereq_search == false and required_contexts ~= nil then
                repair_contexts = prom.head_boundary_contexts(head_key, required_contexts)
            end
            if repair_only and head_to_handler[head_key].custom_prereq_search == false and #repair_contexts == 0 then
                -- Satisfied prerequisites remain exactly as they are.
                head_to_base[head_key] = head.old_base
            elseif up_front[head_key] ~= nil then
                -- Chosen up front, which promotion started from
                log("Chosen up front: " .. key(gutils.get_owner(random_graph, random_graph.nodes[up_front[head_key]])))
            elseif head_to_handler[head_key].custom_prereq_search ~= false then
                -- Custom handling, which will be done later
                handler_to_heads[handler_id] = handler_to_heads[handler_id] or {}
                table.insert(handler_to_heads[handler_id], head_key)
            else
                -- At a chunk boundary (debt mode: the head's dependent owes something only through this head, see skeleton/promotion.lua), bases that pay for it go first
                local order = {}
                local later = {}
                local paying_contexts = (prom ~= nil and #required_contexts > 0) and prom.head_boundary_contexts(head_key, required_contexts) or {}
                for ind = 1, #shuffled_prereqs do
                    if #paying_contexts > 0 and prom.head_pays(head_key, shuffled_prereqs[ind], paying_contexts) then
                        table.insert(order, ind)
                    else
                        table.insert(later, ind)
                    end
                end
                if #paying_contexts > 0 then
                    log("Promotion: boundary head of " .. dep .. " (" .. handler_id .. ") in " .. table.concat(top.context_names(paying_contexts), ", ") .. ": " .. #order .. " of " .. #shuffled_prereqs .. " bases pay")
                end
                -- A head that rolls under its handler's stay_chance tries the bases that keep its old connection (the handler's stays) first among the paying bases and among the rest, so paying bases still go first
                local stay_stats
                local tries_to_stay = false
                local stay_chance = head_to_handler[head_key].stay_chance
                if not repair_only and handler_id == "recipe-category" then
                    stay_chance = (tonumber(graph_customization.fields(handler_id).keep_category) or stay_chance * 100) / 100
                end
                if stay_chance > 0 then
                    handler_to_stay_stats[handler_id] = handler_to_stay_stats[handler_id] or {
                        heads = 0,
                        tried = 0,
                        kept = 0,
                        kept_tried = 0,
                    }
                    stay_stats = handler_to_stay_stats[handler_id]
                    stay_stats.heads = stay_stats.heads + 1
                    tries_to_stay = rng.value(rng.key({id = "unified-stay"})) < stay_chance
                end
                if tries_to_stay then
                    stay_stats.tried = stay_stats.tried + 1
                    local function staying_first(inds)
                        local first = {}
                        local rest = {}
                        for _, ind in pairs(inds) do
                            if head_to_handler[head_key].stays(random_graph, random_graph.nodes[shuffled_prereqs[ind]], head) then
                                table.insert(first, ind)
                            else
                                table.insert(rest, ind)
                            end
                        end
                        for _, ind in pairs(rest) do
                            table.insert(first, ind)
                        end
                        return first
                    end
                    order = staying_first(order)
                    later = staying_first(later)
                end
                for _, ind in pairs(later) do
                    table.insert(order, ind)
                end
                for _, ind in pairs(order) do
                    local base_key = shuffled_prereqs[ind]
                    local base = random_graph.nodes[base_key]

                    -- TEST: Check for nil base or head
                    if base == nil or head == nil then
                        log(base_key)
                        log(head_key)
                        error("Randomization assertion failed! Tell exfret he's a dumbo.")
                    end

                    local is_context_reachable
                    if prom ~= nil then
                        is_context_reachable = #required_contexts == 0 or prom.head_candidate_ok(head_key, base_key, required_contexts)
                    else
                        is_context_reachable = get_context_reachable(base, head)
                    end

                    if repair_only then
                        is_context_reachable = is_context_reachable and prom.head_pays(head_key, base_key, repair_contexts)
                    end
                    if not handler_to_used_prereq_inds[handler_id][ind] and is_context_reachable then
                        -- Have head's handler validate this base

                        if head_to_handler[head_key].validate(random_graph, base, head, {
                            init_sort = sort_for_claiming, -- Needed for tech rando
                        }) then
                            local origin = "pool-only source"
                            if base.pool_only ~= true then
                                origin = key(gutils.get_owner(random_graph, random_graph.nodes[base.old_head]))
                            end
                            log("Accepted prereq " .. key(gutils.get_owner(random_graph, base)) .. " (" .. origin .. ") for " .. dep .. (#paying_contexts > 0 and (prom.head_pays(head_key, base_key, paying_contexts) and " (pays)" or " (doesn't pay)") or ""))
                            head_to_handler[head_key].process(random_graph, base, head)
                            found_prereq = true
                            handler_to_used_prereq_inds[handler_id][ind] = true
                            head_to_base[head_key] = base_key
                            if prom ~= nil then
                                if #paying_contexts > 0 and prom.head_pays(head_key, base_key, paying_contexts) then
                                    num_paying_heads = num_paying_heads + 1
                                end
                                prom.resolve_head(head_key, base_key, required_contexts)
                            end

                            if head_to_handler[head_key].with_replacement then
                                table.insert(shuffled_prereqs, base_key)
                            end

                            break
                        end
                    end
                end
                if not found_prereq and prom ~= nil then
                    -- Fall back to the vanilla base, which promotion guarantees is valid in the required contexts
                    local base_key = head.old_base
                    log("Prereq shuffle found nothing for " .. head_key .. "; falling back to vanilla base")
                    head_to_handler[head_key].process(random_graph, random_graph.nodes[base_key], head)
                    head_to_base[head_key] = base_key
                    prom.resolve_head(head_key, base_key, required_contexts)
                    found_prereq = true
                end
                if stay_stats ~= nil and found_prereq and head_to_handler[head_key].stays(random_graph, random_graph.nodes[head_to_base[head_key]], head) then
                    stay_stats.kept = stay_stats.kept + 1
                    if tries_to_stay then
                        stay_stats.kept_tried = stay_stats.kept_tried + 1
                    end
                end
                if not found_prereq then
                    --log_info(2, serpent.block(shuffled_prereqs))
                    log(head_key)
                    local percentage = math.floor(100 * dep_ind / #sorted_deps)
                    log("Prereq shuffle failed at " .. tostring(percentage) .. "%")
                end
            end
        end
    end
    for handler_id, stats in pairs(handler_to_stay_stats) do
        log("STAY " .. handler_id .. ": " .. stats.kept .. " of " .. stats.heads .. " heads kept their old connection; " .. stats.kept_tried .. " of the " .. stats.tried .. " that tried to first")
    end
    if prom ~= nil then
        log("Promotion: " .. num_paying_heads .. " heads at chunk boundaries took bases that pay for them")
    end
    for _, handler in pairs(handlers) do
        if handler.custom_prereq_search ~= false then
            local search_deps = sorted_deps
            if repair_only then
                search_deps = {}
                for _, dep in pairs(sorted_deps) do
                    local contexts = prom.required_contexts(dep)
                    if #prom.recipe_boundary_contexts(dep, contexts) > 0 then
                        table.insert(search_deps, dep)
                    end
                end
            end
            local search_result = handler.custom_prereq_search({
                random_graph = random_graph,
                -- Generic handlers' choices, which aren't added as edges to random_graph
                head_to_base = head_to_base,
                promotion = prom,
                split_graph = (first_pass_info or {}).graph,
                sorted_deps = search_deps,
                repair_only = repair_only,
                shuffled_prereqs = handler_to_shuffled_prereqs[handler.id],
                sort_for_pool = sort_for_pool,
                trav_to_slot = (first_pass_info or {}).trav_to_slot,
                slot_to_trav = (first_pass_info or {}).slot_to_trav,
                do_first_pass = do_first_pass,
                mechanics_sets_to_ordered = (first_pass_info or {}).mechanics_sets_to_ordered,
                mechanics_sets_to_nodes = (first_pass_info or {}).mechanics_sets_to_nodes,
                trav_to_mechanics_key = (first_pass_info or {}).trav_to_mechanics_key,
            })
            if search_result == false then
                log("Failure at ?%")
                return false
            end
        end
    end
    if prom ~= nil then
        prom.log_debt("end")
        -- Custom searches can promise new backings after the recipe search saved its snapshot, so the built-game audit must use the completed model.
        UNIFIED_PROMISED_PEBBLES = prom.promised_pebbles()
    else
        UNIFIED_PROMISED_PEBBLES = nil
    end

    ----------------------------------------------------------------------------------------------------
    log_info(2, "REFLECT")
    ----------------------------------------------------------------------------------------------------

    if repair_only then
        -- Reflection can have side effects even for an unchanged base (e.g. energy sources).
        for head_key, base_key in pairs(head_to_base) do
            if base_key == random_graph.nodes[head_key].old_base then
                head_to_base[head_key] = nil
            end
        end
    end
    changes = {}
    -- Entity randomization reflects before item randomization, which copies item names and icons into recipes (see handlers.md)
    -- Spoiling does too, since it writes spoil results as positions, which item randomization renames to the items first pass put there
    -- Research triggers too, since item randomization rewrites a craft-item trigger to the item first pass put at its position, reading the trigger the technology has when it reflects
    local reflect_first = {
        "recipe-ingredients-first-pass",
        "entity",
        "spoiling",
        "tech-triggers",
    }
    local reflects_first = {}
    for _, handler_id in pairs(reflect_first) do
        reflects_first[handler_id] = true
        if handlers[handler_id] ~= nil then
            handlers[handler_id].reflect(random_graph, head_to_base, head_to_handler)
        end
    end
    for handler_id, handler in pairs(handlers) do
        if reflects_first[handler_id] == nil then
            handler.reflect(random_graph, head_to_base, head_to_handler)
        end
    end
    for _, change in pairs(changes) do
        if change.multiplier then
            if change.tbl[change.prop] ~= nil then
                change.tbl[change.prop] = change.multiplier * change.tbl[change.prop]
            end
        else
            change.tbl[change.prop] = change.new_val
        end
    end
    for _, change in pairs(changes) do
        if change.is_ing_or_result and change.tbl[change.prop] ~= nil then
            if change.tbl.type == "item" then
                local item
                for item_class, _ in pairs(defines.prototypes.item) do
                    if (data.raw[item_class] or {})[change.tbl.name] ~= nil then
                        item = data.raw[item_class][change.tbl.name]
                        break
                    end
                end
                -- If we have to raise it from 2/3 or below and this is in the ingredients, this is an expensive ingredient, so give some of it back
                if change.ingredients and change.prop == "amount" and change.tbl[change.prop] <= 2 / 3 then
                    local recipe_name_to_use = change.recipe.name
                    if handlers["recipe-ingredients-first-pass"] ~= nil then
                        recipe_name_to_use = random_graph.nodes[handlers["recipe-ingredients-first-pass"].trav_to_slot[gutils.key("recipe", make_trav_name(change.recipe.name))]].name
                    end
                    local recipe_to_use = data.raw.recipe[recipe_name_to_use]

                    local cost_over_reasonable = (3 / 2) / change.tbl[change.prop]
                    -- You "should" only pay up to the cost_reasonable, which would correspond to 1 / cost_over_reasonable amount of the 1 thing, so you get 1 minus this amount back
                    local amount_back = 1 - 1 / cost_over_reasonable
                    recycling.add_item_refund(old_data_raw, recipe_to_use, change.tbl.name, amount_back)
                end
                change.tbl[change.prop] = math.max(1, math.floor(0.5 + change.tbl[change.prop]))
                if not dutils.is_stackable(item) then
                    change.tbl[change.prop] = 1
                else
                    change.tbl[change.prop] = math.min(65535, change.tbl[change.prop])
                end
            else
                -- A fluid's amount can be fractional, to two decimals (user, 2026-09-29; items and fluids trading positions scale amounts across forms)
                if config.item_fluids and change.tbl.type == "fluid" then
                    change.tbl[change.prop] = item_fluid.round_amount("fluid", change.tbl[change.prop])
                end
                change.tbl[change.prop] = math.min(65535, change.tbl[change.prop])
            end
        end
    end
    for _, handler in pairs(handlers) do
        handler.after_changes()
    end
    -- Same-form item renames can leave amounts untouched; validate their final identities too.
    local corrected_amounts = recipe_item_amounts.apply(data.raw)
    if corrected_amounts > 0 then
        log("Item amounts: corrected " .. corrected_amounts .. " non-stackable recipe entries after reflection")
    end
    if not repair_only then
        for _, handler_id in pairs(handler_ids) do
            if handlers[handler_id].after_reflection({
                random_graph = random_graph,
                split_graph = (first_pass_info or {}).graph,
                promotion = prom,
            }) == false then
                return false
            end
        end
        if prom ~= nil then
            UNIFIED_PROMISED_PEBBLES = prom.promised_pebbles()
        end
    end

    if SWITCH_PLANETS then
        local start = constants.starting_planet
        local old_start = table.deepcopy(data.raw.planet[start])
        data.raw.planet[start] = table.deepcopy(data.raw.planet.vulcanus)
        data.raw.planet[start].name = start
        data.raw.planet.vulcanus = old_start
        data.raw.planet.vulcanus.name = "vulcanus"
    end

    if not repair_only then
        for _, line in pairs(graph_customization.report()) do
            log(line)
        end
        local customization_failures = graph_customization.check_material_renames(UNIFIED_MATERIAL_RENAMES)
        if #customization_failures > 0 then
            log("Graph customization lost fixed material identities: " .. table.concat(customization_failures, ", "))
            return false
        end
    end
    -- Only what later stages read (first pass's slot_to_trav, for the randomizer panel), so the attempt's graphs and sorts don't stay in memory for the rest of the load
    return {
        slot_to_trav = (first_pass_info or {}).slot_to_trav,
    }
end

-- Runs one attempt of unified randomization, returning false if it failed (so it's retried), and otherwise what later stages read from it
-- Then lets go of what only the attempt needed: the game as it started (unified_starting_data_raw) and what handlers kept from it (their release), so none of it stays in memory through later attempts and stages
unified.execute = function(options)
    local result = attempt(options)
    unified_starting_data_raw = nil
    for _, handler in pairs(available_handlers) do
        if handler.release ~= nil then
            handler.release()
        end
    end
    return result
end

return unified
