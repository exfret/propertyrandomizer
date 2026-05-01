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
-- CRITICAL TODO: Uncomment!
--[[if config.duplicate_recipe_tech_unlocks then
    local dupe = require("lib/dupe")
    dupe.recipe_tech_unlocks()
end]]

-- Special prototype fixes
require("randomizations/prefixes")

log("Loading in new dependency graph file")

local new_logic = require("new-lib/logic/init")
local unified = require("randomizations/graph/unified/execute-new")

-- Load compat code
require("compat/master")

local function smuggle_info()
    log("Smuggling control info")

    new_logic.build()

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

--[[for i = 1, config.unified_num_retries do
    if not unified.execute() then
        data.raw = table.deepcopy(old_data_raw)
        if i == config.unified_num_retries then
            error("Unified randomization failed. Perhaps try a new seed?")
        end
    else
        break
    end
end]]




-- Actually, need to do this differently
--local dupe = require("lib/dupe")
-- Make the nauvis copies now
-- We'll technically have access to multiple nauvis's while randomizing then, but I can't imagine this changing anything if they all have the same resources etc.
local num_copies = 3
local locale_utils = require("lib/locale")
for i = 1, num_copies do
    local nauvis_copy = table.deepcopy(data.raw.planet.nauvis)
    local suffix = "-exfret-" .. i .. "-copy"
    nauvis_copy.localised_name = {"", locale_utils.find_localised_name(nauvis_copy), " #" .. tostring(i)}
    nauvis_copy.orig_name = nauvis_copy.name
    nauvis_copy.suffix = suffix
    nauvis_copy.name = nauvis_copy.name .. suffix
    nauvis_copy.map_seed_offset = 100 * i
    data:extend({
        nauvis_copy
    })
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






local dupe_number_to_filename = {
    "number_one.png",
    "number_two.png",
    "number_three.png",
    "number_four.png",
    "number_five.png",
    "number_six.png",
    "number_seven.png",
    "number_eight.png",
    "number_nine.png",
}
-- Put -#'s at the end of techs at the beginning
-- Technically assumes that there will not be a -# afterward, but the failure case tech names like just "-3" or "research-2-3" seem pretty silly
local function strip_numeric_suffix(tech_name)
    local base, num = string.match(tech_name, "^([%w_%-]+)%-(%d+)$")
    return base or tech_name, num or ""
end
for _, tech in pairs(data.raw.technology) do
    local base, num = strip_numeric_suffix(tech.name)
    local old_name = tech.name
    if num ~= "" then
        tech.name = num .. "-" .. base
    end
    tech.localised_name = locale_utils.find_localised_name(data.raw.technology[base] or data.raw.technology[base .. "-1"] or data.raw.technology["1-" .. base])
    -- Fix prerequisites
    -- There are other things that reference tech ID's, but none of them are really important or applicable to upgrade techs
    for _, other_tech in pairs(data.raw.technology) do
        if other_tech.prerequisites ~= nil then
            local new_prereqs = {}
            for _, prereq in pairs(other_tech.prerequisites) do
                if prereq == old_name then
                    table.insert(new_prereqs, tech.name)
                else
                    table.insert(new_prereqs, prereq)
                end
            end
            other_tech.prerequisites = new_prereqs
        end
    end
    -- Also set upgrade to false because it's silly
    tech.upgrade = false
    data.raw.technology[old_name] = nil
    data.raw.technology[tech.name] = tech
