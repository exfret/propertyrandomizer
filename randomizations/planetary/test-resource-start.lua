-- Plain-Lua regression test for which resources the starting planet keeps in resource swaps (randomizations/planetary/resources.lua), not loaded by the mod
-- Run from the mod root: lua randomizations/planetary/test-resource-start.lua
--
-- The starting planet keeps its starting area's resources and its wells (user, 2026-10-01, like it keeps its ocean's fluid).
-- When the user's seed swapped Nauvis's copper away, 12,343 goals failed, the other planets' too through the recipes they share, and the fix pass couldn't repair it.
-- Starting area resources are read from the game's resource-autoplace helper (has_starting_area_placement = 1 in the patches expression), not from names.

-- Stand-ins for the Factorio environment
function table.deepcopy(tbl)
    if type(tbl) ~= "table" then
        return tbl
    end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end
function log(msg) end
serpent = {
    block = tostring,
    line = tostring,
}
settings = {
    startup = {},
}
mods = {}
config = {}
package.loaded["__core__/lualib/resource-autoplace"] = {}
package.loaded["helper-tables/constants"] = {
    starting_planet = "home",
}
-- A seeded generator in place of the mod's (which needs Factorio's bit32), so the shuffles differ from draw to draw
local state = 1
package.loaded["lib/random/rng"] = {
    key = function(params)
        return params.id
    end,
    int = function(_, max)
        state = (state * 1103515245 + 12345) % 2147483648
        return state % max + 1
    end,
    shuffle = function(key, tbl)
        for i = #tbl, 2, -1 do
            local j = package.loaded["lib/random/rng"].int(key, i)
            tbl[i], tbl[j] = tbl[j], tbl[i]
        end
    end,
}
package.loaded["lib/graph/context-sort"] = {}
package.loaded["randomizations/planetary/check"] = {}
package.loaded["randomizations/planetary/locks"] = {}
package.loaded["randomizations/planetary/scaffolds"] = {}
package.loaded["lib/surface-sets"] = {}

-- The game: a starting planet and two others with made-up resources, so the fixtures hardcode no vanilla names (dev/hardcoded-names.py)
data = {
    raw = {},
    extend = function(self, prototypes)
        for _, prototype in pairs(prototypes) do
            self.raw[prototype.type] = self.raw[prototype.type] or {}
            self.raw[prototype.type][prototype.name] = prototype
        end
    end,
}
local function prototype(kind, name, fields)
    fields.type = kind
    fields.name = name
    data:extend({
        fields,
    })
    return fields
end
-- A resource as the game's resource-autoplace helper makes it: its probability reads a patches expression that says whether it has starting area patches (1), none (0) or there's no starting area (-1)
local function resource(name, starting_area, is_well)
    prototype("noise-expression", "default-" .. name .. "-patches", {
        expression = "resource_autoplace_all_patches{base_density = 10,has_starting_area_placement = " .. starting_area .. ",seed1 = 100}",
    })
    local result_type = "item"
    if is_well then
        result_type = "fluid"
    end
    prototype("resource", name, {
        autoplace = {
            probability_expression = "clamp(var('default-" .. name .. "-patches'), 0, 1)",
            richness_expression = "var('default-" .. name .. "-patches')",
        },
        minable = {
            results = {
                {
                    type = result_type,
                    name = name .. "-product",
                },
            },
        },
    })
end
resource("red-ore", 1, false)
resource("black-rock", 1, false)
resource("glow-ore", 0, false)
resource("tar-well", 0, true)
resource("blue-ore", -1, false)
resource("salt-well", -1, true)
-- A planet override of a starting area resource still counts (it reads the patches expression too)
prototype("noise-expression", "home-black-rock-probability", {
    expression = "0.5 * clamp(var('default-black-rock-patches'), 0, 1)",
})
local function planet(name, resource_names, overrides)
    local entity_settings = {}
    for _, resource_name in pairs(resource_names) do
        entity_settings[resource_name] = {}
    end
    prototype("planet", name, {
        map_gen_settings = {
            autoplace_settings = {
                entity = {
                    settings = entity_settings,
                },
            },
            property_expression_names = overrides,
        },
    })
end
planet("home", {
    "red-ore",
    "black-rock",
    "glow-ore",
    "tar-well",
}, {
    ["entity:black-rock:probability"] = "home-black-rock-probability",
})
planet("away", {
    "blue-ore",
    "red-ore",
    "salt-well",
}, {})
planet("far", {
    "glow-ore",
    "black-rock",
    "salt-well",
}, {})

local resources = require("randomizations/planetary/resources")

local num_checks = 0
local function check(condition, message)
    num_checks = num_checks + 1
    if condition ~= true then
        error("test-resource-start: " .. message)
    end
end

local slots = resources.slots()
local slot_of = {}
for i, slot in pairs(slots) do
    slot_of[slot.planet_name .. "/" .. slot.resource_name] = i
end
check(#slots == 10, "expected 10 slots, got " .. #slots)

-- 1. Starting area resources are read from the patches expression, through a planet's override too
check(resources.in_starting_area(slots[slot_of["home/red-ore"]]), "red ore has starting area patches")
check(resources.in_starting_area(slots[slot_of["home/black-rock"]]), "black rock (read through home's override) has starting area patches")
check(not resources.in_starting_area(slots[slot_of["home/glow-ore"]]), "glow ore has none (0)")
check(not resources.in_starting_area(slots[slot_of["away/blue-ore"]]), "blue ore has none (-1, no starting area)")

-- 2. Over many draws, the starting planet keeps its starting area's resources and its wells, and everything else still moves
local moved = {}
for _ = 1, 200 do
    local assignment = resources.random_assignment(slots, "planetary-resources")
    check(assignment[slot_of["home/red-ore"]] == "red-ore", "home lost its red ore")
    check(assignment[slot_of["home/black-rock"]] == "black-rock", "home lost its black rock")
    check(assignment[slot_of["home/tar-well"]] == "tar-well", "home lost its well")
    local placed = {}
    for i, slot in pairs(slots) do
        check(assignment[i] ~= nil, "slot " .. slot.planet_name .. "/" .. slot.resource_name .. " got nothing")
        placed[assignment[i]] = (placed[assignment[i]] or 0) + 1
        if assignment[i] ~= slot.resource_name then
            moved[slot.planet_name .. "/" .. slot.resource_name] = true
        end
    end
    -- Every resource is placed as often as before: the kept slots left the shuffle with their own resources
    check(placed["red-ore"] == 2 and placed["black-rock"] == 2 and placed["salt-well"] == 2 and placed["tar-well"] == 1, "the draw lost or doubled a resource")
end
check(moved["home/glow-ore"] == true, "home's other ore never moved")
check(moved["away/red-ore"] == true and moved["far/black-rock"] == true, "another planet's copy of a kept resource never moved")
check(moved["home/red-ore"] == nil and moved["home/tar-well"] == nil, "a kept slot moved")

print("test-resource-start: " .. num_checks .. " checks passed")
