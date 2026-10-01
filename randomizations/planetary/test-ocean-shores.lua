-- Plain-Lua regression test for what an ocean swap moves besides the tiles' own looks (randomizations/planetary/oceans.lua), not loaded by the mod
-- Run from the mod root: lua randomizations/planetary/test-ocean-shores.lua
--
-- A shoreline is drawn by the land tile next to the ocean, from its transitions to the tiles listed in to_tiles.
-- In the user's game (2026-10-01), Vulcanus 2's ocean showed Aquilo's look but kept Vulcanus ground's glowing lava edge, so each restyled tile must be listed where its look's tile was.
-- The clones a look split makes generate only where their slot planet lists them, since other planets let unlisted tiles generate and a planet copy has the same footprint (the original lava showed through on Vulcanus 2 that way).

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
-- oceans.apply never draws at random, and only random_assignment reads the starting planet
package.loaded["helper-tables/constants"] = {}
package.loaded["lib/random/rng"] = {}

local oceans = require("randomizations/planetary/oceans")

local num_checks = 0
local function check_that(condition, message)
    num_checks = num_checks + 1
    if not condition then
        error(message, 2)
    end
end

-- Whether a list holds exactly these names, each once
local function holds_exactly(names, expected)
    local counts = {}
    for _, name in pairs(names) do
        counts[name] = (counts[name] or 0) + 1
    end
    for _, name in pairs(expected) do
        if counts[name] ~= 1 then
            return false
        end
        counts[name] = nil
    end
    return next(counts) == nil
end

local function ocean_tile(name, layer_group, fluid)
    return {
        type = "tile",
        name = name,
        layer_group = layer_group,
        fluid = fluid,
        autoplace = {
            probability_expression = name .. "_probability",
        },
    }
end

-- Two made-up planets: "hot" with a magma ocean, "cold" with brine (two deep looks, so the hot planet's one deep tile gets split)
-- Shore lists shared by several land tiles, like the game's water_tile_type_names, plus one list a land tile has to itself
local waters = {
    "magma",
    "magma-deep",
    "slush",
    "brine",
    "brine-2",
    "puddle",
}
local magmas = {
    "magma-deep",
    "magma",
}
local frost_waters = {
    "slush",
    "brine",
    "brine-2",
}
local tiles = {
    magma = ocean_tile("magma", "water-overlay", "magma-fluid"),
    ["magma-deep"] = ocean_tile("magma-deep", "water", "magma-fluid"),
    slush = ocean_tile("slush", "water-overlay", "brine-fluid"),
    brine = ocean_tile("brine", "water", "brine-fluid"),
    ["brine-2"] = ocean_tile("brine-2", "water", "brine-fluid"),
    cinder = {
        type = "tile",
        name = "cinder",
        transitions = {
            { to_tiles = waters },
            { to_tiles = magmas },
        },
    },
    basalt = {
        type = "tile",
        name = "basalt",
        transitions = {
            { to_tiles = waters },
            { to_tiles = magmas },
        },
    },
    frost = {
        type = "tile",
        name = "frost",
        transitions = {
            { to_tiles = frost_waters },
        },
    },
}
local function planet(tile_names)
    local settings = {}
    for _, tile_name in pairs(tile_names) do
        settings[tile_name] = {}
    end
    return {
        type = "planet",
        map_gen_settings = {
            autoplace_settings = {
                tile = {
                    settings = settings,
                },
            },
        },
    }
end
data = {
    raw = {
        tile = tiles,
        planet = {
            hot = planet({
                "magma",
                "magma-deep",
                "cinder",
                "basalt",
            }),
            cold = planet({
                "slush",
                "brine",
                "brine-2",
                "frost",
            }),
        },
        item = {},
    },
}
function data:extend(prototypes)
    for _, prototype in pairs(prototypes) do
        self.raw[prototype.type] = self.raw[prototype.type] or {}
        self.raw[prototype.type][prototype.name] = prototype
    end
end
oceans.families = {
    hot = {
        fluid = "magma-fluid",
        shallow = {
            "magma",
        },
        deep = {
            "magma-deep",
        },
    },
    cold = {
        fluid = "brine-fluid",
        shallow = {
            "slush",
        },
        deep = {
            "brine",
            "brine-2",
        },
    },
}
oceans.planet_order = {
    "hot",
    "cold",
}

local clone_to_slot = oceans.apply({
    hot = "cold",
    cold = "hot",
})
local clone_name = "propertyrandomizer-magma-deep-brine-2"

-- The look split: the hot planet's deep tile shows both of the cold planet's deep looks
check_that(clone_to_slot[clone_name] == "magma-deep", "the hot deep tile was split for the second brine look")
check_that(tiles["magma-deep"].fluid == "brine-fluid" and tiles[clone_name].fluid == "brine-fluid", "the hot deep tile and its clone give the cold planet's fluid")
check_that(tiles.magma.fluid == "brine-fluid" and tiles.slush.fluid == "magma-fluid", "shallow tiles trade fluids")

-- The clone generates only where its slot planet lists it
check_that(tiles[clone_name].autoplace.default_enabled == false, "the clone isn't a default anywhere")
check_that(data.raw.planet.hot.map_gen_settings.autoplace_settings.tile.settings[clone_name] ~= nil, "the hot planet lists the clone")
check_that(data.raw.planet.cold.map_gen_settings.autoplace_settings.tile.settings[clone_name] == nil, "the cold planet doesn't list it")

-- Shorelines follow the looks: a restyled tile is listed where the tile it looks like was, and nowhere else
-- Every tile listed in the shared water list looked like a listed tile, so all of them stay, and the clone joins them; the other water tile is untouched
check_that(holds_exactly(waters, { "puddle", "magma", "magma-deep", clone_name, "slush", "brine", "brine-2" }), "the shared water list holds every restyled tile once and keeps the rest")
-- Only the cold tiles now look like magma, so they get the glowing edge and the hot tiles lose it
check_that(holds_exactly(magmas, { "slush", "brine", "brine-2" }), "the magma shore list holds exactly the tiles that look like magma")
-- Shared lists are rewritten once and stay shared (a second pass would flip the magma list back)
check_that(tiles.cinder.transitions[2].to_tiles == magmas and tiles.basalt.transitions[2].to_tiles == magmas, "the magma list is still one shared table")
-- The cold land's own shore list now holds the tiles that look like the cold ocean
check_that(holds_exactly(frost_waters, { "magma", "magma-deep", clone_name }), "a land tile's own list follows the looks too")

print("test-ocean-shores: " .. num_checks .. " checks passed")
