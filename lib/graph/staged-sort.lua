-- Staged sorts: one contextual sort (context-sort.lua) continued in stages, so that pebbles needing a later stage rank after everything reachable before it
-- Each stage opens a gate, which turns on the gated changes of that stage:
--   * a relaxed edge (a prerequisite of an AND node that a repair could replace): m --> r becomes m --> slot --> r plus gate --> slot, so once the gate is open r no longer needs m (it counts as filled by anything)
--   * an added edge (like a debt edge from an older world): u --> v becomes u --> join --> v, where join also needs the gate, so the edge only exists once the gate is open
-- Earliest-provider witnesses (top.path) then go through a gate only where nothing reached before its stage works, so they use cheaper stages before costlier ones
-- Used to find where contradictions need repairs and which debt edges a superposed reference still owes (see notes/old/context-shift-report)

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")

local key = gutils.key

local staged = {}

-- Connector node types: existing transmitter types, "head" (OR) and "base" (AND), so the sort treats them like any other node
local OR_TYPE = "head"
local AND_TYPE = "base"

local SOURCE_KEY = key(AND_TYPE, "staged-source")

local function gate_key(stage)
    return key(OR_TYPE, "staged-gate: " .. stage)
end

local function add_connector(graph, node_type, name, op)
    local node = gutils.add_node(graph, node_type, name)
    node.op = op
    return key(node)
end

local function copy_extras(edge)
    local extra = {}
    for k, v in pairs(edge) do
        if k ~= "object_type" and k ~= "start" and k ~= "stop" then
            extra[k] = v
        end
    end
    return extra
end

