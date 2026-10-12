-- Plain-Lua regression tests for what the recipe-ingredients lists mean (src/randomizations/unified/ingredient-blacklists.lua) and for the fluids no crafting machine can take in (fluid_ports.fluids_crafters_cannot_take), which compat makes the only materials never added as new ingredients (not loaded by the mod)
-- Run from the mod root: lua tests/unit/randomizations/unified/test-ingredient-blacklists.lua

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
mods = {}
defines = {
    prototypes = {
        item = {
            item = 0,
        },
        entity = {},
    },
}
data = {
    raw = {},
}

local gutils = require("src/lib/graph/graph-utils")
local ingredient_blacklists = require("src/randomizations/unified/ingredient-blacklists")
local fluid_ports = require("src/prototypes/entities/fluid-ports")

local key = gutils.key

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local ore = {
    type = "item",
    name = "ore",
}
local plasma = {
    type = "fluid",
    name = "plasma",
}
local ice = {
    type = "item",
    name = "ice",
}
local plate = {
    type = "item",
    name = "plate",
}

-- Ore keeps its spots (kept_pre), plasma never is an ingredient anywhere new (blacklisted_pre), melting keeps its ingredients and they count (kept_dep), recycling keeps its and they don't (blacklisted_dep)
local function rules()
    return ingredient_blacklists.of({
        blacklisted_pre = {
            [key("fluid", "plasma")] = true,
        },
        kept_pre = {
            [key("item", "ore")] = true,
        },
        blacklisted_dep = {
            [key("recipe", "recycling")] = true,
        },
        kept_dep = {
            [key("recipe", "melting")] = true,
        },
    })
end

test("an ore keeps its spots but recipes may still take it as a new ingredient (user, 2026-10-07)", function()
    local r = rules()
    assert(r.keeps_spots(ore))
    assert(r.may_add(ore))
end)

test("a material no crafting machine can take keeps its spots and is never a new ingredient", function()
    local r = rules()
    assert(r.keeps_spots(plasma))
    assert(not r.may_add(plasma))
end)

test("any other material moves and is a new ingredient as usual", function()
    local r = rules()
    assert(not r.keeps_spots(plate))
    assert(r.may_add(plate))
end)

test("both kinds of kept recipes keep their ingredients, but only kept_dep's count as uses", function()
    local r = rules()
    assert(r.keeps_ingredients("melting") and r.keeps_ingredients("recycling"))
    assert(not r.keeps_ingredients("smelting"))
    assert(r.counts_uses("melting") and r.counts_uses("smelting"))
    assert(not r.counts_uses("recycling"))
end)

test("a kept use is an ore's spot anywhere that counts, or any material's spot in a kept recipe", function()
    local r = rules()
    assert(r.kept_use(ore, "smelting"))
    assert(r.kept_use(ice, "melting"))
    -- A randomized spot isn't kept, so its own claimed edge gives its entries
    assert(not r.kept_use(plate, "smelting"))
    -- Recycling's uses never count, not even an ore's
    assert(not r.kept_use(ore, "recycling"))
    -- Plasma is never offered, kept recipe or not
    assert(not r.kept_use(plasma, "melting"))
end)

