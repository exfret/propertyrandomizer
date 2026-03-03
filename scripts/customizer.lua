-- The customizer tab of the randomizer panel
-- This has a ton of very duplicate code
-- TODO: Fix!

local spec = require("helper-tables/spec")

local customizer = {}

local function set_width_height(element, player, width_frac, height_frac)
    if width_frac ~= nil then
        element.style.minimal_width = player.display_resolution.width * width_frac
        element.style.maximal_width = player.display_resolution.width * width_frac
    end
    if height_frac ~= nil then
        element.style.minimal_height = player.display_resolution.height * height_frac
        element.style.maximal_height = player.display_resolution.height * height_frac
    end
end

customizer.update_configuration_graph = function(config_gui, player_index)
    config_gui.clear()

    storage.graph_configs = storage.graph_configs or {}
    storage.graph_configs[player_index] = storage.graph_configs[player_index] or {}
    -- Get current setting
    local selector = config_gui.parent["randomizer-customizer-randomization-selector-graph"]
    local curr_setting = selector.items[selector.selected_index]
    storage.graph_configs[player_index][curr_setting] = storage.graph_configs[player_index][curr_setting] or {}
    config_saved = storage.graph_configs[player_index][curr_setting]

    -- TODO: Match with preset
    config_saved.curr_toggle_index = config_saved.curr_toggle_index or 1
    config_gui.add({type = "label", name = "randomizer-customizer-randomization-configuration-graph-toggle-caption", caption = "Whether this randomization should be on/off."})
    config_gui.add({type = "label", name = "randomizer-customizer-randomization-configuration-graph-toggle-caption-2", caption = "Note: Graph randomizations increase loading time greatly."})
    config_gui.add({type = "drop-down", name = "randomizer-customizer-randomization-configuration-graph-toggle", items = {"Off", "On"}, selected_index = config_saved.curr_toggle_index})
end

customizer.update_configuration_unified = function(config_gui, player_index)
    config_gui.clear()

    storage.unified_configs = storage.unified_configs or {}
    storage.unified_configs[player_index] = storage.unified_configs[player_index] or {}
    -- Get current setting
    local selector = config_gui.parent["randomizer-customizer-randomization-selector-unified"]
    local curr_setting = selector.items[selector.selected_index]
    storage.unified_configs[player_index][curr_setting] = storage.unified_configs[player_index][curr_setting] or {}
    config_saved = storage.unified_configs[player_index][curr_setting]

    -- TODO: Match with preset
    config_saved.curr_toggle_index = config_saved.curr_toggle_index or 1
    config_gui.add({type = "label", name = "randomizer-customizer-randomization-configuration-unified-toggle-caption", caption = "Whether this randomization should be on/off."})
    config_gui.add({type = "label", name = "randomizer-customizer-randomization-configuration-unified-toggle-caption-2", caption = "Note: Unified randomizations increase loading time greatly."})
    config_gui.add({type = "drop-down", name = "randomizer-customizer-randomization-configuration-unified-toggle", items = {"Off", "On"}, selected_index = config_saved.curr_toggle_index})
end

customizer.update_configuration_numerical = function(config_gui, player_index)
    -- Dropdown with options "inherit", "default", "off", or "on"

    config_gui.clear()

    if storage.numerical_configs == nil then
        storage.numerical_configs = {}
    end
    if storage.numerical_configs[player_index] == nil then
        storage.numerical_configs[player_index] = {}
    end
    -- Need to check what current setting is
    local selector = config_gui.parent["randomizer-customizer-randomization-selector-numerical"]
    local curr_setting = selector.items[selector.selected_index]
    if storage.numerical_configs[player_index][curr_setting] == nil then
        storage.numerical_configs[player_index][curr_setting] = {}
    end
    config_saved = storage.numerical_configs[player_index][curr_setting]

    config_saved.curr_toggle_index = config_saved.curr_toggle_index or 1
    config_gui.add({type = "label", name = "randomizer-customizer-randomization-configuration-numerical-toggle-caption", caption = "Whether this randomization should be on/off."})
    config_gui.add({type = "drop-down", name = "randomizer-customizer-randomization-configuration-numerical-toggle", items = {"Inherit", "Default", "Off", "On"}, selected_index = config_saved.curr_toggle_index})
end

customizer.update_configuration_misc = function(config_gui, player_index)
    -- Dropdown with options "inherit", "default", "off", or "on"

    config_gui.clear()

    if storage.misc_configs == nil then
        storage.misc_configs = {}
    end
    if storage.misc_configs[player_index] == nil then
        storage.misc_configs[player_index] = {}
    end
    -- Need to check what current setting is
    local selector = config_gui.parent["randomizer-customizer-randomization-selector-misc"]
    local curr_setting = selector.items[selector.selected_index]
    if storage.misc_configs[player_index][curr_setting] == nil then
        storage.misc_configs[player_index][curr_setting] = {}
    end
    config_saved = storage.misc_configs[player_index][curr_setting]

    config_saved.curr_toggle_index = config_saved.curr_toggle_index or 1
    config_gui.add({type = "label", name = "randomizer-customizer-randomization-configuration-misc-toggle-caption", caption = "Whether this randomization should be on/off."})
    config_gui.add({type = "drop-down", name = "randomizer-customizer-randomization-configuration-misc-toggle", items = {"Off", "On"}, selected_index = config_saved.curr_toggle_index})
