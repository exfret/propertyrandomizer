-- Plain-Lua regression tests for lib/mining-fluids.lua (not loaded by the mod)
-- Run from the mod root: lua lib/test-mining-fluids.lua
-- With the unified randomizations in development, no resource needs a mining fluid before the mining fluid randomization chooses them (user, 2026-10-09)

local mining_fluids = require("lib/mining-fluids")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function resources()
    return {
        ["uranium-ore"] = {
            name = "uranium-ore",
            minable = {
                mining_time = 2,
                result = "uranium-ore",
                fluid_amount = 10,
                required_fluid = "sulfuric-acid",
            },
        },
        ["iron-ore"] = {
            name = "iron-ore",
            minable = {
                mining_time = 1,
                result = "iron-ore",
            },
        },
        -- A resource that can't be mined at all is left alone
        ["decoration"] = {
            name = "decoration",
        },
    }
end

test("a resource needing a mining fluid needs none afterwards, and the log says what it needed", function()
    local all = resources()
    local stripped = mining_fluids.strip(all)
    assert(#stripped == 1 and stripped[1] == "uranium-ore (sulfuric-acid)", "the log names the resource and its fluid")
    assert(all["uranium-ore"].minable.required_fluid == nil, "uranium ore needs no fluid now")
    assert(all["uranium-ore"].minable.fluid_amount == nil, "and uses up none, so it can be mined by hand again")
    assert(all["uranium-ore"].minable.result == "uranium-ore", "what it's mined into stays")
end)

test("resources needing no fluid, or not minable at all, are left as they were", function()
    local all = resources()
    mining_fluids.strip(all)
    assert(all["iron-ore"].minable.mining_time == 1 and all["iron-ore"].minable.required_fluid == nil, "iron ore is unchanged")
    assert(all["decoration"].minable == nil, "an unminable resource stays unminable")
end)

print(num_passed .. " tests passed")
