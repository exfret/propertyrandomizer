-- Independent deposits (setting propertyrandomizer-independent-deposits): the names, the newness rule and the renaming back that src/randomizations/unified/deposit-copies.lua applies to the game
-- Nothing here reads data.raw or requires another module, so plain Lua can test it (tests/unit/prototypes/duplicates/test-deposit-copies.lua), and src/prototypes/data-utils.lua can read the registry without a require loop

local copies = {}

-- What the copies are, from the stage's prepare until the end of the load (nil without copies):
--   * original_of: copy name --> the name of the material it copies
--   * original_key: copy's material key ("item: <copy name>") --> the material's key ("item: iron-ore")
--   * position_planets: material key --> planet name --> true, the planets whose deposits mine it (one planet for a copy, and for a material with copies, the planet keeping it; all of them for a material without copies)
--   * mined_on: planet name --> material key --> true, what the planet's deposits mined before the copies (materials' keys, never copies')
--   * deposits: list of { planet_name, resource_name (the resource entity's name now), originals (material keys it mined before the copies) }, one per resource entity on each planet
copies.current = nil

local function key(material_type, name)
    return material_type .. ": " .. name
end
copies.key = key

-- Whether a prototype is a deposit copy (it has deposit_copy_of, set by the stage that makes it)
-- A copy is temporary: renaming it back to its material drops its prototype, so it can't take on anything of its own, like placing an entity or spoiling (handlers/entity.lua, handlers/spoiling.lua)
copies.is_copy = function(prototype)
    return prototype ~= nil and prototype.deposit_copy_of ~= nil
end

-- The copy of a material for one planet's deposits
copies.copy_name = function(material_name, planet_name)
    return "propertyrandomizer-" .. material_name .. "-from-" .. planet_name
end

-- The clone of a resource entity for one planet
copies.clone_name = function(resource_name, planet_name)
    return "propertyrandomizer-" .. resource_name .. "-deposit-on-" .. planet_name
end

-- Whether an identity at a position that deposits mine gives the position's planets something new: none of the materials their deposits mined before the copies (a copy counts as its material)
-- Another planet's copy of an ore the planet mines, or another of the planet's own materials, only relabels its deposits (user, 2026-10-06: "they must change completely, not just get permuted")
-- Keys are material keys; true for a position no deposit mines, and without copies
copies.is_new_for = function(position_key, identity_key)
    local current = copies.current
    if current == nil then
        return true
    end
    local planets = current.position_planets[position_key]
    if planets == nil then
        return true
    end
    local identity = current.original_key[identity_key] or identity_key
    for planet_name, _ in pairs(planets) do
        if (current.mined_on[planet_name] or {})[identity] ~= nil then
            return false
        end
    end
    return true
end

-- Merges the ingredients a recipe lists twice into the first of them, adding the amounts; returns whether it merged any
local function merge_ingredients(recipe)
    local ingredients = recipe.ingredients
    if type(ingredients) ~= "table" then
        return false
    end
    local first = {}
    local kept = {}
    local is_merged = false
    for _, ingredient in pairs(ingredients) do
        local ingredient_key = key(ingredient.type or "item", ingredient.name)
        local earlier = first[ingredient_key]
        if earlier == nil then
            first[ingredient_key] = ingredient
            table.insert(kept, ingredient)
        else
            earlier.amount = (earlier.amount or 0) + (ingredient.amount or 0)
            if ingredient.ignored_by_stats ~= nil then
                earlier.ignored_by_stats = (earlier.ignored_by_stats or 0) + ingredient.ignored_by_stats
            end
            is_merged = true
        end
    end
    if is_merged then
        recipe.ingredients = kept
    end
    return is_merged
end
copies.merge_ingredients = merge_ingredients

-- The mixes of copies a recipe with these materials gets variants for on a planet: lists of material key --> true, the materials it takes the planet's copies of, the first being all of them
-- Every non-empty mix up to max_full materials; past that only all of them and each one alone, since the mixes double with each material
copies.mixes = function(materials, max_full)
    local mixes = {}
    local all = {}
    for _, material_key in pairs(materials) do
        all[material_key] = true
    end
    if #materials == 0 then
        return mixes
    end
    table.insert(mixes, all)
    if #materials > max_full then
        if #materials > 1 then
            for _, material_key in pairs(materials) do
                table.insert(mixes, {
                    [material_key] = true,
                })
            end
        end
        return mixes
    end
    local num_mixes = 1
    for _ = 1, #materials do
        num_mixes = num_mixes * 2
    end
    -- Every other non-empty subset, by bits (the last one is all of them, listed first already)
    for mask = 1, num_mixes - 2 do
        local mixed = {}
        local divisor = 1
        for _, material_key in pairs(materials) do
            if math.floor(mask / divisor) % 2 == 1 then
                mixed[material_key] = true
            end
            divisor = divisor * 2
        end
        table.insert(mixes, mixed)
    end
    return mixes
end

-- A recipe's ingredients or results as one comparable string, in no particular order
local function entries_text(entries)
    local texts = {}
    for _, entry in pairs(entries or {}) do
        local fields = {}
        for field, value in pairs(entry) do
            if type(value) ~= "table" then
                table.insert(fields, tostring(field) .. "=" .. tostring(value))
            end
        end
        table.sort(fields)
        table.insert(texts, table.concat(fields, ","))
    end
    table.sort(texts)
    return table.concat(texts, ";")
end

local function categories_text(recipe)
    local categories = {}
    for _, category in pairs(recipe.categories or { recipe.category or "crafting" }) do
        table.insert(categories, category)
    end
    table.sort(categories)
    return table.concat(categories, ",")
end

-- Whether a variant does in the game exactly what its original does: the same ingredients, results, crafting categories and time (where it's made and what it's called may differ)
copies.same_recipe = function(variant, original)
    return entries_text(variant.ingredients) == entries_text(original.ingredients)
        and entries_text(variant.results) == entries_text(original.results)
        and categories_text(variant) == categories_text(original)
        and (variant.energy_required or 0.5) == (original.energy_required or 0.5)
        and variant.main_product == original.main_product
end

-- Whether other is had whenever recipe is: enabled from the start if recipe is, and otherwise unlocked by every technology unlocking recipe
-- unlocked_by: recipe name --> technology name --> true
local function had_whenever(recipe, other, unlocked_by)
    if other.enabled ~= false then
        return true
    end
    if recipe.enabled ~= false then
        return false
    end
    for technology_name, _ in pairs(unlocked_by[recipe.name] or {}) do
        if (unlocked_by[other.name] or {})[technology_name] == nil then
            return false
        end
    end
    return true
end

-- Drops the planet variants (recipes with deposit_local) that came out the same as their originals, or as another of the original's variants on that planet, once the copies are renamed back (a planet whose deposits kept their material), with the technologies' unlocks of them
-- The original is still had on that planet, so such a variant would only be a duplicate, unless it's had earlier (randomized unlocks could give the two different technologies)
-- Returns how many it dropped
copies.drop_twins = function(raw)
    -- Variant names by original and planet
    local groups = {}
    for name, recipe in pairs(raw.recipe or {}) do
        if recipe.deposit_local ~= nil then
            local group_key = recipe.deposit_local.original .. " on " .. recipe.deposit_local.planet
            groups[group_key] = groups[group_key] or {}
            table.insert(groups[group_key], name)
        end
    end
    local unlocked_by = {}
    for technology_name, technology in pairs(raw.technology or {}) do
        for _, effect in pairs(technology.effects or {}) do
            if effect.type == "unlock-recipe" then
                unlocked_by[effect.recipe] = unlocked_by[effect.recipe] or {}
                unlocked_by[effect.recipe][technology_name] = true
            end
        end
    end
    local function is_covered_by(recipe, other)
        return copies.same_recipe(recipe, other) and had_whenever(recipe, other, unlocked_by)
    end
    local twins = {}
    for _, names in pairs(groups) do
        table.sort(names)
        local kept = {}
        for _, name in pairs(names) do
            local recipe = raw.recipe[name]
            local original = raw.recipe[recipe.deposit_local.original]
            local is_twin = original ~= nil and original ~= recipe and is_covered_by(recipe, original)
            for _, kept_name in pairs(kept) do
                if is_covered_by(recipe, raw.recipe[kept_name]) then
                    is_twin = true
                end
            end
            if is_twin then
                twins[name] = true
            else
                table.insert(kept, name)
            end
        end
    end
    copies.drop_recipes(raw, twins)
    local num_dropped = 0
    for _, _ in pairs(twins) do
        num_dropped = num_dropped + 1
    end
    return num_dropped
end

-- Drops recipes from raw with the technologies' unlocks of them
-- names: recipe name --> true
copies.drop_recipes = function(raw, names)
    for name, _ in pairs(names) do
        raw.recipe[name] = nil
    end
    for _, technology in pairs(raw.technology or {}) do
        local effects = technology.effects or {}
        for i = #effects, 1, -1 do
            if effects[i].type == "unlock-recipe" and names[effects[i].recipe] ~= nil then
                table.remove(effects, i)
            end
        end
    end
end

-- What drop_recipes takes out of raw for these recipes (names: recipe name --> true), for restore_recipes: the prototypes, and the technologies' unlocks of them with their places
copies.save_recipes = function(raw, names)
    local saved = {
        recipes = {},
        unlocks = {},
    }
    for name, _ in pairs(names) do
        saved.recipes[name] = raw.recipe[name]
    end
    for technology_name, technology in pairs(raw.technology or {}) do
        for index, effect in pairs(technology.effects or {}) do
            if effect.type == "unlock-recipe" and names[effect.recipe] ~= nil then
                table.insert(saved.unlocks, {
                    technology = technology_name,
                    index = index,
                    effect = effect,
                })
            end
        end
    end
    table.sort(saved.unlocks, function(a, b)
        if a.technology ~= b.technology then
            return a.technology < b.technology
        end
        return a.index < b.index
    end)
    return saved
end

-- Puts the recipes of names that save_recipes saved back into raw after drop_recipes took them out, with their unlocks where they were
copies.restore_recipes = function(raw, saved, names)
    for name, _ in pairs(names) do
        raw.recipe[name] = saved.recipes[name]
    end
    for _, unlock in pairs(saved.unlocks) do
        local technology = (raw.technology or {})[unlock.technology]
        if names[unlock.effect.recipe] ~= nil and technology ~= nil then
            technology.effects = technology.effects or {}
            table.insert(technology.effects, math.min(unlock.index, #technology.effects + 1), unlock.effect)
        end
    end
end

-- Groups of recipes that make the same things on one planet, for choose_cuts and uncovered_cuts: a list with one group per recipe and planet, { members = names of the recipes (the original, when the planet makes it, and its versions), candidates = the members that may be cut, most worth keeping first, as { name, owes = the contexts it must leave covered } }
-- has(name, context): whether a member has the context (top.provides_context) in the sort the function works with

-- The first context a candidate owes that no member of its group outside cut has, or nil
local function first_uncovered(group, candidate, cut, has)
    for _, context in pairs(candidate.owes) do
        local is_had = false
        for _, member in pairs(group.members) do
            if not is_had and cut[member] == nil and has(member, context) then
                is_had = true
            end
        end
        if not is_had then
            return context
        end
    end
    return nil
end

-- Which recipes to cut so that a planet keeps no more versions of a recipe than it needs (user, 2026-10-10: "The goal is to reduce recipe bloat"), in a sort of the game with all of them
-- A candidate is cut when a member that stays has each context it owes; when some can't be, the first of them stays and the others are checked again, since it may have what they owe
-- The sort can't tell whether a member's contexts come through a candidate cut, so uncovered_cuts checks the cut in a sort of the game without them
-- Returns name --> true for the names cut, and name --> the first context that kept it for the candidates that stay
copies.choose_cuts = function(groups, has)
    local cut = {}
    for _, group in pairs(groups) do
        for _, candidate in pairs(group.candidates) do
            cut[candidate.name] = true
        end
    end
    local why = {}
    while true do
        local stuck
        for _, group in pairs(groups) do
            for _, candidate in pairs(group.candidates) do
                if stuck == nil and cut[candidate.name] ~= nil then
                    local context = first_uncovered(group, candidate, cut, has)
                    if context ~= nil then
                        stuck = candidate.name
                        why[stuck] = context
                    end
                end
            end
        end
        if stuck == nil then
            return cut, why
        end
        cut[stuck] = nil
    end
end

-- The candidates of cut that the members staying no longer cover in a sort of the game without the cut ones (has): name --> the first context it owes that none of them has
-- Putting those back can only add to what the game has, so the rest of the cut stays covered
copies.uncovered_cuts = function(groups, cut, has)
    local uncovered = {}
    for _, group in pairs(groups) do
        for _, candidate in pairs(group.candidates) do
            if cut[candidate.name] ~= nil then
                uncovered[candidate.name] = first_uncovered(group, candidate, cut, has)
            end
        end
    end
    return uncovered
end

-- Whether raw (a data.raw, or a copy of one) still has any of the copies' prototypes
copies.has_copies = function(raw, original_of)
    for _, prototypes in pairs(raw) do
        if type(prototypes) == "table" then
            for name, _ in pairs(original_of) do
                local prototype = prototypes[name]
                if type(prototype) == "table" and prototype.deposit_copy_of ~= nil then
                    return true
                end
            end
        end
    end
    return false
end

-- Renames the copies back to their materials in raw and drops the copies' prototypes
-- Copy names are unique (copy_name), so every string in a prototype that is one, value or key, is a reference to that copy, wherever it is: ingredients and results, mining results, spoil and burnt results, research triggers, fluid filters, ...
-- A recipe left taking a material twice (a copy and its material, or two copies of it) takes it once with the amounts added, since a recipe can't list an ingredient twice (RecipePrototype::ingredients)
-- original_of: copy name --> material name
-- Returns how many references were renamed and how many recipes had ingredients merged
copies.collapse = function(raw, original_of)
    local num_renamed = 0
    local function walk(tbl)
        local renamed_keys
        for k, v in pairs(tbl) do
            if type(v) == "string" then
                local original = original_of[v]
                if original ~= nil then
                    tbl[k] = original
                    num_renamed = num_renamed + 1
                end
            elseif type(v) == "table" then
                walk(v)
            end
            if type(k) == "string" and original_of[k] ~= nil then
                renamed_keys = renamed_keys or {}
                table.insert(renamed_keys, k)
            end
        end
        -- Keys change after the loop, since a loop can't add keys to the table it walks
        for _, k in pairs(renamed_keys or {}) do
            local original = original_of[k]
            if tbl[original] == nil then
                tbl[original] = tbl[k]
            end
            tbl[k] = nil
            num_renamed = num_renamed + 1
        end
    end
    for _, prototypes in pairs(raw) do
        if type(prototypes) == "table" then
            for name, prototype in pairs(prototypes) do
                if type(prototype) == "table" and not (original_of[name] ~= nil and prototype.deposit_copy_of ~= nil) then
                    walk(prototype)
                end
            end
        end
    end
    for _, prototypes in pairs(raw) do
        if type(prototypes) == "table" then
            for name, _ in pairs(original_of) do
                local prototype = prototypes[name]
                if type(prototype) == "table" and prototype.deposit_copy_of ~= nil then
                    prototypes[name] = nil
                end
            end
        end
    end
    local num_merged = 0
    for _, recipe in pairs(raw.recipe or {}) do
        if merge_ingredients(recipe) then
            num_merged = num_merged + 1
        end
    end
    return num_renamed, num_merged
end

return copies
