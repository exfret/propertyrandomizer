local rng = require("lib/random/rng")
local reformat = require("lib/reformat")

-- Idea: Look for simple sprite definitions of the same size/other params and just shuffle those
-- Also map colors

randomizations.all_icons = function(id)
    local icon_infos = reformat.all_icon_properties()

    rng.shuffle(rng.key({id = id}), icon_infos.icon_datas)

    for ind, icon_tbl_prop in pairs(icon_infos.icon_tbl_props) do
        icon_tbl_prop.tbl[icon_tbl_prop.property] = icon_infos.icon_datas[ind]
    end
end

-- NEW
-- Note: this is unfinished
randomizations.all_sprites = function(id, key)
    -- These things we don't want to traverse into
    local dont_traverse = {
        ["circuit_connector"] = true,
        ["connection_points"] = true,
        ["connector_frame_sprites"] = true,
        ["heat_pipe_covers"] = true,
        ["pipe_covers"] = true,
        ["structure_patch"] = true,
        ["variations"] = true
    }

    -- Remove shadows, reflections, etc.
    -- Who needed them anyways

    local function normal_version(property)
        if string.sub(property, 1, 6) == "shadow" then
            return true
        end
        if string.sub(property, 1, 7) == "shadows" then
            return true
        end
        if string.sub(property, -6, -1) == "shadow" then
            return true
        end
        if string.sub(property, -7, -1) == "shadows" then
            return true
        end

        return false
    end

    local function remove_stupid_graphics(tbl)
        for key, val in pairs(tbl) do
            if is_stupid_key(key) and type(val) == "table" then
                tbl[key] = nil
            elseif type(val) == "table" and key ~= "default" and not dont_traverse[key] then
                remove_stupid_graphics(val)
            end
        end
    end

    remove_stupid_graphics(data.raw)

    -- There's not really a good way to do this, so just look at whether the table contains a filename property with a string ending with .png
    local function is_sprite(tbl, key)
        if type(tbl) ~= "table" then
            return false
        end

        if tbl.layers ~= nil and type(tbl.layers) == "table" then
            -- Ignore layers for now
            return "pass"
            --[[
            for _, layer in pairs(tbl.layers) do
                if is_sprite(layer) then
                    return true
                end
            end]]
        end
        -- Some things are a huge pain and unimportant
        if dont_traverse[key] then
            return "pass"
        end
        --[[if tbl.north ~= nil then
            return "pass"
        end]]
        --[[if key == "sheet" then
            return "pass"
        end]]
        if key == "sheets" then
            return "pass"
        end
        if key == "sprites" then
            return "pass"
        end
        if key == "animation" then
            return "pass"
        end
        if key == "animations" then
            return "pass"
        end
        -- Ignore arrays for now
        if tbl[1] ~= nil then
            return "pass"
        end

        -- Don't traverse into gui styles
        if key == "gui-style" then
            return "pass"
        end

        -- Pass over surface stuff
        -- This stuff isn't even sprites
        if key == "surface_render_parameters" then
            return "pass"
        end

        -- Test for 4-way sprite
        if tbl.sheets ~= nil and (tbl.sheets[1].frames == nil or tbl.sheets[1].frames == 4) and is_sprite(tbl.sheets[1]) == "sprite" then
            if tbl.north == nil or is_sprite(tbl.north) then
                return "4-way"
            end
        end
        if tbl.sheet ~= nil and (tbl.sheet.frames == nil or tbl.sheet.frames == 4) and is_sprite(tbl.sheet) == "sprite" then
            if tbl.north == nil or is_sprite(tbl.north) then
                return "4-way"
            end
        end
        if tbl.north ~= nil and tbl.north_east == nil and is_sprite(tbl.north) == "sprite" then
            return "4-way"
        end
        
        -- Now, sheet/sheets etc. should be nil
        if tbl.north ~= nil then
            return "pass"
        end
        if key == "sheet" then
            return "pass"
        end
        if key == "sheets" then
            return "pass"
        end

        if tbl.filename == nil then
            return false
        end

        if string.sub(tbl.filename, -4, -1) ~= ".png" then
            return false
        end

        -- Test that it's not being used as an icon
        if tbl.flags ~= nil then
            for _, flag in pairs(tbl.flags) do
                if flag == "icon" or flag == "gui-icon" then
                    return false
                end
            end
        end

        -- Check that it's a bona fide sprite and not a spicy sprite (i.e.- animation)
        -- There's not a good way to do this, so just check that it doesn't have spicy properties
        if tbl.frame_count ~= nil then
            return false
        end
        if tbl.line_length ~= nil then
            return false
        end
        if tbl.width_in_frames ~= nil then
            return false
        end
        if tbl.type ~= nil then
            return false
        end
        if tbl.icon_size ~= nil then
            return false
        end
        if tbl.mipmap_count ~= nil then
            return false
        end
        if tbl.frames ~= nil then
            return false
        end
        if tbl.direction_count ~= nil then
            return false
        end
        if tbl.render_layer ~= nil then
            return false
        end
        if tbl.variation_count ~= nil then
            return false
        end

        if tbl.icon_size ~= nil then
            return false
        end
        if tbl.x ~= nil or tbl.y ~= nil then
            return false
        end
        if tbl.dice_x ~= nil or tbl.dice_y ~= nil then
            return false
        end
        
        -- Check that it has size or width/height just to make sure
        if tbl.size == nil and (tbl.width == nil or tbl.height == nil) then
            return false
        end

        return "sprite"
    end

    local function gather_sprites(tbl)
        local sprite_groups = {
            ["sprite"] = {},
            ["4-way"] = {}
        }
        for _, group in pairs(sprite_groups) do
            group.sprite_tbl_props = {}
            group.sprites = {}
        end

        for key, val in pairs(tbl) do
            if type(val) == "table" then
                local sprite_classification = is_sprite(val, key)

                if sprite_classification == "sprite" then
                    table.insert(sprite_groups["sprite"].sprite_tbl_props, {tbl = tbl, property = key})
                    table.insert(sprite_groups["sprite"].sprites, table.deepcopy(val))
                elseif sprite_classification == "4-way" then
                    table.insert(sprite_groups["4-way"].sprite_tbl_props, {tbl = tbl, property = key})
                    table.insert(sprite_groups["4-way"].sprites, table.deepcopy(val))
                elseif sprite_classification == "pass" then
                    -- Don't do anything in this case; pass over it
                else
                    local new_sprite_groups = gather_sprites(val)

                    for group_name, new_sprite_infos in pairs(new_sprite_groups) do
                        for _, new_sprite_tbl_prop in pairs(new_sprite_infos.sprite_tbl_props) do
                            table.insert(sprite_groups[group_name].sprite_tbl_props, new_sprite_tbl_prop)
                        end
                        for _, new_sprite in pairs(new_sprite_infos.sprites) do
                            table.insert(sprite_groups[group_name].sprites, new_sprite)
                        end
                    end
                end
            end
        end

        return sprite_groups
    end

    -- Do a deepcopy, but don't copy over certain properties like flags
    local function merge_sprite(old, new)
        local blacklisted = {
            ["flags"] = true
        }

        for key, _ in pairs(new) do
            if not blacklisted[key] then
                if type(old[key]) == "table" and type(new[key]) == "table" then
                    merge_sprite(old[key], new[key])
                else
                    old[key] = new[key]
                end
            end
        end
        for key, _ in pairs(old) do
            if not blacklisted[key] and new[key] == nil then
                old[key] = nil
            end
        end
    end

    local sprite_groups = gather_sprites(data.raw)

    for _, sprite_infos in pairs(sprite_groups) do
        rng.shuffle(rng.key({id = id}), sprite_infos.sprites)

        for ind, sprite_tbl_prop in pairs(sprite_infos.sprite_tbl_props) do
            merge_sprite(sprite_tbl_prop.tbl[sprite_tbl_prop.property], sprite_infos.sprites[ind])
        end
    end
