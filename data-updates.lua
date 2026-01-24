local styles = data.raw["gui-style"].default

local resize_scale = 1 / 2.5

for _, color in pairs({"grey", "red", "yellow", "green", "pink"}) do
    local btn = table.deepcopy(styles["flib_slot_button_" .. color])
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