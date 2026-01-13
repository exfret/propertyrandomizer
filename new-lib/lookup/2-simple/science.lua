-- Maintenance-wise, it's easiest to keep this exact header for all stage 2 lookups, even if not all these are used
-- START repeated header

local collision_mask_util
if not offline then
    collision_mask_util = require("__core__/lualib/collision-mask-util")
else
    collision_mask_util = require("offline/lualib/collision-mask-util")
end

local categories = require("helper-tables/categories")
local gutils = require("new-lib/graph/graph-utils")
local lutils = require("new-lib/logic/logic-utils")
local dutils = require("new-lib/data-utils")
local tutils = require("lib/trigger")

local prots = dutils.prots

local stage = {}

local lu
stage.link = function(lu_to_link)
    lu = lu_to_link
end

-- END repeated header

-- Get science pack sets (collection of science packs that appear together in a tech)
stage.science_sets = function()
    local science_sets = {}

    for _, tech in pairs(lu.techs) do
        if tech.unit ~= nil then
            local set = {}
            for _, ing in pairs(tech.unit.ingredients) do
                table.insert(set, ing[1])
            end
            table.sort(set)
            science_sets[gutils.concat(set)] = set
        end
    end

    lu.science_sets = science_sets
end

-- Technologies that unlock the ability to send starter packs to space
stage.space_platform_unlock_techs = function()
    local space_platform_unlock_techs = {}

    for _, tech in pairs(lu.techs) do
        if tech.effects ~= nil then
            for _, effect in pairs(tech.effects) do
                if effect.type == "unlock-space-platforms" and effect.modifier then
                    space_platform_unlock_techs[tech.name] = true
                end
            end
        end
    end

    lu.space_platform_unlock_techs = space_platform_unlock_techs
end

-- Maps recipe names to technologies that unlock them
stage.recipe_to_techs = function()
    local recipe_to_techs = {}

    for _, tech in pairs(lu.techs) do
        if tech.effects ~= nil then
            for _, effect in pairs(tech.effects) do
                if effect.type == "unlock-recipe" then
                    if recipe_to_techs[effect.recipe] == nil then
                        recipe_to_techs[effect.recipe] = {}
                    end
                    recipe_to_techs[effect.recipe][tech.name] = true
                end
            end
        end
    end

    lu.recipe_to_techs = recipe_to_techs
end

stage.space_location_to_discovery_techs = function()
    local space_location_to_discovery_techs = {}

    for _, tech in pairs(lu.techs) do
        if tech.effects ~= nil then
            for _, effect in pairs(tech.effects) do
                if effect.type == "unlock-space-location" then
                    local loc_name = effect.space_location
                    if space_location_to_discovery_techs[loc_name] == nil then
                        space_location_to_discovery_techs[loc_name] = {}
                    end
                    space_location_to_discovery_techs[loc_name][tech.name] = true
                end
            end
        end
    end

    lu.space_location_to_discovery_techs = space_location_to_discovery_techs
end

return stage