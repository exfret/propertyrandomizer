-- Bootstrap infrastructure on planets (see notes/bootstrap-infrastructure.txt)
-- A finite amount of delivered infrastructure is fine when the room can then make that infrastructure itself: operating a delivered building counts as local there
-- The logic builds a candidate (building, room) pair for each room lutils.bootstrap_rooms names (entity-own-bootstrap-rooms, in src/logic/builders/concrete.lua), and this prunes it to the greatest fixpoint:
--   1. Sort with every remaining pair counted as local.
--   2. Drop the pairs whose building's item (entity-build-item) has no isolatable context in their room in that sort.
--   3. Repeat until nothing drops.
-- Granting at operation only (never at the entity or its ownership) keeps mining a delivered building back from making its item local, which would let every pair justify itself
-- Warmth bootstraps the same way (user, 2026-09-26: "a handfed start as long as eventually no handfeeding is necessary is fine"): a candidate grant warmth-bootstrap --> warmth (src/logic/builders/abstract.lua) for each room that freezes
--   * Heat must be startable there without the grant: the graph says that itself, since the grant takes an isolatable context of heat in the room, which heat only has before the grant if it has it without
--   * and heat must then keep itself going: heat has a context there that's both isolatable and automatable in the sort with the remaining grants (fuel mined and fed by the now warm machines, no hand-feeding), which is pruned like the pairs
-- These conditions are checked when the logic is built, not in the graph, so randomization's model counts a kept grant as fixed; bootstrap.justifications names what must stay true for each, which randomization keeps (src/randomizations/unified/skeleton/protection.lua)

local build_supply = require("src/logic/analysis/entity-build-item")
local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")

local bootstrap = {}

