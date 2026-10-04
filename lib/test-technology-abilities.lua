-- Run from the mod root: lua lib/test-technology-abilities.lua
local abilities = require("lib/technology-abilities")

table.deepcopy = function(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for key, child in pairs(value) do
        copy[key] = table.deepcopy(child)
    end
    return copy
end

local function unlock(recipe)
    return {
        type = "unlock-recipe",
        recipe = recipe,
    }
end

local function permission(effect_type)
    return {
        type = effect_type,
        modifier = true,
    }
end

local function technology(effects)
    local tech = {}
    tech.effects = effects
    return tech
end

local function fixture()
    return {
        rails = technology({
            unlock("modded-support"),
            unlock("modded-ramp"),
            permission("rail-planner-allow-elevated-rails"),
        }),
        foundations = technology({permission("rail-support-on-deep-oil-ocean")}),
        mining = technology({
            permission("mining-with-fluid"),
            unlock("modded-drill"),
        }),
        cliff_permission = technology({permission("cliff-deconstruction-enabled")}),
    }
end

local techs = fixture()
local bundled = abilities.bundle(techs, {
    ["modded-support"] = true,
    ["modded-ramp"] = true,
})
for _, recipe in pairs({
    "modded-support",
    "modded-ramp",
}) do
    local found = {}
    for _, effect in pairs(bundled[recipe]) do
        found[effect.type] = effect.modifier
    end
    assert(found["rail-planner-allow-elevated-rails"] == true)
    assert(found["rail-support-on-deep-oil-ocean"] == true)
end
assert(#techs.rails.effects == 2)
assert(#techs.foundations.effects == 0)
assert(#techs.mining.effects == 1 and techs.mining.effects[1].recipe == "modded-drill")
assert(#techs.cliff_permission.effects == 0)
bundled["modded-support"][1].modifier = false
assert(bundled["modded-ramp"][1].modifier == true)

-- Without a reachable rebuilt rail recipe, preserve both permissions on their existing technologies.
techs = fixture()
assert(next(abilities.bundle(techs, {})) == nil)
assert(#techs.rails.effects == 3 and #techs.foundations.effects == 1)

-- Only attach to recipes the rebuild will actually emit.
techs = fixture()
bundled = abilities.bundle(techs, {["modded-ramp"] = true})
assert(bundled["modded-support"] == nil and #bundled["modded-ramp"] == 2)
print("Technology ability tests passed")

local raw = {}
raw.quality = {}
raw.module = {}
raw.recipe = {}
local quality_techs = {}
for i = 1, 4 do
    local name = "test-quality-" .. i
    raw.quality[name] = {level = i}
    quality_techs[name] = technology({
        {
            type = "unlock-quality",
            quality = name,
        },
    })
end
local rebuilt = {}
for i = 1, 3 do
    local name = "test-module-" .. i
    local module = {}
    module.effect = {}
    module.effect.quality = i == 3 and 0 or i / 100
    raw.module[name] = module
    local recipe = {}
    recipe.results = {
        {
            type = "item",
            name = name,
            amount = 1,
        },
    }
    raw.recipe[name] = recipe
    rebuilt[name] = true
end
local original = table.deepcopy(quality_techs)
local effects = {}
abilities.bundle_quality(quality_techs, {}, raw, effects)
assert(#quality_techs["test-quality-1"].effects == 1)
assert(next(effects) == nil)
abilities.bundle_quality(quality_techs, rebuilt, raw, effects)
for i = 1, 2 do
    local bundle = effects["test-module-" .. i]
    assert(#bundle == 2)
    assert(bundle[1].quality == "test-quality-1" and bundle[2].quality == "test-quality-2")
    assert(#quality_techs["test-quality-" .. i].effects == 0)
end
assert(effects["test-module-3"] == nil)
assert(#quality_techs["test-quality-3"].effects == 1)
assert(#quality_techs["test-quality-4"].effects == 1)
effects["test-module-1"][1].quality = "changed"
assert(effects["test-module-2"][1].quality == "test-quality-1")
assert(original["test-quality-1"].effects[1].quality == "test-quality-1")
print("Quality ability tests passed")
