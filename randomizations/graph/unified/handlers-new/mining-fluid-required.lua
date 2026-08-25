-- TODO: Add to handlers.md, settings, and execute
-- CRITICAL TODO: Cost checking (just reject very expensive fluids)

local constants = require("helper-tables/constants")
local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/top-sort")
local rng = require("lib/random/rng")

local mining_fluid_required = {}

mining_fluid_required.id = "mining_fluid_required"

mining_fluid_required.with_replacement = true

mining_fluid_required.initialize = function()
end

mining_fluid_required.spoof = function(graph)
    -- Dummy fluid so that resources can gain required fluids
    local spoof_node_fluid = gutils.add_node(graph, "fluid", "entity-mine-fluid-spoofed-fluid")
    spoof_node_fluid.op = "OR"
    spoof_node_fluid.spoof = true
    gutils.add_edge(graph, graph.nodes[gutils.key("true", "")], spoof_node_fluid)
    
    -- Do a sort so we only consider reachable nodes
    local sort_info = top.sort(graph)

    local already_checked_fluid = {}
    local already_checked_resource = {}
    for _, node_info in pairs(sort_info.open) do
        local node = graph.nodes[node_info.node]
        if node.type == "fluid" and not already_checked_fluid[node.name] then
            already_checked_fluid[node.name] = true

            local spoof_node_resource = gutils.add_node(graph, "entity-mine", "entity-mine-fluid-spoof-" .. node.name)
            spoof_node_resource.op = "AND"
            spoof_node_resource.spoof = true

            gutils.add_edge(graph, node, spoof_node_resource)
        end
        if node.type == "entity-mine" and not already_checked_resource[node.name] then
            already_checked_resource[node.name] = true

            local resource = data.raw.resource[node.name]
            if resource ~= nil and resource.minable ~= nil and resource.minable.required_fluid == nil then
                gutils.add_edge(graph, spoof_node_fluid, node)
            end
        end
    end
end

mining_fluid_required.claim = function(graph, prereq, dep, edge)
    if prereq.type == "fluid" and dep.type == "entity-mine" then
        return 1
    end
end

mining_fluid_required.validate = function(graph, base, head, extra)
    local base_owner = gutils.get_owner(graph, base)

    if base_owner.type == "fluid" then
        return true
    end
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
                if base_owner.spoof then
                    resource.minable.required_fluid = nil
                    resource.minable.fluid_amount = 0
                else
                    local fluid = data.raw.fluid[base_owner.name]
                    resource.minable.required_fluid = fluid.name
                    if resource.minable.fluid_amount == nil or resource.minable.fluid_amount == 0 then
                        resource.minable.fluid_amount = possible_fluid_amounts[rng.int(rng.key({ id = "unified" }), #possible_fluid_amounts)]
                    end
                end
            end
        end
    end
end

return mining_fluid_required