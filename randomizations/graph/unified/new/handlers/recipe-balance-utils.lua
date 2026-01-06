local gutils = require("new-lib/graph/graph-utils")
local flow_cost = require("lib/graph/flow-cost")
local constants = require("helper-tables/constants")

local recipe_balance = {}

-- Maximum cost ratio allowed during validation (permissive - balance afterward)
local MAX_COST_RATIO_VALIDATE = 100

-- Limits for amount adjustment during balancing
local MIN_AMOUNT = 0.1
local MAX_AMOUNT_MULTIPLIER = 10  -- Don't increase amounts by more than 10x
local MAX_ABSOLUTE_AMOUNT = 500   -- Never exceed this amount for any ingredient/result

--------------------------------------------------------------------------------
-- Lookup caches (built on first use)
--------------------------------------------------------------------------------

local _furnace_fuel_categories = nil
local _smelting_recipes = nil
local _fluid_box_filters = nil
local _material_costs = nil

-- Get material costs using flow cost algorithm (cached)
local function get_material_costs()
    if _material_costs then
        return _material_costs
    end

    log("Computing flow costs for recipe balance validation...")
    local raw_resources = flow_cost.get_default_raw_resource_table()
    -- Add wood and fish as resources
    raw_resources["item-wood"] = 1
    raw_resources["item-raw-fish"] = 25

    local cost_info = flow_cost.determine_recipe_item_cost(
        raw_resources,
        constants.cost_params.time,
        constants.cost_params.complexity
    )
    _material_costs = cost_info.material_to_cost
    log("Flow cost computation complete")
    return _material_costs
end

-- Get fuel categories that furnaces use
local function get_furnace_fuel_categories()
    if _furnace_fuel_categories then
        return _furnace_fuel_categories
    end

    _furnace_fuel_categories = {}
    for _, furnace in pairs(data.raw.furnace or {}) do
        if furnace.energy_source and furnace.energy_source.type == "burner" then
            local fuel_cats = furnace.energy_source.fuel_categories or {"chemical"}
            for _, cat in pairs(fuel_cats) do
                _furnace_fuel_categories[cat] = _furnace_fuel_categories[cat] or {}
                _furnace_fuel_categories[cat][furnace.name] = true
            end
        end
    end
    return _furnace_fuel_categories
end

-- Get all recipes in smelting category
local function get_smelting_recipes()
    if _smelting_recipes then
        return _smelting_recipes
    end

    _smelting_recipes = {}
    for _, recipe in pairs(data.raw.recipe or {}) do
        local cat = recipe.category or "crafting"
        if cat == "smelting" then
            _smelting_recipes[recipe.name] = recipe
        end
    end
    return _smelting_recipes
end

-- Get fluid box filters for all crafting machines
-- Returns: { machine_name = { input = {fluid1, fluid2}, output = {fluid3} } }
local function get_fluid_box_filters()
    if _fluid_box_filters then
        return _fluid_box_filters
    end

    _fluid_box_filters = {}
    for _, class in pairs({"assembling-machine", "furnace", "rocket-silo"}) do
        for _, machine in pairs(data.raw[class] or {}) do
            if machine.fluid_boxes then
                local filters = { input = {}, output = {} }
                for _, fb in pairs(machine.fluid_boxes) do
                    if fb.filter then
                        if fb.production_type == "input" then
                            table.insert(filters.input, fb.filter)
                        elseif fb.production_type == "output" then
                            table.insert(filters.output, fb.filter)
                        end
                    end
                end
                if #filters.input > 0 or #filters.output > 0 then
                    _fluid_box_filters[machine.name] = filters
                end
            end
        end
    end
    return _fluid_box_filters
end

--------------------------------------------------------------------------------
-- Validation functions
--------------------------------------------------------------------------------

