local categories = require("helper-tables/categories")

if mods["pyalternativeenergy"] then
    -- Make assembling machines painfully early so they don't get pushed late
    data.raw.recipe["assembling-machine-1"].enabled = true
    data.raw.recipe["assembling-machine-1"].ingredients = {{type = "item", name = "iron-ore", amount = 8}}
end

-- Make fixed recipes non-hidden
for machine_type, _ in pairs(categories.crafting_machines) do
    for _, machine in pairs(data.raw[machine_type]) do
        if machine.fixed_recipe ~= nil then
            local recipe = data.raw.recipe[machine.fixed_recipe]
            recipe.hidden = false
        end
    end
end

-- Remove pure-recycling recipe unlocks and make them unlocked at the start
local is_pure_recycling = {}
for _, recipe in pairs(data.raw.recipe) do
    if recipe.categories ~= nil and #recipe.categories == 1 and recipe.categories[1] == "recycling" then
        is_pure_recycling[recipe.name] = true
        recipe.enabled = true
    end
end
for _, tech in pairs(data.raw.technology) do
    if tech.effects ~= nil then
        local new_effects = {}
        for _, effect in pairs(tech.effects) do
            if effect.type ~= "unlock-recipe" or not is_pure_recycling[effect.recipe] then
                table.insert(new_effects, effect)
            end
        end
        tech.effects = new_effects
    end
end

-- Add input fluid boxes to all mining drills that don't already have them

local pipe_conns = require("lib/pipe-conns")

-- CRITICAL TODO: This is sometimes putting the pipe connection inside the machine?
for _, drill in pairs(data.raw["mining-drill"]) do
    if drill.input_fluid_box == nil then
        pipe_conns.add_dummy_pipe_conns(drill, {"input_fluid_box", "output_fluid_box"})
        local pipe_conn_to_use = drill.dummy_pipe_conns[1]
        pipe_conn_to_use.flow_direction = "input"

        drill.input_fluid_box = {
            volume = 200,
            pipe_connections = {pipe_conn_to_use},
            production_type = "input",
        }

        -- Delete dummy fluid boxes
        drill.dummy_pipe_conns = nil
    else
        -- Make sure drills don't have input fluid box filters
        drill.input_fluid_box.filter = nil
    end
end

-- Add fluid box connections to assembling machine 1, if it doesn't already have some added by another mod
local assm1 = data.raw["assembling-machine"]["assembling-machine-1"]
local assm2 = data.raw["assembling-machine"]["assembling-machine-2"]
if assm1 ~= nil and assm2 ~= nil then
    if assm1.fluid_boxes == nil or #assm1.fluid_boxes == 0 then
        if assm2.fluid_boxes ~= nil and #assm2.fluid_boxes > 0 then
            assm1.fluid_boxes_off_when_no_fluid_recipe = true
            assm1.fluid_boxes = table.deepcopy(assm2.fluid_boxes)
            table.insert(assm1.crafting_categories, "crafting-with-fluid")
        end
    end
end