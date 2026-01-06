-- TODO: Review and fix

local gutils = require("new-lib/graph/graph-utils")
local recipe_balance = require("randomizations/graph/unified/new/handlers/recipe-balance-utils")
local locale_utils = require("lib/locale")

local recipe_results = {}

-- Claim edges from recipe to item-craft or fluid-craft
-- Recipes have limited result slots, but some have multiple results
-- Add small number of copies for flexibility
recipe_results.claim = function(graph, prereq, dep, trav)
    if prereq.type == "recipe" then
        if dep.type == "item-craft" or dep.type == "fluid-craft" then
            local recipe = data.raw.recipe[prereq.name]
            if recipe then
                local category = recipe.category or "crafting"
                -- Skip hidden non-recycling recipes entirely
                if recipe.hidden and category ~= "recycling" and category ~= "recycling-or-hand-crafting" then
                    return 0  -- Don't claim hidden non-recycling recipes
                end
                -- Skip recycling recipes (they must follow their source recipes)
                if category == "recycling" or category == "recycling-or-hand-crafting" then
                    return 0  -- Don't randomize recycling recipes
                end
            end
            return 2  -- Small copies since recipes have limited result capacity
        end
    end
end

-- Validate: check that the slot (recipe) can produce the traveler (item/fluid)
recipe_results.validate = function(graph, slot, trav, extra)
    local slot_owner = gutils.get_conn_owner(graph, slot)
    local trav_owner = gutils.get_conn_owner(graph, trav)

    -- Slot must be a recipe
    if slot_owner.type ~= "recipe" then
        return false
    end

    -- Check if the recipe exists
    local recipe = data.raw.recipe[slot_owner.name]
    if not recipe then
        return false
    end

    local category = recipe.category or "crafting"

    -- Skip hidden non-recycling recipes entirely
    if recipe.hidden and category ~= "recycling" and category ~= "recycling-or-hand-crafting" then
        return false
    end

    -- Skip recycling recipes (they must follow their source recipes)
    if category == "recycling" or category == "recycling-or-hand-crafting" then
        return false
    end

    -- Traveler must be item-craft or fluid-craft
    if trav_owner.type ~= "item-craft" and trav_owner.type ~= "fluid-craft" then
        return false
    end

    -- Determine what type of material the traveler wants
    local is_fluid_result = (trav_owner.type == "fluid-craft")
    local result_type = is_fluid_result and "fluid" or "item"

    -- Balance check: validate assignment doesn't break gameplay
    local error = recipe_balance.validate_result_assignment(
        slot_owner.name,
        trav_owner.name,
        result_type
    )
    if error then
        return false
    end

    -- Cost ratio check: compare item cost with recipe's original output cost
    -- trav_owner is item-craft/fluid-craft (the item we want recipe to produce)
    -- slot_owner is the recipe that will produce it
    -- We compare: new item's cost vs recipe's original main result's cost
    if recipe.results and #recipe.results > 0 then
        local original_result = recipe.results[1]
        local orig_type = original_result.type or "item"
        local orig_name = original_result.name

        local cost_error = recipe_balance.check_cost_ratio(
            {type = orig_type, name = orig_name},
            {type = is_fluid_result and "fluid" or "item", name = trav_owner.name}
        )
        if cost_error then
            -- log("COST REJECT (result): " .. slot_owner.name .. " -> " .. trav_owner.name .. ": " .. cost_error)
            return false
        end
    end

    -- Check if recipe can produce this type
    if is_fluid_result then
        -- Count fluid results in the recipe
        local fluid_count = 0
        if recipe.results then
            for _, result in pairs(recipe.results) do
                local rt = result.type or "item"
                if rt == "fluid" then
                    fluid_count = fluid_count + 1
                end
            end
        end
        -- Recipe must have at least one fluid result slot
        if fluid_count == 0 then
            return false  -- Can't add fluid result to non-fluid recipe
        end
    end

    return true
end

