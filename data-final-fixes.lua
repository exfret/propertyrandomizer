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
if randomization_info.options.build_graph then
    build_graph = require("lib/graph/build-graph")
    -- Make dependency graph global
    dep_graph = build_graph.graph
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





randomizations.recipe_ingredients("recipe_ingredients")






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