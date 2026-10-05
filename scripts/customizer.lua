-- The customizer builds a persistent draft and exports it to the startup override language.
local customization = require("lib/customization")
local localised_text = require("lib/localised-text")
local translations = require("scripts/explorer-localisation")
local tuning = require("lib/random/tuning")
local graph_tuning = require("lib/graph-tuning")
local spec = require("helper-tables/spec")
local model = require("scripts/customizer-model")

local customizer = {}
local prototype_selector_types = {}

-- The Explorer supplies its already-supported native picker types.
customizer.set_selector_types = function(types)
    prototype_selector_types = types
end

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
    if target == "all" then return text("exclude-all") end
    if target == "numerical/all" then return text("exclude-numerical") end
    local individual = string.match(target, "^randomization/(.+)$")
    if individual ~= nil then
        return {
            "?",
            {"propertyrandomizer-randomization-name." .. individual},
            text("identifier", individual),
        }
    end
    local graph = string.match(target, "^graph/(.+)$")
    if graph ~= nil then
        if graph == "all" or graph_tuning.targets[graph] == true then return text("graph-" .. graph) end
        return {
            "?",
            text("graph-" .. graph),
            {"mod-setting-name.propertyrandomizer-unified-" .. graph},
            text("identifier", graph),
        }
    end
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
    elseif field == "amount" or field == "keep_category" then
        return text("percentage", value)
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
    local graphs, exclusions = 0, 0
    for _, fields in pairs(draft.configuration.graph or {}) do
        if next(fields) ~= nil then graphs = graphs + 1 end
    end
    for _, selectors in pairs(draft.configuration.exclusions or {}) do
        for _, _ in pairs(selectors) do exclusions = exclusions + 1 end
    end
    for _, selectors in pairs(draft.configuration.prototype_exclusions or {}) do
        for _, _ in pairs(selectors) do exclusions = exclusions + 1 end
    end
    content["randomizer-customizer-summary"].caption = {
        "",
        text("summary", groups, individuals, #draft.configuration.postfixes),
        "\n",
        text("graph-summary", graphs, exclusions),
    }
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

local function refresh_exclusion_choices(editor, draft)
    if editor["randomizer-customizer-prototype-choice"] ~= nil then
        local list = editor["randomizer-customizer-exclusion-choices"]
        list.items = {}
        list.tags = {
            action = "exclusion-choice",
            values = {},
        }
        list.selected_index = 0
        editor["randomizer-customizer-exclusion-matches"].caption = text("exclusion-matches", 0)
        return
    end
    local player = game.players[editor.player_index]
    local metadata = prototypes ~= nil and prototypes.mod_data ~= nil and prototypes.mod_data["propertyrandomizer-customizer-catalog"] or nil
    local catalog = metadata ~= nil and metadata.data.entries or {}
    local kind = draft.exclusion_kind or "prototype"
    local query = string.lower(draft.exclusion_query or "")
    local choices = {}
    local seen = {}
    for _, entry in pairs(catalog) do
        local name = kind == "prototype" and entry.name or kind == "type" and entry.kind or entry[kind]
        if name ~= nil and (kind ~= "prototype" or draft.exclusion_class == nil or entry.class == draft.exclusion_class) then
            local selector = kind == "prototype" and "prototype/" .. entry.kind .. "/" .. name or kind .. "/" .. name
            local caption = kind == "prototype" and (entry.caption or {
                "?",
                {entry.class .. "-name." .. name},
                text("identifier", name),
            }) or text("identifier", name)
            local translated = query ~= "" and translations.value(player, "customizer-exclusion:" .. selector, caption, name) or name
            if seen[selector] == nil and (string.find(string.lower(selector), query, 1, true) ~= nil or string.find(string.lower(translated), query, 1, true) ~= nil) then
                seen[selector] = true
                local display_caption = caption
                if kind == "prototype" then
                    display_caption = text("prototype-choice", caption, entry.kind)
                end
                table.insert(choices, {
                    selector = selector,
                    caption = display_caption,
                })
            end
        end
    end
    table.sort(choices, function(a, b) return a.selector < b.selector end)
    local values, captions = {}, {}
    for index, choice in pairs(choices) do
        if index <= 200 then
            table.insert(values, choice.selector)
            table.insert(captions, choice.caption)
        end
    end
    local list = editor["randomizer-customizer-exclusion-choices"]
    local old_selector = list.tags.values ~= nil and list.tags.values[list.selected_index] or nil
    list.items = captions
    list.tags = {
        action = "exclusion-choice",
        values = values,
    }
    list.selected_index = #values > 0 and 1 or 0
    for index, selector in pairs(values) do
        if selector == old_selector then list.selected_index = index end
    end
    editor["randomizer-customizer-exclusion-matches"].caption = text("exclusion-matches", #choices)
end

local function render_exclusions(editor, draft, width)
    local heading = label(editor, text("exclusions"))
    heading.tooltip = text("exclusions-help")
    local kinds = {
        "prototype",
        "type",
        "group",
        "subgroup",
    }
    local items = {}
    local selected = 1
    for index, kind in pairs(kinds) do
        table.insert(items, text("exclude-" .. kind))
        if draft.exclusion_kind == kind then selected = index end
    end
    editor.add({
        type = "drop-down",
        name = "randomizer-customizer-exclusion-kind",
        items = items,
        selected_index = selected,
        tags = {
            action = "exclusion-kind",
            values = kinds,
        },
    })
    local metadata = prototypes ~= nil and prototypes.mod_data ~= nil and prototypes.mod_data["propertyrandomizer-customizer-catalog"] or nil
    local catalog = metadata ~= nil and metadata.data.entries or {}
    local classes, captions, seen = {}, {}, {}
    for _, class in pairs(prototype_selector_types) do
        seen[class] = true
        table.insert(classes, class)
    end
    local extra = {}
    for _, entry in pairs(catalog) do
        if seen[entry.class] == nil then
            seen[entry.class] = true
            table.insert(extra, entry.class)
        end
    end
    table.sort(extra)
    for _, class in pairs(extra) do table.insert(classes, class) end
    local class_index = 1
    for index, class in pairs(classes) do
        table.insert(captions, {
            "?",
            {"propertyrandomizer-gui." .. class},
            text("identifier", class),
        })
        if draft.exclusion_class == class then class_index = index end
    end
    draft.exclusion_class = classes[class_index]
    local class_choice = editor.add({
        type = "drop-down",
        name = "randomizer-customizer-exclusion-class",
        items = captions,
        selected_index = #classes > 0 and class_index or 0,
        visible = (draft.exclusion_kind or "prototype") == "prototype",
        tags = {
            action = "exclusion-class",
            values = classes,
        },
    })
    class_choice.tooltip = text("exclusion-class")
    local native = false
    for _, class in pairs(prototype_selector_types) do
        if class == draft.exclusion_class then native = true end
    end
    native = native and (draft.exclusion_kind or "prototype") == "prototype"
    if native then
        local lookup = prototypes[string.gsub(draft.exclusion_class, "-", "_")]
        if lookup ~= nil and draft.exclusion_value ~= nil and lookup[draft.exclusion_value] == nil then
            draft.exclusion_value = nil
        end
        local choice = editor.add({
            type = "choose-elem-button",
            name = "randomizer-customizer-prototype-choice",
            elem_type = draft.exclusion_class,
            tags = {action = "exclusion-prototype"},
        })
        choice.elem_value = draft.exclusion_value
    end
    local search = editor.add({
        type = "textfield",
        name = "randomizer-customizer-exclusion-search",
        text = draft.exclusion_query or "",
        tooltip = text("exclusion-search"),
        visible = not native,
        tags = {action = "exclusion-search"},
    })
    search.style.width = math.max(120, width - 24)
    local list = editor.add({
        type = "list-box",
        name = "randomizer-customizer-exclusion-choices",
        items = {},
        visible = not native,
        tags = {
            action = "exclusion-choice",
            values = {},
        },
    })
    list.style.width = math.max(120, width - 24)
    list.style.height = 120
    local note = label(editor, "", "randomizer-customizer-exclusion-matches")
    refresh_exclusion_choices(editor, draft)
    note.style.single_line = false
    note.style.maximal_width = width
    note.visible = not native
    button(editor, "exclude-selected")
    local selected_exclusions = {}
    for selector, _ in pairs(model.exclusions(draft, draft.target)) do
        table.insert(selected_exclusions, selector)
    end
    table.sort(selected_exclusions)
    for _, selector in pairs(selected_exclusions) do
        local row = flow(editor, nil, "horizontal")
        local caption = label(row, text("identifier", selector))
        caption.style.single_line = false
        caption.style.maximal_width = math.max(100, width - 100)
        row.add({
            type = "button",
            caption = text("remove-exclusion"),
            tags = {
                action = "remove-exclusion",
                selector = selector,
                scope = draft.target,
            },
        })
    end
    if draft.target ~= "all" then
        local inherited = 0
        for _, _ in pairs((draft.configuration.prototype_exclusions or {}).all or {}) do inherited = inherited + 1 end
        local individual = string.match(draft.target, "^randomization/(.+)$")
        local category = individual ~= nil and spec[individual].category or nil
        if category == "numerical" then
            for _, _ in pairs((draft.configuration.prototype_exclusions or {})["numerical/all"] or {}) do inherited = inherited + 1 end
        end
        if category == "graph" or draft.target ~= "graph/all" and string.sub(draft.target, 1, 6) == "graph/" then
            for _, _ in pairs((draft.configuration.exclusions or {}).all or {}) do inherited = inherited + 1 end
        end
        if inherited > 0 then label(editor, text("inherited-exclusions", inherited)) end
    end
    button(editor, "clear-scope-exclusions")
end

local function render_editor(root, draft)
    local editor = content_for(root)["randomizer-customizer-main"]["randomizer-customizer-editor"]
    editor.clear()
    local editor_width = root.tags.editor_width or 360
    if draft.target == nil then
        label(editor, text("no-results"))
        return
    end
    if draft.scope == "exclusions" then
        label(editor, target_caption(draft.target))
        local description = label(editor, text("exclusions-description"))
        description.style.single_line = false
        description.style.maximal_width = editor_width
        render_exclusions(editor, draft, editor_width)
        return
    end
    local title = label(editor, target_caption(draft.target))
    title.style.single_line = false
    title.style.maximal_width = editor_width
    local setting = string.match(draft.target, "^setting/(.+)$")
    local caption
    local graph = string.match(draft.target, "^graph/(.+)$")
    if graph ~= nil then
        caption = text("graph-description")
    elseif setting ~= nil then
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
        field_label.style.single_line = false
        field_label.tooltip = text("help-" .. field)
        local items = {text("inherit")}
        local selected = 1
        local choices = {}
        for _, value in pairs(values) do table.insert(choices, value) end
        if fields[field] ~= nil then
            local found = false
            for _, value in pairs(choices) do if value == fields[field] then found = true end end
            if not found then table.insert(choices, fields[field]) end
        end
        for index, value in pairs(choices) do
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
                values = choices,
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
    if graph ~= nil then
        for _, field in pairs(graph_tuning.parameter_order) do
            if graph_tuning.supports(graph, field) then
                add_choice(field, graph_tuning.parameters[field].values)
            end
        end
        label(editor, text("exclusions-separate"))
    else
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
    end
    button(editor, "reset-target", nil, "reset-target-tooltip")
end

local function render_targets(root, draft)
    local inheritance = content_for(root)["randomizer-customizer-inheritance"]
    if inheritance ~= nil then
        inheritance.caption = text(draft.scope == "exclusions" and "exclusion-inheritance" or "inheritance")
    end
    local selectors = content_for(root)["randomizer-customizer-main"]["randomizer-customizer-selectors"]
    selectors["randomizer-customizer-group-filter"].visible = draft.scope == "randomizations"
    local player = game.players[root.player_index]
    local targets = model.targets(draft, function(id)
        local target = draft.scope == "settings" and "setting/" .. id or draft.scope == "graph" and "graph/" .. id or id
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
    label(content, text("inheritance"), "randomizer-customizer-inheritance")
    local main = flow(content, "randomizer-customizer-main", "horizontal")
    local selectors = flow(main, "randomizer-customizer-selectors")
    selectors.add({
        type = "drop-down",
        name = "randomizer-customizer-scope",
        items = {
            text("groups"),
            text("individuals"),
            text("graphs"),
            text("prototype-exclusions"),
        },
        selected_index = draft.scope == "settings" and 1 or draft.scope == "graph" and 3 or draft.scope == "exclusions" and 4 or 2,
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
        draft.scope = index == 1 and "settings" or index == 3 and "graph" or index == 4 and "exclusions" or "randomizations"
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
    elseif tags.action == "exclusion-kind" then
        draft.exclusion_kind = tags.values[index]
        render_editor(root, draft)
    elseif tags.action == "exclusion-class" then
        draft.exclusion_class = tags.values[index]
        draft.exclusion_value = nil
        render_editor(root, draft)
    elseif tags.action == "field" then
        local value
        if index > 1 then
            if tags.field == "enabled" then
                value = index == 3
            else
                value = (tags.values or tuning.parameters[tags.field].values)[index - 1]
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
    elseif event.element.tags.action == "exclusion-search" then
        draft.exclusion_query = event.element.text
        refresh_exclusion_choices(event.element.parent, draft)
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
    if action == "exclude-selected" then
        local editor = content["randomizer-customizer-main"]["randomizer-customizer-editor"]
        local choices = editor["randomizer-customizer-exclusion-choices"]
        local selector = choices.tags.values[choices.selected_index]
        local prototype_choice = editor["randomizer-customizer-prototype-choice"]
        if prototype_choice ~= nil then
            selector = prototype_choice.elem_value ~= nil and "prototype/" .. prototype_choice.elem_type .. "/" .. prototype_choice.elem_value or nil
            draft.exclusion_value = prototype_choice.elem_value
        end
        if selector ~= nil then model.exclude(draft, draft.target, selector, true) end
        render_editor(root, draft)
        render_output(root, draft)
    elseif action == "remove-exclusion" then
        model.exclude(draft, event.element.tags.scope or draft.target, event.element.tags.selector, false)
        render_editor(root, draft)
        render_output(root, draft)
    elseif action == "clear-scope-exclusions" then
        model.reset_exclusions(draft, draft.target)
        render_editor(root, draft)
        render_output(root, draft)
    elseif action == "select-string" then
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
customizer.on_elem_changed = function(event)
    local root = root_for(event.element)
    if root == nil then return false end
    if event.element.tags.action == "exclusion-prototype" then
        draft_for(event.player_index).exclusion_value = event.element.elem_value
    end
    return true
end

customizer.refresh_translations = function(player_index)
    local player = game.players[player_index]
    local panel = player ~= nil and player.gui.screen["randomizer-main-panel"] or nil
    local pane = panel ~= nil and panel["randomizer-main-tabbed-pane"] or nil
    local root = pane ~= nil and pane["randomizer-customizer-flow"] or nil
    if root ~= nil then
        local draft = draft_for(player_index)
        if draft.query ~= "" then
            render_targets(root, draft)
        elseif draft.scope == "exclusions" then
            local editor = content_for(root)["randomizer-customizer-main"]["randomizer-customizer-editor"]
            if editor["randomizer-customizer-exclusion-choices"] ~= nil then
                refresh_exclusion_choices(editor, draft)
            end
        end
    end
end

return customizer
