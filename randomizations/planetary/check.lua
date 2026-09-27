-- Checks a planetary randomization against the game before it, using the logic graph
-- check.required is what a planetary change must keep:
--   1. Every recipe that was reachable stays reachable somewhere.
--   2. Recipes locked to one planet by surface conditions (its science pack, pentapod eggs, soils, the foundry...) keep every context they had there (isolatable and automatable included), as themselves or as a variant. The rest of randomization keeps them too (protection.planet_locked_recipe_contexts).
--   3. Every mechanic keeps what protection.planetary_kept_context says: its rooms and automatability, and for rocket building and electricity also its isolatability, except the moved features themselves (like offshore fluids), which follow their feature.
--      Other isolatability (like another planet's science or steam power) may be lost; that's the gameplay change.
-- Sorts use home contexts (the order-independent discovery rule, see lib/graph/context-sort.lua), like the rest of randomization and its checks.
-- check.tiles_unchanged makes sure tile collision (so where offshore pumps work) is exactly as before.
-- check.run is a fuller report: which planets each science pack is isolatable on, and which mechanic contexts moved.
-- All output goes to the log with the prefix PLANETCHECK

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local protection = require("randomizations/graph/unified/skeleton/protection")

local check = {}

-- Home sets of the game before any planetary change, kept for every later sort (narrowed only by recheck_home_sets in execute.lua), and handed to the rest of randomization as logic.home_sets while the changes are in the game (planetary.home_sets)
check.home_sets = nil

-- Builds the logic from the current data.raw and sorts it with room/ability contexts and home contexts
-- The first sort (of the game before planetary changes) sets the home sets the later ones use
-- How many sorts planetary changes took, since sorts are most of what they cost (logged by planetary.execute)
check.num_sorts = 0

check.sort = function(logic)
    check.num_sorts = check.num_sorts + 1
    logic.build(true, {
        home_sets = check.home_sets,
    })
    if check.home_sets == nil then
        check.home_sets = top.home_sets(logic.graph)
    end
    local sort_info = top.sort(logic.graph, nil, nil, {
        complex_contexts = true,
        home_contexts = true,
        home_sets = check.home_sets,
    })
    return {
        graph = logic.graph,
        sort_info = sort_info,
        -- Found now, while data.raw is the game that was sorted (planet_locked_recipe_contexts reads recipes' surface conditions)
        planet_locked = protection.planet_locked_recipe_contexts(logic.graph, sort_info),
    }
end

local function is_isolatable(context)
    local abilities = top.context_abilities(context)
    return abilities ~= nil and string.sub(abilities, 1, 1) == "1"
end

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

-- Whether two values are equal all the way down (tables compared by content)
local function deep_equal(a, b)
    if type(a) ~= "table" or type(b) ~= "table" then
        return a == b
    end
    for key, value in pairs(a) do
        if not deep_equal(value, b[key]) then
            return false
        end
    end
    for key, _ in pairs(b) do
        if a[key] == nil then
            return false
        end
    end
    return true
end

-- Whether a recipe was only ever reachable on the given planet in the given sort (so editing it can't cost another planet anything)
-- node_only_on is the same for any node, by its key
check.node_only_on = function(sort, node_key, planet_name)
    local room = gutils.key("planet", planet_name)
    local contexts = sort.sort_info.node_to_context_inds[node_key] or {}
    if next(contexts) == nil then
        return false
    end
    for context, _ in pairs(contexts) do
        if top.context_room(context) ~= room then
            return false
        end
    end
    return true
end

check.only_on = function(sort, recipe_name, planet_name)
    return check.node_only_on(sort, gutils.key("recipe", recipe_name), planet_name)
end

-- Whether a recipe belongs to the given planet in the given sort: only that planet could make it at all (check.only_on), or only that planet could make it from its own resources (every isolatable context is there, like tungsten carbide on Vulcanus)
-- Other planets could only make such a recipe with imports
-- node_specific_to is the same for any node, by its key; for a technology, whose non-isolatable contexts are everywhere once it's researched, it means only that planet could research it from its own resources (like a trigger that mines a resource only that planet has)
check.node_specific_to = function(sort, node_key, planet_name)
    if check.node_only_on(sort, node_key, planet_name) then
        return true
    end
    local room = gutils.key("planet", planet_name)
    local is_isolatable_there = false
    for context, _ in pairs(sort.sort_info.node_to_context_inds[node_key] or {}) do
        if is_isolatable(context) then
            if top.context_room(context) ~= room then
                return false
            end
            is_isolatable_there = true
        end
    end
    return is_isolatable_there
end

check.specific_to = function(sort, recipe_name, planet_name)
    return check.node_specific_to(sort, gutils.key("recipe", recipe_name), planet_name)
end

-- Offshore pumps (and anything else going by tile collision) only work where they originally did.
-- Every tile keeps its collision and whether it has a fluid, and cloned tiles match the tile they were cloned from.
-- Offshore pump prototypes themselves aren't compared, since other mods may change them.
-- old_raw is data.raw from before the planetary change; clone_to_slot maps each new tile to the tile it was cloned from.
-- Returns a list of problems, empty if there are none
check.tiles_unchanged = function(old_raw, clone_to_slot)
    local problems = {}
    for tile_name, tile in pairs(data.raw.tile) do
        local source = old_raw.tile[tile_name]
        if source == nil and clone_to_slot[tile_name] ~= nil then
            source = old_raw.tile[clone_to_slot[tile_name]]
        end
        if source == nil then
            table.insert(problems, "new tile " .. tile_name .. " isn't a clone of an existing tile")
        else
            if not deep_equal(tile.collision_mask, source.collision_mask) then
                table.insert(problems, "tile " .. tile_name .. " has different collision than " .. source.name)
            end
            if (tile.fluid == nil) ~= (source.fluid == nil) then
                table.insert(problems, "tile " .. tile_name .. (tile.fluid == nil and " lost its fluid" or " gained a fluid"))
            end
        end
    end
    return problems
end

-- Features (planetary_feature names declared on logic nodes) that a planetary stage moves, so their nodes' rooms are expected to change
-- Each stage adds its own: ocean swaps move offshore fluids ("oceans"), and resource swaps move resource categories ("resources")
check.moved_features = {}

-- Goal transport, for goals that follow something a planetary change moved to another room (like a recipe whose planet lock moved, see randomizations/planetary/locks.lua)
-- node key --> { map = old room --> new room, keep_isolatability = whether the goal stays isolatable in the new room }
-- Without keep_isolatability, a transported goal keeps its automatability but not its isolatability: it may use imports in the new room (right for a lock, whose planet's resources don't move with it)
-- Every consumer of the goals (check.required_failures, check.transported_goals for superposed mode, and so first pass and promotion) reads them through check.transported_context, so they all agree
check.transport = {}

-- The context a goal of node_key in context must be kept in after planetary changes (itself, unless check.transport moves its room)
check.transported_context = function(node_key, context)
    local entry = check.transport[node_key]
    local new_room = entry ~= nil and entry.map[top.context_room(context)] or nil
    if new_room == nil then
        return context
    end
    if entry.keep_isolatability then
        local abilities = top.context_abilities(context)
        if abilities == nil then
            return new_room
        end
        return top.context_key(new_room, abilities)
    end
    return protection.without_isolatability(context, new_room)
end

-- Rule 2's goals: planet-locked recipes of the game before planetary changes (before, a sort from check.sort) keep every context they had on their planet, transported where their lock moved
-- Returns node key --> context --> true
check.planet_locked_goals = function(before)
    local goals = {}
    for node_key, contexts in pairs(before.planet_locked or protection.planet_locked_recipe_contexts(before.graph, before.sort_info)) do
        goals[node_key] = {}
        for context, _ in pairs(contexts) do
            goals[node_key][check.transported_context(node_key, context)] = true
        end
    end
    return goals
end

-- What check.required finds missing, as data: each failure has text (for the log), keys (node keys, any of which counts) and context (nil for any context)
-- variants_of: original recipe name --> list of variant recipe names that count as it for rule 2
check.required_failures = function(before, after, variants_of)
    local before_contexts = before.sort_info.node_to_context_inds
    local after_contexts = after.sort_info.node_to_context_inds
    local failures = {}

    -- 1. Recipes stay reachable somewhere
    for node_key, contexts in pairs(before_contexts) do
        local node = before.graph.nodes[node_key]
        if node ~= nil and node.type == "recipe" and next(contexts) ~= nil and next(after_contexts[node_key] or {}) == nil then
            table.insert(failures, {
                text = "unreachable " .. node_key,
                keys = {
                    node_key,
                },
            })
        end
    end

    -- 2. Planet-locked recipes keep every context they had on their planet (isolatable and automatable included; see protection.planet_locked_recipe_contexts), as themselves or as a variant, and follow their lock where it moved (check.planet_locked_goals)
    -- Exact contexts matter: one-off sources like hand-mined rocks or spawner eggs keep a recipe isolatable while losing its automatable, renewable route
    for node_key, contexts in pairs(check.planet_locked_goals(before)) do
        local keys = {
            node_key,
        }
        for _, variant_name in pairs((variants_of or {})[before.graph.nodes[node_key].name] or {}) do
            table.insert(keys, gutils.key("recipe", variant_name))
        end
        for context, _ in pairs(contexts) do
            local works = false
            for _, key in pairs(keys) do
                if (after_contexts[key] or {})[context] ~= nil then
                    works = true
                end
            end
            if not works then
                table.insert(failures, {
                    text = "planet-locked " .. node_key .. " @ " .. context,
                    keys = keys,
                    context = context,
                })
            end
        end
    end

    -- 3. Mechanics keep what protection.planetary_kept_context says
    -- A mechanic node the game no longer has can't be needed (like a fluid-count variant of a recipe category once no recipe has those fluids), so it's skipped, as the mechanic context check does
    for node_key, kept_contexts in pairs(check.transported_mechanic_goals(before)) do
        if after.graph.nodes[node_key] ~= nil then
            for kept, _ in pairs(kept_contexts) do
                if (after_contexts[node_key] or {})[kept] == nil then
                    table.insert(failures, {
                        text = "mechanic " .. node_key .. " @ " .. kept,
                        keys = {
                            node_key,
                        },
                        context = kept,
                    })
                end
            end
        end
    end
    return failures
end

-- Everything check.required keeps in an exact context (rule 3's mechanic goals and rule 2's planet-locked recipe contexts), as node key --> context --> true
-- Rule 1 (every recipe stays reachable somewhere) isn't about any one context, so it isn't in it
check.transported_goals = function(before)
    local goals = check.transported_mechanic_goals(before)
    for node_key, contexts in pairs(check.planet_locked_goals(before)) do
        goals[node_key] = goals[node_key] or {}
        for context, _ in pairs(contexts) do
            goals[node_key][context] = true
        end
    end
    return goals
end

-- What rule 3 of check.required keeps: each mechanic pebble of the game before planetary changes (before, a sort from check.sort) keeps protection.planetary_kept_context, so moved features aren't in it
-- These are the mechanic goals planetary changes carry over to the game after them, as node key --> context --> true
check.transported_mechanic_goals = function(before)
    local goals = {}
    for node_key, contexts in pairs(before.sort_info.node_to_context_inds) do
        local node = before.graph.nodes[node_key]
        if node ~= nil and node.mechanic and node.type ~= "orand" then
            for context, _ in pairs(contexts) do
                local kept = protection.planetary_kept_context(node, context, check.moved_features)
                -- A node of a moved feature keeps nothing where it was, but if its goals follow the feature (a check.transport entry, like lightning power following lightning), it keeps them where the feature went
                if kept == nil and check.transport[node_key] ~= nil then
                    kept = protection.planetary_kept_context(node, context, {})
                end
                if kept ~= nil then
                    goals[node_key] = goals[node_key] or {}
                    goals[node_key][check.transported_context(node_key, kept)] = true
                end
            end
        end
    end
    return goals
end

-- Whether nothing check.required_failures looks for is missing
-- Its log lines start with label (default "PLANETCHECK required")
check.required = function(before, after, variants_of, is_quiet, label)
    label = label or "PLANETCHECK required"
    local failures = check.required_failures(before, after, variants_of)
    if not is_quiet then
        local texts = {}
        for _, failure in pairs(failures) do
            table.insert(texts, failure.text)
        end
        table.sort(texts)
        log(label .. ": " .. #texts .. " failures")
        for _, text in pairs(texts) do
            log(label .. " failure: " .. text)
        end
    end
    return #failures == 0
end

-- Indices in a sort of each failure's earliest pebble there (if it has one), so the witnesses of what a change fixes can be found with top.path
check.goal_inds = function(failures, sort)
    local inds = {}
    for _, failure in pairs(failures) do
        local earliest
        for _, key in pairs(failure.keys) do
            for context, ind in pairs(sort.sort_info.node_to_context_inds[key] or {}) do
                if (failure.context == nil or context == failure.context) and (earliest == nil or ind < earliest) then
                    earliest = ind
                end
            end
        end
        if earliest ~= nil then
            table.insert(inds, earliest)
        end
    end
    return inds
end

-- Returns whether every science pack keeps its planets and isolatable contexts and every recipe stays reachable (stricter than check.required)
-- With is_quiet, nothing is logged and moved mechanics aren't computed (for checking many candidate changes)
check.run = function(before, after, is_quiet)
    local function say(message)
        if not is_quiet then
            log(message)
        end
    end
    local before_contexts = before.sort_info.node_to_context_inds
    local after_contexts = after.sort_info.node_to_context_inds

    -- Science packs keep their isolatable planets
    -- Science packs are whatever labs take, since the initial reformat moves tools into data.raw.item
    local science_packs = {}
    for _, lab in pairs(data.raw.lab) do
        for _, pack_name in pairs(lab.inputs) do
            science_packs[pack_name] = true
        end
    end
    local num_science = 0
    local lost_science = {}
    for _, pack_name in pairs(sorted_keys(science_packs)) do
        local node_key = gutils.key("item", pack_name)
        -- Craftable at all on each planet it was craftable on (this covers Aquilo, where nothing is isolatable even in vanilla)
        local before_rooms = {}
        local after_rooms = {}
        for context, _ in pairs(before_contexts[node_key] or {}) do
            before_rooms[top.context_room(context)] = true
        end
        for context, _ in pairs(after_contexts[node_key] or {}) do
            after_rooms[top.context_room(context)] = true
        end
        for room, _ in pairs(before_rooms) do
            num_science = num_science + 1
            if after_rooms[room] == nil then
                table.insert(lost_science, node_key .. " @ " .. room .. " (at all)")
            end
        end
        for context, _ in pairs(before_contexts[node_key] or {}) do
            if is_isolatable(context) then
                num_science = num_science + 1
                if (after_contexts[node_key] or {})[context] == nil then
                    table.insert(lost_science, node_key .. " @ " .. context)
                end
            end
        end
    end
    -- Which planets each pack is isolatable on, before and after, to show what the check covers
    for _, pack_name in pairs(sorted_keys(science_packs)) do
        local node_key = gutils.key("item", pack_name)
        local function isolatable_rooms(contexts)
            local rooms = {}
            for context, _ in pairs(contexts or {}) do
                if is_isolatable(context) then
                    rooms[top.context_room(context)] = true
                end
            end
            return table.concat(sorted_keys(rooms), ", ")
        end
        say("PLANETCHECK isolatable " .. pack_name .. ": before {" .. isolatable_rooms(before_contexts[node_key]) .. "} after {" .. isolatable_rooms(after_contexts[node_key]) .. "}")
    end
    table.sort(lost_science)
    say("PLANETCHECK checked " .. num_science .. " science pack rooms and isolatable contexts; lost " .. #lost_science)
    for _, str in pairs(lost_science) do
        say("PLANETCHECK lost science " .. str)
    end

    -- Recipes stay reachable somewhere
    local num_recipes = 0
    local lost_recipes = {}
    for node_key, contexts in pairs(before_contexts) do
        local node = before.graph.nodes[node_key]
        if node ~= nil and node.type == "recipe" and next(contexts) ~= nil then
            num_recipes = num_recipes + 1
            if next(after_contexts[node_key] or {}) == nil then
                table.insert(lost_recipes, node_key)
            end
        end
    end
    table.sort(lost_recipes)
    say("PLANETCHECK checked " .. num_recipes .. " recipes; unreachable " .. #lost_recipes)
    for _, recipe_key in pairs(lost_recipes) do
        say("PLANETCHECK unreachable recipe " .. recipe_key)
    end

    if is_quiet then
        return #lost_science == 0 and #lost_recipes == 0
    end


    -- Mechanic contexts that moved, grouped by node
    local moved = {}
    local num_lost = 0
    local num_gained = 0
    local function note(node_key, sign, context)
        if moved[node_key] == nil then
            moved[node_key] = {}
        end
        table.insert(moved[node_key], sign .. top.context_room(context) .. "|" .. (top.context_abilities(context) or ""))
    end
    for node_key, contexts in pairs(before_contexts) do
        local node = before.graph.nodes[node_key]
        if node ~= nil and node.mechanic and node.type ~= "orand" then
            for context, _ in pairs(contexts) do
                if top.context_home(context) == nil and (after_contexts[node_key] or {})[context] == nil then
                    num_lost = num_lost + 1
                    note(node_key, "-", context)
                end
            end
        end
    end
    for node_key, contexts in pairs(after_contexts) do
        local node = after.graph.nodes[node_key]
        if node ~= nil and node.mechanic and node.type ~= "orand" then
            for context, _ in pairs(contexts) do
                if top.context_home(context) == nil and (before_contexts[node_key] or {})[context] == nil then
                    num_gained = num_gained + 1
                    note(node_key, "+", context)
                end
            end
        end
    end
    say("PLANETCHECK mechanic contexts moved: lost " .. num_lost .. ", gained " .. num_gained)
    for _, node_key in pairs(sorted_keys(moved)) do
        table.sort(moved[node_key])
        say("PLANETCHECK moved " .. node_key .. ": " .. table.concat(moved[node_key], " "))
    end

    return #lost_science == 0 and #lost_recipes == 0
end

return check
