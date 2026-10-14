-- User-approved eligibility and infrastructure policy.
-- These are gameplay choices by entity type, not properties that can be inferred from collision masks.
local policy = {}

policy.randomized = {
    ["assembling-machine"] = true,
    furnace = true,
    lab = true,
    beacon = true,
    boiler = true,
    generator = true,
    ["burner-generator"] = true,
    reactor = true,
    ["fusion-reactor"] = true,
    ["fusion-generator"] = true,
    ["solar-panel"] = true,
    accumulator = true,
}

-- Everything profile: broaden terrain placement while retaining surface and special placement requirements.
policy.unrestricted = {
    ["arithmetic-combinator"] = true,
    ["decider-combinator"] = true,
    ["constant-combinator"] = true,
    ["selector-combinator"] = true,
    lamp = true,
    ["programmable-speaker"] = true,
    ["electric-pole"] = true,
    ["power-switch"] = true,
    inserter = true,
    pipe = true,
    ["pipe-to-ground"] = true,
    pump = true,
    ["heat-pipe"] = true,
    container = true,
    ["logistic-container"] = true,
    ["storage-tank"] = true,
    roboport = true,
    radar = true,
}

-- Use categories.belts; individual restrictions need a reachable unrestricted transport option first.
policy.unrestricted_belts = true

-- Other types, including unknown modded types, retain their native placement rules.
return policy
