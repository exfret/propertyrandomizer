-- Differences with first-pass.lua:
--  * Doesn't use base/head terminology, but rather a .slot = true or .trav = true key property; nodes are still of the same type (though slot keeps name)

-- TODO: Filter out things from first pass that are "boring" (maybe in adding no mechanics)

-- TODO: Tests for loop subroutines
--   * Bring loop subroutines out
-- TODO: Logging levels
--
-- (SOLVED) Current issue: Getting lost on recipe tech unlocks (with recipes completely detached)
--     My guess at what's happening is that it assumes these recipes are therefore immediately satisfiable, but they still need a technology beforehand
--     Thus, we need to check for prereq slots of the right type/enough prereqs first
-- Okay, I did that but now...
--     a) It's super duper slow
--     b) The ordering is super vanilla
--     c) The issue isn't fixed (light oil barrels need a particular crafting category and we only check prereq types)
-- Idea:
--     Ways to get unstuck in the beginning are often different from what you need mid-game. Gun turrets are eventually needed in spage, but not initially, so can be put off even if they're on the critical path
-- (SOLVED-ISH) NOW: Things coming before on nauvis but after on other places
--      I tried a solution but it seems logistic science packs now aren't being put after hand crafting
-- NEXT: Gleba things that are naturally early aren't used early (like biochambers)

local MAX_ITERATIONS = 10000
-- CRITICAL TODO: Change back
local FAILURE_ACCEPTANCE = 0.5
-- TODO: This could be set with a startup settings
local DO_TESTS = false
-- Require a node to unlock some mechanic to be considered important
-- This seemed to make things worse, but I think the general idea is still valid, so keeping this hear for future reference
local REQUIRE_MECHANICS_FOR_IMPORTANCE = true
-- A similar idea for needing something of a different canonical class, mostly just applies to the item slot trav rando
local REQUIRE_DIFFERENT_CANONICAL_FOR_IMPORTANCE = true
-- Disabled because it was slow
local PUT_PATH_SLOTS_FIRST = false
local DO_PREREQ_POOL_CHECK = false
local DO_SLOTS_IN_ORDER = true
local CHECK_SAME_MECHANICS = true
local DO_ITEM_RANDO
local EXCLUDE_SCIENCE = true
-- Exclude key things, like stone furnaces
local EXCLUDE_SENSITIVE = false
local EXCLUDE_RECIPES = true
local SPECIAL_RECIPE_FIRST_PASS = true
local EXCLUDE_TECHS = true
local EXCLUDE_ENTITY_OPERATE = true
local REPORT_PATH = false
local REPORT_SIZE_STATS = true
local REPORT_STARTING_TRAVS = false
local REPORT_SLOTS_FAILED = false

local constants = require("helper-tables/constants")
local rng = require("lib/random/rng")
-- TODO: Better flow cost library!
local flow_cost = require("lib/cost/flow-cost")
-- Used for contexts
local logic = require("lib/logic/init")
local lutils = require("lib/logic/logic-utils")
local gutils = require("lib/graph/graph-utils")
local dutils = require("lib/data-utils")
local top = require("lib/graph/consistent-sort")
local first_pass_balance = require("randomizations/graph/unified/first-pass-balance")
local test_graph_invariants = require("tests/graph-invariants")

local base_costs = require("lib/cost/material-costs/sa")
local py_costs = require("lib/cost/material-costs/py-full")

local material_costs = base_costs
if mods["pypostprocessing"] then
    material_costs = py_costs
end

local key = gutils.key

local first_pass = {}

local trav_suffix = "-trav"
local function make_trav_name(old_name)
    return old_name .. trav_suffix
