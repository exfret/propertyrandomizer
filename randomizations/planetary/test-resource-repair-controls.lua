-- Run from the mod root: lua randomizations/planetary/test-resource-repair-controls.lua

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
package.loaded["lib/graph/context-sort"] = {}
package.loaded["lib/random/rng"] = {}
package.loaded["randomizations/planetary/check"] = {}
package.loaded["randomizations/planetary/locks"] = {}
package.loaded["randomizations/planetary/scaffolds"] = {}
package.loaded["lib/surface-sets"] = {}

local resources = require("randomizations/planetary/resources")

local resource = prototype("resource", "test-resource", { autoplace = {} })
local template = prototype("autoplace-control", resource.name, {})
local planet = prototype("planet", "test-planet", {
    map_gen_settings = {
        autoplace_controls = {},
        autoplace_settings = { entity = { settings = {} } },
        property_expression_names = {},
    },
})
local repair = resources.repair(planet.name, resource.name)
resources.add_repair(repair)
local control = data.raw[template.type][repair.control.name]
assert(control.hidden ~= true)
resources.remove_repair(repair)
assert(control.hidden == true)
assert(planet.map_gen_settings.autoplace_controls[control.name] == nil)
resources.add_repair(repair)
assert(control.hidden ~= true)
assert(planet.map_gen_settings.autoplace_controls[control.name] ~= nil)
print("ok - unused repair controls are hidden and a kept repair becomes visible again")

template.hidden = true
local hidden = resources.repair(planet.name, resource.name)
resources.add_repair(hidden)
resources.remove_repair(hidden)
resources.add_repair(hidden)
assert(control.hidden == true)
print("ok - restoring a repair preserves its template's hidden setting")
