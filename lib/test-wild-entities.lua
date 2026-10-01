-- Plain-Lua regression test for planet copies' wild entities (lib/dupe-planets.lua, lib/wild-entities.lua), not loaded by the mod
-- Run from the mod root: lua lib/test-wild-entities.lua
--
-- Entity randomization only moves an entity found in the wild in one room (an entity has one autoplace), and planet copies used to make every tree and rock found on three planets, so in the user's game (2026-10-01) nothing found in the wild moved at all.
-- Each copy now has clones of its original's movable wild entities, and every version must be found on exactly one planet, by the logic's check (lutils.check_in_room) and by what map generation places.

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
-- The prototype classes of each base type; the fixtures below register theirs
defines = {
    prototypes = {
        entity = {},
        item = {},
    },
}
data = {
    raw = {},
}
function data:extend(prototypes)
    for _, prototype in pairs(prototypes) do
        self.raw[prototype.type] = self.raw[prototype.type] or {}
        self.raw[prototype.type][prototype.name] = prototype
    end
end

-- Stand-ins for the modules these don't use
package.loaded["lib/random/rng"] = {
    key = function(info)
        return info.prototype.type .. "/" .. info.prototype.name
    end,
}
package.loaded["resource-autoplace"] = {}
package.loaded["lib/dupe-graphics-manifest"] = {
    files = {},
}
package.loaded["lib/lookup/init"] = {}
package.loaded["lib/surface-sets"] = {}
package.loaded["lib/graph/context-sort"] = {}
package.loaded["lib/logic/init"] = {}
package.loaded["randomizations/planetary/locks"] = {}
package.loaded["randomizations/planetary/oceans"] = {}
package.loaded["lib/planet-names"] = {}

local dupe_planets = require("lib/dupe-planets")
local wild = require("lib/wild-entities")
local lutils = require("lib/logic/logic-utils")

local num_checks = 0
local function check_that(condition, message)
    num_checks = num_checks + 1
    if not condition then
        error(message, 2)
    end
end

local function entity(type, name, autoplace, extra)
    defines.prototypes.entity[type] = 0
    local prototype = extra or {}
    prototype.type = type
    prototype.name = name
    prototype.autoplace = autoplace
    return prototype
end

local function item(type, name, plant_result)
    defines.prototypes.item[type] = 0
    return {
        type = type,
        name = name,
        plant_result = plant_result,
    }
end

