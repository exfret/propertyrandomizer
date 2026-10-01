local categories = require("helper-tables/categories")

local rng = require("lib/random/rng")
local locale_utils = require("lib/locale")
local dutils = require("lib/data-utils")

local resource_autoplace = require("resource-autoplace")
-- Which original sprite paths have recolored copies under graphics/dupes/<n>/ (dev/make-dupe-graphics.py)
local dupe_graphics = require("lib/dupe-graphics-manifest")

-- TODO: This file is really messy and a lot of functionality could be factored out into separate functions, maybe clean this up

-- Note: Duplicating the both the item and recipe for the same thing may cause issues with icons and possibly worse right now

local dupe = {}

-- To dupe:
--   * Important recipes
--   * Tech unlocks (to some extent, maybe not all?)

local dupe_number_to_filename = {
    "number_one.png",
    "number_two.png",
    "number_three.png",
    "number_four.png",
    "number_five.png",
    "number_six.png",
    "number_seven.png",
    "number_eight.png",
    "number_nine.png",
}
dupe.max_icon_number = #dupe_number_to_filename

-- The highest dupe number made (the original is 1): one more than the setting's number of duplicates (config.num_dupes), as far as the recolored graphics shipped with the mod (dev/make-dupe-graphics.py) and the number badges go
dupe.highest_number = function()
    return math.min(1 + config.num_dupes, dupe_graphics.max_dupe, dupe.max_icon_number)
end

