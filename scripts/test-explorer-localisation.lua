-- Run from the mod root: lua scripts/test-explorer-localisation.lua
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
        caption = definition.caption or "",
        valid = true,
        visible = definition.visible ~= false,
        tabs = {},
    }
    element.add = function(child_definition)
        assert(element.valid, "cannot add to a destroyed element")
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
for index = 1, 3 do
    game.players[index] = {
        gui = {screen = gui_element({type = "screen"})},
        display_resolution = {
            width = 1920,
            height = 1080,
        },
        display_scale = 1,
    }
end

-- Unrelated explorer dependencies aren't used by these customizer interactions.
for _, module in pairs({
    "lib/locale",
    "lib/cost/cost-utils",
    "lib/graph/graph-utils",
    "lib/graph/context-sort",
    "lib/logic/init",
    "scripts/explorer-sorts",
    "scripts/explorer-rows",
    "scripts/derandomizer",
}) do
    package.loaded[module] = {}
end
local handlers = {}
package.loaded["lib/graph/graph-utils"].key = function(kind, name)
    return kind .. ":" .. name
end
package.loaded["lib/graph/context-sort"].ISOLATABILITY = 1
package.loaded["lib/graph/context-sort"].AUTOMATABILITY = 2
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

-- Keep this test focused on the main panel and selectors; the customizer owns its own tests.
package.loaded["scripts/customizer"] = {
    set_selector_types = function() end,
    on_elem_changed = function() return false end,
    create = function() end,
    resize = function() end,
    refresh_translations = function() end,
    on_selection_changed = function() return false end,
    on_text_changed = function() return false end,
}
local requests = {}
for index, player in pairs(game.players) do
    player.index = index
    player.locale = "fixture-language"
    player.gui.screen.player_index = index
    player.request_translation = function(caption)
        table.insert(requests, {player_index = index, caption = caption})
        return #requests
    end
end
defines.prototypes = {fixture = {fixture = true}}
prototypes.fixture = {
    alpha = {name = "alpha", localised_name = {"fixture.alpha"}},
    beta = {name = "beta", localised_name = {"fixture.beta"}},
}
package.loaded["lib/locale"].find_localised_name = function(prototype) return prototype.localised_name end
package.loaded["lib/graph/graph-utils"].deconstruct = function(key)
    local kind, name = string.match(key, "^([^:]+):(.*)$")
    return {type = kind, name = name}
end
storage.graph = {
    nodes = {
        alpha = {type = "fixture-type", name = "alpha", prot = "fixture:alpha"},
        beta = {type = "fixture-type", name = "beta", prot = "fixture:beta"},
    },
}
local gui = require("scripts/gui")
local function dispatch(kind, element)
    handlers[kind]({player_index = 1, element = element})
end
handlers["randomizer-panel"]({player_index = 1})
local panel = game.players[1].gui.screen["randomizer-main-panel"]
assert(find(panel, "randomizer-home-flow-caption").style.single_line == false)
assert(find(panel, "randomizer-explorer-intro").style.maximal_width < 1920)
local category = find(panel, "randomizer-explorer-type-choice")
category.selected_index = 9
-- The event runs real selector creation, including real nested LocalisedString captions.
dispatch(defines.events.on_gui_selection_state_changed, category)
local types = find(panel, "randomizer-explorer-node-type")
local names = find(panel, "randomizer-explorer-node-name")
assert(types.tags.keys[1] == "fixture-type")
assert(#names.items == 2 and type(names.items[1]) == "table")
assert(names.tags.keys[1] == "alpha" and names.tags.keys[2] == "beta")
names.selected_index = 1
for id, request in pairs(requests) do
    local caption = request.caption
    local result = "A translated type with an intentionally expanded caption"
    if caption[1] == "propertyrandomizer-gui.node-caption" then
        result = caption[3][1] == "fixture.alpha" and "Z translated alpha" or "A translated beta"
    end
    handlers[defines.events.on_string_translated]({
        player_index = 1, id = id, translated = true, result = result,
    })
end
handlers[defines.events.on_tick]({tick = 30})
assert(names.tags.keys[1] == "beta" and names.tags.keys[2] == "alpha", "selectors sort by translated captions")
assert(names.tags.keys[names.selected_index] == "alpha", "translation completion preserves canonical selection")
local query = find(panel, "randomizer-explorer-node-search")
query.text = "translated beta"
dispatch(defines.events.on_gui_text_changed, query)
assert(#names.items == 1 and names.tags.keys[1] == "beta", "translated search selects the canonical node")
query.text = "ALPHA"
dispatch(defines.events.on_gui_text_changed, query)
assert(#names.items == 1 and names.tags.keys[1] == "alpha", "technical ID search is retained")
query.text = ""
dispatch(defines.events.on_gui_text_changed, query)
local request_count = #requests
game.players[1].locale = "another-language"
handlers[defines.events.on_player_locale_changed]({player_index = 1})
handlers[defines.events.on_tick]({tick = 60})
assert(#requests > request_count, "changing language requests fresh captions")
print("ok - real explorer events, translated sorting/search, canonical selection and expanded-caption layout constraints")
