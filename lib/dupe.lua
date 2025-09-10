local categories = require("helper-tables/categories")

local rng = require("lib/random/rng")
local locale_utils = require("lib/locale")
local patching = require("lib/patching")

local resource_autoplace = require("resource-autoplace")

-- TODO: This file is really messy and a lot of functionality could be factored out into separate functions, maybe clean this up

-- Note: Duplicating the both the item and recipe for the same thing may cause issues with icons and possibly worse right now

local dupe = {}

-- To dupe:
--   * Important recipes
--   * Tech unlocks (to some extent, maybe not all?)

local dupe_number_to_filename = {
    "number_one.png",
    "number_two.png",
    "number_three.png",
    "number_four.png",
    "number_five.png",
    "number_six.png",
    "number_seven.png",
    "number_eight.png",
    "number_nine.png",
}

dupe.prototype = function(prototype, dupe_number)
    local new_prototype = table.deepcopy(prototype)

    -- Need to add the -copy at the end to prevent the special behavior for technology prototypes with -number at end of prototype names
    new_prototype.name = new_prototype.name .. "-exfret-" .. tostring(dupe_number) .. "-copy"
    new_prototype.localised_name = {"propertyrandomizer.dupe", locale_utils.find_localised_name(prototype), tostring(dupe_number)}
    -- For help in localisation later
    new_prototype.orig_name = prototype.name
    new_prototype.dupe_number = dupe_number

    data:extend({
        new_prototype
    })

    return new_prototype
end

dupe.recipe = function(recipe, dupe_number)
    local new_recipe = dupe.prototype(recipe, dupe_number)
    -- Recipes get special dupe names to distinguish them from an item that's duplicated
    new_recipe.localised_name = {"propertyrandomizer.recipe_dupe", locale_utils.find_localised_name(recipe), tostring(dupe_number)}

    -- Recipe tech unlocks
    for _, technology in pairs(data.raw.technology) do
        if technology.effects ~= nil then
            for _, effect in pairs(technology.effects) do
                if effect.type == "unlock-recipe" and effect.recipe == recipe.name then
                    table.insert(technology.effects, {
                        type = "unlock-recipe",
                        recipe = new_recipe.name
                    })
                end
            end
        end
    end

    -- Also need to do icon
    local recipe_icons
    if new_recipe.icons == nil and new_recipe.icon == nil then
        local item_with_icon_name
        if new_recipe.main_product ~= nil then
            item_with_icon_name = new_recipe.main_product
        else
            item_with_icon_name = new_recipe.results[1].name
        end
        local item_with_icon
        for item_class, _ in pairs(defines.prototypes.item) do
            if data.raw[item_class] ~= nil then
                if data.raw[item_class][item_with_icon_name] ~= nil then
                    item_with_icon = data.raw[item_class][item_with_icon_name]
                end
            end
        end
        if data.raw.fluid[item_with_icon_name] ~= nil then
            item_with_icon = data.raw.fluid[item_with_icon_name]
        end
        if item_with_icon.icons ~= nil then
            recipe_icons = item_with_icon.icons
        else
            recipe_icons = {
                {
                    icon = item_with_icon.icon,
                    icon_size = item_with_icon.icon_size or 64
                }
            }
        end
    elseif new_recipe.icons == nil then
        recipe_icons = {
            {
                icon = new_recipe.icon,
                icon_size = new_recipe.icon_size or 64
            }
        }
    else
        recipe_icons = new_recipe.icons
    end
    new_recipe.icons = recipe_icons
    table.insert(new_recipe.icons, {
        icon = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number],
        icon_size = 120,
        scale = 1 / 6,
        shift = {7, -7}
    })

    return new_recipe
end

