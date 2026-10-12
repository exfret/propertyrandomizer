local common = {}

-- The player's screen size in GUI units
-- Style sizes are in GUI units, which the game multiplies by the player's display scale, while display_resolution is in pixels
common.screen_size = function(player)
    return {
        width = player.display_resolution.width / player.display_scale,
        height = player.display_resolution.height / player.display_scale,
    }
end

common.set_width_height = function(element, player, width_frac, height_frac)
    local screen_size = common.screen_size(player)
    if width_frac ~= nil then
        element.style.minimal_width = screen_size.width * width_frac
        element.style.maximal_width = screen_size.width * width_frac
    end
    if height_frac ~= nil then
        element.style.minimal_height = screen_size.height * height_frac
        element.style.maximal_height = screen_size.height * height_frac
    end
end

return common