-- Checks a planetary randomization against the game before it, using the logic graph
-- check.required is what a planetary change must keep:
--   1. Every recipe that was reachable stays reachable somewhere.
--   2. Recipes locked to one planet by surface conditions (its science pack, pentapod eggs, soils, the foundry...) keep every context they had there (isolatable and automatable included), as themselves or as a variant.
--   3. Every mechanic keeps its rooms and automatability, and rocket building and electricity also keep their isolatability, except the moved features themselves (offshore fluids), which follow their feature.
--      Other isolatability (like another planet's science or steam power) may be lost; that's the gameplay change.
-- check.tiles_unchanged makes sure tile collision (so where offshore pumps work) is exactly as before.
-- check.run is a fuller report: which planets each science pack is isolatable on, and which mechanic contexts moved.
-- All output goes to the log with the prefix PLANETCHECK

local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")

local check = {}

-- Builds the logic from the current data.raw and sorts it with room/ability contexts
check.sort = function(logic)
    logic.build(true)
    return {
        graph = logic.graph,
        sort_info = top.sort(logic.graph, nil, nil, { complex_contexts = true }),
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

-- Mechanics that keep their isolatability through a planetary change: a planet must still build and launch rockets and make electricity from its own resources
local isolatability_protected = {
    "^launch",
    "^room%-launch:",
    "^create%-platform",
    "^room%-create%-platform",
    "^rocket%-silo",
    "^entity%-rocket%-silo:",
    "^cargo%-landing%-pad",
    "^recipe%-category: rocket%-building",
    "^energy%-source%-electric",
}

local function protects_isolatability(node_key)
    for _, pattern in pairs(isolatability_protected) do
        if string.find(node_key, pattern) ~= nil then
            return true
        end
    end
    return false
end

-- The context that must still exist for a mechanic pebble: itself if its isolatability is protected, or else its non-isolatable counterpart (anything reachable isolatably is also reachable without isolatability)
local function kept_context(node_key, context)
    local abilities = top.context_abilities(context)
    if abilities == nil or protects_isolatability(node_key) then
        return context
    end
    return top.context_room(context) .. " | 0" .. string.sub(abilities, 2)
end

-- Mechanic nodes that belong to a moved feature, so their rooms are expected to change
local function is_moved_feature(node)
    return string.find(node.type, "fluid-create-offshore", 1, true) == 1
end

-- Rooms a node's contexts are in, and whether any context in that room is isolatable
local function rooms_of(contexts)
    local rooms = {}
    for context, _ in pairs(contexts or {}) do
        local room = top.context_room(context)
        rooms[room] = rooms[room] or is_isolatable(context)
    end
    return rooms
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

    -- 2. Planet-locked recipes keep every context they had on their planet (isolatable and automatable included), as themselves or as a variant
    -- Exact contexts matter: one-off sources like hand-mined rocks or spawner eggs keep a recipe isolatable while losing its automatable, renewable route
    for recipe_name, recipe in pairs(data.raw.recipe) do
        local node_key = gutils.key("recipe", recipe_name)
        local contexts = before_contexts[node_key] or {}
        local planet_rooms = {}
        for room, _ in pairs(rooms_of(contexts)) do
            table.insert(planet_rooms, room)
        end
        if recipe.surface_conditions ~= nil and #planet_rooms == 1 and string.find(planet_rooms[1], "planet", 1, true) == 1 then
            local keys = {
                node_key,
            }
            for _, variant_name in pairs((variants_of or {})[recipe_name] or {}) do
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
    end

    -- 3. Mechanics keep their rooms and automatability, and protected ones their isolatability
    for node_key, contexts in pairs(before_contexts) do
        local node = before.graph.nodes[node_key]
        if node ~= nil and node.mechanic and node.type ~= "orand" and not is_moved_feature(node) then
            for context, _ in pairs(contexts) do
                local kept = kept_context(node_key, context)
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

-- Whether nothing check.required_failures looks for is missing
check.required = function(before, after, variants_of, is_quiet)
    local failures = check.required_failures(before, after, variants_of)
    if not is_quiet then
        local texts = {}
        for _, failure in pairs(failures) do
            table.insert(texts, failure.text)
        end
        table.sort(texts)
        log("PLANETCHECK required: " .. #texts .. " failures")
        for _, text in pairs(texts) do
            log("PLANETCHECK required failure: " .. text)
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
                if (after_contexts[node_key] or {})[context] == nil then
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
                if (before_contexts[node_key] or {})[context] == nil then
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
