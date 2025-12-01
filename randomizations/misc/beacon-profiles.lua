local rng = require("lib/random/rng")
local randnum = require("lib/random/randnum")
local locale_utils = require("lib/locale")

-- This is not in numerical/entity because we are doing randomization from a fixed table rather than actually randomizing the individual numbers

-- Beacon profile functions balanced by adjusting coefficients to equalize their score as calculated by the following function
local score_function = function (func)
    local score = 0
    for i = 1, 16 do
        score = score + func(i)^1.5 * i^1
    end
    return score
end

local beacon_profiles = {
    {
        func = function(n, i) -- Vanilla
            return 1 / math.sqrt(n)
        end,
        coefficients = {1},
        description = "(Standard distribution)",
    },
    {
        func = function(n, i) -- Constant (1.1 Vanilla)
            return 1
        end,
        coefficients = {1/3},
        description = "(Simple distribution)",
    },
    {
        func = function(n, i) -- More beacons doesn't do anything, but at least the effect is stronger
            return 1 / n
        end,
        coefficients = {2.5},
        description = "(Limited distribution)",
    },
    {
        func = function(n, i) -- Noisy scaling
            return randnum.rand({
                key = "profile",
                dummy = 1,
                variance = "big",
                rounding = "discrete_float",
            }) / math.sqrt(n)
        end,
        coefficients = {1},
        description = "(Noisy distribution)",
    },
    {
        func = function(n, i) -- More harsh scaling
            return 1 / math.pow(n, i / (i+1))
        end,
        coefficients = {1, 1.4, 1.6, 1.8, 1.9, 2},
        description = "(Limited distribution)",
    },
    {
        func = function(n, i) -- Need a number of beacons that's a multiple of i
            return math.max(0, 1 - (n % i)) / math.sqrt(n)
        end,
        coefficients = {1, 1.5, 2, 2.5},
        description = "(Finicky distribution)",
    },
    {
        func = function(n, i) -- At most i beacons, but very powerful ones
            return math.min(1, math.max(0, (i+1) - n)) / math.sqrt(n)
        end,
        coefficients = {9, 5, 4, 3, 2.5, 2},
        description = "(Finicky distribution)",
    },
    {
        func = function(n, i) -- Beacons actually get better the more you have
            return math.log(n + i) / math.log(i+1)
        end,
        coefficients = {0.1, 0.15},
        description = "(Amplified distribution)",
    },
    {
        func = function(n, i) -- At *least* i beacons needed
            return math.min(1, math.floor(n / i)) / math.sqrt(n)
        end,
        coefficients = {1, 1.02, 1.06, 1.10, 1.15, 1.20, 1.27, 1.35},
        description = "(Finicky distribution)",
    },
    {
        func = function(n, i) -- Exactly i beacons
            return math.max(0, math.min((i+1) - n, n - (i-1)))
        end,
        coefficients = {9, 5.5, 4, 3.5, 3, 2.5},
        description = "(Finicky distribution)",
    },
}

-- New
randomizations.beacon_profiles = function(id)
    -- TODO: Check that beacon profiles are balanced based off max multipliers!

    for _, beacon in pairs(data.raw.beacon) do
        local key = rng.key({id = id, prototype = beacon})
        local profile_group = beacon_profiles[rng.int(key, #beacon_profiles)]

        local i = rng.int(key, #profile_group.coefficients)
        local coefficient = profile_group.coefficients[i]

        local profile = {}
        for n = 1, 100 do
            table.insert(profile, coefficient * profile_group.func(n, i))
        end

        -- There's probably a smarter way of detecting this, but this works too
        local change = 0
        for j = 1, math.min(#beacon.profile, #profile) do
            change = change + math.abs(beacon.profile[j] - profile[j])
        end

        if change > 1 and profile_group.description ~= nil then
            beacon.localised_description = {"", locale_utils.find_localised_description(beacon), "\n[color=red]" .. profile_group.description .. "[/color]"}
        end

        beacon.profile = profile
    end
end