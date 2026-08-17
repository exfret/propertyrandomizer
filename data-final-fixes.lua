--[[local cost = require("lib/cost/simplex-lp-export")
local top = require("lib/graph/consistent-sort")
local logic = require("lib/logic/init")
local gutils = require("lib/graph/graph-utils")
local packs_in_order = {
    "automation-science-pack",
    "py-science-pack-1",
    "logistic-science-pack",
    "military-science-pack",
    "py-science-pack-2",
    "chemical-science-pack",
    "py-science-pack-3",
    "production-science-pack",
    "py-science-pack-4",
    "utility-science-pack",
    "space-science-pack",
    "full-pyrrhic-victory",
}
for i = 1, #packs_in_order do
    log("I IS THIS VALUE " .. i)
    logic.build()
    local science_pack = packs_in_order[i]
    if science_pack ~= "full-pyrrhic-victory" then
        gutils.add_edge(logic.graph, gutils.key("false", ""), gutils.key("recipe", science_pack))
    end
    local sort_info = top.sort(logic.graph)
    log("SORT COMPLETE")
    cost.export_to_log(sort_info, i)
end
do return end]]




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

-- Duplicates (if applicable)

if config.dupes then
    log("Adding duplicates")

    local dupe = require("lib/dupe")

    --dupe.execute()
    --dupe.execute_vanilla()
end
-- CRITICAL TODO: Uncomment and implement!
--[[if config.duplicate_recipe_tech_unlocks then
    local dupe = require("lib/dupe")
    dupe.recipe_tech_unlocks()
end]]

-- Special prototype fixes
require("randomizations/prefixes")

old_data_raw = table.deepcopy(data.raw)

log("Loading in new dependency graph file")

local new_logic = require("lib/logic/init")
local unified = require("randomizations/graph/unified/execute")

log("Initial reachability check")

local top = require("lib/graph/consistent-sort")
new_logic.build(true)
local init_sort_info = top.sort(new_logic.graph)

-- Load compat code
require("compat/master")

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
    if type(unified_info) == "table" then
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

----------------------------------------------------------------------
-- Setup done!
----------------------------------------------------------------------

-- Do unified randomizations first

for i = 1, config.unified_num_retries do
    unified_info = unified.execute()
    if not unified_info then
        data.raw = table.deepcopy(old_data_raw)
        if i == config.unified_num_retries then
            error("Unified randomization failed. Perhaps try a new seed?")
        end
    else
        break
    end
end

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

-- Fix recycling recipes in case modified by unified rando
--randomizations.fix_recycling_recipes()
-- Rebuild tech tree
randomizations.rebuild_tech_tree()



--[[smuggle_info()
do return end]]




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

    randomizations.recipe_ingredients("recipe_ingredients")
    -- Fix recycling recipes first so that dependency graph is an accurate reflection of reality
    randomizations.fix_recycling_recipes()
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

if settings.startup["propertyrandomizer-tech-tree-rebuild"].value then
    log("Rebuilding tech tree")
    randomizations.rebuild_tech_tree()
end

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

-- Final check for completability

new_logic.build(true)
local final_sort_info = top.sort(new_logic.graph)

--[[local reachability_warning_to_insert
if #final_sort_info.sorted < #initial_sort_info.sorted then
    local first_node_unreachable
    for _, node in pairs(initial_sort_info.sorted) do
        if not final_sort_info.reachable[build_graph.key(node.type, node.name)] and first_node_unreachable == nil then
            first_node_unreachable = node
        end
    end

    local first_tech_unreachable
    local old_reachable_technologies = 0
    for _, node in pairs(initial_sort_info.sorted) do
        if node.type == "technology" then
            old_reachable_technologies = old_reachable_technologies + 1

            if not final_sort_info.reachable[build_graph.key(node.type, node.name)] and first_tech_unreachable == nil then
                first_tech_unreachable = node.name
            end
        end
    end
    local new_reachable_technologies = 0
    for _, node in pairs(final_sort_info.sorted) do
        if node.type == "technology" then
            new_reachable_technologies = new_reachable_technologies + 1
        end
    end
    if new_reachable_technologies < old_reachable_technologies then
        reachability_warning_to_insert = "[img=item.propertyrandomizer-gear] [color=red]exfret's Randomizer:[/color] Potential critical softlock; only " .. tostring(new_reachable_technologies) .. " / " .. tostring(old_reachable_technologies) .. " technologies found reachable. First unreachable found: " .. first_tech_unreachable
        if config.critical_errors then
            error("Critical softlock encountered, only " .. tostring(new_reachable_technologies) .. " / " .. tostring(old_reachable_technologies) .. " technologies reachable.")
        end
    end
end
if reachability_warning_to_insert ~= nil then
    table.insert(randomization_info.warnings, reachability_warning_to_insert)
end]]

-- Add old versions
randomizations.add_old_versions()

-- Add warnings for control stage
smuggle_info()

-- TODO: REMOVE
--log("__DATA_RAW_BEGIN__\n" .. serpent.dump(data.raw) .. "\n__DATA_RAW_END__")

log("Done!")

-- Set config back to nil so that globals aren't floating around
config = nil