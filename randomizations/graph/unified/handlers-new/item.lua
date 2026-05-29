local rng = require("lib/random/rng")
local locale_utils = require("lib/locale")
local dutils = require("new-lib/data-utils")
local gutils = require("new-lib/graph/graph-utils")

--local simplex_cost = require("lib/cost/simplex-cost")
-- CRITICAL TODO: Depend on modpack
local material_costs = require("lib/cost/material-costs/py-full")

local item = {}

item.id = "item"

item.with_replacement = false

-- Can't include dashes because they act weird on string.find
local trav_suffix = "itemrandotrav"

local function undo_suffix(name)
    assert(string.sub(name, -#trav_suffix, -1) == trav_suffix)
    return string.sub(name, 1, -(#trav_suffix + 1))
end

local sticks_with_trav = {
    pre = {
        ["item"] = true, -- Spoilage untouched
        ["item-deliver"] = true,
        ["item-burn"] = true,
    },
    dep = {
        ["entity-build-item"] = true,
        ["tile-build-item"] = true,
        ["tile-build-item-place-as-tile"] = true,
        ["equipment-place"] = true,
        ["equipment-grid"] = true,
        ["fuel-category"] = true,
        ["item"] = true, -- Same things spoil
        ["item-burn"] = true,
        ["item-launch"] = true,
        ["item-ammo"] = true,
        ["item-capsule"] = true,
        ["item-gun"] = true,
        ["room-create-platform-starter-pack"] = true,
        ["energy-source-burner"] = true, -- Not sure why this doesn't just depend on fuel-category, but not going to check now
        ["science-pack-set-science"] = true,
        -- TODO: Balance nodes?
    },
}

local trav_to_slot
local split_graph
local material_to_cost
item.initialize = function()
    trav_to_slot = nil
    split_graph = nil

    --material_to_cost = simplex_cost.get_material_costs()
    material_to_cost = material_costs.costs
end

item.spoof = function(graph)
    --[[local item_nodes = {}
    for _, node in pairs(graph.nodes) do
        if node.type == "item" then
            table.insert(item_nodes, node)
        end
    end
    for _, node in pairs(item_nodes) do
        local new_node = gutils.add_node(graph, "item", node.name .. trav_suffix)
        new_node.op = "OR"
        new_node.item = node.item
        new_node.trav_item = true
        local to_move = {pre = {}, dep = {}}
        for _, dir in pairs({"pre", "dep"}) do
            for edge_key, _ in pairs(node[dir]) do
                local edge = graph.edges[edge_key]
                local edge_endpoint
                if dir == "pre" then
                    edge_endpoint = graph.nodes[edge.start]
                elseif dir == "dep" then
                    edge_endpoint = graph.nodes[edge.stop]
                end
                if sticks_with_trav[dir][edge_endpoint.type] then
                    table.insert(to_move[dir], edge_key)
                end
            end
        end
        for _, edge_key in pairs(to_move.pre) do
            gutils.redirect_edge_stop(graph, edge_key, new_node)
        end
        for _, edge_key in pairs(to_move.dep) do
            gutils.redirect_edge_start(graph, edge_key, new_node)
        end
        gutils.add_edge(graph, node, new_node)
    end]]
end

item.claim = function(graph, prereq, dep, edge)
    return false
    --[[if prereq.type == "item" and dep.type == "item" and dep.name == prereq.name .. trav_suffix and not prereq.dummy then
        return 1
    end]]
end

item.custom_prereq_search = function(params)
    trav_to_slot = params.trav_to_slot
    split_graph = params.split_graph
end

item.validate = false
--[[item.validate = function(graph, base, head, extra)
    local base_owner = gutils.get_owner(graph, base)
    if base_owner.type == "item" and string.find(base_owner.name, trav_suffix) == nil then
        return true
    end
end]]

item.reflect = function(graph, head_to_base, head_to_handler)
    local changes = {}

    local num_times_changed_graphics_of_simple_entity = {}
    for trav_key, slot_key in pairs(trav_to_slot) do
    --for head_key, base_key in pairs(head_to_base) do
        -- Since items are OR nodes, first pass actually deals with orands
        --[[local slot = split_graph.nodes[split_graph.orand_to_parent[slot_key] ]
        local trav_slot_key = split_graph.nodes[trav_key].old_slot
        local trav = split_graph.nodes[split_graph.orand_to_parent[trav_slot_key] ] ]]
        --local base = graph.nodes[base_key]
        --local head = graph.nodes[head_key]
        --[[if head_to_handler[head_key] == "item" then
            local slot = gutils.get_owner(graph, base)
            local trav = gutils.get_owner(graph, head)]]
        
        local slot = split_graph.nodes[slot_key]
        local trav = split_graph.nodes[trav_key]
        if slot ~= nil and slot.type == "item" then
            local slot_item = dutils.get_prot("item", slot.name)
            local trav_item = dutils.get_prot("item", split_graph.nodes[trav.old_slot].name)
            
            local slot_cost = material_to_cost[gutils.key("item", slot_item.name)]
            local trav_cost = material_to_cost[gutils.key("item", trav_item.name)]
            local multiplier = 1
            if slot_cost ~= nil and trav_cost ~= nil and trav_cost ~= 0 then
                multiplier = math.max(1, math.floor(slot_cost / trav_cost))
            end

            for _, recipe in pairs(data.raw.recipe) do
                -- Fix ingredients/results
                for _, material_property in pairs({"ingredients", "results"}) do
                    if recipe[material_property] ~= nil then
                        for _, ing_or_prod in pairs(recipe[material_property]) do
                            if ing_or_prod.type == "item" and ing_or_prod.name == slot_item.name then
                                table.insert(changes, {
                                    tbl = ing_or_prod,
                                    prop = "name",
                                    new_val = trav_item.name
                                })
                                for _, amount_key in pairs({"amount", "amount_min", "amount_max"}) do
                                    if ing_or_prod[amount_key] ~= nil then
                                        local new_amount = multiplier * ing_or_prod[amount_key]
                                        if not dutils.is_stackable(trav_item) then
                                            new_amount = 1
                                        end
                                        new_amount = math.min(65535, new_amount)
                                        table.insert(changes, {
                                            tbl = ing_or_prod,
                                            prop = amount_key,
                                            new_val = new_amount
                                        })
                                    end
                                end
                            end
                        end
                    end
                end

                local fix_localised = false
                if recipe.results ~= nil and #recipe.results >= 1 and recipe.results[1].name == slot_item.name then
                    -- Fix main product for localisations
                    table.insert(changes, {
                        tbl = recipe,
                        prop = "main_product",
                        new_val = trav_item.name
                    })
                    fix_localised = true
                end
                if recipe.main_product == slot_item.name then
                    table.insert(changes, {
                        tbl = recipe,
                        prop = "main_product",
                        new_val = trav_item.name
                    })
                    fix_localised = true
                end
                if fix_localised then
                    -- Find original recipe prototype from dupes if applicable
                    local orig_recipe = recipe
                    if orig_recipe.orig_name ~= nil then
                        orig_recipe = data.raw.recipe[orig_recipe.orig_name]
                    end
                    --if orig_recipe.localised_name == nil then
                        -- TODO: Should I check recipe-name?
                        table.insert(changes, {
                            tbl = recipe,
                            prop = "localised_name",
                            new_val = locale_utils.find_localised_name(trav_item)
                        })
                    --end
                    -- If the original recipe had no icon, recreate the icon as the new item's
                    if orig_recipe.icons == nil and orig_recipe.icon == nil then
                        local recipe_icons
                        if trav_item.icons ~= nil then
                            table.insert(changes, {
                                tbl = recipe,
                                prop = "icons",
                                new_val = table.deepcopy(trav_item.icons)
                            })
                        else
                            table.insert(changes, {
                                tbl = recipe,
                                prop = "icons",
                                new_val = {
                                    {
                                        icon = trav_item.icon,
                                        icon_size = trav_item.icon_size or 64
                                    }
                                }
                            })
                        end
                    end
                end
            end

            -- Replace loot results
            for _, entity in pairs(dutils.get_all_prots("entity")) do
                if entity.loot ~= nil then
                    for ind_in_loot, loot_entry in pairs(entity.loot) do
                        if loot_entry.item == slot_item.name then
                            table.insert(changes, {
                                tbl = entity.loot[ind_in_loot],
                                prop = "item",
                                new_val = trav_item.name
                            })
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
                                        if result.name == slot_item.name then
                                            table.insert(changes, {
                                                tbl = result,
                                                prop = "name",
                                                new_val = trav_item.name
                                            })
                                            for _, amount_key in pairs({"amount", "amount_min", "amount_max"}) do
                                                if result[amount_key] ~= nil then
                                                    local new_amount = multiplier * result[amount_key]
                                                    if not dutils.is_stackable(trav_item) then
                                                        new_amount = 1
                                                    end
                                                    new_amount = math.min(65535, new_amount)
                                                    table.insert(changes, {
                                                        tbl = result,
                                                        prop = amount_key,
                                                        new_val = new_amount
                                                    })
                                                end
                                            end

                                            has_result = true
                                        end
                                    end
                                elseif entity.minable.result == slot_item.name then
                                    table.insert(changes, {
                                        tbl = entity.minable,
                                        prop = "result",
                                        new_val = trav_item.name
                                    })
                                    local new_count = multiplier * (entity.minable.count or 1)
                                    if not dutils.is_stackable(trav_item) then
                                        new_count = 1
                                    end
                                    table.insert(changes, {
                                        tbl = entity.minable,
                                        prop = "count",
                                        new_val = new_count
                                    })

                                    has_result = true
                                end
                            end

                            if has_result then
                                if entity.type == "resource" and (entity.minable.results == nil or #entity.minable.results == 1) then
                                    entity.localised_name = locale_utils.find_localised_name(trav_item)
                                    entity.stages = {
                                        -- Note: This is technically botched with icons, TODO: Fix
                                        sheets = {
                                            {
                                                variation_count = 1,
                                                filename = trav_item.icon or trav_item.icons[1].icon,
                                                size = trav_item.icon_size or 64,
                                                scale = 0.35,
                                                shift = {0.2, 0.6}
                                            },
                                            {
                                                variation_count = 1,
                                                filename = trav_item.icon or trav_item.icons[1].icon,
                                                size = trav_item.icon_size or 64,
                                                scale = 0.25,
                                                shift = {-0.5, 0.2}
                                            },
                                            {
                                                variation_count = 1,
                                                filename = trav_item.icon or trav_item.icons[1].icon,
                                                size = trav_item.icon_size or 64,
                                                scale = 0.45,
                                                shift = {0, 0}
                                            },
                                            {
                                                variation_count = 1,
                                                filename = trav_item.icon or trav_item.icons[1].icon,
                                                size = trav_item.icon_size or 64,
                                                scale = 0.4,
                                                shift = {-0.2, -0.6}
                                            }
                                        }
                                    }
                                    entity.stage_counts = {entity.stage_counts[1]}
                                    entity.stages_effect = nil
                                end

                                -- TODO: Add back fruit trees!

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
                                                filename = trav_item.icon or trav_item.icons[1].icon,
                                                size = trav_item.icon_size or 64,
                                                scale = 0.25,
                                                tint = {236, 152, 130},
                                                shift = {entity.selection_box[1][1] + selection_box_x_size * shifts[i][1], entity.selection_box[1][2] - (entity.drawing_box_vertical_extension or 0) + selection_box_y_size * shifts[i][2]}
                                            })
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            -- Change trigger techs
            for _, technology in pairs(data.raw.technology) do
                if technology.research_trigger ~= nil then
                    if technology.research_trigger.type == "craft-item" then
                        if technology.research_trigger.item == slot_item.name then
                            table.insert(changes, {
                                tbl = technology.research_trigger,
                                prop = "item",
                                new_val = trav_item.name
                            })
                        end
                        if type(technology.research_trigger.item) == "table" and technology.research_trigger.item.name == slot_item.name then
                            table.insert(changes, {
                                tbl = technology.research_trigger.item,
                                prop = "name",
                                new_val = trav_item.name
                            })
                        end
                    end
                end
            end

            for _, item in pairs(dutils.get_all_prots("item")) do
                -- Replace spoil results (not things that spoil)
                if item.spoil_result == slot_item.name then
                    table.insert(changes, {
                        tbl = item,
                        prop = "spoil_result",
                        new_val = trav_item.name
                    })
                end

                -- Replace burnt fuel results (not things that burn into something)
                if item.burnt_result == slot_item.name then
                    table.insert(changes, {
                        tbl = item,
                        prop = "burnt_result",
                        new_val = trav_item.name
                    })
                end
            end

            -- TODO: Make this check less ad-hoc
            -- If this is a coal replacement, give it a fuel value
            -- Also test for raw coal as a hotfix py replacement
            -- TODO: Just do this for fuel ores in general!
            if slot_item.name == "coal" or slot_item.name == "raw-coal" then
                -- TODO: Need to do something special if this is the only non-chemical fuel, since we just override it to chemical
                if trav_item.fuel_category == nil then
                    trav_item.localised_description = {"", locale_utils.find_localised_description(trav_item), "\n[color=green](Combustible)[/color]"}
                end

                if trav_item.fuel_category ~= "chemical" then
                    trav_item.fuel_category = "chemical"
                    trav_item.fuel_value = "4MJ"
                elseif util.parse_energy(trav_item.fuel_value) < 2000000 then
                    trav_item.fuel_value = "2MJ"
                end

                -- TODO: Figure out a better way to do this
                -- Another py compat hot patch: Make it produce ash to guarantee a good way of getting that
                if slot_item.name == "raw-coal" then
                    -- TODO: More proper error handling/just restart
                    -- If trav already had a (possibly important) burnt result, then just give up (very unlikely)
                    if trav_item.burnt_result ~= nil and trav_item.burnt_result ~= "ash" then
                        error("Burnt result collision for raw coal replacement!")
                    end
                    
                    trav_item.burnt_result = "ash"
                end
            end
        end
    end

    for _, change in pairs(changes) do
        change.tbl[change.prop] = change.new_val
    end
end

return item