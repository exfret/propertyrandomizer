-- A very expensive form of the electric mining drill (unlocked with a lot of red science, and also costs a lot of raw resources)
-- Faster and more energy efficient, but no module slots and fueled by steam

local drill = table.deepcopy(data.raw["mining-drill"]["electric-mining-drill"])
drill.name = "steam-drill"
drill.graphics_set = {
    animation = {
        north = {
            layers = {
                {
                    priority = "high",
                    filename = "__propertyrandomizer__/graphics/duplicates/steam-drill/electric-mining-drill-N.png",
                    line_length = 8,
                    width = 196,
                    height = 226,
                    animation_speed = 0.4,
                    shift = util.by_pixel(0, -4),
                    frame_count = 64,
                    scale = 0.5,
                    run_mode = "forward-then-backward"
                },
                {
                    priority = "high",
                    filename = "__propertyrandomizer__/graphics/duplicates/steam-drill/electric-mining-drill-N-shadow.png",
                    line_length = 8,
                    width = 201,
                    height = 223,
                    animation_speed = 0.4,
                    draw_as_shadow = true,
                    shift = util.by_pixel(0, -4),
                    frame_count = 64,
                    scale = 0.5,
                    run_mode = "forward-then-backward"
                },
                {
                    priority = "high",
                    filename = "__propertyrandomizer__/graphics/duplicates/steam-drill/electric-mining-drill-N-patch.png",
                    width = 200,
                    height = 222,
                    shift = util.by_pixel(0, -4),
                    line_length = 1,
                    repeat_count = 126,
                    scale = 0.5,
                },
                {
                    priority = "high",
                    filename = "__propertyrandomizer__/graphics/duplicates/steam-drill/electric-mining-drill-N-patch-shadow.png",
                    width = 220,
                    height = 197,
                    draw_as_shadow = true,
                    shift = util.by_pixel(0, -4),
                    line_length = 1,
                    repeat_count = 126,
                    scale = 0.5,
                },
            }
        },
        south = {
            layers = {
                {
                    priority = "high",
                    filename = "__propertyrandomizer__/graphics/duplicates/steam-drill/electric-mining-drill-S.png",
                    line_length = 8,
                    width = 196,
                    height = 219,
                    animation_speed = 0.4,
                    shift = util.by_pixel(0, -4),
                    frame_count = 64,
                    scale = 0.5,
                    run_mode = "forward-then-backward"
                },
                {
                    priority = "high",
                    filename = "__propertyrandomizer__/graphics/duplicates/steam-drill/electric-mining-drill-S-shadow.png",
                    line_length = 8,
                    width = 200,
                    height = 206,
                    animation_speed = 0.4,
                    draw_as_shadow = true,
                    shift = util.by_pixel(0, -4),
                    frame_count = 64,
                    scale = 0.5,
                    run_mode = "forward-then-backward"
                },
                {
                    priority = "high",
                    filename = "__propertyrandomizer__/graphics/duplicates/steam-drill/electric-mining-drill-S-patch.png",
                    width = 200,
                    height = 226,
                    shift = util.by_pixel(0, -4),
                    line_length = 1,
                    repeat_count = 126,
                    scale = 0.5,
                },
                {
                    priority = "high",
                    filename = "__propertyrandomizer__/graphics/duplicates/steam-drill/electric-mining-drill-S-patch-shadow.png",
                    width = 220,
                    height = 197,
                    draw_as_shadow = true,
                    shift = util.by_pixel(0, -4),
                    line_length = 1,
                    repeat_count = 126,
                    scale = 0.5,
                },
            }
        },
        east = {
            layers = {
                {
                    priority = "high",
                    filename = "__propertyrandomizer__/graphics/duplicates/steam-drill/electric-mining-drill-E.png",
                    line_length = 8,
                    width = 211,
                    height = 197,
                    animation_speed = 0.4,
                    shift = util.by_pixel(0, -4),
                    frame_count = 64,
                    scale = 0.5,
                    run_mode = "forward-then-backward"
                },
                {
                    priority = "high",
                    filename = "__propertyrandomizer__/graphics/duplicates/steam-drill/electric-mining-drill-E-shadow.png",
                    line_length = 8,
                    width = 221,
                    height = 195,
                    animation_speed = 0.4,
                    draw_as_shadow = true,
                    shift = util.by_pixel(0, -4),
                    frame_count = 64,
                    scale = 0.5,
                    run_mode = "forward-then-backward"
                },
                {
                    priority = "high",
                    filename = "__propertyrandomizer__/graphics/duplicates/steam-drill/electric-mining-drill-E-patch.png",
                    width = 200,
                    height = 219,
                    shift = util.by_pixel(0, -4),
                    line_length = 1,
                    repeat_count = 126,
                    scale = 0.5,
                },
                {
                    priority = "high",
                    filename = "__propertyrandomizer__/graphics/duplicates/steam-drill/electric-mining-drill-E-patch-shadow.png",
                    width = 224,
                    height = 198,
                    draw_as_shadow = true,
                    shift = util.by_pixel(0, -4),
                    line_length = 1,
                    repeat_count = 126,
                    scale = 0.5,
                },
            }
        },
        west = {
            layers = {
                {
                    priority = "high",
                    filename = "__propertyrandomizer__/graphics/duplicates/steam-drill/electric-mining-drill-W.png",
                    line_length = 8,
                    width = 211,
                    height = 197,
                    animation_speed = 0.4,
                    shift = util.by_pixel(0, -4),
                    frame_count = 64,
                    scale = 0.5,
                    run_mode = "forward-then-backward"
                },
                {
                    priority = "high",
                    filename = "__propertyrandomizer__/graphics/duplicates/steam-drill/electric-mining-drill-W-shadow.png",
                    line_length = 8,
                    width = 229,
                    height = 195,
                    animation_speed = 0.4,
                    draw_as_shadow = true,
                    shift = util.by_pixel(0, -4),
                    frame_count = 64,
                    scale = 0.5,
                    run_mode = "forward-then-backward"
                },
                {
                    priority = "high",
                    filename = "__propertyrandomizer__/graphics/duplicates/steam-drill/electric-mining-drill-W-patch.png",
                    width = 200,
                    height = 220,
                    shift = util.by_pixel(0, -4),
                    line_length = 1,
                    repeat_count = 126,
                    scale = 0.5,
                },
                {
                    priority = "high",
                    filename = "__propertyrandomizer__/graphics/duplicates/steam-drill/electric-mining-drill-W-patch-shadow.png",
                    width = 220,
                    height = 197,
                    draw_as_shadow = true,
                    shift = util.by_pixel(0, -4),
                    line_length = 1,
                    repeat_count = 126,
                    scale = 0.5,
                },
            }
        },
    }
}
drill.energy_source = {
    type = "fluid",
    fluid_box = {
        pipe_picture = assembler2pipepictures(),
        pipe_covers = pipecoverspictures(),
        volume = 200,
        pipe_connections = {
            { direction = defines.direction.south, position = {0, 1}, flow_direction = "input" }
        },
        filter = "steam",
        production_type = "input",
    },
    scale_fluid_usage = true,
    emissions_per_minute = { pollution = 8 }
}
drill.energy_usage = "60kW"
drill.resource_categories = { "basic-solid" }
drill.mining_speed = 0.75
drill.icon = "__propertyrandomizer__/graphics/duplicates/steam-drill/pneumatic-mining-drill.png"
drill.icon_size = 32
drill.minable.result = "steam-drill"
drill.mining_categories = { "basic-solid" }
drill.input_fluid_box.pipe_connections = {drill.input_fluid_box.pipe_connections[1], drill.input_fluid_box.pipe_connections[2]}

local item = table.deepcopy(data.raw.item["electric-mining-drill"])
item.name = "steam-drill"
item.place_result = "steam-drill"
item.icon = "__propertyrandomizer__/graphics/duplicates/steam-drill/pneumatic-mining-drill.png"
item.icon_size = 32

local recipe = table.deepcopy(data.raw.recipe["electric-mining-drill"])
recipe.name = "steam-drill"
recipe.energy_required = 1
recipe.ingredients = {
    { type = "item", name = "steel-plate", amount = 15 },
    { type = "item", name = "electric-mining-drill", amount = 2 },
}
recipe.results = {
    { type = "item", name = "steam-drill", amount = 1 },
}

local tech = table.deepcopy(data.raw.technology["electric-mining-drill"])
tech.name = "steam-drill"
tech.unit.count = 125
tech.prerequisites = {
    "electric-mining-drill",
    "steel-processing",
}
tech.icon = "__propertyrandomizer__/graphics/duplicates/steam-drill/pneumatic-mining-drill.png"
tech.icon_size = 32
tech.effects = {
    { type = "unlock-recipe", recipe = "steam-drill" }
}

data:extend({
    drill,
    item,
    recipe,
    tech,
})