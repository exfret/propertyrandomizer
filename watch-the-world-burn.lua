local rng = require("lib/random/rng")

-- Random chance to add ingredients to recipes

for _, recipe in pairs(data.raw.recipe) do
    if recipe.ingredients ~= nil then
        for _, ing in pairs(recipe.ingredients) do
            if ing.type == "item" and ing.amount > 1 and rng.value(rng.key({id = "watch-the-world-burn"})) < 0.4 then
                table.insert(recipe.ingredients, {
                    type = "item",
                    name = ing.name,
                    amount = math.floor(ing.amount / 2)
                })
                ing.amount = ing.amount - math.floor(ing.amount / 2)
            end
        end
    end
end