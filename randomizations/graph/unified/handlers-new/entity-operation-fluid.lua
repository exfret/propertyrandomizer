-- TODO: This is too inflexible in the way it assigns fluid required, but I'm not too sure how to fix that.

local gutils = require("new-lib/graph/graph-utils")
local dutils = require("new-lib/data-utils")
local top = require("new-lib/graph/top-sort")

local entity_operation_fluid = {}

entity_operation_fluid.id = "entity_operation_fluid"

entity_operation_fluid.spoof = function(graph)
    local spoof_node = gutils.add_node(graph, "entity-operate-fluid", "any-fluids-spoof")
    spoof_node.op = "OR"
    spoof_node.spoof = true

    -- Do a sort so we only consider reachable nodes
    local sort_info = top.sort(graph)

    local already_checked = {}
    for _, node_info in pairs(sort_info.open) do
        local node = graph.nodes[node_info.node]
        if node.type == "fluid" and not already_checked[node.name] then
            already_checked[node.name] = true
            local node_prot = gutils.deconstruct(node.prot)
            local fluid_prot = data.raw[node_prot.type][node_prot.name]

            gutils.add_edge(graph, node, spoof_node)
        end
    end
end

local already_added_extra = {}

entity_operation_fluid.claim = function(graph, prereq, dep, edge)
    if prereq.type == "fluid" and dep.type == "entity-operate-fluid" then
        -- Check for being a spoof
        if dep.spoof then
            return 1
        end

        local entity_key = gutils.deconstruct(dep.prot)
        local entity = data.raw[entity_key.type][entity_key.name]
        if entity.type == "generator" and (entity.fluid_box.filter == nil or entity.burns_fluid) then
            -- Don't randomize fuel-powered generators
            -- TODO: Support for fluid burning (not just heating) generators
            return false
        end
        if entity.type == "generator" and (entity.fluid_box.filter == nil or not entity.burns_fluid) then
            -- Don't randomize temperature-based generators either
            -- TODO: We might need to somehow consider heating pipeline all at once
            return false
        end
        if entity.type == "fusion-generator" then
            -- We have similar issues for fusion generators as for generators
            return false
        end
        if not already_added_extra[prereq.name] then
            already_added_extra[prereq.name] = true
            return 2
        else
            return 1
        end
    end
end

entity_operation_fluid.validate = function(graph, base, head, extra)
    local base_owner = gutils.get_owner(graph, base)

    if base_owner.type ~= "fluid" then
        return false
    end

    local fluid = data.raw.fluid[base_owner.name]

    -- Don't accept spoofed fluids
    if fluid == nil then
        return false
    end

    return true
end

entity_operation_fluid.reflect = function(graph, head_to_base, head_to_handler)
    for head_key, base_key in pairs(head_to_base) do
        if head_to_handler[head_key].id == "entity_operation_fluid" then
            local base = graph.nodes[base_key]
            local head = graph.nodes[head_key]
            local fluid_op_node = gutils.get_owner(graph, head)
            local entity_op_node = gutils.unique_depconn(graph, fluid_op_node)
            if not entity_op_node.spoof then
                local fluid_node = gutils.get_owner(graph, base)
                local fluid = dutils.get_prot("fluid", fluid_node.name)
                local entity = dutils.get_prot("entity", entity_op_node.name)

                -- Now, based on entity type, change fluids
                if entity.type == "boiler" then
                    -- TODO: Support boilers without filters (those would be weird though)
                    entity.fluid_box.filter = fluid.name
                elseif entity.type == "fusion-generator" then
                    -- Note: not currently supported
                    entity.input_fluid_box.filter = fluid.name
                elseif entity.type == "fusion-reactor" then
                    entity.input_fluid_box.filter = fluid.name
                elseif entity.type == "generator" then
                    -- Note: not currently supported
                    entity.fluid_box.filter = fluid.name
                elseif entity.type == "fluid-turret" then
                    entity.attack_parameters.fluids[head.ind].type = fluid.name
                end
            end
        end
    end
end

return entity_operation_fluid