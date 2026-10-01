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

-- Random planet names (lib/planet-names.lua), before the duplicates and planetary changes, so what they name after a planet takes its new name
local planet_names = require("lib/planet-names")
if config.planet_names then
    planet_names.execute()
end

-- Duplicates of the planets, entities and items with recolored graphics (lib/dupe-planets.lua, lib/dupe.lua), before anything reads the prototypes, so they get randomized like everything else
-- Then each planet-locked duplicate goes to its own copy of the planets, and the original to the original planets (lib/dupe-planet-locks.lua)
local dupe = require("lib/dupe")
local dupe_planets = require("lib/dupe-planets")
local dupe_planet_locks = require("lib/dupe-planet-locks")
if config.dupes then
    log("Adding duplicates")
    dupe_planets.execute()
    dupe.execute()
    dupe_planet_locks.execute()
end

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

local release_isolation
if mods["propertyrandomizer-test-helper"] then
    release_isolation = require("__propertyrandomizer-test-helper__/release-isolation")
end
if release_isolation ~= nil then
    release_isolation.capture()
end

-- Special prototype fixes
require("randomizations/prefixes")
if release_isolation ~= nil then
    release_isolation.check_prefixes()
end

local planetary = require("randomizations/planetary/execute")
local transport = require("randomizations/planetary/transport")
local fix_pass = require("randomizations/planetary/fix-pass")
local recycling = require("lib/recycling")

-- The game before any planetary change, for rolling the changes again for another attempt of the rest of randomization (superposed mode, see the unified loop below)
local pre_planetary_raw = nil
if config.planetary then
    pre_planetary_raw = table.deepcopy(data.raw)
end
-- Planetary randomization goes first, so the rest of randomization and its checks treat the changed world as the starting point
-- Recycling recipes follow the recipes the changes made or edited (a reward's planet variant, lib/recycling.lua), so the rest of randomization models what the recycler would generate from the changed game rather than what it generated before
if config.planetary then
    planetary.execute(new_logic)
    recycling.regenerate(pre_planetary_raw)
end

old_data_raw = table.deepcopy(data.raw)

log("Loading in new dependency graph file")

local unified = require("randomizations/graph/unified/execute")
-- Loaded with unified randomization (its recipe-ingredients handler prices with the old logic)
local old_build_graph = require("lib/old-logic/build-graph")

-- The planetary fix pass (config.planetary_fix_pass, a work in progress): the planetary stages waited for unified's handlers, which the fix pass repairs with (randomizations/planetary/fix-pass.lua)
-- They run now, one at a time, each repaired by the fix pass first and the old way if that isn't enough (run_fix_first in randomizations/planetary/execute.lua)
if planetary.pending ~= nil then
    planetary.run_pending(function(state)
        return #fix_pass.run({
            logic = new_logic,
            unified = unified,
            before = state.before,
            variants_of = state.variants_of,
            replacements = planetary.replacements,
        })
    end)
    -- The rest of randomization starts from the changed game: recycling follows its recipes, the old logic reads the planets again (it loaded before the stages ran), and unified keeps what this game can do
    recycling.regenerate(pre_planetary_raw)
    old_build_graph.read_surfaces()
    old_data_raw = table.deepcopy(data.raw)
end

log("Initial reachability check")

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local graph_cost = require("lib/cost/graph-cost")
local init_sort_info
-- With room/ability contexts (isolatability, automatability), for the mechanic context check at the end
local init_complex_sort_info
-- Sorts the world the rest of randomization starts from (the game after planetary changes, which is data.raw now) and derives what depends on it
local function prepare_world()
    new_logic.build(true)
    -- Home sets come from the game before randomization and stay fixed, so every later sort with home contexts (the discovery rule in promotion, first pass and the checks) uses these
    -- With planetary changes in the game, they're the ones planetary's goals were made with
    local planetary_home_sets = config.planetary and planetary.home_sets()
    new_logic.home_sets = planetary_home_sets or top.home_sets(new_logic.graph)
    init_sort_info = top.sort(new_logic.graph)
    init_complex_sort_info = top.sort(new_logic.graph, nil, nil, {
        complex_contexts = true,
        home_contexts = true,
    })
    -- Raw material costs and the major resources for recipe costs come from the logic graph's cost model, in the world planetary changes made
    graph_cost.derive_cost_options(new_logic.graph, init_sort_info, gutils.key("planet", constants.starting_planet), init_complex_sort_info, new_logic.contexts)
