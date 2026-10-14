-- Run from the mod root: lua tests/unit/runtime/customizer/test-customizer.lua
-- These GUI doubles exercise the real panel/event dispatcher without a running game.
local function gui_element(definition, parent)
    local element = {
        type = definition.type,
        name = definition.name or "",
        parent = parent,
        player_index = parent ~= nil and parent.player_index or 1,
        children = {},
        style = {},
        tags = definition.tags or {},
        items = definition.items or {},
        selected_index = definition.selected_index or 0,
        text = definition.text or "",
        elem_type = definition.elem_type,
        elem_value = definition.elem_value,
        caption = definition.caption or "",
        tooltip = definition.tooltip,
        valid = true,
        visible = definition.visible ~= false,
        tabs = {},
    }
    element.add = function(child_definition)
        assert(element.valid, "cannot add to a destroyed element")
        if child_definition.type == "choose-elem-button" then
            assert(child_definition.elem_value == nil, "installed LuaGuiElement.add API sets initial prototype by class or via the elem_value attribute")
        end
        if child_definition.name ~= nil then
            assert(element[child_definition.name] == nil, "duplicate GUI name: " .. child_definition.name)
        end
        local child = gui_element(child_definition, element)
        table.insert(element.children, child)
        if child_definition.name ~= nil then
            element[child_definition.name] = child
        end
        return child
    end
    element.add_tab = function(tab, content)
        assert(tab.parent == element and content.parent == element)
        table.insert(element.tabs, {
            tab = tab,
            content = content,
        })
    end
    element.clear = function()
        while #element.children > 0 do
            element.children[1].destroy()
        end
    end
    element.destroy = function()
        element.clear()
        element.valid = false
        if parent ~= nil then
            parent[element.name] = nil
            for index, child in pairs(parent.children) do
                if child == element then
                    table.remove(parent.children, index)
                    break
                end
            end
            for index = #parent.tabs, 1, -1 do
                if parent.tabs[index].tab == element or parent.tabs[index].content == element then
                    table.remove(parent.tabs, index)
                end
            end
        end
    end
    element.focus = function() element.focused = true end
    element.select_all = function() element.all_selected = true end
    element.force_auto_center = function() end
    return element
end

local function find(parent, name)
    if parent.name == name then
        return parent
    end
    for _, child in pairs(parent.children) do
        local result = find(child, name)
        if result ~= nil then
            return result
        end
    end
end

settings = {startup = {}}
data = {}
data.extend = function(_, definitions)
    for _, definition in pairs(definitions) do
        settings.startup[definition.name] = {value = definition.default_value}
    end
end
dofile("settings.lua")
local original = "OFF:setting/propertyrandomizer-logistic;ON:belt_speed;PARAM:setting/propertyrandomizer-logistic.range=small;PARAM:belt_speed.variance=big;SET:[fixture=example].value=2;RESET:[fixture=example].other"
settings.startup["propertyrandomizer-overrides"].value = original
storage = {
    num_derandomizations = 3,
    techs_until_derandomization = 10,
}
game = {players = {}}
local translation_requests = {}
for index = 1, 3 do
    game.players[index] = {
        index = index,
        locale = "fixture-language",
        request_translation = function(caption)
            table.insert(translation_requests, {player_index = index, caption = caption})
            return #translation_requests
        end,
        gui = {screen = gui_element({type = "screen"})},
        display_resolution = {
            width = 1920,
            height = 1080,
        },
        display_scale = 1,
    }
    game.players[index].gui.screen.player_index = index
end

-- Unrelated explorer dependencies aren't used by these customizer interactions.
for _, module in pairs({
    "src/localisation/locale",
    "src/cost/cost-utils",
    "src/lib/graph/graph-utils",
    "src/lib/sort/context-sort",
    "src/logic/init",
    "src/runtime/explorer/explorer-sorts",
    "src/runtime/explorer/explorer-rows",
    "src/runtime/panel/derandomizer",
}) do
    package.loaded[module] = {}
end
local handlers = {}
package.loaded["src/lib/graph/graph-utils"].key = function(kind, name)
    return kind .. ":" .. name
