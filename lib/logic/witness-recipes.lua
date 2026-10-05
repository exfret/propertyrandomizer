-- The recipes a pebble directly needs, for giving rebuilt techs their prerequisites (randomizations.rebuild_tech_tree in randomizations/fixes.lua)
-- These are the recipes on its witness that get a tech, not looking past them, since that tech's own prerequisites cover what they need
-- The witness goes on through a recipe that gets no tech, since no tech's prerequisites would carry what that recipe needs
-- Like a machine's fixed recipe (enabled in randomizations/prefixes.lua): the captive spawner's burns bioflux, and stopping there left a recipe needing its biter eggs a tech without prerequisites

local top = require("lib/graph/context-sort")
local gutils = require("lib/graph/graph-utils")

local witness_recipes = {}

-- The names of the recipes the pebble at ind in sort_info directly needs, as a set; gets_tech(recipe_name) says whether a recipe gets a tech
witness_recipes.of = function(graph, sort_info, ind, gets_tech)
    local function has_tech(node_key)
        local node = graph.nodes[node_key]
        return node.type == "recipe" and gets_tech(node.name)
    end

    local path_info = top.path(graph, {ind}, sort_info, {
        stop_if = function(pebble)
            return has_tech(pebble.node_key)
        end,
    })
    local recipes = {}
    for other_ind, _ in pairs(path_info.in_path) do
        -- Don't count ind itself
        if other_ind < ind then
            local other_key = sort_info.sorted[other_ind].node_key
            if has_tech(other_key) then
                recipes[graph.nodes[other_key].name] = true
            end
        end
    end
    return recipes
end

-- Use the research method actually copied onto the rebuilt technology.
-- A recipe's earliest witness can use another unlocking technology or a fixed recipe instead.
-- Technology prerequisites have already been removed from this graph, leaving the recipes needed for the science packs or the research trigger itself.
witness_recipes.research = function(graph, sort_info, tech_name, gets_tech)
    local first
    for _, ind in pairs(sort_info.node_to_context_inds[gutils.key("technology", tech_name)] or {}) do
        if first == nil or ind < first then
            first = ind
        end
    end
    if first == nil then
        return nil
    end
    return witness_recipes.of(graph, sort_info, first, gets_tech)
end

-- Add a research witness only if its prerequisites preserve contexts and cannot lead back to the recipe being unlocked.
witness_recipes.extend = function(recipe_to_prev, recipe_name, requirements, covers)
    local function reaches(start, seen)
        if start == recipe_name then
            return true
        end
        if seen[start] ~= nil then
            return false
        end
        seen[start] = true
        for pre, _ in pairs(recipe_to_prev[start] or {}) do
            if reaches(pre, seen) then
                return true
            end
        end
        return false
    end
    for pre, _ in pairs(requirements) do
        if not covers(pre, recipe_name) or reaches(pre, {}) then
            return false
        end
    end
    for pre, _ in pairs(requirements) do
        recipe_to_prev[recipe_name][pre] = true
    end
    return true
end

return witness_recipes
