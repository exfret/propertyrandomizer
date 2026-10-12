-- Run from the mod root: lua tests/unit/randomizations/misc/test-mining-drill-offsets.lua
bit32 = {
    bxor = function(a, b) return (a ~ b) & 0xFFFFFFFF end,
    lshift = function(a, n) return (a << n) & 0xFFFFFFFF end,
    rshift = function(a, n) return (a & 0xFFFFFFFF) >> n end,
}
math.pow = math.pow or function(a, b) return a ^ b end
local rng = require("src/lib/random/rng")
local randbool = require("src/lib/random/randbool")
local randnum = require("src/lib/random/randnum")
local locale_utils = require("src/localisation/locale")

randomizations = {}
local offsets = require(arg[1] or "src/randomizations/misc/offsets")
local angle = 0
local extension_factor = 0
rng.key = function() return "offset-test" end
rng.float_range = function() return angle end
randbool.rand_chaos = function() return true end
randnum.rand = function(params) return params.dummy * extension_factor end
locale_utils.find_localised_description = function() return "" end

local checked = 0
local function run(drill)
    data = { raw = {} }
    data.raw["mining-drill"] = { fixture = drill }
    randomizations.mining_drill_offsets("mining_drill_offsets")
    return drill.vector_to_place_result
end

local function verify(drill)
    local output = run(drill)
    assert(output[1] == output[1] and output[2] == output[2], "output must be finite")
    assert(math.abs(output[1]) < math.huge and math.abs(output[2]) < math.huge)
    local box = drill.collision_box
    local lt = box.left_top or box[1]
    local rb = box.right_bottom or box[2]
    local left, top = lt.x or lt[1], lt.y or lt[2]
    local right, bottom = rb.x or rb[1], rb.y or rb[2]
    local width = drill.tile_width or math.ceil(right - left)
    local height = drill.tile_height or math.ceil(bottom - top)
    -- Recover the tile containing the output, independently of the ray calculation.
    local x_origin = width % 2 / 2
    local y_origin = height % 2 / 2
    local x = math.floor(x_origin + output[1]) + 0.5 - x_origin
    local y = math.floor(y_origin + output[2]) + 0.5 - y_origin
    assert(x + 0.5 <= left or x - 0.5 >= right or y + 0.5 <= top or y - 0.5 >= bottom,
        string.format("receiving tile overlaps drill: output=(%.5f, %.5f), size=%dx%d, angle=%.5f", output[1], output[2], width, height, angle))
    checked = checked + 1
end

local function fixture(left, top, right, bottom, x, y)
    return {
        type = "mining-drill",
        name = "offset-test-fixture",
        collision_box = {
            {
                left,
                top,
            },
            {
                right,
                bottom,
            },
        },
        vector_to_place_result = {
            x,
            y,
        },
    }
end

-- Burner geometry from base/prototypes/entity/mining-drill.lua in Factorio 2.1.20.
-- The old minimum radius shrinks this to {-0.5, -0.3}, inside its collision box.
verify(fixture(-0.7, -0.7, 0.7, 0.7, -0.35, -1.3))

-- Preview preparation gives item-producing drills an output fluid box too.
local mixed = fixture(-0.7, -0.7, 0.7, 0.7, -0.35, -1.3)
mixed.output_fluid_box = {}
local original_vector = mixed.vector_to_place_result
local original_fluid_box = mixed.output_fluid_box
verify(mixed)
assert(mixed.vector_to_place_result ~= original_vector, "a fluid output box must not suppress item offset randomization")
assert(mixed.output_fluid_box == original_fluid_box, "item offsets must preserve fluid output connections")

-- Cover odd/even and rectangular footprints, non-north outputs, angular extremes, and extensions that shrink to zero or stretch well beyond the drill.
for width = 1, 8 do
    for height = 1, 8 do
        for degrees = -45, 45, 3 do
            angle = degrees * math.pi / 180
            for _, factor in pairs({
                0,
                0.01,
                0.5,
                1,
                4,
            }) do
                extension_factor = factor
                verify(fixture(-width/2 + 0.1, -height/2 + 0.1, width/2 - 0.1, height/2 - 0.1, 0.35, -height/2 - 0.3))
                verify(fixture(-width/2 + 0.1, -height/2 + 0.1, width/2 - 0.1, height/2 - 0.1, width/2 + 0.3, 0))
                verify(fixture(-width/2 + 0.1, -height/2 + 0.1, width/2 - 0.1, height/2 - 0.1, -width/2 - 0.3, height/2 + 0.3))
                -- Asymmetric bounds and explicit dimensions that differ from collision size.
                local asymmetric = fixture(-0.2, -height + 0.2, width - 0.2, 0.2, 0.1, -height - 0.3)
                asymmetric.tile_width = width + 1
                asymmetric.tile_height = height + 1
                verify(asymmetric)
            end
        end
    end
end

local named = fixture(-1.35, -2.35, 1.35, 2.35, 0, -2.85)
named.collision_box = {
    left_top = {
        x = -1.35,
        y = -2.35,
    },
    right_bottom = {
        x = 1.35,
        y = 2.35,
    },
}
named.vector_to_place_result = {
    x = 0,
    y = -2.85,
}
verify(named)

-- Fluid drills, directionless outputs and unsupported geometry retain their vectors.
local fluid = fixture(-0.7, -0.7, 0.7, 0.7, 0, 0)
fluid.output_fluid_box = {}
local zero = fixture(-0.7, -0.7, 0.7, 0.7, 0, 0)
local off_grid = fixture(-0.7, -0.7, 0.7, 0.7, 0, -1.3)
off_grid.flags = { "off-grid" }
local oriented = fixture(-0.7, -0.7, 0.7, 0.7, 0, -1.3)
oriented.collision_box[3] = 0.125
local missing_box = fixture(-0.7, -0.7, 0.7, 0.7, 0, -1.3)
missing_box.collision_box = nil
for _, drill in pairs({
    fluid,
    zero,
    off_grid,
    oriented,
    missing_box,
}) do
    local original = drill.vector_to_place_result
    assert(run(drill) == original, "unsupported outputs should be preserved")
end

print("Mining drill offsets: " .. checked .. " receiving tiles checked; skip cases passed")
