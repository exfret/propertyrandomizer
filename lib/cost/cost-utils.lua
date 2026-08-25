local cutils = {}

cutils.find_amount_in_entry = function(ing_or_prod, extra_params)
    -- TODO: Implement "productivity" extra_params
    extra_params = extra_params or {}

    local amount_expected = ing_or_prod.amount
    if ing_or_prod.amount == nil then
        amount_expected = (ing_or_prod.amount_min + math.max(ing_or_prod.amount_min, ing_or_prod.amount_max)) / 2
    end

    local independent_probability = ing_or_prod.independent_probability or 1
    local shared_probability = ing_or_prod.shared_probability or {min = 0, max = 1}
    local probability = independent_probability * (shared_probability["max"] - shared_probability["min"])
    local extra_count_fraction = ing_or_prod.extra_count_fraction or 0
    return probability * (amount_expected + extra_count_fraction)
end

-- Supports material.temperature, but only for results
cutils.find_amount_in_ing_or_prod = function(ing_or_prod_list, material, extra_params)
    if type(material) ~= "table" then
        error("Actual material expected; material ID or something else passed.")
    end

    local material_type = "item"
    if material.type == "fluid" then
        material_type = "fluid"
    end

    local amount = 0

    if ing_or_prod_list ~= nil then
        for _, ing_or_prod in pairs(ing_or_prod_list) do
            if ing_or_prod.type == material_type and ing_or_prod.name == material.name then
                local matches_temperature
                if material.temperature ~= nil and material.type == "fluid" then
                    local fluid = data.raw.fluid[material.name]
                    if material.temperature == fluid.default_temperature and ing_or_prod.temperature == nil then
                        matches_temperature = true
                    elseif material.temperature == ing_or_prod.temperature then
                        matches_temperature = true
                    else
                        matches_temperature = false
                    end
                else
                    matches_temperature = true
                end
                if matches_temperature then
                    amount = amount + cutils.find_amount_in_entry(ing_or_prod, extra_params)
                end
            end
        end
    end

    return amount
end

cutils.find_amount_in_recipe = function(recipe, material, ing_overrides, use_data, extra_params)
    -- Don't count recipes which are not gotten yet; these will have just the string "blacklisted"
    if ing_overrides ~= nil and ing_overrides[recipe.name] ~= nil and ing_overrides[recipe.name][1] == "blacklisted" then
        return nil
    end
    -- If ing_overrides is non-nil but doesn't contain this recipe, it's not reachable, so also return nil here
    if ing_overrides ~= nil and ing_overrides[recipe.name] == nil then
        return nil
    end

    local ing_amount = cutils.find_amount_in_ing_or_prod(recipe.ingredients, material)

    -- Check use_data to see if we should not be paying attention to the overrides
    if ing_overrides ~= nil and ing_overrides[recipe.name] ~= nil and not use_data then
        ing_amount = 0
        for _, prereq in pairs(ing_overrides[recipe.name]) do
            if prereq.type == material.type and prereq.name == material.name then
                ing_amount = cutils.find_amount_in_entry(prereq)
            end
        end
    end

    return cutils.find_amount_in_ing_or_prod(recipe.results, material, extra_params) - ing_amount
end

return cutils