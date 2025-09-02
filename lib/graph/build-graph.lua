local collision_mask_util
if not offline then
    collision_mask_util = require("__core__/lualib/collision-mask-util")
else
    collision_mask_util = require("offline/lualib/collision-mask-util")
end

local build_graph = {}

local graph

-- TODO
--   * create general "can be placed down on tile" function and use that in the offshore function
--   * deal with hidden recipes/techs, like recipe-unknown
--   * rocket-part-recipe should respect fixed-recipe (also double check it checks what the silo can do)
--   * code in that burner machines are inoperable in space (that might already just be part of a surface condition)
--   * add prototypes to graph information
--   * figure out why explosions are reachable
--   * add corpses (like stomper corpses)
--   * test for planets that are discovered from start, like nauvis, not just ones you start on
--   * check for ice melting (wait was that just someone trolling me?)
--   * check that surface condition checking works well
--   * minability tech nodes (like researching ability to mine uranium in base game)
--   * add dependence for solar that solar percent is >5% or so (aquilo has some but it shouldn't be relied on)
--   * min working temperatures?
--   * make technologies (and maybe some other things) use item-surface rather than item
--   * add in some basic connections to force certain things earlier, like early automation
--   * prereq/dependent "ID"s so we can figure out which prereqs correspond to which dependents

----------------------------------------------------------------------
-- Utility
----------------------------------------------------------------------

-- Get key from type + name

local function key(node_type, node_name)
    return node_type .. "aaa" .. node_name
end
-- export for other files to use
build_graph.key = key

-- Turn a table/list of strings into a string

local function compound_key(tbl)
    -- serpent.block wasn't working for some reason?
    local separator = "bbb"
    local my_str = ""
    for _, entry in pairs(tbl) do
        my_str = my_str .. separator .. tostring(entry)
    end
    -- Remove initial bbb
    return string.sub(my_str, 4, -1)
end
-- export for other files to use
build_graph.compound_key = compound_key

-- Connections into strings
-- This is used in other places but not here, this just makes the most sense to put it here

local function conn_key(conn)
    return compound_key({key(conn[1].type, conn[1].name), key(conn[2].type, conn[2].name)})
end
-- export
build_graph.conn_key = conn_key

-- Add node to graph

-- extra_info is optional additional data to decorate the node with
local function add_to_graph(node_type, node_name, prereqs, extra_info)
    graph[key(node_type, node_name)] = {
        type = node_type,
        name = node_name,
        prereqs = prereqs
    }

    if extra_info ~= nil then
        for k, v in pairs(extra_info) do
            graph[key(node_type, node_name)][k] = v
        end
    end
end

-- Get surfaces

local surfaces = {}
for _, planet in pairs(data.raw.planet) do
    surfaces[compound_key({"planet", planet.name})] = {
        type = "planet",
        name = planet.name,
        -- Don't store the full prototype for optimization reasons
        prototype = {
            type = planet.type,
            name = planet.name,
            map_gen_settings = planet.map_gen_settings,
            surface_properties = planet.surface_properties,
            lightning_properties = planet.lightning_properties,
            entities_require_heating = planet.entities_require_heating
        }
    }
end
if data.raw.surface ~= nil then
    for _, surface in pairs(data.raw.surface) do
        surfaces[compound_key({"space-surface", surface.name})] = {
            type = "space-surface",
            name = surface.name,
            prototype = {
                type = surface.type,
                name = surface.name,
                surface_properties = surface.surface_properties
            }
        }
    end
end
-- export
build_graph.surfaces = surfaces

-- Get materials

local materials = {}
for item_class, _ in pairs(defines.prototypes.item) do
    if data.raw[item_class] ~= nil then
        for _, item in pairs(data.raw[item_class]) do
            materials["item-" .. item.name] = item
        end
    end
end
for _, fluid in pairs(data.raw.fluid) do
    materials["fluid-" .. fluid.name] = fluid
end

-- Get recipe categories

local function recipe_to_num_fluids(recipe)
    local num_input_fluids = 0
    local num_output_fluids = 0

    if recipe.ingredients ~= nil then
        for _, ingredient in pairs(recipe.ingredients) do
            if ingredient.type == "fluid" then
                num_input_fluids = num_input_fluids + 1
            end
        end
    end
    -- TODO: find out if there are duplicate fluid results (multiple results of the same fluid), whether we need one fluid box for each
    if recipe.results ~= nil then
        for _, result in pairs(recipe.results) do
            if result.type == "fluid" then
                num_output_fluids = num_output_fluids + 1
            end
        end
    end

    return {input_fluids = num_input_fluids, output_fluids = num_output_fluids}
end
local function recipe_to_spoofed_category_name(recipe)
    local fluid_amounts = recipe_to_num_fluids(recipe)
    local num_input_fluids = fluid_amounts.input_fluids
    local num_output_fluids = fluid_amounts.output_fluids

    return compound_key({recipe.category or "crafting", num_input_fluids, num_output_fluids})
end
local spoofed_recipe_categories = {}
for _, recipe in pairs(data.raw.recipe) do
    local spoofed_category_name = recipe_to_spoofed_category_name(recipe)
    if spoofed_recipe_categories[spoofed_category_name] == nil then
        local fluid_amounts = recipe_to_num_fluids(recipe)

        spoofed_recipe_categories[spoofed_category_name] = {
            recipe_category = data.raw["recipe-category"][recipe.category or "crafting"],
            input_fluids = fluid_amounts.input_fluids,
            output_fluids = fluid_amounts.output_fluids
        }
    end
end

-- Get resource categories

local function resource_to_fluids(resource)
    if resource.minable == nil then
        return {}
    end

    local input_fluid = resource.minable.required_fluid
    local output_fluid
    if resource.minable.results ~= nil then
        for _, result in pairs(resource.minable.results) do
            if result.type == "fluid" then
                -- If output_fluid is already set, then this produces two fluids and thus can't be mined
                if output_fluid ~= nil then
                    return ""
                else
                    output_fluid = result.name
                end
            end
        end
    end

    return {input_fluid = input_fluid, output_fluid = output_fluid}
end
local function resource_to_spoofed_category_name(resource)
    if resource.minable == nil then
        return ""
    end

    local category = resource.category or "basic-solid"

    local fluid_names = resource_to_fluids(resource)

    return compound_key({category, fluid_names.input_fluid, fluid_names.output_fluid})
end
local spoofed_resource_categories = {}
for _, resource in pairs(data.raw.resource) do
    local spoofed_category_name = resource_to_spoofed_category_name(resource)
    if spoofed_resource_categories[spoofed_category_name] == nil then
        local fluid_amounts = resource_to_fluids(resource)

        spoofed_resource_categories[spoofed_category_name] = {
            resource_category = data.raw["resource-category"][resource.category or "basic-solid"],
            input_fluid = fluid_amounts.input_fluid,
            output_fluid = fluid_amounts.output_fluid
        }
    end
end

-- Get science pack sets

local science_pack_sets = {}
for _, tech in pairs(data.raw.technology) do
    if tech.unit ~= nil then
        local science_pack_set = {}
        for _, ing in pairs(tech.unit.ingredients) do
            table.insert(science_pack_set, ing[1])
        end
        table.sort(science_pack_set)
        if science_pack_sets[compound_key(science_pack_set)] == nil then
            science_pack_sets[compound_key(science_pack_set)] = science_pack_set
        end
    end
end

-- Tables

local crafting_machine_classes = {
    ["assembling-machine"] = true,
    furnace = true,
    ["rocket-silo"] = true
}

-- is_crafting_machine_compatible_with_recipe

-- TODO: Also look at maximum crafting ingredient restrictions
-- TODO: FluidBox filter checks
local function is_crafting_machine_compatible_with_recipe_category(crafting_machine, spoofed_category)
    local num_accepted_input_fluids = 0
    local num_accepted_output_fluids = 0

    if crafting_machine.fluid_boxes ~= nil then
        for _, fluid_box in pairs(crafting_machine.fluid_boxes) do
            if fluid_box.production_type == "input" then
                num_accepted_input_fluids = num_accepted_input_fluids + 1
            elseif fluid_box.production_type == "output" then
                num_accepted_output_fluids = num_accepted_output_fluids + 1
            end
        end
    end

    local has_crafting_category = false
    for _, crafting_category in pairs(crafting_machine.crafting_categories) do
        if crafting_category == spoofed_category.recipe_category.name then
            has_crafting_category = true
        end
    end

    if has_crafting_category and num_accepted_input_fluids >= spoofed_category.input_fluids and num_accepted_output_fluids >= spoofed_category.output_fluids then
        return true
    end

    return false
end

-- Trigger tables helpers

function build_graph.gather_targets_trigger_effect(trigger_effect, target_type)
    local targets = {}

    if trigger_effect.type == "create-entity" then
        if target_type == "entity" then
            table.insert(targets, trigger_effect.entity_name)
        end
    end

    if trigger_effect.type == "nested-result" then
        for _, target in pairs(build_graph.gather_targets_trigger(trigger_effect.action, target_type)) do
            table.insert(targets, target)
        end
    end

    return targets
end

function build_graph.gather_targets_trigger_delivery(trigger_delivery, target_type)
    local targets = {}

    if trigger_delivery.type == "projectile" then
        if target_type == "entity" then
            table.insert(targets, trigger_delivery.projectile)
        end
    end

    for _, key in pairs({"source_effects", "target_effects"}) do
        if trigger_delivery[key] ~= nil then
            if trigger_delivery[key].type == nil then
                for _, trigger_effect in pairs(trigger_delivery[key]) do
                    for _, target in pairs(build_graph.gather_targets_trigger_effect(trigger_effect, target_type)) do
                        table.insert(targets, target)
                    end
                end
            else
                for _, target in pairs(build_graph.gather_targets_trigger_effect(trigger_delivery[key], target_type)) do
                    table.insert(targets, target)
                end
            end
        end
    end

    return targets
end

function build_graph.gather_targets_trigger_item(trigger_item, target_type)
    local targets = {}

    if trigger_item.action_delivery ~= nil then
        if trigger_item.action_delivery.type == nil then
            for _, trigger_delivery in pairs(trigger_item.action_delivery) do
                for _, target in pairs(build_graph.gather_targets_trigger_delivery(trigger_delivery, target_type)) do
                    table.insert(targets, target)
                end
            end
        else
            for _, target in pairs(build_graph.gather_targets_trigger_delivery(trigger_item.action_delivery, target_type)) do
                table.insert(targets, target)
            end
        end
    end

    return targets
end

function build_graph.gather_targets_trigger(trigger, target_type)
    local targets = {}

    if trigger.type == nil then
        for _, trigger_effect in pairs(trigger) do
            for _, target in pairs(build_graph.gather_targets_trigger_item(trigger_effect, target_type)) do
                table.insert(targets, target)
            end
        end
    else
        for _, target in pairs(build_graph.gather_targets_trigger_item(trigger, target_type)) do
            table.insert(targets, target)
        end
    end

    return targets
end

-- Check autoplace on surface

local function check_prototype_on_surface(surface, prototype)
    local type_of_autoplace = "entity"
    if prototype.type == "tile" then
        type_of_autoplace = "tile"
    end

    -- TODO: Ask again if there are any other default ways for entities or tiles to show up other than autoplace?
    if surface.type == "planet" then
        local planet = surface.prototype

        if planet.map_gen_settings ~= nil then
            local map_gen_settings = planet.map_gen_settings

            -- TODO: Demystify myself about control versus settings
            if map_gen_settings.autoplace_settings ~= nil then
                local autoplace_settings = map_gen_settings.autoplace_settings[type_of_autoplace]

                if autoplace_settings.settings ~= nil and autoplace_settings.settings[prototype.name] then
                    if autoplace_settings.treat_missing_as_default or prototype.autoplace ~= nil then
                        return true
                    end
                end
            end
            if map_gen_settings.autoplace_controls ~= nil then
                -- Just check that the autoplace exists
                -- TODO: Also check that frequency/size/richness are nonzero etc.
                for control, _ in pairs(map_gen_settings.autoplace_controls) do
                    if prototype.autoplace and prototype.autoplace.control == control then
                        return true
                    end
                end
            end
        end
    end

    return false
end

-- Check surface conditions

local function check_surface_conditions(conditions, surface)
    for _, condition in pairs(conditions) do
        -- Check that this property is in the right range for this surface
        local surface_val = data.raw["surface-property"][condition.property].default_value

        local surface_prototype = surface.prototype

        if surface_prototype.surface_properties ~= nil then
            if surface_prototype.surface_properties[condition.property] ~= nil then
                surface_val = surface_prototype.surface_properties[condition.property]
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
-- export
build_graph.check_surface_conditions = check_surface_conditions

-- Get buildable things
--    * place_result
--    * plant_result
--    * place_as_tile

local buildables = {}
local in_buildables = {}

for _, result_key in pairs({"place_result", "plant_result", "place_as_tile"}) do
    buildables[result_key] = {}
    in_buildables[result_key] = {}
end

for item_class, _ in pairs(defines.prototypes.item) do
    if data.raw[item_class] ~= nil then
        for _, item in pairs(data.raw[item_class]) do
            for _, result_key in pairs({"place_result", "plant_result"}) do
                if item[result_key] ~= nil then
                    for entity_class, _ in pairs(defines.prototypes.entity) do
                        if data.raw[entity_class] ~= nil then
                            if data.raw[entity_class][item[result_key]] ~= nil and not in_buildables[item[result_key]] then
                                table.insert(buildables[result_key], data.raw[entity_class][item[result_key]])
                                in_buildables[result_key][item[result_key]] = true
                            end
                        end
                    end
                end
            end
            if item.place_as_tile ~= nil then
                if not in_buildables[item.place_as_tile] then
                    table.insert(buildables["place_as_tile"], data.raw.tile[item.place_as_tile])
                    in_buildables[item.place_as_tile] = true
                end
            end
        end
    end
end

----------------------------------------------------------------------
-- Restrictions
----------------------------------------------------------------------

-- Restrict which nodes we focus on; we don't care about explosions for example

build_graph.prototypes = {}

build_graph.prototypes.entities = {}
for entity_class, _ in pairs(defines.prototypes.entity) do
    if entity_class ~= "explosion" and entity_class ~= "smoke-with-trigger" then
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                -- Check only minable corpses
                if entity_class ~= "corpse" or entity.minable ~= nil then
                    table.insert(build_graph.prototypes.entities, entity)
                end
            end
        end
    end
end

----------------------------------------------------------------------
-- Nodes
----------------------------------------------------------------------

local function load()
    -- Added to build_graph later
    graph = {}

    local prereqs

    -- agricultural-tower-surface
    log("Adding: agricultural-tower-surface")

    for surface_name, surface in pairs(surfaces) do
        prereqs = {}

        if data.raw["agricultural-tower"] ~= nil then
            for _, ag_tower in pairs(data.raw["agricultural-tower"]) do
                -- TODO: Are there any extra requirements for the agricultural tower?
                table.insert(prereqs, {
                    type = "operate-entity-surface",
                    name = compound_key({ag_tower.name, surface_name})
                })
            end
        end

        add_to_graph("agricultural-tower-surface", surface_name, prereqs, {
            surface = surface_name
        })
    end

    -- asteroid-collection-surface
    log("Adding: asteroid-collection-surface")
    -- Only implemented for space surfaces

    if data.raw.surface ~= nil then
        for _, surface in pairs(data.raw.surface) do
            prereqs = {}

            for _, entity in pairs(build_graph.prototypes.entities) do
                if entity.type == "asteroid-collector" then
                    table.insert(prereqs, {
                        type = "operate-entity-surface",
                        name = compound_key({entity.name, compound_key({"space-surface", surface.name})})
                    })
                end
            end

            add_to_graph("asteroid-collection-surface", surface.name, prereqs, {
                surface = surface_name
            })
        end
    end

    -- build-entity
    log("Adding: build-entity")

    for _, entity in pairs(build_graph.prototypes.entities) do
        prereqs = {}    
        
        for surface_name, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "build-entity-surface",
                name = compound_key({entity.name, surface_name})
            })
        end

        add_to_graph("build-entity", entity.name, prereqs)
    end

    -- build-entity-item
    log("Adding: build-entity-item")

    for _, entity in pairs(build_graph.prototypes.entities) do
        prereqs = {}

        for item_class, _ in pairs(defines.prototypes.item) do
            if data.raw[item_class] ~= nil then
                for _, item in pairs(data.raw[item_class]) do
                    if item.place_result == entity.name then
                        table.insert(prereqs, {
                            type = "item",
                            name = item.name
                        })
                    end
                end
            end
        end

        add_to_graph("build-entity-item", entity.name, prereqs)
    end

    -- build-entity-surface
    log("Adding: build-entity-surface")

    for _, entity in pairs(build_graph.prototypes.entities) do
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            table.insert(prereqs, {
                type = "entity-buildability-surface",
                name = compound_key({entity.name, surface_name})
            })
            table.insert(prereqs, {
                type = "build-entity-item",
                name = entity.name
            })
            table.insert(prereqs, {
                type = "surface",
                name = surface_name
            })

            -- Check buildability conditions
            local surface_conditions_satisfied = true
            if entity.surface_conditions ~= nil then
                surface_conditions_satisfied = check_surface_conditions(entity.surface_conditions, surface)
            end
            if surface_conditions_satisfied then
                table.insert(prereqs, {
                    type = "build-entity-surface-condition-true",
                    name = "canonical"
                })
            else
                table.insert(prereqs, {
                    type = "build-entity-surface-condition-false",
                    name = "canonical"
                })
            end

            -- TODO: If it needs a rail

            add_to_graph("build-entity-surface", compound_key({entity.name, surface_name}), prereqs, {
                surface = surface_name
            })
        end
    end

    -- build-entity-surface-condition-false
    log("Adding: build-entity-surface-condition-false")
    -- OR

    prereqs = {}

    add_to_graph("build-entity-surface-condition-false", "canonical", prereqs)

    -- build-entity-surface-condition-true
    log("Adding: build-entity-surface-condition-true")
    -- AND

    prereqs = {}

    add_to_graph("build-entity-surface-condition-true", "canonical", prereqs)

    -- build-tile
    log("Adding: build-tile")

    for _, tile in pairs(data.raw.tile) do
        prereqs = {}

        for surface_name, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "build-tile-surface",
                name = compound_key({tile.name, surface_name})
            })
        end

        add_to_graph("build-tile", tile.name, prereqs)
    end

    -- build-tile-item-surface
    log("Adding: build-tile-item-surface")

    -- TODO: Put buildability check here as well
    -- TODO: Modify the spec to account for modification to this
    for _, tile in pairs(data.raw.tile) do
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            for item_class, _ in pairs(defines.prototypes.item) do
                if data.raw[item_class] ~= nil then
                    for _, item in pairs(data.raw[item_class]) do
                        -- TODO: Check for conditions
                        if item.place_as_tile ~= nil and item.place_as_tile.result == tile.name then
                            table.insert(prereqs, {
                                type = "build-tile-item-surface-with-item",
                                name = compound_key({tile.name, item.name, surface_name})
                            })
                        end
                    end
                end
            end

            add_to_graph("build-tile-item-surface", compound_key({tile.name, surface_name}), prereqs)
        end
    end

    -- build-tile-item-surface-buildability
    log("Adding: build-tile-item-surface-buildability")

    -- Check actual tile conditions for a tile-item-surface combo
    -- TODO: Add this to the spec
    -- TODO: Account for other conditions like inverted filters
    for _, tile in pairs(data.raw.tile) do
        for item_class, _ in pairs(defines.prototypes.item) do
            if data.raw[item_class] ~= nil then
                for _, item in pairs(data.raw[item_class]) do
                    -- Fail early if this item doesn't have a place_as_tile with result equal to the tile
                    if item.place_as_tile ~= nil and item.place_as_tile.result == tile.name then
                        for surface_name, surface in pairs(surfaces) do
                            prereqs = {}

                            if item.place_as_tile ~= nil then
                                if item.place_as_tile.tile_condition ~= nil then
                                    for _, tile_id in pairs(item.place_as_tile.tile_condition) do
                                        table.insert(prereqs, {
                                            type = "spawn-tile-surface",
                                            name = compound_key({tile_id, surface_name})
                                        })
                                    end
                                else
                                    -- If no condition just assume it's placeable for now
                                    -- TODO: Remove this assumption
                                    table.insert(prereqs, {
                                        type = "build-entity-surface-condition-true",
                                        name = "canonical"
                                    })
                                end
                            end

                            add_to_graph("build-tile-item-surface-buildability", compound_key({tile.name, item.name, surface_name}), prereqs)
                        end
                    end
                end
            end
        end
    end

    -- build-tile-item-surface-with-item
    log("Adding: build-tile-item-surface-with-item")

    -- TODO: Add this to the spec
    for _, tile in pairs(data.raw.tile) do
        for item_class, _ in pairs(defines.prototypes.item) do
            if data.raw[item_class] ~= nil then
                for _, item in pairs(data.raw[item_class]) do
                    -- Fail early if this item doesn't have a place_as_tile with result equal to the tile
                    if item.place_as_tile ~= nil and item.place_as_tile.result == tile.name then
                        for surface_name, surface in pairs(surfaces) do
                            prereqs = {}

                            table.insert(prereqs, {
                                type = "build-tile-item-surface-buildability",
                                name = compound_key({tile.name, item.name, surface_name})
                            })
                            table.insert(prereqs, {
                                type = "item-surface",
                                name = compound_key({item.name, surface_name})
                            })

                            add_to_graph("build-tile-item-surface-with-item", compound_key({tile.name, item.name, surface_name}), prereqs)
                        end
                    end
                end
            end
        end
    end

    -- build-tile-surface
    log("Adding: build-tile-surface")

    for _, tile in pairs(data.raw.tile) do
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            table.insert(prereqs, {
                type = "build-tile-item-surface",
                name = compound_key({tile.name, surface_name})
            })
            table.insert(prereqs, {
                type = "valid-tile-placement-surface",
                name = compound_key({tile.name, surface_name})
            })
            table.insert(prereqs, {
                type = "surface",
                name = surface_name
            })

            add_to_graph("build-tile-surface", compound_key({tile.name, surface_name}), prereqs, {
                surface = surface_name
            })
        end
    end

    -- burn-item
    log("Adding: burn-item")

    -- TODO: Make this instead depend on burn-item-surface
    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                -- Need to check that fuel category is also nil due to jank
                if item.fuel_category ~= nil and item.burnt_result ~= nil then
                    prereqs = {}

                    table.insert(prereqs, {
                        type = "item",
                        name = item.name
                    })
                    table.insert(prereqs, {
                        type = "fuel-category-burner",
                        name = item.fuel_category
                    })

                    add_to_graph("burn-item", item.name, prereqs)
                end
            end
        end
    end

    -- burn-item-surface
    log("Adding: burn-item-surface")

    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                if item.fuel_category ~= nil and item.burnt_result ~= nil then
                    for surface_name, surface in pairs(surfaces) do
                        prereqs = {}

                        table.insert(prereqs, {
                            type = "item-surface",
                            name = compound_key({item.name, surface_name})
                        })
                        table.insert(prereqs, {
                            type = "fuel-category-burner-surface",
                            name = compound_key({item.fuel_category, surface_name})
                        })

                        add_to_graph("burn-item-surface", compound_key({item.name, surface_name}), prereqs)
                    end
                end
            end
        end
    end

    -- capsule-surface
    log("Adding: capsule-surface")

    for _, capsule in pairs(data.raw.capsule) do
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            table.insert(prereqs, {
                type = "item",
                name = capsule.name
            })
            table.insert(prereqs, {
                type = "surface",
                name = surface_name
            })

            add_to_graph("capsule-surface", compound_key({capsule.name, surface_name}), prereqs, {
                surface = surface_name
            })
        end
    end

    -- capture-robot
    log("Adding: capture-robot")

    prereqs = {}

    if data.raw["capture-robot"] ~= nil then
        for _, robot in pairs(data.raw["capture-robot"]) do
            table.insert(prereqs, {
                type = "spawn-entity",
                name = robot.name
            })
        end
    end

    add_to_graph("capture-robot", "canonical", prereqs)

    -- capture-spawner-surface
    log("Adding: capture-spawner-surface")

    for _, spawner in pairs(data.raw["unit-spawner"]) do
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            table.insert(prereqs, {
                type = "spawn-entity-surface",
                name = compound_key({spawner.name, surface_name})
            })
            table.insert(prereqs, {
                type = "capture-robot",
                name = "canonical"
            })

            add_to_graph("capture-spawner-surface", compound_key({spawner.name, surface_name}), prereqs, {
                surface = surface_name
            })
        end
    end

    -- cargo-landing-pad-planet
    log("Adding: cargo-landing-pad-planet")

    for _, planet in pairs(data.raw.planet) do
        prereqs = {}

        for _, cargo_pad in pairs(data.raw["cargo-landing-pad"]) do
            table.insert(prereqs, {
                type = "operate-entity-surface",
                name = compound_key({cargo_pad.name, compound_key({"planet", planet.name})})
            })
        end

        add_to_graph("cargo-landing-pad-planet", planet.name, prereqs)
    end

    -- character
    log("Adding: character")

    for _, character in pairs(data.raw.character) do
        prereqs = {}

        if character.name == "character" then
            table.insert(prereqs, {
                type = "starting-character",
                name = "canonical"
            })
        end

        add_to_graph("character", character.name, prereqs)
    end

    -- craft-material
    log("Adding: craft-material")

    for material_name, material in pairs(materials) do
        prereqs = {}
        
        for surface_name, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "craft-material-surface",
                name = compound_key({material_name, surface_name})
            })
        end

        add_to_graph("craft-material", material_name, prereqs)
    end

    -- craft-material-surface
    log("Adding: craft-material-surface")

    for material_name, material in pairs(materials) do
        -- Precompute recipes that result in this material for performance reasons
        local recipes_resulting_in_this = {}
        for _, recipe in pairs(data.raw.recipe) do
            local in_results = false

            if recipe.results ~= nil then
                for _, result in pairs(recipe.results) do
                    if result.type .. "-" .. result.name == material_name then
                        in_results = true
                    end
                end
            end

            -- Also check that this isn't an auto-generated recycling recipe since we don't want to rely on those for reachability
            if in_results and not (recipe.category == "recycling" and (recipe.subgroup == nil or recipe.subgroup == "other")) then
                table.insert(recipes_resulting_in_this, recipe)
            end
        end

        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            for _, recipe in pairs(recipes_resulting_in_this) do
                table.insert(prereqs, {
                    type = "recipe-surface",
                    name = compound_key({recipe.name, surface_name})
                })
            end

            add_to_graph("craft-material-surface", compound_key({material_name, surface_name}), prereqs, {
                surface = surface_name
            })
        end
    end

    -- create-fluid-offshore-surface
    log("Adding: create-fluid-offshore-surface")

    for _, pump in pairs(data.raw["offshore-pump"]) do
        for _, tile in pairs(data.raw.tile) do
            -- I'm not too sure what this does as it's written, feels like it should just be *every* triple, but only with the connections on valid ones
            for surface_name, surface in pairs(surfaces) do
                -- As in fun mode, there is somehow some way of making offshore pumps make fluid dependent on the offshore pump rather than the tile
                -- However, it seems space age doesn't use this and it seems like dark voodoo to me so I won't account for it
                -- Note: It's from the offshore pump filter, which isn't too bad, maybe I could do that
                -- TODO: See above
                -- TODO: Check more than just them not colliding
                if tile.fluid ~= nil and not collision_mask_util.masks_collide(tile.collision_mask, pump.collision_mask or collision_mask_util.get_default_mask("offshore-pump")) then
                    prereqs = {}

                    table.insert(prereqs, {
                        type = "spawn-tile-surface",
                        name = compound_key({tile.name, surface_name})
                    })
                    table.insert(prereqs, {
                        type = "operate-entity-surface",
                        name = compound_key({pump.name, surface_name})
                    })

                    add_to_graph("create-fluid-offshore-surface", compound_key({pump.name, tile.name, surface_name}), prereqs, {
                        surface = surface_name
                    })
                end
            end
        end
    end

    -- create-fluid-surface
    log("Adding: create-fluid-surface")

    for _, fluid in pairs(data.raw.fluid) do
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            table.insert(prereqs, {
                type = "craft-material-surface",
                name = compound_key({"fluid-" .. fluid.name, surface_name})
            })

            for _, tile in pairs(data.raw.tile) do
                if tile.fluid == fluid.name then
                    for _, pump in pairs(data.raw["offshore-pump"]) do
                        -- TODO: Also check if pump has filter for this fluid!
                        if not collision_mask_util.masks_collide(tile.collision_mask, pump.collision_mask or collision_mask_util.get_default_mask("offshore-pump")) then
                            table.insert(prereqs, {
                                type = "create-fluid-offshore-surface",
                                name = compound_key({pump.name, tile.name, surface_name})
                            })
                        end
                    end
                end
            end

            for _, boiler in pairs(data.raw.boiler) do
                if boiler.output_fluid_box.filter == fluid.name then
                    table.insert(prereqs, {
                        type = "operate-entity-surface",
                        name = compound_key({boiler.name, surface_name})
                    })
                end
            end

            for _, resource in pairs(data.raw.resource) do
                local mines_to_fluid = false
                if resource.minable ~= nil and resource.minable.results ~= nil then
                    for _, result in pairs(resource.minable.results) do
                        if result.type == "fluid" and result.name == fluid.name then
                            mines_to_fluid = true
                        end
                    end
                end
                if mines_to_fluid then
                    table.insert(prereqs, {
                        type = "mine-entity-surface",
                        name = compound_key({resource.name, surface_name})
                    })
                end
            end

            if data.raw["fusion-reactor"] ~= nil then
                for _, reactor in pairs(data.raw["fusion-reactor"]) do
                    if reactor.output_fluid_box.filter == fluid.name then
                        table.insert(prereqs, {
                            type = "operate-entity-surface",
                            name = compound_key({reactor.name, surface_name})
                        })
                    end
                end
            end

            if data.raw["fusion-generator"] ~= nil then
                for _, generator in pairs(data.raw["fusion-generator"]) do
                    if generator.output_fluid_box.filter == fluid.name then
                        table.insert(prereqs, {
                            type = "operate-entity-surface",
                            name = compound_key({generator.name, surface_name})
                        })
                    end
                end
            end

            add_to_graph("create-fluid-surface", compound_key({fluid.name, surface_name}), prereqs, {
                fluid = fluid,
                surface = surface_name
            })
        end
    end

    -- create-space-platform
    log("Adding: create-space-platform")

    prereqs = {}

    if data.raw.surface ~= nil then
        for _, surface in pairs(data.raw.surface) do
            table.insert(prereqs, {
                type = "space-surface",
                name = surface.name
            })
        end
    end

    add_to_graph("create-space-platform", "canonical", prereqs)

    -- create-space-platform-tech-unlock
    log("Adding: create-space-platform-tech-unlock")

    prereqs = {}

    for _, tech in pairs(data.raw.technology) do
        local unlocks_space_platforms = false

        if tech.effects ~= nil then
            for _, effect in pairs(tech.effects) do
                if effect.type == "unlock-space-platforms" then
                    unlocks_space_platforms = true
                end
            end
        end

        if unlocks_space_platforms then
            table.insert(prereqs, {
                type = "technology",
                name = tech.name
            })
        end
    end

    add_to_graph("create-space-platform-tech-unlock", "canonical", prereqs)

    -- gun-ammo-surface
    log("Adding: gun-ammo-surface")

    -- TODO: Make this something other than just a source
    -- We're basically assuming here that the player can take down anything

    prereqs = {}

    table.insert(prereqs, {
        type = "starting-character",
        name = "canonical"
    })

    add_to_graph("gun-ammo-surface", "canonical", prereqs)

    -- electricity-distribution-surface
    log("Adding: electricity-distribution-surface")

    for surface_name, surface in pairs(surfaces) do
        prereqs = {}

        for _, electric_pole in pairs(data.raw["electric-pole"]) do
            table.insert(prereqs, {
                type = "operate-entity-surface",
                name = compound_key({electric_pole.name, surface_name})
            })
        end

        add_to_graph("electricity-distribution-surface", surface_name, prereqs, {
            surface = surface_name
        })
    end

    -- electricity-production-surface
    log("Adding: electricity-production-surface")

    for surface_name, surface in pairs(surfaces) do
        prereqs = {}

        for _, generator in pairs(data.raw["burner-generator"]) do
            table.insert(prereqs, {
                type = "operate-entity-surface",
                name = compound_key({generator.name, surface_name})
            })
        end

        for _, generator in pairs(data.raw.generator) do
            table.insert(prereqs, {
                type = "operate-entity-surface",
                name = compound_key({generator.name, surface_name})
            })
        end

        -- Check lightning
        -- TODO: Check lightning existence more explicitly, right now, it just checks that the lightning properties is non-nil
        if surface.type == "planet" and surface.prototype.lightning_properties ~= nil then
            for _, attractor in pairs(data.raw["lightning-attractor"]) do
                table.insert(prereqs, {
                    type = "operate-entity-surface",
                    name = compound_key({attractor.name, surface_name})
                })
            end
        end

        for _, solar_panel in pairs(data.raw["solar-panel"]) do
            table.insert(prereqs, {
                type = "operate-entity-surface",
                name = compound_key({solar_panel.name, surface_name})
            })
        end

        if data.raw["fusion-generator"] ~= nil then
            for _, generator in pairs(data.raw["fusion-generator"]) do
                table.insert(prereqs, {
                    type = "operate-entity-surface",
                    name = compound_key({generator.name, surface_name})
                })
            end
        end

        add_to_graph("electricity-production-surface", surface_name, prereqs, {
            surface = surface_name
        })
    end

    -- electricity-surface
    log("Adding: electricity-surface")

    for surface_name, surface in pairs(surfaces) do
        prereqs = {}

        table.insert(prereqs, {
            type = "electricity-distribution-surface",
            name = surface_name
        })
        table.insert(prereqs, {
            type = "electricity-production-surface",
            name = surface_name
        })

        add_to_graph("electricity-surface", surface_name, prereqs, {
            surface = surface_name
        })
    end

    -- energy-source-surface
    log("Adding: energy-source-surface")

    -- We need a key showing which energy sources are "operation" sources rather than just "generation" sources
    local operation_energy_sources = {
        ["agricultural-tower"] = "energy_source",
        ["ammo-turret"] = "energy_source",
        ["arithmetic-combinator"] = "energy_source",
        ["assembling-machine"] = "energy_source",
        ["asteroid-collector"] = "energy_source",
        beacon = "energy_source",
        boiler = "energy_source",
        ["burner-generator"] = "burner",
        car = "energy_source",
        ["decider-combinator"] = "energy_source",
        ["electric-turret"] = "energy_source",
        furnace = "energy_source",
        ["fusion-reactor"] = {"burner", "energy_source"}, -- Has two operability energy sources
        inserter = "energy_source",
        lab = "energy_source",
        lamp = "energy_source",
        loader = "energy_source",
        ["loader-1x1"] = "energy_source",
        locomotive = "energy_source",
        ["mining-drill"] = "energy_source",
        ["offshore-pump"] = "energy_source",
        ["programmable-speaker"] = "energy_source",
        pump = "energy_source",
        radar = "energy_source",
        reactor = "energy_source",
        roboport = "energy_source",
        ["rocket-silo"] = "energy_source",
        ["selector-combinator"] = "energy_source",
        ["spider-vehicle"] = "energy_source"
    }
    for entity_class, properties in pairs(operation_energy_sources) do
        if data.raw[entity_class] ~= nil then
            for _, entity in pairs(data.raw[entity_class]) do
                for surface_name, surface in pairs(surfaces) do
                    prereqs = {}

                    local property_tbl = properties
                    if type(property_tbl) ~= "table" then
                        property_tbl = {property_tbl}
                    end
                    
                    for _, property in pairs(property_tbl) do
                        local energy_source = entity[property]

                        if energy_source ~= nil then
                            if energy_source.type == "electric" then
                                table.insert(prereqs, {
                                    type = "electricity-surface",
                                    name = surface_name
                                })
                            elseif energy_source.type == "burner" then
                                -- TODO: Also check for burnt fuel results and a valid burnt result inventory
                                for _, fuel_category in pairs(energy_source.fuel_categories or {"chemical"}) do
                                    table.insert(prereqs, {
                                        type = "fuel-category-surface",
                                        name = compound_key({fuel_category, surface_name})
                                    })
                                end
                            elseif energy_source.type == "heat" then
                                table.insert(prereqs, {
                                    type = "heat-surface",
                                    name = surface_name
                                })
                            elseif energy_source.type == "fluid" then
                                if energy_source.fluid_box.filter ~= nil then
                                    table.insert(prereqs, {
                                        type = "fluid-surface",
                                        name = compound_key({energy_source.fluid_box.filter, surface_name})
                                    })
                                else
                                    for _, fluid in pairs(data.raw.fluid) do
                                        if fluid.fuel_value ~= nil then
                                            table.insert(prereqs, {
                                                type = "fluid-surface",
                                                name = compound_key({fluid.name, surface_name})
                                            })
                                        end
                                    end
                                end
                            elseif energy_source.type == "void" then
                                table.insert(prereqs, {
                                    type = "void-energy",
                                    name = "canonical"
                                })
                            end
                        -- Since energy_source is an OR, we still need to add a satisfier if there is none, so just use void
                        else
                            table.insert(prereqs, {
                                type = "void-energy",
                                name = "canonical"
                            })
                        end

                        add_to_graph("energy-source-surface", compound_key({entity.name, property, surface_name}), prereqs, {
                            surface = surface_name
                        })
                    end
                end
            end
        end
    end

    -- entity-buildability-surface
    log("Adding: entity-buildability-surface")
    -- For optimization purposes, this only "checks" entities that appear buildable

    for _, entity in pairs(build_graph.prototypes.entities) do
        -- Figure out if this is even buildable, if not don't evaluate prereqs
        local is_buildable = false
        for item_class, _ in pairs(defines.prototypes.item) do
            if data.raw[item_class] ~= nil then
                for _, item in pairs(data.raw[item_class]) do
                    if item.place_result == entity.name or item.plant_result == entity.name then
                        is_buildable = true
                        break
                    end
                end
                if is_buildable then
                    break
                end
            end
        end
        
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            if is_buildable then
                -- Assume default collision mask means it can be placed
                if entity.collision_mask == nil then
                    table.insert(prereqs, {
                        type = "entity-buildability-surface-true",
                        name = "canonical"
                    })
                else
                    for _, tile in pairs(data.raw.tile) do
                        if not collision_mask_util.masks_collide(tile.collision_mask, entity.collision_mask or collision_mask_util.get_default_mask(entity.type)) then
                            local buildable_on_tile = true

                            -- Also check tile restrictions from autoplace, which apply to during the game as well for some reason
                            if entity.autoplace ~= nil and entity.autoplace.tile_restriction ~= nil then
                                buildable_on_tile = false

                                for _, restriction in pairs(entity.autoplace.tile_restriction) do
                                    -- I'm not sure what exactly the two tile transition entries mean so I'm just going to ignore them
                                    if restriction == tile.name then
                                        buildable_on_tile = true
                                    end
                                end
                            end

                            -- TODO: Tile buildability rules?
                            -- TODO: Manually account for entities with tile buildability rules... they're really intense
                            -- Right now it's just 4 things (rail ramps, offshore pumps, thrusters, and asteroid collectors)

                            if buildable_on_tile then
                                table.insert(prereqs, {
                                    type = "spawn-tile-surface",
                                    name = compound_key({tile.name, surface_name})
                                })
                            end
                        end
                    end
                end
            end

            add_to_graph("entity-buildability-surface", compound_key({entity.name, surface_name}), prereqs, {
                surface = surface_name
            })
        end
    end

    -- entity-buildability-surface-true
    log("Adding: entity-buildability-surface-true")

    prereqs = {}

    add_to_graph("entity-buildability-surface-true", "canonical", prereqs)

    -- entity-operation-items
    log("Adding: entity-operation-items")

    -- TODO

    -- fluid
    log("Adding: fluid")

    for _, fluid in pairs(data.raw.fluid) do
        prereqs = {}

        for surface_name, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "fluid-surface",
                name = compound_key({fluid.name, surface_name})
            })
        end
        
        add_to_graph("fluid", fluid.name, prereqs, {
            fluid = fluid
        })
    end

    -- fluid-surface
    log("Adding: fluid-surface")

    for _, fluid in pairs(data.raw.fluid) do
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            table.insert(prereqs, {
                type = "create-fluid-surface",
                name = compound_key({fluid.name, surface_name})
            })
            table.insert(prereqs, {
                type = "hold-fluid-surface",
                name = compound_key({fluid.name, surface_name})
            })

            add_to_graph("fluid-surface", compound_key({fluid.name, surface_name}), prereqs, {
                surface = surface_name,
                fluid = fluid
            })
        end
    end

    -- fuel-category
    log("Adding: fuel-category")

    -- TODO: Specialize into per-surface
    for _, fuel_category in pairs(data.raw["fuel-category"]) do
        prereqs = {}

        for item_class, _ in pairs(defines.prototypes.item) do
            if data.raw[item_class] ~= nil then
                for _, item in pairs(data.raw[item_class]) do
                    if item.fuel_category == fuel_category.name then
                        table.insert(prereqs, {
                            type = "item",
                            name = item.name
                        })
                    end
                end
            end
        end

        add_to_graph("fuel-category", fuel_category.name, prereqs)
    end

    -- fuel-category-burner
    log("Adding: fuel-category-burner")

    -- TODO: Make this depend on fuel-category-burner-surface instead
    for _, fuel_category in pairs(data.raw["fuel-category"]) do
        prereqs = {}

        -- We don't care about the type of energy source here, so we can just search over all of them
        -- Valid energy source keys are exactly "energy_source" and "burner"
        for _, entity in pairs(build_graph.prototypes.entities) do
            for _, property in pairs({"burner", "energy_source"}) do
                if entity[property] ~= nil then
                    local energy_source = entity[property]

                    if energy_source.type == "burner" then
                        -- Check that it accepts this fuel category
                        for _, fuel_category_id in pairs(energy_source.fuel_categories or {"chemical"}) do
                            if fuel_category_id == fuel_category.name then
                                table.insert(prereqs, {
                                    type = "operate-entity",
                                    name = entity.name
                                })
                            end
                        end
                    end
                end
            end
        end

        add_to_graph("fuel-category-burner", fuel_category.name, prereqs)
    end

    -- fuel-category-burner-surface
    log("Adding: fuel-category-burner-surface")

    for _, fuel_category in pairs(data.raw["fuel-category"]) do
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            -- We don't care about the type of energy source here, so we can just search over all of them
            -- Valid energy source keys are exactly "energy_source" and "burner"
            for _, entity in pairs(build_graph.prototypes.entities) do
                for _, property in pairs({"burner", "energy_source"}) do
                    if entity[property] ~= nil then
                        local energy_source = entity[property]

                        if energy_source.type == "burner" then
                            -- Check that it accepts this fuel category
                            for _, fuel_category_id in pairs(energy_source.fuel_categories or {"chemical"}) do
                                if fuel_category_id == fuel_category.name then
                                    table.insert(prereqs, {
                                        type = "operate-entity-surface",
                                        name = compound_key({entity.name, surface_name})
                                    })
                                end
                            end
                        end
                    end
                end
            end

            add_to_graph("fuel-category-burner-surface", compound_key({fuel_category.name, surface_name}), prereqs)
        end
    end

    -- fuel-category-surface
    log("Adding: fuel-category-surface")
    -- TODO: Add this to obsidian spec
    for _, fuel_category in pairs(data.raw["fuel-category"]) do
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            for item_class, _ in pairs(defines.prototypes.item) do
                if data.raw[item_class] ~= nil then
                    for _, item in pairs(data.raw[item_class]) do
                        if item.fuel_category == fuel_category.name then
                            table.insert(prereqs, {
                                type = "item-surface",
                                name = compound_key({item.name, surface_name})
                            })
                        end
                    end
                end
            end

            add_to_graph("fuel-category-surface", compound_key({fuel_category.name, surface_name}), prereqs)
        end
    end

    -- gun-ammo-surface
    log("Adding: gun-ammo-surface")

    -- TODO

    -- gun-surface
    log("Adding: gun-surface")

    -- TODO

    -- heat-distribution-surface
    log("Adding: heat-distribution-surface")

    for surface_name, surface in pairs(surfaces) do
        prereqs = {}

        for _, heat_pipe in pairs(data.raw["heat-pipe"]) do
            table.insert(prereqs, {
                type = "operate-entity-surface",
                name = compound_key({heat_pipe.name, surface_name})
            })
        end

        add_to_graph("heat-distribution-surface", surface_name, prereqs, {
            surface = surface_name
        })
    end

    -- heat-production-surface
    log("Adding: heat-production-surface")

    local heat_producers = {
        ["reactor"] = true
    }

    for surface_name, surface in pairs(surfaces) do
        prereqs = {}

        for heat_producer_class, _ in pairs(heat_producers) do
            for _, entity in pairs(data.raw[heat_producer_class]) do
                table.insert(prereqs, {
                    type = "operate-entity-surface",
                    name = compound_key({entity.name, surface_name})
                })
            end
        end

        add_to_graph("heat-production-surface", surface_name, prereqs, {
            surface = surface_name
        })
    end

    -- heat-surface
    log("Adding: heat-surface")

    for surface_name, surface in pairs(surfaces) do
        prereqs = {}

        table.insert(prereqs, {
            type = "heat-production-surface",
            name = surface_name
        })
        table.insert(prereqs, {
            type = "heat-distribution-surface",
            name = surface_name
        })

        add_to_graph("heat-surface", surface_name, prereqs, {
            surface = surface_name
        })
    end

    -- hold-fluid-surface
    log("Adding: hold-fluid-surface")

    for _, fluid in pairs(data.raw.fluid) do
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            -- Just check pipes now
            -- TODO: Check fluid "holding" in more creative ways
            -- TODO: Also check logistics, like underground pipes
            for _, pipe in pairs(data.raw.pipe) do
                if pipe.fluid_box.filter == nil or pipe.fluid_box.filter == fluid.name then
                    table.insert(prereqs, {
                        type = "operate-entity-surface",
                        name = compound_key({pipe.name, surface_name})
                    })
                end
            end

            add_to_graph("hold-fluid-surface", compound_key({fluid.name, surface_name}), prereqs, {
                surface = surface_name
            })
        end
    end

    -- item
    log("Adding: item")

    -- TODO: Make depend on surface-specific node instead
    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                prereqs = {}

                table.insert(prereqs, {
                    type = "craft-material",
                    name = "item-" .. item.name
                })

                for _, entity in pairs(build_graph.prototypes.entities) do
                    if entity.minable ~= nil then
                        local results_in_item = false

                        if entity.minable.results ~= nil then
                            for _, result in pairs(entity.minable.results) do
                                if result.type == "item" and result.name == item.name then
                                    results_in_item = true
                                end
                            end
                        elseif entity.minable.result ~= nil then
                            if entity.minable.result == item.name then
                                results_in_item = true
                            end
                        end

                        if results_in_item then
                            table.insert(prereqs, {
                                type = "mine-entity",
                                name = entity.name
                            })
                        end
                    end
                end

                for _, tile in pairs(data.raw.tile) do
                    if tile.minable ~= nil then
                        local results_in_item = false

                        if tile.minable.results ~= nil then
                            for _, result in pairs(tile.minable.results) do
                                if result.name == item.name then
                                    results_in_item = true
                                end
                            end
                        elseif tile.minable.result ~= nil then
                            if tile.minable.result == item.name then
                                results_in_item = true
                            end
                        end

                        if results_in_item then
                            table.insert(prereqs, {
                                type = "mine-tile",
                                name = tile.name
                            })
                        end
                    end
                end

                for _, asteroid_chunk in pairs(data.raw["asteroid-chunk"]) do
                    if asteroid_chunk.minable ~= nil then
                        local results_in_item = false

                        if asteroid_chunk.minable.results ~= nil then
                            for _, result in pairs(asteroid_chunk.minable.results) do
                                if result.name == item.name then
                                    results_in_item = true
                                end
                            end
                        elseif asteroid_chunk.minable.result ~= nil then
                            if asteroid_chunk.minable.result == item.name then
                                results_in_item = true
                            end
                        end

                        if results_in_item then
                            table.insert(prereqs, {
                                type = "mine-asteroid-chunk",
                                name = asteroid_chunk.name
                            })
                        end
                    end
                end

                for _, entity in pairs(build_graph.prototypes.entities) do
                    if entity.loot ~= nil then
                        local is_loot_result = false

                        for _, loot in pairs(entity.loot) do
                            if loot.item == item.name then
                                is_loot_result = true
                            end
                        end

                        if is_loot_result then
                            table.insert(prereqs, {
                                type = "loot-entity",
                                name = entity.name
                            })
                        end
                    end
                end

                for item_class_2, _ in pairs(defines.prototypes.item) do
                    if data.raw[item_class_2] ~= nil then
                        for _, item_2 in pairs(data.raw[item_class_2]) do
                            if item_2.spoil_result == item.name then
                                -- CRITICAL TODO: ADD BACK IN
                                -- This was removed because going through spoilage to get things for randomization proved too difficult
                                -- It still works out because spoilage can be found on gleba, so the graph can still be traversed, but this prevents issues at nauvis stage
                                --[[table.insert(prereqs, {
                                    type = "item",
                                    name = item_2.name
                                })]]
                            end
                        end
                    end
                end

                for item_class_2, _ in pairs(defines.prototypes.item) do
                    if data.raw[item_class_2] ~= nil then
                        for _, item_2 in pairs(data.raw[item_class_2]) do
                            if item_2.burnt_result == item.name then
                                table.insert(prereqs, {
                                    type = "burn-item",
                                    name = item_2.name
                                })
                            end
                        end
                    end
                end

                for item_class_2, _ in pairs(defines.prototypes.item) do
                    if data.raw[item_class_2] ~= nil then
                        for _, item_2 in pairs(data.raw[item_class_2]) do
                            if item_2.rocket_launch_products ~= nil then
                                local is_rocket_launch_product = false

                                for _, result in pairs(item_2.rocket_launch_products) do
                                    if result.name == item.name then
                                        is_rocket_launch_product = true
                                    end
                                end

                                if is_rocket_launch_product then
                                    table.insert(prereqs, {
                                        type = "send-item-to-orbit",
                                        name = item_2.name
                                    })
                                end
                            end
                        end
                    end
                end

                -- TODO: Save until we make equipment nodes
                --[[
                for equipment_class, _ in pairs(defines.prototypes.equipment) do
                    for _, equipment in pairs(data.raw[equipment_class]) do
                        if equipment.take_result == item.name then
                            table.insert(prereqs, {
                                type = "equipment",
                                name = equipment.name
                            })
                        end
                    end
                end
                ]]

                add_to_graph("item", item.name, prereqs, {
                    item = item
                })
            end
        end
    end

    -- item-surface
    log("Adding: item-surface")

    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                -- Precompute entities that give this when mined/looted for performance reasons
                local give_when_mined = {}
                local give_when_looted = {}

                for _, entity in pairs(build_graph.prototypes.entities) do
                    if entity.minable ~= nil then
                        local results_in_item = false

                        if entity.minable.results ~= nil then
                            for _, result in pairs(entity.minable.results) do
                                if result.type == "item" and result.name == item.name then
                                    results_in_item = true
                                end
                            end
                        elseif entity.minable.result ~= nil then
                            if entity.minable.result == item.name then
                                results_in_item = true
                            end
                        end

                        if results_in_item then
                            table.insert(give_when_mined, entity)
                        end
                    end
                end

                for _, entity in pairs(build_graph.prototypes.entities) do
                    if entity.loot ~= nil then
                        local is_loot_result = false

                        for _, loot in pairs(entity.loot) do
                            if loot.item == item.name then
                                is_loot_result = true
                            end
                        end

                        if is_loot_result then
                            table.insert(give_when_looted, entity)
                        end
                    end
                end

                for surface_name, surface in pairs(surfaces) do
                    prereqs = {}

                    table.insert(prereqs, {
                        type = "craft-material-surface",
                        name = compound_key({"item-" .. item.name, surface_name})
                    })

                    for _, entity in pairs(give_when_mined) do
                        table.insert(prereqs, {
                            type = "mine-entity-surface",
                            name = compound_key({entity.name, surface_name})
                        })
                    end

                    for _, tile in pairs(data.raw.tile) do
                        if tile.minable ~= nil then
                            local results_in_item = false

                            if tile.minable.results ~= nil then
                                for _, result in pairs(tile.minable.results) do
                                    if result.name == item.name then
                                        results_in_item = true
                                    end
                                end
                            elseif tile.minable.result ~= nil then
                                if tile.minable.result == item.name then
                                    results_in_item = true
                                end
                            end

                            if results_in_item then
                                table.insert(prereqs, {
                                    type = "mine-tile-surface",
                                    name = compound_key({tile.name, surface_name})
                                })
                            end
                        end
                    end

                    if surface.type == "space-surface" then
                        for _, asteroid_chunk in pairs(data.raw["asteroid-chunk"]) do
                            if asteroid_chunk.minable ~= nil then
                                local results_in_item = false

                                if asteroid_chunk.minable.results ~= nil then
                                    for _, result in pairs(asteroid_chunk.minable.results) do
                                        if result.name == item.name then
                                            results_in_item = true
                                        end
                                    end
                                elseif asteroid_chunk.minable.result ~= nil then
                                    if asteroid_chunk.minable.result == item.name then
                                        results_in_item = true
                                    end
                                end

                                if results_in_item then
                                    table.insert(prereqs, {
                                        type = "mine-asteroid-chunk-surface",
                                        name = compound_key({asteroid_chunk.name, surface.name})
                                    })
                                end
                            end
                        end
                    end

                    for _, entity in pairs(give_when_looted) do
                        table.insert(prereqs, {
                            type = "loot-entity-surface",
                            name = compound_key({entity.name, surface_name})
                        })
                    end

                    for item_class_2, _ in pairs(defines.prototypes.item) do
                        if data.raw[item_class_2] ~= nil then
                            for _, item_2 in pairs(data.raw[item_class_2]) do
                                if item_2.spoil_result == item.name then
                                    table.insert(prereqs, {
                                        type = "item-surface",
                                        name = compound_key({item_2.name, surface_name})
                                    })
                                end
                            end
                        end
                    end

                    for item_class_2, _ in pairs(defines.prototypes.item) do
                        if data.raw[item_class_2] ~= nil then
                            for _, item_2 in pairs(data.raw[item_class_2]) do
                                if item_2.burnt_result == item.name then
                                    table.insert(prereqs, {
                                        type = "burn-item-surface",
                                        name = compound_key({item_2.name, surface_name})
                                    })
                                end
                            end
                        end
                    end

                    if surface.type == "planet" then
                        for item_class_2, _ in pairs(defines.prototypes.item) do
                            if data.raw[item_class_2] ~= nil then
                                for _, item_2 in pairs(data.raw[item_class_2]) do
                                    if item_2.rocket_launch_products ~= nil then
                                        local is_rocket_launch_product = false

                                        for _, result in pairs(item_2.rocket_launch_products) do
                                            if result.name == item.name then
                                                is_rocket_launch_product = true
                                            end
                                        end

                                        if is_rocket_launch_product then
                                            table.insert(prereqs, {
                                                type = "send-item-to-orbit-planet",
                                                name = compound_key({item_2.name, surface.name})
                                            })
                                        end
                                    end
                                end
                            end
                        end
                    end

                    table.insert(prereqs, {
                        type = "transport-item-to-surface",
                        name = compound_key({item.name, surface_name})
                    })

                    -- TODO: Save until we make equipment nodes
                    --[[
                    for equipment_class, _ in pairs(defines.prototypes.equipment) do
                        for _, equipment in pairs(data.raw[equipment_class]) do
                            if equipment.take_result == item.name then
                                table.insert(prereqs, {
                                    type = "equipment",
                                    name = equipment.name
                                })
                            end
                        end
                    end
                    ]]

                    add_to_graph("item-surface", compound_key({item.name, surface_name}), prereqs, {
                        item = item,
                        surface = surface_name
                    })
                end
            end
        end
    end

    -- loot-entity
    log("Adding: loot-entity")

    for _, entity in pairs(build_graph.prototypes.entities) do
        if entity.loot ~= nil then
            prereqs = {}

            for surface_name, surface in pairs(surfaces) do
                table.insert(prereqs, {
                    type = "loot-entity-surface",
                    name = compound_key({entity.name, surface_name})
                })
            end

            add_to_graph("loot-entity", entity.name, prereqs)
        end
    end

    -- loot-entity-surface
    log("Adding: loot-entity-surface")

    for _, entity in pairs(build_graph.prototypes.entities) do
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            table.insert(prereqs, {
                type = "spawn-entity-surface",
                name = compound_key({entity.name, surface_name})
            })
            -- TODO: damage-type-amount-surface
            -- Assuming you can damage things for now

            add_to_graph("loot-entity-surface", compound_key({entity.name, surface_name}), prereqs, {
                surface = surface_name
            })
        end
    end

    -- mine-asteroid-chunk
    log("Adding: mine-asteroid-chunk")
    -- Only implemented for space surfaces

    for _, asteroid_chunk in pairs(data.raw["asteroid-chunk"]) do
        prereqs = {}

        if data.raw.surface ~= nil then
            for _, surface in pairs(data.raw.surface) do
                table.insert(prereqs, {
                    type = "mine-asteroid-chunk-surface",
                    name = compound_key({asteroid_chunk.name, surface.name})
                })
            end
        end

        add_to_graph("mine-asteroid-chunk", asteroid_chunk.name, prereqs)
    end

    -- mine-asteroid-chunk-surface
    log("Adding: mine-asteroid-chunk-surface")
    -- Only implemented for space surfaces

    for _, asteroid_chunk in pairs(data.raw["asteroid-chunk"]) do
        if data.raw.surface ~= nil then
            for _, surface in pairs(data.raw.surface) do
                prereqs = {}

                table.insert(prereqs, {
                    type = "spawn-asteroid-chunk",
                    name = asteroid_chunk.name
                })
                table.insert(prereqs, {
                    type = "asteroid-collection-surface",
                    name = surface.name
                })

                add_to_graph("mine-asteroid-chunk-surface", compound_key({asteroid_chunk.name, surface.name}), prereqs)
            end
        end
    end

    -- mine-entity
    log("Adding: mine-entity")

    for _, entity in pairs(build_graph.prototypes.entities) do
        if entity.minable ~= nil then
            prereqs = {}

            for surface_name, surface in pairs(surfaces) do
                table.insert(prereqs, {
                    type = "mine-entity-surface",
                    name = compound_key({entity.name, surface_name})
                })
            end

            add_to_graph("mine-entity", entity.name, prereqs)
        end
    end

    -- mine-entity-surface
    log("Adding: mine-entity-surface")

    for _, entity in pairs(build_graph.prototypes.entities) do
        if entity.minable ~= nil then
            for surface_name, surface in pairs(surfaces) do
                prereqs = {}

                table.insert(prereqs, {
                    type = "spawn-entity-surface",
                    name = compound_key({entity.name, surface_name})
                })

                if entity.minable.required_fluid ~= nil then
                    table.insert(prereqs, {
                        type = "fluid-surface",
                        name = compound_key({entity.minable.required_fluid, surface_name})
                    })

                    table.insert(prereqs, {
                        type = "mining-with-fluid-unlock",
                        name = "canonical"
                    })
                end

                if entity.type == "resource" then
                    table.insert(prereqs, {
                        type = "resource-category-surface",
                        name = compound_key({resource_to_spoofed_category_name(entity), surface_name})
                    })
                end

                add_to_graph("mine-entity-surface", compound_key({entity.name, surface_name}), prereqs, {
                    surface = surface_name
                })
            end
        end
    end

    -- mine-tile
    log("Adding: mine-tile")

    for _, tile in pairs(data.raw.tile) do
        -- Only minable tiles
        if tile.minable ~= nil then
            prereqs = {}

            for surface_name, surface in pairs(surfaces) do
                table.insert(prereqs, {
                    type = "mine-tile-surface",
                    name = compound_key({tile.name, surface_name})
                })
            end

            add_to_graph("mine-tile", tile.name, prereqs)
        end
    end

    -- mine-tile-surface
    log("Adding: mine-tile-surface")

    for _, tile in pairs(data.raw.tile) do
        for surface_name, surface in pairs(surfaces) do
            if tile.minable ~= nil then
                prereqs = {}

                table.insert(prereqs, {
                    type = "spawn-tile-surface",
                    name = compound_key({tile.name, surface_name})
                })

                add_to_graph("mine-tile-surface", compound_key({tile.name, surface_name}), prereqs, {
                    surface = surface_name
                })
            end
        end
    end

    -- mining-with-fluid-unlock
    log("Adding: mining-with-fluid-unlock")

    prereqs = {}

    for _, technology in pairs(data.raw.technology) do
        local satisfies_node = false

        if technology.effects ~= nil then
            for _, modifier in pairs(technology.effects) do
                if modifier.type == "mining-with-fluid" and modifier.modifier then
                    satisfies_node = true
                end
            end
        end

        if satisfies_node then
            table.insert(prereqs, {
                type = "technology",
                name = technology.name
            })
        end
    end

    add_to_graph("mining-with-fluid-unlock", "canonical", prereqs)

    -- operate-entity
    log("Adding: operate-entity")

    for _, entity in pairs(build_graph.prototypes.entities) do
        prereqs = {}

        for surface_name, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "operate-entity-surface",
                name = compound_key({entity.name, surface_name})
            })
        end

        add_to_graph("operate-entity", entity.name, prereqs)
    end

    -- operate-entity-surface
    log("Adding: operate-entity-surface")

    for _, entity in pairs(build_graph.prototypes.entities) do
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            -- This is used later for the aquilo heating prerequisite
            local doesnt_freeze = false
            local property_list = operation_energy_sources[entity_class]
            if type(property_list) ~= "table" then
                property_list = {property_list}
            end
            for _, property in pairs(property_list) do
                table.insert(prereqs, {
                    type = "energy-source-surface",
                    name = compound_key({entity.name, property, surface_name})
                })

                -- I would check that the heat energy source is a production source, not a powered source, but being heat powered leads to the same requirements anyways
                if entity[property] ~= nil and (entity[property].type == "burner" or entity[property].type == "heat") then
                    doesnt_freeze = true
                end
            end

            table.insert(prereqs, {
                type = "spawn-entity-surface",
                name = compound_key({entity.name, surface_name})
            })

            local fluid_required_for_operation = {
                ["boiler"] = true,
                ["fusion-generator"] = true,
                ["fusion-reactor"] = true,
                ["generator"] = true
            }
            if fluid_required_for_operation[entity_class] then
                table.insert(prereqs, {
                    type = "operate-entity-surface-fluid",
                    name = compound_key({entity.name, surface_name})
                })
            end
            
            -- Thruster oxidizer/fuel
            if entity.type == "thruster" then
                table.insert(prereqs, {
                    type = "fluid-surface",
                    name = compound_key({entity.fuel_fluid_box.filter, surface_name})
                })
                table.insert(prereqs, {
                    type = "fluid-surface",
                    name = compound_key({entity.oxidizer_fluid_box.filter, surface_name})
                })
            end

            if surface.type == "planet" and surface.prototype.entities_require_heating then
                -- Do last doesnt_freeze checks
                if entity.type == "heat-pipe" then
                    doesnt_freeze = true
                end
                
                if not doesnt_freeze then
                    table.insert(prereqs, {
                        type = "heat-surface",
                        name = surface_name
                    })
                end
            end

            -- TODO: entity-operation-items, like PyAL modules

            add_to_graph("operate-entity-surface", compound_key({entity.name, surface_name}), prereqs, {
                surface = surface_name
            })
        end
    end

    -- operate-entity-surface-fluid
    log("Adding: operate-entity-surface-fluid")

    for _, entity in pairs(build_graph.prototypes.entities) do
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            --[[ entities with fluid requirements:
                boiler = true,
                ["fusion-generator"] = true,
                ["fusion-reactor"] = true,
                generator = true
            ]]
            
            if entity.type == "boiler" then
                -- Assume it has a filter set
                -- TODO: Get rid of this assumption!
                table.insert(prereqs, {
                    type = "fluid-surface",
                    name = compound_key({entity.fluid_box.filter, surface_name})
                })
            end
            if entity.type == "fusion-generator" then
                table.insert(prereqs, {
                    type = "fluid-surface",
                    name = compound_key({entity.input_fluid_box.filter, surface_name})
                })
            end
            if entity.type == "fusion-reactor" then
                table.insert(prereqs, {
                    type = "fluid-surface",
                    name = compound_key({entity.input_fluid_box.filter, surface_name})
                })
            end
            if entity.type == "generator" then
                if entity.fluid_box.filter ~= nil then
                    table.insert(prereqs, {
                        type = "fluid-surface",
                        name = compound_key({entity.fluid_box.filter, surface_name})
                    })
                else
                    if not burns_fluid then
                        -- TODO: Requires access to certain temperatures
                        -- TODO: Implement temperatures
                    else
                        for _, fluid in pairs(data.raw.fluid) do
                            if fluid.fuel_value ~= nil then
                                table.insert(prereqs, {
                                    type = "fluid-surface",
                                    name = compound_key({fluid.name, surface_name})
                                })
                            end
                        end
                    end
                end
            end

            add_to_graph("operate-entity-surface-fluid", compound_key({entity.name, surface_name}), prereqs, {
                surface = surface_name
            })
        end
    end

    -- planet
    log("Adding: planet")

    for _, planet in pairs(data.raw.planet) do
        prereqs = {}

        if planet.name == "nauvis" then
            table.insert(prereqs, {
                type = "starting-planet",
                name = "canonical"
            })
        end
        table.insert(prereqs, {
            type = "space-location",
            name = planet.name
        })

        add_to_graph("planet", planet.name, prereqs)
    end

    -- planet-launch
    log("Adding: planet-launch")

    for _, planet in pairs(data.raw.planet) do
        prereqs = {}

        if data.raw.surface ~= nil then
            for _, surface in pairs(data.raw.surface) do
                table.insert(prereqs, {
                    type = "send-surface-starter-pack-planet",
                    name = compound_key({surface.name, planet.name})
                })
            end
        end

        add_to_graph("planet-launch", planet.name, prereqs)
    end

    -- plant-entity-item
    log("Adding: plant-entity-item")

    for _, entity in pairs(build_graph.prototypes.entities) do
        prereqs = {}

        for item_class, _ in pairs(defines.prototypes.item) do
            if data.raw[item_class] ~= nil then
                for _, item in pairs(data.raw[item_class]) do
                    if item.plant_result == entity.name then
                        table.insert(prereqs, {
                            type = "item",
                            name = item.name
                        })
                    end
                end
            end
        end

        add_to_graph("plant-entity-item", entity.name, prereqs)
    end

    -- plant-entity-surface
    log("Adding: plant-entity-surface")

    for _, entity in pairs(build_graph.prototypes.entities) do
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            table.insert(prereqs, {
                type = "entity-buildability-surface",
                name = compound_key({entity.name, surface_name})
            })
            table.insert(prereqs, {
                type = "plant-entity-item",
                name = entity.name
            })
            table.insert(prereqs, {
                type = "surface",
                name = surface_name
            })

            -- Check buildability conditions
            -- TODO: Should this just be in entity-buildability-surface?...
            local surface_conditions_satisfied = true
            if entity.surface_conditions ~= nil then
                surface_conditions_satisfied = check_surface_conditions(entity.surface_conditions, surface)
            end
            if surface_conditions_satisfied then
                table.insert(prereqs, {
                    type = "plant-entity-surface-condition-true",
                    name = "canonical"
                })
            else
                table.insert(prereqs, {
                    type = "plant-entity-surface-condition-false",
                    name = "canonical"
                })
            end

            add_to_graph("plant-entity-surface", compound_key({entity.name, surface_name}), prereqs, {
                surface = surface_name
            })
        end
    end

    -- plant-entity-surface-automatability
    log("Adding: plant-entity-surface-automatability")

    for _, entity in pairs(build_graph.prototypes.entities) do
        for surface_name, surface in pairs(surfaces) do
            -- Technically the machine that harvests the plants may be only placeable in a different location from where the plants can be made
            -- This is probably never an issue, though, and would be nearly impossible to solve anyways
            prereqs = {}
            
            table.insert(prereqs, {
                type = "plant-entity-surface",
                name = compound_key({entity.name, surface_name})
            })
            table.insert(prereqs, {
                type = "agricultural-tower-surface",
                name = surface_name
            })

            add_to_graph("plant-entity-surface-automatability", compound_key({entity.name, surface_name}), prereqs, {
                surface = surface_name
            })
        end
    end

    -- plant-entity-surface-condition-false
    log("Adding: plant-entity-surface-condition-false")

    prereqs = {}

    add_to_graph("plant-entity-surface-condition-false", "canonical", prereqs)

    -- plant-entity-surface-condition-true
    log("Adding: plant-entity-surface-condition-true")

    prereqs = {}

    add_to_graph("plant-entity-surface-condition-true", "canonical", prereqs)

    -- recipe
    log("Adding: recipe")

    for _, recipe in pairs(data.raw.recipe) do
        prereqs = {}

        for surface_name, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "recipe-surface",
                name = compound_key({recipe.name, surface_name})
            })
        end

        add_to_graph("recipe", recipe.name, prereqs)
    end

    -- recipe-category
    log("Adding: recipe-category")

    for spoofed_category_name, spoofed_category in pairs(spoofed_recipe_categories) do
        prereqs = {}

        for surface_name, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "recipe-category-surface",
                name = compound_key({spoofed_category_name, surface_name})
            })
        end

        add_to_graph("recipe-category", spoofed_category_name, prereqs)
    end

    -- recipe-category-surface
    log("Adding: recipe-category-surface")

    for spoofed_category_name, spoofed_category in pairs(spoofed_recipe_categories) do
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            table.insert(prereqs, {
                type = "recipe-category-surface-automation",
                name = compound_key({spoofed_category_name, surface_name})
            })
            if spoofed_category.input_fluids == 0 and spoofed_category.output_fluids == 0 then
                for _, character in pairs(data.raw.character) do
                    if character.crafting_categories ~= nil then
                        local has_crafting_category = false

                        for _, category in pairs(character.crafting_categories) do
                            if category == spoofed_category.recipe_category.name then
                                has_crafting_category = true
                            end
                        end

                        if has_crafting_category then
                            table.insert(prereqs, {
                                type = "character",
                                name = character.name
                            })
                        end
                    end
                end
            end

            add_to_graph("recipe-category-surface", compound_key({spoofed_category_name, surface_name}), prereqs, {
                surface = surface_name
            })
        end
    end

    -- recipe-category-surface-automation
    log("Adding: recipe-category-surface-automation")

    for spoofed_category_name, spooofed_category in pairs(spoofed_recipe_categories) do
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            for crafting_machine_class, _ in pairs(crafting_machine_classes) do
                for _, crafting_machine in pairs(data.raw[crafting_machine_class]) do
                    if is_crafting_machine_compatible_with_recipe_category(crafting_machine, spooofed_category) then
                        table.insert(prereqs, {
                            type = "operate-entity-surface",
                            name = compound_key({crafting_machine.name, surface_name})
                        })
                    end
                end
            end

            add_to_graph("recipe-category-surface-automation", compound_key({spoofed_category_name, surface_name}), prereqs, {
                surface = surface_name
            })
        end
    end

    -- recipe-surface
    log("Adding: recipe-surface")

    for _, recipe in pairs(data.raw.recipe) do
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            -- We could calculate num_fluids in the function built for it, but we need to add the fluid prereqs themselves anyways
            local num_input_fluids = 0
            local num_output_fluids = 0
            if recipe.ingredients ~= nil then
                for _, ing in pairs(recipe.ingredients) do
                    if ing.type == "item" then
                        table.insert(prereqs, {
                            ing = ing,
                            is_ingredient = true,
                            type = "item-surface",
                            name = compound_key({ing.name, surface_name})
                        })
                    elseif ing.type == "fluid" then
                        num_input_fluids = num_input_fluids + 1
                        table.insert(prereqs, {
                            ing = ing,
                            is_ingredient = true,
                            type = "fluid-surface",
                            name = compound_key({ing.name, surface_name})
                        })
                    end
                end
            end
            if recipe.results ~= nil then
                for _, result in pairs(recipe.results) do
                    if result.type == "fluid" then
                        num_output_fluids = num_output_fluids + 1
                    end
                end
            end
            local spoofed_category_name = compound_key({recipe.category or "crafting", num_input_fluids, num_output_fluids})
            table.insert(prereqs, {
                type = "recipe-category-surface",
                name = compound_key({spoofed_category_name, surface_name})
            })

            if recipe.enabled == false then
                table.insert(prereqs, {
                    type = "recipe-tech-unlock",
                    name = recipe.name
                })
            end

            -- Check recipe surface conditions
            local surface_conditions_satisfied = true
            if recipe.surface_conditions ~= nil then
                surface_conditions_satisfied = check_surface_conditions(recipe.surface_conditions, surface)
            end
            if surface_conditions_satisfied then
                table.insert(prereqs, {
                    type = "build-entity-surface-condition-true",
                    name = "canonical"
                })
            else
                table.insert(prereqs, {
                    type = "build-entity-surface-condition-false",
                    name = "canonical"
                })
            end

            -- Add the actual surface
            table.insert(prereqs, {
                type = "surface",
                name = surface_name
            })

            add_to_graph("recipe-surface", compound_key({recipe.name, surface_name}), prereqs, {
                recipe = recipe,
                surface = surface_name
            })
        end
    end

    -- recipe-surface-condition-false
    log("Adding: recipe-surface-condition-false")

    prereqs = {}

    add_to_graph("recipe-surface-condition-false", "canonical", prereqs)

    -- recipe-surface-condition-true
    log("Adding: recipe-surface-condition-true")

    prereqs = {}

    add_to_graph("recipe-surface-condition-true", "canonical", prereqs)

    -- recipe-tech-unlock
    log("Adding: recipe-tech-unlock")

    for _, recipe in pairs(data.raw.recipe) do
        prereqs = {}

        for _, tech in pairs(data.raw.technology) do
            if tech.effects ~= nil then
                for _, effect in pairs(tech.effects) do
                    if effect.type == "unlock-recipe" and effect.recipe == recipe.name then
                        table.insert(prereqs, {
                            type = "technology",
                            name = tech.name
                        })
                    end
                end
            end
        end

        add_to_graph("recipe-tech-unlock", recipe.name, prereqs)
    end

    -- resource-category
    log("Adding: resource-category")

    for spoofed_category_name, spoofed_category in pairs(spoofed_resource_categories) do
        prereqs = {}

        for surface_name, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "resource-category-surface",
                name = compound_key({spoofed_category_name, surface_name})
            })
        end

        add_to_graph("resource-category", spoofed_category_name, prereqs)
    end

    -- resource-category-surface
    log("Adding: resource-category-surface")

    -- TODO: Also split into automated and non-automated version
    for spoofed_category_name, spoofed_category in pairs(spoofed_resource_categories) do
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            for _, character in pairs(data.raw.character) do
                if character.mining_categories ~= nil then
                    local has_mining_category = false

                    for _, mining_category_id in pairs(character.mining_categories) do
                        if mining_category_id == spoofed_category.resource_category.name then
                            has_mining_category = true
                        end
                    end

                    if has_mining_category then
                        table.insert(prereqs, {
                            type = "character",
                            name = character.name
                        })
                    end
                end
            end

            for _, mining_drill in pairs(data.raw["mining-drill"]) do
                local has_resource_category = false

                for _, mining_category_id in pairs(mining_drill.resource_categories) do
                    if mining_category_id == spoofed_category.resource_category.name then
                        has_resource_category = true
                    end
                end

                if spoofed_category.input_fluid ~= nil then
                    if mining_drill.input_fluid_box == nil then
                        has_resource_category = false
                    else
                        if mining_drill.input_fluid_box.filter ~= nil then
                            if mining_drill.input_fluid_box.filter ~= spoofed_category.input_fluid then
                                has_resource_category = false
                            end
                        end
                    end
                end
                if spoofed_category.output_fluid ~= nil then
                    if mining_drill.output_fluid_box == nil then
                        has_resource_category = false
                    else
                        if mining_drill.output_fluid_box.filter ~= nil then
                            if mining_drill.output_fluid_box.filter ~= spoofed_category.output_fluid then
                                has_resource_category = false
                            end
                        end
                    end
                end

                if has_resource_category then
                    table.insert(prereqs, {
                        type = "operate-entity-surface",
                        name = compound_key({mining_drill.name, surface_name})
                    })
                end
            end

            add_to_graph("resource-category-surface", compound_key({spoofed_category_name, surface_name}), prereqs, {
                surface = surface_name
            })
        end
    end

    -- rocket-launch-planet
    log("Adding: rocket-launch-planet")

    for _, planet in pairs(data.raw.planet) do
        prereqs = {}

        for _, silo in pairs(data.raw["rocket-silo"]) do
            for _, recipe in pairs(data.raw.recipe) do
                local spoofed_category = spoofed_recipe_categories[recipe_to_spoofed_category_name(recipe)]
                if is_crafting_machine_compatible_with_recipe_category(silo, spoofed_category) then
                    table.insert(prereqs, {
                        type = "rocket-part-recipe-planet",
                        name = compound_key({silo.name, recipe.name, planet.name})
                    })
                end
            end
        end

        add_to_graph("rocket-launch-planet", planet.name, prereqs)
    end

    -- rocket-part-recipe-planet
    log("Adding: rocket-part-recipe-planet")

    for _, silo in pairs(data.raw["rocket-silo"]) do
        for _, recipe in pairs(data.raw.recipe) do
            for _, planet in pairs(data.raw.planet) do
                prereqs = {}

                local surface_name = compound_key({"planet", planet.name})
                table.insert(prereqs, {
                    type = "operate-entity-surface",
                    name = compound_key({silo.name, surface_name})
                })
                table.insert(prereqs, {
                    type = "recipe-surface",
                    name = compound_key({recipe.name, surface_name})
                })

                add_to_graph("rocket-part-recipe-planet", compound_key({silo.name, recipe.name, planet.name}), prereqs)
            end
        end
    end

    -- science-pack-set
    log("Adding: science-pack-set")

    for science_pack_set_name, science_pack_set in pairs(science_pack_sets) do
        prereqs = {}

        for _, lab in pairs(data.raw.lab) do
            local lab_can_hold_science_packs = true

            for _, science_pack in pairs(science_pack_set) do
                local lab_can_hold_science_pack = false

                for _, input in pairs(lab.inputs) do
                    if input == science_pack then
                        lab_can_hold_science_pack = true
                    end
                end

                if not lab_can_hold_science_pack then
                    lab_can_hold_science_packs = false
                end
            end

            if lab_can_hold_science_packs then
                table.insert(prereqs, {
                    type = "operate-entity",
                    name = lab.name
                })
            end
        end

        add_to_graph("science-pack-set", science_pack_set_name, prereqs)
    end

    -- send-item-to-orbit
    log("Adding: send-item-to-orbit")

    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                prereqs = {}

                for _, planet in pairs(data.raw.planet) do
                    table.insert(prereqs, {
                        type = "send-item-to-orbit-planet",
                        name = compound_key({item.name, planet.name})
                    })
                end

                add_to_graph("send-item-to-orbit", item.name, prereqs)
            end
        end
    end

    -- send-item-to-orbit-planet
    log("Adding: send-item-to-orbit-planet")

    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                for _, planet in pairs(data.raw.planet) do
                    prereqs = {}

                    table.insert(prereqs, {
                        type = "rocket-launch-planet",
                        name = planet.name
                    })
                    table.insert(prereqs, {
                        type = "cargo-landing-pad-planet",
                        name = planet.name
                    })
                    table.insert(prereqs, {
                        type = "item-surface",
                        name = compound_key({item.name, compound_key({"planet", planet.name})})
                    })
                    table.insert(prereqs, {
                        type = "planet",
                        name = planet.name
                    })

                    add_to_graph("send-item-to-orbit-planet", compound_key({item.name, planet.name}), prereqs)
                end
            end
        end
    end

    -- send-surface-starter-pack
    log("Adding: send-surface-starter-pack")

    -- Only for space surfaces
    if data.raw.surface ~= nil then
        for _, surface in pairs(data.raw.surface) do
            prereqs = {}

            for _, planet in pairs(data.raw.planet) do
                table.insert(prereqs, {
                    type = "send-surface-starter-pack-planet",
                    name = compound_key({surface.name, planet.name})
                })
            end

            add_to_graph("send-surface-starter-pack", surface.name, prereqs)
        end
    end

    -- send-surface-starter-pack-planet
    log("Adding: send-surface-starter-pack-planet")

    if data.raw.surface ~= nil then
        for _, surface in pairs(data.raw.surface) do
            for _, planet in pairs(data.raw.planet) do
                prereqs = {}

                for _, starter_pack in pairs(data.raw["space-platform-starter-pack"]) do
                    if starter_pack.surface == surface.name then
                        table.insert(prereqs, {
                            type = "send-item-to-orbit-planet",
                            name = compound_key({starter_pack.name, planet.name})
                        })
                    end
                end

                add_to_graph("send-surface-starter-pack-planet", compound_key({surface.name, planet.name}), prereqs)
            end
        end
    end

    -- space-connection
    log("Adding: space-connection")

    if data.raw["space-connection"] ~= nil then
        for _, space_connection in pairs(data.raw["space-connection"]) do
            prereqs = {}

            table.insert(prereqs, {
                type = "space-location-discovery",
                name = space_connection.to
            })
            table.insert(prereqs, {
                type = "space-location",
                name = space_connection.from
            })
            table.insert(prereqs, {
                type = "spaceship",
                name = "canonical"
            })

            add_to_graph("space-connection", space_connection.name, prereqs)
        end
    end

    -- space-location
    log("Adding: space-location")

    for space_location_class, _ in pairs(defines.prototypes["space-location"]) do
        for _, space_location in pairs(data.raw[space_location_class]) do
            prereqs = {}

            if data.raw["space-connection"] ~= nil then
                for _, space_connection in pairs(data.raw["space-connection"]) do
                    if space_connection.to == space_location.name then
                        table.insert(prereqs, {
                            type = "space-connection",
                            name = space_connection.name
                        })
                    end
                end
            end
            if space_location_class == "planet" then
                table.insert(prereqs, {
                    type = "planet-launch",
                    name = space_location.name
                })
            end

            add_to_graph("space-location", space_location.name, prereqs)
        end
    end

    -- space-location-discovery
    log("Adding: space-location-discovery")

    for space_location_class, _ in pairs(defines.prototypes["space-location"]) do
        for _, space_location in pairs(data.raw[space_location_class]) do
            prereqs = {}

            for _, tech in pairs(data.raw.technology) do
                if tech.effects ~= nil then
                    local unlocks_location = false

                    for _, effect in pairs(tech.effects) do
                        if effect.type == "unlock-space-location" and effect.space_location == space_location.name then
                            unlocks_location = true
                        end
                    end

                    if unlocks_location then
                        table.insert(prereqs, {
                            type = "technology",
                            name = tech.name
                        })
                    end
                end
            end

            add_to_graph("space-location-discovery", space_location.name, prereqs)
        end
    end

    -- space-surface
    log("Adding: space-surface")

    if data.raw.surface ~= nil then
        for _, surface in pairs(data.raw.surface) do
            prereqs = {}

            table.insert(prereqs, {
                type = "create-space-platform-tech-unlock",
                name = "canonical"
            })

            table.insert(prereqs, {
                type = "send-surface-starter-pack",
                name = surface.name
            })

            add_to_graph("space-surface", surface.name, prereqs)
        end
    end

    -- spaceship
    log("Adding: spaceship")

    prereqs = {}

    if data.raw.surface ~= nil then
        for _, surface in pairs(data.raw.surface) do
            table.insert(prereqs, {
                type = "spaceship-surface",
                name = surface.name
            })
        end
    end

    add_to_graph("spaceship", "canonical", prereqs)

    -- spaceship-engine-surface
    log("Adding: spaceship-engine-surface")

    if data.raw.surface ~= nil then
        for _, surface in pairs(data.raw.surface) do
            prereqs = {}

            if data.raw.thruster ~= nil then
                for _, thruster in pairs(data.raw.thruster) do
                    table.insert(prereqs, {
                        type = "operate-entity-surface",
                        name = compound_key({thruster.name, compound_key({"space-surface", surface.name})})
                    })
                end
            end

            add_to_graph("spaceship-engine-surface", surface.name, prereqs)
        end
    end

    -- spaceship-surface
    log("Adding: spaceship-surface")

    if data.raw.surface ~= nil then
        for _, surface in pairs(data.raw.surface) do
            prereqs = {}

            table.insert(prereqs, {
                type = "spaceship-engine-surface",
                name = surface.name
            })
            table.insert(prereqs, {
                type = "space-surface",
                name = surface.name
            })

            add_to_graph("spaceship-surface", surface.name, prereqs)
        end
    end

    -- spawn-asteroid-chunk
    log("Adding: spawn-asteroid-chunk")
    -- Only implemented for space locations, for whether they have asteroids

    for _, asteroid_chunk in pairs(data.raw["asteroid-chunk"]) do
        prereqs = {}

        for space_location_class, _ in pairs(defines.prototypes["space-location"]) do
            if data.raw[space_location_class] ~= nil then
                for _, space_location in pairs(data.raw[space_location_class]) do
                    if space_location.asteroid_spawn_definitions ~= nil then
                        for _, spawn_defn in pairs(space_location.asteroid_spawn_definitions) do
                            if spawn_defn.type == "asteroid-chunk" and spawn_defn.asteroid == asteroid_chunk.name and spawn_defn.probability > 0 then
                                table.insert(prereqs, {
                                    type = "space-location",
                                    name = space_location.name
                                })
                            end
                        end
                    end
                end
            end
        end

        add_to_graph("spawn-asteroid-chunk", asteroid_chunk.name, prereqs)
    end

    -- spawn-entity
    log("Adding: spawn-entity")

    for _, entity in pairs(build_graph.prototypes.entities) do
        prereqs = {}

        for surface_name, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "spawn-entity-surface",
                name = compound_key({entity.name, surface_name})
            })
        end

        add_to_graph("spawn-entity", entity.name, prereqs)
    end

    -- spawn-entity-surface
    log("Adding: spawn-entity-surface")

    for _, entity in pairs(build_graph.prototypes.entities) do
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            table.insert(prereqs, {
                type = "build-entity-surface",
                name = compound_key({entity.name, surface_name})
            })
            table.insert(prereqs, {
                type = "plant-entity-surface",
                name = compound_key({entity.name, surface_name})
            })

            if check_prototype_on_surface(surface, entity) then
                table.insert(prereqs, {
                    type = "surface",
                    name = surface_name
                })
            end

            for _, enemy_spawner in pairs(data.raw["unit-spawner"]) do
                if enemy_spawner.captured_spawner_entity == entity.name then
                    table.insert(prereqs, {
                        type = "capture-spawner-surface",
                        name = compound_key({enemy_spawner.name, surface_name})
                    })
                end
            end

            for _, capsule in pairs(data.raw.capsule) do
                local creates_this_entity = false

                -- Right now, we have a few basic expectations, like entities only being made with a throw
                -- TODO: Check or generalize these assumptions
                if capsule.capsule_action.type == "throw" then
                    local ammo_type = capsule.capsule_action.attack_parameters.ammo_type
                    if ammo_type ~= nil and ammo_type.action ~= nil then
                        for _, target in pairs(build_graph.gather_targets_trigger(ammo_type.action, "entity")) do
                            -- See if this entity is a projectile that could then make another entity
                            -- TODO: Technically, this could keep looping, maybe check arbitrary recursion levels?
                            if data.raw.projectile[target] ~= nil then
                                local projectile = data.raw.projectile[target]
                                if projectile.action ~= nil then
                                    -- Assume the create-entity is in the action key
                                    for _, secondary_target in pairs(build_graph.gather_targets_trigger(projectile.action, "entity")) do
                                        if secondary_target == entity.name then
                                            creates_this_entity = true
                                        end
                                    end
                                end
                            -- Maybe this itself was the entity?
                            elseif target == entity.name then
                                creates_this_entity = true
                            end
                        end
                    end
                end

                if creates_this_entity then
                    table.insert(prereqs, {
                        type = "capsule-surface",
                        name = compound_key({capsule.name, surface_name})
                    })
                end
            end

            -- Creation from ammo item
            -- Just assume having the ammo is enough for now ugh
            -- TODO: Actual logic for the bot rocket
            for _, ammo in pairs(data.raw.ammo) do
                local creates_this_entity = false

                -- TODO: Merge this via a function with the above capsule logic
                local ammo_types = table.deepcopy(ammo.ammo_type)
                if ammo_types[1] == nil then
                    ammo_types = {ammo_types}
                end
                for _, ammo_type in pairs(ammo_types) do
                    if ammo_type.action ~= nil then
                        for _, target in pairs(build_graph.gather_targets_trigger(ammo_type.action, "entity")) do
                            -- Could go deeper with recursion
                            if data.raw.projectile[target] ~= nil then
                                local projectile = data.raw.projectile[target]
                                if projectile.action ~= nil then
                                    -- Assume the create-entity is in the action key
                                    for _, secondary_target in pairs(build_graph.gather_targets_trigger(projectile.action, "entity")) do
                                        if secondary_target == entity.name then
                                            creates_this_entity = true
                                        end
                                    end
                                end
                            -- Maybe this itself was the entity?
                            elseif target == entity.name then
                                creates_this_entity = true
                            end
                        end
                    end

                    if creates_this_entity then
                        table.insert(prereqs, {
                            type = "item-surface",
                            name = compound_key({ammo.name, surface_name})
                        })
                    end
                end
            end

            -- Did not code the corpse connections yet
            -- TODO: Code in corpse connections
            -- TODO: Preserve pentapod egg mining from gleba enemies with item randomization when I do that!

            add_to_graph("spawn-entity-surface", compound_key({entity.name, surface_name}), prereqs, {
                surface = surface_name
            })
        end
    end

    -- spawn-rail-surface
    log("Adding: spawn-rail-surface")

    -- TODO

    -- spawn-tile-surface
    log("Adding: spawn-tile-surface")

    for _, tile in pairs(data.raw.tile) do
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            if check_prototype_on_surface(surface, tile) then
                table.insert(prereqs, {
                    type = "surface",
                    name = surface_name
                })
            end

            -- If this is a space location and you can launch a starter pack somewhere, assume you can have those tiles at any space location
            -- TODO: Think past this assumption
            if surface.type == "space-surface" then
                if data.raw["space-platform-starter-pack"] ~= nil then
                    for _, starter_pack in pairs(data.raw["space-platform-starter-pack"]) do
                        if starter_pack.surface == surface.prototype.name then
                            local starts_with_tiles = false

                            if starter_pack.tiles ~= nil then
                                for _, tile_def in pairs(starter_pack.tiles) do
                                    if tile_def.tile == tile.name then
                                        starts_with_tiles = true
                                    end
                                end
                            end

                            -- Condition on this specific starter pack rather than the surface itself
                            if starts_with_tiles then
                                table.insert(prereqs, {
                                    type = "send-item-to-orbit",
                                    name = starter_pack.name
                                })
                            end
                        end
                    end
                end
            end

            table.insert(prereqs, {
                type = "build-tile-surface",
                name = compound_key({tile.name, surface_name})
            })

            add_to_graph("spawn-tile-surface", compound_key({tile.name, surface_name}), prereqs, {
                surface = surface_name
            })
        end
    end

    -- spawner-capturability
    log("Adding: spawner-capturability")

    prereqs = {}

    for _, enemy_spawner in pairs(data.raw["unit-spawner"]) do
        for surface_name, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "capture-spawner-surface",
                name = compound_key({enemy_spawner.name, surface_name})
            })
        end
    end

    add_to_graph("spawner-capturability", "canonical", prereqs)

    -- starting-character
    log("Adding: starting-character")

    prereqs = {}

    add_to_graph("starting-character", "canonical", prereqs)

    -- starting-planet
    log("Adding: starting-planet")

    prereqs = {}

    add_to_graph("starting-planet", "canonical", prereqs)

    -- surface
    log("Adding: surface")

    for surface_name, surface in pairs(surfaces) do
        prereqs = {}

        table.insert(prereqs, {
            type = surface.type,
            name = surface.prototype.name
        })

        add_to_graph("surface", surface_name, prereqs)
    end

    -- technology
    log("Adding: technology")

    for _, tech in pairs(data.raw.technology) do
        prereqs = {}

        if tech.prerequisites ~= nil then
            for _, prerequisite in pairs(tech.prerequisites) do
                table.insert(prereqs, {
                    type = "technology",
                    name = prerequisite
                })
            end
        end

        if tech.unit ~= nil then
            local science_pack_set = {}
            for _, ing in pairs(tech.unit.ingredients) do
                table.insert(science_pack_set, ing[1])
                table.insert(prereqs, {
                    type = "item",
                    name = ing[1]
                })
            end
            table.sort(science_pack_set)
            table.insert(prereqs, {
                type = "science-pack-set",
                name = compound_key(science_pack_set)
            })
        else
            local trigger = tech.research_trigger

            if trigger.type == "mine-entity" then
                table.insert(prereqs, {
                    type = "mine-entity",
                    name = trigger.entity
                })
            elseif trigger.type == "craft-item" then
                table.insert(prereqs, {
                    type = "craft-material",
                    name = "item-" .. trigger.item
                })
            elseif trigger.type == "craft-fluid" then
                table.insert(prereqs, {
                    type = "craft-material",
                    name = "fluid-" .. trigger.fluid
                })
            elseif trigger.type == "send-item-to-orbit" then
                table.insert(prereqs, {
                    type = "send-item-to-orbit",
                    name = trigger.item
                })
            elseif trigger.type == "capture-spawner" then
                table.insert(prereqs, {
                    type = "spawner-capturability",
                    name = "canonical"
                })
            elseif trigger.type == "build-entity" then
                -- TODO: Technically, this can require quality, so we could check that the quality is unlocked too
                -- TODO: In general, go back and check if anywhere can also depend on quality?
                table.insert(prereqs, {
                    type = "build-entity",
                    name = trigger.entity
                })
            elseif trigger.type == "create-space-platform" then
                table.insert(prereqs, {
                    type = "create-space-platform",
                    name = "canonical"
                })
            end
        end

        add_to_graph("technology", tech.name, prereqs)
    end

    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                prereqs = {}

                local can_be_transported = true

                -- Check spoiled, less than 1.5 hours is too short
                if item.spoil_ticks ~= nil and item.spoil_ticks < 60 * 60 * 90 then
                    can_be_transported = false
                end

                -- TODO: Calculate weight if it's nil
                if item.weight ~= nil and item.weight > data.raw["utility-constants"].default.rocket_lift_weight then
                    can_be_transported = false
                end

                if can_be_transported then
                    for surface_name, surface in pairs(surfaces) do
                        table.insert(prereqs, {
                            type = "item-surface",
                            name = compound_key({item.name, surface_name})
                        })
                    end
                end

                add_to_graph("transport-item", item.name, prereqs)
            end
        end
    end

    -- transport-item-to-surface
    log("Adding: transport-item-to-surface")

    for item_class, _ in pairs(defines.prototypes.item) do
        if data.raw[item_class] ~= nil then
            for _, item in pairs(data.raw[item_class]) do
                for surface_name, surface in pairs(surfaces) do
                    prereqs = {}

                    table.insert(prereqs, {
                        type = "surface",
                        name = surface_name
                    })

                    table.insert(prereqs, {
                        type = "transport-item",
                        name = item.name
                    })

                    table.insert(prereqs, {
                        type = "spaceship",
                        name = "canonical"
                    })

                    add_to_graph("transport-item-to-surface", compound_key({item.name, surface_name}), prereqs)
                end
            end
        end
    end

    -- valid-tile-placement-surface
    log("Adding: valid-tile-placement-surface")

    for _, tile in pairs(data.raw.tile) do
        for surface_name, surface in pairs(surfaces) do
            prereqs = {}

            -- Just check collision for now
            -- TODO: Check more general buildability rules
            -- TODO: Check if collision even prevents tiles from being put down? It replaces the tile anyways right?

            for _, tile_2 in pairs(data.raw.tile) do
                if not collision_mask_util.masks_collide(tile.collision_mask, tile_2.collision_mask) then
                    table.insert(prereqs, {
                        type = "spawn-tile-surface",
                        name = compound_key({tile_2.name, surface_name})
                    })
                end
            end

            add_to_graph("valid-tile-placement-surface", compound_key({tile.name, surface_name}), prereqs, {
                surface = surface_name
            })
        end
    end

    -- void-energy
    log("Adding: void-energy")

    prereqs = {}

    add_to_graph("void-energy", "canonical", prereqs)

    ----------------------------------------------------------------------
    -- Load in new graph
    ----------------------------------------------------------------------

    log("Finished building dependency graph")

    build_graph.graph = graph
