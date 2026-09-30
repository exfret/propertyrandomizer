-- Plain-Lua regression tests for recipe shapes (lib/recipe-shape.lua), not loaded by the mod
-- Run from the mod root: lua lib/test-recipe-shape.lua

-- Stand-ins for the Factorio environment: the draws are replaced in every test that plans, so randnum and rng only need to load
local rolls = {}
local rng = {
    value = function(rng_key)
        local roll = table.remove(rolls, 1)
        assert(roll ~= nil, "test asked for more rolls than it gave")
        return roll
    end,
    key = function(params)
        return params.id
    end,
}
package.loaded["lib/random/rng"] = rng
local randnum_calls = {}
package.loaded["lib/random/randnum"] = {
    rand = function(params)
        table.insert(randnum_calls, params)
        return params.dummy
    end,
}
config = {}

local constants = require("helper-tables/constants")
local recipe_shape = require("lib/recipe-shape")

local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local chances = constants.recipe_shape

local function plan_with(params)
    params.chances = params.chances or chances
    params.kept = params.kept or {
        num_items = 0,
        num_fluids = 0,
    }
    params.caps = params.caps or {
        count = 8,
        num_fluids = 4,
        num_items = 65535,
    }
    params.draw_count = params.draw_count or function(count, count_max)
        return count
    end
    params.draw_fluid_change = params.draw_fluid_change or function(fluids)
        return 0
    end
    return recipe_shape.plan(params)
end

test("the chances favor gains and only a recipe with a fluid can lose one", function()
    assert(chances.fluid_gain_chance > chances.fluid_loss_chance)
    assert(chances.fluid_gain_chance + chances.fluid_loss_chance <= 1)
    rolls = { chances.fluid_gain_chance - 0.01, chances.fluid_second_gain_chance + 0.01 }
    assert(recipe_shape.draw_fluid_change("k", 0, chances) == 1)
    rolls = { chances.fluid_gain_chance - 0.01, chances.fluid_second_gain_chance - 0.01 }
    assert(recipe_shape.draw_fluid_change("k", 0, chances) == 2)
    rolls = { chances.fluid_gain_chance + 0.01 }
    assert(recipe_shape.draw_fluid_change("k", 0, chances) == 0, "a recipe without fluids can't lose one")
    rolls = { chances.fluid_gain_chance + 0.01 }
    assert(recipe_shape.draw_fluid_change("k", 1, chances) == -1)
    rolls = { chances.fluid_gain_chance + chances.fluid_loss_chance + 0.01 }
    assert(recipe_shape.draw_fluid_change("k", 1, chances) == 0)
end)

