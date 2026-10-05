-- Recycling recipes as the recycler mod generates them, but generated from the current prototypes instead of before randomization
-- The recycler generates them in its data-updates.lua (recycler/recycling.lua and recycler/data-updates.lua in the game data), so a recipe that randomization changes would otherwise keep recycling into its old ingredients
-- The functions below follow those two files step by step, reading from a given prototype table (data.raw, or old_data_raw for what the recycler generated before randomization)
-- Recycling recipes the recycler didn't generate (like scrap recycling, which is written by hand) are left alone

local surface_sets = require("lib/surface-sets")

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

-- Build the reverse of one source recipe for staged costing, using the same rules as final regeneration.
recycling.recipe_from_source = reverse_recipe

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
    if recipe.recycling_origin ~= nil then
        return true
    end
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
            local entry = recipe.recycling_origin or generated[recycling_name] or {}
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

-- Rounding an item ingredient up can refund part of it as a product.
-- A second item product makes a source ineligible for reversal (reverse_recipe), losing the recycling outputs promotion modeled and pinned.
-- Keep that source's shape.
recycling.add_item_refund = function(original_raw, recipe, item_name, probability)
    for _, entry in pairs(recycling.vanilla(original_raw)) do
        if entry.reversed ~= nil and entry.source == recipe.name then
            return false
        end
    end
    if recipe.results == nil or #recipe.results == 0 then
        return false
    end
    if #recipe.results == 1 then
        recipe.main_product = recipe.results[1].name
    end
    table.insert(recipe.results, {
        type = "item",
        name = item_name,
        amount = 1,
        independent_probability = probability,
    })
    return true
end

-- The recycling recipes the recycler generated, as recipe name --> true: the recycler's from before randomization in old_raw (whatever randomization did to them since, like renaming what they recycle), and ones regeneration made in raw
-- Hand-written recycling recipes, like scrap recycling, aren't among them
recycling.generated_names = function(raw, old_raw)
    local is_generated = {}
    for recycling_name, _ in pairs(recycling.vanilla(old_raw)) do
        is_generated[recycling_name] = true
    end
    for recipe_name, recipe in pairs(raw.recipe) do
        if recycling.looks_generated(recipe) then
            is_generated[recipe_name] = true
        end
    end
    return is_generated
end

-- Replaces the recycling recipes the recycler generated with what it generates from data.raw now
-- old_raw is the game before randomization, for which recipes the recycler generated there and which recipe each was made from
-- Every generated recycling recipe is unlocked from the start
recycling.regenerate = function(old_raw)
    local raw = data.raw
    for _, recipe in pairs(raw.recipe) do
        if recipe.recycling_origin ~= nil then
            recycling.regenerate_planetary(old_raw)
            return
        end
    end
    local vanilla = recycling.vanilla(old_raw)
    if next(vanilla) == nil then
        return
    end

    local is_generated = recycling.generated_names(raw, old_raw)

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