dupe.item = function(item, dupe_number)
    local new_item = dupe.prototype(item, dupe_number)

    -- Check if there was a recipe for this item and duplicate it if so
    if data.raw.recipe[item.name] ~= nil then
        local new_item_recipe = dupe.recipe(data.raw.recipe[item.name], dupe_number)
        -- Override recipe's special localised name and icon
        new_item_recipe.localised_name = {"propertyrandomizer.dupe", locale_utils.find_localised_name(item), tostring(dupe_number)}
        new_item_recipe.icons[#new_item_recipe.icons].shift[1] = -new_item_recipe.icons[#new_item_recipe.icons].shift[1]
        patching.replace_ing_or_result(new_item_recipe.results, "item", item.name, {
            type = "item",
            name = new_item.name,
            amount = 1
        })
    end

    for _, icon_prefix_type in pairs({"", "dark_background_"}) do
        if new_item[icon_prefix_type .. "icon"] ~= nil or new_item[icon_prefix_type .. "icons"] ~= nil then
            local item_icons
            if new_item[icon_prefix_type .. "icons"] == nil then
                item_icons = {
                    {
                        icon = new_item[icon_prefix_type .. "icon"],
                        icon_size = new_item[icon_prefix_type .. "icon_size"] or 64
                    }
                }
            else
                item_icons = new_item[icon_prefix_type .. "icons"]
            end
            table.insert(item_icons, {
                [icon_prefix_type .. "icon"] = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number],
                [icon_prefix_type .. "icon_size"] = 120,
                scale = 1 / 6,
                shift = {-7, -7}
            })
            new_item[icon_prefix_type .. "icons"] = item_icons
        end
    end

    return new_item
end

dupe.technology = function(tech, dupe_number)
    -- Test for special behavior for techs whose name ends with a -number
    local prefix, suffix = tech.name:match("^(.*)%-(%d+)$")

    local new_tech = dupe.prototype(tech, dupe_number)
    -- Add the suffix back on
    if suffix ~= nil and tonumber(suffix) ~= nil then
        data.raw.technology[new_tech.name] = nil
        new_tech.name = prefix .. "-exfret-" .. tostring(dupe_number) .. "-copy-" .. suffix
        data.raw.technology[new_tech.name] = new_tech
    end

    if new_tech.icon ~= nil or new_tech.icons ~= nil then
        local tech_icons
        if new_tech.icons == nil then
            tech_icons = {
                {
                    icon = new_tech.icon,
                    icon_size = new_tech.icon_size or 64
                }
            }
        else
            tech_icons = new_tech.icons
        end
        new_tech.icons = tech_icons
        table.insert(tech_icons, {
            icon = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number],
            icon_size = 120,
            scale = 1 / 3,
            shift = {-40, -40}
        })
    end

    local new_prerequisites = {}
    if new_tech.prerequisites ~= nil then
        for _, prereq in pairs(new_tech.prerequisites) do
            local prereq_prefix, prereq_suffix = prereq:match("^(.*)%-(%d+)$")
            if prereq_suffix ~= nil and tonumber(prereq_suffix) ~= nil then
                table.insert(new_prerequisites, prereq_prefix .. "-exfret-" .. tostring(dupe_number) .. "-copy-" .. prereq_suffix)
            else
                table.insert(new_prerequisites, prereq .. "-exfret-" .. tostring(dupe_number) .. "-copy")
            end
        end
    end
    new_tech.prerequisites = new_prerequisites

    return new_tech
end

local function add_icon_to_anim(anim, dupe_number)
    local frame_count
    local direction_count
    local run_mode
    local layer = anim
    while true do
        if layer.layers == nil then
            local frame_sequence_count
            if layer.frame_sequence ~= nil then
                frame_sequence_count = #layer.frame_sequence
            end

            frame_count = (frame_sequence_count or layer.frame_count or 1) * (layer.repeat_count or 1)

            if layer.direction_count ~= nil then
                direction_count = layer.direction_count
            else
                direction_count = 1
            end

            run_mode = layer.run_mode or "forward"
            if layer.run_mode == "forward-then-backward" then
                frame_count = 2 * frame_count - 2
            end

            break
        else
            layer = layer.layers[1]
        end
    end

    local filenames = {}
    for i = 1, direction_count do
        table.insert(filenames, "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number])
    end

    return {
        layers = {
            anim,
            {
                filenames = filenames,
                lines_per_file = 1,
                width = 120,
                height = 120,
                repeat_count = frame_count,
                frame_count = 1,
                scale = 0.3,
                shift = {-0.5, -0.5}
            }
        }
    }
end

dupe.entity = function(entity, dupe_number)
    local new_entity = dupe.prototype(entity, dupe_number)

    -- If this entity is placeable duplicate its item
    local associated_item
    if new_entity.placeable_by ~= nil then
        if new_entity.placeable_by.item ~= nil then
            new_entity.placeable_by = {new_entity.placeable_by}
        end
        if #new_entity.placeable_by == 1 then
            associated_item = new_entity.placeable_by[1].item
        end
    end
    if associated_item == nil then
        for item_class, _ in pairs(defines.prototypes.item) do
            if data.raw[item_class] ~= nil then
                for _, item in pairs(data.raw[item_class]) do
                    if item.place_result == entity.name then
                        -- This technically doesn't work if multiple things can place the same thing, but that's uncommon
                        associated_item = item
                    end
                end
            end
        end
    end
    if associated_item ~= nil then
        local new_entity_item = dupe.item(associated_item, dupe_number)
        new_entity_item.place_result = new_entity.name
        if new_entity.minable ~= nil then
            if new_entity.minable.result == associated_item.name then
                new_entity.minable.result = new_entity_item.name
            elseif new_entity.minable.results ~= nil and #new_entity.minable.results == 1 and new_entity.minable.results[1].type == "item" and new_entity.minable.results[1].name == associated_item.name then
                new_entity.minable.results[1].name = new_entity_item.name
            end
        end
    end

    -- TODO: Upgrades, pasteable entities, icons, items with this as their plant result

    return new_entity
end

dupe.rolling_stock = function(rolling_stock, dupe_number)
    local new_rolling_stock = dupe.entity(rolling_stock, dupe_number)

    -- Change graphics
    if new_rolling_stock.pictures ~= nil then
        local direction_count
        local layer = new_rolling_stock.pictures.rotated
        while true do
            if layer.direction_count then
                direction_count = layer.direction_count
                break
            else
                layer = layer.layers[1]
            end
        end
        local frames = {}
        for i = 1, direction_count do
            table.insert(frames, {
                x = -(i - 1) * 120
            })
        end
        new_rolling_stock.pictures.rotated = {
            layers = {
                new_rolling_stock.pictures.rotated,
                {
                    filename = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number],
                    size = 120,
                    direction_count = direction_count,
                    frames = frames,
                    scale = 0.6
                }
            }
        }
    end

    return new_rolling_stock
