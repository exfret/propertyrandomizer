-- Recycling recipes as the recycler mod generates them, but generated from the current prototypes instead of before randomization
-- The recycler generates them in its data-updates.lua (recycler/recycling.lua and recycler/data-updates.lua in the game data), so a recipe that randomization changes would otherwise keep recycling into its old ingredients
-- The functions below follow those two files step by step, reading from a given prototype table (data.raw, or old_data_raw for what the recycler generated before randomization)
-- Recycling recipes the recycler didn't generate (like scrap recycling, which is written by hand) are left alone

local recycling = {}

local recycling_category = "recycling"

local function get_prototype(raw, base_type, name)
    for type_name, _ in pairs(defines.prototypes[base_type]) do
        if raw[type_name] ~= nil and raw[type_name][name] ~= nil then
            return raw[type_name][name]
        end
    end
end

local function sorted_keys(tbl)
    local keys = {}
    for k, _ in pairs(tbl) do
        table.insert(keys, k)
    end
    table.sort(keys)
    return keys
end

local function get_item_localised_name(raw, name)
    local item = get_prototype(raw, "item", name)
    if item == nil then
        return
    end
    if item.localised_name ~= nil then
        return item.localised_name
    end
    local prototype
    local type_name = "item"
    if item.place_result ~= nil then
        prototype = get_prototype(raw, "entity", item.place_result)
        type_name = "entity"
    elseif item.place_as_equipment_result ~= nil then
        prototype = get_prototype(raw, "equipment", item.place_as_equipment_result)
        type_name = "equipment"
    elseif item.place_as_tile ~= nil then
        -- Tiles with variations don't have a localised name
        local tile_prototype = raw.tile ~= nil and raw.tile[item.place_as_tile.result] or nil
        if tile_prototype ~= nil and tile_prototype.localised_name ~= nil then
            prototype = tile_prototype
            type_name = "tile"
        end
    end
    return prototype ~= nil and prototype.localised_name or {type_name .. "-name." .. name}
end

local function gray_tints(value)
    local tints = {}
    for _, layer in pairs({"primary", "secondary", "tertiary", "quaternary"}) do
        tints[layer] = {value, value, value, value}
    end
    return tints
end

local function item_entry(name, amount)
    return {
        type = "item",
        name = name,
        amount = amount,
    }
end

-- The recycler's own icon generator, a global it defines in the prototype stage's shared Lua state
local function icons_from_item(item)
    if generate_recycling_recipe_icons_from_item ~= nil then
        return generate_recycling_recipe_icons_from_item(item)
    end
end

local function has_recycling_category(recipe)
    for _, category in pairs(recipe.categories or {}) do
        if category == recycling_category then
            return true
        end
    end
    return false
end

-- The recycler's default_can_recycle
local function can_recycle(recipe)
    if has_recycling_category(recipe) then
        return false
    end
    -- Allow recipes to opt-out
    if recipe.auto_recycle == false then
        return false
    end
    if string.find(recipe.name, "science") and string.find(recipe.name, "pack") then
        return false
    end
    return true
end

