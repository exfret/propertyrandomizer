-- This file is mostly for adding extra custom nodes as needed based on mod configuration
-- It assumes dep_graph is already loaded in
-- Note that, at the moment, this file makes a ton of assumptions about the structure of the game that will probably be untrue in modded playthrough

-- build_graph is just used for its util functions, it should already be loaded in by now
local build_graph = require("lib/old-logic/build-graph")
local top_sort = require("lib/old-logic/top-sort")

local build_graph_compat = {}

-- The rules added here are for balance, like a mining drill before any technology, and balance is soft
-- A game can break a rule before randomization: Any Planet Start's Fulgora researches recycling before any mining drill can run, since drill fuel comes from scrap
-- Keeping such a rule would leave almost nothing reachable, so the first load (the game before graph randomization) finds the rules that game breaks, and no load adds them

-- Rules added in this load, as target node key --> required node key --> true
local rules
-- Rules the game before randomization breaks, in the same form; nil until the first load finds them
local broken_rules

-- Makes an AND node require prereq first, unless the game before randomization breaks that rule
local function require_first(target_node, prereq)
    local target_key = build_graph.key(target_node.type, target_node.name)
    local prereq_key = build_graph.key(prereq.type, prereq.name)
    if broken_rules ~= nil and broken_rules[target_key] ~= nil and broken_rules[target_key][prereq_key] then
        return
    end
    table.insert(target_node.prereqs, prereq)
    rules[target_key] = rules[target_key] or {}
    rules[target_key][prereq_key] = true
end

-- Sorts with every rule; while targets are left blocked only by rules that aren't met, drops those rules and sorts again
-- So a rule is only dropped when the game can't keep it, and a game that keeps them all (like vanilla) keeps them all
local function find_broken_rules(graph)
    local broken = {}
    while true do
        build_graph.add_dependents(graph)
        local reachable = top_sort.sort(graph).reachable
        local dropped = false
        for target_key, prereq_keys in pairs(rules) do
            local target_node = graph[target_key]
            if not reachable[target_key] then
                local blocked_by_rules_only = true
                for _, prereq in pairs(target_node.prereqs) do
                    local prereq_key = build_graph.key(prereq.type, prereq.name)
                    if not reachable[prereq_key] and not prereq_keys[prereq_key] then
                        blocked_by_rules_only = false
                    end
                end
                if blocked_by_rules_only then
                    local kept = {}
                    for _, prereq in pairs(target_node.prereqs) do
                        local prereq_key = build_graph.key(prereq.type, prereq.name)
                        if prereq_keys[prereq_key] and not reachable[prereq_key] then
                            broken[target_key] = broken[target_key] or {}
                            broken[target_key][prereq_key] = true
                            dropped = true
                        else
                            table.insert(kept, prereq)
                        end
                    end
                    target_node.prereqs = kept
                end
            end
        end
        if not dropped then
            return broken
        end
    end
end

