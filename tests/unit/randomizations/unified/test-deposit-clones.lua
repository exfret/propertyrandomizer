-- Run from the mod root: lua tests/unit/randomizations/unified/test-deposit-clones.lua
-- A deposit clone shows itself in Factoriopedia and no planet but its own names it in its map settings, by listing or slider
-- The user's game (2026-10-09) showed each scrap clone with a patch of scrap, mining what scrap mines, and on all six planets with the scrap slider, though overrides kept each on one

function table.deepcopy(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end
defines = {
    prototypes = {
        entity = {
            resource = 0,
        },
        item = {},
    },
}
data = {
    raw = {
        resource = {},
        planet = {},
        ["autoplace-control"] = {},
        ["noise-expression"] = {},
    },
}
function data:extend(prototypes)
    for _, prototype in pairs(prototypes) do
        self.raw[prototype.type] = self.raw[prototype.type] or {}
        self.raw[prototype.type][prototype.name] = prototype
    end
end
-- Only prepare uses these
for _, name in pairs({
    "src/config/graph-customization",
    "src/lib/sort/context-sort",
    "src/randomizations/unified/item-fluid",
    "src/logic/builders/combat-encounters",
    "src/logic/init",
    "src/prototypes/lookup/init",
    "src/prototypes/surfaces/surface-sets",
    "src/randomizations/planetary/locks",
    "src/randomizations/planetary/scaffolds",
}) do
    package.loaded[name] = {}
end
package.loaded["src/cost/material-costs/sa"] = {
    costs = {},
}
package.loaded["src/cost/material-costs/py-full"] = {
    costs = {},
}
package.loaded["src/localisation/locale"] = {
    find_localised_name = function(prototype)
        return {
            "entity-name." .. prototype.name,
        }
    end,
    find_localised_description = function()
        return nil
    end,
}

local stage = require("src/randomizations/unified/deposit-copies")
local looks = require("src/prototypes/looks")
local lutils = require("src/logic/logic-utils")

local function prototype(class, name, extra)
    local result = extra or {}
    result.type = class
    result.name = name
    data:extend({
        result,
    })
    return result
end

-- The game's ore page script (make_resource in base/prototypes/factoriopedia-util.lua), cut short
local function ore_page(name)
    return "game.simulation.camera_position = {0, -0.5}\n"
        .. "game.surfaces[1].create_entity{name = \"" .. name .. "\", position = {-2.5, -2.5}, amount = 50}\n"
        .. "game.surfaces[1].create_entity{name = \"" .. name .. "\", position = {-1.5, -2.5}, amount = 100}\n"
end

-- Like scrap: its autoplace names its slider, which its expression reads
prototype("autoplace-control", "test-scrap", {
    category = "resource",
    richness = true,
})
local scrap = prototype("resource", "test-scrap", {
    autoplace = {
        control = "test-scrap",
        probability_expression = "control:test-scrap:size * test_scrap_spots",
    },
    minable = {
        result = "test-scrap",
    },
    factoriopedia_simulation = {
        init = ore_page("test-scrap"),
    },
})
local function planet(name, listed, has_slider, overrides)
    local settings = {}
    if listed then
        settings[scrap.name] = {
            frequency = 2,
        }
    end
    return prototype("planet", name, {
        map_gen_settings = {
            autoplace_controls = has_slider and {
                [scrap.name] = {},
            } or {},
            autoplace_settings = {
                entity = {
                    settings = settings,
                },
            },
            property_expression_names = overrides,
        },
    })
end
-- Its own planet and a copy of it, both with the slider, a planet the resource swap put it on with another slot's placement, and one without it
local home = planet("test-home", true, true, nil)
local home_copy = planet("test-home-exfret-2-copy", true, true, nil)
local swapped = planet("test-swapped", true, false, {
    ["entity:" .. scrap.name .. ":probability"] = "test-stone-probability",
})
-- Planet resource profiles used to add the slider there (src/randomizations/planetary/planet-resource-profiles.lua), so a slider on a planet the clone isn't listed on must not name it either
swapped.map_gen_settings.autoplace_controls[scrap.name] = {}
local other = planet("test-other", false, false, nil)
local planets = {
    home.name,
    home_copy.name,
    swapped.name,
    other.name,
}

local copy_clone = stage.clone_resource(scrap, home_copy.name, planets)
local swapped_clone = stage.clone_resource(scrap, swapped.name, planets)
stage.place_by_listing(scrap, home.name)

-- Where the logic finds an entity, and where a planet names it in its map settings: listed, or with a slider it names (the planets Factoriopedia showed)
local function planets_with(entity, is_there)
    local found = {}
    for _, planet_name in pairs(planets) do
        if is_there(data.raw.planet[planet_name], entity) then
            table.insert(found, planet_name)
        end
    end
    table.sort(found)
    return table.concat(found, ",")
end
local function found_on(entity)
    return planets_with(entity, function(planet_prototype, prot)
        return lutils.check_in_room({
            type = "planet",
            name = planet_prototype.name,
        }, prot)
    end)
end
local function named_on(entity)
    return planets_with(entity, function(planet_prototype, prot)
        local map_gen_settings = planet_prototype.map_gen_settings
        return map_gen_settings.autoplace_settings.entity.settings[prot.name] ~= nil
            or (prot.autoplace.control ~= nil and map_gen_settings.autoplace_controls[prot.autoplace.control] ~= nil)
    end)
end

for _, entry in pairs({
    {
        entity = scrap,
        planet_name = home.name,
    },
    {
        entity = copy_clone,
        planet_name = home_copy.name,
    },
    {
        entity = swapped_clone,
        planet_name = swapped.name,
    },
}) do
    local entity = entry.entity
    assert(found_on(entity) == entry.planet_name, entity.name .. " is found on " .. entry.planet_name .. " alone, got " .. found_on(entity))
    assert(named_on(entity) == entry.planet_name, entity.name .. " is named by " .. entry.planet_name .. "'s map settings alone, got " .. named_on(entity))
end
print("ok - the resource and each clone are found on their own planet and named by no other planet's map settings")

-- A clone is placed by its listing: its expression still reads the slider, and it isn't placed unlisted
assert(copy_clone.autoplace.probability_expression == scrap.autoplace.probability_expression)
assert(copy_clone.autoplace.default_enabled == false and scrap.autoplace.default_enabled == false)
assert(home_copy.map_gen_settings.autoplace_settings.entity.settings[copy_clone.name].frequency == 2, "the clone takes its resource's settings on its planet")
assert(swapped.map_gen_settings.property_expression_names["entity:" .. swapped_clone.name .. ":probability"] == "test-stone-probability", "the clone takes its resource's placement override on its planet")
print("ok - a clone is placed by its planet's listing, with its resource's settings and placement there")

-- Factoriopedia shows a patch of the clone, not of its resource
local init = copy_clone.factoriopedia_simulation.init
assert(string.find(init, "\"" .. copy_clone.name .. "\"", 1, true) ~= nil and string.find(init, "\"" .. scrap.name .. "\"", 1, true) == nil, "the clone's page makes the clone")
assert(scrap.factoriopedia_simulation.init == ore_page(scrap.name), "the resource's page is left as it was")
assert(swapped_clone.factoriopedia_simulation.init == ore_page(swapped_clone.name))
print("ok - each clone's Factoriopedia page shows the clone")

-- A page script read from a file can't be pointed at the copy, and one that only mentions the original otherwise would still show it: the copy shows none; one that never mentions it stays
local function copy_with(simulation)
    return {
        name = "test-copy",
        factoriopedia_simulation = simulation,
    }
end
local from_file = copy_with({
    init_file = "__test__/simulation.lua",
})
looks.retarget_simulation(from_file, scrap.name)
assert(from_file.factoriopedia_simulation == nil)
local other_mention = copy_with({
    init = "game.surfaces[1].create_entities_from_blueprint_string{string = 'x'}\nlocal shown = 'test-scrap'",
})
looks.retarget_simulation(other_mention, scrap.name)
assert(other_mention.factoriopedia_simulation == nil)
local unrelated = copy_with({
    init = "game.simulation.camera_position = {0, 0}",
})
looks.retarget_simulation(unrelated, scrap.name)
assert(unrelated.factoriopedia_simulation.init == "game.simulation.camera_position = {0, 0}")
-- Names with pattern characters are matched as written, and single quotes count too
local single = copy_with({
    init = "game.surfaces[1].create_entity({ name = 'test-scrap', position = {0, 0}})\ngame.surfaces[1].create_entity{name = 'test%scrap'}",
})
looks.retarget_simulation(single, scrap.name)
assert(single.factoriopedia_simulation.init == "game.surfaces[1].create_entity({ name = 'test-copy', position = {0, 0}})\ngame.surfaces[1].create_entity{name = 'test%scrap'}", single.factoriopedia_simulation.init)
print("ok - a copy's page shows the copy or nothing, never only the original")

-- A resource its first planet places by its slider alone keeps the slider
local slider_placed = prototype("resource", "test-slider-placed", {
    autoplace = {
        control = "test-scrap",
        probability_expression = "control:test-scrap:size",
    },
})
local slider_home = planet("test-slider-home", false, true, nil)
stage.place_by_listing(slider_placed, slider_home.name)
assert(slider_placed.autoplace.control == "test-scrap" and slider_placed.autoplace.default_enabled == nil)
print("ok - a resource placed by its slider alone keeps it")
