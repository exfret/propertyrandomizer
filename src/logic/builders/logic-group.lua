local dutils = require("src/prototypes/data-utils")
local gutils = require("src/lib/graph/graph-utils")

local prots = dutils.prots
local key = gutils.key
local concat = gutils.concat
local ekey = gutils.ekey

local logic_group = {}

-- This is duplicated code from logic.lua
-- Unfortunately, I couldn't think of a better way to do this
-- There are two changes: canonical is based on type_name, not curr_class, and node_name is set to "" by default
local curr
local curr_class
local curr_prot
-- context is nil (signalling default transmit), true (signalling all contexts, as in FORGET), or a string (signaling that specific context, as in ADD/room nodes)
local function add_node(node_type, op, context, node_name, extra)
    extra = extra or {}

    if logic_group.type_info[node_type] == nil then
        logic_group.type_info[node_type] = {
            op = op,
            context = context,
            canonical = extra.canonical or node_type,
        }
    end

    extra.class = extra.class or curr_class
    if extra.prot == nil and curr_prot ~= nil then
        extra.prot = key(curr_prot)
    end
    node_name = node_name or ""
    curr = gutils.add_node(logic_group.graph, node_type, node_name, extra)
end
local function add_edge(start_type, start_name, extra)
    start_name = start_name or ""
    gutils.add_edge(logic_group.graph, key(start_type, start_name), key(curr), extra)
end

logic_group.build = function(graph, type_info)
    logic_group.graph = graph
    logic_group.type_info = type_info

    curr_class = "logic-groups"

    ----------------------------------------------------------------------
    -- Start
    ----------------------------------------------------------------------

    -- Assume the resources on each planet have already been spoofed to be different entities/items
    -- We should probably then hardcode planet --> resources like items groups
    -- I'm now realizing we might have to do an item rando move and separate out the item crafts and items
    -- Or wait, do we need to worry about that for this stage? I'm just worried about it having difficulties when there's the whole recipe tree
    -- Oooh, we could keep the recipe sort different, and if we need a new item, just conjure the next recipe
    -- Then, its index is updated automatically or something, on-the-fly, during the second pass
    -- Though, before we do that fanciness, let's just try with some dumb hardcoding-ish methods for getting common intermediates
    -- Wait, so we could assign different resources to different planets, but then it would be difficult to sync things up for isolated access to silo

    -- NOTE: We could make chunk sorting work by having intra-chunk edges first in the prereq order and doing a depth-first search
    --         To enforce finding the chunk all at once, we could use and AND node gating all the prerequisites

    ----------------------------------------------------------------------
    -- Fuel
    ----------------------------------------------------------------------

    -- There's no steam power mechanic: it's one route to electricity, and energy-source-electric-production already protects electricity itself, so steam engines are free to come later when something else provides power

    ----------------------------------------
    add_node("chemical-fuel", "OR", nil, nil, { mechanic = true })
    ----------------------------------------
    -- Can we get a chemical fuel without a burnt fuel result?
    -- Use the shared category node, where first pass keeps replacement fuel on the resource position.
    -- Direct item edges would separately require the original fuel identities, even when the replacement provides that fuel.
    local fcat_key = concat({
        dutils.REPLACEMENT_FUEL_CATEGORY,
        0,
    })
    if graph[key("fuel-category", fcat_key)] ~= nil then
        add_edge("fuel-category", fcat_key)
    end

end

return logic_group
