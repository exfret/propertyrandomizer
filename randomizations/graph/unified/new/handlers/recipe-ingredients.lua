-- TODO: Review and fix

local gutils = require("new-lib/graph/graph-utils")
local recipe_balance = require("randomizations/graph/unified/new/handlers/recipe-balance-utils")

local recipe_ingredients = {}

-- Track smelting ingredient assignments during randomization
local smelting_assignments = {}

-- Track ingredients already assigned to each recipe (to prevent duplicates)
local recipe_ingredient_assignments = {}

-- Claim edges from item/fluid to recipe
-- Items/fluids can be ingredients in many recipes - not limited
-- Return extra copies to expand the pool
recipe_ingredients.claim = function(graph, prereq, dep, trav)
    if dep.type == "recipe" then
        if prereq.type == "item" or prereq.type == "fluid" then
            local recipe = data.raw.recipe[dep.name]
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
            return 5  -- Items can be shared as ingredients, add copies
        end
    end
end

-- Validate: check that the slot (item/fluid) can be used in the traveler (recipe)
recipe_ingredients.validate = function(graph, slot, trav, extra)
    local slot_owner = gutils.get_conn_owner(graph, slot)
    local trav_owner = gutils.get_conn_owner(graph, trav)

    -- Slot must be item or fluid
    if slot_owner.type ~= "item" and slot_owner.type ~= "fluid" then
        return false
    end

    -- Traveler must be a recipe
    if trav_owner.type ~= "recipe" then
        return false
    end

    -- Check if the recipe exists
    local recipe = data.raw.recipe[trav_owner.name]
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

    local is_fluid_slot = (slot_owner.type == "fluid")
    local ingredient_type = is_fluid_slot and "fluid" or "item"

    -- Check for duplicate ingredient assignment within same recipe
    recipe_ingredient_assignments[trav_owner.name] = recipe_ingredient_assignments[trav_owner.name] or {}
    if recipe_ingredient_assignments[trav_owner.name][slot_owner.name] then
        return false  -- This ingredient already assigned to this recipe
    end

    -- Balance check: validate assignment doesn't break gameplay
    local error = recipe_balance.validate_ingredient_assignment(
        trav_owner.name,
        slot_owner.name,
        ingredient_type,
        smelting_assignments
    )
    if error then
        -- log("BALANCE REJECT: " .. trav_owner.name .. " <- " .. slot_owner.name .. ": " .. error)
        return false
    end

    -- Cost ratio check: don't swap ingredients with wildly different costs
    if extra and extra.trav_to_old_slot then
        local old_slot = extra.trav_to_old_slot[gutils.key(trav)]
        if old_slot then
            local old_slot_owner = gutils.get_conn_owner(graph, old_slot)
            if old_slot_owner and (old_slot_owner.type == "item" or old_slot_owner.type == "fluid") then
                local cost_error = recipe_balance.check_cost_ratio(
                    {type = old_slot_owner.type, name = old_slot_owner.name},
                    {type = slot_owner.type, name = slot_owner.name}
                )
                if cost_error then
                    -- log("COST REJECT: " .. trav_owner.name .. " <- " .. slot_owner.name .. ": " .. cost_error)
                    return false
                end
            end
        end
    end

    -- If the slot is a fluid, check if the recipe can accept fluid ingredients
    if is_fluid_slot then
        -- Check original ingredients for fluid count
        local recipe_fluid_inputs = 0
        if recipe.ingredients then
            for _, ing in pairs(recipe.ingredients) do
                if ing.type == "fluid" then
                    recipe_fluid_inputs = recipe_fluid_inputs + 1
                end
            end
        end

        -- Recipe must have at least one fluid input slot
        if recipe_fluid_inputs == 0 then
            return false  -- Can't add fluid to non-fluid recipe
        end
    end

    -- Track smelting assignments for collision detection
    local category = recipe.category or "crafting"
    if category == "smelting" and not is_fluid_slot then
        smelting_assignments[trav_owner.name] = slot_owner.name
    end

    -- Record this ingredient assignment to prevent duplicates
    recipe_ingredient_assignments[trav_owner.name][slot_owner.name] = true

    return true
end

