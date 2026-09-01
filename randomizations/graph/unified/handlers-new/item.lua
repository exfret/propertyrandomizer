local constants = require("helper-tables/constants")
local rng = require("lib/random/rng")
local locale_utils = require("lib/locale")
local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/consistent-sort")

local base_costs = require("lib/cost/material-costs/sa")
local py_costs = require("lib/cost/material-costs/py-full")

local material_costs = base_costs
if mods["pypostprocessing"] then
    material_costs = py_costs
end

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

local slot_to_trav
local trav_to_slot
local split_graph
local material_to_cost
local orig_graph
local node_science_level
local py_scaling = { -- Roughly in GW expected for an "average" base, but the ratios are what matter anyways
    0.1, -- pre-auto
    0.2, -- auto
    0.5, -- py1
    1, -- logi
    3, -- py2
    10, -- chem
    20, -- py3
    50, -- prod
    100, -- py4
    200, -- utility
    300, -- space
}
item.initialize = function()
    slot_to_trav = nil
    trav_to_slot = nil
    split_graph = nil
    material_to_cost = material_costs.costs
    orig_graph = nil
    node_science_level = {}
end

item.spoof = function(graph)
    -- Just calculate recipe levels here
    -- Only used for pyanodons power balancing
    orig_graph = table.deepcopy(graph)
    local orig_graph_sort = top.sort(orig_graph)
    --local science_inds = {}
    -- Assume linear sciences (this is only for py anyways)
    local num_science_packs = 0
    local already_checked_science = {}
    for ind, pebble in pairs(orig_graph_sort.sorted) do
        local node = orig_graph.nodes[pebble.node_key]
        if node.type == "item" and node.name ~= "military-science-pack" then
            node_science_level[pebble.node_key] = num_science_packs
            local is_science_pack = false
            for _, lab in pairs(data.raw.lab) do
                for _, input in pairs(lab.inputs) do
                    if input == node.name then
                        is_science_pack = true
                    end
                end
            end
            if is_science_pack and not already_checked_science[pebble.node_key] then
                already_checked_science[pebble.node_key] = true
                num_science_packs = 1 + num_science_packs
                --science_inds[ind] = true
            end
        end
    end
    --[[for ind, pebble in pairs(orig_graph_sort.sorted) do
        local node = orig_graph.nodes[pebble.node_key]
        if node.type == "item" then
            local path_info = top.path(orig_graph, {ind}, orig_graph_sort)
            local num_sciences_required = 0
            for science_ind, _ in pairs(science_inds) do
                if path_info.in_path[science_ind] then
                    num_sciences_required = 1 + num_sciences_required
                end
            end
            if node_science_level[pebble.node_key] == nil then
                node_science_level[pebble.node_key] = num_sciences_required
            end
        end
    end]]
    
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
    slot_to_trav = params.slot_to_trav
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

local function get_primary_icon(prot)
    if prot.icon ~= nil then
        return prot.icon, prot.icon_size or 64
    end

    if prot.icons ~= nil and prot.icons[1] ~= nil then
        local icon = prot.icons[1]
        return icon.icon, icon.icon_size or prot.icon_size or 64
    end

    error("Prototype has no usable icon: " .. tostring(prot.name))
end

