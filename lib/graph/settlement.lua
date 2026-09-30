-- Settlement (see notes/context-shift-report): after the rest of randomization, fixes whatever the finished game still owes from a shift superposed on it (lib/graph/superpose.lua)
-- The owed goals' solvency-first witnesses (a staged sort of the game, then its debt edges behind a gate) name the debt edges still needed
-- Settlers, one per kind of shifted feature, offer fixes for the debt edges they own, cheapest first (the ladder: repair, duplicate, addition, revert)
-- Each round applies the next fix of every debt edge on the witnesses, then checks the game again, until nothing is owed or no fix is left
-- A new kind of shift plugs in with a settler of its own; this file doesn't know what the features are

local gutils = require("lib/graph/graph-utils")
local staged = require("lib/graph/staged-sort")
local top = require("lib/graph/context-sort")

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

-- Earliest pebble in a sort of each failure (any of its keys, in its context if it has one; an isolatable pebble counts for a context without isolatability, see top.provides_context)
local function goal_inds(failures, sort_info)
    local inds = {}
    for _, failure in pairs(failures) do
        local earliest
        for _, node_key in pairs(failure.keys) do
            for context, ind in pairs(sort_info.node_to_context_inds[node_key] or {}) do
                if (failure.context == nil or top.provides_context({ [context] = true }, failure.context)) and (earliest == nil or ind < earliest) then
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
    -- The nodes the game lacks, from the superposition: the old world's own nodes, and nodes the game had when the superposition was made but lost since (see below)
    local added_nodes = {}
    local function add_node(node_key)
        if game.nodes[node_key] ~= nil or debt.graph.nodes[node_key] == nil then
            return false
        end
        local copy = table.deepcopy(debt.graph.nodes[node_key])
        copy.pre = {}
        copy.dep = {}
        copy.num_pre = 0
        game.nodes[node_key] = copy
        game[node_key] = copy
        added_nodes[node_key] = true
        return true
    end
    for node_key, _ in pairs(debt.old_nodes) do
        add_node(node_key)
    end
    -- As in superpose.add_debt, only edges into OR nodes of the game (or into nodes only the superposition has)
    -- A debt edge whose start the game no longer has (a recipe category set no recipe has any more, once randomization changed the categories) brings that node of the superposition along, with its own in-edges as debt, so an old node it fed (a recipe that left the game for a variant) stays reachable through the debt and the settlers' fixes for it are found
    local pending = {}
    for edge_key, _ in pairs(debt.debt_edges) do
        table.insert(pending, edge_key)
    end
    table.sort(pending)
    local considered = {}
    local add = {}
    while #pending > 0 do
        local edge_key = table.remove(pending)
        if considered[edge_key] == nil then
            considered[edge_key] = true
            local edge = debt.graph.edges[edge_key]
            local stop = game.nodes[edge.stop]
            if stop ~= nil and (stop.op == "OR" or added_nodes[edge.stop] ~= nil) and game.edges[edge_key] == nil then
                if game.nodes[edge.start] == nil and add_node(edge.start) then
                    local in_edges = {}
                    for pre_key, _ in pairs(debt.graph.nodes[edge.start].pre) do
                        table.insert(in_edges, pre_key)
                    end
                    table.sort(in_edges)
                    for _, pre_key in pairs(in_edges) do
                        table.insert(pending, pre_key)
                    end
                end
                if game.nodes[edge.start] ~= nil then
                    table.insert(add, {
                        start = edge.start,
                        stop = edge.stop,
                        extra = copy_extras(edge),
                        stage = "debt",
                    })
                end
            end
        end
    end
    table.sort(add, function(a, b)
        return gutils.ekey(a) < gutils.ekey(b)
    end)
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
    -- A goal the debt doesn't reach either has no witness and so no fix: why not, as the unreached prerequisites under it (debugging aid, like the lock stage's in randomizations/planetary/execute.lua)
    local num_explained = 0
    for _, failure in pairs(failures) do
        if num_explained < 6 and next(goal_inds({ failure }, result.sort_info)) == nil then
            num_explained = num_explained + 1
            settlement.explain(game, result.sort_info, failure)
        end
    end
    -- Which goals need each owed edge (their own witness goes through it), for the log: a witness walk per goal, no extra sort
    local users = {}
    for _, failure in pairs(failures) do
        for _, info in pairs(result.gates_on_witness(goal_inds({ failure }, result.sort_info))) do
            if info.kind == "add" then
                local edge_key = gutils.ekey(info)
                users[edge_key] = users[edge_key] or {}
                if #users[edge_key] < 3 then
                    table.insert(users[edge_key], failure.text)
                end
            end
        end
    end
    return owed, users
end

-- Logs why a failure's goal isn't reached in its context (or anywhere, for a failure without one) in a sort of graph: the first unreached prerequisite under each AND node, every one under an OR node, a few levels down
settlement.explain = function(graph, sort_info, failure)
    local reached = sort_info.node_to_context_inds
    local function is_reached(node_key)
        local contexts = reached[node_key] or {}
        if failure.context == nil then
            return next(contexts) ~= nil
        end
        return top.provides_context(contexts, failure.context)
    end
    local seen = {}
    local function explain(node_key, depth)
        if depth > 12 or seen[node_key] ~= nil then
            return
        end
        seen[node_key] = true
        local node = graph.nodes[node_key]
        if node == nil or is_reached(node_key) then
            return
        end
        log("Settlement: " .. string.rep("  ", depth) .. node_key .. " (" .. tostring(node.op) .. ") not reached" .. (next(reached[node_key] or {}) ~= nil and " in this context (reached elsewhere)" or ""))
        local prekeys = {}
        for pre, _ in pairs(node.pre) do
            table.insert(prekeys, graph.edges[pre].start)
        end
        table.sort(prekeys)
        for _, prekey in pairs(prekeys) do
            if not is_reached(prekey) then
                explain(prekey, depth + 1)
                if node.op == "AND" then
                    break
                end
            end
        end
    end
    log("Settlement: no witness for " .. failure.text .. ", even with the debt:")
    explain(failure.keys[1], 1)
end

-- params:
--   check(): checks the game as it is now, returning { failures = what's still owed (each { text, keys = node keys any of which counts, context or nil for any }), graph = the game's logic graph, sort_extra = options to sort it with }
--   debt: the superposition's debt (graph, debt_edges and old_nodes, as superpose.union returns them)
--   settlers: list of { name, owns = function(edge) (edge from debt.graph), fixes = function(edge) returning a list of { rung, text, apply = function(), undo = function() }, cheapest first }
--   max_rounds (optional, default 5)
-- Each fix applied records the goals whose witnesses needed its edge (needed_by, up to three), for the log
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
        local owed, users = settlement.owed_edges(result.graph, result.sort_extra, result.failures, params.debt)
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
                fix.needed_by = users[edge_key] or {}
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