end

customizer.update_configuration_event = function(event)
    if event.element.name == "randomizer-customizer-randomization-configuration-graph-toggle" then
        local selector = event.element.parent.parent["randomizer-customizer-randomization-selector-graph"]
        local curr_setting = selector.items[selector.selected_index]
        storage.graph_configs[event.player_index][curr_setting].curr_toggle_index = event.element.selected_index
    end
    if event.element.name == "randomizer-customizer-randomization-selector-graph" then
        customizer.update_configuration_graph(event.element.parent["randomizer-customizer-randomization-configuration-graph"], event.player_index)
    end
    if event.element.name == "randomizer-customizer-randomization-configuration-unified-toggle" then
        local selector = event.element.parent.parent["randomizer-customizer-randomization-selector-unified"]
        local curr_setting = selector.items[selector.selected_index]
        storage.unified_configs[event.player_index][curr_setting].curr_toggle_index = event.element.selected_index
    end
    if event.element.name == "randomizer-customizer-randomization-selector-unified" then
        customizer.update_configuration_unified(event.element.parent["randomizer-customizer-randomization-configuration-unified"], event.player_index)
    end
    if event.element.name == "randomizer-customizer-randomization-configuration-numerical-toggle" then
        local selector = event.element.parent.parent["randomizer-customizer-randomization-selector-numerical"]
        local curr_setting = selector.items[selector.selected_index]
        storage.numerical_configs[event.player_index][curr_setting].curr_toggle_index = event.element.selected_index
    end
    if event.element.name == "randomizer-customizer-randomization-selector-numerical" then
        customizer.update_configuration_numerical(event.element.parent["randomizer-customizer-randomization-configuration-numerical"], event.player_index)
    end
    if event.element.name == "randomizer-customizer-randomization-configuration-misc-toggle" then
        local selector = event.element.parent.parent["randomizer-customizer-randomization-selector-misc"]
        local curr_setting = selector.items[selector.selected_index]
        storage.misc_configs[event.player_index][curr_setting].curr_toggle_index = event.element.selected_index
    end
    if event.element.name == "randomizer-customizer-randomization-selector-misc" then
        customizer.update_configuration_misc(event.element.parent["randomizer-customizer-randomization-configuration-misc"], event.player_index)
    end
end

customizer.update_selector = function(event)
    if event.element.name == "randomizer-customizer-randomization-category" then
        local new_selector
        local new_config
        local selected_category = event.element.items[event.element.selected_index]
        if selected_category == "Graph" then
            new_selector = "randomizer-customizer-randomization-selector-graph"
            new_config = "randomizer-customizer-randomization-configuration-graph"
            customizer.update_configuration_graph(event.element.parent[new_config], event.player_index)
        elseif selected_category == "Unified" then
            new_selector = "randomizer-customizer-randomization-selector-unified"
            new_config = "randomizer-customizer-randomization-configuration-unified"
            customizer.update_configuration_unified(event.element.parent[new_config], event.player_index)
        elseif selected_category == "Numerical" then
            new_selector = "randomizer-customizer-randomization-selector-numerical"
            new_config = "randomizer-customizer-randomization-configuration-numerical"
            customizer.update_configuration_numerical(event.element.parent[new_config], event.player_index)
        elseif selected_category == "Misc" then
            new_selector = "randomizer-customizer-randomization-selector-misc"
            new_config = "randomizer-customizer-randomization-configuration-misc"
            customizer.update_configuration_misc(event.element.parent[new_config], event.player_index)
        end

        for _, element in pairs(event.element.parent.children) do
            if element.name ~= "randomizer-customizer-randomization-category" and element.name ~= new_config then
                element.visible = false
            end
        end
        event.element.parent[new_selector].visible = true
        if new_config ~= nil then
            event.element.parent[new_config].visible = true
        end
    end
end