test("the kept recipes are listed once each, sorted", function()
    local r = ingredient_blacklists.of({
        blacklisted_dep = {
            [key("recipe", "b")] = true,
        },
        kept_dep = {
            [key("recipe", "a")] = true,
            [key("recipe", "b")] = true,
        },
    })
    local recipe_keys = r.kept_recipe_keys()
    assert(#recipe_keys == 2 and recipe_keys[1] == key("recipe", "a") and recipe_keys[2] == key("recipe", "b"))
end)

test("missing lists mean nothing is kept or blocked", function()
    local r = ingredient_blacklists.of({})
    assert(not r.keeps_spots(ore) and r.may_add(ore))
    assert(not r.keeps_ingredients("melting") and r.counts_uses("melting"))
end)

-- A tiny game for fluids_crafters_cannot_take: a crafting machine taking and making fluids through default connections, a pipe, a pump on water tiles, a pumpjack on crude oil, a boiler making steam, a reactor making plasma into connections only its generator shares (like Space Age's fusion reactor), and the editor's infinity pipe joining both, but hidden
local function connection(category)
    return {
        direction = 0,
        position = { 0, 0 },
        connection_category = category,
    }
end
local function box(production_type, filter, category)
    return {
        volume = 100,
        production_type = production_type,
        filter = filter,
        pipe_connections = { connection(category) },
    }
end
local function set_game()
    defines.prototypes.entity = {
        ["assembling-machine"] = 0,
        boiler = 0,
        ["fusion-generator"] = 0,
        ["fusion-reactor"] = 0,
        ["infinity-pipe"] = 0,
        ["mining-drill"] = 0,
        ["offshore-pump"] = 0,
        pipe = 0,
    }
    data.raw = {
        ["assembling-machine"] = {
            machine = {
                name = "machine",
                fluid_boxes = {
                    box("input"),
                    box("output"),
                },
            },
        },
        pipe = {
            pipe = {
                name = "pipe",
                fluid_box = box(nil),
            },
        },
        ["infinity-pipe"] = {
            ["infinity-pipe"] = {
                name = "infinity-pipe",
                hidden = true,
                fluid_box = box(nil, nil, {
                    "default",
                    "fusion",
                }),
            },
        },
        ["offshore-pump"] = {
            pump = {
                name = "pump",
                fluid_box = box("output"),
            },
        },
        ["mining-drill"] = {
            pumpjack = {
                name = "pumpjack",
                resource_categories = { "basic-fluid" },
                output_fluid_box = box("output"),
            },
        },
        boiler = {
            boiler = {
                name = "boiler",
                fluid_box = box("input-output", "water"),
                output_fluid_box = box("output", "steam"),
            },
        },
        ["fusion-reactor"] = {
            reactor = {
                name = "reactor",
                input_fluid_box = box("input", "coolant"),
                output_fluid_box = box("output", "plasma", { "fusion" }),
            },
        },
        ["fusion-generator"] = {
            generator = {
                name = "generator",
                input_fluid_box = box("input", "plasma", { "fusion" }),
                output_fluid_box = box("output", "hot-coolant"),
            },
        },
        tile = {
            water = {
                name = "water",
                fluid = "water",
            },
        },
        resource = {
            ["crude-oil"] = {
                name = "crude-oil",
                category = "basic-fluid",
                minable = {
                    mining_time = 1,
                    results = {
                        {
                            type = "fluid",
                            name = "crude-oil",
                            amount = 10,
                        },
                    },
                },
            },
        },
        recipe = {
            ["coolant"] = {
                name = "coolant",
                results = {
                    {
                        type = "fluid",
                        name = "coolant",
                        amount = 10,
                    },
                },
            },
        },
        fluid = {},
    }
    for _, name in pairs({
        "coolant",
        "crude-oil",
        "hot-coolant",
        "orphan",
        "plasma",
        "steam",
        "water",
    }) do
        data.raw.fluid[name] = {
            name = name,
        }
    end
end

local function cannot_take()
    local names = {}
    for _, name in pairs(fluid_ports.fluids_crafters_cannot_take()) do
        names[name] = true
    end
    return names
end

test("only what's made into connections crafting machines' inputs can't reach is never an ingredient: plasma, and a fluid nothing makes", function()
    set_game()
    local names = cannot_take()
    assert(names.plasma ~= nil)
    assert(names.orphan ~= nil)
    for _, name in pairs({
        "coolant",
        "crude-oil",
        "hot-coolant",
        "steam",
        "water",
    }) do
        assert(names[name] == nil, name .. " should reach crafting machines")
    end
end)

test("a pipe players can build joining both categories carries plasma to crafting machines", function()
    set_game()
    data.raw["infinity-pipe"]["infinity-pipe"].hidden = nil
    assert(cannot_take().plasma == nil)
end)

test("a box that only passes on another fluid joins nothing for plasma", function()
    set_game()
    data.raw.boiler.boiler.fluid_box = box("input-output", "water", {
        "default",
        "fusion",
    })
    assert(cannot_take().plasma ~= nil)
    assert(cannot_take().water == nil)
end)

print(num_passed .. " tests passed")
