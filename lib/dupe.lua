local locale_utils = require("lib/locale")
local patching = require("lib/patching")

-- TODO: Fuel duplication (would require duplicating coal ore patch and fixing solid fuel recipes sensibly)

-- Note: Duplicating the both the item and recipe for the same thing may cause issues with icons and possibly worse right now

local dupe = {}

-- To dupe:
--   * Important recipes
--   * Crafting machines
--   * Tech unlocks (to some extent, maybe not all?)

local dupe_number_to_filename = {
    "number_one.png",
    "number_two.png",
    "number_three.png",
    "number_four.png",
    "number_five.png",
    "number_six.png",
    "number_seven.png",
    "number_eight.png",
    "number_nine.png",
}

dupe.prototype = function(prototype, dupe_number)
    local new_prototype = table.deepcopy(prototype)

    -- Need to add the -copy at the end to prevent the special behavior for technology prototypes with -number at end of prototype names
    new_prototype.name = new_prototype.name .. "-exfret-" .. tostring(dupe_number) .. "-copy"
    new_prototype.localised_name = {"propertyrandomizer.dupe", locale_utils.find_localised_name(prototype), tostring(dupe_number)}
    -- For help in localisation later
    new_prototype.orig_name = prototype.name
    new_prototype.dupe_number = dupe_number

    data:extend({
        new_prototype
    })

    return new_prototype
end

dupe.recipe = function(recipe, dupe_number)
    local new_recipe = dupe.prototype(recipe, dupe_number)
    -- Recipes get special dupe names to distinguish them from an item that's duplicated
    new_recipe.localised_name = {"propertyrandomizer.recipe_dupe", locale_utils.find_localised_name(recipe), tostring(dupe_number)}

    -- Recipe tech unlocks
    for _, technology in pairs(data.raw.technology) do
        if technology.effects ~= nil then
            for _, effect in pairs(technology.effects) do
                if effect.type == "unlock-recipe" and effect.recipe == recipe.name then
                    table.insert(technology.effects, {
                        type = "unlock-recipe",
                        recipe = new_recipe.name
                    })
                end
            end
        end
    end

    -- Also need to do icon
    local recipe_icons
    if new_recipe.icons == nil and new_recipe.icon == nil then
        local item_with_icon_name
        if new_recipe.main_product ~= nil then
            item_with_icon_name = new_recipe.main_product
        else
            item_with_icon_name = new_recipe.results[1].name
        end
        local item_with_icon
        for item_class, _ in pairs(defines.prototypes.item) do
            if data.raw[item_class] ~= nil then
                if data.raw[item_class][item_with_icon_name] ~= nil then
                    item_with_icon = data.raw[item_class][item_with_icon_name]
                end
            end
        end
        if data.raw.fluid[item_with_icon_name] ~= nil then
            item_with_icon = data.raw.fluid[item_with_icon_name]
        end
        if item_with_icon.icons ~= nil then
            recipe_icons = item_with_icon.icons
        else
            recipe_icons = {
                {
                    icon = item_with_icon.icon,
                    icon_size = item_with_icon.icon_size or 64
                }
            }
        end
    elseif new_recipe.icons == nil then
        recipe_icons = {
            {
                icon = new_recipe.icon,
                icon_size = new_recipe.icon_size or 64
            }
        }
    else
        recipe_icons = new_recipe.icons
    end
    new_recipe.icons = recipe_icons
    table.insert(new_recipe.icons, {
        icon = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number],
        icon_size = 120,
        scale = 1 / 6,
        shift = {7, -7}
    })

    return new_recipe
end

dupe.item = function(item, dupe_number)
    local new_item = dupe.prototype(item, dupe_number)

    -- Check if there was a recipe for this item and duplicate it if so
    if data.raw.recipe[item.name] ~= nil then
        local new_item_recipe = dupe.recipe(data.raw.recipe[item.name], dupe_number)
        -- Override recipe's special localised name and icon
        new_item_recipe.localised_name = {"propertyrandomizer.dupe", locale_utils.find_localised_name(item), tostring(dupe_number)}
        new_item_recipe.icons[#new_item_recipe.icons].shift[1] = -new_item_recipe.icons[#new_item_recipe.icons].shift[1]
        patching.replace_ing_or_result(new_item_recipe.results, "item", item.name, {
            type = "item",
            name = new_item.name,
            amount = 1
        })
    end

    for _, icon_prefix_type in pairs({"", "dark_background_"}) do
        if new_item[icon_prefix_type .. "icon"] ~= nil or new_item[icon_prefix_type .. "icons"] ~= nil then
            local item_icons
            if new_item[icon_prefix_type .. "icons"] == nil then
                item_icons = {
                    {
                        icon = new_item[icon_prefix_type .. "icon"],
                        icon_size = new_item[icon_prefix_type .. "icon_size"] or 64
                    }
                }
            else
                item_icons = new_item[icon_prefix_type .. "icons"]
            end
            table.insert(item_icons, {
                [icon_prefix_type .. "icon"] = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number],
                [icon_prefix_type .. "icon_size"] = 120,
                scale = 1 / 6,
                shift = {-7, -7}
            })
            new_item[icon_prefix_type .. "icons"] = item_icons
        end
    end

    return new_item
end

