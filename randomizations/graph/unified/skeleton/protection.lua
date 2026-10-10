-- Which parts of mechanic contexts graph randomization must keep, and which contexts of planet-locked recipes (the one place these rules live)
-- Rooms and automatability are always kept; isolatability is kept everywhere with constants.keep_isolatability, or else only for nodes built with keep_isolatability = true (see lib/logic)
-- Science packs are the exception: each keeps every context it has in the rooms it belongs to (lib/science-rooms.lua, given to its node as science_rooms), isolatable and automatable included, and nothing elsewhere (protection.keeps_room)
-- Home contexts (see context-sort.lua) aren't mechanic contexts of their own: they only matter as backings of isolatability from the discovery rule, which promotion follows, so a mechanic's home context keeps just what the context it rides on keeps
-- Used by promotion (what it promises), monotone matching (its hard set), first pass's gate and the mechanic context check, and in its planetary form by the planetary check (randomizations/planetary/check.lua)

local constants = require("helper-tables/constants")
local bootstrap = require("lib/logic/bootstrap")
local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local recipe_merges = require("lib/recipe-merges")
local surface_sets = require("lib/surface-sets")

local protection = {}

protection.is_isolatable_context = function(context)
    local mask = top.context_mask(context)
    return mask ~= nil and top.has_ability(mask, top.ISOLATABILITY)
end

-- Whether the node must keep its isolatable contexts (in the rooms it keeps anything in, see protection.keeps_room)
protection.protects_isolatability = function(node)
    return constants.keep_isolatability or node.keep_isolatability == true or node.science_rooms ~= nil
end

-- Whether the node keeps anything in the context's room: every mechanic does, except a science pack outside the rooms it belongs to (the user, 2026-10-10: making utility science on Fulgora isn't needed)
protection.keeps_room = function(node, context)
    return node.science_rooms == nil or node.science_rooms[top.context_room(context)] ~= nil
end

-- Whether the node's pebble in context must be kept exactly
-- An unprotected isolatable context only needs its non-isolatable counterpart, which is its own pebble, since anything reachable isolatably is also reachable without isolatability
-- A home context only needs the context it rides on, which is also its own pebble
protection.is_hard_mechanic_pebble = function(node, context)
    if top.context_home(context) ~= nil or not protection.keeps_room(node, context) then
        return false
    end
    return not protection.is_isolatable_context(context) or protection.protects_isolatability(node)
end

-- The part of a context that must be kept for the node: "room | ia" becomes "room | ?a" when the node's isolatability isn't protected, and a home context keeps what the context it rides on keeps
-- Kept parts are numbers: a context, or for "room | ?a" minus one minus the context with isolatability cleared, so it's never a context (protection.kept_name writes them)
-- Nil when the node keeps nothing in the context's room (protection.keeps_room)
protection.kept_part = function(node, context)
    context = top.context_without_home(context)
    if not protection.keeps_room(node, context) then
        return nil
    end
    local mask = top.context_mask(context)
    if mask == nil or protection.protects_isolatability(node) then
        return context
    end
    return -1 - top.context_key(top.context_room(context), top.without_ability(mask, top.ISOLATABILITY))
end

-- Kept part --> how it's written in logs, like "planet: nauvis | ?1" (filled once per kept part)
local kept_names = {}
protection.kept_name = function(kept)
    if kept >= 0 then
        return top.context_name(kept)
    end
    local name = kept_names[kept]
    if name == nil then
        local context = -1 - kept
        local mask_name = top.mask_name(top.context_mask(context))
        name = top.context_room(context) .. " | " .. string.sub(mask_name, 1, top.ISOLATABILITY - 1) .. "?" .. string.sub(mask_name, top.ISOLATABILITY + 1)
        kept_names[kept] = name
    end
    return name
end

-- Whether context asks for every ability other asks for (both complex contexts of one room), like "room | 11" for "room | 10"
local function asks_for_no_more(other, context)
    return top.mask_covers(top.context_mask(context), top.context_mask(other))
end