end
package.loaded["src/lib/sort/context-sort"].ISOLATABILITY = 1
package.loaded["src/lib/sort/context-sort"].AUTOMATABILITY = 2
script = {
    active_mods = {},
    get_event_handler = function(id) return handlers[id] end,
    on_event = function(id, callback) handlers[id] = callback end,
}
defines = {
    events = setmetatable({}, {
        __index = function(_,
        key) return key end,
    }),
    selection_mode = {select = 1},
}
serpent = {load = function() return true, {} end}
prototypes = {
    mod_data = {
        ["propertyrandomizer-reachability-data"] = {
            data = {
                reachable = 0,
                total = 0,
                check_ok = true,
            },
        },
    },
    item = setmetatable({}, {
        __index = function()
            return {get_entity_type_filters = function() return {} end}
        end,
    }),
}
local locale_catalogue = require("tests/unit/localisation/test-locale-catalogue")
local tuning = require("src/lib/random/tuning")
local customization = require("src/config/customization")
local spec = require("src/config/spec")
local model = require("src/runtime/customizer/customizer-model")
local customizer = require("src/runtime/customizer/customizer")
local gui = require("src/runtime/panel/gui")

local function panel(index)
    return game.players[index].gui.screen["randomizer-main-panel"]
end
local function event(index, name, kind)
    local element = find(panel(index), name)
    assert(element ~= nil and element.valid, "missing element: " .. name)
    handlers[kind]({
        player_index = index,
        element = element,
    })
end
local function select(index, name, choice)
    find(panel(index), name).selected_index = choice
    event(index, name, defines.events.on_gui_selection_state_changed)
end
local function write(index, name, value)
    find(panel(index), name).text = value
    event(index, name, defines.events.on_gui_text_changed)
end
local function click(index, name)
    event(index, name, defines.events.on_gui_click)
end
local function exported(index)
    return find(panel(index), "randomizer-customizer-output").text
end
local function target(index, value)
    local selector = find(panel(index), "randomizer-customizer-targets")
    for choice, candidate in pairs(selector.tags.targets) do
        if candidate == value then
            select(index, selector.name, choice)
            return
        end
    end
    error("target wasn't offered: " .. value)
end

