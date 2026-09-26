-- Plain-Lua regression tests for randomizations/graph/entity/common.lua (not loaded by the mod)
-- Run from the mod root: lua randomizations/graph/entity/test-common.lua

-- Stand-ins for the Factorio data stage environment
defines = {
    prototypes = {
        entity = {
            ["transport-belt"] = 0,
            ["locomotive"] = 0,
        },
        item = {
            ["item"] = 0,
        },
    },
}
data = {
    raw = {},
}
-- Factorio adds table.deepcopy (core's util.lua); prototype data has no metatables or cycles, so a plain copy does
table.deepcopy = function(object)
    if type(object) ~= "table" then
        return object
    end
    local copy = {}
    for k, v in pairs(object) do
        copy[k] = table.deepcopy(v)
    end
    return copy
end
-- Every stand-in entity without a collision_mask collides on the same single layer
package.loaded["__core__/lualib/collision-mask-util"] = {
    get_mask = function(prototype)
        return prototype.collision_mask or {
            layers = {
                object = true,
            },
        }
    end,
    masks_are_same = function(mask1, mask2)
        for layer, _ in pairs(mask1.layers) do
            if mask2.layers[layer] == nil then
                return false
            end
        end
        for layer, _ in pairs(mask2.layers) do
            if mask1.layers[layer] == nil then
                return false
            end
        end
        return true
    end,
}

local common = require("randomizations/graph/entity/common")

-- Two belts where yellow-belt upgrades to red-belt, each built by an item of the same name
local function reset_data()
    data.raw = {
        ["transport-belt"] = {
            ["yellow-belt"] = {
                type = "transport-belt",
                name = "yellow-belt",
                collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
                fast_replaceable_group = "transport-belt",
                minable = {
                    mining_time = 0.1,
                    result = "yellow-belt",
                },
                next_upgrade = "red-belt",
            },
            ["red-belt"] = {
                type = "transport-belt",
                name = "red-belt",
                collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
                fast_replaceable_group = "transport-belt",
                minable = {
                    mining_time = 0.1,
                    result = "red-belt",
                },
            },
        },
        item = {
            ["yellow-belt"] = {
                type = "item",
                name = "yellow-belt",
                place_result = "yellow-belt",
            },
            ["red-belt"] = {
                type = "item",
                name = "red-belt",
                place_result = "red-belt",
            },
        },
    }
end

local function yellow()
    return data.raw["transport-belt"]["yellow-belt"]
end

local function red()
    return data.raw["transport-belt"]["red-belt"]
end

local num_passed = 0
local function test(name, fn)
    reset_data()
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

test("valid upgrade passes", function()
    assert(common.next_upgrade_problem(yellow()) == nil)
end)

test("entity without next_upgrade passes", function()
    assert(common.next_upgrade_problem(red()) == nil)
end)

test("not-upgradable flag fails", function()
    yellow().flags = {
        "not-upgradable",
    }
    assert(common.next_upgrade_problem(yellow()) == "entity has the not-upgradable flag")
end)

test("unminable entity fails", function()
    yellow().minable = nil
    assert(common.next_upgrade_problem(yellow()) == "entity isn't minable")
end)

test("entity mining into a hidden item fails", function()
    data.raw.item["belt-scrap"] = {
        type = "item",
        name = "belt-scrap",
        hidden = true,
    }
    yellow().minable = {
        mining_time = 0.1,
        results = {
            {
                type = "item",
                name = "belt-scrap",
                amount = 1,
            },
        },
    }
    assert(common.next_upgrade_problem(yellow()) == "entity mines into a hidden item")
end)

test("rolling stock fails", function()
    yellow().type = "locomotive"
    assert(common.next_upgrade_problem(yellow()) == "entity is rolling stock")
end)

test("missing target fails", function()
    yellow().next_upgrade = "blue-belt"
    assert(common.next_upgrade_problem(yellow()) == "upgrade target blue-belt doesn't exist")
end)

test("target with a different collision box fails", function()
    red().collision_box = {{-0.5, -0.5}, {0.5, 0.5}}
    assert(common.next_upgrade_problem(yellow()) == "upgrade target has a different collision box")
end)

test("same collision box written with named entries passes", function()
    red().collision_box = {
        left_top = {
            x = -0.4,
            y = -0.4,
        },
        right_bottom = {
            x = 0.4,
            y = 0.4,
        },
    }
    assert(common.next_upgrade_problem(yellow()) == nil)
end)

test("target with different collision mask layers fails", function()
    red().collision_mask = {
        layers = {
            object = true,
            water_tile = true,
        },
    }
    assert(common.next_upgrade_problem(yellow()) == "upgrade target has a different collision mask")
end)

test("target with a different collision mask flag fails", function()
    red().collision_mask = {
        layers = {
            object = true,
        },
        not_colliding_with_itself = true,
    }
    assert(common.next_upgrade_problem(yellow()) == "upgrade target has a different collision mask")
end)

test("target with a different fast replaceable group fails", function()
    red().fast_replaceable_group = "red-things"
    assert(common.next_upgrade_problem(yellow()) == "upgrade target has a different fast replaceable group")
end)

test("target no item builds fails", function()
    -- This is what item placement randomization can cause
    data.raw.item["red-belt"].place_result = "yellow-belt"
    assert(common.next_upgrade_problem(yellow()) == "no non-hidden item builds the upgrade target")
end)

test("target only a hidden item builds fails", function()
    data.raw.item["red-belt"].hidden = true
    assert(common.next_upgrade_problem(yellow()) == "no non-hidden item builds the upgrade target")
end)

test("target built through a single placeable_by entry passes", function()
    data.raw.item["red-belt"].place_result = nil
    red().placeable_by = {
        item = "red-belt",
        count = 1,
    }
    assert(common.next_upgrade_problem(yellow()) == nil)
end)

test("add_placeable_by starts a list when there is none", function()
    common.add_placeable_by(red(), "red-belt-salvage")
    assert(#red().placeable_by == 1)
    assert(red().placeable_by[1].item == "red-belt-salvage")
    assert(red().placeable_by[1].count == 1)
end)

test("add_placeable_by keeps an existing single entry and doesn't add duplicates", function()
    red().placeable_by = {
        item = "red-belt",
        count = 1,
    }
    common.add_placeable_by(red(), "red-belt-salvage")
    common.add_placeable_by(red(), "red-belt-salvage")
    assert(#red().placeable_by == 2)
    assert(red().placeable_by[1].item == "red-belt")
    assert(red().placeable_by[2].item == "red-belt-salvage")
end)

test("set_mining_result replaces results, which would otherwise take precedence", function()
    red().minable.results = {
        {
            type = "item",
            name = "yellow-belt",
            amount = 2,
        },
    }
    assert(common.set_mining_result(red(), "red-belt-salvage"))
    assert(red().minable.results == nil)
    assert(red().minable.result == "red-belt-salvage")
    assert(red().minable.count == 1)
end)

test("replace_mining_item swaps just that item in results", function()
    red().minable.results = {
        {
            type = "item",
            name = "red-belt",
            amount = 1,
        },
        {
            type = "item",
            name = "belt-scrap",
            amount = 3,
        },
    }
    assert(common.replace_mining_item(red(), "red-belt", "yellow-belt"))
    assert(red().minable.results[1].name == "yellow-belt")
    assert(red().minable.results[2].name == "belt-scrap")
end)

test("replace_mining_item swaps result and ignores other items", function()
    assert(not common.replace_mining_item(red(), "yellow-belt", "blue-belt"))
    assert(red().minable.result == "red-belt")
    assert(common.replace_mining_item(red(), "red-belt", "blue-belt"))
    assert(red().minable.result == "blue-belt")
end)

test("replace_placeable_by_item handles both the single and array forms", function()
    red().placeable_by = {
        item = "red-belt",
        count = 1,
    }
    common.replace_placeable_by_item(red(), "red-belt", "blue-belt")
    assert(red().placeable_by.item == "blue-belt")
    yellow().placeable_by = {
        {
            item = "yellow-belt",
            count = 1,
        },
        {
            item = "red-belt",
            count = 2,
        },
    }
    common.replace_placeable_by_item(yellow(), "red-belt", "blue-belt")
    assert(yellow().placeable_by[1].item == "yellow-belt")
    assert(yellow().placeable_by[2].item == "blue-belt")
    assert(yellow().placeable_by[2].count == 2)
end)

test("add_mining_item keeps a single result, moving it into results with its count", function()
    red().minable.count = 2
    assert(common.add_mining_item(red(), "red-belt-salvage"))
    assert(red().minable.result == nil and red().minable.count == nil)
    assert(#red().minable.results == 2)
    assert(red().minable.results[1].name == "red-belt" and red().minable.results[1].amount == 2)
    assert(red().minable.results[2].name == "red-belt-salvage" and red().minable.results[2].amount == 1)
end)

-- A plant: planted by its seed, but mined for its fruit
local function plant()
    return {
        type = "plant",
        name = "fruit-stem",
        minable = {
            mining_time = 1,
            results = {
                {
                    type = "item",
                    name = "fruit",
                    amount = 50,
                },
            },
        },
    }
end

test("moving an entity's placing keeps what else mining it gives, like a plant's fruit", function()
    local stem = plant()
    assert(not common.swap_mining_items(stem, {
        "fruit-seed",
    }, "looted-fruit-stem", false))
    assert(#stem.minable.results == 1 and stem.minable.results[1].name == "fruit")
    -- Salvage is gotten by mining, so it's added when mining didn't give the entity's own item
    assert(common.swap_mining_items(stem, {
        "fruit-seed",
    }, "salvaged-fruit-stem", true))
    assert(#stem.minable.results == 2 and stem.minable.results[1].name == "fruit" and stem.minable.results[2].name == "salvaged-fruit-stem")
    -- And swapped in where mining gave it
    assert(common.swap_mining_items(red(), {
        "red-belt",
    }, "red-belt-salvage", true))
    assert(red().minable.result == "red-belt-salvage")
end)

test("set_mining_result leaves unminable entities alone", function()
    red().minable = nil
    assert(not common.set_mining_result(red(), "red-belt-salvage"))
    assert(red().minable == nil)
end)

test("placing an entity, planting and placing a tile all count as placing something", function()
    assert(not common.places_something({
        name = "gear",
    }))
    assert(common.places_something({
        place_result = "chest",
    }))
    assert(common.places_something({
        plant_result = "tree",
    }))
    assert(common.places_something({
        place_as_tile = {
            result = "concrete",
        },
    }))
end)

test("planting counts as placing an entity", function()
    assert(common.placed_entity_name({
        place_result = "chest",
    }) == "chest")
    assert(common.placed_entity_name({
        plant_result = "tree",
    }) == "tree")
    assert(common.placed_entity_name({
        name = "gear",
    }) == nil)
end)

test("an item placing a plant also plants it, and one placing anything else plants nothing", function()
    local seed = {
        place_result = "tree",
        plant_result = "tree",
    }
    common.set_placed_entity(seed, {
        type = "assembling-machine",
        name = "assembler",
    })
    assert(seed.place_result == "assembler" and seed.plant_result == nil)
    local gear = {
        name = "gear",
    }
    common.set_placed_entity(gear, {
        type = "plant",
        name = "tree",
    })
    assert(gear.place_result == "tree" and gear.plant_result == "tree")
end)

test("an entity's sprite uses its main graphics scaled to the target size, and its icon otherwise", function()
    local machine = {
        selection_box = {{-1.5, -1.5}, {1.5, 1.5}},
        graphics_set = {
            animation = {
                layers = {
                    {
                        filename = "machine.png",
                        width = 214,
                        height = 237,
                        frame_count = 32,
                        scale = 0.5,
                        shift = {
                            0,
                            -0.3,
                        },
                    },
                },
            },
        },
    }
    local sprite = common.entity_sprite(machine, 1)
    -- A 3 tile machine shrunk to 1 tile
    assert(sprite.filename == "machine.png" and sprite.frame_count == 1 and sprite.direction_count == 1)
    assert(math.abs(sprite.scale - 0.5 / 3) < 1e-9 and math.abs(sprite.shift[2] + 0.1) < 1e-9)
    local chest = {
        selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
        icon = "chest.png",
    }
    local icon_sprite = common.entity_sprite(chest, 2)
    -- A 64 pixel icon is 2 tiles across at scale 1
    assert(icon_sprite.filename == "chest.png" and icon_sprite.width == 64 and icon_sprite.scale == 1)
end)

test("collision area counts entities smaller than a tile as a tile", function()
    assert(common.collision_area({
        collision_box = {{-1.5, -1.5}, {1.5, 1.5}},
    }) == 9)
    assert(common.collision_area({
        collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
    }) == 1)
    assert(common.collision_area({}) == 1)
end)

test("an entity fits another's autoplace if it collides with no more tiles and isn't much bigger", function()
    data.raw.tile = {
        meadow = {
            collision_mask = {
                layers = {
                    land_layer = true,
                },
            },
        },
        lake = {
            collision_mask = {
                layers = {
                    lake_layer = true,
                },
            },
        },
    }
    local rock = {
        collision_box = {{-1, -1}, {1, 1}},
        collision_mask = {
            layers = {
                bump_layer = true,
                lake_layer = true,
            },
        },
    }
    local furnace = {
        collision_box = {{-1, -1}, {1, 1}},
        collision_mask = {
            layers = {
                bump_layer = true,
                pickup_layer = true,
                lake_layer = true,
            },
        },
    }
    local boat = {
        collision_box = {{-1, -1}, {1, 1}},
        collision_mask = {
            layers = {
                bump_layer = true,
                land_layer = true,
            },
        },
    }
    local silo = {
        collision_box = {{-4.5, -4.5}, {4.5, 4.5}},
        collision_mask = rock.collision_mask,
    }
    -- Colliding with more entities (pickup_layer) is fine, since that isn't about tiles
    assert(common.fits_autoplace_of(furnace, rock, 2))
    -- Something that can't stand on land tiles can't take a rock's place
    assert(not common.fits_autoplace_of(boat, rock, 2))
    assert(not common.fits_autoplace_of(silo, rock, 2))
    assert(common.fits_autoplace_of(rock, silo, 2))
end)

test("icon_layers reads both icon forms as copies, and nil without an icon", function()
    local single = {
        icon = "belt.png",
        icon_size = 32,
    }
    local layers = common.icon_layers(single, "")
    assert(#layers == 1 and layers[1].icon == "belt.png" and layers[1].icon_size == 32)
    local layered = {
        icons = {
            {
                icon = "barrel.png",
            },
            {
                icon = "fluid.png",
                tint = {
                    r = 1,
                },
            },
        },
    }
    layers = common.icon_layers(layered, "")
    assert(#layers == 2 and layers[2].icon == "fluid.png")
    layers[2].tint.r = 0
    assert(layered.icons[2].tint.r == 1)
    assert(common.icon_layers(single, "dark_background_") == nil)
end)

test("set_icon_layers replaces both icon forms", function()
    local item = {
        icon = "old.png",
        icon_size = 32,
    }
    common.set_icon_layers(item, "", {
        {
            icon = "new.png",
        },
    })
    assert(item.icon == nil and item.icon_size == nil and item.icons[1].icon == "new.png")
    common.set_icon_layers(item, "", nil)
    assert(item.icons == nil)
end)

test("with_icon_badge adds the badge at half size in the top left without changing the inputs", function()
    local layers = {
        {
            icon = "module.png",
        },
    }
    local badge_layers = {
        {
            icon = "machine.png",
        },
        {
            icon = "gear.png",
            icon_size = 32,
            scale = 0.5,
            shift = {
                x = 4,
                y = 2,
            },
        },
    }
    local result = common.with_icon_badge(layers, badge_layers)
    assert(#result == 3 and result[1].icon == "module.png" and result[1].scale == nil)
    -- A 64px layer is drawn full size at scale 0.5, so its badge is at 0.25
    assert(result[2].scale == 0.25 and result[2].shift[1] == -8 and result[2].shift[2] == -8)
    assert(result[2].draw_background and result[2].floating)
    assert(result[3].scale == 0.25 and result[3].shift[1] == -6 and result[3].shift[2] == -7)
    assert(not result[3].draw_background and result[3].floating)
    assert(#layers == 1 and badge_layers[2].scale == 0.5 and badge_layers[2].shift.x == 4)
end)

test("darken_icon_layers keeps each layer's own tint and alpha", function()
    local layers = common.darken_icon_layers({
        {
            icon = "plain.png",
        },
        {
            icon = "red.png",
            tint = {
                r = 1,
                a = 0.8,
            },
        },
        {
            icon = "byte-color.png",
            tint = {
                255,
                0,
                102,
            },
        },
    })
    assert(layers[1].tint.r == 0.5 and layers[1].tint.g == 0.5 and layers[1].tint.b == 0.5 and layers[1].tint.a == 1)
    assert(layers[2].tint.r == 0.5 and layers[2].tint.g == 0 and layers[2].tint.a == 0.8)
    assert(layers[3].tint.r == 0.5 and layers[3].tint.b == 0.2 and layers[3].tint.a == 1)
end)

print(num_passed .. " tests passed")
