-- Contracted recipe unlocks
-- lib/logic/concrete.lua builds technology --> recipe-tech-unlock --> recipe-unlock --> recipe for a locked recipe: the technologies unlocking it, then every way to unlock it (fixed-recipe machines too)
-- Where one technology is the only way, both nodes just pass its contexts on through plain edges, so logic.build leaves them out and the technology unlocks the recipe directly
-- Every node left gets the same contexts, with about 14% fewer pebbles per sort of the logic graph (notes/logs/2026-10-09-pebble-breakdown)
-- The two go together or not at all (lib/logic/pass-through.lua's splices, a chain at a time), so a recipe's technology unlocks are edges into its recipe-tech-unlock node, or straight into the recipe once contracted: code looking for them goes through this file
-- (A technology --> recipe edge is always such an unlock: concrete.lua and abstract.lua build technology edges only into recipe-tech-unlock, technology, space-location-discover and the unlock nodes of mining with fluid and space platforms)
-- Code adding an unlock to a built graph expands the recipe first (unlock_contraction.expand), since an edge straight into the recipe would be needed as well, not instead

local gutils = require("lib/graph/graph-utils")
local logic = require("lib/logic/state")
local pass_through = require("lib/logic/pass-through")

local unlock_contraction = {}

local UNLOCK = "recipe-unlock"
local TECH_UNLOCK = "recipe-tech-unlock"

-- The only key of a node's pre or dep set, or nil if it has none or several
local function only(set)
    local first = next(set)
    if first == nil or next(set, first) ~= nil then
        return nil
    end
    return first
end

-- The edges from technologies straight into a recipe node, sorted by key
local function direct_tech_edges(graph, recipe)
    local edge_keys = {}
    for pre, _ in pairs(recipe.pre) do
        local start = graph.nodes[graph.edges[pre].start]
        if start ~= nil and start.type == "technology" then
            table.insert(edge_keys, pre)
        end
    end
    table.sort(edge_keys)
    return edge_keys
end

-- Contracts every recipe exactly one technology unlocks with nothing else unlocking it: technology --> recipe-tech-unlock --> recipe-unlock --> recipe becomes technology --> recipe
-- A recipe nothing unlocks keeps its empty recipe-tech-unlock node, which keeps it locked, and one several things unlock keeps both nodes, which choose between them
-- Returns how many recipes it contracted
unlock_contraction.contract = function(graph)
    local unlock_keys = {}
    for node_key, node in pairs(graph.nodes) do
        if node.type == UNLOCK then
            table.insert(unlock_keys, node_key)
        end
    end
    table.sort(unlock_keys)
    local num_contracted = 0
    for _, unlock_key in pairs(unlock_keys) do
        local unlock = graph.nodes[unlock_key]
        local tech_unlock_key = gutils.key(TECH_UNLOCK, unlock.name)
        local tech_unlock = graph.nodes[tech_unlock_key]
        local tech_edge_key = tech_unlock ~= nil and only(tech_unlock.pre) or nil
        local recipe_edge_key = only(unlock.dep)
        -- The chain technology --> recipe-tech-unlock --> recipe-unlock --> recipe, each node with only those edges
        if tech_edge_key ~= nil and recipe_edge_key ~= nil and only(tech_unlock.dep) ~= nil and only(tech_unlock.dep) == only(unlock.pre) then
            local tech = graph.nodes[graph.edges[tech_edge_key].start]
            if tech ~= nil and tech.type == "technology" and graph.edges[recipe_edge_key].stop == gutils.key("recipe", unlock.name) and pass_through.can_splice(graph, tech_unlock_key) then
                pass_through.splice(graph, tech_unlock_key)
                if pass_through.can_splice(graph, unlock_key) then
                    pass_through.splice(graph, unlock_key)
                    num_contracted = num_contracted + 1
                else
                    -- Never half a chain (see the top): what the first splice joined goes back
                    pass_through.expand(graph, only(unlock.pre))
                end
            end
        end
    end
    return num_contracted
end

-- Gives a contracted recipe its recipe-tech-unlock and recipe-unlock nodes back, so another technology can unlock it as well (an edge straight into the recipe would be needed too)
-- Returns the key of the recipe's recipe-tech-unlock node, or nil if it has none and no technology unlocks it (it's unlocked from the start)
unlock_contraction.expand = function(graph, recipe_name)
    local tech_unlock_key = gutils.key(TECH_UNLOCK, recipe_name)
    if graph.nodes[tech_unlock_key] ~= nil then
        return tech_unlock_key
    end
    local recipe_key = gutils.key("recipe", recipe_name)
    local recipe = graph.nodes[recipe_key]
    if recipe == nil then
        return nil
    end
    for _, edge_key in pairs(direct_tech_edges(graph, recipe)) do
        if graph.edges[edge_key].through ~= nil then
            pass_through.expand(graph, edge_key)
            return tech_unlock_key
        end
    end
    return nil
end

-- The names of the contracted recipes, sorted
unlock_contraction.contracted_recipes = function(graph)
    local recipe_names = {}
    for _, node in pairs(graph.nodes) do
        if node.type == "recipe" and #direct_tech_edges(graph, node) > 0 then
            table.insert(recipe_names, node.name)
        end
    end
    table.sort(recipe_names)
    return recipe_names
end

-- The keys of the edges from the technologies unlocking a recipe, sorted: into its recipe-tech-unlock node, or straight into the recipe once contracted
unlock_contraction.tech_edges = function(graph, recipe_name)
    local tech_unlock = graph.nodes[gutils.key(TECH_UNLOCK, recipe_name)]
    if tech_unlock ~= nil then
        local edge_keys = {}
        for pre, _ in pairs(tech_unlock.pre) do
            local start = graph.nodes[graph.edges[pre].start]
            if start ~= nil and start.type == "technology" then
                table.insert(edge_keys, pre)
            end
        end
        table.sort(edge_keys)
        return edge_keys
    end
    local recipe = graph.nodes[gutils.key("recipe", recipe_name)]
    if recipe == nil then
        return {}
    end
    return direct_tech_edges(graph, recipe)
end

-- Whether an edge is a technology unlocking a recipe, in either shape
unlock_contraction.is_unlock_edge = function(graph, edge)
    local start = graph.nodes[edge.start]
    local stop = graph.nodes[edge.stop]
    return start ~= nil and stop ~= nil and start.type == "technology" and (stop.type == TECH_UNLOCK or stop.type == "recipe")
end

-- The name of the recipe whose technology unlock a pebble on node stands for, or nil
-- That's the recipe of a recipe-tech-unlock node, or a contracted recipe itself: its technology's contexts arrive straight into it, so the recipe needs them wherever the unlock node would have been needed
unlock_contraction.unlocked_recipe = function(graph, node)
    if node.type == TECH_UNLOCK then
        return node.name
    end
    if node.type == "recipe" and #direct_tech_edges(graph, node) > 0 then
        return node.name
    end
    return nil
end

return unlock_contraction
