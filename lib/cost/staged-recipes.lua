-- Recipe prototypes for costing a partial randomization, including its generated reverse recipes.
local recycling = require("lib/recycling")

local staged_recipes = {}

local function copy(tbl)
    local result = {}
    for key, value in pairs(tbl) do
        result[key] = value
    end
    return result
end

staged_recipes.new = function(raw, overrides)
    local recipes = copy(raw.recipe)
    local virtual_raw = copy(raw)
    virtual_raw.recipe = recipes
    local generated = recycling.vanilla(raw)
    local affected = {}
    local function pending(name)
        return name ~= nil and overrides[name] ~= nil and overrides[name][1] == "blacklisted"
    end
    for name, entry in pairs(generated) do
        if entry.source ~= nil and entry.reversed ~= nil then
            for _, source in pairs({entry.source, entry.reversed}) do
                affected[source] = affected[source] or {}
                affected[source][name] = true
            end
            -- A future recipe's original recycling outputs are not a valid source of its old ingredients.
            if pending(entry.source) or pending(entry.reversed) then
                overrides[name] = {"blacklisted"}
            end
        end
    end
    local world = {recipes = recipes}
    world.update = function(name)
        local recipe = copy(recipes[name])
        recipe.ingredients = overrides[name]
        recipes[name] = recipe
        local updated = {recipe}
        local reverse_names = {}
        for reverse_name, _ in pairs(affected[name] or {}) do
            table.insert(reverse_names, reverse_name)
        end
        table.sort(reverse_names)
        for _, reverse_name in pairs(reverse_names) do
            local entry = generated[reverse_name]
            if not pending(entry.source) and not pending(entry.reversed) then
                local reverse = recycling.recipe_from_source(virtual_raw, recipes[entry.source])
                if reverse ~= nil then
                    reverse.name = reverse_name
                    recipes[reverse_name] = reverse
                    overrides[reverse_name] = reverse.ingredients
                    table.insert(updated, reverse)
                end
            end
        end
        return updated
    end
    return world
end

return staged_recipes