-- Apply result changes to data.raw
-- This is complex because we need to:
-- 1. Track which result slots are being swapped
-- 2. Handle item vs fluid type changes
-- 3. Preserve result amounts/probabilities
recipe_results.reflect = function(graph, trav_to_new_slot, trav_to_old_slot)
    -- First pass: collect all changes grouped by recipe
    local recipe_changes = {}

    for trav_key, new_slot in pairs(trav_to_new_slot) do
        local trav = graph.nodes[trav_key]
        local trav_owner = gutils.get_conn_owner(graph, trav)
        local new_slot_owner = gutils.get_conn_owner(graph, new_slot)

        -- Only process our edge types
        if new_slot_owner.type == "recipe" and
           (trav_owner.type == "item-craft" or trav_owner.type == "fluid-craft") then

            local old_slot = trav_to_old_slot[trav_key]
            local old_slot_owner = gutils.get_conn_owner(graph, old_slot)

            -- Get the material name from the traveler owner
            local material_name = trav_owner.name
            local is_fluid = (trav_owner.type == "fluid-craft")

            -- Calculate cost adjustment by comparing recipe's original result with new result
            local new_recipe_name = new_slot_owner.name
            local new_recipe = data.raw.recipe[new_recipe_name]
            local adjustment = 1.0
            if new_recipe and new_recipe.results and #new_recipe.results > 0 then
                local orig_result = new_recipe.results[1]
                local orig_type = orig_result.type or "item"
                local orig_name = orig_result.name
                local new_type = is_fluid and "fluid" or "item"
                adjustment = recipe_balance.get_cost_adjustment(
                    {type = orig_type, name = orig_name},
                    {type = new_type, name = material_name}
                )
            end

            -- Track this assignment
            recipe_changes[new_recipe_name] = recipe_changes[new_recipe_name] or {}
            table.insert(recipe_changes[new_recipe_name], {
                material_name = material_name,
                is_fluid = is_fluid,
                old_recipe_name = old_slot_owner.name,
                trav = trav,
                cost_adjustment = adjustment,
            })
        end
    end

    -- Second pass: apply changes to each recipe
    for recipe_name, changes in pairs(recipe_changes) do
        local recipe = data.raw.recipe[recipe_name]
        if recipe then
            -- Track which result indices have been modified (to handle multi-result recipes)
            local modified_indices = {}
            -- Track adjustment factors for time scaling
            local total_adjustment = 0
            local adjustment_count = 0

            -- For each result that should come from this recipe
            for _, change in pairs(changes) do
                local found = false

                -- Find an existing result slot to modify (skip already-modified slots)
                if recipe.results then
                    for i, result in pairs(recipe.results) do
                        local result_type = result.type or "item"
                        local matches_type = (change.is_fluid and result_type == "fluid") or
                                             (not change.is_fluid and result_type == "item")

                        if matches_type and not found and not modified_indices[i] then
                            -- Modify this result slot
                            local old_result_name = result.name
                            result.name = change.material_name

                            -- Apply cost balancing to amount
                            local old_amount = result.amount or 1
                            local new_amount = recipe_balance.adjust_amount(
                                old_amount, change.cost_adjustment, change.is_fluid
                            )

                            -- Clear temperature - the new fluid may have different temp range
                            if change.is_fluid then
                                result.temperature = nil
                                result.amount = new_amount
                            else
                                -- Check if item is stackable - cap amount if not
                                local item_proto
                                for _, item_type in pairs({"item", "ammo", "capsule", "gun", "tool", "armor", "module"}) do
                                    if data.raw[item_type] and data.raw[item_type][change.material_name] then
                                        item_proto = data.raw[item_type][change.material_name]
                                        break
                                    end
                                end
                                if item_proto then
                                    local stack_size = item_proto.stack_size or 1
                                    -- Apply adjustment but cap to stack size
                                    if new_amount > stack_size then
                                        new_amount = stack_size
                                    end
                                    result.amount = new_amount
                                    -- Also cap amount_max if present
                                    if result.amount_max then
                                        local new_max = recipe_balance.adjust_amount(
                                            result.amount_max, change.cost_adjustment, false
                                        )
                                        result.amount_max = math.min(new_max, stack_size)
                                    end
                                else
                                    result.amount = new_amount
                                end
                            end
                            found = true
                            modified_indices[i] = true
                            -- Track adjustment for time scaling
                            if old_amount > 0 then
                                total_adjustment = total_adjustment + (new_amount / old_amount)
                                adjustment_count = adjustment_count + 1
                            end
                            log("Changed recipe " .. recipe_name .. " result from " ..
                                old_result_name .. " to " .. change.material_name ..
                                " (amount: " .. old_amount .. " -> " .. new_amount .. ")")
                        end
                    end
                end

                if not found then
                    -- Need to add a new result
                    recipe.results = recipe.results or {}
                    table.insert(recipe.results, {
                        type = change.is_fluid and "fluid" or "item",
                        name = change.material_name,
                        amount = 1,
                    })
                    log("Added result " .. change.material_name .. " to recipe " .. recipe_name)
                end
            end

            -- Scale recipe time based on average result adjustment
            -- If we're outputting more items (because they're cheaper), recipe should take longer
            if adjustment_count > 0 then
                local avg_adjustment = total_adjustment / adjustment_count
                if avg_adjustment > 1.1 or avg_adjustment < 0.9 then
                    local old_time = recipe.energy_required or 0.5
                    local new_time = old_time * avg_adjustment
                    -- Cap time scaling to reasonable bounds (0.1s to 100s)
                    new_time = math.max(0.1, math.min(100, new_time))
                    recipe.energy_required = new_time
                    log("Scaled recipe " .. recipe_name .. " time: " .. old_time .. " -> " .. new_time .. " (factor: " .. avg_adjustment .. ")")
                end
            end

            -- Handle main_product and icons for single-result recipes
            if recipe.results and #recipe.results > 0 then
                local main_result = recipe.results[1]
                local result_name = main_result.name
                local result_type = main_result.type or "item"

                -- Find the prototype to get its icon
                local proto
                if result_type == "fluid" then
                    proto = data.raw.fluid[result_name]
                else
                    -- Search item types
                    for _, item_type in pairs({"item", "ammo", "capsule", "gun", "tool", "armor", "module"}) do
                        if data.raw[item_type] and data.raw[item_type][result_name] then
                            proto = data.raw[item_type][result_name]
                            break
                        end
                    end
                end

                -- For single-result recipes, set main_product and localization
                if #recipe.results == 1 and proto then
                    recipe.main_product = result_name

                    -- Set localized name with fallback to recipe's original name
                    if recipe.localised_name == nil then
                        recipe.localised_name = {"?", {"recipe-name." .. recipe_name}, locale_utils.find_localised_name(proto)}
                    end

                    -- Only replace icon if original recipe had no icon
                    -- (check before we might have modified it)
                    local had_original_icon = recipe.icon ~= nil or recipe.icons ~= nil
                    if not had_original_icon then
                        if proto.icons then
                            recipe.icons = proto.icons
                            recipe.icon = nil
                            recipe.icon_size = nil
                        elseif proto.icon then
                            recipe.icons = {
                                {
                                    icon = proto.icon,
                                    icon_size = proto.icon_size or 64
                                }
                            }
                            recipe.icon = nil
                            recipe.icon_size = nil
                        end
                    end
                else
                    -- Multi-result recipe - clear main_product
                    recipe.main_product = nil

                    -- Still update icon if recipe had none
                    if proto and recipe.icon == nil and recipe.icons == nil then
                        if proto.icon then
                            recipe.icon = proto.icon
                            recipe.icon_size = proto.icon_size or 64
                        elseif proto.icons then
                            recipe.icons = proto.icons
                        end
                    end
                end
            else
                -- No results - clear main_product
                recipe.main_product = nil
            end

            -- Safety: ensure recipe has some icon (required by Factorio)
            if recipe.icon == nil and recipe.icons == nil and recipe.main_product == nil then
                -- Try to get icon from first result
                if recipe.results and #recipe.results > 0 then
                    local first_result = recipe.results[1]
                    local first_type = first_result.type or "item"
                    local first_name = first_result.name
                    local first_proto
                    if first_type == "fluid" then
                        first_proto = data.raw.fluid[first_name]
                    else
                        for _, item_type in pairs({"item", "ammo", "capsule", "gun", "tool", "armor", "module", "item-with-entity-data"}) do
                            if data.raw[item_type] and data.raw[item_type][first_name] then
                                first_proto = data.raw[item_type][first_name]
                                break
                            end
                        end
                    end
                    if first_proto then
                        if first_proto.icons then
                            recipe.icons = first_proto.icons
                        elseif first_proto.icon then
                            recipe.icon = first_proto.icon
                            recipe.icon_size = first_proto.icon_size or 64
                        end
                    end
                end
                -- Last resort: use a generic icon
                if recipe.icon == nil and recipe.icons == nil then
                    recipe.icon = "__base__/graphics/icons/wooden-chest.png"
                    recipe.icon_size = 64
                    log("WARNING: Recipe " .. recipe_name .. " had no icon, using fallback")
                end
            end
        end
    end
end

return recipe_results
