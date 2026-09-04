-- TODO:
--   * (DONE) Clutter
--      - Deal with long names like entity-buildability or science sets, so custom abbreviations?
--   * Better names
--      - (DONE) First, "Reachability" (button opens contexts below), also red/yellow/green/purple/gray (implement actual reachability checks later)
--      - Second, the quantity, if applicable (try this at this point!)
--      - The action (build) if prototype is implicit (if any), or the prototype itself if it's not been revealed as a parent, and put that in rich text
--      - The op, T/F/OR/AND (explain T vs. F etc. somewhere later)
--   * Close window button and formatting
--      - Make scrollable
--      - Add styles to list selector to make it not collapse (maybe a horizontal scroll bar too)
--      - Buffer between top description and bottom
--      - A potential title on the page (not just tab)
--   * Persistence
--      - Make choices persistent across closing and reopening (maybe it just requires changing visibility rather than full deletion?)
--   * Sorting
--      - Make sure top sort works in control stage
--      - Perform top sort and keep track of reachable as techs are unlocked, updating colors
--      - Put prereqs in order of "usual" unlock/top sort (putting already unlocked first)
--   * Tooltips
--      - Tooltips for node types, op?, helpful info

local locale = require("lib/locale")
local cutils = require("lib/cost/cost-utils")
local gutils = require("lib/graph/graph-utils")
local common = require("scripts/common")
local customizer = require("scripts/customizer")
local derandomizer = require("scripts/derandomizer")

local set_width_height = common.set_width_height

local selected_ind_to_elem_type = {
    "entity",
    "fluid",
    "item",
    "recipe",
    "technology",
    "tile",
    "asteroid-chunk",
    -- There is weirdness with this due to how rooms work, skip for now
    --"space-location"
}
local is_elem_type = {
    ["achievement"] = true,
    ["decorative"] = true,
    ["entity"] = true,
    ["equipment"] = true,
    ["fluid"] = true,
    ["item"] = true,
    ["item-group"] = true,
    ["recipe"] = true,
    ["signal"] = true,
    ["technology"] = true,
    ["tile"] = true,
    ["asteroid-chunk"] = true,
    ["space-location"] = true,
}

local function can_be_derandomized(element)
    if prototypes.recipe["derandomized-" .. element.elem_type .. "--" .. element.elem_value] ~= nil then
        return true
    end
end

local function add_derandomizer_amount_caption(element)
    local color = "white"
    if storage.num_derandomizations == 0 and not script.active_mods["pyalternativeenergy"] then
        color = "red"
    end
    if script.active_mods["pyalternativeenergy"] then
        local explorer_derandomizer_amount_caption = element.add({type = "label", name = "randomizer-explorer-derandomizer-amount", caption = "[color=" .. color .. "]Number of derandomizations used: " .. tostring(-storage.num_derandomizations) .. "[/color]"})
    else
        local explorer_derandomizer_amount_caption = element.add({type = "label", name = "randomizer-explorer-derandomizer-amount", caption = "[color=" .. color .. "]You currently have this many derandomizations left: " .. tostring(storage.num_derandomizations) .. "[/color]"})
        local explorer_derandomizer_left_caption = element.add({type = "label", name = "randomizer-explorer-derandomizer-left", caption = "Number techs until next derandomization: " .. tostring(storage.techs_until_derandomization)})
    end
end

local function reset_derandomizer(element)
    local explorer_derandomizer_prot_caption = element.add({type = "label", name = "randomizer-explorer-derandomizer-prot", caption = "Select a prototype for derandomization."})
    add_derandomizer_amount_caption(element)
end

local function update_explorer_choice(player_index, explorer_type_choice)
    local explorer_flow_choice = explorer_type_choice.parent
    -- Choosing the same thing shouldn't reset things
    if storage.explorer_prot_choice ~= nil then
        if storage.explorer_prot_choice[player_index] == explorer_type_choice.selected_index then
            -- Return false to signal that nothing should change to outer function
            return false
        end
    end

    if explorer_flow_choice["randomizer-explorer-prot-choice"] ~= nil then
        explorer_flow_choice["randomizer-explorer-prot-choice"].destroy()
    end
    explorer_elem_type = selected_ind_to_elem_type[explorer_type_choice.selected_index]
    local explorer_prot_choice = explorer_flow_choice.add({type = "choose-elem-button", name = "randomizer-explorer-prot-choice", elem_type = explorer_elem_type})
    storage.explorer_prot_choice = storage.explorer_prot_choice or {}
    storage.explorer_prot_choice[player_index] = explorer_type_choice.selected_index
    return true
