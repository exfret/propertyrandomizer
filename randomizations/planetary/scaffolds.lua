-- Scaffolding for planets whose ocean fluid changed: recipe changes that keep what a planet must keep (see check.required) possible from local resources
-- Candidates are variants of the recipes a planet used its old ocean fluid for, remade with its new fluid in the same machine.
-- A plain conversion from the new fluid to the old one is also a candidate, as a last resort.
-- Only the variants on the witnesses of what each changed planet must keep stay, so only what's required to change gets a variant.
-- A needed variant whose original only that planet used becomes an edit of the original instead of a duplicate.
-- Everything else the planet did with its old fluid is lost locally, which is the actual gameplay change.
-- Machines (boilers, heat exchangers) never get duplicates, since new entities would need new graphics.

local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local planetary_check = require("randomizations/planetary/check")

local scaffolds = {}

-- Duplicate recipes kept by execute, for logging and debugging
scaffolds.kept = {}

local function unlocking_technologies(recipe_name)
    local technologies = {}
    for _, technology in pairs(data.raw.technology) do
        for _, effect in pairs(technology.effects or {}) do
            if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
                table.insert(technologies, technology.name)
            end
        end
    end
    table.sort(technologies)
    return technologies
end

-- Whether a node was reachable on a planet (in any context, or only isolatably) in the given sort
local function reachable_on(sort, node_key, planet_name, is_isolatable_only)
    local room = gutils.key("planet", planet_name)
    for context, _ in pairs(sort.sort_info.node_to_context_inds[node_key] or {}) do
        local abilities = top.context_abilities(context) or ""
        if top.context_room(context) == room and (not is_isolatable_only or string.sub(abilities, 1, 1) == "1") then
            return true
        end
    end
    return false
end

local function recipe_display_name(recipe)
    if recipe.localised_name ~= nil then
        return recipe.localised_name
    end
    return { "?", { "recipe-name." .. recipe.name }, { "item-name." .. recipe.name }, { "fluid-name." .. recipe.name }, { "entity-name." .. recipe.name }, recipe.name }
end

-- A prototype's icon layers, whether it uses icons or a single icon
local function icon_layers(prototype)
    if prototype == nil then
        return nil
    end
    if prototype.icons ~= nil then
        return table.deepcopy(prototype.icons)
    end
    if prototype.icon ~= nil then
        return {
            {
                icon = prototype.icon,
                icon_size = prototype.icon_size or 64,
            },
        }
    end
    return nil
end

-- A recipe's icon layers, falling back to its main product's icon like the game does
local function recipe_icon_layers(recipe)
    local layers = icon_layers(recipe)
    if layers ~= nil then
        return layers
    end
    for _, result in pairs(recipe.results or {}) do
        if recipe.main_product == nil or recipe.main_product == "" or recipe.main_product == result.name then
            if result.type == "fluid" then
                return icon_layers(data.raw.fluid[result.name])
            end
            return icon_layers(dutils.get_prot("item", result.name))
        end
    end
    return nil
end

-- A surface property's value on a planet or surface prototype, falling back to the property's default
local function property_value(room, property_name)
    local value = (room.surface_properties or {})[property_name]
    if value == nil then
        value = data.raw["surface-property"][property_name].default_value
    end
    return value
end

-- A surface condition only the given planet meets, or nil if there's none
-- It uses a property that existing recipes already lock recipes to planets with (most used first, like pressure), since other randomizations may change the rest (like day length); the value has to be one no other planet or surface has
local function planet_only_condition(planet_name)
    local uses = {}
    for _, recipe in pairs(data.raw.recipe) do
        for _, condition in pairs(recipe.surface_conditions or {}) do
            uses[condition.property] = (uses[condition.property] or 0) + 1
        end
    end
    local property_names = {}
    for property_name, _ in pairs(uses) do
        if data.raw["surface-property"][property_name] ~= nil then
            table.insert(property_names, property_name)
        end
    end
    table.sort(property_names, function(a, b)
        if uses[a] ~= uses[b] then
            return uses[a] > uses[b]
        end
        return a < b
    end)
    local planet = data.raw.planet[planet_name]
    for _, property_name in pairs(property_names) do
        local value = property_value(planet, property_name)
        local is_unique = true
        -- Rooms as the logic defines them (lib/lookup/1-raw.lua, built by the logic build before this runs), so the condition matches what the logic checks
        for _, room in pairs(lookups.rooms) do
            local prototype = (data.raw[room.type] or {})[room.name]
            if prototype ~= nil and prototype ~= planet and property_value(prototype, property_name) == value then
                is_unique = false
            end
        end
        if is_unique then
            return {
                property = property_name,
                min = value,
                max = value,
            }
        end
    end
    return nil
