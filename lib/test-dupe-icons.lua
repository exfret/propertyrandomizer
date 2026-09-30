-- Plain-Lua regression tests for technology icons made from recipe icons in lib/dupe.lua (not loaded by the mod)
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

print(num_passed .. " tests passed")
