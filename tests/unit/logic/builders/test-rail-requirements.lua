-- Run from the mod root: lua tests/unit/logic/builders/test-rail-requirements.lua
package.loaded["__core__/lualib/collision-mask-util"] = {
    get_mask = function(entity) return entity.collision_mask end,
    masks_collide = function(a, b)
        for layer, enabled in pairs(a.layers) do
            if enabled == true and b.layers[layer] == true then
                return true
            end
        end
        return false
    end,
}
local categories = require("src/prototypes/categories")
local requirements = require("src/logic/builders/rail-requirements")
local rail_type = next(categories.rail)
local stock_type = next(categories.rolling_stock)
local gutils = require("src/lib/graph/graph-utils")
local entities = {}
local buildables = {}
local function add(kind, name, layer, buildable)
    local entity = {
        type = kind,
        name = name,
        collision_mask = { layers = { [layer] = true } },
    }
    entities[name] = entity
    if buildable == true then
        buildables[gutils.key(entity)] = { [name .. "-kit"] = true }
    end
    return entity
end
add(rail_type, "compatible-track", "track", true)
add(rail_type, "blocked-track", "vehicle", true)
add(rail_type, "unbuildable-track", "track", false)
add(stock_type, "first-engine", "vehicle", true)
add(stock_type, "second-engine", "vehicle", true)
local groups, by_entity = requirements.groups(entities, buildables)
assert(by_entity["first-engine"] == by_entity["second-engine"], "duplicate requirements should share a group")
local tracks = groups[by_entity["first-engine"]]
assert(#tracks == 1 and tracks[1] == "compatible-track", "only compatible buildable rails satisfy placement")
entities["compatible-track"] = nil
local empty_groups, empty_by_entity = requirements.groups(entities, buildables)
assert(#empty_groups[empty_by_entity["first-engine"]] == 0, "no rails must leave an unsatisfied OR, not a free requirement")
print("ok - compatible buildable rails are grouped and absent rails cannot satisfy placement")
