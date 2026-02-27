-- TODO: Add to handlers.md, settings, and execute

local constants = require("helper-tables/constants")
local gutils = require("new-lib/graph/graph-utils")
local top = require("new-lib/graph/top-sort")

local mining_fluid_required = {}

mining_fluid_required.id = "mining_fluid_required"

mining_fluid_required.spoof = function(graph)
    -- Dummy fluid so that resources can gain required fluids
    local spoof_node_fluid = gutils.add_node(graph, "fluid", "entity-mine-fluid-spoofed-fluid")
    spoof_node_fluid.op = "OR"
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

mining_fluid_required.claim = function(graph, prereq, dep, trav)
    if prereq.type == "fluid" and dep.type == "entity-mine" then
        return 1
    end
end

mining_fluid_required.validate = function(graph, slot, trav, extra)
    local slot_owner = gutils.get_conn_owner(graph, slot)

    if slot_owner.type == "fluid" then
        return true
    end
end

mining_fluid_required.reflect = function(graph, trav_to_new_slot, trav_to_handler)
    for trav_key, slot in pairs(trav_to_new_slot) do
        if trav_to_handler[trav_key].id == "mining_fluid_required" then
            local trav = graph.nodes[trav_key]
            local resource_node = gutils.get_conn_owner(graph, trav)
            -- Check for dummies
            if string.find(resource_node.name, "spoof") == nil then
                local resource = data.raw.resource[resource_node.name]
                local slot_owner = gutils.get_conn_owner(graph, slot)
                if string.find(slot_owner.name, "spoof") ~= nil then
                    resource.minable.required_fluid = nil
                    resource.minable.fluid_amount = 0
                else
                    local fluid = data.raw.fluid[slot_owner.name]
                    resource.minable.required_fluid = fluid.name
                    if resource.minable.fluid_amount == nil or resource.minable.fluid_amount == 0 then
                        resource.minable.fluid_amount = constants.unified_mining_fluid_required_default_fluid_amount
                    end
                end
            end
        end
    end
end

return mining_fluid_required