-- Number badge layer for the top right of a recipe icon (items put theirs on the top left so the two don't overlap)
dupe.recipe_number_icon = function(number)
    return {
        icon = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[number],
        icon_size = 120,
        scale = 1 / 6,
        shift = {7, -7},
    }
end

-- Number badge layer for an icon list (a 120 px badge), at the given scale and shift
dupe.number_badge = function(number, scale, shift)
    return {
        icon = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[number],
        icon_size = 120,
        scale = scale,
        shift = shift,
    }
end

-- Keep track of things that were already duplicated if needed
-- Also counts duplicates as having been duplicated
dupe.has_been_duplicated = {}
-- Names of duplicates whose sprites were swapped for recolored copies, so they don't also get number badges on their entity graphics
dupe.recolored = {}
-- Dupe number --> original technology name --> its copy with that number (lib/dupe-planets.lua: in that number's parallel technology tree, or discovering that number's planet copy): a duplicate's recipe is unlocked by the copy with its number of the technology unlocking the original, where there is one
dupe.technology_copies = {}

-- The recolored copy's path for an original sprite path, or nil when there is none for this dupe number
local function recolored_path(filename, dupe_number)
    if type(filename) ~= "string" then
        return nil
    end
    local highest = dupe_graphics.files[filename]
    if highest == nil or dupe_number > highest then
        return nil
    end
    local mod_name, rest = string.match(filename, "^__([^_]+)__/(.*)$")
    if mod_name == nil then
        return nil
    end
    return "__propertyrandomizer__/graphics/dupes/" .. tostring(dupe_number) .. "/" .. mod_name .. "/" .. rest
end

-- Swaps every sprite path in the table (filename, filenames, stripes, icon) for its recolored copy; returns how many were swapped
local function recolor_graphics(tbl, dupe_number)
    local swapped = 0
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            swapped = swapped + recolor_graphics(value, dupe_number)
        elseif key == "filename" or key == "icon" or key == "starmap_icon" or (type(key) == "number" and type(value) == "string") then
            local new_path = recolored_path(value, dupe_number)
            if new_path ~= nil then
                tbl[key] = new_path
                swapped = swapped + 1
            end
        end
    end
    return swapped
end
dupe.recolor_graphics = recolor_graphics

-- The items that place this entity
dupe.placing_items = function(entity)
    local items = {}
    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                if item.place_result == entity.name then
                    table.insert(items, item)
                end
            end
        end
    end
    return items
end

-- Whether one of the prototype's icons has a recolored copy for this dupe number
local function icons_have_recolor(prototype, dupe_number)
    local icons = prototype.icons or {{icon = prototype.icon}}
    for _, icon in pairs(icons) do
        if recolored_path(icon.icon, dupe_number) ~= nil then
            return true
        end
    end
    return false
end

-- Whether this entity is one of those with recolored graphics for this dupe number: its placing item's icon has a recolored copy
-- (sheets are shared between entities, remnants carry the entity's icon, but an item's icon is its own)
dupe.has_recolor = function(entity, dupe_number)
    for _, item in pairs(dupe.placing_items(entity)) do
        if icons_have_recolor(item, dupe_number) then
            return true
        end
    end
    return false
end

-- Whether this item is one of those with recolored graphics for this dupe number (its own icon has a recolored copy)
dupe.item_has_recolor = icons_have_recolor

-- The prototype of this name among the classes of a base type (entity, item, equipment)
local function find_prototype(base_type, name)
    for class_name, _ in pairs(defines.prototypes[base_type]) do
        if data.raw[class_name] ~= nil and data.raw[class_name][name] ~= nil then
            return data.raw[class_name][name]
        end
    end
    return nil
end
dupe.find_prototype = find_prototype

-- Whether the item is the recipe's main product: main_product when given, else its only result
local function makes_item(recipe, item_name)
    local product = recipe.main_product
    if product == nil and recipe.results ~= nil and #recipe.results == 1 then
        product = recipe.results[1].name
    end
    if product ~= item_name or recipe.results == nil then
        return false
    end
    for _, result in pairs(recipe.results) do
        if result.type == "item" and result.name == item_name then
            return true
        end
    end
    return false
end

-- The recipes (not hidden) that make this item as their main product
dupe.item_recipes = function(item)
    local recipes = {}
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.hidden ~= true and makes_item(recipe, item.name) then
            table.insert(recipes, recipe)
        end
    end
    return recipes
end

-- Most other functions have dupe_number instead of extra_info, I'm converting over to more informative extra_info over time
dupe.prototype = function(prototype, extra_info)
    local new_prototype = table.deepcopy(prototype)

    local suffix_addon
    if type(extra_info) == "table" then
        suffix_addon = extra_info.suffix
    else
        -- extra_info in this case is a dupe_number
        suffix_addon = tostring(extra_info)
    end

    -- Need to add the -copy at the end to prevent the special behavior for technology prototypes with -number at end of prototype names
    new_prototype.name = new_prototype.name .. "-exfret-" .. suffix_addon .. "-copy"
    new_prototype.localised_name = {"propertyrandomizer.dupe", locale_utils.find_localised_name(prototype), suffix_addon}
    -- For help in localisation later
    new_prototype.orig_name = prototype.name
    if type(extra_info) == "table" then
        new_prototype.suffix = extra_info.suffix
    else
        new_prototype.dupe_number = extra_info
    end

    data:extend({
        new_prototype
    })

    dupe.has_been_duplicated[rng.key({prototype = prototype})] = true
    dupe.has_been_duplicated[rng.key({prototype = new_prototype})] = true

    return new_prototype
end

dupe.get_recipe_icons = function(recipe)
    local recipe_icons
    if recipe.icons == nil and recipe.icon == nil then
        local item_with_icon_name
        if recipe.main_product ~= nil then
            item_with_icon_name = recipe.main_product
        else
            item_with_icon_name = recipe.results[1].name
        end
        local item_with_icon
        for item_class, _ in pairs(defines.prototypes.item) do
            if data.raw[item_class] ~= nil then
                if data.raw[item_class][item_with_icon_name] ~= nil then
                    item_with_icon = data.raw[item_class][item_with_icon_name]
                end
            end
        end
        if data.raw.fluid[item_with_icon_name] ~= nil then
            item_with_icon = data.raw.fluid[item_with_icon_name]
        end
        if item_with_icon.icons ~= nil then
            recipe_icons = item_with_icon.icons
        else
            recipe_icons = {
                {
                    icon = item_with_icon.icon,
                    icon_size = item_with_icon.icon_size or 64
                }
            }
        end
    elseif recipe.icons == nil then
        recipe_icons = {
            {
                icon = recipe.icon,
                icon_size = recipe.icon_size or 64
            }
        }
    else
        recipe_icons = recipe.icons
    end
    return recipe_icons
end

-- A layer's scale defaults to (expected_icon_size / 2) / icon_size, and its shift counts expected_icon_size / 2 units across the icon (IconData)
-- Items, fluids and recipes expect 64 and technologies 256, so on a technology a layer without a scale grows by itself, and one with a scale (like a number badge) needs its scale and shift made as much larger
local TECHNOLOGY_ICON_RATIO = 256 / 64

-- A copy of an item's, fluid's or recipe's icon layers that looks the same on a technology
dupe.technology_icons = function(icons)
    local technology_icons = table.deepcopy(icons)
    for _, layer in pairs(technology_icons) do
        if layer.scale ~= nil then
            layer.scale = TECHNOLOGY_ICON_RATIO * layer.scale
        end
        if layer.shift ~= nil then
            layer.shift = {
                TECHNOLOGY_ICON_RATIO * (layer.shift.x or layer.shift[1]),
                TECHNOLOGY_ICON_RATIO * (layer.shift.y or layer.shift[2]),
            }
        end
    end
    return technology_icons
end

-- Whether researching the technology takes an item the recipe makes (a science pack's recipe can't be unlocked by a technology that needs the pack)
local function research_needs_result(technology, recipe)
    if technology.unit == nil or technology.unit.ingredients == nil then
        return false
    end
    for _, ingredient in pairs(technology.unit.ingredients) do
        for _, result in pairs(recipe.results or {}) do
            if result.type == "item" and result.name == ingredient[1] then
                return true
            end
        end
    end
    return false
end

dupe.recipe = function(recipe, extra_info)
    local has_number_suffix = true
    if type(extra_info) == "table" then
        has_number_suffix = false
    end

    local new_recipe = dupe.prototype(recipe, extra_info)
    -- Don't fix names of specially suffixed recipes; they'll be fixed in the function calling this
    if has_number_suffix then
        -- Recipes get special dupe names to distinguish them from an item that's duplicated
        new_recipe.localised_name = {"propertyrandomizer.recipe_dupe", locale_utils.find_localised_name(recipe), tostring(extra_info)}
    end

    -- Recipe tech unlocks: the copy is unlocked wherever the original is (found first, then added, so the effects aren't changed while they're read)
    -- Where the unlocking technology has a copy with the recipe's dupe number (dupe.technology_copies), the unlock goes to the copy instead, unless researching it takes what the recipe makes
    -- Technology copies themselves (which unlock what their originals do) are left out, so a duplicate isn't unlocked in another number's tree, or twice
    local copies = {}
    if type(extra_info) == "number" then
        copies = dupe.technology_copies[extra_info] or {}
    end
    local unlocking = {}
    for _, technology in pairs(data.raw.technology) do
        if technology.effects ~= nil and technology.dupe_number == nil then
            for _, effect in pairs(technology.effects) do
                if effect.type == "unlock-recipe" and effect.recipe == recipe.name then
                    table.insert(unlocking, technology)
                end
            end
        end
    end
    local unlocked_by = {}
    for _, technology in pairs(unlocking) do
        local target = copies[technology.name]
        if target == nil or research_needs_result(target, new_recipe) then
            target = technology
        end
        if unlocked_by[target.name] == nil then
            unlocked_by[target.name] = true
            target.effects = target.effects or {}
            table.insert(target.effects, {
                type = "unlock-recipe",
                recipe = new_recipe.name,
            })
        end
    end

    -- Only fix icons if it's not a specially suffixed recipe
    if has_number_suffix then
        -- Also need to do icon
        local recipe_icons = dupe.get_recipe_icons(new_recipe)
        new_recipe.icons = recipe_icons
        table.insert(new_recipe.icons, dupe.recipe_number_icon(extra_info))
    end

    return new_recipe
end

-- options (optional): no_badge leaves the number badge off the copy's icons and its recipes' (science packs, which their recolor alone tells apart)
dupe.item = function(item, dupe_number, options)
    options = options or {}
    local new_item = dupe.prototype(item, dupe_number)
    recolor_graphics(new_item, dupe_number)

    -- The recipes that make this item make the copy too, with the same amounts (found first, since duplicating adds recipes)
    for _, recipe in pairs(dupe.item_recipes(item)) do
        local new_recipe = dupe.recipe(recipe, dupe_number)
        recolor_graphics(new_recipe, dupe_number)
        -- Named as the item's copy rather than as a recipe copy, with the number badge (which dupe.recipe put last) on the left like the item's
        new_recipe.localised_name = {"propertyrandomizer.dupe", locale_utils.find_localised_name(recipe), tostring(dupe_number)}
        if options.no_badge == true then
            table.remove(new_recipe.icons)
        else
            new_recipe.icons[#new_recipe.icons].shift[1] = -new_recipe.icons[#new_recipe.icons].shift[1]
        end
        for _, result in pairs(new_recipe.results) do
            if result.type == "item" and result.name == item.name then
                result.name = new_item.name
            end
        end
        -- A recipe with several results names its main product (like the cryogenic science pack's, which gives fluoroketone back)
        if new_recipe.main_product == item.name then
            new_recipe.main_product = new_item.name
        end
    end

    for _, icon_prefix_type in pairs({"", "dark_background_"}) do
        if options.no_badge ~= true and (new_item[icon_prefix_type .. "icon"] ~= nil or new_item[icon_prefix_type .. "icons"] ~= nil) then
            local item_icons
            if new_item[icon_prefix_type .. "icons"] == nil then
                item_icons = {
                    {
                        icon = new_item[icon_prefix_type .. "icon"],
                        icon_size = new_item[icon_prefix_type .. "icon_size"] or 64
                    }
                }
            else
                item_icons = new_item[icon_prefix_type .. "icons"]
            end
            table.insert(item_icons, {
                icon = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number],
                icon_size = 120,
                scale = 1 / 6,
                shift = {-7, -7}
            })
            new_item[icon_prefix_type .. "icons"] = item_icons
        end
    end

    -- The equipment this item places gets its copy, with the recolored grid sprite where there is one and a number badge otherwise
    if item.place_as_equipment_result ~= nil then
        local equipment = find_prototype("equipment", item.place_as_equipment_result)
        if equipment ~= nil then
            local new_equipment = dupe.prototype(equipment, dupe_number)
            if recolor_graphics(new_equipment, dupe_number) == 0 then
                new_equipment.sprite = {
                    layers = {
                        new_equipment.sprite,
                        {
                            filename = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number],
                            size = 120,
                            scale = 0.3,
                            shift = {-15, -15},
                        },
                    },
                }
            end
            new_item.place_as_equipment_result = new_equipment.name
            new_equipment.take_result = new_item.name
        end
    end

    -- An armor's copy needs the character's animations for that armor: a copy of them with recolored sheets where there are some, else a place in the original's list of armors
    if item.type == "armor" then
        for _, character in pairs(data.raw.character) do
            local copies = {}
            for _, animation in pairs(character.animations or {}) do
                local worn = false
                for _, armor_name in pairs(animation.armors or {}) do
                    if armor_name == item.name then
                        worn = true
                    end
                end
                if worn then
                    local copy = table.deepcopy(animation)
                    copy.armors = {new_item.name}
                    if recolor_graphics(copy, dupe_number) > 0 then
                        table.insert(copies, copy)
                    else
                        table.insert(animation.armors, new_item.name)
                    end
                end
            end
            for _, copy in pairs(copies) do
                table.insert(character.animations, copy)
            end
        end
    end

    return new_item
end

dupe.technology = function(tech, dupe_number)
    -- Test for special behavior for techs whose name ends with a -number
    local prefix, suffix = tech.name:match("^(.*)%-(%d+)$")

    local new_tech = dupe.prototype(tech, dupe_number)
    -- Add the suffix back on
    if suffix ~= nil and tonumber(suffix) ~= nil then
        data.raw.technology[new_tech.name] = nil
        new_tech.name = prefix .. "-exfret-" .. tostring(dupe_number) .. "-copy-" .. suffix
        data.raw.technology[new_tech.name] = new_tech
    end

    if new_tech.icon ~= nil or new_tech.icons ~= nil then
        local tech_icons
        if new_tech.icons == nil then
            tech_icons = {
                {
                    icon = new_tech.icon,
                    icon_size = new_tech.icon_size or 64
                }
            }
        else
            tech_icons = new_tech.icons
        end
        new_tech.icons = tech_icons
        table.insert(tech_icons, {
            icon = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number],
            icon_size = 120,
            scale = 1 / 3,
            shift = {-40, -40}
        })
    end

    local new_prerequisites = {}
    if new_tech.prerequisites ~= nil then
        for _, prereq in pairs(new_tech.prerequisites) do
            local prereq_prefix, prereq_suffix = prereq:match("^(.*)%-(%d+)$")
            if prereq_suffix ~= nil and tonumber(prereq_suffix) ~= nil then
                -- Ignore leveled techs for now
                table.insert(new_prerequisites, prereq_prefix .. "-exfret-" .. tostring(dupe_number) .. "-copy-" .. prereq_suffix)
            else
                table.insert(new_prerequisites, prereq .. "-exfret-" .. tostring(dupe_number) .. "-copy")
            end
        end
    end
    new_tech.prerequisites = new_prerequisites

    return new_tech