end
-- Need to keep track of these changes!
local less_old_data_raw = table.deepcopy(data.raw)
local data_raw_copies = {}
for i = 1, num_copies do
    config.seed = config.seed + 1
    
    -- Rebuild graph
    build_graph.load()
    dep_graph = build_graph.graph
    build_graph_compat.load(dep_graph)
    build_graph.add_dependents(dep_graph)
    randomizations.recipe_ingredients("recipe_ingredients")

    build_graph.load()
    dep_graph = build_graph.graph
    build_graph_compat.load(dep_graph)
    build_graph.add_dependents(dep_graph)
    randomizations.item_new("item-new")



    log(serpent.block(data.raw.resource["iron-ore"]))




    table.insert(data_raw_copies, table.deepcopy(data.raw))
    --data.raw = table.deepcopy(less_old_data_raw)
    -- Redo data.raw at prototype property level since old logic is badly coded and maintains stale references to a lot of things
    for _, class in pairs(data.raw) do
        for _, prot in pairs(class) do
            for k, v in pairs(prot) do
                if k ~= "type" and k ~= "name" then
                    prot[k] = nil
                end
            end
            for k, v in pairs(table.deepcopy(less_old_data_raw[prot.type][prot.name])) do
                prot[k] = v
            end
        end
    end
