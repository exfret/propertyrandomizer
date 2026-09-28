-- TODO: Cost checking (just reject very expensive fluids)

-- Bases are mining-fluid nodes: a fluid together with the resource category variant that takes a fluid input (lutils.mcat_name), since only machines with an input fluid box mine a resource needing a fluid, never the character (fluid_amount > 0 means it can't be mined by hand, see MinableProperties in the API docs)
-- prefixes.lua gives every mining drill an input fluid box, so this mostly takes hand mining away
-- A resource can only gain a fluid if its category's fluid input variant has a resource-category node in logic (some resource of that category needed a fluid)

local gutils = require("lib/graph/graph-utils")
local lutils = require("lib/logic/logic-utils")
local top = require("lib/graph/context-sort")
local rng = require("lib/random/rng")
local logic = require("lib/logic/init")

local mining_fluid_required = {}

mining_fluid_required.id = "mining_fluid_required"

mining_fluid_required.with_replacement = true

mining_fluid_required.initialize = function()
end

-- Name of the base meaning "no fluid needed"
local NO_FLUID = "no-fluid-spoof"

-- Resource category variant (lutils.mcat_name) for mining this resource with a fluid input
local function fluid_mcat(resource)
    local fluids = lutils.find_mining_fluids(resource)
    return gutils.concat({resource.category or "basic-solid", 1, fluids.output})
end

mining_fluid_required.spoof = function(graph)
    -- Spoofed type, only in this graph; transmits contexts like fluids do
    logic.type_info["mining-fluid"] = logic.type_info["mining-fluid"] or {
        op = "AND",
        canonical = "mining-fluid",
    }

    -- Dummy base so that resources can lose required fluids
    local no_fluid = gutils.add_node(graph, "mining-fluid", NO_FLUID, {
        op = "OR",
        spoof = true,
    })
    gutils.add_edge(graph, graph.nodes[gutils.key("true", "")], no_fluid)

    -- Fluid input category variants logic can mine with
    local fluid_mcats = {}
    for mcat_key, mcat in pairs(lookups.mcats) do
        if mcat.input == 1 and graph.nodes[gutils.key("resource-category", mcat_key)] ~= nil then
            fluid_mcats[mcat_key] = true
        end
    end

    -- Base for mining with this fluid in this category variant, and a dummy head so it can go unused
    local function get_mining_fluid(fluid_name, mcat_key)
        local name = gutils.concat({fluid_name, mcat_key}, 2)
        local node_key = gutils.key("mining-fluid", name)
        if graph.nodes[node_key] == nil then
            local node = gutils.add_node(graph, "mining-fluid", name, {
                op = "AND",
                spoof = true,
                fluid = fluid_name,
                mcat = mcat_key,
            })
            gutils.add_edge(graph, graph.nodes[gutils.key("fluid", fluid_name)], node)
            gutils.add_edge(graph, graph.nodes[gutils.key("resource-category", mcat_key)], node)

            local spoof_resource = gutils.add_node(graph, "entity-mine", "entity-mine-fluid-spoof-" .. name, {
                op = "AND",
                spoof = true,
            })
            gutils.add_edge(graph, node, spoof_resource)
        end
        return graph.nodes[node_key]
    end

    -- Resources needing a fluid now need it through their mining-fluid node
    local fluid_edges = {}
    for edge_key, edge in pairs(graph.edges) do
        local start = graph.nodes[edge.start]
        local stop = graph.nodes[edge.stop]
        if start.type == "fluid" and stop.type == "entity-mine" and data.raw.resource[stop.name] ~= nil then
            table.insert(fluid_edges, edge_key)
        end
    end
    for _, edge_key in pairs(fluid_edges) do
        local edge = graph.edges[edge_key]
        local fluid_name = graph.nodes[edge.start].name
        local mcat_key = fluid_mcat(data.raw.resource[graph.nodes[edge.stop].name])
        if graph.nodes[gutils.key("resource-category", mcat_key)] ~= nil then
            gutils.redirect_edge_start(graph, edge_key, gutils.key(get_mining_fluid(fluid_name, mcat_key)))
        end
    end

    -- Do a sort so we only consider reachable nodes
    local sort_info = top.sort(graph)

    local already_checked_fluid = {}
    local already_checked_resource = {}
    for _, pebble in pairs(sort_info.sorted) do
        local node = graph.nodes[pebble.node_key]
        if node.type == "fluid" and not already_checked_fluid[node.name] then
            already_checked_fluid[node.name] = true

            for mcat_key, _ in pairs(fluid_mcats) do
                get_mining_fluid(node.name, mcat_key)
            end
        end
        if node.type == "entity-mine" and not node.spoof and not already_checked_resource[node.name] then
            already_checked_resource[node.name] = true

            local resource = data.raw.resource[node.name]
            if resource ~= nil and resource.minable ~= nil and resource.minable.required_fluid == nil then
                gutils.add_edge(graph, no_fluid, node)
            end
        end
    end
end

mining_fluid_required.claim = function(graph, prereq, dep, edge)
    if prereq.type == "mining-fluid" and dep.type == "entity-mine" then
        return 1
    end
end

mining_fluid_required.validate = function(graph, base, head, extra)
    local base_owner = gutils.get_owner(graph, base)
    if base_owner.type ~= "mining-fluid" then
        return false
    end

    local head_owner = gutils.get_owner(graph, head)
    local resource = data.raw.resource[head_owner.name]
    if resource == nil then
        -- Dummy heads take any fluid
        return base_owner.name ~= NO_FLUID
    end
    if base_owner.name == NO_FLUID then
        return true
    end
    return base_owner.mcat == fluid_mcat(resource)
end

-- This is actually a tenth of the actual fluid used amount it seems, so about 40 is a good median
local possible_fluid_amounts = {
    10,
    20,
    40,
    50,
    100,
}
mining_fluid_required.reflect = function(graph, head_to_base, head_to_handler)
    for head_key, base_key in pairs(head_to_base) do
        if head_to_handler[head_key].id == "mining_fluid_required" then
            local head = graph.nodes[head_key]
            local resource_node = gutils.get_owner(graph, head)
            -- Check for dummies
            if not resource_node.spoof then
                local resource = data.raw.resource[resource_node.name]
                local base = graph.nodes[base_key]
                local base_owner = gutils.get_owner(graph, base)
                if base_owner.name == NO_FLUID then
                    resource.minable.required_fluid = nil
                    resource.minable.fluid_amount = 0
                else
                    resource.minable.required_fluid = base_owner.fluid
                    if resource.minable.fluid_amount == nil or resource.minable.fluid_amount == 0 then
                        resource.minable.fluid_amount = possible_fluid_amounts[rng.int(rng.key({ id = "unified" }), #possible_fluid_amounts)]
                    end
                end
            end
        end
    end
end

return mining_fluid_required