end

local function toggle_randomizer_panel(event)
    local player = game.players[event.player_index]
    local gui = player.gui.screen

    if gui["randomizer-main-panel"] ~= nil then
        --gui["randomizer-main-panel"].destroy()
        gui["randomizer-main-panel"].visible = not gui["randomizer-main-panel"].visible
        if gui["randomizer-main-panel"].visible then
            --player.opened = gui["randomizer-main-panel"]
            gui["randomizer-main-panel"].force_auto_center()
        else
            if player.opened == gui["randomizer-main-panel"] then
                --player.opened = nil
            end
        end
        return
    end

    local main_frame = gui.add({type = "frame", name = "randomizer-main-panel", direction = "vertical"})
    local title_flow = main_frame.add({type = "flow", name = "randomizer-main-title-flow", direction = "horizontal"})
    title_flow.drag_target = main_frame
    local title_label = title_flow.add({type = "label", caption = "Randomizer Panel", style = "frame_title"})
    title_label.drag_target = main_frame
    local drag_space = title_flow.add({type = "empty-widget", style = "draggable_space_header"})
    drag_space.style.horizontally_stretchable = true
    drag_space.style.height = 24
    drag_space.drag_target = main_frame
    title_flow.add({type = "sprite-button", name = "randomizer-main-close", sprite = "utility/close", style = "frame_action_button", tooltip = "Close"})
    --player.opened = main_frame
    set_width_height(main_frame, player, 1 / 2.5, 1 / 2.5)
    main_frame.force_auto_center()
    local main_tabbed_pane = main_frame.add({type = "tabbed-pane", name = "randomizer-main-tabbed-pane"})
    main_tabbed_pane.style.horizontally_stretchable = true
    main_tabbed_pane.style.vertically_stretchable = true

    local home_tab = main_tabbed_pane.add({type = "tab", name = "randomizer-home-tab", caption = "Home"})
    local home_flow = main_tabbed_pane.add({type = "flow", name = "randomizer-home-flow", direction = "vertical"})
    home_flow.style.horizontally_stretchable = true
    home_flow.style.vertically_stretchable = true
    main_tabbed_pane.add_tab(home_tab, home_flow)
    local home_flow_caption = home_flow.add({type = "label", name = "randomizer-home-flow-caption", caption = "Welcome to the randomizer panel!"})
    local reachability_text
    local reachable = prototypes.mod_data["propertyrandomizer-reachability-data"].data["reachable"]
    local total = prototypes.mod_data["propertyrandomizer-reachability-data"].data["total"]
    if reachable < total then
        reachability_text = "[color=red]Potential critical softlock found: Only " .. tostring(reachable) .. "/" .. tostring(total) .. " science packs seem reachable.[/color]"
    else
        reachability_text = "[color=green]No critical softlocks discovered. All " .. tostring(total) .. " science packs seem reachable.[/color]"
    end
    local home_flow_reachability = home_flow.add({type = "label", name = "randomizer-home-flow-reachability", caption = reachability_text})
    if settings.startup["propertyrandomizer-seed"].value == 0 then
        local home_default_seed_warning_caption = home_flow.add({type = "label", name = "randomizer-home-flow-warning", caption = "[color=orange]Warning:[/color] You are on the default seed. If this is unintended, see mod settings for customization."})
        local home_default_seed_warning_caption_2 = home_flow.add({type = "label", name = "randomizer-home-flow-warning-2", caption = "Note that some randomizations like recipes are off by default due to slow load times."})
        local home_default_seed_warning_caption_3 = home_flow.add({type = "label", name = "randomizer-home-flow-warning-3", caption = "Also consider turning on prototype caching for faster load times on future game startups (ctrl + shift + click settings, click \"The Rest\", then search for prototype caching)."})
    end
    local home_flow_tip_sync = home_flow.add({type = "label", name = "randomizer-home-flow-tip-1", caption = "[color=yellow]Tip:[/color] Randomizers don't play well with mod updates. CTRL + Click the sync mods button in the loading screen for a save to sync the exact same version."})

    --local customizer_tab = customizer.create(main_tabbed_pane, event.player_index)
    --local derandomizer_tab = derandomizer.create(main_tabbed_pane, event.player_index)

    local explorer_tab = main_tabbed_pane.add({type = "tab", name = "randomizer-explorer-tab", caption = "Explorer"})
    local explorer_flow = main_tabbed_pane.add({type = "flow", name = "randomizer-explorer-flow", direction = "vertical"})
    explorer_flow.style.horizontally_stretchable = true
    explorer_flow.style.vertically_stretchable = true
    main_tabbed_pane.add_tab(explorer_tab, explorer_flow)
    local explorer_intro = explorer_flow.add({type = "label", name = "randomizer-explorer-intro", caption = "Select something to see what's needed to get it. Use the list to select the general class, and click on the square for the exact choice."})
    local explorer_flow_main = explorer_flow.add({type = "flow", name = "randomizer-explorer-flow-main", direction = "horizontal"})
    explorer_flow_main.style.horizontally_stretchable = true
    explorer_flow_main.style.vertically_stretchable = true
    local explorer_flow_left = explorer_flow_main.add({type = "flow", name = "randomizer-explorer-flow-left", direction = "vertical"})
    explorer_flow_left.style.maximal_width = player.display_resolution.width / 6
    local explorer_flow_choice = explorer_flow_left.add({type = "flow", name = "randomizer-explorer-flow-choice", direction = "horizontal"})
    local explorer_type_choice = explorer_flow_choice.add({type = "list-box", name = "randomizer-explorer-type-choice", selected_index = 1, items = {"Entity", "Fluid", "Item", "Recipe", "Technology", "Tile", "Asteroid Chunk"}})
    update_explorer_choice(event.player_index, explorer_type_choice)
    local explorer_derandomizer = explorer_flow_left.add({type = "flow", name = "randomizer-explorer-derandomizer", direction = "vertical"})
    reset_derandomizer(explorer_derandomizer)
    local explorer_dropdowns_scroll = explorer_flow_main.add({type = "scroll-pane", name = "randomizer-explorer-dropdowns-scroll", vertical_scroll_policy = "dont-show-but-allow-scrolling", horizontal_scroll_policy = "dont-show-but-allow-scrolling"})
    explorer_dropdowns_scroll.style.horizontally_stretchable = true
    explorer_dropdowns_scroll.style.vertically_stretchable = true
    local explorer_dropdowns = explorer_dropdowns_scroll.add({type = "flow", name = "randomizer-explorer-dropdowns", direction = "vertical"})