-- The recycler's add_recipe_values and generate_recycling_recipe (without its unlock, since regenerate enables them from the start)
-- Returns the recycling recipe the recycler makes from recipe, and the name of the recipe whose ingredients it returns, or nil if it makes none
local function reverse_recipe(raw, recipe)
    if not can_recycle(recipe) or recipe.results == nil then
        return
    end
    local recipe_to_reverse = recipe.recycle_to_ingredients_of ~= nil and raw.recipe[recipe.recycle_to_ingredients_of] or recipe

    local result_count
    local input_result
    for _, product in pairs(recipe.results) do
        if product.type == "item" then
            -- More than one result item
            if input_result ~= nil then
                return
            end
            local amount_min = product.amount or product.amount_min
            local amount_max = product.amount or product.amount_max
            if amount_min == amount_max then
                input_result = product.name
                result_count = amount_min
            end
        end
    end
    -- The recycler would divide by zero here; a vanilla recipe never makes none of its only item
    if input_result == nil or result_count == nil or result_count <= 0 then
        return
    end
    local result_item = get_prototype(raw, "item", input_result)
    if result_item == nil or recipe_to_reverse.ingredients == nil then
        return
    end

    local subgroup = recipe.subgroup
    if subgroup == nil and recipe.main_product ~= nil then
        local main_item = get_prototype(raw, "item", recipe.main_product)
        if main_item ~= nil then
            subgroup = main_item.subgroup
        end
    end

    local result = {
        type = "recipe",
        name = input_result .. "-recycling",
        localised_name = {"recipe-name.recycling", get_item_localised_name(raw, input_result)},
        icons = icons_from_item(result_item),
        subgroup = subgroup,
        categories = {recycling_category},
        enabled = false,
        hidden = true,
        allow_decomposition = false,
        unlock_results = false,
        ingredients = {item_entry(input_result, 1)},
        results = {},
        energy_required = math.max((recipe_to_reverse.energy_required or 0.5) / 16 / result_count, 0.0011),
    }

    local crafting_tint = gray_tints(0.5)
    for _, ingredient in pairs(recipe_to_reverse.ingredients) do
        if ingredient.type == "item" then
            local final_name = ingredient[1] or ingredient.name
            local final_amount = ingredient[2] or ingredient.amount
            local final_probability = 4 * result_count * (ingredient.result_count or 1)
            local remainder = final_amount % final_probability
            table.insert(result.results, {
                type = "item",
                name = final_name,
                amount = math.floor(final_amount / final_probability),
                extra_count_fraction = remainder / final_probability,
            })
        elseif ingredient.type == "fluid" then
            local fluid = raw.fluid[ingredient.name]
            if fluid ~= nil and fluid.flow_color ~= nil then
                local flow_color = fluid.flow_color
                local normalized = {
                    flow_color[1] or flow_color.r or 0,
                    flow_color[2] or flow_color.g or 0,
                    flow_color[3] or flow_color.b or 0,
                }
                if normalized[1] > 1 or normalized[2] > 1 or normalized[3] > 1 then
                    normalized[1] = normalized[1] / 255
                    normalized[2] = normalized[2] / 255
                    normalized[3] = normalized[3] / 255
                end
                crafting_tint.tertiary = {
                    normalized[1] + ((1 - normalized[1]) * 0.5),
                    normalized[2] + ((1 - normalized[2]) * 0.5),
                    normalized[3] + ((1 - normalized[3]) * 0.5),
                }
                crafting_tint.quaternary = fluid.base_color
            end
        end
    end
    result.crafting_machine_tint = crafting_tint

    if next(result.results) == nil then
        return
    end
    return result, recipe_to_reverse.name
end

-- The recycler's generate_self_recycling_recipe, with the checks data-updates.lua makes before calling it (except the one for an existing recipe of the same name)
local function self_recycling_recipe(raw, item)
    if item.auto_recycle == false or item.parameter == true then
        return
    end
    if string.find(item.name, "-barrel") then
        return
    end
    local same_name_recipe = raw.recipe[item.name]
    local ingredient = item_entry(item.name, 1)
    ingredient.ignored_by_stats = 1
    local result = item_entry(item.name, 1)
    result.independent_probability = 0.25
    result.ignored_by_stats = 1
    return {
        type = "recipe",
        name = item.name .. "-recycling",
        localised_name = {"recipe-name.recycling", get_item_localised_name(raw, item.name)},
        icons = icons_from_item(item),
        subgroup = item.subgroup,
        categories = {recycling_category},
        hidden = true,
        enabled = false,
        unlock_results = false,
        ingredients = {ingredient},
        -- Will show as consumed when item is destroyed
        results = {result},
        energy_required = (same_name_recipe ~= nil and same_name_recipe.energy_required or 0.5) / 16,
        crafting_machine_tint = same_name_recipe ~= nil and same_name_recipe.crafting_machine_tint or gray_tints(0.125),
    }
end

