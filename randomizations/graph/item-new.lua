local constants = require("helper-tables/constants")
local build_graph = require("lib/graph/build-graph")
local flow_cost = require("lib/graph/flow-cost")
local graph_utils = require("lib/graph/graph-utils")
local top_sort = require("lib/graph/top-sort")
local rng = require("lib/random/rng")

local dont_randomize_item = {
    ["rocket-part"] = true,
}

-- item lookup
local items = {}
for item_class, _ in pairs(defines.prototypes.item) do
    if data.raw[item_class] ~= nil then
        for _, item in pairs(data.raw[item_class]) do
            items[item.name] = item
        end
    end
end

randomizations.item_new = function(id)
    -- Special cost analysis for item randomization
    local modified_raw_resource_table = flow_cost.get_default_raw_resource_table()
    -- Consider fish/wood as expensive in a slot, but not when traveling
    modified_raw_resource_table["item-raw-fish"] = 1
    modified_raw_resource_table["item-wood"] = 1
    modified_raw_resource_table["item-spoilage"] = nil
    local cost_as_traveler = flow_cost.determine_recipe_item_cost(modified_raw_resource_table, constants.cost_params.time, constants.cost_params.complexity)
    modified_raw_resource_table["item-raw-fish"] = 25
    modified_raw_resource_table["item-wood"] = 5
    modified_raw_resource_table["item-spoilage"] = nil
    local cost_as_slot = flow_cost.determine_recipe_item_cost(modified_raw_resource_table, constants.cost_params.time, constants.cost_params.complexity)
    local item_recipe_maps = flow_cost.construct_item_recipe_maps()

    -- Pre-processing: Grab valid item nodes
    local initial_sort_info = top_sort.sort(dep_graph)

    local to_be_randomized = {}
    for _, node in pairs(initial_sort_info.sorted) do
        if node.type == "item" then
            local nauvis_reachable = initial_sort_info.reachable[build_graph.key("item-surface", build_graph.compound_key({node.name, build_graph.compound_key({"planet", "nauvis"})}))]
            if nauvis_reachable then
                local item_prototype = items[node.item]
                local cost = cost_as_traveler.material_to_cost[flow_cost.get_prot_id(item_prototype)]
                local stackable = true
                if item_prototype.flags ~= nil then
                    for _, flag in pairs(item_prototype.flags) do
                        if flag == "not-stackable" then
                            stackable = false
                        end
                    end
                end
                -- Check appropriate stackability, not a science pack (so as to not disrupt progression entirely), and that it's not otherwise not supposed to be randomized
                if stackable and item_prototype.equipment_grid == nil and item_prototype.type ~= "tool" and not dont_randomize_item[item_prototype.name] then
                    -- Some randomness to determine whether to randomize it
                    if rng.value(rng.key({id = id})) <= settings.startup["propertyrandomizer-item-percent"].value / 100 then
                        to_be_randomized[build_graph.key(node.type, node.name)] = true
                    end
                end
            end
        end
    end

    -- First, modify the graph to separate item slots and item travelers, and to focus all traveler connections on the item node rather than the item-surface nodes
    -- This could cause issues with how it wipes away some complexity with surfaces, but I don't see a better way for now
    local stays_with_traveler = {
        ["build-entity-item"] = true,
        ["build-entity-item-surface"] = true,
        ["build-tile-item-surface"] = true,
        ["plant-entity-item-surface"] = true,
        ["repair-pack"] = true,
        ["rocket-turret"] = true,
        ["rocket-ammo"] = true,
        ["burn-item"] = true,
        -- Note: fuel-category-surface is used primarily
        ["fuel-category"] = true,
        ["fuel-category-surface"] = true,
        -- This is an AND node so it needs fixing!
        --["build-tile-item-surface-with-item"] = true,
        ["burn-item-surface"] = true,
    }
    for node_name, _ in pairs(to_be_randomized) do
        local item_node = dep_graph[node_name]
        -- First move all traveler dependents to the item from any item-surface
        for surface_name, surface in pairs(build_graph.surfaces) do
            local item_surface_node = dep_graph[build_graph.key("item-surface", build_graph.compound_key({item_node.name, surface_name}))]
            local dependents_to_remove = {}
            for _, dependent in pairs(item_surface_node.dependents) do
                if stays_with_traveler[dependent.type] then
                    table.insert(dependents_to_remove, dependent)
                end
            end
            for _, dependent in pairs(dependents_to_remove) do
                local dependent_node = dep_graph[build_graph.key(dependent.type, dependent.name)]
                graph_utils.add_prereq(item_node, dependent_node)
                graph_utils.remove_prereq(item_surface_node, dependent_node)
            end
        end

        -- Now, separate item slots away from item travelers
        local item_slot_node = {
            type = "item-slot",
            name = item_node.name,
            prereqs = {},
            dependents = {}
        }
        dep_graph[build_graph.key("item-slot", item_node.name)] = item_slot_node
        local prereqs_to_remove = {}
        for _, prereq in pairs(item_node.prereqs) do
            table.insert(prereqs_to_remove, prereq)
        end
        for _, prereq in pairs(prereqs_to_remove) do
            local prereq_node = dep_graph[build_graph.key(prereq.type, prereq.name)]
            graph_utils.add_prereq(prereq_node, item_slot_node)
            graph_utils.remove_prereq(prereq_node, item_node)
        end
        -- Add this temporarily for graph sorting; it will be taken away later
        graph_utils.add_prereq(item_slot_node, item_node)
    end

    -- Now re-sort and create our list of dependents and prereqs for shuffling
    local prereq_sort_info = top_sort.sort(dep_graph)

    local shuffled_prereqs = {}
    local sorted_dependents = {}
    local blacklist = {}
    for _, item_node in pairs(prereq_sort_info.sorted) do
        local node_name = build_graph.key(item_node.type, item_node.name)
        if to_be_randomized[node_name] then
            table.insert(shuffled_prereqs, item_node.prereqs[1])
            table.insert(sorted_dependents, item_node)
            -- Blacklist the edges incoming to the item-surface nodes corresponding to this item
            for surface_name, surface in pairs(build_graph.surfaces) do
                local item_surface_node = dep_graph[build_graph.key("item-surface", build_graph.compound_key({item_node.name, surface_name}))]
                for _, prereq in pairs(item_surface_node.prereqs) do
                    blacklist[build_graph.conn_key({prereq, item_surface_node})] = true
                end
            end
            local item_slot_node = dep_graph[build_graph.key("item-slot", item_node.name)]
            graph_utils.remove_prereq(item_slot_node, item_node)
        end
    end

    -- Shuffle prereqs
    -- Note: In old algorithm, I actually sort the prereqs and shuffle the dependents... strange, but it seemed to work well?
    rng.shuffle(rng.key({id = id}), shuffled_prereqs)
    local slot_to_item = {}
    local curr_sort_state = top_sort.sort(dep_graph, blacklist)
    for _, dep_traveler in pairs(sorted_dependents) do
        -- A slot is reachable if and only if one of its item-surface prereqs is
        local function is_reachable(slot)
            local slot_node = dep_graph[build_graph.key(slot.type, slot.name)]
            for _, prereq in pairs(slot_node.prereqs) do
                if curr_sort_state.reachable[build_graph.key(prereq.type, prereq.name)] then
                    return true
                end
            end
            return false
        end

        local new_slot
        for _, proposed_slot in pairs(shuffled_prereqs) do
            if is_reachable(proposed_slot) and slot_to_item[proposed_slot.name] == nil then
                local slot_cost = cost_as_slot.material_to_cost[flow_cost.get_prot_id(proposed_slot)]
                local traveler_cost = cost_as_traveler.material_to_cost[flow_cost.get_prot_id(dep_traveler)]

                local traveling_item = items[dep_traveler.name]
                local proposed_item = items[proposed_slot.name]

                -- Check that costs align
                local worry_about_costs = false
                if traveler_cost ~= nil and (proposed_item.place_result ~= nil or proposed_item.type ~= "item" or proposed_item.fuel_value ~= nil or proposed_item.place_as_tile ~= nil or proposed_item.plant_result ~= nil) then
                    worry_about_costs = true
                end
                if not worry_about_costs or (slot_cost ~= nil and slot_cost <= constants.item_randomization_cost_factor_threshold * traveler_cost) then
                    -- Check now that stack sizes match up
                    if traveling_item.stack_size >= proposed_item.stack_size / 10 then
                        new_slot = proposed_slot
                        break
                    end
                end
            end
        end
        if new_slot == nil then
            log(serpent.block(curr_sort_state.reachable))
            error("Item randomization failed.")
        end

        log(new_slot.name)
        log(dep_traveler.name)
        slot_to_item[new_slot.name] = dep_traveler
        local new_slot_node = dep_graph[build_graph.key(new_slot.type, new_slot.name)]
        -- Connect the traveler to the slot and unblacklist the slot
        graph_utils.add_prereq(new_slot_node, dep_traveler)
        for surface_name, surface in pairs(build_graph.surfaces) do
            local item_surface_node = dep_graph[build_graph.key("item-surface", build_graph.compound_key({new_slot.name, surface_name}))]
            for _, prereq in pairs(item_surface_node.prereqs) do
                blacklist[build_graph.conn_key({prereq, item_surface_node})] = false
                curr_sort_state = top_sort.sort(dep_graph, blacklist, curr_sort_state, {prereq, item_surface_node})
            end
        end
    end

    ----------------------------------------------------------------------
    -- Messy data.raw change
    ----------------------------------------------------------------------

    local new_order = {}
    local old_order = shuffled_prereqs
    for _, thing in pairs(old_order) do
        table.insert(new_order, slot_to_item[thing.name])
    end

    -- Fix data.raw
    local changes = {}
    local post_changes = {}
    local post_changes_spoil = {}
    local num_times_changed_graphics_of_simple_entity = {}
    for ind, item_node in pairs(new_order) do
        -- item_node takes the place of same-indexed node in old_order
        local old_node = visited_old_order[ind]
        local old_item = items[old_node.item]

        local item_prototype = items[item_node.item]
        local incoming_cost = old_aggregate_cost_for_old.material_to_cost[flow_cost.get_prot_id(item_prototype)]
        local outgoing_cost = old_aggregate_cost_for_new.material_to_cost[flow_cost.get_prot_id(old_item)]
        local amount_multiplier = 1
        local is_significant = false
        if item_prototype.place_result ~= nil or item_prototype.type ~= "item" or item_prototype.fuel_value ~= nil or item_prototype.place_as_tile ~= nil or item_prototype.plant_result ~= nil then
            is_significant = true
        end
        if is_significant and incoming_cost ~= nil and outgoing_cost ~= nil and outgoing_cost / incoming_cost >= 2 and item_prototype.name ~= old_item.name then
            amount_multiplier = math.floor(outgoing_cost / incoming_cost)
        end

        for _, recipe in pairs(data.raw.recipe) do
            for _, material_property in pairs({"ingredients", "results"}) do
                if recipe[material_property] ~= nil then
                    for _, ing_or_prod in pairs(recipe[material_property]) do
                        if ing_or_prod.name == old_node.name then
                            table.insert(changes, {
                                tbl = ing_or_prod,
                                prop = "name",
                                new_val = item_node.name
                            })

                            -- Multiply amounts in products if this is significantly more expensive
                            if material_property == "results" and recipe.category ~= "recycling" then
                                for _, key in pairs({"amount", "amount_min", "amount_max"}) do
                                    if ing_or_prod[key] ~= nil then
                                        ing_or_prod[key] = math.min(65535, ing_or_prod[key] * amount_multiplier)
                                    end
                                end
                            end
                        end
                    end
                end
            end

            local fix_localised = false
            if recipe.results ~= nil and #recipe.results >= 1 and --[[#recipe.results == 1 and]] recipe.results[1].name == old_node.name then
                -- Fix main product for localisations
                table.insert(changes, {
                    tbl = recipe,
                    prop = "main_product",
                    new_val = item_node.name
                })
                fix_localised = true
            end
            if recipe.main_product == old_node.name then
                table.insert(changes, {
                    tbl = recipe,
                    prop = "main_product",
                    new_val = item_node.name
                })
                fix_localised = true
            end
            if fix_localised then
                -- Find original recipe prototype from dupes if applicable
                local orig_recipe = recipe
                if orig_recipe.orig_name ~= nil then
                    orig_recipe = data.raw.recipe[orig_recipe.orig_name]
                end
                if orig_recipe.localised_name == nil then
                    recipe.localised_name = {"?", {"recipe-name." .. orig_recipe.name}, locale_utils.find_localised_name(item_prototype)}
                end
                -- If the original recipe had no icon, recreate the icon as the new item's
                if orig_recipe.icons == nil and orig_recipe.icon == nil then
                    local recipe_icons
                    if item_prototype.icons ~= nil then
                        recipe.icons = item_prototype.icons
                    else
                        recipe.icons = {
                            {
                                icon = item_prototype.icon,
                                icon_size = item_prototype.icon_size or 64
                            }
                        }
                    end
                end
            end
        end

        -- Replace mine results
        local minable_things = table.deepcopy(defines.prototypes.entity)
        -- Need to account for asteroid chunks as well
        minable_things["asteroid-chunk"] = true
        for entity_class, _ in pairs(minable_things) do
            if data.raw[entity_class] ~= nil then
                for _, entity in pairs(data.raw[entity_class]) do
                    -- Don't replace entities that are player creations, so that you still get the buildings back you place down
                    local is_building = false
                    if entity.flags ~= nil then
                        for _, flag in pairs(entity.flags) do
                            if flag == "placeable-player" or flag == "player-creation" then
                                is_building = true
                            end
                        end
                    end

                    if not is_building then
                        local has_result = false

                        if entity.minable ~= nil then
                            if entity.minable.results ~= nil then
                                for _, result in pairs(entity.minable.results) do
                                    if result.name == old_node.name then
                                        table.insert(changes, {
                                            tbl = result,
                                            prop = "name",
                                            new_val = item_node.name
                                        })

                                        -- Multiply amounts if this is significantly more expensive
                                        for _, key in pairs({"amount", "amount_min", "amount_max"}) do
                                            if result[key] ~= nil then
                                                result[key] = math.min(65535, result[key] * amount_multiplier)
                                            end
                                        end

                                        has_result = true
                                    end
                                end
                            elseif entity.minable.result == old_node.name then
                                table.insert(changes, {
                                    tbl = entity.minable,
                                    prop = "result",
                                    new_val = item_node.name
                                })

                                entity.minable.count = math.min(65535, (entity.minable.count or 1) * amount_multiplier)

                                has_result = true
                            end
                        end

                        if has_result then
                            if entity.type == "resource" and (entity.minable.results == nil or #entity.minable.results == 1) then
                                entity.localised_name = locale_utils.find_localised_name(item_prototype)
                                entity.stages = {
                                    -- Note: This is technically botched with icons, TODO: Fix
                                    sheets = {
                                        {
                                            variation_count = 1,
                                            filename = item_prototype.icon or item_prototype.icons[1].icon,
                                            size = item_prototype.icon_size or 64,
                                            scale = 0.35,
                                            shift = {0.2, 0.6}
                                        },
                                        {
                                            variation_count = 1,
                                            filename = item_prototype.icon or item_prototype.icons[1].icon,
                                            size = item_prototype.icon_size or 64,
                                            scale = 0.25,
                                            shift = {-0.5, 0.2}
                                        },
                                        {
                                            variation_count = 1,
                                            filename = item_prototype.icon or item_prototype.icons[1].icon,
                                            size = item_prototype.icon_size or 64,
                                            scale = 0.45,
                                            shift = {0, 0}
                                        },
                                        {
                                            variation_count = 1,
                                            filename = item_prototype.icon or item_prototype.icons[1].icon,
                                            size = item_prototype.icon_size or 64,
                                            scale = 0.4,
                                            shift = {-0.2, -0.6}
                                        }
                                    }
                                }
                                entity.stage_counts = {entity.stage_counts[1]}
                                entity.stages_effect = nil
                            end

                            -- Make trees like fruit trees
                            if entity.type == "tree" then
                                -- Assume tree graphics are defined a certain way
                                -- TODO: Remove this assumption
                                if entity.variations ~= nil then
                                    for _, variation in pairs(entity.variations) do
                                        local new_frame_sequence = {}
                                        for i = 1, variation.leaves.frame_count or 1 do
                                            table.insert(new_frame_sequence, 1)
                                        end
                                        local old_leaves = table.deepcopy(variation.leaves)
                                        variation.leaves = {
                                            layers = {}
                                        }
                                        -- Relative to tree size
                                        local shifts = {
                                            {0.3, 0.6},
                                            {0.5, 0.55},
                                            {0.7, 0.65},
                                            {0.9, 0.5}
                                        }
                                        -- Add random variations to the shifts
                                        for i = 1, #shifts do
                                            shifts[i][1] = shifts[i][1] + 0.2 * (1 - 2 * rng.value(rng.key({id = id, prototype = entity})))
                                            shifts[i][2] = shifts[i][2] + 0.2 * (1 - 2 * rng.value(rng.key({id = id, prototype = entity})))
                                        end
                                        selection_box_x_size = entity.selection_box[2][1] - entity.selection_box[1][1]
                                        selection_box_y_size = entity.selection_box[2][2] - entity.selection_box[1][2] + (entity.drawing_box_vertical_extension or 0)
                                        local starting_x = (old_leaves.shift or {0,0})[1] - selection_box_x_size / 2
                                        local starting_y = (old_leaves.shift or {0,0})[2] - selection_box_y_size / 2
                                        for i = 1, #shifts do
                                            table.insert(variation.leaves.layers, {
                                                variation_count = 1,
                                                frame_sequence = new_frame_sequence,
                                                frame_count = variation.leaves.frame_count,
                                                filename = item_prototype.icon or item_prototype.icons[1].icon,
                                                size = item_prototype.icon_size or 64,
                                                scale = 0.3,
                                                shift = {entity.selection_box[1][1] + selection_box_x_size * shifts[i][1], entity.selection_box[1][2] - (entity.drawing_box_vertical_extension or 0) + selection_box_y_size * shifts[i][2]}
                                            })
                                        end
                                        table.insert(variation.leaves.layers, 1, old_leaves)
                                        --[[
                                        variation.leaves.layers[1].frame_count = 1
                                        variation.shadow.frame_count = 2
                                        if variation.normal ~= nil then
                                            variation.normal.frame_count = 1
                                        end
                                        variation.trunk.frame_count = 2]]
                                    end
                                end
                            end

                            -- Now for rocks and such
                            -- Assume graphics are a certain way
                            if entity.type == "simple-entity" and entity.pictures ~= nil then
                                num_times_changed_graphics_of_simple_entity[entity.name] = (num_times_changed_graphics_of_simple_entity[entity.name] or 0) + 1
                                if num_times_changed_graphics_of_simple_entity[entity.name] == 1 then
                                    entity.lower_pictures = {}
                                end
                                -- Medium-ish render layer
                                entity.lower_render_layer = "object"

                                local variations_tbl
                                if entity.pictures[1] ~= nil then
                                    variations_tbl = entity.pictures
                                elseif entity.pictures.sheet ~= nil then
                                    variations_tbl = {entity.pictures.sheet}
                                else
                                    variations_tbl = {entity.pictures}
                                end

                                for j = 1, #variations_tbl do
                                    if num_times_changed_graphics_of_simple_entity[entity.name] == 1 then
                                        entity.lower_pictures[j] = {layers = {}}
                                    end

                                    -- Relative to rock size
                                    local shifts = {
                                        {0.3, 0.6},
                                        {0.5, 0.55},
                                        {0.7, 0.65},
                                        {0.6, 0.3}
                                    }
                                    -- Add random variations to the shifts
                                    for i = 1, #shifts do
                                        shifts[i][1] = shifts[i][1] + 0.2 * (1 - 2 * rng.value(rng.key({id = id, prototype = entity})))
                                        shifts[i][2] = shifts[i][2] + 0.2 * (1 - 2 * rng.value(rng.key({id = id, prototype = entity})))
                                    end
                                    local selection_box_x_size = entity.selection_box[2][1] - entity.selection_box[1][1]
                                    local selection_box_y_size = entity.selection_box[2][2] - entity.selection_box[1][2]
                                    for i = 1, #shifts do
                                        table.insert(entity.lower_pictures[j].layers, {
                                            filename = item_prototype.icon or item_prototype.icons[1].icon,
                                            size = item_prototype.icon_size or 64,
                                            scale = 0.25,
                                            tint = {236, 152, 130},
                                            shift = {entity.selection_box[1][1] + selection_box_x_size * shifts[i][1], entity.selection_box[1][2] - (entity.drawing_box_vertical_extension or 0) + selection_box_y_size * shifts[i][2]}
                                        })
                                    end
                                end

                                --[[entity.animations = entity.pictures
                                
                                local variations_tbl
                                if entity.animations[1] ~= nil then
                                    variations_tbl = entity.animations
                                elseif entity.animations.sheet ~= nil then
                                    variations_tbl = {entity.animations.sheet}
                                else
                                    variations_tbl = {entity.animations}
                                end

                                for _, variation in pairs(variations_tbl) do
                                    -- Relative to rock size
                                    local shifts = {
                                        {0.3, 0.6},
                                        {0.5, 0.55},
                                        {0.7, 0.65},
                                        {0.9, 0.5},
                                        {0.1, 0.85},
                                        {0.05, 0.15},
                                        {0.6, 0.1}
                                    }
                                    -- Add random variations to the shifts
                                    for i = 1, #shifts do
                                        shifts[i][1] = shifts[i][1] + 0.2 * (1 - 2 * rng.value(rng.key({id = id, prototype = entity})))
                                        shifts[i][2] = shifts[i][2] + 0.2 * (1 - 2 * rng.value(rng.key({id = id, prototype = entity})))
                                    end
                                    variation.layers = {
                                        variation
                                    }
                                    --[[for k, _ in pairs(variation) do
                                        if k ~= "layers" then
                                            variation[k] = nil
                                        end
                                    end
                                    selection_box_x_size = entity.selection_box[2][1] - entity.selection_box[1][1]
                                    selection_box_y_size = entity.selection_box[2][2] - entity.selection_box[1][2]
                                    for i = 1, #shifts do
                                        table.insert(variation.layers, {
                                            filename = item_prototype.icon or item_prototype.icons[1].icon,
                                            size = item_prototype.icon_size or 64,
                                            scale = 0.2,
                                            shift = {entity.selection_box[1][1] + selection_box_x_size * shifts[i][1], entity.selection_box[1][2] - (entity.drawing_box_vertical_extension or 0) + selection_box_y_size * shifts[i][2]}
                                        })
                                    end
                                end]]
                            end
                        end
                    end
                end
            end
        end

        -- See if any items spoil into the old one and modify accordingly
        -- Also look for burnt results
        for item_class, _ in pairs(defines.prototypes.item) do
            if data.raw[item_class] ~= nil then
                for _, item in pairs(data.raw[item_class]) do
                    if item.spoil_result == old_item.name then
                        table.insert(changes, {
                            tbl = item,
                            prop = "spoil_result",
                            new_val = item_prototype.name
                        })
                    end
                    --[[if item.burnt_result == old_item.name then
                        table.insert(changes, {
                            tbl = item,
                            prop = "burnt_result",
                            new_val = item_prototype.name
                        })
                    end]]
                end
            end
        end
        -- Transfer old node's fuel value here
        -- This must be done after burnt results
        --[[table.insert(post_changes, {
            tbl = item_prototype,
            prop = "fuel_value",
            new_val = old_item.fuel_value
        })
        table.insert(post_changes, {
            tbl = item_prototype,
            prop = "fuel_category",
            new_val = old_item.fuel_category
        })
        table.insert(post_changes, {
            tbl = item_prototype,
            prop = "fuel_acceleration_multiplier",
            new_val = old_item.fuel_acceleration_multiplier
        })
        table.insert(post_changes, {
            tbl = item_prototype,
            prop = "fuel_top_speed_multiplier",
            new_val = old_item.fuel_top_speed_multiplier
        })
        table.insert(post_changes, {
            tbl = item_prototype,
            prop = "fuel_emissions_multiplier",
            new_val = old_item.fuel_emissions_multiplier
        })
        table.insert(post_changes, {
            tbl = item_prototype,
            prop = "fuel_glow_color",
            new_val = old_item.fuel_glow_color
        })]]
        -- Transfer old node's spoil stats
        -- This must be done after the spoil_results are updated
        table.insert(post_changes_spoil, {
            tbl = item_prototype,
            prop = "spoil_result",
            old_node_item = old_item
        })
        table.insert(post_changes, {
            tbl = item_prototype,
            prop = "spoil_ticks",
            new_val = old_item.spoil_ticks
        })
        -- CRITICAL TODO: Needs fixing for same reasons as post_changes_spoil
        table.insert(post_changes, {
            tbl = item_prototype,
            prop = "spoil_to_trigger_result",
            new_val = old_item.spoil_to_trigger_result
        })
        table.insert(post_changes, {
            tbl = item_prototype,
            prop = "spoil_level",
            new_val = old_item.spoil_level
        })

        -- Change trigger techs
        for _, technology in pairs(data.raw.technology) do
            if technology.research_trigger ~= nil then
                if technology.research_trigger.type == "craft-item" then
                    if technology.research_trigger.item == old_item.name then
                        table.insert(changes, {
                            tbl = technology.research_trigger,
                            prop = "item",
                            new_val = item_prototype.name
                        })
                    end
                    if type(technology.research_trigger.item) == "table" and technology.research_trigger.item.name == old_item.name then
                        table.insert(changes, {
                            tbl = technology.research_trigger.item,
                            prop = "name",
                            new_val = item_prototype.name
                        })
                    end
                end
            end
        end

        -- TODO: Make this check less ad-hoc
        -- If this is a coal replacement, give it a fuel value
        if old_item.name == "coal" then
            -- TODO: Need to do something special if this is the only non-chemical fuel for something...
            if item_prototype.fuel_category == nil then
                item_prototype.localised_description = {"", locale_utils.find_localised_description(item_prototype), "\n[color=green](Combustible)[/color]"}
            end

            if item_prototype.fuel_category ~= "chemical" then
                item_prototype.fuel_category = "chemical"
                item_prototype.fuel_value = "4MJ"
            elseif util.parse_energy(item_prototype.fuel_value) < 1000000 then
                item_prototype.fuel_value = "1MJ"
            end
            -- item_prototype.localised_name = {"", locale_utils.find_localised_name(item_prototype), "\n[color=red](Burnable)[/color]"}
        end
    end
    for _, change in pairs(changes) do
        change.tbl[change.prop] = change.new_val
    end
    for _, change in pairs(post_changes) do
        change.tbl[change.prop] = change.new_val
    end
    for _, change in pairs(post_changes_spoil) do
        change.tbl[change.prop] = change.old_node_item[change.prop]
    end

    -- return that we've succeeded
    return true
end