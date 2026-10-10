-- Repairs for recipes whose planet lock moved (randomizations/planetary/locks.lua): on each new planet, a recipe must be makeable from that planet's own resources (user, 2026-10-08), so its goals follow it with their isolatability (check.transport)
-- Where it isn't, the recipe gets a version for that planet, locked to it (like "Foundry (Fulgora)"): each ingredient the planet can't make itself is swapped for a close one it can, a material only that planet's family makes if one fits, else anything it makes, closest in depth to the old ingredient at home (like a reward member's substitutes, rewards.lua)
-- The version is unlocked by a technology researchable there from the planet's own resources: one that unlocks the recipe already, or else a copy of its technology whose trigger asks for something the planet has, whose research takes the planet's own science pack instead of other planets' packs, and whose prerequisites are the ones researchable there plus the planet's discovery (like a moved reward's technology)
-- Unified randomization then re-rolls the version's ingredients and research like anything else, and keeps it makeable there: it's locked to one planet, so protection.lua keeps its contexts, and the trigger handler keeps its technology isolatable wherever it's needed
-- The original stays for the planets its lock accepts, with the version beside it, like the resource stage's versions of planet-locked recipes
-- A recipe still failing its goals there keeps its old lock: the lock stage reverts it, and lock_repairs.undo takes its versions back
-- A moved recipe that makes a machine only planet-locked machines are like (the foundry) also takes that machine's ocean recipes along (lock_repairs.follow_machines, user 2026-10-08): each new planet gets its own version of the recipes the machine made from its old planet's ocean, taking the new planet's ocean instead (molten iron from lava on a Fulgora whose ocean is now lava)

local dutils = require("lib/data-utils")
local furnace_selection = require("lib/furnace-selection")
local gutils = require("lib/graph/graph-utils")
local locale_utils = require("lib/locale")
local recycling = require("lib/recycling")
local research_triggers = require("lib/research-triggers")
local top = require("lib/graph/context-sort")
local protection = require("randomizations/graph/unified/skeleton/protection")
local surface_sets = require("lib/surface-sets")
local locks = require("randomizations/planetary/locks")
local rewards = require("randomizations/planetary/rewards")
local scaffolds = require("randomizations/planetary/scaffolds")

local helpers = rewards.helpers

local lock_repairs = {}

-- Lock id --> the versions made for it, each { recipe_name, room_key, variant_name, tech_name (the technology unlocking it), copy_name (a technology copy this made, or nil), notes (for the log) }
lock_repairs.made = {}

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

local function room_name(room_key)
    return gutils.deconstruct(room_key).name
end

-- Whether a node has an isolatable context in the room in the sort, reached without the excluded recipes (recipe node keys) when given
local function is_isolatable_in(sort, node_key, room_key, excluded)
    for context, ind in pairs(sort.sort_info.node_to_context_inds[node_key] or {}) do
        if top.context_home(context) == nil and top.context_room(context) == room_key and protection.is_isolatable_context(context) then
            if excluded == nil or helpers.path_avoids(sort, ind, excluded) then
                return true
            end
        end
    end
    return false
end

-- The rooms of the planet family a room belongs to, as a set (a planet and its copies, surface_sets.family_of)
local function family_rooms(room_key)
    return helpers.families()[helpers.family_of(room_key)] or {
        [room_key] = true,
    }
end

-- What a recipe must not be had through on its new planet: itself and the recycler's generated recipes of what it makes, as recipe node keys (for path_avoids)
local function own_recipes(recipe)
    local excluded = {
        [gutils.key("recipe", recipe.name)] = true,
    }
    local made = {}
    for _, result in pairs(recipe.results or {}) do
        made[result.type .. ":" .. result.name] = true
    end
    for recipe_name, other in pairs(data.raw.recipe) do
        if recycling.looks_generated(other) then
            for _, ingredient in pairs(other.ingredients or {}) do
                if made[ingredient.type .. ":" .. ingredient.name] ~= nil then
                    excluded[gutils.key("recipe", recipe_name)] = true
                end
            end
        end
    end
    return excluded
end

-- How many candidates a pick walks the witness of before giving up (each is a top.path walk; ranking every candidate by them made the lock stage several times slower)
local MAX_WALKED = 25

-- The candidate the room makes itself (isolatably, without the excluded recipes) to pick: one only the room's family makes if one fits, else any, closest in depth in the room to old_depth (rewards' depth_of), or nil
-- Candidates are ranked by what the sort says directly, and only the best ones get their witnesses walked for the excluded recipes and for also_ok (optional)
local function closest_local(sort, candidates, room_key, old_depth, excluded, also_ok)
    local rooms = {
        [room_key] = true,
    }
    local family = family_rooms(room_key)
    local ranked = {}
    for _, candidate in pairs(candidates) do
        local node_key = candidate.source_key or candidate.node_key
        if is_isolatable_in(sort, node_key, room_key) then
            local depth = helpers.depth_of(sort, node_key, rooms)
            if depth ~= nil then
                table.insert(ranked, {
                    candidate = candidate,
                    node_key = node_key,
                    is_specific = helpers.specific_to_rooms(sort, node_key, family),
                    depth_gap = math.abs(depth - (old_depth or depth)),
                })
            end
        end
    end
    table.sort(ranked, function(a, b)
        if a.is_specific ~= b.is_specific then
            return a.is_specific
        end
        if a.depth_gap ~= b.depth_gap then
            return a.depth_gap < b.depth_gap
        end
        return a.node_key < b.node_key
    end)
    for i = 1, math.min(#ranked, MAX_WALKED) do
        local entry = ranked[i]
        if is_isolatable_in(sort, entry.node_key, room_key, excluded) and (also_ok == nil or also_ok(entry.candidate)) then
            return entry.candidate
        end
    end
    return nil
end

-- A material of the ingredient's form the room makes itself (isolatably, without the recipe), to stand in for the ingredient there: one only the room's family makes if one fits, else any, closest in depth to the ingredient at home (home_rooms)
-- Only intermediates stand in for an item: not buildings and not science packs (like rewards' ingredient_substitute)
local function substitute(sort, ingredient, room_key, home_rooms, excluded)
    local candidates
    if ingredient.type == "fluid" then
        candidates = helpers.trigger_candidates("craft-fluid")
    else
        local lab_inputs = dutils.lab_inputs()
        candidates = {}
        for _, candidate in pairs(helpers.trigger_candidates("craft-item")) do
            local item = dutils.get_prot("item", candidate.name)
            if item ~= nil and item.place_result == nil and lab_inputs[candidate.name] == nil then
                table.insert(candidates, candidate)
            end
        end
    end
    local old_depth = helpers.depth_of(sort, gutils.key(ingredient.type, ingredient.name), home_rooms)
    return closest_local(sort, candidates, room_key, old_depth, excluded)
end

-- The recipe's ingredients with each one the room can't make itself swapped for a substitute, and the swaps as { from, to }, or nil (with the ingredient) when one has no substitute
-- A recipe a furnace or recycler picks by ingredient isn't swapped (another recipe there might take the substitute), so then every ingredient must be local already
local function local_ingredients(sort, recipe, room_key, home_rooms, excluded)
    local is_picked = #furnace_selection.pools_for(furnace_selection.pools(), furnace_selection.recipe_categories(recipe)) > 0
    local ingredients = {}
    local swaps = {}
    local by_key = {}
    for _, ingredient in pairs(recipe.ingredients or {}) do
        local new_ingredient = table.deepcopy(ingredient)
        if not is_isolatable_in(sort, gutils.key(ingredient.type, ingredient.name), room_key, excluded) then
            local stand_in = not is_picked and substitute(sort, ingredient, room_key, home_rooms, excluded) or nil
            if stand_in == nil then
                return nil, ingredient.name
            end
            new_ingredient.name = stand_in.name
            new_ingredient.temperature = nil
            new_ingredient.minimum_temperature = nil
            new_ingredient.maximum_temperature = nil
            table.insert(swaps, {
                from = ingredient.name,
                to = stand_in.name,
            })
        end
        local key_name = new_ingredient.type .. ":" .. new_ingredient.name
        if by_key[key_name] ~= nil then
            by_key[key_name].amount = (by_key[key_name].amount or 1) + (new_ingredient.amount or 1)
        else
            by_key[key_name] = new_ingredient
            table.insert(ingredients, new_ingredient)
        end
    end
    return ingredients, swaps
end

local function unlocking_technologies(recipe_name)
    local names = {}
    for _, technology in pairs(data.raw.technology) do
        for _, effect in pairs(technology.effects or {}) do
            if effect.type == "unlock-recipe" and effect.recipe == recipe_name then
                table.insert(names, technology.name)
            end
        end
    end
    table.sort(names)
    return names
end

local function add_unlock(technology_name, recipe_name)
    local technology = data.raw.technology[technology_name]
    technology.effects = technology.effects or {}
    table.insert(technology.effects, {
        type = "unlock-recipe",
        recipe = recipe_name,
    })
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

-- The recipes making an item, the recycler's generated ones aside
local function makers_of(item_name)
    local recipes = {}
    for _, recipe_name in pairs(sorted_keys(data.raw.recipe)) do
        local recipe = data.raw.recipe[recipe_name]
        if not recycling.looks_generated(recipe) then
            for _, result in pairs(recipe.results or {}) do
                if result.type == "item" and result.name == item_name then
                    table.insert(recipes, recipe)
                end
            end
        end
    end
    return recipes
end

local function is_locked(recipe)
    return recipe.surface_conditions ~= nil and next(recipe.surface_conditions) ~= nil
end

-- Whether a science pack is a planet's own: every recipe making it is locked to some planets by its surface conditions (the starting planet's packs aren't locked, so they're no planet's, like rewards' family_pack says)
local function is_planet_pack(pack)
    local recipes = makers_of(pack)
    if #recipes == 0 then
        return false
    end
    for _, recipe in pairs(recipes) do
        if not is_locked(recipe) then
            return false
        end
    end
    return true
end

-- The science pack the room's planet makes itself: a planet's own pack (is_planet_pack) whose recipe the room's surface accepts, and which the room makes isolatably, or nil
local function own_pack(sort, room_key, excluded)
    for _, pack in pairs(sorted_keys(dutils.lab_inputs())) do
        if is_planet_pack(pack) and is_isolatable_in(sort, gutils.key("item", pack), room_key, excluded) then
            for _, recipe in pairs(makers_of(pack)) do
                if surface_sets.accepted(recipe)[room_key] ~= nil then
                    return pack
                end
            end
        end
    end
    return nil
end

-- A trigger the room meets itself (isolatably, without the recipe), for a copy of a technology whose trigger was old_trigger: of its kind if one fits, else of another kind, preferring what only the room's family has, closest in depth to the old trigger at home
local function local_trigger(sort, old_trigger, room_key, home_rooms, excluded)
    local kinds = {
        old_trigger.type,
    }
    for _, kind in pairs({
        "craft-item",
        "mine-entity",
        "craft-fluid",
    }) do
        if kind ~= old_trigger.type then
            table.insert(kinds, kind)
        end
    end
    local old_source = rewards.trigger_source_keys(old_trigger)[1]
    local old_depth = old_source ~= nil and helpers.depth_of(sort, old_source, home_rooms) or nil
    local rooms = {
        [room_key] = true,
    }
    local function met_there(candidate)
        return helpers.met_by_own_recipe(sort, candidate, rooms, excluded)
    end
    for _, kind in pairs(kinds) do
        local options = {}
        if kind == "craft-item" or kind == "mine-entity" or kind == "craft-fluid" then
            options = helpers.trigger_options(kind)
        end
        local pick = closest_local(sort, options, room_key, old_depth, excluded, met_there)
        if pick ~= nil then
            return research_triggers.make({
                kind = kind,
                target = pick.name,
            }, kind == old_trigger.type and old_trigger or nil, {}, {})
        end
    end
    return nil
end

-- A copy of the technology researchable on the room from the planet's own resources, unlocking the version, as { name, notes }, or nil (with why) when its research can't be made local
local function technology_copy(sort, source, variant_name, room_key, home_rooms, excluded)
    local copy = table.deepcopy(source)
    copy.name = scaffolds.planet_variant_name(source.name, room_name(room_key))
    if data.raw.technology[copy.name] ~= nil then
        -- Another moved recipe of the technology got a copy for this planet already, which unlocks this version too
        add_unlock(copy.name, variant_name)
        return {
            name = copy.name,
            shared = true,
            notes = {},
        }
    end
    local planet = data.raw.planet[room_name(room_key)]
    copy.localised_name = {
        "propertyrandomizer-name.planet-variant",
        locale_utils.find_localised_name(source),
        planet ~= nil and planet.localised_name or {
            "space-location-name." .. room_name(room_key),
        },
    }
    copy.effects = {
        {
            type = "unlock-recipe",
            recipe = variant_name,
        },
    }
    local notes = {}
    if source.research_trigger ~= nil then
        local trigger = local_trigger(sort, source.research_trigger, room_key, home_rooms, excluded)
        if trigger == nil then
            return nil, "nothing there to research it by"
        end
        copy.research_trigger = trigger
        table.insert(notes, "trigger " .. helpers.trigger_text(source.research_trigger) .. " --> " .. helpers.trigger_text(trigger))
    elseif source.unit ~= nil then
        -- Other planets' packs become the planet's own pack, once (a unit lists each pack once); the starting planet's packs stay
        local pack = own_pack(sort, room_key, excluded)
        local ingredients = {}
        local has_own = false
        for _, ingredient in pairs(source.unit.ingredients or {}) do
            if helpers.pack_name(ingredient) == pack then
                has_own = true
            end
        end
        local changes = {}
        for _, ingredient in pairs(source.unit.ingredients or {}) do
            local name = helpers.pack_name(ingredient)
            if name == pack or not is_planet_pack(name) then
                table.insert(ingredients, table.deepcopy(ingredient))
            elseif pack == nil then
                return nil, "it takes " .. name .. ", and nothing there is a science pack of its own"
            elseif has_own then
                table.insert(changes, name .. " dropped")
            else
                local swapped = table.deepcopy(ingredient)
                if swapped[1] ~= nil then
                    swapped[1] = pack
                else
                    swapped.name = pack
                end
                table.insert(ingredients, swapped)
                has_own = true
                table.insert(changes, name .. " --> " .. pack)
            end
        end
        copy.unit.ingredients = ingredients
        if #changes > 0 then
            table.insert(notes, "science " .. table.concat(changes, ", "))
        end
    end
    -- Its prerequisites are the ones researchable there and the planet's discovery
    local prerequisites = {}
    local is_listed = {}
    local dropped = {}
    for _, name in pairs(source.prerequisites or {}) do
        if is_listed[name] == nil then
            if is_isolatable_in(sort, gutils.key("technology", name), room_key) then
                is_listed[name] = true
                table.insert(prerequisites, name)
            else
                table.insert(dropped, name)
            end
        end
    end
    for _, name in pairs(sorted_keys(helpers.discoverers({
        [room_key] = true,
    }))) do
        if is_listed[name] == nil then
            is_listed[name] = true
            table.insert(prerequisites, name)
            table.insert(notes, "prerequisite " .. name .. " added")
        end
    end
    if #dropped > 0 then
        table.insert(notes, "prerequisites " .. table.concat(dropped, ", ") .. " dropped")
    end
    copy.prerequisites = prerequisites
    data:extend({
        copy,
    })
    return {
        name = copy.name,
        notes = notes,
    }
end

-- The version of a recipe for a room: the recipe with the given ingredients, named after the planet with its icon as a badge, locked to it (a fixed lock, locks.lua; locks.realize must run after)
local function add_version(recipe, room_key, ingredients)
    local variant = table.deepcopy(recipe)
    variant.name = scaffolds.planet_variant_name(recipe.name, room_name(room_key))
    scaffolds.name_variant(variant, recipe, room_name(room_key))
    local icons = scaffolds.badged_icons(recipe, room_name(room_key))
    if icons ~= nil then
        variant.icons = icons
        variant.icon = nil
    end
    variant.ingredients = table.deepcopy(ingredients)
    data:extend({
        variant,
    })
    locks.fix("recipe", variant.name, {
        [room_key] = true,
    })
    return variant.name
end

-- Takes a version back out of the game; a technology copy it made goes too, unless another lock's version still uses it, which then owns it
local function remove_version(repair)
    data.raw.recipe[repair.variant_name] = nil
    remove_unlocks(repair.variant_name)
    locks.unfix("recipe", repair.variant_name)
    if repair.copy_name ~= nil then
        local heir
        for _, repairs in pairs(lock_repairs.made) do
            for _, other in pairs(repairs) do
                if heir == nil and other ~= repair and other.tech_name == repair.copy_name and data.raw.recipe[other.variant_name] ~= nil then
                    heir = other
                end
            end
        end
        if heir ~= nil then
            heir.copy_name = repair.copy_name
        else
            data.raw.technology[repair.copy_name] = nil
        end
    end
end

-- state.variants_of with a version added or taken out, as a new table (a stage put back restores the old one, see run_stage in execute.lua)
local function with_variant(variants_of, recipe_name, variant_name, should_add)
    local copy = table.deepcopy(variants_of or {})
    local names = {}
    for _, name in pairs(copy[recipe_name] or {}) do
        if name ~= variant_name then
            table.insert(names, name)
        end
    end
    if should_add then
        table.insert(names, variant_name)
    end
    copy[recipe_name] = #names > 0 and names or nil
    return copy
end

-- The fluids each planet's tiles can be pumped for (TilePrototype::fluid), from the tiles its map generation places, as planet name --> fluid name --> true
-- The ocean swap gives a planet's ocean tiles the new ocean's fluid (oceans.lua), so this tells a planet's ocean before and after it
lock_repairs.ocean_fluids = function()
    local fluids = {}
    for planet_name, planet in pairs(data.raw.planet) do
        local tile_settings = (((planet.map_gen_settings or {}).autoplace_settings or {}).tile or {}).settings or {}
        for tile_name, _ in pairs(tile_settings) do
            local tile = data.raw.tile[tile_name]
            if tile ~= nil and tile.fluid ~= nil then
                fluids[planet_name] = fluids[planet_name] or {}
                fluids[planet_name][tile.fluid] = true
            end
        end
    end
    return fluids
end

-- Every recipe's ingredients, as recipe name --> ingredient list, so recipes the planetary stages edit can be made again as they were
lock_repairs.ingredients_now = function()
    local ingredients = {}
    for recipe_name, recipe in pairs(data.raw.recipe) do
        ingredients[recipe_name] = table.deepcopy(recipe.ingredients or {})
    end
    return ingredients
end

-- Whether every recipe making the item has surface conditions (one making it at all), so the item can only be made on some planets
local function is_locked_item(item_name, makers)
    local recipes = makers[item_name] or {}
    if #recipes == 0 then
        return false
    end
    for _, recipe in pairs(recipes) do
        if recipe.surface_conditions == nil or next(recipe.surface_conditions) == nil then
            return false
        end
    end
    return true
end

-- Crafting categories only planet-locked machines craft (a machine is planet-locked when every item placing it can only be made on some planets), like metallurgy, which only the foundry and its duplicates craft, as category --> true
local function machine_only_categories(items, makers)
    local placers = {}
    for item_name, item in pairs(items) do
        if item.place_result ~= nil then
            placers[item.place_result] = placers[item.place_result] or {}
            table.insert(placers[item.place_result], item_name)
        end
    end
    local is_special = {}
    local is_shared = {}
    for _, machine in pairs(dutils.get_all_prots("entity")) do
        if machine.crafting_categories ~= nil then
            local is_locked = (placers[machine.name] or {})[1] ~= nil
            for _, item_name in pairs(placers[machine.name] or {}) do
                if not is_locked_item(item_name, makers) then
                    is_locked = false
                end
            end
            for _, category in pairs(machine.crafting_categories) do
                if is_locked then
                    is_special[category] = true
                else
                    is_shared[category] = true
                end
            end
        end
    end
    for category, _ in pairs(is_shared) do
        is_special[category] = nil
    end
    return is_special
end

-- The planet-locked crafting machine a recipe makes (its first result's item places it), or nil
local function made_machine(recipe, items)
    for _, result in pairs(recipe.results or {}) do
        local item = result.type == "item" and items[result.name] or nil
        if item ~= nil and item.place_result ~= nil then
            local machine = dutils.get_prot("entity", item.place_result)
            if machine ~= nil and machine.crafting_categories ~= nil then
                return machine
            end
        end
    end
    return nil
end

-- Takes each moved machine's ocean recipes along to its new planets (user, 2026-10-08: follow the machine)
-- A machine's ocean recipes are the recipes only machines like it craft (machine_only_categories) that took the ocean fluid of the planets its lock moved from, as the game had them before the planetary stages (state.ingredients_before, state.ocean_fluids_before)
-- Each new planet of the lock gets its own version, taking that planet's ocean now instead, locked to it and unlocked like the recipe; a planet the recipe already works on with that fluid gets none
-- Returns how many versions it made (locks.realize has run when it made any)
lock_repairs.follow_machines = function(state)
    if state.ocean_fluids_before == nil or state.ingredients_before == nil then
        return 0
    end
    local items = dutils.get_all_prots("item")
    local makers = {}
    for _, recipe in pairs(data.raw.recipe) do
        if not recycling.looks_generated(recipe) then
            for _, result in pairs(recipe.results or {}) do
                if result.type == "item" then
                    makers[result.name] = makers[result.name] or {}
                    table.insert(makers[result.name], recipe)
                end
            end
        end
    end
    local special = machine_only_categories(items, makers)
    local fluids_now = lock_repairs.ocean_fluids()
    local num_made = 0
    for _, id in pairs(sorted_keys(locks.moved)) do
        local lock = locks.moved[id]
        local recipe = lock.kind == "recipe" and data.raw.recipe[lock.name] or nil
        local machine = recipe ~= nil and rewards.bundle_of_lock(id) == nil and made_machine(recipe, items) or nil
        if machine ~= nil then
            local machine_categories = {}
            for _, category in pairs(machine.crafting_categories) do
                if special[category] ~= nil then
                    machine_categories[category] = true
                end
            end
            local old_fluids = {}
            for room_key, _ in pairs(lock.old) do
                local room = gutils.deconstruct(room_key)
                if room.type == "planet" then
                    for fluid_name, _ in pairs(state.ocean_fluids_before[room.name] or {}) do
                        old_fluids[fluid_name] = true
                    end
                end
            end
            for _, recipe_name in pairs(sorted_keys(state.ingredients_before)) do
                local ocean_recipe = data.raw.recipe[recipe_name]
                local categories = ocean_recipe ~= nil and (ocean_recipe.categories or { ocean_recipe.category or "crafting" }) or {}
                local is_machines = #categories > 0 and not recycling.looks_generated(ocean_recipe)
                for _, category in pairs(categories) do
                    if machine_categories[category] == nil then
                        is_machines = false
                    end
                end
                -- A machine picking recipes by ingredient could mix the versions up, so those stay as they are
                if is_machines and #furnace_selection.pools_for(furnace_selection.pools(), furnace_selection.recipe_categories(ocean_recipe)) > 0 then
                    is_machines = false
                end
                local old_fluid
                if is_machines then
                    for _, ingredient in pairs(state.ingredients_before[recipe_name]) do
                        if old_fluid == nil and ingredient.type == "fluid" and old_fluids[ingredient.name] ~= nil then
                            old_fluid = ingredient.name
                        end
                    end
                end
                if old_fluid ~= nil then
                    for _, room_key in pairs(sorted_keys(lock.rooms)) do
                        local room = gutils.deconstruct(room_key)
                        local new_fluid = room.type == "planet" and lock.old[room_key] == nil and sorted_keys(fluids_now[room.name] or {})[1] or nil
                        if new_fluid ~= nil then
                            local version_name = scaffolds.planet_variant_name(recipe_name .. "-with-" .. new_fluid, room.name)
                            -- The recipe as it is now works there already when it takes that fluid and the planet's surface allows it
                            local works_there = false
                            for _, ingredient in pairs(ocean_recipe.ingredients or {}) do
                                if ingredient.type == "fluid" and ingredient.name == new_fluid then
                                    works_there = ocean_recipe.surface_conditions == nil or next(ocean_recipe.surface_conditions) == nil
                                end
                            end
                            if not works_there and data.raw.recipe[version_name] == nil then
                                local ingredients = {}
                                local merged
                                for _, ingredient in pairs(state.ingredients_before[recipe_name]) do
                                    if ingredient.type == "fluid" and (ingredient.name == old_fluid or ingredient.name == new_fluid) then
                                        if merged == nil then
                                            merged = {
                                                type = "fluid",
                                                name = new_fluid,
                                                amount = 0,
                                            }
                                            table.insert(ingredients, merged)
                                        end
                                        merged.amount = merged.amount + (ingredient.amount or 0)
                                    else
                                        table.insert(ingredients, table.deepcopy(ingredient))
                                    end
                                end
                                local variant = table.deepcopy(ocean_recipe)
                                variant.name = version_name
                                scaffolds.name_variant(variant, ocean_recipe, room.name)
                                local icons = scaffolds.badged_icons(ocean_recipe, room.name)
                                if icons ~= nil then
                                    variant.icons = icons
                                    variant.icon = nil
                                end
                                variant.ingredients = ingredients
                                data:extend({
                                    variant,
                                })
                                locks.fix("recipe", version_name, {
                                    [room_key] = true,
                                })
                                for _, tech_name in pairs(unlocking_technologies(recipe_name)) do
                                    add_unlock(tech_name, version_name)
                                end
                                lock_repairs.made[id] = lock_repairs.made[id] or {}
                                table.insert(lock_repairs.made[id], {
                                    recipe_name = recipe_name,
                                    room_key = room_key,
                                    variant_name = version_name,
                                    follows = machine.name,
                                    notes = {},
                                })
                                state.variants_of = with_variant(state.variants_of, recipe_name, version_name, true)
                                num_made = num_made + 1
                                log("Planet lock: " .. id .. " takes " .. recipe_name .. " to " .. room.name .. " with " .. machine.name .. ": " .. version_name .. " (" .. old_fluid .. " --> " .. new_fluid .. ")")
                            end
                        end
                    end
                end
            end
        end
    end
    if num_made > 0 then
        locks.realize()
    end
    return num_made
end

-- Makes versions of moved recipes for the new planets where what they must keep fails (failures from check.required_failures in the sort after the moves)
-- Returns how many versions it made (locks.realize has run when it made any)
lock_repairs.make_local = function(sort, failures, state)
    -- Lock id --> rooms the lock moved to where its recipe fails something
    local needs = {}
    for _, failure in pairs(failures) do
        if failure.context ~= nil then
            local lock, id = locks.lock_of_recipe(failure.keys[1])
            local room_key = top.context_room(failure.context)
            -- A reward's members get their versions from the reward move (rewards.lua)
            if lock ~= nil and rewards.bundle_of_lock(id) == nil and lock.old[room_key] == nil and (lock.rooms[room_key] ~= nil or lock.new[room_key] ~= nil) then
                needs[id] = needs[id] or {}
                needs[id][room_key] = true
            end
        end
    end
    local num_made = 0
    for _, id in pairs(sorted_keys(needs)) do
        local lock = locks.moved[id]
        local recipe = data.raw.recipe[lock.name]
        if recipe ~= nil then
            local home_rooms = {}
            for room_key, _ in pairs(lock.old) do
                if gutils.deconstruct(room_key).type == "planet" then
                    home_rooms[room_key] = true
                end
            end
            for _, room_key in pairs(sorted_keys(needs[id])) do
                local excluded = own_recipes(recipe)
                local ingredients, swaps = local_ingredients(sort, recipe, room_key, home_rooms, excluded)
                local why
                if ingredients == nil then
                    why = "nothing there stands in for " .. tostring(swaps)
                else
                    local version_name = scaffolds.planet_variant_name(recipe.name, room_name(room_key))
                    excluded[gutils.key("recipe", version_name)] = true
                    local techs = unlocking_technologies(recipe.name)
                    local tech_name
                    for _, name in pairs(techs) do
                        if tech_name == nil and is_isolatable_in(sort, gutils.key("technology", name), room_key, excluded) then
                            tech_name = name
                        end
                    end
                    if data.raw.recipe[version_name] ~= nil then
                        why = "an earlier stage made " .. version_name .. " already"
                    elseif #swaps == 0 and (tech_name ~= nil or #techs == 0) then
                        why = "it takes nothing the planet can't make, and its research is already doable there"
                    else
                        local variant_name = add_version(recipe, room_key, ingredients)
                        local repair = {
                            recipe_name = recipe.name,
                            room_key = room_key,
                            variant_name = variant_name,
                            notes = {},
                        }
                        for _, swap in pairs(swaps) do
                            table.insert(repair.notes, swap.from .. " --> " .. swap.to)
                        end
                        if tech_name ~= nil then
                            add_unlock(tech_name, variant_name)
                            repair.tech_name = tech_name
                        elseif #techs > 0 then
                            local copy, copy_why = technology_copy(sort, data.raw.technology[techs[1]], variant_name, room_key, home_rooms, excluded)
                            if copy == nil then
                                remove_version(repair)
                                why = copy_why
                                repair = nil
                            else
                                repair.tech_name = copy.name
                                if copy.shared ~= true then
                                    repair.copy_name = copy.name
                                end
                                table.insert(repair.notes, "researched by " .. copy.name .. (#copy.notes > 0 and (" (" .. table.concat(copy.notes, "; ") .. ")") or ""))
                            end
                        end
                        if repair ~= nil then
                            lock_repairs.made[id] = lock_repairs.made[id] or {}
                            table.insert(lock_repairs.made[id], repair)
                            state.variants_of = with_variant(state.variants_of, recipe.name, variant_name, true)
                            num_made = num_made + 1
                            log("Planet lock repair: " .. id .. " on " .. room_name(room_key) .. ": " .. variant_name .. (#repair.notes > 0 and (" (" .. table.concat(repair.notes, ", ") .. ")") or ""))
                        end
                    end
                end
                if why ~= nil then
                    log("Planet lock repair: " .. id .. " on " .. room_name(room_key) .. ": no version, since " .. why)
                end
            end
        end
    end
    if num_made > 0 then
        locks.realize()
    end
    return num_made
end

-- Takes back the versions made for a lock (one the lock stage reverts); locks.realize must run after
lock_repairs.undo = function(id, state)
    for _, repair in pairs(lock_repairs.made[id] or {}) do
        remove_version(repair)
        state.variants_of = with_variant(state.variants_of, repair.recipe_name, repair.variant_name, false)
        log("Planet lock repair: " .. id .. " on " .. room_name(repair.room_key) .. ": " .. repair.variant_name .. " taken back with the lock")
    end
    lock_repairs.made[id] = nil
end

-- The versions made so far, for lock_repairs.restore when a stage is undone
lock_repairs.save = function()
    return table.deepcopy(lock_repairs.made)
end

-- Puts the bookkeeping back as lock_repairs.save had it, for a stage undone with data.raw put back: versions made since forget their fixed locks (locks.fixed isn't put back with data.raw)
lock_repairs.restore = function(saved)
    local is_saved = {}
    for _, repairs in pairs(saved) do
        for _, repair in pairs(repairs) do
            is_saved[repair.variant_name] = true
        end
    end
    for _, repairs in pairs(lock_repairs.made) do
        for _, repair in pairs(repairs) do
            if is_saved[repair.variant_name] == nil then
                locks.unfix("recipe", repair.variant_name)
            end
        end
    end
    lock_repairs.made = saved
end

-- Forgets every version, for when the game goes back to how it was before the lock stage (data.raw is put back, but locks.fixed isn't)
lock_repairs.forget = function()
    for _, repairs in pairs(lock_repairs.made) do
        for _, repair in pairs(repairs) do
            locks.unfix("recipe", repair.variant_name)
        end
    end
    lock_repairs.made = {}
end

-- How many versions and technology copies the game has, for the log (copies are fine, but the user wants to know how many, 2026-09-30)
lock_repairs.log_counts = function()
    local num_versions = 0
    local num_copies = 0
    for _, repairs in pairs(lock_repairs.made) do
        for _, repair in pairs(repairs) do
            if data.raw.recipe[repair.variant_name] ~= nil then
                num_versions = num_versions + 1
            end
            if repair.copy_name ~= nil and data.raw.technology[repair.copy_name] ~= nil then
                num_copies = num_copies + 1
            end
        end
    end
    log("Planet lock repairs: " .. num_versions .. " recipe versions and " .. num_copies .. " technology copies for moved recipes")
end

return lock_repairs
