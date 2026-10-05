-- The customizer builds a persistent draft and exports it to the startup override language.
local customization = require("lib/customization")
local localised_text = require("lib/localised-text")
local translations = require("scripts/explorer-localisation")
local tuning = require("lib/random/tuning")
local spec = require("helper-tables/spec")
local model = require("scripts/customizer-model")

local customizer = {}

local function draft_for(player_index)
    storage.customizer_drafts = storage.customizer_drafts or {}
    if storage.customizer_drafts[player_index] == nil then
        storage.customizer_drafts[player_index] = model.new(settings.startup["propertyrandomizer-overrides"].value)
    end
    return storage.customizer_drafts[player_index]
end

local function root_for(element)
    while element ~= nil and element.valid do
        if element.name == "randomizer-customizer-flow" then
            return element
        end
        element = element.parent
    end
end

local function content_for(root)
    return root["randomizer-customizer-scroll"]["randomizer-customizer-content"]
end

local function text(key, ...)
    return {
        "propertyrandomizer-customizer." .. key,
        ...,
    }
end

local function target_caption(target)
    local setting = string.match(target, "^setting/(.+)$")
    if setting ~= nil then
        return {"mod-setting-name." .. setting}
    end
    return {"propertyrandomizer-randomization-name." .. target}
end

local function value_caption(field, value)
    if value == nil then
        return text("builtin")
    elseif field == "enabled" then
        return text(value == true and "on" or "off")
    elseif value == "same" then
        return text(field == "range" and "match-variance" or "match-range")
    end
    return text("value-" .. value)
end

local function flow(parent, name, direction)
    return parent.add({
        type = "flow",
        name = name,
        direction = direction or "vertical",
    })
end

local function label(parent, caption, name)
    return parent.add({
        type = "label",
        name = name,
        caption = caption,
    })
end

local function button(parent, action, caption, tooltip)
    return parent.add({
        type = "button",
        name = "randomizer-customizer-" .. action,
        caption = text(caption or action),
        tooltip = tooltip ~= nil and text(tooltip) or nil,
        tags = {action = action},
    })
end

