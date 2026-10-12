-- Find recipe or other unlock gates covering every way to acquire a target.
-- The caller decides which nodes can be gated and which gates preserve its cycles and contexts.
-- This is structural reachability only: contexts and edge abilities need the caller's separate check.
local sources = {}

-- Build only the target's ancestors.
-- Keep gate prerequisites too, so a gate depending on its own result cannot count as an independent acquisition just because it is a gate.
local function ancestors(graph, target_key)
    local slice = {}
    local queue = { target_key }
    local queued = { [target_key] = true }
    local i = 1
    while i <= #queue do
        local node_key = queue[i]
        local node = graph.nodes[node_key]
        local entry = slice[node_key] or {
            dep = {},
            num_pre = 0,
        }
        slice[node_key] = entry
        entry.node = node
        for edge_key, _ in pairs(node.pre) do
            local pre_key = graph.edges[edge_key].start
            local pre = slice[pre_key] or {
                dep = {},
                num_pre = 0,
            }
            slice[pre_key] = pre
            table.insert(pre.dep, node_key)
            entry.num_pre = entry.num_pre + 1
            if queued[pre_key] == nil then
                queued[pre_key] = true
                table.insert(queue, pre_key)
            end
        end
        i = i + 1
    end
    return slice
end

-- Least fixed point of the AND/OR graph, with blocked nodes unavailable.
-- Cycles can carry an acquisition once a real source reaches them, but never seed one.
local function reachable(slice, blocked)
    local reached = {}
    local remaining = {}
    local queue = {}
    local function add(node_key)
        if reached[node_key] == nil and blocked[node_key] == nil then
            reached[node_key] = true
            table.insert(queue, node_key)
        end
    end
    for node_key, entry in pairs(slice) do
        remaining[node_key] = entry.num_pre
        if entry.node.op == "AND" and entry.num_pre == 0 then
            add(node_key)
        end
    end
    local i = 1
    while i <= #queue do
        for _, dep_key in pairs(slice[queue[i]].dep) do
            remaining[dep_key] = remaining[dep_key] - 1
            if slice[dep_key].node.op == "OR" or remaining[dep_key] == 0 then
                add(dep_key)
            end
        end
        i = i + 1
    end
    return reached
end

-- Return { gates = set of node keys, ungated = boolean, reason = optional string }.
-- A plan is complete only when ungated is false.
-- Every returned gate is both allowed and structurally reachable.
-- Stop at the first eligible gates on each route rather than gating their ingredients as well.
-- A complete frontier is reduced to an inclusion-minimal cut, so an AND does not unnecessarily gate every mandatory input.
-- A target with no initial acquisition is reported rather than given a vacuous certificate.
sources.plan = function(graph, target_key, can_gate, gate_allowed)
    local gates = {}
    if graph.nodes[target_key] == nil then
        return {
            gates = gates,
            ungated = true,
            reason = "missing target",
        }
    end
    local slice = ancestors(graph, target_key)
    local original = reachable(slice, {})
    if original[target_key] == nil then
        return {
            gates = gates,
            ungated = true,
            reason = "unreachable",
        }
    end
    local queue = { target_key }
    local queued = { [target_key] = true }
    local i = 1
    while i <= #queue do
        local node_key = queue[i]
        local node = slice[node_key].node
        if original[node_key] ~= nil then
            if can_gate(node) and gate_allowed(node) then
                gates[node_key] = true
            else
                for edge_key, _ in pairs(node.pre) do
                    local pre_key = graph.edges[edge_key].start
                    if queued[pre_key] == nil then
                        queued[pre_key] = true
                        table.insert(queue, pre_key)
                    end
                end
            end
        end
        i = i + 1
    end
    local ungated = reachable(slice, gates)[target_key] ~= nil
    if not ungated then
        local ordered = {}
        for gate_key, _ in pairs(gates) do
            table.insert(ordered, gate_key)
        end
        table.sort(ordered)
        for _, gate_key in pairs(ordered) do
            gates[gate_key] = nil
            -- A removed gate stays removed only if every acquisition still crosses another gate.
            if reachable(slice, gates)[target_key] ~= nil then
                gates[gate_key] = true
            end
        end
    end
    return {
        gates = gates,
        ungated = ungated,
        reason = ungated and "ungated acquisition" or nil,
    }
end

return sources
