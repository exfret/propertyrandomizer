-- Local recipe variants for shared intermediates, derived from duplicated recipe ingredients.
-- No extra intermediate variants for fluids, resource/furnace products or items with placement/spoilage behavior.
local dutils = require("lib/data-utils")
local dupe = require("lib/dupe")
local furnace_selection = require("lib/furnace-selection")
local gutils = require("lib/graph/graph-utils")
local locale_utils = require("lib/locale")
local surface_sets = require("lib/surface-sets")
local locks = require("randomizations/planetary/locks")

local intermediates = {}

local function sorted_keys(set)
    local keys = {}
    for key, _ in pairs(set) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

-- Copies already made for buildings, science and other items are reused.
local function item_copies(items)
    local copies = {}
    for _, name in pairs(sorted_keys(items)) do
        local item = items[name]
        if type(item.dupe_number) == "number" and item.orig_name ~= nil then
            copies[item.dupe_number] = copies[item.dupe_number] or {}
            copies[item.dupe_number][item.orig_name] = item.name
        end
    end
    return copies
end

intermediates.plan = function(items, recipes, resources, copies, lab_inputs, furnace_pools)
    local mined = {}
    for _, resource in pairs(resources) do
        local minable = resource.minable or {}
        if minable.result ~= nil then
            mined[minable.result] = true
        end
        for _, result in pairs(minable.results or {}) do
            if result.type == nil or result.type == "item" then
                mined[result.name] = true
            end
        end
    end
    local producers = {}
    local automatic = {}
    for _, name in pairs(sorted_keys(recipes)) do
        local recipe = recipes[name]
        if recipe.orig_name == nil and recipe.hidden ~= true then
            local product = recipe.main_product
            if product == nil and #(recipe.results or {}) == 1 then
                product = recipe.results[1].name
            end
            for _, result in pairs(recipe.results or {}) do
                if result.name == product and (result.type == nil or result.type == "item") then
                    producers[product] = producers[product] or {}
                    table.insert(producers[product], recipe)
                    if #furnace_selection.pools_for(furnace_pools or {}, furnace_selection.recipe_categories(recipe)) > 0 then
                        automatic[product] = true
                    end
                end
            end
        end
    end
    local planned = {}
    for _, number in pairs(sorted_keys(copies)) do
        local selected = {}
        local visited = {}
        local function visit(name)
            if visited[name] ~= nil then
                return
            end
            visited[name] = true
            local item = items[name]
            if copies[number][name] == nil then
                if item == nil or item.hidden == true or mined[name] ~= nil or automatic[name] ~= nil or lab_inputs[name] ~= nil or producers[name] == nil
                    or (item.place_result ~= nil and item.place_result ~= "") or (item.place_as_equipment_result ~= nil and item.place_as_equipment_result ~= "")
                    or item.place_as_tile ~= nil or item.plant_result ~= nil or (item.spoil_ticks or 0) > 0 then
                    return
                end
                selected[name] = true
            end
            for _, recipe in pairs(producers[name] or {}) do
                for _, ingredient in pairs(recipe.ingredients or {}) do
                    if ingredient.type == nil or ingredient.type == "item" then
                        visit(ingredient.name)
                    end
                end
            end
        end
        for _, name in pairs(sorted_keys(recipes)) do
            local recipe = recipes[name]
            if recipe.dupe_number == number then
                for _, ingredient in pairs(recipe.ingredients or {}) do
                    if ingredient.type == nil or ingredient.type == "item" then
                        visit(ingredient.name)
                    end
                end
            end
        end
        planned[number] = selected
    end
    return planned
end

local function replace_item(filter, copies)
    if type(filter) == "string" then
        return copies[filter] or filter
    elseif type(filter) == "table" then
        filter.name = copies[filter.name] or filter.name
    end
    return filter
end

