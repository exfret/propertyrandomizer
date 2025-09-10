local build_graph = require("lib/graph/build-graph")
local top_sort = require("lib/graph/top-sort")
local rng = require("lib/random/rng")

randomizations.recipe_tech_unlock = function(id)
    local sort_info = top_sort.sort(dep_graph)
    local graph_sort = sort_info.sorted

    -- Let's just treat recipe unlocks like they're AND nodes even though they're actually OR's, this will simplify some things

    local unlock_sort = {}
    local blacklist = {}
    for _, node in pairs(graph_sort) do
        
    end
end