local function render_output(root, draft)
    local content = content_for(root)
    content["randomizer-customizer-output"].text = model.export(draft)
    local groups, individuals = 0, 0
    for _, fields in pairs(draft.configuration.settings) do
        if next(fields) ~= nil then
            groups = groups + 1
        end
    end
    for _, fields in pairs(draft.configuration.randomizations) do
        if next(fields) ~= nil then
            individuals = individuals + 1
        end
    end
    content["randomizer-customizer-summary"].caption = text("summary", groups, individuals, #draft.configuration.postfixes)
    local status = content["randomizer-customizer-status"]
    -- Upgrade saved import statuses from before the detailed warnings were localized.
    if type(draft.message) == "table" and type(draft.message[2]) == "table"
    and draft.message[2][1] == "propertyrandomizer-customizer.invalid-import"
    and type(draft.message[4]) == "string" then
        draft.message[4] = localised_text.join(customization.parse(draft.import_text or "").localised_warnings, "\n")
    end
    status.caption = draft.message or ""
    status.visible = draft.message ~= nil
    local warnings = content["randomizer-customizer-preserved-warning"]
    warnings.visible = #draft.configuration.unrecognized > 0
    warnings.caption = text("preserved-warning", #draft.configuration.unrecognized)
end

local function render_editor(root, draft)
    local editor = content_for(root)["randomizer-customizer-main"]["randomizer-customizer-editor"]
    editor.clear()
    local editor_width = root.tags.editor_width or 360
    if draft.target == nil then
        label(editor, text("no-results"))
        return
    end
    local title = label(editor, target_caption(draft.target))
    title.style.single_line = false
    title.style.maximal_width = editor_width
    local setting = string.match(draft.target, "^setting/(.+)$")
    local caption
    if setting ~= nil then
        caption = text("group-description", #customization.groups[setting])
    else
        caption = {
            "?",
            {"propertyrandomizer-tooltip." .. draft.target},
            text("individual-description"),
        }
    end
    local description = label(editor, caption)
    description.style.single_line = false
    description.style.maximal_width = editor_width
    local fields = model.fields(draft, draft.target)
    local controls = editor.add({
        type = "table",
        name = "randomizer-customizer-controls",
        column_count = 2,
    })
    local function add_choice(field, values)
        local field_label = label(controls, text("field-" .. field))
        field_label.style.width = 130
        field_label.tooltip = text("help-" .. field)
        local items = {text("inherit")}
        local selected = 1
        for index, value in pairs(values) do
            table.insert(items, value_caption(field, value))
            if fields[field] == value then
                selected = index + 1
            end
        end
        local inherited, source = model.inherited(draft, draft.target, field, settings.startup)
        local inherited_caption = value_caption(field, inherited)
        if inherited == nil and field == "enabled" then
            inherited_caption = text("setting-level")
        end
        local choice = controls.add({
            type = "drop-down",
            name = "randomizer-customizer-field-" .. field,
            items = items,
            selected_index = selected,
            tags = {
                action = "field",
                target = draft.target,
                field = field,
            },
            tooltip = {
                "",
                text("help-" .. field),
                "\n\n",
                text("inherited-value", text("source-" .. source), inherited_caption),
            },
        })
        choice.style.width = math.max(120, editor_width - 160)
    end
    add_choice("enabled", {
        false,
        true,
    })
    if setting ~= nil or spec[draft.target].tuning ~= false then
        for _, field in pairs(tuning.parameter_order) do
            add_choice(field, tuning.parameters[field].values)
        end
    else
        local note = label(editor, text("toggle-only"))
        note.style.single_line = false
        note.style.maximal_width = editor_width
    end
    button(editor, "reset-target", nil, "reset-target-tooltip")
end

local function render_targets(root, draft)
    local selectors = content_for(root)["randomizer-customizer-main"]["randomizer-customizer-selectors"]
    selectors["randomizer-customizer-group-filter"].visible = draft.scope == "randomizations"
    local player = game.players[root.player_index]
    local targets = model.targets(draft, function(id)
        local target = draft.scope == "settings" and "setting/" .. id or id
        return translations.value(player, "customizer:" .. target, target_caption(target), id)
    end)
    local items = {}
    local selected = 0
    for index, target in pairs(targets) do
        table.insert(items, target_caption(target))
        if draft.target == target then
            selected = index
        end
    end
    if selected == 0 and #targets > 0 then
        selected = 1
    end
    draft.target = targets[selected]
    local selector = selectors["randomizer-customizer-targets"]
    selector.items = items
    selector.tags = {
        action = "target",
        targets = targets,
    }
    selector.selected_index = selected
    render_editor(root, draft)
end

customizer.resize = function(root, width, height)
    local content = content_for(root)
    root.style.maximal_width = math.floor(width)
    root["randomizer-customizer-scroll"].style.maximal_width = math.floor(width)
    -- Leave room for the scroll pane's padding and vertical scrollbar.
    width = math.max(240, math.floor(width - 24))
    local left_width = math.max(170, math.floor(width * 0.3))
    local editor_width = math.max(280, math.floor(width - left_width - 24))
    root.tags = {editor_width = editor_width}
    local main = content["randomizer-customizer-main"]
    main["randomizer-customizer-selectors"].style.width = left_width
    for _, child in pairs(main["randomizer-customizer-selectors"].children) do
        child.style.width = left_width
    end
    local editor = main["randomizer-customizer-editor"]
    editor.style.width = editor_width
    for _, child in pairs(editor.children) do
        if child.type == "label" then
            child.style.single_line = false
            child.style.maximal_width = editor_width
        end
    end
    local controls = editor["randomizer-customizer-controls"]
    if controls ~= nil then
        for _, child in pairs(controls.children) do
            if child.type == "drop-down" then
                child.style.width = math.max(120, editor_width - 160)
            end
        end
    end
    for _, child in pairs(content.children) do
        if child.type == "label" then
            child.style.single_line = false
            child.style.maximal_width = math.floor(width)
        end
    end
    root["randomizer-customizer-scroll"].style.maximal_height = math.max(100, math.floor(height - 100))
    content["randomizer-customizer-output"].style.width = math.floor(width)
    content["randomizer-customizer-import-panel"]["randomizer-customizer-import-text"].style.width = math.floor(width)
end

customizer.create = function(pane, player_index)
    if pane["randomizer-customizer-flow"] ~= nil then
        local root = pane["randomizer-customizer-flow"]
        local draft = draft_for(player_index)
        render_targets(root, draft)
        render_output(root, draft)
        return root
    end
    local draft = draft_for(player_index)
    local tab = pane.add({
        type = "tab",
        name = "randomizer-customizer-tab",
        caption = text("tab"),
    })
    local root = flow(pane, "randomizer-customizer-flow")
    root.style.horizontally_stretchable = true
    root.style.vertically_stretchable = true
    pane.add_tab(tab, root)
    local scroll = root.add({
        type = "scroll-pane",
        name = "randomizer-customizer-scroll",
        horizontal_scroll_policy = "auto",
        vertical_scroll_policy = "auto",
    })
    scroll.style.horizontally_stretchable = true
    scroll.style.vertically_stretchable = true
    local content = flow(scroll, "randomizer-customizer-content")
    label(content, text("intro"))
    label(content, text("inheritance"))
    local main = flow(content, "randomizer-customizer-main", "horizontal")
    local selectors = flow(main, "randomizer-customizer-selectors")
    selectors.add({
        type = "drop-down",
        name = "randomizer-customizer-scope",
        items = {
            text("groups"),
            text("individuals"),
        },
        selected_index = draft.scope == "settings" and 1 or 2,
        tags = {action = "scope"},
    })
    local group_names = {}
    for name, _ in pairs(customization.groups) do
        table.insert(group_names, name)
    end
    table.sort(group_names)
    local filter_items = {text("all-groups")}
    local filter_values = {""}
    local filter_index = 1
    for _, name in pairs(group_names) do
        table.insert(filter_items, {"mod-setting-name." .. name})
        table.insert(filter_values, name)
        if draft.group == name then
            filter_index = #filter_values
        end
    end
    table.insert(filter_items, text("ungrouped"))
    table.insert(filter_values, "ungrouped")
    if draft.group == "ungrouped" then
        filter_index = #filter_values
    end
    selectors.add({
        type = "drop-down",
        name = "randomizer-customizer-group-filter",
        items = filter_items,
        selected_index = filter_index,
        tags = {
            action = "group-filter",
            values = filter_values,
        },
    })
    selectors.add({
        type = "textfield",
        name = "randomizer-customizer-search",
        text = draft.query,
        tooltip = text("search"),
        tags = {action = "search"},
    })
    local targets = selectors.add({
        type = "list-box",
        name = "randomizer-customizer-targets",
    })
    targets.style.height = 220
    flow(main, "randomizer-customizer-editor")
    label(content, "", "randomizer-customizer-summary")
    label(content, text("output"))
    local output = content.add({
        type = "text-box",
        name = "randomizer-customizer-output",
    })
    output.read_only = true
    output.word_wrap = true
    output.style.height = 72
    local actions = flow(content, nil, "horizontal")
    button(actions, "select-string")
    button(actions, "toggle-import", "show-import")
    button(actions, "clear", nil, "clear-tooltip")
    label(content, text("copy-help"))
    local import_panel = flow(content, "randomizer-customizer-import-panel")
    import_panel.visible = draft.import_open
    local import_text = import_panel.add({
        type = "text-box",
        name = "randomizer-customizer-import-text",
        text = draft.import_text,
        tags = {action = "import-text"},
    })
    import_text.word_wrap = true
    import_text.style.height = 56
    local import_actions = flow(import_panel, nil, "horizontal")
    button(import_actions, "import")
    button(import_actions, "load-startup")
    label(content, "", "randomizer-customizer-status")
    label(content, "", "randomizer-customizer-preserved-warning")
    render_targets(root, draft)
    render_output(root, draft)
    return root
end

customizer.on_selection_changed = function(event)
    local root = root_for(event.element)
    if root == nil then
        return false
    end
    local draft = draft_for(event.player_index)
    local tags = event.element.tags
    local index = event.element.selected_index
    if tags.action == "scope" then
        draft.scope = index == 1 and "settings" or "randomizations"
        draft.target = nil
        draft.query = ""
        content_for(root)["randomizer-customizer-main"]["randomizer-customizer-selectors"]["randomizer-customizer-search"].text = ""
        render_targets(root, draft)
    elseif tags.action == "group-filter" then
        draft.group = tags.values[index] or ""
        render_targets(root, draft)
    elseif tags.action == "target" then
        draft.target = tags.targets[index]
        render_editor(root, draft)
    elseif tags.action == "field" then
        local value
        if index > 1 then
            if tags.field == "enabled" then
                value = index == 3
            else
                value = tuning.parameters[tags.field].values[index - 1]
            end
        end
        model.set(draft, tags.target, tags.field, value)
        draft.message = nil
        render_editor(root, draft)
        render_output(root, draft)
    end
    return true
end

customizer.on_text_changed = function(event)
    local root = root_for(event.element)
    if root == nil then
        return false
    end
    local draft = draft_for(event.player_index)
    if event.element.tags.action == "search" then
        draft.query = event.element.text
        render_targets(root, draft)
    elseif event.element.tags.action == "import-text" then
        draft.import_text = event.element.text
    end
    return true
end

customizer.on_click = function(event)
    local root = root_for(event.element)
    if root == nil then
        return false
    end
    local draft = draft_for(event.player_index)
    local content = content_for(root)
    local action = event.element.tags.action
    if action == "select-string" then
        content["randomizer-customizer-output"].focus()
        content["randomizer-customizer-output"].select_all()
    elseif action == "toggle-import" then
        draft.import_open = not draft.import_open
        content["randomizer-customizer-import-panel"].visible = draft.import_open
    elseif action == "reset-target" or action == "clear" then
        if action == "reset-target" then
            model.reset(draft, draft.target)
        else
            model.reset(draft)
        end
        draft.message = nil
        render_editor(root, draft)
        render_output(root, draft)
    elseif action == "import" or action == "load-startup" then
        local source_text = action == "load-startup" and settings.startup["propertyrandomizer-overrides"].value or draft.import_text
        local ok, _, warnings = model.import(draft, source_text)
        if ok == true then
            draft.message = text("imported")
            render_targets(root, draft)
        else
            draft.message = {
                "",
                text("invalid-import"),
                "\n",
                localised_text.join(warnings, "\n"),
            }
        end
        render_output(root, draft)
    end
    return true
end

-- Captions translate directly; refresh filtering when asynchronous search text arrives.
customizer.refresh_translations = function(player_index)
    local player = game.players[player_index]
    local panel = player ~= nil and player.gui.screen["randomizer-main-panel"] or nil
    local pane = panel ~= nil and panel["randomizer-main-tabbed-pane"] or nil
    local root = pane ~= nil and pane["randomizer-customizer-flow"] or nil
    if root ~= nil then
        local draft = draft_for(player_index)
        if draft.query ~= "" then
            render_targets(root, draft)
        end
    end
end

return customizer
