local constants = require("helper-tables/constants")
local build_graph = require("lib/graph/build-graph")
local graph_utils = require("lib/graph/graph-utils")
local path = require("lib/graph/path")
local top_sort = require("lib/graph/top-sort")
local rng = require("lib/random/rng")
local helper = require("randomizations/graph/unified/helper")

local handler_ids = {
    "entity-to-mining-results",
    --"item-spoiling",
    -- Having troubles with this; likely because recipes are AND nodes
    "recipe-ingredients",
    "recipe-results",
}

-- CRITICAL TODO:
--  * Investigate why petroleum gas is thought to be reachable by the algorithm
--  * More randomizations
--  * Add some constraints on what edges get randomized and check for any other necessary special fixes
--  * Refer to notes app for anything else special I might need
--  * Fix data.raw properly (with cost preservation etc.)
--  * Outline algo & plug into chatGPT for bugfixes
--  * Try with base game... I'm not convinced the surface logic works
--  * At some point I NEED to reconstruct the graph according to slot-specific rules, so if like a recipe is set to make another item, don't wire it to that traveler-node necessarily, wire it to the craft-material node for that item
--      We might not actually use traveler-node (from graph surgery) at that point either?
--  * Right now I judge having the travelers all in place good enough, but this results in some awkward situations where some slots are leftover, which doesn't impact reachability but leaves in some vanilla ways of doing things that looks weird
--      I could figure out what to do about that

-- LATER:
--  * Fix one-to-one-ness? So, like, you can't connect the same item as the result of a recipe twice
--  * Go through surface-specific logic again, make sure things make sense, improve it to be less heuristic/hardcoded (might need to be done sooner than later depending on how things go)
--  * Add a utility function for "which planet is this on", could be used in some handlers like item-spoiling
--  * A default.lua handler function, where I can also put generic comments/documentation instead of in recipe-results.lua

-- DONE:
--  * Fallback mechanisms

-- IDEAS:
--  * Make a thing surface-specific if blacklisting its surface-specific node for that surface causes it to be fully unreachable (every item should be surface specific to one spot, maybe other things are agnostic)
--      Via this logic, we can just assign surfaces based off "which surface-specific node do we come across first"
--      No wait, with some things like entities, we might be able to build biochamber on vulcanus first if that's somehow found first, but it indeed belongs to gleba and this is important
--      We could solve this by trying same-surface nodes first in top sort
--      With nodes locked to surfaces... what can we do?

