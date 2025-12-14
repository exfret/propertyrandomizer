local build_graph = require("lib/graph/build-graph")
local graph_utils = require("lib/graph/graph-utils")
local helper = require("randomizations/graph/unified/helper")

local recipe_ingredients = {}

recipe_ingredients.state = {}
recipe_ingredients.init = function(state)
    for k, v in pairs(state) do
        recipe_ingredients.state[k] = v
    end
end

recipe_ingredients.source_types = {
    ["fluid-surface"] = true,
    ["item-surface"] = true
}
recipe_ingredients.target_types = {
    ["recipe-surface"] = true
}
recipe_ingredients.group_surfaces = true

-- Note: This is ignored since we actually only consider the first ingredient ever
-- CRITICAL TODO: FIX THIS!
recipe_ingredients.add_dummies = function()
    -- Add an extra item and fluid ingredient for each recipe for the dummies
    for _, recipe in pairs(data.raw.recipe) do
        if recipe.ingredients ~= nil and #recipe.ingredients > 1 then
            local recipe_node = graph_utils.getk("recipe", recipe.name)
            local dummy_item_ingredient = helper.create_dummy_node("item", build_graph.compound_key({recipe_node.name, "recipe-ingredients-item-dummy"}))
            dummy_item_ingredient.item = "dummy"
            local dummy_fluid_ingredient = helper.create_dummy_node("fluid", build_graph.compound_key({recipe_node.name, "recipe-ingredients-fluid-dummy"}))
            dummy_fluid_ingredient.fluid = "dummy"
            for surface_name, surface in pairs(build_graph.surfaces) do
                local surface_dummy_item_ingredient = helper.create_dummy_node("item-surface", build_graph.compound_key({build_graph.compound_key({recipe_node.name, "recipe-ingredients-item-dummy"}), surface_name}))
                surface_dummy_item_ingredient.surface = surface_name
                surface_dummy_item_ingredient.item = "dummy"
                local surface_dummy_fluid_ingredient = helper.create_dummy_node("fluid-surface", build_graph.compound_key({build_graph.compound_key({recipe_node.name, "recipe-ingredients-fluid-dummy"}), surface_name}))
                surface_dummy_fluid_ingredient.surface = surface_name
                surface_dummy_fluid_ingredient.fluid = "dummy"
                local surface_recipe_node = helper.specify_node_to_surface(recipe_node, surface_name)
                graph_utils.add_prereq(surface_dummy_item_ingredient, dummy_item_ingredient)
                graph_utils.add_prereq(surface_dummy_item_ingredient, surface_recipe_node)
                -- We need a place where these nodes get "unlocked", consider that to occur when the recipe-unlock is done
                if recipe.enabled ~= nil and not recipe.enabled then
                    -- Only add the fluid prereq if this is a later recipe
                    graph_utils.add_prereq(surface_dummy_fluid_ingredient, dummy_fluid_ingredient)
                    graph_utils.add_prereq(surface_dummy_fluid_ingredient, surface_recipe_node)

                    graph_utils.add_prereq(graph_utils.getk("recipe-tech-unlock", recipe.name), surface_dummy_item_ingredient)
                    graph_utils.add_prereq(graph_utils.getk("recipe-tech-unlock", recipe.name), surface_dummy_fluid_ingredient)
                else
                    -- If the recipe is enabled by default, consider the ingredients to always be available; just wire fluid to holding surface and item to character hand mining
                    graph_utils.add_prereq(graph_utils.getk("starting-character", "canonical"), surface_dummy_item_ingredient)
                    -- Holding any fluid is probably enough to justify this as a fluid ingredient
                    for _, fluid in pairs(data.raw.fluid) do
                        graph_utils.add_prereq(graph_utils.getk("hold-fluid-surface", build_graph.compound_key({fluid.name, surface_name})), surface_dummy_fluid_ingredient)
                    end
                end
            end
        end
    end
end

recipe_ingredients.create_slot = function(edge)
    local material_type
    local material_name
    if edge[1].item ~= nil then
        material_type = "item"
        material_name = edge[1].item
    else
        material_type = "fluid"
        material_name = edge[1].fluid
    end
    return {
        item = edge[1].item,
        fluid = edge[1].fluid,
        material_type = material_type,
        material_name = material_name,
    }
end

-- CRITICAL TODO: Need to check that this isn't a "critical" recipe, like iron ore to iron plates
recipe_ingredients.create_traveler = function(edge)
    if edge[2].dummy or data.raw.recipe[edge[2].recipe].ingredients == nil then
        return false
    end

    local material_type
    local ingredient_index
    for ind, ing in pairs(data.raw.recipe[edge[2].recipe].ingredients) do
        if ((ing.type == "item" and ing.name == edge[1].item) or (ing.type == "fluid" and ing.fluid == edge[1].fluid)) then
            material_type = ing.type
            ingredient_index = ind
            break
        end
    end

    -- Only do one ingredient per recipe
    -- Otherwise we get issues since recipes are AND nodes
    if ingredient_index ~= 1 then
        return false
    end

    return {
        material_type = material_type,
        recipe = edge[2].recipe,
        ind = ingredient_index,
    }
end

