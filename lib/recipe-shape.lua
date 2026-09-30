-- Recipe shapes: how many distinct ingredients a recipe takes, and how many of them are fluids (config.recipe_shapes; the plan is in notes/recipe-shape-plan.md)
-- A shape is { count, num_fluids }. Unified recipe randomization plans one per recipe before it chooses anything (the recipe-ingredients handler's before_heads), so the model learns which machines a recipe needs before promising on top of it, and then fills that many slots of each form (slot_forms in randomizations/graph/recipe-cost.lua)
-- Counts come from the mod's own walk (lib/random/randnum.lua); fluid slots are gained or lost by the chances in constants.recipe_shape, favoring gains, since vanilla's fluids are underused (94 of 819 ingredient slots in base + Space Age)
-- Caps come from data: the fluid input boxes of the recipe's crafters (through the logic's recipe-category nodes), furnaces taking one item and one fluid at most (auxiliary/furnace-recipe-selection.html in the API docs), AssemblingMachinePrototype::ingredient_count, and the largest count any recipe in data.raw has
-- Only gains change the model (the recipe's category node): a recipe planned with fewer fluids keeps its vanilla node, which is merely pessimistic, and its vanilla ingredients always fit whatever the search does
-- Shared by the recipe-ingredients handler (which plans and searches) and the recipe-category handler (which checks a planned recipe fits a category's furnaces and fluid boxes), so the two agree

local constants = require("helper-tables/constants")
local randnum = require("lib/random/randnum")
local rng = require("lib/random/rng")

local recipe_shape = {}

-- Plans by recipe name for the current attempt, set by the recipe-ingredients handler and read back by the recipe-category handler
local plans = {}

recipe_shape.reset = function()
    plans = {}
end

recipe_shape.set_plan = function(recipe_name, plan)
    plans[recipe_name] = plan
end

-- The plan for a recipe, or nil when it has none (shapes off, or the recipe isn't randomized)
recipe_shape.planned = function(recipe_name)
    return plans[recipe_name]
end

local function clamp(value, low, high)
    return math.max(low, math.min(high, value))
end

-- How many of a list of ingredients are items and fluids, as { num_items, num_fluids, count }, by the form an entry has in the game when it says one (form, see search_for_ings in randomizations/graph/recipe-cost.lua), else its type
recipe_shape.count_forms = function(ings)
    local counts = {
        num_items = 0,
        num_fluids = 0,
        count = 0,
    }
    for _, ing in pairs(ings or {}) do
        if (ing.form or ing.type) == "fluid" then
            counts.num_fluids = counts.num_fluids + 1
        else
            counts.num_items = counts.num_items + 1
        end
        counts.count = counts.count + 1
    end
    return counts
end

-- The most ingredients any recipe takes, at least 1: the cap on planned counts, so no mod gets shapes bigger than it ships
recipe_shape.largest_count = function(recipes)
    local largest = 1
    for _, recipe in pairs(recipes) do
        largest = math.max(largest, #(recipe.ingredients or {}))
    end
    return largest
end

-- The largest fluid amount any recipe takes, at least 1: the cap on the fluid amounts the search picks, which would otherwise ask for tens of thousands of a cheap fluid per craft
recipe_shape.largest_fluid_amount = function(recipes)
    local largest = 1
    for _, recipe in pairs(recipes) do
        for _, ing in pairs(recipe.ingredients or {}) do
            if ing.type == "fluid" and type(ing.amount) == "number" then
                largest = math.max(largest, ing.amount)
            end
        end
    end
    return largest
end

-- How many recipes take each material (each recipe counting once per material), as key(ing) --> count; recipes is_recycling accepts are left out
recipe_shape.ingredient_uses = function(recipes, key, is_recycling)
    local uses = {}
    for _, recipe in pairs(recipes) do
        if is_recycling == nil or not is_recycling(recipe) then
            local seen = {}
            for _, ing in pairs(recipe.ingredients or {}) do
                local ing_key = key(ing)
                if not seen[ing_key] then
                    seen[ing_key] = true
                    uses[ing_key] = (uses[ing_key] or 0) + 1
                end
            end
        end
    end
    return uses
end

-- The median of a list of numbers (the lower middle one of an even count), or nil for an empty list
recipe_shape.median = function(values)
    local sorted = {}
    for _, value in pairs(values) do
        table.insert(sorted, value)
    end
    if #sorted == 0 then
        return nil
    end
    table.sort(sorted)
    return sorted[math.floor((#sorted + 1) / 2)]
end

-- Pool entries for one ingredient edge of a fluid some recipes take: about the median fluid's share, so a fluid used once is proposed about as often as the median one, at most max_copies
recipe_shape.copies_for = function(uses, median, max_copies)
    if uses == nil or uses <= 0 or median == nil then
        return 1
    end
    return clamp(math.ceil(median / uses), 1, max_copies)
end

-- The change in fluid slots for a recipe with this many fluids: a gain (fluid_gain_chance, and a second on top with fluid_second_gain_chance), a loss when it has one (fluid_loss_chance), or none
recipe_shape.draw_fluid_change = function(rng_key, fluids, chances)
    local roll = rng.value(rng_key)
    if roll < chances.fluid_gain_chance then
        if rng.value(rng_key) < chances.fluid_second_gain_chance then
            return 2
        end
        return 1
    elseif fluids > 0 and roll < chances.fluid_gain_chance + chances.fluid_loss_chance then
        return -1
    end
    return 0
end

-- A new count for a recipe with this many ingredients, by the mod's walk (more ingredients are the worse direction), within 1 .. count_max
recipe_shape.draw_count = function(rng_key, count, count_max, chances)
    if count_max <= 1 then
        return 1
    end
    local drawn = randnum.rand({
        key = rng_key,
        dummy = count,
        abs_min = 1,
        abs_max = count_max,
        range = chances.count_range,
        variance = chances.count_range,
        rounding = "pure_discrete",
        dir = -1,
    })
    return clamp(math.floor(drawn + 0.5), 1, count_max)
end

-- Plans a recipe's shape
-- params: vanilla = { count, num_fluids } (the recipe's ingredients, in the forms its positions have), kept = { num_items, num_fluids } (ingredients the search leaves alone), caps = { count, num_fluids, num_items } (the largest count, the crafters' input fluid boxes, and their item ingredients), delta = first pass's { input, output } on the recipe (fluids the game's recipe has beyond its positions' forms), furnace = whether a furnace crafts it, chances = constants.recipe_shape, rng_key, and optionally draw_count(count, count_max) and draw_fluid_change(fluids) in place of the draws (tests)
-- Returns { count, num_fluids, num_items, model_fluids, gain, vanilla, kept, caps, delta, furnace }: model_fluids is what the model's category node must serve (vanilla's fluids or more), and gain how many fluid slots that is beyond vanilla's
-- Returns nil when nothing crafts the recipe at all (no fluid cap)
recipe_shape.plan = function(params)
    local vanilla = params.vanilla
    local kept = params.kept
    local caps = params.caps
    local delta = params.delta or {
        input = 0,
        output = 0,
    }
    local chances = params.chances or constants.recipe_shape
    if caps.num_fluids == nil or caps.num_fluids < 0 then
        return nil
    end
    local draw_count = params.draw_count or function(count, count_max)
        return recipe_shape.draw_count(params.rng_key, count, count_max, chances)
    end
    local draw_fluid_change = params.draw_fluid_change or function(fluids)
        return recipe_shape.draw_fluid_change(params.rng_key, fluids, chances)
    end

    local furnace = params.furnace == true
    local count_max = caps.count
    if furnace then
        count_max = math.min(count_max, 2)
    end
    count_max = math.max(count_max, kept.num_items + kept.num_fluids, 1)
    local count = clamp(draw_count(vanilla.count, count_max), math.max(kept.num_items + kept.num_fluids, 1), count_max)

    -- Fluid slots the crafters have left for the positions' forms, once first pass's fluids are counted, and at most max_fluids
    local fluid_max = math.min(count, caps.num_fluids - (delta.input or 0), chances.max_fluids or math.huge)
    if furnace then
        fluid_max = math.min(fluid_max, 1)
    end
    fluid_max = math.max(fluid_max, kept.num_fluids)
    local fluids = clamp(vanilla.num_fluids + draw_fluid_change(vanilla.num_fluids), kept.num_fluids, fluid_max)

    local items_max = caps.num_items or math.huge
    if furnace then
        items_max = math.min(items_max, 1)
    end
    local items = math.max(math.min(count - fluids, items_max), kept.num_items)
    count = fluids + items

    return {
        count = count,
        num_fluids = fluids,
        num_items = items,
        model_fluids = math.max(vanilla.num_fluids, fluids),
        gain = math.max(0, fluids - vanilla.num_fluids),
        vanilla = vanilla,
        kept = kept,
        caps = caps,
        delta = delta,
        furnace = furnace,
    }
end

-- The plan with one fluid slot fewer, for when promotion refuses the category its fluids need: the slot becomes an item slot, within the items cap
recipe_shape.back_off = function(plan)
    local fluids = plan.num_fluids - 1
    local items_max = plan.caps.num_items or math.huge
    if plan.furnace == true then
        items_max = math.min(items_max, 1)
    end
    local items = math.min(plan.num_items + 1, items_max)
    return {
        count = fluids + items,
        num_fluids = fluids,
        num_items = items,
        model_fluids = math.max(plan.vanilla.num_fluids, fluids),
        gain = math.max(0, fluids - plan.vanilla.num_fluids),
        vanilla = plan.vanilla,
        kept = plan.kept,
        caps = plan.caps,
        delta = plan.delta,
        furnace = plan.furnace,
    }
end

-- The shapes to try in turn when the search finds nothing for the planned one: the plan, then one fluid slot fewer at a time down to vanilla's fluids, then vanilla's own shape (which its vanilla ingredients always fit)
recipe_shape.ladder = function(plan)
    local rungs = {}
    local seen = {}
    local function add(count, fluids)
        local rung_key = count .. "/" .. fluids
        if not seen[rung_key] then
            seen[rung_key] = true
            table.insert(rungs, {
                count = count,
                num_fluids = fluids,
            })
        end
    end
    add(plan.count, plan.num_fluids)
    for fluids = plan.num_fluids - 1, plan.vanilla.num_fluids, -1 do
        add(plan.count, fluids)
    end
    add(plan.vanilla.count, plan.vanilla.num_fluids)
    return rungs
end

-- The forms of the slots the search fills for a shape, fluids first, once the kept ingredients ({ num_items, num_fluids }) are taken out; nil when the shape can't hold them
recipe_shape.slot_forms = function(shape, kept)
    local fluids = shape.num_fluids - kept.num_fluids
    local items = shape.count - shape.num_fluids - kept.num_items
    if fluids < 0 or items < 0 then
        return nil
    end
    local forms = {}
    for _ = 1, fluids do
        table.insert(forms, "fluid")
    end
    for _ = 1, items do
        table.insert(forms, "item")
    end
    return forms
end

-- A distribution (value --> how many) as "1:61 2:85 ...", in value order
recipe_shape.describe = function(distribution)
    local values = {}
    for value, _ in pairs(distribution) do
        table.insert(values, value)
    end
    table.sort(values)
    local parts = {}
    for _, value in pairs(values) do
        table.insert(parts, value .. ":" .. distribution[value])
    end
    return table.concat(parts, " ")
end

return recipe_shape
