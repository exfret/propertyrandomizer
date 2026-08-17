local common = {}

common.set_width_height = function(element, player, width_frac, height_frac)
    if width_frac ~= nil then
        element.style.minimal_width = player.display_resolution.width * width_frac
        element.style.maximal_width = player.display_resolution.width * width_frac
    end
    if height_frac ~= nil then
        element.style.minimal_height = player.display_resolution.height * height_frac
        element.style.maximal_height = player.display_resolution.height * height_frac
    end
end

return common