-- Planetary randomization stages (settings propertyrandomizer-planetary-oceans, -resources, -lightning, -freezing, -locks, -rewards and -connections)
-- They run before the rest of randomization, so everything after them, including the mechanic context check, treats the changed world as the starting point.
-- Ocean swaps (oceans.lua) come with the scaffolding recipes each planet needs (scaffolds.lua); resource swaps (resources.lua) come with edits to the recipes and mining-triggered technologies belonging to that planet, then the extra resource patches each planet still needs.
-- Lightning (lightning.lua) moves to another planet with what builds lightning attractors; a planet that needed its lightning keeps it as well.
-- Freezing (freezing.lua) moves to another planet with the technologies for heating; a planet that needed to stay frozen does.
-- Planet locks (locks.lua) move which planets accept recipes and entities with surface conditions; a lock breaking something its old planet must keep accepts that planet again too.
-- Planet rewards (rewards.lua) move what a planet gives you to build elsewhere (its planet-locked buildings) with the technology that gives it: the locks go through the lock stage, whose repairs cover them, and the technology's research trigger, science pack and discovery prerequisite follow.
-- All are checked against the game before them with the logic graph (check.lua).
-- None ever stops the game from loading: anything that goes wrong (including errors, for mod compatibility) undoes that stage instead.
-- Ocean swaps that fail their check are first rolled again with a new assignment a few times (OCEAN_TRIES).

