--------------------------------------------------------------------------------
-- Item Slot Scramble Randomization
--------------------------------------------------------------------------------
--
-- This implements "slot scramble" for items: randomizing WHERE items come from
-- (their acquisition method) while preserving WHAT they do (their abilities).
--
-- TERMINOLOGY:
--   slot     = where an item comes from (recipe outputs, mining results, loot)
--   traveler = the item's identity (what it does: builds entities, fuels, etc.)
--
-- ALGORITHM OVERVIEW:
--   1. COLLECT: Build lookups for items, entities, resources
--   2. FILTER: Select Nauvis-reachable, stackable items (not science packs)
--   3. SUBDIVIDE: For each item, create item-slot node holding all prereqs;
--                 item node becomes orphaned traveler (OR with no prereqs = unreachable)
--   4. BLACKLIST: Block edges INTO item-surface nodes (prevents ability propagation)
--   5. SHUFFLE: Randomize traveler order
--   6. ASSIGN: Greedily match slots to travelers:
--      - Terminal slots (plain items) accept any traveler (reservation behavior)
--      - Non-terminal slots (buildings, fuel, etc.) require reachable travelers
--      - Cancellation: if stuck, cancel a terminal assignment to make progress
--   7. UNBLACKLIST: As assignments complete, enable item-surface edges
--   8. UPDATE: Modify data.raw (recipes, mining, loot, spoilage, etc.)
--
-- KEY INVARIANT: Monotonic reachability - nodes become reachable and stay reachable.
-- This prevents softlocks by ensuring progression is always possible.
--
--------------------------------------------------------------------------------

local constants = require("helper-tables/constants")
local build_graph = require("lib/graph/build-graph")
local flow_cost = require("lib/graph/flow-cost")
local graph_utils = require("lib/graph/graph-utils")
local path = require("lib/graph/path")
local top_sort = require("lib/graph/top-sort")
local rng = require("lib/random/rng")
local locale_utils = require("lib/locale")

--------------------------------------------------------------------------------
-- Helper Functions
--------------------------------------------------------------------------------
-- Lookups are built at runtime inside the randomization function from data.raw

