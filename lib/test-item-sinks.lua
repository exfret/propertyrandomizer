-- Plain-Lua regression tests for sinks (lib/item-sinks.lua; not loaded by the mod)
-- Run from the mod root: lua lib/test-item-sinks.lua
-- Spoil results need a way machines can use them up on the way to research (user, 2026-09-29), which isn't the same as being useful elsewhere

-- Stand-ins for the Factorio environment
util = {
    parse_energy = function(energy)
        local number, prefix = string.match(energy, "^([%d%.]+)(%a?)[JW]$")
        local scale = { [""] = 1, k = 1e3, M = 1e6, G = 1e9, T = 1e12 }
        return (tonumber(number) or 0) * (scale[prefix] or 1)
    end,
}
defines = {
    prototypes = {
        item = {
            item = 0,
        },
        entity = {},
    },
}

local categories = require("helper-tables/categories")
local dutils = require("lib/data-utils")
local item_sinks = require("lib/item-sinks")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

-- Some crafting machine type, and some entity type whose energy source can be a burner, from the mod's own tables
local machine_type = next(categories.crafting_machines)
local burner_type, burner_props = next(categories.energy_sources_input)
local burner_prop = dutils.tablize(burner_props)[1]

local MACHINE_CATEGORY = "test-machine-category"
local HAND_CATEGORY = "test-hand-category"
local CHEMICAL = item_sinks.CHEMICAL_FUEL_CATEGORY

local function add_item(raw, name, extra)
    local item = {
        type = "item",
        name = name,
    }
    for k, v in pairs(extra or {}) do
        item[k] = v
    end
    raw.item[name] = item
    return item
end

local function material(material_type, name, amount)
    return {
        type = material_type,
        name = name,
        amount = amount or 1,
    }
end

-- A machine recipe unless extra says otherwise
local function add_recipe(raw, name, ingredients, results, extra)
    local recipe = {
        type = "recipe",
        name = name,
        categories = {
            MACHINE_CATEGORY,
        },
        ingredients = ingredients,
        results = results,
    }
    for k, v in pairs(extra or {}) do
        recipe[k] = v
    end
    raw.recipe[name] = recipe
    return recipe
end

local function add_burner(raw, name, energy_source)
    raw[burner_type] = raw[burner_type] or {}
    raw[burner_type][name] = {
        name = name,
        [burner_prop] = energy_source,
    }
end

local function add_machine(raw, name, crafting_categories, num_fluid_boxes)
    local fluid_boxes = {}
    for _ = 1, num_fluid_boxes do
        table.insert(fluid_boxes, {
            production_type = "input",
        })
        table.insert(fluid_boxes, {
            production_type = "output",
        })
    end
    raw[machine_type] = raw[machine_type] or {}
    raw[machine_type][name] = {
        name = name,
        crafting_categories = crafting_categories,
        fluid_boxes = fluid_boxes,
    }
end

-- A game with a lab taking test-pack, a burner naming no fuel categories, and a machine crafting MACHINE_CATEGORY with one fluid box each way
local function new_game()
    local raw = {
        item = {},
        fluid = {},
        recipe = {},
        technology = {},
        lab = {
            ["test-lab"] = {
                name = "test-lab",
                inputs = {
                    "test-pack",
                },
            },
        },
    }
    add_item(raw, "test-pack")
    add_burner(raw, "test-burner", {
        type = "burner",
    })
    add_machine(raw, "test-machine", {
        MACHINE_CATEGORY,
    }, 1)
    return raw
end

local function sinks(raw, old_raw, item_at)
    return item_sinks.sinkable(raw, old_raw or raw, item_at)
end

test("a path ends at a science pack or at chemical fuel, and nothing else ends one", function()
    local raw = new_game()
    add_item(raw, "test-chemical-fuel", {
        fuel_value = "250kJ",
        fuel_categories = {
            CHEMICAL,
        },
    })
    add_item(raw, "test-other-fuel", {
        fuel_value = "1GJ",
        fuel_categories = {
            "test-other-fuel-category",
        },
    })
    add_item(raw, "test-building", {
        place_result = "test-building",
    })
    add_item(raw, "test-launched", {
        rocket_launch_products = {
            material("item", "test-pack"),
        },
    })
    local sinkable = sinks(raw)
    assert(item_sinks.has_sink(sinkable, "test-pack"))
    assert(item_sinks.has_sink(sinkable, "test-chemical-fuel"))
    assert(not item_sinks.has_sink(sinkable, "test-other-fuel"), "only chemical fuel ends a path")
    assert(not item_sinks.has_sink(sinkable, "test-building"), "placing can't be automated")
    assert(not item_sinks.has_sink(sinkable, "test-launched"), "launching for products is hard to automate")
end)

