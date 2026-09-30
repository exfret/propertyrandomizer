-- Plain-Lua regression tests for lib/furnace-selection.lua (not loaded by the mod)
-- Run from the mod root: lua lib/test-furnace-selection.lua
-- Furnaces pick their recipe by ingredient (doc-html/auxiliary/furnace-recipe-selection.html), so recipes one furnace crafts mustn't share one

local furnace_selection = require("lib/furnace-selection")

local num_passed = 0
local function test(name, fn)
    data = {
        raw = {
            furnace = {},
            recipe = {},
        },
    }
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end

local function add_furnace(name, categories)
    data.raw.furnace[name] = {
        type = "furnace",
        name = name,
        crafting_categories = categories,
    }
end

local function add_recipe(name, categories, ingredients)
    data.raw.recipe[name] = {
        type = "recipe",
        name = name,
        categories = categories,
        ingredients = ingredients,
    }
end

local function item(name)
    return {
        type = "item",
        name = name,
        amount = 1,
    }
end

local function fluid(name)
    return {
        type = "fluid",
        name = name,
        amount = 10,
    }
end

test("recipes one furnace crafts collide when they share their item", function()
    add_furnace("oven", { "baking" })
    add_recipe("bread", { "baking" }, { item("dough") })
    add_recipe("toast", { "baking" }, { item("dough") })
    add_recipe("cake", { "baking" }, { item("batter") })
    local collisions = furnace_selection.collisions(data.raw.recipe)
    assert(#collisions == 1)
    assert(collisions[1].ingredient == "item-dough")
    assert(#collisions[1].recipes == 2)
end)

test("recipes no common furnace crafts don't collide, even with the same item", function()
    add_furnace("oven", { "baking" })
    add_furnace("kiln", { "firing" })
    add_recipe("bread", { "baking" }, { item("dough") })
    add_recipe("pot", { "firing" }, { item("dough") })
    -- Assemblers pick no recipe by input, so their categories don't count
    add_recipe("dumpling", { "cooking" }, { item("dough") })
    assert(#furnace_selection.collisions(data.raw.recipe) == 0)
end)

test("one furnace crafting several categories pools them", function()
    add_furnace("oven", { "baking", "roasting" })
    add_recipe("bread", { "baking" }, { item("dough") })
    add_recipe("crust", { "roasting" }, { item("dough") })
    assert(#furnace_selection.collisions(data.raw.recipe) == 1)
end)

test("a recipe selects by its item, or by its fluid when it has no item", function()
    add_furnace("still", { "boiling" })
    add_recipe("steam", { "boiling" }, { fluid("water") })
    add_recipe("broth", { "boiling" }, { fluid("water"), item("bone") })
    -- steam selects by water, broth by bone
    assert(#furnace_selection.collisions(data.raw.recipe) == 0)
    add_recipe("vapor", { "boiling" }, { fluid("water") })
    local collisions = furnace_selection.collisions(data.raw.recipe)
    assert(#collisions == 1 and collisions[1].ingredient == "fluid-water")
end)

test("recipes a furnace can't run select nothing", function()
    -- Only a single item, a single fluid, or one of each can run in a furnace
    assert(#furnace_selection.selecting_ingredients({ item("a"), item("b") }) == 0)
    assert(#furnace_selection.selecting_ingredients({ fluid("a"), fluid("b") }) == 0)
    assert(furnace_selection.selecting_ingredients({ item("a") })[1] == "item-a")
    assert(furnace_selection.selecting_ingredients({ fluid("f"), item("a") })[1] == "item-a")
end)

test("categories can be given for where recipes will end up", function()
    add_furnace("oven", { "baking" })
    add_recipe("bread", { "baking" }, { item("dough") })
    add_recipe("dumpling", { "cooking" }, { item("dough") })
    assert(#furnace_selection.collisions(data.raw.recipe) == 0)
    local collisions = furnace_selection.collisions(data.raw.recipe, function(recipe)
        return { "baking" }
    end)
    assert(#collisions == 1)
end)

test("only collisions the original game didn't have count as new", function()
    add_furnace("oven", { "baking" })
    -- The original game already has bread and toast colliding, like a mod whose recycling the recycler generates over
    add_recipe("bread", { "baking" }, { item("dough") })
    add_recipe("toast", { "baking" }, { item("dough") })
    add_recipe("cake", { "baking" }, { item("batter") })
    add_recipe("pie", { "baking" }, { item("crust") })
    local old_raw = {
        furnace = data.raw.furnace,
        recipe = {},
    }
    for name, recipe in pairs(data.raw.recipe) do
        old_raw.recipe[name] = recipe
    end
    assert(#furnace_selection.new_collisions(old_raw) == 0)
    -- Randomization gives pie cake's ingredient
    add_recipe("pie", { "baking" }, { item("batter") })
    local new = furnace_selection.new_collisions(old_raw)
    assert(#new == 1 and new[1].ingredient == "item-batter")
    -- And toast now collides with cake too; the old bread/toast pair doesn't count, but a collision with a new pair in it does
    add_recipe("toast", { "baking" }, { item("batter") })
    add_recipe("bread", { "baking" }, { item("batter") })
    new = furnace_selection.new_collisions(old_raw)
    assert(#new == 1 and #new[1].recipes == 4)
end)

test("the tracker only blocks ingredients used by recipes a common furnace crafts", function()
    add_furnace("oven", { "baking", "roasting" })
    add_furnace("kiln", { "firing" })
    add_recipe("bread", { "baking" }, { item("dough") })
    add_recipe("crust", { "roasting" }, { item("flour") })
    add_recipe("pot", { "firing" }, { item("clay") })
    add_recipe("dumpling", { "cooking" }, { item("dough") })
    local tracker = furnace_selection.tracker()
    tracker.take(data.raw.recipe.bread, item("dough"))
    -- The oven crafts crust too, so dough is taken there, but not in the kiln or for assemblers
    assert(tracker.is_taken(tracker.pools_of(data.raw.recipe.crust), item("dough")))
    assert(not tracker.is_taken(tracker.pools_of(data.raw.recipe.pot), item("dough")))
    assert(not tracker.is_taken(tracker.pools_of(data.raw.recipe.dumpling), item("dough")))
    -- A recipe moved into the kiln's category shares its pool
    local moved = furnace_selection.tracker(function(recipe)
        if recipe.name == "dumpling" then
            return { "firing" }
        end
    end)
    moved.take(data.raw.recipe.pot, item("clay"))
    assert(moved.is_taken(moved.pools_of(data.raw.recipe.dumpling), item("clay")))
end)

test("a reserved ingredient is held for its recipe until it's placed, since a fallback to it doesn't ask the tracker", function()
    add_furnace("oven", { "baking", "roasting" })
    add_recipe("bread", { "baking" }, { item("dough") })
    add_recipe("crust", { "roasting" }, { item("flour") })
    local tracker = furnace_selection.tracker()
    -- Bread may fall back to dough, so crust can't take dough in the oven meanwhile
    tracker.reserve(data.raw.recipe.bread, item("dough"))
    assert(tracker.is_taken(tracker.pools_of(data.raw.recipe.crust), item("dough"), data.raw.recipe.crust))
    -- Bread itself can still choose it
    assert(not tracker.is_taken(tracker.pools_of(data.raw.recipe.bread), item("dough"), data.raw.recipe.bread))
    -- A later reservation doesn't take it over
    tracker.reserve(data.raw.recipe.crust, item("dough"))
    assert(tracker.is_taken(tracker.pools_of(data.raw.recipe.crust), item("dough"), data.raw.recipe.crust))
    -- Once bread is placed with something else, dough is free again
    tracker.release(data.raw.recipe.bread)
    tracker.take(data.raw.recipe.bread, item("rye"))
    assert(not tracker.is_taken(tracker.pools_of(data.raw.recipe.crust), item("dough"), data.raw.recipe.crust))
    assert(tracker.is_taken(tracker.pools_of(data.raw.recipe.crust), item("rye"), data.raw.recipe.crust))
end)

print(num_passed .. " tests passed")