end

dupe.turret = function(turret, dupe_number)
    local new_turret = dupe.entity(turret, dupe_number)

    -- Change graphics
    for _, animation_type in pairs({"folded_animation", "preparing_animation", "prepared_animation", "prepared_alternative_animation", "starting_attack_animation", "attacking_animation", "ending_attack_animation", "folding_animation"}) do
        if new_turret[animation_type] ~= nil then
            if new_turret[animation_type].north ~= nil then
                for dir_key, dir_anim in pairs(new_turret[animation_type]) do
                    if dir_anim.filename ~= nil or dir_anim.layers ~= nil then
                        new_turret[animation_type][dir_key] = add_icon_to_anim(dir_anim, dupe_number)
                    else
                        for key, anim in pairs(dir_anim) do
                            dir_anim[key] = add_icon_to_anim(anim, dupe_number)
                        end
                    end
                end
            else
                if new_turret[animation_type].filename ~= nil or new_turret[animation_type].layers ~= nil then
                    new_turret[animation_type] = add_icon_to_anim(new_turret[animation_type], dupe_number)
                else
                    for key, anim in pairs(new_turret[animation_type]) do
                        new_turret[animation_type][key] = add_icon_to_anim(anim, dupe_number)
                    end
                end
            end
        end
    end

    return new_turret
end

dupe.robot = function(robot, dupe_number)
    local new_robot = dupe.entity(robot, dupe_number)

    -- Graphics
    local anim_keys = {"idle", "in_motion"}
    if robot.type == "construction-robot" then
        table.insert(anim_keys, "working")
    end
    for _, animation_type in pairs(anim_keys) do
        if new_robot[animation_type] ~= nil then
            if new_robot[animation_type].filename ~= nil or new_robot[animation_type].layers ~= nil then
                new_robot[animation_type] = add_icon_to_anim(new_robot[animation_type], dupe_number)
            else
                for key, anim in pairs(new_robot[animation_type]) do
                    new_robot[animation_type][key] = add_icon_to_anim(anim, dupe_number)
                end
            end
        end
    end

    return new_robot
end

dupe.roboport = function(roboport, dupe_number)
    local new_roboport = dupe.entity(roboport, dupe_number)

    for _, animation_type in pairs({"door_animation_up", "door_animation_down"}) do
        new_roboport[animation_type] = add_icon_to_anim(new_roboport[animation_type], dupe_number)
    end

    return new_roboport
end

