-- A rebuilt recipe's chosen research method may not cover its other unlock paths.
local gutils = require("src/lib/graph/graph-utils")
local top = require("src/lib/sort/context-sort")

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
                stop_if = function(node_key)
                    return node_key == recipe_key
                end,
            })
            for ind, _ in pairs(path.in_path) do
                if sort_info.pebble_keys[ind] == recipe_key then
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

-- The contexts each kept path (from unlocks.retained) is kept for, as tech name --> context --> the earliest index of the recipes it's kept for there (sort_info's, the sort retained was given)
-- Those are the contexts of a recipe it's kept for that it has and the recipe's own tech (sources) doesn't, so elsewhere the recipe's own tech unlocks the recipe
-- A path kept because the recipe's own tech needs the recipe there (see depends_on_unlock above) is kept for every context of the recipe it has
unlocks.kept_for = function(sources, sort_info, retained)
    local kept_for = {}
    if sort_info == nil then
        return kept_for
    end
    local contexts = sort_info.node_to_context_inds
    for name, recipes in pairs(retained) do
        local alternate = contexts[gutils.key("technology", name)] or {}
        local found = {}
        for recipe_name, _ in pairs(recipes) do
            local selected = contexts[gutils.key("technology", sources[recipe_name] or "")] or {}
            local recipe_contexts = contexts[gutils.key("recipe", recipe_name)] or {}
            local any = false
            for context, ind in pairs(recipe_contexts) do
                if alternate[context] ~= nil and selected[context] == nil then
                    found[context] = math.min(found[context] or ind, ind)
                    any = true
                end
            end
            if not any then
                for context, ind in pairs(recipe_contexts) do
                    if alternate[context] ~= nil then
                        found[context] = math.min(found[context] or ind, ind)
                    end
                end
            end
        end
        kept_for[name] = found
    end
    return kept_for
end

-- Names of a recipe's techs: its rebuilt tech (src/randomizations/rebuild/init.lua) and the numbered unlocks from unlocks.split
unlocks.rebuilt_name = function(recipe_name)
    return "exfret-rebuilt-" .. recipe_name .. "-suffix"
end
unlocks.numbered_name = function(recipe_name, number)
    return "exfret-rebuilt-" .. recipe_name .. "-unlock-" .. number .. "-suffix"
end

-- Whether a tech is one of a recipe's numbered unlocks
local function is_numbered(tech_name, recipe_name, technologies)
    local number = 2
    while technologies[unlocks.numbered_name(recipe_name, number)] ~= nil do
        if unlocks.numbered_name(recipe_name, number) == tech_name then
            return true
        end
        number = number + 1
    end
    return false
end

-- Makes each kept alternate unlock path (unlocks.retained) a tech of its own, so that every tech still unlocks a single recipe (user, 2026-10-08)
-- The original's research and prerequisites go to a new tech for each recipe it was kept for, numbered after the recipe's rebuilt tech: that one is "(Unlock 1)", the new ones "(Unlock 2)" and up
-- A copy has the original's research and prerequisites, so it gives the recipe the same contexts, and techs that needed the original need its copies too
-- The original keeps only effects other than recipe unlocks, and is hidden like the other emptied originals when none are left
-- A tech that already is one of its recipe's numbered unlocks (a copy from an earlier rebuild) is left unchanged
-- Arguments: technologies is data.raw.technology after the rebuild, retained the unlocks it kept (tech name --> recipe name --> true), recipe_unlocks_before (tech name --> how many recipes it unlocked before the rebuild) divides a copied unit's count as for the rebuilt techs, and describe(recipe_name) gives { localised_name, icons } for the recipe's techs
-- Returns copy name --> { recipe = recipe name, original = tech name }, and the sorted names of the originals that were copied
unlocks.split = function(technologies, retained, recipe_unlocks_before, describe)
    local copies = {}
    local copies_of = {}
    local originals = {}
    local tech_names = {}
    for tech_name, _ in pairs(retained) do
        table.insert(tech_names, tech_name)
    end
    table.sort(tech_names)
    for _, tech_name in pairs(tech_names) do
        local original = technologies[tech_name]
        local recipe_names = {}
        for recipe_name, _ in pairs(retained[tech_name]) do
            table.insert(recipe_names, recipe_name)
        end
        table.sort(recipe_names)
        for _, recipe_name in pairs(recipe_names) do
            local description = describe(recipe_name)
            local rebuilt = technologies[unlocks.rebuilt_name(recipe_name)]
            if rebuilt ~= nil then
                rebuilt.localised_name = {
                    "propertyrandomizer-name.unlock-number",
                    description.localised_name,
                    "1",
                }
            end
            if original ~= nil and not is_numbered(tech_name, recipe_name, technologies) then
                local number = 2
                while technologies[unlocks.numbered_name(recipe_name, number)] ~= nil do
                    number = number + 1
                end
                local copy = {
                    type = "technology",
                    name = unlocks.numbered_name(recipe_name, number),
                    localised_name = {
                        "propertyrandomizer-name.unlock-number",
                        description.localised_name,
                        tostring(number),
                    },
                    icons = description.icons,
                    prerequisites = table.deepcopy(original.prerequisites or {}),
                    effects = {
                        {
                            type = "unlock-recipe",
                            recipe = recipe_name,
                        },
                    },
                }
                if original.unit ~= nil then
                    copy.unit = table.deepcopy(original.unit)
                    if copy.unit.count ~= nil then
                        copy.unit.count = math.ceil(copy.unit.count / math.max(1, recipe_unlocks_before[tech_name] or 1))
                    end
                else
                    copy.research_trigger = table.deepcopy(original.research_trigger)
                end
                technologies[copy.name] = copy
                copies[copy.name] = {
                    recipe = recipe_name,
                    original = tech_name,
                }
                copies_of[tech_name] = copies_of[tech_name] or {}
                table.insert(copies_of[tech_name], copy.name)
                local kept_effects = {}
                for _, effect in pairs(original.effects or {}) do
                    if effect.type ~= "unlock-recipe" or effect.recipe ~= recipe_name then
                        table.insert(kept_effects, effect)
                    end
                end
                original.effects = kept_effects
            end
        end
        if copies_of[tech_name] ~= nil then
            table.insert(originals, tech_name)
            if #original.effects == 0 then
                original.hidden = true
                original.hidden_in_factoriopedia = true
            end
        end
    end
    -- What needed an original needs its copies, and no longer the original once it's hidden
    for _, technology in pairs(technologies) do
        local prerequisites = {}
        local listed = {}
        local changed = false
        for _, prerequisite in pairs(technology.prerequisites or {}) do
            local replaced = copies_of[prerequisite] ~= nil and technologies[prerequisite].hidden == true
            if not replaced and listed[prerequisite] == nil then
                table.insert(prerequisites, prerequisite)
                listed[prerequisite] = true
            end
            for _, copy_name in pairs(copies_of[prerequisite] or {}) do
                if listed[copy_name] == nil then
                    table.insert(prerequisites, copy_name)
                    listed[copy_name] = true
                end
            end
            changed = changed or copies_of[prerequisite] ~= nil
        end
        if changed then
            technology.prerequisites = prerequisites
        end
    end
    return copies, originals
end

return unlocks
