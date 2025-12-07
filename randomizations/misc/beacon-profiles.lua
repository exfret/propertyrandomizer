local rng = require("lib/random/rng")

-- This is not in numerical/entity because we are doing randomization from a fixed table rather than actually randomizing the individual numbers

local beacon_profiles = {
    function(n) -- Vanilla
        return 1 / math.sqrt(n)
    end,
    function(n) -- Constant
        return 0.67
    end,
    function(n) -- More harsh scaling
        return 1.33 / math.pow(n, 3 / 4)
    end,
    function(n) -- More beacons doesn't do anything, but at least the effect is stronger
        return 2 / n
    end,
    function(n) -- Need even number of beacons
        return 1.25 * ((n + 1) % 2)
    end,
    function(n) -- At most 3 beacons, but very powerful ones
        return 2 * math.min(1, math.max(0, 4 - n))
    end,
    function(n) -- Beacons actually get better the more you have
        return 0.33 * math.log(n + 2) / math.log(2)
    end,
    function(n) -- SE Beacons (at most one)
        return 5 * math.max(0, 2 - n)
    end,
    function(n) -- At *least* four beacons needed, then constant
        return 1 * math.min(1, math.floor(n / 4))
    end,
    function(n) -- Exactly 3 beacons
        return 5 * math.max(0, math.min(4 - n, n - 2))
    end
}

randomizations.beacon_profiles = function(id)
    -- TODO: Check that beacon profiles are balanced based off max multipliers!

    for _, beacon in pairs(data.raw.beacon) do
        local profile_fnc = beacon_profiles[rng.int(rng.key({id = id, prototype = beacon}), #beacon_profiles)]
        
        local profile = {}
        for i = 1, 100 do
            table.insert(profile, profile_fnc(i))
        end

        beacon.profile = profile
    end
end