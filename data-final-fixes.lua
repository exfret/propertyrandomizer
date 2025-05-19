log("Setup")

-- Global information for control stage and other uses for communicating between processes
randomization_info = {
    warnings = {},
    -- Whether this prototype has been randomized
    -- Useful for references to other prototypes, like projectiles and spider legs
    touched = {},
    -- Options communicated from config or elsewhere
    options = {}
}

log("Gathering config")

-- Find randomizations to perform
-- Must be loaded first because it also loads settings
require("config")

log("Building dependency graph (if applicable)")

-- Load in dependency graph
local build_graph
local build_graph_compat
if randomization_info.options.build_graph then
    build_graph = require("lib/graph/build-graph")
    -- Make dependency graph global
    dep_graph = build_graph.graph

    -- Add custom nodes
    log("Adding custom nodes")
    build_graph_compat = require("lib/graph/build-graph-compat")

    -- Build dependents
    log("Adding dependents")
    build_graph.add_dependents(dep_graph)
end

log("Gathering randomizations")

-- Load in randomizations
require("randomizations/master")

log("Applying basic randomizations")

-- Now randomize
for id, to_perform in pairs(randomizations_to_perform) do
    if to_perform then
        randomizations[id](id)
    end
end

log("Done applying basic randomizations")


-- CRITICAL TODO: Return these to normal
--[[do_stupid_randomization_chance = 0.01
randomizations.recipe_order("recipe_order")
randomizations.recipe_subgroup("recipe_subgroup")
randomizations.subgroup_group("subgroup_group")
do_stupid_randomization_chance = 0.75
randomizations.group_order("group_order")
do_stupid_randomization_chance = 0.01
randomizations.all_names("all_names")
randomizations.all_icons("all_icons")]]
--randomizations.all_sounds("all_sounds")

randomizations.technology_tree("technology_tree")

build_graph.load()
dep_graph = build_graph.graph
build_graph_compat.load(dep_graph)
build_graph.add_dependents(dep_graph)
randomizations.recipe_ingredients("recipe_ingredients")

--[[local top_sort = require("lib/graph/top-sort")
for _, node in pairs(top_sort.sort(dep_graph).sorted) do
    log(build_graph.key(node.type, node.name))
end]]

build_graph.load()
dep_graph = build_graph.graph
build_graph_compat.load(dep_graph)
build_graph.add_dependents(dep_graph)
randomizations.item("item")






log("Applying fixes")

-- Any fixes needed
randomizations.fixes()

log("Smuggling control info")

-- Add warnings for control stage
local warnings_selection_tool = table.deepcopy(data.raw.blueprint.blueprint)
warnings_selection_tool.type = "selection-tool"
warnings_selection_tool.name = "propertyrandomizer-warnings"
warnings_selection_tool.select.entity_type_filters = {serpent.dump(randomization_info.warnings)}
data:extend({
    warnings_selection_tool
})

log("Done!")