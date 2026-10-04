local abilities = {}

-- Keep the elevated rail permissions with the recipes that originally unlocked the rail planner.
-- Read those recipes from effects, rather than vanilla names.
-- The caller supplies only recipes for which it will actually build a new tech.
abilities.bundle = function(technologies, rebuilt_recipes)
    local rail_recipes = {}
    local rail_effects = {}
    for _, tech in pairs(technologies) do
        local unlocks_planner = false
        for _, effect in pairs(tech.effects or {}) do
            if effect.type == "rail-planner-allow-elevated-rails" and effect.modifier == true then
                unlocks_planner = true
            end
        end
        if unlocks_planner then
            for _, effect in pairs(tech.effects or {}) do
                if effect.type == "unlock-recipe" and rebuilt_recipes[effect.recipe] ~= nil then
                    rail_recipes[effect.recipe] = true
                end
            end
        end
    end

    for _, tech in pairs(technologies) do
        local kept = {}
        for _, effect in pairs(tech.effects or {}) do
            if effect.type == "mining-with-fluid" or effect.type == "cliff-deconstruction-enabled" then
                -- These are already granted in control.lua's on_init handler.
            elseif next(rail_recipes) ~= nil and effect.modifier == true and (effect.type == "rail-planner-allow-elevated-rails" or effect.type == "rail-support-on-deep-oil-ocean") then
                rail_effects[effect.type] = effect
            else
                table.insert(kept, effect)
            end
        end
        tech.effects = kept
    end

    local recipe_effects = {}
    for recipe_name, _ in pairs(rail_recipes) do
        recipe_effects[recipe_name] = {}
        for _, effect in pairs(rail_effects) do
            table.insert(recipe_effects[recipe_name], table.deepcopy(effect))
        end
    end
    return recipe_effects
end

-- Move the two lowest researchable qualities onto every rebuilt recipe producing a module with a positive quality effect.
abilities.bundle_quality = function(technologies, rebuilt_recipes, raw, recipe_effects)
    local unlocks = {}
    for _, tech in pairs(technologies) do
        for _, effect in pairs(tech.effects or {}) do
            if effect.type == "unlock-quality" and raw.quality[effect.quality] ~= nil then
                unlocks[effect.quality] = effect
            end
        end
    end
    local qualities = {}
    for name, _ in pairs(unlocks) do
        table.insert(qualities, name)
    end
    table.sort(qualities, function(a, b)
        if raw.quality[a].level == raw.quality[b].level then
            return a < b
        end
        return raw.quality[a].level < raw.quality[b].level
    end)
    local selected = {}
    for i = 1, math.min(2, #qualities) do
        selected[qualities[i]] = true
    end
    local moved = false
    for recipe_name, _ in pairs(rebuilt_recipes) do
        local produces_quality_module = false
        for _, result in pairs(raw.recipe[recipe_name].results or {}) do
            local module = result.type == "item" and (raw.module or {})[result.name] or nil
            if module ~= nil and (module.effect.quality or 0) > 0 then
                produces_quality_module = true
            end
        end
        if produces_quality_module then
            recipe_effects[recipe_name] = recipe_effects[recipe_name] or {}
            for i = 1, math.min(2, #qualities) do
                table.insert(recipe_effects[recipe_name], table.deepcopy(unlocks[qualities[i]]))
            end
            moved = true
        end
    end
    if moved then
        for _, tech in pairs(technologies) do
            local kept = {}
            for _, effect in pairs(tech.effects or {}) do
                if effect.type ~= "unlock-quality" or selected[effect.quality] == nil then
                    table.insert(kept, effect)
                end
            end
            tech.effects = kept
        end
    end
end

return abilities
