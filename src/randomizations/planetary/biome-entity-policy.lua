-- Eligibility for machine biome draws.
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

-- Infrastructure does not participate: keep its native placement rules, with no draw or forced profile.
-- Other types, including unknown modded types, also retain their native placement rules.
return policy