handlers["randomizer-panel"]({player_index = 1})
assert(#find(panel(1), "randomizer-main-tabbed-pane").tabs == 3, "Info, Explorer and Customizer tabs must be present")
assert(find(panel(1), "randomizer-customizer-output").read_only == true)
local parsed = customization.parse(exported(1))
assert(#parsed.postfixes == 2 and customization.resolve(parsed, "belt_speed").enabled == true)
local pane = find(panel(1), "randomizer-main-tabbed-pane")
assert(pane.tabs[2].tab.name == "randomizer-explorer-tab")
assert(pane.tabs[1].tab.name == "randomizer-info-tab" and pane.selected_tab_index == 1)
assert(find(panel(1), "randomizer-home-tab") == nil)
assert(find(panel(1), "randomizer-info-biomes-page") == nil, "biome content loads when selected")
select(1, "randomizer-info-page-choice", 2)
assert(find(panel(1), "randomizer-info-biomes-page").visible == true)
assert(find(panel(1), "randomizer-info-overview").visible == false)
local biome_page = find(panel(1), "randomizer-info-biomes-page")
select(1, "randomizer-info-page-choice", 1)
assert(biome_page.visible == false and find(panel(1), "randomizer-info-overview").visible == true)
select(1, "randomizer-info-page-choice", 2)
assert(find(panel(1), "randomizer-info-biomes-page") == biome_page, "page selection reuses content")
handlers["randomizer-panel"]({player_index = 1})
handlers["randomizer-panel"]({player_index = 1})
assert(find(panel(1), "randomizer-info-page-choice").selected_index == 2)
select(1, "randomizer-info-page-choice", 0)
assert(find(panel(1), "randomizer-info-overview").visible == true)
find(panel(1), "randomizer-customizer-targets").items = {"Legacy English caption"}
customizer.create(pane, 1)
locale_catalogue.gui(find(panel(1), "randomizer-customizer-flow"))
assert(#pane.tabs == 3, "creating the tab again must be harmless")

target(1, "setting/propertyrandomizer-logistic")
select(1, "randomizer-customizer-field-variance", 3)
assert(customization.resolve(customization.parse(exported(1)), "inserter_speed").variance == "small")
select(1, "randomizer-customizer-scope", 2)
write(1, "randomizer-customizer-search", "belt speed")
assert(storage.customizer_drafts[1].target == "belt_speed", "search matches readable randomization names")
select(1, "randomizer-customizer-field-variance", 1)
parsed = customization.parse(exported(1))
assert(parsed.randomizations.belt_speed.variance == nil and customization.resolve(parsed, "belt_speed").variance == "small", "Inherit removes only the individual field")
select(1, "randomizer-customizer-field-enabled", 2)
assert(customization.resolve(customization.parse(exported(1)), "belt_speed").enabled == false, "Off must remain an explicit false")
select(1, "randomizer-customizer-field-variance", 6)
assert(customization.resolve(customization.parse(exported(1)), "belt_speed").variance == "very_big")
click(1, "randomizer-customizer-reset-target")
parsed = customization.parse(exported(1))
assert(parsed.randomizations.belt_speed == nil and customization.resolve(parsed, "belt_speed").enabled == false)

local filter = find(panel(1), "randomizer-customizer-group-filter")
for index, name in pairs(filter.tags.values) do
    if name == "propertyrandomizer-production" then
        select(1, filter.name, index)
    end
end
write(1, "randomizer-customizer-search", "")
for _, candidate in pairs(find(panel(1), "randomizer-customizer-targets").tags.targets) do
    assert(customization.setting_name(spec[candidate]) == "propertyrandomizer-production")
end
write(1, "randomizer-customizer-search", "this matches nothing")
assert(storage.customizer_drafts[1].target == nil)
assert(find(panel(1), "randomizer-customizer-controls") == nil)
select(1, "randomizer-customizer-scope", 1)
assert(storage.customizer_drafts[1].query == "" and storage.customizer_drafts[1].target ~= nil)

click(1, "randomizer-customizer-toggle-import")
assert(find(panel(1), "randomizer-customizer-import-panel").visible == true)
local before_import = exported(1)
write(1, "randomizer-customizer-import-text", "PARAM:belt_speed.variance=3")
click(1, "randomizer-customizer-import")
assert(exported(1) == before_import, "invalid imports must retain the entire draft")
assert(find(panel(1), "randomizer-customizer-status").visible == true)
locale_catalogue.gui(find(panel(1), "randomizer-customizer-flow"))
local imported = "ON:setting/propertyrandomizer-logistic;PARAM:belt_speed.variance=very_small;SET:[fixture=example].value=3;RESET:[fixture=example].other"
write(1, "randomizer-customizer-import-text", imported)
click(1, "randomizer-customizer-import")
parsed = customization.parse(exported(1))
assert(#parsed.warnings == 0 and #parsed.postfixes == 2 and parsed.randomizations.belt_speed.variance == "very_small")
click(1, "randomizer-customizer-select-string")
assert(find(panel(1), "randomizer-customizer-output").focused == true and find(panel(1), "randomizer-customizer-output").all_selected == true)
click(1, "randomizer-customizer-clear")
assert(exported(1) == "SET:[fixture=example].value=3;RESET:[fixture=example].other", "clearing numerical overrides must preserve post-processing")
click(1, "randomizer-customizer-load-startup")
assert(customization.resolve(customization.parse(exported(1)), "belt_speed").variance == "big")
assert(settings.startup["propertyrandomizer-overrides"].value == original, "editing must not change the running startup setting")
local before_resize = exported(1)
game.players[1].display_resolution = {
    width = 1280,
    height = 720,
}
game.players[1].display_scale = 1.5
handlers[defines.events.on_player_display_scale_changed]({player_index = 1})
local customizer_root = find(panel(1), "randomizer-customizer-flow")
assert(customizer_root.style.maximal_width > 0 and customizer_root.style.maximal_width < panel(1).style.maximal_width, "customizer must fit within the resized panel")
assert(find(panel(1), "randomizer-customizer-scroll").style.maximal_height > 0, "small displays must keep the tab scrollable")
assert(exported(1) == before_resize, "resizing must preserve the draft")

-- Closing, reopening, destroying and rebuilding the tab all retain the draft.
local saved = exported(1)
handlers["randomizer-panel"]({player_index = 1})
assert(panel(1).visible == false)
handlers["randomizer-panel"]({player_index = 1})
assert(exported(1) == saved)
find(panel(1), "randomizer-customizer-flow").destroy()
find(panel(1), "randomizer-customizer-tab").destroy()
handlers["randomizer-panel"]({player_index = 1})
handlers["randomizer-panel"]({player_index = 1})
assert(#pane.tabs == 3 and exported(1) == saved, "saved older panels get the new tab when reopened")
assert(find(panel(1), "randomizer-customizer-import-text").text == imported)
handlers["randomizer-panel"]({player_index = 2})
click(1, "randomizer-customizer-clear")
assert(exported(2) == saved, "players must have independent drafts")
select(2, "randomizer-customizer-scope", 2)
target(2, "map_colors")
assert(find(panel(2), "randomizer-customizer-field-enabled") ~= nil)
assert(find(panel(2), "randomizer-customizer-field-range") == nil, "choices without numerical tuning must only offer a toggle")
select(2, "randomizer-customizer-field-enabled", 3)
assert(customization.resolve(customization.parse(exported(2)), "map_colors").enabled == true)
target(2, "fluid_box_locations")
assert(find(panel(2), "randomizer-customizer-field-variance") == nil)
settings.startup["propertyrandomizer-overrides"].value = "PARAM:belt_speed.variance=3;SET:[fixture=example].value=4"
handlers["randomizer-panel"]({player_index = 3})
click(3, "randomizer-customizer-clear")
assert(string.find(exported(3), "PARAM:belt_speed.variance=3", 1, true) ~= nil, "existing unrecognized instructions must not be silently lost")
assert(find(panel(3), "randomizer-customizer-preserved-warning").visible == true)

-- Serializing an import twice is stable, and per-field precedence survives the round trip.
local draft = model.new("PARAM:belt_speed.variance=big;OFF:setting/propertyrandomizer-logistic;ON:belt_speed;PARAM:setting/propertyrandomizer-logistic.range=small;PARAM:setting/propertyrandomizer-logistic.variance=small")
local serialized = model.export(draft)
assert(serialized == customization.serialize(customization.parse(serialized)))
local resolved = customization.resolve(customization.parse(serialized), "belt_speed")
assert(resolved.enabled == true and resolved.range == "small" and resolved.variance == "big")
local inherited, source = model.inherited(draft, "belt_speed", "variance", settings.startup)
assert(inherited == "small" and source == "group")
-- Every future target and tuning value must resolve through the English catalogue.
select(2, "randomizer-customizer-scope", 1)
for _, group_target in pairs(find(panel(2), "randomizer-customizer-targets").tags.targets) do
    target(2, group_target)
    locale_catalogue.gui(find(panel(2), "randomizer-customizer-flow"))
end
select(2, "randomizer-customizer-scope", 2)
local all_targets = find(panel(2), "randomizer-customizer-targets").tags.targets
for _, individual in pairs(all_targets) do
    target(2, individual)
    locale_catalogue.gui(find(panel(2), "randomizer-customizer-flow"))
end
-- Saved tabs and old raw import diagnostics migrate without losing the draft.
local old_draft = storage.customizer_drafts[2]
old_draft.import_text = "PARAM:broken"
old_draft.message = {"", {"propertyrandomizer-customizer.invalid-import"}, "\n", "Legacy English diagnostic"}
local before_migration = exported(2)
customizer.create(find(panel(2), "randomizer-main-tabbed-pane"), 2)
assert(exported(2) == before_migration)
locale_catalogue.gui(find(panel(2), "randomizer-customizer-flow"))

-- Choices for every tuning field include all advertised values, inheritance and fallbacks.
target(2, "belt_speed")
for _, field in pairs(tuning.parameter_order) do
    local choice = find(panel(2), "randomizer-customizer-field-" .. field)
    assert(#choice.items == #tuning.parameters[field].values + 1)
    for index = 1, #choice.items do
        select(2, choice.name, index)
        locale_catalogue.gui(find(panel(2), "randomizer-customizer-flow"))
    end
end
-- Reject every parser-error category through the real import event, keeping the draft.
local import_errors = {
    "PARAM:broken",
    "PARAM:belt_speed.range=invalid",
    "PARAM:belt_speed.unknown=inherit",
    "OFF:unknown_randomization",
    "ON:setting/unknown-setting",
    "PARAM:map_colors.range=small",
    "UNKNOWN:belt_speed",
}
for _, invalid in pairs(import_errors) do
    local before = exported(2)
    write(2, "randomizer-customizer-import-text", invalid)
    click(2, "randomizer-customizer-import")
    assert(exported(2) == before)
    locale_catalogue.gui(find(panel(2), "randomizer-customizer-flow"))
end
-- A wide warning list must stay within LocalisedString's parameter/nesting limits.
local many_errors = {}
for index = 1, 100 do many_errors[index] = "PARAM:broken" end
write(2, "randomizer-customizer-import-text", table.concat(many_errors, ";"))
click(2, "randomizer-customizer-import")
locale_catalogue.gui(find(panel(2), "randomizer-customizer-flow"))

-- Pending translations later reveal a filtered target, preserving its canonical ID.
write(2, "randomizer-customizer-search", "Förderband")
assert(storage.customizer_drafts[2].target == nil)
for id, request in pairs(translation_requests) do
    if request.player_index == 2 and request.caption[1] == "propertyrandomizer-randomization-name.belt_speed" then
        handlers[defines.events.on_string_translated]({
            player_index = 2,
            id = id,
            translated = true,
            result = "Förderband Geschwindigkeit",
        })
    end
end
handlers[defines.events.on_tick]({tick = 30})
assert(storage.customizer_drafts[2].target == "belt_speed")
locale_catalogue.gui(find(panel(2), "randomizer-customizer-flow"))
-- Another player's translations must not affect this search.
write(1, "randomizer-customizer-search", "Förderband")
assert(storage.customizer_drafts[1].target == nil)
game.players[2].locale = "another-language"
handlers[defines.events.on_player_locale_changed]({player_index = 2})
handlers[defines.events.on_tick]({tick = 60})
assert(storage.customizer_drafts[2].target == nil, "locale change discards translated search text")

assert(not pcall(locale_catalogue.validate, "English regression"))
assert(not pcall(locale_catalogue.validate, {"propertyrandomizer-customizer.missing"}))
assert(not pcall(locale_catalogue.validate, {"propertyrandomizer-customizer.summary"}))

prototypes.mod_data["propertyrandomizer-customizer-catalog"] = {
    data = {
        entries = {
            {
                kind = "widget",
                class = "entity",
                name = "fixture-building",
                subgroup = "fixture-subgroup",
                group = "fixture-group",
                caption = {
                    "propertyrandomizer-customizer.identifier",
                    "Fixture building",
                },
            },
            {
                kind = "component",
                class = "fixture-component",
                name = "fixture-component",
                subgroup = "fixture-subgroup",
                group = "fixture-group",
                caption = {
                    "propertyrandomizer-customizer.identifier",
                    "Fixture component",
                },
            },
        },
    },
}
select(1, "randomizer-customizer-scope", 3)
assert(storage.customizer_drafts[1].scope == "graph")
assert(storage.customizer_drafts[1].target == "graph/all")
local graph_targets = find(panel(1), "randomizer-customizer-targets").tags.targets
for _, graph_target in pairs(graph_targets) do
    target(1, graph_target)
    locale_catalogue.gui(find(panel(1), "randomizer-customizer-flow"))
end
target(1, "graph/all")
assert(find(panel(1), "randomizer-customizer-field-enabled") == nil)
select(1, "randomizer-customizer-field-amount", 3)
assert(customization.parse(exported(1)).graph.all.amount == "25")
assert(find(panel(1), "randomizer-customizer-exclusion-search") == nil, "graph parameters do not embed prototype exclusions")
select(1, "randomizer-customizer-scope", 4)
target(1, "graph/all")
local prototype_choice = find(panel(1), "randomizer-customizer-prototype-choice")
assert(prototype_choice.elem_type == "entity", "use the Explorer's native prototype picker")
prototype_choice.elem_value = "fixture-building"
handlers[defines.events.on_gui_elem_changed]({
    player_index = 1,
    element = prototype_choice,
})
assert(storage.customizer_drafts[1].exclusion_value == "fixture-building")
click(1, "randomizer-customizer-exclude-selected")
assert(customization.parse(exported(1)).exclusions.all["prototype/entity/fixture-building"])
assert(find(panel(1), "randomizer-customizer-prototype-choice").elem_value == "fixture-building", "rebuilding retains the native selection")
select(1, "randomizer-customizer-exclusion-kind", 3)
local exclusion_search = find(panel(1), "randomizer-customizer-exclusion-search")
write(1, exclusion_search.name, "fixture-group")
assert(exclusion_search.valid and find(panel(1), exclusion_search.name) == exclusion_search, "typing must preserve the search element and caret")
customizer.refresh_translations(1)
assert(exclusion_search.valid and find(panel(1), exclusion_search.name) == exclusion_search, "translations must preserve the exclusion search element")
click(1, "randomizer-customizer-exclude-selected")
assert(customization.parse(exported(1)).exclusions.all["group/fixture-group"])
select(1, "randomizer-customizer-exclusion-kind", 4)
write(1, "randomizer-customizer-exclusion-search", "fixture-subgroup")
click(1, "randomizer-customizer-exclude-selected")
assert(customization.parse(exported(1)).exclusions.all["subgroup/fixture-subgroup"])
target(1, "all")
click(1, "randomizer-customizer-exclude-selected")
assert(customization.parse(exported(1)).prototype_exclusions.all["subgroup/fixture-subgroup"])
target(1, "numerical/all")
click(1, "randomizer-customizer-exclude-selected")
assert(customization.parse(exported(1)).prototype_exclusions["numerical/all"]["subgroup/fixture-subgroup"])
target(1, "randomization/belt_speed")
click(1, "randomizer-customizer-exclude-selected")
assert(customization.parse(exported(1)).prototype_exclusions["randomization/belt_speed"]["subgroup/fixture-subgroup"])
select(1, "randomizer-customizer-exclusion-kind", 1)
local class_choices = find(panel(1), "randomizer-customizer-exclusion-class")
for index, class in pairs(class_choices.tags.values) do
    if class == "fixture-component" then
        select(1, class_choices.name, index)
        break
    end
end
assert(find(panel(1), "randomizer-customizer-prototype-choice") == nil, "other prototype classes use the catalogue selector")
write(1, "randomizer-customizer-exclusion-search", "fixture-component")
click(1, "randomizer-customizer-exclude-selected")
assert(customization.parse(exported(1)).prototype_exclusions["randomization/belt_speed"]["prototype/component/fixture-component"])
target(1, "graph/all")
click(1, "randomizer-customizer-clear-scope-exclusions")
local after_scope_clear = customization.parse(exported(1))
assert(after_scope_clear.exclusions.all == nil)
assert(after_scope_clear.graph.all.amount == "25", "clearing exclusions retains graph parameters")
assert(after_scope_clear.prototype_exclusions["numerical/all"]["subgroup/fixture-subgroup"], "clearing a scope retains other scopes")
locale_catalogue.gui(find(panel(1), "randomizer-customizer-flow"))
select(1, "randomizer-customizer-scope", 3)
write(1, "randomizer-customizer-search", "recipe-ingredients")
assert(find(panel(1), "randomizer-customizer-field-keep_category") == nil)
select(1, "randomizer-customizer-field-ingredient_count", 2)
select(1, "randomizer-customizer-field-resource_balance", 3)
assert(customization.parse(exported(1)).graph["recipe-ingredients"].ingredient_count == "preserve")
assert(customization.parse(exported(1)).graph["recipe-ingredients"].resource_balance == "off")
locale_catalogue.gui(panel(1))
click(1, "randomizer-customizer-reset-target")
assert(customization.parse(exported(1)).graph["recipe-ingredients"] == nil)
write(1, "randomizer-customizer-search", "entity")
assert(find(panel(1), "randomizer-customizer-field-ingredient_count") == nil)
click(1, "randomizer-customizer-clear")
assert(next(customization.parse(exported(1)).graph) == nil and next(customization.parse(exported(1)).exclusions) == nil)
write(1, "randomizer-customizer-search", "Zutaten")
assert(storage.customizer_drafts[1].target == nil)
for id, request in pairs(translation_requests) do
    if request.player_index == 1 and request.caption[1] == "propertyrandomizer-customizer.graph-recipe-ingredients" then
        handlers[defines.events.on_string_translated]({
            player_index = 1,
            id = id,
            translated = true,
            result = "Zutaten",
        })
    end
end
handlers[defines.events.on_tick]({tick = 120})
assert(storage.customizer_drafts[1].target == "graph/recipe-ingredients", "translated graph captions must be searchable")
local old_panel = panel(1)
local saved_draft = storage.customizer_drafts[1]
find(old_panel, "randomizer-info-flow").destroy()
handlers["randomizer-panel"]({player_index = 1})
assert(old_panel.valid == false and panel(1) ~= old_panel, "legacy panels rebuild on reopening")
assert(find(panel(1), "randomizer-info-page-choice").selected_index == 1)
assert(storage.customizer_drafts[1] == saved_draft, "layout migration preserves customizer drafts")
print("ok - customizer events, all target/value locales, import errors, translated search and persistence")
