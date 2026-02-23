local gutils = require("new-lib/graph/graph-utils")

randomization_info.options.unified["spoiling"].blacklisted_pre = {
    [gutils.key("item", "copper-bacteria")] = true,
    [gutils.key("item", "iron-bacteria")] = true,
}