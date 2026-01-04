local reformat = require("lib/reformat")

-- Need:
--   * General entity resizing function (at least for entities like crane that need resizing)
--   * Graphics transmutation functions (get sprite from animation, turn sprite into animation, etc.)

randomizations.building = function(id)
    -- Try reformatting a rocket silo to look like an assembling machine

    local silo = data.raw["rocket-silo"]["rocket-silo"]
    local assm = data.raw["assembling-machine"]["assembling-machine-1"]

    local bad_properties = {
        --"hole_sprite",
        --"door_back_sprite",
        --"door_front_sprite",
        "base_day_sprite",
        "base_night_sprite",
        "base_front_sprite",
        "base_frozen",
        "base_front_frozen",
        --"door_back_frozen",
        --"door_front_frozen",
        "shadow_sprite",
        "satellite_animation",
        "satellite_shadow_animation",
    }
    for _, property in pairs(bad_properties) do
        silo[property] = nil
    end

    local resize_factor = 1 / 3.5
    local offset_up = 0.6
    local resize_properties = {
        "hole_sprite",
        "door_back_sprite",
        "door_front_sprite",
        "door_back_frozen",
        "door_front_frozen",
        "rocket_glow_overlay_sprite",
        "rocket_shadow_overlay_sprite",
        "red_lights_back_sprites",
        "red_lights_front_sprites",
    }
    for _, property in pairs(resize_properties) do
        reformat.change_image_size(silo[property], resize_factor)
        silo[property].shift = silo[property].shift or {0, 0}
        silo[property].shift[2] = silo[property].shift[2] - offset_up
    end
    reformat.change_box_size(silo.hole_clipping_box, resize_factor)
    silo.hole_clipping_box[1][2] = silo.hole_clipping_box[1][2] - offset_up
    silo.hole_clipping_box[2][2] = silo.hole_clipping_box[2][2] - offset_up
    local vectors_to_change = {
        "door_back_open_offset",
        "door_front_open_offset",
    }
    for _, vector in pairs(vectors_to_change) do
        silo[vector][1] = silo[vector][1] * resize_factor
        silo[vector][2] = silo[vector][2] * resize_factor
        silo[vector][2] = silo[vector][2] - offset_up
    end

    -- Change the rocket itself
    local rocket = data.raw["rocket-silo-rocket"][silo.rocket_entity]
    local rocket_graphic_properties = {
        "rocket_sprite",
        "rocket_shadow_sprite",
        "rocket_glare_overlay_sprite",
        "rocket_smoke_bottom1_animation",
        "rocket_smoke_bottom2_animation",
        "rocket_smoke_top1_animation",
        "rocket_smoke_top2_animation",
        "rocket_smoke_top3_animation",
        "rocket_flame_animation",
        "rocket_flame_left_animation",
        "rocket_flame_right_animation"
    }
    for _, property in pairs(rocket_graphic_properties) do
        if rocket[property] ~= nil then
            reformat.change_image_size(rocket[property], resize_factor)
            rocket[property].shift = rocket[property].shift or {0, 0}
            rocket[property].shift[2] = rocket[property].shift[2] - offset_up
        end
    end
    local rocket_vectors = {
        "rocket_initial_offset",
        "rocket_rise_offset",
        "cargo_attachment_offset",
        "rocket_launch_offset",
    }
    for _, vector in pairs(rocket_vectors) do
        rocket[vector][1] = rocket[vector][1] * resize_factor
        rocket[vector][2] = rocket[vector][2] * resize_factor
        rocket[vector][2] = rocket[vector][2] - offset_up
    end
    -- Hotfix because I'm lazy
    rocket.shadow_slave_entity = nil

    local resize_anim_properties = {
        "arm_02_right_animation",
        "arm_01_back_animation",
        "arm_03_front_animation"
    }
    for _, property in pairs(resize_anim_properties) do
        reformat.change_image_variations_size(silo[property], 1 / 3)
    end

    reformat.change_box_sizes(silo, 1 / 3)

    silo.graphics_set = assm.graphics_set
    silo.rocket_parts_required = 1
end