end

script.on_event("randomizer-panel", function(event)
    toggle_randomizer_panel(event)
end)

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
    customizer.update_selector(event)
    customizer.update_configuration_event(event)

    if string.find(event.element.name, "randomizer%-explorer") then
        local should_update = update_explorer_choice(event.player_index, event.element)
        if should_update ~= false then
            -- Also clear the dropdowns
            explorer_dropdowns = event.element.parent.parent.parent["randomizer-explorer-dropdowns-scroll"]["randomizer-explorer-dropdowns"]
            explorer_dropdowns.clear()
            
            local explorer_derandomizer = event.element.parent.parent["randomizer-explorer-derandomizer"]
            explorer_derandomizer.clear()
            reset_derandomizer(explorer_derandomizer)
        end
    end
end)

local function decon_to_prot(deconstructed)
    local top_level_class
    for top_level_name, class_names in pairs(defines.prototypes) do
        if class_names[deconstructed.type] then
            top_level_class = top_level_name
            break
        end
    end
    -- Control phase uses _'s instead of -'s for some reason
    local control_top_level_name = string.gsub(top_level_class, "-", "_")
    local prot = prototypes[control_top_level_name][deconstructed.name]
    return {prot = prot, control_top_level_name = control_top_level_name, top_level_class = top_level_class}
end

