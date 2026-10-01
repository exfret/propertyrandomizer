-- Planet copies (setting propertyrandomizer-dupes; run from data-final-fixes.lua before the other duplicates)
-- A copy of every planet for each dupe number its icon has a recolored copy for (dev/dupe-planets.txt, made by dev/make-dupe-graphics.py: numbers 2 to 9, the original being 1), up to the setting propertyrandomizer-dupe-count (dupe.highest_number: two copies by default), so planetary randomization has more planets to make different
-- A copy is the planet prototype again under a new name: the same map generation (from its own seed, since the game seeds a planet by its name), surface properties, pollutant, lightning and freezing. With it come:
--   * ocean tiles of its own: clones of its original's handwritten ocean family (randomizations/planetary/oceans.lua), so an ocean swap can give it another ocean than its original's
--   * wild entities of its own: clones of the entities found in the wild on its original that entity randomization could move (lib/wild-entities.lua: trees, rocks, ruins, but not resources or enemies), since it only moves an entity found on one planet; to the player they're the same entities
--   * space connections: each connection of the original again, ending at the copy; where both ends have copies with the same number, one between the copies too
--   * discovery: a copy of each technology discovering the original, discovering the copy; the starting planet, which nothing discovers, gets one modeled on the cheapest discovery technology
--   * science: copies of the planet's own science packs that have recolored icons (dev/dupe-items.txt, with no number badge), named after the copy, locked to the copy while the originals stay locked to their planet (lib/surface-sets.lua properties, through randomizations/planetary/locks.lua); every lab takes the copies
--   * a parallel technology tree per dupe number: a copy of each technology whose research takes a copied pack, taking that number's copies instead, and of each technology on the way from a copied planet's discovery to its packs, rooted at the copy's discovery (so a copy's packs don't wait on its original), with prerequisites among the copies; the duplicates' recipes with that number are unlocked there (dupe.recipe)
--   * a split: a share of the original technologies take a copied pack instead of the original (one of its copies), decided by branch of the tree, so the trees interleave; infinite research takes a random mix, and the endgame (research taking every planet's packs) takes every version; checked with the logic graph (what was reachable stays reachable), else undone
-- The duplicates belong to the copies with their number (lib/dupe-planet-locks.lua)
-- Everything else works on the copy as on its original, since surface conditions go by properties and the copy has its original's
-- A planet's own science packs are the lab inputs whose recipes only that planet accepts; for the starting planet, whose packs have no conditions, the lab inputs whose recipes it accepts at all

local constants = require("helper-tables/constants")
local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local rng = require("lib/random/rng")
local dupe = require("lib/dupe")
local locale_utils = require("lib/locale")
local lu = require("lib/lookup/init")
local surface_sets = require("lib/surface-sets")
local wild = require("lib/wild-entities")
local top = require("lib/graph/context-sort")
local new_logic = require("lib/logic/init")
local lutils = require("lib/logic/logic-utils")
local locks = require("randomizations/planetary/locks")
local oceans = require("randomizations/planetary/oceans")
local planet_names = require("lib/planet-names")

local dupe_planets = {}

-- How far along its orbit each further copy sits from its original on the star map, as a fraction of a turn
local ORIENTATION_NUDGE = 0.035
-- The share of the copied science packs in original technologies that become one of the copies instead (the split: roots of the tree's branches, see split)
local SPLIT_SHARE = 1 / 3
-- Where a copied technology's number badge goes on its icon (like the other duplicates')
local BADGE_SCALE = 1 / 3
local BADGE_SHIFT = {
    -40,
    -40,
}
-- The depths an ocean family lists its tiles by (randomizations/planetary/oceans.lua)
local DEPTHS = {
    "shallow",
    "deep",
}

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

local function sorted_prototypes(class)
    local list = {}
    for _, name in pairs(sorted_keys(data.raw[class] or {})) do
        table.insert(list, data.raw[class][name])
    end
    return list
end

local function lists(names, name)
    for _, listed in pairs(names or {}) do
        if listed == name then
            return true
        end
    end
    return false
end

local function is_discovery(tech)
    for _, effect in pairs(tech.effects or {}) do
        if effect.type == "unlock-space-location" then
            return true
        end
    end
    return false
end

-- Space location name --> the technologies discovering it (sorted by name), from their unlock-space-location effects
local function discovery_technologies()
    local discovery = {}
    for _, tech in pairs(sorted_prototypes("technology")) do
        for _, effect in pairs(tech.effects or {}) do
            if effect.type == "unlock-space-location" then
                discovery[effect.space_location] = discovery[effect.space_location] or {}
                table.insert(discovery[effect.space_location], tech)
            end
        end
    end
    return discovery
end

-- The discovery technology with the fewest research units, the model for a planet nothing discovers
local function cheapest_discovery(discovery)
    local cheapest = nil
    for _, name in pairs(sorted_keys(discovery)) do
        for _, tech in pairs(discovery[name]) do
            if tech.unit ~= nil and tech.unit.count ~= nil and (cheapest == nil or tech.unit.count < cheapest.unit.count) then
                cheapest = tech
            end
        end
    end
    return cheapest
end

-- A space location's name for the player
local function location_name(name)
    local location = data.raw.planet[name] or (data.raw["space-location"] or {})[name]
    if location ~= nil and location.localised_name ~= nil then
        return location.localised_name
    end
    return {"space-location-name." .. name}
end

-- A prototype's icons as a list (its icons, else its icon)
local function icon_list(prototype)
    if prototype.icons ~= nil then
        return prototype.icons
    end
    return {
        {
            icon = prototype.icon,
            icon_size = prototype.icon_size,
        },
    }
end

-- The rooms (planets and surfaces) accepting a recipe's surface conditions, among the given room keys
local function accepting(recipe, room_keys)
    return surface_sets.accepting(recipe.surface_conditions or {}, room_keys, surface_sets.value)
end

-- Whether the science pack made by these recipes is the planet's own (see the header)
local function owned_by(planet, recipes, room_keys)
    local key = gutils.key("planet", planet.name)
    if planet.name == constants.starting_planet then
        for _, recipe in pairs(recipes) do
            if accepting(recipe, room_keys)[key] ~= nil then
                return true
            end
        end
        return false
    end
    for _, recipe in pairs(recipes) do
        local accepted = accepting(recipe, room_keys)
        if accepted[key] == nil then
            return false
        end
        for room_key, _ in pairs(accepted) do
            if room_key ~= key then
                return false
            end
        end
    end
    return true
end

-- The planet prototype again under the name of its copy with this dupe number, beside its original on the star map
local function copy_planet(planet, number)
    local copy = dupe.prototype(planet, number)
    dupe.recolor_graphics(copy, number)
    copy.orientation = ((planet.orientation or 0) + ORIENTATION_NUDGE * (number - 1)) % 1
    copy.order = (planet.order or "") .. "-" .. tostring(number)
    -- With random planet names, the copy gets one of its own rather than its original's with a number
    if config.planet_names then
        planet_names.name(copy)
    end
    return copy
end

-- Clones of the original's ocean tiles for the copy (its map generation places the clones instead), registered as the copy's ocean family
-- Returns how many tiles were cloned
-- Dupe number --> original tile name --> its clone with that number (planets sharing an ocean tile share its clones)
local tile_clones = {}
local function copy_tiles(planet, copy, number)
    tile_clones[number] = tile_clones[number] or {}
    local family = oceans.families[planet.name]
    local map_gen_settings = copy.map_gen_settings or {}
    local tile_settings = ((map_gen_settings.autoplace_settings or {}).tile or {}).settings
    if family == nil or tile_settings == nil then
        return 0
    end
    -- Only the tiles the copy lists generate there: the original's ocean tiles would otherwise generate as defaults (AutoplaceSettings.treat_missing_as_default, which reads true in game on planets that don't set it), with the same probabilities as their clones
    map_gen_settings.autoplace_settings.tile.treat_missing_as_default = false
    local new_family = {
        fluid = family.fluid,
    }
    local num_cloned = 0
    for _, depth in pairs(DEPTHS) do
        new_family[depth] = {}
        for _, tile_name in pairs(family[depth]) do
            local tile = data.raw.tile[tile_name]
            if tile ~= nil then
                if tile_clones[number][tile_name] == nil then
                    tile_clones[number][tile_name] = dupe.tile(tile, number)
                    num_cloned = num_cloned + 1
                end
                local clone = tile_clones[number][tile_name]
                tile_settings[clone.name] = table.deepcopy(tile_settings[tile_name]) or {}
                tile_settings[tile_name] = nil
                table.insert(new_family[depth], clone.name)
            end
        end
    end
    oceans.families[copy.name] = new_family
    table.insert(oceans.planet_order, copy.name)
    return num_cloned
