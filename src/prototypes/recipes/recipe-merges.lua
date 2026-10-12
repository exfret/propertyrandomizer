-- Recipe merges: a recipe's per-planet versions that randomization left taking and making the same things become one recipe (user, 2026-10-10: "it feels like they could be merged")
-- A version says which recipe it's a version of where it's made (version_of: scaffolds.name_variant for the planetary stages' and independent deposits' versions, src/prototypes/duplicates/dupe-intermediates.lua for planet copies' local intermediates), so a recipe and its versions are a family
-- Recipes of one family with the same ingredients, whatever their amounts, and the same results become one recipe (merges.plan), which:
--   * is the family's own recipe if that's among them, else the one made in the most rooms, keeping its name
--   * is made in every room any of them was made in, in any of their machines (user: "You can have merged ones makeable in every machine"), and is unlocked by every technology that unlocked one of them
--   * takes the kept recipe's amounts, or the cheapest amounts where some ingredient's amounts are RADICAL_RATIO times apart or more, which the log flags (user: "Merge when amounts differ; you can just choose arbitrarily... Flag any cases where the amounts are radically different; in those cases you can just choose what has the lowest cost to be safe")
-- So a merge only adds ways to get things: whatever made one of them in a room makes the merged recipe there
-- The kept recipe lists the ones it took in (merged_versions), so the checks hold it to what they had (merges.into_of)
-- Nothing here reads data.raw or requires another module, so plain Lua can test it (tests/unit/prototypes/recipes/test-recipe-merges.lua) and the checks can read it without a require loop; src/randomizations/unified/recipe-merges.lua puts merges in the game

local merges = {}

-- How far apart an ingredient's amounts may be (its largest over its smallest) before a merge is flagged and takes the cheapest amounts
merges.RADICAL_RATIO = 3

local function sorted_keys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

local function deepcopy(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = deepcopy(v)
    end
    return copy
end

-- The recipe a recipe is a version of (a version of a version names the first recipe, since each version is a copy carrying the field on), or its own name
merges.family_of = function(recipe)
    return recipe.version_of or recipe.name
end

-- Ingredient fields saying how much of it a recipe takes or where it goes in a machine, rather than what it is (FluidIngredientPrototype, ItemIngredientPrototype)
local AMOUNT_FIELDS = {
    amount = true,
    ignored_by_stats = true,
    fluidbox_index = true,
    fluidbox_multiplier = true,
}

-- What an ingredient is: its type and name, with a fluid's temperatures and an item's qualities, as one comparable string
local function ingredient_identity(ingredient)
    local fields = {}
    for field, value in pairs(ingredient) do
        if type(value) ~= "table" and AMOUNT_FIELDS[field] == nil then
            table.insert(fields, tostring(field) .. "=" .. tostring(value))
        end
    end
    table.sort(fields)
    return table.concat(fields, ",")
end
merges.ingredient_identity = ingredient_identity

-- A recipe's results as one comparable string, amounts and chances included
local function results_text(results)
    local texts = {}
    for _, result in pairs(results or {}) do
        local fields = {}
        for field, value in pairs(result) do
            if type(value) ~= "table" then
                table.insert(fields, tostring(field) .. "=" .. tostring(value))
            end
        end
        table.sort(fields)
        table.insert(texts, table.concat(fields, ","))
    end
    table.sort(texts)
    return table.concat(texts, ";")
end

-- What a recipe takes and makes, leaving out the amounts it takes: recipes of one family with the same signature merge
merges.signature = function(recipe)
    local identities = {}
    for _, ingredient in pairs(recipe.ingredients or {}) do
        table.insert(identities, ingredient_identity(ingredient))
    end
    table.sort(identities)
    return table.concat(identities, ";") .. " -> " .. results_text(recipe.results) .. " (main product " .. tostring(recipe.main_product) .. ")"
end

-- Ingredient identity --> amount a recipe takes of it
local function amounts_of(recipe)
    local amounts = {}
    for _, ingredient in pairs(recipe.ingredients or {}) do
        local identity = ingredient_identity(ingredient)
        amounts[identity] = (amounts[identity] or 0) + (ingredient.amount or 0)
    end
    return amounts
end

-- How far apart recipes with one signature take their ingredients: the largest, over ingredients, of an ingredient's largest amount over its smallest, so 1 when they take the same amounts
merges.amount_ratio = function(members)
    local member_amounts = {}
    for i, member in pairs(members) do
        member_amounts[i] = amounts_of(member)
    end
    local ratio = 1
    for _, identity in pairs(sorted_keys(member_amounts[1] or {})) do
        local low
        local high
        for _, amounts in pairs(member_amounts) do
            local amount = amounts[identity] or 0
            low = math.min(low or amount, amount)
            high = math.max(high or amount, amount)
        end
        if low > 0 then
            ratio = math.max(ratio, high / low)
        elseif high > 0 then
            ratio = math.huge
        end
    end
    return ratio
end

-- The recipe among members (one signature, sorted by name) with the cheapest amounts, and how it was told apart:
--   * "fewest": it takes no more of any ingredient than any other does
--   * "prices": it costs the least at price_of(ingredient) per unit (optional; nil for an ingredient without a price, which leaves prices out)
--   * "evenly": its amounts multiply to the least, as if every ingredient cost the same
-- Ties go to the first by name
merges.cheapest = function(members, price_of)
    local member_amounts = {}
    for i, member in pairs(members) do
        member_amounts[i] = amounts_of(member)
    end
    local identities = sorted_keys(member_amounts[1] or {})
    for i, amounts in pairs(member_amounts) do
        local is_fewest = true
        for _, other in pairs(member_amounts) do
            for _, identity in pairs(identities) do
                if amounts[identity] > other[identity] then
                    is_fewest = false
                end
            end
        end
        if is_fewest then
            return members[i], "fewest"
        end
    end
    local function lowest(score_of)
        local best
        local best_score
        for i, amounts in pairs(member_amounts) do
            local score = score_of(amounts)
            if score == nil then
                return nil
            end
            if best_score == nil or score < best_score then
                best = members[i]
                best_score = score
            end
        end
        return best
    end
    if price_of ~= nil then
        -- An ingredient's price by its identity, from the first member's own ingredient table
        local price = {}
        for _, ingredient in pairs(members[1].ingredients or {}) do
            price[ingredient_identity(ingredient)] = price_of(ingredient)
        end
        local by_price = lowest(function(amounts)
            local cost = 0
            for _, identity in pairs(identities) do
                if price[identity] == nil then
                    return nil
                end
                cost = cost + amounts[identity] * price[identity]
            end
            return cost
        end)
        if by_price ~= nil then
            return by_price, "prices"
        end
    end
    return lowest(function(amounts)
        local score = 0
        for _, identity in pairs(identities) do
            score = score + math.log(math.max(amounts[identity], 1e-9))
        end
        return score
    end), "evenly"
end

local function size(set)
    local num = 0
    for _, _ in pairs(set) do
        num = num + 1
    end
    return num
end

local function categories_of(recipe)
    return recipe.categories or { recipe.category or "crafting" }
end

-- The merges for recipes (name --> recipe, like data.raw.recipe), as a list, by family and signature, of:
--   * keeper: the name of the recipe that stays (see the top of this file); members: every name, sorted, the keeper's among them; absorbed: the others
--   * rooms: room key --> true, the members' rooms together; categories: their categories together, the keeper's first; is_enabled: whether one of them is enabled from the start
--   * amounts_from: the member whose ingredients the merged recipe takes; ratio: how far apart their amounts are (merges.amount_ratio); is_flagged: whether that's RADICAL_RATIO or more, so the cheapest amounts were taken; told_apart_by: how the cheapest was found (merges.cheapest), nil otherwise
-- options:
--   * rooms_of(recipe): the rooms accepting the recipe now, room key --> true; a recipe no room accepts (a recipe retired on purpose, see src/randomizations/planetary/rewards.lua) stays as it is
--   * price_of(ingredient): optional, for merges.cheapest
merges.plan = function(recipes, options)
    local groups = {}
    local rooms_of = {}
    for _, name in pairs(sorted_keys(recipes)) do
        local recipe = recipes[name]
        if recipe.hidden ~= true then
            local rooms = options.rooms_of(recipe)
            if next(rooms) ~= nil then
                rooms_of[name] = rooms
                local group_key = merges.family_of(recipe) .. " | " .. merges.signature(recipe)
                groups[group_key] = groups[group_key] or {}
                table.insert(groups[group_key], recipe)
            end
        end
    end
    local plan = {}
    for _, group_key in pairs(sorted_keys(groups)) do
        local members = groups[group_key]
        if #members >= 2 then
            local family = merges.family_of(members[1])
            local keeper
            for _, member in pairs(members) do
                if member.name == family then
                    keeper = member
                end
            end
            if keeper == nil then
                for _, member in pairs(members) do
                    if keeper == nil or size(rooms_of[member.name]) > size(rooms_of[keeper.name]) then
                        keeper = member
                    end
                end
            end
            local merge = {
                keeper = keeper.name,
                members = {},
                absorbed = {},
                rooms = {},
                categories = {},
                is_enabled = false,
                amounts_from = keeper.name,
                ratio = merges.amount_ratio(members),
                is_flagged = false,
            }
            local has_category = {}
            local function add_categories(recipe)
                for _, category in pairs(categories_of(recipe)) do
                    if has_category[category] == nil then
                        has_category[category] = true
                        table.insert(merge.categories, category)
                    end
                end
            end
            add_categories(keeper)
            for _, member in pairs(members) do
                table.insert(merge.members, member.name)
                if member ~= keeper then
                    table.insert(merge.absorbed, member.name)
                    add_categories(member)
                end
                for room_key, _ in pairs(rooms_of[member.name]) do
                    merge.rooms[room_key] = true
                end
                if member.enabled ~= false then
                    merge.is_enabled = true
                end
            end
            if merge.ratio >= merges.RADICAL_RATIO then
                local cheapest, told_apart_by = merges.cheapest(members, options.price_of)
                merge.amounts_from = cheapest.name
                merge.is_flagged = true
                merge.told_apart_by = told_apart_by
            end
            table.insert(plan, merge)
        end
    end
    return plan
end

-- Recipe name --> the recipe it was merged into, for raw's merged recipes (merged_versions)
-- Read once for each table of recipes, since the checks ask for every recipe they check; only merges.apply adds merged recipes, and it starts the reading over
local into_cache = setmetatable({}, {
    __mode = "k",
})
merges.into_of = function(raw)
    local recipes = raw.recipe or {}
    if into_cache[recipes] == nil then
        local into = {}
        for name, recipe in pairs(recipes) do
            for _, record in pairs(recipe.merged_versions or {}) do
                into[record.name] = name
            end
        end
        into_cache[recipes] = into
    end
    return into_cache[recipes]
end

-- Puts a plan (merges.plan) in raw (data.raw, or a test's table with recipes and technologies):
--   * each kept recipe takes the merge's categories, amounts and enabling, and lists the recipes it took in (merged_versions: { name, is_planet_locked }), which go
--   * a technology effect naming a recipe that went names its kept recipe instead, unless the technology has that effect for the kept recipe already (two unlocks of one recipe, say)
-- conditions_of: kept recipe name --> its surface conditions (an empty list for every room), for the kept recipes made in more rooms than before; label_of: kept recipe name --> its localised name, for those named after a planet that are made on more planets now
-- Returns recipe name --> the recipe it was merged into
merges.apply = function(raw, plan, conditions_of, label_of)
    local into = {}
    for _, merge in pairs(plan) do
        local keeper = raw.recipe[merge.keeper]
        local source = raw.recipe[merge.amounts_from]
        local records = keeper.merged_versions or {}
        for _, name in pairs(merge.absorbed) do
            local version = raw.recipe[name]
            -- A recipe with conditions of its own is kept like a planet-locked one (skeleton/protection.lua), except independent deposits' versions of recipes that weren't
            table.insert(records, {
                name = name,
                is_planet_locked = next(version.surface_conditions or {}) ~= nil and version.deposit_local_unlocked ~= true,
            })
            into[name] = merge.keeper
        end
        if source ~= keeper then
            keeper.ingredients = deepcopy(source.ingredients)
            keeper.energy_required = source.energy_required
        end
        keeper.categories = deepcopy(merge.categories)
        keeper.category = nil
        if merge.is_enabled then
            keeper.enabled = true
        end
        local conditions = (conditions_of or {})[merge.keeper]
        if conditions ~= nil then
            keeper.surface_conditions = next(conditions) ~= nil and deepcopy(conditions) or nil
        end
        local label = (label_of or {})[merge.keeper]
        if label ~= nil then
            keeper.localised_name = deepcopy(label)
            keeper.intermediate_planet = nil
        end
        keeper.merged_versions = records
        for _, name in pairs(merge.absorbed) do
            raw.recipe[name] = nil
        end
    end
    for _, technology_name in pairs(sorted_keys(raw.technology or {})) do
        local technology = raw.technology[technology_name]
        local is_affected = false
        -- Effect type and recipe of the effects naming no recipe that went, like "unlock-recipe copper-cable", so a renamed one doesn't repeat one of them
        local has_effect = {}
        for _, effect in pairs(technology.effects or {}) do
            if effect.recipe ~= nil then
                if into[effect.recipe] ~= nil then
                    is_affected = true
                else
                    has_effect[effect.type .. " " .. effect.recipe] = true
                end
            end
        end
        if is_affected then
            local effects = {}
            for _, effect in pairs(technology.effects) do
                local kept_name = effect.recipe ~= nil and into[effect.recipe] or nil
                if kept_name == nil then
                    table.insert(effects, effect)
                elseif has_effect[effect.type .. " " .. kept_name] == nil then
                    has_effect[effect.type .. " " .. kept_name] = true
                    effect.recipe = kept_name
                    table.insert(effects, effect)
                end
            end
            technology.effects = effects
        end
    end
    into_cache[raw.recipe] = nil
    return into
end

return merges