-- Candidates keep stable source identities through first pass; their accepted rooms change with the physical input.
-- The same selector is used by the graph and final regeneration.
recycling.planetary_scopes = function(raw, material_for, accepted)
    local choices = {}
    local scopes = {}
    local reserved = {}
    local ambiguities = {}
    for _, name in pairs(sorted_keys(raw.recipe)) do
        local recipe = raw.recipe[name]
        local origin = recipe.recycling_origin
        if origin ~= nil then
            scopes[name] = {}
            local input = material_for(recipe, "ingredients", recipe.ingredients[1])
            if input ~= nil and input.type == "item" then
                for room, _ in pairs(origin.available) do
                    choices[room] = choices[room] or {}
                    choices[room][input.name] = choices[room][input.name] or {}
                    table.insert(choices[room][input.name], name)
                end
            end
        elseif has_recycling_category(recipe) and #(recipe.ingredients or {}) == 1 then
            local input = material_for(recipe, "ingredients", recipe.ingredients[1])
            if input ~= nil and input.type == "item" then
                for room, _ in pairs(accepted(recipe)) do
                    reserved[room] = reserved[room] or {}
                    reserved[room][input.name] = true
                end
            end
        end
    end
    local function priority(name, item)
        local origin = raw.recipe[name].recycling_origin
        local prototype = get_prototype(raw, "item", item)
        local seen = {}
        while prototype ~= nil and prototype.orig_name ~= nil and seen[item] == nil do
            seen[item] = true
            item = prototype.orig_name
            prototype = get_prototype(raw, "item", item)
        end
        return (origin.local_source == true and 8 or 0)
            + (origin.base_name == item and 4 or 0)
            + (origin.preferred == true and 2 or 0)
            + (origin.source ~= nil and origin.reversed ~= nil and 1 or 0)
    end
    local function signature(name)
        local result = {}
        for _, entry in pairs(raw.recipe[name].results or {}) do
            local material = material_for(raw.recipe[name], "results", entry)
            if material ~= nil and material.type == "item" then
                table.insert(result, material.name .. ":" .. tostring(entry.amount) .. ":" .. tostring(entry.extra_count_fraction))
            end
        end
        table.sort(result)
        return table.concat(result, ";")
    end
    local function ingredient_count(name)
        return raw.recipe[name].recycling_origin.original_ingredient_count or math.huge
    end
    for room, items in pairs(choices) do
        for item, names in pairs(items) do
            table.sort(names, function(a, b)
                local pa = priority(a, item)
                local pb = priority(b, item)
                if pa ~= pb then return pa > pb end
                local ca, cb = ingredient_count(a), ingredient_count(b)
                return ca < cb or (ca == cb and a < b)
            end)
            if (reserved[room] or {})[item] == nil then
                scopes[names[1]][room] = true
                local best = signature(names[1])
                for i = 2, #names do
                    if priority(names[i], item) == priority(names[1], item)
                        and ingredient_count(names[i]) == ingredient_count(names[1]) and signature(names[i]) ~= best then
                        table.insert(ambiguities, room .. " / " .. item .. ": " .. names[1] .. " or " .. names[i])
                    end
                end
            end
        end
    end
    table.sort(ambiguities)
    return scopes, ambiguities
end

local recycling_pool = {}
for i, entry in pairs(surface_sets.POOL) do
    recycling_pool[i] = {
        name = "propertyrandomizer-recycling-" .. i,
        step = entry.step,
    }
end

local function apply_scopes(scopes)
    local requests = {}
    for name, rooms in pairs(scopes) do
        table.insert(requests, {
            id = name,
            rooms = rooms,
        })
    end
    local plan = surface_sets.plan_growing(requests, surface_sets.room_keys(), recycling_pool)
    surface_sets.apply_properties(plan, recycling_pool)
    for i, property in pairs(plan.properties) do
        local prototype = data.raw["surface-property"][property.name]
        prototype.localised_name = { "propertyrandomizer-name.numbered", { "surface-property-name.propertyrandomizer-recycling-region" }, tostring(i) }
        prototype.localised_unit_key = "surface-property-unit.propertyrandomizer-recycling-region"
    end
    -- An empty room set is intentionally unavailable; keep its prototype for later assignments.
    local nowhere = "propertyrandomizer-recycling-unavailable"
    data:extend({
        {
            type = "surface-property",
            name = nowhere,
            default_value = 0,
        },
    })
    for name, rooms in pairs(scopes) do
        local recipe = data.raw.recipe[name]
        recipe.surface_conditions = plan.conditions[name] or { { property = nowhere, min = 1, max = 1 } }
        recipe.recycling_rooms = table.deepcopy(rooms)
    end
end

local function physical_entry(_, _, entry)
    return entry
end

