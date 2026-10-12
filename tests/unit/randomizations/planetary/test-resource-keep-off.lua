-- Run from the mod root: lua tests/unit/randomizations/planetary/test-resource-keep-off.lua
-- A resource a planet loses in the swap stays off that planet: its slider can stay for the resource placed in its old spot, and with that slider the game would still place it there and logic would count it there (scrap on Fulgora under calcite)

function table.deepcopy(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end
data = { raw = {} }
data.raw.resource = {}
data.raw.planet = {}
data.raw["autoplace-control"] = {}
data.raw["noise-expression"] = {}
function data:extend(prototypes)
    for _, prototype in pairs(prototypes) do
        self.raw[prototype.type] = self.raw[prototype.type] or {}
        self.raw[prototype.type][prototype.name] = prototype
    end
end
local function prototype(class, name, extra)
    local result = extra or {}
    result.type = class
    result.name = name
    data:extend({ result })
    return result
end
package.loaded["__core__/lualib/resource-autoplace"] = {
    resource_autoplace_settings = function(params)
        local prefix = params.autoplace_set_name
        prototype("noise-expression", prefix .. "_regular_resource_patch_set_count", { expression = 1 })
        prototype("noise-expression", prefix .. "_starting_resource_patch_set_count", { expression = 1 })
        return {
            probability_expression = "test-probability",
            richness_expression = "test-richness",
        }
    end,
}
package.loaded["src/lib/sort/context-sort"] = {}
package.loaded["src/lib/random/rng"] = {}
package.loaded["src/randomizations/planetary/check"] = {}
package.loaded["src/randomizations/planetary/locks"] = {}
package.loaded["src/randomizations/planetary/scaffolds"] = {}
package.loaded["src/prototypes/surfaces/surface-sets"] = {}

local resources = require("src/randomizations/planetary/resources")
local lutils = require("src/logic/logic-utils")
local wild = require("src/prototypes/entities/wild-entities")

-- Like scrap: placed by its own autoplace, which reads its own slider
local scrap = prototype("resource", "test-scrap", {
    autoplace = {
        control = "test-scrap",
        probability_expression = "test-scrap-probability",
    },
})
prototype("autoplace-control", scrap.name, { category = "resource" })
-- Like calcite: placed only where a planet overrides its probability
local calcite = prototype("resource", "test-calcite", {
    autoplace = {
        probability_expression = 0,
    },
})
local function planet_listing(name, resource_name)
    return prototype("planet", name, {
        map_gen_settings = {
            autoplace_controls = {},
            autoplace_settings = { entity = { settings = { [resource_name] = {} } } },
            property_expression_names = {},
        },
    })
end
local fulgora = planet_listing("test-fulgora", scrap.name)
fulgora.map_gen_settings.autoplace_controls[scrap.name] = {}
local vulcanus = planet_listing("test-vulcanus", calcite.name)
prototype("noise-expression", "test-vulcanus-calcite-probability", { expression = "test-vulcanus-calcite" })
vulcanus.map_gen_settings.property_expression_names["entity:" .. calcite.name .. ":probability"] = "test-vulcanus-calcite-probability"
local fulgora_room = {
    type = "planet",
    name = fulgora.name,
}
local vulcanus_room = {
    type = "planet",
    name = vulcanus.name,
}

local slots = {
    {
        planet_name = fulgora.name,
        resource_name = scrap.name,
        kind = "ore",
        probability = scrap.autoplace.probability_expression,
    },
    {
        planet_name = vulcanus.name,
        resource_name = calcite.name,
        kind = "ore",
        probability_name = "test-vulcanus-calcite-probability",
    },
}
-- Calcite moves to Fulgora and scrap to Vulcanus
local assignment = {
    calcite.name,
    scrap.name,
}
local lost = resources.apply(slots, assignment)
assert(lost[fulgora.name][scrap.name] and lost[vulcanus.name][calcite.name])
-- Calcite took scrap's placement, which reads scrap's slider, so the slider is still on Fulgora
assert(fulgora.map_gen_settings.autoplace_controls[scrap.name] ~= nil)
assert(lutils.check_in_room(fulgora_room, calcite))
assert(wild.never_placed(fulgora, scrap.name))
assert(not lutils.check_in_room(fulgora_room, scrap))
assert(lutils.check_in_room(vulcanus_room, scrap))
assert(not lutils.check_in_room(vulcanus_room, calcite))
print("ok - a resource a planet lost stays off it, even where its slider is left")

local repair = resources.repair(fulgora.name, scrap.name)
resources.add_repair(repair)
assert(not wild.never_placed(fulgora, scrap.name))
assert(lutils.check_in_room(fulgora_room, scrap))
resources.remove_repair(repair)
assert(wild.never_placed(fulgora, scrap.name))
assert(not lutils.check_in_room(fulgora_room, scrap))
print("ok - a repair places a lost resource again, and taking the repair out keeps it off")