-- Superposed mode (setting propertyrandomizer-planetary-superposed, config.planetary_superposed; see notes/old/context-shift-report): the swaps come with their root repairs (scaffolds.lua's fluid replacements, and the recipe and trigger edits that follow resource swaps) but no extra patches, and the game before them goes to the rest of randomization as debt (planetary.superposed)
-- Root repairs are fine as fixes though not as random choices (like water or lava taking a lost fluid's place), and they change what unified never changes, what processes a pumped fluid or mined resource
-- Promotion then keeps the goals the swaps still break while unified's choices pay for what they can (see skeleton/promotion.lua), and what's still owed after that is settled (planetary.settle); an attempt of the rest of randomization that still owes goals is retried with the changes rolled again (planetary.reroll, see data-final-fixes.lua), and what the kept attempt still lost is warned about in the randomizer panel (planetary.check_final)
-- Works with entity randomization too: its subdivided acquisition edges leave the debt edges as they are (on seeds 1-2, promotion added and skipped the same debt edges with it on as with it off)

-- Experimental start swap (the Gleba start experiment, like the old SWITCH_PLANETS): the starting planet swaps prototypes with the planet named here, so the game starts on that planet's content; nil for off
-- It runs in superposed mode (turned on with it), before the planetary changes that are on, and only if some planetary setting is on at all; only tried with "gleba", where first pass and promotion are left with a whole-game debt (seed 0: about 2700 owed goals, 21 still owed after settlement)
local SWAP_START_WITH = nil

-- Whether the rest of randomization keeps the recipe goals that moved with planetary changes (protection.transported_recipe_contexts), like a moved lock's recipe staying automatable on its new planet
-- Without it, unified changed a moved lock's recipe freely (it isn't planet-locked when its lock has two planets), so attempts kept losing those goals and were retried; putting the lock back after the attempt didn't help, since the recipe was broken on its old planet too
-- It used to make attempts fail on a moved item's recycling recipe becoming unreachable (like electromagnetic-plant-recycling): promised only on its new planet, the recipe gave up its earliest context, so its item's early pebbles broke and the recycling recipe was left reachable nowhere at its ranks
-- On since 2026-10-01, once such a recipe kept its earliest context too (state.required_contexts in randomizations/graph/unified/skeleton/promotion.lua): 12 of 12 unified-suite runs passed on their first attempt with no planetary losses
local PROTECT_TRANSPORTED = true

-- Whether discovery technologies follow the star map the connection graph draws (discovery.lua, run in draw_map_first)
-- Off: it works (sa/dupes-preview seeds 1-2 passed MECHCHECK, 2026-09-30) but every planet gets a home set of its own, and the lock stage and unified's attempts got so much slower that loads took about 5 times as long (seed 2: 38 instead of 7.5 minutes)
local DISCOVERY_FOLLOWS_MAP = false

local gutils = require("lib/graph/graph-utils")
local rng = require("lib/random/rng")
local dutils = require("lib/data-utils")
local lutils = require("lib/logic/logic-utils")
local top = require("lib/graph/context-sort")
local staged = require("lib/graph/staged-sort")
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
local connections = require("randomizations/planetary/connections")
local discovery = require("randomizations/planetary/discovery")
local rewards = require("randomizations/planetary/rewards")
local enemies = require("randomizations/planetary/enemies")
-- The check's rule 1 skips recipes a reward retired (rewards.bundle_of_retired)
planetary_check.is_retired = function(recipe_name)
    return rewards.bundle_of_retired(recipe_name) ~= nil
end

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

-- A planet's name for the randomizer panel, after its icon: its new name if it got one (lib/planet-names.lua), or else its prototype name
local function planet_label(planet_name)
    local planet = data.raw.planet[planet_name]
    local name = planet_name
    if planet ~= nil and type(planet.localised_name) == "string" then
        name = planet.localised_name
    end
    return "[img=space-location." .. planet_name .. "] " .. name
end

local function run_oceans(logic, state, old_raw)
    planetary_check.moved_features["oceans"] = true
    local assignment, clone_to_slot = oceans.execute("random", "planetary-oceans")
    local variants_of, after, past_limit = scaffolds.execute(assignment, oceans, logic, state.before, state.careful)
    -- Planets that would need a conversion past scaffolds.MAX_CONVERSIONS get their own oceans back (user, 2026-10-01: one conversion is the worst that should happen), and the swap is made again from the game before it
    -- Each round gives at least one more planet its own ocean back, so this ends
    local put_back = {}
    while past_limit ~= nil and #past_limit > 0 do
        assignment = table.deepcopy(assignment)
        for _, planet_name in pairs(past_limit) do
            assignment[planet_name] = planet_name
            table.insert(put_back, planet_name)
        end
        scaffolds.forget()
        data.raw = table.deepcopy(old_raw)
        log("Planetary oceans (planet <-- family), with " .. table.concat(put_back, ", ") .. " given their own oceans back: " .. serpent.line(assignment))
        clone_to_slot = oceans.apply(assignment)
        variants_of, after, past_limit = scaffolds.execute(assignment, oceans, logic, state.before, state.careful)
    end
    if #put_back > 0 then
        local labels = {}
        for _, planet_name in pairs(put_back) do
            table.insert(labels, planet_label(planet_name))
        end
        warn("ocean swaps", "left " .. table.concat(labels, ", ") .. " their own oceans, since each would have needed a recipe making its old ocean's fluid from its new one, and a game gets " .. scaffolds.MAX_CONVERSIONS .. " at most.")
    end
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

-- Whether the starting planet's copies give their biters to random planets too (enemies.move_biters)
-- Capturing a spawner (a mechanic) is then only kept on the starting planet, which keeps its own (user, 2026-10-01; the capture-spawner node's planetary_feature "biters" in lib/logic/abstract.lua)
local MOVE_BITERS = true

-- Moves demolisher territories (enemies.lua), and with MOVE_BITERS the starting planet's enemies off its copies, each as its own stage with its own feature (planetary_check.moved_features)
-- Nothing models demolishers as hazards, so a careful run's check only confirms nothing else broke
local function run_enemy_stage(feature, move)
    return function(logic, state)
        planetary_check.moved_features[feature] = true
        move()
        if not state.careful then
            state.after = nil
            return nil
        end
        state.after = planetary_check.sort(logic)
        if not planetary_check.required(state.before, state.after, state.variants_of) then
            return "a planet lost something it must keep (see PLANETCHECK in the log)"
        end
        return nil
    end
end
local run_demolishers = run_enemy_stage("demolishers", function()
    enemies.move_demolishers("planetary-demolishers")
end)
local run_biters = run_enemy_stage("biters", function()
    enemies.move_biters("planetary-biters")
end)

local function log_edits(edits, trigger_edits, variants)
    variants = variants or {}
    log("Planetary resources: " .. #edits .. " recipes edited, " .. #variants .. " planet variants and " .. #trigger_edits .. " technology triggers edited to follow the swap")
    for _, edit in pairs(edits) do
        log("Planetary resource edit: " .. resources.describe_edit(edit))
    end
    for _, plan in pairs(variants) do
        log("Planetary resource variant: " .. resources.describe_variant(plan))
    end
    for _, edit in pairs(trigger_edits) do
        log("Planetary resource trigger edit: " .. resources.describe_trigger_edit(edit))
    end
end

-- Swaps resources, and has the recipes and mining-triggered technologies belonging to one planet follow its swap (recipes a planet shares with its copies through planet variants)
-- The variants count as their originals for the checks (state.variants_of)
-- Returns what resources.execute does, then the recipe edits, the trigger edits and the variant plans
local function swap_resources(state)
    planetary_check.moved_features["resources"] = true
    local slots, assignment, lost = resources.execute("planetary-resources")

    -- Recipes belonging to one planet follow that planet's swap, including the ocean stage's planet variants
    local planet_recipes = {}
    for _, candidate in pairs(scaffolds.kept) do
        planet_recipes[candidate.planet] = planet_recipes[candidate.planet] or {}
        planet_recipes[candidate.planet][candidate.recipe_name] = true
    end
    local substitutions, alternates = resources.substitutions(slots, assignment, lost)
    local edits, variants = resources.edits(substitutions, state.before, planet_recipes, alternates)
    for _, edit in pairs(edits) do
        resources.add_edit(edit)
    end
    state.variants_of = state.variants_of or {}
    for _, plan in pairs(variants) do
        resources.add_variant(plan)
        state.variants_of[plan.recipe_name] = state.variants_of[plan.recipe_name] or {}
        table.insert(state.variants_of[plan.recipe_name], plan.variant.name)
    end
    if #variants > 0 then
        locks.realize()
    end
    -- So do technologies belonging to one planet that are researched by mining a resource it lost
    local trigger_edits = resources.trigger_edits(resources.replacements(slots, assignment, lost), state.before)
    for _, edit in pairs(trigger_edits) do
        resources.add_trigger_edit(edit)
    end
    return slots, assignment, lost, edits, trigger_edits, variants
end

-- The variants replace their originals on their planets (user, 2026-09-30), once the patches are chosen: each original stops accepting its variants' planets (resources.exclude_originals), except where a planet still needs it
-- A planet can need its original where its variant's new ingredient is harder to get from its own resources than the original's was, like uranium ore, which is mined with sulfuric acid (base/prototypes/entity/resources.lua).
-- So the goals that fail without the originals get them back through gates in a staged sort, one per original and planet, like the lock stage's "widen", and only the gates on their witnesses open.
-- If a goal fails even with every original back, the exclusions all go, leaving the game the patches were chosen for as it was.
-- Returns the excluded originals still excluded (resources.exclude_originals' entries, planet_rooms narrowed to those still excluded) and how many planets got an original back
local function exclude_originals(logic, state, variants)
    local excluded = resources.exclude_originals(variants)
    if #excluded == 0 then
        return {}, 0
    end
    locks.realize()
    local after = planetary_check.sort(logic)
    local failures = planetary_check.required_failures(state.before, after, state.variants_of)
    if #failures == 0 then
        return excluded, 0
    end
    local add = {}
    local include_of_gate = {}
    for _, entry in pairs(excluded) do
        local stop = gutils.key("recipe-surface-condition", entry.recipe_name)
        for _, room_key in pairs(sorted_keys(entry.planet_rooms)) do
            local start = gutils.key("room", room_key)
            table.insert(add, {
                start = start,
                stop = stop,
                stage = "include",
            })
            include_of_gate[start .. " --> " .. stop] = {
                entry = entry,
                room_key = room_key,
            }
        end
    end
    local staged_sort = staged.sort({
        graph = after.graph,
        stages = {
            "include",
        },
        add = add,
        extra = {
            complex_contexts = true,
            home_contexts = true,
            home_sets = planetary_check.home_sets,
        },
    })
    planetary_check.num_sorts = planetary_check.num_sorts + 1
    local with_all = {
        graph = staged_sort.graph,
        sort_info = staged_sort.sort_info,
    }
    if #planetary_check.required_failures(state.before, with_all, state.variants_of) > 0 then
        resources.include_originals(excluded)
        locks.realize()
        log("Planetary resources: the originals stay makeable beside their variants, since some planets can't do without them even with every original back")
        return {}, 0
    end
    local num_back = 0
    for _, gate in pairs(staged_sort.gates_on_witness(planetary_check.goal_inds(failures, with_all))) do
        local include = gate.kind == "add" and include_of_gate[gate.start .. " --> " .. gate.stop] or nil
        if include ~= nil and include.entry.planet_rooms[include.room_key] ~= nil then
            include.entry.planet_rooms[include.room_key] = nil
            local lock = locks.fixed["recipe/" .. include.entry.recipe_name]
            if lock ~= nil then
                lock.rooms[include.room_key] = true
            end
            num_back = num_back + 1
        end
    end
    local still = {}
    for _, entry in pairs(excluded) do
        if next(entry.planet_rooms) == nil then
            resources.include_originals({
                entry,
            })
        else
            table.insert(still, entry)
        end
    end
    locks.realize()
    return still, num_back
end

local function run_resources(logic, state)
    local slots, assignment, lost, edits, trigger_edits, variants = swap_resources(state)
    local excluded = {}

    -- What the swap still breaks without any extra patches
    local without = planetary_check.sort(logic)
    local failures = planetary_check.required_failures(state.before, without, state.variants_of)
    if #failures == 0 then
        local num_back
        excluded, num_back = exclude_originals(logic, state, variants)
        log_edits(edits, trigger_edits, variants)
        log("Planetary resources: " .. #excluded .. " originals replaced by their variants, " .. num_back .. " kept beside them where a planet still needs them; no extra patches needed")
        state.after = nil
        if state.careful == true then
            state.after = planetary_check.sort(logic)
            if #excluded > 0 and not planetary_check.required(state.before, state.after, state.variants_of, true) then
                resources.include_originals(excluded)
                locks.realize()
                state.after = planetary_check.sort(logic)
            end
        end
        return nil
    end
    for _, failure in pairs(failures) do
        log("Planetary resources: without extra patches, failing " .. failure.text)
    end

    -- Every extra patch that could help (each resource a planet lost), then only those the witnesses (earliest-provider paths) of what broke can't do without
    -- A patch is a planet's map placing the resource, which the logic has as an edge from the planet's autoplace node to the resource's entity (lib/logic/concrete.lua); those edges go behind a gate in a staged sort (lib/graph/staged-sort.lua) of the game without patches, so a witness goes through a patch only where the recipe edits, planet variants and new resources can't do it
    -- (A plain sort of the game with every patch kept whatever patch its witnesses happened to use, even where a variant did the same)
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
    logic.build(true, {
        home_sets = planetary_check.home_sets,
    })
    local repair_of_edge = {}
    local add = {}
    for _, repair in pairs(repairs) do
        local start = gutils.key("room-autoplace", gutils.key("planet", repair.planet_name))
        local stop = gutils.key("entity", repair.resource_name)
        for edge_key, edge in pairs(logic.graph.edges) do
            if edge.start == start and edge.stop == stop and without.graph.edges[edge_key] == nil then
                local extra = {}
                for field, value in pairs(edge) do
                    if field ~= "start" and field ~= "stop" and field ~= "object_type" then
                        extra[field] = table.deepcopy(value)
                    end
                end
                table.insert(add, {
                    start = start,
                    stop = stop,
                    extra = extra,
                    stage = "patch",
                })
                repair_of_edge[start .. " --> " .. stop] = repair
            end
        end
    end
    for _, repair in pairs(repairs) do
        resources.remove_repair(repair)
    end
    local staged_sort = staged.sort({
        graph = without.graph,
        stages = {
            "patch",
        },
        add = add,
        extra = {
            complex_contexts = true,
            home_contexts = true,
            home_sets = planetary_check.home_sets,
        },
    })
    planetary_check.num_sorts = planetary_check.num_sorts + 1
    local with_all = {
        graph = staged_sort.graph,
        sort_info = staged_sort.sort_info,
    }
    local used = {}
    for _, gate in pairs(staged_sort.gates_on_witness(planetary_check.goal_inds(failures, with_all))) do
        if gate.kind == "add" then
            local repair = repair_of_edge[gate.start .. " --> " .. gate.stop]
            if repair ~= nil then
                used[repair] = true
            end
        end
    end
    local kept = {}
    for _, repair in pairs(repairs) do
        if used[repair] ~= nil then
            resources.add_repair(repair)
            table.insert(kept, repair)
        end
    end
    local num_back
    excluded, num_back = exclude_originals(logic, state, variants)
    local function log_kept()
        log_edits(edits, trigger_edits, variants)
        if #variants > 0 then
            local num_planets = 0
            for _, entry in pairs(excluded) do
                for _, _ in pairs(entry.planet_rooms) do
                    num_planets = num_planets + 1
                end
            end
            log("Planetary resources: " .. #excluded .. " originals replaced by their variants on " .. num_planets .. " planets, " .. num_back .. " kept beside them where a planet still needs them")
        end
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
    if #excluded > 0 and not planetary_check.required(state.before, state.after, state.variants_of, true) then
        -- The originals the variants replace may be what's missing, so they come back first
        resources.include_originals(excluded)
        locks.realize()
        excluded = {}
        num_back = 0
        state.after = planetary_check.sort(logic)
    end
    if not planetary_check.required(state.before, state.after, state.variants_of, true) then
        -- The witnesses missed something, so try every extra patch
        for _, repair in pairs(repairs) do
            resources.add_repair(repair)
        end
        kept = repairs
        state.after = planetary_check.sort(logic)
        if not planetary_check.required(state.before, state.after, state.variants_of, true) then
            -- The edits themselves may be what's in the way (like a new ingredient only a later drill can mine), so try the original recipes and technology triggers
            log("Planetary resources: every extra patch still wasn't enough, so trying without recipe and trigger edits and planet variants")
            for _, edit in pairs(edits) do
                resources.remove_edit(edit)
            end
            for _, edit in pairs(trigger_edits) do
                resources.remove_trigger_edit(edit)
            end
            resources.include_originals(excluded)
            excluded = {}
            for _, plan in pairs(variants) do
                resources.remove_variant(plan)
                local names = state.variants_of[plan.recipe_name] or {}
                for i = #names, 1, -1 do
                    if names[i] == plan.variant.name then
                        table.remove(names, i)
                    end
                end
            end
            if #variants > 0 then
                locks.realize()
            end
            edits = {}
            trigger_edits = {}
            variants = {}
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

-- Moves planet locks (locks.lua), whose recipes' goals follow them (check.transport), then fixes what they break, with a staged sort (lib/graph/staged-sort.lua) whose gates hold the possible repairs: every lock accepting its old planets again ("widen"), and every moved reward's technology asking for its old trigger again ("tie"; the technology-trigger node of lib/logic/concrete.lua makes that an added edge)
--   1. With every gate open, nothing a planet must keep is lost to the moves, so a moved recipe still failing its own goals can't be reached at all, or isn't automatable on its new planet even with imports: it keeps its old lock (a revert).
--   2. The sort prefers what the moves left and goes through a gate only where nothing else works, so the gates on the witnesses (earliest-provider paths) of what broke are the repairs really needed: a lock whose old planet needs it (for its science, planet-locked recipes that didn't move, or mechanics) accepts that planet again, and a reward's technology whose old planet needs it keeps its old ties (the reward is then shared); the other locks and technologies stay moved.
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

-- Forgets the goal transport of a bundle rewards.revert_bundle put back (its locks' recipes and its variants' originals), returning the entries for rewards.redo_bundle
local function forget_reward_transport(undo)
    local entries = {}
    for _, lock in pairs(undo.reverted) do
        if lock.kind == "recipe" then
            local recipe_key = gutils.key("recipe", lock.name)
            entries[recipe_key] = planetary_check.transport[recipe_key]
            planetary_check.transport[recipe_key] = nil
        end
    end
    for recipe_name, _ in pairs(undo.bundle.variants) do
        local recipe_key = gutils.key("recipe", recipe_name)
        entries[recipe_key] = planetary_check.transport[recipe_key]
        planetary_check.transport[recipe_key] = nil
    end
    return entries
end

-- Rewards move first (their locks then count as moved on purpose, which the random lock moves skip), then the random lock moves
-- The optional logic (outside superposed mode) sorts the game as the earlier stages left it, in which re-homing finds what each planet's science needs
local function move_locks(state, logic)
    planetary_check.moved_features["locks"] = true
    if config.planetary_rewards then
        state.variants_of = state.variants_of or {}
        -- Outside superposed mode nothing later pays for what a machine's old planet loses, so the move re-homes its science into the machine arriving there (see science_needs and rehome_plan in rewards.lua)
        -- What a planet's science needs is found in the game as the earlier stages (resource and ocean swaps) left it, since those can change how a planet makes it
        local rehome = config.planetary_rewards_rehome and not config.planetary_superposed and logic ~= nil
        rewards.execute("planetary-rewards", state.before, state.variants_of, {
            rehome = rehome,
            current = rehome and planetary_check.sort(logic) or nil,
        })
        rewards.log_moves()
    end
    if config.planetary_locks then
        locks.execute("planetary-locks", planet_variants(state))
    end
    for node_key, entry in pairs(locks.transport()) do
        planetary_check.transport[node_key] = entry
    end
    for node_key, entry in pairs(rewards.transport()) do
        planetary_check.transport[node_key] = entry
    end
end

local function run_locks(logic, state)
    move_locks(state, logic)

    local without = planetary_check.sort(logic)
    local failures = planetary_check.required_failures(state.before, without, state.variants_of)
    if #failures == 0 then
        log_locks()
        state.after = without
        return nil
    end
    log("Planet locks: " .. #failures .. " failures before repairs")
    local failure_texts = {}
    for _, failure in pairs(failures) do
        table.insert(failure_texts, failure.text)
    end
    table.sort(failure_texts)
    for i = 1, math.min(40, #failure_texts) do
        log("Planet locks: failing before repairs: " .. failure_texts[i])
    end
    -- Why the first few unreachable recipes can't be reached, moved recipes first: the unreachable prerequisites under them (debugging aid, like first pass's)
    local unreachable = {}
    for _, failure in pairs(failures) do
        if failure.context == nil then
            table.insert(unreachable, failure)
        end
    end
    table.sort(unreachable, function(a, b)
        local a_moved = locks.lock_of_recipe(a.keys[1]) ~= nil
        local b_moved = locks.lock_of_recipe(b.keys[1]) ~= nil
        if a_moved ~= b_moved then
            return a_moved
        end
        return a.text < b.text
    end)
    local num_explained = 0
    for _, failure in pairs(unreachable) do
        if num_explained < 6 then
            num_explained = num_explained + 1
            local reached = without.sort_info.node_to_context_inds
            local seen = {}
            local function explain(node_key, depth)
                if depth > 14 or seen[node_key] ~= nil then
                    return
                end
                seen[node_key] = true
                local node = without.graph.nodes[node_key]
                if node == nil or next(reached[node_key] or {}) ~= nil then
                    return
                end
                log("Planet locks: " .. string.rep("  ", depth) .. node_key .. " (" .. tostring(node.op) .. ") unreachable")
                for pre, _ in pairs(node.pre) do
                    local prekey = without.graph.edges[pre].start
                    if next(reached[prekey] or {}) == nil then
                        explain(prekey, depth + 1)
                        if node.op == "AND" then
                            break
                        end
                    end
                end
            end
            explain(failure.keys[1], 0)
        end
    end

    -- The gates: every lock accepting its old planets again, and every substituted research trigger asking for what it did as well
    local new_rooms = {}
    local add = {}
    for id, lock in pairs(locks.moved) do
        new_rooms[id] = lock.rooms
        for room_key, _ in pairs(lock.old) do
            if lock.rooms[room_key] == nil then
                table.insert(add, {
                    start = gutils.key("room", room_key),
                    stop = lock.node_key,
                    stage = "widen",
                })
            end
        end
    end
    local tie_of_edge = {}
    for _, edge in pairs(rewards.tie_edges()) do
        table.insert(add, {
            start = edge.start,
            stop = edge.stop,
            stage = "tie",
        })
        tie_of_edge[gutils.ekey(edge)] = edge
    end
    local staged_sort = staged.sort({
        graph = without.graph,
        stages = {
            "widen",
            "tie",
        },
        add = add,
        extra = {
            complex_contexts = true,
            home_contexts = true,
            home_sets = planetary_check.home_sets,
        },
    })
    planetary_check.num_sorts = planetary_check.num_sorts + 1
    local with_all = {
        graph = staged_sort.graph,
        sort_info = staged_sort.sort_info,
    }

    -- 1. Moved recipes whose own goals still fail keep their old locks
    local to_revert = {}
    -- Rooms where something still fails with every gate open (a reward's original recipe that left for a variant has no gate, see below)
    local unfixed_rooms = {}
    for _, failure in pairs(planetary_check.required_failures(state.before, with_all, state.variants_of)) do
        local lock, id = locks.lock_of_recipe(failure.keys[1])
        if lock ~= nil then
            to_revert[id] = to_revert[id] or {}
            table.insert(to_revert[id], failure.text)
        else
            log("Planet locks: still failing with every lock widened: " .. failure.text)
            if failure.context ~= nil then
                unfixed_rooms[top.context_room(failure.context)] = true
            end
        end
    end
    local reverted = locks.revert(sorted_keys(to_revert))
    local reverted_recipes = {}
    for _, id in pairs(sorted_keys(reverted)) do
        table.sort(to_revert[id])
        log("Planet locks: " .. id .. " keeps its old lock, since its own goals fail on its new planets: " .. table.concat(to_revert[id], ", ", 1, math.min(4, #to_revert[id])))
        local recipe_key = gutils.key("recipe", reverted[id].name)
        planetary_check.transport[recipe_key] = nil
        reverted_recipes[recipe_key] = true
    end
    for _, undo in pairs(rewards.sync()) do
        forget_reward_transport(undo)
    end

    -- 2. Keep only the repairs the witnesses of what broke go through (reverted recipes' own goals aside)
    local rest = {}
    for _, failure in pairs(failures) do
        if reverted_recipes[failure.keys[1]] == nil then
            table.insert(rest, failure)
        end
    end
    local used = {}
    -- Reward bundles the witnesses need back on their old planets (a member's lock accepting its old planet again, or its technology asking for its old ties): each goes back entirely (user, 2026-09-30: a revert rather than a share), with why, for the log
    local needed_bundles = {}
    -- One witness walk for all of them; the log doesn't say which goals needed each repair, since a walk per goal for that took minutes with thousands of failures (user, 2026-09-30: cut it)
    if #rest > 0 then
        for _, gate in pairs(staged_sort.gates_on_witness(planetary_check.goal_inds(rest, with_all))) do
            if gate.kind == "add" and gate.stage == "widen" then
                local lock, id = locks.lock_of_node(gate.stop)
                if lock ~= nil then
                    local _, bundle_id = rewards.bundle_of_lock(id)
                    if bundle_id ~= nil then
                        needed_bundles[bundle_id] = ""
                    else
                        used[id] = used[id] or {}
                        used[id][gutils.deconstruct(gate.start).name] = true
                    end
                end
            elseif gate.kind == "add" and gate.stage == "tie" then
                local edge = tie_of_edge[gutils.ekey(gate)]
                if edge ~= nil and rewards.moved[edge.bundle_id] ~= nil then
                    needed_bundles[edge.bundle_id] = ""
                end
            end
        end
    end
    -- A reward whose recipes got variants has no gate for its old planet (its retired original has no edge of this graph to come back through): where that planet still fails something with every gate open, it goes back too
    for _, bundle_id in pairs(sorted_keys(rewards.moved)) do
        local bundle = rewards.moved[bundle_id]
        if needed_bundles[bundle_id] == nil and next(bundle.variants) ~= nil then
            for _, room_key in pairs(sorted_keys(bundle.planets)) do
                if unfixed_rooms[room_key] ~= nil then
                    needed_bundles[bundle_id] = " (something on " .. room_key .. " still fails with every lock widened)"
                end
            end
        end
    end
    for _, bundle_id in pairs(sorted_keys(needed_bundles)) do
        local bundle = rewards.moved[bundle_id]
        if bundle ~= nil then
            forget_reward_transport(rewards.revert_bundle(bundle_id))
            log("Planet reward: " .. bundle.source_tech .. " stays, since its old planet needs it" .. needed_bundles[bundle_id])
        end
    end
    for _, undo in pairs(rewards.sync()) do
        forget_reward_transport(undo)
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
        rewards.log_state()
        state.after = nil
        return nil
    end
    state.after = planetary_check.sort(logic)
    if not planetary_check.required(state.before, state.after, state.variants_of, true) then
        -- The witnesses missed something, so every reward goes back and every other lock accepts its old planets again
        for _, bundle_id in pairs(sorted_keys(rewards.moved)) do
            local bundle = rewards.moved[bundle_id]
            forget_reward_transport(rewards.revert_bundle(bundle_id))
            log("Planet reward: " .. bundle.source_tech .. " stays, since the witnesses missed something")
        end
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
    rewards.log_state()
    return nil
end

-- Moves lightning (lightning.lua), its goals following it (and the attractor recipes' locks, which lightning.execute moved), without any repair
-- Returns the planets that gave their lightning away, old planet --> new planet (empty if none did)
local function move_lightning(state)
    local map = lightning.execute("planetary-lightning")
    if next(map) == nil then
        log("Planetary lightning: no planet gave its lightning away")
        return map
    end
    planetary_check.moved_features["lightning"] = true
    for node_key, entry in pairs(lightning.transport(state.before.graph, map)) do
        planetary_check.transport[node_key] = entry
    end
    for node_key, entry in pairs(locks.transport()) do
        planetary_check.transport[node_key] = entry
    end
    log("Planetary lightning: " .. lightning.describe())
    return map
end

-- Moves lightning with what builds lightning attractors (lightning.lua); lightning power's goals follow it (check.transport)
-- If a planet then loses something it must keep (like electricity from its own resources, which lightning was), each planet that gave lightning away keeps it as well (an addition)
local function run_lightning(logic, state)
    local map = move_lightning(state)
    if next(map) == nil then
        return nil
    end

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

-- Draws a new graph of space connections (connections.lua); undone if a planet then lacks something it must keep, which the templates from the same orbits should keep from happening
local function run_connections(logic, state)
    log("Planetary connections: " .. connections.execute("planetary-connections"))
    if not state.careful then
        state.after = nil
        return nil
    end
    state.after = planetary_check.sort(logic)
    if not planetary_check.required(state.before, state.after, state.variants_of, false, "PLANETCHECK connections") then
        return "a planet lost something it must keep with the new connections (see PLANETCHECK in the log)"
    end
    return nil
end

-- The recipe and technology nodes reachable in the current game, by a plain sort (no contexts)
local function reachable_nodes(logic)
    logic.build(true, {
        home_sets = planetary_check.home_sets,
    })
    local sort_info = top.sort(logic.graph)
    local reachable = {}
    for node_key, contexts in pairs(sort_info.node_to_context_inds or {}) do
        local node = logic.graph.nodes[node_key]
        if next(contexts) ~= nil and node ~= nil and (node.type == "recipe" or node.type == "technology") then
            reachable[node_key] = true
        end
    end
    return reachable
end

-- Discovery technologies follow the star map the connection graph drew (discovery.lua), as part of drawing the map first (see draw_map_first)
-- The new order changes which planets come before which, so it isn't checked against what planets had before it (their home sets were the old order's); it's undone if it leaves anything out of reach, like a discovery that waits on itself through a planet before it whose packs need it
local function run_discovery(logic, state)
    local before = reachable_nodes(logic)
    log("Planetary discovery: " .. discovery.execute())
    local after = reachable_nodes(logic)
    local lost = {}
    for node_key, _ in pairs(before) do
        if after[node_key] == nil then
            table.insert(lost, node_key)
        end
    end
    table.sort(lost)
    if #lost > 0 then
        return "a discovery waited on itself, leaving " .. #lost .. " recipes and technologies out of reach (" .. table.concat(lost, ", ", 1, math.min(#lost, 10)) .. ")"
    end
    state.after = nil
    return nil
end

-- Moves freezing (freezing.lua) without any repair; returns the planets that gave their freezing away (empty if none did)
local function move_freezing()
    local map = freezing.execute("planetary-freezing")
    if next(map) == nil then
        log("Planetary freezing: no planet gave its freezing away")
        return map
    end
    planetary_check.moved_features["freezing"] = true
    log("Planetary freezing: " .. freezing.describe())
    -- A heat source delivered to a planet that now freezes counts as local there if the planet can then make more (lib/logic/bootstrap.lua)
    lutils.bootstrap_heat_rooms = freezing.new_frozen_rooms()
    return map
end

-- Moves freezing with the technologies for heating (freezing.lua)
-- A planet that stops freezing only gains warmth, so whatever fails is on a planet that now freezes, and keeping the old planet frozen as well wouldn't help: the stage is undone instead
local function run_freezing(logic, state)
    if next(move_freezing()) == nil then
        return nil
    end
    state.after = planetary_check.sort(logic)
    if not planetary_check.required(state.before, state.after, state.variants_of, false, "PLANETCHECK freezing") then
        return "a planet that freezes now lost something it must keep (see PLANETCHECK freezing in the log)"
    end
    return nil
end

-- How many different assignments a careful run tries for ocean swaps before undoing them: a failed ocean swap is rare, so rolling again usually works
-- Each try costs a few sorts, so this stays small to keep startup time down
local OCEAN_TRIES = 3

-- Runs a stage, undoing it (data.raw and the shared state back to how they were) if it fails or errors
-- With can_retry, a failed check (but not an error, which would likely repeat) is only logged, and the caller runs the stage again
-- Returns whether the stage worked, and whether it's worth running again
local function run_stage(what, stage, logic, state, can_retry)
    local old_raw = table.deepcopy(data.raw)
    local old_state = {
        after = state.after,
        variants_of = state.variants_of,
    }
    local old_moved_features = table.deepcopy(planetary_check.moved_features)
    local old_transport = table.deepcopy(planetary_check.transport)
    local old_locks = locks.moved
    local old_rewards = rewards.moved
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
        rewards.moved = old_rewards
        lutils.bootstrap_heat_rooms = old_bootstrap_heat_rooms
        if can_retry and is_ok then
            log("Planetary " .. what .. ": rolling again, since " .. reason)
            return false, true
        end
        warn(what, "were undone, since " .. reason .. ".")
        return false, false
    end
    return true, false
end

-- The planetary fix pass (config.planetary_fix_pass, randomizations/planetary/fix-pass.lua): what took each planet's old things' places in the stages' moves, planet --> old node key --> new node key, which the fix pass repairs with first (like the ore that took a lost ore's place)
planetary.replacements = {}

local function add_replacement(planet_name, old_key, new_key)
    planetary.replacements[planet_name] = planetary.replacements[planet_name] or {}
    planetary.replacements[planet_name][old_key] = new_key
end

-- Swaps resources without the recipe and trigger edits, planet variants and extra patches that follow the swap (swap_resources, run_resources), for the fix pass to repair first; returns nil
local function move_resources()
    planetary_check.moved_features["resources"] = true
    local slots, assignment, lost = resources.execute("planetary-resources")
    -- What took each lost resource's place: its mined product for ingredients, the resource itself for mining triggers
    for planet_name, subs in pairs(resources.substitutions(slots, assignment, lost)) do
        for _, sub in pairs(subs) do
            add_replacement(planet_name, gutils.key(sub.from.type, sub.from.name), gutils.key(sub.to.type, sub.to.name))
        end
    end
    for planet_name, reps in pairs(resources.replacements(slots, assignment, lost)) do
        for lost_name, new_name in pairs(reps) do
            add_replacement(planet_name, gutils.key("entity-mine", lost_name), gutils.key("entity-mine", new_name))
        end
    end
    return nil
end

-- Runs a stage fix pass first (config.planetary_fix_pass; the user, 2026-09-30: "try fixes through prereq shuffle methods first and then the old way")
-- The stage's move without its own repairs (move, returning a problem or nil), then fix (the fix pass, returning how many goals are still lost); the game is clean before each stage, so what's lost is this stage's
-- If the fix pass can't repair everything (or errors), the stage is undone and runs the old way (old_way: the stage with its own repairs, which undoes it in turn if those aren't enough)
-- The random streams are put back too, so the old way repairs the same move the fix pass couldn't
local function run_fix_first(what, move, old_way, logic, state, fix)
    local old_raw = table.deepcopy(data.raw)
    local old_streams = table.deepcopy(rng.prgs)
    local saved = {
        variants_of = table.deepcopy(state.variants_of),
        moved_features = table.deepcopy(planetary_check.moved_features),
        goal_transport = table.deepcopy(planetary_check.transport),
        locks_moved = table.deepcopy(locks.moved),
        locks_fixed = table.deepcopy(locks.fixed),
        bootstrap_heat_rooms = lutils.bootstrap_heat_rooms,
        replacements = table.deepcopy(planetary.replacements),
    }
    local is_ok, result = pcall(function()
        local problem = move(logic, state, old_raw)
        if problem ~= nil then
            return problem
        end
        log("Planetary " .. what .. ": moved without their own repairs, so the fix pass repairs them first")
        return fix(state)
    end)
    if is_ok and result == 0 then
        log("Planetary " .. what .. ": the fix pass repaired them")
        state.after = nil
        return
    end
    data.raw = old_raw
    state.variants_of = saved.variants_of
    planetary_check.moved_features = saved.moved_features
    planetary_check.transport = saved.goal_transport
    locks.moved = saved.locks_moved
    locks.fixed = saved.locks_fixed
    lutils.bootstrap_heat_rooms = saved.bootstrap_heat_rooms
    planetary.replacements = saved.replacements
    for stream_key, _ in pairs(rng.prgs) do
        rng.prgs[stream_key] = nil
    end
    for stream_key, stream in pairs(old_streams) do
        rng.prgs[stream_key] = stream
    end
    local reason
    if not is_ok then
        reason = "the fix pass stopped on an error (" .. tostring(result) .. ")"
    elseif type(result) == "string" then
        reason = result
    else
        reason = "the fix pass left " .. result .. " goals lost"
    end
    log("Planetary " .. what .. ": " .. reason .. ", so they're undone and run the old way")
    old_way()
end

-- Runs every stage that's on; with careful, each stage checks its own result (see state above)
-- With fix (the planetary fix pass, see run_fix_first), the stages it repairs (resource swaps, lightning and freezing moves) run fix pass first and then the old way; the connection graph, ocean swaps and locks run the old way
local function run_stages(logic, state, careful, fix)
    state.careful = careful
    -- Outside superposed mode the map was drawn first (draw_map_first)
    if config.planetary_connections and state.map_first ~= true then
        local problem = old_graph_problem() or connections.problem()
        if connections.nothing_to_do() then
            log("Planetary connections: no space connections to draw again")
        elseif problem ~= nil then
            warn("connection graph", "was skipped, since " .. problem .. ".")
        else
            run_stage("connection graph", run_connections, logic, state)
        end
    end
    if config.planetary_oceans then
        local problem = oceans.problem()
        if problem ~= nil then
            warn("ocean swaps", "were skipped, since " .. problem .. ".")
        else
            local function old_way()
                -- Only a careful run checks the swap itself, so only it can tell that an assignment failed and roll a new one
                local num_tries = careful and OCEAN_TRIES or 1
                for try = 1, num_tries do
                    local is_done, should_retry = run_stage("ocean swaps", run_oceans, logic, state, try < num_tries)
                    if is_done then
                        break
                    end
                    scaffolds.forget()
                    if not should_retry then
                        break
                    end
                end
            end
            -- Ocean swaps keep their scaffolds even with the fix pass (user, 2026-10-01): a few targeted recipe variants in about 2 s, where the fix pass took 12-94 s for broader changes (like the foundry taking sulfur) and still left goals for the scaffolds
            old_way()
        end
    end
    if config.planetary_resources then
        local function old_way()
            run_stage("resource swaps", run_resources, logic, state)
        end
        if fix ~= nil then
            run_fix_first("resource swaps", move_resources, old_way, logic, state, fix)
        else
            old_way()
        end
    end
    if config.planetary_lightning then
        local problem = old_graph_problem() or lightning.problem()
        if problem ~= nil then
            warn("lightning moves", "were skipped, since " .. problem .. ".")
        else
            local function old_way()
                run_stage("lightning moves", run_lightning, logic, state)
            end
            if fix ~= nil then
                run_fix_first("lightning moves", function(_, stage_state)
                    move_lightning(stage_state)
                    return nil
                end, old_way, logic, state, fix)
            else
                old_way()
            end
        end
    end
    if config.planetary_freezing then
        local problem = old_graph_problem() or freezing.problem()
        if problem ~= nil then
            warn("freezing moves", "were skipped, since " .. problem .. ".")
        else
            local function old_way()
                run_stage("freezing moves", run_freezing, logic, state)
            end
            if fix ~= nil then
                run_fix_first("freezing moves", function()
                    move_freezing()
                    return nil
                end, old_way, logic, state, fix)
            else
                old_way()
            end
        end
    end
    if config.planetary_enemies then
        run_stage("demolisher moves", run_demolishers, logic, state)
        if MOVE_BITERS then
            run_stage("biter moves", run_biters, logic, state)
        end
    end
    if config.planetary_locks or config.planetary_rewards then
        local what = config.planetary_locks and "planet locks" or "planet rewards"
        if old_graph_problem() ~= nil then
            warn(what, "were skipped, since " .. old_graph_problem() .. ".")
        else
            run_stage(what, run_locks, logic, state)
        end
    end
end

-- Draws the star map first, outside superposed mode: the connection graph (checked like any stage, against the game before it) and, with DISCOVERY_FOLLOWS_MAP, the discovery order that follows it (run_discovery), and then the game they make is the one the other stages are checked against, sorted again with home sets of its own
-- The map can change which planets come before which (a far planet's route passes planets that need other planets' packs), which the old home sets don't know (see top.home_sets), so the other stages couldn't be checked against the old game with its home sets
-- state.before becomes the map's game, and state.map_first keeps run_stages from drawing the graph again
local function draw_map_first(logic, state)
    state.map_first = true
    if connections.nothing_to_do() then
        log("Planetary connections: no space connections to draw again")
        return
    end
    local problem = old_graph_problem() or connections.problem()
    if problem ~= nil then
        warn("connection graph", "was skipped, since " .. problem .. ".")
        return
    end
    state.careful = true
    local is_drawn = run_stage("connection graph", run_connections, logic, state)
    if not is_drawn then
        return
    end
    if DISCOVERY_FOLLOWS_MAP then
        local discovery_problem = discovery.problem()
        if discovery_problem ~= nil then
            warn("discovery technologies", "were skipped, since " .. discovery_problem .. ".")
        else
            run_stage("discovery technologies", run_discovery, logic, state)
        end
    end
    planetary_check.home_sets = nil
    state.before = planetary_check.sort(logic)
    state.after = nil
end

-- The game before planetary changes as debt for promotion (see superposed mode at the top), or nil
-- It's promotion's params.debt: { graph, debt_edges and old_nodes (from superpose.union), is_goal = whether a pebble is one of the goals the swaps carry over in an exact context (check.transported_goals), goals = those goals }
planetary.superposed = nil

-- The start swap (SWAP_START_WITH): the starting planet and the other swap their prototypes, so everything local to each goes to the other and the game starts on the other's content
-- The planetary changes that are on then run on the swapped planets, and their own goal transports replace this one for their nodes
-- Goals follow their planet's content (keeping their abilities), except the starting planet's science packs (lab inputs isolatable on the start in the game before) and nodes whose names mention either planet, which stay (experimental: a name match, not a declared property)
local function swap_start(state)
    local start_name = lutils.starting_planet_name
    local other_name = SWAP_START_WITH
    local start = data.raw.planet[start_name]
    local other = data.raw.planet[other_name]
    if start == nil or other == nil or start_name == other_name then
        warn("start swap", "was skipped, since there's no other planet " .. other_name .. " to swap the start with.")
        return
    end
    data.raw.planet[start_name] = table.deepcopy(other)
    data.raw.planet[start_name].name = start_name
    data.raw.planet[other_name] = table.deepcopy(start)
    data.raw.planet[other_name].name = other_name
    log("Planetary superposed: " .. start_name .. " and " .. other_name .. " swapped their prototypes (SWAP_START_WITH)")
    local start_room = gutils.key("planet", start_name)
    local other_room = gutils.key("planet", other_name)
    local before_nci = state.before.sort_info.node_to_context_inds
    local stays = {}
    local starting_packs = {}
    for pack_name, _ in pairs(dutils.lab_inputs()) do
        local node_key = gutils.key("item", pack_name)
        for context, _ in pairs(before_nci[node_key] or {}) do
            if top.context_room(context) == start_room and top.context_home(context) == nil and protection.is_isolatable_context(context) and stays[node_key] == nil then
                stays[node_key] = true
                table.insert(starting_packs, pack_name)
            end
        end
    end
    table.sort(starting_packs)
    log("Planetary superposed: starting science packs that stay: " .. table.concat(starting_packs, ", "))
    local num_transported = 0
    for node_key, node in pairs(state.before.graph.nodes) do
        local room_bound = string.find(node.name or "", start_name, 1, true) ~= nil or string.find(node.name or "", other_name, 1, true) ~= nil
        if not stays[node_key] and not room_bound then
            planetary_check.transport[node_key] = {
                map = {
                    [start_room] = other_room,
                    [other_room] = start_room,
                },
                keep_isolatability = true,
            }
            num_transported = num_transported + 1
        end
    end
    log("Planetary superposed: " .. num_transported .. " nodes' goals follow their planet")
end

-- Superposed mode: runs every swap that's on raw, then superposes the game before them on the game after
-- The connection graph for superposed mode, drawn before the reference sort: routes are a plain change with nothing to repair, and if the routes it replaces stayed in the superposition as debt, the goals only they had (like their asteroids) could never be paid, since the game no longer has those routes, so every attempt would still owe them
-- Like every stage, it never stops the game from loading: an error undoes it
local function draw_connections_first()
    if connections.nothing_to_do() then
        log("Planetary connections: no space connections to draw again")
        return
    end
    local problem = old_graph_problem() or connections.problem()
    if problem ~= nil then
        warn("connection graph", "was skipped, since " .. problem .. ".")
        return
    end
    local old_raw = table.deepcopy(data.raw)
    local is_drawn, result = pcall(connections.execute, "planetary-connections")
    if is_drawn then
        log("Planetary connections: " .. result)
    else
        data.raw = old_raw
        warn("connection graph", "was undone, since of an error: " .. tostring(result) .. ".")
    end
end

local function run_superposed(logic, state)
    if SWAP_START_WITH ~= nil then
        swap_start(state)
    end
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
        local _, _, _, edits, trigger_edits, variants = swap_resources(state)
        log_edits(edits, trigger_edits, variants)
    end
    if config.planetary_lightning and old_graph_problem() == nil and lightning.problem() == nil then
        local map = lightning.execute("planetary-lightning")
        if next(map) ~= nil then
            planetary_check.moved_features["lightning"] = true
            for node_key, entry in pairs(lightning.transport(state.before.graph, map)) do
                planetary_check.transport[node_key] = entry
            end
            -- The attractor recipes' locks moved with lightning (locks.move), so their goals follow them to the new planet, as run_lightning does
            for node_key, entry in pairs(locks.transport()) do
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
    if (config.planetary_locks or config.planetary_rewards) and old_graph_problem() == nil then
        move_locks(state)
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
        local num_explained = 0
        for _, failure in pairs(planetary_check.required_failures(state.before, union_sort, state.variants_of)) do
            local lock, id = locks.lock_of_recipe(failure.keys[1])
            if lock ~= nil then
                to_revert[id] = true
                -- Why not, for the first few (debugging aid, the settlement's explain walk)
                if num_explained < 6 then
                    num_explained = num_explained + 1
                    settlement.explain(union.graph, union_sort.sort_info, failure)
                end
            end
        end
        if next(to_revert) ~= nil then
            local reverted = locks.revert(sorted_keys(to_revert))
            for _, id in pairs(sorted_keys(reverted)) do
                log("Planet locks: " .. id .. " keeps its old lock, since even the superposition doesn't reach its own goals on its new planets")
                planetary_check.transport[gutils.key("recipe", reverted[id].name)] = nil
            end
            for _, undo in pairs(rewards.sync()) do
                forget_reward_transport(undo)
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
            local node_goals = goals[node_key]
            if node_goals == nil then
                return false
            end
            if node_goals[context] ~= nil then
                return true
            end
            -- An isolatable pebble stands for its goal without isolatability too (see top.provides_context)
            return top.context_home(context) == nil and protection.is_isolatable_context(context) and node_goals[protection.without_isolatability(context)] ~= nil
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

-- What the end of planetary.execute does once the stages ran (and planetary.run_pending, with the fix pass): the home sets checked again if the changes moved them (undoing everything back to old_raw if they fail with them), the final planetary check, and the game before the changes kept for the checks after randomization
local function finish(state, old_raw)
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
            rewards.moved = {}
            lutils.bootstrap_heat_rooms = {}
            scaffolds.kept = {}
            warn("changes", "were undone, since " .. (is_ok and "they changed which planets discoveries need, and fail with the home sets both games agree on (see PLANETCHECK home sets in the log)" or "of an error: " .. tostring(passes)) .. ".")
        end
    end
    if state.after ~= nil then
        planetary_check.run(state.before, state.after)
    end
    log("Planetary: " .. planetary_check.num_sorts .. " sorts")
    scaffolds.log_conversions()
    resources.log_extra_patches()
    -- Moved features are the stages whose changes are still in the game
    if next(planetary_check.moved_features) ~= nil then
        planetary.before = {
            sort = state.before,
            variants_of = state.variants_of,
        }
        -- Goals the stages lost as spare versions of duplicated buildings stay given up, since the rest of randomization starts without them (planetary_check.given_up)
        if state.after ~= nil then
            local given_up = planetary_check.give_up_spare(state.before, state.after, state.variants_of)
            log("Planetary: " .. #given_up .. " goals of duplicated buildings another version covers were given up, so later checks don't ask for them")
            for i = 1, math.min(#given_up, 12) do
                log("Planetary: given up " .. given_up[i])
            end
        end
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

-- logic is the logic module (lib/logic/init), rebuilt from data.raw for each check
planetary.execute = function(logic)
    local state = {
        variants_of = {},
    }
    -- The first sort sets the home sets every later one uses
    planetary_check.home_sets = nil
    planetary_check.num_sorts = 0
    -- With the fix pass, a planet may build rockets with machines delivered once, and recipe categories aren't goals of their own (the planetary check's rule 3)
    planetary_check.rocket_machines_importable = config.planetary_fix_pass == true
    planetary_check.skip_recipe_categories = config.planetary_fix_pass == true
    -- In superposed mode the connection graph is drawn before the game before the changes is sorted, so it's part of that reference world (see draw_connections_first)
    if (config.planetary_superposed or SWAP_START_WITH ~= nil) and config.planetary_connections then
        draw_connections_first()
    end
    local is_ok = pcall(function()
        state.before = planetary_check.sort(logic)
    end)
    if not is_ok then
        warn("changes", "were skipped, since the logic couldn't be sorted.")
        return
    end
    -- Outside superposed mode the star map comes first, and the rest is checked against the game it makes (see draw_map_first)
    if not (config.planetary_superposed or SWAP_START_WITH ~= nil) and config.planetary_connections then
        local is_drawn, problem = pcall(draw_map_first, logic, state)
        if not is_drawn then
            warn("changes", "were skipped, since of an error: " .. tostring(problem) .. ".")
            return
        end
    end

    -- Planet rewards first log every bundle of the game before any change (rewards.lua), then the reward bundles move with the lock stage (move_locks)
    if config.planetary_rewards then
        local is_logged, problem = pcall(rewards.log, state.before)
        if not is_logged then
            log("Planet rewards: the dry run stopped on an error: " .. tostring(problem))
        end
    end
    if not (config.planetary_oceans or config.planetary_resources or config.planetary_lightning or config.planetary_freezing or config.planetary_locks or config.planetary_rewards or config.planetary_connections or config.planetary_enemies) and SWAP_START_WITH == nil then
        log("Planetary: " .. planetary_check.num_sorts .. " sorts (no stage that changes the game is on)")
        return
    end

    if config.planetary_superposed or SWAP_START_WITH ~= nil then
        -- An error in any stage undoes them all here too (the normal path's run_stage undoes each stage on its own), so the game still loads
        local old_raw = table.deepcopy(data.raw)
        local is_run, problem = pcall(run_superposed, logic, state)
        if not is_run then
            data.raw = old_raw
            planetary.reset()
            warn("changes", "were undone, since of an error: " .. tostring(problem) .. ".")
            return
        end
        planetary.before = {
            sort = state.before,
            variants_of = state.variants_of,
        }
        log("Planetary: " .. planetary_check.num_sorts .. " sorts")
        return
    end

    -- With the planetary fix pass, the stages wait until unified randomization is loaded, since the fix pass repairs with its handlers: data-final-fixes.lua runs them with planetary.run_pending
    if config.planetary_fix_pass then
        planetary.pending = {
            logic = logic,
            state = state,
        }
        log("Planetary: " .. planetary_check.num_sorts .. " sorts so far; the stages wait for the fix pass")
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
            rewards.moved = {}
            lutils.bootstrap_heat_rooms = {}
            scaffolds.kept = {}
            run_stages(logic, state, true)
        end
    end
    finish(state, old_raw)
end

-- The game before planetary changes (its sort, and the scaffold variants that count as its recipes), kept for check_final while any stage's changes are in the game
planetary.before = nil

-- The stages planetary.execute left waiting for the fix pass (config.planetary_fix_pass), as { logic, state }, or nil
planetary.pending = nil

-- Runs the waiting stages once unified randomization is loaded (data-final-fixes.lua): each one the fix pass can repair runs fix pass first and then the old way (run_fix_first), and each checks its own result, as in a careful run
-- fix is the fix pass: a function of the stage state returning how many goals are still lost
planetary.run_pending = function(fix)
    local pending = planetary.pending
    planetary.pending = nil
    if pending == nil then
        return
    end
    local logic = pending.logic
    local state = pending.state
    local old_raw = table.deepcopy(data.raw)
    run_stages(logic, state, true, fix)
    -- A stage the fix pass repaired leaves no sort of its result behind
    if state.after == nil and next(planetary_check.moved_features) ~= nil then
        state.after = planetary_check.sort(logic)
    end
    finish(state, old_raw)
end

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
        local lock, id = locks.lock_of_node(edge.stop)
        return gutils.deconstruct(edge.start).type == "room" and lock ~= nil and rewards.bundle_of_lock(id) == nil
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

-- The moved bundle (and its id) a debt edge belongs to, or nil: a member's lock its old planet accepted (room --> recipe- or entity-build-surface-condition), a retired recipe's old lock or unlock (it stayed in the game for a variant on the new planet, locked to no surface and unlocked by nothing, see rewards.execute), the old technology's unlock of a member whose unlock went to a copy (technology --> recipe-tech-unlock, see edit_tech in rewards.lua), or an old trigger source of an unsplit technology or of another technology the move retied (--> technology-trigger, see retie_dependent_triggers in rewards.lua)
-- (A machine's other recipes are only ever added on the new planet, see companions_of in rewards.lua, so nothing of theirs is owed)
local function reward_bundle_of(edge)
    local start = gutils.deconstruct(edge.start)
    local stop = gutils.deconstruct(edge.stop)
    if start.type == "room" then
        local lock, id = locks.lock_of_node(edge.stop)
        if lock ~= nil then
            return rewards.bundle_of_lock(id)
        end
    end
    if stop.type == "recipe-surface-condition" or stop.type == "recipe-tech-unlock" then
        local bundle, bundle_id = rewards.bundle_of_retired(stop.name)
        if bundle ~= nil then
            return bundle, bundle_id
        end
    end
    if stop.type == "recipe-tech-unlock" and start.type == "technology" then
        local bundle, bundle_id = rewards.bundle_of_recipe(stop.name)
        if bundle ~= nil and bundle.tech_edit.split ~= nil and bundle.tech_edit.split.source == start.name then
            return bundle, bundle_id
        end
    end
    if stop.type == "technology-trigger" then
        return rewards.bundle_of_trigger(stop.name)
    end
    return nil
end

-- Whatever a moved reward's old planet still needs of it (see reward_bundle_of) brings the whole reward back: its locks, its variants and its technology as they were, a revert (user, 2026-09-30: a reward its old planet needs goes back rather than being shared with it)
-- A reward sent home breaks what the attempt of the rest of randomization promised on its new planet (the check after the settlement would fail on those promises), so it's pinned home (rewards.pinned) and the attempt is rolled again without it (planetary.settle counts it as owed)
local sent_home = 0
table.insert(settlers, {
    name = "planet rewards",
    owns = function(edge)
        return reward_bundle_of(edge) ~= nil
    end,
    fixes = function(edge)
        local bundle, bundle_id = reward_bundle_of(edge)
        local undo
        local transport_before
        local fixes = {}
        table.insert(fixes, {
            rung = "revert",
            text = bundle.source_tech .. " stays",
            apply = function()
                undo = rewards.revert_bundle(bundle_id)
                transport_before = undo ~= nil and forget_reward_transport(undo) or {}
                if undo ~= nil then
                    rewards.pinned[bundle_id] = true
                    sent_home = sent_home + 1
                end
            end,
            undo = function()
                if undo ~= nil then
                    rewards.redo_bundle(bundle_id, undo)
                    for recipe_key, entry in pairs(transport_before) do
                        planetary_check.transport[recipe_key] = entry
                    end
                end
            end,
        })
        return fixes
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

-- Settles what the game an attempt of the rest of randomization built still owes from planetary changes in superposed mode, with the settlers above
-- The logic module (logic) is rebuilt from data.raw for each check
-- Returns how many goals are still owed (0 outside superposed mode)
planetary.settle = function(logic)
    if planetary.superposed == nil then
        return 0
    end
    sent_home = 0
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
    for _, undo in pairs(rewards.sync()) do
        forget_reward_transport(undo)
    end
    log("Planetary settlement: " .. #result.applied .. " fixes, " .. #result.failures .. " goals still owed" .. (sent_home > 0 and (", " .. sent_home .. " rewards sent home (pinned for the next roll)") or ""))
    for _, fix in pairs(result.applied) do
        log("Planetary settlement: " .. fix.rung .. ": " .. fix.text .. (#(fix.needed_by or {}) > 0 and " (needed by " .. table.concat(fix.needed_by, "; ") .. ")" or ""))
    end
    for _, failure in pairs(result.failures) do
        log("Planetary settlement: still owed " .. failure.text)
    end
    for _, edge_key in pairs(sorted_keys(result.unsettled)) do
        log("Planetary settlement: no fix for debt edge " .. edge_key)
    end
    return #result.failures + sent_home
end

-- Checks the finished game (graph, after all randomization) against the game before planetary changes, with the same rules as each stage's own check (PLANETCHECK final)
-- Those goals are what the changes promised to keep, so whatever is still lost fails the check (returns false) and is warned about in the randomizer panel: in superposed mode after settling what the rest of randomization left, otherwise after retrying attempts that lost some (planetary.check_attempt)
-- Later randomization doesn't protect everything the stages kept (like rocket building's isolatability on a planet), and the stages after unified's attempts aren't retried, so this can fail even when every attempt passed
planetary.check_final = function(graph)
    if planetary.before == nil then
        return true
    end
    local after = {
        graph = graph,
        sort_info = top.sort(graph, nil, nil, {
            complex_contexts = true,
            home_contexts = true,
            home_sets = planetary_check.home_sets,
        }),
    }
    local passes, failures = planetary_check.required(planetary.before.sort, after, planetary.before.variants_of, false, "PLANETCHECK final")
    if passes then
        return true
    end
    if planetary.superposed ~= nil then
        warn("changes", "couldn't keep " .. #failures .. " things planets could do before them, even after settling what the rest of randomization left (see PLANETCHECK final in the log).")
    else
        warn("changes", "couldn't keep " .. #failures .. " things planets could do before them (see PLANETCHECK final in the log).")
    end
    return false
end

-- Checks the game an attempt of the rest of randomization built against the game before planetary changes, with the same rules as each stage's own check (PLANETCHECK attempt)
-- The attempt's logic graph comes with sort_info, its sort with room/ability and home contexts, which is only redone if its home sets aren't the stages' own
-- Outside superposed mode (where planetary.settle does this) the stages repaired their changes before the rest of randomization ran, so an attempt that loses what they kept is retried like one that fails UNIFIEDCHECK (see data-final-fixes.lua)
-- Returns how many goals the attempt lost (0 in superposed mode or without planetary changes), the lost goals (see planetary_check.required_failures) and the sort they were found in
planetary.check_attempt = function(graph, sort_info)
    if planetary.before == nil or planetary.superposed ~= nil then
        return 0, {}, sort_info
    end
    if sort_info.home_sets ~= planetary_check.home_sets then
        sort_info = top.sort(graph, nil, nil, {
            complex_contexts = true,
            home_contexts = true,
            home_sets = planetary_check.home_sets,
        })
    end
    local _, failures = planetary_check.required(planetary.before.sort, {
        graph = graph,
        sort_info = sort_info,
    }, planetary.before.variants_of, false, "PLANETCHECK attempt")
    return #failures, failures, sort_info
end

-- Undoes every stage's bookkeeping, so the changes can be rolled again on the game before them (planetary.reroll)
planetary.reset = function()
    planetary_check.moved_features = {}
    planetary_check.transport = {}
    planetary_check.given_up = {}
    planetary_check.home_sets = nil
    locks.moved = {}
    rewards.moved = {}
    scaffolds.kept = {}
    lightning.last = nil
    freezing.last = nil
    lutils.bootstrap_heat_rooms = {}
    protection.transported_recipe_contexts = {}
    planetary.superposed = nil
    planetary.before = nil
    planetary.replacements = {}
    planetary.pending = nil
end

-- Rolls the changes again for another attempt of the rest of randomization in superposed mode (see data-final-fixes.lua); data.raw must be the game before any planetary change again
-- Each stage draws from its own random stream (lib/random/rng.lua), so it rolls something else than the time before
planetary.reroll = function(logic)
    planetary.reset()
    planetary.execute(logic)
end

-- Undoes the changes for the rest of the attempts (data.raw must be the game before any planetary change again), with a warning in the randomizer panel, after num_attempts attempts of the rest of randomization couldn't keep what they owed
planetary.undo = function(num_attempts)
    planetary.reset()
    warn("changes", "were undone, since " .. num_attempts .. " attempts of the rest of randomization couldn't keep what planets could do before them.")
end

return planetary
