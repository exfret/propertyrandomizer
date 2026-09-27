-- Planetary randomization stages (settings propertyrandomizer-planetary-oceans, -resources, -lightning, -freezing and -locks)
-- They run before the rest of randomization, so everything after them, including the mechanic context check, treats the changed world as the starting point.
-- Ocean swaps (oceans.lua) come with the scaffolding recipes each planet needs (scaffolds.lua); resource swaps (resources.lua) come with edits to the recipes belonging to that planet, then the extra resource patches each planet still needs.
-- Lightning (lightning.lua) moves to another planet with what builds lightning attractors; a planet that needed its lightning keeps it as well.
-- Freezing (freezing.lua) moves to another planet with the technologies for heating; a planet that needed to stay frozen does.
-- Planet locks (locks.lua) move which planets accept recipes and entities with surface conditions; a lock breaking something its old planet must keep accepts that planet again too.
-- All are checked against the game before them with the logic graph (check.lua).
-- None ever stops the game from loading: anything that goes wrong (including errors, for mod compatibility) undoes that stage instead.

-- Superposed mode (see notes/context-shift-report): the swaps come with their root repairs (scaffolds.lua's fluid replacements, and the recipe and trigger edits that follow resource swaps) but no extra patches, and the game before them goes to the rest of randomization as debt (planetary.superposed)
-- Root repairs are fine as fixes though not as random choices (like water or lava taking a lost fluid's place), and they change what unified never changes, what processes a pumped fluid or mined resource
-- Promotion then keeps the goals the swaps still break while unified's choices pay for what they can (see skeleton/promotion.lua), and what's still owed after that is settled (planetary.settle)
-- Entity randomization reshapes promotion's graph too much for the debt edges to fit, so with it on, the usual stages run instead
local SUPERPOSED = false

-- Whether the rest of randomization keeps the recipe goals that moved with planetary changes (protection.transported_recipe_contexts), like a moved lock's recipe staying automatable on its new planet
-- Off: on seeds 1-2 (all planetary stages on) every unified attempt then failed, each time on a recycling recipe of a moved lock's item becoming unreachable (like electromagnetic-plant-recycling), while without it all three seeds passed; not yet root-caused
local PROTECT_TRANSPORTED = false

local gutils = require("lib/graph/graph-utils")
local lutils = require("lib/logic/logic-utils")
local top = require("lib/graph/context-sort")
local superpose = require("lib/graph/superpose")
local settlement = require("lib/graph/settlement")
local planetary_check = require("randomizations/planetary/check")
local protection = require("randomizations/graph/unified/skeleton/protection")
local oceans = require("randomizations/planetary/oceans")
local resources = require("randomizations/planetary/resources")
local scaffolds = require("randomizations/planetary/scaffolds")
local locks = require("randomizations/planetary/locks")
local lightning = require("randomizations/planetary/lightning")
local freezing = require("randomizations/planetary/freezing")

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

-- Why a stage built on the current logic can't run, or nil: the old graph randomizations (config.graph: technology, recipe, recipe tech unlocks, item) reason with the old logic (lib/old-logic), which knows nothing of lightning safety, the heating bootstrap or moved planet locks, so they can't keep what these stages need
local function old_graph_problem()
    if next(config.graph or {}) ~= nil then
        return "the old technology, recipe or item randomizations are on, and they can't keep what these changes need"
    end
    return nil
end

local function log_locks()
    log("Planet locks: " .. #sorted_keys(locks.moved) .. " moved")
    for _, id in pairs(sorted_keys(locks.moved)) do
        log("Planet lock: " .. locks.describe(id))
    end
end

-- Moves planet locks (locks.lua), whose recipes' goals follow them (check.transport), then fixes what they break:
--   1. With every lock also accepting its old planets (widened), nothing a planet must keep is lost to the moves, so a moved recipe still failing its own goals can't be reached at all, or isn't automatable on its new planet even with imports: it keeps its old lock (a revert).
--   2. A lock whose old planet needed it (for its science, planet-locked recipes that didn't move, or mechanics) keeps accepting that planet, if the witnesses (earliest-provider paths) of what broke use it there; the other widenings go.
-- Planet variants the ocean stage made (scaffolds.lua) are for one planet on purpose, so they keep their locks
local function planet_variants(state)
    local variants = {}
    for _, variant_names in pairs(state.variants_of or {}) do
        for _, variant_name in pairs(variant_names) do
            variants[variant_name] = true
        end
    end
    return variants
end

local function run_locks(logic, state)
    planetary_check.moved_features["locks"] = true
    locks.execute("planetary-locks", planet_variants(state))
    for node_key, entry in pairs(locks.transport()) do
        planetary_check.transport[node_key] = entry
    end

    local without = planetary_check.sort(logic)
    local failures = planetary_check.required_failures(state.before, without, state.variants_of)
    if #failures == 0 then
        log_locks()
        state.after = without
        return nil
    end
    log("Planet locks: " .. #failures .. " failures before repairs")

    -- Widen every lock to its old planets too
    local new_rooms = {}
    for id, lock in pairs(locks.moved) do
        new_rooms[id] = lock.rooms
        local widened = {}
        for room_key, _ in pairs(lock.rooms) do
            widened[room_key] = true
        end
        for room_key, _ in pairs(lock.old) do
            widened[room_key] = true
        end
        lock.rooms = widened
    end
    locks.realize()
    local with_all = planetary_check.sort(logic)

    -- 1. Moved recipes whose own goals still fail keep their old locks
    local to_revert = {}
    for _, failure in pairs(planetary_check.required_failures(state.before, with_all, state.variants_of)) do
        local lock, id = locks.lock_of_recipe(failure.keys[1])
        if lock ~= nil then
            to_revert[id] = true
        else
            log("Planet locks: still failing with every lock widened: " .. failure.text)
        end
    end
    local reverted = locks.revert(sorted_keys(to_revert))
    local reverted_recipes = {}
    for _, id in pairs(sorted_keys(reverted)) do
        log("Planet locks: " .. id .. " keeps its old lock, since its own goals fail on its new planets")
        local recipe_key = gutils.key("recipe", reverted[id].name)
        planetary_check.transport[recipe_key] = nil
        reverted_recipes[recipe_key] = true
    end

    -- 2. Keep only the widenings the witnesses of what broke use (reverted recipes' own goals aside)
    local rest = {}
    for _, failure in pairs(failures) do
        if reverted_recipes[failure.keys[1]] == nil then
            table.insert(rest, failure)
        end
    end
    local used = {}
    if #rest > 0 then
        for ind, _ in pairs(top.path(with_all.graph, planetary_check.goal_inds(rest, with_all), with_all.sort_info).in_path) do
            local pebble = with_all.sort_info.sorted[ind]
            local lock, id = locks.lock_of_node(pebble.node_key)
            if lock ~= nil then
                local room_key = top.context_room(pebble.context)
                if new_rooms[id][room_key] == nil then
                    used[id] = used[id] or {}
                    used[id][room_key] = true
                end
            end
        end
    end
    for id, lock in pairs(locks.moved) do
        local rooms = {}
        for room_key, _ in pairs(new_rooms[id]) do
            rooms[room_key] = true
        end
        for room_key, _ in pairs(used[id] or {}) do
            rooms[room_key] = true
            log("Planet locks: " .. id .. " accepts " .. room_key .. " again")
        end
        lock.rooms = rooms
    end
    locks.realize()

    if not state.careful then
        log_locks()
        state.after = nil
        return nil
    end
    state.after = planetary_check.sort(logic)
    if not planetary_check.required(state.before, state.after, state.variants_of, true) then
        -- The witnesses missed something, so every lock accepts its old planets again
        for _, lock in pairs(locks.moved) do
            for room_key, _ in pairs(lock.old) do
                lock.rooms[room_key] = true
            end
        end
        locks.realize()
        state.after = planetary_check.sort(logic)
        if not planetary_check.required(state.before, state.after, state.variants_of) then
            return "a planet lost something it must keep even with every lock accepting its old planets again (see PLANETCHECK in the log)"
        end
    end
    log_locks()
    return nil
end

-- Moves lightning with what builds lightning attractors (lightning.lua); lightning power's goals follow it (check.transport)
-- If a planet then loses something it must keep (like electricity from its own resources, which lightning was), each planet that gave lightning away keeps it as well (an addition)
local function run_lightning(logic, state)
    local map = lightning.execute("planetary-lightning")
    if next(map) == nil then
        log("Planetary lightning: no planet gave its lightning away")
        return nil
    end
    planetary_check.moved_features["lightning"] = true
    for node_key, entry in pairs(lightning.transport(state.before.graph, map)) do
        planetary_check.transport[node_key] = entry
    end
    for node_key, entry in pairs(locks.transport()) do
        planetary_check.transport[node_key] = entry
    end
    log("Planetary lightning: " .. lightning.describe())

    local after = planetary_check.sort(logic)
    local failures = planetary_check.required_failures(state.before, after, state.variants_of)
    if #failures == 0 then
        state.after = after
        return nil
    end
    local fails_where_it_was = false
    for _, failure in pairs(failures) do
        log("Planetary lightning: without keeping lightning where it was, failing " .. failure.text)
        if failure.context ~= nil and map[top.context_room(failure.context)] ~= nil then
            fails_where_it_was = true
        end
    end
    -- If only the new planets fail, they may just need attractors made where lightning was, so try that first; a planet that lost something itself needs its lightning back
    if not fails_where_it_was then
        lightning.widen_locks()
        log("Planetary lightning: what builds attractors is accepted where lightning was, as well")
        after = planetary_check.sort(logic)
        if planetary_check.required(state.before, after, state.variants_of) then
            state.after = after
            return nil
        end
    end
    lightning.keep_old()
    log("Planetary lightning: planets that gave their lightning away keep it as well")
    state.after = planetary_check.sort(logic)
    if not planetary_check.required(state.before, state.after, state.variants_of) then
        return "a planet lost something it must keep even with lightning staying where it was as well (see PLANETCHECK in the log)"
    end
    return nil
end

-- Moves freezing with the technologies for heating (freezing.lua)
-- A planet that stops freezing only gains warmth, so whatever fails is on a planet that now freezes, and keeping the old planet frozen as well wouldn't help: the stage is undone instead
local function run_freezing(logic, state)
    local map = freezing.execute("planetary-freezing")
    if next(map) == nil then
        log("Planetary freezing: no planet gave its freezing away")
        return nil
    end
    planetary_check.moved_features["freezing"] = true
    log("Planetary freezing: " .. freezing.describe())
    -- A heat source delivered to a planet that now freezes counts as local there if the planet can then make more (lib/logic/bootstrap.lua)
    lutils.bootstrap_heat_rooms = freezing.new_frozen_rooms()
    state.after = planetary_check.sort(logic)
    if not planetary_check.required(state.before, state.after, state.variants_of, false, "PLANETCHECK freezing") then
        return "a planet that freezes now lost something it must keep (see PLANETCHECK freezing in the log)"
    end
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
    local old_transport = table.deepcopy(planetary_check.transport)
    local old_locks = locks.moved
    local old_bootstrap_heat_rooms = lutils.bootstrap_heat_rooms
    local is_ok, reason = pcall(stage, logic, state, old_raw)
    if not is_ok then
        reason = "of an error: " .. tostring(reason)
    end
    if reason ~= nil then
        data.raw = old_raw
        state.after = old_state.after
        state.variants_of = old_state.variants_of
        planetary_check.moved_features = old_moved_features
        planetary_check.transport = old_transport
        locks.moved = old_locks
        lutils.bootstrap_heat_rooms = old_bootstrap_heat_rooms
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
    if config.planetary_lightning then
        local problem = old_graph_problem() or lightning.problem()
        if problem ~= nil then
            warn("lightning moves", "were skipped, since " .. problem .. ".")
        else
            run_stage("lightning moves", run_lightning, logic, state)
        end
    end
    if config.planetary_freezing then
        local problem = old_graph_problem() or freezing.problem()
        if problem ~= nil then
            warn("freezing moves", "were skipped, since " .. problem .. ".")
        else
            run_stage("freezing moves", run_freezing, logic, state)
        end
    end
    if config.planetary_locks then
        if old_graph_problem() ~= nil then
            warn("planet locks", "were skipped, since " .. old_graph_problem() .. ".")
        else
            run_stage("planet locks", run_locks, logic, state)
        end
    end
end

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
    if config.planetary_lightning and old_graph_problem() == nil and lightning.problem() == nil then
        local map = lightning.execute("planetary-lightning")
        if next(map) ~= nil then
            planetary_check.moved_features["lightning"] = true
            for node_key, entry in pairs(lightning.transport(state.before.graph, map)) do
                planetary_check.transport[node_key] = entry
            end
            log("Planetary lightning: " .. lightning.describe())
        end
    end
    if config.planetary_freezing and old_graph_problem() == nil and freezing.problem() == nil then
        if next(freezing.execute("planetary-freezing")) ~= nil then
            planetary_check.moved_features["freezing"] = true
            lutils.bootstrap_heat_rooms = freezing.new_frozen_rooms()
            log("Planetary freezing: " .. freezing.describe())
        end
    end
    if config.planetary_locks and old_graph_problem() == nil then
        planetary_check.moved_features["locks"] = true
        locks.execute("planetary-locks", planet_variants(state))
        for node_key, entry in pairs(locks.transport()) do
            planetary_check.transport[node_key] = entry
        end
        log_locks()
    end
    local after = planetary_check.sort(logic)
    -- What the swaps still break after their root repairs, which is what promotion starts out owing
    planetary_check.required(state.before, after, state.variants_of, false, "PLANETCHECK superposed")
    local union = superpose.union(after.graph, state.before.graph)
    -- A moved lock's own goals on its new planet are in neither world before the changes, so the superposition may not reach them, and then no debt edge on a witness says what's owed (it's a reference only for goals one of its worlds reaches)
    -- A lock whose own goals the superposition can't reach keeps its old lock, and the games are sorted and superposed again
    if next(locks.moved) ~= nil then
        local union_sort = {
            graph = union.graph,
            sort_info = top.sort(union.graph, nil, nil, {
                complex_contexts = true,
                home_contexts = true,
                home_sets = planetary_check.home_sets,
            }),
        }
        local to_revert = {}
        for _, failure in pairs(planetary_check.required_failures(state.before, union_sort, state.variants_of)) do
            local lock, id = locks.lock_of_recipe(failure.keys[1])
            if lock ~= nil then
                to_revert[id] = true
            end
        end
        if next(to_revert) ~= nil then
            local reverted = locks.revert(sorted_keys(to_revert))
            for _, id in pairs(sorted_keys(reverted)) do
                log("Planet locks: " .. id .. " keeps its old lock, since even the superposition doesn't reach its own goals on its new planets")
                planetary_check.transport[gutils.key("recipe", reverted[id].name)] = nil
            end
            after = planetary_check.sort(logic)
            union = superpose.union(after.graph, state.before.graph)
        end
    end
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

-- Home sets are part of what the goals mean (see check.home_sets): a planetary change can alter which rooms a planet's discovery needs
-- If it did, both games are sorted again with the home sets they agree on (top.intersect_home_sets, which grant less) and checked again, and later sorts use those
-- Returns whether the changes pass
local function recheck_home_sets(state)
    local shifted = top.home_sets(state.after.graph)
    if top.same_home_sets(shifted, planetary_check.home_sets) then
        return true
    end
    log("Planetary: the changes altered which rooms discoveries need, so checking them again with the home sets both games agree on")
    local both = top.intersect_home_sets(planetary_check.home_sets, shifted)
    planetary_check.home_sets = both
    local function resort(sort)
        local sort_info = top.sort(sort.graph, nil, nil, {
            complex_contexts = true,
            home_contexts = true,
            home_sets = both,
        })
        -- The same recipes are planet-locked, with their contexts in the new sort (home contexts aside, as protection.planet_locked_recipe_contexts does)
        local planet_locked = {}
        for node_key, _ in pairs(sort.planet_locked or {}) do
            planet_locked[node_key] = {}
            for context, _ in pairs(sort_info.node_to_context_inds[node_key] or {}) do
                if top.context_home(context) == nil then
                    planet_locked[node_key][context] = true
                end
            end
        end
        return {
            graph = sort.graph,
            sort_info = sort_info,
            planet_locked = planet_locked,
        }
    end
    state.before = resort(state.before)
    state.after = resort(state.after)
    return planetary_check.required(state.before, state.after, state.variants_of, false, "PLANETCHECK home sets")
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
            planetary_check.transport = {}
            locks.moved = {}
            lutils.bootstrap_heat_rooms = {}
            scaffolds.kept = {}
            run_stages(logic, state, true)
        end
    end
    if state.after ~= nil and next(planetary_check.moved_features) ~= nil then
        local original_home_sets = planetary_check.home_sets
        local is_ok, passes = pcall(recheck_home_sets, state)
        if not (is_ok and passes) then
            data.raw = old_raw
            state.variants_of = {}
            state.after = nil
            planetary_check.home_sets = original_home_sets
            planetary_check.moved_features = {}
            planetary_check.transport = {}
            locks.moved = {}
            lutils.bootstrap_heat_rooms = {}
            scaffolds.kept = {}
            warn("changes", "were undone, since " .. (is_ok and "they changed which planets discoveries need, and fail with the home sets both games agree on (see PLANETCHECK home sets in the log)" or "of an error: " .. tostring(passes)) .. ".")
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
        -- The rest of randomization keeps the recipe goals that moved with the changes, like a moved lock's recipe staying automatable on its new planet (protection.transported_recipe_contexts; see PROTECT_TRANSPORTED)
        if PROTECT_TRANSPORTED then
            local goals = planetary_check.planet_locked_goals(state.before)
            local num_kept = 0
            for node_key, _ in pairs(planetary_check.transport) do
                if goals[node_key] ~= nil and gutils.deconstruct(node_key).type == "recipe" then
                    protection.transported_recipe_contexts[node_key] = goals[node_key]
                    num_kept = num_kept + 1
                end
            end
            log("Planetary: the rest of randomization keeps the goals of " .. num_kept .. " recipes that moved")
        end
    end
end


-- The game before planetary changes (its sort, and the scaffold variants that count as its recipes), kept for check_final while any stage's changes are in the game
planetary.before = nil

-- The home sets planetary's goals were made with (check.home_sets) while any stage's changes are in the game, for the rest of randomization's sorts, or nil
-- They're the game's before the changes, narrowed by recheck_home_sets if the changes moved which rooms discoveries need
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

-- A room a moved planet lock no longer accepts (room --> the lock's surface-condition node, see locks.lua) is accepted again by widening the lock to it, an addition
-- Failing that, the lock goes back to its old set, a revert; its recipe's goals then stay where they were
table.insert(settlers, {
    name = "locks",
    owns = function(edge)
        return gutils.deconstruct(edge.start).type == "room" and locks.lock_of_node(edge.stop) ~= nil
    end,
    fixes = function(edge)
        local lock, id = locks.lock_of_node(edge.stop)
        local room_key = gutils.deconstruct(edge.start).name
        local rooms_before
        local reverted
        local transport_before
        return {
            {
                rung = "addition",
                text = id .. " accepts " .. room_key .. " again",
                apply = function()
                    rooms_before = locks.moved[id].rooms
                    locks.widen(id, {
                        [room_key] = true,
                    })
                end,
                undo = function()
                    locks.set_rooms(id, rooms_before)
                end,
            },
            {
                rung = "revert",
                text = id .. " keeps its old lock",
                apply = function()
                    reverted = locks.revert({
                        id,
                    })
                    if lock.kind == "recipe" then
                        transport_before = planetary_check.transport[gutils.key("recipe", lock.name)]
                        planetary_check.transport[gutils.key("recipe", lock.name)] = nil
                    end
                end,
                undo = function()
                    locks.restore(reverted)
                    if lock.kind == "recipe" then
                        planetary_check.transport[gutils.key("recipe", lock.name)] = transport_before
                    end
                end,
            },
        }
    end,
})

-- Lightning a planet lost (room --> a lightning power node, see lib/logic/abstract.lua) comes back by that planet keeping its lightning as well (lightning.keep_old), an addition
-- Failing that, or for the safety from lightning the new planet lost (room --> lightning-safe), lightning goes back where it was with everything that moved with it, a revert
-- (Undoing a revert moves lightning again with a new draw, which may differ from the first one)
table.insert(settlers, {
    name = "lightning moves",
    owns = function(edge)
        if lightning.last == nil or gutils.deconstruct(edge.start).type ~= "room" then
            return false
        end
        if gutils.deconstruct(edge.stop).type == "lightning-safe" then
            return true
        end
        local node = planetary.superposed.graph.nodes[edge.stop]
        return node ~= nil and node.planetary_feature == "lightning"
    end,
    fixes = function(edge)
        local transport_before
        -- Several debt edges share this fix, so only the one that made it undoes it
        local made_it
        return {
            {
                rung = "addition",
                text = "planets that gave their lightning away keep it as well",
                apply = function()
                    made_it = not lightning.last.kept_old
                    lightning.keep_old()
                end,
                undo = function()
                    if made_it then
                        lightning.give_away_again()
                    end
                end,
            },
            {
                rung = "revert",
                text = "lightning stays where it was",
                apply = function()
                    lightning.revert()
                    transport_before = table.deepcopy(planetary_check.transport)
                    for node_key, _ in pairs(lightning.transport(planetary.superposed.graph, lightning.last.map)) do
                        planetary_check.transport[node_key] = nil
                    end
                end,
                undo = function()
                    planetary_check.transport = transport_before
                    lightning.execute("planetary-lightning")
                end,
            },
        }
    end,
})

-- Warmth a planet lost (room --> warmth, now that it freezes) comes back by undoing the freezing move with its heating technology edits, a revert
-- (A planet that gave its freezing away only gains warmth, so nothing it owes comes from freezing)
table.insert(settlers, {
    name = "freezing moves",
    owns = function(edge)
        return freezing.last ~= nil and gutils.deconstruct(edge.start).type == "room" and gutils.deconstruct(edge.stop).type == "warmth"
    end,
    fixes = function(edge)
        return {
            {
                rung = "revert",
                text = "freezing stays where it was",
                apply = function()
                    freezing.revert()
                    lutils.bootstrap_heat_rooms = {}
                end,
                undo = function()
                    freezing.execute("planetary-freezing")
                    lutils.bootstrap_heat_rooms = freezing.new_frozen_rooms()
                end,
            },
        }
    end,
})

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
