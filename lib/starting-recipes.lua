-- A planet's starting recipes: what it needs to get going from its own resources, which its discovery brings (randomizations.rebuild_tech_tree in randomizations/fixes.lua, user 2026-10-10)
-- They're the recipes on the planet's own route (its isolatable contexts, see lib/logic/builder.lua) to what PLANETCHECK keeps isolatable on a planet: the nodes the logic builds with keep_planetary_isolatability, which make electricity, launch rockets and make space platforms (randomizations/planetary/check.lua, rule 3)
-- The route is top.path in a sort with complex contexts of the game without tech prerequisites
--   * It stops at techs: what a tech's research needs comes before the discovery, or doesn't matter once the discovery unlocks the recipe
--   * It stops at other rooms' pebbles: only the planet's own recipes are its start
--   * A delivered building that counts as local on the planet (lib/logic/bootstrap.lua) counts because the planet can then make it, so the route to making it there is part of the start
--   * The rebuild adds the route to the trigger of each starting recipe's tech it leaves for the planet to meet (starting_recipes.trigger_key), so that it can be met right after landing
-- Vanilla does the same by hand: Fulgora's discovery unlocks the lightning rod and needs accumulators, and Aquilo's unlocks its ammonia and ice platform recipes and needs the heating tower (space-age/prototypes/technology.lua)

local bootstrap = require("lib/logic/bootstrap")
local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")

local starting_recipes = {}

-- Whether a context is in room, not a home context, and has every ability in ability_inds (indices like top.ISOLATABILITY)
local function has_abilities_in(context, room, ability_inds)
    local mask = top.context_mask(context)
    if mask == nil or top.context_home(context) ~= nil or top.context_room(context) ~= room then
        return false
    end
    for _, ability in pairs(ability_inds) do
        if not top.has_ability(mask, ability) then
            return false
        end
    end
    return true
end

-- The earliest rank in sort_info of node_key in room with every ability in ability_inds (isolatability if nil), or nil
starting_recipes.goal = function(sort_info, node_key, room, ability_inds)
    ability_inds = ability_inds or { top.ISOLATABILITY }
    local first
    for context, rank in pairs(sort_info.node_to_context_inds[node_key] or {}) do
        if (first == nil or rank < first) and has_abilities_in(context, room, ability_inds) then
            first = rank
        end
    end
    return first
end

-- The keys of graph's nodes that PLANETCHECK keeps isolatable on a planet (keep_planetary_isolatability), sorted
starting_recipes.targets = function(graph)
    local targets = {}
    for node_key, node in pairs(graph.nodes) do
        if node.keep_planetary_isolatability == true then
            table.insert(targets, node_key)
        end
    end
    table.sort(targets)
    return targets
end

-- The ranks of the targets' earliest isolatable pebbles in room, sorted
starting_recipes.goals = function(graph, sort_info, room, targets)
    local goals = {}
    for _, node_key in pairs(targets or starting_recipes.targets(graph)) do
        local rank = starting_recipes.goal(sort_info, node_key, room)
        if rank ~= nil then
            table.insert(goals, rank)
        end
    end
    table.sort(goals)
    return goals
end

-- The recipes on room's own route to the pebbles at goal_inds in sort_info (a sort of graph with complex contexts), as a set of the names gets_tech(recipe_name) says get a tech
-- The route also goes to making each delivered building it counts as local in room (see the top of this file)
starting_recipes.route = function(graph, sort_info, room, goal_inds, gets_tech)
    local pebble_keys = sort_info.pebble_keys
    local pebble_contexts = sort_info.pebble_contexts
    -- The grants in room, by their edge's ends: a grant is on the route when both ends' pebbles in room are (a building's grant ends at a node of its own, and warmth's starts at one)
    local grants = {}
    for _, justification in pairs(bootstrap.justifications(graph)) do
        if justification.room == room then
            table.insert(grants, justification)
        end
    end
    local params = {
        stop_if = function(node_key, context)
            return top.context_room(context) ~= room or graph.nodes[node_key].type == "technology"
        end,
    }
    local recipes = {}
    local done_grants = {}
    -- top.path builds its path in the list it's given
    local goals = {}
    for _, rank in pairs(goal_inds) do
        table.insert(goals, rank)
    end
    while #goals > 0 do
        local path_info = top.path(graph, goals, sort_info, params)
        -- Node keys with a pebble in room on the route
        local on_route = {}
        for _, rank in pairs(path_info.path) do
            local node_key = pebble_keys[rank]
            if top.context_room(pebble_contexts[rank]) == room then
                on_route[node_key] = true
                local node = graph.nodes[node_key]
                if node.type == "recipe" and gets_tech(node.name) then
                    recipes[node.name] = true
                end
            end
        end
        goals = {}
        for _, grant in pairs(grants) do
            local edge = graph.edges[grant.edge_key]
            if done_grants[grant.edge_key] == nil and edge ~= nil and on_route[edge.start] ~= nil and on_route[edge.stop] ~= nil then
                done_grants[grant.edge_key] = true
                local rank = starting_recipes.goal(sort_info, grant.node_key, room, grant.ability_inds)
                if rank ~= nil then
                    table.insert(goals, rank)
                end
            end
        end
    end
    return recipes
end

-- A recipe's tech's trigger node, whose isolatable pebble in a room says the room can meet the trigger from its own resources (lib/logic/concrete.lua)
starting_recipes.trigger_key = function(tech_name)
    return gutils.key("technology-trigger", tech_name)
end

return starting_recipes