-- Check if an item prototype is stackable (doesn't have "not-stackable" flag)
local function is_stackable(item_prototype)
    if item_prototype.flags ~= nil then
        for _, flag in pairs(item_prototype.flags) do
            if flag == "not-stackable" then
                return false
            end
        end
    end
    return true
end

-- Build set of items that come from raw resources (always randomized)
-- Not in lookup tables, so we build it here
local function build_raw_resource_set()
    local raw_items = {}
    for _, resource in pairs(data.raw.resource) do
        if resource.minable ~= nil then
            if resource.minable.results ~= nil then
                for _, result in pairs(resource.minable.results) do
                    if result.type == "item" then
                        raw_items[result.name] = true
                    end
                end
            else
                raw_items[resource.minable.result] = true
            end
        end
    end
    return raw_items
end

--------------------------------------------------------------------------------
-- Main Randomization Function
--------------------------------------------------------------------------------

randomizations.item_new = function(id)  -- Changed from item_simple for production use
    -- Items that should never be randomized
    local dont_randomize_item = {
        ["rocket-part"] = true,
        ["spoilage"] = true,
    }

    --------------------------------------------------------------------------
    -- Phase 1: COLLECT - Build lookups from data.raw
    --------------------------------------------------------------------------
    -- Build items lookup from all item prototype types
    local items = {}
    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                items[item.name] = item
            end
        end
    end

    -- Build entities lookup (for loot drops)
    local entities = {}
    for entity_class, _ in pairs(defines.prototypes.entity) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                entities[entity.name] = entity
            end
        end
    end

    local raw_resource_items = build_raw_resource_set()
    
    -- Special cost analysis for item randomization
    local modified_raw_resource_table = flow_cost.get_default_raw_resource_table()
    -- Consider fish/wood as expensive in a slot, but not when traveling
    modified_raw_resource_table["item-raw-fish"] = 1
    modified_raw_resource_table["item-wood"] = 1
    modified_raw_resource_table["item-spoilage"] = nil
    local cost_as_traveler = flow_cost.determine_recipe_item_cost(modified_raw_resource_table, constants.cost_params.time, constants.cost_params.complexity)
    modified_raw_resource_table["item-raw-fish"] = 25
    modified_raw_resource_table["item-wood"] = 5
    modified_raw_resource_table["item-spoilage"] = nil
    local cost_as_slot = flow_cost.determine_recipe_item_cost(modified_raw_resource_table, constants.cost_params.time, constants.cost_params.complexity)
    local item_recipe_maps = flow_cost.construct_item_recipe_maps()

    -- Pre-processing: Grab valid item nodes
    local initial_sort_info = top_sort.sort(dep_graph)

    -- Find shortest path; first we need to sort prereqs
    local node_to_ind_in_sorted = {}
    -- Create a node for enforcing all technologies reachable
    local all_technologies_node = {
        type = "recipe-surface",
        name = "all-technologies-node",
        prereqs = {},
        dependents = {}
    }
    for ind, node in pairs(initial_sort_info.sorted) do
        node_to_ind_in_sorted[build_graph.key(node.type, node.name)] = ind
        if node.type == "technology" then
            graph_utils.add_prereq(node, all_technologies_node)
        end
    end
    for _, node in pairs(initial_sort_info.sorted) do
        table.sort(node.prereqs, function(prereq1, prereq2)
            return (node_to_ind_in_sorted[build_graph.key(prereq1.type, prereq1.name)] or 0) < (node_to_ind_in_sorted[build_graph.key(prereq2.type, prereq2.name)] or 0)
        end)
    end
    local short_path = {}
    -- Calculate specially for space age
    if mods["space-age"] then
        -- CRITICAL TODO: Fix the shortest path algorithm so I don't have to do this!
        short_path = {
            ["item:boiler"] = true,
            ["item:steam-engine"] = true,
            ["item:stone-furnace"] = true,
            ["item:offshore-pump"] = true,
            ["item:small-electric-pole"] = true,
            ["item:lab"] = true,
            ["item:inserter"] = true,
            ["item:transport-belt"] = true,
            ["item:gun-turret"] = true,
            ["item:submachine-gun"] = true,
            ["item:firearm-magazine"] = true,
            ["item:underground-belt"] = true,
            ["item:splitter"] = true,
            ["item:assembling-machine-1"] = true,
            ["item:burner-mining-drill"] = true,
            ["item:electric-mining-drill"] = true,
            ["item:wooden-chest"] = true,
            ["item:pipe"] = true,
            ["item:rocket-silo"] = true,
            ["item:cargo-landing-pad"] = true,
            ["item:thruster"] = true,
            ["item:space-platform-foundation"] = true,
            ["item:space-platform-starter-pack"] = true,
            ["item:crusher"] = true,
            ["item:oil-refinery"] = true,
            ["item:chemical-plant"] = true,
            ["item:assembling-machine-2"] = true,
            ["item:asteroid-collector"] = true,
            ["item:solar-panel"] = true,
            ["item:cargo-bay"] = true,
        }
    else
        short_path = path.find_path(dep_graph, all_technologies_node)
    end
    log(serpent.block(short_path))

    --------------------------------------------------------------------------
    -- Phase 2: FILTER - Select items to randomize
    --------------------------------------------------------------------------
    -- Criteria: Nauvis-reachable, stackable, not science pack, not in blacklist
    local to_be_randomized = {}
    for _, node in pairs(initial_sort_info.sorted) do
        if node.type == "item" then
            local nauvis_reachable = initial_sort_info.reachable[build_graph.key("item-surface", build_graph.compound_key({node.name, build_graph.compound_key({"planet", "nauvis"})}))]
            if nauvis_reachable then
                local item_prototype = items[node.item]
                local cost = cost_as_traveler.material_to_cost[flow_cost.get_prot_id(item_prototype)]
                -- Filter: stackable, no equipment grid, not science pack (tool), not blacklisted
                if is_stackable(item_prototype) and item_prototype.equipment_grid == nil and item_prototype.type ~= "tool" and not dont_randomize_item[item_prototype.name] then
                    -- Always randomize raw resources; others based on setting percentage
                    if raw_resource_items[item_prototype.name] or rng.value(rng.key({id = id})) <= settings.startup["propertyrandomizer-item-percent"].value / 100 then
                        to_be_randomized[build_graph.key(node.type, node.name)] = true
                    end
                end
            end
        end
    end

    --------------------------------------------------------------------------
    -- Phase 3: SUBDIVIDE - Separate slots from travelers
    --------------------------------------------------------------------------
    -- Node types whose abilities stay with the traveler (not the slot)
    local stays_with_traveler = {
        ["build-entity-item"] = true,
        ["build-entity-item-surface"] = true,
        ["build-tile-item-surface"] = true,
        -- This is an AND node so it needs fixing!
        --["build-tile-item-surface-with-item"] = true,
        ["plant-entity-item-surface"] = true,
        -- Note: fuel-category-surface is used primarily; fuel-category is probably redundant
        ["fuel-category"] = true,
        ["fuel-category-surface"] = true,
        ["burn-item"] = true,
        ["burn-item-surface"] = true,
        -- For space platform starter pack
        ["send-item-to-orbit-planet"] = true,
        -- Special compat nodes
        ["starter-gun"] = true,
        ["starter-gun-ammo"] = true,
        ["repair-pack"] = true,
        ["rocket-turret"] = true,
        ["rocket-ammo"] = true,
    }
    for node_name, _ in pairs(to_be_randomized) do
        local item_node = dep_graph[node_name]
        -- First move all traveler dependents to the item from any item-surface
        for surface_name, surface in pairs(build_graph.surfaces) do
            local item_surface_node = dep_graph[build_graph.key("item-surface", build_graph.compound_key({item_node.name, surface_name}))]
            local dependents_to_remove = {}
            for _, dependent in pairs(item_surface_node.dependents) do
                if stays_with_traveler[dependent.type] then
                    table.insert(dependents_to_remove, dependent)
                end
            end
            for _, dependent in pairs(dependents_to_remove) do
                local dependent_node = dep_graph[build_graph.key(dependent.type, dependent.name)]
                graph_utils.add_prereq(item_node, dependent_node)
                graph_utils.remove_prereq(item_surface_node, dependent_node)
            end
        end

        -- Now, separate item slots away from item travelers
        local item_slot_node = {
            type = "item-slot",
            name = item_node.name,
            prereqs = {},
            dependents = {}
        }
        dep_graph[build_graph.key("item-slot", item_node.name)] = item_slot_node
        local prereqs_to_remove = {}
        for _, prereq in pairs(item_node.prereqs) do
            table.insert(prereqs_to_remove, prereq)
        end
        for _, prereq in pairs(prereqs_to_remove) do
            local prereq_node = dep_graph[build_graph.key(prereq.type, prereq.name)]
            graph_utils.add_prereq(prereq_node, item_slot_node)
            graph_utils.remove_prereq(prereq_node, item_node)
        end
        -- Add this temporarily for graph sorting; it will be taken away later
        graph_utils.add_prereq(item_slot_node, item_node)
    end
    -- We'll make sure chemical fuel is always available as a hotfix at the end, so make sure it's satisfied as a node
    -- build-entity-surface-condition-true is just an easy always-on node to choose
    graph_utils.add_prereq(dep_graph[build_graph.key("build-entity-surface-condition-true", "canonical")], dep_graph[build_graph.key("fuel-category-surface", build_graph.compound_key({"chemical", build_graph.compound_key({"planet", "nauvis"})}))])

    --------------------------------------------------------------------------
    -- Phase 4: BLACKLIST - Block ability propagation until assigned
    --------------------------------------------------------------------------
    -- Re-sort with subdivided nodes, then blacklist edges into item-surface nodes
    local prereq_sort_info = top_sort.sort(dep_graph)

    local slots = {}
    local travelers = {}
    local blacklist = {}
    for _, item_node in pairs(prereq_sort_info.sorted) do
        local node_name = build_graph.key(item_node.type, item_node.name)
        if to_be_randomized[node_name] then
            table.insert(slots, dep_graph[build_graph.key(item_node.prereqs[1].type, item_node.prereqs[1].name)])
            table.insert(travelers, item_node)
            -- Block edges INTO item-surface nodes (prevents abilities from propagating)
            for surface_name, surface in pairs(build_graph.surfaces) do
                local item_surface_node = dep_graph[build_graph.key("item-surface", build_graph.compound_key({item_node.name, surface_name}))]
                for _, prereq in pairs(item_surface_node.prereqs) do
                    blacklist[build_graph.conn_key({prereq, item_surface_node})] = true
                end
            end
            -- Remove temp edge: item is now orphaned (OR with no prereqs = unreachable)
            local item_slot_node = dep_graph[build_graph.key("item-slot", item_node.name)]
            graph_utils.remove_prereq(item_slot_node, item_node)
        end
    end

    --------------------------------------------------------------------------
    -- Phase 5: SHUFFLE - Randomize traveler order
    --------------------------------------------------------------------------
    rng.shuffle(rng.key({id = id}), travelers)

    --------------------------------------------------------------------------
    -- Phase 6: ASSIGN - Match slots to travelers
    --------------------------------------------------------------------------
    local slot_to_traveler = {}
    local traveler_to_slot = {}
    -- Terminal slot assignments can be cancelled if we get stuck
    -- (Terminal = plain item with no important abilities like building/fuel)
    local cancellable_assignments = {}
    local is_cancellable = {}
    local curr_sort_state = top_sort.sort(dep_graph, blacklist)

    -- Event logging
    local event_num = 0
    local function log_event(event_type, slot_name, traveler_name, extra)
        event_num = event_num + 1
        local msg = string.format("[EVENT %3d] %-8s %s -> %s", event_num, event_type, slot_name, traveler_name)
        if extra then
            msg = msg .. " " .. extra
        end
        log(msg)
    end

    -- Check if a slot is reachable (any prereq is reachable)
    local function is_slot_reachable(slot)
        slot_node = slot
        if slot.prereqs == nil then
            local slot_node = dep_graph[build_graph.key(slot.type, slot.name)]
        end
        for _, prereq in pairs(slot_node.prereqs) do
            if curr_sort_state.reachable[build_graph.key(prereq.type, prereq.name)] then
                return true
            end
        end
        return false
    end

    -- Check if a traveler is reachable (directly or via its original slot)
    -- This is a heuristic to guide good assignment choices
    local function is_traveler_reachable(traveler_node)
        return curr_sort_state.reachable[build_graph.key(traveler_node.type, traveler_node.name)] or is_slot_reachable(dep_graph[build_graph.key("item-slot", traveler_node.name)])
    end

    -- Terminal slots have no important abilities (no building, fuel, equipment, etc.)
    -- They can accept any traveler without reachability check (reservation behavior)
    local function is_terminal_slot(node)
        local item_prototype = items[node.name]
        return not (item_prototype.type ~= "item" or item_prototype.place_result ~= nil or item_prototype.place_as_equipment_result ~= nil or (item_prototype.fuel_category ~= nil and item_prototype.fuel_category ~= "chemical") or item_prototype.plant_result ~= nil or item_prototype.place_as_tile ~= nil)
    end

    local force_assignment_mode = false
    for i = 1, #slots do
        local old_slot
        local new_item

        for j = 1, constants.item_randomization_max_fallbacks do
            for _, curr_slot in pairs(slots) do
                if slot_to_traveler[curr_slot.name] == nil and is_slot_reachable(curr_slot) then
                    for _, proposed_item in pairs(travelers) do
                        -- If we're almost done just say whatever and accept this proposal
                        if force_assignment_mode then
                            old_slot = curr_slot
                            new_item = proposed_item
                            break
                        end
                        
                        -- Don't make sure it's reachable if it's a boring slot
                        if traveler_to_slot[proposed_item.name] == nil and (is_terminal_slot(curr_slot) or is_traveler_reachable(proposed_item)) then
                            local proposed_item_prot = items[proposed_item.name]
                            local slot_item = items[curr_slot.name]

                            -- Check that costs align
                            local worry_about_costs = false
                            if traveler_cost ~= nil and (slot_item.place_result ~= nil or slot_item.type ~= "item" or slot_item.fuel_value ~= nil or slot_item.place_as_tile ~= nil or slot_item.plant_result ~= nil) then
                                worry_about_costs = true
                            end
                            if not worry_about_costs or (slot_cost ~= nil and slot_cost <= constants.item_randomization_cost_factor_threshold * traveler_cost) then
                                -- Check now that stack sizes match up
                                if proposed_item_prot.stack_size >= slot_item.stack_size / 10 then
                                    if is_terminal_slot(curr_slot) and not is_cancellable[curr_slot.name] then
                                        table.insert(cancellable_assignments, curr_slot)
                                        is_cancellable[curr_slot.name] = true
                                    end
                                    old_slot = curr_slot
                                    new_item = proposed_item
                                    break
                                end
                            end
                        end
                    end

                    if new_item ~= nil then
                        break
                    else
                        log("No valid traveling items")
                        log(curr_slot.name)
                    end
                elseif not is_slot_reachable(curr_slot) then
                    log("Unreachable slot")
                    log(curr_slot.name)
                end
            end

            if new_item == nil then
                -- Try to find a traveler to switch earlier
                -- NOTE/CRITICAL TODO: This is broken because the switches can violate reachability of later nodes!
                local succeeded_in_traveler_switch = false
                for should_check_on_short_path = 1, 2 do
                    for _, failed_traveler in pairs(travelers) do
                        local on_short_path = false
                        if short_path[build_graph.key("item", failed_traveler.name)] then
                            on_short_path = true
                        else
                            for surface_name, surface in pairs(build_graph.surfaces) do
                                if short_path[build_graph.key("item-surface", build_graph.compound_key({failed_traveler.name, surface_name}))] then
                                    on_short_path = true
                                end
                            end
                        end
                        if traveler_to_slot[failed_traveler.name] == nil and is_traveler_reachable(failed_traveler) and not is_terminal_slot(failed_traveler) and (on_short_path or should_check_on_short_path == 2) then
                            -- Fallback to switching this item back earlier to its vanilla spot
                            --local vanilla_slot = dep_graph[build_graph.key("item-slot", failed_traveler.name)]
                            -- We know its vanilla slot was already taken since that should always be available by now (and the fact we failed means it's probably getting used by something else)
                            -- Otherwise, if no items satisfy this, it's hopeless
                            -- Note: this can cause softlocks if we're not careful, so remove it for now
                            local booted_out_slot --= slot_to_traveler[vanilla_slot.name]
                            -- Our last resort is to boot something exciting out
                            -- Note: actually trying this as the *first* resort now
                            log(#cancellable_assignments)
                            if #cancellable_assignments >= 1 then
                                local ind_to_boot = #cancellable_assignments--rng.int(rng.key({id = id}), #cancellable_assignments)
                                booted_out_slot = cancellable_assignments[ind_to_boot]
                                table.remove(cancellable_assignments, ind_to_boot)
                                is_cancellable[booted_out_slot.name] = nil
                            end

                            -- The variable names to come are a mess; I'm sorry
                            if booted_out_slot ~= nil then
                                local booted_traveler = slot_to_traveler[booted_out_slot.name]
                                log_event("CANCEL", booted_out_slot.name, booted_traveler.name, "(for " .. failed_traveler.name .. ")")
                                log("Booting out " .. booted_out_slot.name .. " slot for " .. failed_traveler.name)

                                -- Switch out slot/item tables
                                local item_being_booted_out = slot_to_traveler[booted_out_slot.name]
                                local corresponding_slot = dep_graph[build_graph.key("item-slot", item_being_booted_out.name)]
                                slot_to_traveler[booted_out_slot.name] = failed_traveler
                                traveler_to_slot[failed_traveler.name] = booted_out_slot
                                traveler_to_slot[item_being_booted_out.name] = nil

                                -- Repair the graph
                                -- No blacklist changes needed since those are all on the item-surface/item-slot level (though we'll need to re-sort from the beginning)
                                graph_utils.remove_prereq(corresponding_slot, item_being_booted_out)
                                graph_utils.add_prereq(booted_out_slot, failed_traveler)

                                local old_num_reachable = #curr_sort_state.sorted

                                -- Redo the sort state entirely instead of trying to backtrack
                                -- This is slow, but we're in a desperate state by now anyways
                                curr_sort_state = top_sort.sort(dep_graph, blacklist)

                                -- As a heuristic, reject if we didn't get at least as many reachable things
                                if #curr_sort_state.sorted < old_num_reachable then
                                    -- Note: With the current changes, we should actually never enter this
                                    error("Actually reduced reachable by " .. tostring(old_num_reachable - #curr_sort_state.sorted))
                                    -- Undo our changes
                                    slot_to_traveler[vanilla_slot.name] = booted_out_item
                                    traveler_to_slot[failed_traveler.name] = nil
                                    traveler_to_slot[booted_out_item.name] = vanilla_slot
                                    graph_utils.remove_prereq(vanilla_slot, failed_traveler)
                                    graph_utils.add_prereq(vanilla_slot, booted_out_item)
                                    curr_sort_state = top_sort.sort(dep_graph, blacklist)

                                    is_cancellable[booted_out_item.name] = true
                                    table.insert(cancellable_assignments, booted_out_item)
                                else
                                    succeeded_in_traveler_switch = true
                                    break
                                end
                            end
                        end
                    end
                    if succeeded_in_traveler_switch then
                        break
                    end
                end
                if not succeeded_in_traveler_switch then
                    break
                end
            end
            -- CRITICAL TODO: Should we be breaking out of this loop if new_item ~= nil???
        end
        -- If still no new items were found, report error
        if new_item == nil then
            log(serpent.block(curr_sort_state.reachable))
            log("Unused traveling items:")
            for _, traveling_item in pairs(travelers) do
                if traveler_to_slot[traveling_item.name] == nil then
                    log(traveling_item.name)
                    log(is_traveler_reachable(traveling_item))
                end
            end
            -- If we're more than 90% of the way there, disable reachability conditions instead
            if not force_assignment_mode and (#slots - i) <= 0.1 * #slots then
                log("Disabling reachability checks... " .. tostring(math.floor(100 * i / #slots)) .. "% of the way done!")
                force_assignment_mode = true
            else
                error("Item randomization failed at " .. tostring(math.floor(100 * i / #slots)) .. "%. Perhaps try a different seed?")
            end
        else
            -- Log the assignment event
            local is_terminal = is_terminal_slot(old_slot)
            if is_terminal then
                log_event("RESERVE", old_slot.name, new_item.name)
            else
                log_event("ASSIGN", old_slot.name, new_item.name)
            end

            slot_to_traveler[old_slot.name] = new_item
            traveler_to_slot[new_item.name] = old_slot

            local old_slot_node = dep_graph[build_graph.key(old_slot.type, old_slot.name)]
            -- Connect the traveler to the slot and unblacklist the slot
            -- Connect "boring-turned-exciting" connections to their original spot so that they don't have an effect on reachability until later
            if is_cancellable[old_slot.name] then
                local new_item_corresponding_slot = dep_graph[build_graph.key("item-slot", new_item.name)]
                graph_utils.add_prereq(new_item_corresponding_slot, new_item)
                -- Sort in case we already missed this
                if curr_sort_state.reachable[build_graph.key(new_item_corresponding_slot.type, new_item_corresponding_slot.name)] then
                    curr_sort_state = top_sort.sort(dep_graph, blacklist, curr_sort_state, {new_item_corresponding_slot, new_item})
                end
            else
                graph_utils.add_prereq(old_slot_node, new_item)
                curr_sort_state = top_sort.sort(dep_graph, blacklist, curr_sort_state, {old_slot_node, new_item})
            end
            for surface_name, surface in pairs(build_graph.surfaces) do
                local item_surface_node = dep_graph[build_graph.key("item-surface", build_graph.compound_key({old_slot.name, surface_name}))]
                for _, prereq in pairs(item_surface_node.prereqs) do
                    blacklist[build_graph.conn_key({prereq, item_surface_node})] = false
                    curr_sort_state = top_sort.sort(dep_graph, blacklist, curr_sort_state, {prereq, item_surface_node})
                end
            end

            -- See if any reservations have been fulfilled (traveler became reachable)
            local to_remove_from_exciting = {}
            for exciting_slot_name, _ in pairs(is_cancellable) do
                local exciting_traveler = slot_to_traveler[exciting_slot_name]
                if curr_sort_state.reachable[build_graph.key("item-slot", exciting_traveler.name)] then
                    log_event("FULFILL", exciting_slot_name, exciting_traveler.name)
                    table.insert(to_remove_from_exciting, exciting_slot_name)
                    local ind_to_remove
                    for ind, exciting_slot in pairs(cancellable_assignments) do
                        if exciting_slot.name == exciting_slot_name then
                            ind_to_remove = ind
                        end
                    end
                    table.remove(cancellable_assignments, ind_to_remove)
                end
            end
            for _, to_remove in pairs(to_remove_from_exciting) do
                is_cancellable[to_remove] = nil
            end
        end
    end

    --------------------------------------------------------------------------
    -- Phase 7: VERIFY - Check event consistency and reachability
    --------------------------------------------------------------------------
    local verify_errors = {}

    -- Count events by type
    local event_counts = {RESERVE = 0, ASSIGN = 0, FULFILL = 0, CANCEL = 0}
    local reserved_slots = {}  -- slot_name -> traveler_name
    local fulfilled_slots = {}
    local cancelled_slots = {}

    -- Parse event log to track lifecycle
    -- (We don't have a stored event log, so we'll verify from state)

    -- 1. Check assignment counts
    local assign_count = 0
    local reserve_count = 0
    for slot_name, traveler in pairs(slot_to_traveler) do
        assign_count = assign_count + 1
        if is_cancellable[slot_name] then
            reserve_count = reserve_count + 1
        end
    end
    log(string.format("[VERIFY] Total assignments: %d (reserves: %d, immediate: %d)",
        assign_count, reserve_count, assign_count - reserve_count))

    -- 2. Check all assigned travelers are reachable
    local final_sort = top_sort.sort(dep_graph, blacklist)
    local unreachable_travelers = {}
    for slot_name, traveler in pairs(slot_to_traveler) do
        local traveler_key = build_graph.key(traveler.type, traveler.name)
        if not final_sort.reachable[traveler_key] then
            table.insert(unreachable_travelers, traveler.name)
        end
    end
    if #unreachable_travelers > 0 then
        table.insert(verify_errors, string.format("Unreachable travelers after assignment: %s",
            table.concat(unreachable_travelers, ", ")))
    else
        log("[VERIFY] All assigned travelers are reachable")
    end

    -- 3. Check all assigned slots are reachable
    local unreachable_slots = {}
    for slot_name, _ in pairs(slot_to_traveler) do
        local slot_key = build_graph.key("item-slot", slot_name)
        if not final_sort.reachable[slot_key] then
            table.insert(unreachable_slots, slot_name)
        end
    end
    if #unreachable_slots > 0 then
        table.insert(verify_errors, string.format("Unreachable slots after assignment: %s",
            table.concat(unreachable_slots, ", ")))
    else
        log("[VERIFY] All assigned slots are reachable")
    end

    -- 4. Check monotonicity (final reachable >= initial)
    local final_reachable = #final_sort.sorted
    local initial_reachable = #initial_sort_info.sorted
    if final_reachable < initial_reachable then
        table.insert(verify_errors, string.format("Monotonicity violated: %d -> %d (lost %d nodes)",
            initial_reachable, final_reachable, initial_reachable - final_reachable))
    else
        log(string.format("[VERIFY] Monotonicity OK: %d -> %d (gained %d)",
            initial_reachable, final_reachable, final_reachable - initial_reachable))
    end

    -- 5. Check no duplicate assignments
    local seen_travelers = {}
    for slot_name, traveler in pairs(slot_to_traveler) do
        if seen_travelers[traveler.name] then
            table.insert(verify_errors, string.format("Duplicate traveler: %s assigned to both %s and %s",
                traveler.name, seen_travelers[traveler.name], slot_name))
        end
        seen_travelers[traveler.name] = slot_name
    end
    if not next(verify_errors) or #verify_errors == 0 then
        log("[VERIFY] No duplicate traveler assignments")
    end

    -- 6. Check bijection: slot_to_traveler and traveler_to_slot are inverses
    for slot_name, traveler in pairs(slot_to_traveler) do
        local reverse_slot = traveler_to_slot[traveler.name]
        if reverse_slot == nil then
            table.insert(verify_errors, string.format("Missing reverse mapping for traveler %s", traveler.name))
        elseif reverse_slot.name ~= slot_name then
            table.insert(verify_errors, string.format("Bijection mismatch: slot %s -> traveler %s, but traveler -> slot %s",
                slot_name, traveler.name, reverse_slot.name))
        end
    end
    if not next(verify_errors) or #verify_errors == 0 then
        log("[VERIFY] Bijection OK: slot_to_traveler and traveler_to_slot are consistent")
    end

    -- Report errors (as warnings, don't fail - we want to see all seeds)
    if #verify_errors > 0 then
        log("[VERIFY] === WARNINGS (" .. #verify_errors .. ") ===")
        for _, err in ipairs(verify_errors) do
            log("[VERIFY WARNING] " .. err)
        end
        -- Don't error - continue to see results from all seeds
        -- error("Verification failed with " .. #verify_errors .. " errors")
    else
        log("[VERIFY] === ALL CHECKS PASSED ===")
    end

    --------------------------------------------------------------------------
    -- Phase 8: UPDATE - Apply randomization to data.raw
    --------------------------------------------------------------------------

    local new_order = {}
    local visited_old_order = {}
    local old_order = slots
    for _, thing in pairs(old_order) do
        table.insert(new_order, slot_to_traveler[thing.name])
        table.insert(visited_old_order, thing)
    end

    -- Fix data.raw
    local changes = {}
    local post_changes = {}
    local post_changes_spoil = {}
    local num_times_changed_graphics_of_simple_entity = {}
    for ind, item_node in pairs(new_order) do
        -- item_node takes the place of same-indexed node in old_order
        local old_node = visited_old_order[ind]
        local old_item = items[old_node.name]

        local item_prototype = items[item_node.name]
        local incoming_cost = cost_as_traveler.material_to_cost[flow_cost.get_prot_id(item_prototype)]
        local outgoing_cost = cost_as_slot.material_to_cost[flow_cost.get_prot_id(old_item)]
        local amount_multiplier = 1
        local is_significant = false
        if item_prototype.place_result ~= nil or item_prototype.type ~= "item" or item_prototype.fuel_value ~= nil or item_prototype.place_as_tile ~= nil or item_prototype.plant_result ~= nil then
            is_significant = true
        end
        if is_significant and incoming_cost ~= nil and outgoing_cost ~= nil and outgoing_cost / incoming_cost >= 2 and item_prototype.name ~= old_item.name then
            amount_multiplier = math.floor(outgoing_cost / incoming_cost)
        end

        for _, recipe in pairs(data.raw.recipe) do
            for _, material_property in pairs({"ingredients", "results"}) do
                if recipe[material_property] ~= nil then
                    for _, ing_or_prod in pairs(recipe[material_property]) do
                        if ing_or_prod.type == "item" and ing_or_prod.name == old_node.name then
                            table.insert(changes, {
                                tbl = ing_or_prod,
                                prop = "name",
                                new_val = item_node.name
                            })

                            -- Multiply amounts in products if this is significantly more expensive
                            if material_property == "results" and recipe.category ~= "recycling" then
                                for _, key in pairs({"amount", "amount_min", "amount_max"}) do
                                    if ing_or_prod[key] ~= nil then
                                        ing_or_prod[key] = math.max(1, math.min(65535, ing_or_prod[key] * amount_multiplier))
                                    end
                                end
                            end
                        end
                    end
                end
            end

            local fix_localised = false
            if recipe.results ~= nil and #recipe.results >= 1 and --[[#recipe.results == 1 and]] recipe.results[1].name == old_node.name then
                -- Fix main product for localisations
                table.insert(changes, {
                    tbl = recipe,
                    prop = "main_product",
                    new_val = item_node.name
                })
                fix_localised = true
            end
            if recipe.main_product == old_node.name then
                table.insert(changes, {
                    tbl = recipe,
                    prop = "main_product",
                    new_val = item_node.name
                })
                fix_localised = true
            end
            if fix_localised then
                -- Find original recipe prototype from dupes if applicable
                local orig_recipe = recipe
                if orig_recipe.orig_name ~= nil then
                    orig_recipe = data.raw.recipe[orig_recipe.orig_name]
                end
                if orig_recipe.localised_name == nil then
                    recipe.localised_name = {"?", {"recipe-name." .. orig_recipe.name}, locale_utils.find_localised_name(item_prototype)}
                end
                -- If the original recipe had no icon, recreate the icon as the new item's
                if orig_recipe.icons == nil and orig_recipe.icon == nil then
                    local recipe_icons
                    if item_prototype.icons ~= nil then
                        recipe.icons = item_prototype.icons
                    else
                        recipe.icons = {
                            {
                                icon = item_prototype.icon,
                                icon_size = item_prototype.icon_size or 64
                            }
                        }
                    end
                end
            end
        end

        -- Replace loot results
        for _, entity in pairs(entities) do
            if entity.loot ~= nil then
                for ind_in_loot, loot_entry in pairs(entity.loot) do
                    if loot_entry.item == old_node.name then
                        loot_entry.count_min = math.max(1, math.min(65535, (loot_entry.count_min or 1) * amount_multiplier))
                        loot_entry.count_max = math.max(1, math.min(65535, (loot_entry.count_max or 1) * amount_multiplier))
                        table.insert(changes, {
                            tbl = entity.loot[ind_in_loot],
                            prop = "item",
                            new_val = item_node.name
                        })
                    end
                end
            end
        end

        -- Replace mine results
        local minable_things = table.deepcopy(defines.prototypes.entity)
        -- Need to account for asteroid chunks as well
        minable_things["asteroid-chunk"] = true
        for entity_class, _ in pairs(minable_things) do
            if data.raw[entity_class] ~= nil then
                for _, entity in pairs(data.raw[entity_class]) do
                    -- Don't replace entities that are player creations, so that you still get the buildings back you place down
                    local is_building = false
                    if entity.flags ~= nil then
                        for _, flag in pairs(entity.flags) do
                            if flag == "placeable-player" or flag == "player-creation" then
                                is_building = true
                            end
                        end
                    end

                    if not is_building then
                        local has_result = false

                        if entity.minable ~= nil then
                            if entity.minable.results ~= nil then
                                for _, result in pairs(entity.minable.results) do
                                    if result.name == old_node.name then
                                        table.insert(changes, {
                                            tbl = result,
                                            prop = "name",
                                            new_val = item_node.name
                                        })

                                        -- Multiply amounts if this is significantly more expensive
                                        for _, key in pairs({"amount", "amount_min", "amount_max"}) do
                                            if result[key] ~= nil then
                                                result[key] = math.max(1, math.min(65535, result[key] * amount_multiplier))
                                            end
                                        end

                                        has_result = true
                                    end
                                end
                            elseif entity.minable.result == old_node.name then
                                table.insert(changes, {
                                    tbl = entity.minable,
                                    prop = "result",
                                    new_val = item_node.name
                                })

                                entity.minable.count = math.max(1, math.min(65535, (entity.minable.count or 1) * amount_multiplier))

                                has_result = true
                            end
                        end

                        if has_result then
                            if entity.type == "resource" and (entity.minable.results == nil or #entity.minable.results == 1) then
                                entity.localised_name = locale_utils.find_localised_name(item_prototype)
                                entity.stages = {
                                    -- Note: This is technically botched with icons, TODO: Fix
                                    sheets = {
                                        {
                                            variation_count = 1,
                                            filename = item_prototype.icon or item_prototype.icons[1].icon,
                                            size = item_prototype.icon_size or 64,
                                            scale = 0.35,
                                            shift = {0.2, 0.6}
                                        },
                                        {
                                            variation_count = 1,
                                            filename = item_prototype.icon or item_prototype.icons[1].icon,
                                            size = item_prototype.icon_size or 64,
                                            scale = 0.25,
                                            shift = {-0.5, 0.2}
                                        },
                                        {
                                            variation_count = 1,
                                            filename = item_prototype.icon or item_prototype.icons[1].icon,
                                            size = item_prototype.icon_size or 64,
                                            scale = 0.45,
                                            shift = {0, 0}
                                        },
                                        {
                                            variation_count = 1,
                                            filename = item_prototype.icon or item_prototype.icons[1].icon,
                                            size = item_prototype.icon_size or 64,
                                            scale = 0.4,
                                            shift = {-0.2, -0.6}
                                        }
                                    }
                                }
                                entity.stage_counts = {entity.stage_counts[1]}
                                entity.stages_effect = nil
                            end

                            -- Make trees like fruit trees
                            if entity.type == "tree" then
                                -- Assume tree graphics are defined a certain way
                                -- TODO: Remove this assumption
                                if entity.variations ~= nil then
                                    for _, variation in pairs(entity.variations) do
                                        local new_frame_sequence = {}
                                        for i = 1, variation.leaves.frame_count or 1 do
                                            table.insert(new_frame_sequence, 1)
                                        end
                                        local old_leaves = table.deepcopy(variation.leaves)
                                        variation.leaves = {
                                            layers = {}
                                        }
                                        -- Relative to tree size
                                        local shifts = {
                                            {0.3, 0.6},
                                            {0.5, 0.55},
                                            {0.7, 0.65},
                                            {0.9, 0.5}
                                        }
                                        -- Add random variations to the shifts
                                        for i = 1, #shifts do
                                            shifts[i][1] = shifts[i][1] + 0.2 * (1 - 2 * rng.value(rng.key({id = id, prototype = entity})))
                                            shifts[i][2] = shifts[i][2] + 0.2 * (1 - 2 * rng.value(rng.key({id = id, prototype = entity})))
                                        end
                                        selection_box_x_size = entity.selection_box[2][1] - entity.selection_box[1][1]
                                        selection_box_y_size = entity.selection_box[2][2] - entity.selection_box[1][2] + (entity.drawing_box_vertical_extension or 0)
                                        local starting_x = (old_leaves.shift or {0,0})[1] - selection_box_x_size / 2
                                        local starting_y = (old_leaves.shift or {0,0})[2] - selection_box_y_size / 2
                                        for i = 1, #shifts do
                                            table.insert(variation.leaves.layers, {
                                                variation_count = 1,
                                                frame_sequence = new_frame_sequence,
                                                frame_count = variation.leaves.frame_count,
                                                filename = item_prototype.icon or item_prototype.icons[1].icon,
                                                size = item_prototype.icon_size or 64,
                                                scale = 0.3,
                                                shift = {entity.selection_box[1][1] + selection_box_x_size * shifts[i][1], entity.selection_box[1][2] - (entity.drawing_box_vertical_extension or 0) + selection_box_y_size * shifts[i][2]}
                                            })
                                        end
                                        table.insert(variation.leaves.layers, 1, old_leaves)
                                    end
                                end
                            end

                            -- Now for rocks and such
                            -- Assume graphics are a certain way
                            if entity.type == "simple-entity" and entity.pictures ~= nil then
                                num_times_changed_graphics_of_simple_entity[entity.name] = (num_times_changed_graphics_of_simple_entity[entity.name] or 0) + 1
                                if num_times_changed_graphics_of_simple_entity[entity.name] == 1 then
                                    entity.lower_pictures = {}
                                end
                                -- Medium-ish render layer
                                entity.lower_render_layer = "object"

                                local variations_tbl
                                if entity.pictures[1] ~= nil then
                                    variations_tbl = entity.pictures
                                elseif entity.pictures.sheet ~= nil then
                                    variations_tbl = {entity.pictures.sheet}
                                else
                                    variations_tbl = {entity.pictures}
                                end

                                for j = 1, #variations_tbl do
                                    if num_times_changed_graphics_of_simple_entity[entity.name] == 1 then
                                        entity.lower_pictures[j] = {layers = {}}
                                    end

                                    -- Relative to rock size
                                    local shifts = {
                                        {0.3, 0.6},
                                        {0.5, 0.55},
                                        {0.7, 0.65},
                                        {0.6, 0.3}
                                    }
                                    -- Add random variations to the shifts
                                    for i = 1, #shifts do
                                        shifts[i][1] = shifts[i][1] + 0.2 * (1 - 2 * rng.value(rng.key({id = id, prototype = entity})))
                                        shifts[i][2] = shifts[i][2] + 0.2 * (1 - 2 * rng.value(rng.key({id = id, prototype = entity})))
                                    end
                                    local selection_box_x_size = entity.selection_box[2][1] - entity.selection_box[1][1]
                                    local selection_box_y_size = entity.selection_box[2][2] - entity.selection_box[1][2]
                                    for i = 1, #shifts do
                                        table.insert(entity.lower_pictures[j].layers, {
                                            filename = item_prototype.icon or item_prototype.icons[1].icon,
                                            size = item_prototype.icon_size or 64,
                                            scale = 0.25,
                                            tint = {236, 152, 130},
                                            shift = {entity.selection_box[1][1] + selection_box_x_size * shifts[i][1], entity.selection_box[1][2] - (entity.drawing_box_vertical_extension or 0) + selection_box_y_size * shifts[i][2]}
                                        })
                                    end
                                end

                            end
                        end
                    end
                end
            end
        end

        -- See if any items spoil into the old one and modify accordingly
        -- Also look for burnt results
        for item_class, _ in pairs(defines.prototypes.item) do
            if data.raw[item_class] ~= nil then
                for _, item in pairs(data.raw[item_class]) do
                    if item.spoil_result == old_item.name then
                        table.insert(changes, {
                            tbl = item,
                            prop = "spoil_result",
                            new_val = item_prototype.name
                        })
                    end
                end
            end
        end
        -- Transfer old node's spoil stats
        -- This must be done after the spoil_results are updated
        table.insert(post_changes_spoil, {
            tbl = item_prototype,
            prop = "spoil_result",
            old_node_item = old_item
        })
        table.insert(post_changes, {
            tbl = item_prototype,
            prop = "spoil_ticks",
            new_val = old_item.spoil_ticks
        })
        -- CRITICAL TODO: Needs fixing for same reasons as post_changes_spoil
        table.insert(post_changes, {
            tbl = item_prototype,
            prop = "spoil_to_trigger_result",
            new_val = old_item.spoil_to_trigger_result
        })
        table.insert(post_changes, {
            tbl = item_prototype,
            prop = "spoil_level",
            new_val = old_item.spoil_level
        })

        -- Change trigger techs
        for _, technology in pairs(data.raw.technology) do
            if technology.research_trigger ~= nil then
                if technology.research_trigger.type == "craft-item" then
                    if technology.research_trigger.item == old_item.name then
                        table.insert(changes, {
                            tbl = technology.research_trigger,
                            prop = "item",
                            new_val = item_prototype.name
                        })
                    end
                    if type(technology.research_trigger.item) == "table" and technology.research_trigger.item.name == old_item.name then
                        table.insert(changes, {
                            tbl = technology.research_trigger.item,
                            prop = "name",
                            new_val = item_prototype.name
                        })
                    end
                end
            end
        end

        -- TODO: Make this check less ad-hoc
        -- If this is a coal replacement, give it a fuel value
        if old_item.name == "coal" then
            -- TODO: Need to do something special if this is the only non-chemical fuel for something...
            if item_prototype.fuel_category == nil then
                item_prototype.localised_description = {"", locale_utils.find_localised_description(item_prototype), "\n[color=green](Combustible)[/color]"}
            end

            if item_prototype.fuel_category ~= "chemical" then
                item_prototype.fuel_category = "chemical"
                item_prototype.fuel_value = "4MJ"
            elseif util.parse_energy(item_prototype.fuel_value) < 1000000 then
                item_prototype.fuel_value = "1MJ"
            end
            -- item_prototype.localised_name = {"", locale_utils.find_localised_name(item_prototype), "\n[color=red](Burnable)[/color]"}
        end
    end
    for _, change in pairs(changes) do
        change.tbl[change.prop] = change.new_val
    end
    for _, change in pairs(post_changes) do
        change.tbl[change.prop] = change.new_val
    end
    for _, change in pairs(post_changes_spoil) do
        change.tbl[change.prop] = change.old_node_item[change.prop]
    end

    -- return the maps between slots and items and vice versa to show we succeeded and keep track of old item positions
    return {slot_to_item = slot_to_traveler, traveler_to_slot = traveler_to_slot}
end