local dutils = require("new-lib/grpah/data-utils")
local gutils = require("new-lib/graph/graph-utils")
local balance = require("randomizations/graph/unified/new/handlers/balance-utils")
local rng = require("lib/random/rng")

local fuel_categories = {}

-- Track original fuel values for balancing
local trav_to_old_fuel_value = {}
local slot_to_spoof_fuel_value = {}

-- Preprocess: nothing needed for fuel-categories
fuel_categories.preprocess = function()
end

-- Claim edges from item to fuel-category
fuel_categories.claim = function(graph, prereq, dep, trav)
    if prereq.type == "item" and dep.type == "fuel-category" then
        -- Return 2 for real fuel categories to add extra slot copies
        -- This gives real fuel travelers more chances to find valid slots
        -- Spoof categories only get 1 copy since they can use any slot
        if string.match(dep.name, "^spoof%-") then
            return 1
        else
            return 2  -- Real fuel category - add extra slot copy
        end
    end
end

-- Validate with fuel value balancing
fuel_categories.validate = function(graph, slot, trav, extra)
    local slot_owner = gutils.get_conn_owner(graph, slot)
    if slot_owner.type ~= "item" then
        return false
    end

    -- Check if traveler is for spoof category
    local trav_owner = gutils.get_conn_owner(graph, trav)
    if trav_owner and string.match(trav_owner.name, "^spoof%-") then
        -- Spoof category travelers can use ANY fuel-capable slot
        -- This includes real fuels and spoofed items
        -- Assignments are filtered out in reflect anyway
        local slot_owner_key = gutils.key(slot_owner)
        local is_spoofed_slot = slot_to_spoof_fuel_value[slot_owner_key] ~= nil
        local new_item = dutils.get_prot("item", slot_owner.name)
        if is_spoofed_slot or (new_item and new_item.fuel_value) then
            return true
        end
        return false
    end

    local new_item = dutils.get_prot("item", slot_owner.name)
    if not new_item then
        return false
    end

    -- Get new fuel value (could be real or spoofed)
    local new_fuel_value
    local slot_owner_key = gutils.key(slot_owner)
    local is_spoofed_slot = slot_to_spoof_fuel_value[slot_owner_key] ~= nil

    if is_spoofed_slot then
        new_fuel_value = slot_to_spoof_fuel_value[slot_owner_key]
        -- Check if spoofed item can be fuel
        if not balance.can_be_fuel(slot_owner.name) then
            return false
        end
    elseif new_item.fuel_value then
        new_fuel_value = util.parse_energy(new_item.fuel_value)
        -- Existing fuels are always valid as slots
    else
        return false  -- No fuel value at all
    end

    -- Get old fuel value from the original slot for this traveler
    local old_fuel_value = 4000000  -- Default (coal = 4MJ)
    if extra.trav_to_old_slot then
        local trav_key = gutils.key(trav)
        local old_slot = extra.trav_to_old_slot[trav_key]
        if old_slot then
            local old_slot_owner = gutils.get_conn_owner(graph, old_slot)
            if old_slot_owner and old_slot_owner.type == "item" then
                local old_item = dutils.get_prot("item", old_slot_owner.name)
                if old_item and old_item.fuel_value then
                    old_fuel_value = util.parse_energy(old_item.fuel_value)
                end
            end
        end
    end

    -- Calculate ratio
    local ratio = old_fuel_value / new_fuel_value
    local stack_size = new_item.stack_size or 100

    -- Cap ratio at stack_size - that's the max multiplier we can apply
    local capped_ratio = math.min(ratio, stack_size)

    if capped_ratio > 1 then
        local scale_info = balance.can_scale_item_output(slot_owner.name, extra.init_sort)

        if scale_info.first_scalable then
            -- Check stack_size limit using capped ratio
            local multiplier = math.ceil(capped_ratio * 2)  -- 2x to reach at least half original

            if multiplier > stack_size then
                return false  -- Would exceed stack size
            end
            -- Accept - will scale in reflect
        else
            -- Not scalable - only accept if ratio <= 4
            if ratio > 4 then
                return false
            end
        end
    end

    return true
