-- Regression coverage for shared-grid isolation, geometry bounds, and restored defaults.
bit32 = {
    bxor = function(a, b) return (a ~ b) & 0xFFFFFFFF end,
    lshift = function(a, n) return (a << n) & 0xFFFFFFFF end,
    rshift = function(a, n) return (a & 0xFFFFFFFF) >> n end,
}
math.pow = math.pow or function(a, b) return a ^ b end
function table.deepcopy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do result[key] = table.deepcopy(child) end
    return result
end
local descriptions = {}
package.loaded["src/localisation/locale"] = {
    create_localised_description = function(prototype, ratio, id, options)
        assert(ratio == ratio and ratio >= 0 and ratio < math.huge)
        descriptions[prototype] = {ratio = ratio, id = id, options = options}
    end,
}
package.loaded["src/prototypes/categories"] = {normal_item_classes = {}}
package.loaded["src/prototypes/data-utils"] = {}
package.loaded["src/randomizations/helpers/indirect"] = {}
package.loaded["src/prototypes/entities/trigger"] = {}
defines = {prototypes = {entity = {locomotive = true, ["cargo-wagon"] = true, car = true}, item = {}}}
data = {raw = {}}
function data:extend(prototypes)
    for _, prototype in pairs(prototypes) do self.raw[prototype.type][prototype.name] = prototype end
end
randomizations = {}
local rng = require("src/lib/random/rng")
local randnum = require("src/lib/random/randnum")
local tuning = require("src/lib/random/tuning")
require("src/randomizations/numerical/entity")
require("src/randomizations/numerical/item")
require("src/randomizations/numerical/tile")
require("src/randomizations/numerical/equipment-grid")
local function run(id) randomizations[id](id) end

