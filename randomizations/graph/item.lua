-- Randomize "usage" of items; for example, bullets may take the place of iron gears as the common iron intermediate

-- Balancing todos
--  * None at the moment, but I'm sure some will come up as it's tested

-- Only used for its utility functions
local constants = require("helper-tables/constants")
local build_graph = require("lib/graph/build-graph")
local flow_cost = require("lib/graph/flow-cost")
local top_sort = require("lib/graph/top-sort")
local rng = require("lib/random/rng")
local locale_utils = require("lib/locale")

-- item lookup
local items = {}
for item_class, _ in pairs(defines.prototypes.item) do
    if data.raw[item_class] ~= nil then
        for _, item in pairs(data.raw[item_class]) do
            items[item.name] = item
        end
    end
end

randomizations.item = function(id)
    local modified_raw_resource_table = flow_cost.get_default_raw_resource_table()
    -- Consider wood expensive as a new ingredient, but not as an old one
    modified_raw_resource_table["item-raw-fish"] = 1
    modified_raw_resource_table["item-wood"] = 1
    modified_raw_resource_table["item-spoilage"] = nil
    local old_aggregate_cost_for_old = flow_cost.determine_recipe_item_cost(modified_raw_resource_table, constants.cost_params.time, constants.cost_params.complexity)
    modified_raw_resource_table["item-raw-fish"] = 25
    modified_raw_resource_table["item-wood"] = 5
    modified_raw_resource_table["item-spoilage"] = nil
    local old_aggregate_cost_for_new = flow_cost.determine_recipe_item_cost(modified_raw_resource_table, constants.cost_params.time, constants.cost_params.complexity)
    local item_recipe_maps = flow_cost.construct_item_recipe_maps()

    local sort_info = top_sort.sort(dep_graph)
    local graph_sort = sort_info.sorted

    -- TODO: Need gun-turret node I think?
    local type_stays_with_node = {
        ["build-entity-item"] = true,
        ["build-entity-item-surface"] = true,
        ["build-tile-item-surface"] = true,
        ["plant-entity-item-surface"] = true,
        ["repair-pack"] = true,
        ["rocket-turret"] = true,
        ["rocket-ammo"] = true,
        ["burn-item"] = true,
        -- Note: fuel-category-surface is used instead of fuel-category now
        ["fuel-category"] = true,
        ["fuel-category-surface"] = true,
        -- This is an AND node so it needs fixing!
        --["build-tile-item-surface-with-item"] = true,
        ["burn-item-surface"] = true,
    }
    local is_blacklisted_item = {
        -- Rocket parts shouldn't be randomized
        ["rocket-part"] = true,
    }
    local node_to_old_stay_with_dependents = {}
    local node_to_old_stay_with_dependents_surface = {}

    local old_order = {}
    local shuffled_order = {}
    -- Used to put ores at the end so they don't become ores as often
    local post_shuffled_order = {}
    local blacklist = {}
    for _, item_node in pairs(graph_sort) do
        if item_node.type == "item" then
            local item_prototype = items[item_node.item]
            -- Condition: only do items reachable from nauvis, no weirdness
            if sort_info.reachable[build_graph.key("item-surface", build_graph.compound_key({item_node.name, build_graph.compound_key({"planet", "nauvis"})}))] then
                -- Must have flow cost, and the cost must be reasonable
                local cost = old_aggregate_cost_for_old.material_to_cost[flow_cost.get_prot_id(item_prototype)]
                -- Remove this check for now
                --if cost ~= nil and 0.5 < cost and cost < 50 then
                    -- Also check stack size, since stack size 1 intermediates would suck
                    -- Disable check for now
                    --if item_prototype.stack_size >= 10 then
                    -- Instead just check for not stackable
                    local stackable = true
                    if item_prototype.flags ~= nil then
                        for _, flag in pairs(item_prototype.flags) do
                            if flag == "not-stackable" then
                                stackable = false
                            end
                        end
                    end
                    if stackable and item_prototype.equipment_grid == nil then
                        local num_corresponding_recipes = 0
                        if item_recipe_maps.material_to_recipe[flow_cost.get_prot_id(item_prototype)] ~= nil then
                            for _, _ in pairs(item_recipe_maps.material_to_recipe[flow_cost.get_prot_id(item_prototype)]) do
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
                                if item_prototype.type ~= "tool" and item_prototype.burnt_result == nil and not is_blacklisted_item[item_prototype.name] then
                                    -- Special priority to resources
                                    local is_raw_resource = false
                                    for _, resource in pairs(data.raw.resource) do
                                        if resource.minable ~= nil then
                                            if resource.minable.results ~= nil then
                                                for _, result in pairs(resource.minable.results) do
                                                    if result.name == item_prototype.name then
                                                        is_raw_resource = true
                                                    end
                                                end
                                            elseif resource.minable.result == item_prototype.name then
                                                is_raw_resource = true
                                            end
                                        end
                                    end

                                    -- If it's a very commonly used item, include it with a 100% chance, otherwise only do so with 30% chance (default)
                                    if is_raw_resource or (num_corresponding_recipes >= 10 and rng.value(rng.key({id = id})) <= 1) or rng.value(rng.key({id = id})) <= config.item_percent_randomized then
                                        table.insert(old_order, item_node)
                                        if is_raw_resource then
                                            table.insert(post_shuffled_order, item_node)
                                        else
                                            table.insert(shuffled_order, item_node)
                                        end

                                        -- Get rid of corresponding item-surface thingies
                                        for surface_name, _ in pairs(build_graph.surfaces) do
                                            local surface_based_node = dep_graph[build_graph.key("item-surface", build_graph.compound_key({item_prototype.name, surface_name}))]

                                            for _, dependent in pairs(surface_based_node.dependents) do
                                                -- Recipes can somehow still get fulfilled idk
                                                if dependent.type ~= "recipe-surface" then
                                                    blacklist[build_graph.conn_key({surface_based_node, dependent})] = true
                                                end
                                            end

                                            node_to_old_stay_with_dependents_surface[surface_based_node.name] = {}
                                            for _, dependent in pairs(surface_based_node.dependents) do
                                                if type_stays_with_node[dependent.type] and not (dependent.type == "fuel-category-surface" and dependent.name == build_graph.compound_key({"chemical", surface_name})) then
                                                    table.insert(node_to_old_stay_with_dependents_surface[surface_based_node.name], dependent)
                                                    local dependent_node = dep_graph[build_graph.key(dependent.type, dependent.name)]
                                                    for i, prereq in pairs(dependent_node.prereqs) do
                                                        if prereq.type == surface_based_node.type and prereq.name == surface_based_node.name then
                                                            table.remove(dependent_node.prereqs, i)
                                                            break
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                        -- Now for actual item node
                                        for _, prereq in pairs(item_node.prereqs) do
                                            blacklist[build_graph.conn_key({prereq, item_node})] = true
                                        end
                                        local new_dependents = {}
                                        node_to_old_stay_with_dependents[item_node.name] = {}
                                        for _, dependent in pairs(item_node.dependents) do
                                            if type_stays_with_node[dependent.type] and not (dependent.type == "fuel-category" and dependent.name == "chemical") then
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
    -- Put resource nodes at end
    rng.shuffle(rng.key({id = id}), post_shuffled_order)
    for _, node in pairs(post_shuffled_order) do
        table.insert(shuffled_order, node)
    end

    local new_order = {}
    -- Since we might actually visit the old_order nodes out of order due to a fix I made for higher probabilities of randomization success chance,
    -- we need to keep track of how we actually visit the old_order nodes
    local visited_old_order = {}
    local ind_to_used = {}
    local ind_to_used_in_old_order = {}
    -- Initial reachability
    local sort_state = top_sort.sort(dep_graph, blacklist)
    for i = 1, #old_order do
        local reachable = sort_state.reachable

        for old_order_ind_2, item_node in pairs(old_order) do
            if not reachable[build_graph.key(item_node.type, item_node.name)] then
                log(item_node.name)
            end

            local item_prototype = items[item_node.item]
            if not ind_to_used_in_old_order[old_order_ind_2] and reachable[build_graph.key(item_node.type, item_node.name)] then
                local new_cost = old_aggregate_cost_for_old.material_to_cost[flow_cost.get_prot_id(item_prototype)]

                local new_node
                for ind = 1, #shuffled_order do
                    local proposed_node = shuffled_order[ind]
                    local proposed_item = items[proposed_node.item]

                    -- I think reachability in this case is technically not needed, but it helps keep game progression
                    if not ind_to_used[ind] and reachable[build_graph.key(proposed_node.type, proposed_node.name)] then
                        local old_cost = old_aggregate_cost_for_new.material_to_cost[flow_cost.get_prot_id(proposed_item)]
                        
                        -- If cost is assignable and this new item is special in some way, try to preserve that cost
                        -- Right now special just means it can place something or is not a standard item
                        local is_significant_item = false
                        local cost_threshold
                        if old_cost ~= nil and (proposed_item.place_result ~= nil or proposed_item.type ~= "item" or proposed_item.fuel_value ~= nil or proposed_item.place_as_tile ~= nil or proposed_item.plant_result ~= nil) then
                            is_significant_item = true

                            -- Cost threshold is higher for more expensive items, since they're probably less common
                            if old_cost <= 5 then
                                cost_threshold = 2
                            elseif old_cost <= 15 then
                                cost_threshold = 5
                            elseif old_cost <= 50 then
                                cost_threshold = 10
                            else
                                --cost_threshold = 10
                                -- If the old version is too expensive, don't worry too much about it
                                is_significant_item = false
                            end
                        end
                        
                        -- Check cost preservation if item_node is significant
                        -- Actually, let's just multiply results later and just make sure the new one has a cost for now
                        -- No wait, do have a cost threshold just for the more ridiculous cases
                        local cost_threshold = 100
                        if not is_significant_item or (new_cost ~= nil and new_cost <= cost_threshold * old_cost) then
                            -- Check now that stack sizes match up / no more light armor ore
                            if proposed_item.stack_size >= item_prototype.stack_size / 10 then
                                new_node = shuffled_order[ind]
                                ind_to_used[ind] = true
                                table.insert(visited_old_order, item_node)
                                table.insert(new_order, new_node)
                                break
                            end
                        end
                    end
                    if ind == #shuffled_order then
                        -- We couldn't find a new substitute
                        --log(serpent.block(reachable))
                        log(item_node.name)
                        log("NEED TO TRY OTHER NODES")
                        --error()
                    end
                end

                if new_node ~= nil then
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
                        table.insert(dependent_node.prereqs, {
                            type = item_node.type,
                            name = item_node.name
                        })
                        table.insert(item_node.dependents, dependent)
                    end
                    -- surface-based items
                    for surface_name, _ in pairs(build_graph.surfaces) do
                        local surface_based_node = dep_graph[build_graph.key("item-surface", build_graph.compound_key({item_prototype.name, surface_name}))]
                        for _, dependent in pairs(node_to_old_stay_with_dependents_surface[surface_based_node.name]) do
                            local dependent_node = dep_graph[build_graph.key(dependent.type, dependent.name)]
                            table.insert(dependent_node.prereqs, {
                                type = surface_based_node.type,
                                name = surface_based_node.name
                            })
                            table.insert(surface_based_node.dependents, dependent)
                        end
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
                    for surface_name, _ in pairs(build_graph.surfaces) do
                        local surface_based_node = dep_graph[build_graph.key("item-surface", build_graph.compound_key({item_prototype.name, surface_name}))]
                        
                        for _, dependent in pairs(surface_based_node.dependents) do
                            if blacklist[build_graph.conn_key({surface_based_node, dependent})] then
                                blacklist[build_graph.conn_key({surface_based_node, dependent})] = false
                                sort_state = top_sort.sort(dep_graph, blacklist, sort_state, {surface_based_node, dependent})
                            end
                        end
                    end

                    ind_to_used_in_old_order[old_order_ind_2] = true
                    break
                end
            -- URGENT TODO: I wonder if this is indented too much; it doesn't seem to error if the last thing was where we couldn't find anything, but that just excludes coal so maybe it's fine?
            elseif old_order_ind_2 == #old_order then
                -- We truly couldn't proceed in old_order!
                log(serpent.block(old_order[i]))
                log(i)
                error("Item randomization failed!")
                --return false
            end
        end
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
                            -- DISABLED: Frame count mismatch causes errors (icons have 1 frame, trees expect 3+)
                            --[[
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
                                        variation.leaves.layers[1].frame_count = 1
                                        variation.shadow.frame_count = 2
                                        if variation.normal ~= nil then
                                            variation.normal.frame_count = 1
                                        end
                                        variation.trunk.frame_count = 2
                                    end
                                end
                            end
                            ]]

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