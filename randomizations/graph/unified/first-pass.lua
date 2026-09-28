-- First pass: randomizes which item identity (trav) goes in which item position (slot), before the other handlers run
-- With constants.entity_first_pass, entity randomization adds entity positions too (params.entity_rules, see first_pass_rules in handlers/entity.lua): every way an entity is acquired (an item placing it, a spot in the wild, a spawner's slot, a trigger, an egg, a death) is a position, and the entity acquired there its identity
-- Entity positions are orands, so any identity can go to any position its rules allow, like a building found in the wild (salvage) or carried by biters, and connecting them gains or loses what the pairing does (params.connection in monotone matching)
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

local constants = require("helper-tables/constants")
local gutils = require("lib/graph/graph-utils")
local dutils = require("lib/data-utils")
local top = require("lib/graph/context-sort")
local monotone_matching = require("randomizations/graph/unified/skeleton/monotone-matching")
local item_fluid = require("lib/item-fluid")
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

-- Material cost key of a slot, or of the slot a trav came from: a fluid slot (a fluid-temperature node) is costed as its fluid
local function cost_key(node_key)
    local node_parts = gutils.deconstruct(node_key)
    if node_parts.type == "fluid-temperature" then
        return key("fluid", gutils.deconstruct(node_parts.name).type)
    end
    return node_key
end

-- The form a slot, or the slot a trav came from, stands for ("item" or "fluid", see lib/item-fluid.lua), or nil for other slots
local function form_of(node_key)
    local node_type = gutils.deconstruct(node_key).type
    if node_type == "item" then
        return "item"
    elseif node_type == "fluid-temperature" then
        return "fluid"
    end
    return nil
end

-- Whether a slot and trav's material costs are close enough to swap them
local function cost_ok(slot, trav)
    local slot_cost = material_costs.costs[cost_key(key(slot))]
    local trav_cost = material_costs.costs[cost_key(trav.old_slot)]
    if type(slot_cost) ~= type(trav_cost) then
        return false
    end
    if slot_cost ~= nil then
        -- Be more permissive about putting cheap travelers in expensive slots
        return math.log(trav_cost) - math.log(slot_cost) <= constants.first_pass_max_cost_log_difference_expensive and math.log(slot_cost) - math.log(trav_cost) <= constants.first_pass_max_cost_log_difference_cheap
    end
    return true
end

-- Whether a trav can go in a slot: their costs fit, and coal's slot only takes travs that item reflection makes the same kind of fuel as coal (see dutils.replacement_gets_fuel)
-- Fuels with burnt results are a separate kind (see lib/lookup/2-simple/fuel.lua), and the rule doesn't remove burnt results
-- An identity changing form (an item at a fluid position or the other way around) takes its new position's amounts as they are, so its costs don't have to fit
local function pair_ok(slot, trav)
    local slot_form = form_of(key(slot))
    local trav_form = form_of(trav.old_slot)
    local changes_form = slot_form ~= nil and trav_form ~= nil and slot_form ~= trav_form
    if not changes_form and not cost_ok(slot, trav) then
        return false
    end
    if slot.type == "item" and dutils.replacement_gets_fuel(slot.name) then
        local item = dutils.get_prot("item", gutils.deconstruct(trav.old_slot).name)
        return item ~= nil and (item.burnt_result == nil or item.burnt_result == "")
    end
    return true
end

-- Returns false if first pass failed (so the attempt is retried)
-- params: spoofed_graph and subdiv_graph (unified's graphs of the game), debt (optional: planetary changes superposed, see planetary.superposed), and entity_rules (optional: entity randomization's first_pass_rules, given the subdivided graph)
first_pass.execute = function(params)
    ----------------------------------------------------------------------------------------------------
    -- CHOOSE SLOTS
    ----------------------------------------------------------------------------------------------------

    -- spoofed_graph is used to get prereqs before subdivision
    local spoofed_graph = table.deepcopy(params.spoofed_graph)
    local subdiv_graph = table.deepcopy(params.subdiv_graph)

    -- Sorts here use home contexts, so the tech discovery rule doesn't depend on order (see context-sort.lua)
    local init_sort
    if not mods["pyalternativeenergy"] then
        init_sort = top.sort(spoofed_graph, nil, nil, {
            choose_randomly = true,
            complex_contexts = true,
            home_contexts = true,
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
            home_contexts = true,
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

    -- Recipes locked to one planet keep every context they have there, like mechanics (see protection.lua)
    local planet_locked = protection.planet_locked_recipe_contexts(spoofed_graph, init_sort)

    -- Entity positions and the rules for pairing them (see the top of this file)
    local entity_rules
    if params.entity_rules ~= nil then
        entity_rules = params.entity_rules(subdiv_graph)
    end

    local lab_inputs = dutils.lab_inputs()
    -- Materials carried around round trips keep their positions (see item_fluid.fluid_slot_ok)
    local round_trip_materials = config.item_fluids and dutils.round_trips().materials or {}
    local function valid_node_for_first_pass(node_key)
        local subdiv_node = subdiv_graph.nodes[node_key]
        -- Entity positions are slots, including items and capsules that make nothing in vanilla, whose sinks are spoofs
        if entity_rules ~= nil and entity_rules.positions[node_key] ~= nil then
            return true
        end
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
        -- Fluid positions too, when items and fluids trade positions (see lib/item-fluid.lua)
        if ITEM_ENABLED and config.item_fluids and item_fluid.fluid_slot_ok(subdiv_graph, subdiv_node, round_trip_materials) then
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
    -- Entity positions nothing reaches in vanilla (like units' placing positions and nowhere positions) are slots too, ranked after everything
    if entity_rules ~= nil then
        local unreached = {}
        for position_key, _ in pairs(entity_rules.positions) do
            if node_in_sorted[position_key] == nil then
                table.insert(unreached, position_key)
            end
        end
        table.sort(unreached)
        for i, position_key in pairs(unreached) do
            node_in_sorted[position_key] = #init_sort.sorted + i
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
            -- Identity heads (entity randomization's mine-back edges, see handlers/entity.lua) belong to the item itself, since mining gives items by name, so they move with the trav
            if (prenode.type ~= "head" or prenode.identity_head ~= nil) and not always_on_slot then
                fixed_pre[pre] = true
            end
        end
        for pre, _ in pairs(fixed_pre) do
            gutils.redirect_edge_stop(split_graph, pre, key(trav))
        end
        local fixed_dep = {}
        -- Whatever replaces coal becomes a fuel like coal (see dutils.replacement_gets_fuel), so that fuel stays on coal's slot, and coal's identity gets its own edge since it's still a fuel wherever it goes
        -- Otherwise coal's identity would be pinned to the earliest slots wherever proofs need early fuel
        local replacement_fuel
        if node.type == "item" and dutils.replacement_gets_fuel(node.name) then
            replacement_fuel = key("fuel-category", gutils.concat({ dutils.REPLACEMENT_FUEL_CATEGORY, 0 }))
        end
        local keeps_replacement_fuel = false
        for dep, _ in pairs(node.dep) do
            local depnode = gutils.depnode(split_graph, dep)
            if depnode.type == "orand" then
                depnode = gutils.unique_depnode(split_graph, depnode)
            end
            local always_on_slot = randomization_info.options.first_pass.always_slot_dep[key(node.type, depnode.type)] ~= nil
            if key(depnode) == replacement_fuel then
                always_on_slot = true
                keeps_replacement_fuel = true
            end
            -- Identity bases (entity randomization's build slots, see handlers/entity.lua) belong to the item itself, so they move with the trav
            if (depnode.type ~= "base" or depnode.identity_base ~= nil) and not always_on_slot then
                fixed_dep[dep] = true
            end
        end
        for dep, _ in pairs(fixed_dep) do
            gutils.redirect_edge_start(split_graph, dep, key(trav))
        end
        if keeps_replacement_fuel then
            gutils.add_edge(split_graph, key(trav), replacement_fuel)
        end

        -- The slot --> trav edge, cut into a base and head, is what gets rewired to match slots and travs
        local slot_trav_edge = gutils.add_edge(split_graph, node, trav)
        local base_head = gutils.subdivide_base_head(split_graph, gutils.ekey(slot_trav_edge))
        slot_to_base[node_key] = base_head.base
        trav_to_head[key(trav)] = base_head.head
        gutils.remove_edge(split_graph, gutils.ekey(gutils.unique_pre(split_graph, base_head.head)))

        -- A fluid slot's fluid node goes with the identity, but mining that needs the fluid is part of the position (see lib/item-fluid.lua)
        if node.type == "fluid-temperature" then
            item_fluid.move_position_deps(split_graph, node_key)
        end
    end
    test_graph_invariants.test(split_graph)

    -- Items and fluids trading positions (see lib/item-fluid.lua): which travs may go to a position of the other form, and the slot of each item or fluid
    local can_change_form = {}
    local slot_of_material = {}
    local fluid_slot_names = {}
    for slot_key, _ in pairs(node_in_sorted) do
        local material = item_fluid.material_of_node(split_graph, split_graph.nodes[slot_key])
        if material ~= nil then
            slot_of_material[item_fluid.material_key(material)] = slot_key
            local trav_key = split_graph.nodes[slot_key].old_trav
            can_change_form[trav_key] = config.item_fluids and item_fluid.can_change_form(split_graph, split_graph.nodes[trav_key])
            if material.type == "fluid" then
                table.insert(fluid_slot_names, material.name)
            end
        end
    end
    if config.item_fluids then
        local num_can_change_form = 0
        for _, can in pairs(can_change_form) do
            if can then
                num_can_change_form = num_can_change_form + 1
            end
        end
        table.sort(fluid_slot_names)
        log("First pass: " .. #fluid_slot_names .. " fluid slots (" .. table.concat(fluid_slot_names, ", ") .. "), " .. num_can_change_form .. " identities that can change form")
    end

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
    local function order_slot(node)
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
    -- A node has a pebble per context, but these lists order nodes, so only count each slot once (at its first pebble)
    local is_slot_ordered = {}
    for _, pebble in pairs(init_sort.sorted) do
        local node = split_graph.nodes[pebble.node_key]
        if node.slot and is_slot_ordered[pebble.node_key] == nil then
            is_slot_ordered[pebble.node_key] = true
            order_slot(node)
        end
    end
    -- Slots the sort never reaches (entity positions ranked after everything, see node_in_sorted) come last, in that rank order
    -- Every slot is then in these lists once, so a trav's place among the travs of its set (mechanics_sets_to_nodes, which counts every trav the final sort reaches) always has a slot
    local unordered_slots = {}
    for slot_key, _ in pairs(node_in_sorted) do
        if is_slot_ordered[slot_key] == nil then
            table.insert(unordered_slots, slot_key)
        end
    end
    table.sort(unordered_slots, function(a, b)
        return node_in_sorted[a] < node_in_sorted[b]
    end)
    for _, slot_key in pairs(unordered_slots) do
        is_slot_ordered[slot_key] = true
        order_slot(split_graph.nodes[slot_key])
    end

    ----------------------------------------------------------------------------------------------------
    -- MATCHING
    ----------------------------------------------------------------------------------------------------

    local slot_keys = {}
    for slot_key, _ in pairs(node_in_sorted) do
        table.insert(slot_keys, slot_key)
    end
    table.sort(slot_keys)
    -- Items that mining a resource gives, which should become something interesting whenever the matching allows it
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

    -- Heads coupled to a slot follow its trav: a head with coupled_slot = the slot takes the base whose coupled_slot is the trav's own slot (the identity's)
    -- With first pass entity positions, entity randomization's mine-back edges are coupled this way: the item placing an entity position is mined back from whatever identity is built there (see handlers/entity.lua)
    -- Otherwise nothing is coupled (its mine-back edges follow its own matching), but a pair's other connections call this (connect_pair_extra)
    -- slot key --> heads coupled to it, and identity slot key --> its coupled base
    local coupled_heads = {}
    local coupled_base = {}
    for node_key, node in pairs(split_graph.nodes) do
        if node.coupled_slot ~= nil and node.type == "head" then
            coupled_heads[node.coupled_slot] = coupled_heads[node.coupled_slot] or {}
            table.insert(coupled_heads[node.coupled_slot], node_key)
        elseif node.coupled_slot ~= nil and node.type == "base" then
            coupled_base[node.coupled_slot] = node_key
        end
    end
    -- An identity with no coupled base (like an entity that isn't mined back into its item) leaves the head detached
    -- Promotion reconnects a cut head without a base to its vanilla base unless it starts detached (see promotion.new), which here would be wrong, so a detached head is marked starts_detached
    local function connect_coupled(graph, slot_key, trav_key)
        local base_key = coupled_base[graph.nodes[trav_key].old_slot]
        for _, head_key in pairs(coupled_heads[slot_key] or {}) do
            for pre, _ in pairs(table.deepcopy(graph.nodes[head_key].pre)) do
                gutils.remove_edge(graph, pre)
            end
            if base_key ~= nil then
                gutils.connect_base_head(graph, base_key, head_key, graph.nodes[base_key].abilities)
                graph.nodes[head_key].starts_detached = nil
            else
                graph.nodes[head_key].starts_detached = true
            end
        end
    end

    -- Entity positions pair by entity randomization's rules, and their connections gain or lose what the pairing does (a carried entity's starts at the position's carrier base)
    -- Travs have the positions' keys in the rules, as each trav is its own slot's vanilla identity
    local function pair_ok_with_entities(slot, trav)
        if entity_rules ~= nil then
            local entity_verdict = entity_rules.pair_ok(slot, trav)
            if entity_verdict ~= nil then
                return entity_verdict
            end
        end
        return pair_ok(slot, trav)
    end
    local function connection(slot_key, trav_key)
        if entity_rules == nil then
            return nil
        end
        return entity_rules.connection(slot_key, split_graph.nodes[trav_key].old_slot)
    end

    -- An identity can go to a position of the other form if nothing about it needs its old form (see item_fluid.can_change_form)
    local function cross_type_ok(slot, trav)
        return can_change_form[key(trav)] == true and item_fluid.material_of_node(split_graph, slot) ~= nil
    end
    -- Besides coupled heads, an item identity at a fluid position is a fluid, which can't be launched (see item_fluid.cut_delivery)
    local function connect_pair_extra(graph, slot_key, trav_key)
        connect_coupled(graph, slot_key, trav_key)
        local position = item_fluid.material_of_node(split_graph, split_graph.nodes[slot_key])
        local identity = item_fluid.material_of_node(split_graph, split_graph.nodes[trav_key])
        if position ~= nil and identity ~= nil and position.type == "fluid" and identity.type == "item" then
            item_fluid.cut_delivery(graph, trav_key)
        end
    end

    -- With planetary changes superposed, goals only their debt reaches must stay reachable with it (see monotone matching's debt goals)
    local assignment, debt_goals = monotone_matching.run({
        slot_keys = slot_keys,
        unconnected_graph = split_graph,
        slot_to_base = slot_to_base,
        trav_to_head = trav_to_head,
        pair_ok = pair_ok_with_entities,
        cross_type_ok = cross_type_ok,
        connection = connection,
        rounds = MONOTONE_MATCHING_ROUNDS,
        is_resource_slot = function(slot_key)
            local slot = split_graph.nodes[slot_key]
            return slot.type == "item" and is_resource_item[slot.name] == true
        end,
        -- Uses the same notion of useless as item reflection, which skips swaps between two useless items
        -- A fluid identity is never interesting there: it could only become a plain item (see item_fluid.can_change_form)
        is_interesting = function(trav_key)
            local identity = item_fluid.material_of_node(split_graph, split_graph.nodes[trav_key])
            if identity == nil or identity.type ~= "item" then
                return false
            end
            local item = dutils.get_prot("item", identity.name)
            return item ~= nil and not dutils.is_useless_item(item)
        end,
        -- Item reflection places useless items differently from the matching (see dutils.reflected_item_position), so each matching is replaced by the one reflection realizes before it's gated
        -- Items and fluids share the rule by their material keys (see item_fluid.useless_predicate)
        realize = function(assignment)
            local identity_at = {}
            for slot_key, trav_key in pairs(assignment) do
                local position = item_fluid.material_of_node(split_graph, split_graph.nodes[slot_key])
                local identity = item_fluid.material_of_node(split_graph, split_graph.nodes[trav_key])
                if position ~= nil and identity ~= nil then
                    identity_at[item_fluid.material_key(position)] = item_fluid.material_key(identity)
                end
            end
            local realized = table.deepcopy(assignment)
            for position_key, identity_key in pairs(dutils.realized_item_assignment(identity_at, item_fluid.useless_predicate(identity_at))) do
                realized[slot_of_material[position_key]] = split_graph.nodes[slot_of_material[identity_key]].old_trav
            end
            return realized
        end,
        debt = params.debt,
        connect_extra = connect_pair_extra,
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
        connection = connection,
        connect_extra = connect_pair_extra,
    }, assignment)
    if config.item_fluids then
        local num_changed_form = 0
        for slot_key, trav_key in pairs(assignment) do
            local position = item_fluid.material_of_node(split_graph, split_graph.nodes[slot_key])
            local identity = item_fluid.material_of_node(split_graph, split_graph.nodes[trav_key])
            if position ~= nil and identity ~= nil and position.type ~= identity.type then
                num_changed_form = num_changed_form + 1
            end
        end
        log("First pass: " .. num_changed_form .. " identities changed form (items and fluids trading positions)")
    end
    local ordered_sort = top.sort(split_graph, nil, nil, {
        choose_randomly = true,
        complex_contexts = true,
        home_contexts = true,
    })

    -- Mechanics must keep every context they had in vanilla; monotone matching's proofs only make that likely, so check it
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
    -- Planet-locked recipes keep their exact contexts
    for node_key, contexts in pairs(planet_locked) do
        for context, _ in pairs(contexts) do
            if (ordered_sort.node_to_context_inds[node_key] or {})[context] == nil then
                table.insert(lost, node_key .. " @ " .. context)
            end
        end
    end
    -- Goals only the debt reaches stay reachable with it
    if debt_goals ~= nil then
        local _, sup_sort = monotone_matching.superposed_sort(split_graph, params.debt)
        for _, pebble in pairs(monotone_matching.lost_debt_goals(debt_goals, sup_sort)) do
            table.insert(lost, pebble.node_key .. " @ " .. pebble.context .. " (with the debt)")
        end
    end
    if #lost > 0 then
        log("First pass lost " .. #lost .. " protected contexts, e.g. " .. table.concat(lost, ", ", 1, math.min(5, #lost)))
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
        planet_locked = planet_locked,
        mechanics_sets_to_ordered = mechanics_sets_to_ordered,
        mechanics_sets_to_nodes = mechanics_sets_to_nodes,
        trav_to_mechanics_key = trav_to_mechanics_key,
    }
end

return first_pass
