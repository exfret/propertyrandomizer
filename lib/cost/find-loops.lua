local gutils = require("lib/graph/graph-utils")

local find_loops = {}

local cost_data = require("lib/cost/material-costs/py-full-with-recipes")

local function get_scc_ids(graph)
    local index = 0
    local indices = {}
    local lowlink = {}

    local stack = {}
    local on_stack = {}

    local component_of = {}
    local component_id = 0

    local function strongconnect(v)
        index = index + 1
        indices[v] = index
        lowlink[v] = index

        stack[#stack + 1] = v
        on_stack[v] = true

        for w, _ in pairs(graph[v] or {}) do
            if graph[w] ~= nil then
                if indices[w] == nil then
                    strongconnect(w)
                    lowlink[v] = math.min(lowlink[v], lowlink[w])
                elseif on_stack[w] then
                    lowlink[v] = math.min(lowlink[v], indices[w])
                end
            end
        end

        if lowlink[v] == indices[v] then
            component_id = component_id + 1

            while true do
                local w = stack[#stack]
                stack[#stack] = nil
                on_stack[w] = nil

                component_of[w] = component_id

                if w == v then
                    break
                end
            end
        end
    end

    for v, _ in pairs(graph) do
        if indices[v] == nil then
            strongconnect(v)
        end
    end

    return component_of
end

find_loops.execute = function()
    local mat_graph = {}

    for mat, _ in pairs(cost_data.costs) do
        mat_graph[mat] = {}
    end

    for mat, recipe_name in pairs(cost_data.recipes) do
        local recipe = data.raw.recipe[recipe_name]
        for _, ing in pairs(recipe.ingredients or {}) do
            mat_graph[mat][gutils.key(ing)] = true
        end
    end

    local component_of = get_scc_ids(mat_graph)

    local loop_edges = {}

    for _, recipe in pairs(data.raw.recipe) do
        loop_edges[recipe.name] = {}
    end

    for mat, prereqs in pairs(mat_graph) do
        for prereq, _ in pairs(prereqs) do
            if component_of[mat] == component_of[prereq] then
                local recipe_name = cost_data.recipes[mat]
                loop_edges[recipe_name][prereq] = true
            end
        end
    end

    return loop_edges
end

return find_loops