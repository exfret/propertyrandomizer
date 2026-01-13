-- Logic dependency graph construction
-- Main entry point that orchestrates the graph building process

-- IDEA/TODO: Cull many edges of the graph by deciding ahead of time what to randomize and not expanding nodes that don't matter
-- For example, if we don't care about whether we can kill certain entities, we can get rid of those entity-kill nodes

-- Note: Only asteroids are checked in entity-kill

-- TODO:
--   * Add note to allow input-output connections in place of pipes for "hold-fluid"
--   * Define ops in same place as node types, where "NODE: ___" currently is, then add an "add_type" function
--   * A use-character for rooms where we can drop stuff and other normal actions (doesn't apply in space)
--   * Construct node type metadata (ops, styles, and gates)
--   * Construct node to canonical function
--   * Add pre, dep keys to nodes
--   * Tables for accessing all nodes/edges of a certain type (precomputed) for niceness
--   * Potentially separate some parts into other files (particularly lookup)
--   * Nodes/edges to nice printable names
--   * Functions for deconstructing key/concat/edge keys
--   * Fun thing after this: randomize collision masks; group some similar masked things etc.

-- OLD TODO:
--   * create general "can be placed down on tile" function and use that in the offshore function
--   * deal with hidden recipes/techs, like recipe-unknown
--   * rocket-part-recipe should respect fixed-recipe (also double check it checks what the silo can do)
--   * code in that burner machines are inoperable in space (that might already just be part of a surface condition)
--   * add prototypes to graph information
--   * figure out why explosions are reachable
--   * add corpses (like stomper corpses)
--   * test for planets that are discovered from start, like nauvis, not just ones you start on
--   * check for ice melting (wait was that just someone trolling me?)
--   * check that surface condition checking works well
--   * minability tech nodes (like researching ability to mine uranium in base game)
--   * add dependence for solar that solar percent is >5% or so (aquilo has some but it shouldn't be relied on)
--   * min working temperatures?
--   * make technologies (and maybe some other things) use item-surface rather than item
--   * add in some basic connections to force certain things earlier, like early automation
--   * prereq/dependent "ID"s so we can figure out which prereqs correspond to which dependents

-- Note: Canonical was for an idea that didn't quite work; I might change it later

-- TERMINOLOGY

-- GRAPH
--   * logic: The underlying game logic, also refers to the dependency graph for the game
--   * key: A unique identifier for indexing into a graph/table; often combines a type and name using the key function
--   * type: A type of node
--   * name: A name for a node that, together with type, uniquely identifies it in the graph
--   * node: A vertex of the dependency graph
--   * edge: A directed connection from one node to another (distinct from a connection)
--   * in: the edges incoming to a node/the prereqs
--   * out: the edges outgoing from a node/the dependents
--   * op: The boolean connective for a node, either AND or OR

-- DATA.RAW
--   * prod: Short for "product"; any ingredient/result
--   * rcat/mcat: Short for recipe/mining category respectively, usually denotes a "spoofed" category which takes fluids into account as well

local lib_name = "new-lib"
local gutils = require(lib_name .. "/graph/graph-utils")
local lu = require(lib_name .. "/lookup/init")
local logic_group = require(lib_name .. "/logic/logic-group")
local builder = require(lib_name .. "/logic/builder")
local concrete = require(lib_name .. "/logic/concrete")
local abstract = require(lib_name .. "/logic/abstract")
local graph_setup = require(lib_name .. "/logic/graph-setup")

local key = gutils.key

local logic = {}

----------------------------------------------------------------------
-- Setup
----------------------------------------------------------------------

-- Contexts currently include rooms (i.e.- where things can be done)
logic.contexts = {}

logic.graph = {}
logic.type_info = {}
-- Needed for edge context info
logic.edge_info = {}

logic.build = function()
    log("Loading lookups")
    lu.load_lookups()

    log("Lookups loaded")

    -- Add contexts
    for room_key, _ in pairs(lu.rooms) do
        logic.contexts[room_key] = true
    end

    logic.graph = {}
    logic.type_info = {}
    logic.edge_info = {}

    -- Initialize helpers with references to our tables
    builder.init(logic.graph, logic.type_info, logic.edge_info)

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Concrete
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

    -- The following nodes represent "concrete" types of things; usually there is a related prototype to point to
    concrete.build(lu)

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Abstract
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

    -- The following nodes represent "abstract" types of things, like electricity, for which there is usually no specific prototype involved
    abstract.build(lu)

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Group
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

    -- Nodes that group other nodes together, like a "boiler" node; useful for later blockification
    -- Also included in a separate file, since this is mod-dependent (currently just implemented for vanilla)

    -- Pass in graph and type_info for modification
    logic_group.build(logic.graph, logic.type_info)

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Balancing
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

    -- Nodes that code in requirements on the logic that aren't strictly necessary, but which are needed to make the game still pragmatically playable (like having inserters/basic automation)
    -- These are included in a separate file to separate them out from the "real logic"
    -- A lot of the time, this can just end up adding edges from nodes created by logic_group

    -- TODO

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Hotfixes
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

    -- TODO: Fix these
    -- Right now, we don't add the extra tiles from the starter pack
    if mods["space-age"] then
        gutils.add_edge(logic.graph, key("room", key("surface", "space-platform")), key("tile", "space-platform-foundation"))
    end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Graph lookups
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

    graph_setup.build(logic)
end

return logic
