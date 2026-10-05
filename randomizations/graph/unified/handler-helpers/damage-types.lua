-- Prototype mutations and the graph consequences are one transaction.
-- Existing OR connectors retain their ability/context filters, including manual-only damage.

local gutils = require("lib/graph/graph-utils")

local helper = {}

local function keys(values)
    local result = {}
    for value, _ in pairs(values or {}) do
        table.insert(result, value)
    end
    table.sort(result)
    return result
end

helper.source_key = function(source_key, info)
    local source = gutils.deconstruct(source_key)
    if info.source_type == "ammo" then
        return gutils.key("item-ammo", source.name)
    elseif info.source_type == "turret" then
        return gutils.key("entity-operate", source.name)
    elseif info.source_type == "entity" then
        return gutils.key("entity", source.name)
    elseif info.source_type == "equipment" then
        return gutils.key("equipment-operate", source.name)
    end
end

helper.capture = function(graph)
    local result = {
        counters = {},
        damage = {},
        damage_links = {},
        carriers = {},
    }
    for _, node_key in pairs(keys(graph.nodes)) do
        local node = graph.nodes[node_key]
        if node.type == "combat-encounter-counters" or node.type == "damage-type" then
            local links = {}
            for _, edge_key in pairs(keys(node.pre)) do
                local start = graph.edges[edge_key].start
                local child = (graph.orand_to_child or {})[start] or start
                local source = graph.nodes[child]
                if node.type == "combat-encounter-counters" and source ~= nil and source.counter_name ~= nil then
                    links[start] = source
                elseif node.type == "damage-type" then
                    links[start] = child
                    -- Any existing connector for this source preserves its original ability filter.
                    result.carriers[child] = result.carriers[child] or start
                end
            end
            if node.type == "combat-encounter-counters" then
                result.counters[node_key] = links
            else
                result.damage[node_key] = node.name
                result.damage_links[node_key] = {}
                for carrier, source_key in pairs(links) do
                    result.damage_links[node_key][source_key] = carrier
                end
            end
        end
    end
    return result
end

helper.same_witness = function(node, candidate, policy)
    if candidate == nil or candidate.mode ~= node.deployment_mode then
        return false
    end
    local count = candidate.count or (candidate.mode == "turret" and policy.turret_count or policy.manual_count)
    local limit = candidate.mode == "turret" and policy.turret_count or policy.manual_count
    if type(count) ~= "number" or count < 1 or count % 1 ~= 0 or count > limit then
        return false
    end
    if type(candidate.clear_seconds) ~= "number" or candidate.clear_seconds ~= candidate.clear_seconds or candidate.clear_seconds <= 0 or candidate.clear_seconds > policy.clear_seconds then
        return false
    end
    local allowed = {}
    for _, prerequisite in pairs(node.counter_prerequisites or {}) do
        allowed[prerequisite] = true
    end
    if type(candidate.prerequisites) ~= "table" or #candidate.prerequisites == 0 then
        return false
    end
    for _, prerequisite in pairs(candidate.prerequisites) do
        if allowed[prerequisite] ~= true then
            return false
        end
    end
    return true
end

-- Only existing counter alternatives are reused. Newly successful attacks may be omitted safely.
helper.changes = function(graph, captured, evaluated, damage_sources, pre_keys_of)
    local desired = {}
    for node_key, links in pairs(captured.counters) do
        desired[node_key] = {}
        for carrier, node in pairs(links) do
            local result = evaluated[node.encounter_name]
            if result ~= nil and helper.same_witness(node, result.counters[node.counter_name], result.policy) then
                desired[node_key][carrier] = true
            end
        end
    end
    for node_key, damage_type in pairs(captured.damage) do
        desired[node_key] = {}
        for source_key, info in pairs(damage_sources[damage_type] or {}) do
            local source = helper.source_key(source_key, info)
            local carrier = captured.damage_links[node_key][source] or captured.carriers[source]
            if carrier ~= nil then
                desired[node_key][carrier] = true
            end
        end
    end
    local changes = {}
    for _, node_key in pairs(keys(desired)) do
        local current = {}
        if pre_keys_of ~= nil then
            for _, start in pairs(pre_keys_of(node_key)) do
                current[start] = true
            end
        else
            for edge_key, _ in pairs(graph.nodes[node_key].pre) do
                current[graph.edges[edge_key].start] = true
            end
        end
        local remove = {}
        for _, start in pairs(keys(current)) do
            if desired[node_key][start] == nil then
                table.insert(remove, start)
            end
        end
        if #remove > 0 then
            table.insert(changes, {
                node_key = node_key,
                remove = remove,
            })
        end
        for _, start in pairs(keys(desired[node_key])) do
            if current[start] == nil then
                table.insert(changes, {
                    node_key = node_key,
                    add = start,
                })
            end
        end
    end
    return changes
end

helper.attempt = function(packets, new_type, evaluate, commit)
    assert(type(new_type) == "string", "Damage mutation needs a named candidate type")
    for _, packet in pairs(packets) do
        assert(type(packet.type) == "string", "Damage mutation needs a named original type")
    end
    local previous = {}
    for _, packet in pairs(packets) do
        if previous[packet] == nil then
            previous[packet] = packet.type
            packet.type = new_type
        end
    end
    local ok, accepted = pcall(function()
        local trial = evaluate()
        return commit(trial) == true
    end)
    if ok ~= true or accepted ~= true then
        for packet, old_type in pairs(previous) do
            packet.type = old_type
        end
    end
    if ok ~= true then
        error(accepted)
    end
    return accepted
end

return helper
