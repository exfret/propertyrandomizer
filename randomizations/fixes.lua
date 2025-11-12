-- File for any last-minute fixes in the randomization process that may be needed

local locale_utils = require("lib/locale")

randomizations.fixes = function()
    -- Fix electric pole supply area to be at least as large as distribution range
    --[[ only a RATIONAL INDIVIDUAL would resort to such PRACTICAL CONVENIENCE in the face of ANGUISH AND TURMOIL
    for _, electric_pole in pairs(data.raw["electric-pole"]) do
        if electric_pole.maximum_wire_distance == nil then
            electric_pole.maximum_wire_distance = 0
        end

        electric_pole.maximum_wire_distance = math.min(64, math.max(electric_pole.maximum_wire_distance, 2 * electric_pole.supply_area_distance))
    end
    ]]

    -- Add the placeable entity/etc.'s localised description to every item so stats show up all at once
    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                if item.localised_description ~= nil then
                    if item.place_result ~= nil then
                        -- Get the entity
                        local entity
                        for entity_class, _ in pairs(defines.prototypes.entity) do
                            if data.raw[entity_class] ~= nil then
                                if data.raw[entity_class][item.place_result] ~= nil then
                                    entity = data.raw[entity_class][item.place_result]
                                end
                            end
                        end
                        local desc = locale_utils.find_localised_description(entity, {with_newline = true})
                        item.localised_description = {"", desc, item.localised_description}
                    end
                    if item.place_as_equipment_result ~= nil then
                        -- Get the equipment
                        local equipment
                        for equipment_class, _ in pairs(defines.prototypes.equipment) do
                            if data.raw[equipment_class] ~= nil then
                                if data.raw[equipment_class][item.place_as_equipment_result] ~= nil then
                                    equipment = data.raw[equipment_class][item.place_as_equipment_result]
                                end
                            end
                        end
                        local desc = locale_utils.find_localised_description(equipment, {with_newline = true})
                        item.localised_description = {"", desc, item.localised_description}
                    end
                    if item.place_as_tile ~= nil then
                        local tile = data.raw.tile[item.place_as_tile.result]
                        local desc = locale_utils.find_localised_description(tile, {with_newline = true})
                        item.localised_description = {"", desc, item.localised_description}
                    end
                end
            end
        end
    end

    -- Remove duplicate ingredients (needed for watch the world burn mode)

    for _, recipe in pairs(data.raw.recipe) do
        if recipe.ingredients ~= nil then
            local item_ing_seen = {}
            local new_ings = {}
            for _, ing in pairs(recipe.ingredients) do
                if ing.type ~= "item" or not item_ing_seen[ing.name] then
                    item_ing_seen[ing.name] = true
                    table.insert(new_ings, ing)
                else
                    for _, new_ing in pairs(new_ings) do
                        if new_ing.type == "item" and new_ing.name == ing.name then
                            new_ing.amount = new_ing.amount + ing.amount
                        end
                    end
                end
            end
            recipe.ingredients = new_ings
        end
    end

    -- Delimit belt stack size so that the upgrade research can take it past 4
    local uint8_max = 255
    for _, inserter in pairs(data.raw.inserter) do
        if inserter.max_belt_stack_size ~= nil and inserter.max_belt_stack_size > 1 then
            inserter.max_belt_stack_size = uint8_max
        end
    end
    data.raw["utility-constants"].default.max_belt_stack_size = uint8_max

    ----------------------------------------------------------------------
    -- Fix recycling recipes
    ----------------------------------------------------------------------

    -- First, some constants
    local recycling_category_name = "recycling"
    local type_item = "item"

    -- Create lookup table for recycling recipes
    local item_to_recycling_recipe = {}
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.category == recycling_category_name and recipe.ingredients ~= nil and #recipe.ingredients == 1 then
            item_to_recycling_recipe[recipe.ingredients[1].name] = recipe
        end
    end

    -- A little helper function
    local amount_expected_value = function (product_or_ingredient)
        local expected_value = product_or_ingredient.amount
        if product_or_ingredient.amount == nil then
            local amount_max = product_or_ingredient.amount_max
            if product_or_ingredient.amount_max < product_or_ingredient.amount_min then
                amount_max = product_or_ingredient.amount_min
            end
            expected_value = (product_or_ingredient.amount_min + amount_max) / 2
        end
        if product_or_ingredient.extra_count_fraction ~= nil then
            expected_value = expected_value + product_or_ingredient.extra_count_fraction
        end
        if product_or_ingredient.ignored_by_stats ~= nil then
            expected_value = expected_value - product_or_ingredient.ignored_by_stats
        end
        if product_or_ingredient.probability ~= nil then
            expected_value = expected_value * product_or_ingredient.probability
        end
        return expected_value
    end

    -- Define some lists to define what recipes recyclers can reverse
    local reversible_category_blacklist = {
        ["recycling"] = true,
        ["smelting"] = true,
        ["chemistry-or-cryogenics"] = true,
        ["crushing"] = true,
        ["metallurgy"] = true,
        ["organic"] = true,
        ["cryogenics"] = true,
    }
    local reversible_subgroup_blacklist = {
        ["empty-barrel"] = true,
    }
    local reversible_name_blacklist = {
        ["tungsten-carbide"] = true,
        ["superconductor"] = true,
        ["biolab"] = true,
    }
    local reversible_name_keyword_blacklist = {
        "science", "pack"
    }
    local reverisble_name_exceptions = {
        ["battery"] = true,
        ["big-mining-drill"] = true,
        ["turbo-transport-belt"] = true,
        ["turbo-underground-belt"] = true,
        ["turbo-splitter"] = true,
        ["railgun-turret"] = true,
        ["railgun"] = true,
        ["cryogenic-plant"] = true,
        ["fusion-reactor"] = true,
        ["fusion-generator"] = true,
    }

    local default_can_recycle = function(recipe)
        if reverisble_name_exceptions[recipe.name] then return true end
        if recipe.auto_recycle == false then return false end
        if reversible_category_blacklist[recipe.category] then return false end
        if reversible_subgroup_blacklist[recipe.subgroup] then return false end
        if reversible_name_blacklist[recipe.name] then return false end
        local match = true
        for _, keyword in pairs(reversible_name_keyword_blacklist) do
            if not string.find(recipe.name, keyword) then
                match = false
            end
        end
        if match then return false end
        return true
    end

    -- Go through all recipes looking for reversible ones to modify recycling recipes based on
    local reversed_items = {}
    for _, recipe in pairs(data.raw.recipe) do
        -- Use rules defined by quality mod to decide if a recipe is worth considering, also exclude recipes without results or ingredients
        if default_can_recycle(recipe) and recipe.results ~= nil and recipe.ingredients ~= nil then
            local elegible_recipe = true
            -- Check the recipe products to see if it's elegible for reversing into a recycling recipe
            local elegible_results = {}
            for _, product in pairs(recipe.results) do
                if product.type == type_item and amount_expected_value(product) > 0 then
                    elegible_results[#elegible_results+1] = product
                end
                -- Recycling recipes don't take fluids as ingredients
                if product.type ~= type_item and amount_expected_value(product) > 0 then
                    elegible_recipe = false
                end
            end
            local elegible_ingredients = {}
            -- Check the ingredients to see if any can be the product of recycling
            for _, ingredient in pairs(recipe.ingredients) do
                -- Fluid ingredients don't affect anything, so ignore
                if ingredient.type == type_item
                and (ingredient.ignored_by_stats == nil or ingredient.ignored_by_stats < ingredient.amount) then
                    elegible_ingredients[#elegible_ingredients+1] = ingredient
                end
            end
            -- Recycling recipes always have 1 ingredient and at least one product
            if #elegible_results ~= 1 or #elegible_ingredients < 1 then
                elegible_recipe = false
            end
            if elegible_recipe then
                local product = elegible_results[1]
                -- Find the corresponding recycling recipe that has this product as ingredient
                local recycling_recipe = item_to_recycling_recipe[product.name]
                if recycling_recipe ~= nil then
                    -- Find out how many products to account for
                    -- Adjust in case of increased maximum_productivity
                    local max_productivity_factor = 4
                    if recipe.maximum_productivity ~= nil then
                        max_productivity_factor = 1 + recipe.maximum_productivity
                    end
                    local max_products = amount_expected_value(product) * max_productivity_factor
                    local recycling_yield_factor = 1 / max_products
                    -- Create new set of recycling results
                    local new_recycling_results = {}
                    for _, ingredient in pairs(elegible_ingredients) do
                        local recycle_product_yield = amount_expected_value(ingredient) * recycling_yield_factor
                        local consistent_amount = math.floor(recycle_product_yield)
                        local extra_count_fraction = recycle_product_yield - consistent_amount
                        local new_recycling_result = {
                            type = type_item,
                            name = ingredient.name,
                        }
                        -- Define probability instead of extra_count_fraction if amount is low. Looks nicer in-game
                        if consistent_amount < 1 then
                            new_recycling_result.amount = 1
                            new_recycling_result.probability = extra_count_fraction
                        else
                            new_recycling_result.amount = consistent_amount
                            new_recycling_result.extra_count_fraction = extra_count_fraction
                        end
                        new_recycling_results[#new_recycling_results+1] = new_recycling_result
                    end
                    recycling_recipe.results = new_recycling_results
                    -- Also remove main product, because that sometimes needs to be fixed for some reason
                    recycling_recipe.main_product = nil
                    -- Remove number from recycling recipe name
                    recycling_recipe.show_amount_in_title = false
                    -- Keep track of what items we have fixed the recycling recipes for
                    reversed_items[product.name] = true
                end
            end
        end
    end

    -- Go through all items to look for items that weren't reversible
    for class_name, _ in pairs(defines.prototypes.item) do
        if data.raw[class_name] ~= nil then
            for _, item in pairs(data.raw[class_name]) do
                if reversed_items[item.name] == nil then
                    local recycling_recipe = item_to_recycling_recipe[item.name]
                    if recycling_recipe ~= nil then
                        -- Create new set of recycling results only containing 25% chance of getting the sole ingredient back
                        recycling_recipe.results = {
                            {
                                type = type_item,
                                name = item.name,
                                amount = 1,
                                probability = 1 / 4,
                                ignored_by_stats = 1,
                            },
                        }
                        -- Also remove main product, because that sometimes needs to be fixed for some reason
                        recycling_recipe.main_product = nil
                        -- Remove number from recycling recipe name
                        recycling_recipe.show_amount_in_title = false
                    end
                end
            end
        end
    end
end