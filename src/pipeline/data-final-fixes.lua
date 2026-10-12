-- The garbage collector's step multiplier is how much collection work Lua does for each byte allocated (Lua 5.2 manual 2.5), and Factorio's data stage starts at Lua's default of 200 (logged by a probe, 2026-10-09).
-- At 200 the collector falls behind the randomizer's allocation inside long steps like first pass and shuffle, so garbage piles up between its rounds.
-- At 1000 a 2-dupes load of the user's settings peaked at 6.2 GB instead of 9.0 GB, built the same game and wasn't slower (2026-10-09, notes/logs/2026-10-09-memory-profile/stepmul-results.txt).
-- The old value goes back at the end of this file, so mods that load after this one get the collector as they found it.
local GC_STEPMUL = 1000
local previous_gc_stepmul = collectgarbage("setstepmul", GC_STEPMUL)

DO_FRODO_FIXES = false

local constants = require("src/config/constants")
local natural_lightning = require("src/prototypes/entities/natural-lightning-attractors")
local claim_tool = require("src/prototypes/entities/claim-tool")
local ctx = require("src/logic/contexts/contexts")

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
local handler_ids = require("src/config/handler-ids")
for _, id in pairs(handler_ids) do
    randomization_info.options.unified[id] = {
        blacklisted_pre = {},
        blacklisted_dep = {},
    }
end

-- Initial reformats to smooth along everything else
local reformat = require("src/pipeline/reformat")
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
require("src/config/init")

-- Load compat code
require("src/compat/master")

-- Random planet names (src/randomizations/planetary/planet-names.lua), before the duplicates and planetary changes, so what they name after a planet takes its new name
local planet_names = require("src/randomizations/planetary/planet-names")
if config.planet_names then
    planet_names.execute()
end

-- Duplicates of the planets, entities and items with recolored graphics (src/prototypes/duplicates/dupe-planets.lua, src/prototypes/duplicates/dupe.lua), before anything reads the prototypes, so they get randomized like everything else
-- Shared intermediates get local recipe variants before other planet-locked duplicates receive their home locks (src/prototypes/duplicates/dupe-planet-locks.lua).
local dupe = require("src/prototypes/duplicates/dupe")
local dupe_planets = require("src/prototypes/duplicates/dupe-planets")
local dupe_planet_locks = require("src/prototypes/duplicates/dupe-planet-locks")
local dupe_intermediates = require("src/prototypes/duplicates/dupe-intermediates")
if config.dupes then
    log("Adding duplicates")
    dupe_planets.execute()
    dupe.execute()
    dupe_intermediates.execute()
    dupe_planet_locks.execute()
end

-- Natural ruins belong to the environment, including when enemies share their planet.
natural_lightning.prepare(data.raw, defines.prototypes.item)
claim_tool.prepare(data.raw, defines.prototypes.entity)

-- Freeze the original appearance donors after planet copies exist, before gameplay randomization edits them.
local biomes = require("src/randomizations/planetary/biomes")
if config.planetary_biomes == true then
    biomes.capture()
end

local new_logic = require("src/logic/init")
local combat_encounters = require("src/logic/builders/combat-encounters")