-- Apply ingredient changes to data.raw
-- This handles replacing ingredients while preserving slot structure
recipe_ingredients.reflect = function(graph, trav_to_new_slot, trav_to_old_slot)
    -- First pass: collect all changes grouped by recipe
    local recipe_changes = {}

    for trav_key, new_slot in pairs(trav_to_new_slot) do
        local trav = graph.nodes[trav_key]
        local trav_owner = gutils.get_conn_owner(graph, trav)
        local new_slot_owner = gutils.get_conn_owner(graph, new_slot)

        -- Only process our edge types
        if trav_owner.type == "recipe" and
           (new_slot_owner.type == "item" or new_slot_owner.type == "fluid") then

            local old_slot = trav_to_old_slot[trav_key]
            local old_slot_owner = gutils.get_conn_owner(graph, old_slot)

            local recipe_name = trav_owner.name
            local new_material = new_slot_owner.name
            local old_material = old_slot_owner.name
            local is_fluid = (new_slot_owner.type == "fluid")
            local was_fluid = (old_slot_owner.type == "fluid")

            -- Calculate cost adjustment for balancing
            local old_type = was_fluid and "fluid" or "item"
            local new_type = is_fluid and "fluid" or "item"
            local adjustment = recipe_balance.get_cost_adjustment(
                {type = old_type, name = old_material},
                {type = new_type, name = new_material}
            )

            recipe_changes[recipe_name] = recipe_changes[recipe_name] or {}
            table.insert(recipe_changes[recipe_name], {
                old_material = old_material,
                new_material = new_material,
                is_fluid = is_fluid,
                was_fluid = was_fluid,
                cost_adjustment = adjustment,
            })
        end
    end

    -- Second pass: apply changes to each recipe
    for recipe_name, changes in pairs(recipe_changes) do
        local recipe = data.raw.recipe[recipe_name]
        if recipe and recipe.ingredients then
            for _, change in pairs(changes) do
                local found = false

                -- Find the ingredient slot to modify
                for i, ing in pairs(recipe.ingredients) do
                    local ing_type = ing.type or "item"
                    local ing_name = ing.name or ing[1]

                    -- Match by old material name and type
                    if ing_name == change.old_material and
                       ((change.was_fluid and ing_type == "fluid") or
                        (not change.was_fluid and ing_type == "item")) then

                        -- Update the ingredient
                        if ing.name then
                            ing.name = change.new_material
                        else
                            ing[1] = change.new_material
                        end

                        -- Handle type change (item <-> fluid)
                        if change.is_fluid ~= change.was_fluid then
                            ing.type = change.is_fluid and "fluid" or "item"
                        end

                        -- Apply cost balancing to amount
                        local old_amount = ing.amount or 1
                        local new_amount = recipe_balance.adjust_amount(
                            old_amount, change.cost_adjustment, change.is_fluid
                        )
                        ing.amount = new_amount

                        found = true
                        log("Changed recipe " .. recipe_name .. " ingredient from " ..
                            change.old_material .. " to " .. change.new_material ..
                            " (amount: " .. old_amount .. " -> " .. new_amount .. ")")
                        break
                    end
                end

                if not found then
                    -- Ingredient not found by exact match, try by type only
                    -- This handles cases where multiple ingredients of same type exist
                    for i, ing in pairs(recipe.ingredients) do
                        local ing_type = ing.type or "item"
                        local matches_type = (change.was_fluid and ing_type == "fluid") or
                                             (not change.was_fluid and ing_type == "item")

                        if matches_type then
                            if ing.name then
                                ing.name = change.new_material
                            else
                                ing[1] = change.new_material
                            end

                            if change.is_fluid ~= change.was_fluid then
                                ing.type = change.is_fluid and "fluid" or "item"
                            end

                            -- Apply cost balancing to amount
                            local old_amount = ing.amount or 1
                            local new_amount = recipe_balance.adjust_amount(
                                old_amount, change.cost_adjustment, change.is_fluid
                            )
                            ing.amount = new_amount

                            log("Changed recipe " .. recipe_name .. " ingredient (fallback) to " ..
                                change.new_material .. " (amount: " .. old_amount .. " -> " .. new_amount .. ")")
                            break
                        end
                    end
                end
            end
        end
    end
end

return recipe_ingredients