-- Recipe contexts a planetary change carried over to where they must be kept now, as node key --> context --> true
-- Like a recipe whose planet lock moved staying automatable on its new planet (randomizations/planetary/check.lua's goal transport), when it also still works on its old planet, so it isn't locked to one planet below
-- The planetary stage sets these once its changes are final; the rest of randomization keeps them like planet-locked recipes' contexts
protection.transported_recipe_contexts = {}

-- A recipe's contexts other than home contexts when all of them are on one planet (a room whose prototype is a planet, so not a space platform), a planet and its copies counting as one (surface_sets.family_of), else nil
local function one_planet_contexts(contexts)
    local family
    for context, _ in pairs(contexts) do
        local context_room = top.context_room(context)
        if gutils.deconstruct(context_room).type ~= "planet" then
            return nil
        end
        local context_family = surface_sets.family_of(context_room)
        if family ~= nil and context_family ~= family then
            return nil
        end
        family = context_family
    end
    if family == nil then
        return nil
    end
    local kept = {}
    for context, _ in pairs(contexts) do
        if top.context_home(context) == nil then
            kept[context] = true
        end
    end
    return kept
end

-- Recipes locked to one planet by their surface conditions keep every context they have there, isolatable and automatable included, through all randomization, planetary changes included
-- A recipe is locked if its prototype has surface conditions and all its pebbles in the sort are on one planet (a room whose prototype is a planet, so not a space platform); a planet and its copies count as one planet (surface_sets.family_of), since no condition can tell them apart
-- Contexts in protection.transported_recipe_contexts that the sort has are kept too
-- So are the contexts that justify a bootstrap grant the graph keeps (bootstrap.justifications in lib/logic/bootstrap.lua, like heat keeping itself going on a planet that freezes): the logic checks those when it's built, not in the graph, so a model of the graph counts the grant as fixed while a change could make the next build drop it
-- A recipe merged into another after an attempt (lib/recipe-merges.lua) is gone from the game, so the recipe it became keeps what the merged one would have kept: it's made wherever that one was, from the same things, unlocked by what unlocked it
-- The graph and sort_info are a logic graph and a complex sort of it, and prototypes come from data.raw, so call this while data.raw is the game that was sorted
-- Home contexts aren't kept for their own sake, as for planetary_kept_context below
-- Returns node key --> context --> true
protection.planet_locked_recipe_contexts = function(graph, sort_info)
    local locked = {}
    local function keep(node_key, contexts)
        locked[node_key] = locked[node_key] or {}
        for context, _ in pairs(contexts) do
            locked[node_key][context] = true
        end
    end
    for node_key, contexts in pairs(sort_info.node_to_context_inds) do
        local node = graph.nodes[node_key]
        local recipe = node ~= nil and node.type == "recipe" and data.raw.recipe[node.name] or nil
        -- A planet's version of a recipe that wasn't locked to one planet (independent deposits, randomizations/graph/unified/deposit-copies.lua) is kept like its original, not like a planet-locked recipe
        if recipe ~= nil and recipe.surface_conditions ~= nil and next(recipe.surface_conditions) ~= nil and recipe.deposit_local_unlocked ~= true then
            local kept = one_planet_contexts(contexts)
            if kept ~= nil then
                keep(node_key, kept)
            end
        end
    end
    -- Recipe node key --> the node key of the recipe it was merged into, for merged recipes
    local merged_into = {}
    local into = recipe_merges.into_of(data.raw)
    for recipe_name, kept_name in pairs(into) do
        merged_into[gutils.key("recipe", recipe_name)] = gutils.key("recipe", kept_name)
    end
    if next(into) ~= nil then
        for kept_name, kept in pairs(data.raw.recipe) do
            for _, record in pairs(kept.merged_versions or {}) do
                if record.is_planet_locked then
                    local kept_contexts = one_planet_contexts(sort_info.node_to_context_inds[gutils.key("recipe", record.name)] or {})
                    if kept_contexts ~= nil then
                        keep(gutils.key("recipe", kept_name), kept_contexts)
                    end
                end
            end
        end
    end
    for node_key, contexts in pairs(protection.transported_recipe_contexts) do
        for context, _ in pairs(contexts) do
            if (sort_info.node_to_context_inds[node_key] or {})[context] ~= nil then
                keep(merged_into[node_key] or node_key, {
                    [context] = true,
                })
            end
        end
    end
    -- Any one context with a grant's abilities in its room justifies it, so only the ones asking for nothing more are kept: a bootstrapped building's item stays isolatable there, not automatable too (unless the sort only has it automatable)
    for _, justification in pairs(bootstrap.justifications(graph)) do
        local justifying = {}
        for context, _ in pairs(sort_info.node_to_context_inds[justification.node_key] or {}) do
            if bootstrap.justifies(context, justification.room, justification.ability_inds) then
                table.insert(justifying, context)
            end
        end
        for _, context in pairs(justifying) do
            local is_weakest = true
            for _, other in pairs(justifying) do
                if other ~= context and asks_for_no_more(other, context) then
                    is_weakest = false
                end
            end
            if is_weakest then
                locked[justification.node_key] = locked[justification.node_key] or {}
                locked[justification.node_key][context] = true
            end
        end
    end
    return locked
end

-- The context a planetary change (randomizations/planetary) must keep for a mechanic pebble, or nil if it needn't keep any
-- Planetary changes run before the rest of randomization, which then keeps whatever contexts they leave, so on purpose they keep less:
--   1. Rooms and automatability, as always.
--   2. Isolatability only for nodes built with keep_planetary_isolatability = true (a planet must still build and launch rockets and make electricity from its own resources, and a platform still take down asteroids from its own); others keep their non-isolatable counterpart.
--   3. Nothing for nodes of a feature a planetary change moves (built with planetary_feature), since those follow their feature; nodes also built with feature_stays_on_start = true still keep their starting planet contexts, since the feature never leaves it.
--   4. Science packs keep every context in the rooms they belong to, isolatability included, and nothing elsewhere, as for the rest of randomization (protection.keeps_room).
-- moved_features is the set of planetary_feature names being moved
-- Home contexts keep nothing of their own, as for kept_part
protection.planetary_kept_context = function(node, context, moved_features)
    if node.planetary_feature ~= nil and moved_features[node.planetary_feature] ~= nil then
        if node.feature_stays_on_start ~= true or top.context_room(context) ~= gutils.key("planet", constants.starting_planet) then
            return nil
        end
    end
    if top.context_home(context) ~= nil or not protection.keeps_room(node, context) then
        return nil
    end
    if node.keep_planetary_isolatability == true or node.science_rooms ~= nil or not protection.is_isolatable_context(context) then
        return context
    end
    return protection.without_isolatability(context)
end

-- The context with the same abilities but isolatability, in room (default: the context's own room), like "room | 11" --> "room | 01"
-- Anything reachable isolatably is also reachable without isolatability, so this pebble exists whenever the original does (in the same room)
protection.without_isolatability = function(context, room)
    local mask = top.context_mask(context)
    room = room or top.context_room(context)
    -- A simple context stands for its room
    if mask == nil then
        return top.simple_context(room)
    end
    return top.context_key(room, top.without_ability(mask, top.ISOLATABILITY))
end

return protection
