local rng = require("lib/random/rng")

local reformat = {}

-- Reformattings that need to happen at the very beginning of the randomization process
function reformat.initial()
    -- Right now this just populates all the class names to avoid space age errors
    log(serpent.block(defines.prototypes))
    for _, class_names in pairs(defines.prototypes) do
        for class_name, _ in pairs(class_names) do
            if data.raw[class_name] == nil then
                data.raw[class_name] = {}
            end
        end
    end
    -- The code above actually was working but I'll leave this here for now in case it comes in handy later
    -- Since defines doesn't populate space age tables without space age, we actually have to do this ourselves manually
    -- I'll keep what's above just in case something in base game gets its table emptied, though
    --[[local space_age_only_classes = {
        "agricultural-tower",
        "asteroid-collector",
        "asteroid",
        "capture-robot",
        "cargo-bay",
        "lightning-attractor",
        "lightning",
        "segment",
        "segmented-unit",
        "space-platform-hub",
        "thruster",
    }
    for _, class_name in pairs(space_age_only_classes) do
        if data.raw[class_name] == nil then
            data.raw[class_name] = {}
        end
    end]]
end

-- Recursive, so can't be defined with the =function syntax
function reformat.change_image_size(picture, factor)
    if picture.layers ~= nil then
        for _, layer in pairs(picture.layers) do
            reformat.change_image_size(layer, factor)
        end
    else
        if picture.scale == nil then
            picture.scale = 1
        end
  
        picture.scale = picture.scale * factor

        if picture.shift ~= nil then
            picture.shift[1] = picture.shift[1] * factor
            picture.shift[2] = picture.shift[2] * factor
        end
    end
end

function reformat.change_image_variations_size(picture, factor)
    if picture.sheet ~= nil then
        reformat.change_image_size(picture.sheet, factor)
    elseif picture.sheets ~= nil then
        for _, sheet in pairs(picture.sheets) do
            reformat.change_image_size(sheet, factor)
        end
    elseif picture.filename ~= nil or picture.layers ~= nil then
        reformat.change_image_size(picture, factor)
    else
        for _, variation in pairs(picture) do
            reformat.change_image_size(variation, factor)
        end
    end
end

function reformat.change_box_size(box, factor)
    for i = 1, 2 do
        for j = 1, 2 do
            box[i][j] = factor * box[i][j]
        end
    end
end

function reformat.change_box_sizes(entity, factor)
    local box_properties = {
        "collision_box",
        "map_generator_bounding_box",
        "selection_box",
        "sticker_box",
        "hit_visualization_box"
    }

    for _, property in pairs(box_properties) do
        if entity[property] ~= nil then
            reformat.change_box_size(entity[property], factor)
        end
    end
end

function reformat.change_corpse_size(corpse_id, factor)
    local corpse = data.raw.corpse[corpse_id]

    if corpse == nil then
        return
    end

    local graphics_properties = {
        "animation",
        "animation_overlay",
        "decay_animation",
        "splash",
        "ground_patch",
        "ground_patch_decay",
        "underwater_patch"
    }

    for _, property in pairs(graphics_properties) do
        if corpse[property] ~= nil then
            reformat.change_image_variations_size(corpse[property], factor)
        end
    end

    -- Change bounding box sizes
    reformat.change_box_sizes(corpse, factor)
end

function reformat.change_entity_corpse_size(entity, factor)
    -- Change corpse sizes
    if entity.corpse ~= nil then
        local corpse_tbl = {}
        if type(entity.corpse) == "table" then
            corpse_tbl = entity.corpse
        else
            corpse_tbl = {entity.corpse}
        end
        for _, corpse_id in pairs(corpse_tbl) do
            reformat.change_corpse_size(corpse_id, factor)
        end
    end
end

-- TODO: An entity size change function?

--------------------------------------------------------------------------------
-- Spider stuff...
--------------------------------------------------------------------------------

function reformat.change_spider_leg_size(leg, factor)
    local leg_properties_to_change = {
        "knee_height",
        "ankle_height"
    }
    for _, property in pairs(leg_properties_to_change) do
        if leg[property] ~= nil then
            leg[property] = leg[property] * factor
        end
    end

    local graphics = leg.graphics_set
    if graphics ~= nil then
        local rotated_sprite_keys = {
            "joint",
            "joint_shadow",
            "foot",
            "foot_shadow"
        }
        for _, property in pairs(rotated_sprite_keys) do
            if graphics[property] ~= nil then
                reformat.change_image_size(graphics[property], factor)
            end
        end

        local spider_leg_part_keys = {
            "upper_part",
            "lower_part",
            "upper_part_shadow",
            "lower_part_shadow",
            "upper_part_water_reflection",
            "lower_part_water_reflection"
        }
        for _, property in pairs(spider_leg_part_keys) do
            if graphics[property] ~= nil then
                local spider_leg_part_sprite_keys = {
                    "top_end",
                    "middle",
                    "bottom_end"
                }
                for _, property2 in pairs(spider_leg_part_sprite_keys) do
                    if graphics[property][property2] ~= nil then
                        reformat.change_image_size(graphics[property][property2], factor)
                    end
                end

                local spider_leg_part_float_keys = {
                    "middle_offset_from_top",
                    "middle_offset_from_bottom",
                    "top_end_length",
                    "bottom_end_length",
                    "top_end_offset",
                    "bottom_end_offset"
                }
                for _, float_key in pairs(spider_leg_part_float_keys) do
                    if graphics[property][float_key] ~= nil then
                        graphics[property][float_key] = graphics[property][float_key] * factor
                    end
                end
            end
        end
    end
