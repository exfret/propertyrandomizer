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

-- Tiles grouped by collision layers
stage.tile_collision_groups = function()
    local tile_collision_groups = {}
    local tile_collision_group_to_layers = {}

    for _, tile in pairs(prots("tile")) do
        local collision_layers = {}
        for layer, _ in pairs(tile.collision_mask.layers) do
            table.insert(collision_layers, layer)
        end
        table.sort(collision_layers)
        local layers_key = gutils.concat(collision_layers)
        if tile_collision_groups[layers_key] == nil then
            tile_collision_groups[layers_key] = {}
        end
        if tile_collision_group_to_layers[layers_key] == nil then
            tile_collision_group_to_layers[layers_key] = tile.collision_mask.layers
        end
        tile_collision_groups[layers_key][tile.name] = true
    end

    lu.tile_collision_groups = tile_collision_groups
    lu.tile_collision_group_to_layers = tile_collision_group_to_layers
end

-- Maps tiles to items that can place them
stage.place_as_tile_items = function()
    local place_as_tile_items = {}

    for _, item in pairs(lu.items) do
        if item.place_as_tile ~= nil then
            local tile_name = item.place_as_tile.result
            if place_as_tile_items[tile_name] == nil then
                place_as_tile_items[tile_name] = {}
            end

            local condition_info = {}

            if item.place_as_tile.condition ~= nil and item.place_as_tile.condition.layers ~= nil then
                condition_info.blocking_layers = item.place_as_tile.condition.layers
            end

            if item.place_as_tile.tile_condition ~= nil then
                condition_info.whitelist = {}
                for _, allowed_tile in pairs(item.place_as_tile.tile_condition) do
                    condition_info.whitelist[allowed_tile] = true
                end
            end

            place_as_tile_items[tile_name][item.name] = condition_info
        end
    end

    lu.place_as_tile_items = place_as_tile_items
end

-- Maps fluids to tiles that have them
stage.fluid_to_tiles = function()
    local fluid_to_tiles = {}

    for _, tile in pairs(prots("tile")) do
        if tile.fluid ~= nil then
            if fluid_to_tiles[tile.fluid] == nil then
                fluid_to_tiles[tile.fluid] = {}
            end
            fluid_to_tiles[tile.fluid][tile.name] = true
        end
    end

    lu.fluid_to_tiles = fluid_to_tiles
end

-- Maps fluids to offshore pumps that have a filter for that fluid
-- These pumps always produce this fluid regardless of tile
stage.pumps_with_filter = function()
    local pumps_with_filter = {}

    for _, pump in pairs(prots("offshore-pump")) do
        if pump.fluid_box.filter ~= nil then
            local fluid_name = pump.fluid_box.filter
            if pumps_with_filter[fluid_name] == nil then
                pumps_with_filter[fluid_name] = {}
            end
            pumps_with_filter[fluid_name][pump.name] = true
        end
    end

    lu.pumps_with_filter = pumps_with_filter
end

-- Maps tiles (with fluid) to offshore pumps that can pump from them
-- Excludes pumps with filter (they don't necessarily pump the same fluid as what's in the tile)
stage.tile_valid_pumps = function()
    local tile_valid_pumps = {}

    -- Only check tiles that have fluids
    for _, tile in pairs(prots("tile")) do
        if tile.fluid ~= nil then
            tile_valid_pumps[tile.name] = {}

            for _, pump in pairs(prots("offshore-pump")) do
                if pump.fluid_box.filter == nil then
                    local pump_mask = pump.collision_mask or collision_mask_util.get_default_mask("offshore-pump")
                    if not collision_mask_util.masks_collide(tile.collision_mask, pump_mask) then
                        tile_valid_pumps[tile.name][pump.name] = true
                    end
                end
            end
        end
    end

    lu.tile_valid_pumps = tile_valid_pumps
end

-- Maps rooms to tiles and tiles to rooms (bidirectional)
stage.room_tile_maps = function()
    local room_tiles = {}
    local tiles_to_rooms = {}

    -- Initialize tiles_to_rooms for all tiles
    for _, tile in pairs(prots("tile")) do
        tiles_to_rooms[tile.name] = {}
    end

    local function get_room_tiles(room)
        local results = {}

        if room.type == "planet" then
            local planet = data.raw.planet[room.name]

            if planet.map_gen_settings ~= nil then
                local map_gen_settings = planet.map_gen_settings

                -- Check autoplace_settings
                if map_gen_settings.autoplace_settings ~= nil then
                    local autoplace_settings = map_gen_settings.autoplace_settings["tile"]

                    if autoplace_settings ~= nil and autoplace_settings.settings ~= nil then
                        for prot_name, _ in pairs(autoplace_settings.settings) do
                            local prot_data = dutils.get_prot("tile", prot_name)
                            if prot_data ~= nil then
                                if autoplace_settings.treat_missing_as_default or prot_data.autoplace ~= nil then
                                    results[prot_name] = true
                                end
                            end
                        end
                    end
                end

                if map_gen_settings.autoplace_controls ~= nil then
                    local control_map = lu.autoplace_control_to_prots["tile"]
                    for control, _ in pairs(map_gen_settings.autoplace_controls) do
                        if control_map[control] ~= nil then
                            for prot_name, _ in pairs(control_map[control]) do
                                results[prot_name] = true
                            end
                        end
                    end
                end
            end
        end

        return results
    end

    -- Build room_tiles, then invert for tiles_to_rooms
    for room_key, room in pairs(lu.rooms) do
        room_tiles[room_key] = get_room_tiles(room)

        for tile_name, _ in pairs(room_tiles[room_key]) do
            tiles_to_rooms[tile_name][room_key] = true
        end
    end

    lu.room_tiles = room_tiles
    lu.tiles_to_rooms = tiles_to_rooms
end

return stage