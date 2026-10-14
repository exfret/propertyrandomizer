local function deepcopy(value, seen)
    if type(value) ~= "table" then return value end
    seen = seen or {}
    if seen[value] ~= nil then return seen[value] end
    local copy = {}
    seen[value] = copy
    for key, entry in pairs(value) do copy[key] = deepcopy(entry, seen) end
    return copy
end
table.deepcopy = deepcopy

local factor = 1
package.loaded["src/lib/random/randnum"] = {
    rand = function(params) return math.min(params.abs_max, math.max(params.abs_min, params.dummy * factor)) end,
}
package.loaded["src/config/prototype-exclusions"] = {
    excluded = function(_, _, prototype) return prototype.excluded == true end,
}
package.loaded["src/localisation/locale"] = {
    find_localised_description = function(prototype) return prototype.localised_description or "original" end,
}
bit32 = {
    bxor = function(a, b) return (a ~ b) & 0xFFFFFFFF end,
    lshift = function(a, n) return (a << n) & 0xFFFFFFFF end,
    rshift = function(a, n) return (a & 0xFFFFFFFF) >> n end,
}
local rng = require("src/lib/random/rng")
randomizations = {}
data = { raw = {} }
config = { seed = 1 }
require("src/randomizations/misc/module-effects")

local function module(name, category, effect)
    return {
        type = "module",
        name = name,
        category = category,
        tier = 1,
        effect = effect,
    }
end
local forced_calls = 0
local function run(seed)
    forced_calls = 0
    config.seed = seed or 1
    rng.prgs = {}
    randomizations.module_effects("module_effects")
