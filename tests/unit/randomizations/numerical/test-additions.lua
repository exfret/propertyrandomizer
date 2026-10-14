-- Coupled fields, nested/shared tables, defaults, and energy units.
local factor = 0.5
local rolls = 0
package.loaded["src/lib/random/randnum"] = {
    rand = function(params)
        rolls = rolls + 1
        if params.dummy ~= nil then
            return params.dummy * factor
        end
        local target = params.tbl or params.prototype
        target[params.property] = target[params.property] * factor
        return target[params.property]
    end,
}
package.loaded["src/lib/random/rng"] = { key = function(params) return params.id end }
package.loaded["src/prototypes/categories"] = { normal_item_classes = {} }
package.loaded["src/prototypes/data-utils"] = {}
package.loaded["src/lib/random/randprob"] = {}
package.loaded["src/lib/random/randbool"] = {}
package.loaded["src/lib/random/fleishman"] = {}
package.loaded["src/randomizations/helpers/indirect"] = {}
package.loaded["src/prototypes/entities/trigger"] = {}
package.loaded["src/localisation/locale"] = {
    create_localised_description = function(_, ratio)
        assert(ratio == ratio and ratio > 0 and ratio < math.huge)
    end,
}
util = {
    parse_energy = function(value)
        local amount, prefix, unit = value:match("([%d.e+%-]+)([kMG]?)([JW])")
        local multiplier = ({ [""] = 1, k = 1e3, M = 1e6, G = 1e9 })[prefix]
        return tonumber(amount) * multiplier / (unit == "W" and 60 or 1)
    end,
}
defines = { prototypes = { entity = { ["assembling-machine"] = true, reactor = true }, item = { item = true } } }
data = { raw = {} }
randomizations = {}
require("src/randomizations/helpers/energy")
require("src/randomizations/numerical/entity")
require("src/randomizations/numerical/item")

local function run(id)
    randomizations[id](id)
end
local function near(actual, expected)
    assert(math.abs(actual - expected) < 1e-8, tostring(actual) .. " ~= " .. tostring(expected))
end

-- One global roll must reach direct, array, and energy-source boxes, without scaling aliases twice.
for _, multiplier in pairs({ 0.5, 2 }) do
    factor = multiplier
    local shared = { pipe_connections = {}, max_pipeline_extent = 200 }
    local inherited = { pipe_connections = {} }
    local nested = { pipe_connections = {}, max_pipeline_extent = 400 }
    local utility = { default_pipeline_extent = 320 }
    local machine = {
        name = "custom-machine",
        fluid_boxes = { shared, inherited },
        energy_source = { fluid_box = nested },
        fluid_box = shared,
    }
    data.raw = { ["utility-constants"] = { default = utility }, ["assembling-machine"] = { custom = machine } }
    rolls = 0
    run("pipe_extent")
    assert(rolls == 1)
    assert(utility.default_pipeline_extent == 320 * factor)
    assert(shared.max_pipeline_extent == 200 * factor)
    assert(nested.max_pipeline_extent == 400 * factor)
    assert(inherited.max_pipeline_extent == nil)
end

factor = 0.5
local heat = { specific_heat = "1MJ", max_transfer = "2GW" }
local source = { specific_heat = "2MJ", max_transfer = "1GW", min_temperature_gradient = 0 }
data.raw = { reactor = { custom = { name = "custom-reactor", heat_buffer = heat, energy_source = source } } }
run("heat_specific_heat")
run("heat_max_transfer")
run("heat_min_temperature_gradient")
near(util.parse_energy(heat.specific_heat), 500000)
near(util.parse_energy(heat.max_transfer), 1e9 / 60)
near(util.parse_energy(source.max_transfer), 0.5e9 / 60)
assert(heat.min_temperature_gradient == 0.5)
assert(source.min_temperature_gradient == 0)

local speed = { arm = { turn_rate = -0.02 }, grappler = { allow_transpolar_movement = false } }
local cooldown = { 360, 150 }
data.raw = {
    ["agricultural-tower"] = { custom = { name = "custom-tower", crane = { speed = speed } } },
    ["unit-spawner"] = { custom = { name = "custom-spawner", spawning_cooldown = cooldown } },
}
rolls = 0
run("agricultural_tower_crane_speed")
run("unit_spawner_cooldown")
assert(rolls == 2)
assert(speed.arm.turn_rate == -0.01)
assert(speed.arm.extension_speed == 0.025)
assert(speed.grappler.extension_speed == 0.005)
assert(speed.grappler.horizontal_turn_rate == 0.005)
assert(speed.grappler.vertical_turn_rate == 0.005)
assert(speed.grappler.allow_transpolar_movement == false)
assert(cooldown[1] / cooldown[2] == 360 / 150)

local clean = { name = "clean-fuel", fuel_value = "1MJ", fuel_emissions_multiplier = 0 }
local default = { name = "default-fuel", fuel_value = "1MJ" }
local not_fuel = { name = "not-fuel" }
local entity = { name = "custom-entity", max_health = 100 }
local unrepairable = { name = "unrepairable", max_health = 100, repair_speed_modifier = 0 }
data.raw = {
    item = { clean = clean, default = default, other = not_fuel },
    ["assembling-machine"] = { custom = entity, unrepairable = unrepairable },
}
run("item_fuel_emissions")
run("entity_repair_speed")
assert(clean.fuel_emissions_multiplier == 0)
assert(default.fuel_emissions_multiplier == 0.5)
assert(not_fuel.fuel_emissions_multiplier == nil)
assert(entity.repair_speed_modifier == 0.5)
assert(unrepairable.repair_speed_modifier == 0)
print("Numerical additions: coupled values, nested boxes, defaults, zero values, and power units passed")
