-- Bootstrap infrastructure on planets (see notes/bootstrap-infrastructure.txt)
-- A finite amount of delivered infrastructure is fine when the room can then make that infrastructure itself: operating a delivered building counts as local there
-- The logic builds a candidate (building, room) pair for each room lutils.bootstrap_rooms names (entity-own-bootstrap-rooms, in lib/logic/concrete.lua), and this prunes it to the greatest fixpoint:
--   1. Sort with every remaining pair counted as local.
--   2. Drop the pairs whose building's item (entity-build-item) has no isolatable context in their room in that sort.
--   3. Repeat until nothing drops.
-- Granting at operation only (never at the entity or its ownership) keeps mining a delivered building back from making its item local, which would let every pair justify itself
-- Warmth bootstraps the same way (user, 2026-09-26: "a handfed start as long as eventually no handfeeding is necessary is fine"): candidate edges room --> warmth (built with bootstrap_warmth in lib/logic/abstract.lua) for rooms that freeze
--   * A room keeps its edge only if heat can be started there at all without it: heat (energy-source-heat) has an isolatable context there in a sort without any warmth grant (like a heating tower fed by hand)
--   * and if heat then keeps itself going: heat has a context there that's both isolatable and automatable in the sort with the remaining grants (fuel mined and fed by the now warm machines, no hand-feeding)

local gutils = require("lib/graph/graph-utils")

local bootstrap = {}

-- Prunes logic.graph's bootstrap pairs in place; home_sets are the home sets to sort with (nil for top.home_sets of the graph)
-- Returns the number of sorts it took (0 when there are no pairs)
bootstrap.prune = function(logic, home_sets)
    local graph = logic.graph
    -- Each pair: its room edge into the building's entity-own-bootstrap-rooms node, the room key and the building's entity-build-item node
    local candidates = {}
    for node_key, node in pairs(graph.nodes) do
        if node.type == "entity-own-bootstrap-rooms" then
            for edge_key, _ in pairs(node.pre) do
                table.insert(candidates, {
                    edge_key = edge_key,
                    room = graph.nodes[graph.edges[edge_key].start].name,
                    item_key = gutils.key("entity-build-item", node.name),
                    name = node.name,
                })
            end
        end
    end
    local warmth_key = gutils.key("warmth", "")
    local heat_key = gutils.key("energy-source-heat", "")
    for edge_key, _ in pairs((graph.nodes[warmth_key] or { pre = {} }).pre) do
        local edge = graph.edges[edge_key]
        if edge.bootstrap_warmth then
            table.insert(candidates, {
                edge_key = edge_key,
                room = graph.nodes[edge.start].name,
                warmth = true,
                name = "warmth",
            })
        end
    end
    if #candidates == 0 then
        return 0
    end
    table.sort(candidates, function(a, b)
        return a.edge_key < b.edge_key
    end)

    -- Required here rather than at the top, since the context sort requires the logic module that requires this file
    local top = require("lib/graph/context-sort")
    home_sets = home_sets or logic.home_sets or top.home_sets(graph)
    local function sort()
        return top.sort(graph, nil, nil, {
            complex_contexts = true,
            home_contexts = true,
            home_sets = home_sets,
        })
    end
    -- Whether node_key has a context in room with the given abilities (by index, like top.ISOLATABILITY) all set
    local function has_context(sort_info, node_key, room, ability_inds)
        for context, _ in pairs(sort_info.node_to_context_inds[node_key] or {}) do
            local abilities = top.context_abilities(context)
            if top.context_room(context) == room and top.context_home(context) == nil and abilities ~= nil then
                local has_all = true
                for _, ind in pairs(ability_inds) do
                    if string.sub(abilities, ind, ind) ~= "1" then
                        has_all = false
                    end
                end
                if has_all then
                    return true
                end
            end
        end
        return false
    end
    local num_sorts = 0

    -- Warmth only bootstraps where heat can be started at all without it: sort without any warmth grant, then put back the grants of the rooms that pass
    local warmth_candidates = {}
    local other_candidates = {}
    for _, candidate in pairs(candidates) do
        if candidate.warmth then
            table.insert(warmth_candidates, candidate)
        else
            table.insert(other_candidates, candidate)
        end
    end
    if #warmth_candidates > 0 then
        local removed = {}
        for _, candidate in pairs(warmth_candidates) do
            removed[candidate.edge_key] = graph.edges[candidate.edge_key]
            gutils.remove_edge(graph, candidate.edge_key)
        end
        num_sorts = num_sorts + 1
        local sort_info = sort()
        candidates = other_candidates
        for _, candidate in pairs(warmth_candidates) do
            if has_context(sort_info, heat_key, candidate.room, { top.ISOLATABILITY }) then
                local edge = removed[candidate.edge_key]
                local extra = {}
                for k, v in pairs(edge) do
                    if k ~= "object_type" and k ~= "start" and k ~= "stop" then
                        extra[k] = v
                    end
                end
                gutils.add_edge(graph, edge.start, edge.stop, extra)
                table.insert(candidates, candidate)
            else
                log("Bootstrap infrastructure: heat can't be started in " .. candidate.room .. " without warmth, so it stays cold there")
            end
        end
    end

    while #candidates > 0 do
        num_sorts = num_sorts + 1
        local sort_info = sort()
        local kept = {}
        local dropped = {}
        for _, candidate in pairs(candidates) do
            local is_local
            if candidate.warmth then
                -- Heat keeps itself going there: local and automatic
                is_local = has_context(sort_info, heat_key, candidate.room, { top.ISOLATABILITY, top.AUTOMATABILITY })
            else
                is_local = has_context(sort_info, candidate.item_key, candidate.room, { top.ISOLATABILITY })
            end
            if is_local then
                table.insert(kept, candidate)
            else
                table.insert(dropped, candidate)
            end
        end
        for _, candidate in pairs(dropped) do
            gutils.remove_edge(graph, candidate.edge_key)
        end
        candidates = kept
        if #dropped == 0 then
            break
        end
    end
    local kept_names = {}
    for _, candidate in pairs(candidates) do
        table.insert(kept_names, candidate.name .. " @ " .. candidate.room)
    end
    log("Bootstrap infrastructure: " .. num_sorts .. " sorts; delivered buildings counted as local: " .. (#kept_names > 0 and table.concat(kept_names, ", ") or "none"))
    return num_sorts
end

return bootstrap