-- Check if two materials have similar costs (within MAX_COST_RATIO)
-- Returns nil if costs are similar, or error string if too different
-- old_material and new_material are {type = "item"/"fluid", name = "..."}
recipe_balance.check_cost_ratio = function(old_material, new_material)
    local costs = get_material_costs()

    local old_id = old_material.type .. "-" .. old_material.name
    local new_id = new_material.type .. "-" .. new_material.name

    local old_cost = costs[old_id]
    local new_cost = costs[new_id]

    -- If either cost is unknown, be permissive
    if not old_cost or not new_cost then
        return nil
    end

    -- Avoid division by zero
    if old_cost <= 0 or new_cost <= 0 then
        return nil
    end

    local ratio = new_cost / old_cost
    if ratio > MAX_COST_RATIO_VALIDATE then
        return string.format("New material too expensive (%.1fx vs max %dx)", ratio, MAX_COST_RATIO_VALIDATE)
    end
    if ratio < (1 / MAX_COST_RATIO_VALIDATE) then
        return string.format("New material too cheap (%.2fx vs min %.2fx)", ratio, 1/MAX_COST_RATIO_VALIDATE)
    end

    return nil  -- Costs are within acceptable range for balancing
end

-- Get material cost (for logging/debugging)
recipe_balance.get_material_cost = function(material_type, material_name)
    local costs = get_material_costs()
    local id = material_type .. "-" .. material_name
    return costs[id]
end

-- Check if an item is a fuel for furnaces
-- Returns true if the item would burn in a furnace instead of being smelted
recipe_balance.is_furnace_fuel = function(item_name)
    local item = nil
    for _, item_type in pairs({"item", "tool", "capsule", "ammo"}) do
        if data.raw[item_type] and data.raw[item_type][item_name] then
            item = data.raw[item_type][item_name]
            break
        end
    end

    if not item or not item.fuel_category then
        return false
    end

    local furnace_fcats = get_furnace_fuel_categories()
    return furnace_fcats[item.fuel_category] ~= nil
end

-- Check if two smelting recipes would have the same ingredient
-- This makes them indistinguishable since furnaces auto-select recipes
-- Returns true if collision would occur
recipe_balance.smelting_ingredient_collision = function(recipe_name, new_ingredient_name, existing_assignments)
    existing_assignments = existing_assignments or {}

    -- Check what ingredients other smelting recipes have
    local smelting = get_smelting_recipes()

    for other_name, other_recipe in pairs(smelting) do
        if other_name ~= recipe_name then
            -- Get ingredient (smelting recipes typically have 1)
            local other_ingredient = nil
            if other_recipe.ingredients then
                for _, ing in pairs(other_recipe.ingredients) do
                    other_ingredient = ing.name or ing[1]
                    break
                end
            end

            -- Check existing assignments first
            if existing_assignments[other_name] then
                other_ingredient = existing_assignments[other_name]
            end

            if other_ingredient == new_ingredient_name then
                return true
            end
        end
    end

    return false
end

-- Check if a fluid is compatible with a recipe category's crafters
-- Some crafters have filtered fluid boxes that only accept specific fluids
-- Returns true if fluid is compatible, false if incompatible
recipe_balance.fluid_compatible_with_category = function(fluid_name, rcat_name, is_input)
    -- Parse rcat_name to get base category
    local parts = {}
    local pos = 1
    while pos <= #rcat_name do
        local sep_start, sep_end = string.find(rcat_name, "__", pos, true)
        if sep_start then
            table.insert(parts, string.sub(rcat_name, pos, sep_start - 1))
            pos = sep_end + 1
        else
            table.insert(parts, string.sub(rcat_name, pos))
            break
        end
    end

    if #parts < 1 then
        return true  -- Can't parse, be permissive
    end

    local base_category = parts[1]
    local filters = get_fluid_box_filters()

    -- Find crafters for this category and check their filters
    for _, class in pairs({"assembling-machine", "furnace", "rocket-silo"}) do
        for _, machine in pairs(data.raw[class] or {}) do
            if machine.crafting_categories then
                for _, cat in pairs(machine.crafting_categories) do
                    if cat == base_category then
                        -- This machine can craft this category
                        local machine_filters = filters[machine.name]
                        if machine_filters then
                            -- Machine has filtered fluid boxes
                            local filter_list = is_input and machine_filters.input or machine_filters.output
                            if #filter_list > 0 then
                                -- Check if our fluid is in the filter list
                                local found = false
                                for _, allowed_fluid in pairs(filter_list) do
                                    if allowed_fluid == fluid_name then
                                        found = true
                                        break
                                    end
                                end
                                if not found then
                                    -- This machine can't accept this fluid
                                    -- But another machine for the category might
                                    -- Continue checking
                                end
                            end
                        end
                        -- Machine has no filters or fluid matches - OK
                        return true
                    end
                end
            end
        end
    end

    -- No compatible crafter found
    return false
