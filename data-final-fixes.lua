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

-- TODO: Planetary randomizations here

log("Applying graph-based randomizations")

if settings.startup["propertyrandomizer-technology"].value then
    log("Applying technology tree randomization")

    randomizations.technology_tree_insnipping("technology_tree_insnipping")
    -- Rebuild graph
    build_graph.load()
    dep_graph = build_graph.graph
    build_graph_compat.load(dep_graph)
    build_graph.add_dependents(dep_graph)
end

if settings.startup["propertyrandomizer-recipe"].value then
    log("Applying recipe ingredients randomization")

    randomizations.recipe_ingredients("recipe_ingredients")
    -- Rebuild graph
    build_graph.load()
    dep_graph = build_graph.graph
    build_graph_compat.load(dep_graph)
    build_graph.add_dependents(dep_graph)
end

if settings.startup["propertyrandomizer-item"].value then
    log("Applying item randomization")

    randomizations.item("item")
    -- Rebuild graph
    build_graph.load()
    dep_graph = build_graph.graph
    build_graph_compat.load(dep_graph)
    build_graph.add_dependents(dep_graph)
end

log("Done applying graph-based randomizations")

log("Applying numerical/misc randomizations")

-- Now randomize
for id, to_perform in pairs(randomizations_to_perform) do
    if to_perform then
        randomizations[id](id)
    end
end

log("Done applying numerical/misc randomizations")

log("Applying extra randomizations")

if settings.startup["propertyrandomizer-icon"].value then
    randomizations.all_icons("all_icons")
end
if settings.startup["propertyrandomizer-sound"].value then
    randomizations.all_sounds("all_sounds")
end
if settings.startup["propertyrandomizer-gui"].value then
    randomizations.group_order("group_order")
    randomizations.recipe_order("recipe_order")
    randomizations.recipe_subgroup("recipe_subgroup")
    randomizations.subgroup_group("subgroup_group")
end
if settings.startup["propertyrandomizer-locale"].value then
    randomizations.all_names("all_names")
end

log("Done applying extra randomizations")

log("Applying fixes")

-- Any fixes needed
randomizations.fixes()

-- Add warnings for control stage
if not offline then
    log("Smuggling control info")

    local warnings_selection_tool = table.deepcopy(data.raw.blueprint.blueprint)
    warnings_selection_tool.type = "selection-tool"
    warnings_selection_tool.name = "propertyrandomizer-warnings"
    warnings_selection_tool.select.entity_type_filters = {serpent.dump(randomization_info.warnings)}
    data:extend({
        warnings_selection_tool
    })
end

log("Done!")







--randomizations.planetary_tiles("planetary_tiles")