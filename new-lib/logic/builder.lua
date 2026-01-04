-- Logic graph building helpers
-- Shared state and functions for constructing the dependency graph

local lib_name = "new-lib"
local gutils = require(lib_name .. "/graph/graph-utils")
local key = gutils.key

local helpers = {}

-- Shared state (set during build)
local graph
local type_info
local edge_info

-- Current context for node/edge creation
local curr
local curr_class
local curr_prot

-- Initialize with references to logic tables
function helpers.init(logic_graph, logic_type_info, logic_edge_info)
    graph = logic_graph
    type_info = logic_type_info
    edge_info = logic_edge_info
end

-- Setters for current context
function helpers.set_class(class_name)
    curr_class = class_name
end

function helpers.set_prot(prot)
    curr_prot = prot
end

function helpers.get_curr()
    return curr
end

function helpers.get_curr_prot()
    return curr_prot
end

-- context is nil (signalling default transmit), true (signalling all contexts, as in FORGET), or a string (signaling that specific context, as in ADD/room nodes)
-- abilities is either nil (just transmits), or a list of ints to true/false (showing an ability being added or removed)
-- Note that being false isn't the same as being nil
-- Here is a list and what they correspond to:
--   1. Isolatability: Can be made without transporting other things in (can still use techs gotten by the time that room is reached)
--   2. Automatability: Can be automated (not just mined from non-resource entities or handcrafted only, for example)
function helpers.add_node(node_type, op, context, node_name, extra)
    extra = extra or {}

    if type_info[node_type] == nil then
        type_info[node_type] = {
            op = op,
            context = context,
            canonical = extra.canonical or curr_class,
        }
    end

    extra.class = extra.class or curr_class
    if extra.prot == nil and curr_prot ~= nil then
        extra.prot = key(curr_prot)
    end
    node_name = node_name or curr_prot.name
    curr = gutils.add_node(graph, node_type, node_name, extra)
end

function helpers.add_edge(start_type, start_name, extra)
    start_name = start_name or curr_prot.name
    extra = extra or {}

    local edge_type_key = gutils.concat({start_type, curr.type})
    edge_info[edge_type_key] = edge_info[edge_type_key] or {}
    -- Note that there can be two "types" of edges between the same node types, which maybe could introduce different contexts as well
    -- We currently clobber the abilities to be whatever the last processed edge type had as its abilities, so we don't account for this
    -- CRITICAL TODO: Account for this!
    if extra.abilities ~= nil then
        edge_info[edge_type_key].abilities = extra.abilities
    end
    gutils.add_edge(graph, key(start_type, start_name), key(curr), extra)
end

return helpers