for seed = 1, 20 do
    config = {
        seed = seed,
        bias = 0,
        bias_idx = 2,
        chaos = 1,
        chaos_range = 1,
        numerical_algorithm = "exfret-random-walk",
        numerical_overrides = {},
        numerical_variances = {},
    }
    rng.prgs = {}
    descriptions = {}
    local original = {name = "shared-grid", type = "equipment-grid", width = 8, height = 6, equipment_categories = {"test-category"}}
    local armor = {name = "test-armor", type = "armor", equipment_grid = original.name}
    local car = {name = "test-car", type = "car", equipment_grid = original.name, max_speed = 1}
    local sprite = {name = "default", type = "utility-sprites", equipment_grid = {filename = "test.png"}}
    data.raw = {armor = {armor = armor}, car = {car = car}, ["equipment-grid"] = {[original.name] = original}, ["utility-sprites"] = {default = sprite}}
    run("equipment_grid_sizes")
    assert(armor.equipment_grid ~= car.equipment_grid)
    assert(armor.equipment_grid ~= original.name and car.equipment_grid ~= original.name)
    assert(original.width == 8 and original.height == 6)
    for _, owner in pairs({armor, car}) do
        local grid = data.raw["equipment-grid"][owner.equipment_grid]
        assert(grid.width >= 1 and grid.height >= 1)
        assert(grid.width % 1 == 0 and grid.height % 1 == 0)
        assert(grid.equipment_categories ~= original.equipment_categories)
        assert(grid.equipment_categories[1] == "test-category")
        assert(descriptions[owner] ~= nil)
    end
    assert(type(sprite.equipment_grid) == "table")

    local drill = {name = "offset-drill", type = "mining-drill", resource_searching_radius = 4.49, resource_searching_offset = {x = 0.5, y = -1}, collision_box = {left_top = {x = -2, y = -1}, right_bottom = {x = 2, y = 1}, orientation = 0.125}}
    data.raw["mining-drill"] = {drill = drill}
    run("mining_drill_radius")
    assert(drill.resource_searching_radius >= 3 / math.sqrt(2) + 1 - 1e-10)
    local rounded_radius = drill.resource_searching_radius + 0.51
    assert(math.abs(rounded_radius - math.floor(rounded_radius + 0.5)) < 1e-10, tostring(drill.resource_searching_radius))
    assert(descriptions[drill] ~= nil)

    local locomotive = {name = "test-locomotive", type = "locomotive", max_speed = 1.2, joint_distance = 4, connection_distance = 3}
    local wagon = {name = "test-wagon", type = "cargo-wagon", max_speed = 2, joint_distance = 4, connection_distance = 3}
    local omitted = {name = "uncapped-wagon", type = "cargo-wagon", joint_distance = 4, connection_distance = 3}
    data.raw.locomotive = {locomotive = locomotive}
    data.raw["cargo-wagon"] = {wagon = wagon, omitted = omitted}
    run("locomotive_max_speed")
    assert(descriptions[locomotive] ~= nil and descriptions[wagon] ~= nil)
    assert(omitted.max_speed == nil and car.max_speed == 1)

    local roboport = {name = "test-roboport", type = "roboport", logistics_radius = 25, construction_radius = 70}
    local tile = {name = "test-tile", type = "tile"}
    local gun = {name = "test-gun", type = "gun", attack_parameters = {movement_slow_down_factor = 0.2}}
    local stopped = {name = "stopped-gun", type = "gun", attack_parameters = {movement_slow_down_factor = 1}}
    local default_gun = {name = "default-gun", type = "gun", attack_parameters = {}}
    local free = {name = "free-gun", type = "gun", attack_parameters = {movement_slow_down_factor = 0}}
    local inserter = {name = "test-inserter", type = "inserter"}
    data.raw.roboport = {roboport = roboport}
    data.raw.tile = {tile = tile}
    data.raw.gun = {gun = gun, stopped = stopped, default_gun = default_gun, free = free}
    data.raw.inserter = {inserter = inserter}
    run("roboport_radar_range")
    run("tile_walking_speed_modifier")
    run("gun_movement_slowdown_factor")
    local rounded_slowdown = randnum.fixes({rounding = tuning.default_rounding}, gun.attack_parameters.movement_slow_down_factor)
    assert(math.abs(gun.attack_parameters.movement_slow_down_factor - rounded_slowdown) < 1e-10)
    assert(stopped.attack_parameters.movement_slow_down_factor == 1)
    assert(default_gun.attack_parameters.movement_slow_down_factor == nil)
    assert(free.attack_parameters.movement_slow_down_factor >= 0 and free.attack_parameters.movement_slow_down_factor < 1)
    run("inserter_base_hand_size")
    local radar = {name = "test-radar", type = "radar", max_distance_of_nearby_sector_revealed = 3}
    local blind = {name = "blind-radar", type = "radar", max_distance_of_nearby_sector_revealed = 0}
    local gate = {name = "test-gate", type = "gate", opening_speed = 0.07, activation_distance = 3}
    car.rotation_speed = 0.01
    data.raw.radar = {radar = radar, blind = blind}
    data.raw.gate = {gate = gate}
    run("radar_reveal_area")
    run("gate_opening_speed")
    run("car_rotation_speed")
    assert(descriptions[radar] ~= nil and descriptions[gate] ~= nil and descriptions[car] ~= nil)
    assert(blind.max_distance_of_nearby_sector_revealed == 0)
    assert(math.abs(descriptions[roboport].ratio - roboport.radar_range / 3) < 1e-10)
    assert(tile.walking_speed_modifier > 0 and descriptions[tile] ~= nil)
    assert(gun.attack_parameters.movement_slow_down_factor >= 0 and gun.attack_parameters.movement_slow_down_factor < 1)
    assert(math.abs(descriptions[gun].ratio - (1 - gun.attack_parameters.movement_slow_down_factor) / 0.8) < 1e-10)
    assert(inserter.stack_size_bonus >= 0 and inserter.stack_size_bonus % 1 == 0 and descriptions[inserter] ~= nil)
end
print("Restored numerical randomizations: isolation, collision bounds, stock limits, defaults, tooltips, and fractional gun values passed")

-- With the random walk disabled, these isolate rounding from the inverse transform.
-- Rounding 1.23456 before conversion would give 0.187 rather than 0.19.
config.chaos = 0
for _, fixture in pairs({
    {travel_time = 1, expected = 0},
    {travel_time = 1.23456, expected = 0.19},
    {travel_time = 1.57, expected = 0.363},
    {travel_time = 2.35, expected = 0.574},
    {travel_time = 100, expected = 0.99},
}) do
    local original = 1 - 1 / fixture.travel_time
    local gun = {
        name = "rounding-fixture",
        type = "gun",
        attack_parameters = {movement_slow_down_factor = original},
    }
    data.raw.gun = {gun = gun}
    rng.prgs = {}
    run("gun_movement_slowdown_factor")
    assert(math.abs(gun.attack_parameters.movement_slow_down_factor - fixture.expected) < 1e-12)
    assert(math.abs(descriptions[gun].ratio - (1 - fixture.expected) / (1 - original)) < 1e-12)
end
assert(randnum.fixes({rounding = tuning.default_rounding}, 0) == 0)
print("Gun slowdown rounding: final fractions, no intermediate rounding, zero endpoint, and matching tooltips passed")
