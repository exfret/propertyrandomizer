-- First pass: randomizes which item identity (trav) goes in which item position (slot), before the other handlers run
-- Nodes aren't split into base/head pairs, but get a .slot = true or .trav = true key property instead; slots keep the node's name and travs get a "-trav" suffix
-- Monotone matching (skeleton/monotone-matching.lua) chooses the whole matching at once, and the result is gated on keeping every protected mechanic context (skeleton/protection.lua)

-- TODO: Filter out things from first pass that are "boring" (maybe in adding no mechanics)

-- Which kinds of nodes are left out of first pass (science packs keep their identity)
local EXCLUDE_SCIENCE = true
local EXCLUDE_RECIPES = true
local EXCLUDE_TECHS = true
local EXCLUDE_ENTITY_OPERATE = true
-- How many rounds of monotone matching to iterate (each starts from the last round's matching)
local MONOTONE_MATCHING_ROUNDS = 3
-- Chance that a resource slot (what mining a resource gives) is given an interesting item, like the old first pass's ore roll
local INTERESTING_RESOURCE_CHANCE = 0.9

local constants = require("helper-tables/constants")
local gutils = require("lib/graph/graph-utils")
local dutils = require("lib/data-utils")
local top = require("lib/graph/context-sort")
local monotone_matching = require("randomizations/graph/unified/skeleton/monotone-matching")
local protection = require("randomizations/graph/unified/skeleton/protection")
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
    local is_science_pack = dutils.lab_inputs()
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

-- Whether a slot and trav's material costs are close enough to swap them
local function cost_ok(slot, trav)
    local slot_cost = material_costs.costs[key(slot)]
    local trav_cost = material_costs.costs[trav.old_slot]
    if type(slot_cost) ~= type(trav_cost) then
        return false
    end
    if slot_cost ~= nil then
        -- Be more permissive about putting cheap travelers in expensive slots
        return math.log(trav_cost) - math.log(slot_cost) <= constants.first_pass_max_cost_log_difference_expensive and math.log(slot_cost) - math.log(trav_cost) <= constants.first_pass_max_cost_log_difference_cheap
    end
    return true
end

-- Returns false if first pass failed (so the attempt is retried)
first_pass.execute = function(params)
    ----------------------------------------------------------------------------------------------------
    -- CHOOSE SLOTS
    ----------------------------------------------------------------------------------------------------

    -- spoofed_graph is used to get prereqs before subdivision
    local spoofed_graph = table.deepcopy(params.spoofed_graph)
    local subdiv_graph = table.deepcopy(params.subdiv_graph)

    local init_sort
    if not mods["pyalternativeenergy"] then
        init_sort = top.sort(spoofed_graph, nil, nil, {
            choose_randomly = true,
            complex_contexts = true,
        })
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
        init_sort = top.sort(graph_for_init_sort, nil, nil, {
            choose_randomly = true,
            complex_contexts = true,
        })
        for i = 1, #packs_in_order - 1 do
            for _, edge_info in pairs(packs_to_deps[packs_in_order[i]]) do
                local false_edge = deps_to_falses[edge_info[3]]
                gutils.remove_edge(graph_for_init_sort, gutils.ekey(false_edge))
                gutils.add_edge(graph_for_init_sort, edge_info[1], edge_info[2])
                init_sort = top.sort(graph_for_init_sort, init_sort, {graph_for_init_sort.nodes[edge_info[1]], graph_for_init_sort.nodes[edge_info[2]]}, { choose_randomly = true, do_new_edge_processing = true })
            end
        end
    end

    local lab_inputs = dutils.lab_inputs()
    local function valid_node_for_first_pass(node_key)
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
        if EXCLUDE_SCIENCE and subdiv_node.type == "item" and lab_inputs[subdiv_node.name] ~= nil then
            return false
        end
        if EXCLUDE_RECIPES and subdiv_node.type == "recipe" then
            return false
        end
        if EXCLUDE_TECHS and subdiv_node.type == "technology" then
            return false
        end
        if EXCLUDE_ENTITY_OPERATE and subdiv_node.type == "entity-operate" then
            return false
        end
        -- Check if at least one of its edges are randomized, or in other words that one of the pre's in subdiv graph are a head
        for _, prenode in pairs(gutils.prenodes(subdiv_graph, subdiv_node)) do
            if prenode.type == "head" then
                return true
            end
        end
        if ITEM_ENABLED and subdiv_node.type == "item" then
            return true
        end
        return false
    end

    -- slot key --> rank of its first pebble
    local node_in_sorted = {}
    for ind, pebble in pairs(init_sort.sorted) do
        if node_in_sorted[pebble.node_key] == nil and valid_node_for_first_pass(pebble.node_key) then
            node_in_sorted[pebble.node_key] = ind
        end
    end

    ----------------------------------------------------------------------------------------------------
    -- SPLIT GRAPH NODES
    ----------------------------------------------------------------------------------------------------

    local split_graph = table.deepcopy(subdiv_graph)

    -- Sends a slot to the base that connects it to a trav, and a trav to its head
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
        -- Randomized edges stay on the slot, fixed ones move to the trav
        -- By construction, an edge is randomized exactly when it's subdivided, so we can just check for the existence of a head/base
        local fixed_pre = {}
        for pre, _ in pairs(node.pre) do
            local prenode = gutils.prenode(split_graph, pre)
            if prenode.type == "orand" then
                prenode = gutils.unique_prenode(split_graph, prenode)
            end
            local always_on_slot = false
            if randomization_info.options.first_pass.always_slot_pre[key(prenode.type, node.type)] ~= nil then
                always_on_slot = true
                if (prenode.type == "tile-mine" or prenode.type == "entity-mine") and node.type == "item" then
                    -- Mining a building or a tile gives items under their own names (item reflection doesn't rename them), so it belongs to the item's identity
                    local mined
                    if prenode.type == "tile-mine" then
                        mined = data.raw.tile[prenode.name]
                    else
                        mined = dutils.get_prot("entity", prenode.name)
                    end
                    if mined == nil then
                        error("First pass: no prototype for " .. key(prenode))
                    end
                    if dutils.mining_keeps_item_names(mined) then
                        always_on_slot = false
                    end
                end
            end
            if prenode.type ~= "head" and not always_on_slot then
                fixed_pre[pre] = true
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
            local always_on_slot = randomization_info.options.first_pass.always_slot_dep[key(node.type, depnode.type)] ~= nil
            if depnode.type ~= "base" and not always_on_slot then
                fixed_dep[dep] = true
            end
        end
        for dep, _ in pairs(fixed_dep) do
            gutils.redirect_edge_start(split_graph, dep, key(trav))
        end

        -- The slot --> trav edge, cut into a base and head, is what gets rewired to match slots and travs
        local slot_trav_edge = gutils.add_edge(split_graph, node, trav)
        local base_head = gutils.subdivide_base_head(split_graph, gutils.ekey(slot_trav_edge))
        slot_to_base[node_key] = base_head.base
        trav_to_head[key(trav)] = base_head.head
        gutils.remove_edge(split_graph, gutils.ekey(gutils.unique_pre(split_graph, base_head.head)))
    end
    test_graph_invariants.test(split_graph)

    local num_slots = 0
    for _, _ in pairs(node_in_sorted) do
        num_slots = num_slots + 1
    end
    log("\n\nNUMBER SLOT/TRAVS: " .. tostring(num_slots) .. "\n\n")

    ----------------------------------------------------------------------------------------------------
    -- MECHANICS
    ----------------------------------------------------------------------------------------------------

    -- trav key --> set of the first mechanics reachable from it
    local trav_to_mechanics = {}
    for slot_key, _ in pairs(node_in_sorted) do
        local trav = split_graph.nodes[split_graph.nodes[slot_key].old_trav]
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
            elseif not dont_propagate_types[next_node.type] then
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
    -- A node has a pebble per context, but these lists order nodes, so only count each slot once (at its first pebble)
    local is_slot_ordered = {}
    for _, pebble in pairs(init_sort.sorted) do
        local node = split_graph.nodes[pebble.node_key]
        if node.slot and is_slot_ordered[pebble.node_key] == nil then
            is_slot_ordered[pebble.node_key] = true
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

    ----------------------------------------------------------------------------------------------------
    -- MATCHING
    ----------------------------------------------------------------------------------------------------

    local slot_keys = {}
    for slot_key, _ in pairs(node_in_sorted) do
        table.insert(slot_keys, slot_key)
    end
    table.sort(slot_keys)
    -- Items that mining a resource gives, which should usually become something interesting
    local is_resource_item = {}
    for _, resource in pairs(data.raw.resource) do
        if resource.minable ~= nil then
            if resource.minable.result ~= nil then
                is_resource_item[resource.minable.result] = true
            elseif resource.minable.results ~= nil and #resource.minable.results == 1 then
                is_resource_item[resource.minable.results[1].name] = true
            end
        end
    end
    dutils.recalculate_spoil_burnt_results()
    local assignment = monotone_matching.run({
        slot_keys = slot_keys,
        unconnected_graph = split_graph,
        slot_to_base = slot_to_base,
        trav_to_head = trav_to_head,
        cost_ok = cost_ok,
        rounds = MONOTONE_MATCHING_ROUNDS,
        is_resource_slot = function(slot_key)
            local slot = split_graph.nodes[slot_key]
            return slot.type == "item" and is_resource_item[slot.name] == true
        end,
        -- Uses the same notion of useless as item reflection, which skips swaps between two useless items
        is_interesting = function(trav_key)
            local item = dutils.get_prot("item", gutils.deconstruct(split_graph.nodes[trav_key].old_slot).name)
            return item ~= nil and not dutils.is_useless_item(item)
        end,
        interesting_resource_chance = INTERESTING_RESOURCE_CHANCE,
        -- Item reflection places useless items differently from the matching (see dutils.reflected_item_position), so each matching is replaced by the one reflection realizes before it's gated
        realize = function(assignment)
            local identity_at = {}
            for slot_key, trav_key in pairs(assignment) do
                if split_graph.nodes[slot_key].type == "item" then
                    identity_at[split_graph.nodes[slot_key].name] = gutils.deconstruct(split_graph.nodes[trav_key].old_slot).name
                end
            end
            local realized = table.deepcopy(assignment)
            for position, identity in pairs(dutils.realized_item_assignment(identity_at)) do
                realized[key("item", position)] = split_graph.nodes[key("item", identity)].old_trav
            end
            return realized
        end,
    })
    local slot_to_trav = {}
    local trav_to_slot = {}
    for _, slot_key in pairs(slot_keys) do
        slot_to_trav[slot_key] = assignment[slot_key]
        trav_to_slot[assignment[slot_key]] = slot_key
    end
    monotone_matching.connect(split_graph, {
        slot_to_base = slot_to_base,
        trav_to_head = trav_to_head,
    }, assignment)
    local ordered_sort = top.sort(split_graph, nil, nil, {
        choose_randomly = true,
        complex_contexts = true,
    })

    -- Mechanics must keep every context they had in vanilla; monotone matching assumes monotone logic, which the tech discovery rule isn't, so check it
    -- Only the protected part of each context counts (see protection.lua)
    local lost = {}
    local kept_by_node = {}
    for _, pebble in pairs(ordered_sort.sorted) do
        -- Protection is declared on the original nodes (split graph travs don't carry it, and aren't mechanics)
        local node = spoofed_graph.nodes[pebble.node_key] or split_graph.nodes[pebble.node_key]
        kept_by_node[pebble.node_key] = kept_by_node[pebble.node_key] or {}
        kept_by_node[pebble.node_key][protection.kept_part(node, pebble.context)] = true
    end
    for _, pebble in pairs(init_sort.sorted) do
        local node = spoofed_graph.nodes[pebble.node_key]
        local kept = protection.kept_part(node, pebble.context)
        if node.mechanic and node.type ~= "orand" and (kept_by_node[pebble.node_key] or {})[kept] == nil then
            table.insert(lost, pebble.node_key .. " @ " .. kept)
        end
    end
    if #lost > 0 then
        log("First pass lost " .. #lost .. " mechanic contexts, e.g. " .. table.concat(lost, ", ", 1, math.min(5, #lost)))
        return false
    end

    local mechanics_sets_to_nodes = {}
    local mechanics_sets_to_size = {}
    -- Count each trav once (at its first pebble), matching mechanics_sets_to_ordered
    local is_trav_ordered = {}
    for _, pebble in pairs(ordered_sort.sorted) do
        local node = split_graph.nodes[pebble.node_key]
        if node.trav and is_trav_ordered[pebble.node_key] == nil then
            is_trav_ordered[pebble.node_key] = true
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
        sort = ordered_sort,
        graph = split_graph,
        mechanics_sets_to_ordered = mechanics_sets_to_ordered,
        mechanics_sets_to_nodes = mechanics_sets_to_nodes,
        trav_to_mechanics_key = trav_to_mechanics_key,
    }
end

return first_pass
