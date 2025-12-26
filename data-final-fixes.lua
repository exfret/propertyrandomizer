log("Setup")

local logic = require("new-lib/logic/logic")
local gutils = require("new-lib/graph/graph-utils")

log("Building")
logic.build()

log("Normal build-graph")

-- CRITICAL TODO: FIX CONTROL PHASE TOO (UNCOMMENT)

local build_graph = require("lib/graph/build-graph")
local old_ops = table.deepcopy(build_graph.ops)
build_graph.add_dependents(build_graph.graph)

log("Done")

local node_amount = 0
local edge_amount = 0
local node_type_to_edges = {}
for _, node in pairs(build_graph.graph) do
    node_amount = node_amount + 1
    edge_amount = edge_amount + #node.prereqs
    if node_type_to_edges[node.type] == nil then
        node_type_to_edges[node.type] = 0
    end
    node_type_to_edges[node.type] = node_type_to_edges[node.type] + #node.prereqs
end
--[[log(node_amount)
log(edge_amount)
local type_edges_list = {}
for node_type, amount in pairs(node_type_to_edges) do
    table.insert(type_edges_list, {
        type = node_type,
        amount = amount
    })
end
table.sort(type_edges_list, function(a, b)
    return a.amount < b.amount
end)
log(serpent.block(type_edges_list))]]

node_amount = 0
edge_amount = 0
node_type_to_edges = {}
for _, node in pairs(logic.graph.nodes) do
    node_amount = node_amount + 1
    if node_type_to_edges[node.type] == nil then
        node_type_to_edges[node.type] = 0
    end
    local num_pre = 0
    for _, _ in pairs(node.pre) do
        num_pre = num_pre + 1
    end
    node_type_to_edges[node.type] = node_type_to_edges[node.type] + num_pre
end
for _, edge in pairs(logic.graph.edges) do
    edge_amount = edge_amount + 1
end
--[[log(node_amount)
log(edge_amount)
type_edges_list = {}
for node_type, amount in pairs(node_type_to_edges) do
    table.insert(type_edges_list, {
        type = node_type,
        amount = amount
    })
end
table.sort(type_edges_list, function(a, b)
    return a.amount < b.amount
end)
log(serpent.block(type_edges_list))]]

log("top-sort original")

local top1 = require("lib/graph/top-sort")
local sort_info = top1.sort(build_graph.graph)

log("top-sort new")

local top = require("new-lib/graph/top-sort")
sort_info = top.sort(logic.graph)

log("end sort")

-- Try with new path algo
local promethium_inds = sort_info.node_to_open_inds[gutils.key({type = "item", name = "promethium-science-pack"})]
local earliest_ind
for ind, _ in pairs(promethium_inds) do
    if earliest_ind == nil or ind < earliest_ind then
        earliest_ind = ind
    end
end
local path = top.path(logic.graph, { ind = earliest_ind, context = gutils.key({type = "surface", name = "space-platform"}) }, sort_info)
local encountered = {}
table.sort(path, function(a, b)
    return a.ind > b.ind
end)
local num_items = 0
local num_nodes = 0
for i = #path, 1, -1 do
    if not encountered[sort_info.open[path[i].ind].node] then
        encountered[sort_info.open[path[i].ind].node] = true
        num_nodes = num_nodes + 1
        if logic.graph.nodes[sort_info.open[path[i].ind].node].type == "item" then
            num_items = num_items + 1
            --log(sort_info.open[path[i].ind].node)
        end
    end
end
local encountered_sort = {}
local total_num_items = 0
local total_num_nodes = 0
for _, open_info in pairs(sort_info.open) do
    if not encountered_sort[open_info.node] then
        encountered_sort[open_info.node] = true
        total_num_nodes = total_num_nodes + 1
        if logic.graph.nodes[open_info.node].type == "item" then
            total_num_items = total_num_items + 1
            --log(open_info.node)
        end
    end
end
--[[log(num_items)
log(total_num_items)
log(num_nodes)
log(total_num_nodes)]]

log("require")

randomizations = {}
require("randomizations/graph/recipe-tech-unlock")

log("randomization")

global_seed = 238597

local unified = require("randomizations/graph/unified/new/execute")
-- Unified builds its own graph
unified.execute()