-- Keep copied prerequisites that lead to real unlocks; discard empty research dead ends.
intermediates.prune = function(technologies, trees)
    local candidates = {}
    for _, tree in pairs(trees) do
        for _, technology in pairs(tree) do
            candidates[technology.name] = true
        end
    end
    local kept = {}
    local function keep(name)
        if kept[name] ~= nil then
            return
        end
        kept[name] = true
        for _, prerequisite in pairs((technologies[name] or {}).prerequisites or {}) do
            keep(prerequisite)
        end
    end
    for name, technology in pairs(technologies) do
        if candidates[name] == nil or next(technology.effects or {}) ~= nil then
            keep(name)
        end
    end
    local removed = 0
    for _, tree in pairs(trees) do
        for original, technology in pairs(tree) do
            if kept[technology.name] == nil then
                technologies[technology.name] = nil
                tree[original] = nil
                removed = removed + 1
            end
        end
    end
    return removed
end

intermediates.execute = function()
    if next(dupe.technology_copies) == nil then
        return
    end
    local items = dutils.get_all_prots("item")
    local entities = dutils.get_all_prots("entity")
    local copies = item_copies(items)
    local planned = intermediates.plan(items, data.raw.recipe, data.raw.resource or {}, copies, dutils.lab_inputs(), furnace_selection.pools())
    local discoveries = {}
    for _, technology in pairs(data.raw.technology) do
        for _, effect in pairs(technology.effects or {}) do
            if effect.type == "unlock-space-location" then
                discoveries[effect.space_location] = technology
            end
        end
    end
    local variants = {}
    local count = 0
    for _, number in pairs(sorted_keys(planned)) do
        variants[number] = {}
        local producers = {}
        for _, name in pairs(sorted_keys(planned[number])) do
            for _, recipe in pairs(dupe.item_recipes(items[name])) do
                if recipe.orig_name == nil then
                    producers[recipe.name] = recipe
                end
            end
        end
        for _, name in pairs(sorted_keys(producers)) do
            local original = producers[name]
            local accepted = surface_sets.accepted(original)
            for _, planet_name in pairs(sorted_keys(data.raw.planet or {})) do
                local planet = data.raw.planet[planet_name]
                local room = gutils.key("planet", planet_name)
                if planet.dupe_number == number and accepted[room] ~= nil then
                    local recipe = dupe.recipe(original, {
                        suffix = "intermediate-" .. planet_name,
                        dupe_number = number,
                        home_discovery = discoveries[planet_name],
                    })
                    -- Outputs and intermediate ingredients keep their ordinary item identities.
                    -- The marker keeps the planet label when item randomization renames recipes.
                    recipe.intermediate_planet = planet_name
                    recipe.localised_name = {
                        "propertyrandomizer.recipe_planet_variant",
                        locale_utils.find_localised_name(original),
                        locale_utils.find_localised_name(planet),
                    }
                    recipe.icons = table.deepcopy(dupe.get_recipe_icons(original))
                    recipe.icon = nil
                    table.insert(recipe.icons, dupe.recipe_number_icon(number))
                    locks.fix("recipe", recipe.name, {
                        [room] = true,
                    })
                    variants[number][name] = variants[number][name] or {}
                    table.insert(variants[number][name], recipe.name)
                    count = count + 1
                end
            end
        end
    end
    if count > 0 then
        locks.realize()
    end
    -- Copies take this number's copies of their ingredients, except that what's only on a planet's branch (dupe.branch_finder) keeps the starting planet's own items unchanged
    -- This number's copy of one of those is made from copied starting planet technologies, which wait on the starting planet copy's discovery, so a planet copy would rely on that other planet just for sharing its dupe number (user, 2026-10-08), like Vulcanus 3's big mining drill on Nauvis 3's electric mining drill; randomization's recipe ingredients later take things from the planets before it
    local closure = {}
    local function needs(name)
        if closure[name] == nil then
            local needed = {}
            closure[name] = needed
            for _, prerequisite in pairs(((data.raw.technology or {})[name] or {}).prerequisites or {}) do
                needed[prerequisite] = true
                for further, _ in pairs(needs(prerequisite)) do
                    needed[further] = true
                end
            end
        end
        return closure[name]
    end
    local branch_of = dupe.branch_finder(needs)
    -- Whether a recipe of the original game is the starting planet's: enabled from the start, or unlocked by a technology on its branch
    local unlocking = {}
    for _, name in pairs(sorted_keys(data.raw.technology)) do
        local technology = data.raw.technology[name]
        if technology.dupe_number == nil then
            for _, effect in pairs(technology.effects or {}) do
                if effect.type == "unlock-recipe" then
                    unlocking[effect.recipe] = unlocking[effect.recipe] or {}
                    table.insert(unlocking[effect.recipe], name)
                end
            end
        end
    end
    local function is_start_recipe(recipe)
        if recipe.enabled ~= false then
            return true
        end
        for _, technology_name in pairs(unlocking[recipe.name] or {}) do
            if next(branch_of(technology_name)) == nil then
                return true
            end
        end
        return false
    end
    local function is_start_item(name)
        for _, recipe in pairs(items[name] ~= nil and dupe.item_recipes(items[name]) or {}) do
            if recipe.orig_name == nil and is_start_recipe(recipe) then
                return true
            end
        end
        return false
    end
    local recipe_copies = {}
    for _, recipe in pairs(data.raw.recipe) do
        local number = recipe.dupe_number
        if type(number) == "number" and recipe.orig_name ~= nil then
            recipe_copies[number] = recipe_copies[number] or {}
            if recipe.intermediate_planet == nil then
                recipe_copies[number][recipe.orig_name] = recipe.name
            end
            -- A planet's local variant is on its planet's branch
            local original = data.raw.recipe[recipe.orig_name]
            local on_start = recipe.intermediate_planet == nil and original ~= nil and is_start_recipe(original)
            for _, ingredient in pairs(recipe.ingredients or {}) do
                if (ingredient.type == nil or ingredient.type == "item") and (on_start == true or not is_start_item(ingredient.name)) then
                    ingredient.name = (copies[number] or {})[ingredient.name] or ingredient.name
                end
            end
        end
    end
    local entity_copies = {}
    for _, entity in pairs(entities) do
        if type(entity.dupe_number) == "number" and entity.orig_name ~= nil then
            entity_copies[entity.dupe_number] = entity_copies[entity.dupe_number] or {}
            entity_copies[entity.dupe_number][entity.orig_name] = entity.name
        end
    end
    for number, technologies in pairs(dupe.technology_copies) do
        for _, technology in pairs(technologies) do
            local trigger = technology.research_trigger
            if trigger ~= nil then
                -- A planet's research is triggered by its own things, so on a planet's branch the starting planet's items stay as they are, as with ingredients above
                local trigger_item = type(trigger.item) == "table" and trigger.item.name or trigger.item
                if trigger_item ~= nil and (next(branch_of(technology.orig_name or technology.name)) == nil or not is_start_item(trigger_item)) then
                    trigger.item = replace_item(trigger.item, copies[number] or {})
                end
                for index, entity in pairs(trigger.entities or {}) do
                    trigger.entities[index] = (entity_copies[number] or {})[entity] or entity
                end
            end
            local effects = {}
            local unlocked = {}
            for _, effect in pairs(technology.effects or {}) do
                if effect.type == "unlock-recipe" then
                    local replacements = (variants[number] or {})[effect.recipe] or {
                        (recipe_copies[number] or {})[effect.recipe] or effect.recipe,
                    }
                    for _, name in pairs(replacements) do
                        if unlocked[name] == nil then
                            local unlock = table.deepcopy(effect)
                            unlock.recipe = name
                            table.insert(effects, unlock)
                            unlocked[name] = true
                        end
                    end
                else
                    table.insert(effects, effect)
                end
            end
            technology.effects = effects
        end
    end
    local removed = intermediates.prune(data.raw.technology, dupe.technology_copies)
    log("Planet copies: " .. count .. " planet-local intermediate recipes added with shared products; " .. removed .. " empty research dead ends removed")
end

return intermediates
