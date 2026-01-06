local gutils = require("new-lib/graph/graph-utils")

local balance_utils = {}

-- Minimum spoil time in ticks to be eligible as fuel (3 minutes = 10800 ticks)
local MIN_SPOIL_TICKS = 10800

-- Check if an item can have its output scaled
-- Returns { scalable = bool, sources = { {type, name, kind}, ... }, first_scalable = bool }
-- first_scalable indicates if the FIRST source in progression is scalable
balance_utils.can_scale_item_output = function(item_name, init_sort)
    local item_key = gutils.key({type = "item", name = item_name})
    local sources = {}
    local first_source_ind = nil
    local first_source_scalable = nil

    -- Check recipe results (excluding recycling)
    for _, recipe in pairs(data.raw.recipe) do
        -- Skip recycling recipes
        if not string.match(recipe.name, "%-recycling$") then
            if recipe.results then
                for _, result in pairs(recipe.results) do
                    local result_name = result.name or result[1]
                    local result_type = result.type or "item"
                    if result_type == "item" and result_name == item_name then
                        table.insert(sources, {type = "recipe", name = recipe.name, kind = "recipe"})

                        -- Check if this is earliest in init_sort
                        if init_sort then
                            local recipe_key = gutils.key({type = "recipe", name = recipe.name})
                            local inds = init_sort.node_to_open_inds[recipe_key]
                            if inds then
                                for ind, _ in pairs(inds) do
                                    if first_source_ind == nil or ind < first_source_ind then
                                        first_source_ind = ind
                                        first_source_scalable = true
                                    end
                                end
                            end
                        end
                        break
                    end
                end
            end
        end
    end

    -- Check mining results (entities, tiles)
    for _, entity_type in pairs({"resource", "tree", "simple-entity", "fish"}) do
        if data.raw[entity_type] then
            for _, entity in pairs(data.raw[entity_type]) do
                if entity.minable then
                    local minable = entity.minable
                    local results = minable.results
                    if results == nil and minable.result then
                        results = {{type = "item", name = minable.result, amount = minable.count or 1}}
                    end
                    if results then
                        for _, result in pairs(results) do
                            local result_name = result.name or result[1]
                            local result_type = result.type or "item"
                            if result_type == "item" and result_name == item_name then
                                table.insert(sources, {type = entity_type, name = entity.name, kind = "mining"})

                                -- Check if this is earliest
                                if init_sort then
                                    local entity_key = gutils.key({type = "entity-mine", name = entity.name})
                                    local inds = init_sort.node_to_open_inds[entity_key]
                                    if inds then
                                        for ind, _ in pairs(inds) do
                                            if first_source_ind == nil or ind < first_source_ind then
                                                first_source_ind = ind
                                                first_source_scalable = true
                                            end
                                        end
                                    end
                                end
                                break
                            end
                        end
                    end
                end
            end
        end
    end

    -- Check loot (scalable)
    for _, entity_type in pairs({"unit", "turret", "unit-spawner", "spider-unit"}) do
        if data.raw[entity_type] then
            for _, entity in pairs(data.raw[entity_type]) do
                if entity.loot then
                    for _, loot in pairs(entity.loot) do
                        if loot.item == item_name then
                            table.insert(sources, {type = entity_type, name = entity.name, kind = "loot"})

                            -- Loot is generally late, check index
                            if init_sort then
                                local entity_key = gutils.key({type = "entity-kill", name = entity.name})
                                local inds = init_sort.node_to_open_inds[entity_key]
                                if inds then
                                    for ind, _ in pairs(inds) do
                                        if first_source_ind == nil or ind < first_source_ind then
                                            first_source_ind = ind
                                            first_source_scalable = true
                                        end
                                    end
                                end
                            end
                            break
                        end
                    end
                end
            end
        end
    end

    -- Check spoil results (NOT scalable)
    for _, item_type in pairs({"item", "capsule", "tool"}) do
        if data.raw[item_type] then
            for _, item in pairs(data.raw[item_type]) do
                if item.spoil_result == item_name then
                    table.insert(sources, {type = item_type, name = item.name, kind = "spoil"})

                    -- Check if this is earliest (would make first_scalable = false)
                    if init_sort then
                        local spoil_key = gutils.key({type = "item", name = item.name})
                        local inds = init_sort.node_to_open_inds[spoil_key]
                        if inds then
                            for ind, _ in pairs(inds) do
                                if first_source_ind == nil or ind < first_source_ind then
                                    first_source_ind = ind
                                    first_source_scalable = false
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    -- Check burnt results (NOT scalable)
    for _, item_type in pairs({"item", "capsule", "tool"}) do
        if data.raw[item_type] then
            for _, item in pairs(data.raw[item_type]) do
                if item.burnt_result == item_name then
                    table.insert(sources, {type = item_type, name = item.name, kind = "burnt"})

                    if init_sort then
                        local burn_key = gutils.key({type = "item-burn", name = item.name})
                        local inds = init_sort.node_to_open_inds[burn_key]
                        if inds then
                            for ind, _ in pairs(inds) do
                                if first_source_ind == nil or ind < first_source_ind then
                                    first_source_ind = ind
                                    first_source_scalable = false
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    local has_scalable = false
    for _, source in pairs(sources) do
        if source.kind == "recipe" or source.kind == "mining" or source.kind == "loot" then
            has_scalable = true
            break
        end
    end

    return {
        scalable = has_scalable,
        first_scalable = first_source_scalable or false,
        sources = sources
    }