end

-- The recipe with every old_fluid ingredient made with new_fluid instead (merged into new_fluid's amount if it's already an ingredient)
-- It's a planned planet variant: named after the planet (like "Concrete (Gleba)"), with the planet's icon in its top right corner, and only makeable on that planet
local function variant_recipe(recipe, old_fluid, new_fluid, planet_name)
    local variant = table.deepcopy(recipe)
    variant.name = "propertyrandomizer-" .. recipe.name .. "-with-" .. new_fluid
    variant.localised_name = { "", recipe_display_name(recipe), " (", { "space-location-name." .. planet_name }, ")" }
    local icons = recipe_icon_layers(recipe)
    local planet_icon = icon_layers(data.raw.planet[planet_name])
    if icons ~= nil and planet_icon ~= nil then
        local badge = planet_icon[1]
        badge.scale = 16 / badge.icon_size
        badge.shift = {
            8,
            -8,
        }
        table.insert(icons, badge)
        variant.icons = icons
        variant.icon = nil
    end
    local ingredients = {}
    local new_ingredient
    for _, ingredient in pairs(variant.ingredients) do
        if ingredient.type == "fluid" and (ingredient.name == old_fluid or ingredient.name == new_fluid) then
            if new_ingredient == nil then
                new_ingredient = {
                    type = "fluid",
                    name = new_fluid,
                    amount = 0,
                }
                table.insert(ingredients, new_ingredient)
            end
            new_ingredient.amount = new_ingredient.amount + ingredient.amount
        else
            table.insert(ingredients, ingredient)
        end
    end
    variant.ingredients = ingredients
    -- A planned planet variant can only be made on its planet
    local condition = planet_only_condition(planet_name)
    if condition ~= nil then
        local conditions = table.deepcopy(variant.surface_conditions or {})
        local has_property = false
        for _, existing in pairs(conditions) do
            if existing.property == condition.property then
                has_property = true
            end
        end
        if not has_property then
            table.insert(conditions, condition)
        end
        variant.surface_conditions = conditions
    end
    return variant
end

local function conversion_recipe(old_fluid, new_fluid)
    return {
        type = "recipe",
        name = "propertyrandomizer-" .. new_fluid .. "-to-" .. old_fluid,
        localised_name = { "", { "fluid-name." .. old_fluid }, " from ", { "fluid-name." .. new_fluid } },
        categories = { "chemistry" },
        subgroup = "fluid-recipes",
        enabled = false,
        energy_required = 1,
        ingredients = {
            {
                type = "fluid",
                name = new_fluid,
                amount = 100,
            },
        },
        results = {
            {
                type = "fluid",
                name = old_fluid,
                amount = 100,
            },
        },
    }
end

-- Candidate: kind ("variant" or "conversion"), planet, recipe_name (the recipe that makes it available), prototypes to add, technologies unlocking recipe_name, and for variants the original recipe
-- before: sort of the game before the ocean swap
scaffolds.candidates = function(assignment, oceans, before)
    local candidates = {}
    for _, planet_name in pairs(oceans.planet_order) do
        local old_fluid = oceans.families[planet_name].fluid
        local new_fluid = oceans.families[assignment[planet_name]].fluid
        if old_fluid ~= new_fluid then
            local recipe_names = {}
            for recipe_name, recipe in pairs(data.raw.recipe) do
                local uses_old_fluid = false
                for _, ingredient in pairs(recipe.ingredients or {}) do
                    if ingredient.type == "fluid" and ingredient.name == old_fluid then
                        uses_old_fluid = true
                    end
                end
                -- Barreling is transport rather than a use, and a variant of it would just be a conversion in disguise
                local is_barreling = recipe.subgroup == "fill-barrel" or recipe.subgroup == "empty-barrel"
                if uses_old_fluid and not is_barreling and reachable_on(before, gutils.key("recipe", recipe_name), planet_name) then
                    table.insert(recipe_names, recipe_name)
                end
            end
            table.sort(recipe_names)
            for _, recipe_name in pairs(recipe_names) do
                local recipe = variant_recipe(data.raw.recipe[recipe_name], old_fluid, new_fluid, planet_name)
                table.insert(candidates, {
                    kind = "variant",
                    planet = planet_name,
                    original = recipe_name,
                    new_fluid = new_fluid,
                    recipe_name = recipe.name,
                    prototypes = {
                        recipe,
                    },
                    technologies = unlocking_technologies(recipe_name),
                })
            end

            -- The conversion is unlocked with the planet's discovery, so it's only a candidate when that technology exists
            local discovery_name = "planet-discovery-" .. planet_name
            if data.raw.technology[discovery_name] ~= nil then
                local conversion = conversion_recipe(old_fluid, new_fluid)
                table.insert(candidates, {
                    kind = "conversion",
                    planet = planet_name,
                    recipe_name = conversion.name,
                    prototypes = {
                        conversion,
                    },
                    technologies = {
                        discovery_name,
                    },
                })
            end
        end
    end
    return candidates
