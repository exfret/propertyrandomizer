-- Planetary randomization stages (settings propertyrandomizer-planetary-oceans and propertyrandomizer-planetary-resources)
-- They run before the rest of randomization, so everything after them, including the mechanic context check, treats the changed world as the starting point.
-- Ocean swaps (oceans.lua) come with the scaffolding recipes each planet needs (scaffolds.lua); resource swaps (resources.lua) come with edits to the recipes belonging to that planet, then the extra resource patches each planet still needs.
-- All are checked against the game before them with the logic graph (check.lua).
-- None ever stops the game from loading: anything that goes wrong (including errors, for mod compatibility) undoes that stage instead.

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
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

local function log_edits(edits)
    log("Planetary resources: " .. #edits .. " recipes edited to follow the swap")
    for _, edit in pairs(edits) do
        log("Planetary resource edit: " .. resources.describe_edit(edit))
    end
end

local function run_resources(logic, state)
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

    -- What the swap still breaks without any extra patches
    local without = planetary_check.sort(logic)
    local failures = planetary_check.required_failures(state.before, without, state.variants_of)
    if #failures == 0 then
        log_edits(edits)
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
        log_edits(edits)
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
            -- The edits themselves may be what's in the way (like a new ingredient only a later drill can mine), so try the original recipes
            log("Planetary resources: every extra patch still wasn't enough, so trying without recipe edits")
            for _, edit in pairs(edits) do
                resources.remove_edit(edit)
            end
            edits = {}
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
end

return planetary