end

-- Apply output multiplier to all scalable sources of an item
balance_utils.apply_output_multiplier = function(item_name, multiplier)
    -- Scale recipe results
    for _, recipe in pairs(data.raw.recipe) do
        if not string.match(recipe.name, "%-recycling$") then
            if recipe.results then
                for _, result in pairs(recipe.results) do
                    local result_name = result.name or result[1]
                    local result_type = result.type or "item"
                    if result_type == "item" and result_name == item_name then
                        if result.amount then
                            result.amount = result.amount * multiplier
                        elseif result[2] then
                            result[2] = result[2] * multiplier
                        end
                    end
                end
            end
        end
    end

    -- Scale mining results
    for _, entity_type in pairs({"resource", "tree", "simple-entity", "fish"}) do
        if data.raw[entity_type] then
            for _, entity in pairs(data.raw[entity_type]) do
                if entity.minable then
                    local minable = entity.minable
                    if minable.results then
                        for _, result in pairs(minable.results) do
                            local result_name = result.name or result[1]
                            local result_type = result.type or "item"
                            if result_type == "item" and result_name == item_name then
                                if result.amount then
                                    result.amount = result.amount * multiplier
                                elseif result[2] then
                                    result[2] = result[2] * multiplier
                                end
                            end
                        end
                    elseif minable.result == item_name then
                        minable.count = (minable.count or 1) * multiplier
                    end
                end
            end
        end
    end

    -- Scale loot
    for _, entity_type in pairs({"unit", "turret", "unit-spawner", "spider-unit"}) do
        if data.raw[entity_type] then
            for _, entity in pairs(data.raw[entity_type]) do
                if entity.loot then
                    for _, loot in pairs(entity.loot) do
                        if loot.item == item_name then
                            loot.count_min = (loot.count_min or 1) * multiplier
                            loot.count_max = (loot.count_max or loot.count_min or 1) * multiplier
                        end
                    end
                end
            end
        end
    end
end

-- Check if an item is eligible to become a fuel
balance_utils.can_be_fuel = function(item_name)
    local item = balance_utils.find_item(item_name)
    if not item then
        return false
    end

    -- Must be stackable (stack_size > 1)
    local stack_size = item.stack_size or 1
    if stack_size <= 1 then
        return false
    end

    -- Check spoil time if spoilable (minimum 3 minutes)
    if item.spoil_ticks and item.spoil_ticks < MIN_SPOIL_TICKS then
        return false
    end

    -- Blacklist science packs
    if string.match(item_name, "science%-pack") then
        return false
    end

    -- Blacklist rocket parts
    if item_name == "rocket-part" or item_name == "rocket-fuel" then
        return false
    end

    return true
end

return balance_utils
