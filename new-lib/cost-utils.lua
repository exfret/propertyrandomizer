local gutils = require("new-lib/graph/graph-utils")
local dutils = require("new-lib/data-utils")

local cutils = {}

-- Changes type to the base class (item or fluid)
-- Sometimes, we call this on things that already have the base class (like recipe ings), at which point it is equivalent to a gutils.key call
cutils.mat_key = function(material)
    if material.type == "fluid" then
        return gutils.key("fluid", material.name)
    end

    return gutils.key("item", material.name)
end

cutils.amount_in_entry = function(ing_or_prod)
    local amount_expected = ing_or_prod.amount
    if ing_or_prod.amount == nil then
        amount_expected = (ing_or_prod.amount_min + math.max(ing_or_prod.amount_min, ing_or_prod.amount_max)) / 2
    end

    local probability = ing_or_prod.probability or 1
    local extra_count_fraction = ing_or_prod.extra_count_fraction or 0
    return probability * (amount_expected + extra_count_fraction)
end

-- Works with material as a prototype as well
cutils.amount_in_entries = function(ing_or_prod_list, material)
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
                amount = amount + flow_cost.amount_in_entry(ing_or_prod)
            end
        end
    end

    return amount
end

-- TODO: ing_overrides/use_data refactor
cutils.amount_in = function(recipe, material)
    local ing_amount = cutils.amount_in_entries(recipe.ingredients, material)
    local prod_amount = cutils.amount_in_entries(recipe.results, material)

    return prod_amount - ing_amount
end

-- TODO: ing_overrides/use_data refactor
cutils.single_recipe_map = function(recipe, maps)
    for _, mat_property in pairs({"ingredients", "results"}) do
        for ing_or_prod in pairs(recipe[mat_property] or {}) do
            local amount = ctuils.amount_in(recipe, ing_or_prod)
            local mat_key = cutils.mat_key(ing_or_prod)
            maps.recipe[recipe.name][mat_key] = amount
            maps.material[mat_key][recipe.name] = amount
        end
    end
end

-- TODO: ing_overrides/use_data refactor
cutils.construct_maps = function()
    --[[
    local materials = {}
    for _, base_class in pairs({"item", "fluid"}) do
        for _, mat_prot in pairs(dutils.get_all_prots(base_class)) do
            
        end
    end]]
end

return cutils