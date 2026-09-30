-- Planet copies (setting propertyrandomizer-dupes; run from data-final-fixes.lua before the other duplicates)
-- A copy of every planet whose icon has a recolored copy (dev/dupe-planets.txt, made by dev/make-dupe-graphics.py), so planetary randomization has more planets to make different
-- A copy is the planet prototype again under a new name: the same map generation (from its own seed, since the game seeds a planet by its name), surface properties, pollutant, lightning and freezing. With it come:
--   * ocean tiles of its own: clones of its original's handwritten ocean family (randomizations/planetary/oceans.lua), so an ocean swap can give it another ocean than its original's
--   * space connections: each connection of the original again, ending at the copy; where both ends have copies, one between the copies too
--   * discovery: a copy of each technology discovering the original, discovering the copy; the starting planet, which nothing discovers, gets one modeled on the cheapest discovery technology
--   * science: copies of the planet's own science packs that have recolored icons (dev/dupe-items.txt), locked to the copy while the originals stay locked to their planet (lib/surface-sets.lua properties, through randomizations/planetary/locks.lua); every lab takes the copies
--   * a parallel technology tree: a copy of each technology whose research takes a copied pack, taking the copies instead, with prerequisites among the copies; the duplicates' recipes are unlocked there (dupe.recipe)
--   * a split: a share of the original technologies take a copied pack instead of the original, so the two trees interleave; checked with the logic graph (what was reachable stays reachable), else undone
-- Everything else works on the copy as on its original, since surface conditions go by properties and the copy has its original's
-- A planet's own science packs are the lab inputs whose recipes only that planet accepts; for the starting planet, whose packs have no conditions, the lab inputs whose recipes it accepts at all

local constants = require("helper-tables/constants")
local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local rng = require("lib/random/rng")
local dupe = require("lib/dupe")
local lu = require("lib/lookup/init")
local surface_sets = require("lib/surface-sets")
local top = require("lib/graph/context-sort")
local new_logic = require("lib/logic/init")
local locks = require("randomizations/planetary/locks")
local oceans = require("randomizations/planetary/oceans")
local planet_names = require("lib/planet-names")

local dupe_planets = {}

-- One copy per planet: the dupe number its recolored graphics carry
local DUPE_NUMBER = 2
-- How far along its orbit a copy sits from its original on the star map, as a fraction of a turn
local ORIENTATION_NUDGE = 0.035
-- The share of the copied science packs in original technologies that become the copies instead (the split)
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

-- The planet prototype again under the copy's name, beside its original on the star map
local function copy_planet(planet)
    local copy = dupe.prototype(planet, DUPE_NUMBER)
    dupe.recolor_graphics(copy, DUPE_NUMBER)
    copy.orientation = ((planet.orientation or 0) + ORIENTATION_NUDGE) % 1
    copy.order = (planet.order or "") .. "-" .. tostring(DUPE_NUMBER)
    -- With random planet names, the copy gets one of its own rather than its original's with a number
    if config.planet_names then
        planet_names.name(copy)
    end
    return copy
end

-- Clones of the original's ocean tiles for the copy (its map generation places the clones instead), registered as the copy's ocean family
-- Returns how many tiles were cloned
local tile_clones = {}
local function copy_tiles(planet, copy)
    local family = oceans.families[planet.name]
    local map_gen_settings = copy.map_gen_settings or {}
    local tile_settings = ((map_gen_settings.autoplace_settings or {}).tile or {}).settings
    if family == nil or tile_settings == nil then
        return 0
    end
    local new_family = {
        fluid = family.fluid,
    }
    local num_cloned = 0
    for _, depth in pairs(DEPTHS) do
        new_family[depth] = {}
        for _, tile_name in pairs(family[depth]) do
            local tile = data.raw.tile[tile_name]
            if tile ~= nil then
                if tile_clones[tile_name] == nil then
                    tile_clones[tile_name] = dupe.tile(tile, DUPE_NUMBER)
                    num_cloned = num_cloned + 1
                end
                local clone = tile_clones[tile_name]
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

