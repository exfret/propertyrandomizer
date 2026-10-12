local collision_mask_util = require("__core__/lualib/collision-mask-util")

local categories = require("src/prototypes/categories")
local dutils = require("src/prototypes/data-utils")
local gutils = require("src/lib/graph/graph-utils")
local lutils = require("src/logic/logic-utils")
local builder = require("src/logic/builders/builder")

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

    -- Krastorio 2 starts you out with an indestructible lab, but it's spawned with control scripting
    local keys_to_remove = {}
    for my_key, thing in pairs(graph) do
        if thing.stop == key("entity-operate", "lab") then
            table.insert(keys_to_remove, my_key)
        end
    end
    for _, my_key in pairs(keys_to_remove) do
        graph[my_key] = nil
    end
end

return compat