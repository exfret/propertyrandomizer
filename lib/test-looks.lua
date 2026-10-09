-- Plain-Lua regression tests: a copy shows itself on its Factoriopedia page, and a resource looks like what it mines (not loaded by the mod)
-- Run from the mod root: lua lib/test-looks.lua
-- In the user's game (2026-10-09) the planet copies of the spidertron, robots, crusher, thrusters, train cars and mech armor showed their originals in Factoriopedia, since a page is a script that makes things by name (PrototypeBase::factoriopedia_simulation)
-- Randomized resources there had their new item on their patches but kept their old icon

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
defines = {
    prototypes = {
        entity = {
            ["spider-vehicle"] = 0,
            ["cargo-wagon"] = 0,
            ["assembling-machine"] = 0,
            resource = 0,
        },
        item = {
            item = 0,
            armor = 0,
        },
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

-- Stand-ins for the modules lib/dupe.lua loads, which these don't use
package.loaded["helper-tables/categories"] = {}
package.loaded["lib/random/rng"] = {
    key = function(info)
        return info.prototype.type .. "/" .. info.prototype.name
    end,
}
package.loaded["lib/locale"] = {
    find_localised_name = function(prototype)
        return {
            "entity-name." .. prototype.name,
        }
    end,
    find_localised_description = function()
        return nil
    end,
}
package.loaded["resource-autoplace"] = {}
package.loaded["lib/dupe-graphics-manifest"] = {
    files = {},
}

local dupe = require("lib/dupe")
local looks = require("lib/looks")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function has(text, part)
    return string.find(text, part, 1, true) ~= nil
end

test("a planet copy's page makes the copy, and the original's page is left as it was", function()
    local init = "game.simulation.camera_zoom = 1.3\ngame.surfaces[1].create_entity{name = \"test-spider\", position = {0, 0}}\n"
    local spider = {
        type = "spider-vehicle",
        name = "test-spider",
        factoriopedia_simulation = {
            init = init,
        },
    }
    local copy = dupe.prototype(spider, 2)
    assert(copy.name == "test-spider-exfret-2-copy")
    assert(has(copy.factoriopedia_simulation.init, "create_entity{name = \"test-spider-exfret-2-copy\", position = {0, 0}}"), copy.factoriopedia_simulation.init)
    assert(spider.factoriopedia_simulation.init == init)
end)

test("an item copy's page puts the copy on, and only an item's inserts are renamed", function()
    local init = "local character = game.surfaces[1].create_entity{name = \"character\", position = {0.5, 0.5}}\ncharacter.insert{name = \"test-armor\"}\n"
    local armor = {
        type = "armor",
        name = "test-armor",
        factoriopedia_simulation = {
            init = init,
        },
    }
    local copy = dupe.prototype(armor, 3)
    assert(has(copy.factoriopedia_simulation.init, "create_entity{name = \"character\""), "the character stays a character")
    assert(has(copy.factoriopedia_simulation.init, "insert{name = \"test-armor-exfret-3-copy\"}"), copy.factoriopedia_simulation.init)
    -- An entity's inserts are items it was given, not the entity
    local chest = {
        type = "assembling-machine",
        name = "test-box",
        factoriopedia_simulation = {
            init = "local box = game.surfaces[1].create_entity{name = \"test-box\"}\nbox.insert{name = \"test-box\"}",
        },
    }
    local chest_copy = dupe.prototype(chest, 2)
    assert(chest_copy.factoriopedia_simulation.init == "local box = game.surfaces[1].create_entity{name = \"test-box-exfret-2-copy\"}\nbox.insert{name = \"test-box\"}", chest_copy.factoriopedia_simulation.init)
end)

-- Blueprint strings, read and written the way LuaHelpers does: a version character, then the encoded JSON (here a lookup)
local encoded_json = {}
local function blueprint_of(json)
    table.insert(encoded_json, json)
    return "0ENCODED" .. #encoded_json
end
local function install_helpers()
    helpers = {
        decode_string = function(body)
            return encoded_json[tonumber(string.match(body, "^ENCODED(%d+)$"))]
        end,
        encode_string = function(json)
            table.insert(encoded_json, json)
            return "ENCODED" .. #encoded_json
        end,
    }
end
local function wagon_page(blueprint)
    return "game.surfaces[1].create_entities_from_blueprint_string\n{\n  string = \"" .. blueprint .. "\",\n  position = {0, 0}\n}\n"
end

test("a copy built from a blueprint gets a blueprint naming the copy", function()
    install_helpers()
    local blueprint = blueprint_of("{\"blueprint\":{\"entities\":[{\"entity_number\":1,\"name\":\"straight-rail\"},{\"entity_number\":2,\"name\":\"test-wagon\"}]}}")
    local wagon = {
        type = "cargo-wagon",
        name = "test-wagon",
        factoriopedia_simulation = {
            init = wagon_page(blueprint),
        },
    }
    local copy = dupe.prototype(wagon, 2)
    local new_blueprint = string.match(copy.factoriopedia_simulation.init, "string = \"([^\"]+)\"")
    assert(new_blueprint ~= blueprint and string.sub(new_blueprint, 1, 1) == "0", copy.factoriopedia_simulation.init)
    local json = helpers.decode_string(string.sub(new_blueprint, 2))
    assert(has(json, "\"name\":\"test-wagon-exfret-2-copy\"") and has(json, "\"name\":\"straight-rail\"") and not has(json, "\"name\":\"test-wagon\""), json)
    assert(wagon.factoriopedia_simulation.init == wagon_page(blueprint), "the original's blueprint stays")
    helpers = nil
end)

test("a copy whose page can't be pointed at it shows none, and one whose page never showed the original keeps it", function()
    -- Without a way to read the blueprint, it would still show the original
    helpers = nil
    local unreadable = {
        type = "cargo-wagon",
        name = "test-locomotive",
        factoriopedia_simulation = {
            init = wagon_page(blueprint_of("{\"blueprint\":{\"entities\":[{\"name\":\"test-locomotive\"}]}}")),
        },
    }
    assert(dupe.prototype(unreadable, 2).factoriopedia_simulation == nil)
    -- A blueprint of the floor around a building the script makes itself: the building is renamed, the floor left as it was
    install_helpers()
    local floor = blueprint_of("{\"blueprint\":{\"tiles\":[{\"name\":\"space-platform-foundation\"}]}}")
    local crusher = {
        type = "assembling-machine",
        name = "test-crusher",
        factoriopedia_simulation = {
            init = wagon_page(floor) .. "game.surfaces[1].create_entity{name = \"test-crusher\", position = {0, 0}}",
        },
    }
    local crusher_copy = dupe.prototype(crusher, 2)
    assert(has(crusher_copy.factoriopedia_simulation.init, "string = \"" .. floor .. "\""), "an untouched blueprint isn't encoded again")
    assert(has(crusher_copy.factoriopedia_simulation.init, "create_entity{name = \"test-crusher-exfret-2-copy\""))
    helpers = nil
    -- A script file can't be changed
    local from_file = {
        type = "spider-vehicle",
        name = "test-filed",
        factoriopedia_simulation = {
            init_file = "__test__/page.lua",
        },
    }
    assert(dupe.prototype(from_file, 2).factoriopedia_simulation == nil)
end)

test("a resource looks like the item it mines: its icon and its patches", function()
    local resource = {
        type = "resource",
        name = "test-scrap",
        icon = "scrap.png",
        icon_size = 64,
        stages = {
            sheet = {
                filename = "scrap-patches.png",
            },
        },
        stage_counts = {
            1000,
            600,
            400,
        },
        stages_effect = {
            sheet = {
                filename = "glow.png",
            },
        },
    }
    looks.like_item(resource, {
        type = "item",
        name = "test-boiler",
        icon = "boiler.png",
        icon_size = 32,
    })
    assert(resource.icon == "boiler.png" and resource.icon_size == 32 and resource.icons == nil)
    assert(#resource.stages.sheets == 4 and resource.stages.sheets[1].filename == "boiler.png" and resource.stages.sheets[1].size == 32)
    assert(#resource.stage_counts == 1 and resource.stage_counts[1] == 1000 and resource.stages_effect == nil)
    -- An item drawn in layers (like a planet copy's, with its number badge) gives all of them, as its own table
    local layers = {
        {
            icon = "boiler.png",
            icon_size = 64,
        },
        {
            icon = "badge-2.png",
            icon_size = 64,
            scale = 0.25,
        },
    }
    looks.like_item(resource, {
        type = "item",
        name = "test-boiler-exfret-2-copy",
        icons = layers,
    })
    assert(resource.icon == nil and #resource.icons == 2 and resource.icons[2].icon == "badge-2.png" and resource.icons ~= layers)
    assert(resource.stages.sheets[1].filename == "boiler.png")
end)

print(num_passed .. " tests passed")