end

local function add_icon_to_anim(anim, dupe_number)
    local frame_count
    local direction_count
    local run_mode
    local layer = anim
    while true do
        if layer.layers == nil then
            local frame_sequence_count
            if layer.frame_sequence ~= nil then
                frame_sequence_count = #layer.frame_sequence
            end

            frame_count = (frame_sequence_count or layer.frame_count or 1) * (layer.repeat_count or 1)

            if layer.direction_count ~= nil then
                direction_count = layer.direction_count
            else
                direction_count = 1
            end

            run_mode = layer.run_mode or "forward"
            if layer.run_mode == "forward-then-backward" then
                frame_count = 2 * frame_count - 2
            end

            break
        else
            layer = layer.layers[1]
        end
    end

    local filenames = {}
    for i = 1, direction_count do
        table.insert(filenames, "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number])
    end

    return {
        layers = {
            anim,
            {
                filenames = filenames,
                lines_per_file = 1,
                width = 120,
                height = 120,
                repeat_count = frame_count,
                frame_count = 1,
                scale = 0.3,
                shift = {-0.5, -0.5}
            }
        }
    }
end

-- Clones a tile under a dupe name for a planet copy (lib/dupe-planets.lua); the clone follows every name-based rule the original is in (tile placement like landfill, foundation, ice platforms and soils; neighbor rules; transitions; autoplace tile restrictions), so it behaves like the original wherever the copy generates it
-- To the player it's the same tile, so it keeps the original's name
dupe.tile = function(tile, dupe_number)
    local new_tile = dupe.prototype(tile, dupe_number)
    new_tile.localised_name = locale_utils.find_localised_name(tile)
    new_tile.hidden_in_factoriopedia = true
    -- A clone generates only where a planet's map gen lists it: with its original's probability, it would otherwise compete with the original on every planet that lets unlisted tiles generate (AutoplaceSettings.treat_missing_as_default)
    if new_tile.autoplace ~= nil then
        new_tile.autoplace.default_enabled = false
    end
    local function follow(names)
        if type(names) ~= "table" then
            return
        end
        local listed = false
        for _, name in pairs(names) do
            if name == tile.name then
                listed = true
            end
        end
        if listed then
            table.insert(names, new_tile.name)
        end
    end
    for item_class, _ in pairs(defines.prototypes.item) do
        for _, item in pairs(data.raw[item_class] or {}) do
            if item.place_as_tile ~= nil then
                follow(item.place_as_tile.tile_condition)
            end
        end
    end
    for _, other in pairs(data.raw.tile) do
        follow(other.allowed_neighbors)
        for _, transition in pairs(other.transitions or {}) do
            follow(transition.to_tiles)
        end
    end
    for _, group in pairs(data.raw) do
        for _, prototype in pairs(group) do
            if type(prototype) == "table" and type(prototype.autoplace) == "table" then
                follow(prototype.autoplace.tile_restriction)
            end
        end
    end
    return new_tile
end

dupe.entity = function(entity, dupe_number)
    local new_entity = dupe.prototype(entity, dupe_number)
    -- Recolored sprites where they exist; the number badge on the entity graphics is only for entities without them
    if recolor_graphics(new_entity, dupe_number) > 0 then
        dupe.recolored[new_entity.name] = true
    end

    -- If this entity is placeable duplicate its item
    local associated_item
    if new_entity.placeable_by ~= nil then
        if new_entity.placeable_by.item ~= nil then
            new_entity.placeable_by = {new_entity.placeable_by}
        end
        if #new_entity.placeable_by == 1 then
            associated_item = new_entity.placeable_by[1].item
        end
    end
    if associated_item == nil then
        -- This technically doesn't work if multiple things can place the same thing, but that's uncommon
        for _, item in pairs(dupe.placing_items(entity)) do
            associated_item = item
        end
    end
    if associated_item ~= nil then
        local new_entity_item = dupe.item(associated_item, dupe_number)
        new_entity_item.place_result = new_entity.name
        if new_entity.minable ~= nil then
            if new_entity.minable.result == associated_item.name then
                new_entity.minable.result = new_entity_item.name
            elseif new_entity.minable.results ~= nil and #new_entity.minable.results == 1 and new_entity.minable.results[1].type == "item" and new_entity.minable.results[1].name == associated_item.name then
                new_entity.minable.results[1].name = new_entity_item.name
            end
        end
    end

    if new_entity.icons ~= nil then
        new_entity.icons = {
            new_entity.icons,
            {
                icon = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number],
                icon_size = 120,
                scale = 1 / 4,
                shift = {-10, -10}
            }
        }
    elseif new_entity.icon ~= nil then
        new_entity.icons = {
            {
                icon = new_entity.icon,
                icon_size = new_entity.icon_size or 64
            },
            {
                icon = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number],
                icon_size = 120,
                scale = 1 / 4,
                shift = {-10, -10}
            }
        }
    end

    -- TODO: Upgrades, pasteable entities, items with this as their plant result

    return new_entity
