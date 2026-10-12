local derandomizer = {}

local common = require("src/runtime/panel/common")

local set_width_height = common.set_width_height

derandomizer.create = function(main_tabbed_pane, player_index)
    local derandomizer_tab = main_tabbed_pane.add({type = "tab", name = "randomizer-derandomizer-tab", caption = {"propertyrandomizer-gui.derandomizer"}})
    local derandomizer_flow = main_tabbed_pane.add({type = "flow", name = "randomizer-derandomizer-flow", direction = "vertical"})
    main_tabbed_pane.add_tab(derandomizer_tab, derandomizer_flow)
    local derandomizer_description = derandomizer_flow.add({type = "label", name = "randomizer-derandomizer-intro", caption = {"propertyrandomizer-gui.derandomizer-intro", tostring(storage.num_derandomizations)}})
    local derandomizer_elem_button = derandomizer_flow.add({type = "choose-elem-button", })
end

return derandomizer