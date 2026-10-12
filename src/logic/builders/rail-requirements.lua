-- Share rolling stock's rail prerequisites when the same buildable rails fit.
local collision_mask_util = require("__core__/lualib/collision-mask-util")
local categories = require("src/prototypes/categories")
local gutils = require("src/lib/graph/graph-utils")

local rail_requirements = {}

rail_requirements.groups = function(entities, buildables)
    local rails = {}
    for _, entity in pairs(entities) do
        if categories.rail[entity.type] == true and buildables[gutils.key(entity)] ~= nil then
            rails[#rails + 1] = entity
        end
    end
    local groups = {}
    local by_entity = {}
    for _, entity in pairs(entities) do
        if categories.rolling_stock[entity.type] == true and buildables[gutils.key(entity)] ~= nil then
            local compatible = {}
            local mask = collision_mask_util.get_mask(entity)
            for _, rail in pairs(rails) do
                if not collision_mask_util.masks_collide(mask, collision_mask_util.get_mask(rail)) then
                    compatible[#compatible + 1] = rail.name
                end
            end
            table.sort(compatible)
            local group = gutils.concat(compatible)
            groups[group] = compatible
            by_entity[entity.name] = group
        end
    end
    return groups, by_entity
end

return rail_requirements