end

dupe.rolling_stock = function(rolling_stock, dupe_number)
    local new_rolling_stock = dupe.entity(rolling_stock, dupe_number)
    if dupe.recolored[new_rolling_stock.name] then
        return new_rolling_stock
    end

    -- Change graphics
    if new_rolling_stock.pictures ~= nil then
        local direction_count
        local layer = new_rolling_stock.pictures.rotated
        while true do
            if layer.direction_count then
                direction_count = layer.direction_count
                break
            else
                layer = layer.layers[1]
            end
        end
        local frames = {}
        for i = 1, direction_count do
            table.insert(frames, {
                x = -(i - 1) * 120
            })
        end
        new_rolling_stock.pictures.rotated = {
            layers = {
                new_rolling_stock.pictures.rotated,
                {
                    filename = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number],
                    size = 120,
                    direction_count = direction_count,
                    frames = frames,
                    scale = 0.6
                }
            }
        }
    end

    return new_rolling_stock
end

-- A spider vehicle's legs are their own prototypes, so they are duplicated (and recolored) with it
dupe.spider_vehicle = function(spider_vehicle, dupe_number)
    local new_spider_vehicle = dupe.entity(spider_vehicle, dupe_number)

    local legs = new_spider_vehicle.spider_engine.legs
    if legs.leg ~= nil then
        legs = {legs}
    end
    local new_legs = {}
    for _, leg_spec in pairs(legs) do
        local leg = data.raw["spider-leg"][leg_spec.leg]
        if new_legs[leg.name] == nil then
            new_legs[leg.name] = dupe.entity(leg, dupe_number)
        end
        leg_spec.leg = new_legs[leg.name].name
    end

    return new_spider_vehicle
end

dupe.turret = function(turret, dupe_number)
    local new_turret = dupe.entity(turret, dupe_number)
    if dupe.recolored[new_turret.name] then
        return new_turret
    end

    -- Change graphics
    for _, animation_type in pairs({"folded_animation", "preparing_animation", "prepared_animation", "prepared_alternative_animation", "starting_attack_animation", "attacking_animation", "ending_attack_animation", "folding_animation"}) do
        if new_turret[animation_type] ~= nil then
            if new_turret[animation_type].north ~= nil then
                for dir_key, dir_anim in pairs(new_turret[animation_type]) do
                    if dir_anim.filename ~= nil or dir_anim.layers ~= nil then
                        new_turret[animation_type][dir_key] = add_icon_to_anim(dir_anim, dupe_number)
                    else
                        for key, anim in pairs(dir_anim) do
                            dir_anim[key] = add_icon_to_anim(anim, dupe_number)
                        end
                    end
                end
            else
                if new_turret[animation_type].filename ~= nil or new_turret[animation_type].layers ~= nil then
                    new_turret[animation_type] = add_icon_to_anim(new_turret[animation_type], dupe_number)
                else
                    for key, anim in pairs(new_turret[animation_type]) do
                        new_turret[animation_type][key] = add_icon_to_anim(anim, dupe_number)
                    end
                end
            end
        end
    end

    return new_turret
end