-- NOTE: will need to potentially order EDGES!
--    Actually, just do this via ordering on their source vertices!
-- Terminology:
--  * conn is for slot-traveler, edge is for graph
randomizations.unified = function(id)
    -- TODO: Common constants/costs/etc. up here

    ----------------------------------------------------------------------------------------------------
    -- SETUP (Mostly utility stuff that couldn't be defined in helper)
    ----------------------------------------------------------------------------------------------------

    local old_data = table.deepcopy(data.raw)

    -- Note: this must be done before conn_handlers is populated
    -- There is also another initialization that must be done afterward
    -- These two cannot be merged!
    helper.init()

    -- Getting handlers (they'll be further initialized later)
    local default_handler = require("randomizations/graph/unified/handlers/default")

    local conn_handlers = {}
    for _, handler_id in pairs(handler_ids) do
        conn_handlers[handler_id] = require("randomizations/graph/unified/handlers/" .. handler_id)

        -- Check that handler has required keys
        for req_key, _ in pairs(default_handler.required_fields) do
            if conn_handlers[handler_id][req_key] == nil then
                error("Handler with ID " .. handler_id " missing required key " .. req_key)
            end
        end

        -- Fill in defaults
        for k, v in pairs(default_handler) do
            if conn_handlers[handler_id][k] == nil then
                conn_handlers[handler_id][k] = v
            end
        end
    end

    ----------------------------------------------------------------------------------------------------
    -- MODIFICATIONS: ADDING DUMMIES
    ----------------------------------------------------------------------------------------------------

    -- We need a very initial sort for some handlers to know how to add dummies; we'll do another sort afterward with the dummies that will be our primary sort_info
    local pre_dummy_sort_info = top_sort.sort(dep_graph)

    -- This step must come before the sort so that the dummies appear in the sort
    for _, handler in pairs(conn_handlers) do
        handler.state.pre_dummy_sort_info = pre_dummy_sort_info
        handler.add_dummies()
    end

    -- Reinitialize helper to account for new dummies
    helper.init()

    ----------------------------------------------------------------------------------------------------
    -- VANILLA SORT
    ----------------------------------------------------------------------------------------------------

    local vanilla_sort_info = top_sort.sort(dep_graph)

    -- Reorder dummies to be at the end
    local non_dummy_nodes_in_order = {}
    local dummy_nodes_in_order = {}
    for _, node in pairs(vanilla_sort_info.sorted) do
        if not node.dummy then
            table.insert(non_dummy_nodes_in_order, node)
        else
            table.insert(dummy_nodes_in_order, node)
        end
    end
    vanilla_sort_info.sorted = {}
    for _, node in pairs(non_dummy_nodes_in_order) do
        table.insert(vanilla_sort_info.sorted, node)
    end
    for _, node in pairs(dummy_nodes_in_order) do
        table.insert(vanilla_sort_info.sorted, node)
    end

    -- Create node to surface maps
    -- TODO: Don't hardcode planets here
    -- The issue is that we need to be careful, since we don't really care about aquilo here; it really depends on the planet how it should be treated!
    local planet_names = {}
    if mods["space-age"] then
        planet_names = {"fulgora", "gleba", "vulcanus"}
    end
    local vanilla_planet_sort_info = {}
    for _, planet_name in pairs(planet_names) do
        local planet_specific_blacklist = {}
        for _, other_planet_name in pairs(planet_names) do
            if other_planet_name ~= planet_name then
                local other_planet_node = graph_utils.getk("space-location-discovery", other_planet_name)
                for _, prereq in pairs(other_planet_node.prereqs) do
                    planet_specific_blacklist[build_graph.conn_key({prereq, other_planet_node})] = true
                end
            end
        end
        -- Also blacklist planet launch node for this planet
        local planet_launch_node = graph_utils.getk("planet-launch", planet_name)
        for _, prereq in pairs(planet_launch_node.prereqs) do
            planet_specific_blacklist[build_graph.conn_key({prereq, planet_launch_node})] = true
        end
        vanilla_planet_sort_info[planet_name] = top_sort.sort(dep_graph, planet_specific_blacklist)
    end
    -- Assigns what planet a node "belongs" to in some heuristic way
    -- If there are multiple, we assume nauvis is one and set the node assigned to nauvis
    -- This should be the case in space age; compatibility layers will be needed for other mods
    local node_to_surface = {}
    for _, node in pairs(vanilla_sort_info.sorted) do
        local node_key = graph_utils.get_node_key(node)
        local surface_specific_node_type = node.type .. "-surface"

        if node.surface ~= nil then
            node_to_surface[node_key] = node.surface
        elseif build_graph.ops[surface_specific_node_type] ~= nil then
            local nauvis_specific_node = helper.specify_node_to_surface(node, build_graph.compound_key({"planet", "nauvis"}))
            local nauvis_specific_node_key
            if nauvis_specific_node ~= nil then
                nauvis_specific_node_key = graph_utils.get_node_key(nauvis_specific_node)
                -- A surface-agnostic node with surface counterparts is assigned to a non-nauvis planet if either:
                --   1. It is not reachable on nauvis in the corresponding planet sort and reachable on the planet there (so that maybe you can transport it later, but it comes before the silo you set up to do so)
                --   2. It is never reachable on nauvis but eventually reachable on that plane (so that maybe it comes after the silo where you have capabilities of transport, but it's just flat-out surface-locked)
                -- If we come across more than one planet for a node, we keep the first and log the situation, then continue (hoping no issues arise)
                for _, planet_name in pairs(planet_names) do
                    local surface_specific_node = helper.specify_node_to_surface(node, build_graph.compound_key({"planet", planet_name}))
                    local surface_specific_node_key = graph_utils.get_node_key(surface_specific_node)
                    if ((vanilla_planet_sort_info[planet_name].reachable[surface_specific_node_key] and not vanilla_planet_sort_info[planet_name].reachable[nauvis_specific_node_key]) or (vanilla_sort_info.reachable[surface_specific_node_key] and not vanilla_sort_info.reachable[nauvis_specific_node_key])) then
                        if node_to_surface[node_key] ~= nil then
                            log(node_key .. " has multiple planets")
                            node_to_surface[node_key] = build_graph.compound_key({"planet", "nauvis"})
                            break
                        else
                            node_to_surface[node_key] = build_graph.compound_key({"planet", planet_name})
                        end
                    end
                end
            end
            -- If node_to_surface[node_key] is still unassigned and it is nauvis reachable, assign it to nauvis,
            --     if its space-platform surface-specific node is reachable, assign it to space-platform
            --     otherwise assign this to aquilo
            local platform_specific_node = helper.specify_node_to_surface(node, build_graph.compound_key({"space-surface", "space-platform"}))
            if node_to_surface[node_key] == nil then
                if nauvis_specific_node_key ~= nil and vanilla_sort_info.reachable[nauvis_specific_node_key] then
                    node_to_surface[node_key] = build_graph.compound_key({"planet", "nauvis"})
                elseif platform_specific_node ~= nil and vanilla_sort_info.reachable[graph_utils.get_node_key(platform_specific_node)] then
                    node_to_surface[node_key] = build_graph.compound_key({"space-surface", "space-platform"})
                else
                    node_to_surface[node_key] = build_graph.compound_key({"planet", "aquilo"})
                end
            end
        else
            -- A surface-agnostic node with no surface counterparts (like techonologies) is simply assigned nauvis
            node_to_surface[node_key] = build_graph.compound_key({"planet", "nauvis"})
        end
    end
    
    -- Find a short path for calculating reservable slots
    local node_to_ind_in_sorted = {}
    -- Create a victory node that depends on all science packs
    -- Also create a "completion" node that depends on all reachable items in general (for determining if a node is significant but not necessarily critical)
    -- Just assume science packs = tool prototypes
    local all_tool_node = {
        type = "victory",
        name = "canonical",
        prereqs = {},
        dependents = {}
    }
    local all_item_node = {
        type = "completion",
        name = "canonical",
        prereqs = {},
        dependents = {}
    }
    for ind, node in pairs(vanilla_sort_info.sorted) do
        node_to_ind_in_sorted[graph_utils.get_node_key(node)] = ind
        if node.type == "item" and not node.dummy then
            graph_utils.add_prereq(node, all_item_node)
            if helper.items[node.item].type == "tool" then
                graph_utils.add_prereq(node, all_tool_node)
            end
        end
    end
    local all_sorted = vanilla_sort_info.sorted
    table.insert(all_sorted, all_tool_node)
    table.insert(all_sorted, all_item_node)
    for _, node in pairs(all_sorted) do
        table.sort(node.prereqs, function(prereq1, prereq2)
            if not vanilla_sort_info.reachable[graph_utils.get_node_key(prereq1)] then
                return false
            end
            if not vanilla_sort_info.reachable[graph_utils.get_node_key(prereq2)] then
                return true
            end
            return node_to_ind_in_sorted[graph_utils.get_node_key(prereq1)] < node_to_ind_in_sorted[graph_utils.get_node_key(prereq2)]
        end)
    end
    local is_critical_node = path.find_path(dep_graph, all_tool_node)
    --log(serpent.block(is_critical_node))
    local is_significant = path.find_path(dep_graph, all_item_node)
    --log(serpent.block(is_significant))

    ----------------------------------------------------------------------------------------------------
    -- INITIALIZE HANDLERS
    ----------------------------------------------------------------------------------------------------

    local state_to_pass = {
        old_data = old_data,
        is_critical = is_critical_node,
        is_significant = is_significant,
        node_to_surface = node_to_surface,
    }
    for _, handler in pairs(conn_handlers) do
        handler.init(state_to_pass)
    end

    -- Also initialize helper's access to these handlers
    helper.init_handlers(conn_handlers)

    ----------------------------------------------------------------------------------------------------
    -- SLOT/TRAVELER GATHERING
    ----------------------------------------------------------------------------------------------------

    local is_added_slot = {}
    local sorted_slots = {}
    local shuffled_travelers = {}
    local edge_reconfigs = {}
    local slot_to_vanilla_traveler = {}
    local traveler_to_vanilla_slot = {}
    for _, node in pairs(vanilla_sort_info.sorted) do
        for handler_id, handler in pairs(conn_handlers) do
            if handler.source_types[node.type] then
                for _, dependent in pairs(node.dependents) do
                    if handler.target_types[dependent.type] then
                        local dependent_node = graph_utils.get(dependent)
                        local edge
                        -- If this is a grouped surface handler, then use the surface-agnostic versions of the nodes
                        -- TODO: This assumes a one-to-one connection between edges in the case of one surface or another; this is almost always the case, but I could generalize this
                        if handler.group_surfaces then
                            edge = {helper.surface_to_agnostic[graph_utils.get_node_key(node)], helper.surface_to_agnostic[graph_utils.get_node_key(dependent_node)]}
                        else
                            edge = {node, dependent_node}
                        end
                        local slot = handler.create_slot(edge)
                        local traveler = handler.create_traveler(edge)
                        -- Check that slot and traveler creation succeeded
                        -- TODO: It might be more intuitive to include this as part of a separate validation function for edges
                        if slot and traveler then
                            -- Add auto-generated fields
                            for connector_type, slot_or_traveler in pairs({slot = slot, traveler = traveler}) do
                                slot_or_traveler.type = build_graph.compound_key({connector_type, handler_id})
                                slot_or_traveler.name = build_graph.conn_key(edge)
                                slot_or_traveler.connector_type = connector_type
                                slot_or_traveler.handler_id = handler_id
                                slot_or_traveler.edge = edge
                            end
                            if node.dummy then
                                slot.dummy = true
                            end
                            if dependent_node.dummy then
                                traveler.dummy = true
                            end

                            -- Check if we've added this edge already
                            if not is_added_slot[graph_utils.get_node_key(slot)] then
                                is_added_slot[graph_utils.get_node_key(slot)] = true
                                table.insert(sorted_slots, slot)
                                table.insert(shuffled_travelers, traveler)
                                table.insert(edge_reconfigs, {edge = edge, slot = slot, traveler = traveler, handler_id = handler_id})
                                slot_to_vanilla_traveler[graph_utils.get_node_key(slot)] = traveler
                                traveler_to_vanilla_slot[graph_utils.get_node_key(traveler)] = slot
                            end
                        end
                    end
                end
            end
        end
    end
    -- We actually want to put the dummy slots in reverse order so that we don't just crowd out using just the ones at the beginning
    local non_dummy_slots = {}
    local dummy_slots = {}
    for _, slot in pairs(sorted_slots) do
        if not slot.dummy then
            table.insert(non_dummy_slots, slot)
        else
            table.insert(dummy_slots, slot)
        end
    end
    sorted_slots = {}
    for _, slot in pairs(non_dummy_slots) do
        table.insert(sorted_slots, slot)
    end
    for i = #dummy_slots, 1, -1 do
        table.insert(sorted_slots, dummy_slots[i])
    end

    ----------------------------------------------------------------------------------------------------
    -- PERFORM GRAPH SURGERY
    ----------------------------------------------------------------------------------------------------

    -- Removing edges is not sufficient for AND nodes since this actually makes them "more" reachable
    -- What we should do is create an intermediate node that still feeds into the AND node and remove the edge to that
    -- However, I don't do AND nodes yet so no need to worry too much about it now
    -- CHECK: Okay, I think this fixed it, but I might need to replace some nodes in the code with these new slot and traveler nodes
    -- At the very least AND nodes are now getting an unsatisfied prereq
    for _, reconfiguration in pairs(edge_reconfigs) do
        if not conn_handlers[reconfiguration.handler_id].group_surfaces then
            graph_utils.remove_prereq(reconfiguration.edge[1], reconfiguration.edge[2])
            
            local slot_node = {
                type = "slot",
                name = reconfiguration.slot.name,
                prereqs = {},
                dependents = {}
            }
            graph_utils.add_prereq(reconfiguration.edge[1], slot_node)
            reconfiguration.slot.node = slot_node
            dep_graph[graph_utils.get_node_key(slot_node)] = slot_node

            local traveler_node = {
                type = "traveler",
                name = reconfiguration.traveler.name,
                prereqs = {},
                dependents = {}
            }
            graph_utils.add_prereq(traveler_node, reconfiguration.edge[2])
            reconfiguration.traveler.node = traveler_node
            dep_graph[graph_utils.get_node_key(traveler_node)] = traveler_node
        else
            -- Add surface-specific nodes if applicable
            -- Assume in this case there aren't direct connections between the non-surface-specific nodes
            -- TODO: Remove this assumption!
            local slot_nodes = {}
            local traveler_nodes = {}

            for surface_name, surface in pairs(build_graph.surfaces) do
                graph_utils.remove_prereq(helper.specify_node_to_surface(reconfiguration.edge[1], surface_name), helper.specify_node_to_surface(reconfiguration.edge[2], surface_name))
                
                local surface_slot_node = {
                    type = "slot-surface",
                    name = build_graph.compound_key({reconfiguration.slot.name, surface_name}),
                    prereqs = {},
                    dependents = {},
                    surface = surface_name
                }
                graph_utils.add_prereq(helper.specify_node_to_surface(reconfiguration.edge[1], surface_name), surface_slot_node)
                slot_nodes[surface_name] = surface_slot_node
                dep_graph[graph_utils.get_node_key(surface_slot_node)] = surface_slot_node

                local surface_traveler_node = {
                    type = "traveler-surface",
                    name = build_graph.compound_key({reconfiguration.traveler.name, surface_name}),
                    prereqs = {},
                    dependents = {},
                    surface = surface_name
                }
                graph_utils.add_prereq(surface_traveler_node, helper.specify_node_to_surface(reconfiguration.edge[2], surface_name))
                traveler_nodes[surface_name] = surface_traveler_node
                dep_graph[graph_utils.get_node_key(surface_traveler_node)] = surface_traveler_node
            end

            reconfiguration.slot.nodes = slot_nodes
            reconfiguration.traveler.nodes = traveler_nodes
        end
    end

    ----------------------------------------------------------------------------------------------------
    -- DO THE SHUFFLE
    ----------------------------------------------------------------------------------------------------

    rng.shuffle(rng.key({id = id}), shuffled_travelers)
    -- Put the dummy nodes at the end of shuffled_travelers
    local non_dummy_travelers_in_order = {}
    local dummy_travelers_in_order = {}
    for _, node in pairs(shuffled_travelers) do
        if not node.dummy then
            table.insert(non_dummy_travelers_in_order, node)
        else
            table.insert(dummy_travelers_in_order, node)
        end
    end
    shuffled_travelers = {}
    for _, node in pairs(non_dummy_travelers_in_order) do
        table.insert(shuffled_travelers, node)
    end
    for _, node in pairs(dummy_travelers_in_order) do
        table.insert(shuffled_travelers, node)
    end

    -- Reservable slots can be "reserved" by future travelers without giving anything new yet
    -- If needed, the most recent reservation is undone and replace with an important traveler
    -- Once a traveler's original/vanilla slot becomes reachable, the reservation is "fulfilled"
    -- Note: This means the original slots must be calculable!
    local reserved_slots = {}
    local is_reserved_slot = {}
    -- Some reservations shouldn't get fulfilled so that they remain available for being booted out (namely if the traveler was already fulfilled)
    -- These connections are added at the end
    local is_permanently_reserved = {}

    local function is_reservable(slot)
        return conn_handlers[slot.handler_id].is_reservable(slot)
    end

    -- Note: Make sure to ignore priority for reservations
    -- It's only for booting things out (and later maybe normal assignments if things aren't going well)
    local function traveler_priority(traveler)
        return conn_handlers[traveler.handler_id].traveler_priority(traveler)
    end

    -- Since slots are chosen first, we don't need to pay attention to surface constraints yet
    -- Still allow to restrict reachable in case we need it later
    local function is_slot_reachable(reachable, slot)
        -- Look at the actual slot node; this helps account for dummies too
        if slot.node ~= nil then
            return reachable[graph_utils.get_node_key(slot.node)]
        else
            for _, node in pairs(slot.nodes) do
                if reachable[graph_utils.get_node_key(node)] then
                    return true
                end
            end
        end
        return false
    end

    -- To check surface constraints, check surface compatibility in main loop rather than here
    -- For a traveler to be reachable, it is either reachable in the new version, or would have been reachable if it was in its old slot in the new version
    local function is_traveler_reachable(reachable, traveler)
        -- dummies are never reachable
        if traveler.dummy then
            return false
        end

        -- Is the "or if it would have been reachable in the old version" logic right? Why are we doing that?
        return reachable[graph_utils.get_node_key(helper.to_canonical(traveler))] or is_slot_reachable(reachable, traveler_to_vanilla_slot[graph_utils.get_node_key(traveler)])
    end

    -- Figure out how many slots to go through
    local num_normal_travelers = 0
    local num_normal_travelers_satisfied = 0
    for _, traveler in pairs(shuffled_travelers) do
        if not traveler.dummy then
            num_normal_travelers = num_normal_travelers + 1
        end
    end

    local curr_global_sort_info = top_sort.sort(dep_graph)
    for _, handler in pairs(conn_handlers) do
        handler.state.curr_global_sort_info = curr_global_sort_info
    end
    local function add_slot_traveler_conns(slot, traveler)
        -- Have the slot's handler take care of this
        -- Actually, I don't think we need anything fancy, so just do something generic
        -- The following logic assumes slot and traveler are both surface-grouped or both not surface-grouped
        -- I think this is a fine assumption and true most of the time, but it would probably be good to expand cases later
        -- TODO: Take care of other cases?
        if not conn_handlers[slot.handler_id].group_surfaces and not conn_handlers[traveler.handler_id].group_surfaces then
            -- Just add a connection from between the corresponding nodes; we're looking at the real slot and traveler nodes now, not their "canonical" representation
            graph_utils.add_prereq(slot.node, traveler.node)
            -- Since this slot must be reachable, this specific connection must be, so we can do the sort
            -- CRITICAL TODO: Bring back iterative sort
            curr_global_sort_info = top_sort.sort(dep_graph, nil, curr_global_sort_info, {slot.node, traveler.node}, {make_new_conn_reachable = true})
            --curr_global_sort_info = top_sort.sort(dep_graph)
            for _, handler in pairs(conn_handlers) do
                handler.state.curr_global_sort_info = curr_global_sort_info
            end
        elseif conn_handlers[slot.handler_id].group_surfaces and conn_handlers[traveler.handler_id].group_surfaces then
            for surface_name, surface in pairs(build_graph.surfaces) do
                graph_utils.add_prereq(slot.nodes[surface_name], traveler.nodes[surface_name])
                -- In this case, only one of the surface connections may even be reachable, so we can't naively apply sort to each one because some may be unreachable
                -- Thus, we need to check for reachability; in this case it is "raw" reachability, not slot reachability
                if curr_global_sort_info.reachable[graph_utils.get_node_key(slot.nodes[surface_name])] then
                    -- CRITICAL TODO: Bring back iterative sort
                    curr_global_sort_info = top_sort.sort(dep_graph, nil, curr_global_sort_info, {slot.nodes[surface_name], traveler.nodes[surface_name]}, {make_new_conn_reachable = true})
                    --curr_global_sort_info = top_sort.sort(dep_graph)
                    for _, handler in pairs(conn_handlers) do
                        handler.state.curr_global_sort_info = curr_global_sort_info
                    end
                end
            end
        else
            error("Assumption that grouped/ungrouped randomizations can't interact was broken!")
        end
    end

    local slot_to_traveler = {}
    local traveler_to_slot = {}

    local function fulfill_reservation(slot_key)
        log(graph_utils.get_node_key(slot_to_traveler[slot_key]) .. " has fulfilled its reservation in slot " .. slot_key)
        local ind_to_remove
        local corresponding_slot
        for ind, reserved_slot in pairs(reserved_slots) do
            if graph_utils.get_node_key(reserved_slot) == slot_key then
                ind_to_remove = ind
                corresponding_slot = reserved_slot
                break
            end
        end
        table.remove(reserved_slots, ind_to_remove)
        add_slot_traveler_conns(corresponding_slot, slot_to_traveler[slot_key])
        return slot_key
    end

    for i = 1, #sorted_slots do
        -- Check if we've filled all the slots we need to
        if num_normal_travelers_satisfied == num_normal_travelers then
            break
        end

        -- Invariant: Each iteration of the loop must assign one additional slot (slots never go from assigned to unassigned)
        local accepted_slot
        local accepted_traveler

        for j = 1, constants.unified_randomization_max_bootings_in_a_row do
            -- Note: we might need to prioritize surface specific travelers for surface specific slots so that the surface-specific slots don't all get taken by non-surface specific things
            -- TODO: Check that a proposed slot's surface-specific node corresponding to the surface it's assigned to is reachable as well here
            for _, proposed_slot in pairs(sorted_slots) do
                -- Only consider dummies as a last resort; try bootings first
                -- Since dummy slots come last, a break here should be fine since all the remaining slots will also be dummy
                if #reserved_slots >= 1 and j < constants.unified_randomization_max_bootings_in_a_row and proposed_slot.dummy then
                    break
                end
                if slot_to_traveler[graph_utils.get_node_key(proposed_slot)] == nil and is_slot_reachable(curr_global_sort_info.reachable, proposed_slot) then
                    for _, proposed_traveler in pairs(shuffled_travelers) do
                        
    ----------------------------------------------------------------------------------------------------
    -- JUDGE THE PROPOSAL
    ----------------------------------------------------------------------------------------------------

                        local this_traveler_reachable = true
                        if not is_traveler_reachable(curr_global_sort_info.reachable, proposed_traveler) then
                            this_traveler_reachable = false
                        elseif not proposed_slot.dummy then
                            -- Note: We an now assume traveler and slot are not dummy
                            
                            -- Surface reachability
                            -- As a check, make sure that when the slot has a non-nauvis home surface, it must be compatible with the traveler's surface (meaning the traveler is either nauvis or that planet)
                            --     ?? OR the sort for that surface (make sure to add per-surface sorts) has found the planet-launch for that planet
                            -- Wait, why is the last condition fine? We have to have compatibility right? Let's go without it for now; it also means I don't need per-surface sorts yet
                            -- TODO: Think more about this
                            local slot_surface = node_to_surface[helper.to_canonical(proposed_slot)]
                            local traveler_surface = node_to_surface[helper.to_canonical(proposed_traveler)]
                            if slot_surface ~= "nauvis" then
                                if traveler_surface ~= "nauvis" and traveler_surface ~= slot_surface then
                                    this_traveler_reachable = false
                                end
                            end
                        end

                        local to_be_reserved = false
                        if not this_traveler_reachable and is_reservable(proposed_slot) then
                            to_be_reserved = true
                        end

                        if i == 2 then
                            log(serpent.block(proposed_traveler))
                        end

                        -- If the thing that this traveler unlocks was already reachable, do a permanent reservation
                        local to_be_permanently_reserved = false
                        if proposed_traveler.dummy or curr_global_sort_info.reachable[graph_utils.get_node_key(helper.to_canonical(proposed_traveler))] then
                            to_be_permanently_reserved = true
                        end

                        if traveler_to_slot[graph_utils.get_node_key(proposed_traveler)] == nil and (to_be_reserved or to_be_permanently_reserved or is_traveler_reachable(curr_global_sort_info.reachable, proposed_traveler)) then
                            -- See if this slot is happy with this traveler
                            if conn_handlers[proposed_slot.handler_id].validate_connection(proposed_slot, proposed_traveler) then
                                if to_be_reserved or to_be_permanently_reserved then
                                    table.insert(reserved_slots, proposed_slot)
                                    is_reserved_slot[graph_utils.get_node_key(proposed_slot)] = true
                                    if to_be_permanently_reserved then
                                        is_permanently_reserved[graph_utils.get_node_key(proposed_slot)] = true
                                    end
                                end
                                accepted_slot = proposed_slot
                                accepted_traveler = proposed_traveler
                                break
                            end
                        end
                    end
                end
                if accepted_slot ~= nil then
                    break
                end
            end

            if accepted_slot == nil then
                local failed_travelers_in_priority_order = {}
                for _, failed_traveler in pairs(shuffled_travelers) do
                    -- Check reachable and unused
                    if is_traveler_reachable(curr_global_sort_info.reachable, failed_traveler) and traveler_to_slot[graph_utils.get_node_key(failed_traveler)] == nil then
                        table.insert(failed_travelers_in_priority_order, failed_traveler)
                    end
                end
                table.sort(failed_travelers_in_priority_order, function(t1, t2)
                    return conn_handlers[t1.handler_id].traveler_priority(t1) > conn_handlers[t2.handler_id].traveler_priority(t2)
                end)
                for _, failed_traveler in pairs(failed_travelers_in_priority_order) do
                    local ind_to_boot = #reserved_slots
                    local booted_slot = reserved_slots[ind_to_boot]
                    if #reserved_slots >= 1 and conn_handlers[booted_slot.handler_id].validate_connection(booted_slot, failed_traveler) then
                        -- Boot out the most recent reservation
                        table.remove(reserved_slots, ind_to_boot)
                        is_reserved_slot[graph_utils.get_node_key(booted_slot)] = nil
                        is_permanently_reserved[graph_utils.get_node_key(booted_slot)] = nil

                        -- Switch out slot/traveler tables
                        local booted_traveler = slot_to_traveler[graph_utils.get_node_key(booted_slot)]
                        slot_to_traveler[graph_utils.get_node_key(booted_slot)] = failed_traveler
                        traveler_to_slot[graph_utils.get_node_key(failed_traveler)] = booted_slot
                        traveler_to_slot[graph_utils.get_node_key(booted_traveler)] = nil

                        -- If we booted out a dummy traveler, this increases number of non-dummies
                        -- Theoretically, a dummy could boot out something normal, but that's very unlikely and I don't feel like testing for everything
                        if booted_traveler.dummy and not failed_traveler.dummy then
                            num_normal_travelers_satisfied = num_normal_travelers_satisfied + 1
                        end

                        add_slot_traveler_conns(booted_slot, failed_traveler)

                        log("Booted out " .. graph_utils.get_node_key(booted_traveler) .. " in slot " .. graph_utils.get_node_key(booted_slot) .. " in favor of " .. graph_utils.get_node_key(failed_traveler))
                    end
                end
            else
                break
            end
        end
        if accepted_slot == nil then
            -- If the traveler's canonical nodes are reachable, then it's probably fine
            local actually_its_fine = true
            for _, traveler in pairs(shuffled_travelers) do
                if not traveler.dummy and not curr_global_sort_info.reachable[graph_utils.get_node_key(helper.to_canonical(traveler))] then
                    actually_its_fine = false
                end
            end
            if actually_its_fine then
                log("Randomizer limped over the finish line, but think's it's okay?")
                break
            end

            -- Quick hotfix: the randomizer is failing on finding *ingredients* for some recipes, which is a bit ridiculous, so I'm just going to ignore them in that case
            -- CRITICAL TODO: Undo this hotfix
            local no_really_its_fine = true
            for _, traveler in pairs(shuffled_travelers) do
                if not traveler.dummy and traveler_to_slot[graph_utils.get_node_key(traveler)] == nil and traveler.handler_id ~= "recipe-ingredients" then
                    no_really_its_fine = false
                end
            end
            if no_really_its_fine then
                log("Randomizer limped over the finish line, but think's it's okay?")
                break
            end

            log(serpent.block(curr_global_sort_info.reachable))
            log("Unused slots:")
            for _, slot in pairs(sorted_slots) do
                if slot_to_traveler[graph_utils.get_node_key(slot)] == nil then
                    log("\n" .. graph_utils.get_node_key(slot))
                    log(is_slot_reachable(curr_global_sort_info.reachable, slot))
                end
            end
            log("Unused non-dummy travelers:")
            for _, traveler in pairs(shuffled_travelers) do
                if traveler_to_slot[graph_utils.get_node_key(traveler)] == nil and not traveler.dummy then
                    log("\n" .. graph_utils.get_node_key(traveler))
                    log(is_traveler_reachable(curr_global_sort_info.reachable, traveler))
                end
            end
            error("Unified randomization failed at " .. tostring(math.floor(100 * num_normal_travelers_satisfied / num_normal_travelers)) .. "%.")
            -- TODO: Decide if I want to disable reachability condition for last stretch
            -- If we're more than 90% of the way there, disable reachability conditions instead
            --[[if not desperate_reachability_disable and (#item_slots - i) <= 0.1 * #item_slots then
                log("Disabling reachability checks... " .. tostring(math.floor(100 * i / #item_slots)) .. "% of the way done!")
                desperate_reachability_disable = true
            else
                error("Item randomization failed at " .. tostring(math.floor(100 * i / #item_slots)) .. "%. Perhaps try a different seed?")
            end]]
        else

    ----------------------------------------------------------------------------------------------------
    -- ACCEPTANCE! (HOPEFULLY MORE TO COME)
    ----------------------------------------------------------------------------------------------------

            -- Log the successful reconnection
            log(graph_utils.get_node_key(accepted_slot))
            log(graph_utils.get_node_key(accepted_traveler))

            slot_to_traveler[graph_utils.get_node_key(accepted_slot)] = accepted_traveler
            traveler_to_slot[graph_utils.get_node_key(accepted_traveler)] = accepted_slot
            if not accepted_traveler.dummy then
                num_normal_travelers_satisfied = num_normal_travelers_satisfied + 1
            end

            -- Reserved slots don't unlock anything... yet
            -- This way "backtracking" to them doesn't actually require undoing anything
            if not is_reserved_slot[graph_utils.get_node_key(accepted_slot)] then
                add_slot_traveler_conns(accepted_slot, accepted_traveler)
            end

            -- Check over all reachable slots in case a reserved one now has a reachable item
            local reservations_complete = {}
            for slot_key, _ in pairs(is_reserved_slot) do
                if is_traveler_reachable(curr_global_sort_info.reachable, slot_to_traveler[slot_key]) and not is_permanently_reserved[slot_key] then
                    table.insert(reservations_complete, fulfill_reservation(slot_key))
                end
            end
            for _, slot_key in pairs(reservations_complete) do
                is_reserved_slot[slot_key] = nil
            end

            curr_global_sort_info = top_sort.sort(dep_graph)
        end
    end

    -- Add permanent reservations
    for slot_key, _ in pairs(is_permanently_reserved) do
        fulfill_reservation(slot_key)
    end

    ----------------------------------------------------------------------------------------------------
    -- REFLECT ONTO DATA.RAW
    ----------------------------------------------------------------------------------------------------

    for _, handler in pairs(conn_handlers) do
        -- slot is the master of what happens to fix data.raw
        -- conn_handlers is needed in case slot needs to know things about its new traveler
        handler.reflect(sorted_slots, slot_to_traveler)
    end
end