-- A rebuilt recipe's chosen research method may not cover its other unlock paths.
local gutils = require("lib/graph/graph-utils")
local top = require("lib/graph/context-sort")

local unlocks = {}

unlocks.retained = function(technologies, sources, sort_info, graph)
    local retained = {}
    if sort_info == nil then
        return retained
    end
    local contexts = sort_info.node_to_context_inds
    local needs_alternate = {}
    local function depends_on_unlock(recipe_name, selected)
        if needs_alternate[recipe_name] == nil then
            needs_alternate[recipe_name] = false
            local recipe_key = gutils.key("recipe", recipe_name)
            local roots = {}
            for context, _ in pairs(contexts[recipe_key] or {}) do
                if selected[context] ~= nil then
                    table.insert(roots, selected[context])
                end
            end
            local path = top.path(graph, roots, sort_info, {
                stop_if = function(pebble)
                    return pebble.node_key == recipe_key
                end,
            })
            for ind, _ in pairs(path.in_path) do
                if sort_info.sorted[ind].node_key == recipe_key then
                    needs_alternate[recipe_name] = true
                    break
                end
            end
        end
        return needs_alternate[recipe_name]
    end
    for name, technology in pairs(technologies) do
        for _, effect in pairs(technology.effects or {}) do
            local source = sources[effect.recipe]
            if effect.type == "unlock-recipe" and source ~= nil and source ~= name then
                local selected = contexts[gutils.key("technology", source)] or {}
                local alternate = contexts[gutils.key("technology", name)] or {}
                local contributes = false
                for context, _ in pairs(contexts[gutils.key("recipe", effect.recipe)] or {}) do
                    if alternate[context] ~= nil then
                        contributes = true
                        if selected[context] == nil then
                            retained[name] = retained[name] or {}
                            retained[name][effect.recipe] = true
                            break
                        end
                    end
                end
                -- A context supplied through the recipe itself disappears if its independent unlock is removed.
                if contributes == true and (retained[name] or {})[effect.recipe] == nil and depends_on_unlock(effect.recipe, selected) then
                    retained[name] = retained[name] or {}
                    retained[name][effect.recipe] = true
                end
            end
        end
    end
    return retained
end

return unlocks
