--[[local gutils = require("lib/graph/graph-utils")
local cutils = require("lib/cost/cost-utils")
local flow_amounts_ingredients = {}
local flow_amounts_results = {}
for _, recipe in pairs(data.raw.recipe) do
    local considered = {}
    for _, ingredient in pairs(recipe.ingredients or {}) do
        if not considered[gutils.key(ingredient)] then
            considered[gutils.key(ingredient)] = true
            flow_amounts_ingredients[gutils.key(ingredient)] = flow_amounts_ingredients[gutils.key(ingredient)] or {}
            table.insert(flow_amounts_ingredients[gutils.key(ingredient)], cutils.find_amount_in_ing_or_prod(recipe.ingredients, ingredient))
        end
    end
    considered = {}
    for _, result in pairs(recipe.results or {}) do
        if not considered[gutils.key(result)] then
            considered[gutils.key(result)] = true
            flow_amounts_results[gutils.key(result)] = flow_amounts_results[gutils.key(result)] or {}
            table.insert(flow_amounts_results[gutils.key(result)], cutils.find_amount_in_ing_or_prod(recipe.results, result))
        end
    end
end
log(serpent.block(flow_amounts_ingredients))
log(serpent.block(flow_amounts_results))
do return end]]

--[[local dutils = require("lib/data-utils")
local pipe_conns = require("lib/pipe-conns")
local new_recipes = require("lib/cost/rotated-bases/FINAL_RANDOMIZED_RECIPES_seed202608250324")
local fixed_recipes = {}
for _, machine_class in pairs({"assembling-machine", "furnace", "rocket-silo"}) do
    for _, machine in pairs(data.raw[machine_class]) do
        if machine.fixed_recipe ~= nil then
            fixed_recipes[machine.fixed_recipe] = true
        end
        machine.fluid_boxes = machine.fluid_boxes or {}
        local has_input_already = false
        if machine.type == "furnace" then
            for _, box in pairs(machine.fluid_boxes) do
                if box.production_type == "input" then
                    has_input_already = true
                end
            end
        end
        local available = pipe_conns.get_available_pipe_connections(machine)
        -- Alternately add input and output boxes
        for ind, conn in pairs(available) do
            local input_type = "input"
            if ind % 2 == 0 or (machine.type == "furnace" and has_input_already) then
                input_type = "output"
            else
                has_input_already = true
            end
            conn.flow_direction = input_type
            table.insert(machine.fluid_boxes, {
                volume = 100,
                pipe_connections = { conn },
                production_type = input_type,
                conn,
            })
        end
    end
end
for recipe_name, recipe_data in pairs(new_recipes.recipes) do
    local blacklisted_recipes = {
    }
    if not blacklisted_recipes[recipe_name] and not fixed_recipes[recipe_name] then
        local recipe = data.raw.recipe[recipe_name]
        local cleaned_ings = {}
        local has_fluid = false
        for _, ing in pairs(recipe_data.ingredients) do
            --ing.amount = math.min(65535, math.max(1, math.floor(0.5 + 100 * ing.amount)))
            if ing.type == "item" then
                local item
                for item_class, _ in pairs(defines.prototypes.item) do
                    if (data.raw[item_class] or {})[ing.name] then
                        item = (data.raw[item_class] or {})[ing.name]
                    end
                end
                if not dutils.is_stackable(item) then
                    ing.amount = 1
                end
            else
                has_fluid = true
                if ing.name == "steam" then
                    ing.amount = ing.amount * 1 / 5
                end
            end
            if ing.amount > 0 then
                table.insert(cleaned_ings, ing)
            end
        end
        recipe.ingredients = cleaned_ings
        local cleaned_results = {}
        for _, result in pairs(recipe_data.results) do
            --result.amount = math.min(65535, math.max(1, math.floor(0.5 + 100 * result.amount)))
            if result.type == "item" then
                local item
                for item_class, _ in pairs(defines.prototypes.item) do
                    if (data.raw[item_class] or {})[result.name] then
                        item = (data.raw[item_class] or {})[result.name]
                    end
                end
                if not dutils.is_stackable(item) then
                    result.amount = 1
                end
                if result.amount < 1 then
                    result.independent_probability = result.amount
                    result.amount = 1
                end
            end
            if result.amount > 0 then
                
                table.insert(cleaned_results, result)
            end
        end
        recipe.main_product = nil
        if recipe.results ~= nil and #recipe.results >= 1 then
            local item
            for item_class, _ in pairs(defines.prototypes.item) do
                if (data.raw[item_class] or {})[recipe.results[1].name] then
                    item = (data.raw[item_class] or {})[recipe.results[1].name]
                end
            end
            if recipe.results[1].type == "fluid" then
                item = data.raw.fluid[recipe.results[1].name]
            end
            recipe.icon = recipe.icon or item.icon
            recipe.icon_size = recipe.icon_size or item.icon_size
            recipe.icons = recipe.icons or item.icons
        end
        recipe.results = cleaned_results
        if has_fluid then
            local new_categories = {}
            local added_fluid_with_crafting = false
            for _, cat in pairs(recipe.categories or {"crafting"}) do
                if cat == "crafting" then
                    if not added_fluid_with_crafting then
                        added_fluid_with_crafting = true
                        table.insert(new_categories, "crafting-with-fluid")
                    end
                elseif cat == "crafting-with-fluid" then
                    if not added_fluid_with_crafting then
                        added_fluid_with_crafting = true
                        table.insert(new_categories, cat)
                    end
                else
                    table.insert(new_categories, cat)
                end
            end
            recipe.categories = new_categories
        end
        -- fbreactor
        --recipe.categories = {"fbreactor"}
        recipe.energy_required = (recipe.energy_required or 0.5) * recipe_data.energy_required_multiplier
    end
end

data.raw.recipe["stone-brick"].ingredients[1].name = "iron-ore"
data.raw.recipe["low-grade-smelting-iron"].categories = {"crafting"}
randomizations = {}
require("randomizations/fixes")
randomizations.rebuild_tech_tree()

do return end]]

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
        --gutils.add_edge(logic.graph, gutils.key("false", ""), gutils.key("recipe", science_pack))
        local science_node = logic.graph.nodes[gutils.key("item", science_pack)]
        local edges_to_remove = {}
        for dep, _ in pairs(science_node.dep) do
            table.insert(edges_to_remove, dep)
        end
        for _, dep in pairs(edges_to_remove) do
            local depnode = logic.graph.nodes[logic.graph.edges[dep].stop]
            if depnode.op == "AND" then
                gutils.add_edge(logic.graph, gutils.key("false", ""), gutils.key(depnode.type, depnode.name))
            end
            gutils.remove_edge(logic.graph, dep)
        end
        if packs_in_order[i] == "military-science-pack" then
            -- Also blacklist py2
            local science_node_2 = logic.graph.nodes[gutils.key("item", "py-science-pack-2")]
            local edges_to_remove_2 = {}
            for dep, _ in pairs(science_node_2.dep) do
                table.insert(edges_to_remove_2, dep)
            end
            for _, dep in pairs(edges_to_remove_2) do
                local depnode = logic.graph.nodes[logic.graph.edges[dep].stop]
                if depnode.op == "AND" then
                    gutils.add_edge(logic.graph, gutils.key("false", ""), gutils.key(depnode.type, depnode.name))
                end
                gutils.remove_edge(logic.graph, dep)
            end
        end
    end
    local sort_info = top.sort(logic.graph)
    if i < #packs_in_order then
        -- Find required materials for this science at this level
        local science_ind
        for ind, pebble in pairs(sort_info.sorted) do
            local node = logic.graph.nodes[pebble.node_key]
            if node.type == "item" and node.name == packs_in_order[i] then
                science_ind = ind
                break
            end
        end
        local path = top.path(logic.graph, {science_ind}, sort_info)
        log("PATH DUMP")
        log(serpent.dump(path))
        log("SORT INFO DUMP")
        log(serpent.dump(sort_info))
    else
        local pyrrhic_ind
        for ind, pebble in pairs(sort_info.sorted) do
            local node = logic.graph.nodes[pebble.node_key]
            if node.type == "technology" and node.name == "pyrrhic" then
                pyrrhic_ind = ind
                break
            end
        end
        local path = top.path(logic.graph, {pyrrhic_ind}, sort_info)
        log("PATH DUMP")
        log(serpent.dump(path))
        log("SORT INFO DUMP")
        log(serpent.dump(sort_info))
    end
    --cost.export_to_log(sort_info, i)
end
log("GRAPH DUMP")
log(serpent.dump(logic.graph))
log("__DATA_RAW_BEGIN__\n" .. serpent.dump(data.raw) .. "\n__DATA_RAW_END__")
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
local unified = require("randomizations/graph/unified/execute-new")

log("Initial reachability check")

local gutils = require("lib/graph/graph-utils")
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
        }
    }
})

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