local recipe_results = require("randomizations/graph/unified/recipe-results")
--recipe_results.execute(logic.graph)

--[[randomizations.recipe_tech_unlock_new(logic.graph)

log("Did it work?")

build_graph.load()
build_graph.add_dependents(build_graph.graph)

log("Actual rando")
dep_graph = build_graph.graph
randomizations.recipe_tech_unlock("recipe_tech_unlock")

log("Okay how long did that take?")]]

build_graph.ops = old_ops
build_graph.load()
local graph_utils = require("lib/graph/graph-utils")
build_graph.add_dependents(build_graph.graph)
graph_utils.add_prereq(build_graph.graph[build_graph.key("build-entity-surface-condition-true", "canonical")], build_graph.graph[build_graph.key("item-surface", build_graph.compound_key({"pentapod-egg", build_graph.compound_key({"planet", "gleba"})}))])
local more_sort_info = top1.sort(build_graph.graph)
for _, tech in pairs(data.raw.technology) do
    if not more_sort_info.reachable[build_graph.key("technology", tech.name)] and tech.name ~= "research-productivity" then
        log(serpent.block(more_sort_info.reachable))
        error(tech.name)
    end
end

--[[for _, node_info in pairs(sort_info.sorted) do
    log("(" .. serpent.block(node_info.contexts) .. ")" .. "\n\t\t" .. node_info.node .. "\n")
end]]

