-- A fixed-target, unobstructed benchmark ray, shared by projectiles and line attacks.
-- This credits one aimed target only; it does not assume collateral hits along the ray.

local projectiles = {}

local function finite(value)
    return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function positive(value)
    return finite(value) and value > 0
end

-- Validate a reusable flight description before the source supplies its benchmark range.
-- https://lua-api.factorio.com/latest/types/ProjectileTriggerDelivery.html
-- https://lua-api.factorio.com/latest/prototypes/ProjectilePrototype.html
projectiles.flight = function(delivery, projectile)
    if (delivery.direction_deviation or 0) ~= 0 or (delivery.range_deviation or 0) ~= 0 or (delivery.starting_speed_deviation or 0) ~= 0 then
        return nil, "variable-projectile-flight"
    end
    local speed = delivery.starting_speed
    local acceleration = projectile.acceleration
    local max_speed = projectile.max_speed
    if not positive(speed) or not finite(acceleration) or acceleration < 0 or (max_speed ~= nil and not positive(max_speed)) then
        return nil, "invalid-projectile-speed"
    end
    local modifier = 1
    local isotropic = true
    if projectile.speed_modifier ~= nil then
        local vector = projectile.speed_modifier
        local x, y = vector.x or vector[1], vector.y or vector[2]
        if not positive(x) or not positive(y) then
            return nil, "invalid-projectile-speed-modifier"
        end
        modifier = math.min(x, y)
        isotropic = x == y
    end
    local max_range, min_range = delivery.max_range or 1000, delivery.min_range or 0
    if not positive(speed) or not positive(max_range) or not finite(min_range) or min_range < 0 or max_range <= min_range then
        return nil, "invalid-projectile-range"
    end
    if projectile.force_condition ~= nil and projectile.force_condition ~= "all" and projectile.force_condition ~= "enemy" then
        return nil, "conditional-projectile-force"
    end
    if projectile.hit_collision_mask ~= nil then
        return nil, "conditional-projectile-collision"
    end
    return {
        speed = speed,
        acceleration = isotropic and acceleration or 0,
        max_speed = max_speed,
        modifier = modifier,
        max_range = max_range,
        min_range = min_range,
    }
end

-- Latency expressions share cached subtrees instead of enumerating delivery paths.
projectiles.parallel = function(first, second)
    if first == nil or first == second then
        return second
    end
    if second == nil then
        return first
    end
    return {
        left = first,
        right = second,
    }
end

projectiles.follow = function(prior, flight)
    return {
        prior = prior,
        flight = flight,
    }
end

-- Float fields may be rounded to single precision; always round our positive estimates down.
-- https://lua-api.factorio.com/latest/types/float.html
local function lower_float(value)
    if value < 2 ^ -126 then
        return 0
    end
    return value * (1 - 2 ^ -23)
end

-- Empirically verified in Factorio 2.1.20 on 2026-10-05: 21 synthetic/data-derived cases, 120 ticks each.
-- Runtime speed follows v := min(max_speed, v + acceleration), then the position moves using v.
-- The probe included capped speeds, initial speed above the cap, and all three tested orientations.
-- MapPosition has 1/256-tile precision; subtract a full rounding step on both axes every tick.
-- https://lua-api.factorio.com/latest/types/MapPosition.html
-- Anisotropic modifiers retain the slower constant-speed bound; inherited forward speed is ignored.
local function flight_ticks(flight, range, budget)
    local speed = lower_float(math.min(flight.speed, flight.max_speed or flight.speed))
    local acceleration = lower_float(flight.acceleration)
    local cap = flight.max_speed and lower_float(flight.max_speed) or math.huge
    local modifier = lower_float(flight.modifier)
    local covered, ticks = 0, 0
    local position_error = math.sqrt(2) / 256
    while covered < range do
        if budget.ticks >= 4096 then
            return nil, "projectile-flight-budget"
        end
        budget.ticks = budget.ticks + 1
        ticks = ticks + 1
        speed = lower_float(math.min(cap, speed + acceleration))
        local advance = lower_float(speed * modifier) - position_error
        if not finite(advance) then
            return nil, "invalid-projectile-speed"
        end
        covered = covered + math.max(0, advance)
        if advance <= 0 and acceleration == 0 then
            return nil, "stationary-projectile-bound"
        end
    end
    return ticks
end

local function expression_ticks(expression, range, budget, memo)
    if expression == nil then
        return 0
    end
    if memo[expression] ~= nil then
        return memo[expression]
    end
    if budget.nodes >= 4096 then
        return nil, "projectile-flight-budget"
    end
    budget.nodes = budget.nodes + 1
    local first, second, reason
    if expression.flight ~= nil then
        first, reason = expression_ticks(expression.prior, range, budget, memo)
        if first == nil then
            return nil, reason
        end
        second, reason = flight_ticks(expression.flight, range, budget)
    else
        first, reason = expression_ticks(expression.left, range, budget, memo)
        if first == nil then
            return nil, reason
        end
        second, reason = expression_ticks(expression.right, range, budget, memo)
    end
    if second == nil then
        return nil, reason
    end
    local ticks = expression.flight ~= nil and first + second or math.max(first, second)
    memo[expression] = ticks
    return ticks
end

-- All latency is charged at the outer edge of the common usable firing interval.
projectiles.delay = function(effect_summary, effective_range, min_range)
    local upper = math.min(effective_range, effect_summary.max_range or effective_range)
    local lower = math.max(min_range, effect_summary.min_range or 0)
    if not positive(upper) or not finite(lower) or lower < 0 or upper <= lower then
        return nil, "unusable-delivery-range"
    end
    local constant = effect_summary.delay_seconds or 0
    local slope = effect_summary.delay_per_tile or 0
    if not finite(constant) or constant < 0 or not finite(slope) or slope < 0 then
        return nil, "invalid-delivery-delay"
    end
    local budget = {
        ticks = 0,
        nodes = 0,
    }
    local flight, reason = expression_ticks(effect_summary.flight_time, upper, budget, {})
    if flight == nil then
        return nil, reason
    end
    local seconds = constant + upper * slope
    if not finite(seconds) then
        return nil, "invalid-delivery-delay"
    end
    return (math.ceil(seconds * 60) + flight) / 60, upper
end

return projectiles
