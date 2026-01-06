-- Balancing nodes for the dependency graph
-- These encode requirements that aren't strictly necessary for game completion,
-- but are needed to make the game pragmatically playable (like early automation).
-- Separating these from "real logic" allows for different difficulty modes.

local lib_name = "new-lib"
local categories = require("helper-tables/categories")
local dutils = require(lib_name .. "/data-utils")
local gutils = require(lib_name .. "/graph/graph-utils")
local lutils = require(lib_name .. "/logic/logic-utils")
local lu = require(lib_name .. "/logic/lookup/init")

local prots = dutils.prots
local key = gutils.key
local concat = gutils.concat

local logic_balancing = {}

-- Duplicated helpers from logic-group.lua
-- TODO: Refactor to share with logic-group.lua
local curr
local curr_class
local curr_prot

local function add_node(node_type, op, context, node_name, extra)
    extra = extra or {}

    if logic_balancing.type_info[node_type] == nil then
        logic_balancing.type_info[node_type] = {
            op = op,
            context = context,
            canonical = extra.canonical or node_type,
        }
    end

    extra.class = extra.class or curr_class
    if extra.prot == nil and curr_prot ~= nil then
        extra.prot = key(curr_prot)
    end
    node_name = node_name or ""
    curr = gutils.add_node(logic_balancing.graph, node_type, node_name, extra)
end

local function add_edge(start_type, start_name, extra)
    start_name = start_name or ""
    gutils.add_edge(logic_balancing.graph, key(start_type, start_name), key(curr), extra)
end

-- Helper to add a prereq edge from a balancing node to technologies
local function add_tech_prereq(balancing_type, balancing_name, condition_fn)
    for _, tech in pairs(lu.techs) do
        if condition_fn(tech) then
            local tech_key = key("technology", tech.name)
            local balancing_key = key(balancing_type, balancing_name or "")
            gutils.add_edge(logic_balancing.graph, balancing_key, tech_key)
        end
    end
end

-- Helper: check if tech has unit research (not trigger)
local function has_unit(tech)
    return tech.unit ~= nil
end

-- Helper: check tech science pack count
local function has_ingredients_over(tech, count)
    return tech.unit ~= nil and #tech.unit.ingredients > count
end

-- Helper: check tech research count
local function has_count_over(tech, count)
    return tech.unit ~= nil and (tech.unit.count_formula ~= nil or (tech.unit.count or 0) >= count)
end