-- TODO: Think about how to add these to notes?
-- TODO: Make these operate-entity-surface for nauvis?
local function load(graph)
    local prereqs
    rules = {}

    -- Require a mining drill before tech can be done

    prereqs = {}

    for _, mining_drill in pairs(data.raw["mining-drill"]) do
        -- TODO: Sense for "weird" mining drills and exclude those
        table.insert(prereqs, {
            type = "operate-entity",
            name = mining_drill.name
        })
    end

    graph[build_graph.key("mining-drill", "canonical")] = {
        type = "mining-drill",
        name = "canonical",
        prereqs = prereqs
    }

    build_graph.ops["mining-drill"] = "OR"

    for _, technology in pairs(data.raw.technology) do
        local tech_node = graph[build_graph.key("technology", technology.name)]

        require_first(tech_node, {
            type = "mining-drill",
            name = "canonical"
        })
    end

    -- Require an assembling machine with crafting as a category before all techs with unit other than automation

    prereqs = {}

    for _, machine in pairs(data.raw["assembling-machine"]) do
        local has_crafting_category = false

        for _, category in pairs(machine.crafting_categories) do
            if category == "crafting" then
                has_crafting_category = true
            end
        end

        if has_crafting_category then
            table.insert(prereqs, {
                type = "operate-entity",
                name = machine.name
            })
        end
    end

    graph[build_graph.key("assembling-machine", "canonical")] = {
        type = "assembling-machine",
        name = "canonical",
        prereqs = prereqs
    }

    build_graph.ops["assembling-machine"] = "OR"

    for _, technology in pairs(data.raw.technology) do
        if technology.name ~= "automation" and technology.unit ~= nil  then
            local tech_node = graph[build_graph.key("technology", technology.name)]

            require_first(tech_node, {
                type = "assembling-machine",
                name = "canonical"
            })
        end
    end

    -- Require gun turret and military before all other techs with unit more than 15, or involving more than automation science

    prereqs = {}

    -- Just consider submachine gun and vehicle guns for now
    table.insert(prereqs, {
        type = "item",
        name = "submachine-gun"
    })
    table.insert(prereqs, {
        type = "operate-entity",
        name = "car"
    })
    table.insert(prereqs, {
        type = "operate-entity",
        name = "tank"
    })

    graph[build_graph.key("starter-gun", "canonical")] = {
        type = "starter-gun",
        name = "canonical",
        prereqs = prereqs
    }

    build_graph.ops["starter-gun"] = "OR"

    prereqs = {}

    -- Just consider bullets for now
    for _, ammo in pairs(data.raw.ammo) do
        if ammo.ammo_category == "bullet" then
            table.insert(prereqs, {
                type = "item",
                name = ammo.name
            })
        end
    end

    graph[build_graph.key("starter-gun-ammo", "canonical")] = {
        type = "starter-gun-ammo",
        name = "canonical",
        prereqs = prereqs
    }

    build_graph.ops["starter-gun-ammo"] = "OR"

    for _, technology in pairs(data.raw.technology) do
        if technology.name ~= "gun-turret" and technology.name ~= "military" and technology.unit ~= nil and (#technology.unit.ingredients > 1 or technology.unit.count_formula ~= nil or technology.unit.count > 15) then
            local tech_node = graph[build_graph.key("technology", technology.name)]

            require_first(tech_node, {
                type = "operate-entity",
                name = "gun-turret"
            })

            require_first(tech_node, {
                type = "starter-gun",
                name = "canonical"
            })

            require_first(tech_node, {
                type = "starter-gun-ammo",
                name = "canonical"
            })
        end
    end

    -- Inserter node: inserters available before any non-automation tech
    
    prereqs = {}

    for _, inserter in pairs(data.raw.inserter) do
        table.insert(prereqs, {
            type = "operate-entity",
            name = inserter.name
        })
    end

    graph[build_graph.key("inserter", "canonical")] = {
        type = "inserter",
        name = "canonical",
        prereqs = prereqs
    }

    build_graph.ops["inserter"] = "OR"

    for _, technology in pairs(data.raw.technology) do
        if technology.name ~= "automation" and technology.unit ~= nil then
            local tech_node = graph[build_graph.key("technology", technology.name)]

            require_first(tech_node, {
                type = "inserter",
                name = "canonical"
            })
        end
    end

    -- Belts before any non-trigger tech
    -- TODO: Make automatable, not just get-able
    -- Note: Automatability is sorta checked with cost checking in item randomization

    prereqs = {}

    for _, belt in pairs(data.raw["transport-belt"]) do
        table.insert(prereqs, {
            type = "operate-entity",
            name = belt.name
        })
    end

    graph[build_graph.key("transport-belt", "canonical")] = {
        type = "transport-belt",
        name = "canonical",
        prereqs = prereqs
    }

    build_graph.ops["transport-belt"] = "OR"

    for _, technology in pairs(data.raw.technology) do
        if technology.unit ~= nil then
            local tech_node = graph[build_graph.key("technology", technology.name)]

            require_first(tech_node, {
                type = "transport-belt",
                name = "canonical"
            })
        end
    end

    -- Underground belts and splitters before any science costing 50 or more

    prereqs = {}

    for _, belt in pairs(data.raw["underground-belt"]) do
        table.insert(prereqs, {
            type = "operate-entity",
            name = belt.name
        })
    end

    graph[build_graph.key("underground-belt", "canonical")] = {
        type = "underground-belt",
        name = "canonical",
        prereqs = prereqs
    }

    build_graph.ops["underground-belt"] = "OR"

    for _, technology in pairs(data.raw.technology) do
        if technology.unit ~= nil and (technology.unit.count_formula ~= nil or technology.unit.count >= 50) then
            local tech_node = graph[build_graph.key("technology", technology.name)]

            require_first(tech_node, {
                type = "underground-belt",
                name = "canonical"
            })
        end
    end

    prereqs = {}

    for _, belt in pairs(data.raw["splitter"]) do
        table.insert(prereqs, {
            type = "operate-entity",
            name = belt.name
        })
    end

    graph[build_graph.key("splitter", "canonical")] = {
        type = "splitter",
        name = "canonical",
        prereqs = prereqs
    }

    build_graph.ops["splitter"] = "OR"

    for _, technology in pairs(data.raw.technology) do
        if technology.unit ~= nil and (technology.unit.count_formula ~= nil or technology.unit.count >= 50) then
            local tech_node = graph[build_graph.key("technology", technology.name)]

            require_first(tech_node, {
                type = "splitter",
                name = "canonical"
            })
        end
    end

    -- Repair pack pre-green science

    prereqs = {}

    for _, tool in pairs(data.raw["repair-tool"]) do
        table.insert(prereqs, {
            type = "item",
            name = tool.name
        })
    end

    graph[build_graph.key("repair-pack", "canonical")] = {
        type = "repair-pack",
        name = "canonical",
        prereqs = prereqs
    }

    build_graph.ops["repair-pack"] = "OR"

    for _, technology in pairs(data.raw.technology) do
        if technology.unit ~= nil and #technology.unit.ingredients > 1 then
            local tech_node = graph[build_graph.key("technology", technology.name)]

            require_first(tech_node, {
                type = "repair-pack",
                name = "canonical"
            })
        end
    end

    -- Storage before green science
    -- TODO: If I implement crashed ship spawnability, watch out for that always satisfying this

    prereqs = {}

    for _, container in pairs(data.raw.container) do
        table.insert(prereqs, {
            type = "operate-entity",
            name = container.name
        })
    end

    graph[build_graph.key("storage", "canonical")] = {
        type = "storage",
        name = "canonical",
        prereqs = prereqs
    }

    build_graph.ops["storage"] = "OR"

    for _, technology in pairs(data.raw.technology) do
        if technology.unit ~= nil and #technology.unit.ingredients > 1 then
            local tech_node = graph[build_graph.key("technology", technology.name)]

            require_first(tech_node, {
                type = "storage",
                name = "canonical"
            })
        end
    end

    -- Rockets and rocket turrets pre-aquilo
    -- Only if space age is enabled

    if mods["space-age"] then
        prereqs = {}

        for _, turret in pairs(data.raw["ammo-turret"]) do
            local has_rocket_category = false
            if turret.attack_parameters.ammo_category == "rocket" then
                has_rocket_category = true
            elseif turret.attack_parameters.ammo_categories ~= nil then
                for _, category in pairs(turret.attack_parameters.ammo_categories) do
                    if category == "rocket" then
                        has_rocket_category = true
                    end
                end
            end

            if has_rocket_category then
                table.insert(prereqs, {
                    type = "operate-entity",
                    name = turret.name
                })
            end
        end

        graph[build_graph.key("rocket-turret", "canonical")] = {
            type = "rocket-turret",
            name = "canonical",
            prereqs = prereqs
        }

        build_graph.ops["rocket-turret"] = "OR"

        -- Also rocket ammo

        prereqs = {}

        for _, ammo in pairs(data.raw.ammo) do
            if ammo.ammo_category == "rocket" then
                table.insert(prereqs, {
                    type = "item",
                    name = ammo.name
                })
            end
        end

        graph[build_graph.key("rocket-ammo", "canonical")] = {
            type = "rocket-ammo",
            name = "canonical",
            prereqs = prereqs
        }

        build_graph.ops["rocket-ammo"] = "OR"

        -- Use space connection because that's an AND node and surface is not
        -- Either way along it that arrives at aquilo

        for _, connection in pairs(data.raw["space-connection"]) do
            local arrivals = {}
            if connection.to == "aquilo" then
                table.insert(arrivals, "space-connection")
            end
            if connection.from == "aquilo" then
                table.insert(arrivals, "space-connection-reverse")
            end
            for _, node_type in pairs(arrivals) do
                local conn_node = graph[build_graph.key(node_type, connection.name)]
                -- A connection the graph doesn't have (drawn after the graph was built, see data-final-fixes.lua) can't take the rule
                if conn_node ~= nil then
                    require_first(conn_node, {
                        type = "rocket-turret",
                        name = "canonical"
                    })

                    require_first(conn_node, {
                        type = "rocket-ammo",
                        name = "canonical"
                    })
                end
            end
        end
    end

    -- Construction before any science past blue
    -- Includes bot and roboport
    -- TODO: Add equipment nodes so I can do personal roboport too
    -- TODO: Include passive provider chest/storage chest node too

    prereqs = {}

    for _, bot in pairs(data.raw["construction-robot"]) do
        table.insert(prereqs, {
            type = "operate-entity",
            name = bot.name
        })
    end

    graph[build_graph.key("construction-robot", "canonical")] = {
        type = "construction-robot",
        name = "canonical",
        prereqs = prereqs
    }

    build_graph.ops["construction-robot"] = "OR"

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
            local tech_node = graph[build_graph.key("technology", technology.name)]

            require_first(tech_node, {
                type = "construction-robot",
                name = "canonical"
            })
        end
    end

    prereqs = {}

    for _, roboport in pairs(data.raw["roboport"]) do
        table.insert(prereqs, {
            type = "operate-entity",
            name = roboport.name
        })
    end

    graph[build_graph.key("roboport", "canonical")] = {
        type = "roboport",
        name = "canonical",
        prereqs = prereqs
    }

    build_graph.ops["roboport"] = "OR"

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
            local tech_node = graph[build_graph.key("technology", technology.name)]

            require_first(tech_node, {
                type = "roboport",
                name = "canonical"
            })
        end
    end

    -- Pumps before anything with blue science

    prereqs = {}

    for _, pump in pairs(data.raw.pump) do
        table.insert(prereqs, {
            type = "operate-entity",
            name = pump.name
        })
    end

    graph[build_graph.key("pump", "canonical")] = {
        type = "pump",
        name = "canonical",
        prereqs = prereqs
    }

    build_graph.ops["pump"] = "OR"

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
            local tech_node = graph[build_graph.key("technology", technology.name)]

            require_first(tech_node, {
                type = "pump",
                name = "canonical"
            })
        end
    end

    if broken_rules == nil then
        broken_rules = find_broken_rules(graph)
        local dropped = {}
        for target_key, prereq_keys in pairs(broken_rules) do
            for prereq_key, _ in pairs(prereq_keys) do
                table.insert(dropped, prereq_key .. " before " .. target_key)
            end
        end
        table.sort(dropped)
        log("Old logic balance rules the game before randomization breaks, so they're left out: " .. #dropped .. (#dropped > 0 and (" (" .. table.concat(dropped, ", ") .. ")") or ""))
    end
end
-- export
build_graph_compat.load = load

-- First time loading
load(dep_graph)

return build_graph_compat