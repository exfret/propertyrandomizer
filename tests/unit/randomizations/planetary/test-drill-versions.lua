-- Plain-Lua regression tests for drills that follow an ore (lock_repairs.drill_versions in src/randomizations/planetary/lock-repairs.lua), not loaded by the mod
-- Run from the mod root: lua tests/unit/randomizations/planetary/test-drill-versions.lua
-- User, 2026-10-13: the resource swap put tungsten ore on a Nauvis copy, whose own recipes then failed even with every extra patch, since only the big mining drill mines it, and that's made in a foundry on Vulcanus
-- A failing planet that can't mine an ore it got gets its own version of a drill that mines it, made there from its own resources and crafted in a machine it has
--
-- The toy game: V and its copy V2 make the big drill (in a foundry, from carbide and molten metal only V's family makes), and N2, a copy of N, got hard ore, which only the big drill mines
-- N2 makes circuits, steel and oil itself, and has an assembler crafting with one fluid

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
config = {}
settings = {
    startup = {},
}
mods = {}
defines = {
    prototypes = {
        item = {
            item = true,
        },
        entity = {
            ["assembling-machine"] = true,
            ["mining-drill"] = true,
        },
    },
}
lookups = {
    rooms = {},
}

local function amount_of(kind, name, amount)
    return {
        type = kind,
        name = name,
        amount = amount,
    }
end

-- Locked to the rooms with this surface property
local function locked_to(property)
    return {
        {
            property = property,
            min = 1,
        },
    }
end

local function recipe(name, category, ingredients, result, surface_conditions)
    return {
        type = "recipe",
        name = name,
        categories = {
            category,
        },
        surface_conditions = surface_conditions,
        ingredients = ingredients,
        results = {
            result,
        },
    }
end

local function planet(name, properties, orig_name, dupe_number)
    lookups.rooms["planet: " .. name] = {
        type = "planet",
        name = name,
    }
    return {
        type = "planet",
        name = name,
        surface_properties = properties,
        orig_name = orig_name,
        dupe_number = dupe_number,
    }
end

local function fresh_data()
    lookups.rooms = {}
    data = {
        extend = function(self, prototypes)
            for _, prototype in pairs(prototypes) do
                self.raw[prototype.type] = self.raw[prototype.type] or {}
                self.raw[prototype.type][prototype.name] = prototype
            end
        end,
        raw = {
            planet = {
                V = planet("V", {
                    v1 = 1,
                }),
                V2 = planet("V2", {
                    v2 = 1,
                }, "V", 2),
                N = planet("N", {}),
                N2 = planet("N2", {}, "N", 2),
            },
            ["surface-property"] = {
                v1 = {
                    default_value = 0,
                },
                v2 = {
                    default_value = 0,
                },
            },
            resource = {
                ["hard-ore"] = {
                    type = "resource",
                    name = "hard-ore",
                    category = "hard",
                    minable = {
                        results = {
                            amount_of("item", "hard-ore", 1),
                        },
                    },
                },
            },
            item = {
                ["big-drill"] = {
                    type = "item",
                    name = "big-drill",
                    place_result = "big-drill",
                },
                drill = {
                    type = "item",
                    name = "drill",
                    place_result = "drill",
                },
                steel = {
                    type = "item",
                    name = "steel",
                },
                carbide = {
                    type = "item",
                    name = "carbide",
                },
                circuit = {
                    type = "item",
                    name = "circuit",
                },
            },
            ["mining-drill"] = {
                ["big-drill"] = {
                    type = "mining-drill",
                    name = "big-drill",
                    resource_categories = {
                        "basic",
                        "hard",
                    },
                },
                drill = {
                    type = "mining-drill",
                    name = "drill",
                    resource_categories = {
                        "basic",
                    },
                },
            },
            ["assembling-machine"] = {
                foundry = {
                    type = "assembling-machine",
                    name = "foundry",
                    crafting_categories = {
                        "metallurgy",
                    },
                },
                assembler = {
                    type = "assembling-machine",
                    name = "assembler",
                    crafting_categories = {
                        "crafting",
                        "crafting-with-fluid",
                    },
                },
                silo = {
                    type = "assembling-machine",
                    name = "silo",
                    crafting_categories = {
                        "rocket-building",
                    },
                    fixed_recipe = "rocket-part",
                },
            },
            recipe = {
                ["big-drill"] = recipe("big-drill", "metallurgy", {
                    amount_of("item", "carbide", 20),
                    amount_of("fluid", "molten", 200),
                    amount_of("item", "circuit", 10),
                }, amount_of("item", "big-drill", 1), locked_to("v1")),
                -- Its duplicate for V's copy 2 (src/prototypes/duplicates)
                ["big-drill-2"] = recipe("big-drill-2", "metallurgy", {
                    amount_of("item", "carbide", 20),
                    amount_of("fluid", "molten", 200),
                    amount_of("item", "circuit", 10),
                }, amount_of("item", "big-drill", 1), locked_to("v2")),
                drill = recipe("drill", "crafting", {
                    amount_of("item", "circuit", 3),
                }, amount_of("item", "drill", 1)),
            },
            technology = {
                ["big-drill-tech"] = {
                    type = "technology",
                    name = "big-drill-tech",
                    effects = {
                        {
                            type = "unlock-recipe",
                            recipe = "big-drill",
                        },
                    },
                },
                ["big-drill-tech-2"] = {
                    type = "technology",
                    name = "big-drill-tech-2",
                    effects = {
                        {
                            type = "unlock-recipe",
                            recipe = "big-drill-2",
                        },
                    },
                },
            },
            furnace = {},
            lab = {},
        },
    }
end
fresh_data()

local fixed = {}
package.loaded["src/randomizations/planetary/locks"] = {
    moved = {},
    fixed = fixed,
    fix = function(kind, name, rooms)
        fixed[kind .. "/" .. name] = rooms
    end,
    unfix = function(kind, name)
        fixed[kind .. "/" .. name] = nil
    end,
    realize = function() end,
}
package.loaded["src/randomizations/planetary/scaffolds"] = {
    planet_variant_name = function(base, planet_name)
        return "propertyrandomizer-" .. base .. "-on-" .. planet_name
    end,
    name_variant = function(variant, recipe, planet_name)
        variant.localised_name = {
            "",
            recipe.name,
            planet_name,
        }
    end,
    badged_icons = function(recipe, planet_name)
        return nil
    end,
}
package.loaded["src/lib/random/rng"] = {
    int = function(_, max)
        return 1
    end,
}
package.loaded["src/logic/init"] = {
    contexts = {},
    type_info = {},
}
package.loaded["src/logic/state"] = package.loaded["src/logic/init"]
package.loaded["src/prototypes/recipes/recycling"] = {
    looks_generated = function(recipe)
        return false
    end,
}

local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")
local lutils = require("src/logic/logic-utils")
-- Contexts are numbers (src/logic/contexts/contexts.lua); the fixtures write them as their names (tests/unit/logic/contexts/contexts-for-tests.lua)
local fx = require("tests/unit/logic/contexts/contexts-for-tests")

-- The earliest index of a context in the rooms, as rewards' depth_of measures it (without its room rank)
local function depth_of(sort, node_key, rooms)
    local best
    for context, ind in pairs(sort.sort_info.node_to_context_inds[node_key] or {}) do
        if rooms[top.context_room(context)] ~= nil and (best == nil or ind < best) then
            best = ind
        end
    end
    return best
end
package.loaded["src/randomizations/planetary/rewards"] = {
    helpers = {
        families = function()
            return {}
        end,
        family_of = function(room_key)
            return room_key
        end,
        specific_to_rooms = function()
            return false
        end,
        depth_of = depth_of,
        path_avoids = function()
            return true
        end,
        trigger_candidates = function(kind)
            local candidates = {}
            local names = kind == "craft-fluid" and {
                "molten",
                "oil",
            } or {
                "carbide",
                "circuit",
                "steel",
            }
            for _, name in pairs(names) do
                table.insert(candidates, {
                    name = name,
                    node_key = gutils.key(kind == "craft-fluid" and "fluid" or "item", name),
                })
            end
            return candidates
        end,
        discoverers = function()
            return {}
        end,
        -- Research can be triggered by crafting any item of the toy game
        trigger_options = function(kind)
            local options = {}
            if kind == "craft-item" then
                for _, name in pairs({
                    "carbide",
                    "circuit",
                    "steel",
                }) do
                    table.insert(options, {
                        name = name,
                        source_key = gutils.key("item-craft", name),
                    })
                end
            end
            return options
        end,
        met_by_own_recipe = function()
            return true
        end,
        trigger_text = function(trigger)
            return trigger.type .. " " .. tostring(trigger.item or trigger.entity)
        end,
    },
    trigger_source_keys = function(trigger)
        if trigger.type == "craft-item" then
            return {
                gutils.key("item-craft", trigger.item),
            }
        end
        return {}
    end,
    bundle_of_lock = function(id)
        return nil
    end,
}

local lock_repairs = require("src/randomizations/planetary/lock-repairs")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function with_fluids(categories, input)
    return gutils.key("recipe-category", lutils.rcat_key(categories, {
        input = input,
        output = 0,
    }))
end

-- The sort of the toy game: V's family makes carbide and molten metal and crafts metallurgy, N2 makes circuits, steel and oil and crafts with one fluid in its assembler, and only V mines hard ore
-- n2_mines: whether N2 mines hard ore itself (a drill it builds already mines it); add_more (optional) gets the function adding a node, to add more
local function toy_sort(n2_mines, add_more)
    local contexts = {}
    local nodes = {}
    local function at(node_key, context_names)
        nodes[node_key] = {
            name = node_key,
        }
        contexts[node_key] = {}
        for i, name in pairs(context_names) do
            contexts[node_key][fx.C(name)] = i * 10
        end
    end
    local hard_mining = gutils.key("resource-category", lutils.mcat_name(data.raw.resource["hard-ore"]))
    at(hard_mining, n2_mines and {
        "planet: V | 11",
        "planet: N2 | 11",
    } or {
        "planet: V | 11",
    })
    at(gutils.key("item", "carbide"), {
        "planet: V | 11",
        "planet: V2 | 11",
    })
    at(gutils.key("fluid", "molten"), {
        "planet: V | 11",
        "planet: V2 | 11",
    })
    -- Stand-ins are the closest in depth to what they replace at home (carbide at 20 on V2): steel at 20 on N2, circuits at 30
    at(gutils.key("item", "circuit"), {
        "planet: V | 11",
        "planet: V2 | 11",
        "planet: N2 | 11",
    })
    at(gutils.key("item", "steel"), {
        "planet: V | 11",
        "planet: N2 | 11",
    })
    at(gutils.key("fluid", "oil"), {
        "planet: N2 | 11",
    })
    at(with_fluids({ "metallurgy" }, 1), {
        "planet: V | 11",
        "planet: V2 | 11",
    })
    at(with_fluids({ "crafting-with-fluid" }, 1), {
        "planet: V | 11",
        "planet: N2 | 11",
    })
    -- The duplicate's research is doable on N2 (the original's isn't)
    at(gutils.key("technology", "big-drill-tech-2"), {
        "planet: V2 | 11",
        "planet: N2 | 11",
    })
    at(gutils.key("technology", "big-drill-tech"), {
        "planet: V | 11",
    })
    if add_more ~= nil then
        add_more(at)
    end
    return {
        graph = {
            nodes = nodes,
            edges = {},
        },
        sort_info = {
            node_to_context_inds = contexts,
        },
    }
end

local VERSION = "propertyrandomizer-big-drill-2-on-N2"

test("a planet that can't mine an ore it got gets its own version of the drill with its copy number", function()
    local state = {
        variants_of = {},
    }
    local made = lock_repairs.drill_versions(toy_sort(false), {
        N2 = {
            "hard-ore",
        },
    }, state)
    assert(#made == 1, "N2 gets one drill version, not " .. #made)
    assert(made[1].variant_name == VERSION, "the duplicate for copy 2 is the one followed: " .. tostring(made[1].variant_name))
    assert(made[1].planet_name == "N2" and made[1].ore_name == "hard-ore", "the version says which planet and ore it's for")
    local version = data.raw.recipe[VERSION]
    assert(version ~= nil, "the version is in the game")
    assert(fixed["recipe/" .. VERSION]["planet: N2"] and next(fixed["recipe/" .. VERSION], next(fixed["recipe/" .. VERSION])) == nil, "it's locked to N2 alone")
    assert(state.variants_of["big-drill-2"][1] == VERSION, "it counts as the drill's recipe for the planetary check")
end)

test("the version takes stand-ins N2 makes itself and is crafted in a machine N2 has", function()
    local version = data.raw.recipe[VERSION]
    local names = {}
    for _, ingredient in pairs(version.ingredients) do
        names[ingredient.type .. ":" .. ingredient.name] = ingredient.amount
    end
    assert(names["item:carbide"] == nil and names["fluid:molten"] == nil, "nothing only V's family makes is left")
    assert(names["item:steel"] == 20 and names["fluid:oil"] == 200, "carbide and molten metal are swapped for steel and oil, the same amounts")
    assert(names["item:circuit"] == 10, "N2 makes circuits itself, so they stay")
    assert(#version.categories == 1 and version.categories[1] == "crafting-with-fluid", "made in the assembler's fluid category instead of metallurgy: " .. table.concat(version.categories, ", "))
    local unlocked = false
    for _, effect in pairs(data.raw.technology["big-drill-tech-2"].effects) do
        if effect.recipe == VERSION then
            unlocked = true
        end
    end
    assert(unlocked, "unlocked by the duplicate's research, which N2 can do")
    assert(data.raw.recipe["big-drill-2"].categories[1] == "metallurgy", "the drill's own recipe doesn't change")
end)

test("taking drill versions back removes them, their locks and their unlocks", function()
    local state = {
        variants_of = {
            ["big-drill-2"] = {
                VERSION,
            },
        },
    }
    lock_repairs.remove_local_versions({
        {
            recipe_name = "big-drill-2",
            variant_name = VERSION,
            room_key = "planet: N2",
        },
    }, state)
    assert(data.raw.recipe[VERSION] == nil, "the version is gone")
    assert(fixed["recipe/" .. VERSION] == nil, "its lock is gone")
    for _, effect in pairs(data.raw.technology["big-drill-tech-2"].effects) do
        assert(effect.recipe == "big-drill-2", "only the drill's own unlock is left")
    end
    assert(state.variants_of["big-drill-2"] == nil, "it no longer counts as the drill's recipe")
end)

test("a planet that mines the ore itself already gets no drill", function()
    fresh_data()
    local state = {
        variants_of = {},
    }
    local made = lock_repairs.drill_versions(toy_sort(true), {
        N2 = {
            "hard-ore",
        },
    }, state)
    assert(#made == 0 and data.raw.recipe[VERSION] == nil, "N2 mines hard ore itself, so nothing is made")
end)

test("a drill whose own category the planet crafts keeps it", function()
    fresh_data()
    -- The drill's duplicate is made in the assembler now, from what N2 makes
    data.raw.recipe["big-drill-2"] = recipe("big-drill-2", "crafting-with-fluid", {
        amount_of("item", "circuit", 10),
        amount_of("fluid", "oil", 50),
    }, amount_of("item", "big-drill", 1), locked_to("v2"))
    local state = {
        variants_of = {},
    }
    local made = lock_repairs.drill_versions(toy_sort(false), {
        N2 = {
            "hard-ore",
        },
    }, state)
    assert(#made == 1, "its lock still leaves N2 out, so N2 gets a version all the same")
    local version = data.raw.recipe[VERSION]
    assert(version.categories[1] == "crafting-with-fluid", "the version keeps the drill's own category")
    for _, note in pairs(made[1].notes) do
        assert(string.find(note, "made in", 1, true) == nil, "nothing to say about its category: " .. note)
    end
    assert(version.ingredients[1].name == "circuit" and version.ingredients[2].name == "oil", "and its ingredients, which N2 makes")
end)

test("a category only a machine with a fixed recipe crafts is never picked", function()
    fresh_data()
    local state = {
        variants_of = {},
    }
    -- N2 has a rocket silo crafting with one fluid earlier than its assembler, but a silo only crafts its own rocket parts
    lock_repairs.drill_versions(toy_sort(false, function(at)
        at(with_fluids({ "rocket-building" }, 1), {
            "planet: N2 | 11",
        })
    end), {
        N2 = {
            "hard-ore",
        },
    }, state)
    local version = data.raw.recipe[VERSION]
    assert(version ~= nil and version.categories[1] == "crafting-with-fluid", "the version is made in the assembler, not the silo: " .. tostring(version and version.categories[1]))
end)

-- Packages (user, 2026-10-13: "if there's an ore on a planet and a drill you unlock just to mine that ore, package them and move them together")

-- A swap's slots (resources.slots), assignment and origins (resources.random_assignment): V's hard ore goes to N2 and V2's to N, crossing copy numbers, and both get stone back
local function swap()
    data.raw.resource.stone = {
        type = "resource",
        name = "stone",
        category = "basic",
        minable = {
            results = {
                amount_of("item", "stone", 1),
            },
        },
    }
    local function slot(planet_name, resource_name)
        return {
            planet_name = planet_name,
            resource_name = resource_name,
            kind = "ore",
        }
    end
    local slots = {
        slot("V", "hard-ore"),
        slot("V2", "hard-ore"),
        slot("N2", "stone"),
        slot("N", "stone"),
    }
    return slots, {
        "stone",
        "stone",
        "hard-ore",
        "hard-ore",
    }, {
        3,
        4,
        1,
        2,
    }
end

test("an ore only planet-locked drills mine is packaged with them, and one an unlocked drill mines isn't", function()
    fresh_data()
    swap()
    local packages = lock_repairs.ore_drills()
    assert(#packages == 1 and packages[1].category == "hard", "only hard ore is packaged: " .. #packages)
    local names = {}
    for _, recipe in pairs(packages[1].recipes) do
        table.insert(names, recipe.name)
    end
    assert(table.concat(names, ",") == "big-drill,big-drill-2", "with both big drill recipes: " .. table.concat(names, ","))
end)

test("each drill follows the ore from its own planet, whatever the copy numbers", function()
    fresh_data()
    local slots, assignment, origins = swap()
    local moves = lock_repairs.drill_moves(lock_repairs.ore_drills(), slots, assignment, origins)
    assert(#moves == 2, "both drills move: " .. #moves)
    local by_recipe = {}
    for _, move in pairs(moves) do
        by_recipe[move.recipe_name] = move
    end
    local function only(rooms, room_key)
        return rooms[room_key] ~= nil and next(rooms, next(rooms)) == nil
    end
    assert(only(by_recipe["big-drill"].rooms, "planet: N2") and by_recipe["big-drill"].map["planet: V"] == "planet: N2", "V's drill goes where V's ore went, N2, a copy 2")
    assert(only(by_recipe["big-drill-2"].rooms, "planet: N") and by_recipe["big-drill-2"].map["planet: V2"] == "planet: N", "V2's drill goes to N, a copy 1")
end)

test("a drill whose ore stayed stays, and so does one on a planet that never had the ore", function()
    fresh_data()
    local slots = swap()
    -- Nothing moved: each slot's resource is its own
    local moves = lock_repairs.drill_moves(lock_repairs.ore_drills(), slots, {
        "hard-ore",
        "hard-ore",
        "stone",
        "stone",
    }, {
        1,
        2,
        3,
        4,
    })
    assert(#moves == 0, "no drill moves when no ore did: " .. #moves)
    -- V never had the ore: its drill stays even though V2's ore leaves
    slots[1].resource_name = "stone"
    moves = lock_repairs.drill_moves(lock_repairs.ore_drills(), slots, {
        "stone",
        "stone",
        "hard-ore",
        "stone",
    }, {
        1,
        4,
        2,
        3,
    })
    assert(#moves == 1 and moves[1].recipe_name == "big-drill-2", "only V2's drill moves")
end)

test("a moved drill's own recipe is made on its new planet in place, and the undo puts it back", function()
    fresh_data()
    local recipe = data.raw.recipe["big-drill-2"]
    local repair = lock_repairs.local_in_place(toy_sort(false), recipe, "planet: N2", {
        ["planet: V2"] = true,
    })
    assert(repair ~= nil and repair.in_place, "the recipe itself is changed, no version")
    assert(data.raw.recipe[VERSION] == nil, "no second recipe")
    local names = {}
    for _, ingredient in pairs(recipe.ingredients) do
        names[ingredient.type .. ":" .. ingredient.name] = ingredient.amount
    end
    assert(names["item:steel"] == 20 and names["fluid:oil"] == 200 and names["item:circuit"] == 10, "stand-ins N2 makes itself")
    assert(recipe.categories[1] == "crafting-with-fluid", "made in N2's assembler")
    assert(repair.tech_name == nil and repair.copy_name == nil, "its own research is doable on N2, so nothing is added")
    lock_repairs.undo_in_place(repair)
    assert(recipe.categories[1] == "metallurgy" and recipe.ingredients[1].name == "carbide", "the undo puts its ingredients and category back")
end)

test("a drill that stays on its old planet too gets a version on its new one instead", function()
    fresh_data()
    local state = {
        variants_of = {},
    }
    local moves = {
        {
            recipe_name = "big-drill-2",
            category = "hard",
            old = {
                ["planet: V2"] = true,
            },
            rooms = {
                ["planet: V2"] = true,
                ["planet: N2"] = true,
            },
            map = {},
        },
    }
    local failed = lock_repairs.make_drills_local(toy_sort(false), moves, state)
    assert(#failed == 0, "it can be made on N2")
    assert(data.raw.recipe[VERSION] ~= nil and data.raw.recipe["big-drill-2"].categories[1] == "metallurgy", "N2 gets a version, and V2's recipe is left as it was")
    assert(state.variants_of["big-drill-2"][1] == VERSION, "the version counts as the drill's recipe")
    lock_repairs.undo_drill_local(moves[1], state)
    assert(data.raw.recipe[VERSION] == nil and state.variants_of["big-drill-2"] == nil, "and goes again with the undo")
end)

test("research triggered by crafting a drill that left gets a trigger its old planet meets, and the undo puts it back", function()
    fresh_data()
    -- Like Tungsten steel, researched by crafting a big mining drill; its copy 2 belongs to the copy 2 drill
    data.raw.technology["steel-tech"] = {
        type = "technology",
        name = "steel-tech",
        research_trigger = {
            type = "craft-item",
            item = "big-drill",
        },
    }
    data.raw.technology["steel-tech-2"] = {
        type = "technology",
        name = "steel-tech-2",
        dupe_number = 2,
        research_trigger = {
            type = "craft-item",
            item = "big-drill",
        },
    }
    -- With the drill gone, V crafts carbide itself; before, it crafted the drill
    local after = toy_sort(false, function(at)
        at(gutils.key("item-craft", "carbide"), {
            "planet: V | 11",
        })
    end)
    local before = toy_sort(false, function(at)
        at(gutils.key("item-craft", "big-drill"), {
            "planet: V | 11",
        })
    end)
    local move = {
        recipe_name = "big-drill",
        category = "hard",
        old = {
            ["planet: V"] = true,
        },
        rooms = {
            ["planet: N2"] = true,
        },
        map = {
            ["planet: V"] = "planet: N2",
        },
    }
    local stuck = lock_repairs.retrigger_drill_research(after, before, {
        move,
    })
    assert(#stuck == 0, "V meets another trigger")
    assert(#move.retriggered == 1 and move.retriggered[1].tech_name == "steel-tech", "only the research of the drill's own tree changes")
    local trigger = data.raw.technology["steel-tech"].research_trigger
    assert(trigger.type == "craft-item" and trigger.item == "carbide", "it's researched by crafting what V makes now: " .. tostring(trigger.item))
    assert(data.raw.technology["steel-tech-2"].research_trigger.item == "big-drill", "copy 2's research belongs to the copy 2 drill, which didn't move")
    lock_repairs.undo_retrigger(move)
    assert(data.raw.technology["steel-tech"].research_trigger.item == "big-drill", "the undo puts the drill back as its trigger")
end)

print(num_passed .. " tests passed")
