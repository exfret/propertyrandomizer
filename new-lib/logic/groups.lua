-- Node groups for the dependency graph
-- These represent collection of things that satsify a common game mechanic like inserters

local collision_mask_util
if not offline then
    collision_mask_util = require("__core__/lualib/collision-mask-util")
else
    collision_mask_util = require("offline/lualib/collision-mask-util")
end

local lib_name = "new-lib"
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
local set_class = builder.set_class
local set_prot = builder.set_prot

local groups = {}

function groups.build(lu)
    -- Group nodes don't care about abilities contexts
    local group_abilities = {
        [1] = true,
        [2] = true,
    }

    set_class("groups")
    set_prot(nil)

    ----------------------------------------
    add_node("group-crafting-automation", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we operate an assembling machine with crafting as a category?

    for _, machine in pairs(prots("assembling-machine")) do
        -- Check this can mine basic-solid
        local valid = false
        for _, cat in pairs(machine.crafting_categories) do
            if cat == "crafting" then
                valid = true
            end
        end
        if valid then
            add_edge("entity-operate", machine.name, {
                abilities = table.deepcopy(group_abilities),
            })
        end
    end

    ----------------------------------------
    add_node("group-construction-robot", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we use a construction robot?

    for _, bot in pairs(prots("construction-robot")) do
        add_edge("entity-operate", bot.name, {
            abilities = table.deepcopy(group_abilities),
        })
    end

    ----------------------------------------
    add_node("group-electric-mining-drill", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we have access some electric-powered mining drill?
    -- This is pretty opinion-based, but I just like them not being too late since burner mining drills just get such bad rolls a lot

    for _, drill in pairs(prots("mining-drill")) do
        -- Check this can mine basic-solid
        local valid = false
        for _, cat in pairs(drill.resource_categories) do
            if cat == "basic-solid" then
                valid = true
            end
        end
        if not (drill.energy_source.type == "void" or drill.energy_source.type == "electric") then
            valid = false
        end
        if valid then
            add_edge("entity-operate", drill.name, {
                abilities = table.deepcopy(group_abilities),
            })
        end
    end

    ----------------------------------------
    add_node("balance-gun-turret", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we use a gun turret?

    for turret_class, _ in pairs(categories.turrets) do
        for _, turret in pairs(prots(turret_class)) do
            add_edge("entity-operate", turret.name, {
                abilities = table.deepcopy(group_abilities),
            })
        end
    end

    ----------------------------------------
    add_node("group-inserter", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we operate some inserter?

    for _, inserter in pairs(prots("inserter")) do
        add_edge("entity-operate", inserter.name, {
            abilities = table.deepcopy(group_abilities),
        })
    end

    ----------------------------------------
    add_node("group-logistic-storage-chest", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we operate some logistic storage chest?
    -- This is enough for pretty much all logistic needs.

    for _, chest in pairs(prots("logistic-container")) do
        if chest.logistic_mode == "storage" then
            add_edge("entity-operate", chest.name, {
                abilities = table.deepcopy(group_abilities),
            })
        end
    end

    ----------------------------------------
    add_node("group-mining-drill", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we have access some mining drill?

    for _, drill in pairs(prots("mining-drill")) do
        -- Check this can mine basic-solid
        local valid = false
        for _, cat in pairs(drill.resource_categories) do
            if cat == "basic-solid" then
                valid = true
            end
        end
        if valid then
            add_edge("entity-operate", drill.name, {
                abilities = table.deepcopy(group_abilities),
            })
        end
    end

    ----------------------------------------
    add_node("group-pump", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we use a pump

    for _, pump in pairs(data.raw.pump) do
        add_edge("entity-operate", pump.name, {
            abilities = table.deepcopy(group_abilities),
        })
    end

    ----------------------------------------
    add_node("group-repair-pack", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we get some sort of repair pack?

    for _, pack in pairs(data.raw["repair-tool"]) do
        add_edge("item", pack.name, {
            abilities = table.deepcopy(group_abilities),
        })
    end

    ----------------------------------------
    add_node("group-roboport", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we use a roboport?

    for _, roboport in pairs(prots("roboport")) do
        add_edge("entity-operate", roboport.name, {
            abilities = table.deepcopy(group_abilities),
        })
    end

    ----------------------------------------
    add_node("group-splitter", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we use some sort of splitter?

    for _, belt in pairs(prots("splitter")) do
        add_edge("entity-operate", belt.name, {
            abilities = table.deepcopy(group_abilities),
        })
    end

    ----------------------------------------
    add_node("group-starter-ammo", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we use ammo that works with a reasonable gun?
    
    for _, ammo in pairs(prots("ammo")) do
        if ammo.ammo_category == "bullet" then
            add_edge("item", ammo.name, {
                abilities = table.deepcopy(group_abilities),
            })
        end
    end

    ----------------------------------------
    add_node("group-storage", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we get some sort of storage

    for _, container in pairs(prots("container")) do
        add_edge("entity-operate", container.name, {
            abilities = table.deepcopy(group_abilities),
        })
    end

    ----------------------------------------
    add_node("group-transport-belt", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we operate some transport belt?
    -- Doesn't count splitters/underground belts/etc., must be a bona fide belt!

    for _, belt in pairs(data.raw["transport-belt"]) do
        add_edge("entity-operate", belt.name, {
            abilities = table.deepcopy(group_abilities),
        })
    end

    ----------------------------------------
    add_node("group-underground-belt", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we use some sort of underground belt?

    for _, belt in pairs(prots("underground-belt")) do
        add_edge("entity-operate", belt.name, {
            abilities = table.deepcopy(group_abilities),
        })
    end

    if mods["space-age"] then
        ----------------------------------------
        add_node("group-rocket-turret", "OR", nil, "", { mechanic = true })
        ----------------------------------------
        -- Can we get the rocket turret?
        -- TODO: Test more generally, don't just hardcode to spage's specfic turret

        add_edge("entity-operate", "rocket-turret", {
            abilities = table.deepcopy(group_abilities),
        })

        ----------------------------------------
        add_node("balance-rocket", "OR", nil, "", { mechanic = true })
        ----------------------------------------
        -- Can we get ammo for the rocket turret?

        for _, ammo in pairs(data.raw.ammo) do
            if ammo.ammo_category == "rocket" then
                add_edge("item", ammo.name, {
                    abilities = table.deepcopy(group_abilities),
                })
            end
        end
    end
end

return groups