local constants = require("helper-tables/constants")
local gutils = require("lib/graph/graph-utils")
local dutils = require("lib/data-utils")

local key = gutils.key

-- Handlers not in helper-tables/handler-ids.lua don't have options tables yet at this point, so create them here
-- (otherwise the blacklists below would be written into throwaway tables and silently lost)
local function unified_options(id)
    if randomization_info.options.unified[id] == nil then
        randomization_info.options.unified[id] = {
            blacklisted_pre = {},
            blacklisted_dep = {},
        }
    end
    return randomization_info.options.unified[id]
end

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

unified_options("entity-autoplace").blacklisted_dep = {
    [key("entity", "fulgoran-ruin-attractor")] = true,
}

unified_options("recipe-ingredients").blacklisted_pre = {
    [key("item", "spoilage")] = true,
    [key("item", "yumako")] = true,
    [key("item", "jellynut")] = true,
}
-- Whatever mining a resource or asteroid chunk or pumping a tile gives stays where it is, so the recipes that process it keep it (smelting plates, plastic's coal, oil processing, crushing, ...)
for _, material in pairs(dutils.resource_materials()) do
    unified_options("recipe-ingredients").blacklisted_pre[key(material.type, material.name)] = true
end
unified_options("recipe-ingredients").blacklisted_dep = {
    [key("recipe", "basic-oil-processing")] = true,
    -- Preserve fuel sinks for fluids
    [key("recipe", "solid-fuel-from-heavy-oil")] = true,
    [key("recipe", "solid-fuel-from-light-oil")] = true,
    [key("recipe", "solid-fuel-from-petroleum-gas")] = true,
    -- Scrap recycling is captured by recycling recipe checks
    -- I would do jellynut/yumako, but it was throwing weird errors, so I just made them unrandomized as ingredients instead
    --[key("recipe", "jellynut-processing")] = true,
    --[key("recipe", "yumako-processing")] = true,
    [key("recipe", "ammoniacal-solution-separation")] = true,
    [key("recipe", "ice-melting")] = true,
    [key("recipe", "holmium-solution")] = true,
    [key("recipe", "holmium-plate")] = true,
    [key("recipe", "lithium-plate")] = true,
}
for _, recipe in pairs(data.raw.recipe) do
    local is_recycling = false
    for _, cat in pairs(recipe.categories or {"crafting"}) do
        if cat == "recycling" then
            is_recycling = true
        end
    end
    if is_recycling then
        (unified_options("recipe-ingredients").blacklisted_dep or {})[key("recipe", recipe.name)] = true
    end
end
-- Round trips (like fluoroketone cooling, which undoes what fusion does to it) break if one side's ingredients change
local round_trips = dutils.round_trips()
for recipe_name, _ in pairs(round_trips.recipes) do
    log("Round trip recipe: " .. recipe_name)
    unified_options("recipe-ingredients").blacklisted_dep[key("recipe", recipe_name)] = true
end
for material_key, material in pairs(round_trips.materials) do
    log("Round trip material: " .. material_key)
    unified_options("recipe-ingredients").blacklisted_pre[key(material.type, material.name)] = true
end
-- Add barreling recipes
-- Sensed by whether "barrel" is in the name
for _, recipe in pairs(data.raw.recipe) do
    if string.sub(recipe.name, -6, -1) == "barrel" then
        (unified_options("recipe-ingredients").blacklisted_dep or {})[key("recipe", recipe.name)] = true
    end
end

randomization_info.options.unified["spoiling"].blacklisted_pre = {
    [key("item", "copper-bacteria")] = true,
    [key("item", "iron-bacteria")] = true,
}

unified_options("recipe-category").blacklisted_dep = {}

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

-- Raw material costs and the major resources come from the logic graph's cost model once it's built (lib/cost/graph-cost.lua, called from data-final-fixes.lua)
-- A compat file can still set a material's cost here, which the derived costs then leave alone
randomization_info.options.cost.default_cost_table = {}
randomization_info.options.cost.major_raw_resources = {}