end
first_pass.make_trav_name = make_trav_name
local function undo_trav_name(trav_name)
    assert(string.sub(trav_name, -#trav_suffix, -1) == trav_suffix)
    return string.sub(trav_name, 1, -(#trav_suffix + 1))
end
first_pass.undo_trav_name = undo_trav_name

local function is_canonical_result(mat_or_recipe_name)
    local is_science_pack = {}
    for _, lab in pairs(data.raw.lab) do
        for _, input in pairs(lab.inputs) do
            is_science_pack[input] = true
        end
    end
    local recipe = data.raw.recipe[mat_or_recipe_name]
    if recipe == nil or recipe.results == nil or #recipe.results ~= 1 or recipe.results[1].name ~= recipe.name then
        return false
    end
    if EXCLUDE_SCIENCE and is_science_pack[mat_or_recipe_name] then
        return false
    end
    if randomization_info.options.first_pass.blacklist[key("recipe", mat_or_recipe_name)] then
        return false
    end
    if randomization_info.options.first_pass.blacklist[key("item", mat_or_recipe_name)] then
        return false
    end
    if randomization_info.options.first_pass.blacklist[key("fluid", mat_or_recipe_name)] then
        return false
    end
    -- TODO: Don't assume base game in the future!
    -- Make sure all ingredients have costs
    for _, ing in pairs(recipe.ingredients or {}) do
        if type(base_costs.costs[gutils.key(ing)]) ~= "number" then
            return false
        end
    end
    -- Just here to hotfix a bug
    if mat_or_recipe_name == "satellite" then
        return false
    end
    -- TODO: We might need to make sure that the item also is *only* gotten from the recipe (or some other *later* ways like mining the building that it places)
    return true
end
first_pass.is_canonical_result = is_canonical_result

local recipe_first_pass_node_types = {
    ["recipe"] = true,
    ["entity-mine"] = true, -- Only for resources
    ["fluid-create-offshore-temperature"] = true, -- Use filtered pumps
    ["item-launch"] = true,
    -- Think about entity output fluids, like water --> steam in boilers
}
local function valid_for_recipe_first_pass(node)
    -- CRITICAL TODO
end

first_pass.execute = function(params)
    DO_ITEM_RANDO = ITEM_ENABLED

    ----------------------------------------------------------------------------------------------------
    -- CREATE PERMUTATION
    ----------------------------------------------------------------------------------------------------

    -- spoofed_graph is used to get prereqs before subdivision
    local spoofed_graph = table.deepcopy(params.spoofed_graph)
    local subdiv_graph = table.deepcopy(params.subdiv_graph)

    local init_sort
    if not mods["pyalternativeenergy"] then
        init_sort = top.sort(spoofed_graph, nil, nil, { choose_randomly = true })
    else
        -- For py specifically, sort based on sciences now, since tiers are very important in py
        local packs_in_order = {
            "automation-science-pack",
            "py-science-pack-1",
            "logistic-science-pack",
            "military-science-pack",
            "py-science-pack-2",
            "chemical-science-pack",
            "py-science-pack-3",
            "production-science-pack",
            "py-science-pack-4",
            "utility-science-pack",
            "space-science-pack",
            "full-pyrrhic-victory",
        }
        local graph_for_init_sort = table.deepcopy(spoofed_graph)
        local packs_to_deps = {}
        local deps_to_falses = {}
        for i = 1, #packs_in_order - 1 do
            local science_node = graph_for_init_sort.nodes[key("item", packs_in_order[i])]
            packs_to_deps[packs_in_order[i]] = {}
            local deps_to_remove = {}
            for dep, _ in pairs(science_node.dep) do
                table.insert(deps_to_remove, dep)
                local edge = graph_for_init_sort.edges[dep]
                table.insert(packs_to_deps[packs_in_order[i]], {edge.start, edge.stop, dep})
            end
            for _, dep in pairs(deps_to_remove) do
                local false_node = graph_for_init_sort.nodes[key("false", science_node.name)]
                if false_node == nil then
                    false_node = gutils.add_node(graph_for_init_sort, "false", science_node.name)
                    false_node.op = "OR"
                end
                deps_to_falses[dep] = gutils.add_edge(graph_for_init_sort, key(false_node), graph_for_init_sort.edges[dep].stop)
                gutils.remove_edge(graph_for_init_sort, dep)
            end
        end
        init_sort = top.sort(graph_for_init_sort, nil, nil, { choose_randomly = true })
        for i = 1, #packs_in_order - 1 do
            for _, edge_info in pairs(packs_to_deps[packs_in_order[i]]) do
                local false_edge = deps_to_falses[edge_info[3]]
                gutils.remove_edge(graph_for_init_sort, gutils.ekey(false_edge))
                gutils.add_edge(graph_for_init_sort, edge_info[1], edge_info[2])
                init_sort = top.sort(graph_for_init_sort, init_sort, {graph_for_init_sort.nodes[edge_info[1]], graph_for_init_sort.nodes[edge_info[2]]}, { choose_randomly = true, do_new_edge_processing = true })
            end
        end
    end

    --local in_balance_blacklist = first_pass_balance.find_balance_blacklist(spoofed_graph, init_sort)

    local sensitive_node_keys = {
        [key("item", "stone-furnace")] = true,
        [key("item", "pipe")] = true,
    }
    if mods["pypostprocessing"] then
        sensitive_node_keys[key("item", "raw-coal")] = true
        sensitive_node_keys[key("item", "boiler")] = true
    end
    -- Burnt results are special
    for burnt_result, _ in pairs(lu.burnt_result_to_items) do
        sensitive_node_keys[key("item", burnt_result)] = true
    end
    for _, item in pairs(lu.items) do
        if item.burnt_result ~= nil and item.burnt_result ~= "ash" then
            sensitive_node_keys[key("item", item.name)] = true
        end
    end
    -- So are rocket launch results
    for item_name, _ in pairs(lu.silo_items) do
        sensitive_node_keys[key("item", item_name)] = true
    end
    for item_name, _ in pairs(lu.rocket_results_to_items) do
        sensitive_node_keys[key("item", item_name)] = true
    end
    for _, item in pairs(lu.items) do
        if item.rocket_launch_products ~= nil then
            sensitive_node_keys[key("item", item.name)] = true
        end
    end
    local function valid_node_for_first_pass(node_key)
        -- Just check if at least one of its edges are randomized, or in other words that one of the pre's in subdiv graph are a head
        local subdiv_node = subdiv_graph.nodes[node_key]
        if subdiv_node.spoof then
            return false
        end
        if randomization_info.options.first_pass.blacklist[node_key] then
            return false
        end
        -- Exclude entity-mine nodes; not much reason to change order of resource mining and that might make non-starter ores too used
        if subdiv_node.type == "entity-mine" then
            return false
        end
        local is_science_pack = {}
        for _, lab in pairs(data.raw.lab) do
            for _, input in pairs(lab.inputs) do
                is_science_pack[input] = true
            end
        end
        if EXCLUDE_SCIENCE and subdiv_node.type == "item" and is_science_pack[subdiv_node.name] ~= nil then
            return false
        end
        if EXCLUDE_SENSITIVE and sensitive_node_keys[key(subdiv_node)] then
            return false
        end
        if EXCLUDE_RECIPES and subdiv_node.type == "recipe" then
            return false
        end
        if SPECIAL_RECIPE_FIRST_PASS and subdiv_node.type == "recipe" then
            if is_canonical_result(subdiv_node.name) then
                return true
            end
        end
        if EXCLUDE_TECHS and subdiv_node.type == "technology" then
            return false
        end
        if EXCLUDE_ENTITY_OPERATE and subdiv_node.type == "entity-operate" then
            return false
        end
        --[[if in_balance_blacklist[node_key] then
            return false
        end]]
        -- CRITICAL TODO: A better method for determining blacklistedness!
        --[[if in_balance_blacklist[subdiv_node.name] then
            return false
        end]]
        for _, prenode in pairs(gutils.prenodes(subdiv_graph, subdiv_node)) do
            if prenode.type == "head" then
                return true
            end
        end
        if DO_ITEM_RANDO and subdiv_node.type == "item" then
            return true
        end
        return false
    end

    local node_in_sorted = {}
    local sorted_node_inds = {}
    for ind, pebble in pairs(init_sort.sorted) do
        if node_in_sorted[pebble.node_key] == nil and valid_node_for_first_pass(pebble.node_key) then
            node_in_sorted[pebble.node_key] = ind
            table.insert(sorted_node_inds, ind)
        end
    end

    -- Permutation to attempt on sorted_node_inds
    local perm = {}
    for i = 1, #sorted_node_inds do
        table.insert(perm, i)
    end
    rng.shuffle(rng.key({id = "unified"}), perm)

    ----------------------------------------------------------------------------------------------------
    -- FIND PATH
    ----------------------------------------------------------------------------------------------------

    -- First create goal nodes: sciences
    -- TODO: This just tests for ability to create sciences, not whether you can launch a ship to beat the game, actually research with the sciences, etc., so I could check those in the future
    -- TODO: This assumes nauvis context; we could be more flexible later
    local is_science_pack = {}
    for _, lab in pairs(data.raw.lab) do
        for _, input in pairs(lab.inputs) do
            is_science_pack[key("item", input)] = true
        end
    end
    local starting_planet_context = key("planet", constants.starting_planet)
    local goal_inds = {}
    for ind, pebble in pairs(init_sort.sorted) do
        if is_science_pack[pebble.node_key] and pebble.context == starting_planet_context then
            table.insert(goal_inds, ind)
        end
    end
    local path_info = top.path(spoofed_graph, goal_inds, init_sort)
    local is_important = {}
    for ind, pebble in pairs(init_sort.sorted) do
        if path_info.in_path[ind] then
            is_important[pebble.node_key] = true
        end
    end
    if REPORT_PATH then
        log(serpent.block(is_important))
    end

    local ordered_mechanics = {}
    local already_included_in_ordered_mechanics = {}
    for ind, pebble in pairs(init_sort.sorted) do
        local node = spoofed_graph.nodes[pebble.node_key]
        if (path_info.in_path[ind] or node.important) and node.mechanic and node.type ~= "orand" and not already_included_in_ordered_mechanics[pebble.node_key] then
            already_included_in_ordered_mechanics[pebble.node_key] = true
            table.insert(ordered_mechanics, pebble.node_key)
        end
    end
    log(serpent.block(ordered_mechanics))
    local curr_mechanic_index = 1
    
    local slot_inds = {}
    if PUT_PATH_SLOTS_FIRST then
        local in_path_in_order = {}
        local not_in_path_in_order = {}
        for _, ind in pairs(sorted_node_inds) do
            if path_info.in_path[ind] then
                table.insert(in_path_in_order, ind)
            else
                table.insert(not_in_path_in_order, ind)
            end
        end
        for _, ind in pairs(in_path_in_order) do
            table.insert(slot_inds, ind)
        end
        for _, ind in pairs(not_in_path_in_order) do
            table.insert(slot_inds, ind)
        end
    else
        slot_inds = sorted_node_inds
    end

    ----------------------------------------------------------------------------------------------------
    -- SPLIT GRAPH NODES
    ----------------------------------------------------------------------------------------------------

    local split_graph = table.deepcopy(subdiv_graph)

    -- TEST: Presumably, at least one edge should not be randomized
    local not_all_randomized = false

    -- Sends a slot to the head that connects it to a trav, and vice versa for trav and head
    local slot_to_base = {}
    local trav_to_head = {}
    for node_key, _ in pairs(node_in_sorted) do
        local node = split_graph.nodes[node_key]
        node.slot = true
        local trav = gutils.add_node(split_graph, node.type, make_trav_name(node.name))
        trav.op = node.op
        trav.trav = true
        trav.old_slot = node_key
        node.old_trav = key(trav)
        -- Randomized edges to slot, fixed to trav
        -- CRITICAL TODO: I am allowing non-dep nodes, so things without any randomized connections... does this create any issues?..
        --    Well, on that note, we need to keep track of the fact that some "normal" nodes (without the -trav in their name) will have fixed edges if they don't get that corresponding slot)
        --    Or wait, the fact we do things this way might prevent this? Just need to add tests.
        -- By construction, an edge is randomized exactly when it's subdivided, so we can just check for the existence of a head/base
        -- EDIT: I'm going back on that and randomizing
        local fixed_pre = {}
        for pre, _ in pairs(node.pre) do
            local prenode = gutils.prenode(split_graph, pre)
            if prenode.type == "orand" then
                prenode = gutils.unique_prenode(split_graph, prenode)
            end
            -- Special handling for recipe ingredients
            if SPECIAL_RECIPE_FIRST_PASS and node.type == "recipe" and is_canonical_result(node.name) then
                if prenode.type == "recipe-category" then
                    -- Stays with trav
                    if RECIPE_INGS_DIR ~= "BACKWARD" then
                        fixed_pre[pre] = true
                        not_all_randomized = true
                    end
                elseif prenode.type == "recipe-unlock" then
                    -- Stays with slot
                    -- Or maybe not?
                    --if RECIPE_INGS_DIR == "BACKWARD" then
                        --fixed_pre[pre] = true
                        --not_all_randomized = true
                    --end
                elseif prenode.type == "recipe-surface-condition" then
                    -- Stays with slot, for context reasons (not currently applicable since doing base game)
                    if RECIPE_INGS_DIR == "BACKWARD" then
                        fixed_pre[pre] = true
                        not_all_randomized = true
                    end
                elseif prenode.type == "recipe-py-module" then
                    -- Stays with trav (the actual recipe prototype goes with trav)
                    if RECIPE_INGS_DIR ~= "BACKWARD" then
                        fixed_pre[pre] = true
                        not_all_randomized = true
                    end
                elseif prenode.type == "item" or prenode.type == "fluid-temperature-range" then
                    -- *All* ingredents stay with trav
                    if RECIPE_INGS_DIR ~= "BACKWARD" then
                        -- Nevermind, let's keep non-canonical edges on slot
                        -- Nevermind again, softlocks
                        --if is_canonical_result(prenode.fluid or prenode.name) then
                            fixed_pre[pre] = true
                            not_all_randomized = true
                        --end
                    end
                end
            else
                local always_on_slot = false
                if randomization_info.options.first_pass.always_slot_pre[key(prenode.type, node.type)] then
                    always_on_slot = true
                    if (prenode.type == "tile-mine" or prenode.type == "entity-mine") and node.type == "item" then
                        local item_prot = dutils.get_prot("item", node.name)
                        -- If the item and entity/tile are supposed to correspond to each other, don't put on slot
                        if (prenode.type == "entity-mine" and item_prot.place_result == prenode.name) or (prenode.type == "tile-mine" and item_prot.place_as_tile ~= nil and item_prot.place_as_tile.result == prenode.name) then
                            always_on_slot = false
                        end
                    end
                end

                if prenode.type ~= "head" and not always_on_slot then
                    fixed_pre[pre] = true
                    not_all_randomized = true
                end
            end
        end
        for pre, _ in pairs(fixed_pre) do
            gutils.redirect_edge_stop(split_graph, pre, key(trav))
        end
        local fixed_dep = {}
        for dep, _ in pairs(node.dep) do
            local depnode = gutils.depnode(split_graph, dep)
            if depnode.type == "orand" then
                depnode = gutils.unique_depnode(split_graph, depnode)
            end
            -- Special handling for recipe ingredients
            if SPECIAL_RECIPE_FIRST_PASS and node.type == "recipe" and is_canonical_result(node.name) then
                -- In this case there should only be one outgoing edge, standing for the item/fluid-craft, which actually stays with the slot (this is what makes the matching nontrivial)
                if RECIPE_INGS_DIR == "BACKWARD" then
                    fixed_dep[dep] = true
                    not_all_randomized = true
                end
            else
                local always_on_slot = false
                if randomization_info.options.first_pass.always_slot_dep[key(node.type, depnode.type)] then
                    always_on_slot = true
                end

                -- TODO: Document/add to vanilla special handling of coal
                -- CRITICAL TODO: Test for pyanodons (uses raw coal instead)
                if depnode.type ~= "base" and not always_on_slot then --and (node_key ~= key("item", "coal") and (depnode.canonical ~= "item" or depnode.name ~= "coal")) then
                    fixed_dep[dep] = true
                    not_all_randomized = true
                end
            end
        end
        for dep, _ in pairs(fixed_dep) do
            gutils.redirect_edge_start(split_graph, dep, key(trav))
        end

        local slot_trav_edge = gutils.add_edge(split_graph, node, trav)
        local base_head = gutils.subdivide_base_head(split_graph, gutils.ekey(slot_trav_edge))
        slot_to_base[node_key] = base_head.base
        trav_to_head[key(trav)] = base_head.head
        local head = base_head.head
        local edge_to_sever = gutils.unique_pre(split_graph, head)
        gutils.remove_edge(split_graph, gutils.ekey(edge_to_sever))
        if SPECIAL_RECIPE_FIRST_PASS and node.type == "recipe" and is_canonical_result(node.name) and RECIPE_INGS_DIR ~= "BACKWARD" then
            -- I'm not sure how to deal with this in general, but we don't want the AND slot transmitting contexts without a matching traveler yet (in this case at least), so connect a false to it that we'll deal with later
            gutils.add_edge(split_graph, gutils.key("false", ""), gutils.key(node))
        end
    end
    test_graph_invariants.test(split_graph)

    if not not_all_randomized and DO_TESTS then
        error("It seems all edges are randomized?")
    end
    if REPORT_SIZE_STATS then
        local in_sorted_size = 0
        for _, _ in pairs(node_in_sorted) do
            in_sorted_size = in_sorted_size + 1
        end
        log("\n\nNUMBER SLOT/TRAVS: " .. tostring(in_sorted_size) .. "\n\n")
    end

    local old_split_graph = table.deepcopy(split_graph)
    local split_sort = top.sort(split_graph, nil, nil, { choose_randomly = true })

    ----------------------------------------------------------------------------------------------------
    -- HELPER FUNCTIONS
    ----------------------------------------------------------------------------------------------------
    
    local slot_to_trav = {}
    local trav_to_slot = {}
    local new_slot_order = {}

    local function ind_to_slot(ind)
        return split_graph.nodes[init_sort.sorted[ind].node_key]
    end
    local function ind_to_trav(ind)
        local slot_node = ind_to_slot(ind)
        local trav_type = slot_node.type
        local trav_name = make_trav_name(slot_node.name)
        return split_graph.nodes[key(trav_type, trav_name)]
    end

    -- Tests if the graph prenodes of node have a shared context in the *split sort* (regardless of the graph)
    -- Ignores heads (we assume we can make those the right context)
    local function node_prenodes_share_context(graph, node)
        for context, _ in pairs(logic.contexts) do
            local has_context = true
            for _, prenode in pairs(gutils.prenodes(graph, node)) do
                -- Don't involve the dangling connections for trav nodes
                if not node.trav or key(prenode) ~= key(trav_to_head[key(node)]) then
                    -- Make sure to also not include the false connections to some slots added to prevent them from being satisfied too early
                    if prenode.type ~= "false" and prenode.type ~= "head" and split_sort.node_to_context_inds[key(prenode)][context] == nil then
                        has_context = false
                        break
                    end
                end
            end
            if has_context then
                return true
            end
        end
        -- No valid context found
        return false
    end

    -- Checks that the slots that another slot would have depended on in vanilla (so fixed + randomized edges) are assigned
    -- This essentially checks whether this slot would have been reachable in a vanilla progression
    local function slot_vanilla_prereqs_assigned(slot)
        -- TEST: Make sure this is a slot
        if not slot.slot then
            log(serpent.block(slot))
            log(key(slot))
            error("Slot expected, but got different node type")
        end

        local spoofed_node = spoofed_graph.nodes[key(slot)]

        -- TEST: Make sure spoofed_node non-nil
        if spoofed_node == nil then
            log(serpent.block(slot))
            log(key(slot))
            error("slot doesn't exist in spoofed graph")
        end

        -- CRITICAL TODO: Make decision of how to do this/profiling
        -- Right now I'm deciding between prereqs assigned and checking contexts

        -- Actually, this approach doesn't work, since slot ... (I apparently never finished this sentence)
        --node_prenodes_share_context(spoofed_graph, spoofed_node)

        for _, prenode in pairs(gutils.prenodes(spoofed_graph, spoofed_node)) do
            local prenode_in_split_graph = split_graph.nodes[key(prenode)]

            if prenode_in_split_graph.slot and slot_to_trav[key(prenode)] == nil then
                return false
            end
        end
        return true
    end

    local function slot_acceptable(slot)
        -- TEST: Make sure this is a slot
        if not slot.slot then
            log(serpent.block(slot))
            log(key(slot))
            error("Slot expected, but got different node type")
        end

        -- TODO: There are many methods here, we should test them all out and choose the best
        --   * Call a slot acceptable if all its vanilla prereq *bases* have been satisfied by some context
        --      - Note that this checks other randomized contexts
        --      - I think this is what I was doing previously?
        --      - Actually, does that even make sense? Because then the slots would almost always go in order anyways
        --   * Call a slot acceptable if all the travelers for its old vanilla bases are assigned
        --      - This could make the sort too vanilla
        --   * Call a slot acceptable if there is some heuristic deciding there are enough prereqs for it
        --   * Just return true (we already follow a sorting of the slots, so this might be enough)
        -- Returning true wasn't sufficient, so I think I'm going to do the first option
        return slot_vanilla_prereqs_assigned(slot)
    end

    local function slot_absolute_reachable(slot)
        if not slot.slot then
            log(serpent.block(slot))
            log(key(slot))
            error("Slot expected, but got different node type")
        end

        if slot.op == "OR" then
            for _, prenode in pairs(gutils.prenodes(split_graph, slot)) do
                if prenode.type == "head" or next(split_sort.node_to_context_inds[key(prenode)]) ~= nil then
                    return true
                end
            end

            return false
        else
            return node_prenodes_share_context(split_graph, slot)
        end
    end

    -- Just checks if there are enough prereq slots for trav of each type
    local function trav_acceptable(trav)
        -- The following code didn't work, but I'm keeping it here in case I need to come back to it
        -- If this stays here a while and I don't need it, then it's safe to delete the whole commented block after this
        --[[
        -- CRITICAL TODO: Something more permanent! So not just for item randomization
        if trav.type == "orand" then
            local old_slot_owner = subdiv_graph.nodes[subdiv_graph.orand_to_parent[trav.old_slot] ]
            if old_slot_owner.type == "item" and old_slot_owner.trav_item then
                -- Check that there are at least as many reachable item slots as item travs
                -- We should probably do this without checking every pebble (keep track of what's reachable as we add things)
                local req_num_item_slots = 0
                for _, _ in pairs(trav_to_slot) do
                    req_num_item_slots = 1 + req_num_item_slots
                end
                -- Add an extra because the upcoming trav would also need a slot if it was an item
                local req_num_item_slots = 1 + req_num_item_slots

                local num_item_slots = 0
                for _, pebble in pairs(split_sort.sorted) do
                    local node = split_graph.nodes[pebble.node_key]
                    -- Genuine item!
                    if node.type == "item" and not node.trav_item then
                        num_item_slots = 1 + num_item_slots
                    end
                end
                if num_item_slots < req_num_item_slots then
                    return false
                end
            end
        end]]

        if not DO_PREREQ_POOL_CHECK then
            return true
        end

        local type_to_nums = {}
        local slot_in_subdiv_graph = subdiv_graph.nodes[trav.old_slot]
        for _, prenode in pairs(gutils.prenodes(subdiv_graph, slot_in_subdiv_graph)) do
            if prenode.type == "head" then
                local prereq_type = gutils.get_owner(subdiv_graph, gutils.get_buddy(subdiv_graph, prenode)).type
                type_to_nums[prereq_type] = type_to_nums[prereq_type] or 0
                type_to_nums[prereq_type] = 1 + type_to_nums[prereq_type]
            end
        end
        local prereq_pool_sizes = {}
        for _, pebble in pairs(split_sort.sorted) do
            -- Check if this has at least one base depnode that could connect
            local node_in_subdiv = subdiv_graph.nodes[pebble.node_key]
            if node_in_subdiv ~= nil then
                for _, depnode in pairs(gutils.depnodes(subdiv_graph, node_in_subdiv)) do
                    if depnode.type == "base" then
                        if gutils.get_owner(subdiv_graph, gutils.get_buddy(subdiv_graph, depnode)).type == trav.type then
                            prereq_pool_sizes[node_in_subdiv.type] = prereq_pool_sizes[node_in_subdiv.type] or 0
                            prereq_pool_sizes[node_in_subdiv.type] = 1 + prereq_pool_sizes[node_in_subdiv.type]
                        end
                    end
                end
            end
        end
        for node_type, num_req in pairs(type_to_nums) do
            if prereq_pool_sizes[node_type] == nil or prereq_pool_sizes[node_type] < num_req then
                return false
            end
        end
        return true
    end

    local function trav_absolute_reachable(trav)
        -- TEST: Make sure this is a trav
        if not trav.trav then
            log(serpent.block(trav))
            log(key(trav))
            error("Traveler expected, but got different node type")
        end

        -- This part is mandatory since it involves fixed edges

        -- We now allow OR node travs, so handle those
        -- These are luckily easy, just need to test if the node itself has gotten context
        if trav.op == "OR" then
            -- OR nodes should always be absolute reachable as long as we can put them on a good slot
            -- CRITICAL TODO: Need to check that the slot we put an OR trav on has an edge, or that the trav does
            return true
            --[[if next(split_sort.node_to_context_inds[key(trav)]) ~= nil then
                return true
            end]]
        end

        -- Check that there is a common context among trav's fixed edge prereqs (excluding the dangling connection for a slot)
        return node_prenodes_share_context(split_graph, trav)
    end
    if DO_TESTS then
        -- Assert that some traveler is not reachable from the start
        local some_trav_not_reachable = false
        for perm_ind, sorted_node_ptr in pairs(perm) do
            local trav = ind_to_trav(slot_inds[sorted_node_ptr])
            if not trav_absolute_reachable(trav) then
                some_trav_not_reachable = true
            elseif REPORT_STARTING_TRAVS then
                log(key(trav))
            end
        end
        if not some_trav_not_reachable then
            error("All travs reachable")
        end
    end

    -- Reserve things until all the corresponding slot is assigned
    -- This makes us stick to a fundamentally vanilla progression, while allowing crazy unlocks earlier
    local function trav_vanilla_reachable(trav)
        -- TEST: Make sure this is a trav
        if not trav.trav then
            log(serpent.block(trav))
            log(key(trav))
            error("Traveler expected, but got different node type")
        end

        --return slot_to_trav[trav.old_slot] ~= nil
        -- Actually let's try "reachable" instead
        return next(split_sort.node_to_context_inds[trav.old_slot]) ~= nil
    end

    local trav_to_mechanics = {}
    for perm_ind, sorted_node_ptr in pairs(perm) do
        local trav = ind_to_trav(slot_inds[sorted_node_ptr])
        trav_to_mechanics[key(trav)] = {}
        local open = { trav }
        local in_open = {
            [key(trav)] = true,
        }
        local ind = 1
        local dont_propagate_types = {
            ["fluid-hold"] = true,
        }
        -- TODO: Put this max_depth into a configuration variable or something
        local max_depth = 20
        local curr_depth = 0
        local curr_next_depth_ind = 1
        while ind <= #open do
            if ind == curr_next_depth_ind then
                curr_depth = 1 + curr_depth
                curr_next_depth_ind = #open + 1
            end
            if curr_depth > max_depth then
                break
            end

            local next_node = open[ind]
            --[[local mechanic_key
            if next_node.mechanic then
                if next_node.type == "orand" then
                    mechanic_key = split_graph.orand_to_parent[key(next_node)]
                else
                    mechanic_key = key(next_node)
                end
            elseif next_node.old_slot ~= nil and split_graph.nodes[next_node.old_slot].mechanic then
                if next_node.type == "orand" then
                    mechanic_key = split_graph.orand_to_parent[next_node.old_slot]
                else
                    mechanic_key = key(next_node)
                end
            end]]
            local mechanic_key
            if next_node.old_slot ~= nil then
                local old_slot = split_graph.nodes[next_node.old_slot]
                if old_slot ~= nil and old_slot.mechanic then
                    mechanic_key = next_node.old_slot
                end
            elseif next_node.mechanic then
                mechanic_key = key(next_node)
            end
            if mechanic_key ~= nil then
                local mechanic_node = split_graph.nodes[mechanic_key]
                if mechanic_node.type == "orand" then
                    mechanic_key = split_graph.orand_to_parent[mechanic_key]
                end
            end

            -- Don't propagate through mechanics
            if mechanic_key ~= nil then
                trav_to_mechanics[key(trav)][mechanic_key] = true
                --trav_to_mechanics[key(trav)][key(next_node)] = true
            elseif not dont_propagate_types[next_node.type] --[[and not (next_node.trav and key(next_node) ~= key(trav))]] then
                for _, depnode in pairs(gutils.depnodes(split_graph, next_node)) do
                    if not (next_node.slot and key(depnode) == key(slot_to_base[key(next_node)])) then
                        if not in_open[key(depnode)] then
                            in_open[key(depnode)] = true
                            table.insert(open, depnode)
                        end
                    end
                end
            end
            ind = ind + 1
        end
    end
    
    -- Want to go: trav key, to new trav position, to old trav
    -- So, key to position on new, position to key on old
    local mechanics_sets_to_ordered = {}
    local trav_to_mechanics_key = {}
    for _, pebble in pairs(init_sort.sorted) do
        local node = split_graph.nodes[pebble.node_key]
        if node.slot then
            local mechanics_set = trav_to_mechanics[node.old_trav]
            local mechanics_list = {}
            for mechanic, _ in pairs(mechanics_set) do
                table.insert(mechanics_list, mechanic)
            end
            table.sort(mechanics_list)
            local mechanics_list_key = gutils.concat(mechanics_list)
            trav_to_mechanics_key[key(node.type, make_trav_name(node.name))] = mechanics_list_key
            mechanics_sets_to_ordered[mechanics_list_key] = mechanics_sets_to_ordered[mechanics_list_key] or {}
            table.insert(mechanics_sets_to_ordered[mechanics_list_key], key(node))
        end
    end

    if REQUIRE_MECHANICS_FOR_IMPORTANCE then
        local new_important = table.deepcopy(is_important)
        local unimportant_removed = 0
        for node_key, _ in pairs(is_important) do
            local trav_key = split_graph.nodes[node_key].old_trav
            -- Make sure node_key actually corresponded to a slot
            -- Note that we only test is_important on travelers anyways
            if trav_key ~= nil then
                -- Check if there are any important mechanics
                -- Right now, this just excludes chemical fuel
                -- CRITICAL TODO: Document/put this in compat
                local has_important_mechanic = false
                for mechanic_node_key, _ in pairs(trav_to_mechanics[trav_key]) do
                    local mechanic_node = split_graph.nodes[mechanic_node_key]
                    local mechanic_orand_parent
                    if mechanic_node.type == "orand" then
                        local mechanic_orand_parent_key = split_graph.orand_to_parent[mechanic_node_key]
                        mechanic_orand_parent = split_graph.nodes[mechanic_orand_parent_key]
                    end
                    if mechanic_node.prot ~= key(data.raw["fuel-category"]["chemical"]) and not (mechanic_orand_parent ~= nil and (mechanic_orand_parent.type == "energy-source-burner" or mechanic_orand_parent.type == "chemical-fuel")) then
                        has_important_mechanic = true
                    end
                end
                if not has_important_mechanic then
                    new_important[node_key] = nil
                    unimportant_removed = 1 + unimportant_removed
                end
            end
        end
        is_important = new_important
        --log("Removed " .. tostring(unimportant_removed) .. " unimportant nodes.")
    end
    if REQUIRE_DIFFERENT_CANONICAL_FOR_IMPORTANCE then
        local new_important = table.deepcopy(is_important)
        local unimportant_removed = 0
        --[[for node_key, _ in pairs(is_important) do
            local trav_key = split_graph.nodes[node_key].old_trav
            if trav_key ~= nil then
                if next(split_graph.nodes[trav_key].dep) == nil then
                    new_important[node_key] = nil
                    unimportant_removed = 1 + unimportant_removed
                end
            end
        end]]
        -- Search for a node with a different canonical or name
        for node_key, _ in pairs(is_important) do
            local node = split_graph.nodes[node_key]
            local trav_key = node.old_trav
            if trav_key ~= nil then
                local trav = split_graph.nodes[trav_key]
                local found_different_node = false

                local open = { trav }
                local in_open = {}
                local ind = 1
                while ind <= #open do
                    local curr_node = open[ind]

                    if curr_node.canonical ~= trav.canonical or (curr_node.name ~= trav.name and curr_node.name ~= undo_trav_name(trav.name)) then
                        found_different_node = true
                        break
                    end
                    for _, depnode in pairs(gutils.depnodes(split_graph, curr_node)) do
                        if not in_open[key(depnode)] then
                            in_open[key(depnode)] = true
                            table.insert(open, depnode)
                        end
                    end

                    ind = ind + 1
                end

                if not found_different_node then
                    new_important[node_key] = nil
                    unimportant_removed = 1 + unimportant_removed
                end
            end
        end
        is_important = new_important
        --log("Removed " .. tostring(unimportant_removed) .. " unimportant nodes.")
    end

    -- Calculate costs; needed just a bit for a compatibility check
    -- TODO: Redo if needed; was just used for recipes, which we aren't first-passing anymore
    --local vanilla_costs = flow_cost.determine_recipe_item_cost(randomization_info.options.cost.default_cost_table, constants.cost_params.time, constants.cost_params.complexity)

    local is_resource_item = {}
    for _, resource in pairs(data.raw.resource) do
        if resource.minable ~= nil then
            if resource.minable.result ~= nil then
                is_resource_item[resource.minable.result] = true
            elseif #resource.minable.results == 1 then
                is_resource_item[resource.minable.results[1].name] = true
            end
        end
    end

    dutils.recalculate_spoil_burnt_results()
    -- Not strictly necessary; this check makes sure the node replacing another is of the same type, increasing probability that valid previous prereqs can be found
    local function is_compatible(slot, trav)
        -- Check that slot and trav are of the same type
        local same_type = false
        if slot.type == "orand" and trav.type == "orand" then
            -- subdiv_graph is technically semantically correct since that's where the orand connections are correct
            local orand_parent1 = subdiv_graph.nodes[subdiv_graph.orand_to_parent[key(slot)]]
            -- Need to go to trav's old slot to get orand parent type
            local orand_parent2 = subdiv_graph.nodes[subdiv_graph.orand_to_parent[trav.old_slot]]
            if orand_parent1.type == orand_parent2.type then
                same_type = true
            end
        elseif slot.type == trav.type then
            same_type = true
        end
        if not same_type then
            return false
        end

        -- If slot/trav are OR nodes, need to check that at least one has a prereq satisfied
        -- For slot, this will happen if it has a head prenode or a satisfied non-randomized prenode
        -- For trav, this will happen if it has a context in general
        if slot.op == "OR" and not slot_absolute_reachable(slot) then
            if next(split_sort.node_to_context_inds[key(trav)]) == nil then
                return false
            end
        end
        
        -- Don't check same mechanics for items because it's too restrictive
        if CHECK_SAME_MECHANICS and slot.type ~= "item" then
            for mechanic, _ in pairs(trav_to_mechanics[slot.old_trav]) do
                if not trav_to_mechanics[key(trav)][mechanic] then
                    return false
                end
            end
            for mechanic, _ in pairs(trav_to_mechanics[key(trav)]) do
                if not trav_to_mechanics[slot.old_trav][mechanic] then
                    return false
                end
            end
        end

        -- TODO: Check tech unlock; crafting with fluid
        if slot.type == "recipe" and trav.type == "recipe" then
            -- Check that two recipes are both enabled or both disabled
            local slot_recipe = data.raw.recipe[slot.name]
            local trav_recipe = data.raw.recipe[split_graph.nodes[trav.old_slot].name]
            if (slot_recipe.enabled or slot_recipe.enabled == nil) ~= (trav_recipe.enabled or trav_recipe.enabled == nil) then
                return false
            end

            -- Also check that both are crafting or not crafting
            if (slot_recipe.categories == nil or (#slot_recipe.categories == 1 and slot_recipe.categories[1] == "crafting")) ~= (trav_recipe.categories == nil or (#trav_recipe.categories == 1 and trav_recipe.categories[1] == "crafting")) then
                return false
            end

            -- Also check fluid match
            local fluids1 = lutils.find_recipe_fluids(slot_recipe)
            local fluids2 = lutils.find_recipe_fluids(trav_recipe)
            if fluids1.input ~= fluids2.input then
                return false
            elseif fluids1.output ~= fluids2.output then
                return false
            end

            -- Also check both have costs or both don't have costs
            --[[local slot_cost = vanilla_costs.recipe_to_cost[slot_recipe.name]
            local trav_cost = vanilla_costs.recipe_to_cost[trav_recipe.name]
            if (slot_cost == nil and trav_cost ~= nil) or (slot_cost ~= nil and trav_cost == nil) then
                return false
            end]]

            -- Check that costs aren't wildly different
            --[[if slot_cost ~= nil and trav_cost ~= nil and math.abs(math.log(slot_cost) - math.log(trav_cost)) > constants.first_pass_max_cost_log_difference then
                return false
            end]]
        end

        if slot.type == "item" and trav.type == "item" then
            local slot_cost = material_costs.costs[key(slot)]
            local trav_cost = material_costs.costs[trav.old_slot]
            if type(slot_cost) ~= type(trav_cost) then
                return false
            end
            if slot_cost ~= nil then
                -- Don't allow costs to differ more than by a factor of like a few hundred
                -- Be more permissive about putting cheat travelers in expensive slots
                if math.log(trav_cost) - math.log(slot_cost) > constants.first_pass_max_cost_log_difference_expensive or math.log(slot_cost) - math.log(trav_cost) > constants.first_pass_max_cost_log_difference_cheap then
                    return false
                end
            end
            -- Enforce that ores get interesting items more often
            if is_resource_item[slot.name] then
                local trav_item = dutils.get_prot("item", string.sub(trav.name, 1, -6))
                if dutils.is_useless_item(trav_item) then
                    -- 90% chance to reject a random uninteresting thing then
                    if math.random() < 0.9 then
                        return false
                    end
                end
            end
        end

        -- Note: THIS IS BROKEN! If it's an item, they'll be ORANDS! Also the name will have the weird suffix from item handler added
        -- CRITICAL TODO: FIX!
        --[=[if (slot.type == "item" and trav.type == "item") or (slot.type == "fluid" and trav.type == "fluid") then
            local slot_prot = dutils.get_prot(slot.type, slot.name)
            -- CRITICAL TODO: This is also broken! Need to get original name without -trav
            local trav_prot = dutils.get_prot(trav.type, trav.name)

            -- Check that both have costs, or both don't have costs
            local slot_cost = vanilla_costs.material_to_cost[flow_cost.get_prot_id(slot)]
            local trav_cost = vanilla_costs.material_to_cost[flow_cost.get_prot_id(trav)]
            if (slot_cost == nil and trav_cost ~= nil) or (slot_cost ~= nil and trav_cost == nil) then
                return false
            end

            -- Check that costs aren't wildly different
            --[[if slot_cost ~= nil and trav_cost ~= nil and math.abs(math.log(slot_cost) - math.log(trav_cost)) > constants.first_pass_max_cost_log_difference then
                return false
            end]]

            -- Check both are not stackable or are stackable
            --[[if dutils.is_stackable(slot_prot) ~= dutils.is_stackable(trav_prot) then
                return false
            end]]
        end]=]

        return true
    end

    ----------------------------------------------------------------------------------------------------
    -- RESERVATION SUBROUTINES
    ----------------------------------------------------------------------------------------------------

    local is_reserved = {}
    local reserved_slots = {}

    local function can_reserve(trav)
        -- Previously, we were checking for the existence of at least some number of prereqs, but it looks like even those checks were removed
        return true
    end

    local function to_be_reserved(trav)
        -- If we've hit all the mechanics, then no need to worry anymore
        if curr_mechanic_index > #ordered_mechanics then
            return false
        end

        -- Reserve if it doesn't help the next mechanic
        local curr_mechanic = ordered_mechanics[curr_mechanic_index]
        if not trav_to_mechanics[key(trav)][curr_mechanic] then
            return true
        end
        return false
        --return not (trav_vanilla_reachable(trav) and is_important[trav.old_slot])
    end

    local function update_mechanic_index(sort_info)
        -- Update mechanic index
        while true do
            if curr_mechanic_index > #ordered_mechanics then
                return
            end

            local curr_mechanic = ordered_mechanics[curr_mechanic_index]
            if next(sort_info.node_to_context_inds[curr_mechanic]) ~= nil then
                curr_mechanic_index = 1 + curr_mechanic_index
            else
                break
            end
        end
    end
    -- Immediately do this to get the mechanics reachable off the bat
    update_mechanic_index(split_sort)

    local function connect_slot_trav(graph, sort_info, slot, trav)
        -- TEST: Check slot is slot and trav is trav
        if not slot.slot then
            log(serpent.block(slot))
            log(key(slot))
            error("Got non-slot when expected slot.")
        end
        if not trav.trav then
            log(serpent.block(trav))
            log(key(trav))
            error("Got non-trav when expected trav.")
        end

        -- Check that these came from the correct graph
        if not test_graph_invariants.check_from_graph(graph, slot) then
            log(serpent.block(slot))
            log(key(slot))
            error("Slot from incorrect graph")
        end
        if not test_graph_invariants.check_from_graph(graph, trav) then
            log(serpent.block(trav))
            log(key(trav))
            error("Trav from incorrect graph")
        end

        -- Connect reachable-room to slot edges to satisfy it, then connect slot to trav
        -- We need to connect to reachable-room so that it still gets contexts in a valid way
        local true_node = graph[key("reachable-room", "")]
        for _, prenode in pairs(gutils.prenodes(graph, slot)) do
            --gutils.add_edge(graph, true_node, prenode)
            --sort_info = top.sort(graph, sort_info, {true_node, prenode}, { choose_randomly = true })
        end
        -- Actually, I think this is incorrect: Either slot or trav needs to get context themselves or else it's impossible anyways
        --[[if slot.op == "OR" then
            -- For OR nodes, we might need a direct connection
            gutils.add_edge(graph, true_node, slot)
            sort_info = top.sort(graph, sort_info, {true_node, slot})
        end]]

        -- TEST: Check that slot corresponds to trav
        if slot_to_trav[key(slot)] ~= key(trav) then
            log(key(slot))
            log(key(trav))
            error("Connecting non-associated slot and trav")
        end

        -- Connect slot base to trav head
        local slot_base = slot_to_base[key(slot)]
        local trav_head = trav_to_head[key(trav)]

        -- TEST: See if base or head is nil
        if slot_base == nil then
            log(serpent.block(slot_to_base[key(slot)]))
            log(serpent.block(slot))
            log(key(slot))
            error("slot base nil")
        end
        if trav_head == nil then
            log(serpent.block(trav_to_head[key(trav)]))
            log(serpent.block(trav))
            log(trav)
            error("trav head nil")
        end

        -- Special handling for recipe first pass randomization
        if SPECIAL_RECIPE_FIRST_PASS and slot.type == "recipe" and is_canonical_result(slot.name) and RECIPE_INGS_DIR ~= "BACKWARD" then
            -- Remove false node
            local pre_to_remove
            for pre, _ in pairs(slot.pre) do
                local pre_edge = graph.edges[pre]
                local pre_edge_node = graph.nodes[pre_edge.start]
                if pre_edge_node.type == "false" then
                    pre_to_remove = pre
                    break
                end
            end
            gutils.remove_edge(graph, pre_to_remove)
            -- First move dependents to trav
            local deps_to_move = {}
            for dep, _ in pairs(slot.dep) do
                local depnode_key = graph.edges[dep].stop
                -- Check that this isn't the slot's base
                if depnode_key ~= gutils.key(slot_to_base[gutils.key(slot)]) then
                    deps_to_move[dep] = true
                end
            end
            for dep, _ in pairs(deps_to_move) do
                gutils.redirect_edge_start(graph, dep, trav)
            end
            -- Now filter context through slot
            gutils.add_edge(graph, gutils.key("true", ""), gutils.key(slot))
            sort_info = top.sort(graph, sort_info, {graph.nodes[gutils.key("true", "")], slot}, { choose_randomly = true })
        end

        gutils.add_edge(graph, slot_base, trav_head)
        sort_info = top.sort(graph, sort_info, {slot_base, trav_head}, { choose_randomly = true })

        update_mechanic_index(sort_info)

        return sort_info
    end

    local function fulfill_reservation(res_ind)
        local slot = reserved_slots[res_ind]
        local trav = split_graph.nodes[slot_to_trav[key(slot)]]

        is_reserved[key(slot)] = nil
        table.remove(reserved_slots, res_ind)
        split_sort = connect_slot_trav(split_graph, split_sort, slot, trav)

        log("\n\nFULFILLED:\n" .. key(slot) .. " BY " .. key(trav) .. "\n")
    end

    local function update_reservations()
        -- Actually, fulfill everything if we got all the mechanics
        --[[if curr_mechanic_index > #ordered_mechanics then
            for j = #reserved_slots, 1, -1 do
                fulfill_reservation(j)
            end
        end]]

        -- Travelers now only become fulfilled as necessary to progress with mechanics
        do return end

        while true do
            local fulfilled = false

            for j = 1, #reserved_slots do
                local trav = split_graph.nodes[slot_to_trav[key(reserved_slots[j])]]
                if trav_vanilla_reachable(trav) then
                    fulfill_reservation(j)
                    fulfilled = true
                    break
                end
            end

            if not fulfilled then
                break
            end
        end
    end

    local function replace_reservation(res_ind, new_trav)
        local slot = reserved_slots[res_ind]
        local old_trav_key = slot_to_trav[key(slot)]

        log("\n\nReplacing\n" .. old_trav_key .. "\nin\n" .. key(slot) .. "\nfor\n" .. key(new_trav) .. "\n")

        trav_to_slot[old_trav_key] = nil
        trav_to_slot[key(new_trav)] = key(slot)
        slot_to_trav[key(slot)] = key(new_trav)

        fulfill_reservation(res_ind)
        -- In case this fulfillment triggered more reservations to be available
        update_reservations()
    end

    ----------------------------------------------------------------------------------------------------
    -- DEBUG CURRENT MECHANIC
    ----------------------------------------------------------------------------------------------------

    local debugged_mechanics = {}

    local function debug_contexts(node_key)
        local contexts = split_sort.node_to_context_inds[node_key]
        if contexts == nil then
            return "NIL"
        end
        return serpent.line(contexts)
    end

    local function debug_mechanic_blockage(mechanic_key)
        local mechanic = split_graph.nodes[mechanic_key]
        if mechanic == nil then
            log("DEBUG: mechanic missing from split_graph: " .. tostring(mechanic_key))
            return
        end

        log("\n\n================ PY1 BLOCKAGE DEBUG ================")
        log("MECHANIC: " .. mechanic_key)
        log("MECHANIC CONTEXTS: " .. debug_contexts(mechanic_key))

        ------------------------------------------------------------------------
        -- A. Walk backward until we hit reachable nodes.
        ------------------------------------------------------------------------

        local seen = {}

        local function walk_blocked(node, depth, indent)
            if node == nil or depth < 0 then
                return
            end

            local node_key = key(node)
            if seen[node_key] then
                return
            end
            seen[node_key] = true

            local contexts = split_sort.node_to_context_inds[node_key]
            local reachable =
                contexts ~= nil and next(contexts) ~= nil

            local extra = ""

            if node.slot then
                extra =
                    extra
                    .. " SLOT"
                    .. " assigned=" .. tostring(slot_to_trav[node_key])
                    .. " reserved=" .. tostring(is_reserved[node_key] ~= nil)
            end

            if node.trav then
                extra =
                    extra
                    .. " TRAV"
                    .. " assigned_to=" .. tostring(trav_to_slot[node_key])
            end

            log(
                indent
                .. node_key
                .. " type=" .. tostring(node.type)
                .. " op=" .. tostring(node.op)
                .. " contexts=" .. debug_contexts(node_key)
                .. extra
            )

            if reachable then
                log(indent .. "  ^^^ REACHABLE FRONTIER")
                return
            end

            for _, pre in pairs(gutils.prenodes(split_graph, node)) do
                walk_blocked(pre, depth - 1, indent .. "  ")
            end
        end

        log("\n=== BLOCKED BACKTRACE ===")
        walk_blocked(mechanic, 12, "")

        ------------------------------------------------------------------------
        -- B. Find traveler-side paths feeding toward this mechanic.
        ------------------------------------------------------------------------

        log("\n=== TRAVELERS WITH PATHS TOWARD MECHANIC ===")

        local queue = {
            {
                node = mechanic,
                path = {mechanic_key},
                depth = 0,
            }
        }

        local visited = {}
        local num_travs_printed = 0
        local MAX_TRAVS_PRINTED = 50
        local MAX_DEPTH = 15

        local qind = 1

        while qind <= #queue and num_travs_printed < MAX_TRAVS_PRINTED do
            local entry = queue[qind]
            qind = qind + 1

            local node = entry.node
            local node_key = key(node)

            if not visited[node_key] then
                visited[node_key] = true

                if node.trav then
                    num_travs_printed = num_travs_printed + 1

                    log("\nTRAV ANCESTOR: " .. node_key)
                    log("  contexts=" .. debug_contexts(node_key))
                    log("  assigned_to=" .. tostring(trav_to_slot[node_key]))

                    log("  PATH TRAV -> MECHANIC:")
                    for i = #entry.path, 1, -1 do
                        local path_key = entry.path[i]
                        local path_node = split_graph.nodes[path_key]

                        log(
                            "    "
                            .. path_key
                            .. " type="
                            .. tostring(path_node and path_node.type)
                        )
                    end
                elseif entry.depth < MAX_DEPTH then
                    for _, pre in pairs(gutils.prenodes(split_graph, node)) do
                        local new_path = table.deepcopy(entry.path)
                        table.insert(new_path, key(pre))

                        table.insert(queue, {
                            node = pre,
                            path = new_path,
                            depth = entry.depth + 1,
                        })
                    end
                end
            end
        end

        log("\nNUM TRAV PATHS PRINTED: " .. tostring(num_travs_printed))
        log("================ END PY1 DEBUG ================\n\n")
    end

    local function debug_blocked_node(node_key, max_depth)
        local node = split_graph.nodes[node_key]

        if node == nil then
            log("DEBUG NODE MISSING: " .. tostring(node_key))
            return
        end

        log("\n\n================ BLOCKED NODE DEBUG ================")
        log("TARGET: " .. node_key)
        log("TARGET CONTEXTS: " .. debug_contexts(node_key))

        local seen = {}

        local function walk(node, depth, indent)
            if node == nil or depth < 0 then
                return
            end

            local node_key = key(node)
            if seen[node_key] then
                log(indent .. node_key .. " [already seen]")
                return
            end
            seen[node_key] = true

            local contexts = split_sort.node_to_context_inds[node_key]
            local reachable =
                contexts ~= nil and next(contexts) ~= nil

            local extra = ""

            if node.slot then
                extra =
                    extra
                    .. " SLOT"
                    .. " assigned=" .. tostring(slot_to_trav[node_key])
                    .. " reserved=" .. tostring(is_reserved[node_key] ~= nil)
                    .. " abs_reachable="
                    .. tostring(slot_absolute_reachable(node))
            end

            if node.trav then
                extra =
                    extra
                    .. " TRAV"
                    .. " assigned_to=" .. tostring(trav_to_slot[node_key])
            end

            log(
                indent
                .. node_key
                .. " type=" .. tostring(node.type)
                .. " op=" .. tostring(node.op)
                .. " contexts=" .. debug_contexts(node_key)
                .. extra
            )

            if reachable then
                log(indent .. "  ^^^ REACHABLE FRONTIER")
                return
            end

            for _, pre in pairs(gutils.prenodes(split_graph, node)) do
                walk(pre, depth - 1, indent .. "  ")
            end
        end

        walk(node, max_depth or 10, "")

        log("================ END BLOCKED NODE DEBUG ================\n")
    end

    ----------------------------------------------------------------------------------------------------
    -- CORE LOOP
    ----------------------------------------------------------------------------------------------------

    local function print_failure_message(i)
        log("\nUnassigned slots...")
        for _, slot_ind in pairs(slot_inds) do
            local slot = ind_to_slot(slot_ind)
            local slot_key = key(slot)
            if slot_to_trav[slot_key] == nil then
                log(slot_key)
            end
        end
        log("\nUnassigned travs...")
        for perm_ind, sorted_node_ptr in pairs(perm) do
            local trav = ind_to_trav(slot_inds[sorted_node_ptr])
            local trav_key = key(trav)
            if trav_to_slot[trav_key] == nil then
                log(trav_key)
                log(trav_absolute_reachable(trav))
                log(trav_vanilla_reachable(trav))
            end
        end
        log("\nFirst pass failed at " .. tostring(math.floor(100 * i / #slot_inds)) .. "%\n")
    end

    for i = 1, #slot_inds do
        log(tostring(i) .. " / " .. tostring(#slot_inds))

        local found_slot
        local found_trav

        -- Outer desperation loop
        local disable_reachability_check = false
        while true do
            for iteration = 1, MAX_ITERATIONS do
                if iteration % 100 == 0 then
                    log("ITERATION #" .. tostring(iteration))
                end

                -- Precompute traveler predicates
                local all_travs_reachable = true
                local precomp_travs = {}
                for perm_ind, sorted_node_ptr in pairs(perm) do
                    local trav = ind_to_trav(slot_inds[sorted_node_ptr])
                    if not trav_absolute_reachable(trav) or disable_reachability_check then
                        all_travs_reachable = false
                    end
                    if trav_acceptable(trav) and trav_to_slot[key(trav)] == nil and (trav_absolute_reachable(trav) or disable_reachability_check) then
                        if can_reserve(trav) or not to_be_reserved(trav) then
                            table.insert(precomp_travs, trav)
                        end
                    end
                end

                local slot_tries = 0
                for _, slot_ind in pairs(slot_inds) do
                    -- TODO: Don't hardcode this number
                    if slot_tries >= 100 then
                        break
                    end

                    local slot = ind_to_slot(slot_ind)
                    local slot_key = key(slot)

                    -- Test if this slot is absolute reachable (for when slots of non-randomized edges)
                    --if slot_absolute_reachable(slot) then
                        if slot_to_trav[slot_key] == nil and (slot_absolute_reachable(slot) or disable_reachability_check) then--and (slot_acceptable(slot) or disable_reachability_check) then
                            slot_tries = 1 + slot_tries
                            for _, trav in pairs(precomp_travs) do
                            --for perm_ind, sorted_node_ptr in pairs(perm) do
                                --local trav = ind_to_trav(slot_inds[sorted_node_ptr])

                                --if trav_acceptable(trav) and trav_to_slot[key(trav)] == nil and (trav_absolute_reachable(trav) or disable_reachability_check) then
                                    if is_compatible(slot, trav) then --and (can_reserve(trav) or not to_be_reserved(trav)) then
                                        if to_be_reserved(trav) then
                                            is_reserved[key(slot)] = true
                                            table.insert(reserved_slots, slot)
                                        end
                                        found_slot = slot
                                        found_trav = trav
                                        break
                                    end
                                --end
                            end
                            if found_trav == nil and REPORT_SLOTS_FAILED then
                                log("SLOT FAILURE: " .. key(slot))
                            end
                        end
                        if found_trav ~= nil then
                            break
                        end

                        -- Should we do a completely ordered traversal?
                        if DO_SLOTS_IN_ORDER and slot_to_trav[slot_key] == nil and slot_absolute_reachable(slot) then
                            log("COULD NOT FIND TRAV FOR " .. slot_key)
                            log(slot_absolute_reachable(slot))
                            break
                        end
                    --end
                end
                if found_trav ~= nil then
                    break
                else
                    -- Reservation loop

                    local curr_mechanic
                    if curr_mechanic_index <= #ordered_mechanics then
                        curr_mechanic = ordered_mechanics[curr_mechanic_index]
                    end

                    log("\n\nRESERVATION LOOP FOR MECHANIC:\n\t" .. (curr_mechanic or "NIL") .. "\n")

                    if #reserved_slots == 0 then
                        log("RAN OUT OF RESERVED SLOTS")
                        break
                    end

                    -- First, try to fulfill an early reservation that now targets the current mechanic
                    local found_fulfiller = false
                    if curr_mechanic ~= nil then
                        for j = 1, #reserved_slots do
                            local reserved_slot = reserved_slots[j]
                            local reserved_trav_key = slot_to_trav[key(reserved_slot)]
                            if trav_to_mechanics[reserved_trav_key][curr_mechanic] then
                                log("FOUND FULFILLER\n\t" .. reserved_trav_key .. "\nFOR \n\t" .. (curr_mechanic or "NIL"))
                                found_fulfiller = true
                                fulfill_reservation(j)
                                update_reservations()
                                break
                            end
                        end
                        -- Cancel reservation
                        if not found_fulfiller then
                            for perm_ind, sorted_node_ptr in pairs(perm) do
                                local trav = ind_to_trav(slot_inds[sorted_node_ptr])
                                -- to_be_reserved checks that it actually satisfies the mechanic we're looking for
                                if trav_acceptable(trav) and trav_to_slot[key(trav)] == nil and trav_absolute_reachable(trav) and not to_be_reserved(trav) then
                                    for j = #reserved_slots, 1, -1 do
                                        local slot = reserved_slots[j]
                                        if is_compatible(slot, trav) then
                                            replace_reservation(j, trav)
                                            found_fulfiller = true
                                            break
                                        end
                                    end
                                end
                                if found_fulfiller then
                                    break
                                end
                            end
                        end
                    end
                    if not found_fulfiller and all_travs_reachable then
                        local slot_tries = 0
                        for _, slot_ind in pairs(slot_inds) do
                            local base_slot = ind_to_slot(slot_ind)

                            if slot_to_trav[key(base_slot)] == nil and slot_absolute_reachable(base_slot) then
                                slot_tries = 1 + slot_tries
                                if slot_tries > 100 then
                                    break
                                end

                                local slot_chain = {base_slot}
                                local trav_chain = {}
                                local already_in_chain = {}
                                local curr_slot = base_slot
                                local found_ending_trav = false
                                for chain_length = 1, 100 do
                                    -- First find a reserved slot to take a trav from
                                    local found_slot_to_take_from = false
                                    for j = #reserved_slots, 1, -1 do
                                        local reserved_slot = reserved_slots[j]
                                        if not already_in_chain[j] then
                                            local trav = split_graph.nodes[slot_to_trav[key(reserved_slot)]]
                                            if is_compatible(curr_slot, trav) then
                                                table.insert(slot_chain, reserved_slot)
                                                table.insert(trav_chain, trav)
                                                already_in_chain[j] = true
                                                curr_slot = reserved_slot
                                                found_slot_to_take_from = true
                                                break
                                            end
                                        end
                                    end
                                    if not found_slot_to_take_from then
                                        break
                                    end
                                    -- Now see if there is a free trav for it
                                    -- This code is largely copied from the main loop
                                    for perm_ind, sorted_node_ptr in pairs(perm) do
                                        local trav = ind_to_trav(slot_inds[sorted_node_ptr])
                                        if trav_to_slot[key(trav)] == nil and trav_acceptable(trav) and is_compatible(curr_slot, trav) then
                                            -- No need to fulfill reservations here, so make it reserved always
                                            table.insert(trav_chain, trav)
                                            found_ending_trav = true
                                            break
                                        end
                                    end
                                    if found_ending_trav then
                                        break
                                    end
                                end
                                if found_ending_trav then
                                    -- The base j = 1 case is taken care of later
                                    for j = #slot_chain, 2, -1 do
                                        local slot_key = key(slot_chain[j])
                                        local trav_key = key(trav_chain[j])
                                        slot_to_trav[slot_key] = trav_key
                                        trav_to_slot[trav_key] = slot_key
                                    end
                                    is_reserved[key(base_slot)] = true
                                    table.insert(reserved_slots, base_slot)
                                    found_fulfiller = true
                                    found_slot = base_slot
                                    found_trav = trav_chain[1]
                                    break
                                end
                            end
                        end
                    end
                    if not found_fulfiller then
                        log("FAILED CANCELLATION")
                        --debug_mechanic_blockage(curr_mechanic)
                        
                        --break
                        fulfill_reservation(1)
                        update_reservations()
                    end

                    --[[if #reserved_slots == 0 then
                        break
                    end

                    local found_reservation = false
                    for p = 1, #perm do
                        -- Going in order is more likely to produce a newly reachable thing
                        local trav = ind_to_trav(slot_inds[p])

                        if trav_acceptable(trav) and trav_to_slot[key(trav)] == nil and trav_absolute_reachable(trav) then
                            for j = #reserved_slots, 1, -1 do
                                local slot = reserved_slots[j]

                                -- TODO: Should we check vanilla reachable for trav here?
                                if is_compatible(slot, trav) and is_important[trav.old_slot] and trav_vanilla_reachable(trav) then
                                    replace_reservation(j, trav)
                                    found_reservation = true
                                    break
                                end
                            end
                        end
                        if found_reservation then
                            break
                        end
                    end

                    if not found_reservation then
                        log("FAILED CANCELLATION")
                        fulfill_reservation(1)
                        update_reservations()
                    end]]
                end
            end

            if found_trav ~= nil then
                break
            else
                print_failure_message(i)
                -- For debugging, ability to ignore last bit of unassigned slots/travs
                if i / #slot_inds < FAILURE_ACCEPTANCE then
                    return false
                else
                    if disable_reachability_check == true then
                        return false
                    else
                        disable_reachability_check = true
                    end
                end
            end
        end

        slot_to_trav[key(found_slot)] = key(found_trav)
        trav_to_slot[key(found_trav)] = key(found_slot)
        table.insert(new_slot_order, key(found_slot))
        local res_string_to_print = "\n\nSLOT: " .. key(found_slot) .. "\nTRAV: " .. key(found_trav)
        if is_reserved[key(found_slot)] then
            res_string_to_print = res_string_to_print .. "\n(RESERVED)"
        else
            split_sort = connect_slot_trav(split_graph, split_sort, found_slot, found_trav)
        end
        res_string_to_print = res_string_to_print .. "\n"
        log(res_string_to_print)

        update_reservations()
    end

    if #reserved_slots >= 1 then
        -- The travs should have been satisfied by now
        --[[for _, slot in pairs(reserved_slots) do
            log(key(slot))
            log(slot_to_trav[key(slot)])
        end
        log("There are " .. tostring(#reserved_slots) .. " reservations left!")
        return false]]

        -- No wait, we should be able to just fulfill the reservations
        while #reserved_slots >= 1 do
            fulfill_reservation(1)
            update_reservations()
        end
    end

    -- Need to do a new sort since the reservations can make it out of order
    local ordered_sort = top.sort(old_split_graph, nil, nil, { choose_randomly = true })
    for _, slot_key in pairs(new_slot_order) do
        local slot = old_split_graph.nodes[slot_key]
        local trav = old_split_graph.nodes[slot_to_trav[slot_key]]
        ordered_sort = connect_slot_trav(old_split_graph, ordered_sort, slot, trav)
    end

    local mechanics_sets_to_nodes = {}
    local mechanics_sets_to_size = {}
    for _, pebble in pairs(ordered_sort.sorted) do
        local node = old_split_graph.nodes[pebble.node_key]
        if node.trav then
            local mechanics_set = trav_to_mechanics[key(node)]
            local mechanics_list = {}
            for mechanic, _ in pairs(mechanics_set) do
                table.insert(mechanics_list, mechanic)
            end
            table.sort(mechanics_list)
            local mechanics_list_key = gutils.concat(mechanics_list)
            mechanics_sets_to_nodes[mechanics_list_key] = mechanics_sets_to_nodes[mechanics_list_key] or {}
            mechanics_sets_to_size[mechanics_list_key] = mechanics_sets_to_size[mechanics_list_key] or 0
            mechanics_sets_to_size[mechanics_list_key] = 1 + mechanics_sets_to_size[mechanics_list_key]
            mechanics_sets_to_nodes[mechanics_list_key][key(node)] = mechanics_sets_to_size[mechanics_list_key]
        end
    end

    return {
        slot_to_trav = slot_to_trav,
        trav_to_slot = trav_to_slot,
        -- CRITICAL TODO: Decide on sort after heuristics (ordered_sort or split_sort or init_sort)
        sort = ordered_sort,
        graph = old_split_graph,
        mechanics_sets_to_ordered = mechanics_sets_to_ordered,
        mechanics_sets_to_nodes = mechanics_sets_to_nodes,
        trav_to_mechanics_key = trav_to_mechanics_key,
    }
end

return first_pass