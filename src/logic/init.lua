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

local gutils = require("src/lib/graph/graph-utils")
local logic = require("src/logic/state")
local ctx = require("src/logic/contexts/contexts")

-- If this is control stage, just get the contexts and type info
if data == nil then
    logic.contexts = {}

    -- Add contexts
    for _, planet in pairs(prototypes.space_location) do
        if planet.type == "planet" then
            logic.contexts[gutils.key(planet)] = true
        end
    end
    for _, surface in pairs(prototypes.surface) do
        logic.contexts[gutils.key(surface)] = true
    end

    for data, _ in pairs(prototypes.item["propertyrandomizer-logic"].get_entity_type_filters(defines.selection_mode.select)) do
        local _, logic_type_info = serpent.load(data)
        logic.type_info = logic_type_info
        break
    end

    -- Context numbers are the data stage's (planet copies can't be told from their originals here, see src/logic/contexts/contexts.lua)
    ctx.import_rooms(prototypes.mod_data["propertyrandomizer-contexts"].data)

    return logic
end

local constants = require("src/config/constants")
local surface_sets = require("src/prototypes/surfaces/surface-sets")

-- Rooms are numbered from the starting planet, and a planet's copies are shifted copies of their original (src/logic/contexts/contexts.lua)
ctx.start_room = gutils.key("planet", constants.starting_planet)
ctx.copy_of = function(room_key)
    local family = surface_sets.family_of(room_key)
    if family ~= room_key then
        return family, surface_sets.copy_number(room_key)
    end
    return nil
end
local lu = require("src/prototypes/lookup/init")
local logic_group = require("src/logic/builders/logic-group")
local group = require("src/logic/builders/groups")
local builder = require("src/logic/builders/builder")
local concrete = require("src/logic/builders/concrete")
local abstract = require("src/logic/builders/abstract")
local balance_mechanics = require("src/logic/builders/balance-mechanics")
local entity_supply = require("src/logic/builders/entity-supply")
local combat_encounters = require("src/logic/builders/combat-encounters")
local compat_bobs = require("src/logic/compat/bobs")
local compat_krastorio = require("src/logic/compat/krastorio")
local compat_pyfull = require("src/logic/compat/pyfull")
local compat_spaceage = require("src/logic/compat/spaceage")
local compat_spaceexploration = require("src/logic/compat/spaceexploration")
local graph_setup = require("src/logic/builders/graph-setup")
local bootstrap = require("src/logic/builders/bootstrap")
local pass_through = require("src/logic/analysis/pass-through")
local reductions = require("src/logic/analysis/reductions")
local reduction_check = require("src/logic/analysis/reduction-check")
local unlock_contraction = require("src/logic/analysis/unlock-contraction")
local item_craft = require("src/logic/builders/item-craft")

local key = gutils.key

----------------------------------------------------------------------
-- Setup
----------------------------------------------------------------------

-- Contexts currently include rooms (i.e.- where things can be done)
logic.contexts = {}

logic.graph = {}
logic.type_info = {}
-- Needed for edge context info
logic.edge_info = {}

local function build(extra_params)
    extra_params = extra_params or {}
    -- extra_params.tech_gated_unlocks stays off unless the caller sets it: control.lua unlocks mining with fluid and space platforms at the start of every game, so their technologies aren't prereqs here
    -- Other randomizers extracting this logic, which don't unlock them at the start, pass tech_gated_unlocks = true

    --log("Loading lookups")
    lu.load_lookups()
    -- Just make it a global
    lookups = lu
    -- Recipe categories sharing a node in this build (lutils.rcat_node_name), nil when the graph isn't reduced
    logic.rcat_canonical = lu.rcat_canonical

    --log("Lookups loaded")

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
    concrete.build(lu, extra_params)

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Abstract
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

    -- The following nodes represent "abstract" types of things, like electricity, for which there is usually no specific prototype involved
    abstract.build(lu, extra_params)

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
-- Groups (new)
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

    group.build(lu)

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Balancing
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

    -- Standalone balance goals protect practical capabilities without adding prerequisites to technologies or recipes.
    balance_mechanics.build(lu)
    -- The combat check (src/logic/builders/combat-encounters.lua): what kills each target on its own, which kills, asteroid routes and attack groups need
    -- extra_params.combat_check: time_limit = false for the final check; difficulty and time_multiplier override the settings
    logic.combat_encounters, logic.combat_diagnostics = combat_encounters.build(logic.graph, lu, extra_params.combat_check)
    -- Entity randomization needs some member of each bulk entity class to stay suppliable automatically
    if config.entity_randomization then
        entity_supply.build(lu)
    end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Compat
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

    -- This is mostly for "special cases"; things that can be handled more programmatically like py modules are in the appropriate node locations

    if mods["boblibrary"] then
        compat_bobs.build(logic.graph, lu)
    end

    if mods["Krastorio2"] then
        compat_krastorio.build(logic.graph, lu)
    end

    if mods["pyalternativeenergy"] then
        compat_pyfull.build(logic.graph, lu)
    end

    if mods["space-age"] then
        compat_spaceage.build(logic.graph, lu)
    end

    if mods["space-exploration"] then
        compat_spaceexploration.build(logic.graph, lu)
    end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Hotfixes
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Graph lookups
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

    graph_setup.build(logic)

    -- The reduced graph (src/logic/analysis/reductions.lua): nodes that only pass on their one way in are left out (src/logic/analysis/pass-through.lua)
    -- A recipe one technology unlocks, with nothing else unlocking it, gets that technology's edge directly (src/logic/analysis/unlock-contraction.lua), and so do the dependents of the types declared pass-through
    if reductions.enabled then
        unlock_contraction.contract(logic.graph)
        pass_through.contract(logic.graph)
        item_craft.contract(logic.graph)
    end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Bootstrap infrastructure
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

    -- Delivered buildings count as local only where the room can then make them (src/logic/builders/bootstrap.lua); extra_params.home_sets are the home sets to judge that with
    bootstrap.prune(logic, extra_params.home_sets, extra_params.bootstrap_from_last)

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Mod fixes
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

    for ind, fix in pairs(RANDOMIZER_HOOK.GRAPH_FIXES) do
        if type(ind) ~= "number" or math.floor(tonumber(ind)) ~= tonumber(ind) then
            error("Non-integer key deteceted! Graph fixes must be given as a list, such as with table.insert().")
        end
        if type(fix) ~= "function" then
            error("Non-function passed as graph fix. Make sure to pass fixes as functions with signature my_fix(params).")
        end
        fix({
            -- Most other files can be included directly since they are just helper functions
            logic = logic,
            lookups = lu,
        })
    end

end

-- Builds the logic graph from data.raw (logic.graph, logic.type_info, logic.edge_info and logic.contexts), reduced (src/logic/analysis/reductions.lua)
-- With the hidden test-reductions setting, every build is made twice from the same data.raw, full and reduced, and src/logic/analysis/reduction-check.lua compares them; the game keeps the reduced one
local checking_reductions = false
logic.build = function(extra_params)
    if config == nil or config.test_reductions ~= true or checking_reductions then
        build(extra_params)
        return
    end
    checking_reductions = true
    local caller = debug.getinfo(2, "Sl")
    local where = caller ~= nil and (tostring(caller.short_src) .. ":" .. tostring(caller.currentline)) or "?"
    reductions.enabled = false
    build(extra_params)
    local full = logic.graph
    reductions.enabled = true
    build(extra_params)
    reduction_check.compare(full, logic.graph, (extra_params or {}).home_sets or logic.home_sets, where)
    checking_reductions = false
end

return logic
