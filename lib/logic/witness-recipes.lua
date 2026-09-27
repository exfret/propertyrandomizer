-- The recipes a pebble directly needs, for giving rebuilt techs their prerequisites (randomizations.rebuild_tech_tree in randomizations/fixes.lua)
-- These are the recipes on its witness that get a tech, not looking past them, since that tech's own prerequisites cover what they need
-- The witness goes on through a recipe that gets no tech, since no tech's prerequisites would carry what that recipe needs
-- Like a machine's fixed recipe (enabled in randomizations/prefixes.lua): the captive spawner's burns bioflux, and stopping there left a recipe needing its biter eggs a tech without prerequisites

local top = require("lib/graph/context-sort")

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

return witness_recipes