end
-- Update with new recipes
for i = 1, num_copies do
    for _, recipe in pairs(data_raw_copies[i].recipe) do
        local suffix = "-exfret-" .. i .. "-copy"
        recipe.localised_name = locale_utils.find_localised_name(recipe)
        recipe.orig_name = recipe.name
        recipe.suffix = suffix
        recipe.name = recipe.name .. suffix
        -- Can't do this or the randomizer will think it's genuinely hidden
        --recipe.enabled = false
        -- Also need to do icon
        local recipe_icons
        if recipe.icons == nil and recipe.icon == nil then
            local item_with_icon_name
            if recipe.main_product ~= nil then
                item_with_icon_name = recipe.main_product
            else
                item_with_icon_name = recipe.results[1].name
            end
            local item_with_icon
            for item_class, _ in pairs(defines.prototypes.item) do
                if data_raw_copies[i][item_class] ~= nil then
                    if data_raw_copies[i][item_class][item_with_icon_name] ~= nil then
                        item_with_icon = data_raw_copies[i][item_class][item_with_icon_name]
                    end
                end
            end
            if data_raw_copies[i].fluid[item_with_icon_name] ~= nil then
                item_with_icon = data_raw_copies[i].fluid[item_with_icon_name]
            end
            if item_with_icon.icons ~= nil then
                recipe_icons = item_with_icon.icons
            else
                recipe_icons = {
                    {
                        icon = item_with_icon.icon,
                        icon_size = item_with_icon.icon_size or 64
                    }
                }
            end
        elseif recipe.icons == nil then
            recipe_icons = {
                {
                    icon = recipe.icon,
                    icon_size = recipe.icon_size or 64
                }
            }
        else
            recipe_icons = recipe.icons
        end
        recipe.icons = recipe_icons
        table.insert(recipe.icons, {
            icon = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[i],
            icon_size = 120,
            scale = 1 / 6,
            shift = {7, -7}
        })
        data:extend({
            recipe
        })
    end

    local change_control = {}
    local change_entity = {}
    -- Whether entity appears should be toggleable in the planet's autoplace settings/controls
    -- All these entities can't actually be transferred between planets (except tree in space age), so having them be different shouldn't be confusing/require graphics differentiations
    for _, minable_class in pairs({"resource", "simple-entity", "tree", "unit", "unit-spawner", "fish"}) do
        for _, entity in pairs(data_raw_copies[i][minable_class]) do
            local suffix = "-exfret-" .. i .. "-copy"
            entity.localised_name = locale_utils.find_localised_name(entity)
            entity.orig_name = entity.name
            entity.suffix = suffix
            entity.name = entity.name .. suffix
            -- Unit spawners do need to be changed to spawn the duplicate units
            if entity.type == "unit-spawner" then
                for _, spawn_def in pairs(entity.result_units) do
                    if spawn_def.unit ~= nil then
                        spawn_def.unit = spawn_def.unit .. suffix
                    else
                        spawn_def[1] = spawn_def[1] .. suffix
                    end
                end
            end
            if entity.autoplace ~= nil or (entity.type == "resource" and data.raw["autoplace-control"][entity.orig_name] ~= nil) then
                change_entity[entity.orig_name] = true
                if entity.autoplace.control ~= nil then
                    change_control[entity.autoplace.control] = true
                    entity.autoplace.control = entity.autoplace.control .. suffix
                end
                if data.raw["autoplace-control"][entity.orig_name] ~= nil then
                    change_control[entity.orig_name] = true
                end
            end

            -- Don't need to update place results or anything because these entities don't have associated items
            -- That wouldn't work anyways since we don't duplicate items
            data:extend({
                entity
            })
        end
    end

    for _, control in pairs(data_raw_copies[i]["autoplace-control"]) do
        if change_control[control.name] then
            local suffix = "-exfret-" .. i .. "-copy"
            control.localised_name = {"", locale_utils.find_localised_name(control), " #" .. tostring(i)}
            control.orig_name = control.name
            control.suffix = suffix
            control.name = control.name .. suffix
            control.order = tostring(i) .. control.order
            data:extend({
                control
            })
        end
    end

    do
        -- Update autoplaces
        local suffix = "-exfret-" .. i .. "-copy"
        local nauvis_copy = data.raw.planet["nauvis" .. suffix]
        local autoplace_controls = nauvis_copy.map_gen_settings.autoplace_controls
        local new_autoplace_controls = {}
        for k, v in pairs(autoplace_controls) do
            if change_control[k] then
                new_autoplace_controls[k .. suffix] = table.deepcopy(v)
            else
                new_autoplace_controls[k] = table.deepcopy(v)
            end
        end
        nauvis_copy.map_gen_settings.autoplace_controls = new_autoplace_controls
        local autoplace_settings = nauvis_copy.map_gen_settings.autoplace_settings.entity.settings
        local new_autoplace_settings = {}
        for k, v in pairs(autoplace_settings) do
            if change_entity[k] then
                new_autoplace_settings[k .. suffix] = table.deepcopy(v)
            else
                new_autoplace_settings[k] = table.deepcopy(v)
            end
        end
        nauvis_copy.map_gen_settings.autoplace_settings.entity.settings = new_autoplace_settings
    end

    -- More items with fuel values (for coal replacement)
    -- This works because adding fuel values doesn't break things, so we can just be liberal about things having those fuel values
    for item_class, _ in pairs(defines.prototypes.item) do
        if data_raw_copies[i][item_class] ~= nil then
            for _, item in pairs(data_raw_copies[i][item_class]) do
                if item.fuel_value ~= nil and util.parse_energy(item.fuel_value) > 0 then
                    local data_raw_item = data.raw[item_class][item.name]
                    if data_raw_item.fuel_value == nil or util.parse_energy(data_raw_item.fuel_value) == 0 then
                        local fuel_properties = {
                            "fuel_value",
                            "fuel_category",
                            "fuel_acceleration_multiplier",
                            "fuel_top_speed_multiplier",
                            "fuel_emissions_multiplier",
                            "fuel_acceleration_multiplier_quality_bonus",
                            "fuel_top_speed_multiplier_quality_bonus",
                        }
                        for _, property in pairs(fuel_properties) do
                            data_raw_item[property] = item[property]
                        end
                    end
                end
            end
        end
    end

    for _, tech in pairs(data_raw_copies[i].technology) do
        local suffix = "-exfret-" .. i .. "-copy"
        tech.localised_name = {"", locale_utils.find_localised_name(tech), " #" .. tostring(i)}
        tech.orig_name = tech.name
        tech.suffix = suffix
        tech.name = tech.name .. suffix
        -- Fix prerequisites
        local new_prereqs = {}
        for _, prereq in pairs(tech.prerequisites or {}) do
            table.insert(new_prereqs, prereq .. suffix)
        end
        tech.prerequisites = new_prereqs
        -- Fix recipe unlocks
        local new_effects = {}
        for _, effect in pairs(tech.effects or {}) do
            if effect.type == "unlock-recipe" then
                table.insert(new_effects, {
                    type = "unlock-recipe",
                    recipe = effect.recipe .. suffix
                })
            else
                table.insert(new_effects, effect)
            end
        end
        tech.effects = new_effects
        -- Trigger effects should already have been fixed during randomization, since they test items rather than recipes
        -- Modify icon
        local tech_icons
        if tech.icons == nil then
            tech_icons = {
                {
                    icon = tech.icon,
                    icon_size = tech.icon_size or 64
                }
            }
        else
            tech_icons = tech.icons
        end
        tech.icons = tech_icons
        table.insert(tech_icons, {
            icon = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[i],
            icon_size = 120,
            scale = 1 / 3,
            shift = {-40, -40}
        })

        data:extend({
            tech
        })
    end

    -- Duplicate rocket silos
    for _, silo in pairs(data_raw_copies[i]["rocket-silo"]) do
        local suffix = "-exfret-" .. i .. "-copy"
        silo.localised_name = {"", locale_utils.find_localised_name(silo), " #" .. tostring(i)}
        silo.orig_name = silo.name
        silo.suffix = suffix
        silo.name = silo.name .. suffix
        silo.minable.result = silo.minable.result .. suffix
        silo.fixed_recipe = silo.fixed_recipe .. suffix
        -- Change graphics
        silo.base_front_sprite = {
            layers = {
                silo.base_front_sprite,
                {
                    filename = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[i],
                    size = 120,
                    scale = 0.6,
                    shift = {-3, -2.2},
                }
            }
        }
        -- TODO: Don't assume it's directly in the item class?
        silo_item = data_raw_copies[i].item[silo.orig_name]
        silo_item.localised_name = {"", locale_utils.find_localised_name(silo_item), " #" .. tostring(i)}
        silo_item.orig_name = silo_item.name
        silo_item.suffix = suffix
        silo_item.name = silo_item.name .. suffix
        silo_item.place_result = silo_item.name
        -- We're relying that the recipe duplication was run first
        for _, recipe in pairs(data.raw.recipe) do
            if recipe.results ~= nil and recipe.results[1] ~= nil and recipe.results[1].name == "rocket-silo" then
                if string.find(recipe.name, suffix) ~= nil then
                        recipe.results[1].name = recipe.results[1].name .. suffix
                    break
                end
            end
        end
        data:extend({
            silo,
            silo_item,
        })
    end