end

local function add_unlock(technology_name, recipe_name)
    local technology = data.raw.technology[technology_name]
    if technology ~= nil then
        technology.effects = technology.effects or {}
        table.insert(technology.effects, {
            type = "unlock-recipe",
            recipe = recipe_name,
        })
    end
end

local function add(candidate)
    data:extend(table.deepcopy(candidate.prototypes))
    for _, technology_name in pairs(candidate.technologies) do
        add_unlock(technology_name, candidate.recipe_name)
    end
end

local function remove_unlocks(recipe_name)
    for _, technology in pairs(data.raw.technology) do
        local effects = technology.effects or {}
        for i = #effects, 1, -1 do
            if effects[i].type == "unlock-recipe" and effects[i].recipe == recipe_name then
                table.remove(effects, i)
            end
        end
    end
end

local function remove(candidate)
    for _, prototype in pairs(candidate.prototypes) do
        data.raw[prototype.type][prototype.name] = nil
    end
    remove_unlocks(candidate.recipe_name)
end

-- Drops as much of each group as passes() allows: all of a group if that passes, or else each half in turn, down to single candidates
-- remove_fn/add_fn take a candidate out of the game and put it back; returns the candidates that had to stay
local function prune_groups(groups, passes, remove_fn, add_fn)
    local kept = {}
    local function prune(group)
        for _, candidate in pairs(group) do
            remove_fn(candidate)
        end
        if passes() then
            return
        end
        for _, candidate in pairs(group) do
            add_fn(candidate)
        end
        if #group == 1 then
            table.insert(kept, group[1])
            return
        end
        local half = math.floor(#group / 2)
        local first = {}
        local second = {}
        for i, candidate in pairs(group) do
            table.insert(i <= half and first or second, candidate)
        end
        prune(first)
        prune(second)
    end
    for _, group in pairs(groups) do
        if #group > 0 then
            prune(group)
        end
    end
    return kept
end

-- Whether a recipe was only ever reachable on the given planet in the given sort (so editing it can't cost another planet anything)
local function only_on(sort, recipe_name, planet_name)
    local room = gutils.key("planet", planet_name)
    local contexts = sort.sort_info.node_to_context_inds[gutils.key("recipe", recipe_name)] or {}
    if next(contexts) == nil then
        return false
    end
    for context, _ in pairs(contexts) do
        if top.context_room(context) ~= room then
            return false
        end
    end
    return true
end

-- The slow way, only used if the fast way's result doesn't pass: drops candidates one check (logic rebuild and sort) at a time
-- Conversions go first, so recipe variants are preferred, then variants whose original wasn't isolatable on its planet anyway, then the rest one at a time
local function prune_slowly(candidates, before, logic, variants_of)
    local function passes()
        return planetary_check.required(before, planetary_check.sort(logic), variants_of(), true)
    end
    local groups = {
        {},
        {},
    }
    for _, candidate in pairs(candidates) do
        if candidate.kind == "conversion" then
            table.insert(groups[1], candidate)
        elseif reachable_on(before, gutils.key("recipe", candidate.original), candidate.planet, true) then
            table.insert(groups, {
                candidate,
            })
        else
            table.insert(groups[2], candidate)
        end
    end
    return prune_groups(groups, passes, remove, add)
end

-- Adds scaffolding for the swap, keeping only what check.required needs; logic is the logic module (lib/logic/init), rebuilt from data.raw for each sort
-- The fast way takes three sorts: sort without scaffolding to see what the swap breaks, then with every recipe variant to keep only the variants on the witnesses (earliest-provider paths) of what broke.
-- Kept variants whose original was only ever used on that planet become edits of the original instead of duplicates; then one sort checks the result.
-- Returns original recipe name --> kept variant names, and the sort of the result
scaffolds.execute = function(assignment, oceans, logic, before)
    local candidates = scaffolds.candidates(assignment, oceans, before)
    local variants = {}
    -- Every variant each original could have, for the failures to know which variants would count as fixing them
    local all_variants_of = {}
    for _, candidate in pairs(candidates) do
        if candidate.kind == "variant" then
            table.insert(variants, candidate)
            all_variants_of[candidate.original] = all_variants_of[candidate.original] or {}
            table.insert(all_variants_of[candidate.original], candidate.recipe_name)
        end
    end
    -- Variants only count as their original while they're in the game
    local function variants_of()
        local map = {}
        for _, candidate in pairs(variants) do
            if data.raw.recipe[candidate.recipe_name] ~= nil then
                map[candidate.original] = map[candidate.original] or {}
                table.insert(map[candidate.original], candidate.recipe_name)
            end
        end
        return map
    end

    -- What the swap breaks without any scaffolding
    local without = planetary_check.sort(logic)
    local failures = planetary_check.required_failures(before, without, all_variants_of)
    if #failures == 0 then
        scaffolds.kept = {}
        log("Planetary scaffolds: none needed")
        return {}, without
    end

    -- Keep only the variants on the witnesses (earliest-provider paths) of what broke
    for _, candidate in pairs(variants) do
        add(candidate)
    end
    local with_all = planetary_check.sort(logic)
    -- A variant on a witness only counts as needed where its original can't do the same (like concrete on Gleba with imported water, which is enough when isolatability doesn't matter)
    local original_of = {}
    for _, candidate in pairs(variants) do
        original_of[gutils.key("recipe", candidate.recipe_name)] = gutils.key("recipe", candidate.original)
    end
    local nci = with_all.sort_info.node_to_context_inds
    local used = {}
    for ind, _ in pairs(top.path(with_all.graph, planetary_check.goal_inds(failures, with_all), with_all.sort_info).in_path) do
        local pebble = with_all.sort_info.sorted[ind]
        local original_key = original_of[pebble.node_key]
        if original_key ~= nil and (nci[original_key] or {})[pebble.context] == nil then
            used[pebble.node_key] = true
        end
    end
    local kept = {}
    for _, candidate in pairs(variants) do
        if used[gutils.key("recipe", candidate.recipe_name)] ~= nil then
            table.insert(kept, candidate)
        else
            remove(candidate)
        end
    end

    -- Keep one recipe where possible: an original only its planet ever used takes the new fluid itself, and the duplicate goes
    -- Others (like concrete, which Nauvis still makes with water) keep their duplicate as a planned planet variant
    local edits = {}
    scaffolds.kept = {}
    for _, candidate in pairs(kept) do
        if only_on(before, candidate.original, candidate.planet) then
            local original = data.raw.recipe[candidate.original]
            table.insert(edits, {
                candidate = candidate,
                ingredients = original.ingredients,
            })
            original.ingredients = table.deepcopy(candidate.prototypes[1].ingredients)
            remove(candidate)
        else
            table.insert(scaffolds.kept, candidate)
        end
    end

    local after = planetary_check.sort(logic)
    if planetary_check.required(before, after, variants_of(), true) then
        log("Planetary scaffolds: " .. #kept .. " of " .. #variants .. " recipe variants needed, " .. #edits .. " of them as edits of the original recipe")
        for _, edit in pairs(edits) do
            log("Planetary scaffold on " .. edit.candidate.planet .. ": " .. edit.candidate.original .. " now uses " .. edit.candidate.new_fluid)
        end
        for _, candidate in pairs(scaffolds.kept) do
            log("Planetary scaffold kept on " .. candidate.planet .. ": " .. candidate.recipe_name)
        end
        return variants_of(), after
    end

    -- The fast way missed something, so undo it and take the slow way with every candidate, conversions included
    log("Planetary scaffolds: the fast way didn't pass, so pruning one check at a time")
    for _, edit in pairs(edits) do
        data.raw.recipe[edit.candidate.original].ingredients = edit.ingredients
    end
    for _, candidate in pairs(candidates) do
        if data.raw.recipe[candidate.recipe_name] == nil then
            add(candidate)
        end
    end
    scaffolds.kept = prune_slowly(candidates, before, logic, variants_of)
    log("Planetary scaffolds: " .. #candidates .. " candidates, kept " .. #scaffolds.kept .. " (the slow way)")
    for _, candidate in pairs(scaffolds.kept) do
        log("Planetary scaffold kept on " .. candidate.planet .. ": " .. candidate.recipe_name)
    end
    return variants_of(), nil
end

return scaffolds