local graph_customization = require("src/config/graph-customization")
local prototype_exclusions = require("src/config/prototype-exclusions")
local randomization_spec = require("src/config/spec")
local landing_lightning = require("src/runtime/landing-lightning")
local unified_info
local function smuggle_info()
    log("Smuggling control info")
    claim_tool.prepare(data.raw, defines.prototypes.entity)
    data:extend({
        {
            type = "mod-data",
            name = "propertyrandomizer-customizer-catalog",
            data = {entries = graph_customization.catalog(old_data_raw or data.raw, defines.prototypes)},
        },
        {
            type = "mod-data",
            name = "propertyrandomizer-landing-lightning",
            data = landing_lightning.catalog(data.raw, defines.prototypes.item),
        },
        {
            type = "mod-data",
            name = "propertyrandomizer-natural-lightning-attractors",
            data = {names = natural_lightning.prepare(data.raw, defines.prototypes.item)},
        },
    })

    new_logic.build()
    -- Context numbers, so the control stage's are the same (src/logic/contexts/contexts.lua)
    ctx.number_rooms(new_logic.contexts)
    data:extend({
        {
            type = "mod-data",
            name = "propertyrandomizer-contexts",
            data = ctx.export_rooms(),
        },
    })

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
    if type(unified_info) == "table" and unified_info.slot_to_trav ~= nil then
        slot_to_trav_selection_tool.select.entity_type_filters = {serpent.dump(unified_info.slot_to_trav)}
    else
        slot_to_trav_selection_tool.select.entity_type_filters = {}
    end
    data:extend({
        warnings_selection_tool,
        graph_selection_tool,
        logic_selection_tool,
        slot_to_trav_selection_tool,
    })
    claim_tool.add_prototypes()
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
require("src/randomizations/prefixes")
if release_isolation ~= nil then
    release_isolation.check_prefixes()
end

local planetary = require("src/randomizations/planetary/execute")
local transport = require("src/randomizations/planetary/transport")
local fix_pass = require("src/randomizations/planetary/fix-pass")
local recycling = require("src/prototypes/recipes/recycling")
local mining_fluids = require("src/prototypes/entities/mining-fluids")

-- With the unified randomizations in development, the mining fluid randomization chooses which resources need a fluid, so none needs one before it (src/prototypes/entities/mining-fluids.lua, user 2026-10-09): planetary changes and independent deposits then never depend on a vanilla mining fluid they can't keep
if config.dev_unified then
    local stripped = mining_fluids.strip(data.raw.resource)
    if #stripped > 0 then
        log("Mining fluids: no resource needs one until the mining fluid randomization chooses them; needed before: " .. table.concat(stripped, ", "))
    end
end

-- The game before planetary changes, for recycling regeneration and the result summary
local pre_planetary_raw = nil
if config.planetary then
    pre_planetary_raw = table.deepcopy(data.raw)
