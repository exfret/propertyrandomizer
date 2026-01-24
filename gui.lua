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
local flow_cost = require("lib/graph/flow-cost")
local gutils = require("new-lib/graph/graph-utils")

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

script.on_event("randomizer-panel", function(event)
    local gui = game.players[event.player_index].gui.screen

    if gui["randomizer-main-panel"] ~= nil then
        --gui["randomizer-main-panel"].destroy()
        gui["randomizer-main-panel"].visible = not gui["randomizer-main-panel"].visible
        return
    end

    local main_frame = gui.add({type = "frame", name = "randomizer-main-panel", caption = "Randomizer Panel"})
    main_frame.force_auto_center()
    local main_tabbed_pane = main_frame.add({type = "tabbed-pane", name = "randomizer-main-tabbed-pane"})

    local home_tab = main_tabbed_pane.add({type = "tab", name = "randomizer-home-tab", caption = "Home"})
    local home_flow = main_tabbed_pane.add({type = "flow", name = "randomizer-home-flow"})
    main_tabbed_pane.add_tab(home_tab, home_flow)
    local home_flow_caption = home_flow.add({type = "label", name = "randomizer-home-flow-caption", caption = "Welcome to the randomizer panel!"})

    local explorer_tab = main_tabbed_pane.add({type = "tab", name = "randomizer-explorer-tab", caption = "Explorer"})
    local explorer_flow = main_tabbed_pane.add({type = "flow", name = "randomizer-explorer-flow", direction = "vertical"})
    main_tabbed_pane.add_tab(explorer_tab, explorer_flow)
    local explorer_intro = explorer_flow.add({type = "label", name = "randomizer-explorer-intro", caption = "Select something to see what's needed to get it."})
    local explorer_flow_main = explorer_flow.add({type = "flow", name = "randomizer-explorer-flow-main", direction = "horizontal"})
    local explorer_flow_choice = explorer_flow_main.add({type = "flow", name = "randomizer-explorer-flow-choice", direction = "horizontal"})
    local explorer_type_choice = explorer_flow_choice.add({type = "list-box", name = "randomizer-explorer-type-choice", selected_index = 1, items = {"Entity", "Fluid", "Item", "Recipe", "Technology", "Tile", "Asteroid Chunk"}})
    update_explorer_choice(event.player_index, explorer_type_choice)
    local explorer_dropdowns_scroll = explorer_flow_main.add({type = "scroll-pane", name = "randomizer-explorer-dropdowns-scroll", vertical_scroll_policy = "dont-show-but-allow-scrolling", horizontal_scroll_policy = "dont-show-but-allow-scrolling"})
    local explorer_dropdowns = explorer_dropdowns_scroll.add({type = "flow", name = "randomizer-explorer-dropdowns", direction = "vertical"})
end)

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
    if string.find(event.element.name, "randomizer%-explorer") then
        local should_update = update_explorer_choice(event.player_index, event.element)
        if should_update ~= false then
            -- Also clear the dropdowns
            explorer_dropdowns = event.element.parent.parent["randomizer-explorer-dropdowns-scroll"]["randomizer-explorer-dropdowns"]
            explorer_dropdowns.clear()
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
    ["entity-rocket-silo"] = "Rocket silo: ",
    ["fluid"] = "",
    ["fluid-craft"] = "Craft: ",
    ["fluid-create"] = "Create: ",
    ["fluid-hold"] = "Hold: ",
    ["item"] = "",
    ["item-craft"] = "Craft: ",
    ["item-deliver"] = "Deliver: ",
    ["launch"] = "Ability to launch sh**",
    ["planet"] = "A planet",
    ["recipe"] = "",
    ["recipe-category"] = "Crafting category: ",
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
    local reachability_button = description.add({type = "button", style = "randomizer_slot_button_red"})
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
                        node_to_amount_modifier[prekey] = node_to_amount_modifier[prekey] / flow_cost.find_amount_in_ing_or_prod(recipe_prot.products, {type = material_info.top_level_class, name = material_info.prot.name})
                    elseif curr_node.type == "recipe" then
                        local recipe_prot = prototypes.recipe[curr_node.name]
                        local material_info = decon_to_prot(gutils.deconstruct(prenode.prot))
                        node_to_amount_modifier[prekey] = node_to_amount_modifier[prekey] * flow_cost.find_amount_in_ing_or_prod(recipe_prot.ingredients, {type = material_info.top_level_class, name = material_info.prot.name})
                    end
                end

                -- Test for whether to propagate more (same op and same canonical)
                -- Don't check op if there is one prereq (AND/OR equivalent then)
                -- Also make sure it's not a source (must be included as leaf then!)
                -- Finally, needs to be the same sort of thing (same node name)
                if prenode.num_pre ~= 0 and (prenode.op == node.op or prenode.num_pre == 1) and graph.type_info[prenode.type].canonical == graph.type_info[node.type].canonical and prenode.name == node.name then
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
        }
        if not is_confusing_node_type[leaf.type] then
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
        explorer_dropdowns = prot_choice.parent.parent["randomizer-explorer-dropdowns-scroll"]["randomizer-explorer-dropdowns"]
        explorer_dropdowns.clear()

        local node = graph.nodes[gutils.key(prot_choice.elem_type, prot_choice.elem_value)]
        local root_flow = explorer_dropdowns.add({type = "flow", name = "randomizer-explorer-dropdowns-root", direction = "horizontal"})
        local amount
        if node.type == "recipe" or node.type == "item" or node.type == "fluid" then
            amount = 1
        end
        local root_checkbox = expand_prereq_dropdown(root_flow, event.player_index, node, {amount = amount})

        -- Do an initial expansion to reveal first prereqs, though we'll need to spoof the event
        root_checkbox.state = true
        expand_node_dropdown({player_index = event.player_index, element = root_checkbox}, node)
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