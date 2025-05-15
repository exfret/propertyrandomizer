local dupe = {}

-- To dupe:
--   * Important recipes
--   * Crafting machines
--   * Tech unlocks (to some extent, maybe not all?)

dupe.prototype = function(prototype)
    local new_prototype = table.deepcopy(prototype)

    new_prototype.name = new_prototype.name .. "-exfret"
    -- Assume this has been fixed, if it needs to be fixed
    -- TODO: Validate this assumption
    new_prototype.localised_name = {"propertyrandomizer.dupe", flib_locale.of(prototype)}

    data:extend({
        new_prototype
    })

    return new_prototype
end

dupe.recipe = function(recipe)
    local new_recipe = dupe.prototype(recipe)

    -- I don't think recipes actually need anything extra to be duped but I'll keep this here in case I find out later that this is false

    return new_recipe
end

return dupe