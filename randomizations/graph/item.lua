-- Randomize "usage" of items; for example, bullets may take the place of iron gears as the common iron intermediate
-- This should be run BEFORE recipe ingredient randomization

-- Balancing todos
--   * Need some sort of cost preservation for common buildings
--   * Need to blacklist connections in the right way (not doing that now), to prevent softlocks

-- Only used for its utility functions
local constants = require("helper-tables/constants")
local build_graph = require("lib/graph/build-graph")
local flow_cost = require("lib/graph/flow-cost")
local top_sort = require("lib/graph/top-sort")
local rng = require("lib/random/rng")
local locale_utils = require("lib/locale")

randomizations.item = function(id)
    local old_aggregate_cost = flow_cost.determine_recipe_item_cost(flow_cost.get_default_raw_resource_table(), constants.cost_params.time, constants.cost_params.complexity)
    local item_recipe_maps = flow_cost.construct_item_recipe_maps()

    local sort_info = top_sort.sort(dep_graph)
    local graph_sort = sort_info.sorted

    type_stays_with_node = {
        ["build-entity-item"] = true,
        ["build-tile-item"] = true,
        ["plant-entity-item"] = true
    }
    local node_to_old_stay_with_dependents = {}

    local old_order = {}
    local shuffled_order = {}
    local blacklist = {}
    for _, item_node in pairs(graph_sort) do
        if item_node.type == "item" then
            -- Condition: only do items reachable from nauvis, no weirdness
            if sort_info.reachable[build_graph.key("item-surface", build_graph.compound_key({item_node.name, build_graph.compound_key({"planet", "nauvis"})}))] then
                -- Must have flow cost, and the cost must be reasonable
                local cost = old_aggregate_cost.material_to_cost[flow_cost.get_prot_id(item_node.item)]
                -- Remove this check for now
                --if cost ~= nil and 0.5 < cost and cost < 50 then
                    -- Also check stack size, since stack size 1 intermediates would suck
                    -- Disable check for now
                    --if item_node.item.stack_size >= 10 then
                    -- Instead just check for not stackable
                    local stackable = true
                    if item_node.item.flags ~= nil then
                        for _, flag in pairs(item_node.item.flags) do
                            if flag == "not-stackable" then
                                stackable = false
                            end
                        end
                    end
                    if stackable and item_node.item.equipment_grid == nil then
                        local num_corresponding_recipes = 0
                        if item_recipe_maps.material_to_recipe[flow_cost.get_prot_id(item_node.item)] ~= nil then
                            for _, _ in pairs(item_recipe_maps.material_to_recipe[flow_cost.get_prot_id(item_node.item)]) do
                                num_corresponding_recipes = num_corresponding_recipes + 1
                            end
                        end
                        -- Check there's at least one recipe making this
                        -- This isn't foolproof to softlocks but good enough for now
                        -- TODO: Check better against softlocks!
                        -- Remove for now
                        --if num_corresponding_recipes >= 1 then
                            -- Actually, also check that it's not gotten any way other than recipes (I guess this makes the last check irrelevant)
                            -- TODO: Clean up these checks
                            local all_valid_prereqs = true
                            for _, prereq in pairs(item_node.prereqs) do
                                -- TODO: If items get refactored to just depend on item-surfaces, we'd need to look at the nauvis item-surface for this
                                -- Hold off on this until a future update though
                                -- Note: the prereq.type ~= "item" is supposed to capture spoilage
                                -- TODO: Just add an is_spoilage prereq key so it can be more accurate
                                if sort_info.reachable[build_graph.key(prereq.type, prereq.name)] and prereq.type ~= "craft-material" and prereq.type ~= "craft-material-surface" and prereq.type ~= "mine-entity" and prereq.type ~= "item" then
                                    all_valid_prereqs = false
                                end
                            end

                            -- Remove this check for now?
                            --if all_valid_prereqs then
                                -- Also check that it's not a science pack (I hope I don't need many more checks...)
                                -- Also check burnt results since those were having issues :(
                                if item_node.item.type ~= "tool" and item_node.item.burnt_result == nil then
                                    -- Special priority to resources
                                    local is_raw_resource = false
                                    for _, resource in pairs(data.raw.resource) do
                                        if resource.minable ~= nil then
                                            if resource.minable.results ~= nil then
                                                for _, result in pairs(resource.minable.results) do
                                                    if result.name == item_node.item.name then
                                                        is_raw_resource = true
                                                    end
                                                end
                                            elseif resource.minable.result == item_node.item.name then
                                                is_raw_resource = true
                                            end
                                        end
                                    end

                                    -- If it's a very commonly used item, include it with a 70% chance, otherwise only do so with 30% chance
                                    if is_raw_resource or (num_corresponding_recipes >= 10 and rng.value(rng.key({id = id})) <= 0.7) or rng.value(rng.key({id = id})) <= 0.3 then
                                        table.insert(old_order, item_node)
                                        table.insert(shuffled_order, item_node)

                                        for _, prereq in pairs(item_node.prereqs) do
                                            blacklist[build_graph.conn_key({prereq, item_node})] = true
                                        end
                                        local new_dependents = {}
                                        node_to_old_stay_with_dependents[item_node.name] = {}
                                        for _, dependent in pairs(item_node.dependents) do
                                            -- TODO: Do I just actually just need to blacklist the recipe results connections
                                            --blacklist[build_graph.conn_key({item_node, dependent})] = true
                                            if type_stays_with_node[dependent.type] then
                                                -- Remove the dependent entirely
                                                table.insert(node_to_old_stay_with_dependents[item_node.name], dependent)
                                                local dependent_node = dep_graph[build_graph.key(dependent.type, dependent.name)]
                                                for i, prereq in pairs(dependent_node.prereqs) do
                                                    if prereq.type == item_node.type and prereq.name == item_node.name then
                                                        table.remove(dependent_node.prereqs, i)
                                                        break
                                                    end
                                                end
                                            else
                                                table.insert(new_dependents, dependent)
                                            end
                                        end
                                        item_node.dependents = new_dependents
                                    end
                                end
                            --end
                        --end
                    end
                --end
            end
        end
    end

    rng.shuffle(rng.key({id = id}), shuffled_order)

    local new_order = {}
    local ind_to_used = {}
    -- Initial reachability
    local sort_state = top_sort.sort(dep_graph, blacklist)
    for _, item_node in pairs(old_order) do
        local reachable = sort_state.reachable




        if not reachable[build_graph.key(item_node.type, item_node.name)] then
            log(item_node.name)
        end





        local new_node
        for ind = 1, #shuffled_order do
            -- I think reachability in this case is technically not needed, but it helps keep game progression
            if not ind_to_used[ind] and reachable[build_graph.key(shuffled_order[ind].type, shuffled_order[ind].name)] then
                new_node = shuffled_order[ind]
                ind_to_used[ind] = true
                table.insert(new_order, shuffled_order[ind])
                break
            end
            if ind == #shuffled_order then
                -- We couldn't find a new substitute
                log(serpent.block(reachable))
                log(item_node.name)
                error()
            end
        end





        log(item_node.name)
        log(new_node.name)
        -- So we're saying too much is reachable and that's biting us
        -- Now wait what's not reachable? We can get to the thruster
        -- Not finding utility science pack
        -- IDEA: Maybe do a fail-and-come-back mechanism? Check if item_node is reachable each time
        -- Ohhhh it didn't find the rocket silo at all?
        -- Or chemical science pack? Oh no wait we blacklisted those
        -- It's finding the build-entity for rocket silo but not the rocket silo




        -- Essentially need to unlock some of new node's dependents, but not old_node's
        -- Right now what occurs to me for this is entities that are player creations
        -- TODO: Proper connection labels here rather than just guessing from node types
        --[[for _, dependent in pairs(new_node.dependents) do
            if type_stays_with_node[dependent.type] then
                blacklist[build_graph.conn_key({new_node, dependent})] = false
                sort_state = top_sort.sort(dep_graph, blacklist, sort_state, {new_node, dependent})
            end
        end]]
        -- Add old stay-with-type nodes
        for _, dependent in pairs(node_to_old_stay_with_dependents[new_node.name]) do
            local dependent_node = dep_graph[build_graph.key(dependent.type, dependent.name)]
            table.insert(dependent_node.dependents, {
                type = item_node.type,
                name = item_node.name
            })
            table.insert(item_node.dependents, dependent)
        end
        --[[for _, dependent in pairs(item_node.dependents) do
            if not type_stays_with_node[dependent.type] then
                blacklist[build_graph.conn_key({item_node, dependent})] = false
                sort_state = top_sort.sort(dep_graph, blacklist, sort_state, {item_node, dependent})
            end
        end]]

        for _, prereq in pairs(item_node.prereqs) do
            blacklist[build_graph.conn_key({prereq, item_node})] = false
            sort_state = top_sort.sort(dep_graph, blacklist, sort_state, {prereq, item_node})
        end
    end

    -- Fix data.raw
    local changes = {}
    local post_changes = {}
    local num_times_changed_graphics_of_simple_entity = {}
    for ind, item_node in pairs(new_order) do
        -- item_node takes the place of same-indexed node in old_order
        local old_node = old_order[ind]

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
                        end
                    end
                end
            end

            local fix_localised = false
            if recipe.results ~= nil and #recipe.results == 1 and recipe.results[1].name == old_node.name then
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
                recipe.localised_name = {"?", locale_utils.find_localised_name(recipe), locale_utils.find_localised_name(item_node.item)}
            end
        end

        -- Replace mine results
        for entity_class, _ in pairs(defines.prototypes.entity) do
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
                                        has_result = true
                                    end
                                end
                            elseif entity.minable.result == old_node.name then
                                table.insert(changes, {
                                    tbl = entity.minable,
                                    prop = "result",
                                    new_val = item_node.name
                                })
                                has_result = true
                            end
                        end

                        if has_result then
                            if entity.type == "resource" and (entity.minable.results == nil or #entity.minable.results == 1) then
                                entity.stages = {
                                    -- Note: This is technically botched with icons, TODO: Fix
                                    sheets = {
                                        {
                                            variation_count = 1,
                                            filename = item_node.item.icon or item_node.item.icons[1].icon,
                                            size = item_node.item.icon_size or 64,
                                            scale = 0.35,
                                            shift = {0.2, 0.6}
                                        },
                                        {
                                            variation_count = 1,
                                            filename = item_node.item.icon or item_node.item.icons[1].icon,
                                            size = item_node.item.icon_size or 64,
                                            scale = 0.25,
                                            shift = {-0.5, 0.2}
                                        },
                                        {
                                            variation_count = 1,
                                            filename = item_node.item.icon or item_node.item.icons[1].icon,
                                            size = item_node.item.icon_size or 64,
                                            scale = 0.45,
                                            shift = {0, 0}
                                        },
                                        {
                                            variation_count = 1,
                                            filename = item_node.item.icon or item_node.item.icons[1].icon,
                                            size = item_node.item.icon_size or 64,
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
                                                filename = item_node.item.icon or item_node.item.icons[1].icon,
                                                size = item_node.item.icon_size or 64,
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
                                    selection_box_x_size = entity.selection_box[2][1] - entity.selection_box[1][1]
                                    selection_box_y_size = entity.selection_box[2][2] - entity.selection_box[1][2]
                                    for i = 1, #shifts do
                                        table.insert(entity.lower_pictures[j].layers, {
                                            filename = item_node.item.icon or item_node.item.icons[1].icon,
                                            size = item_node.item.icon_size or 64,
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
                                            filename = item_node.item.icon or item_node.item.icons[1].icon,
                                            size = item_node.item.icon_size or 64,
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
                    if item.spoil_result == old_node.item.name then
                        table.insert(changes, {
                            tbl = item,
                            prop = "spoil_result",
                            new_val = item_node.item.name
                        })
                    end
                    if item.burnt_result == old_node.item.name then
                        table.insert(changes, {
                            tbl = item,
                            prop = "burnt_result",
                            new_val = item_node.item.name
                        })
                    end
                end
            end
        end
        -- Transfer old node's fuel value here
        -- This must be done after burnt results
        table.insert(post_changes, {
            tbl = item_node.item,
            prop = "fuel_value",
            new_val = old_node.item.fuel_value
        })
        table.insert(post_changes, {
            tbl = item_node.item,
            prop = "fuel_category",
            new_val = old_node.item.fuel_category
        })
        table.insert(post_changes, {
            tbl = item_node.item,
            prop = "fuel_acceleration_multiplier",
            new_val = old_node.item.fuel_acceleration_multiplier
        })
        table.insert(post_changes, {
            tbl = item_node.item,
            prop = "fuel_top_speed_multiplier",
            new_val = old_node.item.fuel_top_speed_multiplier
        })
        table.insert(post_changes, {
            tbl = item_node.item,
            prop = "fuel_emissions_multiplier",
            new_val = old_node.item.fuel_emissions_multiplier
        })
        table.insert(post_changes, {
            tbl = item_node.item,
            prop = "fuel_glow_color",
            new_val = old_node.item.fuel_glow_color
        })
        -- Transfer old node's spoil stats
        -- This must be done after the spoil_results are updated
        table.insert(post_changes, {
            tbl = item_node.item,
            prop = "spoil_result",
            new_val = old_node.item.spoil_result
        })
        table.insert(post_changes, {
            tbl = item_node.item,
            prop = "spoil_ticks",
            new_val = old_node.item.spoil_ticks
        })
        table.insert(post_changes, {
            tbl = item_node.item,
            prop = "spoil_to_trigger_result",
            new_val = old_node.item.spoil_to_trigger_result
        })
        table.insert(post_changes, {
            tbl = item_node.item,
            prop = "spoil_level",
            new_val = old_node.item.spoil_level
        })

        -- Change trigger techs
        for _, technology in pairs(data.raw.technology) do
            if technology.research_trigger ~= nil then
                if technology.research_trigger.type == "craft-item" then
                    log(serpent.block(technology.research_trigger))
                    if technology.research_trigger.item == old_node.item.name then
                        table.insert(changes, {
                            tbl = technology.research_trigger,
                            prop = "item",
                            new_val = item_node.item.name
                        })
                    end
                    if type(technology.research_trigger.item) == "table" and technology.research_trigger.item.name == old_node.item.name then
                        table.insert(changes, {
                            tbl = technology.research_trigger.item,
                            prop = "name",
                            new_val = item_node.item.name
                        })
                    end
                end
            end
        end
    end
    for _, change in pairs(changes) do
        change.tbl[change.prop] = change.new_val
    end
    for _, change in pairs(post_changes) do
        change.tbl[change.prop] = change.new_val
    end

    -- wood needs to have fuel value as the initial fuel of most burner energy sources
    -- TODO: Sense for this and fix it automatically!
    data.raw.item.wood.fuel_value = "2MJ"
    data.raw.item.wood.fuel_category = "chemical"
end