end
-- Planetary randomization goes first, so the rest of randomization and its checks treat the changed world as the starting point
-- Recycling recipes follow the recipes the changes made or edited (a reward's planet variant, src/prototypes/recipes/recycling.lua), so the rest of randomization models what the recycler would generate from the changed game rather than what it generated before
if config.planetary then
    planetary.execute(new_logic)
    recycling.regenerate(pre_planetary_raw)
end

old_data_raw = table.deepcopy(data.raw)

log("Loading in new dependency graph file")

local unified = require("src/randomizations/unified/execute")
-- Loaded with unified randomization (its recipe-ingredients handler prices with the old logic)
local old_build_graph = require("src/legacy/logic/build-graph")

-- Planetary stages waited for unified's prerequisite chooser.
-- Specialized repairs run first; only remaining failures need extra prerequisite choices, still before unified first pass.
if planetary.pending ~= nil then
    planetary.run_pending(function(state)
        local failures, after = fix_pass.run({
            logic = new_logic,
            unified = unified,
            before = state.before,
            variants_of = state.variants_of,
            after = state.after,
        })
        return #failures, after
    end)
    -- The rest of randomization starts from the changed game: recycling follows its recipes, the old logic reads the planets again (it loaded before the stages ran), and unified keeps what this game can do
    recycling.regenerate(pre_planetary_raw)
    old_build_graph.read_surfaces()
    old_data_raw = table.deepcopy(data.raw)
end

-- Independent deposits (src/randomizations/unified/deposit-copies.lua): while unified randomization runs, each planet's deposits mine a copy of their material, and the recipes taking it there take the copy in a version of their own, so item randomization changes them planet by planet
-- After the planetary stages, whose resource placements it splits up, and before the game the rest of randomization starts from is captured
local deposit_copies = require("src/randomizations/unified/deposit-copies")
local recipe_merges = require("src/randomizations/unified/recipe-merges")
local function prepare_deposit_copies()
    if config.deposit_copies ~= true then
        return
    end
    -- Sorted with the home sets the initial check below uses (prepare_world)
    local prepared = deposit_copies.prepare(config.planetary and planetary.home_sets() or nil)
    -- The planetary checks count a recipe's planet versions as the recipe (rules 1 and 2, src/randomizations/planetary/check.lua)
    if planetary.before ~= nil then
        planetary.before.variants_of = planetary.before.variants_of or {}
        for recipe_name, names in pairs(prepared.variants_of) do
            planetary.before.variants_of[recipe_name] = planetary.before.variants_of[recipe_name] or {}
            for _, name in pairs(names) do
                table.insert(planetary.before.variants_of[recipe_name], name)
            end
        end
    end
end
-- Research trigger randomization (src/randomizations/unified/handlers/tech-triggers.lua) gives each technology its own trigger, while the tech tree rebuild gives every recipe its own technology afterwards, copying its technology's trigger onto each (a technology unlocking 25 versions of a recipe made 25 technologies asking for one stone furnace)
-- So with both, a trigger technology unlocking several recipes is split into one technology per recipe first (research_triggers.split_technologies, user 2026-10-08), after deposit copies add their recipe versions
local research_triggers = require("src/prototypes/technology/research-triggers")
local splits_trigger_technologies = config.tech_tree_rebuild == true and unified.randomizes_triggers == true
local function split_trigger_technologies()
    if not splits_trigger_technologies then
        return
    end
    local created = research_triggers.split_technologies(data.raw.technology)
    log("Research triggers: split trigger technologies into " .. #created .. " more, one per recipe")
end
if config.deposit_copies == true or splits_trigger_technologies then
    prepare_deposit_copies()
    split_trigger_technologies()
    old_data_raw = table.deepcopy(data.raw)
end

log("Initial reachability check")

local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
local graph_cost = require("src/cost/graph-cost")
local init_sort_info
-- With room/ability contexts (isolatability, automatability), for the mechanic context check at the end
local init_complex_sort_info
-- Sorts the world the rest of randomization starts from (the game after planetary changes, which is data.raw now) and derives what depends on it
local function prepare_world()
    combat_encounters.reset()
    new_logic.build()
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

local unified_check = require("src/randomizations/unified/skeleton/check")
-- How many attempts that lose only what planetary changes kept (PLANETCHECK attempt) are retried before one is kept anyway, for the final check to warn about; each retry costs a whole attempt
local PLANETARY_LOSS_RETRIES = 2
local num_planetary_loss_retries = 0
-- How many times the planet goals an attempt lost get the items they need made shippable and are checked again (src/randomizations/planetary/transport.lua); each time costs a sort, where a retry costs a whole attempt
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
        new_logic.build()
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
        -- The copies go back to their materials before anything looks at the game the attempt built, so recycling and the checks see the game players get (src/randomizations/unified/deposit-copies.lua)
        if config.deposit_copies == true then
            deposit_copies.collapse(data.raw)
        end
        -- A recipe's per-planet versions that came out taking and making the same things become one recipe (src/randomizations/unified/recipe-merges.lua), before recycling follows the recipes and the checks look at the game
        if config.recipe_merges == true then
            recipe_merges.execute()
        end
        -- Recycling recipes follow the recipes unified randomization changed, as the recycler would have generated them (src/prototypes/recipes/recycling.lua), so the check sees the game players get
        recycling.regenerate(old_data_raw)
        -- Unified randomization's model can be wrong about the game it builds, so check the game itself (logic rebuilt from it) against the original
        -- An attempt that lost something a player needs fails like any other, so it's retried or errors instead of loading as a softlock
        new_logic.build()
        local attempt_sort_info = top.sort(new_logic.graph, nil, nil, {
            complex_contexts = true,
            home_contexts = true,
        })
        local verdict = unified_check.run(new_logic.graph, init_complex_sort_info, attempt_sort_info, "UNIFIEDCHECK")
        -- The planetary stages repaired their changes before unified randomization ran, so an attempt that loses what they kept is retried too, up to PLANETARY_LOSS_RETRIES times
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
    else
        break
    end
end

-- The game every attempt started from loses its copies too, since later stages read it (original versions of recipes, exclusions, the result summary), and so does the game when no attempt ran
if config.deposit_copies == true then
    deposit_copies.collapse(old_data_raw, true)
    deposit_copies.collapse(data.raw, true)
end

-- Do old data raw for derandomization here so that necessary graph randomization tweaks stay
old_data_raw_for_derandomization = table.deepcopy(data.raw)

-- NOTE: When adding a dependency graph randomization, add it to constants.lua!

log("Building dependency graph (if applicable)")

-- Load in dependency graph
local build_graph
local build_graph_compat
build_graph = require("src/legacy/logic/build-graph")
-- The old graph was first built when its file was required, before unified randomization and any planetary reroll (which draws new space connections, among other things); the custom nodes below look prototypes up by their current names in it, so it's built again from the game as it is now
build_graph.load()
-- Make dependency graph global
dep_graph = build_graph.graph

-- Add custom nodes
log("Adding custom nodes")
build_graph_compat = require("src/legacy/logic/build-graph-compat")

-- Build dependents
log("Adding dependents")
build_graph.add_dependents(dep_graph)

log("Gathering randomizations")

-- Load in randomizations
require("src/randomizations/init")

-- TODO: Planetary randomizations here
--randomizations.planetary_tiles("planetary-tiles")

log("Applying graph-based randomizations")

local exclusion_catalog = graph_customization.catalog(old_data_raw or data.raw, defines.prototypes)
prototype_exclusions.initialize(config.customization, data.raw, defines.prototypes, old_data_raw)
config.graph_exclusion_warnings = config.graph_exclusion_warnings or {}
for _, selector in pairs(prototype_exclusions.unmatched(config.customization, exclusion_catalog)) do
    if config.graph_exclusion_warnings[selector] == nil then
        config.graph_exclusion_warnings[selector] = true
        table.insert(randomization_info.warnings, {
            "propertyrandomizer-warning.graph-exclusion-empty",
            selector,
        })
        log("Prototype exclusion matches no loaded prototypes: " .. selector)
    end
end
if config.graph.item == true or config.graph.recipe == true or config.graph.technology == true or config.graph.recipe_tech_unlock == true then
    graph_customization.initialize(config.customization, data.raw, defines.prototypes, config.seed, exclusion_catalog)
    if config.graph.item == true then
        new_logic.build()
        graph_customization.protect_references(new_logic.graph, "items")
    end
end

-- Rebuild tech tree (setting propertyrandomizer-tech-tree-rebuild)
if config.tech_tree_rebuild then
    randomizations.rebuild_tech_tree()
end

-- Old item randomization is only held to the old logic for now (the oldlogic line in tests/configs.txt), so with it on, the old logic checks the built game too (OLDLOGICCHECK below)
-- Its science packs before graph randomization are the baseline; balance rules (build-graph-compat.lua) are soft, so they're left out of both sorts
local top_sort = require("src/legacy/logic/top-sort")
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

local resource_report = require("src/cost/resource-report")
local flow_cost = require("src/cost/flow-cost")
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
            local category = randomization_spec[id].category
            prototype_exclusions.run(id, category, function() randomizations[id](id) end)
        end
    end
end

log("Done applying numerical/misc randomizations")

-- Numerical randomization changes recipe amounts and times too, so recycling recipes are generated again from the game as it is now (src/prototypes/recipes/recycling.lua)
randomizations.fix_recycling_recipes()
-- Both unified and old item randomization change what hand-written recycling recipes recycle
randomizations.fix_recycling_names()

log("Applying extra randomizations")

if config.misc.icon then
    prototype_exclusions.run("all_icons", "misc", function() randomizations.all_icons("all_icons") end)
end
if config.misc.sound then
    prototype_exclusions.run("all_sounds", "misc", function() randomizations.all_sounds("all_sounds") end)
end
if config.misc.gui then
    for _, id in pairs({
        "group_order",
        "recipe_order",
        "recipe_subgroup",
        "subgroup_group",
    }) do
        prototype_exclusions.run(id, "misc", function() randomizations[id](id) end)
    end
end
if config.misc.locale then
    prototype_exclusions.run("all_names", "misc", function() randomizations.all_names("all_names") end)
end
if config.misc.colors ~= "no" then
    prototype_exclusions.run("colors", "misc", function() randomizations.colors("colors") end)
end

log("Done applying extra randomizations")

-- Items made shippable for planet goals stay so, though later randomization changed weights and spoil times again (src/randomizations/planetary/transport.lua)
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

new_logic.build()
local final_sort_info = top.sort(new_logic.graph)
-- Mechanic context check (src/randomizations/unified/skeleton/check.lua), over room/ability contexts
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
            -- The limits on planetary changes the game breaks, which the panel lists in red (planetary.broken_limits)
            ["broken_limits"] = planetary.broken_limits(),
        },
    },
})

