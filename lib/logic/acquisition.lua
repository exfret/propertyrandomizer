-- Entity acquisition: the ways an entity can come to exist in the world
-- Each way corresponds to logic edges tagged with its kind as acq_kind; these are the slots entity randomization moves entities between
-- The edges go into entity nodes, except for build, which is the edge from each item that places the entity into its entity-build-item node

local acquisition = {}

acquisition.kinds = {
    -- An item places it
    build = true,
    -- Map generation puts it in a room
    autoplace = true,
    -- A unit spawner spawns it (result_units)
    spawn = true,
    -- An item spoils into it (spoil_to_trigger_result), like a biter egg hatching
    spoil = true,
    -- Using a capsule creates it
    capsule = true,
    -- Firing ammo creates it
    ammo = true,
    -- Another entity leaves it behind as its corpse
    corpse = true,
    -- Another entity creates it when dying (dying_trigger_effect)
    dying = true,
    -- A captured unit spawner turns into it
    capture = true,
    -- It spawns in space
    asteroid = true,
    -- It's the player's character
    character = true,
}

-- Tags edge info (or a new table if extra is nil) as an acquisition edge of this kind, erroring on unknown kinds so a typo can't leave an edge untagged
acquisition.tag = function(kind, extra)
    if acquisition.kinds[kind] == nil then
        error("Unknown entity acquisition kind " .. tostring(kind))
    end
    extra = extra or {}
    extra.acq_kind = kind
    return extra
end

