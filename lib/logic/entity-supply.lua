-- Supply mechanics for entity randomization, built only when it's on so other randomizations' baselines don't move
-- For each class of entity a base needs in bulk (acquisition.bulk_entity_types), group-supply is an OR over its members' entity-build-item nodes, with no abilities on the edges
-- As a mechanic its contexts are protected (rooms and automatability, see protection.lua), so some member of each class stays suppliable automatically wherever vanilla had one
-- That lets single members (like express belts) be farm-only, while belts as a whole never are

local lib_name = "lib"
local acquisition = require(lib_name .. "/logic/acquisition")
local gutils = require(lib_name .. "/graph/graph-utils")
local builder = require(lib_name .. "/logic/builder")

local key = gutils.key
local add_node = builder.add_node
local add_edge = builder.add_edge
local set_class = builder.set_class
local set_prot = builder.set_prot

local entity_supply = {}

entity_supply.build = function(lu)
    set_class("entity-supply")
    set_prot(nil)

    -- Class --> its members that can be built, in name order so the graph is the same every time
    local members = {}
    for _, entity in pairs(lu.entities) do
        if acquisition.bulk_entity_types[entity.type] ~= nil and lu.buildables[key(entity)] ~= nil then
            members[entity.type] = members[entity.type] or {}
            table.insert(members[entity.type], entity.name)
        end
    end
    local classes = {}
    for class, _ in pairs(members) do
        table.insert(classes, class)
    end
    table.sort(classes)

    for _, class in pairs(classes) do
        ----------------------------------------
        add_node("group-supply", "OR", nil, class, { mechanic = true })
        ----------------------------------------
        -- Can we get some entity of this class to build?

        table.sort(members[class])
        for _, entity_name in pairs(members[class]) do
            add_edge("entity-build-item", entity_name)
        end
    end
end

return entity_supply
