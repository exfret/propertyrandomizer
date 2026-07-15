local styles = data.raw["gui-style"].default

local resize_scale = 1 / 2.5
local slot_tileset = "__propertyrandomizer__/graphics.slots.png"

for ind, color in pairs({"grey", "red", "orange", "yellow", "green", "cyan", "blue", "purple", "pink"}) do
    -- The following button definition (and graphics) is taken from flib, which is under MIT license
    local btn = {
        type = "button_style",
        parent = "slot_button",
        size = 40,
        default_graphical_set = {
            base = {
                border = 4,
                position = { 0, 80 * ind },
                size = 80,
                filename = slot_tileset
            },
            shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
        },
        hovered_graphical_set = {
            base = {
                border = 4,
                position = { 80, 80 * ind },
                size = 80,
                filename = slot_tileset
            },
            shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
            glow = offset_by_2_rounded_corners_glow(glow),
        },
        clicked_graphical_set = {
            base = {
                border = 4,
                position = { 160, 80 * ind },
                size = 80,
                filename = slot_tileset
            },
            shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
        },
        disabled_graphical_set = { -- identical to default graphical set
            base = {
                border = 4,
                position = { 0, 80 * ind },
                size = 80,
                filename = slot_tileset
            },
            shadow = offset_by_2_rounded_corners_glow(default_dirt_color),
        },
    }
    local function change_filename_and_size(tbl)
        if type(tbl) ~= "table" then return end
        for k, v in pairs(tbl) do
            change_filename_and_size(v)
            if k == "filename" then
                tbl[k] = "__propertyrandomizer__/graphics/saturated-slots-smaller.png"
            end
            if k == "size" then
                tbl[k] = resize_scale * tbl[k]
            end
            if k == "position" then
                tbl[k][1] = resize_scale * tbl[k][1]
                tbl[k][2] = resize_scale * tbl[k][2]
            end
            if k == "corner_size" or k == "left_outer_border_shift" or k == "right_outer_border_shift" or k == "top_outer_border_shift" or k == "bottom_outer_border_shift" then
                tbl[k] = resize_scale * tbl[k]
            end
        end
    end
    change_filename_and_size(btn)
    styles["randomizer_slot_button_" .. color] = btn
end