-- Planetary resource swaps (setting propertyrandomizer-planetary-resources)
-- Each resource placement on a planet (where and how much of a resource that planet's map generates) is a slot, and resources are travelers.
-- Resources trade slots between the planets other than the starting planet, ores (mined as items) with ores and wells (mined as fluids) with wells, so each planet gets other resources exactly where its old ones were.
-- Recipes belonging to that planet follow the swap, taking what replaced a lost resource instead of it (an edit; like calcite --> the new resource's item in Vulcanus's lava recipes).
-- So do technologies belonging to that planet that are researched by mining a lost resource: they're researched by mining its replacement instead.
-- A planet that still can't make what it must (see check.required) gets a few extra patches of a lost resource back (a repair); only the repairs the logic needs are kept.
-- Everything is read from the planets' map gen settings, so planets and resources from other mods take part too.

local resource_autoplace = require("__core__/lualib/resource-autoplace")
local constants = require("helper-tables/constants")
local gutils = require("lib/graph/graph-utils")
local rng = require("lib/random/rng")
local planetary_check = require("randomizations/planetary/check")

local resources = {}

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

-- Noise names get referenced inside other expressions, so they need underscores (hyphens would parse as subtraction)
local function noise_name(...)
    local name = "propertyrandomizer_resource"
    for _, part in pairs({ ... }) do
        name = name .. "_" .. string.gsub(part, "-", "_")
    end
    return name
end

local function is_fluid_resource(resource)
    local minable = resource.minable or {}
    for _, result in pairs(minable.results or {}) do
        if result.type == "fluid" then
            return true
        end
    end
    return false
end

-- Every resource placement on the planets other than the starting planet, in a fixed order
-- A slot's probability and richness are what that planet uses for the resource: its override if it has one, or else the resource's own autoplace
resources.slots = function()
    local slots = {}
    for _, planet_name in pairs(sorted_keys(data.raw.planet)) do
        local planet = data.raw.planet[planet_name]
        local map_gen_settings = planet.map_gen_settings or {}
        local entity_settings = (map_gen_settings.autoplace_settings or {}).entity
        if planet_name ~= constants.starting_planet and entity_settings ~= nil and entity_settings.settings ~= nil then
            local overrides = map_gen_settings.property_expression_names or {}
            for _, resource_name in pairs(sorted_keys(entity_settings.settings)) do
                local resource = data.raw.resource[resource_name]
                if resource ~= nil and resource.autoplace ~= nil then
                    local slot = {
                        planet_name = planet_name,
                        resource_name = resource_name,
                        kind = is_fluid_resource(resource) and "well" or "ore",
                    }
                    local probability_override = overrides["entity:" .. resource_name .. ":probability"]
                    if probability_override ~= nil then
                        slot.probability_name = probability_override
                        slot.richness_name = overrides["entity:" .. resource_name .. ":richness"]
                    else
                        slot.probability = resource.autoplace.probability_expression
                        slot.richness = resource.autoplace.richness_expression
                        slot.local_expressions = resource.autoplace.local_expressions
                    end
                    -- A resource listed with no real placement (probability 0) isn't a place to put anything
                    if slot.probability_name ~= nil or (slot.probability ~= nil and tostring(slot.probability) ~= "0") then
                        table.insert(slots, slot)
                    end
                end
            end
        end
    end
    return slots
end

-- Slot index --> the resource now placed there; resources move only within their kind, and each one moves if it can
resources.random_assignment = function(slots, id)
    local key = rng.key({ id = id })
    local assignment = {}
    for _, kind in pairs({
        "ore",
        "well",
    }) do
        local indices = {}
        for i, slot in pairs(slots) do
            if slot.kind == kind then
                table.insert(indices, i)
            end
        end
        local travelers = {}
        for _, i in pairs(indices) do
            table.insert(travelers, slots[i].resource_name)
        end
        -- A few tries for a derangement (every resource somewhere new); the last shuffle is kept either way
        for _ = 1, 20 do
            rng.shuffle(key, travelers)
            local is_derangement = true
            for j, i in pairs(indices) do
                if travelers[j] == slots[i].resource_name then
                    is_derangement = false
                end
            end
            if is_derangement then
                break
            end
        end
        for j, i in pairs(indices) do
            assignment[i] = travelers[j]
        end
    end
    return assignment
end

-- Makes a planet place a resource with the given probability and richness noise expression names
local function place(planet_name, resource_name, probability_name, richness_name)
    local map_gen_settings = data.raw.planet[planet_name].map_gen_settings
    map_gen_settings.autoplace_settings.entity.settings[resource_name] = {}
    map_gen_settings.property_expression_names = map_gen_settings.property_expression_names or {}
    map_gen_settings.property_expression_names["entity:" .. resource_name .. ":probability"] = probability_name
    if richness_name ~= nil then
        map_gen_settings.property_expression_names["entity:" .. resource_name .. ":richness"] = richness_name
    end
end

-- Moves each slot's resource to where the assignment says, keeping each slot's placement
-- Returns planet --> set of resources it lost
resources.apply = function(slots, assignment)
    local lost = {}
    local gained = {}
    for i, slot in pairs(slots) do
        gained[slot.planet_name] = gained[slot.planet_name] or {}
        gained[slot.planet_name][assignment[i]] = true
    end
    -- Take every slot's resource out first, since resources are both slots and travelers
    for _, slot in pairs(slots) do
        data.raw.planet[slot.planet_name].map_gen_settings.autoplace_settings.entity.settings[slot.resource_name] = nil
        if gained[slot.planet_name][slot.resource_name] == nil then
            lost[slot.planet_name] = lost[slot.planet_name] or {}
            lost[slot.planet_name][slot.resource_name] = true
        end
    end
    for i, slot in pairs(slots) do
        local probability_name = slot.probability_name
        local richness_name = slot.richness_name
        if probability_name == nil then
            probability_name = noise_name(slot.planet_name, slot.resource_name, "probability")
            data:extend({
                {
                    type = "noise-expression",
                    name = probability_name,
                    expression = slot.probability,
                    local_expressions = slot.local_expressions,
                },
            })
            if slot.richness ~= nil then
                richness_name = noise_name(slot.planet_name, slot.resource_name, "richness")
                data:extend({
                    {
                        type = "noise-expression",
                        name = richness_name,
                        expression = slot.richness,
                        local_expressions = slot.local_expressions,
                    },
                })
            end
        end
        place(slot.planet_name, assignment[i], probability_name, richness_name)
    end
    return lost
end

-- An existing map gen slider for a resource, to copy for repairs (the game names resource sliders after their resource, like iron ore's)
local function resource_control_template()
    for _, control_name in pairs(sorted_keys(data.raw["autoplace-control"])) do
        if data.raw.resource[control_name] ~= nil then
            return data.raw["autoplace-control"][control_name]
        end
    end
    return nil
end

-- A repair: a few extra patches of a resource a planet lost, with their own map gen slider (a copy of an existing resource slider)
-- Ores get ordinary ore patches and wells get sparse single wells like crude oil, both with one patch near where you land
-- Returns nil if there's no resource slider to copy
resources.repair = function(planet_name, resource_name)
    local template = resource_control_template()
    if template == nil then
        return nil
    end
    local resource = data.raw.resource[resource_name]
    local control_name = "propertyrandomizer-extra-" .. planet_name .. "-" .. resource_name
    local control = table.deepcopy(template)
    control.name = control_name
    control.order = "z-" .. resource_name
    control.localised_name = { "", { "entity-name." .. resource_name }, " (+)" }
    control.localised_description = nil
    local is_fluid = is_fluid_resource(resource)
    local settings = {
        name = resource_name,
        -- The helper puts the set name into noise expressions unquoted, so it needs underscores (hyphens would parse as subtraction)
        autoplace_set_name = noise_name(planet_name),
        patch_set_name = resource_name,
        autoplace_control_name = control_name,
        order = resource.autoplace.order or "b",
        seed1 = 1000 + #sorted_keys(data.raw.resource),
    }
    if is_fluid then
        settings.base_density = 8.2
        settings.base_spots_per_km2 = 1.8
        settings.random_probability = 1 / 48
        settings.random_spot_size_minimum = 1
        settings.random_spot_size_maximum = 1
        settings.additional_richness = 220000
    else
        settings.base_density = 4
        settings.base_spots_per_km2 = 1.25
    end
    -- A planet needs what it lost from the start, so there's a patch near where you land
    settings.has_starting_area_placement = true
    return {
        planet_name = planet_name,
        resource_name = resource_name,
        control = control,
        settings = settings,
    }
end

-- Puts a repair into the game or takes it back out
resources.add_repair = function(repair)
    if data.raw["autoplace-control"][repair.control.name] == nil then
        data:extend({
            repair.control,
        })
        local autoplace = resource_autoplace.resource_autoplace_settings(repair.settings)
        repair.probability_name = noise_name(repair.planet_name, repair.resource_name, "extra", "probability")
        repair.richness_name = noise_name(repair.planet_name, repair.resource_name, "extra", "richness")
        data:extend({
            {
                type = "noise-expression",
                name = repair.probability_name,
                expression = autoplace.probability_expression,
            },
            {
                type = "noise-expression",
                name = repair.richness_name,
                expression = autoplace.richness_expression,
            },
        })
    end
    local map_gen_settings = data.raw.planet[repair.planet_name].map_gen_settings
    map_gen_settings.autoplace_controls = map_gen_settings.autoplace_controls or {}
    map_gen_settings.autoplace_controls[repair.control.name] = {}
    place(repair.planet_name, repair.resource_name, repair.probability_name, repair.richness_name)
end

resources.remove_repair = function(repair)
    local map_gen_settings = data.raw.planet[repair.planet_name].map_gen_settings
    map_gen_settings.autoplace_controls[repair.control.name] = nil
    map_gen_settings.autoplace_settings.entity.settings[repair.resource_name] = nil
    map_gen_settings.property_expression_names["entity:" .. repair.resource_name .. ":probability"] = nil
    map_gen_settings.property_expression_names["entity:" .. repair.resource_name .. ":richness"] = nil
end

-- What a resource is mined into that matters for its kind (its first fluid for a well, its first item for an ore), or nil if there's none
local function mined_product(resource)
    local product_type = is_fluid_resource(resource) and "fluid" or "item"
    local minable = resource.minable or {}
    -- Anything minable lists its products in results, or else gives a single item as result (only read without results, like lib/lookup/3-compound.lua reads it)
    local results = minable.results
    if results == nil and minable.result ~= nil then
        results = {
            {
                type = "item",
                name = minable.result,
            },
        }
    end
    for _, result in pairs(results or {}) do
        if result.type == product_type then
            return {
                type = result.type,
                name = result.name,
            }
        end
    end
    return nil
end

local function product_key(product)
    return product.type .. ":" .. product.name
end

-- The resource new to a planet that replaced a resource it lost, following the slots: the lost resource's slot holds the replacement, unless that's another of the planet's own resources, in which case its old slot holds the replacement, and so on
-- A planet's own resources trading places among themselves don't count as replacements (like Aquilo losing crude oil and gaining sulfuric acid through its crude oil --> fluorine --> lithium brine --> sulfuric acid slots)
local function replacement(assignment, planet_slot, lost_slot_index)
    local visited = {}
    local i = lost_slot_index
    while visited[i] == nil do
        visited[i] = true
        local resource_name = assignment[i]
        local next_index = planet_slot[resource_name]
        if next_index == nil then
            return resource_name
        end
        i = next_index
    end
    return nil
end

-- Planet --> (lost resource --> the resource that replaced it), for each resource a planet lost that something replaced
resources.replacements = function(slots, assignment, lost)
    -- Planet --> resource --> index of that resource's slot on the planet
    local slot_of = {}
    for i, slot in pairs(slots) do
        slot_of[slot.planet_name] = slot_of[slot.planet_name] or {}
        slot_of[slot.planet_name][slot.resource_name] = i
    end
    local replacements = {}
    for i, slot in pairs(slots) do
        if (lost[slot.planet_name] or {})[slot.resource_name] ~= nil then
            local replacement_name = replacement(assignment, slot_of[slot.planet_name], i)
            if replacement_name ~= nil then
                replacements[slot.planet_name] = replacements[slot.planet_name] or {}
                replacements[slot.planet_name][slot.resource_name] = replacement_name
            end
        end
    end
    return replacements
end

-- Planet --> (product key --> substitution), one substitution for each resource the planet lost: from what that resource was mined into, to what its replacement is mined into
resources.substitutions = function(slots, assignment, lost)
    local substitutions = {}
    local replacements = resources.replacements(slots, assignment, lost)
    for _, planet_name in pairs(sorted_keys(replacements)) do
        for _, resource_name in pairs(sorted_keys(replacements[planet_name])) do
            local from = mined_product(data.raw.resource[resource_name])
            local to = mined_product(data.raw.resource[replacements[planet_name][resource_name]])
            if from ~= nil and to ~= nil and from.name ~= to.name then
                substitutions[planet_name] = substitutions[planet_name] or {}
                substitutions[planet_name][product_key(from)] = {
                    from = from,
                    to = to,
                }
            end
        end
    end
    return substitutions
end

-- Crafting categories where the machine picks the recipe by its ingredient (furnaces, recyclers), so two recipes there can't share one
local function picked_by_ingredient_categories()
    local categories = {}
    for _, furnace in pairs(data.raw.furnace or {}) do
        for _, category in pairs(furnace.crafting_categories or {}) do
            categories[category] = true
        end
    end
    return categories
end

-- Whether another recipe in one of the recipe's picked-by-ingredient categories already takes the product
local function is_ingredient_taken(recipe, product, picked_by_ingredient)
    for _, category in pairs(recipe.categories or {}) do
        if picked_by_ingredient[category] ~= nil then
            for other_name, other in pairs(data.raw.recipe) do
                local shares_category = false
                for _, other_category in pairs(other.categories or {}) do
                    if other_category == category then
                        shares_category = true
                    end
                end
                if other_name ~= recipe.name and shares_category then
                    for _, ingredient in pairs(other.ingredients or {}) do
                        if product_key(ingredient) == product_key(product) then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end

-- The recipe's ingredients with each substitution made (merged into the new ingredient's amount if it's already an ingredient), or nil if the edit can't be made
-- It can't when the recipe makes something it would now take (a loop), or when a machine picking recipes by ingredient couldn't tell it apart from another recipe
local function substituted_ingredients(recipe, planet_substitutions, picked_by_ingredient)
    local results = {}
    for _, result in pairs(recipe.results or {}) do
        results[product_key(result)] = true
    end
    local ingredients = {}
    local by_key = {}
    local is_changed = false
    for _, ingredient in pairs(recipe.ingredients or {}) do
        local new_ingredient = table.deepcopy(ingredient)
        local substitution = planet_substitutions[product_key(ingredient)]
        if substitution ~= nil then
            if results[product_key(substitution.to)] ~= nil or is_ingredient_taken(recipe, substitution.to, picked_by_ingredient) then
                return nil
            end
            new_ingredient.name = substitution.to.name
            -- Temperature limits were about the old fluid
            new_ingredient.temperature = nil
            new_ingredient.minimum_temperature = nil
            new_ingredient.maximum_temperature = nil
            is_changed = true
        end
        local key = product_key(new_ingredient)
        if by_key[key] ~= nil then
            by_key[key].amount = by_key[key].amount + new_ingredient.amount
        else
            by_key[key] = new_ingredient
            table.insert(ingredients, new_ingredient)
        end
    end
    if not is_changed then
        return nil
    end
    return ingredients
end

-- Recipe edits: every recipe belonging to one planet (check.specific_to in the sort before) takes what replaced each resource that planet lost
-- Other planets could only make these recipes with imports, so at most they import the new ingredient instead
-- These are more than a visual change, since the new ingredient is mined differently (another drill, another amount, another spot on the map)
-- planet_recipes: planet --> set of recipes that belong to it but weren't in the sort before (like the ocean stage's planet variants)
resources.edits = function(substitutions, before, planet_recipes)
    local picked_by_ingredient = picked_by_ingredient_categories()
    local edits = {}
    for _, planet_name in pairs(sorted_keys(substitutions)) do
        for _, recipe_name in pairs(sorted_keys(data.raw.recipe)) do
            local recipe = data.raw.recipe[recipe_name]
            if planetary_check.specific_to(before, recipe_name, planet_name) or (planet_recipes[planet_name] or {})[recipe_name] ~= nil then
                local ingredients = substituted_ingredients(recipe, substitutions[planet_name], picked_by_ingredient)
                if ingredients ~= nil then
                    table.insert(edits, {
                        planet_name = planet_name,
                        recipe_name = recipe_name,
                        old_ingredients = recipe.ingredients,
                        new_ingredients = ingredients,
                    })
                end
            end
        end
    end
    return edits
end

resources.add_edit = function(edit)
    data.raw.recipe[edit.recipe_name].ingredients = table.deepcopy(edit.new_ingredients)
end

resources.remove_edit = function(edit)
    data.raw.recipe[edit.recipe_name].ingredients = table.deepcopy(edit.old_ingredients)
end

-- What an edit changed, for the log
resources.describe_edit = function(edit)
    local old_names = {}
    for _, ingredient in pairs(edit.old_ingredients) do
        table.insert(old_names, ingredient.name)
    end
    local new_names = {}
    for _, ingredient in pairs(edit.new_ingredients) do
        table.insert(new_names, ingredient.name)
    end
    return edit.recipe_name .. " on " .. edit.planet_name .. " (" .. table.concat(old_names, " + ") .. " --> " .. table.concat(new_names, " + ") .. ")"
end

-- Technology edits: a technology researched by mining a resource that only one planet had (check.node_specific_to of the resource's entity in the sort before) is researched by mining what replaced that resource there once the planet loses it, like recipe edits (like calcite processing when calcite's slot on Vulcanus now holds coal)
-- It goes by the resource rather than the technology, since the discovery rule makes a technology isolatable on later planets too (like calcite processing on Aquilo, whose home set includes Vulcanus)
-- A mining trigger lists entities, any one of which counts, so only those lost resources in it are replaced
-- Swaps keep resources within their kind (ores with ores, wells with wells), so the new resource is mined the same way as the old one
-- The replacements come from resources.replacements
resources.trigger_edits = function(replacements, before)
    local edits = {}
    for _, technology_name in pairs(sorted_keys(data.raw.technology)) do
        local trigger = data.raw.technology[technology_name].research_trigger
        if trigger ~= nil and trigger.type == "mine-entity" then
            local entities = {}
            local is_listed = {}
            local planet_names = {}
            for _, entity_name in pairs(trigger.entities or {}) do
                local new_name = entity_name
                for _, planet_name in pairs(sorted_keys(replacements)) do
                    if new_name == entity_name and replacements[planet_name][entity_name] ~= nil and planetary_check.node_specific_to(before, gutils.key("entity", entity_name), planet_name) then
                        new_name = replacements[planet_name][entity_name]
                        table.insert(planet_names, planet_name)
                    end
                end
                if is_listed[new_name] == nil then
                    is_listed[new_name] = true
                    table.insert(entities, new_name)
                end
            end
            if #planet_names > 0 then
                table.insert(edits, {
                    planet_name = table.concat(planet_names, ", "),
                    technology_name = technology_name,
                    old_entities = trigger.entities,
                    new_entities = entities,
                })
            end
        end
    end
    return edits
end

resources.add_trigger_edit = function(edit)
    data.raw.technology[edit.technology_name].research_trigger.entities = table.deepcopy(edit.new_entities)
end

resources.remove_trigger_edit = function(edit)
    data.raw.technology[edit.technology_name].research_trigger.entities = table.deepcopy(edit.old_entities)
end

-- What a technology edit changed, for the log
resources.describe_trigger_edit = function(edit)
    return edit.technology_name .. " on " .. edit.planet_name .. " (mine " .. table.concat(edit.old_entities, " or ") .. " --> mine " .. table.concat(edit.new_entities, " or ") .. ")"
end

-- Returns the slots, assignment and planet --> set of lost resources
resources.execute = function(id)
    local slots = resources.slots()
    local assignment = resources.random_assignment(slots, id)
    local moves = {}
    for i, slot in pairs(slots) do
        table.insert(moves, slot.planet_name .. " " .. slot.resource_name .. " <-- " .. assignment[i])
    end
    log("Planetary resources (planet slot <-- resource): " .. table.concat(moves, ", "))
    local lost = resources.apply(slots, assignment)
    return slots, assignment, lost
end

return resources