-- Copies of the space connections ending at copied planets: each connection again per copied end, and one between two copies where both ends have one
-- Returns how many connections were added
local function copy_connections(copies)
    local num_added = 0
    for _, connection in pairs(sorted_prototypes("space-connection")) do
        local from_copy = copies[connection.from]
        local to_copy = copies[connection.to]
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
                suffix = tostring(DUPE_NUMBER) .. "-" .. variant.suffix,
            })
            copy.from = variant.from
            copy.to = variant.to
            copy.order = (connection.order or "") .. "-" .. variant.suffix
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
                    local planet_copy = copies[original_name]
                    if original ~= nil and planet_copy ~= nil and icon.icon == original.icon and (variant.from == planet_copy.name or variant.to == planet_copy.name) then
                        icon.icon = planet_copy.icon
                    end
                end
            end
            num_added = num_added + 1
        end
    end
    return num_added
end

-- Copies of the technologies discovering the original, discovering the copy; a planet nothing discovers gets one modeled on the cheapest discovery technology
-- Returns how many technologies were added
local function copy_discovery(planet, copy, discovery, model)
    local techs = discovery[planet.name]
    local num_added = 0
    if techs ~= nil then
        for _, tech in pairs(techs) do
            local copy_tech = dupe.prototype(tech, DUPE_NUMBER)
            for _, effect in pairs(copy_tech.effects or {}) do
                if effect.type == "unlock-space-location" and effect.space_location == planet.name then
                    effect.space_location = copy.name
                end
            end
            copy_tech.localised_name = {
                "propertyrandomizer.planet_discovery",
                copy.localised_name,
            }
            if dupe.recolor_graphics(copy_tech, DUPE_NUMBER) == 0 then
                copy_tech.icons = table.deepcopy(icon_list(tech))
                table.insert(copy_tech.icons, dupe.number_badge(DUPE_NUMBER, BADGE_SCALE, BADGE_SHIFT))
            end
            num_added = num_added + 1
        end
        return num_added
    end
    local copy_tech = dupe.prototype(model, {
        suffix = tostring(DUPE_NUMBER) .. "-" .. planet.name,
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

-- Copies of the planet's own science packs with recolored icons, locked to the copy (fixes, applied by the caller), taken by every lab that takes the original
-- Returns how many packs were copied
local function copy_packs(planet, copy, room_keys, pack_copies, fixes)
    local num_copied = 0
    for _, pack_name in pairs(sorted_keys(dutils.lab_inputs())) do
        local pack = dupe.find_prototype("item", pack_name)
        if pack ~= nil and pack.hidden ~= true and not dupe.has_been_duplicated[rng.key({prototype = pack})] and dupe.item_has_recolor(pack, DUPE_NUMBER) then
            local recipes = dupe.item_recipes(pack)
            if #recipes > 0 and owned_by(planet, recipes, room_keys) then
                local new_pack = dupe.item(pack, DUPE_NUMBER)
                new_pack.default_import_location = copy.name
                for _, lab in pairs(data.raw.lab) do
                    if lists(lab.inputs, pack.name) then
                        table.insert(lab.inputs, new_pack.name)
                    end
                end
                pack_copies[pack.name] = new_pack.name
                -- The original's recipes stay its planet's alone (where they were locked at all), the copy's are the copy's alone
                for _, recipe in pairs(recipes) do
                    if recipe.surface_conditions ~= nil and next(recipe.surface_conditions) ~= nil then
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
                end
                num_copied = num_copied + 1
            end
        end
    end
    return num_copied
end

-- The technologies the parallel tree and the split work on: researched with science packs (no formula or level cap: no infinite or leveled research), not discovering a planet, not copies, and taking a copied pack
local function tree_candidates(pack_copies)
    local candidates = {}
    for _, tech in pairs(sorted_prototypes("technology")) do
        local unit = tech.unit
        if unit ~= nil and unit.ingredients ~= nil and unit.count_formula == nil and tech.max_level == nil and not is_discovery(tech) and not dupe.has_been_duplicated[rng.key({prototype = tech})] then
            local takes_copied = false
            for _, ingredient in pairs(unit.ingredients) do
                if pack_copies[ingredient[1]] ~= nil then
                    takes_copied = true
                end
            end
            if takes_copied then
                table.insert(candidates, tech)
            end
        end
    end
    return candidates
end

-- The parallel tree: a copy of each candidate taking the copied packs, with prerequisites among the copies (originals where a prerequisite has no copy) and no effects of its own yet
-- Returns original name --> copy
local function parallel_tree(candidates, pack_copies)
    local copied = {}
    for _, tech in pairs(candidates) do
        local copy = dupe.prototype(tech, DUPE_NUMBER)
        copy.effects = nil
        copy.essential = nil
        for _, ingredient in pairs(copy.unit.ingredients) do
            if pack_copies[ingredient[1]] ~= nil then
                ingredient[1] = pack_copies[ingredient[1]]
            end
        end
        copy.icons = table.deepcopy(icon_list(tech))
        table.insert(copy.icons, dupe.number_badge(DUPE_NUMBER, BADGE_SCALE, BADGE_SHIFT))
        copied[tech.name] = copy
        dupe.technology_copies[tech.name] = copy
    end
    for tech_name, copy in pairs(copied) do
        local prerequisites = {}
        for _, prerequisite in pairs(data.raw.technology[tech_name].prerequisites or {}) do
            if copied[prerequisite] ~= nil then
                table.insert(prerequisites, copied[prerequisite].name)
            else
                table.insert(prerequisites, prerequisite)
            end
        end
        copy.prerequisites = prerequisites
    end
    return copied
end

-- The split: each copied pack in an original technology's research becomes the copy with probability SPLIT_SHARE
-- Returns the flips made, so they can be undone
local function split(candidates, pack_copies)
    local key = rng.key({
        id = "dupe-planets-split",
    })
    local flips = {}
    for _, tech in pairs(candidates) do
        for _, ingredient in pairs(tech.unit.ingredients) do
            local pack_copy = pack_copies[ingredient[1]]
            if pack_copy ~= nil and rng.value(key) < SPLIT_SHARE then
                table.insert(flips, {
                    ingredient = ingredient,
                    original = ingredient[1],
                })
                ingredient[1] = pack_copy
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
    -- The planets to copy: not hidden, with recolored graphics, and discoverable
    local planets = {}
    for _, planet in pairs(sorted_prototypes("planet")) do
        if planet.hidden ~= true and dupe.item_has_recolor(planet, DUPE_NUMBER) and (discovery[planet.name] ~= nil or model ~= nil) then
            table.insert(planets, planet)
        end
    end
    if #planets == 0 then
        return
    end

    local copies = {}
    local pack_copies = {}
    local fixes = {}
    local names = {}
    local num_tiles = 0
    local num_discovery = 0
    local num_packs = 0
    for _, planet in pairs(planets) do
        local copy = copy_planet(planet)
        copies[planet.name] = copy
        table.insert(names, planet.name)
        num_tiles = num_tiles + copy_tiles(planet, copy)
        num_discovery = num_discovery + copy_discovery(planet, copy, discovery, model)
        num_packs = num_packs + copy_packs(planet, copy, room_keys, pack_copies, fixes)
    end
    local num_connections = copy_connections(copies)

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

    -- The parallel tree, then the split, checked against the game with the tree but without the split
    local candidates = tree_candidates(pack_copies)
    local copied = parallel_tree(candidates, pack_copies)
    local before = reachable_nodes()
    local flips = split(candidates, pack_copies)
    local after = reachable_nodes()
    local lost = {}
    for node_key, _ in pairs(before) do
        if after[node_key] == nil then
            table.insert(lost, node_key)
        end
    end
    table.sort(lost)
    if #lost > 0 then
        for _, flip in pairs(flips) do
            flip.ingredient[1] = flip.original
        end
        log("Planet copies: the split made " .. #lost .. " things unreachable (" .. table.concat(lost, ", ", 1, math.min(#lost, 10)) .. "), so it's undone")
        flips = {}
    end
    local num_unreachable_copies = 0
    for _, copy in pairs(copied) do
        if after[gutils.key("technology", copy.name)] == nil then
            num_unreachable_copies = num_unreachable_copies + 1
        end
    end

    log("Planet copies: " .. #planets .. " planets (" .. table.concat(names, ", ") .. "), " .. num_tiles .. " ocean tiles, " .. num_connections .. " connections, " .. num_discovery .. " discovery technologies, " .. num_packs .. " science packs (" .. #fixes .. " locks), " .. #candidates .. " parallel technologies (" .. num_unreachable_copies .. " unreachable), " .. #flips .. " science packs split")
end

return dupe_planets
