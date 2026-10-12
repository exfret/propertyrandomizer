package.loaded["src/config/experimental-flags"] = {military_resistances = true}
-- Run from the mod root: lua tests/unit/randomizations/numerical/test-resistances.lua
-- Test numerical dispatch and ownership with deterministic samplers.
local calls, excluded, factors, round_sample
local function sample(params)
    table.insert(calls, params)
    local factor = factors and factors[#calls] or 2
    if params.combat ~= nil then
        params.combat.apply(factor)
        return factor
    end
    local value = params.tbl[params.property] * factor
    if params.abs_max ~= nil then value = math.min(value, params.abs_max) end
    params.tbl[params.property] = value
    return value
end

package.loaded["src/lib/random/randnum"] = {
    rand = sample,
    fixes = function(params, value)
        if round_sample ~= nil then value = round_sample(value) end
        return math.min(value, params.abs_max or math.huge)
    end,
}
package.loaded["src/lib/random/randprob"] = {rand = sample}
package.loaded["src/lib/random/randbool"] = {}
package.loaded["src/lib/random/fleishman"] = {}
package.loaded["src/lib/random/rng"] = {key = function() return "test-key" end}
package.loaded["src/randomizations/helpers/indirect"] = {}
package.loaded["src/localisation/locale"] = {find_localised_description = function() return "original" end}
package.loaded["src/prototypes/entities/trigger"] = {}
package.loaded["src/prototypes/categories"] = {enemy_health_classes = {}}
package.loaded["src/config/prototype-exclusions"] = {
    active_excluded = function(prototype) return excluded[prototype.name] == true end,
}

package.loaded["src/logic/builders/combat-encounters"] = {definitions = function() return {} end}

randomizations = {}
defines = {prototypes = {entity = {}}}
local entity_randomizations = require("src/randomizations/numerical/entity")

local passed = 0
local function test(name, run)
    calls, excluded, factors, round_sample = {}, {}, nil, nil
    config = {
        damage_type_randomization = true,
        chaos_idx = 1,
    }
    defines = {prototypes = {entity = {["test-entity"] = true}}}
    data = {
        raw = {
            ["test-entity"] = {},
            ["damage-type"] = {
                ["test-a"] = {},
                ["test-b"] = {},
            },
        },
    }
    run()
    passed = passed + 1
    print("ok - " .. name)
end

local function entity(name, entries)
    local value = {
        type = "test-entity",
        name = name,
        resistances = entries,
        is_military_target = true,
    }
    data.raw[value.type][name] = value
    return value
end

test("numerical resistance changes run without graph combat activation", function()
    local row = {
        type = "test-a",
        decrease = 5,
        percent = 20,
    }
    entity("test-target", {row})
    config.damage_type_randomization = false
    config.chaos_idx = 4
    randomizations.resistances("resistances")
    assert(#calls == 2 and row.percent == 40 and row.decrease == 10 and row.type == "test-a")
    assert(calls[1].tbl == row and calls[1].property == "decrease")
    assert(calls[2].tbl == row and calls[2].property == "percent")
end)

test("shared arrays and rows randomize once and keep their identities", function()
    local row = {
        type = "test-a",
        percent = 20,
    }
    local array = {row}
    local first = entity("test-first", array)
    local second = entity("test-second", array)
    local third = entity("test-third", {row})
    randomizations.resistances("resistances")
    assert(#calls == 1 and row.percent == 40 and row.decrease == nil)
    assert(first.resistances == array and second.resistances == array and third.resistances[1] == row)
    assert(first.localised_description ~= nil and second.localised_description ~= nil and third.localised_description ~= nil)
end)

test("an excluded alias prevents all shared numerical writes", function()
    local row = {
        type = "test-a",
        percent = 20,
    }
    entity("test-first", {row})
    entity("test-excluded", {row})
    excluded["test-excluded"] = true
    randomizations.resistances("resistances")
    assert(#calls == 0 and row.percent == 20)
end)

test("immune entries remain identical and ordinary entries cannot become immune", function()
    local immune = {
        type = "test-a",
        percent = 100,
        decrease = 5,
    }
    local ordinary = {
        type = "test-b",
        percent = 80,
    }
    local target = entity("test-target", {
        immune,
        ordinary,
    })
    randomizations.resistances("resistances")
    assert(#calls == 1 and #target.resistances == 2)
    assert(immune.type == "test-a" and immune.percent == 100 and immune.decrease == 5)
    assert(ordinary.type == "test-b" and ordinary.percent < 100 and ordinary.percent > 0)
end)

test("resistance rows shared with non-entity prototypes remain unchanged", function()
    local row = {
        type = "test-a",
        percent = 20,
    }
    entity("test-first", {row})
    data.raw["test-other-kind"] = {
        ["test-outside"] = {
            type = "test-other-kind",
            name = "test-outside",
            resistances = {row},
        },
    }
    randomizations.resistances("resistances")
    assert(#calls == 0 and row.percent == 20)
end)

test("ordinary entities share flat and odds rolls while retaining distinct origins", function()
    local first = entity("test-first", {
        {
            type = "test-a",
            decrease = 2,
            percent = 20,
        },
    })
    local second = entity("test-second", {
        {
            type = "test-a",
            decrease = 4,
            percent = 40,
        },
    })
    first.is_military_target = false
    second.is_military_target = false
    randomizations.resistances("resistances")
    assert(#calls == 2)
    assert(first.resistances[1].decrease == 4 and second.resistances[1].decrease == 8)
    assert(math.abs(first.resistances[1].percent - 100 / 3) < 1e-8)
    assert(math.abs(second.resistances[1].percent - 400 / 7) < 1e-8)
    assert(first.localised_description ~= nil and second.localised_description ~= nil)
end)

test("sensitive owners receive independent rolls before ordinary batches", function()
    local first = entity("test-first", {
        {
            type = "test-a",
            decrease = 2,
        },
    })
    local second = entity("test-second", {
        {
            type = "test-a",
            decrease = 2,
        },
    })
    local ordinary = entity("test-ordinary", {
        {
            type = "test-a",
            decrease = 2,
        },
    })
    ordinary.is_military_target = false
    factors = {
        2,
        3,
        4,
    }
    randomizations.resistances("resistances")
    assert(#calls == 3)
    assert(first.resistances[1].decrease == 4 and second.resistances[1].decrease == 6)
    assert(ordinary.resistances[1].decrease == 8)
end)

test("ordinary batches keep immune rows and excluded owners unchanged", function()
    local first = entity("test-first", {
        {
            type = "test-a",
            decrease = 5,
            percent = 100,
        },
        {
            type = "test-b",
            percent = 80,
        },
    })
    local second = entity("test-second", {
        {
            type = "test-a",
            decrease = 10,
            percent = 100,
        },
        {
            type = "test-b",
            percent = 40,
        },
    })
    local outside = entity("test-outside", {
        {
                type = "test-b",
                percent = 40,
        },
    })
    first.is_military_target = false
    second.is_military_target = false
    outside.is_military_target = false
    excluded[outside.name] = true
    randomizations.resistances("resistances")
    assert(#calls == 1)
    assert(first.resistances[1].percent == 100 and first.resistances[1].decrease == 5)
    assert(second.resistances[1].percent == 100 and second.resistances[1].decrease == 10)
    assert(first.resistances[2].percent < 100 and first.resistances[2].percent > second.resistances[2].percent)
    assert(outside.resistances[1].percent == 40 and outside.localised_description == nil)
end)

test("high ordinary percentages retain tail precision when shared odds decrease", function()
    local first = entity("test-first", {
        {
            type = "test-a",
            percent = 95,
        },
    })
    first.is_military_target = false
    factors = {2 / 3}
    round_sample = function(value)
        if value > 50 then return 100 end
        return math.floor(value * 2 + 0.5) / 2
    end
    randomizations.resistances("resistances")
    assert(#calls == 1 and first.resistances[1].percent == 92.5)
end)

print(passed .. " tests passed")