end

randomizations.colors = function(id)
    local lut_path
    if settings.startup["propertyrandomizer-colors"].value == "little" then
        lut_path = "__propertyrandomizer__/graphics/lut-less-randomized.png"
    elseif settings.startup["propertyrandomizer-colors"].value == "crazy" then
        lut_path = "__propertyrandomizer__/graphics/lut-randomized.png"
    end

    local uconsts = data.raw["utility-constants"].default
    uconsts.daytime_color_lookup = {{1, lut_path}}
    uconsts.zoom_to_world_daytime_color_lookup = {{1, lut_path}}
    uconsts.frozen_color_lookup = lut_path
end

randomizations.map_colors = function(id)
    for entity_class, _ in pairs(defines.prototypes.entity) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                local key = rng.key({id = id, prototype = entity})
                if entity.map_color ~= nil then
                    entity.map_color = {r = rng.value(key), g = rng.value(key), b = rng.value(key)}
                end
                if entity.friendly_map_color ~= nil then
                    entity.friendly_map_color = {r = rng.value(key), g = rng.value(key), b = rng.value(key)}
                end
                if entity.enemy_map_color ~= nil then
                    entity.enemy_map_color = {r = rng.value(key), g = rng.value(key), b = rng.value(key)}
                end
            end
        end
    end
end

-- TODO
randomizations.tile_visuals = function(id)
end