-- The sliders the fixtures use (made-up names, like a mod's)
local TREES = "test-forest-slider"
local ROCKS = "test-boulder-slider"

data:extend({
    -- Placed by the trees slider, which another planet (a mod's, say) has too
    entity("tree", "oak", {
        control = TREES,
        probability_expression = "oak_probability",
    }, {
        ambient_sounds = {
            sound = "birds.ogg",
        },
    }),
    -- Listed, and placed by the rocks slider as well
    entity("simple-entity", "boulder", {
        control = ROCKS,
        probability_expression = "boulder_probability",
    }),
    -- Listed, with no slider; a variant of the boulder in the deconstruction planner
    entity("simple-entity", "sandstone", {
        probability_expression = "sandstone_probability",
    }, {
        deconstruction_alternative = "boulder",
    }),
    entity("fish", "carp", {
        probability_expression = 0.01,
    }),
    -- Kept in place: a resource, a planted entity, one a research trigger has you mine, an enemy
    entity("resource", "ore", {
        probability_expression = "ore_probability",
    }),
    entity("plant", "berry-bush", {
        control = TREES,
        probability_expression = "bush_probability",
    }),
    entity("tree", "fossil-tree", {
        probability_expression = "fossil_probability",
    }),
    entity("unit-spawner", "nest", {
        force = "enemy",
        probability_expression = "nest_probability",
    }),
    item("item", "berry-seed", "berry-bush"),
    {
        type = "technology",
        name = "paleontology",
        research_trigger = {
            type = "mine-entity",
            entities = {
                "fossil-tree",
            },
        },
    },
    {
        type = "planet",
        name = "home",
        map_gen_settings = {
            autoplace_controls = {
                [TREES] = {},
                [ROCKS] = {
                    size = 2,
                },
            },
            autoplace_settings = {
                entity = {
                    settings = {
                        ["boulder"] = {},
                        ["sandstone"] = {
                            frequency = 3,
                        },
                        ["carp"] = {},
                        ["ore"] = {},
                        ["fossil-tree"] = {},
                        ["nest"] = {},
                    },
                },
            },
        },
        lightning_properties = {
            priority_rules = {
                {
                    type = "id",
                    string = "boulder",
                    priority_bonus = 90,
                },
                {
                    type = "impact-soundset",
                    string = "test-soundset",
                    priority_bonus = 1,
                },
            },
        },
    },
    {
        type = "planet",
        name = "forest",
        map_gen_settings = {
            autoplace_controls = {
                [TREES] = {},
            },
        },
    },
})

-- The planets copies are made from, as lib/dupe-planets.lua's copy_planet makes them (the planet again under the copy's name)
local copies = {}
for _, number in pairs({2, 3}) do
    local copy = table.deepcopy(data.raw.planet.home)
    copy.name = "home-exfret-" .. number .. "-copy"
    data:extend({
        copy,
    })
    copies[number] = copy
end
local kept = wild.kept_in_place()
local num_cloned = 0
for _, number in pairs({2, 3}) do
    num_cloned = num_cloned + dupe_planets.copy_wild_entities(data.raw.planet.home, copies[number], number, kept)
end
local num_kept_off = dupe_planets.keep_clones_home()

local function planets_found_on(entity_name)
    local prototype = data.raw.tree[entity_name] or data.raw["simple-entity"][entity_name] or data.raw.fish[entity_name] or data.raw.resource[entity_name] or data.raw.plant[entity_name] or data.raw["unit-spawner"][entity_name]
    local found = {}
    for planet_name, _ in pairs(data.raw.planet) do
        if lutils.check_in_room({type = "planet", name = planet_name}, prototype) then
            table.insert(found, planet_name)
        end
    end
    table.sort(found)
    return table.concat(found, ",")
end

check_that(num_cloned == 8, "each copy clones its four movable wild entities, got " .. num_cloned)
check_that(data.raw.resource["ore-exfret-2-copy"] == nil and data.raw.plant["berry-bush-exfret-2-copy"] == nil and data.raw.tree["fossil-tree-exfret-2-copy"] == nil and data.raw["unit-spawner"]["nest-exfret-2-copy"] == nil, "resources, planted entities, research trigger entities and enemies aren't cloned")

-- Every movable version is found on one planet (the oak also on the planet sharing its slider, as before)
check_that(planets_found_on("oak") == "forest,home", "the original oak stays on its planet and the one sharing its slider, got " .. planets_found_on("oak"))
for _, name in pairs({"boulder", "sandstone", "carp"}) do
    check_that(planets_found_on(name) == "home", "the original " .. name .. " is found on its own planet alone, got " .. planets_found_on(name))
end
for _, number in pairs({2, 3}) do
    for _, name in pairs({"oak", "boulder", "sandstone", "carp"}) do
        local clone_name = name .. "-exfret-" .. number .. "-copy"
        check_that(planets_found_on(clone_name) == "home-exfret-" .. number .. "-copy", clone_name .. " is found on its copy alone, got " .. planets_found_on(clone_name))
    end
end
-- Kept ones stay where they were, the copies included
check_that(planets_found_on("ore") == "home,home-exfret-2-copy,home-exfret-3-copy", "a resource stays on every copy")
check_that(planets_found_on("berry-bush") == "forest,home,home-exfret-2-copy,home-exfret-3-copy", "a planted entity stays wherever its slider is")

-- A copy places its clones as it placed the originals: listed with their settings, or through the slider
local settings = copies[2].map_gen_settings.autoplace_settings.entity.settings
check_that(settings["sandstone-exfret-2-copy"].frequency == 3 and settings["sandstone"] == nil, "a clone is listed with its original's settings in its place")
check_that(settings["oak-exfret-2-copy"] == nil and data.raw.tree["oak-exfret-2-copy"].autoplace.control == TREES, "a clone placed by a slider keeps the slider and isn't listed")
check_that(data.raw.planet.home.map_gen_settings.autoplace_settings.entity.settings["sandstone"] ~= nil, "the original planet keeps listing its originals")
-- Clones placed by a slider are kept off the other planets with it: each oak clone off home, forest and the other copy, each boulder clone off home and the other copy
check_that(num_kept_off == 10, "the slider clones are kept off the other planets with their sliders, got " .. num_kept_off)
check_that(wild.never_placed(data.raw.planet.forest, "oak-exfret-2-copy") and not wild.never_placed(data.raw.planet.forest, "oak"), "the planet sharing a slider keeps the original and not the clones")

-- To the player a clone is the same entity, and it never generates as an unlisted default
local oak = data.raw.tree["oak-exfret-2-copy"]
check_that(oak.localised_name[1] == "entity-name.oak", "a clone has its original's name")
check_that(oak.autoplace.default_enabled == false, "a clone isn't placed as an unlisted default")
check_that(oak.deconstruction_alternative == "oak" and oak.factoriopedia_alternative == "oak", "a clone shares its original's deconstruction planner entry and Factoriopedia page")
check_that(oak.ambient_sounds == nil and oak.ambient_sounds_group == "oak", "a clone plays its original's ambient sounds as one group")
check_that(data.raw["simple-entity"]["sandstone-exfret-3-copy"].deconstruction_alternative == "boulder", "a variant's clone goes with what the variant goes with")
check_that(data.raw.tree.oak.autoplace.default_enabled == nil, "the original is left as it was")

-- Lightning rules naming an original name its clone on the copy too
local rules = copies[3].lightning_properties.priority_rules
check_that(#rules == 3 and rules[3].string == "boulder-exfret-3-copy" and rules[3].priority_bonus == 90, "a copy's lightning rule for an original also names its clone")
check_that(#data.raw.planet.home.lightning_properties.priority_rules == 2, "the original planet's lightning rules stay")

-- What entity randomization does when an entity takes another's spot (handlers/entity.lua's reflect): the slot's entity's spec, listing and placement overrides, so it's found just where that entity was
local starting_planets = table.deepcopy(data.raw.planet)
local carp = data.raw.fish.carp
carp.autoplace = table.deepcopy(oak.autoplace)
data.raw.planet.home.map_gen_settings.autoplace_settings.entity.settings["carp"] = nil
for planet_name, planet in pairs(data.raw.planet) do
    wild.set_overrides(planet, "carp", wild.overrides(starting_planets[planet_name], "oak-exfret-2-copy"))
end
check_that(planets_found_on("carp") == "home-exfret-2-copy", "an entity taking a clone's spot is found on that clone's copy alone, got " .. planets_found_on("carp"))

-- Placement overrides that aren't constants at most 0 don't keep an entity off
local home = data.raw.planet.home
home.map_gen_settings.property_expression_names["entity:boulder:probability"] = "boulder_probability_here"
check_that(not wild.never_placed(home, "boulder"), "a real expression doesn't keep an entity off")
home.map_gen_settings.property_expression_names["entity:boulder:probability"] = 0
check_that(wild.never_placed(home, "boulder"), "the constant 0 keeps an entity off")
home.map_gen_settings.property_expression_names["entity:boulder:probability"] = "-1"
check_that(wild.never_placed(home, "boulder"), "a negative constant written as a string keeps an entity off")

print("test-wild-entities: " .. num_checks .. " checks passed")
