local gutils = require("new-lib/graph/graph-utils")

local recipe_tech_unlocks = {}

recipe_tech_unlocks.id = "recipe_tech_unlocks"

recipe_tech_unlocks.with_replacement = true

local tech_to_claimed = {}
recipe_tech_unlocks.claim = function(graph, prereq, dep, edge)
    if prereq.type == "recipe-tech-unlock" and dep.type == "recipe" then
        -- Just get a random tech
        if prereq.num_pre > 1 then
            return 1
        end
        local random_edge = gutils.unique_pre(graph, prereq)
        local tech_node = graph.nodes[random_edge.start]
        if not tech_to_claimed[tech_node.name] then
            tech_to_claimed[tech_node.name] = true
            return 1
        else
            return 1
        end
    end
end

recipe_tech_unlocks.validate = function(graph, base, head, extra)
    if gutils.get_owner(graph, base).type == "recipe-tech-unlock" then
        return true
    end
end

recipe_tech_unlocks.reflect = function(graph, head_to_base, head_to_handler)
    local recipe_to_techs = {}

    local tech_recipe_inds = {}
    for _, tech in pairs(data.raw.technology) do
        if tech.effects ~= nil then
            for ind, effect in pairs(tech.effects) do
                if effect.type == "unlock-recipe" then
                    recipe_to_techs[effect.recipe] = recipe_to_techs[effect.recipe] or {}
                    recipe_to_techs[effect.recipe][tech.name] = ind
                    tech_recipe_inds[tech.name] = tech_recipe_inds[tech.name] or {}
                    tech_recipe_inds[tech.name][ind] = true
                end
            end
        end
    end

    -- Needed in case we need to add multiple unlocks
    local tech_ind_used = {}
    for head_key, base_key in pairs(head_to_base) do
        if head_to_handler[head_key].id == "recipe_tech_unlocks" then
            local recipe_unlock_name = gutils.get_owner(graph, graph.nodes[base_key]).name
            local techs_to_change = recipe_to_techs[recipe_unlock_name]
            for tech_name, ind in pairs(techs_to_change) do
                tech_ind_used[tech_name] = tech_ind_used[tech_name] or {}
                if tech_ind_used[tech_name][ind] then
                    table.insert(data.raw.technology[tech_name].effects, {
                        type = "unlock-recipe",
                        recipe = gutils.get_owner(graph, graph.nodes[head_key]).name,
                    })
                else
                    tech_ind_used[tech_name][ind] = true
                    data.raw.technology[tech_name].effects[ind].recipe = gutils.get_owner(graph, graph.nodes[head_key]).name
                end
            end
        end
    end

    -- Remove any tech unlocks leftover
    for _, tech in pairs(data.raw.technology) do
        if tech.effects ~= nil then
            for i = #tech.effects, 1, -1 do
                if tech_recipe_inds[tech.name] ~= nil and tech_recipe_inds[tech.name][i] ~= nil and (not tech_ind_used[tech.name] or not tech_ind_used[tech.name][i]) then
                    table.remove(tech.effects, i)
                end
            end
        end
    end
end

return recipe_tech_unlocks