end
prepare_world()

----------------------------------------------------------------------
-- Setup done!
----------------------------------------------------------------------

-- Do unified randomizations first (skipped when no handler is on, see config.dev_unified)

local unified_check = require("randomizations/graph/unified/skeleton/check")
-- How many times planetary changes in superposed mode are rolled again for a failed attempt before they're undone instead (see below)
local PLANETARY_REROLLS = 2
local num_planetary_rerolls = 0
-- Outside superposed mode, how many attempts that lose only what planetary changes kept (PLANETCHECK attempt) are retried before one is kept anyway, for the final check to warn about; each retry costs a whole attempt
local PLANETARY_LOSS_RETRIES = 2
local num_planetary_loss_retries = 0
-- How many times the planet goals an attempt lost get the items they need made shippable and are checked again (randomizations/planetary/transport.lua); each time costs a sort, where a retry costs a whole attempt
local SHIP_ROUNDS = 3
-- Makes shippable the items that planet goals an attempt lost need only from another planet, and checks the attempt again
-- Returns how many goals are still lost
local function ship_for_goals(num_lost, failures, sort_info)
    for _ = 1, SHIP_ROUNDS do
        local blockers = transport.blockers(new_logic.graph, sort_info, failures, transport.unshippable_in(new_logic.graph))
        if #blockers == 0 then
            return num_lost
        end
        local lines = transport.apply(blockers, function(item_name)
            return lookups.weight[item_name]
        end)
        log("Planetary transport: " .. num_lost .. " planet goals lost need items that can't travel to their planet, made shippable: " .. table.concat(lines, ", "))
        new_logic.build(true)
        local resorted = top.sort(new_logic.graph, nil, nil, {
            complex_contexts = true,
            home_contexts = true,
        })
        num_lost, failures, sort_info = planetary.check_attempt(new_logic.graph, resorted)
        if num_lost == 0 then
            return 0
        end
    end
    return num_lost
