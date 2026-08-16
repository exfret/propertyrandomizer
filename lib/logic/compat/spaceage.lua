local collision_mask_util = require("__core__/lualib/collision-mask-util")

local lib_name = "lib"
local categories = require("helper-tables/categories")
local dutils = require(lib_name .. "/data-utils")
local gutils = require(lib_name .. "/graph/graph-utils")
local lutils = require(lib_name .. "/logic/logic-utils")
local builder = require(lib_name .. "/logic/builder")

local prots = dutils.prots
local key = gutils.key
local concat = gutils.concat
local add_node = builder.add_node
local add_edge = builder.add_edge
local set_class = builder.set_class
local set_prot = builder.set_prot

local compat = {}

function compat.build(graph, lu)
    set_class("compat")
    set_prot(nil)

    -- Surfaces create empty space, even if it's not in an autoplace
    if mods["space-age"] then
        for _, surface in pairs(data.raw.surface) do
            gutils.add_edge(graph, key("room", key("surface", surface.name)), key("tile", "empty-space"))
        end
    end
end

return compat