local type_to_localised = {
    ["deliver"] = "Ability to deliver from space",
    ["energy-source-burner"] = "Fuel",
    ["energy-source-electric"] = "Electricity",
    ["energy-source-electric-distribution"] = "Distribution",
    ["energy-source-electric-production"] = "Production",
    ["energy-source-electric-production-lightning"] = "Lightning!",
    ["energy-source-electric-production-lightning-capture"] = "Capture it",
    ["entity"] = "",
    ["entity-build"] = "Build: ",
    ["entity-build-surface-condition"] = "Valid conditions for: ",
    ["entity-build-tile"] = "Tile to place: ",
    ["entity-collision-group"] = "Valid tiles",
    ["entity-kill"] = "Kill: ",
    ["entity-mine"] = "Mine: ",
    ["entity-operate"] = "Operate: ",
    ["entity-rocket-silo"] = "Rocket building: ",
    ["fluid"] = "",
    ["fluid-craft"] = "Craft: ",
    ["fluid-create"] = "Create: ",
    ["fluid-create-temperature"] = "Create: ",
    ["fluid-hold"] = "Hold: ",
    ["fluid-temperature"] = "Fluid: ",
    ["fluid-temperature-range"] = "Fluid: ",
    ["item"] = "",
    ["item-burn"] = "Burn: ",
    ["item-craft"] = "Craft: ",
    ["item-launch"] = "Launch: ",
    ["launch"] = "Ability to launch sh**",
    ["planet"] = "A planet",
    ["recipe"] = "",
    ["recipe-category"] = "Crafting category: ",
    ["rocket-silo"] = "Any rocket silo",
    ["recipe-tech-unlock"] = "Recipe unlock",
    ["recipe-unlock"] = "Recipe unlock",
    ["room"] = "Location: ",
    ["room-create-platform"] = "Platform creation: ",
    ["room-launch"] = "Launch from: ",
    ["science-pack-set-lab"] = "Lab",
    ["science-pack-set-science"] = "Science packs",
    ["space-connection"] = "Space connection: ",
    ["space-connection-enter"] = "Enter connection",
    ["space-location"] = "Orbit: ",
    ["space-location-reachable"] = "Ability to dock at: ",
    ["space-location-spaceship"] = "Spaceship at: ",
    ["space-platform-unlock"] = "Tech unlock to create platforms",
    ["space-surface"] = "Any space platform",
    ["spaceship"] = "Spaceship",
    ["starting-character"] = "Your initial fleshy form with which you can perform actions.",
    ["starting-planet"] = "Starting planet",
    ["technology"] = "",
    ["tile"] = "",
    ["tile-build"] = "Build: ",
    ["tile-build-item-place-as-tile"] = "Build: ",
    ["tile-collision-group"] = "Tile group",
    ["tile-mine"] = "Mine: ",
    ["warmth"] = "Heat",
}
local node_type_to_tooltip = {
    ["entity-build-surface-condition"] = "A surface with valid conditions to build this entity on it.",
    ["entity-collision-group"] = "Tiles to build the entity on that it does not collide with.",
    ["fluid-hold"] = "Ability to hold fluid in some sort of pipe that supports it.",
    ["recipe-category"] = "The ability to craft recipes of this category.",
    ["room"] = "A planet or space platform.",
    ["science-pack-set-lab"] = "A lab that can hold all the science packs.",
    ["science-pack-set-science"] = "The science packs themselves.",
    ["spaceship"] = "A space platform that can travel.",
    ["starting-character"] = "You.",
    ["starting-planet"] = "You started here.",
    ["tile-build-item-place-as-tile"] = "Requires the item and tile to put it on.",
    ["tile-collision-group"] = "Groups tiles having the same collision properties.",
    ["warmth"] = "Access to a warm surface or to heat.",
}

local function get_node_type_caption(node)
    return type_to_localised[node.type] or string.upper(string.sub(node.type, 1, 1)) .. string.sub(node.type, 2, -1) .. ": "
end

local dont_print_name_types = {
    ["energy-source-burner"] = true,
    ["entity-collision-group"] = true,
    ["resistance-group"] = true,
    ["science-pack-set-lab"] = true,
    ["science-pack-set-science"] = true,
    ["space-connection-enter"] = true,
    ["tile-collision-group"] = true,
}

local function get_node_caption(node)
    local graph = storage.graph

    if dont_print_name_types[node.type] then
        return ""
    end

    if node.type == "space-connection" then
        local two_locations = {}
        for pre, _ in pairs(node.pre) do
            local prenode = graph.nodes[graph.edges[pre].start]
            if prenode.type == "space-connection-enter" then
                for pre2, _ in pairs(prenode.pre) do
                    local prenode2 = graph.nodes[graph.edges[pre2].start]
                    if prenode2.type == "space-location-spaceship" then
                        table.insert(two_locations, prenode2)
                    end
                end
            end
        end
        return get_node_caption(two_locations[1]) .. "-" .. get_node_caption(two_locations[2])
    end

    if node.prot == nil then
        return node.name
    end

    local deconstructed = gutils.deconstruct(node.prot)
    local prot_info = decon_to_prot(deconstructed)
    if is_elem_type[prot_info.top_level_class] then
        if node.type == "fluid-temperature" then
            log(deconstructed.name)
            local temp_decon = gutils.deconstruct(node.name)
            return "[" .. prot_info.top_level_class .. "=" .. temp_decon.type .. "] (" .. temp_decon.name .. "°C)"
        end
        return "[" .. prot_info.top_level_class .. "=" .. deconstructed.name .. "]"
    else
        return {"?", locale.find_localised_name(prot_info.prot), prot_info.prot.name}
    end
