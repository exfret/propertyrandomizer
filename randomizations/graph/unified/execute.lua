local constants = require("helper-tables/constants")
local build_graph = require("lib/graph/build-graph")
local graph_utils = require("lib/graph/graph-utils")
local path = require("lib/graph/path")
local top_sort = require("lib/graph/top-sort")
local helper = require("randomizations/graph/unified/helper")

-- Start with basic prereq shuffle, no surface constraints
-- Then add a bunch of handlers and allow surface jumping (choose 
-- Add surface constraints in later
-- So, thinking about the following issues:
--   1) Recoding surface dependence (solve with styles)
--   2) Right way to solve prereq shuffle with OR nodes (solve with dual graph)
--   3) How to escape topological dependencies (several ideas here, but less likely to work)
--       a. Maybe an initial reordering with slot search on a smaller set of connections?
--       b. Allow surface switching/assign chunks to one surface; need to make sure chunks are sufficiently disconnected (how to assign chunks? Probably exclude global nodes)
-- Just to make sure my super-cool caveats surface idea DOES work, try with simple recipe tech unlock first
-- CRITICAL TODO: Make sure to check critical todo in old unified.lua and check for any that are still applicable here

-- IDEA:
--   * Reverse/dependents randomization for OR nodes?

randomizations.unified = function(id)
    -- Getting handlers
    local default_handler = require("randomizations/graph/unified/handlers/default")
    
    local handlers = {}
    for _, handler_id in pairs(handler_ids) do
        handlers[handler_id] = require("randomizations/graph/unified/handlers/" .. handler_id)

        -- Check that handler has required keys
        for req_key, _ in pairs(default_handler.required_fields) do
            if conn_handlers[handler_id][req_key] == nil then
                error("Handler with ID " .. handler_id " missing required key " .. req_key)
            end
        end

        -- Fill in defaults
        for k, v in pairs(default_handler) do
            if conn_handlers[handler_id][k] == nil then
                conn_handlers[handler_id][k] = v
            end
        end
    end
end