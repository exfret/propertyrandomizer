-- Waiting on information for possible source of graphics: https://mods.factorio.com/mod/gearball-lab
-- Slower lab with only one module slot but with no energy requirements and unlocked from start

local lab = table.deepcopy(data.raw.lab.lab)
lab.name = "void-lab"
lab.energy_source = {
    type = "void",
}
lab.researching_speed = 0.75
lab.module_slots = 1
lab.minable.result = "void-lab"

local custom_lab_on_animation = {
    layers = {
        {
            filename = "__propertyrandomizer__/graphics/duplicates/void-lab/lab.png",
            width = 194,
            height = 174,
            frame_count = 33,
            line_length = 11,
            animation_speed = 1 / 6,
            shift = util.by_pixel(0, 1.5),
            scale = 0.5
        },
        {
            filename = "__base__/graphics/entity/lab/lab-integration.png",
            width = 242,
            height = 162,
            frame_count = 1,
            line_length = 1,
            repeat_count = 33,
            animation_speed = 1 / 3,
            shift = util.by_pixel(0, 15.5),
            scale = 0.5
        },
        {
            filename = "__propertyrandomizer__/graphics/duplicates/void-lab/lab-light.png",
            blend_mode = "additive",
            draw_as_light = true,
            width = 216,
            height = 194,
            frame_count = 33,
            line_length = 11,
            animation_speed = 1 / 6,
            shift = util.by_pixel(-1, 1),
            scale = 0.5
        },
        {
            filename = "__base__/graphics/entity/lab/lab-shadow.png",
            width = 242,
            height = 136,
            frame_count = 1,
            line_length = 1,
            repeat_count = 33,
            animation_speed = 1 / 3,
            shift = util.by_pixel(13, 11),
            scale = 0.5,
            draw_as_shadow = true,
        }
    }
}

local custom_lab_off_animation = {
    layers = {   
        {
            filename = "__propertyrandomizer__/graphics/duplicates/void-lab/lab.png",
            width = 194,
            height = 174,
            frame_count = 1,
            shift = util.by_pixel(0, 1.5),
            scale = 0.5
        },
        {
            filename = "__base__/graphics/entity/lab/lab-integration.png",
            width = 242,
            height = 162,
            frame_count = 1,
            shift = util.by_pixel(0, 15.5),
            scale = 0.5
        },
        {
            filename = "__base__/graphics/entity/lab/lab-shadow.png",
            width = 242,
            height = 136,
            frame_count = 1,
            shift = util.by_pixel(13, 11),
            draw_as_shadow = true,
            scale = 0.5
        }
    }
}

lab.on_animation = custom_lab_on_animation
lab.off_animation = custom_lab_off_animation
lab.icon = "__propertyrandomizer__/graphics/duplicates/void-lab/icon.png"

local item = table.deepcopy(data.raw.item.lab)
item.name = "void-lab"
item.place_result = "void-lab"
item.icon = "__propertyrandomizer__/graphics/duplicates/void-lab/icon.png"

local recipe = table.deepcopy(data.raw.recipe.lab)
recipe.name = "void-lab"
recipe.ingredients = {
    { type = "item", name = "iron-gear-wheel", amount = 10 },
    { type = "item", name = "iron-plate", amount = 15 },
    { type = "item", name = "copper-cable", amount = 2 },
}
recipe.results = {
    { type = "item", name = "void-lab", amount = 1},
}
recipe.enabled = true

data:extend({
    lab,
    item,
    recipe,
})