item.reflect = function(graph, head_to_base, head_to_handler)
    local is_spoil_or_burnt_result = {}
    for class, _ in pairs(defines.prototypes.item) do
        for _, item in pairs(data.raw[class] or {}) do
            if item.spoil_result ~= nil then
                is_spoil_or_burnt_result[item.spoil_result] = true
            end
            if item.burnt_result ~= nil then
                is_spoil_or_burnt_result[item.burnt_result] = true
            end
        end
    end

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

            local function is_useless_item(item)
                if item.type ~= "item" then
                    return false
                end
                if item.fuel_value ~= nil and util.parse_energy(item.fuel_value) ~= 0 then
                    return false
                end
                if item.place_result ~= nil or item.plant_result ~= nil or item.place_as_tile ~= nil or item.place_as_equipment_result ~= nil then
                    return false
                end
                if item.spoil_result ~= nil then
                    return false
                end
                if is_spoil_or_burnt_result[item.name] then
                    return false
                end
                local is_science_pack
                for _, lab in pairs(data.raw.lab) do
                    for _, input in pairs(lab.inputs) do
                        if input == item.name then
                            return false
                        end
                    end
                end
                if item.rocket_launch_products ~= nil then
                    return false
                end
                return true
            end

            local trav_trav = split_graph.nodes[slot_to_trav[trav.old_slot]]
            local trav_trav_item = dutils.get_prot("item", split_graph.nodes[trav_trav.old_slot].name)
            if is_useless_item(trav_trav_item) and is_useless_item(trav_item) then
                -- Don't actually do the switch in this case
            else
                if is_useless_item(trav_item) then
                    -- Back up slot until we get something that would have had a useless trav in it
                    local curr_trav_slot = split_graph.nodes[trav_trav.old_slot]
                    while true do
                        local curr_trav_slot_item = dutils.get_prot("item", curr_trav_slot.name)
                        local curr_trav_slot_trav = split_graph.nodes[slot_to_trav[gutils.key(curr_trav_slot)]]
                        local curr_trav_slot_trav_item = dutils.get_prot("item", split_graph.nodes[curr_trav_slot_trav.old_slot].name)
                        if is_useless_item(curr_trav_slot_trav_item) then
                            log(trav_item.name .. " NOW WITH " .. slot_item.name)
                            slot_item = curr_trav_slot_item
                            break
                        else
                            curr_trav_slot = split_graph.nodes[curr_trav_slot_trav.old_slot]
                        end
                    end
                end
                if mods["pypostprocessing"] then
                    if trav_item.place_result ~= nil then
                        local energy_factor = py_scaling[1 + node_science_level[gutils.key("item", slot_item.name)]] / py_scaling[1 + node_science_level[gutils.key("item", trav_item.name)]]
                        -- Be less punishing when making the energy costs *higher*
                        if energy_factor > 1 then
                            energy_factor = math.max(energy_factor / 10, 1)
                        end
                        local entity = dutils.get_prot("entity", trav_item.place_result)
                        -- Focus only on energy_usage; that's the problematic part that absolutely needed to be changed and let's just let the rest be random as possible
                        for _, property in pairs({"energy_usage"}) do--, "power", "max_power_output", "power_input", "consumption", "energy_production"}) do
                            if entity[property] ~= nil then
                                local curr_usage = 60 * util.parse_energy(entity[property])
                                curr_usage = energy_factor * curr_usage
                                entity[property] = tostring(curr_usage) .. "W"
                            end
                        end
                    end
                end
                
                local slot_cost = material_to_cost[gutils.key("item", slot_item.name)]
                local trav_cost = material_to_cost[gutils.key("item", trav_item.name)]
                local multiplier = 1
                local exact_multiplier = 1
                if slot_cost ~= nil and trav_cost ~= nil and trav_cost ~= 0 then
                    multiplier = math.max(1, math.floor(slot_cost / trav_cost))
                    exact_multiplier = math.max(1, slot_cost / trav_cost)
                end

                for _, recipe in pairs(data.raw.recipe) do
                    local function dont_process_recipe(recipe)
                        -- Try just checking recipe's dont_randomize property
                        -- Needs handling in first pass as well
                        -- CRITICAL TODO (need this so we don't get like slaughterhouse recipes with confusing names)
                        return false
                    end

                    if not dont_process_recipe(recipe) then
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
                                                table.insert(changes, {
                                                    tbl = ing_or_prod,
                                                    prop = amount_key,
                                                    multiplier = exact_multiplier,
                                                    is_ing_or_result = true,
                                                    ingredients = (material_property == "ingredients"),
                                                    recipe = recipe,
                                                })
                                            end
                                        end
                                    end
                                end
                            end
                        end

                        local fix_localised = false
                        if recipe.main_product == slot_item.name or (recipe.results ~= nil and #recipe.results >= 1 and recipe.results[1].name == slot_item.name) then
                            table.insert(changes, {
                                tbl = recipe,
                                prop = "main_product",
                                new_val = trav_item.name
                            })
                            fix_localised = true
                        end
                        -- If this is a weird recipe, like it has dont_randomize, then I think that's a good signal not to change the name and icons
                        local recipe_node = split_graph.nodes[gutils.key("recipe", recipe.name)]
                        if recipe_node.dont_randomize then
                            log("IT WORKED")
                            fix_localised = false
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
                                    new_val = {"", constants.funny_recipe_prefixes[rng.int(rng.key({id = "unified-item"}), #constants.funny_recipe_prefixes)], " ", locale_utils.find_localised_name(trav_item)}
                                })
                            --end
                            -- If the original recipe had no icon, recreate the icon as the new item's
                            --if orig_recipe.icons == nil and orig_recipe.icon == nil then
                                local recipe_icons
                                if trav_item.icons ~= nil then
                                    table.insert(changes, {
                                        tbl = recipe,
                                        prop = "icons",
                                        new_val = table.deepcopy(trav_item.icons)
                                    })
                                else
                                    local icon_filename, icon_size = get_primary_icon(trav_item)
                                    table.insert(changes, {
                                        tbl = recipe,
                                        prop = "icons",
                                        new_val = {
                                            {
                                                icon = icon_filename,
                                                icon_size = icon_size
                                            }
                                        }
                                    })
                                end
                            --end
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
                                        local icon_filename, icon_size = get_primary_icon(trav_item)
                                        entity.stages = {
                                            -- Note: This is technically botched with icons, TODO: Fix
                                            sheets = {
                                                {
                                                    variation_count = 1,
                                                    filename = icon_filename,
                                                    size = icon_size,
                                                    scale = 0.35,
                                                    shift = {0.2, 0.6}
                                                },
                                                {
                                                    variation_count = 1,
                                                    filename = icon_filename,
                                                    size = icon_size,
                                                    scale = 0.25,
                                                    shift = {-0.5, 0.2}
                                                },
                                                {
                                                    variation_count = 1,
                                                    filename = icon_filename,
                                                    size = icon_size,
                                                    scale = 0.45,
                                                    shift = {0, 0}
                                                },
                                                {
                                                    variation_count = 1,
                                                    filename = icon_filename,
                                                    size = icon_size,
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
                                                local icon_filename, icon_size = get_primary_icon(trav_item)
                                                table.insert(entity.lower_pictures[j].layers, {
                                                    filename = icon_filename,
                                                    size = icon_size,
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
                if (not mods["pypostprocessing"] and slot_item.name == "coal") or (mods["pypostprocessing"] and slot_item.name == "raw-coal") then
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
    end
end

return item