test("the count draw is the mod's walk, more ingredients being the worse direction, within 1 and the cap", function()
    randnum_calls = {}
    assert(recipe_shape.draw_count("k", 3, 8, chances) == 3)
    local params = randnum_calls[1]
    assert(params.dummy == 3 and params.abs_min == 1 and params.abs_max == 8 and params.dir == -1 and params.rounding == "pure_discrete")
    assert(params.range == chances.count_range)
    assert(recipe_shape.draw_count("k", 3, 1, chances) == 1)
    assert(#randnum_calls == 1, "a cap of 1 needs no draw")
end)

test("kept ingredients always fit the plan", function()
    local plan = plan_with({
        vanilla = { count = 4, num_fluids = 1 },
        kept = { num_items = 2, num_fluids = 1 },
        draw_count = function() return 1 end,
        draw_fluid_change = function() return -1 end,
    })
    assert(plan.count == 3 and plan.num_items == 2 and plan.num_fluids == 1, plan.count .. "/" .. plan.num_fluids)
end)

test("fluid slots stop at the boxes the crafters have left after first pass's fluids", function()
    local plan = plan_with({
        vanilla = { count = 3, num_fluids = 0 },
        caps = { count = 8, num_fluids = 2, num_items = 65535 },
        delta = { input = 1, output = 0 },
        draw_fluid_change = function() return 2 end,
    })
    assert(plan.num_fluids == 1 and plan.num_items == 2 and plan.count == 3)
    assert(plan.model_fluids == 1 and plan.gain == 1)
end)

test("a plan gives at most max_fluids fluid slots, whatever the crafters' boxes", function()
    local plan = plan_with({
        vanilla = { count = 6, num_fluids = 2 },
        caps = { count = 8, num_fluids = 9, num_items = 65535 },
        chances = {
            fluid_gain_chance = 0.2,
            fluid_second_gain_chance = 0.15,
            fluid_loss_chance = 0.1,
            count_range = "small",
            max_fluids = 3,
        },
        draw_count = function() return 6 end,
        draw_fluid_change = function() return 2 end,
    })
    assert(plan.num_fluids == 3 and plan.num_items == 3)
end)

test("counting forms goes by the form an entry has in the game when it says one", function()
    -- The forms, as recipe shapes name them
    local FLUID = "fluid"
    local ITEM = "item"
    local function entry(entry_type, name, form)
        return {
            type = entry_type,
            name = name,
            form = form,
        }
    end
    local counts = recipe_shape.count_forms({
        entry(ITEM, "a"),
        entry(ITEM, "b", FLUID),
        entry(FLUID, "c", ITEM),
        entry(FLUID, "d"),
    })
    assert(counts.num_items == 2 and counts.num_fluids == 2 and counts.count == 4)
end)

test("a furnace recipe takes one item and one fluid at most", function()
    local plan = plan_with({
        vanilla = { count = 1, num_fluids = 0 },
        furnace = true,
        draw_count = function(count, count_max)
            assert(count_max == 2)
            return 5
        end,
        draw_fluid_change = function() return 2 end,
    })
    assert(plan.count == 2 and plan.num_items == 1 and plan.num_fluids == 1)
end)

test("the items cap and the largest count bound the shape", function()
    local plan = plan_with({
        vanilla = { count = 3, num_fluids = 0 },
        caps = { count = 8, num_fluids = 4, num_items = 2 },
        draw_count = function(count, count_max)
            assert(count_max == 8)
            return 7
        end,
        draw_fluid_change = function() return 1 end,
    })
    assert(plan.num_fluids == 1 and plan.num_items == 2 and plan.count == 3)
    plan = plan_with({
        vanilla = { count = 3, num_fluids = 0 },
        caps = { count = 5, num_fluids = 4, num_items = 65535 },
        draw_count = function() return 9 end,
    })
    assert(plan.count == 5)
end)

test("only gains change the model", function()
    local plan = plan_with({
        vanilla = { count = 3, num_fluids = 1 },
        draw_fluid_change = function() return -1 end,
    })
    assert(plan.num_fluids == 0 and plan.model_fluids == 1 and plan.gain == 0)
    plan = plan_with({
        vanilla = { count = 3, num_fluids = 0 },
        draw_fluid_change = function() return 2 end,
    })
    assert(plan.num_fluids == 2 and plan.model_fluids == 2 and plan.gain == 2)
end)

test("nothing is planned for a recipe nothing crafts", function()
    assert(plan_with({
        vanilla = { count = 2, num_fluids = 0 },
        caps = { count = 8, num_fluids = -1, num_items = 65535 },
    }) == nil)
end)

test("backing off turns a fluid slot into an item slot, within the items cap", function()
    local plan = plan_with({
        vanilla = { count = 2, num_fluids = 0 },
        caps = { count = 8, num_fluids = 4, num_items = 3 },
        draw_count = function() return 4 end,
        draw_fluid_change = function() return 2 end,
    })
    assert(plan.count == 4 and plan.num_fluids == 2 and plan.num_items == 2)
    local backed = recipe_shape.back_off(plan)
    assert(backed.count == 4 and backed.num_fluids == 1 and backed.num_items == 3 and backed.gain == 1 and backed.model_fluids == 1)
    backed = recipe_shape.back_off(backed)
    assert(backed.count == 3 and backed.num_fluids == 0 and backed.num_items == 3 and backed.gain == 0, "the items cap shrinks the count")
end)

test("the ladder goes from the plan down to vanilla's fluids, then to vanilla's shape", function()
    local plan = plan_with({
        vanilla = { count = 3, num_fluids = 0 },
        draw_count = function() return 4 end,
        draw_fluid_change = function() return 2 end,
    })
    local rungs = recipe_shape.ladder(plan)
    assert(#rungs == 4)
    assert(rungs[1].count == 4 and rungs[1].num_fluids == 2)
    assert(rungs[2].count == 4 and rungs[2].num_fluids == 1)
    assert(rungs[3].count == 4 and rungs[3].num_fluids == 0)
    assert(rungs[4].count == 3 and rungs[4].num_fluids == 0)
    plan = plan_with({
        vanilla = { count = 3, num_fluids = 1 },
        draw_count = function() return 2 end,
        draw_fluid_change = function() return -1 end,
    })
    rungs = recipe_shape.ladder(plan)
    assert(#rungs == 2 and rungs[1].count == 2 and rungs[1].num_fluids == 0 and rungs[2].count == 3 and rungs[2].num_fluids == 1)
    plan = plan_with({
        vanilla = { count = 3, num_fluids = 1 },
    })
    assert(#recipe_shape.ladder(plan) == 1, "vanilla's shape is one rung")
end)

test("slot forms leave out the kept ingredients, fluids first, or say the shape can't hold them", function()
    local forms = recipe_shape.slot_forms({ count = 4, num_fluids = 2 }, { num_items = 1, num_fluids = 1 })
    assert(#forms == 2 and forms[1] == "fluid" and forms[2] == "item")
    assert(recipe_shape.slot_forms({ count = 2, num_fluids = 0 }, { num_items = 3, num_fluids = 0 }) == nil)
    assert(recipe_shape.slot_forms({ count = 2, num_fluids = 0 }, { num_items = 0, num_fluids = 1 }) == nil)
    assert(#recipe_shape.slot_forms({ count = 1, num_fluids = 1 }, { num_items = 0, num_fluids = 1 }) == 0, "everything kept means nothing to fill")
end)

test("fluids few recipes take get about the median fluid's share of the pool, items one entry", function()
    -- Made-up materials: "wet" and "sour" are fluids, "cog" an item
    local function fluid(name)
        return {
            type = "fluid",
            name = name,
        }
    end
    local function item(name)
        return {
            type = "item",
            name = name,
        }
    end
    local recipes = {
        a = { ingredients = { fluid("wet"), item("cog") } },
        b = { ingredients = { fluid("wet"), fluid("wet") } },
        c = { ingredients = { fluid("salty"), item("cog") } },
        d = { ingredients = { fluid("wet"), fluid("sour") } },
        e = { ingredients = { fluid("sour") }, is_recycling = true },
    }
    local uses = recipe_shape.ingredient_uses(recipes, function(ing)
        return ing.type .. ": " .. ing.name
    end, function(recipe)
        return recipe.is_recycling == true
    end)
    assert(uses["fluid: wet"] == 3, "a recipe counts once per material")
    assert(uses["fluid: salty"] == 1 and uses["fluid: sour"] == 1 and uses["item: cog"] == 2)
    local median = recipe_shape.median({ 3, 1, 1 })
    assert(median == 1)
    assert(recipe_shape.median({ 21, 10, 8, 6 }) == 8, "the lower middle of an even count")
    assert(recipe_shape.median({}) == nil)
    assert(recipe_shape.copies_for(1, 6, 8) == 6)
    assert(recipe_shape.copies_for(21, 6, 8) == 1)
    assert(recipe_shape.copies_for(1, 20, 8) == 8, "capped")
    assert(recipe_shape.copies_for(nil, 6, 8) == 1 and recipe_shape.copies_for(2, nil, 8) == 1)
end)

test("the caps read from data are the largest count and the largest fluid amount", function()
    local recipes = {
        a = { ingredients = { { type = "item", name = "x", amount = 1 }, { type = "fluid", name = "w", amount = 50 } } },
        b = { ingredients = { { type = "item", name = "x", amount = 1 }, { type = "item", name = "y", amount = 2 }, { type = "item", name = "z", amount = 300 } } },
        c = {},
    }
    assert(recipe_shape.largest_count(recipes) == 3)
    assert(recipe_shape.largest_fluid_amount(recipes) == 50, "item amounts don't count")
    assert(recipe_shape.largest_count({}) == 1 and recipe_shape.largest_fluid_amount({}) == 1)
end)

test("plans are kept by recipe name until the next reset", function()
    recipe_shape.reset()
    assert(recipe_shape.planned("x") == nil)
    recipe_shape.set_plan("x", { count = 1 })
    assert(recipe_shape.planned("x").count == 1)
    recipe_shape.reset()
    assert(recipe_shape.planned("x") == nil)
end)

test("a distribution describes itself in value order", function()
    assert(recipe_shape.describe({ [3] = 5, [1] = 2 }) == "1:2 3:5")
    assert(recipe_shape.describe({}) == "")
end)

print(num_passed .. " tests passed")
