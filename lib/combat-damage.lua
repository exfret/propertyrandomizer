-- Conservative, bounded summaries of a single source's guaranteed target damage.
-- This module never enumerates weapon/ammo combinations or credits splash damage.
-- Create a fresh resolver for each candidate prototype set; its memoized results belong to that set.

local projectiles = require("lib/combat-projectiles")
local targets = require("lib/combat-targets")

local damage = {}

local function finite(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function positive(value)
    return finite(value) and value > 0
end

local function summary()
    return {
        packets = {},
        delay_seconds = 0,
        delay_per_tile = 0,
    }
end

-- Factorio 2.1 TriggerItem, TriggerEffectItem, TriggerDeliveryItem and AmmoType:
-- https://lua-api.factorio.com/latest/types/TriggerItem.html
-- https://lua-api.factorio.com/latest/types/TriggerEffectItem.html
-- https://lua-api.factorio.com/latest/types/TriggerDeliveryItem.html
-- https://lua-api.factorio.com/latest/types/AmmoType.html
damage.new = function(options)
    options = options or {}
    local max_nodes = options.max_nodes or 65536
    local max_depth = options.max_depth or 64
    local max_packets = options.max_packets or 128
    local cache, active = {}, {}
    local visited = 0
    local resolver = {}
    local walk

    local function merge(result, child, multiplier)
        result.delay_seconds = math.max(result.delay_seconds, child.delay_seconds)
        result.delay_per_tile = math.max(result.delay_per_tile or 0, child.delay_per_tile or 0)
        result.flight_time = projectiles.parallel(result.flight_time, child.flight_time)
        result.unsynchronized_hits = result.unsynchronized_hits or child.unsynchronized_hits
        result.projectile_delivery = result.projectile_delivery or child.projectile_delivery
        if child.max_range ~= nil then
            result.max_range = math.min(result.max_range or child.max_range, child.max_range)
        end
        result.min_range = math.max(result.min_range or 0, child.min_range or 0)
        for _, packet in pairs(child.packets) do
            if #result.packets >= max_packets then
                return nil, "packet-budget"
            end
            local count = packet.count * multiplier
            if not positive(count) then
                return nil, "invalid-repeat-count"
            end
            table.insert(result.packets, {
                type = packet.type,
                amount = packet.amount,
                count = count,
                line = packet.line,
            })
        end
        return result
    end

    local function repetitions(value)
        if value.probability ~= nil and value.probability ~= 1 then
            return nil, "probabilistic-effect"
        end
        if (value.repeat_count_deviation or 0) ~= 0 then
            return nil, "variable-repeat-count"
        end
        local count = value.repeat_count or 1
        if not finite(count) or count < 0 or count % 1 ~= 0 then
            return nil, "invalid-repeat-count"
        end
        return count
    end

    local function harmless(value, _, depth)
        local result, reason = walk(value, "visual", depth)
        if result == nil then
            return nil, reason
        end
        if #result.packets > 0 then
            return nil, "non-target-damage"
        end
        return result
    end

    local function visual(value, kind, depth)
        local incidental = kind == "incidental" or kind == "incidental-entity" or kind == "incidental-particle"
        local effect_kind = incidental and "incidental" or "visual"
        local entity_kind = incidental and "incidental-entity" or "visual-entity"
        local particle_kind = incidental and "incidental-particle" or "visual-particle"
        if kind == "visual-entity" or kind == "incidental-entity" then
            if incidental and value.type == "projectile" then
                local created, reason = walk(value.created_effect, effect_kind, depth + 1)
                if created == nil then
                    return nil, reason
                end
                local action
                action, reason = walk(value.action, effect_kind, depth + 1)
                if action == nil then
                    return nil, reason
                end
                return walk(value.final_action, effect_kind, depth + 1)
            end
            if value.type == "particle-source" then
                -- Particle sources can inherit created_effect and emit particles with their own triggers.
                -- Their optional SmokeSource entries use TrivialSmokeID, so those are visual only.
                -- https://lua-api.factorio.com/latest/prototypes/ParticleSourcePrototype.html
                -- https://lua-api.factorio.com/latest/types/SmokeSource.html
                if value.particle ~= nil then
                    local particle = options.particle_of and options.particle_of(value.particle)
                    if particle == nil then
                        return nil, "missing-particle"
                    end
                    local result, reason = walk(particle, particle_kind, depth + 1)
                    if result == nil then
                        return nil, reason
                    end
                end
                return walk(value.created_effect, effect_kind, depth + 1)
            end
            if value.type ~= "explosion" and value.type ~= "corpse" then
                return nil, "created-entity-effect"
            end
            local created, reason = walk(value.created_effect, effect_kind, depth + 1)
            if created == nil then
                return nil, reason
            end
            return walk(value.explosion_effect, effect_kind, depth + 1)
        end
        if kind == "visual-particle" or kind == "incidental-particle" then
            local regular, reason = walk(value.regular_trigger_effect, effect_kind, depth + 1)
            if regular == nil then
                return nil, reason
            end
            local water
            water, reason = walk(value.ended_in_water_trigger_effect, effect_kind, depth + 1)
            if water == nil then
                return nil, reason
            end
            return walk(value.ended_on_ground_trigger_effect, effect_kind, depth + 1)
        end
        if incidental and (value.type == "damage" or value.type == "damage-tile") then
            local packet = value.damage
            if type(packet) ~= "table" or not finite(packet.amount) or packet.amount < 0 then
                return nil, "incidental-healing"
            end
            if not finite(value.lower_damage_modifier or 1) or (value.lower_damage_modifier or 1) < 0 or not finite(value.upper_damage_modifier or 1) or (value.upper_damage_modifier or 1) < 0 then
                return nil, "incidental-healing"
            end
            return summary()
        end
        if incidental and value.type == "projectile" then
            local projectile = options.entity_of and options.entity_of(value.projectile)
            if projectile == nil then
                return nil, "missing-projectile"
            end
            local source, reason = walk(value.source_effects, effect_kind, depth + 1)
            if source == nil then
                return nil, reason
            end
            local target
            target, reason = walk(value.target_effects, effect_kind, depth + 1)
            if target == nil then
                return nil, reason
            end
            return walk(projectile, entity_kind, depth + 1)
        end
        if value.type == "play-sound" or value.type == "create-trivial-smoke" or value.type == "camera-effect" or value.type == "set-tile" then
            return summary()
        end
        if value.type == "invoke-tile-trigger" or value.type == "destroy-decoratives" then
            -- Environmental triggers are indirections, not necessarily visual effects.
            -- https://lua-api.factorio.com/latest/prototypes/TilePrototype.html#trigger_effect
            -- https://lua-api.factorio.com/latest/prototypes/DecorativePrototype.html#trigger_effect
            if value.type == "destroy-decoratives" and value.invoke_decorative_trigger == false then
                return summary()
            end
            local prototypes = value.type == "invoke-tile-trigger" and options.tile_effects or options.decorative_effects
            if prototypes == nil then
                return nil, "unknown-environment-effects"
            end
            for _, prototype in pairs(prototypes) do
                local result, reason = walk(prototype.trigger_effect, effect_kind, depth + 1)
                if result == nil then
                    return nil, reason
                end
            end
            return summary()
        end
        if value.type == "create-decorative" then
            local prototype = options.decorative_effects and options.decorative_effects[value.decorative]
            if prototype == nil then
                return nil, "missing-decorative"
            end
            return walk(prototype.placed_effect, effect_kind, depth + 1)
        end
        if value.type == "destroy-cliffs" then
            local names = {}
            if value.explosion_at_trigger ~= nil then
                table.insert(names, value.explosion_at_trigger)
            end
            if value.explosion_at_cliff ~= nil then
                table.insert(names, value.explosion_at_cliff)
            end
            for _, name in pairs(names) do
                local entity = options.entity_of and options.entity_of(name)
                if entity == nil then
                    return nil, "missing-cliff-explosion"
                end
                local result, reason = walk(entity, entity_kind, depth + 1)
                if result == nil then
                    return nil, reason
                end
            end
            return summary()
        end
        if value.type == "create-entity" or value.type == "create-explosion" then
            local entity = options.entity_of and options.entity_of(value.entity_name)
            -- Created entities with damage are not treated as the original target: their target binding and modifiers need an adapter.
            -- https://lua-api.factorio.com/latest/prototypes/ExplosionPrototype.html
            if entity ~= nil then
                return walk(entity, entity_kind, depth + 1)
            end
            return nil, "missing-created-entity"
        end
        if value.type == "create-particle" then
            local particle = options.particle_of and options.particle_of(value.particle_name)
            -- ParticlePrototype's three effect properties can create more effects or entities.
            -- https://lua-api.factorio.com/latest/prototypes/ParticlePrototype.html
            if particle == nil then
                return nil, "missing-particle"
            end
            return walk(particle, particle_kind, depth + 1)
        end
        if value.type == "direct" or value.type == "area" or value.type == "cluster" or value.type == "line" then
            return walk(value.action_delivery, effect_kind, depth + 1)
        end
        if value.type == "instant" then
            local source, reason = walk(value.source_effects, effect_kind, depth + 1)
            if source == nil then
                return nil, reason
            end
            return walk(value.target_effects, effect_kind, depth + 1)
        end
        if value.type == "nested-result" then
            return walk(value.action, effect_kind, depth + 1)
        end
        if value.type == "activate-impact" then
            -- This indirection is target-dependent. Only harmless combinations can be omitted.
            -- https://lua-api.factorio.com/latest/prototypes/DeliverImpactCombination.html
            if options.impact_effects == nil then
                return nil, "unknown-impact-effects"
            end
            for _, combination in pairs(options.impact_effects) do
                if combination.deliver_category == (value.deliver_category or "") then
                    local result, reason = harmless(combination.trigger_effect_item, "effect", depth + 1)
                    if result == nil then
                        return nil, reason
                    end
                end
            end
            return summary()
        end
        return nil, "nonvisual-effect:" .. tostring(value.type)
    end

    local function effect(value, depth, binding)
        if value.damage_type_filters ~= nil or value.affects_target == true then
            return nil, "conditional-effect"
        end
        if value.type == "damage" then
            if binding == "created" or binding == "position" then
                return nil, "missing-target-binding"
            end
            if value.apply_damage_to_trees == false then
                return nil, "conditional-damage-target"
            end
            -- Distance falloff needs a geometry model; do not count its maximum as guaranteed damage.
            -- https://lua-api.factorio.com/latest/types/DamageEntityTriggerEffectItem.html
            if (value.lower_damage_modifier or 1) ~= 1 or (value.upper_damage_modifier or 1) ~= 1 then
                return nil, "distance-damage-modifier"
            end
            local packet = value.damage
            if type(packet) ~= "table" or type(packet.type) ~= "string" or not positive(packet.amount) then
                return nil, "invalid-damage"
            end
            return {
                packets = {
                    {
                        type = packet.type,
                        amount = packet.amount,
                        count = 1,
                    },
                },
                delay_seconds = 0,
            }
        end
        if value.type == "nested-result" then
            return walk(value.action, "trigger", depth + 1, binding)
        end
        if value.type == "create-entity" or value.type == "create-explosion" then
            local harmless_result = walk(value, "visual", depth + 1)
            if harmless_result ~= nil then
                return harmless_result
            end
            local entity = options.entity_of and options.entity_of(value.entity_name)
            if entity == nil or entity.type ~= "explosion" then
                return nil, "unsupported-created-damage"
            end
            if value.only_when_visible == true or value.check_buildability == true or value.find_non_colliding_position == true or value.tile_collision_mask ~= nil or value.offset_deviation ~= nil or value.offsets ~= nil or value.as_enemy == true or value.abort_if_over_space == true or entity.surface_conditions ~= nil then
                -- Conditional extra damage cannot be credited, but need not invalidate independent guaranteed hits.
                return walk(value, "incidental", depth + 1)
            end
            if value.cycle_while_moving == true or value.inherit_movement_distance_from_projectile == true or (value.max_movement_distance or -1) > 0 or (value.max_movement_distance_deviation or 0) ~= 0 then
                return nil, "moving-created-damage"
            end
            local result, reason = walk(entity.created_effect, "trigger", depth + 1, "created")
            if result == nil then
                return nil, reason
            end
            local delayed
            delayed, reason = walk(entity.explosion_effect, "trigger", depth + 1, "created")
            if delayed == nil then
                return nil, reason
            end
            local delay, deviation = entity.delay or 0, entity.delay_deviation or 0
            if not finite(delay) or delay < 0 or not finite(deviation) or deviation < 0 then
                return nil, "invalid-explosion-delay"
            end
            local combined = summary()
            combined, reason = merge(combined, result, 1)
            if combined == nil then
                return nil, reason
            end
            combined, reason = merge(combined, delayed, 1)
            if combined == nil then
                return nil, reason
            end
            combined.delay_seconds = combined.delay_seconds + (delay + deviation) / 60
            -- Each explosion samples its own extra delay, so repeated/team hits need not arrive together.
            -- https://lua-api.factorio.com/latest/prototypes/ExplosionPrototype.html#delay_deviation
            combined.unsynchronized_hits = combined.unsynchronized_hits or deviation > 0
            return combined
        end
        return walk(value, "visual", depth + 1)
    end

    local function delivery(value, depth, binding)
        -- Source effects act on the shooter, not the target.
        -- Nonvisual source effects may alter survival or damage, so leave that source unscored instead of counting them as target hits.
        local visual, reason = harmless(value.source_effects, "effect", depth + 1)
        if visual == nil then
            return nil, reason
        end
        if value.type == "instant" then
            local target_binding = (binding == "created" or binding == "position") and binding or "target"
            return walk(value.target_effects, "effect", depth + 1, target_binding)
        end
        if value.type ~= "projectile" then
            return nil, "unsupported-delivery"
        end
        local projectile = options.entity_of and options.entity_of(value.projectile)
        if projectile == nil or projectile.type ~= "projectile" then
            return nil, "missing-projectile"
        end
        local creation, creation_reason = walk(projectile.created_effect, "visual", depth + 1)
        if creation == nil then
            return nil, creation_reason
        end
        local final, final_reason = walk(projectile.final_action, "incidental", depth + 1)
        if final == nil then
            return nil, final_reason
        end
        -- Impact effects are reused independently of the source's range.
        -- The default benchmark carries a bounded flight expression until attack() supplies its usable range.
        -- https://lua-api.factorio.com/latest/prototypes/ProjectilePrototype.html
        -- https://lua-api.factorio.com/latest/types/ProjectileTriggerDelivery.html
        local delay, flight
        if options.projectile_time ~= nil then
            delay = options.projectile_time(value, projectile)
            if not finite(delay) or delay < 0 then
                return nil, "unknown-projectile-time"
            end
        else
            flight, reason = projectiles.flight(value, projectile)
            if flight == nil then
                return nil, reason
            end
            delay = 0
        end
        local result = summary()
        local child, child_reason = walk(projectile.action, "trigger", depth + 1, "target")
        if child == nil then
            return nil, child_reason
        end
        result, reason = merge(result, child, 1)
        if result == nil then
            return nil, reason
        end
        child, child_reason = walk(value.target_effects, "effect", depth + 1, "target")
        if child == nil then
            return nil, child_reason
        end
        result, reason = merge(result, child, 1)
        if result == nil then
            return nil, reason
        end
        -- final_action is conditional on destroying the target, so never contributes to killing it.
        result.delay_seconds = result.delay_seconds + delay
        result.projectile_delivery = true
        -- An adapter supplies only an upper flight-time bound, not proof of identical arrival times.
        result.unsynchronized_hits = result.unsynchronized_hits or options.projectile_time ~= nil
        if flight ~= nil then
            result.flight_time = projectiles.follow(result.flight_time, flight)
            result.max_range = math.min(result.max_range or flight.max_range, flight.max_range)
            result.min_range = math.max(result.min_range or 0, flight.min_range)
        end
        return result
    end

    local function trigger(value, depth, binding)
        if value.entity_flags ~= nil or value.collision_mask ~= nil or value.trigger_target_mask ~= nil or value.force ~= nil or value.filter_enabled == true then
            return nil, "conditional-targeting"
        end
        if value.type == "direct" then
            if binding == "direction" then
                return nil, "missing-target-binding"
            end
            return walk(value.action_delivery, "delivery", depth + 1, binding)
        end
        if value.type == "area" then
            if not positive(value.radius) then
                return nil, "invalid-area-radius"
            end
            if value.target_entities == false then
                -- Uncalibrated scatter gets no damage credit; confirm its uncounted branches cannot heal or add enemies.
                return walk(value, "incidental", depth + 1)
            end
            if binding == "source" or binding == "direction" or binding == "position" then
                if value.trigger_from_target ~= true then
                    return nil, "area-away-from-target"
                end
            end
            -- Only the primary aimed target is credited, even when the area could hit a group.
            return walk(value.action_delivery, "delivery", depth + 1, "target")
        end
        if value.type == "line" then
            if not positive(value.range) or not positive(value.width) then
                return nil, "invalid-line-geometry"
            end
            local visual_result, reason = walk(value.range_effects, "visual", depth + 1)
            if visual_result == nil then
                return nil, reason
            end
            local result
            result, reason = walk(value.action_delivery, "delivery", depth + 1, "target")
            if result == nil then
                return nil, reason
            end
            local bounded = summary()
            bounded, reason = merge(bounded, result, 1)
            if bounded ~= nil then
                bounded.max_range = math.min(bounded.max_range or value.range, value.range)
                -- Only a line launched from the shooter has the benchmark's known origin/direction.
                -- A line created at another impact still receives its conservative primary hit only.
                if not bounded.projectile_delivery and (binding == "source" or binding == "direction" or binding == "position") then
                    for _, packet in pairs(bounded.packets) do
                        packet.line = {
                            range = value.range,
                            width = value.width,
                        }
                    end
                end
            end
            return bounded, reason
        end
        return nil, "unsupported-targeting"
    end

    walk = function(value, kind, depth, binding)
        binding = binding or "target"
        if value == nil then
            return summary()
        end
        if type(value) ~= "table" then
            return nil, "invalid-effect-structure"
        end
        if depth > max_depth then
            return nil, "depth-budget"
        end
        local memo_key = kind .. ":" .. binding
        local memo = cache[value] and cache[value][memo_key]
        if memo ~= nil then
            return memo.result, memo.reason
        end
        local active_key = active[value] and active[value][memo_key]
        if active_key == true then
            return nil, "effect-cycle"
        end
        visited = visited + 1
        if visited > max_nodes then
            return nil, "node-budget"
        end
        active[value] = active[value] or {}
        active[value][memo_key] = true
        local result, reason
        if value.type == nil then
            result = summary()
            for _, child in pairs(value) do
                local child_result
                child_result, reason = walk(child, kind, depth + 1, binding)
                if child_result == nil then
                    result = nil
                    break
                end
                result, reason = merge(result, child_result, 1)
                if result == nil then
                    break
                end
            end
        elseif kind == "visual" or kind == "visual-entity" or kind == "visual-particle" or kind == "incidental" or kind == "incidental-entity" or kind == "incidental-particle" then
            result, reason = visual(value, kind, depth)
        elseif kind == "effect" and value.type ~= "damage" and value.type ~= "nested-result" and value.type ~= "create-entity" and value.type ~= "create-explosion" then
            if value.type == "invoke-tile-trigger" or value.type == "destroy-decoratives" then
                result, reason = walk(value, "incidental", depth + 1)
            else
                result, reason = visual(value, "visual", depth)
            end
        else
            local count
            if kind == "effect" and (value.type == "create-entity" or value.type == "create-explosion") then
                result = walk(value, "visual", depth + 1)
            end
            if result == nil then
                count, reason = repetitions(value)
            end
            if result ~= nil then
                -- A validated visual effect remains harmless regardless of its probability/repeats.
            elseif count == 0 then
                result = summary()
            elseif count ~= nil then
                if kind == "effect" then
                    result, reason = effect(value, depth, binding)
                elseif kind == "delivery" then
                    result, reason = delivery(value, depth, binding)
                else
                    result, reason = trigger(value, depth, binding)
                end
                if result ~= nil and count ~= 1 then
                    result, reason = merge(summary(), result, count)
                end
            end
        end
        active[value][memo_key] = nil
        cache[value] = cache[value] or {}
        cache[value][memo_key] = {
            result = result,
            reason = reason,
        }
        if result ~= nil then
            result.target_safe = resolver.target_safe
            result.target_options = resolver.target_options
        end
        return result, reason
    end

    resolver.target_safe = function(entity)
        if entity.segment_engine ~= nil or entity.attack_reaction ~= nil then
            return nil, "unsupported-target-effects"
        end
        local hit, reason = walk(entity.damaged_trigger_effect, "visual", 1)
        if hit == nil then
            return nil, reason
        end
        local death
        death, reason = walk(entity.dying_trigger_effect, "visual", 1)
        if death == nil then
            return nil, reason
        end
        local explosions = entity.dying_explosion
        if type(explosions) == "string" or (type(explosions) == "table" and explosions.name ~= nil) then
            explosions = { explosions }
        end
        for _, explosion in pairs(explosions or {}) do
            local name = type(explosion) == "string" and explosion or explosion.name
            local prototype = options.entity_of and options.entity_of(name)
            if prototype == nil then
                return nil, "missing-dying-explosion"
            end
            local result
            result, reason = walk(prototype, "visual-entity", 1)
            if result == nil then
                return nil, reason
            end
        end
        -- Corpses are entities too, and their inherited created_effect can run on death.
        -- https://lua-api.factorio.com/latest/prototypes/EntityWithHealthPrototype.html#corpse
        local corpses = entity.corpse
        if type(corpses) == "string" then
            corpses = { corpses }
        end
        for _, corpse in pairs(corpses or {}) do
            local prototype = options.entity_of and options.entity_of(corpse)
            if prototype == nil then
                return nil, "missing-corpse"
            end
            local result
            result, reason = walk(prototype, "visual-entity", 1)
            if result == nil then
                return nil, reason
            end
        end
        return true
    end

    resolver.ammo = function(ammo_type)
        if type(ammo_type) ~= "table" or ammo_type[1] ~= nil then
            return nil, "unselected-ammo-type"
        end
        if ammo_type.force_clamp_to_max_range == true or ammo_type.target_filter ~= nil then
            return nil, "conditional-ammo-target"
        end
        local target_type = ammo_type.target_type or "entity"
        if target_type ~= "entity" and target_type ~= "position" and target_type ~= "direction" then
            return nil, "unknown-ammo-target"
        end
        local binding = target_type == "entity" and "source" or target_type
        local result, reason = walk(ammo_type.action, "trigger", 1, binding)
        if result ~= nil and #result.packets == 0 then
            return nil, "no-target-damage"
        end
        return result, reason
    end

    resolver.visual_effect = function(value)
        local result, reason = walk(value, "visual", 1)
        return result ~= nil and true or nil, reason
    end
    resolver.visual_entity = function(value)
        local result, reason = walk(value, "visual-entity", 1)
        return result ~= nil and true or nil, reason
    end
    resolver.target_options = {
        entity_of = options.entity_of,
        visual_effect = resolver.visual_effect,
        visual_entity = resolver.visual_entity,
        max_nodes = max_nodes,
        max_depth = max_depth,
    }

    return resolver
end

-- Parameters/defaults verified in BaseAttackParameters and AmmoType (Factorio 2.1).
-- No research bonuses are assumed. A supplied weapon's modifier applies before resistance.
damage.attack = function(effect_summary, attack_parameters, ammo_type)
    if type(effect_summary) ~= "table" or type(attack_parameters) ~= "table" or type(ammo_type) ~= "table" then
        return nil, "missing-attack-input"
    end
    if attack_parameters.type ~= "projectile" or (attack_parameters.cooldown_deviation or 0) ~= 0 then
        return nil, "unsupported-attack-timing"
    end
    local modifier = attack_parameters.damage_modifier or 1
    local cooldown = attack_parameters.cooldown
    local ammo_cooldown = ammo_type.cooldown_modifier or 1
    local warmup = attack_parameters.warmup or 0
    if not positive(modifier) or not positive(cooldown) or not positive(ammo_cooldown) or not finite(warmup) or warmup < 0 then
        return nil, "invalid-attack-parameters"
    end
    -- Ammo modifies maximum range only; the minimum remains the weapon's unmodified minimum.
    -- https://lua-api.factorio.com/latest/types/AmmoType.html#range_modifier
    -- https://lua-api.factorio.com/latest/types/BaseAttackParameters.html#min_range
    local range = attack_parameters.range
    local min_range = attack_parameters.min_range or 0
    local range_modifier = ammo_type.range_modifier or 1
    if not positive(range) or not positive(range_modifier) or not finite(min_range) or min_range < 0 then
        return nil, "invalid-attack-range"
    end
    local effective_range = range * range_modifier
    if not positive(effective_range) or effective_range <= min_range then
        return nil, "unusable-attack-range"
    end
    local delay, benchmark_range = projectiles.delay(effect_summary, effective_range, min_range)
    if delay == nil then
        return nil, benchmark_range
    end
    local profile = {
        packets = {},
        interval_seconds = math.max(1, math.ceil(cooldown * ammo_cooldown)) / 60,
        warmup_seconds = warmup / 60,
        delay_seconds = delay,
        unsynchronized_hits = effect_summary.unsynchronized_hits,
        benchmark_range = benchmark_range,
        target_safe = effect_summary.target_safe,
        target_options = effect_summary.target_options,
    }
    for _, packet in pairs(effect_summary.packets) do
        local amount = packet.amount * modifier
        if not positive(amount) then
            return nil, "invalid-modified-damage"
        end
        table.insert(profile.packets, {
            type = packet.type,
            amount = amount,
            count = packet.count,
            line = packet.line,
        })
    end
    return profile
end

-- Use a lower bound: unlike the engine's low-damage fallback, subtraction may return zero.
-- This intentionally overestimates difficulty without inventing a fallback formula.
-- https://lua-api.factorio.com/latest/types/Resistance.html (links to https://wiki.factorio.com/Damage)
damage.packet_damage = function(amount, resistance)
    if not positive(amount) then
        return nil, "invalid-damage"
    end
    resistance = resistance or {}
    local decrease, percent = resistance.decrease or 0, resistance.percent or 0
    if not finite(decrease) or decrease < 0 or not finite(percent) or percent < 0 or percent > 100 then
        return nil, "unsupported-resistance"
    end
    return math.max(0, amount - decrease) * (1 - percent / 100)
end

-- Target lifecycles and shared segmented health are evaluated separately from attack effects.
damage.clear_seconds = function(profile, roster, entities, deployment_count)
    local options = type(profile) == "table" and profile.target_options or nil
    return targets.clear_seconds(profile, roster, entities, deployment_count, options)
end

return damage