-- Add old versions and postfixes
-- The result summary at the end only counts what add_old_versions makes (src/pipeline/result-summary.lua)
local result_summary = require("src/pipeline/result-summary")
local names_before_old_versions = result_summary.prototype_names(data.raw)
randomizations.add_old_versions()
randomizations.post_fixes()

if release_isolation ~= nil then
    release_isolation.check_prerequisites()
end

-- Strings that named a planet by its locale key get its new name (src/randomizations/planetary/planet-names.lua)
if config.planet_names then
    planet_names.fix_references()
end

-- Every planet but the starting one gets a random tint, wherever its images show (src/randomizations/planetary/planet-tints.lua)
local planet_tints = require("src/randomizations/planetary/planet-tints")
if config.planet_tints then
    planet_tints.execute()
end

-- Whole environmental ambience and planet music profiles, once every copy exists, with the name/tint identity gate and starting-planet policy.
local planet_sounds = require("src/randomizations/planetary/planet-sounds")
if config.planet_names == true then
    planet_sounds.execute()
end

-- Regional terrain appearances and decorative vegetation preserve the finished terrain and entity mechanics, after gameplay checks.
if config.planetary_biomes == true then
    biomes.execute()
end

-- Shared resource profiles use the final placements, including swaps, repairs and duplicate planets.
local planet_resource_profiles = require("src/randomizations/planetary/planet-resource-profiles")
if config.planetary_resources == true then
    planet_resource_profiles.execute()
end

-- What the randomization did, in the log as RESULT lines (src/pipeline/result-summary.lua): how the finished game differs from the one before any randomization
log("Logging what the randomization did")
result_summary.log(pre_planetary_raw or old_data_raw, data.raw, {
    prototypes = result_summary.added_since(names_before_old_versions, data.raw),
    what = "the (Original!) and (Free!) copies add_old_versions makes",
})
log("Done logging what the randomization did")

-- Add warnings for control stage
smuggle_info()

-- The finished data.raw in the log between markers (setting propertyrandomizer-dump-data-raw), for extracting into a mod that loads this game without randomizing it again; the format the py version wrote, which lib/cost/lower-bounder's scripts read too
if config.dump_data_raw == true then
    log("Writing data.raw to the log")
    log("__DATA_RAW_BEGIN__\n" .. serpent.dump(data.raw) .. "\n__DATA_RAW_END__")
end

log("Done!")

-- Set config back to nil so that globals aren't floating around
config = nil

-- The collector's step multiplier as it was before this file (see GC_STEPMUL at the top)
collectgarbage("setstepmul", previous_gc_stepmul)
