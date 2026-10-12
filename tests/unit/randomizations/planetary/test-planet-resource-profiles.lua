-- Run: lua tests/unit/randomizations/planetary/test-planet-resource-profiles.lua
bit32 = {
    bxor = function(a, b) return (a ~ b) & 0xffffffff end,
    lshift = function(a, b) return (a << b) & 0xffffffff end,
    rshift = function(a, b) return (a & 0xffffffff) >> b end,
}
function table.deepcopy(value)
    if type(value) ~= "table" then return value end
    local copy = {}
    for key, child in pairs(value) do copy[key] = table.deepcopy(child) end
    return copy
end
function log(message) end
config = { seed = 123 }
data = { raw = {} }
defines = { prototypes = { entity = {}, item = {} } }
local profiles = require("src/randomizations/planetary/planet-resource-profiles")

local function add(kind, name, prototype)
    prototype.type = kind
    prototype.name = name
    data.raw[kind] = data.raw[kind] or {}
    data.raw[kind][name] = prototype
    defines.prototypes.entity[kind] = 0
    return prototype
end
local control = add("autoplace-control", "fixture-resource-slider", { richness = true })
control.category = "resource"
local other = add(control.type, "fixture-other-slider", table.deepcopy(control))
local terrain = add(control.type, "fixture-terrain-slider", { richness = true })
terrain.category = "terrain"
local ore = add("resource", "fixture-mod-ore", {
    autoplace = {
        probability_expression = "var('fixture-patches')",
        richness_expression = "var('fixture-patches') * var('control:fixture-resource-slider:richness')",
    },
})
local patches = add("noise-expression", "fixture-patches", {
    expression = "resource_autoplace_all_patches{size_multiplier = var('control:fixture-resource-slider:size'), frequency_multiplier = var('control:fixture-resource-slider:frequency'), has_starting_area_placement = 1}",
})
local planet = add("planet", "fixture-planet", {
    localised_description = "Existing description",
    map_gen_settings = {
        autoplace_controls = {
            [control.name] = { size = 2, frequency = 0.5, richness = 3 },
            [other.name] = {},
            [terrain.name] = { size = 0.5 },
        },
        autoplace_settings = { entity = { settings = { [ore.name] = {} } } },
    },
})
local custom = add(ore.type, "fixture-custom-well", {
    autoplace = { probability_expression = "fixture_other_probability", richness_expression = "fixture_other_richness" },
})
add(patches.type, "fixture_other_probability", {
    expression = "local_size * local_frequency + control:fixture-terrain-slider:size",
    local_expressions = { local_size = "control:fixture-other-slider:size", local_frequency = "control:fixture-other-slider:frequency" },
})
add(patches.type, "fixture_other_richness", { expression = "control:fixture-other-slider:richness" })
planet.map_gen_settings.autoplace_settings.entity.settings[custom.name] = { richness = 2 }
local entries, controls = profiles.eligible(planet)
assert(#entries == 2)
assert(controls[control.name] == true and controls[other.name] == true)
assert(controls[terrain.name] == nil)
local ordinary_probability = ore.autoplace.probability_expression
ore.autoplace.probability_expression = ordinary_probability .. " * random_penalty{amplitude = 100}"
local sparse_entries = profiles.eligible(planet)
for _, entry in pairs(sparse_entries) do
    if entry.resource_name == ore.name then
        assert(entry.has_helper == false, "Sparse placements must use the wider response envelope")
    end
end
ore.autoplace.probability_expression = ordinary_probability
local extreme = { size = 0.1, frequency = 4, richness = 2.5 }
local final = profiles.balance(entries, controls, extreme, planet.map_gen_settings)
assert(final.adjustments > 0)
for _, entry in pairs(entries) do
    local low, high = profiles.total_range(entry, final, planet.map_gen_settings)
    assert(low >= 0.75 and high <= 4 / 3)
end
-- A single unusual resource must constrain the whole profile.
local standard = {}
for _, entry in pairs(entries) do
    if entry.has_helper then table.insert(standard, entry) end
end
local fewer = profiles.balance(standard, controls, extreme, planet.map_gen_settings)
assert(final.adjustments > fewer.adjustments)
-- Copies get their own seed key, with draws stable across resource order and fresh data tables.
local clone = table.deepcopy(planet)
add(planet.type, "fixture-planet-copy", clone)
local original = table.deepcopy(data.raw)
local result = profiles.execute()
assert(result[planet.name].size ~= result[clone.name].size)
for name, profile in pairs(result) do
    local current = data.raw.planet[name]
    local baseline = original.planet[name]
    for _, slider in pairs({ control.name, other.name }) do
        local before = baseline.map_gen_settings.autoplace_controls[slider]
        local after = current.map_gen_settings.autoplace_controls[slider]
        assert(math.abs(after.size / (before.size or 1) - profile.size) < 1e-12)
        assert(math.abs(after.frequency / (before.frequency or 1) - profile.frequency) < 1e-12)
        assert(math.abs(after.richness / (before.richness or 1) - profile.richness) < 1e-12)
    end
    assert(current.localised_description[2] == "Existing description")
    assert(current.localised_description[4][5] == string.format("%.2f", profile.size))
    assert(current.map_gen_settings.autoplace_controls[terrain.name].size == 0.5)
    assert(current.map_gen_settings.autoplace_settings.entity.settings[custom.name].richness == 2 * profile.richness)
end
data.raw = table.deepcopy(original)
local again = profiles.execute()
for name, profile in pairs(result) do
    assert(again[name].size == profile.size and again[name].frequency == profile.frequency and again[name].richness == profile.richness)
end
-- Disabled resources stay disabled, and unsupported expression overrides are ineligible.
data.raw = table.deepcopy(original)
local map = data.raw.planet[planet.name].map_gen_settings
map.autoplace_controls[other.name].size = 0
map.property_expression_names = { ["control:" .. control.name .. ":frequency"] = "fixture-custom-frequency" }
assert(#profiles.eligible(data.raw.planet[planet.name]) == 0)
map.property_expression_names["control:" .. control.name .. ":frequency"] = 0.8
assert(#profiles.eligible(data.raw.planet[planet.name]) == 1)
local numeric_result = profiles.execute()[planet.name]
assert(map.property_expression_names["control:" .. control.name .. ":frequency"] == 0.8 * numeric_result.frequency)
assert(map.autoplace_controls[other.name].size == 0)
-- A slider alone must not make a constant-zero placement eligible.
data.raw.resource[ore.name].autoplace.probability_expression = 0
assert(#profiles.eligible(data.raw.planet[planet.name]) == 0)
-- A resource placed with another slot's placement (a resource swap) gets that placement's sliders, not the one it names, which a planet without it must not gain (scrap on Gleba, 2026-10-09).
data.raw = table.deepcopy(original)
local named = add("autoplace-control", "fixture-named-slider", { richness = true })
named.category = "resource"
local swapped = add("resource", "fixture-swapped-ore", {
    autoplace = {
        control = named.name,
        probability_expression = "var('control:fixture-named-slider:size')",
        richness_expression = "var('control:fixture-named-slider:richness')",
    },
})
local swap_map = data.raw.planet[planet.name].map_gen_settings
swap_map.autoplace_settings.entity.settings[swapped.name] = {}
swap_map.property_expression_names = {
    ["entity:" .. swapped.name .. ":probability"] = patches.name,
    ["entity:" .. swapped.name .. ":richness"] = patches.name,
}
local swap_entries, swap_controls = profiles.eligible(data.raw.planet[planet.name])
assert(swap_controls[named.name] == nil, "The slider a swapped resource names isn't one its placement reads")
for _, entry in pairs(swap_entries) do
    if entry.resource_name == swapped.name then
        assert(entry.controls[control.name] == true and entry.controls[named.name] == nil)
    end
end
profiles.execute()
assert(swap_map.autoplace_controls[named.name] == nil, "Profiles don't add a slider no placement reads")
-- Where the planet has that slider, it's scaled as before.
data.raw = table.deepcopy(original)
data.raw["autoplace-control"][named.name] = table.deepcopy(named)
data.raw.resource[swapped.name] = table.deepcopy(swapped)
swap_map = data.raw.planet[planet.name].map_gen_settings
swap_map.autoplace_settings.entity.settings[swapped.name] = {}
swap_map.property_expression_names = {
    ["entity:" .. swapped.name .. ":probability"] = patches.name,
}
swap_map.autoplace_controls[named.name] = { size = 2 }
local _, kept_controls = profiles.eligible(data.raw.planet[planet.name])
assert(kept_controls[named.name] == true)
local kept_profile = profiles.execute()[planet.name]
assert(math.abs(swap_map.autoplace_controls[named.name].size - 2 * kept_profile.size) < 1e-12)
print("Planet resource profile tests passed")
