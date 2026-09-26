local collision_mask_util = require("__core__/lualib/collision-mask-util")
local categories = require("helper-tables/categories")
local dutils = require("lib/data-utils")

local common = {}

-- Entities that really need to be on a grid or else they, like, freeze the game and stuff
common.grid_like_entity_classes = {
    ["curved-rail-a"] = true,
    ["elevated-curved-rail-a"] = true,
    ["curved-rail-b"] = true,
    ["elevated-curved-rail-b"] = true,
    ["half-diagonal-rail"] = true,
    ["elevated-half-diagonal-rail"] = true,
    ["legacy-curved-rail"] = true,
    ["legacy-straight-rail"] = true,
    ["rail-ramp"] = true,
    ["straight-rail"] = true,
    ["elevated-straight-rail"] = true,
    ["transport-belt"] = true,
    ["underground-belt"] = true,
    ["splitter"] = true,
    ["lane-splitter"] = true,
    ["linked-belt"] = true,
    ["loader-1x1"] = true,
    ["loader"] = true,
}

-- TODO: Work in vehicles (item-with-entity-data)
common.valid_item_placeable_types = {
    ["item"] = true,
    ["ammo"] = true,
    ["gun"] = true,
    ["module"] = true,
    ["space-platform-starter-pack"] = true,
    ["armor"] = true,
    ["repair-tool"] = true,
}

common.is_valid_placeable = function(item)
    if item.hidden then
        return false
    end

    if not common.valid_item_placeable_types[item.type] then
        return false
    end

    if item.plant_result ~= nil then
        return false
    end

    if item.place_as_tile ~= nil then
        return false
    end

    if item.flags ~= nil then
        for _, flag in pairs(item.flags) do
            if flag == "not-stackable" or flag == "spawnable" then
                return false
            end
        end
    end
    
    if item.equipment_grid ~= nil then
        return false
    end

    if item.parameter then
        return false
    end

    return true
end

-- Just find the first item that places an entity
common.entity_to_place_item = {}
common.populate_entity_to_place_item = function()
    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                if item.place_result ~= nil then
                    common.entity_to_place_item[item.place_result] = item
                end
            end
        end
    end
end

-- Makes mining the entity give exactly one of item_name; returns false (changing nothing) if the entity isn't minable
-- MinableProperties only reads result/count when results is absent, so results has to be cleared too
common.set_mining_result = function(entity, item_name)
    if entity.minable == nil then
        return false
    end

    entity.minable.results = nil
    entity.minable.result = item_name
    entity.minable.count = 1
    return true
end

-- Makes mining the entity give new_item_name wherever it gave old_item_name, leaving any other results alone; returns whether anything changed
common.replace_mining_item = function(entity, old_item_name, new_item_name)
    if entity.minable == nil then
        return false
    end

    local replaced = false
    if entity.minable.results ~= nil then
        for _, product in pairs(entity.minable.results) do
            if product.type == "item" and product.name == old_item_name then
                product.name = new_item_name
                replaced = true
            end
        end
    elseif entity.minable.result == old_item_name then
        entity.minable.result = new_item_name
        replaced = true
    end
    return replaced
end

-- Makes mining the entity also give one item_name, keeping everything it gave before; returns false (changing nothing) if the entity isn't minable
-- MinableProperties only reads result/count when results is absent, so a single result moves into results
common.add_mining_item = function(entity, item_name)
    if entity.minable == nil then
        return false
    end

    if entity.minable.results == nil then
        local results = {}
        if entity.minable.result ~= nil then
            table.insert(results, {
                type = "item",
                name = entity.minable.result,
                amount = entity.minable.count or 1,
            })
        end
        entity.minable.results = results
        entity.minable.result = nil
        entity.minable.count = nil
    end
    table.insert(entity.minable.results, {
        type = "item",
        name = item_name,
        amount = 1,
    })
    return true
end

-- Makes mining the entity give new_item_name in place of the entity's own items (old_item_names), keeping everything else it gave, like a plant's fruit
-- With must_give, new_item_name is added if mining gave none of them, for when mining is how new_item_name is gotten
common.swap_mining_items = function(entity, old_item_names, new_item_name, must_give)
    local replaced = false
    for _, old_item_name in pairs(old_item_names) do
        if common.replace_mining_item(entity, old_item_name, new_item_name) then
            replaced = true
        end
    end
    if must_give and not replaced then
        return common.add_mining_item(entity, new_item_name)
    end
    return replaced
end

