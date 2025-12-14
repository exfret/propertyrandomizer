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

-- Select separator strings with characters that cannot appear in names
-- Assuming all names are [a-z-]+

local node_key_separator = ":"
local node_name_separator = "_"

-- Get key from type + name

local function key(node_type, node_name)
    return node_type .. node_key_separator .. node_name
end
-- export for other files to use
build_graph.key = key

-- Turn a table/list of strings into a string

local function compound_key(tbl)
    -- serpent.block wasn't working for some reason?
    local separator = node_name_separator
    local my_str = ""
    for _, entry in pairs(tbl) do
        my_str = my_str .. separator .. tostring(entry)
    end
    -- Remove initial bbb
    return string.sub(my_str, 1 + #node_name_separator, -1)
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
build_graph.spoofed_recipe_categories = {}
local function recalculate_spoofed_recipe_categories()
    for _, recipe in pairs(data.raw.recipe) do
        local spoofed_category_name = recipe_to_spoofed_category_name(recipe)
        if build_graph.spoofed_recipe_categories[spoofed_category_name] == nil then
            local fluid_amounts = recipe_to_num_fluids(recipe)

            build_graph.spoofed_recipe_categories[spoofed_category_name] = {
                recipe_category = data.raw["recipe-category"][recipe.category or "crafting"],
                input_fluids = fluid_amounts.input_fluids,
                output_fluids = fluid_amounts.output_fluids
            }
        end
    end
end
recalculate_spoofed_recipe_categories()
build_graph.recalculate_spoofed_recipe_categories = recalculate_spoofed_recipe_categories

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
build_graph.spoofed_resource_categories = {}
local function recalculate_spoofed_resource_categories()
    for _, resource in pairs(data.raw.resource) do
        local spoofed_category_name = resource_to_spoofed_category_name(resource)
        if build_graph.spoofed_resource_categories[spoofed_category_name] == nil then
            local fluid_amounts = resource_to_fluids(resource)

            build_graph.spoofed_resource_categories[spoofed_category_name] = {
                resource_category = data.raw["resource-category"][resource.category or "basic-solid"],
                input_fluid = fluid_amounts.input_fluid,
                output_fluid = fluid_amounts.output_fluid
            }
        end
    end
end
recalculate_spoofed_resource_categories()
build_graph.recalculate_spoofed_resource_categories = recalculate_spoofed_resource_categories

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

-- entity lookup
local entities = {}
for _, entity in pairs(build_graph.prototypes.entities) do
    entities[entity.name] = entity
end

-- item lookup
local items = {}
for item_class, _ in pairs(defines.prototypes.item) do
    if data.raw[item_class] ~= nil then
        for _, item in pairs(data.raw[item_class]) do
            items[item.name] = item
        end
    end
end

-- Get materials
local materials = {}
for _, item in pairs(items) do
    materials["item-" .. item.name] = item
end
for _, fluid in pairs(data.raw.fluid) do
    materials["fluid-" .. fluid.name] = fluid
end
-- export
build_graph.materials = materials

local mtm_insert = function (many_to_many_lookup_table, key, prototype)
    if many_to_many_lookup_table[key] == nil then
        many_to_many_lookup_table[key] = {}
    end
    many_to_many_lookup_table[key][prototype.name] = prototype
end

local mtm_lookup = function (many_to_many_lookup_table, key)
    if many_to_many_lookup_table[key] == nil then
        return {}
    end
    return many_to_many_lookup_table[key]
end

local get_ammo_categories = function (attack_parameters)
    local ammo_categories = attack_parameters.ammo_categories
    if ammo_categories == nil then
        ammo_categories = { attack_parameters.ammo_category }
    end
    return ammo_categories
end

-- data.raw[class_name] or {}
local get_prototypes = function (class_name)
    if data.raw[class_name] == nil then
        return {}
    end
    return data.raw[class_name]
end

local amount_expected_value = function (product_or_ingredient)
    local expected_value = product_or_ingredient.amount
    if product_or_ingredient.amount == nil then
        local amount_max = product_or_ingredient.amount_max
        if product_or_ingredient.amount_max < product_or_ingredient.amount_min then
            amount_max = product_or_ingredient.amount_min
        end
        expected_value = (product_or_ingredient.amount_min + amount_max) / 2
    end
    if product_or_ingredient.extra_count_fraction ~= nil then
        expected_value = expected_value + product_or_ingredient.extra_count_fraction
    end
    if product_or_ingredient.probability ~= nil then
        expected_value = expected_value * product_or_ingredient.probability
    end
    return expected_value
end

local function load()

    ----------------------------------------------------------------------
    -- Lookup tables
    ----------------------------------------------------------------------

    -- Not all of these need to be in load()
    -- Placing them here just ensures that they're updated along with changes to data.raw

    -- Get buildable things
    --    * place_result
    --    * plant_result
    --    * place_as_tile

    local place_result_key = "place_result"
    local plant_result_key = "plant_result"
    local place_as_tile_key = "place_as_tile"
    local buildable_entity_keys = { place_result_key, plant_result_key }
    local buildable_entities = {}
    local buildable_tiles = {}
    local in_buildables = {}

    -- lookup table for items that build an entity
    local buildable_entity_to_items = {}
    -- lookup table for items that build a tile
    local buildable_tile_to_items = {}

    for _, result_key in pairs(buildable_entity_keys) do
        buildable_entities[result_key] = {}
        in_buildables[result_key] = {}
    end
    in_buildables[place_as_tile_key] = {}
    for _, item in pairs(items) do
        for _, result_key in pairs(buildable_entity_keys) do
            if item[result_key] ~= nil then
                local entity_name = item[result_key]
                if not in_buildables[item[result_key]] then
                    buildable_entities[result_key][entity_name] = entities[entity_name]
                    in_buildables[result_key][item[result_key]] = true
                end
                mtm_insert(buildable_entity_to_items, entity_name, item)
            end
        end
        if item.place_as_tile ~= nil then
            local tile_name = item.place_as_tile.result
            if not in_buildables[item.place_as_tile] then
                buildable_tiles[tile_name] = data.raw.tile[tile_name]
                in_buildables[place_as_tile_key][tile_name] = true
            end
            mtm_insert(buildable_tile_to_items, tile_name, item)
        end
    end

    -- lookup table for finding fuels with a particular burnt result
    local burnt_result_to_fuels = {}
    -- lookup for finding fuel per fuel category
    local fuel_category_to_fuels = {}
    -- lookup for finding items that spoil into the item
    local spoil_result_to_items = {}
    -- lookup for finding items that have the item as a rocket launch product
    local rocket_launch_product_to_items = {}
    for _, item in pairs(items) do
        if item.fuel_category ~= nil and item.burnt_result ~= nil then
            mtm_insert(burnt_result_to_fuels, item.burnt_result, item)
        end
        if item.fuel_category ~= nil then
            mtm_insert(fuel_category_to_fuels, item.fuel_category, item)
        end
        if item.spoil_result ~= nil then
            mtm_insert(spoil_result_to_items, item.spoil_result, item)
        end
        if item.rocket_launch_products ~= nil then
            for _, result in pairs(item.rocket_launch_products) do
                mtm_insert(rocket_launch_product_to_items, result.name, item)
            end
        end
    end

    -- recipe result lookup table
    local result_material_to_recipes = {}
    -- lookup table for finding all recipes of a spoofed crafting category
    local spoofed_recipe_category_to_recipes = {}
    for _, recipe in pairs(get_prototypes("recipe")) do
        if recipe.results ~= nil then
            for _, product in pairs(recipe.results) do
                if amount_expected_value(product) > 0 then
                    local material_name = product.type .. "-" .. product.name
                    mtm_insert(result_material_to_recipes, material_name, recipe)
                end
            end
        end
        local spoofed_category_name = recipe_to_spoofed_category_name(recipe)
        mtm_insert(spoofed_recipe_category_to_recipes, spoofed_category_name, recipe)
    end

    -- tiles you can use an offshore pump on
    local tiles_with_fluid = {}
    -- lookup table for finding tiles for each fluid
    local fluid_to_tiles = {}
    for _, tile in pairs(get_prototypes("tile")) do
        if tile.fluid ~= nil then
            tiles_with_fluid[tile.name] = tile
            mtm_insert(fluid_to_tiles, tile.fluid, tile)
        end
    end

    -- lookup for finding burner entities per fuel category
    local fuel_category_to_burners = {}

    -- We don't care about the type of energy source here, so we can just search over all of them
    -- Valid energy source keys are exactly "energy_source" and "burner"
    for _, entity in pairs(build_graph.prototypes.entities) do
        for _, property in pairs({"burner", "energy_source"}) do
            if entity[property] ~= nil then
                local energy_source = entity[property]

                if energy_source.type == "burner" then
                    for _, fuel_category_id in pairs(energy_source.fuel_categories or {"chemical"}) do
                        mtm_insert(fuel_category_to_burners, fuel_category_id, entity)
                    end
                end
            end
        end
    end

    -- lookup for finding entities that can be mined to get the item
    local mining_result_item_to_entities = {}
    -- lookup for finding entities that can be looted to get the item
    local loot_to_entities = {}
    for _, entity in pairs(build_graph.prototypes.entities) do
        if entity.minable ~= nil then
            if entity.minable.results ~= nil then
                for _, result in pairs(entity.minable.results) do
                    if result.type == "item" and amount_expected_value(result) > 0 then
                        mtm_insert(mining_result_item_to_entities, result.name, entity)
                    end
                end
            elseif entity.minable.result ~= nil then
                mtm_insert(mining_result_item_to_entities, entity.minable.result, entity)
            end
        end
        if entity.loot ~= nil then
            for _, loot in pairs(entity.loot) do
                mtm_insert(loot_to_entities, loot.item, entity)
            end
        end
    end

    -- lookup for finding tiles that can be mined to get the item
    local mining_result_to_tiles = {}
    for _, tile in pairs(get_prototypes("tile")) do
        if tile.minable ~= nil then
            if tile.minable.results ~= nil then
                for _, result in pairs(tile.minable.results) do
                    if result.type == "item" and amount_expected_value(result) > 0 then
                        mtm_insert(mining_result_to_tiles, result.name, tile)
                    end
                end
            elseif tile.minable.result ~= nil then
                mtm_insert(mining_result_to_tiles, tile.minable.result, tile)
            end
        end
    end

    -- lookup table to find technologies that unlock a recipe
    local recipe_to_technology = {}
    for _, tech in pairs(get_prototypes("technology")) do
        if tech.effects ~= nil then
            for _, effect in pairs(tech.effects) do
                if effect.type == "unlock-recipe" then
                    mtm_insert(recipe_to_technology, effect.recipe, tech)
                end
            end
        end
    end

    -- lookup table to find recipes that a crafting machine can use
    local crafting_machine_to_recipes = {}
    for crafting_machine_class, _ in pairs(crafting_machine_classes) do
        for _, crafting_machine in pairs(get_prototypes(crafting_machine_class)) do
            for spoofed_recipe_category_name, spoofed_recipe_category in pairs(build_graph.spoofed_recipe_categories) do
                if is_crafting_machine_compatible_with_recipe_category(crafting_machine, spoofed_recipe_category) then
                    for _, recipe in pairs(mtm_lookup(spoofed_recipe_category_to_recipes, spoofed_recipe_category_name)) do
                        mtm_insert(crafting_machine_to_recipes, crafting_machine.name, recipe)
                    end
                end
            end
        end
    end

    -- lookup table to find capsules that spawn an entity
    local entity_to_capsules = {}
    for _, capsule in pairs(get_prototypes("capsule")) do
        -- Right now, we have a few basic expectations, like entities only being made with a throw
        -- TODO: Check or generalize these assumptions
        if capsule.capsule_action.type == "throw" then
            local ammo_type = capsule.capsule_action.attack_parameters.ammo_type
            if ammo_type ~= nil and ammo_type.action ~= nil then
                for _, target in pairs(build_graph.gather_targets_trigger(ammo_type.action, "entity")) do
                    -- See if this entity is a projectile that could then make another entity
                    -- TODO: Technically, this could keep looping, maybe check arbitrary recursion levels?
                    local projectile = get_prototypes("projectile")[target]
                    if projectile ~= nil then
                        if projectile.action ~= nil then
                            -- Assume the create-entity is in the action key
                            for _, secondary_target in pairs(build_graph.gather_targets_trigger(projectile.action, "entity")) do
                                if entities[secondary_target] ~= nil then
                                    mtm_insert(entity_to_capsules, secondary_target, capsule)
                                end
                            end
                        end
                    -- Maybe this itself was the entity?
                    elseif entities[target] ~= nil then
                        mtm_insert(entity_to_capsules, target, capsule)
                    end
                end
            end
        end
    end

    -- ammo category to ammo lookup table
    local ammo_category_to_ammos = {}
    -- lookup table to find ammos that spawn an entity
    local entity_to_ammos = {}
    for _, ammo in pairs(data.raw.ammo) do
        mtm_insert(ammo_category_to_ammos, ammo.ammo_category, ammo)

        -- Creation from ammo item
        -- Just assume having the ammo is enough for now ugh
        -- TODO: Actual logic for the bot rocket
        -- TODO: Merge this via a function with the above capsule logic
        local ammo_types = table.deepcopy(ammo.ammo_type)
        if ammo_types[1] == nil then
            ammo_types = {ammo_types}
        end
        for _, ammo_type in pairs(ammo_types) do
            if ammo_type.action ~= nil then
                for _, target in pairs(build_graph.gather_targets_trigger(ammo_type.action, "entity")) do
                    -- Could go deeper with recursion
                    local projectile = get_prototypes("projectile")[target]
                    if projectile ~= nil then
                        if projectile.action ~= nil then
                            -- Assume the create-entity is in the action key
                            for _, secondary_target in pairs(build_graph.gather_targets_trigger(projectile.action, "entity")) do
                                if entities[secondary_target] ~= nil then
                                    mtm_insert(entity_to_ammos, secondary_target, ammo)
                                end
                            end
                        end
                    -- Maybe this itself was the entity?
                    elseif entities[target] ~= nil then
                        mtm_insert(entity_to_ammos, target, ammo)
                    end
                end
            end
        end
    end
    
    -- Update spoofed recipe/resource categories
    -- This should probably just be put directly in here with the rest of the mtm stuff...
    build_graph.recalculate_spoofed_recipe_categories()
    build_graph.recalculate_spoofed_resource_categories()

    ----------------------------------------------------------------------
    -- Nodes
    ----------------------------------------------------------------------

    -- Added to build_graph later
    graph = {}

    local prereqs

    -- agricultural-tower-surface
    log("Adding: agricultural-tower-surface")
    -- Can we use any agricultural tower on this surface?

    for surface_key, surface in pairs(surfaces) do
        prereqs = {}

        for _, ag_tower in pairs(get_prototypes("agricultural-tower")) do
            -- TODO: Are there any extra requirements for the agricultural tower?
            table.insert(prereqs, {
                type = "operate-entity-surface",
                name = compound_key({ag_tower.name, surface_key})
            })
        end

        add_to_graph("agricultural-tower-surface", surface_key, prereqs, {
            surface = surface_key
        })
    end

    -- ammo-category-surface
    log("Adding: ammo-category-surface")
    -- Do we have all we need to make ammo of this category on this surface?

    for ammo_category_name, ammos in pairs(ammo_category_to_ammos) do
        for surface_key, surface in pairs(surfaces) do
            prereqs = {}

            for _, ammo in pairs(ammos) do
                table.insert(prereqs, {
                    type = "item-surface",
                    name = compound_key({ammo.name, surface_key})
                })
            end

            add_to_graph("ammo-category-surface", compound_key({ammo_category_name, surface_key}), prereqs)
        end
    end

    -- asteroid-collection-surface
    log("Adding: asteroid-collection-surface")
    -- Only implemented for space surfaces
    -- Can we use any asteroid collector on this surface?

    for _, surface in pairs(get_prototypes("surface")) do
        prereqs = {}
        local surface_key = compound_key({"space-surface", surface.name})

        for _, entity in pairs(get_prototypes("asteroid-collector")) do
            table.insert(prereqs, {
                type = "operate-entity-surface",
                name = compound_key({entity.name, surface_key})
            })
        end

        add_to_graph("asteroid-collection-surface", surface.name, prereqs, {
            surface = surface_key
        })
    end

    -- build-entity
    log("Adding: build-entity")
    -- Can we build this entity somewhere?

    for _, build_key in pairs(buildable_entity_keys) do
        for _, entity in pairs(buildable_entities[build_key]) do
            prereqs = {}

            for surface_key, surface in pairs(surfaces) do
                table.insert(prereqs, {
                    type = "build-entity-surface",
                    name = compound_key({entity.name, surface_key})
                })
            end

            add_to_graph("build-entity", entity.name, prereqs)
        end
    end

    -- build-entity-item
    log("Adding: build-entity-item")
    -- May an item we have somewhere allow us to build this entity?

    for _, build_key in pairs(buildable_entity_keys) do
        for _, entity in pairs(buildable_entities[build_key]) do
            prereqs = {}

            for surface_key, surface in pairs(surfaces) do
                table.insert(prereqs, {
                    type = "build-entity-item-surface",
                    name = compound_key({entity.name, surface_key})
                })
            end

            add_to_graph("build-entity-item", entity.name, prereqs)
        end
    end

    -- build-entity-item-surface
    log("Adding: build-entity-item-surface")
    -- May an item we have on this surface allow us to build this entity?

    for _, build_key in pairs(buildable_entity_keys) do
        for _, entity in pairs(buildable_entities[build_key]) do
            for surface_key, surface in pairs(surfaces) do
                prereqs = {}

                for _, item in pairs(mtm_lookup(buildable_entity_to_items, entity.name)) do
                    table.insert(prereqs, {
                        type = "item-surface",
                        name = compound_key({item.name, surface_key}),
                        remove_caveat = {
                            ["transported"] = true
                        }
                    })
                end

                add_to_graph("build-entity-item-surface", compound_key({entity.name, surface_key}), prereqs, {
                    surface = surface_key
                })
            end
        end
    end

    -- build-entity-surface
    log("Adding: build-entity-surface")
    -- Do we have all we need to build this entity on this surface?

    for _, build_key in pairs(buildable_entity_keys) do
        for _, entity in pairs(buildable_entities[build_key]) do
            for surface_key, surface in pairs(surfaces) do
                prereqs = {}

                table.insert(prereqs, {
                    type = "entity-buildability-surface",
                    name = compound_key({entity.name, surface_key}),
                    remove_caveat = {
                        ["transported"] = true
                    }
                })
                table.insert(prereqs, {
                    type = "build-entity-item-surface",
                    name = compound_key({entity.name, surface_key}),
                    remove_caveat = {
                        ["transported"] = true
                    }
                })
                table.insert(prereqs, {
                    type = "surface",
                    name = surface_key
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

                add_to_graph("build-entity-surface", compound_key({entity.name, surface_key}), prereqs, {
                    surface = surface_key
                })
            end
        end
    end

    -- build-entity-surface-condition-false
    log("Adding: build-entity-surface-condition-false")
    -- OR
    -- Does an entity's surface conditions allow us to build the entity on a surface that doesn't satisfy them?

    prereqs = {}

    add_to_graph("build-entity-surface-condition-false", "canonical", prereqs)

    -- build-entity-surface-condition-true
    log("Adding: build-entity-surface-condition-true")
    -- AND
    -- Does an entity's surface conditions allow us to build the entity on a surface that satisfies them?

    prereqs = {}

    add_to_graph("build-entity-surface-condition-true", "canonical", prereqs)

    -- build-tile
    log("Adding: build-tile")
    -- Can we build this tile somewhere?

    for _, tile in pairs(buildable_tiles) do
        prereqs = {}

        for surface_key, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "build-tile-surface",
                name = compound_key({tile.name, surface_key})
            })
        end

        add_to_graph("build-tile", tile.name, prereqs)
    end

    -- build-tile-item-surface
    log("Adding: build-tile-item-surface")
    -- Does an item we have allow us to build this tile on this surface?

    -- TODO: Put buildability check here as well
    -- TODO: Modify the spec to account for modification to this
    for _, tile in pairs(buildable_tiles) do
        for surface_key, surface in pairs(surfaces) do
            prereqs = {}

            for _, item in pairs(mtm_lookup(buildable_tile_to_items, tile.name)) do
                -- TODO: Check for conditions
                table.insert(prereqs, {
                    type = "build-tile-item-surface-with-item",
                    name = compound_key({tile.name, item.name, surface_key})
                })
            end

            add_to_graph("build-tile-item-surface", compound_key({tile.name, surface_key}), prereqs)
        end
    end

    -- build-tile-item-surface-buildability
    log("Adding: build-tile-item-surface-buildability")
    -- Would this item allow us to build this tile on this surface?

    -- Check actual tile conditions for a tile-item-surface combo
    -- TODO: Add this to the spec
    -- TODO: Account for other conditions like inverted filters
    for _, tile in pairs(buildable_tiles) do
        for _, item in pairs(mtm_lookup(buildable_tile_to_items, tile.name)) do
            for surface_key, surface in pairs(surfaces) do
                prereqs = {}

                if item.place_as_tile.tile_condition ~= nil then
                    for _, tile_id in pairs(item.place_as_tile.tile_condition) do
                        table.insert(prereqs, {
                            type = "spawn-tile-surface",
                            name = compound_key({tile_id, surface_key})
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

                add_to_graph("build-tile-item-surface-buildability", compound_key({tile.name, item.name, surface_key}), prereqs)
            end
        end
    end

    -- build-tile-item-surface-with-item
    log("Adding: build-tile-item-surface-with-item")
    -- Do we have all we need to build this tile on this surface using this item?

    -- TODO: Add this to the spec
    for _, tile in pairs(buildable_tiles) do
        for _, item in pairs(mtm_lookup(buildable_tile_to_items, tile.name)) do
            for surface_key, surface in pairs(surfaces) do
                prereqs = {}

                table.insert(prereqs, {
                    type = "build-tile-item-surface-buildability",
                    name = compound_key({tile.name, item.name, surface_key})
                })
                table.insert(prereqs, {
                    type = "item-surface",
                    name = compound_key({item.name, surface_key}),
                    remove_caveat = {
                        ["transported"] = true
                    }
                })

                add_to_graph("build-tile-item-surface-with-item", compound_key({tile.name, item.name, surface_key}), prereqs)
            end
        end
    end

    -- build-tile-surface
    log("Adding: build-tile-surface")
    -- Do we have all we need to build this tile on this surface?

    for _, tile in pairs(buildable_tiles) do
        for surface_key, surface in pairs(surfaces) do
            prereqs = {}

            table.insert(prereqs, {
                type = "build-tile-item-surface",
                name = compound_key({tile.name, surface_key}),
                remove_caveat = {
                    ["transported"] = true
                }
            })
            table.insert(prereqs, {
                type = "valid-tile-placement-surface",
                name = compound_key({tile.name, surface_key}),
                remove_caveat = {
                    ["transported"] = true
                }
            })
            table.insert(prereqs, {
                type = "surface",
                name = surface_key,
                remove_caveat = {
                    ["transported"] = true
                }
            })

            add_to_graph("build-tile-surface", compound_key({tile.name, surface_key}), prereqs, {
                surface = surface_key
            })
        end
    end

    -- burn-item
    log("Adding: burn-item")
    -- Do we have all we need to use this item as fuel somewhere?

    for _, fuels in pairs(burnt_result_to_fuels) do
        for _, fuel in pairs(fuels) do
            prereqs = {}
    
            for surface_key, _ in pairs(surfaces) do
                table.insert(prereqs, {
                    type = "burn-item-surface",
                    name = compound_key({fuel.name, surface_key})
                })
            end
    
            add_to_graph("burn-item", fuel.name, prereqs)
        end
    end

    -- burn-item-surface
    log("Adding: burn-item-surface")
    -- Do we have all we need to use this item as fuel on this surface?

    for _, fuels in pairs(burnt_result_to_fuels) do
        for _, fuel in pairs(fuels) do
            for surface_key, surface in pairs(surfaces) do
                prereqs = {}

                table.insert(prereqs, {
                    type = "item-surface",
                    name = compound_key({fuel.name, surface_key})
                })
                table.insert(prereqs, {
                    type = "fuel-category-burner-surface",
                    name = compound_key({fuel.fuel_category, surface_key})
                })

                add_to_graph("burn-item-surface", compound_key({fuel.name, surface_key}), prereqs)
            end
        end
    end

    -- capsule-surface
    log("Adding: capsule-surface")
    -- Do we have all we need to use this capsule on this surface?

    for _, capsule in pairs(get_prototypes("capsule")) do
        for surface_key, surface in pairs(surfaces) do
            if surface.type == "planet" then
                prereqs = {}

                table.insert(prereqs, {
                    type = "item",
                    name = capsule.name
                })
                table.insert(prereqs, {
                    type = "surface",
                    name = surface_key
                })

                add_to_graph("capsule-surface", compound_key({capsule.name, surface_key}), prereqs, {
                    surface = surface_key
                })
            end
        end
    end

    -- capture-robot
    log("Adding: capture-robot")
    -- Do we have all we need to spawn a capture robot somewhere?

    prereqs = {}

    for _, robot in pairs(get_prototypes("capture-robot")) do
        table.insert(prereqs, {
            type = "spawn-entity",
            name = robot.name
        })
    end

    add_to_graph("capture-robot", "canonical", prereqs)

    -- capture-spawner-surface
    log("Adding: capture-spawner-surface")
    -- Do we have all we need to capture a unit-spawner on this surface?

    for _, spawner in pairs(get_prototypes("unit-spawner")) do
        for surface_key, surface in pairs(surfaces) do
            prereqs = {}

            table.insert(prereqs, {
                type = "spawn-entity-surface",
                name = compound_key({spawner.name, surface_key})
            })
            table.insert(prereqs, {
                type = "capture-robot",
                name = "canonical"
            })

            add_to_graph("capture-spawner-surface", compound_key({spawner.name, surface_key}), prereqs, {
                surface = surface_key
            })
        end
    end

    -- cargo-landing-pad-planet
    log("Adding: cargo-landing-pad-planet")
    -- Do we have all we need to use a cargo landing pad on this planet?

    for _, planet in pairs(get_prototypes("planet")) do
        prereqs = {}

        for _, cargo_pad in pairs(get_prototypes("cargo-landing-pad")) do
            table.insert(prereqs, {
                type = "operate-entity-surface",
                name = compound_key({cargo_pad.name, compound_key({"planet", planet.name})})
            })
        end

        add_to_graph("cargo-landing-pad-planet", planet.name, prereqs)
    end

    -- character
    log("Adding: character")
    -- Do we have all we need to use a character somewhere?

    for _, character in pairs(get_prototypes("character")) do
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
    -- Do we have all we need to craft this material somewhere?

    for material_name, _ in pairs(materials) do
        prereqs = {}

        for surface_key, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "craft-material-surface",
                name = compound_key({material_name, surface_key})
            })
        end

        add_to_graph("craft-material", material_name, prereqs, {
            material = material_name,
        })
    end

    -- craft-material-surface
    log("Adding: craft-material-surface")
    -- Do we have all we need to craft this material on this surface?

    for material_name, _ in pairs(materials) do
        for surface_key, surface in pairs(surfaces) do
            prereqs = {}

            for _, recipe in pairs(mtm_lookup(result_material_to_recipes, material_name)) do
                table.insert(prereqs, {
                    type = "recipe-surface",
                    name = compound_key({recipe.name, surface_key})
                })
            end

            add_to_graph("craft-material-surface", compound_key({material_name, surface_key}), prereqs, {
                surface = surface_key,
                material = material_name,
            })
        end
    end

    -- create-fluid
    log("Adding: create-fluid")
    -- Can we create this fluid somewhere?
    -- This is unnecessary for reachability, but needed for technical purposes in unified randomization

    for _, fluid in pairs(get_prototypes("fluid")) do
        prereqs = {}

        for surface_name, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "create-fluid-surface",
                name = compound_key({fluid.name, surface_name})
            })
        end

        add_to_graph("create-fluid", fluid.name, prereqs, {
            fluid = fluid.name
        })
    end

    -- create-fluid-offshore-surface
    log("Adding: create-fluid-offshore-surface")
    -- Do we have all we need to use this offshore pump on this tile on this surface?

    for _, pump in pairs(get_prototypes("offshore-pump")) do
        for _, tile in pairs(tiles_with_fluid) do
            -- I'm not too sure what this does as it's written, feels like it should just be *every* triple, but only with the connections on valid ones
            -- As in fun mode, there is somehow some way of making offshore pumps make fluid dependent on the offshore pump rather than the tile
            -- However, it seems space age doesn't use this and it seems like dark voodoo to me so I won't account for it
            -- Note: It's from the offshore pump filter, which isn't too bad, maybe I could do that
            -- TODO: See above
            -- TODO: Check more than just them not colliding
            if not collision_mask_util.masks_collide(tile.collision_mask, pump.collision_mask or collision_mask_util.get_default_mask("offshore-pump")) then
                for surface_key, surface in pairs(surfaces) do
                    prereqs = {}

                    table.insert(prereqs, {
                        type = "spawn-tile-surface",
                        name = compound_key({tile.name, surface_key})
                    })
                    table.insert(prereqs, {
                        type = "operate-entity-surface",
                        name = compound_key({pump.name, surface_key})
                    })

                    add_to_graph("create-fluid-offshore-surface", compound_key({compound_key({pump.name, tile.name}), surface_key}), prereqs, {
                        surface = surface_key
                    })
                end
            end
        end
    end

    -- create-fluid-surface
    log("Adding: create-fluid-surface")
    -- Do we have all we need to obtain this fluid on this surface?

    for _, fluid in pairs(get_prototypes("fluid")) do
        for surface_key, surface in pairs(surfaces) do
            prereqs = {}

            table.insert(prereqs, {
                type = "craft-material-surface",
                name = compound_key({"fluid-" .. fluid.name, surface_key})
            })

            for _, tile in pairs(mtm_lookup(fluid_to_tiles, fluid.name)) do
                for _, pump in pairs(get_prototypes("offshore-pump")) do
                    -- TODO: Also check if pump has filter for this fluid!
                    if not collision_mask_util.masks_collide(tile.collision_mask, pump.collision_mask or collision_mask_util.get_default_mask("offshore-pump")) then
                        table.insert(prereqs, {
                            type = "create-fluid-offshore-surface",
                            name = compound_key({pump.name, tile.name, surface_key})
                        })
                    end
                end
            end

            for _, boiler in pairs(get_prototypes("boiler")) do
                if boiler.output_fluid_box.filter == fluid.name then
                    table.insert(prereqs, {
                        type = "operate-entity-surface",
                        name = compound_key({boiler.name, surface_key})
                    })
                end
            end

            for _, resource in pairs(get_prototypes("resource")) do
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
                        name = compound_key({resource.name, surface_key})
                    })
                end
            end

            for _, reactor in pairs(get_prototypes("fusion-reactor")) do
                if reactor.output_fluid_box.filter == fluid.name then
                    table.insert(prereqs, {
                        type = "operate-entity-surface",
                        name = compound_key({reactor.name, surface_key})
                    })
                end
            end

            for _, generator in pairs(get_prototypes("fusion-generator")) do
                if generator.output_fluid_box.filter == fluid.name then
                    table.insert(prereqs, {
                        type = "operate-entity-surface",
                        name = compound_key({generator.name, surface_key})
                    })
                end
            end

            add_to_graph("create-fluid-surface", compound_key({fluid.name, surface_key}), prereqs, {
                fluid = fluid.name,
                surface = surface_key
            })
        end
    end

    -- create-space-platform
    log("Adding: create-space-platform")
    -- Do we have all we need to create a space platform?

    prereqs = {}

    for _, surface in pairs(get_prototypes("surface")) do
        table.insert(prereqs, {
            type = "space-surface",
            name = surface.name
        })
    end

    add_to_graph("create-space-platform", "canonical", prereqs)

    -- create-space-platform-tech-unlock
    log("Adding: create-space-platform-tech-unlock")
    -- Are space platforms unlocked?

    prereqs = {}

    for _, tech in pairs(get_prototypes("technology")) do
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
    -- Can we deal damage to stuff on this surface?

    -- TODO: Make this something other than just a source
    -- We're basically assuming here that the player can take down anything

    prereqs = {}

    table.insert(prereqs, {
        type = "starting-character",
        name = "canonical"
    })

    add_to_graph("gun-ammo-surface", "canonical", prereqs)

    -- electricity-distribution-space-platfrom
    log("Adding: electricity-distribution-space-platfrom")
    -- Do we have all we need to build electricity distribution infrastructure on a space platform?

    prereqs = {}

    add_to_graph("electricity-distribution-space-platfrom", "canonical", prereqs)

    -- electricity-distribution-surface
    log("Adding: electricity-distribution-surface")
    -- Do we have all we need to build electricity distribution infrastructure on this surface?

    for surface_key, surface in pairs(surfaces) do
        prereqs = {}

        if surface.type == "planet" then
            for _, electric_pole in pairs(get_prototypes("electric-pole")) do
                table.insert(prereqs, {
                    type = "operate-entity-surface",
                    name = compound_key({electric_pole.name, surface_key})
                })
            end
        elseif surface.type == "space-surface" then
            table.insert(prereqs, {
                type = "electricity-distribution-space-platfrom",
                name = "canonical"
            })
        end

        add_to_graph("electricity-distribution-surface", surface_key, prereqs, {
            surface = surface_key
        })
    end

    -- electricity-production-surface
    log("Adding: electricity-production-surface")
    -- Do we have all we need to produce electricity on this surface?

    for surface_key, surface in pairs(surfaces) do
        prereqs = {}

        for _, generator in pairs(get_prototypes("burner-generator")) do
            table.insert(prereqs, {
                type = "operate-entity-surface",
                name = compound_key({generator.name, surface_key})
            })
        end

        for _, generator in pairs(get_prototypes("generator")) do
            table.insert(prereqs, {
                type = "operate-entity-surface",
                name = compound_key({generator.name, surface_key})
            })
        end

        -- Check lightning
        -- TODO: Check lightning existence more explicitly, right now, it just checks that the lightning properties is non-nil
        if surface.type == "planet" and surface.prototype.lightning_properties ~= nil then
            for _, attractor in pairs(get_prototypes("lightning-attractor")) do
                if attractor ~= nil and attractor.efficiency > 0 then
                    table.insert(prereqs, {
                        type = "operate-entity-surface",
                        name = compound_key({attractor.name, surface_key})
                    })
                end
            end
        end

        for _, solar_panel in pairs(get_prototypes("solar-panel")) do
            table.insert(prereqs, {
                type = "operate-entity-surface",
                name = compound_key({solar_panel.name, surface_key})
            })
        end

        for _, generator in pairs(get_prototypes("fusion-generator")) do
            table.insert(prereqs, {
                type = "operate-entity-surface",
                name = compound_key({generator.name, surface_key})
            })
        end

        add_to_graph("electricity-production-surface", surface_key, prereqs, {
            surface = surface_key
        })
    end

    -- electricity-surface
    log("Adding: electricity-surface")
    -- Do we have all we need to distribute electricity on this surface?

    for surface_key, surface in pairs(surfaces) do
        prereqs = {}

        table.insert(prereqs, {
            type = "electricity-distribution-surface",
            name = surface_key
        })
        table.insert(prereqs, {
            type = "electricity-production-surface",
            name = surface_key
        })

        add_to_graph("electricity-surface", surface_key, prereqs, {
            surface = surface_key
        })
    end

    -- energy-source-surface
    log("Adding: energy-source-surface")
    -- Do we have all we need to supply this entity with this type of fuel on this surface?

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
        for _, entity in pairs(get_prototypes(entity_class)) do
            for surface_key, surface in pairs(surfaces) do
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
                                name = surface_key
                            })
                        elseif energy_source.type == "burner" then
                            -- TODO: Also check for burnt fuel results and a valid burnt result inventory
                            for _, fuel_category in pairs(energy_source.fuel_categories or {"chemical"}) do
                                table.insert(prereqs, {
                                    type = "fuel-category-surface",
                                    name = compound_key({fuel_category, surface_key})
                                })
                            end
                        elseif energy_source.type == "heat" then
                            table.insert(prereqs, {
                                type = "heat-surface",
                                name = surface_key
                            })
                        elseif energy_source.type == "fluid" then
                            if energy_source.fluid_box.filter ~= nil then
                                table.insert(prereqs, {
                                    type = "fluid-surface",
                                    name = compound_key({energy_source.fluid_box.filter, surface_key})
                                })
                            else
                                for _, fluid in pairs(get_prototypes("fluid")) do
                                    if fluid.fuel_value ~= nil then
                                        table.insert(prereqs, {
                                            type = "fluid-surface",
                                            name = compound_key({fluid.name, surface_key})
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

                    add_to_graph("energy-source-surface", compound_key({entity.name, property, surface_key}), prereqs, {
                        surface = surface_key
                    })
                end
            end
        end
    end

    -- entity-buildability
    log("Adding: entity-buildability")
    -- Could this entity be built somewhere?
    -- Mostly needed for technical reasons for the randomizer

    for _, build_property in pairs(buildable_entity_keys) do
        for _, entity in pairs(buildable_entities[build_property]) do
            prereqs = {}

            for surface_name, surface in pairs(surfaces) do
                table.insert(prereqs, {
                    type = "entity-buildability-surface",
                    name = compound_key({entity.name, surface_name})
                })
            end

            add_to_graph("entity-buildability", entity.name, prereqs)
        end
    end

    -- entity-buildability-surface
    log("Adding: entity-buildability-surface")
    -- For optimization purposes, this only "checks" entities that appear buildable
    -- Would this entity be allowed to be built on this surface?

    for _, build_property in pairs(buildable_entity_keys) do
        for _, entity in pairs(buildable_entities[build_property]) do
            for surface_key, surface in pairs(surfaces) do
                prereqs = {}
    
                -- Assume default collision mask means it can be placed
                if entity.collision_mask == nil then
                    table.insert(prereqs, {
                        type = "entity-buildability-surface-true",
                        name = "canonical"
                    })
                else
                    for _, tile in pairs(get_prototypes("tile")) do
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
                                    name = compound_key({tile.name, surface_key})
                                })
                            end
                        end
                    end
                end
    
                add_to_graph("entity-buildability-surface", compound_key({entity.name, surface_key}), prereqs, {
                    surface = surface_key
                })
            end
        end
    end

    -- entity-buildability-surface-true
    log("Adding: entity-buildability-surface-true")
    -- Does an entity's absence of buildability constraints allow it to be built?

    prereqs = {}

    add_to_graph("entity-buildability-surface-true", "canonical", prereqs)

    -- entity-operation-items
    log("Adding: entity-operation-items")

    -- TODO

    -- fluid
    log("Adding: fluid")
    -- Is there a surface where we can supply this fluid?

    for _, fluid in pairs(get_prototypes("fluid")) do
        prereqs = {}

        for surface_key, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "fluid-surface",
                name = compound_key({fluid.name, surface_key})
            })
        end
        
        add_to_graph("fluid", fluid.name, prereqs, {
            fluid = fluid.name
        })
    end

    -- fluid-surface
    log("Adding: fluid-surface")
    -- Do we have all we need to supply this fluid on this surface?

    for _, fluid in pairs(get_prototypes("fluid")) do
        for surface_key, surface in pairs(surfaces) do
            prereqs = {}

            table.insert(prereqs, {
                type = "create-fluid-surface",
                name = compound_key({fluid.name, surface_key})
            })
            table.insert(prereqs, {
                type = "hold-fluid-surface",
                name = compound_key({fluid.name, surface_key})
            })

            add_to_graph("fluid-surface", compound_key({fluid.name, surface_key}), prereqs, {
                surface = surface_key,
                fluid = fluid.name
            })
        end
    end

    -- fuel-category
    log("Adding: fuel-category")
    -- Do we have access to this type of fuel somewhere?

    for _, fuel_category in pairs(get_prototypes("fuel-category")) do
        prereqs = {}

        for surface_key, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "fuel-category-surface",
                name = compound_key({fuel_category.name, surface_key})
            })
        end

        add_to_graph("fuel-category", fuel_category.name, prereqs)
    end

    -- fuel-category-burner
    log("Adding: fuel-category-burner")
    -- Do we have something that can use this type of fuel somewhere?

    for _, fuel_category in pairs(get_prototypes("fuel-category")) do
        prereqs = {}

        for surface_key, _ in pairs(surfaces) do
            table.insert(prereqs, {
                type = "fuel-category-burner-surface",
                name = compound_key({fuel_category.name, surface_key})
            })
        end

        add_to_graph("fuel-category-burner", fuel_category.name, prereqs)
    end

    -- fuel-category-burner-surface
    log("Adding: fuel-category-burner-surface")
    -- Do we have all we need to use this type of fuel somewhere?

    for _, fuel_category in pairs(get_prototypes("fuel-category")) do
        for surface_key, surface in pairs(surfaces) do
            prereqs = {}

            -- We don't care about the type of energy source here, so we can just search over all of them
            -- Valid energy source keys are exactly "energy_source" and "burner"
            for _, burner in pairs(mtm_lookup(fuel_category_to_burners, fuel_category.name)) do
                table.insert(prereqs, {
                    type = "operate-entity-surface",
                    name = compound_key({burner.name, surface_key})
                })
            end

            add_to_graph("fuel-category-burner-surface", compound_key({fuel_category.name, surface_key}), prereqs)
        end
    end

    -- fuel-category-surface
    log("Adding: fuel-category-surface")
    -- TODO: Add this to obsidian spec
    -- Do we have access to any items with this fuel category on this surface?

    for _, fuel_category in pairs(get_prototypes("fuel-category")) do
        for surface_key, surface in pairs(surfaces) do
            prereqs = {}

            for _, fuel in pairs(mtm_lookup(fuel_category_to_fuels, fuel_category.name)) do
                table.insert(prereqs, {
                    type = "item-surface",
                    name = compound_key({fuel.name, surface_key})
                })
            end

            add_to_graph("fuel-category-surface", compound_key({fuel_category.name, surface_key}), prereqs)
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
    -- Do we have all we need to use heat distribution entities on this surface?

    for surface_key, surface in pairs(surfaces) do
        prereqs = {}

        for _, heat_pipe in pairs(get_prototypes("heat-pipe")) do
            table.insert(prereqs, {
                type = "operate-entity-surface",
                name = compound_key({heat_pipe.name, surface_key})
            })
        end

        add_to_graph("heat-distribution-surface", surface_key, prereqs, {
            surface = surface_key
        })
    end

    -- heat-production-surface
    log("Adding: heat-production-surface")
    -- Do we have all we need to produce heat on this surface?

    local heat_producers = {
        ["reactor"] = true
    }

    for surface_key, surface in pairs(surfaces) do
        prereqs = {}

        for heat_producer_class, _ in pairs(heat_producers) do
            for _, entity in pairs(get_prototypes(heat_producer_class)) do
                table.insert(prereqs, {
                    type = "operate-entity-surface",
                    name = compound_key({entity.name, surface_key})
                })
            end
        end

        add_to_graph("heat-production-surface", surface_key, prereqs, {
            surface = surface_key
        })
    end

    -- heat-surface
    log("Adding: heat-surface")
    -- Do we have all we need to distribute heat on this surface?

    for surface_key, surface in pairs(surfaces) do
        prereqs = {}

        table.insert(prereqs, {
            type = "heat-production-surface",
            name = surface_key
        })
        table.insert(prereqs, {
            type = "heat-distribution-surface",
            name = surface_key
        })

        add_to_graph("heat-surface", surface_key, prereqs, {
            surface = surface_key
        })
    end

    -- hold-fluid-surface
    log("Adding: hold-fluid-surface")
    -- Do we have all we need to transport fluid on this surface?

    for _, fluid in pairs(get_prototypes("fluid")) do
        for surface_key, surface in pairs(surfaces) do
            prereqs = {}

            -- Just check pipes now
            -- TODO: Check fluid "holding" in more creative ways
            -- TODO: Also check logistics, like underground pipes
            for _, pipe in pairs(get_prototypes("pipe")) do
                if pipe.fluid_box.filter == nil or pipe.fluid_box.filter == fluid.name then
                    table.insert(prereqs, {
                        type = "operate-entity-surface",
                        name = compound_key({pipe.name, surface_key})
                    })
                end
            end

            add_to_graph("hold-fluid-surface", compound_key({fluid.name, surface_key}), prereqs, {
                surface = surface_key,
                fluid = fluid
            })
        end
    end

    -- item
    log("Adding: item")
    -- Do we have access to this item somewhere?

    for _, item in pairs(items) do
        prereqs = {}

        for surface_key, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "item-surface",
                name = compound_key({item.name, surface_key})
            })
        end

        add_to_graph("item", item.name, prereqs, {
            item = item.name
        })
    end

    -- item-space-surface
    log("Adding: item-space-surface")
    -- Do we have access to this item on a space platform?

    for _, item in pairs(items) do
        prereqs = {}

        for surface_key, surface in pairs(surfaces) do
            if surface.type == "space-surface" then
                table.insert(prereqs, {
                    type = "item-surface",
                    name = compound_key({item.name, surface_key})
                })
            end
        end

        add_to_graph("item-space-surface", item.name, prereqs, {
            item = item.name
        })
    end

    -- item-surface
    log("Adding: item-surface")
    -- Do we have access to this item on this surface?

    for _, item in pairs(items) do
        for surface_key, surface in pairs(surfaces) do
            prereqs = {}

            table.insert(prereqs, {
                type = "craft-material-surface",
                name = compound_key({"item-" .. item.name, surface_key})
            })

            for _, entity in pairs(mtm_lookup(mining_result_item_to_entities, item.name)) do
                table.insert(prereqs, {
                    type = "mine-entity-surface",
                    name = compound_key({entity.name, surface_key})
                })
            end

            for _, tile in pairs(mtm_lookup(mining_result_to_tiles, item.name)) do
                table.insert(prereqs, {
                    type = "mine-tile-surface",
                    name = compound_key({tile.name, surface_key})
                })
            end

            if surface.type == "space-surface" then
                for _, asteroid_chunk in pairs(get_prototypes("asteroid-chunk")) do
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

                table.insert(prereqs, {
                    type = "send-item-to-orbit",
                    name = item.name
                })
            end

            for _, entity in pairs(mtm_lookup(loot_to_entities, item.name)) do
                table.insert(prereqs, {
                    type = "loot-entity-surface",
                    name = compound_key({entity.name, surface_key})
                })
            end

            for _, item_2 in pairs(mtm_lookup(spoil_result_to_items, item.name)) do
                table.insert(prereqs, {
                    type = "item-surface",
                    name = compound_key({item_2.name, surface_key})
                })
            end

            for _, item_2 in pairs(mtm_lookup(burnt_result_to_fuels, item.name)) do
                table.insert(prereqs, {
                    type = "burn-item-surface",
                    name = compound_key({item_2.name, surface_key})
                })
            end

            if surface.type == "planet" then
                for _, item_2 in pairs(mtm_lookup(rocket_launch_product_to_items, item.name)) do
                    table.insert(prereqs, {
                        type = "send-item-to-orbit-planet",
                        name = compound_key({item_2.name, surface.name})
                    })
                end

                table.insert(prereqs, {
                    type = "transport-item-to-planet",
                    name = compound_key({item.name, surface.name}),
                    add_caveat = {
                        ["transported"] = true
                    }
                })
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

            add_to_graph("item-surface", compound_key({item.name, surface_key}), prereqs, {
                item = item.name,
                surface = surface_key
            })
        end
    end

    -- loot-entity
    log("Adding: loot-entity")
    -- Do we have all we need to get loot from this entity somewhere?

    for _, entity in pairs(build_graph.prototypes.entities) do
        if entity.loot ~= nil then
            prereqs = {}

            for surface_key, surface in pairs(surfaces) do
                table.insert(prereqs, {
                    type = "loot-entity-surface",
                    name = compound_key({entity.name, surface_key})
                })
            end

            add_to_graph("loot-entity", entity.name, prereqs)
        end
    end

    -- loot-entity-surface
    log("Adding: loot-entity-surface")
    -- Do we have all we need to get loot from this entity on this surface?

    for _, entity in pairs(build_graph.prototypes.entities) do
        if entity.loot ~= nil then
            for surface_key, surface in pairs(surfaces) do
                prereqs = {}

                table.insert(prereqs, {
                    type = "spawn-entity-surface",
                    name = compound_key({entity.name, surface_key})
                })
                -- TODO: damage-type-amount-surface
                -- Assuming you can damage things for now

                add_to_graph("loot-entity-surface", compound_key({entity.name, surface_key}), prereqs, {
                    surface = surface_key
                })
            end
        end
    end

    -- mine-asteroid-chunk
    log("Adding: mine-asteroid-chunk")
    -- Only implemented for space surfaces
    -- Do we have all we need to collect asteroids somewhere?

    for _, asteroid_chunk in pairs(get_prototypes("asteroid-chunk")) do
        prereqs = {}

        for _, surface in pairs(get_prototypes("surface")) do
            table.insert(prereqs, {
                type = "mine-asteroid-chunk-surface",
                name = compound_key({asteroid_chunk.name, surface.name})
            })
        end

        add_to_graph("mine-asteroid-chunk", asteroid_chunk.name, prereqs)
    end

    -- mine-asteroid-chunk-surface
    log("Adding: mine-asteroid-chunk-surface")
    -- Only implemented for space surfaces
    -- Do we have all we need to collect asteroids on this surface?

    for _, asteroid_chunk in pairs(get_prototypes("asteroid-chunk")) do
        for _, surface in pairs(get_prototypes("surface")) do
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

    -- mine-entity
    log("Adding: mine-entity")
    -- Do we have all we need to mine this entity somewhere?

    for _, entity in pairs(build_graph.prototypes.entities) do
        if entity.minable ~= nil then
            prereqs = {}

            for surface_key, surface in pairs(surfaces) do
                table.insert(prereqs, {
                    type = "mine-entity-surface",
                    name = compound_key({entity.name, surface_key})
                })
            end

            add_to_graph("mine-entity", entity.name, prereqs)
        end
    end

    -- mine-entity-surface
    log("Adding: mine-entity-surface")
    -- Do we have all we need to mine this entity on this surface?

    for _, entity in pairs(build_graph.prototypes.entities) do
        if entity.minable ~= nil then
            for surface_key, surface in pairs(surfaces) do
                prereqs = {}

                table.insert(prereqs, {
                    type = "spawn-entity-surface",
                    name = compound_key({entity.name, surface_key})
                })

                if entity.minable.required_fluid ~= nil then
                    table.insert(prereqs, {
                        type = "fluid-surface",
                        name = compound_key({entity.minable.required_fluid, surface_key})
                    })

                    table.insert(prereqs, {
                        type = "mining-with-fluid-unlock",
                        name = "canonical"
                    })
                end

                if entity.type == "resource" then
                    table.insert(prereqs, {
                        type = "resource-category-surface",
                        name = compound_key({resource_to_spoofed_category_name(entity), surface_key})
                    })
                end

                add_to_graph("mine-entity-surface", compound_key({entity.name, surface_key}), prereqs, {
                    surface = surface_key
                })
            end
        end
    end

    -- mine-tile
    log("Adding: mine-tile")
    -- Do we have all we need to mine this tile somewhere?

    for _, tile in pairs(get_prototypes("tile")) do
        -- Only minable tiles
        if tile.minable ~= nil then
            prereqs = {}

            for surface_key, surface in pairs(surfaces) do
                table.insert(prereqs, {
                    type = "mine-tile-surface",
                    name = compound_key({tile.name, surface_key})
                })
            end

            add_to_graph("mine-tile", tile.name, prereqs)
        end
    end

    -- mine-tile-surface
    log("Adding: mine-tile-surface")
    -- Do we have all we need to mine this tile on this surface?

    for _, tile in pairs(get_prototypes("tile")) do
        for surface_key, surface in pairs(surfaces) do
            if tile.minable ~= nil then
                prereqs = {}

                table.insert(prereqs, {
                    type = "spawn-tile-surface",
                    name = compound_key({tile.name, surface_key})
                })

                add_to_graph("mine-tile-surface", compound_key({tile.name, surface_key}), prereqs, {
                    surface = surface_key
                })
            end
        end
    end

    -- mining-with-fluid-unlock
    log("Adding: mining-with-fluid-unlock")
    -- Have we unlocked mining with fluids?

    prereqs = {}

    for _, technology in pairs(get_prototypes("technology")) do
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
    -- Do we have all we need to operate this entity somewhere?

    for _, entity in pairs(build_graph.prototypes.entities) do
        prereqs = {}

        for surface_key, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "operate-entity-surface",
                name = compound_key({entity.name, surface_key})
            })
        end

        add_to_graph("operate-entity", entity.name, prereqs)
    end

    -- operate-entity-surface
    log("Adding: operate-entity-surface")
    -- Do we have all we need to operate this entity on this surface?

    local ammo_required_for_operation = {
        ["ammo-turret"] = true,
        ["artillery-turret"] = true,
    }
    local fluid_required_for_operation = {
        ["boiler"] = true,
        ["fusion-generator"] = true,
        ["fusion-reactor"] = true,
        ["generator"] = true,
        ["fluid-turret"] = true,
    }

    for _, entity in pairs(build_graph.prototypes.entities) do
        for surface_key, surface in pairs(surfaces) do
            prereqs = {}

            -- This is used later for the aquilo heating prerequisite
            local doesnt_freeze = false
            local property_list = operation_energy_sources[entity.type]
            if type(property_list) ~= "table" then
                property_list = {property_list}
            end
            for _, property in pairs(property_list) do
                table.insert(prereqs, {
                    type = "energy-source-surface",
                    name = compound_key({entity.name, property, surface_key})
                })

                -- I would check that the heat energy source is a production source, not a powered source, but being heat powered leads to the same requirements anyways
                if entity[property] ~= nil and (entity[property].type == "burner" or entity[property].type == "heat") then
                    doesnt_freeze = true
                end
            end

            table.insert(prereqs, {
                type = "spawn-entity-surface",
                name = compound_key({entity.name, surface_key})
            })

            if fluid_required_for_operation[entity.type] then
                table.insert(prereqs, {
                    type = "operate-entity-surface-fluid",
                    name = compound_key({entity.name, surface_key})
                })
            end

            -- Thruster oxidizer/fuel
            if entity.type == "thruster" then
                table.insert(prereqs, {
                    type = "fluid-surface",
                    name = compound_key({entity.fuel_fluid_box.filter, surface_key})
                })
                table.insert(prereqs, {
                    type = "fluid-surface",
                    name = compound_key({entity.oxidizer_fluid_box.filter, surface_key})
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
                        name = surface_key
                    })
                end
            end

            if ammo_required_for_operation[entity.type] then
                table.insert(prereqs, {
                    type = "operate-entity-surface-ammo",
                    name = compound_key({entity.name, surface_key})
                })
            end

            -- TODO: entity-operation-items, like PyAL modules

            add_to_graph("operate-entity-surface", compound_key({entity.name, surface_key}), prereqs, {
                surface = surface_key
            })
        end
    end

    -- operate-entity-surface-ammo
    log("Adding: operate-entity-surface-ammo")
    -- Do we have all we need to supply this entity with its required ammo on this surface?

    for _, entity in pairs(build_graph.prototypes.entities) do
        if ammo_required_for_operation[entity.type] then
            for surface_key, surface in pairs(surfaces) do
                prereqs = {}

                if entity.type == "ammo-turret" then
                    for _, ammo_category in pairs(get_ammo_categories(entity.attack_parameters)) do
                        table.insert(prereqs, {
                            type = "ammo-category-surface",
                            name = compound_key({ammo_category, surface_key})
                        })
                    end
                elseif entity.type == "artillery-turret" then
                    local gun = get_prototypes("gun")[entity.gun]
                    for _, ammo_category in pairs(get_ammo_categories(gun.attack_parameters)) do
                        table.insert(prereqs, {
                            type = "ammo-category-surface",
                            name = compound_key({ammo_category, surface_key})
                        })
                    end
                end

                add_to_graph("operate-entity-surface-ammo", compound_key({entity.name, surface_key}), prereqs, {
                    surface = surface_key
                })
            end
        end
    end

    -- operate-entity-surface-fluid
    log("Adding: operate-entity-surface-fluid")
    -- Do we have all we need to supply this entity with its required fluid on this surface?

    for _, entity in pairs(build_graph.prototypes.entities) do
        if fluid_required_for_operation[entity.type] then
            for surface_key, surface in pairs(surfaces) do
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
                        name = compound_key({entity.fluid_box.filter, surface_key})
                    })
                end
                if entity.type == "fusion-generator" then
                    table.insert(prereqs, {
                        type = "fluid-surface",
                        name = compound_key({entity.input_fluid_box.filter, surface_key})
                    })
                end
                if entity.type == "fusion-reactor" then
                    table.insert(prereqs, {
                        type = "fluid-surface",
                        name = compound_key({entity.input_fluid_box.filter, surface_key})
                    })
                end
                if entity.type == "generator" then
                    if entity.fluid_box.filter ~= nil then
                        table.insert(prereqs, {
                            type = "fluid-surface",
                            name = compound_key({entity.fluid_box.filter, surface_key})
                        })
                    else
                        if not burns_fluid then
                            -- TODO: Requires access to certain temperatures
                            -- TODO: Implement temperatures
                        else
                            for _, fluid in pairs(get_prototypes("fluid")) do
                                if fluid.fuel_value ~= nil then
                                    table.insert(prereqs, {
                                        type = "fluid-surface",
                                        name = compound_key({fluid.name, surface_key})
                                    })
                                end
                            end
                        end
                    end
                end
                if entity.type == "fluid-turret" then
                    if entity.attack_parameters.fluids ~= nil then
                        for _, stream_fluid_property in pairs(entity.attack_parameters.fluids) do
                            table.insert(prereqs, {
                                type = "fluid-surface",
                                name = compound_key({stream_fluid_property.type, surface_key})
                            })
                        end
                    end
                end

                add_to_graph("operate-entity-surface-fluid", compound_key({entity.name, surface_key}), prereqs, {
                    surface = surface_key
                })
            end
        end
    end

    -- planet
    log("Adding: planet")
    -- Do we have access to the surface of this planet?

    for _, planet in pairs(get_prototypes("planet")) do
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
    -- Can we send stuff into orbit from this planet?

    for _, planet in pairs(get_prototypes("planet")) do
        prereqs = {}

        for _, surface in pairs(get_prototypes("surface")) do
            table.insert(prereqs, {
                type = "send-surface-starter-pack-planet",
                name = compound_key({surface.name, planet.name})
            })
        end

        add_to_graph("planet-launch", planet.name, prereqs)
    end

    -- plant-entity-item-surface
    log("Adding: plant-entity-item-surface")
    -- Does an item we have on this surface that plants into this entity?

    for _, entity in pairs(buildable_entities[plant_result_key]) do
        for surface_key, _ in pairs(surfaces) do
            prereqs = {}

            for _, item in pairs(mtm_lookup(buildable_entity_to_items, entity.name)) do
                if item.plant_result == entity.name then
                    table.insert(prereqs, {
                        type = "item-surface",
                        name = compound_key({item.name, surface_key}),
                        remove_caveat = {
                            ["transported"] = true
                        }
                    })
                end
            end

            add_to_graph("plant-entity-item-surface", compound_key({entity.name, surface_key}), prereqs)
        end
    end

    -- plant-entity-surface
    log("Adding: plant-entity-surface")
    -- Do we have all we need to plant this entity on this surface?

    for _, entity in pairs(buildable_entities[plant_result_key]) do
        for surface_key, surface in pairs(surfaces) do
            prereqs = {}

            table.insert(prereqs, {
                type = "entity-buildability-surface",
                name = compound_key({entity.name, surface_key})
            })
            table.insert(prereqs, {
                type = "plant-entity-item-surface",
                name = compound_key({entity.name, surface_key})
            })
            table.insert(prereqs, {
                type = "surface",
                name = surface_key
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

            add_to_graph("plant-entity-surface", compound_key({entity.name, surface_key}), prereqs, {
                surface = surface_key
            })
        end
    end

    -- plant-entity-surface-automatability
    log("Adding: plant-entity-surface-automatability")
    -- Do we have all we need to automate planting this entity on this surface?

    for _, entity in pairs(buildable_entities[plant_result_key]) do
        for surface_key, surface in pairs(surfaces) do
            -- Technically the machine that harvests the plants may be only placeable in a different location from where the plants can be made
            -- This is probably never an issue, though, and would be nearly impossible to solve anyways
            prereqs = {}

            table.insert(prereqs, {
                type = "plant-entity-surface",
                name = compound_key({entity.name, surface_key})
            })
            table.insert(prereqs, {
                type = "agricultural-tower-surface",
                name = surface_key
            })

            add_to_graph("plant-entity-surface-automatability", compound_key({entity.name, surface_key}), prereqs, {
                surface = surface_key
            })
        end
    end

    -- plant-entity-surface-condition-false
    log("Adding: plant-entity-surface-condition-false")
    -- Does an entity's surface conditions allow it to be planted on a surface that does not satisfy them?

    prereqs = {}

    add_to_graph("plant-entity-surface-condition-false", "canonical", prereqs)

    -- plant-entity-surface-condition-true
    log("Adding: plant-entity-surface-condition-true")
    -- Does an entity's surface conditions allow it to be planted on a surface that satisfies them?

    prereqs = {}

    add_to_graph("plant-entity-surface-condition-true", "canonical", prereqs)

    -- recipe
    log("Adding: recipe")
    -- Do we have all we need to use this recipe somewhere?

    for _, recipe in pairs(get_prototypes("recipe")) do
        prereqs = {}

        for surface_key, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "recipe-surface",
                name = compound_key({recipe.name, surface_key})
            })
        end

        add_to_graph("recipe", recipe.name, prereqs, {
            recipe = recipe.name,
        })
    end

    -- recipe-category
    log("Adding: recipe-category")
    -- Would we be able to use recipes of this category somewhere?

    for spoofed_category_name, spoofed_category in pairs(build_graph.spoofed_recipe_categories) do
        prereqs = {}

        for surface_key, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "recipe-category-surface",
                name = compound_key({spoofed_category_name, surface_key})
            })
        end

        add_to_graph("recipe-category", spoofed_category_name, prereqs)
    end

    -- recipe-category-surface
    log("Adding: recipe-category-surface")
    -- Would we be able to use recipes of this category on this surface?

    for spoofed_category_name, spoofed_category in pairs(build_graph.spoofed_recipe_categories) do
        for surface_key, surface in pairs(surfaces) do
            prereqs = {}

            table.insert(prereqs, {
                type = "recipe-category-surface-automation",
                name = compound_key({spoofed_category_name, surface_key})
            })
            if surface.type == "planet" then
                if spoofed_category.input_fluids == 0 and spoofed_category.output_fluids == 0 then
                    for _, character in pairs(get_prototypes("character")) do
                        if character.crafting_categories ~= nil then
                            local has_crafting_category = false
    
                            for _, category in pairs(character.crafting_categories) do
                                if category == spoofed_category.recipe_category.name then
                                    has_crafting_category = true
                                end
                            end
    
                            if has_crafting_category then
                                table.insert(prereqs, {
                                    type = "surface",
                                    name = surface_key
                                })
                            end
                        end
                    end
                end
            end

            add_to_graph("recipe-category-surface", compound_key({spoofed_category_name, surface_key}), prereqs, {
                surface = surface_key
            })
        end
    end

    -- recipe-category-surface-automation
    log("Adding: recipe-category-surface-automation")
    -- Would we be able to automate recipes of this category on this surface?

    for spoofed_category_name, spooofed_category in pairs(build_graph.spoofed_recipe_categories) do
        for surface_key, surface in pairs(surfaces) do
            prereqs = {}

            for crafting_machine_class, _ in pairs(crafting_machine_classes) do
                for _, crafting_machine in pairs(get_prototypes(crafting_machine_class)) do
                    if is_crafting_machine_compatible_with_recipe_category(crafting_machine, spooofed_category) then
                        table.insert(prereqs, {
                            type = "operate-entity-surface",
                            name = compound_key({crafting_machine.name, surface_key})
                        })
                    end
                end
            end

            add_to_graph("recipe-category-surface-automation", compound_key({spoofed_category_name, surface_key}), prereqs, {
                surface = surface_key
            })
        end
    end

    -- recipe-surface
    log("Adding: recipe-surface")
    -- Do we have all we need to use this recipe on this surface?

    for _, recipe in pairs(get_prototypes("recipe")) do
        for surface_key, surface in pairs(surfaces) do
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
                            name = compound_key({ing.name, surface_key})
                        })
                    elseif ing.type == "fluid" then
                        num_input_fluids = num_input_fluids + 1
                        table.insert(prereqs, {
                            ing = ing,
                            is_ingredient = true,
                            type = "fluid-surface",
                            name = compound_key({ing.name, surface_key})
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
                name = compound_key({spoofed_category_name, surface_key})
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
                    type = "recipe-surface-condition-true",
                    name = "canonical"
                })
            else
                table.insert(prereqs, {
                    type = "recipe-surface-condition-false",
                    name = "canonical"
                })
            end

            -- Add the actual surface
            table.insert(prereqs, {
                type = "surface",
                name = surface_key
            })

            add_to_graph("recipe-surface", compound_key({recipe.name, surface_key}), prereqs, {
                recipe = recipe.name,
                surface = surface_key
            })
        end
    end

    -- recipe-surface-condition-false
    log("Adding: recipe-surface-condition-false")
    -- Does an recipe's surface conditions allow it to be used on a surface that does not satisfy them?

    prereqs = {}

    add_to_graph("recipe-surface-condition-false", "canonical", prereqs)

    -- recipe-surface-condition-true
    log("Adding: recipe-surface-condition-true")
    -- Does an recipe's surface conditions allow it to be used on a surface that satisfies them?

    prereqs = {}

    add_to_graph("recipe-surface-condition-true", "canonical", prereqs)

    -- recipe-tech-unlock
    log("Adding: recipe-tech-unlock")
    -- Have we unlocked this recipe?

    for _, recipe in pairs(get_prototypes("recipe")) do
        prereqs = {}

        for _, tech in pairs(mtm_lookup(recipe_to_technology, recipe.name)) do
            table.insert(prereqs, {
                type = "technology",
                name = tech.name
            })
        end

        add_to_graph("recipe-tech-unlock", recipe.name, prereqs)
    end

    -- research-science-pack-set
    log("Adding: research-science-pack-set")
    -- Do we have all we need to research with this set of science packs somewhere?

    for science_pack_set_name, science_pack_set in pairs(science_pack_sets) do
        prereqs = {}

        for surface_key, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "research-science-pack-set-surface",
                name = compound_key({science_pack_set_name, surface_key}),
            })
        end

        add_to_graph("research-science-pack-set", science_pack_set_name, prereqs)
    end

    -- research-science-pack-set-surface
    log("Adding: research-science-pack-set-surface")
    -- Do we have all we need to research with this set of science packs on this surface?

    for science_pack_set_name, science_pack_set in pairs(science_pack_sets) do
        for surface_key, surface in pairs(surfaces) do
            prereqs = {}

            table.insert(prereqs, {
                type = "science-pack-set-surface",
                name = compound_key({science_pack_set_name, surface_key}),
            })

            for _, item_name in pairs(science_pack_set) do
                table.insert(prereqs, {
                    type = "item-surface",
                    name = compound_key({item_name, surface_key}),
                })
            end

            add_to_graph("research-science-pack-set-surface", compound_key({science_pack_set_name, surface_key}), prereqs)
        end
    end

    -- resource-category
    log("Adding: resource-category")
    -- Would we be able to mine resources of this category somewhere?

    for spoofed_category_name, spoofed_category in pairs(build_graph.spoofed_resource_categories) do
        prereqs = {}

        for surface_key, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "resource-category-surface",
                name = compound_key({spoofed_category_name, surface_key})
            })
        end

        add_to_graph("resource-category", spoofed_category_name, prereqs)
    end

    -- resource-category-surface
    log("Adding: resource-category-surface")
    -- Would we be able to mine resources of this category on this surface?

    -- TODO: Also split into automated and non-automated version
    for spoofed_category_name, spoofed_category in pairs(build_graph.spoofed_resource_categories) do
        for surface_key, surface in pairs(surfaces) do
            prereqs = {}

            for _, character in pairs(get_prototypes("character")) do
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

            for _, mining_drill in pairs(get_prototypes("mining-drill")) do
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
                        name = compound_key({mining_drill.name, surface_key})
                    })
                end
            end

            add_to_graph("resource-category-surface", compound_key({spoofed_category_name, surface_key}), prereqs, {
                surface = surface_key
            })
        end
    end

    -- rocket-launch-planet
    log("Adding: rocket-launch-planet")
    -- Do we have all we need to craft anything with a rocket silo on this planet?

    for _, planet in pairs(get_prototypes("planet")) do
        prereqs = {}

        for _, silo in pairs(get_prototypes("rocket-silo")) do
            for _, recipe in pairs(mtm_lookup(crafting_machine_to_recipes, silo.name)) do
                table.insert(prereqs, {
                    type = "rocket-part-recipe-planet",
                    name = compound_key({silo.name, recipe.name, planet.name})
                })
            end
        end

        add_to_graph("rocket-launch-planet", planet.name, prereqs)
    end

    -- rocket-part-recipe-planet
    log("Adding: rocket-part-recipe-planet")
    -- Do we have all we need to use this recipe in this rocket silo on this planet?

    for _, silo in pairs(get_prototypes("rocket-silo")) do
        for _, recipe in pairs(mtm_lookup(crafting_machine_to_recipes, silo.name)) do
            for _, planet in pairs(get_prototypes("planet")) do
                prereqs = {}

                local surface_key = compound_key({"planet", planet.name})
                table.insert(prereqs, {
                    type = "operate-entity-surface",
                    name = compound_key({silo.name, surface_key})
                })
                table.insert(prereqs, {
                    type = "recipe-surface",
                    name = compound_key({recipe.name, surface_key})
                })

                add_to_graph("rocket-part-recipe-planet", compound_key({silo.name, recipe.name, planet.name}), prereqs)
            end
        end
    end

    -- science-pack-set-surface
    log("Adding: science-pack-set-surface")
    -- Would we be able to research with this set of science packs on this surface?

    for science_pack_set_name, science_pack_set in pairs(science_pack_sets) do
        for surface_key, surface in pairs(surfaces) do
            prereqs = {}

            for _, lab in pairs(get_prototypes("lab")) do
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
                        type = "operate-entity-surface",
                        name = compound_key({lab.name, surface_key})
                    })
                end
            end

            add_to_graph("science-pack-set-surface", compound_key({science_pack_set_name, surface_key}), prereqs)
        end
    end

    -- send-heavy-item-to-orbit
    log("Adding: send-heavy-item-to-orbit")
    -- Does an item being heavier than the rocket capacity allow us to export it to space platforms?

    prereqs = {}

    add_to_graph("send-heavy-item-to-orbit", "canonical", prereqs)

    -- send-item-to-orbit
    log("Adding: send-item-to-orbit")
    -- Do we have all we need to set up a planet somewhere for export of this item to space platforms?

    for _, item in pairs(items) do
        prereqs = {}

        for _, planet in pairs(get_prototypes("planet")) do
            table.insert(prereqs, {
                type = "send-item-to-orbit-planet",
                name = compound_key({item.name, planet.name})
            })
        end

        add_to_graph("send-item-to-orbit", item.name, prereqs)
    end

    -- send-item-to-orbit-planet
    log("Adding: send-item-to-orbit-planet")
    -- Do we have all we need to set up this planet for exporting this item to space platforms?

    for _, item in pairs(items) do
        for _, planet in pairs(get_prototypes("planet")) do
            prereqs = {}

            table.insert(prereqs, {
                type = "rocket-launch-planet",
                name = planet.name
            })
            table.insert(prereqs, {
                type = "item-surface",
                name = compound_key({item.name, compound_key({"planet", planet.name})}),
                add_caveat = {
                    ["transported"] = true
                }
            })
            table.insert(prereqs, {
                type = "planet",
                name = planet.name
            })
            -- TODO: Calculate weight if it's nil
            if item.weight ~= nil and item.weight > get_prototypes("utility-constants").default.rocket_lift_weight then
                table.insert(prereqs, {
                    type = "send-heavy-item-to-orbit",
                    name = "canonical"
                })
            end

            add_to_graph("send-item-to-orbit-planet", compound_key({item.name, planet.name}), prereqs)
        end
    end

    -- send-surface-starter-pack
    log("Adding: send-surface-starter-pack")
    -- Do we have all we need to send a space platform starter pack to this surface?

    -- Only for space surfaces
    for _, surface in pairs(get_prototypes("surface")) do
        prereqs = {}

        for _, planet in pairs(get_prototypes("planet")) do
            table.insert(prereqs, {
                type = "send-surface-starter-pack-planet",
                name = compound_key({surface.name, planet.name}),
            })
        end

        add_to_graph("send-surface-starter-pack", surface.name, prereqs)
    end

    -- send-surface-starter-pack-planet
    log("Adding: send-surface-starter-pack-planet")
    -- Do we have all we need to send a space platform starter pack from this planet to this surface?

    for _, surface in pairs(get_prototypes("surface")) do
        for _, planet in pairs(get_prototypes("planet")) do
            prereqs = {}

                for _, starter_pack in pairs(data.raw["space-platform-starter-pack"]) do
                    if starter_pack.surface == surface.name then
                        table.insert(prereqs, {
                            type = "send-item-to-orbit-planet",
                            name = compound_key({starter_pack.name, planet.name}),
                            remove_caveat = {
                                ["transported"] = true
                            }
                        })
                    end
                end

            add_to_graph("send-surface-starter-pack-planet", compound_key({surface.name, planet.name}), prereqs)
        end
    end

    -- space-connection
    log("Adding: space-connection")
    -- Do we have all we need to traverse this space connection?

    for _, space_connection in pairs(get_prototypes("space-connection")) do
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

    -- space-location
    log("Adding: space-location")
    -- Do we have all we need to access this space location?

    for space_location_class, _ in pairs(defines.prototypes["space-location"]) do
        for _, space_location in pairs(get_prototypes(space_location_class)) do
            prereqs = {}

            for _, space_connection in pairs(get_prototypes("space-connection")) do
                if space_connection.to == space_location.name then
                    table.insert(prereqs, {
                        type = "space-connection",
                        name = space_connection.name
                    })
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
    -- Have we unlocked this space location?

    for space_location_class, _ in pairs(defines.prototypes["space-location"]) do
        for _, space_location in pairs(get_prototypes(space_location_class)) do
            prereqs = {}

            for _, tech in pairs(get_prototypes("technology")) do
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
    -- Do we have all we need to access this space surface?

    for _, surface in pairs(get_prototypes("surface")) do
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

    -- spaceship
    log("Adding: spaceship")
    -- Do we have all we need to make space platform somewhere that can move?

    prereqs = {}

    for _, surface in pairs(get_prototypes("surface")) do
        table.insert(prereqs, {
            type = "spaceship-surface",
            name = surface.name
        })
    end

    add_to_graph("spaceship", "canonical", prereqs)

    -- spaceship-engine-surface
    log("Adding: spaceship-engine-surface")
    -- Do we have all we need to use a thruster on this surface?

    for _, surface in pairs(get_prototypes("surface")) do
        prereqs = {}

        for _, thruster in pairs(get_prototypes("thruster")) do
            table.insert(prereqs, {
                type = "operate-entity-surface",
                name = compound_key({thruster.name, compound_key({"space-surface", surface.name})})
            })
        end

        add_to_graph("spaceship-engine-surface", surface.name, prereqs)
    end

    -- spaceship-military-surface
    log("Adding: spaceship-military-surface")
    -- Do we have all we need to defend against asteroids on this space surface?

    local spaceship_military_classes = { "ammo-turret", "artillery-turret", "electric-turret", "fluid-turret", "land-mine" }

    for _, surface in pairs(get_prototypes("surface")) do
        prereqs = {}

        for _, defense_class in pairs(spaceship_military_classes) do
            for _, defense_entity in pairs(get_prototypes(defense_class)) do
                table.insert(prereqs, {
                    type = "operate-entity-surface",
                    name = compound_key({defense_entity.name, compound_key({"space-surface", surface.name})})
                })
            end
        end

        -- Combat robots?

        add_to_graph("spaceship-military-surface", surface.name, prereqs)
    end

    -- spaceship-surface
    log("Adding: spaceship-surface")
    -- Do we have all we need to make a space platform on this surface that can safely move across space connections?

    for _, surface in pairs(get_prototypes("surface")) do
        prereqs = {}

        table.insert(prereqs, {
            type = "spaceship-engine-surface",
            name = surface.name
        })
        table.insert(prereqs, {
            type = "space-surface",
            name = surface.name
        })
        table.insert(prereqs, {
            type = "spaceship-military-surface",
            name = surface.name
        })

        add_to_graph("spaceship-surface", surface.name, prereqs)
    end

    -- spawn-asteroid-chunk
    log("Adding: spawn-asteroid-chunk")
    -- Only implemented for space locations, for whether they have asteroids
    -- Do we have all we need to get to some place where this asteroid chunk spawns?

    for _, asteroid_chunk in pairs(get_prototypes("asteroid-chunk")) do
        prereqs = {}

        for space_location_class, _ in pairs(defines.prototypes["space-location"]) do
            for _, space_location in pairs(get_prototypes(space_location_class)) do
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

        add_to_graph("spawn-asteroid-chunk", asteroid_chunk.name, prereqs)
    end

    -- spawn-entity
    log("Adding: spawn-entity")
    -- Do we have all we need to spawn this entity somewhere?

    for _, entity in pairs(build_graph.prototypes.entities) do
        prereqs = {}

        for surface_key, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "spawn-entity-surface",
                name = compound_key({entity.name, surface_key})
            })
        end

        add_to_graph("spawn-entity", entity.name, prereqs)
    end

    -- spawn-entity-surface
    log("Adding: spawn-entity-surface")
    -- Do we have all we need to spawn this entity on this surface?

    for _, entity in pairs(build_graph.prototypes.entities) do
        for surface_key, surface in pairs(surfaces) do
            prereqs = {}

            if buildable_entities[place_result_key][entity.name] ~= nil then
                table.insert(prereqs, {
                    type = "build-entity-surface",
                    name = compound_key({entity.name, surface_key})
                })
            end
            if buildable_entities[plant_result_key][entity.name] ~= nil then
                table.insert(prereqs, {
                    type = "plant-entity-surface",
                    name = compound_key({entity.name, surface_key})
                })
            end

            if check_prototype_on_surface(surface, entity) then
                table.insert(prereqs, {
                    type = "surface",
                    name = surface_key
                })
            end

            for _, enemy_spawner in pairs(get_prototypes("unit-spawner")) do
                if enemy_spawner.captured_spawner_entity == entity.name then
                    table.insert(prereqs, {
                        type = "capture-spawner-surface",
                        name = compound_key({enemy_spawner.name, surface_key})
                    })
                end
            end

            if surface.type == "planet" then
                for _, capsule in pairs(mtm_lookup(entity_to_capsules, entity.name)) do
                    table.insert(prereqs, {
                        type = "capsule-surface",
                        name = compound_key({capsule.name, surface_key})
                    })
                end
            end

            for _, ammo in pairs(mtm_lookup(entity_to_ammos, entity.name)) do
                table.insert(prereqs, {
                    type = "item-surface",
                    name = compound_key({ammo.name, surface_key})
                })
            end

            -- Did not code the corpse connections yet
            -- TODO: Code in corpse connections
            -- TODO: Preserve pentapod egg mining from gleba enemies with item randomization when I do that!

            add_to_graph("spawn-entity-surface", compound_key({entity.name, surface_key}), prereqs, {
                surface = surface_key
            })
        end
    end

    -- spawn-rail-surface
    log("Adding: spawn-rail-surface")

    -- TODO

    -- spawn-tile
    log("Adding: spawn-tile")
    -- Does this tile spawn somewhere?
    -- Needed for technical reasons

    for _, tile in pairs(get_prototypes("tile")) do
        prereqs = {}

        for surface_name, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "spawn-tile-surface",
                name = build_graph.compound_key({tile.name, surface_name})
            })
        end

        add_to_graph("spawn-tile", tile.name, prereqs, {
            tile = tile.name
        })
    end

    -- spawn-tile-surface
    log("Adding: spawn-tile-surface")
    -- Do we have all we need to access this tile on this surface?

    for _, tile in pairs(get_prototypes("tile")) do
        for surface_key, surface in pairs(surfaces) do
            prereqs = {}

            if check_prototype_on_surface(surface, tile) then
                table.insert(prereqs, {
                    type = "surface",
                    name = surface_key
                })
            end

            -- If this is a space location and you can launch a starter pack somewhere, assume you can have those tiles at any space location
            -- TODO: Think past this assumption
            if surface.type == "space-surface" then
                for _, starter_pack in pairs(get_prototypes("space-platform-starter-pack")) do
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

            if buildable_tiles[tile.name] ~= nil then
                table.insert(prereqs, {
                    type = "build-tile-surface",
                    name = compound_key({tile.name, surface_key})
                })
            end

            add_to_graph("spawn-tile-surface", compound_key({tile.name, surface_key}), prereqs, {
                tile = tile.name,
                surface = surface_key
            })
        end
    end

    -- spawner-capturability
    log("Adding: spawner-capturability")
    -- Do we have all we need to capture a unit spawner somewhere?

    prereqs = {}

    for _, enemy_spawner in pairs(get_prototypes("unit-spawner")) do
        for surface_key, surface in pairs(surfaces) do
            table.insert(prereqs, {
                type = "capture-spawner-surface",
                name = compound_key({enemy_spawner.name, surface_key})
            })
        end
    end

    add_to_graph("spawner-capturability", "canonical", prereqs)

    -- starting-character
    log("Adding: starting-character")
    -- Does starting as character allow us to use it?

    prereqs = {}

    add_to_graph("starting-character", "canonical", prereqs)

    -- starting-planet
    log("Adding: starting-planet")
    -- Does starting on a planet allow us access to it?

    prereqs = {}

    add_to_graph("starting-planet", "canonical", prereqs)

    -- surface
    log("Adding: surface")
    -- Do we have all we need to access this surface?

    for surface_key, surface in pairs(surfaces) do
        prereqs = {}

        table.insert(prereqs, {
            type = surface.type,
            name = surface.prototype.name,
            remove_caveat = {
                ["transported"] = true
            }
        })

        add_to_graph("surface", surface_key, prereqs)
    end

    -- technology
    log("Adding: technology")
    -- Do we have all we need to unlock this technology?

    for _, tech in pairs(get_prototypes("technology")) do
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
            end
            table.sort(science_pack_set)
            table.insert(prereqs, {
                type = "research-science-pack-set",
                name = compound_key(science_pack_set),
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

    -- transport-item-to-planet
    log("Adding: transport-item-to-planet")
    -- Do we have all we need to import this item to this planet from a space platform?

    for _, item in pairs(items) do
        for _, planet in pairs(get_prototypes("planet")) do
            prereqs = {}
            local surface_key = compound_key({"planet", planet.name})

            table.insert(prereqs, {
                type = "surface",
                name = surface_key
            })

            table.insert(prereqs, {
                type = "item-space-surface",
                name = item.name,
                add_caveat = {
                    ["transported"] = true
                }
            })

            --[[ This would make pre-spaceship space platforms unable to send items from orbit.
            -- For now, assume access to this planet implies that you can transport items to it.
            table.insert(prereqs, {
                type = "spaceship",
                name = "canonical"
            })]]

            add_to_graph("transport-item-to-planet", compound_key({item.name, planet.name}), prereqs)
        end
    end

    -- valid-tile-placement-surface
    log("Adding: valid-tile-placement-surface")
    -- Do we have all we need to have a valid old tile where we can build this new tile on this surface?

    for _, tile in pairs(buildable_tiles) do
        for surface_key, surface in pairs(surfaces) do
            prereqs = {}

            -- Just check collision for now
            -- TODO: Check more general buildability rules
            -- TODO: Check if collision even prevents tiles from being put down? It replaces the tile anyways right?

            for _, tile_2 in pairs(get_prototypes("tile")) do
                if not collision_mask_util.masks_collide(tile.collision_mask, tile_2.collision_mask) then
                    table.insert(prereqs, {
                        type = "spawn-tile-surface",
                        name = compound_key({tile_2.name, surface_key})
                    })
                end
            end

            add_to_graph("valid-tile-placement-surface", compound_key({tile.name, surface_key}), prereqs, {
                surface = surface_key
            })
        end
    end

    -- void-energy
    log("Adding: void-energy")
    -- Does an entity' absence of a need for energy allow us to use it?

    prereqs = {}

    add_to_graph("void-energy", "canonical", prereqs)

    ----------------------------------------------------------------------
    -- Add surface-agnostic nodes for types that don't already have them
    ----------------------------------------------------------------------

    -- This is needed for technical reasons
    -- I already do this manually with a few node types above
    -- TODO: Refactor so I'm just using this for consistency
    local manual_types = table.deepcopy(build_graph.ops)
    local agnostics_added = {}
    for _, node in pairs(graph) do
        if string.sub(node.type, -8, -1) == "-surface" then
            local agnostic_type = string.sub(node.type, 1, -9)
            if manual_types[agnostic_type] == nil then
                if build_graph.ops[agnostic_type] == nil then
                    build_graph.ops[agnostic_type] = "OR"
                end
                -- Attempt to strip the surface name off the node
                -- This is imperfect and ugly and took me >20 tries to get right but it works now (hopefully)
                local i, _ = string.find(string.reverse(node.name), node_name_separator)
                local j
                if i ~= nil then
                    -- Need to do it again because surface names have separators
                    j, _ = string.find(string.sub(string.reverse(node.name), i+1, -1), node_name_separator)
                end
                local agnostic_name
                if i ~= nil and j ~= nil then
                    agnostic_name = string.sub(node.name, 1, -(i+j)-1)
                else
                    agnostic_name = "canonical"
                end
                local agnostic_key = key(agnostic_type, agnostic_name)
                if agnostics_added[agnostic_key] == nil then
                    agnostics_added[agnostic_key] = table.deepcopy(node)
                    agnostics_added[agnostic_key].type = agnostic_type
                    agnostics_added[agnostic_key].name = agnostic_name
                    agnostics_added[agnostic_key].surface = nil
                    agnostics_added[agnostic_key].prereqs = {}
                    graph[agnostic_key] = agnostics_added[agnostic_key]
                end
                table.insert(agnostics_added[agnostic_key].prereqs, {
                    type = node.type,
                    name = node.name
                })
            end
        end
    end

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
    ["ammo-category-surface"] = "OR",
    ["asteroid-collection-surface"] = "OR",
    ["build-entity"] = "OR",
    ["build-entity-item"] = "OR",
    ["build-entity-item-surface"] = "OR",
    ["build-entity-surface"] = "AND",
    ["build-entity-surface-condition-false"] = "OR",
    ["build-entity-surface-condition-true"] = "AND",
    ["build-tile"] = "OR",
    ["build-tile-item-surface"] = "OR",
    ["build-tile-item-surface-buildability"] = "OR",
    ["build-tile-item-surface-with-item"] = "AND",
    ["build-tile-surface"] = "AND",
    ["burn-item"] = "OR",
    ["burn-item-surface"] = "AND",
    ["capsule-surface"] = "AND",
    ["capture-robot"] = "OR",
    ["capture-spawner-surface"] = "AND",
    ["cargo-landing-pad-planet"] = "OR",
    ["character"] = "OR",
    ["completion"] = "AND", -- Used during simultaneous randomization to find nodes which are significant in some way at least
    ["craft-material"] = "OR",
    ["craft-material-surface"] = "OR",
    ["create-fluid"] = "OR",
    ["create-fluid-offshore-surface"] = "AND",
    ["create-fluid-surface"] = "OR",
    ["create-space-platform"] = "OR",
    ["create-space-platform-tech-unlock"] = "OR",
    ["damage-type-amount-surface"] = "OR",
    ["electricity-distribution-space-platfrom"] = "AND",
    ["electricity-distribution-surface"] = "OR",
    ["electricity-production-surface"] = "OR",
    ["electricity-surface"] = "AND",
    ["energy-source-surface"] = "OR",
    ["entity-buildability"] = "OR",
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
    ["item-slot"] = "OR", -- Used during item randomization; not constructed here
    ["item-space-surface"] = "OR",
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
    ["operate-entity-surface-ammo"] = "OR",
    ["operate-entity-surface-fluid"] = "OR",
    ["planet"] = "OR",
    ["planet-launch"] = "OR",
    ["plant-entity-item-surface"] = "OR",
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
    ["research-science-pack-set"] = "OR",
    ["research-science-pack-set-surface"] = "AND",
    ["resource-category"] = "OR",
    ["resource-category-surface"] = "OR",
    ["rocket-launch-planet"] = "OR",
    ["rocket-part-recipe-planet"] = "AND",
    ["science-pack-set-surface"] = "OR",
    ["send-heavy-item-to-orbit"] = "OR",
    ["send-item-to-orbit"] = "OR",
    ["send-item-to-orbit-planet"] = "AND",
    ["send-surface-starter-pack"] = "OR",
    ["send-surface-starter-pack-planet"] = "OR",
    ["slot"] = "OR", -- Used and constructed during simultaneous randomization
    ["slot-surface"] = "OR",
    ["space-connection"] = "AND",
    ["space-location"] = "OR",
    ["space-location-discovery"] = "OR",
    ["space-surface"] = "AND",
    ["spaceship"] = "OR",
    ["spaceship-engine-surface"] = "OR",
    ["spaceship-military-surface"] = "OR",
    ["spaceship-surface"] = "AND",
    ["spawn-asteroid-chunk"] = "OR",
    ["spawn-entity"] = "OR",
    ["spawn-entity-surface"] = "OR",
    ["spawn-rail-surface"] = "OR",
    ["spawn-tile"] = "OR",
    ["spawn-tile-surface"] = "OR",
    ["spawner-capturability"] = "OR",
    ["starting-character"] = "AND",
    ["starting-planet"] = "AND",
    ["surface"] = "OR",
    ["technology"] = "AND",
    ["thruster-surface"] = "AND",
    ["transport-item-to-planet"] = "AND",
    ["traveler"] = "OR", -- Used and constructed during simultaneous randomization
    ["traveler-surface"] = "OR",
    ["valid-tile-placement-surface"] = "OR",
    ["victory"] = "AND", -- Used during simultaneous randomization to find a shortest path through the game
    ["void-energy"] = "AND"
}

----------------------------------------------------------------------
-- Node metadata
----------------------------------------------------------------------

-- If checking if something is creatable "from just that surface", we really mean "can it be created from reachable non-isolatable nodes, and via non-transport connections across isolatable nodes"
-- This should represent "is this something that would need regular shipments to satisfy this ability if it was missing otherwise"
-- I think I may have been messing up the logic actually, this may not be necessary
-- CRITICAL TODO: REMOVE THIS?
build_graph.isolatable_nodes = {
    ["burn-item-surface"] = true,
    ["craft-material-surface"] = true,
    ["create-fluid-surface"] = true,
    ["fluid-surface"] = true,
    ["item-surface"] = true,
    ["planet-launch"] = true,
    ["recipe-surface"] = true,
    ["rocket-launch-planet"] = true,
    ["rocket-part-recipe-planet"] = true,
    ["send-item-to-orbit-planet"] = true,
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
    for key, op in pairs(build_graph.ops) do
        if op == "AND" then
            build_graph.ops[key] = "OR"
        elseif op == "OR" then
            build_graph.ops[key] = "AND"
        end
    end
end

----------------------------------------------------------------------
-- Dependents
----------------------------------------------------------------------

function build_graph.add_dependents(graph_param)
    log("Adding dependents")
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
                name = node.name,
                add_caveat = prereq.add_caveat,
                remove_caveat = prereq.remove_caveat
            })
        end
    end
end

load()

-- TODO: Function inspired by code that used to be here to determine complexity of graph for future optimization purposes if I go that route

return build_graph