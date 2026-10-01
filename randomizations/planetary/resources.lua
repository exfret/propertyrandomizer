-- Planetary resource swaps (setting propertyrandomizer-planetary-resources)
-- Each resource placement on a planet (where and how much of a resource that planet's map generates) is a slot, and resources are travelers.
-- Resources trade slots between all the planets, the starting planet included, ores (mined as items) with ores and wells (mined as fluids) with wells, so each planet gets other resources exactly where its old ones were.
-- The starting planet keeps what its early game and its own science need through the extra patches (a planet's repairs put a patch near where you land), so it can start with tungsten in its iron's footprint and an iron patch beside the crash site.
-- In superposed mode the starting planet stays out: without extra patches up front, a start without its ores would be a whole-game debt the rest of randomization can't pay (see the Gleba start experiment in randomizations/planetary/execute.lua).
-- Recipes belonging to that planet follow the swap, taking what replaced a lost resource instead of it (an edit; like calcite --> the new resource's item in Vulcanus's lava recipes).
-- A recipe other planets make too (like copper plate, or anything a planet shares with its copies, lib/dupe-planets.lua) can't follow the swap in place, so each planet that made it from its own resources and lost one of them gets a planned variant of its own instead, like "Copper plate (Nauvis 2)" taking what replaced copper ore there, locked to that planet; the original stays for the planets that kept the resource or import it.
-- So do technologies belonging to that planet that are researched by mining a lost resource: they're researched by mining its replacement instead.
-- A planet that still can't make what it must (see check.required) gets a few extra patches of a lost resource back (a repair); only the repairs the logic needs are kept.
-- Everything is read from the planets' map gen settings, so planets and resources from other mods take part too.

local resource_autoplace = require("__core__/lualib/resource-autoplace")
local constants = require("helper-tables/constants")
local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local rng = require("lib/random/rng")
local planetary_check = require("randomizations/planetary/check")
local locks = require("randomizations/planetary/locks")
local scaffolds = require("randomizations/planetary/scaffolds")
local surface_sets = require("lib/surface-sets")

local resources = {}

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

-- Which run of the resource stage this is (resources.execute counts them): the extra patches' autoplace sets are named per run, so the game's resource-autoplace helper, which remembers every set it made for the rest of the load, never meets a set from a run whose data.raw was put back (a failed fast run before the careful one, or a rolled-again attempt): a remembered set's patch counts live in noise expressions that the put-back data.raw no longer has, and a count of zero divides by zero when the planet generates (an inf crash in the game's spot noise)
resources.run = 0
-- Autoplace set names whose expressions this run made, to notice a set meeting a put-back data.raw all the same
local sets_made = {}

-- Every extra patch slider made so far, as control name --> planet name, for counting the patches the game ends up with (resources.log_extra_patches)
resources.repair_controls = {}
-- How many planets the latest resource swap worked on, or nil before any
resources.num_planets = nil

-- The two patch counts the helper keeps per autoplace set, as noise expressions named after the set
local count_suffixes = {
    "_regular_resource_patch_set_count",
    "_starting_resource_patch_set_count",
}

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

-- Every resource placement on the planets (the starting planet's too, except in superposed mode), in a fixed order
-- A slot's probability and richness are what that planet uses for the resource: its override if it has one, or else the resource's own autoplace
resources.slots = function()
    local slots = {}
    for _, planet_name in pairs(sorted_keys(data.raw.planet)) do
        local planet = data.raw.planet[planet_name]
        local map_gen_settings = planet.map_gen_settings or {}
        local entity_settings = (map_gen_settings.autoplace_settings or {}).entity
        local is_start_kept_out = planet_name == constants.starting_planet and config.planetary_superposed
        if not is_start_kept_out and entity_settings ~= nil and entity_settings.settings ~= nil then
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

-- Whether a slot's resource has patches in the starting area: the game's resource-autoplace helper (core/lualib/resource-autoplace.lua) writes has_starting_area_placement = 1 into the patches expression a resource's probability reads
-- Follows the slot's probability (its planet's override, or the resource's own) one var() deep; placements written some other way don't count
resources.in_starting_area = function(slot)
    local expression = slot.probability
    if slot.probability_name ~= nil then
        local named = data.raw["noise-expression"][slot.probability_name]
        expression = named and named.expression
    end
    if type(expression) ~= "string" then
        return false
    end
    for name in string.gmatch(expression, "var%('([^']+)'%)") do
        local patches = data.raw["noise-expression"][name]
        if patches ~= nil and type(patches.expression) == "string" and string.find(patches.expression, "has_starting_area_placement = 1", 1, true) ~= nil then
            return true
        end
    end
    return false
end

-- Slot index --> the resource now placed there; resources move only within their kind, and each one moves if it can
-- The starting planet keeps its starting area's resources and its wells (user, 2026-10-01, like it keeps its ocean's fluid): everything after its first minutes is made from them (crude oil has no starting area patches but is as basic), and losing them broke the other planets too through the recipes they share
resources.random_assignment = function(slots, id)
    local key = rng.key({ id = id })
    local assignment = {}
    local kept = {}
    for i, slot in pairs(slots) do
        if slot.planet_name == constants.starting_planet and (resources.in_starting_area(slot) or slot.kind == "well") then
            assignment[i] = slot.resource_name
            table.insert(kept, slot.resource_name)
        end
    end
    if #kept > 0 then
        log("Planetary resources: the starting planet keeps its starting area's resources and its wells: " .. table.concat(kept, ", "))
    end
    for _, kind in pairs({
        "ore",
        "well",
    }) do
        local indices = {}
        for i, slot in pairs(slots) do
            if slot.kind == kind and assignment[i] == nil then
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
    resources.repair_controls[control_name] = planet_name
    local control = table.deepcopy(template)
    control.name = control_name
    control.order = "z-" .. resource_name
    control.localised_name = { "", { "entity-name." .. resource_name }, " (+)" }
    control.localised_description = nil
    local is_fluid = is_fluid_resource(resource)
    local settings = {
        name = resource_name,
        -- The helper puts the set name into noise expressions unquoted, so it needs underscores (hyphens would parse as subtraction); one set per planet and run (see resources.run)
        autoplace_set_name = noise_name(planet_name, "run" .. tostring(resources.run)),
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
        -- A set this load made whose count expressions are gone met a put-back data.raw: a fresh set keeps the helper's memory of the old one out of the way
        local set_name = repair.settings.autoplace_set_name
        if sets_made[set_name] ~= nil and data.raw["noise-expression"][set_name .. "_regular_resource_patch_set_count"] == nil then
            resources.run = resources.run + 1
            set_name = noise_name(repair.planet_name, "run" .. tostring(resources.run))
            repair.settings.autoplace_set_name = set_name
        end
        sets_made[set_name] = true
        local autoplace = resource_autoplace.resource_autoplace_settings(repair.settings)
        -- The set's patch counts must be at least one, or the planet can't generate (see resources.run)
        for _, suffix in pairs(count_suffixes) do
            local count = data.raw["noise-expression"][set_name .. suffix]
            if count == nil or type(count.expression) ~= "number" or count.expression < 1 then
                error("Planetary resources: the autoplace set " .. set_name .. " has no patch count for " .. repair.resource_name)
            end
        end
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
    -- Planet --> kind --> the resources new to it of that kind, sorted (for a lost resource whose slots lead back to the planet's own resources)
    local new_of_kind = {}
    for i, slot in pairs(slots) do
        local name = assignment[i]
        if slot_of[slot.planet_name][name] == nil then
            new_of_kind[slot.planet_name] = new_of_kind[slot.planet_name] or {}
            new_of_kind[slot.planet_name][slot.kind] = new_of_kind[slot.planet_name][slot.kind] or {}
            new_of_kind[slot.planet_name][slot.kind][name] = true
        end
    end
    local replacements = {}
    for i, slot in pairs(slots) do
        if (lost[slot.planet_name] or {})[slot.resource_name] ~= nil then
            local replacement_name = replacement(assignment, slot_of[slot.planet_name], i)
            -- The lost resource's slots can lead back to the planet's own resources (its tungsten slot holding the coal it already had), so none of them is new: then the first new resource of the same kind the planet gained takes its place in recipes, if there's one
            if replacement_name == nil then
                replacement_name = sorted_keys((new_of_kind[slot.planet_name] or {})[slot.kind] or {})[1]
            end
            if replacement_name ~= nil then
                replacements[slot.planet_name] = replacements[slot.planet_name] or {}
                replacements[slot.planet_name][slot.resource_name] = replacement_name
            end
        end
    end
    return replacements
end

-- Planet --> (product key --> substitution), one substitution for each resource the planet lost: from what that resource was mined into, to what its replacement is mined into
-- Also returns planet --> list of what each resource new to the planet is mined into (sorted), the alternatives when a machine picking recipes by ingredient already has a recipe taking the replacement
resources.substitutions = function(slots, assignment, lost)
    local substitutions = {}
    local replacements = resources.replacements(slots, assignment, lost)
    local own = {}
    for _, slot in pairs(slots) do
        own[slot.planet_name] = own[slot.planet_name] or {}
        own[slot.planet_name][slot.resource_name] = true
    end
    local alternates = {}
    local listed = {}
    for i, slot in pairs(slots) do
        local name = assignment[i]
        if own[slot.planet_name][name] == nil then
            local product = mined_product(data.raw.resource[name])
            listed[slot.planet_name] = listed[slot.planet_name] or {}
            if product ~= nil and listed[slot.planet_name][product_key(product)] == nil then
                listed[slot.planet_name][product_key(product)] = true
                alternates[slot.planet_name] = alternates[slot.planet_name] or {}
                table.insert(alternates[slot.planet_name], product)
            end
        end
    end
    for _, products in pairs(alternates) do
        table.sort(products, function(a, b)
            return product_key(a) < product_key(b)
        end)
    end
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
    return substitutions, alternates
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

-- Whether another recipe in one of the recipe's picked-by-ingredient categories already takes the product, or an edit or variant planned in the same pass does (claimed: category --> product key --> true)
local function is_ingredient_taken(recipe, product, picked_by_ingredient, claimed)
    for _, category in pairs(recipe.categories or {}) do
        if picked_by_ingredient[category] ~= nil and ((claimed or {})[category] or {})[product_key(product)] ~= nil then
            return true
        end
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
local function substituted_ingredients(recipe, planet_substitutions, picked_by_ingredient, claimed, planet_alternates)
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
            local to = substitution.to
            -- When the replacement can't be used here (a loop, or a machine picking recipes by ingredient that already takes it), another resource new to the planet of the same form can
            local function usable(product)
                return product.type == ingredient.type and results[product_key(product)] == nil and not is_ingredient_taken(recipe, product, picked_by_ingredient, claimed)
            end
            if not usable(to) then
                to = nil
                for _, alternate in pairs(planet_alternates or {}) do
                    if to == nil and usable(alternate) then
                        to = alternate
                    end
                end
            end
            if to == nil then
                return nil
            end
            new_ingredient.name = to.name
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

-- Whether a recipe was reachable in a planet's room in the sort, or with is_isolatable_only, made there from the planet's own resources
local function reachable_in(sort, recipe_name, planet_name, is_isolatable_only)
    local room = gutils.key("planet", planet_name)
    for context, _ in pairs(sort.sort_info.node_to_context_inds[gutils.key("recipe", recipe_name)] or {}) do
        local abilities = top.context_abilities(context) or ""
        if top.context_room(context) == room and (not is_isolatable_only or string.sub(abilities, 1, 1) == "1") then
            return true
        end
    end
    return false
end

-- Recipe edits: every recipe belonging to one planet (check.specific_to_room in the sort before) takes what replaced each resource that planet lost
-- Other planets could only make these recipes with imports, so at most they import the new ingredient instead
-- These are more than a visual change, since the new ingredient is mined differently (another drill, another amount, another spot on the map)
-- Any other recipe a planet made from its own resources that takes a resource it lost (a recipe several planets make, or one it shares with its copies) gets a planet variant for that planet instead (resources.variant_plan), since editing it in place would change it for the others
-- A replacement a machine picking recipes by ingredient already takes there gives way to another resource new to the planet of the same form
-- Edits and variants made in one pass claim their new ingredients in machines that pick recipes by ingredient, so two of them can't take the same one there
-- planet_recipes: planet --> set of recipes that belong to it but weren't in the sort before (like the ocean stage's planet variants)
-- Returns the edits and the variant plans
resources.edits = function(substitutions, before, planet_recipes, alternates)
    local picked_by_ingredient = picked_by_ingredient_categories()
    local claimed = {}
    local function claim(recipe, ingredients)
        for _, category in pairs(recipe.categories or {}) do
            if picked_by_ingredient[category] ~= nil then
                claimed[category] = claimed[category] or {}
                for _, ingredient in pairs(ingredients) do
                    claimed[category][product_key(ingredient)] = true
                end
            end
        end
    end
    local edits = {}
    local variants = {}
    for _, planet_name in pairs(sorted_keys(substitutions)) do
        for _, recipe_name in pairs(sorted_keys(data.raw.recipe)) do
            local recipe = data.raw.recipe[recipe_name]
            -- Barreling is transport rather than a use: a barrel filled with the new fluid but emptied into the old one would be a hidden conversion (the ocean stage leaves them out for the same reason, scaffolds.lua)
            local is_barreling = recipe.subgroup == "fill-barrel" or recipe.subgroup == "empty-barrel"
            -- Belonging to exactly this planet's room (check.specific_to_room): an in-place edit changes the recipe for every planet, a copy of this one included
            local is_own = not is_barreling and (planetary_check.specific_to_room(before, recipe_name, planet_name) or (planet_recipes[planet_name] or {})[recipe_name] ~= nil)
            -- Any other recipe this planet made itself, from its own resources (or as one of the only planets that could make it at all): its supply of the lost resource is gone, whoever else makes the recipe, so it follows the swap through a variant of its own (like iron plate on a Nauvis whose iron ore went elsewhere, while Gleba still smelts the iron its bacteria make)
            local is_shared = not is_own and not is_barreling and (reachable_in(before, recipe_name, planet_name, true) or (planetary_check.only_on(before, recipe_name, planet_name) and reachable_in(before, recipe_name, planet_name, false)))
            if is_own or is_shared then
                local ingredients = substituted_ingredients(recipe, substitutions[planet_name], picked_by_ingredient, claimed, (alternates or {})[planet_name])
                if ingredients ~= nil then
                    claim(recipe, ingredients)
                    if is_own then
                        table.insert(edits, {
                            planet_name = planet_name,
                            recipe_name = recipe_name,
                            old_ingredients = recipe.ingredients,
                            new_ingredients = ingredients,
                        })
                    else
                        table.insert(variants, resources.variant_plan(recipe, planet_name, ingredients))
                    end
                end
            end
        end
    end
    return edits, variants
end

-- Technologies unlocking a recipe, sorted
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

-- A planned planet variant of a recipe a planet shares with its copies: the recipe with the planet's new ingredients, named after the planet (like "Copper plate (Nauvis 2)") with its icon as a badge, unlocked by the same technologies and locked to that planet (resources.add_variant)
-- Returns { planet_name, recipe_name (the original's), old_ingredients (the original's), variant (the prototype), technologies }
resources.variant_plan = function(recipe, planet_name, ingredients)
    local variant = table.deepcopy(recipe)
    variant.name = scaffolds.planet_variant_name(recipe.name, planet_name)
    variant.localised_name = scaffolds.variant_name(recipe, planet_name)
    local icons = scaffolds.badged_icons(recipe, planet_name)
    if icons ~= nil then
        variant.icons = icons
        variant.icon = nil
    end
    variant.ingredients = table.deepcopy(ingredients)
    return {
        planet_name = planet_name,
        recipe_name = recipe.name,
        old_ingredients = table.deepcopy(recipe.ingredients),
        variant = variant,
        technologies = unlocking_technologies(recipe.name),
    }
end

-- Puts a variant in the game, locked to its planet (a fixed lock, randomizations/planetary/locks.lua); locks.realize must run after (once for several)
resources.add_variant = function(plan)
    data:extend({
        table.deepcopy(plan.variant),
    })
    for _, technology_name in pairs(plan.technologies) do
        local technology = data.raw.technology[technology_name]
        if technology ~= nil then
            technology.effects = technology.effects or {}
            table.insert(technology.effects, {
                type = "unlock-recipe",
                recipe = plan.variant.name,
            })
        end
    end
    locks.fix("recipe", plan.variant.name, {
        [gutils.key("planet", plan.planet_name)] = true,
    })
end

-- Takes a variant back out of the game; locks.realize must run after (once for several)
resources.remove_variant = function(plan)
    data.raw.recipe[plan.variant.name] = nil
    for _, technology in pairs(data.raw.technology) do
        local effects = technology.effects or {}
        for i = #effects, 1, -1 do
            if effects[i].type == "unlock-recipe" and effects[i].recipe == plan.variant.name then
                table.remove(effects, i)
            end
        end
    end
    locks.unfix("recipe", plan.variant.name)
end

-- On a planet that got a variant, the variant replaces the original there (user, 2026-09-30): each original stops accepting the planets with a variant of it, through a fixed lock on every other room (locks.fix), which goes again if the variants do
-- Only originals without surface conditions of their own: a planet-locked original (like acid neutralisation) stays free for the lock stage's random moves, and keeps its variant beside it
-- locks.realize must run after; a set the new surface properties can't give (the pool ran out) leaves that original makeable everywhere, as without this
-- Returns the excluded originals: list of { recipe_name, planet_rooms = room key --> true }, sorted
resources.exclude_originals = function(variants)
    local planets_of = {}
    local variants_of = {}
    for _, plan in pairs(variants) do
        planets_of[plan.recipe_name] = planets_of[plan.recipe_name] or {}
        planets_of[plan.recipe_name][gutils.key("planet", plan.planet_name)] = true
        variants_of[plan.recipe_name] = variants_of[plan.recipe_name] or {}
        table.insert(variants_of[plan.recipe_name], plan.variant.name)
    end
    local excluded = {}
    for _, recipe_name in pairs(sorted_keys(planets_of)) do
        local recipe = data.raw.recipe[recipe_name]
        local id = "recipe/" .. recipe_name
        if recipe ~= nil and (recipe.surface_conditions == nil or next(recipe.surface_conditions) == nil) and locks.fixed[id] == nil and locks.moved[id] == nil then
            local rooms = {}
            for _, room_key in pairs(surface_sets.room_keys()) do
                if planets_of[recipe_name][room_key] == nil then
                    rooms[room_key] = true
                end
            end
            locks.fix("recipe", recipe_name, rooms, variants_of[recipe_name])
            table.insert(excluded, {
                recipe_name = recipe_name,
                planet_rooms = planets_of[recipe_name],
            })
        end
    end
    return excluded
end

-- Makes excluded originals makeable on those planets again (their own conditions back); locks.realize must run after
resources.include_originals = function(excluded)
    for _, entry in pairs(excluded) do
        locks.release("recipe", entry.recipe_name)
    end
end

-- What a variant changed, for the log
resources.describe_variant = function(plan)
    local old_names = {}
    for _, ingredient in pairs(plan.old_ingredients or {}) do
        table.insert(old_names, ingredient.name)
    end
    local new_names = {}
    for _, ingredient in pairs(plan.variant.ingredients) do
        table.insert(new_names, ingredient.name)
    end
    return plan.variant.name .. " (" .. table.concat(old_names, " + ") .. " --> " .. table.concat(new_names, " + ") .. ")"
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

-- Technology edits: a technology researched by mining a resource that only one planet had (check.node_specific_to_room of the resource's entity in the sort before) is researched by mining what replaced that resource there once the planet loses it, like recipe edits (like calcite processing when calcite's slot on Vulcanus now holds coal)
-- It goes by the resource rather than the technology, since the discovery rule makes a technology isolatable on later planets too (like calcite processing on Aquilo, whose home set includes Vulcanus)
-- A mining trigger lists entities, any one of which counts, so only those lost resources in it are replaced
-- A resource more than one planet had (like crude oil on Nauvis, its copy and Aquilo) stays in the list, since the others may still mine it, and each planet that lost it adds what replaced it there, so every planet can still research the technology from its own resources (like oil processing by mining a geyser on a Nauvis whose crude oil went elsewhere)
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
            local function list(name)
                if is_listed[name] == nil then
                    is_listed[name] = true
                    table.insert(entities, name)
                end
            end
            for _, entity_name in pairs(trigger.entities or {}) do
                local new_name = entity_name
                local added = {}
                for _, planet_name in pairs(sorted_keys(replacements)) do
                    local replacement = replacements[planet_name][entity_name]
                    if replacement ~= nil then
                        if new_name == entity_name and planetary_check.node_specific_to_room(before, gutils.key("entity", entity_name), planet_name) then
                            new_name = replacement
                            table.insert(planet_names, planet_name)
                        else
                            table.insert(added, replacement)
                            table.insert(planet_names, planet_name)
                        end
                    end
                end
                list(new_name)
                for _, name in pairs(added) do
                    list(name)
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
    resources.run = resources.run + 1
    local slots = resources.slots()
    local planets = {}
    for _, slot in pairs(slots) do
        planets[slot.planet_name] = true
    end
    resources.num_planets = #sorted_keys(planets)
    local assignment = resources.random_assignment(slots, id)
    local moves = {}
    for i, slot in pairs(slots) do
        table.insert(moves, slot.planet_name .. " " .. slot.resource_name .. " <-- " .. assignment[i])
    end
    log("Planetary resources (planet slot <-- resource): " .. table.concat(moves, ", "))
    local lost = resources.apply(slots, assignment)
    return slots, assignment, lost
end

-- Logs the extra patches the planets have, and how many planets resource swaps work on (PLANETCHECK extra patches, which dev/run-tests.py holds to half a patch per planet)
-- A patch counts while its planet lists its slider: taking a repair back out (resources.remove_repair) leaves the slider prototype in data.raw
resources.log_extra_patches = function()
    if resources.num_planets == nil then
        return
    end
    local names = {}
    for _, control_name in pairs(sorted_keys(resources.repair_controls)) do
        local planet = data.raw.planet[resources.repair_controls[control_name]] or {}
        local controls = (planet.map_gen_settings or {}).autoplace_controls or {}
        if controls[control_name] ~= nil then
            table.insert(names, control_name)
        end
    end
    local listed = ""
    if #names > 0 then
        listed = ": " .. table.concat(names, ", ")
    end
    log("PLANETCHECK extra patches: " .. #names .. " on " .. resources.num_planets .. " planets" .. listed)
end

return resources