end
for i = 1, (unified.has_handlers and config.unified_num_retries) or 0 do
    unified_info = unified.execute()
    if unified_info then
        -- Recycling recipes follow the recipes unified randomization changed, as the recycler would have generated them (lib/recycling.lua), so the check sees the game players get
        recycling.regenerate(old_data_raw)
        -- Planetary changes in superposed mode: the attempt settles what it still owes them (randomizations/planetary/execute.lua), and one that leaves goals owed fails like one that fails the check below
        local num_owed = 0
        if config.planetary then
            num_owed = planetary.settle(new_logic)
        end
        -- Unified randomization's model can be wrong about the game it builds, so check the game itself (logic rebuilt from it) against the original
        -- An attempt that lost something a player needs fails like any other, so it's retried or errors instead of loading as a softlock
        new_logic.build(true)
        local attempt_sort_info = top.sort(new_logic.graph, nil, nil, {
            complex_contexts = true,
            home_contexts = true,
        })
        local verdict = unified_check.run(new_logic.graph, init_complex_sort_info, attempt_sort_info, "UNIFIEDCHECK")
        -- Outside superposed mode the planetary stages repaired their changes before unified randomization ran, so an attempt that loses what they kept is retried too, up to PLANETARY_LOSS_RETRIES times
        local num_lost_planetary = 0
        if config.planetary then
            local lost_goals
            local check_sort_info
            num_lost_planetary, lost_goals, check_sort_info = planetary.check_attempt(new_logic.graph, attempt_sort_info)
            -- Goals lost only because an item can't travel to their planet are kept by making it shippable, instead of retrying the whole attempt (user, 2026-09-30)
            if verdict.ok and num_lost_planetary > 0 then
                num_lost_planetary = ship_for_goals(num_lost_planetary, lost_goals, check_sort_info)
            end
        end
        -- The last attempt is kept even then, since a startup error would make the player reset their settings; the final check below warns them instead
        local problem = nil
        if not verdict.ok then
            problem = "loses what the original had (see the UNIFIEDCHECK lines)"
        elseif num_owed > 0 then
            problem = "still owes planetary changes " .. num_owed .. " goals (see the Planetary settlement lines)"
        elseif num_lost_planetary > 0 and num_planetary_loss_retries < PLANETARY_LOSS_RETRIES then
            num_planetary_loss_retries = num_planetary_loss_retries + 1
            problem = "loses " .. num_lost_planetary .. " things planets could do after planetary changes (see the PLANETCHECK attempt lines)"
        elseif num_lost_planetary > 0 then
            log("Unified randomization attempt " .. i .. " built a game that loses " .. num_lost_planetary .. " things planets could do after planetary changes (see the PLANETCHECK attempt lines), and it's kept after " .. PLANETARY_LOSS_RETRIES .. " retries for that; the final check warns about it")
        end
        if problem ~= nil and i < config.unified_num_retries then
            log("Unified randomization attempt " .. i .. " built a game that " .. problem .. ", so it's retried")
            unified_info = false
        elseif problem ~= nil then
            log("Unified randomization's last attempt built a game that " .. problem .. ", and it's kept")
        end
    end
    if not unified_info then
        -- The next attempt rebuilds logic from this (see unified.execute), and none of this attempt's items stay shippable
        data.raw = table.deepcopy(old_data_raw)
        transport.applied = {}
        if i == config.unified_num_retries then
            error("Unified randomization failed. Perhaps try a new seed?")
        end
        -- In superposed mode the planetary changes are rolled again for the next attempt, since this roll may have no fix for what the attempt owed (what ocean swaps owe has none)
        -- After PLANETARY_REROLLS rolls they're undone instead, with a warning in the randomizer panel, so a seed is never worse off with them than without
        if planetary.superposed ~= nil then
            data.raw = table.deepcopy(pre_planetary_raw)
            if num_planetary_rerolls < PLANETARY_REROLLS then
                num_planetary_rerolls = num_planetary_rerolls + 1
                planetary.reroll(new_logic)
            else
                planetary.undo(i)
            end
            recycling.regenerate(pre_planetary_raw)
            old_data_raw = table.deepcopy(data.raw)
            prepare_world()
        end
    else
        break
    end
end

-- Do old data raw for derandomization here so that necessary graph randomization tweaks stay
old_data_raw_for_derandomization = table.deepcopy(data.raw)

-- NOTE: When adding a dependency graph randomization, add it to constants.lua!

log("Building dependency graph (if applicable)")

-- Load in dependency graph
local build_graph
local build_graph_compat
build_graph = require("lib/old-logic/build-graph")
-- The old graph was first built when its file was required, before unified randomization and any planetary reroll (which draws new space connections, among other things); the custom nodes below look prototypes up by their current names in it, so it's built again from the game as it is now
build_graph.load()
-- Make dependency graph global
dep_graph = build_graph.graph

-- Add custom nodes
log("Adding custom nodes")
build_graph_compat = require("lib/old-logic/build-graph-compat")

-- Build dependents
log("Adding dependents")
build_graph.add_dependents(dep_graph)

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

