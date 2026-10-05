-- Run from the mod root: lua lib/test-localisation.lua
local text = require("lib/localised-text")
local locale = require("lib/locale")
local search = require("scripts/explorer-localisation")
local customization = require("lib/customization")

local function validate(value, depth)
    depth = depth or 0
    assert(depth <= 20, "localisation nesting exceeded")
    if type(value) == "table" then
        assert(type(value[1]) == "string" and #value <= 21, "invalid locale header or parameter count")
        for index = 2, #value do
            validate(value[index], depth + 1)
        end
    else
        assert(type(value) == "string", "prototype locale must contain strings or tables")
    end
end
local parts = {}
for index = 1, 1000 do
    parts[index] = text.get("fixture.part", index)
end
local joined = text.join(parts, ", ")
validate(joined)
local function flatten(value)
    if type(value) ~= "table" then return value end
    if value[1] == "fixture.part" then return value[2] end
    local result = ""
    for index = 2, #value do result = result .. flatten(value[index]) end
    return result
end
assert(flatten(joined) == table.concat((function()
    local numbers = {}
    for index = 1, 1000 do numbers[index] = tostring(index) end
    return numbers
end)(), ", "), "wide locale lists must retain their order")

-- The startup crash involved a translated technology-modifier addon reaching this helper.
defines = {prototypes = {fixture = {fixture = true}}}
local prototype = {type = "fixture", name = "sample", localised_description = "Original description"}
locale.create_localised_description(prototype, 1.2, "fixture", {
    addons = text.get("fixture.addon", text.get("fixture.modifier")),
})
validate(prototype.localised_description)
assert(prototype.localised_description[5][2][1] == "fixture.addon")
for index = 1, 40 do
    locale.create_localised_description(prototype, 1.2, "fixture", {addons = " (plain addon)"})
end
validate(prototype.localised_description)

local invalid = customization.parse("ON:unknown_randomization;PARAM:belt_speed.range=invalid")
assert(#invalid.warnings == 2 and #invalid.localised_warnings == 2)
for _, warning in pairs(invalid.localised_warnings) do validate(warning) end
assert(type(invalid.warnings[1]) == "string", "customizer diagnostics must keep their existing API")

storage = {}
local requests = 0
local function player(index, language)
    return {
        index = index,
        locale = language,
        request_translation = function(caption)
            requests = requests + 1
            return requests
        end,
    }
end
game = {players = {player(1, "de"), player(2, "fr")}}
local key = "node:fixture"
assert(search.value(game.players[1], key, text.get("fixture.name"), "fixture-id") == "fixture-id")
search.value(game.players[1], key, text.get("fixture.name"), "fixture-id")
assert(requests == 1, "pending translations must not be requested repeatedly")
search.on_translated({player_index = 1, id = 1, translated = true, result = "Übersetzter Name"})
assert(search.value(game.players[1], key, {}, "fixture-id") == "Übersetzter Name")
assert(search.matches("Übersetz", "Übersetzter Name", "fixture-id"))
assert(search.matches("FIXTURE", "Übersetzter Name", "fixture-id"))
assert(not search.matches("missing", "Übersetzter Name", "fixture-id"))
assert(search.value(game.players[2], key, {}, "fixture-id") == "fixture-id", "translations must be per player")
search.on_translated({player_index = 2, id = 2, translated = false, result = ""})
assert(search.value(game.players[2], key, {}, "fixture-id") == "fixture-id", "failed translation must retain its fallback")
search.invalidate(1)
search.on_translated({player_index = 1, id = 1, translated = true, result = "stale"})
game.players[1].locale = "fr"
assert(search.value(game.players[1], key, {}, "fixture-id") == "fixture-id", "locale changes discard stale translations")
assert(storage.explorer_translation_dirty[1])
print("ok - LocalisedString limits, table addons, warning compatibility and per-player translated search")
