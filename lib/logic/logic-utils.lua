-- Utilities specific to logic
-- TODO: This should probably get renamed to lookup-utils

local lib_name = "lib" -- Use this until integration with "old" lib
local categories = require("helper-tables/categories")
local constants = require("helper-tables/constants")
local dutils = require(lib_name .. "/data-utils")
local gutils = require(lib_name .. "/graph/graph-utils")

local lutils = {}

lutils.starting_character_name = "character"
lutils.starting_planet_name = constants.starting_planet

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
        for _, cat in pairs(rcat.cats) do
            if category == cat and fluids.input >= rcat.input and fluids.output >= rcat.output then
                return true
            end
        end
    end

    return false
end
-- The spoofed recipe category name of a category list with these fluid counts ({ input, output }), which recipe-category nodes are named by
lutils.rcat_key = function(cats, fluids)
    local cats_table = {}
    for _, cat in pairs(cats) do
        table.insert(cats_table, cat)
    end
    table.sort(cats_table)
    return gutils.concat({gutils.concat(cats_table), fluids.input, fluids.output})
end

lutils.rcat_name = function(recipe)
    return lutils.rcat_key(recipe.categories or {"crafting"}, lutils.find_recipe_fluids(recipe))
end

-- Spoofed fuel category for burning an item: its fuel categories as one sorted key, so a burner of any of them can burn it
-- An item with one category keeps that category's name
lutils.item_fcats_name = function(item)
    local fcats = {}
    for _, fcat in pairs(item.fuel_categories or {}) do
        table.insert(fcats, fcat)
    end
    table.sort(fcats)
    return gutils.concat(fcats)
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
-- The spoofed resource category name of a category with these fluid counts ({ input, output }), which resource-category nodes are named by
lutils.mcat_key = function(category, fluids)
    return gutils.concat({category, fluids.input, fluids.output})
end

lutils.mcat_name = function(resource)
    if resource.minable == nil then
        return ""
    end

    return lutils.mcat_key(resource.category or "basic-solid", lutils.find_mining_fluids(resource))
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

-- Whether lightning can damage the entity on some planet: it has health, isn't a lightning attractor (attractors take strikes rather than suffer them), and some planet with lightning doesn't exempt it
-- Lightning applies its damage to whatever it strikes that isn't an attractor (LightningPrototype::damage); a planet's LightningProperties::exemption_rules name what it never strikes, by prototype type or by name
-- Other kinds of exemption rules (by impact soundset, or counting as a rock) aren't read, so entities they'd exempt count as endangered, which only asks more of the logic
lutils.lightning_endangered = function(entity)
    if categories.without_health[entity.type] or entity.type == "lightning-attractor" then
        return false
    end
    for _, planet in pairs(data.raw.planet or {}) do
        if planet.lightning_properties ~= nil then
            local is_exempt = false
            for _, rule in pairs(planet.lightning_properties.exemption_rules or {}) do
                if (rule.type == "prototype" and rule.string == entity.type) or (rule.type == "id" and rule.string == entity.name) then
                    is_exempt = true
                end
            end
            if not is_exempt then
                return true
            end
        end
    end
    return false
end

-- Rooms where operating a delivered building may count as local, if the room can then make the building itself (see notes/bootstrap-infrastructure.txt and lib/logic/bootstrap.lua, which prunes them)
-- Only heat sources (categories.heat_producers) on the planets in lutils.bootstrap_heat_rooms, and any building on the planets lutils.lightning_lost_rooms names: elsewhere, like vanilla Aquilo, it adds no contexts, and each logic build then skips the extra sorts
-- The heat rooms are set by a planetary change that makes planets freeze (randomizations/planetary/freezing.lua)
lutils.bootstrap_heat_rooms = {}

-- The planets a planetary change left without the lightning they had, as room key --> true; none unless randomizations/planetary/lightning.lua sets this to its own function
-- Lightning was their power, so any building may be delivered to start them again (user, 2026-09-30), like a recycler and solar panels on Fulgora, whose scrap then makes more of both
-- It's a function of the game as it is, so it stays right when a stage puts the game back
lutils.lightning_lost_rooms = function()
    return {}
end

-- The bootstrap rooms for an entity, as a sorted list of room keys
lutils.bootstrap_rooms = function(entity)
    local is_room = {}
    if categories.heat_producers[entity.type] then
        for room_key, _ in pairs(lutils.bootstrap_heat_rooms) do
            is_room[room_key] = true
        end
    end
    for room_key, _ in pairs(lutils.lightning_lost_rooms()) do
        is_room[room_key] = true
    end
    local rooms = {}
    for room_key, _ in pairs(is_room) do
        table.insert(rooms, room_key)
    end
    table.sort(rooms)
    return rooms
end

-- Whether the entity freezes on a planet whose entities require heating (PlanetPrototype::entities_require_heating)
-- An entity can freeze if its heating_energy is larger than zero (EntityPrototype::heating_energy); Space Age gives it to the buildings that freeze on Aquilo (space-age/base-data-updates.lua), and the rest, like characters, electric poles and stone furnaces, don't freeze
lutils.check_freezable = function(entity)
    return entity.heating_energy ~= nil and util.parse_energy(entity.heating_energy) > 0
end

return lutils