dupe.robot = function(robot, dupe_number)
    local new_robot = dupe.entity(robot, dupe_number)
    if dupe.recolored[new_robot.name] then
        return new_robot
    end

    -- Graphics
    local anim_keys = {"idle", "in_motion"}
    if robot.type == "construction-robot" then
        table.insert(anim_keys, "working")
    end
    for _, animation_type in pairs(anim_keys) do
        if new_robot[animation_type] ~= nil then
            if new_robot[animation_type].filename ~= nil or new_robot[animation_type].layers ~= nil then
                new_robot[animation_type] = add_icon_to_anim(new_robot[animation_type], dupe_number)
            else
                for key, anim in pairs(new_robot[animation_type]) do
                    new_robot[animation_type][key] = add_icon_to_anim(anim, dupe_number)
                end
            end
        end
    end

    return new_robot
end

dupe.roboport = function(roboport, dupe_number)
    local new_roboport = dupe.entity(roboport, dupe_number)
    if dupe.recolored[new_roboport.name] then
        return new_roboport
    end

    for _, animation_type in pairs({"door_animation_up", "door_animation_down"}) do
        new_roboport[animation_type] = add_icon_to_anim(new_roboport[animation_type], dupe_number)
    end

    return new_roboport
end

dupe.logistic_container = function(logistic_container, dupe_number)
    local new_logistic_container = dupe.entity(logistic_container, dupe_number)
    if dupe.recolored[new_logistic_container.name] then
        return new_logistic_container
    end

    if new_logistic_container.animation ~= nil then
        new_logistic_container.animation = add_icon_to_anim(new_logistic_container.animation, dupe_number)
    end
    if new_logistic_container.picture ~= nil then
        new_logistic_container.picture = {
            layers = {
                new_logistic_container.picture,
                {
                    filename = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number],
                    size = 120,
                    scale = 0.6,
                    shift = {-0.5, -0.5}
                }
            }
        }
    end

    return new_logistic_container
end

dupe.boiler = function(boiler, dupe_number)
    local new_boiler = dupe.entity(boiler, dupe_number)
    if dupe.recolored[new_boiler.name] then
        return new_boiler
    end

    if new_boiler.pictures ~= nil then
        for _, picture in pairs(new_boiler.pictures) do
            picture.structure = add_icon_to_anim(picture.structure, dupe_number)
        end
    end

    return new_boiler
end

dupe.generator = function(generator, dupe_number)
    local new_generator = dupe.entity(generator, dupe_number)
    if dupe.recolored[new_generator.name] then
        return new_generator
    end

    if new_generator.pictures ~= nil then
        for _, picture in pairs(new_generator.pictures) do
            picture.structure = add_icon_to_anim(picture.structure, dupe_number)
        end
    end

    --[[for _, animation_type in pairs({"horizontal_animation", "vertical_animation"}) do
        if new_generator[animation_type] ~= nil then
            new_generator[animation_type] = add_icon_to_anim(new_generator[animation_type], dupe_number)
        end
    end]]

    return new_generator
end

dupe.solar_panel = function(solar_panel, dupe_number)
    local new_solar_panel = dupe.entity(solar_panel, dupe_number)
    if dupe.recolored[new_solar_panel.name] then
        return new_solar_panel
    end

    if new_solar_panel.picture ~= nil then
        if new_solar_panel.picture.sheet ~= nil then
            new_solar_panel.picture.sheet = add_icon_to_anim(new_solar_panel.picture.sheet, dupe_number)
        elseif new_solar_panel.picture[1] ~= nil then
            for key, sprite in pairs(new_solar_panel.picture) do
                new_solar_panel.picture[key] = {
                    layers = {
                        new_solar_panel.picture,
                        {
                            filename = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number],
                            size = 120,
                            scale = 0.6,
                            shift = {-0.5, -0.5}
                        }
                    }
                }
            end
        else
            new_solar_panel.picture = add_icon_to_anim(new_solar_panel.picture, dupe_number)
        end
    end

    return new_solar_panel
end

dupe.reactor = function(reactor, dupe_number)
    local new_reactor = dupe.entity(reactor, dupe_number)
    if dupe.recolored[new_reactor.name] then
        return new_reactor
    end

    if new_reactor.picture ~= nil then
        new_reactor.picture = {
            layers = {
                new_reactor.picture,
                {
                    filename = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number],
                    size = 120,
                    scale = 0.6,
                    shift = {-0.5, -0.5}
                }
            }
        }
    end

    return new_reactor
end

dupe.crafting_machine = function(crafting_machine, dupe_number)
    local new_crafting_machine = dupe.entity(crafting_machine, dupe_number)
    if dupe.recolored[new_crafting_machine.name] then
        return new_crafting_machine
    end

    if new_crafting_machine.graphics_set ~= nil then
        if new_crafting_machine.graphics_set.animation ~= nil then
            if new_crafting_machine.graphics_set.animation.north ~= nil then
                for dir_key, dir_anim in pairs(new_crafting_machine.graphics_set.animation) do
                    if dir_anim.filename ~= nil or dir_anim.layers ~= nil then
                        new_crafting_machine.graphics_set.animation[dir_key] = add_icon_to_anim(dir_anim, dupe_number)
                    else
                        for key, anim in pairs(dir_anim) do
                            dir_anim[key] = add_icon_to_anim(anim, dupe_number)
                        end
                    end
                end
            else
                if new_crafting_machine.graphics_set.animation.filename ~= nil or new_crafting_machine.graphics_set.animation.layers ~= nil then
                    new_crafting_machine.graphics_set.animation = add_icon_to_anim(new_crafting_machine.graphics_set.animation, dupe_number)
                else
                    for key, anim in pairs(new_crafting_machine.graphics_set.animation) do
                        new_crafting_machine.graphics_set.animation[key] = add_icon_to_anim(anim, dupe_number)
                    end
                end
            end
        end
    end

    return new_crafting_machine
end

dupe.beacon = function(beacon, dupe_number)
    local new_beacon = dupe.entity(beacon, dupe_number)
    if dupe.recolored[new_beacon.name] then
        return new_beacon
    end

    if new_beacon.graphics_set ~= nil then
        if new_beacon.graphics_set.animation_list then
            for _, anim in pairs(new_beacon.graphics_set.animation_list) do
                if anim.animation ~= nil then
                    anim.animation = add_icon_to_anim(anim.animation, dupe_number)
                end
            end
        end
    end

    return new_beacon
end

