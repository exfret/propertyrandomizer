-- Recipe production without an extra item-craft OR node.
-- Only a craft node feeding its item alone is folded; actual trigger sources stay.
-- Production edges keep their role, and expansion restores the builder's shape before graphs are combined.
-- Queries use recipe witnesses, never acquisition contexts of the item (which can also come from mining, delivery or spoilage).

local gutils = require("src/lib/graph/graph-utils")
local logic = require("src/logic/state")

local craft = {}

local function extras(object)
    local result = {}
    for field, value in pairs(object) do
        if field ~= "object_type" and field ~= "type" and field ~= "name" and field ~= "start" and field ~= "stop" and field ~= "pre" and field ~= "dep" and field ~= "num_pre" then
            result[field] = table.deepcopy(value)
        end
    end
    return result
end

local function remove_node(graph, node_key)
    graph.nodes[node_key] = nil
    graph[node_key] = nil
    graph.sources[node_key] = nil
end

local function remove_edge(graph, edge_key)
    gutils.remove_edge(graph, edge_key)
    graph[edge_key] = nil
end

-- The original input edge, before make_orands put a connector on it.
craft.input_edge = function(graph, edge_key)
    local edge = graph.edges[edge_key]
    local node = graph.nodes[edge.start]
    if node.type == "orand" then
        return gutils.unique_pre(graph, node)
    end
    return edge
end

-- Production inputs of an item or its separate craft node, in key order.
-- branch_key is the connector to remove when a recipe stops making the item.
craft.providers = function(graph, item_name)
    local node = graph.nodes[gutils.key("item-craft", item_name)]
    local separate = node ~= nil
    node = node or graph.nodes[gutils.key("item", item_name)]
    local providers = {}
    for edge_key, _ in pairs((node or {}).pre or {}) do
        local edge = craft.input_edge(graph, edge_key)
        if separate or edge.item_craft == true then
            table.insert(providers, {
                key = edge.start,
                edge = edge,
                branch_key = graph.edges[edge_key].start,
            })
        end
    end
    table.sort(providers, function(a, b) return gutils.ekey(a.edge) < gutils.ekey(b.edge) end)
    return providers
end

-- A folded crafting query returns the union of its recipe contexts, with each rank pointing to a real recipe witness for callers that walk top.path.
craft.context_inds = function(graph, sort_info, node_key)
    local contexts = sort_info.node_to_context_inds[node_key]
    if contexts ~= nil or gutils.deconstruct(node_key).type ~= "item-craft" then
        return contexts or {}
    end
    local result = {}
    for _, provider in pairs(craft.providers(graph, gutils.deconstruct(node_key).name)) do
        for context, ind in pairs(sort_info.node_to_context_inds[provider.key] or {}) do
            if result[context] == nil or ind < result[context] then
                result[context] = ind
            end
        end
    end
    return result
end

craft.contract = function(graph)
    local keys = {}
    for node_key, node in pairs(graph.nodes) do
        if node.type == "item-craft" then
            table.insert(keys, node_key)
        end
    end
    table.sort(keys)
    local count = 0
    for _, node_key in pairs(keys) do
        local node = graph.nodes[node_key]
        local out_key = next(node.dep)
        local out = out_key ~= nil and graph.edges[out_key] or nil
        local item_key = gutils.key("item", node.name)
        local info = logic.type_info[node.type] or {}
        local item = graph.nodes[item_key]
        local safe = node.op == "OR" and item ~= nil and item.op == "OR" and out ~= nil and next(node.dep, out_key) == nil and out.stop == item_key and out.amount == 1
        if info.context ~= nil or info.research_input == true or info.home_carrier == true or info.relay == true then
            safe = false
        end
        local fields = extras(node)
        for field, _ in pairs(fields) do
            if field ~= "op" and field ~= "class" and field ~= "prot" then
                safe = false
            end
        end
        for field, _ in pairs(out ~= nil and extras(out) or {}) do
            if field ~= "amount" then
                safe = false
            end
        end
        local pres = {}
        for pre_key, _ in pairs(node.pre) do
            local edge = graph.edges[pre_key]
            local source = graph.nodes[edge.start]
            local info = logic.type_info[source.type] or {}
            if source.type ~= "recipe" or edge.abilities ~= nil or info.context ~= nil or info.research_input == true or info.home_carrier == true or info.relay == true or graph.edges[gutils.ekey({
                start = edge.start,
                stop = item_key,
            })] ~= nil then
                safe = false
            end
            table.insert(pres, pre_key)
        end
        if safe then
            graph.item_craft_nodes = graph.item_craft_nodes or {}
            graph.item_craft_nodes[node_key] = fields
            for _, pre_key in pairs(pres) do
                local edge = graph.edges[pre_key]
                local extra = extras(edge)
                extra.item_craft = true
                remove_edge(graph, pre_key)
                gutils.add_edge(graph, edge.start, item_key, extra)
            end
            remove_edge(graph, out_key)
            remove_node(graph, node_key)
            count = count + 1
        end
    end
    return count
end

-- Restore one node for a caller that needs an explicit OR, moving its production edges back.
-- Expansion happens before subdivision, on physical logic graphs.
craft.expand = function(graph, item_name)
    local node_key = gutils.key("item-craft", item_name)
    if graph.nodes[node_key] ~= nil then
        return node_key
    end
    local fields = (graph.item_craft_nodes or {})[node_key]
    if fields == nil then
        return nil
    end
    local providers = craft.providers(graph, item_name)
    gutils.add_node(graph, "item-craft", item_name, table.deepcopy(fields))
    for _, provider in pairs(providers) do
        assert(provider.branch_key == provider.key, "expand item-craft before subdividing edges")
        local extra = extras(provider.edge)
        extra.item_craft = nil
        remove_edge(graph, gutils.ekey(provider.edge))
        gutils.add_edge(graph, provider.key, node_key, extra)
    end
    gutils.add_edge(graph, node_key, gutils.key("item", item_name), { amount = 1 })
    graph.item_craft_nodes[node_key] = nil
    return node_key
