-- Run from the mod root: lua tests/unit/config/test-graph-customization.lua
local customization = require("src/config/customization")
local tuning = require("src/config/graph-tuning")
local policy = require("src/config/graph-customization")
local model = require("src/runtime/customizer/customizer-model")

local state = customization.parse("PARAM:graph/all.amount=25;PARAM:graph/all.fluids=less;PARAM:graph/recipe-ingredients.amount=75;PARAM:graph/recipe-ingredients.fluids=more;EXCLUDE:graph/all:group/fixture-group;EXCLUDE:graph/entity:prototype/entity/fixture-machine")
assert(#state.warnings == 0)
assert(tuning.resolve(state, "recipe-ingredients").amount == "75")
assert(tuning.resolve(state, "recipe-ingredients").fluids == "more")
assert(tuning.resolve(state, "entity").amount == "25")
assert(tuning.resolve(state, "entity").fluids == nil)
local serialized = customization.serialize(state)
assert(serialized == customization.serialize(customization.parse(serialized)))
for _, instruction in pairs({
    "PARAM:graph/entity.fluids=more",
    "PARAM:graph/item.cost_similarity=small",
    "PARAM:graph/all.amount=-1",
    "PARAM:graph/all.amount=101",
    "PARAM:graph/all.amount=0.5",
    "PARAM:graph/all.unknown=inherit",
    "EXCLUDE:graph/all:prototype/missing-class",
    "EXCLUDE:graph/missing:type/widget",
}) do
    assert(#customization.parse(instruction).warnings == 1, instruction)
end
local removed = customization.parse(serialized .. ";PARAM:graph/recipe-ingredients.amount=inherit;INCLUDE:graph/all:group/fixture-group")
assert(tuning.resolve(removed, "recipe-ingredients").amount == "25")
assert(removed.exclusions.all["group/fixture-group"] == nil)
local cleared = customization.parse(serialized .. ";INHERIT:graph/entity")
assert(cleared.graph.entity == nil and cleared.exclusions.entity == nil)

local raw = {}
local classes = {}
classes.entity = {widget = true}
classes.item = {component = true}
classes.recipe = {fabrication = true}
raw.widget = {
    ["fixture-machine"] = {
        name = "fixture-machine",
        type = "widget",
        subgroup = "fixture-subgroup",
    },
    ["fixture-other"] = {
        name = "fixture-other",
        type = "widget",
    },
}
raw.component = {
    ["fixture-placer"] = {
        name = "fixture-placer",
        type = "component",
        place_result = "fixture-machine",
    },
    ["fixture-input"] = {
        name = "fixture-input",
        type = "component",
    },
    ["fixture-output"] = {
        name = "fixture-output",
        type = "component",
    },
}
raw.fabrication = {
    ["fixture-process"] = {
        name = "fixture-process",
        type = "fabrication",
        ingredients = {
            {
                type = "component",
                name = "fixture-input",
                amount = 1,
            },
        },
        results = {
            {
                type = "component",
                name = "fixture-output",
                amount = 1,
            },
        },
    },
}
raw["item-subgroup"] = {
    ["fixture-subgroup"] = {
        name = "fixture-subgroup",
        group = "fixture-group",
    },
}
raw.component["fixture-output"].subgroup = "fixture-subgroup"
local catalogue = policy.catalog(raw, classes)
local found_recipe_group = false
for _, entry in pairs(catalogue) do
    if entry.class == "recipe" then
        found_recipe_group = entry.group == "fixture-group" and entry.subgroup == "fixture-subgroup"
    end
end
assert(found_recipe_group, "recipe groups inherit their singular product's metadata")
local machine = {
    type = "entity",
    name = "fixture-machine",
    prot = "widget: fixture-machine",
}
local placer = {
    type = "item",
    name = "fixture-placer",
    prot = "component: fixture-placer",
}
for _, selector in pairs({
    "prototype/entity/fixture-machine",
    "prototype/widget/fixture-machine",
    "type/widget",
    "group/fixture-group",
    "subgroup/fixture-subgroup",
}) do
    policy.initialize(customization.parse("EXCLUDE:graph/all:" .. selector), raw, classes, 1)
    assert(policy.excluded("entity", machine), selector)
    assert(policy.excluded("item", placer), "placing identity must stay fixed: " .. selector)
end
policy.initialize(customization.parse("EXCLUDE:graph/entity:prototype/entity/fixture-machine"), raw, classes, 1)
assert(policy.excluded("entity", machine))
assert(not policy.excluded("item", machine), "handler-specific exclusions do not silently become global")
policy.initialize(customization.parse("EXCLUDE:graph/all:prototype/recipe/fixture-process"), raw, classes, 1)
assert(policy.excluded("item", {
    type = "item",
    name = "fixture-input",
    prot = "component: fixture-input",
}))
assert(policy.excluded("item", {
    type = "item",
    name = "fixture-output",
    prot = "component: fixture-output",
}))
policy.initialize(customization.parse("EXCLUDE:graph/all:prototype/item/fixture-placer"), raw, classes, 1)
assert(policy.excluded("entity", machine), "fixed placing items protect what they place")
raw.component["fixture-second-placer"] = {
    name = "fixture-second-placer",
    type = "component",
    place_result = "fixture-machine",
}
policy.initialize(customization.parse("EXCLUDE:graph/all:prototype/item/fixture-placer"), raw, classes, 1)
assert(policy.excluded("item", {
    type = "item",
    name = "fixture-second-placer",
}), "all placing items for a protected entity stay fixed")

policy.initialize(customization.parse("PARAM:graph/recipe-ingredients.fluids=less"), raw, classes, 1)
local less_fluids = policy.shape()
policy.initialize(customization.parse("PARAM:graph/recipe-ingredients.fluids=more"), raw, classes, 1)
local more_fluids = policy.shape()
assert(less_fluids.fluid_gain_chance < more_fluids.fluid_gain_chance)
assert(less_fluids.fluid_loss_chance > more_fluids.fluid_loss_chance)

for _, amount in pairs({
    "0",
    "25",
    "50",
    "75",
    "100",
}) do
    local configuration = customization.parse("PARAM:graph/all.amount=" .. amount)
    policy.initialize(configuration, raw, classes, 19)
    local selected = {}
    local count = 0
    for index = 1, 1000 do
        local node = {
            type = "fixture",
            name = "target-" .. index,
            prot = "fixture: target-" .. index,
        }
        selected[index] = policy.selected("recipe-ingredients", node)
        assert(selected[index] == policy.selected("recipe-ingredients", node), "selection must be shared by all edges")
        if selected[index] == true then count = count + 1 end
    end
    if amount == "0" then assert(count == 0)
    elseif amount == "100" then assert(count == 1000)
    else assert(math.abs(count / 10 - tonumber(amount)) < 8, "selection rate deviates too far: " .. count) end
    policy.initialize(configuration, raw, classes, 19)
    for index = 1, 1000 do
        assert(selected[index] == policy.selected("recipe-ingredients", {
            type = "fixture",
            name = "target-" .. index,
            prot = "fixture: target-" .. index,
        }), "retry selection must stay fixed")
    end
end
policy.initialize(customization.parse("PARAM:graph/recipe-ingredients.ingredient_count=preserve;PARAM:graph/recipe-ingredients.fluids=preserve;PARAM:graph/recipe-ingredients.resource_balance=off"), raw, classes, 1)
local shape = policy.shape()
assert(shape.count_range == "preserve" and shape.fluid_gain_chance == 0 and shape.fluid_loss_chance == 0)
assert(policy.fields("recipe-ingredients").resource_balance == "off")

policy.initialize(customization.parse("EXCLUDE:graph/all:prototype/entity/fixture-machine"), raw, classes, 1)
policy.protect_references({
    nodes = {
        owner = machine,
        input = {
            type = "item",
            name = "fixture-input",
            prot = "component: fixture-input",
        },
    },
    edges = {
        {
            start = "input",
            stop = "owner",
        },
    },
})
assert(policy.excluded("item", {
    type = "item",
    name = "fixture-input",
}), "fixed prototypes protect referenced material identities")
assert(#policy.check_material_renames({
    ["item: fixture-input"] = {
        type = "item",
        name = "fixture-output",
    },
}) == 1)
policy.initialize(customization.parse("PARAM:graph/item.amount=50"), raw, classes, 1)
assert(policy.selected("item", placer) == policy.selected("item", {
    type = "item",
    name = "fixture-placer",
}), "concrete and top-level aliases must have the same sample")
policy.initialize(customization.parse("PARAM:graph/item.amount=0"), raw, classes, 1)
assert(#policy.check_material_renames({
    ["item: fixture-input"] = {
        type = "item",
        name = "fixture-output",
    },
}) == 1)
assert(#policy.check_material_renames({
    ["item: fixture-input"] = {
        type = "item",
        name = "fixture-input",
    },
}) == 0)
assert(#policy.report() > 0)

local draft = model.new(serialized)
model.set(draft, "graph/entity", "amount", "33")
assert(model.fields(draft, "graph/entity").amount == "33")
assert(model.inherited(draft, "graph/entity", "amount", {}) == "25")
model.exclude(draft, "graph/entity", "subgroup/fixture-subgroup", true)
assert(customization.parse(model.export(draft)).exclusions.entity["subgroup/fixture-subgroup"])
model.reset(draft, "graph/entity")
assert(draft.configuration.exclusions.entity["subgroup/fixture-subgroup"], "parameter resets preserve independent exclusions")
model.reset(draft)
assert(next(draft.configuration.graph) == nil and next(draft.configuration.exclusions) == nil)
print("ok - graph parameter schema, inheritance, sampling, exclusions, linked identities and draft editing")