dupe.logistic_container = function(logistic_container, dupe_number)
    local new_logistic_container = dupe.entity(logistic_container, dupe_number)

    if new_logistic_container.animation ~= nil then
        new_logistic_container.animation = add_icon_to_anim(new_logistic_container.animation, dupe_number)
    end
    if new_logistic_container.picture ~= nil then
        new_logistic_container.picture = {
            layers = {
                new_logistic_container.picture,
                {
                    filename = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number],
                    size = 120,
                    scale = 0.6,
                    shift = {-0.5, -0.5}
                }
            }
        }
    end

    return new_logistic_container
end

dupe.boiler = function(boiler, dupe_number)
    local new_boiler = dupe.entity(boiler, dupe_number)

    if new_boiler.pictures ~= nil then
        for _, pictures in pairs(new_boiler.pictures) do
            pictures.structure = add_icon_to_anim(pictures.structure, dupe_number)
        end
    end

    return new_boiler
end

dupe.generator = function(generator, dupe_number)
    local new_generator = dupe.entity(generator, dupe_number)

    for _, animation_type in pairs({"horizontal_animation", "vertical_animation"}) do
        if new_generator[animation_type] ~= nil then
            new_generator[animation_type] = add_icon_to_anim(new_generator[animation_type], dupe_number)
        end
    end

    return new_generator
end

dupe.solar_panel = function(solar_panel, dupe_number)
    local new_solar_panel = dupe.entity(solar_panel, dupe_number)

    if new_solar_panel.picture ~= nil then
        if new_solar_panel.picture.sheet ~= nil then
            new_solar_panel.picture.sheet = add_icon_to_anim(new_solar_panel.picture.sheet, dupe_number)
        elseif new_solar_panel.picture[1] ~= nil then
            for key, sprite in pairs(new_solar_panel.picture) do
                new_solar_panel.picture[key] = {
                    layers = {
                        new_solar_panel.picture,
                        {
                            filename = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number],
                            size = 120,
                            scale = 0.6,
                            shift = {-0.5, -0.5}
                        }
                    }
                }
            end
        else
            new_solar_panel.picture = add_icon_to_anim(new_solar_panel.picture, dupe_number)
        end
    end

    return new_solar_panel
end

dupe.reactor = function(reactor, dupe_number)
    local new_reactor = dupe.entity(reactor, dupe_number)

    if new_reactor.picture ~= nil then
        new_reactor.picture = {
            layers = {
                new_reactor.picture,
                {
                    filename = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number],
                    size = 120,
                    scale = 0.6,
                    shift = {-0.5, -0.5}
                }
            }
        }
    end

    return new_reactor
end

dupe.crafting_machine = function(crafting_machine, dupe_number)
    local new_crafting_machine = dupe.entity(crafting_machine, dupe_number)

    if new_crafting_machine.graphics_set ~= nil then
        if new_crafting_machine.graphics_set.animation ~= nil then
            if new_crafting_machine.graphics_set.animation.north ~= nil then
                for dir_key, dir_anim in pairs(new_crafting_machine.graphics_set.animation) do
                    if dir_anim.filename ~= nil or dir_anim.layers ~= nil then
                        new_crafting_machine.graphics_set.animation[dir_key] = add_icon_to_anim(dir_anim, dupe_number)
                    else
                        for key, anim in pairs(dir_anim) do
                            dir_anim[key] = add_icon_to_anim(anim, dupe_number)
                        end
                    end
                end
            else
                if new_crafting_machine.graphics_set.animation.filename ~= nil or new_crafting_machine.graphics_set.animation.layers ~= nil then
                    new_crafting_machine.graphics_set.animation = add_icon_to_anim(new_crafting_machine.graphics_set.animation, dupe_number)
                else
                    for key, anim in pairs(new_crafting_machine.graphics_set.animation) do
                        new_crafting_machine.graphics_set.animation[key] = add_icon_to_anim(anim, dupe_number)
                    end
                end
            end
        end
    end

    return new_crafting_machine
end

dupe.beacon = function(beacon, dupe_number)
    local new_beacon = dupe.entity(beacon, dupe_number)

    if new_beacon.graphics_set ~= nil then
        if new_beacon.graphics_set.animation_list then
            for _, anim in pairs(new_beacon.graphics_set.animation_list) do
                if anim.animation ~= nil then
                    anim.animation = add_icon_to_anim(anim.animation, dupe_number)
                end
            end
        end
    end

    return new_beacon
end