end
-- Remove old techs and recipes by making them hidden
for tech_key, tech in pairs(data.raw.technology) do
    if tech.orig_name == nil then
       tech.hidden = true
    end
end
local lesser_old_data_raw = table.deepcopy(data.raw)
for i = 1, config.unified_num_retries do
    if not unified.execute() then
        data.raw = table.deepcopy(lesser_old_data_raw)
        if i == config.unified_num_retries then
            error("Unified randomization failed. Perhaps try a new seed?")
        end
    else
        break
    end
end

-- We can't reload old logic after doing the duplicates because of bad coding in old logic building
--[[build_graph.load()
dep_graph = build_graph.graph
build_graph_compat.load(dep_graph)
build_graph.add_dependents(dep_graph)
randomizations.item_new("item-new")]]







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

-- CRITICAL TODO: REMOVE!
if config.duplicate_recipe_tech_unlocks then
    local dupe = require("lib/dupe")
    dupe.recipe_tech_unlocks()
end

-- Any fixes needed
randomizations.fixes()
do_overrides_postfixes()

-- Final check for completability

-- Don't do the reachability sort now, we can't do the final graph building
-- I could try with new logic softlock checking, though
--local final_sort_info = top_sort.sort(dep_graph)

--[[for _, node in pairs(final_sort_info.sorted) do
    log(build_graph.key(node.type, node.name))
end]]

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

-- Add warnings for control stage
if not offline then
    smuggle_info()
end

log("Done!")

-- Set config back to nil so that globals aren't floating around
config = nil