-- Builder file for nodes mostly used for balancing, like ensuring early enough inserters, etc.

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
local add_edge_reversed = builder.add_edge_reversed
local set_class = builder.set_class
local set_prot = builder.set_prot

local balance = {}

balance.build = function(lu)
    -- Balance nodes shouldn't affect abilities contexts
    -- To accomplish this, we have them add all
    local balance_abilities = {
        [1] = true,
        [2] = true,
    }

    set_class("balance")
    set_prot(nil)

    -- Make automation technology not require green packs
    add_edge("technology", "automation", {
        abilities = table.deepcopy(balance_abilities),
    }, "recipe", "logistic-science-pack")

    ----------------------------------------
    add_node("balance-mining-drill", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Do we have access to some mining drill?

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

    -- Require this before any technology
    for _, tech in pairs(data.raw.technology) do
        add_edge_reversed("technology", tech.name, {
            abilities = table.deepcopy(balance_abilities),
        })
    end

    ----------------------------------------
    add_node("balance-crafting-automation", "OR", nil, "", { mechanic = true })
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

    -- Require this before all techs with unit other than the technology automation
    for _, tech in pairs(data.raw.technology) do
        if tech.unit ~= nil and tech.name ~= "automation" then
            add_edge_reversed("technology", tech.name, {
                abilities = table.deepcopy(balance_abilities),
            })
        end
    end
    add_edge_reversed("recipe", "logistic-science-pack", {
        abilities = table.deepcopy(balance_abilities),
    })

    ----------------------------------------
    add_node("balance-starter-gun", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we use a reasonable gun of some sort?
    
    add_edge("item", "submachine-gun", {
        abilities = table.deepcopy(balance_abilities),
    })
    add_edge("entity-operate", "car", {
        abilities = table.deepcopy(balance_abilities),
    })
    add_edge("entity-operate", "tank", {
        abilities = table.deepcopy(balance_abilities),
    })

    -- Require this before non-gun-turret, non-military techs needing more than 15 science packs, or more than one science pack (presumably automation science)
    -- EDIT: Needed to remove the non-gun-turret, non-military clause for technical reasons
    for _, tech in pairs(data.raw.technology) do
        -- TODO: Test for automation science directly; also check trigger effects
        if --[[tech.name ~= "gun-turret" and tech.name ~= "military" and]] tech.unit ~= nil and (#tech.unit.ingredients > 1 or tech.unit.count_formula ~= nil or tech.unit.count > 15) then
            add_edge_reversed("technology", tech.name, {
                abilities = table.deepcopy(balance_abilities),
            })
        end
    end
    add_edge_reversed("recipe", "logistic-science-pack")

    ----------------------------------------
    add_node("balance-starter-ammo", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we use ammo that works with a reasonable gun?
    
    for _, ammo in pairs(data.raw.ammo) do
        if ammo.ammo_category == "bullet" then
            add_edge("item", ammo.name, {
                abilities = table.deepcopy(balance_abilities),
            })
        end
    end

    -- Requirement same as last
    for _, tech in pairs(data.raw.technology) do
        -- TODO: Test for automation science directly; also check trigger effects
        if --[[tech.name ~= "gun-turret" and tech.name ~= "military" and]] tech.unit ~= nil and (#tech.unit.ingredients > 1 or tech.unit.count_formula ~= nil or tech.unit.count > 15) then
            add_edge_reversed("technology", tech.name, {
                abilities = table.deepcopy(balance_abilities),
            })
        end
    end
    add_edge_reversed("recipe", "logistic-science-pack", {
        abilities = table.deepcopy(balance_abilities),
    })

    ----------------------------------------
    add_node("balance-gun-turret", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we use gun turrets? (Currently just tests base gun turret)
    
    add_edge("entity-operate", "gun-turret", {
        abilities = table.deepcopy(balance_abilities),
    })

    -- Requirement same as last, again
    for _, tech in pairs(data.raw.technology) do
        -- TODO: Test for automation science directly; also check trigger effects
        if --[[tech.name ~= "gun-turret" and tech.name ~= "military" and]] tech.unit ~= nil and (#tech.unit.ingredients > 1 or tech.unit.count_formula ~= nil or tech.unit.count > 15) then
            add_edge_reversed("technology", tech.name, {
                abilities = table.deepcopy(balance_abilities),
            })
        end
    end
    add_edge_reversed("recipe", "logistic-science-pack", {
        abilities = table.deepcopy(balance_abilities),
    })

    ----------------------------------------
    add_node("balance-inserter", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we use some sort of inserter?

    for _, inserter in pairs(data.raw.inserter) do
        add_edge("entity-operate", inserter.name, {
            abilities = table.deepcopy(balance_abilities),
        })
    end

    -- Require this before any tech with unit other than the technology automation (just like assembling machines)
    for _, tech in pairs(data.raw.technology) do
        if tech.unit ~= nil and tech.name ~= "automation" then
            add_edge_reversed("technology", tech.name, {
                abilities = table.deepcopy(balance_abilities),
            })
        end
    end
    add_edge_reversed("recipe", "logistic-science-pack", {
        abilities = table.deepcopy(balance_abilities),
    })

    ----------------------------------------
    add_node("balance-transport-belt", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we use some sort of transport belt?

    for _, belt in pairs(data.raw["transport-belt"]) do
        add_edge("entity-operate", belt.name, {
            abilities = table.deepcopy(balance_abilities),
        })
    end

    -- Require this before any tech with unit
    for _, tech in pairs(data.raw.technology) do
        if tech.unit ~= nil then
            add_edge_reversed("technology", tech.name, {
                abilities = table.deepcopy(balance_abilities),
            })
        end
    end

    ----------------------------------------
    add_node("balance-underground-belt", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we use some sort of underground belt?

    for _, belt in pairs(data.raw["underground-belt"]) do
        add_edge("entity-operate", belt.name, {
            abilities = table.deepcopy(balance_abilities),
        })
    end

    -- Require this before any tech costing 50+ science
    for _, tech in pairs(data.raw.technology) do
        if tech.unit ~= nil and (tech.unit.count_formula ~= nil or tech.unit.count >= 50) then
            add_edge_reversed("technology", tech.name, {
                abilities = table.deepcopy(balance_abilities),
            })
        end
    end

    ----------------------------------------
    add_node("balance-underground-belt", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we use some sort of splitter?

    for _, belt in pairs(data.raw.splitter) do
        add_edge("entity-operate", belt.name, {
            abilities = table.deepcopy(balance_abilities),
        })
    end

    -- Same requirement as last one
    for _, tech in pairs(data.raw.technology) do
        if tech.unit ~= nil and (tech.unit.count_formula ~= nil or tech.unit.count >= 50) then
            add_edge_reversed("technology", tech.name, {
                abilities = table.deepcopy(balance_abilities),
            })
        end
    end

    ----------------------------------------
    add_node("balance-repair-pack", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we get some sort of repair pack?

    for _, pack in pairs(data.raw["repair-tool"]) do
        add_edge("item", pack.name, {
            abilities = table.deepcopy(balance_abilities),
        })
    end

    -- Require before any technology with more than one science pack (presumably meaning more than just automation science packs)
    for _, tech in pairs(data.raw.technology) do
        if tech.unit ~= nil and #tech.unit.ingredients > 1 then
            add_edge_reversed("technology", tech.name, {
                abilities = table.deepcopy(balance_abilities),
            })
        end
    end
    add_edge_reversed("recipe", "logistic-science-pack", {
        abilities = table.deepcopy(balance_abilities),
    })

    ----------------------------------------
    add_node("balance-storage", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we get some sort of storage

    for _, container in pairs(data.raw.container) do
        add_edge("entity-operate", container.name, {
            abilities = table.deepcopy(balance_abilities),
        })
    end

    -- Requirement same as last one
    for _, tech in pairs(data.raw.technology) do
        if tech.unit ~= nil and #tech.unit.ingredients > 1 then
            add_edge_reversed("technology", tech.name, {
                abilities = table.deepcopy(balance_abilities),
            })
        end
    end
    add_edge_reversed("recipe", "logistic-science-pack", {
        abilities = table.deepcopy(balance_abilities),
    })

    ----------------------------------------
    add_node("balance-construction-robot", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we use a construction robot?

    for _, bot in pairs(data.raw["construction-robot"]) do
        add_edge("entity-operate", bot.name, {
            abilities = table.deepcopy(balance_abilities),
        })
    end

    -- Require before any post-chemical science tech
    -- Just copy-pasted from build-graph-compat, could probably be refactored for less code repetition
    for _, technology in pairs(data.raw.technology) do
        local is_chemical_science_ings = {
            ["automation-science-pack"] = true,
            ["logistic-science-pack"] = true,
            ["military-science-pack"] = true,
            ["chemical-science-pack"] = true,
        }
        if mods["space-age"] then
            is_chemical_science_ings["space-science-pack"] = true
        end

        local past_chemical_science = false
        if technology.unit ~= nil then
            for _, ing in pairs(technology.unit.ingredients) do
                if not is_chemical_science_ings[ ing[1] ] then
                    past_chemical_science = true
                end
            end
        end

        if past_chemical_science then
            add_edge_reversed("technology", technology.name, {
                abilities = table.deepcopy(balance_abilities),
            })
        end
    end
    add_edge_reversed("recipe", "utility-science-pack", {
        abilities = table.deepcopy(balance_abilities),
    })
    add_edge_reversed("recipe", "production-science-pack", {
        abilities = table.deepcopy(balance_abilities),
    })

    ----------------------------------------
    add_node("balance-roboport", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we use a roboport?

    for _, roboport in pairs(data.raw.roboport) do
        add_edge("entity-operate", roboport.name, {
            abilities = table.deepcopy(balance_abilities),
        })
    end

    -- Require before any post-chemical science tech
    -- Just copy-pasted from build-graph-compat, could probably be refactored for less code repetition
    for _, technology in pairs(data.raw.technology) do
        local is_chemical_science_ings = {
            ["automation-science-pack"] = true,
            ["logistic-science-pack"] = true,
            ["military-science-pack"] = true,
            ["chemical-science-pack"] = true,
        }
        if mods["space-age"] then
            is_chemical_science_ings["space-science-pack"] = true
        end

        local past_chemical_science = false
        if technology.unit ~= nil then
            for _, ing in pairs(technology.unit.ingredients) do
                if not is_chemical_science_ings[ ing[1] ] then
                    past_chemical_science = true
                end
            end
        end

        if past_chemical_science then
            add_edge_reversed("technology", technology.name)
        end
    end
    add_edge_reversed("recipe", "utility-science-pack", {
        abilities = table.deepcopy(balance_abilities),
    })
    add_edge_reversed("recipe", "production-science-pack", {
        abilities = table.deepcopy(balance_abilities),
    })

    ----------------------------------------
    add_node("balance-pump", "OR", nil, "", { mechanic = true })
    ----------------------------------------
    -- Can we use a pump

    for _, pump in pairs(data.raw.pump) do
        add_edge("entity-operate", pump.name, {
            abilities = table.deepcopy(balance_abilities),
        })
    end

    -- Require before any post-logistic science tech
    -- Just copy-pasted from build-graph-compat, could probably be refactored for less code repetition
    for _, technology in pairs(data.raw.technology) do
        local is_logistic_science_ings = {
            ["automation-science-pack"] = true,
            ["logistic-science-pack"] = true,
        }

        local past_logistic_science = false
        if technology.unit ~= nil then
            for _, ing in pairs(technology.unit.ingredients) do
                if not is_logistic_science_ings[ ing[1] ] then
                    past_logistic_science = true
                end
            end
        end

        if past_logistic_science then
            add_edge_reversed("technology", technology.name, {
                abilities = table.deepcopy(balance_abilities),
            })
        end
    end
    add_edge_reversed("recipe", "chemical-science-pack", {
        abilities = table.deepcopy(balance_abilities),
    })

    -- Space age particular things
    if mods["space-age"] then
        ----------------------------------------
        add_node("balance-rocket-turret", "OR", nil, "", { mechanic = true })
        ----------------------------------------
        -- Can we get the rocket turret?

        add_edge("entity-operate", "rocket-turret", {
            abilities = table.deepcopy(balance_abilities),
        })
        
        -- Require before aquilo space connections
        add_edge_reversed("space-connection", "gleba-aquilo", {
            abilities = table.deepcopy(balance_abilities),
        })
        add_edge_reversed("space-connection", "fulgora-aquilo", {
            abilities = table.deepcopy(balance_abilities),
        })

        ----------------------------------------
        add_node("balance-rocket", "OR", nil, "", { mechanic = true })
        ----------------------------------------
        -- Can we get the rocket ammo?

        for _, ammo in pairs(data.raw.ammo) do
            if ammo.ammo_category == "rocket" then
                add_edge("item", ammo.name)
            end
        end
        
        -- Require before aquilo space connections
        add_edge_reversed("space-connection", "gleba-aquilo", {
            abilities = table.deepcopy(balance_abilities),
        })
        add_edge_reversed("space-connection", "fulgora-aquilo", {
            abilities = table.deepcopy(balance_abilities),
        })
    end
end

return balance