end
-- export
build_graph.load = load

----------------------------------------------------------------------
-- Ops
----------------------------------------------------------------------

build_graph.ops = {
    -- SOURCE's are just AND's
    ["agricultural-tower-surface"] = "OR",
    ["asteroid-collection-surface"] = "OR",
    ["build-entity"] = "OR",
    ["build-entity-item"] = "OR",
    ["build-entity-surface"] = "AND",
    ["build-entity-surface-condition-false"] = "OR",
    ["build-entity-surface-condition-true"] = "AND",
    ["build-tile"] = "OR",
    ["build-tile-item-surface"] = "OR",
    ["build-tile-item-surface-buildability"] = "OR",
    ["build-tile-item-surface-with-item"] = "AND",
    ["build-tile-surface"] = "AND",
    ["burn-item"] = "AND",
    ["burn-item-surface"] = "AND",
    ["capsule-surface"] = "AND",
    ["capture-robot"] = "OR",
    ["capture-spawner-surface"] = "AND",
    ["cargo-landing-pad-planet"] = "OR",
    ["character"] = "OR",
    ["craft-material"] = "OR",
    ["craft-material-surface"] = "OR",
    ["create-fluid-offshore-surface"] = "AND",
    ["create-fluid-surface"] = "OR",
    ["create-space-platform"] = "OR",
    ["create-space-platform-tech-unlock"] = "OR",
    ["damage-type-amount-surface"] = "OR",
    ["electricity-distribution-surface"] = "OR",
    ["electricity-production-surface"] = "OR",
    ["electricity-surface"] = "AND",
    ["energy-source-surface"] = "OR",
    ["entity-buildability-surface"] = "OR",
    ["entity-buildability-surface-true"] = "AND",
    ["entity-operation-items"] = "OR",
    ["fluid"] = "OR",
    ["fluid-surface"] = "AND",
    ["fuel-category"] = "OR",
    ["fuel-category-burner"] = "OR",
    ["fuel-category-burner-surface"] = "OR",
    ["fuel-category-surface"] = "OR",
    ["gun-ammo-surface"] = "AND",
    ["gun-surface"] = "OR",
    ["heat-distribution-surface"] = "OR",
    ["heat-production-surface"] = "OR",
    ["heat-surface"] = "AND",
    ["hold-fluid-surface"] = "OR",
    ["item"] = "OR",
    ["item-surface"] = "OR",
    ["item-insertion"] = "OR",
    ["loot-entity"] = "OR",
    ["loot-entity-surface"] = "AND",
    ["mine-asteroid-chunk"] = "OR",
    ["mine-asteroid-chunk-surface"] = "AND",
    ["mine-entity"] = "OR",
    ["mine-entity-surface"] = "AND",
    ["mine-tile"] = "OR",
    ["mine-tile-surface"] = "AND",
    ["mining-with-fluid-unlock"] = "OR",
    ["operate-entity"] = "OR",
    ["operate-entity-surface"] = "AND",
    ["operate-entity-surface-fluid"] = "OR",
    ["planet"] = "OR",
    ["planet-launch"] = "OR",
    ["plant-entity-item"] = "OR",
    ["plant-entity-surface"] = "AND",
    ["plant-entity-surface-automatability"] = "AND",
    ["plant-entity-surface-condition-false"] = "OR",
    ["plant-entity-surface-condition-true"] = "AND",
    ["recipe"] = "OR",
    ["recipe-category"] = "OR",
    ["recipe-category-surface"] = "OR",
    ["recipe-category-surface-automation"] = "OR",
    ["recipe-surface"] = "AND",
    ["recipe-surface-condition-false"] = "OR",
    ["recipe-surface-condition-true"] = "AND",
    ["recipe-tech-unlock"] = "OR",
    ["resource-category"] = "OR",
    ["resource-category-surface"] = "OR",
    ["rocket-launch-planet"] = "OR",
    ["rocket-part-recipe-planet"] = "AND",
    ["science-pack-set"] = "OR",
    ["send-item-to-orbit"] = "OR",
    ["send-item-to-orbit-planet"] = "AND",
    ["send-surface-starter-pack"] = "OR",
    ["send-surface-starter-pack-planet"] = "OR",
    ["space-connection"] = "AND",
    ["space-location"] = "OR",
    ["space-location-discovery"] = "OR",
    ["space-surface"] = "AND",
    ["spaceship"] = "OR",
    ["spaceship-engine-surface"] = "OR",
    ["spaceship-surface"] = "AND",
    ["spawn-asteroid-chunk"] = "OR",
    ["spawn-entity"] = "OR",
    ["spawn-entity-surface"] = "OR",
    ["spawn-rail-surface"] = "OR",
    ["spawn-tile-surface"] = "OR",
    ["spawner-capturability"] = "OR",
    ["starting-character"] = "AND",
    ["starting-planet"] = "AND",
    ["surface"] = "OR",
    ["technology"] = "AND",
    ["thruster-surface"] = "AND",
    ["transport-item"] = "OR",
    ["transport-item-to-surface"] = "AND",
    ["valid-tile-placement-surface"] = "OR",
    ["void-energy"] = "AND"
}

----------------------------------------------------------------------
-- Special manipulation methods
----------------------------------------------------------------------

function build_graph.reverse(graph_param)
    for _, node in pairs(graph_param) do
        local old_prereqs = node.prereqs
        node.prereqs = node.dependents
        node.dependents = old_prereqs
    end

    -- Switch node ops?
end

----------------------------------------------------------------------
-- Dependents
----------------------------------------------------------------------

function build_graph.add_dependents(graph_param)
    for _, node in pairs(graph_param) do
        node.dependents = {}
    end
    for _, node in pairs(graph_param) do
        for _, prereq in pairs(node.prereqs) do
            if prereq.name == nil then
                log(serpent.block(node))
            end
            -- If the prereq doesn't exist, log it
            if graph_param[key(prereq.type, prereq.name)] == nil then
                log(serpent.block(node))
                log(serpent.block(prereq))
                error()
            end

            table.insert(graph_param[key(prereq.type, prereq.name)].dependents, {
                type = node.type,
                name = node.name
            })
        end
    end
end

load()

-- TODO: Function inspired by code that used to be here to determine complexity of graph for future optimization purposes if I go that route

return build_graph