local gutils = require("new-lib/graph/graph-utils")

local recipe_categories = {}

-- Build lookup of recipes used as fixed_recipe on entities (can't change category)
local _fixed_recipes = nil
local function get_fixed_recipes()
    if _fixed_recipes then return _fixed_recipes end
    _fixed_recipes = {}
    for _, class in pairs({"assembling-machine", "furnace", "rocket-silo"}) do
        for _, entity in pairs(data.raw[class] or {}) do
            if entity.fixed_recipe then
                _fixed_recipes[entity.fixed_recipe] = entity.name
            end
        end
    end
    return _fixed_recipes
end

-- Claim edges from recipe-category to recipe
-- Categories are unlimited - any number of recipes can use the same category
-- Return extra copies to expand the pool
recipe_categories.claim = function(graph, prereq, dep, trav)
    if prereq.type == "recipe-category" and dep.type == "recipe" then
        local recipe = data.raw.recipe[dep.name]
        if recipe then
            local category = recipe.category or "crafting"
            -- Skip hidden recipes
            if recipe.hidden then
                return 0
            end
        end
        return 1  -- Categories can be shared, add copies for flexibility
    end
end

-- Validate: check that the slot's recipe-category is compatible with the recipe
-- The slot is a recipe-category (spoofed with fluid counts), traveler is a recipe
-- We need to ensure the fluid counts are compatible
recipe_categories.validate = function(graph, slot, trav, extra)
    local slot_owner = gutils.get_conn_owner(graph, slot)
    local trav_owner = gutils.get_conn_owner(graph, trav)

    if slot_owner.type ~= "recipe-category" then
        return false
    end

    -- Parse the slot's rcat_name: "category|input_fluids|output_fluids"
    -- The traveler needs this category to have at least as many fluid connections
    -- as the recipe requires

    -- Get the traveler's required fluid counts from its original rcat_name
    local recipe = data.raw.recipe[trav_owner.name]
    if not recipe then
        return false
    end

    local category = recipe.category or "crafting"

    -- Skip hidden recipes
    if recipe.hidden then
        return false
    end

    -- TODO: This just shouldn't be claimed in the first place
    -- Check if recipe is used as fixed_recipe - if so, only allow same category
    local fixed_recipes = get_fixed_recipes()
    if fixed_recipes[trav_owner.name] then
        -- Recipe is fixed on an entity - don't change its category
        -- Only allow if slot category matches original
        local original_cat = recipe.category or "crafting"
        local parts = {}
        local pos = 1
        local name = slot_owner.name
        -- TODO: Fix this so it finds the input and output fluids correctly
        while pos <= #name do
            local sep_start, sep_end = string.find(name, "__", pos, true)
            if sep_start then
                table.insert(parts, string.sub(name, pos, sep_start - 1))
                pos = sep_end + 1
            else
                table.insert(parts, string.sub(name, pos))
                break
            end
        end
        if #parts >= 1 and parts[1] ~= original_cat then
            return false  -- Don't change category of fixed_recipe
        end
    end

    -- TODO: Use proper helper function for this purpose
    -- Count fluids in recipe ingredients and results
    local recipe_input_fluids = 0
    local recipe_output_fluids = 0

    if recipe.ingredients then
        for _, ing in pairs(recipe.ingredients) do
            if ing.type == "fluid" then
                recipe_input_fluids = recipe_input_fluids + 1
            end
        end
    end

    if recipe.results then
        for _, result in pairs(recipe.results) do
            local result_type = result.type or "item"
            if result_type == "fluid" then
                recipe_output_fluids = recipe_output_fluids + 1
            end
        end
    end

    -- TODO: Just get this directly and properly
    -- Parse the slot's rcat_name to get available fluid counts
    -- Format: "category__input__output" (separator is __)
    -- Use pattern that splits on __ (double underscore)
    local parts = {}
    local pos = 1
    local name = slot_owner.name
    while pos <= #name do
        local sep_start, sep_end = string.find(name, "__", pos, true)
        if sep_start then
            table.insert(parts, string.sub(name, pos, sep_start - 1))
            pos = sep_end + 1
        else
            table.insert(parts, string.sub(name, pos))
            break
        end
    end

    if #parts < 3 then
        -- Invalid format, reject
        return false
    end

    local slot_input_fluids = tonumber(parts[#parts - 1]) or 0
    local slot_output_fluids = tonumber(parts[#parts]) or 0

    -- Slot must have at least as many fluid connections as recipe needs
    if slot_input_fluids < recipe_input_fluids then
        return false
    end
    if slot_output_fluids < recipe_output_fluids then
        return false
    end

    return true
end

-- Apply recipe category changes to data.raw
recipe_categories.reflect = function(graph, trav_to_new_slot, trav_to_old_slot)
    for trav_key, slot in pairs(trav_to_new_slot) do
        local trav = graph.nodes[trav_key]
        local trav_owner = gutils.get_conn_owner(graph, trav)
        local slot_owner = gutils.get_conn_owner(graph, slot)

        -- Only process our edge type
        if trav_owner.type == "recipe" and slot_owner.type == "recipe-category" then
            local recipe_name = trav_owner.name
            local rcat_name = slot_owner.name

            -- TODO: Get rcat_name properly
            -- Parse category from rcat_name (format: "category__input__output")
            -- Split on __ (double underscore)
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

            if #parts >= 3 then
                -- Category is the first part (before fluid counts)
                local category = parts[1]

                local recipe = data.raw.recipe[recipe_name]
                if recipe then
                    recipe.category = category
                    log("Changed recipe " .. recipe_name .. " to category " .. category)
                end
            end
        end
    end
end

return recipe_categories
