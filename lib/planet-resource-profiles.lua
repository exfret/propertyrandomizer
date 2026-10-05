-- One compensated resource-control profile per finished planet, including copies.
-- Control semantics: installed 2.1 docs, PlanetPrototypeMapGenSettings, AutoplaceSettings and MapGenSize.
-- Total estimates: core/prototypes/noise-functions.lua (resource_autoplace_all_patches).
-- Custom noise is deliberately given a wider response envelope; estimates are not a map simulation.

local rng = require("lib/random/rng")
local wild = require("lib/wild-entities")
local lutils = require("lib/logic/logic-utils")

local profiles = {}
local dimensions = {
    "size",
    "frequency",
    "richness",
}
local MIN_TOTAL = 0.75
local MAX_TOTAL = 4 / 3

local function control_value(map, control, dimension)
    local override = (map.property_expression_names or {})["control:" .. control .. ":" .. dimension]
    if override ~= nil then
        return tonumber(override)
    end
    return nil
end

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl or {}) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

-- Legacy MapGenSize spellings, documented in types/MapGenSize.html.
local function amount(value)
    if value == nil then
        return 1
    elseif type(value) == "number" then
        return value
    elseif value == "none" then
        return 0
    elseif string.sub(value, 1, 5) == "very-" then
        local rest = string.sub(value, 6)
        if rest == "low" or rest == "small" or rest == "poor" then
            return 0.5
        elseif rest == "high" or rest == "big" or rest == "good" then
            return 2
        end
    elseif value == "low" or value == "small" or value == "poor" then
        return 1 / math.sqrt(2)
    elseif value == "high" or value == "big" or value == "good" then
        return math.sqrt(2)
    elseif value == "normal" or value == "medium" or value == "regular" then
        return 1
    end
    return nil
end

-- Follow the actual placement's named expressions/functions, including local scopes and planet overrides.
-- Resource copies and swapped slots need not use their entity's name as a slider.
local function dependencies(planet, resource)
    local controls = {}
    local has_helper = false
    local has_starting = false
    local has_sparse_placement = false
    local visited = {}
    local names = planet.map_gen_settings.property_expression_names or {}
    local function scan(expression, scope)
        if type(expression) ~= "string" then
            return
        end
        -- The helper's random_probability path places sparse single entities instead of a filled patch.
        -- Its clipped placement and fixed added richness need the wider coverage response envelope.
        has_sparse_placement = has_sparse_placement or string.find(expression, "random_penalty%s*{") ~= nil
        if string.find(expression, "resource_autoplace_all_patches", 1, true) ~= nil then
            has_helper = true
            has_starting = has_starting or string.find(expression, "has_starting_area_placement%s*=%s*1") ~= nil
        end
        for control in string.gmatch(expression, "control:([%w_%-]+):[%w_]+") do
            local prototype = (data.raw["autoplace-control"] or {})[control]
            if prototype ~= nil and prototype.category == "resource" and prototype.richness == true then
                controls[control] = true
            end
        end
        local function follow(name)
            local local_expression = (scope.local_expressions or {})[name]
            local local_function = (scope.local_functions or {})[name]
            local key = tostring(scope) .. ":" .. name
            if visited[key] ~= nil then
                return
            end
            visited[key] = true
            if local_expression ~= nil then
                scan(local_expression, scope)
            elseif local_function ~= nil then
                scan(local_function.expression, local_function)
            else
                local target = names[name] or name
                local named = (data.raw["noise-expression"] or {})[target] or (data.raw["noise-function"] or {})[target]
                if named ~= nil then
                    scan(named.expression, named)
                end
            end
        end
        for name in string.gmatch(expression, "var%(['\"]([^'\"]+)['\"]%)") do
            follow(name)
        end
        -- Unquoted expression identifiers cannot contain hyphens (NoiseExpression docs).
        for name in string.gmatch(expression, "[%a_][%w_]*") do
            follow(name)
        end
    end
    local overrides = wild.overrides(planet, resource.name)
    for _, property in pairs({
        "probability",
        "richness",
    }) do
        local override = overrides[property]
        local expression = override or resource.autoplace[property .. "_expression"]
        if override ~= nil then
            local named = (data.raw["noise-expression"] or {})[override]
            if named ~= nil then
                expression = named.expression
                scan(expression, named)
            end
        else
            scan(expression, resource.autoplace)
        end
    end
    local control = resource.autoplace.control
    local prototype = (data.raw["autoplace-control"] or {})[control]
    if prototype ~= nil and prototype.category == "resource" and prototype.richness == true then
        controls[control] = true
    end
    return controls, has_helper and not has_sparse_placement, has_starting