dupe.mining_drill = function(mining_drill, dupe_number)
    local new_mining_drill = dupe.entity(mining_drill, dupe_number)
    if dupe.recolored[new_mining_drill.name] then
        return new_mining_drill
    end

    for _, graphics_set_key in pairs({"graphics_set", "wet_mining_graphics_set"}) do
        if new_mining_drill[graphics_set_key] ~= nil then
            if new_mining_drill[graphics_set_key].working_visualisations ~= nil then
                for _, anim_key in pairs({--[["animation",]] "north_animation", "east_animation", "south_animation", "west_animation"}) do
                    for _, working_vis in pairs(new_mining_drill[graphics_set_key].working_visualisations) do
                        if working_vis[anim_key] ~= nil then
                            working_vis[anim_key] = add_icon_to_anim(working_vis[anim_key], dupe_number)
                        end
                    end
                end
            else
                for _, anim_key in pairs({"animation", "idle_animation"}) do
                    if new_mining_drill[graphics_set_key][anim_key] ~= nil then
                        if new_mining_drill[graphics_set_key][anim_key].north ~= nil then
                            for dir_key, dir_val in pairs(new_mining_drill[graphics_set_key][anim_key]) do
                                new_mining_drill[graphics_set_key][anim_key][dir_key] = add_icon_to_anim(dir_val, dupe_number)
                            end
                        else
                            new_mining_drill[graphics_set_key][anim_key] = add_icon_to_anim(new_mining_drill[graphics_set_key][anim_key], dupe_number)
                        end
                    end
                end
            end
        end
    end

    return new_mining_drill
end

dupe.resource = function(resource, dupe_number)
    local new_resource = dupe.entity(resource, dupe_number)

    local function recursively_invert_colors(layer)
        if layer.layers ~= nil then
            for _, new_layer in pairs(layer.layers) do
                recursively_invert_colors(new_layer)
            end
        else
            layer.invert_colors = true
        end
    end

    if new_resource.stages ~= nil then
        if new_resource.stages.sheet ~= nil then
            recursively_invert_colors(new_resource.stages.sheet)
        elseif new_resource.stages.sheets ~= nil then
            for _, anim in pairs(new_resource.stages.sheets) do
                recursively_invert_colors(anim)
            end
        elseif new_resource.stages.layers ~= nil or new_resource.stages.filename ~= nil or new_resource.stages.filenames ~= nil then
            recursively_invert_colors(new_resource.stages)
        else
            for _, anim in pairs(new_resource.stages) do
                recursively_invert_colors(anim)
            end
        end
    end

    -- If there is a single minable result, duplicate that
    local associated_item_name
    if new_resource.minable ~= nil then
        if new_resource.minable.results ~= nil and #new_resource.minable.results == 1 and new_resource.minable.results[1].type == "item" then
            associated_item_name = new_resource.minable.results[1].name
        elseif new_resource.minable.result ~= nil then
            associated_item_name = new_resource.minable.result
        end
    end
    -- Find associated item from name
    local associated_item
    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil and data.raw[item_class][associated_item_name] then
            associated_item = data.raw[item_class][associated_item_name]
        end
    end
    if associated_item ~= nil then
        local new_associated_item = dupe.item(associated_item, dupe_number)

        if new_resource.minable ~= nil then
            if new_resource.minable.result == associated_item.name then
                new_resource.minable.result = new_associated_item.name
            elseif new_resource.minable.results ~= nil and #new_resource.minable.results == 1 and new_resource.minable.results[1].type == "item" and new_resource.minable.results[1].name == associated_item.name then
                new_resource.minable.results[1].name = new_associated_item.name
            end
        end

        -- Assume that a recipe with just the old associated item as an ingredient and in the smelting category is the processing/plate recipe for this item
        -- If there's multiple, the choice is just whatever we come across first
        local new_smelted_item
        local smelted_item
        for _, recipe in pairs(data.raw.recipe) do
            local is_smelting_recipe = false
            for _, cat in pairs(recipe.categories or {"crafting"}) do
                if cat == "smelting" then
                    is_smelting_recipe = true
                end
            end
            if is_smelting_recipe and recipe.ingredients ~= nil and #recipe.ingredients == 1 and recipe.ingredients[1].type == "item" and recipe.ingredients[1].name == associated_item.name then
                -- Also check that this recipe is named after its result
                if recipe.results ~= nil and #recipe.results == 1 and recipe.results[1].type == "item" and recipe.results[1].name == recipe.name then
                    -- Find the corresponding item
                    for item_class, _ in pairs(defines.prototypes.item) do
                        if data.raw[item_class] ~= nil and data.raw[item_class][recipe.name] ~= nil then
                            smelted_item = data.raw[item_class][recipe.name]
                            break
                        end
                    end
                    new_smelted_item = dupe.item(smelted_item, dupe_number)
                    data.raw.recipe[recipe.name .. "-exfret-" .. dupe_number .. "-copy"].ingredients[1].name = new_associated_item.name
                    break
                end
            end
        end
        -- Make sure this smelted item is in some new recipes
        if new_smelted_item ~= nil then
            for _, recipe in pairs(data.raw.recipe) do
                if not dupe.has_been_duplicated[rng.key({prototype = recipe})] then
                    if recipe.ingredients ~= nil then
                        for ing_ind, ing in pairs(recipe.ingredients) do
                            if ing.type == "item" and ing.name == smelted_item.name then
                                local new_recipe = dupe.recipe(recipe, dupe_number)
                                new_recipe.ingredients[ing_ind].name = new_smelted_item.name
                                break
                            end
                        end
                    end
                end
            end
        end
        -- Make sure the original ore is used in some new recipes if the old one was
        for _, recipe in pairs(data.raw.recipe) do
            if not dupe.has_been_duplicated[rng.key({prototype = recipe})] then
                if recipe.ingredients ~= nil then
                    for ing_ind, ing in pairs(recipe.ingredients) do
                        if ing.type == "item" and ing.name == associated_item.name then
                            local new_recipe = dupe.recipe(recipe, dupe_number)
                            new_recipe.ingredients[ing_ind].name = new_associated_item.name
                            break
                        end
                    end
                end
            end
        end
    end

    -- Finally, autoplace
    new_resource.autoplace = resource_autoplace.resource_autoplace_settings({
        name = new_resource.name,
        base_density = 30,
        has_starting_area_placement = true
    })
    -- Idk if autoplace controls actually do much, they probably need to be coded into the actual probability expression
    if data.raw["autoplace-control"][resource.name] ~= nil then
        local new_autoplace_control = dupe.prototype(data.raw["autoplace-control"][resource.name], dupe_number)
        for _, planet in pairs(data.raw.planet) do
            if planet.map_gen_settings ~= nil then
                if planet.autoplace_controls ~= nil then
                    if planet.autoplace_controls[resource.name] ~= nil then
                        planet.autoplace_controls[new_autoplace_control.name] = table.deepcopy(planet.autoplace_controls[resource.name])
                    end
                end
            end
        end
    end
    for _, planet in pairs(data.raw.planet) do
        if planet.map_gen_settings ~= nil then
            if planet.map_gen_settings.autoplace_settings ~= nil then
                if planet.map_gen_settings.autoplace_settings.entity.settings ~= nil then
                    if planet.map_gen_settings.autoplace_settings.entity.settings[resource.name] then
                        planet.map_gen_settings.autoplace_settings.entity.settings[new_resource.name] = table.deepcopy(planet.map_gen_settings.autoplace_settings.entity.settings[resource.name])
                    end
                end
            end
        end
    end

    return new_resource
