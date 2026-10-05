-- Fixed target workloads, including shared-health bodies and threats spawned on death.
-- Recreate the resolver after prototype changes; memoized counts belong to one candidate.

local targets = {}

local function finite(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function positive(value)
    return finite(value) and value > 0
end

local function sorted_keys(values)
    local names = {}
    for name, _ in pairs(values) do
        table.insert(names, name)
    end
    table.sort(names)
    return names
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
    local max_count = options.max_count or 1000000000
    local visited = 0
    local cache, active, variants = {}, {}, {}
    local effects_cache, effects_active = {}, {}
    -- Metadata stays separate from entity-name keys, which mods may freely choose.
    local phases_of = {}
    local resolve, effects, created
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

    local function merge(result, child, multiplier, phase_shift)
        for name, amount in pairs(child) do
            local count = (result[name] or 0) + amount * multiplier
            if not positive(count) or count % 1 ~= 0 or count > max_count then
                return nil, "target-count-budget"
            end
            result[name] = count
        end
        phases_of[result] = phases_of[result] or {}
        for phase, counts in pairs(phases_of[child] or {}) do
            local destination = phase + (phase_shift or 0)
            if destination > max_depth then
                return nil, "target-depth-budget"
            end
            local phase_counts = phases_of[result][destination] or {}
            phases_of[result][destination] = phase_counts
            for name, amount in pairs(counts) do
                phase_counts[name] = (phase_counts[name] or 0) + amount * multiplier
            end
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
        -- Asteroids need no attack_parameters to remain part of the clearing workload.
        if entity.max_health ~= nil or entity.type == "asteroid" or entity.type == "unit" or entity.type == "spider-unit" or entity.segment_engine ~= nil then
            return resolve(name, depth + 1)
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
                result, reason = merge(result, child, 1)
                if result == nil then
                    break
                end
            end
        elseif value.type == "create-entity" or value.type == "create-explosion" then
            result, reason = created(value.entity_name, depth + 1)
            if result ~= nil and value.non_colliding_fail_result ~= nil then
                -- Count both possible branches; this cannot understate the spawn workload.
                child, reason = effects(value.non_colliding_fail_result, depth + 1)
                if child == nil then
                    result = nil
                else
                    result, reason = merge({}, result, 1)
                    if result ~= nil then
                        result, reason = merge(result, child, 1)
                    end
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
                    result, reason = merge({}, result, 1)
                    if result ~= nil then
                        result, reason = merge(result, child, 1)
                    end
                end
            end
        else
            okay, reason = visual(value)
            if okay ~= true then
                result = nil
            end
        end
        if result ~= nil and next(result) ~= nil and value.type ~= nil then
            -- Upper bound: every nonzero-probability spawn occurs at its maximum repeat count.
            -- TriggerEffectItem + CreateEntityTriggerEffectItem::offsets (Factorio 2.1).
            local probability = value.probability or 1
            local repeats = value.repeat_count or 1
            local deviation = value.repeat_count_deviation or 0
            local offsets = value.offsets ~= nil and #value.offsets or 1
            if not finite(probability) or probability < 0 or probability > 1 or not finite(repeats) or repeats < 0 or not finite(deviation) or deviation < 0 then
                result, reason = nil, "invalid-target-repeat"
            elseif probability == 0 or repeats + deviation == 0 or offsets == 0 then
                result = {}
            else
                result, reason = merge({}, result, math.ceil(repeats + deviation) * offsets)
            end
        end
        effects_active[value] = nil
        effects_cache[value] = {
            result = result,
            reason = reason,
        }
        return result, reason
    end

    local function lifecycle(entity, depth)
        if entity.attack_reaction ~= nil and next(entity.attack_reaction) ~= nil then
            return nil, "unsupported-target-reaction"
        end
        local safe, reason = visual(entity.damaged_trigger_effect)
        if safe ~= true then
            return nil, reason
        end
        local result
        result, reason = effects(entity.dying_trigger_effect, depth + 1)
        if result == nil then
            return nil, reason
        end
        result, reason = merge({}, result, 1)
        if result == nil then
            return nil, reason
        end
        local created_counts
        created_counts, reason = effects(entity.created_effect, depth + 1)
        if created_counts == nil then
            return nil, reason
        end
        result, reason = merge(result, created_counts, 1)
        if result == nil then
            return nil, reason
        end
        local explosions = entity.dying_explosion
        if type(explosions) == "string" or (type(explosions) == "table" and explosions.name ~= nil) then
            explosions = { explosions }
        end
        local names = {}
        for _, explosion in pairs(explosions or {}) do
            table.insert(names, type(explosion) == "string" and explosion or explosion.name)
        end
        local corpses = entity.corpse
        if type(corpses) == "string" then
            corpses = { corpses }
        end
        for _, name in pairs(corpses or {}) do
            table.insert(names, name)
        end
        for _, name in pairs(names) do
            local child
            child, reason = created(name, depth + 1)
            if child == nil then
                return nil, reason
            end
            result, reason = merge(result, child, 1)
            if result == nil then
                return nil, reason
            end
        end
        return result
    end

    resolve = function(name, depth)
        local memo = cache[name]
        if memo ~= nil then
            return memo.result, memo.reason
        end
        if active[name] == true then
            return nil, "target-spawn-cycle"
        end
        local okay, reason = budget(depth)
        if okay ~= true then
            return nil, reason
        end
        local entity = entity_of(name)
        if entity == nil then
            return nil, "missing-target"
        end
        active[name] = true
        local parts = { entity }
        local result = { [name] = 1 }
        phases_of[result] = { [0] = { [name] = 1 } }
        if entity.segment_engine ~= nil then
            -- One head health/regen pool; damage on individual parts reaches that shared pool.
            -- https://www.factorio.com/blog/post/fff-429 (Combat Clarity Improvements)
            -- https://lua-api.factorio.com/latest/classes/LuaSegmentedUnit.html
            local segments = entity.segment_engine.segments
            if type(segments) ~= "table" or #segments > 63 then
                result, reason = nil, "invalid-segment-engine"
            else
                for _, specification in pairs(segments) do
                    local part = entity_of(specification.segment)
                    if part == nil then
                        result, reason = nil, "missing-segment"
                        break
                    end
                    if part.segment_engine ~= nil then
                        result, reason = nil, "nested-segment-engine"
                        break
                    end
                    table.insert(parts, part)
                end
            end
        end
        if result ~= nil then
            for _, part in pairs(parts) do
                local child
                child, reason = lifecycle(part, depth + 1)
                if child == nil then
                    result = nil
                    break
                end
                -- Waiting for every parent in a generation to die is a valid conservative schedule.
                result, reason = merge(result, child, 1, 1)
                if result == nil then
                    break
                end
            end
        end
        active[name] = nil
        cache[name] = {
            result = result,
            reason = reason,
        }
        variants[name] = parts
        return result, reason
    end

    resolver.workload = function(roster)
        if type(roster) ~= "table" or #roster == 0 then
            return nil, "missing-workload"
        end
        local counts = {}
        for _, target in pairs(roster) do
            if type(target.entity) ~= "string" or not positive(target.amount) or target.amount % 1 ~= 0 then
                return nil, "invalid-target"
            end
            local expanded, reason = resolve(target.entity, 1)
            if expanded == nil then
                return nil, reason
            end
            counts, reason = merge(counts, expanded, target.amount)
            if counts == nil then
                return nil, reason
            end
        end
        local result = {}
        for _, name in pairs(sorted_keys(counts)) do
            local phases = {}
            for phase, phase_counts in pairs(phases_of[counts] or {}) do
                if phase_counts[name] ~= nil then
                    phases[phase] = phase_counts[name]
                end
            end
            table.insert(result, {
                entity = name,
                amount = counts[name],
                prototype = entity_of(name),
                parts = variants[name],
                phases = phases,
            })
        end
        return result
    end
    return resolver
end

-- Assign a repeated job to fixed teams without allocating one object per target.
-- The completion-time threshold gives an integer assignment for the whole batch.
local function schedule_batch(loads, seconds, amount)
    local function earliest()
        local best = 1
        for index = 2, #loads do
            if loads[index] < loads[best] then
                best = index
            end
        end
        return best
    end
    if #loads == 1 then
        loads[1] = loads[1] + seconds * amount
        return
    end
    if amount <= #loads * 4 then
        for _ = 1, amount do
            local index = earliest()
            loads[index] = loads[index] + seconds
        end
        return
    end
    local first = loads[earliest()]
    local low, high = first, first + seconds * amount
    local function capacity(finish)
        local total = 0
        for _, load in pairs(loads) do
            total = total + math.min(amount, math.max(0, math.floor((finish - load) / seconds)))
            if total >= amount then
                return total
            end
        end
        return total
    end
    for _ = 1, 52 do
        local middle = low + (high - low) / 2
        if middle == low or middle == high then
            break
        end
        if capacity(middle) >= amount then
            high = middle
        else
            low = middle
        end
    end
    local remaining = amount
    for index, load in pairs(loads) do
        local assigned = math.min(remaining, math.max(0, math.floor((high - load) / seconds)))
        loads[index] = load + assigned * seconds
        remaining = remaining - assigned
    end
    if remaining > 0 then
        -- Floating-point boundary cases still produce a complete, valid assignment.
        local index = earliest()
        loads[index] = loads[index] + remaining * seconds
    end
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
    -- Every counted box also overlaps the line's width, without borrowing hits from other roster entities.
    return head_distance + segment.center <= line.range and segment.shape.left < line.width / 2 and segment.shape.right > -line.width / 2
end

-- Prepare costs for an already expanded workload, so mixed batteries can reuse one dependency graph.
targets.prepare = function(profile, workload, options)
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
    if type(workload) ~= "table" or #workload == 0 then
        return nil, "missing-workload"
    end
    local stats = {}
    for _, target in pairs(workload) do
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
                    if layout == nil then
                        layout, reason = segment_layout(target.parts)
                    end
                    if layout == nil then
                        return nil, reason
                    end
                    line_packets[index] = true
                end
            end
        end
        local resistance_maps = {}
        for _, part in pairs(target.parts) do
            local map = {}
            for _, resistance in pairs(part.resistances or {}) do
                if map[resistance.type] ~= nil then
                    return nil, "duplicate-resistance"
                end
                map[resistance.type] = resistance
            end
            resistance_maps[part] = map
        end
        local per_shot = math.huge
        local hit_parts = segment_aim == "head" and { target.prototype } or target.parts
        for _, part in pairs(hit_parts) do
            local resistances = resistance_maps[part]
            local damage = 0
            for index, packet in pairs(profile.packets) do
                if not positive(packet.count) or packet.count % 1 ~= 0 then
                    return nil, "invalid-packet-count"
                end
                local amount, reason
                amount, reason = packet_damage(packet.amount, resistances[packet.type])
                if amount == nil then
                    return nil, reason
                end
                if line_packets[index] ~= true then
                    damage = damage + amount * packet.count
                end
                if not finite(damage) then
                    return nil, "invalid-packet-damage"
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
        stats[target.entity] = {
            target = target,
            health = health,
            healing = healing,
            healing_margin = healing_margin,
            per_shot = per_shot,
            line_hits = line_hits,
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
            local net = volley_damage - healing * interval
            if not positive(net) then
                return nil, "insufficient-damage"
            end
            -- The first volley removes damage from full health; prior warmup/flight cannot add health.
            -- Each additional volley pays one firing interval of healing, with one cadence margin over the whole span.
            local remaining = health - volley_damage + arrival_healing + stat.healing_margin
            volleys = 1 + math.ceil(remaining / net)
        end
        local seconds = warmup + delay + volleys * interval
        if not positive(seconds) then
            return nil, "invalid-clear-time"
        end
        return seconds
    end

    local evaluator = {}
    evaluator.shot_damage = function(name)
        local stat = stats[name]
        if stat == nil then
            return nil, "unknown-prepared-target"
        end
        return stat.per_shot, stat.line_hits
    end
    local costs = {}
    evaluator.seconds = function(name, team_size)
        if stats[name] == nil then
            return nil, "unknown-prepared-target"
        end
        if not positive(team_size) or team_size % 1 ~= 0 or team_size > (options.max_team_sizes or 64) then
            return nil, "invalid-deployment-count"
        end
        costs[name] = costs[name] or {}
        local memo = costs[name][team_size]
        if memo == nil then
            local seconds, reason = target_seconds(stats[name], team_size)
            memo = {
                seconds = seconds,
                reason = reason,
            }
            costs[name][team_size] = memo
        end
        return memo.seconds, memo.reason
    end

    -- Independent jobs only; callers must serialize dependency phases before using this API.
    evaluator.schedule = function(counts, deployment_count, fixed_team_size)
        if not positive(deployment_count) or deployment_count % 1 ~= 0 then
            return nil, "invalid-deployment-count"
        end
        if deployment_count > (options.max_team_sizes or 64) then
            return nil, "deployment-budget"
        end
        if next(counts) == nil then
            return 0
        end
        if fixed_team_size ~= nil and (not positive(fixed_team_size) or fixed_team_size % 1 ~= 0 or fixed_team_size > deployment_count) then
            return nil, "invalid-team-size"
        end
        local best, best_schedule
        local failure = "insufficient-damage"
        for team_size = fixed_team_size or 1, fixed_team_size or deployment_count do
            local teams = math.floor(deployment_count / team_size)
            local jobs = {}
            local feasible = true
            for _, name in pairs(sorted_keys(counts)) do
                local amount = counts[name]
                if not finite(amount) or amount < 0 or amount % 1 ~= 0 or amount > (options.max_count or 1000000000) then
                    return nil, "invalid-target-count"
                end
                if amount > 0 then
                    local seconds, reason = evaluator.seconds(name, team_size)
                    if seconds == nil then
                        feasible = false
                        failure = reason
                        break
                    end
                    table.insert(jobs, {
                        entity = name,
                        amount = amount,
                        seconds = seconds,
                    })
                end
            end
            if feasible then
                table.sort(jobs, function(a, b)
                    if a.seconds ~= b.seconds then
                        return a.seconds > b.seconds
                    end
                    return a.entity < b.entity
                end)
                local loads = {}
                for index = 1, teams do
                    loads[index] = 0
                end
                for _, job in pairs(jobs) do
                    schedule_batch(loads, job.seconds, job.amount)
                end
                local duration = 0
                for _, load in pairs(loads) do
                    duration = math.max(duration, load)
                end
                if finite(duration) and (best == nil or duration < best) then
                    best = duration
                    best_schedule = {
                        team_size = team_size,
                        teams = teams,
                    }
                end
            end
        end
        if best == nil then
            return nil, failure
        end
        return best, nil, best_schedule
    end
    return evaluator
end

targets.clear_seconds = function(profile, roster, entities, deployment_count, options)
    options = options or {}
    if not positive(deployment_count) or deployment_count % 1 ~= 0 then
        return nil, "invalid-deployment-count"
    end
    if deployment_count > (options.max_team_sizes or 64) then
        return nil, "deployment-budget"
    end
    local resolver = targets.new(entities, options)
    local workload, reason = resolver.workload(roster)
    if workload == nil then
        return nil, reason
    end
    local evaluator
    evaluator, reason = targets.prepare(profile, workload, options)
    if evaluator == nil then
        return nil, reason
    end
    local phases = {}
    for _, target in pairs(workload) do
        for phase, amount in pairs(target.phases) do
            phases[phase] = phases[phase] or {}
            phases[phase][target.entity] = amount
        end
    end
    local best, best_schedule
    for team_size = 1, deployment_count do
        local total = 0
        local phase_times = {}
        for _, phase in pairs(sorted_keys(phases)) do
            local seconds
            seconds, reason = evaluator.schedule(phases[phase], deployment_count, team_size)
            if seconds == nil then
                total = nil
                break
            end
            phase_times[phase] = seconds
            total = total + seconds
        end
        if positive(total) and (best == nil or total < best) then
            best = total
            best_schedule = {
                team_size = team_size,
                teams = math.floor(deployment_count / team_size),
                phase_times = phase_times,
            }
        end
    end
    if best == nil then
        return nil, reason or "invalid-clear-time"
    end
    return best, nil, workload, best_schedule
end

return targets