end
local function profile(effect)
    local keys = {}
    for name, value in pairs(effect) do if value ~= 0 then keys[#keys + 1] = name end end
    table.sort(keys)
    return table.concat(keys, ",")
end

-- Verify new effect sets, combinations, deterministic seeds, and duplicate categories and tiers.
-- Every original beneficial entry must survive across many seeds, with no consumers present.
local changed, mixed, changed_benefit = false, false, false
local function fixture()
    local shared = {
        speed = 0.2,
        consumption = 0.5,
    }
    local locked = module("locked", "custom-modules", shared)
    locked.excluded = true
    return {
        module = {
            a = module("a", "custom-modules", shared),
            b = module("b", "custom-modules", { consumption = -0.5 }),
            c = module("c", "custom-modules", {
                productivity = 0.1,
                speed = -0.15,
            }),
            d = module("d", "custom-modules", {
                quality = 0.02,
                speed = -0.1,
            }),
            e = module("e", "custom-modules", { pollution = -0.1 }),
            f = module("f", "custom-modules", {
                speed = 0.3,
                pollution = -0.05,
            }),
            locked = locked,
        },

    }
end
local function snapshot()
    local out = {}
    for _, name in pairs({
        "a",
        "b",
        "c",
        "d",
        "e",
        "f",
        "locked",
    }) do
        local effect = data.raw.module[name].effect
        for _, field in pairs({
            "consumption",
            "pollution",
            "productivity",
            "quality",
            "speed",
        }) do
            out[#out + 1] = name .. ":" .. field .. "=" .. tostring(effect[field])
        end
    end
    return table.concat(out, ";")
end
for seed = 1, 100 do
    data.raw = fixture()
    local before = {}
    for name, item in pairs(data.raw.module) do before[name] = profile(item.effect) end
    local excluded = data.raw.module.locked.effect
    run(seed)
    local present = {}
    for name, item in pairs(data.raw.module) do
        if profile(item.effect) ~= before[name] then changed = true end
        local benefits = 0
        for effect, value in pairs(item.effect) do
            if ((effect == "consumption" or effect == "pollution") and value < 0)
                or (effect ~= "consumption" and effect ~= "pollution" and value > 0) then
                present[effect] = true
                benefits = benefits + 1
            end
        end
        if benefits > 1 and profile(item.effect) ~= before[name] then mixed = true end
        if name == "a" and (item.effect.productivity or 0) > 0 then changed_benefit = true end
        assert(item.category == "custom-modules" and item.tier == 1)
    end
    for _, effect in pairs({
        "speed",
        "consumption",
        "pollution",
        "productivity",
        "quality",
    }) do assert(present[effect]) end
    assert(data.raw.module.locked.effect == excluded)
    assert(excluded.speed == 0.2 and excluded.consumption == 0.5)
    assert(data.raw.module.locked.localised_description == nil)
    local first = snapshot()
    data.raw = fixture()
    run(seed)
    assert(first == snapshot(), "seed must reproduce the same effects")
end
assert(changed and mixed and changed_benefit, "must change benefits, effect sets, and combinations")

-- A productivity entry can move between arbitrary categories without consumer checks.
local original_int, original_shuffle, original_value = rng.int, rng.shuffle, rng.value
rng.int = function(_, maximum)
    forced_calls = forced_calls + 1
    if forced_calls == 1 then return math.min(2, maximum) end
    return (forced_calls - 1) % 4 < 2 and 1 or math.min(2, maximum)
end
rng.shuffle = function() end
rng.value = function() return 1 end
local function transfer_fixture()
    local a = module("a", "source", {
        speed = 0.2,
        productivity = 0.1,
    })
    a.productivity_quality_multiplier = 0.7
    local b = module("b", "target", { speed = 0.4 })
    return {
        module = {
            a = a,
            b = b,
        },
    }
end
data.raw = transfer_fixture()
run()
assert(data.raw.module.b.effect.productivity == 0.1)
assert(data.raw.module.b.productivity_quality_multiplier == 0.7)
assert(data.raw.module.a.effect.productivity == nil)
assert(data.raw.module.a.productivity_quality_multiplier == nil)
assert(data.raw.module.a.category == "source" and data.raw.module.b.category == "target")

-- Reject a trade that would leave a module with no benefit, restoring absent fields and scaling.
data.raw = transfer_fixture()
data.raw.module.a.effect.speed = nil
run()
assert(data.raw.module.a.effect.productivity == 0.1)
assert(data.raw.module.a.productivity_quality_multiplier == 0.7)
assert(data.raw.module.b.effect.productivity == nil)
assert(data.raw.module.b.productivity_quality_multiplier == nil)

-- An atomic trade can exchange the only benefit of each module.
data.raw = transfer_fixture()
data.raw.module.a.effect.speed = nil
rng.value = function() return 0 end
run()
assert(data.raw.module.a.effect.speed == 0.4)
assert(data.raw.module.a.effect.productivity == nil)
assert(data.raw.module.b.effect.speed == nil)
assert(data.raw.module.b.effect.productivity == 0.1)
rng.int, rng.shuffle, rng.value = original_int, original_shuffle, original_value

-- Magnitudes vary without erasing a tiny positive productivity entry or changing signs.
data.raw = {
    module = {
        only = module("only", "source", {
            productivity = 0.0001,
            speed = -0.2,
            consumption = -0.3,
        }),
    },
}
factor = 0.001
run()
assert(data.raw.module.only.effect.productivity == 0.0001)
assert(data.raw.module.only.effect.speed < 0)
assert(data.raw.module.only.effect.consumption < 0)
factor = 2
data.raw = { module = { only = module("only", "source", { productivity = 0.1 }) } }
run()
assert(data.raw.module.only.effect.productivity == 0.2)

-- Reading entities, recipes, technologies or quality prototypes is unnecessary.
data.raw = setmetatable({ module = { only = module("only", "source", { productivity = 0.1 }) } }, {
    __index = function(_, key) error("Unexpected prototype access: " .. key) end,
})
run()
assert(data.raw.module.only.effect.productivity == 0.2)

-- Sparse or empty pools work without inventing effects absent from the input.
factor = 1
for _, raw in pairs({
    {},
    { module = {} },
    { module = { only = module("only", "source", { speed = 0.2 }) } },
}) do
    data.raw = raw
    run()
    if raw.module ~= nil and raw.module.only ~= nil then
        assert(data.raw.module.only.effect.speed == 0.2)
        assert(data.raw.module.only.effect.productivity == nil)
    end
end
print("Module effects: new combinations, 100 reproducible seeds, productivity preservation, exclusions, scaling, rollback, and sparse pools passed")
