-- Utilities specific to logic
-- TODO: This should probably get renamed to lookup-utils

local lib_name = "new-lib" -- Use this until integration with "old" lib
local categories = require("helper-tables/categories")
local dutils = require(lib_name .. "/data-utils")
local gutils = require(lib_name .. "/graph/graph-utils")

local lutils = {}

lutils.starting_character_name = "character"
lutils.starting_planet_name = "nauvis"

lutils.find_recipe_fluids = function(recipe)
    local fluids = {
        input = 0,
        output = 0,
    }
    
    for prop, key in pairs({ingredients = "input", results = "output"}) do
        if recipe[prop] ~= nil then
            for _, prod in pairs(recipe[prop]) do
                if prod.type == "fluid" then
                    fluids[key] = fluids[key] + 1
                end
            end
        end
    end

    return fluids
end
lutils.is_compatible_rcat = function(machine, rcat)
    local fluids = {
        input = 0,
        output = 0,
    }

    if machine.fluid_boxes ~= nil then
        for _, fluid_box in pairs(machine.fluid_boxes) do
            for _, dir in pairs({"input", "output"}) do
                if fluid_box.production_type == dir then
                    fluids[dir] = fluids[dir] + 1
                end
            end
        end
    end

    for _, category in pairs(machine.crafting_categories) do
        if category == rcat.cat and fluids.input >= rcat.input and fluids.output >= rcat.output then
            return true
        end
    end

    return false
end
lutils.rcat_name = function(recipe)
    local fluids = lutils.find_recipe_fluids(recipe)
    return gutils.concat({recipe.category or "crafting", fluids.input, fluids.output})
end

lutils.find_mining_fluids = function(resource)
    if resource.minable == nil then
        return nil
    end
    local fluids = {
        input = 0,
        output = 0,
    }
    if resource.minable.required_fluid ~= nil then
        fluids.input = 1
    end
    if resource.minable.results ~= nil then
        for _, result in pairs(resource.minable.results) do
            if result.type == "fluid" then
                -- If there is already a fluid output, then this produces two fluids and thus can't be mined
                if fluids.output >= 1 then
                    log(serpent.block(resource))
                    error("A resource with more than one mining fluid was defined by another mod.")
                else
                    fluids.output = 1
                end
            end
        end
    end

    return fluids
end
lutils.mcat_name = function(resource)
    if resource.minable == nil then
        return ""
    end

    local fluids = lutils.find_mining_fluids(resource)
    return gutils.concat({resource.category or "basic-solid", fluids.input, fluids.output})
end

lutils.fcat_combo_name = function(energy_source)
    local fuel_key = gutils.concat(energy_source.fuel_categories or {"chemical"})
    local burnt_key = 0
    if energy_source.burnt_inventory_size ~= nil and energy_source.burnt_inventory_size >= 1 then
        burnt_key = 1
    end
    return gutils.concat({fuel_key, burnt_key}, 2)
end

-- Gets all prototypes of a type that appear in a room via autoplace, or checks a single prototype
-- If prot is "tile" or "entity", returns a table of all matching prototypes in the room
-- If prot is a prototype table, returns true/false for whether it appears in the room
lutils.check_in_room = function(room, prot)
    -- Determine if we're getting all prots or checking a single one
    local get_all = (prot == "tile" or prot == "entity")
    local type_of_autoplace = get_all and prot or (prot.type == "tile" and "tile" or "entity")

    local results = {}

    if room.type == "planet" then
        local planet = data.raw.planet[room.name]

        if planet.map_gen_settings ~= nil then
            local map_gen_settings = planet.map_gen_settings

            -- Check autoplace_settings
            if map_gen_settings.autoplace_settings ~= nil then
                local autoplace_settings = map_gen_settings.autoplace_settings[type_of_autoplace]

                if autoplace_settings ~= nil and autoplace_settings.settings ~= nil then
                    if get_all then
                        -- Return all prots in settings
                        for prot_name, _ in pairs(autoplace_settings.settings) do
                            local prot_data = dutils.get_prot(type_of_autoplace, prot_name)
                            if prot_data ~= nil then
                                if autoplace_settings.treat_missing_as_default or prot_data.autoplace ~= nil then
                                    results[prot_name] = true
                                end
                            end
                        end
                    else
                        -- Check single prot
                        if autoplace_settings.settings[prot.name] then
                            if autoplace_settings.treat_missing_as_default or prot.autoplace ~= nil then
                                return true
                            end
                        end
                    end
                end
            end

            -- Check autoplace_controls
            if map_gen_settings.autoplace_controls ~= nil then
                if get_all then
                    -- Find all prots matching any control
                    -- For tiles: data.raw.tile works directly; for entities: iterate all entity classes
                    -- This is expensive but only done once during lookup construction (can't use lu.entities here due to circular dependency)
                    local prots_to_check = (type_of_autoplace == "tile") and data.raw.tile or dutils.get_all_prots("entity")

                    for control, _ in pairs(map_gen_settings.autoplace_controls) do
                        for prot_name, prot_data in pairs(prots_to_check) do
                            if prot_data.autoplace and prot_data.autoplace.control == control then
                                results[prot_name] = true
                            end
                        end
                    end
                else
                    -- Check single prot
                    for control, _ in pairs(map_gen_settings.autoplace_controls) do
                        if prot.autoplace and prot.autoplace.control == control then
                            return true
                        end
                    end
                end
            end
        end
    end

    if get_all then
        return results
    else
        return false
    end
end

lutils.check_surface_conditions = function(room, conditions)
    for _, condition in pairs(conditions) do
        -- Check that this property is in the right range for this surface
        local surface_val = data.raw["surface-property"][condition.property].default_value

        local room_prot = data.raw[room.type][room.name]

        if room_prot.surface_properties ~= nil then
            if room_prot.surface_properties[condition.property] ~= nil then
                surface_val = room_prot.surface_properties[condition.property]
            end
        end

        if condition.min ~= nil and condition.min > surface_val then
            return false
        end
        if condition.max ~= nil and condition.max < surface_val then
            return false
        end
    end

    return true
end

-- Just checks whether it's a burner
lutils.check_freezable = function(entity)
    -- TODO: Cars and a few other things maybe shouldn't need heat even if they have void energy sources
    if entity.type == "heat-pipe" then
        return false
    end

    local property_list = categories.energy_sources_input[entity.type]
    if type(property_list) ~= "table" then
        property_list = {property_list}
    end
    for _, property in pairs(property_list) do
        -- I would check that the heat energy source is a production source, not a powered source, but being heat powered leads to the same requirements anyways
        if entity[property] ~= nil and (entity[property].type == "burner" or entity[property].type == "heat") then
            return false
        end
    end

    return true
end

return lutils