recipe_ingredients.to_canonical = function(slot_or_traveler)
    if slot_or_traveler.dummy then
        -- The travelers always still correspond to real recipes
        if slot_or_traveler.connector_type == "traveler" then
            return graph_utils.getk("recipe", slot_or_traveler.recipe)
        end
        -- the slots don't, though
        return "dummy"
    end

    -- In this case, slots are materials, travelers are recipes
    if slot_or_traveler.connector_type == "slot" then
        return graph_utils.getk(slot_or_traveler.material_type, slot_or_traveler.material_name)
    elseif slot_or_traveler.connector_type == "traveler" then
        return graph_utils.getk("recipe", slot_or_traveler.recipe)
    end
end

-- "Hard-to-get" materials are the ones that we are fine replacing, the "easier" ones should be reserved for the "important" travelers
-- However, I'm not really sure a good way to classify "hard-to-get"; and even "easy-to-get" things are often fine to be reserved if they're numerous enough
-- I think maybe it's fine if they're always reservable?
-- We just need to maybe be more picky about the ing-recipe connections we accept
recipe_ingredients.is_reservable = function(slot)
    return true
end

recipe_ingredients.traveler_priority = function(traveler)
    -- Just do normal priority calculations (probably keep this for all handlers for now)
    return helper.find_priority(traveler, recipe_ingredients.state)
end

recipe_ingredients.validate_connection = function(slot, traveler)
    -- CRITICAL TODO: We can actually connect to non-recipe nodes! The slot is the item/fluid, and those are fine elsewhere!
    -- Check that it's a recipe
    -- CRITICAL TODO: Do recipe checks as well (need to do those in the first place as well)
    if traveler.recipe == nil then
        return false
    end

    local recipe_prot = data.raw.recipe[traveler.recipe]
    if slot.fluid ~= nil and not (recipe_prot.category == "oil-processing" or recipe_prot.category == "chemistry" or recipe_prot.category == "crafting-with-fluid") then
        return false
    end

    -- Things seem to be working without this somehow and broken otherwise
    --[[if slot.material_type == "fluid" and traveler.fluid == nil and traveler.material_type ~= "fluid" then
        return false
    end
    if slot.material_type == "item" and traveler.item == nil and traveler.material_type ~= "item" then
        return false
    end]]

    -- Check that single-slot recipes don't get a dummy item/fluid as their ingredient
    -- No wait, this is fine, just interpret dummies as adding ingredients, not removing
    --[[if traveler.recipe ~= "dummy" and data.raw.recipe[traveler.recipe].ingredients ~= nil and #data.raw.recipe[traveler.recipe].ingredients == 1 then
        if slot.dummy then
            return false
        end
    end]]
    
    return true
end

recipe_ingredients.reflect = function(sorted_slots, slot_to_traveler)
    -- CRITICAL TODO: Cost-based amounts reassignment (also for choosing valid connections)
    -- ^^^ The above critical todo actually applies in a lot of places

    -- CRITICAL TODO: Make sure we don't accidentally make a recipe free! (Make sure it always has ingredients)
    
    -- Instead of going slot-by-slot, look at the new recipe ingredients as a whole, then balance them
    -- This allows us to do better balancing, more similar to in recipe.lua, and fixes the issue of deciding amounts
    for _, recipe in pairs(data.raw.recipe) do
        local new_ing_prots = {}

        local recipe_node = graph_utils.getk("recipe", recipe.name)
        -- Just get any surface specific node; they'll all have the ingredients
        local surface_recipe_node = helper.specify_node_to_surface(recipe_node, build_graph.compound_key({"planet", "nauvis"}))
        for _, prereq in pairs(surface_recipe_node.prereqs) do
            local prereq_node = graph_utils.get(prereq)
            -- First check for normal prereqs
            if prereq_node.type == "item-surface" and not prereq_node.dummy then
                table.insert(new_ing_prots, helper.items[prereq_node.item])
            elseif prereq_node.type == "fluid-surface" and not prereq_node.dummy then
                table.insert(new_ing_prots, data.raw.fluid[prereq_node.fluid])
            end
            -- Check if this is a traveler-type node
            if prereq_node.type == "traveler" or prereq_node.type == "traveler-surface" then
                -- We need this for the hotfix where we abandon ingredients randomization early if everything else went well
                -- This can probably be removed if I get rid of the hotfix
                if prereq_node.prereqs[1] ~= nil then
                    -- Need to go back to slot node, then what that slot node depends on, in order to get reliable data about whether this is an item or a fluid
                    local corresponding_slot_prereq = graph_utils.get(graph_utils.get(prereq_node.prereqs[1]).prereqs[1])
                    if corresponding_slot_prereq.type == "item-surface" then
                        table.insert(new_ing_prots, helper.items[corresponding_slot_prereq.item])
                    elseif corresponding_slot_prereq.type == "fluid-surface" then
                        table.insert(new_ing_prots, data.raw.fluid[corresponding_slot_prereq.fluid])
                    end
                end
            end
        end

        -- CRITICAL TODO: Actually balance amounts
        -- Right now, just set all amounts to one
        local new_ings = {}
        for _, prot in pairs(new_ing_prots) do
            local mat_type = "item"
            if prot.type == "fluid" then
                mat_type = "fluid"
            end

            table.insert(new_ings, {
                type = mat_type,
                name = prot.name,
                amount = 1
            })
        end
        recipe.ingredients = new_ings
    end
end

return recipe_ingredients