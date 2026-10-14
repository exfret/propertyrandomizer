local profiles = require("src/randomizations/planetary/biome-profiles")

local biomes = {}

local function sorted_keys(values)
    local result = {}
    for name, _ in pairs(values) do
        table.insert(result, name)
    end
    table.sort(result)
    return result
end

-- Read the finished prototypes so duplicated/rebuilt buildings show the rules they actually received.
biomes.rows = function(entity_prototypes)
    local rows = {}
    for _, name in pairs(sorted_keys(entity_prototypes)) do
        local entity = entity_prototypes[name]
        -- Match the Explorer's filtering of add_old_versions copies.
        local visible = entity.hidden ~= true and string.sub(name, 1, 4) ~= "old-"
        for _, rule in pairs(visible and entity.tile_buildability_rules or {}) do
            for _, profile in pairs(profiles.choices) do
                if ((rule.required_tiles or {}).layers or {})[profiles.layer(profile)] == true then
                    table.insert(rows, {
                        entity = entity,
                        profile = profile,
                    })
                end
            end
        end
    end
    return rows
end

-- Equal localised names identify cosmetic variants without depending on the player's language.
local function caption_key(value)
    if type(value) ~= "table" then
        return type(value) .. ":" .. tostring(value)
    end
    local parts = {}
    for _, child in pairs(value) do
        local key = caption_key(child)
        table.insert(parts, #key .. ":" .. key)
    end
    return table.concat(parts)
end

biomes.tiles = function(profile)
    local report = prototypes.mod_data["propertyrandomizer-biome-placement"]
    local appearances = prototypes.mod_data["propertyrandomizer-biomes"]
    local donors = appearances ~= nil and appearances.data.clone_to_appearance or {}
    local result, seen = {}, {}
    for _, name in pairs(sorted_keys(report.data.memberships)) do
        local tile = prototypes.tile[name]
        if report.data.memberships[name][profile] and tile ~= nil then
            tile = prototypes.tile[(report.data.tile_sources or {})[name] or donors[name]] or tile
            tile = tile.factoriopedia_alternative or tile
            local key = caption_key(tile.localised_name or tile.name)
            if not seen[key] then
                seen[key] = true
                table.insert(result, tile)
            end
        end
    end
    return result
end

local function show_tiles(selector, profile)
    for _, button in pairs(selector.children) do
        button.toggled = button.tags.biome_profile == profile
    end
    local body = selector.parent["randomizer-biome-tile-body"]
    body["randomizer-biome-tile-summary"].caption = {"propertyrandomizer-biome-summary." .. profile}
    local scroll = body["randomizer-biome-tile-list"]
    scroll.clear()
    for _, tile in pairs(biomes.tiles(profile)) do
        local label = scroll.add({type = "label", caption = "[tile=" .. tile.name .. "]", tags = {biome_tile = tile.name}})
        label.style.rich_text_setting = defines.rich_text_setting.highlight
        label.elem_tooltip = {type = "tile", name = tile.name}
    end
    return true
end

biomes.on_click = function(event)
    local tags = event.element.tags
    if tags.biome_profile ~= nil then
        show_tiles(event.element.parent, tags.biome_profile)
        return true
    end
    local prototype
    if tags.biome_tile ~= nil then
        prototype = prototypes.tile[tags.biome_tile]
    elseif tags.biome_entity ~= nil then
        prototype = prototypes.entity[tags.biome_entity]
    else
        return false
    end
    if prototype ~= nil then
        game.players[event.player_index].open_factoriopedia_gui(prototype)
    end
    return true
end

biomes.create = function(parent)
    local flow = parent.add({type = "flow", name = "randomizer-info-biomes-page", direction = "vertical"})
    flow.style.horizontally_stretchable = true
    flow.style.vertically_stretchable = true
    local intro = flow.add({type = "label", caption = {"propertyrandomizer-biomes.intro"}})
    intro.style.single_line = false
    intro.style.maximal_width = 850
    local report = prototypes.mod_data["propertyrandomizer-biome-placement"]
    if report == nil then
        flow.add({type = "label", caption = {"propertyrandomizer-biomes.disabled"}})
        return flow
    end
    local pane = flow.add({type = "tabbed-pane", name = "randomizer-biome-tabs"})
    pane.style.horizontally_stretchable = true
    pane.style.vertically_stretchable = true
    local buildings_tab = pane.add({type = "tab", caption = {"propertyrandomizer-biomes.buildings"}})
    local scroll = pane.add({type = "scroll-pane", vertical_scroll_policy = "auto"})
    scroll.style.horizontally_stretchable = true
    scroll.style.vertically_stretchable = true
    pane.add_tab(buildings_tab, scroll)
    local tiles_tab = pane.add({type = "tab", caption = {"propertyrandomizer-biomes.tiles"}})
    local tiles_flow = pane.add({type = "flow", name = "randomizer-biome-tiles", direction = "horizontal"})
    tiles_flow.style.horizontally_stretchable = true
    tiles_flow.style.vertically_stretchable = true
    pane.add_tab(tiles_tab, tiles_flow)
    local selector = tiles_flow.add({type = "flow", name = "randomizer-biome-tile-choice", direction = "vertical"})
    selector.style.width = 180
    selector.style.vertically_stretchable = true
    for _, profile in pairs(profiles.choices) do
        local button = selector.add({
            type = "button",
            style = "list_box_item",
            caption = {"propertyrandomizer-biome-profile." .. profile},
            tooltip = {"propertyrandomizer-biome-summary." .. profile},
            tags = {biome_profile = profile},
        })
        button.style.horizontally_stretchable = true
    end
    local body = tiles_flow.add({type = "flow", name = "randomizer-biome-tile-body", direction = "vertical"})
    body.style.horizontally_stretchable = true
    body.style.vertically_stretchable = true
    body.add({type = "label", name = "randomizer-biome-tile-summary"})
    local tile_list = body.add({type = "scroll-pane", name = "randomizer-biome-tile-list", vertical_scroll_policy = "auto"})
    tile_list.style.horizontally_stretchable = true
    tile_list.style.vertically_stretchable = true
    show_tiles(selector, profiles.choices[1])
    pane.selected_tab_index = 1
    local rows = scroll.add({type = "table", column_count = 2})
    for _, heading in pairs({"building", "requirement"}) do
        rows.add({type = "label", caption = {"propertyrandomizer-biomes." .. heading}, style = "bold_label"})
    end
    local entries = biomes.rows(prototypes.entity)
    for _, row in pairs(entries) do
        local label = rows.add({type = "label", caption = "[entity=" .. row.entity.name .. "]", tags = {biome_entity = row.entity.name}})
        label.style.rich_text_setting = defines.rich_text_setting.highlight
        label.elem_tooltip = {type = "entity", name = row.entity.name}
        rows.add({
            type = "label",
            caption = {"propertyrandomizer-biome-profile." .. row.profile},
            tooltip = {"propertyrandomizer-biome-summary." .. row.profile},
        })
    end
    if #entries == 0 then
        flow.add({type = "label", caption = {"propertyrandomizer-biomes.empty"}})
    end
    return flow
end

biomes.resize = function(flow, width)
    flow.style.maximal_width = width
    for _, child in pairs(flow.children) do
        if child.type == "label" then
            child.style.single_line = false
            child.style.maximal_width = width
        end
    end
    local pane = flow["randomizer-biome-tabs"]
    if pane ~= nil then
        local summary = pane["randomizer-biome-tiles"]["randomizer-biome-tile-body"]["randomizer-biome-tile-summary"]
        summary.style.single_line = false
        summary.style.maximal_width = math.max(1, width - 200)
    end
end

return biomes
