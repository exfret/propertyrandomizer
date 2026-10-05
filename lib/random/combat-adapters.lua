-- Sampling coordinates for combat edits whose final prototype writes differ from the sampled scalar.
-- Each adapter captures one immutable starting state and is used for one randomization call.

local randnum = require("lib/random/randnum")

local adapters = {}

adapters.rounding = function(params)
    return function(value) return randnum.fixes(params, value) end
end

adapters.fields = function(objects, key, predicate)
    local fields = {}
    for _, object in pairs(objects or {}) do
        local value = object[key]
        if type(value) == "number" and (predicate == nil and value > 0 or predicate ~= nil and predicate(value)) then
            table.insert(fields, {
                object = object,
                key = key,
            })
        end
    end
    return fields
end

-- Duplicate field references share one write based on their original values.
adapters.factor = function(fields, round, direction)
    local saved, watched, seen = {}, {}, {}
    for _, field in pairs(fields) do
        local object, key = field.object, field.key
        seen[object] = seen[object] or {}
        if seen[object][key] == nil then
            seen[object][key] = true
            table.insert(watched, {
                object = object,
                key = key,
            })
            table.insert(saved, {
                object = object,
                key = key,
                value = object[key],
            })
        end
    end
    return {
        read = function() return 1 end,
        apply = function(factor)
            for _, field in pairs(saved) do
                local value = field.value
                if factor ~= 1 then
                    value = value * factor
                    if round ~= nil then
                        value = round(value)
                    end
                end
                field.object[field.key] = value
            end
        end,
        direction = direction,
        fields = watched,
    }
end

-- Share an odds multiplier while keeping each probability's own starting value.
-- Zero and immune rows are omitted by the caller; factor 1 restores exact origins.
adapters.odds = function(fields, scale, round, direction)
    local adapter = adapters.factor(fields, nil, direction)
    local saved = {}
    for _, field in pairs(adapter.fields) do
        table.insert(saved, {
            object = field.object,
            key = field.key,
            value = field.object[field.key],
        })
    end
    adapter.apply = function(factor)
        for _, field in pairs(saved) do
            local value = field.value
            if factor ~= 1 then
                value = scale / (1 + (scale - value) / value / factor)
                if round ~= nil then value = round(value) end
            end
            field.object[field.key] = value
        end
    end
    return adapter
end

-- For example, sample attacks per second while the prototype retains ticks per attack.
adapters.reciprocal = function(object, key, numerator, default)
    local original = object[key]
    local value = original
    if value == nil then
        value = default
    end
    local coordinate = numerator / value
    return {
        read = function() return coordinate end,
        apply = function(candidate)
            if candidate == coordinate then
                object[key] = original
            else
                object[key] = numerator / candidate
            end
        end,
        direction = "increasing",
        fields = {
            {
                object = object,
                key = key,
            },
        },
    }
end

-- Convert a sampled magnitude back to the original sign and units.
adapters.scaled = function(object, key, multiplier, direction)
    local original = object[key]
    local coordinate = original / multiplier
    return {
        read = function() return coordinate end,
        apply = function(candidate)
            if candidate == coordinate then
                object[key] = original
            else
                object[key] = candidate * multiplier
            end
        end,
        direction = direction,
        fields = {
            {
                object = object,
                key = key,
            },
        },
    }
end

-- The first energy field supplies the sampling coordinate; every coupled cost, capacity and drain is written together.
adapters.energy = function(entries, round)
    local saved, fields = {}, {}
    for _, entry in pairs(entries) do
        local original = entry.object[entry.key]
        local value = entry.value
        if value == nil then
            value = (entry.multiplier or 1) * util.parse_energy(original)
        end
        table.insert(saved, {
            object = entry.object,
            key = entry.key,
            original = original,
            value = value,
            suffix = entry.suffix or "J",
            rounded = entry.rounded ~= false,
        })
        table.insert(fields, {
            object = entry.object,
            key = entry.key,
        })
    end
    local coordinate = saved[1].value
    return {
        read = function() return coordinate end,
        apply = function(candidate)
            local factor = candidate / coordinate
            for index, field in pairs(saved) do
                if candidate == coordinate then
                    field.object[field.key] = field.original
                else
                    local value = field.value * factor
                    if index > 1 and field.rounded == true and round ~= nil then
                        value = round(value)
                    end
                    field.object[field.key] = value .. field.suffix
                end
            end
        end,
        direction = false,
        fields = fields,
    }
end

return adapters
