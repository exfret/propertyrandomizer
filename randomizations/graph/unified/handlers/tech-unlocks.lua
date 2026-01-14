-- Just does recipe tech unlocks for now

local gutils = require("new-lib/graph/graph-utils")

local tech_unlocks = {}

tech_unlocks.id = "tech_unlocks"




-- CRITICAL TODO: Remove when done testing!
tech_unlocks.spoof = function(graph)
    --[[local edges_to_remove = {}
    for _, edge in pairs(graph.edges) do
        local start_node = graph.nodes[edge.start]
        local stop_node = graph.nodes[edge.stop]
        if start_node.type == "recipe-tech-unlock" and stop_node.type == "recipe" then
            table.insert(edges_to_remove, edge)
        end
    end
    for _, edge in pairs(edges_to_remove) do
        gutils.remove_edge(graph, gutils.ekey(edge))
    end]]
end






tech_unlocks.claim = function(graph, prereq, dep, trav)
    if prereq.type == "technology" and dep.type == "recipe-tech-unlock" then
        return 4
    end
end

tech_unlocks.validate = function(graph, slot, trav, extra)
    if gutils.get_conn_owner(graph, slot).type == "technology" then
        return true
    end
end

tech_unlocks.reflect = function(graph, trav_to_new_slot, trav_to_handler)
    -- First, wipe all old tech unlocks
    -- TODO: We might want to blacklist some tech unlocks from changing later, in which case we wouldn't want to wipe those here
    for _, tech in pairs(data.raw.technology) do
        if tech.effects ~= nil then
            local new_effects = {}
            for _, effect in pairs(tech.effects) do
                if effect.type ~= "unlock-recipe" then
                    table.insert(new_effects, effect)
                end
            end
            tech.effects = new_effects
        end
    end

    --[[for trav_key, slot in pairs(trav_to_new_slot) do
        if trav_to_handler[trav_key].id == "tech_unlocks" then
            -- The or part is in case of hacky combining tech unlocks that I was doing
            local dep = gutils.get_conn_owner(graph, graph.nodes[trav_key]) or graph.nodes[trav_key]
            local recipe_name = dep.name
            local tech_name = gutils.get_conn_owner(graph, slot).name]]
    for trav_key, slot in pairs(trav_to_new_slot) do
        if trav_to_handler[trav_key].id == "tech_unlocks" then
            local node = graph.nodes[trav_key]
            local recipe_name
            if node.type == "recipe-tech-unlock" then
                -- Hacky COMBINE path: the "trav" is the recipe-tech-unlock node itself
                -- This should no longer be used unless I resurrect the tech unlock combiner
                error()
                recipe_name = node.name
            else
                -- Normal path: trav is a traveler, get the owner (recipe-tech-unlock)
                local dep = gutils.get_conn_owner(graph, node)
                recipe_name = dep.name
            end
            -- Only look at head travelers
            --if string.find(node.name, "-head") ~= nil then
                -- If this is not the name of a recipe, we probably are combining tech unlocks, so just look at dependent's name
                if data.raw.recipe[recipe_name] == nil then
                    local slot_before_recipe = graph.nodes[graph.edges[next(gutils.get_conn_owner(graph, node).dep)].stop]
                    recipe_name = gutils.get_conn_owner(graph, gutils.get_conn_buddy(graph, slot_before_recipe)).name
                    -- Remove the "recipe-final" prefix
                    recipe_name = string.sub(recipe_name, 14, -1)
                end
                local tech_name = gutils.get_conn_owner(graph, slot).name
                local tech = data.raw.technology[tech_name]
                tech.effects = tech.effects or {}
                table.insert(tech.effects, {
                    type = "unlock-recipe",
                    recipe = recipe_name,
                })
            --end
        end
    end
end

return tech_unlocks