end

-- gui_elt.parent[gui_elt.name .. "-flow"][gui_elt.name .. "-flow-down"]
local function expand_prereq_dropdown(gui_elt_flow_down, player_index, new_node, extra)
    local extra = extra or {}
    local amount = extra.amount

    local new_name = gui_elt_flow_down.name .. "-" .. gutils.key(new_node)
    local flow_name = new_name .. "-flow"
    local flow_name_down = new_name .. "-flow-down"
    storage.gui_element_to_node = storage.gui_element_to_node or {}
    storage.gui_element_to_node[player_index] = storage.gui_element_to_node[player_index] or {}
    storage.gui_element_to_node[player_index][new_name] = new_node

    local hor_flow = gui_elt_flow_down.add({type = "flow", name = new_name, direction = "horizontal"})
    -- Only add if has prereqs
    local checkbox
    if new_node.num_pre > 0 then
        checkbox = hor_flow.add({type = "checkbox", name = new_name .. "-checkbox", state = false})
    end
    local right_flow = hor_flow.add({type = "flow", name = flow_name, direction = "vertical"})

    -- TODO: Working on this part
    local description = right_flow.add({type = "flow", direction = "horizontal"})
    local style_to_use = "randomizer_slot_button_pink"
    if next(storage.tech_sort_info.node_to_context_inds[gutils.key(new_node)]) ~= nil then
        style_to_use = "randomizer_slot_button_green"
    elseif next(storage.science_pack_sort_info.node_to_context_inds[gutils.key(new_node)]) ~= nil then
        style_to_use = "randomizer_slot_button_yellow"
    elseif next(storage.sort_info.node_to_context_inds[gutils.key(new_node)]) ~= nil then
        style_to_use = "randomizer_slot_button_red"
    end
    local reachability_button = description.add({type = "button", style = style_to_use})
    local description_label_amount
    if amount ~= nil then
        -- Ignore recipe nodes since their amounts might cause confusion
        -- Also don't put numbers to non-item/fluids (like no technology amounts)
        local dont_print = false
        if new_node.type == "recipe" then
            dont_print = true
        end
        if new_node.prot == nil then
            dont_print = true
        else
            local deconstructed = gutils.deconstruct(new_node.prot)
            if deconstructed.type ~= "item" and deconstructed.type ~= "fluid" then
                dont_print = true
            end
        end
        if not dont_print then
            description_label_amount = description.add({type = "label", style = "bold_label", caption = tostring(math.floor(10000 * amount) / 10000) .. "x "})
        end
        storage.gui_element_to_amount = storage.gui_element_to_amount or {}
        storage.gui_element_to_amount[player_index] = storage.gui_element_to_amount[player_index] or {}
        storage.gui_element_to_amount[player_index][new_name] = amount
    end
    local description_label_type = description.add({type = "label", caption = get_node_type_caption(new_node)})
    description_label_type.tooltip = node_type_to_tooltip[new_node.type]
    local description_label_name = description.add({type = "label", name = new_name .. "-randomizer-explorer-description-name", caption = get_node_caption(new_node)})
    description_label_name.style.rich_text_setting = defines.rich_text_setting.highlight
    if new_node.prot ~= nil then
        local deconstructed = gutils.deconstruct(new_node.prot)
        local prot_info = decon_to_prot(deconstructed)
        if is_elem_type[prot_info.top_level_class] then
            description_label_name.elem_tooltip = {type = prot_info.top_level_class, name = deconstructed.name}
        end
    end

    local right_flow_down = right_flow.add({type = "flow", name = flow_name_down, direction = "vertical"})

    return checkbox
end