end

-- Create the duplicates: the entities and items with recolored graphics
-- The technology and resource duplication functions above are older work that isn't wired in yet
dupe.execute = function()
    -- The dupe numbers come with the recolor sets shipped with the mod (dev/make-dupe-graphics.py), up to the setting's count (dupe.highest_number): a thing gets dupe n when its icon has a recolor for n
    local num_dupes = dupe.highest_number()

    -- Entities: the ones with recolored graphics, whatever their type (the list lives in dev/dupe-entities.txt)
    -- Found first, since duplicating adds prototypes to the tables being read
    local entities_to_dupe = {}
    for entity_class, _ in pairs(defines.prototypes.entity) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                if entity.hidden ~= true then
                    for i = 2, num_dupes do
                        if dupe.has_recolor(entity, i) then
                            table.insert(entities_to_dupe, {
                                prototype = entity,
                                dupe_number = i,
                            })
                        end
                    end
                end
            end
        end
    end
    -- Legs come with their spider vehicle
    local leg_names = {}
    for _, entry in pairs(entities_to_dupe) do
        if entry.prototype.type == "spider-vehicle" then
            local legs = entry.prototype.spider_engine.legs
            if legs.leg ~= nil then
                legs = {legs}
            end
            for _, leg_spec in pairs(legs) do
                leg_names[leg_spec.leg] = true
            end
        end
    end
    for _, entry in pairs(entities_to_dupe) do
        if leg_names[entry.prototype.name] == nil then
            if entry.prototype.type == "spider-vehicle" then
                dupe.spider_vehicle(entry.prototype, entry.dupe_number)
            else
                dupe.entity(entry.prototype, entry.dupe_number)
            end
        end
    end

    -- Items: the ones with recolored icons that no entity brought along (modules, fuels, guns, ammo, armor and the items that place equipment; the list lives in dev/dupe-items.txt)
    -- Science packs only come with planet copies (lib/dupe-planets.lua), never on their own
    local lab_inputs = dutils.lab_inputs()
    local items_to_dupe = {}
    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                if item.hidden ~= true and lab_inputs[item.name] == nil and not dupe.has_been_duplicated[rng.key({prototype = item})] then
                    for i = 2, num_dupes do
                        if dupe.item_has_recolor(item, i) then
                            table.insert(items_to_dupe, {
                                prototype = item,
                                dupe_number = i,
                            })
                        end
                    end
                end
            end
        end
    end
    for _, entry in pairs(items_to_dupe) do
        dupe.item(entry.prototype, entry.dupe_number)
    end
end

local function change_graphics_dupes(tbl, old_graphics, new_folder)
    if type(tbl) ~= "table" then
        return
    end
    for k, v in pairs(tbl) do
        change_graphics_dupes(v, old_graphics, new_folder)
        if type(v) == "string" then
            local last_part = string.match(v, "([^/]+)$")
            if old_graphics[last_part] then
                tbl[k] = new_folder .. "/" .. last_part
            end
        end
    end
end

