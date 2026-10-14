local biomes = require("src/runtime/panel/biomes")

local info = {}
info.layout_version = 3
info.on_click = biomes.on_click

local function overview(home_flow)
    local home_flow_caption = home_flow.add({type = "label", name = "randomizer-home-flow-caption", caption = {"propertyrandomizer-gui.welcome"}})
    local reachability_text
    local reachable = prototypes.mod_data["propertyrandomizer-reachability-data"].data["reachable"]
    local total = prototypes.mod_data["propertyrandomizer-reachability-data"].data["total"]
    if reachable < total then
        reachability_text = {"propertyrandomizer-gui.science-unreachable", tostring(reachable), tostring(total)}
    elseif prototypes.mod_data["propertyrandomizer-reachability-data"].data["check_ok"] == false then
        -- The mechanic context check (skeleton/check.lua) found something a player needs lost, like a recipe no longer reachable
        reachability_text = {"propertyrandomizer-gui.mechanic-check-failed"}
    else
        reachability_text = {"propertyrandomizer-gui.science-reachable", tostring(total)}
    end
    local home_flow_reachability = home_flow.add({type = "label", name = "randomizer-home-flow-reachability", caption = reachability_text})
    -- Limits on planetary changes the game breaks (planetary.broken_limits), each a red line: not a softlock, but a game the tests fail
    for ind, caption in pairs(prototypes.mod_data["propertyrandomizer-reachability-data"].data["broken_limits"] or {}) do
        home_flow.add({type = "label", name = "randomizer-home-flow-broken-limit-" .. ind, caption = caption})
    end
    -- What randomization warned about at startup (randomization_info.warnings, smuggled by data-final-fixes.lua), without the chat-style prefix each one starts with
    for data, _ in pairs(prototypes.item["propertyrandomizer-warnings"].get_entity_type_filters(defines.selection_mode.select)) do
        local _, warnings = serpent.load(data)
        for ind, warning in pairs(warnings or {}) do
            local message = warning
            if type(warning) == "string" then
                message = string.gsub(warning, "^%[img=item%.propertyrandomizer%-gear%] %[color=[^%]]*%]exfret's Randomizer:%[/color%] ", "")
            end
            home_flow.add({type = "label", name = "randomizer-home-flow-startup-warning-" .. ind, caption = {"propertyrandomizer-gui.warning", message}})
        end
        break
    end
    if settings.startup["propertyrandomizer-seed"].value == 0 then
        local home_default_seed_warning_caption = home_flow.add({type = "label", name = "randomizer-home-flow-warning", caption = {"propertyrandomizer-gui.default-seed"}})
        local home_default_seed_warning_caption_2 = home_flow.add({type = "label", name = "randomizer-home-flow-warning-2", caption = {"propertyrandomizer-gui.default-disabled"}})
        local home_default_seed_warning_caption_3 = home_flow.add({type = "label", name = "randomizer-home-flow-warning-3", caption = {"propertyrandomizer-gui.prototype-caching"}})
    end
    local home_flow_tip_sync = home_flow.add({type = "label", name = "randomizer-home-flow-tip-1", caption = {"propertyrandomizer-gui.sync-tip"}})
end

info.resize = function(flow, width)
    if flow == nil then
        return
    end
    flow.style.maximal_width = width
    local content = flow["randomizer-info-content"]
    local body_width = math.max(1, width - 220 - 12)
    content.style.maximal_width = body_width
    local overview_flow = content["randomizer-info-overview"]["randomizer-home-flow"]
    for _, child in pairs(overview_flow.children) do
        if child.type == "label" then
            child.style.single_line = false
            child.style.maximal_width = math.max(1, body_width - 20)
        end
    end
    local biome_page = content["randomizer-info-biomes-page"]
    if biome_page ~= nil then
        biomes.resize(biome_page, body_width)
    end
end

info.on_selection_changed = function(event)
    local selector = event.element
    if selector.name ~= "randomizer-info-page-choice" then
        return false
    end
    if selector.selected_index ~= 2 then
        selector.selected_index = 1
    end
    local flow = selector.parent
    local content = flow["randomizer-info-content"]
    local show_biomes = selector.selected_index == 2
    local biome_page = content["randomizer-info-biomes-page"]
    if show_biomes and biome_page == nil then
        biome_page = biomes.create(content)
    end
    content["randomizer-info-overview"].visible = not show_biomes
    if biome_page ~= nil then
        biome_page.visible = show_biomes
    end
    info.resize(flow, flow.style.maximal_width)
    return true
end

info.create = function(pane)
    local tab = pane.add({type = "tab", name = "randomizer-info-tab", caption = {"propertyrandomizer-gui.info"}})
    local flow = pane.add({type = "flow", name = "randomizer-info-flow", direction = "horizontal", tags = {layout_version = info.layout_version}})
    flow.style.horizontally_stretchable = true
    flow.style.vertically_stretchable = true
    pane.add_tab(tab, flow)
    local selector = flow.add({
        type = "list-box",
        name = "randomizer-info-page-choice",
        selected_index = 1,
        items = {
            {"propertyrandomizer-gui.overview"},
            {"propertyrandomizer-biomes.title"},
        },
    })
    selector.style.width = 220
    selector.style.vertically_stretchable = true
    local content = flow.add({type = "flow", name = "randomizer-info-content", direction = "vertical"})
    content.style.horizontally_stretchable = true
    content.style.vertically_stretchable = true
    local scroll = content.add({
        type = "scroll-pane",
        name = "randomizer-info-overview",
        horizontal_scroll_policy = "never",
        vertical_scroll_policy = "auto",
    })
    scroll.style.horizontally_stretchable = true
    scroll.style.vertically_stretchable = true
    local overview_flow = scroll.add({type = "flow", name = "randomizer-home-flow", direction = "vertical"})
    overview_flow.style.horizontally_stretchable = true
    overview(overview_flow)
    -- Keep the welcome and warnings as the initial view.
    pane.selected_tab_index = #pane.tabs
end

return info
