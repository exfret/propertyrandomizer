-- The customizer tab of the randomizer panel

local spec = require("helper-tables/spec")

local customizer = {}

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

customizer.update_configuration_event = function(event)
    if event.element.name == "randomizer-customizer-randomization-configuration-numerical-toggle" then
        local selector = event.element.parent.parent["randomizer-customizer-randomization-selector-numerical"]
        local curr_setting = selector.items[selector.selected_index]
        storage.numerical_configs[event.player_index][curr_setting].curr_toggle_index = event.element.selected_index
    end
    if event.element.name == "randomizer-customizer-randomization-selector-numerical" then
        customizer.update_configuration_numerical(event.element.parent["randomizer-customizer-randomization-configuration-numerical"], event.player_index)
    end
end

customizer.update_selector = function(event)
    if event.element.name == "randomizer-customizer-randomization-category" then
        local new_selector
        local new_config
        local selected_category = event.element.items[event.element.selected_index]
        if selected_category == "Graph" then
            new_selector = "randomizer-customizer-randomization-selector-graph"
        elseif selected_category == "Numerical" then
            new_selector = "randomizer-customizer-randomization-selector-numerical"
            new_config = "randomizer-customizer-randomization-configuration-numerical"
            customizer.update_configuration_numerical(event.element.parent[new_config], event.player_index)
        elseif selected_category == "Misc" then
            new_selector = "randomizer-customizer-randomization-selector-misc"
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
    
    local customizer_randomization_category = customizer_randomization_main.add({type = "list-box", name = "randomizer-customizer-randomization-category", items = {"Graph", "Numerical", "Misc"}, selected_index = 1})

    local customizer_randomization_selector_graph = customizer_randomization_main.add({type = "list-box", name = "randomizer-customizer-randomization-selector-graph", items = {}})
    local randomizations_to_choose = {}
    for key, _ in pairs(spec) do
        table.insert(randomizations_to_choose, key)
    end
    local customizer_randomization_selector_numerical = customizer_randomization_main.add({type = "list-box", name = "randomizer-customizer-randomization-selector-numerical", items = randomizations_to_choose, selected_index = 1})
    local customizer_randomization_configuration_numerical = customizer_randomization_main.add({type = "flow", name = "randomizer-customizer-randomization-configuration-numerical", direction = "vertical"})
    customizer.update_configuration_numerical(customizer_randomization_configuration_numerical, player_index)
    customizer_randomization_selector_numerical.visible = false
    customizer_randomization_configuration_numerical.visible = false
    local customizer_randomization_selector_misc = customizer_randomization_main.add({type = "list-box", name = "randomizer-customizer-randomization-selector-misc", items = {}})
end

return customizer