-- Dupes manually chosen special entities with special graphics
dupe.execute_vanilla = function()
    local old_folder
    local new_folder
    -- Only contains the replaced files
    local old_filenames_to_new

    local function replace_with_new_graphics(tbl)
        for k, v in pairs(tbl) do
            if type(v) == "table" then
                replace_with_new_graphics(v)
            elseif type(v) == "string" then
                if string.find(v, old_folder, 1, true) ~= nil then
                    local filename = string.sub(v, #old_folder + 1, -1)
                    if old_filenames_to_new[filename] then
                        tbl[k] = new_folder .. old_filenames_to_new[filename]
                    end
                end
            end
        end
    end

    -- Extra transport belt tier between yellow and red
    -- TODO: Can't find graphics!

    -- Extra bulk inserter (uses filter inserter graphics)
    -- Has long-handedness but twice as expensive
    -- TODO: Corpse
    do
        local bulk_inserter = table.deepcopy(data.raw.inserter["bulk-inserter"])
        bulk_inserter.name = "bulk-inserter-2"
        old_folder = "__base__/graphics/entity/bulk-inserter/"
        new_folder = "__reskins-assets-bobs__/graphics/entity/inserters/inserter-express-filter/"
        old_filenames_to_new = {
            ["bulk-inserter-hand-base.png"] = "inserter-express-filter-arm.png",
            ["bulk-inserter-hand-closed.png"] = "inserter-express-filter-hand-closed.png",
            ["bulk-inserter-hand-open.png"] = "inserter-express-filter-hand-open.png",
            ["bulk-inserter-platform.png"] = "inserter-express-filter-platform.png",
        }
        replace_with_new_graphics(bulk_inserter)
        bulk_inserter.icon = "__reskins-assets-bobs__/graphics/icons/inserters/express-filter-inserter-icon.png"
        bulk_inserter.insert_position = data.raw.inserter["long-handed-inserter"].insert_position
        bulk_inserter.pickup_position = data.raw.inserter["long-handed-inserter"].pickup_position
        local bulk_inserter_item = table.deepcopy(data.raw.item["bulk-inserter"])
        bulk_inserter_item.name = bulk_inserter.name
        bulk_inserter_item.icon = "__reskins-assets-bobs__/graphics/icons/inserters/express-filter-inserter-icon.png"
        bulk_inserter_item.place_result = bulk_inserter.name
        bulk_inserter.minable.result = bulk_inserter_item.name
        bulk_inserter_recipe = table.deepcopy(data.raw.recipe["bulk-inserter"])
        bulk_inserter_recipe.name = bulk_inserter.name
        for _, ing in pairs(bulk_inserter_recipe.ingredients) do
            ing.amount = ing.amount * 2
        end
        bulk_inserter_recipe.results[1].name = bulk_inserter_item.name
        table.insert(data.raw.technology["bulk-inserter"].effects, {
            type = "unlock-recipe",
            recipe = bulk_inserter_recipe.name
        })
        data.raw.inserter[bulk_inserter.name] = bulk_inserter
        data.raw.item[bulk_inserter_item.name] = bulk_inserter_item
        data.raw.recipe[bulk_inserter_recipe.name] = bulk_inserter_recipe
    end

    -- Extra stack inserter (uses Bob's express bulk inserter graphics)
    -- Half as expensive and corners
    -- TODO: Remnants
    do
        if mods["space-age"] then
            local stack_inserter = table.deepcopy(data.raw.inserter["stack-inserter"])
            stack_inserter.name = "stack-inserter-2"
            old_folder = "__space-age__/graphics/entity/stack-inserter/"
            -- The png's needed slight resizings because frickin stack inserters need to have special graphics sizes for some reason
            new_folder = "__propertyrandomizer__/graphics/duplicates/stack-inserter/"
            old_filenames_to_new = {
                ["stack-inserter-hand-base.png"] = "inserter-express-bulk-arm.png",
                ["stack-inserter-hand-closed.png"] = "inserter-express-bulk-hand-closed.png",
                ["stack-inserter-hand-open.png"] = "inserter-express-bulk-hand-open.png",
                ["stack-inserter-platform.png"] = "inserter-express-bulk-platform.png",
            }
            replace_with_new_graphics(stack_inserter)
            stack_inserter.icon = "__reskins-assets-bobs__/graphics/icons/inserters/express-inserter-icon.png"
            stack_inserter.insert_position = {
                -stack_inserter.insert_position[2],
                stack_inserter.insert_position[1]
            }
            -- Allow inserter to be flipped
            stack_inserter.allow_custom_vectors = true
            local stack_inserter_item = table.deepcopy(data.raw.item["stack-inserter"])
            stack_inserter_item.name = stack_inserter.name
            stack_inserter_item.icon = "__reskins-assets-bobs__/graphics/icons/inserters/express-inserter-icon.png"
            stack_inserter_item.place_result = stack_inserter.name
            stack_inserter.minable.result = stack_inserter_item.name
            stack_inserter_recipe = table.deepcopy(data.raw.recipe["stack-inserter"])
            stack_inserter_recipe.name = stack_inserter.name
            for _, ing in pairs(stack_inserter_recipe.ingredients) do
                ing.amount = math.ceil(ing.amount * 0.5)
            end
            stack_inserter_recipe.results[1].name = stack_inserter_item.name
            table.insert(data.raw.technology["stack-inserter"].effects, {
                type = "unlock-recipe",
                recipe = stack_inserter_recipe.name
            })
            data.raw.inserter[stack_inserter.name] = stack_inserter
            data.raw.item[stack_inserter_item.name] = stack_inserter_item
            data.raw.recipe[stack_inserter_recipe.name] = stack_inserter_recipe
        end
    end

    -- TODO: Extra locomotive (need graphics)

    -- TODO: Car (need graphics)

    -- TODO: Spidertron (need graphics)

    -- TODO: Logistic/construction robots (need graphics - could try with mask like what reskins does in main mod)

    -- Big mining drill
    if mods["space-age"] then
        --[[local big_mining_drill = table.deepcopy(data.raw["mining-drill"]["big-mining-drill"])
        big_mining_drill.name = "big-mining-drill-2"
        local big_mining_drill_graphics = {
            ["big-mining-drill-E-still-front.png"] = true,
            ["big-mining-drill-E-support.png"] = true,
            ["big-mining-drill-E-top.png"] = true,
            ["big-mining-drill-N-still-front.png"] = true,
            ["big-mining-drill-N-support.png"] = true,
            ["big-mining-drill-N-top.png"] = true,
            ["big-mining-drill-W-still-front.png"] = true,
            ["big-mining-drill-W-support.png"] = true,
            ["big-mining-drill-W-top.png"] = true,
            ["big-mining-drill-S-still-front.png"] = true,
            ["big-mining-drill-S-support.png"] = true,
            ["big-mining-drill-S-top.png"] = true,
            ["big-mining-drill-remnants.png"] = true,
            ["big-mining-drill.png"] = true,
        }
        change_graphics_dupes(big_mining_drill, big_mining_drill_graphics, "__propertyrandomizer__/graphics/duplicates/big-mining-drill")
        data.raw["mining-drill"]["big-mining-drill-2"] = big_mining_drill
        -- TODO: item etc.]]
    end
end

-- TODO: In an unfinished state
dupe.recipe_tech_unlocks = function()
    -- We need to add tech unlocks to different techs due to how they work
    local all_recipe_effects = {}
    local all_techs = {}
    local unlock_to_tech = {}
    -- CRITICAL TODO: FIX NEXT LINE TO BE NEW DATA RAW
    for _, tech in pairs(old_data_raw.technology) do
        table.insert(all_techs, tech)
        if tech.effects ~= nil then
            for _, effect in pairs(tech.effects) do
                if effect.type == "unlock-recipe" then
                    unlock_to_tech[effect.recipe] = unlock_to_tech[effect.recipe] or {}
                    unlock_to_tech[effect.recipe][tech.name] = true
                    table.insert(all_recipe_effects, table.deepcopy(effect))
                end
            end
        end
    end
    for recipe_name, techs in pairs(unlock_to_tech) do
        for tech_name, _ in pairs(techs) do
            local already_has_unlock = false
            for _, unlock in pairs(data.raw.technology[tech_name].effects) do
                if unlock.type == "unlock-recipe" and unlock.recipe == recipe_name then
                    already_has_unlock = true
                end
            end
            if not already_has_unlock then
                table.insert(data.raw.technology[tech_name].effects, {
                    type = "unlock-recipe",
                    recipe = recipe_name,
                })
            end
        end
    end
    -- TODO: Uncomment out!
    --[[
    for _, effect in pairs(all_recipe_effects) do
        local tech
        while true do
            tech = all_techs[rng.int(rng.key({id = "recipe-tech-unlock-dupes"}), #all_techs)]
            if not unlock_to_tech[effect.recipe][tech.name] then
                break
            end
        end
        tech.effects = tech.effects or {}
        table.insert(tech.effects, effect)
    end]]
end

return dupe