DO_FRODO_FIXES = false

local constants = require("helper-tables/constants")

-- Global information for control stage and other uses for communicating between processes
-- TODO: Reorganize globals?
randomization_info = {
    warnings = {},
    -- Whether this prototype has been randomized
    -- Useful for references to other prototypes, like projectiles and spider legs
    touched = {},
    -- Options communicated from config or elsewhere
    options = {
        cost = {},
        logic = {},
        unified = {},
        first_pass = {},
    },
}
local handler_ids = require("helper-tables/handler-ids")
for _, id in pairs(handler_ids) do
    randomization_info.options.unified[id] = {
        blacklisted_pre = {}, 
        blacklisted_dep = {},
    }
end

-- Initial reformats to smooth along everything else
local reformat = require("lib/reformat")
reformat.initial()

-- Get rid of shared references in data.raw that have been causing constant issues
local function copy_without_shared_refs(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = copy_without_shared_refs(v)
    end
    return copy
end
data.raw = copy_without_shared_refs(data.raw)

log("Gathering config")

-- Find randomizations to perform
-- Must be loaded first because it also loads settings
require("config")

-- Load compat code
require("compat/master")

local new_logic = require("lib/logic/init")

local unified_info
local function smuggle_info()
    log("Smuggling control info")

    new_logic.build(true)

    local warnings_selection_tool = table.deepcopy(data.raw.blueprint.blueprint)
    warnings_selection_tool.type = "selection-tool"
    warnings_selection_tool.name = "propertyrandomizer-warnings"
    warnings_selection_tool.select.entity_type_filters = {serpent.dump(randomization_info.warnings)}
    local graph_selection_tool = table.deepcopy(data.raw.blueprint.blueprint)
    graph_selection_tool.type = "selection-tool"
    graph_selection_tool.name = "propertyrandomizer-graph"
    graph_selection_tool.select.entity_type_filters = {serpent.dump(new_logic.graph)}
    local logic_selection_tool = table.deepcopy(data.raw.blueprint.blueprint)
    logic_selection_tool.type = "selection-tool"
    logic_selection_tool.name = "propertyrandomizer-logic"
    logic_selection_tool.select.entity_type_filters = {serpent.dump(new_logic.type_info)}
    local slot_to_trav_selection_tool = table.deepcopy(data.raw.blueprint.blueprint)
    slot_to_trav_selection_tool.type = "selection-tool"
    slot_to_trav_selection_tool.name = "propertyrandomizer-slot-to-trav"
    if type(unified_info) == "table" and unified_info.first_pass_info ~= nil then
        slot_to_trav_selection_tool.select.entity_type_filters = {serpent.dump(unified_info.first_pass_info.slot_to_trav)}
    else
        slot_to_trav_selection_tool.select.entity_type_filters = {}
    end
    data:extend({
        warnings_selection_tool,
        graph_selection_tool,
        logic_selection_tool,
        slot_to_trav_selection_tool,
    })
end

-- If unit testing is on, do only the unit tests
local test = require("tests/execute")
if config.unit_test then
    test.execute()
    smuggle_info()
    return
end

-- Special prototype fixes
require("randomizations/prefixes")

-- Planetary randomization goes first, so the rest of randomization and its checks treat the changed world as the starting point
if config.planetary then
    require("randomizations/planetary/execute").execute(new_logic)
end

old_data_raw = table.deepcopy(data.raw)

log("Loading in new dependency graph file")

local unified = require("randomizations/graph/unified/execute-new")

log("Initial reachability check")

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
new_logic.build(true)
-- Home sets come from the game before randomization and stay fixed, so every later sort with home contexts (the discovery rule in promotion, first pass and the checks) uses these
-- With planetary changes in the game, they're the ones planetary's goals were made with
local planetary_home_sets = config.planetary and require("randomizations/planetary/execute").home_sets()
new_logic.home_sets = planetary_home_sets or top.home_sets(new_logic.graph)
local init_sort_info = top.sort(new_logic.graph)
-- With room/ability contexts (isolatability, automatability), for the mechanic context check at the end
local init_complex_sort_info = top.sort(new_logic.graph, nil, nil, {
    complex_contexts = true,
    home_contexts = true,
})
-- Raw material costs and the major resources for recipe costs come from the logic graph's cost model, in the world planetary changes made
require("lib/cost/graph-cost").derive_cost_options(new_logic.graph, init_sort_info, gutils.key("planet", constants.starting_planet), init_complex_sort_info)

----------------------------------------------------------------------
-- Setup done!
----------------------------------------------------------------------

-- Do unified randomizations first (skipped when no handler is on, see config.dev_unified)

local unified_check = require("randomizations/graph/unified/skeleton/check")
local recycling = require("lib/recycling")
for i = 1, (unified.has_handlers and config.unified_num_retries) or 0 do
    unified_info = unified.execute()
    if unified_info then
        -- Recycling recipes follow the recipes unified randomization changed, as the recycler would have generated them (lib/recycling.lua), so the check sees the game players get
        recycling.regenerate(old_data_raw)
        -- Unified randomization's model can be wrong about the game it builds, so check the game itself (logic rebuilt from it) against the original
        -- An attempt that lost something a player needs fails like any other, so it's retried or errors instead of loading as a softlock
        new_logic.build(true)
        local verdict = unified_check.run(new_logic.graph, init_complex_sort_info, top.sort(new_logic.graph, nil, nil, {
            complex_contexts = true,
            home_contexts = true,
        }), "UNIFIEDCHECK")
        -- The last attempt is kept even then, since a startup error would make the player reset their settings; the final check below warns them instead
        if not verdict.ok and i < config.unified_num_retries then
            log("Unified randomization attempt " .. i .. " built a game that loses what the original had (see the UNIFIEDCHECK lines), so it's retried")
            unified_info = false
        elseif not verdict.ok then
            log("Unified randomization's last attempt built a game that loses what the original had (see the UNIFIEDCHECK lines), and it's kept")
        end
    end
    if not unified_info then
        -- The next attempt rebuilds logic from this (see unified.execute)
        data.raw = table.deepcopy(old_data_raw)
        if i == config.unified_num_retries then
            error("Unified randomization failed. Perhaps try a new seed?")
        end
    else
        break
    end
end

-- Planetary changes in superposed mode are settled once the rest of randomization is done (see randomizations/planetary/execute.lua)
if config.planetary then
    require("randomizations/planetary/execute").settle(new_logic)
end

-- Do old data raw for derandomization here so that necessary graph randomization tweaks stay
old_data_raw_for_derandomization = table.deepcopy(data.raw)

-- NOTE: When adding a dependency graph randomization, add it to constants.lua!

log("Building dependency graph (if applicable)")

-- Load in dependency graph
local build_graph
local build_graph_compat
build_graph = require("lib/old-logic/build-graph")
-- Make dependency graph global
dep_graph = build_graph.graph

-- Add custom nodes
log("Adding custom nodes")
build_graph_compat = require("lib/old-logic/build-graph-compat")

-- Build dependents
log("Adding dependents")
build_graph.add_dependents(dep_graph)

log("Finding initially reachable nodes")
local top_sort = require("lib/old-logic/top-sort")
-- A deepcopy is necessary because otherwise modifications to the nodes by randomizations mess up the sort's "sorted" list
-- TODO: This slows down startup, though, so I want to find a way around it
local initial_sort_info = top_sort.sort(table.deepcopy(dep_graph))

log("Gathering randomizations")

-- Load in randomizations
require("randomizations/master")

-- TODO: Planetary randomizations here
--randomizations.planetary_tiles("planetary-tiles")

log("Applying graph-based randomizations")

-- Rebuild tech tree (setting propertyrandomizer-tech-tree-rebuild)
if config.tech_tree_rebuild then
    randomizations.rebuild_tech_tree()
end

build_graph.load()
dep_graph = build_graph.graph
build_graph_compat.load(dep_graph)
build_graph.add_dependents(dep_graph)

if config.graph.technology then
    -- We currently do tech randomization many times since one time isn't enough to get it that random
    -- Nifyr's new algorithm (see randomizations/graph/core.lua) works a lot better though, so we'll probably end up using that instead
    log("Applying technology tree randomization")

    randomizations.technology_tree_insnipping("technology_tree_insnipping")

    -- Rebuild graph
    build_graph.load()
    dep_graph = build_graph.graph
    build_graph_compat.load(dep_graph)
    build_graph.add_dependents(dep_graph)

    randomizations.technology_tree_insnipping("technology_tree_insnipping")

    -- Rebuild graph
    build_graph.load()
    dep_graph = build_graph.graph
    build_graph_compat.load(dep_graph)
    build_graph.add_dependents(dep_graph)

    randomizations.technology_tree_insnipping("technology_tree_insnipping")

    -- Rebuild graph
    build_graph.load()
    dep_graph = build_graph.graph
    build_graph_compat.load(dep_graph)
    build_graph.add_dependents(dep_graph)

    randomizations.technology_tree_insnipping("technology_tree_insnipping")

    -- Rebuild graph
    build_graph.load()
    dep_graph = build_graph.graph
    build_graph_compat.load(dep_graph)
    build_graph.add_dependents(dep_graph)

    randomizations.technology_tree_insnipping("technology_tree_insnipping")

    -- Rebuild graph
    build_graph.load()
    dep_graph = build_graph.graph
    build_graph_compat.load(dep_graph)
    build_graph.add_dependents(dep_graph)
end

if config.graph.recipe then
    log("Applying recipe ingredients randomization")

    local resource_report = require("lib/cost/resource-report")
    resource_report.run("before")
    randomizations.recipe_ingredients("recipe_ingredients")
    -- Fix recycling recipes first so that dependency graph is an accurate reflection of reality
    randomizations.fix_recycling_recipes()
    resource_report.run("after")
    -- Rebuild graph
    build_graph.load()
    dep_graph = build_graph.graph
    build_graph_compat.load(dep_graph)
    build_graph.add_dependents(dep_graph)
end

if config.graph.recipe_tech_unlock then
    log("Applying recipe tech unlock randomization")

    randomizations.recipe_tech_unlock("recipe_tech_unlock")
    -- Rebuild graph
    build_graph.load()
    dep_graph = build_graph.graph
    build_graph_compat.load(dep_graph)
    build_graph.add_dependents(dep_graph)
end

local item_slot_info = {}
if config.graph.item then
    log("Applying item randomization")

    item_slot_info = randomizations.item_new("item")
    -- Rebuild graph
    build_graph.load()
    dep_graph = build_graph.graph
    build_graph_compat.load(dep_graph)
    build_graph.add_dependents(dep_graph)
end

log("Done applying graph-based randomizations")

log("Applying numerical/misc randomizations")

-- Now randomize
for _, order_group in pairs(randomizations_to_perform) do
    for id, to_perform in pairs(order_group) do
        if to_perform then
            randomizations[id](id)
        end
    end
end

log("Done applying numerical/misc randomizations")

-- Numerical randomization changes recipe amounts and times too, so recycling recipes are generated again from the game as it is now (lib/recycling.lua)
randomizations.fix_recycling_recipes()
-- Both unified and old item randomization change what hand-written recycling recipes recycle
randomizations.fix_recycling_names()

log("Applying extra randomizations")

if config.misc.icon then
    randomizations.all_icons("all_icons")
end
if config.misc.sound then
    randomizations.all_sounds("all_sounds")
end
if config.misc.gui then
    randomizations.group_order("group_order")
    randomizations.recipe_order("recipe_order")
    randomizations.recipe_subgroup("recipe_subgroup")
    randomizations.subgroup_group("subgroup_group")
end
if config.misc.locale then
    randomizations.all_names("all_names")
end
if config.misc.colors ~= "no" then
    randomizations.colors("colors")
end

log("Done applying extra randomizations")

log("Applying fixes")

-- Any fixes needed
randomizations.fixes()
do_overrides_postfixes()

-- Rebuild tech tree post-fixes
if config.tech_tree_rebuild then
    randomizations.rebuild_tech_tree()
end

-- Final check for completability

new_logic.build(true)
local final_sort_info = top.sort(new_logic.graph)
-- Mechanic context check (randomizations/graph/unified/skeleton/check.lua), over room/ability contexts
local final_complex_sort_info = top.sort(new_logic.graph, nil, nil, {
    complex_contexts = true,
    home_contexts = true,
})
-- A game that lost something a player needs could softlock, so the randomizer panel tells the player (reachability data below); a startup error would make them reset their settings
local final_check_ok = require("randomizations/graph/unified/skeleton/check").run(new_logic.graph, init_complex_sort_info, final_complex_sort_info).ok
-- What planetary changes kept, checked against the game before them (only logged for now, as PLANETCHECK final)
if config.planetary then
    require("randomizations/planetary/execute").check_final(new_logic.graph)
end

local reachable = 0
local total = 0
local is_science_pack = {}
for _, lab in pairs(data.raw.lab) do
    for _, input in pairs(lab.inputs) do
        is_science_pack[input] = true
    end
end
for pack, _ in pairs(is_science_pack) do
    local pack_key = gutils.key("item", pack)
    if next(init_sort_info.node_to_context_inds[pack_key]) ~= nil then
        total = 1 + total
        if next(final_sort_info.node_to_context_inds[pack_key]) ~= nil then
            reachable = 1 + reachable
        end
    end
end
data:extend({
    {
        type = "mod-data",
        name = "propertyrandomizer-reachability-data",
        data = {
            ["reachable"] = reachable,
            ["total"] = total,
            -- Whether the mechanic context check found nothing a player needs lost (see skeleton/check.lua)
            ["check_ok"] = final_check_ok,
        }
    }
})

-- Add old versions and postfixes
randomizations.add_old_versions()
randomizations.post_fixes()

-- Add warnings for control stage
smuggle_info()

log("Done!")

-- Set config back to nil so that globals aren't floating around
config = nil