script.on_event(defines.events.on_gui_click, function(event)
    if string.find(event.element.name, "randomizer%-explorer%-description%-name") ~= nil then
        local hor_flow = event.element.parent.parent.parent
        local prot_node = storage.gui_element_to_node[event.player_index][hor_flow.name]
        local prot_key = prot_node.prot
        if prot_key ~= nil then
            local deconstructed = gutils.deconstruct(prot_key)
            local prot_info = decon_to_prot(deconstructed)
            if is_elem_type[prot_info.top_level_class] then
                local player = game.players[event.player_index]
                if prot_info.top_level_class == "technology" then
                    player.open_technology_gui(player.force.technologies[prot_info.prot.name])
                else
                    player.open_factoriopedia_gui(prot_info.prot)
                end
            end
        end
    end
    if event.element.name == "randomizer-explorer-derandomizer-button" then
        if storage.num_derandomizations > 0 or script.active_mods["pyalternativeenergy"] then
            storage.num_derandomizations = -1 + storage.num_derandomizations
            local prot_choice = event.element.parent.parent["randomizer-explorer-flow-choice"]["randomizer-explorer-prot-choice"]
            game.forces.player.recipes["derandomized-" .. prot_choice.elem_type .. "--" .. prot_choice.elem_value].enabled = true
            storage.already_derandomized[prot_choice.elem_type .. "--" .. prot_choice.elem_value] = true

            local parent = event.element.parent
            parent.clear()
            reset_derandomizer(parent)
        end
        return
    end
    if event.element.name == "randomizer-main-close" then
        local player = game.players[event.player_index]
        if player.opened == event.element.parent.parent then
            --player.opened = nil
        else
            event.element.parent.parent.visible = false
        end
        return
    end
    if event.element.name == "randomizer-main-open" then
        toggle_randomizer_panel(event)
        return
    end
end)

script.on_event(defines.events.on_gui_closed, function(event)
    if event.element ~= nil and event.element.name == "randomizer-main-panel" then
        event.element.visible = false
        local player = game.players[event.player_index]
        if player.opened == event.element then
            --player.opened = nil
        end
    end
end)

local function get_node_leaves(node)
    local graph = storage.graph

    local open = {node}
    local leaves = {}
    local checked = {}
    local node_to_amount_modifier = {[gutils.key(node)] = 1}
    local open_ind = 1
    while open_ind <= #open do
        local curr_node = open[open_ind]
        for pre, _ in pairs(curr_node.pre) do
            local prekey = graph.edges[pre].start
            if not checked[prekey] then
                checked[prekey] = true
                local prenode = graph.nodes[prekey]

                node_to_amount_modifier[prekey] = node_to_amount_modifier[gutils.key(curr_node)]
                if graph.edges[pre].inds ~= nil then
                    if prenode.type == "recipe" then
                        local recipe_prot = prototypes.recipe[prenode.name]
                        local material_info = decon_to_prot(gutils.deconstruct(curr_node.prot))
                        node_to_amount_modifier[prekey] = node_to_amount_modifier[prekey] / cutils.find_amount_in_ing_or_prod(recipe_prot.products, {type = material_info.top_level_class, name = material_info.prot.name})
                    elseif curr_node.type == "recipe" then
                        local recipe_prot = prototypes.recipe[curr_node.name]
                        local material_info = decon_to_prot(gutils.deconstruct(prenode.prot))
                        node_to_amount_modifier[prekey] = node_to_amount_modifier[prekey] * cutils.find_amount_in_ing_or_prod(recipe_prot.ingredients, {type = material_info.top_level_class, name = material_info.prot.name})
                    end
                end

                -- Test for whether to propagate more (same op and same canonical)
                -- Don't check op if there is one prereq (AND/OR equivalent then)
                -- Also make sure it's not a source (must be included as leaf then!)
                -- Finally, needs to be the same sort of thing (same node name)
                if prenode.num_pre ~= 0 and (((prenode.op == node.op or prenode.num_pre == 1) and (graph.type_info[prenode.type].canonical == graph.type_info[node.type].canonical and prenode.name == node.name)) or (node.num_pre == 1 and prenode.type == "fluid-temperature")) then
                    table.insert(open, prenode)
                else
                    table.insert(leaves, prenode)
                end
            end
        end

        open_ind = open_ind + 1
    end

    return {leaves = leaves, node_to_amount_modifier = node_to_amount_modifier}
end

