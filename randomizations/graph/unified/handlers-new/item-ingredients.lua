local gutils = require("new-lib/graph/graph-utils")

local item_ingredients = {}

item_ingredients.id = "item_ingredients"

item_ingredients.with_replacement = false

item_ingredients.initialize = function()
end

item_ingredients.spoof = function(graph)
    -- Add new "ingredient" nodes
    for _, node in pairs(graph.nodes) do
        if node.type == "item" or node.type == "fluid" then
            local new_node = gutils.add_node(graph, node.type .. "-ingredient", node.name)
            new_node.op = "AND"
            gutils.add_edge(graph, node, new_node)
            local to_redirect = {}
            for dep, _ in pairs(node.dep) do
                local edge = graph.edges[dep]
                local depnode = graph.nodes[edge.stop]
                if depnode.type == "recipe" then
                    table.insert(to_redirect, {dep, new_node})
                end
            end
            for _, redirect_info in pairs(to_redirect) do
                gutils.redirect_edge_start(graph, redirect_info[1], redirect_info[2])
            end
            if #to_redirect == 0 then
                -- Consider it just a spoof if it doesn't lead to anything more (no dependents satisfied)
                new_node.spoof = true
            end
        end
    end
end

item_ingredients.claim = function(graph, prereq, dep, edge)
    if dep.type == "item-ingredient" or dep.type == "fluid-ingredient" then
        return 1
    end
end

item_ingredients.validate = function(graph, base, head, extra)
    local base_owner = gutils.get_owner(graph, base)
    local head_owner = gutils.get_owner(graph, head)
    if base_owner.type == "item" and head_owner.type == "item-ingredient" then
        return true
    end
    if base_owner.type == "fluid" and head_owner.type == "fluid-ingredient" then
        return true
    end
    return false
end

item_ingredients.reflect = function(graph, head_to_base, head_to_handler)
    for head_key, base_key in pairs(head_to_base) do
        if head_to_handler[head_key].id == "item_ingredients" then
            local base = graph.nodes[base_key]
            local head = graph.nodes[head_key]
            local base_owner = gutils.get_owner(graph, base)
            local head_owner = gutils.get_owner(graph, head)
            local new_ing_name = base_owner.name
            for dep, _ in pairs(head_owner.dep) do
                local edge = graph.edges[dep]
                local depnode = graph.nodes[edge.stop]
                local recipe = data.raw.recipe[depnode.name]
                for ind, _ in pairs(edge.inds) do
                    recipe.ingredients[ind].name = new_ing_name
                end
            end
        end
    end
end

return item_ingredients