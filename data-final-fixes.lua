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
    },
}

-- Initial reformats to smooth along everything else
local reformat = require("lib/reformat")
reformat.initial()

old_data_raw = table.deepcopy(data.raw)

log("Gathering config")

-- Find randomizations to perform
-- Must be loaded first because it also loads settings
require("config")

-- Special changes for watch the world burn mode
if config.watch_the_world_burn then
    require("watch-the-world-burn")
end

-- Duplicates (if applicable)

if config.dupes then
    log("Adding duplicates")

    local dupe = require("lib/dupe")

    --dupe.execute()
    --dupe.execute_vanilla()
end

post_dupe_data_raw = table.deepcopy(data.raw)

-- Special prototype fixes
require("randomizations/prefixes")

log("Loading in new dependency graph file")

local new_logic = require("new-lib/logic/init")
local unified = require("randomizations/graph/unified/execute-new")

-- Load compat code
require("compat/master")

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
    data:extend({
        warnings_selection_tool,
        graph_selection_tool,
        logic_selection_tool,
    })
end

smuggle_info()
do return end

-- If unit testing is on, do only those
if config.unit_test then
    require("tests/execute")
    smuggle_info()
    return
end

----------------------------------------------------------------------
-- Setup done!
----------------------------------------------------------------------

-- Do unified randomizations first

for i = 1, config.unified_num_retries do
    if not unified.execute() then
        data.raw = table.deepcopy(post_dupe_data_raw)
        if i == config.unified_num_retries then
            error("Unified randomization failed. Perhaps try a new seed?")
        end
    else
        break
    end
end

--[=[

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

if config.simultaneous then
    -- Include these to toggle individual randomizers
    --require("randomizations/graph/core/randomizers/burnt-result-source")
    --require("randomizations/graph/core/randomizers/recipe-ingredients")
    --require("randomizations/graph/core/randomizers/technology-ingredients")
    --require("randomizations/graph/core/randomizers/technology-prerequisites")
    --randomizations.graph("graph")

    -- Rebuild graph
    build_graph.load()
    dep_graph = build_graph.graph
    build_graph_compat.load(dep_graph)
    build_graph.add_dependents(dep_graph)
end

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
    -- Rebuild graph
    build_graph.load()
    dep_graph = build_graph.graph
    build_graph_compat.load(dep_graph)
    build_graph.add_dependents(dep_graph)
end

if config.recipe_tech_unlock then
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

local final_sort_info = top_sort.sort(dep_graph)

--[[for _, node in pairs(final_sort_info.sorted) do
    log(build_graph.key(node.type, node.name))
end]]

local reachability_warning_to_insert
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
end]=]

for _, tech in pairs(data.raw.technology) do
    if tech.unit ~= nil then
        tech.unit.ingredients = {}
    end
    local new_effects = {}
    if tech.effects ~= nil then
        for _, effect in pairs(tech.effects) do
            if not (effect.recipe ~= nil and string.find(effect.recipe, "science-pack") ~= nil) then
                table.insert(new_effects, effect)
            end
        end
    end
    tech.effects = new_effects
end
for _, tool in pairs(data.raw.tool) do
    tool.hidden = true
    tool.hidden_in_factoriopedia = true
end
for _, recipe in pairs(data.raw.recipe) do
    if string.find(recipe.name, "science-pack") ~= nil then
        recipe.hidden = true
        recipe.hidden_in_factoriopedia = true
    end
end

TECH_TO_REACHABLE_NAME = {}
local consistent_sort = require("new-lib/graph/consistent-sort")
new_logic.build(true)
local graph = table.deepcopy(new_logic.graph)
local init_sort = consistent_sort.sort(graph)
local gutils = require("new-lib/graph/graph-utils")
local total_techs = 1
for _, technology in pairs(data.raw.technology) do
    total_techs = total_techs + 1
end
local techs_done = 1
for _, tech in pairs(data.raw.technology) do
    local is_okay = {}
    --[[local queue = {tech.name}
    local ind = 1
    while true do
        if ind <= #queue then
            local curr = queue[ind]
            local curr_tech = data.raw.technology[curr]
            if curr_tech.prerequisites ~= nil then
                for _, prereq in pairs(curr_tech.prerequisites) do
                    if not is_okay[prereq] then
                        table.insert(queue, prereq)
                        is_okay[prereq] = true
                    end
                end
            end
        else
            break
        end
        ind = ind + 1
    end]]
    local goal_inds = {}
    for ind, pebble in pairs(init_sort.sorted) do
        local node_key = pebble.node_key
        local node = graph.nodes[node_key]
        if node.type == "technology" and node.name == tech.name then
            table.insert(goal_inds, ind)
        end
    end
    local short_path = consistent_sort.path(graph, goal_inds, init_sort)
    for ind = 1, #init_sort.sorted do
        local pebble = init_sort.sorted[ind]
        local node_key = pebble.node_key
        local node = graph.nodes[node_key]
        if node.type == "technology" and short_path.in_path[ind] then
            is_okay[node.name] = true
        end
    end
    log(serpent.block(is_okay))
    local reachable_in_order = {}
    for ind = 1, #init_sort.sorted do
        local pebble = init_sort.sorted[ind]
        local node_key = pebble.node_key
        local node = graph.nodes[node_key]
        if (node.type == "item" or node.type == "fluid") and node.name ~= "water" and node.name ~= "steam" then
            local is_reachable = false
            for _, tech2 in pairs(data.raw.technology) do
                if is_okay[tech2.name] then
                    if tech2.effects ~= nil then
                        for _, effect in pairs(tech2.effects) do
                            if effect.type == "unlock-recipe" then
                                local recipe = data.raw.recipe[effect.recipe]
                                if recipe.results ~= nil then
                                    for _, result in pairs(recipe.results) do
                                        if result.name == node.name then
                                            is_reachable = true
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if is_reachable then
                table.insert(reachable_in_order, node.name)
            end
        end
    end
    TECH_TO_REACHABLE_NAME[tech.name] = {}
    for i = math.max(1, math.floor(#reachable_in_order / 2)), #reachable_in_order do
        TECH_TO_REACHABLE_NAME[tech.name][reachable_in_order[i]] = false
    end
    TECH_TO_REACHABLE_NAME[tech.name][#reachable_in_order] = true
    log(tostring(math.floor(100 * techs_done / total_techs)) .. "% DONE")
    log(tech.name)
    log(serpent.block(TECH_TO_REACHABLE_NAME[tech.name]))
    techs_done = techs_done + 1
end

-- Add warnings for control stage
if not offline then
    smuggle_info()
end

log("Done!")

-- Set config back to nil so that globals aren't floating around
config = nil