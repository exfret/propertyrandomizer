-- Compile the item-to-operation corridor without changing acquisition alternatives.
-- A supplied item can traverse this corridor in a new order; external acquisitions remain facts from the real sort, so the local proof cannot manufacture supplies.
local top = require("src/lib/sort/context-sort")
local logic = require("src/logic/state")

local bundles = {}

local function frontier(node)
    return node.type == "item" or node.type == "fluid" or node.type == "fluid-temperature" or node.type == "recipe" or node.type == "technology"
end

bundles.compile = function(graph, item_key, operation_keys)
    local compiled = {
        graph = graph,
        item_key = item_key,
        operations = {},
        nodes = {},
        supported = false,
    }
    if graph.nodes[item_key] == nil or next(operation_keys or {}) == nil then
        return compiled
    end
    for operation_key, _ in pairs(operation_keys) do
        if graph.nodes[operation_key] == nil then
            return compiled
        end
        table.insert(compiled.operations, operation_key)
    end
    table.sort(compiled.operations)

    local affected = { [item_key] = true }
    local queue = { item_key }
    local i = 1
    while i <= #queue do
        for edge_key, _ in pairs(graph.nodes[queue[i]].dep) do
            local dep = graph.edges[edge_key].stop
            if affected[dep] == nil and not frontier(graph.nodes[dep]) then
                affected[dep] = true
                table.insert(queue, dep)
            end
        end
        i = i + 1
    end
    -- Discard forward branches that cannot lead to one of the requested operations.
    queue = {}
    for _, operation_key in pairs(compiled.operations) do
        if affected[operation_key] == nil then
            return compiled
        end
        compiled.nodes[operation_key] = true
        table.insert(queue, operation_key)
    end
    i = 1
    while i <= #queue do
        for edge_key, _ in pairs(graph.nodes[queue[i]].pre) do
            local pre = graph.edges[edge_key].start
            if affected[pre] ~= nil and compiled.nodes[pre] == nil then
                compiled.nodes[pre] = true
                table.insert(queue, pre)
            end
        end
        i = i + 1
    end
    compiled.supported = true
    return compiled
end

local function supplies(incoming, needed)
    if incoming == needed then
        return true
    end
    if top.context_room(incoming) ~= top.context_room(needed) or top.context_home(incoming) ~= top.context_home(needed) then
        return false
    end
    local have = top.context_mask(incoming)
    local want = top.context_mask(needed)
    if have == nil or want == nil then
        return false
    end
    return top.mask_covers(have, want)
end

local function better(candidate, old)
    return candidate ~= nil and (old == nil or candidate.rank < old.rank or (candidate.rank == old.rank and candidate.count < old.count))
end

local function combine(proofs)
    local result = {
        rank = 0,
        leaves = {},
        count = 0,
    }
    for _, proof in pairs(proofs) do
        result.rank = math.max(result.rank, proof.rank)
        for leaf, _ in pairs(proof.leaves) do
            if result.leaves[leaf] == nil then
                result.leaves[leaf] = true
                result.count = result.count + 1
            end
        end
    end
    return result
end

-- Context-changing nodes keep the real sort's delivery/discovery witness.
-- Ordinary corridor nodes use a least fixed point, not the original order of their pebbles.
-- Optional levels rank external facts by acquisition/research layer instead of index.
bundles.prove = function(compiled, sort_info, context, levels)
    if compiled == nil or not compiled.supported or context == nil then
        return nil
    end
    local graph = compiled.graph
    local nci = sort_info.node_to_context_inds
    local states = {}
    local ordered = {}
    local get_state
    get_state = function(node_key, needed)
        states[node_key] = states[node_key] or {}
        if states[node_key][needed] ~= nil then
            return states[node_key][needed]
        end
        local state = {
            groups = {},
            dependents = {},
        }
        states[node_key][needed] = state
        table.insert(ordered, state)
        local ind = (nci[node_key] or {})[needed]
        local node = graph.nodes[node_key]
        if node_key == compiled.item_key and supplies(context, needed) then
            state.proof = {
                rank = 0,
                leaves = {},
                count = 0,
            }
            return state
        elseif compiled.nodes[node_key] == nil then
            if ind ~= nil then
                state.proof = {
                    rank = levels ~= nil and levels[ind] or ind,
                    leaves = { [ind] = true },
                    count = 1,
                }
            end
            return state
        end

        local function add_group(sources)
            table.insert(state.groups, sources)
            for _, source in pairs(sources) do
                source.dependents[state] = true
            end
        end
        if (logic.type_info[node.type] or {}).context ~= nil then
            -- No existing transition witness means no license to supply another room.
            if ind == nil then
                return state
            end
            state.op = "AND"
            local backing = top.path(graph, { ind }, sort_info, { immediate = true }).in_path
            local predecessors = {}
            for pre, _ in pairs(backing) do
                if pre < ind then
                    table.insert(predecessors, pre)
                end
            end
            table.sort(predecessors)
            for _, pre in pairs(predecessors) do
                local pebble_key, pebble_context = sort_info.pebble_keys[pre], sort_info.pebble_contexts[pre]
                add_group({ get_state(pebble_key, pebble_context) })
            end
        else
            state.op = node.op
            local edges = {}
            for edge_key, _ in pairs(node.pre) do
                table.insert(edges, edge_key)
            end
            table.sort(edges)
            for _, edge_key in pairs(edges) do
                local edge = graph.edges[edge_key]
                local contexts = { needed }
                if not top.edge_keeps_context(sort_info, edge, needed) then
                    contexts = top.edge_source_contexts(sort_info, edge, needed)
                end
                local sources = {}
                for _, source in pairs(contexts) do
                    table.insert(sources, get_state(edge.start, source))
                end
                add_group(sources)
            end
        end
        return state
    end

    local goals = {}
    for _, operation_key in pairs(compiled.operations) do
        local contexts = { [context] = true }
        for c, _ in pairs(nci[operation_key] or {}) do
            if top.context_home(c) == nil then
                contexts[c] = true
            end
        end
        local context_list = {}
        for c, _ in pairs(contexts) do
            table.insert(context_list, c)
        end
        table.sort(context_list)
        local choices = {}
        for _, c in pairs(context_list) do
            table.insert(choices, get_state(operation_key, c))
        end
        table.insert(goals, choices)
    end

    local queue = {}
    local queued = {}
    for _, state in pairs(ordered) do
        table.insert(queue, state)
        queued[state] = true
    end
    local i = 1
    while i <= #queue do
        local state = queue[i]
        queued[state] = nil
        local candidate
        if state.op ~= nil then
            local inputs = {}
            local complete = true
            for _, group in pairs(state.groups) do
                local best
                for _, source in pairs(group) do
                    if better(source.proof, best) then
                        best = source.proof
                    end
                end
                if state.op == "AND" then
                    if best == nil then
                        complete = false
                        break
                    end
                    table.insert(inputs, best)
                elseif better(best, candidate) then
                    candidate = best
                end
            end
            if state.op == "AND" and complete then
                candidate = combine(inputs)
            end
        end
        if better(candidate, state.proof) then
            state.proof = candidate
            for dependent, _ in pairs(state.dependents) do
                if queued[dependent] == nil then
                    queued[dependent] = true
                    table.insert(queue, dependent)
                end
            end
        end
        i = i + 1
    end
    local results = {}
    for _, choices in pairs(goals) do
        local best
        for _, state in pairs(choices) do
            if better(state.proof, best) then
                best = state.proof
            end
        end
        if best == nil then
            return nil
        end
        table.insert(results, best)
    end
    return combine(results)
end

return bundles
