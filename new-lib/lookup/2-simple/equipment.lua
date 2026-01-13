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

-- Maps equipment names to items that place them
-- equipment_name -> { item_name -> true }
stage.equipment_to_items = function()
    local equipment_to_items = {}

    for equip_name, _ in pairs(lu.equipment) do
        equipment_to_items[equip_name] = {}
    end

    for item_name, item in pairs(lu.items) do
        if item.place_as_equipment_result ~= nil then
            local equip_name = item.place_as_equipment_result
            if equipment_to_items[equip_name] ~= nil then
                equipment_to_items[equip_name][item_name] = true
            end
        end
    end

    lu.equipment_to_items = equipment_to_items
end

-- Maps equipment categories to grids that support them
stage.category_to_grids = function()
    local category_to_grids = {}

    for _, grid in pairs(prots("equipment-grid")) do
        for _, cat in pairs(grid.equipment_categories) do
            if category_to_grids[cat] == nil then
                category_to_grids[cat] = {}
            end
            category_to_grids[cat][grid.name] = true
        end
    end

    lu.category_to_grids = category_to_grids
end

stage.equipment_grid_sources = function()
    local equipment_grid_sources = {}

    local function add_grid_source(grid_name, source_name, source_type)
        local grid = data.raw["equipment-grid"][grid_name]
        if grid ~= nil and grid.equipment_categories ~= nil then
            for _, cat in pairs(grid.equipment_categories) do
                if equipment_grid_sources[cat] == nil then
                    equipment_grid_sources[cat] = {}
                end
                equipment_grid_sources[cat][source_name] = source_type
            end
        end
    end

    for _, armor in pairs(prots("armor")) do
        if armor.equipment_grid ~= nil then
            add_grid_source(armor.equipment_grid, armor.name, "armor")
        end
    end

    for _, vehicle_class in pairs(categories.vehicles_with_grids) do
        for _, vehicle in pairs(prots(vehicle_class)) do
            if lu.entities[vehicle.name] ~= nil and vehicle.equipment_grid ~= nil then
                add_grid_source(vehicle.equipment_grid, vehicle.name, "vehicle")
            end
        end
    end

    lu.equipment_grid_sources = equipment_grid_sources
end

-- Maps grid names to armors/vehicles that have them
-- grid_name -> { source_name -> source_type }
stage.grid_to_sources = function()
    local grid_to_sources = {}

    for _, grid in pairs(prots("equipment-grid")) do
        grid_to_sources[grid.name] = {}
    end

    for _, armor in pairs(prots("armor")) do
        if armor.equipment_grid ~= nil then
            if grid_to_sources[armor.equipment_grid] ~= nil then
                grid_to_sources[armor.equipment_grid][armor.name] = "armor"
            end
        end
    end

    for _, vehicle_class in pairs(categories.vehicles_with_grids) do
        for _, vehicle in pairs(prots(vehicle_class)) do
            if lu.entities[vehicle.name] ~= nil and vehicle.equipment_grid ~= nil then
                if grid_to_sources[vehicle.equipment_grid] ~= nil then
                    grid_to_sources[vehicle.equipment_grid][vehicle.name] = "vehicle"
                end
            end
        end
    end

    lu.grid_to_sources = grid_to_sources
end

-- Maps grids to power-producing equipment that can go in them
-- grid_name -> { equip_name -> true }
stage.grid_power_sources = function()
    local grid_power_sources = {}

    for _, grid in pairs(prots("equipment-grid")) do
        grid_power_sources[grid.name] = {}

        local grid_cats = {}
        for _, cat in pairs(grid.equipment_categories) do
            grid_cats[cat] = true
        end

        for equip_name, equip in pairs(lu.equipment) do
            if categories.equipment_power_producers[equip.type] then
                local equip_cats = equip.categories or {}
                for _, cat in pairs(equip_cats) do
                    if grid_cats[cat] then
                        grid_power_sources[grid.name][equip_name] = true
                        break
                    end
                end
            end
        end
    end

    lu.grid_power_sources = grid_power_sources
end

return stage