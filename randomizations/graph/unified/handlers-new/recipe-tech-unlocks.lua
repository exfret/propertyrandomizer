local gutils = require("new-lib/graph/graph-utils")

local recipe_tech_unlocks = {}

recipe_tech_unlocks.id = "recipe_tech_unlocks"

recipe_tech_unlocks.claim = function(graph, prereq, dep, edge)
    if prereq.type == "recipe-tech-unlock" and dep.type == "recipe" then
        return 4
    end
end

recipe_tech_unlocks.validate = function(graph, base, head, extra)
    if gutils.get_owner(graph, base).type == "recipe-tech-unlock" then
        return true
    end
end

recipe_tech_unlocks.reflect = function(graph, head_to_base, head_to_handler)
    local recipe_to_techs = {}

    for _, tech in pairs(data.raw.technology) do
        if tech.effects ~= nil then
            for ind, effect in pairs(tech.effects) do
                if effect.type == "unlock-recipe" then
                    recipe_to_techs[effect.recipe] = recipe_to_techs[effect.recipe] or {}
                    recipe_to_techs[effect.recipe][tech.name] = ind
                end
            end
        end
    end

    for head_key, base_key in pairs(head_to_base) do
        if head_to_handler[head_key].id == "recipe_tech_unlocks" then
            local recipe_unlock_name = gutils.get_owner(graph, graph.nodes[base_key]).name
            local techs_to_change = recipe_to_techs[recipe_unlock_name]
            for tech_name, ind in pairs(techs_to_change) do
                data.raw.technology[tech_name].effects[ind].recipe = gutils.get_owner(graph, graph.nodes[head_key]).name
            end
        end
    end
end

return recipe_tech_unlocks