-- Makes the entity's placeable_by use new_item_name wherever it used old_item_name
-- placeable_by can be a single ItemToPlace or an array of them
common.replace_placeable_by_item = function(entity, old_item_name, new_item_name)
    local placeable_by = entity.placeable_by
    if placeable_by == nil then
        return
    end
    if placeable_by.item ~= nil then
        placeable_by = {
            placeable_by,
        }
    end
    for _, item_to_place in pairs(placeable_by) do
        if item_to_place.item == old_item_name then
            item_to_place.item = new_item_name
        end
    end
end

-- Adds item_name to the entity's placeable_by, keeping any entries already there
-- placeable_by can be a single ItemToPlace or an array of them
common.add_placeable_by = function(entity, item_name)
    local placeable_by = entity.placeable_by
    if placeable_by == nil then
        placeable_by = {}
    elseif placeable_by.item ~= nil then
        placeable_by = {
            placeable_by,
        }
    end

    local already_placeable = false
    for _, item_to_place in pairs(placeable_by) do
        if item_to_place.item == item_name then
            already_placeable = true
        end
    end
    if not already_placeable then
        table.insert(placeable_by, {
            item = item_name,
            count = 1,
        })
    end
    entity.placeable_by = placeable_by
end

-- Whether an item already places something when used on the world (an entity, a plant or a tile), which is a left click
common.places_something = function(item)
    return item.place_result ~= nil or item.plant_result ~= nil or item.place_as_tile ~= nil
end

-- The entity an item places, counting planting, which is building that agricultural towers can do too
common.placed_entity_name = function(item)
    return item.place_result or item.plant_result
end

-- Makes an item place the entity (and nothing else), planting it if it's a plant so agricultural towers can plant it too, like vanilla seeds
common.set_placed_entity = function(item, entity)
    item.place_result = entity.name
    if entity.type == "plant" then
        item.plant_result = entity.name
    else
        item.plant_result = nil
    end
end

-- Icon groups an item can have, by property prefix: its icon, and the one alt-mode shows instead if set
common.item_icon_prefixes = {
    "",
    "dark_background_",
}

-- A copy of one of a prototype's icon groups (icons, or icon and icon_size, after prefix) as a list of IconData layers, or nil if it doesn't have one
common.icon_layers = function(prototype, prefix)
    if prototype[prefix .. "icons"] ~= nil then
        return table.deepcopy(prototype[prefix .. "icons"])
    end
    if prototype[prefix .. "icon"] ~= nil then
        return {
            {
                icon = prototype[prefix .. "icon"],
                icon_size = prototype[prefix .. "icon_size"],
            },
        }
    end
    return nil
end

-- Sets one of a prototype's icon groups to these layers, or clears it if layers is nil
common.set_icon_layers = function(prototype, prefix, layers)
    prototype[prefix .. "icons"] = layers
    prototype[prefix .. "icon"] = nil
    prototype[prefix .. "icon_size"] = nil
end

-- A badge is another icon at half size in the top left corner (the bottom corners show item counts and quality)
-- Vanilla badges barrel recipe icons with their fluid the same way (util.combine_icons)
local BADGE_SCALE = 0.5
-- Item icons are 32 units across in IconData shifts, so this puts the badge's center in the middle of the top left quarter
local BADGE_SHIFT = {
    -8,
    -8,
}

-- The layers with badge_layers added on top as a badge
common.with_icon_badge = function(layers, badge_layers)
    local result = table.deepcopy(layers)
    for ind, badge_layer in pairs(table.deepcopy(badge_layers)) do
        -- IconData's default scale draws the icon at full size, which is 32 units across
        badge_layer.scale = BADGE_SCALE * (badge_layer.scale or 32 / (badge_layer.icon_size or 64))
        local shift_x = 0
        local shift_y = 0
        if badge_layer.shift ~= nil then
            shift_x = badge_layer.shift.x or badge_layer.shift[1]
            shift_y = badge_layer.shift.y or badge_layer.shift[2]
        end
        badge_layer.shift = {
            BADGE_SCALE * shift_x + BADGE_SHIFT[1],
            BADGE_SCALE * shift_y + BADGE_SHIFT[2],
        }
        -- Outline the badge like a standalone icon, so it stands apart from the icon under it
        badge_layer.draw_background = ind == 1
        -- Keep the badge from making the whole icon shrink to fit it
        badge_layer.floating = true
        table.insert(result, badge_layer)
    end
    return result
end

