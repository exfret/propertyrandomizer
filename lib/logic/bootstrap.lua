-- Bootstrap infrastructure on planets (see notes/bootstrap-infrastructure.txt)
-- A finite amount of delivered infrastructure is fine when the room can then make that infrastructure itself: operating a delivered building counts as local there
-- The logic builds a candidate (building, room) pair for each room lutils.bootstrap_rooms names (entity-own-bootstrap-rooms, in lib/logic/concrete.lua), and this prunes it to the greatest fixpoint:
--   1. Sort with every remaining pair counted as local.
--   2. Drop the pairs whose building's item (entity-build-item) has no isolatable context in their room in that sort.
--   3. Repeat until nothing drops.
-- Granting at operation only (never at the entity or its ownership) keeps mining a delivered building back from making its item local, which would let every pair justify itself
-- Warmth bootstraps the same way (user, 2026-09-26: "a handfed start as long as eventually no handfeeding is necessary is fine"): a candidate grant warmth-bootstrap --> warmth (lib/logic/abstract.lua) for each room that freezes
--   * Heat must be startable there without the grant: the graph says that itself, since the grant takes an isolatable context of heat in the room, which heat only has before the grant if it has it without
--   * and heat must then keep itself going: heat has a context there that's both isolatable and automatable in the sort with the remaining grants (fuel mined and fed by the now warm machines, no hand-feeding), which is pruned like the pairs
-- These conditions are checked when the logic is built, not in the graph, so randomization's model counts a kept grant as fixed; bootstrap.justifications names what must stay true for each, which randomization keeps (randomizations/graph/unified/skeleton/protection.lua)

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")

local bootstrap = {}

-- The grants in graph (the candidates before pruning, the kept ones after) with what justifies each, as a list sorted by edge key of
-- { edge_key = the grant's edge, room = its room key, name = the building or "warmth", node_key = the node that must have a context in the room with every ability in ability_inds }
--   * a bootstrapped building: its item (entity-build-item) isolatable in the room
--   * a warmed room: heat (energy-source-heat) isolatable and automatable there
bootstrap.justifications = function(graph)
    local justifications = {}
    for _, node in pairs(graph.nodes) do
        if node.type == "entity-own-bootstrap-rooms" then
            for edge_key, _ in pairs(node.pre or {}) do
                table.insert(justifications, {
                    edge_key = edge_key,
                    room = graph.nodes[graph.edges[edge_key].start].name,
                    name = node.name,
                    node_key = gutils.key("entity-build-item", node.name),
                    ability_inds = { top.ISOLATABILITY },
                })
            end
        end
    end
    local warmth = graph.nodes[gutils.key("warmth", "")]
    for edge_key, _ in pairs((warmth or {}).pre or {}) do
        local edge = graph.edges[edge_key]
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
    local abilities = top.context_abilities(context)
    if top.context_room(context) ~= room or top.context_home(context) ~= nil or abilities == nil then
        return false
    end
    for _, ind in pairs(ability_inds) do
        if string.sub(abilities, ind, ind) ~= "1" then
            return false
        end
    end
    return true
end

-- Prunes logic.graph's bootstrap grants in place; home_sets are the home sets to sort with (nil for top.home_sets of the graph)
-- Returns the number of sorts it took (0 when there are no grants)
bootstrap.prune = function(logic, home_sets)
    local graph = logic.graph
    local candidates = bootstrap.justifications(graph)
    if #candidates == 0 then
        return 0
    end

    home_sets = home_sets or logic.home_sets or top.home_sets(graph)
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
                log("Bootstrap infrastructure: heat can't be started in " .. candidate.room .. " and then keep itself going, so it stays cold there")
            end
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
