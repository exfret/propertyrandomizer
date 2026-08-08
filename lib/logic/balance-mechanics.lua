-- Builder file for nodes mostly used for balancing, like ensuring early enough inserters, etc.

local lib_name = "lib"
local categories = require("helper-tables/categories")
local dutils = require(lib_name .. "/data-utils")
local gutils = require(lib_name .. "/graph/graph-utils")
local lutils = require(lib_name .. "/logic/logic-utils")
local builder = require(lib_name .. "/logic/builder")

local prots = dutils.prots
local key = gutils.key
local concat = gutils.concat
local add_node = builder.add_node
local add_edge = builder.add_edge
local add_edge_reversed = builder.add_edge_reversed
local set_class = builder.set_class
local set_prot = builder.set_prot

local balance_mechanics = {}

balance_mechanics.build = function(lu)
    -- Balance nodes shouldn't affect abilities contexts
    -- To accomplish this, we have them add all
    local balance_abilities = {
        [1] = true,
        [2] = true,
    }

    set_class("balance-mechanics")
    set_prot(nil)

    ----------------------------------------
    add_node("balance-mechanics-mining-drill", "OR", nil, "", { mechanic = true, important = true })
    ----------------------------------------
    -- Do we have access to some solid-resource mining drill?

    for _, drill in pairs(data.raw["mining-drill"]) do
        -- Check this can mine basic-solid
        local valid = false
        for _, cat in pairs(drill.resource_categories) do
            if cat == "basic-solid" then
                valid = true
            end
        end
        if valid then
            add_edge("entity-operate", drill.name, {
                abilities = table.deepcopy(balance_abilities),
            })
        end
    end

    ----------------------------------------
    add_node("balance-mechanics-crafting-automation", "OR", nil, "", { mechanic = true, important = true })
    ----------------------------------------
    -- Can we operate an assembling machine with crafting as a category?

    for _, machine in pairs(data.raw["assembling-machine"]) do
        -- Check this can mine basic-solid
        local valid = false
        for _, cat in pairs(machine.crafting_categories) do
            if cat == "crafting" then
                valid = true
            end
        end
        if valid then
            add_edge("entity-operate", machine.name, {
                abilities = table.deepcopy(balance_abilities),
            })
        end
    end

    ----------------------------------------
    add_node("balance-mechanics-inserter", "OR", nil, "", { mechanic = true, important = true })
    ----------------------------------------
    -- Can we use some sort of inserter?

    for _, inserter in pairs(data.raw.inserter) do
        add_edge("entity-operate", inserter.name, {
            abilities = table.deepcopy(balance_abilities),
        })
    end

    ----------------------------------------
    add_node("balance-mechanics-transport-belt", "OR", nil, "", { mechanic = true, important = true })
    ----------------------------------------
    -- Can we use some sort of transport belt?

    for _, belt in pairs(data.raw["transport-belt"]) do
        add_edge("entity-operate", belt.name, {
            abilities = table.deepcopy(balance_abilities),
        })
    end

    ----------------------------------------
    add_node("balance-mechanics-underground-belt", "OR", nil, "", { mechanic = true, important = true })
    ----------------------------------------
    -- Can we use some sort of underground belt?

    for _, belt in pairs(data.raw["underground-belt"]) do
        add_edge("entity-operate", belt.name, {
            abilities = table.deepcopy(balance_abilities),
        })
    end

    ----------------------------------------
    add_node("balance-mechanics-splitter", "OR", nil, "", { mechanic = true, important = true })
    ----------------------------------------
    -- Can we use some sort of splitter?

    for _, belt in pairs(data.raw.splitter) do
        add_edge("entity-operate", belt.name, {
            abilities = table.deepcopy(balance_abilities),
        })
    end

    ----------------------------------------
    add_node("balance-mechanics-storage", "OR", nil, "", { mechanic = true, important = true })
    ----------------------------------------
    -- Can we get some sort of storage

    for _, container in pairs(data.raw.container) do
        add_edge("entity-operate", container.name, {
            abilities = table.deepcopy(balance_abilities),
        })
    end

    ----------------------------------------
    add_node("balance-mechanics-construction-robot", "OR", nil, "", { mechanic = true, important = true })
    ----------------------------------------
    -- Can we use a construction robot?

    for _, bot in pairs(data.raw["construction-robot"]) do
        add_edge("entity-operate", bot.name, {
            abilities = table.deepcopy(balance_abilities),
        })
    end

    ----------------------------------------
    add_node("balance-mechanics-roboport", "OR", nil, "", { mechanic = true, important = true })
    ----------------------------------------
    -- Can we use a roboport?

    for _, roboport in pairs(data.raw.roboport) do
        add_edge("entity-operate", roboport.name, {
            abilities = table.deepcopy(balance_abilities),
        })
    end

    ----------------------------------------
    add_node("balance-mechanics-logistic-storage", "OR", nil, "", { mechanic = true, important = true })
    ----------------------------------------
    -- Can we use a logistics storage chest?

    for _, chest in pairs(data.raw["logistic-container"]) do
        if chest.logistic_mode == "storage" then
            add_edge("entity-operate", chest.name, {
                abilities = table.deepcopy(balance_abilities),
            })
        end
    end

    ----------------------------------------
    add_node("balance-mechanics-pump", "OR", nil, "", { mechanic = true, important = true })
    ----------------------------------------
    -- Can we use a pump

    for _, pump in pairs(data.raw.pump) do
        add_edge("entity-operate", pump.name, {
            abilities = table.deepcopy(balance_abilities),
        })
    end

    ----------------------------------------
    add_node("balance-mechanics-no-big-electric-pole", "OR", nil, "", { mechanic = true, important = true })
    ----------------------------------------
    -- Can we not start with just big electric poles please and thank you

    for _, pole in pairs(data.raw["electric-pole"]) do
        if pole.name ~= "big-electric-pole" then
            add_edge("entity-operate", pole.name, {
                abilities = table.deepcopy(balance_abilities),
            })
        end
    end
end

return balance_mechanics