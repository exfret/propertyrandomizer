-- This file is mostly for adding extra custom nodes as needed based on mod configuration
-- It assumes dep_graph is already loaded in

-- build_graph is just used for its util functions, it should already be loaded in by now
local build_graph = require("lib/graph/build-graph")

local build_graph_compat = {}

local function load(graph)
    local prereqs

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

        table.insert(tech_node.prereqs, {
            type = "mining-drill",
            name = "canonical"
        })
    end

    -- Require automation before all other techs with unit
    -- Note that this is relies heavily on the structure of vanilla

    for _, technology in pairs(data.raw.technology) do
        if technology.name ~= "automation" and technology.unit ~= nil  then
            local tech_node = graph[build_graph.key("technology", technology.name)]

            table.insert(tech_node.prereqs, {
                type = "operate-entity",
                name = "assembling-machine-1"
            })
        end
    end

    -- Require gun turret and military before all other techs with unit more than 15, or involving more than automation science

    for _, technology in pairs(data.raw.technology) do
        if technology.name ~= "gun-turret" and technology.name ~= "military" and technology.unit ~= nil and (#technology.unit.ingredients > 1 or technology.unit.count > 15) then
            local tech_node = graph[build_graph.key("technology", technology.name)]

            table.insert(tech_node.prereqs, {
                type = "operate-entity",
                name = "gun-turret"
            })

            table.insert(tech_node.prereqs, {
                type = "item",
                name = "submachine-gun"
            })

            table.insert(tech_node.prereqs, {
                type = "item",
                name = "firearm-magazine"
            })
        end
    end
end
-- export
build_graph_compat.load = load

-- First time loading
load(dep_graph)

return build_graph_compat