end

-- Spoof: add fake fuel category with non-fuel items
fuel_categories.spoof = function(graph)
    -- Count existing fuels per category
    local fcat_to_fuel_count = {}
    local existing_fuel_count = 0
    for node_key, node in pairs(graph.nodes) do
        if node.type == "item" then
            local item = dutils.get_prot("item", node.name)
            if item and item.fuel_category and item.fuel_value then
                existing_fuel_count = existing_fuel_count + 1
                fcat_to_fuel_count[item.fuel_category] = (fcat_to_fuel_count[item.fuel_category] or 0) + 1
            end
        end
    end

    -- Store old fuel values for balancing (from edges that will be claimed)
    for edge_key, edge in pairs(graph.edges) do
        local start_node = graph.nodes[edge.start]
        local end_node = graph.nodes[edge.finish]
        if start_node and end_node and start_node.type == "item" and end_node.type == "fuel-category" then
            local item = dutils.get_prot("item", start_node.name)
            if item and item.fuel_value then
                local trav_key = gutils.key(end_node)
                trav_to_old_fuel_value[trav_key] = util.parse_energy(item.fuel_value)
            end
        end
    end

    -- Create spoof fuel category (no burnt result)
    local spoof_fcat_key = gutils.key({type = "fuel-category", name = "spoof-chemical__0"})
    if not graph.nodes[spoof_fcat_key] then
        gutils.add_node(graph, "fuel-category", "spoof-chemical__0", {op = "OR"})
    end

    -- Wacky fuel values - range that keeps ratios manageable
    local fuel_value_options = {
        250000,      -- 250kJ (spoilage level - lowest practical)
        500000,      -- 500kJ
        1000000,     -- 1MJ
        2000000,     -- 2MJ
        4000000,     -- 4MJ (coal)
        8000000,     -- 8MJ
        12000000,    -- 12MJ (solid fuel)
        25000000,    -- 25MJ
        50000000,    -- 50MJ
        100000000,   -- 100MJ (rocket fuel)
        250000000,   -- 250MJ
        500000000,   -- 500MJ (high-end practical)
    }

    -- Get candidates: non-fuel, stackable, not blacklisted
    local candidates = {}
    for node_key, node in pairs(graph.nodes) do
        if node.type == "item" then
            local item = dutils.get_prot("item", node.name)
            if item and not item.fuel_category and balance.can_be_fuel(node.name) then
                table.insert(candidates, node.name)
            end
        end
    end
    rng.shuffle(rng.key({id = "fuel-spoof"}), candidates)

    local candidate_index = 1
    local function get_next_candidate()
        if candidate_index <= #candidates then
            local name = candidates[candidate_index]
            candidate_index = candidate_index + 1
            return name
        end
        return nil
    end

    -- First, add a spoofed item to each single-fuel category (fusion, nuclear, etc.)
    -- This ensures they have more options while keeping the original fuel as primary
    local single_fuel_spoofs = 0
    for fcat_name, count in pairs(fcat_to_fuel_count) do
        if count == 1 then
            local item_name = get_next_candidate()
            if item_name then
                local item_key = gutils.key({type = "item", name = item_name})
                -- Find the fuel-category node (format is "category__0" or "category__1")
                local fcat_key = gutils.key({type = "fuel-category", name = fcat_name .. "__0"})
                if not graph.nodes[fcat_key] then
                    fcat_key = gutils.key({type = "fuel-category", name = fcat_name .. "__1"})
                end
                if graph.nodes[fcat_key] then
                    -- Pick a random fuel value
                    local value_index = rng.range(rng.key({id = "fuel-value-single", name = item_name}), 1, #fuel_value_options)
                    local spoof_fuel_value = fuel_value_options[value_index]

                    local edge = gutils.add_edge(graph, item_key, fcat_key)
                    if edge then
                        slot_to_spoof_fuel_value[item_key] = spoof_fuel_value
                        single_fuel_spoofs = single_fuel_spoofs + 1
                        log("Added spoofed fuel " .. item_name .. " to single-fuel category " .. fcat_name)
                    end
                end
            end
        end
    end

    -- Now add remaining candidates to spoof-chemical for the main pool
    local num_to_add = math.min(existing_fuel_count, #candidates - candidate_index + 1)
    local spoofed_items = {}
    for i = 1, num_to_add do
        local item_name = get_next_candidate()
        if not item_name then break end

        local item_key = gutils.key({type = "item", name = item_name})

        -- Pick a random fuel value from the wacky options
        local value_index = rng.range(rng.key({id = "fuel-value", name = item_name}), 1, #fuel_value_options)
        local spoof_fuel_value = fuel_value_options[value_index]

        -- Add edge: item -> spoof-fuel-category
        local edge = gutils.add_edge(graph, item_key, spoof_fcat_key)
        if edge then
            slot_to_spoof_fuel_value[item_key] = spoof_fuel_value
            table.insert(spoofed_items, item_name)
        end
    end

    log("Spoofed " .. #spoofed_items .. " items to spoof-chemical, " .. single_fuel_spoofs .. " to single-fuel categories")
end

-- Apply fuel category changes to data.raw with balancing
fuel_categories.reflect = function(graph, trav_to_new_slot, trav_to_old_slot)
    -- Apply new fuel assignments
    for trav_key, slot in pairs(trav_to_new_slot) do
        local trav = graph.nodes[trav_key]
        local trav_owner = gutils.get_conn_owner(graph, trav)
        local slot_owner = gutils.get_conn_owner(graph, slot)

        -- Only process our edge type, skip spoof category
        if trav_owner.type == "fuel-category" and slot_owner.type == "item" then
            if string.match(trav_owner.name, "^spoof%-") then
                -- Remove fuel properties for things that no longer have them
                local item = dutils.get_prot("item", slot_owner.name)
                local fuel_properties = {
                    ["fuel_category"] = true,
                    ["burnt_result"] = true,
                    ["fuel_value"] = true,
                    ["fuel_acceleration_multiplier"] = true,
                    ["fuel_top_speed_multiplier"] = true,
                    ["fuel_emissions_multiplier"] = true,
                    ["fuel_acceleration_multiplier_quality_bonus"] = true,
                    ["fuel_top_speed_multiplier_quality_bonus"] = true,
                }
                for prop, _ in pairs(fuel_properties) do
                    item[prop] = nil
                end
            else
                -- fuel-category name is like "chemical__0" - extract base category
                -- TODO: Fix and find spoof category name properly
                local fcat_spoofed = trav_owner.name
                local fcat_name = string.match(fcat_spoofed, "(.+)__[01]$")

                local item = dutils.get_prot("item", slot_owner.name)
                if item and fcat_name then
                    -- Set fuel category
                    item.fuel_category = fcat_name

                    -- Set fuel value if not already set (spoofed items)
                    local slot_owner_key = gutils.key(slot_owner)
                    if not item.fuel_value and slot_to_spoof_fuel_value[slot_owner_key] then
                        local spoof_value = slot_to_spoof_fuel_value[slot_owner_key]
                        item.fuel_value = spoof_value .. "J"
                    end

                    -- Apply output scaling if needed
                    local new_fuel_value = util.parse_energy(item.fuel_value)
                    local old_fuel_value = 4000000  -- Default
                    if trav_to_old_slot then
                        local old_slot = trav_to_old_slot[trav_key]
                        if old_slot then
                            local old_slot_owner = gutils.get_conn_owner(graph, old_slot)
                            if old_slot_owner and old_slot_owner.type == "item" then
                                local old_item = dutils.get_prot("item", old_slot_owner.name)
                                if old_item and old_item.fuel_value then
                                    old_fuel_value = util.parse_energy(old_item.fuel_value)
                                end
                            end
                        end
                    end

                    local ratio = old_fuel_value / new_fuel_value
                    -- Cap ratio at stack_size to match validation logic
                    local stack_size = item.stack_size
                    local capped_ratio = math.min(ratio, stack_size)
                    if capped_ratio > 1 then
                        local multiplier = math.ceil(capped_ratio * 2)
                        if multiplier > 1 then
                            balance.apply_output_multiplier(item_name, multiplier)
                            log("Scaled " .. item_name .. " output by " .. multiplier .. "x for fuel balance (ratio=" .. string.format("%.1f", ratio) .. ")")
                        end
                    end
                end
            end
        end
    end

    -- SAFEGUARD: Ensure each fuel category has at least one fuel
    -- Collect all fuel categories and their fuels
    local fcat_to_fuels = {}
    for fcat_name, _ in pairs(data.raw["fuel-category"] or {}) do
        fcat_to_fuels[fcat_name] = {}
    end

    -- Find all items that are fuels for each category
    local all_fuel_items = {}
    for _, item in pairs(dutils.get_all_prots("item")) do
        if item.fuel_category ~= nil and item.fuel_value ~= nil then
            if fcat_to_fuels[item.fuel_category] then
                table.insert(fcat_to_fuels[item.fuel_category], item_name)
            end
            table.insert(all_fuel_items, {name = item_name, item = item})
        end
    end

    -- Fix empty categories by reassigning a fuel from overpopulated categories
    for fcat_name, fuels in pairs(fcat_to_fuels) do
        if #fuels == 0 then
            -- Find a category with multiple fuels to borrow from
            local donor_item = nil
            for other_fcat, other_fuels in pairs(fcat_to_fuels) do
                if #other_fuels > 1 then
                    -- Take the last one
                    donor_item = table.remove(other_fuels)
                    break
                end
            end

            if donor_item then
                -- Find and reassign the item
                local item = dutils.get_prot("item", donor_item)
                if item then
                    item.fuel_category = fcat_name
                    table.insert(fuels, donor_item)
                    log("SAFEGUARD: Reassigned " .. donor_item .. " to empty fuel category '" .. fcat_name .. "'")
                end
            else
                log("ERROR: Could not find donor fuel for empty category '" .. fcat_name .. "'")
            end
        end
    end

    -- Fix initial_fuel references in entities
    -- When we change an item's fuel_category, entities using it as initial_fuel need updating
    -- TODO: Fix! This needs to check all entities with burner...
    local entity_types_with_burner = {"inserter", "mining-drill", "furnace", "boiler", "locomotive", "car"}
    for _, entity_type in pairs(entity_types_with_burner) do
        for entity_name, entity in pairs(data.raw[entity_type] or {}) do
            if entity.energy_source and entity.energy_source.initial_fuel then
                local fuel_name = entity.energy_source.initial_fuel
                local fuel_item = dutils.get_prot("item", fuel_name)
                if fuel_item and fuel_item.fuel_category then
                    -- Check if fuel's category is compatible with entity's burner
                    local burner_cats = entity.energy_source.fuel_categories or {entity.energy_source.fuel_category or "chemical"}
                    local is_compatible = false
                    for _, cat in pairs(burner_cats) do
                        if cat == fuel_item.fuel_category then
                            is_compatible = true
                            break
                        end
                    end
                    if not is_compatible then
                        -- Find a compatible fuel from fcat_to_fuels
                        for _, cat in pairs(burner_cats) do
                            if fcat_to_fuels[cat] and #fcat_to_fuels[cat] > 0 then
                                entity.energy_source.initial_fuel = fcat_to_fuels[cat][1]
                                log("Fixed initial_fuel for " .. entity_name .. ": " .. fuel_name .. " -> " .. fcat_to_fuels[cat][1])
                                break
                            end
                        end
                    end
                end
            end
        end
    end
end

return fuel_categories