test("chemical fuel ends a path only if a burner can burn it, and one with a burnt result needs a burnt result inventory", function()
    local raw = new_game()
    raw[burner_type]["test-burner"] = nil
    add_item(raw, "test-coal", {
        fuel_value = "4MJ",
        fuel_categories = {
            CHEMICAL,
        },
    })
    add_item(raw, "test-cell", {
        fuel_value = "4MJ",
        fuel_categories = {
            CHEMICAL,
        },
        burnt_result = "test-used-cell",
    })
    assert(not item_sinks.has_sink(sinks(raw), "test-coal"), "nothing burns fuel in a game without burners")

    add_burner(raw, "test-burner", {
        type = "burner",
    })
    assert(item_sinks.has_sink(sinks(raw), "test-coal"))
    assert(not item_sinks.has_sink(sinks(raw), "test-cell"))

    add_burner(raw, "test-burner-with-inventory", {
        type = "burner",
        fuel_categories = {
            CHEMICAL,
        },
        burnt_inventory_size = 1,
    })
    assert(item_sinks.has_sink(sinks(raw), "test-cell"))
end)

test("a recipe some machine can craft is a step, with fluids along the way, but one only the character can craft isn't", function()
    local raw = new_game()
    add_item(raw, "test-ore")
    add_item(raw, "test-hand-only")
    add_item(raw, "test-two-fluids")
    add_recipe(raw, "test-dissolve", {
        material("item", "test-ore"),
    }, {
        material("fluid", "test-solution"),
    })
    add_recipe(raw, "test-research-from-solution", {
        material("fluid", "test-solution"),
    }, {
        material("item", "test-pack"),
    })
    add_recipe(raw, "test-by-hand", {
        material("item", "test-hand-only"),
    }, {
        material("item", "test-pack"),
    }, {
        categories = {
            HAND_CATEGORY,
        },
    })
    -- The machine has one fluid box each way, so it can't take two fluids at once
    add_recipe(raw, "test-two-fluid-inputs", {
        material("item", "test-two-fluids"),
        material("fluid", "test-solution"),
        material("fluid", "test-other-solution"),
    }, {
        material("item", "test-pack"),
    })
    local sinkable = sinks(raw)
    assert(item_sinks.has_sink(sinkable, "test-ore"))
    assert(sinkable["fluid/test-solution"] ~= nil)
    assert(not item_sinks.has_sink(sinkable, "test-hand-only"))
    assert(not item_sinks.has_sink(sinkable, "test-two-fluids"))
end)

test("the recycler's generated recycling isn't a step, even after randomization renames what it recycles, but scrap recycling is", function()
    local old_raw = new_game()
    add_machine(old_raw, "test-recycler", {
        "recycling",
    }, 0)
    add_item(old_raw, "test-junk")
    add_item(old_raw, "test-scrap")
    -- The shape the recycler gives what it generates (recycling.looks_generated)
    add_recipe(old_raw, "test-junk-recycling", {
        material("item", "test-junk"),
    }, {
        material("item", "test-pack"),
    }, {
        categories = {
            "recycling",
        },
        hidden = true,
        unlock_results = false,
    })
    -- Scrap recycling is in the recycling category and can be hand crafted (space-age/prototypes/recipe.lua)
    add_recipe(old_raw, "test-scrap-recycling", {
        material("item", "test-scrap"),
    }, {
        material("item", "test-pack"),
    }, {
        categories = {
            "recycling",
            "hand-crafting",
        },
    })
    local sinkable = sinks(old_raw)
    assert(not item_sinks.has_sink(sinkable, "test-junk"))
    assert(item_sinks.has_sink(sinkable, "test-scrap"))

    -- Randomization renames what a recipe recycles, but not the recipe
    local raw = new_game()
    add_machine(raw, "test-recycler", {
        "recycling",
    }, 0)
    add_item(raw, "test-renamed")
    raw.recipe["test-junk-recycling"] = old_raw.recipe["test-junk-recycling"]
    raw.recipe["test-junk-recycling"].ingredients = {
        material("item", "test-renamed"),
    }
    assert(not item_sinks.has_sink(sinks(raw, old_raw), "test-renamed"))
end)

