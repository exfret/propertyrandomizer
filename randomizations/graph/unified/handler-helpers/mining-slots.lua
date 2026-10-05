-- Graph-only material positions: one per resource product, with independent identities in first pass.

local gutils = require("lib/graph/graph-utils")
local dutils = require("lib/data-utils")
local item_fluid = require("lib/item-fluid")
local graph_customization = require("lib/graph-customization")

local slots = {}

slots.material = function(node)
    if node.type == "item" then
        return {
            type = node.type,
            name = node.name,
        }
    elseif node.type == "fluid-create-temperature" then
        local parts = gutils.deconstruct(node.name)
        return {
            type = data.raw.fluid[parts.type].type,
            name = parts.type,
            temperature = tonumber(parts.name),
        }
    end
end

slots.spoof = function(graph)
    local edges = {}
    local lab_inputs = dutils.lab_inputs()
    for edge_key, edge in pairs(graph.edges) do
        local maker = graph.nodes[edge.start]
        local product = graph.nodes[edge.stop]
        local resource = maker.type == "entity-mine" and data.raw.resource[maker.name] or nil
        local material = slots.material(product)
        local is_eligible = material ~= nil and randomization_info.options.first_pass.blacklist[gutils.key(material)] == nil
        if is_eligible and material.type == "item" and lab_inputs[material.name] ~= nil then
            is_eligible = false
        end
        if is_eligible and material.type == "fluid" then
            local fluid_slot = graph.nodes[gutils.key("fluid-temperature", gutils.key(material.name, tostring(material.temperature)))]
            is_eligible = fluid_slot ~= nil and item_fluid.fluid_slot_ok(graph, fluid_slot)
        end
        if resource ~= nil and not dutils.mining_keeps_item_names(resource) and is_eligible and graph_customization.selected("mining-results", product) and graph_customization.selected("item", product) and not graph_customization.excluded("mining-results", maker) then
            table.insert(edges, edge_key)
        end
    end
    -- One deposit reuses the material's existing position, so recipe ingredients follow its chosen identity.
    -- Additional deposits get separate positions while sharing the same physical identities.
    local primary = {}
    for _, edge_key in pairs(edges) do
        local product = graph.nodes[graph.edges[edge_key].stop]
        local material = slots.material(product)
        if material.type == "item" then
            primary[gutils.key(product)] = gutils.key(product)
        else
            primary[gutils.key(product)] = gutils.key("fluid-temperature", gutils.key(material.name, tostring(material.temperature)))
        end
    end
    table.sort(edges)
    for _, edge_key in pairs(edges) do
        local edge = graph.edges[edge_key]
        local maker = graph.nodes[edge.start]
        local material = slots.material(graph.nodes[edge.stop])
        local name = "propertyrandomizer-mining-slot-" .. gutils.concat({
            maker.name,
            material.type,
            material.name,
        })
        local class = "item"
        if material.type == "fluid" then
            class = "fluid-temperature"
            name = gutils.key(name, tostring(material.temperature))
        end
        local stop = edge.stop
        local metadata = {
            node_type = class,
            resource_name = maker.name,
            material = material,
            inds = table.deepcopy(edge.inds),
        }
        if primary[stop] ~= nil then
            local primary_key = primary[stop]
            primary[stop] = nil
            metadata.primary = true
            graph.nodes[primary_key].mining_slot = metadata
        else
            local slot = gutils.add_node(graph, class, name, {
                op = material.type == "fluid" and "AND" or "OR",
                mining_slot = metadata,
            })
            if material.type == "fluid" then
                local original = graph.nodes[gutils.key("fluid-temperature", gutils.key(material.name, tostring(material.temperature)))]
                for pre, _ in pairs(original.pre) do
                    local provider = gutils.prenode(graph, pre)
                    if provider.type == "fluid-hold" then
                        local extra = table.deepcopy(graph.edges[pre])
                        extra.start = nil
                        extra.stop = nil
                        gutils.add_edge(graph, provider, slot, extra)
                    end
                end
            end
            gutils.redirect_edge_stop(graph, edge_key, gutils.key(slot))
            gutils.add_edge(graph, slot, stop)
        end
    end
end