end

-- The lightning rules naming an entity (like Fulgora's, which make lightning strike the bigger ruins first) name its clone on the copy too
local function follow_lightning_rules(copy, entity_name, clone_name)
    local lightning = copy.lightning_properties
    if lightning == nil then
        return
    end
    local rule_lists = {
        lightning.priority_rules or {},
        lightning.exemption_rules or {},
    }
    for _, rules in pairs(rule_lists) do
        local added = {}
        for _, rule in pairs(rules) do
            if rule.type == "id" and rule.string == entity_name then
                local clone_rule = table.deepcopy(rule)
                clone_rule.string = clone_name
                table.insert(added, clone_rule)
            end
        end
        for _, rule in pairs(added) do
            table.insert(rules, rule)
        end
    end
end

-- Clones of the movable wild entities found on the original (wild.movable) for the copy, so each is found in the wild on one planet and entity randomization can move it
-- The copy places the clones as it placed the originals: listed in its settings where they were, or through the same slider
-- The originals are kept off the copy, since its settings and sliders would still place them (keep_clones_home then keeps the clones off the other planets with their sliders)
-- Returns how many entities were cloned
-- Dupe number --> original entity name --> its clone with that number (planets sharing a wild entity share its clones)
local entity_clones = {}
-- Clone name --> the set of planet copies it's found on
local clone_homes = {}
dupe_planets.copy_wild_entities = function(planet, copy, number, kept)
    entity_clones[number] = entity_clones[number] or {}
    local entity_settings = ((copy.map_gen_settings or {}).autoplace_settings or {}).entity
    local entities = dutils.get_all_prots("entity")
    local room = {
        type = "planet",
        name = planet.name,
    }
    local num_cloned = 0
    for _, name in pairs(sorted_keys(entities)) do
        local entity = entities[name]
        -- Clones made for an earlier planet aren't kept home yet, so they could look found here
        if clone_homes[name] == nil and wild.movable(entity, kept) and lutils.check_in_room(room, entity) then
            local clone = entity_clones[number][name]
            if clone == nil then
                clone = dupe.wild_entity(entity, number)
                entity_clones[number][name] = clone
                num_cloned = num_cloned + 1
            end
            clone_homes[clone.name] = clone_homes[clone.name] or {}
            clone_homes[clone.name][copy.name] = true
            if entity_settings ~= nil and entity_settings.settings ~= nil and entity_settings.settings[name] ~= nil then
                entity_settings.settings[clone.name] = entity_settings.settings[name]
                entity_settings.settings[name] = nil
            end
            wild.keep_off(copy, name)
            follow_lightning_rules(copy, name, clone.name)
        end
    end
    return num_cloned
end

-- A clone placed by a slider (AutoplaceSpecification.control) would show up on every planet with that slider: its original's, the other copies, and other planets sharing the slider
-- So it's kept off every one of those but its own copies
-- Returns how many times a clone was kept off a planet
dupe_planets.keep_clones_home = function()
    local num_kept_off = 0
    for _, clone_name in pairs(sorted_keys(clone_homes)) do
        local control = dutils.get_prot("entity", clone_name).autoplace.control
        if control ~= nil then
            for _, other in pairs(sorted_prototypes("planet")) do
                local controls = (other.map_gen_settings or {}).autoplace_controls
                if clone_homes[clone_name][other.name] == nil and controls ~= nil and controls[control] ~= nil then
                    wild.keep_off(other, clone_name)
                    num_kept_off = num_kept_off + 1
                end
            end
        end
    end
    return num_kept_off
end

-- Copies of the space connections ending at copied planets: each connection again per copied end, and one between two copies with the same dupe number where both ends have one
-- copies: dupe number --> original planet name --> its copy with that number
-- Returns how many connections were added
local function copy_connections(copies)
    local num_added = 0
    for _, connection in pairs(sorted_prototypes("space-connection")) do
        for _, number in pairs(sorted_keys(copies)) do
            local from_copy = copies[number][connection.from]
            local to_copy = copies[number][connection.to]
            local variants = {}
            if from_copy ~= nil then
                table.insert(variants, {
                    suffix = "from",
                    from = from_copy.name,
                    to = connection.to,
                })
            end
            if to_copy ~= nil then
                table.insert(variants, {
                    suffix = "to",
                    from = connection.from,
                    to = to_copy.name,
                })
            end
            if from_copy ~= nil and to_copy ~= nil then
                table.insert(variants, {
                    suffix = "both",
                    from = from_copy.name,
                    to = to_copy.name,
                })
            end
            for _, variant in pairs(variants) do
                local copy = dupe.prototype(connection, {
                    suffix = tostring(number) .. "-" .. variant.suffix,
                })
                copy.from = variant.from
                copy.to = variant.to
                copy.order = (connection.order or "") .. "-" .. variant.suffix .. "-" .. tostring(number)
                copy.localised_name = {
                    "",
                    location_name(variant.from),
                    " - ",
                    location_name(variant.to),
                }
                -- The connection's icons show its ends: an end's planet icon becomes the copy's where the end is a copy
                local ends = {
                    connection.from,
                    connection.to,
                }
                for _, icon in pairs(copy.icons or {}) do
                    for _, original_name in pairs(ends) do
                        local original = data.raw.planet[original_name]
                        local planet_copy = copies[number][original_name]
                        if original ~= nil and planet_copy ~= nil and icon.icon == original.icon and (variant.from == planet_copy.name or variant.to == planet_copy.name) then
                            icon.icon = planet_copy.icon
                        end
                    end
                end
                num_added = num_added + 1
            end
        end
    end
    return num_added
end

-- Copies of the technologies discovering the original, discovering the copy (with its dupe number); a planet nothing discovers gets one modeled on the cheapest discovery technology
-- discovery_copies gets original technology name --> its copy's name, for the parallel tree's prerequisites (of the tree with this number)
-- Returns how many technologies were added
local function copy_discovery(planet, copy, number, discovery, model, discovery_copies)
    local techs = discovery[planet.name]
    local num_added = 0
    if techs ~= nil then
        dupe.technology_copies[number] = dupe.technology_copies[number] or {}
        for _, tech in pairs(techs) do
            local copy_tech = dupe.prototype(tech, number)
            discovery_copies[tech.name] = copy_tech.name
            -- A duplicate of a recipe the original discovers is discovered with the copy that has its number (dupe.recipe)
            dupe.technology_copies[number][tech.name] = copy_tech
            for _, effect in pairs(copy_tech.effects or {}) do
                if effect.type == "unlock-space-location" and effect.space_location == planet.name then
                    effect.space_location = copy.name
                end
            end
            copy_tech.localised_name = {
                "propertyrandomizer.planet_discovery",
                copy.localised_name,
            }
            if dupe.recolor_graphics(copy_tech, number) == 0 then
                copy_tech.icons = table.deepcopy(icon_list(tech))
                table.insert(copy_tech.icons, dupe.number_badge(number, BADGE_SCALE, BADGE_SHIFT))
            end
            num_added = num_added + 1
        end
        return num_added
    end
    local copy_tech = dupe.prototype(model, {
        suffix = tostring(number) .. "-" .. planet.name,
    })
    -- Only the discovery itself (and travel to platforms, which the model's discovery may bring): the model's recipe unlocks belong to its own planet
    local effects = {}
    for _, effect in pairs(model.effects or {}) do
        if effect.type == "unlock-space-location" then
            table.insert(effects, {
                type = "unlock-space-location",
                space_location = copy.name,
            })
        elseif effect.type == "unlock-travel-to-space-platforms" then
            table.insert(effects, table.deepcopy(effect))
        end
    end
    copy_tech.effects = effects
    copy_tech.localised_name = {
        "propertyrandomizer.planet_discovery",
        copy.localised_name,
    }
    copy_tech.localised_description = copy.localised_description or {"space-location-description." .. planet.name}
    -- The copy's own (recolored) icon; its original gave the model's discovery no icon
    copy_tech.icon = nil
    copy_tech.icons = table.deepcopy(icon_list(copy))
    return 1
end

-- Copies of the planet's own science packs with recolored icons for the copy's dupe number, locked to the copy (fixes, applied by the caller), taken by every lab that takes the original
-- Each copy and its recipes are named after the copy planet, since no number badge sets it apart
-- Fills in packs: copies (dupe number --> original pack name --> copy name), owner (pack name --> the planet whose own pack it is, for originals and copies alike) and recipe_copies (dupe number --> original recipe name --> the copy's recipe name)
-- Returns how many packs were copied
local function copy_packs(planet, copy, number, room_keys, packs, fixes)
    packs.copies[number] = packs.copies[number] or {}
    packs.recipe_copies[number] = packs.recipe_copies[number] or {}
    local num_copied = 0
    for _, pack_name in pairs(sorted_keys(dutils.lab_inputs())) do
        local pack = dupe.find_prototype("item", pack_name)
        -- An original pack, not duplicated by anything else (one copied here for another dupe number is copied again)
        local is_free = pack ~= nil and pack.orig_name == nil and (not dupe.has_been_duplicated[rng.key({prototype = pack})] or packs.owner[pack_name] ~= nil)
        if is_free and pack.hidden ~= true and dupe.item_has_recolor(pack, number) then
            local recipes = dupe.item_recipes(pack)
            if #recipes > 0 and owned_by(planet, recipes, room_keys) then
                -- No number badge: a pack copy's color alone tells it apart from every other pack (dev/dupe-items.txt)
                local new_pack = dupe.item(pack, number, {
                    no_badge = true,
                })
                new_pack.default_import_location = copy.name
                new_pack.localised_name = {
                    "propertyrandomizer.planet_pack",
                    locale_utils.find_localised_name(pack),
                    location_name(copy.name),
                }
                for _, lab in pairs(data.raw.lab) do
                    if lists(lab.inputs, pack.name) then
                        table.insert(lab.inputs, new_pack.name)
                    end
                end
                local is_first_copy = packs.owner[pack.name] == nil
                packs.copies[number][pack.name] = new_pack.name
                packs.owner[pack.name] = planet.name
                packs.owner[new_pack.name] = copy.name
                -- The original's recipes stay its planet's alone (where they were locked at all), the copy's are the copy's alone
                for _, recipe in pairs(recipes) do
                    if is_first_copy and recipe.surface_conditions ~= nil and next(recipe.surface_conditions) ~= nil then
                        table.insert(fixes, {
                            recipe = recipe.name,
                            rooms = {
                                [gutils.key("planet", planet.name)] = true,
                            },
                        })
                    end
                end
                for _, recipe in pairs(dupe.item_recipes(new_pack)) do
                    table.insert(fixes, {
                        recipe = recipe.name,
                        rooms = {
                            [gutils.key("planet", copy.name)] = true,
                        },
                    })
                    local original = data.raw.recipe[recipe.orig_name]
                    if original ~= nil then
                        packs.recipe_copies[number][original.name] = recipe.name
                        recipe.localised_name = {
                            "propertyrandomizer.planet_pack",
                            locale_utils.find_localised_name(original),
                            location_name(copy.name),
                        }
                    end
                end
                num_copied = num_copied + 1
            end
        end
    end
    return num_copied
end

-- Whether the technology is leveled or infinite research (a count formula or a level cap), which the parallel tree and the split leave out
local function is_leveled(tech)
    return tech.unit ~= nil and (tech.unit.count_formula ~= nil or tech.max_level ~= nil)
end

-- Whether the technology's research takes one of the packs (a set of pack names)
local function takes_any(tech, pack_set)
    for _, ingredient in pairs((tech.unit or {}).ingredients or {}) do
        if pack_set[ingredient[1]] ~= nil then
            return true
        end
    end
    return false
end

-- Whether the technology's research takes the pack
local function takes(tech, pack_name)
    for _, ingredient in pairs((tech.unit or {}).ingredients or {}) do
        if ingredient[1] == pack_name then
            return true
        end
    end
    return false
end

-- The technologies the parallel tree and the split work on: researched with science packs (no formula or level cap: no infinite or leveled research), not discovering a planet, not copies, and taking a copied pack
local function tree_candidates(pack_copies)
    local candidates = {}
    for _, tech in pairs(sorted_prototypes("technology")) do
        if tech.unit ~= nil and tech.unit.ingredients ~= nil and not is_leveled(tech) and not is_discovery(tech) and not dupe.has_been_duplicated[rng.key({prototype = tech})] and takes_any(tech, pack_copies) then
            table.insert(candidates, tech)
        end
    end
    return candidates
end

-- A function giving a technology's name --> the set of technologies it needs through its prerequisites, all the way down (found when first asked)
local function prerequisite_closure()
    local closure = {}
    local function needs(name)
        if closure[name] == nil then
            local needed = {}
            -- Stored first, so a prerequisite cycle (which the game rejects anyway) ends here
            closure[name] = needed
            local tech = data.raw.technology[name]
            for _, prerequisite in pairs((tech or {}).prerequisites or {}) do
                needed[prerequisite] = true
                for further, _ in pairs(needs(prerequisite)) do
                    needed[further] = true
                end
            end
        end
        return closure[name]
    end
    return needs
end

-- The technologies on the way from a planet's discovery to its own science packs: each technology unlocking one of the packs' recipes that needs a discovery technology of the planet, and every technology between the two (leveled research and other discoveries aside)
-- A planet copy gets copies of them (parallel_tree), so its packs don't wait on its original's discovery: otherwise Gleba's copy makes its agricultural packs only after Gleba's discovery, and a discovery that takes them (randomizations/planetary/discovery.lua) could wait on itself
-- Adds the names to chain (a set)
local function add_discovery_chain(chain, discovery_names, pack_recipe_names, needs)
    for _, tech in pairs(sorted_prototypes("technology")) do
        local unlocks_pack = false
        for _, effect in pairs(tech.effects or {}) do
            if effect.type == "unlock-recipe" and pack_recipe_names[effect.recipe] ~= nil then
                unlocks_pack = true
            end
        end
        if unlocks_pack and not is_discovery(tech) then
            local tech_needs = needs(tech.name)
            for _, discovery_name in pairs(discovery_names) do
                if tech_needs[discovery_name] ~= nil then
                    chain[tech.name] = true
                    for between, _ in pairs(tech_needs) do
                        local between_tech = data.raw.technology[between]
                        if between_tech ~= nil and between ~= discovery_name and needs(between)[discovery_name] ~= nil and not is_discovery(between_tech) and not is_leveled(between_tech) then
                            chain[between] = true
                        end
                    end
                end
            end
        end
    end
end

-- The parallel tree of a dupe number: a copy of each candidate taking that number's copied packs, and of each technology on a copied planet's discovery chain (add_discovery_chain), with prerequisites among the copies: a copied technology's copy, else a copied planet's discovery technology's copy (discovery_copies, that number's), else the original
-- A candidate's copy has no effects of its own yet (the duplicates' recipes with that number are unlocked there, see dupe.recipe); a chain copy unlocks the recipes its original does (not its bonuses), with pack recipes swapped for that number's copies (packs.recipe_copies), whose unlocks move off the original
-- Returns original name --> copy, and the unlocks moved (see undo_moves)
local function parallel_tree(candidates, chain, packs, discovery_copies, number)
    local pack_copies = packs.copies[number]
    local recipe_copies = packs.recipe_copies[number]
    local copied = {}
    dupe.technology_copies[number] = dupe.technology_copies[number] or {}
    local function copy_of(tech)
        local copy = dupe.prototype(tech, number)
        copy.effects = nil
        copy.essential = nil
        for _, ingredient in pairs((copy.unit or {}).ingredients or {}) do
            if pack_copies[ingredient[1]] ~= nil then
                ingredient[1] = pack_copies[ingredient[1]]
            end
        end
        copy.icons = table.deepcopy(icon_list(tech))
        table.insert(copy.icons, dupe.number_badge(number, BADGE_SCALE, BADGE_SHIFT))
        copied[tech.name] = copy
        dupe.technology_copies[number][tech.name] = copy
        return copy
    end
    for _, tech in pairs(candidates) do
        if takes_any(tech, pack_copies) then
            copy_of(tech)
        end
    end
    -- Pack copies' recipes of every number: this tree moves its own number's, and its copies leave the others' to their trees
    local copy_number_of = {}
    for other_number, other_recipe_copies in pairs(packs.recipe_copies) do
        for _, copy_name in pairs(other_recipe_copies) do
            copy_number_of[copy_name] = other_number
        end
    end
    local moves = {}
    for _, tech_name in pairs(sorted_keys(chain)) do
        local tech = data.raw.technology[tech_name]
        local copy = copied[tech_name] or copy_of(tech)
        local kept = {}
        local copy_effects = {}
        for _, effect in pairs(tech.effects or {}) do
            local copy_number = effect.type == "unlock-recipe" and copy_number_of[effect.recipe] or nil
            if copy_number == number then
                -- A pack copy's recipe: the copy unlocks it instead (through its original's recipe below)
                table.insert(moves, {
                    tech = tech,
                    copy = copy,
                    effect = effect,
                })
            else
                table.insert(kept, effect)
                if effect.type == "unlock-recipe" and copy_number == nil then
                    table.insert(copy_effects, {
                        type = "unlock-recipe",
                        recipe = recipe_copies[effect.recipe] or effect.recipe,
                    })
                end
            end
        end
        tech.effects = kept
        copy.effects = copy_effects
    end
    for tech_name, copy in pairs(copied) do
        local prerequisites = {}
        for _, prerequisite in pairs(data.raw.technology[tech_name].prerequisites or {}) do
            if copied[prerequisite] ~= nil then
                table.insert(prerequisites, copied[prerequisite].name)
            elseif discovery_copies[prerequisite] ~= nil then
                table.insert(prerequisites, discovery_copies[prerequisite])
            else
                table.insert(prerequisites, prerequisite)
            end
        end
        copy.prerequisites = prerequisites
    end
    return copied, moves
