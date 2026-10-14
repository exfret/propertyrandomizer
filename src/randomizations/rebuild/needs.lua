-- What a rebuilt technology needs, read off one derivation (a witness) in a sort of the game without tech prerequisites (src/randomizations/rebuild/tree.lua)
-- A witness is top.path from one pebble: the earliest way the sort found to have it there, each AND node taking all its inputs and each OR node one
-- It stops where something else covers what's behind it
--   * At a recipe with a technology of its own, since that technology's prerequisites cover what the recipe needs.
--   * At a technology, which is then a prerequisite itself (like the discovery a planet copy's technologies stay behind, src/randomizations/unified/execute.lua).
--   * At a room, since getting there is its discovery's business, and a discovery takes the route there (src/randomizations/rebuild/tree.lua).
--   * At the recipe's own unlock, which the rebuilt technology replaces: the old technology's research isn't what the recipe needs, and walking through it gave a copied drill an unrelated pipe-to-ground's technology (user, 2026-10-12).

local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
local logic = require("src/logic/state")
-- Ranks ties between rooms and shares what paths take from each pebble, as the old witnesses did
local witness_recipes = require("src/logic/builders/witness-recipes")

local needs = {}

-- Whether a node is a room's own node, whose context names the room (src/logic/builders/abstract.lua)
local function is_room(node)
    return type(logic.type_info[node.type].context) == "string"
end

-- What the pebble at rank in sort_info needs, as { recipes = list of { name, room } sorted by name then room, techs = set of names, rooms = set of room keys }
-- A rank a listed pebble stands for (top.implied_ability_contexts) starts from that pebble
-- params.has_tech(recipe name) says which recipes have technologies of their own; params.own_recipe is the recipe whose unlock the witness doesn't go through; params.home_sets are the sort's home sets, for ranking ties (see witness_recipes.tie_rank)
needs.of = function(graph, sort_info, rank, params)
    local pebble_keys = sort_info.pebble_keys
    local pebble_contexts = sort_info.pebble_contexts
    local own_unlocks = {}
    if params.own_recipe ~= nil then
        own_unlocks[gutils.key("recipe-unlock", params.own_recipe)] = true
        own_unlocks[gutils.key("recipe-tech-unlock", params.own_recipe)] = true
    end
    local ind = math.ceil(rank)
    local tie_rank, rank_key = witness_recipes.tie_rank(graph, sort_info, ind, params.home_sets)
    local expansions, cache = witness_recipes.expansions_for(graph, sort_info, rank_key)
    local path_info = top.path(graph, { ind }, sort_info, {
        stop_if = function(node_key)
            if own_unlocks[node_key] ~= nil then
                return true
            end
            local node = graph.nodes[node_key]
            if node.type == "technology" or is_room(node) then
                return true
            end
            return node.type == "recipe" and params.has_tech(node.name)
        end,
        tie_rank = tie_rank,
        expansions = expansions,
        options = cache.options,
    })
    local found = {
        recipes = {},
        techs = {},
        rooms = {},
    }
    local seen_recipes = {}
    for other_ind, _ in pairs(path_info.in_path) do
        if other_ind ~= ind then
            local node = graph.nodes[pebble_keys[other_ind]]
            if node.type == "recipe" and params.has_tech(node.name) then
                local room = top.context_room(pebble_contexts[other_ind])
                local seen_key = node.name .. "\n" .. tostring(room)
                if seen_recipes[seen_key] == nil then
                    seen_recipes[seen_key] = true
                    table.insert(found.recipes, {
                        name = node.name,
                        room = room,
                    })
                end
            elseif node.type == "technology" then
                found.techs[node.name] = true
            elseif is_room(node) then
                found.rooms[node.name] = true
            end
        end
    end
    table.sort(found.recipes, function(a, b)
        if a.name ~= b.name then
            return a.name < b.name
        end
        return tostring(a.room) < tostring(b.room)
    end)
    return found
end

-- Where a witness of what a tech's research needs starts, for its pebble at rank: that pebble, unless the discovery rule gave it (the tech had in a home context of the room's home set, once the room is discovered: top.discovery_candidates), when it's the tech's own pebble the rule backs it with
-- How the room gets discovered isn't something the research needs: a planet's discovery is the gate of a technology made there anyway, and a platform is discovered by a spaceship that can fly (top.is_discoverer), whose thrusters' technologies would otherwise need the research (user's 10:08 game: thruster fuel's, ice melting's and asteroid crushing's technologies on platforms needed thruster oxidizer's, which needed them)
-- room_discoverers comes from top.room_discoverers
needs.research_start = function(graph, sort_info, rank, room_discoverers)
    local ind = math.ceil(rank)
    local candidates = top.discovery_candidates(sort_info, room_discoverers, graph.nodes[sort_info.pebble_keys[ind]], sort_info.pebble_contexts[ind])
    if candidates == nil or candidates.own[1] == nil or candidates.discoverers[1] == nil then
        return rank
    end
    -- top.path takes the rule only when no context the tech takes in has it earlier, which its first step shows
    local step = top.path(graph, { ind }, sort_info, {
        stop_if = function()
            return true
        end,
    })
    if step.path[2] == candidates.own[1] and step.path[3] == candidates.discoverers[1] then
        return candidates.own[1]
    end
    return rank
end

return needs
