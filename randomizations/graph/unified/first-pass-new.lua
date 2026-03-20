-- Used for contexts
local logic = require("new-lib/logic/init")
local gutils = require("new-lib/graph/graph-utils")
-- Standard top sort
local top = require("new-lib/graph/top-sort")

local first_pass = {}

first_pass.execute = function()
    -- First step: decide reachability
end

return first_pass