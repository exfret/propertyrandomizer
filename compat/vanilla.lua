local gutils = require("new-lib/graph/graph-utils")

local key = gutils.key

randomization_info.options.unified["spoiling"].blacklisted_pre = {
    [key("item", "copper-bacteria")] = true,
    [key("item", "iron-bacteria")] = true,
}

randomization_info.options.unified["entity-autoplace"].blacklisted_dep = {
    [key("entity", "fulgoran-ruin-attractor")] = true,
}

-- I don't know if this actually is needed right now (which is a good thing)
randomization_info.options.logic.contexts_in_order = {
    key({type = "planet", name = "nauvis"}),
    key({type = "surface", name = "space-platform"}),
    key({type = "planet", name = "vulcanus"}),
    key({type = "planet", name = "fulgora"}),
    key({type = "planet", name = "gleba"}),
    key({type = "planet", name = "aquilo"}),
}