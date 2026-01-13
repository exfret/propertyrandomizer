local categories = require("helper-tables/categories")
local gutils = require("new-lib/graph/graph-utils")
local dutils = require("new-lib/data-utils")

local prots = dutils.prots

local stage = {}

local lu
stage.link = function(lu_to_link)
    lu = lu_to_link
end

-- Rooms are places that you can be (planets and surfaces)
stage.rooms = function()
    local rooms = {}

    for _, class in pairs({"planet", "surface"}) do
        for prot_name, prot in pairs(prots(class)) do
            rooms[gutils.key(prot)] = {
                type = class,
                name = prot_name,
            }
        end
    end

    lu.rooms = rooms
end

-- Space places are places that a surface (the prototype) can be
stage.space_places = function()
    local space_places = {}

    for class, _ in pairs(defines.prototypes["space-location"]) do
        for _, location in pairs(prots(class)) do
            space_places[gutils.key(location)] = {
                type = location.type,
                name = location.name,
            }
        end
    end
    for _, conn in pairs(prots("space-connection")) do
        space_places[gutils.key(conn)] = {
            type = conn.type,
            name = conn.name,
        }
    end

    lu.space_places = space_places
end

-- Note: Only gets "relevant" entities for logic; filters corpses without minable and explosions
stage.entities = function()
    local entities = {}

    for class, _ in pairs(defines.prototypes.entity) do
        if class ~= "explosion" and class ~= "smoke-with-trigger" then
            for _, entity in pairs(prots(class)) do
                -- Check only minable corpses
                if not categories.corpse[entity.type] or entity.minable ~= nil then
                    entities[entity.name] = entity
                end
            end
        end
    end

    lu.entities = entities
end

stage.items = function()
    local items = {}

    for class, _ in pairs(defines.prototypes.item) do
        for _, item in pairs(prots(class)) do
            items[item.name] = item
        end
    end

    lu.items = items
end

stage.equipment = function()
    local equipment = {}

    for class, _ in pairs(defines.prototypes.equipment) do
        for _, prot in pairs(prots(class)) do
            equipment[prot.name] = prot
        end
    end

    lu.equipment = equipment
end

stage.fluids = function()
    local fluids = {}

    for _, fluid in pairs(prots("fluid")) do
        fluids[fluid.name] = fluid
    end

    lu.fluids = fluids
end

-- All recipes (including hidden for recycling compatibility)
stage.recipes = function()
    local recipes = {}

    for _, recipe in pairs(prots("recipe")) do
        recipes[recipe.name] = recipe
    end

    lu.recipes = recipes
end

-- Non-hidden technologies
stage.techs = function()
    local techs = {}

    for _, tech in pairs(prots("technology")) do
        if not tech.hidden then
            techs[tech.name] = tech
        end
    end

    lu.techs = techs
end

return stage