dupe.technology = function(tech, dupe_number)
    -- Test for special behavior for techs whose name ends with a -number
    local prefix, suffix = tech.name:match("^(.*)%-(%d+)$")

    local new_tech = dupe.prototype(tech, dupe_number)
    -- Add the suffix back on
    if suffix ~= nil and tonumber(suffix) ~= nil then
        data.raw.technology[new_tech.name] = nil
        new_tech.name = prefix .. "-exfret-" .. tostring(dupe_number) .. "-copy-" .. suffix
        data.raw.technology[new_tech.name] = new_tech
    end

    if new_tech.icon ~= nil or new_tech.icons ~= nil then
        local tech_icons
        if new_tech.icons == nil then
            tech_icons = {
                {
                    icon = new_tech.icon,
                    icon_size = new_tech.icon_size or 64
                }
            }
        else
            tech_icons = new_tech.icons
        end
        new_tech.icons = tech_icons
        table.insert(tech_icons, {
            icon = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number],
            icon_size = 120,
            scale = 1 / 3,
            shift = {-40, -40}
        })
    end

    local new_prerequisites = {}
    if new_tech.prerequisites ~= nil then
        for _, prereq in pairs(new_tech.prerequisites) do
            local prereq_prefix, prereq_suffix = prereq:match("^(.*)%-(%d+)$")
            if prereq_suffix ~= nil and tonumber(prereq_suffix) ~= nil then
                table.insert(new_prerequisites, prereq_prefix .. "-exfret-" .. tostring(dupe_number) .. "-copy-" .. prereq_suffix)
            else
                table.insert(new_prerequisites, prereq .. "-exfret-" .. tostring(dupe_number) .. "-copy")
            end
        end
    end
    new_tech.prerequisites = new_prerequisites

    return new_tech
end

dupe.entity = function(entity, dupe_number)
    local new_entity = dupe.prototype(entity, dupe_number)

    -- If this entity is placeable duplicate its item
    local associated_item
    if new_entity.placeable_by ~= nil then
        if new_entity.placeable_by.item ~= nil then
            new_entity.placeable_by = {new_entity.placeable_by}
        end
        if #new_entity.placeable_by == 1 then
            associated_item = new_entity.placeable_by[1].item
        end
    end
    if associated_item == nil then
        for item_class, _ in pairs(defines.prototypes.item) do
            if data.raw[item_class] ~= nil then
                for _, item in pairs(data.raw[item_class]) do
                    if item.place_result == entity.name then
                        -- This technically doesn't work if multiple things can place the same thing, but that's uncommon
                        associated_item = item
                    end
                end
            end
        end
    end
    if associated_item ~= nil then
        local new_entity_item = dupe.item(associated_item, dupe_number)
        new_entity_item.place_result = new_entity.name
        if new_entity.minable ~= nil then
            if new_entity.minable.result == associated_item.name then
                new_entity.minable.result = new_entity_item.name
            elseif new_entity.minable.results ~= nil and #new_entity.minable.results == 1 and new_entity.minable.results[1].type == "item" and new_entity.minable.results[1].name == associated_item.name then
                new_entity.minable.results[1].name = new_entity_item.name
            end
        end
    end

    -- TODO: Upgrades, pasteable entities, icons, items with this as their plant result

    return new_entity
end

dupe.rolling_stock = function(rolling_stock, dupe_number)
    local new_rolling_stock = dupe.entity(rolling_stock, dupe_number)

    -- Change graphics
    if new_rolling_stock.pictures ~= nil then
        local direction_count
        local layer = new_rolling_stock.pictures.rotated
        while true do
            if layer.direction_count then
                direction_count = layer.direction_count
                break
            else
                layer = layer.layers[1]
            end
        end
        local frames = {}
        for i = 1, direction_count do
            table.insert(frames, {
                x = -(i - 1) * 120
            })
        end
        new_rolling_stock.pictures.rotated = {
            layers = {
                new_rolling_stock.pictures.rotated,
                {
                    filename = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number],
                    size = 120,
                    direction_count = direction_count,
                    frames = frames,
                    scale = 0.6
                }
            }
        }
    end

    return new_rolling_stock
end

-- Create the duplicates
dupe.execute = function()
    -- Tech tree
    --[[local techs_to_dupe = {}
    for _, tech in pairs(data.raw.technology) do
        table.insert(techs_to_dupe, tech)
    end
    for _, tech in pairs(techs_to_dupe) do
        for i = 2, 3 do
            dupe.technology(tech, i)
        end
    end]]

    -- Duplicate science pack recipes
    for _, science_pack in pairs(data.raw.tool) do
        if data.raw.recipe[science_pack.name] ~= nil then
            dupe.recipe(data.raw.recipe[science_pack.name], 2)
        end
    end
    dupe.recipe(data.raw.recipe["rocket-part"], 2)

    local items_to_dupe = {}
    for _, ammo in pairs(data.raw.ammo) do
        table.insert(items_to_dupe, ammo)
    end
    for _, item in pairs(items_to_dupe) do
        dupe.item(item, 2)
    end
    dupe.rolling_stock(data.raw.locomotive.locomotive, 2)

    -- TODO:
    --   * Turrets
    --   * All bot stuffs
    --   * All power gen stuffs
    --   * Agricultural tower (maybe "unique" crafting machines too)
    --   * Beacon
    --   * Fuels
    --   * Personal equipment
    --   * Mining drills

    --log(serpent.block(data.raw.technology))
    
    --[[local recipes_to_dupe = {}
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.category ~= "smelting" then
            table.insert(recipes_to_dupe, recipe)
        end
    end
    for _, recipe in pairs(recipes_to_dupe) do
        for i = 2, 9, 1 do
            dupe.recipe(recipe, i)
        end
    end]]
end

return dupe