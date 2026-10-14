-- Contracted recipe unlocks
-- src/logic/builders/concrete.lua builds technology --> recipe-tech-unlock --> recipe-unlock --> recipe for a locked recipe: the technologies unlocking it, then every way to unlock it (fixed-recipe machines too)
-- Where one technology is the only way, both nodes just pass its contexts on through plain edges, so logic.build leaves them out and the technology unlocks the recipe directly
-- Every node left gets the same contexts, with about 14% fewer pebbles per sort of the logic graph (notes/logs/2026-10-09-pebble-breakdown)
-- Single-technology chains lose both nodes; other technology-only groups share their recipe-tech-unlock OR by leaving out the forwarding recipe-unlock (share_forwarders).
-- Spliced edges record the removed nodes for exact expansion (src/logic/analysis/pass-through.lua); technology edges still go into recipe-tech-unlock, or directly into a recipe for a fully contracted chain.
-- (A technology --> recipe edge is always such an unlock: concrete.lua and abstract.lua build technology edges only into recipe-tech-unlock, technology, space-location-discover and the unlock nodes of mining with fluid and space platforms)
-- Code adding an unlock to a built graph expands the recipe first (unlock_contraction.expand), since an edge straight into the recipe would be needed as well, not instead

local gutils = require("src/lib/graph/graph-utils")
local logic = require("src/logic/state")
local pass_through = require("src/logic/analysis/pass-through")

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

-- A shared unlock edge still represents the old recipe-unlock boundary for claiming.
unlock_contraction.forwards_unlock = function(edge, recipe_name)
    for _, node in pairs(edge.through or {}) do
        if node.type == UNLOCK and (recipe_name == nil or node.name == recipe_name) then
            return true
        end
    end
    return false
end

-- The real OR standing for a removed forwarding recipe-unlock, or nil in other shapes.
unlock_contraction.forwarding_key = function(graph, recipe_name)
    if graph.nodes[gutils.key(UNLOCK, recipe_name)] ~= nil then
        return nil
    end
    local source_key = gutils.key(TECH_UNLOCK, recipe_name)
    local edge = graph.edges[gutils.ekey({
        start = source_key,
        stop = gutils.key("recipe", recipe_name),
    })]
    if graph.nodes[source_key] ~= nil and edge ~= nil and unlock_contraction.forwards_unlock(edge, recipe_name) then
        return source_key
    end
    return nil
end

-- Leave out only the forwarding OR, retaining every technology alternative and empty OR locks.
-- Debt endpoints/goals keep their physical identity; unchanged forwarding links can still be shared before matching subdivision.
unlock_contraction.share_forwarders = function(graph, debt)
    -- An opaque goal predicate gives no list of identities it needs; keep them all in that case.
    if debt ~= nil and debt.is_goal ~= nil and debt.goals == nil then
        return 0
    end
    local blocked = {}
    if debt ~= nil then
        for edge_key, _ in pairs(debt.debt_edges) do
            local edge = debt.graph.edges[edge_key]
            blocked[edge.start], blocked[edge.stop] = true, true
        end
        for key, _ in pairs(debt.old_nodes) do blocked[key] = true end
        for key, _ in pairs(debt.goals or {}) do blocked[key] = true end
    end
    local keys = {}
    for key, node in pairs(graph.nodes) do
        if node.type == UNLOCK then table.insert(keys, key) end
    end
    table.sort(keys)
    local count = 0
    for _, key in pairs(keys) do
        local node = graph.nodes[key]
        local in_key, out_key = only(node.pre), only(node.dep)
        if blocked[key] ~= true and in_key ~= nil and out_key ~= nil then
            local source_key = graph.edges[in_key].start
            local source = graph.nodes[source_key]
            local info = logic.type_info[source.type] or {}
            local stop_key = graph.edges[out_key].stop
            local joined_key = gutils.ekey({
                start = source_key,
                stop = stop_key,
            })
            if node.op == "OR" and source.op == "OR" and source.type == TECH_UNLOCK and source.name == node.name
                and stop_key == gutils.key("recipe", node.name) and info.context == nil
                and info.research_input ~= true and info.home_carrier ~= true and info.relay ~= true
                and (debt == nil or debt.debt_edges[joined_key] == nil) and pass_through.can_splice(graph, key) then
                pass_through.splice(graph, key)
                count = count + 1
            end
        end
    end
    return count
end

-- Virtual forwarding queries use the retained technology OR's actual witness ranks.
unlock_contraction.context_inds = function(graph, sort_info, node_key)
    local node = gutils.deconstruct(node_key)
    if node.type == UNLOCK then
        node_key = unlock_contraction.forwarding_key(graph, node.name) or node_key
    end
    return sort_info.node_to_context_inds[node_key] or {}
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
-- This complete-chain pass retains empty and multiple-input technology ORs; share_forwarders may then remove only their forwarding recipe-unlock.
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

-- Restores either a complete chain or just its forwarding recipe-unlock, before code adds unlock alternatives.
-- Returns the key of the recipe's recipe-tech-unlock node, or nil if it has none and no technology unlocks it (it's unlocked from the start)
unlock_contraction.expand = function(graph, recipe_name)
    local tech_unlock_key = gutils.key(TECH_UNLOCK, recipe_name)
    if graph.nodes[tech_unlock_key] ~= nil then
        if unlock_contraction.forwarding_key(graph, recipe_name) ~= nil then
            pass_through.expand(graph, gutils.ekey({
                start = tech_unlock_key,
                stop = gutils.key("recipe", recipe_name),
            }))
        end
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

-- The names of the fully contracted single-technology recipes, sorted.
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