dupe.mining_drill = function(mining_drill, dupe_number)
    local new_mining_drill = dupe.entity(mining_drill, dupe_number)

    for _, graphics_set_key in pairs({"graphics_set", "wet_mining_graphics_set"}) do
        if new_mining_drill[graphics_set_key] ~= nil then
            if new_mining_drill[graphics_set_key].working_visualisations ~= nil then
                for _, anim_key in pairs({--[["animation",]] "north_animation", "east_animation", "south_animation", "west_animation"}) do
                    for _, working_vis in pairs(new_mining_drill[graphics_set_key].working_visualisations) do
                        if working_vis[anim_key] ~= nil then
                            working_vis[anim_key] = add_icon_to_anim(working_vis[anim_key], dupe_number)
                            -- Only add to one working visualization
                            --break
                        end
                    end
                end
            else
                for _, anim_key in pairs({"animation", "idle_animation"}) do
                    if new_mining_drill[graphics_set_key][anim_key] ~= nil then
                        if new_mining_drill[graphics_set_key][anim_key].north ~= nil then
                            for dir_key, dir_val in pairs(new_mining_drill[graphics_set_key][anim_key]) do
                                new_mining_drill[graphics_set_key][anim_key][dir_key] = add_icon_to_anim(dir_val, dupe_number)
                            end
                        else
                            new_mining_drill[graphics_set_key][anim_key] = add_icon_to_anim(new_mining_drill[graphics_set_key][anim_key], dupe_number)
                        end
                    end
                end
            end
        end
    end

    return new_mining_drill
end

dupe.resource = function(resource, dupe_number)
    new_resource = dupe.entity(resource, dupe_number)

    local function recursively_invert_colors(layer)
        if layer.layers ~= nil then
            for _, new_layer in pairs(layer.layers) do
                recursively_invert_colors(new_layer)
            end
        else
            layer.invert_colors = treu
        end
    end

    if new_resource.stages ~= nil then
        if new_resource.stages.sheet ~= nil then
        elseif new_resource.stages.sheets ~= nil then
            for _, anim in pairs(new_resource.stages.sheets) do
                recursively_invert_colors(anim)
            end
        elseif new_resource.stages.layers ~= nil or new_resource.stages.filename ~= nil or new_resource.stages.filenames ~= nil then
            recursively_invert_colors(anim)
        else
            for _, anim in pairs(new_resource.stages) do
                recursively_invert_colors(anim)
            end
        end
    end

    return new_resource
end

dupe.equipment = function(equipment, dupe_number)
    local new_equipment = dupe.prototype(equipment, dupe_number)

    local old_item_name = equipment.take_result or equipment.name
    local old_item
    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil and data.raw[item_class][old_item_name] then
            old_item = data.raw[item_class][old_item_name]
            break
        end
    end
    local new_item = dupe.item(old_item, dupe_number)
    new_item.place_as_equipment_result = new_equipment.name
    new_equipment.take_result = new_item.name

    new_equipment.sprite = {
        layers = {
            new_equipment.sprite,
            {
                filename = "__propertyrandomizer__/graphics/" .. dupe_number_to_filename[dupe_number],
                size = 120,
                scale = 0.3,
                shift = {-15, -15}
            }
        }
    }

    return new_equipment
end

