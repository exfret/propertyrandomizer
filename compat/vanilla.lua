local gutils = require("new-lib/graph/graph-utils")

local key = gutils.key

randomization_info.options.unified["entity-autoplace"].blacklisted_dep = {
    [key("entity", "fulgoran-ruin-attractor")] = true,
}

randomization_info.options.unified["recipe-ingredients"].blacklisted_pre = {
    [key("fluid", "water")] = true,
    [key("item", "spoilage")] = true,
    [key("item", "yumako")] = true,
    [key("item", "jellynut")] = true,
    [key("fluid", "fluoroketone-cold")] = true,
    [key("fluid", "lava")] = true,
    [key("item", "metallic-asteroid-chunk")] = true,
    [key("item", "carbonic-asteroid-chunk")] = true,
    [key("item", "oxide-asteroid-chunk")] = true,
}
randomization_info.options.unified["recipe-ingredients"].blacklisted_dep = {
    [key("recipe", "iron-plate")] = true,
    [key("recipe", "copper-plate")] = true,
    [key("recipe", "stone-brick")] = true,
    [key("recipe", "basic-oil-processing")] = true,
    -- Preserve fuel sinks for fluids
    [key("recipe", "solid-fuel-from-heavy-oil")] = true,
    [key("recipe", "solid-fuel-from-light-oil")] = true,
    [key("recipe", "solid-fuel-from-petroleum-gas")] = true,
    -- Sensitive due to being only place coal is truly needed
    [key("recipe", "plastic-bar")] = true,
    [key("recipe", "uranium-processing")] = true,
    -- Technically redundant due to other checks
    [key("recipe", "kovarex-enrichment-process")] = true,
    -- Scrap recycling is captured by recycling recipe checks
    -- I would do jellynut/yumako, but it was throwing weird errors, so I just made them unrandomized as ingredients instead
    --[key("recipe", "jellynut-processing")] = true,
    --[key("recipe", "yumako-processing")] = true,
    [key("recipe", "tungsten-plate")] = true,
    [key("recipe", "iron-bacteria-cultivation")] = true,
    [key("recipe", "copper-bacteria-cultivation")] = true,
    [key("recipe", "fluoroketone-cooling")] = true,
    [key("recipe", "ammoniacal-solution-separation")] = true,
    [key("recipe", "thruster-fuel")] = true,
    [key("recipe", "thruster-oxidizer")] = true,
    [key("recipe", "ice-melting")] = true,
    [key("recipe", "holmium-solution")] = true,
    [key("recipe", "holmium-plate")] = true,
    [key("recipe", "lithium-plate")] = true,
    -- For asteroids
    [key("recipe", "firearm-magazine")] = true,
}
for _, recipe in pairs(data.raw.recipe) do
    if recipe.category == "recycling" or recipe.category == "recycling-or-hand-crafting" then
        randomization_info.options.unified["recipe-ingredients"].blacklisted_dep[key("recipe", recipe.name)] = true
    end
end
-- Add barreling recipes
-- Sensed by whether "barrel" is in the name
for _, recipe in pairs(data.raw.recipe) do
    if string.sub(recipe.name, -6, -1) == "barrel" then
        randomization_info.options.unified["recipe-ingredients"].blacklisted_dep[key("recipe", recipe.name)] = true
    end
end
-- Add crushing recipes (space stuff is too sensitive I think?)
for _, recipe in pairs(data.raw.recipe) do
    if recipe.category == "crushing" then
        randomization_info.options.unified["recipe-ingredients"].blacklisted_dep[key("recipe", recipe.name)] = true
    end
end

randomization_info.options.unified["spoiling"].blacklisted_pre = {
    [key("item", "copper-bacteria")] = true,
    [key("item", "iron-bacteria")] = true,
}

-- I don't know if this actually is needed right now (which is a good thing)
randomization_info.options.logic.contexts_in_order = {
    key({type = "planet", name = "nauvis"}),
    key({type = "surface", name = "space-platform"}),
    key({type = "planet", name = "vulcanus"}),
    key({type = "planet", name = "fulgora"}),
    key({type = "planet", name = "gleba"}),
    key({type = "planet", name = "aquilo"}),
}

randomization_info.options.cost.major_raw_resources = {
    "item-iron-ore",
    "item-copper-ore",
    "item-coal",
    "item-stone",
    "fluid-crude-oil",
    -- Don't include space age resources; those aren't super important to balance
}