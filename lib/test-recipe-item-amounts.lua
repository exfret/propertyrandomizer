-- Run from the mod root: lua lib/test-recipe-item-amounts.lua
local amounts = require("lib/recipe-item-amounts")
local recycling = require("lib/recycling")

defines = {
    prototypes = {
        item = {
            item = 0,
            armor = 0,
            ["item-with-inventory"] = 0,
        },
        entity = {},
        equipment = {},
    },
}
local num_passed = 0
local function test(name, fn)
    fn()
    num_passed = num_passed + 1
    print("ok - " .. name)
end
local function fixture()
    return {
        item = {
            plate = {
                type = "item",
                name = "plate",
                stack_size = 1,
            },
            singleton = {
                type = "item",
                name = "singleton",
                flags = { "not-stackable" },
            },
            product = {
                type = "item",
                name = "product",
            },
        },
        armor = {
            suit = {
                type = "armor",
                name = "suit",
                equipment_grid = "test-grid",
            },
        },
        ["item-with-inventory"] = {
            kit = {
                type = "item-with-inventory",
                name = "kit",
            },
        },
        recipe = {},
        fluid = {},
        technology = {},
    }
end
local function entry(name, count)
    return {
        type = "item",
        name = name,
        amount = count,
    }
end

test("late physical identities determine ingredient and result limits", function()
    local raw = fixture()
    raw.recipe.test = {
        ingredients = { entry("suit", 100) },
        results = { entry("singleton", 25) },
    }
    assert(amounts.apply(raw) == 2)
    assert(raw.recipe.test.ingredients[1].amount == 1)
    assert(raw.recipe.test.results[1].amount == 1)
    assert(amounts.apply(raw) == 0)
end)
test("inventory items are constrained without requiring an explicit flag", function()
    local raw = fixture()
    raw.recipe.test = { ingredients = { entry("kit", 11) } }
    assert(amounts.apply(raw) == 1)
    assert(raw.recipe.test.ingredients[1].amount == 1)
end)
test("stackable items and fluids retain their quantities", function()
    local raw = fixture()
    local fluid = {
        type = "fluid",
        name = "suit",
        amount = 100,
    }
    raw.recipe.test = {
        ingredients = { entry("plate", 4173) },
        results = { fluid },
    }
    assert(amounts.apply(raw) == 0)
    assert(raw.recipe.test.ingredients[1].amount == 4173 and fluid.amount == 100)
end)
test("ranged outputs keep their probabilities within a one-item maximum", function()
    local raw = fixture()
    local product = {
        type = "item",
        name = "suit",
        amount_min = 0,
        amount_max = 25,
        independent_probability = 0.2,
    }
    raw.recipe.test = { results = { product } }
    assert(amounts.apply(raw) == 1)
    assert(product.amount_min == 0 and product.amount_max == 1)
    assert(product.independent_probability == 0.2)
end)
test("an extra fractional item cannot be added to a guaranteed non-stackable item", function()
    local raw = fixture()
    local product = entry("suit", 1)
    product.extra_count_fraction = 0.25
    raw.recipe.test = { results = { product } }
    assert(amounts.apply(raw) == 1)
    assert(product.amount == 1 and product.extra_count_fraction == 0)
end)
test("fractional recycling of one non-stackable item remains fractional", function()
    local raw = fixture()
    local product = entry("suit", 0)
    product.extra_count_fraction = 0.25
    raw.recipe.test = { results = { product } }
    assert(amounts.apply(raw) == 0)
    assert(product.amount == 0 and product.extra_count_fraction == 0.25)
end)
test("regeneration corrects the source ingredient before reversing its amount", function()
    local raw = fixture()
    raw.recipe.product = {
        name = "product",
        ingredients = { entry("suit", 100) },
        results = { entry("product", 1) },
    }
    data = { raw = raw }
    for name, generated in pairs(recycling.generate(raw)) do
        raw.recipe[name] = generated.recipe
    end
    recycling.regenerate(raw)
    assert(raw.recipe.product.ingredients[1].amount == 1)
    local result = raw.recipe["product-recycling"].results[1]
    assert(result.name == "suit" and result.amount == 0 and result.extra_count_fraction == 0.25)
end)
print(num_passed .. " recipe item amount tests passed")
