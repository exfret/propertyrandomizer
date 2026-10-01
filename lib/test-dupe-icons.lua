-- Plain-Lua regression tests for icons in lib/dupe.lua: technology icons made from recipe icons, and item copies' number badges (not loaded by the mod)
-- Run from the mod root: lua lib/test-dupe-icons.lua
-- The tech tree rebuild (randomizations/fixes.lua) gives each rebuilt technology its recipe's icons, and every layer has to grow with the first one, number badges too

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

-- Stand-ins for the modules lib/dupe.lua loads, which these helpers don't use
package.loaded["helper-tables/categories"] = {}
package.loaded["lib/random/rng"] = {}
package.loaded["lib/locale"] = {}
package.loaded["lib/data-utils"] = {}
package.loaded["resource-autoplace"] = {}
package.loaded["lib/dupe-graphics-manifest"] = {
    files = {},
}

local dupe = require("lib/dupe")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

test("a recipe copy's number badge keeps its size and place on a rebuilt technology", function()
    local recipe = {
        icons = {
            {
                icon = "plate.png",
                icon_size = 64,
            },
            dupe.recipe_number_icon(2),
        },
    }
    local icons = dupe.technology_icons(dupe.get_recipe_icons(recipe))
    -- A layer without a scale takes the technology's default by itself
    assert(icons[1].scale == nil and icons[1].shift == nil and icons[1].icon == "plate.png")
    assert(icons[2].scale == 4 / 6 and icons[2].shift[1] == 28 and icons[2].shift[2] == -28)
    -- The recipe keeps its own icons
    assert(recipe.icons[2].scale == 1 / 6 and recipe.icons[2].shift[1] == 7)
end)

test("a shift with named coordinates is scaled too", function()
    local icons = dupe.technology_icons({
        {
            icon = "fluid.png",
            icon_size = 64,
            scale = 0.25,
            shift = {
                x = -8,
                y = 4,
            },
        },
    })
    assert(icons[1].scale == 1 and icons[1].shift[1] == -32 and icons[1].shift[2] == 16)
end)

test("a recipe with a single icon gets it unchanged", function()
    local icons = dupe.technology_icons(dupe.get_recipe_icons({
        icon = "gear.png",
    }))
    assert(#icons == 1 and icons[1].icon == "gear.png" and icons[1].icon_size == 64 and icons[1].scale == nil)
end)

-- Stand-ins for what dupe.item reads: prototypes in data.raw, the item classes, rng keys and localised names
local function fresh_data()
    data = {
        raw = {
            tool = {},
            fluid = {},
            recipe = {},
            technology = {},
        },
    }
    function data:extend(prototypes)
        for _, prototype in pairs(prototypes) do
            self.raw[prototype.type] = self.raw[prototype.type] or {}
            self.raw[prototype.type][prototype.name] = prototype
        end
    end
    defines = {
        prototypes = {
            item = {
                tool = 0,
            },
            equipment = {},
        },
    }
    package.loaded["lib/random/rng"].key = function(info)
        return info.prototype.type .. ":" .. info.prototype.name
    end
    package.loaded["lib/locale"].find_localised_name = function(prototype)
        return prototype.name
    end
    data:extend({
        {
            type = "tool",
            name = "flask",
            icon = "flask.png",
        },
        {
            type = "recipe",
            name = "flask",
            results = {
                {
                    type = "item",
                    name = "flask",
                    amount = 1,
                },
            },
        },
    })
end

-- Whether any of the icon layers is a number badge
local function has_badge(icons)
    for _, layer in pairs(icons or {}) do
        if string.find(layer.icon, "number_", 1, true) ~= nil then
            return true
        end
    end
    return false
end

test("a science pack copy (no_badge) has no number badge on its icon or its recipe's", function()
    fresh_data()
    local copy = dupe.item(data.raw.tool.flask, 2, {
        no_badge = true,
    })
    assert(copy.icons == nil and copy.icon == "flask.png")
    local recipe_copy = data.raw.recipe["flask-exfret-2-copy"]
    assert(recipe_copy ~= nil and recipe_copy.results[1].name == copy.name)
    assert(#recipe_copy.icons == 1 and recipe_copy.icons[1].icon == "flask.png" and not has_badge(recipe_copy.icons))
    -- The originals stay as they were
    assert(data.raw.tool.flask.icons == nil and data.raw.recipe.flask.icons == nil)
end)

test("any other item copy keeps its number badges", function()
    fresh_data()
    local copy = dupe.item(data.raw.tool.flask, 2)
    assert(has_badge(copy.icons) and copy.icons[#copy.icons].shift[1] == -7)
    local recipe_copy = data.raw.recipe["flask-exfret-2-copy"]
    assert(has_badge(recipe_copy.icons) and recipe_copy.icons[#recipe_copy.icons].shift[1] == -7)
end)

test("the dupe numbers made follow the setting, as far as the recolored graphics and the number badges go", function()
    local manifest = package.loaded["lib/dupe-graphics-manifest"]
    manifest.max_dupe = 9
    config = {
        num_dupes = 2,
    }
    -- The default: copies 2 and 3
    assert(dupe.highest_number() == 3)
    config.num_dupes = 1
    assert(dupe.highest_number() == 2)
    config.num_dupes = 8
    assert(dupe.highest_number() == 9)
    -- Every number up to the highest has its badge
    local badge = dupe.number_badge(9, 1, {
        0,
        0,
    })
    assert(dupe.max_icon_number == 9 and string.find(badge.icon, "number_nine.png", 1, true) ~= nil)
    -- Graphics made for fewer dupes than the setting asks for cap it
    manifest.max_dupe = 3
    assert(dupe.highest_number() == 3)
    manifest.max_dupe = nil
    config = nil
end)

print(num_passed .. " tests passed")