logic_balancing.build = function(graph, type_info)
    logic_balancing.graph = graph
    logic_balancing.type_info = type_info

    ----------------------------------------------------------------------
    -- Balancing Nodes (migrated from build-graph-compat.lua)
    ----------------------------------------------------------------------
    -- These aggregate entity types and add prereqs to technologies

    curr_class = "balancing"

    ----------------------------------------
    add_node("transport-belt-canonical", "OR", nil, "", { canonical = "transport-belt-canonical" })
    ----------------------------------------
    -- Can we operate any transport belt?

    for _, belt in pairs(prots("transport-belt")) do
        add_edge("entity-operate", belt.name)
    end

    -- Add prereq to all unit techs
    add_tech_prereq("transport-belt-canonical", "", has_unit)

    ----------------------------------------
    add_node("underground-belt-canonical", "OR", nil, "", { canonical = "underground-belt-canonical" })
    ----------------------------------------
    -- Can we operate any underground belt?

    for _, belt in pairs(prots("underground-belt")) do
        add_edge("entity-operate", belt.name)
    end

    -- Add prereq to techs with count >= 50
    add_tech_prereq("underground-belt-canonical", "", function(tech)
        return has_count_over(tech, 50)
    end)

    ----------------------------------------
    add_node("splitter-canonical", "OR", nil, "", { canonical = "splitter-canonical" })
    ----------------------------------------
    -- Can we operate any splitter?

    for _, splitter in pairs(prots("splitter")) do
        add_edge("entity-operate", splitter.name)
    end

    -- Add prereq to techs with count >= 50
    add_tech_prereq("splitter-canonical", "", function(tech)
        return has_count_over(tech, 50)
    end)

    ----------------------------------------
    add_node("repair-pack-canonical", "OR", nil, "", { canonical = "repair-pack-canonical" })
    ----------------------------------------
    -- Can we get any repair tool?

    for _, tool in pairs(prots("repair-tool")) do
        add_edge("item", tool.name)
    end

    -- Add prereq to techs with >1 ingredient
    add_tech_prereq("repair-pack-canonical", "", function(tech)
        return has_ingredients_over(tech, 1)
    end)

    ----------------------------------------
    add_node("storage-canonical", "OR", nil, "", { canonical = "storage-canonical" })
    ----------------------------------------
    -- Can we operate any container?

    for _, container in pairs(prots("container")) do
        add_edge("entity-operate", container.name)
    end

    -- Add prereq to techs with >1 ingredient
    add_tech_prereq("storage-canonical", "", function(tech)
        return has_ingredients_over(tech, 1)
    end)

    ----------------------------------------
    add_node("pump-canonical", "OR", nil, "", { canonical = "pump-canonical" })
    ----------------------------------------
    -- Can we operate any pump?

    for _, pump in pairs(prots("pump")) do
        add_edge("entity-operate", pump.name)
    end

    -- Add prereq to techs with 3+ science pack types (mid-game)
    add_tech_prereq("pump-canonical", "", function(tech)
        return has_ingredients_over(tech, 2)
    end)

    ----------------------------------------
    add_node("construction-robot-canonical", "OR", nil, "", { canonical = "construction-robot-canonical" })
    ----------------------------------------
    -- Can we operate any construction robot?

    for _, robot in pairs(prots("construction-robot")) do
        add_edge("entity-operate", robot.name)
    end

    -- Add prereq to techs with 5+ science pack types (late-game)
    add_tech_prereq("construction-robot-canonical", "", function(tech)
        return has_ingredients_over(tech, 4)
    end)

    ----------------------------------------
    add_node("starter-gun-canonical", "OR", nil, "", { canonical = "starter-gun-canonical" })
    ----------------------------------------
    -- Can we get a gun that uses ammo? Find guns and vehicles with guns.

    -- Collect ammo categories from all guns
    local gun_ammo_cats = {}
    for _, gun in pairs(prots("gun")) do
        if gun.attack_parameters then
            local cat = gun.attack_parameters.ammo_category
            if cat then
                gun_ammo_cats[cat] = true
            end
            if gun.attack_parameters.ammo_categories then
                for _, c in pairs(gun.attack_parameters.ammo_categories) do
                    gun_ammo_cats[c] = true
                end
            end
        end
        add_edge("item", gun.name)
    end

    -- Add vehicles that have guns (cars, tanks, spidertrons)
    for _, car in pairs(prots("car")) do
        if car.guns then
            add_edge("entity-operate", car.name)
        end
    end
    for _, spider in pairs(prots("spider-vehicle")) do
        if spider.guns then
            add_edge("entity-operate", spider.name)
        end
    end

    ----------------------------------------
    add_node("starter-gun-ammo-canonical", "OR", nil, "", { canonical = "starter-gun-ammo-canonical" })
    ----------------------------------------
    -- Can we get ammo for any gun?

    for _, ammo in pairs(prots("ammo")) do
        if gun_ammo_cats[ammo.ammo_category] then
            add_edge("item", ammo.name)
        end
    end

    -- Add starter gun + ammo prereq to techs with multiple science packs or high count
    for _, tech in pairs(lu.techs) do
        if has_unit(tech) and (has_ingredients_over(tech, 1) or has_count_over(tech, 15)) then
            local tech_key = key("technology", tech.name)
            gutils.add_edge(logic_balancing.graph, key("starter-gun-canonical", ""), tech_key)
            gutils.add_edge(logic_balancing.graph, key("starter-gun-ammo-canonical", ""), tech_key)
        end
    end

    -- High-damage turrets and ammo (for space connections with dangerous asteroids)
    if mods["space-age"] then
        ----------------------------------------
        add_node("high-damage-turret-canonical", "OR", nil, "", { canonical = "high-damage-turret-canonical" })
        ----------------------------------------
        -- Find turrets that can deal high damage (for asteroids with high resistance)
        -- Look for turrets with large projectiles or high damage per shot

        local high_damage_ammo_cats = {}
        for _, ammo in pairs(prots("ammo")) do
            -- Check if ammo does significant damage (> 100 per action)
            if ammo.ammo_type and ammo.ammo_type.action then
                local actions = ammo.ammo_type.action
                if actions[1] == nil then actions = {actions} end
                for _, action in pairs(actions) do
                    if action.action_delivery and action.action_delivery.target_effects then
                        local effects = action.action_delivery.target_effects
                        if effects[1] == nil then effects = {effects} end
                        for _, effect in pairs(effects) do
                            if effect.type == "damage" and effect.damage and effect.damage.amount then
                                if effect.damage.amount > 100 then
                                    high_damage_ammo_cats[ammo.ammo_category] = true
                                end
                            end
                        end
                    end
                end
            end
        end

        for _, turret in pairs(prots("ammo-turret")) do
            if turret.attack_parameters then
                local cat = turret.attack_parameters.ammo_category
                if cat and high_damage_ammo_cats[cat] then
                    add_edge("entity-operate", turret.name)
                end
                if turret.attack_parameters.ammo_categories then
                    for _, c in pairs(turret.attack_parameters.ammo_categories) do
                        if high_damage_ammo_cats[c] then
                            add_edge("entity-operate", turret.name)
                            break
                        end
                    end
                end
            end
        end

        ----------------------------------------
        add_node("high-damage-ammo-canonical", "OR", nil, "", { canonical = "high-damage-ammo-canonical" })
        ----------------------------------------
        -- Can we get high-damage ammo?

        for _, ammo in pairs(prots("ammo")) do
            if high_damage_ammo_cats[ammo.ammo_category] then
                add_edge("item", ammo.name)
            end
        end

        -- Find space connections with dangerous asteroids (high health/resistance)
        -- and require high-damage weapons for them
        for _, conn in pairs(prots("space-connection")) do
            local needs_high_damage = false
            -- Check asteroid spawn definitions for high-health asteroids
            if conn.asteroid_spawn_definitions then
                for _, spawn_def in pairs(conn.asteroid_spawn_definitions) do
                    local chunk_name = spawn_def.asteroid
                    if chunk_name then
                        local chunk = prots("asteroid-chunk")[chunk_name]
                        if chunk and chunk.graphics_set and chunk.graphics_set.variations then
                            -- Large asteroids (huge) typically need high damage
                            -- Check minable.hardness or other properties
                        end
                    end
                end
            end
            -- Connections going to far planets typically have harder asteroids
            if conn.length and conn.length > 30000 then
                needs_high_damage = true
            end
            if needs_high_damage then
                local conn_key = key("space-connection", conn.name)
                gutils.add_edge(logic_balancing.graph, key("high-damage-turret-canonical", ""), conn_key)
                gutils.add_edge(logic_balancing.graph, key("high-damage-ammo-canonical", ""), conn_key)
            end
        end
    end

    ----------------------------------------------------------------------
    -- Entity Canonical Nodes (new additions)
    ----------------------------------------------------------------------

    curr_class = "entity-canonical"

    ----------------------------------------
    add_node("accumulator-canonical", "OR", nil, "", { canonical = "accumulator-canonical" })
    ----------------------------------------
    -- Can we operate any accumulator?

    for _, acc in pairs(prots("accumulator")) do
        add_edge("entity-operate", acc.name)
    end

    ----------------------------------------
    add_node("assembling-machine-canonical", "OR", nil, "", { canonical = "assembling-machine-canonical" })
    ----------------------------------------
    -- Can we operate any assembling machine with "crafting" category?
    -- "crafting" is the special base category for hand-craftable recipes

    for _, machine in pairs(prots("assembling-machine")) do
        if machine.crafting_categories ~= nil then
            for _, cat in pairs(machine.crafting_categories) do
                if cat == "crafting" then
                    add_edge("entity-operate", machine.name)
                    break
                end
            end
        end
    end

    -- Add prereq to all unit techs that have prerequisites (not the first tech)
    add_tech_prereq("assembling-machine-canonical", "", function(tech)
        return has_unit(tech) and tech.prerequisites and next(tech.prerequisites) ~= nil
    end)

    ----------------------------------------
    add_node("beacon-canonical", "OR", nil, "", { canonical = "beacon-canonical" })
    ----------------------------------------
    -- Can we operate any beacon?

    for _, beacon in pairs(prots("beacon")) do
        add_edge("entity-operate", beacon.name)
    end

    ----------------------------------------
    add_node("bot-network-complete", "AND", nil, "", { canonical = "bot-network-complete" })
    ----------------------------------------
    -- Complete bot network: roboport + logistic robot + logistic container

    add_edge("roboport-canonical", "")
    add_edge("logistic-robot-canonical", "")
    add_edge("logistic-container-canonical", "")

    ----------------------------------------
    add_node("cargo-wagon-canonical", "OR", nil, "", { canonical = "cargo-wagon-canonical" })
    ----------------------------------------

    for _, wagon in pairs(prots("cargo-wagon")) do
        add_edge("entity-operate", wagon.name)
    end

    ----------------------------------------
    add_node("fluid-wagon-canonical", "OR", nil, "", { canonical = "fluid-wagon-canonical" })
    ----------------------------------------

    for _, wagon in pairs(prots("fluid-wagon")) do
        add_edge("entity-operate", wagon.name)
    end

    ----------------------------------------
    add_node("gate-canonical", "OR", nil, "", { canonical = "gate-canonical" })
    ----------------------------------------
    -- Can we operate any gate?

    for _, gate in pairs(prots("gate")) do
        add_edge("entity-operate", gate.name)
    end

    ----------------------------------------
    add_node("inserter-canonical", "OR", nil, "", { canonical = "inserter-canonical" })
    ----------------------------------------
    -- Can we operate any inserter?

    for _, inserter in pairs(prots("inserter")) do
        add_edge("entity-operate", inserter.name)
    end

    -- Add prereq to all unit techs that have prerequisites (not the first tech)
    add_tech_prereq("inserter-canonical", "", function(tech)
        return has_unit(tech) and tech.prerequisites and next(tech.prerequisites) ~= nil
    end)

    ----------------------------------------
    add_node("lab-canonical", "OR", nil, "", { canonical = "lab-canonical" })
    ----------------------------------------
    -- Can we operate any lab?

    for _, lab in pairs(prots("lab")) do
        add_edge("entity-operate", lab.name)
    end

    ----------------------------------------
    add_node("locomotive-canonical", "OR", nil, "", { canonical = "locomotive-canonical" })
    ----------------------------------------

    for _, loco in pairs(prots("locomotive")) do
        add_edge("entity-operate", loco.name)
    end

    ----------------------------------------
    add_node("logistic-container-canonical", "OR", nil, "", { canonical = "logistic-container-canonical" })
    ----------------------------------------

    for _, container in pairs(prots("logistic-container")) do
        add_edge("entity-operate", container.name)
    end

    ----------------------------------------
    add_node("logistic-robot-canonical", "OR", nil, "", { canonical = "logistic-robot-canonical" })
    ----------------------------------------

    for _, robot in pairs(prots("logistic-robot")) do
        add_edge("entity-operate", robot.name)
    end

    ----------------------------------------
    add_node("mining-drill-canonical", "OR", nil, "", { canonical = "mining-drill-canonical" })
    ----------------------------------------
    -- Can we operate any mining drill?

    for _, drill in pairs(prots("mining-drill")) do
        add_edge("entity-operate", drill.name)
    end

    -- Add prereq to all unit-researched techs
    add_tech_prereq("mining-drill-canonical", "", has_unit)

    ----------------------------------------
    add_node("radar-canonical", "OR", nil, "", { canonical = "radar-canonical" })
    ----------------------------------------
    -- Can we operate any radar?

    for _, radar in pairs(prots("radar")) do
        add_edge("entity-operate", radar.name)
    end

    ----------------------------------------
    add_node("rail-canonical", "OR", nil, "", { canonical = "rail-canonical" })
    ----------------------------------------

    for rail_class, _ in pairs(categories.rail or {}) do
        for _, rail in pairs(prots(rail_class) or {}) do
            add_edge("entity", rail.name)
        end
    end

    ----------------------------------------
    add_node("rail-signal-canonical", "OR", nil, "", { canonical = "rail-signal-canonical" })
    ----------------------------------------

    for _, signal in pairs(prots("rail-signal")) do
        add_edge("entity-operate", signal.name)
    end
    for _, signal in pairs(prots("rail-chain-signal")) do
        add_edge("entity-operate", signal.name)
    end

    ----------------------------------------
    add_node("roboport-canonical", "OR", nil, "", { canonical = "roboport-canonical" })
    ----------------------------------------
    -- Can we operate any roboport?

    for _, roboport in pairs(prots("roboport")) do
        add_edge("entity-operate", roboport.name)
    end

    -- Add prereq to techs with 5+ science pack types (late-game)
    add_tech_prereq("roboport-canonical", "", function(tech)
        return has_ingredients_over(tech, 4)
    end)

    ----------------------------------------
    add_node("train-stop-canonical", "OR", nil, "", { canonical = "train-stop-canonical" })
    ----------------------------------------

    for _, stop in pairs(prots("train-stop")) do
        add_edge("entity-operate", stop.name)
    end

    ----------------------------------------
    add_node("wall-canonical", "OR", nil, "", { canonical = "wall-canonical" })
    ----------------------------------------
    -- Can we operate any wall?

    for _, wall in pairs(prots("wall")) do
        add_edge("entity-operate", wall.name)
    end

    ----------------------------------------
    add_node("train-network-complete", "AND", nil, "", { canonical = "train-network-complete" })
    ----------------------------------------
    -- Complete train network: locomotive + cargo wagon + train stop + signals + rail

    add_edge("locomotive-canonical", "")
    add_edge("cargo-wagon-canonical", "")
    add_edge("train-stop-canonical", "")
    add_edge("rail-signal-canonical", "")
    add_edge("rail-canonical", "")

    ----------------------------------------
    add_node("vehicle-car-canonical", "OR", nil, "", { canonical = "vehicle-car-canonical" })
    ----------------------------------------

    for _, car in pairs(prots("car")) do
        add_edge("entity-operate", car.name)
    end
end

return logic_balancing
