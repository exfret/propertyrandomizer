-- Run from the mod root: lua tests/unit/config/test-customization.lua
local customization = require("src/config/customization")
local spec = require("src/config/spec")
local tuning = require("src/lib/random/tuning")

local group = "setting/propertyrandomizer-logistic"
local id = "belt_speed"
local function resolve(text, target)
    local state = customization.parse(text)
    assert(#state.warnings == 0, table.concat(state.warnings, "\n"))
    return customization.resolve(state, target or id)
end

local individual = "ON:" .. id .. ";PARAM:" .. id .. ".variance=big"
local broad = "OFF:" .. group .. ";PARAM:" .. group .. ".range=small;PARAM:" .. group .. ".variance=very_small"
for _, text in pairs({
    individual .. ";" .. broad,
    broad .. ";" .. individual,
}) do
    local value = resolve(text)
    assert(value.enabled == true and value.range == "small" and value.variance == "big", "individual fields must win in either order")
    local other = resolve(text, "inserter_speed")
    assert(other.enabled == false and other.range == "small" and other.variance == "very_small", "other members must inherit group fields")
end
assert(resolve("ON:" .. group .. ";!" .. id).enabled == false, "false must override true")
assert(resolve("!" .. id .. ";ON:" .. group).enabled == false, "a later group must not erase an individual false")
assert(resolve("!" .. id .. ";" .. id).enabled == true, "last instruction at the same scope wins")
assert(resolve("ON:" .. group .. ";OFF:" .. group).enabled == false)
assert(resolve(broad .. ";" .. individual .. ";PARAM:" .. id .. ".variance=inherit").variance == "very_small")
assert(resolve(broad .. ";" .. individual .. ";INHERIT:" .. id).enabled == false)
assert(resolve(broad .. ";INHERIT:" .. group).range == nil)
assert(resolve("PARAM:" .. id .. ".range=small").enabled == nil, "tuning must not enable a randomization")
assert(resolve("SET:[fixture=example].value=1;RESET:[fixture=example]").enabled == nil, "post-processing must be left to config")
assert(resolve("").range == nil)

-- Setting membership comes from both supported shapes of spec metadata.
assert(customization.setting_name({setting = "fixture-setting"}) == "fixture-setting")
assert(customization.setting_name({setting = {name = "fixture-setting"}}) == "fixture-setting")
assert(customization.setting_name({setting = "none"}) == nil)
for name, members in pairs(customization.groups) do
    for _, member in pairs(members) do
        assert(customization.setting_name(spec[member]) == name)
    end
end
for member, info in pairs(spec) do
    local name = customization.setting_name(info)
    if info.category == "numerical" and name ~= nil then
        local found = false
        for _, candidate in pairs(customization.groups[name]) do
            if candidate == member then
                found = true
            end
        end
        assert(found, "every randomization tied to a setting must belong to its group")
    end
end
for parameter, info in pairs(tuning.parameters) do
    for _, value in pairs(info.values) do
        assert(resolve("PARAM:" .. id .. "." .. parameter .. "=" .. value)[parameter] == value)
    end
end

local invalid = {
    "PARAM:" .. id .. ".variance=none",
    "PARAM:" .. id .. ".range=3",
    "PARAM:" .. id .. ".abs_min=0",
    "PARAM:" .. id .. ".dir=1",
    "PARAM:" .. id .. ".rounding=none",
    "PARAM:" .. id .. ".not_a_parameter=inherit",
    "PARAM:unknown_randomization.range=small",
    "ON:setting/unknown-setting",
    "OFF:unknown_randomization",
    "PARAM:" .. id .. ".variance=big=small",
    "PARAM:" .. id .. "=small",
    "PARAM:spoil_spawn.variance=small",
    "PARAM:items.variance=small",
    "PARAM:map_colors.variance=small",
    "PARAM:fluid_box_locations.range=small",
    "UNKNOWN:" .. id,
}
for _, instruction in pairs(invalid) do
    local state = customization.parse(instruction .. ";ON:" .. id)
    assert(#state.warnings == 1, "invalid instruction needs one warning: " .. instruction)
    assert(customization.resolve(state, id).enabled == true, "later valid instructions must still apply")
end
spec.fixture_boolean = {
    category = "numerical",
    setting = "propertyrandomizer-misc",
    tuning = false,
}
local boolean_state = customization.parse("PARAM:fixture_boolean.variance=small")
assert(#boolean_state.warnings == 1, "boolean-only choices must reject individual tuning")
local boolean_choice = resolve("OFF:setting/propertyrandomizer-misc;PARAM:setting/propertyrandomizer-misc.variance=big", "fixture_boolean")
spec.fixture_boolean = nil
assert(boolean_choice.enabled == false and boolean_choice.variance == nil, "group toggles include boolean choices, tuning does not")

-- Exercise the actual startup-setting bridge using defaults from settings.lua.
settings = {startup = {}}
data = {}
data.extend = function(_, definitions)
    for _, definition in pairs(definitions) do
        settings.startup[definition.name] = {value = definition.default_value}
    end
end
dofile("settings.lua")
settings.startup["propertyrandomizer-unified-preview"].value = false
settings.startup["propertyrandomizer-dev-unified"].value = false
settings.startup["propertyrandomizer-overrides"].value = individual .. ";" .. broad
randomization_info = {
    options = {},
    warnings = {},
}
dofile("src/config/init.lua")
assert(#randomization_info.warnings == 0)
assert(config.numerical_overrides[id].variance == "big")
local toggles = {}
for _, ordered in pairs(randomizations_to_perform) do
    for member, enabled in pairs(ordered) do
        toggles[member] = enabled
    end
end
assert(toggles[id] == true and toggles.inserter_speed == false, "compiled startup overrides must control scheduling")
print("ok - customization inheritance, validation, derived groups and startup-setting bridge")