end

craft.expand_all = function(graph)
    local keys = {}
    for node_key, _ in pairs(graph.item_craft_nodes or {}) do
        table.insert(keys, node_key)
    end
    table.sort(keys)
    for _, node_key in pairs(keys) do
        craft.expand(graph, gutils.deconstruct(node_key).name)
    end
    return #keys
end

-- Trigger candidates need a production OR too, with no edge to the item.
-- Subdivision merges it into the candidate's matching base (fuse_options).
craft.add_option = function(graph, item_name)
    local node_key = gutils.key("item-craft", item_name)
    if graph.nodes[node_key] ~= nil then
        return node_key
    end
    local fields = (graph.item_craft_nodes or {})[node_key]
    if fields == nil then
        return nil
    end
    local providers = craft.providers(graph, item_name)
    local extra = table.deepcopy(fields)
    extra.craft_option_only = true
    gutils.add_node(graph, "item-craft", item_name, extra)
    for _, provider in pairs(providers) do
        gutils.add_edge(graph, provider.key, node_key, extras(provider.edge))
    end
    return node_key
end

craft.fuse_options = function(graph)
    local bases = {}
    for node_key, node in pairs(graph.nodes) do
        if node.type == "base" and node.trigger_option ~= nil and node.trigger_option.kind == "craft-item" then
            table.insert(bases, node_key)
        end
    end
    table.sort(bases)
    local count = 0
    for _, base_key in pairs(bases) do
        local base = graph.nodes[base_key]
        local owner = gutils.get_owner(graph, base)
        if owner.craft_option_only == true then
            local owner_key = gutils.key(owner)
            assert(owner.num_pre > 0 and next(owner.dep, next(owner.dep)) == nil, "craft option must only feed its base")
            remove_edge(graph, gutils.ekey(gutils.unique_pre(graph, base)))
            base.op = "OR"
            base.source_owner = {
                type = "item-craft",
                name = owner.name,
                prot = owner.prot,
                class = owner.class,
            }
            base.craft_item = owner.name
            -- Share the item's existing production connectors to keep the reduction with multiple recipe providers.
            graph.node_to_orands[base_key] = {}
            for _, provider in pairs(craft.providers(graph, owner.name)) do
                -- Find the temporary option's matching production branch on the item before deleting this copy.
                local item = graph.nodes[gutils.key("item", owner.name)]
                for item_pre, _ in pairs(item.pre) do
                    local input = craft.input_edge(graph, item_pre)
                    if input.item_craft == true and input.start == provider.key then
                        local shared = graph.edges[item_pre].start
                        gutils.add_edge(graph, shared, base_key)
                        graph.node_to_orands[base_key][shared] = true
                    end
                end
                local branch = graph.nodes[provider.branch_key]
                for pre, _ in pairs(table.deepcopy(branch.pre)) do
                    remove_edge(graph, pre)
                end
                for dep, _ in pairs(table.deepcopy(branch.dep)) do
                    remove_edge(graph, dep)
                end
                graph.orand_to_parent[provider.branch_key] = nil
                graph.orand_to_child[provider.branch_key] = nil
                remove_node(graph, provider.branch_key)
            end
            graph.node_to_orands[owner_key] = nil
            remove_node(graph, owner_key)
            graph.craft_option_bases = graph.craft_option_bases or {}
            graph.craft_option_bases[owner.name] = base_key
            count = count + 1
        end
    end
    return count
end

-- The claiming graph keeps temporary option groups until their edges are claimed.
-- First pass ranks the physical positions after detached options have been cut, so those groups and their private connectors can then be discarded.
craft.discard_options = function(graph)
    local keys = {}
    for node_key, node in pairs(graph.nodes) do
        if node.type == "item-craft" and node.craft_option_only == true then
            table.insert(keys, node_key)
        end
    end
    for _, node_key in pairs(keys) do
        local node = graph.nodes[node_key]
        assert(next(node.dep) == nil, "detach craft options before discarding their temporary sources")
        for edge_key, _ in pairs(table.deepcopy(node.pre)) do
            local branch_key = graph.edges[edge_key].start
            local branch = graph.nodes[branch_key]
            assert(branch.type == "orand" and branch.craft_option_only == true)
            for pre, _ in pairs(table.deepcopy(branch.pre)) do
                remove_edge(graph, pre)
            end
            remove_edge(graph, edge_key)
            graph.orand_to_parent[branch_key] = nil
            graph.orand_to_child[branch_key] = nil
            remove_node(graph, branch_key)
        end
        for branch_key, child_key in pairs(graph.orand_to_child) do
            if child_key == node_key then
                graph.orand_to_child[branch_key] = gutils.key("false", "")
            end
        end
        graph.node_to_orands[node_key] = nil
        remove_node(graph, node_key)
    end
end

-- The production aggregators that derived recycling may add providers to.
craft.targets = function(graph, item_name)
    local result = {}
    local node_key = gutils.key("item-craft", item_name)
    if graph.nodes[node_key] == nil then
        node_key = gutils.key("item", item_name)
    end
    if graph.nodes[node_key] ~= nil then
        table.insert(result, node_key)
    end
    local base_key = (graph.craft_option_bases or {})[item_name]
    if base_key ~= nil and graph.nodes[base_key] ~= nil then
        table.insert(result, base_key)
    end
    table.sort(result)
    return result
end

return craft
