offline = true

require("offline/utils/master")
bit32 = {
    bxor = function(a,b) return a ~ b & 0xffffffff end,
    lshift = function(a,b) return a << b & 0xffffffff end,
    rshift = function(a,b) return a >> b & 0xffffffff end
}
math.pow = function(a,b) return a ^ b end

mods = {
    ["space-age"] = false
}

local data_file = io.open("offline/data-raw/base.json", "rb")
data = {}
data.raw = json.parse(data_file:read("*all"))
log = print

data.raw["utility-constants"] = {
    default = {
        rocket_lift_weight = 1000000
    }
}

-- Skip data.lua as it's not needed and uses the undefined :extend method for data
--require("data")
require("data-updates")
require("data-final-fixes")

output = io.open("offline/output/data-raw-randomized.json", "wb")
output:write(json.stringify(data.raw))