local constants = require("helper-tables/constants")
local build_graph = require("lib/graph/build-graph")
local graph_utils = require("lib/graph/graph-utils")
local rng = require("lib/random/rng")
local dupe = require("lib/dupe")
local helper = require("randomizations/graph/unified/helper")

local recipe_results = {}

local state = {}
recipe_results.state = state
recipe_results.init = function(state)
    for k, v in pairs(state) do
        recipe_results.state[k] = v
    end
end

recipe_results.source_types = {
    ["recipe-surface"] = true
}
recipe_results.target_types = {
    ["craft-material-surface"] = true
}
recipe_results.group_surfaces = true

recipe_results.add_dummies = function()
    -- Ideas for more slots:
    -- If a recipe alread produces multiple outputs, it might make sense to add another (though we'd still need a way to balance things)
    -- When we add more randomizations there will be more slots for items, but we also need automated slots like these not just mining rocks etc.
    -- Let's just "duplicate" every recipe that produces exactly one boring item or a fluid
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.results ~= nil and #recipe.results == 1 and recipe.results[1].name == recipe.name then
            -- Don't add too many dummies
            if rng.value(rng.key({id = "add-dummies"})) < constants.unified_recipe_results_dummy_fraction then
                local result = recipe.results[1]
                --if result.type == "fluid" or helper.is_boring_item(helper.items[result.name]) then
                    -- Just need to create the craft-material and craft-material-surface nodes, and the recipe and recipe-surface nodes, and I guess those should get separate tech unlocks?
                    -- I wonder if it would be easier to just modify data.raw and rebuild the dependency graph, but let's go with this way for now
                    local node_set = {}
                    table.insert(node_set, graph_utils.getk("craft-material", result.type .. "-" .. result.name))
                    table.insert(node_set, graph_utils.getk("recipe", recipe.name))
                    table.insert(node_set, graph_utils.getk("recipe-tech-unlock", recipe.name))
                    
                    local orig_to_new = helper.copy_node_set(node_set, "recipe-results-dummy")
                    -- Remove dependencies from old craft-material nodes to technologies (so that trigger effects don't require the dummies)
                    for _, new_node in pairs(orig_to_new) do
                        if new_node.type == "craft-material" or new_node.type == "craft-material-surface" then
                            local dep_nodes_to_remove = {}
                            for _, dep in pairs(new_node.dependents) do
                                if dep.type == "technology" then
                                    table.insert(dep_nodes_to_remove, graph_utils.get(dep))
                                end
                            end
                            for _, node_to_remove in pairs(dep_nodes_to_remove) do
                                graph_utils.remove_prereq(new_node, node_to_remove)
                            end
                        end
                    end
                    -- Note: In our case, dummy nodes are always copies and have node.original, so we'll be taking advantage of that, but we can't always
                    -- In particular, if we deal with other node types like in data.raw reflection we must keep in mind that dummy does not imply copy

                    -- Data.raw/rando notes:
                    -- We need to change how we modify data.raw to add in these dummy recipes (and potentially remove recipes) if necessary
                    -- OH OH, and a way to make sure the dummy results don't crowd everything out (maybe we can somehow just exclude them)
                    -- We might ALSO want to put the dummy slots at the end of the sort or something such so that they're also not preferred (or maybe scattered throughout?)
                --end
            end
        end
    end
end

recipe_results.create_slot = function(edge)
    local function find_result_index(recipe_name, material_name)
        local result_index
        local multiple_valid_results = false
        for ind, result in pairs(data.raw.recipe[recipe_name].results) do
            if result.type == helper.get_material_type(material_name) and result.name == helper.get_material_name(material_name) then
                if result_index ~= nil then
                    multiple_valid_results = true
                    break
                end
                result_index = ind
            end
        end
        if multiple_valid_results then
            return false
        end
        return result_index
    end

    -- TODO: Clean this up with helper functions
    -- Get the material
    -- Check that the result stacks
    local material = edge[2].material
    if material == "dummy" then
        material = dep_graph[edge[2].original].material
    end
    if helper.get_material_type(material) == "item" then
        local item_prototype = helper.items[helper.get_material_name(material)]
        local stackable = true
        if item_prototype.flags ~= nil then
            for _, flag in pairs(item_prototype.flags) do
                if flag == "not-stackable" then
                    stackable = false
                end
            end
        end
        if not stackable or item_prototype.equipment_grid ~= nil then
            return false
        end
    end

    -- Case of a dummy slot
    -- By construction, they're constructed last (we put them later in the topological sort), so we can assume ind for the original node is known
    if edge[1].dummy then
        local original_recipe_name = dep_graph[edge[1].original].recipe
        -- In this case, traveler will also be dummy for us
        local result_index = find_result_index(original_recipe_name, dep_graph[edge[2].original].material)
        if not result_index then
            return false
        end
        return {
            recipe = "dummy",
            original_recipe = original_recipe_name,
            -- ind in original
            ind = result_index,
            trigger_techs = {},
        }
    end

    -- These special checks don't need to apply to dummies
    -- Stone furnace is just so important; don't randomize it
    if helper.get_material_type(material) == "item" and helper.get_material_name(material) == "stone-furnace" then
        return false
    end
    -- Don't do recycling recipes
    if data.raw.recipe[edge[1].recipe].category == "recycling" then
        return false
    end

    -- Store trigger techs to change
    local trigger_techs = {}
    for _, technology in pairs(data.raw.technology) do
        if technology.research_trigger ~= nil and technology.research_trigger.type == "craft-item" and "item" == helper.get_material_type(material) and technology.research_trigger.item == helper.get_material_name(material) then
            table.insert(trigger_techs, technology)
        end
        if technology.research_trigger ~= nil and technology.research_trigger.type == "craft-fluid" and "fluid" == helper.get_material_type(material) and technology.research_trigger.fluid == helper.get_material_name(material) then
            table.insert(trigger_techs, technology)
        end
    end

    local result_index = find_result_index(edge[1].recipe, edge[2].material)
    if result_index == nil then
        return false
    end
    return {
        recipe = edge[1].recipe,
        ind = result_index,
        trigger_techs = trigger_techs,
    }
end

-- CRITICAL TODO:
--  * Check that traveler can stack (so that revising costs works)
--  * Check fluid outputs and compatibility with crafting categories
--  * Don't do recycling recipes
recipe_results.create_traveler = function(edge)
    local item
    local fluid
    if helper.get_material_type(edge[2].material) == "item" then
        item = helper.get_material_name(edge[2].material)
    else
        fluid = helper.get_material_name(edge[2].material)
    end
    return {
        -- get_material_type and get_material_name account for dummies
        material_type = helper.get_material_type(edge[2].material),
        material_name = helper.get_material_name(edge[2].material),
        -- Note that one of these will be nil (depending on whether it's actually an item or a fluid)
        -- They could also be dummy, but will at least be non-nil
        item = item,
        fluid = fluid,
    }
end

recipe_results.to_canonical = function(slot_or_traveler)
    if slot_or_traveler.dummy then
        -- In our case, that means we're a duplicate
        return "dummy"
    end

    if slot_or_traveler.connector_type == "slot" then
        return graph_utils.getk("recipe", slot_or_traveler.recipe)
    elseif slot_or_traveler.connector_type == "traveler" then
        if slot_or_traveler.material_type == "item" then
            return graph_utils.getk("item", slot_or_traveler.material_name)
        else
            return graph_utils.getk("fluid", slot_or_traveler.material_name)
        end
    end
end

-- What is not an important node that we can probably replace?
recipe_results.is_reservable = function(slot)
    if slot.dummy then
        return true
    end

    -- Reservable in this case simply if no surface version is critical
    -- TODO: Should I check for the non-surface-specific node too?
    local slot_node = recipe_results.to_canonical(slot)
    local corresponding_nodes = helper.get_surface_variants(slot_node)
    table.insert(corresponding_nodes, slot_node)
    for _, node in pairs(corresponding_nodes) do
        if recipe_results.state.is_critical[graph_utils.get_node_key(node)] then
            return false
        end
    end
    return true
end

-- What is likely to progress us/fix our problems?
recipe_results.traveler_priority = function(traveler)
    -- I'm too exhausted to do anything fancier for now
    -- Note that find_priority in helper accounts for dummy
    return helper.find_priority(traveler, recipe_results.state)
end

-- For connection validations, mostly just checking that things are of the right types
recipe_results.validate_connection = function(slot, traveler)
    -- Note: We need to be able to check any item/fluid like traveler node, and this breaks reconnection logic

    -- Make sure this is a craftable (item or fluid)
    if traveler.item == nil and traveler.fluid == nil then
        return false
    end

    local recipe_prot = data.raw.recipe[slot.recipe]
    if recipe_prot == nil then
        recipe_prot = data.raw.recipe[slot.original_recipe]
    end
    if traveler.fluid ~= nil and not (recipe_prot.category == "oil-processing" or recipe_prot.category == "chemistry" or recipe_prot.category == "crafting-with-fluid") then
        return false
    end
    -- Only replace fluids with fluids
    if traveler.fluid ~= nil and recipe_prot.results[slot.ind].type == "item" then
        return false
    end
    if traveler.fluid == nil and recipe_prot.results[slot.ind].type == "fluid" then
        return false
    end

    -- Enforce that this is not a dummy item/fluid if there are trigger techs attached
    if #slot.trigger_techs > 0 and traveler.dummy then
        return false
    end

    -- Otherwise, accept
    -- CRITICAL TODO: Go through any other checks needed!
    return true
end

-- We don't need to fix a trigger tech more than once
local trigger_techs_fixed = {}
recipe_results.do_slot_conn_fixes = function(slot, traveler)
    -- If this traveler is not of type craft-material, make it a craft-material
    local node_example = graph_utils.get(traveler.nodes[build_graph.compound_key({"planet", "nauvis"})].dependents[1])
    if node_example.type ~= "craft-material-surface" then
        for _, node in pairs(traveler.nodes) do
            local old_dependent = graph_utils.get(node.dependents[1])
            local material_type
            local material_name
            if old_dependent.item ~= nil then
                material_type = "item"
                material_name = old_dependent.item
            else
                material_type = "fluid"
                material_name = old_dependent.fluid
            end
            -- Test that craft-material node exists in case it's a dummy; if it is then we don't need to worry about this
            local craft_material_node = graph_utils.getk("craft-material-surface", build_graph.compound_key({material_type .. "-" .. material_name, old_dependent.surface}))
            if craft_material_node ~= nil then
                graph_utils.remove_prereq(node, old_dependent)
                graph_utils.add_prereq(node, craft_material_node)
            end
        end
    end

    -- Also fix trigger techs (this modifies data.raw but it's more convenient here than in reflect)
    for _, tech in pairs(slot.trigger_techs) do
        if not trigger_techs_fixed[tech.name] then
            trigger_techs_fixed[tech.name] = true
            if traveler.item ~= nil then
                tech.research_trigger.type = "craft-item"
                tech.research_trigger.item = traveler.item
            elseif traveler.fluid ~= nil then
                tech.research_trigger.type = "craft-fluid"
                tech.research_trigger.fluid = traveler.fluid
            end
        end
    end
end

-- I'm wondering if reflection should be done all at once as a separate step rather than handled by each slot individually
-- In item randomization, for example, we need to first gather the changes, so like an item that spoils into one thing being changed might cause that new item to see it needs to be changed again wrongly
-- However, as long as we detect what needs to be changed from the graph rather than from data.raw, I think we're good
recipe_results.reflect = function(slot_to_traveler)
    -- CRITICAL TODO: Cost-based amounts reassignment (also for choosing valid connections)
    -- Do this after testing to make sure it at least runs first

    local function reassign_slot_material(result, traveler)
        local traveler_canonical = helper.to_canonical(traveler)
        if traveler_canonical.item ~= nil then
            result.type = "item"
            result.name = traveler_canonical.item
        elseif traveler_canonical.fluid ~= nil then
            result.type = "fluid"
            result.name = traveler_canonical.fluid
        else
            error("None item/fluid node assigned to recipe-results slot.")
        end
    end

    local tech_to_slot = {}
    for _, slot in pairs(state.sorted_slots) do
        if slot.handler_id == "recipe-results" then
            local traveler = slot_to_traveler[graph_utils.get_node_key(slot)]
            if traveler ~= nil then
                local recipe_prot
                if not slot.dummy then
                    recipe_prot = data.raw.recipe[slot.recipe]

                    -- Look for technology trigger effects to change
                    for _, tech in pairs(slot.trigger_techs) do
                        tech_to_slot[tech.name] = slot
                    end
                    
                    if not traveler.dummy then
                        reassign_slot_material(recipe_prot.results[slot.ind], traveler)
                    else
                        -- CRITICAL TODO: We're removing the whole recipe here just because of one result missing; we should probably fix that!
                        -- Remove this recipe
                        --recipe_prot.hidden = true
                        --helper.remove_recipe_tech_unlock(recipe_prot.name)
                        -- Okay, hotfix for now, only do this if there are no longer results
                        -- Need to still follow up with the critical todo to make sure we only address one result per randomization or that we check more carefully if they all go away
                        if recipe_prot.results ~= nil and #recipe_prot.results == 1 then
                            recipe_prot.hidden = true
                            helper.remove_recipe_tech_unlock(recipe_prot.name)
                        end
                    end
                else
                    if not traveler.dummy then
                        local recipe_prot = data.raw.recipe[slot.original_recipe]

                        -- Create a new recipe for this item/fluid
                        recipe_prot = dupe.recipe(recipe_prot, {suffix = "recipe-results-dummy"})
                        reassign_slot_material(recipe_prot.results[slot.ind], traveler)
                    else
                        -- In this case actually we don't need to do anything
                    end
                end

                if not traveler.dummy and recipe_prot ~= nil then
                    recipe_prot.main_product = nil
                    if recipe_prot.icon == nil then
                        --recipe_prot.icon = data.raw.item["iron-plate"].icon
                    end
                    
                    -- In this case, recipe_prot might need some fixes
                    local mat_prot
                    local traveler_canonical = helper.to_canonical(traveler)
                    if traveler_canonical.item ~= nil then
                        mat_prot = helper.items[traveler_canonical.item]
                    elseif traveler_canonical.fluid ~= nil then
                        mat_prot = data.raw.fluid[traveler_canonical.fluid]
                    end

                    -- Fix icon and localised_name
                    if recipe_prot.icons == nil and recipe_prot.icon == nil then
                        local recipe_icons
                        if mat_prot.icons ~= nil then
                            recipe_prot.icons = mat_prot.icons
                        else
                            recipe_prot.icons = {
                                {
                                    icon = mat_prot.icon,
                                    icon_size = mat_prot.icon_size or 64
                                }
                            }
                        end
                    end

                    -- CRITICAL TODO: Correct localised names
                end
            else
                -- Hide unused recipes
                recipe_prot = data.raw.recipe[slot.recipe]
                if recipe_prot ~= nil then
                    recipe_prot.hidden = true
                end
            end
        end
    end

    -- Fix main products; not sure how they're broken
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.main_product ~= nil then
            if recipe.results ~= nil then
                local has_valid_result = false
                for _, ing in pairs(recipe.results) do
                    if ing.name == recipe.main_product then
                        has_valid_result = true
                        break
                    end
                end
                if not has_valid_result then
                    recipe.main_product = nil
                end
            else
                recipe.main_product = nil
            end
        end
    end

    -- Fix technology trigger effects
    -- We actually do this in the main execute.lua now
    --[[for _, tech in pairs(data.raw.technology) do
        if tech_to_slot[tech.name] ~= nil then
            local new_crafting_material = slot_to_traveler[graph_utils.get_node_key(tech_to_slot[tech.name])]
            tech.research_trigger.type = "craft-" .. new_crafting_material.material_type
            tech.research_trigger.item = new_crafting_material.item
            tech.research_trigger.fluid = new_crafting_material.fluid
        end
    end]]
end

return recipe_results