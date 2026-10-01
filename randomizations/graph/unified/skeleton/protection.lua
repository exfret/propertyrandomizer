-- Which parts of mechanic contexts graph randomization must keep, and which contexts of planet-locked recipes (the one place these rules live)
-- Rooms and automatability are always kept; isolatability is kept everywhere with constants.keep_isolatability, or else only for nodes built with keep_isolatability = true (see lib/logic)
-- Home contexts (see context-sort.lua) aren't mechanic contexts of their own: they only matter as backings of isolatability from the discovery rule, which promotion follows, so a mechanic's home context keeps just what the context it rides on keeps
-- Used by promotion (what it promises), monotone matching (its hard set), first pass's gate and the mechanic context check, and in its planetary form by the planetary check (randomizations/planetary/check.lua)

local constants = require("helper-tables/constants")
local bootstrap = require("lib/logic/bootstrap")
local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")
local surface_sets = require("lib/surface-sets")

local protection = {}

protection.is_isolatable_context = function(context)
    local abilities = top.context_abilities(context)
    return abilities ~= nil and string.sub(abilities, top.ISOLATABILITY, top.ISOLATABILITY) == "1"
end

-- Whether the node must keep its isolatable contexts
protection.protects_isolatability = function(node)
    return constants.keep_isolatability or node.keep_isolatability == true
end

-- Whether the node's pebble in context must be kept exactly
-- An unprotected isolatable context only needs its non-isolatable counterpart, which is its own pebble, since anything reachable isolatably is also reachable without isolatability
-- A home context only needs the context it rides on, which is also its own pebble
protection.is_hard_mechanic_pebble = function(node, context)
    if top.context_home(context) ~= nil then
        return false
    end
    return not protection.is_isolatable_context(context) or protection.protects_isolatability(node)
end

-- The part of a context that must be kept for the node: "room | ia" becomes "room | ?a" when the node's isolatability isn't protected, and a home context keeps what the context it rides on keeps
protection.kept_part = function(node, context)
    context = top.context_without_home(context)
    local abilities = top.context_abilities(context)
    if abilities == nil or protection.protects_isolatability(node) then
        return context
    end
    local kept = top.context_room(context) .. " | "
    for i = 1, #abilities do
        if i == top.ISOLATABILITY then
            kept = kept .. "?"
        else
            kept = kept .. string.sub(abilities, i, i)
        end
    end
    return kept
end

-- Recipe contexts a planetary change carried over to where they must be kept now, as node key --> context --> true
-- Like a recipe whose planet lock moved staying automatable on its new planet (randomizations/planetary/check.lua's goal transport), when it also still works on its old planet, so it isn't locked to one planet below
-- The planetary stage sets these once its changes are final; the rest of randomization keeps them like planet-locked recipes' contexts
protection.transported_recipe_contexts = {}

-- Recipes locked to one planet by their surface conditions keep every context they have there, isolatable and automatable included, through all randomization, planetary changes included
-- A recipe is locked if its prototype has surface conditions and all its pebbles in the sort are on one planet (a room whose prototype is a planet, so not a space platform); a planet and its copies count as one planet (surface_sets.family_of), since no condition can tell them apart
-- Contexts in protection.transported_recipe_contexts that the sort has are kept too
-- So are the contexts that justify a bootstrap grant the graph keeps (bootstrap.justifications in lib/logic/bootstrap.lua, like heat keeping itself going on a planet that freezes): the logic checks those when it's built, not in the graph, so a model of the graph counts the grant as fixed while a change could make the next build drop it
-- The graph and sort_info are a logic graph and a complex sort of it, and prototypes come from data.raw, so call this while data.raw is the game that was sorted
-- Home contexts aren't kept for their own sake, as for planetary_kept_context below
-- Returns node key --> context --> true
protection.planet_locked_recipe_contexts = function(graph, sort_info)
    local locked = {}
    for node_key, contexts in pairs(sort_info.node_to_context_inds) do
        local node = graph.nodes[node_key]
        local recipe = node ~= nil and node.type == "recipe" and data.raw.recipe[node.name] or nil
        if recipe ~= nil and recipe.surface_conditions ~= nil and next(recipe.surface_conditions) ~= nil then
            local family
            local is_one_family = true
            for context, _ in pairs(contexts) do
                local context_room = top.context_room(context)
                if gutils.deconstruct(context_room).type ~= "planet" then
                    is_one_family = false
                else
                    local context_family = surface_sets.family_of(context_room)
                    if family == nil then
                        family = context_family
                    elseif context_family ~= family then
                        is_one_family = false
                    end
                end
            end
            if family ~= nil and is_one_family then
                locked[node_key] = {}
                for context, _ in pairs(contexts) do
                    if top.context_home(context) == nil then
                        locked[node_key][context] = true
                    end
                end
            end
        end
    end
    for node_key, contexts in pairs(protection.transported_recipe_contexts) do
        for context, _ in pairs(contexts) do
            if (sort_info.node_to_context_inds[node_key] or {})[context] ~= nil then
                locked[node_key] = locked[node_key] or {}
                locked[node_key][context] = true
            end
        end
    end
    for _, justification in pairs(bootstrap.justifications(graph)) do
        for context, _ in pairs(sort_info.node_to_context_inds[justification.node_key] or {}) do
            if bootstrap.justifies(context, justification.room, justification.ability_inds) then
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
--   2. Isolatability only for nodes built with keep_planetary_isolatability = true (a planet must still build and launch rockets and make electricity from its own resources); others keep their non-isolatable counterpart.
--   3. Nothing for nodes of a feature a planetary change moves (built with planetary_feature), since those follow their feature.
-- moved_features is the set of planetary_feature names being moved
-- Home contexts keep nothing of their own, as for kept_part
protection.planetary_kept_context = function(node, context, moved_features)
    if node.planetary_feature ~= nil and moved_features[node.planetary_feature] ~= nil then
        return nil
    end
    if top.context_home(context) ~= nil then
        return nil
    end
    if node.keep_planetary_isolatability == true or not protection.is_isolatable_context(context) then
        return context
    end
    return protection.without_isolatability(context)
end

-- The context with the same abilities but isolatability, in room (default: the context's own room), like "room | 11" --> "room | 01"
-- Anything reachable isolatably is also reachable without isolatability, so this pebble exists whenever the original does (in the same room)
protection.without_isolatability = function(context, room)
    local abilities = top.context_abilities(context)
    room = room or top.context_room(context)
    -- A simple context is just its room
    if abilities == nil then
        return room
    end
    return top.context_key(room, string.sub(abilities, 1, top.ISOLATABILITY - 1) .. "0" .. string.sub(abilities, top.ISOLATABILITY + 1))
end

return protection
