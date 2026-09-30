-- Military rebalance (config.military_rebalance): enemies spawned away from their home planet come in their home spawners' numbers, at their new planet's strength
-- Entity randomization's spawn slots are what move units between spawners (randomizations/graph/unified/handlers/entity.lua), and randomizations/graph/unified/handler-helpers/military.lua applies this to the game
-- Everything here works on plain tables (spawn points as acquisition.read_spawn_definition gives them, and a few prototype fields), so lib/test-military.lua can test it outside the game
-- A spawner's spawns are a list of entries {unit = ..., points = ...}

local acquisition = require("lib/logic/acquisition")

local military = {}

-- A spawner's unit limits (EnemySpawnerPrototype): how many units it keeps (owned), and how many friendly units around it stop it spawning (friends)
-- Defensive units (is_defensive) are also held to the defensive versions, which default to the others
military.spawner_limits = function(spawner)
    return {
        owned = spawner.max_count_of_owned_units,
        owned_defensive = spawner.max_count_of_owned_defensive_units or spawner.max_count_of_owned_units,
        friends = spawner.max_friends_around_to_spawn,
        friends_defensive = spawner.max_defensive_friends_around_to_spawn or spawner.max_friends_around_to_spawn,
    }
end

-- Writes limits (as spawner_limits reads them) into a spawner
military.set_spawner_limits = function(spawner, limits)
    spawner.max_count_of_owned_units = limits.owned
    spawner.max_count_of_owned_defensive_units = limits.owned_defensive
    spawner.max_friends_around_to_spawn = limits.friends
    spawner.max_defensive_friends_around_to_spawn = limits.friends_defensive
end

-- Whether a unit is defensive: it doesn't join attack groups (UnitAISettings::join_attacks, true by default), like wrigglers
military.is_defensive = function(unit)
    return unit.ai_settings ~= nil and unit.ai_settings.join_attacks == false
end

-- The loosest of several spawners' limits, limit by limit, since a unit several spawners spawn comes in the numbers of whichever keeps the most
military.loosest_limits = function(limits_list)
    local loosest = {}
    for _, limits in pairs(limits_list) do
        for limit, value in pairs(limits) do
            loosest[limit] = math.max(loosest[limit] or value, value)
        end
    end
    return loosest
end

-- Evolutions where a share of a spawner's spawns can peak: between points every weight is linear, so a share only peaks at a point, just before one (a unit starting with weight above 0 jumps in there), or at the ends
local function sample_evolutions(entries)
    local evolutions = {
        0,
        1,
    }
    for _, entry in pairs(entries) do
        for _, point in pairs(entry.points) do
            for _, evolution in pairs({
                point.evolution - 1e-6,
                point.evolution,
                point.evolution + 1e-6,
            }) do
                table.insert(evolutions, math.min(1, math.max(0, evolution)))
            end
        end
    end
    table.sort(evolutions)
    return evolutions
end

-- The limits each class of unit is held to (see spawner_limits)
local limits_of_class = {
    attacking = {
        "owned",
        "friends",
    },
    defensive = {
        "owned_defensive",
        "friends_defensive",
    },
}

-- A spawner's limits once it spawns units from other spawners (foreign units), so that on average, at every evolution, it keeps no more of them than their home spawners would
-- limits: the spawner's own (spawner_limits); entries: what it spawns, each also with defensive (is_defensive) and home (its home spawners' loosest_limits, or nil for the spawner's own units)
-- A foreign unit making up share of its class's spawns at some evolution fills share / (its home's limit) of each limit of its class, so each limit becomes the largest whole number their shares fit in at every evolution
-- Limits never go above the spawner's own or below 1, and the defensive ones stay within the others, as their defaults do
military.limits_with_foreign_units = function(limits, entries)
    local new_limits = table.deepcopy(limits)
    for class, class_limits in pairs(limits_of_class) do
        local members = {}
        for _, entry in pairs(entries) do
            if (class == "defensive") == (entry.defensive == true) then
                table.insert(members, entry)
            end
        end
        local evolutions = sample_evolutions(members)
        for _, limit in pairs(class_limits) do
            local peak = 0
            for _, evolution in pairs(evolutions) do
                local total = 0
                for _, member in pairs(members) do
                    total = total + acquisition.spawn_weight_at(member.points, evolution)
                end
                if total > 0 then
                    local filled = 0
                    for _, member in pairs(members) do
                        if member.home ~= nil then
                            filled = filled + acquisition.spawn_weight_at(member.points, evolution) / total / math.max(1, member.home[limit])
                        end
                    end
                    peak = math.max(peak, filled)
                end
            end
            if peak > 0 then
                new_limits[limit] = math.min(limits[limit], math.max(1, math.floor(1 / peak + 1e-9)))
            end
        end
    end
    new_limits.owned_defensive = math.min(new_limits.owned_defensive, new_limits.owned)
    new_limits.friends_defensive = math.min(new_limits.friends_defensive, new_limits.friends)
    return new_limits
end

-- The share of a spawner's spawns the entry at index makes up at an evolution, or nil when the spawner spawns nothing then
military.share_at = function(entries, index, evolution)
    local total = 0
    for _, entry in pairs(entries) do
        total = total + acquisition.spawn_weight_at(entry.points, evolution)
    end
    if total <= 0 then
        return nil
    end
    return acquisition.spawn_weight_at(entries[index].points, evolution) / total
end