-- Create the duplicates
dupe.execute = function()
    if settings.startup["propertyrandomizer-watch-the-world-burn"].value then
        -- Tech tree
        local techs_to_dupe = {}
        for _, tech in pairs(data.raw.technology) do
            table.insert(techs_to_dupe, tech)
        end
        for _, tech in pairs(techs_to_dupe) do
            for i = 2, 3 do
                dupe.technology(tech, i)
            end
        end
    end

    -- Duplicate science pack recipes
    for _, science_pack in pairs(data.raw.tool) do
        if data.raw.recipe[science_pack.name] ~= nil then
            dupe.recipe(data.raw.recipe[science_pack.name], 2)
        end
    end
    dupe.recipe(data.raw.recipe["rocket-part"], 2)

    local items_to_dupe = {}
    for _, ammo in pairs(data.raw.ammo) do
        table.insert(items_to_dupe, ammo)
    end
    for _, item in pairs(items_to_dupe) do
        dupe.item(item, 2)
    end

    local rolling_stock_to_dupe = {}
    for _, locomotive in pairs(data.raw.locomotive) do
        table.insert(rolling_stock_to_dupe, locomotive)
    end
    for _, rolling_stock in pairs(rolling_stock_to_dupe) do    
        dupe.rolling_stock(rolling_stock, 2)
    end

    local turrets_to_dupe = {}
    for turret_category, _ in pairs(categories.turrets) do
        for _, turret in pairs(data.raw[turret_category]) do
            table.insert(turrets_to_dupe, turret)
        end
    end
    for _, turret in pairs(turrets_to_dupe) do
        dupe.turret(turret, 2)
    end

    local robots_to_dupe = {}
    for _, bot_class in pairs({"construction-robot", "logistic-robot"}) do
        for _, bot in pairs(data.raw[bot_class]) do
            table.insert(robots_to_dupe, bot)
        end
    end
    for _, robot in pairs(robots_to_dupe) do
        dupe.robot(robot, 2)
    end

    local roboports_to_dupe = {}
    for _, roboport in pairs(data.raw.roboport) do
        table.insert(roboports_to_dupe, roboport)
    end
    for _, roboport in pairs(roboports_to_dupe) do
        dupe.roboport(roboport, 2)
    end

    -- Add logistic chests, mainly for recipe rando or other graph randos
    local logistic_containers_to_dupe = {}
    for _, logistic_container in pairs(data.raw["logistic-container"]) do
        table.insert(logistic_containers_to_dupe, logistic_container)
    end
    for _, logistic_container in pairs(logistic_containers_to_dupe) do
        dupe.logistic_container(logistic_container, 2)
    end

    local boilers_to_dupe = {}
    for _, boiler in pairs(data.raw.boiler) do
        table.insert(boilers_to_dupe, boiler)
    end
    for _, boiler in pairs(boilers_to_dupe) do
        dupe.boiler(boiler, 2)
    end

    local generators_to_dupe = {}
    for _, generator in pairs(data.raw.generator) do
        table.insert(generators_to_dupe, generator)
    end
    for _, generator in pairs(generators_to_dupe) do
        dupe.generator(generator, 2)
    end

    local solar_panels_to_dupe = {}
    for _, solar_panel in pairs(data.raw["solar-panel"]) do
        table.insert(solar_panels_to_dupe, solar_panel)
    end
    for _, solar_panel in pairs(solar_panels_to_dupe) do
        dupe.solar_panel(solar_panel, 2)
    end

    local reactors_to_dupe = {}
    for _, reactor in pairs(data.raw.reactor) do
        table.insert(reactors_to_dupe, reactor)
    end
    for _, reactor in pairs(reactors_to_dupe) do
        dupe.reactor(reactor, 2)
    end

    if data.raw["agricultural-tower"] ~= nil then
        local ag_towers_to_dupe = {}
        for _, ag_tower in pairs(data.raw["agricultural-tower"]) do
            table.insert(ag_towers_to_dupe, ag_tower)
        end
        for _, ag_tower in pairs(ag_towers_to_dupe) do
            -- Agricultural towers have the same graphics to be changed as crafting machines
            dupe.crafting_machine(ag_tower, 2)
        end
    end

    local crafting_machines_to_dupe = {}
    for crafting_machine_class, _ in pairs(categories.crafting_machines) do
        for _, crafting_machine in pairs(data.raw[crafting_machine_class]) do
            local to_duplicate = true
            if to_duplicate then
                table.insert(crafting_machines_to_dupe, crafting_machine)
            end
        end
    end
    for _, crafting_machine in pairs(crafting_machines_to_dupe) do
        dupe.crafting_machine(crafting_machine, 2)
    end

    local beacons_to_dupe = {}
    for _, beacon in pairs(data.raw.beacon) do
        table.insert(beacons_to_dupe, beacon)
    end
    for _, beacon in pairs(beacons_to_dupe) do
        dupe.beacon(beacon, 2)
    end

    local mining_drills_to_dupe = {}
    for _, mining_drill in pairs(data.raw["mining-drill"]) do
        table.insert(mining_drills_to_dupe, mining_drill)
    end
    for _, mining_drill in pairs(mining_drills_to_dupe) do
        dupe.mining_drill(mining_drill, 2)
    end

    local equipment_to_dupe = {}
    for equipment_class, _ in pairs(defines.prototypes.equipment) do
        if data.raw[equipment_class] ~= nil then
            for _, equipment in pairs(data.raw[equipment_class]) do
                if equipment.type ~= "equipment-ghost" then
                    table.insert(equipment_to_dupe, equipment)
                end
            end
        end
    end
    for _, equipment in pairs(equipment_to_dupe) do
        dupe.equipment(equipment, 2)
    end

    if settings.startup["propertyrandomizer-watch-the-world-burn"].value then
        for _, resource in pairs(data.raw.resource) do
            dupe.resource(resource, 2)
        end
    end
end

return dupe