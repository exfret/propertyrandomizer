-- Planetary randomization stages (settings propertyrandomizer-planetary-oceans and propertyrandomizer-planetary-resources)
-- They run before the rest of randomization, so everything after them, including the mechanic context check, treats the changed world as the starting point.
-- Ocean swaps (oceans.lua) come with the scaffolding recipes each planet needs (scaffolds.lua); resource swaps (resources.lua) come with edits to the recipes belonging to that planet, then the extra resource patches each planet still needs.
-- All are checked against the game before them with the logic graph (check.lua).
-- None ever stops the game from loading: anything that goes wrong (including errors, for mod compatibility) undoes that stage instead.

-- Superposed mode (see notes/context-shift-report): the swaps come with their root repairs (scaffolds.lua's fluid replacements, and the recipe and trigger edits that follow resource swaps) but no extra patches, and the game before them goes to the rest of randomization as debt (planetary.superposed)
-- Root repairs are fine as fixes though not as random choices (like water or lava taking a lost fluid's place), and they change what unified never changes, what processes a pumped fluid or mined resource
-- Promotion then keeps the goals the swaps still break while unified's choices pay for what they can (see skeleton/promotion.lua), and what's still owed after that is settled (planetary.settle)
-- Entity randomization reshapes promotion's graph too much for the debt edges to fit, so with it on, the usual stages run instead
local SUPERPOSED = false

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local superpose = require("lib/graph/superpose")
local settlement = require("lib/graph/settlement")
local planetary_check = require("randomizations/planetary/check")
local oceans = require("randomizations/planetary/oceans")
local resources = require("randomizations/planetary/resources")
local scaffolds = require("randomizations/planetary/scaffolds")

local planetary = {}

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

-- what is the stage's name, like "ocean swaps"
local function warn(what, message)
    log("Planetary " .. what .. ": " .. message)
    table.insert(randomization_info.warnings, "[img=item.propertyrandomizer-gear] [color=yellow]exfret's Randomizer:[/color] Planetary " .. what .. " " .. message)
end

-- Each stage returns nil if it worked, or else why it has to be undone
-- state holds what the stages share: the sort of the game before them (before), the scaffold variants that count as their originals, and the sort of the latest result (after, nil while the latest changes are unchecked)
-- Sorts are what planetary changes cost, so stages first run without checking their own result (state.careful false): each stage's first sort also checks every earlier stage, and one sort at the end checks the last
-- Only if that fails does everything run again carefully, each stage checking itself and being undone on its own

local function run_oceans(logic, state, old_raw)
    planetary_check.moved_features["oceans"] = true
    local assignment, clone_to_slot = oceans.execute("random", "planetary-oceans")
    local variants_of, after = scaffolds.execute(assignment, oceans, logic, state.before, state.careful)
    -- Tile collision staying exactly as it was is part of how the swap works, so a difference means something unexpected happened
    local tile_problems = planetary_check.tiles_unchanged(old_raw, clone_to_slot)
    if #tile_problems > 0 then
        return "tile collision changed (" .. table.concat(tile_problems, "; ") .. ")"
    end
    state.variants_of = variants_of
    if not state.careful then
        state.after = nil
        return nil
    end
    state.after = after or planetary_check.sort(logic)
    if not planetary_check.required(state.before, state.after, state.variants_of) then
        return "a planet lost something it must keep (see PLANETCHECK in the log)"
    end
    return nil
end

local function log_edits(edits, trigger_edits)
    log("Planetary resources: " .. #edits .. " recipes and " .. #trigger_edits .. " technology triggers edited to follow the swap")
    for _, edit in pairs(edits) do
        log("Planetary resource edit: " .. resources.describe_edit(edit))
    end
    for _, edit in pairs(trigger_edits) do
        log("Planetary resource trigger edit: " .. resources.describe_trigger_edit(edit))
    end
end

-- Swaps resources, and has the recipes and mining-triggered technologies belonging to one planet follow its swap
-- Returns what resources.execute does, then the recipe edits and the trigger edits
local function swap_resources(state)
    planetary_check.moved_features["resources"] = true
    local slots, assignment, lost = resources.execute("planetary-resources")

    -- Recipes belonging to one planet follow that planet's swap, including the ocean stage's planet variants
    local planet_recipes = {}
    for _, candidate in pairs(scaffolds.kept) do
        planet_recipes[candidate.planet] = planet_recipes[candidate.planet] or {}
        planet_recipes[candidate.planet][candidate.recipe_name] = true
    end
    local edits = resources.edits(resources.substitutions(slots, assignment, lost), state.before, planet_recipes)
    for _, edit in pairs(edits) do
        resources.add_edit(edit)
    end
    -- So do technologies belonging to one planet that are researched by mining a resource it lost
    local trigger_edits = resources.trigger_edits(resources.replacements(slots, assignment, lost), state.before)
    for _, edit in pairs(trigger_edits) do
        resources.add_trigger_edit(edit)
    end
    return slots, assignment, lost, edits, trigger_edits
end

local function run_resources(logic, state)
    local slots, assignment, lost, edits, trigger_edits = swap_resources(state)

    -- What the swap still breaks without any extra patches
    local without = planetary_check.sort(logic)
    local failures = planetary_check.required_failures(state.before, without, state.variants_of)
    if #failures == 0 then
        log_edits(edits, trigger_edits)
        log("Planetary resources: no extra patches needed")
        state.after = without
        return nil
    end
    for _, failure in pairs(failures) do
        log("Planetary resources: without extra patches, failing " .. failure.text)
    end

    -- Every extra patch that could help (each resource a planet lost), then only those on the witnesses (earliest-provider paths) of what broke
    local repairs = {}
    for _, planet_name in pairs(sorted_keys(lost)) do
        for _, resource_name in pairs(sorted_keys(lost[planet_name])) do
            local repair = resources.repair(planet_name, resource_name)
            if repair ~= nil then
                resources.add_repair(repair)
                table.insert(repairs, repair)
            end
        end
    end
    local with_all = planetary_check.sort(logic)
    local used = {}
    for ind, _ in pairs(top.path(with_all.graph, planetary_check.goal_inds(failures, with_all), with_all.sort_info).in_path) do
        local pebble = with_all.sort_info.sorted[ind]
        used[pebble.node_key .. " @ " .. top.context_room(pebble.context)] = true
    end
    local kept = {}
    for _, repair in pairs(repairs) do
        if used[gutils.key("entity", repair.resource_name) .. " @ " .. gutils.key("planet", repair.planet_name)] ~= nil then
            table.insert(kept, repair)
        else
            resources.remove_repair(repair)
        end
    end
    local function log_kept()
        log_edits(edits, trigger_edits)
        log("Planetary resources: " .. #kept .. " of " .. #repairs .. " possible extra patches needed")
        for _, repair in pairs(kept) do
            log("Planetary resources: extra " .. repair.resource_name .. " patches on " .. repair.planet_name)
        end
    end
    if not state.careful then
        log_kept()
        state.after = nil
        return nil
    end
    state.after = planetary_check.sort(logic)
    if not planetary_check.required(state.before, state.after, state.variants_of, true) then
        -- The witnesses missed something, so try every extra patch
        for _, repair in pairs(repairs) do
            resources.add_repair(repair)
        end
        kept = repairs
        state.after = planetary_check.sort(logic)
        if not planetary_check.required(state.before, state.after, state.variants_of, true) then
            -- The edits themselves may be what's in the way (like a new ingredient only a later drill can mine), so try the original recipes and technology triggers
            log("Planetary resources: every extra patch still wasn't enough, so trying without recipe and trigger edits")
            for _, edit in pairs(edits) do
                resources.remove_edit(edit)
            end
            for _, edit in pairs(trigger_edits) do
                resources.remove_trigger_edit(edit)
            end
            edits = {}
            trigger_edits = {}
            state.after = planetary_check.sort(logic)
            if not planetary_check.required(state.before, state.after, state.variants_of) then
                return "a planet lost something it must keep even with extra patches (see PLANETCHECK in the log)"
            end
        end
    end
    log_kept()
    return nil
end

-- Runs a stage, undoing it (data.raw and the shared state back to how they were) if it fails or errors
local function run_stage(what, stage, logic, state)
    local old_raw = table.deepcopy(data.raw)
    local old_state = {
        after = state.after,
        variants_of = state.variants_of,
    }
    local old_moved_features = table.deepcopy(planetary_check.moved_features)
    local is_ok, reason = pcall(stage, logic, state, old_raw)
    if not is_ok then
        reason = "of an error: " .. tostring(reason)
    end
    if reason ~= nil then
        data.raw = old_raw
        state.after = old_state.after
        state.variants_of = old_state.variants_of
        planetary_check.moved_features = old_moved_features
        warn(what, "were undone, since " .. reason .. ".")
        return false
    end
    return true
end

-- Runs every stage that's on; with careful, each stage checks its own result (see state above)
local function run_stages(logic, state, careful)
    state.careful = careful
    if config.planetary_oceans then
        local problem = oceans.problem()
        if problem ~= nil then
            warn("ocean swaps", "were skipped, since " .. problem .. ".")
        elseif not run_stage("ocean swaps", run_oceans, logic, state) then
            scaffolds.kept = {}
        end
    end
    if config.planetary_resources then
        run_stage("resource swaps", run_resources, logic, state)
    end
end

-- logic is the logic module (lib/logic/init), rebuilt from data.raw for each check
-- The game before planetary changes as debt for promotion (see superposed mode at the top), or nil
-- It's promotion's params.debt: { graph, debt_edges and old_nodes (from superpose.union), is_goal = whether a pebble is one of the goals the swaps carry over in an exact context (check.transported_goals), goals = those goals }
planetary.superposed = nil

-- Superposed mode: runs every swap that's on raw, then superposes the game before them on the game after
local function run_superposed(logic, state)
    if config.planetary_oceans then
        local problem = oceans.problem()
        if problem ~= nil then
            warn("ocean swaps", "were skipped, since " .. problem .. ".")
        else
            planetary_check.moved_features["oceans"] = true
            local old_raw = table.deepcopy(data.raw)
            local assignment, clone_to_slot = oceans.execute("random", "planetary-oceans")
            -- Root repairs: where a goal needs it, the recipes a planet used its old fluid for take its new one (scaffolds.lua), since unified never changes what processes a pumped fluid
            state.variants_of = scaffolds.execute(assignment, oceans, logic, state.before, false)
            for _, problem_text in pairs(planetary_check.tiles_unchanged(old_raw, clone_to_slot)) do
                log("Planetary superposed: " .. problem_text)
            end
        end
    end
    if config.planetary_resources then
        local _, _, _, edits, trigger_edits = swap_resources(state)
        log_edits(edits, trigger_edits)
    end
    local after = planetary_check.sort(logic)
    -- What the swaps still break after their root repairs, which is what promotion starts out owing
    planetary_check.required(state.before, after, state.variants_of, false, "PLANETCHECK superposed")
    local union = superpose.union(after.graph, state.before.graph)
    local num_debt_edges = 0
    for _, _ in pairs(union.debt_edges) do
        num_debt_edges = num_debt_edges + 1
    end
    log("Planetary superposed: " .. num_debt_edges .. " debt edges, " .. #union.not_into_or .. " of them into nodes that aren't OR nodes")
    for _, edge_key in pairs(union.not_into_or) do
        log("Planetary superposed: debt edge into a node that isn't an OR node: " .. edge_key)
    end
    -- A planet variant (see scaffolds.lua) counts as its original, so an original's goal the game already meets through a variant isn't owed
    local goals = planetary_check.transported_goals(state.before)
    local nci = after.sort_info.node_to_context_inds
    for recipe_name, variant_names in pairs(state.variants_of) do
        local node_key = gutils.key("recipe", recipe_name)
        for context, _ in pairs(goals[node_key] or {}) do
            for _, variant_name in pairs(variant_names) do
                if (nci[gutils.key("recipe", variant_name)] or {})[context] ~= nil then
                    goals[node_key][context] = nil
                end
            end
        end
    end
    planetary.superposed = {
        graph = union.graph,
        debt_edges = union.debt_edges,
        old_nodes = union.old_nodes,
        is_goal = function(node_key, context)
            return goals[node_key] ~= nil and goals[node_key][context] ~= nil
        end,
        goals = goals,
    }
end

-- logic is the logic module (lib/logic/init), rebuilt from data.raw for each check
planetary.execute = function(logic)
    local state = {
        variants_of = {},
    }
    -- The first sort sets the home sets every later one uses
    planetary_check.home_sets = nil
    planetary_check.num_sorts = 0
    local is_ok = pcall(function()
        state.before = planetary_check.sort(logic)
    end)
    if not is_ok then
        warn("changes", "were skipped, since the logic couldn't be sorted.")
        return
    end

    if SUPERPOSED and not config.entity_randomization then
        run_superposed(logic, state)
        planetary.before = {
            sort = state.before,
            variants_of = state.variants_of,
        }
        log("Planetary: " .. planetary_check.num_sorts .. " sorts")
        return
    end

    local old_raw = table.deepcopy(data.raw)
    run_stages(logic, state, false)
    if state.after == nil then
        local is_sorted, passes = pcall(function()
            state.after = planetary_check.sort(logic)
            return planetary_check.required(state.before, state.after, state.variants_of, true)
        end)
        if not (is_sorted and passes) then
            log("Planetary: the changes together didn't pass, so running each stage again with its own check")
            data.raw = old_raw
            state.variants_of = {}
            state.after = nil
            planetary_check.moved_features = {}
            scaffolds.kept = {}
            run_stages(logic, state, true)
        end
    end
    if state.after ~= nil then
        planetary_check.run(state.before, state.after)
    end
    log("Planetary: " .. planetary_check.num_sorts .. " sorts")
    -- Moved features are the stages whose changes are still in the game
    if next(planetary_check.moved_features) ~= nil then
        planetary.before = {
            sort = state.before,
            variants_of = state.variants_of,
        }
    end
end


-- The game before planetary changes (its sort, and the scaffold variants that count as its recipes), kept for check_final while any stage's changes are in the game
planetary.before = nil

-- The home sets planetary's goals were made with (check.home_sets) while any stage's changes are in the game, for the rest of randomization's sorts, or nil
-- They're the game's before the changes
-- The changed game isn't asked for its own: in superposed mode it relies on its debt, and may not reach any discoverer until unified pays it (then it would have no home sets, and nothing would be isolatable by discovery)
planetary.home_sets = function()
    if planetary.before == nil then
        return nil
    end
    return planetary_check.home_sets
end

-- Settlers (see lib/graph/settlement.lua): for each kind of feature a planetary change moves, the fixes for a debt edge it owns, cheapest first
-- Ocean swaps have none yet, so what they still owe is only reported
local settlers = {
    -- A resource a planet had (room-autoplace --> resource entity) comes back as extra patches of it (resources.repair), an addition
    {
        name = "resources",
        owns = function(edge)
            local start = gutils.deconstruct(edge.start)
            local stop = gutils.deconstruct(edge.stop)
            return start.type == "room-autoplace" and stop.type == "entity" and data.raw.resource[stop.name] ~= nil
        end,
        fixes = function(edge)
            local room = gutils.deconstruct(gutils.deconstruct(edge.start).name)
            local resource_name = gutils.deconstruct(edge.stop).name
            if room.type ~= "planet" or data.raw.planet[room.name] == nil then
                return {}
            end
            local repair = resources.repair(room.name, resource_name)
            if repair == nil then
                return {}
            end
            return {
                {
                    rung = "addition",
                    text = "extra " .. resource_name .. " patches on " .. room.name,
                    apply = function()
                        resources.add_repair(repair)
                    end,
                    undo = function()
                        resources.remove_repair(repair)
                    end,
                },
            }
        end,
    },
}

-- Settles what the finished game (after the rest of randomization) still owes from planetary changes in superposed mode, with the settlers above
-- The logic module (logic) is rebuilt from data.raw for each check
planetary.settle = function(logic)
    if planetary.superposed == nil then
        return
    end
    local result = settlement.settle({
        check = function()
            local game = planetary_check.sort(logic)
            return {
                failures = planetary_check.required_failures(planetary.before.sort, game, planetary.before.variants_of),
                graph = game.graph,
                sort_extra = {
                    complex_contexts = true,
                    home_contexts = true,
                    home_sets = planetary_check.home_sets,
                },
            }
        end,
        debt = planetary.superposed,
        settlers = settlers,
    })
    log("Planetary settlement: " .. #result.applied .. " fixes, " .. #result.failures .. " goals still owed")
    for _, fix in pairs(result.applied) do
        log("Planetary settlement: " .. fix.rung .. ": " .. fix.text)
    end
    for _, failure in pairs(result.failures) do
        log("Planetary settlement: still owed " .. failure.text)
    end
    for _, edge_key in pairs(sorted_keys(result.unsettled)) do
        log("Planetary settlement: no fix for debt edge " .. edge_key)
    end
end

-- Checks the finished game (graph, after all randomization) against the game before planetary changes, with the same rules as each stage's own check
-- Only logged for now (PLANETCHECK final): later randomization doesn't protect everything planetary changes kept yet, so this measures how much of it survives
planetary.check_final = function(graph)
    if planetary.before == nil then
        return
    end
    local after = {
        graph = graph,
        sort_info = top.sort(graph, nil, nil, {
            complex_contexts = true,
            home_contexts = true,
            home_sets = planetary_check.home_sets,
        }),
    }
    planetary_check.required(planetary.before.sort, after, planetary.before.variants_of, false, "PLANETCHECK final")
end

return planetary