local function expand_node_dropdown(event, node)
    local graph = storage.graph

    local leaf_info = get_node_leaves(node)
    local leaves = leaf_info.leaves
    local node_to_amount_modifier = leaf_info.node_to_amount_modifier

    -- Only include one example of each leaf having the same leaves as another
    -- TODO: Allow this to be disabled as a setting
    local leaf_to_concat = {}
    for _, leaf in pairs(leaves) do
        local leaf_table = {}
        for _, leaf_leaf in pairs(get_node_leaves(leaf).leaves) do
            table.insert(leaf_table, gutils.key(leaf_leaf))
        end
        -- Sort for determinism
        table.sort(leaf_table)
        leaf_to_concat[gutils.key(leaf)] = gutils.concat(leaf_table)
    end
    local already_has_rep = {}
    for _, leaf in pairs(leaves) do
        -- Check if this is a hidden prot and hide it if so (in particular for recycling recipes)
        -- TODO: Allow this to be disabled for a setting
        local is_hidden = false
        if leaf.prot ~= nil then
            local prot = decon_to_prot(gutils.deconstruct(leaf.prot)).prot
            if prot.hidden then
                is_hidden = true
            end
        end

        -- Don't allow certain confusing nodes
        -- TODO: Allow this to be disabled for a setting
        local is_confusing_node_type = {
            ["entity-collision-group"] = true,
            ["item-deliver"] = true,
            ["resistance-group"] = true,
            ["warmth"] = true,
            ["false"] = true,
        }
        if not is_confusing_node_type[leaf.type] and string.find(leaf.name, "derandomized") == nil then
            if not is_hidden then
                if not already_has_rep[leaf_to_concat[gutils.key(leaf)]] then
                    already_has_rep[leaf_to_concat[gutils.key(leaf)]] = true
                    -- Remove the -checkbox
                    local non_checkbox_name = string.sub(event.element.name, 1, -10)

                    -- Calculate amount, if applicable
                    local amount
                    storage.gui_element_to_amount = storage.gui_element_to_amount or {}
                    storage.gui_element_to_amount[event.player_index] = storage.gui_element_to_amount[event.player_index] or {}
                    local old_amount = storage.gui_element_to_amount[event.player_index][non_checkbox_name]
                    if old_amount ~= nil then
                        if leaf.prot == node.prot then
                            amount = old_amount
                        elseif node.prot ~= nil and leaf.prot ~= nil then
                            local decon_node = gutils.deconstruct(node.prot)
                            local decon_leaf = gutils.deconstruct(leaf.prot)
                            if decon_node.type == "recipe" or decon_leaf.type == "recipe" then
                                amount = old_amount * node_to_amount_modifier[gutils.key(leaf)]
                            end
                        end
                    end
                    if amount == nil and leaf.prot ~= nil then
                        local deconstructed = gutils.deconstruct(leaf.prot)
                        if deconstructed.type == "item" or deconstructed.type == "recipe" or deconstructed.type == "fluid" then
                            amount = 1
                        end
                    end

                    expand_prereq_dropdown(event.element.parent[non_checkbox_name .. "-flow"][non_checkbox_name .. "-flow-down"], event.player_index, leaf, {amount = amount})
                end
            end
        end
    end
end