-- Where the entry at index makes up most of its spawner's spawns: the earliest evolution of its highest share, and that share (nil and 0 if it never spawns)
military.peak_of = function(entries, index)
    local peak_evolution
    local peak_share = 0
    for _, evolution in pairs(sample_evolutions(entries)) do
        local share = military.share_at(entries, index, evolution)
        if share ~= nil and share > peak_share + 1e-12 then
            peak_evolution = evolution
            peak_share = share
        end
    end
    return peak_evolution, peak_share
end

-- The mean of a value over what some spawners spawn at an evolution: each spawner's spawns weighted by spawn weight, then the spawners alike
-- spawners: a list of spawners' entries; value_of(unit): the unit's value, or nil to leave it out (like units that don't join attacks, for attack costs)
-- Returns nil when none of the spawners spawns a unit with a value then
military.mean_at = function(spawners, value_of, evolution)
    local sum = 0
    local count = 0
    for _, entries in pairs(spawners) do
        local total = 0
        local weighted = 0
        for _, entry in pairs(entries) do
            local value = value_of(entry.unit)
            if value ~= nil then
                local weight = acquisition.spawn_weight_at(entry.points, evolution)
                total = total + weight
                weighted = weighted + weight * value
            end
        end
        if total > 0 then
            sum = sum + weighted / total
            count = count + 1
        end
    end
    if count == 0 then
        return nil
    end
    return sum / count
end

-- Damage a trigger does per hit: every damage effect's amount once, following what it delivers to another prototype (prototype_of(type, name) gives that prototype, or nil)
-- A delivery handing on to another prototype names it in the field its type is called (a projectile delivery's projectile, a stream's stream, a beam's beam), so any such field is followed
-- Heals (negative amounts) are left out, and so are fires and stickers it creates, which only hurt what stands in them over time
military.trigger_damage = function(trigger, prototype_of, seen)
    seen = seen or {}
    if type(trigger) ~= "table" or seen[trigger] ~= nil then
        return 0
    end
    seen[trigger] = true
    local damage = 0
    if trigger.type == "damage" and type(trigger.damage) == "table" and (trigger.damage.amount or 0) > 0 then
        damage = damage + trigger.damage.amount
    end
    if type(trigger.type) == "string" and type(trigger[trigger.type]) == "string" then
        damage = damage + military.trigger_damage(prototype_of(trigger.type, trigger[trigger.type]), prototype_of, seen)
    end
    for _, value in pairs(trigger) do
        damage = damage + military.trigger_damage(value, prototype_of, seen)
    end
    return damage
end

-- A unit's damage per second: its attack's damage per hit (times its damage_modifier) every cooldown ticks, or nil if it has no attack with a cooldown
-- A spider unit also stomps with its legs while attacking, which damage_modifier doesn't reach; legs land at their own pace, which the data doesn't give, so one leg's stomp counts per attack
military.damage_per_second = function(unit, prototype_of)
    local attack = unit.attack_parameters
    if attack == nil or attack.cooldown == nil or attack.cooldown <= 0 then
        return nil
    end
    local per_hit = (attack.damage_modifier or 1) * military.trigger_damage(attack.ammo_type, prototype_of)
    if unit.spider_engine ~= nil and unit.spider_engine.legs ~= nil then
        local legs = unit.spider_engine.legs
        if legs[1] == nil then
            legs = {
                legs,
            }
        end
        local stomps = 0
        for _, leg in pairs(legs) do
            stomps = stomps + military.trigger_damage(leg.leg_hit_the_ground_when_attacking_trigger, prototype_of)
        end
        per_hit = per_hit + stomps / #legs
    end
    return per_hit * 60 / attack.cooldown
end

-- How much a unit's health or damage scales (the user's rule): enemies on the starting planet that aren't from it scale down, and the starting planet's own enemies scale up once they're only elsewhere; an enemy on both scales down, to be safe
-- Strengths are enemies' mean health, or mean damage per second, for health and damage apart (mean_at) where the unit makes up most of its spawner (peak_of): home_strength at home, and slots its foreign spawners, each {strength = ..., on_start = whether that spawner is on the starting planet}
-- home_on_start: whether one of its home spawners is on the starting planet; now_on_start: whether one of the spawners spawning it now is, home ones included
-- Scaling down never goes above 1 and scaling up never below, and the slot asking for the least wins, so a unit is never stronger than its weakest place asks
military.strength_factor = function(home_strength, slots, home_on_start, now_on_start)
    if home_strength == nil or home_strength <= 0 then
        return 1
    end
    local factor
    if now_on_start and not home_on_start then
        for _, slot in pairs(slots) do
            if slot.on_start and slot.strength ~= nil then
                factor = math.min(factor or 1, slot.strength / home_strength)
            end
        end
        return math.min(1, factor or 1)
    end
    if home_on_start and not now_on_start then
        for _, slot in pairs(slots) do
            if slot.strength ~= nil then
                factor = math.min(factor or math.huge, slot.strength / home_strength)
            end
        end
        return math.max(1, factor or 1)
    end
    return 1
end

-- What a unit costs to join attacks (absorptions_to_join_attack) in a pollutant its new spawner absorbs: its home cost times the new planet's usual cost (new_usual) over its home planet's (home_usual), each where it spawns most
-- Returns nil when any of them is unknown
military.matched_cost = function(home_cost, home_usual, new_usual)
    if home_cost == nil or home_usual == nil or new_usual == nil or home_usual <= 0 then
        return nil
    end
    return home_cost * new_usual / home_usual
end

-- Health rounds to whole points, at least 1
military.round_health = function(health)
    return math.max(1, math.floor(health + 0.5))
end

-- Costs to join attacks round to tenths, at least a tenth, since a cost of 0 would join attacks for free
military.round_cost = function(cost)
    return math.max(0.1, math.floor(cost * 10 + 0.5) / 10)
end

return military