end

function reformat.change_spider_leg_spec_size(leg_spec, factor)
    for key, _ in pairs(leg_spec.mount_position) do
        leg_spec.mount_position[key] = factor * leg_spec.mount_position[key]
    end
    for key, _ in pairs(leg_spec.ground_position) do
        leg_spec.ground_position[key] = factor * leg_spec.ground_position[key]
    end

    -- Change leg prototype
    local leg = data.raw["spider-leg"][leg_spec.leg]
    if not randomization_info.touched[rng.key({prototype = leg})] then
        reformat.change_spider_leg_size(leg, factor)
        randomization_info.touched[rng.key({prototype = leg})] = true
    end
end

function reformat.change_spider_engine_size(engine, factor)
    if engine.legs.leg then
        reformat.change_spider_leg_spec_size(engine.legs, factor)
    else
        for _, leg_spec in pairs(engine.legs) do
            reformat.change_spider_leg_spec_size(leg_spec, factor)
        end
    end
end

function reformat.change_spider_torso_graphics_size(graphics, factor)
    local animation_keys = {
        "base_animation",
        "shadow_base_animation",
        "animation",
        "shadow_animation"
    }

    for _, property in pairs(animation_keys) do
        if graphics[property] ~= nil then
            reformat.change_image_size(graphics[property], factor)
        end
    end
end

function reformat.all_icon_properties()
    -- Might as well put the gathering of icons into here as well
    local icon_tbl_props = {}
    local icon_datas = {}

    -- Consists of tables of lists, with first as icon property, second icon_size property, then finally icons property
    -- First add special icon groups
    local class_to_icon_groups = {
        ["achievement"] = {},
        ["ammo-category"] = {},
        ["asteroid-chunk"] = {},
        ["entity"] = {},
        ["fluid"] = {},
        ["item-group"] = {},
        ["item"] = {
            {"dark_background_icon", "dark_background_icon_size", "dark_background_icons"}
        },
        ["quality"] = {},
        ["recipe"] = {},
        ["shortcut"] = {
            {"small_icon", "small_icon_size", "small_icons"}
        },
        ["space-connection"] = {},
        ["space-location"] = {
            {"starmap-icon", "starmap-icon_size", "starmap-icons"}
        },
        ["technology"] = {},
        ["tile"] = {},
        ["tips-and-tricks"] = {},
        ["virtual-signal"] = {}
    }
    -- Extend any base class icons to all icons
    for class_name, icon_groups in pairs(class_to_icon_groups) do
        if defines.prototypes[class_name] ~= nil then
            for extended_class_name, _ in pairs(defines.prototypes[class_name]) do
                if class_name ~= extended_class_name then
                    if class_to_icon_groups[extended_class_name] == nil then
                        class_to_icon_groups[extended_class_name] = {}
                    end
                    
                    for _, icon_group in pairs(icon_groups) do
                        table.insert(class_to_icon_groups[extended_class_name], icon_group)
                    end
                end
            end
        end
    end
    -- Also add the standard icon/icon_size/icons
    for _, icon_groups in pairs(class_to_icon_groups) do
        table.insert(icon_groups, {"icon", "icon_size", "icons"})
    end
    
    for class_name, icon_groups in pairs(class_to_icon_groups) do
        if data.raw[class_name] ~= nil then
            for _, prototype in pairs(data.raw[class_name]) do
                for _, icon_group in pairs(icon_groups) do
                    if prototype[icon_group[3]] == nil and prototype[icon_group[1]] ~= nil then
                        prototype[icon_group[3]] = {
                            {
                                icon = prototype[icon_group[1]],
                                icon_size = prototype[icon_group[2]]
                            }
                        }
                    end

                    if prototype[icon_group[3]] ~= nil then
                        table.insert(icon_tbl_props, {tbl = prototype, property = icon_group[3]})
                        table.insert(icon_datas, prototype[icon_group[3]])
                    end
                end
            end
        end
    end

    -- BaseModifier also has appropriate icons data, use that too
    for _, tech in pairs(data.raw.technology) do
        if tech.effects ~= nil then
            for _, effect in pairs(tech.effects) do
                if effect.icons == nil and effect.icon ~= nil then
                    effect.icons = {
                        {
                            icon = effect.icon,
                            icon_size = effect.icon_size
                        }
                    }
                end

                if effect.icons ~= nil then
                    table.insert(icon_tbl_props, {tbl = effect, property = "icons"})
                    table.insert(icon_datas, effect.icons)
                end
            end
        end
    end

    return {icon_tbl_props = icon_tbl_props, icon_datas = icon_datas}
end

return reformat