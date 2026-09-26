-- Which parts of mechanic contexts graph randomization must keep (the one place this rule lives)
-- Rooms and automatability are always kept; isolatability is kept everywhere with constants.keep_isolatability, or else only for nodes built with keep_isolatability = true (see lib/logic)
-- Used by promotion (what it promises), monotone matching (its hard set), first pass's gate and the mechanic context check

local constants = require("helper-tables/constants")
local top = require("lib/graph/context-sort")

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
protection.is_hard_mechanic_pebble = function(node, context)
    return not protection.is_isolatable_context(context) or protection.protects_isolatability(node)
end

-- The part of a context that must be kept for the node: "room | ia" becomes "room | ?a" when the node's isolatability isn't protected
protection.kept_part = function(node, context)
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

return protection