-- params:
--   * graph: the graph to sort (copied, never changed)
--   * stages: stage names, in the order their gates open
--   * relax: list of { edge_key, stage }, edges into AND nodes that count as satisfied from that stage on
--   * add: list of { start, stop, extra (edge extras like abilities, optional), stage }, edges that exist from that stage on
--   * extra: options for top.sort (complex_contexts, home_contexts, home_sets, choose_randomly)
-- Returns the staged sort:
--   * graph and sort_info: the gated graph and its sort after every stage
--   * stage_starts: stage name --> rank of the first pebble reached in it
--   * stage_of(ind): the stage a pebble (by rank) was first reached in, or nil for before any gate
--   * gates_on_witness(goal_inds): the gated changes the goals' earliest-provider witness goes through, as id --> { kind ("relax" or "add"), stage, edge_key (relax) or start and stop (add), contexts = context --> true }
staged.sort = function(params)
    local graph = table.deepcopy(params.graph)
    local extra = params.extra or {}
    add_connector(graph, AND_TYPE, "staged-source", "AND")
    local is_stage = {}
    for _, stage in pairs(params.stages) do
        is_stage[stage] = true
        add_connector(graph, OR_TYPE, "staged-gate: " .. stage, "OR")
    end

    -- Slot key --> { edge_key, stage, start }, for relaxed edges
    local slots = {}
    for _, change in pairs(params.relax or {}) do
        assert(is_stage[change.stage], "unknown stage " .. tostring(change.stage))
        local edge = graph.edges[change.edge_key]
        assert(edge ~= nil, "no edge " .. change.edge_key)
        assert(graph.nodes[edge.stop].op == "AND", "relaxed edges go into AND nodes: " .. change.edge_key)
        local extras = copy_extras(edge)
        gutils.remove_edge(graph, change.edge_key)
        local slot_key = add_connector(graph, OR_TYPE, "staged-slot: " .. change.edge_key, "OR")
        -- The edge's abilities stay on the way from its start, so the slot gets exactly what the edge delivered
        gutils.add_edge(graph, edge.start, slot_key, extras)
        gutils.add_edge(graph, slot_key, edge.stop)
        gutils.add_edge(graph, gate_key(change.stage), slot_key)
        slots[slot_key] = {
            edge_key = change.edge_key,
            stage = change.stage,
            start = edge.start,
        }
    end

    -- Join key --> { start, stop, stage }, for added edges
    local joins = {}
    for _, change in pairs(params.add or {}) do
        assert(is_stage[change.stage], "unknown stage " .. tostring(change.stage))
        assert(graph.nodes[change.start] ~= nil and graph.nodes[change.stop] ~= nil, "added edge needs both nodes: " .. change.start .. " --> " .. change.stop)
        local join_key = add_connector(graph, AND_TYPE, "staged-join: " .. change.start .. " --> " .. change.stop, "AND")
        gutils.add_edge(graph, change.start, join_key, change.extra)
        gutils.add_edge(graph, gate_key(change.stage), join_key)
        gutils.add_edge(graph, join_key, change.stop)
        joins[join_key] = {
            start = change.start,
            stop = change.stop,
            stage = change.stage,
        }
    end

    -- Stage 0: every gate closed
    local sort_info = top.sort(graph, nil, nil, extra)
    local stage_starts = {}
    local stage_order = {}
    for _, stage in pairs(params.stages) do
        stage_starts[stage] = #sort_info.sorted + 1
        table.insert(stage_order, stage)
        -- Open the gate and continue the same sort, so everything new ranks after what came before
        gutils.add_edge(graph, SOURCE_KEY, gate_key(stage))
        sort_info = top.sort(graph, sort_info, {
            graph.nodes[SOURCE_KEY],
            graph.nodes[gate_key(stage)],
        }, {
            choose_randomly = extra.choose_randomly,
        })
    end

    local result = {
        graph = graph,
        sort_info = sort_info,
        stage_starts = stage_starts,
    }

    result.stage_of = function(ind)
        local found
        for _, stage in pairs(stage_order) do
            if ind >= stage_starts[stage] then
                found = stage
            end
        end
        return found
    end

    -- Earliest pebble of an edge's start that gets context through the edge, like the provider top.path picks for an OR node
    local nci = sort_info.node_to_context_inds
    local function provider_ind(edge, context)
        local earliest
        for _, source in pairs(top.edge_source_contexts(sort_info, edge, context)) do
            local ind = (nci[edge.start] or {})[source]
            if ind ~= nil and (earliest == nil or ind < earliest) then
                earliest = ind
            end
        end
        return earliest
    end

    result.gates_on_witness = function(goal_inds)
        local path = top.path(graph, table.deepcopy(goal_inds), sort_info).in_path
        local used = {}
        for ind, _ in pairs(path) do
            local pebble = sort_info.sorted[ind]
            local slot = slots[pebble.node_key]
            if slot ~= nil then
                -- top.path gives an OR node's earliest provider, so the slot is filled by the gate exactly when the gate's pebble comes first
                local gate_ind
                local start_ind
                for pre, _ in pairs(graph.nodes[pebble.node_key].pre) do
                    local edge = graph.edges[pre]
                    if edge.start == gate_key(slot.stage) then
                        gate_ind = provider_ind(edge, pebble.context)
                    else
                        start_ind = provider_ind(edge, pebble.context)
                    end
                end
                if gate_ind ~= nil and gate_ind < ind and (start_ind == nil or start_ind >= ind or gate_ind < start_ind) then
                    used[slot.edge_key] = used[slot.edge_key] or {
                        kind = "relax",
                        stage = slot.stage,
                        edge_key = slot.edge_key,
                        contexts = {},
                    }
                    used[slot.edge_key].contexts[pebble.context] = true
                end
            end
            local join = joins[pebble.node_key]
            if join ~= nil then
                local id = gutils.ekey(join)
                used[id] = used[id] or {
                    kind = "add",
                    stage = join.stage,
                    start = join.start,
                    stop = join.stop,
                    contexts = {},
                }
                used[id].contexts[pebble.context] = true
            end
        end
        return used
    end

    return result
end

return staged
