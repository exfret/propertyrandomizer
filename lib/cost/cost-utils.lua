local cutils = {}

cutils.find_amount_in_entry = function(ing_or_prod)
    local amount_expected = ing_or_prod.amount
    if ing_or_prod.amount == nil then
        amount_expected = (ing_or_prod.amount_min + math.max(ing_or_prod.amount_min, ing_or_prod.amount_max)) / 2
    end

    local probability = ing_or_prod.probability or 1
    local extra_count_fraction = ing_or_prod.extra_count_fraction or 0
    return probability * (amount_expected + extra_count_fraction)
end

cutils.find_amount_in_ing_or_prod = function(ing_or_prod_list, material)
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
                amount = amount + cutils.find_amount_in_entry(ing_or_prod)
            end
        end
    end

    return amount
end

cutils.find_amount_in_recipe = function(recipe, material, ing_overrides, use_data)
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

    return cutils.find_amount_in_ing_or_prod(recipe.results, material) - ing_amount
end

return cutils