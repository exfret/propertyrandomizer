-- Names and icons for the recipes item randomization renames after their new product, in both the unified item handler (randomizations/graph/unified/handlers-new/item.lua) and the old item randomization (randomizations/graph/item.lua)
-- A renamed recipe takes its new product's name and icon, since it may have had its own, and is listed with its new product (its subgroup defaults to the main product's, see RecipePrototype::main_product)
-- When several recipes are named after the same product, the renamed ones also get a prefix and a number badge to tell them apart

local constants = require("helper-tables/constants")
local dupe = require("lib/dupe")
local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local item_fluid = require("lib/item-fluid")
local locale_utils = require("lib/locale")
local recycling_sources = require("lib/logic/recycling-sources")
local rng = require("lib/random/rng")

local recipe_renames = {}

-- A prototype's icons as an icons list: its own icons, or its single icon as one layer
local function icons_of(prot)
    if prot.icons ~= nil then
        return table.deepcopy(prot.icons)
    end
    if prot.icon ~= nil then
        return {
            {
                icon = prot.icon,
                icon_size = prot.icon_size or 64,
            },
        }
    end
    error("Prototype has no usable icon: " .. tostring(prot.name))
end

-- Names each renamed recipe after its new product, once every change item randomization makes is in data.raw
-- renamed: recipe name --> the product it's named after now, as { type, name }
-- old_recipes: data.raw.recipe before randomization, to tell recycling recipes apart (they're named after what they recycle)
-- rng_key: the key the prefixes are drawn with
recipe_renames.apply = function(renamed, old_recipes, rng_key)
    -- Product material key --> how many recipes are named after it, counting ones that weren't renamed (recycling recipes are named after what they recycle)
    local num_named_after = {}
    for recipe_name, recipe in pairs(data.raw.recipe) do
        local main_product = dutils.recipe_main_product(recipe)
        if main_product ~= nil and (main_product.type == "item" or main_product.type == "fluid") and recycling_sources.named_after_ingredient(old_recipes, recipe_name) == nil then
            local product_key = gutils.key(main_product.type, main_product.name)
            num_named_after[product_key] = (num_named_after[product_key] or 0) + 1
        end
    end

    local recipe_names = {}
    for recipe_name, _ in pairs(renamed) do
        table.insert(recipe_names, recipe_name)
    end
    table.sort(recipe_names)
    -- Product material key --> how many of its renamed recipes have been numbered so far
    local num_numbered = {}
    for _, recipe_name in pairs(recipe_names) do
        local recipe = data.raw.recipe[recipe_name]
        local product_key = gutils.key(renamed[recipe_name].type, renamed[recipe_name].name)
        -- The product's prototype in its current form (an identity that changed form has one now)
        local product = item_fluid.prot(renamed[recipe_name])
        local recipe_icons = icons_of(product)
        if (num_named_after[product_key] or 0) >= 2 then
            recipe.localised_name = {"", constants.funny_recipe_prefixes[rng.int(rng_key, #constants.funny_recipe_prefixes)], " ", locale_utils.find_localised_name(product)}
            num_numbered[product_key] = (num_numbered[product_key] or 0) + 1
            -- Only single digit badges exist, so any past that keep the plain product icon
            if num_numbered[product_key] <= dupe.max_icon_number then
                table.insert(recipe_icons, dupe.recipe_number_icon(num_numbered[product_key]))
            end
        else
            recipe.localised_name = locale_utils.find_localised_name(product)
        end
        recipe.icon = nil
        recipe.icons = recipe_icons
        recipe.subgroup = nil
        recipe.order = nil
    end
end

return recipe_renames
