-- One target at a time: how long a team of identical weapons takes to kill it, and what it leaves behind that might need killing too.
-- Recreate the resolver after prototype changes; memoized results belong to one candidate.

local categories = require("src/prototypes/categories")

local targets = {}

local function finite(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function positive(value)
    return finite(value) and value > 0
end

-- A conservative lower bound on damage; never credit fractional resistance packets together.
local function packet_damage(amount, resistance)
    resistance = resistance or {}
    local decrease, percent = resistance.decrease or 0, resistance.percent or 0
    if not positive(amount) or not finite(decrease) or decrease < 0 or not finite(percent) or percent < 0 or percent > 100 then
        return nil, "unsupported-resistance"
    end
    return math.max(0, amount - decrease) * (1 - percent / 100)
end

targets.new = function(entities, options)
    options = options or {}
    entities = entities or {}
    local max_nodes = options.max_nodes or 4096
    local max_depth = options.max_depth or 64
    local visited = 0
    local spawn_cache, spawn_active, part_cache = {}, {}, {}
    local effects_cache, effects_active = {}, {}
    local effects, created, spawned
    local resolver = {}

    local function entity_of(name)
        return entities[name] or (options.entity_of and options.entity_of(name))
    end

    local function budget(depth)
        visited = visited + 1
        if depth > max_depth then
            return nil, "target-depth-budget"
        end
        if visited > max_nodes then
            return nil, "target-node-budget"
        end
        return true
    end

    local function union(result, child)
        for name, _ in pairs(child) do
            result[name] = true
        end
        return result
    end

    local function visual(value)
        if value == nil then
            return true
        end
        if options.visual_effect ~= nil then
            return options.visual_effect(value)
        end
        return nil, "unsupported-target-effects"
    end

    -- What putting an entity in the world adds that might need killing: the entity itself if it has health, and what it spawns
    created = function(name, depth)
        local entity = entity_of(name)
        if entity == nil then
            return nil, "missing-created-target"
        end
        -- Basic rocks/remains have no combat behavior, but their created_effect still runs.
        -- https://lua-api.factorio.com/latest/prototypes/SimpleEntityPrototype.html
        if entity.type == "simple-entity" then
            return effects(entity.created_effect, depth + 1)
        end
        if options.visual_entity ~= nil then
            local safe = options.visual_entity(entity)
            if safe == true then
                return {}
            end
        end
        -- These inherit health; default max_health is 10 even when the field is absent.
        -- Asteroids need no attack_parameters to remain targets.
        if entity.max_health ~= nil or entity.type == "asteroid" or entity.type == "unit" or entity.type == "spider-unit" or entity.segment_engine ~= nil then
            local children, reason = spawned(name, depth + 1)
            if children == nil then
                return nil, reason
            end
            return union({ [name] = true }, children)
        end
        return nil, "unsupported-created-target"
    end

    effects = function(value, depth)
        if value == nil then
            return {}
        end
        if type(value) ~= "table" then
            return nil, "invalid-target-effect"
        end
        local memo = effects_cache[value]
        if memo ~= nil then
            return memo.result, memo.reason
        end
        if effects_active[value] == true then
            return nil, "target-effect-cycle"
        end
        local okay, reason = budget(depth)
        if okay ~= true then
            return nil, reason
        end
        effects_active[value] = true
        local result = {}
        local child
        if value.type == nil then
            for _, item in pairs(value) do
                child, reason = effects(item, depth + 1)
                if child == nil then
                    result = nil
                    break
                end
                union(result, child)
            end
        elseif value.type == "create-entity" or value.type == "create-explosion" then
            result, reason = created(value.entity_name, depth + 1)
            if result ~= nil and value.non_colliding_fail_result ~= nil then
                -- Count both possible branches.
                child, reason = effects(value.non_colliding_fail_result, depth + 1)
                if child == nil then
                    result = nil
                else
                    result = union(union({}, result), child)
                end
            end
        elseif value.type == "create-asteroid-chunk" then
            -- Chunks are AsteroidChunkPrototype resources, not health-bearing entities.
            -- https://lua-api.factorio.com/latest/prototypes/AsteroidChunkPrototype.html
        elseif value.type == "nested-result" then
            result, reason = effects(value.action, depth + 1)
        elseif value.type == "direct" then
            result, reason = effects(value.action_delivery, depth + 1)
        elseif value.type == "instant" then
            result, reason = effects(value.target_effects, depth + 1)
            if result ~= nil then
                child, reason = effects(value.source_effects, depth + 1)
                if child == nil then
                    result = nil
                else
                    result = union(union({}, result), child)
                end
            end
        else
            okay, reason = visual(value)
            if okay ~= true then
                result = nil
            end
        end
        if result ~= nil and value.type ~= nil then
            -- Any nonzero-probability spawn can happen.
            local probability = value.probability or 1
            if not finite(probability) or probability < 0 or probability > 1 then
                result, reason = nil, "invalid-target-repeat"
            elseif probability == 0 or (value.repeat_count or 1) + (value.repeat_count_deviation or 0) == 0 or (value.offsets ~= nil and #value.offsets == 0) then
                result = {}
            end
        end
        effects_active[value] = nil
        effects_cache[value] = {
            result = result,
            reason = reason,
        }
        return result, reason
    end

    -- An entity and its segments, after checking that their reactions to damage are harmless
    local function parts_of(name)
        local memo = part_cache[name]
        if memo ~= nil then
            return memo.result, memo.reason
        end
        local entity = entity_of(name)
        local parts, reason
        if entity == nil then
            reason = "missing-target"
        else
            parts = { entity }
            if entity.segment_engine ~= nil then
                -- One head health/regen pool; damage on individual parts reaches that shared pool.
                -- https://www.factorio.com/blog/post/fff-429 (Combat Clarity Improvements)
                -- https://lua-api.factorio.com/latest/classes/LuaSegmentedUnit.html
                local segments = entity.segment_engine.segments
                if type(segments) ~= "table" or #segments > 63 then
                    parts, reason = nil, "invalid-segment-engine"
                else
                    for _, specification in pairs(segments) do
                        local part = entity_of(specification.segment)
                        if part == nil then
                            parts, reason = nil, "missing-segment"
                            break
                        end
                        if part.segment_engine ~= nil then
                            parts, reason = nil, "nested-segment-engine"
                            break
                        end
                        table.insert(parts, part)
                    end
                end
            end
            for _, part in pairs(parts or {}) do
                if part.attack_reaction ~= nil and next(part.attack_reaction) ~= nil then
                    parts, reason = nil, "unsupported-target-reaction"
                    break
                end
                local safe
                safe, reason = visual(part.damaged_trigger_effect)
                if safe ~= true then
                    parts = nil
                    break
                end
            end
        end
        part_cache[name] = {
            result = parts,
            reason = reason,
        }
        return parts, reason
    end

    -- What an entity's creation and death (its segments' too) spawn that might need killing, all the way down
    spawned = function(name, depth)
        local memo = spawn_cache[name]
        if memo ~= nil then
            return memo.result, memo.reason
        end
        if spawn_active[name] == true then
            return nil, "target-spawn-cycle"
        end
        local okay, reason = budget(depth)
        if okay ~= true then
            return nil, reason
        end
        local parts
        parts, reason = parts_of(name)
        if parts == nil then
            return nil, reason
        end
        spawn_active[name] = true
        local result = {}
        for _, part in pairs(parts) do
            local names = {}
            local explosions = part.dying_explosion
            if type(explosions) == "string" or (type(explosions) == "table" and explosions.name ~= nil) then
                explosions = { explosions }
            end
            for _, explosion in pairs(explosions or {}) do
                table.insert(names, type(explosion) == "string" and explosion or explosion.name)
            end
            -- Corpses are entities too, and their inherited created_effect can run on death.
            -- https://lua-api.factorio.com/latest/prototypes/EntityWithHealthPrototype.html#corpse
            local corpses = part.corpse
            if type(corpses) == "string" then
                corpses = { corpses }
            end
            for _, corpse in pairs(corpses or {}) do
                table.insert(names, corpse)
            end
            local child
            for _, value in pairs({
                part.dying_trigger_effect,
                part.created_effect,
            }) do
                child, reason = effects(value, depth + 1)
                if child == nil then
                    result = nil
                    break
                end
                union(result, child)
            end
            for _, child_name in pairs(result ~= nil and names or {}) do
                child, reason = created(child_name, depth + 1)
                if child == nil then
                    result = nil
                    break
                end
                union(result, child)
            end
            if result == nil then
                break
            end
        end
        spawn_active[name] = nil
        spawn_cache[name] = {
            result = result,
            reason = reason,
        }
        return result, reason
    end

    -- The target an evaluator scores: its prototype and parts (a segmented unit's head first)
    resolver.target = function(name)
        local parts, reason = parts_of(name)
        if parts == nil then
            return nil, reason
        end
        return {
            entity = name,
            prototype = parts[1],
            parts = parts,
        }
    end

    -- Names of everything the entity's creation and death can spawn that might need killing, closed over what those spawn
    resolver.spawned = function(name)
        return spawned(name, 1)
    end
    return resolver
end

local function segment_shape(part)
    local box = part.collision_box
    if type(box) ~= "table" or (box.orientation or box[3] or 0) ~= 0 then
        return nil, "unsupported-segment-geometry"
    end
    local first, last = box.left_top or box[1], box.right_bottom or box[2]
    if type(first) ~= "table" or type(last) ~= "table" then
        return nil, "unsupported-segment-geometry"
    end
    local left, top = first.x or first[1], first.y or first[2]
    local right, bottom = last.x or last[1], last.y or last[2]
    local forward, backward = part.forward_padding or 0, part.backward_padding or 0
    if not finite(left) or not finite(top) or not finite(right) or not finite(bottom) or not finite(forward) or not finite(backward) then
        return nil, "unsupported-segment-geometry"
    end
    if left > 0 or right < 0 or top > 0 or bottom < 0 or left >= right or top >= bottom then
        return nil, "unsupported-segment-geometry"
    end
    return {
        left = left,
        right = right,
        height = bottom - top,
        forward = forward,
        backward = backward,
    }
end

-- The benchmark faces the head toward the shooter with every body segment straight behind it.
-- Scale is already baked into each prototype's collision box and padding (SegmentSpecification only names the prototype).
-- Empirically verified with nine straight-body cases on Factorio 2.1.20, 2026-10-05.
-- Gaps use half of both collision heights, half of the previous backward padding, and all current forward padding.
-- Independent padding changes and doubled/asymmetric boxes were checked using LuaSurface.create_segmented_unit(extended=true).
-- https://lua-api.factorio.com/latest/types/SegmentSpecification.html
-- https://lua-api.factorio.com/latest/prototypes/SegmentPrototype.html#backward_padding
local function segment_layout(parts)
    local result, previous = {}, nil
    local center = 0
    for index, part in pairs(parts) do
        local shape, reason = segment_shape(part)
        if shape == nil then
            return nil, reason
        end
        if previous ~= nil then
            local gap = (previous.height + previous.backward + shape.height) / 2 + shape.forward
            if not positive(gap) then
                return nil, "unsupported-segment-geometry"
            end
            -- Reserve four 1/256-tile steps per link for box-coordinate and center rounding.
            -- https://lua-api.factorio.com/latest/types/MapPosition.html
            center = center + gap + 4 / 256
        end
        result[index] = {
            center = center,
            shape = shape,
        }
        previous = shape
    end
    return result
end

local function line_intersects(segment, head_distance, line)
    -- Center inclusion guarantees an intersection; edge-only hits near the endpoint receive no credit.
    -- Every counted box also overlaps the line's width.
    return head_distance + segment.center <= line.range and segment.shape.left < line.width / 2 and segment.shape.right > -line.width / 2
end

local function resistance_map(part)
    local map = {}
    for _, resistance in pairs(part.resistances or {}) do
        if map[resistance.type] ~= nil then
            return nil, "duplicate-resistance"
        end
        map[resistance.type] = resistance
    end
    return map
end

-- Each part's resistances by damage type, worked out once per target table and kept on it, since every weapon reads them
local function resistance_maps_of(target)
    if target.resistance_maps == nil and target.resistance_reason == nil then
        local maps = {}
        for _, part in pairs(target.parts) do
            local map, reason = resistance_map(part)
            if map == nil then
                target.resistance_reason = reason
                return nil, reason
            end
            maps[part] = map
        end
        target.resistance_maps = maps
    end
    return target.resistance_maps, target.resistance_reason
end

-- The head-on body layout, also kept on the target table
local function layout_of(target)
    if target.layout == nil and target.layout_reason == nil then
        target.layout, target.layout_reason = segment_layout(target.parts)
    end
    return target.layout, target.layout_reason
end

-- What one weapon of the profile does to each target (resolver.target results), for evaluator.seconds to turn into kill times
-- A target that can't be scored keeps its reason, without failing the others
targets.prepare = function(profile, target_list, options)
    options = options or {}
    local segment_aim = options.segment_aim or "worst-segment"
    if segment_aim ~= "head" and segment_aim ~= "worst-segment" then
        return nil, "invalid-segment-aim"
    end
    if options.segment_line_geometry ~= nil and options.segment_line_geometry ~= "head-on" then
        return nil, "invalid-segment-line-geometry"
    end
    if type(profile) ~= "table" or type(profile.packets) ~= "table" or #profile.packets == 0 then
        return nil, "missing-workload"
    end
    local interval, delay, warmup = profile.interval_seconds, profile.delay_seconds or 0, profile.warmup_seconds or 0
    if not positive(interval) or not finite(delay) or delay < 0 or not finite(warmup) or warmup < 0 then
        return nil, "invalid-attack-timing"
    end
    for _, packet in pairs(profile.packets) do
        if not positive(packet.count) or packet.count % 1 ~= 0 then
            return nil, "invalid-packet-count"
        end
    end
    local interval_ticks = math.floor(interval * 60 + 0.5)

    local function stat_of(target)
        local health = target.prototype.max_health or 10
        local healing = target.prototype.healing_per_tick or 0
        if not positive(health) or not finite(healing) then
            return nil, "invalid-target"
        end
        -- Ignoring negative regeneration overestimates how hard a target is to clear.
        healing = math.max(0, healing)
        -- Only slow regeneration is batched once per second; other regeneration applies per tick.
        -- https://lua-api.factorio.com/latest/prototypes/EntityWithHealthPrototype.html#healing_per_tick
        local healing_margin = healing * (healing <= 0.0166 and 60 or 1)
        healing = healing * 60
        local layout
        local line_packets = {}
        if options.segment_line_geometry == "head-on" and target.prototype.segment_engine ~= nil then
            for index, packet in pairs(profile.packets) do
                if packet.line ~= nil then
                    if not positive(packet.line.range) or not positive(packet.line.width) or not positive(profile.benchmark_range) then
                        return nil, "invalid-line-geometry"
                    end
                    local reason
                    layout, reason = layout_of(target)
                    if layout == nil then
                        return nil, reason
                    end
                    line_packets[index] = true
                end
            end
        end
        local resistance_maps, reason = resistance_maps_of(target)
        if resistance_maps == nil then
            return nil, reason
        end
        local per_shot = math.huge
        local hit_parts = segment_aim == "head" and { target.prototype } or target.parts
        for _, part in pairs(hit_parts) do
            local resistances = resistance_maps[part]
            local damage = 0
            for index, packet in pairs(profile.packets) do
                local amount, reason = packet_damage(packet.amount, resistances[packet.type])
                if amount == nil then
                    return nil, reason
                end
                if line_packets[index] ~= true then
                    damage = damage + amount * packet.count
                end
            end
            per_shot = math.min(per_shot, damage)
        end
        local line_hits = {}
        for index, packet in pairs(profile.packets) do
            if line_packets[index] == true then
                line_hits[index] = 0
                for part_index, part in pairs(target.parts) do
                    if line_intersects(layout[part_index], profile.benchmark_range, packet.line) then
                        local amount, reason = packet_damage(packet.amount, resistance_maps[part][packet.type])
                        if amount == nil then
                            return nil, reason
                        end
                        per_shot = per_shot + amount * packet.count
                        line_hits[index] = line_hits[index] + 1
                    end
                end
            end
        end
        if not finite(per_shot) then
            return nil, "invalid-packet-damage"
        end
        -- Stickers only stick to some prototype types, and then to the entity itself
        -- One that lasts until the next hit keeps damaging between hits; a shorter one only for its duration
        -- Each application comes damage_interval ticks after the last, so one application is held back as lag
        local dot_rate, dot_lag = 0, 0
        if categories.sticker_targets[target.prototype.type] == true then
            for _, dot in pairs(profile.dots or {}) do
                local amount, reason = packet_damage(dot.amount, resistance_maps[target.prototype][dot.type])
                if amount == nil then
                    return nil, reason
                end
                if amount > 0 then
                    if dot.duration_ticks >= interval_ticks then
                        dot_rate = dot_rate + amount * 60 / dot.interval_ticks
                    else
                        dot_rate = dot_rate + amount * math.floor(dot.duration_ticks / dot.interval_ticks) / interval
                    end
                    dot_lag = dot_lag + amount
                end
            end
        end
        return {
            health = health,
            healing = healing,
            healing_margin = healing_margin,
            per_shot = per_shot,
            line_hits = line_hits,
            dot_rate = dot_rate,
            dot_lag = dot_lag,
        }
    end

    local stats = {}
    for _, target in pairs(target_list) do
        local stat, reason = stat_of(target)
        stats[target.entity] = stat or {
            reason = reason,
        }
    end

    local function target_seconds(stat, team_size)
        local health, healing = stat.health, stat.healing
        local volley_damage = stat.per_shot * team_size
        if not finite(volley_damage) then
            return nil, "invalid-volley-damage"
        end
        -- Healing before the first hit cannot exceed max_health.
        -- A single packet's whole volley arrives together on the fixed unobstructed path.
        -- Multiple packets may have different delivery times, so retain healing between them.
        local separated_packets = delay > 0 and (#profile.packets > 1 or profile.unsynchronized_hits == true)
        local arrival_healing = separated_packets and healing * delay or 0
        local first_health = health + (separated_packets and arrival_healing + stat.healing_margin or 0)
        local volleys = 1
        if volley_damage < first_health then
            -- Stickers don't stack across the team, so their damage isn't multiplied by it
            local net = volley_damage + (stat.dot_rate - healing) * interval
            if not positive(net) then
                return nil, "insufficient-damage"
            end
            -- The first volley removes damage from full health; prior warmup/flight cannot add health.
            -- Each additional volley pays one firing interval of healing, with one cadence margin over the whole span.
            local remaining = health - volley_damage + arrival_healing + stat.healing_margin + stat.dot_lag
            volleys = 1 + math.ceil(remaining / net)
        end
        local seconds = warmup + delay + volleys * interval
        if not positive(seconds) then
            return nil, "invalid-clear-time"
        end
        return seconds
    end

    local evaluator = {}
    -- One weapon's damage per shot to the target, and how many parts each line packet hits
    evaluator.shot_damage = function(name)
        local stat = stats[name]
        if stat == nil then
            return nil, "unknown-prepared-target"
        end
        if stat.per_shot == nil then
            return nil, stat.reason
        end
        return stat.per_shot, stat.line_hits
    end
    -- Seconds for team_size of these weapons to kill the target alone, or nil and why they can't
    evaluator.seconds = function(name, team_size)
        local stat = stats[name]
        if stat == nil then
            return nil, "unknown-prepared-target"
        end
        if stat.per_shot == nil then
            return nil, stat.reason
        end
        if not positive(team_size) or team_size % 1 ~= 0 or team_size > (options.max_team_size or 64) then
            return nil, "invalid-deployment-count"
        end
        return target_seconds(stat, team_size)
    end
    return evaluator
end

return targets
