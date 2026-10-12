-- Independent deposits (setting propertyrandomizer-independent-deposits; config.deposit_copies, only with the unified randomizations in development, whose item randomization does the work)
-- What each planet's deposits mine changes independently of the other planets (the user's design, 2026-10-07):
--   * every material that deposits on several planets mine (an ore, or a fluid like crude oil) gets a copy for each of those planets but the first (the starting planet first) while unified randomization runs, and each of those planets' deposits mine its own copy (src/prototypes/duplicates/deposit-copies.lua names them)
--   * the first planet keeps the material itself, so whatever else still takes the material (barrels, recycling, recipes on other surfaces) keeps a way to get it: with every planet on a copy, crude oil barrels and uranium ore's recycling became unreachable before any randomization ran (seed 1 with duplicates, 2026-10-07)
--   * a resource placed on several planets keeps its prototype on the first (the starting planet first) and gets a clone on every other one, placed where it was there, with the same look, map settings and research triggers
--   * every recipe a planet with a copy can craft that takes such a material gets a variant taking the planet's copy, locked to that planet ("Iron plate (Nauvis 2)", with the planet's badge, had exactly when the recipe is)
--   * a variant stays only if its planet can make it from its own resources before any randomization (prune_variants): that's what the variants protect, and the others only crowded the game (the user asked why electrolyte had variants on 8 planets, 2026-10-07)
--   * the original recipes stay as they are, on every planet they were on, so a planet can still use the material itself from elsewhere (imported, or from rocks and corpses), except an original that only one planet makes, which its version there can replace (see the last point)
--   * a recipe taking several materials a planet mines copies of gets a variant there for each mix of copies and the materials themselves, so it can still take some from the planet's own deposits and the rest from elsewhere, as it could before: like the tungsten carbide of a Vulcanus copy taking the planet's own crude oil and the volcanic rocks' tungsten ore, without which rocket building on Vulcanus copies lost its isolatability before any randomization ran (seed 1 with duplicates, 2026-10-07)
--   * then each planet keeps one version of a recipe, the one taking the most from its own deposits, and the others go with any original only that planet makes, unless the planet would lose something without them (cut_extra_versions, user 2026-10-10: "The goal is to reduce recipe bloat")
-- (Tying each copy to its material in the logic instead kept the game whole too, but first pass couldn't keep what the ties made possible once identities moved, and moved nothing at all)
-- Item randomization then sees each planet's copy as an item of its own, whose position is that planet's deposits and the variants taking it there, and moves it like any other item: a planet's deposits and those variants change together, independently of other planets
-- The rule that keeps two useless items from trading places (item_fluid.realized_assignment) treats copies like their ores, so a deposit only changes to an item that does something on its own; first pass's newness rule for deposits also asks for something the planet didn't mine (src/prototypes/duplicates/deposit-copies.lua's is_new_for)
-- After each unified attempt, collapse renames the copies back to their materials, so the game has one iron ore again, and drops the variants that came out the same as their originals or as one another (a planet whose deposits kept their material); the others stay, locked to their planets, beside the originals that are left
-- Merging the copies mostly only adds ways to get things the logic didn't count, but machines that pick their recipe by ingredient can't keep everything: the recycler has one recipe per item, so a material keeps one of the recycling recipes its copies had (src/prototypes/recipes/recycling.lua's regenerate), and two furnace recipes whose ingredients became one material collide
-- First pass knows which recycling recipes go (recycling.lost_to_merges, the rule regenerate keeps by), so no matching relies on them and neither does the rest of randomization (2026-10-09)
-- The attempt's checks run on the collapsed game, so an attempt whose model relied on what was lost there, like a furnace collision, is retried
local constants = require("src/config/constants")
local copies = require("src/prototypes/duplicates/deposit-copies")
local dutils = require("src/prototypes/data-utils")
local graph_customization = require("src/config/graph-customization")
local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
local item_fluid = require("src/randomizations/unified/item-fluid")
local locale_utils = require("src/localisation/locale")
local looks = require("src/prototypes/looks")
local lutils = require("src/logic/logic-utils")
local combat_encounters = require("src/logic/builders/combat-encounters")
local logic = require("src/logic/init")
local lu = require("src/prototypes/lookup/init")
local surface_sets = require("src/prototypes/surfaces/surface-sets")
local wild = require("src/prototypes/entities/wild-entities")
local locks = require("src/randomizations/planetary/locks")
local scaffolds = require("src/randomizations/planetary/scaffolds")
local base_costs = require("src/cost/material-costs/sa")
local py_costs = require("src/cost/material-costs/py-full")

local key = gutils.key

-- Up to how many materials with copies a recipe gets a variant for every mix of them on a planet (src/prototypes/duplicates/deposit-copies.lua's mixes); more only get the all-copies one and the one-copy ones
local MAX_FULL_MIXES = 3

local stage = {}

local function sorted_keys(tbl)
    local keys = {}
    for k, _ in pairs(tbl or {}) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

local function count(tbl)
    local num = 0
    for _, _ in pairs(tbl or {}) do
        num = num + 1
    end
    return num
end

-- Planet names, the starting planet first, then by name
local function planet_order()
    local names = sorted_keys(data.raw.planet)
    for i, name in pairs(names) do
        if name == constants.starting_planet then
            table.remove(names, i)
            table.insert(names, 1, name)
            break
        end
    end
    return names
end

local function material_prototype(material)
    if material.type == "fluid" then
        return (data.raw.fluid or {})[material.name]
    end
    return dutils.get_prot("item", material.name)
end

-- A material's copy for a planet's deposits: the same prototype under the copy's name, which collapse finds by deposit_copy_of
local function make_copy(prototype, material, planet_name)
    local copy = table.deepcopy(prototype)
    copy.name = copies.copy_name(material.name, planet_name)
    copy.localised_name = locale_utils.find_localised_name(prototype)
    copy.localised_description = locale_utils.find_localised_description(prototype)
    copy.deposit_copy_of = material.name
    copy.deposit_planet = planet_name
    if material.type == "fluid" then
        -- Fluids get barrels before this runs; a copy gets none, so its barrels can't stay behind after collapse
        copy.auto_barrel = false
    end
    data:extend({
        copy,
    })
    return copy
end

-- Every options table keyed by node (handler blacklists and what recipe randomization keeps, first pass's blacklist)
local function option_lists()
    local lists = {}
    for _, options in pairs(randomization_info.options.unified or {}) do
        for _, list in pairs(options) do
            if type(list) == "table" then
                table.insert(lists, list)
            end
        end
    end
    for _, list in pairs(randomization_info.options.first_pass or {}) do
        if type(list) == "table" then
            table.insert(lists, list)
        end
    end
    return lists
end

-- A copy is randomized like its material, and a variant like its recipe: it takes the original's entry in every options table keyed by node
local function mirror_options(original_key, copy_key)
    for _, list in pairs(option_lists()) do
        if list[original_key] ~= nil then
            list[copy_key] = list[original_key]
        end
    end
end

-- First pass weighs swaps by material costs (src/randomizations/unified/first-pass.lua's cost_ok), so a copy costs what its material does
local function mirror_costs(material_key, copy_key)
    local cost_tables = {
        base_costs.costs,
        py_costs.costs,
    }
    for _, costs in pairs(cost_tables) do
        if costs[material_key] ~= nil then
            costs[copy_key] = costs[material_key]
        end
    end
end

-- A resource's clone for another planet it's placed on: the same prototype under the clone's name, placed on that planet where the resource was (its map settings and placement overrides move to the clone), and kept off every other planet
local function clone_resource(resource, planet_name, planets)
    local clone = table.deepcopy(resource)
    clone.name = copies.clone_name(resource.name, planet_name)
    clone.localised_name = locale_utils.find_localised_name(resource)
    clone.localised_description = locale_utils.find_localised_description(resource)
    -- The deposit it stands in for and its planet, so the result summary compares it with that deposit (src/pipeline/result-summary.lua)
    clone.deposit_clone_of = resource.name
    clone.deposit_planet = planet_name
    -- Its Factoriopedia page shows a patch of the clone, which item randomization gives its own look, not one of its resource
    looks.retarget_simulation(clone, resource.name)
    -- The clone is placed by its planet's listing alone, so it names no slider (AutoplaceSpecification.control) and isn't placed where it isn't listed (default_enabled, as for the clones planet copies make in src/prototypes/duplicates/dupe.lua)
    -- With its resource's slider, every other planet with that slider would place it but for the probability override keeping it off, and Factoriopedia listed those planets anyway: each scrap clone showed the six planets with the scrap slider (user's game, 2026-10-09)
    -- Its noise expressions still read the planet's sliders (control:scrap:size and the like), as the game's own ores do without naming one (core/lualib/resource-autoplace.lua leaves control out)
    clone.autoplace.control = nil
    clone.autoplace.default_enabled = false
    data:extend({
        clone,
    })
    local planet = data.raw.planet[planet_name]
    local map_gen_settings = planet.map_gen_settings
    map_gen_settings.autoplace_settings = map_gen_settings.autoplace_settings or {}
    map_gen_settings.autoplace_settings.entity = map_gen_settings.autoplace_settings.entity or {}
    local placement = map_gen_settings.autoplace_settings.entity
    placement.settings = placement.settings or {}
    placement.settings[clone.name] = placement.settings[resource.name] or {}
    placement.settings[resource.name] = nil
    wild.set_overrides(planet, clone.name, wild.overrides(planet, resource.name))
    wild.keep_off(planet, resource.name)
    for _, other_name in pairs(planets) do
        local other = data.raw.planet[other_name]
        if other_name ~= planet_name and other.map_gen_settings ~= nil then
            wild.keep_off(other, clone.name)
        end
    end
    return clone
end

-- A resource with clones stays on its first planet alone; where that planet lists it, it's placed by the listing alone there, like its clones, so its slider doesn't list it in Factoriopedia on the planets its clones took (planet copies keep their original's sliders)
-- One that planet places by its slider alone keeps the slider
local function place_by_listing(resource, planet_name)
    local entity_settings = ((data.raw.planet[planet_name].map_gen_settings or {}).autoplace_settings or {}).entity or {}
    if (entity_settings.settings or {})[resource.name] ~= nil then
        resource.autoplace.control = nil
        resource.autoplace.default_enabled = false
    end
end
stage.clone_resource = clone_resource
stage.place_by_listing = place_by_listing

-- Makes a resource on a planet mine that planet's copies of what it mined
local function mine_copies(resource, planet_name, copy_for)
    local minable = resource.minable
    if minable == nil then
        return
    end
    if minable.results ~= nil then
        for _, result in pairs(minable.results) do
            local copy_name = (copy_for[key(result.type or "item", result.name)] or {})[planet_name]
            if copy_name ~= nil then
                result.name = copy_name
            end
        end
    elseif minable.result ~= nil then
        local copy_name = (copy_for[key("item", minable.result)] or {})[planet_name]
        if copy_name ~= nil then
            minable.result = copy_name
        end
    end
end

-- Whether rooms are all planets of one family (a planet and its copies, surface_sets.family_of), so a recipe accepted only there is locked to one planet
local function is_planet_locked(rooms)
    local family
    for room_key, _ in pairs(rooms) do
        if gutils.deconstruct(room_key).type ~= "planet" then
            return false
        end
        local room_family = surface_sets.family_of(room_key)
        if family ~= nil and room_family ~= family then
            return false
        end
        family = room_family
    end
    return family ~= nil
end

-- Whether a recipe is a hand-written recycling recipe under its item's recycling name, like scrap recycling: the recycler then generates no recycling of its own for the item (see src/prototypes/recipes/recycling.lua), and the recipe's planet versions keep that (deposit_hand_recycled)
local function is_hand_recycling(recipe)
    local is_recycling = false
    for _, category in pairs(recipe.categories or { recipe.category or "crafting" }) do
        if category == "recycling" then
            is_recycling = true
        end
    end
    local ingredients = recipe.ingredients or {}
    return is_recycling and #ingredients == 1 and ingredients[1].type == "item" and ingredients[1].name .. "-recycling" == recipe.name
end

-- A planet's variant of a recipe, before its ingredients are localized: named after the planet with the planet's badge like planetary variants (src/randomizations/planetary/scaffolds.lua)
-- It's had exactly when the recipe is (enabled from the start like it, and unlocked by every technology unlocking it): unlocked in a planet copy's own tree like a duplicate, it came later than the recipe it stands beside, which cost rocket building on planet copies its isolatability before any randomization ran (seed 1 with duplicates, 2026-10-07)
-- Its intermediate_planet field (scaffolds.name_variant) keeps the planet in its name when item randomization renames recipes (src/prototypes/recipes/recipe-renames.lua), and a variant of a recipe that's already the planet's own (a planetary variant, or a planet copy's local recipe) names the planet once
-- The optional mix numbers the variant among the recipe's on the planet, when it has several
local function make_variant(recipe, planet_name, unlocked_by, mix)
    local variant = table.deepcopy(recipe)
    local base = recipe.name .. "-deposits"
    if mix ~= nil then
        base = base .. "-" .. mix
    end
    variant.name = scaffolds.planet_variant_name(base, planet_name)
    scaffolds.name_variant(variant, recipe, planet_name)
    variant.localised_description = locale_utils.find_localised_description(recipe)
    local icons = scaffolds.badged_icons(recipe, planet_name)
    if icons ~= nil then
        variant.icons = icons
        variant.icon = nil
    end
    data:extend({
        variant,
    })
    for _, technology in pairs(unlocked_by[recipe.name] or {}) do
        table.insert(technology.effects, {
            type = "unlock-recipe",
            recipe = variant.name,
        })
    end
    mirror_options(key("recipe", recipe.name), key("recipe", variant.name))
    return variant
end

-- The keys of the materials a recipe takes that a planet mines copies of, in order
local function materials_with_copies(recipe, planet_name, copy_for)
    local materials = {}
    for _, ingredient in pairs(recipe.ingredients or {}) do
        local material_key = key(ingredient.type or "item", ingredient.name)
        if (copy_for[material_key] or {})[planet_name] ~= nil then
            table.insert(materials, material_key)
        end
    end
    table.sort(materials)
    return materials
end

-- Makes a recipe a planet's version: it takes the planet's copies of the materials in mixed (material key --> true), and says so (deposit_local, with how many ingredients come from the planet's own deposits; deposit_local_unlocked for protection, deposit_hand_recycled for recycling, see markers)
local function localize(recipe, planet_name, copy_for, markers, mixed)
    local num_local = 0
    for _, ingredient in pairs(recipe.ingredients or {}) do
        local material_key = key(ingredient.type or "item", ingredient.name)
        local copy_name = (copy_for[material_key] or {})[planet_name]
        if copy_name ~= nil and mixed[material_key] ~= nil then
            ingredient.name = copy_name
            num_local = num_local + 1
        end
    end
    recipe.deposit_local = {
        original = markers.original,
        planet = planet_name,
        num_local = num_local,
    }
    if markers.unlocked == true then
        recipe.deposit_local_unlocked = true
    end
    if markers.hand_recycled == true then
        recipe.deposit_hand_recycled = true
    end
end

-- Cuts each planet's versions of a recipe down to one (user, 2026-10-10: "The goal is to reduce recipe bloat"):
--   * the version taking the most from the planet's own deposits stays
--   * the planet's other versions go, and so does the original when that planet alone makes it (a planetary version, or a planet copy's own recipe), since the version stands in for it there
--   * except a recipe the planet would lose something with: a context of it that no recipe staying has (copies.choose_cuts, in prune_variants' sort of the game with every variant in it), or still has once the cut ones are gone (copies.uncovered_cuts, in a sort of the game without them, since a recipe staying may have been had through one cut, like a deposit getting started with a version taking rocks' ore); those are put back
--   * an original also owes what the variants dropped there relied on it for, since they went because it stays
--   * hand-written recycling recipes stay, since the recycler generates no recycling for their item while they're there (is_hand_recycling)
-- variants_of: original recipe name --> its kept variants, which loses the ones cut; dropped: recipe name --> true, which gains them; dropped_on: original recipe name --> planet name --> its variants dropped there
-- sort_info and home_sets: the sort prune_variants made, and its home sets
-- Leaves the dropped and cut recipes out of data.raw, and the logic built without them (prune_variants drops them again, which changes nothing)
-- Returns how many it cut
local function cut_extra_versions(variants_of, dropped, dropped_on, sort_info, home_sets)
    -- The contexts of the recipes, each once, in order
    local function owed(names)
        local seen = {}
        local list = {}
        for _, name in pairs(names) do
            for context, _ in pairs(sort_info.node_to_context_inds[key("recipe", name)] or {}) do
                if seen[context] == nil then
                    seen[context] = true
                    table.insert(list, context)
                end
            end
        end
        table.sort(list)
        return list
    end
    local groups = {}
    for _, recipe_name in pairs(sorted_keys(variants_of)) do
        local original = data.raw.recipe[recipe_name]
        local accepted = surface_sets.accepted(original)
        local on_planet = {}
        for _, name in pairs(variants_of[recipe_name]) do
            local planet_name = data.raw.recipe[name].deposit_local.planet
            on_planet[planet_name] = on_planet[planet_name] or {}
            table.insert(on_planet[planet_name], name)
        end
        for _, planet_name in pairs(sorted_keys(on_planet)) do
            local versions = on_planet[planet_name]
            table.sort(versions, function(a, b)
                local num_a = data.raw.recipe[a].deposit_local.num_local
                local num_b = data.raw.recipe[b].deposit_local.num_local
                if num_a ~= num_b then
                    return num_a > num_b
                end
                return a < b
            end)
            local group = {
                planet_name = planet_name,
                original = recipe_name,
                members = {},
                candidates = {},
            }
            for i, name in pairs(versions) do
                table.insert(group.members, name)
                if i > 1 then
                    table.insert(group.candidates, {
                        name = name,
                        owes = owed({ name }),
                    })
                end
            end
            if accepted[key("planet", planet_name)] ~= nil then
                table.insert(group.members, recipe_name)
                if count(accepted) == 1 and not is_hand_recycling(original) then
                    local names = { recipe_name }
                    for _, name in pairs((dropped_on[recipe_name] or {})[planet_name] or {}) do
                        table.insert(names, name)
                    end
                    table.insert(group.candidates, {
                        name = recipe_name,
                        owes = owed(names),
                    })
                end
            end
            if #group.candidates > 0 then
                table.insert(groups, group)
            end
        end
    end
    local function has_in(contexts_of)
        return function(name, context)
            return top.provides_context(contexts_of[key("recipe", name)] or {}, context)
        end
    end
    local cut, why = copies.choose_cuts(groups, has_in(sort_info.node_to_context_inds))
    local num_put_back = 0
    if next(cut) ~= nil then
        local saved = copies.save_recipes(data.raw, cut)
        local gone = {}
        for name, _ in pairs(dropped) do
            gone[name] = true
        end
        for name, _ in pairs(cut) do
            gone[name] = true
        end
        copies.drop_recipes(data.raw, gone)
        combat_encounters.reset()
        logic.build()
        local after = top.sort(logic.graph, nil, nil, {
            complex_contexts = true,
            home_contexts = true,
            home_sets = home_sets,
        })
        local uncovered = copies.uncovered_cuts(groups, cut, has_in(after.node_to_context_inds))
        copies.restore_recipes(data.raw, saved, uncovered)
        for name, context in pairs(uncovered) do
            cut[name] = nil
            why[name] = context
            num_put_back = num_put_back + 1
        end
    end
    local num_versions = 0
    local num_originals = 0
    local num_stayed = 0
    for _, group in pairs(groups) do
        local cut_names = {}
        local stayed_names = {}
        for _, candidate in pairs(group.candidates) do
            if cut[candidate.name] ~= nil then
                table.insert(cut_names, candidate.name)
                if candidate.name == group.original then
                    num_originals = num_originals + 1
                else
                    num_versions = num_versions + 1
                end
            else
                table.insert(stayed_names, candidate.name .. (why[candidate.name] ~= nil and (" (" .. top.context_name(why[candidate.name]) .. ")") or ""))
                num_stayed = num_stayed + 1
            end
        end
        log("Independent deposits: " .. group.original .. " on " .. group.planet_name .. " keeps " .. group.members[1] .. (#cut_names > 0 and ("; cut " .. table.concat(cut_names, ", ")) or "") .. (#stayed_names > 0 and ("; kept for what the planet would lose without them: " .. table.concat(stayed_names, ", ")) or ""))
    end
    for name, _ in pairs(cut) do
        dropped[name] = true
    end
    for _, recipe_name in pairs(sorted_keys(variants_of)) do
        local kept = {}
        for _, name in pairs(variants_of[recipe_name]) do
            if cut[name] == nil then
                table.insert(kept, name)
            end
        end
        variants_of[recipe_name] = kept
    end
    log("Independent deposits: each planet keeps one version of a recipe: " .. num_versions .. " other versions and " .. num_originals .. " originals only their planet made were cut, " .. num_stayed .. " kept for what their planet would lose without them (" .. num_put_back .. " of them put back after a sort without the cut ones)")
    return num_versions + num_originals
end

-- Drops the variants their planet can't make from its own resources (an isolatable context in its room, top.isolatable_in), in a sort of the game with every variant in it, sorted like the game the rest of randomization starts from (data-final-fixes.lua's prepare_world)
-- Isolatable asks that of the machines too: a delivered building only counts where the planet can then make more of it (src/logic/builders/bootstrap.lua), so Aquilo's oil processing variants go, its refineries coming from elsewhere
-- Keeping a planet able to make a recipe without imports once its deposits change is what a variant does: its deposits and the variant change together
-- A variant that needs imports anyway protects nothing, since the import could bring the material too, which the original still takes there (the resource swaps' planet variants follow the same rule, src/randomizations/planetary/resources.lua)
-- Then each planet keeps one version of a recipe (cut_extra_versions), chosen in the same sort and checked in one without the recipes cut
-- variants_of: original recipe name --> its variants' names, changed to the ones kept; home_sets: the home sets to sort with, or nil for the game's own
-- Returns how many it dropped
local function prune_variants(variants_of, home_sets)
    combat_encounters.reset()
    logic.build()
    local sort_home_sets = home_sets or top.home_sets(logic.graph)
    local sort_info = top.sort(logic.graph, nil, nil, {
        complex_contexts = true,
        home_contexts = true,
        home_sets = sort_home_sets,
    })
    -- Planet names in order of first appearance, with how many variants each has when that's more than one, like "vulcanus (3), gleba"
    local function planets_text(planet_names)
        local order = {}
        local counts = {}
        for _, planet_name in pairs(planet_names) do
            if counts[planet_name] == nil then
                table.insert(order, planet_name)
                counts[planet_name] = 0
            end
            counts[planet_name] = counts[planet_name] + 1
        end
        local texts = {}
        for _, planet_name in pairs(order) do
            table.insert(texts, planet_name .. (counts[planet_name] > 1 and (" (" .. counts[planet_name] .. ")") or ""))
        end
        return table.concat(texts, ", ")
    end
    local dropped = {}
    local num_dropped = 0
    -- Original recipe name --> planet name --> the variants dropped there
    local dropped_on = {}
    for _, recipe_name in pairs(sorted_keys(variants_of)) do
        local kept = {}
        local kept_planets = {}
        local dropped_planets = {}
        for _, name in pairs(variants_of[recipe_name]) do
            local planet_name = data.raw.recipe[name].deposit_local.planet
            if top.isolatable_in(sort_info.node_to_context_inds[key("recipe", name)], key("planet", planet_name)) then
                table.insert(kept, name)
                table.insert(kept_planets, planet_name)
            else
                dropped[name] = true
                num_dropped = num_dropped + 1
                table.insert(dropped_planets, planet_name)
                dropped_on[recipe_name] = dropped_on[recipe_name] or {}
                dropped_on[recipe_name][planet_name] = dropped_on[recipe_name][planet_name] or {}
                table.insert(dropped_on[recipe_name][planet_name], name)
            end
        end
        if #dropped_planets > 0 then
            local kept_text = #kept > 0 and ("on " .. planets_text(kept_planets) .. "; ") or ""
            log("Independent deposits: " .. recipe_name .. " keeps " .. #kept .. " of its " .. #variants_of[recipe_name] .. " planet variants (" .. kept_text .. "dropped on " .. planets_text(dropped_planets) .. ")")
        end
        if #kept > 0 then
            variants_of[recipe_name] = kept
        else
            variants_of[recipe_name] = nil
        end
    end
    num_dropped = num_dropped + cut_extra_versions(variants_of, dropped, dropped_on, sort_info, sort_home_sets)
    copies.drop_recipes(data.raw, dropped)
    local lists = option_lists()
    for name, _ in pairs(dropped) do
        for _, list in pairs(lists) do
            list[key("recipe", name)] = nil
        end
    end
    return num_dropped
end

-- Puts the copies, clones and variants in the game (see the top of this file), with their locks realized (src/randomizations/planetary/locks.lua)
-- Call it with the game the rest of randomization starts from (after the planetary stages), before that game is captured
-- home_sets: the home sets that game is sorted with (the planetary stages' when they ran), or nil for its own (see prune_variants)
-- Returns { variants_of = original recipe name --> list of its planet variants' names }, for the planetary checks, which count a recipe's variants as the recipe
stage.prepare = function(home_sets)
    graph_customization.initialize(config.customization, data.raw, defines.prototypes, config.seed)
    -- Surface sets read the rooms from the lookups (src/prototypes/surfaces/surface-sets.lua), which only a logic build has loaded so far, and none has run yet without duplicates or planetary stages
    lu.load_lookups()
    lookups = lu
    local planets = planet_order()

    -- The planets each resource is placed on, in planet order
    local homes = {}
    for _, resource_name in pairs(sorted_keys(data.raw.resource)) do
        local resource = data.raw.resource[resource_name]
        if resource.autoplace ~= nil then
            for _, planet_name in pairs(planets) do
                if lutils.check_in_room(data.raw.planet[planet_name], resource) then
                    homes[resource_name] = homes[resource_name] or {}
                    table.insert(homes[resource_name], planet_name)
                end
            end
        end
    end

    -- The planets mining each material, and what each planet mines
    local material_of = {}
    local material_planets = {}
    local mined_on = {}
    for resource_name, planet_names in pairs(homes) do
        for _, result in pairs(dutils.minable_results(data.raw.resource[resource_name])) do
            local material_key = key(result.type, result.name)
            material_of[material_key] = result
            material_planets[material_key] = material_planets[material_key] or {}
            for _, planet_name in pairs(planet_names) do
                material_planets[material_key][planet_name] = true
                mined_on[planet_name] = mined_on[planet_name] or {}
                mined_on[planet_name][material_key] = true
            end
        end
    end

    -- The materials that get copies: mined on two planets or more, and moved by item randomization at all
    local lab_inputs = dutils.lab_inputs()
    local split = {}
    for _, material_key in pairs(sorted_keys(material_planets)) do
        local material = material_of[material_key]
        local node = {
            type = material.type,
            name = material.name,
        }
        if count(material_planets[material_key]) >= 2 and material_prototype(material) ~= nil and lab_inputs[material.name] == nil
            and randomization_info.options.first_pass.blacklist[material_key] == nil
            and not graph_customization.excluded("item", node) then
            split[material_key] = true
        end
    end
    if next(split) == nil then
        log("Independent deposits: no material that deposits mine is mined on two planets, so the deposits stay as they are")
        copies.current = nil
        return {
            variants_of = {},
        }
    end

    -- The copies
    local copy_for = {}
    local original_of = {}
    local original_key = {}
    local position_planets = {}
    for material_key, planet_set in pairs(material_planets) do
        if split[material_key] == nil then
            position_planets[material_key] = planet_set
        end
    end
    local num_copies = 0
    local split_names = {}
    for _, material_key in pairs(sorted_keys(split)) do
        local material = material_of[material_key]
        local prototype = material_prototype(material)
        table.insert(split_names, material.name)
        copy_for[material_key] = {}
        local first_planet
        for _, planet_name in pairs(planets) do
            if material_planets[material_key][planet_name] ~= nil and first_planet == nil then
                -- The first planet keeps the material itself (see the top of this file)
                first_planet = planet_name
                position_planets[material_key] = {
                    [planet_name] = true,
                }
            elseif material_planets[material_key][planet_name] ~= nil then
                local copy = make_copy(prototype, material, planet_name)
                local copy_key = key(material.type, copy.name)
                copy_for[material_key][planet_name] = copy.name
                original_of[copy.name] = material.name
                original_key[copy_key] = material_key
                position_planets[copy_key] = {
                    [planet_name] = true,
                }
                mirror_options(material_key, copy_key)
                mirror_costs(material_key, copy_key)
                num_copies = num_copies + 1
            end
        end
    end

    -- Each planet's deposits mine its copies (none on a material's first planet): clones first, from the resource as it was, then every version's mining results
    local clones_of = {}
    local deposits = {}
    for _, resource_name in pairs(sorted_keys(homes)) do
        local resource = data.raw.resource[resource_name]
        local originals = {}
        local mines_split = false
        for _, result in pairs(dutils.minable_results(resource)) do
            local material_key = key(result.type, result.name)
            table.insert(originals, material_key)
            if split[material_key] ~= nil then
                mines_split = true
            end
        end
        for i, planet_name in pairs(homes[resource_name]) do
            local entity_name = resource_name
            if mines_split and i > 1 then
                entity_name = clone_resource(resource, planet_name, planets).name
                clones_of[resource_name] = clones_of[resource_name] or {}
                table.insert(clones_of[resource_name], entity_name)
            end
            -- Every planet's deposits are logged after each attempt, those of materials without copies too
            table.insert(deposits, {
                planet_name = planet_name,
                resource_name = entity_name,
                originals = originals,
            })
        end
        if clones_of[resource_name] ~= nil then
            place_by_listing(resource, homes[resource_name][1])
        end
    end
    for _, deposit in pairs(deposits) do
        mine_copies(data.raw.resource[deposit.resource_name], deposit.planet_name, copy_for)
    end
    -- Mining a clone does what mining its resource did for research (MineEntityTechnologyTrigger::entities: any of them fulfills the trigger)
    for _, technology_name in pairs(sorted_keys(data.raw.technology)) do
        local trigger = data.raw.technology[technology_name].research_trigger
        if trigger ~= nil and trigger.type == "mine-entity" and trigger.entities ~= nil then
            local added = {}
            for _, entity_name in pairs(trigger.entities) do
                for _, clone_name in pairs(clones_of[entity_name] or {}) do
                    table.insert(added, clone_name)
                end
            end
            for _, clone_name in pairs(added) do
                table.insert(trigger.entities, clone_name)
            end
        end
    end

    -- Each planet's versions of the recipes taking its copies' materials
    -- Barrel filling and emptying stay with their fluid (item_fluid.move_identity_sources), and hidden recipes (like generated recycling) aren't any planet's
    -- Recipe name --> the technologies unlocking it, found before any variant is added
    local unlocked_by = {}
    for _, technology_name in pairs(sorted_keys(data.raw.technology)) do
        local technology = data.raw.technology[technology_name]
        for _, effect in pairs(technology.effects or {}) do
            if effect.type == "unlock-recipe" then
                unlocked_by[effect.recipe] = unlocked_by[effect.recipe] or {}
                table.insert(unlocked_by[effect.recipe], technology)
            end
        end
    end
    local is_container_recipe = {}
    for _, held in pairs(item_fluid.container_recipes(item_fluid.fluid_containers(data.raw.recipe))) do
        for recipe_name, _ in pairs(held.fill) do
            is_container_recipe[recipe_name] = true
        end
        for recipe_name, _ in pairs(held.empty) do
            is_container_recipe[recipe_name] = true
        end
    end
    local variants_of = {}
    local num_made = 0
    for _, recipe_name in pairs(sorted_keys(data.raw.recipe)) do
        local recipe = data.raw.recipe[recipe_name]
        if recipe.hidden ~= true and not is_container_recipe[recipe_name] and not graph_customization.excluded("item", recipe) then
            local accepted = surface_sets.accepted(recipe)
            local takes_on = {}
            for _, ingredient in pairs(recipe.ingredients or {}) do
                local material_key = key(ingredient.type or "item", ingredient.name)
                for planet_name, _ in pairs(copy_for[material_key] or {}) do
                    if accepted[key("planet", planet_name)] ~= nil then
                        takes_on[planet_name] = true
                    end
                end
            end
            local localized = {}
            for _, planet_name in pairs(planets) do
                if takes_on[planet_name] ~= nil then
                    table.insert(localized, planet_name)
                end
            end
            if #localized > 0 then
                local markers = {
                    original = recipe_name,
                    -- A variant of a recipe that's locked to one planet's family is locked to one planet too, which protection keeps exactly like any (protection.planet_locked_recipe_contexts); one of a recipe that wasn't isn't
                    unlocked = not is_planet_locked(accepted),
                    hand_recycled = is_hand_recycling(recipe),
                }
                local names = {}
                for _, planet_name in pairs(localized) do
                    for mix, mixed in pairs(copies.mixes(materials_with_copies(recipe, planet_name, copy_for), MAX_FULL_MIXES)) do
                        local variant = make_variant(recipe, planet_name, unlocked_by, mix > 1 and mix or nil)
                        localize(variant, planet_name, copy_for, markers, mixed)
                        locks.fix("recipe", variant.name, {
                            [key("planet", planet_name)] = true,
                        })
                        table.insert(names, variant.name)
                    end
                end
                variants_of[recipe_name] = names
                num_made = num_made + #names
            end
        end
    end
    local unrealized = locks.realize()

    copies.current = {
        original_of = original_of,
        original_key = original_key,
        position_planets = position_planets,
        mined_on = mined_on,
        deposits = deposits,
    }
    -- The dropped variants' locks go with them (locks.realize forgets a lock whose prototype is gone)
    if prune_variants(variants_of, home_sets) > 0 then
        unrealized = locks.realize()
    end
    local num_variants = 0
    local num_recipes = 0
    for _, names in pairs(variants_of) do
        num_variants = num_variants + #names
        num_recipes = num_recipes + 1
    end
    log("Independent deposits: " .. num_copies .. " copies of the " .. #split_names .. " materials deposits on several planets mine (" .. table.concat(split_names, ", ") .. "), " .. count(clones_of) .. " resources cloned for their other planets, " .. num_variants .. " planet variants of " .. num_recipes .. " recipes (of " .. num_made .. " made, the others their planet couldn't make from its own resources)")
    if #unrealized > 0 then
        log("Independent deposits: " .. #unrealized .. " locks the surface properties couldn't give stay as they were: " .. table.concat(unrealized, ", "))
    end
    return {
        variants_of = variants_of,
    }
end

-- Logs what each planet's deposits mine in raw (the game an attempt built, before collapse), with how many mine something else than before and how many something their planet didn't mine
local function log_deposits(raw)
    local current = copies.current
    local num_deposits = 0
    local num_changed = 0
    local num_new = 0
    local lines = {}
    for _, deposit in pairs(current.deposits) do
        local resource = (raw.resource or {})[deposit.resource_name]
        if resource ~= nil then
            num_deposits = num_deposits + 1
            local was = {}
            local is_original = {}
            for _, material_key in pairs(deposit.originals) do
                is_original[material_key] = true
                table.insert(was, gutils.deconstruct(material_key).name)
            end
            local mines = {}
            local is_changed = false
            local is_new = false
            for _, result in pairs(dutils.minable_results(resource)) do
                local name = current.original_of[result.name] or result.name
                local material_key = key(result.type, name)
                table.insert(mines, name)
                if not is_original[material_key] then
                    is_changed = true
                end
                if (current.mined_on[deposit.planet_name] or {})[material_key] == nil then
                    is_new = true
                end
            end
            if is_changed then
                num_changed = num_changed + 1
            end
            if is_new then
                num_new = num_new + 1
            end
            local note = ""
            if is_new then
                note = ", new to the planet"
            elseif is_changed then
                note = ", which the planet mined already"
            end
            table.insert(lines, "Independent deposits: " .. deposit.planet_name .. ": " .. deposit.resource_name .. " mines " .. table.concat(mines, ", ") .. " (was " .. table.concat(was, ", ") .. note .. ")")
        end
    end
    log("Independent deposits: " .. num_changed .. " of " .. num_deposits .. " deposits mine something else, " .. num_new .. " something new to their planet")
    for _, line in pairs(lines) do
        log(line)
    end
end

-- Fields a copy has of its own by construction (make_copy), which renaming it back drops on purpose
local own_fields = {
    name = true,
    localised_name = true,
    localised_description = true,
    deposit_copy_of = true,
    deposit_planet = true,
    auto_barrel = true,
}

local function same_value(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then
        return a == b
    end
    for k, v in pairs(a) do
        if not same_value(v, b[k]) then
            return false
        end
    end
    for k, _ in pairs(b) do
        if a[k] == nil then
            return false
        end
    end
    return true
end

-- What copies gained during the attempt, before collapse drops them with their prototypes
-- Whatever replaces coal becomes a fuel (dutils.give_replacement_fuel), and a copy that did hands that on to its material, since a fuel more only adds ways to get things
-- Any other difference from its material goes with the copy, and is logged, so a randomization that gave copies something can be taught to leave them alone (copies.is_copy)
-- (Some differences come from the material instead, like the badge on its icon when entity randomization makes it place something, which copies are kept out of)
local function settle_gains(raw)
    for _, prototypes in pairs(raw) do
        if type(prototypes) == "table" then
            for _, copy_name in pairs(sorted_keys(copies.current.original_of)) do
                local copy = prototypes[copy_name]
                local original = prototypes[copies.current.original_of[copy_name]]
                if copies.is_copy(copy) and original ~= nil then
                    if dutils.has_fuel_category(copy, dutils.REPLACEMENT_FUEL_CATEGORY) and not dutils.has_fuel_category(original, dutils.REPLACEMENT_FUEL_CATEGORY) then
                        dutils.give_replacement_fuel(original)
                        log("Independent deposits: " .. copy_name .. " became a fuel where coal was, so " .. original.name .. " is one now too")
                    end
                    for _, field in pairs(sorted_keys(copy)) do
                        if own_fields[field] == nil and not same_value(copy[field], original[field]) then
                            log("Independent deposits: " .. copy_name .. "'s " .. field .. " differs from " .. original.name .. "'s after randomization, and goes with the copy")
                        end
                    end
                end
            end
        end
    end
end

-- Whether raw still has copies
stage.has_copies = function(raw)
    return copies.current ~= nil and copies.has_copies(raw, copies.current.original_of)
end

-- Renames the copies back to their materials in raw and drops them (src/prototypes/duplicates/deposit-copies.lua)
-- With is_quiet it doesn't log what the deposits mine (for another version of the game, like the one each attempt starts from)
stage.collapse = function(raw, is_quiet)
    if not stage.has_copies(raw) then
        return
    end
    if not is_quiet then
        log_deposits(raw)
    end
    settle_gains(raw)
    local num_renamed, num_merged = copies.collapse(raw, copies.current.original_of)
    local num_dropped = copies.drop_twins(raw)
    log("Independent deposits: copies renamed back to their materials (" .. num_renamed .. " references; " .. num_merged .. " recipes took a material twice and take it once now); " .. num_dropped .. " planet variants came out the same as their originals and were dropped")
end

return stage