end

-- Combined validation for recipe-ingredients handler
-- Returns nil if valid, or error string if invalid
recipe_balance.validate_ingredient_assignment = function(recipe_name, ingredient_name, ingredient_type, existing_assignments)
    local recipe = data.raw.recipe[recipe_name]
    if not recipe then
        return "Recipe not found"
    end

    local category = recipe.category or "crafting"

    -- Check 1: Smelting recipes can't use furnace fuels as ingredients
    if category == "smelting" and ingredient_type == "item" then
        if recipe_balance.is_furnace_fuel(ingredient_name) then
            return "Item is a furnace fuel and would burn instead of smelt"
        end
    end

    -- Check 2: Smelting recipes can't have duplicate ingredients
    if category == "smelting" and ingredient_type == "item" then
        if recipe_balance.smelting_ingredient_collision(recipe_name, ingredient_name, existing_assignments) then
            return "Would create duplicate smelting ingredient"
        end
    end

    -- Check 3: Fluids must be compatible with category's fluid boxes
    if ingredient_type == "fluid" then
        -- Build rcat_name (simplified - just use category with 1 fluid input)
        local rcat_name = category .. "__1__0"
        if not recipe_balance.fluid_compatible_with_category(ingredient_name, rcat_name, true) then
            return "Fluid not compatible with category's fluid boxes"
        end
    end

    return nil  -- Valid
end

-- Combined validation for recipe-results handler
-- Returns nil if valid, or error string if invalid
recipe_balance.validate_result_assignment = function(recipe_name, result_name, result_type)
    local recipe = data.raw.recipe[recipe_name]
    if not recipe then
        return "Recipe not found"
    end

    local category = recipe.category or "crafting"

    -- Check: Fluids must be compatible with category's fluid boxes
    if result_type == "fluid" then
        local rcat_name = category .. "__0__1"
        if not recipe_balance.fluid_compatible_with_category(result_name, rcat_name, false) then
            return "Fluid not compatible with category's output fluid boxes"
        end
    end

    return nil  -- Valid
end

--------------------------------------------------------------------------------
-- Post-randomization balancing
--------------------------------------------------------------------------------

-- Calculate how much to multiply an amount by to balance cost difference
-- old_material and new_material are {type = "item"/"fluid", name = "..."}
-- Returns multiplier (1.0 = no change needed)
recipe_balance.get_cost_adjustment = function(old_material, new_material)
    local costs = get_material_costs()

    local old_id = old_material.type .. "-" .. old_material.name
    local new_id = new_material.type .. "-" .. new_material.name

    local old_cost = costs[old_id]
    local new_cost = costs[new_id]

    -- If either cost is unknown, no adjustment
    if not old_cost or not new_cost then
        return 1.0
    end

    -- Avoid division by zero
    if old_cost <= 0 or new_cost <= 0 then
        return 1.0
    end

    -- If new material is cheaper, we need MORE of it (multiply up)
    -- If new material is more expensive, we need LESS of it (multiply down)
    -- ratio = old_cost / new_cost means: how many new items equal one old item in value
    local ratio = old_cost / new_cost

    -- Clamp to reasonable bounds
    if ratio > MAX_AMOUNT_MULTIPLIER then
        ratio = MAX_AMOUNT_MULTIPLIER
    end
    if ratio < (1 / MAX_AMOUNT_MULTIPLIER) then
        ratio = 1 / MAX_AMOUNT_MULTIPLIER
    end

    return ratio
end

-- Apply cost adjustment to an amount, respecting min/max bounds
-- Returns adjusted amount (may be fractional for fluids, rounded for items)
recipe_balance.adjust_amount = function(amount, adjustment, is_fluid)
    local adjusted = amount * adjustment

    -- Apply absolute maximum cap
    if adjusted > MAX_ABSOLUTE_AMOUNT then
        adjusted = MAX_ABSOLUTE_AMOUNT
    end

    -- For fluids, allow fractional amounts but enforce minimum
    if is_fluid then
        if adjusted < MIN_AMOUNT then
            adjusted = MIN_AMOUNT
        end
    else
        -- For items, round to nearest integer (minimum 1)
        adjusted = math.floor(adjusted + 0.5)
        if adjusted < 1 then
            adjusted = 1
        end
    end

    return adjusted
end

return recipe_balance
