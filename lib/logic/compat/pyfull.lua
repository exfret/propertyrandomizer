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

    add_edge("logic-or", "bioport-hidden-recipe-food", nil, "recipe", "bioport-hidden-recipe")
    ----------------------------------------
    add_node("logic-or", "OR", nil, "bioport-hidden-recipe-food")
    ----------------------------------------
    -- Can we provide this biopyanoport with food?
    add_edge("item", "workers-food")
    add_edge("item", "workers-food-02")
    add_edge("item", "workers-food-03")

    add_edge("logic-or", "bioport-hidden-recipe-animal", nil, "recipe", "bioport-hidden-recipe")
    ----------------------------------------
    add_node("logic-or", "OR", nil, "bioport-hidden-recipe-animal")
    ----------------------------------------
    -- Can we provide this biopyanoport with an animal to work in it?
    add_edge("item", "chorkok")
    add_edge("item", "huzu")
    add_edge("item", "gobachov")

    add_edge("logic-and", "bioport-hidden-recipe-logistic-component", nil, "recipe", "bioport-hidden-recipe")
    ----------------------------------------
    add_node("logic-and", "AND", nil, "bioport-hidden-recipe-logistic-component")
    ----------------------------------------
    -- Can we provide this biopyanoport with the provider and requester to allow animals to actually work?
    add_edge("entity-operate", "provider-tank")
    add_edge("entity-operate", "requester-tank")
end

return compat