-- Old item randomization is only held to the old logic for now (the oldlogic line in tests/configs.txt), so with it on, the old logic checks the built game too (OLDLOGICCHECK below)
-- Its science packs before graph randomization are the baseline; balance rules (build-graph-compat.lua) are soft, so they're left out of both sorts
local top_sort = require("lib/old-logic/top-sort")
local function old_logic_science_packs()
    build_graph.load()
    build_graph.add_dependents(build_graph.graph)
    local reachable = top_sort.sort(build_graph.graph).reachable
    local packs = {}
    for _, lab in pairs(data.raw.lab) do
        for _, input in pairs(lab.inputs) do
            if reachable[build_graph.key("item", input)] ~= nil then
                packs[input] = true
            end
        end
    end
    return packs
end
local old_logic_packs_before
if config.graph.item then
    old_logic_packs_before = old_logic_science_packs()
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

local resource_report = require("lib/cost/resource-report")
local flow_cost = require("lib/cost/flow-cost")
local science_costs
if mods["propertyrandomizer-test-helper"] then
    science_costs = require("__propertyrandomizer-test-helper__/science-costs")
end

if config.graph.recipe then
    log("Applying recipe ingredients randomization")

    resource_report.run("before")
    if science_costs ~= nil then
        science_costs.capture("before", flow_cost, constants.cost_params)
    end
    randomizations.recipe_ingredients("recipe_ingredients")
    -- Fix recycling recipes first so that dependency graph is an accurate reflection of reality
    randomizations.fix_recycling_recipes()
    resource_report.run("after")
    if science_costs ~= nil then
        science_costs.capture("after", flow_cost, constants.cost_params)
    end
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

-- Items made shippable for planet goals stay so, though later randomization changed weights and spoil times again (randomizations/planetary/transport.lua)
local num_reshipped = transport.reapply()
if num_reshipped > 0 then
    log("Planetary transport: " .. num_reshipped .. " items made shippable again after later randomization")
end

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
local final_check_ok = unified_check.run(new_logic.graph, init_complex_sort_info, final_complex_sort_info).ok
-- The old logic's check of the built game, with old item randomization on (see old_logic_packs_before)
if old_logic_packs_before ~= nil then
    local packs_after = old_logic_science_packs()
    local num_kept = 0
    local num_total = 0
    local lost_packs = {}
    for pack, _ in pairs(old_logic_packs_before) do
        num_total = num_total + 1
        if packs_after[pack] ~= nil then
            num_kept = num_kept + 1
        else
            table.insert(lost_packs, pack)
        end
    end
    table.sort(lost_packs)
    log("OLDLOGICCHECK science packs reachable " .. num_kept .. " of " .. num_total .. (#lost_packs > 0 and ("; lost " .. table.concat(lost_packs, ", ")) or ""))
end
-- What planetary changes kept, checked against the game before them (PLANETCHECK final): what's still lost fails the check like a lost mechanic context, and the randomizer panel says so
if config.planetary and not planetary.check_final(new_logic.graph) then
    final_check_ok = false
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
-- The result summary at the end only counts what add_old_versions makes (lib/result-summary.lua)
local result_summary = require("lib/result-summary")
local names_before_old_versions = result_summary.prototype_names(data.raw)
randomizations.add_old_versions()
randomizations.post_fixes()

if release_isolation ~= nil then
    release_isolation.check_prerequisites()
end

-- Strings that named a planet by its locale key get its new name (lib/planet-names.lua)
if config.planet_names then
    planet_names.fix_references()
end

-- Every planet but the starting one gets a random tint, wherever its images show (lib/planet-tints.lua)
local planet_tints = require("lib/planet-tints")
if config.planet_tints then
    planet_tints.execute()
end

-- What the randomization did, in the log as RESULT lines (lib/result-summary.lua): how the finished game differs from the one before any randomization
log("Logging what the randomization did")
result_summary.log(pre_planetary_raw or old_data_raw, data.raw, {
    prototypes = result_summary.added_since(names_before_old_versions, data.raw),
    what = "the (Original!) and (Free!) copies add_old_versions makes",
})
log("Done logging what the randomization did")

-- Add warnings for control stage
smuggle_info()

log("Done!")

-- Set config back to nil so that globals aren't floating around
config = nil