-- Synthetic positions/identities keep distinct keys in the permutation, even when their physical items coincide.
slots.position_key = function(graph, node)
    if node.old_slot ~= nil then
        node = graph.nodes[node.old_slot]
    end
    if node.mining_slot ~= nil or node.production_slot ~= nil then
        return gutils.key(node)
    end
    local material = item_fluid.material_of_node(graph, node)
    return material ~= nil and item_fluid.material_key(material) or nil
end

slots.link_identities = function(graph, trav_to_head)
    local fluid_sources = {}
    local positions = {}
    for node_key, node in pairs(graph.nodes) do
        if node.slot == true and (node.production_slot ~= nil or (node.mining_slot ~= nil and node.mining_slot.primary ~= true)) then
            table.insert(positions, node_key)
        end
    end
    table.sort(positions)
    for _, slot_key in pairs(positions) do
        local slot = graph.nodes[slot_key]
        local trav = graph.nodes[slot.old_trav]
        for edge_key, _ in pairs(table.deepcopy(trav.dep)) do
            local gate = gutils.depnode(graph, edge_key)
            if gate.type == "orand" then
                assert(gate.num_pre == 1, "Mining identity link has multiple providers")
                for dep, _ in pairs(table.deepcopy(gate.dep)) do
                    gutils.remove_edge(graph, dep)
                end
                local gate_key = gutils.key(gate)
                local parent = graph.orand_to_parent[gate_key]
                graph.node_to_orands[parent][gate_key] = nil
                graph.orand_to_parent[gate_key] = nil
                graph.orand_to_child[gate_key] = nil
                gutils.remove_edge(graph, edge_key)
                graph.nodes[gate_key] = nil
                graph[gate_key] = nil
                graph.sources[gate_key] = nil
            else
                gutils.remove_edge(graph, edge_key)
            end
        end
        local material = (slot.production_slot or slot.mining_slot).material
        local original_key = gutils.key(material)
        if material.type == "fluid" then
            original_key = gutils.key("fluid-temperature", gutils.key(material.name, tostring(material.temperature)))
        end
        local original = assert(graph.nodes[original_key], "Mining slot has no material node: " .. original_key)
        local identity = graph.nodes[original.old_trav] or original
        identity.shares_mining_identity = true
        trav.shares_mining_identity = true
        trav.shared_identity_key = gutils.key(identity)
        if identity.op == "AND" and original.old_trav ~= nil and identity.num_pre == 1 then
            local provider = gutils.unique_prenode(graph, identity)
            if provider.type == "head" then
                -- Holding is required by every source position already; their alternatives form an OR identity.
                identity.op = "OR"
            end
        end
        if identity.op == "AND" then
            -- Fluid identities still require their holding prerequisite. Merge only their production heads.
            local identity_key = gutils.key(identity)
            local sources = fluid_sources[identity_key]
            if sources == nil then
                if original.old_trav ~= nil then
                    sources = gutils.add_node(graph, "item", "propertyrandomizer-mining-fluid-sources-" .. identity.name, { op = "OR" })
                    local head_key = gutils.key(trav_to_head[identity_key])
                    local edge_key = gutils.ekey({
                        start = head_key,
                        stop = identity_key,
                    })
                    assert(graph.edges[edge_key] ~= nil, "Fluid identity has no production head")
                    gutils.redirect_edge_stop(graph, edge_key, gutils.key(sources))
                    gutils.add_edge(graph, sources, identity)
                else
                    sources = assert(graph.nodes[gutils.key("fluid-create-temperature", gutils.key(material.name, tostring(material.temperature)))])
                end
                fluid_sources[identity_key] = sources
            end
            local head_key = gutils.key(trav_to_head[gutils.key(trav)])
            local edge_key = gutils.ekey({
                start = head_key,
                stop = gutils.key(trav),
            })
            gutils.redirect_edge_stop(graph, edge_key, gutils.key(sources))
            trav.op = identity.op
            for pre, _ in pairs(identity.pre) do
                local extra = table.deepcopy(graph.edges[pre])
                local start = extra.start
                extra.start = nil
                extra.stop = nil
                gutils.add_edge(graph, start, trav, extra)
            end
        else
            trav.op = identity.op
            gutils.add_edge(graph, trav, identity, { shared_identity = true })
            gutils.add_edge(graph, identity, trav, { shared_identity = true })
        end
    end
end

return slots
