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

stage.fcat_to_items = function()
    local fcat_to_items = {}

    for _, item in pairs(lu.items) do
        if item.fuel_category ~= nil and item.fuel_value ~= nil and util.parse_energy(item.fuel_value) > 0 then
            local burnt = 0
            if item.burnt_result ~= nil and item.burnt_result ~= "" then
                burnt = 1
            end
            local fcat_key = gutils.concat({item.fuel_category, burnt})
            if fcat_to_items[fcat_key] == nil then
                fcat_to_items[fcat_key] = {}
            end
            fcat_to_items[fcat_key][item.name] = true
        end
    end

    lu.fcat_to_items = fcat_to_items
end

-- Combinations of fuel categories and burnt inventory size
stage.fcat_combos = function()
    local fcat_combos = {}

    for _, entity in pairs(lu.entities) do
        if categories.energy_sources_input[entity.type] ~= nil then
            for _, energy_prop in pairs(dutils.tablize(categories.energy_sources_input[entity.type])) do
                local energy_source = entity[energy_prop]
                if energy_source ~= nil and energy_source.type == "burner" then
                    local burnt = 0
                    if energy_source.burnt_inventory_size ~= nil and energy_source.burnt_inventory_size > 0 then
                        burnt = 1
                    end
                    fcat_combos[lutils.fcat_combo_name(energy_source)] = {
                        fuel = energy_source.fuel_categories or {"chemical"},
                        burnt = burnt,
                    }
                end
            end
        end
    end

    lu.fcat_combos = fcat_combos
end

-- Maps fuel_category to burner entities that have burnt_inventory_size > 0
stage.fcat_to_burners = function()
    local fcat_to_burners = {}

    for _, entity in pairs(lu.entities) do
        if categories.energy_sources_input[entity.type] ~= nil then
            for _, energy_prop in pairs(dutils.tablize(categories.energy_sources_input[entity.type])) do
                local energy_source = entity[energy_prop]
                if energy_source ~= nil and energy_source.type == "burner" then
                    if energy_source.burnt_inventory_size ~= nil and energy_source.burnt_inventory_size > 0 then
                        local fuel_cats = energy_source.fuel_categories or {"chemical"}
                        for _, fcat in pairs(fuel_cats) do
                            if fcat_to_burners[fcat] == nil then
                                fcat_to_burners[fcat] = {}
                            end
                            fcat_to_burners[fcat][entity.name] = true
                        end
                    end
                end
            end
        end
    end

    lu.fcat_to_burners = fcat_to_burners
end

return stage