-- How bright a Vestige's icon is compared to the icon it copies (the 0.5 gray tint the old entity randomizations used)
local VESTIGE_BRIGHTNESS = 0.5

-- Darkens layers in place for a Vestige (an item that no longer places anything), keeping each layer's own tint
common.darken_icon_layers = function(layers)
    for _, layer in pairs(layers) do
        -- A layer without a tint is drawn as is (opaque white); channels left out of a tint are 0, except alpha, which is opaque
        local r = 1
        local g = 1
        local b = 1
        local a
        local tint = layer.tint
        if tint ~= nil then
            r = tint.r or tint[1] or 0
            g = tint.g or tint[2] or 0
            b = tint.b or tint[3] or 0
            a = tint.a or tint[4]
        end
        -- A color with any channel given above 1 is in the 0-255 range
        if r > 1 or g > 1 or b > 1 or (a ~= nil and a > 1) then
            r, g, b = r / 255, g / 255, b / 255
            if a ~= nil then
                a = a / 255
            end
        end
        if a == nil then
            a = 1
        end
        layer.tint = {
            r = VESTIGE_BRIGHTNESS * r,
            g = VESTIGE_BRIGHTNESS * g,
            b = VESTIGE_BRIGHTNESS * b,
            a = a,
        }
    end
    return layers
end

-- Bounding boxes and positions can each be written with positional or named entries
local function box_coords(box)
    box = box or {{0, 0}, {0, 0}}
    local left_top = box.left_top or box[1]
    local right_bottom = box.right_bottom or box[2]
    return {
        left_top.x or left_top[1],
        left_top.y or left_top[2],
        right_bottom.x or right_bottom[1],
        right_bottom.y or right_bottom[2],
    }
end

-- The first single-frame sprite layer of a sprite or animation definition (a file, or the first of its layers, sheets or directions), or nil
local function first_sprite_layer(source)
    if type(source) ~= "table" then
        return nil
    end
    if source.filename ~= nil then
        return {
            filename = source.filename,
            width = source.width or source.size,
            height = source.height or source.size,
            scale = source.scale or 1,
            shift = source.shift,
        }
    end
    return first_sprite_layer(source.layers and source.layers[1])
        or first_sprite_layer(source.sheet)
        or first_sprite_layer(source.sheets and source.sheets[1])
        or first_sprite_layer(source.north)
        or first_sprite_layer(source[1])
end

-- Largest width or height of an entity's selection (or collision) box in tiles, at least one tile
local function box_size(entity)
    local coords = box_coords(entity.selection_box or entity.collision_box)
    return math.max(1, coords[3] - coords[1], coords[4] - coords[2])
end
common.box_size = box_size

-- An entity's look as one still sprite layer (for a RotatedAnimation with one frame and direction), sized to be tiles across
-- Uses the entity's main graphics when it has any of the usual ones, and its icon otherwise
common.entity_sprite = function(entity, tiles)
    local source
    if entity.graphics_set ~= nil then
        source = entity.graphics_set.animation or entity.graphics_set.idle_animation
    end
    source = source or entity.on_animation or entity.animation or entity.horizontal_animation or entity.animations or entity.base_animation or entity.picture or entity.pictures
    local layer = first_sprite_layer(source)
    if layer ~= nil and layer.width ~= nil and layer.height ~= nil then
        -- The sprite is drawn about as big as the entity, so shrink it by how much bigger the entity is than the target
        layer.scale = layer.scale * tiles / box_size(entity)
    else
        -- Icons are drawn 32 pixels to a tile at scale 1
        local icon_layers = common.icon_layers(entity, "")
        if icon_layers == nil then
            return nil
        end
        local icon_size = icon_layers[1].icon_size or 64
        layer = {
            filename = icon_layers[1].icon,
            width = icon_size,
            height = icon_size,
            scale = tiles * 32 / icon_size,
        }
    end
    layer.frame_count = 1
    layer.direction_count = 1
    if layer.shift ~= nil then
        layer.shift = {
            (layer.shift.x or layer.shift[1]) * tiles / box_size(entity),
            (layer.shift.y or layer.shift[2]) * tiles / box_size(entity),
        }
    end
    return layer
end

-- Area of an entity's collision box in tiles, counting one smaller than a tile (or none) as a tile
common.collision_area = function(entity)
    local coords = box_coords(entity.collision_box)
    return math.max(1, (coords[3] - coords[1]) * (coords[4] - coords[2]))
end