end

-- Puts the pack copies' recipe unlocks that parallel_tree moved to chain copies back on the originals
local function undo_moves(moves)
    for _, move in pairs(moves) do
        table.insert(move.tech.effects, move.effect)
        local effects = {}
        for _, effect in pairs(move.copy.effects or {}) do
            if not (effect.type == "unlock-recipe" and effect.recipe == move.effect.recipe) then
                table.insert(effects, effect)
            end
        end
        move.copy.effects = effects
    end
end

-- The endgame joins every version: a technology whose research takes a pack of every planet with copied packs (like the solar system edge's discovery, or research productivity) takes every other version of each copied pack it takes as well, originals and parallel copies alike, so the original and the copied trees meet at the end
-- Returns the ingredients added (tech, ingredient), so they can be undone, and the set of the technologies' names
local function join_endgame(packs)
    -- Pack (original or copy) --> the original planet it belongs to
    local family = {}
    local families = {}
    for original, versions in pairs(packs.versions) do
        local owner = packs.owner[original]
        families[owner] = true
        for _, version in pairs(versions) do
            family[version] = owner
        end
    end
    local added = {}
    local joined = {}
    for _, tech in pairs(sorted_prototypes("technology")) do
        if tech.unit ~= nil and tech.unit.ingredients ~= nil then
            local taken = {}
            local has = {}
            for _, ingredient in pairs(tech.unit.ingredients) do
                has[ingredient[1]] = true
                if family[ingredient[1]] ~= nil then
                    taken[family[ingredient[1]]] = true
                end
            end
            local takes_every = next(families) ~= nil
            for owner, _ in pairs(families) do
                if taken[owner] == nil then
                    takes_every = false
                end
            end
            if takes_every then
                joined[tech.name] = true
                local additions = {}
                for _, ingredient in pairs(tech.unit.ingredients) do
                    local original = packs.original_of[ingredient[1]]
                    for _, other in pairs(original ~= nil and packs.versions[original] or {}) do
                        if has[other] == nil then
                            has[other] = true
                            table.insert(additions, {
                                other,
                                ingredient[2],
                            })
                        end
                    end
                end
                for _, ingredient in pairs(additions) do
                    table.insert(tech.unit.ingredients, ingredient)
                    table.insert(added, {
                        tech = tech,
                        ingredient = ingredient,
                    })
                end
            end
        end
    end
    return added, joined
end

-- The split: a share of the copied packs in the original technologies' research become one of their copies, chosen by branch of the tree rather than pack by pack
-- For each copied pack, a technology decides like the nearest technologies it needs that decided about that pack (through prerequisites that don't take it): where they all agree it follows them, where they disagree it sides with one at random (weighted by how many took each version), and where none decided it's a root that takes a copy (a random one of them) with probability SPLIT_SHARE
-- So a branch takes one planet's version of a pack, while its roots decide on their own; technologies in skip (the endgame's, which take every version) don't decide
-- Returns the flips made, so they can be undone
local function split(candidates, packs, skip)
    local key = rng.key({
        id = "dupe-planets-split",
    })
    local deciding = {}
    for _, tech in pairs(candidates) do
        if skip[tech.name] == nil then
            deciding[tech.name] = true
        end
    end
    -- Pack --> technology name --> the version it takes (the pack itself or one of its copies), or false (no decision), found when first asked
    local decisions = {}
    local function decide(tech_name, pack)
        decisions[pack] = decisions[pack] or {}
        if decisions[pack][tech_name] ~= nil then
            return decisions[pack][tech_name]
        end
        -- Stored first, so a prerequisite cycle ends here
        decisions[pack][tech_name] = false
        local tech = data.raw.technology[tech_name]
        -- How many prerequisites took each version, in the order first seen
        local counts = {}
        local seen = {}
        local total = 0
        for _, prerequisite in pairs((tech or {}).prerequisites or {}) do
            local decision = decide(prerequisite, pack)
            if decision ~= false then
                if counts[decision] == nil then
                    counts[decision] = 0
                    table.insert(seen, decision)
                end
                counts[decision] = counts[decision] + 1
                total = total + 1
            end
        end
        local decision = false
        if #seen == 1 then
            decision = seen[1]
        elseif #seen > 1 then
            local roll = rng.value(key) * total
            for _, version in pairs(seen) do
                decision = version
                roll = roll - counts[version]
                if roll < 0 then
                    break
                end
            end
        elseif deciding[tech_name] ~= nil and takes(tech, pack) then
            decision = pack
            if rng.value(key) < SPLIT_SHARE then
                local copies = packs.copies_of[pack]
                decision = copies[1]
                if #copies > 1 then
                    decision = copies[rng.int(key, #copies)]
                end
            end
        end
        decisions[pack][tech_name] = decision
        return decision
    end
    local flips = {}
    for _, tech in pairs(candidates) do
        if deciding[tech.name] ~= nil then
            for _, ingredient in pairs(tech.unit.ingredients) do
                if packs.versions[ingredient[1]] ~= nil then
                    local version = decide(tech.name, ingredient[1])
                    if version ~= false and version ~= ingredient[1] then
                        table.insert(flips, {
                            ingredient = ingredient,
                            original = ingredient[1],
                        })
                        ingredient[1] = version
                    end
                end
            end
        end
    end
    return flips
end

-- Infinite and leveled research takes copied packs too, which the parallel trees and the split leave out: each copied pack in its research becomes a random one of its versions (itself or a copy, all as likely), so the copies stay useful once the trees run out; technologies in skip (the endgame's) are left alone
-- Returns the flips made, so they can be undone
local function mix_infinite(packs, skip)
    local key = rng.key({
        id = "dupe-planets-infinite",
    })
    local flips = {}
    for _, tech in pairs(sorted_prototypes("technology")) do
        if is_leveled(tech) and tech.unit.ingredients ~= nil and not is_discovery(tech) and skip[tech.name] == nil and not dupe.has_been_duplicated[rng.key({prototype = tech})] then
            for _, ingredient in pairs(tech.unit.ingredients) do
                local versions = packs.versions[ingredient[1]]
                if versions ~= nil then
                    local version = versions[rng.int(key, #versions)]
                    if version ~= ingredient[1] then
                        table.insert(flips, {
                            ingredient = ingredient,
                            original = ingredient[1],
                        })
                        ingredient[1] = version
                    end
                end
            end
        end
    end
    return flips
end

-- The recipe and technology nodes reachable in the current game, by a plain sort of the logic graph
local function reachable_nodes()
    new_logic.build(true)
    local sort_info = top.sort(new_logic.graph)
    local reachable = {}
    for node_key, contexts in pairs(sort_info.node_to_context_inds or {}) do
        local node = new_logic.graph.nodes[node_key]
        if next(contexts) ~= nil and node ~= nil and (node.type == "recipe" or node.type == "technology") then
            reachable[node_key] = true
        end
    end
    return reachable
end

-- The nodes reachable before that aren't after, sorted
local function lost_nodes(before, after)
    local lost = {}
    for node_key, _ in pairs(before) do
        if after[node_key] == nil then
            table.insert(lost, node_key)
        end
    end
    table.sort(lost)
    return lost
end

local function describe_lost(lost)
    return #lost .. " things unreachable (" .. table.concat(lost, ", ", 1, math.min(#lost, 10)) .. ")"
end

dupe_planets.execute = function()
    local discovery = discovery_technologies()
    if next(discovery) == nil then
        log("Planet copies: no technology discovers a space location, so no planet is copied")
        return
    end
    local model = cheapest_discovery(discovery)
    -- Rooms before any copy, for which science packs are a planet's own
    local room_keys = {}
    for _, name in pairs(sorted_keys(data.raw.planet)) do
        table.insert(room_keys, gutils.key("planet", name))
    end
    for _, name in pairs(sorted_keys(data.raw.surface or {})) do
        table.insert(room_keys, gutils.key("surface", name))
    end
    -- The planets to copy: not hidden, with recolored graphics for some dupe number, and discoverable; each gets a copy per number it has recolored graphics for
    local planets = {}
    local numbers_of = {}
    for _, planet in pairs(sorted_prototypes("planet")) do
        if planet.hidden ~= true and (discovery[planet.name] ~= nil or model ~= nil) then
            local numbers = {}
            for number = 2, dupe.highest_number() do
                if dupe.item_has_recolor(planet, number) then
                    table.insert(numbers, number)
                end
            end
            if #numbers > 0 then
                table.insert(planets, planet)
                numbers_of[planet.name] = numbers
            end
        end
    end
    if #planets == 0 then
        return
    end

    -- Dupe number --> original planet name --> its copy with that number
    local copies = {}
    -- copies and recipe_copies by dupe number (see copy_packs); versions: original pack name --> it and its copies, by number; copies_of: original pack name --> its copies; original_of: version --> original pack name
    local packs = {
        copies = {},
        owner = {},
        recipe_copies = {},
        versions = {},
        copies_of = {},
        original_of = {},
    }
    -- Dupe number --> original discovery technology name --> its copy's name
    local discovery_copies = {}
    local fixes = {}
    local names = {}
    local num_copies = 0
    local num_tiles = 0
    local num_wild = 0
    local num_discovery = 0
    local num_packs = 0
    local kept = wild.kept_in_place()
    for _, planet in pairs(planets) do
        table.insert(names, planet.name .. " x" .. #numbers_of[planet.name])
        for _, number in pairs(numbers_of[planet.name]) do
            local copy = copy_planet(planet, number)
            copies[number] = copies[number] or {}
            copies[number][planet.name] = copy
            discovery_copies[number] = discovery_copies[number] or {}
            num_copies = num_copies + 1
            num_tiles = num_tiles + copy_tiles(planet, copy, number)
            num_wild = num_wild + dupe_planets.copy_wild_entities(planet, copy, number, kept)
            num_discovery = num_discovery + copy_discovery(planet, copy, number, discovery, model, discovery_copies[number])
            num_packs = num_packs + copy_packs(planet, copy, number, room_keys, packs, fixes)
        end
    end
    local num_wild_kept_off = dupe_planets.keep_clones_home()
    local num_connections = copy_connections(copies)
    local numbers = sorted_keys(copies)
    for _, number in pairs(numbers) do
        for original, copy in pairs(packs.copies[number] or {}) do
            if packs.versions[original] == nil then
                packs.versions[original] = {
                    original,
                }
                packs.copies_of[original] = {}
                packs.original_of[original] = original
            end
            table.insert(packs.versions[original], copy)
            table.insert(packs.copies_of[original], copy)
            packs.original_of[copy] = original
        end
    end

    -- The science pack locks need the logic's lookups (which rooms there are now)
    lu.load_lookups()
    lookups = lu
    for _, fix in pairs(fixes) do
        locks.fix("recipe", fix.recipe, fix.rooms)
    end
    local unrealized = locks.realize()
    for _, target_id in pairs(unrealized) do
        log("Planet copies: no surface properties left for " .. target_id .. ", so it keeps its old lock")
    end

    -- The parallel trees (one per dupe number) with each copied planet's discovery chain, checked against the game without them (only the moved pack unlocks can lose anything), and undone to the old unlocks if they lose something
    local reachable_without_tree = reachable_nodes()
    local candidates = tree_candidates(packs.versions)
    local chain = {}
    local needs = prerequisite_closure()
    for _, planet in pairs(planets) do
        local pack_recipe_names = {}
        for pack_name, owner in pairs(packs.owner) do
            if owner == planet.name and packs.versions[pack_name] ~= nil then
                for _, recipe in pairs(dupe.item_recipes(dupe.find_prototype("item", pack_name))) do
                    pack_recipe_names[recipe.name] = true
                end
            end
        end
        local discovery_names = {}
        for _, tech in pairs(discovery[planet.name] or {}) do
            table.insert(discovery_names, tech.name)
        end
        add_discovery_chain(chain, discovery_names, pack_recipe_names, needs)
    end
    -- Copied technology name --> its copy, over every tree
    local copied = {}
    local moves = {}
    for _, number in pairs(numbers) do
        local tree_copied, tree_moves = parallel_tree(candidates, chain, packs, discovery_copies[number], number)
        for _, copy in pairs(tree_copied) do
            copied[copy.name] = copy
        end
        for _, move in pairs(tree_moves) do
            table.insert(moves, move)
        end
    end
    local before = reachable_nodes()
    local lost = lost_nodes(reachable_without_tree, before)
    if #lost > 0 then
        undo_moves(moves)
        log("Planet copies: moving the pack copies' unlocks to their discovery chains made " .. describe_lost(lost) .. ", so they're back on the originals")
        before = reachable_without_tree
        moves = {}
    end

    -- The endgame's join, the split and the infinite research's mix, checked against the game with the tree, and all undone if they lose something
    local additions, joined = join_endgame(packs)
    local flips = split(candidates, packs, joined)
    local infinite_flips = mix_infinite(packs, joined)
    local after = reachable_nodes()
    lost = lost_nodes(before, after)
    if #lost > 0 then
        for _, flip in pairs(flips) do
            flip.ingredient[1] = flip.original
        end
        for _, flip in pairs(infinite_flips) do
            flip.ingredient[1] = flip.original
        end
        for _, addition in pairs(additions) do
            local ingredients = {}
            for _, ingredient in pairs(addition.tech.unit.ingredients) do
                if ingredient ~= addition.ingredient then
                    table.insert(ingredients, ingredient)
                end
            end
            addition.tech.unit.ingredients = ingredients
        end
        log("Planet copies: the split, the infinite research's mix and the endgame's join made " .. describe_lost(lost) .. ", so they're undone")
        flips = {}
        infinite_flips = {}
        additions = {}
        joined = {}
    end
    local num_unreachable_copies = 0
    for _, copy in pairs(copied) do
        if after[gutils.key("technology", copy.name)] == nil then
            num_unreachable_copies = num_unreachable_copies + 1
        end
    end

    log("Planet copies: " .. num_copies .. " copies of " .. #planets .. " planets (" .. table.concat(names, ", ") .. "), " .. num_tiles .. " ocean tiles, " .. num_wild .. " wild entities (kept off " .. num_wild_kept_off .. " other planets with their sliders), " .. num_connections .. " connections, " .. num_discovery .. " discovery technologies, " .. num_packs .. " science packs (" .. #fixes .. " locks), " .. #sorted_keys(copied) .. " parallel technologies (" .. #sorted_keys(chain) .. " on discovery chains, " .. #moves .. " pack unlocks moved to them, " .. num_unreachable_copies .. " unreachable), " .. #flips .. " science packs split, " .. #infinite_flips .. " in infinite research, " .. #additions .. " added to " .. #sorted_keys(joined) .. " endgame technologies")
end

return dupe_planets
