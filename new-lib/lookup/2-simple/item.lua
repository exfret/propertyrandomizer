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

-- Reverse map: item -> items that spoil into it
stage.spoil_result_to_items = function()
    local spoil_result_to_items = {}

    for _, item in pairs(lu.items) do
        if item.spoil_result ~= nil and item.spoil_result ~= "" then
            if spoil_result_to_items[item.spoil_result] == nil then
                spoil_result_to_items[item.spoil_result] = {}
            end
            spoil_result_to_items[item.spoil_result][item.name] = true
        end
    end

    lu.spoil_result_to_items = spoil_result_to_items
end

-- Reverse map: item -> fuels that burn into it
stage.burnt_result_to_items = function()
    local burnt_result_to_items = {}

    for _, item in pairs(lu.items) do
        if item.burnt_result ~= nil and item.burnt_result ~= "" then
            if burnt_result_to_items[item.burnt_result] == nil then
                burnt_result_to_items[item.burnt_result] = {}
            end
            burnt_result_to_items[item.burnt_result][item.name] = true
        end
    end

    lu.burnt_result_to_items = burnt_result_to_items
end

return stage