--[=[
-- Global information for control stage and other uses for communicating between processes
randomization_info = {
    warnings = {},
    -- Whether this prototype has been randomized
    -- Useful for references to other prototypes, like projectiles and spider legs
    touched = {},
    -- Options communicated from config or elsewhere
    options = {}
}

log("Gathering config")

-- Find randomizations to perform
-- Must be loaded first because it also loads settings
require("config")

-- Initial reformats to smooth along everything else
local reformat = require("lib/reformat")
reformat.initial()

-- Special changes for watch the world burn mode
if settings.startup["propertyrandomizer-watch-the-world-burn"].value then
    require("watch-the-world-burn")
end

-- Duplicates (if applicable)

if settings.startup["propertyrandomizer-dupes"].value then
    log("Adding duplicates")

    local dupe = require("lib/dupe")

    dupe.execute()
end

-- NOTE: When adding a dependency graph randomization, add it to constants.lua!

log("Building dependency graph (if applicable)")

-- Load in dependency graph
local build_graph
local build_graph_compat
build_graph = require("lib/graph/build-graph")
-- Make dependency graph global
dep_graph = build_graph.graph

-- Add custom nodes
log("Adding custom nodes")
build_graph_compat = require("lib/graph/build-graph-compat")

-- Build dependents
log("Adding dependents")
build_graph.add_dependents(dep_graph)

log("Finding initially reachable nodes")
local top_sort = require("lib/graph/top-sort")
-- A deepcopy is necessary because otherwise modifications to the nodes by randomizations mess up the sort's "sorted" list
-- TODO: This slows down startup, though, so I want to find a way around it
local initial_sort_info = top_sort.sort(table.deepcopy(dep_graph))

log("Gathering randomizations")

-- Load in randomizations
require("randomizations/master")

-- TODO: Planetary randomizations here
--randomizations.planetary_tiles("planetary-tiles")

log("Applying graph-based randomizations")

build_graph.load()
dep_graph = build_graph.graph
build_graph_compat.load(dep_graph)
build_graph.add_dependents(dep_graph)

if settings.startup["propertyrandomizer-simultaneous"].value then
    --randomizations.graph("graph")

    -- Rebuild graph
    build_graph.load()
    dep_graph = build_graph.graph
    build_graph_compat.load(dep_graph)
    build_graph.add_dependents(dep_graph)
end

--if settings.startup["propertyrandomizer-unified"].value then
    randomizations.unified("unified")

    -- Rebuild graph
    build_graph.load()
    dep_graph = build_graph.graph
    build_graph_compat.load(dep_graph)
    build_graph.add_dependents(dep_graph)
--end

if settings.startup["propertyrandomizer-technology"].value then
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

if settings.startup["propertyrandomizer-recipe"].value then
    log("Applying recipe ingredients randomization")

    randomizations.recipe_ingredients("recipe_ingredients")
    -- Rebuild graph
    build_graph.load()
    dep_graph = build_graph.graph
    build_graph_compat.load(dep_graph)
    build_graph.add_dependents(dep_graph)
end

if settings.startup["propertyrandomizer-recipe-tech-unlock"].value then
    log("Applying recipe tech unlock randomization")

    randomizations.recipe_tech_unlock("recipe_tech_unlock")
    -- Rebuild graph
    build_graph.load()
    dep_graph = build_graph.graph
    build_graph_compat.load(dep_graph)
    build_graph.add_dependents(dep_graph)
end

local item_slot_info = {}
if settings.startup["propertyrandomizer-item"].value then
    log("Applying item randomization")

    item_slot_info = randomizations.item_new("item-new")
    -- Rebuild graph
    build_graph.load()
    dep_graph = build_graph.graph
    build_graph_compat.load(dep_graph)
    build_graph.add_dependents(dep_graph)

    --[[while true do
        local should_break = randomizations.item("item")
        -- Rebuild graph
        build_graph.load()
        dep_graph = build_graph.graph
        build_graph_compat.load(dep_graph)
        build_graph.add_dependents(dep_graph)
        if should_break then
            break
        end
    end]]
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

log("Applying extra randomizations")

if settings.startup["propertyrandomizer-icon"].value then
    randomizations.all_icons("all_icons")
end
if settings.startup["propertyrandomizer-sound"].value then
    randomizations.all_sounds("all_sounds")
end
if settings.startup["propertyrandomizer-gui"].value then
    randomizations.group_order("group_order")
    randomizations.recipe_order("recipe_order")
    randomizations.recipe_subgroup("recipe_subgroup")
    randomizations.subgroup_group("subgroup_group")
end
if settings.startup["propertyrandomizer-locale"].value then
    randomizations.all_names("all_names")
end

log("Done applying extra randomizations")

log("Applying fixes")

-- Any fixes needed
randomizations.fixes()

-- Final check for completability

local final_sort_info = top_sort.sort(dep_graph)

--[[for _, node in pairs(final_sort_info.sorted) do
    log(build_graph.key(node.type, node.name))
end]]

local reachability_warning_to_insert
if #final_sort_info.sorted < #initial_sort_info.sorted then
    log(serpent.block(final_sort_info.reachable))

    local first_node_unreachable
    for _, node in pairs(initial_sort_info.sorted) do
        if not final_sort_info.reachable[build_graph.key(node.type, node.name)] and first_node_unreachable == nil then
            first_node_unreachable = node
        end
    end
    log("First unreachable...")
    log(serpent.block(first_node_unreachable))

    -- It's legitimately possible for some nodes to be no longer possible, like crafting impossible if something is a resource
    --[[if settings.startup["propertyrandomizer-softlock-prevention"].value == "all" then
        error("Softlock encountered, only " .. tostring(#final_sort_info.sorted) .. " / " .. tostring(#initial_sort_info.sorted) .. " nodes reachable.")
    else
        reachability_warning_to_insert = "[img=item.propertyrandomizer-gear] [color=red]exfret's Randomizer:[/color] Potential softlock encountered, only " .. tostring(#final_sort_info.sorted) .. " / " .. tostring(#initial_sort_info.sorted) .. " game pieces reachable."
    end]]

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
        if settings.startup["propertyrandomizer-softlock-prevention"].value == "critical" then
            error("Critical softlock encountered, only " .. tostring(new_reachable_technologies) .. " / " .. tostring(old_reachable_technologies) .. " technologies reachable.")
        end
    end
end
if reachability_warning_to_insert ~= nil then
    table.insert(randomization_info.warnings, reachability_warning_to_insert)
end

-- Add warnings for control stage
if not offline then
    log("Smuggling control info")

    local warnings_selection_tool = table.deepcopy(data.raw.blueprint.blueprint)
    warnings_selection_tool.type = "selection-tool"
    warnings_selection_tool.name = "propertyrandomizer-warnings"
    warnings_selection_tool.select.entity_type_filters = {serpent.dump(randomization_info.warnings)}
    data:extend({
        warnings_selection_tool
    })
end

log("Done!")]=]