script.on_event(defines.events.on_gui_elem_changed, function(event)
    local graph = storage.graph

    if event.element.name == "randomizer-explorer-prot-choice" then
        local prot_choice = event.element
        explorer_dropdowns = prot_choice.parent.parent.parent["randomizer-explorer-dropdowns-scroll"]["randomizer-explorer-dropdowns"]
        explorer_dropdowns.clear()

        local explorer_derandomizer = prot_choice.parent.parent["randomizer-explorer-derandomizer"]

        if prot_choice.elem_value ~= nil then
            local node_type_to_use = prot_choice.elem_type

            explorer_derandomizer.clear()
            if storage.already_derandomized[prot_choice.elem_type .. "--" .. prot_choice.elem_value] then
                local explorer_derandomizer_prot_caption = explorer_derandomizer.add({type = "label", name = "randomizer-explorer-derandomizer-prot", caption = "[color=red]You already acquired the derandomized version of this.[/color]"})
            elseif can_be_derandomized(prot_choice) then
                if prot_choice.elem_type == "item" and next(storage.tech_sort_info.node_to_context_inds[gutils.key("item", prot_choice.elem_value)]) == nil then
                    explorer_derandomizer.add({type = "label", name = "randomizer-explorer-derandomizer-prot", caption = "[color=red]Items must be accessible before you can derandomize them.[/color]"})
                else
                    local explorer_derandomizer_prot_caption = explorer_derandomizer.add({type = "label", name = "randomizer-explorer-derandomizer-prot", caption = "[color=green]This prototype can be derandomized![/color]"})
                    if prot_choice.elem_type == "entity" then
                        local explorer_derandomizer_prot_caption_desc = explorer_derandomizer.add({type = "label", name = "randomizer-explorer-derandomizer-prot-desc", caption = "Derandomize to reset its stats."})
                    elseif prot_choice.elem_type == "recipe" then
                        local explorer_derandomizer_prot_caption_desc = explorer_derandomizer.add({type = "label", name = "randomizer-explorer-derandomizer-prot-desc", caption = "Derandomize to reset crafting time and restore these recipe categories:"})
                        for _, cat in pairs(prototypes.recipe["derandomized-" .. prot_choice.elem_type .. "--" .. prot_choice.elem_value].categories) do
                            explorer_derandomizer.add({type = "label", name = "randomizer-explorer-derandomizer-prot-desc-" .. cat, caption = "    " .. cat})
                        end
                    elseif prot_choice.elem_type == "item" then
                        local explorer_derandomizer_prot_caption_desc = explorer_derandomizer.add({type = "label", name = "randomizer-explorer-derandomizer-prot-desc", caption = "Derandomize to get access to a handcrafting recipe to make this for free."})
                        local explorer_derandomizer_prot_caption_desc_2 = explorer_derandomizer.add({type = "label", name = "randomizer-explorer-derandomizer-prot-desc-2", caption = "(Not really 'derandomizing' but whatever)."})
                    end
                end
            else
                local explorer_derandomizer_prot_caption = explorer_derandomizer.add({type = "label", name = "randomizer-explorer-derandomizer-prot", caption = "[color=red]This prototype is not derandomizable.[/color]"})
            end
            add_derandomizer_amount_caption(explorer_derandomizer)
            if not storage.already_derandomized[prot_choice.elem_type .. "--" .. prot_choice.elem_value] and can_be_derandomized(prot_choice) and (storage.num_derandomizations > 0 or script.active_mods["pyalternativeenergy"]) then
                local explorer_derandomizer_button = explorer_derandomizer.add({type = "button", name = "randomizer-explorer-derandomizer-button", caption = "Derandomize!"})
            end

            -- Refer to the operate entity node if there are more requirements to operation than just the entity
            if node_type_to_use == "entity" then
                local operate_node = graph.nodes[gutils.key("entity-operate", prot_choice.elem_value)]
                if operate_node ~= nil then
                    local to_ignore = {
                        ["entity"] = true,
                        ["warmth"] = true,
                    }
                    for _, prenode in pairs(gutils.prenodes(graph, operate_node)) do
                        if not to_ignore[prenode.type] then
                            node_type_to_use = "entity-operate"
                        end
                    end
                end
            end
            local node = graph.nodes[gutils.key(node_type_to_use, prot_choice.elem_value)]
            if node ~= nil then
                local root_flow = explorer_dropdowns.add({type = "flow", name = "randomizer-explorer-dropdowns-root", direction = "horizontal"})
                local amount
                if node.type == "recipe" or node.type == "item" or node.type == "fluid" then
                    amount = 1
                end
                local root_checkbox = expand_prereq_dropdown(root_flow, event.player_index, node, {amount = amount})

                -- Return in case root_checkbox is nil due to it being a weird entity like half-diagonal rails
                -- We should fix this bug in a better way in the future
                if root_checkbox == nil then
                    return
                end

                -- Do an initial expansion to reveal first prereqs, though we'll need to spoof the event
                root_checkbox.state = true
                expand_node_dropdown({player_index = event.player_index, element = root_checkbox}, node)
            end
        else
            explorer_derandomizer.clear()
            reset_derandomizer(explorer_derandomizer)
        end
    end
end)

script.on_event(defines.events.on_gui_checked_state_changed, function(event)
    local graph = storage.graph

    if string.find(event.element.name, "randomizer%-explorer%-dropdowns") ~= nil then
        local non_checkbox_name = string.sub(event.element.name, 1, -10)
        if event.element.state == false then
            local gui_elt_flow_down = event.element.parent[non_checkbox_name .. "-flow"][non_checkbox_name .. "-flow-down"]
            gui_elt_flow_down.clear()
        else
            local node = storage.gui_element_to_node[event.player_index][non_checkbox_name]
            expand_node_dropdown(event, node)
        end
    end
end)