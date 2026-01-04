-- Stage 0: Constants, localized globals, and shared helpers
-- No lookups here - just setup for performance

local stage0 = {}

-- Localize frequently-used globals for performance
stage0.pairs = pairs
stage0.ipairs = ipairs
stage0.next = next
stage0.type = type
stage0.table_insert = table.insert
stage0.table_sort = table.sort
stage0.math_floor = math.floor
stage0.math_min = math.min

-- Shared requires (loaded once, passed to stages)
stage0.init_requires = function(lib_name)
    local requires = {}

    requires.categories = require("helper-tables/categories")
    requires.flow_cost = require("lib/graph/flow-cost")
    requires.tutils = require("lib/trigger")
    requires.dutils = require(lib_name .. "/data-utils")
    requires.gutils = require(lib_name .. "/graph/graph-utils")
    requires.lutils = require(lib_name .. "/logic/logic-utils")

    -- Collision mask util with offline support
    if not offline then
        requires.collision_mask_util = require("__core__/lualib/collision-mask-util")
    else
        requires.collision_mask_util = require("offline/lualib/collision-mask-util")
    end

    -- Commonly used shortcut
    requires.prots = requires.dutils.prots

    return requires
end

return stage0