-- Prepare all local alternatives before the initial graph, including alternatives inactive until identities move.
-- Existing global recycling remains a fallback outside the winning local recipe's rooms.
recycling.prepare_planetary = function()
    local raw = data.raw
    local original = recycling.vanilla(raw)
    if next(original) == nil then
        return
    end
    for _, recipe in pairs(raw.recipe) do
        if recipe.recycling_origin ~= nil then
            return
        end
    end
    local all_rooms = {}
    for _, room in pairs(surface_sets.room_keys()) do
        all_rooms[room] = true
    end
    local preferred = {}
    for _, entry in pairs(original) do
        if entry.source ~= nil then
            preferred[entry.source] = true
        end
    end
    local function origin(source, reversed, rooms, is_local)
        -- Capture complexity before ingredient randomization, so graph selection and regeneration agree.
        -- Count distinct materials, including fluids; quantities and duplicate rows do not add complexity.
        local original_source = raw.recipe[source]
        local ingredient_count = original_source ~= nil and 0 or nil
        local materials = {}
        for _, ingredient in pairs(original_source ~= nil and original_source.ingredients or {}) do
            local key = (ingredient.type or "item") .. ":" .. ingredient.name
            if materials[key] == nil then
                materials[key] = true
                ingredient_count = ingredient_count + 1
            end
        end
        local base_name = source
        local was_preferred = false
        local seen = {}
        while base_name ~= nil and seen[base_name] == nil do
            seen[base_name] = true
            was_preferred = was_preferred or preferred[base_name] == true
            local ancestor = raw.recipe[base_name]
            if ancestor == nil or ancestor.orig_name == nil then break end
            base_name = ancestor.orig_name
        end
        return {
            source = source,
            reversed = reversed,
            available = table.deepcopy(rooms),
            local_source = is_local,
            base_name = base_name,
            preferred = was_preferred,
            original_ingredient_count = ingredient_count,
        }
    end
    local additions = {}
    for _, name in pairs(sorted_keys(raw.recipe)) do
        local source = raw.recipe[name]
        if original[name] == nil and (source.dupe_number ~= nil or source.intermediate_planet ~= nil) then
            local recipe, reversed = reverse_recipe(raw, source)
            if recipe ~= nil then
                recipe.name = "propertyrandomizer-local-recycling-" .. name
                assert(raw.recipe[recipe.name] == nil, "Recycling variant name already exists: " .. recipe.name)
                recipe.recycling_origin = origin(name, reversed, surface_sets.accepted(source), true)
                recipe.enabled = true
                additions[recipe.name] = recipe
            end
        end
    end
    if next(additions) == nil then
        return
    end
    for name, entry in pairs(original) do
        raw.recipe[name].recycling_origin = origin(entry.source, entry.reversed, all_rooms, false)
    end
    for name, recipe in pairs(additions) do
        raw.recipe[name] = recipe
    end
    vanilla_cache = {}
    apply_scopes(recycling.planetary_scopes(raw, physical_entry, surface_sets.accepted))
end

-- Keep every candidate's name and source; only its surface scope competes with other candidates.
recycling.regenerate_planetary = function(old_raw)
    local raw = data.raw
    for _, name in pairs(sorted_keys(raw.recipe)) do
        local previous = raw.recipe[name]
        local origin = previous.recycling_origin
        if origin ~= nil then
            local source = raw.recipe[origin.source]
            local recipe = source ~= nil and origin.reversed ~= nil and reverse_recipe(raw, source) or nil
            if recipe == nil then
                local input = previous.ingredients and previous.ingredients[1]
                local item = input ~= nil and input.type == "item" and get_prototype(raw, "item", input.name) or nil
                recipe = item ~= nil and self_recycling_recipe(raw, item) or nil
            end
            if recipe ~= nil then
                recipe.name = name
                recipe.recycling_origin = table.deepcopy(origin)
                recipe.enabled = true
                raw.recipe[name] = recipe
            else
                -- A fluid took this position; its candidate has no physical recycler input.
                previous.results = {}
                previous.recycling_origin.available = {}
            end
        end
    end
    local scopes, ambiguities = recycling.planetary_scopes(raw, physical_entry, surface_sets.accepted)
    apply_scopes(scopes)
    log("Planet recycling: " .. #ambiguities .. " equally ranked alternatives with different returns")
    for i = 1, math.min(#ambiguities, 12) do
        log("Planet recycling ambiguity: " .. ambiguities[i])
    end
    for _, technology in pairs(raw.technology or {}) do
        local kept = {}
        for _, effect in pairs(technology.effects or {}) do
            local recipe = effect.type == "unlock-recipe" and raw.recipe[effect.recipe] or nil
            if recipe == nil or recipe.recycling_origin == nil then
                table.insert(kept, effect)
            end
        end
        if technology.effects ~= nil then
            technology.effects = kept
        end
    end
end

return recycling