end

profiles.eligible = function(planet)
    local entries = {}
    local controls = {}
    local map = planet.map_gen_settings
    if map == nil then
        return entries, controls
    end
    for _, name in pairs(sorted_keys(data.raw.resource)) do
        local resource = data.raw.resource[name]
        if resource.autoplace ~= nil and lutils.check_in_room(planet, resource) then
            local used, has_helper, has_starting = dependencies(planet, resource)
            local enabled = next(used) ~= nil
            local probability = wild.overrides(planet, name).probability or resource.autoplace.probability_expression
            local named = (data.raw["noise-expression"] or {})[probability]
            local constant_probability = tonumber(named and named.expression or probability)
            if constant_probability ~= nil and constant_probability <= 0 then
                enabled = false
            end
            local placement = (((map.autoplace_settings or {}).entity or {}).settings or {})[name] or {}
            for control, _ in pairs(used) do
                local settings = (map.autoplace_controls or {})[control] or {}
                for _, dimension in pairs(dimensions) do
                    local override = (map.property_expression_names or {})["control:" .. control .. ":" .. dimension]
                    local value = control_value(map, control, dimension) or amount(placement[dimension] or settings[dimension])
                    if override ~= nil and control_value(map, control, dimension) == nil then
                        enabled = false
                    end
                    enabled = enabled and value ~= nil and value > 0
                    -- Every slider we will write needs a numeric baseline, even if this resource has an entity-level value that takes precedence over it.
                    enabled = enabled and (control_value(map, control, dimension) ~= nil or amount(settings[dimension]) ~= nil)
                end
            end
            if enabled then
                table.insert(entries, {
                    resource_name = name,
                    controls = used,
                    has_helper = has_helper,
                    has_starting = has_starting,
                    placement = placement,
                })
                for control, _ in pairs(used) do
                    controls[control] = true
                end
            end
        end
    end
    return entries, controls
end

-- Validate each resource, rather than averaging a shortage away with another resource's surplus.
-- The helper's regular quantity scales as size*frequency*richness.
-- Fixed additional/minimum richness also depends on patch coverage (size^(2/3)); starting quantity uses frequency+1.
-- For custom expressions, check linear, quadratic and control-independent responses too.
profiles.total_range = function(entry, profile, map)
    local s, f, r = profile.size, profile.frequency, profile.richness
    local ratios = {
        s * f * r,
        s ^ (2 / 3) * f * r,
    }
    if entry.has_helper and entry.has_starting then
        for control, _ in pairs(entry.controls) do
            local base = control_value(map, control, "frequency") or amount(entry.placement.frequency or ((map.autoplace_controls or {})[control] or {}).frequency)
            table.insert(ratios, s * (base * f + 1) / (base + 1) * r)
        end
    elseif not entry.has_helper then
        for size_power = 0, 2 do
            for frequency_power = 0, 2 do
                for richness_power = 0, 1 do
                    table.insert(ratios, s ^ size_power * f ^ frequency_power * r ^ richness_power)
                end
            end
        end
    end
    local low, high = 1, 1
    for _, ratio in pairs(ratios) do
        low = math.min(low, ratio)
        high = math.max(high, ratio)
    end
    return low, high
end

