-- Settlement (see notes/context-shift-report): after the rest of randomization, fixes whatever the finished game still owes from a shift superposed on it (lib/graph/superpose.lua)
-- The owed goals' solvency-first witnesses (a staged sort of the game, then its debt edges behind a gate) name the debt edges still needed
-- Settlers, one per kind of shifted feature, offer fixes for the debt edges they own, cheapest first (the ladder: repair, duplicate, addition, revert)
-- Each round applies the next fix of every debt edge on the witnesses, then checks the game again, until nothing is owed or no fix is left
-- A new kind of shift plugs in with a settler of its own; this file doesn't know what the features are

local gutils = require("lib/graph/graph-utils")
local staged = require("lib/graph/staged-sort")

local settlement = {}

local function copy_extras(edge)
    local extra = {}
    for k, v in pairs(edge) do
        if k ~= "object_type" and k ~= "start" and k ~= "stop" then
            extra[k] = v
        end
    end
    return extra
end

-- Earliest pebble in a sort of each failure (any of its keys, in its context if it has one)
local function goal_inds(failures, sort_info)
    local inds = {}
    for _, failure in pairs(failures) do
        local earliest
        for _, node_key in pairs(failure.keys) do
            for context, ind in pairs(sort_info.node_to_context_inds[node_key] or {}) do
                if (failure.context == nil or context == failure.context) and (earliest == nil or ind < earliest) then
                    earliest = ind
                end
            end
        end
        if earliest ~= nil then
            table.insert(inds, earliest)
        end
    end
    return inds
end

-- Debt edges (keys in debt.graph) on the solvency-first witnesses of the failures in the game (graph, sorted with sort_extra)
-- Returns edge key --> set of contexts it's used in
settlement.owed_edges = function(graph, sort_extra, failures, debt)
    local game = table.deepcopy(graph)
    for node_key, _ in pairs(debt.old_nodes) do
        if game.nodes[node_key] == nil then
            local copy = table.deepcopy(debt.graph.nodes[node_key])
            copy.pre = {}
            copy.dep = {}
            copy.num_pre = 0
            game.nodes[node_key] = copy
            game[node_key] = copy
        end
    end
    local add = {}
    for edge_key, _ in pairs(debt.debt_edges) do
        local edge = debt.graph.edges[edge_key]
        local stop = game.nodes[edge.stop]
        -- As in superpose.add_debt, only edges into OR nodes of the game (or into the old world's own nodes)
        if game.nodes[edge.start] ~= nil and stop ~= nil and (stop.op == "OR" or debt.old_nodes[edge.stop] ~= nil) and game.edges[edge_key] == nil then
            table.insert(add, {
                start = edge.start,
                stop = edge.stop,
                extra = copy_extras(edge),
                stage = "debt",
            })
        end
    end
    local result = staged.sort({
        graph = game,
        stages = {
            "debt",
        },
        add = add,
        extra = sort_extra,
    })
    local owed = {}
    for _, info in pairs(result.gates_on_witness(goal_inds(failures, result.sort_info))) do
        if info.kind == "add" then
            owed[gutils.ekey(info)] = info.contexts
        end
    end
    return owed
end

-- params:
--   check(): checks the game as it is now, returning { failures = what's still owed (each { text, keys = node keys any of which counts, context or nil for any }), graph = the game's logic graph, sort_extra = options to sort it with }
--   debt: the superposition's debt (graph, debt_edges and old_nodes, as superpose.union returns them)
--   settlers: list of { name, owns = function(edge) (edge from debt.graph), fixes = function(edge) returning a list of { rung, text, apply = function(), undo = function() }, cheapest first }
--   max_rounds (optional, default 5)
-- Returns { applied = the fixes applied, failures = what's still owed, unsettled = edge key --> set of contexts for owed debt edges no fix is left for }
settlement.settle = function(params)
    local tried = {}
    local applied = {}
    local result
    for _ = 1, params.max_rounds or 5 do
        result = params.check()
        if #result.failures == 0 then
            return {
                applied = applied,
                failures = {},
                unsettled = {},
            }
        end
        local owed = settlement.owed_edges(result.graph, result.sort_extra, result.failures, params.debt)
        local edge_keys = {}
        for edge_key, _ in pairs(owed) do
            table.insert(edge_keys, edge_key)
        end
        table.sort(edge_keys)
        local unsettled = {}
        local num_applied = 0
        for _, edge_key in pairs(edge_keys) do
            local edge = params.debt.graph.edges[edge_key]
            local fix
            for _, settler in pairs(params.settlers) do
                if fix == nil and settler.owns(edge) then
                    local fixes = settler.fixes(edge)
                    local next_fix = (tried[edge_key] or 0) + 1
                    fix = fixes[next_fix]
                    if fix ~= nil then
                        tried[edge_key] = next_fix
                    end
                end
            end
            if fix ~= nil then
                fix.apply()
                table.insert(applied, fix)
                num_applied = num_applied + 1
            else
                unsettled[edge_key] = owed[edge_key]
            end
        end
        if num_applied == 0 then
            return {
                applied = applied,
                failures = result.failures,
                unsettled = unsettled,
            }
        end
    end
    result = params.check()
    return {
        applied = applied,
        failures = result.failures,
        unsettled = {},
    }
end

return settlement
