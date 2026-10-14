local collision_mask_util = require("__core__/lualib/collision-mask-util")
local profiles = require("src/randomizations/planetary/biome-profiles")

local collision = {}

local function sorted_keys(values)
    local result = {}
    for name, _ in pairs(values) do
        table.insert(result, name)
    end
    table.sort(result)
    return result
end

local function effective_mask(raw, entity)
    if entity.collision_mask ~= nil then
        return entity.collision_mask
    end
    for _, constants in pairs(raw["utility-constants"] or {}) do
        if constants.default_collision_masks ~= nil and constants.default_collision_masks[entity.type] ~= nil then
            return constants.default_collision_masks[entity.type]
        end
    end
    return collision_mask_util.get_mask(entity)
end

-- A shared layer can block both terrain and another entity.
-- Give every entity-side mask an alias before dropping terrain layers from selected buildings; tiles never receive these aliases.
-- This includes prototype hit filters and other nested collision masks, not just primary entity masks.
collision.prepare = function(raw, prototype_types, extend)
    local layers = {}
    for _, tile in pairs(raw.tile) do
        for layer, _ in pairs(tile.collision_mask.layers) do
            layers[layer] = true
        end
    end
    local aliases, additions = {}, {}
    for index, layer in pairs(sorted_keys(layers)) do
        aliases[layer] = "propertyrandomizer_biome_entity_" .. index
        table.insert(additions, aliases[layer])
    end
    for _, profile in pairs(profiles.order) do
        if profile ~= "normal" then
            table.insert(additions, profiles.layer(profile))
            table.insert(additions, profiles.blocking_layer(profile))
        end
    end
    table.insert(additions, profiles.layer("platform"))
    local count = 0
    for _, _ in pairs(raw["collision-layer"] or {}) do
        count = count + 1
    end
    if count + #additions > 256 then
        return nil, "collision-layer capacity exceeded"
    end
    for _, name in pairs(additions) do
        if (raw["collision-layer"] or {})[name] ~= nil then
            return nil, "collision-layer name already exists: " .. name
        end
    end
    collision.refresh(raw, prototype_types, aliases)
    for _, name in pairs(additions) do
        extend({{type = "collision-layer", name = name}})
    end
    return aliases
end

-- Reapply to prototypes created later, such as Original/Free copies made after the final graph check.
-- Runtime scripts constructing new collision masks must include the same aliases themselves.
collision.refresh = function(raw, prototype_types, aliases)
    local tile_masks = {}
    for _, tile in pairs(raw.tile) do
        tile_masks[tile.collision_mask] = true
    end
    -- Materialize the actual UtilityConstants defaults, which other mods can override.
    for entity_type, _ in pairs(prototype_types.entity) do
        for _, entity in pairs(raw[entity_type] or {}) do
            entity.collision_mask = table.deepcopy(effective_mask(raw, entity))
        end
    end
    local seen = {}
    local function visit(value)
        if type(value) ~= "table" or seen[value] then
            return
        end
        seen[value] = true
        if type(value.layers) == "table" and not tile_masks[value] then
            -- Detach shared layer dictionaries before adding entity-only aliases.
            value.layers = table.deepcopy(value.layers)
            for layer, alias in pairs(aliases) do
                if value.layers[layer] then
                    value.layers[alias] = true
                end
            end
        end
        for _, child in pairs(value) do
            visit(child)
        end
    end
    for kind, prototypes in pairs(raw) do
        if kind ~= "mod-data" then
            visit(prototypes)
        end
    end
end

collision.area = function(entity)
    local box = entity.collision_box
    if box == nil then
        return nil
    end
    local a, b = box.left_top or box[1], box.right_bottom or box[2]
    local x1, y1, x2, y2 = a.x or a[1], a.y or a[2], b.x or b[1], b.y or b[2]
    if x1 >= x2 or y1 >= y2 then
        return nil
    end
    return {{x1, y1}, {x2, y2}}
end

collision.supported = function(entity, raw, platform)
    local mask = entity.collision_mask
    if collision.area(entity) == nil or mask == nil or mask.not_colliding_with_itself or mask.colliding_with_tiles_only then
        return false
    end
    for key, _ in pairs(entity) do
        if key ~= "collision_mask" and string.find(key, "collision_mask", 1, true) then
            return false
        end
    end
    for _, flag in pairs(entity.flags or {}) do
        if flag == "placeable-off-grid" then
            return false
        end
    end
    -- Broadening terrain must never grant new platform placement. Native tile rules and surface conditions remain.
    for name, _ in pairs(platform) do
        if collision_mask_util.masks_collide(mask, raw.tile[name].collision_mask) then
            return false
        end
    end
    return true
end

collision.apply = function(entity, profile, aliases)
    if profile == "normal" then
        return
    end
    local mask = table.deepcopy(entity.collision_mask)
    for layer, _ in pairs(aliases) do
        mask.layers[layer] = nil
    end
    -- Terrain exclusions also belong in the primary mask so different profiles cannot be paired by the upgrade planner.
    mask.layers[profiles.blocking_layer(profile)] = true
    entity.collision_mask = mask
    entity.tile_buildability_rules = table.deepcopy(entity.tile_buildability_rules or {})
    table.insert(entity.tile_buildability_rules, {
        area = collision.area(entity),
        required_tiles = {
            layers = {
                [profiles.layer(profile)] = true,
                [profiles.layer("platform")] = true,
            },
        },
        remove_on_collision = false,
    })
end

return collision