-- Whether recipe has the shape the recycler gives every recipe it generates (named after its one item ingredient, only in the recycling category, hidden, and not unlocking its results), which hand-written ones like scrap recycling don't
-- Regeneration numbers the name when another item's recycling has it ("<item>-recycling-2"), so a numbered name counts too; otherwise the next call wouldn't see the recipe as its own and would make another one for the same item
recycling.looks_generated = function(recipe)
    if recipe.hidden ~= true or recipe.unlock_results ~= false then
        return false
    end
    if recipe.categories == nil or #recipe.categories ~= 1 or recipe.categories[1] ~= recycling_category then
        return false
    end
    if recipe.ingredients == nil or #recipe.ingredients ~= 1 or recipe.ingredients[1].type ~= "item" then
        return false
    end
    local default_name = recipe.ingredients[1].name .. "-recycling"
    if recipe.name == default_name then
        return true
    end
    local number = string.sub(recipe.name, #default_name + 2)
    return string.sub(recipe.name, 1, #default_name + 1) == default_name .. "-" and string.match(number, "^%d+$") ~= nil
end

-- Recycling name --> what each recipe the recycler would reverse into it makes, by recipe name
local function reverse_candidates(raw)
    local candidates = {}
    for _, recipe_name in pairs(sorted_keys(raw.recipe)) do
        local recycling_recipe, reversed = reverse_recipe(raw, raw.recipe[recipe_name])
        if recycling_recipe ~= nil then
            candidates[recycling_recipe.name] = candidates[recycling_recipe.name] or {}
            table.insert(candidates[recycling_recipe.name], {
                recipe = recycling_recipe,
                source = recipe_name,
                reversed = reversed,
            })
        end
    end
    return candidates
end

-- Generates recycling recipes from raw the way the recycler does
-- Several recipes can make the same item; the recycler keeps whichever it visits last, which isn't reproducible, so this takes preferred_source[recycling name] if it's one of them, and otherwise the first by name
-- Returns recycling name --> {recipe = the recycling recipe, source = the recipe it was made from, reversed = the recipe whose ingredients it returns (nil for self-recycling)}
recycling.generate = function(raw, preferred_source)
    preferred_source = preferred_source or {}
    local generated = {}
    for recycling_name, options in pairs(reverse_candidates(raw)) do
        local chosen = options[1]
        for _, option in pairs(options) do
            if option.source == preferred_source[recycling_name] then
                chosen = option
            end
        end
        generated[recycling_name] = chosen
    end
    for item_class, _ in pairs(defines.prototypes.item) do
        for _, item_name in pairs(sorted_keys(raw[item_class] or {})) do
            local name = item_name .. "-recycling"
            if generated[name] == nil then
                local recipe = self_recycling_recipe(raw, raw[item_class][item_name])
                if recipe ~= nil then
                    generated[name] = {
                        recipe = recipe,
                        source = item_name,
                    }
                end
            end
        end
    end
    return generated
end

local function same_results(a, b)
    if #a ~= #b then
        return false
    end
    for i = 1, #a do
        if a[i].name ~= b[i].name or a[i].amount ~= b[i].amount or (a[i].extra_count_fraction or 0) ~= (b[i].extra_count_fraction or 0) then
            return false
        end
    end
    return true
end

local vanilla_cache = {}

-- What the recycler generated in raw (the game before randomization): recycling name --> {source, reversed} as in recycling.generate, both nil if it can't be made again from raw
-- Among several recipes making the same item, the source is the one whose recycling results match what raw has
recycling.vanilla = function(raw)
    if vanilla_cache.raw == raw then
        return vanilla_cache.info
    end
    local preferred = {}
    for recycling_name, options in pairs(reverse_candidates(raw)) do
        local recipe = raw.recipe[recycling_name]
        if recipe ~= nil and recycling.looks_generated(recipe) then
            for _, option in pairs(options) do
                if preferred[recycling_name] == nil and same_results(option.recipe.results, recipe.results or {}) then
                    preferred[recycling_name] = option.source
                end
            end
        end
    end
    local generated = recycling.generate(raw, preferred)
    local info = {}
    for recycling_name, recipe in pairs(raw.recipe) do
        if recycling.looks_generated(recipe) then
            local entry = generated[recycling_name] or {}
            info[recycling_name] = {
                source = entry.source,
                reversed = entry.reversed,
            }
        end
    end
    vanilla_cache = {
        raw = raw,
        info = info,
    }
    return info
end

-- Replaces the recycling recipes the recycler generated with what it generates from data.raw now
-- old_raw is the game before randomization, for which recipes the recycler generated there and which recipe each was made from
-- Every generated recycling recipe is unlocked from the start
recycling.regenerate = function(old_raw)
    local raw = data.raw
    local vanilla = recycling.vanilla(old_raw)
    if next(vanilla) == nil then
        return
    end

    -- Generated recipes: the recycler's from before randomization (whatever randomization did to them since), and ones an earlier call made
    local is_generated = {}
    for recycling_name, _ in pairs(vanilla) do
        is_generated[recycling_name] = true
    end
    for recipe_name, recipe in pairs(raw.recipe) do
        if recycling.looks_generated(recipe) then
            is_generated[recipe_name] = true
        end
    end

    -- The generated recipes there are now, by name
    local old_recipes = {}
    for recipe_name, _ in pairs(is_generated) do
        if raw.recipe[recipe_name] ~= nil then
            old_recipes[recipe_name] = raw.recipe[recipe_name]
            raw.recipe[recipe_name] = nil
        end
    end

    -- The recycler generates no recycling for an item whose "<item>-recycling" name a hand-written recipe has taken, like scrap's (recycler/data-updates.lua)
    -- Item randomization renames the item such a recipe takes, so follow the recipe to the item it takes now; otherwise the recycler, which picks its recipe by ingredient, would have two for that item
    local hand_recycled = {}
    for recipe_name, recipe in pairs(raw.recipe) do
        local old_recipe = old_raw.recipe[recipe_name]
        if old_recipe ~= nil and has_recycling_category(recipe) and recipe.ingredients ~= nil and #recipe.ingredients == 1 and recipe.ingredients[1].type == "item" then
            local old_ingredients = old_recipe.ingredients or {}
            if #old_ingredients == 1 and old_ingredients[1].type == "item" and old_ingredients[1].name .. "-recycling" == recipe_name then
                hand_recycled[recipe.ingredients[1].name] = true
            end
        end
    end

    -- Item randomization changes which item each recycling recipe recycles, and the logic model follows each recipe by its name, so an item's recycling keeps the name of the recipe that recycles it now
    -- Item name --> name of the generated recipe recycling it now, preferring the one named after it
    local name_for_item = {}
    for _, recipe_name in pairs(sorted_keys(old_recipes)) do
        local ingredients = old_recipes[recipe_name].ingredients or {}
        if #ingredients == 1 and ingredients[1].type == "item" then
            local item_name = ingredients[1].name
            if name_for_item[item_name] == nil or recipe_name == item_name .. "-recycling" then
                name_for_item[item_name] = recipe_name
            end
        end
    end

    -- The source to prefer for an item's recycling is the one its recipe name had before randomization
    local preferred_by_default_name = {}
    local taken = {}
    for item_name, recipe_name in pairs(name_for_item) do
        if vanilla[recipe_name] ~= nil then
            preferred_by_default_name[item_name .. "-recycling"] = vanilla[recipe_name].source
        end
        taken[recipe_name] = true
    end
    local generated = {}
    local unnamed = {}
    for default_name, entry in pairs(recycling.generate(raw, preferred_by_default_name)) do
        local item_name = entry.recipe.ingredients[1].name
        if hand_recycled[item_name] ~= nil then
            -- Recycled by hand already (see above)
        elseif name_for_item[item_name] ~= nil then
            entry.recipe.name = name_for_item[item_name]
            generated[entry.recipe.name] = entry
        else
            unnamed[default_name] = entry
        end
    end
    -- Items no generated recipe recycled before take the recycler's name, numbered if another item's recycling has it now
    for _, default_name in pairs(sorted_keys(unnamed)) do
        local name = default_name
        local number = 1
        while taken[name] ~= nil or raw.recipe[name] ~= nil do
            number = number + 1
            name = default_name .. "-" .. number
        end
        taken[name] = true
        unnamed[default_name].recipe.name = name
        generated[name] = unnamed[default_name]
    end

    -- Recycling recipes are unlocked from the start, so no technology unlocks them
    for _, tech in pairs(raw.technology or {}) do
        if tech.effects ~= nil then
            local kept_effects = {}
            for _, effect in pairs(tech.effects) do
                if effect.type ~= "unlock-recipe" or (is_generated[effect.recipe] == nil and generated[effect.recipe] == nil) then
                    table.insert(kept_effects, effect)
                end
            end
            tech.effects = kept_effects
        end
    end

    for _, recycling_name in pairs(sorted_keys(generated)) do
        -- The recycler doesn't replace a recipe of the same name here, like one written by hand
        if raw.recipe[recycling_name] == nil then
            local recipe = generated[recycling_name].recipe
            recipe.enabled = true
            raw.recipe[recycling_name] = recipe
        end
    end
end

return recycling
