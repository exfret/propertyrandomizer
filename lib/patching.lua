local patching = {}

patching.replace_ing_or_result = function(ing_or_prod_list, old_mat_type, old_mat_name, new_ing_or_prod)
    for _, ing_or_prod in pairs(ing_or_prod_list) do
        if ing_or_prod.type == old_mat_type and ing_or_prod.name == old_mat_name then
            -- Clear old keys
            for key, _ in pairs(ing_or_prod) do
                ing_or_prod[key] = nil
            end
            -- Add new vals
            for key, val in pairs(new_ing_or_prod) do
                ing_or_prod[key] = val
            end
        end
    end
end

patching.remove_recipe_unlock = function(technology, recipe_name)
    if technology.effects ~= nil then
        local ind_to_remove
        for ind, effect in pairs(technology.effects) do
            if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
                ind_to_remove = ind
            end
        end
        table.remove(technology.effects, ind_to_remove)
    end
end

return patching