-- Collision layers that some tile uses; an entity colliding with none of them can stand on any tile
local function tile_layers()
    local layers = {}
    for _, tile in pairs(data.raw.tile or {}) do
        for layer, _ in pairs((tile.collision_mask or {}).layers or {}) do
            layers[layer] = true
        end
    end
    return layers
end

-- Whether an entity can be autoplaced wherever another one was: it collides with no tile layer the other doesn't, and its collision box is at most area_tolerance times as big
-- Autoplace skips spots where an entity collides (AutoplaceSpecification.placement_density), so a bigger entity just shows up less
common.fits_autoplace_of = function(entity, other, area_tolerance)
    if common.collision_area(entity) > area_tolerance * common.collision_area(other) then
        return false
    end
    local any_tile_layer = tile_layers()
    local other_layers = collision_mask_util.get_mask(other).layers
    for layer, _ in pairs(collision_mask_util.get_mask(entity).layers) do
        if any_tile_layer[layer] ~= nil and other_layers[layer] == nil then
            return false
        end
    end
    return true
end

local function boxes_equal(box1, box2)
    local coords1 = box_coords(box1)
    local coords2 = box_coords(box2)
    for i = 1, 4 do
        if coords1[i] ~= coords2[i] then
            return false
        end
    end
    return true
end

local collision_mask_flags = {
    "not_colliding_with_itself",
    "consider_tile_transitions",
    "colliding_with_tiles_only",
}

local function masks_equal(entity1, entity2)
    local mask1 = collision_mask_util.get_mask(entity1)
    local mask2 = collision_mask_util.get_mask(entity2)
    if not collision_mask_util.masks_are_same(mask1, mask2) then
        return false
    end
    for _, flag in pairs(collision_mask_flags) do
        if (mask1[flag] == true) ~= (mask2[flag] == true) then
            return false
        end
    end
    return true
end

-- Whether some non-hidden item builds the entity, either through place_result or the entity's placeable_by
local function has_non_hidden_builder(entity)
    for _, item in pairs(dutils.get_all_prots("item")) do
        if item.place_result == entity.name and not item.hidden then
            return true
        end
    end

    local placeable_by = entity.placeable_by
    if placeable_by ~= nil and placeable_by.item ~= nil then
        placeable_by = {
            placeable_by,
        }
    end
    for _, item_to_place in pairs(placeable_by or {}) do
        local item = dutils.get_prot("item", item_to_place.item)
        if item ~= nil and not item.hidden then
            return true
        end
    end

    return false
end

-- Whether mining the entity can give a hidden item, which the engine doesn't allow for an entity with a next_upgrade
local function mines_hidden_item(entity)
    local mined_items = {}
    if entity.minable.results ~= nil then
        for _, product in pairs(entity.minable.results) do
            if product.type == "item" then
                table.insert(mined_items, product.name)
            end
        end
    elseif entity.minable.result ~= nil then
        table.insert(mined_items, entity.minable.result)
    end

    for _, item_name in pairs(mined_items) do
        local item = dutils.get_prot("item", item_name)
        if item ~= nil and item.hidden then
            return true
        end
    end
    return false
end

-- The engine's load checks for next_upgrade (EntityPrototype::next_upgrade in the 2.1 API docs)
-- Returns nil if the entity's next_upgrade passes them, or otherwise the reason it doesn't
-- Randomizing which items place what, or what entities mine into, can break these, so this should be checked after reflection
common.next_upgrade_problem = function(entity)
    if entity.next_upgrade == nil then
        return nil
    end

    for _, flag in pairs(entity.flags or {}) do
        if flag == "not-upgradable" then
            return "entity has the not-upgradable flag"
        end
    end
    if entity.minable == nil then
        return "entity isn't minable"
    end
    if mines_hidden_item(entity) then
        return "entity mines into a hidden item"
    end
    if categories.rolling_stock[entity.type] ~= nil then
        return "entity is rolling stock"
    end

    local target = dutils.get_prot("entity", entity.next_upgrade)
    if target == nil then
        return "upgrade target " .. entity.next_upgrade .. " doesn't exist"
    end
    if not boxes_equal(entity.collision_box, target.collision_box) then
        return "upgrade target has a different collision box"
    end
    if not masks_equal(entity, target) then
        return "upgrade target has a different collision mask"
    end
    if (entity.fast_replaceable_group or "") ~= (target.fast_replaceable_group or "") then
        return "upgrade target has a different fast replaceable group"
    end
    if not has_non_hidden_builder(target) then
        return "no non-hidden item builds the upgrade target"
    end

    return nil
end

return common