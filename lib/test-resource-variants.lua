-- Run from the mod root: lua lib/test-resource-variants.lua

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
function log(message) end
defines = {
    prototypes = {
        entity = {},
        item = {},
    },
}
data = { raw = {} }
function data:extend(prototypes)
    for _, prototype in pairs(prototypes) do
        self.raw[prototype.type] = self.raw[prototype.type] or {}
        self.raw[prototype.type][prototype.name] = prototype
    end
end

local constants = require("helper-tables/constants")
local variants = require("lib/resource-variants")
local wild = require("lib/wild-entities")
local lutils = require("lib/logic/logic-utils")

local function prototype(class, name, extra)
    local result = extra or {}
    result.type = class
    result.name = name
    defines.prototypes.entity[class] = 0
    data:extend({ result })
    return result
end

local source = prototype("resource", "test-shared-ore", {
    autoplace = {
        control = "test-ore-slider",
        probability_expression = "test-ore-probability",
        richness_expression = "test-ore-richness",
    },
    minable = {
        result = "test-product",
        mining_time = 2,
    },
})
local starting = prototype("planet", "test-start", {
    map_gen_settings = {
        autoplace_controls = { ["test-ore-slider"] = {} },
        autoplace_settings = { entity = { settings = { [source.name] = {} } } },
    },
})
constants.starting_planet = starting.name
local copy = prototype(starting.type, "test-start-copy", table.deepcopy(starting))
local map = copy.map_gen_settings
map.autoplace_settings.entity.settings[source.name].frequency = 2
map.autoplace_settings.entity.settings[source.name].size = 3
map.autoplace_settings.entity.settings[source.name].richness = 4
wild.set_overrides(copy, source.name, {
    probability = "test-copy-probability",
    richness = "test-copy-richness",
})
local foreign = prototype(starting.type, "test-foreign", {
    map_gen_settings = {
        autoplace_controls = { ["test-ore-slider"] = {} },
    },
})
local absent = prototype(starting.type, "test-absent", {
    map_gen_settings = table.deepcopy(starting.map_gen_settings),
})
wild.keep_off(absent, source.name)
local unique = prototype(source.type, "test-unique-ore", table.deepcopy(source))
unique.autoplace.control = nil
starting.map_gen_settings.autoplace_settings.entity.settings[unique.name] = {}
local trigger = prototype("technology", "test-mining-trigger", {})
trigger.research_trigger = { entities = { source.name } }
trigger.research_trigger.type = "mine-entity"

local before = table.deepcopy(data.raw)
local copies = variants.execute()
assert(#copies[source.name] == 2)
assert(copies[unique.name] == nil)
local copied
for _, name in pairs(copies[source.name]) do
    local resource = data.raw.resource[name]
    assert(resource.autoplace.probability_expression == source.autoplace.probability_expression)
    assert(resource.autoplace.richness_expression == source.autoplace.richness_expression)
    assert(resource.minable ~= source.minable)
    local homes = 0
    for _, planet in pairs(data.raw.planet) do
        if lutils.check_in_room(planet, resource) then
            homes = homes + 1
            if planet.name == copy.name then
                copied = resource
            end
        end
    end
    assert(homes == 1)
end
assert(copied ~= nil)
assert(lutils.check_in_room(starting, source))
assert(not lutils.check_in_room(copy, source))
assert(not lutils.check_in_room(foreign, source))
assert(not lutils.check_in_room(absent, source))
local placement = map.autoplace_settings.entity.settings[copied.name]
assert(placement.frequency == 2 and placement.size == 3 and placement.richness == 4)
local overrides = wild.overrides(copy, copied.name)
assert(overrides.probability == "test-copy-probability")
assert(overrides.richness == "test-copy-richness")
assert(map.autoplace_controls["test-ore-slider"] ~= nil)
assert(#trigger.research_trigger.entities == 3)
copied.minable.result = "test-independent-product"
assert(source.minable.result == "test-product")
copied.minable.result = "test-product"
assert(next(variants.execute()) == nil)
assert(#trigger.research_trigger.entities == 3)
-- A later planetary repair can put the original back beside its previous copy.
-- Separating it again must neither overwrite that copy nor lose the repair's placement.
map.autoplace_settings.entity.settings[source.name] = { frequency = 5 }
wild.set_overrides(copy, source.name, {
    probability = "test-repair-probability",
    richness = "test-repair-richness",
})
local repairs = variants.execute()
assert(#repairs[source.name] == 1)
local repair = data.raw.resource[repairs[source.name][1]]
assert(repair.name ~= copied.name)
assert(data.raw.resource[copied.name] == copied)
assert(lutils.check_in_room(copy, copied))
assert(lutils.check_in_room(copy, repair))
assert(not lutils.check_in_room(copy, source))
assert(map.autoplace_settings.entity.settings[repair.name].frequency == 5)
assert(wild.overrides(copy, repair.name).probability == "test-repair-probability")
assert(wild.overrides(copy, repair.name).richness == "test-repair-richness")
assert(#trigger.research_trigger.entities == 4)
assert(next(variants.execute()) == nil)
assert(before.resource[source.name].autoplace.probability_expression == source.autoplace.probability_expression)
print("ok - planet resource variants preserve placements, isolate entities and keep mining triggers")
