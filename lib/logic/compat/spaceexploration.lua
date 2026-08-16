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

    gutils.add_edge(graph, key("fluid", "se-liquid-rocket-fuel"), key("entity-operate", "se-rocket-launch-pad"))
    gutils.add_edge(graph, key("item", "se-cargo-rocket-section"), key("entity-operate", "se-rocket-launch-pad"))
    gutils.add_edge(graph, key("item", "se-space-capsule"), key("entity-operate", "se-rocket-launch-pad"))

    gutils.add_edge(graph, key("entity-operate", "se-rocket-launch-pad"), key("room", key("control", "space")))
    gutils.add_edge(graph, key("entity-operate", "se-rocket-launch-pad"), key("room", key("control", "space")))

    -- Working on this!
    
    gutils.add_edge(graph, key("entity-operate", "se-rocket-launch-pad"), key("room", key("control", "other-planet")))
    -- Just add enough tiles to place things
    gutils.add_edge(graph, key("room", key("control", "other-planet")), key("tile", "water"))
    gutils.add_edge(graph, key("room", key("control", "other-planet")), key("tile", "grass-1"))
end

return compat