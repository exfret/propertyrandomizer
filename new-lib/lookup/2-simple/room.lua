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

-- Maps space connections to asteroid entities that spawn on them
-- connection_name -> { asteroid_name -> true }
stage.connection_asteroids = function()
    local connection_asteroids = {}

    for _, conn in pairs(prots("space-connection")) do
        connection_asteroids[conn.name] = {}

        if conn.asteroid_spawn_definitions ~= nil then
            for _, spawn in pairs(conn.asteroid_spawn_definitions) do
                local asteroid_name
                if spawn.asteroid ~= nil then
                    asteroid_name = spawn.asteroid
                elseif spawn[1] ~= nil then
                    asteroid_name = spawn[1]
                end
                if asteroid_name ~= nil and lu.entities[asteroid_name] ~= nil then
                    connection_asteroids[conn.name][asteroid_name] = true
                end
            end
        end
    end

    lu.connection_asteroids = connection_asteroids
end

-- Where asteroids/asteroid chunks spawn
stage.asteroid_to_place = function()
    local asteroid_to_place = {}

    for place_key, place in pairs(lu.space_places) do
        local space_prot = data.raw[place.type][place.name]
        if space_prot.asteroid_spawn_definitions ~= nil then
            for _, spawn in pairs(space_prot.asteroid_spawn_definitions) do
                local spawned_thing
                if spawn[1] == nil then
                    spawned_thing = gutils.key({type = spawn.type or "entity", name = spawn.asteroid})
                else
                    spawned_thing = gutils.key({type = "entity", name = spawn[1]})
                end
                if asteroid_to_place[spawned_thing] == nil then
                    asteroid_to_place[spawned_thing] = {}
                end
                asteroid_to_place[spawned_thing][place_key] = place
            end
        end
    end

    lu.asteroid_to_place = asteroid_to_place
end

-- Maps space-locations to the space-connections that touch them
-- space_location_name -> { connection_name -> "from" | "to" }
stage.space_location_to_connections = function()
    local space_location_to_connections = {}

    for _, conn in pairs(prots("space-connection")) do
        for _, endpoint in pairs({"from", "to"}) do
            local loc_name = conn[endpoint]
            if space_location_to_connections[loc_name] == nil then
                space_location_to_connections[loc_name] = {}
            end
            space_location_to_connections[loc_name][conn.name] = endpoint
        end
    end

    lu.space_location_to_connections = space_location_to_connections
end

-- Maps surface prototypes to starter packs that create them
-- surface_name -> { item_name -> true }
stage.surface_to_starter_packs = function()
    local surface_to_starter_packs = {}

    for _, item in pairs(prots("space-platform-starter-pack")) do
        if item.surface ~= nil then
            if surface_to_starter_packs[item.surface] == nil then
                surface_to_starter_packs[item.surface] = {}
            end
            surface_to_starter_packs[item.surface][item.name] = true
        end
    end

    lu.surface_to_starter_packs = surface_to_starter_packs
end

stage.autoplace_control_to_prots = function()
    local control_to_prots = {
        tile = {},
        entity = {},
    }

    -- Tiles: O(tiles)
    for _, tile in pairs(prots("tile")) do
        if tile.autoplace ~= nil and tile.autoplace.control ~= nil then
            local ctrl = tile.autoplace.control
            if control_to_prots.tile[ctrl] == nil then
                control_to_prots.tile[ctrl] = {}
            end
            control_to_prots.tile[ctrl][tile.name] = true
        end
    end

    -- Entities: O(entities) - iterate all entity classes
    for _, entity in pairs(lu.entities) do
        if entity.autoplace ~= nil and entity.autoplace.control ~= nil then
            local ctrl = entity.autoplace.control
            if control_to_prots.entity[ctrl] == nil then
                control_to_prots.entity[ctrl] = {}
            end
            control_to_prots.entity[ctrl][entity.name] = true
        end
    end

    lu.autoplace_control_to_prots = control_to_prots
end

return stage