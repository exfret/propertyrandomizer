local categories = require("helper-tables/categories")
local dutils = require("lib/data-utils")
local pipe_conns = require("lib/pipe-conns")

if mods["pyalternativeenergy"] then
    -- Make assembling machines painfully early so they don't get pushed late
    data.raw.recipe["assembling-machine-1"].enabled = true
    data.raw.recipe["assembling-machine-1"].ingredients = {{type = "item", name = "iron-plate", amount = 10}}

    -- Same with burners/sinkhole/exhaust pipe
    for _, voider in pairs({"py-burner", "py-gas-vent", "py-sinkhole"}) do
        data.raw.recipe[voider].enabled = true
        data.raw.recipe[voider].ingredients = {{type = "item", name = "iron-plate", amount = 10}}
    end

    -- Give all burner energy sources burnt result inventory
    for class, _ in pairs(defines.prototypes.entity) do
        for _, entity in pairs(data.raw[class] or {}) do
            if categories.energy_sources_input[entity.type] ~= nil then
                for _, energy_prop in pairs(dutils.tablize(categories.energy_sources_input[entity.type])) do
                    local energy_source = entity[energy_prop]
                    if energy_source ~= nil and energy_source.type == "burner" then
                        if energy_source.burnt_inventory_size == 0 or energy_source.burnt_inventory_size == nil then
                            energy_source.burnt_inventory_size = 1
                        end
                    end
                end
            end
        end
    end

    -- Make furnaces crafting machines
    -- I think this is really all that's needed?
    for _, furnace_name in pairs({"stone-furnace", "steel-furnace", "electric-furnace"}) do
        local furnace = data.raw.furnace[furnace_name]
        furnace.type = "assembling-machine"
        data.raw.furnace[furnace_name] = nil
        data:extend({
            furnace
        })
    end

    -- Make other furnace recipes always unlocked
    for _, furnace in pairs(data.raw.furnace) do
        for _, category in pairs(furnace.crafting_categories) do
            for _, recipe in pairs(data.raw.recipe) do
                local should_enable = false
                for _, other_category in pairs(recipe.categories or {"crafting"}) do
                    if category == other_category then
                        should_enable = true
                    end
                end
                if should_enable then
                    recipe.enabled = true
                end
            end
        end
    end

    -- Add pipe connections to assembling machines
    -- Make sure to change volume in recipe randomization/fluid multiplier too if this changes
    local default_volume = 500
    for _, machine in pairs(data.raw["assembling-machine"]) do
        machine.fluid_boxes = machine.fluid_boxes or {}
        machine.fluid_boxes_off_when_no_fluid_recipe = true
        -- Remove excess pipe connections from fluid boxes so that we have more room for other fluid boxes
        for _, fluid_box in pairs(machine.fluid_boxes) do
            fluid_box.draw_only_when_connected = true
            fluid_box.pipe_connections = { fluid_box.pipe_connections[1] }
            -- Increase volume just in case a recipe gets that much fluid
            fluid_box.volume = default_volume
        end
        local available = pipe_conns.get_available_pipe_connections(machine)
        -- Alternately add input and output boxes
        -- Keep three fluid boxes free; one for input, one for output, and one for energy source
        for ind = 1, #available - 3 do
            local conn = available[ind]
            local input_type = "input"
            if ind % 2 == 0 then
                input_type = "output"
            end
            conn.flow_direction = input_type
            conn.connection_category = {
                "default",
                "pipe",
                "niobium-pipe",
                "ht-pipes",
            }
            table.insert(machine.fluid_boxes, {
                volume = default_volume,
                pipe_connections = { conn },
                draw_only_when_connected = true,
                production_type = input_type,
                conn,
            })
        end
    end

    -- Enable hidden enableable reachable recipes; these are all now crafted by machines that should grant you the ability to do them immediately anyways
    local is_enableable = {}
    for _, tech in pairs(data.raw.technology) do
        if not tech.hidden then
            for _, effect in pairs(tech.effects) do
                if effect.type == "unlock-recipe" then
                    is_enableable[effect.recipe] = true
                end
            end
        end
    end
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.enabled ~= false then
            is_enableable[recipe.name] = true
        end
    end
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.hidden then
            if is_enableable[recipe.name] then
                recipe.enabled = true
            end
        end
    end

    -- Make something a main product if it's the only thing in the results
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.results ~= nil and #recipe.results == 1 then
            recipe.main_product = recipe.results[1].name
        end
    end

    -- QOL
    data.raw.character.character.inventory_size = 200
    for _, armor in pairs(data.raw.armor) do
        armor.inventory_size_bonus = (armor.inventory_size_bonus or 10) * 5
    end
    data.raw.character.character.crafting_speed = 5
    data.raw.character.character.mining_speed = 2
    data.raw.technology.toolbelt.effects = {
        {
            type = "character-inventory-slots-bonus",
            modifier = 100,
        },
    }
end

-- Make fixed recipes enabled
for machine_type, _ in pairs(categories.crafting_machines) do
    for _, machine in pairs(data.raw[machine_type]) do
        if machine.fixed_recipe ~= nil then
            local recipe = data.raw.recipe[machine.fixed_recipe]
            recipe.enabled = true
            recipe.hide_from_player_crafting = true
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