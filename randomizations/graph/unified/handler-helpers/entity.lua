local collision_mask_util = require("__core__/lualib/collision-mask-util")
local categories = require("helper-tables/categories")
local dutils = require("lib/data-utils")

local common = {}

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

-- Trigger delivery fields naming the entity a delivery sends (ProjectileTriggerDelivery and ArtilleryTriggerDelivery's projectile, BeamTriggerDelivery's beam, StreamTriggerDelivery's stream), whose own triggers carry on where it lands
local sent_entity_fields = {
    ["projectile"] = true,
    ["beam"] = true,
    ["stream"] = true,
}

-- Makes a trigger create other entities: rewrites, in place, each create-entity effect whose entity_name is a key of retargets (entity name --> function(effect) that rewrites the effect)
-- Pass a copy of the trigger (like a copy of a capsule's capsule_action), since it's changed in place
-- Entities it sends by name (like a capsule's projectile) are followed; each one with an effect to rewrite is replaced by a copy named copy_name(its name), so nothing else sending it changes
-- Returns how many effects were rewritten, and the copies, which the caller adds to data
common.retarget_created_entities = function(trigger, retargets, copy_name)
    local num_rewritten = 0
    local copies = {}
    -- Each table is rewritten at most once, even if the trigger holds it twice, so an effect retargeted to an entity that's also retargeted isn't rewritten again
    local seen = {}
    -- Sent entity name --> name of its rewritten copy, or false if it has nothing to rewrite
    local copy_names = {}
    local walk
    local function follow(sent_name)
        if copy_names[sent_name] == nil then
            -- Marked before walking, so an entity that sends itself isn't followed forever
            copy_names[sent_name] = false
            local prototype = dutils.get_prot("entity", sent_name)
            if prototype ~= nil then
                local copy = table.deepcopy(prototype)
                if walk(copy) then
                    copy.name = copy_name(sent_name)
                    copy_names[sent_name] = copy.name
                    table.insert(copies, copy)
                end
            end
        end
        return copy_names[sent_name]
    end
    walk = function(object)
        if seen[object] ~= nil then
            return false
        end
        seen[object] = true
        local rewrote = false
        for field, value in pairs(object) do
            if type(value) == "table" then
                if walk(value) then
                    rewrote = true
                end
            elseif type(value) == "string" and sent_entity_fields[field] ~= nil then
                local sent_copy_name = follow(value)
                if sent_copy_name ~= false then
                    object[field] = sent_copy_name
                    rewrote = true
                end
            end
        end
        if object.type == "create-entity" and retargets[object.entity_name] ~= nil then
            retargets[object.entity_name](object)
            num_rewritten = num_rewritten + 1
            rewrote = true
        end
        return rewrote
    end
    walk(trigger)
    return num_rewritten, copies
end

-- Rewrites a create-entity effect to create entity_name instead, at a free spot near where it lands and never over space, since what it made before might have fit anywhere (like a flying robot)
common.create_at_free_spot = function(effect, entity_name)
    effect.entity_name = entity_name
    effect.find_non_colliding_position = true
    effect.abort_if_over_space = true
end

-- Rewrites a create-entity effect to create one entity_name that's placed like a building: at a free spot (create_at_free_spot), for the force that set it off (never as an enemy), and nothing if there's no room
-- For triggers that made something else, like a combat robot, now making a building that's mined for an item placing it
common.create_as_building = function(effect, entity_name)
    common.create_at_free_spot(effect, entity_name)
    effect.offsets = nil
    effect.repeat_count = nil
    effect.repeat_count_deviation = nil
    effect.as_enemy = nil
    effect.ignore_no_enemies_mode = nil
    effect.non_colliding_fail_result = nil
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

-- A wreck of an entity: a rock-like simple entity with the entity's size and a darkened copy of its look, mined for one item_name
-- Its icon is a darkened copy of the icon of look (like the entity's own item)
-- A simple entity is neutral even when an enemy's dying trigger makes it, so anyone can mine it, unlike the entity itself, which would be the enemy's
common.wreck_of = function(entity, name, item_name, look)
    local sprite = common.entity_sprite(entity, box_size(entity))
    if sprite == nil then
        error("Randomization assertion failed! " .. entity.name .. " has no look for a wreck")
    end
    -- A simple entity's picture is a still sprite, not an animation
    sprite.frame_count = nil
    sprite.direction_count = nil
    sprite.tint = {
        r = 0.45,
        g = 0.45,
        b = 0.45,
        a = 1,
    }
    local wreck = {
        type = "simple-entity",
        name = name,
        flags = {
            "placeable-neutral",
            "placeable-off-grid",
        },
        collision_box = table.deepcopy(entity.collision_box),
        selection_box = table.deepcopy(entity.selection_box or entity.collision_box),
        max_health = entity.max_health or 100,
        picture = sprite,
        minable = {
            mining_time = 1,
            results = {
                {
                    type = "item",
                    name = item_name,
                    amount = 1,
                },
            },
        },
    }
    common.set_icon_layers(wreck, "", common.darken_icon_layers(common.icon_layers(look, "")))
    return wreck
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

-- Whether an item is a capsule that explodes cliffs when used (a destroy-cliffs capsule action)
common.explodes_cliffs = function(item)
    return item ~= nil and item.capsule_action ~= nil and item.capsule_action.type == "destroy-cliffs"
end

-- Cliffs name the capsule that explodes them (CliffPrototype::cliff_explosive in the 2.1 API docs), and the engine's load checks that its capsule action still explodes cliffs
-- After capsule effects moved (capsule_effect: capsule --> the capsule whose effect it has now), each cliff whose explosive lost that effect follows it to the capsule that has it now, or to any capsule that still explodes cliffs, or forgets its explosive when none is left (a Vestige took the effect)
-- Returns one {cliff, from, to} per cliff changed, in cliff name order, with to = nil for a forgotten explosive
common.cliffs_follow_explosives = function(capsule_effect)
    local effect_now_on = {}
    for capsule_name, from_name in pairs(capsule_effect) do
        effect_now_on[from_name] = capsule_name
    end
    -- The first capsule by name that explodes cliffs now, for cliffs whose own explosive's effect no capsule has
    local fallback
    for name, item in pairs(dutils.get_all_prots("item")) do
        if common.explodes_cliffs(item) and (fallback == nil or name < fallback) then
            fallback = name
        end
    end
    local changes = {}
    for _, cliff in pairs(data.raw.cliff or {}) do
        local explosive = cliff.cliff_explosive
        if explosive ~= nil and not common.explodes_cliffs(dutils.get_prot("item", explosive)) then
            local new_explosive = effect_now_on[explosive]
            if new_explosive == nil or not common.explodes_cliffs(dutils.get_prot("item", new_explosive)) then
                new_explosive = fallback
            end
            cliff.cliff_explosive = new_explosive
            table.insert(changes, {
                cliff = cliff.name,
                from = explosive,
                to = new_explosive,
            })
        end
    end
    table.sort(changes, function(a, b)
        return a.cliff < b.cliff
    end)
    return changes
end

return common