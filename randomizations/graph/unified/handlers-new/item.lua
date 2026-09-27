local constants = require("helper-tables/constants")
local rng = require("lib/random/rng")
local locale_utils = require("lib/locale")
local dupe = require("lib/dupe")
local recycling_sources = require("lib/logic/recycling-sources")
local dutils = require("lib/data-utils")
local gutils = require("lib/graph/graph-utils")
local item_fluid = require("lib/item-fluid")
local top = require("lib/graph/context-sort")

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
local mechanics_sets_to_ordered
local mechanics_sets_to_nodes
local trav_to_mechanics_key
local material_to_cost
local orig_graph
local node_science_level
-- Recipe name --> the product reflect made it named after, as {type, name}
local renamed_recipes
-- Fluid position name --> name of the fluid identity there, for required fluids (see after_changes)
local required_fluid_renames
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
    mechanics_sets_to_ordered = nil
    mechanics_sets_to_nodes = nil
    trav_to_mechanics_key = nil
    material_to_cost = material_costs.costs
    orig_graph = nil
    node_science_level = {}
    renamed_recipes = {}
    required_fluid_renames = {}
    -- What reflect renames, for checks comparing the final game with the original (see item_fluid.final_node_key), or nil if it didn't run
    UNIFIED_MATERIAL_RENAMES = nil
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
    mechanics_sets_to_ordered = params.mechanics_sets_to_ordered
    mechanics_sets_to_nodes = params.mechanics_sets_to_nodes
    trav_to_mechanics_key = params.trav_to_mechanics_key
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
    dutils.recalculate_spoil_burnt_results()

    -- Order mk's to go in order (solves certain cost problems)

    -- Position material key --> the identity reflect put there, as {type, name} (see lib/item-fluid.lua)
    local new_identity_at = {}

    local num_times_changed_graphics_of_simple_entity = {}
    -- Position material key --> material key of the identity first pass assigned there, for items and fluids (see lib/item-fluid.lua)
    local identity_at = {}
    for slot_key, trav_key in pairs(slot_to_trav) do
        local slot = split_graph.nodes[slot_key]
        if slot ~= nil then
            local position = item_fluid.material_of_node(split_graph, slot)
            local identity = item_fluid.material_of_node(split_graph, split_graph.nodes[trav_key])
            if position ~= nil and identity ~= nil then
                identity_at[item_fluid.material_key(position)] = item_fluid.material_key(identity)
            end
        end
    end
    local is_useless = item_fluid.useless_predicate(identity_at)
    UNIFIED_MATERIAL_RENAMES = {}
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
        -- Item and fluid positions, as {type, name}; others (entity positions) are the entity handler's
        local position = slot ~= nil and item_fluid.material_of_node(split_graph, slot) or nil
        local identity = item_fluid.material_of_node(split_graph, trav)
        if position ~= nil and identity ~= nil then
            -- Useless items aren't swapped with each other, so a useless identity can go to a different position (see dutils.reflected_item_position, which first pass models too)
            local reflected_position = dutils.reflected_item_position(identity_at, item_fluid.material_key(position), item_fluid.material_key(identity), is_useless)
            if reflected_position == nil then
                -- Don't actually do the switch in this case
            else
                if reflected_position ~= item_fluid.material_key(position) then
                    log(identity.name .. " NOW WITH " .. position.name)
                    position = gutils.deconstruct(reflected_position)
                end
                -- The prototypes of the position's own material and of the identity, each in its old form
                local slot_item = item_fluid.prot(position)
                local trav_item = item_fluid.prot(identity)
                local changes_form = position.type ~= identity.type

                new_identity_at[item_fluid.material_key(position)] = identity
                UNIFIED_MATERIAL_RENAMES[item_fluid.material_key(position)] = identity

                -- An identity at a position of the other form becomes that form: it gets a prototype of it with its own name and look, and its old one is made nowhere now (see lib/item-fluid.lua)
                if changes_form then
                    local new_prot
                    if position.type == "fluid" then
                        new_prot = item_fluid.fluid_from_item(trav_item, slot_item)
                    else
                        new_prot = item_fluid.item_from_fluid(trav_item, slot_item)
                    end
                    data:extend({ new_prot })
                    trav_item.hidden = true
                    trav_item.hidden_in_factoriopedia = true
                    log(identity.name .. " becomes a " .. position.type .. " at " .. position.name .. "'s position")
                end

                if mods["pypostprocessing"] and not changes_form and position.type == "item" then
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

                    if slot_item.name == "ash" then
                        trav_item.stack_size = 1000
                    end
                end

                -- Find cost relative to position where this satisfies a mechanic, not the "actual" cost, which could be inflated too early in the game
                -- Only a position of the identity's own form has a comparable cost (an item's and a fluid's units differ)
                -- A trav the final sort doesn't reach has no such position, and then its cost isn't known (no multiplier)
                local trav_mechanics_key = trav_to_mechanics_key[gutils.key(trav)]
                local trav_rank = (mechanics_sets_to_nodes[trav_mechanics_key] or {})[gutils.key(trav)]
                local to_use_for_trav_cost
                if trav_rank ~= nil then
                    to_use_for_trav_cost = split_graph.nodes[mechanics_sets_to_ordered[trav_mechanics_key][trav_rank]]
                end
                local trav_cost_material
                if config.item_fluids and to_use_for_trav_cost ~= nil then
                    trav_cost_material = item_fluid.material_of_node(split_graph, to_use_for_trav_cost)
                end

                local slot_cost = material_to_cost[item_fluid.material_key(position)]
                local trav_cost
                if not config.item_fluids then
                    -- As before items and fluids traded positions
                    if to_use_for_trav_cost ~= nil then
                        trav_cost = material_to_cost[gutils.key("item", to_use_for_trav_cost.name)]
                    end
                elseif trav_cost_material ~= nil and trav_cost_material.type == identity.type then
                    trav_cost = material_to_cost[item_fluid.material_key(trav_cost_material)]
                end
                local multiplier = 1
                local exact_multiplier = 1
                -- An identity changing form takes its new position's amounts as they are
                if not changes_form and slot_cost ~= nil and trav_cost ~= nil and trav_cost ~= 0 then
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
                    local function dont_process_recipe_ings(recipe)
                        if string.find(recipe.name, "pyvoid") then
                            return true
                        end
                        return false
                    end

                    if not dont_process_recipe(recipe) then
                        -- Fix ingredients/results
                        for _, material_property in pairs({"ingredients", "results"}) do
                            if not (material_property == "ingredients" and dont_process_recipe_ings(recipe)) then
                                if recipe[material_property] ~= nil then
                                    for _, ing_or_prod in pairs(recipe[material_property]) do
                                        if ing_or_prod.type == position.type and ing_or_prod.name == position.name then
                                            table.insert(changes, {
                                                tbl = ing_or_prod,
                                                prop = "name",
                                                new_val = trav_item.name
                                            })
                                            -- Temperatures were the position's fluid's; another fluid there has its own
                                            if position.type == "fluid" and trav_item.name ~= position.name then
                                                for _, temperature_key in pairs({"temperature", "minimum_temperature", "maximum_temperature"}) do
                                                    if ing_or_prod[temperature_key] ~= nil then
                                                        table.insert(changes, {
                                                            tbl = ing_or_prod,
                                                            prop = temperature_key,
                                                            new_val = nil,
                                                        })
                                                    end
                                                end
                                            end
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
                        end

                        -- Only a recipe named after this item gets renamed; one with several products and no main product keeps its own name
                        -- Recycling recipes are named after what they recycle instead, and fixes.lua renames them after all item randomization
                        local main_product = dutils.recipe_main_product(recipe)
                        local fix_localised = main_product ~= nil and main_product.type == position.type and main_product.name == position.name
                            and recycling_sources.named_after_ingredient(old_data_raw.recipe, recipe.name) == nil
                        if recipe.main_product == position.name and main_product ~= nil and main_product.type == position.type then
                            table.insert(changes, {
                                tbl = recipe,
                                prop = "main_product",
                                new_val = trav_item.name
                            })
                        end
                        -- If this is a weird recipe, like it has dont_randomize, then I think that's a good signal not to change the name and icons
                        local recipe_node = split_graph.nodes[gutils.key("recipe", recipe.name)]
                        if recipe_node.dont_randomize then
                            fix_localised = false
                        end
                        if fix_localised then
                            -- Find original recipe prototype from dupes if applicable
                            local orig_recipe = recipe
                            if orig_recipe.orig_name ~= nil then
                                orig_recipe = data.raw.recipe[orig_recipe.orig_name]
                            end
                            orig_recipe.subgroup = nil
                            orig_recipe.order = nil
                            -- Named in after_changes, once it's known how many recipes share the item
                            renamed_recipes[recipe.name] = {
                                type = position.type,
                                name = trav_item.name,
                            }
                        end
                    end
                end

                -- Replace loot results (always items)
                for _, entity in pairs(dutils.get_all_prots("entity")) do
                    if position.type == "item" and entity.loot ~= nil then
                        for ind_in_loot, loot_entry in pairs(entity.loot) do
                            -- Loot entries name their item with "name" in 2.0 (older data used "item")
                            local loot_item_prop = loot_entry.name ~= nil and "name" or "item"
                            if loot_entry[loot_item_prop] == slot_item.name then
                                table.insert(changes, {
                                    tbl = entity.loot[ind_in_loot],
                                    prop = loot_item_prop,
                                    new_val = trav_item.name,
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
                            -- Don't replace entities that are player creations, so that you still get the buildings back you place down (first pass models these results the same way)
                            if not dutils.mining_keeps_item_names(entity) then
                                local has_result = false

                                if entity.minable ~= nil then
                                    if entity.minable.results ~= nil then
                                        for _, result in pairs(entity.minable.results) do
                                            if (result.type or "item") == position.type and result.name == position.name then
                                                table.insert(changes, {
                                                    tbl = result,
                                                    prop = "name",
                                                    new_val = trav_item.name
                                                })
                                                -- As for recipes, another fluid there comes out at its own temperature
                                                if position.type == "fluid" and trav_item.name ~= position.name and result.temperature ~= nil then
                                                    table.insert(changes, {
                                                        tbl = result,
                                                        prop = "temperature",
                                                        new_val = nil,
                                                    })
                                                end
                                                for _, amount_key in pairs({"amount", "amount_min", "amount_max"}) do
                                                    if result[amount_key] ~= nil then
                                                        local new_amount = multiplier * result[amount_key]
                                                        if position.type == "item" and not dutils.is_stackable(trav_item) then
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
                                    elseif position.type == "item" and entity.minable.result == position.name then
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

                -- Change trigger techs (crafting an item for item positions, a fluid for fluid positions)
                for _, technology in pairs(data.raw.technology) do
                    if technology.research_trigger ~= nil then
                        if position.type == "fluid" and technology.research_trigger.type == "craft-fluid" and technology.research_trigger.fluid == position.name then
                            table.insert(changes, {
                                tbl = technology.research_trigger,
                                prop = "fluid",
                                new_val = trav_item.name,
                            })
                        end
                        if position.type == "item" and technology.research_trigger.type == "craft-item" then
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

                -- Fluid positions are also what tiles pump, what filtered offshore pumps make, and what resources need to be mined (the last after every handler reflected, see after_changes)
                if position.type == "fluid" then
                    for _, tile in pairs(dutils.prots("tile")) do
                        if tile.fluid == position.name then
                            table.insert(changes, {
                                tbl = tile,
                                prop = "fluid",
                                new_val = trav_item.name,
                            })
                        end
                    end
                    for _, pump in pairs(dutils.prots("offshore-pump")) do
                        if pump.fluid_box ~= nil and pump.fluid_box.filter == position.name then
                            table.insert(changes, {
                                tbl = pump.fluid_box,
                                prop = "filter",
                                new_val = trav_item.name,
                            })
                        end
                    end
                    required_fluid_renames[position.name] = trav_item.name
                end

                for _, item in pairs(dutils.get_all_prots("item")) do
                    -- Replace spoil results (not things that spoil), which are always items
                    if position.type == "item" and item.spoil_result == slot_item.name then
                        table.insert(changes, {
                            tbl = item,
                            prop = "spoil_result",
                            new_val = trav_item.name
                        })
                    end

                    -- Replace burnt fuel results (not things that burn into something), which are always items
                    if position.type == "item" and item.burnt_result == slot_item.name then
                        table.insert(changes, {
                            tbl = item,
                            prop = "burnt_result",
                            new_val = trav_item.name
                        })
                    end
                end

                -- Whatever replaces coal always becomes a fuel of coal's category, so it still fuels what coal did (first pass relies on this, see dutils.replacement_gets_fuel)
                -- First pass only puts items there (its pair_ok)
                if position.type == "item" and identity.type == "item" and dutils.replacement_gets_fuel(slot_item.name) then
                    local description = locale_utils.find_localised_description(trav_item)
                    if dutils.give_replacement_fuel(trav_item) then
                        trav_item.localised_description = {"", description, "\n[color=green](Combustible)[/color]"}
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

    -- Change single-resource mining drills to be named after their new item or fluid
    for _, drill in pairs(data.raw["mining-drill"]) do
        if #drill.resource_categories == 1 then
            -- Material key of what the resource gives
            local unique_resource
            local not_unique = false
            for _, resource in pairs(data.raw.resource) do
                if resource.category ~= nil and resource.category == drill.resource_categories[1] then
                    if unique_resource ~= nil then
                        not_unique = true
                    end
                    if resource.minable ~= nil then
                        if resource.minable.result ~= nil then
                            unique_resource = gutils.key("item", resource.minable.result)
                        elseif resource.minable.results ~= nil and #resource.minable.results == 1 then
                            unique_resource = gutils.key(resource.minable.results[1].type or "item", resource.minable.results[1].name)
                        else
                            not_unique = true
                        end
                    else
                        not_unique = true
                    end
                end
            end
            if not not_unique and unique_resource ~= nil then
                local new_identity = new_identity_at[unique_resource]
                if new_identity ~= nil then
                    -- In the position's form (an identity that changed form has a prototype of it now)
                    local new_item = item_fluid.prot({
                        type = gutils.deconstruct(unique_resource).type,
                        name = new_identity.name,
                    })
                    local suffix = ""
                    if string.len(drill.name) >= 4 then
                        local old_suffix = string.sub(drill.name, -4, -1)
                        if string.sub(old_suffix, 1, 2) == "mk" then
                            suffix = " " .. old_suffix
                        end
                    end
                    drill.localised_name = {"", locale_utils.find_localised_name(new_item), " mine", suffix}
                end
            end
        end
    end
end

-- Renamed recipes take their new item's name and icon, since they may have had their own
-- When several recipes are named after the same item, the renamed ones also get a prefix and a number badge to tell them apart
item.after_changes = function()
    -- Resources need whatever fluid is made at their required fluid's position now: reflect renames fluid positions everywhere else, and mining-fluid-required's reflection also writes positions (see lib/item-fluid.lua)
    -- Done here, once every handler has reflected
    for _, resource in pairs(dutils.prots("resource")) do
        if resource.minable ~= nil and resource.minable.required_fluid ~= nil and required_fluid_renames[resource.minable.required_fluid] ~= nil then
            resource.minable.required_fluid = required_fluid_renames[resource.minable.required_fluid]
        end
    end

    -- Product material key --> how many recipes are named after it, counting ones reflect didn't rename (recycling recipes are named after what they recycle)
    local num_named_after = {}
    for recipe_name, recipe in pairs(data.raw.recipe) do
        local main_product = dutils.recipe_main_product(recipe)
        if main_product ~= nil and (main_product.type == "item" or main_product.type == "fluid") and recycling_sources.named_after_ingredient(old_data_raw.recipe, recipe_name) == nil then
            local product_key = gutils.key(main_product.type, main_product.name)
            num_named_after[product_key] = (num_named_after[product_key] or 0) + 1
        end
    end

    local recipe_names = {}
    for recipe_name, _ in pairs(renamed_recipes) do
        table.insert(recipe_names, recipe_name)
    end
    table.sort(recipe_names)
    -- Product material key --> how many of its renamed recipes have been numbered so far
    local num_numbered = {}
    for _, recipe_name in pairs(recipe_names) do
        local recipe = data.raw.recipe[recipe_name]
        local product_key = gutils.key(renamed_recipes[recipe_name].type, renamed_recipes[recipe_name].name)
        -- The product's prototype in its position's form (an identity that changed form has one now)
        local new_item = item_fluid.prot(renamed_recipes[recipe_name])
        local recipe_icons
        if new_item.icons ~= nil then
            recipe_icons = table.deepcopy(new_item.icons)
        else
            local icon_filename, icon_size = get_primary_icon(new_item)
            recipe_icons = {
                {
                    icon = icon_filename,
                    icon_size = icon_size,
                },
            }
        end
        if (num_named_after[product_key] or 0) >= 2 then
            recipe.localised_name = {"", constants.funny_recipe_prefixes[rng.int(rng.key({id = "unified-item"}), #constants.funny_recipe_prefixes)], " ", locale_utils.find_localised_name(new_item)}
            num_numbered[product_key] = (num_numbered[product_key] or 0) + 1
            -- Only single digit badges exist, so any past that keep the plain item icon
            if num_numbered[product_key] <= dupe.max_icon_number then
                table.insert(recipe_icons, dupe.recipe_number_icon(num_numbered[product_key]))
            end
        else
            recipe.localised_name = locale_utils.find_localised_name(new_item)
        end
        recipe.icon = nil
        recipe.icons = recipe_icons
    end
end

return item