test("only recipes a player can get are steps: enabled or unlocked by a technology, and not blueprint parameters", function()
    local raw = new_game()
    for _, name in pairs({
        "test-locked",
        "test-researched",
        "test-parameter",
    }) do
        add_item(raw, name)
    end
    add_recipe(raw, "test-locked-recipe", {
        material("item", "test-locked"),
    }, {
        material("item", "test-pack"),
    }, {
        enabled = false,
    })
    add_recipe(raw, "test-researched-recipe", {
        material("item", "test-researched"),
    }, {
        material("item", "test-pack"),
    }, {
        enabled = false,
    })
    raw.technology["test-tech"] = {
        name = "test-tech",
        effects = {
            {
                type = "unlock-recipe",
                recipe = "test-researched-recipe",
            },
        },
    }
    add_recipe(raw, "test-parameter-recipe", {
        material("item", "test-parameter"),
    }, {
        material("item", "test-pack"),
    }, {
        parameter = true,
    })
    local sinkable = sinks(raw)
    assert(not item_sinks.has_sink(sinkable, "test-locked"))
    assert(item_sinks.has_sink(sinkable, "test-researched"))
    assert(not item_sinks.has_sink(sinkable, "test-parameter"))
end)

test("a product that can't come out isn't a step", function()
    local raw = new_game()
    add_item(raw, "test-none")
    add_item(raw, "test-never")
    add_recipe(raw, "test-none-recipe", {
        material("item", "test-none"),
    }, {
        material("item", "test-pack", 0),
    })
    local never = material("item", "test-pack")
    never.independent_probability = 0
    add_recipe(raw, "test-never-recipe", {
        material("item", "test-never"),
    }, {
        never,
    })
    local sinkable = sinks(raw)
    assert(not item_sinks.has_sink(sinkable, "test-none"))
    assert(not item_sinks.has_sink(sinkable, "test-never"))
end)

test("spoiling into something with a sink is a step", function()
    local raw = new_game()
    add_item(raw, "test-rotting", {
        spoil_ticks = 60,
        spoil_result = "test-pack",
    })
    -- ItemPrototype::spoil_result is only loaded with a spoil time above 0
    add_item(raw, "test-not-rotting", {
        spoil_ticks = 0,
        spoil_result = "test-pack",
    })
    local sinkable = sinks(raw)
    assert(item_sinks.has_sink(sinkable, "test-rotting"))
    assert(not item_sinks.has_sink(sinkable, "test-not-rotting"))
end)

test("before reflect, recipes stay with positions, while ending a path and spoiling move with the identity there", function()
    local raw = new_game()
    for _, name in pairs({
        "test-position-a",
        "test-position-b",
        "test-position-c",
        "test-position-d",
        "test-fuel",
    }) do
        add_item(raw, name)
    end
    raw.item["test-fuel"].fuel_value = "250kJ"
    raw.item["test-fuel"].fuel_categories = {
        CHEMICAL,
    }
    raw.item["test-position-d"].spoil_ticks = 60
    raw.item["test-position-d"].spoil_result = "test-pack"
    add_recipe(raw, "test-a-to-b", {
        material("item", "test-position-a"),
    }, {
        material("item", "test-position-b"),
    })
    -- First pass put the science pack at b, the fuel at c, and b's item (which doesn't spoil) at d
    local identity_at = {
        ["test-position-b"] = "test-pack",
        ["test-position-c"] = "test-fuel",
        ["test-position-d"] = "test-position-b",
    }
    local function item_at(position_name)
        return raw.item[identity_at[position_name] or position_name]
    end
    local sinkable = sinks(raw, raw, item_at)
    assert(item_sinks.has_sink(sinkable, "test-position-a"), "a's recipe makes whatever is at b, which labs use up")
    assert(item_sinks.has_sink(sinkable, "test-position-c"))
    assert(not item_sinks.has_sink(sinkable, "test-position-d"), "what spoils moves with the identity")

    local own = sinks(raw)
    assert(not item_sinks.has_sink(own, "test-position-a"))
    assert(item_sinks.has_sink(own, "test-position-d"))
end)

test("the spoiling handler judges new result candidates, its search, and every spoil result in the built game with sinks", function()
    local handle = assert(io.open("randomizations/graph/unified/handlers/spoiling.lua", "r"))
    local text = handle:read("*a")
    handle:close()
    local _, num_sinkable = string.gsub(text, "item_sinks%.sinkable%(data%.raw, old_data_raw", "")
    assert(num_sinkable == 3, "spoof, the search and after_changes should all use item_sinks.sinkable")
    assert(string.find(text, "not item_sinks.has_sink(sinkable, result_name)", 1, true) ~= nil)
end)

print(num_passed .. " tests passed")