local function acceptable(entries, controls, profile, map)
    for _, entry in pairs(entries) do
        local low, high = profiles.total_range(entry, profile, map)
        if low < MIN_TOTAL or high > MAX_TOTAL then
            return false
        end
        for _, dimension in pairs(dimensions) do
            local value = amount(entry.placement[dimension]) * profile[dimension]
            if entry.placement[dimension] ~= nil and (value < 1 / 6 or value > 6) then
                return false
            end
        end
    end
    for control, _ in pairs(controls) do
        for _, dimension in pairs(dimensions) do
            local base = control_value(map, control, dimension) or amount(((map.autoplace_controls or {})[control] or {})[dimension])
            local value = base * profile[dimension]
            if value > 0 and (value < 1 / 6 or value > 6) and value ~= base then
                return false
            end
        end
    end
    return true
end

profiles.balance = function(entries, controls, requested, map)
    local strength = 1
    for attempt = 1, 25 do
        local profile = {}
        for _, dimension in pairs(dimensions) do
            profile[dimension] = requested[dimension] ^ strength
        end
        if acceptable(entries, controls, profile, map) then
            profile.adjustments = attempt - 1
            return profile
        end
        strength = strength * 0.75
    end
    return {
        size = 1,
        frequency = 1,
        richness = 1,
        adjustments = 25,
    }
end

local function adjective(value, low, high, normal)
    if value < 0.95 then
        return { "propertyrandomizer-resource-profile." .. low }
    elseif value > 1.05 then
        return { "propertyrandomizer-resource-profile." .. high }
    end
    return { "propertyrandomizer-resource-profile." .. normal }
end

profiles.description = function(profile)
    return {
        "propertyrandomizer-resource-profile.description",
        adjective(profile.size, "small", "large", "medium"),
        adjective(profile.frequency, "sparse", "frequent", "regular"),
        adjective(profile.richness, "poor", "rich", "normal"),
        string.format("%.2f", profile.size),
        string.format("%.2f", profile.frequency),
        string.format("%.2f", profile.richness),
    }
end

profiles.execute = function()
    local results = {}
    for _, name in pairs(sorted_keys(data.raw.planet)) do
        local planet = data.raw.planet[name]
        if planet.hidden ~= true then
            local entries, controls = profiles.eligible(planet)
            if #entries > 0 then
                local key = rng.key({
                    id = "planet-resource-profile",
                    prototype = planet,
                })
                -- Reset this private stream so retries or a second call cannot change a planet's draw.
                rng.seed(key)
                local size = math.exp(rng.float_range(key, -1.1, 1.1))
                local frequency = math.exp(-math.log(size) + rng.float_range(key, -0.4, 0.4))
                local requested = {
                    size = size,
                    frequency = frequency,
                    richness = 1 / (size * frequency),
                }
                local profile = profiles.balance(entries, controls, requested, planet.map_gen_settings)
                local map = planet.map_gen_settings
                map.autoplace_controls = map.autoplace_controls or {}
                for control, _ in pairs(controls) do
                    local settings = table.deepcopy(map.autoplace_controls[control] or {})
                    for _, dimension in pairs(dimensions) do
                        local property = "control:" .. control .. ":" .. dimension
                        local override = control_value(map, control, dimension)
                        if override ~= nil then
                            map.property_expression_names[property] = override * profile[dimension]
                        else
                            settings[dimension] = amount(settings[dimension]) * profile[dimension]
                        end
                    end
                    map.autoplace_controls[control] = settings
                end
                for _, entry in pairs(entries) do
                    for _, dimension in pairs(dimensions) do
                        if entry.placement[dimension] ~= nil then
                            entry.placement[dimension] = amount(entry.placement[dimension]) * profile[dimension]
                        end
                    end
                end
                local original = planet.localised_description or {
                    "?",
                    { "space-location-description." .. name },
                    "",
                }
                planet.localised_description = {
                    "",
                    original,
                    "\n\n",
                    profiles.description(profile),
                }
                results[name] = profile
                log("Planet resource profile: " .. name .. " size=" .. profile.size .. " frequency=" .. profile.frequency .. " richness=" .. profile.richness .. " adjustments=" .. profile.adjustments .. " resources=" .. #entries)
            end
        end
    end
    return results
end

return profiles
