local graph_utils = require("lib/graph/graph-utils")
local rng = require("lib/random/rng")
local registry = require("randomizations/graph/core/registry")

-- Primitive recipe randomizer, does not care about automatability or costs

local recycling_category = "recycling"
local fluid_type = "fluid"
local item_type = "item"
local recipe_node_type = "recipe-surface"
local item_node_type = "item-surface"
local fluid_node_type = "fluid-surface"

-- Item lookup
local items = {}
for item_class, _ in pairs(defines.prototypes.item) do
    if data.raw[item_class] ~= nil then
        for _, item in pairs(data.raw[item_class]) do
            items[item.name] = item
        end
    end
end

local recipe_randomizer = registry.create_empty_randomizer("recipe")
recipe_randomizer.get_target_edges = function (params)
    local edges = {}
    for _, node_key in pairs(params.node_type_to_node_keys[recipe_node_type]) do
        local node = params.vanilla_graph[node_key]
        local recipe = data.raw.recipe[node.recipe]
        if recipe.category ~= recycling_category
        and recipe.factoriopedia_alternative == nil then
            for _, prereq in pairs(node.prereqs) do
                if prereq.type == item_node_type or prereq.type == fluid_node_type then
                    local edge = graph_utils.create_edge(graph_utils.get_node_key(prereq), node_key, params.vanilla_graph)
                    edges[edge.key] = edge
                end
            end
        end
    end
    return edges
end

recipe_randomizer.execute_randomization = function (params)
    if #params.suitable_edges < params.first_edge_count and not params.critical_node then
        params.postpone = true
        return
    end
    if #params.suitable_edges < 1 and params.first_edge_count > 0 then
        params.postpone = true
        return
    end
    rng.shuffle(params.rng_key, params.suitable_edges)
    for i = 1, math.min(params.first_edge_count, #params.suitable_edges) do
        params.new_edges[i] = params.suitable_edges[i]
    end
end

recipe_randomizer.finalize = function (params)
    local recipes_handled = {}
    for _, node_key in pairs(params.node_type_to_node_keys[recipe_node_type]) do
        local node = params.random_graph[node_key]
        if recipes_handled[node.recipe] == nil then
            recipes_handled[node.recipe] = true
            local recipe = data.raw.recipe[node.recipe]
            if recipe.category ~= recycling_category
            and recipe.factoriopedia_alternative == nil
            and recipe.ingredients ~= nil then
                local fluid_prereqs = {}
                local item_prereqs = {}
                for _, prereq in pairs(node.prereqs) do
                    local prereq_node = graph_utils.get_node(params.random_graph, prereq)
                    if prereq_node.type == fluid_node_type then
                        table.insert(fluid_prereqs, prereq_node.fluid)
                    elseif prereq_node.type == item_node_type then
                        table.insert(item_prereqs, prereq_node.item)
                    end
                end
                local fluid_ingredients = {}
                local item_ingredients = {}
                for _, ing in pairs(recipe.ingredients) do
                    if ing.type == fluid_type then
                        fluid_ingredients[#fluid_ingredients+1] = ing
                    elseif ing.type == item_type then
                        item_ingredients[#item_ingredients+1] = ing
                    end
                end
                for i = 1, math.min(#fluid_prereqs, #fluid_ingredients) do
                    fluid_ingredients[i].name = fluid_prereqs[i]
                end
                if #fluid_prereqs < #fluid_ingredients then
                    for i = #fluid_prereqs + 1, #fluid_ingredients do
                        fluid_ingredients[i].amount = 0
                    end
                elseif #fluid_prereqs > #fluid_ingredients then
                    for i = #fluid_ingredients + 1, #fluid_prereqs do
                        fluid_ingredients[i] = {
                            type = fluid_type,
                            name = fluid_prereqs[i],
                            amount = 1,
                        }
                    end
                end
                for i = 1, math.min(#item_prereqs, #item_ingredients) do
                    item_ingredients[i].name = item_prereqs[i]
                    local item = items[item_prereqs[i]]
                    if item.stack_size <= 1 then
                        item_ingredients[i].amount = 1
                    end
                end
                if #item_prereqs < #item_ingredients then
                    for i = #item_prereqs + 1, #item_ingredients do
                        item_ingredients[i].amount = 0
                    end
                elseif #item_prereqs > #item_ingredients then
                    for i = #item_ingredients + 1, #item_prereqs do
                        item_ingredients[i] = {
                            type = item_type,
                            name = item_prereqs[i],
                            amount = 1,
                        }
                    end
                end
                local i = 1
                while i <= #recipe.ingredients do
                    if recipe.ingredients[i].amount == 0 then
                        table.remove(recipe.ingredients, i)
                    else
                        i = i + 1
                    end
                end
            end
        end
    end
end

registry.add(recipe_randomizer)
