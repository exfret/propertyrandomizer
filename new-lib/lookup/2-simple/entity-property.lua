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

stage.entity_collision_groups = function()
    local entity_collision_groups = {}
    local entity_collision_group_to_layers = {}
    local entity_to_collision_group = {}

    for _, entity in pairs(lu.entities) do
        local collision_layers = {}
        local collision_mask = entity.collision_mask or collision_mask_util.get_default_mask(entity.type)
        for layer, _ in pairs(collision_mask.layers) do
            table.insert(collision_layers, layer)
        end
        table.sort(collision_layers)
        local layers_key = gutils.concat(collision_layers)
        if entity_collision_groups[layers_key] == nil then
            entity_collision_groups[layers_key] = {}
        end
        if entity_collision_group_to_layers[layers_key] == nil then
            entity_collision_group_to_layers[layers_key] = collision_mask.layers
        end
        entity_collision_groups[layers_key][entity.name] = true
        entity_to_collision_group[entity.name] = layers_key
    end

    lu.entity_collision_groups = entity_collision_groups
    lu.entity_collision_group_to_layers = entity_collision_group_to_layers
    lu.entity_to_collision_group = entity_to_collision_group
end

-- Maps items to entities that drop them as loot
stage.loot_to_entities = function()
    local loot_to_entities = {}

    for _, entity in pairs(lu.entities) do
        if entity.loot ~= nil then
            for _, loot_entry in pairs(entity.loot) do
                local item_name = loot_entry.item
                if item_name ~= nil then
                    if loot_to_entities[item_name] == nil then
                        loot_to_entities[item_name] = {}
                    end
                    loot_to_entities[item_name][entity.name] = true
                end
            end
        end
    end

    lu.loot_to_entities = loot_to_entities
end

-- Maps entities to their output fluid (boilers, fusion-reactors, fusion-generators)
stage.entity_output_fluids = function()
    local entity_output_fluids = {}

    for _, entity in pairs(lu.entities) do
        local output_fluid = nil

        if entity.type == "boiler" then
            if entity.output_fluid_box ~= nil and entity.output_fluid_box.filter ~= nil then
                local input_filter = entity.fluid_box and entity.fluid_box.filter
                if entity.output_fluid_box.filter ~= input_filter then
                    output_fluid = entity.output_fluid_box.filter
                end
            end
        elseif entity.type == "fusion-reactor" then
            if entity.output_fluid_box ~= nil and entity.output_fluid_box.filter ~= nil then
                output_fluid = entity.output_fluid_box.filter
            end
        elseif entity.type == "fusion-generator" then
            if entity.output_fluid_box ~= nil and entity.output_fluid_box.filter ~= nil then
                output_fluid = entity.output_fluid_box.filter
            end
        end

        if output_fluid ~= nil then
            entity_output_fluids[entity.name] = output_fluid
        end
    end

    lu.entity_output_fluids = entity_output_fluids
end

-- Get a list of entities that are probably operable
stage.operable_entities = function()
    local operable_entities = {}

    for _, entity in pairs(lu.entities) do
        if entity.flags ~= nil then
            for _, flag in pairs(entity.flags) do
                if flag == "player-creation" or flag == "placeable-player" then
                    operable_entities[entity.name] = true
                end
            end
        end
        if entity.type == "character" then
            operable_entities[entity.name] = true
        end
    end

    lu.operable_entities = operable_entities
end

return stage