-- The edge that an edge into an OR node stands for: itself, or in a graph with orands (gutils.make_orands, like unified's models) the edge from the orand's child (the original start) into the orand, which keeps the original edge's fields
local function original_edge(graph, edge_key)
    local edge = graph.edges[edge_key]
    local child_key = (graph.orand_to_child or {})[edge.start]
    if child_key == nil or child_key == edge.start then
        return edge
    end
    return graph.edges[gutils.ekey({
        start = child_key,
        stop = edge.start,
    })] or {
        start = child_key,
        stop = edge.stop,
    }
end

-- The grants in graph (the candidates before pruning, the kept ones after) with what justifies each, as a list sorted by edge key of
-- { edge_key = the grant's edge, room = its room key, name = the building or "warmth", node_key = the node that must have a context in the room with every ability in ability_inds }
--   * a bootstrapped building: its item (entity-build-item) isolatable in the room
--   * a warmed room: heat (energy-source-heat) isolatable and automatable there
-- The graph may have orands, whose grant edges come from an orand standing for the original edge
bootstrap.justifications = function(graph)
    local justifications = {}
    for _, node in pairs(graph.nodes) do
        if node.type == "entity-own-bootstrap-rooms" then
            for edge_key, _ in pairs(node.pre or {}) do
                table.insert(justifications, {
                    edge_key = edge_key,
                    room = graph.nodes[original_edge(graph, edge_key).start].name,
                    name = node.name,
                    node_key = build_supply.key(graph, node.name),
                    ability_inds = { top.ISOLATABILITY },
                })
            end
        end
    end
    local warmth = graph.nodes[gutils.key("warmth", "")]
    for edge_key, _ in pairs((warmth or {}).pre or {}) do
        local edge = original_edge(graph, edge_key)
        if edge.bootstrap_warmth then
            table.insert(justifications, {
                edge_key = edge_key,
                room = graph.nodes[edge.start].name,
                name = "warmth",
                node_key = gutils.key("energy-source-heat", ""),
                ability_inds = { top.ISOLATABILITY, top.AUTOMATABILITY },
            })
        end
    end
    table.sort(justifications, function(a, b)
        return a.edge_key < b.edge_key
    end)
    return justifications
end

-- Whether context is in room, not a home context, and has every ability in ability_inds (indices like top.ISOLATABILITY)
bootstrap.justifies = function(context, room, ability_inds)
    local mask = top.context_mask(context)
    if top.context_room(context) ~= room or top.context_home(context) ~= nil or mask == nil then
        return false
    end
    for _, ind in pairs(ability_inds) do
        if not top.has_ability(mask, ind) then
            return false
        end
    end
    return true
end

-- The last prune: what it started from (see bootstrap.prune), the edges it removed in order, its lines about rooms that stay cold and the buildings it counted as local, so pruning the same again (a logic build after a change the logic doesn't model) takes no sorts
-- Only a full prune is kept here, not one that started from what the last one left out (see from_last below)
local last_prune = nil
-- The grants the last full prune left out, as room .. "\n" .. name --> true
local last_dropped = nil

-- Prunes logic.graph's bootstrap grants in place; home_sets are the home sets to sort with (nil for top.home_sets of the graph)
-- With from_last, the grants the last full prune left out are left out up front, which saves the sort with every grant when nothing else drops: for the tech tree rebuild's check of the game it rebuilt, which only changed techs
-- That can keep fewer grants than a full prune, if the change lets a room make a building it couldn't before, so it's only for a check, which then asks more of the game rather than less
-- Returns the number of sorts it took (0 when there are no grants, or when it starts from what the last prune started from)
bootstrap.prune = function(logic, home_sets, from_last)
    local graph = logic.graph
    local candidates = bootstrap.justifications(graph)
    if #candidates == 0 then
        return 0
    end

    home_sets = home_sets or logic.home_sets or top.home_sets(graph)
    -- What the prune depends on: what its sorts read (top.graph_fingerprint) with the home sets, and the grants, whose justifications read edge fields like bootstrap_warmth
    local start = {
        top.graph_fingerprint(graph),
        top.home_sets_signature(home_sets),
    }
    for _, candidate in pairs(candidates) do
        table.insert(start, candidate.edge_key .. " " .. candidate.room .. " " .. candidate.name)
    end
    start = table.concat(start, "\n")
    if last_prune ~= nil and last_prune.start == start and from_last ~= true then
        for _, edge_key in pairs(last_prune.removed) do
            gutils.remove_edge(graph, edge_key)
        end
        for _, line in pairs(last_prune.lines) do
            log(line)
        end
        log("Bootstrap infrastructure: no sorts, as the last prune started from the same graph; delivered buildings counted as local: " .. last_prune.counted)
        return 0
    end
    local removed = {}
    local lines = {}
    local function sort()
        return top.sort(graph, nil, nil, {
            complex_contexts = true,
            home_contexts = true,
            home_sets = home_sets,
        })
    end
    local function is_justified(sort_info, candidate)
        for context, _ in pairs(sort_info.node_to_context_inds[candidate.node_key] or {}) do
            if bootstrap.justifies(context, candidate.room, candidate.ability_inds) then
                return true
            end
        end
        return false
    end
    local num_sorts = 0
    local num_up_front = 0
    if from_last == true and last_dropped ~= nil then
        local kept = {}
        for _, candidate in pairs(candidates) do
            if last_dropped[candidate.room .. "\n" .. candidate.name] ~= nil then
                if candidate.name == "warmth" then
                    local line = "Bootstrap infrastructure: heat can't be started in " .. candidate.room .. " and then keep itself going, so it stays cold there"
                    table.insert(lines, line)
                    log(line)
                end
                table.insert(removed, candidate.edge_key)
                gutils.remove_edge(graph, candidate.edge_key)
                num_up_front = num_up_front + 1
            else
                table.insert(kept, candidate)
            end
        end
        candidates = kept
    end
    local all_candidates = {}
    for _, candidate in pairs(candidates) do
        all_candidates[candidate.room .. "\n" .. candidate.name] = true
    end
    while #candidates > 0 do
        num_sorts = num_sorts + 1
        local sort_info = sort()
        local kept = {}
        local dropped = {}
        for _, candidate in pairs(candidates) do
            if is_justified(sort_info, candidate) then
                table.insert(kept, candidate)
            else
                table.insert(dropped, candidate)
            end
        end
        for _, candidate in pairs(dropped) do
            if candidate.name == "warmth" then
                local line = "Bootstrap infrastructure: heat can't be started in " .. candidate.room .. " and then keep itself going, so it stays cold there"
                table.insert(lines, line)
                log(line)
            end
            table.insert(removed, candidate.edge_key)
            gutils.remove_edge(graph, candidate.edge_key)
        end
        candidates = kept
        if #dropped == 0 then
            -- The graph stays as this sort found it, so the next sort of it the same way can be this one
            top.offer_reusable_sort(graph, sort_info, home_sets)
            break
        end
    end
    -- Per room, sorted (candidates are sorted by edge key, which starts with the room only for some grants)
    local names_by_room = {}
    local rooms = {}
    for _, candidate in pairs(candidates) do
        if names_by_room[candidate.room] == nil then
            names_by_room[candidate.room] = {}
            table.insert(rooms, candidate.room)
        end
        table.insert(names_by_room[candidate.room], candidate.name)
    end
    table.sort(rooms)
    local parts = {}
    for _, room in pairs(rooms) do
        table.sort(names_by_room[room])
        table.insert(parts, room .. " (" .. #names_by_room[room] .. "): " .. table.concat(names_by_room[room], ", "))
    end
    local counted = #parts > 0 and table.concat(parts, "; ") or "none"
    log("Bootstrap infrastructure: " .. num_sorts .. " sorts" .. (num_up_front > 0 and (" after leaving out " .. num_up_front .. " grants the last full prune did") or "") .. "; delivered buildings counted as local: " .. counted)
    if from_last ~= true or last_dropped == nil then
        last_prune = {
            start = start,
            removed = removed,
            lines = lines,
            counted = counted,
        }
        last_dropped = {}
        local final = {}
        for _, candidate in pairs(candidates) do
            final[candidate.room .. "\n" .. candidate.name] = true
        end
        for key, _ in pairs(all_candidates) do
            if final[key] == nil then
                last_dropped[key] = true
            end
        end
    else
        -- The graph no longer matches a full prune's
        last_prune = nil
    end
    return num_sorts
end

return bootstrap
