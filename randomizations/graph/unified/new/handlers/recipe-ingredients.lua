-- No cost preservation for now, just enough to get it loading

local gutils = require("new-lib/graph/graph-utils")

local recipe_ingredients = {}

recipe_ingredients.id = "recipe_ingredients"

recipe_ingredients.claim = function(graph, prereq, dep, trav)
    if (prereq.type == "item" or prereq.type == "fluid") and dep.type == "recipe" then
        local recipe = data.raw.recipe[dep.name]
        if recipe.hidden then
            return false
        end
        -- TODO: Other checks
        -- TODO: Better claim logic (not sure what that would entail yet)
        -- TODO: Things are delicate right now... I should really decrease this from 6 or at least add ways to encourage lesser-used intermediates
        return 6
    end
end

recipe_ingredients.validate = function(graph, slot, trav, extra)
    local slot_owner = gutils.get_conn_owner(graph, slot)
    if slot_owner.type ~= "fluid" and slot_owner.type ~= "item" then
        return false
    end

    -- Only allow fluids in fluid slots and items in item slots for now
    local old_prereq = gutils.get_conn_owner(graph, graph.nodes[trav.old_slot])
    if old_prereq.type ~= slot_owner.type then
        return false
    end

    -- Otherwise, we're probably okay for now
    return true
end

recipe_ingredients.reflect = function(graph, trav_to_new_slot, trav_to_handler)
    -- Hotfix for now: don't add an ing if it's already been added
    local added_ings = {}

    local recipe_inds_to_remove = {}
    for trav_key, slot in pairs(trav_to_new_slot) do
        if trav_to_handler[trav_key].id == "recipe_ingredients" then
            local trav = graph.nodes[trav_key]
            local recipe_node = gutils.get_conn_owner(graph, trav)
            local recipe = data.raw.recipe[recipe_node.name]
            added_ings[recipe.name] = added_ings[recipe.name] or {}
            local ing = gutils.get_conn_owner(graph, slot)
            -- trav.inds holds recipe inds of old ingredient
            for ind, _ in pairs(trav.inds) do
                if not added_ings[recipe.name][gutils.key(ing)] then
                    added_ings[recipe.name][gutils.key(ing)] = true
                    recipe.ingredients[ind].type = ing.type
                    recipe.ingredients[ind].name = ing.name
                else
                    recipe_inds_to_remove[recipe.name] = recipe_inds_to_remove[recipe.name] or {}
                    recipe_inds_to_remove[recipe.name][ind] = true
                end
            end
        end
    end

    for recipe_name, inds in pairs(recipe_inds_to_remove) do
        local recipe = data.raw.recipe[recipe_name]
        local new_ings = {}
        for ind, ing in pairs(recipe.ingredients) do
            if not inds[ind] then
                table.insert(new_ings, ing)
            end
        end
        recipe.ingredients = new_ings
    end
end

return recipe_ingredients