customizer.create = function(main_tabbed_pane, player_index)
    local customizer_tab = main_tabbed_pane.add({type = "tab", name = "randomizer-customizer-tab", caption = "Customizer"})
    local customizer_flow = main_tabbed_pane.add({type = "flow", name = "randomizer-customizer-flow", direction = "vertical"})
    main_tabbed_pane.add_tab(customizer_tab, customizer_flow)
    local customizer_description = customizer_flow.add({type = "label", name = "randomizer-customizer-intro", caption = "Create a customization string for more fine-grained control over your randomizer experience."})
    -- TODO: "Generate Settings" button
    local customizer_selector = customizer_flow.add({type = "tabbed-pane", name = "randomizer-customizer-selector"})

    local customizer_randomization_tab = customizer_selector.add({type = "tab", name = "randomizer-customizer-randomization-tab", caption = "Randomizations"})
    local customizer_randomization_flow = customizer_selector.add({type = "flow", name = "randomizer-customizer-randomization-flow", direction = "vertical"})
    customizer_selector.add_tab(customizer_randomization_tab, customizer_randomization_flow)
    local customizer_randomization_description = customizer_randomization_flow.add({type = "label", name = "randomizer-customizer-randomization-description", caption = "Change which randomizations are on and their parameters."})
    local customizer_randomization_main = customizer_randomization_flow.add({type = "flow", name = "randomizer-customizer-randomization-main", direction = "horizontal"})
    
    local customizer_randomization_category = customizer_randomization_main.add({type = "list-box", name = "randomizer-customizer-randomization-category", items = {"Graph", "Unified", "Numerical", "Misc"}, selected_index = 1})
    set_width_height(customizer_randomization_category, game.players[player_index], 1 / 17)

    local randomizations_to_choose_graph = {}
    for key, rand_info in pairs(spec) do
        if rand_info.category == "graph" then
            table.insert(randomizations_to_choose_graph, key)
        end
    end
    local customizer_randomization_selector_graph = customizer_randomization_main.add({type = "list-box", name = "randomizer-customizer-randomization-selector-graph", items = randomizations_to_choose_graph, selected_index = 1})
    local customizer_randomization_configuration_graph = customizer_randomization_main.add({type = "flow", name = "randomizer-customizer-randomization-configuration-graph", direction = "vertical"})
    customizer.update_configuration_graph(customizer_randomization_configuration_graph, player_index)
    set_width_height(customizer_randomization_selector_graph, game.players[player_index], 1 / 8.5)
    set_width_height(customizer_randomization_configuration_graph, game.players[player_index], 0.2)
    -- Graph is the initially selected category, so stays visible

    local randomizations_to_choose_unified = {}
    for key, rand_info in pairs(spec) do
        if rand_info.category == "unified" then
            table.insert(randomizations_to_choose_unified, key)
        end
    end
    local customizer_randomization_selector_unified = customizer_randomization_main.add({type = "list-box", name = "randomizer-customizer-randomization-selector-unified", items = randomizations_to_choose_unified, selected_index = 1})
    local customizer_randomization_configuration_unified = customizer_randomization_main.add({type = "flow", name = "randomizer-customizer-randomization-configuration-unified", direction = "vertical"})
    customizer.update_configuration_unified(customizer_randomization_configuration_unified, player_index)
    customizer_randomization_selector_unified.visible = false
    customizer_randomization_configuration_unified.visible = false
    set_width_height(customizer_randomization_selector_unified, game.players[player_index], 1 / 8.5)
    set_width_height(customizer_randomization_configuration_unified, game.players[player_index], 0.2)
    
    local randomizations_to_choose_numerical = {}
    for key, rand_info in pairs(spec) do
        if rand_info.category == "numerical" then
            table.insert(randomizations_to_choose_numerical, key)
        end
    end
    local customizer_randomization_selector_numerical = customizer_randomization_main.add({type = "list-box", name = "randomizer-customizer-randomization-selector-numerical", items = randomizations_to_choose_numerical, selected_index = 1})
    local customizer_randomization_configuration_numerical = customizer_randomization_main.add({type = "flow", name = "randomizer-customizer-randomization-configuration-numerical", direction = "vertical"})
    customizer.update_configuration_numerical(customizer_randomization_configuration_numerical, player_index)
    customizer_randomization_selector_numerical.visible = false
    customizer_randomization_configuration_numerical.visible = false
    set_width_height(customizer_randomization_selector_numerical, game.players[player_index], 1 / 8.5)
    set_width_height(customizer_randomization_configuration_numerical, game.players[player_index], 0.2)
    
    local randomizations_to_choose_misc = {}
    for key, rand_info in pairs(spec) do
        if rand_info.category == "misc" then
            table.insert(randomizations_to_choose_misc, key)
        end
    end
    local customizer_randomization_selector_misc = customizer_randomization_main.add({type = "list-box", name = "randomizer-customizer-randomization-selector-misc", items = randomizations_to_choose_misc, selected_index = 1})
    local customizer_randomization_configuration_misc = customizer_randomization_main.add({type = "flow", name = "randomizer-customizer-randomization-configuration-misc", direction = "vertical"})
    customizer.update_configuration_misc(customizer_randomization_configuration_misc, player_index)
    customizer_randomization_selector_misc.visible = false
    customizer_randomization_configuration_misc.visible = false
    set_width_height(customizer_randomization_selector_misc, game.players[player_index], 1 / 8.5)
    set_width_height(customizer_randomization_configuration_misc, game.players[player_index], 0.2)
end

return customizer