-- Spawn weight of spawn points (from read_spawn_definition) at an evolution: linear between points, the last weight after the last point, and none before the first (undocumented, see spawn_class)
acquisition.spawn_weight_at = function(points, evolution)
    if #points == 0 or evolution < points[1].evolution then
        return 0
    end
    for i = 1, #points - 1 do
        local from = points[i]
        local to = points[i + 1]
        if evolution <= to.evolution then
            if to.evolution == from.evolution then
                return to.weight
            end
            return from.weight + (evolution - from.evolution) / (to.evolution - from.evolution) * (to.weight - from.weight)
        end
    end
    return points[#points].weight
end

-- Spawn points that never go below share of their highest weight, keeping the curve's shape otherwise
acquisition.floor_spawn_points = function(points, share)
    local highest = 0
    for _, point in pairs(points) do
        highest = math.max(highest, point.weight)
    end
    local floored = {}
    for _, point in pairs(points) do
        table.insert(floored, {
            evolution = point.evolution,
            weight = math.max(point.weight, share * highest),
        })
    end
    return floored
end

-- Spawn points spawning at least as much as either of two at every evolution, for a spawner that would get two entries for one unit
-- Both curves are linear between their points, so the higher weight at every point of either is at least as high as both in between
acquisition.merge_spawn_points = function(points1, points2)
    local evolutions = {}
    local seen = {}
    for _, points in pairs({
        points1,
        points2,
    }) do
        for _, point in pairs(points) do
            if seen[point.evolution] == nil then
                seen[point.evolution] = true
                table.insert(evolutions, point.evolution)
            end
        end
    end
    table.sort(evolutions)
    local merged = {}
    for _, evolution in pairs(evolutions) do
        table.insert(merged, {
            evolution = evolution,
            weight = math.max(acquisition.spawn_weight_at(points1, evolution), acquisition.spawn_weight_at(points2, evolution)),
        })
    end
    return merged
end

-- A UnitSpawnDefinition for a unit and spawn points (as read_spawn_definition gives them)
acquisition.spawn_definition = function(unit, points)
    local spawn_points = {}
    for _, point in pairs(points) do
        table.insert(spawn_points, {
            evolution_factor = point.evolution,
            spawn_weight = point.weight,
        })
    end
    return {
        unit = unit,
        spawn_points = spawn_points,
    }
end

-- Entity classes a base needs hundreds of, which entity randomization keeps suppliable automatically (see group-supply in lib/logic/entity-supply.lua)
acquisition.bulk_entity_types = {
    ["transport-belt"] = true,
    ["underground-belt"] = true,
    ["splitter"] = true,
    ["lane-splitter"] = true,
    ["loader"] = true,
    ["loader-1x1"] = true,
    ["linked-belt"] = true,
    ["inserter"] = true,
    ["pipe"] = true,
    ["pipe-to-ground"] = true,
    ["heat-pipe"] = true,
    ["electric-pole"] = true,
    ["wall"] = true,
    ["gate"] = true,
    ["solar-panel"] = true,
    ["accumulator"] = true,
}
-- Entities whose own item stacks to at least this many are needed in bulk too, and ones stacking to at most FEW_STACK_SIZE only a few at a time
acquisition.BULK_STACK_SIZE = 100
acquisition.FEW_STACK_SIZE = 5

-- How many of an entity a base needs: "bulk" (hundreds), "some" (tens) or "few" (a handful), from its class and its own item's stack size (nil if it has none)
acquisition.demand_tier = function(entity_type, stack_size)
    if acquisition.bulk_entity_types[entity_type] ~= nil or (stack_size or 0) >= acquisition.BULK_STACK_SIZE then
        return "bulk"
    end
    if stack_size ~= nil and stack_size <= acquisition.FEW_STACK_SIZE then
        return "few"
    end
    return "some"
end

-- Which kinds of slots can supply an entity of each demand tier
-- Items and biters (renewable) can supply anything, since the balance layer keeps some member of every bulk class suppliable automatically (group-supply)
-- What's found in the wild is finite, so it's only for entities needed in tens or fewer
local supplies = {
    bulk = {
        build = true,
        spawn = true,
    },
    some = {
        build = true,
        spawn = true,
        autoplace = true,
    },
    few = {
        build = true,
        spawn = true,
        autoplace = true,
    },
}
acquisition.can_supply = function(tier, slot_kind)
    return supplies[tier][slot_kind] ~= nil
end

-- Cost (lib/cost/material-costs) of loot a carrier drops per point of its health, so tougher carriers drop more
acquisition.LOOT_COST_PER_HEALTH = 0.37
-- Bulk entities are needed in hundreds, so carriers drop more of them
acquisition.BULK_LOOT_FACTOR = 2
-- A unit only carries an item if killing it is worth at least this much of one, so weak units don't drop expensive entities
acquisition.MIN_LOOT = 0.25

-- How many of an item a carrier with this much health drops per kill (at least 1, at most a stack), with the item's cost (known, see worth_carrying) and its entity's demand tier
acquisition.loot_amount = function(health, cost, tier, stack_size)
    assert(cost ~= nil, "A carried item needs a known cost (acquisition.worth_carrying)")
    local amount = acquisition.LOOT_COST_PER_HEALTH * health / cost
    if tier == "bulk" then
        amount = amount * acquisition.BULK_LOOT_FACTOR
    end
    return math.max(1, math.min(stack_size, math.floor(amount + 0.5)))
end

-- Whether a unit with this much health is worth making a carrier of an item with this cost
-- An unknown (nil) cost never is, since the loot can't be balanced without it
acquisition.worth_carrying = function(health, cost)
    return cost ~= nil and acquisition.LOOT_COST_PER_HEALTH * health / cost >= acquisition.MIN_LOOT
end

-- An entity salvaged from the wild costs at most this many times what mining the slot's own entity gave, so common things like trees don't give expensive ones
acquisition.SALVAGE_COST_FACTOR = 25

-- Whether an item with this cost can be salvaged from a slot whose entity mined into items worth yield
-- Salvage worth more than SALVAGE_COST_FACTOR times the yield is never allowed, and neither is an unknown (nil) cost or yield, since then that can't be checked
acquisition.worth_salvaging = function(cost, yield)
    return cost ~= nil and yield ~= nil and cost <= acquisition.SALVAGE_COST_FACTOR * yield
end

-- Index of automatability in edge abilities (top.AUTOMATABILITY in lib/graph/context-sort.lua, which can't be required here since building logic uses this file)
local AUTOMATABILITY = 2

-- Whether slots of this kind give an item that places the entity (only build slots do), rather than the entity itself
acquisition.gives_item = function(kind)
    return kind == "build"
end

-- What connecting a base (a slot's side of an acquisition edge) to a head (an entity's side of one) means, when entity randomization moves an entity to another slot
-- The base and head are nodes from gutils.subdivide_base_head, which carry their edge's acq_kind and abilities
-- Returns nil if the pairing isn't supported, and otherwise { abilities = ... } for the edge connecting them (nil abilities when there are none)
-- A slot giving an item connects to an entity that's built with the slot's own abilities
-- A slot giving the entity connects to an entity that shows up some other way with the slot's own abilities, like autoplace's isolatability
-- A slot giving the entity connects to an entity that's built by salvaging or looting what the slot gives, which can't be automated
-- A slot giving an item can't connect to an entity that isn't built yet, since placing an entity that isn't built in vanilla has placement prereqs logic doesn't have
acquisition.pairing = function(base, head)
    local base_gives_item = acquisition.gives_item(base.acq_kind)
    local head_is_built = acquisition.gives_item(head.acq_kind)
    if base_gives_item and not head_is_built then
        return nil
    end
    local abilities = table.deepcopy(base.abilities)
    if head_is_built and not base_gives_item then
        abilities = abilities or {}
        abilities[AUTOMATABILITY] = false
    end
    return {
        abilities = abilities,
    }
end

-- A UnitSpawnDefinition is {unit = ..., spawn_points = ...} or {unit, spawn_points}, and each SpawnPoint is {evolution_factor = ..., spawn_weight = ...} or {evolution_factor, spawn_weight}
-- Returns the spawned entity's name and its spawn points as {evolution = ..., weight = ...}, in the given (ascending) order
acquisition.read_spawn_definition = function(definition)
    local unit = definition.unit or definition[1]
    local points = {}
    for _, point in pairs(definition.spawn_points or definition[2] or {}) do
        table.insert(points, {
            evolution = point.evolution_factor or point[1],
            weight = point.spawn_weight or point[2],
        })
    end
    return unit, points
end

-- When a spawner spawns something, given its spawn points (from read_spawn_definition):
--   "persistent": at every evolution
--   "transient": from evolution 0, but not at every evolution (like small biters, which stop at 0.6)
--   "late": not at evolution 0 (like big biters)
-- Weights interpolate linearly between points and the last weight holds after the last point, so something spawns at every evolution exactly when the first point is at 0 and no point has zero weight
-- What happens before the first point is undocumented, so a first point above 0 counts as not spawning at 0
-- Evolution can be turned off in map settings, so logic can't count on late spawns
acquisition.spawn_class = function(points)
    if #points == 0 or points[1].evolution > 0 or points[1].weight <= 0 then
        return "late"
    end
    for _, point in pairs(points) do
        if point.weight <= 0 then
            return "transient"
        end
    end
    return "persistent"
end

return acquisition
