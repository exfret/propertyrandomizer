local constants = require("helper-tables/constants")
local gutils = require("lib/graph/graph-utils")

local key = gutils.key

randomization_info.options.first_pass.blacklist = {}
-- Blacklist barrels
for _, recipe in pairs(data.raw.recipe) do
    if string.sub(recipe.name, -6, -1) == "barrel" then
        randomization_info.options.first_pass.blacklist[key("recipe", recipe.name)] = true
    end
end
for class, _ in pairs(defines.prototypes.item) do
    if data.raw[class] ~= nil then
        for _, item in pairs(data.raw[class]) do
            if string.sub(item.name, -6, -1) == "barrel" then
                randomization_info.options.first_pass.blacklist[key("item", item.name)] = true
            end
            -- Armors with grids all get their own electric network, potentially lagging the game; don't randomize them!
            if item.type == "armor" and item.equipment_grid ~= nil then
                randomization_info.options.first_pass.blacklist[key("item", item.name)] = true
            end
        end
    end
end
-- TODO: Do in more automatic way than hardcoding
randomization_info.options.first_pass.blacklist[key("item", "rocket-part")] = true
-- Also do the rocket launch products (this is in particular for py, where the mechanics system would trip up otherwise)
for class, _ in pairs(defines.prototypes.item) do
    if data.raw[class] ~= nil then
        for _, item in pairs(data.raw[class]) do
            if item.rocket_launch_products ~= nil then
                for _, result in pairs(item.rocket_launch_products) do
                    randomization_info.options.first_pass.blacklist[key("item", result.name)] = true
                end
            end
        end
    end
end

randomization_info.options.first_pass.always_slot_pre = {
    [key("item-craft", "item")] = true,
    [key("entity-kill", "item")] = true,
    [key("item-burn", "item")] = true,
    [key("item", "item")] = true,
    [key("tile-mine", "item")] = true, -- Special handling
    [key("entity-mine", "item")] = true, -- Special handling
    [key("asteroid-chunk-mine", "item")] = true,
}

randomization_info.options.first_pass.always_slot_dep = {
    [key("item", "recipe")] = true,
}

(randomization_info.options.unified["entity-autoplace"] or {}).blacklisted_dep = {
    [key("entity", "fulgoran-ruin-attractor")] = true,
}

(randomization_info.options.unified["recipe-ingredients"] or {}).blacklisted_pre = {
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
(randomization_info.options.unified["recipe-ingredients"] or {}).blacklisted_dep = {
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
    local is_recycling = false
    for _, cat in pairs(recipe.categories or {"crafting"}) do
        if cat == "recycling" then
            is_recycling = true
        end
    end
    if is_recycling then
        ((randomization_info.options.unified["recipe-ingredients"] or {}).blacklisted_dep or {})[key("recipe", recipe.name)] = true
    end
end
-- Add barreling recipes
-- Sensed by whether "barrel" is in the name
for _, recipe in pairs(data.raw.recipe) do
    if string.sub(recipe.name, -6, -1) == "barrel" then
        ((randomization_info.options.unified["recipe-ingredients"] or {}).blacklisted_dep or {})[key("recipe", recipe.name)] = true
    end
end
-- Add crushing-only recipes (space stuff is too sensitive I think?)
for _, recipe in pairs(data.raw.recipe) do
    local is_only_crushing = true
    for _, cat in pairs(recipe.categories or {"crafting"}) do
        if cat ~= "crushing" then
            is_only_crushing = false
            break
        end
    end
    if is_only_crushing then
        ((randomization_info.options.unified["recipe-ingredients"] or {}).blacklisted_dep or {})[key("recipe", recipe.name)] = true
    end
end

randomization_info.options.unified["spoiling"].blacklisted_pre = {
    [key("item", "copper-bacteria")] = true,
    [key("item", "iron-bacteria")] = true,
}

(randomization_info.options.unified["recipe-category"] or {}).blacklisted_dep = {}

-- I don't know if this actually is needed right now (which is a good thing)
randomization_info.options.logic.contexts_in_order = {}
local contexts_in_order = randomization_info.options.logic.contexts_in_order
table.insert(contexts_in_order, {
    key({type = "planet", name = constants.starting_planet})
})
table.insert(contexts_in_order, {
    key({type = "surface", name = "space-platform"})
})
for _, planet in pairs({"nauvis", "fulgora", "gleba", "vulcanus"}) do
    if planet ~= constants.starting_planet then
        table.insert(contexts_in_order, {
            key({type = "planet", name = planet})
        })
    end
end
table.insert(contexts_in_order, {
    key({type = "planet", name = "aquilo"})
})

-- TODO: Make these into node format
randomization_info.options.cost.default_cost_table = {
    ["item-iron-ore"] = 1,
    ["item-copper-ore"] = 1,
    ["item-coal"] = 1,
    -- Higher cost for stone since its patches are smaller/rarer
    ["item-stone"] = 1.2,
    ["fluid-crude-oil"] = 0.15,
    ["item-uranium-ore"] = 1.5,
    -- Include this so that uranium-235 isn't too expensive
    -- TODO: Maybe just require kovarex earlier?
    ["item-uranium-235"] = 100,
    ["fluid-water"] = 0.001,
    ["fluid-steam"] = 0.05,
}
local space_age_cost_table_additions = {
    -- Adding the asteroid chunks actually tricks the randomizer into thinking iron is cheap and putting it everywhere
    -- NOTE: Actually the issue seems to be elsewhere... not sure what it is though
    --["item-metallic-asteroid-chunk"] = 1,
    --["item-carbonic-asteroid-chunk"] = 1,
    --["item-oxide-asteroid-chunk"] = 1,
    ["item-carbon"] = 1, -- Add this instead of the asteroid chunks
    ["item-ice"] = 1,
    ["fluid-ammoniacal-solution"] = 0.6,
    ["fluid-fluorine"] = 0.6,
    ["item-lithium"] = 2,
    -- Set scrap cost high to prevent it from interfering with cost assignments of iron and the like
    -- This makes it unlikely to appear elsewhere besides scrap recycling but whatever
    ["item-scrap"] = 10,
    ["item-pentapod-egg"] = 2,
    ["item-jellynut"] = 1,
    ["item-yumako"] = 1,
    ["item-spoilage"] = 0.5,
    ["fluid-lava"] = 0.05,
    ["item-tungsten-ore"] = 3,
    ["item-calcite"] = 1,
    ["item-iron-bacteria"] = 5,
    ["item-copper-bacteria"] = 5,
    ["item-biter-egg"] = 1,
}
if mods["space-age"] then
    for k, v in pairs(space_age_cost_table_additions) do
        randomization_info.options.cost.default_cost_table[k] = v
    end
end
randomization_info.options.cost.major_raw_resources = {
    "item-iron-ore",
    "item-copper-ore",
    "item-coal",
    "item-stone",
    "fluid-crude-oil",
    -- Don't include space age resources; those aren't super important to balance
}